#INCLUDE "plsa475.ch"
#include "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#Include "TOPCONN.CH"

#define K_Fase     5
#define K_RetFas   6
#define K_RevPag   7
#define K_RetCob   8
#define K_RetCP    9

STATIC __cLastTime := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IgualaVar  ³ Autor ³ Tulio Cesar       ³ Data ³ 20.12.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Iguala dados em variaveis...                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function IgualaVar(lTipo)

Default lTipo := .F.

If lTipo // se esta vindo de outra rotina

	cOpeDe     := BCI->BCI_CODOPE
	cOpeAte    := BCI->BCI_CODOPE
	cLocDe     := BCI->BCI_CODLDP
	cLocAte    := BCI->BCI_CODLDP
	cPegDe     := BCI->BCI_CODPEG
	cPegAte    := BCI->BCI_CODPEG
	cRDADe     := BCI->BCI_CODRDA
	cRDAAte    := BCI->BCI_CODRDA
	cAnoDe     := BCI->BCI_ANO
	cAnoAte    := BCI->BCI_ANO
	cMesDe     := BCI->BCI_MES
	cMesAte    := BCI->BCI_MES
	nTipo      := iif(IsInCallStack("PLSA498"),1,mv_par13) // Caso esteja vindo do proc contas sempresera 1 enao ira pegar do parametro utilizado para mudança de fase em lote (PLSA475)
	cCodEmpDe  := ""
	cCodEmpAte := "ZZZZZZ"
	cContDe    := ""
	cContAte   := "ZZZZZZ"
	cSubConDe  := ""
	cSubConAte := "ZZZZZZZZZZ"
	lRegCad    := (mv_par20 == 2)
	cGruCobDe  := ""
	cGruCobAte := "ZZZZZZZZZZ"
	cDataDe    := BCI->BCI_DTDIGI
	cDataAte   := BCI->BCI_DTDIGI
	cLocAtDe   := BCI->BCI_CODLDP
	cLocAtAte  := BCI->BCI_CODLDP                           
	cClaRDA    := alltrim(mv_par27)
	nOnlyZero  := mv_par28
	nDifUs	   := mv_par29
	nVlrDifUs  := mv_par30
	cGrpPagDe  := ""
	cGrpPagAte := "ZZZZZZ"


Else
	cOpeDe     := mv_par01
	cOpeAte    := mv_par02
	cLocDe     := mv_par03
	cLocAte    := mv_par04
	cPegDe     := mv_par05
	cPegAte    := mv_par06
	cRDADe     := mv_par07
	cRDAAte    := mv_par08
	cAnoDe     := mv_par09
	cAnoAte    := mv_par10
	cMesDe     := mv_par11
	cMesAte    := mv_par12
	nTipo      := mv_par13
	cCodEmpDe  := mv_par14
	cCodEmpAte := mv_par15
	cContDe    := mv_par16
	cContAte   := mv_par17
	cSubConDe  := mv_par18
	cSubConAte := mv_par19
	lRegCad    := (mv_par20 == 2)
	cGruCobDe  := mv_par21
	cGruCobAte := mv_par22
	cDataDe    := mv_par23
	cDataAte   := mv_par24
	cLocAtDe   := mv_par25
	cLocAtAte  := mv_par26                           
	cClaRDA    := alltrim(mv_par27)
	nOnlyZero  := mv_par28
	nDifUs	   := mv_par29
	nVlrDifUs  := mv_par30
	cGrpPagDe  := mv_par31
	cGrpPagAte := mv_par32
Endif

If ExistBlock("PL475IGUALA")
	ExecBlock("PL475IGUALA",.F.,.F.,{cperg})
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa   ³ PLSA475Job ³ Autor ³ Eduardo Motta        ³ Data ³ 28.09.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Mudanca de fase por lote (executacao em JOB)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA475Job()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cIniFile := "plsfase.ini"
LOCAL cDia     := StrZero(Dow(Date()),2)
Local cEmpresa
Local cFil         
Local cRootPath
Local cStart
Local cHorario
Local cLastExec
Local cTmpIni := Time()
Local nTotPer := 0
Local nI
Local cPerg := "PLS475"
PRIVATE cOpeDe   
PRIVATE cOpeAte
PRIVATE cLocDe
PRIVATE cLocAte
PRIVATE cPegDe
PRIVATE cPegAte
PRIVATE cRDADe
PRIVATE cRDAAte
PRIVATE cAnoDe
PRIVATE cAnoAte
PRIVATE cMesDe
PRIVATE cMesAte     
PRIVATE nTipo       
PRIVATE cCodEmpDe
PRIVATE cCodEmpAte
PRIVATE cContDe
PRIVATE cContAte
PRIVATE cSubConDe
PRIVATE cSubConAte
PRIVATE cGruCobDe
PRIVATE cGruCobAte
PRIVATE lRegCad
PRIVATE cDataDe
PRIVATE cDataAte      
PRIVATE cLocAtDe   
PRIVATE cLocAtAte  
PRIVATE cClaRDA    
PRIVATE nOnlyZero
PRIVATE cGrpPagDe
PRIVATE cGrpPagAte
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca parametros....                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cRootPath := AllTrim(GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() ))
cStart := AllTrim(GetPvProfString( GetEnvServer(), "StartPath", "ERROR", GetADV97() ))
If SubStr(cRootPath,Len(cRootPath),1) $ "\/"
   cRootPath := SubStr(cRootPath,1,Len(cRootPath)-1)
EndIf

//cIniFile  := cStart+cIniFile

cEmpresa   := GetPvProfString( cDia, "cEmpresa" , "01", cIniFile )
cFil       := GetPvProfString( cDia, "cFilial" , "01", cIniFile )
cHorario   := GetPvProfString( cDia, "cHorario" , "  :  :  ", cIniFile )
cLastExec  := GetPvProfString( cDia, "cUltimaExecucao" , "                ", cIniFile )
If Empty(cHorario) .or. cHorario == "  :  :  "
   Return
EndIf

If SubStr(cLastExec,1,8) >= DtoS(Date())  // ja foi executado neste dia
   Return
EndIf
If cHorario > Time()
   Return                   
EndIf

RpcSetEnv( cEmpresa, cFil,,,'PLS',, )

If !Pergunte(cPerg,.F.)
   Return
Endif

IgualaVar(lTipo)

WritePPros( cDia, "cUltimaExecucao"    , DtoS(Date())+Time(), cIniFile )
WritePPros( cDia, "cTmpIni"    , cTmpIni, cIniFile )
WritePPros( cDia, "cTmpFin"    , Time(),  cIniFile  )

RPLSA475PRO(.t.,cPerg)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³RPLSA475PRO³ Autor ³ Tulio Cesar            ³ Data ³ 10.03.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Processa a mudanca de fase por lote...                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RPLSA475PRO(lJob,cPerg, lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSQL             
LOCAL aFiltro
LOCAL cHoraIniT := Time()
LOCAL aResumo   := {}
LOCAL aRetRes
LOCAL nFor            
LOCAL lFlag     := .F.
LOCAL cTitulo
LOCAL nTotReg   := 0
LOCAL nTotEventos := 0
LOCAL nQtd      := 0
LOCAL nRecAtu
LOCAL nHorIni
LOCAL cArqLog  := "PLSLGRV.LOG"
LOCAL aThreads := {}
LOCAL nThreads := GetNewPar("MV_PLSMFNT",1)
LOCAL nQtdFor
LOCAL nCont              
LOCAL aRegs    := {}
LOCAL nPosVet
LOCAL nQtdPorT                 
LOCAL nAux
LOCAL nLastRec
LOCAL lSaida := .F.
LOCAL aCabec       
LOCAL aRestTot := {}
LOCAL lDlg
LOCAL oBrowseSta
LOCAL oTimer                                                                           
LOCAL oTimeOut
LOCAL oSay                                      
LOCAL aBCL    := {}
LOCAL cOriMov := ""                         
LOCAL nTotGerEv := 0
LOCAL cAliasPri
LOCAL lField
LOCAL lProcesso := .F.
LOCAL cNameBAU  := BAU->(RetSQLName("BAU"))
LOCAL cFilBAU   := BAU->(xFilial("BAU"))
DEFAULT lJob := .F.
default lAuto := .F.

If nThreads > 15
   nThreads := 15
Endif   
Pergunte(cPerg,.F.)

IgualaVar()

aFiltro := { 	 cOpeDe,;  //[1]
				 cOpeAte,;//[2]	
				 cCodEmpDe,;//[3]
				 cCodEmpAte,;//[4]
				 cContDe,;//[5]
				 cContAte,;//[6]
				 cSubConDe,;//[7]
				 cSubConAte,;//[8]
				 cGruCobDe,;//[9]
				 cGruCobAte,;//[10]
				 cDataDe,;//[11]
				 cDataAte,;//[12]
				 cLocAtDe,;//[13]
				 cLocAtAte,;//[14]
				 cClaRDA ,;//[15]
				 nOnlyZero,;//[16]
				 cGrpPagDe,;//[17]
				 cGrpPagAte}//[18]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pede confirmacao...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If     nTipo == 1
       If ! lJob .And. ! MsgYesNo(STR0017) //"Confirma a mudanca de fase dos PEGS de acordo com os parametros informados ?"
          Return
       Endif   
ElseIf nTipo == 2
       If ! lJob .And. ! MsgYesNo(STR0018) //"Confirma o retorno de fase dos PEGS de acordo com os parametros informados ?"
          Return
       Endif   
ElseIf nTipo == 3
       If ! lJob .And. ! MsgYesNo(STR0019) //"Confirma a revalorizacao de pagamento das PEGS de acordo com os parametros informados ?"
          Return
       Endif   
ElseIf nTipo == 4
       If ! lJob .And. ! MsgYesNo(STR0020) //"Confirma a revalorizacao de cobranca das PEGS de acordo com os parametros informados ?"
          Return
       Endif   
ElseIf nTipo == 5
       If ! lJob .And. ! MsgYesNo(STR0021) //"Confirma a revalorizacao de pagamento e cobranca das PEGS de acordo com os parametros informados ?"
          Return
       Endif   
Endif

If PLSMDFGRI(.F.)
	RstMvBuff()
	Processa({||PLSA475FST(.T.,"PLS475    ",.F.,nTipo)},STR0001,STR0022,.T.)//"Processamento De Guias Por Lote","Processando Peg ... "
	Return
elseIf lAuto
	PLSA475FST(.T.,"PLS475    ",.F.,nTipo,lauto)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza status da PEG                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//somente a revalorizacao de cobranca (nTipo ==4) nao e necessario reprocessar as Pegs
If cOpeDe == cOpeAte .And. nTipo <> 4 //Se for a mesma Operadorado no De/Ate, utilizo ela diretamente     
	PLSM190Pro(,.F.,cOpeDe,cLocDe,cLocAte,cPegDe,cPegAte,cAnoDe,cMesDe,cAnoAte,cMesAte,lJob)

ElseIf nTipo <> 4 //Foi utilizado o De Para com operadoras diferentes    
	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT    

	If Empty(cOpeDe) .Or. !BA0->(DbSeek(xFilial("BA0")+cOpeDe)) //Se nao encontrei a operadora ou o parametro 'De' veio vazio, posiciono no topo
		BA0->(DbGoTop())
	EndIf
		
	While !BA0->(Eof()) //Rodo todas as operadoras que tenho na BA0 a verificar se os parametros De/Para sao atendidos
		If BA0->BA0_CODIDE >= SubStr(cOpeDe,1,1) .And. BA0->BA0_CODINT >= SubStr(cOpeDe,2,3) .And. ;
	   	   BA0->BA0_CODIDE <= SubStr(cOpeAte,1,1) .And. BA0->BA0_CODINT <= SubStr(cOpeAte,2,3)   
	   	   
	   		PLSM190Pro(,.F.,BA0->(BA0_CODIDE+BA0_CODINT),cLocDe,cLocAte,cPegDe,cPegAte,cAnoDe,cMesDe,cAnoAte,cMesAte,lJob)   
	    EndIf   
	    BA0->(DbSkip())
	EndDo
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cClaRDA) 
	cSQL := "SELECT "+RetSQLName('BCI')+".R_E_C_N_O_ AS REGBCI FROM "+RetSQLName("BCI")+","+RetSQLName("BAU")+" WHERE "
