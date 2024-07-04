#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "topconn.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lautoSt := .F.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддбдддддддбдддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR671Ё Autor Ё Tulio Cesar             Ё Data Ё 01.11.00 Ё╠╠╠
╠╠цддддддддддеддддддддадддддддадддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Exportacao de Cartas de Cobranca para UNISOFT.             Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR671()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial.                              Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠ 
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё          Ё      Ё             Ё                                       Ё╠╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSR671(lauto)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nOpca       	:= 0
Local aSays       	:= {}
Local aButtons 		:= {}
Local oTempTRB
Local oTempSE1
Local aStructSE1	:= {}
Local aFieldsSE1	:= {}
Local cWhere		:= ""

Default lAuto := .F.

Private aEtiqueta 	:= {}
Private cCadastro 	:= "Carta de Cobranca"
Private cPerg     	:= "PLR671" 
Private nTamVal		:= TamSx3("E1_VALOR")[1]
Private nDecVal		:= TamSx3("E1_VALOR")[2]
Private cIntDe   
Private cIntAte  
Private cEmpDe   
Private cEmpAte  
Private dVenDe   
Private dVenAte  
Private cNatDe   
Private cNatAte  
Private cIncDe   
Private cIncAte  
Private nConsid 
Private cEmpresa
Private cEmpExc 
Private cDatExc 
Private cObs1 
Private cObs2
Private nOpcao  
Private cArqSai

lautoSt := lAuto

