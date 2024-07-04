#INCLUDE "plsr660.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ?PLSR660 ?Autor ?Tulio Cesar            ?Data ?14.06.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ?Lista as Empresas e seus respectivos dados                 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ?PLSR660                                                    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±?Uso      ?Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±?Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±?Data     ?BOPS ?Programador ?Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define nome da funcao                                                    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function PLSR660(lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define variaveis padroes para todos os relatorios...                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lAuto := .F.

PRIVATE nQtdLin     := 60
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cTitulo     := STR0001  //"Relatorio dos Grupos/Empresas Pessoa Juridica "
PRIVATE cDesc1      := STR0002 //"Este relatorio visa a listagem dos Grupos/Empresas Pessoa Juridica"
PRIVATE cDesc2      := "" 
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BG9"
PRIVATE cPerg       := "PLR660"
PRIVATE cRel        := "PLSR660"
PRIVATE nli         := 00   
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {STR0003,STR0004}  //"Codigo"###"Descricao Empresa"
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "" 
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 01 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Dados do parametro...                                                    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCodEmpDe
PRIVATE cCodEmpAte
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Testa ambiente do relatorio somente top...                               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAutoSt := lAuto

If ! PLSRelTop()
   Return
Endif  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Chama SetPrint (padrao)                                                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
   cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif

   aAlias := {"BTN","BT6","BI3","BR6","BG9","BT5","BQB"}
	objCENFUNLGP:setAlias(aAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Verifica se foi cancelada a operacao (padrao)                            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto .ANd. nLastKey  == 27 
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Acessa parametros do relatorio...                                        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

cCodEmpDe  := mv_par01
cCodEmpAte := mv_par02
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Configura impressora (padrao)                                            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
   SetDefault(aReturn,cAlias) 
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Emite relat¢rio                                                          ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
   MsAguarde({|| R660Imp() }, cTitulo, "", .T.)
else
   R660Imp()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Fim da rotina                                                            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ?R660Imp  ?Autor ?Tulio Cesar           ?Data ?14.06.02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Imprime detalhe do relatorio...                            ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R660Imp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define variaveis...                                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSQL
LOCAL nOrdSel  := aReturn[8] 
LOCAL aCpos
LOCAL aCampos
LOCAL cLinha ,nInd
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Monta dados para montagem de query...                                    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cBG9Name := RetSQLName("BG9")
LOCAL cBG9Fil  := xFilial("BG9")

LOCAL cBT5Name := RetSQLName("BT5")
LOCAL cBT5Fil  := xFilial("BT5")

LOCAL cBQBName := RetSQLName("BQB")
LOCAL cBQBFil  := xFilial("BQB")

LOCAL cBI3Name := RetSQLName("BI3")

LOCAL cBT6Name := RetSQLName("BT6")

LOCAL cBTNName := RetSQLName("BTN")
LOCAL cBTNFil  := xFilial("BTN")

LOCAL cBR6Name := RetSQLName("BR6")
LOCAL cBR6Fil  := xFilial("BR6")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define variaveis de uso generico na rotina...                            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cQuebra     
LOCAL cConEmp
LOCAL cVersao                                                                 
LOCAL nCont

PRIVATE aCpoBG9  := PLSR660CPO("1")
PRIVATE aCpoBT5  := PLSR660CPO("2")
PRIVATE aCpoBQB  := PLSR660CPO("3")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Exibe mensagem...                                                        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
   MsProcTxt(PLSTR0001) 
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Monta Query...                                                           ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Campos do Grupo/Empresa (BG9)...                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BG9_CODINT, BG9_CODIGO, BG9_DESCRI, "

For nCont := 1 To Len(aCpoBG9) 
    cSQL += aCpoBG9[nCont,1]+", "
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Campos do Contrato/Empresa (BT5)...                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BT5_NUMCON, BT5_COBNIV, "

For nCont := 1 To Len(aCpoBT5) 
    cSQL += aCpoBT5[nCont,1]+", "
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Campos das Versoes (BQB)...                                              ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BQB_VERSAO, "

For nCont := 1 To Len(aCpoBQB) 
    cSQL += aCpoBQB[nCont,1]+", "
Next
cSQL := Subs(cSQL,1,Len(cSQL)-2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Relaciona arquvos a serem acessados...                                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += " FROM "+cBG9Name+", "+cBT5Name+", "+cBQBName+" WHERE "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Condicao Grupo/Empresa (BG9)...                                          ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BG9_FILIAL = '"+cBG9Fil+"' AND " 
cSQL += "BG9_CODINT >= '"+Subs(cCodEmpDe,1,4)+"' AND BG9_CODINT <= '"+Subs(cCodEmpAte,1,4)+"' AND "
cSQL += "BG9_CODIGO >= '"+Subs(cCodEmpDe,5,4)+"' AND BG9_CODIGO <= '"+Subs(cCodEmpAte,5,4)+"' AND "
cSQL += "BG9_TIPO = '2' AND "
cSQL += cBG9Name+".D_E_L_E_T_ = '' AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Condicao Contrato/Empresa (BT5)...                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BT5_FILIAL = '"+cBT5Fil+"' AND "
cSQL += "BT5_CODINT = BG9_CODINT AND "
cSQL += "BT5_CODIGO = BG9_CODIGO AND "
cSQL += cBT5Name+".D_E_L_E_T_ = '' AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Condicao Versao (BQB)...                                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BQB_FILIAL = '"+cBQBFil+"' AND "
cSQL += "BQB_CODINT = BG9_CODINT AND "
cSQL += "BQB_CDEMP  = BG9_CODIGO AND "
cSQL += "BQB_NUMCON = BT5_NUMCON AND "
cSQL += cBQBName+".D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Se houver filtro executa parse para converter expressoes adv para SQL    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(aReturn[7])
   cSQL += " AND (" + PLSParSQL(aReturn[7])+" ) "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?De acordo com a ordem....                                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If      nOrdSel == 1
        cSQL += "ORDER BY BG9_FILIAL,BG9_CODINT,BG9_CODIGO,BT5_NUMCON,BQB_VERSAO"
ElseIf  nOrdSel == 2       
        cSQL += "ORDER BY BG9_FILIAL,BG9_DESCRI,BT5_NUMCON,BQB_VERSAO"
Endif

cSQL := ChangeQuery(cSQL)   
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbRel",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Imprime cabecalho...                                                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R660Cabec()      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Inicio da impressao dos detalhes...                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ! TrbRel->(Eof())
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //?Quebra de cada empresa...                                                ?
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cQuebra := TrbRel->(BG9_CODINT+BG9_CODIGO) 
      R660LisEmp()
      
      While cQuebra == TrbRel->(BG9_CODINT+BG9_CODIGO)      
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //?Quebra de cada contrato de uma empresa...                          ?
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cConEmp := TrbRel->BT5_NUMCON
            R660LisCon()

            While cQuebra+cConEmp == TrbRel->(BG9_CODINT+BG9_CODIGO)+TrbRel->BT5_NUMCON
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //?Quebra versoes...                                                  ?
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  cVersao := TrbRel->BQB_VERSAO
                  R660LisVer()

                  While cQuebra+cConEmp+cVersao == TrbRel->(BG9_CODINT+BG9_CODIGO)+TrbRel->BT5_NUMCON+TrbRel->BQB_VERSAO
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //?Exibe mensagem...                                                  ?
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        if !lAutoSt
                           MsProcTXT(STR0005+objCENFUNLGP:verCamNPR("BG9_DESCRI",AllTrim(TrbRel->BG9_DESCRI))+"...") //"Imprimindo "
                        endif
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //?Verifica se foi abortada a impressao...                            ?
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        If !lAutoSt .AND. Interrupcao(lAbortPrint)
                           nLi ++
                           @ nLi, nColuna pSay PLSTR0002
                           Exit
                        Endif                       
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //?Imprime Produtos...                                                ?
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        nLi ++
                        @ ++nLi, nColuna+024 pSay "[ PRODUTOS ]"
                        
                        //cSQL := "SELECT BT6_CODPRO, BT6_VERSAO, BT6_CDPLAN, BI3_DESCRI FROM "
                        cSQL := "SELECT BT6_CODPRO, BT6_VERSAO, BI3_DESCRI FROM "
                        cSQL += cBT6Name+", "+cBI3Name+" WHERE "
                        cSQL += "BT6_FILIAL = '"+xFilial("BT6")+"' AND "
                        cSQL += "BT6_CODINT = '"+TrbRel->BG9_CODINT+"' AND "
                        cSQL += "BT6_CODIGO = '"+TrbRel->BG9_CODIGO+"' AND "
                        cSQL += "BT6_NUMCON = '"+TrbRel->BT5_NUMCON+"' AND "
                        cSQL += "BT6_VERCON = '"+TrbRel->BQB_VERSAO+"' AND "
                        cSQL += cBT6Name+".D_E_L_E_T_ = '' AND "
                        cSQL += "BI3_FILIAL = '"+xFilial("BI3")+"' AND "
                        cSQL += "BI3_CODINT = BT6_CODINT AND "
                        cSQL += "BI3_CODIGO = BT6_CODPRO AND "
                        cSQL += "BI3_VERSAO = BT6_VERSAO AND "
                        cSQL += cBI3Name+".D_E_L_E_T_ = ''"
                        
		                cSQL := ChangeQuery(cSQL)   
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBT6",.F.,.T.) 
		                                        
                        While ! TrbBT6->(Eof())
                        
                              nLi ++
                              @ ++nLi, nColuna+024 pSay  objCENFUNLGP:verCamNPR("BT6_CODPRO",TrbBT6->BT6_CODPRO)+" / "+;
                                                         objCENFUNLGP:verCamNPR("BT6_VERSAO",TrbBT6->BT6_VERSAO)+" - "+;
                                                         objCENFUNLGP:verCamNPR("BI3_DESCRI",TrbBT6->BI3_DESCRI)

                              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                              //?Para cada produto imprime sua forma de pagamento...                ?
                              //?                                                                   ?
                              //?Por emquanto somente BTN...                                        ?
                              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                              cSQL := "SELECT BTN_TIPUSR, BTN_SEXO, BTN_IDAINI, BTN_IDAFIN, BTN_VALFAI, "
                              cSQL += "BTN_GRAUPA, BTN_TIPUSR, BTN_GRAUPA FROM "
                              cSQL += cBTNName+" WHERE "
                              cSQL += "BTN_FILIAL = '"+cBTNFil+"' AND "
                              cSQL += "BTN_CODIGO = '"+TrbRel->(BG9_CODINT+BG9_CODIGO)+"' AND "
                              cSQL += "BTN_NUMCON = '"+TrbRel->BT5_NUMCON+"' AND "
                              cSQL += "BTN_VERCON = '"+TrbRel->BQB_VERSAO+"' AND "
                              cSQL += "BTN_CODPRO = '"+TrbBT6->BT6_CODPRO+"' AND "
                              cSQL += "BTN_VERPRO = '"+TrbBT6->BT6_VERSAO+"' AND "
                              cSQL += cBTNName+".D_E_L_E_T_ = ''"
                              
                              cSQL := ChangeQuery(cSQL)   
							  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBTN",.F.,.T.) 
                             
                              SX3->(DbSetOrder(2))
                              
                              If ! TrbBTN->(Eof())
                                  nLi ++
                                  @ ++nLi, nColuna+030 pSay "[ FAIXAS ETARIAS ]"
                                  nLi ++
                                  
                                  While ! TrbBTN->(Eof())   
                                        aCpos := {}
                                        TrbBTN->(aadd(aCpos,{"BTN_TIPUSR",objCENFUNLGP:verCamNPR("BTN_TIPUSR",BTN_TIPUSR)}))
                                        TrbBTN->(aadd(aCpos,{"BTN_SEXO",objCENFUNLGP:verCamNPR("BTN_SEXO",BTN_SEXO)}))
                                        TrbBTN->(aadd(aCpos,{"BTN_IDAINI",objCENFUNLGP:verCamNPR("BTN_IDAINI",BTN_IDAINI)}))
                                        TrbBTN->(aadd(aCpos,{"BTN_IDAFIN",objCENFUNLGP:verCamNPR("BTN_IDAFIN",BTN_IDAFIN)}))
                                        TrbBTN->(aadd(aCpos,{"BTN_VALFAI",objCENFUNLGP:verCamNPR("BTN_VALFAI",BTN_VALFAI)}))
                                        TrbBTN->(aadd(aCpos,{"BTN_GRAUPA",objCENFUNLGP:verCamNPR("BTN_GRAUPA",BTN_GRAUPA)}))
                                  
                                        aCampos := PLSPRNFld(aCpos)
                                  
                                        For nInd := 1 To Len(aCampos)
                                            cLinha := aCampos[nInd]
                                            @ ++nLi, nColuna+030 pSay cLinha
                                            If nInd+1 <= Len(aCampos)
                                               @ nLi, 070 pSay aCampos[nInd+1]
                                               nInd ++
                                               
                                               VldPag()
                                            Endif   
                                        Next           
                                        VldPag()
                                        
                                  TrbBTN->(DbSkip())
                                  
                                  If ! TrbBTN->(Eof())
                                     nLi ++
                                     nLi ++
                                  Endif
                                  
                                  Enddo
                              Else
                                  nLi ++
                                  @ ++nLi, nColuna+030 pSay STR0006 //"Nao existe faixa(s) etaria(s) cadastrada"
                                  nLi ++
                              Endif           
                              TrbBTN->(DbCloseArea())
                              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                              //?Para cada produto imprime sua TAXA DE ADESAO...                    ?
                              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                              cSQL := "SELECT BR6_TIPUSR, BR6_SEXO, BR6_IDAINI, BR6_IDAFIN, BR6_VLRADE, "
                              cSQL += "BR6_GRAUPA, BR6_TIPUSR, BR6_GRAUPA FROM "
                              cSQL += cBR6Name+" WHERE "
                              cSQL += "BR6_FILIAL = '"+cBR6Fil+"' AND "             
                              cSQL += "BR6_CODINT = '"+TrbRel->(BG9_CODINT)+"' AND "
                              cSQL += "BR6_CODGRU = '"+TrbRel->(BG9_CODIGO)+"' AND "
                              cSQL += "BR6_NUMCON = '"+TrbRel->BT5_NUMCON+"' AND "
                              cSQL += "BR6_VERSAO = '"+TrbRel->BQB_VERSAO+"' AND "
                              cSQL += "BR6_CODPRO = '"+TrbBT6->BT6_CODPRO+"' AND "
                              cSQL += cBR6Name+".D_E_L_E_T_ = ''"
                              
                              cSQL := ChangeQuery(cSQL)   
							  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBR6",.F.,.T.) 
							  
                              SX3->(DbSetOrder(2))
                              
                              If ! TrbBR6->(Eof())
                                  nLi ++
                                  @ ++nLi, nColuna+030 pSay STR0007 //"[ TAXA ADESAO ]"
                                  nLi ++
                                  
                                  While ! TrbBR6->(Eof())   
                                        aCpos := {}
                                        TrbBR6->(aadd(aCpos,{"BR6_TIPUSR",objCENFUNLGP:verCamNPR("BR6_TIPUSR",BR6_TIPUSR)}))
                                        TrbBR6->(aadd(aCpos,{"BR6_SEXO",objCENFUNLGP:verCamNPR("BR6_SEXO",BR6_SEXO)}))
                                        TrbBR6->(aadd(aCpos,{"BR6_IDAINI",objCENFUNLGP:verCamNPR("BR6_IDAINI",BR6_IDAINI)}))
                                        TrbBR6->(aadd(aCpos,{"BR6_IDAFIN",objCENFUNLGP:verCamNPR("BR6_IDAFIN",BR6_IDAFIN)}))
                                        TrbBR6->(aadd(aCpos,{"BR6_VlRADE",objCENFUNLGP:verCamNPR("BR6_VLRADE",BR6_VLRADE)}))
                                        TrbBR6->(aadd(aCpos,{"BR6_GRAUPA",objCENFUNLGP:verCamNPR("BR6_GRAUPA",BR6_GRAUPA)}))
                                  
                                        aCampos := PLSPRNFld(aCpos)
                                  
                                        For nInd := 1 To Len(aCampos)
                                            cLinha := aCampos[nInd]
                                            @ ++nLi, nColuna+030 pSay cLinha
                                            If nInd+1 <= Len(aCampos)
                                               @ nLi, 070 pSay aCampos[nInd+1]
                                               nInd ++     
                                               
                                               VldPag()
                                            Endif   
                                        Next               
                                        VldPag()
                                        
                                  TrbBR6->(DbSkip())
                                  
                                  If ! TrbBR6->(Eof())
                                     nLi ++
                                     nLi ++
                                  Endif   
                                  
                                  Enddo
                              Else
                                  nLi ++
                                  @ ++nLi, nColuna+030 pSay STR0008 //"Nao existe taxa(s) de adesao(s) cadastrada"
                                  nLi ++
                              Endif    
                              TrbBR6->(DbCloseArea())
                        TrbBT6->(DbSkip())
                        Enddo             
                        TrbBT6->(DbCloseArea())
                  TrbRel->(DbSkip())
                  Enddo
            Enddo      
      Enddo     
Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Imprime rodape do relatorio...                                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
   Roda(0,space(10),cTamanho)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Fecha arquivo...                                                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TrbRel->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Libera impressao                                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. aReturn[5] == 1 
    Set Printer To
    Ourspool(cRel)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Fim do Relat¢rio                                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ?R660Cabec ?Autor ?Tulio Cesar          ?Data ?14.06.02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Imprime Cabecalho                                          ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R660Cabec()      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Imprime cabecalho...                                                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
   nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
endif
nLi ++
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Fim da Rotina...                                                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return                                                                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ?R660LISEMP?Autor ?Tulio Cesar          ?Data ?14.06.02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Lista Empresa...                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R660LisEmp()
LOCAL cLinha,nCont
@ ++nLi,nColuna pSay STR0009+TransForm(objCENFUNLGP:verCamNPR("BG9_CODINT",TrbRel->BG9_CODINT)+;
                                       objCENFUNLGP:verCamNPR("BG9_CODIGO",TrbRel->BG9_CODIGO),"@R !.!!!-!!!!")+" - "+; //"EMPRESA [ "
                              AllTrim(objCENFUNLGP:verCamNPR("BG9_DESCRI",TrbRel->BG9_DESCRI))+" ]"
                          
nLi ++
For nCont := 1 To Len(aCpoBG9)
    If Empty(aCpoBG9[nCont,3])
       cLinha := aCpoBG9[nCont,2]+" : "+;
                            objCENFUNLGP:verCamNPR(aCpoBG9[nCont,1],TransForm(&("TrbRel->"+aCpoBG9[nCont,1]),aCpoBG9[nCont,4]) )
    Else
       cLinha := aCpoBG9[nCont,2]+" : "+;
                            objCENFUNLGP:verCamNPR(aCpoBG9[nCont,1],X3COMBO(aCpoBG9[nCont,1],&("TrbRel->"+aCpoBG9[nCont,1])))
    Endif                        
    @ ++nLi,nColuna+008 pSay cLinha
   
    If nCont+1 <= Len(aCpoBG9)                          
       If Empty(aCpoBG9[nCont+1,3])
          cLinha := aCpoBG9[nCont+1,2]+" : "+;
                               objCENFUNLGP:verCamNPR(aCpoBG9[nCont+1,1],TransForm(&("TrbRel->"+aCpoBG9[nCont+1,1]),aCpoBG9[nCont+1,4]) )
       Else
          cLinha := aCpoBG9[nCont+1,2]+" : "+;
                              objCENFUNLGP:verCamNPR(aCpoBG9[nCont+1,1],X3COMBO(aCpoBG9[nCont+1,1],&("TrbRel->"+aCpoBG9[nCont+1,1])))
       Endif                        
       @ nLi,070 pSay cLinha                           
       VldPag()
       nCont ++
    Endif    
    VldPag()
Next    

Return                      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ?R660LISCON?Autor ?Tulio Cesar          ?Data ?14.06.02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Lista Contrato...                                          ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R660LisCon()
LOCAL cLinha,nCont

nLi ++
@ ++nLi,nColuna+008 pSay STR0010+AllTrim(objCENFUNLGP:verCamNPR("BT5_NUMCON",TrbRel->(BT5_NUMCON)))+" ]" //"CONTRATO [ "

nLi ++
For nCont := 1 To Len(aCpoBT5)
    If Empty(aCpoBT5[nCont,3])
       cLinha := aCpoBT5[nCont,2]+" : "+;
                            objCENFUNLGP:verCamNPR(aCpoBT5[nCont,1],TransForm(&("TrbRel->"+aCpoBT5[nCont,1]),aCpoBT5[nCont,4]) )
    Else
       cLinha := aCpoBT5[nCont,2]+" : "+;
                            objCENFUNLGP:verCamNPR(aCpoBT5[nCont,1],X3COMBO(aCpoBT5[nCont,1],&("TrbRel->"+aCpoBT5[nCont,1])))
    Endif                        

    @ ++nLi,nColuna+017 pSay cLinha

    If nCont+1 <= Len(aCpoBT5)                          
       If Empty(aCpoBT5[nCont+1,3])
          cLinha := aCpoBT5[nCont+1,2]+" : "+;
                               objCENFUNLGP:verCamNPR(aCpoBT5[nCont+1,1],TransForm(&("TrbRel->"+aCpoBT5[nCont+1,1]),aCpoBT5[nCont+1,4]) )
       Else
          cLinha := aCpoBT5[nCont+1,2]+" : "+;
                              objCENFUNLGP:verCamNPR(aCpoBT5[nCont+1,1],X3COMBO(aCpoBT5[nCont+1,1],&("TrbRel->"+aCpoBT5[nCont+1,1])))
       Endif                        
       @ nLi,070 pSay cLinha
       VldPag()
       nCont ++
    Endif    
    VldPag()
Next    

Return                      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ?R660LISVER?Autor ?Tulio Cesar          ?Data ?14.06.02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Lista Versoes...                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R660LisVer()
LOCAL cLinha,nCont

nLi ++
@ ++nLi,nColuna+017 pSay STR0011+objCENFUNLGP:verCamNPR("BQB_VERSAO",TrbRel->(BQB_VERSAO))+" ]" //"VERSAO [ "

nLi ++
For nCont := 1 To Len(aCpoBQB)
    If Empty(aCpoBQB[nCont,3])
       cLinha := aCpoBQB[nCont,2]+" : "+;
                            objCENFUNLGP:verCamNPR(aCpoBQB[nCont,1],TransForm(&("TrbRel->"+aCpoBQB[nCont,1]),aCpoBQB[nCont,4]) )
    Else
       cLinha := aCpoBQB[nCont,2]+" : "+;
                            objCENFUNLGP:verCamNPR(aCpoBQB[nCont,1],X3COMBO(aCpoBQB[nCont,1],&("TrbRel->"+aCpoBQB[nCont,1])))
    Endif                        
    @ ++nLi,nColuna+024 pSay cLinha
    
    If nCont+1 <= Len(aCpoBQB)                          
       If Empty(aCpoBQB[nCont+1,3])
          cLinha := aCpoBQB[nCont+1,2]+" : "+;
                               objCENFUNLGP:verCamNPR(aCpoBQB[nCont+1,1],TransForm(&("TrbRel->"+aCpoBQB[nCont+1,1]),aCpoBQB[nCont+1,4]) )
       Else
          cLinha := aCpoBQB[nCont+1,2]+" : "+;
                              objCENFUNLGP:verCamNPR(aCpoBQB[nCont+1,1],X3COMBO(aCpoBQB[nCont+1,1],&("TrbRel->"+aCpoBQB[nCont+1,1])))
       Endif                        
       @ nLi,070 pSay cLinha
       VldPag()
       nCont ++
    Endif    
    VldPag()    
Next    

Return                      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ?PLSR660CPO?Autor ?Tulio Cesar          ?Data ?14.06.02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Monta campos...                                            ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function PLSR660CPO(cTipo)
LOCAL aCampos := {}
/*
"1" - BG9
"2" - BT5
"3" - BQB
*/

If     cTipo == "1"
       SX3->(DbSetOrder(1))
       If SX3->(DbSeek("BG9"))
          While SX3->X3_ARQUIVO == "BG9"
                If X3USO(SX3->X3_USADO) .And. ! ( SX3->X3_CAMPO $ "BG9_CODINT,BG9_CODIGO,BG9_DESCRI" ) .And. SX3->X3_CONTEXT <> "V"
                   aadd(aCampos,{SX3->X3_CAMPO,X3TITULO(),SX3->X3_CBOX,AllTrim(SX3->X3_PICTURE)})
                Endif    
          SX3->(DbSkip())
          Enddo
       Endif
ElseIf cTipo == "2"
       SX3->(DbSetOrder(1))
       If SX3->(DbSeek("BT5"))
          While SX3->X3_ARQUIVO == "BT5"
                If X3USO(SX3->X3_USADO) .And. ! ( SX3->X3_CAMPO $ "BT5_NUMCON" ) .And. SX3->X3_CONTEXT <> "V"
                   aadd(aCampos,{SX3->X3_CAMPO,X3TITULO(),SX3->X3_CBOX,AllTrim(SX3->X3_PICTURE)})
                Endif    
          SX3->(DbSkip())
          Enddo
       Endif
ElseIf cTipo == "3"
       SX3->(DbSetOrder(1))
       If SX3->(DbSeek("BQB"))
          While SX3->X3_ARQUIVO == "BQB"
                If X3USO(SX3->X3_USADO) .And. ! ( SX3->X3_CAMPO $ "BQB_VERSAO" ) .And. SX3->X3_CONTEXT <> "V"
                   aadd(aCampos,{SX3->X3_CAMPO,X3TITULO(),SX3->X3_CBOX,AllTrim(SX3->X3_PICTURE)})
                Endif    
          SX3->(DbSkip())
          Enddo
       Endif
Endif

Return(aCampos)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ?VLDPAG    ?Autor ?Tulio Cesar          ?Data ?14.06.02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Valida a proxima pagina...                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function VldPag()

If nLi > nQtdLin
   R660Cabec()
Endif 


Return
