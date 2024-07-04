#INCLUDE "PLSA090.ch"
#INCLUDE 'MSOBJECT.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER2.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "hatActions.ch"

#DEFINE G_CONSULTA  "01" 
#DEFINE G_SADT_ODON "13"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"

STATIC oBrwBEA		:= NIL 
STATIC oBrwPro		:= NIL
STATIC oBrwCri		:= NIL
STATIC oEncAut      := NIL
STATIC oBrwB4B		:= nil
STATIC aMatCom     	:= {}
STATIC __cDescri   	:= ""
STATIC __lAutoriz  	:= .F.
STATIC cPadPro	   	:= ""
STATIC nHorIni     	:= 0
STATIC __cCodRdaP  	:= ""
STATIC __cTipo     	:= "1"
STATIC lInfRda	   	:= .F.
STATIC cCodLocPar  	:= ""
STATIC aAutFor     	:= {}
STATIC aDadCri     	:= {}
STATIC aCabCri     	:= {}
STATIC aTrbCri     	:= {}
STATIC aValAcuAut  	:= {}
STATIC bImpGuia    	:= {|| A090PosArq(), IIf( ( ((BEA->BEA_STATUS $ "1,2,3,4" .OR. GetNewPar("MV_IGUINE", .F.)) .And. BEA->BEA_CANCEL <> "1") .Or. (BEA->BEA_STATUS == '6' .And. getNewPar("MV_PLIBAUD",.F.) == .T.))  ,IIF(ExistBlock("PLSA090IMP") ,ExecBlock("PLSA090IMP",.F.,.F.,{"1"}) ,IIf(GetNewPar("MV_PLSTISS","1")=="1" ,PLSR430N({"1",lImpGuiDir}) ,PLSR430({"1",lImpGuiDir}))) ,(Help("",1,"PLSR430")))}
STATIC bImpG2      	:= {|| A090PosArq(), If(.T.,IF(ExistBlock("PLSA090IMP"),ExecBlock("PLSA090IMP",.F.,.F.,{"2"}),IIf(GetNewPar("MV_PLSTISS","1")=="1", PLSR430N({"2",lImpGuiDir}), PLSR430({"2",lImpGuiDir}))),(Help("",1,"PLSR430")))   }
STATIC aDadB43     	:= {}
STATIC aCabB43     	:= {}
STATIC aTrbB43     	:= {}
STATIC aCdCores    	:= {}
STATIC cDesQtdSol  	:= ""
STATIC cDesQtdAut  	:= ""
STATIC aMatIte	   		:= {}
STATIC _aCopHCri   	:= {}
STATIC lBEANTit    	:= BEA->(FieldPos("BEA_NUMTIT"))>0
STATIC lLembre		:= .F.
STATIC aBkCritc		:= {}
STATIC aCabDf 		:= {}
STATIC aDadDf 		:= {}
STATIC aTrbDf 		:= {}
STATIC lIntGui		:= .F.
STATIC aCriCab 		:= {{}}
STATIC __cCodMedGen := GetNewPar("MV_PLMEDPT","")
STATIC __cCodMatGen := GetNewPar("MV_PLMATPT","")
STATIC __cCodTaxGen := GetNewPar("MV_PLTAXPT","")
STATIC __cCodOpmGen := GetNewPar("MV_PLOPMPT","")
STATIC cMV_PLSGEIN	:= getNewPar("MV_PLSGEIN","")
STATIC objCENFUNLGP := CENFUNLGP():New()

#define  K_VisOnline  15
#define  K_Imprimir   7
#define  K_ImpRec 	  8
#define  K_Copiar	  6
#define  K_Evolucao	  16
#define  K_IMPEVSA    17
#define	 K_OK		  1	

#define __aCdCri102 {"915",STR0270}//"Codigo EDI da critica nao encontrado"
#define __aCdCri107 {"910",STR0271}//"Processo de autorizacao On-Line (Cancelado)"
#define __aCdCri065 {"934",STR0274}//"Time out.Operadora fora do Ar."
#define __aCdCri158 {"087",STR0379}//"Bloqueio de pagamento e cobranÁa, evento n„o Autorizado."
#define __aCdCri187 {"573",STR0480}//"Demanda por requerimento"
#define __aCdCri145 {"083",STR0493}//"Item com quantidade maior que a solicitada"
#define __aCdCri09Z {"09Z",STR0615} //"Guia Juridica - Esta guia n„o ser· submetida aos critÈrios de validaÁ„o do sistema!"
#define __aCdCri197 {"09P",STR0616}//"Habilita checagem de regra para procedimentos incompatÌveis!"
#define __aCdCri09S {"09S",STR0530}//Quantidade de dias permitido para execuÁ„o da guia foi ultrapassado
#define __aCdCri228 {"986",STR0617}//"Erro na estrutura do arquivo PTU Online gerado."
#define __aCdCri229 {"587",STR0622}//"Usu·rio n„o tem premiss„o para solicitar Reembolso"
#define __aCdCri230 {"987",STR0624}//"N„o foi realizada nenhuma comunicaÁ„o com a operadora do benefici·rio"
#define __aCdCri240 {"5A1",STR0654}//"Este usu·rio somente poder· utilizar o plano conforme bloqueio prÈ-determinado."
#define __aCdCri025 {"025",STR0657}//"Para este procedimento necessita Auditoria."
#define __aCdCri241 {"588",STR0673}//"Token inv·lido."

/*/{Protheus.doc} PLSA090
Atendimento Sadt/Consulta ou Liberacao 

@author  PLS TEAM
@version P11
@since   16.04.00
/*/
Function PLSA090(cTipoRot)
LOCAL nI			:= 0
LOCAL nPos			:= 0
LOCAL cStrFil		:= ""
LOCAL cMVPLSRDAG 	:= GetNewPar("MV_PLSRDAG","999999")
LOCAL aCores		:= {}

private lImpGuiDir 	:= .F.
private oBrwBQV090	:= nil
private oBrwBQZ090	:= nil
private oBrwBE2Seq	:= nil
private aCabProcSq	:= {}
private aBlockLib   := {}
private nLibIni		:= 1
private lCopyGui	:= .F.
private aRotina   	:= MenuDef(cTipoRot,@aCores)
private cCadastro 	:= Fundesc()
private cCodLocSXB 	:= ""
private cCodIntSxb	:= ""
Private cHshLib		:= ""
Private oTempTTRB	:= nil

pergunte("PLA090",.F.)

lImpGuiDir := (mv_par01==1)

aCriCab := {{}}

PLClearHM(1)

//TISS 2.2 - Requisitos minimos È a existencia da tabela BRI e a existencia da funÁ„o PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. findFunction("PLSRETLDP") )
	Final("Necess·rio atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

PL090CarCr()

If !PLSALIASEXI("B0C") .and. GetNewPar("MV_PLNUMPR","0") == "1"
	Msgstop(STR0383)//"Parametro da procedure criado sem que o compatibilizador correspondente tenha sido executado.")
	return
Endif

__cTipo := cTipoRot

//Faz uma seria de tratamento para o cTipo 1 ou 2...                      
If ! __cTipo == "1" .and. ! __cTipo == "2"
	Help("",1,"PLSA090TIP")
	Return
Endif

//Se for liberacao trata a existencia da rda generica...                  
If __cTipo == "2" //Liberacao
	BAU->(DbSetOrder(1))
	If ! BAU->(MsSeek(xFilial("BAU")+cMVPLSRDAG))
		Aviso( STR0014, ; //"Rede de Atendimento Generica"
		STR0015,; //"Para a correta utilizacao desta rotina deve ser criada a Rede de Atendimento Generica para liberacoes e configurado o parametro MV_PLSRDAG."
		{ STR0146 }, 2 )
		Return
	Endif
Endif
DbSelectArea("BEA")
BEA->(DbSetOrder(1))
cFiltro := "@BEA_FILIAL = '" + xFilial("BEA") + "' and BEA_TIPO < '3' and BEA_ORIGEM = '" + __cTipo + "' "

If FindFunction("PlsRestOp")

	//retorna string com filtro para restricao do operador
	cStrFil := PlsRestOp("L",.f.)

	If !Empty(cStrFil)
		cFiltro += " .and. " + cStrFil
	EndIf
EndIf

//Filtro
If ExistBlock( "PL090FIL" )
	cFiltro := ExecBlock( "PL090FIL", .F., .F., {cFiltro} )
EndIf

//Busca dados do parametro...
If GetNewPar("MV_PLSMODA","1") == "0"
	If ! Pergunte("PLS090",.T.)
		Return
	Endif
	cCodLocPar := mv_par01
Endif
oBrwBEA := FWmBrowse():New()
oBrwBEA:SetAlias('BEA')
oBrwBEA:SetDescription( cCadastro )
oBrwBEA:SetFilterDefault( cFiltro )

//Inclui legenda
	if len(aCores)>0
		for nI:=1 to len(aCores)
			if ( nPos := aScan(aCdCores,{|x| x[1] == aCores[nI,2]}) ) > 0
				oBrwBEA:AddLegend( aCores[nI,1], aCores[nI,2], aCdCores[nPos,2] )
			endIf
		next
	endif

	oBrwBEA:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090Mov
Programa de Movimentacao da Autorizacao/Liberacao  

@author  PLS TEAM
@version P11
@since   19.06.00
/*/
//------------------------------------------------------------------- 
Function PLSA090Mov(cAlias,nReg,nOpc,cNil,aDadosPad,cTipoEsp,lVld,cBenef,cRda,cLoc,cEsp,aProc,lCons,cCid,cRegsol,cRegExe,cNumProTMK, cTipoRot,lSolWeb)
LOCAL I__f 		:= 0
LOCAL nFor		:= 0
LOCAL cChaveAC9 	:= NIL
LOCAL cMVPLSRDAG 	:= ""
LOCAL oDlg		:= nil
LOCAL nPos  		:= 0
LOCAL aCampos    	:= {}
LOCAL nOpcA     	:= 0
LOCAL cFaseGuia 	:= ""
LOCAL cSequen		:= ""
LOCAL nRegBEA   	:= Iif(BEA->(eof()),0,BEA->(Recno()))
LOCAL nOrdBEA   	:= BEA->(IndexOrd())
LOCAL aRetASE1  	:= {}
LOCAL aPosObj   	:= {}
LOCAL aObjects  	:= {}
LOCAL aSize     	:= {}
LOCAL aInfo     	:= {}
LOCAL aRetP		:= {}

//Uso na enchoiceBar...                     

LOCAL aButtons   	:= {}
LOCAL aRetorno   	:= {}
LOCAL bOK			:= {|| lConfirma:=.T.,nOpca := 1,If( PLSA090VLD(aRetorno,oEncAut:aGets,oEncAut:aTela,oBrwPro,oEncAut,nOpc,__cTipo,oBrwCri,nil,lNMudFase,aMatCom,cAlias,lAutoOnl,oGetBZC,cTrolComun,@aDadB6M),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.),Iif(FindFunction("PLSLIMSTA"),PLSLIMSTA(),NIL) }
LOCAL bCancel    	:= {|| lConfirma:=.F.,Iif( Type("BE1_COMUNI") == "C" .And. Type("BE1_MSG04") == "C" .And.;
Type("BE1_NRTROL") == "C" .And. Type("BE1_VIACAR") == "N" .And. M->BE1_COMUNI == "1" .And. GetNewPar("MV_PTGLOBO","1") == "1",;
If( PLSASOEEXE("BE1",lConf,,,,,,IIF((nOPC <> 2 .And. Type("BE1_CANCEL") == "C" .And. M->BE1_CANCEL <> "1"),PLSCANCCOM(),"")), oDlg:End() , .F. ) , oDlg:End() ),Iif(FindFunction("PLSLIMSTA"),PLSLIMSTA(),NIL) }
LOCAL oBotao		:= nil
LOCAL cSeqPF     	:= ""
LOCAL cSQL			:= ""

//Dados da gravacao dos itens...     
LOCAL cOpeMov	:= ''
LOCAL cAnoAut	:= ''
LOCAL cMesAut	:= ''
LOCAL cNumAut	:= ''
LOCAL cStrFil	:= ''

//GetDados Procedimentos...                                                

LOCAL aCabProc   := {}
LOCAL aDadProcBl := {}
LOCAL aDadProc   := {}
LOCAL aCabBQV    := {}
LOCAL aCabBQZ    := {}
LOCAL aDadBQV    := {}
LOCAL aDadBQZ    := {}
LOCAL aTrbProc   := {}
LOCAL aTrbBQV    := {}
LOCAL aTrbBQZ    := {}
LOCAL aArea		:= {}
LOCAL bFilter	 := nil
LOCAL oFontAutor := nil
LOCAL oFolder	 := nil

//Enchoice...                                                             
LOCAL oSay01	 := NIL
LOCAL oSay02	 := NIL
LOCAL oSay		 := NIL
LOCAL oDlgSay    := NIL
LOCAL aRetAux    := {.T.,{},ctod(""),"",""}
LOCAL nLinSoma   := 0

LOCAL aProcAbert := {}
LOCAL cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
LOCAL I			 := 0
LOCAL SlvInclui  := If(Type('inclui')=="L",Inclui,.T.)
LOCAL lValidVis  := .T.
LOCAL nX		 := 1
LOCAL cLiber     := BEA->BEA_STALIB
LOCAL nQtdPro    := 0
LOCAL nValComp   := 0
LOCAL cSenhaBEA	 := ""
LOCAL lEvoluSADT := GetNewPar("MV_PLEVSAD","0") == "1" .And. FunName() $ "PLSA094A,PLS790MOV" .And. nOpc <> K_Copiar
LOCAL cChGui
LOCAL nPosProtoc := 0
LOCAL lInterProt := .F.
LOCAL lEmptyProt := .F.
LOCAL lRn395     := GetNewPar("MV_PLRN395","0") == "1"

Local lPtuAnex   := .F.
Local lAutoOnl   := .F. 
Local cChavBZC   := ""
Local lNovInd    := GETNEWPAR("MV_PLSUNI","0") == "1" .And. PLSALIASEXI("BZC") .And. BZC->(FieldPos("BZC_CHVGUI")) > 0 .And. BZC->(FieldPos("BZC_ALIAS")) > 0 .And.  FindFunction('MSGCOMINT') 
Local cTrolComun := ""
Local lEvlSaBq   := .F. 
Local lPTUOn80	 := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80" .And. PLSALIASEXI("B6M") 
Local aDadB6M  	 := {}
//privates so existente devido a chamada da funcao EvalTrigger...          

PRIVATE aMatCBkp		:={}
PRIVATE aGets 		:= {}
PRIVATE aTela 		:= {}
PRIVATE lConf 		:= .T.
PRIVATE lComunica  	:= .T.
PRIVATE lBtnOn     	:= .F.
PRIVATE lNMudFase 	:= Getnewpar("MV_PLMFSA",'1') == '0'
PRIVATE cSituacPTU  := ""
PRIVATE cNumProto   := Space(20)
PRIVATE oGetBZC	    := nil
Private cNrProWeb   := Space(20)
Private aRdaPt      := {}
Private aCriPacote  := {} 

Default lVld 		:= .F.
Default cBenef 		:= ""
Default cRda 		:= ""
Default cLoc 		:= ""
Default cEsp 		:= ""
Default aProc 		:= {}
Default lCons		:= .F.
Default cCid    	:= ""
Default cRegsol		:= ""
Default cRegExe		:= ""
Default cNumProTMK 	:= ""
Default cTipoRot    := ""  
Default lSolWeb     := .F.  

_aCopHCri 	:= {}
aMatIte 	:= {}

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
objCENFUNLGP:useLogUser()
	
//  Necessaria a alteraÁ„o da variavel private para chamada da rotina
If PLSALIASEXI("BKU") .And. !Empty(BKU->BKU_NRPRO) .And. cTipoRot == "2" .And. lSolWeb
	cCadastro := "LiberaÁ„o SADT" // incluir a constante no ATUSX
	cNrProWeb := BKU->BKU_NRPRO
EndIf

//Verifica se a Guia esta em an·lise antes da exclus„o
If nOpc == K_Excluir .and. PLSALIASEX("B53")
	If !PLSA092VL2(cAlias)
		Return
	EndIf
EndIf

If nOpc == K_Incluir
	Inclui := .T.
Endif

If !Empty(cRda)
	lInfRda := .T.
EndIf

//Verifica se ja foi definido um numero de protocolo no atendimento call center
If ! Empty(cNumProTMK)
	cNumProto := cNumProTMK
EndIf

//Reinicializa objeto de Evolucao SADT    								

oBrwBQV090	:= {}
oBrwPro    	:= {}
oBrwCri 	:= {}
aAutFor    	:= {}
aDadCri    	:= {}
aCabCri    	:= {}
aTrbCri    	:= {}
acabdf		:= {}
adaddf 	    := {}
atrbdf 		:= {}

//Evolucao SADT somente para guais de Servico

If K_Evolucao == nOpc .And. BEA->BEA_TIPGUI <> "02"
	Aviso( STR0120,STR0491,{ STR0146 }, 2 ) //"Atencao" //"EvoluÁ„o permitida somente para Guias de ServiÁo" //"Ok"
	Return
EndIf

If nOpc == K_VisOnline

	lAutoOnl := .T. 
	
EndIf

//Validacao de preenchimento do protocolo de atendimento RN 395
If lRn395 .And. K_Evolucao == nOpc .And. Dtos(BEA->BEA_DATPRO) >= '20160515'
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Verifica se o protocolo de atendimento foi gerado/informado	 		     ≥       
	//≥ Nao verifico se nao for guia remote ou guia de intercambio     	     	 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aDadUsr := PLSDADUSR(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),"1",.F.,dDataBase)

	If aDadUsr[45] == PlsIntPad() .And. BEA->BEA_TPGRV == "1"

		If Empty(BEA->BEA_PROATE) 
			lEmptyProt := .T.
		Else	
			BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
			If BQV->(DbSeek(xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ))
				While xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .And. !BQV->(Eof())
					If Empty(BQV->BQV_PROATE)
						lEmptyProt := .T.
						Exit
					EndIf
					BQV->(DbSkip())
				EndDo
			EndIf                
		EndIf
	EndIf

	If lEmptyProt == .T. 
		Aviso( STR0120,STR0575,{ STR0146 }, 2 ) //"Atencao" //"EvoluÁ„o permitida somente para Guias de ServiÁo" //"Ok" ## "… necess·rio informar os protocolos pendentes antes de realizar a evoluÁ„o do atendimento."
		Return
	EndIf	
EndIf

//Verifica se e guia solicitada pelo Ptu Online

If nOpc == K_Excluir

	//Se for online nao deixa cancelar por aqui
	if BEA->( FieldPos("BEA_NRTROL") ) > 0 .and. !empty(BEA->BEA_NRTROL) .And. BEA->BEA_OPESOL <> PlsIntPad()
		Aviso( STR0120, STR0278 , {  STR0146  }, 2 ) //"Guia On-Line, n„o e possÌvel fazer este tipo de cancelamento!"
		Return
	EndIf

EndIf

//Verifica se a tabela BQZ ja existe															  
If !PLSALIASEX("BQZ")
	Aviso(	STR0120,; 				//"Atencao"
	STR0272 + "BQZ",; 		//"Tabela nao existe no SX2 -> "
	{ STR0146 }, 2 ) 		//"ok"
	If nOpc == K_Incluir
		Inclui := SlvInclui
	Endif
	Return
EndIf

aAutFor := {}
aDadB43 := {}
aCabB43 := {}
aTrbB43 := {}

//Mudar o nOpc da funcao PLSA090Mov para visual (erro Array out Of Bound no DuploClick do Brows 
If lAutoOnl

	lBtnOn 		:= .T.
	cNumProto 	:= BEA->BEA_PROATE

	If (Empty(BEA->BEA_MATANT) .Or. SubStr(BEA->BEA_MATANT,atCodOpe[1],atCodOpe[2]) == PLSINTPAD()) .And. Empty(BEA->BEA_NRTROL)  

		BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
		If BAU->(DbSeek(xFilial("BAU")+BEA->BEA_CODRDA)) .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
			B4A->(DbSetOrder(4))//B4A_FILIAL+B4A_GUIREF
			If B4A->(DbSeek(xFilial("B4A")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))) 
				lPtuAnex := .T.	
			EndIf
		Endif

		If !lPtuAnex
			Aviso(	STR0054,; //"AtenÁ„o"
			STR0408,; //"Benefici·rio da operadora local, impossÌvel fazer solicitaÁ„o on-line!"
			{STR0146},1)//"Ok"
			Return 
		EndIf	
	EndIf

	//Se veio da internacao																		 
	If BEA->BEA_TIPGUI == "03"
		Aviso( STR0120, ; //"Atencao"
		STR0275,; //"Guia originada na internacao, impossivel fazer solicitacao on-line!"
		{ STR0146 }, 2 )//"Ok"
		If nOpc == K_Incluir
			Inclui := SlvInclui
		Endif
		Return
	EndIf     
	
	If BEA->BEA_TIPGUI == "02" .And. lEvoluSadt .And. BEA->BEA_COMUNI == "1" 
		BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
		If BQV->(DbSeek(xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ))
			While xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .And. !BQV->(Eof())
				If BQV->BQV_COMUNI == "0"
					lEvlSaBq := .t.
					Exit
				EndIf
				BQV->(DbSkip())
			EndDo
		EndIf 		
	EndIf  
	If !lEvlSaBq
		nOpc := K_Alterar
	Else
	    nOpc := K_Evolucao
	EndIf	
Else
	lBtnOn := .F.
EndIf

//Se veio da internacao																		  

If nOpc == K_Excluir .And. BEA->BEA_TIPGUI == "03"
	Aviso( STR0120, ; //"Atencao"
	STR0276,; //"Guia originada na internacao, impossivel fazer exclusao!"
	{ STR0146 }, 2 )//"Ok"
	If nOpc == K_Incluir
		Inclui := SlvInclui
	Endif
	Return
EndIf

//Se e uma liberacao fechada nao pode ser excluida                                              
If nOpc == K_Excluir .And. BEA->BEA_ORIGEM == "2" .And. BEA->BEA_STALIB == "2"
	Aviso( 	STR0120, ; //"Atencao"
	STR0363,; //"Para esta liberaÁ„o foi gerada autorizaÁıes, portanto n„o poder· ser excluÌda."
	{ STR0146 }, 2 )//"Ok"
	Return
EndIf

//Se existe complemento de SADT pendente nao permite a exclusao                                 
If nOpc == K_Excluir .And. BEA->BEA_COMUNI == "1" .And. GetNewPar("MV_PLEVSAD","0") == "1"
	DbSelectArea("BQV")
	DbSetOrder(1)//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
	If BQV->(DbSeek(xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
		Alert(STR0492)//"N„o È possÌvel cancelar a Guia, pois existem complementos pendentes"
		Return
	EndIf
EndIf

//Se e uma liberacao em aberto que ja tenha sido gerado pelo menos uma autorizacao nao pode excluir
If nOpc == K_Excluir .And. BEA->BEA_ORIGEM == "2" .And. BEA->BEA_STALIB == "1"
	cSQL := "SELECT BEA_FILIAL FROM "+BEA->(RetSQLName("BEA"))+" WHERE "
	cSQL += "BEA_FILIAL = '"+xFilial("BEA")+"' AND "
	cSQL += "BEA_NRLBOR = '"+cChave+"' AND "
	cSQL += "D_E_L_E_T_ = ' '"
	PLSQuery(cSQL,"TrbBEA")

	If ! TrbBEA->(Eof())
		Aviso( STR0120, ; //"Atencao"
		STR0363,; //"Para esta liberaÁ„o foi gerada autorizaÁıes, portanto n„o poder· ser excluÌda."
		{ STR0146 }, 2 )//"Ok"
		TrbBEA->(DbCloseArea())
		Return
	Else
		TrbBEA->(DbCloseArea())
	EndIf
EndIf

//Se ja esta concluido nao deixa acessar
If Type("BEA_TRACON") == "C" .And. BEA->BEA_COMUNI == "1" .And. lBtnOn .And. !lEvlSaBq  //BEA->BEA_TRACON == "1"
	Aviso( STR0120, ; //"Atencao"
	STR0279,; //"Transacao concluida nao e possivel fazer solicitacao on-line!"
	{ STR0146 }, 2 )//"Ok"
	If nOpc == K_Incluir
		Inclui := SlvInclui
	Endif
	Return
EndIf

//Define fontes utilizadas somente nesta funcao...                        
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-012 BOLD

DEFAULT aDadosPad := {}
DEFAULT cTipoEsp  := ""

if !empty(cTipoEsp)
	__cTipo := cTipoEsp
endIf

If nOpc == K_Incluir
	Inclui := SlvInclui
Endif

If __cTipo == "1"
	__cDescri := STR0017 //"Autorizacao"
	cCadastro :=STR0017
	If FunName() == "TMKA271"
		aCampos   := {}
		STORE FIELD "BE1" TO aCampos For ! (SX3->X3_CAMPO $ "BE1_FILIAL,BE1_TIPCON,BE1_TIPDOE,BE1_TPODOE,BE1_UTPDOE,BE1_INDACI,BE1_LOTGUI,BE1_GRAUPA") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
		If BEA->BEA_TIPO == "4"
			cCadastro := STR0544 //"Autorizacao S.a.d.t. / Odontologico"
		EndIf
	Else
		aCampos   := nil //todos os campos devem aparecer
	Endif
ElseIf __cTipo == "2"
	__cDescri := STR0018 //"Liberacao"
	aCampos   := {}
	If FunName() == "TMKA271"
		cCadastro:= STR0018
	Endif
	STORE FIELD "BE1" TO aCampos For ! (SX3->X3_CAMPO $ "BE1_FILIAL,BE1_TIPCON,BE1_TIPDOE,BE1_TPODOE,BE1_UTPDOE,BE1_NUMLIB,BE1_LOTGUI,BE1_GRAUPA") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
Else
	Help("",1,"PLSA090TIP")
	If nOpc == K_Incluir
		Inclui := SlvInclui
	Endif
	Return
Endif

//Se for exclusao testa se pode ser excluida (no caso de exclusao)        
If nOpc == K_Excluir

	If ExistBlock("PLS090EX")
		If ! ExecBlock("PLS090EX",.F.,.F.)
			If nOpc == K_Incluir
				Inclui := SlvInclui
			Endif
			Return
		Endif
	Endif

	//Se foi comprada e paga no ato...                                        

	If BEA->BEA_GUIACO == "1" .And. BEA->BEA_QUACOB == "1"

		SE1->(DbSetOrder(1))

		If lBEANTit
			cChvSE1 := BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)
		Else
			cChvSE1 := BEA->BEA_CHVSE1
		Endif

		If SE1->(MsSeek(xFilial("SE1")+cChvSE1))

			//Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada..
			aRetASE1 := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

			//[1] - Calendario contabil (.T./.F.)
			//[2] - Movimentado (.T./.F.)
			
			if aRetASE1[1] .and. aRetASE1[2]

				aviso( 	STR0019, ; 	//"Guia Comprada"
						STR0020,; 	//"Esta guia foi comprada e paga no ato, e o respectivo titulo a receber ja sofreu baixa. Voce deve cancelar a baixa para consegui excluir a guia."
						{ STR0146 }, 2 )
			
				If nOpc == K_Incluir
					Inclui := SlvInclui
				Endif

				return

			else
				
				//exclui titulos ou nota				
				if ! P629ExcE1()
					disarmTransaction()
					return
				endIf

			endIf

		Endif
		
	Endif

	//Verifica se a guia foi cobrada (custo, VD, Co-Participacao, Etc)        

	BCI->(DbSetOrder(1))
	If BCI->(MsSeek(xFilial("BCI")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG)))
		If BCI->BCI_TIPGUI $ "01,02,13"
			BD5->(DbSetOrder(1))
			If BD5->(MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
				cSeqPF := BD5->BD5_SEQPF
				cFaseGuia := BD5->BD5_FASE
			Endif
		Else
			BE4->(DbSetOrder(1)) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
			If BE4->(MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
				cSeqPF 		:= BE4->BE4_SEQPF
				cFaseGuia 	:= BE4->BE4_FASE
			Endif
		Endif
	Endif

	If ! Empty(cSeqPF)
		If PLSVERCCBG(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),BEA->BEA_ANOPAG,BEA->BEA_MESPAG,cSeqPF)
			Aviso(STR0021,STR0022,{STR0146},2) //"Guia Cobrada"###"Ja gerada a cobranca de custo operacional/co-participacao portanto nao podera ser excluida"
			If nOpc == K_Incluir
				Inclui := SlvInclui
			Endif
			Return
		Endif
	Endif
	If cFaseGuia == "4"
		Aviso(STR0023,STR0024,{STR0146},2)    //"Guia Paga"###"Guia ja paga portanto nao podera ser excluida"
		If nOpc == K_Incluir
			Inclui := SlvInclui
		Endif
		Return
	Endif
Endif

//Monta aHeader e aCols Procedimentos...                                  
aCabProc	:= PLSA090Hea(__cTipo,NIL,nOpc)
aDadProcBl	:= PLSA090ClB(aCabProc)

//Busca dado do parametro...                                              

Pergunte("PLS090",.F.)
cCodLocPar := mv_par01
aCriCab := {{}}
//Monta dados do GetDados procedimentos...                                

If nOpc == K_Copiar

	If cLiber == "2"
		Aviso(STR0410,STR0411,{STR0146},2)//"Copia n„o autorizada","Esta LiberaÁ„o encontra-se fechada e n„o pode ser copiada!",{"OK"}
		Return
	EndIf
	__lAutoriz := .F.

	Inclui := .F.

	Copy "BE1" TO Memory

	Inclui := .T.

	cOpeMov    := BEA->BEA_OPEMOV
	cAnoAut    := BEA->BEA_ANOAUT
	cMesAut    := BEA->BEA_MESAUT
	cNumAut    := BEA->BEA_NUMAUT
	cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

	If ! PLSA090MDa(cChave,"1",aCabProc,aTrbProc,aDadProc)
		If nOpc == K_Incluir
			Inclui := SlvInclui
		Endif
		Return
	EndIf

	PLSA090USR(M->BE1_USUARI,M->BE1_DATPRO,M->BE1_HORPRO,"BE1")

	PLSA090RDA(BEA->BEA_OPERDA,BEA->BEA_CODRDA,"1",BEA->BEA_DATPRO,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),BEA->(BEA_CODLOC+BEA_LOCAL),BEA->BEA_CODESP,"BE1",.F.)

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Valida calendario pagto...                                               ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aRetAux := PLS746CAL(BEA->BEA_OPEMOV,BEA->BEA_ANOPAG,BEA->BEA_MESPAG)

	nPos1 := PLRETPOS("BE2_IMGSTA",aCabProc)
	nPos2 := PLRETPOS("BE2_STATUS",aCabProc)

	For nFor := 1 To Len(aDadProc)
		aDadProc[nFor,nPos1] := If(aDadProc[nFor,nPos2]=="1","ENABLE","DISABLE")
	Next

	//Monta as criticas relacionadas ao procedimento...                       

	Store Header "BEG" TO aCabCri For .T.

	BEG->(DbSetOrder(1))
	If ! BEG->(MsSeek(xFilial("BEG")+cChave))
		Store COLS Blank "BEG" TO aDadCri FROM aCabCri
	Else
		Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial("BEG")+cChave == BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
	Endif

	If PLSALIASEXI("B43")
		Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
		B43->(DbSetOrder(2))
		If B43->(MsSeek(xFilial("B43")+cChave))
			Store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT) == xFilial("B43")+cChave
		Else
			Store COLS Blank "B43" TO aDadB43 FROM aCabB43
		EndIf
	EndIf

	//Monta os Dentes/Faces relacionados ao procedimento...                   

	If FindFunction('PGetTisVer') .and. PGetTisVer() >= '3' .and. PLSALIASEXI("B4B")
		Store Header "B4B" TO aCabDF For .T.
		B4B->(DbSetOrder(1))
		If ! B4B->(MsSeek(xFilial("B4B")+cChave))
			Store COLS Blank "B4B" TO aDadDF FROM aCabDF
		Else
			Store COLS "B4B" TO aDadDF FROM aCabDF VETTRAB aTrbDF While ;
			xFilial("B4B")+cChave == B4B->(B4B_FILIAL+B4B_OPEMOV+B4B_ANOAUT+B4B_MESAUT+B4B_NUMAUT)
		EndIf
	Endif


ElseIf nOpc <> K_Incluir .And. nOpc <> K_Copiar
	RegToMemory("BE1",.F.,.F.)

	cOpeMov    := BEA->BEA_OPEMOV
	cAnoAut    := BEA->BEA_ANOAUT
	cMesAut    := BEA->BEA_MESAUT
	cNumAut    := BEA->BEA_NUMAUT
	cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	cSenhaBEA  := BEA->BEA_SENHA

	If nOpc == K_Visualizar .And. BEA->(FieldPos("BEA_NRLBOR"))>0
		M->BE1_NUMLIB := BEA->BEA_NRLBOR
	EndIf

	If ! PLSA090MDa(cChave,"1",aCabProc,aTrbProc,aDadProc,nOpc == K_Visualizar)
		If nOpc == K_Incluir
			Inclui := SlvInclui
		Endif
		Return
	Endif

	//Para Nao ser Visualizadas as Criticas
	If nOpc == K_Visualizar  .Or.  nOpc == K_Excluir
		lValidVis := .F.
	Endif

	PLSA090USR(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),BEA->BEA_DATPRO,BEA->BEA_HORPRO,;
	"BE1",.F.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,lValidVis,Iif((nOpc == K_Incluir .Or. nOpc == K_Copiar),.T.,.F.))

	If nOpc <> K_Visualizar .And. nOpc <> K_Excluir

		PLSA090RDA(BEA->BEA_OPERDA,BEA->BEA_CODRDA,"1",BEA->BEA_DATPRO,;
		BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),;
		BEA->(BEA_CODLOC+BEA_LOCAL),BEA->BEA_CODESP,"BE1",.F.)
	EndIf

	BDS->(DbSetOrder(1))
	If FunName() == "PLSA09A" .And. Type("aAutForAnx") <> "U"
		If BDS->(MsSeek(xFilial("BDS")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)+SubStr(B4A->B4A_TIPGUI,Len(B4A->B4A_TIPGUI))))
			While ! BDS->(Eof()) .And. BDS->(BDS_FILIAL+BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM) == ;
			xFilial("BDS")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)+SubStr(B4A->B4A_TIPGUI,Len(B4A->B4A_TIPGUI))

				AaDd(aAutForAnx,{.F.,BDS->BDS_CODPAD,BDS->BDS_CODPRO,BDS->BDS_OPEMOV,BDS->BDS_ANOAUT,BDS->BDS_MESAUT,;
				BDS->BDS_NUMAUT,BDS->(Recno()),BDS->BDS_OPESIS,BDS->BDS_DATA,BDS->BDS_HORA,,,Iif( BDS->(FieldPos("BDS_SEQUEN")) > 0,BDS->BDS_SEQUEN,"001")})
				BDS->(DbSkip())
			Enddo
		Endif
	ElseIf BDS->(MsSeek(xFilial("BDS")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+"1")))
		While ! BDS->(Eof()) .And. BDS->(BDS_FILIAL+BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM) == ;
		xFilial("BDS")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+"1")

			AaDd(aAutFor,{.F.,BDS->BDS_CODPAD,BDS->BDS_CODPRO,BDS->BDS_OPEMOV,BDS->BDS_ANOAUT,BDS->BDS_MESAUT,;
			BDS->BDS_NUMAUT,BDS->(Recno()),BDS->BDS_OPESIS,BDS->BDS_DATA,BDS->BDS_HORA,,,Iif( BDS->(FieldPos("BDS_SEQUEN")) > 0,BDS->BDS_SEQUEN,"001")})
			BDS->(DbSkip())
		Enddo
	ElseIf	FunName() == "PLSA094A" .And. BDS->(MsSeek(xFilial("BDS")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+"2")))
		While ! BDS->(Eof()) .And. BDS->(BDS_FILIAL+BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM) == ;
		xFilial("BDS")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+"2")

			AaDd(aAutFor,{.F.,BDS->BDS_CODPAD,BDS->BDS_CODPRO,BDS->BDS_OPEMOV,BDS->BDS_ANOAUT,BDS->BDS_MESAUT,;
			BDS->BDS_NUMAUT,BDS->(Recno()),BDS->BDS_OPESIS,BDS->BDS_DATA,BDS->BDS_HORA,,,Iif( BDS->(FieldPos("BDS_SEQUEN")) > 0,BDS->BDS_SEQUEN,"001")})
			BDS->(DbSkip())
		Enddo
	Endif
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Valida calendario pagto...                                               ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aRetAux := PLS746CAL(BEA->BEA_OPEMOV,BEA->BEA_ANOPAG,BEA->BEA_MESPAG)

	nPos1 := PLRETPOS("BE2_IMGSTA",aCabProc)
	nPos2 := PLRETPOS("BE2_STATUS",aCabProc)

	For nFor := 1 To Len(aDadProc)
		aDadProc[nFor,nPos1] := If(aDadProc[nFor,nPos2]=="1","ENABLE","DISABLE")
	Next

	//Monta as criticas relacionadas ao procedimento...                       
	BEG->(DbCloseArea())
	Store Header "BEG" TO aCabCri For .T.

	BEG->(DbSetOrder(1))
	If ! BEG->(MsSeek(xFilial("BEG")+cChave))
		Store COLS Blank "BEG" TO aDadCri FROM aCabCri
	Else
		Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial("BEG")+cChave == BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
	Endif

	If PLSALIASEXI("B43")
		Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
		B43->(DbSetOrder(2))
		If B43->(MsSeek(xFilial("B43")+cChave))
			Store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT) == xFilial("B43")+cChave
		Else
			Store COLS Blank "B43" TO aDadB43 FROM aCabB43
		Endif
	Endif

	//Monta os Dentes/Faces relacionados ao procedimento...                   

	If FindFunction('PGetTisVer') .and. PGetTisVer() >= '3' .and. PLSALIASEXI("B4B")
		Store Header "B4B" TO aCabDF For .T.
		B4B->(DbSetOrder(1))
		If ! B4B->(MsSeek(xFilial("B4B")+cChave))
			Store COLS Blank "B4B" TO aDadDF FROM aCabDF
		Else
			Store COLS "B4B" TO aDadDF FROM aCabDF VETTRAB aTrbDF While ;
			xFilial("B4B")+cChave == B4B->(B4B_FILIAL+B4B_OPEMOV+B4B_ANOAUT+B4B_MESAUT+B4B_NUMAUT)
		EndIf
	Endif

	//Monta evolucao												    	   

	If lEvoluSADT
		oBrwBE2Seq := aClone(aDadProc)
		aCabProcSq := aClone(aCabProc)
		Store Header "BQV" TO aCabBQV For .T.
		BQV->(DbSetOrder(1))
		If !BQV->( MsSeek( xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
			Store COLS Blank "BQV" TO aDadBQV FROM aCabBQV
		Else
			Store COLS "BQV" TO aDadBQV FROM aCabBQV VETTRAB aTrbBQV While BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == ;
			xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
		Endif

		Store Header "BQZ" TO aCabBQZ For .T.
		BQZ->(DbSetOrder(1))
		If !BQZ->( MsSeek( xFilial("BQZ")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
			Store COLS Blank "BQZ" TO aDadBQZ FROM aCabBQZ
		Else
			Store COLS "BQZ" TO aDadBQZ FROM aCabBQZ VETTRAB aTrbBQZ While BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT) == ;
			xFilial("BQZ")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
		Endif
	EndIf

ElseIf nOpc == K_Incluir
	__lAutoriz := .F.

	//Abre a tabela														

	If Select("BEG") == 0
		aArea := GetArea()
		DbSelectArea("BEG")
		RestArea(aArea)
	EndIf

	//Monta aHeader e aCols Procedimentos...                                  

	aDadProc := aClone(aDadProcBl)

	//Valida calendario pagto...                                              

	aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

	If ! aRetAux[1]
		If nOpc == K_Incluir
			Inclui := SlvInclui
		Endif
		Return
	Endif

	If FindFunction('PGetTisVer') .and. PGetTisVer() >= '3' .and. PlsAliasExi('B4B')
		Store Header 'B4B' TO aCabDF For .T.
		Store COLS Blank 'B4B' TO aDadDF FROM aCabDF
	Endif

	Store Header "BEG" TO aCabCri For .T.
	Store COLS Blank "BEG" TO aDadCri FROM aCabCri

	Copy "BE1" TO Memory Blank

	If !Empty(AllTrim(cBenef))

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE1_USUARI"))

		M->BE1_USUARI := cBenef

		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
			RunTrigger(1)
		Endif

		If FunName() == "TMKA271"
			DbSelectArea("BA1")
			DbSetOrder(2)
			DbSeek(xFilial("BA1") + cBenef)
			If dDataBase > BA1->BA1_DATBLO .And. !Empty(BA1->BA1_DATBLO)
				Return(.F.)
			Endif
		Endif
		If lRn395 .And. !Empty(cNumProto)
			M->BE1_PROATE := cNumProto
		EndIf
	EndIf

	//Preenchimento do Protocolo caso haja uma solicitaÁ„o de autorizaÁ„o p um beneficiario via Portal.
	If ValType(cNrProWeb) != "U" .and. !Empty(cNrProWeb)
		M->BE1_PROATE := cNrProWeb
	EndIf 
	

	If __cTipo == "2" .or. !Empty(cRda)

		cMVPLSRDAG := Iif(!Empty(cRda),cRda,GetNewPar("MV_PLSRDAG","999999"))
		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE1_CODRDA"))

		M->BE1_CODRDA := cMVPLSRDAG
		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
			RunTrigger(1)
		EndIf

	Endif

	If !Empty(cLoc)

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE1_CODLOC"))

		M->BE1_CODLOC := cLoc

		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
			RunTrigger(1)
		Endif

	EndIf

	If !Empty(cEsp)

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE1_CODESP"))

		M->BE1_CODESP := cEsp

		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
			RunTrigger(1)
		Endif

	Endif

	If !Empty(cCid)

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE1_CID"))

		M->BE1_CID := cCid

		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
			RunTrigger(1)
		Endif

	Endif

	If !Empty(cRegSol)

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE1_REGSOL"))

		M->BE1_REGSOL := cRegSol

		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
			RunTrigger(1)
		Endif

	Endif

	If !Empty(cRegExe)

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE1_REGEXE"))

		M->BE1_REGEXE := cRegExe

		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
			RunTrigger(1)
		Endif

	Endif

	If PLSALIASEXI("B43")
		Store Header "B43" TO aCabB43 For ( AllTrim(SX3->X3_CAMPO) $ PRetHeaPac() )
		Store COLS Blank "B43" TO aDadB43 FROM aCabB43
	EndIf
EndIf

aSize := MsAdvSize()
AAdd( aObjects, { 001, Iif(GetNewPar("MV_PLSMODA","1") == "0",020,Iif((nOpc == K_Incluir .Or. nOpc == K_Copiar),000,020)), .T., .F.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.T. } )

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj[1][2]+=15
aPosObj[2][2]+=15
aPosObj[3][2]+=15
aPosObj[3][3]-=15

//Cria Dialog...                                                          

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

//Cria Enchoice... 

oEncAut := BE1->(MSMGet():New("BE1",BE1->(Recno()),nOpc,,,,aCampos,aPosObj[2],aCampos,,,,,oDlg,,IIF(nOpc == K_Incluir,.T.,),.F.))

If VerSis() >= 8
	nLinSoma := 15
	oDlgSay  := oDlg
Else
	nLinSoma := 0
	oDlgSay  := oEncAut:oBox
EndIf

If nOpc == K_Copiar

	If FunName() == 'PLSA094B' //Liberacao
		M->BE1_USUARI := Space(TamSx3("BE1_USUARI")[1])
		M->BE1_NOMUSR := Space(TamSx3("BE1_NOMUSR")[1])
		M->BE1_TIPUSR := Space(TamSx3("BE1_TIPUSR")[1])
		M->BE1_MATANT := Space(TamSx3("BE1_MATANT")[1])
		M->BE1_MATUSA := Space(TamSx3("BE1_MATUSA")[1])
	ElseIf FunName() == 'PLSA094A' //Autorizacao SADT
		M->BE1_USUARI := Space(TamSx3("BE1_USUARI")[1])
		M->BE1_NOMUSR := Space(TamSx3("BE1_NOMUSR")[1])
		M->BE1_TIPUSR := Space(TamSx3("BE1_TIPUSR")[1])
		M->BE1_MATANT := Space(TamSx3("BE1_MATANT")[1])
		M->BE1_MATUSA := Space(TamSx3("BE1_MATUSA")[1])
		M->BE1_CODRDA := Space(TamSx3("BE1_CODRDA")[1])
		M->BE1_NOMRDA := Space(TamSx3("BE1_NOMRDA")[1])
		M->BE1_TIPPRE := Space(TamSx3("BE1_TIPPRE")[1])
		M->BE1_CODLOC := Space(TamSx3("BE1_CODLOC")[1])
		M->BE1_DESLOC := Space(TamSx3("BE1_DESLOC")[1])
		M->BE1_ENDLOC := Space(TamSx3("BE1_ENDLOC")[1])
		M->BE1_CODESP := Space(TamSx3("BE1_CODESP")[1])
		M->BE1_DESESP := Space(TamSx3("BE1_DESESP")[1])
	EndIf

EndIf

If nOpc == K_Incluir .Or. nOpc == K_Copiar

	If nOpc == K_Incluir
		M->BE1_MESPAG := aRetAux[5]
		M->BE1_ANOPAG := aRetAux[4]
		if __cTipo == "2" .or. !Empty(cRda)
			M->BE1_CODRDA := cMVPLSRDAG
			if !Empty(M->BE1_CODRDA)
				PLSA090RDA(M->BE1_OPERDA,M->BE1_CODRDA,"1",M->BE1_DATPRO,M->BE1_USUARI,;
                   "","","BE1",,,,,,__ctipo,oBrwPro,oBrwCri)
			endif
		endif

	Else
		M->BE1_MESPAG := AllTrim(StrZero(Month(dDataBase),2))
		M->BE1_ANOPAG := AllTrim(Str(Year(dDataBase)))
	EndIf

	If Len(aDadosPad) > 0

		//Trata campos padroes...                                                 

		//Sigla
		nPos := Ascan(aDadosPad,{ |x| x[1] == "SIGLA"})
		If nPos > 0
			M->BE1_SIGLA := aDadosPad[nPos,2]
		Endif

		//Estado
		nPos := Ascan(aDadosPad,{ |x| x[1] == "ESTSOL"})
		If nPos > 0
			M->BE1_ESTSOL := aDadosPad[nPos,2]
		Endif

		//OpeSol
		nPos := Ascan(aDadosPad,{ |x| x[1] == "OPESOL"})
		If nPos > 0
			M->BE1_OPESOL := aDadosPad[nPos,2]
		Endif

		//Numero do Conselho Regional do Solicitante
		nPos := Ascan(aDadosPad,{ |x| x[1] == "REGSOL"})
		If nPos > 0
			M->BE1_REGSOL := aDadosPad[nPos,2]
			M->BE1_NOMSOL := Posicione("BB0",4,xFilial("BB0")+M->BE1_ESTSOL+M->BE1_REGSOL+M->BE1_SIGLA+M->BE1_OPESOL,"BB0_NOME")
		Endif

		//Matricula do usuario...
		nPos := Ascan(aDadosPad,{ |x| x[1] == "USUARIO"})
		If nPos > 0
			M->BE1_USUARI := aDadosPad[nPos,2]
			If PLSA090USR(M->BE1_USUARI,M->BE1_DATPRO,M->BE1_HORPRO,"BE1")
				M->BE1_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
			Else
				If nOpc == K_Incluir
					Inclui := SlvInclui
				Endif
				Return
			Endif
		Endif

		//Numero de controle do encaminhamento (marcaca de consulta Recepcao)
		nPos := Ascan(aDadosPad,{ |x| x[1] == "NUMATE"})
		If nPos > 0
			M->BE1_NUMATE := aDadosPad[nPos,2]
		Endif
		lRefresh := .T.

	Endif
Endif

//Exibe Label.                                                            

If nOpc <> K_Incluir .Or. GetNewPar("MV_PLSMODA","1") == "0"
	@ aPosObj[1,1], aPosObj[1,2] GROUP oGrupo TO aPosObj[1,3], aPosObj[1,4] PIXEL OF oDlg LABEL " "+STR0273+" "  COLOR CLR_HBLUE, CLR_HRED //"Informacoes"

	If nOpc <> K_Incluir .and. !Empty(cSenhaBEA)
		@ aPosObj[1,1]+6,aPosObj[1,2]+150  Say oSay PROMPT "Senha "  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor
		@ aPosObj[1,1]+6,aPosObj[1,2]+233  Say oSay PROMPT cSenhaBEA  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
	Endif
EndIf


//Exibe say...                                                            

If nOpc <> K_Incluir .And. nOpc <> K_Copiar
	If __cTipo == "1"
		@ aPosObj[1,1]+6,aPosObj[1,2]+5  Say oSay PROMPT STR0361  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"AutorizaÁ„o N˙mero"
	Else
		@ aPosObj[1,1]+6,aPosObj[1,2]+5  Say oSay PROMPT STR0362  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"LiberaÁ„o N˙mero"
	Endif
	@ aPosObj[1,1]+6,aPosObj[1,2]+70 Say oSay PROMPT TransForm(M->BE1_NUMAUT,PesqPict("BE1","BE1_NUMAUT"))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
Endif

If GetNewPar("MV_PLSMODA","1") == "0"
	If nOpc == K_Incluir
		@ aPosObj[1,1]+6,aPosObj[1,2]+5  Say oSay PROMPT STR0026  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"Local de Atendimento "
		@ aPosObj[1,1]+6,aPosObj[1,2]+75 Say oSay PROMPT Eval({ || cCodLocPar+" - "+AllTrim(BD1->(Posicione("BD1",1,xFilial("BD1")+PLSINTPAD()+cCodLocPar,"BD1_DESLOC")))  })  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
	Else
		If Empty(cSenhaBEA)
			@ aPosObj[1,1]+6,aPosObj[1,2]+180 Say oSay PROMPT STR0026  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"Local de Atendimento "
			@ aPosObj[1,1]+6,aPosObj[1,2]+247 Say oSay PROMPT Eval({ || cCodLocPar+" - "+AllTrim(BD1->(Posicione("BD1",1,xFilial("BD1")+PLSINTPAD()+cCodLocPar,"BD1_DESLOC")))  })  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
		Else
			@ aPosObj[1,1]+6,aPosObj[1,2]+250 Say oSay PROMPT STR0026  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"Local de Atendimento "
			@ aPosObj[1,1]+6,aPosObj[1,2]+283 Say oSay PROMPT Eval({ || cCodLocPar+" - "+AllTrim(BD1->(Posicione("BD1",1,xFilial("BD1")+PLSINTPAD()+cCodLocPar,"BD1_DESLOC")))  })  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
		Endif
	EndIf
Endif


//Zera o campo BE2_QTDPRO quando escolhida a opcao de Copiar.             

If nOpc == K_Copiar
	nQtdSol  := Ascan(aCabProc,{|x| AllTrim(x[2]) == "BE2_QTDSOL"})
	nQtdPro  := Ascan(aCabProc,{|x| AllTrim(x[2]) == "BE2_QTDPRO"})
	nValComp := Ascan(aCabProc,{|x| AllTrim(x[2]) == "BE2_VLCOMP"})


	//Alimentanto a variavel lCopyGui como .T. para que a quantidade permaneca
	//zerada ao clicar no item procedimento                                   

	lCopyGui := .T.

	For nX := 1 To Len(aDadProc)
		If Funname()="PLSA094B" //zerando a copia do campo realizado
			aDadProc[nX][nQtdSol]  := 0
		Endif
		aDadProc[nX][nQtdPro]  := 0
		aDadProc[nX][nValComp] := 0
	Next nX
EndIf
If lbtnOn
	nQtdSol  := Ascan(aCabProc,{|x| AllTrim(x[2]) == "BE2_QTDSOL"})
	nQtdPro  := Ascan(aCabProc,{|x| AllTrim(x[2]) == "BE2_QTDPRO"})

	For nX := 1 To Len(aDadProc)

		aDadProc[nX][nQtdPro]  := 	aDadProc[nX][nQtdSol]

	Next nX
EndIf

//Atribui novamente o valor ao campo BE2_QTDPRO quando escolhida a opcao de Inclusao 
If nOpc == K_Incluir
	nQtdPro  := Ascan(aCabProc,{|x| AllTrim(x[2]) == "BE2_QTDPRO"})

	For nX := 1 To Len(aDadProc)
		aDadProc[nX][nQtdPro]  := 1
	Next nX
EndIf

//Define folder...                                                        

If lEvoluSADT .And. nOpc <> K_Incluir
	oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],{STR0027,STR0028,"Complem. SADT","Criticas Compl."},{"","","",""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4]) //"Eventos"###"Criticas"
Else
	If FindFunction('PGetTisVer') .and. PGetTisVer() >= '3' .and. PlsAliasExi('B4B')
		oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],{STR0027,STR0028,'Executantes'},{"","",""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4]) //"Eventos"###"Criticas"
	Else
		oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],{STR0027,STR0028},{"",""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4]) //"Eventos"###"Criticas"
	Endif
EndIf

//Cria GetDados...                                                        

AaDd(aProcAbert,{"BMPVISUAL",{|| P090Pacote("BE2",aDadB43,aCabB43,aTrbB43)},STR0359,STR0360}) //"Visualizar procedimentos contidos no pacote"       Pacote

If FindFunction("PLSNEGCOM")
	If nOpc == K_Incluir
		AaDd(aProcAbert,{"NCO",{|| aMatCom := PLSNEGCOM(M->BE2_SEQUEN,M->BE2_CODPAD,M->BE2_CODPRO,M->BE2_STATUS,M->BE1_DATPRO,,,IIF(__cTipo == '2',.F.,.T.),M->BE1_CODRDA,M->BE1_CODESP,M->BE1_CODLOC,M->BE1_USUARI) },STR0412,IIF(__cTipo == '2',STR0413,STR0415)}) //"ComposiÁ„o do procedimento"       Negar Comp./ComposiÁ„o"
	Else
		AaDd(aProcAbert,{"NCO",{|| aMatCom := PLSNEGCOM(M->BE2_SEQUEN,M->BE2_CODPAD,M->BE2_CODPRO,M->BE2_STATUS,M->BE1_DATPRO,oBrwPro:nOpcX,BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+M->BE2_SEQUEN,,M->BE1_CODRDA,M->BE1_CODESP,BEA->(BEA_CODLOC+BEA_LOCAL),BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO) ) },STR0412,STR0415}) //"ComposiÁ„o"
	EndIf
EndIf

//10                                                                                              //20
oBrwPro             := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[01],nil    ,Iif(lBtnOn,{|| .F.},NIL)  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabProc,aDadProc,.F.,"BE2",IIf(nOpc = K_Excluir .or. (nOpc = K_Evolucao .and. lEvoluSADT),K_Visualizar,nOpc),STR0029+__cDescri,nil,nil,nil,aTrbProc,nil,Iif(lBtnOn,'PlsNDel(.F.)',NIL),nil,{|a,b,c| PLSA090COR(a,b,c,.T.)},aProcAbert,nil,{|| PLSCANCEL(),Iif(oBrwPro:nOpcX==K_Incluir .And. FindFunction("PLSLIMSTA"),PLSLIMSTA(M->BE2_SEQUEN+M->BE2_CODPAD+M->BE2_CODPRO),nil) },IF(__cTipo=="2",{|nLinha,aHeaderEd,aColsEd,oObjetoBrw,oEncPLS| PLSMUDADES(nLinha,aHeaderEd,aColsEd,oObjetoBrw,oEncPLS)},nil),If(Funname()=="PLSA094B" .and. nOpc== K_Copiar,.T.,.F.)/*SOMENTE COPIA DA LIBERA«√O PARA LIBERA«√O DO CAMPO SOLICITA E BLOQUIO DA REALIZADA*/  ) 
oBrwPro:oBrowse:bDelOk  := {||IIf(!lConf,MsgInfo(STR0536),nil),lConf}//"ComunicaÁ„o j· realizada, n„o È possÌvel realizar esta aÁ„o."
oBrwPro:bLostFocus 	:= {|| P090SEQCRI(), lRefresh := .T. }
oBrwPro:bChange    	:= {|| Eval(oBrwPro:bLostFocus), oBrwCri:ForceRefresh(oBrwPro),If(FindFunction('PGetTisVer') .and. PGetTisVer() >= '3' .and. PlsAliasExi('B4B') .and. !lEvoluSADT,oBrwB4B:ForceRefresh(oBrwPro),nil) }
oBrwPro:cVldLine   	:= "PLS090VDC() .and. P090DUPADD()"

//define o campo que ser· desconsiderado em procedimentos negados na validaÁ„o de inclus„o de uma nova linha no grid.
oBrwPro:cDescCmpo   := "BE2_QTDPRO" 

//define o nome do campo de status utilizado para informar se o procedimento foi negado ou aprovado, que ser· utilizado na validaÁ„o
//no momento de incluir uma nova linha.
oBrwPro:cCmpStat    := "BE2_IMGSTA" //07 11

//ApÛs incluir pacote, inclui itens.
oBrwPro:bAfterAdd	:= {|| IIf(Len(oBrwPro:aCols) > 0, PLSADDPCT("BE2", oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_CODPAD",oBrwPro:aHeader)], ;
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_CODPRO",oBrwPro:aHeader)], ;
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_PROPCT",oBrwPro:aHeader)], ;
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_QTDSOL",oBrwPro:aHeader)], ;
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_QTDPRO",oBrwPro:aHeader)], ;
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_NIVAUT",oBrwPro:aHeader)], ;
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_NIVCRI",oBrwPro:aHeader)], ;
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_STATUS",oBrwPro:aHeader)], ;  
oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_SEQUEN",oBrwPro:aHeader)], oBrwPro,aRdaPt,oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BE2_AUDITO",oBrwPro:aHeader)]), nil)}

//Cria Criticas                                                           

bFilter             := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BEG_SEQUEN",aHeader)] == oBrwPro:FieldGet("BE2_SEQUEN") }
oBrwCri 		    := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil,oFolder:aDialogs[02],nil,,nil,nil,nil, .T.   ,nil  ,.T.,nil,aCabCri,aDadCri,.F.,"BEG",K_Visualizar,"Criticas da "+__cDescri,nil,nil,nil,aTrbCri,,,bFilter)
oBrwCri:oPai        := oBrwPro
oBrwCri:aOrigem     := {"BE2_SEQUEN"}
oBrwCri:aRelac      := {"BEG_SEQUEN"}

//Cria Executantes                                                       
If FindFunction('PGetTisVer') .and. PGetTisVer() >= '3' .and. PlsAliasExi('B4B') .and. !lEvoluSADT
	bFilB4B         := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("B4B_SEQUEN",aHeader,.T.)] == oBrwPro:FieldGet("BE2_SEQUEN") }
	oBrwB4B 		 := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[3],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabDF,aDadDF,.F.,"B4B",IIf(nOpc = K_Excluir .or. (nOpc = K_Evolucao .and. lEvoluSADT),K_Visualizar,nOpc),'Executantes',nil,nil,nil,aTrbDF,,,bFilB4B)
	oBrwB4B:oPai    := oBrwPro
	oBrwB4B:aOrigem := {"BE2_SEQUEN"}
	oBrwB4B:aRelac  := {"B4B_SEQUEN"}
Endif


//Cria Folders de Complemento e Critica de Complemento                    

If lEvoluSADT .And. nOpc <> K_Incluir
	//Itens																	
	Store Header "BQV" TO aCabBQV For .T.
	BQV->(DbSetOrder(1))

	If !BQV->( MsSeek( xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))  )
		Store COLS Blank "BQV" TO aDadBQV FROM aCabBQV
	Else
		Store COLS "BQV" TO aDadBQV FROM aCabBQV VETTRAB aTrbBQV While BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) ==  BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	Endif
		
	If lPTUOn80
		aProcAbert := {}
		aAdd(aProcAbert, {"ComPTUOn", {|| ComPTUOn("BQV","BEA")}, "PTU Online", "PTU Online"}) // Tabela de Complemento do PTU Online
	EndIf

	oBrwBQV090  := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[03],nil, ,nil,nil,nil,.T.,nil,.T.,nil,aCabBQV,aDadBQV,.F.,"BQV",IIf(nOpc == K_Evolucao,K_Alterar,K_Visualizar),"Criticas da "+__cDescri,nil,nil,nil,aTrbBQV,,'PlsNDelBQV()',NIL,{|a,b,c| PLSA092COR(a,b,c,0) },aProcAbert)
	oBrwBQV090:cVldLine	:= "P090DUPADD('oBrwBQV090','BQV')"

	//Criticas de Complemento de SADT                                         

	bFilter         := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BQZ_SEQUEN",aHeader)] == oBrwBQV090:FieldGet("BQV_SEQUEN") }
	oBrwBQZ090         := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[04],nil, ,nil,nil,nil,.T.,nil,.T.,nil,aCabBQZ,aDadBQZ,.F.,"BQZ",K_Visualizar,"Criticas da "+__cDescri,nil,nil,nil,aTrbBQZ,,,bFilter)
	oBrwBQZ090:oPai    := oBrwBQV090
	oBrwBQZ090:aOrigem := {"BQV_SEQUEN"}
	oBrwBQZ090:aRelac  := {"BQZ_SEQUEN"}
	oBrwBQZ090:bGotFocus := {||oBrwBQZ090:ForceRefresh(oBrwBQZ090)}
EndIf

//Starta funcao padrao para montar botoes padrao...                       
PLSA090Bot(nOpc,"BE1",oEncAut,oBrwPro,"BE2",{ || M->BE1_USUARI },aButtons,oFolder,oDlg,oSay02,nil,oBrwCri,lBtnOn,@cTrolComun,@aDadB6M)

//Vai desabilitar todos os campos																  
If lBtnOn
	PLS090RONL(.T.,oEncAut)
EndIf

If lCons
	PLSA090ACO("BE1",oEncAut,oBrwCri,oBrwPro)
ElseIf Len(aProc) > 0

	For I := 1 to Len(aProc)

		If I > 1
			oBrwPro:AddBlank()
			oBrwPro:oBrowse:nAt := Len(oBrwPro:aCols)
			oBrwPro:FieldPut("BE2_SEQUEN",StrZero(I,3),Len(oBrwPro:aCols))
		EndIf


		PLSA090ACO("BE1",oEncAut,oBrwCri,oBrwPro,aProc[i,1])

	Next

EndIf


//Retorna a chave relacionado a auditoria para a exclusao de registros na B72																  
if nOpc == K_Excluir

	If PLSALIASEX("B53")
		dbSelectArea("B53")
		dbSetOrder(3)

		If !EMPTY(BE2->BE2_NUMERO) .And. dbSeek(xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_CODLDP+BE2_CODPEG+BE2_NUMERO)) // B53_SITUAC, B53_NUMGUI, B53_ORIMOV
			cChave := b53->(B53_ALIMOV+B53_RECMOV)
		Else
			If dbSeek(xFilial("BEA")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)) // B53_SITUAC, B53_NUMGUI, B53_ORIMOV
				cChave := b53->(B53_ALIMOV+B53_RECMOV)
			EndIf
		EndIf
	EndIf
EndIf

//Gera/Informa protocolo de atendimento - RN 395
If lRn395 .And. nOpc == K_IMPEVSA  
	If GETNEWPAR("MV_PLSUNI","1") =="1" .And. BEA->BEA_CODEMP == GetNewPar("MV_PLSGEIN","0050")
		lInterProt := .T.    
	EndIf
	P773AutInc(IIF(nOpc == K_Incluir,"BE1","BQV"),@cNumProto,iif(nOpc == K_Evolucao,@oBrwBQV090,NIL),lInterProt,.F.,nil,nil,nil,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),.T.)  
Endif

//Ativa Dialog...                                                         

ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnchoiceBar(oDlg,bOK,{||Eval(bCancel)},.F.,aButtons), oEncAut:SetFocus() })

//Busca retorno contido no aRetorno...                                    

If nOpca == K_OK
	cOpeMov := aRetorno[2]
	cAnoAut := aRetorno[3]
	cMesAut := aRetorno[4]
	cNumAut := aRetorno[5]

	//Conclui um protocolo    
	If lRn395 .And. ! Empty(cNumProto) .And. !lInterProt
		P773AutCon(IIF(nOpc == K_Incluir,"BE1","BQV"),cNumProto,cOpeMov+cAnoAut+cMesAut+cNumAut)
	EndIf

	If (nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Copiar) .And. !lBtnOn
		A090Final(cOpeMov,cAnoAut,cMesAut,cNumAut,aRetorno[7],aRetorno[8],oBrwPro,aRetorno[9])
	Endif
Endif

//Limpa DADUSR
PLSCLEAUSR()

//Exclui os registros no banco de conhecimento relacionados com a guia excluida
If nOpca == K_OK .And. FindFunction("PLSA092EBC")
	PLSA092EBC(cOpeMov, cAnoAut, cMesAut, cNumAut)
EndIf
If nOpca == K_OK .And. FindFunction("PLS92B72")
	If !EMPTY(cChave)
		PLS92B72(cChave)
		If nOpc == K_Excluir
			DelMovAud(cChave)
		EndIf		
	EndIf
EndIf

//Desativa Sets Keys...                                                   

SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO

//Refaz filtro...                                                         

DbSelectArea("BEA")
BEA->(dbSetOrder(nOrdBEA))

if type('oBrwBEA') == "O"
	oBrwBEA:Refresh()
endIf

If nRegBEA > 0
	BEA->(DbGoTo(nRegBEA))
Endif

//incluir																	 	
If nOpc == K_Incluir
	Inclui := SlvInclui
Endif
//Se possui procedimentos de radioterapia abro a guia de radio para digitaÁ„o.
If nOpca == K_OK .AND. Len(aRetorno) >= 12 .AND. aRetorno[12]

	PLS09AMo1(,,,cOpeMov+cAnoAut+cMesAut+cNumAut)

EndIf

If nOpc == K_Excluir .AND. lNovInd

	cChavBZC := BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)

	BZC->( DbSetOrder(1) )

	if BZC->( msSeek(xFilial("BZC") + cChavBZC) )
		BZC->(recLock("BZC",.F.))
			BZC->(dbDelete())
			BZC->(msUnLock())
		endIf

	endIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A090Final
Exibir dados da autorizacao/liberacao efetuada   

@author  PLS TEAM
@version P11
@since   20.04.00
/*/
//------------------------------------------------------------------- 
Static Function A090Final(cOpeMov,cAnoAut,cMesAut,cNumAut,cCodOpeG,cTipoGuia,oBrwPro,lAuditoria)
LOCAL cNomUser
LOCAL cSIM
LOCAL cNAO
LOCAL cNomRDA
LOCAL oDlg
LOCAL cDescSimb := GetNewPar("MV_SIMB1","R$")
LOCAL cMsgTaxa  := STR0033+cDescSimb //"Valor da Taxa Administracao    "
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
LOCAL oBot01,oBot02,oBot03
LOCAL cMsgObs := ""

//Define fontes utilizadas somente nesta funcao...                        

DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

If lAuditoria
	Aviso( STR0034, ; //"Auditoria"
	STR0035,; //"Esta guia foi gravada e esta sendo analisada pela auditoria."
	{ STR0146 }, 2 )
	Return
Endif

//ponto de entrada para poder trocar a msg de taxa de administracao...    

If ExistBlock("PLS090F1")
	cMsgTaxa := ExecBlock("PLS090F1",.F.,.F.)
Endif

//ponto de entrada Bops 126389 - InserÁ„o de Msg de ObservaÁ„o            

If ExistBlock("PLS090F2")
	cMsgObs := ExecBlock("PLS090F2",.F.,.F.,{cOpeMov,cAnoAut,cMesAut,cNumAut,cCodOpeG,cTipoGuia,oBrwPro,lAuditoria})
Endif

//Mostra Resumo da Autorizacao...                                         

DEFINE MSDIALOG oDlg TITLE STR0036+__cDescri FROM 009,000 TO 024,070 OF GetWndDefault() //"Dados da "

nColAut := PLRETPOS("BE2_IMGSTA",oBrwPro:aHeader)
aEval(oBrwPro:aCols,{ |aVet|  IF(!aVet[Len(oBrwPro:aHeader)+1],If(AllTrim(aVet[nColAut])=="ENABLE",nItensSIM++,nItensNAO++),nil) })

cNomUser := TransForm(M->BE1_USUARI,PesqPict("BE1","BE1_USUARI"))+" - "+M->BE1_NOMUSR
cNomRDA  := TransForm(M->BE1_CODRDA,PesqPict("BE1","BE1_CODRDA"))+" - "+M->BE1_NOMRDA
cSIM     := StrZero(nItensSIM,2)
cNAO     := StrZero(nItensNAO,2)

If __lAutoriz

	If M->BE1_GUIACO == "1" //Guia comprada
		If M->BE1_QUACOB == "1" //No Ato
			oBot02 := SButton():New(097, 035, 4, {|| PLSA090Bxt()},,.T.)
			oBot02:cToolTip := STR0037 //"Baixar Titulo a Receber Vinculado a Guia"
		Else
			oBot02 := SButton():New(097, 035, 6, {|| Pergunte("PLA090",.F.),lImpGuiDir:=(mv_par01==1),Eval(bImpGuia),If(lImpGuiDir,oDlg:End(),nil) },,.T.)
			oBot02:cToolTip := STR0038+__cDescri //"Imprimir a "
		Endif
	Else
		oBot02 := SButton():New(097, 035, 6, {|| Pergunte("PLA090",.F.),lImpGuiDir:=(mv_par01==1),Eval(bImpGuia),If(lImpGuiDir,oDlg:End(),nil) },,.T.)
		oBot02:cToolTip := STR0038+__cDescri //"Imprimir a "
	Endif

	aVlrPF  := PLSVALCOPA(cCodOpeG,cTipoGuia)

	nVlrPF  := aVlrPF[1]
	nVlrBPF := aVlrPF[2]
	nPercPF := aVlrPF[3]
	nVlrTPF := aVlrPF[4]
	nVlrTAD := aVlrPF[5]

	If nVlrPF > 0 .And. ( M->BE1_CODRDA <> GetNewPar("MV_PLSRDAG","999999") .Or. (GetNewPar("MV_PLSEVRG","0") == "1" ) )

		If GetNewPar("MV_PLSEXPF","1") == "1"
			If GetNewPar("MV_PLSEXBT","1") == "1"
				If M->BE1_GUIACO <> "1"
					If Len(aVlrPF) >= 6
						If aVlrPF[6] <> "1"
							@ 063,151 SAY oSay PROMPT STR0039+cDescSimb SIZE 220,010 OF oDlg PIXEL //"Valor da Co-Participacao       "
						Else
							@ 063,105 SAY oSay PROMPT STR0386 SIZE 220,010 OF oDlg PIXEL  //"Valor total a ser pago direto a rede de atendimento R$"
						Endif
					Else
						@ 063,151 SAY oSay PROMPT STR0039+cDescSimb SIZE 220,010 OF oDlg PIXEL //"Valor da Co-Participacao       "
					Endif
				Else
					@ 063,151 SAY oSay PROMPT STR0040+cDescSimb SIZE 220,010 OF oDlg PIXEL       //"Valor da Compra                "
				Endif
				@ 063,230 SAY oSay PROMPT Round(nVlrPF,2) PICTURE PLPMONEY_M   SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

				If nVlrTAD > 0
					@ 080,151 SAY oSay PROMPT cMsgTaxa SIZE 220,010 OF oDlg PIXEL

					@ 080,230 SAY oSay PROMPT Round(nVlrTAD,2) PICTURE PLPMONEY_M   SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE
				Endif
			Endif

			If M->BE1_GUIACO <> "1"
				If Len(aVlrPF) >= 6
					If aVlrPF[6] <> "1"
						@ 097,151 SAY oSay PROMPT STR0041+cDescSimb SIZE 220,010 OF oDlg PIXEL //"Valor Total da Co-Participacao "
					Else
						@ 097,105 SAY oSay PROMPT STR0386 SIZE 220,010 OF oDlg PIXEL //"Valor total a ser pago direto a rede de atendimento R$"
					Endif
				Else
					@ 097,151 SAY oSay PROMPT STR0041+cDescSimb SIZE 220,010 OF oDlg PIXEL //"Valor Total da Co-Participacao "
				Endif
			Else
				@ 097,151 SAY oSay PROMPT STR0042+cDescSimb SIZE 220,010 OF oDlg PIXEL  //"Valor Total da Compra          "
			Endif
			@ 097,230 SAY oSay PROMPT Round(nVlrTPF,2)  PICTURE PLPMONEY_M   SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

			@ 105,151 SAY oSay PROMPT STR0043 SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED //"(*) Nao inclui valores de materiais e medicamentos."
		Endif
	Endif
Endif

oBot01 := SButton():New(097, 005, 1, {|| oDlg:End() },,.T.)
oBot01:cToolTip := STR0044 //"Fechar Tela"

oBot03 := SButton():New(097, 065, 5, {|| Pergunte("PLA090",.T.),lImpGuiDir:=(mv_par01==1) },,.T.)
oBot03:cToolTip := STR0045 //"Parametros Impressao"

@ 007,005 SAY oSay PROMPT __cDescri+" "+STR0046  SIZE 220,010 OF oDlg PIXEL FONT oFontNum //" Numero   "
@ 006,095 SAY oSay PROMPT cOpeMov+"."+cAnoAut+"."+cMesAut+"."+cNumAut SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

If nItensSIM > 0 .And. ! Empty(M->BE1_SENHA)
	@ 005,230 SAY oSay PROMPT STR0047  SIZE 220,010 OF oDlg PIXEL //"Senha"
	@ 014,150 SAY oSay PROMPT "[ "+M->BE1_SENHA+" ]" SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED
Endif

@ 025,005 SAY oSay PROMPT STR0048  SIZE 220,010 OF oDlg PIXEL //"Usuario              "
@ 025,065 MSGET cNomUser                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 043,005 SAY oSay PROMPT STR0049  SIZE 220,010 OF oDlg PIXEL //"Rede Atendimento     "
@ 043,065 MSGET cNomRDA                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 061,005 SAY oSay PROMPT STR0050+IF(__cTipo=="1",STR0051,STR0052)+"s"  SIZE 220,010 OF oDlg PIXEL //"Itens "###"Autorizado"###"Liberado"
@ 061,065 MSGET cSIM                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 079,005 SAY oSay PROMPT STR0053+IF(__cTipo=="1",STR0051,STR0052)+"s"  SIZE 220,010 OF oDlg PIXEL  //"Itens NAO "###"Autorizado"###"Liberado"
@ 079,065 MSGET cNAO                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

If !Empty(cMsgObs)
	@ 079,082 SAY oSay PROMPT SubStr(cMsgObs,1,60) SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED
EndIf

ACTIVATE MSDIALOG oDlg CENTERED on init if(Type('oBot02') == "O",oBot02:SetFocus(),Nil)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A090LIMPA
Limpa todos os campos da Enchoice e GetDados e Atualiza.   

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//------------------------------------------------------------------- 
Function A090Limpa(cAlias,oEnchoice,oBrowse,cAliasGetd,lItens,lUsr,lPerg,cAliCri,oGet01,cGet01)
	LOCAL cField
	LOCAL cCpoUsr  := cAlias+"_USUARI,"+cAlias+"_MATANT,"+cAlias+"_NOMUSR,"+cAlias+"_TIPUSR"
DEFAULT lItens := .T.
DEFAULT lUsr   := .T.
DEFAULT lPerg  := .F.
DEFAULT cAliCri := "BEG"
DEFAULT oGet01  := nil
DEFAULT cGet01  := ""

//Para escolha do usuario se limpa a guia ou somente os eventos e criticas

If lPerg
	If  Aviso(	STR0054, STR0055,{ STR0056, STR0057}, 2 ) == 1 //"AtenÁ„o"###"Deseja limpar os campos do FOLDER GUIA/OUTROS?"###"Sim"###"Nao"
		lPerg := .F.
	Else
		lPerg := .T.
	EndIf
EndIf
If !lPerg

	//Em todos os campo da enchoice zera conteudo...                          

	SX3->(DbSetOrder(1))
	IF SX3->(MsSeek(cAlias))
		While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias

			cField := AllTrim(SX3->X3_CAMPO)

			If ! (cField $ cAlias+"_ANOPAG,"+cAlias+"_MESPAG")
				If     cField $ cCpoUsr
					If lUsr
						M->&(cField) := CriaVar(cField)
					Endif
				Else
					M->&(cField) := CriaVar(cField)
				Endif
			Endif

			SX3->(DbSkip())
		Enddo
	Endif
EndIF

//Limpa itens...                                                          

If lItens
	A090Clr(cAliCri,oBrwCri)
	A090Clr(cAliasGetd,oBrowse)
	If !Empty(cGet01)
		A090Clr(cGet01,oGet01)
	Endif
Endif

//Atualiza Enchoice...                                                    

	lRefresh := .T.
	oEnchoice:oBox:Refresh()
	oEnchoice:oBox:SetFocus()
Return

/*/{Protheus.doc} PLSA090USR
Tratamento do campo BE1_USUARI (X3_VALID   

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
Function PLSA090USR(cMatric,dData,cHora,cAliasAux,lMsgCri,lRPC,lAtuGets,cLocalExec,cCodPad,cCodPro,cViaCartao,cTpMat,;
	lIncAutIE,cNomUsrCar,dDatNasUsr,lIncWeb,lCheckFin,lValidVis,lInc,lCarga,cTpLocExec,cTipAtd,lProtRN395,lBloqGui, lVldBlq, lApiBenHAT)       

LOCAL   nFor       := 0
LOCAL   nLenMat	   := 0
LOCAL   nDiasBloq  := GetNewPar("MV_PLDIABL",0)
LOCAL   cSQL       := ""
LOCAL   cVldMat    := ""
LOCAL   cOpeUsr    := ""
LOCAL   cTipoMat   := ""
LOCAL   cMatSalv   := ""
LOCAL   cMatAntPes := ""
LOCAL   cMatr16Dig := ""
LOCAL   cLocalPar  := GetNewPar("MV_PLSSTAD","3")
LOCAL   cOriMat    := cMatric
LOCAL   aRetIntEve := {}
LOCAL   aCri       := {}
LOCAL   aRetFun    := {}
LOCAL   aSitAdv    := {}
LOCAL   aCodCri    := {}
LOCAL   aDadUsr    := {}
LOCAL   aRetCon	   := {}
LOCAL   aRetFin    := {}
LOCAL   aRetPtoEnt := {}
LOCAL   aMatCri	   := {}
LOCAL	aCriTok	   := {}
LOCAL   aRetTok    := {}
LOCAL   lForcou    := .F.
LOCAL   lOK        := .F.
LOCAL   lAntiga    := .F.
LOCAL   lUnimeds   := IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
LOCAL   lPerFor    := .T.
LOCAL   lFlag      := .F.
LOCAL   l16Digitos := .F.
LOCAL   lIncEvent  := .T.
LOCAL   i          := 0
Local   lMsCriFi   := .F.
Local 	 cGloNF    := "508" //Codigo de glosas que nao devem permitir forcar.
Local   cProdUsu   := ""
Local   cVersaoPrd := ""
Local   lPosOdont  := .F. //Retorna falso caso usuario nao possua produto odontologico
Local   lPosMedic  := .F. //Retorna falso caso usuario nao possua produto medicina
Local 	lRetSeg	   := .F. //Retorna falso caso usuario nao possua produto medicina ou odontologico
Local   cOprda	   := ""
Local 	aCliente   := {}
Local   lInterProt := .F.
Local   lMatChP    := .F.
Local   lBloqu	   := .F.
Local 	lRetInt	   := .F.
Local   cMsn       := ""
Local   aAreaBE4   := {} 
Local 	aArea498   := BE4->(GetArea())
Local   dXdate	   := Date()
Local   cXtime	   := Time()
Local   xCodUsr	   := BCS->(RetCodUsr())
Local   lDesInt    := GETNEWPAR("MV_PLSDEIN",.F.)
Local lNewAud       := GetNewPar("MV_PL790NE","0") == "1"
Local cHorMem		:= ""
Local cHorPar		:= ""
Local lUsuLib		:= .F.
Local lStrTPLS	   := FindFunction("StrTPLS")
Local cAliNomSoc   := ""

DEFAULT lValidVis  := .T.
DEFAULT cLocalExec := "1"
DEFAULT cCodPad    := ""
DEFAULT cCodPro    := ""
DEFAULT cViaCartao := ""
DEFAULT cTpMat     := ""
DEFAULT cNomUsrCar := ""
DEFAULT dDatNasUsr := ctod("")
DEFAULT lMsgCri    := .T.
DEFAULT lRPC       := .F.
DEFAULT lAtuGets   := .T.
DEFAULT lIncAutIE  := .F.
DEFAULT lIncWeb	   := .F.
DEFAULT lCheckFin  := .T.
DEFAULT lInc	   := .T.
DEFAULT lCarga	   := .F.
DEFAULT cAliasAux  := ""
DEFAULT cTpLocExec := '1'
DEFAULT cTipAtd	   := ""
DEFAULT lProtRN395 := .F.
DEFAULT lBloqGui		:=.F.
DEFAULT lVldBlq	:= .T. //identifica se vai valida bloqueio de usuario/familia ou n„o, foi criado pq È chamado na validaÁ„o da matricula mas nem sempre ja valida o bloqueio nessa hora, no reembolso por exemplo, valida de acordo com a data do documento fiscal apenas
DEFAULT lApiBenHAT := .F.

//cTpMat   " " procurar pela nova e antiga
//         "1" procurar pela nova somente
//         "2" procurar pela antiga

//Busca informaÁ„o se o usu·rio existe - ResoluÁ„o para chamado DSAUPC-11359/12328
lUsuLib := PlExistUsu(cMatric,.F.)

//Ponto de entrada antes da validacao da matricula do usuario≥
If ExistBlock("PLS090MATR")
	aRetPtoEnt := ExecBlock("PLS090MATR",.F.,.F.,{cMatric,lRPC})
	If ValType(aRetPtoEnt) == "A"
		cMatric	 := aRetPtoEnt[1]
		cMatAntPes := aRetPtoEnt[2]
	Else
		cMatric := aRetPtoEnt
	Endif
Endif

If GetNewPar("MV_PLRN395","0") == "0"
	lProtRN395 := .F.
EndIf

cMatric := AllTrim(cMatric)
nLenMat := Len(cMatric)

// cLocalExec  "1" - Autorizacao/Liberacao
//             "2" - Processamento de Conta
// cTpLocExec  "1" Remote Protheus  "2" WEB  "3" POS "4" ---- "5" XML

//Verifica se a matricula foi digitada integralmente...                   

If lUnimeds
	If nLenMat >= 16
		For i := 1 to nLenMat-1
			If !lStrTPLS
				If !(Subs(cMatric,i,1))$"0123456789"
					MsgAlert(STR0414,"TOTVS",{STR0146})
					Return(lOK)
				EndIf
			EndIF	
		Next i
	EndIf

	If ( nLenMat < 16 .Or. nLenMat > 17 ) .Or. isAlpha(cMatric)
		PLSPOSGLO(PLSINTPAD(),__aCdCri011[1],__aCdCri011[2],cLocalExec,nil,cTpLocExec)

		If lRPC
			aCodCri := {}
			aadd(aCodCri,{__aCdCri011[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			aadd(aCodCri,{""   ,STR0058,cMatric,"","",cCodPad,cCodPro}) //"Matricula Usuario"
			aadd(aCodCri,{""   ,STR0059,cMatric,"","",cCodPad,cCodPro}) //"Matricula deve ter entre 16 e 17 caracteres"
			Return({.F.,aCodCri})
		Else
			Help("",1,"PLSMATINV",nil,PLSBCTDESC())
			Return(lOK)
		Endif
	ElseIf nLenMat == 16
		If !lStrTPLS
			If Modulo11(Subs(cMatric,1,15)) <> Subs(cMatric,16,1)
				PLSPOSGLO(PLSINTPAD(),__aCdCri038[1],__aCdCri038[2],cLocalExec,nil,cTpLocExec)
				If lRPC
					aCodCri := {}
					aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{""   ,STR0060,Subs(cMatric,16,1),"","",cCodPad,cCodPro}) //"Digito informado"
					aadd(aCodCri,{""   ,STR0061,Modulo11(Subs(cMatric,1,15)),"","",cCodPad,cCodPro}) //"Digito correto"
					Return({.F.,aCodCri})
				Else
					Aviso( STR0062, ;                         												            //"Digito Verificador"
					STR0063+chr(13)+STR0064+Subs(cMatric,16,1)+Chr(13)+STR0065+Modulo11(Subs(cMatric,1,15)),; //"O Digito verificador do matricula do usuario e invalido."###" Digito Informado "###" Digito correto "
					{ STR0146 }, 2 )
					Return(lOK)
				Endif
			Endif
		Else
			If Modulo11(StrTPLS(Subs(cMatric,1,15))) <> Subs(cMatric,16,1)
				PLSPOSGLO(PLSINTPAD(),__aCdCri038[1],__aCdCri038[2],cLocalExec,nil,cTpLocExec)
				If lRPC
					aCodCri := {}
					aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{""   ,STR0060,Subs(cMatric,16,1),"","",cCodPad,cCodPro}) //"Digito informado"
					aadd(aCodCri,{""   ,STR0061,Modulo11(StrTPLS(Subs(cMatric,1,15))),"","",cCodPad,cCodPro}) //"Digito correto"
					Return({.F.,aCodCri})
				Else
					Aviso( STR0062, ;                         												            //"Digito Verificador"
					STR0063+chr(13)+STR0064+Subs(cMatric,16,1)+Chr(13)+STR0065+Modulo11(StrTPLS(Subs(cMatric,1,15))),; //"O Digito verificador do matricula do usuario e invalido."###" Digito Informado "###" Digito correto "
					{ STR0146 }, 2 )
					Return(lOK)
				Endif
			Endif
		EndIf
		lAntiga  := .T.
		cOpeUsr  := "0"+Subs(cMatric,1,3)
		cTipoMat := "2"
	ElseIf nLenMat == 17
		PLSPOSGLO(PLSINTPAD(),__aCdCri038[1],__aCdCri038[2],cLocalExec,nil,cTpLocExec)

		If !lStrTPLS
			If Modulo11(Subs(cMatric,1,16)) <> Subs(cMatric,17,1)
				If lRPC
					aCodCri := {}
					aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{""   ,STR0060,Subs(cMatric,17,1),"","",cCodPad,cCodPro}) //"Digito informado"
					aadd(aCodCri,{""   ,STR0061,Modulo11(Subs(cMatric,1,16)),"","",cCodPad,cCodPro}) //"Digito correto"
					Return({.F.,aCodCri})
				Else
					Aviso( STR0062, ;                                     //"Digito Verificador"
					STR0063+chr(13)+STR0064+Subs(cMatric,17,1)+Chr(13)+STR0065+Modulo11(Subs(cMatric,1,16)),; //"O Digito verificador do matricula do usuario e invalido."###" Digito Informado "###" Digito correto "
					{ STR0146 }, 2 )
					Return(lOK)
				Endif
			Endif
		Else
			If Modulo11(StrTPLS(Subs(cMatric,1,16))) <> Subs(cMatric,17,1)
				If lRPC
					aCodCri := {}
					aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{""   ,STR0060,Subs(cMatric,17,1),"","",cCodPad,cCodPro}) //"Digito informado"
					aadd(aCodCri,{""   ,STR0061,Modulo11(StrTPLS(Subs(cMatric,1,16))),"","",cCodPad,cCodPro}) //"Digito correto"
					Return({.F.,aCodCri})
				Else
					Aviso( STR0062, ;                                     //"Digito Verificador"
					STR0063+chr(13)+STR0064+Subs(cMatric,17,1)+Chr(13)+STR0065+Modulo11(StrTPLS(Subs(cMatric,1,16))),; //"O Digito verificador do matricula do usuario e invalido."###" Digito Informado "###" Digito correto "
					{ STR0146 }, 2 )
					Return(lOK)
				Endif
			Endif
		EndIF

		cOpeUsr := Subs(cMatric,1,4)
		cTipoMat := "1"
	Endif
Else
	cTipoMat := "1"
	//Procura primeiro pela matricula antiga...                               
	If nLenMat > 0
		For i := 1 to nLenMat
			If !(Subs(cMatric,i,1))$"0123456789"
				lMatChP := .T.
			EndIf
		Next i

		If lMatChP 
			BA1->( DbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
			If BA1->( MsSeek( xFilial("BA1")+AllTrim(cMatric) ) )
				cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
			Else
				BA1->( DbSetOrder(2) )//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO                                                                                               
				If BA1->( MsSeek( xFilial("BA1")+AllTrim(cMatric) ) )
					cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)			
				Else
					MsgAlert(STR0414,"TOTVS",{STR0146})
				
					aRetFun := PLSDADUSR(cMatric,"1",.T.,dData,nil,nil,cViaCartao)
					aCodCri := aClone(aRetFun[2])
					Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat, .F.}))
				Endif			
			EndIf
		EndIf	  
	EndIf
Endif

//Procura primeiro pela matricula antiga...                            	
If (cTpMat == "2" .or. empty(cTpMat) )

	aRetFun := PLSDADUSR( iIf( empty(cMatAntPes),cMatric,cMatAntPes),"1",.t.,dData,nil,nil,cViaCartao)

	If ! aRetFun[1] .and. empty(cTpMat)
		aRetFun := PLSDADUSR(If(Empty(cMatAntPes),cMatric,cMatAntPes),"2",.T.,dData,nil,nil,cViaCartao)
	EndIf

	lOK := aRetFun[1]
	If lOK
		cMatric := aRetFun[2]
		aDadUsr := PLSGETUSR()
	Endif

Endif

//Busca dados do usuario pela matricula microsiga                         

If !lOK .and. (cTpMat == "1" .Or. Empty(cTpMat))

	aRetFun := PLSDADUSR(cMatric,"1",.T.,dData,nil,nil,cViaCartao)

	lOK := aRetFun[1]
	If lOK
		aDadUsr := PLSGETUSR()
	Endif
Else
	aDadUsr := PLSGETUSR()
Endif

If lUnimeds .And. nLenMat == 16 .And. ! lOK

	l16Digitos 	:= .T.
	cMatr16Dig 	:= cMatric
	cMatric 		:= "0"+cMatric

	If ! lRPC .And. ! MsgYesNo(STR0377+CHR(13)+CHR(13)+cMatr16Dig)
		lOK       := .F.
		lIncEvent := .F.

		aCodCri := {}
		aadd(aCodCri,{"",STR0378,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
		If Len(aRetFun) >= 2
			aRetFun[2] := aClone(aCodCri)
		Endif
	Endif
Endif

//Se for usuario eventual abre tela para cadastrado...                    

If     ( lIncEvent ) .And. ;
( ! lOK ) .And. ;
( ! lRPC ) .And. ;
( lUnimeds ) .And. ;
( cOpeUsr <> PLSINTPAD() ) .And. ;
( aRetFun[2,1,1] == __aCdCri011[1] )

	If MsgYesNo(STR0066) //"Usuario nao encontrado. Deseja inclui-lo como intercambio eventual ?"

		aRetIntEve := PLSA235(.F.,If(lAntiga,cOriMat,cMatric))
		If aRetIntEve[1]
			aRetFun := PLSDADUSR(aRetIntEve[2],"1",.T.,dData,nil,nil,cViaCartao)
			lOK     := aRetFun[1]

			If lOK
				aDadUsr := PLSGETUSR()
				// Se a inclus„o do usu·rio de intercabio for bem sucedida, a variavel cMatric passa a ser a matricula do BA1 recem 
				// Criado. 
				cMatric := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
			Else
				If Len(aRetFun) >= 2
					PLSMOVCRI("2",{},aRetFun[2])
				Endif
			Endif
		Else
			lOK :=  .F.
			If Len(aRetIntEve) >= 2 .And. Len(aRetIntEve[2]) > 0
				PLSMOVCRI("2",{},aRetIntEve[2])
			Endif
		Endif
	Endif

ElseIf ( ! lOK ) .And. ;
( lRPC ) .And. ;
( lUnimeds ) .And. ;
( cOpeUsr <> PLSINTPAD() ) .And. ;
( aRetFun[2,1,1] == __aCdCri011[1] ) .And. ;
( lIncAutIE )

	If Empty(cNomUsrCar)
		cNomUsrCar := If(lAntiga,cOriMat,cMatric)+STR0067 //"Usr Event" 29 caracteres
	Endif

	aRetIntEve := PLSA235(.F.,If(lAntiga,cOriMat,cMatric),.F.,.T.,cNomUsrCar,dDatNasUsr,lRPC,,lIncWeb)
	If aRetIntEve[1]
		aRetFun := PLSDADUSR(aRetIntEve[2],"1",.T.,dData,nil,nil,cViaCartao)
		lOK     := aRetFun[1]

		If lOK
			aDadUsr := PLSGETUSR()
		Else
			If Len(aRetFun) >= 2
				aCodCri := aClone(aRetFun[2])
			Endif
		Endif
	Else
		lOK := .F.
		If Len(aRetIntEve) >= 2
			aCodCri := aClone(aRetIntEve[2])
		Endif
	Endif
Endif


//Verifica se foi gerado/informado protocolo de atendimento 
If !lRpc .and. (Type("cNrProWeb") == "U"  .or. Empty(cNrProWeb))
	If !lRpc .And. lOk .And. lProtRN395 .And. Type("cNumProto") <> "U" .And. Empty(cNumProto)

		If lUnimeds .And. aDadUsr[45] <> PlsIntPad()  
			P773AutInc(cAliasAux,@cNumProto,nil,.T.,.F.,nil,nil,nil,Alltrim(aDadUsr[2]),.T.)     
			lInterProt := .T.
		Else
			P773AutInc(cAliasAux,@cNumProto,nil,nil,nil,nil,nil,nil,Alltrim(aDadUsr[2]),.T.)
		EndIf	

		If Empty(cNumProto) .And. !lInterProt 
			lOk := .F.
			Return(lOK)
		Endif	
	Endif
EndIF
If ! lOK .And. Len(aRetFun) >= 2
	BCT->(DbSetOrder(1))
	For nFor := 1 To Len(aRetFun[2])
		If ! Empty(aRetFun[2][nFor][1])
			If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aRetFun[2][nFor][1])) .And.;
			BCT->BCT_PERFOR == "1" .And.;
			!(BCT->(BCT_PROPRI+BCT_CODGLO) $ cGloNF)

				lFlag := .T.
			Else
				lFlag := .F.
				Exit
			Endif
		Endif
	Next

	//Se existe pelo menos uma critica que pode forcar entra nessa regra de forcar≥
	If lFlag .And. ( lMsgCri .Or. ! lRPC )

		If lValidVis .and. !lCarga
			lOK := PLSMOVCRI("2",{},aRetFun[2],.T.)
		EndIf

		If lOK
			If ValType(aAutFor) == "A"
				nPos := Ascan(aAutFor,{|x| AllTrim(x[2]+x[3]) == ""})
				If nPos == 0
					AaDd(aAutFor,{.T.,"","","","","","",0,BCS->(RetCodUsr()),Date(),Time(),,,""})
				Endif
			Endif
		Endif
	Else
		If lMsgCri .Or. ! lRPC
			If lValidVis .and. !lCarga
				PLSMOVCRI("2",{},aRetFun[2])
			EndIf
		Endif

		If lRPC
			aCodCri := aClone(aRetFun[2])
		Endif
	Endif
Endif

//Verificar se encontra o usuario, caso force a critica e n„o tenha encontrado usuario ...
If lOK .And. Len(aDadUsr) == 0
	aDadUsr := PLSGETUSR()
Endif

aCriCab := {{}}
//Caso o usuario seja valido limpa os dados...                            

If lOK .And. Len(aDadUsr) > 0

	If FunName() == "PLSA092"
		cHorMem := M->BE4_HHDIGI

		If valType(M->BE4_HHDIGI) != 'U' .And. ! Empty(M->BE4_HHDIGI)
			cHorPar := subStr(cHorMem,1,2)+":"+subStr(cHorMem,3,2)+":"+subStr(cHorMem,5,5)
		EndIf
	EndIf

	If isInCallstack("PLSA090DAT") .Or. isInCallstack("PLS090OMOV") .Or. isInCallStack("PLVLDUSRP") .Or. isInCallStack("PLSXAUTP")
		cHorPar := time()
	EndIf

	//Inicia uma serie de gatilhos...                                         

	lRefresh := .T.

	If ( cLocalPar == "3" .Or. cLocalPar == cLocalExec ) .And. ! lRPC .And. lMsgCri
		aSitAdv  := PLSXANASAD(.T., dData)
	Endif

	If cLocalExec == "1" //No atendimento...

		// Se AutorizaÁ„o SADT ou SolicitaÁ„o de InternaÁ„o via Remote, valido o Token
		If UPPER(Alltrim(Funname())) $ "PLSA094A,PLSA092" .And. PLSPOSGLO(PLSINTPAD(),__aCdCri241[1],__aCdCri241[2],cLocalExec,nil,cTpLocExec) .And. ;
		   (( lUnimeds .And. aDadUsr[45] == PlsIntPad() ) .Or. !lUnimeds ) // Unimed: Benefici·rio de Intercambio n„o valida o token, a validaÁ„o È feito pela Unimed do Benefici·rio no PTU Online

			cAliTok := Iif(AllTrim(Funname()) == "PLSA094A", "BE1", "BE4")
			aRetTok := PLSUTOKVLD(cMatric, &("M->"+cAliTok+"_TOKEDI"))
			If !aRetTok[1]
				aCriTok := {}
				aAdd(aCriTok,{__aCdCri241[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				aAdd(aCriTok,{""   ,STR0671,&("M->"+cAliTok+"_TOKEDI"),"","",cCodPad,cCodPro}) //"Token informado"
				aAdd(aCriTok,{""   ,STR0672,aRetTok[2],"","",cCodPad,cCodPro}) //"Token correto"
				aCriTok := {.F., aCriTok}
			Else
				aCriTok := {.T., {}}
			EndIf
		Else
			aCriTok := {.T., {}}
		EndIf

		If cAliasAux != 'BOW' 
			aRetCon  := PLSVLDCON(cMatric,dData,cCodPad,cCodPro,cLocalExec,NIL,NIL,NIL,NIL,NIL,cTpLocExec, lVldBlq,cHorPar)

			aRetFin  := PLSVLDFIN(cMatric,dData,cCodPad,cCodPro,cLocalExec,aDadUsr,nil,lCheckFin,NIL,cTpLocExec)
		Else
			AADD(aRetCon,.T.)
			AADD(aRetFin,.T.)
		EndIf 

		if !FdCrifor(M->BE1_NUMLIB,{},"",aRetCon,aRetFin,@lRPC,,,,,aCriTok) .And. ;
			((AllTrim(M->BE1_TIPADM) <> "4") .Or. (AllTrim(M->BE1_TIPADM) == "4" .And. Iif(Len(aRetCon) > 1, Ascan(aRetCon[2],{|x| x[1] == "010"}) > 0 , .F.)))
			//Inclui as criticas em uma unica matriz, se n„o encontrar liberaÁ„o forcada manual
			If (!aRetCon[1] .or. !aRetFin[1] .or. !aCriTok[1]) .And. IIf(Type("M->BE1_NUMLIB") != "C", .T., NotFdBDS(M->BE1_NUMLIB))

				If ExistBlock("PLSMSCRI")
					aRetBlc := ExecBlock("PLSMSCRI",.F.,.F.,{aRetCon,aRetFin})
					aRetCon := aRetBlc[1]
					aRetFin := aRetBlc[2]
				Endif

				aMatCri := {{}}
				aCriCab := {{}}   

				If !aRetCon[1]
					For nFor:=1 To Len(aRetCon[2])
						AaDd(aMatCri[1],aRetCon[2][nFor])
						AaDd(aCriCab[1],aRetCon[2][nFor])			 	
					Next
				Endif

				If !aRetFin[1]
					For nFor:=1 To Len(aRetFin[2])
						AaDd(aMatCri[1],aRetFin[2][nFor])
						AaDd(aCriCab[1],aRetFin[2][nFor])
					Next
				Endif

				If !aCriTok[1]
					For nFor:=1 To Len(aCriTok[2])
						AaDd(aMatCri[1],aCriTok[2][nFor])
						AaDd(aCriCab[1],aCriTok[2][nFor])
					Next
				Endif

				If Len(aMatCri[1])>0
					lMsCriFi := .T.
				Endif

				lOK := .F.

				If (lMsgCri .And. ! lRPC)  .or. lMsCriFi

					BCT->(DbSetOrder(1))
					For nFor := 1 To Len(aMatCri[1])
						If ! Empty(aMatCri[1][nFor][1])
							If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aMatCri[1][nFor][1])) .And. BCT->BCT_PERFOR == "1"
								lFlag := .T.
							Else
								lFlag := .F.
								Exit
							Endif
						Endif
					Next

					//tratamento especifico para criticas financeiras
					If !aRetFin[1]
						lPerFor := GETNEWPAR("MV_PLSFORC","1")=="1"

						If lPerFor .And. ExistBlock("PLSPRFRF")
							lPerFor := ExecBlock("PLSPRFRF",.F.,.F.,aRetFin[2])
						Endif
					Endif
					If !lPerFor
						lFlag := .F.
					Endif

					//Valida se usuario est· internado 
					BE4->(DbSetOrder(18))//BE4_FILIAL, BE4_OPERDA, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO, BE4_CODRDA, BE4_DATPRO
					lRetInt := !BE4->(MsSeek(xFilial("BE4")+cMatric)) 

					If ! lRetInt .And. !EMPTY(BE4->BE4_DATPRO) .And. EMPTY(BE4->BE4_DTALTA) .and. lValidVis .and. BE4->BE4_TIPGUI == G_SOL_INTER

						If  ! lRPC .And. ! Empty(BA1->BA1_MOTBLO) .and.  dData>=BA1->BA1_DATBLO+nDiasBloq  .and. cLocalExec == "1"
							//"Usuario"  "Este usuario somente podera utilizar o plano, conforme bloqueio pre-determinado, ate o dia ######"
							If nDiasBloq == 0
								Aviso( STR0071, STR0072+dtoc(BA1->BA1_DATBLO), { STR0146 }, 2 )
								lIntGui:=.T.
							Else
								Aviso( STR0071, STR0072+dtoc(BA1->BA1_DATBLO) +". "+ STR0405  +" "+  dtoc(BA1->BA1_DATBLO+nDiasBloq) + ".", { STR0146 }, 2 )
								lIntGui:=.T.
							EndIf
						Endif					

						lValidVis:=.F.
						lOk:=.T.
					Else
						lIntGui:=.F.
					Endif

					If lValidVis .And. !lCarga .And. !lRPC
						If !lUsuLib //N„o aciona PLSMOVCRI caso usuario exista - ResoluÁ„o para chamado DSAUPC-11359/12328
							lOK := PLSMOVCRI("2",{},aMatCri[1],lFlag)
						Else
							lOk := .T.
						EndIf
					EndIf

					//se este parametro estiver ativo indica que o cliente sempre vai permitir que as criticas de cabeÁalho
					//nao impeÁam a gravaÁ„o          
					lOK := lOK .OR. (GETNEWPAR("MV_PLSCABC","0")=="1" .And. !IsInCallStack("PTONPEDAUT") .And. !IsInCallStack("PROCONLINE") .And. !lApiBenHAT) 

					If lOK .And. lFlag .And. ValType(aAutFor) == "A"
						nPos := Ascan(aAutFor,{|x| AllTrim(x[2]+x[3]) == ""})
						If nPos == 0
							aadd(aAutFor,{.T.,"","","","","","",0,BCS->(RetCodUsr()),Date(),Time(), IIF( Len(aMatCri[1][1]) >= 9, aMatCri[1][1][9], "") , IIF( Len(aMatCri[1][1]) >= 10, aMatCri[1][1][10], "") ,""})
						Endif
					Endif

					If !lOK .Or. (lMsCriFi .And. IsInCallStack("PROCONLINE") .And. (lRetInt .Or. !lDesInt)) ;  //transacao do tissonline deve ser negada caso tenha critica e o benef n esteja internado 
					 		.OR. (lMsCriFi .And. IsInCallStack("PLSA001A"))  //ira retornar a critica na geraÁ„o da autorizaÁ„o de reembolso 
							
							aCodCri := aClone(aMatCri[1])                 
							lOK:=.F.
					Endif 

				ElseIf lRPC
					aCodCri := aClone(aMatCri[1])
				Endif
			Else
				If lMsgCri
					If ! aRetCon[1]

						lForcar := BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+aRetCon[2][1][1],"BCT_PERFOR")) == "1"
						lForcou := PLSMOVCRI("2",{},aRetCon[2],lForcar)
							If lForcar .And. lForcou
							lOK := .T.
							aadd(aAutFor,{.T.,"","","","","","",0,xCodUsr,dXdate,cXtime})
						Else
							Return(.F.)
						Endif
					else
						lOK := .T.   
					Endif

					if ! aRetFin[1]

						lForcar := BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+aRetFin[2][1][1],"BCT_PERFOR")) == "1"
						lForcou := PLSMOVCRI("2",{},aRetFin[2],lForcar)
						If lForcar .And. lForcou
							lOK := .T.
							aadd(aAutFor,{.T.,"","","","","","",0,xCodUsr,dXdate,cXtime})
						Else
							Return(.F.)
						Endif
					else
						lOK := .T.
					EndIF

					If ! aCriTok[1]
						lForcar := BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+aCriTok[2][1][1],"BCT_PERFOR")) == "1"
						lForcou := PLSMOVCRI("2",{},aCriTok[2],lForcar)
						If lForcar .And. lForcou
							lOK := .T.
							aadd(aAutFor,{.T.,"","","","","","",0,xCodUsr,dXdate,cXtime})
						Else
							Return(.F.)
						Endif
					Else
						lOK := .T.
					Endif
				Else
					lOK := .T.
				EndIF
			Endif
		EndIf
	Endif

	//Inserido Critica para quando o Usu·rio n„o pode solicitar Reembolso. Definido nos niveis (BA3,BQC,BT5,BG9,BI3)
	If cAliasAux == 'BOW'

		If lInc .And. lOK .And. !lRPC .AND. !aDadUsr[87] .AND. PLSPOSGLO(PLSINTPAD(),__aCdCri229[1],__aCdCri229[2])

			aCriReemb := {{__aCdCri229[1],__aCdCri229[2],""}}
			lOK := PLSMOVCRI("2",{},aCriReemb,.F.)
			aCodCri := aClone(aCriReemb[1])

		EndIf

	EndIf

	If lOK .And. ! lRPC .And. lAtuGets .AND. ! Empty(cAliasAux)

		&("M->"+cAliasAux+"_USUARI") := aDadUsr[2]
		&("M->"+cAliasAux+"_NOMUSR") := aDadUsr[6]
		&("M->"+cAliasAux+"_TIPUSR") := aDadUsr[43]
		&("M->"+cAliasAux+"_MATUSA") := cTipoMat

		If Empty(BA1->BA1_MATANT) .And. Len(aDadUsr)> 2
			&("M->"+cAliasAux+"_MATANT") := aDadUsr[3] 
		Else
			&("M->"+cAliasAux+"_MATANT") := BA1->BA1_MATANT
		EndIf

		&("M->"+cAliasAux+"_CODPLA") := BI3->BI3_CODIGO
		&("M->"+cAliasAux+"_DESPLA") := BI3->BI3_DESCRI
		&("M->"+cAliasAux+"_VIACAR") := BA1->BA1_VIACAR
		&("M->"+cAliasAux+"_OPERDA") := BA1->BA1_CODINT
		&("M->"+cAliasAux+"_OPESOL") := BA1->BA1_CODINT
		&("M->"+cAliasAux+"_OPEEXE") := BA1->BA1_CODINT

		If !Empty(BA1->BA1_CODINT)
			&("M->"+cAliasAux+"_OPERDA") := BA1->BA1_CODINT
			&("M->"+cAliasAux+"_OPESOL") := BA1->BA1_CODINT
			&("M->"+cAliasAux+"_OPEEXE") := BA1->BA1_CODINT 
		EndIf 

		If cAliasAux $ "BE4"
			&("M->"+cAliasAux+"_DATNAS") := BA1->BA1_DATNAS
		EndIf

		if cAliasAux == 'BOW' .And. lInc

			aCliente := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),;
			BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,nil,BA1->BA1_TIPREG,.F.)

			If aCliente[1,1] <> "ZZZZZZ"
				M->BOW_CODCLI := aCliente[1][1]
				M->BOW_LOJA   := aCliente[1][2]
				M->BOW_NOMCLI := aCliente[1][3]
			EndIf

		EndIf
		
		cAliNomSoc := iif(cAliasAux=="BE1","BEA",cAliasAux) 
		if &( cAliNomSoc+"->( FieldPos('"+cAliNomSoc+"_NOMSOC') )" ) > 0
			&("M->"+cAliasAux+"_NOMSOC") := BA1->BA1_NOMSOC
		endIf

		lRefresh := .T.

	Endif

Endif

//Se for usuario VIP exibe mensagem...                                    

If ! lRPC .And. BA1->BA1_USRVIP == "1"

	Aviso( STR0069, ; 	//"Usuario VIP"
	STR0070,; 	//"Este usuario e VIP!!!"
	{ STR0146 }, 2 )

Endif

If lOK .And. ! lRPC .And. ! Empty(BA1->BA1_MOTBLO) .and. BA1->BA1_DATBLO+nDiasBloq > dData .and. cLocalExec == "1"

	//"Usuario"  "Este usuario somente podera utilizar o plano, conforme bloqueio pre-determinado, ate o dia ######"
	If nDiasBloq == 0
		Aviso( STR0071, STR0072+dtoc(BA1->BA1_DATBLO), { STR0146 }, 2 )

		If 	M->BE1_VALSEN > BA1->BA1_DATBLO
			M->BE1_VALSEN := BA1->BA1_DATBLO
		endif	
	
	Else
		Aviso( STR0071, STR0072+dtoc(BA1->BA1_DATBLO) +". "+ STR0405  +" "+  dtoc(BA1->BA1_DATBLO+nDiasBloq) + ".", { STR0146 }, 2 )
	EndIf

	lBloqu := .T.

Endif

//Valida se usuario est· internado 
BE4->(DbSetOrder(18))//BE4_FILIAL, BE4_OPERDA, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO, BE4_CODRDA, BE4_DATPRO
lRetInt := !BE4->(MsSeek(xFilial("BE4")+cMatric))
If ! lRetInt .And. !EMPTY(BE4->BE4_DATPRO) .And. EMPTY(BE4->BE4_DTALTA) .and. lBloqu .and. BE4->BE4_TIPGUI == G_SOL_INTER 
	lIntGui:=.T.
Else
	lIntGui:=.F.
Endif

restArea(aArea498)

If getNewPar("MV_BIOCONF",.F.) .And. lAtuGets .And.;
("PLSA315" $ UPPER( Alltrim( Funname() ) ) .OR. "TMKA271" $ UPPER( Alltrim( Funname() ) ) .OR.;
(UPPER(Alltrim( Funname() ) ) $ "PLSA094B,PLSA094A,PLSA094C,PLSA094D,PLS090O" .AND. getNewPar("MV_BIOATEN",.F.)) .OR.;
(UPPER(Alltrim( Funname() ) ) $ "PLSA092" .AND. getNewPar("MV_BIOGIH",.F.) ) ) .And.;
(!"PLSA300" $ UPPER( Alltrim( Funname() ) ) .AND. !IsInCallStack("PLSA300PUS") .And. !IsInCallStack("PLVISGUI")) .And. lInc .And. lOK

	lRetBio := PLSBIOMET("BTS",BA1->BA1_MATVID,.T.,"2")

	If !lRetBio

		Return(lRetBio)

	EndIf

EndIf

If lOk .And. Empty(__cOpePad)
	__cOpePad := BA1->BA1_CODINT
Endif

If lOk
	If getNewPar("MV_VLDREGI","0") == "1"
		lOk:= PLSTrtReg({},{},{},{},BA1->BA1_MATVID)
	EndIf
EndIf

//Valida regras de segmentacao do produto		 
If BI6->(FieldPos("BI6_MEDICO")) > 0 .And. BI6->(FieldPos("BI6_ODONTO")) > 0

	If Len(aDadUsr) == 0
		aDadUsr := PLSGETUSR()
	Endif

	If Len(aDadUsr) ==0
		Return(IF(!lRPC,lOK,{lOK,aCodCri,lForcou,cTipoMat, .T.}))
	Endif

	cProdUsu 	:= aDadUsr[11]
	cVersaoPrd 	:= aDadUsr[12]
	cOprda		:= Subs(cMatric, 1, 4)

	DbSelectArea("BI3")
	DbSetOrder(1)

	If dbSeek(xFilial("BI3")+substr(cMatric,1, Len(BA1->BA1_CODINT) )+cProdUsu+cVersaoPrd) .Or. (lUnimeds .And. dbSeek(xFilial("BI3")+__cOpePad+cProdUsu+cVersaoPrd))

		DbSelectArea("BI6")
		DbSetOrder(1)

		If dbSeek(xFilial("BI6")+BI3->BI3_CODSEG)
			If FunName() $ "PLSA094C/PLSA094D"

				//Valida se o cliente possui o produto Odontologico, para continuar com o atendimento 
				If BI6->BI6_ODONTO == "0"

					DbSelectArea("BF4")
					DbSetOrder(1)

					If	dbSeek(xFilial("BF4")+SUBS(cMatric, 1, 16))
						WHILE !BF4->(Eof()) .AND. xFilial("BF4")+BF4->BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG == xFilial("BF4")+;
						SUBS(cMatric, 1, 16)

							DbSelectArea("BI3")
							DbSetOrder(1)

							If dbSeek(xFilial("BI3")+BF4->BF4_CODINT+BF4->BF4_CODPRO+BF4->BF4_VERSAO)
								WHILE !BI3->(Eof()) .AND. xFilial("BI3")+BI3->BI3_CODINT+BI3_CODIGO+BI3_VERSAO == xFilial("BI3")+;
								BF4->BF4_CODINT+BF4->BF4_CODPRO+BF4->BF4_VERSAO

									DbSelectArea("BI6")
									DbSetOrder(1)

									If dbSeek(xFilial("BI6")+BI3->BI3_CODSEG)
										If BI6->BI6_ODONTO != "0" .AND. !Empty(BI6->BI6_ODONTO)
											lPosOdont := .T.
											EXIT
										ElseIf Empty(BI6->BI6_ODONTO)
											Help("",1,"PL315VLD")
											Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
										EndIf
									EndIf
									BI6->(DbSkip())
									BI3->(DbSkip())
								EndDo
							EndIf

							BF4->(DbSkip())

							If lPosOdont
								EXIT
							EndIf
						EndDo
					EndIf

					If !lPosOdont
						Help("",1,"PL316VLD")
						Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
					EndIf
				ElseIf Empty(BI6->BI6_ODONTO)
					Help("",1,"PL315VLD")
					Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
				EndIf
			ElseIf FunName() $ "PLSA094A/PLSA094B"

				//Valida se o cliente possui o produto Medicina, para continuar com o atendimento     
				If BI6->BI6_MEDICO == "0"

					DbSelectArea("BF4")
					DbSetOrder(1)

					If	dbSeek(xFilial("BF4")+SUBS(cMatric, 1, 16))
						WHILE !BF4->(Eof()) .AND. xFilial("BF4")+BF4->BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG == xFilial("BF4")+;
						SUBS(cMatric, 1, 16)

							DbSelectArea("BI3")
							DbSetOrder(1)

							If dbSeek(xFilial("BI3")+BF4->BF4_CODINT+BF4->BF4_CODPRO+BF4->BF4_VERSAO)
								WHILE !BI3->(Eof()) .AND. xFilial("BI3")+BI3->BI3_CODINT+BI3_CODIGO+BI3_VERSAO == xFilial("BI3")+;
								BF4->BF4_CODINT+BF4->BF4_CODPRO+BF4->BF4_VERSAO

									DbSelectArea("BI6")
									DbSetOrder(1)

									If dbSeek(xFilial("BI6")+BI3->BI3_CODSEG)
										If BI6->BI6_MEDICO != "0" .AND. !Empty(BI6->BI6_MEDICO)
											lPosMedic := .T.
											EXIT
										ElseIf Empty(BI6->BI6_MEDICO)
											Help("",1,"PL319VLD")
											Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
										EndIf
									EndIf

									BI6->(DbSkip())
									BI3->(DbSkip())
								EndDo
							EndIf

							BF4->(DbSkip())

							If lPosMedic
								EXIT
							EndIf
						EndDo
					EndIf
					If !lPosMedic
						Help("",1,"PL320VLD")
						Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
					EndIf
				ElseIf Empty(BI6->BI6_MEDICO)
					Help("",1,"PL319VLD")
					Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat, .F.}))
				EndIf
			Else

				//Valida se o cliente possui o produto Medicina ou Odonto, para continuar com o atendimento     

				If BI6->BI6_MEDICO == "0" .And. BI6->BI6_ODONTO == "0"

					DbSelectArea("BF4")
					DbSetOrder(1)

					If	dbSeek(xFilial("BF4")+SUBS(cMatric, 1, 16))
						WHILE !BF4->(Eof()) .AND. xFilial("BF4")+BF4->BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG == xFilial("BF4")+;
						SUBS(cMatric, 1, 16)

							DbSelectArea("BI3")
							DbSetOrder(1)

							If dbSeek(xFilial("BI3")+BF4->BF4_CODINT+BF4->BF4_CODPRO+BF4->BF4_VERSAO)
								WHILE !BI3->(Eof()) .AND. xFilial("BI3")+BI3->BI3_CODINT+BI3_CODIGO+BI3_VERSAO == xFilial("BI3")+;
								BF4->BF4_CODINT+BF4->BF4_CODPRO+BF4->BF4_VERSAO

									DbSelectArea("BI6")
									DbSetOrder(1)

									If dbSeek(xFilial("BI6")+BI3->BI3_CODSEG)
										If (BI6->BI6_MEDICO != "0" .AND. !Empty(BI6->BI6_MEDICO)) .Or. (BI6->BI6_ODONTO != "0" .AND. !Empty(BI6->BI6_ODONTO))
											lRetSeg := .T.
											EXIT
										ElseIf Empty(BI6->BI6_MEDICO) .And. Empty(BI6->BI6_ODONTO)
											Help("",1,"PL498SEG01")
											Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
										EndIf
									EndIf

									BI6->(DbSkip())
									BI3->(DbSkip())
								EndDo
							EndIf

							BF4->(DbSkip())

							If lRetSeg
								EXIT
							EndIf
						EndDo
					EndIf
					If !lRetSeg
						Help("",1,"PL498SEG02")
						Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
					EndIf
				ElseIf Empty(BI6->BI6_MEDICO) .And. Empty(BI6->BI6_ODONTO)
					Help("",1,"PL498SEG01")
					Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat, .F.}))
				EndIf
			Endif
			//Valida se o segmento informado no produto e valido  
		Else
			Help("",1,"PL317VLD")
			Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
		EndIf
	Else
		Help("",1,"PL318VLD")
		Return(IF(!lRPC,.F.,{lOK,aCodCri,lForcou,cTipoMat,.F.}))
	EndIf
Endif

//Valida se usuario est· bloqueado e internado, para pacientes internados È permitido a liberaÁ„o Atendimento
If ! Empty(BA1->BA1_MOTBLO) .and.  dData>=BA1->BA1_DATBLO+nDiasBloq  .and. (cLocalExec == "1" .or. cLocalExec="") .and. (cTipAtd $ "2,4" .OR. (cTipAtd="" .AND. ( cAliasAux $ "BE1,B01,B44,BOW,B45,B1N"))) 
	aAreaBE4 := GetArea()
	BE4->(DbSetOrder(18))//BE4_FILIAL, BE4_OPERDA, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO, BE4_CODRDA, BE4_DATPRO
	IF BE4->(dbSeek(xFilial("BE4")+cMatric))
		While !BE4->(Eof()) .AND.  BE4->(BE4_FILIAL+BE4_OPERDA+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)== xFilial("BE4") +  cMatric
			IF (EMPTY(BE4->BE4_DTALTA) .OR. cAliasAux $ "BOW,B1N" )  .And. !EMPTY(BE4->BE4_DATPRO) .and. BE4->BE4_TIPGUI == G_SOL_INTER // Permite Protocolo Reembolso
				If   lRPC
					If nDiasBloq == 0
						cMsn:= STR0072+dtoc(BA1->BA1_DATBLO) + ". "+ STR0574 //"Este utilizador apenas poder· utilizar o plano conforme bloqueio prÈ-determinado, atÈ ao dia "
					Else
						cMsn:= STR0072+dtoc(BA1->BA1_DATBLO) +". "+ STR0405  +" "+  dtoc(BA1->BA1_DATBLO+nDiasBloq) + ". " + STR0574 //"Este utilizador apenas poder· utilizar o plano conforme bloqueio prÈ-determinado, atÈ ao dia "
					EndIf
				EndIf
				If lDesInt
					lOK:=.F.  //Mesmo estando internado, o sistema deve criticar
					lIntGui:=.F.
					if lRPC
						aCodCri := {}
						PLSPOSGLO(PLSINTPAD(),__aCdCri240[1],__aCdCri240[2])
						aadd(aCodCri,{__aCdCri240[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{""   ,STR0655,dtoc(BA1->BA1_DATBLO),"","",cCodPad,cCodPro}) //"Data de bloqueio"
						if nDiasBloq <> 0
							aadd(aCodCri,{""   ,STR0405,dtoc(BA1->BA1_DATBLO+nDiasBloq),"","",cCodPad,cCodPro}) //"RestriÁ„o a partir de"
						endIf	
					endIf
				Else
					lOK:=.T.  //N„o poder· Bloquear lanÁamento de SADT para pacientes Internados e bloqueados
					lIntGui:=.T.
				EndIf
				If lOK .And. ! lRPC .And. lAtuGets .AND. !Empty(cAliasAux)
					&("M->"+cAliasAux+"_USUARI") := aDadUsr[2]
					&("M->"+cAliasAux+"_NOMUSR") := aDadUsr[6]
					&("M->"+cAliasAux+"_TIPUSR") := aDadUsr[43]
					&("M->"+cAliasAux+"_MATUSA") := cTipoMat
					If Empty(BA1->BA1_MATANT) .And. Len(aDadUsr)> 2
						&("M->"+cAliasAux+"_MATANT") := aDadUsr[3] 
					Else
						&("M->"+cAliasAux+"_MATANT") := BA1->BA1_MATANT
					EndIf 
					&("M->"+cAliasAux+"_CODPLA") := BI3->BI3_CODIGO
					&("M->"+cAliasAux+"_DESPLA") := BI3->BI3_DESCRI
					&("M->"+cAliasAux+"_VIACAR") := BA1->BA1_VIACAR
					&("M->"+cAliasAux+"_OPERDA") := BA1->BA1_CODINT
					&("M->"+cAliasAux+"_OPESOL") := BA1->BA1_CODINT
					&("M->"+cAliasAux+"_OPEEXE") := BA1->BA1_CODINT
					If !Empty(BA1->BA1_CODINT)
						&("M->"+cAliasAux+"_OPERDA") := BA1->BA1_CODINT
						&("M->"+cAliasAux+"_OPESOL") := BA1->BA1_CODINT
						&("M->"+cAliasAux+"_OPEEXE") := BA1->BA1_CODINT 
					EndIf 
					If cAliasAux $ "BE4"
						&("M->"+cAliasAux+"_DATNAS") := BA1->BA1_DATNAS
					EndIf
					If cAliasAux $ "BOW" .And. lInc
						aCliente := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),;
						BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,nil,BA1->BA1_TIPREG,.F.)

						If aCliente[1,1] <> "ZZZZZZ"
							M->BOW_CODCLI := aCliente[1][1]
							M->BOW_LOJA   := aCliente[1][2]
							M->BOW_NOMCLI := aCliente[1][3]
						EndIf


					Endif	

				Endif

				Exit
			Else
				lIntGui:=.F.
				BE4->(dbSkip())
				loop
			Endif
			RestArea(aAreaBE4)
		Enddo
	Endif
Else
	lIntGui:=.F.	
Endif
If ValType(lBloqGui) == 'L'  .AND. ! Empty(BA1->BA1_MOTBLO) .and.  dData>=BA1->BA1_DATBLO+nDiasBloq
	If lBloqGui
		lOK:=.T.  //DigitaÁ„o de contas
		lIntGui:=.T.
		cMsn:="Paciente encontra-se Bloqueado"
		Endif
	endif	

Return(IF(!lRPC,lOK,{lOK,aCodCri,lForcou,cTipoMat, .T.,lIntGui,cMsn}))

//-------------------------------------------------------------------
/*/{Protheus.doc} A090Clr
Limpa itens da autorizacao/liberacao  

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//------------------------------------------------------------------- 
Function A090Clr(cAlias,oBrowse)
	LOCAL cCampo
	If ValType(oBrowse) == "O"
	If &( cAlias+"->( FieldPos('"+cAlias+"_CODPRO') )" ) > 0
		cCampo := cAlias+"_CODPRO"
			If ! Empty(oBrowse:aCols[1,PLRETPOS(cCampo,oBrowse:aHeader)])
				Store COLS Blank cAlias TO oBrowse:aCols FROM oBrowse:aHeader
			Endif
		Else
			Store COLS Blank cAlias TO oBrowse:aCols FROM oBrowse:aHeader
		EndIf
		oBrowse:SetPos(1)
		oBrowse:Atualiza()
		oBrowse:ForceRefresh()
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090RDA
Validacao da Rede de Atendimento na Autorizacao/Liberacao  

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//------------------------------------------------------------------- 
Function PLSA090RDA(cOpeRda,cCodRDA,cTipo,dData,cMatrUsr,cCodLoc,cCodEsp,cAliasAux,lMsgCri,cCodPad,cCodPro,lRPC,lLoadRda,_cTipo,oBrwPro,oBrwCri,cNaoUsado,nModule,lProrInt) 
	LOCAL nI		 := 0
	LOCAL nFor		 := 0
	LOCAL cLocal	 := ""
LOCAL cNumLib	 := ""
LOCAL lOK		 := .f.
lOCAL lPLRDA     := .t.
LOCAL lForcar 	 := .f.
LOCAL aRetFun	 := {}
LOCAL aDadRda	 := {}
LOCAL aCodCri    := {}
LOCAL aDadUsr    := PLSGETUSR()
LOCAL aRetExec	 := {}
LOCAL aCriGer	 := {}
LOCAL aRetVldRda := {}
LOCAL loBrwEven	 := Type("oBrwEven") != "U"

DEFAULT cCodPad  := ""
DEFAULT cCodPro  := ""
DEFAULT _cTipo	 := __cTipo
DEFAULT cNaoUsado:= ""
DEFAULT lMsgCri  := .T.
DEFAULT lRPC     := .F.
DEFAULT lLoadRda := .F.
DEFAULT oBrwPro  := GetBrowseItem()
DEFAULT oBrwCri  := GetBrowseCri()
DEFAULT nModule  := 0 
DEFAULT lProrInt := .F.

//Testa se foi informado o aDadUsr...                                     
//nModule -  vari·vel utilizada para que n„o faÁa a validaÁ„o do aDadUsr 
//caso a funÁ„o esteja sendo chamada de determinado modulo contido no nModule
If Len(aDadUsr) == 0 .And. __cTipo == "1" .And. _cTipo == "1" .And. nModulo != nModule 
	If ! lRPC.And. nModulo != 13
		Help("",1,"PLSA090IUS")  
		Return(.F.)
	Else
		Return({.F.,aCodCri})
	Endif
Endif

//Se esta tentando informar outra rda eu zero o local e especialidade     

If (! lRPC ) .And. (type("M->"+cAliasAux+"_CODRDA") <> "C" .Or. &("M->"+cAliasAux+"_CODRDA") <> cCodRda)
	cCodLoc := CriaVar(cAliasAux+"_CODLOC")
	cCodLoc := Subs(cCodLoc,1,3)
	cCodEsp := CriaVar(cAliasAux+"_CODESP")
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
//Busca dados da Rda...
aRetFun	:= PLSDADRDA(cOpeRda,cCodRda,cTipo,dData,Subs(cCodLoc,1,3),cCodEsp,cCodPad,cCodPro,,lLoadRda,,,,lProrInt)
lOK			:= aRetFun[1]

//Caso o usuario seja valido limpa os dados...                            

If lOK

	//Inicia uma serie de gatilhos...                                         

	aDadRDA := PLSGETRDA()
	If ! lRPC
		&("M->"+cAliasAux+"_CODRDA") := aDadRDA[2]
		&("M->"+cAliasAux+"_NOMRDA") := aDadRDA[6]
		&("M->"+cAliasAux+"_CODLOC") := aDadRda[18]
		&("M->"+cAliasAux+"_DESLOC") := aDadRda[19]
		&("M->"+cAliasAux+"_ENDLOC") := aDadRda[20]
		&("M->"+cAliasAux+"_CODESP") := aDadRda[15]
		&("M->"+cAliasAux+"_DESESP") := aDadRda[17]
		&("M->"+cAliasAux+"_TIPPRE") := aDadRda[27]

		If aDadRda[23] == "1" // obrigatorio corpo clinico
			BC1->(DbSetOrder(1))
			If BC1->(MsSeek(xFilial("BC1")+cCodRda+cCodLoc+cCodEsp))
				BC1->(DbSkip())
				If BC1->(BC1_FILIAL+BC1_CODIGO+BC1_CODLOC+BC1_CODESP) <> xFilial("BC1")+cCodRda+cCodLoc+cCodEsp
					BC1->(DbSkip(-1))

					If BC1->(FieldPos("BC1_DATBLO")) > 0
						If Empty(BC1->BC1_DATBLO) .Or. BC1->BC1_DATBLO > dData

							BB0->(DbSetOrder(1))
							If BB0->(MsSeek(xFilial("BB0")+BC1->BC1_CODPRF))
								&("M->"+cAliasAux+"_REGEXE") := BB0->BB0_NUMCR
								&("M->"+cAliasAux+"_NOMEXE") := BB0->BB0_NOME
								&("M->"+cAliasAux+"_CDPFRE") := BC1->BC1_CODPRF
								&("M->"+cAliasAux+"_ESTEXE") := BB0->BB0_ESTADO
							Endif
						EndIf
					Else
						BB0->(DbSetOrder(1))
						If BB0->(MsSeek(xFilial("BB0")+BC1->BC1_CODPRF))
							&("M->"+cAliasAux+"_REGEXE") := BB0->BB0_NUMCR
							&("M->"+cAliasAux+"_NOMEXE") := BB0->BB0_NOME
							&("M->"+cAliasAux+"_CDPFRE") := BC1->BC1_CODPRF
							&("M->"+cAliasAux+"_ESTEXE") := BB0->BB0_ESTADO
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif

	lRefresh := .T.

	aRetVldRda  := PLSVLDRDA("1",cCodPad,cCodPro,,,cAliasAux,BEA->BEA_TIPGUI, IIf(Type("M->BE1_NUMLIB") != "U", M->BE1_NUMLIB, ""))

	If !aRetVldRda[1]

		If lMsgCri .And. (Len(_aCopHCri) == 0 .Or. ReadVar() == "M->"+cAliasAux+"_CODRDA")

			BCT->(dbSetOrder(1))
			BCT->(dbSeek(xFilial("BCT")+PlsIntPad()+aRetVldRda[2,1,1]))

			If PLSMOVCRI("3",{},aRetVldRda[2],Iif(BCT->BCT_PERFOR == "1",.T.,.F.),"",Iif(BCT->BCT_AUDITO == "1",.T.,.F.))
				lOK := .T.
				aAdd(aAutFor,{.T.,"","","","","","",0,BCS->(RetCodUsr()),Date(),Time(),aRetVldRda[2][1][9],aRetVldRda[2][1][10],""})
			Else
				// MV_PLSCABC ativo, indica que as criticas de cabeÁalho n„o v„o impedir a gravaÁ„o da Guia          
				lOK := IIF(GetNewPar("MV_PLSCABC","0") == "1",.T.,.F.)
				If Len(_aCopHCri) > 0
					_aCopHCri := {}
				EndIf
			EndIf

		Else
			If aScan(aRetVldRda[2],{|x| x[1] == BCT->(BCT_PROPRI+BCT_CODGLO)}) > 0
				aRetVldRda[1] := .T.
				lOK := .T.
			Else
				lOK := .F.
			EndIf
		EndIf
		If lRPC .And. !aRetVldRda[1]
			aCodCri := aClone(aRetVldRda[2])
		Endif
	Else
		lOK := .T.

		//Caso for aproveitando de uma liberacao verifica se a rda pode executar  

		If __cTipo == "1" .And. Type("M->"+cAliasAux+"_NUMLIB") == "C" .And. !Empty( (&("M->"+cAliasAux+"_NUMLIB")) ) .And.;
		ValType(oBrwPro) == "O" .And. ValType(oBrwCri) == "O" .And. Len(aDadUsr) > 0 .And. Len(aDadRda) > 0

			For nFor := 1 To Len(oBrwPro:aCols)
				//pega o aCodCri
				aOldCodCri  := PLLimpCCri(.F.)
				If aOldCodCri == nil
					aOldCodCri  := {}
				Endif
				PLLimpCCri(.T.)

				aRetExec := PLSTratExe(oBrwPro:FieldGet("BE2_CODPAD",nFor),oBrwPro:FieldGet("BE2_CODPRO",nFor),.T.,.T.,.F.,"1","",nil,aDadRDA,aDadUsr,nil,&("M->"+cAliasAux+"_DATPRO"),NIL,NIL,NIL,cAliasAux)
				//limpa o a codCri
				PLLimpCCri(.F.,.T.,aOldCodCri)

				lPLRDA := aRetExec[1]

				If lPLRDA
					BR8->(DbSetOrder(1))
					BR8->(MsSeek(xFilial("BR8")+oBrwPro:FieldGet("BE2_CODPAD",nFor)+oBrwPro:FieldGet("BE2_CODPRO",nFor)))

					cCid := ''
					If VALTYPE("M->"+cAliasAux+"_CID") == "C" .And. !Empty( (&("M->"+cAliasAux+"_CID")) )
						cCid := &("M->"+cAliasAux+"_CID")
					Endif
					aRetExec := PLSVLDOCD(oBrwPro:FieldGet("BE2_CODPAD",nFor),;
					oBrwPro:FieldGet("BE2_CODPRO",nFor),;
					'1',;
					cCid,;
					oBrwPro:FieldGet("BE2_QTDPRO",nFor),;
					nil,nil,;
					'1','E',;
					NIL)
					lPLRDA := aRetExec[1]
				Endif

				If ValType(aRetExec) == "A" .And. Len(aRetExec) >= 1 .And. ValType(aRetExec[1]) == "L" .And. ! aRetExec[1] .And. (oBrwPro:FieldGet("BE2_STATUS",nFor) == "1")

					If lMsgCri
						PLSMOVCRI("3",{},aRetExec[2],nil,"Procedimento "+oBrwPro:FieldGet("BE2_CODPAD",nFor)+" - "+oBrwPro:FieldGet("BE2_CODPRO",nFor))
					Endif
					lOK := .F.
					If lRPC
						aCodCri := aClone(aRetExec[2])
					Endif

					oBrwPro:FieldPut("BE2_STATUS","0",nFor)
					oBrwPro:FieldPut("BE2_IMGSTA","DISABLE",nFor)
					PLSA090ACR(aDadCri,aCabCri,aTrbCri,aRetExec[2],oBrwCri,oBrwPro:FieldGet("BE2_SEQUEN",nFor),"BEG",oBrwPro)

				Endif

				If lPLRDA .And. oBrwPro:FieldGet("BE2_STATUS",nFor) == "0"
					oBrwPro:FieldPut("BE2_STATUS","1",nFor)
					oBrwPro:FieldPut("BE2_IMGSTA","ENABLE",nFor)

					If Len(oBrwCri:aCols)> 0
						nPosX := PlRetPos("BEG_SEQUEN",oBrwCri:aHeader)
						cSeqX := oBrwPro:FieldGet("BE2_SEQUEN",nFor)
						If nPosX > 0
							while (nI:=aScan(oBrwCri:aCols,{|x| x[nPosX] == cSeqX})) > 0
								nSize := Len(oBrwCri:aCols)
								aDel(oBrwCri:aCols,nI)
								aSize(oBrwCri:aCols,nSize-1)
							Enddo
							If len(oBrwCri:aCols) == 0
								Store COLS Blank "BEG" TO oBrwCri:aCols FROM oBrwCri:aHeader
							EndIf
						Else
							Store COLS Blank "BEG" TO oBrwCri:aCols FROM oBrwCri:aHeader
						Endif
						oBrwCri:SetPos(1)
						oBrwCri:Atualiza()
						oBrwCri:ForceRefresh()
						lOK :=.F.

					EndIf

					If loBrwEven .And. len(oBrwEven:aCols) > 0
						nPosX := PlRetPos("BYS_SEQUEN",oBrwEven:aHeader)
						cSeqX := oBrwPro:FieldGet("BE2_SEQUEN",nFor)
						If nPosX > 0
							while (nI:=aScan(oBrwEven:aCols,{|x| x[nPosX] == cSeqX})) > 0
								nSize := Len(oBrwEven:aCols)
								aDel(oBrwEven:aCols,nI)
								aSize(oBrwEven:aCols,nSize-1)
							Enddo
							If len(oBrwEven:aCols) == 0
								Store COLS Blank "BYS" TO oBrwEven:aCols FROM oBrwEven:aHeader
							EndIf
						Else
							Store COLS Blank "BYS" TO oBrwEven:aCols FROM oBrwEven:aHeader
						Endif

						If ValType(oBrwEven) != "U"
							oBrwEven:SetPos(1)
							oBrwEven:Atualiza()
							oBrwEven:ForceRefresh()
						EndIf

					EndIf

					If ValType(aRetExec[2])=="A"
						PLSA090ACR(aDadCri,aCabCri,aTrbCri,aRetExec[2],oBrwCri,oBrwPro:FieldGet("BE2_SEQUEN",nFor),"BEG",oBrwPro)
					Endif
				Else

					If Len(oBrwCri:aCols)> 0
						nPosX := PlRetPos("BEG_SEQUEN",oBrwCri:aHeader)
						cSeqX := oBrwPro:FieldGet("BE2_SEQUEN",nFor)
						If nPosX > 0
							while (nI:=aScan(oBrwCri:aCols,{|x| x[nPosX] == cSeqX})) > 0
								nSize := Len(oBrwCri:aCols)
								aDel(oBrwCri:aCols,nI)
								aSize(oBrwCri:aCols,nSize-1)
							Enddo
							If len(oBrwCri:aCols) == 0
								Store COLS Blank "BEG" TO oBrwCri:aCols FROM oBrwCri:aHeader
							EndIf
						Else
							Store COLS Blank "BEG" TO oBrwCri:aCols FROM oBrwCri:aHeader
						Endif

						If ValType(oBrwCri) != "U"
							oBrwCri:SetPos(1)
							oBrwCri:Atualiza()
							oBrwCri:ForceRefresh()
						EndIf

						lOK := .T.
					EndIf

					If loBrwEven .And. Len(oBrwEven:aCols)> 0
						nPosX := PlRetPos("BYS_SEQUEN",oBrwEven:aHeader)
						cSeqX := oBrwPro:FieldGet("BE2_SEQUEN",nFor)
						If nPosX > 0
							while (nI:=aScan(oBrwEven:aCols,{|x| x[nPosX] == cSeqX})) > 0
								nSize := Len(oBrwEven:aCols)
								aDel(oBrwEven:aCols,nI)
								aSize(oBrwEven:aCols,nSize-1)
							Enddo
							If len(oBrwEven:aCols) == 0
								Store COLS Blank "BYS" TO oBrwEven:aCols FROM oBrwEven:aHeader
							EndIf
						Else
							Store COLS Blank "BYS" TO oBrwEven:aCols FROM oBrwEven:aHeader
						Endif

						If ValType(oBrwEven) != "U"
							oBrwEven:SetPos(1)
							oBrwEven:Atualiza()
							oBrwEven:ForceRefresh()
						EndIf

					EndIf

					If ValType(aRetExec[2])=="A"
						PLSA090ACR(aDadCri,aCabCri,aTrbCri,aRetExec[2],oBrwCri,oBrwPro:FieldGet("BE2_SEQUEN",nFor),"BEG",oBrwPro)
					Endif

				Endif

			Next
			If FunName() != "PLSA094C" .Or. ValType(oBrwPro:oBrowse:oBrowse) != "U"
				oBrwPro:ForceRefresh()

				If ValType(oBrwCri) != "U"
					oBrwCri:Atualiza()
					oBrwCri:ForceRefresh()
				EndIf
			EndIf
		Endif
	Endif

Else
	If lMsgCri
		PLSMOVCRI("3",{},aRetFun[2])
		Endif
		lOK := .F.
		If lRPC
			aCodCri := aClone(aRetFun[2])
		Endif
		_aCopHCri := {}
		aRetFun := {}
	Endif

Return(If(!lRPC,lOK,{lOK,aCodCri}))

/*/{Protheus.doc} PLSBENEF
	Apenas executa o AxVisual, funÁ„o criada para geraÁ„o do log de Auditoria LGPD antes de mostrar a tela para o Usu·rio
	@type  Function
	@author David Juan
	@since 03/03/2020
	@version P12
	@see https://tdn.totvs.com/pages/viewpage.action?pageId=23889145
	/*/
Function PLSBENEF(cAlias,nReg,nOpc)
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

Return (AxVisual(cAlias,nReg,nOpc))

/*/{Protheus.doc} PLSA090BOT
Monta botoes e keys... 

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
Function PLSA090Bot(nOpc,cAliasEnc,oEncAut,oBrwPro,cAliasPro,bMatUsr,aButtons,oFolder,oDlg,oSay02,cDescri,oBrwCri,lBtnOn,cTrolComun,aDadB6M) 
	LOCAL lAnt		 := .f.
	LOCAL bBotao01   := {|| A090Limpa(cAliasEnc,oEncAut,oBrwPro,"BE2",,,.T.),PLS090RONL(.F.,oEncAut)}
LOCAL bBotao02   := {|| PLPOSFIN(Eval(bMatUsr),.T.,.T.) }
LOCAL bBotao03   := {|| PLHISMOV(Eval(bMatUsr)) }
LOCAL bBotao04   := {|| PLAltCli(Eval(bMatUsr), .T.) }
LOCAL bBotao05   := {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSVLRCOB(,,.T.),Help("",1,"PLSA090USR")) }
LOCAL bBotao06   := {|| lAnt := Inclui,Inclui := .F., BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSA260MOV("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")), Inclui := lAnt}
LOCAL bBotao07   := {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSBENEF("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")) }
LOCAL bBotao08   := {|| PLSA090ACO(cAliasEnc,oEncAut,oBrwCri,oBrwPro) }
LOCAL bBotao09   := {|| PLSA090CPR(cAliasEnc,oEncAut,oBrwCri,__cTipo,oBrwPro) }
LOCAL bBotao10   := {|| BA3->(DbSetOrder(1)), BA3->(MsSeek(xFilial("BA3")+Subs(&("M->"+cAliasEnc+"_USUARI"),1,14))), If(BA3->(Found()),ExeQuest(),Help("",1,"PLSA090QUE")) }
LOCAL bBotao13   := {|| PLSA096(SUBSTR(&("M->"+cAliasEnc+"_USUARI"),1,4),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),5,4),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),9,6),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),15,2),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),17,1)) }
LOCAL bBotao11   := {|| PLSMSGCA(Eval(bMatUsr)) }
LOCAL bBotao17   := {|| PLSA09AMTC(cAliasEnc,oEncAut,oBrwCri,__cTipo,oBrwPro, BEA->BEA_OPEMOV+BEA->BEA_ANOAUT+BEA->BEA_MESAUT+BEA->BEA_NUMAUT, BEA->(RECNO()), "BEA", Inclui) }
LOCAL bBotao18   := {|| MSGCOMINT(IIF(Inclui,{},),"2",nOpc,&("M->"+cAliasEnc+"_USUARI"),IIF(Inclui,"","BEA"),BEA->(RecNo()),@oGetBZC) }
LOCAL bBotao19   := {|| ComPTUOn(IIF(Inclui,"","BEA"))}
LOCAL aDadRda    := PLSGETRDA()
LOCAL aPTBot	 := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
LOCAL oBotao
LOCAL aPtoEntrB1
LOCAL aPtoEntrB2
LOCAL cCodCri
LOCAL J
LOCAL nTamArray
LOCAL lRn395     := GetNewPar("MV_PLRN395","0") == "1"
Local lNovInd    := GETNEWPAR("MV_PLSUNI","0") == "1" .And. PLSALIASEXI("BZC") .And. BZC->(FieldPos("BZC_CHVGUI")) > 0 .And. BZC->(FieldPos("BZC_ALIAS")) > 0 .And.  FindFunction('MSGCOMINT') 
Local lPTUOn80	 := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80" .And. PLSALIASEXI("B6M") 

DEFAULT cDescri  	:= __cDescri
DEFAULT lBtnOn  	:= .F.
DEFAULT cTrolComun 	:= ""
DEFAULT aDadB6M		:= {}

//Verifica																

If nOpc == K_Incluir
	aadd(aButtons,{"S4WB004N",bBotao01,STR0074,STR0075}) //"Limpar Tela - <F5>"###"Limpa"
	SetKey(VK_F5,bBotao01)
Endif

//Ponto de entrada para desabilitar BOTOES PARA um grupo de operadores	

If ExistBlock("PLSBUTOP")
	aPTBot := ExecBlock("PLSBUTOP",.F.,.F.,{"PLSA090"})
	nTamArray:= Len(aPTBot)
	If nTamArray < 16
		For j:=(nTamArray+1) to 16
			aadd(aPTBot,.T.)
		Next
	EndIf
EndIf

//Botoes																	

If aPTBot[1]
	aadd(aButtons,{"SALARIOS",bBotao02,STR0076,STR0077})  //"Posicao Financeira - <F6>"###"Financ"
	SetKey(VK_F6,bBotao02)
EndIf

If aPTBot[2]
	aadd(aButtons,{"POSCLI",bBotao04,STR0078,STR0079}) //"Alterar Dados do Cliente - <F8>"###"Cliente"
	SetKey(VK_F8,bBotao04)
EndIf

If aPTBot[3]
	aadd(aButtons,{"PLNPROP",bBotao05,STR0080,STR0081}) //"Composicao de Cobranca - <F9>"###"Cobranca"
	SetKey(VK_F9,bBotao05)
EndIf

If aPTBot[4]
	aadd(aButtons,{"GROUP",bBotao06,STR0082,STR0083}) //"Dados da Familia - <F10>"###"Familia"
	SetKey(VK_F10,bBotao06)
EndIf

If aPTBot[5]
	aadd(aButtons,{"RELATORIO",bBotao03,STR0084,STR0085}) //"Historico de Movimentacao - <F7>"###"Historico"
	SetKey(VK_F7,bBotao03)
EndIf

If aPTBot[6]
	aadd(aButtons,{"RESPONSA",bBotao07,STR0086,STR0087}) //"Dados da vida do beneficiario - <F11>"###"Benef."
	SetKey(VK_F11,bBotao07)
EndIf

If aPTBot[7]
	aadd(aButtons,{"S4WB006N",bBotao09,STR0088,STR0089}) //"Comprar Procedimento"###"Comprar"
EndIf

If aPTBot[8]
	aadd(aButtons,{"S4WB007N",{ || A090INTGER(cAliasEnc) },STR0090,STR0091}) //"Usuarios de Outros Intercambios"###"Usuarios"
EndIf

If aPTBot[9]
	aadd(aButtons,{"S4WB008N",{ || A090VlrCPP(cAliasEnc,__cTipo,oEncAut,oBrwCri,oBrwPro) },STR0092,STR0093}) //"Consultar Valor de Co-Participacao/Fator Moderador"###"Co-Part."
EndIf

If aPTBot[10]
	aadd(aButtons,{"S4WB009N",{ || A090MovPOS() },STR0094,STR0095}) //"Consultar Movimentacoes Negadas em POS/Internet/Outros"###"Mov.Neg."
EndIf

//************************
If aPTBot[17]
	aadd(aButtons,{"S4WB019N",bBotao17,"",STR0550}) //"Motivo NegaÁ„o"
EndIf

If GetNewPar("MV_PLSMODA","1") == "0"
	aadd(aButtons,{"S4WB007N",{ || lOK := Pergunte("PLS090",.T.), IF(lOK,cCodLocPar := mv_par01,nil), IF(lOK,A090Limpa(cAliasEnc,oEncAut,oBrwPro,"BE2",.F.,.F.),nil) , If(lOK,PLSA090ATP(cAliasPro,cAliasEnc,oEncAut,cCodLocPar,.F.),nil), lRefresh := .T.,oEncAut:oBox:Refresh(),oEncAut:oBox:SetFocus() },STR0096,STR0097  } ) //"Trocar Local de Atendimento"###"Local"
Endif

If nOpc == K_Incluir .And. !UPPER( Alltrim( FunName() ) ) $ "PLSA094C,PLSA094D"
	aadd(aButtons,{"S4WB005N",bBotao08,cDescri+STR0098,STR0099}) //" Consulta - <F12>"###"Consulta"
	SetKey(VK_F12,bBotao08)
Endif

//Botao Hist Criticas Forcadas											

If nOpc == K_Visualizar
	aadd(aButtons,{"S4WB010N",{ || PLS090FOR("BEA","BE2",oBrwPro) },"Hist. Criticas ForÁadas","Crit. ForÁadas"})
Endif


//Monta outros botoes de apoio...                                         

If aPTBot[11]
	@ 030,002 BTNBMP oBotao RESOURCE "VERNOTA" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0280 ACTION Eval(bBotao11) //"Grupo de carencia"###"GrupoCa"
Endif
If aPTBot[12]
	@ 065,002 BTNBMP oBotao RESOURCE "NOTE" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0100 ACTION PLSRTGCUSR(&("M->"+cAliasEnc+"_USUARI")) //"Grupos de Cobertura"
Endif
If aPTBot[13]
	@ 100,002 BTNBMP oBotao RESOURCE "RELATORIO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0101 ACTION Eval(bBotao10) //"Visualizar Entrevista Qualificada do Usuario"
Endif
If aPTBot[14]
	@ 135,002 BTNBMP oBotao RESOURCE "RELACIONAMENTO_DIREITA" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0102 ACTION PLSCONRDA() //"Pesquisar Rede de Atendimento Por parametros"
Endif
nLin := 135

If FindFunction("PLSC005")

	If aPTBot[15]
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "S4WB016N" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0103 ACTION Eval( {||  BA1->(DbSetOrder(2)),PLSC005()} ) //"Consultar Cobertura/Carencia"
	Endif

Endif

If FindFunction("PL169HIST")
	If aPTBot[16]
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "HISTORIC" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0104 ACTION PL169HIST() //"Historico Transferencia"
	Endif
Endif

If ExistBlock("PLS090B1")
	aPtoEntrB1 := ExecBlock("PLS090B1",.F.,.F.)
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB1[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEntrB1[2] ACTION Eval(aPtoEntrB1[3])
Endif

If ExistBlock("PLS090B2")
	aPtoEntrB2 := ExecBlock("PLS090B2",.F.,.F.)
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB2[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEntrB2[2] ACTION Eval(aPtoEntrB2[3])
Endif

If ExistBlock("PLS090B3") .and. nOpc == K_Incluir
	cCodCri := ExecBlock("PLS090B3",.F.,.F.)
	BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
	If BCT->( MsSeek( xFilial( 'BCT' )+PLSINTPAD()+cCodCri )  )// Trocar o 701 pelo codigo da sua critica
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "AFASTAMENTO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0105 ACTION PL090CRINE(cCodCri) //"Negar AutorizaÁ„o"
	EndIf
Endif

If Type(cAliasEnc+"_COMUNI") <> "U" .And. Type(cAliasEnc+"_MSG04") <> "U" .And.;
Type(cAliasEnc+"_NRTROL") <> "U" .And. Type(cAliasEnc+"_VIACAR") <> "U" .And. GetNewPar("MV_PLSSOOL","1") == "1"

	If (nOpc == K_Incluir .Or. lBtnOn )
		If GetNewPar("MV_PTGLOBO","1") == "1"
			nLin += 35
			@ nLin,002 BTNBMP oBotao RESOURCE "WEB" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0106 ACTION PLSAUTREM(cAliasEnc,"BE2","BEG",oBrwPro,oBrwCri,nOpc,NIL,NIL,NIL,NIL,@cTrolComun,@aDadB6M) //"Efetuar conexao autorizador remoto"
		EndIf
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "POSCLI" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0416 ACTION PLSUSRPTUA() //"Consulta Dados Benefici·rio Online"
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "S4WB007N" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0417 ACTION PLSPREPTUA() //"Consulta Dados Prestador Online"
	ElseIf nOpc == K_Evolucao .And. BQV->( FieldPos("BQV_OLNAUD") ) > 0 .And. GetNewPar("MV_PTGLOBO","1") == "1"
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "WEB" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0072 ACTION PLSAUTREM(cAliasEnc,"BQV","BQZ",oBrwBQV090,oBrwBQZ090,nOpc,.F.,.T.,NIL,NIL,@cTrolComun,@aDadB6M) //"Efetuar conexao autorizador remoto"
	EndIf

EndIf

If getNewPar("MV_BIOCONF",.F.) .And. ("PLSA315" $ UPPER( Alltrim( Funname() ) ) .OR. getNewPar("MV_BIOATEN",.F.) )
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "OBJETIVO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0380 ACTION PL090BIO(cAliasEnc,.F.) //"Biometria"
EndIf

If lRn395
	If nOpc == K_Visualizar .And. cAliasEnc $ "BE1/B01" 
		cNumProto := BEA->BEA_PROATE
	EndIf
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "USER" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0578 ACTION P773AutInc(IIF(nOpc == K_Evolucao,"BQV",cAliasEnc),@cNumProto,iif(nOpc == K_Evolucao,@oBrwBQV090,NIL),NIL,.T.,nOpc) //"Protocolo de Atendimento"
EndIf     

If aPTBot[18] .And. lNovInd 
	aadd(aButtons,{"MSGCOMINT",bBotao18,STR0636,STR0636}) //Mensagens Complementares PTU
	Endif

If lPTUOn80
	aAdd(aButtons, {"ComPTUOn", bBotao19, "PTU Online", "PTU Online"})
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090FLD
Monta campos padroes para a getDados do Procedimentos... 

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//------------------------------------------------------------------- 
Function PLSA090Fld(cTipo,cTpTipo)

	LOCAL cCampos := "BE2_CODPAD,BE2_SEQUEN,BE2_NIVEL ,BE2_CODPRO,BE2_DESPRO,BE2_QTD   ,BE2_STATUS,"
cCampos += "BE2_QTDPRO,BE2_IMGSTA,BE2_NIVAUT,BE2_CHVNIV,BE2_NIVCRI,BE2_VLPGMA,BE2_AUDITO,BE2_VIA   ,"
cCampos += "BE2_PERVIA,BE2_PROCCI,BE2_CDPDRC,BE2_PROREL,BE2_PRPRRL,BE2_VLCOMP,BE2_LIBESP,BE2_PEREVC,"
cCampos += "BE2_VLRAPR,BE2_BLOCPA,BE2_BLOPAG,BE2_DNIVCR,BE2_DNIVAU,BE2_SOLREV,BE2_COMUNI,BE2_TRACON,BE2_NRAOPE, "
cCampos += "BE2_GUIACO,BE2_QUACOB,BE2_VALORI,BE2_CODAUD,BE2_PROPCT "

DEFAULT cTipo   := ""
DEFAULT cTpTipo := __cTipo

//Campos odontologico														

If cTipo == "3"
	cCampos := "BE2_CODPAD,BE2_SEQUEN,BE2_NIVEL ,BE2_CODPRO,BE2_DESPRO,BE2_QTD   ,BE2_STATUS,"
	cCampos += "BE2_QTDPRO,BE2_IMGSTA,BE2_NIVAUT,BE2_CHVNIV,BE2_NIVCRI,BE2_VLPGMA,BE2_AUDITO,"
	cCampos += "BE2_VLCOMP,BE2_LIBESP,BE2_DNIVCR,BE2_DNIVAU,BE2_PEREVC,BE2_DENREG,BE2_DESREG,"
	cCampos += "BE2_FADENT,BE2_VALORI,BE2_FACDES,BE2_CDPDRC,BE2_PROREL,BE2_PRPRRL,BE2_GUIACO,BE2_QUACOB,BE2_PROPCT,BE2_VLRAPR "

	If cTpTipo == "" .Or. cTpTipo == "1"
		cCampos += ",BE2_QTDSOL"
	EndIf
	If BE2->(FieldPos("BE2_SALDO")) > 0 .And. cTpTipo == "2"
		cCampos += ",BE2_SALDO,BE2_QTDSOL"
	EndIf
Else
	If cTipo == "" .Or. cTipo == "1"
		cCampos += ",BE2_QTDSOL, BE2_HORFIM, BE2_TECUTI"
	EndIf
	If BE2->(FieldPos("BE2_SALDO")) > 0 .And. cTipo == "2"
		cCampos += ",BE2_SALDO, BE2_QTDSOL"
	EndIf
	If BE2->(FieldPos("BE2_REGPAG")) > 0 .and. BE2->(FieldPos("BE2_REGCOB")) > 0
		cCampos += ",BE2_REGPAG, BE2_REGCOB"
	EndIf
	If BE2->(FieldPos("BE2_REFFED")) > 0
		cCampos += ",BE2_REFFED"
	EndIf
	If BE2->(FieldPos("BE2_CANEDI")) > 0
		cCampos += ",BE2_CANEDI"
	EndIf
	If BE2->(FieldPos("BE2_PACOTE")) > 0
		cCampos += ",BE2_PACOTE"
	EndIf
	If BE2->(FieldPos("BE2_REGANV")) > 0
		cCampos += ",BE2_REGANV"
	EndIf
	If BE2->(FieldPos("BE2_NRTROL")) > 0
		cCampos += ",BE2_NRTROL"
	EndIf                 
	If  GETNEWPAR("MV_PLSUNI","0") == "1" .And. BE2->(FieldPos("BE2_SEQPTU")) > 0
		cCampos += ",BE2_SEQPTU"
	EndIf
	If GetNewPar("MV_PLSUNI","0") == "1" .And. BE2->(FieldPos("BE2_CDPACO")) > 0
		cCampos += ",BE2_CDPACO"
	EndIf	
	If GetNewPar("MV_PLSUNI","0") == "1" .And. BE2->(FieldPos("BE2_DESPAC")) > 0
		cCampos += ",BE2_DESPAC"
	EndIf		
EndIf

If  ExistBlock("PL090FL1")
	cCampos += ","+ExecBlock("PL090FL1",.F.,.F.)
	EndIf

Return(cCampos)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090HEA
Monta a header padrao

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//------------------------------------------------------------------- 
Function PLSA090Hea(cTipo,cTpTipo,nOpc)
	LOCAL nPosPro     := 0 //Procedimento
LOCAL nPos     := 0
LOCAL cCampos  	:= PLSA090Fld(cTipo,cTpTipo)
LOCAL aCabProc 	:= {}

DEFAULT cTpTipo := __cTipo
DEFAULT nOpc	:= K_Visualizar

Store Header "BE2" TO aCabProc For ( alltrim(SX3->X3_CAMPO) $ cCampos )
//Quando for inclusao de uma liberacao o campo vai se chamar Qtd. Solicitada				
If ((cTipo == "2" .Or. cTpTipo == "2") .And. nOpc == K_Incluir) .or. /*bot„o copia com mesma funcionalidade de incluir*/ ((cTipo == "2" .Or. cTpTipo == "2") .And. nOpc == K_Copiar)
	nPosPro := ascan(aCabProc,{|x| x[2] == "BE2_QTDPRO"})
	nPosAut := ascan(aCabProc,{|x| x[2] == "BE2_QTDSOL"})

	If nPosPro > 0 .And. nPosAut > 0
		SX3->(DbSetOrder(2))
		SX3->(DbSeek("BE2_QTDSOL"))
		cDesQtdSol 		:= AllTrim(X3Titulo("BE2_QTDSOL"))
			cDesQtdAut 		:= AllTrim(aCabProc[nPosPro,1])

			aCabProc[nPosPro,1] 	:= cDesQtdSol
			aCabProc[nPosAut,1] 	:= cDesQtdAut
		Endif
	EndIf
Return(aCabProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090CLB
Monta aCols Blank padrao...

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//------------------------------------------------------------------- 
Function PLSA090ClB(aCabProc)
	LOCAL aDadProc := {}
	Store COLS Blank "BE2" TO aDadProc FROM aCabProc
Return(aDadProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090MDA
Monta dados de uma autorizacao (itens)

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//------------------------------------------------------------------- 
Function PLSA090MDa(cChave,cTipo,aCabProc,aTrbProc,aDadProc,lVisual)
	LOCAL aAux := {}
	LOCAL lRet := .T.
	Local nX			:= 0
	Local nPosSol	:= PlRetPos("BE2_QTDSOL",aCabProc)
Local nPosPro	:= PlRetPos("BE2_QTDPRO",aCabProc)
Local nPosSeq	:= PlRetPos("BE2_SEQUEN",aCabProc)
Local nPosPad	:= PlRetPos("BE2_CODPAD",aCabProc)
Local nPosEve	:= PlRetPos("BE2_CODPRO",aCabProc)
Local nPosSaldo := PlRetPos("BE2_SALDO" ,aCabProc) 
Local cChaSeq	:=	""
LOCAL cAliasTrb	:= ""

Default lVisual := .F.

BE2->(DbSetOrder(1))
BE2->(MsSeek(xFilial("BE2")+cChave))

STORE COLS "BE2" TO aAux FROM aCabProc VETTRAB aTrbProc While xFilial("BE2")+cChave == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)

If Len(aAux) == 0
	Help("",1,"PLS090ITEN")
	Return
	lRet := .F.
Endif

aDadProc := aClone(aAux)

//Atualizacao do valor do campo BE2_QTDSOL com os dados do campo BE2_QTDPRO
If __cTipo == "2" .And. nPosSeq > 0

	cAliasTrb :=GetNextAlias()

	BE2->(DbSetOrder(1))

	For nX = 1 to Len(aDadProc)

		cChaSeq := aDadProc[nX,nPosSeq]
		cCdPadT := aDadProc[nX,nPosPad] 
		cCdProT := aDadProc[nX,nPosEve]

		If BE2->(MsSeek(xFilial("BE2")+ cChave + cChaSeq)) .And. nPosSol > 0 .And. nPosPro > 0

			If BE2->BE2_QTDSOL == 0
				aDadProc[nX,nPosSol] := BE2->BE2_QTDPRO
			Else
				aDadProc[nX,nPosSol] := BE2->BE2_QTDSOL
			Endif

			BeginSql Alias cAliasTrb    
				SELECT SUM(BE2_QTDPRO) AS QTDPRO FROM %table:BE2% BE2
				WHERE BE2.BE2_FILIAL = %exp:xFilial("BE2")%  
					AND  BE2.BE2_NRLBOR = %exp:cChave% 
					AND  BE2.BE2_CODPAD = %exp:cCdPadT% 
					AND  BE2.BE2_CODPRO = %exp:cCdProT% 
					AND BE2.%notDel%
				Endsql	

				If (cAliasTrb)->( ! eof() )

					If aDadProc[nX,nPosPro] == 0 .OR. aDadProc[nX,nPosSaldo] == aDadProc[nX,nPosSol]
						aDadProc[nX,nPosPro] := IIF(!lVisual,(cAliasTrb)->QTDPRO,aDadProc[nX,nPosPro])  
					EndIf 

				Else	
					aDadProc[nX,nPosPro] :=0
				Endif           

				(cAliasTrb)->(DbCloseArea())

				nLibIni := BE2->(BE2_QTDSOL)

			EndIf

		Next nX

	EndIf

Return(lRet)

/*/{Protheus.doc} PLSA090GRV
Gravacao dos dados de uma autorizacao...

@author  PLS TEAM
@version P11
@since   14.05.02
/*/
Function PLSA090Grv(aColsITE,aHeaderITE,aDadBEA,nOpc,aVetTrab,aChaveGen,cMatric,dData,cHora,cMatUsa,cAnoPag,;
	cMesPag,cTipGui,lIntern,aDadCri,aCabCri,aTrbCri,lAutori,cTipoRotEsp,cCodLDP,lReanaliza,;
	cNaoUsado,cKey,lForBloq,lVeioComu,lNMudFase,cAliasIte,cAliasCri,lAjusta,lEvolu,aDadBE4,;
	lGerSenha,lWeb,aDadB43,aCabB43,aTrbB43,oBrwEven,lExcluiAte,oBrwB47,cAliasCab,lReembolso,oBrwB46,;
	oBrwB44,lIncNeg,cObsoleto,lSolicit,cTpGrv,aColsDF,aHeaderDF,aVetDF,aDaSenPro,lGuiHoRe,aMatBd6,;
	aMatCom,lResInt,cAliasCmp,lOdontoWeb,cNumLib,cArqImp,lEvoSadt,cSituac,lProtoc,aPartic,aColsB4B,;
	aHeaderB4B,aVetB4B,cNumLibOd,lRecGlo,lPTUOnSol,cObsEvo,nNrSeqTR,cSenhaOpe,cOpeSolPTU,cNewAut,;
	lPtuOnline,aCampCust,dValSen,lSUS,aArraySUS, lReembCriaBD5,lGuiAudit,oGetBZC,cTrolComun,aBQVPTUDif,strJsonB7B,aDadB6M,aItensB6L, cRdaExe) 
LOCAL nI         	:= 0
LOCAL I__f 			:= 0
LOCAL nFor        	:= 0
LOCAL nFor2    		:= 0
LOCAL nForH       	:= 0
LOCAL nForC       	:= 0
LOCAL nPos,nPos2 	:= 0
LOCAL cCpoAux    	:= ""
LOCAL cOpeMov    	:= ""
LOCAL cAnoAut    	:= ""
LOCAL cMesAut   	:= ""
LOCAL cNumAut		:= ""
LOCAL cFldTrbBEA 	:= ""
LOCAL cCodOpeG		:= ""
LOCAL cSQL        	:= ""
LOCAL aStrucBEA  	:= {}
LOCAL aItensGlo		:= {}
LOCAL bOpeMov    	:= { || IF(nOpc == K_Incluir ,BXF->(PLSINTPAD()),&(cAliasCab+"->"+cAliasCab+"_OPEMOV")   ) }
LOCAL bAnoAut    	:= { || IF(nOpc == K_Incluir,cAnoPag ,&(cAliasCab+"->"+cAliasCab+"_ANOAUT") ) }
LOCAL bMesAut    	:= { || IF(nOpc == K_Incluir,cMesPag ,&(cAliasCab+"->"+cAliasCab+"_MESAUT")) }
LOCAL bNumAut    	:= { || IF(nOpc == K_Incluir,PLNUMAUT(Eval(bOpeMov),Eval(bAnoAut),Eval(bMesAut)),&(cAliasCab+"->"+cAliasCab+"_NUMAUT")) }
LOCAL aCpoChv    	:= { "BEA_FILIAL","BEA_OPEMOV","BEA_ANOAUT","BEA_MESAUT","BEA_NUMAUT","BE4_CODOPE","BE4_ANOINT","BE4_MESINT","BE4_NUMINT","BE4_ANOAUT","BE4_MESAUT","BE4_NUMAUT" }
LOCAL cCodEmp    	:= subs(cMatric,atCodEmp[1],atCodEmp[2])
LOCAL cMatrUs    	:= subs(cMatric,atMatric[1],atMatric[2])
LOCAL cTipReg    	:= subs(cMatric,atTipReg[1],atTipReg[2])
LOCAL lGuiaPri   	:= .F.
LOCAL lAut       	:= .F.
LOCAL lRet			:= .T.
LOCAL lPartic		:= .F.
LOCAL aRetMF     	:= {}
LOCAL cStatus    	:= ""
LOCAL cCancelada	:= ""
LOCAL nItensAut  	:= 0
LOCAL nItensNeg  	:= 0
LOCAL nAuditAut  	:= 0
LOCAL nAuditNeg  	:= 0
LOCAL lAuditoria 	:= .F.
LOCAL aRetASE1   	:= {}
LOCAL aArea		 	:= {}
LOCAL aVetTemp      := {}
LOCAL aMatAlias     := {}
LOCAL cChvSE1		:= ""
LOCAL cChaveAut 	:= ""
LOCAL cChaveGui 	:= ""
LOCAL nVlrPag  		:= 0
LOCAL cConEmp  		:= ""
LOCAL cVerCon  		:= ""
LOCAL cSubCon  		:= ""
LOCAL cVerSub  		:= ""
LOCAL cChavSE1		:= ""
LOCAL lPlNumPr      := getNewPar("MV_PLNUMPR","0") == "1"
LOCAL lMudarFase	:= .F.
LOCAL nH1 			:= 0
LOCAL nH0 			:= 0
LOCAL cAliasPri		:= ""
LOCAL cCodTes       := ""
LOCAL cCodSB1       := ""
LOCAL aVlrAuxPAG    := {}
LOCAL cCodEvePAG    := ""
LOCAL cParcTit      := ""
LOCAL lTitGer       := .T.
LOCAL lJaMudou      := .F.
LOCAL lJaCobLib 	:= .F.
LOCAL cCodTab       := ""
LOCAL cCodOpe       := PLSINTPAD()
LOCAL cCodRda       := ""
LOCAL lPtuOn        := .F.
LOCAL lGetCri		:= .F.
LOCAL nPos01   		:= 0
LOCAL nPos02   		:= 0
LOCAL nPos03   		:= 0
LOCAL nPos04   		:= 0
LOCAL nPos05   		:= 0
LOCAL nPos06   		:= 0
LOCAL nPos07   		:= 0
LOCAL nPos08   		:= 0
LOCAL nPos09   		:= 0
LOCAL nPos10   		:= 0
LOCAL nOrdBA0       := 0
LOCAL nRecBA0       := 0
LOCAL aDadUsr       := {}
LOCAL nPos13   		:= 0
LOCAL nPos14   		:= 0
LOCAL nPos15   		:= 0
LOCAL nRecBEA		:= 0
LOCAL nC            := 0
LOCAL aItens		:= {}
LOCAL cCodInt  		:= ""
LOCAL cLotGui       := ""
LOCAL cGraPar		:= Iif( Type("M->BE1_GRAUPA") == "C",M->BE1_GRAUPA,"")
LOCAL o790C			:= NIL
LOCAL lPagAto       := .F.
LOCAL lOdonto	   	:= UPPER( Alltrim( FunName() ) ) $ "PLSA094C,PLSA094D" //falta tratar web, quando tiver
LOCAL aBanco        := {}
LOCAL lMVPromo 		:= getNewPar("MV_PROSAUD", .F.)  // PromoÁ„o a Saude
LOCAL lMVVEleg 		:= getNewPar("MV_VELEGUI", .F.)  // PromoÁ„o a Saude  - verifica elegiveis
LOCAL nOrdBa1O      := 0
LOCAL nRecBa1O      := 0
LOCAL cGuiJur     	:= ""		// Conceito de guia juridica.
LOCAL cCodFor 		:= ""
LOCAL nSaldo		:= 0
LOCAL nPosSeq		:= 0
LOCAL nPosPro		:= 0
LOCAL nPosSol		:= 0
LOCAL cPrefixo    	:= ""
LOCAL cNumTit     	:= ""
local cNumGuia		:= ""
LOCAL nRecAutEVO  	:= 0
LOCAL nValPag	    := 0
LOCAL aAreaBE2 	 	:= BE2->(GetArea())
LOCAL aAreaBD6 	 	:= BD6->(GetArea())
Local lFluig		:= getNewPar("MV_PLFLUIG", .F.) //Ativa Fluig
LOCAL cChaveLib		:=	""
LOCAL lCampoCan     := .F.
LOCAL lIncBD6BQV    := .F.
LOCAL nIJ			:= 0
LOCAL cLocDigP		:= PLSRETLDP(4)
LOCAL lBloqGCt   	:= getNewPar("MV_PLBQGCT",.F.)
LOCAL nPosTipo   	:= 0
LOCAL dVencto		:= dDataBase
Local lRadio		:= .F.
LOCAL aChavBZC      := {}
LOCAL lGrvEvoSad    := .F.
LOCAL cPesqAnex     := ""
LOCAL nPos18        := 0
LOCAL nPos19        := 0
LOCAL lPl90L1       := ExistBlock("PLS090L1")
LOCAL aPar90JOB     := {}
LOCAL lJobAc        := GetNewPar("MV_PLMFJOB","1") == "1" .AND. ((lWeb .And. !IsInCallStack("PLSA973PRO")) .Or. IsInCallStack("PROCONLINE"))  
Local lCentralObr 	:= GetNewPar("MV_PLSEXCO",.F.)
LOCAL aDelAutFor    := {}
LOCAL aAux          := {}
LOCAL aRetB7B       := {}
Local lPos090MF     := .F.
Local lBtnOnMF      := .F.
Local lTitAtoMF     := .F.
Local cSenhaPLS 	:= ""
Local lExiSenha		:= GetNewPar("MV_PLSSENH",.T.)
Local lGerB53       := .T.
Local cFornSE2		:= ""
Local cGuiaPacote	:= ""
Local aAreaAutBEA := {}
Local cNumNRL := ""
Local cCobEsp := "" //Variavel Cobertura Especial TISS Versao 4.00

If Type("lBtnOn")=="U"
	PRIVATE lBtnOn := .F.
EndIf

DEFAULT aMatBd6		:= NIL
DEFAULT lIntern     := .F.
DEFAULT aDadCri     := {}
DEFAULT aCabCri     := {}
DEFAULT aTrbCri     := {}
DEFAULT aColsDF		:= {}
DEFAULT aHeaderDF	:= {}
DEFAULT aVetDF		:= {}
DEFAULT lAutori     := .T.
DEFAULT cTipoRotEsp := __cTipo
DEFAULT cCodLDP     := ""
DEFAULT lReanaliza  := .T.
DEFAULT cNaoUsado   := ""
DEFAULT lForBloq	:= .F.
DEFAULT lVeioComu	:= .F.
DEFAULT lNMudFase	:= .F.
DEFAULT cKey 		:= "BE1"
DEFAULT cAliasIte   := "BE2"
DEFAULT cAliasCri   := "BEG"
DEFAULT cAliasCmp	:= "B47"
DEFAULT lAjusta		:= .T.
DEFAULT lEvolu		:= .F.
DEFAULT lEvoSadt    := .F.
DEFAULT aDadBE4		:= {}
DEFAULT lGerSenha   := .F.
DEFAULT lWeb		:= .F.
DEFAULT aDadB43		:= {}
DEFAULT aCabB43     := {}
DEFAULT aTrbB43     := {}
DEFAULT oBrwEven	:= NIL
DEFAULT lExcluiAte  := .T.
DEFAULT oBrwB46		:= nil
DEFAULT oBrwB47		:= nil
DEFAULT cAliasCab	:= "BEA"
DEFAULT lReembolso	:= .F.
DEFAULT oBrwB44		:= NIL
DEFAULT lIncNeg		:= .F.
DEFAULT cObsoleto   := ""
DEFAULT lSolicit	:= .F.
DEFAULT cTpGrv		:= '1'
DEFAULT aDaSenPro	:= {}
DEFAULT aMatCom		:= {}
DEFAULT lGuiHoRe    := .F.
DEFAULT lResInt		:= .F.
DEFAULT cSituac    	:= "1"
DEFAULT lOdontoWeb  := .F.
DEFAULT cNumLib		:= Iif( Type("M->BE1_NUMLIB") == "C",If(Empty(M->BE1_NUMLIB) .and. Type("M->BE1_NRLBOR") == "C",M->BE1_NRLBOR,M->BE1_NUMLIB),"" )
DEFAULT cNumLibOd	:= ""
DEFAULT cArqImp		:= ""
DEFAULT lProtoc		:= .F.
DEFAULT aPartic		:= {}
DEFAULT aColsB4B	:= {}
DEFAULT aHeaderB4B	:= {}
DEFAULT aVetB4B		:= {}
DEFAULT lRecGlo		:= .F.
DEFAULT lPTUOnSol   := .F. //Indica que È uma solicitacao PTU Online partindo de minha Operadora. Esta solicitacao foi realizada no Portal do Prestador
DEFAULT cObsEvo     := ""
DEFAULT nNrSeqTR    := ""
DEFAULT cSenhaOpe   := ""
DEFAULT cOpeSolPTU  := ""
DEFAULT cNewAut		:= ""
DEFAULT strJsonB7B  := ""
DEFAULT lPtuOnline  := .F.
DEFAULT aCampCust	:= {}
DEFAULT dValSen		:= cTod('')
DEFAULT lSUS		:= .F.
DEFAULT aArraySUS	:= {}
DEFAULT lReembCriaBD5	:= .T. //Identifica se Cria BD5 ou n„o quando se tratar de Reembolso.
DEFAULT lGuiAudit     	:= .F. //Se a guia est· sendo gerada pela rotina de inclus„o de procedimentos pela auditoria
DEFAULT oGetBZC     	:= nil
DEFAULT cTrolComun  	:= ""
DEFAULT aBQVPTUDif  	:= {}
DEFAULT aDadB6M			:= {}
DEFAULT aItensB6L		:= {}
Default cRdaExe			:= ""


If lReembolso .AND. nOpc == K_Excluir //26-02
	cChavBD6 := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")+&(cAliasCab+"->"+cAliasCab+"_CODLDP")+&(cAliasCab+"->"+cAliasCab+"_CODPEG")+&(cAliasCab+"->"+cAliasCab+"_NUMGUI")
EndIf

//Guarda o Recno da execucao para ser utilizada na Evolucao SADT
If cAliasCab == "BEA" .And. nOpc == K_Evolucao
	nRecAutEVO := BEA->(Recno())
EndIf

If Empty(cCodLDP)
	If PLSOBRPRDA()
		cCodLDP     := PLSRETLDP(9)
	Else
		cCodLDP := GetNewPar("MV_PLSPEGE","0000")
	Endif
Endif

//Na inclusao da guia de c	obranca considerar a critica ja registrada no atendimento
lGetCri := GetNewPar("MV_PLSDTPG",.F.) .And. cTipoRotEsp != "2"

//Pega a chave de liberacao na conta medica para tratamento no ponto de entrada PLCALCEV
if nOpc <> K_Excluir .and. nOpc <> K_Alterar .and. ! empty(cNumLib)

	cChaveLib := cNumLib

endIf

//Variavel transacao online
lPtuOn := IIf(cTpGrv == "2",.F.,IIf(Type("lBtnOn") == "U",.F.,lBtnOn))

//Se Ptu Online e versao 4.0, grava guia negada para posterior insistencia
aDadUsr := PLSGETUSR()

If LEN(aDadUsr) > 0 .and. aDadUsr[45] <> PLSINTPAD()
	nOrdBA0 := BA0->(IndexOrd())
	nRecBA0 := BA0->(Recno())
	BA0->(DbSetOrder(1))
	If BA0->(MsSeek(xFilial("BA0")+aDadUsr[45])) .And. BA0->BA0_ONLINE == "1" .And. GetNewPar("MV_PLSSOOL","1") == "1"
		lIncNeg := .T.
	Endif
	BA0->(DbSetOrder(nOrdBA0))
	BA0->(DbGoTo(nRecBA0))
Endif

//Verifica se e uma Guia Ondonto liberado pela Web
If lOdontoWeb
	lOdonto := lOdontoWeb
EndIf

//Tratamento de Pacote no Portal

If cTpGrv=="2" .And. PLSALIASEXI("B47") .And. Len(aColsITE) > 0 .And. Len(aDadB43)==0 .And. ! lGuiHoRe .And. ! lResInt

	nPos  := Ascan(aDadBEA,{|x| Alltrim(x[1]) == "BEA_OPERDA"})
	nPos2 := Ascan(aDadBEA,{|x| Alltrim(x[1]) == "BEA_CODRDA"})

	If nPos > 0
		cCodOpe := Alltrim(aDadBEA[nPos,2])
	Endif

	If nPos2 > 0
		cCodRda := Alltrim(aDadBEA[nPos2,2])
	Endif

	//Chama a funÁ„o para carregar o array do pacote no portal
	PLSAWEBPAC(aColsITE,aHeaderITE,aDadB43,aCabB43,aTrbB43,cAliasIte,cTpGrv,cCodOpe,cCodRda)

Endif


//Ajusta item e critica retirando itens deletados
If ( nOpc == K_Incluir .Or. nOpc == K_Alterar) .And. !(FunName() $ 'PLSA315') .And. lPtuOn
	PLAJUMAT(aHeaderITE,aColsITE,aVetTrab,cAliasIte,aCabCri,aDadCri,aTrbCri,cAliasCri)
EndIf

aStrucBEA := &(cAliasCab+"->(DbStruct())")

//Verifica se a tabela dos itens foi aberta uma vez
if len(aMatAlias) > 0

	aArea := GetArea()
	For nI := 1 To Len(aMatAlias)
		If !PLSALIASEX(aMatAlias[nI])
			If !lWeb
				Aviso(	STR0120,; 			//"Atencao"
				STR0272 + aMatAlias[nI],;	//"Tabela nao existe no SX2 -> "
				{ STR0146 }, 2 ) 			//"ok"
			Else
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0272 + aMatAlias[nI] , 0, 0, {})
			EndIf
		Else
			If Select(aMatAlias[nI]) == 0
				DbSelectArea(aMatAlias[nI])
			EndIf
		EndIf
	Next
	RestArea(aArea)

endIf
// Ajusta o local de digitacao												 ≥

If Empty(cCodLDP)
	If lDatPagto .And. cTipoRotEsp == "2" //Liberacao
		cCodLDP := PLSRETLDP(6) 
	Else
		cCodLDP := PLSRETLDP(5)
	Endif
Endif

//Se for internacao ou evolucao
If (lIntern .Or. lEvolu) .And. nOpc <> K_Incluir

	BEA->( DbSetOrder(6) )	//BEA_FILIAL + BEA_OPEINT + BEA_ANOINT + BEA_MESINT + BEA_NUMINT + DTOS(BEA_DATPRO) + BEA_HORPRO
	If !BEA->( MsSeek( xFilial("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

		If ! lWeb
			Aviso(	STR0120, ; 				//"Operadora Origem On-Line"
			STR0265,; 				//"Inconsistencia no relacionamento BE4 X BEA!"
			{ STR0146 }, 2 )	 	//"ok"
		Else

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0265 , 0, 0, {})

		EndIf

		Return( {.F.,"","","","",.F.,"","",.F.,"",,lRadio} )

	EndIf

EndIf


//Se for internacao ajusta o tipo da guia
If lIntern
	cTipGui := GetNewPar("MV_PLSTPGI","03")
EndIf

//Se for evolucao

If lEvolu .Or. lEvoSADT
	lIntern := .F.
EndIf

//Ponto de entrada para troca de dados na aut do portal
If ExistBlock("PLS90ITENS")
	aRetItens := ExecBlock("PLS90ITENS",.F.,.F.,{aColsITE,aHeaderITE})
	If Len(aRetItens)>0 .and. Valtype(aRetItens)="A"
		aColsITE:=aClone(aRetItens)
	Endif
EndIf

//Envia os itens da guia para auditoria caso a critica de guia juridica estiver parametrizada para isso.
If nOpc <> K_Excluir

	//Verifica itens autorizados e negados
	If Type("M->"+cKey+"_GUIJUR") == "C"
		cGuiJur := &("M->"+cKey+"_GUIJUR")

		If cGuiJur == "1" .and. PlsGetJur()[2]
			nPos   := PLRETPOS(cAliasIte+"_STATUS",aHeaderITE,.F.)
			nPos2  := PLRETPOS(cAliasIte+"_AUDITO",aHeaderITE,.F.)

			For nFor := 1 To Len(aColsITE)
				If ! aColsITE[nFor,Len(aHeaderITE)+1]
					If nPos2 > 0
						aColsITE[nFor,nPos]  := "0"
						aColsITE[nFor,nPos2] := "1"
					EndIf
				EndIf
			Next
		Endif
	EndIf
Endif

//Verifica se pelo menos um item foi autorizado

If nOpc <> K_Excluir
	nPos := PLRETPOS(cAliasIte+"_STATUS",aHeaderITE)
	If nPos > 0
		For nFor := 1 To Len(aColsITE)

			//Verifica se tem algum procedimento de participativa
			nPos01 := PLRETPOS(cAliasIte+"_CODPAD",aHeaderITE)
			nPos02 := PLRETPOS(cAliasIte+"_CODPRO",aHeaderITE)

			If nPos01 > 0 .and. nPos02 > 0 .and. ! lPartic
				lPartic := Posicione("BR8",1,xFilial("BR8")+aColsITE[nFor,nPos01]+aColsITE[nFor,nPos02],"BR8_PARTIC") == '1'
			EndIf

			//Se tem algum registro autorizado
			If aColsITE[nFor,nPos] == "1"
				lAut := .T.
				Exit
			Endif
		Next
	EndIf

	If lAut	
		__lAutoriz := .T.
	Endif
Endif

//Verifica se existe uma internacao em aberto...
If !lPlNumPr
	nH1 := PLSAbreSem("P090SEMDEF.SMF")
EndIf

//Se nao for exclusao
If nOpc <> K_Excluir

	nPos   := PLRETPOS(cAliasIte+"_STATUS",aHeaderITE,.F.)
	nPos2  := PLRETPOS(cAliasIte+"_AUDITO",aHeaderITE,.F.)
	nPos01 := PLRETPOS(cAliasIte+"_SEQUEN",aHeaderITE,.F.)
	nPos02 := PLRETPOS(cAliasIte+"_QTDPRO",aHeaderITE,.F.)

	//Verifica itens autorizados e negados
	For nFor := 1 To Len(aColsITE)

		If ! aColsITE[nFor,Len(aHeaderITE)+1]

			If nPos > 0
				If  aColsITE[nFor,nPos] == "1"
					nItensAut ++
				Else
					nItensNeg ++
				EndIf
			EndIf

			If nPos2 > 0
				If  aColsITE[nFor,nPos2] == "1"
					nAuditAut ++
				Else
					nAuditNeg ++
				EndIf
			EndIf
		EndIf

	Next

	//Honorario ou Resumo
	If ! lGuiHoRe .And. ! lResInt

		If nOpc == K_Incluir
			If nAuditAut > 0 .And.  &(cAliasCab+"->(FieldPos('"+cAliasCab+"_AUDITO"+"'))") > 0
				aadd(aDadBEA,{cAliasCab+"_AUDITO","1"})
				lAuditoria := .T.
			Else
				aadd(aDadBEA,{cAliasCab+"_AUDITO","0"})
				lAuditoria := .F.
			Endif
		ElseIf lBtnOn
			lAuditoria := (nAuditAut > 0)
		Else
			lAuditoria := (&(cAliasCab+"->"+cAliasCab+"_AUDITO")=="1")
		Endif

		If nOpc == K_Incluir .And. lGerSenha .Or. (nOpc == K_Alterar .And. cAliasCab =="BEA" .And. !lAuditoria .And. lGerSenha .And. lBtnOn)

			If lPl90L1     
				cSenhaPLS := ExecBlock("PLS090L1",.F.,.F.,{cTipoRotEsp,.F.,dData})
			ElseIf !lExiSenha .And. lAuditoria
				cSenhaPLS := ""
			Else
				cSenhaPLS := PLSSenAut(dData)		
			EndIf

			M->BE1_SENHA := cSenhaPLS
			M->B01_SENHA := cSenhaPLS

			AaDd(aDadBEA,{cAliasCab+"_SENHA",cSenhaPLS})

			If lPtuOnSol .Or. lPtuOnLine .Or. GetNewPar("MV_PLSUNI","1") == "1" .And. (aDadUsr[45] <> PlsIntPad() .Or. (BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")))
				If !empty(dValSen)
					AAdd(aDadBEA,{cAliasCab+"_VALSEN",dValSen})
				Else
					AAdd(aDadBEA,{cAliasCab+"_VALSEN",dDatabase+GetNewPar("MV_PLPRZPT",30)})
				Endif
			Else
				If 	!empty(dValSen)
					AAdd(aDadBEA,{cAliasCab+"_VALSEN",dValSen})
				Else	
					AAdd(aDadBEA,{cAliasCab+"_VALSEN",dDatabase+GetNewPar("MV_PLPRZLB",30)})
				EndIf
			EndIf

		Endif

		nPos := Ascan(aDadBEA,{|x| Alltrim(x[1]) = cAliasCab+"_NRLBOR"})

		If Upper(FunName()) $ 'PLSA094A,PLSA094C' .And. nPos > 0
			lJaCobLib := PLSBusCob(SubStr(aDadBEA[nPos,2],1,4),SubStr(aDadBEA[nPos,2],5,4),;
			SubStr(aDadBEA[nPos,2],9,2),SubStr(aDadBEA[nPos,2],11,8))
		EndIf

		nPos := Ascan(aDadBEA,{|x| Alltrim(x[1]) = cAliasCab+"_PAGATO"})

		If nPos > 0

			If aDadBEA[nPos,2] == "1" //comprada
				nPos := Ascan(aDadBEA,{|x| AllTrim(x[1]) = cAliasCab+"_QUACOB"})
				If (nPos == 0 .AND. cTipGui == "03") .OR. (aDadBEA[nPos,2] == "1" .And. ! lAuditoria .And. !lJaCobLib)
					cStatus := "5" //Aguardando baixa do titulo de compra
				Endif
			Endif
		Endif
	Endif

	nPos := Ascan(aDadBEA,{|x| Alltrim(x[1]) == "BEA_CODRDA"})
	If nPos > 0
		If 	Upper(FunName()) $ 'PLSA094D,PLSA094B' .And. (aDadBEA[nPos,2] == GetNewPar("MV_PLSRDAG","999999") .And. !GetNewPar("MV_PLSCOLI",.F.))
			cStatus := ""
		EndIf
	EndIf

	If Empty(cStatus) .AND. !lAuditoria

		If ( nItensNeg == 0 .And. nItensAut >= 1 )
			cStatus := "1" //Autorizada
		ElseIf ( nItensNeg > 0  .And. nItensAut >= 1 )
			cStatus := "2" //Autorizada parcialmente
		ElseIf ( nItensNeg > 0 .And. nItensAut == 0 )
			cStatus := "3" //nao autorizada
		Endif

		//CondiÁ„o necess·rio para o caso onde a vari·vel cStatus esteja preenchida.
	ElseIf lAuditoria

		If FindFunction("PLSSTATUS")
			//devido aos novos status das guias, se uma guia vai para auditoria, o status
			//dever· ser 2 que corresponde ao status em an·lise/aprovado parcialmente na
			//rotina consulta status do portal do benefici·rio e do prestador.

			cStatus := "6"
		Else
			If ( nItensNeg == 0 .And. nItensAut >= 1 )
				cStatus := "1" //Autorizada
			ElseIf ( nItensNeg > 0  .And. nItensAut >= 1 )
				cStatus := "2" //Autorizada parcialmente
			ElseIf ( nItensNeg > 0 .And. nItensAut == 0 )
				cStatus := "3" //nao autorizada
			Endif
		EndIf
	Endif
Endif

If nOpc <> K_Excluir .And. cStatus == "5" .And. ! lAuditoria .and. !lReembolso .And. !lJaCobLib

	If GetNewPar("MV_PLSIFIN","1") == "1"

		cPrefixo := GetNewPar("MV_PLSPRCP","CPP")
		cParcTit := Space( Len(SE1->E1_PARCELA) )
		cTipTit  := GetNewPar("MV_PLSTPCP","FT")

		If cPaisLoc == "BRA"
			cNumTit  := PLSE1NUM(cPrefixo)
			cChavSE1 := cPrefixo+cNumTit
		Endif

		nPos :=  Ascan(aDadBEA,{|x| Alltrim(x[1]) = cAliasCab+"_DATPRO"})
		If nPos >0
			dVencto  := aDadBEA[nPos][2]+GetNewPar("MV_PLSVCGC",0)
		Else
			dVencto  := dDataBase+GetNewPar("MV_PLSVCGC",0)
		EndIf

	Endif

Endif

If nOpc == K_Incluir .And. Type("M->"+Alltrim(cKey)+"_LOTGUI") == "C" .And. !Empty(Alltrim(&("M->"+Alltrim(cKey)+"_LOTGUI")))

	If Val(&("M->"+Alltrim(cKey)+"_LOTGUI")) == 0
		cLotGui	:= Alltrim(&("M->"+Alltrim(cKey)+"_LOTGUI"))
	Else
		cLotGui	:= Alltrim(Str(Val(&("M->"+Alltrim(cKey)+"_LOTGUI"))))
	Endif

EndIf

If nOpc == K_Incluir .And. lReembolso .And. &(cKey+"->(FieldPos('"+cKey+"_FORPAG'))") > 0

	If &("M->"+Alltrim(cKey)+"_FORPAG") == "1"

		If GetNewPar("MV_PLRESE1","1") == "1"

			cPrefixo := GetNewPar("MV_PLSPFRE",'"RLE"')
			cPrefixo := Eval({|| &cPrefixo })
			cNumTit  := PLSE1NUM(cPrefixo)

		EndIf
	EndIf

	lPagAto:= .T.

Endif

//Valida se possui procedimento de radioterapia. Apenas para liberaÁ„o
If nOpc <> K_Excluir .and. cTipoRotEsp == "2"

	//Verifica se a operadora solicita Anexos Clinicos
	If BA0->(FieldPos("BA0_DIGANE")) > 0 .AND. Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_DIGANE") == "1"

		//Verifica se a RDA envia Anexos Clinicos
		nPos := Ascan(aDadBEA,{|x| Alltrim(x[1]) == "BEA_CODRDA"})

		If nPos > 0  .and. Posicione("BAU",1,xFilial("BAU")+aDadBEA[nPos,2],"BAU_DIGANE") == '1'

			//Procura algum item de radiologia
			For nFor := 1 To Len(aColsITE)

				If ! aColsITE[nFor,Len(aHeaderITE)+1] //Deletado?

					//Verifica se tem algum procedimento de participativa
					nPos01 := PLRETPOS(cAliasIte+"_CODPAD",aHeaderITE)
					nPos02 := PLRETPOS(cAliasIte+"_CODPRO",aHeaderITE)

					lRadio := Posicione("BR8",1,xFilial("BR8")+aColsITE[nFor,nPos01]+aColsITE[nFor,nPos02],"BR8_ANEEDI") == '2'

					//Se tem algum registro de radioterapia
					If lRadio
						Exit
					Endif

				EndIf

			Next nFor

		EndIf

	EndIf

EndIf

If nOpc <> K_Visualizar .And. nOpc <> K_VisOnline  .And. nOpc <> K_Evolucao

	If nOpc == K_Incluir

		If Empty(Eval(bOpeMov))
			bOpeMov := { || PLSINTPAD() }
		Endif

	Endif

	//Nao grava senha se for totalmente negada
	If ! lGuiHoRe .And. ! lResInt

		If cStatus == "3" .OR. lAuditoria .AND. ( nItensNeg > 0 .And. nItensAut == 0 )
			If (nPos := Ascan(aDadBEA,{|x| x[1] == cAliasCab+"_SENHA"})) == 0
				AaDd(aDadBEA,{cAliasCab+"_SENHA",""})
			Else
				aDadBEA[nPos,2] := ""
			Endif
		EndIf
	Endif

	//Monta a chave
	cOpeMov := (cAliasCab)->&( cAliasCab + "_OPEMOV" )
	cAnoAut := (cAliasCab)->&( cAliasCab + "_ANOAUT" )
	cMesAut := (cAliasCab)->&( cAliasCab + "_MESAUT" )
	cNumAut := (cAliasCab)->&( cAliasCab + "_NUMAUT" )

	If nOpc <> K_Excluir

		cOpeMov := Eval(bOpeMov)
		cAnoAut := Eval(bAnoAut)
		cMesAut := Eval(bMesAut)
		cNumAut := iIf( empty(cNewAut), PlNewNAut(cAliasCab,cOpeMov,cAnoAut,cMesAut,nOpc), cNewAut)

	EndIf

	// CUIDADO AO MOVER O INICIO DA TRANSA«√O DAQUI PRA OUTRO LUGAR
	// TEM QUE INICIAR A TRANSA«√O DEPOIS DE PEGAR O NUMERO, PQ AS GRAVA«’ES SUBSEQUENTES  N√O PRECISAM ESPERAR A
	// GRAVA«√O INTEIRA DE UMA GUIA PRA PEGAR UM SIMPLES NUMERO, SE CAIR, VAI PULAR ESSE NUMERO MAIS ISSO N√O PODE AFETAR NA PERFORMANCE COMO ESTAVA AFETANDO
	// QUALQUER SEMAFORO COLOCADO AP”S O INICIO DESSA TRANSA«√O TEM QUE SER BEM PENSADO POIS UM RECLOCK NA TABELA JA ENFILEIRA OS PROCESSOS E GERA LENTID√O

	Begin Transaction

		//Gravacao do cabecalho da Movimentacao (BEA)...
		nPos   := PLRETPOS(cAliasIte+"_STATUS",aHeaderITE,.F.)
		nPos2  := PLRETPOS(cAliasIte+"_AUDITO",aHeaderITE,.F.)
		nPos02 := PLRETPOS(cAliasIte+"_QTDPRO",aHeaderITE,.F.)
		nPos01 := PLRETPOS(cAliasIte+"_SEQUEN",aHeaderITE,.F.)
		nPos03 := PLRETPOS(cAliasIte+"_CODPAD",aHeaderITE,.F.)
		nPos04 := PLRETPOS(cAliasIte+"_CODPRO",aHeaderITE,.F.)
		nPos18 := PLRETPOS(cAliasIte+"_DENREG",aHeaderITE,.F.)
		nPos19 := PLRETPOS(cAliasIte+"_FADENT",aHeaderITE,.F.)
		nPos10 := PLRETPOS(cAliasIte+"_VLRAPR",aHeaderITE,.F.)
		
		//Verifica itens autorizados e negados
		If nOpc <> K_Excluir

			For nFor := 1 To Len(aColsITE)

				If ! aColsITE[nFor,Len(aHeaderITE)+1]

					//Grau de participacao 45-a da guia de sadt ou ghi
					If !Empty(cGraPar) .and. Len(aPartic) == 0

						If lGuiHoRe

							AaDd(aPartic, {	cGraPar,aColsITE[nFor,nPos01],;
							aColsITE[nFor,nPos03]+aColsITE[nFor,nPos04],;
							aColsITE[nFor,nPos10],M->&(cAliasCab+"_SICONS"),;
							M->&(cAliasCab+"_NUCONS"),M->&(cAliasCab+"_UFCONS"),0} )
						Else

							AaDd(aPartic, {	cGraPar,aColsITE[nFor,nPos01],;
							aColsITE[nFor,nPos03]+aColsITE[nFor,nPos04],;
							aColsITE[nFor,nPos10],"","","",0} )

						EndIf

					ElseIf lResInt .And. Len(oBrwB47:aCols) > 0

						nPos05 := PLRETPOS("B0K_SEQUEN",oBrwB47:aHeader)
						nPos06 := PLRETPOS("B0K_CODPAD",oBrwB47:aHeader)
						nPos07 := PLRETPOS("B0K_CODPRO",oBrwB47:aHeader)
						nPos08 := PLRETPOS("B0K_GRAUPA",oBrwB47:aHeader)

						nPos13 := PLRETPOS("B0K_CRMRDA",oBrwB47:aHeader)
						nPos14 := PLRETPOS("B0K_CRMNUM",oBrwB47:aHeader)
						nPos15 := PLRETPOS("B0K_CRMUF",oBrwB47:aHeader)

						nPos09 := AsCan(oBrwB47:aCols,{|x| AllTrim( x[nPos05]+x[nPos06]+x[nPos07]) == AllTrim(aColsITE[nFor,nPos01]+aColsITE[nFor,nPos03]+aColsITE[nFor,nPos04]) })

						If nPos09 > 0

							For nI:=nPos09 To Len(oBrwB47:aCols)

								if ! oBrwB47:aCols[nI,Len(oBrwB47:aHeader)+1]

									AaDd(aPartic, {	oBrwB47:aCols[nI,nPos08], oBrwB47:aCols[nI,nPos05],;
									oBrwB47:aCols[nI,nPos06]+oBrwB47:aCols[nI,nPos07],;
									aColsITE[nFor,nPos10],oBrwB47:aCols[nI,nPos13],;
									oBrwB47:aCols[nI,nPos14], oBrwB47:aCols[nI,nPos15],0} )
								EndIf
							Next
						EndIf
					EndIf

					//Quando for ConfirmaÁ„o de Liberacao o aCols e atualizado com o valor restante do saldo na Qtd. Solicitada e Executada
					If UPPER(Alltrim(FunName())) $ "PLSA097"
						nSaldo := PLGTBE2SL(cNumLib,aColsITE[nFor][nPosSeq:=aScan(aHeaderITE,{|X| X[2]=="BE2_SEQUEN"})])
						aColsITE[nFor][nPosPro:=aScan(aHeaderITE,{|X| X[2]=="BE2_QTDPRO"})]:= nSaldo
						aColsITE[nFor][nPosSol:=aScan(aHeaderITE,{|X| X[2]=="BE2_QTDSOL"})]:= nSaldo
					Endif

					//Atualiza saldo
					If ! Empty(cNumLibOd) .And. nPos > 0 .and. aColsITE[nFor,nPos] == "1" .and. lOdonto == .T.
						PLSAtuLib(cNumLibOd,aColsITE[nFor,nPos01],aColsITE[nFor,nPos03],aColsITE[nFor,nPos04],aColsITE[nFor,nPos02],aPartic,,,lAuditoria,,aColsITE[nFor,nPos18], aColsITE[nFor,nPos19]) 
					EndIf

					nPosTipo := Ascan(aDadBEA,{|x| Alltrim(x[1]) == "BEA_TIPO"})

					If ! Empty(cNumLib) .And. (nPos > 0 .and. aColsITE[nFor,nPos] == "1" .And. !lWeb .OR. ! lWeb .AND. aColsITE[nFor,nPos] == "1" /*procedimento autorizado*/ .AND. nPosTipo > 0 .AND. aDadBEA[nPosTipo][2] == "2")
						PLSAtuLib(cNumLib,aColsITE[nFor,nPos01],aColsITE[nFor,nPos03],aColsITE[nFor,nPos04],aColsITE[nFor,nPos02],aPartic,lIntern,(lGuiHoRe .Or. lResInt),lAuditoria )
					EndIf

				EndIf

			Next

		EndIf

		//Inicio do tratamento para Evolucao
		If lEvolu

			//≥ Gravacao da evolucao													 
			lRet := PLSAGRVEVO(PlsPtuGet(cAliasCab+"_NRTROL",aDadBEA),aColsITE,aHeaderITE,aDadCri,;
			aCabCri,PlsPtuGet(cAliasCab+"_MSG03",aDadBEA),lVeioComu,;
			PlsPtuGet(cAliasCab+"_LOTGUI",aDadBEA),lWeb,aDaSenPro,aMatCom,cObsEvo,cOpeSolPTU,aBQVPTUDif,aDadB6M,aItensB6L)

		ElseIf lEvoSadt

			//Gravacao da evolucao de SADT
			lRet := PLSEVOSADT(PlsPtuGet(cAliasCab+"_NRTROL",aDadBEA),aColsITE,aHeaderITE,aDadCri,;
			aCabCri,PlsPtuGet(cAliasCab+"_MSG03",aDadBEA),lVeioComu,;
			PlsPtuGet(cAliasCab+"_LOTGUI",aDadBEA),lWeb,aDaSenPro,cTipGui,cObsEvo,cOpeSolPTU,aBQVPTUDif,aDadB6M,aItensB6L)

		Else

			//Se for internacao faz a gravacao
			If lIntern

				//Gravacao
				cNumGuia := PLSAGRVINT(nOpc,PlsPtuGet("OPEINT",aDadBEA),cAnoAut,cMesAut,cNumAut,cTipGui,cStatus,lAuditoria,cKey,cTipoRotEsp,aDadBEA,;
				aClone(aColsITE),aClone(aHeaderITE),aClone(aVetTrab),aClone(aDadCri),aClone(aCabCri),aClone(aTrbCri),@lAjusta,;
				aDadBE4,lVeioComu,cCodLDP,cOpeMov,aDadB6M,aItensB6L)
				if ! lAjusta

					plChkHECO('BEJ','BE2',@aHeaderITE,@aColsITE)

					If nOpc <> K_Incluir .Or. nOpc <> K_Copiar

						aVetTemp := aClone(aVetTrab)
						aVetTrab := {}

						BE2->( DbSetOrder(1) )//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
						nPos := PLRETPOS("BE2_SEQUEN",aHeaderITE,.F.)

						for nFor := 1 to len(aVetTemp)

							If nPos > 0 .and. !nFor > len(aColsITE)

								If BE2->( msSeek( xFilial("BE2") + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + aColsITE[nFor,nPos]) )
									aadd( aVetTrab,BE2->(Recno()) )
								endIf

							endIf

						next

					endIf

				endIf

			endIf

			//Fim do tratamento para Internacao
			If nOpc == K_Excluir .And. ! lGuiHoRe .And. ! lResInt .And. ( lReembolso .or. (&(cAliasCab+"->"+cAliasCab+"_GUIACO") == "1" .And. &(cAliasCab+"->"+cAliasCab+"_QUACOB") == "1"))

				If lReembolso
					cChavSE1 := &(cAliasCab+"->"+cAliasCab+"_PREFIX")+&(cAliasCab+"->"+cAliasCab+"_NUM")+&(cAliasCab+"->"+cAliasCab+"_PARCEL")+&(cAliasCab+"->"+cAliasCab+"_TIPO")
					cFornSE2 :=	BOW->BOW_FORNEC
				Else
					If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_NUMTIT"+"'))") > 0
						cChavSE1 := &(cAliasCab+"->"+cAliasCab+"_PREFIX")+&(cAliasCab+"->"+cAliasCab+"_NUMTIT")+&(cAliasCab+"->"+cAliasCab+"_PARCEL")+&(cAliasCab+"->"+cAliasCab+"_TIPTIT")
					Else
						cChavSE1 := &(cAliasCab+"->"+cAliasCab+"_CHVSE1")
					EndIf
				EndIf

				DbSelectArea("SE1")

				SE1->(DbSetOrder(1))
				BBT->(DbSetOrder(7))
				If GetNewPar("MV_PLRESE1","1") == "0"//trato a exlusao do remebolso no se2

					SE2->(DbSetORder(1))
					If SE2->(MsSeek(xFilial("SE1")+cChavSE1+cFornSE2))
						PLCANCRE()  //excluo o titulo
					Endif

				Endif

				If SE1->(MsSeek(xFilial("SE1")+cChavSE1)) .And. BBT->(MsSeek(xFilial("BBT")+cChavSE1))

					BDC->(DbSetOrder(1))

					If BDC->(DbSeek(xFilial("BDC")+BBT->(BBT_NUMCOB)))

						If BBT->BBT_RECPAG == "1" .Or. Empty(BBT->BBT_RECPAG)// remebolso no se2
							BBT->(RecLock("BBT",.F.))
							BBT->BBT_RECPAG := "0" // remebolso no SE1
							BBT->(MsUnLock())
						EndIf

						PL627MOV("BDC",BDC->(Recno()),K_Excluir,.T.)

						// Caso o procedimento foi liberado pela auditoria e aguardando Liq. de titulo a receber - PLSA090OD
					Else
						If Empty(BBT->(BBT_NUMCOB))
							BBT->(DbSetOrder(1))
							PLSA625SE1(BDC->(BDC_CODOPE+BDC_NUMERO),Iif(Type('M->BDC_INTERC')<>'U',M->BDC_INTERC=='1',.F.),BBT->BBT_PREFIX,BBT->BBT_NUMTIT,BBT->BBT_PARCEL,BBT->BBT_TIPTIT,,.F.)
						EndIf
					EndIf
				Endif

			EndIf

			//Exclusao
			If nOpc == K_Excluir

				If &( cAliasCab+"->( FieldPos('"+cAliasCab+"_CANCEL') )" ) > 0
					lCampoCan := .T.
					cCancelada := &(cAliasCab+"->("+cAliasCab+"_CANCEL)")
				Endif

				cChaveAut := &(cAliasCab+"->("+cAliasCab+"_OPEMOV+"+cAliasCab+"_ANOAUT+"+cAliasCab+"_MESAUT+"+cAliasCab+"_NUMAUT)")
				If cAliasCab == 'BEA' .or. cAliasCab == 'B44'
					cChaveGui := &(cAliasCab+"->("+cAliasCab+"_OPEMOV+"+cAliasCab+"_CODLDP+"+cAliasCab+"_CODPEG+"+cAliasCab+"_NUMGUI)")				
				Else
					cChaveGui := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODLDP+"+cAliasCab+"_CODPEG+"+cAliasCab+"_NUMGUI)")
				EndIf

				// Se e uma excluao de autorizacao baseada em uma liberacao refaz saldo
				If cTipoRotEsp == "1" .And. ! Empty(cNumLib) .or. lCampoCan .and. cCancelada != '1'
					PLSA090RSD(cChaveAut,cNumLib,lGuiHoRe,lResInt)
				EndIf

				If PLSALIASEX("B53")
					B53->( DbSetOrder(1) )//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
					While B53->( MsSeek(xFilial("B53")+cChaveAut) )
						B53->(RecLock("B53",.F.))
						B53->(DbDelete())
						B53->(MsUnLock())
					Enddo			

					BBR->( DbSetOrder(1) )//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
					While BBR->( MsSeek(xFilial("BBR")+cChaveAut) )
						BBR->(RecLock("BBR",.F.))
						BBR->(DbDelete())
						BBR->(MsUnLock())
					Enddo			
				EndIf	

				BVX->(DbSetOrder(3))
				While BVX->(MsSeek(xFilial("BVX")+cChaveAut))
					BVX->(RecLock("BVX",.F.))
					BVX->(DbDelete())
					BVX->(MsUnLock())
				Enddo

				B43->(DbSetOrder(2))//B43_FILIAL + B43_OPEMOV + B43_ANOAUT + B43_MESAUT + B43_NUMAUT + B43_SEQUEN
				While B43->(MsSeek(xFilial("B43")+cChaveAut))
					B43->(RecLock("B43",.F.))
					B43->(DbDelete())
					B43->(MsUnLock())
				Enddo

				If PGetTisVer() >= '3'
					B4B->(DbSetOrder(1))//B43_FILIAL + B43_OPEMOV + B43_ANOAUT + B43_MESAUT + B43_NUMAUT + B43_SEQUEN
					While B4B->(MsSeek(xFilial("B4B")+cChaveAut))
						B4B->(RecLock("B4B",.F.))
						B4B->(DbDelete())
						B4B->(MsUnLock())
					Enddo
				Endif

				If !lGuiHoRe .And. !lResInt

					BYS->(DbSetOrder(1))
					While BYS->(MsSeek(xFilial("BYS")+cChaveAut))
						BYS->(RecLock("BYS",.F.))
						BYS->(DbDelete())
						BYS->(MsUnLock())
					Enddo

					BYT->(DbSetOrder(1))
					While BYT->(MsSeek(xFilial("BYT")+cChaveGui))
						BYT->(RecLock("BYT",.F.))
						BYT->(dbDelete())
						BYT->(MsUnLock())
					Enddo

					B46->(DbSetOrder(1))
					While B46->(MsSeek(xFilial("B46")+cChaveAut))
						B46->(RecLock("B46",.F.))
						B46->(DbDelete())
						B46->(MsUnLock())
					Enddo

					B47->(DbSetOrder(1))
					While B47->(MsSeek(xFilial("B47")+cChaveAut))
						B47->(RecLock("B47",.F.))
						B47->(DbDelete())
						B47->(MsUnLock())
					Enddo

				EndIf

				If lResInt
					B0K->(DbSetOrder(1))
					While B0K->(MsSeek(xFilial("B0K")+cChaveAut))
						B0K->(RecLock("B0K",.F.))
						B0K->(DbDelete())
						B0K->(MsUnLock())
					EndDo
				EndIf

				//≥ Nao entra se for processo online somente atualiza nao precisa mudar a fase≥
				//se for reembolso verifica se pode criar BD5 ou n„o.
				if ! lReembolso .or. ( lReembolso .and. lReembCriaBD5 )

					aRetMF := PLSA090MF(cOpeMov,cAnoAut,cMesAut,aColsITE,aHeaderITE,nOpc,cMatUsa,cAnoPag,cMesPag,cTipGui,lIntern,;
					cNumGuia,lAutori,cSituac,cCodLDP,lReanaliza,nil,lExcluiAte,;
					lNMudFase,lReembolso,cAliasCab,oBrwB47,nil,cObsoleto,lSolicit,@lMudarFase,@cAliasPri,aMatCom,;
					cTpGrv,cLotGui,lResInt,lGuiHoRe,aPartic,lOdonto,cArqImp,lRecGlo, lWeb, nil,lSUS,aArraySUS,,, cRdaExe)

					cCodOpeG  := aRetMF[1]

				endif

				If PLSALIASEX("B6M") .And. PLSALIASEX("B6L") 
					B6M->(DbSetOrder(1))
					While B6M->( MsSeek(xFilial("B6M") + cChaveAut) )
						B6M->(RecLock("B6M",.F.))
						B6M->(DbDelete())
						B6M->(MsUnLock())
					Enddo			

					B6L->(DbSetOrder(1))
					While B6L->( MsSeek(xFilial("B6L") + cChaveAut) )
						B6L->(RecLock("B6L",.F.))
						B6L->(DbDelete())
						B6L->(MsUnLock())
					Enddo			
				EndIf	

			EndIf

			If lExcluiAte

				//Se veio da web tenho que levantar o M da tabela
				If lWeb .And. (lGuiHoRe .Or. lResInt)

					Copy cAliasCab To Memory Blank

					For nFor := 1 To Len(aDadBEA)
						If &( cAliasCab+"->( FieldPos('"+aDadBEA[nFor,1]+"') )" ) > 0
							&( "M->"+aDadBEA[nFor,1] ) := aDadBEA[nFor,2]
						EndIf
					Next

				EndIf

				//Honorario ou Resumo
				If lGuiHoRe .And. !lResInt

					PLUPTENC(cAliasCab,nOpc)

					If nOpc == K_Incluir

						&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")

						//Se nao veio da web
						If !lWeb
							For nFor := 1 To Len(aDadBEA)
								If AsCan(aCpoChv,{|x| x == aDadBEA[nFor,1]}) == 0 .And. &( cAliasCab+"->( FieldPos('"+aDadBEA[nFor,1]+"') )" ) > 0
									&(cAliasCab+"->"+aDadBEA[nFor,1]) := aDadBEA[nFor,2]
								EndIf
							Next
						EndIf
						&(cAliasCab+"->"+cAliasCab+"_FILIAL") := xFilial(cAliasCab)
						&(cAliasCab+"->"+cAliasCab+"_OPEMOV") := cOpeMov
						&(cAliasCab+"->"+cAliasCab+"_ANOAUT") := cAnoAut
						&(cAliasCab+"->"+cAliasCab+"_MESAUT") := cMesAut
						&(cAliasCab+"->"+cAliasCab+"_NUMAUT") := cNumAut
						&(cAliasCab+"->( MsUnlock() )")

					EndIf

					//Resumo
				ElseIf lResInt

					PLUPTENC(cAliasCab,nOpc)

					If nOpc == K_Incluir

						&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")

						//Se nao veio da web
						If ! lWeb
							For nFor := 1 To Len(aDadBEA)
								If AsCan(aCpoChv,{|x| x == aDadBEA[nFor,1]}) == 0 .And. &( cAliasCab+"->( FieldPos('"+aDadBEA[nFor,1]+"') )" ) > 0
									&(cAliasCab+"->"+aDadBEA[nFor,1]) := aDadBEA[nFor,2]
								Endif
							Next
						EndIf
						&(cAliasCab+"->"+cAliasCab+"_FILIAL") := xFilial(cAliasCab)
						&(cAliasCab+"->"+cAliasCab+"_OPEMOV") := cOpeMov
						&(cAliasCab+"->"+cAliasCab+"_ANOAUT") := cAnoAut
						&(cAliasCab+"->"+cAliasCab+"_MESAUT") := cMesAut
						&(cAliasCab+"->"+cAliasCab+"_NUMAUT") := cNumAut
						&(cAliasCab+"->( MsUnlock() )")

					EndIf

					//Reembolso
				ElseIf lReembolso

					PLUPTENC(cAliasCab,nOpc)
					If nOpc == K_Excluir

						BD5->(DbSetOrder(1))
						BD6->(DbSetOrder(1))
						BD7->(DbSetOrder(1))
			
						If BD5->(MsSeek(xFilial("BD5") + cChavBD6))	

							If lCentralObr
								cDataRef 	:= dtos(dDataBase)
								cChvOpe		:= xFilial("BA0")+BD5->BD5_OPEUSR
								cTipData 	:= getNewPar("MV_PLSIPDT","1")
								cRegANS 	:= Posicione("BA0",1,cChvOpe,"BA0_SUSEP")
								cChvRee		:= BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)
								StartJob("PLSIPREE",getEnvServer(),.F.,cEmpAnt,cFilAnt,{},cDataRef,cTipData,cRegANS,.F.,"",1,cChvRee,.T./*lExcRee*/ )
							EndIf

							BD5->( RecLock("BD5",.F.) )
							BD5->( dbDelete() )
		        			BD5->( MsUnLock() )
						EndIF
					    BD6->(DbSetOrder(1))		        		
					    If BD6->(MsSeek(xFilial("BD6") + cChavBD6))	
			    		
			    			While BD6->( BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == xFilial("BD6") + cChavBD6  .AND. !BD6->(EoF())		//Para cada procedimento
			    		
			        
			        			If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			
									While !BD7->(Eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
															  BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
								
										BD7->(RecLock('BD7',.f.))
										BD7->(DbDelete())
										BD7->( MsUnlock() )
										BD7->(DbSkip())
									EndDo
							
								EndIf
			    				BD6->( RecLock("BD6",.F.) )
			   					BD6->(DbDelete())
			        			BD6->( MsUnLock() )
			        	
			        			BD6->(DbSkip())
			        		EndDo
			    		EndiF			

					EndiF



					If nOpc == K_Incluir

						&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")

						For nFor := 1 To Len(aDadBEA)
							If AsCan(aCpoChv,{|x| x == aDadBEA[nFor,1]}) == 0 .And. &( cAliasCab+"->( FieldPos('"+aDadBEA[nFor,1]+"') )" ) > 0
								&(cAliasCab+"->"+aDadBEA[nFor,1]) := aDadBEA[nFor,2]
							Endif
						Next

						&(cAliasCab+"->"+cAliasCab+"_FILIAL") := xFilial(cAliasCab)
						&(cAliasCab+"->"+cAliasCab+"_OPEMOV") := cOpeMov
						&(cAliasCab+"->"+cAliasCab+"_ANOAUT") := cAnoAut
						&(cAliasCab+"->"+cAliasCab+"_MESAUT") := cMesAut
						&(cAliasCab+"->"+cAliasCab+"_NUMAUT") := cNumAut

						IF &(cAliasCab+"->"+cAliasCab+"_FORPAG") <> '0' .AND. lAuditoria
							cStatus := "6"	// Em auditoria 
						EndIf

						&(cAliasCab+"->"+cAliasCab+"_STATUS") := PLSStReemb(cStatus)
						&(cAliasCab+"->"+cAliasCab+"_TIPGUI") := cTipGui
						&(cAliasCab+"->"+cAliasCab+"_CODLOC") := subs(&(cAliasCab+"->"+cAliasCab+"_LOCATE"),1,3)
						&(cAliasCab+"->"+cAliasCab+"_LOCAL")  := subs(&(cAliasCab+"->"+cAliasCab+"_LOCATE"),4,3)
						&(cAliasCab+"->"+cAliasCab+"_GUIIMP") := "0"
						&(cAliasCab+"->"+cAliasCab+"_ORIMOV") := "3"
						&(cAliasCab+"->"+cAliasCab+"_TPGRV")  := cTpGrv
						&(cAliasCab+"->( MsUnlock() )")

					Endif

					//Gravo o titulo referente ao reembolso
					If !lProtoc .AND. !lAuditoria .And. nOpc == K_Incluir .And. &(cAliasCab+"->"+cAliasCab+"_VLRPAG") > 0 .And. &(cAliasCab+"->"+cAliasCab+"_FORPAG") <> '0'

						If GetNewPar("MV_PLRESE1","1") == "1"

							cNat     := GetNewPar("MV_PLSNTRE",'"PLS"')
							cNat     := Eval({|| &cNat })
							cTipTit  := GetNewPar("MV_PLSNCRE","NCC")

							dVencto  := &(cAliasCab+"->"+cAliasCab+"_DATVEN")
							cCodCli  := &(cAliasCab+"->"+cAliasCab+"_CODCLI")
							cLoja    := &(cAliasCab+"->"+cAliasCab+"_LOJA")
							nVlrPag  := &(cAliasCab+"->"+cAliasCab+"_VLRPAG")
							cCodInt  := &(cAliasCab+"->"+cAliasCab+"_OPEUSR")
							cCodEmp  := &(cAliasCab+"->"+cAliasCab+"_CODEMP")
							cMatric  := &(cAliasCab+"->"+cAliasCab+"_MATRIC")
							cTipReg  := &(cAliasCab+"->"+cAliasCab+"_TIPREG")
							cConEmp  := &(cAliasCab+"->"+cAliasCab+"_CONEMP")
							cVerCon  := &(cAliasCab+"->"+cAliasCab+"_VERCON")
							cSubCon  := &(cAliasCab+"->"+cAliasCab+"_SUBCON")
							cVerSub  := &(cAliasCab+"->"+cAliasCab+"_VERSUB")

							If ExistBlock("PLS001CLI")
								aRetPto := ExecBlock("PLS001CLI",.F.,.F.,{cCodCli,cLoja,cNat,cPrefixo,cNumTit,cTipTit,dVencto})
								cCodCli := aRetPto[1]
								cLoja   := aRetPto[2]
								cNat    := aRetPto[3]
								cPrefixo:= aRetPto[4]
								cNumTit := aRetPto[5]
								cTipTit := aRetPto[6]
								dVencto := aRetPto[7]
							EndIf

							If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_NROBCO'))") > 0
								aAdd(aBanco,&(cAliasCab+"->"+cAliasCab+"_NROBCO")) //Numero Banco
								aAdd(aBanco,&(cAliasCab+"->"+cAliasCab+"_NROAGE")) //Numero Agencia
								aAdd(aBanco,&(cAliasCab+"->"+cAliasCab+"_NROCTA")) //Numero Conta
							EndIf

							PLSGRVREM(	cPrefixo,cNumTit,cCodCli,cLoja,cTipTit,dVencto,cCodInt,;
							cCodEmp,cMatric,nOpc,nVlrPag,cConEmp,cVerCon,cSubCon,;
							cVerSub,cTipReg,cNat,aBanco)

							&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")
							&(cAliasCab+"->"+cAliasCab+"_PREFIX"):= cPrefixo
							&(cAliasCab+"->"+cAliasCab+"_NUM")   := cNumTit
							&(cAliasCab+"->"+cAliasCab+"_TIPO")  := cTipTit
							&(cAliasCab+"->"+cAliasCab+"_PARCEL"):= ''
							&(cAliasCab+"->"+cAliasCab+"_STATUS") := '5'//atualizo o status para aguardando baixa
							&(cAliasCab+"->( MsUnlock() )")

						Else

							cNat     := GetNewPar("MV_PLSNTRE",'"PLS"')
							cNat     := Eval({|| &cNat })
							cTipo    := GetNewPar("MV_PLSNCRE","NCC")
							cPrefixo := GetNewPar("MV_PLSPFRE",'"RLE"')
							cPrefixo := Eval({|| &cPrefixo })
							cNumTit  := PLSREMSE2(cPrefixo)
							dVencto  := &(cAliasCab+"->"+cAliasCab+"_DATPAG")
							cCodCli  := &(cAliasCab+"->"+cAliasCab+"_CODCLI")
							cLoja    := &(cAliasCab+"->"+cAliasCab+"_LOJA")
							cCodInt  := &(cAliasCab+"->"+cAliasCab+"_OPEUSR")
							cCodEmp  := &(cAliasCab+"->"+cAliasCab+"_CODEMP")
							cMatric  := &(cAliasCab+"->"+cAliasCab+"_MATRIC")

							If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_NROBCO'))") > 0
								cBanco   := &(cAliasCab+"->"+cAliasCab+"_NROBCO") //Numero Banco
								cAgencia := &(cAliasCab+"->"+cAliasCab+"_NROAGE") //Numero Agencia
								cConta   := &(cAliasCab+"->"+cAliasCab+"_NROCTA") //Numero Conta
							Else
								cBanco   := ""
								cAgencia := ""
								cConta   := ""
							Endif

							//Armazenar Referencia Arquivo BA1 ...
							nOrdBa1O  := BA1->(IndexOrd())
							nRecBa1O  := BA1->(Recno())

							//Forcar Buscar Registro Beneficiario Titular ...
							BA1->(DbSetOrder(2))
							BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+"00"))

							//Setar Ordem Arquivo SA2 - Cadastro Fornecedores (SA2) ...
							SA2->(DbSetOrder(3))

							//Verifico Se Eh Beneficiario Titular ...
							If AllTrim(BA1->BA1_TIPUSU) $ "T" // Titular ????
								lFoundSA2 := (!Empty(BA1->BA1_CPFUSR) .And. SA2->(DbSeek(xFilial("SA2")+BA1->BA1_CPFUSR)))  //1a Vez .F. e na 2a Vez .T.
							Else //Se Nao Eh Titular
								lFoundSA2 := .T. //Para nao acessar Area Criacao Cadastro SA2.
							EndIf

							//pode ter cliente que quer usar a busca por nome
							If GetNewPar("MV_PLRENOM","1") == "1"
								SA2->(DbSetOrder(2))
								lFoundSA2 := SA2->(dbSeek(xFilial("SA2")+SA2->A2_NOME))
							Endif

							//busco o banco caso nao tenha sido informado ainda
							If !(lFoundSA2)

								If Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)

									BA3->(DbSetORder(1))
									BA3->(MsSeek(xFilial("BA3") + BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_CODEMP + BA1->BA1_CONEMP + BA1->BA1_VERCON + BA1->BA1_SUBCON + BA1->BA1_VERSUB))

									cBanco   := BA3->BA3_BCOCLI
									cAgencia := BA3->BA3_AGECLI
									cConta   := BA3->BA3_CTACLI
								EndIf

								SA2->(RecLock("SA2",.T.))
								SA2->A2_FILIAL	 := xFilial("SA2")
								SA2->A2_COD		 := GetSX8Num("SA2","A2_COD")
								SA2->A2_LOJA	 := '01'
								SA2->A2_NOME	 := BA1->BA1_NOMUSR
								SA2->A2_CGC		 := BA1->BA1_CPFUSR
								SA2->A2_TEL		 := BA1->BA1_TELEFO
								SA2->A2_FAX      := BA1->BA1_TELEFO
								SA2->A2_NREDUZ	 := BA1->BA1_NOMUSR
								SA2->A2_BAIRRO	 := BA1->BA1_BAIRRO
								SA2->A2_MUN		 := BA1->BA1_MUNICI
								SA2->A2_EST		 := BA1->BA1_ESTADO
								SA2->A2_END		 := BA1->BA1_ENDERE
								SA2->A2_TIPO 	 := "F"
								SA2->A2_EMAIL    := BA1->BA1_EMAIL
								SA2->A2_BANCO    := cBanco
								SA2->A2_AGENCIA  := cAgencia
								SA2->A2_NUMCON   := cConta
								SA2->(MsUnlock())
								SA2->(ConfirmSX8())
							EndIf

							//Atualizo Variaveis do Fornecedor ...
							cCodForn := SA2->A2_COD
							cLoja    := SA2->A2_LOJA

							//Reposicionar Beneficiario ...
							BA1->(DbSetOrder(nOrdBa1O))
							BA1->(DbGoTo(nRecBa1O))

							nVlrPag  := &(cAliasCab+"->"+cAliasCab+"_VLRPAG")

							If ExistBlock("PLS002FOR")
								aRetPto  := ExecBlock("PLS002FOR",.F.,.F.,{cCodForn,cLoja,cNat,cPrefixo,cNumTit,cTipo,dVencto,cCodInt,cCodEmp,cMatric})
								cCodForn := aRetPto[1]
								cLoja    := aRetPto[2]
								cNat     := aRetPto[3]
								cPrefixo := aRetPto[4]
								cNumTit  := aRetPto[5]
								cTipo    := aRetPto[6]
								dVencto  := aRetPto[7]
							EndIf

							aCampos :={	{"E2_FILIAL"    ,xFilial("SE2")     ,NIL},;
							{"E2_PREFIXO"	,cPrefixo           ,Nil},;
							{"E2_NUM"		,cNumTit            ,Nil},;
							{"E2_PARCELA"	,Space(Len(SE2->E2_PARCELA))           ,Nil},;
							{"E2_TIPO"		,cTipo              ,Nil},;
							{"E2_FORNECE"	,cCodForn           ,Nil},;
							{"E2_LOJA"		,cLoja              ,Nil},;
							{"E2_NOMFOR"    ,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),Nil},;
							{"E2_EMISSAO"	,dDataBase          ,NIL},;
							{"E2_EMIS1"     ,dDataBase          ,NIL},;
							{"E2_VENCTO"	,dVencto            ,NIL},;
							{"E2_VENCREA"   ,DataValida(dVencto),NIL},;
							{"E2_VENCORI"   ,dVencto            ,NIL},;
							{"E2_MOEDA"     ,01                 ,NIL},;
							{"E2_VALOR"		,nVlrPag			,Nil},;
							{"E2_VLCRUZ"	,nVlrPag            ,Nil},;
							{"E2_SALDO"		,nVlrPag            ,Nil},;
							{"E2_DECRESC"   ,0		            ,NIL},;
							{"E2_ACRESC"    ,0		            ,NIL},;
							{"E2_PLLOTE"    ,cMesAut+cNumAut    ,NIL},;
							{"E2_PLOPELT"   ,cAnoAut            ,NIL},;
							{"E2_CODRDA"    ,""                 ,NIL},;
							{"E2_ANOBASE"   ,cAnoAut            ,NIL},;
							{"E2_MESBASE"   ,cMesAut            ,NIL},;
							{"E2_NATUREZ" 	,cNat				,NIL},;
							{"E2_DESDOBR" 	,"N"				,NIL},;
							{"E2_DIRF" 		,"2"				,NIL},;
							{"E2_HIST" 		,"PAGTO. REEMBOLSO"	,NIL},;
							{"E2_ORIGEM"	,"PLSA090"			,NIL},;
							{"E2_FORBCO" 		,cBanco				,NIL},;
							{"E2_FORAGE" 		,cAgencia				,NIL},;
							{"E2_FORCTA" 		,cConta				,NIL}}


							lMsErroAuto := .F.

							MsExecAuto({ | a,b | Fina050(a,b) }, aCampos, 3)

							If lMsErroAuto
								DisarmTransaction()
								MostraErro()
								lRetorno := .F.
							Else
								&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")
								&(cAliasCab+"->"+cAliasCab+"_PREFIX"):= cPrefixo
								&(cAliasCab+"->"+cAliasCab+"_NUM")   := cNumTit
								&(cAliasCab+"->"+cAliasCab+"_TIPO")  := cTipo
								&(cAliasCab+"->"+cAliasCab+"_PARCEL"):= ''
								&(cAliasCab+"->"+cAliasCab+"_STATUS") := '5'//atualizo o status para aguardando baixa
								&(cAliasCab+"->( MsUnlock() )")
								lRetorno := .T.
							Endif

						Endif

					Endif

					// ATUALIZA STATUS DA BOW
					PLATUSTBOW({lRet,&(cAliasCab+"->"+cAliasCab+"_OPEMOV"),&(cAliasCab+"->"+cAliasCab+"_ANOAUT"),&(cAliasCab+"->"+cAliasCab+"_MESAUT"),;
					&(cAliasCab+"->"+cAliasCab+"_NUMAUT"),lAut,cCodOpeG,cTipGui,lAuditoria,cStatus,lJaCobLib,lRadio},lProtoc,nOpc, lReembCriaBD5)

					//Sadt ou Consulta
				Else

					nPosTipo := Ascan(aDadBEA,{|x| Alltrim(x[1]) == "BEA_COBESP"})
					IF nPosTipo <> 0 
						cCobEsp = aDadBEA[nPosTipo][2]
					EndIf

					BEA->( RecLock("BEA",nOpc == K_Incluir) )

					If nOpc <> K_Excluir

						For nFor := 1 To Len(aDadBEA)

							If AsCan(aCpoChv,{|x| x == aDadBEA[nFor,1]}) == 0 .And. &( "BEA->( FieldPos('"+aDadBEA[nFor,1]+"') )" ) > 0
								&("BEA->"+aDadBEA[nFor,1]) := aDadBEA[nFor,2]
							Endif

						Next

						If nOpc == K_Incluir
							BEA->BEA_FILIAL := xFilial("BEA")
							BEA->BEA_OPEMOV := cOpeMov
							BEA->BEA_ANOAUT := cAnoAut
							BEA->BEA_MESAUT := cMesAut
							BEA->BEA_NUMAUT := cNumAut
							BEA->BEA_STATUS := cStatus
							BEA->BEA_TIPGUI := cTipGui
							If BEA->(FieldPos("BEA_COBESP")) > 0
								BEA->BEA_COBESP := cCobEsp
							EndIf
							BEA->BEA_STTISS := PLSANLSTIG(cStatus, lAuditoria )
							If BEA->(FieldPos("BEA_GUIIMP")) > 0
								BEA->BEA_GUIIMP := "0"
							Endif
							If Empty(BEA->BEA_TPGRV)
								BEA->BEA_TPGRV  := cTpGrv
							Endif

							// gravacao do numero da impress„o para guia Prestador
							If(lOdontoWeb .and. BEA->(FieldPos("BEA_NUMIMP")) > 0)
							      BEA->BEA_NUMIMP := cOpeMov+cAnoAut+cMesAut+cNumAut
							EndIf

						Endif

						//gravacao dos dados baseando nos campos identicos BE1 X BEA OU BE4 X BEA
						SX3->(DbsetOrder(1))
						If SX3->( MsSeek(cKey) ) .And. ! Empty(cKey)

							SX3->( DbSkip() )
							While ! SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cKey

								cFldTrbBEA := StrTran(SX3->X3_CAMPO,cKey,cAliasCab)

								If 	type( "M->" + allTrim(SX3->X3_CAMPO) ) <> "U" .and. type( cAliasCab + "->" + cFldTrbBEA ) <> "U" .and.;
								asCan(aCpoChv,{|x| alltrim(x) == alltrim(cFldTrbBEA)}) == 0 	.and.;
								asCan(aDadBEA,{|x| alltrim(x[1]) == alltrim(cFldTrbBEA)}) == 0 	.and.;
								asCan(aStrucBEA,{|x| alltrim(x[1]) == alltrim(cFldTrbBEA)}) > 0

									&(cAliasCab+"->"+cFldTrbBEA) := &("M->"+AllTrim(SX3->X3_CAMPO))

								Endif

								SX3->(DbSkip())
							Enddo

						Endif
						&(cAliasCab+"->"+cAliasCab+"_ORIGEM") := cTipoRotEsp

						//Liberacao
						If cTipoRotEsp == "2"

							&(cAliasCab+"->"+cAliasCab+"_LIBERA") := "1"

							if lAuditoria .and. findFunction("PLSSTATUS")
								&(cAliasCab+"->"+cAliasCab+"_STALIB") := "6"
							else
								&(cAliasCab+"->"+cAliasCab+"_STALIB") := "1"
							endIf

						else

							&(cAliasCab+"->"+cAliasCab+"_LIBERA") := "0"

							if &(cAliasCab+"->(FieldPos('"+cAliasCab+"_STALIB"+"'))") > 0
								&(cAliasCab+"->"+cAliasCab+"_STALIB") := ""
							endIf

						endIf

						//Gravacao de campos customizados...
						If Len(aCampCust) > 0
							For nIJ := 1 To Len(aCampCust[1])
								&(aCampCust[1,nIJ,1]+"->"+aCampCust[1,nIJ,2]) := aCampCust[1,nIJ,3]
							Next
						Endif

					Else
						BEA->( DbDelete() )
					Endif
					BEA->( MsUnLock() )
					
					// Quando È uma internaÁ„o a GravaÁ„o da tabela B6M/B6L È realizada na func„o PLSAGRVINT 
					If Len(aDadB6M) > 0 .And. !lIntern 
						PLSPTUGRV(aDadB6M, {cOpeMov, cAnoAut, cMesAut, cNumAut},"B6M")
					EndIf
					
					If Len(aItensB6L) > 0 .And. !lIntern
						PLSPTUGRV(aItensB6L, {cOpeMov, cAnoAut, cMesAut, cNumAut},"B6L")
					EndIf

				EndIf

				//Gravacao dos itens (Procedimentos Medicos)...
				If nOpc <> K_Excluir					

						//Nao e reembolso
						If ! lReembolso

							cAliasIte := "BE2"
							cAliasCri := "BEG"

							dbSelectArea(cAliasIte)

							For nFor := 1 To Len(aStrucBEA)

								cCpoAux := cAliasIte + "_" + subs(aStrucBEA[nFor,1],5,10)

								if type( cAliasIte + "->" + cCpoAux ) <> "U" .and. (nPos := Ascan(aChaveGen,{|x| x[1] == cCpoAux})) == 0
									aadd(aChaveGen,{cCpoAux,&(cAliasCab+"->"+cAliasCab+"_"+Subs(cCpoAux,5,10))})
								endIf

							Next

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_TIPO"})) == 0
								aadd(aChaveGen,{cAliasIte+"_TIPO",&(cAliasCab+"->"+cAliasCab+"_TIPO")})
							Else
								aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_TIPO")
							EndIf

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_OPEINT"})) == 0
								aadd(aChaveGen,{cAliasIte+"_OPEINT",&(cAliasCab+"->"+cAliasCab+"_OPEINT")})
							Else
								aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_OPEINT")
							EndIf

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_ANOINT"})) == 0
								aadd(aChaveGen,{cAliasIte+"_ANOINT",&(cAliasCab+"->"+cAliasCab+"_ANOINT")})
							Else
								aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_ANOINT")
							EndIf

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_MESINT"})) == 0
								aadd(aChaveGen,{cAliasIte+"_MESINT",&(cAliasCab+"->"+cAliasCab+"_MESINT")})
							Else
								aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_MESINT")
							EndIf

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_NUMINT"})) == 0
								aadd(aChaveGen,{cAliasIte+"_NUMINT",&(cAliasCab+"->"+cAliasCab+"_NUMINT")})
							Else
								aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_NUMINT")
							EndIf

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_PRFATD"})) == 0
								aadd(aChaveGen,{cAliasIte+"_PRFATD",BAU->BAU_CODBB0})
							Else
								aChaveGen[nPos,2] := BAU->BAU_CODBB0
							EndIf

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_TIPRDA"})) == 0
								aadd(aChaveGen,{cAliasIte+"_TIPRDA",BAU->BAU_TIPPE})
							Else
								aChaveGen[nPos,2] := BAU->BAU_TIPPE
							EndIf

							If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_CPFRDA"})) == 0
								aadd(aChaveGen,{cAliasIte+"_CPFRDA",BAU->BAU_CPFCGC})
							Else
								aChaveGen[nPos,2] := BAU->BAU_CPFCGC
							EndIf
						Else

							//Reembolso
							cAliasIte := "B45"
							cAliasCri := "B46"

							dbSelectArea(cAliasIte)

						EndIf

						If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_OPEMOV"})) == 0
							aadd(aChaveGen,{cAliasIte+"_OPEMOV", &(cAliasCab+"->"+cAliasCab+"_OPEMOV") })
						Else
							aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
						EndIf

						If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_ANOAUT"})) == 0
							aadd(aChaveGen,{cAliasIte+"_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
						Else
							aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_ANOAUT")
						EndIf

						If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_MESAUT"})) == 0
							aadd(aChaveGen,{cAliasIte+"_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
						Else
							aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_MESAUT")
						EndIf

						If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_NUMAUT"})) == 0
							aadd(aChaveGen,{cAliasIte+"_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})
						Else
							aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")
						EndIf

						If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_AUDITO"})) == 0
							aadd(aChaveGen,{cAliasIte+"_AUDITO",""})
						Else
							aChaveGen[nPos,2] := ""
						EndIf

						If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_TPGRV"})) == 0
							aadd(aChaveGen,{cAliasIte+"_TPGRV",&(cAliasCab+"->"+cAliasCab+"_TPGRV")})
						Else
							aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_TPGRV")
						EndIf

					

				Else

					If lReembolso
						cAliasIte := "B45"
						cAliasCri := "B46"
					Else
						cAliasIte := "BE2"
						cAliasCri := "BEG"
					EndIf

				EndIf

				//Quando for ConfirmaÁ„o de Liberacao o aCols e atualizado com o Numero de Autorizacao
				If UPPER(Alltrim(FunName())) $ "PLSA097/PLSA552"

					For nI := 1 To Len(aColsITE)
						aColsITE[nI][nPos := aScan(aHeaderITE,{|X| X[2]=="BE2_NUMAUT"})] := BEA->BEA_NUMAUT
					Next nI

				Endif

				//Gravacao
				PLUPTCOLS(cAliasIte,aColsITE,aHeaderITE,aVetTrab,nOpc,aChaveGen,,,,,iif(lIntern,.t.,.f.))

				//Checagem
				If Len(aDadCri) > 0

					//Retirar critica sem descricao
					PLSAJUMAT(aCabCri,aDadCri,cAliasCri+"_DESGLO")

					//Se reenvio Ptu de internacao, ajusta Alias da Critica
					If Type("lBtnOn") <> 'U' .And. lBtnOn .And. lIntern

						aChaveGen := {}
						aadd(aChaveGen,{"BEL_CODOPE",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
						aadd(aChaveGen,{"BEL_ANOINT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
						aadd(aChaveGen,{"BEL_MESINT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
						aadd(aChaveGen,{"BEL_NUMINT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})

						//Chave da critica
					Else
						aChaveGen := {}
						aadd(aChaveGen,{cAliasCri+"_OPEMOV",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
						aadd(aChaveGen,{cAliasCri+"_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
						aadd(aChaveGen,{cAliasCri+"_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
						aadd(aChaveGen,{cAliasCri+"_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})
					EndIf

					//Ajusta aTrbCri
					If Type("lBtnOn") <> 'U' .And. lBtnOn

						aTrbCri := {}

						If lIntern

							cAliasCri := "BEL"

							//Prepara  para poder gravar  internacao x sadt
							//Troca o nome e testa se existe
							plChkHECO('BEG','BEL',@aCabCri,@aDadCri)

							//Deleta criticas ja existentes
							BEL->(DbSetOrder(1))//BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN+BEL_CODGLO
							If BEL->(DbSeek(xFilial("BEL")+&(cAliasCab+"->"+cAliasCab+"_OPEMOV")+&(cAliasCab+"->"+cAliasCab+"_ANOAUT")+&(cAliasCab+"->"+cAliasCab+"_MESAUT")+&(cAliasCab+"->"+cAliasCab+"_NUMAUT")))

								cKeyCri := BEL->(BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT)

								While xFilial("BEL")+BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT) == cKeyCri .And. !BEL->(Eof())

									BEL->(RecLock("BEL",.F.))
									BEL->(DbDelete())
									BEL->(MsUnLock())

									BEL->(DbSkip())
								EndDo

							Endif

						Else

							//Deleta criticas ja existentes
							BEG->(DbSetOrder(1))//BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
							If BEG->(DbSeek(xFilial("BEG")+&(cAliasCab+"->"+cAliasCab+"_OPEMOV")+&(cAliasCab+"->"+cAliasCab+"_ANOAUT")+&(cAliasCab+"->"+cAliasCab+"_MESAUT")+&(cAliasCab+"->"+cAliasCab+"_NUMAUT")))

								cKeyCri := BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)

								While xFilial("BEG")+BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT) == cKeyCri .And. !BEG->(Eof())

									BEG->(RecLock("BEG",.F.))
									BEG->(DbDelete())
									BEG->(MsUnLock())

									BEG->(DbSkip())
								EndDo

							Endif

						EndIf

					EndIf

					//Grava
					If Len(aDadCri) > 0
						PLUPTCOLS(cAliasCri,aDadCri,aCabCri,aTrbCri,nOpc,aChaveGen,.T.)
					EndIf

				EndIf

				//Composicao do reembolso
				If nOpc == K_Incluir

					If ValType(oBrwB47) <> 'U' .and. Len(oBrwB47:aCols) > 0 .And. !lGuiHoRe
						aChaveGen := {}
						aadd(aChaveGen,{cAliasCmp+"_OPEMOV",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
						aadd(aChaveGen,{cAliasCmp+"_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
						aadd(aChaveGen,{cAliasCmp+"_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
						aadd(aChaveGen,{cAliasCmp+"_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})
						oBrwB47:nOpc := nOpc
						oBrwB47:Grava(aChaveGen)
					EndIf

					If Len(aDadB43) > 0
						aChaveGen := {}
						aadd(aChaveGen,{"B43_OPEMOV",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
						aadd(aChaveGen,{"B43_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
						aadd(aChaveGen,{"B43_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
						aadd(aChaveGen,{"B43_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})
						PLUPTCOLS("B43",aDadB43,aCabB43,aTrbB43,nOpc,aChaveGen,.T.)
					EndIf
				EndIf

				//GRAVA OS EXECUTANTES
				If PGetTisVer() >= '3' .And. nOpc == K_Incluir

					If Len(aColsB4B)>0

						aChaveGen := {}
						aadd(aChaveGen,{"B4B_OPEMOV",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
						aadd(aChaveGen,{"B4B_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
						aadd(aChaveGen,{"B4B_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
						aadd(aChaveGen,{"B4B_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})

						For nC := 1 To Len(aChaveGen)
							nI := Ascan(aHeaderB4B, { |x| x[2] == aChaveGen[nC,1]})
							If nI > 0
								For nForC := 1 To Len(aColsB4B)
									aColsB4B[nForC,nI]:= aChaveGen[nC,2]
								Next nForC
							EndIf
						Next nC

						PLUPTCOLS('B4B',aColsB4B,aHeaderB4B,aVetB4B,nOpc,aChaveGen,.T.)

					EndIf

				EndIf

				//Gravacao Dente e Faces

				If !lGuiHoRe .And. !lResInt

					//Grava BYT - Dentes/Faces Guia Odontologica...

					If nOpc == K_Incluir

						If (ValType(oBrwEven) <> 'U' .Or. lWeb) .And. Len(aColsDF)>0

							aChaveGen := {}
							aadd(aChaveGen,{"BYS_OPEMOV",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
							aadd(aChaveGen,{"BYS_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
							aadd(aChaveGen,{"BYS_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
							aadd(aChaveGen,{"BYS_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})

							For nC=1 To Len(aChaveGen)

								nI := Ascan(aHeaderDF, { |x| x[2] == aChaveGen[nC,1]})
								If nI > 0
									For nForC := 1 To Len(aColsDF)
										aColsDF[nForC,nI]:= aChaveGen[nC,2]
									Next nForC
								EndIf
							Next nC

							PLUPTCOLS('BYS',aColsDF,aHeaderDF,aVetDF,nOpc,aChaveGen,.T.)

						EndIf

					EndIf

					// esta vindo do portal e ja esta sendo executa portanto a guia n„o pode ficar mais bloqueada
					// !lPTUOnSol -> Unimed VS solicitou que guias solicitadas no Portal Prestador entrem como bloqueadas
					If (!lReembolso .and. FUNNAME()=="RPC" .and. (&(cAliasCab+"->"+cAliasCab+"_ORIGEM") == "1" .or. lForBloq)) .And. (!lPTUOnSol .Or. lBloqGct)
						cSituac := "1"
					Endif

					IF !lReembolso .and. (&(cAliasCab+"->"+cAliasCab+"_ORIGEM") == "2") .AND. (cCodLdp == cLocDigP)   //R7
						cSituac := "1"
					ENDIF

					If !lReembolso .and. (&(cAliasCab+"->"+cAliasCab+"_ORIGEM") == "2") .AND. (cCodLdp <> cLocDigP)  .or. lForBloq //R7
						cSituac := "3"
					Else
						If &(cAliasCab+"->"+cAliasCab+"_STATUS") $ "3,5" .And. !lIncNeg .And. lAuditoria
							cSituac := "3"
						Endif
					EndIf
					If FUNNAME()=="PLSA094A" .And. lAuditoria .Or. FUNNAME()=="RPC" .And. lAuditoria
						cSituac := "3"
					EndIf

					if ExistBlock("PL090SIT")
						cSituac  := ExecBlock("PL090SIT",.F.,.F.,{aDadBEA,aColsITE,aHeaderITE,cSituac,nItensAut,nItensNeg,nAuditNeg,lAuditoria} )
					endIf

				EndIf

			EndIf

			//Nao entra se for processo online somente atualiza nao precisa mudar a fase≥
			If nOpc <> K_Excluir

				If UPPER( Alltrim( FunName() ) )=="PLSA097"

					For nI:= 1 To Len(aColsITE)
						If (nPos := ascan(aHeaderITE,{|x| x[2] == "BE2_NUMAUT"})) > 0
							aColsITE[nI][nPos] := BEA->BEA_NUMAUT
						EndIf
					Next nI

				EndIf

				//se for reembolso verifica se pode criar BD5 ou n„o.
				if ! lReembolso .or. (lReembolso .and. lReembCriaBD5)
					lPos090MF := .T.
				endif
				
				//Se Auto Online PTU, atualiza Status da Guia
				If lBtnOn
					lBtnOnMF := .T.
				endIf
				
			endIf

			//Matriz autfor
			If lReembolso
				aAutFor := Pl001AuF()
			EndIf

			If lOdontoWeb
				aAutFor := Pl090ODAuF()
				lMudarFase	:= .t.
			ElseIf lOdonto
				aAutFor := Pl090ODAuF()
			Endif

			//Historico de autorizacao forÁada
			If ValType(aAutFor) == "A" .and. len(aAutFor) > 0
				//Devo rodar o aAutFor e verificar se o registro correspondente 
				//no aColsITE est· marcado como deletado
				if len(aAutFor[1]) >= 14 .And. len(aHeaderITE) > 0 
					nPosSeq := Ascan(aHeaderITE,{|x|x[2] == cAliasIte+"_SEQUEN"})
					if nPosSeq > 0
						aDelAutFor := {}
						for nFor := 1 to len(aAutFor)
							//Verifica se o item esta deletado no Browse
							if aScan(aColsITE,{|x| x[nPosSeq] == aAutFor[nFor,14]  .and. x[len(aHeaderITE)+1] }) > 0 
								aadd(aDelAutFor,nFor)
							endIf
						next

						//Monto aAux para auxiliar na delecao do aAutFor e _aCopHCri 
						if len(aDelAutFor) > 0 
							aAux := Array(len(aDelAutFor)) 
							for nFor := 1 to len(aDelAutFor)
								aAux[nFor] := aDelAutFor[(len(aDelAutFor) + 1 ) - nFor]
							next
						endIf	

						//Deleto fisicamente do aAutFor e _aCopHCri 
						for nFor := 1 to len(aAux)
							nSize := len(aAutFor)
							aDel(aAutFor,aAux[nFor])
							aSize(aAutFor,nSize-1)

							nSize := len(_aCopHCri)
							aDel(_aCopHCri,aAux[nFor])
							aSize(_aCopHCri,nSize-1)
						next	
					
					endIf
				endIf
				//Grava fisicamente os registros nas tabelas BDS e B67		
				if len(aAutFor) > 0 
					PLSFORHIS(nOpc,Iif(lReembolso,'5',IIF(cTipoRotEsp == "2","1",BEA->BEA_TIPO)),cAliasCab,aAutFor,_aCopHCri)
				endIf	
			EndIf

			//Se o Titulo foi comprado e deve ser pago no ato grava titulo a receber...≥
			//Compra que deve ser liquidado o titulo antes de liberar a autorizacao

			If nOpc <> K_Excluir .And. cStatus == "5" .And. ! lAuditoria .and. !lReembolso .And. !lJaCobLib
				lTitAtoMF := .T.
			Endif
	
		Endif

		DbCommitAll()
	End Transaction

	//Determina a integraÁ„o  com HealthMap para os itens de urgencia e emergencia
	If BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+BEA->BEA_TIPADM)) .And. BDR->BDR_CARINT == "U"  .And. FindFunction("PLMapIntAviso")
		PLMapIntAviso(cOpeMov, cAnoAut, cMesAut, cNumAut,,,'BEA')
	EndIf
	

	// PLSA090MF foi movido para fora do Begin Transaction pois gerava erros de numeracao 
	// junto ao semaforo, trechos posteriores que dependiam de parametros desta chamada
	// e manipulacao de BD5/BE4 tambem foram movidos para este trecho:
	if lPos090MF
		if !lJobAc .Or. cStatus == "5"  //o PLSA090MF por JOB n„o atende pgto no ato (status == "5"), portanto deve entrar aqui

			aRetMF := PLSA090MF(cOpeMov,cAnoAut,cMesAut,aColsITE,aHeaderITE,nOpc,cMatUsa,cAnoPag,cMesPag,cTipGui,lIntern,;
					cNumGuia,lAutori,cSituac,cCodLDP,lReanaliza,lVeioComu,lExcluiAte,;
					lNMudFase,lReembolso,cAliasCab,oBrwB47,lIncNeg,cObsoleto,lSolicit,@lMudarFase,;
					@cAliasPri,aMatCom,cTpGrv,cLotGui,lResInt,lGuiHoRe,aPartic,lOdonto,cArqImp, lRecGlo,lWeb,;
					nil,lSUS,aArraySUS,,,cRdaExe, lJaCobLib)

					cCodOpeG := aRetMF[1]			
		else
			lMudarFase := .T.
		endIf	
	endIf	

	//Se Auto Online PTU, atualiza Status da Guia
	if lBtnOnMF
		//Autorizada
		if ( nItensNeg == 0 .And. nItensAut >= 1 )
			cStatus := "1" 
			Iif(BEA->BEA_LIBERA == "1" .And. !BEA->BEA_TIPGUI $ "03/05",cSituac := "3",cSituac := "1")
		
		//Autorizada parcialmente
		elseIf ( nItensNeg > 0  .And. nItensAut >= 1 )
			cStatus := "2" 
			Iif(BEA->BEA_LIBERA == "1",cSituac := "3",cSituac := "1")
		
		//nao autorizada	
		elseIf ( nItensNeg > 0 .and. nItensAut == 0 )
			cStatus := "3" 
			cSituac := "3"
		endIf

		if lAuditoria
			cStatus := '6'
		endIf

		PLSSTAGUI(cOpeMov,cAnoAut,cMesAut,BEA->BEA_NUMAUT,cSituac,nil,nil,.t.,,,,,,Iif(cStatus=="1",.t.,.f.),cSenhaOpe,nNrSeqTR,cStatus,,,,,lBtnOn,Iif(nItensNeg > 0 .And. nItensAut == 0, .T., .F.))

		//Se internacao atualizo as criticas
		If BEA->BEA_TIPGUI == '03' .and. cStatus == '1' .and. ! empty(nNrSeqTR)

			BEL->(dbSetOrder(1))//BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN
			If BEL->(DbSeek(xFilial("BEL")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))

				while xFilial("BEA")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("BEL")+BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT) .And. !BEL->(Eof())

					BEL->(recLock("BEL",.F.))
					BEL->( DbDelete())
					BEL->(MsUnLock())

					BEL->(dbSkip())
				endDo
			endIf
		endIf
	endIf

	
	If nOpc <> K_Excluir .And. ExistBlock("PLS090GR")
		aRetB7B := PlDeseraliza(strJsonB7B)
	endif 

	//Grava mensagens complementares de intercambio
	If ValType(oGetBZC) == "O" .And. nOpc == K_Incluir .And. len(oGetBZC:aCols) > 0 .And. !oGetBZC:aCols[1,len(oGetBZC:aHeader)+1]
		AaDd(aChavBZC,{"BZC_FILIAL",xFilial("BZC")})
		AaDd(aChavBZC,{"BZC_CHVGUI",&(cAliasCab+"->"+cAliasCab+"_FILIAL")+&(cAliasCab+"->"+cAliasCab+"_OPEMOV")+&(cAliasCab+"->"+cAliasCab+"_CODLDP")+&(cAliasCab+"->"+cAliasCab+"_CODPEG")+&(cAliasCab+"->"+cAliasCab+"_NUMGUI") })
		AaDd(aChavBZC,{"BZC_ALIAS",IIF(!Empty(cAliasPri),cAliasPri,cAliasCab) })
		oGetBZC:Grava(aChavBZC,.T.)
		FreeObj(oGetBZC)
	EndIf

	If ExistBlock("PLS090GR")
		ExecBlock("PLS090GR",.F.,.F.,{nOpc,lAutori,lReembolso,cOpeMov,cAnoAut,cMesAut,cNumAut,aRetB7B,lWeb})
	Endif	
	
	//Evolucao de SADT
ElseIf nOpc == K_Evolucao

	lGrvEvoSad := .T.

	Begin Transaction

		//Posiciona na execucao
		BEA->(DbGoTo(nRecAutEVO))

		dDatInt := BEA->BEA_DATPRO
		If Empty(dDatInt)
			dDatInt := dDataBase
		Endif

		aAreaBEAEv := BEA->(GetArea())

		For nI:=1 to Len(oBrwBQV090:ACOLS)

			// Se a linha nao esta deletada
			If !oBrwBQV090:aCols[nI,Len(oBrwBQV090:aHeader)+1]

				lIncBD6BQV := .T.
				If oBrwBQV090:aVetTrab[nI] > 0

					// Pega a sequencia
					cSequen := oBrwBQV090:FieldGet("BQV_SEQUEN",nI)

					// Ordem e verifica se existe no BD6
					BD6->( DbSetOrder(1) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
					If BD6->( MsSeek( xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+cSequen ) )
						lIncBD6BQV := .F.
					EndIf
				EndIf

				//Espelha BD6 e BD7

				If lIncBD6BQV

					// Inclui a Senha
					If Empty( oBrwBQV090:FieldGet("BQV_SENHA",nI) )
						If lPl90L1    
							cSenhaPLS := ExecBlock("PLS090L1",.F.,.F.,{"3",.F.,dDatInt})
						Else
							cSenhaPLS := PLSSenAut(dDatInt)
						Endif		

						//Atualiza a senha

						oBrwBQV090:FieldPut("BQV_SENHA",cSenhaPls,nI)
					Else
						cSenhaPls := oBrwBQV090:FieldGet("BQV_SENHA",nI)
					EndIf

					cSequen := A090BQVSad(nOpc,cSenhaPls,oBrwBQV090:FieldGet("BQV_CODPAD",nI),oBrwBQV090:FieldGet("BQV_CODPRO",nI),oBrwBQV090:FieldGet("BQV_QTDSOL",nI),;
					oBrwBQV090:FieldGet("BQV_HORPRO",nI),oBrwBQV090:FieldGet("BQV_SEQUEN",nI),oBrwBQV090:FieldGet("BQV_NIVAUT",nI),oBrwBQV090:FieldGet("BQV_NIVCRI",nI),;
					oBrwBQV090:FieldGet("BQV_CHVNIV",nI),/*cLotGui*/,oBrwBQV090:FieldGet("BQV_DATPRO",nI),.T.)

					// Verifica se a sequencia esta diferente dos itens no bd6
					If oBrwBQV090:FieldGet("BQV_SEQUEN",nI) <> cSequen

						// Atualiza a sequencia do BQZ
						While Eval( {|| nPos := Ascan( oBrwBQZ090:aCols,{|x| x[ PLRETPOS("BQZ_SEQUEN",oBrwBQZ090:aHeader) ] == oBrwBQV090:FieldGet("BQV_SEQUEN",nI) } ), nPos > 0} )
							oBrwBQZ090:FieldPut("BQZ_SEQUEN",cSequen,nPos)
						EndDo

						// Atualiza a sequencia do BQV
						oBrwBQV090:FieldPut("BQV_SEQUEN",cSequen,nI)
					EndIf

				EndIf

			Else

				//Se esta deletado e tem aVetTrab e pq ja gravou no BD6 e BD7
				If oBrwBQV090:aVetTrab[nI] > 0

					// Pega a sequencia
					cSequen := oBrwBQV090:FieldGet("BQV_SEQUEN",nI)

					// Ordem e verifica se existe no BD6
					BD6->( DbSetOrder(1) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
					If BD6->( MsSeek( xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+cSequen ) )

						// Ordem e procura os BD7 para excluir
						BD7->(DbSetOrder(1))
						While BD7->( MsSeek(xFilial("BD7")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+cSequen) )
							BD7->(RecLock("BD7",.F.))
							BD7->(DbDelete())
							BD7->(MsUnLock())
						Enddo

						// BD6
						BD6->(RecLock("BD6",.F.))
						BD6->(DbDelete())
						BD6->(MsUnLock())
					Endif
				EndIf
			Endif

		Next nI

		//Retorna fase

		aAreaBEA := BEA->(GetArea())
		DbselectArea("BD5")
		DbSetOrder(1)
		IF DbSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI))//BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO

			PLSA500RFS("BD5",BD5->(RECNO()),nOpc,,.T.)
			// Muda fase
			PLSXMUDFAS("BD5","1","",cTipGui,dDataBase,.F.,"3")

		Endif
		RestArea(aAreaBEA)

		//Grava itens BQV

		aChave := {}
		aadd(aChave,{"BQV_CODOPE",BEA->BEA_OPEMOV})
		aadd(aChave,{"BQV_ANOINT",BEA->BEA_ANOAUT})
		aadd(aChave,{"BQV_MESINT",BEA->BEA_MESAUT})
		aadd(aChave,{"BQV_NUMINT",BEA->BEA_NUMAUT})
		aadd(aChave,{"BQV_OPEUSR",BEA->BEA_OPEUSR})
		aadd(aChave,{"BQV_CODEMP",BEA->BEA_CODEMP})
		aadd(aChave,{"BQV_MATRIC",BEA->BEA_MATRIC})
		aadd(aChave,{"BQV_TIPREG",BEA->BEA_TIPREG})
		aadd(aChave,{"BQV_DIGITO",BEA->BEA_DIGITO})

		oBrwBQV090:Grava(aChave)

		//Grava criticas BQZ
		oBrwBQZ090:nOpc := 4 //Altera nOpc para realizar a gravacao

		//Ajusta aCols eliminando registros em branco
		For nI := 1 to len(oBrwBQZ090:aCols)

			If Empty(oBrwBQZ090:aCols[nI][aScan(oBrwBQZ090:aHeader,{|x|x[2] == "BQZ_CODGLO"})]) .And. ;
			Empty(oBrwBQZ090:aCols[nI][aScan(oBrwBQZ090:aHeader,{|x|x[2] == "BQZ_DESGLO"})])

				oBrwBQZ090:aCols[nI][len(oBrwBQZ090:aHeader)+1] := .T.
			EndIf

		Next

		aChave := {}
		aadd(aChave,{"BQZ_CODOPE",BEA->BEA_OPEMOV})
		aadd(aChave,{"BQZ_ANOINT",BEA->BEA_ANOAUT})
		aadd(aChave,{"BQZ_MESINT",BEA->BEA_MESAUT})
		aadd(aChave,{"BQZ_NUMINT",BEA->BEA_NUMAUT})
		oBrwBQZ090:Grava(aChave)

		RestArea( aAreaBEAEv )

		DbCommitAll()

		If Len(aDadB6M) > 0 
			PLSPTUGRV(aDadB6M, {BEA->BEA_OPEMOV, BEA->BEA_ANOAUT, BEA->BEA_MESAUT, BEA->BEA_NUMAUT},"B6M")
		EndIf

		If Len(aItensB6L) > 0
			PLSPTUGRV(aItensB6L, {BEA->BEA_OPEMOV, BEA->BEA_ANOAUT, BEA->BEA_MESAUT, BEA->BEA_NUMAUT},"B6L")
		EndIf

	End Transaction

Endif

//PromoÁ„o da Sa˙de

If lMVPromo
	BOM->(DbSetOrder(3))
	If BOM->(MsSeek(xFilial("BOM") + BTS->BTS_MATVID+"0"))

		BOA->(DbSetOrder(1))
		IF BOA->(MsSeek(xFilial("BOA") + BOM->BOM_CODPRO))
			PLSPROALE("",STR0525,dDataBase,Time(),"3",BTS->BTS_MATVID, "0",; //"Paciente È elegivel e ainda nao foi inscrito no programa!"
			STR0526 +  "  "+Alltrim(BTS->BTS_NOMUSR) +; //	"O Paciente "
			"  "+STR0527 + BOA->BOA_DESPRO + STR0528 ,; //" È elegivel ao programa " ### " realizou procedimento e ainda n„o foi inscrito no programa"
			,BOM->BOM_CODPRO,"",BOM->BOM_CODLOC) //"Verificar junto ao participante!"
		Endif

	Endif
	If lMVVEleg // VERIFICA ELEGIVEIS NO MOMENTO DA CONFIRMACAO
		PLSELEG(,BTS->BTS_MATVID, , , , , .T., /*cCodCrm*/)
	EndIf
Endif


If !lPlNumPr
	PLSFechaSem(nH1,"P090SEMDEF.SMF")
Endif

//Salva posicao

DbSelectArea("BEA")
nRecBEA := BEA->(Recno())

//MudanÁa de fase fora da transaÁ„o

Begin Transaction

	If lMudarFase .And. (!lJaMudou .Or. lJobAc) 
	    
		if !lJobAc
			cCpoFase := (cAliasPri+"->"+cAliasPri+"_FASE")
      	endIf

		If BCL->BCL_TIPGRV == "1"

			If lPtuOnline .and. GetNewPar("MV_PLTHPTU","0") == "1"

				aEmp 	:= GetEmpPtu()

				StartJob("U_PLMUDFASPT",GetEnvServer(),.F.,aEmp[1],aEmp[2],BCL->(Recno()),&(cAliasCab+"->(Recno())"),cAliasPri,cAliasCab,lAutori,aItensGlo,;
				lReanaliza,lSolicit,lPagAto,cChaveLib,lGetCri,lProtoc,lRecGlo,&(cAliasPri+"->(Recno())"),;
				BCI->(Recno()),nRecBEA,aAreaBD6,nOpc,lReembolso,aAreaBE2)

				// O portal/tiss online n„o precisa esperar que a guia mude de fase, isso n„o interessa no momento para o prestador, podemos fazer em segundo plano pq o link do portal n„o pode esperar (digitar 20 itens em uma guia nunca concluia)
			elseIf lJobAc .And. nOpc <> K_Excluir .And. cStatus <> "5"  
				
				aDadRda   := PLSGETRDA()       
				aPar90JOB := {cOpeMov,cAnoAut,cMesAut,aColsITE,aHeaderITE,nOpc,cMatUsa,cAnoPag,cMesPag,cTipGui,lIntern,cNumGuia,lAutori,cSituac,;
							  cCodLDP,lReanaliza,lVeioComu,lExcluiAte,lNMudFase,lReembolso,cAliasCab,oBrwB47,lIncNeg,cObsoleto,lSolicit,lMudarFase,;
							  @cAliasPri,aMatCom,cTpGrv,cLotGui,lResInt,lGuiHoRe,aPartic,lOdonto,cArqImp, lRecGlo,lWeb,nil,lSUS,aArraySUS,aDadRda,.T.}

				aParMFJOB := {cAliasPri,"1",BCL->BCL_CODOPE,cTipGui,&(cAliasCab+"->"+cAliasCab+"_DATPRO"),lAutori,nil,nil,nil,.F.,aItensGlo,nil,lReanaliza,.F.,;
				nil,nil,nil,nil,nil,nil,nil,lSolicit,Nil,lPagAto,cChaveLib,.F.,lGetCri, lProtoc,lRecGlo}

				// Thread para mudar a fase - Tenho que usar array pela limitaÁ„o de parametros do JOB
				PLMFEMJOB( BCL->(recno()),(cAliasCab)->(recno()), BCI->(recno()), cAliasCab, BAU->(recno()),aParMFJOB, aPar90JOB,aDadRda,cAliasIte,&(cAliasIte+"->(Recno())"))

			Else

				PLSXMUDFAS(cAliasPri,"1",BCL->BCL_CODOPE,BCL->BCL_TIPGUI,&(cAliasCab+"->"+cAliasCab+"_DATPRO"),lAutori,;
				nil,nil,nil,.f.,aItensGlo,nil,lReanaliza,.f.,nil,nil,nil,nil,nil,nil,nil,lSolicit,nil,;
				lPagAto,cChaveLib,.f.,lGetCri, lProtoc,lRecGlo)

			EndIf


		Else
			aRetAux := ExecBlock(BCL->BCL_FUNMFS,.F.,.F.,{cAliasPri,"2",&(cAliasCab+"->"+cAliasCab+"_OPEMOV"),"2",&cCpoFase,;
			BCI->BCI_CODLDP,BCI->BCI_CODPEG,"",BCL->BCL_GUIREL,lAutori,&(cAliasCab+"->"+cAliasCab+"_DATPRO"),.F.,;
			BCL->BCL_ALIAS,nil,nil,lReanaliza,.F.,nil,nil,nil,nil,nil,nil,nil,lSolicit,Nil,lPagAto,cChaveLib})
		Endif

	Endif

	If nOpc <> K_Visualizar .And. nOpc <> K_VisOnline .And. !(lPtuOnline .And. GetNewPar("MV_PLTHPTU","0") == "1")

		If GetNewPar("MV_PLADPAG","0") == "1" .and. !lReembolso

			If nOpc <> K_Excluir

				PLS90CRDB(BEA->BEA_OPERDA,BEA->BEA_CODRDA,BEA->BEA_CODLDP,BEA->BEA_CODPEG,BEA->BEA_NUMGUI,;
				BEA->BEA_OPEUSR,BEA->BEA_CODEMP,BEA->BEA_MATRIC,BEA->BEA_TIPREG,BEA->BEA_CONEMP,;
				BEA->BEA_VERCON,GetNewPar("MV_PLCDADC","901"),nOpc)
			Else

				PLS90CRDB(BEA->BEA_OPERDA,BEA->BEA_CODRDA,BEA->BEA_CODLDP,BEA->BEA_CODPEG,BEA->BEA_NUMGUI,;
				BEA->BEA_OPEUSR,BEA->BEA_CODEMP,BEA->BEA_MATRIC,BEA->BEA_TIPREG,BEA->BEA_CONEMP,;
				BEA->BEA_VERCON,GetNewPar("MV_PLCDADD","900"),nOpc)

			EndIf

		EndIf

	Endif

	_aCopHCri := {}
	aAutFor  := {}

End Transaction

//Posicao original

BEA->( DbGoTo(nRecBEA) )

//Verificando se a Guia foi comprada no ato, esse item pode ser feito pelo PE ou pelo campo combo
If !Empty(cAliasPri) .And. &(cAliasPri+"->(FieldPos('"+cAliasPri+"_PAGATO'))") > 0 .and. !lAuditoria
	If &(cAliasPri+"->"+cAliasPri+"_PAGATO") =='1' .And. nOpc <> K_Excluir
		lTitAtoMF	:=.T.
		cStatus		:= '5'
	Endif	
EndIf

// Verifica se possui uma liberaÁ„o, caso tenha e a mesma seja Pagamento no Ato,
// Tenha TÌtulo baixado e tenha vindo da LiberaÁ„o, n„o gerar· um novo TÌtulo
If !Empty(BEA->BEA_NRLBOR)
	
	aAreaAutBEA:= BEA->(GetArea())
	cNumNRL := BEA->BEA_NRLBOR

	BEA->(DbSetOrder(1))
	If BEA->(DbSeek(xFilial("BEA")+cNumNRL))
		If BEA->BEA_PAGATO == "1" .And. !Empty(BEA->BEA_NUMTIT) .And. BEA->BEA_LIBERA == "1"
			lTitAtoMF	:=.F.
		EndIf
	EndIf

	RestArea( aAreaAutBEA )
EndIf

//Se o Titulo foi comprado e deve ser pago no ato grava titulo a receber
//Compra que deve ser liquidado o titulo antes de liberar a autorizacao
if lTitAtoMF .And. nOpc <> K_Excluir		
	if GetNewPar("MV_PLSIFIN","1") == "1"

		cPrefixo := GetNewPar("MV_PLSPRCP","CPP")
		cParcTit := Space( Len(SE1->E1_PARCELA) )
		cTipTit  := GetNewPar("MV_PLSTPCP","FT")

		If cPaisLoc == "BRA"
			cNumTit  := PLSE1NUM(cPrefixo)
			cChavSE1 := cPrefixo+cNumTit
		Endif

		nPos :=  Ascan(aDadBEA,{|x| Alltrim(x[1]) = cAliasCab+"_DATPRO"})
		If nPos >0
			dVencto  := aDadBEA[nPos][2]+GetNewPar("MV_PLSVCGC",0)
		Else
			dVencto  := dDataBase+GetNewPar("MV_PLSVCGC",0)
		EndIf
		
		PLSProcAto(	cAliasPri,cAliasCab,cAliasIte,cMatric,cTipoRotEsp,aDadUsr,lAutori,lReanaliza,lWeb,lMudarFase,;
		.F.,lSolicit,cChaveLib,nil,@dVencto,@cChavSE1,@cTipTit,@cParcTit,@cPrefixo,@cNumTit,@lJaMudou)
		lJobAc := .F.
	else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0108 , 0, 0, {})//"A Guia foi comprada porem o titulo a receber nao foi gerado em funcao do parametro MV_PLSIFIN"	
	endif
endIf

//Ticket 6329946, DSAUATE-3480
//Criado PE para Vale gerar B53 de atendimentos PTU Online
//Foi criada essa possibilidade porque o Remote ja estava permitindo a criacao
if cCodEmp == GetNewPar("MV_PLSGEIN","0050") .Or. lVeioComu
	if ExistBlock("P90PTB53")
		lTissOn := IsInCallStack("PROCONLINE")
		lGerB53 := ExecBlock("P90PTB53",.F.,.F., {lVeioComu,lTissOn,aDadBEA,aColsITE,aHeaderITE})
	else
		IIF(!lVeioComu,lGerB53 := .T.,lGerB53 := .F.) //Padrao nao gera B53 se guia de intercambio PTU Online
	endIf

	If lGerB53 .And. (lEvolu .Or. lEvoSADT)
		cAliasIte := "BQV"
		cAliasCri := "BQZ"
	EndIf
endIf

//Se alias existir e for auditoria e nao veio do ptu-online

If FindFunction("PLSA790C") .And. PLSALIASEXI("B53") .And. lGerB53 .And. (lAuditoria .Or. lPartic) .and. GetNewPar("MV_PL790NE","0")<>"0"

	//Grava na auditoria
	o790C := PLSA790C():New(.T.)

	o790C:SetAuditoria(lAuditoria,lIntern,lEvolu,lReembolso,lPartic,aDadCri,aCabCri,__aCdCri187[1],PLSRETDAD( aDadBE4,"BE4_REGINT","0" ),cAliasCri,aColsITE,aHeaderITE,cAliasIte,,,)

	o790C:Destroy()

	//Executa funcinalidade Auditoria/Fluig
	If lFluig
		PLSAUDFLG()
	EndIf

EndIf

If !(lPtuOnline .And. GetNewPar("MV_PLTHPTU","0") == "1")

	BEA->( DbGoTo(nRecBEA) )

	cChaveBD5 := BEA->(BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI)
	cChaveBEA := BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)

	If BE2->(FieldPos("BE2_VLPGGU")) > 0
		BE2->(DbSetOrder(1))//BE2_FILIAL, BE2_OPEMOV, BE2_ANOAUT, BE2_MESAUT, BE2_NUMAUT, BE2_SEQUEN
		If BE2->(MsSeek(xFilial("BE2")+cChaveBEA))
			While ! BE2->(Eof()) .And. xFilial("BE2")+cChaveBEA == BE2->(BE2_FILIAL+BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT)
				BD6->(DbSetOrder(1))
				nValPag := 0
				If BD6->(MsSeek(xFilial("BD6")+cChaveBD5+BEA->BEA_ORIMOV+BE2->BE2_SEQUEN))
					nValPag := BD6->BD6_VLRPAG
					Restarea(aAreaBD6)
				EndIf

				If nValPag > 0
					BE2->(RecLock("BE2",.F.))
					BE2->BE2_VLPGGU := nValPag
					BE2->(MsUnLock())
				EndIf
				BE2->(DbSkip())
			EndDo
			Restarea(aAreaBE2)
		EndIf
	Endif
EndIf

//Atualiza as guias de Anexo - PTU Online
If !(lPtuOnline .And. GetNewPar("MV_PLTHPTU","0") == "1")

	BEA->( DbGoTo(nRecBEA) )

	cChaveBD5 := BEA->(BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI)
	cChaveBEA := BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)

	If BE2->(FieldPos("BE2_VLPGGU")) > 0
		BE2->(DbSetOrder(1))//BE2_FILIAL, BE2_OPEMOV, BE2_ANOAUT, BE2_MESAUT, BE2_NUMAUT, BE2_SEQUEN
		If BE2->(MsSeek(xFilial("BE2")+cChaveBEA))
			While ! BE2->(Eof()) .And. xFilial("BE2")+cChaveBEA == BE2->(BE2_FILIAL+BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT)
				BD6->(DbSetOrder(1))
				nValPag := 0
				If BD6->(MsSeek(xFilial("BD6")+cChaveBD5+BEA->BEA_ORIMOV+BE2->BE2_SEQUEN))
					nValPag := BD6->BD6_VLRPAG
					Restarea(aAreaBD6)
				EndIf

				If nValPag > 0
					BE2->(RecLock("BE2",.F.))
					BE2->BE2_VLPGGU := nValPag
					BE2->(MsUnLock())
				EndIf
				BE2->(DbSkip())
			EndDo
			Restarea(aAreaBE2)
		EndIf
	Endif
EndIf

//Atualiza as guias de Anexo - PTU Online
If !Empty(nNrSeqTR) .And. !lPtuOnline .And. GetNewPar("MV_PLSUNI","0") == "1" .And. (nOpc == K_Alterar .Or. nOpc == K_Evolucao .Or. nOpc == K_Excluir) .And. ;
B4C->( FieldPos("B4C_COMUNI") ) > 0 .and. B4C->( FieldPos("B4C_NRTROL") ) > 0 .and. B4C->( FieldPos("B4C_NRAOPE") ) > 0

	IIF(cAliasCab == "BE4",cPesqAnex := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),cPesqAnex := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)) 

	B4A->( DbSetOrder(4) )//B4A_FILIAL + B4A_GUIREF
	If B4A->( msSeek( xFilial("B4A") + cPesqAnex ) )

		If lGrvEvoSad
			aHeaderITE := oBrwBQV090:aHeader
			aColsITE   := oBrwBQV090:aCols    
			aCabCri    := oBrwBQZ090:aHeader
			aDadCri    := oBrwBQZ090:aCols
			cAliasIte  := "BQV"  
			cAliasCri  := "BQZ"
				nNrSeqTR   := cTrolComun   
			EndIf

			PLPTUAtAne(aHeaderITE,aColsITE,aCabCri,aDadCri,cAliasIte,cAliasCri,nNrSeqTR,cPesqAnex,cSenhaOpe,nOpc,lWeb)
		EndIf

	EndIf

// Quando for recebido uma transaÁ„o de PTU Online que contenha pacote, executa JOB
// para comunicar com o WebServices para gravar a composiÁ„o do pacote 
If Len(aItensB6L) > 0 .And. FindFunction("PTUPACJOB") 
	cGuiaPacote := &(cAliasCab+"->("+cAliasCab+"_OPEMOV+"+cAliasCab+"_ANOAUT+"+cAliasCab+"_MESAUT+"+cAliasCab+"_NUMAUT)")
	StartJob("PTUPACJOB",GetEnvServer(),.F.,cEmpAnt,cFilAnt,PlsIntPad(),cGuiaPacote)
EndIf

Return({lRet,&(cAliasCab+"->"+cAliasCab+"_OPEMOV"),&(cAliasCab+"->"+cAliasCab+"_ANOAUT"),&(cAliasCab+"->"+cAliasCab+"_MESAUT"),;
&(cAliasCab+"->"+cAliasCab+"_NUMAUT"),lAut,cCodOpeG,cTipGui,lAuditoria,cStatus,lJaCobLib,lRadio})

/*/{Protheus.doc} PLSA090Vld
Funcao que confirma uma autorizacao retornando o seu numero

@author  PLS TEAM
@version P11
@since   14.05.02
/*/
Function PLSA090Vld(aRetorno,aGets,aTela,oBrwPro,oEncAut,nOpc,cTipo,oBrwCri,cNaoUsado,lNMudFase,aMatCom, cAlias, lAutoOnl,oGetBzc,cTrolComun,aDadB6M)
	LOCAL nI
	LOCAL nFor
	LOCAL cOpeOri
	LOCAL nOrdBA0
	LOCAL nRecBA0
	LOCAL aDadBEA    	:= {}
	LOCAL aDadUsr    	:= PLSGETUSR()
	LOCAL aDadRDA    	:= PLSGETRDA()
	LOCAL aChaveGen  	:= {}
	LOCAL lUmVld	 	:= .F.
	LOCAL lRet 		:= .T.
	LOCAL lPossuiIt	:= .F.
	LOCAL lGerSenha  	:= .F.
	LOCAL lCompra    	:= .F.
	LOCAL lIndCli    	:= .F.
	LOCAL lConsulta 	:= (PLSISCON(oBrwPro:FieldGet("BE2_CODPAD"),oBrwPro:FieldGet("BE2_CODPRO")) .And. Len(oBrwPro:aCols) == 1 .And. oBrwPro:FieldGet("BE2_AUDITO") <> "1")
LOCAL nVlrCom    	:= 0
LOCAL cExcAtend  	:= GetNewPar("MV_PLEXATE","0")
LOCAL lPLSEXPC      := getNewPar("MV_PLSEXPC",.f.)
LOCAL aRetASE1   	:= {}
LOCAL cChaveSE1		:= ""
LOCAL cProcIndCli	:= ""
LOCAL lUnimeds   	:= IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
LOCAL nOpc2			:= 0
LOCAL lLote      	:= GETNEWPAR("MV_PLSLOTE",.F.)
LOCAL lEvoluSADT 	:= GetNewPar("MV_PLEVSAD","0") == "1" .And. FunName() $ "PLSA094A"
LOCAL aCodProcs	 	:= {}
LOCAL aColsB4B   	:= {}
LOCAL aHeaderB4B 	:= {}
LOCAL aVetB4B    	:= {}
LOCAL aResComuni 	:= {}
LOCAL cAvisoRet  	:= ""
Local cTissVer   	:= PLSTISSVER()
LOCAL nQtdPrc		:= 0
LOCAL nQtdCri		:= 0
LOCAL nPr			:= 0
LOCAL nCr			:= 0
LOCAL aColBEG		:= {}
LOCAL aHeaBEG		:= {}
LOCAL aVtaBEG		:= {}
LOCAL lComunPTU 	:= .T.
LOCAL dValSen		:= cTod('')
LOCAL lBQVSemCom    := .F.
LOCAL nPos          := 0
LOCAL nResOS        := 0
LOCAL lPTUAutom     := .F.
LOCAL cMsgPTUAut    := ""
Local dXdate		:= Date()
Local cXtime		:= Time()
Local xCodUsr		:= BCS->(RetCodUsr())
Local cNrAutWeb     :=  ""
Local cStAutWeb     :=  ""
Local cTpAutWeb     :=  ""
/*vari·vel utilizada para informar quais campos de um item deve sem des desconsiderados na validaÁ„o
caso o procedimento esteja negado, os campos devem ser separados por virgula.*/
LOCAL cDescCmpo     := "BE2_QTDPRO" 
LOCAL lCancelPTU    := .F.
LOCAL aAreaBEA      := {}
Local nCont			:= 0
Local cNrlBor		:= ""
Local cSql			:= ""
Local lHaIncompat	:= .F.
Local lForcar 		:= .F.
Local lForcou		:= .F.
Local aBkpCrit 		:= {}

DEFAULT aMatCom		:= {}
DEFAULT cNaoUsado	:= ""
DEFAULT cAlias	    := ""
DEFAULT lAutoOnl    := .F.
DEFAULT oGetBZC     := NIL
DEFAULT cTrolComun  := ""
DEFAULT aDadB6M     := {} 

//Verifica o codigo da consulta, se for intercambio, somente a eletiva pode gerar guia consulta 

If lConsulta .And. Len(aDadUsr) >= 45 .And. aDadUsr[45] <> PlsIntPad() .And. GetNewPar("MV_PLSUNI","1") == "1"
	If !Alltrim(oBrwPro:FieldGet("BE2_CODPRO")) $ GetNewPar("MV_PTCELET","10101012")
		lConsulta := .F.
	EndIf
EndIf

//Verifica Exclus„o Guia comprada onde o TÌtulo sofre movimentaÁ„o           				   	  

If nOpc == K_Excluir .and. cExcAtend == "1"

	If lBEANTit
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

			Aviso(	STR0054,; 		//"AtenÁ„o"
					STR0382,;		//"TÌtulo Movimentado N„o È possÌvel excluir Atendimento!"
					{ "Ok" }, 2 ) 	//"ok"
		
			Return(.F.)

		EndIf

	EndIf

EndIf

//Verifica se foi informado algum procedimento												  
For nI := 1 To Len(oBrwPro:aCols)

	//nao esta deletado																			  
	If ! oBrwPro:aCols[nI,Len(oBrwPro:aHeader)+1]

		//Valida procedimentos sem qtde realizada na execuÁ„o SADT
		If (nOpc == K_Incluir .Or. nOpc == K_Copiar) .And. !Empty(M->BE1_NUMLIB) .AND. oBrwPro:FieldGet("BE2_QTDPRO",nI) < 1 .AND. oBrwPro:FieldGet("BE2_STATUS",nI) == "1" 

			aviso(	STR0120,; 				//"Atencao"
			STR0641,; 				//"H· procedimentos informados sem quantidade realizada. Verifique!"
			{ STR0146 }, 2 ) 		//"ok"
			return(.f.)

		endIf

		//Checagem
		lUmVld := .T.

		If lUnimeds

			lAudito := .f.

			If oBrwPro:FieldGet("BE2_STATUS",nI) == "0"

				If oBrwPro:FieldPos("BE2_AUDITO") > 0 .and. oBrwPro:FieldGet("BE2_AUDITO",nI) == '1'
					lAudito := .t.
				Endif

			Endif

			If oBrwPro:FieldGet("BE2_STATUS",nI) == "1" .or. lAudito

				//Trata Obrigatoriedade do campo IndicaÁ„o Clinica para Unimed (PTU)							  
				If BR8->( FieldPos("BR8_TRAIND") ) > 0 .And. BR8->(DBSeek(xFilial("BR8")+oBrwPro:FieldGet("BE2_CODPAD",nI)+oBrwPro:FieldGet("BE2_CODPRO",nI))) .And. BR8->BR8_TRAIND == "1"  .And. !lIndCli
					lIndCli := .T.
					cProcIndCli := BR8->BR8_CODPSA
				EndIf

				If M->BE1_GUIACO == "1" .And. !lCompra .And. oBrwPro:FieldGet("BE2_VLCOMP",nI) > 0
					lCompra := .T.
				EndIf

			EndIf

			If lIndCli .And. lCompra
				Exit
			EndIf

		Else

			If M->BE1_GUIACO == "1"
				If oBrwPro:FieldGet("BE2_STATUS",nI) == "1" .And. oBrwPro:FieldGet("BE2_VLCOMP",nI) > 0
					lCompra := .t.
					Exit
				EndIf
			Else
				Exit
			EndIf

		EndIf

		If oBrwPro:FieldGet("BE2_STATUS",nI) == "0"
			If oBrwPro:FieldPos("BE2_AUDITO") > 0 .and. oBrwPro:FieldGet("BE2_AUDITO",nI) == '0'
				oBrwPro:FieldPut("BE2_SALDO",0, nI) 
			Endif
		endif
	EndIf

Next nI

//Exibe msg se nao for informado	
If ! lUmVld
	Aviso(	STR0120,; 				//"Atencao"
	STR0277,; 				//"Nenhum procedimento informado!"
	{ STR0146 }, 2 ) 		//"ok"
	Return(.F.)
EndIf
//Caso for excluido o procedimento comprado, desmarca a guia de compra.
If !lCompra .And. M->BE1_GUIACO == "1"
	M->BE1_GUIACO := "0"
Endif

//Nao e preciso validacao para visualizacao	

If nOpc == K_Visualizar
	aRetorno := {.T.,BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,.T.,"","",.F.,""}
	Return(.T.)
Endif

//Caso que pode acontecer da guia com ano e mes em branco... 

If Empty(M->BE1_ANOPAG) .Or. Empty(M->BE1_MESPAG)
	MsgStop(STR0109) //"Ano ou Mes de pagamento em branco. Esta guia nao pode ser gravada."
	Return(.F.)
Endif

//Verifica se foi informado pelo menos um item... 

If  nOpc <> K_Excluir .and. (!Obrigatorio(oEncAut:aGets,oEncAut:aTela).Or. !oBrwPro:TudoOK(,cDescCmpo) ) 
	Return(.F.)
Endif

//Verifica se e uma guia originada da internacao e nao deixa excluir

If nOpc == K_Excluir .And. BEA->BEA_TIPGUI == "03"
	MsgStop(STR0266) //"Nao e possivel excluir guia originada da INTERNACAO!"
	Return(.F.)
Endif

//Valida a obrigatoriedade do campo Obrigatorio Corpo Clinico no Loc.Aten.

If nOpc <> K_Excluir .And. Len(aDadRDA) > 0 .And. aDadRda[23] == "1" .And. Empty(M->BE1_REGEXE)
	Help("",1,"PLSA090EXE")
	Return(.F.)
Endif

//Trata cid obrigatorio de acordo com parametrizacao... 

If !lConsulta .And. !PLSVLDCID(M->BE1_CODRDA,M->BE1_CID)
	Return(.F.)
Endif

If TYPE("M->BE1_TIPATE") == "C" .and. TYPE("M->BE1_TIPSAI") == "C" .and. TYPE("M->BE1_TIPCON") == "C" .and. nOpc <> K_Excluir

	If ! lConsulta .And. EMPTY(M->BE1_TIPATE) .And. cTipo == "1"
		MsgStop(STR0353)//'O campo Tipo Atendim(Tipo de Atendimento) deve ser preenchido por se tratar de uma Guia de serviÁo '
		Return(.F.)
	Endif

	If (lConsulta .Or. M->BE1_TIPATE == '04') .And. EMPTY(M->BE1_TIPCON).and. nOpc <> K_Excluir 
		MsgStop(STR0352)//'O campo Tip Consulta(Tipo de Consulta) deve ser preenchido por se tratar de uma Guia de Consulta'
		Return(.F.)
	Endif

	//A validaÁ„o n„o faz mais sentido, devido ao campo ser obrigatÛrio somente em caso de Ûbito
	//	If ! lConsulta .And. EMPTY(M->BE1_TIPSAI) .And. cTipo == "1".and. nOpc <> K_Excluir
	//	   MsgStop(STR0351)//'O campo Tipo de SaÌda deve ser preenchido por se tratar de uma AutorizaÁ„o de servÁo'
	//	   Return(.F.)
	//	Endif

	If lConsulta .And. M->BE1_TIPSAI == "6"
		MsgStop(STR0350)//'Tipo de SaÌda "6=”bito" n„o È permitido para consultas.'
		Return(.F.)
	EndIf
	If !lConsulta .and. Empty(M->BE1_SIGLA)
		MsgStop(STR0394)//'O campo Sigla CR deve ser preenchido por se tratar de uma AutorizaÁ„o de servÁo'
		Return(.F.)
	Endif
	If !lConsulta .and. Empty(M->BE1_ESTSOL)
		MsgStop(STR0395)//'O campo Uf Solic deve ser preenchido por se tratar de uma AutorizaÁ„o de servÁo'
		Return(.F.)
	Endif
Endif

//Valida a obrigatoriedade do campo LotGuia. 								

If BEA->(FieldPos("BEA_LOTGUI")) > 0

	If cTipo == "1" .And. lLote .And. nOpc == K_Incluir .And. TYPE("M->BE1_LOTGUI") == "C" .And. Empty(M->BE1_LOTGUI)
		MsgStop("O campo 'Lote Guia' - Numero do Lote da Guia deve ser informado!")
		Return(.F.)
	Endif
Endif

//Validacao de majoracao
If nOpc == K_Incluir .And. GetNewPar("MV_PLSMAJ",.F.) .And. BEA->(FieldPos("BEA_TIPMAJ")) > 0
	DbSelectArea("BAU")
	If (Posicione("BAU",1,xFilial("BAU")+M->BE1_CODRDA,"BAU->BAU_TIPPRE") == GetNewPar("MV_PLSTPIN","OPE")) .And. Empty(M->BE1_TIPMAJ)
		Help( ,, 'HELP',,"Para RDA de convenio de reciprocidade o Tipo de MajoraÁ„o È obrigatÛrio!", 1, 0)
		Return(.F.)
	EndIf
EndIf

If lUnimeds .And. lIndCli .And. nOpc == K_Incluir .And. TYPE("M->BE1_INDCLI") == "C" .And. EMPTY(M->BE1_INDCLI)
	MsgStop(STR0391+Alltrim(cProcIndCli)+STR0392)//"O campo Indic Clinic. (Indicacao Clinica) deve ser preenchido pois o procedimento "+" est· parametrizado na Tabela Padr„o para Tratar IndicaÁ„o!"
	Return(.F.)
Endif

//ERRO CONTROLADO...               										

If nOpc <> K_Excluir .And. Len(aDadUsr) > 2 .and. AllTrim(M->BE1_MATANT) <> AllTrim(aDadUsr[3])
	MsgStop(STR0257)//"Matricula antiga contida na [MEMORIA] diferente da contida no [ADADUSR]. Contate o suporte."
	Return(.F.)
Endif

//Verifica se existem itens ativos na getdados≥

For nFor := 1 To Len(oBrwPro:aCols)
	if !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
		lPossuiIt := .T.
		Exit
	Endif
Next

//lPossuiIt								  

If !lPossuiIt
	Help(" ",1,"OBRIGAT")
	Return(.F.)
Endif

//Trata se for uma autorizacao de intercambio a comunicacao online...     

If (nOpc == K_Incluir .Or. lAutoOnl) .And. Len(aDadUsr) >= 45 .And. TYPE("M->BE1_COMUNI") == "C" .And. M->BE1_COMUNI == "0" .And. GetNewPar("MV_PTGLOBO","1") == "1"
	cOpeOri := aDadUsr[45]

	If cOpeOri <> PLSINTPAD()

		If cTissVer < "3.00.00" .And. M->BE1_TIPATE $ "11,13,14,15,16,17 18,19,20,21"
			MsgInfo("O Tipo de Atendimento selecionado sÛ pode ser utilizado na TISS 3.00.00 ou superior.")
			Return(.F.)
		EndIf

		nOrdBA0 := BA0->(IndexOrd())
		nRecBA0 := BA0->(Recno())
		BA0->(DbSetOrder(1))

		If BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1" .And. lConf .And. GetNewPar("MV_PLSSOOL","1") == "1"
			If  Aviso(	STR0110, ; //"Operadora Origem On-Line"
			STR0111,; //"Deseja confirmar este atendimento de intercambio eventual, sem efetuar a comunicaÁ„o com outra operadora?"
			{ STR0056, STR0057}, 2 ) <> 1 //"Sim"###"Nao"
				Return(.F.)
			Else
				PLSAUTPTU(__aCdCri230,@oBrwPro, @oBrwCri)
			EndIf
			//Se ha processo PTU, forco critica de negativa   
		ElseIf BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1" .And. GetNewPar("MV_PLSSOOL","1") == "1" .And. !lConf 
			PLSAUTPTU(__aCdCri230,@oBrwPro, @oBrwCri)
		Endif

		BA0->(DbSetOrder(nOrdBA0))
		BA0->(DbGoTo(nRecBA0))
	Endif
Endif

//Trata se o solicitante foi digitado... 
If !lConsulta .And. AllTrim(GetNewPar("MV_PLSOSOL","1")) == "1" .And. M->BE1_OPESOL == PLSINTPAD() .And. Empty(M->BE1_REGSOL) .And. !UPPER( Alltrim( FunName() ) ) $ "PLSA094C,PLSA094D"
	Help("",1,"PLSA090SOL")
	Return(.F.)
Endif

if lIntGui .And. !lConsulta  

	If TYPE("M->BE1_GUIPRI") == "C"  
		IF  Empty(M->BE1_GUIPRI) 
			Aviso( STR0573 ,STR0574, { STR0146 }, 2 ) //"Este Paciente Encontra -se  Bloqueado" #"Necessario informar a Guia Principal da InternaÁ„o "
			Return(.F.)	
		Endif	
	Endif

Endif	


//Valida a guia juridica
If TYPE("M->BE1_GUIJUR") == "C" .and. TYPE("M->BE1_NUMPRO") == "C" .AND. nOpc <> K_Excluir
	If M->BE1_GUIJUR == "1" .and. Empty(M->BE1_NUMPRO)
		If PlsGetJur()[1]
			Help("",1,"PLSGUIJUR")
			Return(.F.)
		Endif
	Endif
Endif

//Comunica PTU Online quando MV_PTGLOBO esta desativado                    
If (nOpc == K_Incluir .And. Len(aDadUsr) >= 45 .And. TYPE("M->BE1_COMUNI") == "C" .And. M->BE1_COMUNI == "0" .And. GetNewPar("MV_PTGLOBO","1") <> "1" .And. GetNewPar("MV_PLSUNI","1") == "1") .Or. ; //Solicitacao
(nOpc == K_Evolucao .And. Len(aDadUsr) >= 45 .And. BEA->BEA_COMUNI == "1" .And. GetNewPar("MV_PTGLOBO","1") <> "1" .And. GetNewPar("MV_PLSUNI","1") == "1") .Or. ;//Evolucao de (nOpc == K_Evolucao .And. Len(aDadUsr) >= 45 .And. BEA->BEA_COMUNI == "1" .And. GetNewPar("MV_PTGLOBO","1") <> "1" .And. GetNewPar("MV_PLSUNI","1") == "1")SADT
(nOpc == K_Alterar .And. Len(aDadUsr) >= 45 .And. BEA->BEA_COMUNI <> "1" .And. GetNewPar("MV_PTGLOBO","1") <> "1" .And. GetNewPar("MV_PLSUNI","1") == "1") //Botao Auto Online

	cOpeOri := aDadUsr[45]
	nOrdBA0 := BA0->(IndexOrd())
	nRecBA0 := BA0->(Recno())
	BA0->(DbSetOrder(1))

	//Se operadora diferente realiza verifica se realiza solicitacao normal   
	If cOpeOri <> PLSINTPAD() .And. BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1"
		If GetNewPar("MV_PLSSOOL","1") == "1" .And. MsgYesNo(STR0541) //"Usu·rio de Interc‚mbio Eventual, deseja realizar comunicaÁ„o com a Operadora Origem?"
			//Evolucao SADT
			If nOpc == K_Evolucao .And. BQV->( FieldPos("BQV_OLNAUD") ) > 0
				If !PLVerAnPTU(oBrwBQV090,"BQV",nOpc) //Para versao 5.0, e necessario verificar se foi utilizado uma guia de anexo
					lComunPTU := .F.
				EndIf
				If lComunPTU
					If !PLSAUTREM("BE1","BQV","BQZ",oBrwBQV090,oBrwBQZ090,nOpc,.F.,.T.,@aResComuni,@cAvisoRet,@cTrolComun)
						Return(.F.)
					EndIf
				Else
					PLSAUTPTU(__aCdCri230,@oBrwBQV090, @oBrwBQZ090)
				EndIf	

				//Solicitacao Normal
			Else
				If !PLVerAnPTU(oBrwPro,"BE2",nOpc) //Para versao 5.0, e necessario verificar se foi utilizado uma guia de anexo
					lComunPTU := .F.
				EndIf

				If lComunPTU
					If !PLSAUTREM("BE1","BE2","BEG",oBrwPro,oBrwCri,nOpc,nil,nil,@aResComuni,@cAvisoRet,@cTrolComun)
						Return(.F.)
					EndIf
				Else
					PLSAUTPTU(__aCdCri230,@oBrwPro, @oBrwCri)
				Endif
			Endif
			//Cancelou a a comunicacao online, devo criticar os eventos
		Else   
			//Solicitacao Vale do Sinos - Se BE1_NRAOPE informado ou Guia de Baixo Risco, nao realiza a comunicacao e autoriza a Guia.
			If GetNewPar("MV_PLPTUAB","0") == "1"         
				Do Case
					Case nOpc == K_Incluir  
						If !Empty(M->BE1_NRAOPE) 
							lPTUAutom  := .T.
							cMsgPTUAut := STR0633 //"Os eventos ser„o autorizados automaticamente pois o campo 'Nr Aut Oper.' foi preenchido." 
						ElseIf BR8->( FieldPos("BR8_RISCO") ) > 0 .And. PL90IteRis(oBrwPro) 
							lPTUAutom  := .T. 
							cMsgPTUAut := STR0634 //"Os eventos ser„o autorizados automaticamente pois a Guia È de Baixo Risco."
						EndIf
					Case nOpc == K_Evolucao .And. FindFunction("PLChkCompPTU")
						If PLChkCompPTU(oBrwBQV090)
							lPTUAutom  := .T.
							cMsgPTUAut := "Os eventos ser„o autorizados automaticamente pois o campo 'Nr Aut Oper.' foi preenchido ou os eventos s„o de baixo risco." //"Os eventos ser„o autorizados automaticamente pois o campo 'Nr Aut Oper.' foi preenchido ou os eventos s„o de baixo risco."
						EndIf
				EndCase
			EndIf

			If nOpc == K_Evolucao
				If GetNewPar("MV_PLPTUAB","0") == "1" .And. FindFunction("PLAutComPTU")
					If PLAutComPTU(__aCdCri230, @oBrwBQV090, @oBrwBQZ090, IIF(lPTUAutom,"2","1")) .And. lPTUAutom
						Aviso(STR0120, cMsgPTUAut, {STR0146}, 2) // "AtenÁ„o";"Ok"
					EndIf
				Else
					PLSAUTPTU(__aCdCri230, @oBrwBQV090, @oBrwBQZ090)
				EndIf
			Else
				PLSAUTPTU(__aCdCri230,@oBrwPro, @oBrwCri,IIF(lPTUAutom,"2","1"))  
				If lPTUAutom
					Aviso( STR0120,cMsgPTUAut,{ STR0146 }, 2 )
				EndIf			
			EndIf					
		Endif	

		//Verifica se realiza solicitacao de ordem de servico                     
	Else
		DbSelectArea("BAU")
		DbSetOrder(1)//BAU_FILIAL+BAU_CODIGO
		BAU->(DbSeek(xFilial("BAU")+&("M->BE1_CODRDA")))

		If BA0->(msSeek(xFilial("BA0")+BAU->BAU_CODOPE)) .and. BA0->BA0_ONLINE == "1" .and. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE") // .and. msgYesNo("RDA selecionada È de outra Operadora, deseja realizar comunicaÁ„o Online?")

			nResOS := Aviso( STR0120,STR0537,{ STR0628,STR0629 }, 2 ) //"Atencao" //"RDA selecionada È outra Operadora, deseja realizar transaÁ„o de Ordem de ServiÁo/TriangulaÁ„o ou SolicitaÁ„o Normal?""Os/Triang.","Sol. Normal"
			If nResOS == 1 .And. !PLSAUTREM("BE1","BE2","BEG",oBrwPro,oBrwCri,nOpc,nil,nil,@aResComuni,@cAvisoRet,@cTrolComun)
				Return(.F.)
			EndIf
		Endif
	EndIf
	BA0->(DbSetOrder(nOrdBA0))
	BA0->(DbGoTo(nRecBA0))
Endif

//Se evolucao de PTU Online sem comunicacao
If GetNewPar("MV_PTGLOBO","1") == "1" .And. nOpc == K_Evolucao .And. Len(aDadUsr) >= 45 .And. GetNewPar("MV_PLSUNI","1") == "1" .And. aDadUsr[45] <> PlsIntPad() .And. lConf 
	BA0->(DbSetOrder(1))
	If BA0->(MsSeek(xFilial("BA0")+aDadUsr[45])) .And. BA0->BA0_ONLINE == "1"  
		nPos := AScan(oBrwBQV090:aHeader,{|x| x[2] == "BQV_NRTROL"})    
		For nFor := 1 to len(oBrwBQV090:aCols) 
			If Empty(oBrwBQV090:aCols[nFor][nPos])     
				lBQVSemCom := .T.
				Exit
			EndIf
		Next     
		If lBQVSemCom  
			If Aviso(	STR0110, ; //"Operadora Origem On-Line"
			STR0111,; //"Deseja confirmar este atendimento de intercambio eventual, sem efetuar a comunicaÁ„o com outra operadora?"
			{ STR0056, STR0057}, 2 ) <> 1 //"Sim"###"Nao"
				Return(.F.)
			Else
				PLSAUTPTU(__aCdCri230,@oBrwBQV090, @oBrwBQZ090)
			EndIf
		EndIf	
	EndIf	
EndIf  

//Se evolucao de PTU Online criticada  criticada 
If GetNewPar("MV_PTGLOBO","1") == "1" .And. nOpc == K_Evolucao .And. Len(aDadUsr) >= 45 .And. GetNewPar("MV_PLSUNI","1") == "1" .And. aDadUsr[45] <> PlsIntPad() .And. !lConf 
	BA0->(DbSetOrder(1))
	If BA0->(MsSeek(xFilial("BA0")+aDadUsr[45])) .And. BA0->BA0_ONLINE == "1"  
		nPos := AScan(oBrwBQV090:aHeader,{|x| x[2] == "BQV_NRTROL"})    
		For nFor := 1 to len(oBrwBQV090:aCols) 
			If Empty(oBrwBQV090:aCols[nFor][nPos])     
				lBQVSemCom := .T.
				Exit
			EndIf
		Next     
		If lBQVSemCom  
			PLSAUTPTU(__aCdCri230,@oBrwBQV090, @oBrwBQZ090)
		EndIf	
	EndIf	
Endif

//Analiso procedimentos incompativeis e cids incompativeis... 
For nFor := 1 To Len(oBrwPro:aCols)
	If (oBrwPro:FieldGet("BE2_STATUS",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]) .or.  (cTipo =='2' .And. oBrwPro:FieldGet("BE2_AUDITO",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1])// quando se tratar de auditoria teremos que analisar os procedimento incompativeis

		AaDd(aCodProcs,{oBrwPro:FieldGet("BE2_CODPAD",nFor),;
		oBrwPro:FieldGet("BE2_CODPRO",nFor),;
		"",;
		oBrwPro:FieldGet("BE2_PROREL",nFor),;
		oBrwPro:FieldGet("BE2_PRPRRL",nFor),;
		oBrwPro:FieldGet("BE2_QTDPRO",nFor),;
		"",;
		oBrwPro:FieldGet("BE2_SEQUEN",nFor)})


	Endif
Next

If PLSPOSGLO(PLSINTPAD(),__aCdCri197[1],__aCdCri197[2],'1','1') .And. Len(aDadRDA) > 0 .And. PLSCHKCRI( {'BAU',aDadRDA[2],__aCdCri197[1]} )
	aOldCodCri  := PLLimpCCri(.F.)
	If aOldCodCri == nil
		aOldCodCri  := {}
	Endif
	PLLimpCCri(.T.)

	If ( nOpc == K_Incluir .Or. nOpc == K_Alterar ) .And. Len(aCodProcs) > 0
		For ni:=1 to len(aCodProcs)
			aRetFun := PLSVLDPRI(M->BE1_CID,"1",aCodProcs,aDadUsr,M->BE1_DATPRO,NIL,NIL,NIL,aCodProcs[ni,1],aCodProcs[ni,2],aCodProcs[ni,8],NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.,.T., (GetNewPar("MV_PLSSENT", "1") =='2')) // CHAMANDO O PROCEDIMENTOS INCOMPATIVEIS

			If ! aRetFun[1]

				lForcar := BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+aRetFun[2][1][1],"BCT_PERFOR")) == "1"
				
				//MV_PLSSENT 
				//igual a 2 determina que irei verificar os incompativel somente ao confirmar a guia e n„o na validaÁ„o de item a item ao digitar a Guia
				//igual a 1 determina que irei verificar os incompativel na digitaÁ„o dos procedimentos item a item ao digitar a Guia
				If (GetNewPar("MV_PLSSENT", "1") <>'2')
					lForcou := PLSMOVCRI("2",{},aRetFun[2],lForcar)
				Endif	

				If  lForcar .And. lForcou
					aadd(aAutFor,{.T.,"","","","","","",0,xCodUsr,dXdate,cXtime})
					Exit
				Else
					//O paramentro MV_PLSSENT com seu valor a 2 significa que a critica de incompativeis sera exibida somente na confirmaÁ„o da Guia e n„o no momento de digitaÁ„o dos procedimentos
					If (GetNewPar("MV_PLSSENT", "1") <>'2')
						Return(.F.)
					Else
						// Irei adicionar a critica somente aos procedimentositens que foram criticados por imconpativel
						nPos:= PlRetPos("BE2_CODPRO",oBrwPro:aHeader)
						nLin:= Ascan(oBrwPro:aCols,{|x| x[nPos] == aCodProcs[ni,2]  })

						If nLin	> 0
							aBkpCrit 		:= aClone(aRetFun[2])
							oBrwPro:FieldPut("BE2_STATUS","0",nLin)
							PLSA090ACR(aDadCri,aCabCri,aTrbCri,aBkpCrit,oBrwCri,aCodProcs[ni,8],oBrwCri:cAlias,oBrwPro)
						Endif	
						lHaIncompat:= .T.
					Endif	
				Endif
			Endif
		Next ni

		//Irei exibir somente uma vez a tela de critica de incompativeis 
		//Caso a critica conter a opÁ„o de forÁar eu tenho que retirar as criticas de incompativei 
		If lHaIncompat .And.  (GetNewPar("MV_PLSSENT", "1") =='2')
			lForcou := PLSMOVCRI("2",{},aBkpCrit,lForcar)
			If  lForcar .And. lForcou
				aadd(aAutFor,{.T.,"","","","","","",0,xCodUsr,dXdate,cXtime})
				For ni:=1 to len(aCodProcs)
					// Irei retirar a critica somente aos procedimentositens que foram criticados por imconpativel pois foi forÁado 
					nPos:= PlRetPos("BE2_CODPRO",oBrwPro:aHeader)
					nLin:= Ascan(oBrwPro:aCols,{|x| x[nPos] == aCodProcs[ni,2]  })

					If nLin	> 0
						oBrwPro:FieldPut("BE2_STATUS","1",nLin)
					Endif	
				Next ni
			Endif	
		Endif
	Endif
	PLLimpCCri(.F.,.T.,aOldCodCri)
Endif

If ExistBlock("PLS090OK")
	If !ExecBlock("PLS090OK",.F.,.F., {nOpc,oBrwPro})
		Return(.F.)
	Endif
Endif

//Trata uma autorizacao que veio de uma liberacao...                       

if (nOpc == K_Incluir .Or. nOpc == K_Copiar) .And. !Empty(M->BE1_NUMLIB)
	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	If !BEA->( MsSeek(xFilial("BEA")+M->BE1_NUMLIB) )
		Help("",1,"PLNUMLIB")
		Return(.F.)
	EndIf
endIf

//<< BEA BEA BEA BEA >> Monta dados do CABECALHO...                       
//Dados sempre atualizados (Inclusao/Alteracao)...                        

If nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Copiar

	M->BE1_VALOR := 0

	For nFor := 1 To Len(oBrwPro:aCols)
		If !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
			nVlrCom += oBrwPro:FieldGet("BE2_VLCOMP",nFor)
		Endif
	Next

	M->BE1_VALOR := nVlrCom

	aadd(aDadBEA,{"BEA_ORIMOV","1"})
	aadd(aDadBEA,{"BEA_TIPO"  ,If(lConsulta,"1","2")})
	aadd(aDadBEA,{"BEA_OPERDA",M->BE1_OPERDA})
	aadd(aDadBEA,{"BEA_CID   ",M->BE1_CID})
	aadd(aDadBEA,{"BEA_DESCID",M->BE1_DESCID})
	aadd(aDadBEA,{"BEA_DATPRO",M->BE1_DATPRO})
	aadd(aDadBEA,{"BEA_HORPRO",M->BE1_HORPRO})
	aadd(aDadBEA,{"BEA_CDPFSO",M->BE1_CDPFSO})
	aadd(aDadBEA,{"BEA_ANOPAG",M->BE1_ANOPAG})
	aadd(aDadBEA,{"BEA_MESPAG",M->BE1_MESPAG})
	aadd(aDadBEA,{"BEA_NUMIMP",M->BE1_NUMIMP})
	aadd(aDadBEA,{"BEA_MATANT",M->BE1_MATANT})
	aadd(aDadBEA,{"BEA_MATUSA",M->BE1_MATUSA})
	aadd(aDadBEA,{"BEA_PACOTE",M->BE1_PACOTE})
	aadd(aDadBEA,{"BEA_VLRPAC",M->BE1_VLRPAC})
	aadd(aDadBEA,{"BEA_GUIORI",M->BE1_GUIORI})
	aadd(aDadBEA,{"BEA_MSG01",M->BE1_MSG01})
	aadd(aDadBEA,{"BEA_MSG02",M->BE1_MSG02})
	aadd(aDadBEA,{"BEA_MSG03",M->BE1_MSG03})
	aadd(aDadBEA,{"BEA_GUIACO",M->BE1_GUIACO})
	aadd(aDadBEA,{"BEA_NRTROL",M->BE1_NRTROL})

	If BEA->(FieldPos("BEA_TIPMAJ")) > 0
		aadd(aDadBEA,{"BEA_TIPMAJ",M->BE1_TIPMAJ})
	EndIf

	if type("M->BE1_NUMLIB") == "C"

		if ! empty(M->BE1_NUMLIB)
			aadd(aDadBEA,{"BEA_NRLBOR",M->BE1_NUMLIB})
		endIf      		

	endIf

	If Type("M->BE1_LOTGUI") == "C"
		If ! Empty(M->BE1_LOTGUI)
			aadd(aDadBEA,{"BEA_LOTGUI",AllTrim( Str( Val(M->BE1_LOTGUI) ) )})
		Endif
	Endif
	If Type("M->BE1_VALSEN") == "D" .And. !Empty(M->BE1_VALSEN)
		dValSen := M->BE1_VALSEN
	Endif

	If BEA->(FieldPos("BEA_TIPPRE")) > 0
		aadd(aDadBEA,{"BEA_TIPPRE",M->BE1_TIPPRE})
	Endif

	aadd(aDadBEA,{"BEA_QUACOB",M->BE1_QUACOB})
	If Type("M->BE1_PAGATO") == "C"
		aadd(aDadBEA,{"BEA_PAGATO",M->BE1_PAGATO})
	Endif
	aadd(aDadBEA,{"BEA_CODCLI",M->BE1_CODCLI})
	aadd(aDadBEA,{"BEA_LOJA  ",M->BE1_LOJA  })
	aadd(aDadBEA,{"BEA_VALOR ",M->BE1_VALOR })

	//Se for um usuario da operadora padrao sendo atendido em outra operadora 
	//| OU se o parametro que define que                                        
	//| sempre sera gerado uma senha na autorizacao/liberacao estiver ligado    

	If ( ( BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE") ) .Or. ( GetNewPar("MV_PLSGSAL","0") == "1" ) 	) .Or. ( GetNewPar("MV_PLSTISS","1")=="1" .And. cTipo == "2" )
		lGerSenha := .T.

		//Se estiver em memoria (Ordem de Servico) utiliza a senha ja gerada      

		If Type("M->BE1_SENHA") == "C" .And. !Empty(M->BE1_SENHA)
			lGerSenha := .F.
			aadd(aDadBEA,{"BEA_SENHA",M->BE1_SENHA})
		Endif
	Endif
Endif

//Somente na inclusao...                                                  

If nOpc == K_Incluir .Or. nOpc == K_Copiar
	aadd(aDadBEA,{"BEA_HHDIGI",StrTran(Time(),":","")})
	aadd(aDadBEA,{"BEA_DTDIGI",date()})
	aadd(aDadBEA,{"BEA_USUOPE",PLSRtCdUsr()})
	aadd(aDadBEA,{"BEA_DESOPE",PLRETOPE()})
	If BEA->(FieldPos("BEA_NUMATE")) > 0
		aadd(aDadBEA,{"BEA_NUMATE",M->BE1_NUMATE})
	Endif
Endif

//Rede de Atendimento...                                                  
//06/01/14 - Realizado ajuste para sempre gravar OPESOL qdo for intercambio≥
//Esta informacao e necessaria para posteriormente identificar a Operadora
//solicitante no recebimento dos arquivos de resposta de auditoria        

If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar) .Or. (nOpc == K_Copiar)
	aadd(aDadBEA,{"BEA_CODRDA",M->BE1_CODRDA})
	aadd(aDadBEA,{"BEA_NOMRDA",M->BE1_NOMRDA})
	If ! Empty(M->BE1_REGSOL)
		aadd(aDadBEA,{"BEA_SIGLA",M->BE1_SIGLA})
		aadd(aDadBEA,{"BEA_ESTSOL",M->BE1_ESTSOL})
		aadd(aDadBEA,{"BEA_REGSOL",M->BE1_REGSOL})
		aadd(aDadBEA,{"BEA_NOMSOL",M->BE1_NOMSOL})
		If BEA->(FieldPos("BEA_NRTROL"))> 0  .And. !Empty(M->BE1_NRTROL) .And. Empty(M->BE1_OPESOL)
			aadd(aDadBEA,{"BEA_OPESOL",PlsIntPad()})
		Else
			aadd(aDadBEA,{"BEA_OPESOL",M->BE1_OPESOL})
		EndIf
	Else
		aadd(aDadBEA,{"BEA_SIGLA",""})
		aadd(aDadBEA,{"BEA_ESTSOL",""})
		aadd(aDadBEA,{"BEA_REGSOL",""})
		aadd(aDadBEA,{"BEA_NOMSOL",""})
		If BEA->(FieldPos("BEA_NRTROL"))> 0  .And. !Empty(M->BE1_NRTROL)
			If !Empty(M->BE1_OPESOL)
				aadd(aDadBEA,{"BEA_OPESOL",M->BE1_OPESOL})
			Else
				aadd(aDadBEA,{"BEA_OPESOL",PlsIntPad()})
			EndIf
		Else
			aadd(aDadBEA,{"BEA_OPESOL",""})
		EndIf
	Endif
	If ! Empty(M->BE1_REGEXE)
		aadd(aDadBEA,{"BEA_ESTEXE",M->BE1_ESTEXE})
		aadd(aDadBEA,{"BEA_REGEXE",M->BE1_REGEXE})
		aadd(aDadBEA,{"BEA_NOMEXE",M->BE1_NOMEXE})
		aadd(aDadBEA,{"BEA_SIGEXE",M->BE1_SIGEXE})
	Else
		aadd(aDadBEA,{"BEA_ESTEXE",""})
		aadd(aDadBEA,{"BEA_REGEXE",""})
		aadd(aDadBEA,{"BEA_NOMEXE",""})
		aadd(aDadBEA,{"BEA_SIGEXE",""})
	Endif
Endif

//Local de Atendimento...                                                 

If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
	aadd(aDadBEA,{"BEA_CODLOC",Subs(M->BE1_CODLOC,1,3)})
	aadd(aDadBEA,{"BEA_LOCAL",Subs(M->BE1_CODLOC,4,3)})
	aadd(aDadBEA,{"BEA_DESLOC",M->BE1_DESLOC})
	aadd(aDadBEA,{"BEA_ENDLOC",M->BE1_ENDLOC})
Endif

//Especialidade...                                                        

If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
	aadd(aDadBEA,{"BEA_CODESP",aDadRDA[15]})
	aadd(aDadBEA,{"BEA_DESESP",aDadRDA[17]})
Endif

//Usuario...                                                              

If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
	aadd(aDadBEA,{"BEA_OPEUSR",Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])})
	aadd(aDadBEA,{"BEA_CODEMP",Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])})
	aadd(aDadBEA,{"BEA_MATRIC",Subs(aDadUsr[2],atMatric[1],atMatric[2])})
	aadd(aDadBEA,{"BEA_TIPREG",Subs(aDadUsr[2],atTipReg[1],atTipReg[2])})
	aadd(aDadBEA,{"BEA_MATVID",aDadUsr[5]})
	aadd(aDadBEA,{"BEA_NOMUSR",M->BE1_NOMUSR})
	aadd(aDadBEA,{"BEA_NOMTIT",aDadUsr[6]})
	aadd(aDadBEA,{"BEA_CONEMP",aDadUsr[9]})
	aadd(aDadBEA,{"BEA_VERCON",aDadUsr[39]})
	aadd(aDadBEA,{"BEA_SUBCON",aDadUsr[41]})
	aadd(aDadBEA,{"BEA_VERSUB",aDadUsr[42]})
	aadd(aDadBEA,{"BEA_CPFUSR",BA1->BA1_CPFUSR})
	aadd(aDadBEA,{"BEA_IDUSR",BA1->BA1_DRGUSR})
	aadd(aDadBEA,{"BEA_DATNAS",aDadUsr[26]})
	aadd(aDadBEA,{"BEA_DIGITO",Subs(aDadUsr[2],atDigito[1],atDigito[2])})
Endif

//                                                                        
//<< BE2 BE2 BE2 BE2 >> Monta dados dos ITENS PROCEDIMENTOS...            
//                                                                        


//Dados sempre atualizados (Inclusao/Alteracao)...                        

If nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Copiar
	aadd(aChaveGen,{"BE2_DATPRO",M->BE1_DATPRO})
	aadd(aChaveGen,{"BE2_HORPRO",M->BE1_HORPRO})
	aadd(aChaveGen,{"BE2_TPGRV" ,"1"})
	aadd(aChaveGen,{"BE2_CDPFSO",M->BE1_CDPFSO})
	aadd(aChaveGen,{"BE2_CDPFSO",M->BE1_CDPFSO})
	aadd(aChaveGen,{"BE2_TIPRDA",BAU->BAU_TIPPE})
	aadd(aChaveGen,{"BE2_IDUSR",BA1->BA1_DRGUSR})
	aadd(aChaveGen,{"BE2_ENDLOC",M->BE1_ENDLOC})
	aadd(aChaveGen,{"BE2_DESLOC",M->BE1_DESLOC})
	aadd(aChaveGen,{"BE2_ATEAMB",M->BE1_ATEAMB})
	aadd(aChaveGen,{"BE2_CID",M->BE1_CID})
	aadd(aChaveGen,{"BE2_DATNAS",aDadUsr[26]})
	aadd(aChaveGen,{"BE2_CPFRDA",BAU->BAU_CPFCGC})
	aadd(aChaveGen,{"BE2_NUMIMP",M->BE1_NUMIMP})
	aadd(aChaveGen,{"BE2_GUIACO",M->BE1_GUIACO})
	aadd(aChaveGen,{"BE2_QUACOB",M->BE1_QUACOB})
	If Type("BE1_COMUNI") == "C" .And. BEA->( FieldPos("BEA_TIPCON") ) > 0 .And. Type("M->BE1_TIPCON") == "C"
		aadd(aChaveGen,{"BE2_TIPCON",M->BE1_TIPCON})
	EndIf
	If BE2->(FieldPos("BE2_NRAOPE")) > 0
		aadd(aChaveGen,{"BE2_NRAOPE",M->BE1_NRAOPE})
	Endif
Endif

//Usuario...                                                              

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
	aadd(aChaveGen,{"BE2_MATANT",M->BE1_MATANT})
	aadd(aChaveGen,{"BE2_ATEAMB",M->BE1_ATEAMB})
	aadd(aChaveGen,{"BE2_CID",M->BE1_CID})
Endif

//Rede de Atendimento...                                                  

If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)

	//Procedimentos...                                                        

	aadd(aChaveGen,{"BE2_PRFATD",aDadRDA[5]})
	aadd(aChaveGen,{"BE2_OPERDA",M->BE1_OPERDA})
	aadd(aChaveGen,{"BE2_CODRDA",M->BE1_CODRDA})
Endif

//Local de Atendimento...                                                 

If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)

	//Procedimentos...                                                        

	aadd(aChaveGen,{"BE2_CODLOC",Subs(M->BE1_CODLOC,1,3)})
	aadd(aChaveGen,{"BE2_LOCAL ",Subs(M->BE1_CODLOC,4,3)})
Endif

//Especialidade...                                                        

If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
	aadd(aChaveGen,{"BE2_CODESP",aDadRDA[15]})
Endif

//Quando for uma exclusao e for de intercambio e foi solicitado autorizacao
//online vai entrar na funcao PLSASOEEXE para solicitar a exclusao 		 
//lRet inicia como .T. para que possa seguir o processo nomal caso nao entre≥

If nOpc == K_Excluir .And. ( Type("BE1_COMUNI") == "C" .And.;
Type("BE1_MSG04") == "C"  .And. Type("BE1_NRTROL") == "C" .And.;
Type("BE1_VIACAR") == "N" ) .And. M->BE1_COMUNI == "1"

	If ! Empty(BEA->BEA_GUIORI)

		aAreaBEA	:= BEA->(GetArea())
		cNrlBor		:= BEA->BEA_NRLBOR

		cSql := " SELECT BEA_NRLBOR "
		cSQL += " FROM " + retSQLName("BEA")
		cSQL += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' "
		cSQL += " AND BEA_NRLBOR = '" + cNrlBor + "' "
		cSQL += " AND BEA_STATUS = '1' OR BEA_STATUS = '2' "
		cSQL += " AND D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBEA",.T.,.F.)

		While !TRBEA->(EOF())
			nCont++
			TRBEA->(DbSkip())
		EndDo

		TRBEA->(dbCloseArea())
		
		If nCont == 1 .And. MsgYesNo(STR0638+substr(BEA->BEA_NRLBOR,1,4)+"-"+substr(BEA->BEA_NRLBOR,5,4)+"."+substr(BEA->BEA_NRLBOR,9,2)+"-"+substr(BEA->BEA_NRLBOR,11,8)+STR0639 )//"Esta guia È uma execuÁ„o da LiberaÁ„o "###" que foi autorizada atravÈs do interc‚mbio Online. Deseja enviar para a Operadora Origem do Benefici·rio uma comunicaÁ„o do Cancelamento?"
			lCancelPTU := .T.
		EndIf

		RestArea(aAreaBEA)

	Else
		lCancelPTU := .T.
	EndIf

	If lCancelPTU
		lRet := PLSASOEEXE("BE1",.F.)
	EndIf	

Endif

If nOpc == K_Excluir .And. lEvoluSADT
	aChav09 := {{"BQV_FILIAL,BQV_CODOPE,BQV_ANOINT,BQV_MESINT,BQV_NUMINT",xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)}}
	PLUPTCOLS("BQV",oBrwBQV090:aCols,oBrwBQV090:aHeader,oBrwBQV090:aVetTrab,5,aChav09,.t.)
	PLUPTCOLS("BQZ",oBrwBQZ090:aCols,oBrwBQZ090:aHeader,oBrwBQZ090:aVetTrab,5,aChav09,.t.)
Endif

//Executa rotina generica de gravacao...                                  

If lRet

	//Grava																	          

	If nOpc == K_Copiar
		nOpc2 := nOpc
		nOpc  := K_Incluir
	EndIf

	If ValType(oBrwB4B) <> 'U'
		aColsB4B   := oBrwB4B:RetaCols()
		aHeaderB4B := oBrwB4B:aHeader
		aVetB4B    := oBrwB4B:aVetTrab
	Endif

	If FindFunction("PLSA790C") .And. PLSALIASEXI("B53")
	
		// Ao confirmar guia com procedimentos q contÈm pacote È intermitente a gravaÁ„o das criticas sendo necessario o ajuste no browse tela
		If lPLSEXPC .and. len(aRdaPt)>0 .and. (len(aCriPacote) > len(oBrwCri:aCols))
			oBrwCri:aCols := aCriPacote
		endIf

		//Se o procedimento tem crÌtica, mas n„o È de auditoria
		//	as criticas que s„o enviadas para a tabela de crÌticas da auditoria
		//	s„o retiradas.                   											
		nQtdPrc := Len(oBrwPro:aCols)
		nQtdCri := LEN(oBrwCri:aCols)

		for nPr := 1 To nqtdPrc
			//esse item foi retirado pois mesmo sem enviar para auditoria temos que gravar a critica
			//If oBrwPro:aCols[nPr][GdFieldPos("BE2_AUDITO",oBrwPro:aHeader)] != "0"

			For nCr:= 1 To nQtdCri
				If oBrwCri:aCols[nCr][GdFieldPos("BEG_SEQUEN",oBrwCri:aHeader)] == oBrwPro:aCols[nPr][GdFieldPos("BE2_SEQUEN",oBrwPro:aHeader)]

					aadd(aColBEG,oBrwCri:aCols[nCr])
				EndIf
			Next
			//EndIf
		Next
	Else

		aColBEG := aClone(oBrwCri:aCols)
	EndIf

	aHeaBEG := aClone(oBrwCri:aHeader)
	aVtaBEG := aClone(oBrwCri:aVetTrab)

	aRetorno := PLSA090Grv(oBrwPro:aCols,oBrwPro:aHeader,aDadBEA,nOpc,oBrwPro:aVetTrab,aChaveGen,;
	M->BE1_USUARI,M->BE1_DATPRO,M->BE1_HORPRO,M->BE1_MATUSA,M->BE1_ANOPAG,M->BE1_MESPAG,;
	If(!lConsulta,GetNewPar("MV_PLSTPGS","02"),GetNewPar("MV_PLSTPGC","01")),;
	/*lIntern*/,aColBEG,aHeaBEG,aVtaBEG,/*lAutori*/,cTipo,;
	If((nOpc == K_Incluir .Or. nOpc == K_Copiar),"",BEA->BEA_CODLDP),/*lReanaliza*/,nil,/*cKey*/,;
	/*lForBloq*/,/*lVeioComu*/,lNMudFase,/*cAliasIte*/,/*cAliasCri*/,/*lAjusta*/,/*lEvolu*/,;
	/*aDadBE4*/,lGerSenha,/*lWeb*/,aDadB43,aCabB43,/*aTrbB43*/,/*oBrwEven*/,/*lExcluiAte*/,;
	/*oBrwB47*/,/*cAliasCab*/,/*lReembolso*/,/*oBrwB46*/,/*oBrwB44*/,/*lIncNeg*/,/*cObsoleto*/,/*lSolicit*/,;
	/*cTpGrv*/,/*aColsDF*/,/*aHeaderDF*/,/*aVetDF*/,/*aDaSenPro*/,/*lGuiHoRe*/,/*aMatBd6*/,aMatCom,;
	/*lResInt*/,/*cAliasCmp*/,/*lOdontoWeb*/,/*cNumLib*/,/*cArqImp*/,/*lEvoSadt*/,;
	IIF(Type("cSituacPTU") <> "U" .And. ! Empty(cSituacPTU),cSituacPTU,NIL),/*lProtoc*/,/*aPartic*/,aColsB4B,;
	aHeaderB4B,aVetB4B,/*cNumLibOd*/,/*lRecGlo*/,/*lPTUOnSol*/,/*cObsEvo*/,M->BE1_NRTROL,M->BE1_NRAOPE,;
	/*cOpeSolPTU*/,/*cNewAut*/,/*lPtuOnline*/,/*aCampCust*/,dValSen,/*lSUS*/,/*aArraySUS*/,;
	/*lReembCriaBD5*/,/*lGuiAudit*/,oGetBZC,cTrolComun,/*aBQVPTUDif*/,/*strJsonB7B*/,aDadB6M)
	nOpc := nOpc2

	If Type("cHshLib") <> "U"
		cHshLib := ""
	EndIf

	//radioterapia
	If aRetorno[12]
		Aviso(	"Guia de Radioterapia", ; 
		"A Guia possui procedimentos de Radioterapia. Digite a guia de Anexo de Radioterapia para complementar as informaÁıes do tratamento.",; 
		{ "OK" }, 2 )  //"Sim"###"Nao"
	EndIf


	// Vinculo do protocolo da SolicitaÁ„o de AutorizaÁ„o gerado pelo beneficiario via Portal
	If ValType(cNrProWeb) != "U" .and. !Empty(cNrProWeb) 		
		cNrAutWeb := aRetorno[2]
		cNrAutWeb += aRetorno[3]
		cNrAutWeb += aRetorno[4]
	    cNrAutWeb += aRetorno[5]
	    cStAutWeb := aRetorno[10]
	    cTpAutWeb := "S"
	    If !Empty(cNrAutWeb) .And. !Empty(cNrProWeb)
	    	GrvVincAut(cNrAutWeb,cNrProWeb,cStAutWeb,cTpAutWeb,"")
	    EndIf			
	EndIf


	If ExistBlock("PLS090AR")
		ExecBlock("PLS090AR",.F.,.F.,{nOpc,.T.})//indica que È uma autorizacao
	EndIf

EndIf

//Exibe log do PTU quando globo de comunicacao esta desativado            
If GetNewPar("MV_PTGLOBO","1") <> "1"
	If !Empty(cAvisoRet)
		Aviso( STR0120, cAvisoRet , { STR0146 }, 2 )
	EndIf

	If len(aResComuni) > 0

		BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(DbSeek(xFilial("BA1")+M->BE1_USUARI))
				PTUResCom(aResComuni[1],aResComuni[2],aResComuni[3],aResComuni[4],aResComuni[5],aResComuni[6],aResComuni[7],aResComuni[8],BA1->(Recno()),.T.)
			EndIf

		EndIf

	Endif

Return(lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥PLSVERPCT≥ Autor ≥   Roberto Vanderlei   ≥ Data ≥ 31.03.15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Verifica se o pacote ja esta na gride.			           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

function PLSVERPCT(cCodPad,cCodPro, cCampo, oBrwProPesquisa)

local lExistePct := .F.
local nX
local nI
local cCodInt := plsIntPad()
local aProc := {}
local cProcedimento := ""
local cSQL := ""


For nX := 1 to Len(oBrwProPesquisa:aCols)

	If Alltrim(cCodPro) == Alltrim(oBrwProPesquisa:aCols[nX,PLRETPOS(cCampo/*"BE2_CODPRO"*/,oBrwProPesquisa:aHeader)]) .and. oBrwProPesquisa:aCols[nX,1] != "DISABLE"
		lExistePct := .T.
	end if		

Next nX


if(!empty(cCodPad) .and. !lExistePct)
	cSQL := " SELECT BLE_CPADOC, BLE_CODPRO, BLE_CODPAD, BLE_CODOPC "
	cSQL += "   FROM " + retSQLName("BLE")
	cSQL += "  WHERE BLE_FILIAL = '" + xFilial("BLE") + "' "
	cSQL += "    AND BLE_CODINT = '" + cCodInt + "' "
	cSQL += "    AND BLE_CODPAD = '" + cCodPad + "' "
	cSQL += "    AND BLE_CODPRO = '" + cCodPro + "' "
	cSQL += "    AND BLE_TIPO = '9' "
	cSQL += "    AND ( BLE_VIGDE <= '" + dtos(dDataBase) + "' AND "
	cSQL += "        ( BLE_VIGATE = '' OR '" + dtos(dDataBase) + "' <= BLE_VIGATE ) ) "
	cSQL += "    AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"TRBBLE",.T.,.F.)

	while ! TRBBLE->(eof())

		cProcedimento := BR8->( posicione("BR8",1,xFilial("BR8") + TRBBLE->(BLE_CPADOC + BLE_CODOPC) ,"BR8_DESCRI") )
		aadd(aProc, { TRBBLE->BLE_CODOPC, TRBBLE->BLE_CODPAD,cProcedimento})

		TRBBLE->(DbSkip())
	endDo

	TRBBLE->( dbCloseArea())

	if(len(oBrwProPesquisa:aCols)>0 .and. len(aProc)>0)
		for nI := 1 to len(aProc)
			for nX := 1 to len(oBrwProPesquisa:aCols)
				if (oBrwProPesquisa:aCols[nX,4] != "" .and. oBrwProPesquisa:aCols[nX,4] == aProc[nI,1]) 
						lExistePct := .T.
				endIf
			next
		next
	endIf

	//Inicializando array
    aRdaPt := {}

	if(!lExistePct) .and. len(aProc)>0
		aRdaPt := aClone(aProc)
	endIf

endIf




return(lExistePct) 

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥PLSADDPCT≥ Autor ≥ Roberto Vanderlei    ≥ Data ≥ 31.03.15  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Adiciona itens do pacote na gride de procedimentos.        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function PLSADDPCT(cAlias, cCodPad, cCodPro, lPacote, nQtdSol, nQtdPro, nNivAut, nNivCrit, cStatus, cSequen, oBrwProPesquisa,aRdaPt,cAudito)
local lRet 			:= .t.
local nI			:= 0
local nLinha		:= 0
local nSeq          := 0
local nPos          := 0	
local cProcedimento := ""
local cCodInt		:= plsIntPad()		
local nPosCmp  		:= gdFieldPos(cAlias+"_CODPRO",oBrwProPesquisa:aHeader) 
local lExistReg		:= .F.
local lPLSEXPC 		:= getNewPar("MV_PLSEXPC",.f.)

//TODO - 20/04/2018 - Roberto - necessario rever este codigo

if  lPacote .and. lPLSEXPC .and. len(aRdaPt)>0

	// tratamento para q n„o inclua o codigo do pacote somente os itens
	lExistReg := aScan( oBrwProPesquisa:aCols,{|x| x[nPosCmp] == cCodPro }) > 0 .and. len(oBrwProPesquisa:aCols) > 0

	If lExistReg	
       nPos := aScan( oBrwProPesquisa:aCols,{|x| x[nPosCmp] == cCodPro })
	   if nPos > 0
	       aDel(oBrwProPesquisa:aCols, nPos)
		   aSize(oBrwProPesquisa:aCols, len(oBrwProPesquisa:aCols)-1) 
	   endIf
	endIf
	

	if len(aRdaPt) > 0

		aviso( STR0054, STR0552, { STR0146 }, 2 ) //"Este cÛdigo de pacote possui procedimentos relacionados, os procedimentos ser„o carregados e devem compor a guia."

		for nI := 1 to len(aRdaPt)	

			if ! PLSVERPCT("",aRdaPt[nI][1], cAlias + "_CODPRO", oBrwProPesquisa) 		
					
				oBrwProPesquisa:addBlank()
				oBrwProPesquisa:setPos(len(oBrwProPesquisa:aCols))	

				nLinha := len(oBrwProPesquisa:aCols)

				oBrwProPesquisa:Consiste() 
				oBrwProPesquisa:Refresh()

				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_SEQUEN",oBrwProPesquisa:aHeader)] := STRZERO(val(cSequen)+nSeq, 3 )
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_IMGSTA",oBrwProPesquisa:aHeader)] := If(cStatus=="1","ENABLE","DISABLE") //"ENABLE"
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_CODPRO",oBrwProPesquisa:aHeader)] := aRdaPt[nI][1]
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_CODPAD",oBrwProPesquisa:aHeader)] := aRdaPt[nI][2]
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_DESPRO",oBrwProPesquisa:aHeader)] := aRdaPt[nI][3] 		
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_QTDSOL",oBrwProPesquisa:aHeader)] := nQtdSol
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_QTDPRO",oBrwProPesquisa:aHeader)] := nQtdPro
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_NIVAUT",oBrwProPesquisa:aHeader)] := nNivAut
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_NIVCRI",oBrwProPesquisa:aHeader)] := nNivCrit
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_STATUS",oBrwProPesquisa:aHeader)] := cStatus
				oBrwProPesquisa:aCols[nLinha,PLRETPOS(cAlias + "_AUDITO",oBrwProPesquisa:aHeader)] := cAudito
				nSeq++
				endIf
				
			next

			oBrwProPesquisa:consiste()
			oBrwProPesquisa:refresh()
		endIf

endIf

return (lRet)

/*/{Protheus.doc} PLSA090AUT
Validacao do procedimento...

cTipo
"1" Default - Atualiza os M->BE2
"2"         - Atualiza o oBroPro direto (geralmente executado via autorizacao consulta)

cRegAte
1 - Internacao
2 - Ambulatorial

aDadProrro
Informa a data e hora de uma internaÁ„o, caso a RDA esteja bloqueado ir· verificar se 
foi feita a internaÁ„o antes do bloqueio da RDA, caso seja permitir a inclus„o.

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
Function PLSA090Aut(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,cAliasIte,cAliasCab,cAliasCri,oBrwPro,oBrwCri,cCodExe,lChkPag,lPerFor,cPadInt,;
	cPadCon,cFaces,cGrpInt,aObsolet,lEvolucao,aDadB43,aCabB43,aTrbB43,cRegAte,cTipoProc,oBrwBEJ,cAliasProc,lVldObrg,;
	lNegProPac,cGrauPa,lIntern,aCritCab,lTratRda,aDadProrro,lCriDatSup)
	LOCAL nPos		  := 0
	LOCAL nPos2		  := 0
	LOCAL nPosAcu	  := 0	
	LOCAL nFor		  := 0
	LOCAL nLin		  := 0
	LOCAL nRecBR8 	  := 0
	LOCAL nOrdBR8 	  := 0
	LOCAL nPrPrRl     := 0
	LOCAL nInd		  := 0
	LOCAL nI		  := 0
	LOCAL njx		  := 0
	LOCAL nPosPacote  := 0
	LOCAL njy		  := 0
	LOCAL nj		  := 0
	local nTamCODPRO  := BLE->(tamSX3("BLE_CODPRO")[1])
LOCAL nOrdBA0     := BA0->(IndexOrd())
LOCAL nRecBA0     := BA0->(Recno())
LOCAL cSQL		  := ""
LOCAL cOpeOri	  := ""
local cTipGui	  := PLSRetAut()[1]
LOCAL cRDAEDI	  := ""
LOCAL cProRel     := ""
LOCAL cAteRNA     := "0"
LOCAL cRetGui     := ""
LOCAL cSomInt     := ""
LOCAL cTipPreGui  := ""
LOCAL cChavLib    := ""
LOCAL cStrFil	  := ""
LOCAL cCodSol     := ""
LOCAL cOpeSol	  := ""
LOCAL cTipAdmissao:= ""
LOCAL cTipAte 	  := ""
LOCAL cRegInt	  := ""
LOCAL cFinAte	  := ""
LOCAL cCodEsp     := ""
LOCAL cGuiJur     := ""		// Conceito de guia juridica.
LOCAL cEspSol     := ""
LOCAL cEspExe	  := ""
LOCAL cHorPro	  := ""
LOCAL lChkLib 		:= GetNewPar("MV_PLSCKLB", .T.) //Indica se as regras de periodicidade e quantidade serao avaliadas na liberacao
local cTpaten	  := ""
local lPLSMSGPCT  := FindFunction("PLSMSGPCT") 
local cCodInt	  := plsIntPad()
LOCAL dDatPro	  := ctod("")
LOCAL cCodGloAud  := __aCdCri051[1]
LOCAL aRetAux	  := {}
LOCAL aValor  	  := {}
LOCAL aCliente    := {}
LOCAL aRet        := {}
LOCAL aRetFun 	  := {}
LOCAL aHisCri     := {}
LOCAL aRetB43	  := {}
LOCAL aDadUsr     := PLSGETUSR()
LOCAL aDadRDA     := PLSGETRDA()
LOCAL aHeader	  := {}
LOCAL lRet        := .T.
LOCAL lForcou     := .F.
LOCAL lAuditoria  := .F.
LOCAL lAto        := .F.
LOCAL lLibEsp     := .F.
LOCAL lUnimeds    := IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
LOCAL lTratExLib  := IF(AllTrim(GETNEWPAR("MV_PLEXLB","0"))=="1",.T.,.F.)
LOCAL lFlag       := .F.
LOCAL lConPagAto  := .F.
LOCAL lPLSEXPC    := getNewPar("MV_PLSEXPC", .f.)
local lConsulta	  := .f.					   
LOCAL aQtdBrow	  := {}
LOCAL aOldCodCri  := {}
LOCAL aAuxRetPro  := {}
LOCAL aItGeralPac := {}
LOCAL aItensPac	  := {}
local aDados 	  := {}
local aDadoPro    := {} 
local aAlerta 	  := {} 
Local lLimCab     := .F.
Local nCab        := 0
Local nRet        := 0                      
Local nRet2       := 0
Local lVerCob     := .F.
Local nAd         := 0
Local lBCTAudito  := BCT->( FieldPos("BCT_AUDITO") ) > 0
local cBkpPad     := ""
local cBkpPro     := ""
LOCAL cMVPLSRDAG  := GetNewPar("MV_PLSRDAG","999999")
Local cCid		  := ""
Local cGuiaEmp	  := ""
Local lFoundItem  := .F. 
Local lCodDigitadoCheck := .F.
Local lUsrInt := iIf( allTrim(cMV_PLSGEIN) == BA1->BA1_CODEMP,.t.,.f.)
Local lPTUOn90 := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
Local cTipoRDA := ""
Local cCodOpeRDA := ""

DEFAULT lEvolucao := .F.
DEFAULT cTipo     := "1"
DEFAULT cAliasIte := "BE2"
DEFAULT cAliasCab := "BE1"
DEFAULT cAliasCri := "BEG"
DEFAULT cCodExe   := ""
DEFAULT lChkPag   := .T.
DEFAULT lPerFor   := .T.
DEFAULT cPadInt   := ""
DEFAULT cPadCon   := ""
DEFAULT cFaces    := ""
DEFAULT cGrpInt   := ""
DEFAULT aObsolet   := {}
DEFAULT aDadB43   := {}
DEFAULT aCabB43   := {}
DEFAULT aTrbB43   := {}
DEFAULT cRegAte	  := ""
DEFAULT lVldObrg  := .T.
DEFAULT cTipoProc := ""
DEFAULT cAliasProc:= ""
DEFAULT lNegProPac:= .F.
DEFAULT cGrauPa	  := ""
DEFAULT aCritCab  := {}
DEFAULT lTratRda  := getNewPar("MV_PLSMODA","1") == "1"
DEFAULT aDadProrro := {}
DEFAULT lCriDatSup := .T. //Default do PLSAUTP È .T.

//TODO - 20/04/2018 - Roberto - necessario rever este codigo
//TODO - Verificar chamada deste metodo ao sair do campo codpad (neste momento o codpro esta vindo errado) tabela B7B
//TODO - verificar verificar chamado que nao envia o codrda (em branco)

If lPLSEXPC .and. ( cAliasIte = 'BE2' .or. cAliasIte =  'BEJ' )

	&("M->"+cAliasIte+"_PROPCT") := .F.

	//Verifica se o evento e um pacote
	BLE->(dbSetOrder(1))//BLE_FILIAL+BLE_CODINT+BLE_CODPAD+BLE_CODPRO+BLE_TIPO+BLE_CPADOC+BLE_CODOPC
	if BLE->( msSeek( xFilial("BLE") + cCodInt + cCodPad + allTrim(cCodPro) + space( nTamCODPRO - len(allTrim(cCodPro) ) ) + "9" ) ) .and. BLE->BLE_VIGDE <= dDataBase .and. ( empty(BLE->BLE_VIGATE) .or. dDataBase <= BLE->BLE_VIGATE )

		BLZ->(dbSetOrder(1))//BLZ_FILIAL+BLZ_CODINT+BLZ_CODRDA+BLZ_CODPAD+BLZ_CODPRO

		if ! BLZ->( msSeek( xFilial("BLZ") + cCodInt + aDadRda[2] + cCodPad + cCodPro ) )

			MsgInfo("Esse pacote n„o pertence a RDA informada, n„o poder· ser utilizado. Verifique!!!","AtenÁ„o") 

		else

			&("M->"+cAliasIte+"_PROPCT") := .T.

		endIf

	else

		//verifica se o codigo do evento esta em um pacote
		cSQL := " SELECT BLE_CPADOC, BLE_CODOPC, BLE_CODPRO, BLE_CODPAD "
		cSQL += "   FROM " + retSQLName("BLE")
		cSQL += "  WHERE BLE_FILIAL = '" + xFilial("BLE") + "' "
		cSQL += "    AND BLE_CODINT = '" + cCodInt + "' "
		cSQL += "    AND BLE_CPADOC = '" + cCodPad + "' "
		cSQL += "    AND BLE_CODOPC = '" + cCodPro + "' "
		cSQL += "    AND BLE_TIPO   = '9' "
		cSQL += "    AND ( BLE_VIGDE <= '" + dtos(dDataBase) + "' AND "
		cSQL += "        ( BLE_VIGATE = '' OR '" + dtos(dDataBase) + "' <= BLE_VIGATE ) ) "
		cSQL += "    AND D_E_L_E_T_ = '' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"TRBBLE",.T.,.F.)

		if ! TRBBLE->(eof())

			&("M->"+cAliasIte+"_PROPCT") := .T.

			BLD->(dbSetOrder(1))//BLD_FILIAL+BLD_CODINT+BLD_CODPAD+BLD_CODPRO
			BLZ->(dbSetOrder(1))//BLZ_FILIAL+BLZ_CODINT+BLZ_CODRDA+BLZ_CODPAD+BLZ_CODPRO

			while ! TRBBLE->(eof())

				if BLD->( msSeek( xFilial("BLD") + cCodInt + TRBBLE->(BLE_CODPAD + BLE_CODPRO) ) )

					//Verifica se na tabela de RDA x Pacote existe o procedimento dentro do pacote
					if BLZ->( msSeek( xFilial("BLZ") + BLD->BLD_CODINT + aDadRda[2] + BLD->(BLD_CODPAD+BLD_CODPRO) ) )
						aadd(aDados, {BLD->BLD_CODPRO, BLD->BLD_DESPRO})
						aadd(aDadoPro,{BLD->BLD_CODPAD, BLD->BLD_CODPRO}) 
					endIf

				endIf	

				TRBBLE->(dbSkip())
			endDo


			If Len(aDados) > 0 .and. lPLSMSGPCT

				Aviso( STR0054, STR0551, { STR0146 }, 2 ) //"Este procedimento esta vinculado a um ou mais pacotes, selecione o pacote correspondente a execuÁ„o."

				// Guardo o codPad anterior Caso seja informado um procedimento que ja esteja na grid	
				cBkpPad := &("M->"+cAliasIte+"_CODPAD")
				cBkpPro	:= &("M->"+cAliasIte+"_CODPRO")

				cCodPct := PLSMSGPCT( &("M->"+cAliasIte+"_CODPRO"), aDados) 	


				If alltrim(cCodPct) <> "" .and. ValType(cCodPct) <> "N"

					&("M->"+cAliasIte+"_CODPRO") := allTrim(cCodPct)

					cCodPro	:= &("M->"+cAliasIte+"_CODPRO")

					cCodPad := aDadoPro[Ascan( aDadoPro,{|x| x[2] == cCodPct } )][1] 

					&("M->"+cAliasIte+"_CODPAD") := cCodPad

					TRBBLE->( dbCloseArea())


					If PLSVERPCT(cCodPad,&("M->"+cAliasIte+"_CODPRO"), cAliasIte + "_CODPRO", oBrwPro)

						Aviso( STR0054, STR0404, { STR0146 }, 2 ) //"AtenÁ„o"###"Este procedimento j· foi adicionado."###"Ok

						&("M->"+cAliasIte+"_DESPRO") := ""
						&("M->"+cAliasIte+"_CODPAD") := cBkpPad
						&("M->"+cAliasIte+"_CODPRO") := cBkpPro
						return 
					endIf

				elseIf ValType(cCodPct) <> "N"

					TRBBLE->( dbCloseArea())
					return

				endIf
					
				If ValType(cCodPct) == "N" 

					// Nessario validar novamente a grid caso haja procedimento duplicado.
					If PLSVERPCT("",&("M->"+cAliasIte+"_CODPRO"), cAliasIte + "_CODPRO", oBrwPro)
						Aviso( STR0054, STR0404, { STR0146 }, 2 ) 
						TRBBLE->( dbCloseArea() )
						return(.F.)

					else
						//Inicializando array de pacote para q n„o haja duplicidade na grid
                        aRdaPt := {}
					endIf

					
			    endIf

		    endIf

		endIf

		If Select("TRBBLE") > 0          
		    DbSelectArea("TRBBLE")        
		    DbCloseArea("TRBBLE")
		EndIf

	EndIf

EndIf

//Tipo de Atendimento
If Type("M->"+cAliasCab+"_TIPATE") == "C"
	cTipAte := &("M->"+cAliasCab+"_TIPATE")
EndIf

//Regime
If Type("M->"+cAliasCab+"_REGINT") == "C"
	cRegInt := &("M->"+cAliasCab+"_REGINT")
EndIf

//Finalidade
If Type("M->"+cAliasCab+"_TIPPAC") == "C"
	cFinAte := &("M->"+cAliasCab+"_TIPPAC")
EndIf

//Se todos obrigatorios foram informados									
If ValType(oEncAut) <> 'U' .And. lVldObrg
	If !Obrigatorio(oEncAut:aGets,oEncAut:aTela)
		Return(.F.)
	Endif
EndIf

//Nao informado															

If Type("M->"+cAliasCab+"_USUARI") == "C"
	If Empty(&("M->"+cAliasCab+"_USUARI"))
		Aviso( STR0071, ; //"Usuario"
		STR0112,; //"Informe o usuario."
		{ STR0146 }, 2 )
		Return(.F.)
	Endif
Endif

//Nao informado															

If Type("M->"+cAliasCab+"_CODRDA") == "C"
	If Empty(&("M->"+cAliasCab+"_CODRDA"))
		Aviso( "RDA", ;
		STR0113,; //"Rede de Atendimento."
		{ STR0146 }, 2 )
		Return(.F.)
	Endif
Endif


//Trata se o solicitante foi digitado...                                  
lConsulta  := (PLSISCON(cCodPad,cCodPro) .And. Len(oBrwPro:aCols) == 1)

If  ! UPPER( Alltrim( FunName() ) ) $ "PLSA094C,PLSA094D" .and. !lConsulta .And. AllTrim(GetNewPar("MV_PLSOSOL","1")) == "1" .And. type('M->BE1_OPESOL') <> 'U' .and. M->BE1_OPESOL == PLSINTPAD() .And. Empty(M->BE1_REGSOL)
	Help("",1,"PLSA090SOL")
	Return(.F.)
Endif

IF lIntGui .And. !lConsulta  
	If Type("M->BE1_GUIPRI") == "C"  
		IF  Empty(M->BE1_GUIPRI) 
			Aviso( STR0573 ,STR0574, { STR0146 }, 2 ) //"Este Paciente Encontra -se  Bloqueado" #"Necessario informar a Guia Principal da InternaÁ„o "
			Return(.F.)	
		Endif	
	Endif
Endif	

//Nao informado															

If Len(aDadUsr) == 0
	If Empty(&("M->"+cAliasCab+"_USUARI"))
		Aviso( STR0071, ; //"Usuario"
		STR0114,; //"Informe um usuario valido."
		{ STR0146 }, 2 )
		Return(.F.)
	Endif
Endif

//Nao informado															

If Type("M->"+cAliasCab+"_NUMLIB") == "C"
	If !Empty(&("M->"+cAliasCab+"_NUMLIB"))
		cChavLib := &("M->"+cAliasCab+"_NUMLIB")
	Endif
Endif

//Pega operadora															

If Len(aDadUsr) >= 45

	cOpeOri := aDadUsr[45]

	If Len(aDadRda) >= 27
		cTipoRDA := aDadRda[27]
		cCodOpeRDA := aDadRda[28]
	EndIf

	If lPTUOn90 .And. lUnimeds .And. !lConsulta 
		If cOpeOri <> PlsIntPad() .Or. (cCodOpeRDA <> PlsIntPad() .And. cTipoRDA == GetNewPar("MV_PLSTPIN", "OPE"))

			If Type("M->"+cAliasCab+"_ESPSOL") == "C" .And. Empty(&("M->"+cAliasCab+"_ESPSOL"))
				Help(,,STR0661,, STR0677, 1, 0,,,,,,{STR0678+" ("+cAliasCab+"_ESPSOL) "+STR0679}) // "CBO do Solicitante È obrigatÛrio para guias de SADT ou internaÁ„o.";"Preencher o campo Espec. Sol.";"no cabeÁalho da guia."
				Return(.F.)
			EndIf
		
		EndIf
	EndIf

	//Valida a Via da Carteirinha para usuario de intercambio					
	If BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1"

		BA0->(DbSetOrder(nOrdBA0))
		BA0->(DbGoTo(nRecBA0))

		If Type("M->"+cAliasCab+"_VIACAR") == "N"

			If !Empty(&("M->"+cAliasCab+"_MATANT") ) .And. &("M->"+cAliasCab+"_VIACAR") == 0

				Aviso( STR0115, ; //"Carteirinha"
				STR0496,;//"N„o foi informado a via do cart„o, ser· utilizada a via 00"
				{ STR0146 }, 2 )	//"ok"

			Endif

		EndIf

	EndIf

EndIf

If ValType(aDadRDA) == "A" .And. Len(aDadRDA) > 0 .And. aDadRda[23] == "1" .And. Empty(&("M->"+cAliasCab+"_REGEXE"))
	If cAliasCab == "BE4"
		Help("",1,"PLSA090001")
	Else
		Help("",1,"PLSA090EXE")
	EndIf
	Return(.F.)
Endif

If Type("M->"+cAliasIte+"_PROREL") == "C"
	cProRel := &("M->"+cAliasIte+"_PROREL")
Endif

If Type("M->"+cAliasCab+"_ESPSOL") == "C"
	cEspSol := &("M->"+cAliasCab+"_ESPSOL")
Endif

If Type("M->"+cAliasCab+"_ESPEXE") == "C"
	cEspExe := &("M->"+cAliasCab+"_ESPEXE")
Endif

If Type("M->"+cAliasIte+"_PRPRRL") == "N"
	nPrPrRl := &("M->"+cAliasIte+"_PRPRRL")
Endif

If Type("M->"+cAliasCab+"_ATERNA") == "C"
	cAteRNA := &("M->"+cAliascAB+"_ATERNA")
Endif

If Type("M->"+cAliasIte+"_SEQUEN") == "C" .And. Empty(cSequen)
	cSequen := &("M->"+cAliasIte+"_SEQUEN")
Endif

If Type("M->"+cAliasCab+"_TIPPRE") == "C"
	cTipPreGui := &("M->"+cAliasCab+"_TIPPRE")
Endif

If Type("M->"+cAliasCab+"_RDAEDI") == "C"
	cRDAEDI := &("M->"+cAliasCab+"_RDAEDI")
Endif

If Type("M->"+cAliasCab+"_TIPADM") == "C"
	cTipAdmissao := &("M->"+cAliasCab+"_TIPADM")
Endif


If Type("M->"+cAliasCab+"_CDPFSO") == "C"
	cCodSol := &("M->"+cAliasCab+"_CDPFSO")
	If cTipoProc=="S" .And. Empty(cCodSol) .And. !Empty(aDadRDA[5])
		cCodSol := aDadRDA[5]
	EndIf
EndIf

If Type("M->"+cAliasCab+"_OPESOL") == "C"
	cOpeSol := &("M->"+cAliasCab+"_OPESOL")
EndIf

If Type("M->"+cAliasCab+"_GUIJUR") == "C"

	cGuiJur := &("M->"+cAliasCab+"_GUIJUR")

	// O campo Guia Juridica sÛ ser· considerado se todos os critÈrios da critica forem atendidos.
	// Caso contrario, ignora o conteudo do campo.
	If cGuiJur == "1"
		If !PlsGetJur()[1]
			cGuiJur := ""
		Endif
	Endif

EndIf


//Por algum motivo o n esta mudando o valor quando e feito alteracao	    
n := oBrwPro:Linha()

If ! lRet
	Return(lRet)
Endif

//Roda autorizacao do procedimento...                                     
if cAliasIte $ "BQV/B4C"
	dDatPro := &("M->"+cAliasIte+"_DATPRO")
	if Type("M->"+cAliasIte+"_HORPRO") == "C"
		cHorPro := &("M->"+cAliasIte+"_HORPRO")
	endIf	
else
	dDatPro := &("M->"+cAliasCab+"_DATPRO")
endIf	
	
If Empty(dDatPro)
	dDatPro := dDataBase
Endif

If Empty(cHorPro) .And. Type("M->"+cAliasCab+"_HORPRO") == "C"
	cHorPro := &("M->"+cAliasCab+"_HORPRO")
Endif

//plsusuinte																 	
if empty(cRegAte) .and. len(aDadUsr) > 0
	cRegAte := iIf(len(aDadUsr) >= 92, aDadUsr[92], "")
endIf

//Pega os procedimentos que estao contidos no browse						

If ValType(oBrwPro) == "O" .And. ! lIntern

	For nFor := 1 To Len(oBrwPro:aCols)

		If ! oBrwPro:aCols[nFor][Len(oBrwPro:aCols[nFor])] .and. (oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_STATUS")] == "1" .Or. oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_AUDITO")] == "1") .And. oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_SEQUEN")] <> cSequen

			aadd(aQtdBrow,{oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_CODPAD")],;
			oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_CODPRO")],;
			oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_QTDPRO")],;
			dDatPro,;
			cHorPro,;
			If(oBrwPro:FieldPos("BE2_DENREG")>0,oBrwPro:FieldGet("BE2_DENREG",nFor),""),;
			If(oBrwPro:FieldPos("BE2_FADENT")>0,oBrwPro:FieldGet("BE2_FADENT",nFor),""),;
			oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_SEQUEN")]})

		EndIf

	Next

Endif

If ValType(oBrwBEJ) == "O" .and. ! empty(cAliasProc) .And. lIntern

	//Qdo EvoluÁ„o pega os procedimentos que estao contidos no browse Eventos (Atendimento)|
	For nFor := 1 To Len(oBrwBEJ:aCols)


		If ! oBrwBEJ:aCols[nFor][Len(oBrwBEJ:aCols[nFor])] .and. (oBrwBEJ:aCols[nFor][oBrwBEJ:FieldPos(cAliasProc+"_STATUS")] == "1" .Or. oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasIte+"_AUDITO")] == "1") .And. oBrwBEJ:aCols[nFor][oBrwBEJ:FieldPos(cAliasProc+"_SEQUEN")] <> cSequen
			aadd(aQtdBrow,{oBrwBEJ:aCols[nFor][oBrwBEJ:FieldPos(cAliasProc+"_CODPAD")],;
			oBrwBEJ:aCols[nFor][oBrwBEJ:FieldPos(cAliasProc+"_CODPRO")],;
			oBrwBEJ:aCols[nFor][oBrwBEJ:FieldPos(cAliasProc+"_QTDPRO")],;
			dDatPro,;
			cHorPro,;
			"",;
			"",;
			oBrwBEJ:aCols[nFor][oBrwBEJ:FieldPos(cAliasProc+"_SEQUEN")]})

		EndIf

	Next

Endif

//Utiliza a especialidade indicada na rotina					            
If Type("M->BE1_CODESP") == "C" .And. !Empty(M->BE1_CODESP) .And. Empty(cCodEsp)
	cCodEsp := M->BE1_CODESP
EndIf

//Tratamento do itens de pacote para que o sistema verifique se h·
//procedimento no pacote e fora do pacote.                        
For nj := 1 to Len(oBrwPro:aCols)

	//Checa se o procedimento encontrado e um pacote
	If Empty(oBrwPro:FieldGet(cAliasIte+"_CODPRO",nj))
		aItensPac := PlRetPac(PLSINTPAD(), If(TYPE("M->"+cAliasCab+"_CODRDA") == "C",&("M->"+cAliasCab+"_CODRDA"),padr('',TamSx3('BAU_CODIGO')[1])),cCodPad,cCodPro ,nil,dDatPro)
		lCodDigitadoCheck := .T.
	Else
		aItensPac := PlRetPac(PLSINTPAD(), If(TYPE("M->"+cAliasCab+"_CODRDA") == "C",&("M->"+cAliasCab+"_CODRDA"),padr('',TamSx3('BAU_CODIGO')[1])),oBrwPro:FieldGet(cAliasIte+"_CODPAD",nj) ,oBrwPro:FieldGet(cAliasIte+"_CODPRO",nj) ,nil,dDatPro)
	Endif
	
	// … UM PACOTE ADICIONO NO ARRAY PARA FUTURAS CONSULTAS SE HA PROCEDIMENTOS NO PACOTE
	If Len(aItensPac) > 0

		For njx:=1  to Len(aItensPac)
			lFoundItem := IIF(Len(aItensPac[njx]) >= 11, aItensPac[njx][11], .F.) 

			If !lFoundItem
				Aadd(aItGeralPac,aItensPac[njx,2])
			EndIf
		Next njx

		For njy:=1 to Len(oBrwPro:aCols)
			If Ascan( aItGeralPac ,oBrwPro:FieldGet(cAliasIte+"_CODPRO",njy)) > 0
				lNegProPac:= .T.
			Endif
		Next njy		
	Endif

	// ele È um procedimento e preciso ver se ele ta dentro do pacote
	If Ascan( aItGeralPac ,cCodPro) > 0
		lNegProPac := .T.
	EndIf
Next nj

// Verificar o codigo digitado, situaÁ„o em que o aCols n„o possui linha em branco 
If !lCodDigitadoCheck .And. !lNegProPac
	aItensPac := PlRetPac(PLSINTPAD(), If(TYPE("M->"+cAliasCab+"_CODRDA") == "C", &("M->"+cAliasCab+"_CODRDA"), padr('',TamSx3('BAU_CODIGO')[1])), ;
	                      cCodPad, cCodPro , nil, dDatPro)

	If Len(aItensPac) > 0
		For njx := 1  To Len(aItensPac)
			lFoundItem := IIF(Len(aItensPac[njx]) >= 11, aItensPac[njx][11], .F.) 

			If !lFoundItem
				Aadd(aItGeralPac, aItensPac[njx][2])
			EndIf
		Next njx

		If !lFoundItem
			For njy := 1 To Len(oBrwPro:aCols)
				If Ascan(aItGeralPac, oBrwPro:FieldGet(cAliasIte+"_CODPRO", njy)) > 0
					lNegProPac:= .T.
				Endif
			Next njy
		EndIf	
	EndIf
EndIf

If Type("M->"+cAliasCab+"_CID") == "C"
	cCid := &("M->"+cAliasCab+"_CID")
ElseIf Type("M->"+cAliasCab+"_CIDPRI") == "C" .And. cAliasCab == "B4A" // Guias de Anexo Clinico
	cCid := &("M->"+cAliasCab+"_CIDPRI")
EndIF

If !(cAliasIte == "BQV" .And. cAliasCab == "BE1") // Complemento SADT n„o possui Guia Empresa, ent„o gera a Critica 022 se houver.
	cGuiaEmp := IIF(Type("M->"+cAliasCab+"_NRAEMP") == "C",&("M->"+cAliasCab+"_NRAEMP"),"")
EndIf

//plsautp																		
aRetFun := PLSAUTP(	dDatPro,;
cHorPro,;
cCodPad,;
cCodPro,;
nQtdPro,;
aDadUsr,;
0,;
aDadRDA,;
"1",;
lTratRda,;
cCid,;
.T.,;
"1",;
(cTipoProc=="S"),;//lTrarSolic
cOpeSol,;
cCodSol,;
&("M->"+cAliasCab+"_ANOPAG"),;
&("M->"+cAliasCab+"_MESPAG"),;
cPadInt,;
cPadCon,;
cRegAte,;
.T.,;
cCodExe,;//23
cProRel,;
nPrPrRl,;
If(Type("M->"+cAliasCab+"_OPEEXE") == "C",&("M->"+cAliasCab+"_OPEEXE"),nil),;
aValAcuAut,;
cAteRNA,;
If(Type("M->"+cAliasCab+"_NRAOPE") == "C",&("M->"+cAliasCab+"_NRAOPE"),nil),;
cGuiaEmp,;
cSequen,;
nil,;
iIf(cAliasIte == 'B4C',.f.,nil),;//33
"1",;
cFaces,;
.f.,;
NIL,;
cTipPreGui,;
cGrpInt,;
nil,;
cRDAEDI,;
cChavLib,;
BI3->BI3_ABRANG,;
nil,;
nil,;
nil,;
nil,;
nil,;
Iif(lTratExLib, lTratExLib, (cTipoProc == "E" .or. ! Empty(cCodExe))),;//49
iIf(cAliasIte == 'B4C',.f.,.t.),;
cTipoProc,;
iif(! empty(cCodEsp),cCodEsp,nil),; //52
aQtdBrow,;
iIf(cTipoProc == "S" .And. !lChkLib,{.F.,.F.,nil,nil,nil,nil,nil,nil,nil,nil,nil},nil),; //se for solicitaÁ„o, n„o trata periodicidade e quantidade.
iIf( type("M->"+cAliasCab+"_CODLOC") == "C", &( "M->" + cAliasCab + "_CODLOC") ,nil),;
nil,;
nil,;
nil,;
.f.,;
cAliasCab,;
cRegInt,;
cTipAte,;
lNegProPac,;
nil,;
cFinAte,;
cGrauPa,;
nil,;
cGuiJur,;
nil,;
cEspSol,;
cEspExe,;
/*dDatCab*/,;
lCriDatSup,;
iif(cAliasIte=='BEJ','03',cTipGui),;
/*cStProc*/,;
aCritCab,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
nil,;
Alltrim(cTipAdmissao),,,aDadProrro)
//aret																	
aRet := aClone(aRetFun)

//significa que houve critica no cabecalho           
If Len(aCriCab) >= 1 .and. Len(aCriCab[1]) > 0 
	If Len(_aCopHCri)
		For nCab:=1 to Len(_aCopHCri[1])
			If !Empty(_aCopHCri[1,nCab,1]) .And. Len(_aCopHCri[1,nCab])>10 .And. Len(_aCopHCri[1,nCab,11])>0 .And. _aCopHCri[1,nCab,11] =="1"  //verifico se no _aCopHCri h· critica forÁada de cabeÁalho 
				lLimCab := .T.                                    
				If !aRet[1]					
					For nRet:=1 To Len(aRet[2])				                                
						If _aCopHCri[1,nCab,1] ==  aRet[2,nRet,1] // retiro do aret[2] o codglo que pertence a critica de cabeÁalho forÁado e ajusto o array					
							nTam := Len(aRet[2])
							aDel(aRet[2],nRet)    
							aSize(aRet[2],nTam-1)   

							For nRet2:=1 To Len(aRet[2]) //o codigo retirado acima tem complementos, cujo a primeira posiÁ„o est· em branco.. neste ponto retiro os que est„o em branco
								If Len(aRet[2]) >= nRet2 .And. Empty(aRet[2,nRet2,1])  					
									nTam := Len(aRet[2])
									aDel(aRet[2],nRet2)    
									aSize(aRet[2],nTam-1)   
								Else
									Exit  //quando n„o encontrar mais registros em branco, significa que ja deletou todas posiÁıes que È referente a determinada critica, ent„o saio 
								EndIf     //do for para encontrar a prÛxima posiÁ„o preenchida		
							Next nRet2
							Exit    
						EndIf	
					Next nRet
				EndIf
			EndIf       
		Next nCab     
	EndIf
	// a critica de cabeÁalho foi forÁada... n„o deve aparecer mais na tela e nem negar a guia.		
	If !lLimCab 
		//se autorizou eu vou 'desautorizar' pq houve critica no cabecalho
		If aRet[1] 

			aRet := {.F.,aCriCab[1],'CAB',cCodPad+cCodPro}

			PLLimpCCri(.F.,.T.,aCriCab[1])

			//se nao autorizou eu vou adicionar as criticas do cabecalho
		Else          

			For nI := 1 to Len(aCriCab[1])
				aadd(aRet[2],aCriCab[1][nI])
			Next

		Endif
	Else 
		If Len(aRet[2]) = 0
			lVerCob:= .T.
			lForcou:= .T.
		EndIF
	EndIf		
Endif

If aRet[1] = .F. .And. GetNewPar("MV_PLATURG",.F.) == .T. .And. BDR->BDR_CARINT == "U" .And. dDataBase - BA1->BA1_DATINC > 0 .And.;
	 (Iif(Len(aRet) > 1, Ascan(aRet[2],{|x| x[1] == "09V"}) == 0, .F.) .Or. Iif(Len(aRet) > 1, Ascan(aRet[2],{|x| x[1] == "010"}) > 0 , .F.))  //Procura a crÌtia 09V e 010 porque se o benefici·rio estiver internado, n„o tem porque intern·-lo de novo na urgÍncia.
	aRet[1] := .T.
	aRet[2] := 1
	aRet[3] := "URG"
Endif

//Se for um usuario da operadora padrao em intercambio enviar p auditoria..≥

If Type("M->"+cAliasCab+"_CODRDA") == 'C'

	BAU->(DbSetOrder(1))
	BAU->(MsSeek(xFilial("BAU") + &("M->"+cAliasCab+"_CODRDA"))) // Posiciono na BAU novamente pra garantir que nenhum funcao ira desposicionar

	If GetNewPar("MV_PLSMSAA","1") == "1" .And. lUnimeds .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE") .And. ! lForcou
		If ! lAuditoria
			aRet[1] := .F.
			If ValType(aRet[2]) == "C"
				aRet[2] := {}
				aadd(aRet[2],{__aCdCri025[1],__aCdCri025[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})		
			ElseIf ValType(aRet[2]) == "A"
				If Ascan(aRet[2],{|x| x[1] == __aCdCri025[1] }) == 0 .And. Ascan(aRet[2],{|x| x[1] == __aCdCri025[2] }) == 0
					aadd(aRet[2],{__aCdCri025[1],__aCdCri025[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})	
				EndIf
			EndIf
			PLSA090MSG()
		Endif
	Endif

Endif

//Se for um usuario da operadora padrao em intercambio enviar p auditoria..≥
If GetNewPar("MV_PLSMSAA","1") == "1" .And. !lUnimeds .And. lUsrInt
	If ! lAuditoria
		aRet[1] := .F.
		If ValType(aRet[2]) == "C"
			aRet[2] := {}
			aadd(aRet[2],{__aCdCri025[1],__aCdCri025[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})		
		ElseIf ValType(aRet[2]) == "A"
			If Ascan(aRet[2],{|x| x[1] == __aCdCri025[1] }) == 0 .And. Ascan(aRet[2],{|x| x[1] == __aCdCri025[2] }) == 0
				aadd(aRet[2],{__aCdCri025[1],__aCdCri025[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})	
			EndIf
		EndIf
		PLSA090MSG()
	Endif
Endif


lRet := aRet[1]

//Alimenta o array de pacote												 	
If PLSALIASEXI("B43")
	PlAliPac(cCodPad,cCodPro,cTipPreGui,dDatPro,cAliasCab,aDadB43,aCabB43,aTrbB43,cSequen)
Endif

//Pega as criticas
If ! lRet

	aHisCri 		:= aClone( aRet[2] )
	lAuditoria	:= Ascan( aHisCri,{|x| x[1] == cCodGloAud } ) > 0

	//Verifico se a critica deve colocar o procedimento em auditoria
	If !lAuditoria .And. Len(aHisCri) > 0 .And. lBCTAudito
		BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO	
		For nFor := 1 to Len(aHisCri)
			If !Empty(aHisCri[nFor,1]) .And. BCT->( MsSeek( xFilial("BCT")+PlsIntPad()+aHisCri[nFor,1] ) )
				lAuditoria := Iif(BCT->BCT_AUDITO == "1",.T.,.F.)
				If lAuditoria
					Exit
				EndIf	
			EndIf
		Next

	EndIf

	//≥ Verifica se procedimento em auditoria se enquandra na exceÁ„o cadastrada ≥
	//≥ Caso esteja na exceÁ„o retira o procedimento da auditoria. ≥
	if lAuditoria

		//InternaÁ„o ou Resumo de InternaÁ„o
		if cTipGui == "03" .or. cTipGui == "05"

			cTpaten := PLSRetAut("3")[1]

			//Anexos
		elseif cTipGui == "07" .or. cTipGui == "08" .or. cTipGui == "09"

			cTpaten := PLSRetAut("7")[1]

		else

			cTpaten := PLSRetAut()[1]

		endif     

		if PLSVLDEX(cCodPro+cTpaten,aDadUsr[26],nQtdPro)
			lAuditoria 	:= .F.
			aRet[1] 	:= .T.
			aRet[2] 	:= {}
			aRet[3] 	:= "B1O"
			aHisCri 	:= {}
		endif

	endif

	PLSALERTA(@aHisCri,@aRet,@aAlerta)

endIf

//Retirando as possivel criticas da sequencia corrente caso houver, isso ocorre quando h· mudanÁa de procedimento,
//onde o primeiro tem critica e o segundo n„o																	

If Len(oBrwCri:aCols) > 0

	nFor	:= Len(oBrwCri:aCols)
	nPos  	:= oBrwCri:FieldPos(cAliasCri+"_SEQUEN")
	nPos2 	:= oBrwCri:FieldPos(cAliasCri+"_CODGLO")
	nPos3 	:= oBrwCri:FieldPos(cAliasCri+"_DESGLO")
	aBkCritc:= {}

	While .T.

		If oBrwCri:aCols[nFor,nPos] == cSequen

			If Alltrim(oBrwCri:aCols[nFor,nPos3])<>""

				ADel(oBrwCri:aCols,nFor)
				ASize(oBrwCri:aCols,Len(oBrwCri:aCols)-1)

				If Len(oBrwCri:aCols) > 0
					oBrwCri:SetPos(Len(oBrwCri:aCols))
				Endif

			Endif

		Else
			Exit
		Endif

		nFor--

		If nFor = 0
			Exit
		Endif

	Enddo

	If Len(oBrwCri:aCols)= 0
		oBrwCri:AddBlank()
		oBrwCri:SetPos(Len(oBrwCri:aCols))
	Endif

	If Len(aBkCritc)> 0
		oBrwCri:aCols := aClone(aBkCritc)
	Endif

Endif

//Caso nao seja autorizada analiso o campo que trata se e permitido forcar
If  lPerFor .And. ! lRet .And. BR8->( MsSeek(xFilial("BR8") + cCodPad + cCodPro ) )

	//1o Regra. somente se todos as criticas podem forcar e que entra na regra de forcar
	If BR8->BR8_PERFOR <> "0"

		BCT->( DbSetOrder(1) )
		For nFor := 1 To Len(aRet[2])

			If aRet[2][nFor][1] <> cCodGloAud .OR. (aRet[2][nFor][1] == cCodGloAud .AND. GetNewPar("MV_PLAUFOR","0")=="1")

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
		lFlag := .f.
	Endif

	//Se existe pelo menos uma critica que pode forcar entra nessa regra de forcar≥
	If lFlag .AND. LEN(aHisCri) > 0 .Or. lVerCob     //Verifico o aHisCri, pois podemos ter casos de alertas e n„o crÌticas - quando alerta, PLSALERTA limpa a crÌticas, pois È apenas informativo.

		If !lVerCob
			lForcou := PLSMOVCRI("1",{cCodPad,cCodPro,BR8->BR8_DESCRI,cSequen},aHisCri,.T.)
		EndIf

		If lForcou

			aRet[1]	:= .T.
			lRet	 	:= .T.

			If aDadUsr[1] .And. Len(aDadUsr) >= 38  .And. !(FunName() $ "PLSA09A/PLSA09P")

				//pega o aCodCri
				aOldCodCri  := PLLimpCCri(.F.)

				//precisa disso pq antes a funcao nao retornava nada, e se o cliente receber o 090 sem o XAUT vai sar erro
				If aOldCodCri == nil
					aOldCodCri  := {}
				Endif

				//limpa o a codCri
				PLLimpCCri(.T.)

				//rodo para pegar o nivel de cobertura, vou precisar para calcular a co participacao
				aAuxRetPro  := PLSAUTPDIR(aDadUsr[37],aDadUsr[38],cCodPad,cCodPro,aDadUsr,dDatPro,cHorPro,nil,nil,.F.,nil,nQtdPro,nil,nil,nil,;
				If(Type("M->"+cAliasCab+"_NRAOPE") == "C",&("M->"+cAliasCab+"_NRAOPE"),NIL),;
				If(Type("M->"+cAliasCab+"_NRAEMP") == "C",&("M->"+cAliasCab+"_NRAEMP"),NIL),;
				aDadUsr[11],aDadUsr[12],.T.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
				{.F.,.F.,.F.,.F.,.T.,.T.,.T.,.F.,.F.,.F.,.F.})
				//limpa o a codCri
				PLLimpCCri(.F.,.T.,aOldCodCri)

				If aAuxRetPro[1] .and. Len(aAuxRetPro) >= 4 .and. Len(aRet) >= 4
					aRet[3] := aAuxRetPro[3]
					aRet[4] := aAuxRetPro[4]

					//Quinto passo. Verifico se neste caso ele deveria pagar no ato sim/nao...       						
					If aRet[1] .Or. ( Valtype(aRet[2]) == "A" .And. Len(aRet[2]) > 0 .And. aRet[2][1][1] $ "025")

						PLSTratPgA(cCodEsp,adadrda[14],adadrda[2],;
						cCodPad,cCodPro,cCodExe,adadrda[12],cSequen,&("M->"+cAliasCab+"_MESPAG"),&("M->"+cAliasCab+"_ANOPAG"),;
						nil,dDatPro,nQtdPro,cGrpInt,aDadUsr,cPadInt,cRegAte,.t.,cHorPro,NIL,cProRel,nPrPrRl,NIL,;
						@aRet,If(Type("M->"+cAliasCab+"_CID") == "C",&("M->"+cAliasCab+"_CID"),nil),;
						cPadCon,nil,.t.,.t.,nil,nil,nil,nil,nil,nil,nil,cTipgui,.t.)
					EndIf


				Endif
			Endif

			lAuditoria := .F.

			If Len(aAutFor) > 0 .And. Len(aAutFor[1]) >= 14
				nPos := Ascan(aAutFor,{|x| x[14]+x[2]+x[3] == cSequen+cCodPad+cCodPro})
			Else
				nPos := Ascan(aAutFor,{|x| x[2]+x[3] == cCodPad+cCodPro})
			EndIf

			If nPos == 0

				cCodMot := RetCodMot(cCodPad,cCodPro,aHisCri)[1]
				cObsMot := RetCodMot(cCodPad,cCodPro,aHisCri)[2]

				If FunName() $ "PLSA09A/PLSA09P" .And. Type("aCodCriHis") <> "U"
					aCodCriHis := aClone(_aCopHCri)
					AaDd(aAutForAnx,{.T.,cCodPad,cCodPro,"","","","",0,BCS->(RetCodUsr()),Date(),Time(),cCodMot,cObsMot,cSequen})
				Else
					AaDd(aAutFor,{.T.,cCodPad,cCodPro,"","","","",0,BCS->(RetCodUsr()),Date(),Time(),cCodMot,cObsMot,cSequen})
				Endif

			Endif

			//Caso tenha forcado o procedimento registro no campo.
			If Alltrim(__cTipo)  == "1"
				M->BE2_NIVAUT := "FOR"
			EndIf

		Else 
			If !lForcou .And. Len(aHisCri)>0 .And. !lVerCob .And. !lLimCab .And. Len(aCriCab)>0 .And. Len(aCriCab[1])>0 

				For nAd:=1 to Len(aCriCab[1])         	
					AADD(aHisCri,aCriCab[1,nAd]) 
				Next nAd	

			EndIf
			//Alimento as criticas...                                                 
			PLSA090ACR(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
		EndIf

	EndIf

EndIf

//Novo tratamento para analisar caso nao tenha cobertura se pode ser      
//enviado para liberacao especial ou nao...                               
If ! aRet[1] .And. BCT->(FieldPos("BCT_LIBESP")) > 0

	BCT->(DbSetOrder(1))
	If ValType(aRet[2]) == "A" .And. Len(aRet[2]) > 0

		For nI := 1 to Len(aRet[2])

			If !Empty(aRet[2,nI,1]) .and. BCT->(MsSeek(xFilial("BCT")+PLSINTPAD()+aRet[2,nI,1]))
				lLibEsp := BCT->BCT_LIBESP $ "1, "
			Endif

			If lLibEsp
				If BR8->BR8_LIBESP $ "0, "
					lLibEsp := .F.
				Endif
			Endif

			If lLibEsp
				Exit
			Endif

		Next

	Endif

Endif

//Por algum motivo o n esta mudando o valor quando e feito alteracao	    
n := oBrwPro:Linha()

//a partir do retorno monta dados da autorizacao...                       
If cTipo == "1"

	&("M->"+cAliasIte+"_STATUS") := If(aRet[1],"1","0")
	&("M->"+cAliasIte+"_NIVAUT") := If(aRet[1],aRet[3],Space(03))

	If BE2->(FieldPos("BE2_CHVNIV")) > 0
		&("M->"+cAliasIte+"_CHVNIV") := If(Len(aRet) >= 4 .And. ValType(aRet[4]) == "C",aRet[4],Space(60))
	Endif

	If !( Alltrim(cCodPro) $ __cCodMedGen )	.and.  ! ( alltrim(cCodPro) $ __cCodMatGen )	
		&("M->"+cAliasIte+"_DESPRO") := BR8->BR8_DESCRI
	endIf

	&("M->"+cAliasIte+"_NIVCRI") := If( ! aRet[1], aRet[3], space(03))
	&("M->"+cAliasIte+"_NIVEL")  := BR8->BR8_NIVEL

	If lLibEsp
		&("M->"+cAliasIte+"_LIBESP")  := If(lLibEsp,"1","0")
	endIf

	//Trata situacao de prioridade da rede de atendimento...                  

	If GetNewPar("MV_PLSMODA","1") == "0"
		Pergunte("PLS090",.F.)
		cCodLocPar := mv_par01
		PLSA090ATP(cAliasIte,cAliasCab,oEncAut,cCodLocPar)
	Endif

Else

	If Empty(cChavLib)
		oBrwPro:FieldPut(cAliasIte+"_NIVAUT",If(aRet[1],aRet[3],Space(03)),n)
		If BE2->(FieldPos("BE2_CHVNIV")) > 0
			oBrwPro:FieldPut(cAliasIte+"_CHVNIV",If(Len(aRet)>=4  .And. ValType(aRet[4]) == "C",aRet[4],Space(60)),n)
		Endif
	EndIf

	oBrwPro:FieldPut(cAliasIte+"_CODPAD",cCodPad,n)
	oBrwPro:FieldPut(cAliasIte+"_CODPRO",cCodPro,n)
	oBrwPro:FieldPut(cAliasIte+"_QTDPRO",nQtdPro,n)
	oBrwPro:FieldPut(cAliasIte+"_SALDO",nQtdPro,n)
	oBrwPro:FieldPut(cAliasIte+"_QTDSOL",nQtdPro,n)
	oBrwPro:FieldPut(cAliasIte+"_STATUS",If(aRet[1],"1","0"),n)
	oBrwPro:FieldPut(cAliasIte+"_IMGSTA",If(aRet[1],"ENABLE","DISABLE"),n)
	oBrwPro:FieldPut(cAliasIte+"_NIVAUT",If(aRet[1],aRet[3],Space(03)),n)

	If lLibEsp
		oBrwPro:FieldPut(cAliasIte+"_LIBESP",If(lLibEsp,"1","0"),n)
	Endif

	If BE2->(FieldPos("BE2_CHVNIV")) > 0
		oBrwPro:FieldPut(cAliasIte+"_CHVNIV",If(Len(aRet)>=4  .And. ValType(aRet[4]) == "C",aRet[4],Space(60)),n)
	Endif
	oBrwPro:FieldPut(cAliasIte+"_DESPRO",BR8->BR8_DESCRI,n)
	oBrwPro:FieldPut(cAliasIte+"_NIVEL",BR8->BR8_NIVEL,n)
	oBrwPro:FieldPut(cAliasIte+"_NIVCRI",If(!aRet[1],aRet[3],Space(03)),n)

Endif

//foi autorizado, verificar guia paga no ATO...                           
If Len(aRet) >= 5 .And. ValType(aRet[5]) == "L" .And. aRet[5]

	aValor := aRet[6]

	If aValor[1] .And. aValor[16] == "1" .And. If(Len(aValor)>=27,!aValor[27],.T.)

		If BA3->BA3_TIPOUS == "1"
			aCliente := PlBuscaClien("1","1",aDadUsr)
		Else
			aCliente := PlBuscaClien("2","1",aDadUsr)
		Endif

		If ! aCliente[1]

			Help("",1,"PLSA090NCC")

			If cTipo == "1"
				&("M->"+cAliasIte+"_STATUS") := "0"
			Else
				oBrwPro:FieldPut(cAliasIte+"_STATUS","0",n)
			Endif

		ElseIf aValor[12] == 0 .And. BR8->BR8_PODDIG <> "1"

			Help("",1,"PLSA090NC1")

			If cTipo == "1"
				&("M->"+cAliasIte+"_STATUS") := "0"
			Else
				oBrwPro:FieldPut(cAliasIte+"_STATUS","0",n)
			Endif

		Else

			If lChkPag

				lAto:= .T.

				&("M->"+cAliasCab+"_PAGATO") := "1" //Paga no Ato sim/nao
				&("M->"+cAliasCab+"_GUIACO") := "1" //Guia comprada sim/nao
				&("M->"+cAliasCab+"_QUACOB") := "1" //1-No Ato;2-Fatura

				If cTipo == "1"
					&("M->"+cAliasIte+"_VLCOMP") := Iif(aRet[1],aValor[12],0)//Casos de auditoria nao grava valor
				Else
					oBrwPro:FieldPut(cAliasIte+"_VLCOMP",aValor[12],n)
				Endif

				&("M->"+cAliasCab+"_CODCLI") := aCliente[3]
				&("M->"+cAliasCab+"_LOJA")   := aCliente[4]

				lRefresh      := .T.

				If Len(aValor) >= 17
					nPosAcu := Ascan(aValAcuAut,{|x| x[1]+x[2] == cCodPad+cCodPro})

					If nPosAcu == 0
						aadd(aValAcuAut,{cCodPad,cCodPro,aValor[17],dDatPro,cHorPro,aValor})
					Else
						aValAcuAut[nPosAcu,3] := aValor[17]
					Endif
				endIf

			Else

				//Aqui a guia deve ser paga no ato, mais como foi chamada de autorizacao de internacao nao devo exibir...

				Aviso( STR0117, ; 			//"Compra de Procedimentos"
				STR0118,; 			//"Este procedimento possui cobertura porem devera ser efetuado o pagamento do procedimento na proxima fatura"
				{ STR0146 }, 2 )
			Endif

		Endif

	Endif

ElseIf &( cAliasIte+"->( FieldPos('"+cAliasIte+"_VLCOMP') )" ) > 0

	If cTipo == "1"
		lAto := &("M->"+cAliasIte+"_VLCOMP")>0
		If !lAto
			&("M->"+cAliasIte+"_VLCOMP") := 0
		EndIf
	Else
		lAto := oBrwPro:FieldGet(cAliasIte+"_VLCOMP")>0
		oBrwPro:FieldPut(cAliasIte+"_VLCOMP",0,n)
	Endif

Endif

If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_VLCOMP') )" ) > 0 .and. Type("M->"+cAliasIte+"_VLCOMP") <> "N"
	&("M->"+cAliasIte+"_VLCOMP") := 0
Endif

//Habilita campo para informar valores de compras de mat/med.             

If cAliasIte == "BE2"

	If cTipo == "1"
		&("M->"+cAliasIte+"_PEREVC") := IF(BR8->BR8_PODDIG$" ,1","1","0")
	Else
		oBrwPro:FieldPut(cAliasIte+"_PEREVC",IF(BR8->BR8_PODDIG$" ,1","1","0"),n)
	Endif

Endif

//Se existir critica exibe dialogo...                                     
If ( ! lRet .And. ! lPerFor .and. Len(aHisCri) > 0 ) .Or. ( ! lRet .And. ! lFLag .and. Len(aHisCri) > 0 )

	BR8->( DbSetOrder(1) )
	If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
		//Monta aHisCri...                                                        
		PLSMOVCRI("1",{cCodPad,cCodPro,BR8->BR8_DESCRI,cSequen},aHisCri)

		If lPLSEXPC .and. ( cAliasIte = 'BE2' .or. cAliasIte =  'BEJ' ) .and. len(aRdaPt)>0
			for nI:= 1 to len(aRdaPt)
				PLSA090ACR(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
				cSequen := STRZERO(val(cSequen)+ 1, 3 )
			next nI
	
			aCriPacote := aClone(oBrwCri:aCols)
		Else
		//Alimento as criticas...                                                 
		PLSA090ACR(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
		EndIf
		
	ElseIf !Empty(cCodPad) .And. !Empty(cCodPro)
		Help("",1,"REGNOIS")
   		return .F.
	Endif
Endif

//Exibe os alertas do procedimento
If Len(aAlerta) > 0  

	If MsgYesNo(STR0584) //"Existem alertas para o procedimento selecionado, deseja visualizar?"

		PLSMOVCRI("4",{cCodPad,cCodPro,BR8->BR8_DESCRI,cSequen},aAlerta,.F.)

	EndIf

EndIf 

n := oBrwPro:Linha()

//Se tipo == 1 m 2 browse													

If cTipo == "1"
	&("M->"+cAliasIte+"_AUDITO") := If(lAuditoria,"1","0")
Else
	oBrwPro:FieldPut(cAliasIte+"_AUDITO",If(lAuditoria,"1","0"),n)
Endif

//Se for guia paga no ato exibir mensagem...                              
//Somente mostrar que tem que pagar no ato se realmente ele tem direito	
If lAto  .And. ((aRet[1] .And. cMVPLSRDAG != aDadRDA[2]) .Or. (Valtype(aRet[2]) == "A" .And. aRet[2][1][1] $ "025")) .And. Empty(cChavLib)

	PLSPOSGLO(PLSINTPAD(),__aCdCri056[1],__aCdCri056[2],"1")
	Aviso( STR0119, PLSBCTDESC(), { STR0146 }, 2 ) 	 //"Pagamento no Ato"

Endif

If Valtype(aRet[2]) == "A"

	If Len(aRet[2]) > 0

		If aRet[2][1][1] $ "025"
			lConPagAto := .T.
		Else
			lConPagAto := .F.
		Endif

	Endif

Else
	lConPagAto := .F.
EndIf

If lAto
	AtuVlComp(.T.,cTipo,lConPagAto)
Endif

If FindFunction("PLSRETNCRI")

	If ( ! lRet .And. ! lPerFor ) .Or. ( ! lRet .And. ! lFLag ) .or. ! lRet

		If cTipo == "1" .And. Type("M->"+cAliasIte+"_DNIVCR") == "C" .And. Type("M->"+cAliasIte+"_NIVAUT") == "C" .And. Type("M->"+cAliasIte+"_CHVNIV") == "C" .And. Type("M->"+cAliasIte+"_NIVCRI") == "C"

			&("M->"+cAliasIte+"_DNIVAU") := ''
			&("M->"+cAliasIte+"_DNIVCR") := PLSRETNCRI(&("M->"+cAliasIte+"_NIVAUT"), &("M->"+cAliasIte+"_CHVNIV"),&("M->"+cAliasIte+"_NIVCRI"))

		ElseIf cTipo == "2" .And. oBrwPro:FieldPos(cAliasIte+"_NIVAUT") > 0  .And. oBrwPro:FieldPos(cAliasIte+"_NIVCRI") > 0 .And. oBrwPro:FieldPos(cAliasIte+"_CHVNIV") > 0 .And. oBrwPro:FieldPos(cAliasIte+"_DNIVAU") > 0

			oBrwPro:FieldPut(cAliasIte+"_DNIVAU",'',n)
			oBrwPro:FieldPut(cAliasIte+"_DNIVCR",PLSRETNCRI(oBrwPro:FieldGet(cAliasIte+"_NIVAUT"),oBrwPro:FieldGet(cAliasIte+"_CHVNIV"),oBrwPro:FieldGet(cAliasIte+"_NIVCRI")),n)

		Endif

	Else

		If cTipo == "1" .And. Type("M->"+cAliasIte+"_DNIVAU") == "C" .And. Type("M->"+cAliasIte+"_NIVAUT") == "C" .And. Type("M->"+cAliasIte+"_CHVNIV") == "C" .And. Type("M->"+cAliasIte+"_NIVCRI") == "C"

			&("M->"+cAliasIte+"_DNIVCR") := ''
			&("M->"+cAliasIte+"_DNIVAU") := PLSRETNCRI(&("M->"+cAliasIte+"_NIVAUT"), &("M->"+cAliasIte+"_CHVNIV"),&("M->"+cAliasIte+"_NIVCRI"))

		ElseIf cTipo == "2" .And. oBrwPro:FieldPos(cAliasIte+"_NIVAUT") > 0 .And. oBrwPro:FieldPos(cAliasIte+"_NIVCRI") > 0 .And. oBrwPro:FieldPos(cAliasIte+"_CHVNIV") > 0 .And. oBrwPro:FieldPos(cAliasIte+"_DNIVCR") > 0

			oBrwPro:FieldPut(cAliasIte+"_DNIVCR",'',n)
			oBrwPro:FieldPut(cAliasIte+"_DNIVAU",PLSRETNCRI(oBrwPro:FieldGet(cAliasIte+"_NIVAUT"),oBrwPro:FieldGet(cAliasIte+"_CHVNIV"),oBrwPro:FieldGet(cAliasIte+"_NIVCRI")),n)

		Endif

	Endif

Endif

//Se for atualizacao de browse forca atualizacao de objeto                

If cTipo == "2"
	oBrwCri:ForceRefresh(oBrwCri)
	oBrwPro:ForceRefresh(oBrwPro)
EndIf

CursorArrow()

//Checa menssagem informatica de guia da empresa...                       

If BA3->BA3_TIPOUS == "2" .And. BT6->(FieldPos("BT6_RETGUI")) > 0 .And. BT6->BT6_RETGUI == "1"
	cRetGui    := "1"
	cSomInt    := BT6->BT6_SOMINT

	If cSomInt <> "1"
		Aviso( STR0120, STR0121 , { STR0146 }, 2 ) 	 //"Atencao"###"Anexar autorizacao da empresa."
	ElseIf cSomInt == "1" .And. cAliasCab == "BE4"
		Aviso( STR0120, STR0121 , { STR0146 }, 2 ) 	 //"Atencao"###"Anexar autorizacao da empresa."
		Endif

	EndIf

Return(.t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMOVCRI


@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSMOVCRI(cTipo,aDados,aHisCri,lForcar,cTitAdic,lAudito)
	LOCAL nI		  := 0
	LOCAL oDlg		  := NIL
	LOCAL aCri       := {}
	LOCAL nOpca      := 0                          
	LOCAL lForSBx4   := PLFSENBX()
	LOCAL bOKPad     := {|| nOpca := 1,oDlg:End() }
	LOCAL bOKFor     := {|| Iif(!Empty(cSenhaAc) .And. !PLSGETSPRO(cSenhaAC) .And. lForSBx4,;
	MsgStop(STR0122),; //"Senha invalida"
Iif(!VldMot(cCodMot,aHisCri) .And. (!Empty(cSenhaAc).Or. !lForSBx4),;
MsgStop(STR0472),;//"Informe o motivo!"
Iif(Empty(cSenhaAc) .And. lForSBx4,;
(nOpca := 0, oDlg:End()),;
(nOpca := 1, oDlg:End());
);
);
);
}
LOCAL bCancel    	:= {|| nOpca := 0,oDlg:End() }
LOCAL oCritica   	:= NIL
LOCAL cCodPad		:= ""
LOCAL cCodPro		:= ""
LOCAL cDesPro		:= ""
LOCAL cSequen		:= ""
LOCAL cTitulo		:= ""
LOCAL cCodGlo		:= ""
LOCAL oSay         := NIL
LOCAL cSenhaAc   	:= Space(25)
LOCAL oCheck 		:= NIL
LOCAL lCheck	 	:= .F.
LOCAL cCodMot	 	:= Space(3)
LOCAL cObs    	 	:= Space(250)
LOCAL nFor,nFor2,nFor3 := 0
LOCAL lChvSX5	 	:= .F.
LOCAL nLinhaRef		:=0
local lConfirma		:=.T.
LOCAL bBlockPto		:= {|| .t.}
Local nCop        := 0
DEFAULT lForcar  	:= .F.
DEFAULT cTitAdic 	:= ""
DEFAULT lAudito  	:= .F.

//Ajusta criticas para evitarscricao repetida

For nI:=1 To Len(aHisCri)
	If !Empty(aHisCri[nI,1])
		cCodGlo := aHisCri[nI,1]
		Loop
	EndIf
	If !Empty(aHisCri[nI,2])
		If !(cCodGlo+ " - " $ aHisCri[nI,2])
			aHisCri[nI,2] := cCodGlo + " - " + aHisCri[nI,2]
		Endif
	EndIf
Next

//Monta dados para o caso de critica de movimentacao...                   

If     cTipo == "1"
	cCodPad := aDados[1]
	cCodPro := aDados[2]
	cDesPro := aDados[3]
	cSequen := aDados[4]

	cTitulo := STR0123+cCodPad+"-"+AllTrim(cCodPro)+" - "+AllTrim(cDesPro) //"Criticas Procedimento "
ElseIf cTipo == "2"
	cTitulo := STR0124 //"Criticas Usuario"
ElseIf cTipo == "3"
	cTitulo := STR0125 //"Criticas Rede de Atendimento"

ElseIf cTipo == "4" 
	cCodPad := aDados[1]
	cCodPro := aDados[2]
	cDesPro := aDados[3]
	cSequen := aDados[4]

	cTitulo := STR0585 + " - " + cCodPad + "-" + AllTrim(cCodPro) + " - " + AllTrim(cDesPro) //"Alertas do procedimento" 
Endif 

If ! Empty(cTitAdic)
	cTitulo += "- "+cTitAdic
Endif

If ExistBlock("PLS090MO")
	bBlockPto		:= {|| Execblock("PLS090MO",.F.,.F.,{oCritica,aHisCri,cCodPad,cCodPro,cSequen,cDesPro,cTipo,aDados,lForcar,cTitAdic,lAudito})}
Endif

//Ponto de entrada que determina se podemos efetuar tratamento especifico para forcar a critica. 
If ExistBlock( "PL090FOR" )
	lForcar := ExecBlock( "PL090FOR", .F., .F., {RetCodUsr(),aHisCri,aDados} )
EndIf

//Define dialogo...                                                       
If !isBlind() 
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 008.0,010.3 TO 039.4,110.3
	If Val(GetVersao(.F.)) >= 12
		oCritica := TcBrowse():New( 035, 005, 390, If(!lForcar.and.!lAudito,200,130),NIL,NIL,NIL,oDlg,NIL,NIL,NIL,NIL,bBlockPto,NIL,NIL,NIL,NIL,NIL,NIL, .F.,, .T.,, .F., )
	Else
		oCritica := TcBrowse():New( 015, 005, 390, If(!lForcar.and.!lAudito,200,130),NIL,NIL,NIL,oDlg,NIL,NIL,NIL,NIL,bBlockPto,NIL,NIL,NIL,NIL,NIL,NIL, .F.,, .T.,, .F., )
	Endif
Endif

oCritica:AddColumn(TcColumn():New(STR0126,{ || aHisCri[oCritica:nAt,1] },; //"Codigo"
"@C",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))
oCritica:AddColumn(TcColumn():New(STR0127,{ || OemToAnsi(aHisCri[oCritica:nAt,2]) },; //"Descricao"
"@C",nil,nil,nil,220,.F.,.F.,nil,nil,nil,.F.,nil))
oCritica:AddColumn(TcColumn():New(STR0128,{ || OemToAnsi(aHisCri[oCritica:nAt,3]) },; //"Info"
"@C",nil,nil,nil,400,.F.,.F.,nil,nil,nil,.F.,nil))

If Ascan(aHisCri,{ |x| x[1] == "025"})  > 0 .and. GetNewPar("MV_PLAUFOR","0")=="0"	
	lForcar:=.F.
Endif

lChvSX5 := SX5->(MsSeek(xFilial("SX5")+"BU"))

If lForcar

	If lForSBx4
		@ 158,005 SAY 	oSay PROMPT STR0129  	SIZE 330,010 			OF oDlg PIXEL 	COLOR CLR_RED //"O procedimento foi negado porem e possivel que seja forcada de acordo com o parametro existente na tabela padrao."
		@ 170,005 SAY 	oSay PROMPT STR0130  	SIZE 300,010   			OF oDlg PIXEL 	COLOR CLR_RED //"Para forcar digite na caixa de edicao abaixo sua senha de acesso ao sistema."
		@ 185,005 SAY 	oSay PROMPT STR0131  	SIZE 080,010 			OF oDlg PIXEL 	COLOR CLR_RED //"Digite aqui sua senha: "
		@ 185,065 MSGET 	cSenhaAc 		   	SIZE 035,006 			OF oDlg PIXEL 	PASSWORD	
	Else
		@ 170,005 SAY 	oSay PROMPT STR0642	    SIZE 300,010   			OF oDlg PIXEL 	COLOR CLR_RED    //Para Autorizar, clique em Salvar. Para N„o Autorizar, clique em Cancelar
	EndIf	  

	If lChvSX5
		If lForSBx4
			@ 185,115 SAY 	oSay PROMPT STR0473  	SIZE 080,010			OF oDlg PIXEL 	COLOR CLR_RED //"Motivo:"
			@ 185,135 MSGet 	cCodMot PICTURE "@!"	VALID Empty(cCodMot) .Or. ExistCpo("SX5","BU"+cCodMot) SIZE 010,010 F3 "BU" 	OF oDlg PIXEL
		Else
			@ 185,020 SAY 	oSay PROMPT STR0473      SIZE 080,010	    	OF oDlg PIXEL 	COLOR CLR_RED //"Motivo:"
			@ 185,040 MSGet 	cCodMot PICTURE "@!"	VALID Empty(cCodMot) .Or. ExistCpo("SX5","BU"+cCodMot) SIZE 010,010 F3 "BU" 	OF oDlg PIXEL 
		EndIf

		@ 205,005 SAY 	oSay PROMPT STR0474 	SIZE 080,010 			OF oDlg PIXEL 	COLOR CLR_RED //"ObservaÁ„o:"
		@ 205,040 MSGet 	cObs PICTURE "@!" 		SIZE 305,010 			OF oDlg PIXEL

	EndIf

	If lAudito
		@ 185,180 SAY oSay PROMPT STR0387  SIZE 200,010 			OF oDlg PIXEL 	COLOR CLR_RED //"Enviar procedimentos para auditoria:"
		@ 184,280 CHECKBOX oCheck VAR lCheck PROMPT "" 			OF oDlg SIZE 100,8
	EndIf
Else
	If lAudito
		@ 158,005 SAY oSay PROMPT STR0388  SIZE 330,010 			OF oDlg PIXEL  	COLOR CLR_RED //"O procedimento foi negado porem e possivel que seja forcada de acordo com o parametro existente na tabela padrao."
		@ 170,005 SAY oSay PROMPT STR0387  SIZE 200,010 			OF oDlg PIXEL 	COLOR CLR_RED //"Enviar procedimentos para auditoria:"
		@ 170,105 CHECKBOX oCheck VAR lCheck PROMPT "" 			OF oDlg SIZE 100,8
	EndIf
EndIf

oCritica:SetArray(aHisCri)

If cTipo == "4" 

	//Exibe apenas o bot„o fechar.
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,,bCancel,.F.,{},,,,,,.F.) } )
Else

	//Ativa dialogo....
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,If(!lForcar,bOKPad,bOKFor),bCancel,.F.) } )
EndIf 

lAudito := lCheck

//Adiciono o motivo e observacao, nas posicoes 9 e 10 do aHisCri.	 
If nOpca==K_OK .And. !lAudito
	For nFor := 1 To Len(aHisCri)
		If !Empty(aHisCri[nFor][1])
			// Realiza o tratamento do array
			If Len(aHisCri[nFor]) < 10
				For nFor2 := 1 To 10
					If Len(aHisCri[nFor]) < 10
						AaDd(aHisCri[nFor],"")
					Else
						Exit
					EndIf
				Next nFor2
			EndIf
			aHisCri[nFor][9]  := cCodMot
			aHisCri[nFor][10] := cObs
		Endif
	Next nFor

	If (lForcar .Or. lAudito) .And. nOpca == K_OK
		AADD(_aCopHCri,aclone(aHisCri))
		If cTipo =="2"
			For nCop:=1 to Len(_aCopHCri[1])
				If Len(_aCopHCri[1,nCop]) > 9 .And. !Empty(_aCopHCri[1,nCop,1])
					AADD(_aCopHCri[1,nCop],"1") // 1 - Procedimento forcado e autorizado
				EndIf
			Next nCop	
		EndIf
	EndIf

	If ValType(oBrwCri) == "O"
		aMatCBkp := aClone(oBrwCri:aCols)
	EndIf

Else
	If lConfirma // confirmou mas n„o informou a senha
		For nFor := 1 To Len(aHisCri)
			If !Empty(aHisCri[nFor][1])
				// Realiza o tratamento do array
				If Len(aHisCri[nFor]) < 10
					For nFor2 := 1 To 10
						If Len(aHisCri[nFor]) < 10
							AaDd(aHisCri[nFor],"")
						Else
							Exit
						EndIf
					Next nFor2
				EndIf
				aHisCri[nFor][9]  := cCodMot
				aHisCri[nFor][10] := cObs
			Endif
		Next nFor

		If (lForcar .Or. lAudito) .And. nOpca == K_OK
			AADD(_aCopHCri,aclone(aHisCri))
		EndIf
	Else
		If ValType(oBrwCri) == "O"
			aMatCBkp := aClone(oBrwCri:aCols)
		EndIf
		aHisCri:={}       // tramento para zeras as criticas
		Endif
	EndIf




Return(If(lForcar .Or. lAudito,(nOpca==K_OK),.F.))

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090COR
Muda a cor do browse de acordo com a autorizacao...

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090Cor(nLinha,aHeaderEd,aColsEd,lZraQtPro) 
	LOCAL nPos := PLRETPOS("BE2_IMGSTA",aHeaderEd,.F.)

DEFAULT lZraQtPro := .F. 

If nPos > 0
	aColsEd[nLinha,nPos] := If(M->BE2_STATUS=="1","ENABLE","DISABLE")
Endif

//Bkp do browse criticas													

aMatCBkp := aClone(oBrwCri:aCols)

//zera o quantidade autorizada, no caso de um procedimento negado,
//necess·rio para n„o impactar no saldo de uma liberaÁ„o.
If lZraQtPro 
	If M->BE2_STATUS == '0' .AND. M->BE2_AUDITO == '0' 

			M->BE2_QTDPRO := 0
			M->BE2_SALDO := 0
		Endif 
	EndIf 
Return

/*/{Protheus.doc} PLSA090MF
Espelha dados de uma autorizacao para um PEG/Guia

@author  PLS TEAM
@version P11
@since   20.01.03
/*/
Function PLSA090MF(cOpeAut,cAnoMov,cMesMov,aColsITE,aHeaderITE,nOpc,cMatUsa,cAnoPag,cMesPag,cTipGui,;
	lIntern,cNumGuia,lAutoriz,cSituac,cCodLDP,lReanaliza,lVeioComu,lExcluiAte,lNMudFase,;
	lReembolso,cAliasCab,oBrwB47,lIncNeg,cObsoleto,lSolicit,lMudarFase,cAliasPri,aMatCom,;
	cTpGrv,cLotGui,lResInt,lGuiHoRe,aPartic,lOdontoWeb,cArqImp,lRecGlo,lWeb,notUsed,lSUS,aArraySUS,aDadRda,lMfJob, cRdaExe, lJaCobLib)
	Local I__f 			:= 0
	Local _nInd			:= 0
	Local nForX         := 0
	LOCAL nFor          := 0
	LOCAL nTmp      	:= 0
	LOCAL nAux      	:= 0
	LOCAL nPosCodPro    := 0
	LOCAL nPos          := 0
	LOCAL nPos2         := 0
	LOCAL nPos3      	:= 0
	LOCAL nQtdTotEve   	:= 0
	LOCAL nVlrTotGui   	:= 0
	LOCAL nForCpo       := 0
	LOCAL nI		   	:= 0
	LOCAL nH1 		  	:= 0
	LOCAL nHP 		   	:= 0
	LOCAL cAliasIte		:= Subs(aHeaderITE[1,2],1,3)
	LOCAL nPosPP   		:= 0
	LOCAL aFiles        := {}
	LOCAL aChave		:= {}
	LOCAL aVetTrab 		:= {}
	LOCAL aHeader   	:= {}
	LOCAL aCols     	:= {}
	LOCAL aStruBEA  	:= If(!lReembolso,BEA->(DbStruct()),B44->(DbStruct()))
	LOCAL aColsAux		:= {}
	LOCAL aNiveis		:= {}
	LOCAL aPar			:= {}
	LOCAL aRetAux 		:= {.T.,{},ctod(""),"",""}
LOCAL aResult 		:= {}
LOCAL aCposPad 	   	:= {}
LOCAL aErrInt	   	:= {}
LOCAL aDelB43      	:= {}
LOCAL aHeadB47     	:= {}
LOCAL aColsB47     	:= {}
LOCAL aDadUsr      	:= PLSGETUSR()

LOCAL bBlock    	:= { || aFiles[nFor,7]=="1" }

LOCAL cCodProAux    := ""
LOCAL cCodPadAux	:= ""
LOCAL cAliasAux     := ""
LOCAL cCpoFase 		:= ""
LOCAL cCampos       := ""
LOCAL cFase     	:= ""
LOCAL cMatricUsr 	:= ""
LOCAL cCC           := ""
LOCAL cFunGRV		:= ""
LOCAL cTipGRV		:= ""
LOCAL cTipoGuia 	:= ""
LOCAL cGuiRel   	:= ""
LOCAL cDesLoc		:= ""
LOCAL cEndLoc		:= ""
LOCAL cCodEsp		:= ""
LOCAL cCodLoc		:= ""
LOCAL cDesEsp		:= ""
LOCAL cCodBlo		:= ""
LOCAL cDesBlo		:= ""
LOCAL cMacro		:= ""
LOCAL cFunIni		:= ""
LOCAL cTipIni		:= ""
LOCAL cChavGui	   	:= ""
LOCAL cSemGuia 	   	:= ""
LOCAL cCodPla      	:= If(Len(aDadUsr)>=11,aDadUsr[11],BA3->BA3_CODPLA)
LOCAL cCodRDA 		:= BCI->BCI_CODRDA
LOCAL cNomRDA 		:= BAU->BAU_NOME
LOCAL cChaveBCI     := ""
LOCAL lFlag         := .F.
LOCAL lGravarCM     := .F.
LOCAL lGravar      	:= .F.
LOCAL lOdonto	   	:= UPPER( Alltrim( FunName() ) ) $ "PLSA094C,PLSA094D" //falta tratar web, quando tiver
LOCAL aDatPag       := {}
LOCAL nIndUt		:=	0
LOCAL nPosFil		:= 0
local cChvGuiPE		:= ""
local aDad			:= {}
local lInternado	:= .f.
local lBusDig		:= .f.
local cChvBCIZ		:= ""
local cKeyB53		:= ""
Local cRdaBB0		:= ""
Local nPRegEx		:= 0
Local nPEstEx		:= 0
Local nPoCdPf		:= 0
Local nPSigEx		:= 0

DEFAULT cSituac    	:= "1"
DEFAULT cCodLDP    	:= iIf(PLSOBRPRDA(cCodRDA), PLSRETLDP(9), PLSRETLDP(5) )
DEFAULT cAliasCab  	:= "BEA"
DEFAULT cObsoleto	:= ""
DEFAULT lIntern    	:= .F.
DEFAULT lAutoriz   	:= .T.
DEFAULT lReanaliza 	:= .T.
DEFAULT lVeioComu  	:= .F.
DEFAULT lReembolso 	:= .F.
DEFAULT lSolicit   	:= .F.
DEFAULT lNMudFase  	:= .T.
DEFAULT lIncNeg	   	:= .F.
DEFAULT aMatCom		:= {}
DEFAULT oBrwB47	   	:= nil
DEFAULT cLotGui     := ""
DEFAULT cTpGrv      := "1"
DEFAULT lResInt		:= .F.
DEFAULT lGuiHoRe	:= .F.
DEFAULT aPartic     := {}
DEFAULT lOdontoWeb  := .F.
DEFAULT lWeb		:= .F.
DEFAULT cArqImp		:= ""
DEFAULT LRecGlo		:= .F.
DEFAULT notUsed		:= ''
DEFAULT lSUS		:= .F.
DEFAULT aArraySUS	:= {}
DEFAULT aDadRda     := {}
DEFAULT lMfJob      := .F.
DEFAULT cRdaExe		:= ""
DEFAULT lJaCobLib	:= .F.

If Len(aDadUsr) == 0
	If lReembolso
		aDadUsr := PLSDADUSR(B44->(B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG+B44_DIGITO),"1",.F.,dDataBase)
	Else
		aDadUsr := PLSDADUSR(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),"1",.F.,dDataBase)
	EndIf
EndIf

If !lMfJob .Or. Len(aDadRda) == 0
	aDadRda := PLSGETRDA()
EndIf

//Verifica se e uma Guia Ondonto liberado pela Web        				
If lOdontoWeb
	lOdonto := lOdontoWeb
EndIf

BCL->(DbSetOrder(1))
If !BCL->(MsSeek(xFilial("BCL")+cOpeAut+cTipGui))
	aadd(aErrInt,{"BCL",STR0247,cOpeAut+'.'+cTipGui})
ElseIf !FindFunction(BCL->BCL_FUNGRV)
	aadd(aErrInt,{"BCL",STR0248,BCL->BCL_FUNGRV })
Elseif !FindFunction(BCL->BCL_FUNINI)
	aadd(aErrInt,{"BCL",STR0249,BCL->BCL_FUNINI})
Elseif !FindFunction(BCL->BCL_FUNMFS)
	aadd(aErrInt,{"BCL",STR0250,BCL->BCL_FUNMFS})
Endif

If len(aErrInt) > 0
	PLSCRIGEN(aErrInt,{ {STR0252,"@C",20},{STR0253,"@C",160},{STR0254,"@C",100} },STR0255)
	Return({BCL->BCL_CODOPE,BCL->BCL_TIPGUI})
Endif

cDesLoc := ""
cEndLoc := ""
cCodEsp := ""
cCodLoc := ""
cDesEsp := ""
lFlag 	:= .F.
nPos  	:= 0
nPos2 	:= 0
nPos3 	:= 0

//Matriz de itens
For nTmp := 1 To Len(aColsITE)

	nPos3 := PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_STATUS",aHeaderITE,.F.)

	If nPos3 > 0

		If nOpc == K_Excluir
			lFlag := .T.
			Exit
		EndIf

		If lVeioComu .Or. lIncNeg
			lFlag := .T.
			Exit
		EndIf

		//Se foi autorizado	
		If  aColsITE[nTmp,nPos3] == "1" 
			lFlag := .T.
			Exit
		Else
			nPos  := PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_AUDITO",aHeaderITE,.F.)
			nPos2 := PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_LIBESP",aHeaderITE,.F.)

			If (nPos > 0 .And. aColsITE[nTmp,nPos] == "1") .Or. (nPos2 > 0 .And. aColsITE[nTmp,nPos2] == "1")
				lFlag := .T.
				Exit
			Endif
		Endif
	EndIf
Next

//Caso seja portal algumas variaveis ainda devem ser alimentadas, portanto o retorno nao pode ser efetuado nesse trecho.
If ! lFlag .and. ! lWeb
	Return({BCL->BCL_CODOPE,BCL->BCL_TIPGUI})
Endif

//Atualiza totais do peg
nQtdTotEve := len(aColsITE)

If lGuiHoRe .and. ! lResInt
	nPosPP := PLRETPOS(cAliasIte+"_VALOR",aHeaderITE,.F.)
Else
	nPosPP := PLRETPOS(cAliasIte+"_VLRAPR",aHeaderITE,.F.)
EndIf

If nPosPP > 0
	aEval(aColsITE,{|x| nVlrTotGui += x[nPosPP]})
EndIf

//Verifica se existe o PEG eletronico do mes para o credenciado...
BCL->( DbSetOrder(1) )
BCL->( MsSeek( xFilial("BCL") + cOpeAut + cTipGui ) )

cTipoGuia := BCL->BCL_TIPGUI
cGuiRel   := BCL->BCL_GUIREL
cFunGRV   := BCL->BCL_FUNGRV
cTipGRV   := BCL->BCL_TIPGRV
cFunIni   := BCL->BCL_FUNINI
cTipIni   := BCL->BCL_TIPINI

If BCL->( FieldPos("BCL_FASE") ) > 0

	cFase := BCL->BCL_FASE

	If Empty(cFase)
		cFase := "3"
	EndIf

Else
	cFase := "3"
EndIf

//ponto de entrada
If ExistBlock("PLS090LD")
	cCodLDP := ExecBlock( "PLS090LD",.F.,.F.,{lAutoriz,cCodLDP,cTipGui} )
EndIf

//Codigo da rda
cCodRDA := PADR( iif(lGuiHoRe,(cAliasCab)->&(cAliasCab+"_RDAEXE"),(cAliasCab)->&(cAliasCab+"_CODRDA")),6)

//tipo de operacao
If nOpc <> K_Excluir .And. nOpc <> K_Alterar

	//Se alias existe o agrupamento de guias nao considera competencia
	//se o local de digitacao for igual ao local definido como generico nao considera a rda.
	//este agrupamento considera somente ate o tipo de guia.
	if BXX->(FieldPos("BXX_CODPEG")) > 0 .and. PLSOBRPRDA(cCodRDA) .and. ! empty(cArqImp)

		nIndUt := PLSBUIND("BCI","BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_TIPGUI + BCI_CODRDA + BCI_ARQUIV") /// Busca da Ordem do indice

		BCI->(dbSetOrder(nIndUt)) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_TIPGUI + BCI_CODRDA + BCI_ARQUIV
		cChaveBCI := (cAliasCab)->&( cAliasCab+"_OPERDA" ) + cCodLDP + cTipGui + cCodRDA + cArqImp

		//Chave padrao
	else

		BCI->(dbSetOrder(4)) //BCI_FILIAL, BCI_OPERDA, BCI_CODRDA, BCI_ANO, BCI_MES, BCI_TIPO, BCI_FASE, BCI_SITUAC, BCI_TIPGUI, BCI_CODLDP
		cChaveBCI := (cAliasCab)->&( cAliasCab+"_OPERDA" ) + cCodRDA + cAnoMov + cMesMov + "2" + cFase + "1" + cTipGui + cCodLDP

		lBusDig	:= cFase <> "1"

		if lBusDig
			cChvBCIZ := (cAliasCab)->&( cAliasCab+"_OPERDA" ) + cCodRDA + cAnoMov + cMesMov + "2" + "1" + "1" + cTipGui + cCodLDP
		endIf

	endIf

	//Se encontrar a PEG, verifica se considerar Numero lote, ela nao pode estar faturada
	if ! BCI->( msSeek(xFilial("BCI") + upper(cChaveBCI) ) ) .and. ! BCI->( msSeek(xFilial("BCI") + lower(cChaveBCI) ) ) .and. iIf(lBusDig, ! BCI->( msSeek( xFilial("BCI") + cChvBCIZ ) ), .t.)

		//Cria peg
		PLSIPP((cAliasCab)->&(cAliasCab+"_OPEMOV"),cCodLDP,(cAliasCab)->&(cAliasCab+"_OPERDA"),cCodRDA,cMesMov,cAnoMov,dDataBase,cTipGui,cLotGui,aDatPag,cFase,cArqImp,nQtdTotEve,1,nVlrTotGui)

	elseIf lOdontoWeb

		PLSATUPP(nQtdTotEve,nVlrTotGui,,.f.,,,,((cAliasCab)->&(cAliasCab+"_OPEMOV")+ If(PLSOBRPRDA(),PLSRETLDP(9),GetNewPar("MV_PLSPEGE","0000"))+BCI->BCI_CODPEG+BCI->BCI_FASE+BCI->BCI_SITUAC))

	endIf

	//exclui
Else

	BCI->( DbSetOrder(1) ) //BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
	If ! BCI->( MsSeek(xFilial("BCI")+&(cAliasCab+"->"+cAliasCab+"_OPEMOV")+&(cAliasCab+"->"+cAliasCab+"_CODLDP")+&(cAliasCab+"->"+cAliasCab+"_CODPEG")) )
		Return( {BCL->BCL_CODOPE,BCL->BCL_TIPGUI} )
	EndIf

	if empty(cNumGuia)
		cNumGuia  := (cAliasCab)->&( cAliasCab + "_NUMGUI" )
	endIf

endIf

//Inicio do processo de gravacao das guias...                             
aFiles := PLSA500Fil(BCI->BCI_CODOPE,BCI->BCI_TIPGUI,"2")

//Monta os Objetivos...
cSemGuia := BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)

for nFor := 1 to len(aFiles)

	cAliasAux := aFiles[nFor,1]

	if nOpc == K_Incluir

		if empty(cAliasPri)

			cAliasPri := aFiles[nFor,1]

			if empty(cNumGuia) 
				cNumGuia  := PLSA500NUM(cAliasPri, BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
			endIf

		endIf

	else

		if empty(cNumGuia)
			cNumGuia  := (cAliasAux)->&( cAliasAux + "_NUMERO" )
		endIf

		if empty(cAliasPri)
			cAliasPri := aFiles[nFor,1]
		endIf

	endIf

	//Alimenta a vari·vel de chave da guia que ser· utilizada pelo ponto de entrada executado apÛs a gravaÁ„o do BD6.
	cChvGuiPE := BCI->BCI_CODOPE + BCI->BCI_CODLDP + BCI->BCI_CODPEG + cNumGuia

	cMatricUsr 	:= (cAliasCab)->&( cAliasCab + "_OPEUSR" ) + (cAliasCab)->&( cAliasCab + "_CODEMP") + (cAliasCab)->&( cAliasCab + "_MATRIC" ) + (cAliasCab)->&( cAliasCab + "_TIPREG" ) + (cAliasCab)->&( cAliasCab + "_DIGITO" )
	cCC 		:= PLSUSRCC(cMatricUsr)
	If !Empty(cRdaExe)
		cRdaBB0 := Posicione("BAU",1,xFilial("BAU")+cRdaExe, "BAU_CODBB0")
	EndIf

	If aFiles[nFor,3] == "2" .And. Eval(bBlock)

		//Monta RegToMemory...                                                    
		If nOpc == K_Incluir .Or. nOpc == K_Copiar

			lGravar := .T.

			Copy cAliasAux To Memory Blank

			For nAux := 1 To Len(aStruBEA)

				if type( cAliasAux + "->" + strTran(aStruBEA[nAux,1],cAliasCab,cAliasAux) ) <> "U"
					&("M->"+cAliasAux+Subs(aStruBEA[nAux,1],4,10)) := &(cAliasCab+"->"+aStruBEA[nAux,1])
				Endif

			Next

			If lSUS .and. cAliasAux == "BD5"
				&("M->"+cAliasAux+"_QTDEVE") := Len(aArraySUS) 
			EndIf

			&("M->"+cAliasAux+"_DESLOC") := aDadRDA[19]
			&("M->"+cAliasAux+"_ENDLOC") := aDadRDA[20]
			&("M->"+cAliasAux+"_CODESP") := aDadRDA[15]
			&("M->"+cAliasAux+"_DESESP") := aDadRDA[17]
			&("M->"+cAliasAux+"_LOCAL")  := aDadRDA[13]
			&("M->"+cAliasAux+"_CODLOC") := aDadRDA[18]
			&("M->"+cAliasAux+"_CPFRDA") := aDadRDA[16]

			&("M->"+cAliasAux+"_CODOPE") := BCI->BCI_CODOPE
			&("M->"+cAliasAux+"_CODLDP") := BCI->BCI_CODLDP
			&("M->"+cAliasAux+"_CODPEG") := BCI->BCI_CODPEG
			&("M->"+cAliasAux+"_NUMERO") := cNumGuia
			&("M->"+cAliasAux+"_ORIMOV") := BCL->BCL_CDORIT

			&("M->"+cAliasAux+"_TIPGUI") := BCI->BCI_TIPGUI
			&("M->"+cAliasAux+"_FASE")   := "1"
			&("M->"+cAliasAux+"_SITUAC") := cSituac
			&("M->"+cAliasAux+"_CC")     := cCC

			BB0->(DBSetOrder(1))
			If !Empty(cRdaBB0) .And. BB0->(DBSeek(xFilial("BB0")+cRdaBB0)) //Inputando os dados do Profissional executante.

				&("M->"+cAliasAux+"_REGEXE") := BB0->BB0_NUMCR
				&("M->"+cAliasAux+"_ESTEXE") := BB0->BB0_ESTADO
				
				If cAliasAux == "BD5"
					&("M->"+cAliasAux+"_OPEEXE") := PlsIntPad()
				EndIf

				&("M->"+cAliasAux+"_CDPFRE") := cRdaBB0
				&("M->"+cAliasAux+"_SIGEXE") := BB0->BB0_CODSIG
				&("M->"+cAliasAux+"_NOMEXE") := BB0->BB0_NOME

			EndIf 
			
			If &(cAliasAux+"->(FieldPos('"+cAliasAux+"_TIPATO'))") > 0 .and. !lOdonto
				&("M->"+cAliasAux+"_TIPATO") := ""
			Endif

			If &(cAliasAux+"->(FieldPos('"+cAliasAux+"_TISVER'))") > 0 
				&("M->"+cAliasAux+"_TISVER") := PGetTISVer()
			Endif

			if cTipGui $ "02|13" .and. empty( BEA->BEA_NUMINT ) .and. cAliasAux == "BD5"

				aDad := PLSUSRINTE(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO), BEA->BEA_DATPRO, BEA->BEA_HORPRO, .t.)

				lInternado := iIf( len(aDad) > 0 .and. aDad[1],.t., .f.)

				M->&( cAliasAux + "_REGATE" ) := iIf(lInternado,'1','2')
				M->&( cAliasAux + "_PADINT" ) := iIf(lInternado, aDad[6], aDadUsr[17]) 
				M->&( cAliasAux + "_GUIINT" ) := iIf(lInternado, aDad[2] + aDad[3] + aDad[4] + aDad[5],"")
				M->&( cAliasAux + "_GUIPRI" ) := iIf(lInternado, aDad[7],"")

			endIf

			//Consulta
			If cTipGui == "01" 
				M->&( cAliasAux + "_REGATE" ) := '2'
			EndIf
			
			If cTipGui == "01" .And. (lVeioComu .Or. lIncNeg )
				
				If ( nPos := PLRETPOS( Subs(aHeaderITE[1,2],1,3)+"_STATUS",aHeaderITE,.F.) ) > 0  .And. aColsITE[nTmp,nPos] <> "1"

					//Critica usada no motivo de bloqueio de cobranca e pagamento para evento negado

					PLSPOSGLO(PLSINTPAD(),__aCdCri158[1],__aCdCri158[2])
					cCodBlo := __aCdCri158[1]
					cDesBlo := PLSBCTDESC()
				EndIf

			EndIf

			// Reembolso
			If cTipGui == "04" .And. &(cAliasCab+"->(FieldPos('"+cAliasCab+"_REEANE')) > 0")
				&("M->"+cAliasAux+"_REEANE") := &("M->"+cAliasCab+"_REEANE")
				&("M->"+cAliasAux+"_ENV507") := "0"
			Endif

			//Resumo ou Honorario
			If cTipGui == "05" .Or. cTipGUi == "06"
				&("M->"+cAliasAux+"_PADINT") := &("M->"+cAliasCab+"_TIPACO")
				&("M->"+cAliasAux+"_MESPAG") := &("M->"+cAliasCab+"_MESAUT")
				&("M->"+cAliasAux+"_ANOPAG") := &("M->"+cAliasCab+"_ANOAUT")
				&("M->"+cAliasAux+"_MESINT") := &("M->"+cAliasCab+"_MESAUT")
				&("M->"+cAliasAux+"_ANOINT") := &("M->"+cAliasCab+"_ANOAUT")
				&("M->"+cAliasAux+"_NUMINT") := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")
				&("M->"+cAliasAux+"_GUIORI") := &(cAliasCab+"->"+cAliasCab+"_GUIORI")

				&("M->"+cAliasAux+"_TIPUSR") := aDadUsr[43]
				&("M->"+cAliasAux+"_CONEMP") := aDadUsr[09]
				&("M->"+cAliasAux+"_VERCON") := aDadUsr[39]
				&("M->"+cAliasAux+"_SUBCON") := aDadUsr[41]
				&("M->"+cAliasAux+"_VERSUB") := aDadUsr[42]
				&("M->"+cAliasAux+"_DATNAS") := aDadUsr[26]
				&("M->"+cAliasAux+"_MATVID") := aDadUsr[05]
			EndIf

			//Resumo
			If cTipGui == "05"
				&("M->"+cAliasAux+"_NOMUSR") := &("M->"+cAliasCab+"_NOMUSR")
				&("M->"+cAliasAux+"_NOMRDA") := &("M->"+cAliasCab+"_NOMRDA")
				&("M->"+cAliasAux+"_DATPRO") := &("M->"+cAliasCab+"_DATINT")
				&("M->"+cAliasAux+"_HORPRO") := &("M->"+cAliasCab+"_HORINT")
				&("M->"+cAliasAux+"_CID")	  := &("M->"+cAliasCab+"_CODCID")
			EndIf

			//Honorario
			If cTipGUi == "06"
				&("M->"+cAliasAux+"_CODRDA") := cCodRda
				&("M->"+cAliasAux+"_NOMRDA") := &("M->"+cAliasCab+"_NRDAEX")
				&("M->"+cAliasAux+"_CODOPE") := &("M->"+cAliasCab+"_CODOPE")

				&("M->"+cAliasAux+"_NOMUSR") := &("M->"+cAliasCab+"_NOME")
				&("M->"+cAliasAux+"_GRAUPA") := &("M->"+cAliasCab+"_GRAPAR")
				&("M->"+cAliasAux+"_CID") 	 := &("M->"+cAliasCab+"_CID")
				&("M->"+cAliasAux+"_GUIINT") := &("M->"+cAliasCab+"_NUMINT") //gravo a guia de solicitacao
				&("M->"+cAliasAux+"_CDPFRE") := &("M->"+cAliasCab+"_CODEXE")
				&("M->"+cAliasAux+"_NOMEXE") := &("M->"+cAliasCab+"_NOMEXE")
				&("M->"+cAliasAux+"_SIGEXE") := &("M->"+cAliasCab+"_SICONS")
				&("M->"+cAliasAux+"_REGEXE") := &("M->"+cAliasCab+"_NUCONS")
				&("M->"+cAliasAux+"_ESTEXE") := &("M->"+cAliasCab+"_UFCONS")
				&("M->"+cAliasAux+"_ATERNA") := Iif (&("M->"+cAliasCab+"_ATENRN") == '1', '1', '0')

				If Empty(&("M->"+cAliasAux+"_ANOPAG"))
					&("M->"+cAliasAux+"_ANOPAG") := cAnoMov
				Endif

				If Empty(&("M->"+cAliasAux+"_MESPAG"))
					&("M->"+cAliasAux+"_MESPAG") := cMesMov
				Endif

			EndIf

		Else


			DbSelectArea(cAliasPri)
			DbSetOrder(1)

			MsSeek( xFilial(cAliasPri) + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cNumGuia )

			Copy cAliasAux To Memory

			lGravar := &(cAliasAux)->(Found())

		Endif

		//Executa funcao de inicializacao de dados...
		If nOpc <> K_Excluir .And. ! Empty(cFunINI)

			aPar := { cTipoGuia,cGuiRel,"2",nOpc ,aDadRda, lMfJob }

			If cTipINI == "1"
				cMacro := AllTrim(cFunINI)
				&(cMacro)(aPar,,,)
			Else
				ExecBlock(cFunINI,.F.,.F.,aPar)
			Endif

		Endif

		If lGravar
			PLUPTENC(cAliasAux,nOpc)
		Endif

	ElseIf Eval(bBlock)

		If !lReembolso .And. !lResInt .And. !lGuiHoRe

			cCampos := PLSA090Fld(Iif( &(cAliasCab+"->"+cAliasCab+"_TIPO") == "4","3",""))
			cCampos := StrTran(cCampos,"BE2",cAliasAux)

			If cAliasAux == "BD6"
				cCampos += ", BD6_MOTBPG, BD6_MOTBPF, BD6_DESBPG, BD6_DESBPF"
			EndIf

		ElseIf lResInt
			// Descontinuado
		ElseIf lGuiHoRe .And. !lResInt
			// Descontinuado
		Else
			cCampos := strTran(PLSA001Fld(),'B45_VALORI,','') 
			cCampos := strTran(cCampos,"B45",cAliasAux)
		Endif

		Store Header cAliasAux TO aHeader For ( ( SX3->X3_CAMPO $ cCampos ) .Or. ( cAliasAux+"_CDNV01" == SX3->X3_CAMPO ) .Or. ( cAliasAux+"_CDNV02" == SX3->X3_CAMPO ) .Or. ( cAliasAux+"_CDNV03" == SX3->X3_CAMPO ) .Or. ( cAliasAux+"_CDNV04" == SX3->X3_CAMPO ) .Or. ( cAliasAux+"_VLRAPR" == SX3->X3_CAMPO ) )

		If nOpc == K_Incluir .Or. nOpc == K_Copiar
			Store COLS Blank cAliasAux TO aCols FROM aHeader
		Else

			//Tem que zerar senao.......											  
			aVetTrab := {}
			DbSelectArea(cAliasAux)
			DbSetOrder(1)
			If MsSeek(xFilial(cAliasAux)+BCI->BCI_CODOPE+BCI->BCI_CODLDP+BCI->BCI_CODPEG+cNumGuia)

				STORE COLS cAliasAux TO aCols FROM aHeader VETTRAB aVetTrab While xFilial(cAliasAux)+BCI->BCI_CODOPE+BCI->BCI_CODLDP+BCI->BCI_CODPEG+cNumGuia == ;
				&(cAliasAux+"->("+cAliasAux+"_FILIAL+"+;
				cAliasAux+"_CODOPE+"+;
				cAliasAux+"_CODLDP+"+;
				cAliasAux+"_CODPEG+"+;
				cAliasAux+"_NUMERO)")

			Else
				STORE COLS BLANK cAliasAux TO aCols FROM aHeader
			Endif
		Endif

		aColsAux := aClone(aCols)

		For nTmp := 1 To Len(aColsITE)

			// Verifica se o registro esta deletado
			If ! aColsITE[nTmp,Len(aColsITE[nTmp])]  

				lGravarCM := .F.
				nPos3     := PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_STATUS",aHeaderITE,.F.)

				If nPos3 > 0

					//Envia registro negado para o contas medicas  ou Se foi autorizado
					If aColsITE[nTmp,nPos3] == "1"
						lGravarCM := .T.
					Else
						nPos  := PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_AUDITO",aHeaderITE,.F.)
						nPos2 := PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_LIBESP",aHeaderITE,.F.)

						lGravarCM := (nPos > 0 .And. aColsITE[nTmp,nPos] == "1") .Or. (nPos2 > 0 .And. aColsITE[nTmp,nPos2] == "1")
					EndIf

					cCodBlo := ""
					cDesBlo := ""
					If lVeioComu .Or. lIncNeg
						lGravarCM := .T.
						If ( nPos := PLRETPOS( Subs(aHeaderITE[1,2],1,3)+"_STATUS",aHeaderITE,.F.) ) > 0  .And. aColsITE[nTmp,nPos] <> "1"

							//Critica usada no motivo de bloqueio de cobranca e pagamento para evento negado
							PLSPOSGLO(PLSINTPAD(),__aCdCri158[1],__aCdCri158[2])
							cCodBlo := __aCdCri158[1]
							cDesBlo := PLSBCTDESC()
						EndIf
					EndIf

				Endif

				If lGravarCM

					If nTmp > Len(aCols)
						If !Empty(aCols[Len(aCols),PLRETPOS(cAliasAux+"_CODPRO",aHeader,.F.)])
							aadd(aCols,{})
						EndIf
						For _nInd :=  1 To Len(aHeader)+1
							aadd(aCols[Len(aCols)],_nInd)
							If _nInd <= Len(aHeader)
								aCols[Len(aCols),_nInd] := CriaVar(aHeader[_nInd,2],.T.)
							Else
								aCols[Len(aCols),_nInd] := .F.
							Endif
						Next
					Endif

					For nAux := 1 To Len(aHeaderITE)

						nPos := Ascan(aHeader,{|x| cAliasAux+Subs(aHeaderITE[nAux,2],4,10) == x[2] })

						If nPos >= 1
							aCols[Len(aCols),nPos] := aColsITE[nTmp,nAux]

							If AllTrim(aHeader[nPos,2]) = 'BD6_GUIACO' .and.  aColsITE[nTmp,PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_VLCOMP",aHeaderITE,.F.)] = 0
								aCols[Len(aCols),nPos] := '0'
							EndIf

							If AllTrim(aHeader[nPos,2]) = 'BD6_QUACOB' .and.  aColsITE[nTmp,PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_VLCOMP",aHeaderITE,.F.)] = 0
								aCols[Len(aCols),nPos] := ' '
							EndIf

						Endif
					Next

					//aqui eu forco a gravacao dos campos que eu quero na BD6
					nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_CODOPE"  })
					If  nPos > 0 .and. !Empty(cOpeAut)
						aCols[Len(aCols),nPos] := cOpeAut
					Endif

					nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_MOTBPG"  })
					If  nPos > 0 .and. !Empty(cCodBlo)
						aCols[Len(aCols),nPos] := cCodBlo
					Endif
					nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_MOTBPF"  })
					If  nPos > 0 .and. !Empty(cCodBlo)
						aCols[Len(aCols),nPos] := cCodBlo
					Endif

					nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_DESBPG"  })
					If nPos > 0 .and. !Empty(cDesBlo)
						aCols[Len(aCols),nPos] := cDesBlo
					Endif

					nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_DESBPF"  })
					If nPos > 0 .and. !Empty(cDesBlo)
						aCols[Len(aCols),nPos] := cDesBlo
					Endif

					nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_BLOPAG"  })
					If nPos > 0 .and. (!Empty(cCodBlo) .Or. lJaCobLib)
						aCols[Len(aCols),nPos] := '1'
					Endif

					nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_BLOCPA"  })
					If nPos > 0 .and. !Empty(cCodBlo)
						aCols[Len(aCols),nPos] := '1'
					Endif

					if lGuiHore .and. !lResInt
						nPos := Ascan(aHeader,{|x| alltrim(x[2]) $ cAliasAux+"_CODOPE"  })
						If  nPos > 0
							aCols[Len(aCols),nPos] := &("M->"+cAliasCab+"_CODOPE")
						Endif
					EndIf

					For nAux := 1 To Len(aHeaderITE)
						nPos := Ascan(aHeader,{|x| cAliasAux+Subs(aHeaderITE[nAux,2],4,10) == x[2] })
						If nPos >= 1
							aCols[Len(aCols),nPos] := aColsITE[nTmp,nAux]

							If AllTrim(aHeader[nPos,2]) = 'BD6_GUIACO' .and.  aColsITE[nTmp,PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_VLCOMP",aHeaderITE,.F.)] = 0
								aCols[Len(aCols),nPos] := '0'
							EndIf

							If AllTrim(aHeader[nPos,2]) = 'BD6_QUACOB' .and.  aColsITE[nTmp,PLRETPOS(Subs(aHeaderITE[1,2],1,3)+"_VLCOMP",aHeaderITE,.F.)] = 0
								aCols[Len(aCols),nPos] := ' '
							EndIf

							If AllTrim(aHeader[nPos,2]) = 'BD6_BLOPAG' .and. lJaCobLib
								aCols[Len(aCols),nPos] := '1'
							EndIf

						Endif
					Next
				Endif
			EndIf
		Next

		//atualizar codigos de niveis01,02,03 e 04 para facilitar acesso nas querys...
		For nTmp := 1 To Len(aCols)
			nPos       := PLRETPOS(cAliasAux+"_CODPAD",aHeader,.F.)
			nPosCodPro := PLRETPOS(cAliasAux+"_CODPRO",aHeader,.F.)
			If nPosCodPro > 0
				cCodProAux := aCols[nTmp,nPosCodPro]
				cCodPadAux := aCols[nTmp,nPos]
				aNiveis    := PLSESPNIV(cCodPadAux)

				For nForx := 1 To aNiveis[1]
					nPos := PLRETPOS(cAliasAux+"_CDNV0"+StrZero(nForx,1),aHeader,.F.)
					If nPos > 0
						aCols[nTmp,nPos] := Subs(cCodProAux,aNiveis[2,nForx,1],aNiveis[2,nForx,2])
					Endif
				Next
			Endif
		Next

		If Len(aChave) == 0
			aChave := {}
		EndIf

		aadd(aChave,{cAliasAux+"_CODOPE",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
		aadd(aChave,{cAliasAux+"_CODLDP",BCI->BCI_CODLDP})
		aadd(aChave,{cAliasAux+"_CODPEG",BCI->BCI_CODPEG})
		aadd(aChave,{cAliasAux+"_NUMERO",cNumGuia})
		aadd(aChave,{cAliasAux+"_ORIMOV",BCL->BCL_CDORIT})
		aadd(aChave,{cAliasAux+"_TPGRV","1"})
		aadd(aChave,{cAliasAux+"_CC",cCC})
		aadd(aChave,{cAliasAux+"_NOMUSR",BA1->BA1_NOMUSR})
		aadd(aChave,{cAliasAux+"_NOMRDA",BAU->BAU_NOME})
		aadd(aChave,{cAliasAux+"_DTDIGI",Date()})
		aadd(aChave,{cAliasAux+"_MATANT",BA1->BA1_MATANT})
		aadd(aChave,{cAliasAux+"_MATUSA",cMatUsa})
		aadd(aChave,{cAliasAux+"_ANOPAG",cAnoPag})
		aadd(aChave,{cAliasAux+"_MESPAG",cMesPag})
		aadd(aChave,{cAliasAux+"_TIPGUI",BCL->BCL_TIPGUI})
		aadd(aChave,{cAliasAux+"_FASE","1"})
		aadd(aChave,{cAliasAux+"_SITUAC",cSituac})

		If Len(aDadUsr) >= 43 
			aadd(aChave,{cAliasAux+"_TIPUSR",aDadUsr[43]})
			aadd(aChave,{cAliasAux+"_CONEMP",aDadUsr[09]})
			aadd(aChave,{cAliasAux+"_VERCON",aDadUsr[39]})
			aadd(aChave,{cAliasAux+"_SUBCON",aDadUsr[41]})
			aadd(aChave,{cAliasAux+"_VERSUB",aDadUsr[42]})
			aadd(aChave,{cAliasAux+"_DATNAS",aDadUsr[26]})
			aadd(aChave,{cAliasAux+"_MATVID",aDadUsr[05]})
		EndIf

		If cPaisLoc == "BRA"
			aadd(aChave,{cAliasAux+"_CODPLA",IIf(Empty(BA1->BA1_CODPLA),BA3->BA3_CODPLA,BA1->BA1_CODPLA)})
		Else
			aadd(aChave,{cAliasAux+"_CODPLA",IIf(Empty(cCodpla),BA1->BA1_CODPLA,cCodpla)})
		Endif
		

		aCposPad := Eval( { || DbSelectArea(cAliasAux), DbStruct() })

		For nForCpo := 1 To Len(aCposPad)
			
			cMacro := ""				

			If !lReembolso
				cMacro := ("BE2->BE2_"+Subs(aCposPad[nForCpo,1],5,10))
			Else
				if aCposPad[nForCpo,1] <> 'BD6_VALORI' .And. aCposPad[nForCpo,1] <> 'BD7_VALORI'
					cMacro := ("B45->B45_"+Subs(aCposPad[nForCpo,1],5,10))
				endIf	
			Endif

			if !Empty(cMacro) .and. type(cMacro) <> "U" .and. type(cAliasAux+"_"+Subs(aCposPad[nForCpo,1],5,10)) <> "U" .And. AsCan(aChave,{|x| x[1] == aCposPad[nForCpo,1]} ) == 0 .And. !cMacro $ 'BE2->BE2_GUIACO,BE2->BE2_QUACOB'
				aadd(aChave,{cAliasAux+"_"+Subs(aCposPad[nForCpo,1],5,10),&(cMacro)})
			endif

		Next
		// Aqui eu evito problemas de FILIAL
		nPosFil := Ascan(aChave,{|x| "_FILIAL" $ x[1] })

		If nPosFil > 0 .AND. cAliasAux $ aChave[nPosFil, 1]
			aChave[nPosFil, 2] := xFilial(cAliasAux)
		EndIf

		BB0->(DBSetOrder(1)) //Inputando os dados do Profissional Executante.
		If cAliasAux == "BD6" .And. !Empty(cRdaBB0) .And. BB0->(DBSeek(xFilial("BB0")+cRdaBB0))

			nPRegEx	:= aScan( aChave, { |x| x[1] ==  "BD6_REGEXE"} )
			nPEstEx	:= aScan( aChave, { |x| x[1] ==  "BD6_ESTEXE"} )
			nPoCdPf	:= aScan( aChave, { |x| x[1] ==  "BD6_CDPFRE"} )
			nPSigEx	:= aScan( aChave, { |x| x[1] ==  "BD6_SIGEXE"} )
			aChave[nPRegEx][2] := BB0->BB0_NUMCR
			aChave[nPEstEx][2] := BB0->BB0_ESTADO
			aChave[nPoCdPf][2] := cRdaBB0
			aChave[nPSigEx][2] := BB0->BB0_CODSIG
			aadd(aChave,{cAliasAux+"_NOMEXE",AllTrim(BB0->BB0_NOME)})

		ElseIf cAliasAux == "BD5" .And. !Empty(cRdaBB0)  .And. BB0->(DBSeek(xFilial("BB0")+cRdaBB0))

			nPRegEx	:= aScan( aChave, { |x| x[1] ==  "BD5_REGEXE"} )
			nPEstEx	:= aScan( aChave, { |x| x[1] ==  "BD5_ESTEXE"} )
			nPoCdPf	:= aScan( aChave, { |x| x[1] ==  "BD5_CDPFRE"} )
			nPSigEx	:= aScan( aChave, { |x| x[1] ==  "BD5_SIGEXE"} )
			aChave[nPRegEx][2] := BB0->BB0_NUMCR
			aChave[nPEstEx][2] := BB0->BB0_ESTADO
			aChave[nPoCdPf][2] := cRdaBB0
			aChave[nPSigEx][2] := BB0->BB0_CODSIG
			aadd(aChave,{cAliasAux+"_NOMEXE",AllTrim(BB0->BB0_NOME)})
		EndIf
	
		//Inclusao do parametro .T. para nao gravar registro em branco            
		PLUPTCOLS(cAliasAux,aCols,aHeader,aVetTrab,nOpc,aChave, .F.,lSUS,aArraySUS)
	Endif

Next

If valType(oBrwB47) <> 'U'
	aHeadB47 := aClone(oBrwB47:aHeader)
	aColsB47 := aClone(oBrwB47:aCols)
Endif

//Executa funcao de gravacao dos dados...                                 
If ! Empty(cFunGRV)

	aPar    := { IF(nOpc<>K_Excluir,K_Incluir,K_Excluir),;	//1
	&(cAliasCab+"->"+cAliasCab+"_OPEMOV"),;	//2
	BCI->BCI_CODLDP,;							//3
	BCI->BCI_CODPEG,;							//4
	cNumGuia,;									//5
	.T.,;										//6
	BCL->BCL_ALIAS,;							//7
	cTipoGuia,;									//8
	cGuiRel,;									//9
	BCL->BCL_CDORIT,;							//10
	aColsITE,;									//11
	aHeaderITE,;								//12
	{},;										//13
	{},;										//14
	aColsB47,;									//15
	aHeadB47,;									//16
	If(!Empty(cCodBlo).And.cTipGui == "01",cCodBlo,''),;//17 passo o cCodBlo somente para guias de consulta, demais guias tratadas acima
	If(!Empty(cDesBlo).And.cTipGui == "01",cDesBlo,''),;//18 passo o cDesBlo somente para guias de consulta, demais guias tratadas acima
	"",;										//19 daher - retirei a passagem de parametro daqui e fiz agora la encima pois quando tinha + de 1 evento ele bloqueaa todos
	aMatCom,;									//20
	aPartic}									//21

	If cTipGRV == "1"
		cMacro := AllTrim(cFunGRV)
		&(cMacro)(aPar,,,)
	Else
		ExecBlock(cFunGRV,.F.,.F.,{aPar})
	Endif

	//P.E. para que possa ser alterado o conte˙do que ser· gravado na BD6
	If ExistBlock("P090ABD6")
		Execblock("P090ABD6",.F.,.F.,{cAliasPri,cChvGuiPE})
	EndIf

	BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + 	BD7_NLANC
	BB0->(DBSetOrder(1))
	If !Empty(cRdaBB0) .And. BB0->(DBSeek(xFilial("BB0")+cRdaBB0)) .And. BD7->(DbSeek(xFilial("BD7")+aPar[2]+aPar[3]+aPar[4]+AllTrim(aPar[5])+aPar[10]))
		While !BD7->(Eof()) .And. (aPar[2]+aPar[3]+aPar[4]+AllTrim(aPar[5])+aPar[10] == BD7->( BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV)) //Grava o executante profissional a partir da BD5.
			BD7->( RecLock("BD7",.F.) )
				BD7->BD7_REGPRE := BB0->BB0_NUMCR
				BD7->BD7_ESTPRE := BB0->BB0_ESTADO
				BD7->BD7_NOMPRE := BB0->BB0_NOME
				BD7->BD7_CDPFPR := cRdaBB0
			BD7->( MsUnLock() )
			BD7->(DbSkip())
		EndDo
	EndIf
Endif


//Muda a fase da guia...                                                  
If ! Empty(BCL->BCL_FUNMFS) .And. (BCL->BCL_PERINC == "1" .Or. BCL->BCL_TIPGUI $ '04|05|06') .And. nOpc <> K_Excluir .And. !lNMudFase
	lMudarFase := .T.
Endif

//Grava ultimos dados na guia de autorizacao...                           
If lExcluiAte

	&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")

	If nOpc <> K_Excluir

		If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_OPEPEG')) > 0")
			&(cAliasCab+"->"+cAliasCab+"_OPEPEG") := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
		Endif

		If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_CODOPE')) > 0")
			&(cAliasCab+"->"+cAliasCab+"_CODOPE") := BCI->BCI_CODOPE
		EndIf

		&(cAliasCab+"->"+cAliasCab+"_CODLDP") := BCI->BCI_CODLDP

		If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_CODPEG')) > 0")
			&(cAliasCab+"->"+cAliasCab+"_CODPEG") := BCI->BCI_CODPEG
		EndIf

		&(cAliasCab+"->"+cAliasCab+"_NUMGUI") := cNumGuia
	Else
		&(cAliasCab+"->(DbDelete())")
	Endif
	&(cAliasCab+"->(MsUnlock())")

Endif

//No momento que faz a gravaÁ„o da B53 ainda n„o atualizou todos os campos da BEA e a B53 salva com os dados da BEA.
//GravaÁ„o dos campos faltantes da B53. 
B53->(dbSetOrder(1)) //B53_FILIAL + B53_NUMGUI + B53_ORIMOV 

If cAliasCab == "BEA" .Or. cAliasCab == "BE4"
	
	If cAliasCab == "BEA"
		cKeyB53 := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	ElseIf cAliasCab == "BE4"										
		cKeyB53 := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
	endIf
		
	If B53->(dbSeek(xFilial("B53")+ cKeyB53)) .And. (Empty(B53->B53_CODPEG).And. Empty(B53->B53_CODLDP) .And.Empty(B53->B53_NUMERO))

		B53->(RecLock("B53",.f.))
		B53->B53_CODPEG := &(cAliasCab+"->"+cAliasCab+"_CODPEG")
		B53->B53_CODLDP	:= &(cAliasCab+"->"+cAliasCab+"_CODLDP")
		B53->B53_NUMERO := Iif(cAliasCab == "BEA", &(cAliasCab+"->"+cAliasCab+"_NUMGUI"),&(cAliasCab+"->"+cAliasCab+"_NUMERO"))
		B53->(MsUnLock())	
	EndIf
EndIf

//Monta chave da guia
cChavGui := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")+&(cAliasCab+"->"+cAliasCab+"_ANOAUT")+&(cAliasCab+"->"+cAliasCab+"_MESAUT")+&(cAliasCab+"->"+cAliasCab+"_NUMAUT")

//Se nao for resumo nem honorario

If ! lResInt .And. ! lGuiHoRe

	BE2->(DbSetOrder(1))
	If BE2->(MsSeek(xFilial("BE2")+cChavGui))
		While ! BE2->(Eof()) .And. xFilial("BE2")+cChavGui == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)

			BE2->(RecLock("BE2",.F.))
			BE2->BE2_CODLDP := &(cAliasCab+"->"+cAliasCab+"_CODLDP")
			BE2->BE2_CODPEG := &(cAliasCab+"->"+cAliasCab+"_CODPEG")
			BE2->BE2_NUMERO := &(cAliasCab+"->"+cAliasCab+"_NUMGUI")
			BE2->(MsUnLock())

			BE2->(DbSkip())
		EndDo
	EndIf

	//Reembolso

	If lReembolso
		B45->(DbSetOrder(1))
		If B45->(MsSeek(xFilial("B45")+cChavGui))
			While ! B45->(Eof()) .And. xFilial("B45")+cChavGui == B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)

				B45->(RecLock("B45",.F.))
				B45->B45_CODLDP := &(cAliasCab+"->"+cAliasCab+"_CODLDP")
				B45->B45_CODPEG := &(cAliasCab+"->"+cAliasCab+"_CODPEG")
				B45->B45_NUMERO := &(cAliasCab+"->"+cAliasCab+"_NUMGUI")
				B45->B45_ORIMOV := &(cAliasCab+"->"+cAliasCab+"_ORIMOV")
				B45->(MsUnLock())

				B45->(DbSkip())
			Enddo
		Endif
		B47->(DbSetOrder(1))
		If B47->(MsSeek(xFilial("B47")+cChavGui))
			While ! B47->(Eof()) .And. xFilial("B47")+cChavGui == B47->(B47_FILIAL+B47_OPEMOV+B47_ANOAUT+B47_MESAUT+B47_NUMAUT)

				B47->(RecLock("B47",.F.))
				If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_CODOPE')) > 0")
					B47->B47_CODOPE := &(cAliasCab+"->"+cAliasCab+"_CODOPE")
				EndIf
				B47->B47_CODLDP := &(cAliasCab+"->"+cAliasCab+"_CODLDP")
				B47->B47_CODPEG := &(cAliasCab+"->"+cAliasCab+"_CODPEG")
				B47->B47_NUMERO := &(cAliasCab+"->"+cAliasCab+"_NUMGUI")
				B47->B47_ORIMOV := &(cAliasCab+"->"+cAliasCab+"_ORIMOV")
				B47->(MsUnLock())

				B47->(DbSkip())
			Enddo
		Endif
	Endif

	BYS->(DbSetOrder(1))
	If BYS->(MsSeek(xFilial("BYS")+cChavGui))
		While ! BYS->(Eof()) .And. xFilial("BYS")+cChavGui == BYS->(BYS_FILIAL+BYS_OPEMOV+BYS_ANOAUT+BYS_MESAUT+BYS_NUMAUT)

			BYT->(RecLock("BYT",.T.))
			BYT->BYT_FILIAL := xFilial("BYT")

			If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_CODOPE')) > 0")
				BYT->BYT_CODOPE := &(cAliasCab+"->"+cAliasCab+"_CODOPE")
			Elseif &(cAliasCab+"->(FieldPos('"+cAliasCab+"_OPEMOV')) > 0")
				BYT->BYT_CODOPE := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
			EndIf

			BYT->BYT_CODLDP := &(cAliasCab+"->"+cAliasCab+"_CODLDP")
			BYT->BYT_CODPEG := &(cAliasCab+"->"+cAliasCab+"_CODPEG")
			BYT->BYT_NUMERO := &(cAliasCab+"->"+cAliasCab+"_NUMGUI")
			BYT->BYT_SEQUEN := BYS->BYS_SEQUEN
			BYT->BYT_CODIGO := BYS->BYS_CODIGO
			BYT->BYT_DESCRI := BYS->BYS_DESCRI
			BYT->BYT_TIPO   := BYS->BYS_TIPO
			BYT->BYT_SEGMEN := BYS->BYS_SEGMEN
			BYT->BYT_DESSEG := BYS->BYS_DESSEG
			BYT->BYT_M_ARCO := BYS->BYS_M_ARCO
			BYT->BYT_DESARC := BYS->BYS_DESARC
			BYT->BYT_CODPAD := BYS->BYS_CODPAD
			BYT->BYT_CODPSA := BYS->BYS_CODPSA
			BYT->BYT_FACES  := BYS->BYS_FACES
			BYT->(MsUnLock())

			BYS->(dbSkip())
		EndDo
	EndIf

EndIf

//Grava os itens...                                                       

If PLSALIASEXI("B43")
	B43->(DbSetOrder(2))
	If B43->(MsSeek(xFilial("B43")+cChavGui))
		While ! B43->(Eof()) .And. xFilial("B43")+cChavGui == B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT)

			B43->(RecLock("B43",.F.))
			If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_CODOPE')) > 0")
				B43->B43_CODOPE := &(cAliasCab+"->"+cAliasCab+"_CODOPE")
			Else
				B43->B43_CODOPE := PlsIntPad()
			EndIf

			B43->B43_CODLDP := &(cAliasCab+"->"+cAliasCab+"_CODLDP")
			B43->B43_CODPEG := &(cAliasCab+"->"+cAliasCab+"_CODPEG")
			B43->B43_NUMERO := &(cAliasCab+"->"+cAliasCab+"_NUMGUI")
			B43->B43_ORIMOV := &(cAliasCab+"->"+cAliasCab+"_ORIMOV")
			B43->(MsUnLock())

			//Se eu nao encontrei o BE2 correspondente ao itens do pacote eu o deleto 

			BE2->(DbSetOrder(1))
			If !BE2->(MsSeek(xFilial("BE2")+B43->(B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT+B43_SEQUEN)))
				aadd(aDelB43,{B43->(Recno())})
			Endif

			B43->(DbSkip())
		Enddo
	Endif
Endif

For nI := 1 to Len(aDelB43)
	B43->(DbGoTo(aDelB43[nI][1]))
	B43->(RecLock("B43",.F.))
	B43->(DbDelete())
	B43->(MsUnLock())
Next

//Posiciona no tipo de guia...                                            

BCL->(DbSetOrder(1))
BCL->(MsSeek(xFilial("BCL") + cOpeAut + cTipoGuia ) )

Return({BCL->BCL_CODOPE,BCL->BCL_TIPGUI,cAliasPri,&(cAliasPri+"->(Recno())")})

/*/{Protheus.doc} PLSA090IMA
Executa a impressao de guias via menu

@author  PLS TEAM
@version P11
@since   04.06.03
/*/
Function PLSA090Ima()
	if objCENFUNLGP:isLGPDAt()
		if !objCENFUNLGP:getPermPessoais() .OR. !objCENFUNLGP:getPermSensiveis()
			objCENFUNLGP:msgNoPermissions()
			Return
		Else
		objCENFUNLGP:useLogUser()
		EndIF
	EndIF
	lImpGuiDir := .F.
	Eval(bImpGuia)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090CPM
Trata a regra de modelos de autorizacoes. O ou 1 MV_PLSMODA

@author  PLS TEAM
@version P11
@since   04.06.03
/*/
//-------------------------------------------------------------------
Function PLSA090CPM(cTipo)
	LOCAL lRet        := .T.
	LOCAL aDadUsr     := PLSGETUSR()
	LOCAL aDadRDA     := PLSGETRDA()
	DEFAULT cTipo := "1"

//Trata a nao existencia do aDadRDA... Matriz essencial para essa rotina...≥
If GetNewPar("MV_PLSMODA","1") == "0" .And. ( Empty(aDadUsr) .Or. If(cTipo=="2",Empty(oBrwPro:FieldGet("BE2_CODPRO",oBrwPro:Linha())),Empty(M->BE2_CODPRO)) )
	lRet := .F.
	Help("",1,"PLS090CPM1")
ElseIf GetNewPar("MV_PLSMODA","1") == "1" .And. ( Empty(aDadUsr).Or. Empty(aDadRDA) ) .And. __cTipo == "1" .And. !lInfRda
	lRet := .F.
	MsgStop(STR0134) //"Informe o usuario e a rda antes de digitar o procedimento."
	Endif

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSSUGMED
Visualiza todos os prestadores sugeridos por ordem de prior

@author  PLS TEAM
@version P11
@since   04.06.03
/*/
//-------------------------------------------------------------------
Function PLSSUGMED()
	LOCAL aDados  := {}
	LOCAL aRes
	LOCAL cCodPad := oBrwPro:FieldGet("BE2_CODPAD")
LOCAL cCodPro := oBrwPro:FieldGet("BE2_CODPRO")

If ! PLSA090CPM("2")
	Return
Endif

aDados := PLSListaPrd(cCodPad,cCodPro,cCodLocPar)

If Len(aDados) > 0
	aRes := PLSCRIGEN(aDados,{ {STR0135,"@C",040} , {STR0136,"@C",200 } , ; //"Codigo Prestador"###"Nome Rede de Atendimento"
	{STR0137,"@C",040 } }, STR0138) //"Prioridade"###"  Rede de Atendimento / Prioridade "

	If aRes[1]
		BAU->(DbSetOrder(1))
		BAU->(MsSeek(xFilial("BAU")+aDados[aRes[2],1]))
	Endif
Else
	Help("",1,"PLSSUGMED")
	Endif

Return(.T.)

/*/{Protheus.doc} PLSA090VMD
Valida prestador de acordo com parametro MV_PLSMODA

@author  PLS TEAM
@version P11
@since   04.06.03
/*/
Function PLSA090VMD()
	LOCAL lRet		:= .T.
	LOCAL aRet		:= {}
	LOCAL aHisCri   := {}
	LOCAL aDadUsr	:= PLSGETUSR()
	LOCAL aDadRDA	:= PLSGETRDA()
	LOCAL aRetAux   := {}
	LOCAL cAteRNA	:= M->BE1_ATERNA
	LOCAL cAliasIte := "BE2"
LOCAL nX 		:= 0
LOCAL cCodAud	:= ""
LOCAL nPosLoc	:= 0
LOCAL cRegAte   := iIf(len(aDadUsr) >= 92, aDadUsr[92], "")

//se nao tratar a RDA (lTratRDA dentro da xAut)
if getNewPar("MV_PLSMODA","1") == "0"

	aRetFun := PLSListaPrd(oBrwPro:FieldGet("BE2_CODPAD"),oBrwPro:FieldGet("BE2_CODPRO"),cCodLocPar)
	lRet 	:= Ascan(aRetFun,{|x| x[1] == M->BE1_CODRDA}) > 0

	If lRet

		//Roda autorizacao do procedimento...                                     
		aRet := PLSAUTP(	M->BE1_DATPRO,;
		M->BE1_HORPRO,;
		oBrwPro:FieldGet("BE2_CODPAD"),;
		oBrwPro:FieldGet("BE2_CODPRO"),;
		oBrwPro:FieldGet("BE2_QTDPRO"),;
		aDadUsr,;
		oBrwPro:aVetTrab[oBrwPro:Linha()],;
		aDadRDA,;
		"1",;
		.T.,;
		M->BE1_CID,;
		.F.,;
		"1",;
		(__cTipo =='2'),; //lTratSol
		M->BE1_OPESOL,;
		M->BE1_CDPFSO,;
		M->BE1_ANOPAG,;
		M->BE1_MESPAG,;
		nil,nil,nil,nil,;
		M->BE1_CDPFRE,;
		oBrwPro:FieldGet("BE2_PROREL"),;
		oBrwPro:FieldGet("BE2_PRPRRL"),;
		nil,nil,;
		cAteRNA,;
		M->BE1_NRAOPE,;
		M->BE1_NRAEMP,;
		oBrwPro:FieldGet("BE2_SEQUEN"),;
		nil,nil,;
		"1",;
		if(&(cAliasIte+"_FACES")->(FieldPos(cAliasIte+"_FACES")) > 0,&("M->"+cAliasIte+"_FACES"),""))

		lRet := aRet[1]

		//Se existir critica exibe dialogo...                                     
		If ! lRet

			//Monta aHisCri...                                                        
			aHisCri := aClone(aRet[2])

			PLSMOVCRI("1",{oBrwPro:FieldGet("BE2_CODPAD"),oBrwPro:FieldGet("BE2_CODPRO"),oBrwPro:FieldGet("BE2_DESPRO"),oBrwPro:FieldGet("BE2_SEQUEN")},aHisCri)

			If lRet

				M->BE1_TIPMAJ := ""

				If BAU->( Posicione("BAU",1,xFilial("BAU") + M->BE1_CODRDA,"BAU->BAU_TIPPRE") ) <> GetNewPar("MV_PLSTPIN","OPE") 
					M->BE1_TIPMAJ := IIF(BAU->BAU_TIPPE == "F","1",IIF(BAU->BAU_TIPPE=="J","2",""))
				endIf

			endIf

		endIf

	endIf

else

	if lRet .and. type("M->BE1_NUMLIB") <> 'U' .and. ! empty(M->BE1_NUMLIB)

		aBlockLib := {} //Variavel utilizada no X3_RELACAO do BE2_QTDPRO para que a quantidade zero, colocada propositalmente nao seja substituida por 1, que era o valor padrao

		//Roda autorizacao de todos os procedimentos para garantir as liberacoes	
		for nX := 1 To Len(oBrwPro:aCols)
			aadd(aBlockLib,.t.)
		next

	endIf

	if lRet

		M->BE1_TIPMAJ := ""

		if BAU->(Posicione("BAU",1,xFilial("BAU")+M->BE1_CODRDA,"BAU->BAU_TIPPRE")) <> GetNewPar("MV_PLSTPIN","OPE")

			M->BE1_TIPMAJ := IIF(BAU->BAU_TIPPE == "F","1",IIF(BAU->BAU_TIPPE=="J","2",""))

		endIf

	endIf

endIf	

if valType(oEncAut) == "O" .and. (nPosLoc := aScan(oEncAut:aGets, {| aVet | "_CODLOC" 	$ aVet})) > 0 .and. ValType(oEncAut:AENTRYCTRLS[nPosLoc]) <> 'U'
		oEncAut:AENTRYCTRLS[nPosLoc]:SetFocus()
	endIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090VRD
Valida prestador de acordo com parametro MV_PLSMODA

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090VRD()
	LOCAL cMVPLSRDAG := GetNewPar("MV_PLSRDAG","999999")

If __cTipo == "1" .And. M->BE1_CODRDA == cMVPLSRDAG //Se for autorizacao nao pode informar rda gen...
	Aviso( STR0139, ; //"Rede de Atendimento Invalida"
	STR0140,; //"A Rede de Atendimento informada nao e valida para lancamentos de guias de autorizacao."
	{ STR0146 }, 2 )	//"Ok"
	Return(.F.)
Endif

If __cTipo == "2" .And. cMVPLSRDAG == M->BE1_CODRDA .And. ! Empty(M->BE1_CODESP) .And. ! Empty(M->BE1_CODLOC)
	Return(.T.) //Nao precisa validar de novo...
Endif

If GetNewPar("MV_PLSCZRE","1") == "1"
	PlsZero("M->BE1_CODRDA")
	Endif

Return(PLSA090RDA(M->BE1_OPERDA,M->BE1_CODRDA,"1",M->BE1_DATPRO,M->BE1_USUARI,"","","BE1",,,,,,,,,,13)) 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090ACO
Valida a autorizacao de uma consulta...

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090ACO(cAlias,oEncA,oBrwC,oBrwP,cCodCon)
LOCAL nI        := 1
LOCAL cCodPad  	:= ""
LOCAL cCodPro  	:= ""
LOCAL nQtdCon  	:= 1
LOCAL lOK      	:= .T.
LOCAL cOpeOri   := ""
LOCAL aDadUsr 	:= PLSGETUSR()
LOCAL nOrdBA0   := BA0->(IndexOrd())
LOCAL nRecBA0   := BA0->(Recno())
PRIVATE aGets
PRIVATE aTela
Default cCodCon  := GetNewPar("MV_PLSCDCO","0110101012")

cCodPad  := Subs(cCodCon,1,2)
cCodPro  := Subs(cCodCon,3,16)

aGets := aClone(oEncA:aGets)
aTela := aClone(oEncA:aTela)
//essas privates foram colocadas porque a funcao RunTrigger(1) necessita delas

cCodPro := cCodPro+Space(16-Len(cCodPro))

If Empty(&("M->"+cAlias+"_USUARI"))
	MsgInfo(STR0141) //"Informe o Usuario"
	lOK := .F.
Endif

If Empty( &("M->"+cAlias+"_CODRDA") )
	MsgInfo(STR0142) //"Informe a Rede de Atendimento"
	lOK := .F.
Endif

If !Empty( &("M->"+cAlias+"_NUMLIB") )
	MsgInfo(STR0393)//"Executando uma LiberaÁ„o"
	lOK := .F.
Endif

If Type("M->"+cAlias+"_TIPCON") == "C" .And. Empty( &("M->"+cAlias+"_TIPCON") )
	MsgInfo(STR0364)//"Informe o Tipo de Consulta"
	lOK := .F.
Endif

//Valida a Via da Carteirinha para usuario de intercambio					
//Pega operadora															

If lOK .And. Len(aDadUsr) >= 45
	cOpeOri := aDadUsr[45]

	//Valida a Via da Carteirinha para usuario de intercambio					

	If BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1"

		BA0->(DbSetOrder(nOrdBA0))
		BA0->(DbGoTo(nRecBA0))

		If Type("M->"+cAlias+"_VIACAR") == "N"
			If !Empty(&("M->"+cAlias+"_MATANT") ) .And. &("M->"+cAlias+"_VIACAR") == 0
				Aviso( STR0115, ; //"Carteirinha"
				STR0496,;//"N„o foi informado a via do cart„o, ser· utilizada a via 00"
				{ STR0146 }, 2 )	//"ok"
			Endif
		EndIf
	EndIf

EndIf

If lOK

	If ValType(oBrwC) == "O"
		For nI := 1 To Len(oBrwC:aCols)
			If oBrwC:FieldGet("BEG_SEQUEN",nI) == oBrwP:FieldGet("BE2_SEQUEN")
				oBrwC:FieldPut("BEG_SEQUEN","",nI)
				oBrwC:FieldPut("BEG_CODGLO","",nI)
				oBrwC:FieldPut("BEG_DESGLO","",nI)
			EndIf
		Next
		oBrwC:Refresh()
	EndIf

	BR8->(DbSetOrder(1))
	BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
	If PLSA090Aut(oBrwP:FieldGet("BE2_SEQUEN",len(oBrwP:aCols)),cCodPad,cCodPro,nQtdCon,"2",;
	nil,cAlias,nil,oBrwP,oBrwC,&("M->"+cAlias+"_CDPFRE"),nil,nil,nil,nil,nil,;
	nil,nil,nil,aDadB43,aCabB43,aTrbB43,NIL,If(__cTipo=="2","S","E"),;
	nil,nil,.F.,nil,nil,nil,_aCopHCri)

		Posicione("SX3",2,"BE2_CODPRO","")
		M->BE2_AUDITO := oBrwP:FieldGet("BE2_AUDITO")
		M->BE2_NIVCRI := oBrwP:FieldGet("BE2_NIVCRI")
		M->BE2_STATUS := oBrwP:FieldGet("BE2_STATUS")
		M->BE2_QTDPRO := oBrwP:FieldGet("BE2_QTDPRO")
		M->BE2_QTDSOL := oBrwP:FieldGet("BE2_QTDPRO")
		If oBrwP:FieldPos("BE2_SALDO") > 0
			M->BE2_SALDO  := oBrwP:FieldGet("BE2_SALDO")
		Endif
		RunTrigger(1)
		SX7->(DbSetOrder(1))
		If SX7->(MsSeek("BE2_CODPRO"))
			While ! SX7->(Eof()) .And. SX7->X7_CAMPO == "BE2_CODPRO"
				If oBrwP:FieldPos(SX7->X7_CDOMIN) > 0 .And. TYPE("M->"+SX7->X7_CDOMIN) <> "U"
					oBrwP:FieldPut(SX7->X7_CDOMIN,&("M->"+SX7->X7_CDOMIN),n)
				Endif
				SX7->(DbSkip())
			Enddo
		Endif

		If ExistBlock("PLS090AC")
			ExecBlock("PLS090AC",.F.,.F.)
		Endif

		oBrwP:Refresh()

		//N„o permiti alterar os campos da guia									  

			PLS090RONL(.T.,oEncAut)
		Endif
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090RD4

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090RD4
	LOCAL lRet

	If GetNewPar("MV_PLSCZRE","1") == "1"
	PlsZero("M->BE4_CODRDA")
Endif

lRet := PLSA090RDA(M->BE4_OPERDA,M->BE4_CODRDA,"1",dDataBase,M->BE4_USUARI,"","","BE4",,,,,,,,,,13) 

//Checa Historico de (Des)bloqueio										
If  FindFunction("A360CHEBLO")
	lRet := A360CHEBLO(M->BE4_CODRDA,M->BE4_PRVINT)
Endif

If lRet .And. BE4->(FieldPos("BE4_TIPMAJ")) > 0
	DbSelectArea("BAU")
	If (Posicione("BAU",1,xFilial("BAU")+M->BE4_CODRDA,"BAU->BAU_TIPPRE") <> GetNewPar("MV_PLSTPIN","OPE"))
		M->BE4_TIPMAJ := IIF(BAU->BAU_TIPPE == "F","1",IIF(BAU->BAU_TIPPE=="J","2",""))
	Else
		M->BE4_TIPMAJ := ""
		Endif
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090ACR

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090ACR(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
	LOCAL nPos  	:= oBrwCri:FieldPos(cAliasCri+"_SEQUEN")
LOCAL nPos2 	:= oBrwCri:FieldPos(cAliasCri+"_CODGLO")
LOCAL nPos3 	:= oBrwCri:FieldPos(cAliasCri+"_DESGLO")
LOCAL nFor,nLin
LOCAL cCodGlo   := ""
LOCAL cDesGlo   := ""
LOCAL cCodMot 	:= ""
LOCAL cObsMot 	:= ""
LOCAL cPartci 	:= ""
LOCAL cUniMed 	:= ""
LOCAL aAux      := {}
LOCAL nLinPro 	:= oBrwPro:Linha()
LOCAL lEntrou   := .f.
DEFAULT aDadCri := {}
DEFAULT aCabCri := {}
DEFAULT aTrbCri := {}

If Len(oBrwCri:aCols) > 0
	nFor:=Len(oBrwCri:aCols)
	While .T.
		If oBrwCri:aCols[nFor,nPos] == cSequen
			If Alltrim(oBrwCri:aCols[nFor,nPos3])<>""
				ADel(oBrwCri:aCols,nFor)
				ASize(oBrwCri:aCols,Len(oBrwCri:aCols)-1)
			Endif
		Else
			Exit
		Endif
		nFor--
		If nFor = 0
			Exit
		Endif
	Enddo

	If Len(aBkCritc)> 0
		oBrwCri:aCols:=aClone(aBkCritc)
	Endif
Endif

For nFor := 1 To Len(aHisCri)
	cCodGlo := aHisCri[nFor,1]
	cDesGlo := aHisCri[nFor,2]
	cCodMot := Iif(Len(aHisCri[nFor]) >= 9, aHisCri[nFor,9],"")
	cObsMot := Iif(Len(aHisCri[nFor]) >= 10, aHisCri[nFor,10],"")
	cPartci := Iif(Len(aHisCri[nFor]) >= 11, aHisCri[nFor,11],"")
	cUniMed := Iif(Len(aHisCri[nFor]) >= 12, aHisCri[nFor,12],"")


	If  Funname()<>"PLSA092"
		nLin    := Ascan(oBrwCri:aCols,{|x| x[nPos]+x[nPos2] == cSequen+cCodGlo .Or. ( x[nPos] == cSequen .And. Empty(x[nPos2]) .And. Empty(x[nPos3]) ) })
	Else // item foi colocado para evitar os erros log na internaÁ„o pois temos clientes que tem varias criticas no procedimento assim encavalando o SEQCRI
		nLin    := 0
	Endif

	If nLin > 0
		While Len(oBrwCri:aCols) > nLin
			If ! Empty(oBrwCri:aCols[++nLin][2])
				nLin--
				Exit
			EndIf
			ADel(oBrwCri:aCols,nLin--)
			ASize(oBrwCri:aCols,Len(oBrwCri:aCols)-1)
		End
		ADel(oBrwCri:aCols,nLin)
		ASize(oBrwCri:aCols,Len(oBrwCri:aCols)-1)
	EndIf

	oBrwCri:AddBlank()
	oBrwCri:SetPos(Len(oBrwCri:aCols))
	lEntrou := .t.
	oBrwCri:FieldPut(cAliasCri+"_SEQUEN",cSequen)
	oBrwCri:FieldPut(cAliasCri+"_CODGLO",cCodGlo)
	oBrwCri:FieldPut(cAliasCri+"_DESGLO",cDesGlo)
	oBrwCri:FieldPut(cAliasCri+"_CODMOT",cCodMot)
	oBrwCri:FieldPut(cAliasCri+"_OBSMOT",cObsMot)
	oBrwCri:FieldPut(cAliasCri+"_PARTIC",cPartci)
	oBrwCri:FieldPut(cAliasCri+"_UNIMED",cUniMed)

	If &(cAliasCri)->( FieldPos(cAliasCri+"_SEQCRI") ) > 0
		If cAliasCri == "BEG"
			oBrwCri:FieldPut(cAliasCri+"_SEQCRI",P090SEQCRI(1))

		Elseif cAliasCri == "BEL"

			If  Funname()<>"PLSA092" // item foi colocado para evitar os erros log na internaÁ„o pois temos clientes que tem varias criticas no procedimento assim encavalando o SEQCRI
				oBrwCri:FieldPut(cAliasCri+"_SEQCRI",P092SEQCRI(2))
			Endif

		Endif
	Endif

	nFor ++
	While nFor <= Len(aHisCri) .And. Empty(aHisCri[nFor,1])
		oBrwCri:AddBlank()
		oBrwCri:SetPos(Len(oBrwCri:aCols))
		oBrwCri:FieldPut(cAliasCri+"_SEQUEN",cSequen)
		oBrwCri:FieldPut(cAliasCri+"_CODGLO","")
		oBrwCri:FieldPut(cAliasCri+"_DESGLO",aHisCri[nFor,2])
		oBrwCri:FieldPut(cAliasCri+"_INFGLO",aHisCri[nFor,3])

		If &(cAliasCri)->( FieldPos(cAliasCri+"_SEQCRI") ) > 0
			If cAliasCri == "BEG"
				oBrwCri:FieldPut(cAliasCri+"_SEQCRI",P090SEQCRI(1))

			Elseif cAliasCri == "BEL"

				// item foi colocado para evitar os erros log na internaÁ„o pois temos clientes que tem varias criticas no procedimento assim encavalando o SEQCRI
				If  Funname()<>"PLSA092"
					oBrwCri:FieldPut(cAliasCri+"_SEQCRI",P092SEQCRI(2)) // esse item foi excluido devido ja estar incrimentando o seqcrio e assim com essa linha colocava de 2 em 2
				Endif

			Endif
		Endif

		nFor ++
	Enddo
	nFor --
Next
If lEntrou
	oBrwCri:ForceRefresh(oBrwPro)
	oBrwCri:SetPos(1)//posiciono o registro no primeiro para aparecer na tela. nao eh necessario refresh
	Endif
Return

/*/{Protheus.doc} PLSA090CPR
Possibilita a compra de um procedimento negado baseado em regras do sistema.

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
Function PLSA090CPR(cAliasEnc,oEncA,oBrwC,cTipo,oBrwP)

	LOCAL oDlg		 := nil
	LOCAL cTitulo    := STR0117 //"Compra de Procedimentos"
LOCAL oBrowse	 := nil
LOCAL nOpca      := 0
LOCAL oSay		 := nil
LOCAL bOK        := { || nOpca := 1, oDlg:End() }
LOCAL bCancel    := { || nOpca := 0, oDlg:End() }
LOCAL aRetFun    := {}
LOCAL oFontTit	 := nil
LOCAL nPos		 := 0
LOCAL oComboResP := nil
LOCAL aComboResp := Eval( { || SX3->(DbSetOrder(2)), SX3->(MsSeek("BQC_RESCOM")), RetSx3Box(X3CBox(),,,1) } )
LOCAL cComboResp := ""
LOCAL oPagtoResP := nil
LOCAL aPagtoResp := Eval( { || SX3->(DbSetOrder(2)), SX3->(MsSeek("BQC_QUACOB")), RetSx3Box(X3CBox(),,,1) })
LOCAL cPagtoResp := ""
LOCAL aDadUsr    := PLSGETUSR()
LOCAL cRegAte    := iIf(len(aDadUsr) >= 92, aDadUsr[92], "")
LOCAL nFor		 := 0	
local nSize		 := 0
LOCAL cMV_PLSSELC:= AllTrim(GetNewPar("MV_PLSSELC","3"))
LOCAL cParam01   := AllTrim(GETMV("MV_PLSCDCO"))
LOCAL lPodeComp  := .F.
LOCAL aCdPrcNeg  := {}
LOCAL nQtdPro    := 0
LOCAL cGrpInt    := ""
LOCAL nVlrBPF    := 0
LOCAL nVlrPF     := 0
LOCAL nPercPF    := 0
LOCAL nVlrPFTot  := 0
LOCAL cNomCli    := ""
LOCAL cProRel 	 := ""
LOCAL cPrPrRl 	 := ""
LOCAL aCliente   := {}
LOCAL lWhen1     := .F.
LOCAL lWhen2     := .F.
LOCAL aDadRda    := PLSGETRDA()
LOCAL cOpcCob1	 := ''
LOCAL cOpcCob2	 := ''
LOCAL aAux		 := {}
LOCAL aRetMed	 := {}
LOCAL aRdas      := {}
LOCAL cTipPreFor := ""
LOCAL cTipoGuia	 := ''
LOCAL lAtuGui    := .T.
LOCAL aButtons   := { {"RELATORIO",{|| PLSA090ICP(aCdPrcNeg,cNomCli,cPagtoResp,;
aCdPrcNeg[Len(aCdPrcNeg),8],&("M->"+cAliasEnc+"_CODRDA"),;
,&("M->"+cAliasEnc+"_OPERDA"),;
Subs(&("M->"+cAliasEnc+"_CODLOC"),1,3),Subs(&("M->"+cAliasEnc+"_CODLOC"),4,3),;
&("M->"+cAliasEnc+"_USUARI"),&("M->"+cAliasEnc+"_NOMUSR"),;
&("M->"+cAliasEnc+"_CID"),&("M->"+cAliasEnc+"_ESTSOL"),;
&("M->"+cAliasEnc+"_REGSOL"),&("M->"+cAliasEnc+"_SIGLA"),;
&("M->"+cAliasEnc+"_NOMSOL"),"1") };
,STR0143,STR0144}} //"Imprimir Orcamento de Compra"###"Imprimir"
LOCAL aValAcu := {}
LOCAL cChvNiv := ""
LOCAL cNiv	  := ""
LOCAL cPadInt := ""
LOCAL cPadCon := ""
LOCAL cRegInt := ""
LOCAL cDescSimb:= GetNewPar("MV_SIMB1","R$")
LOCAL cCodCli  := ""
LOCAL cLoja    := ""
LOCAL aLocais  := {}

//Testa se foi informado o prestador, usuario e procedimento...           

If Empty(aDadRda) .Or. Empty(aDadUsr) .Or. Empty(oBrwP:FieldGet("BE2_CODPRO",1))
	Aviso( STR0117, STR0145, { STR0146 }, 2 ) 	  //"Compra de Procedimentos"###"Informe o prestador, usuario e pelo menos um procedimento antes de selecionar esta opcao"###"Ok"
	Return
Endif

//Se for rda generica nao pode comprar...                                 

If cTipo == "2" .And. ( GetNewPar("MV_PLSEVRG","0") == "0" .And. &("M->"+cAliasEnc+"_CODRDA") == GetNewPar("MV_PLSRDAG","999999") )
	Aviso( STR0117, STR0147, { STR0146 }, 2 ) 	  //"Compra de Procedimentos"###"Informa uma Rede de Atendimento valida para continuar."###"Ok"
	Return
Endif

If Empty(cMV_PLSSELC)
	Aviso( STR0117, STR0148, { STR0146 }, 2 ) 	    //"Compra de Procedimentos"###"Parametro MV_PLSSELC com conteudo invalido."###"Ok"
	Return
Endif

//Alimenta o Array com os Locais de Atendimento

aAdd(aLocais,{aDadRda[12]})

//Verificar se o prestador pode executar o servico...                     

aRetMed := PLSAUTPMDD(&("M->"+cAliasEnc+"_OPERDA"),&("M->"+cAliasEnc+"_CODRDA"),oBrwP:FieldGet("BE2_CODPAD",1),;
oBrwP:FieldGet("BE2_CODPRO",1),aDadRDA,"1",aDadUsr,"1",;
&("M->"+cAliasEnc+"_CODESP"),Subs(&("M->"+cAliasEnc+"_CODLOC"),1,3),.F.,aLocais)

If ! aRetMed[1]
	PLSMOVCRI("3",{},aRetMed[2])
	Return
Endif

//1-Internacao
//2-Ambulatorial
//Se for internacao ou reembolso
If cAliasEnc == 'BE4' .Or. cAliasEnc == 'B44'
	cPadInt := (cAliasEnc)->&(cAliasEnc+"_PADINT")
	cPadCon := (cAliasEnc)->&(cAliasEnc+"_PADCON")
	cRegInt := (cAliasEnc)->&(cAliasEnc+"_REGINT")
EndIf

//Redefine a lista de opcoes retirando a opcao a Escolher...              

nSize := Len(aComboResp)
aDel(aComboResp,nSize)
aSize(aComboResp,nSize-1)

nSize := Len(aPagtoResp)
aDel(aPagtoResp,nSize)
aSize(aPagtoResp,nSize-1)

If Len(aPagtoResp) == 0
	Aviso( STR0117, STR0149, { STR0146 }, 2 ) 	     //"Compra de Procedimentos"###"Falha ao buscar dados do campo BQC_QUACOB."###"Ok"
	Return
Endif

If Len(aComboResp) == 0
	Aviso( STR0117, STR0150, { STR0146 }, 2 ) 	     //"Compra de Procedimentos"###"Falha ao buscar dados do campo BQC_RESCOM."###"Ok"
	Return
Endif

//Ajusta o aComboResp e aPagtoResp...                                     

aAux := {}
For nFor := 1 To Len(aComboResp)-1
	aadd(aAux,aComboResp[nFor,1])
Next
aComboResp := aClone(aAux)

aAux := {}
For nFor := 1 To Len(aPagtoResp)-1
	aadd(aAux,aPagtoResp[nFor,1])
Next
aPagtoResp := aClone(aAux)

//Checa se existem pelo menos um dos itens negados...                     

For nFor := 1 To Len(oBrwP:aCols)

	//Campo status igual a 0=Nao linha ativa...                               

	If oBrwP:FieldGet("BE2_STATUS",nFor) == "0" .And. ! oBrwP:IsDeleted(nFor)

		//Liga flag para testar se pelo menos um item esta ativo...               

		If ! lPodeComp
			lPodeComp := .T.
		Endif

		//Calcula o valor deste item para compra...                               

		If BEA->(FieldPos("BEA_TIPPRE")) > 0
			cTipPreFor := &("M->"+cAliasEnc+"_TIPPRE")
		Else
			cTipPreFor := ""
		Endif

		aRdas := PLS720IBD7("0",0,oBrwP:FieldGet("BE2_CODPAD",nFor),oBrwP:FieldGet("BE2_CODPRO",nFor),"",;
		&("M->"+cAliasEnc+"_OPERDA"),&("M->"+cAliasEnc+"_CODRDA"),;
		&("M->"+cAliasEnc+"_REGEXE"),&("M->"+cAliasEnc+"_SIGEXE"),;
		&("M->"+cAliasEnc+"_ESTEXE"),&("M->"+cAliasEnc+"_CDPFRE"),;
		&("M->"+cAliasEnc+"_CODESP"),;
		&("M->"+cAliasEnc+"_CODLOC"),"3",oBrwP:FieldGet("BE2_SEQUEN",nFor),;
		"1","02")

		If BD6->(FieldPos("BD6_CHVNIV")) > 0
			cChvNiv := oBrwP:FieldGet("BE2_CHVNIV",nFor)
		Else
			cChvNiv := ""
		Endif

		If Empty(oBrwP:FieldGet("BE2_NIVAUT",nFor))
			cNiv := oBrwP:FieldGet("BE2_NIVCRI",nFor)
		Else
			cNiv := oBrwP:FieldGet("BE2_NIVAUT",nFor)
		EndIf

		cTipoGuia := IF(AllTrim(oBrwP:FieldGet("BE2_CODPAD",nFor)+oBrwP:FieldGet("BE2_CODPRO",nFor)) == cParam01,"01","02")


		cProRel := If(oBrwP:FieldPos("BE2_PROREL") > 0 ,oBrwP:FieldGet("BE2_PROREL",nFor), "")
		cPrPrRl := If(oBrwP:FieldPos("BE2_PRPRRL") > 0 ,oBrwP:FieldGet("BE2_PRPRRL",nFor), "")

		aValor := PLSCALCCOP(oBrwP:FieldGet("BE2_CODPAD",nFor),;
		oBrwP:FieldGet("BE2_CODPRO",nFor),;
		&("M->"+cAliasEnc+"_MESPAG"),&("M->"+cAliasEnc+"_ANOPAG"),&("M->"+cAliasEnc+"_CODRDA"),;
		&("M->"+cAliasEnc+"_CODESP"),"",subs(&("M->"+cAliasEnc+"_CODLOC"),1,3),;
		IIF(oBrwP:FieldGet("BE2_QTDPRO",nFor)==0,oBrwP:FieldGet("BE2_QTDSOL",nFor),oBrwP:FieldGet("BE2_QTDPRO",nFor)),;
		&("M->"+cAliasEnc+"_DATPRO"),.F.,"2",0,cGrpInt,;
		aDadUsr,cPadInt,cPadCon,nil,cRegAte,0,.T.,.T.,&("M->"+cAliasEnc+"_HORPRO"),aRdas,;
		&("M->"+cAliasEnc+"_OPERDA"),cTipPreFor,;
		cProRel,cPrPrRl,aValAcu,;
		cNiv,cChvNiv,nil,nil,&("M->"+cAliasEnc+"_CID"),nil,cTipoGuia,,,,,,,,,,,,,,,,,cRegInt,;
		Iif(TYPE(&("M->"+cAliasEnc+"_TIPPAC")) <> "U",&("M->"+cAliasEnc+"_TIPPAC"),nil))

		If aValor[1]
			If oBrwP:FieldGet("BE2_VLCOMP",nFor) == 0
				nVlrBPF    := aValor[11]
				nVlrPF     := aValor[12]
				nQtdPro    := oBrwP:FieldGet("BE2_QTDPRO",nFor)
				nPercPF    := (nVlrPF*100)/nVlrBPF
				nVlrPFTot  += nVlrPF
			Else
				nVlrBPF    := oBrwP:FieldGet("BE2_VLCOMP",nFor)
				nVlrPF     := oBrwP:FieldGet("BE2_VLCOMP",nFor)
				nQtdPro    := oBrwP:FieldGet("BE2_QTDPRO",nFor)
				nPercPF    := (nVlrPF*100)/nVlrBPF
				nVlrPFTot  += nVlrPF
			Endif

			aadd(aValAcu,{oBrwP:FieldGet("BE2_CODPAD",nFor),oBrwP:FieldGet("BE2_CODPRO",nFor),aValor[17],;
			&("M->"+cAliasEnc+"_DATPRO"),&("M->"+cAliasEnc+"_HORPRO")})
		Else
			nVlrBPF    := 0
			nVlrPF     := 0
			nQtdPro    := 0
			nPercPF    := 0

			aadd(aValAcu,{oBrwP:FieldGet("BE2_CODPAD",nFor),oBrwP:FieldGet("BE2_CODPRO",nFor),;
			{},&("M->"+cAliasEnc+"_DATPRO"),&("M->"+cAliasEnc+"_HORPRO")})
		Endif

		//Adiciona na matriz o procedimento e o seu respectivo valor               
		//                                                                         
		//[1]  Cod Tipo Tabela                                                     
		//[2]  Codigo Procedimento                                                 
		//[3]  Quantidade                                                          
		//[4]  Descricao                                                           
		//[5]  Valor Base Participacao Financeira                                  
		//[6]  Valor da Participacao Financeira                                    
		//[7]  Percentual da Participacao Financeira                               
		//[8]  Valor Total da Participacao Financeira Acumulada                    

		aadd(aCdPrcNeg,{oBrwP:FieldGet("BE2_CODPAD",nFor),oBrwP:FieldGet("BE2_CODPRO",nFor),;
		nQtdPro,oBrwP:FieldGet("BE2_DESPRO",nFor),;
		nVlrBPF,nVlrPF,nPercPF,nVlrPFTot,aValor})
	Endif
Next

If ! lPodeComp
	Help("",1,"PLSA090CPR")
	Return
Endif

//Define de quem sera cobrado a compra e quando....                       

If BA3->BA3_TIPOUS == "1"
	lWhen1     := .F.
	cComboResp := aComboResp[1]
	lWhen2     := IF(cMV_PLSSELC=="3",.T.,.F.)
	If cMV_PLSSELC == "3"
		cPagtoResp := aPagtoResp[1]
	Else
		cPagtoResp := aPagtoResp[Val(cMV_PLSSELC)]
	Endif

	aRetFun    := PlBuscaClien("1",nil,aDadUsr)
	If ! aRetFun[1]
		Help("PLSA090CP1")
		Return
	Else
		cNomCli := aRetFun[2]
		cCodCli := aRetFun[3]
		cLoja   := aRetFun[4]
	Endif
Else

	//Posiciona no subcontrato...                                             

	BQC->(DbSetOrder(1))
	If ! BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
		Help("",1,"PLSA090CP2")
		Return
	Endif

	//Verifica se esta habilitado a comprar procedimentos...                  

	If BQC->BQC_PERCOM <> "1"
		Help("",1,"PLSA090CP3")
		Return
	Endif

	//RESPONSAVEL PELO PAGAMENTO...                                           



	//Se o responsavel for cliente da familia....                             

	If BQC->BQC_RESCOM == "1"
		cComboResp := aComboResp[1]
		lWhen1     := .F.
		aRetFun    := PlBuscaClien("1",nil,aDadUsr)

		If ! aRetFun[1]
			Help("",1,"PLSA090CP4")
			Return
		Else
			cNomCli := aRetFun[2]
			cCodCli := aRetFun[3]
			cLoja   := aRetFun[4]
		Endif

		//Se for a empresa...                                                     

	ElseIf BQC->BQC_RESCOM == "2"
		cComboResp := aComboResp[2]
		lWhen1      := .F.
		aRetFun    := PLBuscaClien("2",nil,aDadUsr)
		If ! aRetFun[1]
			Help("",1,"PLSA090CP5")
			Return
		Else
			cCodCli := aRetFun[3]
			cLoja   := aRetFun[4]
			cNomCli := aRetFun[2]
		Endif

		//Se for a escolhe habilita a escolha...                                  

	Else
		cComboResp  := ""
		lWhen1      := .T.
	Endif

	//QUANDO COBRAR...                                                        



	//Se for no ato...                                                        

	If BQC->BQC_QUACOB == "1"
		cPagtoResp := aPagtoResp[1]
		lWhen2     := .F.
	ElseIf BQC->BQC_QUACOB == "2"
		cPagtoResp := aPagtoResp[2]
		lWhen2     := .F.
	Else
		cPagtoResp := ""
		lWhen2     := .T.
	Endif
Endif

//Ponto de entrada para alterar a opÁ„o quando comprar                                                                                      

If ExistBlock("PLS090QDCP")

	aQuaCob:=Execblock("PLS090QDCP",.F.,.F.,{aPagtoResp,lWhen2})
	If ValType(aQuaCob) =='A'
		cPagtoResp := aQuaCob[1]
		lWhen2     := aQuaCob[2]
	Endif

Endif

//Testa se houve valor p/ compra...                                       

If aCdPrcNeg[Len(aCdPrcNeg),8] == 0
	Help("",1,"PLS090CP2")
	Return
Endif

//Exibe dialogo com os dados da compra...                                 

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 005,005 TO 030, 090

//Exibe mensagem informativa...                                           

@ 018,005 SAY oSay PROMPT STR0151  SIZE 220,010 OF oDlg PIXEL  //"Procedimento(s) a Ser(e)m Comprado(s)"

//Exibe browse com os dados da compra...                                  

oBrowse := TcBrowse():New( 030, 005, 320, 070,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
oBrowse:bLDblClick := { || A090VACP(aCdPrcNeg,oBrowse:nAt) }

oBrowse:AddColumn(TcColumn():New(STR0030,{ || aCdPrcNeg[oBrowse:nAt,1]+"-"+aCdPrcNeg[oBrowse:nAt,2] },; //"Procedimento"
"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))

oBrowse:AddColumn(TcColumn():New(STR0127,{ || aCdPrcNeg[oBrowse:nAt,4] },; //"Descricao"
"@!",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))

oBrowse:AddColumn(TcColumn():New(STR0152,{ || aCdPrcNeg[oBrowse:nAt,3] },; //"Qtd"
"999",nil,nil,nil,015,.F.,.F.,nil,nil,nil,.F.,nil))

oBrowse:AddColumn(TcColumn():New(STR0153,{ || aCdPrcNeg[oBrowse:nAt,5] },; //"Vlr Base"
PLPMONEY_M,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))

oBrowse:AddColumn(TcColumn():New(STR0154,{ || aCdPrcNeg[oBrowse:nAt,6] },; //"Valor Compra"
PLPMONEY_M,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))

oBrowse:AddColumn(TcColumn():New(STR0155,{ || aCdPrcNeg[oBrowse:nAt,7] },; //"% Compra"
PLPMONEY_M,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))

oBrowse:AddColumn(TcColumn():New(STR0156,{ || aCdPrcNeg[oBrowse:nAt,8] },; //"Valor Total Compra Acumulada"
PLPMONEY_M,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BE2_CODPAD+BE2_CODPRO", "BE2_DESPRO",.F.,.F.,.F.,.F.,.F.}
		aBls := objCENFUNLGP:getTcBrw(aCampos)
		oBrowse:aObfuscatedCols := aBls
		objCENFUNLGP:useLogUser()
	endif

//-------------------------------------------------------------------
//  Ativa o Dialogo...                                                        
//-------------------------------------------------------------------
oBrowse:SetArray(aCdPrcNeg)


//Exibe opcoes de compra..                                                

cOpcCob1 := Subs(cComboResP,1,1)
cOpcCob2 := Subs(cPagtoResP,1,1)

@ 110,005 SAY oSay PROMPT STR0157  SIZE 220,010 OF oDlg PIXEL  //"Responsavel pelo Pagamento ?"
@ 109,086 COMBOBOX oComboResP Var cOpcCob1 ITEMS aComboResp SIZE 092,010 OF oDlg PIXEL WHEN lWhen1
@ 110,190 SAY oSay PROMPT cNomCli  SIZE 220,010 OF oDlg PIXEL

@ 130,005 SAY oSay PROMPT STR0158  SIZE 220,010 OF oDlg PIXEL  //"Quando sera pago ?"
@ 129,086 COMBOBOX oPagtoResP Var cOpcCob2 ITEMS aPagtoResp SIZE 092,010 OF oDlg PIXEL WHEN lWhen2

//Exibe totais...                                                         

DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

@ 130,215 SAY oSay PROMPT STR0159+cDescSimb  SIZE 220,010 OF oDlg PIXEL //"Valor Total da Compra "
@ 130,285 SAY oSay PROMPT aCdPrcNeg[Len(aCdPrcNeg),8] PICTURE PLPMONEY_M SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

//Ativa o dialogo...                                                      

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons)

//Conclui a transacao de foi confirmada...                                

If nOpca == K_OK

	If Empty(cNomCli)
		If     cOpcCob1 == "1"
			aRetFun    := PlBuscaClien("1",nil,aDadUsr)
			If ! aRetFun[1]
				Help("",1,"PLSA090CP4")
				lAtuGui := .F.
			Else
				cNomCli := aRetFun[2]
				cCodCli := aRetFun[3]
				cLoja   := aRetFun[4]
				lAtuGui := .T.
			Endif
		ElseIf cOpcCob1 == "2"
			aRetFun    := PLBuscaClien("2",nil,aDadUsr)
			If ! aRetFun[1]
				Help("",1,"PLSA090CP5")
				lAtuGui := .F.
			Else
				cNomCli := aRetFun[2]
				cCodCli := aRetFun[3]
				cLoja   := aRetFun[4]
				lAtuGui := .T.
			Endif
		Endif
	Endif

	If lAtuGui
		&("M->"+cAliasEnc+"_GUIACO") := "1"
		&("M->"+cAliasEnc+"_QUACOB") := cOpcCob2
		&("M->"+cAliasEnc+"_CODCLI") := cCodCli
		&("M->"+cAliasEnc+"_LOJA")   := cLoja
		For nFor := 1 To Len(oBrwP:aCols)
			If ! oBrwP:aCols[nFor,Len(oBrwP:aHeader)+1] .And. oBrwP:FieldGet("BE2_STATUS",nFor) == "0"
				nPos := Ascan(aCdPrcNeg,{ |x| x[1]+x[2] == oBrwP:FieldGet("BE2_CODPAD",nFor)+oBrwP:FieldGet("BE2_CODPRO",nFor) })

				oBrwP:FieldPut("BE2_IMGSTA","ENABLE",nFor)
				oBrwP:FieldPut("BE2_STATUS","1",nFor)
				oBrwP:FieldPut("BE2_AUDITO","0",nFor)
				oBrwP:FieldPut("BE2_NIVCRI","",nFor)
				oBrwP:FieldPut("BE2_NIVAUT",cNiv,nFor)
				oBrwP:FieldPut("BE2_GUIACO","1",nFor)
				oBrwP:FieldPut("BE2_QUACOB",cOpcCob2,nFor)
				If nPos > 0
					oBrwP:FieldPut("BE2_VLCOMP",aCdPrcNeg[nPos,6],nFor)
				EndIf
			Else
				oBrwP:FieldPut("BE2_GUIACO","0",nFor)
				oBrwP:FieldPut("BE2_QUACOB","",nFor)
			EndIf
		Next
		oBrwP:Atualiza()
		AtuVlComp(.F.,"2")
		EndIf

	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlBuscaClien
Busca dados do cliente "1" na familia e "2" no nv de cobr.

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLBuscaClien(cTipo,cPagAto,aDadUsr)
	LOCAL aRet         := {.F.,"","","",""}
LOCAL aCliente     := {}
LOCAL cTipoPagAto
LOCAL cMatric   	  := ""
LOCAL aRetPto
DEFAULT cPagAto 	  := "0"
DEFAULT aDadUsr 	  := {}

If Len(aDadUsr) > 2 .and. aDadUsr[1]
	cMatric    := aDadUsr[2]
	If  cMatric <> BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO
		BA1->(DbSetOrder(2))
		BA1->(MsSeek(xFilial("BA1")+cMatric))
	Endif
Endif

If     cTipo == "1"
	SA1->(DbSetOrder(1))
	If ! SA1->(MsSeek(xFilial("SA1")+BA3->(BA3_CODCLI+BA3_LOJA)))
		Return(aRet)
	Else
		aRet := {.T.,SA1->A1_COD+"-"+SA1->A1_LOJA+" -> "+Subs(AllTrim(SA1->A1_NOME),1,20)+STR0160,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME} //" (Familia)"
	Endif
ElseIf cTipo == "2"

	If cPagAto == "0" //Tratamento para quando nao for pagamento no Ato
		aCliente := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,1,BA1->BA1_TIPREG)

		If ( Empty(aCliente) ) .Or. ( aCliente[1,1] == "ZZZZZZ" ) .Or. ( Len(aCliente) > 0 .And. ! aCliente[1,18] $ "1,2,3,4,5,6" )
			Return(aRet)
		Else
			aRet[1] := .T.
		Endif

		aRet[2] := AllTrim(aCliente[1,1])+"-"+AllTrim(aCliente[1,2])+" -> "+Subs(AllTrim(aCliente[1,3]),1,20)
		aRet[3] := aCliente[1,1]
		aRet[4] := aCliente[1,2]
		aRet[5] := aCliente[1,3]
		If     aCliente[1,18] == "1"
			aRet[2] += STR0161 //"(Empresa)"
		ElseIf aCliente[1,18] == "2"
			aRet[2] += STR0162 //"(Contrato)"
		ElseIf aCliente[1,18] == "3"
			aRet[2] += STR0163 //"(Subcontrato)"
		ElseIf aCliente[1,18] == "4"
			aRet[2] += STR0164 //"(Familia)"
		ElseIf aCliente[1,18] == "5"
			aRet[2] += STR0165 //"(Usuario)"
		ElseIf aCliente[1,18] == "6"
			aRet[2] += STR0166 //"(Operadora)"
		Endif
	Else //Tratamento para quando for pagamento no ato
		BQC->(DbSetOrder(1))
		BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))

		cTipoPagAto := "1"

		If BQC->(FieldPos("BQC_RPGPAT")) > 0
			cTipoPagAto := BQC->BQC_RPGPAT
		Endif

		If cTipoPagAto == "1"
			aCliente := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,1,BA1->BA1_TIPREG)

			If ( Empty(aCliente) ) .Or. ( aCliente[1,1] == "ZZZZZZ" ) .Or. ( Len(aCliente) > 0 .And. ! aCliente[1,18] $ "1,2,3,4,5,6" )
				Return(aRet)
			Else
				aRet[1] := .T.
			Endif

			aRet[2] := AllTrim(aCliente[1,1])+"-"+AllTrim(aCliente[1,2])+" -> "+Subs(AllTrim(aCliente[1,3]),1,20)
			aRet[3] := aCliente[1,1]
			aRet[4] := aCliente[1,2]
			aRet[5] := aCliente[1,3]
			If     aCliente[1,18] == "1"
				aRet[2] += STR0161 //"(Empresa)"
			ElseIf aCliente[1,18] == "2"
				aRet[2] += STR0162 //"(Contrato)"
			ElseIf aCliente[1,18] == "3"
				aRet[2] += STR0163 //"(Subcontrato)"
			ElseIf aCliente[1,18] == "4"
				aRet[2] += STR0164 //"(Familia)"
			ElseIf aCliente[1,18] == "5"
				aRet[2] += STR0165 //"(Usuario)"
			ElseIf aCliente[1,18] == "6"
				aRet[2] += STR0166 //"(Operadora)"
			Endif
		Else
			SA1->(DbSetOrder(1))
			If !SA1->(dbSeek(xFilial("SA1")+GetNewPar("MV_PLSCLIG","999999"),.F.))
				Reclock('SA1',.T.)
				SA1->A1_FILIAL	:= xFilial('SA1')
				SA1->A1_COD		:= GetNewPar("MV_PLSCLIG","999999")
				SA1->A1_LOJA	:= '01'
				SA1->A1_NOME	:= 'CLIENTE GENERICO'
				SA1->A1_PESSOA	:= 'F'
				SA1->A1_NREDUZ	:= 'CLIENTE GENERICO'
				SA1->A1_END		:= 'CLIENTE GENERICO'
				SA1->A1_TIPO	:= 'F'
				SA1->A1_EST		:= GetNewPar('MV_ESTADO','SP')
				SA1->A1_MUN		:= 'CLIENTE GENERICO'
				msUnlock()
			EndIf				
			aRet := {.T.,;
			SA1->A1_COD+"-"+SA1->A1_LOJA+" -> "+Subs(SA1->A1_NOME,1,20)+STR0167,;						// SA1->A1_COD+"-"+SA1->A1_LOJA+" -> "+Subs(SA1->A1_NOME,1,20),;
			SA1->A1_COD,;
			SA1->A1_LOJA,;
			SA1->A1_NOME }				// SA1->A1_NOME,;
		Endif
	Endif
Endif

If ExistBlock("PLS090CLI")
	aRetPto := ExecBlock("PLS090CLI",.F.,.F.,{aRet})
		aRet := aRetPto[1]
	Endif

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090VR2

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090VR2(cAlias,oObj)
	LOCAL lRet    := .T.
	LOCAL cCodRda
	DEFAULT cAlias := "BE1"
DEFAULT oObj   := oEncAut

If &("M->"+cAlias+"_OPERDA") == PLSINTPAD()
	Return(lRet)
Endif

BA0->(DbSetOrder(1))
If ! BA0->(MsSeek(xFilial("BA0")+&("M->"+cAlias+"_OPERDA")))
	Help("",1,"REGNOIS")
	lRet := .F.
Endif

If lRet
	cCodRda := BA0->BA0_CODRDA
	&("M->"+cAlias+"_CODRDA") := cCodRda

	If ( &("M->"+cAlias+"_OPERDA") <> PLSINTPAD() ) .And. ( ! Empty(cCodRda) )
		lRet := PLSA090RDA(&("M->"+cAlias+"_OPERDA"),&("M->"+cAlias+"_CODRDA"),"1",&("M->"+cAlias+"_DATPRO"),;
		&("M->"+cAlias+"_USUARI"),&("M->"+cAlias+"_CODLOC"),&("M->"+cAlias+"_CODESP"),cAlias)

		If lRet
			&("M->"+cAlias+"_TIPPRE") := BAU->BAU_TIPPRE
			lRefresh := .T.
			oObj:Refresh()
		Else
			&("M->"+cAlias+"_CODRDA") := ""
		Endif
	Endif
Endif

&("M->"+cAlias+"_OPERDA") := PLSINTPAD()

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090Bxt

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090Bxt
	LOCAL cChvSE1	   := ''
LOCAL cStatus	   := '1'
PRIVATE nValTot := 0
PRIVATE aCaixaFin  := xCxFina() // Caixa Geral do Financeiro (MV_CXFIN)
PRIVATE nTotAGer   := 0
PRIVATE nTotADesc  := 0
PRIVATE nTotAMul   := 0
PRIVATE nTotAJur   := 0
PRIVATE nTotADesp  := 0
PRIVATE cLoteFin   := Space (4 )
PRIVATE cMarca     := GetMark()
PRIVATE cOld       := cCadastro
PRIVATE aCampos    := {}
PRIVATE cLote      := ""
PRIVATE lF070Auto  := .F.
PRIVATE oFontLbl
PRIVATE lValidou := .F.
Private lImpGuiDir := .F.
PRIVATE aDadosRef := Array(7)
PRIVATE aDadosRet := Array(7)
PRIVATE aDadosImp := Array(3)
PRIVATE nIndexSE1 := ""
PRIVATE cIndexSE1 := ""
PRIVATE lFini055  := IsInCallStack("FINI055")
PRIVATE lMVGlosa	:= getNewPar("MV_GLOSA",.F.)

//Privates Referente ao FINA070, para que a baixa do tÌtulo n„o dÍ erro
//PRIVATE lF070Auto	:= (xAutoCab <> NIL)
PRIVATE aAutoCab	:={}
PRIVATE cPortado	:= CriaVar("E1_PORTADO",.F.)
PRIVATE cBanco	:= CriaVar("E1_PORTADO",.F.)
PRIVATE cAgencia	:= CriaVar("E1_AGEDEP" ,.F.)
PRIVATE cConta	:= CriaVar("E1_CONTA"  ,.F.) 
PRIVATE cNatMov  	:= ''
PRIVATE lValidou	:= .F. 
PRIVATE lOracle		:= "ORACLE"$Upper(TCGetDB())
PRIVATE nOldValRec	:= 0
PRIVATE aDadosRef	:= Array(7)
PRIVATE lFini055	:= IsInCallStack("FINI055") 
PRIVATE aCols		:= {}
PRIVATE NISS        := 0
//Fim do bloco de Privates do FINA070

DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD


If ExistBlock("PLS090CX")
	aCaixaFin := ExecBlock("PLS090CX",.F.,.F.,aCaixaFin)
Endif

If GetNewPar("MV_PLSIFIN","1") <> "1"
	MsgInfo(STR0168) //"A opcao de baixa nao pode ser executada neste momento em funcao do parametro MV_PLSIFIN"
	Return
Endif
SE1->(DbSetOrder(1))
If lBEANTit
	cChvSE1 := BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)
Else
	cChvSE1 := BEA->BEA_CHVSE1
Endif
If ! SE1->(MsSeek(xFilial("SE1")+cChvSE1))
	If !Empty(BEA->BEA_NUMTIT)
		Help("",1,"PLSA090Bx3")
		Return
	Else
		MsgInfo(STR0169)
		Return
	EndIf
Endif

If SE1->E1_SALDO == 0
	//Help("",1,"PLSA090Bx1")
	MsgInfo(STR0169)    //"A baixa referente a esta guia ja foi feita. O saldo do titulo e zero."
	Return
Endif

If BEA->BEA_STATUS <> "5"
	Help("",1,"PLSA090Bx2")
	Return
Endif

Pergunte("FIN070",.F.)

nRec := SE1->(Recno())

If GetNewPar("MV_PLSBXCP","1") == "1"
	SE1->(FA070Tit("SE1",0,SE1->(Recno())))
Else
	Fina087a(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
Endif

SE1->(DbGoTo(nRec))

If SE1->E1_SALDO == 0
	//Atualiza o Status da Guia
	PLSTitStat()

	If FunName() == "PLSA094C" .OR. FunName() == "PLSA094D" //BAIXA DE TITULO PELA AUTORIZA«√O ODONTO OU LIBERA«√O ODONTO.
		RecLock("BEA",.F.)
		BEA->BEA_GUIACO := "1"
		MsUnLock()
		PLSR431N({"2"})
	Else
		Eval(bImpGuia)
	Endif

	If MsgYesNo(STR0170) //"Imprimir o Recibo?"
		PLSA090REC(.F.)
	Endif
Else
	MsgStop(STR0171) //"Nao foi liquidado o titulo, a guia continua bloqueada"
Endif

If ExistBlock("PLS090BX")
	ExecBlock("PLS090BX",.F.,.F.)
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090ICP

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090ICP(aDadosCompra,cNomCli,cPagtoResp,nVlrTotal,cCodRda,cOpeRda,cCodLoc,cLocal,cMatric,cNomUsr,;
	cCid,cEstSol,cRegSol,cSigla,cNomSol,cTipo)

	//Ponto de Entrada para permitir customizaÁ„o da impress„o do orÁamento.
If ExistBlock('PL736IMP')
	ExecBlock('PL736IMP',.F.,.F.,{aDadosCompra,cNomCli,cPagtoResp,nVlrTotal,cCodRda,cOpeRda,cCodLoc,cLocal,cMatric,cNomUsr,;
		cCid,cEstSol,cRegSol,cSigla,cNomSol,cTipo})
	Else
		PLSR736(aDadosCompra,cNomCli,cPagtoResp,nVlrTotal,cCodRda,cOpeRda,cCodLoc,cLocal,cMatric,cNomUsr,;
		cCid,cEstSol,cRegSol,cSigla,cNomSol,cTipo)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090ATP

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090ATP(cAliasIte,cAliasCab,oEnc,cCodLocPar,lVld)

	LOCAL cCodPad
	LOCAL cCodPro
	LOCAL aDados
	LOCAL cCodRDA
	LOCAL aDadRda := PLSGETRDA()
	LOCAL nRegBAU    := BAU->(Recno())
	LOCAL nOrdBAU    := BAU->(IndexOrd())
	LOCAL bRest      := { || BAU->(DbSetOrder(nOrdBAU)), BAU->(DbGoTo(nRegBAU)) }
	DEFAULT lVld := .T.

	If lVld
		cCodPad := &("M->"+cAliasIte+"_CODPAD")
		cCodPro := &("M->"+cAliasIte+"_CODPRO")
	Else
		cCodPad := oBrwPro:FieldGet(cAliasIte+"_CODPAD")
		cCodPro := oBrwPro:FieldGet(cAliasIte+"_CODPRO")
	Endif

	aDados := PLSListaPrd(cCodPad,cCodPro,cCodLocPar)

	If Len(aDados) > 0
		cCodRda := aDados[1,1]
		BAU->(DbSetOrder(1))
		If BAU->(MsSeek(xFilial("BAU")+cCodRda))
			&("M->"+cAliasCab+"_CODRDA") := BAU->BAU_CODIGO
			&("M->"+cAliasCab+"_NOMRDA") := BAU->BAU_NOME
			PLSA090RDA(&("M->"+cAliasCab+"_OPERDA"),&("M->"+cAliasCab+"_CODRDA"),"1",&("M->"+cAliasCab+"_DATPRO"),;
			&("M->"+cAliasCab+"_USUARI"),&("M->"+cAliasCab+"_CODLOC"),&("M->"+cAliasCab+"_CODESP"),cAliasCab)
			lRefresh := .T.
			If ValType(oEnc) == "O"
				oEnc:Refresh()
			Endif
		Endif
		EVAL(bRest)
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSListaPrd

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function PLSListaPrd(cCodPad,cCodPro,cCodLocPar)
	LOCAL nFor
	Local aArea     := GetArea()
	LOCAL __aNiveis := PLSESPNIV(cCodPad)
	LOCAL nNiveis   := (__aNiveis[1]+1)
	LOCAL cSQL
	LOCAL aDados    := {}

	For nFor := 1 To nNiveis

		cSQL   := "SELECT BDJ_CODRDA, BDJ_PRIORI FROM "+RetSQLName("BDJ")+" WHERE "
	cSQL   += "BDJ_FILIAL = '"+xFilial("BDJ")+"' AND "
	cSQL   += "BDJ_CODINT = '"+PLSINTPAD()+"' AND "
	cSQL   += "BDJ_CODLOC = '"+cCodLocPar+"' AND "

	If nFor == 1
		cSQL += "BDJ_CODPRO = '"+cCodPro+"' AND "
	Else
		cSQL += "BDJ_CDNV0"+StrZero(nFor-1,1)+" = '"+Subs(cCodPro,__aNiveis[2,(nFor-1),1],__aNiveis[2,(nFor-1),2])+"' AND "
		cSQL += "BDJ_NIVEL = '"+__aNiveis[2,(nFor-1),3]+"' AND "
	Endif

	cSQL   += "BDJ_CODPAD = '"+cCodPad+"' AND "
	cSQL   += "D_E_L_E_T_ = ''"
	cSQL   += " ORDER BY BDJ_PRIORI"

	PLSQuery(cSQL,"Trb090")

	If ! Trb090->(Eof())
		While ! Trb090->(Eof())
			aadd(aDados,{Trb090->BDJ_CODRDA,Posicione("BAU",1,xFilial("BAU")+Trb090->BDJ_CODRDA,"BAU_NOME"),Trb090->BDJ_PRIORI})
				Trb090->(DbSkip())
			Enddo
		Endif

		Trb090->(DbCloseArea())
		RestArea(aArea)
	Next

Return(aDados)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090LOC
Valida o local de atendimento...  

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090LOC(cOpeRda,cCodRda,cCodLoc,dData,cAlias,cMatricula)
	LOCAL aRetFun	:= {}
	LOCAL aCarRDA	:= {}
	LOCAL lForcar	:= .F.
	LOCAL lRet	:= .F.
	LOCAL aDadRda	:= PLSGETRDA()
	LOCAL aUser	:= PLSGETUsr()
	LOCAL cCodPla	:= ""
LOCAL cVerPla	:= ""
LOCAL nPosLoc	:= 0

DEFAULT dData 		:= dDataBase
DEFAULT cAlias		:= "BE1"
DEFAULT cMatricula	:= ""

//oEncAut	:= {}

If Empty(cCodLoc)
	Return(.T.)
Endif

If Empty(aUser)
	If Select(cAlias) > 0 .and.  &(cAlias)->(FieldPos(cAlias+"_DATPRO")) > 0 .and. !Empty(cMatricula)
		aUser := PLSDADUSR(cMatricula,"1", .F., &(cAlias+"_DATPRO"))
		If Len(aUser)>=11
			cCodPla := aUser[11]
			cVerPla := aUser[12]
		Endif
	Elseif !Empty(cMatricula)
		aUser := PLSDADUSR(cMatricula,"1", .F., dDataBase)
		If Len(aUser)>=11
			cCodPla := aUser[11]
			cVerPla := aUser[12]
		Endif
	Endif
Else
	If Len(aUser)>=11
		cCodPla := aUser[11]
		cVerPla := aUser[12]
	Endif
Endif
//Se for portal, n„o necessita efetuar o restante das verificaÁıes   
aRetFun := PLSVDLOCRD(cCodRda,cOpeRda,dData,cCodLoc,"","", "", "", cCodPla, cVerPla)

If cAlias == "PORTAL"
	If !aRetFun[1]
		Return .F.
	Else
		return .T.
	EndIf
Else
	If !aRetFun[1]
		PLSMOVCRI("3",aUser,aRetFun[2])
		Return .F.
	EndIf
EndIf

&("M->"+cAlias+"_DESLOC") := BB8->BB8_DESLOC
&("M->"+cAlias+"_ENDLOC") := AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO)

If Len(aDadRda) >= 13
	PLSPUTRDA(12,Subs(cCodLoc,1,3))
	PLSPUTRDA(13,Subs(cCodLoc,4,3))
Endif
If Len(aDadRda) >= 20
	PLSPUTRDA(18,cCodLoc)
	PLSPUTRDA(19,BB8->BB8_DESLOC)
	PLSPUTRDA(20,AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO))
Endif

aRetFun := PLSVDESPRD(cCodRda,cOpeRda,cCodLoc,"",dData,"","")

If ! aRetFun[1]
	Help("",1,"PLSA090ESP")
	Return(.F.)
Else
	If Len(aDadRda) >= 17
		PLSPUTRDA(15,BAX->BAX_CODESP)
		PLSPUTRDA(17,BAQ->BAQ_DESCRI)
	Endif
	&("M->"+cAlias+"_CODESP") := BAX->BAX_CODESP
	&("M->"+cAlias+"_DESESP") := BAQ->BAQ_DESCRI
EndIf
//Monta caracterizacao desse local de atendimento para a rda...      
If FindFunction('PLSRDAREF')
	aCarRDA := PLSRDAREF('BBK',cCodRda+cOpeRda+BB8->BB8_CODLOC+BAX->BAX_CODESP)

	If Len(aDadRda) >= 26
		PLSPUTRDA(26,aCarRDA)
	Endif
Endif

lRet := PLSA090RDA(&("M->"+cAlias+"_OPERDA"),&("M->"+cAlias+"_CODRDA"),"1",&("M->"+cAlias+"_DATPRO"),&("M->"+cAlias+"_USUARI"),cCodLoc,BAX->BAX_CODESP,cAlias,nil,nil,nil,.T.)[1]

// Volta o foco para a enchoice pois apos o valid estava atraplhando o usuario
If ValType(oEncAut) == "O" .and. (nPosLoc := aScan(oEncAut:aGets, {| aVet | "_CODLOC" 	$ aVet})) > 0  .and. ValType(oEncAut:AENTRYCTRLS[nPosLoc]) <> 'U'
		nPosLoc := IIf(Len(oEncAut:AENTRYCTRLS) > nPosLoc, nPosLoc + 1, nPosLoc)
		oEncAut:AENTRYCTRLS[nPosLoc]:SetFocus()
	EndIf
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090ESP
Valida a especialidade  

@author  PLS TEAM
@version P11
@since   02.07.00
/*/
//-------------------------------------------------------------------
Function PLSA090ESP(cOpeRda,cCodRda,cCodLoc,cCodEsp,dData,cAlias)
	LOCAL lRet	  	:= .F.
	LOCAL lForcar 	:= .F.
	LOCAL lVldRDA 	:= .T.
	LOCAL aRetFun 	:= {}
	LOCAL aCarRDA 	:= {}
	DEFAULT dData 	:= dDataBase
	DEFAULT cAlias	:= "BE1"

If Empty(cCodEsp)
	Return(.T.)
Endif

aRetFun := PLSVDESPRD(cCodRda,cOpeRda,SUBS(cCodLoc,1,3),cCodEsp,dData,"","")

If ! aRetFun[1]

	aRetFun := PLSVDESPRD(cCodRda,PLSINTPAD(),SUBS(cCodLoc,1,3),cCodEsp,dData,"","")

	If ! aRetFun[1]
		Help("",1,"PLSA090ESP")
		Return(.F.)
	Endif
Endif

&("M->"+cAlias+"_DESESP") := BAQ->BAQ_DESCRI

PLSPUTRDA(15,cCodEsp)
PLSPUTRDA(17,BAQ->BAQ_DESCRI)

//Monta caracterizacao desse local de atendimento para a rda...      
If FindFunction('PLSRDAREF')
	aCarRDA := PLSRDAREF('BBK',cCodRda+cOpeRda+SUBS(cCodLoc,1,3)+cCodEsp)

	PLSPUTRDA(26,aCarRDA)
Endif

//Valida novamente a rda agora com a especialidade definida
lRet := PLSA090RDA(&("M->"+cAlias+"_OPERDA"),&("M->"+cAlias+"_CODRDA"),"1",&("M->"+cAlias+"_DATPRO"),&("M->"+cAlias+"_USUARI"),cCodLoc,cCodEsp,cAlias,nil,nil,nil,.T.)[1]

Return(lRet)

/*/{Protheus.doc} PLSA090PRO

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
Function PLSA090PRO()
LOCAL aArea 		:= GetArea()
LOCAL lRet      	:= .F.
LOCAL cFaces 		:= ""
LOCAL cSQL          := ""
local cTipGui		:= PLSRetAut()[1]
LOCAL cAliCab		:= PLSRetAut()[2]
LOCAL cAliIte   	:= PLSRetAut()[3]
LOCAL cAliCri   	:= PLSRetAut()[4]
LOCAL nOrdBA0   	:= BA0->(IndexOrd())
LOCAL nRecBA0   	:= BA0->(Recno())
LOCAL nPosLinDel    := 0
LOCAL nPosCodPad    := 0
LOCAL nPosCodPro    := 0
LOCAL nPosDesPro	:= 0
LOCAL cCodProLin	:= 0
LOCAL nPosDenPro    := 0
LOCAL nPosFacPro    := 0
LOCAL nX			:= 0
LOCAL aRet			:= {}
LOCAL lVerDente     := .F.
LOCAL lVerFace      := .F.
LOCAL lNegProPac    := .F.
LOCAL cCodTab		:= ""
LOCAL cCodPad 		:= ""
LOCAL cCodPro 		:= ""
LOCAL cPadInt 		:= ""
LOCAL cPadCon 		:= ""
LOCAL lProPTUGen    := .F.
LOCAL lUnimeds      := IF(AllTrim(GetNewPar("MV_PLSUNI","1"))=="1",.T.,.F.)
LOCAL cTipRot       := "1" //Liberacao
LOCAL dDatPro		:= Iif(ValType(&("M->"+cAliCab+"_DATPRO"))=="D",&("M->"+cAliCab+"_DATPRO"),dDataBase) 
LOCAL aDadUsr       := {}
LOCAL nItensPTU     := 0
LOCAL oBrwB4B		:= Nil
LOCAL cBE2SEQUEN    := ""
LOCAL cBE2CODPAD    := ""
LOCAL cBE2CODPRO    := ""
LOCAL cBE2QTDPRO    := ""
LOCAL nPos			:= 0
LOCAL nFor			:= 0
LOCAL aAreaBE2      := {}
LOCAL lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70"    
LOCAL lCritRepet    := .T.
local lPGetTisVer	:= findFunction('PGetTisVer')
local cFunName		:= funName()	
local nQtdIte       := 0
LOCAL lRdaOpeInt    := .F.
LOCAL lPTUOn80      := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
LOCAL nPosDatPro    := 0

//Odontologico															
If cTipGui == "01" //Usa o reotrno do PlsRetaut, tem que diferenciar SADT de Odonto.
	oBrwPro := PLRetOProO()
	oBrwCri := PLRetOCriO()
	oEncAut := PLRetOEnOd()
EndIf

If cTipGui $ G_SADT_ODON//Usa o reotrno do PlsRetaut, tem que diferenciar SADT de Odonto.
	oBrwPro := PLRetOProO()
	oBrwCri := PLRetOCriO()
	oEncAut := PLRetOEnOd()
EndIf

//Reembolso																
If cTipGui == G_REEMBOLSO
	oBrwPro := Pl001ROp()
	oBrwCri := Pl001RCr()
	oEncAut := Pl001REn()
Endif

If cTipGui == G_ANEX_QUIM
	oBrwPro := PAGeObrPro()
	oBrwCri := PAGeObrC()
	oEncAut := PAGeObEn()
Endif

If cTipGui == G_PROR_INTE
	oBrwPro := P09PRETPRO()
	oBrwCri := P09PRETCRI()
	oEncAut := P09PRETENC()
Endif

If (cTipGui $ G_SADT_ODON .or. cAliCab =="B01") .And. cAliIte == "BE2" .And. Type("M->" + cAliIte + "_CODPAD" ) == "U" .And. cFunName $ "PLSA094A,PLSA094B"

	For nFor := 1 To Len(oBrwPro:aHeader)
		&( "M->"+oBrwPro:aHeader[nFor,2] ) := oBrwPro:aCols[oBrwPro:oBrowse:NAT,nFor]
	Next

EndIf

//Verifica se tem algum campo obrigatorio nao informado no cabecellho		

If ValType(oEncAut) == 'O'

	If !Obrigatorio(oEncAut:aGets,oEncAut:aTela)
		Return(.F.)
	EndIf

	If ( Type("M->" + cAliCab + "_GUIJUR") != "U" .And. &( "M->" + cAliCab + "_GUIJUR" ) == '1' )

		If (Type("M->" + cAliCab + "_NUMPRO") != "U" .And. Empty(&( "M->" + cAliCab + "_NUMPRO")))
			Aviso( "AtenÁ„o", "Esta È uma Guia Juridica. Informe o numero do processo no cabeÁalho da guia.", {"Ok"} )
			Return(.F.)
		Endif

	EndIf

	//radio e quimio nao entra se for OPME
	if cTipGui == G_ANEX_QUIM .and. Type(_xTp) != 'U' .and. _xTp != '3' .and. Type("M->" + cAliCab + "_IDADE" ) != "U" .and. &( "M->" + cAliCab + "_IDADE" ) == 0 
		Aviso( "AtenÁ„o", "Informe a IDADE", {"Ok"} )
		Return(.F.)
	endIf

EndIf

//Pega a tabela correspondente

If Type("M->" + cAliIte + "_CODPAD" ) <> 'U'

	cCodPad := &("M->"+cAliIte+"_CODPAD")
	cCodPro := &("M->"+cAliIte+"_CODPRO")
	cSequen := &("M->"+cAliIte+"_SEQUEN")
	nQtdPro := &("M->"+cAliIte+"_QTDPRO")

EndIf

If empty(GetNewPar("MV_PLSTBPD",""))
	aRet 	:= PLSCHKPAC(cAliIte,&("M->"+cAliCab+"_CODRDA"),dDatPro)
	cPadPro := aRet[1]
	&("M->" + cAliIte + "_CODPAD" ) := aRet[2]
Else
	If !Empty(cCodPad) .And. Empty(cPadPro) 
		cPadPro := cCodPad
	EndIf
EndIF

//Se o fluxo normal
If !lRet
	BR8->( DbSetOrder(1) )
	lRet := BR8->( MsSeek(xFilial("BR8") + cCodPad + cCodPro ) )
EndIf

//Se tiver tudo ok.
If lRet

	//Descricao do procedimento
	If ! ( Alltrim(cCodPro) $ __cCodMedGen)	.and. !(Alltrim(cCodPro) $ __cCodMatGen )  

		If Type("M->" + cAliIte + "_CODPAD" ) <> 'U'

			If Empty( &( "M->" + cAliIte + "_CODPAD" ) )
				&( "M->" + cAliIte + "_DESPRO" ) := Posicione("BR8",3,xFilial("BR8")+AllTrim( &( "M->" + cAliIte + "_CODPRO" ) ),"BR8_DESCRI")
			Else
				&( "M->" + cAliIte + "_DESPRO" ) := Posicione("BR8",1,xFilial("BR8")+AllTrim( &( "M->" + cAliIte + "_CODPAD" ) + &( "M->" + cAliIte + "_CODPRO" ) ),"BR8_DESCRI")
			EndIf

		EndIf

	Endif

	//Se eh reembolso sempre entra aqui
	If cTipGui == G_REEMBOLSO

		// Se for Reembolso de Intercambio
		If M->B44_REEANE == "1"

			If Empty(M->B44_CODREF)
				Aviso("Reembolso Intercambio",STR0558, {"Ok"} )//"ObrigatÛrio informar o prestador no campo 'Rede N„o Ref' do cabeÁalho!"
				lRet := .F.
			Else 
				BK6->(dbSetOrder(3) )//BK6_FILIAL, BK6_CODIGO
				If BK6->( MsSeek(xFilial("BK6")+M->B44_CODREF) )

					//Rda referente a Rede nao referenciada
					BAU->(dbSetOrder(8) )//BAU_FILIAL, BAU_CODBK6
					If !BAU->( MsSeek(xFilial("BAU")+BK6->BK6_CODIGO)) .And. BK6->(Fieldpos("BK6_CODBAU")) >0 .And. Empty(BK6->BK6_CODBAU)
						Aviso( "Reembolso Intercambio", STR0559, {"Ok"} )//"ObrigatÛrio associar uma Rede ReferÍnciada a uma N„o ReferÍnciada ou vice e versa!"
						lRet := .F.
					EndIf

				Endif

			Endif

			If lRet .And. (Empty(M->B44_REGEXE).Or. Alltrim(M->B44_REGEXE) == "1")
				Aviso( "Reembolso Intercambio", STR0560, {"Ok"} ) //"ObrigatÛrio informar um profissional executante v·lido no campo 'Executante' do cabeÁalho!"
				lRet := .F.
			Endif

			If lRet .And. Empty(M->B44_OPEEXE)
				Aviso( "Reembolso Intercambio", STR0561, {"Ok"} )//"ObrigatÛrio informar a Operadora Origem do profissional executante v·lido no campo 'Operad. Exe.' do cabeÁalho!"
				lRet := .F.
			Endif

			If lRet .And. M->B44_OPEEXE == PLSINTPAD()
				Aviso( "Reembolso Intercambio", STR0562, {"Ok"} )   //"A Operadora do profissional executante deve ser diferente a Operadora padr„o!"
				lRet := .F.
			Endif

		Endif

		//Validacao
		If ReadVar() == "M->B45_CODPRO" .OR. UpPER(allTrim(cFunName)) == "PLSA001A"

			lRet := PLSA001Aut(M->B45_SEQUEN,M->B45_CODPAD,M->B45_CODPRO,M->B45_QTDPRO,;
			"1",nil,cAliCab,nil,oBrwPro,oBrwCri,M->B44_CDPFRE,nil,nil,M->B44_PADINT,;
			M->B44_PADCON,M->B44_GRPINT,,lNegProPac)
		EndIf

		If lRet .And. B45->(FieldPos("B45_DENREG")) > 0 				   

			If ReadVar() == "M->B45_DENREG"

				BYL->(DbSetORder(1))//BYL_FILIAL + BYL_CODPAD + BYL_CODPSA + BYL_CODIGO + BYL_TIPO+BYL_FACE
				If !BYL->( MsSeek( xFilial("BYL")+&("M->"+cAliIte+"_CODPAD")+&("M->"+cAliIte+"_CODPRO")+&("M->"+cAliIte+"_DENREG") ) )
					lRet := PLA090CPMo("B44", "B45", "B46",oBrwCri)
				EndIf

			ElseIf ReadVar() == "M->B45_FADENT"
				lRet := PLA090CPMo("B44", "B45", "B46", oBrwCri)
			EndIf

		Endif

		//Odontologico
	ElseIf cTipGui $ G_SADT_ODON .Or. cAliCab == "B01"        //Usa o reotrno do PlsRetaut, tem que diferenciar SADT de Odonto.

		If ( BR8->(FieldPos("BR8_ODONTO") ) > 0 .And. BR8->BR8_ODONTO <> '1' )
			Aviso( "AtenÁ„o", "O tipo do procedimento n„o È odontologico!", {"Ok"} )
			lRet := .F.
		EndIf

		If lRet

			if lIntGui 
				If Type("M->B01_GUIPRI") == "C"
					IF  Empty(M->B01_GUIPRI) 
						Aviso( STR0573 ,STR0574, { STR0146 }, 2 ) //"Este Paciente Encontra -se  Bloqueado" #"Necessario informar a Guia Principal da InternaÁ„o "
						Return(.F.)	
					Endif
				Endif		
			Endif		

			M->BE1_NUMLIB := M->B01_NUMLIB

			If ReadVar() == "M->BE2_QTDPRO" .And. Type('M->BE2_QTDSOL') <> 'U'

				If M->BE2_QTDSOL <> M->BE2_QTDPRO
					lRet := PLA090CPMo()
				EndIf

				//Estou no procedimento                           						
			ElseIf ReadVar() == "M->BE2_CODPRO"

				M->BE2_DENREG := Space(TamSx3("BE2_DENREG")[1])
				M->BE2_DESREG := Space(TamSx3("BE2_DESREG")[1])
				M->BE2_FADENT := Space(TamSx3("BE2_FADENT")[1])
				M->BE2_FACDES := Space(TamSx3("BE2_FACDES")[1])

				//Verifica se tem dente a ser informado									
				B05->( DbSetORder(1) )//B05_FILIAL + B05_CODPAD + B05_CODPSA + B05_CODIGO + B05_TIPO
				If !B05->( MsSeek( xFilial("B05")+&("M->"+cAliIte+"_CODPAD")+&("M->"+cAliIte+"_CODPRO") ) )
					lRet := PLA090CPMo()
				EndIf

				//Lembretes                                                 			 	
				If BR8->( FieldPos("BR8_LEMBRE") ) > 0 .and. !Empty(BR8->BR8_LEMBRE)
					If lLembre := PLSLEMBRE()
						Aviso("Lembrete", Alltrim(BR8->BR8_LEMBRE), {"Ok"})
					EndIf
				Endif

				//Se estou no dente ou regi„o e nao existe face cadastrada					
			ElseIf ReadVar() == "M->BE2_DENREG"

				BYL->(DbSetORder(1))//BYL_FILIAL + BYL_CODPAD + BYL_CODPSA + BYL_CODIGO + BYL_TIPO+BYL_FACE
				If !BYL->( MsSeek( xFilial("BYL")+&("M->"+cAliIte+"_CODPAD")+&("M->"+cAliIte+"_CODPRO")+&("M->"+cAliIte+"_DENREG") ) )
					lRet := PLA090CPMo()
				EndIf

			ElseIf ReadVar() == "M->BE2_FADENT"
				lRet := PLA090CPMo()
			EndIf
		EndIf

	Elseif cTipGui == G_ANEX_QUIM

		lRet := PLSA090Aut(M->B4C_SEQUEN,M->B4C_CODPAD,M->B4C_CODPRO,M->B4C_QTDPRO,"1",'B4C',cAliCab,;
		'BEG',oBrwPro,oBrwCri,'',nil,nil,nil,nil,nil,nil,nil,;
		nil,nil,nil,nil,nil,'E',nil,nil,.F.,nil,nil,,NIL,.f.,NIL,.F. )
				
		If M->B4C_STATUS == "0" //se o procedimento for negado, ele zera o valor unit·rio autorizado do mesmo.
			M->B4C_VLRUNA := 0
		ElseIf M->B4C_STATUS == "1" //sen„o pega o valor unit·rio solicitado.
			M->B4C_VLRUNA := M->B4C_VLRUNT
		EndIf

		If lRet

			If BR8->( FieldPos("BR8_LEMBRE") ) > 0 .and. !Empty(BR8->BR8_LEMBRE)
				If lLembre := PLSLEMBRE(nil,nil,nil,nil,nil,.T.)
					Aviso("Lembrete", Alltrim(BR8->BR8_LEMBRE), {"Ok"})
				EndIf
			Endif

		Endif

	Elseif cTipGui == G_PROR_INTE

		lRet := PLSA090Aut(M->BQV_SEQUEN,M->BQV_CODPAD,M->BQV_CODPRO,M->BQV_QTDPRO,"1",'BQV',cAliCab,;
		'BEG',oBrwPro,oBrwCri,'',nil,nil,nil,nil,NIL,nil,nil,;
		nil,NIL,NIL,NIL,nil,'E',nil,nil,.F.,NIL,nil,,NIL,.f. )

		If lRet
			M->BQV_SALDO := M->BQV_QTDPRO
			If BR8->( FieldPos("BR8_LEMBRE") ) > 0 .and. !Empty(BR8->BR8_LEMBRE)
				If lLembre := PLSLEMBRE(nil,nil,nil,nil,nil,.T.)
					Aviso("Lembrete", Alltrim(BR8->BR8_LEMBRE), {"Ok"})
				EndIf
			Endif
		Endif

	Else

		If ! type("M->BE2_SEQUEN") == "U"

			cBE2SEQUEN  := M->BE2_SEQUEN
			cBE2CODPAD  := M->BE2_CODPAD
			cBE2CODPRO  := M->BE2_CODPRO
			cBE2QTDPRO  := M->BE2_QTDPRO

		ElseIf valType(oBrwPro) == "O"

			cBE2SEQUEN  := oBrwPro:aCols[1,ascan(oBrwPro:aHeader,{|x| x[2]=="BE2_SEQUEN"})]
			cBE2CODPAD  := oBrwPro:aCols[1,ascan(oBrwPro:aHeader,{|x| x[2]=="BE2_CODPAD"})]
			cBE2CODPRO  := oBrwPro:aCols[1,ascan(oBrwPro:aHeader,{|x| x[2]=="BE2_CODPRO"})]
			cBE2QTDPRO  := oBrwPro:aCols[1,ascan(oBrwPro:aHeader,{|x| x[2]=="BE2_QTDPRO"})]

		EndIf

		If cBE2QTDPRO == 0 .and. cFunName == 'PLSA094B'
			lRet := .T.
		Else
			lRet := PLSA090Aut(cBE2SEQUEN,cBE2CODPAD,cBE2CODPRO,cBE2QTDPRO,"1",nil,cAliCab,;
			nil,oBrwPro,oBrwCri,M->BE1_CDPFRE,nil,nil,nil,nil,cFaces,nil,nil,;
			nil,aDadB43,aCabB43,aTrbB43,nil,If(__cTipo=="2","S","E"),nil,nil,.F.,lNegProPac,Iif( Type("M->"+cAliCab+"_GRAUPA") == "C",&("M->"+cAliCab+"_GRAUPA"),""),,_aCopHCri )
		Endif

		If lRet

			If BR8->( FieldPos("BR8_LEMBRE") ) > 0 .and. !Empty(BR8->BR8_LEMBRE)

				If lLembre := PLSLEMBRE()
					Aviso("Lembrete", Alltrim(BR8->BR8_LEMBRE), {"Ok"})
				EndIf

			Endif

		Endif
	EndIf
Else
	Help("",1,"REGNOIS")
EndIf

//Se for autorizaÁ„o a quantidade solicitada vai ser igual a quantidade realizada desde que nao exista uma liberaÁ„o
If lRet

	If __cTipo == '1'
		If Type('M->BE1_NUMLIB') <> 'U' .and. Type('M->BE2_QTDPRO') <> 'U' .and. Type('M->BE2_QTDSOL') <> 'U' .and. Empty(M->BE1_NUMLIB) //ela nao eh oriunda de uma liberacao
			M->BE2_QTDSOL := M->BE2_QTDPRO
		Endif
	ElseIf __cTipo == '2' .And. Empty(M->BE1_NUMLIB)
		M->BE2_QTDSOL := M->BE2_QTDPRO
	EndIf

Endif

//Se PTU Online, verifico a quantidade que existe no saldo ainda
If cFunName == "PLSA094A" .And. M->BE1_COMUNI == "1" .And. !Empty(M->BE1_NUMLIB)

	aAreaBE2 := BE2->(GetArea())

	BE2->(DbSetOrder(6))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_CODPAD + BE2_CODPRO + BE2_DENREG + BE2_FADENT
	If BE2->(DbSeek(xFilial("BE2")+M->BE1_NUMLIB+M->BE2_CODPAD+M->BE2_CODPRO))

		If M->BE2_QTDPRO > BE2->BE2_SALDO
			MsgInfo(STR0543)//"N„o È possÌvel indicar uma quantidade maior que a liberada pela Operadora Origem."
			lRet := .F.
		EndIf

	EndIf

	RestArea(aAreaBE2)

EndIf

//Ok
If lRet

	//Se for guia de reembolso ou honorario individual, nao verifica          
	//regra de procedimento ja liberado                                       
	nPosCodPad  := Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliIte+"_CODPAD"})
	nPosCodPro  := Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliIte+"_CODPRO"})
	nPosDesPro	:= Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliIte+"_DESPRO"})
	cCodProLin	:= Alltrim(oBrwPro:aCols[oBrwPro:OBROWSE:nAt,nPosCodPro])
	if cTipGui == G_ANEX_QUIM
		nPosDatPro  := Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliIte+"_DATPRO"})
	endIf

	//Verifica a existencia de dentes e faces para procedimentos de odonto    
	If cTipGui $ G_SADT_ODON .Or. cAliCab == "B01"
		nPosDenPro  := Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliIte+"_DENREG"})
		nPosFacPro	:= Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliIte+"_FADENT"})

		DbSelectArea("B05")//Dentes
		DbSetOrder(1)//B05_FILIAL + B05_CODPAD + B05_CODPSA + B05_CODIGO + B05_TIPO
		If B05->(DbSeek(xFilial("B05")+M->BE2_CODPAD+M->BE2_CODPRO))
			lVerDente := .T.
		EndIf

		DbSelectArea("BYL")//Faces
		DbSetOrder(1)//BYL_FILIAL + BYL_CODPAD + BYL_CODPSA + BYL_CODIGO + BYL_TIPO+BYL_FACE
		If BYL->(DbSeek(xFilial("BYL")+M->BE2_CODPAD+M->BE2_CODPRO))
			lVerFace := .T.
		EndIf
	EndIf


	//Adicionado as rotinas de Liberacao e Autorizacao a regra que nao permite
	//lancar procedimentos repetidos em uma solicitacao para  atender o PTU   
	//Online onde e permitido repetir somente os mat/med/taxa genericos       

	If lUnimeds .And. cAliCab != "B44"
		cTipRot += "/2" //Adiciona Liberacao

		//Pega a tabela correspondente

		If Type("M->" + cAliIte + "_CODPRO" ) <> 'U'

			cCodPro := &("M->"+cAliIte+"_CODPRO")		

		EndIf

		If Alltrim(cCodPro) $ GetNewPar("MV_PTEVURG","10101039") .And. Type("M->" + cAliCab + "_TIPADM" ) <> 'U' 	
			BDR->(DbSetOrder(1))//BDR_FILIAL+BDR_CODOPE+BDR_CODTAD
			If BDR->(DbSeek(xFilial("BDR")+PlsIntPad()+&("M->" + cAliCab + "_TIPADM" ))) 
				If BDR->BDR_CARINT <> "U"
					MsgInfo("Foi informado um evento de urgÍncia/emergÍncia de interc‚mbio. … necess·rio selecionar um Tipo de Admiss„o correspondente.")
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If Alltrim(cCodPro) $(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) //Verifica eventos genericos
			lProPTUGen := .T.
		EndIf

		//Regra de itens fracionados para PTU Online
		If lUnimeds
			aDadUsr 	:= PLSGETUSR()
			
			BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
			//Solicitacao de Ordem de Servico
			if cAliCab != "B4A" .And. aDadUsr[45] == PlsIntPad() .And. BAU->( MsSeek(xFilial("BAU")+&("M->"+cAliCab+"_CODRDA"))) .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
				lRdaOpeInt := .T.
			endIf

			If aDadUsr[45] <> PlsIntPad() .Or. lRdaOpeInt

				cCodPad := &("M->"+cAliIte+"_CODPAD")
				cCodPro := &("M->"+cAliIte+"_CODPRO")
				nQtdIte := &("M->"+cAliIte+"_QTDPRO")
				
				If nQtdIte >= 1000 .And. cAliIte <> "B4C" //Para anexos ignoro a verificacao de quantidade
					MsgInfo(STR0648)//"A quantidade m·xima para um evento em atendimento de Interc‚mbio È 999."
					lRet := .F.
				EndIf
				
				BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
				If BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro)) .And. (Empty(BR8->BR8_TPPROC) .or. BR8->BR8_TPPROC $ "0/6") .And. nQtdIte % 1 > 0
					MsgInfo(STR0649)//"N„o È permitido solicitar Procedimentos MÈdicos e Pacotes fracionados para atendimento de Interc‚mbio."
					lRet := .F.
				EndIf

			EndIf

		EndIf

	EndIf

	//Verifica se o procedimento ja foi adicionado anteriormente no browse.
	If __cTipo $ cTipRot .And. Type("M->" + cAliIte + "_CODPRO") <> 'U' .AND. ( oBrwPro:linAddLine .Or. cCodProLin <>  AllTrim( M->&(cAliIte+"_CODPRO") ) ) .And. !(cTipGui $ G_RES_INTER + '|' + G_SOL_INTER)

		For nX := 1 to Len(oBrwPro:aCols)

			If Alltrim(oBrwPro:aCols[nX,nPosCodPad]) == Alltrim( M->&(cAliIte+"_CODPAD") ) .And. Alltrim(oBrwPro:aCols[nX,nPosCodPro]) == Alltrim( M->&(cAliIte+"_CODPRO") ) .And. !oBrwPro:aCols[nX,Len(oBrwPro:aHeader)+1] .and. !(Alltrim( M->&(cAliIte+"_CODPRO") ) $(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) )

				//Se o procedimento tiver dentes e faces verifica ambos                   
				If lVerDente .And. lVerFace

					If Alltrim(oBrwPro:aCols[nX,nPosDenPro]) == Alltrim(M->BE2_DENREG) .And. Alltrim(oBrwPro:aCols[nX,nPosFacPro]) == Alltrim(M->BE2_FADENT)

						Aviso( STR0028,; //Criticas
						STR0404,; //Este procedimento j· foi adicionado.
						{STR0146}, 2 )

						//Quando o usuario usa a tecla ESC, apos digitar um codigo de procedimento que ja exista a descricao ja esta atualizada, entao preciso retornar a descricao que esta na linha da getDados.
						M->BE2_DESPRO := oBrwPro:aCols[oBrwPro:oBrowse:nAt,nPosDesPro]
						lRet := .F.
						Exit
					EndIf

					//Se o procedimento tiver dentes, verifica ele somente                    

				ElseIf lVerDente

					If Alltrim(oBrwPro:aCols[nX,nPosDenPro]) == Alltrim(M->BE2_DENREG)

						Aviso( 	STR0028,; //Criticas
						STR0404,; //Este procedimento j· foi adicionado.
						{STR0146}, 2 )

						//Quando o usuario usa a tecla ESC, apos digitar um codigo de procedimento que ja exista a descricao ja esta atualizada, entao preciso retornar a descricao que esta na linha da getDados.
						M->BE2_DESPRO := oBrwPro:aCols[oBrwPro:oBrowse:nAt,nPosDesPro]
						lRet := .F.
						Exit
					EndIf

					//Caso nao seja odonto, critica o procedimento                            
				Else
					lCritRepet := .T.

					// O cÛdigo de serviÁo poder· ser repetido, apenas quando o campo tipoTabela for igual a 
					// 20 (Medicamento TUSS) ou 00 (Medicamento TNUMM) e o tipo de anexo for igual a 1.
					If lPTUOn80
						If BR8->BR8_ANEEDI == "1" .And. (PtTpTabTus(,,.T.) == "20" .Or. PtTpTabTus(,,.T.,.T.) == "20")
							lCritRepet := .F.
						EndIf
					Else
						If BR8->BR8_ANEEDI == "1" .And. BR8->BR8_TPPROC == "2"
							lCritRepet := .F.
						EndIf
					EndIf

					//Guias de Quimioterapia permitem lancar o evento em sessao
					if cTipGui == G_ANEX_QUIM
						dDatPro := &("M->"+cAliIte+"_DATPRO")
						if nPosDatPro > 0 .And. oBrwPro:aCols[nX,nPosDatPro] <> dDatPro        
							lCritRepet := .F.
						endIf
					endIf

					If lCritRepet 
						Aviso( 	STR0028,; //Criticas
						STR0404,; //Este procedimento j· foi adicionado.
						{STR0146}, 2 )

						//Quando o usuario usa a tecla ESC, apos digitar um codigo de procedimento que ja exista a descricao ja esta atualizada, entao preciso retornar a descricao que esta na linha da getDados.

						M->&(cAliIte+"_DESPRO") := oBrwPro:aCols[oBrwPro:oBrowse:nAt,nPosDesPro]
						lRet := .F.
						Exit
					EndIf
				EndIf

			EndIf

		Next nX
	EndIf
EndIf

//Se Reembolso, verifica  se procedimento esta na liberaÁ„o e e negado    
//total ou parcial (Nega Participacao (detalhes do procedimento)          
//se ok, libera digitacao, caso contrario, informa a critica ao usuario   
//RDS (29/11/2010)														
If lRet .And. cTipGui == G_REEMBOLSO .And. B44->(FieldPos("B44_NUMLIB")) > 0
	lRet:= PLSAB44LIB(M->B44_NUMLIB,M->B45_CODPAD,M->B45_CODPRO)
Endif

If lRet .And. GetNewPar("MV_PLSLIBE","0") == "1" .And. (cTipGui $ G_SADT_ODON .Or. cAliCab == "B01") .And. ! Empty(M->B01_NUMLIB)
	PLSAB02LIB(M->B01_NUMLIB,M->BE2_CODPAD,M->BE2_CODPRO)
EndIf

//Valida o pacote x procedimento do pacote
If GetNewPar("MV_PLSDTPG",.F.) .And. ( (Type("M->BE1_NUMLIB") == "C" .And. Empty(M->BE1_NUMLIB) ) .Or. ( Type("M->B01_NUMLIB") == "C" .And. Empty(M->B01_NUMLIB) ) )
		lNegProPac := PLSVLDINP(__cTipo,cPadPro,oEncAut,oBrwPro,oBrwCri,cAliCab,cAliIte,cAliCri,aDadB43,aCabB43,aTrbB43)
	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} PLSA090SOL

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
Function PLSA090SOL()
	LOCAL lRet := .F.
	LOCAL aProg     := PlsRetAut()
	LOCAL cAlias 	:= aProg[2]
	Local aRetQry
	Local cQuery1
	Local cQuery2
	LOCAL nRegBAU   := BAU->(Recno())
	LOCAL nOrdBAU   := BAU->(IndexOrd())
	LOCAL nRegBAW   := BAW->(Recno())
	LOCAL nOrdBAW   := BAW->(IndexOrd())
	LOCAL aRetBAW   := {}
	LOCAL lExDATPRO := .F.
	LOCAL aAreaSX3  := {}
	LOCAL aProfs    := {}
	LOCAL lGrdExe 	:= .f.

	If cAlias=="BE1" .AND. EMPTY(&("M->"+cAlias+"_REGSOL"))
		&("M->"+cAlias+"_NOMSOL") := ""
		&("M->"+cAlias+"_CDPFSO") := ""
		&("M->"+cAlias+"_ESTSOL") := ""
		Return .T.
	EndIf
//M->BE1_ESTSOL esta com o valor errado 
aRetQry := PLSRQCon("BD6_CODPAD","BD6_CODPRO")
//&("M->"+cAlias+"_ESTSOL") := M->BE1_ESTEXE
cQuery1 := aRetQry[1]
cQuery2 := aRetQry[2]

If Type("M->B4B_UFCONS") <> 'U'
	BB0->(DbSetOrder(4)) //BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
	lRet := BB0->(MsSeek(xFilial("BB0")+&("M->B4B_UFCONS")+  PadR( &("M->B4B_NUCONS") , TamSX3( "BB0_NUMCR" )[ 1 ] ) +&("M->B4B_SICONS")))
	while !BB0->(Eof()) .and. xFilial("BB0")+&("M->B4B_UFCONS")+&("M->B4B_NUCONS")+&("M->B4B_SICONS") ==;
	BB0->(BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG)

		aadd(aProfs,{BB0->(Recno()),BB0->BB0_CODIGO})
		BB0->(DbSkip())
	Enddo

	lGrdExe := .t. //significa que estou no novo grid dos executantes na tela de SDAT ou na tela de HONORARIO INDIVIDUAL

ElseIf Type("M->"+cAlias+"_ESTSOL") <> 'U'

	BB0->(DbSetOrder(4)) //BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
	lRet := BB0->(MsSeek(xFilial("BB0")+&("M->"+cAlias+"_ESTSOL")+&("M->"+cAlias+"_REGSOL")+&("M->"+cAlias+"_SIGLA")))
	while !BB0->(Eof()) .and. xFilial("BB0")+&("M->"+cAlias+"_ESTSOL")+&("M->"+cAlias+"_REGSOL")+&("M->"+cAlias+"_SIGLA") ==;
	BB0->(BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG)

		aadd(aProfs,{BB0->(Recno()),BB0->BB0_CODIGO})
		BB0->(DbSkip())
	Enddo
Endif

If !lRet .and. Funname() <>"PLSAGHI"

	If Type("M->"+cAlias+"_ESTSOL") <> 'U' .And. !Empty(&("M->"+cAlias+"_ESTSOL"))
		BB0->(DbSetOrder(4))
		lRet := BB0->( MsSeek( xFilial("BB0")+&("M->"+cAlias+"_ESTSOL")+&("M->"+cAlias+"_REGSOL")))
	Else 
		BB0->(DbSetOrder(7))
		lRet := BB0->( MsSeek( xFilial("BB0")+&("M->"+cAlias+"_REGSOL")))
	EndIf
	aadd(aProfs,{BB0->(Recno()),BB0->BB0_CODIGO})
EndIf

If Len(aProfs) > 0
	BB0->(DbGoTo(aProfs[1][1]))
Endif
If lRet
	If Type("M->"+cAlias+"_NOMSOL") <> 'U' .AND. cAlias <> "B4F"
		&("M->"+cAlias+"_NOMSOL") := BB0->BB0_NOME
	Endif
	If Type("M->"+cAlias+"_CDPFSO") <> 'U'
		&("M->"+cAlias+"_CDPFSO") := BB0->BB0_CODIGO
	Endif
	If  Type("M->"+cAlias+"_CONREG") <> 'U'
		&("M->"+cAlias+"_CONREG") := BB0->BB0_NUMCR
	EndIf

	If  Type("M->"+cAlias+"_SIGLA") <> 'U' 
		&("M->"+cAlias+"_SIGLA") := BB0->BB0_CODSIG
	EndIf

	If  Type("M->"+cAlias+"_ESTSOL") <> 'U' 
		&("M->"+cAlias+"_ESTSOL") := BB0->BB0_ESTADO
	EndIf

	If  Type("M->B4B_NOMPRF") <> 'U'
		&("M->B4B_NOMPRF") := BB0->BB0_NOME
	EndIf
	If  Type("M->B4B_CDPFPR") <> 'U'
		&("M->B4B_CDPFPR") := BB0->BB0_CODIGO
	EndIf
	if type("M->B4B_CGC") <> "U"
		M->B4B_CGC :=  BB0->BB0_CGC
	endif
Endif

If !lRet
	Help("",1,"REGNOIS")
Else
	If cAlias == "BE1"
		aAreaSX3 := SX3->(GetArea())
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("BE1_DATPRO"))
			lExDATPRO := .T.
		EndIf
		SX3->(RestArea(aAreaSX3))
	Else
		lExDATPRO := &(cAlias + "->(FieldPos('" + cAlias + "_DATPRO'))") > 0
	EndIf

	If BB0->(FieldPos("BB0_CODBLO")) > 0 .AND. lExDATPRO
		lRet := A090CHEBLO(BB0->BB0_CODIGO,&("M->"+cAlias+"_DATPRO"),nil,aProfs)
		&("M->"+cAlias+"_NOMSOL") := BB0->BB0_NOME
		&("M->"+cAlias+"_CDPFSO") := BB0->BB0_CODIGO
		&("M->"+cAlias+"_ESTSOL") := BB0->BB0_ESTADO
		If  &(cAlias + "->(FieldPos('" + cAlias + "_CONREG'))") > 0
			&("M->"+cAlias+"_CONREG") := BB0->BB0_NUMCR
		EndIf
	EndIf

	If lRet
		BAU->(DbSetOrder(5))
		If BAU->(DbSeek(xFilial("BAU")+BB0->BB0_CODIGO))
			aRetBAW := PLSVldBAW(PLSINTPAD(),nil,nil,nil,nil,nil,nil,BAU->BAU_CODIGO)
			If ! aRetBAW[1]
				If !lGrdExe
					Aviso( "Solicitante",aRetBAW[2,1,1] + aRetBAW[2,1,2],{ STR0022 }, 2 ) //"Ok"
				Else
					Aviso( "Executante",aRetBAW[2,1,1] + aRetBAW[2,1,2],{ STR0022 }, 2 ) //"Ok"
					Endif
					lRet := .F.
				Endif
			Endif
		Endif
	Endif

	BAU->(DbGoTo(nRegBAU))
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRegBAW))
	BAU->(DbSetOrder(nOrdBAW))

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090DAT

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090DAT(cTp,lAutoma)
	local lRet  := .t.
	local aRet	:= {}

	Default lAutoma := .F.

	default cTp := "" // RDA "1" // USUARIO "2" // "" AMBOS

if (!empty(M->BE1_CODRDA) .and. !empty(M->BE1_DATPRO)) .and. (cTp == "" .or. cTp == "1")
	lRet := PLSA090RDA(M->BE1_OPERDA,M->BE1_CODRDA,"1",M->BE1_DATPRO,M->BE1_USUARI,M->BE1_CODLOC,M->BE1_CODESP,"BE1")
endIf

if (lRet .and. !empty(M->BE1_USUARI) .and. !empty(M->BE1_DATPRO)) .and. (cTp == "" .or. cTp == "2")
	If !lAutoma
		lRet := PLSA090USR(M->BE1_USUARI,M->BE1_DATPRO,M->BE1_HORPRO,"BE1",,,,,,,,,,,,,,,,,,,.T.) 
	Else
		aRet := PLSA090USR(M->BE1_USUARI,M->BE1_DATPRO,M->BE1_HORPRO,"BE1",,.T.,,,,,,,,,,,,,,,,,.T.) //mandando lRPC = .T. para nao apresentar elementos visuais.
		return (aRet)
	EndIf
endIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A090PosArq

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function A090PosArq()

	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial("BA3")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC)))

BD5->(DbSetOrder(1))
BD5->(MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
BD6->(DbSetOrder(1))
BD6->(MsSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090REC

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090REC(lPos)
	LOCAL cChvSE1

If ! ( BEA->BEA_STATUS $ "1,2" .And. BEA->BEA_GUIACO == "1" )
	Aviso( STR0172, ; //"Recibo"
	STR0173,; //"Recibo nao pode ser emitida porque ainda nao foi gerado titulo a receber ou ainda nao foi baixado o titulo."
	{ STR0146 }, 2 ) 	                                                                     //"Ok"
	Return
Endif

If lPos
	A090PosArq()
Endif

SE1->(DbSetOrder(1))

If lBEANTit
	cChvSE1 := BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)
Else
	cChvSE1 := BEA->BEA_CHVSE1
Endif
If ! SE1->(MsSeek(xFilial("SE1")+cChvSE1))
	Help("",1,"PLSA090RC1")
	Return
Endif

If SE1->E1_SALDO > 0
	Help("",1,"PLSA090RC2")
	Return
Endif

If ! ExistBlock("PLSA090REC")
	PLSR735()
Else
	ExecBlock("PLSA090REC",.F.,.F.)
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A090INTGER

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function A090INTGER(cAliasEnc)
	LOCAL aRetIntEve := PLSA235(.F.,"",.T.)
If FunName() == "TMKA271"
	M->BE1_DATPRO := dDataBase
	M->BE1_HORPRO := StrTran(Time(),":","")
Endif

If aRetIntEve[1]
	&("M->"+cAliasEnc+"_USUARI") := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

	PLSA090USR(&("M->"+cAliasEnc+"_USUARI"),&("M->"+cAliasEnc+"_DATPRO"),&("M->"+cAliasEnc+"_HORPRO"),"B01")
	lRefresh := .T.
Else
	If Len(aRetIntEve) >= 2 .And. Len(aRetIntEve[2]) > 0
		PLSMOVCRI("2",{},aRetIntEve[2])
		Endif
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090F3S

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090F3S()
	LOCAL aDados := {}
	LOCAL aCabec := { {STR0126,"@C",40} , {STR0127,"@C",200 } } //"Codigo"###"Descricao"
LOCAL nFor		:= 0
LOCAL aRet		:= {}
LOCAL lOK := .F.
LOCAL aProg     := PlsRetAut()
LOCAL cAlias 	:= aProg[1]
LOCAL cAliIte 	:= aProg[3]

if cAlias == "01" // odonto
	oBrwPro := PlGeObrPro()
elseif cAlias == "07" // anexos
	oBrwPro := PAGeObrPro()
Elseif cAlias == "03" // reembolso
	oBrwPro := Pl001ROp()
endif

For nFor := 1 To Len(oBrwPro:aCols)
	If !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1] .And. !Empty(oBrwPro:FieldGet(cAliIte+"_CODPRO",nFor))
		aadd(aDados,{oBrwPro:FieldGet(cAliIte+"_CODPRO",nFor),oBrwPro:FieldGet(cAliIte+"_DESPRO",nFor)})
	Endif
Next

If Len(aDados) == 0
	Help("",1,"PLSA090FE2")
	Return(lOK)
Endif

aRet := PLSCRIGEN(aDados,aCabec,STR0174,.F.) //"Selecione o Procedimento"

If aRet[1]
	BR8->(DbSetOrder(1))
	lOK := BR8->(MsSeek(xFilial("BR8")+&("M->"+cAliIte+"_CODPAD")+aDados[aRet[2],1]))
	Endif

Return(lOK)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090F3R

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090F3R()

	LOCAL nFor		:= 0
	LOCAL lRet := .F.
	LOCAL aProg     := PlsRetAut()
	LOCAL cTipo 	:= aProg[1]
	LOCAL cAliIte 	:= aProg[3]

	if cTipo == "01" // odonto
	oBrwPro := PlGeObrPro()
elseif cTipo == "07"
	oBrwPro := PAGeObrPro()
Elseif cTipo == "03" // reembolso
	oBrwPro := Pl001ROp()
endif

For nFor := 1 To Len(oBrwPro:aCols)
	If !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1] .And. ;
	! Empty(oBrwPro:FieldGet(cAliIte+"_CODPRO",nFor)) .And. ;
	oBrwPro:FieldGet(cAliIte+"_CODPRO",nFor) == &("M->"+cAliIte+"_PROREL")
		lRet := .T.
		Exit
	Endif
Next

If ! lRet
	Help("",1,"PLSA090FE3")
	Endif

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ExeQuest

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function ExeQuest()
	Local nX
	Local cSql 		:= ""
Local cChave 	:= ""
Local bOk 		:= {|| SetBAX(), PLSA530Mov("BXA",BXA->(Recno()),2,.F.,BA3->(Recno()))}
Private oBrwBXA
Private aRecBXA := {}

cSql := " SELECT * FROM " + RetSqlName("BXA")
cSql += " WHERE BXA_USUARI = '" + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) + "'"
cSql += " AND D_E_L_E_T_ = ' '"
cSql += " ORDER BY BXA_DATA"

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW Alias "PLSENT"

TcSetField("PLSENT","BXA_DATA","D")

If PLSENT->(Eof())
	PLSENT->(DbCloseArea())
	Help("",1,"PLSA090QUE")
	Return
Endif

// Cria Vetor com os resultados da query
While PLSENT->(!Eof())
	cChave := xFilial("BAM")+PLSENT->(BXA_PROQUE+BXA_CODQUE)

	aListAux := {PLSENT->BXA_DATA, PLSENT->BXA_NUMERO, PLSENT->BXA_CODQUE, AllTrim(Posicione("BAM", 1, cChave, "BAM_DESCRI"))}
	aadd(aRecBXA, aListAux)

	PLSENT->(DbSkip())
Enddo

DEFINE MSDIALOG oDlg FROM 0,0 TO 320,640 PIXEL TITLE "Entrevista Qualificada do Usu·rio"

// Cria objeto de fonte que sera usado na Browse
Define Font oFont Name 'Courier New' Size 0, -12

// Cria Browse
oBrwBXA := TCBrowse():New( 30 , 01, 320,147 ,,;
{"Data","N˙mero","Question·rio","DescriÁ„o"},{50,50,50,50},;
oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )

// Aponta o vetor com as informacoes da query
oBrwBXA:SetArray(aRecBXA)

// Monta a linha a ser exibina no Browse
oBrwBXA:bLine := {||{ aRecBXA[oBrwBXA:nAt,01],;
aRecBXA[oBrwBXA:nAt,02],;
aRecBXA[oBrwBXA:nAt,03],;
aRecBXA[oBrwBXA:nAt,04]}}

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BXA_DATA","BXA_NUMERO","BXA_CODQUE","BAM_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrwBXA:aObfuscatedCols := aBls
	endif


// Evento de DuploClick
	oBrwBXA:bLDblClick := bOk

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,{ || oDlg:End() },.F.)

	PLSENT->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBAX

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function SetBAX()

	BXA->(DbSetOrder(1))//BXA_FILIAL+BXA_NUMERO
BXA->(DbSeek(xFilial("BXA")+aRecBXA[oBrwBXA:nAt,2]))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSANAINT
Quando o usuario for de outra operadora e esta estiver   
online esta funcao executa a comunicacao com a outra oper.

@author  PLS TEAM
@version P11
@since   01.08.06
/*/
//-------------------------------------------------------------------
Function PLSANAINT(aDados,aCodsProc,cAliasCab,lWeb,lReqOrdSer,lUseTran,cObsEvo,cTranUsada,aQuimio,aRadio,aAuto)
	LOCAL nFor2
	LOCAL nFor
	LOCAL cCodCri
	LOCAL cTpAut
	LOCAL cObs 		   := ""
LOCAL cTipReq 	   := Eval( { || nPos := Ascan(aDados,{|x| alltrim(x[1]) == "CTIPREQ"}), If(nPos>0,aDados[nPos,2],"0") })
LOCAL cTranOri     := "0000000001"
LOCAL aRet         := {}
LOCAL aRetOln      := {}
LOCAL aRetBTU      := {}
LOCAL cNumTDes     := ""
LOCAL cNomUsr      := ""
LOCAL cMatAnt 	   := ""
LOCAL aCriticas    := {}
LOCAL cAutori  	   := "3"
LOCAL lOK    	   := .F.
LOCAL lNeg         := .F.
LOCAL nQtd		   := 0
LOCAL lAltor	   := .F.
LOCAL cAudit	   := "0"
LOCAL cInsist	   := "0"
LOCAL lRet		   := .T.
LOCAL lEnvia	   := .F.
LOCAL aGrvTraPTU   := {}
LOCAL aPtuIteBkp   := {}
LOCAL aPlPtuIte    := {}
LOCAL lExitTran    := .F.
LOCAL aAreaBEA     := {}
LOCAL cTipAcomod   := ""
LOCAL cValidAut    := ""
LOCAL cIndClin     := ""
LOCAL lAuditOS     := .F.
LOCAL nPosObser1   := 0 
LOCAL cMsgXsdErr   := ""
LOCAL lEncMsg      := .F.
LOCAL cDesCm       := ""
LOCAL nPosEvePTU   := 0
LOCAL lExBLPLP     := ExistBlock("PLPTUITE")
LOCAL lParPTUTA    := GetMV("MV_PTUTAB2",.T.)
LOCAL cParPLSTB    := SubStr( GETMV("MV_PLSTBPD") ,1,2)
LOCAL aCodCriIte   := {}
LOCAL lPTUOn80     := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
LOCAL lPTUOn90     := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
Local cNomeSocial  := ""
DEFAULT cAliasCab  := "BE1"
DEFAULT lWeb	   := .T.
DEFAULT lReqOrdSer := .F.
DEFAULT lUseTran   := .F. //Este parametro nao e mais utilizado, mas mantive pelo legado da passagem de parametros
DEFAULT cObsEvo    := ""
DEFAULT cTranUsada := ""
DEFAULT aQuimio    := {}
DEFAULT aRadio     := {}
DEFAULT aAuto      := {.F.,""}

aAreaBEA := BEA->(GetArea())

//Implementacao dos campos para transacao									

If cTipReq == "0" .And. !PlsPtuGet("CD_TRANS",aDados) == "00405" .And. Empty(cTranUsada)
	If PLSALIASEX("BSN")

		cTranOri := StrZero( Val( BSN->(GetSx8Num("BSN","BSN_SEQUEN") ) ),10)
		BSN->(ConfirmSX8())

		SIX->(DbSetOrder(1))
		If SIX->( MsSeek("BEAM") )
			BEA->(DbSetOrder(22))//BEA_FILIAL + BEA_NRTROL
			If BEA->(DbSeek(xFilial("BEA")+cTranOri+Space( TamSX3("B0S_NUMSEQ")[1]-Len(cTranOri))+PlsIntPad()))
				While !lExitTran
					cTranOri := Strzero(val(cTranOri)+1,10)
					If !BEA->(DbSeek(xFilial("BEA")+cTranOri))
						lExitTran := .T.
					EndIf
				EndDo
			EndIf
		EndIf

		BSN->(RecLock("BSN",.T.))
		BSN->BSN_FILIAL := xFilial("BSN")
		BSN->BSN_SEQUEN := cTranOri
		BSN->(MsUnLock())

		cLastTran := cTranOri

	Endif
Else
	cTranOri := cTranUsada 
	cLastTran := cTranOri
EndIf

//Alimenta as variaveis do layout atravez da propria matriz adados padrao 
//plsxmov																	

Do Case
	//Se for um envio															
	Case PlsPtuGet("CD_TRANS",aDados) == "00600" .Or. PlsPtuGet("CD_TRANS",aDados) == "00605"

		PlsPtuPut("NR_IDENT_O",cTranOri,aDados)    								//Numero da Transacao
		If lPTUOn80
			PlsPtuPut("ID_BENEF",PadL(PlsPtuGet("USUARIO",aDados),13,"0"),aDados)			
		Else
			PlsPtuPut("ID_BENEF",PlsPtuGet("USUARIO",aDados),aDados)
		EndIf
		If !lPTUOn90
			PlsPtuPut("NR_VIA_CAR",PlsPtuGet("VIACAR",aDados),aDados)				//Numero da via do cartao inf., se = a 00 trata-se de cart. ou disp. a			
		EndIf

		PlsPtuPut("CD_CID",PLSDELIM(PlsPtuGet("CIDPRI",aDados)),aDados)		//Numero do Cædigo Internacional da Doenca.

		If Type(cAliasCab+"_MSG01") <> "U" .And. Type(cAliasCab+"_MSG02") <> "U"
			cObs := Alltrim(&("M->"+cAliasCab+"_MSG01"))+" "+Alltrim(&("M->"+cAliasCab+"_MSG02"))

			//Mensagem 3 - SADT
			if cAliasCab == "BE1" .And. BEA->(FieldPos("BEA_MSG08")) > 0 .And. Type(cAliasCab+"_MSG08") <> "U"  
				cObs += " " + Alltrim(&("M->"+cAliasCab+"_MSG08"))
			endIf             

			//Mensagem 3 - Internacao
			if cAliasCab == "BE4" .And. BE4->(FieldPos("BE4_MSG08")) > 0 .And. Type(cAliasCab+"_MSG08") <> "U"  
				cObs += " " + Alltrim(&("M->"+cAliasCab+"_MSG08"))
			endIf      

			//Mensagem 4 - SADT
			if cAliasCab == "BE1" .And. BEA->(FieldPos("BEA_MSG09")) > 0 .And. Type(cAliasCab+"_MSG09") <> "U"  
				cObs += " " + Alltrim(&("M->"+cAliasCab+"_MSG09"))
			endIf   

			//Mensagem 4 - Internacao
			if cAliasCab == "BE4" .And. BE4->(FieldPos("BE4_MSG09")) > 0 .And. Type(cAliasCab+"_MSG09") <> "U"  
				cObs += " " + Alltrim(&("M->"+cAliasCab+"_MSG09"))
			endIf  

			cObs := Alltrim(Substr(cObs,1,999))
		EndIf

		If !Empty(cObsEvo)
			PlsPtuPut("DS_LINHA_O",PTURemChr(cObsEvo),aDados)										//Observacao.
		Else
			PlsPtuPut("DS_OBSERVA",PTURemChr(cObs),aDados)										//Observacao.
		EndIf
		IF PlsPtuGet("CD_TRANS", aDados) == "00605"	//	ObservaÁıes das ProrrogaÁıes
			cObs := ""
			FOR nFor := 1 TO LEN(aCodsProc)
				nPosObser1 := ASCAN(aCodsProc[nFor],{|x| x[1] == "OBSER1BQV"})
				If nPosObser1 > 0  
					cIndClin := ALLTRIM(aCodsProc[nFor, nPosObser1, 2])
				EndIf
				IF !EMPTY(cIndClin)
					cObs += IIF(LEN(cObs) > 1, "// ", "") + cIndClin		//	Insere o campo ObservaÁ„o(BQV_OBSER1) de cada procedimento
				ENDIF
			NEXT
			cIndClin := ""
			PlsPtuPut("DS_OBSERVA", cObs, aDados)
		ENDIF
		IF PlsPtuGet("CD_TRANS", aDados) == "00605"	//	Indicacao clinica da Prorrogacao
			If !lWeb .And. Empty (cIndClin)
				FOR nFor := 1 TO LEN(aCodsProc)
					nPosIndCl := ASCAN(aCodsProc[nFor],{|x| x[1] == "INDCLIEVO"})
					If nPosIndCl > 0  
						cIndClin := PTURemChr(ALLTRIM(aCodsProc[nFor, nPosIndCl, 2]))
					EndIf
				NEXT
			ElseIf lWeb .And. Empty (cIndClin)
				FOR nFor := 1 TO LEN(aCodsProc)
					nPosIdCl := ASCAN(aCodsProc[nFor],{|x| x[1] == "DS_IND_CLI"})
					If nPosIdCl > 0  
						cIndClin := PTURemChr(ALLTRIM(aCodsProc[nFor, nPosIdCl, 2]))
					EndIf
				NEXT	
			EndIf	
			PlsPtuPut("DS_IND_CLI", cIndClin, aDados)
		ENDIF

		//Verifica codigo Edi da Especialidade

		If !lPTUOn90
			DbSelectArea("BAQ")
			BAQ->(DbSetOrder(1))//BAQ_FILIAL+BAQ_CODINT+BAQ_CODESP
			If BAQ->(DbSeek(xFilial("BAQ")+PlsIntPad()+PlsPtuGet("CODESP",aDados))) .And. BAQ->(FieldPos("BAQ_INTERC")) > 0
				PlsPtuPut("CD_ESPEC",BAQ->BAQ_INTERC,aDados)//Codigo da Especialidade Medica.
			Else
				PlsPtuPut("CD_ESPEC",PlsPtuGet("CODESP",aDados),aDados)//Codigo da Especialidade Medica.
			EndIf
		EndIf

		If Type(cAliasCab+"_INDCLI") <> "U" .And. Type(cAliasCab+"_INDCL2") <> "U" .And. Empty(cIndClin)
			cIndClin := PTURemChr(AllTrim(&("M->"+cAliasCab+"_INDCLI"))+" "+AllTrim(&("M->"+cAliasCab+"_INDCL2")))
			PlsPtuPut("DS_IND_CLI",cIndClin,aDados)   	//Linha de dados da Unimed Origem.
		EndIf

		//Usado no xmov guardano no bsa

		If Type(cAliasCab+"_CODRDA") <> "U"
			PlsPtuPut("CODRDA",&("M->"+cAliasCab+"_CODRDA"),aDados)        		//Codigo da Rda
		EndIf
		If Type(cAliasCab+"_CDPFSO") <> "U"
			PlsPtuPut("CDPFSO",&("M->"+cAliasCab+"_CDPFSO"),aDados)	    		//Codigo do Solicitante
		EndIf

	//Requisicao de Ordem de Servico
	Case PlsPtuGet("CD_TRANS",aDados) == "00806"

		//Se ja existir a senha utiliza, senao gera uma senha para a transacao

		If Empty(&("M->"+cAliasCab+"_SENHA"))
			&("M->"+cAliasCab+"_SENHA") := PLSSenAut(dDataBase)
		EndIf

		If Type(cAliasCab+"_MSG01") <> "U" .And. Type(cAliasCab+"_MSG02") <> "U"
			cObs := &("M->"+cAliasCab+"_MSG01")+" "+&("M->"+cAliasCab+"_MSG02")
		EndIf
		PlsPtuPut("DS_OBSERVA",cObs,aDados)
		
		If !lPTUOn90
			PlsPtuPut("NR_VIA_CAR",PlsPtuGet("VIACAR",aDados),aDados)
		endif

		If Type(cAliasCab+"_INDCLI") <> "U" .And. Type(cAliasCab+"_INDCL2") <> "U"
			cIndClin := PTURemChr(AllTrim(&("M->"+cAliasCab+"_INDCLI"))+" "+AllTrim(&("M->"+cAliasCab+"_INDCL2")))
			PlsPtuPut("DS_IND_CLI",cIndClin,aDados)   	//Linha de dados da Unimed Origem.
		EndIf

		PlsPtuPut("NR_TRANS_S",Strzero(Val(&("M->"+cAliasCab+"_SENHA")),10),aDados)
		PlsPtuPut("CD_UNI_SOL",&("M->"+cAliasCab+"_OPESOL"),aDados)

		If !lPTUOn90 .And. !Empty(&("M->"+cAliasCab+"_REGSOL"))

			PlsPtuPut("NR_CONS_PR",Strzero(Val(&("M->"+cAliasCab+"_REGSOL")),15),aDados)
			PlsPtuPut("UF_CONS_PR",Alltrim(&("M->"+cAliasCab+"_ESTSOL")),aDados)
			PlsPtuPut("SG_CONS_PR",Alltrim(&("M->"+cAliasCab+"_SIGLA")),aDados)

			BB0->(DbSetOrder(4))//BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
			If BB0->(DbSeek(xFilial("BB0")+Padr(Alltrim(&("M->"+cAliasCab+"_ESTSOL")),(TamSX3("BB0_ESTADO")[1]))+;
			Padr(Alltrim(&("M->"+cAliasCab+"_REGSOL")),(TamSX3("BB0_NUMCR")[1]))+;
			Padr(Alltrim(&("M->"+cAliasCab+"_SIGLA")),(TamSX3("BB0_CODSIG")[1]))))
				PlsPtuPut("NM_PREST",Padr(BB0->BB0_NOME,40),aDados)
			EndIf

		EndIf    

		PlsPtuPut("NR_IDENT_B",cTranOri,aDados)
		PlsPtuPut("NR_IDENT_S",cTranOri,aDados)

EndCase

//Utiliza o PE PLPPTUITE para trocar os codigos de servico	
//Retorna o De-Para realizado AMB/CBHPM    							    
For nFor := 1 To Len(aCodsProc)

	If lExBLPLP
		aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),"ENVENT","",PlsPtuGet("TP_TABELA",aCodsProc[nFor]),nil,cTranOri,aPtuIteBkp})
		nPosEvePTU := Ascan(aCodsProc[nFor],{|x|x[1] == "CD_SERVICO"})
		aCodsProc[nFor][nPosEvePTU][2] := allTrim(aPlPtuIte[2])
	Else
		// De-para pela tabela BTU (Terminologia TISS)
		If lPTUOn80 
			aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),PlsPtuGet("CODPAD",aCodsProc[nFor]),,.T.,.T.)
			
			If len(aRetBTU) > 0
				aCodsProc[nFor][2][2] := allTrim(aRetBTU[2])
			EndIf

		Else 
			If lParPTUTA

				PLBusProTab(aCodsProc[nFor][2][2],.F.,,,.T.,,,GetNewPar("MV_PTUTAB2","02"),cParPLSTB )

				If BR8->(Found())
					aCodsProc[nFor][2][2] := allTrim(BR8->BR8_CODPSA)
				EndIf

			elseIf GetNewPar("MV_PTDPION","0") == "1"

				PLBusProTab(aCodsProc[nFor][2][2],.F.,,dDatPro,,,,,)

				if BR8->(Found())
					aCodsProc[nFor][2][2] := allTrim(BR8->BR8_CODPSA)
				EndIf

			elseIf GetNewPar("MV_PTDPION","0") == "2"

				aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),,.T.,)

				If len(aRetBTU) > 0
					aCodsProc[nFor][2][2] := allTrim(aRetBTU[2])
				EndIf

			endIf
		EndIf
	endIf
next		

//Verifica nome do usuario para gravar arquivo para possivel reenvio   	 
If !lReqOrdSer
	BA1->(DbSetOrder(5))//BA1_FILIAL+BA1_MATANT+BA1_TIPANT
	If BA1->(DbSeek(xFilial("BA1")+PlsPtuGet("CD_UNI_DES",aDados)+PlsPtuGet("USUARIO",aDados)))
		cNomUsr := BA1->BA1_NOMUSR
	Endif
Else
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If BA1->(DbSeek(xFilial("BA1")+PlsPtuGet("CD_UNI",aDados)+PlsPtuGet("ID_BENEF",aDados)))
		cNomUsr := BA1->BA1_NOMUSR
	Endif
EndIf

//Comunicacao e tratamento												
aGrvTraPTU := {AllTrim(cTranOri),PlsPtuGet("CD_TRANS",aDados),PlsPtuGet("OPEMOV",aDados),PlsPtuGet("CD_UNI_DES",aDados),cNomUsr,aQuimio,aRadio}

If ExistBlock("PL090ACOM")
	aRetCom := ExecBlock("PL090ACOM",.F.,.F., {aDados,aCodsProc})

	If ValType (aRetCom) == "A"	
		aDados	   := aRetCom[1]
		aCodsProc  := aRetCom[2]
	EndIf
Endif

If lWeb
	aRetOln := PlsPtuOln(aDados,aCodsProc,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,lWeb,aGrvTraPTU,aQuimio,aRadio,@cMsgXsdErr,aAuto)
Else
	MsAguarde( {|| aRetOln := PlsPtuOln(aDados,aCodsProc,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,lWeb,aGrvTraPTU,aQuimio,aRadio, @cMsgXsdErr ) }, 'Comunicando' , STR0177, .F.) //"Aguarde..."
EndIf

//Verifica se houve retorno 00210/00310 (falha na transacao)     			 
If (Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310") .Or. Len(aRetOln) == 0 

	// Se aRetOln vazio, forco o comunica para gravar a guia e grava-la bloqueada - Solicitacao Vale do Sinos
	If Len(aRetOln) == 0
		lComunica := .T.
	EndIf

	//Ponto de Entrada									
	If ExistBlock("PLS090PT")
		ExecBlock("PLS090PT",.F.,.F.,{aDados,aCodsProc,lOK} )
	EndIf

	//Avaliando retorno da solicitacao de Exame
	aCriticas := {}

	For nFor:= 1 to Len(aCodsProc)

		//Utiliza o PE PLPPTUITE para trocar os codigos de servico	
		//Retorna o De-Para realizado AMB/CBHPM    							    
		if lExBLPLP
			aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),"ENVENT","",PlsPtuGet("TP_TABELA",aCodsProc[nFor]),nil,cTranOri,aPtuIteBkp})
			nPosEvePTU := Ascan(aCodsProc[nFor],{|x|x[1] == "CD_SERVICO"})
			aCodsProc[nFor][nPosEvePTU][2] := allTrim(aPlPtuIte[2])
		Else
			// De-para pela tabela BTU (Terminologia TISS)
			If lPTUOn80
				If PlsPtuGet("TP_TABELA",aCodsProc[nFor]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_ORI",aDados)) 
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),Alltrim(GetNewPar("MV_PLPACPT")),,.T.,,.T.)
				Else
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),,.T.,,.T.)
				EndIf
				If len(aRetBTU)>0
					aCodsProc[nFor][3][2] := allTrim(aRetBTU[2])
				EndIf
			Else 
				If lParPTUTA

					PLBusProTab(aCodsProc[nFor][2][2],.F.,,,.T.,,,GetNewPar("MV_PTUTAB2","02"),cParPLSTB )

					If BR8->(Found())
						aCodsProc[nFor][2][2]:=Alltrim(BR8->BR8_CODPSA)
					EndIf

				elseIf GetNewPar("MV_PTDPION","0") == "1"

					PLBusProTab(aCodsProc[nFor][2][2],.F.,,dDatPro,,,,,)

					If BR8->(Found())
						aCodsProc[nFor][2][2] := allTrim(BR8->BR8_CODPSA)
					Endif

				elseIf GetNewPar("MV_PTDPION","0") == "2"

					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),,.T.,)

					If len(aRetBTU)>0
						aCodsProc[nFor][2][2] := allTrim(aRetBTU[2])
					EndIf

				EndIf
			EndIf
		endIf

		//Replica informacao pois na transacao 00507/00607 o registro e diferente 
		PlsPtuPut("ID_AUTORIZ","1",aCodsProc[nFor])

		// Pega o tipo de autorizacao												
		cTpAut   := "1"
		cAutori  := "3"

		// Mostra o procedimento													
		PLSPtuLog( STR0189 + " ->"+PlsPtuGet("CD_SERVICO",aCodsProc[nFor])+" - "+Iif(cTpAut=="2","AUTORIZADO",Iif( cTpAut=="1","NEGADO","PENDENDE DE AUDITORIA" ) ) ) //"ANALISANDO ITEM "

		// Seta como nao autorizado
		lOK := .F.

		//Seta item negado
		lNeg := Iif(PlsPtuGet("ID_AUTORIZ",aCodsProc[nFor])=="1",.T.,.F.)

		If ! Empty(cMsgXsdErr) .And. upper(substr(cMsgXsdErr,1,11)) == "ERRO LAYOUT"  

			If ! Empty(cMsgXsdErr)   

				cMsgPtu:= IIF(len(upper(allTrim(Substr(cMsgXsdErr,12,4))))>3,UPPER(Substr(cMsgXsdErr,12,4)),UPPER(Substr(cMsgXsdErr,13,4)))

				BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
				If ! Empty(cMsgPtu) .and. BCT->(DbSeek(xFilial("BCT")+PlsIntPad() + cMsgPtu)) 

					cCodCri := cMsgPtu
					lEncMsg := .T. 
					cDesCm  := Posicione("SX5",1,xFilial("SX5")+"CM"+BCT->BCT_CODED2,"X5_DESCRI")

					If Empty(cDesCm)
						cDesCm := BCT->BCT_DESCRI 
						cCodCri:= BCT->BCT_PROPRI + BCT->BCT_CODGLO
					EndIf

				EndIf

			EndIf

			If ! lEncMsg
				PLSPOSGLO(PLSINTPAD(),	__aCdCri228[1],	__aCdCri228[2])
				cCodCri := 	__aCdCri228[1]
			EndIf

		Else

			BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
			If len(aRetOln) > 0 .And. BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
				cCodCri := PlsPtuGet("CD_MENS_EX",aRetOln[1])
			Else
				//Posiciona em timeout
				PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
				cCodCri := __aCdCri065[1] //Critica de time-out
			Endif

		EndIf

		AaDd( aCriticas,{ cCodCri,IIF(lEncMsg,cDesCm,PLSBCTDESC()),PlsPtuGet("CD_SERVICO",aCodsProc[nFor]) } )

		//"CRITICA"
		PlsPtuPut("CD_MENS_E1",cCodCri,aCodsProc[nFor])
		PLSPtuLog( STR0181 + cCodCri + " - " + PLSBCTDESC() )

	Next 

	If !lWeb 
		If !Empty(cMsgXsdErr)
			MsgInfo(cMsgXsdErr)
		ElseIf GetNewPar("MV_PTGLOBO","1") == "1"    
			Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
		EndIf	
	EndIf

	AaDd(aRet,{cAutori,aCodsProc,aCriticas,cTranOri,cNumTDes,cObs,cTipAcomod,""} )

	//Trata o Retorno da Comunicacao											

ElseIf Len(aRetOln) > 0
	If Len(aCodsProc) <> Len(aRetOln[2]) .Or. Len(aRetOln[2]) == 0

		AaDd(aRet,{cAutori,aCodsProc,{ { "XXX",STR0178,"" } } ,"","","","",""})	//"Inconsistencia no RETORNO"


		If !lWeb
			Aviso( STR0120,STR0179,{ STR0146 }, 2 )  			   			    //"Atencao" //"Inconsistencia no retorno!" //"Ok"
		EndIf

		Return(aRet)
	EndIf

	//Gravacao do arquivo de solicitacoes de ptu online BSA

	PLSGrvIEOL(aDados,aCodsProc,cTranOri)

	//Implementa matriz													   

	aDados    := aClone(aRetOln[1])
	aCodsProc := aClone(aRetOln[2])

	//Para a autorizacao														|

	cNumTDes := PlsPtuGet("NR_IDENT_D",aDados)
	cObs     := PlsPtuGet("DS_LINHA_O",aDados)
	cValidAut:= PlsPtuGet("DT_VALIDAD",aDados)

	//Para atualizar o usuario													|

	cNomUsr 	:= UPPER(PlsPtuGet("NM_BENEF",aDados))
	cMatAnt  := PlsPtuGet("CD_UNI",aDados)+PlsPtuGet("ID_BENEF",aDados)

	If lPTUOn90
		cNomeSocial := Upper(PlsPtuGet("NM_NOMSOC", aDados))
	EndIf

	//Posiciona																
	If !lReqOrdSer .And. GetNewPar("MV_PLNOMPT","1") == "1"
		BA1->( DbSetOrder(5) ) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
		If BA1->( MsSeek(xFilial("BA1")+cMatAnt) )

			//Atualiza																	|

			If (AllTrim(BA1->BA1_NOMUSR) <> AllTrim(cNomUsr)) .And. (Alltrim(UPPER(cNomUsr)) <> GetNewPar("MV_PLNOPT2",""))
				BA1->( RecLock("BA1",.F.) )
				BA1->BA1_NOMUSR	:= cNomUsr
				BA1->(MsUnLock())
			EndIf
		EndIf
	EndIf

	//Ponto de Entrada															|

	If ExistBlock("PLS090PT")
		ExecBlock("PLS090PT",.F.,.F.,{aDados,aCodsProc,lOK} )
	EndIf

	//Avaliando retorno da solicitacao de Exame								|

	aCriticas := {}

	For nFor := 1 To Len(aCodsProc)

		//Utiliza o PE PLPPTUITE para trocar os codigos de servico	
		//Retorna o De-Para realizado AMB/CBHPM    							    
		If lExBLPLP
			aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),"ENVENT","",PlsPtuGet("TP_TABELA",aCodsProc[nFor]),nil,cTranOri,aPtuIteBkp})
			nPosEvePTU := Ascan(aCodsProc[nFor],{|x|x[1] == "CD_SERVICO"})
			aCodsProc[nFor][nPosEvePTU][2] := allTrim(aPlPtuIte[2])
		Else
			// De-para pela Tabela BTU (Terminologia TISS)
			If lPTUOn80 
				If PlsPtuGet("TP_TABELA",aCodsProc[nFor]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_ORI",aDados))
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),Alltrim(GetNewPar("MV_PLPACPT")),,.T.,,.T.)
				Else
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),,.T.,,.T.)
				EndIf
				If len(aRetBTU)>0
					aCodsProc[nFor][3][2] := allTrim(aRetBTU[2])
				EndIf
			Else 
				If lParPTUTA

					PLBusProTab(aCodsProc[nFor][2][2],.F.,,,.T.,,,GetNewPar("MV_PTUTAB2","02"),cParPLSTB )

					If BR8->(Found())
						aCodsProc[nFor][2][2]:=Alltrim(BR8->BR8_CODPSA)
					EndIf

				elseIf GetNewPar("MV_PTDPION","0") == "1"

					PLBusProTab(aCodsProc[nFor][2][2],.F.,,dDatPro,,,,,)

					If BR8->(Found())
						aCodsProc[nFor][2][2] := allTrim(BR8->BR8_CODPSA)
					Endif

				elseIf GetNewPar("MV_PTDPION","0") == "2"

					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aCodsProc[nFor]),PlsPtuGet("CD_SERVICO",aCodsProc[nFor]),,.T.,)

					If len(aRetBTU)>0
						aCodsProc[nFor][2][2] := allTrim(aRetBTU[2])
					EndIf

				EndIf
			EndIf
		endIf

		//Replica informacao pois na transacao 00507/00607 o registro e diferente 

		If lReqOrdSer
			PlsPtuPut("ID_AUTORIZ",PlsPtuGet("ID_STATUS",aCodsProc[nFor]),aCodsProc[nFor])
		EndIf

		//Pega o tipo de autorizacao									

		cTpAut := PlsPtuGet("ID_AUTORIZ",aCodsProc[nFor])

		If cTpAut $ "34"
			lAuditOS := .T.
		EndIf
		//Mostra o procedimento													

		PLSPtuLog( STR0189 + " ->"+PlsPtuGet("CD_SERVICO",aCodsProc[nFor])+" - "+Iif(cTpAut=="2","AUTORIZADO",Iif( cTpAut=="1","NEGADO","PENDENDE DE AUDITORIA" ) ) ) //"ANALISANDO ITEM "

		//Se esta autorizado ou nao 1 - negada 2 - autorizado 3 - pendente

		If !lOk
			lOK := Iif(PlsPtuGet("ID_AUTORIZ",aCodsProc[nFor])=="2",.T.,.F.)
		EndIf

		//Verifica se ha item negado                                      

		If !lNeg
			lNeg := Iif(PlsPtuGet("ID_AUTORIZ",aCodsProc[nFor])=="1",.T.,.F.)
		EndIf

		//Mostra as criticas												
		aCodCriIte := {}
		For nFor2 := 1 To 5
			cCodCri := PlsPtuGet("CD_MENS_E"+AllTrim(Str(nFor2)),aCodsProc[nFor])
			
			If aScan(aCodCriIte,{|x|x[1] == cCodCri}) > 0
				loop
			Else	
				Aadd(aCodCriIte,{cCodCri})
			EndIf
			
			If Val(cCodCri) <> 0
				AaDd( aCriticas,{ cCodCri,PlsRtcdCed(PlsIntPad(),cCodCri,3),PlsPtuGet("CD_SERVICO",aCodsProc[nFor])+" - "+PlsPtuGet("DS_SERVICO",aCodsProc[nFor]) } )
				PLSPtuLog( STR0181 + cCodCri + " - " + PlsRtcdCed(PlsIntPad(),cCodCri,3) ) //"CRITICA"
			Endif
		Next
	Next

	//Msg																		|

	If lOk .And. Len(aCriticas) == 0 .And. !lNeg
		PlsPtuLog(STR0184)	//"*** AUTORIZADO ***"
		cAutori := "1"
	ElseIf lOk .And. (Len(aCriticas) > 0 .Or. lNeg)
		PlsPtuLog(STR0268)	//"*** AUTORIZADO PARCIAL ***"
		cAutori := "2"
	Else
		PLSPtuLog(STR0182)	//"CRITICAS ENCONTRADAS"
		PlsPtuLog(STR0188)	//"*** NAO AUTORIZADO ***"
		cAutori := "3"
	EndIf

	//Se versao 4.0 retorna o Tipo de Acomodacao   						   

	cTipAcomod := PlsPtuGet("TP_ACOMODA",aDados)

	aadd(aRet, {cAutori, aCodsProc, aCriticas, cTranOri, cNumTDes, cObs, cTipAcomod, cValidAut, cNomeSocial})

	if !lWeb .And. !lAuditOS .And. !Empty( &("M->"+cAliasCab+"_NRTROS") ) .And. ( &("M->"+cAliasCab+"_OPESOL") != Left(&("M->"+cAliasCab+"_MATANT"),4) .and. &("M->"+cAliasCab+"_OPESOL") != plsintpad() ) 

		cTranOri 	:= Alltrim(&("M->"+cAliasCab+"_NRTROS"))
		cTraPrest 	:= PlsPtuGet("NR_IDENT_O",aDados)
		cTraOriBen 	:= PlsPtuGet("NR_IDENT_D",aDados)
		cDatValid	:= PlsPtuGet("DT_VALIDAD",aDados)

		PTUAUTOSV5(aDados,aCodsProc,cTranOri,cTraPrest,cTraOriBen,cDatValid,&("M->"+cAliasCab+"_OPESOL"))

		endIf

	EndIf

	BEA->(RestArea(aAreaBEA))
Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090EXE

@author  PLS TEAM
@version P11
@since   11.11.06
/*/
//-------------------------------------------------------------------
Function PLSA090EXE()
	LOCAL lRet 		:= .t.
	LOCAL aProg     := PlsRetAut()
	LOCAL cAlias 	:= aProg[2]
	LOCAL aRetBAW   := {}
	LOCAL nRegBAU   := BAU->(Recno())
	LOCAL nOrdBAU   := BAU->(IndexOrd())
	LOCAL nRegBAW   := BAW->(Recno())
	LOCAL nOrdBAW   := BAW->(IndexOrd())
	LOCAL aProfs	:= {}

	If cAlias=="BE1" .AND. EMPTY(&("M->"+cAlias+"_REGEXE"))
	&("M->"+cAlias+"_NOMEXE") := ""
	&("M->"+cAlias+"_CDPFRE") := ""
	&("M->"+cAlias+"_ESTEXE") := ""
	Return .T.
EndIf

BB0->(DbSetOrder(4)) //BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
If cAlias=="B44" .and. B44->(FieldPos("B44_SIGEXE")) > 0
	lRet := BB0->( MsSeek( xFilial("BB0")+&("M->"+cAlias+"_ESTEXE")+&("M->"+cAlias+"_REGEXE")+&("M->"+cAlias+"_SIGEXE")+&("M->"+cAlias+"_OPEEXE") ) )
	While BB0->(!Eof()) .and. xFilial("BB0")+&("M->"+cAlias+"_ESTEXE")+&("M->"+cAlias+"_REGEXE")+&("M->"+cAlias+"_SIGEXE")+&("M->"+cAlias+"_OPEEXE") == ;
	BB0->(BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE)

		aadd(aProfs,{BB0->(Recno()),BB0->BB0_CODIGO})
		BB0->(DbSkip())
	Enddo
Else
	lRet := BB0->( MsSeek( xFilial("BB0")+&("M->"+cAlias+"_ESTEXE")+&("M->"+cAlias+"_REGEXE")+&("M->"+cAlias+"_SIGLA")+&("M->"+cAlias+"_OPEEXE") ) )
	While BB0->(!Eof()) .and. xFilial("BB0")+&("M->"+cAlias+"_ESTEXE")+&("M->"+cAlias+"_REGEXE")+&("M->"+cAlias+"_SIGLA")+&("M->"+cAlias+"_OPEEXE") == ;
	BB0->(BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE)

		aadd(aProfs,{BB0->(Recno()),BB0->BB0_CODIGO})
		BB0->(DbSkip())
	Enddo
Endif

If !lRet
	&("M->"+cAlias+"_ESTEXE") := ""
	BB0->(DbSetOrder(7))
	lRet := BB0->( MsSeek( xFilial("BB0")+&("M->"+cAlias+"_REGEXE")))
	aadd(aProfs,{BB0->(Recno()),BB0->BB0_CODIGO})
EndIf

If Len(aProfs) > 0
	BB0->(DbGoTo(aProfs[1][1])) //posiciono sempre no primeiro BB0
Endif

If lRet
	If BB0->(FieldPos("BB0_CODBLO")) > 0 .AND. cAlias != "BOW"
		lRet := A090CHEBLO(BB0->BB0_CODIGO, &("M->"+cAlias+"_DATPRO"),nil,aProfs)
	EndIf
	&("M->"+cAlias+"_NOMEXE") := BB0->BB0_NOME
	&("M->"+cAlias+"_CDPFRE") := BB0->BB0_CODIGO
	&("M->"+cAlias+"_ESTEXE") := BB0->BB0_ESTADO

Else
	Help("",1,"REGNOIS")
Endif

If lRet
	BAU->(DbSetOrder(5))
	If BAU->(DbSeek(xFilial("BAU")+BB0->BB0_CODIGO))
		aRetBAW := PLSVldBAW(PLSINTPAD(),nil,nil,nil,nil,nil,nil,BAU->BAU_CODIGO)
		If ! aRetBAW[1]
			Aviso( "Executante", ;
			aRetBAW[2,1,1] + aRetBAW[2,1,2],;
			{ STR0022 }, 2 ) //"Ok"
				lRet := .F.
			Endif
		Endif
	Endif

	BAU->(DbGoTo(nRegBAU))
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRegBAW))
	BAU->(DbSetOrder(nOrdBAW))

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuVlComp

@author  PLS TEAM
@version P11
@since   11.11.06
/*/
//-------------------------------------------------------------------
Static Function AtuVlComp(lValid,cTipo,lConPagAto )
	LOCAL nFor		:= 0
	LOCAL nVlrComp 	:= 0
	LOCAL cAliasCab := ""
DEFAULT lConPagAto := .F.

For nFor := 1 To Len(oBrwPro:aCols)
	If lValid .And. n == nFor
		If cTipo == "1"
			nVlrComp += M->BE2_VLCOMP
		Else
			nVlrComp += oBrwPro:FieldGet("BE2_VLCOMP",nFor)
		Endif
	Else
		If ! oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
			nVlrComp += oBrwPro:FieldGet("BE2_VLCOMP",nFor)
		Endif
	Endif
Next

If n > Len(oBrwPro:aCols) .And. cTipo == "1"
	nVlrComp += M->BE2_VLCOMP
Endif

If Type('M->BE1_VALOR') <> 'U'
	M->BE1_VALOR	:= nVlrComp
	cAliasCab	 	:= "BE1"
ElseIf Type('M->B01_VALOR') <> 'U'
	M->B01_VALOR	:= nVlrComp
	cAliasCab 	 	:= "B01"
EndIf

If nVlrComp == 0 .And. !lConPagAto
	&("M->"+cAliasCab+"_PAGATO") := "0" //Paga no Ato sim/nao
	&("M->"+cAliasCab+"_GUIACO") := "0" //Guia comprada sim/nao
	&("M->"+cAliasCab+"_QUACOB") := "0" //1-No Ato;2-Fatura
	&("M->"+cAliasCab+"_CODCLI") := ""
	&("M->"+cAliasCab+"_LOJA")   := ""
	EndIf

	lRefresh := .T.
	oEncAut:oBox:Refresh()
	oEncAut:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A090VlrCPP
Exibe a previsao de valores para compra de procedimentos...

@author  PLS TEAM
@version P11
@since   11.11.06
/*/
//-------------------------------------------------------------------
Static Function A090VlrCPP(cAliasEnc,cTipo,oEncA,oBrwC,oBrwP)

	LOCAL nFor		:= 0
	LOCAL aRdas		:= {}
	LOCAL aValor    := {}
	LOCAL aCdPrcNeg := {}
	LOCAL oDlg		:= nil
	LOCAL cTitulo 	:= STR0191 //"Previsao de Custos de Co-Participacao/Fator Moderador"
LOCAL bOK     	:= { || oDlg:End() }
LOCAL cGrpInt 	:= ""
LOCAL aDadUsr 	:= PLSGETUSR()
LOCAL aDadRda 	:= PLSGETRDA()
LOCAL cRegAte 	:= iIf(len(aDadUsr) >= 92, aDadUsr[92], "")
LOCAL cPadInt 	:= ""
LOCAL cPadCon 	:= ""
LOCAL cRegInt 	:= ""
LOCAL nVlrBPF 	:= 0
LOCAL nVlrPF  	:= 0
LOCAL nQtdPro 	:= 0
LOCAL nPercPF 	:= 0
LOCAL nVlrPFTot := 0
LOCAL cPLSCDCO  := AllTrim(GETMV("MV_PLSCDCO"))
LOCAL cTipPreFor:= ''
LOCAL aValAcu 	:= {}
LOCAL cChvNiv	:= ''
LOCAL nPos		:= 0
LOCAL cTipoGuia	:= ''
LOCAL aQtdPer   := {}
LOCAL lExiQTDSOL := .T.
LOCAL aButtons  := { {"RELATORIO",{|| PLSA090ICP(aCdPrcNeg,"","",;
aCdPrcNeg[Len(aCdPrcNeg),8],&("M->"+cAliasEnc+"_CODRDA"),;
&("M->"+cAliasEnc+"_OPERDA"),;
Subs(&("M->"+cAliasEnc+"_CODLOC"),1,3),;
Subs(&("M->"+cAliasEnc+"_CODLOC"),4,3),;
&("M->"+cAliasEnc+"_USUARI"),&("M->"+cAliasEnc+"_NOMUSR"),;
&("M->"+cAliasEnc+"_CID"),&("M->"+cAliasEnc+"_ESTSOL"),;
&("M->"+cAliasEnc+"_REGSOL"),&("M->"+cAliasEnc+"_SIGLA"),;
&("M->"+cAliasEnc+"_NOMSOL"),"2") };
,STR0192,STR0144}} //"Imprimir Orcamento de Co-Participacao"###"Imprimir"

//Se nao tiver preenchido o usuario nao pode entrar na tela...            

If Empty(&("M->"+cAliasEnc+"_USUARI"))
	Aviso( STR0117, STR0193, { STR0146 }, 2 ) 	  //"Compra de Procedimentos"###"Informa um Usuario valido para continuar."###"Ok"
	Return
Endif

//Se for rda generica nao pode comprar...                                 

If cTipo == "2" .And. &("M->"+cAliasEnc+"_CODRDA") == GetNewPar("MV_PLSRDAG","999999")
	Aviso( STR0117, STR0147, { STR0146 }, 2 ) 	  //"Compra de Procedimentos"###"Informa uma Rede de Atendimento valida para continuar."###"Ok"
	Return
Endif

//1-Internacao
//2-Ambulatorial
//Se for internacao ou reembolso
If cAliasEnc == 'BE4' .Or. cAliasEnc == 'B44'
	cPadInt := (cAliasEnc)->&(cAliasEnc+"_PADINT")
	cPadCon := (cAliasEnc)->&(cAliasEnc+"_PADCON")
	cRegInt := (cAliasEnc)->&(cAliasEnc+"_REGINT")
EndIf

//Checa se existem pelo menos um dos itens negados...                     

For nFor := 1 To Len(oBrwP:aCols)

	//Campo status igual a 0=Nao linha ativa...                               

	If oBrwP:FieldGet("BE2_STATUS",nFor) == "1" .And. ! oBrwP:IsDeleted(nFor)

		//Calcula o valor deste item para compra...                               

		If BEA->(FieldPos("BEA_TIPPRE")) > 0
			cTipPreFor := &("M->"+cAliasEnc+"_TIPPRE")
		Else
			cTipPreFor := ""
		Endif

		aValor := {}

		If oBrwP:PLRETPOS("BE2_VLCOMP",.F.) >0 .And. oBrwP:FieldGet("BE2_VLCOMP",nFor) == 0
			aRdas := PLS720IBD7("0",0,oBrwP:FieldGet("BE2_CODPAD",nFor),oBrwP:FieldGet("BE2_CODPRO",nFor),"",;
			&("M->"+cAliasEnc+"_OPERDA"),&("M->"+cAliasEnc+"_CODRDA"),;
			&("M->"+cAliasEnc+"_REGEXE"),&("M->"+cAliasEnc+"_SIGEXE"),;
			&("M->"+cAliasEnc+"_ESTEXE"),&("M->"+cAliasEnc+"_CDPFRE"),;
			&("M->"+cAliasEnc+"_CODESP"),&("M->"+cAliasEnc+"_CODLOC"),;
			"3",oBrwP:FieldGet("BE2_SEQUEN",nFor),;
			"1","02",;
			&("M->"+cAliasEnc+"_DATPRO"))
			If BE2->(FieldPos("BE2_CHVNIV")) > 0
				cChvNiv :=  oBrwP:FieldGet("BE2_CHVNIV",nFor)
			Else
				cChvNiv := ""
			Endif

			cTipoGuia := IF(AllTrim(oBrwP:FieldGet("BE2_CODPAD",nFor)+oBrwP:FieldGet("BE2_CODPRO",nFor)) == cPLSCDCO,"01","02")

			aQtdPer := PlMonQtPer(oBrwP:FieldGet("BE2_SEQUEN",nFor),oBrwP:FieldGet("BE2_CODPAD",nFor),;
			oBrwP:FieldGet("BE2_CODPRO",nFor),IIF(INCLUI,oBrwP:FieldGet("BE2_QTDPRO",nFor),oBrwP:FieldGet("BE2_QTDSOL",nFor)),.T.,;
			"",&("M->"+cAliasEnc+"_DATPRO"),.F.,.T.,oBrwP)

			If ValType(oBrwP:FieldGet("BE2_QTDSOL",nFor)) == "C" //Se caracter, indica que o campo nao existe no Objeto, assim deve utilziar o BE2_QTDPRO 
				lExiQTDSOL := .F.
			EndIf	 
			
			aValor := PLSCALCCOP(oBrwP:FieldGet("BE2_CODPAD",nFor),;
			oBrwP:FieldGet("BE2_CODPRO",nFor),;
			&("M->"+cAliasEnc+"_MESPAG"),&("M->"+cAliasEnc+"_ANOPAG"),;
			&("M->"+cAliasEnc+"_CODRDA"),;
			&("M->"+cAliasEnc+"_CODESP"),"",subs(&("M->"+cAliasEnc+"_CODLOC"),1,3),;
			IIF(INCLUI .Or. !lExiQTDSOL,oBrwP:FieldGet("BE2_QTDPRO",nFor),IIf(oBrwP:FieldGet("BE2_QTDSOL",nFor)>0,oBrwP:FieldGet("BE2_QTDSOL",nFor),oBrwP:FieldGet("BE2_QTDPRO",nFor))),;
			&("M->"+cAliasEnc+"_DATPRO"),.F.,"2",0,cGrpInt,;
			aDadUsr,cPadInt,cPadCon,aQtdPer,cRegAte,0,.T.,.F.,&("M->"+cAliasEnc+"_HORPRO"),;
			aRdas,&("M->"+cAliasEnc+"_OPERDA"),cTipPreFor,;
			If(oBrwP:FieldPos("BE2_PROREL") > 0,oBrwP:FieldGet("BE2_PROREL",nFor),nil),;
			If(oBrwP:FieldPos("BE2_PRPRRL") > 0,oBrwP:FieldGet("BE2_PRPRRL",nFor),nil),aValAcu,;
			oBrwP:FieldGet("BE2_NIVAUT",nFor),cChvNiv,nil,nil,&("M->"+cAliasEnc+"_CID"),nil,cTipoGuia,;
			,,,,,,,,,,,,,,,,cRegInt,Iif(TYPE(&("M->"+cAliasEnc+"_TIPPAC")) <> "U",&("M->"+cAliasEnc+"_TIPPAC"),nil),;
			nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,oBrwP:FieldGet("BE2_CHVNIV",nFor))

			If aValor[1]
				nVlrBPF    := aValor[11]
				nVlrPF     := aValor[12]
				nQtdPro    := IIF(INCLUI,oBrwP:FieldGet("BE2_QTDPRO",nFor),oBrwP:FieldGet("BE2_QTDSOL",nFor))
				nPercPF    := (nVlrPF*100)/nVlrBPF
				nVlrPFTot  += nVlrPF
				AaDd(aValAcu,{oBrwP:FieldGet("BE2_CODPAD",nFor),oBrwP:FieldGet("BE2_CODPRO",nFor),aValor[17],&("M->"+cAliasEnc+"_DATPRO"),&("M->"+cAliasEnc+"_HORPRO")})
			Else
				nVlrBPF    := 0
				nVlrPF     := 0
				nQtdPro    := oBrwP:FieldGet("BE2_QTDPRO",nFor)
				nPercPF    := 0
			EndIf
		ElseIf oBrwP:PLRETPOS("BE2_VLCOMP",.F.) > 0
			nPos := Ascan(aValAcuAut,{|x| x[1]+x[2] == oBrwP:FieldGet("BE2_CODPAD",nFor)+oBrwP:FieldGet("BE2_CODPRO",nFor)})
			If nPos > 0
				aValor := aClone(aValAcuAut[nPos,6])
			Endif

			nVlrBPF    := oBrwP:FieldGet("BE2_VLCOMP",nFor)
			nVlrPF     := oBrwP:FieldGet("BE2_VLCOMP",nFor)
			nQtdPro    := IIF(INCLUI,oBrwP:FieldGet("BE2_QTDPRO",nFor),oBrwP:FieldGet("BE2_QTDSOL",nFor))
			nPercPF    := 0
			nVlrPFTot  += oBrwP:FieldGet("BE2_VLCOMP",nFor)
		Else
			nVlrBPF    := 0
			nVlrPF     := 0
			nQtdPro    := 0
			nPercPF    := 0
			nVlrPFTot  += 0
		Endif

		//Adiciona na matriz o procedimento e o seu respectivo valor               
		//                                                                         
		//[1]  Cod Tipo Tabela                                                     
		//[2]  Codigo Procedimento                                                 
		//[3]  Quantidade                                                          
		//[4]  Descricao                                                           
		//[5]  Valor Base Participacao Financeira                                  
		//[6]  Valor da Participacao Financeira                                    
		//[7]  Percentual da Participacao Financeira                               
		//[8]  Valor Total da Participacao Financeira Acumulada                    

		aadd(aCdPrcNeg,{oBrwP:FieldGet("BE2_CODPAD",nFor),oBrwP:FieldGet("BE2_CODPRO",nFor),;
		nQtdPro,oBrwP:FieldGet("BE2_DESPRO",nFor),;
		nVlrBPF,nVlrPF,nPercPF,nVlrPFTot,aValor})
	Endif
Next

If Len(aCdPrcNeg) == 0
	Aviso( "", ;
	STR0194,; //"Nao existem registros a serem visualizados."
	{ STR0146 }, 2 ) 	                                                                     //"Ok"
	Return
Endif


DEFINE MSDIALOG oDlg TITLE cTitulo FROM 005,005 TO 024, 090

@ 018,005 SAY oSay PROMPT STR0195  SIZE 210,010 OF oDlg PIXEL  //"Procedimento(s) que irao ter Co-Participacao/Fator Moderador"

//Exibe browse com os dados da compra...                                  

oBrowse := TcBrowse():New( 030, 005, 320, 90,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F. )
oBrowse:bLDblClick := { || A090VACP(aCdPrcNeg,oBrowse:nAt) }

oBrowse:AddColumn(TcColumn():New(STR0030,{ || aCdPrcNeg[oBrowse:nAt,1]+"-"+aCdPrcNeg[oBrowse:nAt,2] },; //"Procedimento"
"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowse:AddColumn(TcColumn():New(STR0127,{ || aCdPrcNeg[oBrowse:nAt,4] },; //"Descricao"
"@!",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowse:AddColumn(TcColumn():New(STR0152,{ || aCdPrcNeg[oBrowse:nAt,3] },; //"Qtd"
"999",nil,nil,nil,015,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowse:AddColumn(TcColumn():New(STR0153,{ || aCdPrcNeg[oBrowse:nAt,5] },; //"Vlr Base"
PLPMONEY_M,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowse:AddColumn(TcColumn():New(STR0196,{ || aCdPrcNeg[oBrowse:nAt,6] },; //"Valor"
PLPMONEY_M,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowse:AddColumn(TcColumn():New("%",{ || aCdPrcNeg[oBrowse:nAt,7] },;
PLPMONEY_M,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowse:AddColumn(TcColumn():New(STR0197,{ || aCdPrcNeg[oBrowse:nAt,8] },; //"Valor Total Acumulado"
	PLPMONEY_M,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BE2_CODPRO","BE2_DESPRO",.F.,.F.,.F.,.F.,.F.}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrowse:aObfuscatedCols := aBls
		objCENFUNLGP:useLogUser()
	endif

//-------------------------------------------------------------------
//  Ativa o Dialogo...                                                        
//-------------------------------------------------------------------
	oBrowse:SetArray(aCdPrcNeg)

	oBrowse:nScrollType:= 1

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bOK,.F.,aButtons)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090WH1

@author  PLS TEAM
@version P11
@since   11.11.06
/*/
//-------------------------------------------------------------------
Function PLSA090WH1()
Return(   BAU->BAU_TIPPRE==GetNewPar("MV_PLSTPIN","OPE")   .Or. BAU->BAU_CODIGO == GetNewPar("MV_PLSRDAG","999999") )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090WH2

@author  PLS TEAM
@version P11
@since   11.11.06
/*/
//-------------------------------------------------------------------
Function PLSA090WH2()
	LOCAL lRet := .T.
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090MSG

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090MSG()
	LOCAL cTexto
	LOCAL lUnimeds   := IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)

If lUnimeds
	cTexto := STR0198 //"Este procedimento foi encaminhado para a Auditoria por se tratar de autorizacao de intercambio"
Else
	cTexto := STR0199 //"Este procedimento foi encaminhado para a Auditoria por se tratar de autorizacao para outra operadora"
Endif

Aviso( STR0200, ; //"Aviso"
cTexto,;
{ STR0146 }, 2 ) 	 //"Ok"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090SEQ
Cria Sequencia

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090SEQ
	LOCAL cRet := ""

If ValType(oBrwPro) == "O"

	If oBrwPro:aCols[Len(oBrwPro:aCols),Len(oBrwPro:aHeader)+1]
		cRet := Soma1(oBrwPro:FieldGet("BE2_SEQUEN"))
	Else
		cRet := PLSINCRE("BE2_SEQUEN",oBrwPro)
	EndIf

Else
	cRet := PLSINCRE("BE2_SEQUEN")
	Endif

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} P090SEQCRI
Cria Sequencia

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function P090SEQCRI(nTipo)
	LOCAL cRet := "001"
LOCAL aProg     := PlsRetAut()
LOCAL cAliIte 	:= aProg[3]

DEFAULT nTipo := 0

If nTipo == 0
	If ValType(oBrwPro) == "O"
		cRet := oBrwPro:FieldGet(cAliIte+"_SEQUEN")
	EndIf

Endif

If BEG->( FieldPos("BEG_SEQCRI") ) > 0
	If ValType(oBrwCri) == "O" .AND. !Empty(oBrwCri:aCols)
		If !(oBrwCri:aCols[Len(oBrwCri:aCols),Len(oBrwCri:aHeader)+1])
			cRet := PLSINCRE("BEG_SEQCRI",oBrwCri)
		EndIf
	Else
		cRet := PLSINCRE("BEG_SEQCRI")
		Endif
	Endif

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A090MovPOS

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function A090MovPOS()
	LOCAL cOldCad := cCadastro

	PLSA086()

	cCadastro := cOldCad

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090IMG

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090IMG()
	if objCENFUNLGP:isLGPDAt()
		if !objCENFUNLGP:getPermPessoais() .OR. !objCENFUNLGP:getPermSensiveis()
			objCENFUNLGP:msgNoPermissions()
			Return
		Else
		objCENFUNLGP:useLogUser()
		EndIF
	EndIF
	Eval(bImpG2)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A090VACP

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function A090VACP(aCdPrcNeg,nLinha)
	LOCAL aItens
	LOCAL nFor
	LOCAL aDadosBrw := {}
	LOCAL cCodUnd
	LOCAL cNivel
	LOCAL cValor
	LOCAL nCoefic
	LOCAL cDesCoe
	LOCAL nRefTDE
	LOCAL cDesNiv

	If aCdPrcNeg[nLinha,8] == 0
		MsgStop(STR0201) //"Nao existem valores para serem exibidos"
	Return
Endif

If Len(aCdPrcNeg[nLinha,9]) == 0
	MsgStop(STR0201) //"Nao existem valores para serem exibidos"
	Return
Endif

If ! aCdPrcNeg[nLinha,9,1] .Or. Len(aCdPrcNeg[nLinha,9,17]) == 0
	MsgStop(STR0201) //"Nao existem valores para serem exibidos"
	Return
Endif

aItens := aClone(aCdPrcNeg[nLinha,9,17,1])

For nFor := 1 To Len(aItens)
	If Len(aItens[nFor,5]) > 0
		cCodUnd := aItens[nFor,1]
		cNivel  := aItens[nFor,5,1,2]
		cValor  := aItens[nFor,5,1,4]
		nCoefic := aItens[nFor,5,1,3]
		cDesCoe := aItens[nFor,5,1,7]
		nRefTDE := aItens[nFor,9]
		If FindFunction("PLSRETNCRI")
			cDesNiv := PLSRETNCRI(cNivel, "", "")
		Else
			cDesNiv := ""
		Endif

		aadd(aDadosBrw,{cCodUnd,cValor,nCoefic,cDesCoe,nRefTDE,cNivel,cDesNiv})
	Endif
Next

If Len(aDadosBrw) > 0
	PLSCRIGEN(aDadosBrw,{ {STR0202,"@C",040} ,; //"Unidade"
	{STR0196,"@E 999,999.9999",040 } , {STR0203,"@E 999,999.9999",040 }, ; //"Valor"###"Coeficiente"
	{STR0127,"@C",040 },{STR0204,"@E 999,999.9999",040 }, {STR0205,"@C",40 }, {STR0206,"@C",500 } }, STR0207+AllTrim(aCdPrcNeg[nLinha,2])+" - "+aCdPrcNeg[nLinha,4]) //"Descricao"###"Ref.TDE"###"Nivel"###"Descricao Nivel"###"Composicao do Item "
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS090AVP

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLS090AVP()
	LOCAL nPosAcu
	LOCAL cCodPad := M->BE2_CODPAD
	LOCAL cCodPro := M->BE2_CODPRO

	AtuVlComp(.T.,"1")

nPosAcu := Ascan(aValAcuAut,{|x| x[1]+x[2] == cCodPad+cCodPro})
If nPosAcu == 0
	aadd(aValAcuAut,{cCodPad,cCodPro,M->BE2_VLCOMP,M->BE1_DATPRO,M->BE1_HORPRO,{}})
Else
	aValAcuAut[nPosAcu,3] := M->BE2_VLCOMP
Endif

If M->BE2_PEREVC == "1" .And. M->BE2_VLCOMP > 0
		M->BE2_VLRAPR := M->BE2_VLCOMP
	Endif

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS090VDC
Valida linha	do brw itens

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLS090VDC()
	LOCAL lRet := .T.

	//Se vai chear a compra de procedimento
If Type("M->BE2_PEREVC") == "C" .And. M->BE2_PEREVC == "1" .And. M->BE2_VLCOMP == 0 .And. M->BE2_GUIACO == "1" .And. M->BE2_STATUS == "1"
	Aviso( STR0117, ; //"Compra de Procedimentos"
	STR0210,; //"Informe o valor do procedimento comprado."
	{ STR0146 }, 2 )//"Ok"
	lRet := .F.
Endif

If !Obrigatorio(oEncAut:aGets,oEncAut:aTela)
	Return(.F.)
Endif

//N„o permiti alterar os campos da guia

	PLS090RONL(.T.,oEncAut)
Return(lRet)

/*/{Protheus.doc} PLSA090AE1
Analisa dados de um SE1 (Tit Receber) 

@author  PLS TEAM
@version P11
@since   04.01.05
/*/
Function PLSA090AE1(cPrefixo,cNumero,cParcela,cTipo,cCliFor,cLoja)
LOCAL lBloCtb  	:= .f. //Indica bloqueio do calendario contabil
LOCAL lMovimen 	:= .f. //Indica se o titulo foi movimentado
LOCAL lCanc    	:= .f. //Indica se foi baixado por cancelamento
LOCAL lSeqSE1  	:= .f. //Indica que o cliente controla sequencia de titulos
LOCAL lDesPro  	:= .f. //Indica que houve desconto na producao medica
LOCAL lDesBai 	:= .f. //Indica que o titulo referente a producao medica foi baixado
LOCAL lBFP		:= .f. //Indica que o titulo foi baixado devido a lancamento na folha de pagamento
LOCAL lCanBaix	:= .f. //Indica se a baixa foi cancelada
local lTitCart  := .f. //Indica titulo em carteira
local lTeleCob  := .f. //Indica titulo de teleCobranca		
LOCAL lNotUsed	:= .f. //Nao esta mais sendo usado
local lBXCMP    := .f. //Indica que o titulo foi compensado
local lBxNormal := .f.
local lBX		:= .f.
local cPlMotBC	:= getNewPar("MV_PLMOTBC","CAN")
local cPlMotFP	:= getNewPar("MV_PLMOTFP","BFP")
LOCAL cSQL    	:= ""
local cFk1DOC   := ''

if SE1->( E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) <>  cPrefixo + cNumero + cParcela + cTipo
	SE1->(dbSetorder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->( msSeek( xFilial("SE1") + cPrefixo + cNumero + cParcela + cTipo ) )
endIf

//Calendario Contabil Bloqueado. Verifique o processo.
if ! PLVLDBLQCO(SE1->E1_EMISSAO, {"PLS003"}, .f.)
	lBloCtb := .t.
endIf

//verifica se tem movimentacao 
cSql := " SELECT FK1_MOTBX, FK1_TPDOC, FK1_DOC "
cSql += "   FROM " + retSqlName("FK7") + " FK7 "

cSql += "  INNER JOIN " + retSQLName("FK1") + " FK1 "
cSql += "     ON FK1_FILIAL = '" + xFilial("FK1") + "' "
cSql += "    AND FK1_IDDOC  = FK7_IDDOC "
cSql += "    AND FK1.D_E_L_E_T_ = '' "

cSql += "   WHERE FK7_FILIAL = '" + xFilial("FK7") + "' "
cSql += "     AND FK7_CHAVE  = '" + SE1->( E1_FILIAL + "|" + E1_PREFIXO + "|" +E1_NUM + "|" + E1_PARCELA + "|" + E1_TIPO + "|" + E1_CLIENTE + "|" + E1_LOJA ) + "' "
cSql += "     AND FK7.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSQL)),"TRBFK71",.F.,.T.)

while ! TRBFK71->(eof()) 

	lMovimen := .t. 

    //deve pegar a ultima interacao
	lCanc 	 := .f. 
	lCanBaix := .f.
	lBFP 	 := .f.

	//Indica que o titulo foi baixado por motivo de cancelamento
	if TRBFK71->FK1_MOTBX == cPlMotBC
		
		lCanc := .t. 

	//Indica que o titulo foi baixado devido a lancamento na folha de pagamento
	elseIf TRBFK71->FK1_MOTBX == cPlMotFP
		
		lBFP := .t. 

	elseIf TRBFK71->FK1_TPDOC == "ES" .and. empty(SE1->E1_BAIXA)
		
		lCanBaix := .t.

	endIf

	if TRBFK71->FK1_TPDOC != "ES"
		
    lBX := TRBFK71->FK1_TPDOC == "CP" .or. ( TRBFK71->FK1_TPDOC == "BA" .and. TRBFK71->FK1_MOTBX == "CMP" )

	if ! lBxNormal
        lBxNormal := ! lBX 
    endIf
    
	endIf	
    
    //deve verificar todas as interacoes para saber se teve alguma compensacao NCC
    if lBX
		
		lBXCMP 	:= .t.
        cFk1DOC := TRBFK71->FK1_DOC

    elseIf TRBFK71->FK1_MOTBX == "CMP" .and. TRBFK71->FK1_TPDOC == "ES" .and. TRBFK71->FK1_DOC == cFk1DOC   
        
		lBXCMP := .f.
        
    endIf

TRBFK71->(dbSkip())
endDo

//ocorreu qualquer outra interacao de baixa nao pode excluir a compensacao automatica
if lBxNormal
    lBXCMP := .f.
endIf

TRBFK71->(dbCloseArea())	

if lCanBaix .or. lCanc
	lMovimen := .f.
endIf

//Se o titulo foi movimentado, verifica se foi desconto na producao medica
If lMovimen

	BGQ->(dbSetOrder(7))
	If BGQ->(MsSeek(xFilial("BGQ")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))

		lDesPro := .t.  //Indica que foi baixado para desconto na producao medica

		If ! empty(BGQ->BGQ_NUMLOT)
			lDesBai := .t.
		Endif

	Endif

Endif

// Titulo nao esta em carteira
If SE1->E1_SITUACA <> '0'  
	lTitCart := .t.
Endif

//Verifica se o titulo esta em TELECOBRANCA
SK1->(DbSetorder(1))// K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO
If SK1->( msSeek( xFilial("SK1") + cPrefixo + cNumero + cParcela + cTipo ) ) .and. SK1->K1_OPERAD != "XXXXXX"
	lTeleCob := .t.		
Endif

Return( { lBloCtb, lMovimen, lCanc, lNotUsed, lSeqSE1, lDesPro, lDesBai, lBFP, lNotUsed, lCanBaix, lTitCart, lTeleCob, lBXCMP })

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSGETSPRO

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSGETSPRO(cSenDigit)
Return(BSProtheus(PLSRtCdUsr(),cSenDigit))

//-------------------------------------------------------------------
/*/{Protheus.doc} BSProtheus

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function BSProtheus(cIdUser,cSenDigit)
	Local cTGetDomain := space(40)
    Local cTGetUser := space(40)
	Local lRet := .F.

	If ExistBlock("PLBSPROT")
	lRet := Execblock("PLBSPROT",.F.,.F.,{cIdUser,cSenDigit})
	Else
		PswOrder(1)
		If PswSeek(cIdUser)
			lRet := PswName(cSenDigit)
		endif
	Endif

	// ValidaÁ„o Protheus com o usu·rio de rede do AD (Active Directory)
	if(!lRet)
		GetUserFromSID(GetCredential(), @cTGetDomain, @cTGetUser)
		lRet := ADUserValid(alltrim(cTGetDomain), alltrim(cTGetUser), alltrim(cSenDigit))
	EndIF
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090GBr

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090GBr()
Return(oBrwPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090OCr - Retorna o Objeto oBrwCri

@author  Gabriel Mucciolo
@version P12
@since   05/10/2022
/*/
//-------------------------------------------------------------------
Function PLSA090OCr()
Return oBrwCri

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090OEn - Retorna o Objeto oEncAut

@author  Gabriel Mucciolo
@version P12
@since   05/10/2022
/*/
//-------------------------------------------------------------------
Function PLSA090OEn()
Return oEncAut



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090ODO
Faz a validacao do RX do odontologico

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLSA090ODO()
	LOCAL lRet    := .T.
	LOCAL nInd1   := 1
	LOCAL nInd2   := 1
	LOCAL cTipRx  := ""
LOCAL cCodPro := ""
LOCAL cCodPad := ""
LOCAL lError  := .F.

//Se o procedimento que se esta digitando eh odontologico e eh necessario 
//Raio x para ele e o usuario ainda nao digitou os raios x,eu nem deixo   
//o usuario continuar						                                

if BR8->(MsSeek(xFilial("BR8")+M->BE2_CODPAD+M->BE2_CODPRO))
	if BR8->(FieldPos("BR8_ODONTO")) > 0
		if BR8->BR8_ODONTO == '1'

			//Indica o tipo de raio x necessario para o procedimento, caso o procedim.
			//| jah seja um raio x  ele nem vai entrar nesse if e vai passar direto		

			if !empty(BR8->BR8_TIPRAX) .and. empty(BR8->BR8_RAIOX)
				cTipRx := alltrim(BR8->BR8_TIPRAX)
				if     cTipRx == "3"
					cTipRx := "1,2"
				elseif cTipRx == "6"
					cTipRx := "1,2,5"
				endif
				while nInd1 <= len(cTipRx) .and. !lError
					nInd2   := 1
					if len(oBrwPro:acols)-1 <= 1
						lError := .T.
					endif
					while nInd2 <= len(oBrwPro:acols)-1
						cCodPro := oBrwPro:acols[nInd2][oBrwPro:PlRetPos("BE2_CODPRO")]
						cCodPad := oBrwPro:acols[nInd2][oBrwPro:PlRetPos("BE2_CODPAD")]
						BR8->(DbSetOrder(1))

						//Teoricamente sempre vai entrar neste if									

						if BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
							if BR8->BR8_RAIOX != subs(cTipRx,nInd1,1)
								lError := .T.
							else
								lError:= .F.
							endif
						endif
						nInd2++
					enddo
					nInd1+=2
				enddo
				if len(cTipRx) != 0
					if lError
						msginfo(STR0211+       ; //"Para este procedimento algum(s) tipo(s) de raio-x ainda "
						STR0212) //"n„o informado(s) È(s„o) necess·rio(s)."
						lRet := .T.
					endif
				endif
			endif
		endif
	endif
else
	lRet := .F.
	Help("",1,"REGNOIS")
	endif

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL090CRINE
Faz a critica de um procedimento autorizado				
Usada pelo ponto de entrada (PLS090B3)	

@author  PLS TEAM
@version P11
@since   12.07.05
/*/
//-------------------------------------------------------------------
Function PL090CRINE(cCodCri)

	LOCAL nLinha

	If oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BE2_STATUS",oBrwPro:aHeader)] <> '1' .or.;
Empty( oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BE2_CODPRO",oBrwPro:aHeader)] )
	MsgAlert(STR0342)//'So e permitido esta aÁ„o para procedimento AUTORIZADO!'
	Return
EndIf

If !MsgYesNo(STR0341)//'Deseja NEGAR a AUTORIZA«√O?'
	Return
EndIf

BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
BCT->( MsSeek( xFilial( 'BCT' )+PLSINTPAD()+cCodCri )  )// Trocar o 701 pelo codigo da sua critica

M->BE1_VALOR := M->BE1_VALOR - oBrwPro:FieldGet("BE2_VLCOMP")
oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BE2_STATUS",oBrwPro:aHeader)] := "0"
oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BE2_VLCOMP",oBrwPro:aHeader)] := 0
oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BE2_IMGSTA",oBrwPro:aHeader)] := "DISABLE"
oBrwPro:Consiste()
nLinha := oBrwPro:Linha()
oBrwPro:Refresh()
oBrwPro:SetPos(nLinha)

oBrwCri:aCols[oBrwCri:Linha(),PLRETPOS("BEG_CODGLO",oBrwCri:aHeader)] := cCodCri
oBrwCri:aCols[oBrwCri:Linha(),PLRETPOS("BEG_DESGLO",oBrwCri:aHeader)] := BCT->BCT_DESCRI
oBrwCri:Consiste()
oBrwCri:ForceRefresh(oBrwPro)

If M->BE1_VALOR == 0
	M->BE1_GUIACO := "0"
	M->BE1_QUACOB := ""
	M->BE1_PAGATO := "0"
Endif
//lRefresh := .T.
Return

/*/{Protheus.doc} PLSAUTREM
Envio de transacoes ptu-online	

@author  PLS TEAM
@version P11
@since   29.06.06
/*/
Function PLSAUTREM(cAliasCab,cAliasIte,cAliasCri,oObjBrw,oBrwCri,nOpc,lInternacao,lEvolucao,aResComuni,cAvisoRet,cTrolComun,aDadB6M)
	LOCAL nPos			
	LOCAL nI			
	LOCAL nX			
	LOCAL nY			
	LOCAL nZ			
	LOCAL cRet			
	LOCAL lFlag		
	LOCAL nOrdBA0		
	LOCAL nRecBA0		
	LOCAL oDlg			
	LOCAL cTpAut		
	LOCAL cCodPad		
	LOCAL cCodPro		
	LOCAL cDesPro		
	LOCAL cSituac		
	LOCAL cTipCon		
	LOCAL dDatCir		
	LOCAL cHorCir		
	LOCAL cTipGui		
	LOCAL cOriMov		
	LOCAL lEnc			:= .T.
	LOCAL aRdas 		:= {}
	LOCAL cMatricUsr    := &("M->"+cAliasCab+"_USUARIO")
LOCAL cPadInt    	:= ""
LOCAL cPadCon    	:= ""
LOCAL cRegInt		:= ""
LOCAL cRegAte 		:= ''
LOCAL nPerVia   	:= 100
LOCAL lCirurgico	:= .F.
LOCAL aValor		:= {}
LOCAL lConsulta     := .F.
LOCAL cCodCri 	 	:= "000"
LOCAL cDesCri 	 	:= STR0318//"CRITICA DESABILITADA"
LOCAL aRet		 	:= {}
LOCAL cTranOri	 	:= ""
LOCAL cTranDes	 	:= ""
LOCAL cSenhaOpe  	:= ""
local lRadio 		:= .t.
local lQuimio 		:= .t.
local lOpme 		:= .t.
LOCAL cAutori    	:= "3"
LOCAL lUmNeg	 	:= .F.
LOCAL lUmAut	 	:= .F.
LOCAL lAudit 	 	:= .F.
LOCAL nSequen    	:= "0"
LOCAL aDados 	 	:= {}
LOCAL aProcAux 	 	:= {}
LOCAL aRetOln	 	:= {}
LOCAL aDadRda    	:= {}
LOCAL aDadUsr    	:= {}
LOCAL aQuimio       := {}
Local aRadio        := {}
LOCAL aRetDesCan    := {}
LOCAL aFlgB4C		:= {}
LOCAL cOpeUsu 	 	:= ""
LOCAL lInsist    	:= .F.
LOCAL lEnvia	 	:= .F.
LOCAL lRevisao	 	:= .F.
LOCAL TpTab		 	:= "0"
LOCAL lEvoCon	 	:= .F.
LOCAL lEvoFim	 	:= .F.
LOCAL lEvoTem	 	:= .F.
LOCAL lEvoExcl      := .F.
LOCAL lEnvConclu 	:= .F.
LOCAL aRetB43 		:= {}
LOCAL aPacote 		:= {0,0,{},""}
LOCAL nJ			:= 1
LOCAL lReqOrdSer    := .F.
LOCAL lCriTime      := .F.
LOCAL lAnexo        := .F.
LOCAL lItemPacote   := .F. 
LOCAL cCodProcPri   := ""
LOCAL cCodPacote    := ""
LOCAL cTranUsada    := ""
LOCAL cDesGenPtu    := __cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen
LOCAL nItensAut     := 0
LOCAL nItensNeg     := 0
LOCAL nFor          := 0
LOCAL nContOPME     := 0
LOCAL cValorUni		:= "" 
LOCAL cValorTot		:= "" 
LOCAL cStatus       := ""
LOCAL cTranCanc     := ""
LOCAL cPesqAnex     := "" 
LOCAL cDecItem      := ""
LOCAL cQtdItem      := ""
LOCAL cTipPre		:= ""
LOCAL cCodOpeUni    := ""
LOCAL cTVerPTU		:= ''
LOCAL lTVBA0BAU		:= getNewPar("MV_PTUTIVE",.f.)
LOCAL dProvAtend    := Ctod(Space(8))
LOCAL cCodPre600    := Space(8)
LOCAL nOpca         := 0
LOCAL bOKFor        := {|| Iif(FunName()=="PLSA092",IIF(!Empty(cCodPre600) .And. !Empty(dProvAtend),(nOpca := 1, oDlg:End()),Msginfo(STR0505)),(nOpca := 1, oDlg:End()) )  } //"Para SolicitaÁ„o de InternaÁ„o È obrigatÛrio informar a Data Prov·vel de Atendimento e CÛdigo do Prestador"
LOCAL bCancel       := {|| nOpca := 0, oDlg:End() }
LOCAL cTissVer      := PLSTISSVER()
LOCAL cObsEvo       := ""
LOCAL lPTUOn50      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "50" 
LOCAL nRecBA1       := 0
LOCAL nAudito       := 0
LOCAL nStaAut		:= 0
LOCAL nStaNeg		:= 0
LOCAL nStaPar		:= 0
LOCAL lBR8Anex      := .F.
LOCAL lTriangulacao	:= .f.
LOCAL nIdade        := 0
LOCAL nSeqPtu			:= 0
LOCAL aRegPos		:= {}
LOCAL nPosScan		:= 0
LOCAL cObser1BQV    := ""
LOCAL cIdLiminar		:= ""
LOCAL lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70" 
LOCAL lTiss330		:= ! Empty(cTissVer) .And. cTissVer >= "3.03.00"
LOCAL lMeBenef	   := .F.
LOCAL cRegAnv		:= ""
LOCAL cRefFab		:= ""
LOCAL lAudito       := .F.
LOCAL nPosCriBQV    := 0
LOCAL lRet          := .F.
LOCAL cToken        := ""
LOCAL aCodCriIte    := {}
Local lExiTUSEDI    := BR8->(FieldPos("BR8_TUSEDI") ) > 0														 
Local lExPlVTb      := ExistBlock( "PLSVATBI" )
LOCAL nPosCodPro    := 0
LOCAL nValSaldo     := 0
LOCAL cDecDosag     := ''
LOCAL cQtdDosag     := ''
LOCAL cTpGuia		:= ""	
LOCAL cTpAcomod     := "" 
LOCAL cTpEtapaAut   := ""
LOCAL lPTUOn80	    := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80" 
LOCAL lRolUnimed 	:= BR8->( FieldPos("BR8_ROLUNI") ) > 0
LOCAL cDtSolic  	:= DtoS(dDataBase)
Local aDadB6MAux	:= {}
Local lGuiaPacote	:= .F.
Local aGuiaPacote 	:= {}
Local aItemPacote	:= {}
Local nNx
LOCAL lPTUOn90 := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
Local cNomeSocial := ""
Local cCodEspOrdServ := Space(7)

DEFAULT nOpc 	 	:= K_Incluir
DEFAULT lEvolucao	:= .F.
DEFAULT lInternacao	:= .F.
DEFAULT aResComuni  := {}
DEFAULT cAvisoRet    := ""
DEFAULT cTrolComun   := ""
DEFAULT aDadB6M		 := {}

DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011
//Resposta padrao e negativa                   							
lConf := .F.

//Verifica se ja foi informado algum procedimento							
If Len(oObjBrw:aCols) > 0
	If Empty(oObjBrw:aCols[1,GdFieldPos(cAliasIte+"_CODPRO",oObjBrw:aHeader)])
		Return(lConf)
	EndIf
Else
	Return(lConf)
EndIf

//Verifica o tipo de atendimento inferior a TISS 3.00.00                  
If cTissVer < "3.00.00" .And. Type("M->"+cAliasCab+"_TIPATE") == "C" .And. &("M->"+cAliasCab+"_TIPATE") $ "11,13,14,15,16,17 18,19,20,21"
	MsgInfo(STR0595) //"O Tipo de Atendimento selecionado sÛ pode ser utilizado na TISS 3.00.00 ou superior."
	Return(lConf)
EndIf

//Verifica se eh item de anexo e nao permite a comunicacao                
If GetNewPar("MV_PTGLOBO","1") == "1" .And. !PLVerAnPTU(oObjBrw,cAliasIte,nOpc,cAliasCab)
	Return(lConf)
EndIf

//Verifica se bloqueia solicitacao por guia com critica de periodicidade  
If Len(oObjBrw:aCols) == 1 .And. Len(oBrwCri:aCols) > 0 .And. Alltrim(oObjBrw:aCols[1,PLRETPOS(cAliasIte+"_CODPRO",oObjBrw:aHeader)]) $ GetNewPar("MV_PTBLPER","10101012")
	For nX := 1 to Len(oBrwCri:aCols)
		If !Empty(oBrwCri:aCols[nX][2]) .And. oBrwCri:aCols[nX][2] == __aCdCri047[1]
			MsgInfo(STR0538)//"Foi apresentada crÌtica de periodicidade no item solicitado, n„o È permitido realizar a solicitacao online."
			Return(lConf)
		EndIf
	Next
EndIf

//Verifica campos necessarios												

If Type(cAliasIte+"->"+cAliasIte+"_AUDITO") <> "C"	.Or. Type(cAliasIte+"->"+cAliasIte+"_STATUS") <> "C"	.Or.;
Type(cAliasIte+"->"+cAliasIte+"_SEQUEN") <> "C"	.Or. Type(cAliasIte+"->"+cAliasIte+"_CODPRO") <> "C"	.Or.;
Type(cAliasCri+"->"+cAliasCri+"_SEQUEN") <> "C"	.Or. Type(cAliasCri+"->"+cAliasCri+"_CODGLO") <> "C"	.Or.;
Type(cAliasCri+"->"+cAliasCri+"_DESGLO") <> "C"	.Or. Type("M->"+cAliasCab+"_NRAOPE") <> "C" 	.Or.;
Type("M->"+cAliasCab+"_COMUNI") <> "C"	.Or. Type("M->"+cAliasCab+"_NRTROL") <> "C" 	.Or.;
Type("M->"+cAliasCab+"_AUDITO") <> "C"	.Or. Type("M->"+cAliasCab+"_TRACON") <> "C" 	.Or.;
Type("M->"+cAliasCab+"_CANCEL") <> "C"	.Or. Type("M->"+cAliasCab+"_VIACAR") <> "N"
	MsgAlert(STR0260)//"Sua base esta desatualizada favor verificar os campos referente ao EDI-ONLINE"
	Return(lConf)
EndIf

//Verifica se esta tentando executar uma liberacao online											

If &("M->"+cAliasCab+"_COMUNI") == "1" .And. BEA->BEA_ORIGEM == '2' .And. !FunName() $ "PLSA094B/PLSA092" .And. !Empty( &("M->"+cAliasCab+"_NUMLIB") )
	MsgAlert(STR0390)//"A liberaÁ„o j· foi solicitada On-Line"
	Return(lConf)
EndIf

//Verifica se esta tentando solicitar autorizacao da evolucao sem ter solicitado para autorizacao	

If &("M->"+cAliasCab+"_COMUNI") == "0" .And. lEvolucao

	If BEA->BEA_TIPGUI == '02'
		MsgAlert(STR0643) //"Nao foi solicitado autorizac„o on-line para a autorizaÁ„o de SADT!"
		Return(lConf)
	Else
		MsgAlert(STR0261) //"Nao foi solicitado autorizac„o on-line para a autorizaÁ„o de internaÁ„o!"
		Return(lConf)
	EndIf

EndIf

//Nao permite enviar complemento se nao tiver concluido					

If &("M->"+cAliasCab+"_TRACON") == "0" .And. lEvolucao
	If BEA->BEA_TIPGUI=='02'	
		Aviso( STR0120, ; //"Atencao"
		STR0644,; //"TransaÁ„o n„o foi concluida, impossivel fazer solicitacao  on-line da evoluÁ„o de SADT!"
		{ STR0146 }, 2 )//"Ok"
		Return(lConf)
	Else
		Aviso( STR0120, ; //"Atencao"
		STR0262,; //"TransaÁ„o n„o foi concluida, impossivel fazer solicitacao  on-line da evoluÁ„o de GIH!"
		{ STR0146 }, 2 )//"Ok"
		Return(lConf)
	EndIf  
EndIf

//Nao permite mais fazer solicitacao on-line								

If &("M->"+cAliasCab+"_TRACON") == "1" .And. !lEvolucao
	Aviso( STR0120, ; //"Atencao"
	STR0279,; //"Transacao concluida nao e possivel fazer solicitacao on-line!"
	{ STR0146 }, 2 )//"Ok"
	Return(lConf)
EndIf

//Nao permite mais fazer solicitacao on-line								
If &("M->"+cAliasCab+"_TRACON") == "1" .And. !lEvolucao
	Aviso( STR0120, ; //"Atencao"
	STR0279,; //"Transacao concluida nao e possivel fazer solicitacao on-line!"
	{ STR0146 }, 2 )//"Ok"
	Return(lConf)
EndIf

If !lEvolucao .And. len(oObjBrw:FieldGet(cAliasIte+"_NRAOPE",nI)) > 0 .And. !Empty(oObjBrw:FieldGet(cAliasIte+"_NRAOPE",nI)) .And. ;
&("M->"+cAliasCab+"_TRACON")=="0" .And. !Empty(oObjBrw:FieldGet(cAliasIte+"_NRTROL",nI)) .And. ;
oObjBrw:FieldGet(cAliasIte+"_STATUS",nI) =="0" .And. &("M->"+cAliasCab+"_COMUNI")=="1"

	Aviso( STR0120, ; //"Atencao"
	STR0623,; //"ComunicaÁ„o j· realizada e Negada. Confirme a Guia e utilize a insistÍncia em AÁıes Relacionadas! "
	{ STR0146 }, 2 )//"Ok"
	Return(lConf)
EndIf

//Verifica se a guia esta cancelada										 

If &("M->"+cAliasCab+"_CANCEL") == "1"
	Aviso( STR0120, ; //"Atencao"
	STR0213,; //"Guia cancelada!"
	{ STR0146 }, 2 )//"Ok"
	Return(lConf)
EndIf

//Verifica tamanho da matricula    										 

If Substr(&("M->"+cAliasCab+"_USUARI"),1,4) <> PlsIntPad() .And. ;
(Len(Alltrim(&("M->"+cAliasCab+"_MATANT"))) <> 17 .And. Substr(&("M->"+cAliasCab+"_MATANT"),1,4) <> PlsIntPad())

	Aviso( STR0120, ; //"Atencao"
	STR0494,; //"Tamanho da matrÌcula diferente do esperado (17 caracteres)"
	{ STR0146 }, 2 )//"Ok"
	Return(lConf)
EndIf

//Alimenta variaveis													

aDadRda	:= PLSGETRDA()
aDadUsr	:= PLSGETUSR()

cRegAte := iIf(len(aDadUsr) >= 92, aDadUsr[92], "")

// Valida a existencia de dados obrigatorios ja validados... 
If Len(aDadRda) == 0 .or. Len(aDadUsr) == 0 .or. Empty(oObjBrw:FieldGet(cAliasIte+"_CODPRO",1))
	aviso( STR0216,STR0217,{ STR0146 }, 2 )//"Dados"//"Informe os dados da Rede de Atendimento, Usuario e Procedimento(s) antes de executar este processo."//"Ok"
	Return(lConf)
EndIf

cOpeUsu		:= aDadUsr[45]
cTipPre		:= aDadRda[27]
cCodOpeUni 	:= aDadRda[28]
//-------------------------------------------------------------------------------------
// VerIfica se e a mesma operadora, caso sim, realiza a Requisicao de Ordem de Servico
//-------------------------------------------------------------------------------------
If cOpeUsu == PLSINTPAD() .or. ( cOpeUsu != PLSINTPAD() .and. cCodOpeUni != PLSINTPAD() .and. cTipPre == GetNewPar("MV_PLSTPIN","OPE") )

	If cOpeUsu == PLSINTPAD()

		cTit := STR0614 //"Ordem de ServiÁo"

		//se for guia de autorizacao sadt n„o permite fazer ordem de servico.
		if ( !lInternacao .and. !lEvolucao )  .and. __cTipo != "2"
			aviso( STR0054,STR0613,{ STR0146 }, 2 ) //'Para ordem de serviÁo utilize a guia de solicitaÁ„o de autorizaÁ„o!'
			Return(lConf)
		EndIf

		If cTipPre <> GetNewPar("MV_PLSTPIN","OPE")
			msgInfo(STR0610) //"RDA informada n„o È do tipo Operadora"
			Return(lConf)
		Endif

		If !Empty( &("M->"+cAliasCab+"_NRTROS") )  
			msgInfo(STR0609) //"Esta guia foi gerada a partir de uma Ordem de ServiÁo, ser· gerado um Pedido de AutorizaÁ„o para a Operadora do Benefici·rio."
		Endif

	Else
		cTit 			:= STR0611   //"TriangulaÁ„o"
		lTriangulacao 	:= .t.
	EndIf

	If Empty( &("M->"+cAliasCab+"_REGSOL") )
		msgInfo(STR0603) //"Para solicitaÁ„o de Ordem de ServiÁo, È necess·rio informar o Solicitante"	
		Return(lConf)
	Endif

	nRet := aviso(cTit,STR0612,{ STR0326,STR0327 }, 2 ) //"Confirma a solicitaÁ„o?"

	If nRet == 1

		lReqOrdSer := .T.

		cCodOpeUni 	:= aDadRda[28]
		PlsPtuPut("CD_UNI_BEN",cCodOpeUni,aDados)

		If lTriangulacao
			PlsPtuPut("CD_UNI",cOpeUsu,aDados)
			PlsPtuPut("CD_UNI_SOL",PlsIntPad(),aDados)
			PlsPtuPut("NR_IDENT_B",Replicate("0",10),aDados)
		Else
			PlsPtuPut("CD_UNI_SOL",cOpeUsu,aDados)
			PlsPtuPut("NR_IDENT_B",Strzero(Val(&("M->"+cAliasCab+"_SENHA")),10),aDados)
			PlsPtuPut("CD_UNI",PlsIntPad(),aDados)
		Endif

		// Define dialogo...
		DEFINE MSDIALOG oDlg TITLE IIf(lTriangulacao,STR0539,STR0470) FROM 008.0,010.3 TO 034.4,100.3 //"Triangulacao" ou //"RequisiÁ„o de Ordem ServiÁo"

		@ 045,005 SAY oSay PROMPT STR0471  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//"Data Prov·vel de Atendimento"
		@ 045,100 MSGET dProvAtend SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		@ 060,005 SAY oSay PROMPT STR0135  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//"CÛdigo Prestador"
		@ 060,100 MSGET cCodPre600 SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		If lPTUOn90
			@ 075,005 SAY oSay PROMPT STR0676 SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED // "Especialidade do Prestador"
			@ 075,100 MSGET cCodEspOrdServ SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK F3 "BAQPLS"
		EndIf

		// Ativa dialogo....

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOKFor,bCancel,.F.) } )

		If nOpca <> 1
			Return(lConf)
		Endif

	Else
		Return(lConf)
	EndIf

EndIf

//Valida a existencia de dados obrigatorios ja validados...               
If Len(aDadRda) == 0 .Or. Len(aDadUsr) == 0 .Or. Empty(oObjBrw:FieldGet(cAliasIte+"_CODPRO",1))
	Aviso( STR0216,; //"Dados"
	STR0217,; //"Informe os dados da Rede de Atendimento, Usuario e Procedimento(s) antes de executar este processo."
	{ STR0146 }, 2 )//"Ok"
	Return(lConf)
Endif

//Verificando ba0															

nOrdBA0 := BA0->(IndexOrd())
nRecBA0 := BA0->(Recno())
BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cOpeUsu)) .And. BA0->BA0_ONLINE <> "1"
	Aviso( STR0214, ; 		//"Operadora"
	STR0218,; 		//"Operadora origem do usuario nao esta configurada para este tipo de comunicacao remota."
	{ STR0146 }, 2 ) //"Ok"
	Return(lConf)
Endif

//Verifica se a variavel existe											

If Type('lComunica') == "U"
	lComunica := .T.
EndIf

//Se nao for nem internacao ou evolucao									
If ! lInternacao .And. !lEvolucao
	lConsulta := (PLSISCON(oObjBrw:FieldGet(cAliasIte+"_CODPAD"),oObjBrw:FieldGet(cAliasIte+"_CODPRO")) .And. Len(oObjBrw:aCols) == 1)
EndIf

//Verifica se a tabela foi aberta											

If Select(cAliasCri) == 0
	RegToMemory(cAliasCri, .F., .F. )
EndIf

//Verifica se ha exclusao de complemento								    

BR8->(DbSetOrder(1)) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
If cAliasIte == "BQV" .And. lEvolucao

	nPos := aScan(oObjBrw:aCols,{|x| x[Len(oObjBrw:aHeader)+1] == .T.})
	If nPos > 0
		If !Empty(oObjBrw:FieldGet(cAliasIte+"_NRTROL",nPos))
			cTranOri  := oObjBrw:FieldGet(cAliasIte+"_NRTROL",nPos)
			cTranCanc := oObjBrw:FieldGet(cAliasIte+"_NRAOPE",nPos)
			lEvoExcl  := .T.
		EndIf
	Endif
EndIf

//Inclui os procedimentos do brw											

If !lEvoExcl

	B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF  
	B4C->( DbSetOrder(3) )//B4C_FILIAL + B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT + B4C_CODPAD + B4C_CODPRO  

	For nX := 1 To Len(oObjBrw:aCols)
		lBR8Anex := .F.
		aValor   := {}

		//Despreza procedimentos deletados                                            
		If oObjBrw:aCols[nX][Len(oObjBrw:aHeader)+1]
			Loop
		EndIf

		cCodPad  	:= oObjBrw:FieldGet(cAliasIte+"_CODPAD",nX)
		cCodPro  	:= oObjBrw:FieldGet(cAliasIte+"_CODPRO",nX)
		lItemPacote := oObjBrw:FieldGet(cAliasIte+"_PACOTE",nX) == '1'
		cDesPro		:= Left(oObjBrw:FieldGet(cAliasIte+"_DESPRO",nX),80)
		cRegAnv		:= oObjBrw:FieldGet(cAliasIte+"_REGANV",nX)
		cRefFab		:= oObjBrw:FieldGet(cAliasIte+"_REFFED",nX)  

		//Verifica se tem algum procedimento que ainda nao foi solicitado comunicacao	
		If lEvolucao .And. oObjBrw:FieldGet(cAliasIte+"_COMUNI",nX) == "1" .And. oObjBrw:FieldGet(cAliasIte+"_TRACON",nX) == "1"
			lEvoFim := .T.
			Loop
		ElseIf lEvolucao .And. oObjBrw:FieldGet(cAliasIte+"_COMUNI",nX) == "1" .And. oObjBrw:FieldGet(cAliasIte+"_TRACON",nX) <> "1"
			If Empty(oObjBrw:FieldGet(cAliasIte+"_NRAOPE",nX))
				cTranUsada := oObjBrw:FieldGet(cAliasIte+"_NRTROL",nX)
				lEvoCon := .T.
			Else
				lEvoFim := .T.
				Loop
			EndIf
		ElseIf lEvolucao .And. oObjBrw:FieldGet(cAliasIte+"_COMUNI",nX) <> "1" .And. oObjBrw:FieldGet(cAliasIte+"_TRACON",nX) <> "1"
			lEvoTem := .T.
			If !Empty(oObjBrw:FieldGet(cAliasIte+"_NRTROL",nX))
				cTranUsada := oObjBrw:FieldGet(cAliasIte+"_NRTROL",nX)
			EndIf
		EndIf

		If cAliasIte == 'BQV' 
			//Pesquiso na BQV pois itens em auditoria podem estar sem o TRACON preenchido
			BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
			If BQV->(MsSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)+oObjBrw:FieldGet(cAliasIte+"_SEQUEN",nX)))
				If Empty(oObjBrw:FieldGet(cAliasIte+"_SEQPTU",nX)) 
					nSeqPtu++
				Else
					nSeqPtu := Val(oObjBrw:FieldGet(cAliasIte+"_SEQPTU",nX)) 
				EndIf
			Else
				nSeqPtu++
			EndIf	
		Else
			//Alias BE2 e BEJ sempre incrementa
			nSeqPtu++
		EndIf	

		//Seek																		
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )			
			If lPTUOn80 
				// 18 = TUSS Taxas hospitalares,di·rias e gases medicinais
				// 19 = TUSS Materiais
				// 20 = TUSS Medicamentos
				// 22 = TUSS Procedimentos e eventos em sa˙de(medicina,odonto e demais ·reas de sa˙de)
				// 98 = Tabela PrÛpria de Pacotes
				// 00 = Tabela PrÛpria das Operadoras				 		
				TpTab := PtTpTabTus(lExiTUSEDI,lExPlVTb,.T.)
			Else 
				//0=Procedimento							(0=AMB)						 		
				//1=Material	    						(2=Material)				 		
				//2=Medicamento							(3=Medicamento)				 		
				//3=Taxas									(1=Hospitalar)				 		
				//4=Diarias								(1=Hospitalar)				 		
				//5=Ortese/Protese							(1=Hospitalar)				 		
				//6=Pacote 								(1=Hospitalar)				 		
				TpTab := PtTpTabTus(lExiTUSEDI,lExPlVTb) //TpTab := Iif(BR8->BR8_TPPROC=='0' .Or. Empty(BR8->BR8_TPPROC),'0',Iif(BR8->BR8_TPPROC $ '1/5','2',Iif(BR8->BR8_TPPROC=='2','3',Iif(BR8->BR8_TPPROC=='6','4','1') ) ) )
			EndIf	
			//Vai na tde para verificar se o procedimento ja foi informado para unimed brasil	 
			//Somente se for ortese/protese ou material								 		 

			If lExPlVTb
				TpTab := ExecBlock( "PLSVATBI", .F., .F., {TpTab,lPTUOn80,.F.} )
			EndIf  

			If lPTUOn80
				If Empty(TpTab)
					Help(,,STR0658,,STR0659 + Alltrim(cCodPro), 1, 0,,,,,,{STR0660}) // "De-Para TISS" # "Procedimento n„o vinculado com a Terminologia TISS - " # "Realizar o vinculo do procedimento na Tabela Padr„o > Vinculo TISS"
					Return(.F.)
				EndIf
			EndIf   
			
			If (BR8->BR8_TPPROC $ '5,6' .And. BR8->( FieldPos("BR8_DATINC") ) > 0  .And. Empty(BR8->BR8_DATINC) ) .Or. (BR8->BR8_TPPROC == '6') .or. lItemPacote .Or. Alltrim(cCodPro) $ Alltrim(cDesGenPtu)

				If IIF(lPTUOn80,!(BR8->BR8_TPPROC == "6" .Or. lItemPacote),.T.) // O Valor do pacote encontram-se no SISPAC, portanto n„o precisa calcular no Atendimento

					dDatCir := &("M->"+cAliasCab+"_DATPRO")
					cHorCir := &("M->"+cAliasCab+"_HORPRO")

					//Prepara para pegar o valor do procedimento								|

					If lInternacao
						cRegAte := "1" //regime internacao
						cPadInt := &("M->"+cAliasCab+"_PADINT")
						cPadCon := &("M->"+cAliasCab+"_PADCON")
						cSigla  := &("M->"+cAliasCab+"_SIGLA")
						cTipGui := "03"
						cOriMov := "2"
					Else
						If FunName() == "PLSA092" .And. lEvolucao
							cSigla  := &("M->"+cAliasCab+"_SIGLA")
						Else
							cSigla  := &("M->"+cAliasCab+"_SIGEXE")
						Endif

						//Se uma consulta ou exame													|
						If lConsulta
							cTipGui := "01"
						Else
							cTipGui := "02"
						EndIf
						cOriMov := "1"
					Endif

					//Monta matriz rdas														|

					aRdas := PLS720IBD7("0",0,oObjBrw:FieldGet(cAliasIte+"_CODPAD",nX),oObjBrw:FieldGet(cAliasIte+"_CODPRO",nX),"",;
					&("M->"+cAliasCab+"_OPERDA"),&("M->"+cAliasCab+"_CODRDA"),&("M->"+cAliasCab+"_REGEXE"),;
					cSigla,&("M->"+cAliasCab+"_ESTEXE"),&("M->"+cAliasCab+"_CDPFRE"),;
					&("M->"+cAliasCab+"_CODESP"),&("M->"+cAliasCab+"_CODLOC"),;
					"3",oObjBrw:FieldGet(cAliasIte+"_SEQUEN",nX),cOriMov,cTipGui)

					//Se e cirurgico ou nao													|

					lCirurgico := (BR8->BR8_TIPEVE == "2") //1=Clinico;2=Cirurgico;3=Ambos

					If PLSALIASEXI("B43")
						aRetB43 := PlRetPac(&("M->"+cAliasCab+"_OPERDA"),&("M->"+cAliasCab+"_CODRDA"),cCodPad,cCodPro,nil,&("M->"+cAliasCab+"_DATPRO"))
						aPacote := {0,0,{},""}
						For nJ:=1 To Len(aRetB43)
							aadd(aPacote[3],{aRetB43[nJ][1],aRetB43[nJ][2],aRetB43[nJ][5],aRetB43[nJ][4],aRetB43[nJ][6],aRetB43[nJ][9]})
							aPacote[1] += aRetB43[nJ][5] //_VALFIX
							aPacote[2] += aRetB43[nJ][4] //_VALCH
							aPacote[4] := aRetB43[nJ][10]
						Next
					Endif

					//Calcula o valor do procedimento										   

					aValor := PLSCALCEVE(cCodPad,cCodPro,&("M->"+cAliasCab+"_MESPAG"),&("M->"+cAliasCab+"_ANOPAG"),;
					PlsIntPad(),&("M->"+cAliasCab+"_CODRDA"),&("M->"+cAliasCab+"_CODESP"),;
					aDadRda[21],&("M->"+cAliasCab+"_CODLOC"),oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX),;
					&("M->"+cAliasCab+"_DATPRO"),aDadUsr[48],cPadInt,cRegAte,0,aDadUsr,cPadCon,;
					{},Nil,Nil,Nil,Nil,&("M->"+cAliasCab+"_HORPRO"),aRdas,Nil,Nil,Nil,;
					{},Nil,dDatCir,cHorCir,{},cTipGui,.F.,0,{},Nil,;
					lCirurgico,nPerVia,"","",oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX),0,aPacote)

					//Verifica se consegue pegar o valor do procedimento						|

					For nI := 1 To Len(aValor[1])
						If !Empty(aValor[1][nI][4])
							Aviso( STR0120,; 				//"AtenÁ„o"
							AllTrim(cCodPro)+"-> ( " + AllTrim(aValor[1][nI][4]) + " )",;
							{ STR0146 }, 2 )		//"Ok"
							Return(lConf)
						Endif
					Next
				EndIf
			EndIf
		EndIf

		//Monta matriz															
		AaDd(aProcAux,{})

		If !lPTUOn80 
			cCodProcPri := ""
			//quando entra como codigo de pacote obrigatoriamente o mesmo ja foi negociado com outra operadora	
			If TpTab == "4" .And. !lItemPacote 

				cSql := " SELECT BLE_CODOPC "
				cSql += "  FROM " + RetSqlName("BLD") + " BLD, " + RetSqlName("BLE") + " BLE "
				cSql += " WHERE BLD_FILIAL = '" + xFilial("BLD") + "'  "
				cSql += " AND BLE_FILIAL = '"+xFilial("BLE")+  "' "
				cSql += "   AND BLD_CODINT = '" + plsintpad() + "' "
				cSql += "   AND BLD_CODPAD = '" + cCodPad + "' "
				cSql += " AND BLD_CODPRO = '"+cCodPro+ "' "
				cSql += "   AND BLE_CODINT = BLD_CODINT "
				cSql += "   AND BLE_CODPAD = BLD_CODPAD "
				cSql += "   AND BLE_CODPRO = BLD_CODPRO "
				cSql += " AND BLE_PRINCI = '1' "
				cSql += " AND BLD.D_E_L_E_T_ <> '*' "
				cSql += " AND BLE.D_E_L_E_T_ <> '*' "

				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

				if !TmpPac->( Eof() )
					cCodProcPri := TmpPac->BLE_CODOPC
					cCodPacote  := cCodPro 

					If Empty (cCodProcPri) .And. !Empty(cCodPacote)
						cCodProcPri:=cCodPacote
						PlsPtuPut("ID_PACOTE","S",aProcAux[Len(aProcAux)])			
					EndIf
				endIf

				TmpPac->( dbClosearea() )            
			endIf       
				
			If TpTab == "4" .And. Empty(cCodProcPri)
				cCodProcPri := cCodPro					
			EndIf	
		EndIf

		PlsPtuPut("TP_TABELA", TpTab, aProcAux[Len(aProcAux)]) //Identifica o Tipo de Tabela utilizado no Servico Medico.

		If lPTUOn80
			PlsPtuPut("CD_SERVICO", cCodPro, aProcAux[Len(aProcAux)])
		Else
			PlsPtuPut("CD_SERVICO", iif(TpTab == "4",cCodProcPri,cCodPro), aProcAux[Len(aProcAux)])	//codigo do servico
		EndIf

		If lPTUOn80		
			If lPTUOn90 // MandatÛrio apenas para CodificaÁıes GenÈricas
				If Alltrim(cCodPro) $ Alltrim(cDesGenPtu)				
					PlsPtuPut("DS_SERVICO", cDesPro, aProcAux[Len(aProcAux)]) //Descricao do Servico.
				EndIf
			Else
				// MandatÛrio apenas para CodificaÁıes GenÈricas, Materiais TUSS (tipoTabela = 19) e Materias TNUMM (tipoTabela = 00),
				If Alltrim(cCodPro) $ Alltrim(cDesGenPtu) .Or. ((TpTab == "19" .Or. (TpTab == "00" .And. PtTpTabTus(,,.T.,.T.) == "19") .Or.; 
					BR8->BR8_TPPROC == "5") .And. dDataBase >= Stod("20190604"))
						
					PlsPtuPut("DS_SERVICO", cDesPro, aProcAux[Len(aProcAux)]) //Descricao do Servico.
				EndIf
			EndIf
		Else
			If Alltrim(cCodPro) $ Alltrim(cDesGenPtu) .Or. ;
				((TpTab $ "2/5" .Or. BR8->BR8_TPPROC == "5") .And. dDataBase >= Stod("20190604"))
				
				PlsPtuPut("DS_SERVICO", cDesPro, aProcAux[Len(aProcAux)])	  							//Descricao do Servico.
			EndIf
		EndIf
		
		PlsPtuPut("CODPAD", cCodPad, aProcAux[Len(aProcAux)])									//Informa CODPAD para utilizacao do PE PLPTUITE

		If cAliasIte == "BQV" .And. BQV->( FieldPos("BQV_OBSER1") ) > 0 .And. Empty(cObsEvo)
			cObsEvo := Alltrim(oObjBrw:FieldGet(cAliasIte+"_OBSER1",nX))
		Endif

		If (IIF(lPTUOn80,TpTab $ "22/98" .Or. (TpTab == "00" .And. PtTpTabTus(,,.T.,.T.) == "22"),TpTab $ "0/4"))
			cQtdItem := cValToChar(oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX) )
		else
			cDecItem := cValToChar(oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX) - Int(oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX)))
			cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
			cQtdItem := cValtoChar(int(oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX)) )+"."+cDecItem
		endIf	

		PlsPtuPut("QT_SERVICO",cQtdItem,aProcAux[Len(aProcAux)])	//Quantidade de um procedimento m⁄dico solicitado.

		If lReqOrdSer 
			PlsPtuPut("QT_AUTORIZ"	,cQtdItem,aProcAux[Len(aProcAux)])
		EndIf

		cValorUni := ''
		cValorTot := ''

		//se tem valor calculado pega
		if len(aValor) > 0 
			cValorTot := StrTran(StrZero(noRound(aValor[2],2),15,2),".","")
			cValorUni := StrTran(StrZero(noRound(aValor[2]/oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX),2),15,2),".","")
		endIf

		//se tem valor apresentado e este que deve ser considerado
		if !Empty(oObjBrw:FieldGet(cAliasIte+"_VLRAPR",nX))
			cValorUni := StrTran(StrZero(noRound(oObjBrw:FieldGet(cAliasIte+"_VLRAPR",nX),2),15,2),".","")
			cValorTot := StrTran(StrZero(noRound(oObjBrw:FieldGet(cAliasIte+"_VLRAPR",nX)*oObjBrw:FieldGet(cAliasIte+"_QTDPRO",nX),2),15,2),".","")
		endIf

		if ! empty(cValorUni) .And. ! empty(cValorTot)
			PlsPtuPut("VL_SERVICO" ,cValorTot,aProcAux[Len(aProcAux)])	//Valor do procedimento
			If !lPTUOn90
				PlsPtuPut("VL_UNI_SER" ,cValorUni,aProcAux[Len(aProcAux)])	//Valor do procedimento unitario
			EndIf
		elseIf (Alltrim(cCodPro) $ Alltrim(cDesGenPtu)) .Or. IIF(lRolUnimed .And. lPTUOn80,BR8->BR8_ROLUNI $ "1/2",.F.) // 1 = Coberto sem Valor; 2 = Sem Cobertura
			Aviso( STR0120,STR0500,{ STR0146}, 2 ) //"Atencao" //"Necess·rio informar o valor dos eventos Materiais/Medicamentos/Taxas/OPME GenÈricos, procedimentos cobertos sem valores e sem cobertura no Rol Unimed."  //"Ok"
			Return(.F.)
		EndIf
		If cAliasIte == "BQV" .And. BQV->( FieldPos("BQV_OBSER1") ) > 0
			cObser1BQV := Alltrim(oObjBrw:FieldGet(cAliasIte + "_OBSER1", nX))
			PlsPtuPut("OBSER1BQV", cObser1BQV, aProcAux[Len(aProcAux)])
		Endif

		If cAliasIte == "BQV" .And. BQV->( FieldPos("BQV_MEMO1") ) > 0
			cIndClin := Alltrim(oObjBrw:FieldGet(cAliasIte + "_MEMO1", nX))
			PlsPtuPut("INDCLIEVO", cIndClin, aProcAux[Len(aProcAux)])
		Endif

		//Verifica os campos de anexos - PTU 5.0                                       	 

		if (K_Alterar == nOpc .or. K_Evolucao == nOpc)

			If BR8->(FieldPos("BR8_ANEEDI"))> 0 .And. BR8->(Found()) .And. BR8->BR8_ANEEDI $ "123"
				If BR8->BR8_ANEEDI $ "2/3" 
					lBR8Anex := .T.     
					lAnexo   := .T.
					PlsPtuPut("TP_ANEXO",BR8->BR8_ANEEDI,aProcAux[Len(aProcAux)])  
				EndIf   	
			EndIf

			if cAliasCab == "BE4"
				BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
				if BEA->(DbSeek(xFilial("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT))) 
					cPesqAnex := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
				EndIf
			Else
				cPesqAnex := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
			EndIf

			if B4A->( msSeek( xFilial("B4A") + cPesqAnex ) )  

				while !B4A->( eof() ) .and. xFilial("B4A")+cPesqAnex == xFilial("B4A")+B4A->B4A_GUIREF   
					//Regras de Anexo:                                                   	  		  	     
					//Quimio: deve enviar os insumos como Anexo e honorario como nao anexo, necessario 	             
					//        parametrizar BR8_ANEEDI. Os insumos devem ser lancados na guia de anexo  	
					//Radio: deve enviar somente o honorario como anexo. necessario parametrizar 	            
					//        BR8_ANEEDI.                                                              
					//Opme: deve enviar os mat/med como Anexo e honorario como nao anexo. Os mat/med    
					//		devem ser lancados na guia de anexo 								                                   


					//Se anexo de radio, so preencho os dados para o honorario
					If B4A->B4A_TIPANE == "1" .And. !lBR8Anex 
						B4A->(dbSkip())
						Loop
					EndIf

					//Se anexo de quimio, so preencho os dados para insumos
					If B4A->B4A_TIPANE == "2" .And. lBR8Anex 
						B4A->(dbSkip())
						Loop
					EndIf   

					// Se ja comunicou pula registro 
					If !Empty(B4A->B4A_NRTROL)
						B4A->(dbSkip())
						Loop
					EndIf

					//Posiciono e rodo os anexos
					if B4C->( msSeek( xFilial("B4C") + B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) + IIf(B4A->B4A_TIPANE $ "23",oObjBrw:FieldGet(cAliasIte+"_CODPAD",nX) + oObjBrw:FieldGet(cAliasIte+"_CODPRO",nX),"")  ) )  .Or. B4A->B4A_TIPANE == '1'

						If Len(aFlgB4C) == 0
							aAdd(aFlgB4C,{B4C->(Recno()),B4C->(B4C_SEQUEN)})
						ElseIf aScan(aFlgB4C, {|x| x[1] == B4C->(Recno())} ) > 0 
							B4C->(dbGoTo(aFlgB4C[Len(aFlgB4C)][1] + 1))
							If Empty(B4C->(B4C_SEQUEN)) .Or. B4C->(B4C_SEQUEN) == '001'
								B4C->(dbGoTo(aFlgB4C[Len(aFlgB4C)][1]))
							Else
								aAdd(aFlgB4C,{B4C->(Recno()),B4C->(B4C_SEQUEN)})
							EndIf
						EndIf
						//Vers„o 3.03.00 da Tiss foram removidos os campos de procedimento da guia de radioterapia	
						If lTiss330 .And. B4A->B4A_TIPANE == '1'

							//07 CD_ANVISA - CÛdigo ANVISA do Material/Medicamento
							PlsPtuPut("CD_ANVISA", Space(15), aProcAux[Len(aProcAux)])							

							//08 CD_REF_FAB - Referencia do Material no Fabricante
							PlsPtuPut("CD_REF_FAB", Space(60), aProcAux[Len(aProcAux)])

							// DT_PROVAVE
							PlsPtuPut("DT_PROVAVE", Dtos(B4A->B4A_DATPRE) ,aProcAux[Len(aProcAux)])

						ElseIf B4A->B4A_TIPANE $ '12'

							PlsPtuPut("DT_PROVAVE", Dtos(B4C->B4C_DATPRO) ,aProcAux[Len(aProcAux)])	

						Else
							//07 CD_ANVISA - CÛdigo ANVISA do Material/Medicamento
							PlsPtuPut("CD_ANVISA", Padr(B4C->B4C_REGANV,15), aProcAux[Len(aProcAux)])

							//08 CD_REF_FAB - Referencia do Material no Fabricante
							PlsPtuPut("CD_REF_FAB", Padr(B4C->B4C_REFMAF,60), aProcAux[Len(aProcAux)])
							// DT_PROVAVE
							PlsPtuPut("DT_PROVAVE", Space(8) ,aProcAux[Len(aProcAux)])
						EndIf


						//11 CD_VIA_ADMIN - Via AdministraÁ„o 
						PlsPtuPut("CD_VIA_ADM",IIF(B4A->B4A_TIPANE == "2",B4C->B4C_VIAADM,Space(2)),aProcAux[Len(aProcAux)])

						//12 QT_FREQUENCIA - FrequÍncia da administraÁ„o
						PlsPtuPut("QT_FREQUEN",IIF(B4A->B4A_TIPANE == "2",Strzero(B4C->B4C_FREQUE,2),"00"),aProcAux[Len(aProcAux)])

						If B4A->B4A_TIPANE == '2'
							cDecDosag := cValToChar(B4C->B4C_QTDPRO - Int(B4C->B4C_QTDPRO))
							cDecDosag := Padr(Substr(cDecDosag,3,len(cDecDosag)),2,"0")
							cQtdDosag := cValtoChar(int(B4C->B4C_QTDPRO))+cDecDosag

							PlsPtuPut("TOT_DOSAGE",cQtdDosag,aProcAux[Len(aProcAux)])
							PlsPtuPut("UNI_MEDIDA",cValToChar(B4C->B4C_UNMED),aProcAux[Len(aProcAux)])						
						EndIf


						//09 TP_ANEXO - Indicador de Anexo    
						do Case
							Case B4A->B4A_TIPANE	== "1"

							PlsPtuPut("TP_ANEXO","2",aProcAux[Len(aProcAux)]) //2 = Indicador de Radioterapia

							if lRadio
								lRadio := .f.

								PlsPtuPut("DS_DIAG_RA",PTURemChr(Alltrim(B4A->B4A_DIAGCH)),aRadio) //DS_DIAG_CIT_HIST_RADIO - DescriÁ„o do diagnÛstico citopatolÛgico e histopatolÛgico
								PlsPtuPut("DS_INF_RAD",PTURemChr(Alltrim(B4A->B4A_INFREL)),aRadio) //DS_INF_RELEV_RADIO - InformaÁıes relevantes a serem fornecidas pelo profissional solicitante para esclarecimento do caso.
								PlsPtuPut("DS_RADIO",PTURemChr(Alltrim(B4A->B4A_OBSERV)),aRadio)   //DS_RADIO - ObservaÁ„o da Radioterapia    

								//Dados Anexo - Radioterapia                                     		
								PlsPtuPut("DT_DIAG",Dtos(B4A->B4A_DATDIA),aRadio) //01 DT_DIAG - Data do DiagnÛstico
								PlsPtuPut("CD_CID1",Padr(Substr(PLSDELIM(B4A->B4A_CIDPRI),1,4),4),aRadio) //02 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa
								PlsPtuPut("CD_CID2",Padr(Substr(PLSDELIM(B4A->B4A_CIDSEC),1,4),4),aRadio) //03 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa
								PlsPtuPut("CD_CID3",Padr(Substr(PLSDELIM(B4A->B4A_CIDTER),1,4),4),aRadio) //04 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa
								PlsPtuPut("CD_CID4",Padr(Substr(PLSDELIM(B4A->B4A_CIDQUA),1,4),4),aRadio) //05 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa
								PlsPtuPut("CD_ESTADIA",B4A->B4A_ESTADI,aRadio) //06 CD_ESTADIAMENTO - Estadiamento do Tumor
								PlsPtuPut("CD_FINALID",B4A->B4A_FINALI,aRadio) //07 CD_FINALI - CÛdigo da finalidade do tratamento
								PlsPtuPut("CD_ECOG",B4A->B4A_ECOG,aRadio) //08 CD_ECOG - ClassificaÁ„o internacional sobre capacidade funcional do benefici·rio
								PlsPtuPut("CD_DIAG_IM",B4A->B4A_DIAIMG,aRadio) //09 CD_DIAG_IMG Tecnologia Utilizada para diagnÛstico de imagem
								PlsPtuPut("QT_CAMPOS",Strzero(B4A->B4A_NROCAM,3),aRadio) //10 QT_CAMPOS - Quantidade de campos de irradiaÁ„o
								PlsPtuPut("QT_DOSE_DI",Strzero(B4A->B4A_DOSDIA,4),aRadio) //11 QT_DOSE_DIA - Dose de radioter·pico, expressa em Gy, por dia de tratamento
								PlsPtuPut("QT_DOSE_TO",Strzero(B4A->B4A_DOSTOT,4),aRadio) //12 QT_DOSE_TOTAL - Dose total, expressa em Gy, a ser utilizada considerando o n˙mero de dias e dosagem di·ria
								PlsPtuPut("QT_DIAS_TR",Strzero(B4A->B4A_NRODIA,3),aRadio) //13 QT_DIAS_TRAT - Quantidade de dias de tratamento previstos pelo profissional solicitante
								PlsPtuPut("DT_PREV_AD",DtoS(B4A->B4A_DATPRE),aRadio) //14 DT_PREV_ADMIN - Data prevista para inÌcio da administraÁ„o da radioterapia
								PlsPtuPut("DS_CIRURGI",PTURemChr(Substr(B4A->B4A_CIRURG,1,40)),aRadio) //15 DS_CIRURGIA - DescriÁ„o da cirurgia
								PlsPtuPut("DT_CIRURGI",Dtos(B4A->B4A_DATCIR),aRadio) //16 DT_CIRURGIA - Data da cirurgia
								PlsPtuPut("DS_QUIMIOT",PTURemChr(Substr(B4A->B4A_QUIMIO,1,40)),aRadio)//17 DS_QUIMIOTERAPIA - DescriÁ„o da Quimioterapia utilizada anteriormente, para a mesma patologia
								PlsPtuPut("DT_QUIMIOT",Dtos(B4A->B4A_DATQUI),aRadio) //18 DT_QUIMIOTERAPIA - Data em que foi realizada a quimioterapia anterior
								PlsPtuPut("NM_SOL_RAD",Substr(B4A->B4A_NOMSOL,1,40),aRadio) //19 NM_PRO_SOLIC_RADIO - Nome do Profissional Solicitante de Radio
								PlsPtuPut("NR_TEL_RAD",Strzero(Val(B4A->B4A_TELSOL),11),aRadio) //20 NR_TELEFONE_RADIO - N˙mero de Telefone do Profissional Solicitante de Radio
								PlsPtuPut("END_EM_RAD",Substr(B4A->B4A_EMASOL,1,60),aRadio) //21 END_EMAIL_RADIO - EndereÁo de E-mail do Profissional Solicitante de Radio
							endIf

							Case B4A->B4A_TIPANE	== "2"

							PlsPtuPut("TP_ANEXO","1",aProcAux[Len(aProcAux)]) //1 = Indicador de Quimioterapia
							lAnexo := .T.

							if lQuimio
								lQuimio := .f.    
								PlsPtuPut("DS_DIAG_QU",PTURemChr(Alltrim(B4A->B4A_DIAGCH)),aQuimio) //DS_DIAG_CIT_HIST_QUIMIO - DescriÁ„o do diagnÛstico citopatolÛgico e histopatolÛgico
								PlsPtuPut("DS_INF_QUI",PTURemChr(Alltrim(B4A->B4A_INFREL)),aQuimio) //DS_INF_RELEV_QUIMIO - InformaÁıes relevantes a serem fornecidas pelo profissional solicitante para esclarecimento do caso.
								PlsPtuPut("DS_PL_TERA",PTURemChr(Alltrim(B4A->B4A_PLATER)),aQuimio) //DS_PL_TERAP - Plano TerapÍutico proposto pelo profissional solicitante
								PlsPtuPut("DS_QUIMIO",PTURemChr(Alltrim(B4A->B4A_OBSERV)),aQuimio)  //DS_QUIMIO - ObservaÁ„o da Quimioterapia

								//Dados Anexo - Quimioterapia                                    		
								PlsPtuPut("NR_ALTBENE",StrTran(TransForm(B4A->B4A_ALTURA,PesqPict("B4A","B4A_ALTURA")),",","."),aQuimio) //01 NR_ALTBENEF - Altura do Benefici·rio
								PlsPtuPut("NR_PESOBEN",StrTran(TransForm(B4A->B4A_PESO  ,PesqPict("B4A","B4A_PESO"  )),",","."),aQuimio)   //02 NR_PESOBENEF - Peso do Benefici·rio
								PlsPtuPut("NR_SUPCORP",StrTran(TransForm(B4A->B4A_SUPCOR,PesqPict("B4A","B4A_SUPCOR")),",","."),aQuimio) //03 NR_SUPCORP - SuperfÌcie Corporal do Benefici·rio

								PlsPtuPut("DT_DIAG",Dtos(B4A->B4A_DATDIA),aQuimio) //04 DT_DIAG - Data do DiagnÛstico
								PlsPtuPut("CD_CID1",Padr(Substr(PLSDELIM(B4A->B4A_CIDPRI),1,4),4),aQuimio) //05 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa.
								PlsPtuPut("CD_CID2",Padr(Substr(PLSDELIM(B4A->B4A_CIDSEC),1,4),4),aQuimio) //06 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa.
								PlsPtuPut("CD_CID3",Padr(Substr(PLSDELIM(B4A->B4A_CIDTER),1,4),4),aQuimio) //07 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa.
								PlsPtuPut("CD_CID4",Padr(Substr(PLSDELIM(B4A->B4A_CIDQUA),1,4),4),aQuimio) //08 CD_CID - N˙mero do CÛdigo Internacional da DoenÁa.
								PlsPtuPut("CD_ESTADIA",B4A->B4A_ESTADI,aQuimio) //09 CD_ESTADIAMENTO - Estadiamento do Tumor
								PlsPtuPut("CD_FINALID",B4A->B4A_FINALI,aQuimio) //10 CD_FINALIDADE - CÛdigo da finalidade do tratamento
								PlsPtuPut("CD_ECOG",B4A->B4A_ECOG,aQuimio) //11 CD_ECOG - ClassificaÁ„o internacional sobre capacidade funcional do benefici·rio
								PlsPtuPut("TP_QUIMIO",B4A->B4A_TIPQUI,aQuimio) //12 TP_QUIMIO - Tipo de Quimioterapia N 01
								PlsPtuPut("NR_CICLOS",Strzero(B4A->B4A_NROCIC,2),aQuimio) //13 NR_CICLOS - N˙mero de ciclos previstos
								PlsPtuPut("NR_CL_ATUA",Strzero(B4A->B4A_CICATU,2),aQuimio) //14 NR_CL_ATUAL - Ciclo Atual
								PlsPtuPut("NR_INTERV",Strzero(B4A->B4A_INTCIC,3),aQuimio) //15 NR_INTERV - Intervalo entre ciclos
								PlsPtuPut("DS_CIRURGI",PTURemChr(Substr(B4A->B4A_CIRURG,1,40)),aQuimio) //16 DS_CIRURGIA - DescriÁ„o da cirurgia
								PlsPtuPut("DT_CIRURGI",Dtos(B4A->B4A_DATCIR),aQuimio) //17 DT_CIRURGIA - Data da cirurgia
								PlsPtuPut("DS_AREA_IR",PTURemChr(Substr(B4A->B4A_AREA,1,40)),aQuimio) //18 DS_AREA_IRRAD - DescriÁ„o da ·rea irradiada
								PlsPtuPut("DT_IRRAD",Dtos(B4A->B4A_DATIRR),aQuimio) //19 DT_IRRAD - Data da irradiaÁ„o
								PlsPtuPut("NM_SOL_QUI",Substr(B4A->B4A_NOMSOL,1,70),aQuimio) //20 NM_PRO_SOLIC_QUIMIO - Nome do Profissional Solicitante de Quimio
								PlsPtuPut("NR_TEL_QUI",Strzero(Val(SubStr(B4A->B4A_TELSOL,1,11)),11),aQuimio) //21 NR_TELEFONE_QUIMIO - N˙mero de Telefone do Profissional Solicitante de Quimio
								PlsPtuPut("END_EM_QUI",Substr(B4A->B4A_EMASOL,1,60),aQuimio) //22 END_EMAIL_QUIMIO - EndereÁo de E-mail do Profissional Solicitante de Quimio

								If B4A->(FieldPos('B4A_DCICAT')) > 0
									PlsPtuPut("CL_TUMOR",B4A->B4A_TUMOR,aQuimio) 
									PlsPtuPut("CL_NODULO",B4A->B4A_NODULO,aQuimio) 
									PlsPtuPut("CL_METASTA",B4A->B4A_METAST,aQuimio) 
									PlsPtuPut("QT_DIAS_CI",cValToChar(B4A->B4A_DCICAT),aQuimio) 
								EndIf		

							endIf

							Case B4A->B4A_TIPANE	== "3"

							PlsPtuPut("TP_ANEXO","3",aProcAux[Len(aProcAux)]) //3 = Indicador de OPME
							lAnexo := .T.

							If B4C->( FieldPos("B4C_ORDEDI") ) > 0 .And. ; 
							B4C->( msSeek( xFilial("B4C") + B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) + oObjBrw:FieldGet(cAliasIte+"_CODPAD",nX) + oObjBrw:FieldGet(cAliasIte+"_CODPRO",nX)  ) ) .And. ;
							!Empty(B4C->B4C_ORDEDI)

								nContOPME := B4C->B4C_ORDEDI
							Else
								nContOPME := "1"
							EndIf  

							PlsPtuPut("TP_ORDEM",cValToChar(nContOPME),aProcAux[Len(aProcAux)])

							if lOpme
								lOpme := .f.
								PlsPtuPut("NM_SOLIC_O",Padr(B4A->B4A_NOMSOL,70),aDados)  //24 NM_PRO_SOLIC_OPME - Nome do Profissional Solicitante de OPME
								PlsPtuPut("NR_TEL_OPM",Strzero(Val(SubStr(B4A->B4A_TELSOL,1,11)),11),aDados)  //25 NR_TELEFONE_OPME - N˙mero de Telefone do Profissional Solicitante
								PlsPtuPut("END_EM_OPM",Padr(B4A->B4A_EMASOL,60),aDados)  //26 END_EMAIL_OPME - EndereÁo de E-mail do Profissional Solicitante de OPME
								PlsPtuPut("DS_OPME",PTURemChr(Alltrim(B4A->B4A_OBSERV)),aDados)    //DS_OPME - ObservaÁ„o do OPME
								PlsPtuPut("DS_JUST_TE",PTURemChr(Alltrim(B4A->B4A_JUSTTE)),aDados) //DS_JUST_TEC - RelatÛrio profissional embasando a solicitaÁ„o
								PlsPtuPut("DS_MAT_SOL",PTURemChr(Alltrim(B4A->B4A_ESPMAT)),aDados) //DS_MAT_SOLIC DescriÁ„o do Material Solicitado
							endIf

							Otherwise
							PlsPtuPut("TP_ANEXO","9",aProcAux[Len(aProcAux)]) //9 = N„o anexo
						endCase			    	   

					endIf

					B4A->(dbSkip())
				endDo
			endIf
		endIf 
	
		If !lPTUOn80
			//se informar que o evento e pacote a observacao deve seguir com a composicao do pacote e a negociacao se da via chat.
			If TpTab == "4" .Or. lItemPacote
				PlsPtuPut("ID_PACOTE","S",aProcAux[Len(aProcAux)])
			EndIf

			If Empty(PlsPtuGet("ID_PACOTE", aProcAux[Len(aProcAux)] ))
				PlsPtuPut("ID_PACOTE","N",aProcAux[Len(aProcAux)])		
			Endif
		EndIf
		
		If Empty(PlsPtuGet("TP_ANEXO", aProcAux[Len(aProcAux)] ))
			PlsPtuPut("TP_ANEXO","9",aProcAux[Len(aProcAux)])		
		Endif

		If Empty(PlsPtuGet("SQ_ITEM", aProcAux[Len(aProcAux)] )) .And. (cAliasIte)->(FieldPos(cAliasIte+"_SEQPTU")) > 0
			PlsPtuPut("SQ_ITEM", StrZero(nSeqPtu,2), aProcAux[Len(aProcAux)])	
			oObjBrw:FieldPut(cAliasIte+"_SEQPTU",StrZero(nSeqPtu,2),nX)
		Endif	 		

		If Empty(PlsPtuGet("CD_ANVISA", aProcAux[Len(aProcAux)] ))
			PlsPtuPut("CD_ANVISA",cRegAnv ,aProcAux[Len(aProcAux)])		
		Endif

		If Empty(PlsPtuGet("CD_REF_FAB", aProcAux[Len(aProcAux)] ))
			PlsPtuPut("CD_REF_FAB",cRefFab ,aProcAux[Len(aProcAux)])		
		Endif                              

		If lPTUOn70 .And. cAliasIte == "BQV" .And. !Empty(oObjBrw:FieldGet(cAliasIte+"_TOKEDI",nX))

			If ! Empty(cToken) .And. cToken <> oObjBrw:FieldGet(cAliasIte+"_TOKEDI",nX)

				Aviso( 	STR0120, ; //"Atencao"
				STR0640,; //"N„o È possÌvel realizar a comunicaÁ„o, foram informados Tokens diferentes nos eventos do Complemento."
				{ STR0146 }, 2 )//"Ok"

				Return(lConf)

			Else
				cToken := oObjBrw:FieldGet(cAliasIte+"_TOKEDI",nX)  
			EndIf

		EndIf

		// Busca o item principal ou alternativo dos pacotes
		If lPTUOn80 .And. (TpTab == "98" .Or. lItemPacote)
			Do Case 
				Case TpTab == "98"
					aRetB43 := PlRetPac(&("M->"+cAliasCab+"_OPERDA"), &("M->"+cAliasCab+"_CODRDA"), cCodPad, cCodPro)
					
					For nNx := 1 To Len(aRetB43)
						If aRetB43[nNx][6] $ "1/2"
							aAdd(aItemPacote,{ Alltrim(aRetB43[nNx][1]), Alltrim(aRetB43[nNx][2]) })
						EndIf
					Next nNx

					lGuiaPacote := .T.

				Case lItemPacote .And. TpTab <> "98"
					aAdd(aGuiaPacote,{ Alltrim(cCodPad), Alltrim(cCodPro) })
			EndCase			
		EndIf

	Next

	If lGuiaPacote
		If Len(aGuiaPacote) == 0
			MsgInfo( STR0667 ) // "O Codigo Principal do Pacote n„o foi informado. "
			Return .F.
		EndIf
		
		If &("M->"+cAliasCab+"_CODRDA") <> GetNewPar("MV_PLSRDAG","999999")
			If Len(aItemPacote) == 0
				MsgInfo( STR0669 ) // "Dentro do Pacote informado n„o foi encontrado nenhum CÛdigo Principal ou Alternativo. Verifique o Cadastro do pacote."
				Return .F.
			EndIf
			
			For nNx := 1 To Len(aGuiaPacote)

				nPos := aScan(aItemPacote, {|x| x[1] == aGuiaPacote[nNx][1] .And. x[2] == aGuiaPacote[nNx][2] })
				If nPos == 0
					MsgInfo( STR0668 + aGuiaPacote[nNx][1] + "-" + aGuiaPacote[nNx][2]) // "CÛdigo principal informado na guia n„o foi encontrado no cadastro do pacote. "
					Return .F.
				EndIf

			Next nNx				
		EndIf	
	EndIf

endIf

//Se tem algum procedimento a ser enviado									 
If lEvolucao

	Do Case
		Case ! lEvoTem .And. ! lEvoCon .And. lEvoFim .And. ! lEvoExcl
			Aviso( STR0120,; //"AtenÁ„o"
			STR0263,; //"Todos os procedimentos da evolucao de GIH ja foram solicitados On-Line!"
			{ STR0146 }, 2 )//"Ok"
			Return(lConf)
		Case !lEvoTem .And. lEvoCon
		lEnvConclu := .T.
		Case !lEvoTem .And. !lEvoCon .And. lEvoExcl
		nPos := aScan(oObjBrw:aHeader,{|x| x[2] == cAliasIte+"_NRTROL"})
		If aScan(oObjBrw:aCols,{|x| x[len(oObjBrw:aHeader)+1] == .F. .And. Alltrim(x[nPos]) == Alltrim(cTranOri)}) > 0
			MsgInfo(STR0483+Alltrim(cTranOri))//"Para realizar a comunicaÁ„o, È necess·rio cancelar todos os complementos da transaÁ„o "
			Return(.F.)
					//Verifica se foram deletados itens de prorogacoes diferentes	
		ElseIf aScan(oObjBrw:aCols,{|x| x[len(oObjBrw:aHeader)+1] == .T. .And. Alltrim(x[nPos]) <> Alltrim(cTranOri)}) > 0
			MsgInfo(STR0647)//"Nao È possÌvel excluir complementos de transaÁıes diferentes. Verifique os campos Nr.Tr.Online."
			Return(.F.)
		Else
			aRetDesCan := PLSCANCCOM()
			If Empty(aRetDesCan[1])
				MsgInfo(STR0601)//"Para a vers„o 5.0 do PTU Online, È obrigatÛrio o preenchimento do motivo de cancelamento."
				Return(.F.)
			EndIf

			lRet := PtuCancEvo(cTranOri,cTranCanc,Alltrim(aRetDesCan[1]))

			If lRet
				cTrolComun := cTranOri
			EndIf

			Return(lRet)
		Endif
	EndCase
Else
	lEnvConclu := .T.
EndIf

//Para poder gravar as alteracoes sem mudar a fase da guia			  	

lNMudFase := nOpc <> K_Incluir

//Checando se ja comunicou												
//Se ja fez a primeira solicitacao agora so vai poder pedir revisao,		
//cancelar ou conclui o processo caso nao seja evolucao					

If &("M->"+cAliasCab+"_COMUNI") == "1" .And. lEnvConclu .And. !Empty(&("M->"+cAliasCab+"_NRAOPE") ) .And. !lEvolucao

	//Pega a atransacao de origem e destino									|

	cTranOri := AllTrim(&("M->"+cAliasCab+"_NRTROL"))
	cTranDes := AllTrim(&("M->"+cAliasCab+"_NRAOPE"))

	//Implementa as Matrizes												   

	aDadSeq  := PlsGetBSA( cTranOri,PlsIntPad() )
	aDados   := aClone(aDadSeq[1])

	//Matriz de comunicacao													|

	PlsPtuPut("NR_IDENT_O",cTranOri,aDados)     					 //Numero da Transacao Origem
	PlsPtuPut("NR_IDENT_D",cTranDes,aDados)   					 //Numero da Transacao Destino
	PlsPtuPut("CD_UNI_DES",cOpeUsu,aDados)						 //Codigo da Unimed Destino da transacao.
	PlsPtuPut("CUNIDOM",cOpeUsu,aDados)				 			 //Para qual operadora enviar

	//Funcao para envio de cancelamento,conclusao, cancelamento ou complemento	|

	PLSCONFSOL(oObjBrw,oBrwCri,cAliasCab,cAliasIte,cAliasCri,aDados,cTranOri,nOpc,lEvolucao)

	//Se ja comunicou uma vez e esta pedindo a revisao	pode sair para aguardar a resposta	|
	Return(lConf)
EndIf

//Mesmo padrao plsxmov desta forma o pos e web poderao usar				
PlsPtuPut("VIACAR",IIf(&("M->"+cAliasCab+"_VIACAR") == 0,"0",cValToChar(&("M->"+cAliasCab+"_VIACAR"))),aDados)

//Para internacao															
If lInternacao
	PlsPtuPut("DS_JUST_IN",PTURemChr(&("M->"+cAliasCab+"_DESJUS")),aDados)
	PlsPtuPut("QT_DIAS_DO",StrZero(&("M->"+cAliasCab+"_DIASIN"),5),aDados)
	PlsPtuPut("TP_ATENDIM","2",aDados) //Atendimento Hospitalar
	PlsPtuPut("DT_ATENDIM",DToS(&("M->"+cAliasCab+"_PRVINT")),aDados)  //Data do atendimento
Else
	If !lEvolucao
		PlsPtuPut("DT_ATENDIM",DToS(&("M->"+cAliasCab+"_DATSOL")),aDados)  //Data do atendimento
	EndIf
	PlsPtuPut("QT_DIAS_DO","00000",aDados) //Para Consulta/Sadt campo nao mandatorio
	If lConsulta
		PlsPtuPut("TP_ATENDIM","0",aDados)  //Nao se aplica
	Else
		PlsPtuPut("TP_ATENDIM","1",aDados)  //Atendimento Ambulatorial
	EndIf
EndIf

//Tipo de Atendimento (ID_URG_EMERG)       								

BDR->(DbSetOrder(1))//BDR_FILIAL+BDR_CODOPE+BDR_CODTAD
If BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+&("M->"+cAliasCab+"_TIPADM")))
	If BDR->BDR_CARINT == "E" //Eletiva
		cTipCon := "N"
	ElseIf BDR->BDR_CARINT == "U" //Urgencia/Emergencia
		cTipCon := "S"
	EndIf
Else
	cTipCon := "N"
EndIf

//Regime de Atendimento
PlsPtuPut("ID_URG_EME",cTipCon,aDados)  							

//Usado para definir qual tipo de transacao	                		    

PlsPtuPut("CTIPREQ","0",aDados)

//Genericos																
PlsPtuPut("OPEMOV",PlsIntPad(),aDados)
PlsPtuPut("USUARIO",subs(allTrim(aDadUsr[3]),iIf( len(allTrim(aDadUsr[3])) == 16 ,4,5) ),aDados)
PlsPtuPut("CIDPRI",&("M->"+cAliasCab+"_CID"),aDados)

//Especialidade EDI            											

DbSelectArea("BAQ")
BAQ->(DbSetOrder(1))//BAQ_FILIAL+BAQ_CODINT+BAQ_CODESP
If BAQ->(DbSeek(xFilial("BAQ")+PlsIntPad()+&("M->"+cAliasCab+"_CODESP"))) .And. BAQ->( FieldPos("BAQ_INTERC") ) > 0 .And. !Empty(BAQ->BAQ_INTERC)
	PlsPtuPut("CODESP",BAQ->BAQ_INTERC,aDados)
Else
	PlsPtuPut("CODESP",&("M->"+cAliasCab+"_CODESP"),aDados)
EndIf

//Usadas na transacao diretamente											

PlsPtuPut("CD_UNI_DES",cOpeUsu,aDados)										//Codigo da Unimed Destino da transacao.
PlsPtuPut("CUNIDOM",cOpeUsu,aDados)							 			    //Para qual operadora enviar
PlsPtuPut("ID_ALTO_CU",IiF(aDadRda[30]=="1","1","3"),aDados)				//Identifica se prestador da transacao de Alto Custo
PlsPtuPut("CD_UNI",cOpeUsu,aDados)					 						// Codigo da Unimed

If Empty(BAU->BAU_TIPRED)
	BAU->(dbSetOrder(1))
	BAU->(dbSeek(xFilial('BAU') + aDadRda[2] ))
EndIf	

// 1 = SolicitaÁ„o de autorizaÁ„o PrÈvia
// 2 = SolicitaÁ„o de autorizaÁ„o pelo prestador executante (AutorizaÁ„o)
cTpEtapaAut := IIF(BAU->BAU_CODIGO == GetNewPar("MV_PLSRDAG","999999"),"1","2")  

If !lPTUOn90 .Or. (lPTUOn90 .And. !lReqOrdSer)
	If cTpEtapaAut == "2" .Or. BAU->BAU_TIPRED $ "2/3" .Or. FunName() == "PLSA092" .Or. !lPtuOn80 // MandatÛrio se internaÁ„o ou tipoEtapaAutorizacao = 2 ou tpRedeMIN = 2 ou 3.

		PlsPtuPut("NM_PRESTAD",Pad(aDadRda[6],25),aDados)	 // Nome do prestador de Alto Custo.
		PlsPtuPut("CD_UNI_PRE",PlsIntPad(),aDados)           // Codigo da Unimed do Prestador do Servico.
		PlsPtuPut("CD_PREST",Padl(aDadRda[2],8,"0"),aDados)  // Codigo do Prestador

		If lPTUOn90
			If Type(cAliasCab+"_CODESP") <> "U" .And. !Empty(&(cAliasCab+"_CODESP"))
				If BAQ->(DbSeek(xFilial("BAQ")+&("M->"+cAliasCab+"_OPERDA")+&("M->"+cAliasCab+"_CODESP")))
					If !Empty(BAQ->BAQ_CBOS)
						PlsPtuPut("CD_CBO_EXEC", StrZero(Val(BAQ->BAQ_CBOS), 6), aDados)
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf
EndIf

If lPTUOn90
	// Dados de Prestador Solicitante, somente para guias de consulta n„o dever· ser enviado
	If !lConsulta
		If Type("M->"+cAliasCab+"_ESTSOL") <> "U" .And. Type("M->"+cAliasCab+"_REGSOL") <> "U"

			BB0->(DbSetOrder(4))
			If BB0->(DbSeek(xFilial("BB0")+&("M->"+cAliasCab+"_ESTSOL")+&("M->"+cAliasCab+"_REGSOL")))

				If FwIsNumeric(Alltrim(BB0->BB0_CODIGO))
					PlsPtuPut("CD_UNI_REQ", &("M->"+cAliasCab+"_OPESOL"), aDados)
					PlsPtuPut("CD_PRE_REQ", PadL(BB0->BB0_CODIGO, 8, "0"), aDados)
				EndIf

				PlsPtuPut("NM_PRO_SOLIC", PadR(&("M->"+cAliasCab+"_NOMSOL"), 70, ""), aDados)
				PlsPtuPut("SG_CONSEL", &("M->"+cAliasCab+"_SIGLA"), aDados)
				PlsPtuPut("NM_CONSEL", &("M->"+cAliasCab+"_REGSOL"), aDados)
				PlsPtuPut("UN_FEDERA", &("M->"+cAliasCab+"_ESTSOL"), aDados)
				
				// CBO Solicitante
				If Type(cAliasCab+"_ESPSOL") <> "U" .And. !Empty(&(cAliasCab+"_ESPSOL"))
					If BAQ->(DbSeek(xFilial("BAQ")+&("M->"+cAliasCab+"_OPESOL")+&("M->"+cAliasCab+"_ESPSOL")))
						PlsPtuPut("CD_CBO_SOL", StrZero(Val(BAQ->BAQ_CBOS), 6), aDados)
					EndIf
				EndIf

			EndIf

		EndIf
	EndIf

EndIF

If lPTUOn80
	If cTpEtapaAut == "2" .And. Empty(BAU->BAU_TIPRED) .And. !lReqOrdSer .And. !lEvolucao
		Help(,,STR0661,,STR0662, 1, 0,,,,,,{STR0663}) //"N„o informado" # "Tipo de Rede MandatÛrio se o tipo de AutorizaÁ„o for uma SolicitaÁ„o de autorizaÁ„o pelo prestador executante" # "Preencher o campo (Tp Rede Edi) no cadastro da Rede de Atendimento"
		Return(.F.)
	EndIf 
EndIf

If (!Empty(BAU->BAU_TIPRED) .And. cTpEtapaAut == "2") .Or. !lPtuOn80
	PlsPtuPut("TIPO_REDE_", BAU->BAU_TIPRED, aDados)
EndIf

If Empty(BAU->BAU_MUN) .And. lPTUOn80
	Help(,,STR0661,,STR0664, 1, 0,,,,,,{STR0665}) // "CÛdigo IBGE da cidade do escritÛrio, sede ou posto da Unimed MandatÛrio." # "Preencher o campo (Municipio) no cadastro da Rede de Atendimento"
	Return(.F.)
EndIf

PlsPtuPut("CD_IBGE", BAU->BAU_MUN, aDados)

If Empty((cAliasCab)->&(cAliasCab+"_GUIJUR")) .Or. (cAliasCab)->&(cAliasCab+"_GUIJUR") == '0'
	cIdLiminar := "N"
Else
	cIdLiminar := "S"
EndIf
PlsPtuPut("ID_LIMINAR", cIdLiminar, aDados)	

//Requisicao de Ordem de Servico / Solicitacao de Consulta/Exames			
If lReqOrdSer

	If cOpeUsu == PLSINTPAD() 
		lMeBenef:= .T.
	EndIf

	PlsPtuPut("CD_TRANS","00806",aDados)
	PlsPtuPut("ID_BENEF",PadL(IIf(!lMeBenef,Substr(&("M->"+cAliasCab+"_MATANT"),5,13),Substr(&("M->"+cAliasCab+"_USUARI"),5,13)),13,"0"),aDados)
	PlsPtuPut("DT_PROV_AD",DtoS(dProvAtend),aDados)

	PlsPtuPut("CD_UNI_EXE",PlsIntPad(),aDados)

	PlsPtuPut("CD_UNI_PRE",cCodOpeUni,aDados)
	PlsPtuPut("CD_PREST",Strzero(Val(cCodPre600),8),aDados)

	If lPTUOn90 // CBO Executante
		If !Empty(cCodEspOrdServ)
			If BAQ->(MsSeek(xFilial("BAQ")+cCodEspOrdServ))
				PlsPtuPut("CD_CBO_EXEC", StrZero(Val(BAQ->BAQ_CBOS), 6), aDados)
			EndIf
		EndIf
	EndIf

	PlsPtuPut("CD_CID",PLSDELIM(&("M->"+cAliasCab+"_CID")),aDados)

	If lInternacao .Or. lEvolucao
		PlsPtuPut("DT_VALIDAD",DtoS(&("M->"+cAliasCab+"_DATVAL")),aDados)
		PlsPtuPut("CD_UNI_PRE",PlsIntPad(),aDados)
		PlsPtuPut("CD_PREST","0000"+PlsIntPad(),aDados)
	Else
		PlsPtuPut("DT_VALIDAD",DtoS(&("M->"+cAliasCab+"_VALSEN")),aDados)
	EndIf

	If !lPTUOn90
		DbSelectArea("BAQ")
		BAQ->(DbSetOrder(1))//BAQ_FILIAL+BAQ_CODINT+BAQ_CODESP

		If BAQ->(DbSeek(xFilial("BAQ")+PlsIntPad()+&("M->"+cAliasCab+"_CODESP")))
			PlsPtuPut("CD_ESPEC",BAQ->BAQ_INTERC,aDados)
		EndIf
	EndIf

	DbSelectArea("BA1")
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO

	If BA1->(DbSeek(xFilial("BA1")+&("M->"+cAliasCab+"_USUARI")))  
		
		If !lPTUOn90
			PlsPtuPut("NR_VIA_CAR",IIf(BA1->BA1_VIACAR == 0,"00",cValtoChar(BA1->BA1_VIACAR)),aDados)
		EndIf

		PlsPtuPut("NM_BENEF",Substr(BA1->BA1_NOMUSR,1,25),aDados)

		If lPTUOn90 .And. BA1->(FieldPos("BA1_NOMSOC")) > 0 .And. !Empty(BA1->BA1_NOMSOC)
			PlsPtuPut("NM_NOMSOC",Substr(BA1->BA1_NOMSOC, 1, 70), aDados)
		EndIf

	EndIf
Else
	If lEvolucao
		PlsPtuPut("CD_TRANS","00605",aDados)	    	//Envio de Complemento
		PlsPtuPut("NR_TRANS_R",&("M->"+cAliasCab+"_NRTROL"),aDados)            //Transacao original
		PlsPtuPut("NR_IDENT_B",&("M->"+cAliasCab+"_NRAOPE"),aDados)            //Transacao original
	Else
		PlsPtuPut("CD_TRANS","00600",aDados)			//Codigo da Transacao
	EndIf
EndIf

PlsPtuPut("ID_RN",IIF(&("M->"+cAliasCab+"_ATERNA")=="1","S","N"),aDados) //21 ID_RN Indica se o benefici·rio È recÈm-nato 

//22 TP_INTERNACAO - Indica o Tipo de InternaÁ„o 
If cAliasCab == "BE4" .and. Type("M->"+cAliasCab+"_GRPINT") <> 'U' 
	Do Case
		Case &("M->"+cAliasCab+"_GRPINT")== "1" //1 = InternaÁ„o ClÌnica
		PlsPtuPut("TP_INTERNA","1",aDados)
		Case &("M->"+cAliasCab+"_GRPINT") == "2" //2 = InternaÁ„o Cir˙rgica 
		PlsPtuPut("TP_INTERNA","2",aDados)	
		Case &("M->"+cAliasCab+"_GRPINT") == "3" //3 = InternaÁ„o ObstÈtrica
		PlsPtuPut("TP_INTERNA","3",aDados)	
		Case &("M->"+cAliasCab+"_GRPINT") == "4" //6 = InternaÁ„o Pedi·trica
		PlsPtuPut("TP_INTERNA","6",aDados)
		Case &("M->"+cAliasCab+"_GRPINT") == "5" //7 = InternaÁ„o Psiqui·trica
		PlsPtuPut("TP_INTERNA","7",aDados)					
	EndCase
EndIf          

If !lPTUOn90
	//23 ID_ACIDENTE - Indicador de Acidente
	If Type("M->"+cAliasCab+"_INDACI") <> 'U'
		Do Case
			Case &("M->"+cAliasCab+"_INDACI") == "0" //1 = Acidente de Trabalho
			PlsPtuPut("ID_ACIDENT","1",aDados)
			Case &("M->"+cAliasCab+"_INDACI") == "1" //2 = Acidente de Tr‚nsito
			PlsPtuPut("ID_ACIDENT","2",aDados) 
			Case &("M->"+cAliasCab+"_INDACI") == "2" //3 = Acidente ñ Outros
			PlsPtuPut("ID_ACIDENT","3",aDados)	
			OtherWise
			PlsPtuPut("ID_ACIDENT","9",aDados) //9 = N„o acidente	
		EndCase   
	Else
		PlsPtuPut("ID_ACIDENT","9",aDados) //9 = N„o acidente	
	EndIf
EndIf

PlsPtuPut("CD_UNI_ATE",PlsIntPad(),aDados) 										//27 CD_UNI_ATEND - CÛdigo da Unimed na qual o Benefici·rio ser· atendido

If !lPTUOn90
	iIf(lAnexo,PlsPtuPut("ID_ANEXO","S",aDados),PlsPtuPut("ID_ANEXO","N",aDados)) 	//28 ID_ANEXO - Indica a existÍncia de um anexo na transaÁ„o
EndIf

If !lPTUOn90 .Or. (lPTUOn90 .And. lReqOrdSer)
	PlsPtuPut("TP_SEXO",iif(aDadUsr[25]=="2","3","1"),aDados) 						//29 TP_SEXO - Sexo do Benefici·rio

	B4C->( DbSetOrder(1) )//B4C_FILIAL + B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT + B4C_SEQUEN  
	If B4A->( msSeek( xFilial("B4A") + cPesqAnex ) )
		While B4A->B4A_GUIREF == cPesqAnex .And. !B4A->(Eof()) 
			If Empty(B4A->B4A_NRAOPE) .And. B4A->B4A_TIPANE $ "12" .And. B4A->B4A_IDADE <> 0
				nIdade := B4A->B4A_IDADE
				Exit	
			EndIf
			B4A->(DbSkip())
		EndDo
	EndIf 
	If nIdade == 0 .And. aDadusr[27] <> 0
		nIdade := aDadusr[27]
	EndIf    
	PlsPtuPut("NR_IDADE",Strzero(nIdade,3),aDados)
EndIf

PlsPtuPut("DT_SUG_INT",IIf(cAliasCab == "BE4",Dtos( &("M->"+cAliasCab+"_PRVINT")),Replicate(" ",8)),aDados) //31 DT_SUG_INTERNACAO - Data sugerida para a internaÁ„o

If cAliasCab == "BE4" .And. lPTUOn80
	If Empty(&("M->"+cAliasCab+"_PRVINT"))
		MsgInfo(STR0666) // "Data Sugerida para InternaÁ„o È obrigatÛrio na solicitaÁ„o de InternaÁ„o."
		Return(.F.)
	EndIf 
EndIf

//Se versao da tiss for diferente operadora e rda considera operadora
cTVerPTU := PLSTISSVER( &("M->"+cAliasCab+"_CODRDA") )

if lTVBA0BAU 
	BA0->(dbSetOrder(1))
	if BA0->(FieldPos("BA0_TISVER")) > 0 .and. BA0->( dbSeek(xFilial("BA0")+PLSIntPad() ) ) 
		if !empty(BA0->BA0_TISVER)
			cTVerPTU := allTrim(BA0->BA0_TISVER)
		endIf
	endIf
endIf

PlsPtuPut("NR_VER_TIS",cTVerPTU,aDados)		 //34 NR_VER_TISS  - N˙mero de vers„o da TISS que o prestador enviou a transaÁ„o

// N˙mero da TransaÁ„o da Ordem de ServiÁo
If !Empty(&("M->"+cAliasCab+"_NRTROS"))
	PlsPtuPut("NR_IDE_OS",Substr(&("M->"+cAliasCab+"_NRTROS"),1,10),aDados)			
Else
	PlsPtuPut("NR_IDE_OS",Replicate("0",10),aDados)									
Endif

If !lPTUOn90
	PlsPtuPut("ID_ORDEM_S", IIf(!Empty(&("M->"+cAliasCab+"_NRTROS")), "S", "N"), aDados) // Indica se o pedido de autorizaÁ„o foi gerado atravÈs de uma comunicaÁ„o de Ordem de ServiÁo
EndIf

//Faz a transacao												
//ponto de entrada para controlar o processamento do PTU on-line    
If ExistBlock("PL090VPTU")
	lRet := ExecBlock("PL090VPTU",.F.,.F., {aDadUsr,aDados,aProcAux})
	If !lRet
		Return(.F.)
	Endif
Endif

If !Empty(&("M->"+cAliasCab+"_NRTROL")) .And. !lEvolucao
	cTranUsada := AllTrim(&("M->"+cAliasCab+"_NRTROL"))
EndIf

//Novos campos PTU 7.0
If lPTUOn70
	If !Empty(cNumProto)
		PlsPtuPut("PROT_ATEND",cNumProto,aDados) 
	EndIf
	If cAliasIte != 'BQV' .And. !Empty(&("M->"+cAliasCab+"_TOKEDI"))
		PlsPtuPut("TOKEN",&("M->"+cAliasCab+"_TOKEDI"),aDados)
	ElseIf cAliasIte == 'BQV' .And. !Empty(cToken)
		PlsPtuPut("TOKEN",cToken,aDados)
	EndIf
EndIf

If lPTUOn80
	cTpGuia := IIF(lInternacao .Or. FunName() == "PLSA092","3",IIF(lConsulta,"1","2")) // 1 = Consulta , 2 = SP/SADT , 3 = InternaÁ„o
	PlsPtuPut("TP_GUIA",cTpGuia,aDados)
	
	If cTpGuia == "3" // Quando for uma InternaÁ„o ou ProrrogaÁ„o de InternaÁ„o
		If BI4->(DbSeek(xFilial("BI4")+M->BE4_PADINT))
			Do Case
				Case BI4->BI4_CODEDI == "1" // Apartamento(Individual)
					cTpAcomod := Padr("B",2)
				Case BI4->BI4_CODEDI == "2" // Enfermaria(Coletiva) 
					cTpAcomod := Padr("A",2)   
				Case BI4->BI4_CODEDI $ "3/4"// N„o se aplica 
					cTpAcomod := Padr("C",2)
				Otherwise
					cTpAcomod := "" 
			EndCase
		EndIf
	Else
		cTpAcomod := "C" // Quando for informado no campo tipoGuia = 1 (Consulta) ou 2 (SADT), utilizar a opÁ„o C = N„o se Aplica.
	EndIf
	
	PlsPtuPut("TP_ACOMODAC",cTpAcomod,aDados)

	PlsPtuPut("TP_ETAP_AUT",cTpEtapaAut,aDados) // Indica a etapa da solicitaÁ„o de autorizaÁ„o
	PlsPtuPut("DT_SOLICIT" ,cDtSolic,aDados) 	// Momento em que a Unimed Prestadora toma conhecimento do pedido
EndIf

If lPTUOn90 .And. !lEvolucao
	If Type(cAliasCab+"_COBESP") <> "U" .And. cTVerPTU >= "4.00.00" .And. !Empty(&(cAliasCab+"_COBESP"))
		PlsPtuPut("ID_COBESPE", cValToChar(Val(&(cAliasCab+"_COBESP"))), aDados)
	EndIf

	If Type(cAliasCab+"_TIPATE") <> "U" .And. !Empty(&(cAliasCab+"_TIPATE"))
		Do Case
			Case &(cAliasCab+"_TIPATE") == "14" // Admissional
				PlsPtuPut("ID_SAUDEOCUP", "1", aDados)

			Case &(cAliasCab+"_TIPATE") == "15" // Demissional
				PlsPtuPut("ID_SAUDEOCUP", "2", aDados)

			Case &(cAliasCab+"_TIPATE") == "16" // PeriÛdico
				PlsPtuPut("ID_SAUDEOCUP", "3", aDados)

			Case &(cAliasCab+"_TIPATE") == "17" // Retorno ao trabalho 
				PlsPtuPut("ID_SAUDEOCUP", "4", aDados)

			Case &(cAliasCab+"_TIPATE") == "18" // MudanÁa de funÁ„o 
				PlsPtuPut("ID_SAUDEOCUP", "5", aDados)

			Case &(cAliasCab+"_TIPATE") == "19" // PromoÁ„o ‡ sa˙de
				PlsPtuPut("ID_SAUDEOCUP", "6", aDados)
		EndCase
	EndIf
EndIf

nRecBA1 := BA1->(Recno())

aRet := {}
aRet := PLSANAINT(aDados,aProcAux,cAliasCab,.F.,lReqOrdSer,IIF(!Empty(&("M->"+cAliasCab+"_NRTROL")) .And. !lEvolucao,.T.,.F.),cObsEvo,cTranUsada,aQuimio,aRadio)

//Verifica
If ValType( aRet[1,2] ) == 'A'
	If lComunica
		lConf 	 	:= .F.
		cAutori   	:= aRet[1,1]
		cTranOri  	:= aRet[1,4]
		cSenhaOpe 	:= aRet[1,5]
		cObs 	 	:= aRet[1,6]
		cTrolComun 	:= cTranOri

		If lPTUOn90 .And. Len(aRet[1]) >= 9
			cNomeSocial := aRet[1][9]
		EndIf

		//Verfica se tem algum autorizado										   
		If cAutori $ '1,2'
			lUmAut := .T.
		EndIf

		//For dos procedimentos													
		For nX := 1 To Len(aRet[1,2])

			//Ajusta tamanho dos codigos dos procedimentos
			nPosCodPro := Ascan(aRet[1,2,nX],{|x|x[1] == "CD_SERVICO"})
			If nPosCodPro > 0
				If Len(aRet[1, 2, nX, nPosCodPro, 2]) > 8
					aRet[1, 2, nX, nPosCodPro, 2] := Strzero(Val(aRet[1, 2, nX, nPosCodPro, 2]), Len(aRet[1, 2, nX, nPosCodPro, 2]))
				Else  
					aRet[1, 2, nX, nPosCodPro, 2] := Strzero(Val(aRet[1, 2, nX, nPosCodPro, 2]), 8)
				EndIf
			EndIf

			nPosSaldo := aScan(aRet[1][2][nX], {|x|x[1] == "QT_SERVICO"})
			if nPosSaldo > 0 .And. cAliasIte == "BE2"
				nValSaldo := Val(aRet[1][2][nX][nPosSaldo][2])
			endIf
			//Verifica retorno de pacote e realiza a convers„o                        

			If PlsPtuGet("TP_TABELA",aRet[1,2,nX]) == "4" .And. !Empty(cCodPacote)
				nPos := Ascan(aRet[1,2,nX],{|x|x[1] == "CD_SERVICO"})
				If nPos > 0
					aRet[1,2,nX,nPos,2] := Alltrim(cCodPacote)
				EndIf
			EndIf

			// Pega a posicao do acos de procedimentos	( 11 e comunicado e auditoria)


			If lEvolucao

				If Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX])) $ Alltrim(cDesGenPtu)
					nPos := Ascan( oObjBrw:aCols , {|x| AllTrim(x[oObjBrw:PlRetPos(cAliasIte+"_CODPRO")])+AllTrim( StrTran(x[oObjBrw:PlRetPos(cAliasIte+"_TRACON")]," ","0") )+x[oObjBrw:PlRetPos(cAliasIte+"_NRAOPE")] == ;
					Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX]))+"0"+Space(TamSx3(cAliasIte+"_NRAOPE")[1]) .And. ;
					cValtoChar(Val( x[oObjBrw:PlRetPos(cAliasIte+"_SEQPTU") ] )) == cValtoChar(Val(PlsPtuGet("SQ_ITEM",aRet[1,2,nX]))) .And. x[Len(oObjBrw:aHeader)+1]  == .F.} )

					If nPos == 0 //Verifica se tem item ja comunicado anteriormente
						nPos := Ascan( oObjBrw:aCols , {|x| AllTrim(x[oObjBrw:PlRetPos(cAliasIte+"_CODPRO")])+AllTrim( StrTran(x[oObjBrw:PlRetPos(cAliasIte+"_TRACON")]," ","0") )+Alltrim(x[oObjBrw:PlRetPos(cAliasIte+"_NRAOPE")]) == ;
						Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX]))+"0"+Replicate("0",10) .And. ;
						cValtoChar(Val( x[oObjBrw:PlRetPos(cAliasIte+"_SEQPTU") ] )) == cValtoChar(Val(PlsPtuGet("SQ_ITEM",aRet[1,2,nX]))) .And. x[Len(oObjBrw:aHeader)+1]  == .F.} )
					EndIf
				Else
					nPos := Ascan( oObjBrw:aCols , {|x| AllTrim(x[oObjBrw:PlRetPos(cAliasIte+"_CODPRO")])+AllTrim( StrTran(x[oObjBrw:PlRetPos(cAliasIte+"_TRACON")]," ","0") )+x[oObjBrw:PlRetPos(cAliasIte+"_NRAOPE")] == ;
					Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX]))+"0"+Space(TamSx3(cAliasIte+"_NRAOPE")[1]) .And. ;
					x[Len(oObjBrw:aHeader)+1]  == .F. } )

					If nPos == 0 //Verifica se tem item ja comunicado anteriormente
						nPos := Ascan( oObjBrw:aCols , {|x| AllTrim(x[oObjBrw:PlRetPos(cAliasIte+"_CODPRO")])+AllTrim( StrTran(x[oObjBrw:PlRetPos(cAliasIte+"_TRACON")]," ","0") )+Alltrim(x[oObjBrw:PlRetPos(cAliasIte+"_NRAOPE")]) == ;
						Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX]))+"0"+Replicate("0",10) .And. ;
						x[Len(oObjBrw:aHeader)+1]  == .F. } )
					EndIf

				EndIf
			Else

				If Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX])) $ Alltrim(cDesGenPtu)
					nPos := Ascan( oObjBrw:aCols , {|x| AllTrim( x[oObjBrw:PlRetPos(cAliasIte+"_CODPRO") ] ) == Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX])) .And. ;
					cValtoChar(Val( x[oObjBrw:PlRetPos(cAliasIte+"_SEQPTU") ] )) == cValtoChar(Val(PlsPtuGet("SQ_ITEM",aRet[1,2,nX]))) .And. x[Len(oObjBrw:aHeader)+1]  == .F.} )
				Else
					nPos := Ascan( oObjBrw:aCols , {|x| AllTrim( x[oObjBrw:PlRetPos(cAliasIte+"_CODPRO") ] ) == Alltrim(PlsPtuGet("CD_SERVICO",aRet[1,2,nX])) .And. x[Len(oObjBrw:aHeader)+1]  == .F. } )
					If aScan(aRegPos, {|x| x == nPos}) > 0
						For nZ:= nPos To Len(oObjBrw:aCols) 
							If oObjBrw:aCols[nZ][4] == oObjBrw:aCols[nX][4] .And. aScan(aRegPos, {|x| x == nZ}) == 0
								nPos := nZ
								aAdd(aRegPos,nPos)
								exit
							EndIf
						Next
					Else	
						aAdd(aRegPos,nPos)
					EndIf
				EndIf
			EndIf

			// Se nao encontrar o procedimento erro no retorno						  

			If nPos <> 0

				// Se for evolucao  														  

				If lEvolucao

					// Se tiver pelo menos uma autorizado										 

					If lUmAut
						oObjBrw:FieldPut(cAliasIte+"_TRACON","1",nPos)
					Else
						oObjBrw:FieldPut(cAliasIte+"_TRACON","0",nPos)
					EndIf

					// Se comunicou															 
					oObjBrw:FieldPut(cAliasIte+"_COMUNI","1",nPos)
					nPosCriBQV := nPos //Gravo posicao para posterior utilizacao

					If lPTUOn70 .And. Empty(oObjBrw:aCols[nPos,PLRETPOS(cAliasIte+"_TOKEDI",oObjBrw:aHeader)]) .And. !Empty(cToken)
						oObjBrw:FieldPut(cAliasIte+"_TOKEDI",cToken,nPos)
					EndIf

				EndIf

				cTpAut := PlsPtuGet("ID_AUTORIZ",aRet[1,2,nX])

				// Transacao destino														  
				//Quando eu solicito transacao de usuario de outra operadora.														  
				If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_NRAOPE') )" ) > 0
					oObjBrw:FieldPut(cAliasIte+"_NRAOPE",IIf(cTpAut <> "2" .And. Empty(cSenhaOpe),Replicate("0",10),cSenhaOpe),nPos) 
				EndIf

				// Transacao origem														  

				If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_NRTROL') )" ) > 0
					oObjBrw:FieldPut(cAliasIte+"_NRTROL",cTranOri,nPos) //Codigo de minha transacao
				EndIf

				// Pega a sequencia														  

				nSequen := oObjBrw:aCols[nPos,PLRETPOS(cAliasIte+"_SEQUEN",oObjBrw:aHeader)]

				// Atualiza o procedimento												  

				If PlsPtuGet("ID_AUTORIZ",aRet[1,2,nX]) == "2"
					oObjBrw:FieldPut(cAliasIte+"_STATUS","1",nPos)
					oObjBrw:FieldPut(cAliasIte+"_IMGSTA","ENABLE",nPos)
					oObjBrw:FieldPut(cAliasIte+"_AUDITO","0",nPos)
					If cAliasIte == "BE2"
						oObjBrw:FieldPut(cAliasIte+"_SALDO",nValSaldo,nPos)
					EndIf
				Else
					oObjBrw:FieldPut(cAliasIte+"_STATUS","0",nPos)
					oObjBrw:FieldPut(cAliasIte+"_IMGSTA","DISABLE",nPos)
					oObjBrw:FieldPut(cAliasIte+"_AUDITO","0",nPos)
					lUmNeg := .T.
				EndIf

				// Limpa as criticas para atualizacoes									  

				For nY := 1 To Len(oBrwCri:aCols)
					If oBrwCri:FieldGet(cAliasCri+"_SEQUEN",nY) == nSequen
						oBrwCri:FieldPut(cAliasCri+"_CODGLO","",nY)
						oBrwCri:FieldPut(cAliasCri+"_DESGLO","",nY)
						oBrwCri:FieldPut(cAliasCri+"_INFGLO","",nY)
					EndIf
				Next

				// Tipo de retorno do item												  

				cTpAut := PlsPtuGet("ID_AUTORIZ",aRet[1,2,nX])

				// Pega a posicao do acols de criticas									  
				aCodCriIte := {}
				For nY := 1 To 5
					cCodCri := ""

					// Somente para casos 2 - autorizados ou 1 - negados						

					If cTpAut == "1" .Or. cTpAut == "2"

						// Caso exista criticas													  

						If Val(PlsPtuGet("CD_MENS_E"+AllTrim(Str(nY)),aRet[1,2,nX]) ) > 0

							// Pega a posicao da sequencia no acos									  

							nPos := 0
							For nI := 1 To Len(oBrwCri:aCols)
								If oBrwCri:FieldGet(cAliasCri+"_SEQUEN",nI) == nSequen .And. AllTrim(oBrwCri:FieldGet(cAliasCri+"_CODGLO",nI)) == ""
									nPos := nI
									Exit
								EndIf
							Next

							// Se achou atualiza se nao inclui										  

							If nPos == 0
								oBrwCri:AddBlank()
								nPos := Len(oBrwCri:aCols)
							EndIf

							//Posiciona na critica de Time-Out
							PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])

							//Verifica se e critica de time-out no retorno do arquivo (00301)
							If Alltrim(PlsPtuGet("CD_MENS_E"+AllTrim(Str(nY)),aRet[1,2,nX])) == __aCdCri065[1]
								cCodCri := __aCdCri102[1]
								cDesCri := PLSBCTDESC()
								lCriTime  := .T.
								//Verifica se critica de layout (Schema incorreto)	  
							ElseIf Alltrim(PlsPtuGet("CD_MENS_E"+AllTrim(Str(nY)),aRet[1,2,nX])) == __aCdCri228[1] 
								PLSPOSGLO(PLSINTPAD(),__aCdCri228[1],__aCdCri228[2])
								cCodCri := __aCdCri228[1]
								cDesCri := PLSBCTDESC()
								lCriTime  := .T.
							Else
								//Pega o codigo da critica 									  
								cCodCri := PlsRtcdCed(PlsIntPad(),PlsPtuGet("CD_MENS_E"+AllTrim(Str(nY)),aRet[1,2,nX]),4)
								If Empty(cCodCri)
									If PLSPOSGLO(PLSINTPAD(),__aCdCri102[1],__aCdCri102[2])
										cCodCri := __aCdCri102[1]
										cDesCri := PLSBCTDESC()
									EndIf
								Else
									cDesCri := PlsRtcdCed(PlsIntPad(),PlsPtuGet("CD_MENS_E"+AllTrim(Str(nY)),aRet[1,2,nX]),3)
								EndIf
							EndIf
							
							If aScan(aCodCriIte,{|x|x[1] == cCodCri}) > 0
								loop
							Else	
								Aadd(aCodCriIte,{cCodCri})
							EndIf

							//Atualiza																  
							oBrwCri:FieldPut(cAliasCri+"_SEQUEN",nSequen,nPos)
							oBrwCri:FieldPut(cAliasCri+"_CODGLO",cCodCri,nPos)
							oBrwCri:FieldPut(cAliasCri+"_DESGLO",cDesCri,nPos)

							If &(cAliasCri+"->(FieldPos('"+cAliasCri+"_CODEDI') )") > 0
								oBrwCri:FieldPut(cAliasCri+"_CODEDI",PlsPtuGet("CD_MENS_E"+AllTrim(Str(nY)),aRet[1,2,nX]) ,nPos)
							EndIf	

							If &(cAliasCri+"->(FieldPos('"+cAliasCri+"_CRIEDI') )") > 0
								oBrwCri:FieldPut(cAliasCri+"_CRIEDI",PlsPtuGet("DS_MENS_ES",aRet[1,2,nX]),nPos)
							EndIf

							If lEvolucao .And. lCriTime .And. nPosCriBQV > 0 //Preciso ajustar o item de evolucao sem comunicacao        
								oObjBrw:FieldPut(cAliasIte+"_COMUNI","0",nPosCriBQV)
							Endif   

							oBrwCri:FieldPut(cAliasCri+"_DMANED",PlsRtcdCed(PlsIntPad(),PlsPtuGet("CD_MENS_E"+AllTrim(Str(nY)),aRet[1,2,nX]),5),nPos)
						EndIf
						//Somente para os tipos 3 - pendente para autorizacao e 4 pendente para auditoria  

					Else
						If cTpAut == "3"
							If PLSPOSGLO(PLSINTPAD(),__aCdCri052[1],__aCdCri052[2])
								cCodCri := __aCdCri052[1]
								cDesCri := PLSBCTDESC()
							EndIf
						ElseIf cTpAut == "4"
							If PLSPOSGLO(PLSINTPAD(),__aCdCri051[1],__aCdCri051[2])
								cCodCri := __aCdCri051[1]
								cDesCri := PLSBCTDESC()
							EndIf
						EndIf

						// Marca como auditoria													

						oObjBrw:FieldPut(cAliasIte+"_AUDITO","1",nPos)
						lAudit := .T.

						// Pega a posicao da sequencia no brw criticas								

						nPos := Ascan( oBrwCri:aCols , { |x| AllTrim(x[oBrwCri:PlRetPos(cAliasCri+"_SEQUEN")]) == nSequen } )

						// Se achou atualiza se nao inclui										    

						If nPos == 0
							oBrwCri:AddBlank()
							nPos := Len(oBrwCri:aCols)
						EndIf

						// Atualiza																
						oBrwCri:FieldPut(cAliasCri+"_SEQUEN",nSequen,nPos)
						oBrwCri:FieldPut(cAliasCri+"_CODGLO",cCodCri,nPos)
						oBrwCri:FieldPut(cAliasCri+"_DESGLO",cDesCri,nPos)
						Exit
					EndIf
				Next
			Else
				Aviso( STR0120,STR0264,{ STR0146 }, 2 ) //"Nao ocorreu o retorno de todos os procedimentos!"
				Return(lConf)
			EndIf
		Next

		//Alimenta campos em memoria												
		&("M->"+cAliasCab+"_MSG03") := cObs

		If Len(aRet[1]) >= 8 .And. Type("M->BE1_VALSEN") == "D" .And. !Empty (aRet[1,8])
			&("M->"+cAliasCab+"_VALSEN") := STOD(aRet[1,8])
		EndIf

		If lPTUOn90 .And. ValType(&("M->"+cAliasCab+"_NOMSOC")) == "C" .And. !Empty(cNomeSocial)
			&("M->"+cAliasCab+"_NOMSOC") := cNomeSocial
		EndIf

		If lPTUOn80 .And. PlsAliasExi("B6M")
			If !lEvolucao
				aAdd(aDadB6MAux, {"B6M_TIPGUI", cTpGuia}) 
				aAdd(aDadB6MAux, {"B6M_ALIAS" , IIF(cAliasCab == "BE1","BEA",cAliasCab)})
				If !lReqOrdSer     
					aAdd(aDadB6MAux, {"B6M_ETAAUT", cTpEtapaAut})
					aAdd(aDadB6MAux, {"B6M_DTSOLI", StoD(cDtSolic)})  
					aAdd(aDadB6MAux, {"B6M_TPACOM", cTpAcomod})   
				EndIf				
			Else
				aAdd(aDadB6MAux, {"B6M_TPACOM", cTpAcomod})
				aAdd(aDadB6MAux, {"B6M_ALIAS" , cAliasIte})  				
			EndIf
			aAdd(aDadB6MAux, {"B6M_NRAOPE", cSenhaOpe})
			aAdd(aDadB6MAux, {"B6M_NRTROL", cTranOri})	

			aAdd(aDadB6M,aDadB6MAux)
		EndIf

		//Nao e evolucao															
		If !lEvolucao

			//Se pelo menos um foi autorizado conclui a trancacao                        
			//!lCriTime -> Unimed VS solcitou a possibilidade de reenvio quando houver   
			//critica de Time-Out, assim nao concluo a transacao                         

			If lUmAut .And. !lCriTime
				&("M->"+cAliasCab+"_TRACON") := "1"
			Else
				&("M->"+cAliasCab+"_TRACON") := "0"
			EndIf

			//Transacao destino,comunicou e transacao origem							|

			&("M->"+cAliasCab+"_NRAOPE") := cSenhaOpe  //Quando eu solicito transacao de usuario de outra operadora.
			&("M->"+cAliasCab+"_NRTROL") := cTranOri

			//!lCriTime -> Unimed VS solcitou a possibilidade de reenvio quando houver   
			//critica de Time-Out, assim nao seto como comunicado                        

			&("M->"+cAliasCab+"_COMUNI") := Iif(!lCriTime,"1","0")

			//Botao Auto Online, vai atualizar Status da guia de acordo com a comunicacao

			If lBtnOn
				nPos  := PLRETPOS(cAliasIte+"_STATUS",oObjBrw:aHeader,.F.)
				For nFor := 1 To Len(oObjBrw:aCols)
					If ! oObjBrw:aCols[nFor,Len(oObjBrw:aHeader)+1]
						If nPos > 0
							If  oObjBrw:aCols[nFor,nPos] == "1"
								nItensAut ++
							Else
								nItensNeg ++
							Endif
						Endif
					Endif
				Next

				//Verifica status da guia 										         	|

				If ( nItensNeg == 0 .And. nItensAut >= 1 )
					cStatus := "1" //Autorizada
				ElseIf ( nItensNeg > 0  .And. nItensAut >= 1 )
					cStatus := "2" //Autorizada parcialmente
				ElseIf ( nItensNeg > 0 .And. nItensAut == 0 )
					cStatus := "3" //nao autorizada
				Endif
			EndIf

			//Se esta em auditoria														|
			If lAudit
				&("M->"+cAliasCab+"_AUDITO") := "1"
			ElseIf lBtnOn .And. !lAudit
				&("M->"+cAliasCab+"_AUDITO") := "0"
			EndIf

			//Se for autorizacao total ou parcial situac 1 - ativa ou 3-bloqueada     

			If cAutori == "1" .Or. cAutori == "2"
				cSituac    := "1"
				cSituacPTU := "1"
			Else
				cSituac    := "3"
				cSituacPTU := "3"
			EndIf

			//Se for direfente de incluir											   

			If nOpc <> K_Incluir

				//Se for internacao ou evolucao											  

				If cAliasCab == "BE4"
					SIX->(DbSetOrder(1))
					If SIX->( MsSeek("BEAM") )
						BEA->( DbSetOrder(22) )	//BEA_FILIAL + BEA_NRTROL
						If !BEA->( MsSeek( xFilial("BEA")+BE4->BE4_NRTROL ) )
							lEnc := .F.
						EndIf
					EndIf
				EndIf

				//Se nao encontra nao atualiza o status da guia							  

				If lEnc .And. !lBtnOn
					PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,"1",NIL,NIL,.T.,,,,,,,,,Iif(lBtnOn,cStatus,"3"))
				ElseIf !lBtnOn
					Alert(STR0322+" ("+BE4->BE4_NRTROL+")!")//"Nao foi possivel atualizar o status da guia na transacao"
				EndIf
			EndIf
		EndIf
	EndIf

	//Mostra resultado da comunicacao											

	If GetNewPar("MV_PTGLOBO","1") <> "1"
		aResComuni := {oObjBrw,oBrwCri,cAutori,cSenhaOpe,cTranOri,cAliasCab,aRet,lReqOrdSer,""}
	Else
		PTUResCom(oObjBrw,oBrwCri,cAutori,cSenhaOpe,cTranOri,cAliasCab,aRet,lReqOrdSer,nRecBA1)
	Endif

	//Se ok na revisao exibe msg												
	If lAudit
		If GetNewPar("MV_PTGLOBO","1") == "1"
			Aviso( "AUDITORIA",STR0222,{ STR0146 }, 2 ) //"Aguarde resposta da auditoria!"//"Ok"
		ElseIf len(aResComuni) > 8
			cAvisoRet := STR0222
		EndIf
	EndIf

	//Unimed dominio envio													

	PlsPtuPut("CUNIDOM",cOpeUsu,aDados)				 			 //Para qual operadora enviar

	//Funcao para envio de cancelamento,conclusao ou revisao					

	If !lUmAut .And. !lReqOrdSer .And. GetNewPar("MV_PTGLOBO","1") == "1" .And. !lCriTime
		PLSCONFSOL(oObjBrw,oBrwCri,cAliasCab,cAliasIte,cAliasCri,aDados,cTranOri,nOpc,lEvolucao)
	EndIf

	//Houve resposta do WSD, gravo informacoes para posterior reenvio  		

ElseIf ValType( aRet[1,3] ) == 'A' .And. len(aRet[1]) > 6

	For nX:= 1 to len(oObjBrw:aCols)

		//Marco eventos como nao autorizados                          	     	
		oObjBrw:FieldPut(cAliasIte+"_STATUS","0",nX)
		oObjBrw:FieldPut(cAliasIte+"_IMGSTA","DISABLE",nX)
		oObjBrw:FieldPut(cAliasIte+"_AUDITO","0",nX)

		//Pega a sequencia														

		nSequen := oObjBrw:aCols[nX,PLRETPOS(cAliasIte+"_SEQUEN",oObjBrw:aHeader)]

		//Pega a posicao da sequencia no aCols								    

		nPos := 0
		For nI := 1 To Len(oBrwCri:aCols)
			If oBrwCri:FieldGet(cAliasCri+"_SEQUEN",nI) == nSequen .And. AllTrim(oBrwCri:FieldGet(cAliasCri+"_CODGLO",nI)) == ""
				nPos := nI
				Exit
			EndIf
		Next

		//Se achou atualiza se nao inclui										    

		If nPos == 0
			oBrwCri:AddBlank()
			nPos := Len(oBrwCri:aCols)
		EndIf

		//Inclui criticas de Time-out de comunicacao         		   			    

		PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
		oBrwCri:FieldPut(cAliasCri+"_SEQUEN",nSequen,nX)
		oBrwCri:FieldPut(cAliasCri+"_CODGLO",__aCdCri065[1],nX)
		oBrwCri:FieldPut(cAliasCri+"_DESGLO",__aCdCri065[2],nX)
	Next

	//Indico que foi realizada comunicacao, nao concluida e num. de transacao 

	&("M->"+cAliasCab+"_TRACON") := "0"
	&("M->"+cAliasCab+"_NRTROL") := aRet[1][7]
	&("M->"+cAliasCab+"_COMUNI") := "1"

	If GetNewPar("MV_PTGLOBO","1") == "1"
		Aviso( STR0120,STR0501+Space(1)+aRet[1][7]+STR0502,{ STR0146 }, 2 ) //Atencao ##"N„o houve resposta para a transaÁ„o" ## ", favor confirmar a guia para posterior reenvio" ## Ok
	ElseIf len(aResComuni) > 8
		cAvisoRet := STR0501+Space(1)+aRet[1][7]+STR0502
	EndIf
EndIf

lRefresh := .T.

//Refresh nos brw s														

oObjBrw:Atualiza()
oBrwCri:ForceRefresh(oObjBrw)

//Atualiza Tela															

	ProcessMessage()
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} INSISTECOM
Solicitacao de insistencia para um atendimento que ja 	
sofreu comunicacao

@author  PLS TEAM
@version P11
@since   04.08.05
/*/
//-------------------------------------------------------------------
Static Function INSISTECOM(cAliasCab,oObjBrw)
	LOCAL nOpca	:= 1
	LOCAL aRet  := {.T.}
	LOCAL nI

	cSolRev1 := Space(254)
	cSolRev2 := Space(254)

	DEFINE MSDIALOG oDlg TITLE STR0223 FROM 008.2,003.3 TO 016,045 OF GetWndDefault() //"Insistencia - Informe a descricao"

@ 05,10 Say  STR0127  				PIXEL OF oDlg		 //"Descricao"
@ 15,10 MsGet cSolRev1 SIZE 150,08	PIXEL OF oDlg HASBUTTON
@ 25,10 MsGet cSolRev2 SIZE 150,08	PIXEL OF oDlg HASBUTTON

TButton():New(40,30, STR0340	,,{ || nOpca := 0 , IIf(!Empty(cSolRev1),oDlg:End(),MsgInfo(STR0495)) } , 040, 010 ,,,,.T.) //Confirma###"ObrigatÛrio informar a descriÁ„o da insistÍncia"
TButton():New(40,90, STR0329	,,{ || nOpca := 1 , oDlg:End() } , 040, 010 ,,,,.T.) //Cancelar

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 0
	If Type("M->"+cAliasCab+"_MSG04") == "C"

		&("M->"+cAliasCab+"_MSG04") := cSolRev1

		If Type("M->"+cAliasCab+"_MSG06") == "C"
			&("M->"+cAliasCab+"_MSG06") := cSolRev2
		Endif

		//Limpa a resposta														 

		If Type("M->"+cAliasCab+"_MSG05") == "C"
			&("M->"+cAliasCab+"_MSG05") := ""
		EndIf
		If Type("M->"+cAliasCab+"_MSG07") == "C"
			&("M->"+cAliasCab+"_MSG07") := ""
			Endif

		Endif

		AaDd(aRet,{cSolRev1+cSolRev2})
	Else
		aRet[1] := .F.
	EndIf

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCANCCOM
Monta tela para indicar motivo de cancelamento PTU Online

@author  PLS TEAM
@version P11
@since   16.12.14
/*/
//-------------------------------------------------------------------
Function PLSCANCCOM()
	LOCAL nOpca	:= 1
	LOCAL aRet  := {}
	LOCAL nI
	LOCAL cDesCancel := Space(254)

	DEFINE MSDIALOG oDlg TITLE STR0607 FROM 008.2,003.3 TO 016,045 OF GetWndDefault() //"Cancelamento - Informe o motivo"

@ 05,10 Say  STR0127  					PIXEL OF oDlg		 //"Descricao"
@ 15,10 MsGet cDesCancel SIZE 150,08	PIXEL OF oDlg HASBUTTON

TButton():New(40,30, STR0340,,{|| nOpca := 0 , IIf(!Empty(cDesCancel),oDlg:End(),MsgInfo(STR0608)) } , 040, 010 ,,,,.T.) //Confirma###"ObrigatÛrio informar o motivo de cancelamento."
TButton():New(40,90, STR0329,,{|| nOpca := 1 , oDlg:End() } , 040, 010 ,,,,.T.) //Cancelar

	ACTIVATE MSDIALOG oDlg CENTERED

	Aadd(aRet,Alltrim(cDesCancel))

	If nOpca == 0
		Aadd(aRet,.T.)
	Else
		Aadd(aRet,.F.)
	EndIf	

Return(aRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSASOEEXE
Verifica e faz a Solicitacao de exclusao	(intercambio)

@author  PLS TEAM
@version P11
@since   19.08.05
/*/
//-------------------------------------------------------------------
Function PLSASOEEXE(cAliasCab,lExe,lGih,lCancel,lEvolucao,lRPC,cDescCanc,aRetCan)

	Local aRetOln := {}
	Local aDadSeq := {}
	Local cChaveGuia := ""	
	Local cTranOri := ""
	Local cTranDes := ""
	Local aDados := {}
	Local aLogs := {}
	Local lRet := .T.
	Local cNomUsr := ""
	Local cMsgXsdErr := ""
	Local nPos := 0
	Local cGuiasAne := ""
	Local nX := 0
	Local aRetAnx := {}
	Local validA520 := .F.
	Local cVerPTUOnline := "0"+GetNewPar("MV_PTUVEON","70")

	Default lGih := .T.
	Default lCancel := .F.
	Default lEvolucao := .F.
	Default lRPC := .F.
	Default cDescCanc := STR0606 //"SolicitaÁ„o de Cancelamento"
	Default aRetCan := {}

	//Verifica se vai solicitar a exclusao									
	dBSelectArea(cAliasCab)

	If Len(aRetCan) > 1
		If aRetCan[2]
			cDescCanc := aRetCan[1]
		Else
			Return(.F.)
		EndIf
	EndIf

	If (Type("M->"+cAliasCab+"_COMUNI") == "C" .And. &("M->"+cAliasCab+"_COMUNI") == "1" .And. lComunica .And. !lExe) .Or. lCancel

		//Alimenta variaveis														
		If !lCancel

			If !lEvolucao
				cTranOri   := AllTrim(&("M->"+cAliasCab+"_NRTROL"))
			Else
				cTranOri   := cLastTran
			EndIf

			cTranDes   := &("M->"+cAliasCab+"_NRAOPE")
			cNomUsr := &("M->"+cAliasCab+"_NOMUSR")
		Else
			cTranOri   := AllTrim(&(cAliasCab+"->"+cAliasCab+"_NRTROL"))
			cTranDes   := &(cAliasCab+"->"+cAliasCab+"_NRAOPE")
			cNomUsr := &(cAliasCab+"->"+cAliasCab+"_NOMUSR")
		EndIf

		If cAliasCab =="BE4"
			cChaveGuia := &(cAliasCab+"->"+cAliasCab+"_CODOPE")+&(cAliasCab+"->"+cAliasCab+"_ANOINT")+&(cAliasCab+"->"+cAliasCab+"_MESINT")+&(cAliasCab+"->"+cAliasCab+"_NUMINT")
		ElseIf cAliasCab =="BEA"
			cChaveGuia := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")+&(cAliasCab+"->"+cAliasCab+"_ANOAUT")+&(cAliasCab+"->"+cAliasCab+"_MESAUT")+&(cAliasCab+"->"+cAliasCab+"_NUMAUT")
		ElseIf cAliasCab =="BE1"
			cChaveGuia := &("M->"+cAliasCab+"_NUMAUT")
		EndIf

		//Implementa as Matrizes													
		aDadSeq := PlsGetBSA( cTranOri,PlsIntPad() )
		aDados := aClone(aDadSeq[1])

		//Implementea a aDados													
		PlsPtuPut("CD_TRANS", "00311", aDados) // Envio de Cancelamento
		PlsPtuPut("NR_IDENT_O", cTranOri, aDados) // Numero da Transacao Origem
		PlsPtuPut("NR_IDENT_D", cTranDes, aDados) // Numero da Transacao Destino
		PlsPtuPut("TP_IDENTIF", "1", aDados) // Cancelada
		PlsPtuPut("NR_VERSAO", cVerPTUOnline, aDados)

		If !Empty(cDescCanc) //PTU Online Versao 5.0 ou superior
			PlsPtuPut("DS_MOTIVO",cDescCanc,aDados)                   //DS_MOTIVO  - DescriÁ„o do Motivo do Cancelamento
		EndIf

		//Ajusta Operadoras Destino/Origem										
		If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_CODEMP"+"'))") > 0 .And. GetNewPar("MV_PLSGEIN","0050") == &(cAliasCab+"->"+cAliasCab+"_CODEMP")
			If (nPos := aScan(aDados,{|x|x[1] == "CD_UNI_ORI"})) > 0
				aDados[nPos][2] := PlsIntPad()   										//Codigo da Unimed Origem
			Endif
			If (nPos := aScan(aDados,{|x|x[1] == "CD_UNI_DES"})) > 0
				aDados[nPos][2] := Substr(&(cAliasCab+"->"+cAliasCab+"_MATANT") ,1,4) //Codigo da Unimed Destino
			Endif
		Endif

		//Processamento															
		aGrvTraPTU := {AllTrim(cTranOri),PlsPtuGet("CD_TRANS",aDados),PlsIntPad(),PlsPtuGet("CD_UNI_DES",aDados),cNomUsr}

		If lRPC
			aRetOln := PlsPtuOln(aDados, {}, AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3) ,.T.,lRPC,aGrvTraPTU,,,@cMsgXsdErr) 
		Else
			MsAguarde( {|| aRetOln := PlsPtuOln(aDados, {}, AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3) ,.T.,.F.,aGrvTraPTU ,,,@cMsgXsdErr) }, 'Comunicando' , STR0177, .F.) //"Aguarde..."
		EndIf

		//Tratamento do Retorno
		If Len(aRetOln) > 0

			//Retorno
			If (PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310" .or. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00210") .and. Len(aRetOln[2]) == 0

				BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2

				If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
					Aviso( STR0120, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0146 }, 2 )//"Atencao"//"Ok"
				ElseIf PlsPtuGet("CD_MENS_EX",aRetOln[1]) == "4003"
					PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
					Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )//"Atencao"//"Ok"
				Else
					Aviso( STR0120,"codigoMensagemExcecao: "+PlsPtuGet("CD_MENS_EX",aRetOln[1])+STR0632,{ STR0146 }, 2 )	//"Atencao" //" - Entre em contato com o administrador do sistema."
				EndIf

				lRet := .F.

			elseif !lCancel 
				//Trata o Retorno da Comunicacao				 						   
				If PlsPtuGet("ID_CONFIRM",aRetOln[1]) == "S" .And. Len(aRetOln[2]) == 0
					Aviso( STR0120,STR0179,{ STR0146 }, 2 )  			   			    //"Atencao" //"Inconsistencia no retorno!" //"Ok"
					lRet := .F.

					//Verifica se foi enviada a transacao correta na resposta                 
				ElseIf PlsPtuGet("CD_TRANS ",aRetOln[1]) <> "00309"

					AaDd(aLogs,{STR0425,STR0426+"00209"})//"TransaÁ„o de Resposta Incorreta"#"Diferente de"
					PLSCRIGEN(aLogs,{ {STR0243,"@C",90} , {STR0244,"@C",80 } },STR0245) //"Campo"###"Conteudo"###"Resumo da Comunicacao"
					lRet := .F.
				Else

					//verifica se existe guias avisadas A520
					validA520 := chkA520(BD5->BD5_CODOPE,BD5->BD5_CODLDP,BD5->BD5_CODPEG)

					//Checa se vai excluir														|
					If !Empty(cChaveGuia) .And. lGih
						If validA520
							lRet:= .F.
						Else
							lRet := PLSXEXCA(cChaveGuia,__cTipo)
						Endif
					EndIf

					//Retorno																	|

					If !lRet
						Aviso( "EXCLUSAO",STR0226,{ STR0146 }, 2 ) 	//"N„o foi possivel EXCLUIR a GUIA"###"Ok"
						PlsPtuLog(STR0227) //"*** NAO FOI POSSIVEL EXCLUIR A GUIA ***"
					Else
						Aviso( "EXCLUSAO",STR0228,{ STR0146 }, 2 )//"*** EXCLUSAO CONCLUIDA ***""###""Ok"
						PlsPtuLog(STR0228) //"*** EXCLUSAO CONCLUIDA ***"

						//Cancela as guias de Anexos Clinicos vinculadas.
						B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF
						If B4A->( msSeek( xFilial("B4A")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

							aRetAnx := PLSA0A2CAN(.T., .F.)

							If len(aRetAnx) > 2      
								For nX := 1 to len(aRetAnx[3])    
									If aRetAnx[3][nX][1] == "B4A"
										B4A->(DbGoto(aRetAnx[3][nX][2]))	
										cGuiasAne += IIf(!Empty(cGuiasAne),", ","") + B4A->(B4A_OPEMOV+"-"+B4A_ANOAUT+"."+B4A_MESAUT+"-"+B4A_NUMAUT)
									EndIf
								Next
							EndIf

							If !Empty(cGuiasAne)
								Aviso( STR0120,STR0626+cGuiasAne,{ STR0146 }, 2 ) //"Atencao" //"Foram canceladas as guias de Anexos ClÌnico vinculadas a guia cancelada: " //"Ok"      
							Else				      
								//Verifica se ha anexos pendentes
								B4A->(DbSetOrder(4))//B4A_FILIAL+B4A_GUIREF
								If B4A->(MsSeek(xFilial("B4A")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
									While B4A->B4A_GUIREF == BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) .And. !B4A->(Eof())
										cGuiasAne += IIf(!Empty(cGuiasAne),", ","") + B4A->(B4A_OPEMOV+"-"+B4A_ANOAUT+"."+B4A_MESAUT+"-"+B4A_NUMAUT)
										B4A->(DbSkip())
									EndDo   

									If !Empty(cGuiasAne)
										Aviso( STR0120,STR0627+cGuiasAne,{ STR0146 }, 2 ) //"Atencao" //"H· guias de Anexos ClÌnico pendentes vinculadas a guia cancelada: " //"Ok"
									EndIf
								EndIf	
							EndIf 		
						EndIf
					EndIf

				EndIf

				// Encerra o protocolo de atendimento pendente			        			
			ElseIf GetNewPar("MV_PL395WS","0") == "1" .And. PLSALIASEX("B4J")
				atuProCanc(cTranOri,PlsPtuGet("CD_UNI_DES",aDados),cDescCanc)
			EndIf

		else
			If !Empty(@cMsgXsdErr)
				MsgInfo(@cMsgXsdErr)
			Else		
				//Mostra o Log															   
				PlsPtuLog(STR0321)//"INCONSISTENCIA NA OPERACAO DE ENVIO!"
				MsgAlert(STR0321) //"INCONSISTENCIA NA OPERACAO DE ENVIO!"
			EndIf    
			lRet := .F.
		Endif

	EndIf

Return(lRet)

/*/{Protheus.doc} PLSA090CAN
Faz o cancelamento de uma gui

@author  PLS TEAM
@version P11
@since   29.07.05
/*/
Function PLSA090CAN(lRPC,cMotivo,cRecno,lCanAudit, nStatusTiss) 
	LOCAL cFaseGuia 	:= ""
LOCAL cSeqPF    	:= ""
LOCAL cMsg			:= ""
Local cChavSE1 		:= ""
Local cSE1 			:= ""
Local aRetDesCan 	:= {}
Local lOriAud 		:= iIf( upper(funName()) == "PLSA790V", .t., .f.)
Local lIntern		:= .F.
Local cChvSE1		:= ""
local lOk			:= .t.
LOCAL aRetAnx		:= {}
LOCAL lAnex			:= .F.
LOCAL lCanNow		:= .F.
LOCAL cGuiasAne 	:= ""
LOCAL nX        	:= 0
LOCAL aMotCanc  	:= {} 
Local lApagaGuia 	:= getNewPar("MV_PLAUDAN",.F.) // Determina que mesmo se a guia estiver na auditoria EM analise podera ser excluida
Local lConfPTU   	:= .F.
Local cChaveHAT     := ""
Local cCodTra       := ""
LOCAL aAreaBEA      := {}
Local nCont			:= 0
Local cNrlBor		:= ""
Local cSql			:= ""
Local cChave		:= ""

default lCanAudit 	:= .F. 
default lRPC		:= .F.
default cMotivo		:= STR0606 //'SolicitaÁ„o de cancelamento'
default cRecno		:= 0
default nStatusTiss	:= 0

if type(_cancel_BEA_atu) <> "U"
	cCodTra       := _cancel_BEA_atu
endif

if cRecno > 0
	BEA->(dbGoto(cRecno))
endIf

if lRPC .and. !empty(cMotivo) 
	aadd(aRetDesCan,cMotivo)
endif

//Verifica se a guia foi cobrada (custo, VD, Co-Participacao, Etc)        
BCI->(DbSetOrder(1))
If BCI->( MsSeek( xFilial("BCI") + BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG) ) )

	If BCI->BCI_TIPGUI $ "01,02,13"

		//Se for online nao deixa cancelar por aqui							    
		If ! Empty(BEA->BEA_NRTROL) .And. BEA->BEA_CODEMP <> GetNewPar("MV_PLSGEIN","0050")

			lOk := .f.

			If lRPC
				cMsg := STR0278
			Else
				aviso( STR0120, STR0278 , {  STR0146  }, 2 ) //"Guia On-Line, n„o e possÌvel fazer este tipo de cancelamento!"
			endIf		

		EndIf

		//BD5																	  
		if lOk

			BD5->(DbSetOrder(1))
			If BD5->(MsSeek(xFilial("BD5") + BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))			

				cSeqPF    := BD5->BD5_SEQPF
				cFaseGuia := BD5->BD5_FASE

				BAU->( dbSetOrder(1) )//BAU_FILIAL+BAU_CODIGO

				//ValidaÁ„o de local de digitaÁ„o e fase da guia para cancelamento.
				//Regras: Caso guia esteja faturada (fase 4) ou codldp = 9999 ou 0003, nao permite o cancelamento
				if cFaseGuia == '4'

					if lRPC
						cMsg := "Guias faturadas n„o podem ser canceladas."
					else
						aviso( STR0120, "Guias faturadas n„o podem ser canceladas." , {  STR0146  }, 2 )
					endIf

					lOk := .f.

					//Guia de intercambio permite o cancelamento
				elseIf ! empty(BEA->BEA_NRTROL) .and. BEA->BEA_OPESOL == PlsIntPad()

					lOk := .t.

					//Modelo antigo de Pegs, permite o cancelamento
				elseIf BAU->(MsSeek(xFilial("BAU") + BEA->BEA_CODRDA)) .and. BAU->BAU_OBRPTO != "1"

					lOk := .t.

				elseIf ! ( BD5->BD5_CODLDP $ ( PLSRETLDP(9) + '|' + PLSRETLDP(3) ) )

					if lRPC
						cMsg := "Esta guia n„o pode ser cancelada, consulte a operadora."
					else
						aviso( STR0120, "Esta guia n„o pode ser cancelada, consulte a operadora." , {  STR0146  }, 2 )
					endIf

					lOk := .f.

				endIf

			endIf

		endIf	

	else

		lIntern := .t.

		BE4->(dbSetOrder(1))
		if BE4->( msSeek( xFilial("BE4") + BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))

			cSeqPF    := BE4->BE4_SEQPF
			cFaseGuia := BE4->BE4_FASE

			//Se for online nao deixa cancelar por aqui								
			if BE4->( fieldPos("BE4_NRTROL") ) > 0 .and. ! empty(BE4->BE4_NRTROL) .And. BE4->BE4_CODEMP <> GetNewPar("MV_PLSGEIN","0050")

				lOk := .f.

				if lRPC
					cMsg := STR0278
				else
					aviso( STR0120, STR0278 , {  STR0146  }, 2 ) //"Guia On-Line, n„o e possÌvel fazer este tipo de cancelamento!"
				endIf

			endIf

			if lOk

				BAU->( dbSetOrder(1) )//BAU_FILIAL+BAU_CODIGO

				//ValidaÁ„o de local de digitaÁ„o e fase da guia para cancelamento.
				//Regras: Caso guia esteja faturada (fase 4) ou codldp = 9999 ou 0003, nao permite o cancelamento
				if cFaseGuia == '4'

					if lRPC
						cMsg := "Guias faturadas n„o podem ser canceladas."
					else
						aviso( STR0120, "Guias faturadas n„o podem ser canceladas." , {  STR0146  }, 2 )
					endIf

					lOk := .f.

					//Guia de intercambio permite o cancelamento
				elseIf ! empty(BE4->BE4_NRTROL) .and. BE4->BE4_OPESOL == plsIntPad()

					lOk := .t.

					//Modelo antigo de Pegs, permite o cancelamento
				elseIf BAU->( msSeek(xFilial("BAU") + BE4->BE4_CODRDA) ) .and. BAU->BAU_OBRPTO != "1"

					lOk := .t.	

				elseIf ! ( BE4->BE4_CODLDP $ ( PLSRETLDP(9) + '|' + PLSRETLDP(3) ) )

					if lRPC
						cMsg := "Esta guia n„o pode ser cancelada, consulte a operadora."
					else
						aviso( STR0120, "Esta guia n„o pode ser cancelada, consulte a operadora." , {  STR0146  }, 2 )
					endIf

					lOk := .f.

				endIf

			endIf

		endIf

	endIf

endIf

if lOk

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

	if ! empty(cSeqPF)

		if PLSVERCCBG(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),BEA->BEA_ANOPAG,BEA->BEA_MESPAG,cSeqPF)

			lOk := .f.

			if lRPC
				cMsg := STR0235
			else
				Aviso(STR0021,STR0235,{STR0146},2) //"Guia Cobrada"###"Ja gerada a cobranca de custo operacional/co-participacao portanto nao podera ser cancelada"###"Ok"
			endIf

		endIf

	endIf

	if lOk .and. cFaseGuia == "4"

		lOk := .f.

		if lRPC
			cMsg := STR0236
		else
			Aviso(STR0023,STR0236,{STR0146},2)    //"Guia Paga"###"Guia ja paga portanto nao podera ser cancelada"###"Ok"
		endIf

	endIf

	if lOk

		//Verificando a Data do Sistema em relacao a data de emissao do titulo no financeiro
		if lBEANTit
			cChvSE1 := BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)
		else
			cChvSE1 := BEA->BEA_CHVSE1
		endIf

		if BEA->BEA_STATUS == "5" .or. ! empty(cChvSE1)  

			SE1->(DbSetOrder(1))

			if SE1->(MsSeek(xFilial("SE1") + cChvSE1)) .And. dDataBase < SE1->E1_EMISSAO

				lOk := .f.

				if lRPC
					cMsg := "N·o È possÌvel cancelar guias antes da emiss„o do tÌtulo no financeiro"
				else
					Aviso("ImpossÌvel cancelar o tÌtulo","N·o È possÌvel cancelar guias antes da emiss„o do tÌtulo no financeiro",{STR0146},2)//"Ok"
				endIf

			endIf

		endIf

		if lOk .and. BEA->( FieldPos("BEA_CANCEL") ) == 0

			lOk := .f.

			if lRPC
				cMsg := STR0337
			else
				msgAlert(STR0337) //Campo de CANCELAMENTO n„o EXISTE!
			endIf

		endIf

		if lOk .and. BEA->BEA_CANCEL == '1' .AND. !lCanNow

			lOk := .f.
			if lRPC
				cMsg := STR0338
			else
				msgAlert(STR0338)//'A Guia ja esta CANCELADA!'
			endIf
			nStatusTiss := 1 //Cancelado com sucesso
		endIf

		if lOk .and. lRPC .and. ! empty(BE4->BE4_TIPGUI) .and. BE4->BE4_TIPGUI == "03" .and. lIntern
			BDR->(DbSetOrder(1))
			if BE4->( FieldPos("BE4_DATPRO") ) > 0 .And. ! Empty(BE4->BE4_DATPRO) ;
				.And. BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+BE4->BE4_TIPADM)) .And. BDR->BDR_CARINT <> "U"

				if lRPC
					lOk  := .f.
					cMsg := STR0553 //"Guia com Data de InternaÁ„o j· informada. Paciente internado, n„o È possÌvel cancelar esta guia."
				else
					lOk  := .F.
					msgAlert(STR0553) //"Guia com Data de InternaÁ„o j· informada. Paciente internado, n„o È possÌvel cancelar esta guia."				
				endIf

			endIf

		endIf

		If lOk .AND. ! lRPC .And. BEA->BEA_COMUNI <> "1"

			aMotCanc := P090MTVCAN()

			if empty(aMotCanc[1]) .and. empty(aMotCanc[2])

				msgInfo(STR0569) //"Informe um motivo v·lido!"
				lOk := .f.

			endIf

		endIf

		if lOk .and. !lCanAudit 

			//Cancela as guias de Anexos Clinicos vinculadas.
			B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF
			if B4A->( msSeek( xFilial("B4A")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

				//Caso seja chamada do cancelamento de guias de internaÁ„o do remote,
				//n„o exibe a mensagem de confirmaÁ„o para o cancelamento pois j· foi confirmado anteriormente*/
				if cRecno > 0 .or. isInCallstack("PLSA92MTCAN")
					aRetAnx := PLSA0A2CAN(.T., .F., aMotCanc)
				else
					aRetAnx := PLSA0A2CAN(.T., !lRPC, aMotCanc) //Se lRpc true n„o exibe mensagem. Por sua vez, se LRpc = true o parametro lAlerta deve ser false
				endIf

				lOk		:= aRetAnx[1]
				lAnex 	:= aRetAnx[2]
				lCanNow	:= iIf(lOk, .T., .F.)

				if len(aRetAnx) > 2

					for nX := 1 to len(aRetAnx[3])

						if aRetAnx[3][nX][1] == "B4A"

							B4A->(DbGoto(aRetAnx[3][nX][2]))	

							cGuiasAne += iIf(!Empty(cGuiasAne),", ","") + B4A->(B4A_OPEMOV+"-"+B4A_ANOAUT+"."+B4A_MESAUT+"-"+B4A_NUMAUT)

						endIf

					next

				endIf

			endIf

		endIf 

		if lOk

			If lBEANTit
				cSE1 := BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)
			else
				cSE1 := BEA->BEA_CHVSE1
			endIf

			DbSelectArea("SE1")

			SE1->(DbSetOrder(1))
			SE1->(MsSeek(xFilial("SE1")+cSE1))

			If SE1->E1_BAIXA <> cTod("")

				lOk := .f.

				if lRPC
					cMsg := STR0542
				else
					msgAlert(STR0542)
				endIf

			endIf

			//Verifica se tem complemento de SADT pendente
			if lOk .and. BEA->BEA_COMUNI == "1" .and. GetNewPar("MV_PLEVSAD","0") == "1" 

				BQV->( dbSetOrder(1) )//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
				if BQV->( dbSeek(xFilial("BQV") + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) ) .And. VerProBqv(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))

					lOk := .f.

					if lRPC
						cMsg := STR0484
					else
						msgAlert(STR0484)//"N„o È possÌvel cancelar a Guia, pois existem complementos pendentes"
					endIf	

				endIf

			endIf

			//Verifica se a guia esta em an·lise pela auditoria≥
			if lOk .and. PLSALIASEX("B53") .and. !lOriAud  .And. !lApagaGuia

				if !PLSA092VL2("BEA")

					lOk := .f.
					if lRPC
						cMsg := STR0604 //'Guia em an·lise pela Auditoria'
					else
						msgAlert(STR0604) //'Guia em an·lise pela Auditoria'
					endIf

				endIf

			endIf

			//Ponto de entrada da chegar o cancelamento da guia≥
			if lOk .and. ExistBlock("PL090CKCAN")

				if ! execBlock("PL090CKCAN",.f.,.f.,{ BEA->BEA_CODPEG,BEA->BEA_NUMGUI,BEA->BEA_MATRIC,BEA->BEA_NUMAUT,lRPC } )

					lOk := .f.

					if lRPC
						cMsg := STR0605 //'Guia n„o pode ser cancelada'
					else
						msgAlert(STR0605) //'Guia n„o pode ser cancelada'
					endIf	

				endIf

			endIf

			//Se e uma liberacao fechada nao pode ser excluida  
			if lOk .and. BEA->BEA_LIBERA == '1' .and. BEA->BEA_STALIB == "2"

				lOk := .f.

				if lRPC
					cMsg := STR0564//"Esta liberaÁ„o encontra-se Fechada, portanto n„o poder· ser cancelada."
				else
					aviso( 	STR0120,STR0564,{ STR0146 }, 2 ) //"Atencao"//"Esta liberaÁ„o encontra-se Fechada, portanto n„o poder· ser cancelada."//"Ok"
				endIf

			endIf

			//Confirmado o cancelamento, verifica se e guia Online e gera o arquivo "00111"≥
			if lOk .and. BEA->BEA_COMUNI == "1" .and. ! empty(BEA->BEA_NRTROL)

				If ! lRpc .and. ! empty(BEA->BEA_GUIORI) 

					aAreaBEA	:= BEA->(GetArea())
					cNrlBor		:= BEA->BEA_NRLBOR

					cSql := " SELECT BEA_NRLBOR "
					cSQL += " FROM " + retSQLName("BEA")
					cSQL += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' "
					cSQL += " AND BEA_NRLBOR = '" + cNrlBor + "' "
					cSQL += " AND (BEA_STATUS = '1' OR BEA_STATUS = '2') "
					cSQL += " AND D_E_L_E_T_ = ' ' "

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBEA",.T.,.F.)

					While !TRBEA->(EOF())
						nCont++
						TRBEA->(DbSkip())
					EndDo

					TRBEA->(dbCloseArea())
					
					If nCont == 1 .And. MsgYesNo(STR0638+substr(BEA->BEA_NRLBOR,1,4)+"-"+substr(BEA->BEA_NRLBOR,5,4)+"."+substr(BEA->BEA_NRLBOR,9,2)+"-"+substr(BEA->BEA_NRLBOR,11,8)+STR0639 )//"Esta guia È uma execuÁ„o da LiberaÁ„o "###" que foi autorizada atravÈs do interc‚mbio Online. Deseja enviar para a Operadora Origem do Benefici·rio uma comunicaÁ„o do Cancelamento?"
						lConfPTU := .T.
					EndIf	

					RestArea(aAreaBEA)


				ElseIf !lRpc .and. empty(BEA->BEA_GUIORI) .And. BEA->BEA_ORIGEM == "2" .And. BEA->BEA_STALIB == "1"
					cSQL := "SELECT BEA_FILIAL FROM "+BEA->(RetSQLName("BEA"))+" WHERE "
					cSQL += "BEA_FILIAL = '"+xFilial("BEA")+"' AND "
					cSQL += "BEA_NRLBOR = '"+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)+"' AND "
					cSQL += "BEA_STATUS = '1' AND "
					cSQL += "D_E_L_E_T_ = ' '"
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBEA",.F.,.T.)

					If !TrbBEA->(EOF())
						Aviso( STR0120, ; //"Atencao"
						"Para esta liberaÁ„o foi gerada autorizaÁıes, portanto n„o poder· ser cancelada.",;
						{ STR0146 }, 2 )//"Ok"
						TrbBEA->(DbCloseArea())
						Return
					Else
						lConfPTU := .t.
					EndIf
					TrbBEA->(DbCloseArea())
						
				Else
					lConfPTU := .t.
				EndIf

				if lRPC .or. lAnex .or. isInCallstack("PLSA92MTCAN") .or. msgYesNo(STR0339)//"Confirma o CANCELAMENTO da GUIA?"

					If lConfPTU

						if ! lRPC
							aRetDesCan := PLSCANCCOM()
						else
							aadd(aRetDesCan,cMotivo)
						endIf	

						if empty(aRetDesCan[1])

							lOk := .f.

							if lRPC
								cMsg := STR0601  //"Para a versao 5.0 ou superior do PTU Online, e obrigatorio o preenchimento do motivo de cancelamento."
							else
								msgInfo(STR0603)  //"Para a versao 5.0 ou superior do PTU Online, e obrigatorio o preenchimento do motivo de cancelamento."
							endIf

						endif


						if lOk .and. ! PLSASOEEXE("BEA",nil,nil,.t.,,lRPC,aRetDesCan[1])

							lOk := .f.

							if lRPC
								cMsg := STR0532
							else
								msgInfo(STR0532) //"N„o foi possÌvel realizar o cancelamento da guia, entre em contato com a Operadora"
							endIf

						endIf

					endIf	

				else
					lOk := .f.	
				endIf

			else

				if lOk .and. ! isInCallstack("PLSA92MTCAN") .and. !lRPC .And. !lAnex .And. !MsgYesNo(STR0339) //"Confirma o CANCELAMENTO da GUIA?"  
					lOk := .f.
				endIf

			endif

			if lOk

				if ! empty(cGuiasAne) .and. ! lRPC

					aviso( STR0120,STR0626 + cGuiasAne,{ STR0146 }, 2 ) //"Atencao" //"Foram canceladas as guias de Anexos ClÌnico vinculadas a guia cancelada: " //"Ok"

				else

					//Verifica se ha anexos pendentes
					B4A->(dbSetOrder(4))//B4A_FILIAL+B4A_GUIREF
					if B4A->( msSeek( xFilial("B4A") + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

						while B4A->B4A_GUIREF == BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) .and. ! B4A->(eof())
							cGuiasAne += iIf( ! empty(cGuiasAne),", ","") + B4A->(B4A_OPEMOV+"-"+B4A_ANOAUT+"."+B4A_MESAUT+"-"+B4A_NUMAUT)
							B4A->( dbSkip() )
						endDo   

						if ! empty(cGuiasAne)
							aviso( STR0120,STR0627+cGuiasAne,{ STR0146 }, 2 ) //"Atencao" //"H· guias de Anexos ClÌnico pendentes vinculadas a guia cancelada: " //"Ok"
						endIf

					endIf

				endIf

				PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,"2",nil,nil,.t.)

				if ! empty(BEA->BEA_NRLBOR)
					PLSA090RSD( BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT), BEA->BEA_NRLBOR, BEA->BEA_TIPGUI == '06',BEA->BEA_TIPGUI=='05')
				endIf

				BEA->( RecLock("BEA", .f.) )
				BEA->BEA_STATUS := '3'
				BEA->BEA_CANCEL := '1'
				BEA->BEA_STTISS := PLSANLSTIG(,,.T. ) //Como est· cancelada, no portal deve exibir o status TISS como cancelada

				If len(aRetDesCan) > 0
					BEA->BEA_CANEDI := aRetDesCan[1]
				ElseIf Len(aMotCanc) > 0
					BEA->BEA_CANTIS := aMotCanc[1] //Motivo TISS
					BEA->BEA_CANEDI := aMotCanc[2] //Texto motivo 
				EndIf
				BEA->( MsUnLock() )
				//Vamos informar que a guia foi cancelada guando vier de uma requisiÁ„o da TISS online
				nStatusTiss := 1 //Guia cancelada com sucesso

				//LiberaÁ„o odontolÛgica
				BE2->( DbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
				BE2->( MsSeek( xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
				While !BE2->(Eof()) .And. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)

					BE2->( RecLock("BE2", .F.) )
					BE2->BE2_LIBESP := '0'
					BE2->BE2_AUDITO := '0'
					BE2->BE2_STATUS := '0'

					BE2->( MsUnLock() )

					BE2->( DbSkip() )
				EndDo

				If BEA->BEA_TIPGUI == "03"

					BE4->( DbSetOrder(2) )
					BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
					While !BE4->(Eof()) .And. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

						BE4->( RecLock("BE4", .F.) )
						BE4->BE4_STATUS := "3"
						BE4->BE4_CANCEL := "1"
						BE4->BE4_STTISS := PLSANLSTIG(,,.T. ) //Como est· cancelada, no portal deve exibir o status TISS como cancelada 

						If len(aRetDesCan) > 0 
							BE4->BE4_CANEDI := aRetDesCan[1]
						ElseIf Len(aMotCanc) > 0
							BE4->BE4_CANTIS := aMotCanc[1] //Motivo TISS
							BE4->BE4_CANEDI := aMotCanc[2] //Texto motivo
						EndIf

						BE4->( MsUnLock() )

						BEJ->( DbSetOrder(1) ) //BEJ_FILIAL + BEJ_OPEMOV + BEJ_ANOAUT + BEJ_MESAUT + BEJ_NUMAUT + BEJ_SEQUEN
						BEJ->( MsSeek( xFilial("BEJ")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
						While !BEJ->(Eof()) .And. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)
							
							BEJ->( RecLock("BEJ", .F.) )
							BEJ->BEJ_AUDITO := '0'
							BEJ->BEJ_STATUS := '0'

							BEJ->( MsUnLock() )

							BEJ->( DbSkip() )
						EndDo

						BE4->( DbSkip() )
					EndDo

					//Cancela as prorrogaÁıes vinculadas a internaÁ„o. 
					If FindFunction("PLCANPROG")
						PLCANPROG(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))
					Else
						If lRPC						
							cMsg := "N„o foi possÌvel cancelar as prorrogaÁıes vinculadas a internaÁ„o"
						else 
							msgInfo("N„o foi possÌvel cancelar as prorrogaÁıes vinculadas a internaÁ„o")
						EndIf
					EndIf 

				EndIf

				If lBEANTit
					cChavSE1 := BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)
				Else
					cChavSE1 := BEA->BEA_CHVSE1
				EndIf

				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))
				BBT->(DbSetOrder(7))

				If SE1->(MsSeek(xFilial("SE1")+cChavSE1)) .And. BBT->(MsSeek(xFilial("BBT")+cChavSE1))

					BDC->(DbSetOrder(1))
					If BDC->(DbSeek(xFilial("BDC")+BBT->(BBT_NUMCOB)))
						PL627MOV("BDC",BDC->(Recno()),K_Excluir,.T.)
					Endif

					BEA->(RecLock("BEA",.F.))
					If lBEANTit
						BEA->BEA_PREFIX:=''
						BEA->BEA_NUMTIT:=''
						BEA->BEA_PARCEL:=''
						BEA->BEA_TIPTIT:=''
					Else
						BEA->BEA_CHVSE1:=''
					EndIf
					BEA->(MsUnlock())

				Endif

				//Altera o status da guia na auditoria para cancelada.							  
				B53->(dbSetOrder(1)) //B53_FILIAL, B53_NUMGUI, B53_ORIMOV
				If B53->(dbSeek(BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
					B53->(Reclock("B53",.F.))
					B53->B53_STATUS := '6'
					B53->(MsUnlock())
				EndIf

				//Quando lRPC for .T. nao deve ser exibido mensagem em tela,deve ser retornado uma string≥
				//Se tudo tiver ok deve ser retornado uma string ""									  
				if ! lRPC
					if ExistBlock("PLS090CAN")
						ExecBlock("PLS090CAN",.F.,.F.)
					endif
				endIf

				If ! lRPC 
					MsgInfo(STR0625) //"Guia cancelada com sucesso"
				EndIf	

				endIf

				If BEA->BEA_ORIMOV == "6" .And. FWAliasInDic("BNV", .F.) .And. GetNewPar("MV_PLSHAT","0") == "1" 

					BNV->(DbSetOrder(2))//BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE
											
					If !BNV->(MsSeek(xFilial("BNV")+cCodTra+"BEA"+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))) 		
						cChaveHAT := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
						PLHATPedPD(K_Incluir,cCodTra,"BEA",cChaveHAT,NIL,1)	
					EndIf	
				EndIf

				If lConfPTU //Se foi cancelado a guia de autorizaÁ„o e pediu para fazer a comunicaÁ„o com a solicitaÁ„o, faz a gravaÁ„o
					PLSATTLIBER(BEA->BEA_NRLBOR,aRetDesCan, aMotCanc, lBEANTit) //Cancelar a guia de liberaÁ„o caso a vari·vel lConfPTU vier true.
				EndIf

			endIf

		endIf

	endIf	
	//Vamos informar que a guia n„o foi cancelada guando vier de uma requisiÁ„o da TISS online
	Iif(nStatusTiss != 1, nStatusTiss := 2 , "")
Return Iif(lRPC,cMsg,)

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUResCom
Abre um resumo da comunicacao do intercambio on-line 

@author  PLS TEAM
@version P11
@since   29.07.05
/*/
//-------------------------------------------------------------------
Function PTUResCom(oBrwPro,oBrwCri,cAutori,cSenhaOpe,cTranOri,cAliasCab,aRet,lReqOrdSer,nRecBA1,lGloboOff)
	LOCAL cNomOpe
	LOCAL nI
	LOCAL aDados   := {}
	LOCAL cOpeOri  	:= ""
LOCAL nOrdBA0  := BA0->(IndexOrd())
LOCAL nRecBA0  := BA0->(Recno())
LOCAL cOldPro  := ""
//Variaveis WebService RN
LOCAL aRetWeb   := {}
LOCAL cMsgCri   := ""
LOCAL nX        := 0
LOCAL lRetCom   := .F.
LOCAL cCodTraPro:= ""
LOCAL nPosNrTrol:= 0
LOCAL nPosProAte:= 0

DEFAULT aRet   := {}
DEFAULT lReqOrdSer := .F.
DEFAULT nRecBA1    := 0
DEFAULT lGloboOff  := .F.

If nRecBA1 > 0
	BA1->(DbGoTo(nRecBA1)) 
EndIf

cOpeOri  := BA1->BA1_OPEORI

BA0->(DbSetOrder(1))
BA0->(MsSeek(xFilial("BA0")+cOpeOri))
cNomOpe := BA0->BA0_NOMINT
BA0->(DbSetOrder(nOrdBA0))
BA0->(DbGoTo(nRecBA0))

AaDd(aDados,{STR0237,cOpeOri+" - "+cNomOpe}) 											//"Operadora Origem"
If !lReqOrdSer
	AaDd(aDados,{STR0238,BA1->BA1_MATANT}) 					   						//"Matricula do Usuario"
Else
	AaDd(aDados,{STR0238,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)})//"Matricula do Usuario"
EndIf
AaDd(aDados,{STR0239,BA1->BA1_NOMUSR}) 	   											//"Nome do Usuario"
AaDd(aDados,{STR0240,BAU->BAU_CODIGO+"-"+BAU->BAU_NOME}) 							//"RDA"
AaDd(aDados,{STR0241,cTranOri}) 	   													//"Num. Transacao de Comunicacao"
AaDd(aDados,{STR0051,Iif(cAutori=="1",STR0056,Iif(cAutori=="3",STR0057,STR0258) ) } ) //"Autorizado"##Sim#"Nao"#"Parcial"
If len(aRet[1]) > 6 .And. Alltrim(aRet[1][7]) $ "aAbB"
	AaDd(aDados,{STR0441,Iif(Alltrim(aRet[1][7]) $ "aA",STR0503,STR0504)}) 	        //""AcomodaÁ„o""#"COLETIVA"#"INDIVIDUAL"
EndIf

//Mostra Criticas															

If ValType(aRet[1,3])=='A' .And. Len(aRet[1,3]) > 0
	For nI := 1 To Len(aRet[1,3])
		If !Empty(aRet[1,3,nI,3]) .And. cOldPro <> aRet[1,3,nI,3]
			Aadd( aDados,{ STR0030,aRet[1,3,nI,3] } ) //"Procedimento"
			cOldPro := aRet[1,3,nI,3]
		EndIf
		Aadd( aDados,{ STR0242,aRet[1,3,nI,2] } ) //"Critica"
	Next
EndIf

If cAutori=="1"
	Aadd(aDados,{STR0047,cSenhaOpe}) //"Senha"
Endif

// Chama WebService de Protocolos RN 395

If GetNewPar("MV_PL395WS","0") == "1" .And. PLSALIASEX("B4J") 
	aDadUsr := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.F.,dDataBase)       
	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(DbSeek(xFilial("BA0")+aDadUsr[45]))      

	B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI
	B00->(DbSeek(xFilial("B00")+cNumProto)) 

	If Empty(cNumProto)
		If MsgYesNo("Deseja solicitar o protocolo de atendimento para a Operadora Origem do Benefici·rio?")

			P773AutInc(cAliasCab,@cNumProto,nil,.T.,.F.,nil,.F.,.F.,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),.F.)
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Atualiza o numero do protocolo no cabecalho/itens		                              ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If lGloboOff    
				If Substr(oBrwPro:aHeader[1][2],1,3) == "BQV" .And. (nPosNrTrol := Ascan(oBrwPro:aHeader,{|x|x[2] == "BQV_NRTROL"}) ) > 0 .And. ;
				(nPosProAte:= Ascan(oBrwPro:aHeader,{|x|x[2] == "BQV_PROATE"}) ) > 0  .And. (nPosSequen:= Ascan(oBrwPro:aHeader,{|x|x[2] == "BQV_SEQUEN"}) ) > 0
					BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
					For nX := 1 to len(oBrwPro:aCols)   
						If Alltrim(oBrwPro:aCols[nX][nPosNrTrol]) == cTranOri .And. BQV->(DbSeek(xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)+oBrwPro:aCols[nX][nPosSequen]))  
							BQV->(Reclock("BQV",.F.))
							BQV->BQV_PROATE := cNumProto
							BQV->(MsUnlock())
						EndIf
					Next
				Else
					If cAliasCab == "BE4"
						BE4->(Reclock("BE4",.F.))
						BE4->BE4_PROATE := cNumProto
						BE4->(MsUnlock())
					EndIf
					BEA->(Reclock("BEA",.F.))
					BEA->BEA_PROATE := cNumProto
					BEA->(MsUnlock())  
				EndIf	
			EndIf	
		Endif	
	Else
		cCodTraPro := PLB4JRegTr(PlsIntPad(),aDadUsr[45],"003")	

		B00->(Reclock("B00",.F.))
		B00->B00_NRTROL := cTranOri
		B00->(MsUnlock())

		If !Empty(cTranOri)		
			While !lRetCom  
				MsAguarde( {|| aRetWeb := PLComProRN(PlsIntPad(),aDadUsr[45],"",cCodTraPro,dDatabase,;
				cUserName,Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13) ,cNumProto,cTranOri,,B00->B00_MSGINT) })
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Exibe resposta		                                                     ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If aRetWeb[1]
					AaDd(aDados,{"Comunic. Complementar Protocolo","Concluida com sucesso"}) 	
					lRetCom := .T. 
				Else
					cMsgCri := "N„o foi possÌvel complementar o protocolo. CrÌticas:"+Chr(10)+Chr(10)
					For nX := 1 to len(aRetWeb[2])
						cMsgCri += Alltrim(aRetWeb[2][nX][1])+"-"+Alltrim(aRetWeb[2][nX][2])+Chr(10)
					Next   
					cMsgCri += Chr(10)+"Deseja complementar o protocolo novamente?"
					If !MsgYesNo(cMsgCri) 
						lRetCom := .T.
					EndIf
				EndIf
			EndDo
			If !lRetCom
				AaDd(aDados,{"Comunic. Complementar Protocolo","N„o realizada."}) 	
			EndIf
		EndIf		
	EndIf	
EndIf


PLSCRIGEN(aDados,{ {STR0243,"@C",90} , {STR0244,"@C",80 } },STR0245) //"Campo"###"Conteudo"###"Resumo da Comunicacao"
Return

/*/{Protheus.doc} PLSRetAut
@author  PLS TEAM
@version P11
@since   10.08.05
/*/
Function PLSRetAut(cTipo)
	LOCAL aRet := {}
	Default cTipo = '1'

If  UPPER( Alltrim( FunName() ) ) $ "PLSA094C,PLSA094D,PLS090O" .Or. cTipo = '2' .Or. (Type('M->B01_USUARI') <> 'U' .And. ReadVar() $ "M->BE2_CODPRO,M->BE2_QTDPRO,M->BE2_DENREG,M->BE2_FADENT")
	aRet := {"13","B01","BE2","BEG"} //Odontologico
ElseIf  UPPER( Alltrim( FunName() ) ) $ "PLSA001" .Or. cTipo == '4' .Or. ReadVar() $ "M->B44_REGSOL/M->B45_QTDPRO/M->B44_REGEXE/M->B45_CODPRO"
	aRet := {"04","B44","B45","B46"} //Reembolso 
ElseIf  UPPER( Alltrim( FunName() ) ) == "PLSA09A" .or. cTipo == "7" .Or. ((IsInCallStack("PLS09AMO2") .Or. IsInCallStack("PLS09AMO3")) .And. UPPER( Alltrim( FunName() ) ) == "PLSA094B" .And. cTipo == "1")
	aRet := {"07","B4A","B4C","BEG"} //Anexos Clinicos
ElseIf  UPPER( Alltrim( FunName() ) ) == "PLSA09P"
	aRet := {"11","B4Q","BQV","BEG"} //ProrrogaÁ„o de internaÁ„o
elseIf UPPER(AllTrim( FunName())) == "PLSA001A" .AND. isInCallstack("PL001MOV")
	aret := {"04","B44","B45","B46"} //Protocolo gerando reembolso Reembolso
ElseIf  UPPER( Alltrim( FunName() ) ) == "PLSA001A" .AND. PLSALIASEXI("BOW") .AND. ReadVar() <> "M->B1N_REGSOL"
	aRet := {"04","BOW","",""} // Protocolo de Reembolso
ElseIf  ReadVar() == "M->B4F_REGSOL"
	aRet := {"","B4F","",""} // Cadastro de receitas
ElseIf  ReadVar() == "M->B1N_REGSOL" 
	aRet := {"","B1N","",""} // Itens do protocolo de reembolso
ElseIf  ReadVar() == "M->B45_REGSOL" 
	aRet := {"","B45","",""} // itens da autorizaÁ„o de reembolso
ElseIf  UPPER( Alltrim( FunName() ) ) == "PLSA092" .AND. ReadVar() == "M->BQV_CODPRO"
	aRet := {"11","B4Q","BQV","BEG"} //Guia de solicitaÁ„o de internaÁ„o
ElseIf  UPPER( Alltrim( FunName() ) ) == "PLSA092"
	aRet := {"03","","",""} //Guia de solicitaÁ„o de internaÁ„o	
ElseIf	cTipo == "3" //Guia de internaÁ„o
	aRet := {"03","BE4","",""}
Else
	aRet := {"02","BE1","BE2","BEG"} //SADT
	Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSFILCDPA

@author  PLS TEAM
@version P11
@since   10.08.05
/*/
//-------------------------------------------------------------------
Function PLSFILCDPA()
	LOCAL aProg := PLSRetAut()
	LOCAL cRet	:= ""

If     aProg[1] == "01"
	cRet :=  (GetNewPar("MV_PLTABOD","03"))
Elseif aProg[1] == "02"
	cRet := (GetNewPar("MV_PLSTBPD","01"))
	Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS090RONL
Coloca os campos da guia com ReadOnly

@author  PLS TEAM
@version P11
@since   29.10.05
/*/
//-------------------------------------------------------------------
Function PLS090RONL(lOp,oObj)
	LOCAL nI
	LOCAL cCpoNot := "BE1_MSG01,BE1_MSG02,BE1_MSG03,BE1_NRAOPE,BE1_NRAEMP,BE1_ESTSOL,BE1_SIGLA,BE1_TIPSAI,BE1_TIPATE,BE1_INDCLI,BE1_INDCL2"
LOCAL cCampo

cCpoNot +=",BE1_CODCLI,BE1_LOJA,BE1_LOTGUI,BE1_TIPMAJ,B44_LOTGUI,B44_REGSOL,BE1_TIPCON"

For nI := 1 To Len(oObj:AENTRYCTRLS)
	cCampo := AllTrim(oObj:aEntryctrls[nI]:CREADVAR)
	cCampo := StrTran(cCampo,"M->","")
		If ! ( cCampo $ cCpoNot )
			oObj:AENTRYCTRLS[nI]:LREADONLY := lOp
		Endif
	Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSHORINI
Coloca os campos da guia com ReadOnly

@author  PLS TEAM
@version P11
@since   02.12.05
/*/
//-------------------------------------------------------------------
Function PlsHorIni(lZera)
	Local nDif
	Static nHorIni := NIL
	DEFAULT lZera := .F.
	If nHorIni == NIL .or. lZera
		nHorIni := Seconds()
	EndIf
	nDif := Seconds() - nHorIni
	nHorIni := Seconds()
Return nDif

//-------------------------------------------------------------------
/*/{Protheus.doc} VerSis
Funcao intermediaria a PLSGETVERSAO para que nao de mensagem
de funcao nao existe caso a PLSGETVERSAO nao esteja compilad

@author  PLS TEAM
@version P11
@since   08.12.05
/*/
//-------------------------------------------------------------------
Static Function VerSis()
	Local nVersao := 7
	If FindFunction("PLSGETVERSAO")
		nVersao := PlsGetVersao()
	EndIf
Return nVersao

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaSX1
Verifica Grupo do Pergunte no SX1 e cria se necessario 

@author  PLS TEAM
@version P11
@since   09/01/06
/*/
//-------------------------------------------------------------------
Static Function fCriaSX1(cPerg)

	Local aRegs	:=	{}

	aadd(aRegs,{cPerg,"01",STR0246,"","","mv_ch1","N", 1,0,2,"C","","mv_par01","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","",""}) //"Imprimir direto na impressora?"

	PlsVldPerg(aRegs)

Return

/*/{Protheus.doc} PLSDWRET

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
Function PLSDWRET(cTpGrv)
Return(X3COMBO("BE2_TPGRV",cTpGrv))

/*/{Protheus.doc} PLA090LIB
Busca dados de uma liberacao para uma autorizacao  

@author  PLS TEAM
@version P11
@since   13.06.00
/*/
function PLA090LIB(cChavLib,dDatPro)
	local lRet 		 := .t.
	local cCampoBE1	 := ""
local cCampoBEA	 := ""
local __nAux	 := 0
local __nInd	 := 0
local nI		 := 0
local nQtdPro	 := 0
local cField	 := ""
local xField	 := 0
local nPosPro	 := ascan(oBrwPro:aHeader,{|x| x[2] == "BE2_QTDPRO"})
local aDadRda    := PLSGETRDA()
local lRdaGen    := .f.
local cChave     := " "
LOCAL lPLIBESAL  := existBlock("PLIBESAL")
local cCamposRDA := "BEA_CODRDA,BEA_CODLOC,BEA_CODESP,BEA_NOMRDA,BEA_TIPPRE,BEA_LOCAL,BEA_DESLOC,BEA_ENDLOC,BEA_DESESP"
local cTransNum  := "@R !!!!.!!!!.!!-!!!!!!!!"
local cTransMat  := "@R !!!!.!!!!.!!!!!!-!!-!"
local lInterProt := .f.
local lRn395     := getNewPar("MV_PLRN395","0") == "1"
local lPTUOn70   := allTrim(getNewPar("MV_PTUVEON","35")) >= "70" 


local lRetorno   := .f.
local lLib       := .f.  
local lFechada   := .f.  
local lTemSeriad := .F.
local lCri09S    := .F.
local lPERet09S  := .F.
local aAreaBE2   := {}
local aSeriado   := {}

default dDatPro  := dDataBase

//Limpa criticas
PLLimpCCri(.t.)

if ! PLSA090DPR()
	return .f.
endIf



dbSelectArea("BEA")

//Verifica integridade do numero da liberacao...                          
BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO

lLib := BEA->( msSeek( xFilial("BEA") + cChavLib ) ) .and. BEA->BEA_ORIGEM == "2" 

If getNewPar("MV_PLIBAUD",.F.)

	lRetorno := (BEA->BEA_STALIB $ '1,6' .And. BEA->BEA_STATUS $ '1,2,5,6' .And. PLIBAUD(@cChavLib)) 
else
	lRetorno :=  (BEA->BEA_STALIB == '1'  .And.  BEA->BEA_STATUS $ '1,2')

EndIf



if lLib .and. lRetorno

	lRdaGen 		:= ( BEA->BEA_CODRDA == GetNewPar("MV_PLSRDAG","999999") )
	__cCodRdaP 	:= BEA->BEA_CODRDA	

	BE2->(DbSetOrder(1))
	BE2->(MsSeek(xFilial("BE2")+cChavLib))
	//Ponto de entrada para validar a liberacao informada                     
	If existblock("PL90VLDLIB")

		aRetValid := execBlock("PL90VLDLIB",.F.,.F.,{cChavLib,.F.})

		if valType(aRetValid) == "A"
			lRet := aRetValid[1] 			//Se sistema continuar· com a validaÁ„o .T./.F.
		else
			lRet := aRetValid				//Se sistema continuar· com a validaÁ„o .T./.F.
		endIf

		if !lRet
			return(lRet)
		endIf

	endIf

	//Como ja estou executando uma liberacao apenas utilizo o aBlockLib para que ele nao carregue qtdpro = 1 ao clicar 2 vezes no grid de procedimento	
	//este array esta no inicializador padrao do BE2_QTDPRO e ao executar uma lib estava retornando 1 de qtdade
	if len(aBlockLib) == 0
		aBlockLib:= {.T.} 
	endIf

	//Critica 09S verifico se os eventos sao de tratamento seriado, caso sim, nao posso apresentar a critica:

	//"6.4.21. No tratamento seriado, a continuidade do atendimento poder· ser 
	//prestada apÛs a validade de 60 (sessenta) dias e enquanto o benefici·rio 
	//estiver de posse do cart„o de identificaÁ„o v·lido, considerando como 
	//limite o n˙mero de sessıes liberadas pela Unimed Origem, que efetuar· o 
	//pagamento total das sessıes realizadas." 
	if BEA->BEA_VALSEN < dDataBase .And. PLSPOSGLO(BEA->BEA_OPEMOV,__aCdCri09S[1],__aCdCri09S[2],,,)

		lCri09S := .T.
		aAreaBE2 := BE2->(GetArea())
		BJE->(DbSetOrder(1)) //BJE_FILIAL+BJE_CODIGO
		BE2->(DbSetORder(1)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
		BR8->(DbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN

		lPERet09S := ExistBlock("PL09009S")

		if BE2->(MsSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
			while BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) .and. !BE2->(Eof())
				if lPERet09S
					aPERet09S := ExecBlock("PL09009S",.F.,.F.,{BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),BE2->BE2_SEQUEN,.F.})
					if !aPERet09S[1] //Se um dos itens nao apresentar a critica, ignora a critica para a guia
						lCri09S := .F.
					endIf	
					if aPERet09S[2]
						lTemSeriad := .T.
						aadd(aSeriado,BE2->BE2_SEQUEN)
					endIf

				elseIf BE2->BE2_SALDO > 0 .And. BR8->(MsSeek(xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO))) .And. !Empty(BR8->BR8_CLASSE)	
					if BJE->(MsSeek(xFilial("BJE")+BR8->BR8_CLASSE)) .And. BJE->BJE_TIPO == "2"
						lTemSeriad := .T.
						lCri09S    := .F. //Se tiver item seriado, nao apresento a critica 09S
						aadd(aSeriado,BE2->BE2_SEQUEN)
					endIf
				endIf
				BE2->(DbSkip())
			endDo
		endIf
		
		if lCri09S
			aHisCri := {{__aCdCri09S[1],__aCdCri09S[2],""},;
			{"",STR0497,Transform(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),cTransNum)},; //Guia liberacao
			{"",STR0238,Transform(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),cTransMat)},;//Matricula do usuario
			{"",STR0239,BEA->BEA_NOMUSR},;//Nome do usuario
			{"",STR0531,DtoC(BEA->BEA_VALSEN)}}

			if ! PLSMOVCRI("1",{__aCdCri09S[1],__aCdCri09S[2],"",""},aHisCri,BCT->BCT_PERFOR=="1","",.F.)
				return .F.
			endIf

		endIf
		RestArea(aAreaBE2)
	endIf

	//Liberacao OK. Busco dados da da Enchoice                        
	SX3->(MsSeek("BEA"))
	while ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "BEA"

		//Campos chave nao podem ser atualizados...                               
		if allTrim(SX3->X3_CAMPO) $ "BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT,BEA_MESAUT,BEA_ANOAUT,BEA_DATPRO,BEA_MESPAG,BEA_ANOPAG"
			SX3->(dbSkip())
			Loop
		endif

		//Se a rda for generica nao atualiza dados da rda aqui na autorizacao...  
		if lRdaGen .and. allTrim(SX3->X3_CAMPO) $ cCamposRDA
			SX3->(dbSkip())
			Loop
		endif

		//Liberacao OK. Busco dados da da Enchoice (BEA)...                       
		If (SX3->X3_CONTEXT <> "V")

			cCampoBE1 := "M->BE1_" + Subs(AllTrim(SX3->X3_CAMPO),5,10)
			cCampoBEA := "BEA->" + AllTrim(SX3->X3_CAMPO)
			&cCampoBE1 := &cCampoBEA

		endIf


		SX3->(dbSkip())
	endDo

	//Verifica se e vai gerar um novo protocolo
	If lRn395 .And. type("cNumProto") <> "U" .And. Empty(cNumProto)

		cNumProto := space(20)
		if GetNewPar("MV_PLSUNI","1") == "1" .And. BEA->BEA_CODEMP == GetNewPar("MV_PLSGEIN","0050")

			If ! empty(BEA->BEA_NRTROL) .And. ((GetNewPar("MV_PL395WS","0") == "1" .And. PLSALIASEX("B4J")) .Or. lPTUOn70 ) 
				cNumProto := BEA->BEA_PROATE
			else	
				P773AutInc("BE1",@cNumProto,nil,.T.,.F.,nil,nil,nil,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),.T.)      
			endIf 

			lInterProt := .T.

		else
			P773AutInc("BE1",@cNumProto,nil,nil,nil,nil,nil,nil,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),.T.)
		endIf	

		if empty(cNumProto) .And. ! lInterProt 
			lRet := .F.
			return(lRet)
		endIf	

	endIf 

	//Monta dados do usuario...                                               
	M->BE1_USUARI := BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)
	M->BE1_GUIORI := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)

	BA1->(DbSetOrder(2))
	if BA1->(MsSeek(xFilial("BA1") + M->BE1_USUARI))

		M->BE1_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
		M->BE1_NOMUSR := BA1->BA1_NOMUSR
		M->BE1_MATANT := BA1->BA1_MATANT
		M->BE1_MATUSU := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

		if ! lRdaGen
			M->BE1_CODLOC := BEA->(BEA_CODLOC+BEA_LOCAL)
		endIf

	else
		Help("",1,"PLA090BA1")
	endIf

	if empty(M->BE1_TIPCON)
		M->BE1_TIPCON := "1"
	endIf

	//Alimenta o array de pacote												
	cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	aDadB43    := {}
	aCabB43    := {}
	aTrbB43    := {}

	if PLSALIASEXI("B43")

		Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
		B43->(DbSetOrder(2))

		if B43->(MsSeek(xFilial("B43")+cChave))
			Store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT) == xFilial("B43")+cChave
		else
			Store COLS Blank "B43" TO aDadB43 FROM aCabB43
		endIf

	endIf

	//Atualiza Enchoice...                                                    
	lRefresh := .t.
	oEncAut:oBox:refresh()
	oEncAut:oBox:setFocus()

	//Agora busco dados da GetDados...                                        
	oBrwPro:aCols := array(1,len(oBrwPro:aHeader)+1)
	nRow := 1
	While ! BE2->(Eof()) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2")+cChavLib

		If BE2->BE2_STATUS != '1'
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
			oBrwPro:addBlank()
		EndIf

		If GetNewPar("MV_PLSLIBE","0") == "1"
			BE2->(DbSkip())
			Loop
		EndIf

		//Se deu critica 09S, so posso apresentar os itens que sao seriado
		if lTemSeriad .And. aScan(aSeriado,BE2->BE2_SEQUEN) == 0
			BE2->(DbSkip())
			Loop
		endIf
		
		__nInd := 1
		for __nInd := 1 to len(oBrwPro:aHeader)

			if oBrwPro:aHeader[__nInd,2] == "BE2_QTDSOL" .And. oBrwPro:fieldPos("BE2_QTDSOL") > 0
				//atencao: BE2 aqui e da liberacao 
				//BE2_QTDSOL = ao que foi solicitado
				//BE2_QTDPRO = ao que foi autorizado (caso onde vai para auditoria)
				//na liberacao o BE2_QTDPRO recebe a quantidade BE2_QTDSOL
				//se a liberacao for para auditoria a BE2_QTDPRO deve ser alimentada com a quantidade autorizada
				if BE2->BE2_QTDSOL <> BE2->BE2_QTDPRO
					oBrwPro:fieldPut("BE2_QTDSOL",BE2->BE2_QTDPRO,nRow)
				else
					oBrwPro:fieldPut("BE2_QTDSOL",BE2->BE2_QTDSOL,nRow)
				endIf	 

				loop
			endIf

			if oBrwPro:aHeader[__nInd,2] == "BE2_SALDO"
				oBrwPro:fieldPut("BE2_SALDO",0,nRow)
				loop
			endIf

			//Se a regra for Pagamento no Ato, no evento da AutorizaÁ„o n„o ser· apresentado o Valor de Compra
			if oBrwPro:aHeader[__nInd,2] == "BE2_VLCOMP" .And. BEA->BEA_PAGATO == "1"
				If &("BE2->" + oBrwPro:aHeader[__nInd,2]) > 0
					oBrwPro:aCols[nRow,__nInd] := 0
					loop
				EndIf
			endIf

			//Parametro MV_PLSALIB para que o cliente tenha a opÁ„o de funcionar como na vers„o 11
			if oBrwPro:aHeader[__nInd,2] == "BE2_QTDPRO"

				if lPLIBESAL

					nQtdPro := execBlock("PLIBESAL",.f.,.f.,{ BE2->BE2_SALDO, cChavLib } )
					oBrwPro:fieldPut("BE2_QTDPRO", nQtdPro ,nRow)

				else	
					oBrwPro:fieldPut("BE2_QTDPRO", 0 ,nRow)
				endIf

				loop

			endIf

			if oBrwPro:aHeader[__nInd,10] <> "V"

				cField := "BE2->" + oBrwPro:aHeader[__nInd,2]
				cField := strTran(cField,"BE2","BE2")

				if TYPE(cField) <> "U"
					oBrwPro:aCols[nRow,__nInd] := &cField
				endIf

			else

				if oBrwPro:aHeader[__nInd,8] == "C"
					xField := ""
				elseIf oBrwPro:aHeader[__nInd,8] == "N"
					xField := 0
				elseIf oBrwPro:aHeader[__nInd,8] == "D"
					xField := ctod("")
				elseIf oBrwPro:aHeader[__nInd,8] == "L"
					xField := .F.
				endIf

				oBrwPro:aCols[nRow,__nInd] := xField

			Endif

		Next

		oBrwPro:aCols[nRow,len(oBrwPro:aHeader)+1] := .f.
		oBrwPro:FieldPut("BE2_IMGSTA","ENABLE",nRow)
		oBrwPro:FieldPut("BE2_DNIVAU",PLSRETNCRI(oBrwPro:FieldGet("BE2_NIVCRI",nRow),oBrwPro:FieldGet("BE2_CHVNIV",nRow),oBrwPro:FieldGet("BE2_NIVAUT",nRow)),nRow)
		oBrwPro:FieldPut("BE2_DNIVCR",PLSRETNCRI(oBrwPro:FieldGet("BE2_NIVCRI",nRow)),nRow)

		oBrwPro:aVetTrab[nRow] := BE2->(recno())

		//Atualizacao do valor do campo BE2_QTDSOL com os dados do campo BE2_QTDPRO≥
		if __cTipo == "2"
			oBrwPro:aCols[nRow,nPosPro] := BE2->BE2_QTDSOL
		endIf

		BE2->(DbSkip())
		nRow ++
	endDo

	For __nInd := 1 To Len(oBrwPro:aCols)
		For __nAux := 1 To Len(oBrwPro:aHeader)
			If ValType(oBrwPro:aCols[__nInd,__nAux]) == "U"
				oBrwPro:aCols[__nInd,__nAux] := CriaVar(AllTrim(oBrwPro:aHeader[__nAux,2]))
			Endif
		Next
		oBrwPro:aCols[__nInd,Len(oBrwPro:aHeader)+1] := .F.
	Next

	lRet := PLSA090USR(M->BE1_USUARI,M->BE1_DATPRO,M->BE1_HORPRO,"BE1",.T.)

	if !lRet
		return(lRet)
	endIf

	PLSA090RDA(M->BE1_OPERDA,M->BE1_CODRDA,"1",M->BE1_DATPRO,M->BE1_USUARI,M->BE1_CODLOC,M->BE1_CODESP,"BE1",.F.)

	// Atualiza os dados da guia juridica.
	If BEA->(FieldPos("BEA_GUIJUR")) > 0 // Se existir no BEA, vai existir no BE1.
		PLSGUIJUR("BE1_GUIJUR")
	Endif

	oBrwPro:atualiza(.f.)

elseIf BE2->(MsSeek(xFilial("BE2")+cChavLib))
	While BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2")+cChavLib .And. !BE2->(Eof())
		If BE2->BE2_SALDO > 0 
			lFechada := .T.
		EndIf
		BE2->(DbSkip()) 
	enddo
	If !lFechada
		lRet := .F.

		Aviso( "ATEN«√O","N„o h· itens na guia para ser executada.",{ STR0146 }, 2 )
	else
		lRet := .F.
		Aviso( "AUDITORIA","Guia encontra-se em Auditoria e n„o pode ser executada",{ STR0146 }, 2 )	 
	EndIf	

else

	lRet := .F.
	Help("",1,"PLNUMLIB")

	endIf

return(lRet)

/*/{Protheus.doc} PL090CLS
Clear Screan - Valid BE1_NUMLIB(Numero LiberaÁ„o) Limpa Tela 

@author  PLS TEAM
@version P11
@since   05.10.07
/*/
Function PL090CLS()
	Local aRet:=.F.
	If Empty(M->BE1_NUMLIB)
		If !Empty(M->BE1_USUARI) .and. UPPER( Alltrim( FunName() ) ) <> "TMKA271"
		A090Limpa("BE1",oEncAut,oBrwPro,"BE2")
			aRet:=.F.
		Else
			aRet:=.T.
		Endif
	Else
		PLA090LIB(M->BE1_NUMLIB,M->BE1_DATPRO)
		aRet:=.T.
	Endif

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSOPEOLN
Clear Screan - Valid BE1_NUMLIB(Numero LiberaÁ„o) Limpa Tela 

@author  PLS TEAM
@version P11
@since   05.10.07
/*/
//-------------------------------------------------------------------
Function PLSOPEOLN(cOpeOri)
	LOCAL nOrdBA0 := BA0->(IndexOrd())
	LOCAL nRecBA0 := BA0->(Recno())
	LOCAL lRet    := .F.

	BA0->(DbSetOrder(1))
	If BA0->(MsSeek(xFilial("BA0")+cOpeOri))
	lRet := (BA0->BA0_ONLINE == "1")
	Endif

	BA0->(DbSetOrder(nOrdBA0))
	BA0->(DbGoTo(nRecBA0))

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBcoCon
Banco de conhecimento dos itens  

@author  PLS TEAM
@version P11
@since   18.05.06
/*/
//-------------------------------------------------------------------
Function Pls090Bco(cOp)

	Local aArea		:= GetArea()
	Local aAreaBEA	:= BEA->(GetArea())
	Local aAreaBE2	:= BE2->(GetArea())
	Local aAreaB53	:= B53->(GetArea())
	Local aRotBack  := aRotina
	Local cQuery	:= ""
Local cIndex	:= ""
LOCAL cChaveInt  	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
LOCAL cChaveAC9 := BEA->BEA_FILIAL+cChaveInt
local nIndex	  := 1

Default cOp		:= "I" // C = Anexo vinculado ao cabeÁalho  I = Anexo vinculado ao item

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

aRotina := {{STR0256,'MsDocument',0,3},{"Inclus„o R·pida",'PLSDOcs',0,3}} //"Conhecimento"


BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
BEA->( MsSeek( xFilial("BEA") + cChaveInt ) )
DbSelectArea("BE2")

If cOp == "I" // inclus„o nos itens

	nIndex := BE2->(IndexOrd())	
	cIndex := CriaTrab(NIL,.F.)
	cQuery := "BE2_FILIAL == '" + xFilial("BE2") + "' "
	cQuery += " .And. BE2_OPEMOV == '" + BEA->BEA_OPEMOV + "'"
	cQuery += " .And. BE2_ANOAUT == '" + BEA->BEA_ANOAUT + "'"
	cQuery += " .And. BE2_MESAUT == '" + BEA->BEA_MESAUT + "'"
	cQuery += " .And. BE2_NUMAUT == '" + BEA->BEA_NUMAUT + "'"

	IndRegua("BE2",cIndex,BE2->(IndexKey()),,cQuery)

	If BE2->(!Eof())
		MaWndBrowse(0,0,300,600,STR0027,"BE2",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
	EndIf

	If PLSALIASEX("B53")

		AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_

		If AC9->(dbSeek( xFilial("AC9") + "BE2" +xfilial('BE2')+cChaveAC9))

			If B53->(dbSeek(xFilial("B53")+cChaveInt))
				If B53->B53_BANCON != '1'
					B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '1'
					B53->(MsUnlock())
				EndIf
			EndIf
		else

			If B53->(dbSeek(xFilial("B53")+cChaveInt))
				If B53->B53_BANCON != '0'
					B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '0'
					B53->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf

	RetIndex( "BE2" )
	dbClearFilter()
	FErase( cIndex+OrdBagExt() )
Else	
	MsDocument( "BEA", BEA->( RecNo() ), 2 )
	PLSATUB53(cChaveAC9, cChaveInt)	
EndIf

aRotina := aRotBack

BE2->(DbCloseArea())
	RestArea(aArea)

	RestArea(aAreaBEA)
	RestArea(aAreaB53)
	RestArea(aAreaBE2)

Return .T.

/*/{Protheus.doc} A090CHEBLO
Verifica se o Profissional de Saude esta bloqueado na data
informada                                                 
Parametros:                                               
- cCodPfs: Codigo do Profissional de Saude                
- dData:   Data a ser considerada na comparacao com o     
historico de bloqueio                          
- lMens:   Se deve exibir mensagem quando usuario estiver 
bloqueado (.T. - Exibe, .F. - Nao Exibe)
- cHora: Hora a ser considerada na comparacao com o 
historico de bloqueio (HHMM). Nao obrigatorio.       
Retorno:                                                  
- lRet: .T. - Bloqueado / .F. - Ativo  

@author  PLS TEAM
@version P11
@since   25.09.06
/*/
Function A090CHEBLO(cCodPfS,dData,lMens,aProfs,cHora)
	Local lRet	:= .T.
	Local lBloq	:= .F.
	Local nI	:= 0

	Default lMens 	:= .T.
	Default aProfs	:= {}
	Default cHora	:= ""

If Len(aProfs) > 0
	For nI := 1 To Len(aProfs)
		BB0->(DbGoTo(aProfs[nI][1]))
		lBloq := xCHEBLO(aProfs[nI][2],dData,aProfs,cHora)
		If !lBloq //achei pelo menos um que esta desbloqueado
			exit
		Endif
	Next
Else
	lBloq := xCHEBLO(cCodPfS,dData,aProfs,cHora)
Endif

If  lBloq
	If lMens
		MsgAlert("Profissional de Sa˙de ["+BB0->BB0_CODSIG+BB0->BB0_NUMCR+BB0->BB0_ESTADO+"] ["+BB0->BB0_NOME+"] bloqueado nesta data.")
		EndIf
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} xCHEBLO
@author  PLS TEAM
@version P11
@since   25.09.06
/*/
static function xCHEBLO(cCodPfS,dData,xReserv,cHora)
	local lBloq 		:= .F.
	local cAliBlo		:= ""
local cAliDes		:= ""
local cData 		:= ""
local cTipBlo 	:= "0"
local cTipDes 	:= "1"

default cHora 	:= ""

//Formatando campo de Data
if ValType(dData) == "D"
	cData := DtoS(dData)
elseif ValType(dData) == "C" .And. At(dData,"/") > 0
	cData := CtoD(dData)
	cData := DtoS(cData)
else
	cData := dData
endif

//Inicio WHERE
cWhere := "%"
//Caso for informada, a consulta deve considerar a Hora
if ! Empty(cHora)
	cHora := StrTran(cHora,":","")
	cHora := SubStr(cHora,1,4)
	cWhere += "B17_HORA <= '" + cHora + "' AND "
endif
cWhere += "%"
// Final WHERE

cAliBlo := GetNextAlias()

//Procura o Bloqueio mais recente 
BeginSql alias cAliBlo
	SELECT
	MAX(B17_DATA) DATBLO, MAX(B17_HORA) HORA
	FROM
	%table:B17% B17
	WHERE
	B17_FILIAL = %exp:xFilial("B17")%  AND
	B17_CODPFS	=	%exp:cCodPfS%	AND
	B17_DATA	<=	%exp:cData% 	AND
	%exp:cWhere%
	B17_TIPO 	= 	%exp:cTipBlo%	AND
	B17.%notdel%
	ORDER BY
	DATBLO DESC
EndSql

if !(cAliBlo)->(Eof()) .And. !Empty((cAliBlo)->DATBLO + (cAliBlo)->HORA)
	lBloq := .T.
	cAliDes := GetNextAlias()
	//Procura o DesBloqueio mais recente 
	BeginSql alias cAliDes
		SELECT
		MAX(B17_DATA) DATBLO, MAX(B17_HORA) HORA
		FROM
		%table:B17% B17 
		WHERE
		B17_FILIAL = %exp:xFilial("B17")%  AND
		B17_CODPFS	=	%exp:cCodPfS%	AND
		B17_DATA	<=	%exp:cData% 	AND
		%exp:cWhere%
		B17_TIPO 	= 	%exp:cTipDes%	AND
		B17.%notdel%
		ORDER BY
		DATBLO DESC
	EndSql

	if !(cAliDes)->(Eof()) .And. !Empty((cAliDes)->DATBLO + (cAliDes)->HORA) .And. (cAliDes)->DATBLO > (cAliBlo)->DATBLO
		lBloq := .F.
	endif

	if !(cAliDes)->(Eof()) .And. !Empty((cAliDes)->DATBLO + (cAliDes)->HORA) .And. (cAliDes)->DATBLO = (cAliBlo)->DATBLO .And. (cAliDes)->HORA > (cAliBlo)->HORA
		lBloq := .F.
	endif

	//Fecha o alias da query de desbloqueio
	(cAliDes)->(DbCloseArea())

endif

//Fecha o alias da query de bloqueio
	(cAliBlo)->(DbCloseArea())

Return lBloq

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsNDel
Nao deixa deletar os itens quando estiver em alteracao

@author  PLS TEAM
@version P11
@since   16.08.06
/*/
//-------------------------------------------------------------------
Function PlsNDel()
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsNDelBQV
Analisa delecao do complemento de SADT 

@author  PLS TEAM
@version P11
@since   19.10.11
/*/
//-------------------------------------------------------------------
Function PlsNDelBQV()
	LOCAL cChave := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)
	LOCAL cCodTran  := ""
LOCAL nPosTran  := 0
LOCAL nI        := 0

//Se ja comunicacao ja realizada, nao permite realizar a delecao					

If !lConf
	MsgInfo(STR0536)//"ComunicaÁ„o j· realizada, n„o È possÌvel realizar esta aÁ„o."
	Return .F.
EndIf

//Se ja comunicou nao deixa deletar												

If ValType(oBrwBQV090) <> 'U'

	cChave +=oBrwBQV090:FieldGet("BQV_SEQUEN")+oBrwBQV090:FieldGet("BQV_CODPAD")+oBrwBQV090:FieldGet("BQV_CODPRO")

	//Verifica se o procedimento ja esta no contas medicas							

	BD6->( DbSetOrder(1) ) //BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
	If BD6->( MsSeek( xFilial("BD6")+cChave ) )

		// Se foi realizada pelo remote, nao foi importada, item da evolucao nao foi impresso, nao foi contabilizado
		If BD6->BD6_TPGRV == "1" .and. empty(BEA->BEA_ARQIMP) .and. empty(oBrwBQV090:FieldGet("BQV_SEQIMP")) .and. !PLCHKCTB('D',BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN))

			//Se comunicao online, verifica itens ja marcados para exclusao					
			If BEA->BEA_COMUNI == "1" .and. BQV->( FieldPos("BQV_NRTROL") ) > 0

				nPosTran := aScan(oBrwBQV090:aHeader,{|x| alltrim(x[2]) == "BQV_NRTROL"})

				For nI := 1 to len(oBrwBQV090:aCols)

					If oBrwBQV090:aCols[nI][len(oBrwBQV090:aHeader)+1]
						cCodTran := oBrwBQV090:aCols[nI][nPosTran]
						Exit
					EndIf

				Next

				If Empty(cCodTran) .Or. cCodTran == oBrwBQV090:FieldGet("BQV_NRTROL")
					Return .T.
				Else
					MsgInfo(STR0602)//"Registro com transaÁ„o diferente de um registro j· marcado para exclus„o (Nr. Tr. OnLine)"
						Return .F.
					EndIf
				Else
					Return .T.
				EndIf

			Else
				Return .F.
			EndIf

		EndIf

	EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCONFSOL
Funcao para envio de cancelamento,conclusao ou Revisao  

@author  PLS TEAM
@version P11
@since   16.08.06
/*/
//-------------------------------------------------------------------
Function PLSCONFSOL(oObjBrw,oBrwCri,cAliasCab,cAliasIte,cAliasCri,aDados,cTranOri,nOpc,lEvolucao)
	LOCAL nRet
	LOCAL nY
	LOCAL nI
	LOCAL nSequen
	LOCAL nPos
	LOCAL nPos2
	LOCAL cCodCri
	LOCAL cDesCri
	LOCAL nTipo 		:= 0
	LOCAL lRevi			:= .F.
	LOCAL lEnc			:= .T.
	LOCAL lEnvia   		:= .F.
	LOCAL lRevisao 		:= .F.
	LOCAL lFindB4A      := .F.
	LOCAL aRet 	   		:= {}
	LOCAL aRetOln  		:= {}
	LOCAL cText			:= ""
LOCAL cMsgXsdErr   := ""
LOCAL nRecB4A       := 0
DEFAULT lEvolucao	:= .F.

//Verifica tipo de pergunta												

If Empty( &("M->"+cAliasCab+"_MSG04") ) .And. &("M->"+cAliasCab+"_AUDITO") <> "1" .And. !lEvolucao//Nao e revisao e nao esta na auditoria
	nTipo := 1
	cText := STR0333//"Nao solicitou revisao e nao esta na auditoria!"
ElseIf !Empty( &("M->"+cAliasCab+"_MSG04") ) .And. Empty( &("M->"+cAliasCab+"_MSG05") ) .And. !lEvolucao//revisao e nao teve resposta
	nTipo := 2
	cText := STR0334//"Solicitou revisao e nao teve resposta!"
ElseIf !Empty( &("M->"+cAliasCab+"_MSG04") ) .And. !Empty( &("M->"+cAliasCab+"_MSG05") ) .And. &("M->"+cAliasCab+"_AUDITO") == "1" //revisao e nao teve resposta e esta na auditoria
	nTipo := 0
	cText := STR0335//"Solicitou revisao ja teve resposta e esta na auditoria!"
ElseIf &("M->"+cAliasCab+"_AUDITO") == "1" //Em auditoria
	nTipo := 4
	cText := STR0336//"Em auditoria!"
ElseIf lEvolucao
	nPos := aScan(oObjBrw:aHeader,{|x| x[2] == "BQV_AUDITO"}) //Se evolucao verifica se a resposta foi enviada para auditoria
	nPos2 := aScan(oObjBrw:aHeader,{|x| x[2] == "BQV_NRTROL"})

	If nPos2 > 0 .And. (nPosTrol := aScan(oObjBrw:aCols,{|x| Alltrim(x[nPos2]) == Alltrim(cTranOri)})) > 0 .And. ;
	nPos  > 0 .And. oObjBrw:aCols[nPosTrol][nPos] == "1"

		nTipo := 4
		cText := STR0336//"Em auditoria!"

	EndIf
EndIf

//Verifica se vai cancelar ou continuar									

If nTipo == 1
	nRet := Aviso(STR0323,STR0324+Chr(13)+Chr(10)+cText,{ STR0326,STR0327 }, 2 ) //"AtenÁ„o","Solicita Revis„o?"Sim","Nao"
	nRet := Iif(nRet==1,3,4)
ElseIf nTipo == 2
	nRet := Aviso(STR0323,STR0325+Chr(13)+Chr(10)+cText,{ STR0326,STR0327 }, 2 )//"AtenÁ„o","Solicita Cancelamento?"Sim","Nao"
	nRet := Iif(nRet==1,1,4)
ElseIf nTipo == 3
	nRet := Aviso(STR0323,STR0325+Chr(13)+Chr(10)+cText,{ STR0326,STR0327 }, 2 )//"AtenÁ„o","Solicita Cancelamento?"Sim","Nao"
	nRet := Iif(nRet==1,1,4)
ElseIf nTipo == 4
	While .T.
		nRet := Aviso(STR0323,STR0328+Chr(13)+Chr(10)+cText,{ STR0329,STR0330}, 2 )//"AtenÁ„o","Qual execuÁ„o ser· tomada?""Cancelar","Concluir"
		If nRet <> 0
			If nRet == 2 //Se a reposta for "Concluir", nao envio o 00209/00309
				nRet := 4
			EndIf
			Exit
		EndIf
	EndDo
ElseIf nTipo == 0
	nRet := Aviso(STR0323,STR0328+Chr(13)+Chr(10)+cText,{ STR0329,STR0330,STR0331,STR0332 }, 2 )//"AtenÁ„o","Qual execuÁ„o ser· tomada?" "Cancelar","Concluir","Revis„o","Sair"
	If lEvolucao .And. nRet == 2
		nRet := 4
	EndIf
EndIf

//Caso necessite de pedir revisao em outro momento						

Do Case

	//Enviando a Cancelamento transacao 00211/00311									

	Case nRet == 1
		PlsPtuPut("CD_TRANS","00311",aDados)						 //Envio de Conclusao ou Cancelamento
		PlsPtuPut("TP_IDENTIF",AllTrim(Str(nRet)),aDados)  		 //Identifica a Transacao aceita
		lEnvia := .T.

		//Enviando a Conclusao do pedido 00209/00309								
		//Alimenta as variaveis do layout 									    

		Case nRet == 2
		PlsPtuPut("CD_TRANS","00309",aDados)						 //Envio de Conclusao ou Cancelamento
		PlsPtuPut("TP_IDENTIF",AllTrim(Str(nRet)),aDados)  		 //Identifica a Transacao aceita
		lEnvia := .T.

	//Tela para pedido de insistencia											

	Case nRet == 3
		If !Empty(cAliasCab) .And. oObjBrw <> Nil
			aRet := INSISTECOM(cAliasCab,oObjBrw)
			If aRet[1]
				PlsPtuPut("CD_TRANS","00302",aDados) //Envio de Revisao
				PlsPtuPut("DS_MENS_LI",aRet[2,1],aDados) 		  //Mensagem de Revisao
				lEnvia   := .T.
				lRevisao := .T.
			EndIf
		EndIf
EndCase

If nRet == 1 .And. (nTipo == 2 .Or. nTipo == 4) .And. nOpc <> K_Excluir
	If !Empty(oObjBrw:FieldGet(cAliasIte+"_NRTROL",nI))
		cTranOri  := oObjBrw:FieldGet(cAliasIte+"_NRTROL",nI)
		cTranCanc := oObjBrw:FieldGet(cAliasIte+"_NRAOPE",nI)
	EndIf
	aRetDesCan := PLSCANCCOM()
	If Empty(aRetDesCan[1])
		MsgInfo(STR0601) //"Para a vers„o 5.0 ou superior do PTU Online, È obrigatÛrio o preenchimento do motivo de cancelamento."
		Return(.F.)	
	EndIf
	If !Empty(aRetDesCan[1]) //PTU Online Versao 5.0 ou superior
		PlsPtuPut("DS_MOTIVO",aRetDesCan[1],aDados)                   //DS_MOTIVO  - DescriÁ„o do Motivo do Cancelamento
	EndIf
EndIf								

//Se vai enviar															

If lEnvia

	//Comunicacao e tratamneto											    

	aGrvTraPTU := {AllTrim(cTranOri),PlsPtuGet("CD_TRANS",aDados),PlsIntPad(),PlsPtuGet("CD_UNI_DES",aDados), &("M->"+cAliasCab+"_NOMUSR")}
	MsAguarde( {|| aRetOln := PlsPtuOln(aDados,{},AllTrim(cTranOri)+"A."+Subs(PLSINTPAD(),2,3) ,.F.,.F.,aGrvTraPTU,,,@cMsgXsdErr ) }, 'Comunicando' , STR0177, .F.) //"Aguarde..."

	//Tratamento do Retorno													

	If Len(aRetOln) > 0

		If PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "2" .Or. PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "3"
			iif(PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "2",cRespIns:=STR0652,cRespIns:=STR0653) //"2-Guia Inexistente"###"3-SituaÁ„o Inv·lida" 
			Aviso( STR0120,STR0650+cRespIns,{ STR0146 }, 2 )	//"Atencao" //"N„o foi possÌvel processar a solicitaÁ„o, resposta da Operadora Origem: "
		
		//So entra se nao for evolucao da gih  									
		ElseIf !lEvolucao

			//Conclui ou cancela a transacao											
			If nRet == 2

				//Finaliza																		
				&("M->"+cAliasCab+"_TRACON") := "1"

			//Cancelamento Ou Revisao															
			ElseIf nRet == 1 .Or. nRet == 3

				//Pega criticas
				If nRet == 1
					If PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])
						cCodCri := __aCdCri107[1]
						cDesCri := PLSBCTDESC()
					EndIf

					//Atualiza Cabecalho
					&("M->"+cAliasCab+"_CANCEL") := "1"
					&("M->"+cAliasCab+"_SENHA")  := ""
					&("M->"+cAliasCab+"_TRACON") := "1"

					//Quando nao foi na inclusao nao muda fase e necessario ajustar o contas
					If nOpc <> K_Incluir

						//Se for internacao ou evolucao
						If cAliasCab == "BE4"
							SIX->(DbSetOrder(1))
							If SIX->( MsSeek("BEAM") )
								BEA->( DbSetOrder(22) )//BEA_FILIAL + BEA_NRTROL
								If !BEA->( MsSeek( xFilial("BEA")+BE4->BE4_NRTROL ) )
									lEnc := .F.
								EndIf
							EndIf
						EndIf

						//Se nao encontra nao atualiza o status da guia
						If lEnc
							PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,"2",NIL,NIL,.T.,,,,,,,,,"3")
						Else
							Alert(STR0322+" ("+BE4->BE4_NRTROL+")!")  //"Nao foi possivel atualizar o status da guia na transacao"
						EndIf
					EndIf
					lConf := .T.
				EndIf

				//Atualiza Itens
				For nI := 1 To Len(oObjBrw:aCols)

					//Cancelamento
					If nRet == 1

						//Pega a Sequencia
						nSequen := oObjBrw:FieldGet(cAliasIte+"_SEQUEN",nI)

						//Limpa as criticas referente ao procedimento
						For nY := 1 To Len(oBrwCri:aCols)
							If oBrwCri:FieldGet(cAliasCri+"_SEQUEN",nY) == nSequen
								oBrwCri:FieldPut(cAliasCri+"_CODGLO","",nY)
								oBrwCri:FieldPut(cAliasCri+"_DESGLO","",nY)
								oBrwCri:FieldPut(cAliasCri+"_INFGLO","",ny)
							EndIf
						Next

						//Para os procedimentos
						If TYPE(cAliasIte+"->"+cAliasIte+"_LIBESP") == "C"
							oObjBrw:FieldPut(cAliasIte+"_LIBESP","0",nI)
						EndIf

						//Atualiza variaveis
						oObjBrw:FieldPut(cAliasIte+"_AUDITO","0",nI)

						//Procura a posicao na acols
						nPos := Ascan( oBrwCri:aCols , { |x| AllTrim(x[oBrwCri:PlRetPos(cAliasCri+"_SEQUEN")]) == nSequen } )

						//Se nao achar cria uma linha
						If nPos == 0
							oBrwCri:AddBlank()
							nPos := Len(oBrwCri:aCols)
						EndIf

						//Atualiza																
						oBrwCri:FieldPut(cAliasCri+"_SEQUEN",nSequen,nPos)
						oBrwCri:FieldPut(cAliasCri+"_CODGLO",cCodCri,nPos)
						oBrwCri:FieldPut(cAliasCri+"_DESGLO",cDesCri,nPos)

					//Revisao
					Else
						If TYPE(cAliasIte+"->"+cAliasIte+"_SOLREV") == "C"
							oObjBrw:FieldPut(cAliasIte+"_SOLREV","1",nI)
							oObjBrw:FieldPut(cAliasIte+"_AUDITO","1",nI)//Nova regra 3.5, revisao vai para auditoria

							If !lEvolucao
								&("M->"+cAliasCab+"_AUDITO") := "1"
							EndIf
							//Ajusta anexo se houver 
							If nOpc == K_Alterar
								B4A->(DbSetOrder(4))//B4A_FILIAL+B4A_GUIREF
								If cAliasCab == "BE4" 
									If B4A->(MsSeek(xFilial("B4A")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
										While B4A->B4A_GUIREF == BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) .And. !B4A->(Eof())  
											If cTranOri == Alltrim(B4A->B4A_NRTROL)
												lFindB4A := .T.    
												nRecB4A  := B4A->(Recno())
												Exit
											EndIf
											B4A->(DbSkip())
										EndDo
									EndIf
								Else
									If B4A->(MsSeek(xFilial("B4A")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
										While B4A->B4A_GUIREF == BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) .And. !B4A->(Eof())  
											If cTranOri == Alltrim(B4A->B4A_NRTROL)
												lFindB4A := .T.    
												nRecB4A  := B4A->(Recno())
												Exit
											EndIf
											B4A->(DbSkip())
										EndDo
									EndIf
								EndIf   

								If lFindB4A
									B4A->(DbGoTo(nRecB4A))
									B4A->( RecLock("B4A",.F.) )
									B4A->B4A_STATUS := "3"
									B4A->B4A_AUDITO := "1" 
									B4A->B4A_NRTROL := cTranOri
									B4A->( MsUnLock() ) 

									B4C->(DbSetOrder(1))//B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN
									If B4C->(MsSeek(xFilial("B4C")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)))
										While B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) == B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT) .And. !B4C->(Eof())
											B4C->( RecLock("B4C",.F.) )
											B4C->B4C_STATUS := "0"
											B4C->B4C_AUDITO := "1" 
											B4C->B4C_NRTROL := cTranOri
											B4C->( MsUnLock() ) 

											B4C->(DbSkip())
										EndDo
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					oObjBrw:FieldPut(cAliasIte+"_STATUS","0",nI)
					oObjBrw:FieldPut(cAliasIte+"_IMGSTA","DISABLE",nI)
				Next
			EndIf

		//Conclusao dos itens da evolucao de GIh
		ElseIf lEvolucao

			//Conclusao
			If nRet == 2

				//For de procedimentos
				For nI := 1 To Len(oObjBrw:aCols)

					//Transacao concluida para o procedimento
					If oObjBrw:FieldGet(cAliasIte+"_TRACON",nI) <> "1"
						oObjBrw:FieldPut(cAliasIte+"_TRACON","1",nI)
					EndIf
				Next

				//Cancelamento ou Revisao
			ElseIf nRet == 1 .Or. nRet == 3

				//Pega criticas
				If nRet == 1
					If PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])
						cCodCri := __aCdCri107[1]
						cDesCri := PLSBCTDESC()
					EndIf
				EndIf

				//Atualiza Itens
				For nI := 1 To Len(oObjBrw:aCols)

					//Se ja comunicou e nao concluiu solicito revisao
					If oObjBrw:FieldGet(cAliasIte+"_COMUNI",nI) == "1" .And. oObjBrw:FieldGet(cAliasIte+"_TRACON",nI) <> "1"

						//Cancelamento
						If nRet == 1

							//Pega a Sequencia
							nSequen := oObjBrw:FieldGet(cAliasIte+"_SEQUEN",nI)

							//Limpa as criticas referente ao procedimento
							For nY := 1 To Len(oBrwCri:aCols)
								If oBrwCri:FieldGet(cAliasCri+"_SEQUEN",nY) == nSequen
									oBrwCri:FieldPut(cAliasCri+"_CODGLO","",nY)
									oBrwCri:FieldPut(cAliasCri+"_DESGLO","",nY)
									oBrwCri:FieldPut(cAliasCri+"_INFGLO","",ny)
								EndIf
							Next

							//Atualiza variaveis
							oObjBrw:FieldPut(cAliasIte+"_AUDITO","0",nI)
							oObjBrw:FieldPut(cAliasIte+"_CANCEL","1",nI)
							oObjBrw:FieldPut(cAliasIte+"_TRACON","1",nI)
							oObjBrw:FieldPut(cAliasIte+"_SENHA","",nI)

							//Procura a posicao na acols
							nPos := Ascan( oBrwCri:aCols , { |x| AllTrim(x[oBrwCri:PlRetPos(cAliasCri+"_SEQUEN")]) == nSequen } )

							//Se nao achar cria uma linha
							If nPos == 0
								oBrwCri:AddBlank()
								nPos := Len(oBrwCri:aCols)
							EndIf

							//Atualiza
							oBrwCri:FieldPut(cAliasCri+"_SEQUEN",nSequen,nPos)
							oBrwCri:FieldPut(cAliasCri+"_CODGLO",cCodCri,nPos)
							oBrwCri:FieldPut(cAliasCri+"_DESGLO",cDesCri,nPos)

						//Revisao
						Else
							If TYPE(cAliasIte+"->"+cAliasIte+"_SOLREV") == "C"
								oObjBrw:FieldPut(cAliasIte+"_SOLREV","1",nI)
								oObjBrw:FieldPut(cAliasIte+"_AUDITO","1",nI)//Nova regra 3.5, revisao vai para auditoria
							EndIf
						EndIf
						oObjBrw:FieldPut(cAliasIte+"_STATUS","0",nI)
						oObjBrw:FieldPut(cAliasIte+"_IMGSTA","DISABLE",nI)
					EndIf
				Next
			EndIf
		EndIf
		//EndIf

		//Exibe msg de retorno															

		PlsPtuLog("***********************************")
		PlsPtuLog(STR0489)//"TransaÁ„o concluÌda com sucesso"
		PlsPtuLog("***********************************")
		MsgInfo(STR0489)//"TransaÁ„o concluÌda com sucesso"
	Else
		If !Empty(cMsgXsdErr)  
			PlsPtuLog(STR0321)  //"INCONSISTENCIA NA OPERACAO DE ENVIO!"    
			MsgInfo(cMsgXsdErr)
		Else
			//Mostra o Log															
			PlsPtuLog(STR0321)  //"INCONSISTENCIA NA OPERACAO DE ENVIO!"
			MsgAlert(STR0321)//"INCONSISTENCIA NA OPERACAO DE ENVIO!"
		EndIf	
	EndIf
EndIf

//.T. para Refresh														

lRefresh := .T.

//Refresh nos brw s														

	oObjBrw:Atualiza()
	oBrwCri:ForceRefresh(oObjBrw)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSACOMP
Altera o cabeca/item e critica da guia	  

@author  PLS TEAM
@version P11
@since   16.08.06
/*/
//-------------------------------------------------------------------
Function PLSACOMP(cTranOri,cTranDes,cResRev,aIte,cTpTran,cOpeSol,cDatValSen,lDecurso,l404Triang)
	LOCAL aArea := GetArea()
	LOCAL nPos			:= 0
	LOCAL nI			:= 0
	LOCAL nY			:= 0
	LOCAL cSituac		:= ''
LOCAL cStatus		:= ''
LOCAL nSequen		:= 0
LOCAL cOpeMov		:= ''
LOCAL cAnoAut		:= ''
LOCAL cMesAut		:= ''
LOCAL cNumAut		:= ''
LOCAL cTipGui		:= ''
LOCAL cCodLdp		:= ''
LOCAL cCodPeg		:= ''
LOCAL cNumGui		:= ''
LOCAL cSenhaAut		:= ''
LOCAL nQtdAtu := 0
LOCAL lAudito := .F.
LOCAL lAutUm  := .F.
LOCAL lNegUm  := .F.
LOCAL lRetMudFas := .F.
LOCAL aMatBQV := {}
LOCAL cRet	  := ""
LOCAL nRecBEA := BEA->(Recno())
LOCAL nRecBE2 := BE2->(Recno())
LOCAL nRecBEG := BEG->(Recno())
LOCAL nRecBE4 := BE4->(Recno())
LOCAL nRecBEJ := BEJ->(Recno())
LOCAL nRecBEL := BEL->(Recno())
LOCAL nRecBQV := BQV->(Recno())
LOCAL nRecBQZ := BQZ->(Recno())
LOCAL nRecB4A 		:= B4A->(Recno())
LOCAL nRecB4C 		:= B4C->(Recno())
LOCAL cCodCri := "000"
LOCAL cDesCri := STR0318//"CRITICA DESABILITADA"
LOCAL cSQL    := ""
LOCAL nRecno  := ""
LOCAl nSeqCri := 0
LOCAL cDesGenPtu	:= __cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen
LOCAL lEvoluSadt  := .F.
LOCAL lExit       := .F.
LOCAL cTranArq    := cTranOri
LOCAL aVerArq     := {}
LOCAL cResRev1		:= SubStr(cResRev,1,254)
LOCAL cResRev2		:= SubStr(cResRev,255)
local lAuditoB4A 	:= .f.
Local lCompl        := .F.
local lNegUmB4C		:= .f.
local lAutUmB4C		:= .f.
local cStatusB4A	:= "0" 
local lLibAud       := .F.

LOCAL lRn395        := GetNewPar("MV_PLRN395","0") == "1"
LOCAL cStatusB00    := ""
LOCAL cProAte       := ""
LOCAL cTraBQVAne    := cTranOri
LOCAL nTamNumSeq    := TamSX3("B0S_NUMSEQ")[1]
LOCAL lPl90L1       := ExistBlock("PLS090L1")
Local lMsgLivPTU8   := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80" .And. PLSALIASEXI("B6M")
Local lGrvPTU8 		:= .F.

default lDecurso	:= .F.
default l404Triang  := .F.

//Verifica se e o retorno de uma evolucao 00505, neste caso,          
//o sistema busca o codigo da transacao original    				    
If BEA->(FieldPos("BEA_NRTROL")) > 0
	B0S->(DbSetOrder(1))//B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL+B0S_ENVREC
	If B0S->(DbSeek(xFilial("B0S")+cTranOri+Space( nTamNumSeq-Len(cTranOri))+"00605"+cOpeSol))

		//E um complemento, verifica a transacao original						    

		B0T->(DbSetOrder(1))//B0T_FILIAL+B0T_NUMSEQ+B0T_TIPTRA+B0T_OPESOL+B0T_IDENT+B0T_VARIAV
		If B0T->(DbSeek(xFilial("B0T")+cTranOri+Space( nTamNumSeq-Len(cTranOri))+"00605"+cOpeSol+"CAB"+"NR_TRANS_R"))
			cTranOri := Alltrim(B0T->B0T_CONTEU)
			lCompl := .T.
		EndIf
	EndIf

	//Faz a segunda verificacao diretamente na BQV
	SIX->( DbSetOrder(1) )
	If !lCompl .And. BQV->(FieldPos("BQV_NRTROL")) > 0 .And. SIX->( MsSeek("BQV5") )   
		BQV->(DbSetOrder(5))//BQV_FILIAL+BQV_NRTROL
		BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
		If BQV->(MsSeek(xFilial("BQV")+cTranOri)) 
			While Alltrim(BQV->BQV_NRTROL) == Alltrim(cTranOri) .And. !BQV->(	Eof())
				If BEA->(MsSeek(xFilial("BEA")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) )) .And. BEA->BEA_OPESOL == cOpeSol
					cTranOri := Alltrim(BEA->BEA_NRTROL)
					lCompl := .T.
					Exit
				EndIf
				BQV->(DbSkip())
			EndDo
		EndIf
	EndIf

Else
	cRet := STR0315//"INDICE (E) NO BEA NAO EXISTE"
EndIf

//Como estou recebendo uma resposta de auditoria, procuro somente         
//transacoes onde a operadora origem e a minha                            
//NOVO AJUSTE: versao 5.0, a transacao 00700 pode ter outra operadora como Opesol
If BEA->(FieldPos("BEA_NRTROL")) > 0

	If Select("BEANRTROL") > 0
		DbSelectArea("BEANRTROL")
		BEANRTROL->(DbCloseArea())
	Endif

	cSQL := " SELECT BEA_LIBERA, R_E_C_N_O_ FROM "+RetSqlName("BEA")
	cSQL += " WHERE BEA_FILIAL = '"+xFilial("BEA")+ "' "
	cSQL += " AND BEA_NRTROL = '"+cTranOri+"' "
	cSQL += " AND BEA_OPESOL = '"+IIF(cTpTran=="00700" .Or. l404Triang,cOpeSol,PlsIntPad())+"' "
	cSQL += " AND D_E_L_E_T_ <> '*' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BEANRTROL",.F.,.T.)


	BEANRTROL->(DbGotop())
	If !BEANRTROL->( Eof() )

		nRecno := BEANRTROL->R_E_C_N_O_ //Guarda primeiro Recno

		While !BEANRTROL->( Eof() )
			If BEANRTROL->BEA_LIBERA == "0"
				nRecno := BEANRTROL->R_E_C_N_O_
				Exit
			EndIf
			BEANRTROL->(DbSkip())
		EndDo

		BEANRTROL->( dbClosearea() )

		BEA->( DbGoto(nRecno))

		cOpeMov := BEA->BEA_OPEMOV
		cAnoAut := BEA->BEA_ANOAUT
		cMesAut := BEA->BEA_MESAUT
		cNumAut := BEA->BEA_NUMAUT
		cTipGui := BEA->BEA_TIPGUI
		cCodLdp := BEA->BEA_CODLDP
		cCodPeg := BEA->BEA_CODPEG
		cNumGui := BEA->BEA_NUMGUI

		//Verifica se a resposta da auditoria e revisao e para a evolucao de  GIH

		If cTipGui == GetNewPar("MV_PLSTPGI","03")

			BE4->(DbSetOrder(1)) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
			If BE4->( MsSeek(xFilial("BE4")+cOpeMov+cCodLdp+cCodPeg+cNumGui) )

				//Se esta autorizado retira da auditoria 									

				If BQV->( MsSeek( xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

					//Evolucao																
					While 	!BQV->(Eof()) .And. BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
						//Monta array de verificacao de resposta x solicitacao - Evolucao			
						If Alltrim(BQV->BQV_NRTROL) == Alltrim(cTranArq)
							//aVerArq adiciona todos os itens da solicitacao
							AaDd(aVerArq,{BQV->BQV_CODPRO,BQV->BQV_DESPRO,Iif(!Empty(BQV->BQV_SEQPTU),BQV->BQV_SEQPTU,"99")})
							//Implementa procedimentos em auditoria
							If BQV->BQV_COMUNI == "1" .And. BQV->BQV_AUDITO == "1"
								AaDd(aMatBQV,{BQV->(BQV_CODOPE+BQV->BQV_ANOINT+BQV->BQV_MESINT+BQV->BQV_NUMINT+BQV_SEQUEN) } )
							EndIf
						EndIf

						BQV->(DbSkip())
					EndDo

				EndIf

				//Monta array de verificacao de resposta x solicitacao - Internacao		

				If len(aVerArq) == 0

					BEJ->( DbSetOrder(1) ) //BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN
					If BEJ->( MsSeek( xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

						cChaveBEJ :=  BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)

						While xFilial("BEJ")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == cChaveBEJ .And. !BEJ->(Eof())

							If BEJ->(FieldPos("BEJ_NRTROL")) > 0 .And. Alltrim(BEJ->BEJ_NRTROL) == Alltrim(cTranArq)
								AaDd(aVerArq,{BEJ->BEJ_CODPRO,BEJ->BEJ_DESPRO,Iif(!Empty(BEJ->BEJ_SEQPTU),BEJ->BEJ_SEQPTU,"99")})
							EndIf

							BEJ->(DbSkip())
						EndDo

					EndIf

				EndIf

				//Verifica se o arquivo de resposta esta condizente com o solicitado		

				For nI := 1 To Len(aVerArq)

					If aVerArq[nI][3] <> "99"
						nPos := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(aVerArq[nI][1]) .And. x[8] == Alltrim(aVerArq[nI][3]) } )
					Else		
						If Alltrim(aVerArq[nI][1]) $ Alltrim(cDesGenPtu)
							nPos := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(aVerArq[nI][1]) .And. Upper(x[5]) == Upper(Alltrim(aVerArq[nI][2]))} )
						Else
							nPos := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(aVerArq[nI][1])})
						EndIf
					EndIf

					//Se nao encontrar no arquivo, algum item da solicitacao aborta tudo  	

					If nPos == 0 .and. !lDecurso
						cRet := STR0486+ Alltrim(aVerArq[nI][1])+STR0487+cTranArq+STR0488 //"FALHA ARQUIVO - Despesa "###" da transacao "###" nao foi encontrada ou sua descricao esta diferente do solicitado."
						lExit := .T.
						Exit
					EndIf
				Next
			EndIf

			//Verifica se ha complemento para Sadt                                    

		ElseIf GetNewPar("MV_PLEVSAD","0") == "1"

			BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
			If BEA->( MsSeek(xFilial("BEA")+cOpeMov+cAnoAut+cMesAut+cNumAut) )

				//Se esta autorizado retira da auditoria 									
				BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT
				If BQV->( MsSeek( xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

					//Evolucao																
					While 	!BQV->(Eof()) .And. BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
						
						//Monta array de verificacao de resposta x solicitacao - Complemento SADT	
						If Alltrim(BQV->BQV_NRTROL) == Alltrim(cTranArq)
							//aVerArq adiciona todos os itens da solicitacao
							AaDd(aVerArq,{BQV->BQV_CODPRO,BQV->BQV_DESPRO,Iif(!Empty(BQV->BQV_SEQPTU),BQV->BQV_SEQPTU,"99")})
							//Implementa procedimentos em auditoria
							If BQV->BQV_COMUNI == "1" .And. BQV->BQV_AUDITO == "1"
								AaDd(aMatBQV,{BQV->(BQV_CODOPE+BQV->BQV_ANOINT+BQV->BQV_MESINT+BQV->BQV_NUMINT+BQV_SEQUEN) } )
							Endif
						EndIf

						BQV->(DbSkip())
					EndDo
					lEvoluSadt := .T.
				EndIf

				//Monta array de verificacao de resposta x solicitacao - Consulta/SADT    

				If len(aVerArq) == 0

					BE2->( DbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
					If BE2->( MsSeek( xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

						cChaveBE2 := BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)

						While xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChaveBE2 .And. !BE2->(Eof())

							If BE2->(FieldPos("BE2_NRTROL")) > 0 .And. Alltrim(BE2->BE2_NRTROL) == Alltrim(cTranArq)
								AaDd(aVerArq,{BE2->BE2_CODPRO,BE2->BE2_DESPRO,Iif(!Empty(BE2->BE2_SEQPTU),BE2->BE2_SEQPTU,"99")})      
							EndIf

							BE2->(DbSkip())
						EndDo

					EndIf
				EndIf

				//Verifica se o arquivo de resposta esta condizente com o solicitado		

				For nI := 1 To Len(aVerArq)

					If aVerArq[nI][3] <> "99"  
						nPos := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(aVerArq[nI][1]) .And. x[8] == Alltrim(aVerArq[nI][3]) } )
					Else
						If Alltrim(aVerArq[nI][1]) $ Alltrim(cDesGenPtu)      
							nPos := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(aVerArq[nI][1]) .And. Upper(x[5]) == Upper(Alltrim(aVerArq[nI][2]))} )
						Else
							nPos := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(aVerArq[nI][1])})
						EndIf
					EndIf

					//Se nao encontrar no arquivo, algum item da solicitacao aborta tudo  	
					If nPos == 0 .and. !lDecurso
						cRet := STR0486+ Alltrim(aVerArq[nI][1])+STR0487+cTranArq+STR0488//"FALHA ARQUIVO - Despesa "###" da transacao "###" nao foi encontrada ou sua descricao esta diferente do solicitado."
						lExit := .T.
						Exit
					EndIf

				Next
			EndIf
		EndIf

		//Nao achou eventos, aborta tudo
		If Len(aVerArq) == 0
			cRet  := cTpTran + STR0651 //" - N„o processado, n„o foram encontrados eventos para a transaÁ„o informada."
			lExit := .T.
		EndIf	        

		//Resposta da Sadt e GIH
		If Len(aMatBQV) == 0 .And. !lExit .And. !lCompl

			//Se esta autorizado retira da auditoria BE2 e Criticas do BEG

			BEG->( DbSetOrder(1) ) //BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
			BE2->( DbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
			B4A->(dbSetOrder(4))   //B4A_FILIAL + B4A_GUIREF
			B4C->(dbSetOrder(3))   //B4C_FILIAL + B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT + B4C_CODPAD + B4C_CODPRO

			lAutUmB4C := .F.
			lNegUmB4C := .F.

			If BE2->( MsSeek( xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

				While !BE2->(Eof()) .And. BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

					nSequen := BE2->BE2_SEQUEN

					If ! Empty(BE2->BE2_SEQPTU)
						nPos    := aScan(aIte,{|x| Alltrim(x[1]) == AllTrim(BE2->BE2_CODPRO) .And. x[8] == Alltrim(BE2->BE2_SEQPTU) } )
					Else
						If AllTrim(BE2->BE2_CODPRO) $ Alltrim(cDesGenPtu)

							nPos    := aScan(aIte,{|x| Alltrim(x[1]) == AllTrim(BE2->BE2_CODPRO) .And. Upper(x[5]) == Upper(Alltrim(BE2->BE2_DESPRO))} )
						Else
							nPos 	:= aScan(aIte,{|x| Alltrim(x[1]) == AllTrim(BE2->BE2_CODPRO) } )
						EndIf
					EndIf  

					nQtdAtu := 0

					If nPos > 0

						//Negado,Pendente autorizacao empresa ou Auditoria
						If aIte[nPos,2] == "1" .Or. aIte[nPos,2] == "3" .Or. aIte[nPos,2] == "4"

							lNegUm 	:= .T.
							cStatus	:= "0" //Nao Autorizado

							//Se nao autorizado atualiza as criticas

							If BEG->( MsSeek( xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) ) )

								While !BEG->(Eof()) .And. BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN)

									nQtdAtu++

									If nQtdAtu <= Len(aIte[nPos,4])

										BEG->( RecLock("BEG",.F.) )
										BEG->BEG_CODGLO := aIte[nPos,4,nQtdAtu,1]
										BEG->BEG_DESGLO := aIte[nPos,4,nQtdAtu,2]
										If aIte[nPos,4,nQtdAtu,3] == "4"
											lAudito := .T.
										EndIf
										If BEG->(FieldPos("BEG_CRIEDI"))>0 .And. len(aIte[nPos]) > 6 
											BEG->BEG_CRIEDI := aIte[nPos,7]
										EndIf
										If BEG->(FieldPos("BEG_CODEDI"))>0 .And. len(aIte[nPos,4,nQtdAtu]) >3
											BEG->BEG_CODEDI := aIte[nPos,4,nQtdAtu,4]	
										EndIf
										BEG->( MsUnLock() )
									Else
										BEG->( RecLock("BEG",.F.) )
										BEG->(DbDelete())
										BEG->( MsUnLock() )
									EndIf
									BEG->( DbSkip() )

									If BEG->(Eof()) .And. nQtdAtu < Len(aIte[nPos,4])
										nQtdAtu++
										For nY := nQtdAtu To Len(aIte[nPos,4])
											BEG->( RecLock("BEG",.T.) )
											BEG->BEG_FILIAL := BE2->BE2_FILIAL
											BEG->BEG_OPEMOV := BE2->BE2_OPEMOV
											BEG->BEG_ANOAUT := BE2->BE2_ANOAUT
											BEG->BEG_MESAUT := BE2->BE2_MESAUT
											BEG->BEG_NUMAUT := BE2->BE2_NUMAUT
											BEG->BEG_SEQUEN := nSequen
											BEG->BEG_CODGLO := aIte[nPos,4,nY,1]
											BEG->BEG_DESGLO := aIte[nPos,4,nY,2]
											If Len (aIte[nPos,4,nY]) >2 .And. aIte[nPos,4,nY,3] == "4"
												lAudito := .T.
											EndIf
											If BEG->(FieldPos("BEG_CRIEDI"))>0 
												BEG->BEG_CRIEDI := aIte[nPos,7]
											EndIf
											If BEG->(FieldPos("BEG_CODEDI"))>0 .And. Len(aIte[nPos,4,nQtdAtu]) > 3
												BEG->BEG_CODEDI := aIte[nPos,4,nQtdAtu,4]	
											EndIf
											BEG->( MsUnLock() )
										Next
									EndIf
								EndDo
							Else
								For nY := 1 To Len(aIte[nPos,4])
									BEG->( RecLock("BEG",.T.) )
									BEG->BEG_FILIAL := BE2->BE2_FILIAL
									BEG->BEG_OPEMOV := BE2->BE2_OPEMOV
									BEG->BEG_ANOAUT := BE2->BE2_ANOAUT
									BEG->BEG_MESAUT := BE2->BE2_MESAUT
									BEG->BEG_NUMAUT := BE2->BE2_NUMAUT
									BEG->BEG_SEQUEN := nSequen
									BEG->BEG_CODGLO := aIte[nPos,4,nY,1]
									BEG->BEG_DESGLO := aIte[nPos,4,nY,2]
									If aIte[nPos,4,nY,3] == "4"
										lAudito := .T.
									EndIf
									BEG->( MsUnLock() )
								Next
							EndIf

							//Autorizado
						ElseIf aIte[nPos,2] == "2"

							lAutUm 	:= .T.
							cStatus := "1" //Autorizado

							//Se autorizado limpa as criticas										    

							If BEG->( MsSeek( xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) ) )

								While !BEG->(Eof()) .And. BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN)

									BEG->( RecLock("BEG",.F.) )
									BEG->(DbDelete())
									BEG->( MsUnLock() )

									BEG->( DbSkip() )
								EndDo
							EndIf

						EndIf

						//Gravacao do ITEN
						BE2->( RecLock("BE2",.F.) )

						BE2->BE2_STATUS := cStatus

						//Vai para auditoria pq a resposta da revisao informa isso
						If lAudito
							BE2->BE2_AUDITO := "1"
						Else
							BE2->BE2_AUDITO := "0"
						EndIf

						//Se resposta de Auditoria atualiza o NRAOPE
						If !Empty(cTranDes) .And. cTpTran $ "00404-00360-00700-00804" .And. BE2->(FieldPos("BE2_NRAOPE")) > 0
							BE2->BE2_NRAOPE := Strzero(Val(cTranDes),10)
						EndIf

						//Atualiza quantidade liberada
						If aIte[nPos,2] == "2" .And. aIte[nPos,3] <> BE2->BE2_QTDPRO

							BE2->BE2_SALDO := aIte[nPos,3]
							BE2->BE2_QTDPRO	:= aIte[nPos,3]

							BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO

							If BD6->(DbSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+BE2->(BE2_SEQUEN+BE2_CODPAD+BE2_CODPRO)))

								BD6->( RecLock("BD6",.F.) )
								BD6->BD6_QTDPRO := aIte[nPos,3]
								BD6->BD6_STATUS := cStatus
								BD6->( MsUnLock() )

								//Desmarca bloqueio de pagamento no BD7								    

								BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
								If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

									cBD6Key := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

									While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cBD6Key .And. !BD7->(Eof())

										BD7->( RecLock("BD7",.F.) )
										PLBLOPC("BD7", .f.)
										BD7->( MsUnLock() )

										BD7->(DbSkip())
									EndDo
								EndIf
								lRetMudFas := .T.
							EndIf
						Else
							BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
							If BD6->(DbSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+BE2->(BE2_SEQUEN+BE2_CODPAD+BE2_CODPRO)))

								BD6->( RecLock("BD6",.F.) )
								BD6->BD6_STATUS := cStatus

								If cStatus == '1' //se autorizou e ta bloqueado a copart eu desbloqueio

									PLBLOPC("BD6", .f., nil, nil, .t., .t., .f.)

								Endif
								BD6->( MsUnLock() )

								//Desmarca bloqueio de pagamento no BD7								    

								BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
								If aIte[nPos,2] == "2" .And. BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

									cBD6Key := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

									While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cBD6Key .And. !BD7->(Eof())

										BD7->( RecLock("BD7",.F.) )

										PLBLOPC("BD7", .f.)

										BD7->( MsUnLock() )

										BD7->(DbSkip())
									EndDo
								EndIf
							EndIf
						EndIf

						BE2->( MsUnLock() )

						//tratamento para anexos
						if B4A->( msSeek( xFilial("B4A") + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

							while !B4A->( eof() ) .and. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("B4A")+B4A->B4A_GUIREF

								if B4C->( msSeek( xFilial("B4C") + B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) + BE2->(BE2_CODPAD+BE2_CODPRO) ) )

									B4C->( RecLock("B4C",.F.) )

									B4C->B4C_AUDITO := BE2->BE2_AUDITO

									If BE2->BE2_QTDPRO == 0
										B4C->B4C_SALDO  := BE2->BE2_SALDO
										B4C->B4C_QTDPRO := BE2->BE2_QTDPRO
									EndIf

									B4C->B4C_STATUS := BE2->BE2_STATUS

									B4C->( MsUnLock() )

									//Negado,Pendente autorizacao empresa ou Auditoria
									If aIte[nPos,2] == "1" .or. aIte[nPos,2] == "3" .or. aIte[nPos,2] == "4"

										nQtdAtu		:= 0
										lNegUmB4C	:= .T.

										//Se nao autorizado atualiza as criticas
										If BEG->( msSeek( xFilial("BEG")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) ) )

											While !BEG->(Eof()) .and. BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN)

												nQtdAtu++

												If nQtdAtu <= Len(aIte[nPos,4])

													BEG->( RecLock("BEG",.F.) )
													BEG->BEG_CODGLO := aIte[nPos,4,nQtdAtu,1]
													BEG->BEG_DESGLO := aIte[nPos,4,nQtdAtu,2]

													If aIte[nPos,4,nQtdAtu,3] == "4"
														lAuditoB4A := .T.
													EndIf

													If BEG->(FieldPos("BEG_CRIEDI"))>0
														BEG->BEG_CRIEDI := aIte[nPos,7]
													EndIf

													If BEG->(FieldPos("BEG_CODEDI"))>0
														BEG->BEG_CODEDI := aIte[nPos,4,nQtdAtu,4]	
													EndIf

													BEG->( MsUnLock() )
												Else
													BEG->( RecLock("BEG",.F.) )
													BEG->(DbDelete())
													BEG->( MsUnLock() )
												EndIf

												BEG->( DbSkip() )

												If BEG->(Eof()) .And. nQtdAtu < Len(aIte[nPos,4])

													nQtdAtu++

													For nY := nQtdAtu To Len(aIte[nPos,4])

														BEG->( RecLock("BEG",.T.) )
														BEG->BEG_FILIAL := B4C->B4C_FILIAL
														BEG->BEG_OPEMOV := B4C->B4C_OPEMOV
														BEG->BEG_ANOAUT := B4C->B4C_ANOAUT
														BEG->BEG_MESAUT := B4C->B4C_MESAUT
														BEG->BEG_NUMAUT := B4C->B4C_NUMAUT
														BEG->BEG_SEQUEN := nSequen
														BEG->BEG_CODGLO := aIte[nPos,4,nY,1]
														BEG->BEG_DESGLO := aIte[nPos,4,nY,2]

														If aIte[nPos,4,nY,3] == "4"
															lAuditoB4A := .T.
														EndIf

														If BEG->(FieldPos("BEG_CRIEDI"))>0 
															BEG->BEG_CRIEDI := aIte[nPos,7]
														EndIf

														If BEG->(FieldPos("BEG_CODEDI"))>0 
															BEG->BEG_CODEDI := aIte[nPos,4,nQtdAtu,4]	
														EndIf
														BEG->( MsUnLock() )
													Next
												EndIf
											EndDo
										Else
											For nY := 1 To Len(aIte[nPos,4])
												BEG->( RecLock("BEG",.T.) )
												BEG->BEG_FILIAL := B4C->B4C_FILIAL
												BEG->BEG_OPEMOV := B4C->B4C_OPEMOV
												BEG->BEG_ANOAUT := B4C->B4C_ANOAUT
												BEG->BEG_MESAUT := B4C->B4C_MESAUT
												BEG->BEG_NUMAUT := B4C->B4C_NUMAUT
												BEG->BEG_SEQUEN := nSequen
												BEG->BEG_CODGLO := aIte[nPos,4,nY,1]
												BEG->BEG_DESGLO := aIte[nPos,4,nY,2]

												If aIte[nPos,4,nY,3] == "4"
													lAuditoB4A := .T.
												EndIf

												BEG->( MsUnLock() )
											Next
										EndIf

										//Autorizado
									elseIf aIte[nPos,2] == "2"

										lAutUmB4C	:= .t.

										//Se autorizado limpa as criticas
										If BEG->( msSeek( xFilial("BEG") + B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) ) )

											while !BEG->(eof()) .And. BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN)

												BEG->( RecLock("BEG",.F.) )
												BEG->(DbDelete())
												BEG->( MsUnLock() )

												BEG->( DbSkip() )
											endDo

										endIf

									endIf

									//cabecalho
									B4A->( RecLock("B4A",.F.) )

									if lAuditoB4A
										B4A->B4A_AUDITO := '1'
									else
										B4A->B4A_AUDITO := '0'
									endIf	

									//Status da B4A - 1=Autorizada;2=Autorizada Parcialmente;3=Nao Autorizada
									If lAutUmB4C .And. lNegUmB4C //Autorizada Parcialmente 
										cStatusB4A := "2"
									ElseIf lAutUmB4C .And. !lNegUmB4C //Autorizada
										cStatusB4A := "1"
									Else
										cStatusB4A := "3"
									EndIf

									B4A->B4A_STATUS := cStatusB4A
									B4A->B4A_AUDITO := Iif(lAuditoB4A,'1','0')

									B4A->( MsUnLock() )
									//Tratamento para guias de Radioterapia (nao tem eventos), utilizara como base a Guia Principal
								elseIf B4A->B4A_TIPANE == "1" 

									If lAutUm //Pelo menos um item autorizado
										cStatusB4A := "1"
									Else
										cStatusB4A := "3"
									EndIf

									B4A->( RecLock("B4A",.F.) )	
									B4A->B4A_STATUS := cStatusB4A
									B4A->( MsUnLock() )	
								endIf

								B4A->(dbSkip())
							endDo
						endIf		

					elseIf !lDecurso
						cRet := STR0319+" -> " + AllTrim(BE2->BE2_CODPRO) //"PROCEDIMENTO NAO ENCONTRADO NA MATRIZ"
					EndIf

					BE2->( DbSkip() )
				EndDo

				//Verifica a situacao														

				Do Case
					Case lAutUm .And. lNegUm
					cStatus := "2" //Autorizacao Parcial
					cSituac := Iif(BEA->BEA_LIBERA == "1" .And. BEA->BEA_TIPGUI <> "03","3","1")
					cStatusB00 := "2" //2=Autorizada Parcialmente

					Case lAutUm .And. !lNegUm
					cStatus := "1" //Autorizada
					cSituac := Iif(BEA->BEA_LIBERA == "1" .And. !BEA->BEA_TIPGUI $ "03/05","3","1")
					cStatusB00 := "1" //1=Autorizada 	

					Case (!lAutUm .And. lNegUm) .Or. (!lAutUm .And. !lNegUm)
					cStatus := "3" //Nao Autorizada
					cSituac := "3"
					cStatusB00 := "3" //3=Nao Autorizada
				EndCase

				//Atualiza status do protocolo da RN 395 
				If lRn395 .And. !Empty(cStatusB00)
					B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI
					If B00->(DbSeek(xFilial("B00")+Alltrim(BEA->BEA_PROATE)))  
						B00->(RecLock("B00",.F.))
						B00->B00_STATE := cStatusB00
						B00->(MsUnlock())
					EndIf
				EndIf

				//Se esta autorizado retira da auditoria BEA 							    
				BEA->( RecLock("BEA",.F.) )

				//Vai para auditoria pq a resposta da revisao informa isso			  	

				If lAudito
					BEA->BEA_AUDITO := "1"
				Else
					BEA->BEA_AUDITO := "0"
				EndIf

				If lMsgLivPTU8
					B6M->(DbSetOrder(2))
					If B6M->(DbSeek(xFilial("B6M")+Alltrim(cTranArq)))
						If !Empty(cResRev)
							B6M->(RecLock("B6M",.F.))
								B6M->B6M_MSGLIV := B6M->B6M_MSGLIV + "[ TransaÁ„o " + cTranDes + " ] " + Chr(13) + Chr(10) + cResRev + Chr(13) + Chr(10)	
								If (Empty(B6M->B6M_NRAOPE) .Or. Val(B6M->B6M_NRAOPE) == 0) .And. cTpTran $ "00404-00360-00700"
									B6M->B6M_NRAOPE := Strzero(Val(cTranDes),10)
								EndIf
							B6M->(MsUnLock())
						EndIf
						lGrvPTU8 := .T.
					EndIf
				EndIf

				//Resposta da revisao														
				If !lGrvPTU8 
					ConcatMsg("BEA","BEA_MSG05","BEA_MSG07",cResRev,cTranArq)
				EndIf
				
				//Coloca a senha de autorizacao

				If cStatus <> "3"

					If lPl90L1 
						cSenhaAut := ExecBlock("PLS090L1",.F.,.F.,{BEA->BEA_ORIGEM,.F.,BEA->BEA_DATPRO})
					Else
						cSenhaAut := PLSSenAut(BEA->BEA_DATPRO)
					Endif

					BEA->BEA_SENHA := cSenhaAut
					if empty(cTranDes)
						cTranDes := cSenhaAut
					endIf	
				EndIf

				//Se for resposta da auditoria e tiver um autorizado conclui

				If cTpTran $ "00404-00360-00700"

					BEA->BEA_TRACON := "1"

					If Empty(BEA->BEA_NRAOPE) .Or. Val(BEA->BEA_NRAOPE) == 0
						BEA->BEA_NRAOPE := Strzero(Val(cTranDes),10)
					EndIf

					If cStatus $ "1-2"

						If !Empty(cDatValSen)
							BEA->BEA_VALSEN := Stod(cDatValSen)

							BD5->(DbSetOrder(1))//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
							If BD5->(DbSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
								BD5->( RecLock("BD5",.F.) )
								BD5->BD5_VALSEN := Stod(cDatValSen)
								BD5->( MsUnLock() )
							EndIf

						EndIf

					EndIf

				EndIf
				BEA->( MsUnLock() )

				If BEA->BEA_LIBERA=="1" .And. BEA->BEA_AUDITO=="0" .And. !Empty(cTpTran)     //Caso seja uma liberacao que passou pela auditoria... nao devo fechar a liberaÁ„o
					lLibAud:=.T.
				EndIf

				//Atualiza o status da guia Sadt e Internacao
				PLSSTAGUI(cOpeMov,cAnoAut,cMesAut,cNumAut,cSituac,NIL,NIL,.T.,,,,,,Iif(cStatus=="1",.T.,.F.),cTranDes,cTranOri,cStatus,,,,,,lLibAud)

				//Verifica se e internacao

				If cTipGui == GetNewPar("MV_PLSTPGI","03")

					BE4->(DbSetOrder(1)) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
					If BE4->( MsSeek(xFilial("BE4")+cOpeMov+cCodLdp+cCodPeg+cNumGui) )

						//Se esta autorizado retira da auditoria BE2 e Criticas do BEG			

						BEL->( DbSetOrder(1) ) //BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN + BEL_CODGLO
						BEJ->( DbSetOrder(1) ) //BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN
						If BEJ->( MsSeek( xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

							While !BEJ->(Eof()) .And. BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
								nSequen := BEJ->BEJ_SEQUEN

								If !Empty(BEJ->BEJ_SEQPTU)
									nPos    := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(BEJ->BEJ_CODPRO) .And. x[8] == Alltrim(BEJ->BEJ_SEQPTU) } )
								Else
									If AllTrim(BEJ->BEJ_CODPRO) $ Alltrim(cDesGenPtu)

										nPos 	:= aScan(aIte,{|x| Alltrim(x[1]) == AllTrim(BEJ->BEJ_CODPRO) .And. Upper(Alltrim(x[5])) == Upper(Alltrim(BEJ->BEJ_DESPRO))} )
									Else
										nPos 	:= aScan(aIte,{|x| Alltrim(x[1]) == AllTrim(BEJ->BEJ_CODPRO) } )
									EndIf
								EndIf   

								nQtdAtu := 0

								If nPos > 0

									//Negado,Pendente autorizacao empresa ou Auditoria						

									If aIte[nPos,2] == "1" .Or. aIte[nPos,2] == "3" .Or. aIte[nPos,2] == "4"

										lNegUm 	:= .T.
										cStatus := "0" //Nao Autorizado

										//Se nao autorizado atualiza as criticas								    

										If BEL->( MsSeek( xFilial("BEL")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ) )
											While !BEL->(Eof()) .And. BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN) == BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN)

												nQtdAtu++

												If nQtdAtu <= Len(aIte[nPos,4])
													BEL->( RecLock("BEL",.F.) )
													BEL->BEL_CODGLO := aIte[nPos,4,nQtdAtu,1]
													BEL->BEL_DESGLO := aIte[nPos,4,nQtdAtu,2]
													If aIte[nPos,4,nQtdAtu,3] == "4"
														lAudito := .T.
													EndIf
													If BEL->(FieldPos("BEL_CRIEDI"))>0 
														BEL->BEL_CRIEDI := aIte[nPos,7]
													EndIf
													If BEL->(FieldPos("BEL_CODEDI"))>0 
														BEL->BEL_CODEDI := aIte[nPos,4,nQtdAtu,4]	
													EndIf
													BEL->( MsUnLock() )
												Else
													BEL->( RecLock("BEL",.F.) )
													BEL->(DbDelete())
													BEL->( MsUnLock() )
												EndIf
												BEL->( DbSkip() )

												If BEL->(Eof()) .And. nQtdAtu < Len(aIte[nPos,4])
													nQtdAtu++
													For nY := nQtdAtu To Len(aIte[nPos,4])
														BEL->( RecLock("BEL",.T.) )
														BEL->BEL_FILIAL := BEJ->BEJ_FILIAL
														BEL->BEL_CODOPE := BEJ->BEJ_CODOPE
														BEL->BEL_ANOINT := BEJ->BEJ_ANOINT
														BEL->BEL_MESINT := BEJ->BEJ_MESINT
														BEL->BEL_NUMINT := BEJ->BEJ_NUMINT
														BEL->BEL_SEQUEN := nSequen
														BEL->BEL_CODGLO := aIte[nPos,4,nY,1]
														BEL->BEL_DESGLO := aIte[nPos,4,nY,2]
														If aIte[nPos,4,nY,3] == "4"
															lAudito := .T.
														EndIf

														If BEL->( FieldPos("BEL_SEQCRI") ) > 0
															BEL->BEL_SEQCRI := StrZero(nY, Len(BEL->BEL_SEQCRI))
														Endif
														If BEL->(FieldPos("BEL_CRIEDI"))>0 
															BEL->BEL_CRIEDI := aIte[nPos,7]
														EndIf
														If BEL->(FieldPos("BEL_CODEDI"))>0 
															BEL->BEL_CODEDI := aIte[nPos,4,nQtdAtu,4]	
														EndIf

														BEL->( MsUnLock() )
													Next
												EndIf
											EndDo
										Else
											For nY := 1 To Len(aIte[nPos,4])
												BEL->( RecLock("BEL",.T.) )
												BEL->BEL_FILIAL := BEJ->BEJ_FILIAL
												BEL->BEL_CODOPE := BEJ->BEJ_CODOPE
												BEL->BEL_ANOINT := BEJ->BEJ_ANOINT
												BEL->BEL_MESINT := BEJ->BEJ_MESINT
												BEL->BEL_NUMINT := BEJ->BEJ_NUMINT
												BEL->BEL_SEQUEN := nSequen
												BEL->BEL_CODGLO := aIte[nPos,4,nY,1]
												BEL->BEL_DESGLO := aIte[nPos,4,nY,2]
												If aIte[nPos,4,nY,3] == "4"
													lAudito := .T.
												EndIf

												If BEL->( FieldPos("BEL_SEQCRI") ) > 0
													BEL->BEL_SEQCRI := StrZero(nY, Len(BEL->BEL_SEQCRI))
												Endif
												BEL->( MsUnLock() )
											Next
										EndIf

										//Autorizado																

									ElseIf aIte[nPos,2] == "2"

										lAutUm 	:= .T.
										cStatus := "1" //Autorizado

										//Se autorizado limpa as criticas										    

										If BEL->( MsSeek( xFilial("BEL")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ) )

											While !BEL->(Eof()) .And. BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN) == BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN)

												BEL->( RecLock("BEL",.F.) )
												BEL->(DbDelete())
												BEL->( MsUnLock() )

												BEL->( DbSkip() )
											EndDo

										EndIf
									EndIf

									//Gravacao do ITEN														

									BEJ->( RecLock("BEJ",.F.) )
									BEJ->BEJ_STATUS := 	cStatus

									//Vai para auditoria pq a resposta da revisao informa isso				

									If lAudito
										BEJ->BEJ_AUDITO := "1"
									Else
										BEJ->BEJ_AUDITO := "0"
									EndIf

									If !Empty(cTranDes) .And. cTpTran $ "00404-00360-00700-00804" .And. BEJ->(FieldPos("BEJ_NRAOPE")) > 0
										BEJ->BEJ_NRAOPE := Strzero(Val(cTranDes),10)
									EndIf

									//Se Autorizado marca campos para mudar de fase sem criticas		       
									If aIte[nPos,2] == "2"

										If aIte[nPos,3] <> BEJ->BEJ_QTDPRO
											BEJ->BEJ_QTDPRO := aIte[nPos,3]
										EndIf

										BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
										If BD6->(DbSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+BEJ->(BEJ_SEQUEN+BEJ_CODPAD+BEJ_CODPRO)))

											BD6->( RecLock("BD6",.F.) )
											BD6->BD6_AUDITA := "1"
											BD6->BD6_STATUS := "1"

											PLBLOPC("BD6", .f., nil, nil, .t., .t., .f.)

											//Altera para a quantidade liberada pela outra Operadora				    

											If aIte[nPos,3] <> BEJ->BEJ_QTDPRO
												BD6->BD6_QTDPRO := aIte[nPos,3]
											EndIf

											BD6->( MsUnLock() )

											//Desmarca bloqueio de pagamento no BD7								    

											BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
											If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

												cBD6Key := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

												While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cBD6Key .And. !BD7->(Eof())

													BD7->( RecLock("BD7",.F.) )

													PLBLOPC("BD7", .f.)

													BD7->( MsUnLock() )

													BD7->(DbSkip())
												EndDo

											EndIf
										EndIf


									ElseIf aIte[nPos,2] == "1"

										BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
										If BD6->(DbSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+BEJ->(BEJ_SEQUEN+BEJ_CODPAD+BEJ_CODPRO)))

											//Deleta BD7														          

											BD7->( DbSetOrder(1) )
											If BD7->( MsSeek( xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )

												While ! BD7->( Eof() ) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)


													//Bloqueia BD7															  

													PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])

													BD7->(RecLock("BD7",.F.))
													PLBLOPC("BD7", .t., __aCdCri107[1], PLSBCTDESC())
													BD7->(MsUnLock())

													BD7->(DbSkip())
												Enddo
											Endif

											//Bloqueia BD6															      

											If BD6->(Found())

												BD6->(RecLock("BD6",.F.))

												PLBLOPC("BD6", .t., __aCdCri107[1], PLSBCTDESC(), .t., .t., .t.)

												BD6->(MsUnLock())
											Endif
										Endif
									Endif
									BEJ->( MsUnLock() )

								elseIf !lDecurso
									cRet := STR0319+" -> " + AllTrim(BEJ->BEJ_CODPRO) //"PROCEDIMENTO NAO ENCONTRADO NA MATRIZ"
								EndIf

								BEJ->( DbSkip() )
							EndDo

							//Se esta autorizado retira da auditoria BE4 							    

							BE4->( RecLock("BE4",.F.) )

							//Vai para auditoria pq a resposta da revisao informa isso			  	

							If lAudito
								BE4->BE4_AUDITO := "1"
							Else
								BE4->BE4_AUDITO := "0"
							EndIf

							//Resposta da revisao														
							If !lGrvPTU8
								ConcatMsg("BE4","BE4_MSG05","BE4_MSG07",cResRev,cTranArq)
							Endif

							If !Empty (cDatValSen)
								BE4->BE4_DATVAL := Stod(cDatValSen)
							EndIf

							//Coloca a senha de autorizacao

							If !Empty(cSenhaAut)
								BE4->BE4_SENHA := cSenhaAut
								if empty(cTranDes)
									cTranDes := cSenhaAut
								endIf	
							EndIf

							//Se for resposta da auditoria e tiver um autorizado conclui

							If cTpTran $ "00404-00360-00700"

								BE4->BE4_TRACON := "1"

								If cStatus $ "1-2" .And. !Empty(cDatValSen)
									BE4->BE4_DATVAL := Stod(cDatValSen)
								EndIf

							EndIf

							If Empty(BE4->BE4_NRAOPE) .Or. Val(BE4->BE4_NRAOPE) == 0
								BE4->BE4_NRAOPE := Strzero(Val(cTranDes),10)
							EndIf

							BE4->( MsUnLock() )
						EndIf
					EndIf
				EndIf
			Else
				cRet := STR0320+" -> " + cTranOri//"TRANSACAO NAO ENCONTRADA NO ITEM"
			EndIf

			//Evolucao de GIH															
		ElseIf Len(aMatBQV) > 0 .And. !lExit

			If lMsgLivPTU8
				B6M->(DbSetOrder(2))
				If B6M->(DbSeek(xFilial("B6M")+Alltrim(cTranArq)))
					If !Empty(cResRev)
						B6M->(RecLock("B6M",.F.))
							B6M->B6M_MSGLIV := B6M->B6M_MSGLIV + "[ TransaÁ„o " + cTranDes + " ] " + Chr(13) + Chr(10) + cResRev + Chr(13) + Chr(10)	
							If (Empty(B6M->B6M_NRAOPE) .Or. Val(B6M->B6M_NRAOPE) == 0) .And. cTpTran $ "00404-00360-00700-00804"
								B6M->B6M_NRAOPE := Strzero(Val(cTranDes),10)
							EndIf
						B6M->(MsUnLock())
					EndIf
					lGrvPTU8 := .T.
				EndIf
			EndIf

			If !lGrvPTU8
				//Atualiza as msg de revisao												
				BEA->( RecLock("BEA",.F.) )
				
				ConcatMsg("BEA","BEA_MSG05","BEA_MSG07",cResRev,cTranArq)
								
				BEA->( MsUnLock() )
			EndIf

			//Atualiza as msg de revisao												
			If !lEvoluSadt
				BE4->( RecLock("BE4",.F.) )
				
				If !lGrvPTU8
					ConcatMsg("BE4","BE4_MSG05","BE4_MSG07",cResRev,cTranArq)
				Endif

				If !Empty (cDatValSen)
					BE4->BE4_DATVAL := Stod(cDatValSen)
				EndIf

				BE4->( MsUnLock() )
			EndIf

			//Se esta autorizado retira da auditoria BQV e Criticas do BQZ			

			BQZ->( DbSetOrder(1) ) //BQZ_FILIAL + BQZ_CODOPE + BQZ_ANOINT + BQZ_MESINT + BQZ_NUMINT + BQZ_SEQUEN + BQZ_CODGLO
			BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN

			For nI := 1 To Len(aMatBQV)

				//Posiciona no procedimento												

				BQV->( MsSeek( xFilial("BQV")+aMatBQV[nI,1] ) )

				//Sequencia e nPos														

				nSequen := BQV->BQV_SEQUEN

				If !Empty(BQV->BQV_SEQPTU)
					nPos    := aScan(aIte,{|x| Alltrim(x[1]) == Alltrim(BQV->BQV_CODPRO) .And. x[8] == Alltrim(BQV->BQV_SEQPTU) .And. Alltrim(BQV->BQV_NRTROL) == cTranArq} )   
				Else	
					If AllTrim(BQV->BQV_CODPRO) $ Alltrim(cDesGenPtu)      
						nPos 	:= aScan(aIte,{|x| Alltrim(x[1]) == AllTrim(BQV->BQV_CODPRO) .And. Upper(x[5]) == Upper(Alltrim(BQV->BQV_DESPRO)) .And. Alltrim(BQV->BQV_NRTROL) == cTranArq} )
					Else
						nPos 	:= aScan(aIte,{|x| Alltrim(x[1]) == AllTrim(BQV->BQV_CODPRO) .And. Alltrim(BQV->BQV_NRTROL) == cTranArq} )
					EndIf
				EndIf      

				nQtdAtu := 0

				If nPos > 0

					//Negado,Pendente autorizacao empresa ou Auditoria					 	

					If aIte[nPos,2] == "1" .Or. aIte[nPos,2] == "3" .Or. aIte[nPos,2] == "4"
						lNegUm 	:= .T.
						cStatus	:= "0" //Nao Autorizado

						//Se nao autorizado atualiza as criticas								    

						If BQZ->( MsSeek( xFilial("BQZ")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN) ) )
							While !BQZ->(Eof()) .And. BQZ->(BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN) == BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN)

								nQtdAtu++

								If nQtdAtu <= Len(aIte[nPos,4])
									BQZ->( RecLock("BQZ",.F.) )
									BQZ->BQZ_CODGLO := aIte[nPos,4,nQtdAtu,1]
									BQZ->BQZ_DESGLO := aIte[nPos,4,nQtdAtu,2]
									If aIte[nPos,4,nQtdAtu,3] == "4"
										lAudito := .T.
									EndIf
									If BQZ->(FieldPos("BQZ_CRIEDI"))>0 
										BQZ->BQZ_CRIEDI := aIte[nPos,7]
									EndIf
									If BQZ->(FieldPos("BQZ_CODEDI"))>0 
										BQZ->BQZ_CODEDI := aIte[nPos,4,nQtdAtu,4]	
									EndIf
									BQZ->( MsUnLock() )
								Else
									BQZ->( RecLock("BQZ",.F.) )
									BQZ->(DbDelete())
									BQZ->( MsUnLock() )
								EndIf
								BQZ->( DbSkip() )

								If BQZ->(Eof()) .And. nQtdAtu < Len(aIte[nPos,4])
									nQtdAtu++
									For nY := nQtdAtu To Len(aIte[nPos,4])
										BQZ->( RecLock("BQZ",.T.) )
										BQZ->BQZ_FILIAL := BQV->BQV_FILIAL
										BQZ->BQZ_CODOPE := BQV->BQV_CODOPE
										BQZ->BQZ_ANOINT := BQV->BQV_ANOINT
										BQZ->BQZ_MESINT := BQV->BQV_MESINT
										BQZ->BQZ_NUMINT := BQV->BQV_NUMINT
										BQZ->BQZ_SEQUEN := nSequen
										BQZ->BQZ_CODGLO := aIte[nPos,4,nY,1]
										BQZ->BQZ_DESGLO := aIte[nPos,4,nY,2]
										If aIte[nPos,4,nY,3] == "4"
											lAudito := .T.
										EndIf
										If BQZ->(FieldPos("BQZ_CRIEDI"))>0 
											BQZ->BQZ_CRIEDI := aIte[nPos,7]
										EndIf

										If BQZ->(FieldPos("BQZ_CODEDI"))>0 
											BQZ->BQZ_CODEDI := aIte[nPos,4,nQtdAtu,4]	
										EndIf   

										If BQZ->( FieldPos("BQZ_SEQCRI") ) > 0
											BQZ->BQZ_SEQCRI := StrZero(nY, Len(BQZ->BQZ_SEQCRI))
										Endif
										BQZ->( MsUnLock() )
									Next
								EndIf
							EndDo
						Else
							For nY := 1 To Len(aIte[nPos,4])
								BQZ->( RecLock("BQZ",.T.) )
								BQZ->BQZ_FILIAL := BQV->BQV_FILIAL
								BQZ->BQZ_CODOPE := BQV->BQV_CODOPE
								BQZ->BQZ_ANOINT := BQV->BQV_ANOINT
								BQZ->BQZ_MESINT := BQV->BQV_MESINT
								BQZ->BQZ_NUMINT := BQV->BQV_NUMINT
								BQZ->BQZ_SEQUEN := nSequen
								BQZ->BQZ_CODGLO := aIte[nPos,4,nY,1]
								BQZ->BQZ_DESGLO := aIte[nPos,4,nY,2]

								If BQZ->( FieldPos("BQZ_SEQCRI") ) > 0
									BQZ->BQZ_SEQCRI := StrZero(nY, Len(BQZ->BQZ_SEQCRI))
								Endif

								If aIte[nPos,4,nY,3] == "4"
									lAudito := .T.
								EndIf
								BQZ->( MsUnLock() )
							Next
						EndIf

						//Autorizado
					ElseIf aIte[nPos,2] == "2"
						lAutUm 	:= .T.
						cStatus	:= "1" //Autorizado

						//Se autorizado limpa as criticas										    

						If BQZ->( MsSeek( xFilial("BQZ")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN) ) )

							While !BQZ->(Eof()) .And. BQZ->(BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN) == BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN)
								BQZ->( RecLock("BQZ",.F.) )
								BQZ->(DbDelete())
								BQZ->( MsUnLock() )
								BQZ->( DbSkip() )
							EndDo

						EndIf
					EndIf

					//Marca numero do protocolo para processo RN 395
					If lRn395 .And. BQV->( FieldPos("BQV_PROATE") )  > 0
						cProAte := Alltrim(BQV->BQV_PROATE)
					EndIf

					//Gravacao dos Itens da Evolucao

					BQV->( RecLock("BQV",.F.) )

					BQV->BQV_STATUS := cStatus

					//Vai para auditoria pq a resposta da revisao informa isso
					If lAudito
						BQV->BQV_AUDITO := "1"
					Else
						BQV->BQV_AUDITO := "0"
					EndIf
					BQV->BQV_OLNAUD := "1"

					//Coloca a senha de autorizacao											

					If cStatus == "1"

						If lPl90L1     
							cSenhaAut := ExecBlock("PLS090L1",.F.,.F.,{"3",.F.,BE4->BE4_DATPRO})
						Else
							cSenhaAut := PLSSenAut(BE4->BE4_DATPRO)
						Endif
			
						BQV->BQV_SENHA	:= cSenhaAut

						if empty(cTranDes)
							cTranDes := cSenhaAut
						endIf	

						If !Empty(cTranDes) .And. cTpTran $ "00404-00360-00700-00804" .And. BQV->(FieldPos("BQV_NRAOPE")) > 0
							BQV->BQV_NRAOPE := Strzero(Val(cTranDes),10)
						EndIf

						//Atualiza campos na BD6 e BQV                           					

						If lEvoluSadt

							BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
							If BD6->(DbSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+BQV->(BQV_SEQUEN+BQV_CODPAD+BQV_CODPRO)))

								BD6->( RecLock("BD6",.F.) )

								//Se Autorizado marca campos para mudar de fase sem criticas				
								If aIte[nPos,2] == "2"

									BD6->BD6_AUDITA := "1"
									BD6->BD6_STATUS := "1"

									PLBLOPC("BD6", .f., nil, nil, .t., .t., .f.)

									//Desmarca bloqueio de pagamento no BD7								    

									BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
									If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

										cBD6Key := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

										While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cBD6Key .And. !BD7->(Eof())

											BD7->( RecLock("BD7",.F.) )

											PLBLOPC("BD7", .f.)

											BD7->( MsUnLock() )

											BD7->(DbSkip())
										EndDo
									EndIf
								EndIf

								//Altera para a quantidade liberada pela outra Operadora				    

								If BQV->BQV_QTDPRO <> aIte[nPos,3]
									BD6->BD6_QTDPRO := aIte[nPos,3]
									BQV->BQV_QTDPRO := aIte[nPos,3]
									lRetMudFas := .T.
								EndIf

								BD6->( MsUnLock() )
							EndIf

						Else
							BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
							If BD6->(DbSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+BQV->(BQV_SEQUEN+BQV_CODPAD+BQV_CODPRO)))

								BD6->( RecLock("BD6",.F.) )

								//Se Autorizado marca campos para mudar de fase sem criticas
								If aIte[nPos,2] == "2"
									BD6->BD6_AUDITA := "1"
									BD6->BD6_STATUS := "1"

									PLBLOPC("BD6", .f., nil, nil, .t., .t., .f.)

									//Desmarca bloqueio de pagamento no BD7

									BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
									If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
										cBD6Key := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
										While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cBD6Key .And. !BD7->(Eof())

											BD7->( RecLock("BD7",.F.) )

											PLBLOPC("BD7", .f.)

											BD7->( MsUnLock() )

											BD7->(DbSkip())
										EndDo
									EndIf
								EndIf

								//Altera para a quantidade liberada pela outra Operadora

								If BQV->BQV_QTDPRO <> aIte[nPos,3]
									BD6->BD6_QTDPRO := aIte[nPos,3]
									BQV->BQV_QTDPRO := aIte[nPos,3]
									lRetMudFas := .T.
								EndIf
								BD6->( MsUnLock() )
							EndIf
						EndIf

						//Se negado, bloqueia pagamento/cobranca                   				

					ElseIf cStatus == "0" .And. aIte[nPos,2] == "1"
						BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
						If BD6->(DbSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+BQV->(BQV_SEQUEN+BQV_CODPAD+BQV_CODPRO)))

							BD6->(RecLock("BD6",.F.))

							PLBLOPC("BD6", .t., __aCdCri107[1], PLSBCTDESC(), .t., .t., .t.)

							BD6->(MsUnLock())

							//Desmarca bloqueio de pagamento no BD7								    

							BD7->(DbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
							If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

								cBD6Key := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

								While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cBD6Key .And. !BD7->(Eof())

									BD7->( RecLock("BD7",.F.) )
									PLBLOPC("BD7", .t., __aCdCri107[1], PLSBCTDESC())
									BD7->( MsUnLock() )

									BD7->(DbSkip())
								EndDo

							EndIf
						EndIf
					EndIf

					//Se for resposta da auditoria e tiver um autorizado conclui				
					If cTpTran $ "00404-00360-00700"
						BQV->BQV_TRACON := "1"
					EndIf
					BQV->( MsUnLock() )

					//Atualiza os anexos    
					B4A->(dbSetOrder(4))   //B4A_FILIAL + B4A_GUIREF  
					B4C->(dbSetOrder(3))   //B4C_FILIAL + B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT + B4C_CODPAD + B4C_CODPRO
					If B4A->( msSeek( xFilial("B4A") + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

						While !B4A->( eof() ) .and. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("B4A")+B4A->B4A_GUIREF

							If B4C->( msSeek( xFilial("B4C") + B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) + BQV->(BQV_CODPAD+BQV_CODPRO) ) ) .And. Alltrim(B4C->B4C_NRTROL) == Alltrim(cTraBQVAne)

								B4C->( RecLock("B4C",.F.) )
								B4C->B4C_AUDITO := BQV->BQV_AUDITO
								B4C->B4C_STATUS := BQV->BQV_STATUS
								B4C->( MsUnLock() )

								//Negado,Pendente autorizacao empresa ou Auditoria
								If aIte[nPos,2] == "1" .Or. aIte[nPos,2] == "3" .Or. aIte[nPos,2] == "4"

									lNegUmB4C	:= .T.
									cStatusB4A	:= "3" //Nao Autorizado   

									If aIte[nPos,2] == "4" .Or. aIte[nPos,2] == "3"
										lAuditoB4A := .T.
									EndIf     

									BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
									//Deleto criticas existentes
									If BEG->(MsSeek(xFilial("BEG")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) ))
										While B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) == BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) .And. !BEG->(Eof())
											BEG->(RecLock("BEG",.F.))
											BEG->(DbDelete())
											BEG->(MsUnLock())

											BEG->(DbSkip())
										EndDo
									EndIf

									For nY := 1 to len(aIte[nPos][4])
										//Gero as novas criticas 
										BEG->( RecLock("BEG",.T.) )
										BEG->BEG_FILIAL := xFilial("BEG")
										BEG->BEG_OPEMOV := B4C->B4C_OPEMOV
										BEG->BEG_ANOAUT := B4C->B4C_ANOAUT
										BEG->BEG_MESAUT := B4C->B4C_MESAUT
										BEG->BEG_NUMAUT := B4C->B4C_NUMAUT
										BEG->BEG_SEQUEN := B4C->B4C_SEQUEN
										BEG->BEG_CODGLO := aIte[nPos][4][nY][1]
										BEG->BEG_DESGLO := aIte[nPos][4][nY][2] 
										BEG->BEG_SEQCRI := StrZero(nY, Len(BEG->BEG_SEQCRI))
										If BEG->(FieldPos("BEG_CRIEDI")) > 0 
											BEG->BEG_CRIEDI := aIte[nPos][4][nY][2] 
										EndIf
										If BEG->(FieldPos("BEG_CODEDI")) > 0 
											BEG->BEG_CODEDI := aIte[nPos][4][nY][4] 
										EndIf
										BEG->( MsUnLock() )

									Next 

									//Autorizado
								ElseIf aIte[nPos,2] == "2"
									lAutUmB4C	:= .T.
									cStatusB4A	:= "1" //Autorizado  

									BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
									//Deleto criticas existentes
									If BEG->(MsSeek(xFilial("BEG")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) ))
										While B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) == BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) .And. !BEG->(Eof())
											BEG->(RecLock("BEG",.F.))
											BEG->(DbDelete())
											BEG->(MsUnLock())

											BEG->(DbSkip())
										EndDo
									EndIf
								EndIf

								//Ajusta o Cabecalho
								B4A->( RecLock("B4A",.F.) )
								B4A->B4A_AUDITO := IIf(lAuditoB4A,'1','0')
								B4A->B4A_STATUS := IIf(lAutUmB4C .And. lNegUmB4C,'2',cStatusB4A)
								B4A->( MsUnLock() )

							ElseIf B4A->B4A_TIPANE == "1" .And. Alltrim(B4A->B4A_NRTROL) == Alltrim(cTraBQVAne)

								//Negado,Pendente autorizacao empresa ou Auditoria
								If aIte[nPos,2] == "1" .Or. aIte[nPos,2] == "3" .Or. aIte[nPos,2] == "4"
									lNegUmB4C	:= .T.
									If aIte[nPos,2] == "4" .Or. aIte[nPos,2] == "3"
										lAuditoB4A := .T.
									EndIf     
									//Autorizado
								ElseIf aIte[nPos,2] == "2"
									lAutUmB4C	:= .T.
								EndIf

								//Ajusta o Cabecalho
								B4A->( RecLock("B4A",.F.) )
								B4A->B4A_AUDITO := IIf(lAuditoB4A,'1','0')
								B4A->B4A_STATUS := IIf(lAutUmB4C,'1','3')
								B4A->( MsUnLock() )

							EndIf

							B4A->(dbSkip())
						EndDo
					EndIf

				elseIf !lDecurso
					cRet := STR0319+" -> " + AllTrim(BQV->BQV_CODPRO)//"PROCEDIMENTO NAO ENCONTRADO NA MATRIZ"
				EndIf
			Next

			Do Case
				Case lAutUm .And. lNegUm
				cStatusB00 := "2" //2=Autorizada Parcialmente

				Case lAutUm .And. !lNegUm
				cStatusB00 := "1" //1=Autorizada 	

				Case (!lAutUm .And. lNegUm) .Or. (!lAutUm .And. !lNegUm)
				cStatusB00 := "3" //3=Nao Autorizada	 
			EndCase

			//Atualiza status do protocolo da RN 395 
			If lRn395 .And. !Empty(cStatusB00) .And. !Empty(cProAte)
				B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI
				If B00->(DbSeek(xFilial("B00")+cProAte))  
					B00->(RecLock("B00",.F.))
					B00->B00_STATE := cStatusB00
					B00->(MsUnlock())
				EndIf
			EndIf

		EndIf
	Else
		cRet := STR0314+" -> " + cTranOri //"TRANSACAO NAO ENCONTRADA NO CABECALHO
	EndIf
Else
	cRet := STR0315//"INDICE (E) NO BEA NAO EXISTE"
EndIf

//Retorno a posicao inicial												

BEA->(DbGoTo(nRecBEA))
BE2->(DbGoTo(nRecBE2))
BEG->(DbGoTo(nRecBEG))
B4A->(DbGoTo(nRecB4A))
B4C->(DbGoTo(nRecB4C))

//Retorno a posicao inicial												

If cTipGui == GetNewPar("MV_PLSTPGI","03")
	BE4->(DbGoTo(nRecBE4))
	BEJ->(DbGoTo(nRecBEJ))
	BEL->(DbGoTo(nRecBEL))
	BQV->(DbGoTo(nRecBQV))
	BQZ->(DbGoTo(nRecBQZ))

ElseIf lRetMudFas	//so retorna e muda a fase se nao for internacao
	//retorna e Muda fase
	PLSXMUDFAS("BD5","1","",cTipGui,dDataBase,.F.,"1")
	PLSXMUDFAS("BD5","1","",cTipGui,dDataBase,.F.,"3")
EndIf

RestArea(aArea)

//Fim da Funcao
Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSACOMC
Atualiza a guia solicitada por outra operadora	  

@author  PLS TEAM
@version P11
@since   16.08.06
/*/
//-------------------------------------------------------------------
Function PLSACOMC(cTranOri,cTranDes,cResRev,aIte,cTpTran,cTpResp,lInternacao,lEvolu,cOpeSol,cDescCanc,cTranPrest)
	LOCAL cAliasCab
	LOCAL cAliasIte
	LOCAL cAliasCri
	LOCAL cChaveCab
	LOCAL cChaveIte
	LOCAL cChaveCri
	LOCAL nRec
	LOCAL lEvolucao		:= .F.
	LOCAL lIntern   	:= .F.
	LOCAL lPrimeiro 	:= .T.
	LOCAL cCodCri 		:= "000"
LOCAL cDesCri 		:= STR0318//"CRITICA DESABILITADA"
LOCAL nRecBEA 		:= BEA->( Recno() )
LOCAL nRecBE4 		:= BE4->( Recno() )
LOCAL cRet	  		:= ""
LOCAL cSQL          := ""
LOCAL cTransacao    := ""
LOCAL cSenha        := ""
LOCAL cGuiOri       := ""
LOCAL lRetCompl     := .F.
LOCAL aRet          := {}
LOCAL cResRev1		:= SubStr(cResRev,1,254)
LOCAL cResRev2		:= SubStr(cResRev,255)
//Variaveis PE
LOCAL lP90INB53  := ExistBlock("P90INB53")
LOCAL lGerB53    := .F.
LOCAL o790C      := nil
LOCAL cRegInt    := '0'
LOCAL cKeyCriAux := ''
LOCAL aHeaderITE := {}
LOCAL aColsITE   := {}
LOCAL aTrbIte    := {}
LOCAL aCabCri    := {}
LOCAL aDadCri    := {}
LOCAL aTrbCri    := {}
Local lPTUOn80   := GetNewPar("MV_PTUVEON","80") >= "80" .And. PLSALIASEXI("B6M")

DEFAULT lInternacao := .F.
DEFAULT lEvolu		:= .F.
DEFAULT cOpeSol     := ''
DEFAULT cTranPrest	:= ""

//Verifica a possibilidade de ser um complemento
If cTpTran $ ("00311-00302")
	cSQL := " SELECT BSA_CONTEU FROM "+RetSqlName("BSA")
	cSQL += " WHERE BSA_FILIAL = '"+xFilial("BSA")+"' "
	cSQL += " AND BSA_NUMSEQ = '"+cTranOri+"' "
	cSQL += " AND BSA_IDENT = 'CAB' "
	cSQL += " AND BSA_VARIAV = 'NR_TRANS_R' "
	cSQL += " AND BSA_OPESOL = '" + cOpeSol +"' "
	cSQL += " AND D_E_L_E_T_ <> '*' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

	TmpEvol->(DbGotop())
	If !TmpEvol->( Eof() )
		cTransacao := Alltrim(TmpEvol->BSA_CONTEU)
	Else
		cTransacao := cTranOri
	EndIf
	TmpEvol->( dbClosearea() )

Else
	cTransacao := cTranOri
EndIf

cTransacao := PadL(cTransacao,10,"0")
//Verifica															    

SIX->( DbSetOrder(1) )
If SIX->( MsSeek("BEAM") )
	BEA->( DbSetOrder(22) )//BEA_FILIAL + BEA_NRTROL + BEA_OPESOL
	If BEA->( MsSeek(xFilial("BEA")+cTransacao+Space(TamSX3("BEA_NRTROL")[1]-len(cTransacao))+cOpeSol) )

		If BEA->BEA_TIPO == "3" .And. !lInternacao

			BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE

			If !BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
				cRet := STR0317+" ["+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+"]"  //"NAO FOI POSSIVEL LOCALIZAR A GUIA DE INTERNACAO COM A CHAVE"
			Endif

			cAliasCab := "BE4"
			cAliasIte := "BEJ"
			cAliasCri := "BEL"
			cChaveCab := &( cAliasCab+"->("+cAliasCab+"_CODOPE+"+cAliasCab+"_ANOINT+"+cAliasCab+"_MESINT+"+cAliasCab+"_NUMINT)" )
			cChaveIte := cAliasIte+"->("+cAliasIte+"_CODOPE+"+cAliasIte+"_ANOINT+"+cAliasIte+"_MESINT+"+cAliasIte+"_NUMINT)"
			cChaveCri := cAliasCri+"->("+cAliasCri+"_CODOPE+"+cAliasCri+"_ANOINT+"+cAliasCri+"_MESINT+"+cAliasCri+"_NUMINT+"+cAliasCri+"_SEQUEN)"
			cKeyCriAux:= cAliasCri+"->("+cAliasCri+"_CODOPE+"+cAliasCri+"_ANOINT+"+cAliasCri+"_MESINT+"+cAliasCri+"_NUMINT)"
			lIntern   := .T.
			cRegInt   := BE4->BE4_REGINT
			//Verifica	se e uma evolucao										       

			If BQV->( FieldPos("BQV_OLNAUD") )  > 0
				BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
				If BQV->( MsSeek(xFilial("BQV")+cChaveCab ) )
					lEvolucao := .T.
					lIntern   := .F.
					cAliasIte := "BQV"
					cAliasCri := "BQZ"
					cChaveIte := cAliasIte+"->("+cAliasIte+"_CODOPE+"+cAliasIte+"_ANOINT+"+cAliasIte+"_MESINT+"+cAliasIte+"_NUMINT)"
					cChaveCri := cAliasCri+"->("+cAliasCri+"_CODOPE+"+cAliasCri+"_ANOINT+"+cAliasCri+"_MESINT+"+cAliasCri+"_NUMINT+"+cAliasCri+"_SEQUEN)"
					cKeyCriAux:= cAliasCri+"->("+cAliasCri+"_CODOPE+"+cAliasCri+"_ANOINT+"+cAliasCri+"_MESINT+"+cAliasCri+"_NUMINT)"
				EndIf
			Else
				cRet := STR0316//"E NECESSARIO A CRIACAO DO CAMPO BQV_OLNAUD PARA PROCESSAMENTO DE EVOLUCAO"
			EndIf
		Else
			cAliasCab := "BEA"
			cAliasIte := "BE2"
			cAliasCri := "BEG"
			cChaveCab := &( cAliasCab+"->("+cAliasCab+"_OPEMOV+"+cAliasCab+"_ANOAUT+"+cAliasCab+"_MESAUT+"+cAliasCab+"_NUMAUT)" )
			cChaveIte := cAliasIte+"->("+cAliasIte+"_OPEMOV+"+cAliasIte+"_ANOAUT+"+cAliasIte+"_MESAUT+"+cAliasIte+"_NUMAUT)"
			cChaveCri := cAliasCri+"->("+cAliasCri+"_OPEMOV+"+cAliasCri+"_ANOAUT+"+cAliasCri+"_MESAUT+"+cAliasCri+"_NUMAUT+"+cAliasCri+"_SEQUEN)"
			cKeyCriAux:= cAliasCri+"->("+cAliasCri+"_OPEMOV+"+cAliasCri+"_ANOAUT+"+cAliasCri+"_MESAUT+"+cAliasCri+"_NUMAUT)"

			//Verifica	se e uma evolucao										       

			If BQV->( FieldPos("BQV_OLNAUD") )  > 0

				BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
				If BQV->( MsSeek(xFilial("BQV")+cChaveCab ) )
					lEvolucao := .T.
					lIntern   := .F.
					cAliasIte := "BQV"
					cAliasCri := "BQZ"
					cChaveIte := cAliasIte+"->("+cAliasIte+"_CODOPE+"+cAliasIte+"_ANOINT+"+cAliasIte+"_MESINT+"+cAliasIte+"_NUMINT)"
					cChaveCri := cAliasCri+"->("+cAliasCri+"_CODOPE+"+cAliasCri+"_ANOINT+"+cAliasCri+"_MESINT+"+cAliasCri+"_NUMINT+"+cAliasCri+"_SEQUEN)"
					cKeyCriAux:= cAliasCri+"->("+cAliasCri+"_CODOPE+"+cAliasCri+"_ANOINT+"+cAliasCri+"_MESINT+"+cAliasCri+"_NUMINT)"
				EndIf

			Else
				cRet := STR0316//"E NECESSARIO A CRIACAO DO CAMPO BQV_OLNAUD PARA PROCESSAMENTO DE EVOLUCAO"
			EndIf

		Endif
	Else
		cRet := STR0314+" -> " + cTranOri//"TRANSACAO NAO ENCONTRADA NO CABECALHO
	Endif
Else
	cRet := STR0315//"INDICE (E) NO BEA NAO EXISTE"
EndIf

//Verifica se tem complementos pendentes, realizada esta verificacao caso	a  
//operadora envie o cancelamento da guia principal com complementos pendentes

If Empty(cRet) .And. cTpTran == "00311"
	cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("BQV")
	cSql += " WHERE BQV_CODOPE = '"+Iif(cAliasCab=="BEA",BEA->BEA_OPEMOV,BE4->BE4_CODOPE)+"' "
	cSql += "   AND BQV_MESINT = '"+Iif(cAliasCab=="BEA",BEA->BEA_MESAUT,BE4->BE4_MESINT)+"' "
	cSql += "   AND BQV_ANOINT = '"+Iif(cAliasCab=="BEA",BEA->BEA_ANOAUT,BE4->BE4_ANOINT)+"' "
	cSql += "   AND BQV_NUMINT = '"+Iif(cAliasCab=="BEA",BEA->BEA_NUMAUT,BE4->BE4_NUMINT)+"' "
	cSql += "   AND BQV_CANCEL <> '1' "
	cSql += "   AND D_E_L_E_T_ <> '*' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

	TmpEvol->(DbGotop())
	If !TmpEvol->( Eof() )
		lRetCompl := .T.
		If cTransacao == cTranOri
			cRet := "GUIA PRINCIPAL COM COMPLEMENTOS PENDENTES"
		EndIf
	EndIf
	TmpEvol->( dbClosearea() )

EndIf


//Bloqueia pagamento/cobranca de complementos da transacao enviada
If Empty(cRet) .And. cTpTran == "00311"
	cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("BQV")
	cSql += " WHERE BQV_NRTROL = '"+cTranOri+"' "
	cSql += "   AND BQV_CODOPE = '"+Iif(cAliasCab=="BEA",BEA->BEA_OPEMOV,BE4->BE4_CODOPE)+"' "
	cSql += "   AND BQV_MESINT = '"+Iif(cAliasCab=="BEA",BEA->BEA_MESAUT,BE4->BE4_MESINT)+"' "
	cSql += "   AND BQV_ANOINT = '"+Iif(cAliasCab=="BEA",BEA->BEA_ANOAUT,BE4->BE4_ANOINT)+"' "
	cSql += "   AND BQV_NUMINT = '"+Iif(cAliasCab=="BEA",BEA->BEA_NUMAUT,BE4->BE4_NUMINT)+"' "
	cSql += "   AND D_E_L_E_T_ <> '*' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

	aArea := GetArea()

	DbSelectArea("BD6")
	DbSetOrder(1)//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO

	DbSelectArea("BD7")
	DbSetOrder(1)//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC

	DbSelectArea("BQV")

	TmpEvol->(DbGotop())
	While !TmpEvol->( Eof() )
		cChaveBD6 := ""
		lRetCompl := .T.
		BQV->( DbGoTo(TmpEvol->R_E_C_N_O_) )

		If cAliasCab == "BEA"

			//Bloqueia pagamento na BD6 e BD7 Guia de Sadt                     		

			If BD6->(DbSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+BQV->(BQV_SEQUEN+BQV_CODPAD+BQV_CODPRO)))

				PLSPOSGLO(PLSINTPAD(),__aCdCri107[1]	,__aCdCri107[2])

				BD6->( RecLock("BD6") )
				PLBLOPC("BD6", .t., __aCdCri107[1], PLSBCTDESC(), .t., .f., .t.)
				BD6->( MsUnLock() )

				cChaveBD6 := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

				If BD7->(DbSeek(xFilial("BD7")+cChaveBD6))
					While BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cChaveBD6

						BD7->( RecLock("BD7") )
						PLBLOPC("BD7", .t., __aCdCri107[1], PLSBCTDESC())
						BD7->( MsUnLock() )

						BD7->(DbSkip())
					EndDo
				EndIf
			EndIf

			//Para guias Sadt e necessario retornar e mudar a fase                	

			PLSXMUDFAS("BD5","1","",BEA->BEA_TIPGUI,dDataBase,.F.,"1")
			PLSXMUDFAS("BD5","1","",BEA->BEA_TIPGUI,dDataBase,.F.,"3")
		Else

			//Bloqueia pagamento na BD6 e BD7 Guia de Internacao                		

			If BD6->(DbSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+BQV->(BQV_SEQUEN+BQV_CODPAD+BQV_CODPRO)))
				PLSPOSGLO(PLSINTPAD(),__aCdCri107[1]	,__aCdCri107[2])

				BD6->( RecLock("BD6") )

				PLBLOPC("BD6", .t., __aCdCri107[1], PLSBCTDESC(), .t., .f., .t.)

				BD6->( MsUnLock() )

				cChaveBD6 := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

				If BD7->(DbSeek(xFilial("BD7")+cChaveBD6))
					While BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cChaveBD6

						BD7->( RecLock("BD7") )
						PLBLOPC("BD7", .t., __aCdCri107[1], PLSBCTDESC())
						BD7->( MsUnLock() )

						BD7->(DbSkip())
					EndDo
				EndIf

			EndIf

		EndIf

		//Flag de cancelado na BQV

		BQV->( RecLock("BQV") )
		BQV->BQV_CANCEL := "1"
		BQV->BQV_AUDITO := "0"           
		BQV->BQV_CANEDI := cDescCanc
		BQV->BQV_TRACON := "1"
		BQV->BQV_STATUS := "0"
		BQV->( MsUnLock() )

		TmpEvol->(DbSkip())
	EndDo
	TmpEvol->( dbClosearea() )
	RestArea(aArea)
EndIf
If Empty(cRet) .And. cTpResp == "1" .And. cTpTran == "00311" .And. ALLTRIM(BEA->BEA_NRTROL) <> ALLTRIM(cTranOri)
	cGuiOri := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) 
	B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF

	lRetCompl :=.T.         	
	If B4A->(DbSeek(xFilial("B4A")+cGuiOri))
        	 
		While xFilial("B4A")+cGuiOri == xFilial("B4A")+B4A->B4A_GUIREF .And. !B4A->(Eof())
       	 If ALLTRIM(B4A->B4A_NRTROL) == ALLTRIM(cTranOri)		
       	 	B4A->(RecLock("B4A",.F.))
            	B4A->B4A_CANCEL := "1"
            	B4A->B4A_STATUS := "3"
            	B4A->B4A_AUDITO := "0"	            	
		  		B4A->(MsUnlock())
	  	 	  EndIf            
	   		 B4A->(DbSkip())
   	EndDo
	Else
		cRet:= STR0646 //"MovimentaÁ„o n„o localizada"
	EndIf

EndIf


//Se nao teve erros e complementos pendentes

If Empty(cRet) .And. !lRetCompl

	//Se esta autorizado retira da auditoria  							    

	&(cAliasCab+"->( RecLock('"+cAliasCab+"',.F.) ) ")

	//Atualiza																

	Do Case

		//Confirmacao da Resposta de auditoria											

		Case lEvolu

			//Conclusao da auditoria na evolucao deve desmarcar os itens de auditoria controle oln
			While !&(cAliasIte+"->( Eof() )") .And. xFilial(cAliasCab)+cChaveCab == xFilial(cAliasIte)+&(cChaveIte)
				If &(cAliasIte+"->"+cAliasIte+"_NRTROL") == cTranOri
					&(cAliasIte+"->( RecLock('"+cAliasIte+"',.F.) ) ")
					&(cAliasIte+"->"+cAliasIte+"_OLNAUD") := "0"
					&(cAliasIte+"->"+cAliasIte+"_TRACON") := "1"
					&( cAliasIte+"->( MsUnLock() )" )
				EndIf
				&(cAliasIte+"->( DbSkip() )")
			EndDo

		//Conclusao ou Cancelamento														

		Case cTpTran == "00311" .Or. cTpTran == "00309"

			//Conclui																			

			&(cAliasCab+"->"+cAliasCab+"_TRACON") := "1"

			&(cAliasCab+"->"+cAliasCab+"_CANEDI") := cDescCanc //DS_MOTIVO - Descricao do Motivo do Cancelamento

			//Se for para cancelar													   		

			If cTpResp == "1"

				//Cancela																			

				&(cAliasCab+"->"+cAliasCab+"_CANCEL") := "1"

				//Quando nao foi na inclusao nao muda fase e necessario ajustar o contas		    

				PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,"2",NIL,NIL,.T.,,,,,,,,,"3")
			EndIf

			cSenha := &(cAliasCab+"->"+cAliasCab+"_SENHA")

			//Se for evolucao																	

			If lEvolucao

				//Ajusta evolucao																	|

				While !&(cAliasIte+"->( Eof() )") .And. xFilial(cAliasCab)+cChaveCab == xFilial(cAliasIte)+&(cChaveIte)
					&(cAliasIte+"->( RecLock('"+cAliasIte+"',.F.) ) ")

					//Somente os pendentes															

					If  &(cAliasIte+"->"+cAliasIte+"_TRACON") <> "1"

						//Concluido																		

						&(cAliasIte+"->"+cAliasIte+"_OLNAUD") := "0"
						&(cAliasIte+"->"+cAliasIte+"_TRACON") := "1"

						//Conclusao com cancelamento														

						If cTpResp == "1"
							&(cAliasIte+"->"+cAliasIte+"_CANCEL") := "1"
							&(cAliasIte+"->"+cAliasIte+"_AUDITO") := "0"
						EndIf
					Else
						If cTpTran == "00311" .And. &(cAliasIte+"->(FieldPos('"+cAliasIte+"_NRTROL') )") > 0
							If cTranOri == &(cAliasIte+"->"+cAliasIte+"_NRTROL")
								&(cAliasIte+"->"+cAliasIte+"_CANCEL") := "1"
								&(cAliasIte+"->"+cAliasIte+"_AUDITO") := "0"
							EndIf
						EndIf
					EndIf
					&( cAliasIte+"->( MsUnLock() )" )
					&(cAliasIte+"->( DbSkip() )")
				EndDo
			EndIf

			//Exclusao de anexo na versao 5.0 do PTU Online									

			cGuiOri := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) 
			B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF

			If B4A->(DbSeek(xFilial("B4A")+cGuiOri))

				While xFilial("B4A")+cGuiOri == xFilial("B4A")+B4A->B4A_GUIREF .And. !B4A->(Eof())

					B4A->(RecLock("B4A",.F.))
					B4A->B4A_CANCEL := "1"
					B4A->(MsUnlock())

					B4A->(DbSkip())
				EndDo
			EndIf

		//Revisao																	
		Case cTpTran == "00302"

			//Atualiza cabecalho,itens e criticas										

			If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_MSG04') )") > 0
				&(cAliasCab+"->"+cAliasCab+"_MSG04")  := cResRev1
			EndIf
			If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_MSG06') )") > 0
				&(cAliasCab+"->"+cAliasCab+"_MSG06")  := cResRev2
			EndIf

			//Reposta da revisao														

			If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_MSG05') )") > 0
				&(cAliasCab+"->"+cAliasCab+"_MSG05")  := ""
			EndIf
			If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_MSG07') )") > 0
				&(cAliasCab+"->"+cAliasCab+"_MSG07")  := ""
			EndIf

			//Se nao for evolucao														

			If !lEvolucao
				If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_AUDITO') )") > 0
					&(cAliasCab+"->"+cAliasCab+"_AUDITO") := "1"
				Endif
				If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_STATUS') )") > 0
					&(cAliasCab+"->"+cAliasCab+"_STATUS") := "3"
				Endif
			EndIf

			//Pega criticas																	

			If PLSPOSGLO(PLSINTPAD(),__aCdCri051[1]	,__aCdCri051[2])
				cCodCri := __aCdCri051[1]
				cDesCri := PLSBCTDESC()
			EndIf

			//Atualiza Itens																	

			&( cAliasCri+"->( DbSetOrder(1) )" ) //_FILIAL + _CODOPE + _ANOINT + _MESINT + _NUMINT + _SEQUEN + _CODGLO
			&( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
			&( cAliasIte+"->( MsSeek( '"+xFilial(cAliasIte)+cChaveCab+"' ) )" )
			
			//Ticket 6329946, DSAUATE-3480
			//Criado PE para Vale gerar B53 de atendimentos PTU Online
			//Foi criada essa possibilidade porque o Remote ja estava permitindo a criacao
			if !lEvolu .And. lP90INB53

				aPEB53Cab 	:= (cAliasCab)->(GetArea())
				aPEB53Ite 	:= (cAliasIte)->(GetArea())
				aPEB53Cri 	:= (cAliasCri)->(GetArea())

				//Eventos
				Store Header cAliasIte TO aHeaderITE For .T.
				Store COLS cAliasIte TO aColsITE FROM aHeaderITE VETTRAB aTrbIte While xFilial(cAliasIte)+cChaveCab == xFilial(cAliasIte)+&(cChaveIte)

				//Criticas
				if &( cAliasCri+"->( MsSeek( '"+xFilial(cAliasCri)+cChaveCab+"' ) )" )
					Store Header cAliasCri TO aCabCri For .T.
					Store COLS cAliasCri TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial(cAliasCri)+cChaveCab == xFilial(cAliasCri)+&(cKeyCriAux)
				endIf

				lGerB53 := ExecBlock("P90INB53",.F.,.F., {cAliasCab,(cAliasCab)->(Recno()),aColsITE,aHeaderITE})

				RestArea(aPEB53Cab)
				RestArea(aPEB53Ite)
				RestArea(aPEB53Cri)
			endIf

			//While																			

			While !&(cAliasIte+"->( Eof() )") .And. xFilial(cAliasIte)+&(cChaveIte) == xFilial(cAliasCab)+cChaveCab

				//Se for evolucao retira os procedimento ja tratados								

				If lEvolucao
					If &(cAliasIte+"->"+cAliasIte+"_TRACON") == "1"
						&( cAliasIte+"->( DbSkip() )" )
						Loop
					EndIf

					If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_NRTROL') )") > 0 .And. &(cAliasIte+"->"+cAliasIte+"_NRTROL") <> Alltrim(cTranOri)
						&( cAliasIte+"->( DbSkip() )" )
						Loop
					EndIf
				EndIf

				//Pega a Sequencia																

				nSequen := &( cAliasIte+"->"+cAliasIte+"_SEQUEN" )

				//Atualiza itens															

				&(cAliasIte+"->( RecLock('"+cAliasIte+"',.F.) ) ")
				If TYPE(cAliasIte+"->"+cAliasIte+"_SOLREV") == "C"
					&( cAliasIte+"->"+cAliasIte+"_SOLREV" ) := "1"
				EndIf
				&( cAliasIte+"->"+cAliasIte+"_AUDITO" ) := "1"
				&( cAliasIte+"->"+cAliasIte+"_STATUS" ) := "0"

				//Se for evolucao															

				If lEvolucao
					&(cAliasIte+"->"+cAliasIte+"_OLNAUD") := "1"
					&(cAliasIte+"->"+cAliasIte+"_TRACON") := "0"


					//Nova regra, necessario retornar o codigo da transacao (senha)           

					If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_SENHA') )") > 0
						&(cAliasIte+"->"+cAliasIte+"_SENHA") := PLSSenAut(dDataBase)
						cSenha := &(cAliasIte+"->"+cAliasIte+"_SENHA")
					Endif
				EndIf

				&( cAliasIte+"->( MsUnLock() )" )

				//Proximo																	

				&( cAliasIte+"->( DbSkip() )" )
			EndDo

			//Ticket 6329946, DSAUATE-3480
			//Criado PE para Vale gerar B53 de atendimentos PTU Online
			//Foi criada essa possibilidade porque o Remote ja estava permitindo a criacao
			if lGerB53
				o790C := PLSA790C():New(.T.)
				o790C:SetAuditoria(.T.,lIntern,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],cRegInt,cAliasCri,aColsITE,aHeaderITE,cAliasIte)
				o790C:Destroy()
			endIf

	EndCase
	&( cAliasCab+"->( MsUnLock() )" )

	If lPtuOn80 .and. cTpTran == "00404"

		If Empty(cTranPrest)
			cTranPrest := cTranOri
		EndIf

		B6M->(DbSetOrder(2))
		If B6M->(MsSeek(xFilial("B6M")+Alltrim(cTranPrest)))
			If !Empty(cResRev)
				B6M->(RecLock("B6M",.F.))
				B6M->B6M_MSGLIV := B6M->B6M_MSGLIV + "[ TransaÁ„o " + Alltrim(cTranDes) + " ] " + Chr(13) + Chr(10) + cResRev + Chr(13) + Chr(10)					
				If (Empty(B6M->B6M_NRAOPE) .or. Val(B6M->B6M_NRAOPE) == 0) 
					B6M->B6M_NRAOPE := Strzero(Val(cTranDes),10)
				EndIf				
				B6M->(MsUnLock())
			EndIf
		EndIf
	EndIf		
EndIf

//Retorno a posicao inicial

BEA->( DbGoTo(nRecBEA) )
BE4->( DbGoTo(nRecBE4) )

//Se for internacao deve fazer tb o espelho na guia sadt

If lIntern
	PLSACOMC(cTranOri,cTranDes,cResRev1+cResRev2,aIte,cTpTran,cTpResp,lIntern,,cOpeSol,cDescCanc)
EndIf

aRet := {cRet,cSenha}

//Fim da Funcao
Return(aRet)

/*/{Protheus.doc} PLSAGRVINT
Gravacao do Cabecalho,Item e Criticas da internacao	  

@author  PLS TEAM
@version P11
@since   03.10.06
/*/
Function PLSAGRVINT(nOpc,cOpeInt,cAnoAut,cMesAut,cNumAut,cTipGui,cStatus,lAuditoria,cKey,cTipoRotEsp,aDadBEA,;
	aColsBEJ,aHeaderBEJ,aVetTrab,aDadIntCri,aCabIntCri,aTrbIntCri,lAjusta,aDadBE4,lVeioComu,cCodLDP,;
	cOpeMov,aDadB6M,aItensB6L)

	local nI			:= 0
	local nFor			:= 0
	local nForH			:= 0
	local nPos			:= 0
	local nPos2			:= 0
	local cMat			:= ""
	local cCpoAux		:= ""
	local cChaveBCI		:= ""
	local cNumGuia		:= ""
	local aStrucBE4  	:= BE4->(DbStruct())
	local cCodOpe    	:= PLSINTPAD()
	local aChaveGen  	:= {}
	local aAux       	:= {}
	local aAuxNew    	:= {}
	local aAuxCol 	 	:= {}
	local aColsNew	 	:= {}
	local aCpoChv    	:= { "BE4_CODOPE","BE4_ANOINT","BE4_MESINT","BE4_NUMINT","BE4_ANOAUT","BE4_MESAUT","BE4_NUMAUT",Iif(lVeioComu,Nil,"BE4_DATPRO"),Iif(lVeioComu,Nil,"BE4_HORPRO") }
	local nDatPro	 	:= Ascan(aDadBE4,{ |x| x[1] == "BE4_DATPRO"})
	local nHorPro	 	:= Ascan(aDadBE4,{ |x| x[1] == "BE4_HORPRO"})
	local lDtInternacao := .F.

	DEFAULT cCodLDP 	:= ""
	DEFAULT cOpeMov 	:= ""
	DEFAULT aDadB6M		:= {}
	DEFAULT aItensB6L   := {}

	dbSelectArea('BEJ')
	dbSelectArea('BEL')

	//Para branco pega a intpad												
	If empty(cOpeInt)
		cOpeInt := cCodOpe
	EndIf

	//Alteracao,Inclusao e Exclusao											
	BE4->( RecLock("BE4",nOpc == K_Incluir) )

	If nOpc <> K_Excluir

		//Alteracao e Inclusao BEA X BE4										   
		For nFor := 1 To Len(aDadBEA)

			cCpoAux := "BE4_"+Subs(aDadBEA[nFor,1],5,10)

			If AsCan(aCpoChv,{|x| x == cCpoAux}) == 0 .And. TYPE("BE4->"+cCpoAux) <> "U"
				&( "BE4->"+cCpoAux ) := aDadBEA[nFor,2]
			Endif

		Next

		//Alteracao e Inclusao BE4 X BE4										   
		For nFor := 1 To Len(aDadBE4)

			cCpoAux := aDadBE4[nFor,1]

			If AsCan(aCpoChv,{|x| x == cCpoAux}) == 0 .And. TYPE("BE4->"+cCpoAux) <> "U"
				&( "BE4->"+cCpoAux ) := aDadBE4[nFor,2]
			Endif

		Next

		//Somente inclusao														   
		If nOpc == K_Incluir .Or. nOpc == K_Copiar

			//Se inclusao preencho temporariamente o BE4_CODLDP, BE4_CODPEG e o 	  
			//BE4_NUMERO para evitar erro de chave duplicada na tabela BE4			  

			If nOpc == K_Incluir

				//Retornado pesquisa para o indice 4, pois utilizando o 12, o sistema gerava o BEA/BE4 com o campo XXX_CODPEG divergente
				//Obs: o indice padrao no PLSA090MF (gera o Alias BEA/BE2/BEG) e o indice 4
				BCI->(dbSetOrder(4))//BCI_FILIAL+BCI_OPERDA+BCI_CODRDA+BCI_ANO+BCI_MES+BCI_TIPO+BCI_FASE+BCI_SITUAC+BCI_TIPGUI+BCI_CODLDP+BCI_ARQUIV
				cChaveBCI := BE4->BE4_OPERDA + BE4->BE4_CODRDA + cAnoAut + cMesAut + "2" + BE4->BE4_FASE + BE4->BE4_SITUAC + cTipGui + cCodLDP
				cChaveBCI2 := BE4->BE4_OPERDA + BE4->BE4_CODRDA + cAnoAut + cMesAut + "2" + "1" + BE4->BE4_SITUAC + cTipGui + cCodLDP
				//Cria peg
				if ! BCI->( msSeek(xFilial("BCI") + cChaveBCI) ) .AND. ! BCI->( msSeek(xFilial("BCI") + cChaveBCI2) )
					PLSIPP(cCodOpe,cCodLDP,BE4->BE4_OPERDA,BE4->BE4_CODRDA,cMesAut,cAnoAut,dDataBase,cTipGui,,,BE4->BE4_FASE)
				endIf

				BE4->BE4_CODLDP := BCI->BCI_CODLDP
				BE4->BE4_CODPEG := BCI->BCI_CODPEG
				BE4->BE4_NUMERO := PLSA500NUM("BE4", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)

			EndIf

			cNumGuia := BE4->BE4_NUMERO

			BE4->BE4_FILIAL := xFilial("BE4")
			BE4->BE4_CODOPE := cCodOpe
			BE4->BE4_ANOINT := cAnoAut
			BE4->BE4_MESINT := cMesAut
			BE4->BE4_NUMINT := cNumAut
			BE4->BE4_STATUS := cStatus
			BE4->BE4_AUDITO := If(lAuditoria,"1","0")
			BE4->BE4_TIPGUI := cTipGui
			BE4->BE4_STTISS := PLSANLSTIG(cStatus, lAuditoria )

			//ATENCAO!! SEMPRE QUE FOR GRAVAR UM DADO COM BASE NO ADADBEA DEVE-SE FAZER UM ASCAN ANTES PARA DESCOBRIR A POSICAO
			//POIS AS POSICOES VARIAM DE ACORDO COM O SX3
			If (nPos := Ascan(aDadBEA,{|x| x[1] == "BEA_SENHA"} ) ) > 0 .and. !Empty(aDadBEA[nPos][2])

				If ExistBlock("PL090SNHA")
					BE4->BE4_SENHA := ExecBlock("PL090SNHA",.F.,.F.,{cStatus,dDataBase,aDadBEA})
				Else
					BE4->BE4_SENHA  := aDadBea[nPos,2]
				Endif

			Endif

			//ATENCAO!! PREFERENCIALMENTE NAO SE DEVE USAR VARIAVEIS EM MEMORIA DENTRO DO PLSA090GRV POIS ESTA FUNCAO EH CHAMADA EM DIVERSOS PONTOS
			//DO SISTEMA, PORTAL, ETC.. E O M-> DA ERROADMIN	...
			If (nPos := Ascan(aDadBE4,{|x| x[1] == "BE4_TIPADM"} ) ) > 0

				If AllTrim(aDadBE4[nPos][2]) $ AllTrim(GetNewPar("MV_PLSCDIU","4,5")) .And. GetNewPar("MV_PLSTDIA","1") == "1" .And. nDatPro > 0 .And. nHorPro > 0

					BE4->BE4_DATPRO := aDadBE4[nDatPro][2]
					BE4->BE4_HORPRO := aDadBE4[nHorPro][2]+"00"

					If Empty(aDadBE4[Ascan(aDadBE4,{|x| x[1] == "BE4_SENHA"} )][2])
						BE4->BE4_SENHA  := PLSSenAut(aDadBE4[nDatPro][2])
					Endif

					lDtInternacao := .T.

				Endif

			Endif

			//Marca como liberacao na internacao
			If BE4->( FieldPos('BE4_LIBERA') ) > 0
				BE4->BE4_LIBERA := "1"
			EndIf

			//Somente gravacao														  
			If (nPos := Ascan(aDadBEA,{|x| x[1] == "BEA_ANOINT"} ) ) == 0
				AaDd(aDadBEA,{"BEA_ANOINT",cAnoAut})
			Else
				aDadBEA[nPos,2] := cAnoAut
			Endif
			If (nPos := Ascan(aDadBEA,{|x| x[1] == "BEA_MESINT"} ) ) == 0
				AaDd(aDadBEA,{"BEA_MESINT",cMesAut})
			Else
				aDadBEA[nPos,2] := cMesAut
			Endif
			If (nPos := Ascan(aDadBEA,{|x| x[1] == "BEA_NUMINT"} ) ) == 0
				AaDd(aDadBEA,{"BEA_NUMINT",cNumAut})
			Else
				aDadBEA[nPos,2] := cNumAut
			Endif
			If (nPos := Ascan(aDadBEA,{|x| x[1] == "BEA_TIPGUI"} ) ) == 0
				AaDd(aDadBEA,{"BEA_TIPGUI",cTipGui})
			Else
				aDadBEA[nPos,2] := cTipGui
			Endif
		Endif
	Else
		BE4->( DbDelete() )
	Endif

	BE4->( MsUnLock() )

	If nOpc == K_Incluir .And. Len(aDadB6M) > 0
		PLSPTUGRV(aDadB6M, {cCodOpe, cAnoAut, cMesAut, cNumAut},"B6M")
	EndIf

	If nOpc == K_Incluir .And. Len(aItensB6L) > 0
		PLSPTUGRV(aItensB6L, {cCodOpe, cAnoAut, cMesAut, cNumAut},"B6L")
	EndIf

	//Somente gravacao														
	If nOpc <> K_Excluir

		//Montando strutura generica												
		For nFor := 1 To Len(aStrucBE4)

			cCpoAux := "BEJ_" + subs(aStrucBE4[nFor,1],5,10)

			If (nPos := aScan(aChaveGen,{|x| x[1] == cCpoAux})) == 0 .and. TYPE("BEJ->"+cCpoAux) <> "U"
				aadd(aChaveGen,{cCpoAux,&( "BE4->" + aStrucBE4[nFor,1] ) } )
			EndIf

		Next

		//Adicionando outros itens												
		If (nPos := Ascan(aChaveGen,{|x| x[1] == "BEJ_ANOINT"} ) ) == 0
			AaDd(aChaveGen,{"BEJ_ANOINT",BE4->BE4_ANOINT})
		Else
			aChaveGen[nPos,2] := BE4->BE4_ANOINT
		EndIf

		If (nPos := Ascan(aChaveGen,{|x| x[1] == "BEJ_MESINT"} ) ) == 0
			AaDd(aChaveGen,{"BEJ_MESINT",BE4->BE4_MESINT})
		Else
			aChaveGen[nPos,2] := BE4->BE4_MESINT
		EndIf

		If (nPos := Ascan(aChaveGen,{|x| x[1] == "BEJ_NUMINT"} ) ) == 0
			AaDd(aChaveGen,{"BEJ_NUMINT",BE4->BE4_NUMINT})
		Else
			aChaveGen[nPos,2] := BE4->BE4_NUMINT
		EndIf

		If (nPos := Ascan(aChaveGen,{|x| x[1] == "BEJ_AUDITO"} ) ) == 0
			AaDd(aChaveGen,{"BEJ_AUDITO",""} )
		Else
			aChaveGen[nPos,2] := ""
		Endif
	EndIf

	//Se e para ajustar a matriz												
	If lAjusta

		plChkHECO('BE2','BEJ',@aHeaderBEJ,@aColsBEJ)

		//Exclusao acerta vettrab													
		If nOpc <> K_Incluir .Or. nOpc <> K_Copiar

			aVetTemp := aClone(aVetTrab)
			aVetTrab := {}

			BEJ->( DbSetOrder(1) )//BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN
			nPos := PLRETPOS("BEJ_SEQUEN",aHeaderBEJ,.F.)

			For nFor := 1 To Len(aVetTemp)

				If nPos > 0

					If BEJ->( MsSeek(xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)+aColsBEJ[nFor,nPos]))
						AaDd( aVetTrab,BEJ->(Recno()) )
					Endif

				Endif

			Next

		EndIf

	EndIf

	//Gravacao dos itens da internacao										
	PLUPTCOLS("BEJ",aColsBEJ,aHeaderBEJ,aVetTrab,nOpc,aChaveGen)

	//Se e para ajustar a matriz												
	If lAjusta

		//Prepara  para poder gravar  internacao x sadt					   		
		//Troca o nome e testa se existe										    
		plChkHECO('BEG','BEL',@aCabIntCri,@aDadIntCri)

		//Exclusao acerta vettrab													
		If nOpc <> K_Incluir .Or. nOpc <> K_Copiar

			aVetTemp   := aClone(aTrbIntCri)
			aTrbIntCri := {}

			BEL->( DbSetOrder(1) ) //BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN + BEL_CODGLO
			nPos := PLRETPOS("BEL_SEQUEN",aCabIntCri,.F.)

			For nFor := 1 To Len(aVetTemp)

				If nPos > 0

					If BEL->( MsSeek(xFilial("BEL")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)+aDadIntCri[nFor,nPos]) )
						AaDd( aTrbIntCri,BEL->(Recno()) )
					Endif

				Endif

			Next

		EndIf

		//Retornar o que era antes BEJ X BE2											
		lAjusta := .f.

	EndIf

	//Retirar critica sem descricao											
	PLSAJUMAT(aCabIntCri,aDadIntCri,"BEL_DESGLO")

	//Chave generica															
	aChaveGen := {}
	aadd(aChaveGen,{"BEL_CODOPE",cCodOpe})
	aadd(aChaveGen,{"BEL_ANOINT",cAnoAut})
	aadd(aChaveGen,{"BEL_MESINT",cMesAut})
	aadd(aChaveGen,{"BEL_NUMINT",cNumAut})

	//Gravacao das Criticas													
	If Len(aDadIntCri) > 0
		PLUPTCOLS("BEL",aDadIntCri,aCabIntCri,aTrbIntCri,nOpc,aChaveGen,.T.)
	EndIf

	//Exclui possiveis evolucoes												
	If nOpc == K_Excluir

		//Exclusao das evolucoes de GIH..	                                        
		BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
		BQV->( MsSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

		cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

		//While																	
		While BQV->( !EOF() ) .And. cChave == BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)

			BQV->( RecLock("BQV") )
			BQV->( DbDelete() )
			BQV->( MsUnlock() )

			BQV->( DbSkip() )
		Enddo

		//Exclusao das criticas da evolucao de GIH..	                            
		BQZ->( DbSetOrder(1) )//BQZ_FILIAL + BQZ_CODOPE + BQZ_ANOINT + BQZ_MESINT + BQZ_NUMINT + BQZ_SEQUEN + BQZ_CODGLO
		BQZ->( MsSeek(xFilial("BQZ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

		cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

		//While																	
		While BQZ->(!EOF()) .And. cChave == BQZ->(BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT)

			BQZ->( RecLock("BQZ") )
				BQZ->(DbDelete())
				BQZ->( MsUnlock() )

			BQZ->(DbSkip())
		Enddo

	Endif

	// IntegraÁ„o do Aviso de InternaÁ„o (API)
	If lDtInternacao .And. FindFunction("PLMapIntAviso")
		PLMapIntAviso(BE4->BE4_CODOPE, BE4->BE4_ANOINT, BE4->BE4_MESINT, BE4->BE4_NUMINT)
	EndIf

Return(cNumGuia)

/*/{Protheus.doc} PLSAGRVEVO
Gravacao do Item e Criticas da evolucao  

@author  PLS TEAM
@version P11
@since   10.10.06
/*/
Function PLSAGRVEVO(cTranOri,aCols,aHeader,aDadEvoCri,aCabEvoCri,cDiagn,lVeioComu,cLotGui,lWeb,aDaSenPro,aMatCom,cObsEvo,cOpeSolPTU,aBQVPTUDif,aDadB6M,aItensB6L)
	LOCAL nFor
	LOCAL nY
	LOCAL nI
	LOCAL nForH
	LOCAL nPos
	LOCAL cMat
	LOCAL cCpoAux
	LOCAL cSenhaPls
	LOCAL cSequen
	LOCAL aHeaderBQV
	LOCAL 	nPSeqC 		:= 0
	LOCAL	nPSeqD 		:= 0
	LOCAL nQtdDPro	 := 0
	LOCAL nRecBE4	 := 0
	LOCAL lGerSen	 := .T.
	LOCAL lUmAut     := .F.
	LOCAL lAuditoria := .F.
	LOCAL cCpoExc	 := "BQV_TRACON,BQV_SENHA"
LOCAL aChaveNew	 := {}
LOCAL aColsBQV   := {}
LOCAL dDatInt    := dDataBase
LOCAL cMultSen   := GetNewPar("MV_PLSMULT","0")
LOCAL aChaveGen  := {}
LOCAL aAux       := {}
LOCAL aAuxNew    := {}
LOCAL aAuxCol 	 := {}
LOCAL aColsNew	 := {}
LOCAL aStrucBE4  := BE4->(DbStruct())
LOCAL cAliasIte  := "BQV"
LOCAL cAliasCri  := "BQZ"
LOCAL nOpc		 := K_Incluir
LOCAL cBQVCodPad	:= ""
LOCAL cBQVCodPro	:= ""
LOCAL nBQVQtdPro	:= "0"
LOCAL cBQVHorPro	:= ""
LOCAL cBQVNivAut	:= ""
LOCAL cBQVNivCri	:= ""
LOCAL cBQVChvNiv	:= ""
LOCAL dBQVDatPro	:= ""
LOCAL cChvBE4      	:= ""
LOCAL aDadCriNew	:= {}
LOCAL nPosBQVAux  	:= 0
LOCAL lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70" 

DEFAULT lWeb	 := .F.
DEFAULT cLotGui	 := ""
DEFAULT aDaSenPro:= {}
DEFAULT aMatCom	 := {}
DEFAULT cObsEvo  := {}
DEFAULT cOpeSolPTU := ""
DEFAULT aBQVPTUDif := {}
DEFAULT aDadB6M	   := {}
DEFAULT aItensB6L  := {}

If lPTUOn70
	cCpoExc	 += ",BQV_PROATE,BQV_TOKEDI"
EndIf

//Monta o header BQV														
Store Header cAliasIte TO aHeaderBQV For .T.
If lWeb
	BE4->( DbSetOrder(2) )//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
	If BE4->( MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)) )
		cTranOri:= BE4->BE4_NRTROL 	
	EndIf	
EndIf

//Verifica															    

cTranOri := cTranOri + Space(TamSx3("BEA_NRTROL")[1] - len(cTranOri))

SIX->( DbSetOrder(1) )
If SIX->( MsSeek("BE4A") )
	BE4->( DbSetOrder(10) )//BEA_FILIAL + BEA_NRTROL
	If !Empty(cTranOri) .And. !BE4->( MsSeek(xFilial("BE4")+cTranOri+cOpeSolPTU) )

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0314+" -> " + cTranOri , 0, 0, {})//"TRANSACAO NAO ENCONTRADA NO CABECALHO"	

		Return(.F.)

	Else
		nRecBE4 := BE4->(Recno())
		cChvBE4 := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
		BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT
		If !BQV->( MsSeek( xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )
			BEJ->( DbSetOrder(1) ) //BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN
			BEJ->( MsSeek( xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

			//Pega a ultima sequencia													

			cSequen := PLSA625Cd("BEJ_SEQUEN","BEJ",1,"BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)",xFilial("BEJ")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT))
		Else

			//Pega a ultima sequencia													

			cSequen := PLSA625Cd("BQV_SEQUEN","BQV",1,"BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)",xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT))
		EndIf
	Endif
	dDatInt := If(Empty(BE4->BE4_DATPRO),dDataBase,BE4->BE4_DATPRO )
Else
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0313 , 0, 0, {}) //"INDICE (E) NO BE4 NAO EXISTE"
	Return(.F.)
EndIf

//Verificando campos de igualdade internacao x sadt ITENS			   		
plChkHECO('BE2','BQV',@aHeader,@aCols)

//Campos comuns para o cabecalho											
aChaveGen := {}
If BQV->( FieldPos("BQV_DATPRO") ) > 0
	AaDd(aChaveGen,{"BQV_DATPRO",dDataBase})
Else
	AaDd(aChaveGen,{"BQV_DTENTR",dDataBase})
EndIf

If !HS_EXISDIC({{"C", "BE2_DIAGNO"}},.F.)
	AaDd(aChaveGen,{"BQV_DIAGNO",Iif( Empty(cDiagn),"NAO INFORMADO",cDiagn) } )
EndIf
AaDd(aChaveGen,{"BQV_TIPDIA","1" } )

If BQV->( FieldPos("BQV_OBSER1") ) > 0
	AaDd(aChaveGen,{"BQV_OBSER1",IIF(Empty(cObsEvo),PlsPtuGet("DS_OBSERVA",aDados),cObsEvo) } )
EndIf

If BQV->( FieldPos("BQV_MEMO1") ) > 0
	AaDd(aChaveGen,{"BQV_MEMO1",PlsPtuGet("DS_IND_CLI",aDados) } )
EndIf

dbSelectArea('BQV')
For nFor := 1 To Len(aStrucBE4)

	cCpoAux := "BQV_"+Subs(aStrucBE4[nFor,1],5,10)

	If (nPos := Ascan(aChaveGen,{|x| x[1] == cCpoAux})) == 0 .And. VALTYPE("BQV->"+cCpoAux) <> "U" .And. !cCpoAux $ cCpoExc
		AaDd(aChaveGen,{cCpoAux,&( "BE4->" + aStrucBE4[nFor,1] ) } )
	Endif

Next

//Monta no novo acols da evolucao											
For nFor := 1 To Len(aCols)
	AaDd( aColsBQV,Array( Len(aHeaderBQV)+1) )
Next

//Verificando campos de igualdade internacao x sadt Genericos		   		
For nFor := 1 To Len(aChaveGen)
	nPos := Ascan( aHeaderBQV, {|x| AllTrim( x[2]) == AllTrim(aChaveGen[nFor,1]) } )
	If nPos > 0
		For nY := 1 To Len(aColsBQV)
			aColsBQV[nY,nPos] := aChaveGen[nFor,2]
		Next
	Else
		AaDd(aChaveNew,{aChaveGen[nFor,1],aChaveGen[nFor,2] } )
	EndIf
Next
aChaveGen := aClone(aChaveNew)

//Verificando campos de igualdade internacao x sadt itens			   		
For nFor := 1 To Len(aHeader)
	nPos  := Ascan( aHeaderBQV, {|x| x[2] == aHeader[nFor,2] } )
	If nPos > 0
		For nY := 1 To Len(aCols)
			if Alltrim(aHeaderBQV[nPos,2]) == "BQV_MEMO1"
				aColsBQV[nY,nPos] := PlsPtuGet("DS_IND_CLI",aDados)
			else 
				aColsBQV[nY,nPos] := aCols[nY,nFor]
			endIf
		Next
	EndIf
Next

//Prepara  para poder gravar  internacao x sadt					   		
//Troca o nome e testa se existe										    
plChkHECO('BEG','BQZ',@aCabEvoCri,@aDadEvoCri)

//Adiciona campos que sao especificos somente da BQV
For nFor := 1 To Len(aColsBQV)
	If (nPos := Ascan( aHeaderBQV, {|x| x[2] == "BQV_SEQUEN" } ) ) > 0
		nPosBQVAux := Ascan(aBQVPTUDif,{|x|x[1][2] == aColsBQV[nFor][nPos]})
		If(nPosBQVAux) > 0
			For nY := 2 to len(aBQVPTUDif[nPosBQVAux])//For comeca com 2 porque o primeiro registro sempre sera o BQV_SEQUEN
				If (nPos := Ascan( aHeaderBQV, {|x| x[2] == aBQVPTUDif[nPosBQVAux][nY][1] } ) ) > 0 
					aColsBQV[nFor][nPos] :=  aBQVPTUDif[nPosBQVAux][nY][2]
				EndIf	
			Next
		EndIf
	EndIf
Next                                                    


//Pega a ultima sequencia do arquivo bqv									
If lVeioComu

	//Ajusta sequencia														
	For nI := 1 To Len(aColsBQV)

		//Ajusta as criticas														
		While Eval( {|| nPos := Ascan( aDadEvoCri,{|x| x[ PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri) ] == aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] } ), nPos > 0} ) .And.;
		Val(aDadEvoCri[nPos,PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri)]) < Val(cSequen)

			aDadEvoCri[nPos,PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri)] := cSequen

		EndDo

		//Ajusta os itens															
		If Val(aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)]) < Val(cSequen)

			aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] := cSequen

		EndIf

		cSequen := StrZero(Val(cSequen)+1,3)
	Next
EndIf

//Grava todos os bd6 e bd7												

For nI := 1 To Len(aColsBQV)

	//Se tiver algum item em auditoria										
	If aColsBQV[nI,PLRETPOS(cAliasIte+"_AUDITO",aHeaderBQV)] == "1"
		lAuditoria := .T.
	EndIf

	//Checagem dos itens														
	If aColsBQV[nI,PLRETPOS(cAliasIte+"_STATUS",aHeaderBQV)] ==  "1"

		//Gera a Senha somente se autorizado 										

		If aColsBQV[nI,PLRETPOS(cAliasIte+"_AUDITO",aHeaderBQV)] <> "1"
			If cMultSen == "0"
				cSenhaPls := PLSSenAut(dDatInt)
			ElseIf cMultSen == "1" .And. lGerSen
				cSenhaPls := PLSSenAut(dDatInt)
				lGerSen	  := .F.
			EndIf
			If lVeioComu .And. Empty(aColsBQV[nI,PLRETPOS(cAliasIte+"_NRAOPE",aHeaderBQV)])
				aColsBQV[nI,PLRETPOS(cAliasIte+"_NRAOPE",aHeaderBQV)]:= PLSNRAOPE()
			EndIf

			//Inclui a Senha															

			aColsBQV[nI,PLRETPOS(cAliasIte+"_SENHA",aHeaderBQV)] := cSenhaPls
			AaDd(aDaSenPro,{aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)]+aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPAD",aHeaderBQV)]+aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPRO",aHeaderBQV)],cSenhaPls})

			//Quantidade de diarias autorizadas										

			nQtdDPro += aColsBQV[nI,PLRETPOS(cAliasIte+"_QTDPRO",aHeaderBQV)]
		EndIf
		lUmAut := .T.
	EndIf

	//Variaveis

	cBQVCodPad	:= iIf(PLRETPOS(cAliasIte+"_CODPAD",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPAD",aHeaderBQV)],"")
	cBQVCodPro	:= iIf(PLRETPOS(cAliasIte+"_CODPRO",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPRO",aHeaderBQV)],"")
	nBQVQtdPro	:= iIf(PLRETPOS(cAliasIte+"_QTDPRO",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_QTDPRO",aHeaderBQV)],"0")
	cBQVHorPro	:= iIf(PLRETPOS(cAliasIte+"_HORPRO",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_HORPRO",aHeaderBQV)],"")
	cBQVNivAut	:= iIf(PLRETPOS(cAliasIte+"_NIVAUT",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_NIVAUT",aHeaderBQV)],"")
	cBQVNivCri	:= iIf(PLRETPOS(cAliasIte+"_NIVCRI",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_NIVCRI",aHeaderBQV)],"")
	cBQVChvNiv	:= iIf(PLRETPOS(cAliasIte+"_CHVNIV",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_CHVNIV",aHeaderBQV)],"")
	dBQVDatPro	:= iIf(PLRETPOS(cAliasIte+"_DATPRO",aHeaderBQV)>0,aColsBQV[nI,PLRETPOS(cAliasIte+"_DATPRO",aHeaderBQV)],"")

	//Faz a gravacao e pega a sequencia										

	cSequen := A092BQVGIH(nOpc,cSenhaPls,cBQVCodPad,cBQVCodPro,nBQVQtdPro,cBQVHorPro,cSequen,cBQVNivAut,cBQVNivCri,cBQVChvNiv,cLotGui,aMatCom,dBQVDatPro)

	//Tendo diferenca na sequencia ou nao trasferi as criticas para a new

	nPSeqC := PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri)
	nPSeqD := PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)

	While Eval( {|| nPos := Ascan( aDadEvoCri,{|x| x[ nPSeqC ] == aColsBQV[nI,nPSeqD] } ), nPos > 0} )

		aadd(aDadCriNew,aClone(aDadEvoCri[nPos]))

		aDadCriNew[len(aDadCriNew),nPSeqC] := cSequen
		aDadEvoCri[nPos,nPSeqC] 				:= '****'
	EndDo

	//Verifica se a sequencia esta diferente dos itens

	if aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] <> cSequen
		aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] := cSequen
	endIf
Next
aDadEvoCri 	:= aClone(aDadCriNew)
aDadCriNew := {}

//Atualiza a quantidade de diarias prorrogadas							

If nRecBE4 > 0
	If BAU->( FieldPos("BAU_GRALAU") ) > 0  .And. BAU->BAU_GRALAU=='1' .And. BR8->BR8_TPPROC=='4'
		BE4->( DbGoTo(nRecBE4) )

		If BE4->(FieldPos("BE4_DIASPR")) > 0
			RecLock("BE4", .F.)
			BE4_DIASPR += nQtdDPro
			BE4_DTALTA += Iif(Empty(BE4_DTALTA), BE4_DATPRO, 0) + nQtdDPro 
			MsUnLock()
		EndIf
	EndIf
Else
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Cabecalho da internacao nao esta posicionado" , 0, 0, {})
EndIf

//Se for para a auditoria marca todos os procedimentos da transacao		

If BQV->( FieldPos("BQV_OLNAUD") ) > 0
	AaDd(aChaveGen,{"BQV_OLNAUD",Iif(lAuditoria,"1","0")} )
EndIf

//Se tiver um autorizado													

If lUmAut
	AaDd(aChaveGen,{"BQV_TRACON","1" } )
Else
	AaDd(aChaveGen,{"BQV_TRACON","0" } )
EndIf

//Gravacao dos itens da internacao										

PLUPTCOLS("BQV",aColsBQV,aHeaderBQV,{},nOpc,aChaveGen)

If Len(aDadB6M) > 0 
	PLSPTUGRV(aDadB6M, {BE4->BE4_CODOPE, BE4->BE4_ANOPAG, BE4->BE4_MESPAG, BE4->BE4_NUMINT},"B6M")
EndIf

If Len(aItensB6L) > 0 
	PLSPTUGRV(aItensB6L, {BE4->BE4_CODOPE, BE4->BE4_ANOPAG, BE4->BE4_MESPAG, BE4->BE4_NUMINT},"B6L")
EndIf


If ExistBlock("PLGRVBQV")
	ExecBlock("PLGRVBQV",.F.,.F.,{aColsBQV,aHeaderBQV,nOpc,cChvBE4})
EndIf

//Retirar critica sem descricao											
PLSAJUMAT(aCabEvoCri,aDadEvoCri,"BQZ_DESGLO")

//Gravacao																	
aChaveGen := {}
aadd(aChaveGen,{"BQZ_CODOPE",BE4->BE4_CODOPE})
aadd(aChaveGen,{"BQZ_ANOINT",BE4->BE4_ANOPAG})
aadd(aChaveGen,{"BQZ_MESINT",BE4->BE4_MESPAG})
aadd(aChaveGen,{"BQZ_NUMINT",BE4->BE4_NUMINT})

//Gravacao das Criticas													

If Len(aDadEvoCri) > 0
	PLUPTCOLS("BQZ",aDadEvoCri,aCabEvoCri,{},nOpc,aChaveGen,.T.)
	EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCANCEL
Se cancelar na EditRecord retorna para o original	

@author  PLS TEAM
@version P11
@since   16.08.06
/*/
//-------------------------------------------------------------------
Static Function PLSCANCEL()

	Local ni:=0

	//Se cancelado retorna original													
If ValType(aMatCBkp) <> 'U'
		If Len(aMatCBkp)>0
			oBrwCri:aCols := aClone(aMatCBkp)
			oBrwCri:oBrowse:oBrowse:nAt := Len(aMatCBkp)
		Else
			oBrwCri:aCols:={Array(Len(oBrwCri:AHEADER)+1)}


			For nI := 1 To Len(oBrwCri:AHEADER)
				cX3Campo := AlLTrim( oBrwCri:AHEADER[nI][2] )
				oBrwCri:aCols[1,nI]:=CriaVar( cX3Campo, .T. )
			Next

			oBrwCri:aCols[1,(Len(oBrwCri:AHEADER)+1)]:=.F.
			oBrwCri:OBROWSE:ForceRefresh()

		Endif
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} P090Pacote
Tratamento do pacote	

@author  PLS TEAM
@version P11
@since   20.01.07
/*/
//-------------------------------------------------------------------
Function P090Pacote(cAlias,aDadB43,aCabB43,aTrbB43,lAutoma)

	LOCAL cCodPad    := &("M->"+cAlias+"_CODPAD")
	LOCAL cCodPro    := &("M->"+cAlias+"_CODPRO")
	LOCAL cSequen    := &("M->"+cAlias+"_SEQUEN")
	local cChave 	 := ""
	LOCAL cTpProc    := ""
	LOCAL nRecBR8    := BR8->(Recno())
	LOCAL nOrdBR8    := BR8->(IndexOrd())
	LOCAL bRest   	 := {|| BR8->(DbSetOrder(nOrdBR8)), BR8->(DbGoTo(nRecBR8)) }
	LOCAL aOldHeader := Iif(!lAutoma, aClone(aHeader), nil)
	LOCAL aOldCols   := Iif(!lAutoma, aClone(aCols), nil)
	LOCAL nOldN      := Iif(!lAutoma, n, 0)
	LOCAL nI		 := 0
	LOCAL nTotRea	 := 0
	LOCAL nTotUS     := 0
	LOCAL oBrwB43
	LOCAL oL1,oD1,oL2,oD2,oL3,oD3,oL4,oD4,oL5,oD5,oL6,oD6,oGrupoCon,oGrupoVal
	LOCAL lQtdServico := B43->(FieldPos("B43_QTDPRO")) > 0
	LOCAL nQtdServico := 0
	//Define dados do dialogo...                                         
	LOCAL oDlg
	LOCAL nOpca      := 0
	LOCAL bFilter
	LOCAL nTot 		 := 150
	LOCAL nCol 		 := 50
	LOCAL aB43Aux	 := {}
	LOCAL aB43TAux	 := {}

	DEFAULT lAutoma	:= .F.

	//Procedimento nao foi informado													
	If Empty(cCodPro)
		Help("",1,"PLSA090P02")
		Eval(bRest)
		Return
	Endif

	//Posiciono na tabela padr„o														
	BR8->(DbSetOrder(1))
	BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
	cTpProc := BR8->BR8_TPPROC
	If cTpProc <> '6' .and. alltrim(cCodPro) <> getNewPar("MV_PLPACPT","99999998")
		Help("",1,"PLSA090P01")
		Eval(bRest)
		Return
	Endif

	//SeguranÁa
	if len(aDadB43) == 0 .or. empty(aDadB43[1,1])
		//na„o existe esses campos na tabela bej
		cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+cSequen)
		B43->(DbSetOrder(2))//B43_FILIAL+B43_CODOPE+B43_CODLDP+B43_CODPEG+B43_NUMERO+B43_ORIMOV+B43_SEQUEN
		if B43->(MsSeek(xFilial("B43")+cChave))
			store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_CODOPE+B43_CODLDP+B43_CODPEG+B43_NUMERO+B43_ORIMOV+B43_SEQUEN) == xFilial("B43")+cChave
		endIf
	endIf

	//Nao existe parametrizaÁ„o para pacote											
	nPos := PLRETPOS("B43_SEQUEN",aCabB43)
	If aScan(aDadB43,{|x| alltrim(x[nPos]) == AllTrim(cSequen) .and. x[Len(x)] == .F.}) == 0
		Help("",1,"PLSA090P03")
		Eval(bRest)
		Return
	Endif

	aB43Aux  := FiltroPac(cSequen,aDadB43,,aCabB43)//Filtrando o aDadB43 para sÛ deixar os procedimentos do pacote que est· se referindo para a exibiÁ„o dentro do Protheus.
	aB43TAux := FiltroPac(cSequen,aDadB43,aTrbB43,aCabB43)//Filtrando o aTrbB43 para sÛ deixar os procedimentos do pacote que est· se referindo para a exibiÁ„o dentro do Protheus.
	//Define dialogo...         
	If !lAutoma                                         
		DEFINE MSDIALOG oDlg TITLE  STR0312 FROM 009,000 TO 041,60 OF GetWndDefault() //"Itens contidos no pacote"
		oDlg:lEscClose := .F.
		//Monta o Browse dos Procedimentos                                   
		oBrwB43 := TPLSBrw():New(030,001,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabB43 ,aB43Aux ,.F. ,"B43" ,K_Visualizar,"Procedimentos contidos no pacote",nil,nil,nil,aB43TAux,,,)
		oBrwB43:Refresh()
		//0=Procedimento							(0=AMB)						|
		//1=Material	    						(2=Material)				|
		//2=Medicamento							(3=Medicamento)				|
		//3=Taxas									(1=Hospitalar)				|
		//4=Diarias								(1=Hospitalar)				|
		//5=Ortese/Protese							(1=Hospitalar)				|
		@ 155,5 GROUP oGrupoCon TO 202,150 OF oDlg LABEL STR0284   COLOR CLR_BLACK PIXEL  //Legenda
		@ 15+nTot,10 		BITMAP oL1 RESNAME PRetColPac('0')    	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 15+nTot,20 		Say    oD1 PROMPT  PRetColPac('0',.T.)	OF oDlg SIZE 120,10 PIXEL
		@ 15+nTot,40+nCol 	BITMAP oL2 RESNAME PRetColPac('1')   	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 15+nTot,50+nCol 	Say    oD2 PROMPT  PRetColPac('1',.T.) OF oDlg SIZE 120,10 PIXEL
		@ 23+nTot,10 		BITMAP oL3 RESNAME PRetColPac('2')    	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 23+nTot,20 		Say    oD3 PROMPT  PRetColPac('2',.T.) 	OF oDlg SIZE 120,10 PIXEL
		@ 23+nTot,40+nCol 	BITMAP oL4 RESNAME PRetColPac('3')    	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 23+nTot,50+nCol 	Say    oD4 PROMPT  PRetColPac('3',.T.) OF oDlg SIZE 120,10 PIXEL
		@ 31+nTot,10 		BITMAP oL5 RESNAME PRetColPac('4')      OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 31+nTot,20 		Say    oD5 PROMPT  PRetColPac('4',.T.) OF oDlg SIZE 120,10 PIXEL
		@ 31+nTot,40+nCol 	BITMAP oL6 RESNAME PRetColPac('5')    	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 31+nTot,50+nCol 	Say    oD6 PROMPT  PRetColPac('5',.T.) 	OF oDlg SIZE 120,10 PIXEL
		@ 39+nTot,10 		BITMAP oL7 RESNAME PRetColPac('7')      OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 39+nTot,20 		Say    oD7 PROMPT  PRetColPac('7',.T.) OF oDlg SIZE 120,10 PIXEL
		@ 39+nTot,40+nCol 	BITMAP oL8 RESNAME PRetColPac('8')    	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
		@ 39+nTot,50+nCol 	Say    oD8 PROMPT  PRetColPac('8',.T.) 	OF oDlg SIZE 120,10 PIXEL
	EndIf
	For nI:= 1 to Len(aB43Aux)
		If !aB43Aux[nI][len(aB43Aux[nI])]
			If lQtdServico 
				nQtdServico := aB43Aux[nI][PLRETPOS("B43_QTDPRO",aCabB43,.F.)]

				If nQtdServico > 0
					nTotRea += (aB43Aux[nI][PLRETPOS("B43_VALFIX",aCabB43,.F.)] * nQtdServico)
				Else
					nTotRea += aB43Aux[nI][PLRETPOS("B43_VALFIX",aCabB43,.F.)]
				EndIf
				nTotUs  += aB43Aux[nI][PLRETPOS("B43_VALCH",aCabB43,.F.)]
			Else
				nTotRea += aB43Aux[nI][PLRETPOS("B43_VALFIX",aCabB43,.F.)]
				nTotUs  += aB43Aux[nI][PLRETPOS("B43_VALCH",aCabB43,.F.)]
			EndIf
		Endif
	Next
	If !lAutoma
		@ 155,155 GROUP oGrupoVal TO 202,230 OF oDlg LABEL STR0311 COLOR CLR_BLACK PIXEL   //"ValorizaÁ„o"

		@ 15+nTot,160 		Say    oD1 PROMPT  STR0309+' - '+alltrim(TransForm(nTotRea,"@E 99,999,999,999.99"))	OF oDlg SIZE 120,10 PIXEL //"Valor Real"
		@ 23+nTot,160 		Say    oD3 PROMPT  STR0310+'  - '+alltrim(str(nTotUs))	OF oDlg SIZE 120,10 PIXEL  //"Valor CH"

		If Len(aB43Aux) > 1
			oBrwB43:SetPos(1)
		Endif
		//Ativa o dialogo...                                                 
		ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))
	
		//Restaura dados salvados...                                         
		aCols := aOldCols
		aHeader := aOldHeader
		n := nOldN
	EndIf

	Eval(bRest)

	If lAutoma
		Return .T.
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL090CarCr
Carrega as criticas	

@author  PLS TEAM
@version P11
@since   08.12.05
/*/
//-------------------------------------------------------------------
Function PL090CarCr()

	PutHelp("PPLNUMLIB02",{"O n˙mero da liberaÁ„o","j· foi executada em outra guia."},{},{},.T.)
PutHelp("SPLNUMLIB02",{"Selecione um n˙mero de liberaÁ„o","diferente"},{},{},.T.)

PutHelp("PPLSA090P01",{STR0300,STR0301,""},{},{},.f.) //"N„o foi possÌvel a visualizaÁ„o.""da composiÁ„o do pacote."
PutHelp("SPLSA090P01",{STR0302,STR0303,""},{},{},.f.)//"O procedimento n„o est· cadastrado""como 'Pacote' na tabela pad„o."

PutHelp("PPLSA090P02",{STR0300,STR0301,""},{},{},.f.) //"N„o foi possÌvel a visualizaÁ„o.""da composiÁ„o do pacote."
PutHelp("SPLSA090P02",{STR0304,STR0305,""},{},{},.f.)//"O procedimento n„o foi informado","corretamente."

PutHelp("PPLSA090P03",{STR0300,STR0301,""},{},{},.f.)  //"N„o foi possÌvel a visualizaÁ„o.""da composiÁ„o do pacote."
PutHelp("SPLSA090P03",{STR0306,STR0307,STR0308},{},{},.f.) //"N„o existe itens relacionados","relacionados a este pacote","nesta guia."

PutHelp("PPLSA090001",{STR0396,STR0397},{STR0396,STR0397},{STR0396,STR0397},.F.)
PutHelp("SPLSA090001",{STR0398,STR0399},{STR0398,STR0399},{STR0398,STR0399},.F.)

PutHelp("PPLSA090002",{STR0340,STR0341},{STR0340,STR0341},{STR0340,STR0341},.F.)
PutHelp("SPLSA090002",{STR0342,STR0343},{STR0342,STR0343},{STR0342,STR0343},.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PRetColPac
Retorna a cor correspondente do procedimento

@author  PLS TEAM
@version P11
@since   08.12.05
/*/
//-------------------------------------------------------------------
Function PRetColPac(cTipo,lDesc)
	LOCAL aColor  := {{'0',STR0294,'BR_VERDE_OCEAN'},;  //"Procedimento"
{'1',STR0295,'BR_LARANJA_OCEAN'},; //"Material"
{'2',STR0296,'BR_AZUL_OCEAN'},;  //"Medicamento"
{'3',STR0297,'BR_PRETO_OCEAN'},; //"Taxa"
{'4',STR0298,'BR_AMARELO_OCEAN'},; //"Di·ria"
{'5',STR0299,'BR_CINZA_OCEAN'},;   //"Ortese/Protese"
{'7',STR0406,'BR_VERMELHO_OCEAN'},;   //"Gases Medicinais"
{'8',STR0407,'BR_PINK_OCEAN'}}   //"Alugueis"
LOCAL cRet	  := ""
LOCAL nI	  := ""
DEFAULT cTipo := ""
	DEFAULT lDesc := .F.
	If !lDesc
		If (nI := aScan(aColor,{|x| x[1] == cTipo})) > 0
			cRet := aColor[nI][3]
		Endif
	Else
		If (nI := aScan(aColor,{|x| x[1] == cTipo})) > 0
			cRet := aColor[nI][2]
		Endif
	Endif
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PRetHeaPac
Retorna a os campos para exibicao emn tela	

@author  PLS TEAM
@version P11
@since   08.12.05
/*/
//-------------------------------------------------------------------
Function PRetHeaPac(lArray)

	Local cRet := "B43_IMGSTA,B43_SEQUEN,B43_CODPAD,B43_CODPRO,B43_DESPRO,B43_VALCH,B43_VALFIX,B43_PRINCI,B43_TIPO,B43_NIVPAC"
	Local aRet := {'B43_IMGSTA','B43_SEQUEN','B43_CODPAD','B43_CODPRO','B43_DESPRO','B43_VALCH','B43_VALFIX','B43_PRINCI','B43_TIPO','B43_NIVPAC'}

	Default lArray := .F.

	If B43->(FieldPos("B43_QTDPRO")) > 0
		cRet += ",B43_QTDPRO"
		aAdd(aRet, "B43_QTDPRO")
	EndIf

Return IIF(lArray, aRet, cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PlAliPac

@author  PLS TEAM
@version P11
@since   08.12.05
/*/
//-------------------------------------------------------------------
Function PlAliPac(cCodPad,cCodPro,cTipPreGui,dDatPro,cAliasCab,aDadB43,aCabB43,aTrbB43,cSequen,cTpGrv,cCodOpe,cCodRda)
	LOCAL nRecBR8   := BR8->(Recno())
	LOCAL nOrdBR8   := BR8->(Indexord())
	LOCAL aRetB43   := {}
	LOCAL nPos	    := 0
	LOCAL nSize     := 0
	LOCAL nI	    := 0
	LOCAL nInd	    := 0
	Default cCodOpe := PLSINTPAD()
	Default cCodRda := ""
Default cTpGrv  := "1"

If cTpGrv=="2"
	aRetB43 := PlRetPac(cCodOpe,cCodRda,cCodPad,cCodPro,cTipPreGui,dDatPro)
Else
	aRetB43 := PlRetPac(cCodOpe,If(Type("M->"+cAliasCab+"_CODRDA") == "C",&("M->"+cAliasCab+"_CODRDA"),padr('',TamSx3('BAU_CODIGO')[1])),cCodPad,cCodPro,cTipPreGui,dDatPro)
Endif

//Tenho que limpar pq o usuario pode estar alterando					 	

If (nPos := PLRETPOS("B43_SEQUEN",aCabB43,.F.)) > 0
	nSize := Len(aDadB43)

	//Antes de alimentar o array eu deleto as linhas daquela sequencia	    

	While (nI := aScan(aDadB43,{|x| x[nPos] == cSequen .and. x[Len(x)] == .F. })) != 0
		aDadB43[nI][Len(aDadB43[nI])] := .T.
	Enddo

	For nI := 1 To Len(aRetB43)

		//Faco um addblank na mao												 	

		If !(Len(aDadB43) == 1 .and. (nPos := PLRETPOS("B43_SEQUEN",aCabB43,.F.)) > 0 .and. Empty(aDadB43[1][nPos]))
			aadd(aDadB43,{})
			For nInd :=  1 To Len(aCabB43)+1
				If nInd <= Len(aCabB43)
					If     aCabB43[nInd,8] == "C"
						aadd(aDadB43[Len(aDadB43)],Space(aCabB43[nInd,4]))
					ElseIf aCabB43[nInd,8] == "D"
						aadd(aDadB43[Len(aDadB43)],ctod(""))
					ElseIf aCabB43[nInd,8] == "N"
						aadd(aDadB43[Len(aDadB43)],0)
					Else
						aadd(aDadB43[Len(aDadB43)],nInd)
					Endif
				Else
					aadd(aDadB43[Len(aDadB43)],.F.)
				Endif
			Next
		Endif

		For nInd :=  1 To Len(aCabB43)+1
			If nInd <= Len(aCabB43)
				aDadB43[Len(aDadB43),nInd] := CriaVar(aCabB43[nInd,2],.T.)
			Else
				aDadB43[Len(aDadB43),nInd] := .F.
			Endif
		Next

		aadd(aTrbB43,0)

		nPos := PLRETPOS("B43_SEQUEN",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := cSequen
		nPos := PLRETPOS("B43_TIPO",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := aRetB43[nI][3]
		nPos := PLRETPOS("B43_CODPAD",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := aRetB43[nI][1]
		nPos := PLRETPOS("B43_CODPRO",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := aRetB43[nI][2]
		nPos := PLRETPOS("B43_DESPRO",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := Posicione("BR8",1,xFilial("BR8")+aRetB43[nI][1]+aRetB43[nI][2],"BR8_DESCRI")
		nPos := PLRETPOS("B43_VALCH",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := aRetB43[nI][4]
		nPos := PLRETPOS("B43_VALFIX",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := aRetB43[nI][5]
		nPos := PLRETPOS("B43_PRINCI",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := aRetB43[nI][6]
		nPos := PLRETPOS("B43_IMGSTA",aCabB43,.F.)
		aDadB43[Len(aDadB43)][nPos] := PRetColPac(aRetB43[nI][3])
		nPos := PLRETPOS("B43_NIVPAC",aCabB43,.F.)
			aDadB43[Len(aDadB43)][nPos] := aRetB43[nI][10]
		Next
	Endif
	BR8->(DbSetOrder(nOrdBR8))
	BR8->(DbGoTo(nRecBR8))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTrtReg
Trata a regra da  localidade x regiao x rede credenciada

@author  PLS TEAM
@version P11
@since   08.12.05
/*/
//-------------------------------------------------------------------
Function PLSTrtReg(aRetPro,aDadRDA,aDadUsr,aRet,cMatVid1)
	LOCAL lAutorizado	:= .F.
	Local lRet			:= .T.
	LOCAL cMatVid		:= cMatVid1
	LOCAL cCodPla		:= "   "
LOCAL cVersao		:= " "
LOCAL cCepUsr     := " "
LOCAL	cMunic		:= " "
LOCAL cCodOpe		:= __CUSERID
LOCAL aRegiao		:= {}
LOCAL I				:= 0
LOCAL nOrdBEA		:= BEA->(IndexOrd())
LOCAL nRecBEA		:= BEA->(Recno())
LOCAL nOrdBE2		:= BE2->(IndexOrd())
LOCAL nRecBE2		:= BE2->(Recno())
LOCAL bRest			:= {||	BEA->(DbSetOrder(nOrdBEA)),BEA->(DbGoTo(nRecBEA)),BE2->(DbSetOrder(nOrdBE2)),BE2->(DbGoTo(nRecBE2))}

DbSelectArea("BY8")
DbSetOrder(1)
If DbSeek(xFilial("BY8")+PlsIntPad()+cCodOpe)
	While BY8->(!EOF()) .AND. BY8_CODOPE == cCodOpe
		aadd(aRegiao,BY8->BY8_CODREG)
		BY8->(DbSkip())
	End
EndIf

For i:=1 to Len(aRegiao)
	DbSelectArea("BTS")
	DbSetOrder(1)
	DbSeek(xFilial("BTS")+cMatvid)
	cCepUsr := BTS->BTS_CEPUSR
	cMunic  := BTS->BTS_CODMUN
	DbSelectArea("BIB")
	DbSetOrder(1)
	If DbSeek(xFilial("BIB")+PLSINTPAD()+aRegiao[i],.T.)
		If (BIB->BIB_TIPO == "1" .OR. BIB->BIB_TIPO == "3")
			DbSelectArea("BIC")
			DbSetOrder(1)
			If !DbSeek(xFilial("BIC")+PLSINTPAD()+aRegiao[i]+cMunic,.T.)
				DbSelectArea("BY7")
				DbSetOrder(1)
				If DbSeek(xFilial("BY7")+PLSINTPAD()+aRegiao[i],.T.)
					While BY7->(!EOF()) .AND. BY7->BY7_CODREG == aRegiao[i]
						If cCepUsr >= BY7->BY7_CEPDE .AND. cCepUsr <= BY7->BY7_CEPATE
							lAutorizado := .T.
							Exit
						EndIf
						BY7->(DbSkip())
					End
				EndIf
			Else
				lAutorizado := .T.
			EndIf
		Else
			DbSelectArea("BY7")
			DbSetOrder(1)
			If DbSeek(xFilial("BY7")+PLSINTPAD()+aRegiao[i]+cCepUsr,.T.)
				lAutorizado := .T.
			EndIf
		EndIf
	EndIf
Next
If !lAutorizado
	If Type("M->BE1_USUARI") <> "U"
		M->BE1_USUARI:= Space(Len(M->BE1_USUARI))
		M->BE1_MATANT:= Space(Len(M->BE1_MATANT))
		M->BE1_NOMUSR:= Space(Len(M->BE1_NOMUSR))
		M->BE1_TIPUSR:= Space(Len(M->BE1_TIPUSR))
	EndIf
	lRet:= .F.
	MsgAlert(STR0282)//"O Operador n„o atende a essa Regi„o"
	EndIf

	Eval(bRest)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090LEG
Exibe a legenda...

@author  PLS TEAM
@version P11
@since   01.04.07
/*/
//-------------------------------------------------------------------
Function PLSA090Leg()

	BrwLegenda(cCadastro,STR0293,aCdCores)//status

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090RAS
Rastrear autorizacoes a partir de uma liberacao  

@author  PLS TEAM
@version P11
@since   01.04.07
/*/
//-------------------------------------------------------------------
Function PLSA090RAS()
	LOCAL cSQL		:= ""
LOCAL cChave     	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
LOCAL cTransNum  	:= "@R !!!!.!!!!.!!-!!!!!!!!"
LOCAL cTransGui  	:= "@R !!!!.!!!!.!!!!!!!!.!!!!!!!!"
LOCAL cTitulo    	:= STR0600 +TransForm(cChave,cTransNum) //"AutorizaÁıes/Guias geradas a partir da liberaÁ„o n˙mero "
LOCAL cStrFil    	:= ""
LOCAL aDados     	:= {}
LOCAL aCores	 	:= {}
LOCAL aCdCores	:= {}
LOCAL aArea      	:= GetArea()
LOCAL aCabec     	:= {}
LOCAL cTipGui		:= ''

//Monta cabecalho

aCabec := {{STR0288,cTransNum,070},; //"Numero da AutorizaÁ„o"
{"Numero da Guia",cTransGui,070},; //"Numero da Guia"
{'Data',"@D",40},;
{STR0290,"@R !!:!!",020},; //"Hora"
{"RDA","@!",030},;
{'Nome RDA',"@!",200},;
{'Tipo',"@!",70}}

//sql
cSQL := " SELECT BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT AUT, BEA_DATPRO, BEA_HORPRO, "
cSQL += " BEA_CODRDA, BEA_NOMRDA, BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI CTAMED, BEA_TIPGUI FROM "+BEA->(RetSQLName("BEA"))+" WHERE "
cSQL += " BEA_FILIAL = '"+xFilial("BEA")+"' AND "
cSQL += " BEA_NRLBOR = '"+cChave+"' AND "
cSQL += " BEA_CANCEL <> '1' AND "
cSQL += " D_E_L_E_T_ = ' ' ORDER BY R_E_C_N_O_ "

PLSQuery(cSQL,"TrbBEA")

//carrega matriz

While ! TrbBEA->(Eof())
	If  TrbBEA->BEA_TIPGUI $ "01/02" 
		cTipGui	:= 'SADT'
	elseif TrbBEA->BEA_TIPGUI == "13"
		cTipgui := "Odonto"
	Else
		cTipGui	:= 'Internacao'
	EndIf
	aadd(aDados,{TrbBEA->AUT,;
	TrbBEA->CTAMED,;
	TrbBEA->BEA_DATPRO,;
	TrbBEA->BEA_HORPRO,;
	TrbBEA->BEA_CODRDA,;
	TrbBEA->BEA_NOMRDA,;
	cTipGui})
	TrbBEA->(DbSkip())
Enddo
TrbBEA->(DbCloseArea())

//select no bd5

cSQL := " SELECT '' AUT, BD5_DATPRO, BD5_HORPRO, "
cSQL += " BD5_CODRDA, BD5_NOMRDA, BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO CTAMED, BD5_TIPGUI FROM "+BD5->(RetSQLName("BD5"))+" WHERE "
cSQL += " BD5_FILIAL = '"+xFilial("BD5")+"' AND "
cSQL += " (BD5_NRLBOR = '"+cChave+"' ) AND "
cSql += " BD5_SITUAC = '1' AND "
cSQL += " D_E_L_E_T_ = ' ' ORDER BY R_E_C_N_O_ "

PLSQuery(cSQL,"TrbBD5")

While ! TrbBD5->(Eof())

	If aScan(aDados,{|x| x[2] == TrbBD5->CTAMED }) == 0
		If TrbBD5->BD5_TIPGUI $ "01/02"
			cTipGui	:= 'SADT'
		Else
			cTipGui	:= 'Internacao'
		EndIf
		aadd(aDados,{'',;
		TrbBD5->CTAMED,;
		TrbBD5->BD5_DATPRO,;
		TrbBD5->BD5_HORPRO,;
		TrbBD5->BD5_CODRDA,;
		TrbBD5->BD5_NOMRDA,;
		cTipGui})
	Endif
	TrbBD5->(DbSkip())
Enddo
TrbBD5->(DbCloseArea())

//acdcores
aCdCores  	:= { 	{ 'BR_VERMELHO'    	,OemtoAnsi('GUIA DE CONSULTA')},;
{ 'BR_AZUL' 		,OemtoAnsi('GUIA DE SERVICOS')},;
{ 'BR_LARANJA' 		,OemtoAnsi('GUIA DE SOL. INTERNACAO')},;
{ 'BR_PRETO' 		,OemtoAnsi('GUIA DE REEMBOLSO')},;
{ 'BR_VERDE' 		,OemtoAnsi('GUIA DE RES. INTERNACAO')},;
{ 'BR_PINK' 		,OemtoAnsi('GUIA DE HOR. INDIVIDUAL')}}

//acores
aCores   := {	{ 'aDados[oCritica:nAt, 7] == "01"'	,aCdCores[1,1] },;
{ 'aDados[oCritica:nAt, 7] == "02"'	,aCdCores[2,1] },;
{ 'aDados[oCritica:nAt, 7] == "03"'	,aCdCores[3,1] },;
{ 'aDados[oCritica:nAt, 7] == "04"'	,aCdCores[4,1] },;
{ 'aDados[oCritica:nAt, 7] == "05"'	,aCdCores[5,1] },;
{ 'aDados[oCritica:nAt, 7] == "06"'	,aCdCores[6,1] }}

//block
bBloCli := {|x| pAbrGuia(x,aDados)}

//Abrir uma area para evitar erro de area j· sendo usado em outro processamento

DbSelectArea("BEA")

//monstra crigem

If Len(aDados) >= 0
	If Len(aDados) <> 0
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
		objCENFUNLGP:useLogUser()
	endif
	PLSCRIGEN(aDados,aCabec,cTitulo,nil,nil,nil,nil,nil,nil,nil,nil,bBloCli,nil,nil,nil,nil,nil,nil,nil,aCores,aCdCores,nil,nil,nil,nil,nil)
Else
	Help("",1,"REGNOIS")
	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} pAbrGuia

@author  PLS TEAM
@version P11
@since   01.04.07
/*/
//-------------------------------------------------------------------
static Function pAbrGuia(x,aDados)
	LOCAL nRecBD5 := BD5->(Recno())
	LOCAL nOrdBD5 := BD5->(IndexOrd())
	LOCAL nRecBE4 := BE4->(Recno())
	LOCAL nOrdBE4 := BE4->(IndexOrd())

	If aDados[x:nAt,7] $ "01,02,04,06"
	BD5->(DbSetOrder(1))
	BD5->(MsSeek(xFilial('BD5')+aDados[x:nAt,2]))
	PLVISGUI('BD5',BD5->(Recno()),K_Visualizar)
Elseif aDados[x:nAt,7] $ "03,05"
	BE4->(DbSetOrder(1))
	BE4->(MsSeek(xFilial('BE4')+aDados[x:nAt,2]))
	PLVISGUI('BE4',BE4->(Recno()),K_Visualizar)
	Endif

	BD5->(DbGoTo(nRecBD5))
	BD5->(DbSetORder(nOrdBD5))
	BE4->(DbGoTo(nRecBE4))
	BE4->(DbSetORder(nOrdBE4))


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVISGUI
Parcelamento	

@author  PLS TEAM
@version P11
@since   22.05.13
/*/
//-------------------------------------------------------------------
Function PLVISGUI(cAlias,nReg,nOpc)
	LOCAL cCpoSta   := &(cAlias+"->"+cAlias+"_FASE")
LOCAL cCpoSit   := &(cAlias+"->"+cAlias+"_SITUAC")
LOCAL cTipGui   := &(cAlias+"->"+cAlias+"_TIPGUI")
LOCAL cCodOpe   := &(cAlias+"->"+cAlias+"_CODOPE")
LOCAL nOpca
LOCAL aRetorno
LOCAL nFor
LOCAL aProxAno
LOCAL aCampos   := {}
LOCAL cFunCpo
LOCAL cTipCpo
LOCAL aAlter    := {}
LOCAL nOrdBCL   := BCL->(IndexOrd())
LOCAL nRecBCL   := BCL->(Recno())
Local aArea		:= GetArea()

//__lManunt := .T.

//Testa posicao do layout da guia...                                      

If BCL->BCL_TIPGUI <> cTipGui
	BCL->(DbSetOrder(1))
	BCL->(MsSeek(xFilial("BCL")+cCodOpe+cTipGui))
Endif

cFunCpo   := BCL->BCL_FUNACP
cTipCpo   := BCL->BCL_TIPACP

//Testa parametrizacao do ajuste no layout da guia...                     

If Empty(cFunCpo)
	Help("",1,"PLSA500ES1")
	Return
Endif

//Determina os campos que serao analisados...                             

aPar := {cTipGui}

//Executa a funcao do layout...                                           

If cTipCpo == "1"
	cMacro   := AllTrim(cFunCpo)
	aCampos := &(cMacro)(aPar,,,)
Else
	aCampos := ExecBlock(cFunCpo,.F.,.F.,aPar)
Endif

//Executa o PLSA500MOV passando o parametro de ajuste...                  


dbSelectArea("BCI")
BCI->(dbSetOrder(3))
BCI->(MsSeek(xFilial("BCI")+cCodOpe+cTipGui)) //BCI_FILIAL, BCI_CODOPE, BCI_TIPGUI, R_E_C_N_O_, D_E_L_E_T_

	PLSA500MOV(cAlias,nReg,K_Visualizar,{},.F.)

	BCL->(DbSetOrder(nOrdBCL))
	BCL->(DbGoTo(nRecBCL))
	RestArea(aArea)

Return

/*/{Protheus.doc} PLSA090RSD
Refaz o status da liberacao a partir de uma exclusao de autor	

@author  PLS TEAM
@version P11
@since   01.04.07
/*/
function PLSA090RSD(cNumAut,cNumLib,lGuiHo,lResInt)
local aAreaBEA 	:= BEA->(GetArea())
local aAreaBE4 	:= BE4->(GetArea())
local aAreaBD6 	:= BD6->(GetArea())
local aAreaBD7 	:= BD7->(GetArea())
local nMaiorSld	:= 0
local cSQL		:= ""
local cAliasIte	:= ""
local cChvGOri	:= ""
local cCodOpe	:= ""
local cCodLdp	:= ""
local cCodPeg	:= ""
local cNumero	:= ""
local cOriMov	:= ""
local cSequen 	:= ""
local cCodPad 	:= ""
local cCodPro 	:= ""
local cCancGuia	:= ""
local cStatusBEA:= ""
local cTipGui	:= ""

default lGuiHo	:= .F.
default lResInt	:= .F.

cAliasIte := "BE2"
BE2->( DbSetOrder(1) )//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_CODPAD + BE2_CODPRO + BE2_DENREG + BE2_FADENT

//Posiciona na guia de cobranca
if lGuiHo .or. lResInt

	BE4->( DbGoTop() )

	BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
	if BE4->( MsSeek( xFilial("BE4") + cNumAut ) )
		cCodOpe	:= BE4->BE4_CODOPE
		cCodLdp	:= BE4->BE4_CODLDP
		cCodPeg	:= BE4->BE4_CODPEG
		cNumero	:= BE4->BE4_NUMERO
		cOriMov	:= BE4->BE4_ORIMOV
	else

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "BE4 - Cobranca nao encontrada - ["+cNumAut+"]" , 0, 0, {})

		BEA->(RestArea(aAreaBEA))
		BE4->(RestArea(aAreaBE4))
		BD6->(RestArea(aAreaBD6))
		BD7->(RestArea(aAreaBD7))
		return
	endIf

	//Posiciona na guia de autorizacao
	if BE4->( MsSeek( xFilial("BE4") + cNumLib ) )
		cChvGOri := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
	else

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "BE4 - Autorizacao nao encontrada - ["+cNumLib+"]" , 0, 0, {})

		BEA->(RestArea(aAreaBEA))
		BE4->(RestArea(aAreaBE4))
		BD6->(RestArea(aAreaBD6))
		BD7->(RestArea(aAreaBD7))
		return
	endIf

else

	BEA->( DbGoTop() )

	BEA->( DbSetOrder(1) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	if BEA->( MsSeek( xFilial("BEA") + cNumAut ) )
		cCodOpe	:= BEA->BEA_OPEMOV
		cCodLdp	:= BEA->BEA_CODLDP
		cCodPeg	:= BEA->BEA_CODPEG
		cNumero	:= BEA->BEA_NUMGUI
		cOriMov	:= BEA->BEA_ORIMOV
		cCancGuia	:= BEA->BEA_CANCEL
		cStatusBEA	:= BEA->BEA_STATUS
	else

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "BEA - Cobranca nao encontrada - ["+cNumAut+"]" , 0, 0, {})

		BEA->(RestArea(aAreaBEA))
		BE4->(RestArea(aAreaBE4))
		BD6->(RestArea(aAreaBD6))
		BD7->(RestArea(aAreaBD7))
		Return
	endIf

	//Posiciona na guia de autorizacao
	if !BEA->( MsSeek( xFilial("BEA") + cNumLib ) )

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "BEA - Autorizacao nao encontrada - ["+cNumLib+"]" , 0, 0, {})

		BEA->(RestArea(aAreaBEA))
		BE4->(RestArea(aAreaBE4))
		BD6->(RestArea(aAreaBD6))
		BD7->(RestArea(aAreaBD7))
		Return
	endIf
	//Atualiza stalib
	PLSATUCS("1")
endIf

//Seleciona todos os registros da execucao que esta sendo deletada
cSQL := "SELECT BE2_SEQUEN, BE2_CODPAD, BE2_CODPRO, BE2_QTDPRO, BE2_SALDO FROM " + BE2->( RetSQLName("BE2") )
cSQL += " WHERE BE2_FILIAL = '" + xFilial(cAliasIte)	+"' "
cSQL += " 	AND BE2_OPEMOV = '" + subs(cNumAut,1,4)		+ "' "
cSQL += " 	AND BE2_ANOAUT = '" + subs(cNumAut,5,4)		+ "' "
cSQL += " 	AND BE2_MESAUT = '" + subs(cNumAut,9,2)		+ "' "
cSQL += " 	AND BE2_NUMAUT = '" + subs(cNumAut,11,8)	+ "' "
cSQL += "	AND BE2_STATUS = '1'"
cSQL += " 	AND D_E_L_E_T_ = ' ' "

//Ajusta o alias da query
If cAliasIte <> 'BE2'
	cSQL := strTran(cSQL,'BE2',cAliasIte)
endIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSQL)),"Trb",.F.,.T.)

//While nos itens da execucao
While !Trb->( Eof() )
	//Quantidade do procedimento na execucao
	nQtdPro := Trb->&( cAliasIte+"_QTDPRO" )
	cSequen := Trb->&( cAliasIte+"_SEQUEN" )
	//Atualiza saldo do bd6 e be2
	If lGuiHo .Or. lResInt
		PLSATUSS(nil,nil,nil,nMaiorSld,"1",.T.,cNumLib + cSequen, 1)
	Else
		If cCancGuia == "1" .And. cStatusBEA == "3" .And. !lGuiHo .and. !lResInt
			PLSATUSS(nil,.F.,nil,nil,"1",.F.,cNumLib + cSequen,1)
		Else
			PLSATUSS(nil,.F.,nil,nil,"1",.F.,cNumLib + cSequen,1,nil,nil,nil,nQtdPro )
		EndIf
	EndIf

		Trb->( DbSkip() )
endDo

	Trb->( DbCloseArea() )

	BEA->(RestArea(aAreaBEA))
	BE4->(RestArea(aAreaBE4))
	BD6->(RestArea(aAreaBD6))
	BD7->(RestArea(aAreaBD7))

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMUDADES
Troca da Descricao do campo BE2_QTDPRO x BE2_QTDSOL 	

@author  PLS TEAM
@version P11
@since   01.04.07
/*/
//-------------------------------------------------------------------
Function PLSMUDADES(nLinha,aHeaderEd,aColsEd,oObjetoBrw,oEncPLS)
	Local nI		:= 0
	Local nX 		:= 0
	Local nInd		:= 0
	Local aTela 	:= aClone(oEncPLS:aTela)
	Local aFields	:= {}
	Local nPosQtdProd := Ascan(aheadered,{|x| AllTrim(x[2]) == "BE2_QTDPRO"})

For nI := 1 To Len(aTela)
	//na versao 11 mudou... agora tem que mexer tambem no aentryctrls
	aFields	:= aTela[nI]
	For nX := 1 To Len(aFields)
		If AllTrim(cDesQtdAut) == AllTrim(aFields[nX])
			oEncPLS:aTela[nI,nX] := cDesQtdSol
			For nInd := 1 To Len(oEncPls:AENTRYCTRLS)
				If ALLTRIM(oEncPls:AENTRYCTRLS[nInd]:cReadVar) == "M->BE2_QTDPRO"
					oEncPls:aentryctrls[nInd]:oparent:ctitle := strtran(oEncPls:aentryctrls[nInd]:oparent:ctitle,AllTrim(cDesQtdAut),Alltrim(cDesQtdSol))
					M->BE2_QTDPRO := acolsEd[nLinha,nPosQtdProd]
				Endif
			Next
		Endif

		If AllTrim(cDesQtdSol) == AllTrim(aFields[nX])
			oEncPLS:aTela[nI,nX] := cDesQtdAut
			For nInd := 1 To Len(oEncPls:AENTRYCTRLS)
				If ALLTRIM(oEncPls:AENTRYCTRLS[nInd]:cReadVar) == "M->BE2_QTDSOL"
						oEncPls:aentryctrls[nInd]:oparent:ctitle := strtran(oEncPls:aentryctrls[nInd]:oparent:ctitle,AllTrim(cDesQtdSol),Alltrim(cDesQtdAut))
					Endif
				Next
			Endif
		Next nX
	Next

	oBrwCri:ForceRefresh(oBrwCri)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090Ins
Faz a insistencia de solicitacoes negadas via PTU

@author  PLS TEAM
@version P11
@since   13.04.12
/*/
//-------------------------------------------------------------------
Function PLSA090Ins(cAliasCab)
	Local aItens     := {}
	Local aStru01    := {}
	Local aCpoBro    := {}
	Local aCores     := {}
	Local aDados     := {}
	Local aRetOln    := {}
	Local aGrvTraPTU := {}
	Local aItemLib   := {}
	Local nCont      := 0
	Local nOpca      := 0
	Local nOpca2     := 0
	Local nQtdAud    := 0
	Local cSolRev1   := Space(254)
	Local cSolRev2   := Space(254)
	Local cTranOri   := ""
Local cNrTrol    := ""
Local cAliasTrol := ""
Local cMsgXsdErr := ""
Local cArq       := ""
Local oDlg
Local oDlg2
Local cChaveB4A  := ""
Local lPrimSolic := .T.
Local dDatPro    
//Variaveis PE
Local lGerB53    := .F.
Local lP90INB53  := ExistBlock("P90INB53")
Local cRegInt    := '0'
Local cAliItePE  := ''
Local cAliCriPE  := ''
Local cChaveIte  := ''
Local cChaveCri  := ''
Local aHeaderITE := {}
Local aColsITE   := {}
Local aTrbIte    := {}
Local aCabCri    := {}
Local aDadCri    := {}
Local aTrbCri    := {}
Private lInverte := .F.
Private cMark   := GetMark()
Private oMark

//Verifica se e uma transacao online                                      

If &(cAliasCab+"->"+cAliasCab+"_COMUNI") <> '1' .Or. Empty(&(cAliasCab+"->"+cAliasCab+"_NRTROL"))
	MsgInfo(STR0599) //"A guia selecionada n„o foi solicitada via transacao online."
	Return
EndIf

If &(cAliasCab+"->"+cAliasCab+"_OPESOL") <> PlsIntPad()
	MsgInfo(STR0618) //"A Operadora Solicitante da transaÁ„o deve ser a mesma da Operadora Padr„o do Sistema."
	Return
EndIf

If &(cAliasCab+"->"+cAliasCab+"_CANCEL") == "1"
	MsgInfo(STR0645)//"N„o È permitido realizar a InsistÍncia de uma guia cancelada." 
	Return
EndIf

//Verifica se ha procedimentos negados para realizar a insistencia        

If cAliasCab == "BEA"
	BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	If BE2->(DbSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
		cChave := BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
		While BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChave .And. !BE2->(Eof())
			If BE2->BE2_STATUS == "0" .And. BE2->BE2_AUDITO == "0"
				aaDD(aItens,{"BE2",	BE2->BE2_CODPAD,;
				BE2->BE2_CODPRO,;
				BE2->BE2_DESPRO,;
				BE2->BE2_QTDPRO,;
				BE2->BE2_NRTROL,;
				BE2->BE2_NRAOPE,;
				BE2->BE2_DATPRO})
			ElseIf BE2->BE2_STATUS <> "0"
				aaDD(aItemLib,{BE2->BE2_NRTROL})
			EndIf
			BE2->(DbSkip())
		EndDo
	EndIf

	//Verifica se ha prorrogacoes                                              

	BQV->(DbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
	If BQV->(DbSeek(xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))

		cChave := BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

		While BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == cChave .And. !BQV->(Eof())
			If BQV->BQV_STATUS == "0" .And. BQV->BQV_AUDITO == "0" 
				aaDD(aItens,{"BQV",	BQV->BQV_CODPAD,;
				BQV->BQV_CODPRO,;
				BQV->BQV_DESPRO,;
				BQV->BQV_QTDPRO,;
				BQV->BQV_NRTROL,;
				BQV->BQV_NRAOPE,;
				BQV->BQV_DATPRO})
			ElseIf BQV->BQV_STATUS <> "0"
				aaDD(aItemLib,{BQV->BQV_NRTROL})
			EndIf
			BQV->(DbSkip())
		EndDo
	EndIf
ElseIf cAliasCab == "BE4"

	BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	If BE2->(DbSeek(xFilial("BE2")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))

		cChave 	:= BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

		While BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChave .And. !BE2->(Eof())
			If BE2->BE2_STATUS == "0" .And. BE2->BE2_AUDITO == "0"
				aaDD(aItens,{"BE2",	BE2->BE2_CODPAD,;
				BE2->BE2_CODPRO,;
				BE2->BE2_DESPRO,;
				BE2->BE2_QTDPRO,;
				BE2->BE2_NRTROL,;
				BE2->BE2_NRAOPE,;
				BE2->BE2_DATPRO})
			ElseIf BE2->BE2_STATUS <> "0"
				aaDD(aItemLib,{BE2->BE2_NRTROL})
			EndIf
			BE2->(DbSkip())
		EndDo
	EndIf

	//Verifica se ha prorrogacoes
	BQV->(DbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
	If BQV->(DbSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))

		cChave := BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

		While BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == cChave .And. !BQV->(Eof())

			If BQV->BQV_STATUS == "0" .And. BQV->BQV_AUDITO == "0"
				aaDD(aItens,{"BQV",	BQV->BQV_CODPAD,;
				BQV->BQV_CODPRO,;
				BQV->BQV_DESPRO,;
				BQV->BQV_QTDPRO,;
				BQV->BQV_NRTROL,;
				BQV->BQV_NRAOPE,;
				BQV->BQV_DATPRO})
			ElseIf BQV->BQV_STATUS <> "0"
				aaDD(aItemLib,{BQV->BQV_NRTROL})
			EndIf
			BQV->(DbSkip())
		EndDo
	EndIf
EndIf

If Len(aItens) >0

	//Monta Estrutura do arquivo temporario

	aadd(aStru01,{"OK"    ,"C",002,0})
	aadd(aStru01,{"CODPAD","C",002,0})
	aadd(aStru01,{"CODPRO","C",016,0})
	aadd(aStru01,{"DESPRO","C",050,0})
	aadd(aStru01,{"QTDPRO","N",007,0})
	aadd(aStru01,{"NRTROL","C",010,0})
	aadd(aStru01,{"NRAOPE","C",010,0})
	aadd(aStru01,{"STATUS","C",002,0})
	aadd(aStru01,{"ALIAS" ,"C",003,0})
	aadd(aStru01,{"DATPRO","D",008,0})

	//Define quais colunas (campos da TTRB) serao exibidas na MsSelect

	aCpoBro	:= {{ "OK"	   ,, ""           ,"@!"},;
	{ "CODPAD" ,, "Tabela"     ,"@!"},;
	{ "CODPRO" ,, "Cod Proc"   ,"@!"},;
	{ "DESPRO" ,, "Descricao"  ,"@!"},;
	{ "QTDPRO" ,, "Quantidade" ,"@E 999,999,999.99"},;
	{ "NRTROL" ,, "Transacao " ,"@!"},;
	{ "NRAOPE" ,, "Trans. Resp " ,"@!"}}


	//Define as cores dos itens de legenda.

	aCores := {}
	aAdd(aCores,{"TTRB->STATUS == '0'","BR_VERMELHO"})
	aAdd(aCores,{"TTRB->STATUS == '1'","BR_VERDE"	})

	//Cria arquivo temporario      		                 				    

	//--< CriaÁ„o do objeto FWTemporaryTable >---
	oTempTTRB := FWTemporaryTable():New( "TTRB" )
	oTempTTRB:SetFields( aStru01 )
	oTempTTRB:AddIndex( "INDTTRB",{ "CODPAD","CODPRO" } )

	if( select( "TTRB" ) > 0 )
		TTRB->( dbCloseArea() )
	endIf

	oTempTTRB:Create()

	//Grava itens encontrados no arquivo temporario                           

	For nCont := 1 to Len(aItens)
		TTRB->(RecLock("TTRB",.T.))
		TTRB->ALIAS  := aItens[nCont][1]
		TTRB->CODPAD := aItens[nCont][2]
		TTRB->CODPRO := aItens[nCont][3]
		TTRB->DESPRO := aItens[nCont][4]
		TTRB->QTDPRO := aItens[nCont][5]
		TTRB->NRTROL := aItens[nCont][6]
		TTRB->NRAOPE := aItens[nCont][7]
		TTRB->DATPRO := aItens[nCont][8]
		TTRB->STATUS := "0"
		TTRB->(MsUnLock())
	Next

	//Cria a Dialog                                                           

	DEFINE MSDIALOG oDlg TITLE "Solicitacao de Insistencia" From 9,0 To 315,800 PIXEL
	DbSelectArea("TTRB")
	DbGotop()

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

	//Cria a MsSelect                                                         
	oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{17,1,150,400},,,,,aCores)
	oMark:bMark := {| | PL90InsDbC()}

	//Exibe a Dialog                                                          
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IIF(PL90InsVal(),(nOpca := 1, oDlg:End()),MsgInfo(STR0506))},{|| oDlg:End()})//"Necess·rio marcar uma transaÁ„o"

	If nOpca == 1

		TTRB->(DbGoTop())
		While !TTRB->(Eof())
			If TTRB->OK == cMark
				cNrTrol    := TTRB->NRTROL
				cAliasTrol := TTRB->ALIAS
				cNrAOpe    := TTRB->NRAOPE
				dDatPro    := TTRB->DATPRO
				Exit
			EndIf
			TTRB->(DbSkip())
		EndDo

		//Verifica se a transacao esta totalmente negada                          
		If AScan(aItemLib,{|x|Alltrim(x[1]) == Alltrim(cNrTrol)}) > 0
			MsgInfo(STR0508+Alltrim(cNrTrol)+STR0509)//"N„o È possÌvel solicitar a insistÍncia pois a transaÁ„o " ## " n„o foi totalmente negada."
			if( select( "TTRB" ) > 0 )
				oTempTTRB:delete()
			endIf
			Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
			Return
		Endif

		//Verifica se a transacao ja foi auditada duas vezes                      
		B0S->(DbSetOrder(1))//B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL+B0S_ENVREC
		If B0S->(DbSeek(xFilial("B0S")+cNrTrol))
			cKeyB0S := xFilial("B0S")+cNrTrol
			While xFilial("B0S")+B0S->B0S_NUMSEQ == cKeyB0S .And. !B0S->(Eof())
				If B0S->B0S_TIPTRA == "00404"
					nQtdAud ++
				EndIf
				B0S->(DbSkip())
			EndDo

			If nQtdAud >= 2
				MsgInfo(STR0510)//"ImpossÌvel de solicitar nova insistÍncia. A transaÁ„o j· foi auditada 2 (duas) vezes."
				if( select( "TTRB" ) > 0 )
					oTempTTRB:delete()
				endIf
				Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
				Return
			EndIf
		EndIf

		/*Nova regra vigÍncia 06/05/2019

		Foi definido o prazo de atÈ 02 (dois) dias ˙teis, apÛs a negativa da transaÁ„o inicial, 
		para a Unimed Executora realizar a transaÁ„o de pedido de insistÍncia.
		Esclarecemos que pedido de insistÍncia ocorre quando a Unimed Origem nega a transaÁ„o
		e a Unimed Executora percebe a necessidade de insistir no pedido de autorizaÁ„o para
		uma nova avaliaÁ„o da Unimed Origem.
		*/
		B0S->(DbSetOrder(1)) //B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL+B0S_ENVREC
		if B0S->(MsSeek(xFilial("B0S")+cNrTrol+"00404"+PlsIntPad()))
			while xFilial("B0S")+cNrTrol+"00404"+PlsIntPad() == B0S->(B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL) .and. !B0S->(Eof()) 
				if B0S->B0S_NUMARQ == "1" //Recupero a data da primeira resposta
					dDatNeg := B0S->B0S_DATPRO
				elseIf B0S->B0S_NUMARQ >= "2" //Verifico se tem mais de uma insistencia
					lPrimSolic := .F.
					exit
				endIf	
				B0S->(DbSkip())
			endDo
		else 
			dDatNeg := dDatPro //&(cAliasCab+"->"+ cAliasCab+"_DATPRO")
		endIf
		
		//So verifico a regra dos 2 uteis para a primeira solicitacao
		if lPrimSolic .And. (Date() - dDatNeg) >= 2 .And. P790DayUti(dDatNeg,2)
			Aviso( STR0120,"O prazo m·ximo para realizar a insistÍncia È de 2 dias ˙teis a partir da data da negativa.",{ STR0146 }, 2 )	//"Atencao" //"O prazo m·ximo para realizar a insistÍncia È de 2 dias ˙teis a partir da data da negativa."
			TTRB->(DbCloseArea())
			Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
			Return
		endIf	

	    //Solicita a mensagem para insistencia                                    
		DEFINE MSDIALOG oDlg2 TITLE STR0223 FROM 008.2,003.3 TO 016,045 OF GetWndDefault() //"Insistencia - Informe a descricao"

		@ 05,10 Say  STR0127  				PIXEL OF oDlg2		 //"Descricao"
		@ 15,10 MsGet cSolRev1 SIZE 150,08	PIXEL OF oDlg2 HASBUTTON
		@ 25,10 MsGet cSolRev2 SIZE 150,08	PIXEL OF oDlg2 HASBUTTON

		TButton():New(40,30, STR0340,,{|| nOpca2 := 1 , IIf(!Empty(cSolRev1),oDlg2:End(),MsgInfo(STR0507)) } , 040, 010 ,,,,.T.) //"ObrigatÛrio informar a descriÁ„o da insistÍncia"
		TButton():New(40,90, STR0329,,{|| nOpca2 := 0, , oDlg2:End() } , 040, 010 ,,,,.T.) //Cancelar

		ACTIVATE MSDIALOG oDlg2 CENTERED

		If nOpca2 == 1

			PlsPtuPut("CUNIDOM",Iif(cAliasCab == "BEA",Substr(BEA->BEA_MATANT,1,4),Substr(BE4->BE4_MATANT,1,4)),aDados)
			PlsPtuPut("CD_TRANS","00302",aDados)
			PlsPtuPut("CD_UNI_ORI",PlsIntPad(),aDados)
			PlsPtuPut("CD_UNI_DES",Iif(cAliasCab == "BEA",Substr(BEA->BEA_MATANT,1,4),Substr(BE4->BE4_MATANT,1,4)),aDados)
			PlsPtuPut("NR_IDENT_O",Strzero(Val(cNrTrol),10),aDados)
			PlsPtuPut("NR_IDENT_D",Strzero(Val(cNrAOpe),10),aDados)
			PlsPtuPut("DS_MENS_LI",cSolRev1+cSolRev2,aDados)
			cTranOri := Strzero(Val(cNrTrol),10)

			aGrvTraPTU := {AllTrim(cTranOri),PlsPtuGet("CD_TRANS",aDados),PlsIntPad(),PlsPtuGet("CD_UNI_DES",aDados), &(cAliasCab+"->"+cAliasCab+"_NOMUSR")}
			MsAguarde( {|| aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,.F.,aGrvTraPTU,,,@cMsgXsdErr ) }, 'Comunicando' , STR0177, .F.) //"Aguarde..."


			//Verifica se houve retorno 00210/00310 (falha na transacao)       		

			If Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310"
				BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
				If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
					Aviso( STR0120, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
				ElseIf PlsPtuGet("CD_MENS_EX",aRetOln[1]) == "4003" 
					PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
					Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
				Else
					Aviso( STR0120,"codigoMensagemExcecao: "+PlsPtuGet("CD_MENS_EX",aRetOln[1])+STR0632,{ STR0146 }, 2 )	//"Atencao" //" - Entre em contato com o administrador do sistema."
				EndIf
				Return

				//Trata o Retorno da Comunicacao											

			ElseIf Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00309" .And. PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "1" .And. Strzero(Val(PlsPtuGet("NR_IDENT_O",aRetOln[1])),10) == cTranOri

				//Itens na solicitacao - SADT    											
				If cAliasTrol == "BE2" .And. cAliasCab == "BEA"

					BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
					If BE2->(DbSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))

						cChave 		:= BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
						cChaveB4A 	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) 

						While BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChave .And. !BE2->(Eof())
							If Alltrim(BE2->BE2_NRTROL) == Alltrim(cNrTrol)
								BE2->(RecLock("BE2",.F.))
								BE2->BE2_STATUS := "0"
								BE2->BE2_AUDITO := "1"
								BE2->BE2_SOLREV := "1"
								BE2->(MsUnLock())
							EndIf
							BE2->(DbSkip())
						EndDo
						BEA->(RecLock("BEA",.F.))
						BEA->BEA_AUDITO := "1"
						BEA->(MsUnLock())
					EndIf

					//Itens na prorrogacao - SADT    											
				ElseIf cAliasTrol == "BQV" .And. cAliasCab == "BEA"

					BQV->(DbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
					If BQV->(DbSeek(xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))

						cChave 		:= BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
						cChaveB4A 	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) 

						While BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == cChave .And. !BQV->(Eof())
							If Alltrim(BQV->BQV_NRTROL) == Alltrim(cNrTrol)
								BQV->(RecLock("BQV",.F.))
								BQV->BQV_STATUS := "0"
								BQV->BQV_AUDITO := "1"
								BQV->BQV_SOLREV := "1"
								BQV->(MsUnLock())
							EndIf
							BQV->(DbSkip())
						EndDo

					EndIf

					//Itens na solicitacao - INTERNACAO    									
				ElseIf cAliasTrol == "BE2" .And. cAliasCab == "BE4"

					BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
					If BE2->(DbSeek(xFilial("BE2")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))

						cChave 		:= BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
						cChaveB4A 	:= BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

						While BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChave .And. !BE2->(Eof())
							If Alltrim(BE2->BE2_NRTROL) == Alltrim(cNrTrol)
								BE2->(RecLock("BE2",.F.))
								BE2->BE2_STATUS := "0"
								BE2->BE2_AUDITO := "1"
								BE2->BE2_SOLREV := "1"
								BE2->(MsUnLock())
							EndIf
							BE2->(DbSkip())
						EndDo

						//Achou os itens BE2, altera cabecalho BE4								

						BE4->(RecLock("BE4",.F.))
						BE4->BE4_AUDITO := "1"
						BE4->(MsUnLock())

						BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
						If BEA->(MsSeek(xFilial("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
							BEA->(RecLock("BEA",.F.))
							BEA->BEA_AUDITO := "1"
							BEA->(MsUnLock())
						EndIf
					EndIf

					BEJ->(DbSetOrder(1))//BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN
					If BEJ->(DbSeek(xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))

						cChave 		:= BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
						cChaveB4A 	:= BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

						While BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == cChave .And. !BEJ->(Eof())
							If Alltrim(BEJ->BEJ_NRTROL) == Alltrim(cNrTrol)
								BEJ->(RecLock("BEJ",.F.))
								BEJ->BEJ_STATUS := "0"
								BEJ->BEJ_AUDITO := "1"
								BEJ->BEJ_SOLREV := "1"
								BEJ->(MsUnLock())
							EndIf
							BEJ->(DbSkip())
						EndDo
					EndIf

					//Itens na prorrogacao - INTERNACAO    									

				ElseIf cAliasTrol == "BQV" .And. cAliasCab == "BE4"
					BQV->(DbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
					If BQV->(DbSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))

						cChave 		:= BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
						cChaveB4A 	:= BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

						While BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == cChave .And. !BQV->(Eof())
							If Alltrim(BQV->BQV_NRTROL) == Alltrim(cNrTrol)
								BQV->(RecLock("BQV",.F.))
								BQV->BQV_STATUS := "0"
								BQV->BQV_AUDITO := "1"
								BQV->BQV_SOLREV := "1"
								BQV->(MsUnLock())
							EndIf
							BQV->(DbSkip())
						EndDo
					EndIf
				EndIf

				//Ajusta cabecalho                       									

				&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")
				&(cAliasCab+"->"+cAliasCab+"_MSG04") := cSolRev1
				If Type("M->"+cAliasCab+"_MSG06") == "C"
					&("M->"+cAliasCab+"_MSG06") := cSolRev2
				Endif
				If cAliasCab == "BEA"
					&(cAliasCab+"->"+cAliasCab+"_STALIB") := "1"
				EndIf
				&(cAliasCab+"->(MsUnlock())")

				//Verifica se ha Anexo e atualiza
				B4A->(DbSetOrder(4))//B4A_FILIAL+B4A_GUIREF
				If B4A->(MsSeek(xFilial("B4A")+cChaveB4A))

					While Alltrim(B4A->B4A_GUIREF) == Alltrim(cChaveB4A) .And. !B4A->(Eof())

						If Alltrim(B4A->B4A_NRTROL) == Alltrim(cNrTrol) 

							B4A->(RecLock("B4A",.F.))     
							B4A->B4A_AUDITO := "1"
							B4A->(MsUnlock())

							B4C->(DbSetOrder(1))//B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN
							If B4C->(MsSeek(xFilial("B4C")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)))
								While B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT) == B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) .And. !B4C->(Eof())
									B4C->(RecLock("B4C",.F.))     
									B4C->B4C_AUDITO := "1"
									B4C->B4C_STATUS := "0"
									B4C->(MsUnlock())

									B4C->(DbSkip())
								EndDo
							EndIf

							Exit
						EndIf

						B4A->(DbSkip())
					EndDo 

				EndIf

				if lP90INB53 .And. cAliasTrol <> "BQV"

					if cAliasCab == 'BE4'
						BEL->(DbSetOrder(1)) //BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN
						cAliItePE := 'BEJ'
						cAliCriPE := 'BEL'
						cChaveIte := 'BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)'
						cChaveCri := 'BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT)'
						cRegInt   := BE4->BE4_REGINT
					else
						BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
						cAliItePE := 'BE2'
						cAliCriPE := 'BEG'
						cChaveIte := 'BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)'
						cChaveCri := 'BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)'
					endIf

					//Eventos
					Store Header cAliItePE TO aHeaderITE For .T.
					Store COLS cAliItePE TO aColsITE FROM aHeaderITE VETTRAB aTrbIte While xFilial(cAliItePE)+cChave == xFilial(cAliItePE)+&(cChaveIte)

					//Criticas
					if &( cAliCriPE+"->( MsSeek( '"+cChave+"' ) )" )
						Store Header cAliCriPE TO aCabCri For .T.
						Store COLS cAliCriPE TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial(cAliCriPE)+cChave == xFilial(cAliCriPE)+&(cChaveCri)
					endIf

					lGerB53 := ExecBlock("P90INB53",.F.,.F., {cAliasCab,(cAliasCab)->(Recno()),aColsITE,aHeaderITE})
					
					if lGerB53
						o790C := PLSA790C():New(.T.)
						o790C:SetAuditoria(.T.,iif(cAliasCab=="BE4",.T.,.F.),.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],cRegInt,cAliCriPE,aColsITE,aHeaderITE,cAliItePE)
						o790C:Destroy()
					endIf

				endIf

				MsgInfo(STR0489)

			//Apresenta critica de Time-out
			ElseIf Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) <> "00309"
				MsgInfo(STR0425+" "+STR0426+" 00309")//"TransaÁ„o de Resposta Incorreta"#"Diferente de"
			
			ElseIf PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "2" .Or. PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "3"
				iif(PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "2",cRespIns:=STR0652,cRespIns:=STR0653) //"2-Guia Inexistente" ## "3-SituaÁ„o Inv·lida"
				Aviso( STR0120,STR0650+cRespIns,{ STR0146 }, 2 )	//"Atencao" //"N„o foi possÌvel processar a solicitaÁ„o, resposta da Operadora Origem: "

			Else
				If !Empty(@cMsgXsdErr)
					MsgInfo(@cMsgXsdErr) 
				Else	
					PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
					Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
				EndIf 
			EndIf
		EndIf
	EndIf

	//Fecha a Area e elimina os arquivos de apoio criados em disco.           

	if( select( "TTRB" ) > 0 )
		oTempTTRB:delete()
	endIf
	Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
Else
	MsgInfo(STR0511)//"N„o foram encontrados procedimentos negados para realizar a insistÍncia"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090Dec
Decurso do prazo

@author  PLS TEAM
@version P11
@since   30/06/2015
/*/
//-------------------------------------------------------------------
function PLSA090Dec(cAliasCab,cTranOri,cOpeOri,cTranDes)
	local lDecurso	:= .f.
	local cTpProc	:= ''
local cRet		:= ''
local dBase 	:= ctod('')
local nDias		:= 0
local nDiasUteis:= 0
local aFeriados	:= {}
local aMatEve	:= {}
Default cTranOri := ""
Default cOpeOri  := ""
Default cTranDes := ""

BR8->( dbSetOrder(1) ) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
BE2->( dbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN

if BE2->(DbSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))

	while !BE2->(Eof()) .and. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

		if BE2->BE2_AUDITO == "1"

			lDecurso := .f.

			if empty(BE2->BE2_TPPROC)
				BR8->( msSeek( xFilial("BR8") + BE2->(BE2_CODPAD+BE2_CODPRO) ) )
				cTpProc := BR8->BR8_TPPROC
			else
				cTpProc := BE2->BE2_TPPROC
			endIf	

			//0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;6=Pacote;7=Gases Medicinais;8=Alugueis;9=Outros
			if cTpProc $ '1,5,0'

				dBase 		:= BE2->BE2_DATPRO
				nDias		:= date()-dBase
				nDiasUteis	:= 0

				if cTpProc $ '1,5' .and. nDias > 10

					aadd( aMatEve,{ BE2->BE2_CODPRO, '2', BE2->BE2_QTDPRO, {}, Alltrim(BE2->BE2_DESPRO), nil, '' ,BE2->BE2_SEQPTU} )

					lDecurso := .t.

				elseIf cTpProc == '0' .and. nDias >= 2

					aFeriados := retFeriados()

					while nDias > 0
						dBase++

						if ascan(aFeriados,dtos(dBase)) == 0 .and. dow(dBase) <> 1 .and. dow(dBase) <> 7
							nDias--
							nDiasUteis++

							if nDiasUteis >= 2
								aadd( aMatEve,{ BE2->BE2_CODPRO, '2', BE2->BE2_QTDPRO, {}, Alltrim(BE2->BE2_DESPRO), nil, '', BE2->BE2_SEQPTU } )
								lDecurso := .t.
								exit
							endIf
						endIf

					endDo

				endIf
			endIf

			//verifica se tem algum procedimento negado critica __aCdCri052.  (3 = Pendente para autorizaÁ„o da empresa)
			if !lDecurso

				if cAliasCab == 'BEA'

					BEG->( dbSetOrder(2) ) //BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN + BEG_CODGLO + BEG_DESGLO
					if BEG->( msSeek(xFilial("BEG") + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + BE2->BE2_SEQUEN + __aCdCri052[1] ) )
						aadd( aMatEve,{ BE2->BE2_CODPRO, '2', BE2->BE2_QTDPRO, {}, Alltrim(BE2->BE2_DESPRO), nil, '', BE2->BE2_SEQPTU } )
					endIf

				elseIf cAliasCab == 'BE4'

					BEL->( dbSetOrder(2) ) //BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN + BEL_CODGLO + BEL_DESGLO
					if BEL->( msSeek(xFilial("BEL") + BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) + BE2->BE2_SEQUEN + __aCdCri052[1] ) )
						aadd( aMatEve,{ BE2->BE2_CODPRO, '2', BE2->BE2_QTDPRO, {}, Alltrim(BE2->BE2_DESPRO), nil, '', BE2->BE2_SEQPTU } )
					endIf

				endIf

			endIf

		endIf

		BE2->(DbSkip())
	endDo

endIf

//Verifica se ha prorrogacoes
BQV->(DbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
if BQV->(DbSeek(xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))

	while !BQV->(Eof()) .and. BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

		if BQV->BQV_AUDITO == "1"

			lDecurso := .f.

			if empty(BQV->BQV_TPPROC)
				BR8->( msSeek( xFilial("BR8") + BQV->(BQV_CODPAD+BQV_CODPRO) ) )
				cTpProc := BR8->BR8_TPPROC
			else
				cTpProc := BQV->BQV_TPPROC
			endIf	

			//0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;6=Pacote;7=Gases Medicinais;8=Alugueis;9=Outros
			if cTpProc $ '1,5,0'

				dBase 		:= BQV->BQV_DATPRO
				nDias		:= date()-dBase
				nDiasUteis	:= 0

				if cTpProc $ '1,5' .and. nDias > 10

					aadd( aMatEve,{ BQV->BQV_CODPRO, '2', BQV->BQV_QTDPRO, {}, Alltrim(BQV->BQV_DESPRO), nil, '', BQV->BQV_SEQPTU } )
					lDecurso := .t.

				elseIf cTpProc == '0' .and. nDias >= 2

					aFeriados := retFeriados()

					while nDias > 0
						dBase++

						if ascan(aFeriados,dtos(dBase)) == 0 .and. dow(dBase) <> 1 .and. dow(dBase) <> 7
							nDias--
							nDiasUteis++

							if nDiasUteis >= 2
								aadd( aMatEve,{ BQV->BQV_CODPRO, '2', BQV->BQV_QTDPRO, {}, Alltrim(BQV->BQV_DESPRO), nil, '', BQV->BQV_SEQPTU } )
								lDecurso := .t.
								exit
							endIf
						endIf

					endDo

				endIf
			endIf

			//verifica se tem algum procedimento negado critica __aCdCri052.  (3 = Pendente para autorizaÁ„o da empresa)
			if !lDecurso

				if cAliasCab == 'BEA'

					BEG->( dbSetOrder(2) ) //BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN + BEG_CODGLO + BEG_DESGLO
					if BEG->( msSeek(xFilial("BEG") + BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + BQV->BQV_SEQUEN + __aCdCri052[1] ) )
						aadd( aMatEve,{ BQV->BQV_CODPRO, '2', BQV->BQV_QTDPRO, {}, Alltrim(BQV->BQV_DESPRO), nil, '', BQV->BQV_SEQPTU } )
					endIf

				elseIf cAliasCab == 'BE4'

					BEL->( dbSetOrder(2) ) //BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN + BEL_CODGLO + BEL_DESGLO
					if BEL->( msSeek(xFilial("BEL") + BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) + BQV->BQV_SEQUEN + __aCdCri052[1] ) )
						aadd( aMatEve,{ BQV->BQV_CODPRO, '2', BQV->BQV_QTDPRO, {}, Alltrim(BQV->BQV_DESPRO), nil, '', BQV->BQV_SEQPTU } )
					endIf

				endIf

			endIf

		endIf

		BQV->(DbSkip())
	endDo

endIf

if len(aMatEve) == 0
	cRet := '3'
endIf	

if cRet <> '3'
	cTranDes := PLSNRAOPE()
	PLSACOMP(cTranOri,cTranDes,'',aMatEve,"00700",cOpeOri,dtos(date()+60),.t.)
	cRet := '1'
	endIf	

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL90InsDbC
Funcao executada ao Marcar/Desmarcar um registro da PLSA090Ins

@author  PLS TEAM
@version P11
@since   30/06/2015
/*/
//-------------------------------------------------------------------
Static Function PL90InsDbC()
	Local cNrTrol := ""

cNrTrol := TTRB->NRTROL

If Marked("OK")
	TTRB->(DbGoTop())
	While !TTRB->(Eof())
		If TTRB->NRTROL == cNrTrol
			RecLock("TTRB",.F.)
			TTRB->OK := cMark
			MsUnLock()
		Else
			RecLock("TTRB",.F.)
			TTRB->OK := ""
			MsUnLock()
		EndIf
		TTRB->(DbSkip())
	EndDo
Else
	TTRB->(DbGoTop())
	While !TTRB->(Eof())
		RecLock("TTRB",.F.)
		TTRB->OK := ""
			MsUnLock()
			TTRB->(DbSkip())
		EndDo
	EndIf
	oMark:oBrowse:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL90InsVal
Valida Ok da tela de insistencia PLSA090Ins

@author  PLS TEAM
@version P11
@since   05.06.12
/*/
//-------------------------------------------------------------------
Static Function PL90InsVal()
	Local lRet := .F.

	TTRB->(DbGoTop())
	While !TTRB->(Eof())
		If !Empty(TTRB->OK)
			lRet := .T.
			Exit
		EndIf
		TTRB->(DbSkip())
	EndDo

Return(lRet)

/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional 

@author  PLS TEAM
@version P11
@since   05.06.12
/*/
Static Function MenuDef(cTipoRot,aCores)

local cInteracao := "PLSAINTE('BE2','02', 'BEA->BEA_OPEMOV' , 'BEA->BEA_ANOAUT' , 'BEA->BEA_MESAUT' , 'BEA->BEA_NUMAUT' )" 
LOCAL lRn395     := GetNewPar("MV_PLRN395","0") == "1"
//Banco de conhecimento por cabeÁalho e item
Local  aRotConh     := {{STR0567 , "PLS090Bco('C')", 0, 0}, ;//"Guia"
{STR0568 , "PLS090Bco('I')", 0, 0}} //"Item"
Local  aRotAnexo     := {{"Radioterapia" , "PLS09AMo1(,,,BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))", 0, 0},; //"Radioterapia"
{"Quimioterapia" ,"PLS09AMo2(,,,BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))" , 0, 0},; //"Quimioterapia"
{"OPME" ,"PLS09AMo3(,,,BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))" , 0, 0}  } //"OPME"


LOCAL aRotina := {	{ STR0001,'AxPesqui'  		, 0 , K_Pesquisar  	, 0 , .F.},; //"Pesquisar"
{ STR0002,'PLSA090Mov'		, 0 , K_Visualizar 	, 0 , Nil},; //"Visualizar"
{ STR0003,'PLSA090Mov'		, 0 , K_Incluir    	, 0 , Nil},; //"Incluir"
{ STR0004,'NAODISP'   		, 0 , K_Alterar    	, 0 , Nil},; //"Nao Disponivel"
{ STR0005,'PLSA090Mov'		, 0 , K_Excluir    	, 0 , Nil},; //"Excluir"
{ STR0409,'PLSA090Mov'		, 0 , K_Incluir    	, 0 , Nil},;  //"Copiar"
{ STR0006,'PLSA090Ima'		, 0 , K_Imprimir   	, 0 , Nil},; //"Imp.Guia"
{ STR0007,'PLSA090Rec(.T.)'	, 0 , K_ImpRec   		, 0 , Nil},; //"Imp. Recibo"
{ STR0008,'PLSA090Bxt'		, 0 , K_Visualizar	, 0 , Nil},; //"Baixar Tit"
{ STR0009,'PLSA090Img'		, 0 , K_Imprimir		, 0 , Nil},; //"Imp.Varias Guias"
{ STR0010,'PLSA090Can(.F.)'	, 0 , K_Visualizar	, 0 , Nil},; //"Cancelar Guia"
{ STR0256, aRotConh			, 0 , 0/*K_Incluir*/		, 0 , Nil},; //"Banco de conhecimento"
{ STR0283,'PLSA090RAS'		, 0 , K_Imprimir		, 0 , Nil},; //"Rastrear"
{ STR0555,cInteracao		, 0 , K_Incluir		, 0 , Nil}} //InteraÁ„o 


//Arotina com opcao para online										    

If getNewPar("MV_PLSSOOL","0") == "1"
	AaDd( aRotina,{ STR0011 ,'PLSA090Mov' , 0 , K_VisOnline , 0 , Nil} )	//"Auto. On-Line"
EndIf

If FunName() $ "PLSA094B"
	AaDd( aRotina,{ "Inc. Anexo Cli.",aRotAnexo 	, 0 , 0 , 0 , Nil} ) //"Inc. Anexo"
EndIf

//EvolunÁıa	da SADT													    

If GetNewPar("MV_PLEVSAD","0") == "1" .And. !FunName() $ "PLSA094B/PLSA094D"
	AaDd( aRotina,{ STR0485 ,'PLSA090Mov' , 0 , K_Evolucao , 0 , Nil} )	//"EvoluÁ„o Sadt"
	AaDd( aRotina,{ STR0554 ,'PL090IEvSA' , 0 , K_IMPEVSA  , 0 , Nil} )	//"Imprime EvoluÁ„o SADT"
Endif

//Nova Insistencia PTU													
IF GetNewPar("MV_PTUVEON","35")>="40" .And. getNewPar("MV_PLSSOOL","0") == "1"
	AaDd( aRotina,{ "InsistÍncia" ,'PLSA090Ins("BEA")' , 0 , K_Alterar , 0 , Nil} )	//"InsistÍncia"
EndIf
//Protocolo de Atendimento
If lRn395
	AaDd( aRotina,{ STR0580 ,'PL90InfPro("BEA")' , 0 , K_Alterar , 0 , Nil} ) //"Informar Protoc."
EndIf

if GetNewPar("MV_PLSHAT","0") == "1"
	aAdd( aRotina, { STR0656 , 'PLSVERARQ(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))'   , 0, Nil} )  //'Anexos HAT'
endIf

If ExistBlock("PLS090M1")
	aPtoEntrada := ExecBlock("PLS090M1",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif

If ExistBlock("PLS090M2")
	aPtoEntrada := ExecBlock("PLS090M2",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif

If ExistBlock("PLS090M3")
	aPtoEntrada := ExecBlock("PLS090M3",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif

If ExistBlock("PLS090M4")
	aRotina := ExecBlock("PLS090M4",.F.,.F., aRotina)
Endif

If ExistBlock("PLS090CR")
	aCores := ExecBlock( "PLS090CR",.F.,.F., aCores )
ElseIf cTipoRot == "2" .And. BEA->(FieldPos("BEA_STALIB")) > 0

	aCores 		:=	{ 	{ "BEA->BEA_STALIB=='2'", 'BR_VERMELHO' },;
	{ "BEA->BEA_STALIB=='1'", 'BR_VERDE'    },;
	{ "BEA->BEA_STALIB=='6'", 'BR_AZUL'    } } 

	aCdCores 	:= 	{ 	{ 'BR_VERDE'    ,STR0285},; //liberaÁ„o em aberto
	{ 'BR_VERMELHO' ,STR0286},;  //liberaÁ„o fechada
	{ 'BR_AZUL' , STR0583}} //"Em analise pela auditoria"

	Aadd(aRotina, { STR0284    	 , "PLSA090LEG"		, 0 , K_Incluir     }) //Legenda
Endif

If cTipoRot == "2" .And. BEA->(FieldPos("BEA_STALIB")) > 0
	Aadd(aRotina, { STR0283    	 , "PLSA090RAS"		, 0 , K_Imprimir     })	 //Rastrear
	Endif

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL090TITCP
Altera Status de AutorizaÁ„o Realizada Via Compra

@author  PLS TEAM
@version P11
@since   21.11.07
/*/
//-------------------------------------------------------------------
Function PL090TITCP(cPrefixo,cNum,cParcela,cTipo,cStatus)

	Local cSql := ""
	Local aArea := GetArea()
	Local lPls := GetNewPar("MV_PLSATIV",.F.)
	Local nRecBEA := BEA->(Recno())
	Local cSitGui := ""

	Default cStatus  := "1"

	#IFDEF TOP
	If lPls
		If PLSALIASEXI("BEA") .and. ChkFile("BEA") .AND. BEA->(FIELDPOS("BEA_CHVSE1")) > 0
			cSql := "SELECT R_E_C_N_O_ RECBEA"
			cSql += " FROM "+BEA->(RetSqlName("BEA"))
			cSql += " WHERE BEA_FILIAL = '"+xFilial("BEA")+"' "
			If lBEANTit
				cSql += " AND ((BEA_PREFIX = '"+cPrefixo+"' "
				cSql += " AND BEA_NUMTIT = '"+cNum+"' "
				cSql += " AND BEA_PARCEL = '"+cParcela+"' "
				cSql += " AND BEA_TIPTIT = '"+cTipo+"') OR "
				cSql += " BEA_CHVSE1 = '" + cPrefixo+cNum+cParcela+cTipo + Space( TamSX3("BEA_CHVSE1")[1] - Len(cPrefixo+cNum+cParcela+cTipo) )+"') "
			Else
				cSql += " AND BEA_CHVSE1 = '" + cPrefixo+cNum+cParcela+cTipo + Space( TamSX3("BEA_CHVSE1")[1] - Len(cPrefixo+cNum+cParcela+cTipo) )+"' "
			EndIf
			cSql += " AND D_E_L_E_T_ = ' ' "

			cSql := ChangeQuery(cSql)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"SE1BEA",.T.,.T.)

			If !SE1BEA->(Eof())
				BEA->(DbGoTo(SE1BEA->RECBEA))

				If BEA->BEA_LIBERA == "1"
					cSitGui := "3" // Bloqueada
				Else
					If cStatus == "5" // Aguardando Liq. Titulo a Receber
						cSitGui := "1" // Ativa
					Else
						cSitGui := Nil
					EndIf
				EndIf

				If Existblock("PL090SGUI")
					/*
					Ponto de Entrada para definir o Status e a Situacao da Guia             
					Retorno:aRet[1] -> Indica Status da Guia. Ex: BE2_STATUS              
							aRet[2] -> Indica a Situacao da Guia. Ex: BD5_SITUAC 
					*/
					aRet := Execblock("PL090SGUI",.F.,.F.,{BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,cStatus})

					If ValType(aRet) == "A"
						PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,aRet[1],,,,,,,,aRet[2])
					Else
						PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,cStatus,,,,,,,,cSitGui)
					EndIf

				Elseif __cTipo <> "2"
					PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,cStatus,,,,,,,,cSitGui)
				EndIf
			EndIf

			SE1BEA->(DbCloseArea())
		EndIf
	EndIf
	#ENDIF

	BEA->(Dbgoto(nRecBEA))
	RestArea(aArea)
    
    If SE1->E1_SALDO == 0 .AND. !IsInCallstack("FA070CAN")
        BED->(dbSetOrder(3))//BED_FILIAL+BED_PREFIX+BED_NUMTIT+BED_PARCEL+BED_TIPTIT
        If BED->(msSeek(xFilial("BED") + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))    
	        RecLock("BED",.F.)
	            BED->BED_FATUR := "3"
	        MsUnlock()
	    	// Atualiza via do cartao do usuario... 		                        
            BA1->(DbSetOrder(2))
	        If BA1->(DbSeek(xFilial("BA1")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO)))
	    	    RecLock("BA1",.F.)
	    	       BA1->BA1_VIACAR := BED->BED_VIACAR
	    	       BA1->BA1_CDIDEN := BED->BED_CDIDEN
	    	       BA1->BA1_DTVLCR := BED->BED_DATVAL
	    	    MsUnLock()
	    	    GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BED->BED_DATVAL)	    	    		        
            EndIf
        EndIF
    EndIF
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBrowseItem
Retorna o objeto browse.... 

@author  PLS TEAM
@version P11
@since   15.01.08
/*/
//-------------------------------------------------------------------
Static Function GetBrowseItem()
Return(oBrwPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBrowseCri
Retorna o objeto browse.... 

@author  PLS TEAM
@version P11
@since   15.01.08
/*/
//-------------------------------------------------------------------
Static Function GetBrowseCri()
Return(oBrwCri)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL090BIO
ValidaÁ„o biometrica  

@author  PLS TEAM
@version P11
@since   07.03.08
/*/
//-------------------------------------------------------------------
Function PL090BIO(cAliasEnc,lValidOpe)
	Default lValidOpe := .T.

	If Empty(&("M->"+cAliasEnc+"_USUARI"))

	Aviso( STR0380, STR0381 , {STR0146} )

Else

	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI")))

	PLSBIOMET("BTS",BA1->BA1_MATVID,lValidOpe,"1")

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlNewNAut
Retorna o numero de uma autorizacao  
cAliasCab - Alias do cabecalho		  		  		  		  		 
cOpeMov   - Operadora		  		  		  		  		  		 
cAnoAut   - Ano da autorizacao		  		  		  		  		 
cMesAut   - Mes da autorizacao		  		  		  		  		 
nOpc      - Opcao clicada no arotina

@author  PLS TEAM
@version P11
@since   15.05.08
/*/
//-------------------------------------------------------------------
Function PlNewNAut(cAliasCab,cOpeMov,cAnoAut,cMesAut,nOpc,cNaoUsado)
	LOCAL cNumAut    		:= ""
LOCAL cFilalCab 		:= xFilial(cAliasCab)
LOCAL nHP        		:= 0
LOCAL aResult    		:= {}
DEFAULT cNaoUsado	    := ""

nHP := PLSAbreSem("P090PROCEDURE.SMF")

aResult := PlProc090(cFilalCab,cOpeMov,cAnoAut,cMesAut)//retorna o proximo numero de uma autorizacao

If valtype(aResult) == 'U' .or. Len(aResult) == 0
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Erro numeraÁ„o PLNUMAUT' , 0, 0, {})
Else
	cNumAut := aResult[1]
Endif

PLSFechaSem(nHP,"P090PROCEDURE.SMF")

Return cNumAut

//-------------------------------------------------------------------
/*/{Protheus.doc} PlProc090
Cria a procedure para busca de proximo numero de autorizaca≥
e retorna o proximo numero

@author  PLS TEAM
@version P11
@since   15.05.08
/*/
//-------------------------------------------------------------------
Function PlProc090(cFilalCab,cOpeMov,cAnoAut,cMesAut)
	LOCAL cUltimo := ""
LOCAL cProximo:= ""

B0C->(dbSelectArea("B0C"))
B0C->(DbSetOrder(1))//B0C_FILIAL+B0C_OPEMOV+B0C_ANOAUT+B0C_MESAUT

If ! B0C->( msSeek(xFilial("B0C") + cOpeMov + cAnoAut + cMesAut))

	cProximo := '00000001'

	B0C->(recLock("B0C",.t.))

	B0C->B0C_FILIAL  := xFilial("B0C")
	B0C->B0C_OPEMOV  := cOpeMov
	B0C->B0C_ANOAUT  := cAnoAut
	B0C->B0C_MESAUT  := cMesAut
	B0C->B0C_ULTIMO  := cProximo
	B0C->B0C_PROXIM  := cProximo

	B0C->(msUnLock())

else

	cUltimo := B0C->B0C_PROXIM

	cProximo:= soma1(cUltimo)

	B0C->(RecLock("B0C",.F.))
	B0C->B0C_ULTIMO := cUltimo
	B0C->B0C_PROXIM := cProximo
	B0C->(MsUnLock())

endIf

/*Adicionado para garantir que a tabela B0C ser· sempre aberta, sem a instruÁ„o abaixo ocorria duplicidade
se houvesse 2 ou mais inclusıes de liberaÁ„o na mesma thread em paralelo com inclus„o em outras threads.*/
	B0C->(DbCloseArea())

Return( { cProximo } )

//-------------------------------------------------------------------
/*/{Protheus.doc} P090RdaEdi
Verifica se existe o RDAEDI

@author  PLS TEAM
@version P11
@since   15.05.08
/*/
//-------------------------------------------------------------------
Function P090RdaEdi()
	LOCAL lRet    := .t.
	LOCAL nRecBAU := BAU->(Recno())

	lRet := ExistCpo("BAU",M->BE1_RDAEDI,1)
	If !lRet
		M->BE1_NOMEDI := SPACE(Len(M->BE1_NOMEDI))
	Endif

	BAU->(DbGoTo(nRecBAU))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCOMVLD
Usada no WHEN dos campos BE2_QTDPRO,BE2_CODPRO e BE2_QTDPRO 

@author  PLS TEAM
@version P11
@since   15.05.08
/*/
//-------------------------------------------------------------------
Function PLSCOMVLD()
	Local lRet 		:= .T.
	Local cArqCab   := PlsRetAut()[2]

	If M->BE2_STATUS == "1" .AND. M->BE2_VLCOMP > 0 .AND. &("M->"+cArqCab+"_PAGATO") = '0'
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL09PESLIB

@description	Pesquisa generica de Liberacoes
@author			David Juan Freire da Silva
@version 		P12
@since   		03.01.2020
/*/
//-------------------------------------------------------------------
function PL09PESLIB(cChave,cTipoPes,aBrwLib,oBrwLib,aVetPad)
	
	LOCAL aArea   	:= GetArea()
	LOCAL cNumLib 	:= ""
	LOCAL cMatUsr 	:= ""
	LOCAL cNomUsr	:= ""
	LOCAL dDatPro	:= nil
	LOCAL cSQL 		:= ""
	
	aBrwLib	:= {}

//-------------------------------------------------------------------
//  monta query
//-------------------------------------------------------------------
	cSQL += "SELECT BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT NUMLIB,"
	cSQL += "BEA_OPEUSR || BEA_CODEMP || BEA_MATRIC || BEA_TIPREG MATUSR,"
	cSQL += "BEA_NOMUSR,"
	cSQL += "BEA_DATPRO"
	cSQL += " FROM " +RetSQLName("BEA")
	cSQL += " WHERE BEA_FILIAL = '"+xfilial("BEA")+"'"
	If cTipoPes == '2' //numero da liberacao
		cChave := StrTran(StrTran(cChave,".",""),"-","")
		cSQL += " AND BEA_OPEMOV = '"+substr(cChave,1,4)+"'"
		cSQL += " AND BEA_ANOAUT = '"+substr(cChave,5,4)+"'"
		cSQL += " AND BEA_MESAUT = '"+substr(cChave,9,2)+"'"
		cSQL += " AND BEA_NUMAUT = '"+substr(cChave,11,8)+"'"
	ElseIf cTipoPes == '3' //matricula
		cChave := StrTran(StrTran(cChave,".",""),"-","")
		cSQL += " AND BEA_OPEUSR = '"+substr(cChave,1,4)+"'"
		cSQL += " AND BEA_CODEMP = '"+substr(cChave,5,4)+"'"
		cSQL += " AND BEA_MATRIC = '"+substr(cChave,9,6)+"'"
		cSQL += " AND BEA_TIPREG = '"+substr(cChave,15,2)+"'"
	ElseIf cTipoPes == '1' //nome
		cSQL += " AND BEA_NOMUSR LIKE '%"+cChave+"%'"
	Endif
	cSQL += " AND BEA_STALIB = '1'"
	cSQL += " AND (BEA_STATUS LIKE '%1%'"
	cSQL += " OR BEA_STATUS LIKE '%2%')"
	cSQL += " AND BEA_ORIGEM = '2'"
	If UPPER( allTrim( FunName() ) ) $ "PLSA094C,PLSA094D"
		cSQL += " AND BEA_TIPO LIKE '%4%'"
	Else
		cSQL += " AND (BEA_TIPO LIKE '%1%' OR BEA_TIPO LIKE '%2%')"
	EndIf
	cSQL += " AND D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY BEA_DATPRO ASC"

//-------------------------------------------------------------------
//  executa a query
//-------------------------------------------------------------------
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"numlib",.F.,.T.)

//-------------------------------------------------------------------
//  looping na area de trabalho
//-------------------------------------------------------------------
	numlib->( DbGoTop() )
	While !numlib->( Eof() )
		cNumLib := transform(numlib->NUMLIB,"@R !!!!.!!!!.!!.!!!!!!!!")
		cMatUsr := transform(numlib->MATUSR,"@R !!!!.!!!!.!!!!!!-!!")
		cNomUsr	:= numlib->BEA_NOMUSR
		dDatPro	:= SToD(numlib->BEA_DATPRO)

		numlib->( AaDd( aBrwLib,{ cNumLib,cMatUsr,cNomUsr,dDatPro} ) )
		numlib->( DbSkip() )
	EndDo

//-------------------------------------------------------------------
//  fecha area
//-------------------------------------------------------------------
	numlib->( DbCloseArea() )
	RestArea(aArea)

//-------------------------------------------------------------------
//  Testa resultado da pesquisa...                                            
//-------------------------------------------------------------------
	If Len(aBrwLib) == 0
		aBrwLib := aClone(aVetPad)
	EndIf

//-------------------------------------------------------------------
//  Atualiza browse...                                                        
//-------------------------------------------------------------------
	oBrwLib:nAt := 1
	oBrwLib:SetArray(aBrwLib)
	oBrwLib:Refresh()
	oBrwLib:SetFocus()

return (.T.)

//-------------------------------------------------------------------
/*/{{Protheus.doc} PLVLDLIB
Validacao da consulta de liberacao

@author 	David Juan Freire da Silva
@version 	P12
@since		03/01/2020

/*/
//-------------------------------------------------------------------

function PLVLDLIB(cNroGui)

	LOCAL oDlg 		:= TDialog():New(0, 0, 315, 800, STR0675,,,,,,,,,.T.) //Pesquisa de LiberaÁıes
	LOCAL oBrwLib	:= TcBrowse():New( 060, 008, 390, 075,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	LOCAL oGetChave	:= NIL
	LOCAL oPanel 	:= NIL
	LOCAL oFont		:= NIL
	LOCAL nOpca 	:= 0
	LOCAL aBrwLib	:= {}
	LOCAL aVetPad	:= { {"","","",CTOD("")} }
	LOCAL nLin	 	:= 1
	LOCAL bOK      	:= { || If(!Empty(cChave),(nLin := oBrwLib:nAt,nOpca := 1,lOk:=.T.,oDlg:End()),Help("",1,"PLSMCON")) }
	LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
	LOCAL bRefresh  := { || If(!Empty(cChave),;
								PL09PESLIB(AllTrim(cChave),Subs(cTipoPes,1,1),aBrwLib,oBrwLib,aVetPad),;
								.T.),;
							If( Empty(aBrwLib[1,1]) .And. !Empty(cChave),;
								.F.,;
								.T.);
						}
	LOCAL cValid    := "{|| Eval(bRefresh) }"
	LOCAL cSetFocus := ""
	LOCAL cBkpCadastro := cCadastro
	LOCAL oChkChk	:= NIL
	LOCAL lChkChk   := .F.
	LOCAL cTipoPes	:= ''
	LOCAL cChave    := Space(40)
	LOCAL lRet 		:= .F.

	aBrwLib := aClone(aVetPad)
	aTipoPes := {'1-Nome Beneficiario','2-Nro da LiberaÁ„o','3-Matricula'}

	oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlg,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
	@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlg PIXEL COLOR CLR_HBLUE
 	@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlg
	 
//-------------------------------------------------------------------
//  Monta Browse...                                                           
//-------------------------------------------------------------------
	oBrwLib:AddColumn(TcColumn():New("Nro LiberaÁ„o",nil,;
		nil,nil,nil,nil,80,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwLib:ACOLUMNS[1]:BDATA := { || aBrwLib[oBrwLib:nAt,1] }

	oBrwLib:AddColumn(TcColumn():New("Mat. Beneficiario",nil,;
		nil,nil,nil,nil,80,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwLib:ACOLUMNS[2]:BDATA := { || aBrwLib[oBrwLib:nAt,2] }

	oBrwLib:AddColumn(TcColumn():New("Nome Beneficiario",nil,;
		nil,nil,nil,nil,150,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwLib:ACOLUMNS[3]:BDATA := { || aBrwLib[oBrwLib:nAt,3] }

	oBrwLib:AddColumn(TcColumn():New("Data",nil,;
		nil,nil,nil,nil,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwLib:ACOLUMNS[4]:BDATA := { || aBrwLib[oBrwLib:nAt,4] }

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT",;
					"BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG",;
					"BEA_NOMUSR",;
					"BEA_DATPRO"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrwLib:aObfuscatedCols := aBls
	endif

//-------------------------------------------------------------------
//  Ativa o Dialogo...                                                        
//-------------------------------------------------------------------
	oBrwLib:SetArray(aBrwLib)
	oBrwLib:BLDBLCLICK := bOK

	If findFunction("PL09PGRef")
		oTipoPes:bLostFocus := { || cSetFocus := "{ || oGetChave:Refresh(),oGetChave:SetFocus(),.T.}", &(cSetFocus) }

		//Inclui bot„o visualizar
		oPanel := TPanel():New(30,0,'', oDlg,, .T., .T.,, ,315,20,.T.,.T. ) 
		oFont := TFont():New('Times New Roman',,-18,.T.)

		@	003, 335 BUTTON STR0002 SIZE 060, 015 ACTION PL09PGRef("BEA", &("oBrwLib:aArray[oBrwLib:nAt, 1]")) OF oPanel PIXEL
	EndIf
	
	cCadastro := STR0675 //Pesquisa de LiberaÁıes

	ACTIVATE MSDIALOG oDlg ON INIT  Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlg,bOK,bCancel,.F.,{}), oPanel:Align:=CONTROL_ALIGN_BOTTOM }) CENTER

	cCadastro := cBkpCadastro

//-------------------------------------------------------------------
//  OK
//-------------------------------------------------------------------
	If nOpca == K_OK
		
		BEA->(DbSetOrder(1))
		BEA->(dbSeek(xFilial("BEA")+strtran(strtran(aBrwLib[nLin,1],'-',''),'.','')))
				
		//Numero da Liberacao
		M->BEA_OPEMOV := substr(strtran(strtran(aBrwLib[nLin,1],'-',''),'.',''),1,4)
		M->BEA_ANOAUT := substr(strtran(strtran(aBrwLib[nLin,1],'-',''),'.',''),5,4)
		M->BEA_MESAUT := substr(strtran(strtran(aBrwLib[nLin,1],'-',''),'.',''),9,2)
		M->BEA_NUMAUT := substr(strtran(strtran(aBrwLib[nLin,1],'-',''),'.',''),11,8)

		//Numero da Matricula
		M->BEA_OPEUSR := substr(strtran(strtran(aBrwLib[nLin,2],'-',''),'.',''),1,4)
		M->BEA_CODEMP := substr(strtran(strtran(aBrwLib[nLin,2],'-',''),'.',''),5,4)
		M->BEA_MATRIC := substr(strtran(strtran(aBrwLib[nLin,2],'-',''),'.',''),9,6)
		M->BEA_TIPREG := substr(strtran(strtran(aBrwLib[nLin,2],'-',''),'.',''),15,2)

		//Nome do Usuario
		M->BEA_NOMUSR := aBrwLib[nLin,3]

		//Data
		M->BEA_DATPRO := aBrwLib[nLin,4]
		
		lRet := .T.
		
	EndIf

return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLDLIB
Validacao da consulta de liberacao  

@author  PLS TEAM
@version P11
@since   05/05/09
/*/
//-------------------------------------------------------------------
/*
function PLVLDLIB()
	LOCAL cTipLib := '1,2'

if UPPER( allTrim( FunName() ) ) $ "PLSA094C,PLSA094D"
	cTipLib := '4'
	endIf

return( eval( {|| BEA->BEA_STALIB == "1" .AND. BEA->BEA_STATUS $ "1,2" .AND. BEA->BEA_TIPO $ cTipLib .AND. BEA->BEA_ORIGEM == "2" } ))
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} PLAJUMAT
Ajusta matriz retirando registro deletado 

@author  PLS TEAM
@version P11
@since   10.09.09
/*/
//-------------------------------------------------------------------
Function PLAJUMAT(aHIte,aDIte,aVIte,cAliasIte,aHCri,aDCri,aVCri,cAliasCri)
	LOCAL nI		 := 0
	LOCAL nPosSel	 := 0
	LOCAL nPosSeC	 := 0
	LOCAL nPosRel	 := 0
	LOCAL nPosRrl	 := 0
	LOCAL nPosDrc	 := 0
	LOCAL nPosPad	 := 0
	LOCAL nPosPro	 := 0
	LOCAL nFor		 := 0
	LOCAL nForH		 := 0
	LOCAL nCont		 := 0
	LOCAL nId		 := 2
	LOCAL cSequen	 := ""
LOCAL aDIteAux   := {}
LOCAL aVIteAux 	 := {}
LOCAL aDCriAux   := {}
LOCAL aVCriAux   := {}
LOCAL aMatAux	 := {}
DEFAULT aHCri	 := {}
DEFAULT aDCri	 := {}
DEFAULT aVCri	 := {}
DEFAULT cAliasCri:= ""

//Inicia o processo de retirada do deletado e ajuste da sequencia			

If Len(aDIte)>0 .And. Len(aVIte)>0


	If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_SEQREL"+"'))") > 0
		nPosSel := PLRETPOS(cAliasIte+"_SEQREL",aHIte,.F.)
	EndIf
	If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_CDPDRC"+"'))") > 0
		nPosDrc := PLRETPOS(cAliasIte+"_CDPDRC",aHIte)
	EndIf
	If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_PROREL"+"'))") > 0
		nPosRel := PLRETPOS(cAliasIte+"_PROREL",aHIte)
	EndIf
	If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_PRPRRL"+"'))") > 0
		nPosRrl := PLRETPOS(cAliasIte+"_PRPRRL",aHIte)
	EndIf

	nPosSeq := PLRETPOS(cAliasIte+"_SEQUEN",aHIte)
	nPosPad := PLRETPOS(cAliasIte+"_CODPAD",aHIte)
	nPosPro := PLRETPOS(cAliasIte+"_CODPRO",aHIte)

	If !Empty(cAliasCri) .And. Len(aHCri)>0
		nPosSeC := PLRETPOS(cAliasCri+"_SEQUEN",aHCri)
	EndIf

	//Dados do item															

	If nPosSeq > 0
		For nFor := 1 To Len(aDIte)

			//Deletado sai															

			If aDIte[nFor,Len(aHIte)+1]
				Loop
			EndIf

			//Atualiza o Item															

			cSequen := aDIte[nFor,nPosSeq]
			If Empty(cSequen)
				Loop
			EndIf

			//Nova matriz ajustando o sequen											

			nCont++
			cSeqNew := StrZero(nCont,TamSX3(cAliasIte+"_SEQUEN")[1])

			//Usada para ajustar o procedimento relacionado							

			AaDd(aMatAux,{aDIte[nFor,nPosSeq]+aDIte[nFor,nPosPad]+aDIte[nFor,nPosPro],aDIte[nFor,nPosPad]+aDIte[nFor,nPosPro],cSeqNew })
			AaDd(aDIteAux,aDIte[nFor])  //AaDd(aDIteAux,aClone(aDIte[nFor]))
			AaDd(aVIteAux,aVIte[nFor]) //AaDd(aVIteAux,aClone(aVIte[nFor]))

			//Atualiza a Sequencia													

			aDIteAux[Len(aDIteAux),nPosSeq] := cSeqNew

			//Criticas																

			If Len(aDCri)>0 .And. Len(aVCri)>0 .And. nPosSeC>0
				nI := aScan(aDCri,{|x| x[nPosSeC] == cSequen })
				If nI>0
					For nForH:=nI To Len(aDCri)
						If aDCri[nForH,nPosSeC] == cSequen
							aDCri[nForH,nPosSeC] := cSeqNew

							AaDd(aDCriAux,aClone(aDCri[nForH]))
							AaDd(aVCriAux,aClone(aVCri[nForH]))
						Else
							Exit
						EndIf
					Next
				EndIf
			EndIf
		Next

		//Verificando procedimentos relacionados									

		If nPosRel>0
			For nFor:=1 To Len(aDIteAux)
				If !Empty( aDIteAux[nFor,nPosRel] )
					If BE2->(FieldPos("BE2_SEQREL")) > 0 .And. nPosSel > 0
						nId		:= 1
						cProRel := aDIteAux[nFor,nPosSel]+aDIteAux[nFor,nPosDrc]+aDIteAux[nFor,nPosRel]
					Else
						nId		:= 2
						cProRel := aDIteAux[nFor,nPosDrc]+aDIteAux[nFor,nPosRel]
					EndIf

					nPosReg	:= aScan( aMatAux,{|x| x[nId] == cProRel } )
					If nPosReg > 0 .And. nPosSel > 0
						If nId == 1
							aDIteAux[nFor,nPosSel] := aMatAux[nPosReg,3]
						EndIf
					Else
						If nPosSel > 0
							aDIteAux[nFor,nPosSel] := ""
						EndIf
						aDIteAux[nFor,nPosDrc] := ""
						aDIteAux[nFor,nPosRel] := ""
						aDIteAux[nFor,nPosRrl] := 0
					EndIf
				EndIf
			Next
		EndIf

		//Retorna a matriz atualizada												

			If Len(aDIteAux) > 0
				aDIte := aClone(aDIteAux)
				aVIte := aClone(aVIteAux)
			EndIf
			If Len(aDCriAux) > 0
				aDCri := aClone(aDCriAux)
				aVCri := aClone(aVCriAux)
			EndIf
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAWEBPAC
Tratamento pacote no portal  
aColsITE   : Array Dados Procedimentos Dados	     	      	
aHeaderITE : Array Procedimentos Dados CabeÁalho	 			
aDadB43    : Array Procedimentos Dados Pacote	 			
aCabB43    : Array Procedimentos CabeÁalho Pacote			
aTrbB43    : Array Trabalho Procedimentos Pacote				
cAliasIte  : Alias Item (Procedimento) 						
lWeb    	  : Atendimento via Portal 	 						
cOpeRda	  : Codigo Operadora Rda							
cCodRda	  : Codigo Rede Atendimento  

@author  PLS TEAM
@version P11
@since   10.09.09
/*/
//-------------------------------------------------------------------
Function PLSAWEBPAC(aColsITE,aHeaderITE,aDadB43,aCabB43,aTrbB43,cAliasIte,cTpGRV,cOpeRda,cCodRda)
	LOCAL nI           := 0
	LOCAL cSequen	   := ''
LOCAL cCodPad	   := ''
LOCAL cCodPro	   := ''
LOCAL dDatPro	   := CtoD("")
DEFAULT cAliasIte  := "BE2"
DEFAULT cTpGrv	   := "1"
DEFAULT cOpeRda	   := PLSINTPAD()
DEFAULT cCodRda	   := ""

Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
Store COLS Blank "B43" TO aDadB43 FROM aCabB43

For nI:=1 To Len(aColsITE)
	cSequen	:= aColsITE[nI,Ascan(aHeaderITE,{|x| AllTrim(x[2]) == "BE2_SEQUEN"})]
	cCodPad := aColsITE[nI,Ascan(aHeaderITE,{|x| AllTrim(x[2]) == "BE2_CODPAD"})]
	cCodPro := aColsITE[nI,Ascan(aHeaderITE,{|x| AllTrim(x[2]) == "BE2_CODPRO"})]
	dDatPro := aColsITE[nI,Ascan(aHeaderITE,{|x| AllTrim(x[2]) == "BE2_DATPRO"})]

		PlAliPac(cCodPad,cCodPro,nil,dDatPro,cAliasIte,aDadB43,aCabB43,aTrbB43,cSequen,cTpGrv,cOpeRda,cCodRda)
	Next nI

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBusCob
Tratamento pacote no portal  
Busca Liberacao para verificar se ja foi cobrado no ato  

@author  PLS TEAM
@version P11
@since   30/03/10
/*/
//-------------------------------------------------------------------
Static Function PLSBusCob(cOpeMov,cAnoAut,cMesAut,cNumAut)
	Local lRet		:= .F.
	Local cSQL 		:= ""
DEFAULT cOpeMov := ""
DEFAULT cAnoAut := ""
DEFAULT cMesAut := ""
DEFAULT cNumAut := ""

cSQL := "SELECT * FROM "+RetSQLName("BEA")
cSQL += " WHERE BEA_FILIAL = '"+xFilial("BEA")+"' AND "
cSQL += " BEA_OPEMOV = '"+cOpeMov+"' AND "
cSQL += " BEA_ANOAUT = '"+cAnoAut+"' AND "
cSQL += " BEA_MESAUT = '"+cMesAut+"' AND "
cSQL += " BEA_NUMAUT = '"+cNumAut+"' AND "
cSQL += " D_E_L_E_T_ = ' '"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYBEA",.F.,.T.)

	While !QRYBEA->(Eof())
		If !Empty(QRYBEA->BEA_NUMTIT)
			lRet := .T.
		EndIf
		QRYBEA->(dbSkip())
	EndDo
	QRYBEA->(dbCloseArea())

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodMot
Retorna o codigo de motivo da critica  

@author  PLS TEAM
@version P11
@since   30/03/10
/*/
//-------------------------------------------------------------------
Function RetCodMot(cCodPad,cCodproc,aHisCri)
	Local cCodMot  	 := ""
Local cObsMot  	 := ""
Local nI   	 	 := 0
Default aHisCri  := {}
Default cCodPad  := ""
Default cCodproc := ""

	For nI:= 1 To Len(aHisCri)
		If Len(aHisCri[1]) > 8
			If !Empty(aHisCri[nI][1]) .And. aHisCri[nI][6] == cCodPad;
			.And. Alltrim(aHisCri[nI][7]) == Alltrim(cCodproc)
				cCodMot := aHisCri[nI][9]
				cObsMot := aHisCri[nI][10]
				Exit
			Endif
		Else
			Exit
		Endif
	Next nI

Return({cCodMot,cObsMot})

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMot
Valida o preenchimento do codigo de motivo. 

@author  PLS TEAM
@version P11
@since   26.06.00
/*/
//-------------------------------------------------------------------
Function VldMot(cCodMot,aHisCri)

	Local lRet 			:= .T.
	Local nI   	 	 	:= 0
	Default aHisCri 	:= {}

	If Empty(cCodMot) .And. BCT->(FieldPos("BCT_MOTOBR")) > 0

	For nI:= 1 To Len(aHisCri)
		If BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+aHisCri[nI][1],"BCT_MOTOBR")) == "1"
				lRet := .F.
				Exit
			EndIf
		Next nI

	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PtuCancEvo
Cancela um complemento de evolucao  

@author  PLS TEAM
@version P11
@since   14.12.10
/*/
//-------------------------------------------------------------------
Static Function PtuCancEvo(cTranOri,cTranCanc,cDescCanc)

	Local aDados := {}
	Local aDadSeq := {}
	Local aRetOln := {}
	Local aGrvTraPTU := {}
	Local lRet := .F.
	Local cNomUsr := ""
	Local cMsgXsdErr := ""
	Local aLog := {}
	Local cVerPTUOnline := "0"+GetNewPar("MV_PTUVEON","70")

	Default cDescCanc := ""

	aDadSeq := PlsGetBSA( cTranOri )
	aDados := aClone(aDadSeq[1])

	PlsPtuPut("CD_TRANS","00311",aDados)
	PlsPtuPut("CD_UNI_ORI",PlsIntPad(),aDados)

	If FunName() == "PLSA092"
		PlsPtuPut("CD_UNI_DES",Substr(BE4->BE4_MATANT,1,4),aDados)
	Else
		PlsPtuPut("CD_UNI_DES",Substr(BEA->BEA_MATANT,1,4),aDados)
	EndIf	

	PlsPtuPut("NR_VERSAO", cVerPTUOnline, aDados)

	PlsPtuPut("NR_IDENT_O",cTranOri ,aDados)
	PlsPtuPut("NR_IDENT_D",cTranCanc,aDados)

	If !Empty(cDescCanc) //PTU Online Versao 5.0 ou superior
		PlsPtuPut("DS_MOTIVO",cDescCanc,aDados)                   //DS_MOTIVO  - DescriÁ„o do Motivo do Cancelamento
	EndIf

	//Comunicacao e tratamento												
	BA1->(DbSetOrder(5))//BA1_FILIAL+BA1_MATANT+BA1_TIPANT
	If BA1->(DbSeek(xFilial("BA1")+PlsPtuGet("CD_UNI_DES",aDados)+PlsPtuGet("USUARIO",aDados)))
		cNomUsr := BA1->BA1_NOMUSR
	Endif

	aGrvTraPTU := {AllTrim(cTranOri),"00311",PlsPtuGet("CD_UNI_DES",aDados),PlsPtuGet("CD_UNI_DES",aDados),cNomUsr}
	MsAguarde( {|| aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,.F.,aGrvTraPTU,,,@cMsgXsdErr ) }, 'Comunicando' , STR0177, .F.) //"Aguarde..."

	If Len(aRetOln) > 0

		//Verifica se houve retorno 00210/00310 (falha na transacao)     			
		If Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310"
			BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
			If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
				Aviso( STR0120, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0146 }, 2 )
			ElseIf PlsPtuGet("CD_MENS_EX",aRetOln[1]) == "4003"
				PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
				Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
			Else
				Aviso( STR0120,"codigoMensagemExcecao: "+PlsPtuGet("CD_MENS_EX",aRetOln[1])+STR0632,{ STR0146 }, 2 )	//"Atencao" //" - Entre em contato com o administrador do sistema."
			EndIf

			//Verifica se foi enviada a transacao correta na resposta       			
		ElseIf PlsPtuGet("CD_TRANS ",aRetOln[1]) <> "00309"

			AaDd(aLog,{STR0425,STR0426+"00309"})//"TransaÁ„o de Resposta Incorreta"#"Diferente de"
			PLSCRIGEN(aLog,{ {STR0243,"@C",90} , {STR0244,"@C",80 } },STR0245) //"Campo"###"Conteudo"###"Resumo da Comunicacao"
			lRet := .F.

			//Trata o Retorno da Comunicacao				 						    
		ElseIf PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "2" .And. Len(aRetOln[2]) == 0
			Aviso( STR0120,STR0490,{ STR0146 }, 2 )  			   			    //"Atencao" //"Guia Inexistente!" //"Ok"
			lRet := .F.

		ElseIf PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "1" .And. Len(aRetOln[2]) == 0

			MsgInfo(STR0489)//"TransaÁ„o concluÌda com sucesso"
			lRet:= .T.

			If GetNewPar("MV_PL395WS","0") == "1" .And. PLSALIASEX("B4J")
				atuProCanc(cTranOri,PlsPtuGet("CD_UNI_DES",aDados),cDescCanc)
			EndIf
		Else
			MsgInfo(STR0178)//"Inconsistencia no RETORNO"
		EndIf
	Else
		If !Empty(cMsgXsdErr)
			MsgInfo(cMsgXsdErr)
		Else	
			PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
			Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
		EndIf	
	EndIf

Return(lRet)

/*/{Protheus.doc} PLSEVOSADT
Gravacao do Item e Criticas da evolucao  

@author  PLS TEAM
@version P11
@since   10.10.06
/*/
Function PLSEVOSADT(cTranOri,aCols,aHeader,aDadEvoCri,aCabEvoCri,cDiagn,lVeioComu,cLotGui,lWeb,aDaSenPro,cTipGui,cObsEvo,cOpeSolPTU,aBQVPTUDif,aDadB6M,aItensB6L)
	LOCAL nFor
	LOCAL nY
	LOCAL nI
	LOCAL nForH
	LOCAL nPos
	LOCAL cMat
	LOCAL cCpoAux
	LOCAL cSenhaPls
	LOCAL cSequen
	LOCAL aHeaderBQV
	LOCAL nQtdDPro	 := 0
	LOCAL nRecBE4	 := 0
	LOCAL lGerSen	 := .T.
	LOCAL lUmAut     := .F.
	LOCAL lAuditoria := .F.
	LOCAL cCpoExc	 := "BQV_TRACON,BQV_SENHA"
LOCAL aChaveNew	 := {}
LOCAL aColsBQV   := {}
LOCAL dDatInt    := dDataBase
LOCAL cMultSen   := GetNewPar("MV_PLSMULT","0")
LOCAL aChaveGen  := {}
LOCAL aAux       := {}
LOCAL aAuxNew    := {}
LOCAL aAuxCol 	 := {}
LOCAL aColsNew	 := {}
LOCAL aStrucBEA  := BEA->(DbStruct())
LOCAL cAliasIte  := "BQV"
LOCAL cAliasCri  := "BQZ"
LOCAL nOpc		 := K_Incluir
LOCAL aEmp       := {}
DEFAULT lWeb	 := .F.
DEFAULT cLotGui	 := ""
DEFAULT aDaSenPro:= {}
DEFAULT cTipGui  := ""
DEFAULT cObsEvo  := ""
DEFAULT cOpeSolPTU := ""
DEFAULT aBQVPTUDif := {}
DEFAULT aDadB6M	   := {}
DEFAULT aItensB6L  := {}

//Monta o header BQV														

Store Header cAliasIte TO aHeaderBQV For .T.

//Verifica															    

cTranOri := cTranOri + Space(TamSx3("BEA_NRTROL")[1] - len(cTranOri))

SIX->( DbSetOrder(1) )
If SIX->( MsSeek("BEAM") )

	BEA->( DbSetOrder(22) )//BEA_FILIAL + BEA_NRTROL

	If !Empty(cTranOri) .And. !BEA->( MsSeek(xFilial("BEA")+cTranOri+cOpeSolPTU) )

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0314+" -> " + cTranOri , 0, 0, {})//"TRANSACAO NAO ENCONTRADA NO CABECALHO"

		Return(.F.)

	Else
		nRecBEA := BEA->(Recno())
		BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT
		If !BQV->( MsSeek( xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
			BE2->( DbSetOrder(1) ) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
			BE2->( MsSeek( xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )

			//Pega a ultima sequencia													

			cSequen := PLSA625Cd("BE2_SEQUEN","BE2",1,"BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)",xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT))
		Else

			//Pega a ultima sequencia													

			cSequen := PLSA625Cd("BQV_SEQUEN","BQV",1,"BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)",xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT))
		EndIf
	Endif
Else
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "INDICE (F) NO BEA NAO EXISTE" , 0, 0, {})
	Return(.F.)
EndIf

//Verificando campos de igualdade internacao x sadt ITENS			   		
plChkHECO('BE2','BQV',@aHeader,@aCols)

//Campos comuns para o cabecalho											
aChaveGen := {}
If BQV->( FieldPos("BQV_DATPRO") ) > 0
	AaDd(aChaveGen,{"BQV_DATPRO",dDataBase})
Else
	AaDd(aChaveGen,{"BQV_DTENTR",dDataBase})
EndIf

AaDd(aChaveGen,{"BQV_DIAGNO",Iif( Empty(cDiagn),"NAO INFORMADO",cDiagn) } )
AaDd(aChaveGen,{"BQV_TIPDIA","1" } )

dbSelectArea('BQV')																	

For nFor := 1 To Len(aStrucBEA)

	//De-Para campos chave BEA -> BQV											
	If aStrucBEA[nFor,1] == "BEA_OPEMOV"
		AaDd(aChaveGen,{"BQV_CODOPE",&( "BEA->" + aStrucBEA[nFor,1] ) } )
	ElseIf aStrucBEA[nFor,1] == "BEA_MESAUT"
		AaDd(aChaveGen,{"BQV_MESINT",&( "BEA->" + aStrucBEA[nFor,1] ) } )
	ElseIf aStrucBEA[nFor,1] == "BEA_ANOAUT"
		AaDd(aChaveGen,{"BQV_ANOINT",&( "BEA->" + aStrucBEA[nFor,1] ) } )
	ElseIf aStrucBEA[nFor,1] == "BEA_NUMAUT"
		AaDd(aChaveGen,{"BQV_NUMINT",&( "BEA->" + aStrucBEA[nFor,1] ) } )
	Else

		cCpoAux := "BQV_"+Subs(aStrucBEA[nFor,1],5,10)

		If (nPos := Ascan(aChaveGen,{|x| x[1] == cCpoAux})) == 0 .And. TYPE("BQV->"+cCpoAux) <> "U" .And. !cCpoAux $ cCpoExc
			AaDd(aChaveGen,{cCpoAux,&( "BEA->" + aStrucBEA[nFor,1] ) } )
		Endif

	EndIf
Next

If BQV->( FieldPos("BQV_OBSER1") ) > 0
	AaDd(aChaveGen,{"BQV_OBSER1",IIF(Empty(cObsEvo),PlsPtuGet("DS_OBSERVA",aDados),cObsEvo) } )
EndIf

If BQV->( FieldPos("BQV_MEMO1") ) > 0
	AaDd(aChaveGen,{"BQV_MEMO1",PlsPtuGet("DS_IND_CLI",aDados) } )
EndIf
//Monta no novo acols da evolucao											

For nFor := 1 To Len(aCols)
	AaDd( aColsBQV,Array( Len(aHeaderBQV)+1) )
Next

//Verificando campos de igualdade internacao x sadt Genericos		   		

For nFor := 1 To Len(aChaveGen)
	nPos := Ascan( aHeaderBQV, {|x| AllTrim( x[2]) == AllTrim(aChaveGen[nFor,1]) } )
	If nPos > 0
		For nY := 1 To Len(aColsBQV)
			aColsBQV[nY,nPos] := aChaveGen[nFor,2]
		Next
	Else
		AaDd(aChaveNew,{aChaveGen[nFor,1],aChaveGen[nFor,2] } )
	EndIf
Next
aChaveGen := aClone(aChaveNew)

//Verificando campos de igualdade internacao x sadt itens			   		

For nFor := 1 To Len(aHeader)
	nPos  := Ascan( aHeaderBQV, {|x| x[2] == aHeader[nFor,2] } )
	If nPos > 0
		For nY := 1 To Len(aCols)
			if Alltrim(aHeaderBQV[nPos,2]) == "BQV_MEMO1"
				aColsBQV[nY,nPos] := PlsPtuGet("DS_IND_CLI",aDados)
			else 
				aColsBQV[nY,nPos] := aCols[nY,nFor]
			endIf
		Next
	EndIf
Next

//Prepara  para poder gravar  internacao x sadt					   		

//Troca o nome e testa se existe										    
plChkHECO('BEG','BQZ',@aCabEvoCri,@aDadEvoCri)

//Adiciona campos que sao especificos somente da BQV
For nFor := 1 To Len(aColsBQV)
	If (nPos := Ascan( aHeaderBQV, {|x| x[2] == "BQV_SEQUEN" } ) ) > 0
		nPosBQVAux := Ascan(aBQVPTUDif,{|x|x[1][2] == aColsBQV[nFor][nPos]})
		If(nPosBQVAux) > 0
			For nY := 2 to len(aBQVPTUDif[nPosBQVAux])//For comeca com 2 porque o primeiro registro sempre sera o BQV_SEQUEN
				If (nPos := Ascan( aHeaderBQV, {|x| x[2] == aBQVPTUDif[nPosBQVAux][nY][1] } ) ) > 0 
					aColsBQV[nFor][nPos] :=  aBQVPTUDif[nPosBQVAux][nY][2]
				EndIf	
			Next		
		EndIf
	EndIf
Next   

//Pega a ultima sequencia do arquivo bqv									
If lVeioComu

	//Ajusta sequencia														
	For nI := 1 To Len(aColsBQV)

		//Ajusta as criticas														
		While Eval( {|| nPos := Ascan( aDadEvoCri,{|x| x[ PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri) ] == aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] } ), nPos > 0} ) .And.;
		Val(aDadEvoCri[nPos,PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri)]) < Val(cSequen)

			aDadEvoCri[nPos,PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri)] := cSequen

		EndDo

		//Ajusta os itens															
		If Val(aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)]) < Val(cSequen)
			aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] := cSequen
		EndIf

		cSequen := StrZero(Val(cSequen)+1,3)

	Next

EndIf

//Grava todos os BD6 e BD7												
For nI := 1 To Len(aColsBQV)

	//Se tiver algum item em auditoria										
	If aColsBQV[nI,PLRETPOS(cAliasIte+"_AUDITO",aHeaderBQV)] == "1"
		lAuditoria := .T.
	EndIf

	//Checagem dos itens														
	If aColsBQV[nI,PLRETPOS(cAliasIte+"_STATUS",aHeaderBQV)] ==  "1"

		//Gera a Senha somente se autorizado 										
		If aColsBQV[nI,PLRETPOS(cAliasIte+"_AUDITO",aHeaderBQV)] == "2"

			If cMultSen == "0"
				cSenhaPls := PLSSenAut(dDatInt)
			ElseIf cMultSen == "1" .And. lGerSen
				cSenhaPls := PLSSenAut(dDatInt)
				lGerSen	  := .F.
			EndIf

			If lVeioComu .And. Empty(aColsBQV[nI,PLRETPOS(cAliasIte+"_NRAOPE",aHeaderBQV)])
				aColsBQV[nI,PLRETPOS(cAliasIte+"_NRAOPE",aHeaderBQV)]:= PLSNRAOPE()
			EndIf

			//Inclui a Senha															

			aColsBQV[nI,PLRETPOS(cAliasIte+"_SENHA",aHeaderBQV)] := cSenhaPls
			AaDd(aDaSenPro,{aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)]+aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPAD",aHeaderBQV)]+aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPRO",aHeaderBQV)],cSenhaPls})

			//Quantidade de diarias autorizadas										

			nQtdDPro += aColsBQV[nI,PLRETPOS(cAliasIte+"_QTDPRO",aHeaderBQV)]
		EndIf
		lUmAut := .T.
	EndIf

	//Pega a Sequencia														

	cSequen := aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)]

	//Faz a gravacao e pega a sequencia										

	cSequen := A090BQVSad(nOpc,cSenhaPls,aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPAD",aHeaderBQV)],aColsBQV[nI,PLRETPOS(cAliasIte+"_CODPRO",aHeaderBQV)],;
	aColsBQV[nI,PLRETPOS(cAliasIte+"_QTDPRO",aHeaderBQV)],aColsBQV[nI,PLRETPOS(cAliasIte+"_HORPRO",aHeaderBQV)],cSequen,;
	aColsBQV[nI,PLRETPOS(cAliasIte+"_NIVAUT",aHeaderBQV)],aColsBQV[nI,PLRETPOS(cAliasIte+"_NIVCRI",aHeaderBQV)],;
	aColsBQV[nI,PLRETPOS(cAliasIte+"_CHVNIV",aHeaderBQV)],cLotGui,aColsBQV[nI,PLRETPOS(cAliasIte+"_DATPRO",aHeaderBQV)])

	//Verifica se a sequencia esta diferente dos itens   						

	If aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] <> cSequen

		//Atualiza a sequencia do BQZ								 			 	

		While Eval( {|| nPos := Ascan( aDadEvoCri,{|x| x[ PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri) ] == aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] } ), nPos > 0} )
			aDadEvoCri[nPos,PLRETPOS(cAliasCri+"_SEQUEN",aCabEvoCri)] := cSequen
		EndDo

		//Atualiza a sequencia do BQV												

		aColsBQV[nI,PLRETPOS(cAliasIte+"_SEQUEN",aHeaderBQV)] := cSequen
	EndIf
Next

//Retorna fase 															

DbselectArea("BD5")
DbSetOrder(1)

If DbSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI))//BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO

	If GetNewPar("MV_PLTHPTU","0") == "1"

		aEmp := GetEmpPtu()

		//Retorna e muda a fase da Guia
		StartJob("U_PLMUDFASPT",GetEnvServer(),.F.,aEmp[1],aEmp[2],BCL->(Recno()),BEA->(Recno()),"BD5","BEA",nil,nil,;
		nil,nil,nil,nil,nil,nil,nil,BD5->(Recno()),BCI->(Recno()),nil,nil,nOpc,nil,nil,.T.,cTipGui)
	Else
		PLSA500RFS("BD5",BD5->(RECNO()),nOpc,,.T.)

		//Muda fase 											     				
		PLSXMUDFAS("BD5","1","",cTipGui,dDataBase,.F.,"3")
	Endif

Endif

//Se for para a auditoria marca todos os procedimentos da transacao		

If BQV->( FieldPos("BQV_OLNAUD") ) > 0
	AaDd(aChaveGen,{"BQV_OLNAUD",Iif(lAuditoria,"1","0")} )
EndIf

//Se tiver um autorizado													

If lUmAut
	AaDd(aChaveGen,{"BQV_TRACON","1" } )
Else
	AaDd(aChaveGen,{"BQV_TRACON","0" } )
EndIf

//Gravacao dos itens da internacao										
PLUPTCOLS("BQV",aColsBQV,aHeaderBQV,{},nOpc,aChaveGen)

If Len(aDadB6M) > 0
	PLSPTUGRV(aDadB6M, {BEA->BEA_OPEMOV, BEA->BEA_ANOAUT, BEA->BEA_MESAUT, BEA->BEA_NUMAUT},"B6M")
EndIf

If Len(aItensB6L) > 0
	PLSPTUGRV(aItensB6L, {BEA->BEA_OPEMOV, BEA->BEA_ANOAUT, BEA->BEA_MESAUT, BEA->BEA_NUMAUT},"B6L")
EndIf

//Para testar se os campos da critica beg existem no bel gravacao das criticas
If Len(aDadEvoCri) > 0

	//Para nao gravar registro em branco											
	For nI := 1 To Len(aDadEvoCri)
		If Empty( aDadEvoCri[ nI,PLRETPOS( "BQZ_DESGLO",aCabEvoCri ) ] )
			aDadEvoCri[ nI,PLRETPOS( "BQZ_SEQUEN",aCabEvoCri ) ] := ""
		EndIF
	Next

	//Gravacao																	
	aChaveGen := {}
	aadd(aChaveGen,{"BQZ_CODOPE",BEA->BEA_OPEMOV})
	aadd(aChaveGen,{"BQZ_ANOINT",BEA->BEA_ANOAUT})
	aadd(aChaveGen,{"BQZ_MESINT",BEA->BEA_MESAUT})
	aadd(aChaveGen,{"BQZ_NUMINT",BEA->BEA_NUMAUT})

	//Gravacao das Criticas													
	PLUPTCOLS("BQZ",aDadEvoCri,aCabEvoCri,{},nOpc,aChaveGen,.T.)

EndIf

Return(.T.)

/*/{Protheus.doc} A090BQVSad
Espelha um registro do BQV na guia... 

@author  PLS TEAM
@version P11
@since   28.08.06
/*/
Function A090BQVSad(nOpc,cSenhaPls,cCodPad,cCodPro,nQTDPRO,cHRENTR,cSeqAtu,cNivAut,cNivCri,cChvNiv,cLotGui,dDataPro)
	LOCAL nForCpo
	LOCAL cField
	LOCAL aCodTab
	LOCAL cOpeInt
	LOCAL cTipGrv
	LOCAL cTipRda
	LOCAL cTipInt
	LOCAL cTipUsr
	LOCAL cAteAMB
	LOCAL cDesLoc
	LOCAL cEndLoc
	LOCAL cTipGui
	LOCAL cCodPla
	LOCAL cOpeOri
	LOCAL cOpeAut
	LOCAL cSituac
	LOCAL lIntAlt
	LOCAL cGrpEmpInt    := GetNewPar("MV_PLSGEIN","0050")
LOCAL aAreaBEA 		:= BEA->(GetArea())
LOCAL cChaveSadt 	:= BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)
LOCAL cSequen   	:= "001"
LOCAL nOrdBD6  		:= BD6->(IndexOrd())
LOCAL nRecBD6   	:= BD6->(Recno())
LOCAL aCposPad  	:= BEA->(DbStruct())
DEFAULT cSenhaPls 	:= ''
DEFAULT cNivAut		:= ""
DEFAULT cNivCri     := ""
DEFAULT cChvNiv     := ""
DEFAULT cLotGui		:= ""

BD6->(DbSetOrder(1))
BD6->(MsSeek(xFilial("BD6")+cChaveSadt+Replicate("Z",Len(BD6->BD6_SEQUEN)),.T.))
BD6->(DbSkip(-1))

If BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) <> xFilial("BD6")+cChaveSadt
	cSequen := StrZero(1,Len(BD6->BD6_SEQUEN))
Else
	cSequen := SOMA1(BD6->BD6_SEQUEN)
Endif

//Indice																	

BQV->( DbSetOrder(1) )//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
lIntAlt := !BQV->( MsSeek( xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)+cSeqAtu ) )



//Posiciona no BD6														

BD6->( DbSetOrder(1) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
If lIntAlt

	//Atualiza a sequencia													

	If cSequen > cSeqAtu
		cSeqAtu := cSequen
	EndIf
	BD6->( MsSeek(xFilial("BD6")+cChaveSadt) )
Else
	If !BD6->( MsSeek(xFilial("BD6")+cChaveSadt+cSeqAtu+cCodPad+cCodPro) )
		BD6->( MsSeek(xFilial("BD6")+cChaveSadt) )
		lIntAlt := .T.
	EndIf
EndIf

//Atualiza variaveis														

cOpeAut := BD6->BD6_CODOPE
cOpeInt := BD6->BD6_OPEINT
cTipGrv := BD6->BD6_TPGRV
cTipRda := BD6->BD6_TIPRDA

cTipUsr := BD6->BD6_TIPUSR
cTipInt := BD6->BD6_TIPINT
cInterc := BD6->BD6_INTERC
cModCob	:= BD6->BD6_MODCOB

cAteAMB := BD6->BD6_ATEAMB
cDesLoc := BD6->BD6_DESLOC
cEndLoc := BD6->BD6_ENDLOC
cTipGui := BD6->BD6_TIPGUI
cCodPla := BD6->BD6_CODPLA
cSituac := BD6->BD6_SITUAC

//Indice e posiciona no bcl											    

BCL->(DbSetOrder(1))
BCL->(MsSeek(xFilial("BCL")+cOpeAut+cTipGui))

//Indice e posiciona no br8												

BR8->(DbSetOrder(1))
BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))

//Indice e posiciona no bau												

BAU->(DbSetOrder(1))
BAU->(DbSeek(xFilial("BAU")+BEA->BEA_CODRDA))

//Indice e posiciona no ba3												

BA3->(DbSetOrder(1))
BA3->(DbSeek(xFilial("BA3")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC)))

//Indice e posiciona no ba1												

BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)))

//Indice e posiciona no bg9												

BG9->(DbSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))

If BG9->BG9_TIPO == "2"
	BT5->(DbSetOrder(1))
	BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))
	BQC->(DbSetOrder(1))
	BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
Endif

//plsretab																
aCodTab := PLSRETTAB(cCodPad,cCodPro,BEA->BEA_DATPRO,;
BEA->BEA_OPEMOV,BEA->BEA_CODRDA,BEA->BEA_CODESP,"",BEA->(BEA_CODLOC+BEA_LOCAL),;
BD6->BD6_DATPRO,,BD6->BD6_OPEORI,BD6->BD6_CODPLA,"1","1",,IIF(!Empty(BEA->BEA_TIPPRE),BEA->BEA_TIPPRE,nil))

//Limpa variavel de memoria												

M->BQV_CDNV01 := ""
M->BQV_CDNV02 := ""
M->BQV_CDNV03 := ""
M->BQV_CDNV04 := ""

//Inclui no bd6															

BD6->(RecLock("BD6",lIntAlt))

BD6->BD6_FILIAL := xFilial("BD6")

For nForCpo := 1 To Len(aCposPad)
	cField := StrTran(aCposPad[nForCpo,1],"BEA","BD6")
	If ! ("FILIAL" $ cField)
		If BD6->(FieldPos(cField)) > 0
			&("BD6->"+cField) := &("BEA->"+aCposPad[nForCpo,1])
		Endif
	Endif
Next

//gatniv																	
PLSGatNiv(cCodPad,cCodPro,"BQV")

//continua a gravacao													    
BD6->BD6_CODOPE := BEA->BEA_OPEMOV
BD6->BD6_NUMERO := BEA->BEA_NUMGUI
BD6->BD6_SITUAC := cSituac

BD6->BD6_SEQUEN := cSeqAtu
BD6->BD6_CODPAD := cCodPad
BD6->BD6_CODPRO := cCodPro
BD6->BD6_DESPRO := BR8->BR8_DESCRI
BD6->BD6_QTDPRO := nQTDPRO
BD6->BD6_PROCCI := If(BR8->BR8_TIPEVE$"2,3","1","0")
BD6->BD6_OPEINT := cOpeInt
BD6->BD6_TPGRV  := cTipGrv
BD6->BD6_CPFRDA := BAU->BAU_CPFCGC
BD6->BD6_TIPRDA := cTipRda
BD6->BD6_HORPRO := cHRENTR

If Valtype(dDataPro) <> "U"
	BD6->BD6_DATPRO := dDataPro
EndIf

BD6->BD6_CDNV01 := M->BQV_CDNV01
BD6->BD6_CDNV02 := M->BQV_CDNV02
BD6->BD6_CDNV03 := M->BQV_CDNV03
BD6->BD6_CDNV04 := M->BQV_CDNV04
BD6->BD6_NIVEL  := BR8->BR8_NIVEL

If BD6->(FieldPos("BD6_LOTGUI")) > 0
	BD6->BD6_LOTGUI := cLotGui
EndIf

If aCodTab[1]
	BD6->BD6_CODTAB := aCodTab[3]
	BD6->BD6_ALIATB := aCodTab[4]
Endif

BD6->BD6_MODCOB := cModCob
BD6->BD6_TIPUSR := cTipUsr
BD6->BD6_INTERC := cInterc
BD6->BD6_TIPINT := cTipInt

BD6->BD6_OPEORI := BA1->BA1_OPEORI
BD6->BD6_NIVAUT := cNivAut
BD6->BD6_NIVCRI := cNivCri
BD6->BD6_CHVNIV := cChvNiv
BD6->BD6_ATEAMB := cAteAMB
BD6->BD6_DESLOC := cDesLoc
BD6->BD6_ENDLOC := cEndLoc
BD6->BD6_TIPGUI := cTipGui
BD6->BD6_CODPLA := cCodPla

If BD6->(FieldPos("BD6_SENEVO")) > 0
	BD6->BD6_SENEVO  := cSenhaPls
Endif

PLBLOPC("BD6", .f., nil, nil, .t., .f., .f.)

BD6->BD6_INCAUT := ""
BD6->BD6_QTDPRO := nQTDPRO

BD6->BD6_SEQIMP := ""
BD6->BD6_FASE   := '1'

BD6->(MsUnLock())

//Inclui o bd7															

If lIntAlt
	PLS720IBD7("0",BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
	BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",;
		BD6->BD6_SEQUEN,BCL->BCL_CDORIT,cTipGui,BD6->BD6_DATPRO,nil,nil)
	EndIf

	RestArea(aAreaBEA)

Return(cSeqAtu)

/*/{Protheus.doc} PLGRVORDSE
Grava o recebimento da Ordem de Servico PTU 

@author  PLS TEAM
@version P11
@since    26.10.11
/*/
Function PLGRVORDSE(aCab,aIte)
	LOCAL nFor		:= 0
	LOCAL cCodPad 	:= SubStr( GETMV("MV_PLSTBPD") ,1,2)
LOCAL cVerPtuOn := GetNewPar("MV_PTUVEON","40")
LOCAL lRecTab	:= .T.
LOCAL cCdUniBen := ""
LOCAL cNrIdentB := ""
LOCAL cCdUni    := ""
LOCAL cIdBenef  := ""
LOCAL cCdUniReq := ""
LOCAL cCdUniExe := ""
LOCAL cNrIdentS := ""
LOCAL cCdUniSol := ""
Local lPTUOn90 := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"

DEFAULT aCab  := {}
DEFAULT aIte  := {}

//Campos de Operadora e Transacao
cCdUniBen := Strzero(Val(PlsPtuGet("CD_UNI_BEN",aDados)),4)  
cNrIdentB := Strzero(Val(PlsPtuGet("NR_IDENT_B",aDados)),10)   
cCdUni    := Strzero(Val(PlsPtuGet("CD_UNI",aDados)),4)  
cIdBenef  := Strzero(Val(PlsPtuGet("ID_BENEF",aDados)),13)        
cCdUniReq := Strzero(Val(PlsPtuGet("CD_UNI_REQ",aDados)),4)   
cCdUniExe := Strzero(Val(PlsPtuGet("CD_UNI_EXE",aDados)),4)       
cNrIdentS := Strzero(Val(PlsPtuGet("NR_IDENT_S",aDados)),10)  
cCdUniSol := Strzero(Val(PlsPtuGet("CD_UNI_SOL",aDados)),4)

If PLSALIASEX("B0U") .And. PLSALIASEX("B0V")

	B0U->(DbSetorder(1))
	If B0U->(DbSeek(xFilial("B0U")+cCdUniBen+cNrIdentB+cCdUni+cIdBenef))
		lRecTab := .F.
	Endif

	BAQ->(DbSetorder(5))//BAQ_FILIAL+BAQ_INTERC

	//Grava cabecalho para posterior pesquisa									

	B0U->(RecLock("B0U",lRecTab))
	B0U->B0U_FILIAL := xFilial("B0U")
	B0U->B0U_NOMUSR := PlsPtuGet("NM_BENEF",aDados)
	B0U->B0U_NUMSEQ := cNrIdentB
	B0U->B0U_MATRIC := cCdUni+cIdBenef
	B0U->B0U_OPEDES := cCdUniBen
	B0U->B0U_OPESOL := cCdUniExe
	If !lPTUOn90
		B0U->B0U_VIACAR := Val(PlsPtuGet("NR_VIA_CAR",aDados))
	EndIf
	B0U->B0U_DTPROV := Stod(PlsPtuGet("DT_PROV_AD",aDados))
	B0U->B0U_VALSEN := Stod(PlsPtuGet("DT_VALIDAD",aDados))
	B0U->B0U_OBSERV := PlsPtuGet("DS_OBSERVA",aDados)
	B0U->B0U_INDCLI := PlsPtuGet("DS_IND_CLI",aDados)
	B0U->B0U_CID    := PlsPtuGet("CD_CID",aDados)
	B0U->B0U_URGENC := PlsPtuGet("ID_URG_EME",aDados)
	B0U->B0U_UNPREQ := cCdUniReq // CÛdigo da Unimed na qual o Prestador Requisitante esta cadastrado

	B0U->B0U_CDPRES := PlsPtuGet("CD_PRE_REQ",aDados) //CÛdigo do Prestador Requisitante
	B0U->B0U_CDUNIP := PlsPtuGet("CD_UNI_PRE",aDados) // CÛdigo da Unimed do Prestador de ServiÁo
	B0U->B0U_CODPRE := PlsPtuGet("CD_PREST",aDados) //CÛdigo do Prestador.

	If !lPTUOn90
		If BAQ->(DbSeek(xFilial("BAQ")+PlsPtuGet("CD_ESPEC",aDados)))
			B0U->B0U_CODESP := BAQ->BAQ_CODESP
		EndIf
	EndIf

	B0U->B0U_TRASOL := cNrIdentS//N˙mero da transaÁ„o da Unimed Solicitante
	B0U->B0U_CDUNSO := cCdUniSol//CÛdigo da Unimed Solicitante

	If !lPTUOn90
		B0U->B0U_NOMPRE := PlsPtuGet("NM_PREST"  ,aDados)//Nome do Prestador.
		B0U->B0U_CODSIG := PlsPtuGet("SG_CONS_PR",aDados)//Sigla do Conselho Profissional
		B0U->B0U_NUMCR  := PlsPtuGet("NR_CONS_PR",aDados)//N˙mero do Conseho Profissional.
		B0U->B0U_ESTADO := PlsPtuGet("UF_CONS_PR",aDados)//CÛdigo da Unidade Federativa do conselho.
	EndIf

	B0U->(MsUnLock())

	BR8->(DbSetorder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
	For nFor := 1 to len(aIte)

		B0V->(DbSetorder(1))
		If B0V->(DbSeek(xFilial("B0V")+cCdUniBen+cNrIdentB+cValToChar(Strzero(nFor,3))))
			lRecTab := .F.
		Else
			lRecTab := .T.	
		Endif

		B0V->(RecLock("B0V",lRecTab))
		B0V->B0V_FILIAL := xFilial("B0V")
		B0V->B0V_SEQUEN := cValToChar(Strzero(nFor,3))
		B0V->B0V_NUMSEQ := cNrIdentB
		B0V->B0V_OPEDES := cCdUniBen
		B0V->B0V_OPESOL := cCdUniExe
		B0V->B0V_CODPAD := cCodPad
		B0V->B0V_CODPRO := PlsPtuGet("CD_SERVICO",aIte[nFor])

		If ! Empty(PlsPtuGet("DS_SERVICO",aIte[nFor]) )
			B0V->B0V_DESPRO := PlsPtuGet("DS_SERVICO",aIte[nFor])
		Else
			If BR8->(DbSeek(xFilial("BR8")+cCodPad+PlsPtuGet("CD_SERVICO",aIte[nFor])))
				B0V->B0V_DESPRO := BR8->BR8_DESCRI
			EndIf
		Endif

		B0V->B0V_QTDPRO := Val(PlsPtuGet("QT_AUTORIZ",aIte[nFor]))

			B0V->(MsUnLock())
		Next
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} P090PTUGEN
Verifica se foi digitado um codigo de mat/med generico Ptu

@author  PLS TEAM
@version P11
@since    28.08.06
/*/
//-------------------------------------------------------------------
Function P090PTUGEN(cOpe)
LOCAL lRet := .F.
LOCAL cCodPro := ""
LOCAL cNrtrol := ""
LOCAL lPlsUni := AllTrim(GetNewPar("MV_PLSUNI","1")) == "1"
DEFAULT cOpe      := "1"

if lPlsUni
	If Type("M->BE2_CODPRO") == "C"
		cCodPro := M->BE2_CODPRO
		cNrtrol := M->BE2_NRTROL
		If Empty(M->BE2_CODPRO)
			Return(.F.)
		EndIf
	ElseIf Type("M->BEJ_CODPRO") == "C"
		cCodPro := M->BEJ_CODPRO
		cNrtrol := M->BEJ_NRTROL
		If Empty(M->BEJ_CODPRO)
			Return(.F.)
		EndIf
	ElseIf Type("M->BQV_CODPRO") == "C"
		cCodPro := M->BQV_CODPRO
		cNrtrol := M->BQV_NRTROL
		If Empty(M->BQV_CODPRO)
			Return(.F.)
		EndIf
	ElseIf Type("M->B4C_CODPRO") == "C"
		cCodPro := M->B4C_CODPRO
		cNrtrol := M->B4C_NRTROL
		If Empty(M->B4C_CODPRO)
			Return(.F.)
		EndIf
	EndIf

	Do Case
		Case cOpe == "1"
			If Alltrim(cCodPro) $ Alltrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) .And. ;
				(Val(cNrtrol) == 0 .Or. Empty(cNrtrol))
				
				lRet := .T.
			EndIf
		Case cOpe == "2"
			If Alltrim(cCodPro) $ Alltrim(__cCodOpmGen+"-"+__cCodMatGen+"-"+__cCodMedGen) .And. ;
				(Val(cNrtrol) == 0 .Or. Empty(cNrtrol))

				lRet := .T.
			EndIf
	EndCase
endIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRETPAP
Retorna se a PEG necessita da Guia de papel. 

@author  PLS TEAM
@version P11
@since    17.01.11
/*/
//-------------------------------------------------------------------
Function PLSRETPAP(cOperadora,cCodRda,cTipGuia)
	Local lRet 			:= .T.
	Local lNecPapRda    := .F.
	Local lNecPapGuia   := .F.
	Default cOperadora 	:= PLSINTPAD()

	If !Empty(cCodRda) .And. BAU->(FieldPos("BAU_GUIPAP")) > 0
	BAU->(dbSetOrder(1)) //BAU_FILIAL, BAU_CODIGO
	If BAU->(MsSeek(xFilial("BAU")+cCodRda))
		lNecPapRda := IIF(BAU->BAU_GUIPAP == '1',.T.,.F.)
	Endif
Endif
If !Empty(cTipGuia) .And. BCL->(FieldPos("BCL_GUIPAP")) > 0
	BCL->(dbSetOrder(1)) //BCL_FILIAL, BCL_CODOPE, BCL_TIPGUI
	If BCL->(MsSeek(xFilial("BCL")+cOperadora+cTipGuia))
		lNecPapGuia := IIF(BCL->BCL_GUIPAP == '1',.T.,.F.)
		Endif
	Endif

	lRet := lNecPapRda .And. lNecPapGuia

Return(lRet)

/*/{Protheus.doc} PLRetGrauPa
Tratamento do campo 45a 

@author  PLS TEAM
@version P11
@since    20/01/11
/*/
Function PLRetGrauPa()
LOCAL aArea		:= GetArea()
LOCAL aUnidades := PLSXBKC()
LOCAL lRet		:= .F.
LOCAL cAlias    := ""
LOCAL cChave    := ""
LOCAL cChaveBD7 := ""

cAlias 		:= "BEA"
cChave 		:= M->BE1_NUMLIB
cChaveBD7 	:= BEA->(BEA_OPEPEG+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)
BEA->(dbsetOrder(1))

If &(cAlias)->( MsSeek(xFilial(cAlias)+cChave) )
	BD7->( DbSetOrder(1) )
	If BD7->(MsSeek(xFilial("BD7")+cChaveBD7))
		While !BD7->(Eof()) .And. BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV) == cChaveBD7
			If BD7->BD7_CODTPA == BWT->BWT_CODPAR .And. BD7->BD7_SALDO > 0 .And. Empty(BD7->BD7_MOTBLO).And. Ascan(aUnidades,{|x| Alltrim(x[2]) == AllTrim(BD7->BD7_CODUNM) } ) > 0
				lRet := .T.
				Exit
			EndIf
			BD7->( DbSkip() )
		EndDo
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} PLSAtuLib
Atualiza saldo e status da liberaÁ„o

@author  PLS TEAM
@version P11
@since    20/01/11
/*/
Function PLSAtuLib(cNumLib,cSequen,cCodPad,cCodPro,nQtdPro,aPartic,lInterna,lGuiHoRe,lAuditoria, nIncre, cDente, cFace) 
	LOCAL aArea     := getArea()
	LOCAL aAreaBE2  := BE2->(getArea())
	LOCAL aAreaBE4  := BE4->(getArea())
	LOCAL aAreaBD5  := BD5->(getArea())
	LOCAL aAreaBEA  := BEA->(getArea())
	LOCAL nMaiorSld	:= 0
	LOCAL nIdx		:= 1
	LOCAL cStaLib	:= ""
local cCompChv	:= ""
LOCAL lFound	:= .f.
LOCAL aMatCri	:= {}
LOCAL aMatBD7	:= {}
Local cCompchvOd	:= ""

DEFAULT cSequen		:= ""
DEFAULT cCodPad 	:= ""
DEFAULT cCodPro 	:= ""
DEFAULT nQtdPro 	:= 0
DEFAULT aPartic 	:= {}
DEFAULT lInterna	:= .f.
DEFAULT lGuiHoRe	:= .f.
DEFAULT nIncre		:= 0
Default lAuditoria  := .F.
Default cDente	:= ""
Default cFace		:= ""
//Posiciona na guia de liberacao de sadt ou internacao
if lInterna .or. lGuiHoRe
	BEA->( dbSetOrder(6) )//BEA_FILIAL+BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT+DTOS(BEA_DATPRO)+BEA_HORPRO
else
	BEA->( dbSetOrder(1) )//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
endIf

if !Empty(cNumLib )
	lFound := BEA->( msSeek( xFilial("BEA") + cNumLib ) )

	if ! lFound

		BEA->( dbSetOrder(12) ) //BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV
		lFound := BEA->( MsSeek( xFilial("BEA") + cNumLib ) )

	endIf
endIf
//Posiciona na guia de liberacao
If lFound

	nIdx 	 := 6 //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT
	cCompChv := cCodPad + cCodPro

	If ! empTy(cDente)
		cCompchvOd += AllTrim(cDente)
		If ! empTy(cFace)
			cCompchvOd += AllTrim(cFace)
		EndIf
	EndIf

	cNumLib  := BEA->( BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT )

	if lFound

		If ! lInterna .and. ! lGuiHoRe .and. nIncre == 0

			BE2->( DbSetOrder(nIdx) )//BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT
			if BE2->(MsSeek(xFilial("BE2")+ BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT ) + cCompChv ))

				while ! BE2->(Eof()) .and. BEA->(BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT ) == ;
				BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT )

					If BE2->BE2_STATUS == "1" .and. alltrim(BE2->(BE2_CODPAD+BE2_CODPRO)) == alltrim(cCompChv) .and. (empTy(cCompchvOd) .OR. AllTrim(BE2->(BE2_DENREG)) + Alltrim(BE2->(BE2_FADENT)) == cCompchvOd)

						nMaiorSld += BE2->BE2_SALDO
						nMaiorSld -= nQtdPro
						nQtdPro	  := 0

					endIf

					BE2->(DbSkip())
				enddo

				If nMaiorSld < 0 
					nMaiorSld := 0
				endIf

			endIf

		endIf

		//Status do item!!
		cStaLib := Iif(nMaiorSld <= 0,"2","1")

		//Atualiza saldo do bd6 e be2 e o status do item
		PLSATUSS(nil,iIf(nIncre == 0,.t.,.f.),nil,nMaiorSld,@cStaLib,(lInterna .or. lGuiHoRe),cNumLib + cCompChv, nIdx, nil,nil,nil, nIncre, cCodPad, cCodPro, cDente, cFace)

		//Ajusta o status do cabecalho
		if ! lInterna .and. ! lGuiHoRe

			if lAuditoria 
				cStaLib := "6"

				//confirma se tem saldo na guia pra atualizar certo o cabeÁalho	
			elseIf BE2->( msSeek( xFilial("BE2") + cNumLib ) )

				while ! BE2->(eof()) .and. xFilial("BE2") + cNumLib == BE2->( BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT )

					If BE2->BE2_SALDO > 0

						cStaLib := "1"
						exit
					endIf

					BE2->(DbSkip())
				endDo

			endIf 

			if PLIBAUD(@cNumLib,.T.) 
				cStaLib := "6"    
				endIf

				PLSATUCS(cStaLib)

			endIf

		endIf

	endIf

	restArea( aArea )
	BE2->( restArea( aAreaBE2 ) )
	BE4->( restArea( aAreaBE4 ) )
	BD5->( restArea( aAreaBD5 ) )
	BEA->( restArea( aAreaBEA ) )

return( { aMatCri,aMatBD7 } )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLPROC
Valid do campo de procedimento

@author  PLS TEAM
@version P11
@since    20/01/11
/*/
//-------------------------------------------------------------------
Function PLSVCPPROC(cCodPad,cCodPro)
	LOCAL lRet 		:= .T.
	LOCAl cAlias    := Substr(ReadVar(),4,3)
	Default cCodPad := ""
Default cCodPro := ""

If Empty(GetNewPar("MV_PLSTBPD","")) .And. Empty(cCodPad)
	BR8->(DbSetOrder(3))
	lRet := BR8->(MsSeek(xFilial("BR8")+cCodPro ))
	If lRet
		If ReadVar() == "M->"+cAlias+"_PROFIM" .And. ;
		&("M->"+cAlias+"_PROFIM") < &("M->"+cAlias+"_PROINI")
			lRet:=.F.
			Help( ,, 'HELP',,"Procedimento final tem que ser maior ou igual ao procedimento inicial!", 1, 0)
			Return lRet
		Endif
		If &( cAlias+"->( FieldPos('"+cAlias+"_CODPAD') )" ) > 0
			&("M->"+cAlias+"_CODPAD") := BR8->BR8_CODPAD
		EndIf
	Endif
Else
	BR8->(DbSetOrder(1))
	lRet := BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro ))
	If lRet .And. ReadVar() == "M->"+cAlias+"_PROFIM" .And. ;
	&("M->"+cAlias+"_PROFIM") < &("M->"+cAlias+"_PROINI")
		lRet:=.F.
		Help( ,, 'HELP',,"Procedimento final tem que ser maior ou igual ao procedimento inicial!", 1, 0)
		Return lRet
	Endif
EndIf

IF !lRet
	Help( ,, 'HELP',,"Procedimento n„o encontrado!", 1, 0)
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB02LIB
Valid do campo de procedimento

@author  PLS TEAM
@version P11
@since    20/01/11
/*/
//-------------------------------------------------------------------
Function PLSAB02LIB(cNumLib,cCodPad,cCodPro)
	LOCAL cSQL 		:= ""
DEFAULT cNumLib := ""
DEFAULT cCodPad := ""
DEFAULT cCodPro := ""

cSQL := "SELECT BE2_DENREG, BE2_FADENT "
cSQL += "FROM "+RetSQLName("BE2")+" "
cSQL += "WHERE BE2_FILIAL = '"+xFilial("BE2")+"' AND "
cSQL += "BE2_OPEMOV = '"+Substr(cNumLib,01,4)+"' AND "
cSQL += "BE2_ANOAUT = '"+Substr(cNumLib,05,4)+"' AND "
cSQL += "BE2_MESAUT = '"+Substr(cNumLib,09,2)+"' AND "
cSQL += "BE2_NUMAUT = '"+Substr(cNumLib,11,8)+"' AND "
cSQL += "BE2_CODPAD = '"+cCodPad+"' AND "
cSQL += "BE2_CODPRO = '"+cCodPro+"' AND "
cSQL += RetSQLName("BE2")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYLIB",.F.,.T.)

	If !QRYLIB->(Eof())
		M->BE2_DENREG := QRYLIB->BE2_DENREG
		M->BE2_FADENT := QRYLIB->BE2_FADENT
	EndIf
	QRYLIB->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS090FOR
Tratamento Botao Hist Crit. ForÁadas

@author  PLS TEAM
@version P11
@since   08/04/11
/*/
//-------------------------------------------------------------------
Function PLS090FOR(cAliasCab,cAliasIte,oBrwPro)
	Local lRet      	:= .F.
	Local aArea     	:= GetArea()
	Local cNumAut		:= ""
Local nLin			:= 0
Local nCodPad       := 0
Local nCodPro       := 0
Local cCodPad       := ""
Local cCodPro       := ""

If ! CheckB67()
	Return lRet
Endif


//Procuro a Linha do evento posicionado									

nLin	 := oBrwPro:Linha()
nCodPad  := PLRETPOS(cAliasIte+"_CODPAD",oBrwPro:aHeader)
nCodPro  := PLRETPOS(cAliasIte+"_CODPRO",oBrwPro:aHeader)

//Procuro a Tabela padrao posicionada										

cCodPad := oBrwPro:aCols[nLin,nCodPad]

//Procuro o Codigo procedimento posicionado								

cCodPro := oBrwPro:aCols[nLin,nCodPro]

//Numero da Autorizacao posicionada e Origem								

If cAliasCab == "BE4" // Internacao
	cNumAut	:= &(cAliasCab+"->("+cAliasCab+"_OPEUSR"+"+"+cAliasCab+"_ANOPAG"+"+"+cAliasCab+"_MESPAG"+"+"+cAliasCab+"_NUMINT"+")")
	cOrig   := "3"
ElseIf cAliasCab == "B44" // Reembolso
	cNumAut	:= &(cAliasCab+"->("+cAliasCab+"_OPEUSR"+"+"+cAliasCab+"_ANOPAG"+"+"+cAliasCab+"_MESPAG"+"+"+cAliasCab+"_NUMAUT"+")")
	cOrig   := "5"
ElseIf cAliasCab == "B4A"
	cNumAut	:= &(cAliasCab+"->("+cAliasCab+"_OPEMOV"+"+"+cAliasCab+"_ANOAUT"+"+"+cAliasCab+"_MESAUT"+"+"+cAliasCab+"_NUMAUT"+")")
	cOrig 	:= SubStr(&(cAliasCab+"->"+cAliasCab+"_TIPGUI"),Len(&(cAliasCab+"->"+cAliasCab+"_TIPGUI")))
ElseIf cAliasCab == "B4Q"
	cNumAut	:= &(cAliasCab+"->("+cAliasCab+"_OPEMOV"+"+"+cAliasCab+"_ANOAUT"+"+"+cAliasCab+"_MESAUT"+"+"+cAliasCab+"_NUMAUT"+")")
	cOrig 	:= "B"
Else
	cNumAut	:= &(cAliasCab+"->("+cAliasCab+"_OPEMOV"+"+"+cAliasCab+"_ANOAUT"+"+"+cAliasCab+"_MESAUT"+"+"+cAliasCab+"_NUMAUT"+")")
	If &( cAliasCab+"->( FieldPos('"+cAliasCab+"_LIBERA') )" ) > 0 .And. &(cAliasCab+"->"+cAliasCab+"_LIBERA") == "1"
		cOrig := "1"
	Else
		cOrig   := &(cAliasCab+"->"+cAliasCab+"_TIPO")
	Endif
Endif

//Verifico os dados e procuro o Historica da critica para o Procedimento	

If !Empty(cNumAut) .And. !Empty(cCodPad) .And. !Empty(cCodPro).And. !Empty(cOrig)
	aArea := GetArea()
	DbSelectArea('BDS')
	BDS->( dbSetOrder( 1 ) ) //BDS_FILIAL, BDS_OPEMOV, BDS_ANOAUT, BDS_MESAUT, BDS_NUMAUT, BDS_ORIGEM, BDS_CODPAD, BDS_CODPRO
	If BDS->( dbSeek( xFilial( 'BDS' )+cNumAut+cOrig+cCodPad+cCodPro) )
		lRet:=.T.
		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		objCENFUNLGP:useLogUser()
		FWExecView('Visualizacao','PLSA031',1,,{ || lOk := .T., lOk } )
	Else
		lRet := .F.
	EndIf
	RestArea(aArea)
Else
	lRet := .F.
Endif

//Caso nao encontre exibe a mensagem										

If !lRet
	MsgAlert( STR0598 ) //'Para o Procedimento posicionado n„o existem Criticas ForÁadas!'
Endif

//Retorno a Area															

	RestArea( aArea )
Return lRet

/*/{Protheus.doc} PLValGrauPa
Valida Grau Participacao

@author  PLS TEAM
@version P11
@since   12/05/11
/*/
Function PLValGrauPa()
	LOCAL lRet := .T.
Return lRet

/*/{Protheus.doc} PLSCTLIB
Retorna chave da liberacao na conta medica

@author  PLS TEAM
@version P11
@since   12/05/11
/*/
Function PLSCTLIB(cNumLib,lGuiInt)
	local cAliasLib 	:= ""
local cCdOpeLib 	:= ""
local cNumeGLib 	:= ""
local cChaveLib		:= ""
local cSenha		:= ""
local lSolicitacao 	:= .f.

//Pega a chave de liberacao na conta medica para tratamento no ponto de entrada PLCALCEV

If ! empty(cNumLib)

	cAliasLib := iIf(lGuiInt,"BE4","BEA")

	(cAliasLib)->( dbSetOrder( Iif(lGuiInt,2,1) ) )//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT # BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO

	if (cAliasLib)->( msSeek( xFilial(cAliasLib) + cNumLib ) )

		if lGuiInt

			cCdOpeLib := BE4->BE4_CODOPE
			cNumeGLib := BE4->BE4_NUMERO

			//Para garantir que o bea fique posicionado
			BEA->( dbSetOrder(6) )	//BEA_FILIAL + BEA_OPEINT + BEA_ANOINT + BEA_MESINT + BEA_NUMINT + DTOS(BEA_DATPRO) + BEA_HORPRO
			BEA->( msSeek( xFilial("BEA") + BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )

		else

			cCdOpeLib := BEA->BEA_OPEMOV
			cNumeGLib := BEA->BEA_NUMGUI

		endIf

		lSolicitacao := ( BEA->BEA_LIBERA == '1' )
		cChaveLib  	 := cCdOpeLib + (cAliasLib)->&(cAliasLib+"_CODLDP") + (cAliasLib)->&(cAliasLib+"_CODPEG") + cNumeGLib + (cAliasLib)->&(cAliasLib+"_ORIMOV")
		cSenha		 := (cAliasLib)->&( cAliasLib + "_SENHA")

		endIf

	endIf

return( { cChaveLib, cSenha, lSolicitacao } )

//-------------------------------------------------------------------
/*/{Protheus.doc} NotFdBDS
Verifica se a liberacao foi forcada anteriormente para 	 
evitar o reprocessamento da critica  

@author  PLS TEAM
@version P11
@since   04/11/11
/*/
//-------------------------------------------------------------------
Static Function NotFdBDS(cCodLib)

	Local lRet 		:= .T.
	Local aAreaBDS 	:= BDS->(GetArea())

	BDS->(DbSetOrder(1))

	If !Empty(cCodLib) .And. BDS->(MsSeek(xFilial("BDS")+cCodLib))
		lRet := .F.
	EndIf

	RestArea(aAreaBDS)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FdCrifor
Verifica se a liberacao foi forcada anteriormente a fim de evitar o reprocessamento
de uma mesma critica na autorizaÁ„o
@author  PLS TEAM
@version P12
@since   27/08/2018
/*/
//-------------------------------------------------------------------
Function FdCrifor(cNumLib,aRetRda,cCodRda,aRetCon,aRetFin,lRPC,lJaAud,cCdTbPd,cCdPro,lNewAud,aCriTok)

Local lRet 		 := .F.
Local lRda       := .F.
Local cCriFor    := ""
Local cCodPad    := ""
Local cCodPro    := ""	
Local cReBeg     := ""
Local nFor       := 0
Local i          := 0
Local nPos       := 0
Local nBkpPos    := 0
Local nTam       := 0
Local nK         := 0
Local aCriCab	 := {}
Local aAuxCab    := {}
Local aAreaB67   := B67->(GetArea())
Local aAreaBEA 	 := BEA->(GetArea())

default lRPC     := .F.
default lJaAud   := .F.
default lNewAud  := .T.
default cCodRda  := ""
default cCdTbPd  := ""   
default cCdPro   := ""
default cNumLib  := ""
default aRetCon  := {}
default aRetFin  := {}
default aRetRda  := {}   
default aCriTok  := {}

If !empty(cNumLib) 

	If !lNewAud .And. lJaAud
		DbSelectArea("BVX")
		BVX->(DbSetOrder(3))		
		If BVX->(MsSeek(xFilial("BVX")+cNumLib))
			While !BVX->( Eof() ) .And. BVX->(BVX_OPEMOV+BVX_ANOAUT+BVX_MESAUT+BVX_NUMAUT) == cNumLib
		
				cCodPad := Alltrim(BVX->BVX_CODPAD)
				cCodPro := Alltrim(BVX->BVX_CODPRO)    
			  				
				If  Alltrim(BVX->BVX_PARECE) == "0" .And. lJaAud .And. !Empty(cCodPad+cCodPro) .And. cCodPad+cCodPro == cCdTbPd+cCdPro 
					cReBeg:= ChkAudt(cNumLib,cCodPad,cCodPro,BVX->BVX_SEQUEN)					
				
					aAuxCab:=StrTokArr(cReBeg, "/")
					 
				EndIf '
				BVX->( DbSkip() )
			EndDo
		EndIf				
	EndIf
	
	B67->(DbSetOrder(1))
	If (lNewAud .Or. !lJaAud) .And. B67->(MsSeek(xFilial("B67")+cNumLib))
		While !B67->( Eof() ) .And. B67->(B67_OPEMOV+B67_ANOAUT+B67_MESAUT+B67_NUMAUT) == cNumLib
	
			cCodPad := Alltrim(B67->B67_CODPAD)
			cCodPro := Alltrim(B67->B67_CODPRO)
			If Empty(cCodPad+cCodPro) .Or. (lJaAud .And. !Empty(cCodPad+cCodPro) .And. cCodPad+cCodPro == cCdTbPd+cCdPro ) 
				aAdd(aAuxCab,B67->B67_CODCRI)
			EndIf
			B67->( DbSkip() )
		EndDo
	EndIf
		
	//Verifico se o Array retorna criticas j· forÁada na liberaÁ„o.
	If len(aAuxCab) > 0

		//Nas criticas do Prestador verifico se È a mesma rda da critica forÁada.
		if !empty(cCodRDA) 
			BEA->( DbSetOrder(1) )
			If BEA->( MsSeek(xFilial("BEA")+ cNumLib) .And. BEA->BEA_ORIGEM == "2")
				if BEA->BEA_CODRDA == cCodRda
					lRda := .T.
				Else
					// Quando a RDA for Generica
					If GetNewPar("MV_PLSRDAG","") == BEA->BEA_CODRDA .And. lJaAud // Valido somente quando j· foi auditado o procedimento
						lRda := .T.
					Else
						lRda := .F.
					EndIf
				endIf
			EndIf
		EndIf
	
		//Criticas de Contrato		
		If len(aRetCon) > 0
			If !aRetCon[1]
				For nFor:=1 To Len(aRetCon[2])
					aAdd(aCriCab,aRetCon[2][nFor])
				Next
			Endif
		EndIf
		//Criticas Finceiras
		If len(aRetFin) > 0
			If !aRetFin[1]
				For nFor:=1 To Len(aRetFin[2])
					aAdd(aCriCab,aRetFin[2][nFor])
				Next
			EndIf
		EndIf
		//Criticas de Prestador    // quando o lJaud estiver ativo estou verificando se ha demais criticas ja auditadas
		If len(aRetRda) > 0
			For nFor:=1 To Len(aRetRda)		
				aAdd(aCricab, aRetRda[1])
			Next
		EndIf
		//Criticas de Token
		If len(aCriTok) > 0
			If !aCriTok[1]
				For nFor:=1 To Len(aCriTok[2])
					aAdd(aCriCab,aCriTok[2][nFor])
				Next
			Endif
		EndIf
	
		//limpo as criticas forÁada
		If len(aCriCab) > 0
			for i:=1 To len(aAuxCab) 
				cCriFor := aAuxCab[i]
				nPos  := ascan( aCriCab,{|x| x[1] == cCriFor})
				If nPos > 0
					nBkpPos := nPos
				EndiF	
				If nPos > 0
					for nFor := nPos to len(aCriCab)
						nTam := len(aCriCab)
						If (len(aCriCab) >= nPos)
							If nTam > 0 .And. (aCriCab[nFor,1] == cCriFor .Or. empty(aCriCab[nFor,1]))
								aDel(aCriCab, nFor)
								aSize(aCriCab, len(aCriCab)-1)
								nFor--
							else
								exit
							endIf
						else
							exit	
						endif
					next
				EndIf
			next		
	
			// Caso seja maior que 0 ainda tem critica entao retorno como falso p que apresente as criticas p o Usuario.
			If nTam > 0
				lRet := .F.
			elseIf nTam == 0 .And. nBkpPos > 0 .And. !len(aRetRda) > 0  
				// Caso Array esteja vazio e nPos maior q 0 houve somente a critica forÁada na liberaÁ„o.
					lRet := .T.
			elseIf nTam == 0 .And. nBkpPos > 0 .And. lRda
					lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaB67)
RestArea(aAreaBEA)

Return(lRet)

/*/{Protheus.doc} PLSREMSE2
Retorna o proximo numero do SE2->E2_NUM. MV_PLNUME2 

@author  PLS TEAM
@version P11
@since   21.03.2012
/*/
Function PLSREMSE2(cPrefixo)
	local aAreaSE2	:= SE2->(getArea())
	local cNum 		:= ""

cNum := getSXENum("SE2", "E2_NUM", "PLSNUMTITREE_" + cPrefixo)

SE2->(dbSetOrder(1))
while SE2->(MsSeek(xFilial("SE2") + cPrefixo + cNum))
	cNum := getSXENum("SE2", "E2_NUM", "PLSNUMTITREE_" + cPrefixo)
	endDo

	confirmSX8()

	restArea(aAreaSE2)

Return(cNum)

/*/{Protheus.doc} pbVldCbo 

@author  PLS TEAM
@version P11
@since   21.03.2012
/*/
Function PBVLDCBO(cEsp,lWeb)
	LOCAL lRet  := .F.
	LOCAL cDado := ""

DEFAULT cEsp	:= ""
DEFAULT lWeb := .F.

If lWeb
	cDado := cEsp
Else
	cDado := M->B4B_CODESP
EndIf

//Verifica se o codigo passado È da CBO ou da Especialidade
lCodCBO := Len(AllTrim(cDado)) > TamSX3("BAQ_CODESP")[1]

BAQ->(DbSetORder(1))
If !lCodCBO .AND. BAQ->(MsSeek(xFilial('BAQ')+plsintpad()+cDado))
	If !Empty(BAQ->BAQ_CBOS)
		lRet := .T.
	Else
		If !lWeb
			MsgStop(STR0597) //'Nao foi possivel localizar o CBOS para a especialidade informada'
		EndIf
	Endif
Else
	BAQ->(DbSetORder(4))
	If !BAQ->(MsSeek(xFilial('BAQ')+plsintpad()+cDado))
		If !lWeb
			Help("",1,"REGNOIS")
		EndIf
	Else
		cDado := BAQ->BAQ_CODESP
		lRet := .T.
	Endif
Endif
If lRet
	BQ1->(DbSetORder(1))
	If !BQ1->(MsSeek(xFilial('BQ1')+M->B4B_CDPFPR+cDado))
		lRet := .F.
	Else
		M->B4B_CODESP := BAQ->BAQ_CBOS
	Endif
Endif

If !lRet
	If !lWeb
		MsgStop(STR0596) //'Nao foi possivel localizar o CBOS no profissional informado'
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PlsFilEsp 

@author  PLS TEAM
@version P11
@since   21.03.2012
/*/
Function PlsFilEsp()
	LOCAL cCampo := ReadVar()
	Local cCodigo := ""

If cCampo == "M->BE1_ESPSOL"
	cCodigo := M->BE1_CDPFSO
Endif

If cCampo == "M->BE1_ESPEXE"
	cCodigo := M->BE1_CDPFRE
Endif

If cCampo == "M->BE4_ESPSOL"
	cCodigo := M->BE4_CDPFSO
Endif

If cCampo == "M->B4B_CODESP"
	cCodigo := M->B4B_CDPFPR
Endif

If cCampo == "M->BE4_ESPEXE"
	cCodigo := M->BE4_CDPFRE
Endif

If cCampo == "M->BD5_ESPSOL"
	cCodigo := M->BD5_CDPFSO
Endif

If cCampo == "M->BD5_ESPEXE"
	cCodigo := M->BD5_CDPFRE
Endif

If cCampo == "M->BD6_ESPSOL"
	If Type('M->BD5_CDPFSO') <> 'U'
		cCodigo := M->BD5_CDPFSO
	Endif
	If Type('M->BE4_CDPFSO') <> 'U'
		cCodigo := M->BE4_CDPFSO
	Endif
Endif

If cCampo == "M->BD6_ESPEXE"
	If Type('M->BD5_CDPFRE') <> 'U'
		cCodigo := M->BD5_CDPFRE
	Endif
	If Type('M->BE4_CDPFRE') <> 'U'
		cCodigo := M->BE4_CDPFRE
	Endif
Endif

If cCampo == "M->BD7_ESPSOL"
	If Type('M->BD5_CDPFSO') <> 'U'
		cCodigo := M->BD5_CDPFSO
	Endif
	If Type('M->BE4_CDPFSO') <> 'U'
		cCodigo := M->BE4_CDPFSO
	Endif
Endif

If cCampo == "M->BD7_ESPEXE"
	If Type('M->BD5_CDPFRE') <> 'U'
		cCodigo := M->BD5_CDPFRE
	Endif
	If Type('M->BE4_CDPFRE') <> 'U'
		cCodigo := M->BE4_CDPFRE
	Endif
Endif

cRet := "@#BQ1_FILIAL == '"+xFilial("BQ1")+"' .AND. BQ1_CODIGO == '"+cCodigo+"' @#"

Return cRet

/*/{Protheus.doc} PLSLEMBRE 
FunÁ„o para validar a exibiÁ„o do lembrete do procedimento

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
Function PLSLEMBRE(lIntern,lPortal,cCodPad,cCodPro,nQtdPro,lAnexos,lEvolucao)
	Local lRet   := .F.
	Local cSql   := ""
Local aUser	 := PLSGETUsr()
Local aArea  := GetArea()
Local cCodOpe := If(Len(aUser)>0,Substr(aUser[2],1,4),"")
Local cCodEmp := If(Len(aUser)>0,Substr(aUser[2],5,4),"")
Local cMatric := If(Len(aUser)>0,Substr(aUser[2],9,6),"")
Local cTipReg := If(Len(aUser)>0,Substr(aUser[2],15,2),"")
Local cContra := If(Len(aUser)>0,aUser[9],"")
Local cVerCon := If(Len(aUser)>0,aUser[39],"")
Local cSubCon := If(Len(aUser)>0,aUser[41],"")
Local cVerSub := If(Len(aUser)>0,aUser[42],"")
Local dDatHis := CtoD("")
Local nQtd	  := 0
Default lIntern := .F.
Default lAnexos := .f.
Default lEvolucao := .F.

If BR8->( FieldPos("BR8_QTDLEM")) > 0 .And. BR8->BR8_QTDLEM > 0 .And. BR8->( FieldPos("BR8_PERLEM") ) > 0 .And. BR8->BR8_PERLEM > 0
	If BR8->( FieldPos("BR8_UNILEM") ) > 0 .And. !Empty(BR8->BR8_UNILEM)
		If lAnexos
			If M->B4C_QTDPRO > 1 .And. M->B4C_QTDPRO >= BR8->BR8_QTDLEM
				lRet := .T.
			Endif
		Else
			If lPortal
				If Valtype(nQtdPro) <> 'U' .And. nQtdPro > 1 .And. nQtdPro >= BR8->BR8_QTDLEM
					lRet := .T.
				EndIf
			ElseIf !lIntern .And. M->BE2_QTDPRO > 1 .And. M->BE2_QTDPRO >= BR8->BR8_QTDLEM
				lRet := .T.
			ElseIf lIntern .And. !lEvolucao .And. M->BEJ_QTDPRO > 1 .And. M->BEJ_QTDPRO >= BR8->BR8_QTDLEM
				lRet := .T.
			ElseIf lIntern .And. lEvolucao .And. M->BQV_QTDPRO > 1 .And. M->BQV_QTDPRO >= BR8->BR8_QTDLEM
				lRet := .T.
			EndIf
		Endif
		If !lRet .and. !Empty(cCodOpe)
			cSql := " SELECT BD6_QTDPRO FROM "+RetSqlName("BD6")
			cSql += " WHERE BD6_FILIAL = '"+xFilial("BEA")+"' "
			cSql += "   AND BD6_OPEUSR = '"+cCodOpe+"' "
			cSql += "   AND BD6_CODEMP = '"+cCodEmp+"' "
			cSql += "   AND BD6_MATRIC = '"+cMatric+"' "
			cSql += "   AND BD6_TIPREG = '"+cTipReg+"' "
			cSql += "   AND BD6_CONEMP = '"+cContra+"' "
			cSql += "   AND BD6_VERCON = '"+cVerCon+"' "
			cSql += "   AND BD6_SUBCON = '"+cSubCon+"' "
			cSql += "   AND BD6_VERSUB = '"+cVerSub+"' "

			If lAnexos
				cSql += "   AND BD6_CODPAD = '"+M->B4C_CODPAD +"' "
				cSql += "   AND BD6_CODPRO = '"+M->B4C_CODPRO +"' "
			Else
				If lPortal
					cSql += "   AND BD6_CODPAD = '"+cCodPad +"' "
					cSql += "   AND BD6_CODPRO = '"+cCodPro +"' "
				Else
					If lEvolucao

						cSql += "   AND BD6_CODPAD = '"+ M->BQV_CODPAD +"' "
						cSql += "   AND BD6_CODPRO = '"+ M->BQV_CODPRO +"' "
					ElseIf lIntern
						cSql += "   AND BD6_CODPAD = '"+M->BEJ_CODPAD +"' "
						cSql += "   AND BD6_CODPRO = '"+M->BEJ_CODPRO +"' "
					Else
						cSql += "   AND BD6_CODPAD = '"+M->BE2_CODPAD +"' "
						cSql += "   AND BD6_CODPRO = '"+M->BE2_CODPRO +"' "

					EndIf
				EndIf
			Endif

			If BR8->BR8_UNILEM = '0'//Dias
				dDatHis := (dDataBase - BR8->BR8_PERLEM)+1
			ElseIf BR8->BR8_UNILEM = '1'//Meses
				dDatHis := dDataBase - (BR8->BR8_PERLEM * 30)+1
			Else //BR8->BR8_UNILEM = 2 Anos
				dDatHis := dDataBase - (BR8->BR8_PERLEM * 365)+1
			EndIf

			cSql += "AND BD6_DATPRO BETWEEN '" + DTOS(dDatHis)+ "' AND '" + DTOS(dDataBase)+ "' "

			cSql += "   AND D_E_L_E_T_ <> '*' "

			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
		EndIf
	EndIf
Else
	lRet := .T.
EndIf

If lAnexos
	nQtd := M->B4C_QTDPRO
Else
	If lPortal
		If Valtype(nQtdPro) <> 'U'
			nQtd := nQtdPro
		EndIf
	ElseIf lIntern
		If lEvolucao
			nQtd := M->BQV_QTDPRO
		Else
			nQtd := M->BEJ_QTDPRO
		Endif
	Else
		nQtd := M->BE2_QTDPRO
	EndIf
Endif

If Select("TRBBD6") > 0
	While !TRBBD6->(EOF())
		nQtd += TRBBD6->BD6_QTDPRO
		TRBBD6->(dbSkip())
	EndDo

	If nQtd >= BR8->BR8_QTDLEM
		lRet := .T.
	EndIf
EndIf

If Select("TRBBD6") > 0
	DbSelectArea("TRBBD6")
		TRBBD6->(DbCloseArea())
	Endif

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldLembre 
FunÁ„o chamada no x3_valid do BE2_QTDPRO para validar
a exibiÁ„o do lembrete do procedimento.

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function VldLembre()

	If !lLembre
		If BR8->( FieldPos("BR8_LEMBRE") ) > 0 .and. !Empty(BR8->BR8_LEMBRE)
		If lLembre := PLSLEMBRE()
			Aviso("Lembrete", Alltrim(BR8->BR8_LEMBRE), {"Ok"})
			EndIf
		Endif
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLTpAteBox 

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function PLTpAteBox()
	Local cTissVer   := PLSTISSVER()
	Local cRet := ""

	cret +=	"01=RemoÁ„o;"
	cRet += "02=Pequena Cirurgia;"
	cRet += "03=Outras Terapias;"
	cRet += "04=Consulta;"
	cRet += "05=Exame Ambulatorial;"
	cRet += "06=Atendimento Domiciliar;"
	cRet += "07=InternaÁ„o;"
	cRet += "08=Quimioterapia;"
	cRet += "09=Radioterapia;"
	cRet += "10=Terapia Renal Substitutiva (TRS) ;"
	cRet += "11=Pronto Socorro;"
	cRet += "13=Pequeno atendimento (sutura, gesso e outros);"
	cRet += "14=Sa˙de Ocupacional - Admissional;"
	cRet += "15=Sa˙de Ocupacional - Demissional;"
	cRet += "16=Sa˙de Ocupacional - PeriÛdico;"
	cRet += "17=Sa˙de Ocupacional - Retorno ao trabalho;"
	cRet += "18=Sa˙de Ocupacional - MudanÁa de funÁ„o;"
	cRet += "19=Sa˙de Ocupacional - PromoÁ„o a sa˙de;"
	cRet += "20=Sa˙de Ocupacional - Benefici·rio novo;"
	cRet += "21=Sa˙de Ocupacional - AssistÍncia a demitidos;"
	cRet += "22=TELESSA⁄DE;"
	cRet += "23=Exame"

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} P09LSEQCRI 

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function P09LSEQCRI()
	LOCAL cRet      := "001"
LOCAL aProg     := PlsRetAut()
LOCAL cAliIte 	:= aProg[3]

If ValType(oBrwPro) == "O"
	cRet := oBrwPro:FieldGet(cAliIte+"_SEQUEN")
	Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUSRPTU 
Funcoes PTU que foram transportadas para o fonte PLSUSRPTUA

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function PLSUSRPTU()
	//Funcao foi transportada para o fonte PLSTRTPTU_SCS2 como PLSUSRPTUA
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPREPTU 

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function PLSPREPTU()
	//Funcao foi transportada para o fonte PLSTRTPTU_SCS2 como PLSPREPTUA
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PtuRetUsu 

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function PtuRetUsu(aDados)
	//Funcao foi transportada para o fonte PLSTRTPTU_SCS2 como PtuRetUsuA
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PtuRetPre 

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function PtuRetPre(aDados)
	//Funcao foi transportada para o fonte PLSTRTPTU_SCS2 como PtuRetPreA
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PtuReqServ 

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function PtuReqServ(aDados,aItens)
	//Funcao foi transportada para o fonte PLSTRTPTU_SCS2 como PtuReqSerA
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL90VLDTAT 
Valida o Tipo de Atendimento selecionado 

@author  PLS TEAM
@version P11
@since   27.02.14
/*/
//-------------------------------------------------------------------
Function PL90VLDTAT(cAlias)
	Local lRet     := .T.
	Local cTissVer := PLSTISSVER()
	Local aDadusr  := PLSDADUSR(&("M->"+cAlias+"_USUARI"),"1",,&("M->"+cAlias+"_DATPRO"))
Local cOpeOri  := ""

If len(aDadUsr) > 44
	cOpeOri := aDadUsr[45]
Endif

If !Empty(cOpeOri) .And. cOpeOri <> PLSINTPAD() .And. cTissVer < "3.00.00" .And. &("M->"+cAlias+"_TIPATE") $ "11,13,14,15,16,17 18,19,20,21"
	MsgInfo(STR0595) //"O Tipo de Atendimento selecionado sÛ pode ser utilizado na TISS 3.00.00 ou superior."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} PLPESINTSXB 
Executa a consulta padrao (especifica)

@author  PLS TEAM
@version P11
@since   27.02.14
/*/
Function PlPESINTSXB()
	local cSql 		:= ""
local cWhr 		:= ""
local cRet 		:= ""
local aIndices 	:= {}
local aHeader 	:= {}
local lRet		:= .f.
local oConsulta	:= nil
local aArea 	:= getArea()
local cMatric	:= iIf(valType(M->BD5_USUARI) != 'U',M->BD5_USUARI,M->BE1_USUARI)

//Monta a query da consulta padrao																	
//Converte primeiro campo para string pois o mesmo eh chave na consulta padrao e na pesquisa do mesmo

	cSql := "SELECT (BEA_OPEMOV||BEA_ANOAUT||BEA_MESAUT||BEA_NUMAUT) AS GUIA,  "
	cSql += "       (BEA_OPEUSR||BEA_CODEMP||BEA_MATRIC||BEA_TIPREG||BEA_DIGITO) AS MATRIC,BEA_NOMUSR, BEA_DATPRO, BEA_TIPGUI, BE4_DTALTA "
	cSql +=	" FROM  " + RetSqlName("BEA")+ " BEA"
	cSql += " LEFT JOIN " + RetSqlName("BE4") + " BE4"
	cSql += " ON BE4_FILIAL = '"  + xFilial("BE4")+ "' "
	cSql += " AND BEA_OPEMOV = BE4_CODOPE"
	cSql += " AND BEA_ANOAUT = BE4_ANOINT"
	cSql += " AND BEA_MESAUT = BE4_MESINT"
	cSql += " AND BEA_NUMAUT = BE4_NUMINT"
	cSql += " AND BE4.D_E_L_E_T_ = ' ' "
	
	cWhr := " WHERE BEA_FILIAL = '" + xFilial("BEA")+ "' "
	cWhr += " AND (BEA_OPEUSR||BEA_CODEMP||BEA_MATRIC||BEA_TIPREG||BEA_DIGITO) = '" + cMatric + "' "
	cWhr += " AND BEA_DATPRO <> ' ' "
	cWhr += " AND BEA.D_E_L_E_T_ = ' ' "

if existBlock("PL90ALTA")

	cRet := execBlock("PL90ALTA", .F., .F., cWhr)

	if valType(cRet) == "C" .and. "WHERE " $ upper(cRet)
		cWhr := " " + allTrim(cRet) 
	endIf

endIf

cSql += cWhr
cSql := ChangeQuery(cSql)

//Monta a aHeader da consulta≥
SX3->( dbSetOrder( 2 ) )
SX3->( dbGotop() )
if SX3->( dbSeek( "BEA_NUMAUT", .F. ) )
	aadd(aHeader,{SX3->X3_TITULO,'BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT',SX3->X3_PICTURE,20,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
	aadd( aIndices, {"BEA_NUMAUT",SX3->X3_TITULO})
endIf

if SX3->( dbSeek( "BEA_MATRIC", .F. ) )
	aadd(aHeader,{"Matricula",'BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO',SX3->X3_PICTURE,15,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
	aadd( aIndices, {"BEA_MATRIC",SX3->X3_TITULO})
endIf

if SX3->( dbSeek( "BEA_NOMUSR", .F. ) )
	aadd(aHeader,{SX3->X3_TITULO,'BEA_NOMUSR',SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
	aadd( aIndices, {"BEA_NOMUSR",SX3->X3_TITULO})
endIf

if SX3->( dbSeek( "BEA_DATPRO", .F. ) )
	aadd(aHeader,{SX3->X3_TITULO,'BEA_DATPRO',SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
endIf

if SX3->( dbSeek( "BEA_TIPGUI", .F. ) )
	aadd(aHeader,{SX3->X3_TITULO,'BEA_TIPGUI',SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V","01=Consulta;02=Sadt;03=InternaÁ„o;04=Outros"})
endIf

if SX3->( dbSeek( "BE4_DTALTA", .F. ) )
	aadd(aHeader,{SX3->X3_TITULO,'BE4_DTALTA',SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
endIf


//Monta a consulta padrao≥
oConsulta:= PlsIntSxb():New()
oConsulta:cTitle 		:= "CONSULTA" 					    				//Titulo da Consulta
oConsulta:cQuery 		:= cSql												//Query dos dados a serem apresentados
oConsulta:aIndex 		:= aIndices											//Indices disponiveis (deve usar os mesmos campos da query)
oConsulta:aHeader 		:= aHeader                      					//Header da grid presente consulta (deve usar os mesmos campos da query)
oConsulta:aReturn		:= {'BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT'}	//Campos de retorno da consulta (deve usar os mesmos campos da query)
oConsulta:lDataBaseRM 	:= .T.												//Indica se a query eh executada na base do protheus ou da RM
oConsulta:Show()

//Coleta o retorno≥
	if len(oConsulta:aRetSXB) > 0
		cCodIntSxb 	:= oConsulta:aRetSXB[1]
		lRet 		:= .t.
	endIf

	RestArea(aArea)

return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDINTER 
Verifica se existe a Guia de InternaÁ„o. 

@author  PLS TEAM
@version P11
@since   27.02.14
/*/
//-------------------------------------------------------------------
Function PLSVLDINTER(cGuiaIntPri, lSADT)
	Local lret :=.T.
	Local cSQL := ""
Local aArea := GetArea()
DEFAULT lSADT := .F.


If !IsInCallStack("PLPESINTSXB").and. !Empty(cGuiaIntPri)

	If AllTrim( TCGetDB() ) == "ORACLE"
		cSQL := " SELECT (BE4_ANOINT||BE4_MESINT||BE4_NUMINT)AS INTERNACAO,(BE4_CODOPE||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG||BE4_DIGITO) AS MATRIC,BE4_NOMUSR,BE4_CODRDA,R_E_C_N_O_ FROM " + RetSQLName("BE4")
		cSQL += " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  (BE4_ANOINT||BE4_MESINT||BE4_NUMINT) = '"+cGuiaIntPri+"'   AND D_E_L_E_T_ = ''"
	Else
		cSQL := " SELECT  BE4_ANOINT+ BE4_MESINT+ BE4_NUMINT AS INTERNACAO,(BE4_CODOPE+ BE4_CODEMP+ BE4_MATRIC+ BE4_TIPREG +BE4_DIGITO) AS MATRIC,BE4_NOMUSR,BE4_CODRDA,R_E_C_N_O_ FROM " + RetSQLName("BE4")
		cSQL += " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  (BE4_ANOINT+BE4_MESINT+BE4_NUMINT)     = '"+cGuiaIntPri+"'  AND  D_E_L_E_T_ = ''"
	Endif


	PLSQuery(cSQL,"TrbBE4")

	If  !lSADT .AND. TrbBE4->(Eof())
		Aviso( STR0120, ; //"Atencao"
		"N„o h· internaÁ„o para esse codigo",;
		{ STR0146 }, 2 )//"Ok"
			lRet:=.F.
		EndIf
		TrbBE4->(DbCloseArea())
	Endif

	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P090DUPADD 
Verifica se o procedimento generico possui mesma descriÁ„o 

@author  PLS TEAM
@version P11
@since   30.01.15
/*/
//-------------------------------------------------------------------
Function P090DUPADD(cBrw,cAliIte,cTipo)
LOCAL lRet          := .T.
LOCAL nX 		    := 0
LOCAL nLenBrw		:= 0
LOCAL cDesForPro	:= ""
LOCAL cMsgGener     := ""
Local aHeaderAux    := {}
Local aColsAux      := {}
Local nDesPosPro	:= 0
Local nPosNrtrol    := 0
Local nPosSequen    := 0
Local lPTUOn80		:= Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
DEFAULT cTipo			:= "1"
DEFAULT cBrw			:= "oBrwPro"
DEFAULT cAliIte		:= PLSRetAut(cTipo)[3]

aHeaderAux := &(cBrw+":aHeader")
aColsAux   := &(cBrw+":aCols")	

nDesPosPro	:= ascan(aHeaderAux,{ |x| x[2] == cAliIte+"_DESPRO"})
nPosNrtrol  := ascan(aHeaderAux,{ |x| x[2] == cAliIte+"_NRTROL"})
nPosSequen  := ascan(aHeaderAux,{ |x| x[2] == cAliIte+"_SEQUEN"})

if allTrim( M->&(cAliIte+"_CODPRO") ) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) 

	if nDesPosPro > 0

		for nX := 1 to len(aColsAux)
			
			cDesForPro	:= alltrim(aColsAux[nX,nDesPosPro])

			if allTrim(M->&(cAliIte+"_DESPRO")) == cDesForPro .And. ;
				( Empty(alltrim(aColsAux[nX,nPosNrtrol])) .Or. Val(alltrim(aColsAux[nX,nPosNrtrol])) == 0 ) .And. ;
				( aColsAux[nX,nPosSequen] <> M->&(cAliIte+"_SEQUEN") )

				Aviso(STR0028,STR0404,{STR0146}, 2 ) //"Criticas" ### "Este procedimento j· foi adicionado."
				lRet := .F.
		
			endIf	

		Next nX
	endIf	

	//verifica se È codigo generico e nao deixa passar sem informar a descricao e valor
	If M->&(cAliIte+"_VLRAPR") == 0 
		cMsgGener += STR0196//"Valor"
	EndIf

	If Empty(M->&(cAliIte+"_DESPRO")) 
		cMsgGener += (Iif(!Empty(cMsgGener),"/","")+STR0127) //"DescriÁ„o"
	EndIf

	If &( cAliIte+"->( FieldPos('"+cAliIte+"_REGANV') )" ) > 0 .And. empty(M->&(cAliIte+"_REGANV")) .And. ;
	allTrim( M->&(cAliIte+"_CODPRO") ) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodOpmGen)    
		cMsgGener += (Iif(!Empty(cMsgGener),"/","")+STR0590) //"CÛdigo ANVISA"
	EndIf

	If &( cAliIte+"->( FieldPos('"+cAliIte+"_REFFED') )" ) > 0 .And. empty(M->&(cAliIte+"_REFFED")) .And. ;
	allTrim( M->&(cAliIte+"_CODPRO") ) $ allTrim(__cCodMatGen+"-"+__cCodOpmGen) 
		cMsgGener += (Iif(!Empty(cMsgGener),"/","")+STR0591) //"ReferÍncia do Fabricante"
	EndIf

	If !Empty(cMsgGener)
		Aviso( STR0586,STR0587+cMsgGener, { STR0146 }, 2 ) //"Evento genÈrico!" ### "Necess·rio informar o(s) campo(s): "
		lRet := .f.
	EndIf

else
	//verifica se foi informado pacote sem valor 
	if AllTrim(GetNewPar("MV_PLSUNI","1")) == "1" .And. M->&(cAliIte+"_VLRAPR") == 0 .And. M->&(cAliIte+"_PACOTE") == "1" .And. !lPTUOn80 // PTU 8, Valor do pacote encontram-se no SISPAC
		Aviso( STR0588,STR0589, { STR0146 }, 2 ) // "Pacote!" ### 
			lRet := .f.
		endIf	
	endIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL090IEvSA 

@author  PLS TEAM
@version P11
@since    29.06.15
/*/
//-------------------------------------------------------------------
Function PL090IEvSA()

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()
	PLSR432()       

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVerAnPTU 
Verifica se ha um evento 

@author  PLS TEAM
@version P11
@since    29.06.15
/*/
//-------------------------------------------------------------------
Function PLVerAnPTU(oObjBrw,cAliasIte,nOpc,cAlias)
	Local lRet     := .T.      
	Local nI   	   := 0 
	Local cCodPro  := ""   
Local cCodPad  := "" 
Local lAnexo   := .F.      
Local cNrtrol	 := ''    
Local aAreaBEA := BEA->(GetArea())
Local aAreaBE4 := {}
Default cAlias := "BEA"

B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF 
BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA 

If BR8->(FieldPos("BR8_ANEEDI")) == 0
	Return lRet
EndIf

For nI := 1 to len(oObjBrw:aCols)
	cCodPro := Alltrim(oObjBrw:aCols[nI,PLRETPOS(cAliasIte+"_CODPRO",oObjBrw:aHeader)])	   
	cCodPad := Alltrim(oObjBrw:aCols[nI,PLRETPOS(cAliasIte+"_CODPAD",oObjBrw:aHeader)])	
	cNrtrol := Alltrim(oObjBrw:aCols[nI,PLRETPOS(cAliasIte+"_NRTROL",oObjBrw:aHeader)])

	If BR8->(DbSeek(xFilial("BR8")+cCodPad+cCodPro)) .And. BR8->BR8_ANEEDI $ "123"  

		If Empty(cNrtrol)   
			lRet := .F.   

			If nOpc == 3
				MsgInfo(STR0592) //'Foi informado um Evento do tipo "Anexo", por gentileza incluir a Guia de Anexo e posteriormente realizar a comunicaÁ„o de interc‚mbio online.'
				Return(lRet)
			EndIf 

			If cAlias == "BE4
				cPesqAnex := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)    
				aAreaBE4 := BE4->(GetArea())
			Else
				cPesqAnex := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
			EndIf

			If B4A->( msSeek( xFilial("B4A") + cPesqAnex ) )
				While B4A->B4A_GUIREF == cPesqAnex .And. !B4A->(Eof())
					If Empty(B4A->B4A_NRTROL) 
						lAnexo 	:= .T.
						Exit
					EndIf  
					B4A->(DbSkip())
				EndDo 
			EndIf      

			If lAnexo
				lRet := .T.
			Else      
				lRet := .F.
				MsgInfo(STR0593) //"Foi informado um evento do tipo anexo, È necess·rio digitar uma guia de anexo para realizar a comunicaÁ„o." 
				nI := (len(oObjBrw:aCols)+1)
			EndIf         

			If cAlias == "BE4"
					RestArea(aAreaBE4)
				EndIf

			EndIf
		Endif
	Next

	RestArea(aAreaBEA)

Return lRet    	             

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEmpPtu 
define o arquivo de ini

@author  PLS TEAM
@version P11
@since    09.08.06
/*/
//-------------------------------------------------------------------
Static Function GetEmpPtu()
	LOCAL cIniFile := PLSMUDSIS("\plsptu.ini")

//Pega o conteudo da chave na enviroment correspondente em um arquivo		  

cEmpPos  := GetPvProfString( "SETUP", "Empresa"	, "01", cIniFile )
cFilPos  := GetPvProfString( "SETUP", "Filial" 	, "01", cIniFile )

//Grava o conteudo da chave na enviroment correspondente em um arquivo	  

Return {cEmpPos,cFilPos}


//-------------------------------------------------------------------
/*/{Protheus.doc} PL090EDPAC 
Libera o campo de digitacao de valor quando pacote

@author  PLS TEAM
@version P11
@since    09.08.06
/*/
//-------------------------------------------------------------------
Function PL090EDPAC(cAlias)
	Local aAreaBR8 := {}

	If (&("M->"+cAlias+"_PACOTE") == "1" .And. AllTrim(GETNEWPAR("MV_PLSUNI","1")) == "1") 
	&("M->"+cAlias+"_PEREVC") := "1"
Else
	&("M->"+cAlias+"_PEREVC") := "0"
EndIf 

If &("M->"+cAlias+"_PEREVC") == "0" 
	aAreaBR8 := BR8->(GetArea())

	BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
	If BR8->(DbSeek(xFilial("BR8")+&("M->"+cAlias+"_CODPAD")+&("M->"+cAlias+"_CODPRO")))
		&("M->"+cAlias+"_PEREVC") := IF(BR8->BR8_PODDIG$" ,1","1","0")	
		EndIf

		RestArea(aAreaBR8)
	EndIf

Return .T.   


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSNRAOPE 
Busca numero da transacao da Operadora

@author  PLS TEAM
@version P11
@since    17.02.16
/*/
//-------------------------------------------------------------------
Function PLSNRAOPE()

	LOCAL cTrOri    :="0000000001"
LOCAL lExTran   :=.F.

aAreaBEA := BEA->(GetArea())

If PLSALIASEX("BSN")

	cTrOri := StrZero( Val( BSN->(GetSx8Num("BSN","BSN_SEQUEN") ) ),10)
	BSN->(ConfirmSX8())

	SIX->(DbSetOrder(1))
	If SIX->( MsSeek("BEAM") )
		BEA->(DbSetOrder(22))//BEA_FILIAL + BEA_NRTROL
		If BEA->(DbSeek(xFilial("BEA")+cTrOri+Space( TamSX3("B0S_NUMSEQ")[1]-Len(cTrOri))+PlsIntPad()))
			While !lExTran
				cTrOri := Strzero(val(cTrOri)+1,10)
				If !BEA->(DbSeek(xFilial("BEA")+cTrOri))
					lExTran := .T.
				EndIf
			EndDo
		EndIf
	EndIf

	BSN->(RecLock("BSN",.T.))
	BSN->BSN_FILIAL := xFilial("BSN")
		BSN->BSN_SEQUEN := cTrOri
		BSN->(MsUnLock())
	EndIf

	BEA->(RestArea(aAreaBEA))

Return(cTrOri)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL90InfPro 
define o arquivo de ini

@author  PLS TEAM
@version P11
@since    04.04.16
/*/
//-------------------------------------------------------------------
Function PL90InfPro(cAlias) 
	Local aArea := GetArea()      
	Local cChaveBQV  := ""
Local lInterProt := .F.                     
Local lEmptyCAB  := .F. 
Local lEmptyBQV  := .F.
Local lOkAlt     := .F.
Local cMatric    := ""
Local cNrTrol    := ""

//Verifica o cabecalho
If Empty( &(cAlias+"->"+cAlias+"_PROATE") )     
	lEmptyCAB := .T.
EndIf

If cAlias == "BEA"
	cChaveBQV := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) 
	cMatric   := BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
	cNrTrol   := BEA->BEA_NRTROL
ElseIf cAlias == "BE4"
	cChaveBQV := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)   
	cMatric   := BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
	cNrTrol   := BE4->BE4_NRTROL
EndIf	

//Verifica os itens de complemento
If !lEmptyCAB

	BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
	If BQV->(DbSeek(xFilial("BQV")+cChaveBQV ))
		While xFilial("BQV")+cChaveBQV == xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .And. !BQV->(Eof())
			If Empty(BQV->BQV_PROATE)
				lEmptyBQV := .T.
				cNrTrol   := BQV->BQV_NRTROL
				Exit
			EndIf
			BQV->(DbSkip())
		EndDo
	EndIf                

EndIf

If lEmptyCAB .Or. lEmptyBQV

	If GETNEWPAR("MV_PLSUNI","1") =="1" .And. &(cAlias+"->"+cAlias+"_CODEMP") == GetNewPar("MV_PLSGEIN","0050")
		lInterProt := .T.    
	EndIf    

	cNumProto := Space(20)
	If GetNewPar("MV_PL395WS","0") == "1" .And. PLSALIASEX("B4J")   
		PL773WEBRN(@cNumProto,cMatric,.F.,cAlias,cNrTrol)
		If !Empty(cNumProto)
			lOkAlt := .T.
		EndIf
	Else
		P773AutInc(cAlias,@cNumProto,nil,lInterProt,.F.,nil,nil,@lOkAlt,cMatric)            
	EndIf           

	//Conclui um protocolo    
	If lOkAlt .And. !Empty(cNumProto) .And. lInterProt
		P773AutCon(cAlias,cNumProto,cChaveBQV)
	EndIf

	If lOkAlt .And. !Empty(cNumProto) .And. lEmptyCAB
		&(cAlias+"->(RecLock('"+cAlias+"',.F.))")   
		&(cAlias+"->"+cAlias+"_PROATE") := cNumProto
		&(cAlias+"->(MsUnlock())")                   

		MsgInfo(STR0581+cNumProto)//"Protocolo registrado: "
	EndIf     

	If lOkAlt .And. !Empty(cNumProto) .And. lEmptyBQV .And. BQV->(DbSeek(xFilial("BQV")+cChaveBQV ))
		While xFilial("BQV")+cChaveBQV == xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .And. !BQV->(Eof())
			If Empty(BQV->BQV_PROATE)
				BQV->(RecLock("BQV",.F.))
				BQV->BQV_PROATE := cNumProto
				BQV->(MsUnLock())
			EndIf
			BQV->(DbSkip())
		EndDo   
		MsgInfo(STR0581+cNumProto)//"Protocolo registrado: "
	EndIf
Else
	MsgInfo(STR0582)//"O protocolo j· foi registrado para este atendimento."
	Endif  

	RestArea(aArea)

Return

/*/{Protheus.doc} PLSXBGUIORI 
Executa a consulta de internaÁ„o e SADT

@author  Lucas Nonato
@version P11
@since   08/07/2016
/*/
Function PLSXBGUIORI()
	Local cSql 		:= ""
local cWhr 		:= ""
local cRet 		:= ""
Local aIndices 	:= {}
Local aHeader 	:= {}
Local lRet		:= .F.
Local oConsulta	:= Nil
Local aArea 	:= GetArea()
//Monta a query da consulta padrao																	
//Converte primeiro campo para string pois o mesmo eh chave na consulta padrao e na pesquisa do mesmo
cSQL	:= " SELECT BE4_OPEUSR + BE4_ANOINT+ BE4_MESINT+ BE4_NUMINT AS ATENDIMENTO, "
cSQL	+= " (BE4_OPEUSR + BE4_CODEMP+ BE4_MATRIC+ BE4_TIPREG+ BE4_DIGITO) AS MATRIC, "
cSQL	+= " BE4_DATPRO AS DATPRO, "
cSQL	+= " BE4_DTALTA AS DTALTA, "
cSQL	+= " 'InternaÁ„o' AS TIPO FROM " + RetSQLName("BE4")
cWhr 	:= " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  (BE4_CODOPE+ BE4_CODEMP+ BE4_MATRIC+ BE4_TIPREG+ BE4_DIGITO) = '"+M->BE1_USUARI+"' AND  BE4_DATPRO <> ' ' AND BE4_DTALTA = ' ' AND D_E_L_E_T_ = ''"


IF EXISTBLOCK("PL90ALTA")
	cRet := EXECBLOCK("PL90ALTA", .F., .F., cWhr)	//	cWhr - WHERE da Query
	IF VALTYPE(cRet) == "C" .AND. "WHERE " $ UPPER(cRet)
		cWhr := " " + ALLTRIM(cRet) 
	ENDIF
ENDIF
cSql += cWhr

cSQL	+= " UNION ALL " 
cSQL	+= " SELECT (BD5_OPEUSR + BD5_ANOAUT + BD5_MESAUT + BD5_NUMAUT) AS ATENDIMENTO, "
cSQL	+= " (BD5_OPEUSR + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG + BD5_DIGITO) AS MATRIC, "
cSQL	+= " BD5_DATPRO AS DATPRO, "
cSQL	+= " ' ' AS DTALTA, "
cSQL	+= " 'Sadt' AS TIPO FROM " + RetSQLName("BD5")
cSQL	+= " WHERE BD5_FILIAL= '" + xFilial("BD5")+ "' AND  (BD5_OPEUSR + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG + BD5_DIGITO) = '"+M->BE1_USUARI+"' AND  BD5_DATPRO <> ' ' AND D_E_L_E_T_ = ''"


//Monta a aHeader da consulta≥
SX3->( dbSetOrder( 2 ) )
SX3->( dbGotop(  ) )
If SX3->( dbSeek( "BE4_NUMINT", .F. ) )
	Aadd(aHeader,{'Atendimento','ATENDIMENTO+MATRIC+DATPRO+DTALTA+TIPO',SX3->X3_PICTURE,20,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
	aAdd( aIndices, {'Atendimento','Atendimento'})
Endif

If SX3->( dbSeek( "BE4_MATRIC", .F. ) )
	Aadd(aHeader,{"Matricula",'Matricula',SX3->X3_PICTURE,15,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
Endif

If SX3->( dbSeek( "BE4_DATPRO", .F. ) )
	Aadd(aHeader,{'Data Procedimento','DATPRO',SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
Endif

If SX3->( dbSeek( "BE4_DTALTA", .F. ) )
	Aadd(aHeader,{'Data Alta','BE4_DTALTA',SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
Endif

If SX3->( dbSeek( "BE4_NOMRDA", .F. ) ) // Usado o campo NOMRDA apenas para pegar o tamanho do campo, pois se fosse usado TIPGUI pegaria tamanho 02
	Aadd(aHeader,{'Tipo','BE4_NOMRDA',SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
Endif


//Monta a consulta padrao≥
oConsulta				:=	PlsIntSxb():New()
oConsulta:cTitle 		:= "Consulta Guia Principal" 					    							//Titulo da Consulta
oConsulta:cQuery 		:= cSql															//Query dos dados a serem apresentados
oConsulta:aIndex 		:= aIndices														//Indices disponiveis (deve usar os mesmos campos da query)
oConsulta:aHeader 	:= aHeader                      								//Header da grid presente consulta (deve usar os mesmos campos da query)
oConsulta:aReturn		:= {'ATENDIMENTO+MATRIC+DATPRO+DTALTA+TIPO'}					//Campos de retorno da consulta (deve usar os mesmos campos da query)
oConsulta:lDataBaseRM 	:= .T.															//Indica se a query eh executada na base do protheus ou da RM
oConsulta:Show()

//Coleta o retorno
	If Len(oConsulta:aRetSXB) > 0
		cCodIntSxb 	:= oConsulta:aRetSXB[1]
		lRet 		:= .t.
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} PLSVLDSADT 
Verifica se existe a Guia de SADT. 

@author  Lucas Nonato	
@version P11
@since   11/07/2016
/*/
Function PLSVLDSADT(cGuiaIntPri)
	Local lret :=.T.
	Local cSQL := ""
Local aArea := GetArea()


If !IsInCallStack("PLPESINTSXB").and. !Empty(cGuiaIntPri)

	cSQL	:= " SELECT (BD5_ANOAUT + BD5_MESAUT + BD5_NUMERO) AS ATENDIMENTO, "
	cSQL	+= " (BD5_OPEUSR + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG + BD5_DIGITO) AS MATRIC, "
	cSQL	+= " BD5_DATPRO AS DATPRO " + RetSQLName("BD5")
	cSQL	+= " WHERE BD5_FILIAL= '" + xFilial("BD5")+ "'  AND D_E_L_E_T_ = ''"

	PLSQuery(cSQL,"Trb")

	If  Trb->(Eof())
		Aviso( STR0120, ; //"Atencao"
		STR0594,; //"N„o h· guia para esse cÛdigo"
		{ STR0146 }, 2 )//"Ok"
			lRet:=.F.
		EndIf
		Trb->(DbCloseArea())
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} PLATUSTBOW 
Atualiza Status da BOW (PROTOCOLO DE REEMBOLSO) DENTRO DA BEGIN 

@author  Robson nayland
@version P11
@since   07/03/2017
/*/
Function PLATUSTBOW(aRetorno, lProtoc, nOpc, lReembCriaBD5)
	Local nI:=0
	Local cChaveB45 := ""  
Local nIndice   := 0 
LOCAL oBrwPro   := Pl001ROp() 

If aRetorno [1] .AND. PLSALIASEXI("BOW") .AND. PLSALIASEXI("BOX")

	DbSelectArea("BOW")
	BOW->(DbSetOrder(1))
	BOW->(DbSeek(xFilial("B44")+B44->B44_PROTOC))
	BOW->(RecLock('BOW',.F.))

	If nOpc == K_Incluir

		If aRetorno[9] //Auditoria?

			BOW->BOW_STATUS := '9' //Auditoria

	/*	ElseIf M->B44_FORPAG == '0'

			//Se a forma de pagamento for via fatura, a autorizaÁ„o deve entrar
			//com o staus de aprovado e na digitaÁ„o de contas com o status faturado.
			BOW->BOW_STATUS := '6' //Liberado financerio*/
		Else
			BOW->BOW_STATUS := '5' //Em DigitaÁ„o
		EndIf

		BOW->BOW_ANOAUT := aRetorno [3]
		BOW->BOW_MESAUT := aRetorno [4]


	ElseIf nOpc == K_Excluir

		BOW->BOW_STATUS := '3'
		BOW->BOW_ANOAUT := ''
		BOW->BOW_MESAUT := ''
		BOW->BOW_CODLDP := ''
		BOW->BOW_CODPEG := ''
		BOW->BOW_NUMAUT := ''
		BOW->BOW_ORIMOV := ''
		BOW->BOW_MOTIND := ''
		BOW->BOW_PGMTO  := STR0169
		BOW->BOW_VLRREE := 0
		BOW->BOW_PREFIX := ''
		BOW->BOW_NUM := ''
		BOW->BOW_PARCEL := ''

		If FindFunction("AtuCmpB1N")
			AtuCmpB1N(oBrwPro, .T.)
		EndIf

	EndIf

	BOW->( MsUnlock() )

	PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS, BOW->BOW_NUMAUT, /*cNumCC*/, /*dDtBaix*/, /*cObs*/, BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_ORIMOV, BOW->BOW_NPROCE)

elseif !lReembCriaBD5 .and. aRetorno [1] .AND. lProtoc .and.  nOpc == K_Excluir

	DbSelectArea("BOW")
	BOW->(DbSetOrder(1))
	BOW->(DbSeek(xFilial("B44")+B44->B44_PROTOC))
	BOW->(RecLock('BOW',.F.))
	BOW->BOW_STATUS := '3'
	BOW->BOW_MOTIND := ''
	BOW->BOW_PGMTO  := STR0169
	BOW->BOW_VLRREE := 0
	BOW->BOW_PREFIX := ''
	BOW->BOW_NUM := ''
	BOW->BOW_PARCEL := ''
	BOW->( MsUnlock() )

	//Grava o histÛrico da alteraÁao do status do protocolo
	PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS, BOW->BOW_NUMAUT, /*cNumCC*/, /*dDtBaix*/, /*cObs*/, BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_ORIMOV, BOW->BOW_NPROCE)

	cChavBD6 :=  BOW->(BOW_OPEMOV+BOW_CODLDP+BOW_CODPEG+BOW_NUMGUI)

	BD5->(DbSetOrder(1))

	If BD5->(MsSeek(xFilial("BD5") + cChavBD6))			

		While BD5->( BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO) == xFilial("BD5") + cChavBD6  .AND. !BD5->(EoF())
			BD5->( RecLock("BD5",.F.) )
			BD5->BD5_FASE := "1" //Alterando Para Faturada
			BD5->( MsUnLock() )
			BD5->(DbSkip())
		endDo

	endIf

	//Atualiza Status da BD6. FASE/SITUACAO
	cChavBD6 :=  BOW->(BOW_OPEMOV+BOW_CODLDP+BOW_CODPEG+BOW_NUMGUI+"5" /*Origem Movto Classes*/)

	BD6->(DbSetOrder(1))

	If BD6->(MsSeek(xFilial("BD6") + cChavBD6))			

		While BD6->( BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6") + cChavBD6  .AND. !BD6->(EoF())		//Para cada procedimento
			BD6->( RecLock("BD6",.F.) )
			BD6->BD6_STATUS := "0" //Alterando Status para N„o Autorizado. Abaixo os itens aprovados ter„o seu status alterado para autorizado.
			BD6->BD6_FASE := "1" //Alterando Para Faturada
			BD6->( MsUnLock() )

			BD6->(DbSkip())
		endDo

	endIf

endIf
//Retorna saldo da liberaÁ„o vinculada ao reembolso
If nOpc == K_Excluir

	For nI := 1 To Len(oBrwPro:aCols)

		If ValType(oBrwPro:FieldGet("B45_NUMLIB",nI)) == "C" //Quando foi pra auditoria ele n„o gerou o NUMLIB, caso a autorizaÁ„o for excluÌda nesse momento, gerava erro

			If oBrwPro:FieldGet("B45_STATUS",nI) == "1"	 

				//Retorna o saldo ao estado anterior da liberaÁ„o SADT levando em consideraÁ„o o sequencial caso exista o campo B45_SEQBE2
				If B45->(FieldPos("B45_SEQBE2")) > 0 

					nIndice := 1
					cChaveB45 := xFilial("BE2") + oBrwPro:FieldGet("B45_NUMLIB",nI) + oBrwPro:FieldGet("B45_SEQBE2",nI)	
				Else
					nIndice := 6
					cChaveB45 := xFilial("BE2") + oBrwPro:FieldGet("B45_NUMLIB",nI) + oBrwPro:FieldGet("B45_CODPAD",nI) +;
					oBrwPro:FieldGet("B45_CODPRO",nI)
				EndIf 

				BE2->(dbSetOrder(nIndice)) 
				If BE2->(dbSeek(cChaveB45 )) 

					BE2->( RecLock("BE2",.F.) )
					BE2->BE2_SALDO  += oBrwPro:FieldGet("B45_QTDPRO",nI) 
					BE2->BE2_QTDPRO -= oBrwPro:FieldGet("B45_QTDPRO",nI) 

					If BE2->BE2_SALDO >= 0 
						BE2->BE2_STALIB := '1'//em aberto
					Endif
					BE2->( MsUnLock() )



					BEA->(dbSetOrder(1))
					BEA->(dbSeek(xFilial("BEA") + oBrwPro:FieldGet("B45_NUMLIB",nI)))
					PLSATUCS("1")
					EndIf

				EndIf

			EndIf

		Next

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090DPR

@author  Cesar Augusto da Silva
@version P12
@since   27.07.17
/*/
//-------------------------------------------------------------------
Function PLSA090DPR()
	LOCAL lRet := .T.
	Local cMsg := "" 

If !Empty(M->BE1_NUMLIB) .AND. !Empty(M->BE1_DATPRO) .AND. IsInCallStack("PLSA094A")
	If M->BE1_DATPRO > dDatabase 
		cMsg := "A data do procedimento È maior que a data atual!"
	ElseIf M->BE1_DATPRO < dDatabase
		cMsg := "A data do procedimento È menor que a data atual!"
	EndIf

	If !Empty(cMsg)
		MsgStop(cMsg)
		lRet := .F. 
	EndIf
ElseIf Empty(M->BE1_NUMLIB)
	If M->BE1_DATPRO > dDatabase 
		MsgStop("A data do procedimento È maior que a data atual!")
			lRet := .F. 
		EndIf
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PL90IteRis
Valida se itens de uma Grid sao de Baixo Risco

@author  Renan Sakai
@version P12
@since   14/07/2017
/*/
//-------------------------------------------------------------------  
Function PL90IteRis(oBrwPro)
	Local cCodPad   := ""
Local cCodPro   := ""
Local nX        := 0     
Local nPos      := 0
Local lRet      := .T.

BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN

For nX := 1 to len(oBrwPro:aCols)      
	nPos := AScan(oBrwPro:aHeader,{|x| x[2] == oBrwPro:cAlias + "_CODPAD"})
	cCodPad    := oBrwPro:aCols[nX][nPos]

	nPos := AScan(oBrwPro:aHeader,{|x| x[2] == oBrwPro:cAlias + "_CODPRO"})
	cCodPro    := oBrwPro:aCols[nX][nPos]

	If !(BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro)) .And. BR8->BR8_RISCO == "1")
			lRet := .F.
			Exit
		EndIf
	Next

Return lRet


/*/{Protheus.doc} MSGCOMINT
Mensagens PTU
@author jose.paulo
@since 13/07/2017
/*/
Function MSGCOMINT(aMsgPtu,cTpMov,nOpc,cMatUsu,cAliCab,nRecCab,oGetBZC)
Local nMsg        := 0       
Local cIndcli     := ""       
Local cObsNt      := ""       
Local cJustTec    := ""       
Local cEspMat     := ""       
Local cChvGui     := "" 
LOCAL I__f 		  := 0
LOCAL oDlg        := NIL
LOCAL bOk 		  := {|| oDlg:End() }
LOCAL bCancel 	  := {|| oDlg:End() }
LOCAL cAlias      := "BZC"
LOCAL cChave 	  := ""
LOCAL aChave	  := {}
LOCAL aHeader 	  := {}
LOCAL aCols       := {}
LOCAL aTrab       := {}
LOCAL lChkBZC     := .F.  
LOCAL lEncBzc     := .T.
Local lGrv		  := .F.
local lIncAltBZC  := .f.
local nT := 0	

DEFAULT cMatUsu   := ""
DEFAULT nOpc	  := 2 //Visualizar
DEFAULT cTpMov    := ""      //cTpMov = 1  Inclusao de registro na BZC     cTpMov = 2 Visualizacao da Tabela
DEFAULT aMsgPtu   :={}    
DEFAULT cAliCab   := ""
DEFAULT oGetBZC   := NIL

BZC->(DbSetORder(1))       
BD5->(DbSetORder(2))       
BE4->(DbSetORder(1)) 

If ! PLSALIASEX("BZC")
	Return
EndIf

If nOpc == K_Incluir  
	cChave :=""
Else
	If cTpMov == "2" .And. nRecCab > 0 .And. !Empty(cAliCab)

		If cAliCab == "BEA"

			BEA->(DbGoTo(nRecCab))
			cChave:= &(cAliCab+"->"+cAliCab+"_FILIAL") + &(cAliCab+"->"+cAliCab+"_OPEMOV") + &(cAliCab+"->"+cAliCab+"_CODLDP") + &(cAliCab+"->"+cAliCab+"_CODPEG") + &(cAliCab+"->"+cAliCab+"_NUMGUI")

		ElseIf cAliCab == "BD5"

			BD5->(DbGoTo(nRecCab))
			cChave:= &(cAliCab+"->"+cAliCab+"_FILIAL") + &(cAliCab+"->"+cAliCab+"_CODOPE") + &(cAliCab+"->"+cAliCab+"_CODLDP") + &(cAliCab+"->"+cAliCab+"_CODPEG") + &(cAliCab+"->"+cAliCab+"_NUMERO")			

		ElseIf cAliCab == "BE4"

			BE4->(DbGoTo(nRecCab))
			cChave:= &(cAliCab+"->"+cAliCab+"_FILIAL") + &(cAliCab+"->"+cAliCab+"_CODOPE") + &(cAliCab+"->"+cAliCab+"_CODLDP") + &(cAliCab+"->"+cAliCab+"_CODPEG") + &(cAliCab+"->"+cAliCab+"_NUMERO")

		EndIf		
	EndIf		
EndIf

IF Empty(cMatUsu) .And. !IsInCallStack("PROCA50")  

	Help("",1,"PLSA090USR")	
	Return

Else

	If cTpMov == "2" .And. !Subs(cMatUsu,5,4) == GetNewPar("MV_PLSGEIN","0050") 

		If nOpc <> K_Visualizar .And. !IsInCallStack("PLSA500MOV")  

			MsgInfo(STR0637) 

			Return	            

		EndIf

	EndIf

EndIf

//Trecho utilizado para importacao do A500.
If !Empty(cTpMov) .And. len(aMsgPtu) > 0  .And. cTpMov == "1"

	For nMsg := 1 To LEN(aMsgPtu)

		if cChvGui <> RTRIM(aMsgPtu[nMsg,3])
			cIndcli := ""
			cObsNt		 := ""
			cJustTec := ""
			cEspMat	:= ""
			
			If !Empty(aMsgPtu[nMsg,2])

				cAliMsg:= aMsgPtu[nMsg,1]
				cChvGui:= RTRIM(aMsgPtu[nMsg,3])

				for nT := 1 to len(aMsgPtu) 

					if (aMsgPtu[nT,3] == cChvGui)

						If aMsgPtu[nT,4] = "1"

							cIndcli  += AllTrim(aMsgPtu[nT,2])

						ElseIf aMsgPtu[nT,4] = "2"

							cObsNt   += AllTrim(aMsgPtu[nT,2])

						ElseIf aMsgPtu[nT,4] = "3"

							cJustTec += AllTrim(aMsgPtu[nT,2])

						ElseIf aMsgPtu[nT,4] = "4"

							cEspMat  += AllTrim(aMsgPtu[nT,2])

						EndIf
					
					endif	

				next
			EndIf


			If cAliMsg == "BE4" .AND. BE4->(MSseek(cChvGui))
				lGrv := .T.
			elseif cAliMsg == "BD5" .AND. BD5->(MSseek(cChvGui))
				lGrv := .T.
			Endif

			if lGrv
				&(cAliMsg+"->(RecLock('"+cAliMsg+"',.F.))")

				If !Empty(cIndCli)

					&(cAliMsg+"->"+cAliMsg+"_INDCLI"):= subs(cIndCli,1,250)

					If LEN(cIndCli) > 250
						&(cAliMsg+"->"+cAliMsg+"_INDCL2") := subs(cIndCli,251)
					EndIf

				EndIf

				&(cAliMsg+"->( MsUnlock() )")
			EndIf

			if BZC->(MsSeek(xFilial("BZC")+cChvGui))
				lIncAltBZC := .f.
			else
				lIncAltBZC := .t.
			endif

				BZC->(Reclock("BZC",lIncAltBZC))	
				BZC->BZC_FILIAL := xFilial("BZC")
				BZC->BZC_ALIAS  := cAliMsg
				BZC->BZC_CHVGUI := cChvGui

				If !Empty(cObsNt) 
					BZC->BZC_OBSNO1:= subs(cObsNt,1,250) 
					BZC->BZC_OBSNO1:= subs(cObsNt,1,250) 
				EndIf

				If !Empty(cJustTec)

					BZC->BZC_JUSTE1 := subs(cJustTec,  1,250)
					BZC->BZC_JUSTE2 := subs(cJustTec,251,250)
					BZC->BZC_JUSTE3 := subs(cJustTec,501,250)
					BZC->BZC_JUSTE4 := subs(cJustTec,751,250)

				EndIf

				If !Empty(cEspMat)

					BZC->BZC_ESMAT1:= subs(cEspMat,  1,250)
					BZC->BZC_ESMAT2:= subs(cEspMat,251,250)
					BZC->BZC_ESMAT3:= subs(cEspMat,501,250)
					BZC->BZC_ESMAT4:= subs(cEspMat,751,250)

				EndIf

				BZC->(MsUnlock())

		endif
	Next	

EndIf	

//neste ponto eh quando o usuario abre a tela p·ra digitar as informacoes
If !Empty(cTpMov) .And. cTpMov == "2" 

	If nOpc == K_Incluir .And. ValType(oGetBZC)<>"O"
		Copy "BZC" To Memory Blank
	Else 
		Copy "BZC" TO Memory
	Endif     

	Store Header "BZC" TO aHeader For .T.

	If ValType(oGetBZC) <> "O"

		BZC->(dbSetOrder(1))  
		If Empty(cChave) .Or. ! BZC->(MsSeek(xFilial("BZC")+cChave))
			Store COLS Blank "BZC" TO aCols FROM aHeader
		Else
			Store COLS "BZC" TO aCols FROM aHeader VETTRAB aTrab While RTRIM(BZC->(BZC_CHVGUI)) == cChave
		EndIf             
	Else                
		If LEN(aCols) == 0 .And. LEN(aHeader) > 0 
			aCols:=oGetBZC:aCols 
		EndIf	
	EndIf	

	DEFINE MSDIALOG oDlg TITLE STR0635 FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()           

	oGetBZC 		 := TPLSBrw():New(040,001,355,190,nil,oDLG,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,'BZC',nOpc,STR0635,nil,nil,nil,aTrab)
	oGetBZC:lAddLine := .F.

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) })

	If nOpc > 0
		oGetBZC:nOpc:= nOpc
	EndIf

	If nOpc == 4 .And. ValType(oGetBZC) == "O"
			aCols       := oGetBZC:aCols
			oGetBZC:nOpc:= 4
		EndIf 

	EndIf	

Return oGetBZC

//-------------------------------------------------------------------
/*/{Protheus.doc} atuProCanc
Atualiza o protocolo quando realizado o cancelamento de atendimento

@author  PLS TEAM
@version P11
@since   11/07/2016
/*/
//-------------------------------------------------------------------  
Static Function atuProCanc(cTranOri,cOpeDes,cMsgLivre)
	Local cCodTraPro := ""
Local cSql       := ""
Local cMsg       := ""
Local aRetWeb    := {}
Local aDadUsr    := {}
Local nX         := 0                

B00->(DbSetOrder(5))//B00_FILIAL+B00_NRTROL+B00_OPESOL
If B00->(DbSeek(xFilial("B00")+cTranOri+Space(TamSx3("B00_NRTROL")[1]-len(cTranOri))+PlsIntPad()))

	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(DbSeek(xFilial("BA0")+cOpeDes))

	aDadUsr    := PLSDADUSR(B00->B00_MATRIC,"1",.F.,dDataBase)
	cCodTraPro := PLB4JRegTr(PlsIntPad(),cOpeDes,"010")

	MsAguarde( {|| aRetWeb := PLCanProRN(PlsIntPad(),cOpeDes,"",cCodTraPro,dDatabase,cUserName,;
	Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13), cMsgLivre , B00->B00_COD) }, 'Comunicando' , "Aguarde", .F.)

	If aRetWeb[1]
		cSql := " SELECT MAX(B4I_SEQUEN) SEQUEN FROM "+RetSqlName("B4I")
		cSql += " WHERE B4I_PROTOC = '"+B00->B00_COD+"'"
		cSql += " AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql)

		DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , "TMP" , .F. , .T. )
		DBSelectArea("TMP")
		TMP->(DBGoTop())
		If TMP->(!Eof()) .And. B00->B00_CANCEL <> "1"
			B4I->(RecLock("B4I",.T.))
			B4I->B4I_FILIAL  := xFilial("B4I")
			B4I->B4I_SEQUEN  := Soma1(TMP->SEQUEN)
			B4I->B4I_PROTOC  := B00->B00_COD
			B4I->B4I_MENSAG  := cMsgLivre
			B4I->B4I_STATUS  := "4"
			B4I->B4I_DATRES  := dDataBase
			B4I->B4I_HORRES  := StrTran(Time(),":","")
			B4I->(MsUnLock())

			B00->(RecLock("B00",.F.))
			B00->B00_STAINT := "4"
			B00->B00_CANCEL := "1"
			B00->(MsUnLock())
		EndIf
		TMP->(DbCloseArea())    
		MsgInfo("Protocolo cancelado com sucesso.")
	Else
		cMsg   := "N„o foi possÌvel solicitar cancelar o Protocolo deste atendimento. CrÌticas:"+Chr(10)+Chr(10)
		For nX := 1 to len(aRetWeb[2])
			cMsg += Alltrim(aRetWeb[2][nX][1])+"-"+Alltrim(aRetWeb[2][nX][2])+Chr(10)
			Next
			MsgInfo(cMsg)
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelMovAud
Ao excluir a Guia, esta funÁ„o deleta movimentaÁıes da nova auditoria

@author  PLS TEAM
@version P12
@since   27/02/2018
/*/
//-------------------------------------------------------------------  

Function DelMovAud(cChNAud)  

	Local   nI       := 0  
	Local   aAliUti  := {"B68","B69","B70","B71","B73"}
Local cAliNAud   := "" 
Default cChNAud  := ""

IF !Empty(cChNAud)

	For nI:= 1 To Len(aAliUti)
		cAliNAud:= aAliUti[nI]
		&(cAliNAud)->(DbSetOrder(1))

		If &(cAliNAud)->(DbSeek(xFilial(cAliNAud)+cChNAud))
			While !&(cAliNAud)->(Eof()) .And. &(cAliNAud+"->("+cAliNAud+"_FILIAL+"+cAliNAud+"_ALIMOV+"+cAliNAud+"_RECMOV)") == xFilial(cAliNAud)+cChNAud	                                   	 

					&(cAliNAud)->(RecLock(cAliNAud,.F.))
					&(cAliNAud)->(DbDelete())
					&(cAliNAud)->(MsUnlock())

					&(cAliNAud)->(DbSkip())
				EndDo	
			EndIf
		Next
	EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} PLFSENBX
Verifica aparametrizaÁ„o do campo BX4_FORSEN - campo utilizado para solicitar ou nao a senha para forcar procedimentos

@author  PLS TEAM
@version P12
@since   24/03/2018
/*/
//-------------------------------------------------------------------  

Function PLFSENBX()

	LOCAL cIntPad    :=PLSINTPAD()
	LOCAL cOperad    :=RetCodUsr()  
	LOCAL lRet       := .T.
	LOCAL lTemBx4    := BX4->(FieldPos("BX4_FORSEN"))>0

If lTemBx4
	BX4->(DbSetOrder(1))       
	If BX4->( MsSeek(xFilial("BX4")+cOperad+cIntPad) ) .And. BX4->BX4_FORSEN == "0"  	
			lRet:=.F.
		EndIf
	EndIf	

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PLIBAUD

@author  PLS TEAM
@version P12
@since   05/2018
/*/
//-------------------------------------------------------------------  

Function PLIBAUD(cChavLib,lAud)

	local lRet       := .F.
	local lLibAud    := getNewPar("MV_PLIBAUD",.F.)

default lAud := .f.

if lLibAud

	BE2->(DbSetOrder(1))
	if BE2->( msSeek( xFilial("BE2") + cChavLib ) )
		if !lAud
			While BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2")+cChavLib .And. !BE2->(Eof())
				If BE2->BE2_STATUS == '1' .AND. BE2->BE2_SALDO > 0 
					lRet := .T.
				EndIf
				BE2->(DbSkip()) 
			enddo
		else
			While BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2")+cChavLib .And. !BE2->(Eof())
				If BE2->BE2_AUDITO == '1' 
						lRet := .T.
					EndIf
					BE2->(DbSkip()) 
				enddo
			endIf   
		endIf

	endIf

Return lRet


/*/{Protheus.doc} PLSProcAto
Gera as informaÁıes de cobranÁa para guias com procedimentos que necessitam de pagamento no ato
@param cAliasPri, characters, Alias do cabecalho conta medica
@param cAliasCab, characters, Alias do cabecalho da guia
@param cAliasIte, characters, Alias do item da guia
@param cMatric, characters, Matricula do beneficiario
@param cTipoRotEsp, characters, 1-Autorizacao SADT/2-Liberaca SADT
@param aDadUsr, array, Dados do Beneficiario
@param lAutori, logical, Utilizado na mudanca de fase 
@param lReanaliza, logical, Utilizado na mudanca de fase
@param lWeb, logical, Indica se o processamento esta sendo realizado via Portal do Prestador
@param lMudarFase, logical, Indica se deve mudar a fase da guia
@param lOnlyIte, logical, Indica se calcula somente o evento posicionado
@param lSolicit, logical, descricao
@param cChaveLib, characters, Chave da Liberacao
@param dVencto, data, Data de vencimento do titulo
@param cChavSE1, characters, Chave do Titulo
@param cTipTit, characters, Tipo do Titulo
@param cParcTit, characters, Numero da parcela do Titulo
@param cPrefixo, characters, Prefixo do Titulo
@param cNumTit, characters, Numero do Titulo
@param lJaMudou, logical, Variavel logica que indica que a fase ja foi avanÁada para nao mudar novamente na continuacao da funcao de processamento anterior
/*/
function PLSProcAto(cAliasPri,cAliasCab,cAliasIte,cMatric,cTipoRotEsp,aDadUsr,lAutori,lReanaliza,lWeb,lMudarFase,;
	lOnlyIte,lSolicit,cChaveLib,nOpc,dVencto,cChavSE1,cTipTit,cParcTit,cPrefixo,cNumTit,lJaMudou)

	local aVlrAuxPAG 	:= {{.T.,{},0,"C"},{},{},{},{},{},{}}
local aRetAux 		:= {}
local aDadGPE 		:= {}
local cVerba		:= ""
local cTpPlan		:= ""
local cCodFor		:= ""
local cSeqDep		:= ""
local cPlanGPE		:= ""
local cCodTab 		:= ""
local cCodEvePAG 	:= ""
local cCodTES 		:= ""
local cCodSB1 		:= ""
local cFase 		:= ""
local cWhileBD6 	:= ""
local cChaveBD6 	:= ""
local cMatFam		:= ""
local cAnoPag		:= ""
local cMesPag		:= ""
local lDirf11 		:= (PLSALIASEX("RHK") .and. RHK->(FieldPos("RHK_PD"))>0 .and. RHK->(FieldPos("RHK_PDDAGR"))>0 .and. BA1->(FieldPos("BA1_CODDEP"))>0 )
local lTitGer		:= .F.
LOCAL aAreaBD6 	 	:= BD6->(GetArea())
local cOpeMov 		:= ""
local cCodLdp 		:= ""
local cCodPeg 		:= ""
local cNumGui 		:= ""
local cOriMov 		:= ""
local dDatPro 		:= ""
local cSeqPro 		:= ""
local cCodPad 		:= "" 
local cCodPro 		:= ""
local lAudCarol     := IsInCallStack('BSCGUIPOST')
local lLogCarol     := GetNewPar("MV_PCARLOG","0") == "1"
local cDateTime     := ''
Local nValComp		:= 0
Local nVlrCon		:= 0
Local cNumAut		:=''

//Parametros de entrada
default cAliasPri	:= ""
default cAliasCab	:= ""
default cAliasIte	:= ""
default cMatric		:= ""
default cTipoRotEsp	:= ""
default aDadUsr	 	:= {}
default lAutori		:= .T.
default lReanaliza	:= .T.
default lWeb		:= .F.
default lMudarFase	:= .F.
default lOnlyIte 	:= .F.
default lSolicit	:= .F.
default cChaveLib	:= ""
default nOpc		:= K_Incluir
//Parametros de saida
default dVencto		:= dDataBase
default cChavSE1	:= ""
default cTipTit 	:= ""
default cParcTit	:= ""
default cPrefixo	:= ""
default cNumTit		:= ""
default lJaMudou 	:= .F.

If nOpc == K_Incluir
	if lAudCarol
		lWeb := .T.
	endIf
	
	If !IsInCallStack("PLSA790") .And. cPaisLoc == "BRA" .And. ExistBlock("PLSA090CRT")
		cChavSE1 := ExecBlock("PLSA090CRT",.F.,.F.,{cPrefixo,cNumTit,cTipTit,dVencto,K_Incluir,cParcTit,cTipoRotEsp})
	Else
		//Retorna as informacoes da guia de acordo com o Alias do cabecalho
		If cAliasPri == "BE4"
			BEA->(dbsetOrder(6))
			BEA->(MSSeek(xfilial("BE4")+ BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
			nValComp := BEJ->BEJ_VLCOMP
		endIf

		cMatFam := BEA->BEA_OPEUSR + BEA->BEA_CODEMP + BEA->BEA_MATRIC
		cAnoPag := BEA->BEA_ANOAUT
		cMesPag := BEA->BEA_MESAUT
		cOpeMov := BEA->BEA_OPEMOV
		cCodLdp := BEA->BEA_CODLDP
		cCodPeg := BEA->BEA_CODPEG
		cNumGui := BEA->BEA_NUMGUI
		dDatPro	:= BEA->BEA_DATPRO
		cOriMov	:= BEA->BEA_ORIMOV
		cSeqPro	:= BE2->BE2_SEQUEN
		cCodPad	:= BE2->BE2_CODPAD 
		cCodPro	:= BE2->BE2_CODPRO
		cNumAut := BEA->BEA_NUMAUT

		//Preenche o aDadUsr
		if Len(aDadUsr) == 0
			aDadUsr := PLSDADUSR(cMatric,"1",.F.,dDatPro)
		endif

		If lMudarFase
			lJaMudou := .T.
			cFase 	:= &(cAliasPri + "->" + cAliasPri + "_FASE")

			If BCL->BCL_TIPGRV == "1"
				PLSXMUDFAS(	cAliasPri,"1",BCL->BCL_CODOPE,BCL->BCL_TIPGUI,dDatPro,lAutori,nil,nil,nil,;
				.F.,nil,nil,lReanaliza,.F.,nil,nil,nil,nil,nil,nil,nil,lSolicit,,,cChaveLib)
			Else
				aRetAux := ExecBlock(	BCL->BCL_FUNMFS,.F.,.F.,{cAliasPri,"2",cOpeMov,"2",&cFase,BCI->BCI_CODLDP,BCI->BCI_CODPEG,"",BCL->BCL_GUIREL,;
				lAutori,dDatPro,.F.,BCL->BCL_ALIAS,nil,nil,lReanaliza,.F.,nil,nil,nil,nil,nil,nil,nil,lSolicit,,,cChaveLib})
			EndIf
		EndIf

		if !lOnlyIte
			cWhileBD6	:= "BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV)"
			cChaveBD6	:= xFilial("BD6") + cOpeMov + cCodLdp + cCodPeg + cNumGui + cOriMov
		else
			cWhileBD6	:= "BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO)"
			cChaveBD6	:= xFilial("BD6") + cOpeMov + cCodLdp + cCodPeg + cNumGui + cOriMov + cSeqPro + cCodPad + cCodPro
		endif

		BD6->(DbSetorder(1))
		If BD6->(MsSeek(cChaveBD6))
			While ! BD6->(Eof()) .And. &(cWhileBD6) == cChaveBD6

				BD7->(DbSetOrder(1))
				If BD7->(MsSeek(xFilial("BD7") + BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN)))
					While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN) == ;
					xFilial("BD7") + BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN)

						//Se nao houver copart. pula para a proxima participacao
						If cPaisLoc == "BRA" .And. BD7->BD7_VLRTPF ==0
							BD7->(DbSkip())
							Loop
						Endif

						If BD6->BD6_TPPF == "1" //Co-Part
							cCodEvePAG := "121"
						Else
							cCodEvePAG := "120"
						Endif

						//Posiciona na BFQ
						BFQ->(DbSetOrder(1))
						BFQ->(DbSeek(xFilial("BFQ") + cOpeMov + cCodEvePAG))

						//Posiciona na BD4
						BD4->(DbSetOrder(1))
						If !BD4->(DbSeek(xFilial("BD4") + BD6->BD6_CODOPE + BD6->BD6_CDTBRC + BD6->BD6_CODPAD + BD6->BD6_CODPRO + BD7->BD7_CODUNM))
							BD4->(DbSeek(xFilial("BD4") + BD6->BD6_CODOPE + BD6->BD6_CODTAB + BD6->BD6_CODPAD + BD6->BD6_CODPRO + BD7->BD7_CODUNM))
						Endif

						If ! Empty(BQC->BQC_CODTES)
							cCodTes := BQC->BQC_CODTES
						Else
							If Empty(BD4->BD4_CODTES) .Or. ( ! BD4->(Found()) )
								If !Empty(BFQ->BFQ_CODTES)
									cCodTES := BFQ->BFQ_CODTES
								EndIf
							Else
								cCodTes := BD4->BD4_CODTES
							Endif
						Endif

						If Empty(BD4->BD4_CODSB1) .Or. ( ! BD4->(Found()) ) 
							If !Empty(BFQ->BFQ_CODSB1)
								cCodSB1 := BFQ->BFQ_CODSB1
							EndIf
						Else
							cCodSB1 := BD4->BD4_CODSB1
						Endif

						//Caso nao localizar nos niveis acima, retorna a informacao do produto (mais especifico)
						If empty(cCodTes)
							cCodTes := BI3->BI3_CODTES
						Endif

						If empty(cCodSB1)
							cCodSB1 := BI3->BI3_CODSB1
						Endif

						If lDirf11
							aDadGPE := MontaVer(cMatric,BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA3->BA3_CODINT,,If(BI3->(Fieldpos("BI3_TPFORN"))>0,BI3->BI3_TPFORN,''))
							If Len(aDadGPE)>0
								cVerba	 := If(BFQ->BFQ_TPLAN <>'1',BFQ->BFQ_VERBA,aDadGPE[1] )
								cTpPlan  := aDadGPE[2]
								cCodFor  := aDadGPE[3]
								cSeqDep  := aDadGPE[4]
								cPlanGPE := aDadGPE[5]
							Endif
						Endif

						aAdd(aVlrAuxPAG[1,2],{	BFQ->BFQ_DEBCRE,;	    	    							//01
						BD7->BD7_VLRTPF,;	            							//02
						BFQ->(BFQ_PROPRI + BFQ_CODLAN),;							//03
						"",;           	                							//04
						"",;          	                							//05
						"",;     				        							//06
						cMatric,;				        							//07
						BA1->BA1_NOMUSR,;		        							//08
						.F.,;				            							//09
						BA1->BA1_SEXO,;		      	    							//10
						BA1->BA1_GRAUPA,;		  	    							//11
						"",;				    	    							//12
						"",;			    	        							//13
						"",;			 	            							//14
						BA1->BA1_TIPUSU,;		        							//15
						"",;				            							//16
						"",;				            							//17
						0,;				                							//18
						StrZero(1,4),;		            							//19
						0,;				                							//20
						0,;				                							//21
						BFQ->BFQ_VERBA,;		        							//22
						BD7->BD7_VLRTPF,;		        							//23
						0,;				                							//24
						0,;				                							//25
						0,;				                							//26
						0,;				                							//27
						0,;				                							//28
						0,;				                							//29
						"",;				            							//30
						"",;				            							//31
						"",;				            							//32
						BD7->BD7_VLRTPF,;		        							//33
						BA3->BA3_CODPLA,;		        							//34 - Codigo do plano
						BA3->BA3_VERSAO,;		        							//35 - Versao do plano
						BI3->BI3_DESCRI,;		        							//36 - Descricao do plano
						cCodSB1,;	   	                							//37 - Codigo do Produto SB1 ERP
						cCodTES,;                       							//38 - Codigo da TES SB1 ERP
						0,;  				            							//39 - Recno do BM1 para uso generico
						0,;   														//40 - Total do desconto aglutinado para o item - integracao com a nota de saida.
						BA3->BA3_CODINT,;											//41 
						BA3->BA3_CODEMP,;											//42 
						BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC),;				//43 
						BA3->BA3_CONEMP,;											//44 
						BA3->BA3_VERCON,;											//45 
						BA3->BA3_SUBCON,;											//46 
						BA3->BA3_VERSUB,;											//47 
						BA3->BA3_CODPLA,;											//48 
						BA3->BA3_VERSAO,; 											//49 
						'',;														//50 
						0,;	 	 													//51 
						BA3->BA3_TIPOUS,;			  								//52 
						BA3->(RecNo()),;											//53 
						BG9->(RecNo()),;											//54
						BT5->(RecNo()),;											//55
						BQC->(RecNo()),;											//56
						BT6->(RecNo()),;											//57
						"",;	 													//58
						StrZero(Year(Date()),4),;									//59 
						StrZero(Month(Date()),2),;									//60 
						IIF(BA1->BA1_OPEORI<>PLSINTPAD(),.T.,.F.),; 				//61
						"",;														//62 
						{},;														//63 
						{},;     													//64 
						{},;														//65 
						.F.,;                           							//66
						cTpPlan,; 													//67
						IIF(BI3->(Fieldpos("BI3_TPFORN"))>0,BI3->BI3_TPFORN,''),;	//68
						cCodFor,;													//69
						cSeqDep,; 													//70
						cPlanGpe}) 													//71

						BD7->(DbSkip())
					Enddo
				Endif
				BD6->(DbSkip())
			EndDo
		EndIf

		If Existblock("PL090CGP")
			Execblock("PL090CGP")
		Endif

		lTitGer := PLSA760(	cMatFam,;
		cAnoPag,;
		cMesPag,;
		.F.,;
		"",;
		"",;
		"",;
		dDataBase,;
		dvencto,;
		aVlrAuxPAG,;
		.F.,;
		.T.,;
		aDadUsr[58],;
		aDadUsr[59],;
		"0",;
		cPrefixo,;
		cNumTit,;
		lWeb,;
		nValComp,;
		nVlrCon)

		If lTitGer
			BBT->(DbSetOrder(8))
			BBT->(DbSeek(xFilial("BBT") + BDC->(BDC_CODOPE + BDC_NUMERO)))

			SE1->(DbSetOrder(1))
			SE1->(DbSeek(xFilial("SE1") + BBT->(BBT_PREFIX + BBT_NUMTIT + BBT_PARCEL + BBT_TIPTIT)))

			cPrefixo := SE1->E1_PREFIXO
			cNumTit  := SE1->E1_NUM
			cTipTit  := SE1->E1_TIPO
			cParcTit := SE1->E1_PARCELA

		EndIf

	EndIf

	BEA->( dbSetOrder(1) )
	If lTitGer .And. BEA->(MsSeek(xFilial("BEA") +cOpeMov + cAnoPag + cMesPag + cNumAut))
		//Grava os dados do titulo no cabecalho da guia
		BEA->(RecLock(cAliasCab,.F.))
		BEA->BEA_PREFIX := cPrefixo
		BEA->BEA_NUMTIT := cNumTit
		BEA->BEA_PARCEL := cParcTit
		BEA->BEA_TIPTIT := cTipTit
		BEA->BEA_GUIACO := "1" 
		BEA->BEA_QUACOB := "1" 	 
		BEA->BEA_PAGATO := "1" 
		BEA->BEA_STATUS := "5" 
		BEA->(MsUnLock())

		//Grava os dados na conta medica (cabecalho e evento)	
		If cAliasPri == "BE4"
			BE4->(recLock("BE4",.F.))
			BE4->BE4_PREFIX := cPrefixo
			BE4->BE4_NUMTIT := cNumTit
			BE4->BE4_TIPTIT := cTipTit
			BE4->(msUnlock())
		else		//Grava os dados na conta medica (cabecalho e evento)	
			BD5->(RecLock("BD5"),.F.)
			BD5->BD5_PREFIX := cPrefixo
			BD5->BD5_NUMTIT := cNumTit
			BD5->BD5_TIPTIT := cTipTit
			BD5->BD5_GUIACO := "1"			
			BD5->BD5_QUACOB := "1" 	 
			BD5->BD5_PAGATO := "1" 
			BD5->(MsUnLock())	
		endIf

		BD6->(DbSetorder(1))
		If BD6->(MsSeek(xFilial("BD6") + cOpeMov + cCodLdp + cCodPeg + cNumGui + cOriMov + cSeqPro + cCodPad + cCodPro))
			BD6->(RecLock("BD6",.F.))
			BD6->BD6_PREFIX := cPrefixo
			BD6->BD6_NUMTIT := cNumTit
			BD6->BD6_TIPTIT := cTipTit
			BD6->BD6_GUIACO := "1"				
			BD6->BD6_QUACOB := "1"				
			BD6->(MsUnlock())
			BD6->(DbSkip())
		Endif

	Else
		//Caso nao for gerado, altera o status da guia
		(cAliasCab)->(RecLock(cAliasCab,.F.))
		&(cAliasCab + "->" + cAliasCab + "_STATUS") := "3"
		(cAliasCab)->(MsUnLock())

		if lAudCarol .And. lLogCarol .And. cAliasCab == "BEA"
			cDateTime := Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + "-" + Time()
			PlsPtuLog("["+cDateTime+"] "+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + ' - Alterando status da guia para 3-Negado pois nao foi possivel gerar o titulo de pagamento no ato.' ,'plaudcarol.log')
		endIf

		//Verifica se eh liberacao/autorizacao SADT
		if Type("M->BE1_GUIACO") <> "U" .And. ValType(__lAutoriz) <> "U"
			M->BE1_GUIACO	:= "0" //Nao e mais comprada
				__lAutoriz		:= .F.
			endif

		Endif

		RestArea(aAreaBD6)

	endif

return lTitGer

/*/{Protheus.doc} PLSTitStat
Atualiza o status da guia apÛs realizar a baixa de uma guia que possui titulos
aguardando a liquidacao. NECESSARIO QUE O PONTEIRO DA BEA ESTEJA SETADO NA GUIA.
/*/
function PLSTitStat()
	local cStatus 	:= "1"
local aRet		:= {}

//Atualiza Status da BEA
BEA->(RecLock("BEA",.F.))
BEA->BEA_STATUS := "1"
BEA->(MsUnlock())

//Verifica se possui algum item nao autorizado para informar que a guia foi autorizada parcialmente
BE2->( DbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
BE2->( MsSeek( xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
While !BE2->( Eof() ) .And. xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	If BE2->BE2_STATUS == '0'
		cStatus := "2"
		Exit
	EndIf
	BE2->( DbSkip() )
EndDo


//Ponto de Entrada para definir o Status e a Situacao da Guia             
/*	Retorno : 	aRet[1] -> Indica Status da Guia. Ex: BE2_STATUS              
aRet[2] -> Indica a Situacao da Guia. Ex: BD5_SITUAC	*/          
If Existblock("PL090SGUI")
	aRet := Execblock("PL090SGUI",.F.,.F.,{BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,cStatus})
	If ValType(aRet) == "A"
		PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,aRet[1],,,,,,,,aRet[2])
	Else
		PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,cStatus)
	EndIf
Elseif BEA->BEA_LIBERA <> '1' //.or. BEA->BEA_PAGATO = "1"
	PLSSTAGUI(BEA->BEA_OPEMOV,BEA->BEA_ANOAUT,BEA->BEA_MESAUT,BEA->BEA_NUMAUT,cStatus)
EndIf

BD5->(DbSetOrder(1))
BD5->(MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
BD6->(DbSetOrder(1))
BD6->(MsSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))

return	

/*/{Protheus.doc} ChkAudt
Verifica o codigo da glosa para um registro que j· foi auditado pela rotina antiga.
/*/
Function ChkAudt(cChvLib,cCodPad,cCodPro,cSequen)
Local cOpMov   := SubStr(cChvLib,1,4)
Local cAnoAut  := SubStr(cChvLib,5,4)
Local cMesAut  := SubStr(cChvLib,9,2) 
Local cNumAut  := SubStr(cChvLib,11,8)              
Local cCrBeg   := ""

Default cChvLib   := ""
Default cCodPad   := ""
Default cCodPro   := ""
Default cSequen   := ""  

BEG->(DbSetOrder(1))
             
cSQL := " SELECT BEG_CODGLO "
cSQL += "   FROM " + retSQLName("BEG")
cSQL += "  WHERE BEG_FILIAL = '" + xFilial("BEG") + "' "
cSQL += "    AND BEG_OPEMOV = '" + cOpMov + "' "
cSQL += "    AND BEG_ANOAUT = '" + cAnoAut + "' "
cSQL += "    AND BEG_MESAUT = '" + cMesAut + "' "
cSQL += "    AND BEG_NUMAUT = '" + cNumAut + "' "
cSQL += "    AND BEG_SEQUEN = '" + cSequen + "' "
cSQL += "    AND BEG_CODGLO <> '" + " " + "' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"TRBBEG",.T.,.F.)

While !TRBBEG->(Eof())
	cCrBeg += TRBBEG->BEG_CODGLO  + "/"

	TRBBEG->(DbSkip())
Enddo
TRBBEG->(DbCloseArea())  

Return cCrBeg


/*/{Protheus.doc} PLSA092Cor
Atualiza o status da legenda evoluÁ„o sadt
/*/
Static Function PLSA092Cor(nLinha,aHeaderEd,aColsEd,nTp)

Local nPos := PLRETPOS("BQV_IMGSTA",aHeaderEd,.F.)

//≥ AtualizaÁ„o do status do Procedimento.																 ≥
//---------------------------------------------------------------------
If nPos > 0
	aColsEd[nLinha,nPos] := If(M->BQV_STATUS=="1","ENABLE","DISABLE")
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLWhenMsg3
Trata o When dos campos XXX_MSG03

@author  PLS TEAM
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Function PLWhenMsg3(cAlias)
Local lRet    := .T.
Local cMatAnt := &("M->"+cAlias+"_MATANT")

if !Empty(cMatAnt) .And. len(Alltrim(cMatAnt)) == 17 .And. Substr(cMatAnt,1,4) <> PlsIntPad()
	lRet := .F.
endIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PlDeseraliza
Deserializa uma string no formato JSO
@author  PLS TEAM
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Function PlDeseraliza(strJsonRet)

local aJson  := {}
local aProperties := {}
local cJson  := ""
local oJson  := JsonObject():new()
local nLenProp := 0
local nX     := 0
local nProp  := 1
local aAdB7B := {}
local aArray := {}


cJson += strJsonRet
If(cJson <> "")
	oJson:fromJson(cJson)
	aProperties := oJson:getNames()
	nLenProp := len(aProperties)
	
	// Deserializa uma string no formato JSON
	FWJsonDeserialize(DecodeUtf8(cJson),@oJson)
	
	while nProp <= nLenProp
	   aAdd(aJson,{aProperties[nProp], oJson[aProperties[nProp]] })
	   nProp++
	enddo
	
	if(len(aJson) > 0)
		for nProp := 1 To len(aJson)
			aAdd(aAdB7B, aJson[nProp,2])
		next
		for nProp := 1 To len(aAdB7B)
			  for nX := 1 To len(aAdB7B[nProp])	
		          aAdd(aArray,  ClassDataArr(aAdB7B[nProp,nX], .T.))
		      next
		next
		 
	EndIf	
EndIf	
return aArray

//-------------------------------------------------------------------
/*/{Protheus.doc} ConcatMsg
Concatena a mensagem nos campos passados por parametro
@author  Vinicius.Queiros
@version P12
@since   09/03/2020
@Obs     Quando o campo 1 tiver com o tamanho maximo o texto ser· 
		 gravado no campo 2
@Param   1 = Tabela
		 2 = Campo da Mensagem 1
		 3 = Campo da Mensagem 2
		 4 = Texto a ser informado
		 5 = Identificado da TransaÁ„o
/*/
//------------------------------------------------------------------- 

Static Function ConcatMsg(cAlias,cCampo1,cCampo2,cTexto,cTArq)

Local cCamp1 	:= cAlias+"->"+cCampo1  
Local cCamp2 	:= cAlias+"->"+cCampo2
// Verifica se existe campo no dicionario
Local lExistC1  := &(cAlias+"->(FieldPos('"+cCampo1+"'))") > 0
Local lExistC2	:= &(cAlias+"->(FieldPos('"+cCampo2+"'))") > 0 
Local nTamLivre 

	If Len(Alltrim(&(cCamp1))) < 254 .AND. !Empty(cTexto) .AND. lExistC1  // Se tiver espaÁo no primeiro campo para gravar

		IF Empty(&(cCamp1))
			// Tamanho do espaÁo livre
			nTamLivre := (254 - Len(Alltrim(&(cCamp1)))) - (Len(cTArq)+1)  // Menos o espaÁo do cod.tran + ':'
			&(cCamp1) := Alltrim(&(cCamp1)) + cTArq + ":" + Substr(cTexto,1,nTamLivre) // GravaÁ„o
		Else
			// Tamanho do espaÁo livre
			nTamLivre := (254 - Len(Alltrim(&(cCamp1)))) - (Len(cTArq)+2)  // Menos o espaÁo do + "/" + cod.tran + ':'
			&(cCamp1) := Alltrim(&(cCamp1)) + "/" +cTArq + ":" + Substr(cTexto,1,nTamLivre) // GravaÁ„o
		EndIf

		// Verifica se ainda tem texto a ser gravado, se houver grava a continuaÁ„o no campo 2
		If !Empty(Substr(cTexto,nTamLivre+1)) .AND. lExistC2
			&(cCamp2) := Alltrim(&(cCamp2)) + Substr(cTexto,nTamLivre+1) // GravaÁ„o
		EndIf

	ElseIf Len(Alltrim(&(cCamp2))) < 254 .AND. !Empty(cTexto) .AND. lExistC2  // Quando sÛ tem espaÁo para gravar no campo 2

		IF Empty(&(cCamp2))
			// Tamanho do espaÁo livre 
			nTamLivre := (254 - Len(Alltrim(&(cCamp2)))) - (Len(cTArq)+1) // Menos o espaÁo do cod.tran + ':'
			&(cCamp2) := Alltrim(&(cCamp2)) + cTArq + ":" + Substr(cTexto,1,nTamLivre) // GravaÁ„o
		Else
			// Tamanho do espaÁo livre
			nTamLivre := (254 - Len(Alltrim(&(cCamp2)))) - (Len(cTArq)+2) // Menos o espaÁo do + "/" + cod.tran + ':'
			&(cCamp2) := Alltrim(&(cCamp2)) + "/" + cTArq + ":" + Substr(cTexto,1,nTamLivre) // GravaÁ„o
		EndIf
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltroPac
FunÁ„o criada para filtrar o Pacote ao visualizar na rotina de atendimento
@author  r.soares Rafael Soares
@version P12
@since   02/09/2020
@Param   1 = CÛdigo da sequÍncia do Evento
		 2 = aDadB43 para filtrar qual cÛdigo da sequÍncia que È e ordenar o array.
		 3 = aTrbB43 ficar no size do aDadB43
		 4 = aCabB43 Para buscar informaÁ„o do B43_SEQUEN no cabeÁalho.
/*/
//------------------------------------------------------------------- 
Function FiltroPac(cSequen, aDadAux, aTrbAux, aCabAux)
Local aCol		:= {}
Local aColAux	:= {}
Local aTrb		:= {}
Local nX		:= 0
Local nPos		:= PLRETPOS("B43_SEQUEN",aCabAux)
Local cSeqNew	:= "001"

Default cSequen := "" 
Default aCol 	:= {}
Default aTrbAux := {}

If !Empty(aDadAux) .And. Empty(aTrbAux)
	aCol := aClone(aDadAux)
	For nX := 1 to Len(aCol)
		If cSequen == aCol[nX][nPos]
			aCol[nX][nPos] := cSeqNew
			aAdd(aColAux, aCol[nX])
			cSeqNew := padl(cValToChar(Val(cSeqNew) + 1),3,"0")
		EndIf
	Next
ElseIf !Empty(aDadAux) .And. !Empty(aTrbAux) .And. Len(aTrbAux) == Len(aDadAux)
	aCol := aClone(aDadAux)
	aTrb := aClone(aTrbAux)
	For nX := 1 to Len(aCol)
		If cSequen == aCol[nX][nPos]
			aAdd(aColAux, aTrb[nX])
		EndIf
	Next
EndIf

Return aColAux

//-------------------------------------------------------------------
/*/{Protheus.doc} ComPTUOn
Visualiza a tabela B6M que corresponde aos campos do PTU Online

@author  Vinicius.Queiros
@version P12
@since   22/06/2020
@Obs     Funcionalidade somente apartir da vers„o 8 do PTU Online
@Param   cAlias       Tabela a ser consultada
		 cAliasCab    Tabela de CabeÁalho
@return  Logico       Se a consulta foi realizada com sucesso.
/*/
//------------------------------------------------------------------- 

Function ComPTUOn(cAlias,cAliasCab)

Local lRetorno 		:= .F.
Local cNumTrans 	:= ""
Local cChaveGuia 	:= ""
Local oDlgPTU

Default cAlias    := ""
Default cAliasCab := ""

	Do Case
		Case cAlias == "BEA"
			cNumTrans  := BEA->BEA_NRTROL
			cChaveGuia := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
		Case cAlias == "BE4"
			cNumTrans  := M->BE4_NRTROL
			cChaveGuia := M->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
		Case cAlias == "BQV"
			Do Case
				Case cAliasCab == "BEA"
					cChaveGuia := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
				Case cAliasCab == "BE4"
					cChaveGuia := M->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			EndCase
			cNumTrans  := M->BQV_NRTROL			
	EndCase

	B6M->(DbSetOrder(2))
	If !Empty(cAlias) .And. B6M->(MsSeek(xFilial("B6M") + cNumTrans + cChaveGuia ))

		DEFINE MSDIALOG oDlgPTU TITLE "Complemento - PTU Online" FROM 9,0 TO TranslateBottom(.F.,28),100 OF oMainWnd

		AxVisual("B6M",B6M->(Recno()),2,,,,,,.F.,,.T.,oDlgPTU)

		ACTIVATE MSDIALOG oDlgPTU CENTERED

		lRetorno := .T.
						
	Else
		MsgInfo("N„o foi encontrado nenhuma TransaÁ„o Online.")
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPTUGRV

GravaÁ„o das tabela B6M (Complemento PTU Online) e B6L (Pacote PTU Online)

@author  Vinicius.Queiros
@version P12
@since   01/09/2020
@Param   aDados  Array com os dados a serem gravado
		 aChave	 Array com os dados: OPEMOV,ANOAUT,MESAUT,NUMAUT (Chave)
		 cAlias  Tabela: B6M ou B6L
@Return  Logico  Se a gravaÁ„o foi realizado com sucesso

/*/
//------------------------------------------------------------------- 

Function PLSPTUGRV(aDados,aChave,cAlias,lBD6)

Local nNx
Local nNz
Local lRetorno	:= .F.

Default aDados	:= {}
Default aChave	:= {}
default lBD6  	:= .f.

If Len(aDados) > 0 .And. Len(aChave) >= 4 .And. ChkFile(cAlias) .And. PlsAliasExi(cAlias)

	If cAlias == "B43"
        B43->(dbsetorder(1))			
        If B43->(MsSeek(xFilial("B43")+aChave[1]+aChave[2]+aChave[3]+aChave[4]+If(Len(aChave)>4,aChave[5],'')))
            while !(B43->(EoF())) .AND. aChave[3] == B43->B43_CODPEG .AND. aChave[4] == B43->B43_NUMERO
                B43->(Reclock("B43", .F.))
                B43->(dbDelete())
                B43->(MsUnlock())
                B43->(Dbskip())
            enddo
        endif
    endif

	For nNx := 1 To Len(aDados)
		&(cAlias+"->(Reclock('"+cAlias+"',.T.))")

		For nNz := 1 To Len(aDados[nNx])
			&(cAlias+"->"+aDados[nNx,nNz,1]) := aDados[nNx,nNz,2]
		Next nNz

		if !lBD6
			&(cAlias+"->"+cAlias+"_FILIAL") := xFilial(cAlias)
			&(cAlias+"->"+cAlias+"_OPEMOV") := aChave[1]
			&(cAlias+"->"+cAlias+"_ANOAUT") := aChave[2]
			&(cAlias+"->"+cAlias+"_MESAUT") := aChave[3]
			&(cAlias+"->"+cAlias+"_NUMAUT") := aChave[4]
		elseif FWAliasInDic("B6L", .F.)
				if B6L->( FieldPos("B6L_CODLDP") ) > 0 .and. B6L->( FieldPos("B6L_CODPEG") ) > 0 .and. B6L->( FieldPos("B6L_NUMERO") ) > 0 .and. B6L->( FieldPos("B6L_ORIMOV") ) > 0
					&(cAlias+"->"+cAlias+"_FILIAL") := xFilial(cAlias)
					&(cAlias+"->"+cAlias+"_OPEMOV") := aChave[1]
					&(cAlias+"->"+cAlias+"_CODLDP") := aChave[2]
					&(cAlias+"->"+cAlias+"_CODPEG") := aChave[3]
					&(cAlias+"->"+cAlias+"_NUMERO") := aChave[4]
				endif
		endif
		&(cAlias+"->( MsUnLock() )")
		lRetorno := .T.
	Next nNx
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSATTLIBER

Atualiza a liberaÁ„o da guia para cancelada.

@author  r.soares
@version P12
@since   07/12/2020
@Param   cNumLib com o n˙mero da liberaÁ„o a ser cancelada ao solicitar um cancelamento.
		 aRetDesCan descriÁ„o do cancelamento.
		 aMotCanc  Motivo de cancelamento tiss
@Return  NIL

/*/
//------------------------------------------------------------------- 
function PLSATTLIBER(cNumLib, aRetDesCan, aMotCanc, lBEANTit)
Local aAreaBEA := BEA->(GetArea())

Default lBEANTit	:= .F.
Default cNumLib 	:= ""
Default aRetDesCan 	:= {}
Default aMotCanc	:= {}

BEA->(DBSetOrder(1))
If BEA->(msSeek(xFilial("BEA")+BEA->BEA_NRLBOR))
	
	BEA->( RecLock("BEA", .f.) )
		BEA->BEA_STATUS := "3"
		BEA->BEA_CANCEL := "1"
		BEA->BEA_STTISS := PLSANLSTIG(,,.T. ) //Como est· cancelada, no portal deve exibir o status TISS como cancelada 
		If len(aRetDesCan) > 0 
			BEA->BEA_CANEDI := aRetDesCan[1]
		ElseIf Len(aMotCanc) > 0
			BEA->BEA_CANTIS := aMotCanc[1] //Motivo TISS
			BEA->BEA_CANEDI := aMotCanc[2] //Texto motivo
		EndIf

	BEA->( MsUnLock() )

	//se for LiberaÁ„o odontolÛgica
	BE2->( DbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	BE2->( MsSeek( xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
	While !BE2->(Eof()) .And. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)

		BE2->( RecLock("BE2", .F.) )
		BE2->BE2_LIBESP := '0'
		BE2->BE2_AUDITO := '0'
		BE2->BE2_STATUS := '0'

		BE2->( MsUnLock() )

		BE2->( DbSkip() )
	EndDo

	//Altera o status da guia na auditoria para cancelada.							  
	B53->(dbSetOrder(1)) //B53_FILIAL, B53_NUMGUI, B53_ORIMOV
	If B53->(dbSeek(BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
		B53->(Reclock("B53",.F.))
		B53->B53_STATUS := '6'
		B53->(MsUnlock())
	EndIf
EndIf

RestArea(aAreaBEA)
Return

Function VerProBqv(cChvBqv)
	Local cSql   := ""
	Local lBqvAut:= .F.
	Default cChvBqv:= ""

	cSQL := "SELECT BQV_FILIAL FROM "+BQV->(RetSQLName("BQV"))+" WHERE "
	cSQL += "BQV_FILIAL = '"+xFilial("BQV")+"' AND "
	cSQL += "BQV_CODOPE = '"+SubStr(cChvBqv,1,4)+"' AND "
	cSQL += "BQV_ANOINT = '"+SubStr(cChvBqv,5,4)+"' AND "
	cSQL += "BQV_MESINT = '"+SubStr(cChvBqv,9,2)+"' AND "
	cSQL += "BQV_NUMINT = '"+SubStr(cChvBqv,11,8)+"' AND "
	cSQL += "BQV_COMUNI = '1' AND BQV_STATUS = '1' AND "
	cSQL += "D_E_L_E_T_ = ' '"

	PLSQuery(cSQL,"TrbBQV")

	If ! TrbBQV->(Eof())
		lBqvAut:= .T.
	EndIf
	TrbBQV->(DbCloseArea())

Return lBqvAut

//-------------------------------------------------------------------
/*/{Protheus.doc}  
Verifica se È possÌvel realizar a exclus„o verificando o status do A520 
Rotina referente a PLSA094 
@author Cesar Almeida
@since 18/04/2022
@version P12
/*/
//-------------------------------------------------------------------

static function chkA520(codOpe,codLdp,codPeg)

local cSql := ""
local lret := .f.
local lMV_PLSUNI := .f.

lMV_PLSUNI := GetNewPar("MV_PLSUNI", "0") == "1" // VERIFICA SE O CLIENTE … UNIMED 

if lMV_PLSUNI

	cSql += " SELECT 1 FROM" + retsqlname("B5S") + " B5S " 
	cSQL += " WHERE B5S_FILIAL = '" + xFilial('B5S') +"' "
	cSql += " AND B5S_CODOPE = '" + codOpe +"'"
	cSql += " AND B5S_CODLDP = '" + codLdp + "'"
	cSql += " AND B5S_CODPEG = '" + codPeg + "'"
	cSql += " AND B5S.D_E_L_E_T_ = '' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"TRB",.f.,.t.)

	IF !TRB->(Eof()) 
		lret := .t. // SE ACHOU REGISTRO 
	ENDIF

TRB->(DbCloseArea())

ENDIF

return lret
