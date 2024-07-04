#INCLUDE "PLSR612.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSR612  ?Autor ?Guilherme Brunoro      ?Data ?04.11.02 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao ?Lista Familias                                             낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙굇
굇쿞intaxe   ?PLSR612                                                    낢굇
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
Function PLSR612(lAuto)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis padroes para todos os relatorios...                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Default lAuto := .F.

PRIVATE nQtdLin     := 64     
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cTitulo     := STR0001  //"Relatorio do cadastro de Familias"
PRIVATE cDesc1      := STR0002 //"Este relatorio ira emitir os dados cadastrais das"
PRIVATE cDesc2      := STR0003  //"Familias"
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA3"
PRIVATE cPerg       := "PLR612"
PRIVATE cRel        := "PLSR612"
PRIVATE nli         := 01   
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {STR0004}  //"Codigo"
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "" 
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 01 
PRIVATE aLinha      := {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Dados do parametro...                                                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
PRIVATE cFamDe   := mv_par01 // Codigo da Familia de
PRIVATE cFamAte  := mv_par02 // Codigo da Familia ate
PRIVATE nAtivo   := mv_par03 // Somente ativos (Sim;Nao;Ambos)
PRIVATE cFolder  := mv_par04 // Folders a nao imprimir
PRIVATE cMatAnD	 
PRIVATE cMatAnA                           
PRIVATE lImpMaA  

lAutoSt := lAuto                          

CriaSX1()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Testa ambiente do relatorio somente top...                               ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If ! PLSRelTop()
   Return
Endif    
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Chama SetPrint (padrao)                                                  ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if !lAuto
   cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
   aAlias := {"BA3","BA1","BG9","BII","BQC"}
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

cFamDe   := mv_par01
cFamAte  := mv_par02
nAtivo   := mv_par03
cFolder  := mv_par04
cMatAnD	 := mv_par05
cMatAnA  := mv_par06
lImpMaA  := If(mv_par07==1,.t.,.f.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Configura impressora (padrao)                                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lAuto
   SetDefault(aReturn,cAlias) 
endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Emite relat줿io                                                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lAuto
   MsAguarde({|| R612Imp() }, cTitulo, "", .T.)
else
   R612Imp()
endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fim da rotina                                                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컴쩡컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿛rograma   ?R612Imp  ?Autor ?Guilherme Brunoro     ?Data ?04.11.02 낢?
굇쳐컴컴컴컴컴탠컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escricao  ?Imprime detalhe do relatorio...                            낢?
굇읕컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
/*/
Static Function R612Imp()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis...                                                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cSQL
LOCAL nOrdSel  := aReturn[8] 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Cadastro da Rede de Atendimento...                                       ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cBA3Name := RetSQLName("BA3")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define variaveis de trabalho...                                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cCodFam
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
LOCAL cMvPLCDTGP := GetNewPar("MV_PLTRTIT","00")  
LOCAL aTitRel := {STR0015,STR0016,STR0022,STR0017,STR0018,STR0019,STR0020,STR0021}
LOCAL nTexto := 0
LOCAL nx:= 0
LOCAL aHeadRG :={}
LOCAL aColRg  := {}
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
cSQL += "FROM "+cBA3Name+" "
cSQL += "WHERE "+cBA3Name+".D_E_L_E_T_ = '' AND "
cSQL += "BA3_FILIAL = '"+xFilial("BA3")+"'  AND "
cSQL += "BA3_CODINT+BA3_CODEMP+BA3_MATRIC >= '"+cFamDe+"' AND BA3_CODINT+BA3_CODEMP+BA3_MATRIC <= '"+cFamAte+"' "
If !Empty(cMatAnA)
	cSQL += "AND BA3_MATANT >= '"+cMatAnD+"' AND BA3_MATANT <= '"+cMatAnA+"' "
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?De acordo com parametro mv_par03 : bloqueado ou nao                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If      nAtivo == 1 //ativo
        cSQL += " AND BA3_MOTBLO = '' " 
ElseIf  nAtivo == 2 //bloqueado      
        cSQL += " AND BA3_MOTBLO <> '' "
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
        cSQL += "ORDER BY BA3_CODINT,BA3_CODEMP,BA3_MATRIC"
Endif

PLSQuery(cSQL,"BA3TRB")
BA3TRB->(DbGotop())
cCodFam := BA3TRB->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime cabecalho...                                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
R612Cabec()      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Inicio da impressao dos detalhes...                                      ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
While ! BA3TRB->(Eof())
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Exibe mensagem...                                                  ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If !lAutoSt
         MsProcTXT(STR0005+" "+;
						objCENFUNLGP:verCamNPR("BA3_CODINT",BA3TRB->BA3_CODINT)+;
						objCENFUNLGP:verCamNPR("BA3_CODEMP",BA3TRB->BA3_CODEMP)+;
						objCENFUNLGP:verCamNPR("BA3_MATRIC",BA3TRB->BA3_MATRIC)+"...") //"Imprimindo"
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
      //?Posiciono no Titular...                                                  ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      BA1->(DbSetOrder(2))// CODINT+CODEMP+MATRIC+TIPREG
      If !lAutoSt .AND. ! BA1->(DbSeek(xFilial("BA1")+BA3TRB->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cMvPLCDTGP))
         MsgStop(STR0006+": "+BA3TRB->BA3_CODINT+"-"+BA3TRB->BA3_CODEMP+"-"+BA3TRB->BA3_MATRIC+"-00. "+STR0007) //"Nao existe Titular"###"Verifique."
      Endif   
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Posiciono no Grupo-Empresa...                                            ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      BG9->(DbSetOrder(1))// BG9_CODINT + BG9_CODIGO + BG9_TIPO
      BG9->(DbSeek(xFilial("BG9")+BA3TRB->(BA3_CODINT+BA3_CODEMP)))
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Posiciono no Contrato...                                                 ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      BT5->(DbSetOrder(1))// BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
      BT5->(DbSeek(xFilial("BT5")+BA3TRB->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Posiciono no Sub-Contrato...                                             ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      BQC->(DbSetOrder(1))// BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
      BQC->(DbSeek(xFilial("BQC")+BA3TRB->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Imprime grupo...                                                   ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If !lImpMaA
	      @ nLi, nColuna pSay STR0008+"     : "+;
                              objCENFUNLGP:verCamNPR("BA3_CODINT",BA3TRB->BA3_CODINT)+"-"+;
                              objCENFUNLGP:verCamNPR("BA3_CODEMP",BA3TRB->BA3_CODEMP)+"-"+;
                              objCENFUNLGP:verCamNPR("BA3_MATRIC",BA3TRB->BA3_MATRIC)+; //"Familia"
	                           " - "+STR0009+": "+;
                              objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR) //"Titular"
      Else
          @ nLi, nColuna pSay STR0008+"     : "+;
                              objCENFUNLGP:verCamNPR("BA3_MATANT",BA3TRB->BA3_MATANT)+; //"Familia"
	                           " - "+STR0009+": "+;
                              objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR) //"Titular"
      Endif
      @ ++nLi, nColuna pSay STR0010+"/"+STR0011+": "+;
                              objCENFUNLGP:verCamNPR("BA3_CODEMP",BA3TRB->BA3_CODEMP)+"-"+;
                              objCENFUNLGP:verCamNPR("BG9_DESCRI",Substr(BG9->BG9_DESCRI,1,30)) //"Grup"###"Empresa"
      @ ++nLi, nColuna pSay STR0012+"    : "+;
                              objCENFUNLGP:verCamNPR("BA3_CONEMP",BA3TRB->BA3_CONEMP)+" - "+STR0013+": "+;
                              objCENFUNLGP:verCamNPR("BA3_VERCON",BA3TRB->BA3_VERCON)+" - "+; //"Contrato"###"Versao"
                              objCENFUNLGP:verCamNPR("BII_DESCRI",Posicione("BII",1,xFilial("BII")+BT5->BT5_TIPCON,"BII_DESCRI"))
      @ ++nLi, nColuna pSay STR0014+": "+;
                              objCENFUNLGP:verCamNPR("BA3_SUBCON",BA3TRB->BA3_SUBCON)+"    - "+STR0013+": "+; //"Sub-Contrato"###"Versao"
                              objCENFUNLGP:verCamNPR("BA3_VERSUB",BA3TRB->BA3_VERSUB)+" - "+;
                              objCENFUNLGP:verCamNPR("BQC_DESCRI",BQC->BQC_DESCRI)
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?verifica proxima pagina...                                         ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      If nLi > nQtdLin
         R612Cabec()
      Endif 
      While cCodFam == BA3TRB->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
             //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
               //?Imprime BA3 - Familias...                                          ?
               FillGetDados(2,"BA3",1,,,,,,,,{||.T.},.T.,@aHeadRG,@aColRg)	

               While  Len(aTitRel) > nTexto //! SXA->(Eof()) .And. SXA->XA_ALIAS == cAlias
                     nTexto++

                     aCampoFld:=FolderSX2(nTexto)

                     If Len(aCampoFld)= 0
                        Loop
                     Endif

                     nLi++
                     @ ++nLi, nColuna pSay aTitRel[nTexto]
                     //@ ++nLi, nColuna pSay Replicate("-",131)
                     lAux    := .T.
                     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                     //?verifica proxima pagina...                                         ?
                     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                     If nLi > nQtdLin
                        R612Cabec()
                     Endif 
                    
                     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                     //?Posiciono nos campos 
                     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                     //For nX:= 1 to Len(aHeadRG)
                     For nX:= 1 to Len(aCampoFld)

                        nPosCmp 	:= aScan(aHeadRG,{|x| Trim(x[2])==aCampoFld[nx,1]})

                        If nPosCmp = 0
                           Loop
                        Endif  
                        
                        cCampX3 := aHeadRG[nPosCmp,2]
                        cCampCb := cCampX3
                        cCampX3 := "BA3TRB->"+cCampX3
                        cTypeX3 := aHeadRG[nPosCmp,8]

                        If BA3TRB->(FieldPos(cCampCb)) = 0
                           Loop
                        Endif
                        If aHeadRG[nPosCmp,10] = "V"
                           // Chumbei
                           If cCampX3 == "BA3TRB->BA3_DEFOTX"
                            cContX3 := Posicione("BJ1",1,xFilial("BJ1")+BA3TRB->BA3_FORCTX,"BJ1_DESCRI")
                           Elseif  cCampX3 == "BA3TRB->BA3_DESTDE"
                              cContX3 := Posicione("BF8",1,xFilial("BF8")+BA3TRB->(BA3_CODINT+BA3_CODTDE),"BF8_DESCM")
                           Elseif  cCampX3 == "BA3TRB->BA3_DESTCO"
                              cContX3 := Posicione("BII",1,xFilial("BII")+BA3TRB->BA3_TIPCON,"BII_DESCRI")
                           Elseif  cCampX3 == "BA3TRB->BA3_DESSEG"
                              cContX3 := Posicione("BI6",1,xFilial("BI6")+BA3TRB->BA3_SEGPLA,"BI6_DESCRI")
                           Elseif  cCampX3 == "BA3TRB->BA3_NOMOPE"
                              cContX3 := " "
                           Elseif  cCampX3 == "BA3TRB->BA3_DESINT"
                              cContX3 := " "
                           Elseif  cCampX3 == "BA3TRB->BA3_DESEMP"
                              cContX3 := Posicione("BG9",1,xFilial("BG9")+BA3TRB->(BA3_CODINT+BA3_CODEMP),"BG9_DESCRI")
                           Elseif  cCampX3 == "BA3TRB->BA3_DESPLA"
                              cContX3 := " "
                           Elseif  cCampX3 == "BA3TRB->BA3_DESFOR"
                              cContX3 := Posicione("BJ1",1,xFilial("BJ1")+BA3TRB->BA3_FORPAG,"BJ1_DESCRI")
                           Elseif  cCampX3 == "BA3TRB->BA3_NOMCLI"
                              cContX3 := Posicione("SA1",1,xFilial("SA1")+BA3TRB->BA3_CODCLI,"A1_NOME")
                           Elseif  cCampX3 == "BA3TRB->BA3_NOMFOR"
                              cContX3 := " "
                           Elseif  cCampX3 == "BA3TRB->BA3_AGNMFU"
                              cContX3 := Posicione("SRA",1,xFilial("SRA")+BA3->BA3_AGMTFU,"RA_NOME")
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
                           cCpoBox := "X3COMBO('"+cCampCb+"',"+cCampX3+")"
                           cResuBx := &cCpoBox
                           If ! Empty(cResuBx )
                              cCampBx := "X3COMBO('"+cCampCb+"',"+cCampX3+")"
                              cResuBx := &cCampBx
                              @ ++nLi, nColuna pSay aHeadRG[nPosCmp,1]+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),cResuBx)
                        Else  
                           @ ++nLi, nColuna pSay aHeadRG[nPosCmp,1]+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),Subs(cContX3,1,40))
                        Endif
                           lAux    := .F.
                        Else 
                           cCpoBox := "X3COMBO('"+cCampCb+"',"+cCampX3+")"
                           cResuBx := &cCpoBox
                           If ! Empty(cResuBx)
                              cCampBx := "X3COMBO('"+cCampCb+"',"+cCampX3+")"
                              cResuBx := &cCampBx
                              @ nLi, 67 pSay aHeadRG[nPosCmp,1]+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),cResuBx)
                              SX3->(DbSetOrder(04))//ALIAS+FOLDER
                           Else
                              @ nLi, 67 pSay aHeadRG[nPosCmp,1]+": "+objCENFUNLGP:verCamNPR(AllTrim(cCampCb),Subs(cContX3,1,40))
                           Endif
                           lAux    := .T.
                        Endif
                        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                        //?verifica proxima pagina...                                         ?
                        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                        If nLi > nQtdLin
                           R612Cabec()
                        Endif 

                     Next
                     
               Enddo
            //Endif
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
            //?Acessa proximo registro...                                         ?
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
            BA3TRB->(DbSkip())
      Enddo
      nLi++
      cCodFam := BA3TRB->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //?Imprime cabecalho...                                                     ?
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      R612Cabec()      
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
BA3TRB->(DbCloseArea())
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
굇쿛rograma   ?R612Cabec ?Autor ?Guilherme Brunoro    ?Data ?04.11.02 낢?
굇쳐컴컴컴컴컴탠컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escricao  ?Imprime Cabecalho                                          낢?
굇읕컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
/*/
Static Function R612Cabec()      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Imprime cabecalho...                                                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nLi ++
nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
nLi ++
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Fim da Rotina...                                                         ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Return                                                                       


Static Function CriaSX1()

Local aRegs	:=	{}

aadd(aRegs,{cPerg,"05","Matr. Antiga de ?            ","","","mv_ch5","C", 17,0,0,"G",""           ,"mv_par05",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","",""})
aadd(aRegs,{cPerg,"06","Matr. Antiga ate ?           ","","","mv_ch6","C", 17,0,0,"G",""           ,"mv_par06",""            	,"","","","",""               	,"","","","",""              ,"","","","",""       ,"","","","","","","","","",""})
aadd(aRegs,{cPerg,"07","Imp. Matr. Antiga?           ","","","mv_ch7","N", 1,0,0,"C",""           ,"mv_par07","Sim"         	,"","","","","Nao"            	,"","","","",""              ,"","","","",""       ,"","","","","","","","",""   ,""})

PlsVldPerg( aRegs )
    
Return


/*/

{Protheus.doc}
convDataStr
Verifica qual folfer esta o campo

@author PLS TEAM
@version 1.xx
@since 22/03/2019
@param nFolfer 	= Numero do folder que esta sendo impresso
@param cCampo 	= Qual e o campo que esta sendo impresso
@return lRet      = se o campo pertence ao folder que estasendo impresso

/*/
//------------------------------------------------------------------------------------------


Static Function FolderSX2(nFolder)


Local aCmpFld:= {}

If nFolder = 1
   aadd(aCmpFld,{"BA3_CODINT",1})
   aadd(aCmpFld,{"BA3_DESINT",1})
   aadd(aCmpFld,{"BA3_CODEMP",1})
   aadd(aCmpFld,{"BA3_DESEMP",1})
   aadd(aCmpFld,{"BA3_CONEMP",1})
   aadd(aCmpFld,{"BA3_VERCON",1})
   aadd(aCmpFld,{"BA3_SUBCON",1})
   aadd(aCmpFld,{"BA3_VERSUB",1})
   aadd(aCmpFld,{"BA3_DESSUB",1})
   aadd(aCmpFld,{"BA3_NUMCON",1})
   aadd(aCmpFld,{"BA3_MATRIC",1})
   aadd(aCmpFld,{"BA3_MATEMP",1})
   aadd(aCmpFld,{"BA3_MATANT",1})
   aadd(aCmpFld,{"BA3_HORACN",1})
   aadd(aCmpFld,{"BA3_DATBAS",1})
   aadd(aCmpFld,{"BA3_DATINC",1})
   aadd(aCmpFld,{"BA3_TIPOUS",1})
   aadd(aCmpFld,{"BA3_MOTBLO",1})
   aadd(aCmpFld,{"BA3_DATBLO",1})
   aadd(aCmpFld,{"BA3_AGMTFU",1})
   aadd(aCmpFld,{"BA3_AGNMFU",1})
   aadd(aCmpFld,{"BA3_VALSAL",1})
   aadd(aCmpFld,{"BA3_ROTSAL",1})
   aadd(aCmpFld,{"BA3_DESMUN",1})
   aadd(aCmpFld,{"BA3_RGIMP",1})
   aadd(aCmpFld,{"BA3_DEMITI",1})
   aadd(aCmpFld,{"BA3_DATDEM",1})
   aadd(aCmpFld,{"BA3_MOTDEM",1})
   aadd(aCmpFld,{"BA3_LIMATE",1})
   aadd(aCmpFld,{"BA3_VALANT",1})
   aadd(aCmpFld,{"BA3_LETANT",1})
   aadd(aCmpFld,{"BA3_DATALT",1})
   aadd(aCmpFld,{"BA3_MATFMB",1})
   aadd(aCmpFld,{"BA3_TRAORI",1})
   aadd(aCmpFld,{"BA3_TRADES",1})
   aadd(aCmpFld,{"BA3_VALID",1})
   aadd(aCmpFld,{"BA3_DESLIG",1})
   aadd(aCmpFld,{"BA3_DATDES",1})
   aadd(aCmpFld,{"BA3_LIMITE",1})
   aadd(aCmpFld,{"BA3_CONSID",1})
   aadd(aCmpFld,{"BA3_AGLUT",1})
   aadd(aCmpFld,{"BA3_TIPPGO",1})
   aadd(aCmpFld,{"BA3_UNDORG",1})

Endif

If nFolder = 2
   aadd(aCmpFld,{"BA3_CODPLA",2})
   aadd(aCmpFld,{"BA3_DESPLA",2})
   aadd(aCmpFld,{"BA3_VERSAO",2})
   aadd(aCmpFld,{"BA3_FORPAG",2})
   aadd(aCmpFld,{"BA3_DESFOR",2})
   aadd(aCmpFld,{"BA3_FORCTX",2})
   aadd(aCmpFld,{"BA3_DEFOTX",2})
   aadd(aCmpFld,{"BA3_TXUSU",2})
   aadd(aCmpFld,{"BA3_FORCOP",2})
   aadd(aCmpFld,{"BA3_DEFOOP",2})
   aadd(aCmpFld,{"BA3_GRPCOB",2})
   aadd(aCmpFld,{"BA3_CODTDE",2})
   aadd(aCmpFld,{"BA3_DESTDE",2})
   aadd(aCmpFld,{"BA3_COBRAT",2})
   aadd(aCmpFld,{"BA3_RATMAI",2})
   aadd(aCmpFld,{"BA3_COBRET",2})
   aadd(aCmpFld,{"BA3_DIARET",2})
   aadd(aCmpFld,{"BA3_ULTCOB",2})
   aadd(aCmpFld,{"BA3_RATSAI",2})
   aadd(aCmpFld,{"BA3_NUMCOB",2})
   aadd(aCmpFld,{"BA3_ULREA" ,2})
   aadd(aCmpFld,{"BA3_CARIMP",2})
   aadd(aCmpFld,{"BA3_ROTINA",2})
   aadd(aCmpFld,{"BA3_DESMEN",2})
   aadd(aCmpFld,{"BA3_PADSAU",2})
  Endif 

If nFolder = 3  
   
   aadd(aCmpFld,{"BA3_DATCIV",3})
   aadd(aCmpFld,{"BA3_MESREA",3})
   aadd(aCmpFld,{"BA3_INDREA",3})
   aadd(aCmpFld,{"BA3_TIPCON",3})
   aadd(aCmpFld,{"BA3_DESTCO",3})
   aadd(aCmpFld,{"BA3_SEGPLA",3})
   aadd(aCmpFld,{"BA3_DESSEG",3})
   aadd(aCmpFld,{"BA3_MODPAG",3})
   aadd(aCmpFld,{"BA3_APLEI",3})
   aadd(aCmpFld,{"BA3_ABRANG",3})
   aadd(aCmpFld,{"BA3_DESABR",3})
   aadd(aCmpFld,{"BA3_CODACO",3})
   aadd(aCmpFld,{"BA3_DESACO",3})
   aadd(aCmpFld,{"BA3_DATPLA",3})
Endif


/*
If nFolder = 5  
   aadd(aCmpFld,{"BA3_EQUIPE",5})
   aadd(aCmpFld,{"BA3_NOMEQ ",5})
   aadd(aCmpFld,{"BA3_CODVEN",5})
   aadd(aCmpFld,{"BA3_NOMVEN",5})
   aadd(aCmpFld,{"BA3_CODVE2",5})
   aadd(aCmpFld,{"BA3_NOMVE2",5})
Endif   
*/


If nFolder = 5  
   aadd(aCmpFld,{"BA3_COBNIV",5})
   aadd(aCmpFld,{"BA3_VENCTO",5})
   aadd(aCmpFld,{"BA3_CODCLI",5})
   aadd(aCmpFld,{"BA3_LOJA",5})
   aadd(aCmpFld,{"BA3_NOMCLI",5})
   aadd(aCmpFld,{"BA3_NATURE",5})
   aadd(aCmpFld,{"BA3_CODFOR",5})
   aadd(aCmpFld,{"BA3_LOJFOR",5})
   aadd(aCmpFld,{"BA3_NOMFOR",5})
   aadd(aCmpFld,{"BA3_ENDCOB",5})
   aadd(aCmpFld,{"BA3_END",5})
   aadd(aCmpFld,{"BA3_CEP",5})
   aadd(aCmpFld,{"BA3_NUMERO",5})
   aadd(aCmpFld,{"BA3_COMPLE",5})
   aadd(aCmpFld,{"BA3_BAIRRO",5})
   aadd(aCmpFld,{"BA3_CODMUN",5})
   aadd(aCmpFld,{"BA3_MUN",5})
   aadd(aCmpFld,{"BA3_ESTADO",5})
   aadd(aCmpFld,{"BA3_INFCOB",5})
   aadd(aCmpFld,{"BA3_INFGCB",5})
   aadd(aCmpFld,{"BA3_IMPORT",5})
   aadd(aCmpFld,{"BA3_PERMOV",5})
   aadd(aCmpFld,{"BA3_OUTLAN",5})
   aadd(aCmpFld,{"BA3_BLOFAT",5})
   aadd(aCmpFld,{"BA3_CODLAN",5})
   aadd(aCmpFld,{"BA3_CODRDA",5})
   aadd(aCmpFld,{"BA3_TIPPAG",5})
   aadd(aCmpFld,{"BA3_BCOCLI",5})
   aadd(aCmpFld,{"BA3_AGECLI",5})
   aadd(aCmpFld,{"BA3_CTACLI",5})
   aadd(aCmpFld,{"BA3_PORTAD",5})
   aadd(aCmpFld,{"BA3_AGEDEP",5})
   aadd(aCmpFld,{"BA3_CTACOR",5})
   aadd(aCmpFld,{"BA3_PACOOK",5})
   aadd(aCmpFld,{"BA3_CODTES",5})
   aadd(aCmpFld,{"BA3_CODSB1",5})
Endif

If nFolder = 6  
   aadd(aCmpFld,{"BA3_USUOPE",6})
   aadd(aCmpFld,{"BA3_NOMOPE",6})
   aadd(aCmpFld,{"BA3_DATCON",6})
   aadd(aCmpFld,{"BA3_HORCON",6})
Endif

Return aCmpFld