if !lauto .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta texto para janela de processamento                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aSays,"Esta rotina permite a geracao de Carta de Cobranca, em formato")
aadd(aSays,"de relatorio ou em formato de arquivo texto.")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta botoes para janela de processamento                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk().and.Ver_Perg(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe janela de processamento                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lauto
    FormBatch(cCadastro,aSays,aButtons)
else
    nOpca := 1
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa importacao do arquivo texto                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nOpca == 1

    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Declara variaveis...                                                     Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    Private cDatBas
    Private Trb
    PRIVATE lAbortPrint := .F.                                                                       
    PRIVATE nQtdCli     := 0
    PRIVATE nQtdExc     := 0
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Cria arquivo de onde sera gerado no arquivo de exportacao...             Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    aCampos := {}
    aadd(aCampos,{"CONTADOR"    ,"C",006,0})
    aadd(aCampos,{"TIPREG  "    ,"C",001,0})
    aadd(aCampos,{"RESTO   "    ,"C",206,0})
    
	//--< CriaГЦo do objeto FWTemporaryTable >---
	oTempTRB := FWTemporaryTable():New( "TRB" )
	oTempTRB:SetFields( aCampos )
	oTempTRB:AddIndex( "INDTRB",{ "CONTADOR","TIPREG" } )
	
	if( select( "TRB" ) > 0 )
		TRB->( dbCloseArea() )
	endIf
	
	oTempTRB:Create()
    
    DbSelectArea("SE1")

    if lautoSt
        cIntDe := "    "
        cIntAte := "ZZZZ"
        cEmpDe := "  "
        cEmpAte := "ZZ"
        dVenDe := StoD("")
        dVenAte := Date()
        cNatAte := "ZZ"
        cNatDe := "  "
    endif
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Monta filtro no arquivo de contas a receber de acordo com os parametros  Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    cWhere   := " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
    cWhere   += " and E1_CODINT >= '" + cIntDe  + "'"
    cWhere   += " and E1_CODINT <= '" + cIntAte + "'"
    cWhere   += " and E1_CODEMP >= '" + cEmpDe  + "'"
    cWhere   += " and E1_CODEMP <= '" + cEmpAte + "'"
    cWhere   += " and E1_VENCTO >= '" + dtos(dVenDe)  + "'"
    cWhere   += " and E1_VENCTO <= '" + dtos(dVenAte) + "'"
    cWhere   += " and E1_NATUREZ >= '" + cNatDe  + "'"
    cWhere   += " and E1_NATUREZ <= '" + cNatAte + "'"
    cWhere   += " and E1_SALDO > 0 "
    cWhere   += " and E1_MATRIC <> '      ' "
    cWhere   += " and D_E_L_E_T_ = ' ' "
    
	aStructSE1 := SE1->( dbStruct() )
	aFieldsSE1 := {}
	aEval( aStructSE1,{ | x | aadd( aFieldsSE1,x[ 1 ] ) },1,len( aStructSE1 ) )
	
	oTempSE1 := FWTemporaryTable():New( "TEMPSE1" )
	oTempSE1:SetFields( aStructSE1 )
	oTempSE1:AddIndex( "INDSE1",StrTokArr( SE1->( indexKey( 14 ) ),"+" ) ) //FILIAL+CODINT+CODEMP+MATRIC+ANOBASE+MESBASE
	
	if( select( "TEMPSE1" ) > 0 )
		TEMPSE1->( dbCloseArea() )
	endIf
			
	oTempSE1:Create()
	oTempSE1:InsertSelect( RetSqlName( "SE1" ),aFieldsSE1 )
	MPSysOpenQuery( "select * from " + oTempSE1:GetRealName() + cWhere,'QRYSE1' )
    
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Executa funcao para efetuar a exportacao...                              Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    if !lauto
        MsAguarde( { || Plr671Imp() } )
    else
        Plr671Imp()
    endif

    if( select( "TRB" ) > 0 )
    	oTempTRB:delete()
    endIf
    
    if( select( "TEMPSE1" ) > 0 )
    	oTempSE1:delete()
    endIf
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё Ver_Perg    Ё Autor Ё Angelo Sperandio   Ё Data Ё 26/02/04 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Verifica se parametros estao ok                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё Ver_Perg()                                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё nenhum                                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function Ver_perg()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRet := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza parametros                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
cIntDe   := mv_par01
cIntAte  := mv_par02
cEmpDe   := mv_par03
cEmpAte  := mv_par04
dVenDe   := mv_par05
dVenAte  := mv_par06
cNatDe   := mv_par07
cNatAte  := mv_par08
cIncDe   := mv_par09
cIncAte  := mv_par10
nConsid  := mv_par11 // 1 Ativos, 2 Bloqueados, 3 Todos
cEmpExc  := mv_par12
cObs1    := alltrim(mv_par13)
cObs2    := alltrim(mv_par14)
nOpcao   := mv_par15
cArqSai  := alltrim(mv_par16)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao for etiqueta, verifica se informou modelo de carta / arq de saida Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nOpcao <> 3 // Diferente de etiqueta
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verifica existencia dos modelos de cartas                                Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  ! empty(cObs1) .and. ;
        ! file(cObs1)
        msgstop("Modelo de carta inicio nao encontrado")
        lRet := .F.
    Endif    
    If  ! empty(cObs2) .and. ;
        ! file(cObs2)
        msgstop("Modelo de carta fim nao encontrado")
        lRet := .F.
    Endif    
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verifica se informou arquivo de saida                                    Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  nOpcao == 2 .and. ;
        empty(cArqSai)
        msgstop("Arquivo de Saida nao informado")
        lRet := .F.
    Endif    
Endif    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё Plr671Imp Ё Autor Ё Tulio Cesar          Ё Data Ё 05.07.00 Ё╠╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Exportacao de Cartas Cobranca Padrao UNISOFT               Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function Plr671Imp()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL nCont    	:= 1        
LOCAL nVlrTot  	:= 0
LOCAL nQtdReg  	:= 0
LOCAL pCep      := PesqPict("SA1","A1_CEP")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta registro tipo "1" - Cabecalho do arquivo de remessa...             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
c01Cont    := StrZero(nCont++,6)
c01Tipo    := "0"
c01Data    := dtoc(dDataBase) 
c01Emp     := cEmpresa
c01Linha   := c01Data

Trb->(DbAppend())
Trb->CONTADOR := c01Cont
Trb->TIPREG   := c01Tipo
Trb->RESTO    := c01Linha
Trb->(DbUnLock())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da nevagacao pelos titulos selecionados...                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
QRYSE1->(DbGoTop())

While ! QRYSE1->(Eof())
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Acumuladores...                                                          Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nQtdReg ++
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Exibe mensagem...                                                        Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    if !lautoSt
       MsProcTXT("Processando... "+QRYSE1->(E1_CODINT+E1_CODEMP+E1_MATRIC))
    endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se deve desconsiderar a empresa                                 Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !lautoSt .AND. QRYSE1->E1_CODEMP $ cEmpExc
       QRYSE1->(DbSkip())
       Loop
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Para cada titulo lido posiciono no arquivo de contratos...               Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BA3->(DbSetOrder(1))
   If  ! BA3->(DbSeek(xFilial("BA3")+QRYSE1->(E1_CODINT+E1_CODEMP+E1_MATRIC)))
       if !lautoSt
           MsgStop("Contrato do Titulo "+QRYSE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)+" Invalido. Verifique")
       endif
       QRYSE1->(DbSkip())
       Loop
   Else
       cDatBas := BA3->BA3_DATBAS
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Se o usuario tiver menos de um mes de plano nao imprimo registro...      Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If (dDataBase - BA3->BA3_DATBAS) < 30
           QRYSE1->(DbSkip())
           Loop
       Endif
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Para cada titulo lido posiciono no cliente...                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   SA1->(DbSetOrder(1))
   If  ! SA1->(DbSeek(xFilial("SA1")+BA3->(BA3_CODCLI+BA3_LOJA)))
       if !lautoSt
           MsgStop("Cliente do Titulo "+QRYSE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)+" Invalido. Verifique")
       endif
       QRYSE1->(DbSkip())
       Loop
   Endif   
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Para cada titulo lido posiciono no titular...                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BA1->(DbSetOrder(2))
   If  ! BA1->(DbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
       if !lautoSt
            MsgStop("Titular do Contrato "+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+" Invalido. Verifique")
       endif
       QRYSE1->(DbSkip())
       Loop
   Endif   
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica situacao do contrato avaliando de acordo com o parametro...     Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If     nConsid == 1 // Somente ativos
          If  ! Empty(BA3->BA3_MOTBLO)
              QRYSE1->(DbSkip())
              Loop
          Endif
   ElseIf nConsid == 2 // Somente Bloqueados
          If  Empty(BA3->BA3_MOTBLO)
              QRYSE1->(DbSkip())
              Loop
          Endif
   Endif          
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Contador de clientes                                                     Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nQtdCli ++
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta vetor com codigos dos clientes para emissa da etiqueta             Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  nOpcao == 3 // Etiqueta
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Monta vetor com codigos dos clientes para emissa da etiqueta             Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       aadd(aEtiqueta,{AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)),; // Vinha como cСdigo do cliente, mas o correto И vir com a matrМcula do beneficiАrio. AllTrim(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC))
                       AllTrim(SA1->A1_NOME),;
                       AllTrim(SA1->A1_END),;
                       AllTrim(SA1->A1_BAIRRO),;
                       AllTrim(SA1->A1_MUN) + " - " + AllTrim(SA1->A1_EST) + "  CEP " + AllTrim(TransForm(SA1->A1_CEP,pCep))}) //aplicado o AllTrim pois dava divergЙncia de tamanho no layout
   
   Else
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Monta registro tipo "1" - dados do titulo e do cliente...                Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       c02Cont   := StrZero(nCont++,6)
       c02Tipo   := "1"
       c02TipReg := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
       c02Nome   := Subs(SA1->A1_NOME,1,30)

       c02Aux    := AllTrim(SA1->A1_END) // +Space(01)+AllTrim(SA1->A1_YNR_END)+Space(01)+AllTrim(SA1->A1_YCOMEND)
       c02Ender  := Subs(c02Aux + Space(40),1,40)
       If  Len(c02Ender) < 40
           c02Ender := c02Ender+Space(40-Len(c02Ender))
       Endif   
     
       c02Bairro := Subs(SA1->A1_BAIRRO,1,15)
       c02Cep    := TransForm(SA1->A1_CEP,pCep)
       c02Cidade := Subs(SA1->A1_MUN,1,15)
       c02Estado := SA1->A1_EST
      
       c02Linha  := c02TipReg+c02Nome+c02Ender+c02Bairro+c02Cep+c02Cidade+c02Estado
      
       Trb->(DbAppend())
       Trb->CONTADOR := c02Cont
       Trb->TIPREG   := c02Tipo
       Trb->RESTO    := c02Linha
       Trb->(DbUnLock())
   Endif
 
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta registro tipo "2" - dados dos titulos...                           Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cChave    := QRYSE1->(E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC)
      
   While ! QRYSE1->(Eof()) .And. QRYSE1->(E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC) == cChave

      If  nOpcao <> 3 // Diferente de Etiqueta
     
          c03Cont  := StrZero(nCont++,6)
          c03Tipo  := "2"
          c03Mes   := QRYSE1->E1_MESBASE
          c03Ano   := QRYSE1->E1_ANOBASE
          c03Venc  := DtoC(StoD(QRYSE1->E1_VENCTO))
          cValor   := Str(QRYSE1->E1_VALOR,nTamVal,nDecVal)
          cValor   := AllTrim(StrTran(cValor,".",""))
          cVlr     := Subs(cValor,1,Len(cValor)-nDecVal)
          cDec     := Subs(cValor,Len(cValor)+1-nDecVal,nDecVal)
          cValor   := StrZero(Val(cVlr+cDec),nTamVal)
          
          c03Linha := c03Mes+c03Ano+c03Venc+cValor
           
          Trb->(DbAppend())
          Trb->CONTADOR := c03Cont
          Trb->TIPREG   := c03Tipo
          Trb->RESTO    := c03Linha
          Trb->(DbUnLock())
          
          nVlrTot += QRYSE1->E1_VALOR

      Endif

      QRYSE1->(DbSkip())

   Enddo
   
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Trailler.                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nOpcao <> 3 // Diferente de Etiqueta

    c06Cont    := StrZero(nCont++,6)
    c06Tipo    := "9" 
	c06TotCont := StrZero(nQtdCli,6)

	cValor   := Str(QRYSE1->E1_VALOR,nTamVal,nDecVal)
	cValor   := StrTran(cValor,".","")
	cVlr     := Subs(cValor,1,Len(cValor)-nDecVal)
	cDec     := Subs(cValor,Len(cValor)+1-nDecVal,nDecVal)
	cValor   := StrZero(Val(cVlr+cDec),nTamVal)
	c06VlrTot:= cValor

    c06Linha   := c06TotCont+c06VlrTot

    Trb->(DbAppend())
    Trb->CONTADOR := c06Cont
    Trb->TIPREG   := c06Tipo
    Trb->RESTO    := c06Linha
    Trb->(DbUnLock())

Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera arquivo em disco...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nQtdCli > 0
    If     nOpcao = 1	// Emite a Carta de Cobranca
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Chama funcao para impressao da carta de cobranca                         Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            if !lautoSt
               MsAguarde( { || Plr671Cart() } ) 
            else
                Plr671Cart()
            endif
    ElseIf nOpcao = 2	// Gera o arquivo texto
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Grava arquivo texto...                                                   Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           DbSelectArea("TRB")
           Copy To &cArqSai SDF     
           if !lautoSt
               MsgStop("Arquivo "+cArqSai+" Gerado Com Sucesso !!!")
            endif
    ElseIf nOpcao = 3	// Imprime etiquetas
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Chama funcao para impressao de etiquetas                                 Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           PLSR043("Etiqueta p/ Carta de Cobranca",aEtiqueta,3,5)
    Endif