Else
	cSQL := "SELECT "+RetSQLName('BCI')+".R_E_C_N_O_ AS REGBCI FROM "+RetSQLName("BCI")+" WHERE "
Endif
cSQL += "BCI_FILIAL = '"+xFilial("BCI")+"' AND "
cSQL += "( BCI_CODOPE >= '"+cOpeDe+"' AND BCI_CODOPE <= '"+cOpeAte+"' ) AND  "
cSQL += "( BCI_CODLDP >= '"+cLocDe+"' AND BCI_CODLDP <= '"+cLocAte+"' ) AND  "
cSQL += "( BCI_CODPEG >= '"+cPegDe+"' AND BCI_CODPEG <= '"+cPegAte+"' ) AND  "
cSQL += "( BCI_CODRDA >= '"+cRdaDe+"' AND BCI_CODRDA <= '"+cRdaAte+"' ) AND  "
cSQL += "( BCI_ANO+BCI_MES    >= '"+cAnoDe+cMesDe+"' AND  "
cSQL += "  BCI_ANO+BCI_MES    <= '"+cAnoAte+cMesAte+"')  "        
cSQL += " AND "+RetSQLName("BCI")+".D_E_L_E_T_ = '' "
cSQL += "   AND (exists (select R_E_C_N_O_                "
cSQL += "                        from "+RetSQLName("BD5")+" 
cSQL += "                       where bd5_filial = bci_filial"
cSQL += "                         AND bd5_codope = bci_codope"
cSQL += "                         AND bd5_codldp = bci_codldp"
cSQL += "                         AND bd5_codpeg = bci_codpeg"
cSQL += "                         AND bd5_codrda = bci_codrda"
If nTipo == 1
	cSQL += "                         AND bd5_fase = '1' "
ElseIf nTipo == 2
	cSQL += "                         AND bd5_fase <> '4' "
EndIf
cSQL += "                         AND "+RetSQLName('BD5')+".d_e_l_e_t_ = ' ') OR exists"
cSQL += "          (select R_E_C_N_O_ "
cSQL += "             from "+RetSQLName("BE4")+" 
cSQL += "            where be4_filial = bci_filial "
cSQL += "              AND be4_codope = bci_codope"
cSQL += "              AND be4_codldp = bci_codldp"
cSQL += "              AND be4_codpeg = bci_codpeg"
cSQL += "              AND be4_codrda = bci_codrda"
If nTipo == 1
	cSQL += "              AND be4_fase = '1' "
ElseIf nTipo == 2
	cSQL += "              AND be4_fase <> '4' "
EndIf
cSQL += "              AND "+RetSQLName('BE4')+".d_e_l_e_t_ = ' ')) "

If !Empty(cClaRDA) 
	cSQL += " AND  BAU_FILIAL = BCI_FILIAL  "
	cSQL += " AND  BAU_CODIGO = BCI_CODRDA  "
	cSQL += " AND "+RetSQLName("BAU")+".D_E_L_E_T_ = '' "
	cSQL += " AND  BAU_TIPPRE in ('"+StrTran(cClaRDA,",","','")+"')"
Endif

//Ponto de Entrada solicitado pela CAPESESP para filtrar a seleção das PEG´s 
If ExistBlock("PL475FIL")
	cSQL += ExecBlock("PL475FIL",.F.,.F.,{cSQL}) 
EndIf

cSQL += " ORDER BY " + StrTran(Eval({ || BCI->(DbSetOrder(1)), BCI->(IndexKey()) }),"+",",")

