#INCLUDE "plsr606.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()
static lautoSt := .F.
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSR606  ?Autor ?Guilherme Brunoro      ?Data ?10.05.02 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao ?Lista Rede de Atendimento                                  낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇쿞intaxe   ?PLSR606                                                    낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇?Uso      ?Advanced Protheus                                          낢굇
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇?Alteracoes desde sua construcao inicial                               낢굇
굇쳐컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇?Data     ?BOPS ?Programador ?Breve Descricao                       낢굇
굇쳐컴컴컴컴컵컴컴컴탠컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇읕컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define nome da funcao                                                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Function PLSR606(lAuto)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis padroes para todos os relatorios...                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
PRIVATE nQtdLin     := 60     
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cTitulo     := STR0001  //"Relatorio do cadastro da Rede de Atendimento"
PRIVATE cDesc1      := STR0002 //"Este relatorio ira emitir os dados cadastrais da"
PRIVATE cDesc2      := STR0003  //"Rede de Atendimento"
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BAU"
PRIVATE cPerg       := "PLR606"
PRIVATE cRel        := "PLSR606"
PRIVATE nli         := 01   
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {STR0004,STR0005}  //"Codigo"###"Nome"
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "" 
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 01 
PRIVATE aLinha      := {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Dados do parametro...                                                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
PRIVATE cRedDe   := mv_par01 // Codigo da Rede de atendimento de
PRIVATE cRedAte  := mv_par02 // Codigo da Rede de atendimento ate
PRIVATE nAtivo   := mv_par03 // Somente ativos (Sim;Nao;Ambos)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Testa ambiente do relatorio somente top...                               ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Default lAuto := .F.

lautoSt := lAuto

If !lAuto .AND. ! PLSRelTop()
   Return
Endif    
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Chama SetPrint (padrao)                                                  ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if !lAuto
   cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif

aAlias := {"BAU", "SXA", "SX3"}
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
cRedDe   := mv_par01
cRedAte  := mv_par02
nAtivo   := mv_par03
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Configura impressora (padrao)                                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lAuto
   SetDefault(aReturn,cAlias) 
endIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Emite relat줿io                                                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lAuto
   MsAguarde({|| R606Imp() }, cTitulo, "", .T.)
else
   R606Imp()
endIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fim da rotina                                                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컴쩡컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿛rograma   ?R606Imp  ?Autor ?Guilherme Brunoro     ?Data ?10.05.02 낢?
굇쳐컴컴컴컴컴탠컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escricao  ?Imprime detalhe do relatorio...                            낢?
굇읕컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
/*/
Static Function R606Imp()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis...                                                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cSQL
LOCAL nOrdSel  := aReturn[8] 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Cadastro da Rede de Atendimento...                                       ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cBAUName := RetSQLName("BAU")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis de trabalho...                                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cCodRed                
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
If !lAutoSt
   MsProcTxt(PLSTR0001)
endIf 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Faz filtro no arquivo...                                                 ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cSQL := "SELECT * "
cSQL += "FROM "+cBAUName+" "
cSQL += "WHERE "+cBAUName+".D_E_L_E_T_ = '' AND "
cSQL += "BAU_FILIAL = '"+xFilial("BAU")+"'  AND "
cSQL += "BAU_CODIGO >= '"+cRedDe+"' AND BAU_CODIGO <= '"+cRedAte+"' "
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?De acordo com parametro mv_par03 : bloqueado ou nao                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If      nAtivo == 1 //ativo
        cSQL += " AND BAU_CODBLO = '' " 
ElseIf  nAtivo == 2 //bloqueado      
        cSQL += " AND BAU_CODBLO <> '' "
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
        cSQL += "ORDER BY BAU_CODIGO"
ElseIf  nOrdSel == 2       
        cSQL += "ORDER BY BAU_NOME"
Endif

PLSQuery(cSQL,"BAUTRB")
BAUTRB->(DbGotop())
cCodRed := BAUTRB->BAU_CODIGO 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime cabecalho...                                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
R606Cabec()      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Inicio da impressao dos detalhes...                                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
While ! BAUTRB->(Eof())
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Exibe mensagem...                                                  ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If !lAutoSt
         MsProcTXT(STR0006+objCENFUNLGP:verCamNPR("BAU_CODIGO",BAUTRB->BAU_CODIGO)+"...") //"Imprimindo "
      endIf
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Verifica se foi abortada a impressao...                            ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         nLi ++
         @ nLi, nColuna pSay PLSTR0002
         Exit
      Endif                       
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Imprime grupo...                                                   ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      @ nLi, nColuna pSay objCENFUNLGP:verCamNPR("BAU_CODIGO",BAUTRB->BAU_CODIGO)+" - "+objCENFUNLGP:verCamNPR("BAU_NOME",BAUTRB->BAU_NOME)
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?verifica proxima pagina...                                         ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If nLi > nQtdLin
         R606Cabec()
      Endif 
      While cCodRed == BAUTRB->BAU_CODIGO 
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
            //?Imprime BAU - Rede de Atendimento...                               ?
            //?Posiciono no arquivo SXA (Folders)...                              ?
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
            SXA->(DbSetOrder(01))//ALIAS+ORDEM
            If SXA->(Dbseek("BAU"))
               While ! SXA->(Eof()) .And. SXA->XA_ALIAS == cAlias
                     nLi++
                     @ ++nLi, nColuna pSay objCENFUNLGP:verCamNPR("XA_DESCRIC",SXA->XA_DESCRIC)
                     @ ++nLi, nColuna pSay Replicate("-",131)
                     lAux    := .T.
                     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                     //?verifica proxima pagina...                                         ?
                     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                     If nLi > nQtdLin
                        R606Cabec()
                     Endif 
                     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                     //?Posiciono no arquivo SX3 (Dicionario)...                           ?
                     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                     SX3->(DbSetOrder(04))//ALIAS+FOLDER
                     If SX3->(Dbseek("BAU"+SXA->XA_ORDEM))
                        While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias .And. SX3->X3_FOLDER == SXA->XA_ORDEM
                                If ! X3Uso(SX3->X3_USADO)
                                   SX3->(DbSkip())
                                   Loop
                                Endif
                                cCampX3 := SX3->X3_CAMPO
                                cCampCb := cCampX3
                                cCampX3 := "BAUTRB->"+cCampX3
                                cTypeX3 := SX3->X3_TIPO
                           		If SX3->X3_CONTEXT == "V"
                                   // Chumbei ...Isso eh provisorio, eh so para controlar os campos virtuais
                                   If cCampX3 == "BAUTRB->BAU_DESSIG" 
                                      cContX3 := Posicione("BAH",1,xFilial("BAH")+BAUTRB->BAU_SIGLCR,"BAH_DESCRI")
                                   ElseIf cCampX3 == "BAUTRB->BAU_DESSI2"
                                      cContX3 := Posicione("BAH",1,xFilial("BAH")+BAUTRB->BAU_SIGCR2,"BAH_DESCRI")
                                   ElseIf cCampX3 == "BAUTRB->BAU_CONSEN"
                                      cContX3 := " "
                                   ElseIf cCampX3 == "BAUTRB->BAU_NOMSA2"
                                      cContX3 := Posicione("SA2",1,xFilial("SA2")+BAUTRB->(BAU_CODSA2+BAU_LOJSA2),"A2_NOME")
                                   ElseIf cCampX3 == "BAUTRB->BAU_DESMUN"
                                      cContX3 := Posicione("BID",1,xFilial("BID")+BAU->BAU_MUN,"BID_DESCRI")
                                   ElseIf cCampX3 == "BAUTRB->BAU_DESMUN"
                                      cContX3 := Posicione("BID",1,xFilial("BID")+BAU->BAU_MUN,"BID_DESCRI")
                                   ElseIf cCampX3 == "BAUTRB->BAU_BANCO" .Or. cCampX3 == "BAUTRB->BAU_AGENCI" .Or.; 
                                          cCampX3 == "BAUTRB->BAU_CONTA" .Or. cCampX3 == "BAUTRB->BAU_NATURE"
                                      cContX3 := " "
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
                                      @ ++nLi, nColuna pSay X3TITULO()+": "+ objCENFUNLGP:verCamNPR(AllTrim(cCampCb),cResuBx)
                                      SX3->(DbSetOrder(04))//ALIAS+FOLDER
                                   Else  
                                      @ ++nLi, nColuna pSay X3TITULO()+": "+ objCENFUNLGP:verCamNPR(AllTrim(cCampCb),Subs(cContX3,1,40))
                                   Endif
                                   lAux    := .F.
                                Else 
                                   If ! Empty(SX3->X3_CBOX)
                                      cCampBx := "X3COMBO('"+cCampCb+"',"+cCampX3+")"
                                      cResuBx := &cCampBx
                                      @ nLi, 67 pSay X3TITULO()+": "+ objCENFUNLGP:verCamNPR(AllTrim(cCampCb),cResuBx)
                                      SX3->(DbSetOrder(04))//ALIAS+FOLDER
                                   Else
                                      @ nLi, 67 pSay X3TITULO()+": "+ objCENFUNLGP:verCamNPR(AllTrim(cCampCb),Subs(cContX3,1,40))
                                   Endif
                                   lAux    := .T.
                                Endif
                                //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                                //?verifica proxima pagina...                                         ?
                                //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                                If nLi > nQtdLin
                                   R606Cabec()
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
            BAUTRB->(DbSkip())
      Enddo
      nLi++
      cCodRed := BAUTRB->BAU_CODIGO 
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Imprime cabecalho...                                                     ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      R606Cabec()      
Enddo
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime rodape do relatorio...                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Roda(0,space(10),cTamanho)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fecha arquivo...                                                   ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BAUTRB->(DbCloseArea())
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
굇쿛rograma   ?R606Cabec ?Autor ?Guilherme Brunoro    ?Data ?10.05.02 낢?
굇쳐컴컴컴컴컴탠컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escricao  ?Imprime Cabecalho                                          낢?
굇읕컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
/*/
Static Function R606Cabec()      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime cabecalho...                                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nLi ++
If !lAutoSt
   nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
endIf
nLi ++
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fim da Rotina...                                                         ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Return                                                                       