Elseif !lautoSt
    MsgStop("Nao existem registros para o parametro especificado.")
Endif 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return      

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё Plr671CartЁ Autor Ё Guilherme Brunoro    Ё Data Ё 02.04.01 Ё╠╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Imprime carta de cobranca                                  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function Plr671Cart()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR671"
PRIVATE nCaracter   := 15
PRIVATE nColuna     := 16
PRIVATE nLimite     := 80
PRIVATE cTamanho    := "P"
PRIVATE cTitulo     := "Relatorio de carta de cobranca"
PRIVATE cDesc1      := "Relatorio de carta de cobranca"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE cAlias      := "SE1"
PRIVATE cRel        := "PLSR671"
PRIVATE nLiIni      := 5
PRIVATE nLi         := 5
PRIVATE m_pag       := 1
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } // 'Zebrado' , 'Administracao'
PRIVATE aOrdens     := {"",""}
PRIVATE lDicion     := .F.
PRIVATE lCompres    := .F.
PRIVATE lCrystal    := .F.
PRIVATE lFiltro     := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lautoSt
    cRel := SetPrint(cAlias,cRel,"",@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,nil,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lautoSt .AND. nLastKey  == 27
    Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura Impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lautoSt
    SetDefault(aReturn,cAlias)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta RptStatus...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lautoSt
    MsAguarde( {|| Plr671PCar() }  , "" , "" , .T. ) // 'Aguarde. Processando...'
else
    Plr671PCar()
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё Plr671PCarЁ Autor Ё Guilherme Brunoro    Ё Data Ё 02.04.01 Ё╠╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Monta relatorio                                            Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function Plr671PCar()

LOCAL   lExc     := .F.              
LOCAL   aMes     := {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho",;
                     "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"} 
LOCAL nLinha

PRIVATE wArqIni  := MemoRead(cObs1)
PRIVATE wLinIni  := MLCount(wArqIni,98) 
PRIVATE wArqFim  := MemoRead(cObs2)
PRIVATE wLinFim  := MLCount(wArqFim,98) 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se existe registros da empresa excessao...                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nQtdExc > 0
    If lautoSt .OR. MsgYesNo("Imprimir somente empresa "+cEmpExc+" ?")
        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        //Ё Imprimir aviso de cobranca...                                            Ё
        //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        lExc     := .T.
    Endif
Endif

TRB->(DbGoTop())

While ! TRB->(Eof())
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Exibe mensagem...                                                        Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   if !lautoSt
       MsProcTXT("Imprimindo... ")
   endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se foi abortada a impressao...                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !lautoSt .AND. Interrupcao(lAbortPrint)
       Exit
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se somente registros da empresa excessao...                              Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  lExc
       If  TRB->TIPREG == '1'
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Para cada registro lido posiciono no arquivo de contratos...             Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           BA3->(DbSetOrder(1))
           If  ! BA3->(DbSeek(xFilial("BA3")+Subs(TRB->RESTO,01,13))) .AND. !lautoSt
               MsgStop("Contrato do Titulo "+Subs(TRB->RESTO,01,13)+" Invalido. Verifique")
           Else
               cDatBas := BA3->BA3_DATBAS
           Endif
           If  ! (Substr(Subs(TRB->RESTO,01,13),4,4) == cEmpExc .And. cDatBas <= cDatExc)
               TRB->(DbSkip())
               Loop
           Endif
       Endif
       If  TRB->TIPREG == '2'
           While ! TRB->(Eof()) .And. TRB->TIPREG   == '2'
              TRB->(DbSkip())
           Enddo
           Loop
       Endif
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica os tipos de registros...                                  Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  TRB->TIPREG   == '0'
       TRB->(DbSkip())
       Loop
   Endif      
  
   If  TRB->TIPREG   == '1'                               
   
       cDia    := substr(dtos(dDataBase),7,2)
       nMes    := month(dDataBase)
       cAno    := substr(dtos(dDataBase),1,4)
       cDatLoc := alltrim(SM0->M0_CIDCOB) + ", " + cDia + " de " + aMes[nMes] + " de " + cAno
   
       @ nLi, nColuna pSay cDatLoc
       nLi ++     
       nLi ++     
       @ nLi, nColuna pSay Subs(TRB->RESTO,15,30) //nome  
       nLi ++     
       @ nLi, nColuna pSay Subs(TRB->RESTO,45,40) //endereco
       nLi ++     
       @ nLi, nColuna pSay Subs(TRB->RESTO,85,15) //bairro
       nLi ++     
       @ nLi, nColuna pSay Subs(TRB->RESTO,109,15) + " - " + Subs(TRB->RESTO,124,2) //CIDADE+ESTADO
       nLi ++     
       @ nLi, nColuna pSay Subs(TRB->RESTO,100,09) //CEP  
       nLi ++     
       nLi ++     
       @ nLi, nColuna pSay "Matricula: " + transform(Subs(TRB->RESTO,01,14),"@R XXXX.XXXX.XXXXXX")  //MATRIC  
       nLi ++     
          
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Para cada registro lido posiciono no arquivo de contratos...             Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BA3->(DbSetOrder(1))
       If  ! BA3->(DbSeek(xFilial("BA3")+Subs(TRB->RESTO,01,13))) .AND. !lautoSt
           MsgStop("Contrato do Titulo "+Subs(TRB->RESTO,01,13)+" Invalido. Verifique")
       Else
           cDatBas := BA3->BA3_DATBAS
       Endif
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Imprime arquivo texto inicial                                      Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       For nLinha := 1 To wLinIni
           nLi ++
           @ nLi,nColuna pSay MemoLine(wArqIni,98,nLinha)
       Next

       TRB->(DbSkip())

   Endif       

   If  TRB->TIPREG   == '2'
       nLi ++     
       nLi ++     
       @ nLi, nColuna pSay "Parcela  Vencimento    Valor do Titulo" 
       nLi ++
       @ nLi, nColuna pSay "-------  ------------  ---------------" 
             
       While ! TRB->(Eof()) .And. TRB->TIPREG   == '2'
          PRIVATE pVlr    := "@E 9,999,999,999,999.99" 
          PRIVATE nVlrInt := Val(Subs(TRB->RESTO, 17					,nTamVal-nDecVal))
          PRIVATE nVlrDec := Val(Subs(TRB->RESTO, 17+(nTamVal-nDecVal)	,nDecVal))
          PRIVATE nValor  := nVlrInt+(nVlrDec*0.01)

          nLi ++
          @ nLi, nColuna pSay Subs(TRB->RESTO,01,02)+"-"+Subs(TRB->RESTO,03,04)+Space(03)+;
                              Subs(TRB->RESTO,07,10)+ Space(04)+ AllTrim(Transform(nValor,pVlr))
                                        
          TRB->(DbSkip())
       Enddo
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Imprime arquivo texto final                                        Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nLi ++
   For nLinha := 1 To wLinFim
       nLi ++
       @ nLi,nColuna pSay MemoLine(wArqFim,98,nLinha)
   Next
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Pula para proxima pagina...                                        Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nLi := nLiIni
     
   If  TRB->TIPREG   == '9'
       TRB->(DbSkip())
       Loop
   Endif
      
Enddo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lautoSt .ANd. aReturn[5] == 1
    Set Printer To
    Ourspool(cRel)
Endif


Return 