PLSQuery(upper(cSQL),"PLS475")
While ! PLS475->(Eof())
       BCI->(DbGoTo(PLS475->REGBCI))
       nPosVet := Ascan(aBCL, {|x| x[2] == BCI->BCI_TIPGUI } )
       If nPosVet == 0
          BCL->(DbSetOrder(1))
          BCL->(DbSeek(xFilial("BCI")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
          aadd(aBCL,{BCI->BCI_TIPGUI,BCL->BCL_CDORIT,BCL->BCL_ALIAS})
          cOriMov   := BCL->BCL_CDORIT
          cAliasPri := BCL->BCL_ALIAS
       Else
          cOriMov   := aBCL[nPosVet,2]
          cAliasPri := BCL->BCL_ALIAS
       Endif   
       
       lField    := &(cAliasPri)->(FieldPos(cAliasPri+"_STAFAT")) > 0
       
       cSQL := "SELECT SUM("+cAliasPri+"_QTDEVE) QTDEVE FROM "+RetSqlName(cAliasPri)+", "+cNameBAU+"  WHERE "
       cSQL += cAliasPri+"_FILIAL = '"+xFilial(cAliasPri)+"' AND "
       cSQL += cAliasPri+"_CODOPE = '"+BCI->BCI_CODOPE+"' AND "
       cSQL += cAliasPri+"_CODLDP = '"+BCI->BCI_CODLDP+"' AND "
       cSQL += cAliasPri+"_CODPEG = '"+BCI->BCI_CODPEG+"' AND "  
       cSQL += cAliasPri+"_ORIMOV = '"+cOriMov+"' AND "    
       cSQL += cAliasPri+"_SITUAC = '1' AND "'
       cSQL += cAliasPri+"_DATPRO >= '"+DtoS(cDataDe)+"' AND "+cAliasPri+"_DATPRO <= '"+DtoS(cDataAte)+"' AND "

       If     nTipo == 1 //mudar a fase somente as pegs de digitacao...              
              cSQL += "( "+cAliasPri+"_FASE = '1' ) AND "  
       ElseIf nTipo == 2 //Retorno de Fase
              cSQL += "( "+cAliasPri+"_FASE = '3' OR "+cAliasPri+"_FASE = '2' ) AND "  
              If &(cAliasPri)->(FieldPos(cAliasPri+"_SEQEST")) > 0
                cSQL += "( "+cAliasPri+"_SEQEST = '"+SPACE(LEN(&(cAliasPRI+"->"+cAliasPRI+"_SEQEST")))+"' ) AND "
              Endif   
       ElseIf nTipo == 3 //Revalorização de pagamento      
              cSQL += cAliasPri+"_FASE = '3' AND "
       ElseIf nTipo == 4 //Revalorização de cobranca
              cSQL += "( "+cAliasPri+"_FASE = '3' OR "+cAliasPri+"_FASE = '4' ) AND "
       ElseIf nTipo == 5 //Revalorização de pagamento e cobrança      
              cSQL += "( "+cAliasPri+"_FASE = '3' OR "+cAliasPri+"_FASE = '4' ) AND "              
       Endif       

       cSQL += "( "+cAliasPri+"_CODEMP >= '"+cCodEmpDe+"' AND "+cAliasPri+"_CODEMP <= '"+cCodEmpAte+"' ) AND "
       cSQL += "( "+cAliasPri+"_CONEMP >= '"+cContDe+"' AND "+cAliasPri+"_CONEMP <= '"+cContAte+"' ) AND "
       cSQL += "( "+cAliasPri+"_SUBCON >= '"+cSubConDe+"' AND "+cAliasPri+"_SUBCON <= '"+cSubConAte+"' ) AND "
       cSQL += "( "+cAliasPri+"_LOCAL >= '"+cLocAtDe+"' AND "+cAliasPri+"_LOCAL <= '"+cLocAtAte+"' ) AND "       
       
       If nTipo == 2 .And. &(cAliasPri)->(FieldPos(cAliasPri+"_PODRFS")) > 0
          cSQL += cAliasPri+"_PODRFS <> '0' AND "  
       Endif       

       If nTipo <> 3 .and. lField                                   
          cSQL += cAliasPri+"_STAFAT <> '0' AND "  
       Endif              
       
       If nOnlyZero == 2
          cSQL += cAliasPri+"_VLRPAG = 0 AND "  
       Endif   
       
       If nTipo == 1 .And. &(cAliasPri)->(FieldPos(cAliasPri+"_DTALTA")) > 0 
          cSQL += cAliasPri+"_DTALTA <> '"+Space(8)+"' AND "  
       Endif                                                                                     
       cSQL += RetSqlName(cAliasPri)+".D_E_L_E_T_ = ' ' AND "
       
       cSQL += "BAU_FILIAL = '"+cFilBAU+"' AND "
       cSQL += "BAU_CODIGO = "+cAliasPri+"_CODRDA AND "
       If BAU->(FieldPos("BAU_GRPPAG")) > 0
          cSQL += "( BAU_GRPPAG >= '"+cGrpPagDe+"' AND BAU_GRPPAG <= '"+cGrpPagAte+"' ) AND "       
       Endif   
       cSQL += cNameBAU+".D_E_L_E_T_ = ' '"

       PLSQuery(cSQL,"TrbNotas")
       
       nTotEventos := TrbNotas->QTDEVE
       nTotGerEv += nTotEventos
       Aadd(aRegs,{PLS475->REGBCI,nTotEventos})
       nTotReg ++
       
       TrbNotas->(DbCloseArea())
       DbSelectArea("PLS475")
PLS475->(DbSkip())
Enddo
PLS475->(DbCloseArea())
DbSelectArea("BA1")

aRegs := aSort(aRegs,,,{|x,y| x[2] > Y[2] })

For nCont := 1 To nThreads
    aadd(aThreads,{{},;                        //Array com os Recnos das Pegs
                   "ThrPls"+StrZero(nCont,3),; //Codigo ad Theard
                   "Não",;                        //Aberta Sim Ou Nao
                   0,;                         //Total de Eventos
                   0,;                         //% concluido
                   "",;                        //Hora Inicio
                   "",;                        //Hora Fim
                   "",;                        //Tempo Total
                   "ThrPlsSta"+StrZero(nCont,3),; //Status do Processo...
                   "BR_VERMELHO",; //Imagem Browse
                   "Perc"+StrZero(nCont,3),; //Percentual concluido variavel
                   nil,; //uso livre
                   "ThrSPRO"+StrZero(nCont,3),; //status do processo
                   "EvProc"+StrZero(nCont,3),;
                   0,; 
                   "EvDes"+StrZero(nCont,3),;
                   0,;
                   STR0034,; //"Normal"
                   0,;
                   0,;
                   .F.})                        
                   
                   
                   
Next    

nQtdPorT := nTotGerEv/nThreads

nLastRec := 1                     
nTotEvT  := 0
For nCont := 1 To Len(aThreads) 
    For nAux := nLastRec To Len(aRegs)
        nTotEvT += aRegs[nAux,2]
        If nTotEvT >= nQtdPorT
           aadd(aThreads[nCont,1],aRegs[nAux,1])
           aThreads[nCont,4] += aRegs[nAux,2]
           nTotEvT := 0     
           nLastRec := nAux+1
           Exit
        Else                                     
           If nTotEvT >= nQtdPorT
              aadd(aThreads[nCont,1],aRegs[nAux,1])
              aThreads[nCont,4] += aRegs[nAux,2]
              nTotEvT := 0
           Else
              If aRegs[nAux,2] > 0
                 aadd(aThreads[nCont,1],aRegs[nAux,1])
                 aThreads[nCont,4] += aRegs[nAux,2]
              Endif   
           Endif   
        Endif       
    Next
Next

For nCont := 1 To Len(aThreads)
    If aThreads[nCont,4] > 0
       PutGlbValue(aThreads[nCont,2], "0" )
	   GlbUnLock()

       PutGlbValue(aThreads[nCont,9], "0" )
	   GlbUnLock()

       PutGlbValue(aThreads[nCont,11], "0" )
	   GlbUnLock()

       PutGlbValue(aThreads[nCont,13], "0" )
	   GlbUnLock()

       PutGlbValue(aThreads[nCont,14], "0" )
	   GlbUnLock()

       PutGlbValue(aThreads[nCont,16], "0" )
	   GlbUnLock()

       aThreads[nCont,6] :=	 Time()
	   If !lauto
       	StartJob("RPLSPEGBATH",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,lJob,nQtd,nTotReg,nTipo,@cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte)
		lProcesso := .T.
	   endIf
    Endif   
Next

If lProcesso
   StatusProc(aThreads,aRestTot,.F.,oBrowseSta,oDlg,oSay,cHoraIniT,"1")

   DEFINE MSDIALOG oDlg TITLE STR0035 FROM 008.2,000 TO 028,ndColFin OF GetWndDefault()  //"Status do Processamento"
   
   oDlg:lEscClose := .F.

   @ 035,005 Say oSay PROMPT STR0036  SIZE 220,010 OF oDlg PIXEL //"Tempo de Processamento: "
   
   oBrowseSta := TcBrowse():New( 045, 008, 378, 100,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

   oBrowseSta:AddColumn(TcColumn():New("",nil,;
            nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[1]:BDATA     := { || LoadBitmap( GetResources(), aRestTot[oBrowseSta:nAt,1]) }

   oBrowseSta:AddColumn(TcColumn():New(STR0037,nil,; //"Processo"
            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[2]:BDATA     := { || aRestTot[oBrowseSta:nAt,2] }

   oBrowseSta:AddColumn(TcColumn():New(STR0038,nil,; //"Aberta"
            nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[3]:BDATA     := { || aRestTot[oBrowseSta:nAt,3] }

   oBrowseSta:AddColumn(TcColumn():New(STR0039,nil,; //"Eventos Lidos"
            nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[4]:BDATA     := { || AllTrim(Str(aRestTot[oBrowseSta:nAt,4],10)) }

   oBrowseSta:AddColumn(TcColumn():New(STR0040,nil,; //"Eventos Processados"
            nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[5]:BDATA     := { || aRestTot[oBrowseSta:nAt,10] }

   oBrowseSta:AddColumn(TcColumn():New(STR0041,nil,; //"Eventos Desconsiderados"
            nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[6]:BDATA     := { || aRestTot[oBrowseSta:nAt,11] }

   oBrowseSta:AddColumn(TcColumn():New(STR0042,nil,; //"Inicio"
            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[7]:BDATA     := { || aRestTot[oBrowseSta:nAt,5] }

   oBrowseSta:AddColumn(TcColumn():New(STR0024,nil,; //"% Concluído"
            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[8]:BDATA     := { || aRestTot[oBrowseSta:nAt,8] }

   oBrowseSta:AddColumn(TcColumn():New(STR0043,nil,; //"Fim"
            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[9]:BDATA     := { || aRestTot[oBrowseSta:nAt,6] }

   oBrowseSta:AddColumn(TcColumn():New(STR0044,nil,; //"Tempo Decorrido/Total"
            nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[10]:BDATA     := { || aRestTot[oBrowseSta:nAt,7] }

   oBrowseSta:AddColumn(TcColumn():New(STR0045,nil,; //"Status do Processo"
            nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.T.,nil))
            oBrowseSta:ACOLUMNS[11]:BDATA     := { || aRestTot[oBrowseSta:nAt,9] }

   oBrowseSta:SetArray(aRestTot)

   oTimer 	:= TTimer():New( 10000 ,{ || StatusProc(aThreads,aRestTot,.T.,oBrowseSta,oDlg,oSay,cHoraIniT,"1") },oDlg)	
   oTimer:Activate()
   //Atualização de 10 em 10 segundos do status do processamento....

   //Se em 10 minutos nao houver uma resposta da theard e encarado como time-out
   oTimeOut := TTimer():New( GetNewPar("MV_PLTMOUT",300000) ,{ || StatusProc(aThreads,aRestTot,.T.,oBrowseSta,oDlg,oSay,cHoraIniT,"2") },oDlg)	
   oTimeOut:Activate()
   //5 minutos para identificar se a thread esta executando ou nao...
   
   
   ACTIVATE MSDIALOG oDlg CENTER ON INIT EnChoiceBar(oDlg,{ || TestaFecha(oDlg,aThreads) },{|| TestaFecha(oDlg,aThreads) },.F.)
Elseif !lAuto
   Help("",1,"REGNOIS")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³RPLSA475PRO³ Autor ³ Tulio Cesar            ³ Data ³ 10.03.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Processa a mudanca de fase por lote...                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA475FST(lJob,cPerg,lTipo,nTipFas, lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
LOCAL cSQL             
LOCAL aFiltro
LOCAL cHoraIniT := Time()
LOCAL aResumo   := {}
LOCAL aRetRes
LOCAL nFor            
LOCAL lFlag     := .F.
LOCAL cTitulo
LOCAL nTotReg   := 0
LOCAL nTotEventos := 0
LOCAL nQtd      := 0
LOCAL nRecAtu
LOCAL nHorIni
LOCAL cArqLog  := "PLSLGRV.LOG"
LOCAL aThreads := {}
LOCAL nThreads := GetNewPar("MV_PLSMFNT",1)
LOCAL nQtdFor
LOCAL nCont              
LOCAL aRegs    := {}
LOCAL nPosVet
LOCAL nQtdPorT                 
LOCAL nAux
LOCAL nLastRec
LOCAL lSaida := .F.
LOCAL aCabec       
LOCAL aRestTot := {}
LOCAL lDlg
LOCAL oBrowseSta
LOCAL oTimer                                                                           
LOCAL oTimeOut
LOCAL oSay                                      
LOCAL aBCL    := {}
LOCAL cOriMov := ""                         
LOCAL nTotGerEv := 0
LOCAL cAliasPri
LOCAL lField
LOCAL lProcesso := .F.
LOCAL cNameBAU  := BAU->(RetSQLName("BAU"))
LOCAL cFilBAU   := BAU->(xFilial("BAU"))
LOCAL oDlg
Local oGrid := Nil
Local lPrepGrid := .T.
Local lExecGrid := .T.
Local aInicio := {}
Local nTempoAloc := GetNewPar("MV_PLSTICO",90)
Local nProcs := 0
Local __xRetPeri:= {}


PRIVATE cOpeDe   
PRIVATE cOpeAte
PRIVATE cLocDe
PRIVATE cLocAte
PRIVATE cPegDe
PRIVATE cPegAte
PRIVATE cRDADe
PRIVATE cRDAAte
PRIVATE cAnoDe
PRIVATE cAnoAte
PRIVATE cMesDe
PRIVATE cMesAte     
PRIVATE nTipo       
PRIVATE cCodEmpDe
PRIVATE cCodEmpAte
PRIVATE cContDe
PRIVATE cContAte
PRIVATE cSubConDe
PRIVATE cSubConAte
PRIVATE cGruCobDe
PRIVATE cGruCobAte
PRIVATE lRegCad
PRIVATE cDataDe
PRIVATE cDataAte
PRIVATE cLocAtDe
PRIVATE cLocAtAte                                        
PRIVATE cClaRDA
PRIVATE nOnlyZero
PRIVATE nDifUs    
PRIVATE nVlrDifUs 
PRIVATE cGrpPagDe
PRIVATE cGrpPagAte
PRIVATE lFinal   := .T. 
PRIVATE cRandVar := alltrim(STR(Randomize(1,32000)))
DEFAULT lJob := .F.
DEFAULT cPerg    := "PLS475"
DEFAULT lTipo:=.f. // caso seja .f. esta vindo de outra rotina
DEFAULT nTipFas:=1

PutGlbVars("__xRetPeri",__xRetPeri) // Tratamento para controlar quantidade e periodiciadade.
GlbUnLock()

If nThreads > 15
   nThreads := 15
Endif   
Pergunte(cPerg,.F.)

IgualaVar(lTipo)

aFiltro := { 	 cOpeDe,;  //[1]
				 cOpeAte,;//[2]	
				 cCodEmpDe,;//[3]
				 cCodEmpAte,;//[4]
				 cContDe,;//[5]
				 cContAte,;//[6]
				 cSubConDe,;//[7]
				 cSubConAte,;//[8]
				 cGruCobDe,;//[9]
				 cGruCobAte,;//[10]
				 cDataDe,;//[11]
				 cDataAte,;//[12]
				 cLocAtDe,;//[13]
				 cLocAtAte,;//[14]
				 cClaRDA ,;//[15]
				 nOnlyZero,;//[16]
				 cGrpPagDe,;//[17]
				 cGrpPagAte}//[18]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pede confirmacao...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lJob .And. ! MsgYesNo(STR0017) //"Confirma a mudanca de fase dos PEGS de acordo com os parametros informados ?"
	Return
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza status da PEG                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//somente a revalorizacao de cobranca (nTipo ==4) nao e necessario reprocessar as Pegs
If cOpeDe == cOpeAte .And. nTipo <> 4 //Se for a mesma Operadorado no De/Ate, utilizo ela diretamente     
	PLSM190Pro(,.F.,cOpeDe,cLocDe,cLocAte,cPegDe,cPegAte,cAnoDe,cMesDe,cAnoAte,cMesAte,lJob)

ElseIf nTipo <> 4 //Foi utilizado o De Para com operadoras diferentes    
	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT    

	If Empty(cOpeDe) .Or. !BA0->(DbSeek(xFilial("BA0")+cOpeDe)) //Se nao encontrei a operadora ou o parametro 'De' veio vazio, posiciono no topo
		BA0->(DbGoTop())
	EndIf
		
	While !BA0->(Eof()) //Rodo todas as operadoras que tenho na BA0 a verificar se os parametros De/Para sao atendidos
		If BA0->BA0_CODIDE >= SubStr(cOpeDe,1,1) .And. BA0->BA0_CODINT >= SubStr(cOpeDe,2,3) .And. ;
	   	   BA0->BA0_CODIDE <= SubStr(cOpeAte,1,1) .And. BA0->BA0_CODINT <= SubStr(cOpeAte,2,3)   
	   	   
	   		PLSM190Pro(,.F.,BA0->(BA0_CODIDE+BA0_CODINT),cLocDe,cLocAte,cPegDe,cPegAte,cAnoDe,cMesDe,cAnoAte,cMesAte,lJob)   
	    EndIf   
	    BA0->(DbSkip())
	EndDo
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BCI.BCI_TIPGUI, BCI_FILIAL,BD5.BD5_CODOPE,BCI.BCI_CODOPE,BD5.BD5_CODLDP,BCI.BCI_CODLDP, BD5.BD5_CODPEG, BCI.BCI_CODPEG,BE4.BE4_CODLDP, BCI.BCI_CODLDP, BE4.BE4_CODPEG,BCI.BCI_CODPEG,BD5.BD5_DATPRO,BE4.BE4_DATPRO,BD5.BD5_SITUAC,BE4_SITUAC,BD5.BD5_FASE,BD5.BD5_QTDEVE,BE4.BE4_QTDEVE,BCI.R_E_C_N_O_ AS RECBCI  , BD5.R_E_C_N_O_ AS RECBD5, BE4.R_E_C_N_O_ AS RECBE4, "  
cSql += " BE4.BE4_OPEUSR ABE4, BE4.BE4_CODEMP BBE4, BE4.BE4_MATRIC CBE4, BE4.BE4_TIPREG DBE4, BE4.BE4_DIGITO EBE4, "
cSql += " BD5.BD5_OPEUSR ABD5, BD5.BD5_CODEMP BBD5, BD5.BD5_MATRIC CBD5, BD5.BD5_TIPREG DBD5, BD5.BD5_DIGITO EBD5  "
cSql += "FROM "+RetSQLName("BCI")+" BCI "
cSql +=" LEFT  JOIN  " + RetSqlName("BD5") + " BD5 ON BD5.BD5_FILIAL = BCI.BCI_FILIAL AND BD5.BD5_CODOPE = BCI.BCI_CODOPE AND BD5.BD5_CODLDP = BCI.BCI_CODLDP AND BD5.BD5_CODPEG = BCI.BCI_CODPEG AND BD5.BD5_SITUAC = '1' AND BD5.BD5_FASE = '1' AND BD5.D_E_L_E_T_ = ' '"
cSql +=" LEFT  JOIN  " + RetSqlName("BE4") + " BE4 ON BE4.BE4_FILIAL = BCI.BCI_FILIAL AND BE4.BE4_CODOPE = BCI.BCI_CODOPE AND BE4.BE4_CODLDP = BCI.BCI_CODLDP AND BE4.BE4_CODPEG = BCI.BCI_CODPEG AND BE4.BE4_SITUAC = '1' AND BE4.BE4_FASE = '1' AND BE4.D_E_L_E_T_ = ' '"
cSQL += " WHERE BCI.BCI_FILIAL = '"+xFilial("BCI")+"' AND "
cSQL += " ( BCI.BCI_CODOPE >= '"+cOpeDe+"'  AND  BCI.BCI_CODOPE <= '"+cOpeAte+"' ) AND  "
cSQL += " ( BCI.BCI_CODLDP >= '"+cLocDe+"'  AND  BCI.BCI_CODLDP <= '"+cLocAte+"' ) AND  "
cSQL += " ( BCI.BCI_CODPEG >= '"+cPegDe+"'  AND  BCI.BCI_CODPEG <= '"+cPegAte+"' ) AND  "
cSQL += " ( BCI.BCI_CODRDA >= '"+cRdaDe+"'  AND  BCI.BCI_CODRDA <= '"+cRdaAte+"' ) AND  "
cSQL += " ( BCI.BCI_ANO    >= '"+cAnoDe+"'  AND  BCI.BCI_ANO    <= '"+cAnoAte+"' ) AND  "                
cSQL += " ( BCI.BCI_MES    >= '"+cMesDe+ "' AND  BCI.BCI_MES    <= '"+cMesAte+"' ) AND  "
cSQL += " BCI.D_E_L_E_T_ = '' "
cAliasTrb := GetNextAlias()
cSQL := ChangeQuery( cSQL )
dbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL),cAliasTrb , .F.,.T. )

If PLSMDFGRI(.T.)

	If ValType(oGrid) != "U"
		oGrid:Terminate()
		oGrid := Nil
	EndIf
	
	oGrid := GridClient():New()
	oGrid:nWAIT4AGENTS := nTempoAloc
	aInicio := {cEmpAnt,cFilAnt}
	lPrepGrid := oGrid:Prepare('PLINMDFGR',aInicio,'PLEXMDFGR','PLFNMDFGR')

	If !lPrepGrid
		PLSGRILOG("Erro GRID: Falha de Preparacao:" + oGrid:GetError())
		oGrid:Terminate()
		oGrid := Nil
	Else//If !lPrepGrid

		ProcRegua(-1)
		cChvPeg := ""

		While !(cAliasTrb)->(Eof())

			//Retorno de fase por PEG - dispara o agente apenas uma vez para a PEG
			If nTipFas == 2 .And. cChvPeg == (cAliasTrb)->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)
				(cAliasTrb)->(dbSkip())
				Loop
			EndIf
			
			nProcs++			
			aExec := {}
			aExec := IniParExec(cAliasTrb,nTipFas)
			lExecGrid := oGrid:Execute(aExec)
			IncProc("[" + AllTrim(Str(nProcs)) + "] " + STR0071)//"guias processadas ..."

			If !lExecGrid
				PLSGRILOG("Erro GRID: Falha de Execucao:" + oGrid:GetError())
				oGrid:Terminate()
				oGrid := Nil
			EndIf	

			cChvPeg := (cAliasTrb)->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)
			(cAliasTrb)->(dbSkip())
			//Sleep(nTempoAloc)

		EndDo//!(cAliasTrb)->(Eof())
			
	EndIf//If !lPrepGrid
	
	(cAliasTrb)->(dbCloseArea())

Else//PROCESSAMENTO CHAMADO somente PELA ROTINA MUDANÇA DE FASE PLSA498 
	
	nTotReg :=0
	While ! (cAliasTrb)->(Eof())
		If (cAliasTrb)->RECBD5 > 0 .or. (cAliasTrb)->RECBE4  > 0
			Aadd(aRegs,{(cAliasTrb)->RECBCI,(cAliasTrb)->RECBD5,(cAliasTrb)->RECBE4})
			nTotReg ++
		Endif	
	    (cAliasTrb)->(DbSkip())
	Enddo
	(cAliasTrb)->(DbCloseArea())
	DbSelectArea("BA1")
	
	For nCont := 1 To nTotReg
	    aadd(aThreads,{{aRegs[nCont,1]},;           //Array com os Recnos das Pegs
	                   "ThrPls"+StrZero(nCont,3)+"_"+cRandVar,; //Codigo ad Theard
	                   "Não",;                        //Aberta Sim Ou Nao
	                   nCont,;                       //Total de Eventos
	                   0,;                         //% concluido
	                   "",;                        //Hora Inicio
	                   "",;                        //Hora Fim
	                   "",;                        //Tempo Total
	                   "ThrPlsSta"+StrZero(nCont,3)+"_"+cRandVar,; //Status do Processo...
	                   "BR_VERMELHO",; //Imagem Browse
	                   "Perc"+StrZero(nCont,3)+"_"+cRandVar,; //Percentual concluido variavel
	                   nil,; //uso livre
	                   "ThrSPRO"+StrZero(nCont,3)+"_"+cRandVar,; //status do processo
	                   "EvProc"+StrZero(nCont,3)+"_"+cRandVar,;
	                   0,; 
	                   "EvDes"+StrZero(nCont,3)+"_"+cRandVar,;
	                   0,;
	                   STR0034,; //"Normal"
	                   0,;
	                   0,;
	                   .F.,;
	                   If(!Empty(aRegs[nCont,2]),aRegs[nCont,2],aRegs[nCont,3])})                        
	Next
	
	If !lAuto
		Processa( {|| P475TelaPrc(nThreads,aThreads,lJob,nQtd,nTotReg,nTipo,cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte,aRestTot,oBrowseSta, oTimer, oSay,oDlg) },"Analisando a Mudança de Fase" )   
	endIf

	ClearGlbValue("__xRetPeri") // Limpado Variavel Global utilizado em Job

EndIf //PLSMDFGRI()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³xGetPvProfString³ Autor ³ Tulio Cesar            ³ Data ³ 10.03.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Recebe o retorno da funcao GetPvProfString.                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function xGetPvProfString( cSecao, cVar    , cDef, cIniFile )
Local uRet

uRet := GetPvProfString( cSecao, cVar    , cDef, cIniFile )
If Len(uRet) == 0
   uRet := cDef
EndIf                                                             


Return uRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RPLSPEGBATH      ³ Autor ³ Tulio Cesar³ Data ³ 20.12.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Roda processo theard.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RPLSPEGBATH(cEmp,cFil,aThreads,lJob,nQtd,nTotReg,nTipo,cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cNameUsr,cDataDe,cDataAte)
LOCAL nFor
LOCAL nFor2
LOCAL nRecAtu
LOCAL lFlag                   
LOCAL aGuias := aThreads[nCont,1]                                   
LOCAL nPos
LOCAL cOriMov := ""
LOCAL nDifUs := 0                                                                                  
LOCAL nVlrDifUs := 0   
LOCAL aPLS475   := {}    
PRIVATE aRotina:={}
DEFAULT aBCL := {}
DEFAULT cNameUsr := ""
DEFAULT cDataDe  := ""
DEFAULT cDataAte := ""

lJob := .T.
RpcSetType ( 3 )

RpcSetEnv( cEmp, cFil,,,'PLS')

PutGlbValue(aThreads[nCont,2], "1" )
GlbUnLock()

For nFor2 := 1 To Len(aGuias)
    nRecAtu := aGuias[nFor2]
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Posiciona no peg...                                                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    BCI->( DbGoTo(nRecAtu) )
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Flag																  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    lFlag := .T.
    
    nPos := Ascan(aBCL,{|x| x[1] == BCI->BCI_TIPGUI})
    If nPos > 0
       cOriMov := aBCL[nPos,2]
    Else
       BCL->(DbSetOrder(1))
       BCL->(DbSeek(xFilial("BCI")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
       cOriMov := BCL->BCL_CDORIT
    Endif
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Alimenta Array utilizado para filtro de datas   			        ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    AaDd(aPLS475,.T.)
    AaDd(aPLS475,cDataDe)
    AaDd(aPLS475,cDataAte)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Processo														  	  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If     nTipo == 1 //Mudar a Fase
           PLSA175FAS("BCI",nRecAtu,K_Fase,nil,.F.,aFiltro,lRegCad,aThreads[nCont,4],aThreads,nCont,cNameUsr,aPLS475)
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Atualiza status													 ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   PLSM190Pro( ,,,,,,,,,,,,.T.,nRecAtu )		     
           cTitulo := STR0054 //"Mudança de fase das PEGS concluída."
    ElseIf nTipo == 2 //Retorno de Fase                                    
           PLSA175RGR("BCI",nRecAtu,K_RetFas,nil,.F.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"1",nil,nil,aPLS475)
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Atualiza status													 ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   PLSM190Pro( ,,,,,,,,,,,,.T.,nRecAtu )		     
           cTitulo := STR0055 //"Retorno de fase das PEGS concluída."
    ElseIf nTipo == 3 //Revalorizar Pagamento
           PLSA175RGR("BCI",nRecAtu,K_RevPag,nil,.F.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"2",nDifUs,nVlrDifUs,aPLS475)
           cTitulo := STR0056 //"Revalorização de Pagamento das PEGS concluída."
    ElseIf nTipo == 4 //Revalorizar Cobranca
           PLSA175RGR("BCI",nRecAtu,K_RetCob,nil,.F.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"3",nil,nil,aPLS475)
           cTitulo := STR0057 //"Revalorização de Cobranca das PEGS concluída."
    ElseIf nTipo == 5 //Revalorizar Cobranca e Cobranca
           PLSA175RGR("BCI",nRecAtu,K_RetCP,nil,.F.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"4",nDifUs,nVlrDifUs,aPLS475)
           cTitulo := STR0058 //"Revalorização de Cobrança e Pagamento das PEGS concluída."
    Endif             
Next

PutGlbValue(aThreads[nCont,9], "1" )
GlbUnLock()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RPLSPEGBATH      ³ Autor ³ Tulio Cesar³ Data ³ 20.12.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Roda processo theard.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFASTBATH(cEmp,cFil,aThreads,lJob,nQtd,nTotReg,nTipo,cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cNameUsr,cDataDe,cDataAte, cLockThread, cLock, lHdl)
LOCAL nFor
LOCAL nFor2 := 1
LOCAL nRecAtu
LOCAL lFlag                   
LOCAL aGuias := aThreads[nCont,1]                                   
LOCAL nPos
LOCAL cOriMov := ""
LOCAL nDifUs := 0                                                                                  
LOCAL nVlrDifUs := 0   
LOCAL aPLS475   := {}    
LOCAL __xRetPeri:={}
PRIVATE aRotina:={}
DEFAULT aBCL := {}
DEFAULT cNameUsr := ""
DEFAULT cDataDe  := ""
DEFAULT cDataAte := ""
DEFAULT lHdl	:= .f.
DEFAULT cLockThread	:= ''
DEFAULT cLock := ''

lJob := .T.
RpcSetType ( 3 )

RpcSetEnv( cEmp, cFil,,,'PLS')

If !Empty(cLockThread)
	PlSemafCtrl( cLockThread )
Endif	

PutGlbValue(aThreads[nCont,2], "1" )
GlbUnLock()

//PutGlbVars("__xRetPeri",__xRetPeri)
//GlbUnLock()

For nFor2 := 1 To Len(aGuias)
    nRecAtu := aGuias[nFor2]
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Posiciona no peg...                                                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    BCI->( DbGoTo(nRecAtu) )
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Flag																  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    lFlag := .T.
    
    BCL->(DbSetOrder(1))
    BCL->(DbSeek(xFilial("BCI")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
    cAliasPri := BCL->BCL_ALIAS
 
    If     nTipo == 1 .and. aThreads[nCont,22] > 0//Mudar a Fase
    		If cAliasPri =="BD5"  
    			DbSelectArea("BD5")
    			BD5->(DbGoTo(aThreads[nCont,22]))		
    		Else
				DbSelectArea("BE4")
    			BE4->(DbGoTo(aThreads[nCont,22]))	    		
    		Endif
    			
  			aRetAux:=PLSXMUDFAS(BCL->BCL_ALIAS,"1",BCL->BCL_CODOPE,BCL->BCL_TIPGUI,&(cAliasPri+"->"+cAliasPri+"_DATPRO"),.F.,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aThreads,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL)
  			
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Atualiza status													 ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   PLSM190Pro( ,,,,,,,,,,,,.T.,nRecAtu )		     
           cTitulo := "Mudança de fase das GUIAS concluída."
    Endif             
Next

PutGlbValue(aThreads[nCont,9], "1" )
GlbUnLock()

If !Empty(cLockThread)
	PlSemafCtrl( cLockThread, .T., lHdl )
Endif	

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³StatusProc³ Autor ³ Tulio Cesar            ³ Data ³ 10.10.07 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Analisa status do processamento e atualiza em tela.         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function StatusProc(aThreads,aRestTot,lRefresh,oBrowseSta,oDlg,oSay,cHoraIniT,cTipo)
LOCAL lSaida     := .T.   
LOCAL nCont  
LOCAL lTime      := .F.
DEFAULT cTipo    := "1"
//cTipo == "1" - Temporizador de estatistica do processo em execucao
//cTipo == "2" - Temporizador para verificar se algum processo caiu (erro de conexao, erro fatal error.log)

If cTipo == "2"
   If Empty(__cLastTime)
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0059 + time() + "]" , 0, 0, {})//"Analisando status das Threads... ["
      __cLastTime := Time()
   Else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0060+__cLasttime+STR0061+time()+"]" , 0, 0, {})//"Analisando status das Threads... Ultima execução em ["###"] Agora ["
   Endif   
Endif   

For nCont := 1 To Len(aThreads)
    If aThreads[nCont,4] > 0
       If cTipo == "1" 
	      If GetGlbValue(aThreads[nCont,13]) == "1" //Theard houve algum problema em execucao
	      	  // Esse item foi removido deviDo para os casos de muitas guias esse item é exibido varias vezes e o usaurio tem que confirmar essa mensagem guia a guia isso estava impactando, 
	        // Aviso(STR0062,STR0063+aThreads[nCont,2]+STR0064,{STR0065},2) //"Problema na execução de Theard"###"Ocorreu algum problema na execução da Thread "###". Analise o console do Protheus para maiores informações"###"Ok"
	         aThreads[nCont,18] := STR0066 //"Cancelado"
	      Endif   
	       
	      If GetGlbValue(aThreads[nCont,2]) == "1"
	         aThreads[nCont,3] := STR0050 //"Sim"
	      Endif   
	      If GetGlbValue(aThreads[nCont,9]) == "1" 
	         aThreads[nCont,3] := STR0050 //"Sim"
	         If Empty(aThreads[nCont,7])
	            aThreads[nCont,7]  := Time()
	            aThreads[nCont,8]  := elaptime(aThreads[nCont,6],aThreads[nCont,7])
	            aThreads[nCont,10] := "BR_VERDE"
	            aThreads[nCont,5]  := GetGlbValue(aThreads[nCont,11])
	            aThreads[nCont,15] := GetGlbValue(aThreads[nCont,14])
	            aThreads[nCont,17] := GetGlbValue(aThreads[nCont,16])
	            If lRefresh .And. ! lTime
	               oSay:cCaption := STR0036+aThreads[nCont,8] //"Tempo de Processamento: "
	               oSay:Refresh()        
	               lTime := .T.
	            Endif   
	         Endif                                                                 
	      Else
	         lSaida := .F.
	         aThreads[nCont,8] := elaptime(aThreads[nCont,6],Time())             
	         aThreads[nCont,5] := GetGlbValue(aThreads[nCont,11])
	         aThreads[nCont,15] := GetGlbValue(aThreads[nCont,14])   
	         aThreads[nCont,17] := GetGlbValue(aThreads[nCont,16])
	         If lRefresh .And. ! lTime
	            oSay:cCaption := STR0036+elaptime(cHoraIniT,Time())              //"Tempo de Processamento: "
	            lTime := .T.
	            oSay:Refresh()
	         Endif   
	      Endif   
	   Else         
          If VAL(aThreads[nCont,5]) < 100
             If aThreads[nCont,19] == 0 .And. aThreads[nCont,20] == 0 .And. ! aThreads[nCont,21]
                aThreads[nCont,19] := val(aThreads[nCont,15])                            
                aThreads[nCont,20] := val(aThreads[nCont,17])                                    
                aThreads[nCont,21] := .T.
             Else
                If ( aThreads[nCont,19] == val(aThreads[nCont,15]) ) .And. ;
                   ( aThreads[nCont,20] == val(aThreads[nCont,17]) )
                    PutGlbValue(aThreads[nCont,13], "1" ) //Nao foi atualizada e gerou time-out
                    aThreads[nCont,18] := STR0066 //"Cancelado"
                Endif    
             Endif   
          Endif   
	   Endif   
	Endif   
Next           

aRestTot := {}
For nCont := 1 To Len(aThreads)
    If aThreads[nCont,4] > 0
       aadd(aRestTot,{aThreads[nCont,10],;
                     aThreads[nCont,2],;
                     aThreads[nCont,3],;
                     aThreads[nCont,4],;
                     aThreads[nCont,6],;
                     aThreads[nCont,7],;
                     aThreads[nCont,8],;
                     aThreads[nCont,5],;
                     aThreads[nCont,18],; //era 13
                     aThreads[nCont,15],;
                     aThreads[nCont,17]})
    Endif                 
Next          

If lRefresh
   oBrowseSta:SetArray(aRestTot)        
   oBrowseSta:Refresh()
Endif   

Return(lSaida)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³StatusFstProc³ Autor ³ 		              ³ Data ³ 30.05.15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Analisa status do processamento e atualiza em tela.         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function StatusFstProc(aThreads,aRestTot,lRefresh,oBrowseSta,oDlg,oSay,cHoraIniT,cTipo)
LOCAL lSaida     := .T.   
LOCAL nCont  
LOCAL lTime      := .F.
LOCAL nFinalCount:= 0
DEFAULT cTipo    := "1"
//cTipo == "1" - Temporizador de estatistica do processo em execucao
//cTipo == "2" - Temporizador para verificar se algum processo caiu (erro de conexao, erro fatal error.log)

If cTipo == "2"
   If Empty(__cLastTime)
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0059 + time() + "]" , 0, 0, {}) //"Analisando status das Threads... ["
      __cLastTime := Time()
   Else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0060+__cLasttime+STR0061+time()+"]" , 0, 0, {})//"Analisando status das Threads... Ultima execução em ["###"] Agora ["
   Endif   
Endif   

For nCont := 1 To Len(aThreads)
    If aThreads[nCont,4] > 0
       If cTipo == "1" 
	      If GetGlbValue(aThreads[nCont,13]) == "1" //Theard houve algum problema em execucao
	      		//Esse item foi retirado devido na mudanaça de fase estava apresentando varias vezes essa mesagame, assim forcando o usuario clicar varias vezes na mensagem 
	         //Aviso(STR0062,STR0063+aThreads[nCont,2]+STR0064,{STR0065},2) //"Problema na execução de Theard"###"Ocorreu algum problema na execução da Thread "###". Analise o console do Protheus para maiores informações"###"Ok"
	         aThreads[nCont,18] := STR0066 //"Cancelado"
            aThreads[nCont,7]  := Time()
            aThreads[nCont,8]  := elaptime(aThreads[nCont,6],aThreads[nCont,7])
	      Endif   
	       
	      If GetGlbValue(aThreads[nCont,2]) == "1"
	         aThreads[nCont,3] := STR0050 //"Sim"
	      Endif   
	      If GetGlbValue(aThreads[nCont,9]) == "1" 
	         aThreads[nCont,3] := STR0050 //"Sim"
	         If Empty(aThreads[nCont,7])
	            aThreads[nCont,7]  := Time()
	            aThreads[nCont,8]  := elaptime(aThreads[nCont,6],aThreads[nCont,7])
	            aThreads[nCont,10] := "BR_VERDE"
	            aThreads[nCont,5] := "100%"
//	            aThreads[nCont,5]  := GetGlbValue(aThreads[nCont,11])
	            aThreads[nCont,15] := GetGlbValue(aThreads[nCont,14])
	            aThreads[nCont,17] := GetGlbValue(aThreads[nCont,16])
	            If lRefresh .And. ! lTime
	               oSay:cCaption := STR0036+aThreads[nCont,8] //"Tempo de Processamento: "
	               oSay:Refresh()        
	               lTime := .T.
	            Endif   
	         Endif                                                                 
	      Else
	         lSaida := .F.
	         aThreads[nCont,8] := elaptime(aThreads[nCont,6],Time())             
	         aThreads[nCont,5] := GetGlbValue(aThreads[nCont,11])
	         aThreads[nCont,15] := GetGlbValue(aThreads[nCont,14])   
	         aThreads[nCont,17] := GetGlbValue(aThreads[nCont,16])
	         If lRefresh .And. ! lTime
	            oSay:cCaption := STR0036+elaptime(cHoraIniT,Time())              //"Tempo de Processamento: "
	            lTime := .T.
	            oSay:Refresh()
	         Endif   
	      Endif   
	   Else         
          If VAL(aThreads[nCont,5]) < 100
             If aThreads[nCont,19] == 0 .And. aThreads[nCont,20] == 0 .And. ! aThreads[nCont,21]
                aThreads[nCont,19] := val(aThreads[nCont,15])                            
                aThreads[nCont,20] := val(aThreads[nCont,17])                                    
                aThreads[nCont,21] := .T.
             Else
                If ( aThreads[nCont,19] == val(aThreads[nCont,15]) ) .And. ;
                   ( aThreads[nCont,20] == val(aThreads[nCont,17]) )
                    PutGlbValue(aThreads[nCont,13], "1" ) //Nao foi atualizada e gerou time-out
                    aThreads[nCont,18] := STR0066 //"Cancelado"
		            aThreads[nCont,7]  := Time()
		            aThreads[nCont,8]  := elaptime(aThreads[nCont,6],aThreads[nCont,7])
                Endif    
             Endif   
          Endif   
	   Endif   
	Endif   
Next           

aRestTot := {}
For nCont := 1 To Len(aThreads)
    If aThreads[nCont,4] > 0
       aadd(aRestTot,{aThreads[nCont,10],;
                     aThreads[nCont,2],;
                     aThreads[nCont,3],;
                     aThreads[nCont,4],;
                     aThreads[nCont,6],;
                     aThreads[nCont,7],;
                     aThreads[nCont,8],;
                     aThreads[nCont,5],;
                     aThreads[nCont,18],; //era 13
                     aThreads[nCont,15],;
                     aThreads[nCont,17]})
    Endif                 
Next          

If lRefresh
   oBrowseSta:SetArray(aRestTot)        
   oBrowseSta:Refresh()
Endif   

// cq
For nCont := 1 To Len(aThreads)
	If !Empty(aThreads[nCont,7])
		nFinalCount++
	EndIf
Next nCont

If Len(aThreads) == nFinalCount  .and. lFinal
	msginfo("Processamento das guias concluído.")
	lFinal := .F.
EndIf

Return(lSaida)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³TestaFecha³ Autor ³ Tulio Cesar            ³ Data ³ 10.10.07 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se e possivel fechar a janela ou nao.              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TestaFecha(oDlg,aThreads)
LOCAL nFor
LOCAL lFlag := .T.

For nFor := 1 To Len(aThreads)
    If aThreads[nFor,4] > 0 .And. aThreads[nFor,10] <> "BR_VERDE" .And. AllTrim(aThreads[nFor,18]) <> STR0066 
       lFlag := .F.
    Endif
Next

If ! lFlag 
   MsgStop(STR0068) //"Existem Threads Pendentes a Rotina não poderá ser finalizada."
Else
   oDlg:End()
Endif
       
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RPLSATUVGL  ³ Autor ³ Tulio Cesar       ³ Data ³ 20.12.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza dados das therads...                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RPLSATUVGL(aThreads,nCont,nTotEventos,cTipo,nQtdEve,cLocalAnalise,cAlias,cChave)
LOCAL nAuxTot  := val(GetGlbValue(aThreads[nCont,14]))+nQtdEve
LOCAL nAuxTot2 := val(GetGlbValue(aThreads[nCont,16]))+nQtdEve
LOCAL lGerarLog:= GetNewPar("MV_PLSLAMF","0") == "1"
LOCAL cFileLog := "PLSLGAMF.LOG"
LOCAL cTextoLog:= ""
DEFAULT cLocalAnalise := ""                                                            
DEFAULT cAlias := ""
DEFAULT cChave := ""

If lGerarLog
   cTextoLog := "["+aThreads[nCont,2]+"] "+;
   				IF(cTipo=="1","[ Processado ]","[ Desconsid. ]")+;
                " Alias ["+cALias+"] Chave ["+cChave+"]"+;
                " Eventos Guia ["+StrZero(nQtdEve,6)+"]"+;
                " Eventos Totais ["+StrZero(If(cTipo=="1",nAuxTot,nAuxTot2),6)+"]"+;
                " Análise ["+cLocalAnalise+"]"
                
   PlsLogFil(cTextoLog,cFileLog)
Endif   

If cTipo == "1" //Somar nos processados                   
   PutGlbValue(aThreads[nCont,14],AllTrim(str(nAuxTot,10)))
Else //Somar nos desconsiderados
   PutGlbValue(aThreads[nCont,16],AllTrim(str(nAuxTot2,10)))
Endif

nAuxTot  := val(GetGlbValue(aThreads[nCont,14]))
nAuxTot2 := val(GetGlbValue(aThreads[nCont,16]))

PutGlbValue(aThreads[nCont,11], AllTrim(str(((nAuxTot+nAuxTot2)*100)/nTotEventos,10)))
GlbUnLock()

Return


/*/{Protheus.doc} PLINMDFGR
//Funcao criada para inicializar o ambiente do agente
@author timoteo.bega
@since 18/11/2016
/*/
Function PLINMDFGR(aParam)
Local cEmpParm := aParam[1]
Local cFilParm := aParam[2]

RPCSetType(3)
RpcSetEnv ( cEmpParm, cFilParm,,, 'PLS',"PLSA475", {"BCI","BCL","BD5","BE4"},,,.T. )

Return .T.

/*/{Protheus.doc} PLEXMDFGR
//Funcao criada para ser o metodo execute do grid
@author timoteo.bega
@since 18/11/2016
/*/
Function PLEXMDFGR(aExec)
Local cAliCab	:= Iif(Empty(aExec[4]),"BD5",aExec[4])
Local nRecCab	:= Iif(Empty(aExec[3]),0,aExec[3])
Local cCodPeg	:= Iif(Empty(aExec[13]),0,aExec[13])
Local nTipFas	:= Iif(Empty(aExec[14]),1,aExec[14])
Local lContinua:= .T.

cInicio := Time()
BCI->(dbSetOrder(14))//BCI_FILIAL + BCI_CODPEG
If BCI->(msSeek(xFilial("BCI")+cCodPeg))
	BCL->(dbSetOrder(1))//BCL_FILIAL + BCL_CODOPE + BCL_TIPGUI
	If !BCL->(msSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
		lContinua := .F.
		PLSGRILOG("Nao foi possivel localizar o tipo de guia " + BCI->BCI_TIPGUI)
	EndIf
Else
	lContinua := .F.
	PLSGRILOG("Nao foi possivel localizar o PEG " + cCodPeg)
EndIf

If lContinua

	dbSelectArea(cAliCab)
	(cAliCab)->(dbGoTo(nRecCab))
	BEGIN TRANSACTION

	If nTipFas == 1//Mudanca de fase
		PLSXMUDFAS(aExec[4],aExec[5],aExec[6],aExec[7],aExec[8],aExec[9],aExec[10],aExec[11],aExec[12])
	ElseIf nTipFas == 2//Retorno de fase
		PLSA175RGR("BCI",aExec[15],K_RetFas,Nil,.F.,,,,,BCL->BCL_CDORIT,,"1",Nil,Nil,)
		PLSM190PRO(,,,,,,,,,,,,.T.,aExec[15])
	ElseIf nTipFas == 3//Revalorizacao de Pagamento
		PLSA175RGR("BCI",aExec[15],K_RevPag,Nil,.F.,,,,,BCL->BCL_CDORIT,,"2",Nil,Nil,)
	ElseIf nTipFas == 4//Revalorizacao de Cobranca
		PLSA175RGR("BCI",aExec[15],K_RetCob,Nil,.F.,,,,,BCL->BCL_CDORIT,,"3",Nil,Nil,)
	ElseIf nTipFas == 5//Revalorizacao de Cobranca e Pagamento
		PLSA175RGR("BCI",aExec[15],K_RetCP,Nil,.F.,,,,,BCL->BCL_CDORIT,,"4",Nil,Nil,)
	EndIf

	END TRANSACTION

EndIf//lContinua	
cTermino := Time()
cTexto := AllTrim(Str(nRecCab)) + " Inicio: " + cInicio + " Termino: " + cTermino
PLSGRILOG(cTexto)

Return

/*/{Protheus.doc} PLFNMDFGR
//Funcao criada para ser executa na finalizacao do agente
@author timoteo.bega
@since 18/11/2016
/*/
Function PLFNMDFGR()
Return

/*/{Protheus.doc} PLSMDFGRI
//Funcao criada para verificar se a rotina podera ser executada utilizando recursos do grid
@author timoteo.bega
@since 18/11/2016
/*/
Function PLSMDFGRI(lMsg, lauto)
Local lRet := .T.
Default lMsg := .T.
Default lAuto := .F.

If lauto
	lret := .F.
endIf

If lret .AND. !GetNewPar("MV_PLSMFGR",.F.)
	lRet := .F.
EndIf

If lRet .And. Upper(GetPvProfString("GridAgent","CoordServer","ERROR",GetADV97())) == 'ERROR'
	lRet := .F.
EndIf 

If lRet .And. lMsg .And. !MsgYesNo(STR0072)//"Deseja executar a mudança de fase por lote utilizando grid de procssamento ?"
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} IniParExec
//Funcao criada para retornar a matriz de parametros de execucao do agente
@author timoteo.bega
@since 18/11/2016
/*/
Static Function IniParExec(cAliasTrb,nTipFas)
Local cAliCab		:= ""
Local cTipo			:= "1"
Local cTipGui		:= ""
Local cCodPeg		:= ""
Local cCodOpe		:= (cAliasTrb)->BCI_CODOPE
Local dDatPro		:= dDataBase
Local lAutori		:= .F.
Local lPergun		:= .F.
Local nRecCab		:= 0
Default nTipFas	:= 1 		

If !Empty((cAliasTrb)->RECBE4)
	cAliCab := "BE4"
	nRecCab := (cAliasTrb)->RECBE4
Else
	cAliCab := "BD5"
	nRecCab := (cAliasTrb)->RECBD5	
EndIf

cTipGui := (cAliasTrb)->BCI_TIPGUI
cCodPeg	:= (cAliasTrb)->BCI_CODPEG
nRecBCI	:= (cAliasTrb)->RECBCI

Return  {/*1*/cEmpAnt,/*2*/cFilAnt,/*3*/nRecCab,/*4*/cAliCab,/*5*/cTipo,/*6*/cCodOpe,/*7*/cTipGui,/*8*/dDatPro,/*9*/lAutori,/*10*/Nil,;
		/*11*/Nil,/*12*/lPergun,/*13*/cCodPeg,/*14*/nTipFas,/*15*/nRecBCI}
		
		
/*/{Protheus.doc} P475TELAPRC
//Funcao criada para exibir as Guias que estao sendo processada pelo StarJob
@author totvs
@since 15/05/2017
/*/
Static Function P475TelaPrc(nThreads,aThreads,lJob,nQtd,nTotReg,nTipo,cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte,aRestTot,oBrowseSta, oTimer, oSay,oDlg)

Local nThrIni 	:= 1
Local nThrMax 	:= nThrIni +  nThreads
Local lProcesso	:= .F.
Local lHdl			:= .f.
Local lHdlThread	:= .f.
Local cSrvName  	:= Upper(AllTrim(GetPvProfString( "TCP", "PORT", "", GetADV97() )))
Local cLock 	:= "PlProcPEGProcPeg.lck"	


ProcRegua(nTotReg)

nTotGuiPrc:=Len(aThreads)
nCont:=1

While .T. 
	While nThrIni <= nThrMax  .and.  nCont <= nTotGuiPrc
				
		cLockThread := cSrvName + allTrim(str(nThrIni)) + ".lck"
		lHdlThread := PlSemafCtrl( cLockThread )
	
		If ( lHdlThread )
	
			While !lHdl
				lHdl := PlSemafCtrl( cLock )
	
				If ( lHdl )
					exit
				Endif
				sleep( 1000 )
			EndDo
					
			If aThreads[nCont,4] > 0
			
				nThrIni++
			
				PutGlbValue(aThreads[nCont,2], "0" )
				GlbUnLock()
		
				PutGlbValue(aThreads[nCont,9], "0" )
				GlbUnLock()
		
				PutGlbValue(aThreads[nCont,11], "0" )
				GlbUnLock()
		
				PutGlbValue(aThreads[nCont,13], "0" )
				GlbUnLock()
		
				PutGlbValue(aThreads[nCont,14], "0" )
				GlbUnLock()
		
				PutGlbValue(aThreads[nCont,16], "0" )
				GlbUnLock()
					
				aThreads[nCont,6] :=	 Time()
				ProcMudaFas(cEmpAnt,cFilAnt,aThreads,lJob,nQtd,nTotReg,nTipo,@cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte,lHdlThread, cLockThread, cLock, lHdl)
	
			//	sleep(1500)

				
				//StartJob("PLSFASTBATH",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,lJob,nQtd,nTotReg,nTipo,@cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte,)
				IncProc(STR0073+Alltrim(StrZero(nCont,6))+ STR0074+Alltrim(Strzero(nTotReg,6)) )
				
				nCont ++
						
				If nCont > nTotGuiPrc
					Exit
				Endif	
				
				
				If nThrIni > nThrMax
					nThrIni := 1
					Exit
				Endif
						
			Endif	
		Endif
	
		sleep(1500)
	
	EndDo
	nThrIni := 1
	lProcesso := .T.
	nQtd := 1
	If nCont > nTotGuiPrc
		PlSemafCtrl( cLock, .T., lHdl )
		Exit
	Endif	


Enddo
	
If lProcesso

	StatusFstProc(aThreads,aRestTot,.F.,oBrowseSta,oDlg,oSay,cHoraIniT,"1")
	
	DEFINE MSDIALOG oDlg TITLE STR0035 FROM 008.2,000 TO 028,ndColFin OF GetWndDefault()  //"Status do Processamento"
	   
	oDlg:lEscClose := .F.
	
	@ 035,005 Say oSay PROMPT STR0036  SIZE 220,010 OF oDlg PIXEL //"Tempo de Processamento: "
	   
	oBrowseSta := TcBrowse():New( 045, 008, 378, 100,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	
	oBrowseSta:AddColumn(TcColumn():New("",nil,;
	            nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[1]:BDATA     := { || LoadBitmap( GetResources(), aRestTot[oBrowseSta:nAt,1]) }
	
	oBrowseSta:AddColumn(TcColumn():New(STR0037,nil,; //"Processo"
	            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[2]:BDATA     := { || aRestTot[oBrowseSta:nAt,2] }
	
	oBrowseSta:AddColumn(TcColumn():New(STR0024,nil,; //"% Concluído"
	            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[3]:BDATA     := { || aRestTot[oBrowseSta:nAt,8] }
	
	oBrowseSta:AddColumn(TcColumn():New(STR0042,nil,; //"Inicio"
	            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[4]:BDATA     := { || aRestTot[oBrowseSta:nAt,5] }
	
	oBrowseSta:AddColumn(TcColumn():New(STR0043,nil,; //"Fim"
	            nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[5]:BDATA     := { || aRestTot[oBrowseSta:nAt,6] }
	
	oBrowseSta:AddColumn(TcColumn():New(STR0044,nil,; //"Tempo Decorrido/Total"
	            nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[6]:BDATA     := { || aRestTot[oBrowseSta:nAt,7] }
	
	oBrowseSta:AddColumn(TcColumn():New(STR0045,nil,; //"Status do Processo"
	            nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[7]:BDATA     := { || aRestTot[oBrowseSta:nAt,9] }
	
	oBrowseSta:AddColumn(TcColumn():New(STR0038,nil,; //"Aberta"
	            nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[8]:BDATA     := { || aRestTot[oBrowseSta:nAt,3] }
	
	oBrowseSta:AddColumn(TcColumn():New("N.o Guia",nil,; //"Eventos Lidos"
	            nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.T.,nil))
	            oBrowseSta:ACOLUMNS[9]:BDATA     := { || AllTrim(Str(aRestTot[oBrowseSta:nAt,4],10)) }
	
	oBrowseSta:SetArray(aRestTot)
	
	oTimer 	:= TTimer():New( 2000 ,{ || StatusFstProc(aThreads,aRestTot,.T.,oBrowseSta,oDlg,oSay,cHoraIniT,"1") },oDlg)	
	oTimer:Activate()
	//Atualização de 10 em 10 segundos do status do processamento....
	
	   //Se em 10 minutos nao houver uma resposta da theard e encarado como time-out
	//   oTimeOut := TTimer():New( 3600000 ,{ || StatusProc(aThreads,aRestTot,.T.,oBrowseSta,oDlg,oSay,cHoraIniT,"2") },oDlg)	
	//   oTimeOut:Activate()
	   //5 minutos para identificar se a thread esta executando ou nao...
	   
	   
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnChoiceBar(oDlg,{ || TestaFecha(oDlg,aThreads) },{|| TestaFecha(oDlg,aThreads) },.F.)
	
Else
	MsgInfo("Essa PEG já se encontra com a mudança de fase executada ou Bloqueadas.  Favor Verificar o Status.")
Endif

ClearGlbValue("__xRetPeri") // Limpado Variavel Global utilizado em Job


Return nil



//-------------------------------------------------------------------------------
/*/{Protheus.doc} ProcMudaFas
Executa os StartJob da mudança de fase
        
@author 	Totvs Team
@since 		25/05/2017
@version 	P11

@return		Nil	
/*/ 
//-------------------------------------------------------------------------------
Static Function ProcMudaFas(cEmpAnt,cFilAnt,aThreads,lJob,nQtd,nTotReg,nTipo,cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte,lHdlThread, cLockThread, cLock, lHdl)

	UnLockByName( cLockThread,.T.,.T. )
	
	StartJob("PLSFASTBATH",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,lJob,nQtd,nTotReg,nTipo,@cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte, cLockThread, cLock, lHdl)
	
	
	PlSemafCtrl( cLockThread, .T., lHdl )
	

Return Nil




//-------------------------------------------------------------------------------
/*/{Protheus.doc} PlSemafCtrl
Cria semaforo
        
@author 	Totvs Team
@since 		25/05/2017
@version 	P11

@return		Nil	
/*/ 
//-------------------------------------------------------------------------------
Static Function PlSemafCtrl( cLock, lLibera, lHdl, lAberto )

default lLibera := .F.

makeDir(GetPathSemaforo())

if ( lLibera )
	UnLockByName(cLock,.T.,.T.)
else
	lHdl := LockByName(cLock,.T.,.T.)
endif

return lHdl
