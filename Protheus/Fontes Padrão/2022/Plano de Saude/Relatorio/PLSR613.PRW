
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSR613  ?Autor ?Guilherme Brunoro      ?Data ?04.11.02 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao ?Lista Usuarios                                             낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇쿞intaxe   ?PLSR613                                                    낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇?Uso      ?Advanced Protheus                                          낢굇
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇?Alteracoes desde sua construcao inicial                               낢굇
굇쳐컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇?Data     ?BOPS ?Programador ?Breve Descricao                       낢굇
굇쳐컴컴컴컴컵컴컴컴탠컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇?6/01/2003?     ?Brunoro     ?controle de campos virtuais           낢굇
굇읕컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define nome da funcao                                                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Function PLSR613(lAuto)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis padroes para todos os relatorios...                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Default lAuto := .F.

PRIVATE nQtdLin     := 64    
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cTitulo     := "Relatorio do cadastro de Usuarios" 
PRIVATE cDesc1      := "Este relatorio ira emitir os dados cadastrais ds"
PRIVATE cDesc2      := "Usuarios" 
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE cPerg       := "PLR613"
PRIVATE cRel        := "PLSR613"
PRIVATE nli         := 01   
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {"Codigo","Nome"} 
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "" 
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 01 
PRIVATE aLinha      := {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Dados do parametro...                                                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
PRIVATE cUsuDe   := mv_par01 // Usuario de
PRIVATE cUsuAte  := mv_par02 // Usuario ate
PRIVATE nAtivo   := mv_par03 // Somente ativos (Sim;Nao;Ambos)
PRIVATE cFolder  := mv_par04 // Folders a nao imprimir
PRIVATE cMatAnD	 
PRIVATE cMatAnA  
PRIVATE lImpMaA  
CriaSX1()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Testa ambiente do relatorio somente top...                               ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If ! PLSRelTop()
   Return
Endif    

lAutoSt := lAuto

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Chama SetPrint (padrao)                                                  ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if !lAuto
   cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
	aAlias := {"BA1","BG9","BQC","SXA"}
	objCENFUNLGP:setAlias(aAlias)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Verifica se foi cancelada a operacao (padrao)                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lAuto .AND. nLastKey  == 27 
   Return
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Acessa parametros do relatorio...                                        ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte(cPerg,.F.)
cUsuDe   := mv_par01
cUsuAte  := mv_par02
nAtivo   := mv_par03
cFolder  := mv_par04           
cMatAnD	 := mv_par05
cMatAnA  := mv_par06
lImpMaA  := If(mv_par07==1,.t.,.f.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Configura impressora (padrao)                                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if !lAuto
   SetDefault(aReturn,cAlias) 
endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Emite relat줿io                                                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if !lAuto
   MsAguarde({|| R613Imp() }, cTitulo, "", .T.)
else
   R613Imp()
endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fim da rotina                                                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컴쩡컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿛rograma   ?R613Imp  ?Autor ?Guilherme Brunoro     ?Data ?04.11.02 낢?
굇쳐컴컴컴컴컴탠컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escricao  ?Imprime detalhe do relatorio...                            낢?
굇읕컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
/*/
Static Function R613Imp()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis...                                                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cSQL
LOCAL nOrdSel  := aReturn[8] 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Cadastro da Rede de Atendimento...                                       ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cBA1Name := RetSQLName("BA1")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis de trabalho...                                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cCodUsu
LOCAL cCampX3
LOCAL cCampCb
LOCAL cContX3
LOCAL cTypeX3   
LOCAL cArqOrd
LOCAL cArqSek      
LOCAL cSx3Sek                        
LOCAL cCampBx
LOCAL cResuBx
LOCAL lAux 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Exibe mensagem...                                                        ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if !lAutoSt
   MsProcTxt(PLSTR0001) 
endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Faz filtro no arquivo...                                                 ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cSQL := "SELECT * "
cSQL += "FROM "+cBA1Name+" "
cSQL += "WHERE "+cBA1Name+".D_E_L_E_T_ = '' AND "
cSQL += "BA1_FILIAL = '"+xFilial("BA1")+"'  AND "
cSQL += "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG >= '"+cUsuDe+"' AND BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG <= '"+cUsuAte+"' "
If !Empty(cMatAnA)
	cSQL += "AND BA1_MATANT >= '"+cMatAnD+"' AND BA1_MATANT <= '"+cMatAnA+"' "
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?De acordo com parametro mv_par03 : bloqueado ou nao                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If      nAtivo == 1 //ativo
        cSQL += " AND BA1_MOTBLO = '' " 
ElseIf  nAtivo == 2 //bloqueado      
        cSQL += " AND BA1_MOTBLO <> '' "
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Se houver filtro executa parse para converter expressoes adv para SQL    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If ! Empty(aReturn[7])
   cSQL += " AND (" + PLSParSQL(aReturn[7])+" ) "
Endif   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?De acordo com a ordem....                                                ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If      nOrdSel == 1
        cSQL += "ORDER BY BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG"
ElseIf  nOrdSel == 2       
        cSQL += "ORDER BY BA1_NOMUSR"
Endif

PLSQuery(cSQL,"BA1TRB")
BA1TRB->(DbGotop())
cCodUsu := BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime cabecalho...                                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
R613Cabec()      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Inicio da impressao dos detalhes...                                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
While ! BA1TRB->(Eof())
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Exibe mensagem...                                                  ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      if !lAutoSt
         MsProcTXT("Imprimindo "+objCENFUNLGP:verCamNPR("BA1_CODINT",BA1TRB->BA1_CODINT)+;
								objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+;
								objCENFUNLGP:verCamNPR("BA1_MATRIC",BA1TRB->BA1_MATRIC)+;
								objCENFUNLGP:verCamNPR("BA1_TIPREG",BA1TRB->BA1_TIPREG)+"...")
      endif
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Verifica se foi abortada a impressao...                            ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         nLi ++
         @ nLi, nColuna pSay PLSTR0002
         Exit
      Endif                       
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Posiciono no Grupo-Empresa...                                            ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      BG9->(DbSetOrder(1))// BG9_CODINT + BG9_CODIGO + BG9_TIPO
      BG9->(DbSeek(xFilial("BG9")+BA1TRB->(BA1_CODINT+BA1_CODEMP)))
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Posiciono no Contrato...                                                 ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      BT5->(DbSetOrder(1))// BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
      BT5->(DbSeek(xFilial("BT5")+BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Posiciono no Sub-Contrato...                                             ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      BQC->(DbSetOrder(1))// BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
      BQC->(DbSeek(xFilial("BQC")+BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Imprime grupo...                                                   ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If !lImpMaA
	      @ nLi, nColuna pSay "Usuario     : "+;
                              objCENFUNLGP:verCamNPR("BA1_CODINT",BA1TRB->BA1_CODINT)+"-"+;
                              objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+"-"+;
                              objCENFUNLGP:verCamNPR("BA1_MATRIC",BA1TRB->BA1_MATRIC)+"-"+;
                              objCENFUNLGP:verCamNPR("BA1_TIPREG",BA1TRB->BA1_TIPREG)+" - Nome: "+;
                              objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1TRB->BA1_NOMUSR)
	  Else
	      @ nLi, nColuna pSay "Usuario     : "+;
                              objCENFUNLGP:verCamNPR("BA1_MATANT",BA1TRB->BA1_MATANT)+" - Nome: "+;
                              objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1TRB->BA1_NOMUSR)
	  Endif
      @ ++nLi, nColuna pSay "Grup/Empresa: "+;
                              objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+"-"+;
                              objCENFUNLGP:verCamNPR("BG9_DESCRI",Substr(BG9->BG9_DESCRI,1,30))
      @ ++nLi, nColuna pSay "Contrato    : "+;
                              objCENFUNLGP:verCamNPR("BA1_CONEMP",BA1TRB->BA1_CONEMP)+" - Versao: "+;
                              objCENFUNLGP:verCamNPR("BA1_VERCON",BA1TRB->BA1_VERCON)+" - "+;
                              Posicione("BII",1,xFilial("BII")+BT5->BT5_TIPCON,"BII_DESCRI")
      @ ++nLi, nColuna pSay "Sub-Contrato: "+;
                              objCENFUNLGP:verCamNPR("BA1_SUBCON",BA1TRB->BA1_SUBCON)+"    - Versao: "+;
                              objCENFUNLGP:verCamNPR("BA1_VERSUB",BA1TRB->BA1_VERSUB)+" - "+;
                              objCENFUNLGP:verCamNPR("BQC_DESCRI",BQC->BQC_DESCRI)
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?verifica proxima pagina...                                         ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If nLi > nQtdLin
         R613Cabec()
      Endif 
      While cCodUsu == BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
            //?Imprime BA1 - Usuarios...                                          ?
            //?Posiciono no arquivo SXA (Folders)...                              ?
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
            SXA->(DbSetOrder(01))//ALIAS+ORDEM
            If SXA->(Dbseek("BA1"))
               While ! SXA->(Eof()) .And. SXA->XA_ALIAS == cAlias
                    If SXA->XA_ORDEM $ cFolder
                       //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                       //?Acessa proximo registro...                                         ?
                       //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                       SXA->(DbSkip())
                       Loop
                     Endif
                     nLi++
                     @ ++nLi, nColuna pSay objCENFUNLGP:verCamNPR("XA_DESCRIC",SXA->XA_DESCRIC)
                     //@ ++nLi, nColuna pSay Replicate("-",131)
                     lAux    := .T.
                     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                     //?verifica proxima pagina...                                         ?
                     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                     If nLi > nQtdLin
                        R613Cabec()
                     Endif 
                     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                     //?Posiciono no arquivo SX3 (Dicionario)...                           ?
                     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                     SX3->(DbSetOrder(04))//ALIAS+FOLDER
                     If SX3->(Dbseek("BA1"+SXA->XA_ORDEM))
                        While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias .And. SX3->X3_FOLDER == SXA->XA_ORDEM
                            //    If SX3->X3_CONTEXT == "V" .Or. SX3->X3_VISUAL == "V" .Or. ! X3Uso(SX3->X3_USADO)
                                If ! X3Uso(SX3->X3_USADO)
                                   SX3->(DbSkip())
                                   Loop
                                Endif
                                cCampX3 := SX3->X3_CAMPO
                                cCampCb := cCampX3
                                cCampX3 := "BA1TRB->"+cCampX3
                                cTypeX3 := SX3->X3_TIPO
                                If SX3->X3_CONTEXT == "V"
                               	   // Chumbei
                                   If cCampX3 == "BA1TRB->BA1_DESUSU"
                                      cContX3 := Posicione("BIH",1,xFilial("BIH")+BA1TRB->BA1_TIPUSU,"BIH_DESCRI")
                                   Elseif  cCampX3 == "BA1TRB->BA1_DESGRA"
                                       cContX3 := Posicione("BRP",1,xFilial("BRP")+BA1TRB->BA1_GRAUPA,"BRP_DESCRI")
                                   Elseif  cCampX3 == "BA1TRB->BA1_DESCIV"
                                       cContX3 := Posicione("SX5",1,xFilial("SX5")+"33"+BA1TRB->BA1_ESTCIV,"X5_DESCRI")
                                   Elseif  cCampX3 == "BA1TRB->BA1_IDADE "
                                       cContX3 := Alltrim(Str(Calc_Idade(dDataBase,BA1TRB->BA1_DATNAS)))
                                   Elseif  cCampX3 == "BA1TRB->BA1_VLRIND"
                                       cContX3 := " "
                                   Elseif  cCampX3 == "BA1TRB->BA1_MATUSU"
                                       cContX3 := " "
                                   Elseif  cCampX3 == "BA1TRB->BA1_DESBLO"
                                       cContX3 := " "
                                   Elseif  cCampX3 == "BA1TRB->BA1_DESCFU"
                                       cContX3 := Posicione("SRJ",1,xFilial("SRJ")+BA1TRB->BA1_CODFUN,"RJ_DESC")
                                   Elseif  cCampX3 == "BA1TRB->BA1_DESSET"
                                       cContX3 := Posicione("BLM",1,xFilial("BLM")+BA1TRB->BA1_CODSET,"BLM_DESSET")
                                   Elseif  cCampX3 == "BA1TRB->BA1_DESPRF"
                                       cContX3 := Posicione("BCX",1,xFilial("BCX")+BA1TRB->BA1_CODPRF,"BCX_DESCRI")
                                   Else                                     
                                       cContX3 := " "
                                   Endif
                                Else
                                   If cTypeX3 == "N" 
			                           cContX3 := Alltrim(Str(&cCampX3))
                    	           Elseif cTypeX3 == "D"
                   		               cContX3 := Dtoc(&cCampX3)
                                   Else   
                                       cContX3 := &cCampX3        
                                   Endif
                                Endif                  
                                If lAux
                                   If ! Empty(SX3->X3_CBOX)
                                      cCampBx := "X3COMBO('"+cCampCb+"',"+cCampX3+")"
                                      cResuBx := &cCampBx
                                      @ ++nLi, nColuna pSay X3TITULO()+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),cResuBx)
                                      SX3->(DbSetOrder(04))//ALIAS+FOLDER
                                   Else  
                                      @ ++nLi, nColuna pSay X3TITULO()+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),Subs(cContX3,1,40))
                                   Endif
                                   lAux    := .F.
                                Else 
                                   If ! Empty(SX3->X3_CBOX)
                                      cCampBx := "X3COMBO('"+cCampCb+"',"+cCampX3+")"
                                      cResuBx := &cCampBx
                                      @ nLi, 67 pSay X3TITULO()+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),cResuBx)
                                      SX3->(DbSetOrder(04))//ALIAS+FOLDER
                                   Else
                                      @ nLi, 67 pSay X3TITULO()+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),Subs(cContX3,1,40))
                                   Endif
                                   lAux    := .T.
                                Endif
                                //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                                //?verifica proxima pagina...                                         ?
                                //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                                If nLi > nQtdLin
                                   R613Cabec()
                                Endif 
                        SX3->(DbSkip())
                        Enddo
                     Endif         
               SXA->(DbSkip())
               Enddo
            Endif
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
            //?Acessa proximo registro...                                         ?
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
            BA1TRB->(DbSkip())
      Enddo
      nLi++
      cCodUsu := BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Imprime cabecalho...                                                     ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      R613Cabec()      
Enddo
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime rodape do relatorio...                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if !lAutoSt
   Roda(0,space(10),cTamanho)
endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fecha arquivo...                                                   ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BA1TRB->(DbCloseArea())
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Libera impressao                                                         ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lAutoSt .AND. aReturn[5] == 1 
    Set Printer To
    Ourspool(cRel)
End
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fim do Relat줿io                                                         ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컴쩡컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿛rograma   ?R613Cabec ?Autor ?Guilherme Brunoro    ?Data ?04.11.02 낢?
굇쳐컴컴컴컴컴탠컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escricao  ?Imprime Cabecalho                                          낢?
굇읕컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
/*/
Static Function R613Cabec()      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime cabecalho...                                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nLi ++
if !lAutoSt
   nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
endif
nLi ++
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fim da Rotina...                                                         ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

Return          

Static Function CriaSX1()

Local aRegs	:=	{}

aadd(aRegs,{cPerg,"05","Matr. Antiga de ?            ","","","mv_ch5","C", 17,0,0,"G",""           ,"mv_par5",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","",""})
aadd(aRegs,{cPerg,"06","Matr. Antiga ate ?           ","","","mv_ch6","C", 17,0,0,"G",""           ,"mv_par6",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","",""})
aadd(aRegs,{cPerg,"07","Imp. Matr. Antiga?           ","","","mv_ch7","N", 1,0,0,"C",""           ,"mv_par7","Sim"         	,"","","","","Nao"            	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   ,""})

PlsVldPerg( aRegs )
    
Return                                                             
