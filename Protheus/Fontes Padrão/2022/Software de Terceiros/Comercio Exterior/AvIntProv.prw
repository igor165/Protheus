//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: AvTitProv
//Autor.....: Alex Wallauer (AWR)
//Data......: 01 de Junho de 2011
//Uso.......: SIGAEIC   
//Versao....: Protheus - P11
//------------------------------------------------------------------------------------//
#include "Average.ch"

#Define PROVISORIOS "PROVISORIOS"

*==========================================================================================*
Class AvTitProv From AvObject//Objeto para cada titulo
*==========================================================================================*
   
   Data nRecNo
   Data cTipo
   Data lEmbarque
   Data cOpcEnv
   
   Data cPoNum
   Data cHawb
   Data cProforma
   Data cFornecedor
   Data cLoja
   Data cInvoice
   Data cDespesa
   Data cNatureza
   
   Data dEmissao
   Data dVencimento
   Data cMoeda
   Data nValor
   
   Data cChave
   Data nOrd
   Data cSQLChv 
   Data cError
   Data cWarning   
   
*---------------------------------*
   Method New()
   Method GravaEW7()
   Method ExcluiEW7()  
*---------------------------------*
   
EndClass

*==========================================================================================*
Class AvIntProv From AvObject//Objeto para os Objetos de cada titulo
*==========================================================================================*
   
   Data aProvDel
   Data aProvInc
   
   Data aGravar
   Data aDeletar
   Data cError
   Data cWarning

*---------------------------------*
   Method New()       //Chamado do EICFI400.PRW - cParamIXB == "ANT_GRV_PO" - cParamIXB == "ANT_GRV_DI"
   Method DelAllProv()//Chamado do EICFI400.PRW - cParamIXB == "ANT_GRV_PO" - cParamIXB == "ANT_GRV_DI" - cParamIXB == "POS_GRV_DI"
   Method GeraProv()  //Chamado do EICFI400.PRW - FI400_POSPO() e AVFLUXO.PRW - AVPOS_PO() - AVPOS_DI()
   Method Grava()     //Chamado do EICFI400.PRW - cParamIXB == "POS_GRV_PO" - cParamIXB == "POS_GRV_DI"
   Method CarregaProvDel()
   Method BuscaMuro()
   Method LimpaMuro()
   Method EnviaMuro()
   Method DelDespProv()//tratar exclusão individual de PRE, quando habilitado o cenário
   Method CarregaDespDel() 
*---------------------------------*
   
EndClass

*==========================================================================================*
//Chamado do EICFI400.PRW - cParamIXB == "ANT_GRV_PO" - cParamIXB == "ANT_GRV_DI"
Method New() Class AvIntProv
*==========================================================================================*
_Super:New()

::cClassName := "AvIntProv"

::aProvDel := {}
::aProvInc := {}

::aGravar  := {}
::aDeletar := {}

::cError   := ""
::cWarning := ""

Return Self

*==========================================================================================*
//Chamado do EICFI400.PRW - cParamIXB == "ANT_GRV_PO" - cParamIXB == "ANT_GRV_DI" - cParamIXB == "POS_GRV_DI"
Method DelAllProv(cPoNum, cHawb, cTipo) Class AvIntProv
*==========================================================================================*
If !Empty(cPoNum)
   cChave := xFilial("EW7")+AvKey(cTipo,"EW7_TPTIT")+AvKey(cPoNum,"EW7_PO_NUM")//Ordem 1
   ::CarregaProvDel(cChave,1)
EndIf

If !Empty(cHawb)
   cChave := xFilial("EW7")+AvKey(cTipo,"EW7_TPTIT")+AvKey(cHawb,"EW7_HAWB")//Ordem 2
   ::CarregaProvDel(cChave,2)
EndIf

Return Nil

/*==========================================================================================*/
/* Tratamento de exclusão de despesa provisória específica.
/* Montagem da chave de busca.
/*==========================================================================================*/
Method DelDespProv(cPoNum, cHawb, cTipo, cDesp) Class AvIntProv

If !Empty(cPoNum)
   cChave := xFilial("EW7")+AvKey(cTipo,"EW7_TPTIT")+AvKey(cPoNum,"EW7_PO_NUM")//Ordem 1
   ::CarregaDespDel(cChave, 1, cDesp)
EndIf

If !Empty(cHawb)
   cChave := xFilial("EW7")+AvKey(cTipo,"EW7_TPTIT")+AvKey(cHawb,"EW7_HAWB")//Ordem 2
   ::CarregaDespDel(cChave, 2, cDesp)
EndIf

Return Nil

*==========================================================================================*
Method CarregaProvDel(cChave,nOrder) Class AvIntProv//Chamada do Method DelAllProv(cPoNum, cHawb, cTipo) Class AvIntProv
*==========================================================================================*
Local nOldOrd := EW7->(IndexOrd())

EW7->(dbSetOrder(nOrder))
EW7->(dbSeek(cChave))
Do While EW7->( !Eof() .AND. Left(&(IndexKey()),Len(cChave)) == cChave )
   
   EW7->(aAdd( ::aProvDel , AvTitProv():New(.T.) ))
   EW7->(dbSkip())

EndDo

EW7->(dbSetOrder(nOldOrd))

Return Nil

/*==========================================================================================*/
/* Quando a despesa provisória existir, adiciona-a no array para ser excluída.
/* Chamada do Method DelDespProv() Class AvIntProv
/*==========================================================================================*/
Method CarregaDespDel(cChave, nOrder, cDesp) Class AvIntProv
Local aOrd := SaveOrd({"EW7"})
 
EW7->(DBSetOrder(nOrder))
EW7->(DBSeek(cChave))
Do While EW7->( !Eof() .AND. Left(&(IndexKey()),Len(cChave)) == cChave )
   
   If EW7->EW7_DESPES == AvKey(cDesp, "EW7_DESPES")
      EW7->(aAdd( ::aProvDel , AvTitProv():New(.T.) ))
      Exit
   EndIf
   
   EW7->(DBSkip())

EndDo

RestOrd(aOrd)
Return Nil

*====================================================================================================================================================================*
//Class AvTitProv
Method New(lEW7,nValor,dEmissao,dDataVenc,cSimbMoeda,cTipo,nParcela,cFornece,cLoja,cHistor,cHAWB,cPoNum,cDespesa,nRecNo,cProforma,cInvoice,cNatureza) Class AvTitProv
*====================================================================================================================================================================*
//Local nOldW2Rec, nOldW2Ord

_Super:New()

::cError   := ""
::cWarning := ""
::cClassName := "AvTitProv"

If lEW7
   dbSelectArea("EW7")
   Default nValor     := EW7_VALOR
   Default dEmissao   := EW7_DT_EMI
   Default dDataVenc  := EW7_DT_VEN
   Default cSimbMoeda := EW7_MOEDA
   Default cTipo      := EW7_TPTIT
   Default nParcela   := 1
   Default cFornece   := EW7_FORN
   Default cLoja      := EW7_LOJA
   Default cHistor    := ""
   Default cHAWB      := EW7_HAWB
   Default cPoNum     := EW7_PO_NUM
   Default cDespesa   := EW7_DESPES
   Default cInvoice   := EW7_INVOIC
   Default cProforma  := EW7_PROFOR
   Default cNatureza  := ""
   Default nRecNo     := RecNo()
EndIf

::ValidaParam(@nValor,"N",0)
::ValidaParam(@dEmissao,"D",dDataBase)
::ValidaParam(@dDataVenc,"D",dDataBase)
::ValidaParam(@cSimbMoeda,"C","R$")
::ValidaParam(@cTipo,"C","")
::ValidaParam(@nParcela,"N",1)
::ValidaParam(@cFornece,"C","")
::ValidaParam(@cLoja,"C","")
::ValidaParam(@cHistor,"C","")
::ValidaParam(@cHAWB,"C","")
::ValidaParam(@cPoNum,"C","")
::ValidaParam(@cDespesa,"C","")
::ValidaParam(@cInvoice,"C","")
::ValidaParam(@cProforma,"C","")
::ValidaParam(@cNatureza,"C","")
::ValidaParam(@nRecNo,"N",0)

If !Empty(::cError)
   //ERRO COM OS PARAMETROS
   Return .F.
EndIf

::nRecNo      := nValor
::cTipo       := AvKey(cTipo,"EW7_TPTIT")
::lEmbarque   := !Empty(cHAWB)
::cPoNum      := AvKey(cPoNum,"EW7_PO_NUM")
::cHawb       := AvKey(cHAWB,"EW7_HAWB")
::cProforma   := AvKey(cProforma,"EW7_PROFOR")
/*
If !::lEmbarque .AND. !Empty(::cPoNum)
   IF Empty(cProforma)
      SW2->(nOldW2Ord := IndexOrd(),nOldW2Rec := RecNo())
      If SW2->(dbSetOrder(1),dbSeek(xFilial("SW2")+::cPoNum))
         ::cProforma := SW2->W2_NR_PRO
      EndIf
      SW2->(dbSetOrder(nOldW2Ord),dbGoTo(nOldW2Rec))
   EndIf
Else
   ::cProforma   := AvKey("","EW7_PROFOR")
EndIf
*/
/* wfs 08/08 - não permitir que o vencimento seja menor que a data de emissão. */
If AvFlags("EIC_EAI")

   dEmissao:= dDataBase //no logix, a emissão não pode ser diferente da data base.

   If dDataVenc < dEmissao
      dDataVenc:= dEmissao
   EndIf

EndIf

::cFornecedor := AvKey(cFornece,"EW7_FORN")
::cLoja       := AvKey(cLoja,"EW7_LOJA")
::cInvoice    := AvKey(cInvoice,"EW7_INVOIC")
::cDespesa    := AvKey(cDespesa,"EW7_DESPES")
::cNatureza   := cNatureza
::dEmissao    := dEmissao
::dVencimento := dDataVenc
::cMoeda      := AvKey(cSimbMoeda,"EW7_MOEDA")
::nValor      := nValor
::nRecNo      := nRecNo
::cOpcEnv     := ""

::nOrd   := 1
//::cChave := ::cTipo+::cHawb+::cPoNum+::cFornecedor+::cLoja+::cDespesa+DToS(::dVencimento)+::cMoeda
::cChave := ::cTipo+::cPoNum+::cHawb+::cFornecedor+::cLoja+::cDespesa+DToS(::dVencimento)+::cMoeda
::cSQLChv:= "EW7_FILIAL = '"+xFilial("EW7")+     "' AND "+;
            "EW7_TPTIT  = '"+::cTipo+            "' AND "+;
            "EW7_PO_NUM = '"+::cPoNum+           "' AND "+;
            "EW7_HAWB   = '"+::cHawb+            "' AND "+;
            "EW7_FORN   = '"+::cFornecedor+      "' AND "+;
            "EW7_LOJA   = '"+::cLoja+            "' AND "+;
            "EW7_DESPES = '"+::cDespesa+         "' AND "+;
            "EW7_DT_VEN = '"+DToS(::dVencimento)+"' AND "+;
            "EW7_MOEDA  = '"+::cMoeda+           "' "

Return Self

*====================================================================================================================================================================*
//Chamado do EICFI400.PRW - FI400_POSPO() e AVFLUXO.PRW - AVPOS_PO() - AVPOS_DI()
Method GeraProv(nValor,dEmissao,dDataVenc,cSimbMoeda,cTipo,nParcela,cFornece,cLoja,cHistor,cHAWB,cPoNum,cDespesa,cProforma,cInvoice,cNatureza) Class AvIntProv
*====================================================================================================================================================================*
aAdd(::aProvInc,AvTitProv():New(.F.,nValor,dEmissao,dDataVenc,cSimbMoeda,cTipo,nParcela,cFornece,cLoja,cHistor,cHAWB,cPoNum,cDespesa, 0 ,cProforma,cInvoice, cNatureza))

Return nil

*==========================================================================================*
//Chamado do EICFI400.PRW - cParamIXB == "POS_GRV_PO" - cParamIXB == "POS_GRV_DI"
Method Grava() Class AvIntProv
*==========================================================================================*
LOCAL cTipEnv,cPedido,cProcesso
LOCAL cCodPROV   :=EasyGParam('MV_EICFI09',,'')//Código da integração p/ Títulos das Despesas Provisórias (via AVINTEG)
LOCAL oIntegracao//:=AVINTEG():New(cCodPROV)//Ativa a interface de ENVIO uma vez para todos os metodos usarem    
LOCAL I,T,lOK := .T.

IF !AvFlags("EIC_EAI")
   oIntegracao:= EasyExRdm("AVINTEG():New", cCodPROV) //Ativa a interface de ENVIO uma vez para todos os metodos usarem    
ENDIF

If Len(::aGravar) == 0 .AND. Len(::aDeletar) == 0
   ::aGravar  := ACLONE(::aProvInc)
   ::aDeletar := ACLONE(::aProvDel)
EndIf

IF Len(::aDeletar) > 0

   aTipoEnvia:={}

      For i := 1 To Len(::aDeletar)
         IF ASCAN(aTipoEnvia,{|T| T[1]+T[2]+T[3] == (::aDeletar[I]:cTipo+::aDeletar[I]:cPoNum+::aDeletar[I]:cHawb) }) = 0
            AADD(aTipoEnvia,{::aDeletar[I]:cTipo,::aDeletar[I]:cPoNum,::aDeletar[I]:cHawb} )//PR e PRE
         ENDIF      
      Next i

   IF !AvFlags("EIC_EAI")
      FOR T := 1 TO LEN(aTipoEnvia)
         cTipEnv  := aTipoEnvia[T,1]//PR e PRE
         cPedido  := aTipoEnvia[T,2]//Pedido
         cProcesso:= aTipoEnvia[T,3]//Processo
 
         cSQLChv:= "CDEMPR = '"+SM0->M0_CODIGO+"' AND "+;
                   "CDFILI = '"+xFilial("EW7")+"' AND "+;
                   "CDFASE = '"+"DPV"/*cTipEnv*/+       "' AND "+; //Alterado por AOM - 25/04/2012 - A tabela de muro sempre a Fase dos titulos provisório é DPV
                   "NUMPED = '"+cPedido+       "' AND "+;
                   "NRHAWB = '"+cProcesso+     "'"

         ::BuscaMuro(cSQLChv,," Filial: "+xFilial("EW7")+", Tipo: "+cTipEnv+", PO: "+cPedido+", Processo: "+cProcesso) //Executa o recebimento dos titulos só desse pedido/processo  TEM TELA

         cSQLimpa:= cSQLChv+" AND ( (FLAG   = 'N' AND TPINTG <> 'E') OR (TITERP = ' ' AND TITGER = ' ') )"
 
         ::LimpaMuro(cSQLimpa,oIntegracao)//Deleta do muro tudo que nao foi gerado titulo, só desse pedido/processo

         cChave   := cTipEnv+cPedido+cProcesso
         cSQLEnvia:= "EW7_FILIAL = '"+xFilial("EW7")+"' AND "+;
                     "EW7_TPTIT  = '"+cTipEnv+       "' AND "+;
                     "EW7_PO_NUM = '"+cPedido+       "' AND "+;
                     "EW7_HAWB   = '"+cProcesso+     "' AND "+;
                     "EW7_TITERP <> ' '                 AND "+;
                     "EW7_CTRERP <> 'ENVIADO EXC' "//Só para prevenir

         oIntegracao:SetProp(oIntegracao:GetOrder("01.00"),"TITULO","Envia Exclusao: "+" Filial: "+xFilial("EW7")+", Tipo: "+cTipEnv+", PO: "+cPedido+", Processo: "+cProcesso)

         ::EnviaMuro("E",cChave,cSQLEnvia,oIntegracao)//Envia para o muro os titulos para excluir, se tiver, só desse pedido/processo TEM TELA
      NEXT T

   ELSE //AvFlags("EIC_EAI")

      IF !EICFI410(.T.,5,::aDeletar)
         lOK := .F.
      ENDIF

   ENDIF

   IF lOK
      For i := 1 To Len(::aDeletar)
          ::aDeletar[i]:ExcluiEW7()//Method ExcluiEW7() Class AvTitProv 
      Next i
   ENDIF
   
ENDIF

IF Len(::aGravar) > 0 .AND. lOK

   aTipoEnvia:={}

   For i := 1 To Len(::aGravar)
       ::aGravar[i]:GravaEW7()//Grava no EW7 
       IF ASCAN(aTipoEnvia,{|T| T[1]+T[2]+T[3] == (::aGravar[I]:cTipo+::aGravar[I]:cPoNum+::aGravar[I]:cHawb)} ) = 0
          AADD(aTipoEnvia,{::aGravar[I]:cTipo,::aGravar[I]:cPoNum,::aGravar[I]:cHawb} )//PR e PRE
       ENDIF      
   Next i

   IF AvFlags("EIC_EAI") 
      EICFI410(.T.,3,::aGravar)
   ENDIF

   IF !AvFlags("EIC_EAI")
      FOR T := 1 TO LEN(aTipoEnvia)
         cTipEnv  := aTipoEnvia[T,1]//PR e PRE
         cPedido  := aTipoEnvia[T,2]//Pedido
         cProcesso:= aTipoEnvia[T,3]//Processo

         cChave := cTipEnv+cPedido+cProcesso
         cSQLChv:= "EW7_FILIAL = '"+xFilial("EW7")+"' AND "+;
                   "EW7_TPTIT  = '"+cTipEnv+       "' AND "+;
                   "EW7_PO_NUM = '"+cPedido+       "' AND "+;
                   "EW7_HAWB   = '"+cProcesso+     "' AND "+;
                   "EW7_TITERP = ' ' "

         oIntegracao:SetProp(oIntegracao:GetOrder("01.00"),"TITULO","Envia Inclusao: "+" Filial: "+xFilial("EW7")+", Tipo: "+cTipEnv+", PO: "+cPedido+", Processo: "+cProcesso)
         ::EnviaMuro("I",cChave,cSQLChv,oIntegracao)//Envia para o muro para o ERP do cliente ler TEM TELA
      NEXT T
   ENDIF   
ENDIF

If !Empty(::cError)
   ::ShowErrors(.T.)
   Return .F.
EndIf


Return .T.

*==========================================================================================*
Method BuscaMuro(cSQLChv,oIntRecebe,cTitulo) Class AvIntProv
*==========================================================================================*
Local cCodPROV := "RETORNO.TITERP.TIT.PROVISORIOS"//EasyGParam('MV_EICFIXX',,'')//RETORNO.TITERP.TIT.PROVISORIOS, O Alexandre Costa ficou de cria um MV_EICFIXX
IF VALTYPE(oIntRecebe) # "O" .OR. UTrim(oIntRecebe:GetInterf()) # cCodPROV 
   oIntRecebe := EasyExRdm("AVINTEG():New", cCodPROV)      
ENDIF
//oIntRecebe:LEXIBEPREVIA := .T.
oIntRecebe:SetProp(oIntRecebe:GetOrder("01.00"),"TITULO","Busca Muro: "+cTitulo)
oIntRecebe:ProcInteg(cSQLChv)

RETURN .T.

*==========================================================================================*
Method LimpaMuro(cSQLChv,oIntEnvia) Class AvIntProv
*==========================================================================================*
Local cCodPROV := EasyGParam('MV_EICFI09',,'')//Código da integração p/ Títulos das Despesas Provisórias (via AVINTEG)
IF VALTYPE(oIntEnvia) # "O" .OR. UTrim(oIntEnvia:GetInterf()) # cCodPROV
   oIntEnvia := EasyExRdm("AVINTEG():New", cCodPROV)      
ENDIF
//oIntEnvia:lGeraQRYLOG:=.F.
oIntEnvia:DeleteReg(cSQLChv,"01.00")

RETURN .T.

*==========================================================================================*
//Class AvTitProv
Method GravaEW7() Class AvTitProv
*==========================================================================================*

   EW7->(RecLock("EW7",.T.))
   EW7->EW7_FILIAL := xFilial("EW7")
   EW7->EW7_TPTIT  := ::cTipo

   EW7->EW7_PO_NUM := ::cPoNum
   EW7->EW7_PROFOR := ::cProforma

   EW7->EW7_HAWB   := ::cHAWB
   EW7->EW7_FORN   := ::cFornecedor
   EW7->EW7_LOJA   := ::cLoja

   EW7->EW7_INVOIC := ::cInvoice
   EW7->EW7_DESPES := ::cDespesa
   EW7->EW7_DT_EMI := ::dEmissao
   EW7->EW7_DT_VEN := ::dVencimento
   EW7->EW7_MOEDA  := ::cMoeda
   
   If EW7->(FieldPos("EW7_NATFIN")) > 0
      EW7->EW7_NATFIN := ::cNatureza
   EndIf

   EW7->EW7_VALOR  := ::nValor
   
   If EW7->(FieldPos("EW7_SEQ")) > 0
        EW7->EW7_SEQ    := EW7ProxSeq(::cHAWB,::cPoNum,::cProforma,::cTipo,::cFornecedor,::cLoja,::cDespesa) //THTS - 31/08/2017 - Busca a Proxima Sequencia para o campo EW7_SEQ
   EndIf 

   EW7->(MsUnLock())
   
   //ENVIA INCLUSAO
   ::nRecNo := EW7->(RecNo())
   ::cOpcEnv:= "I"

Return nil

*==========================================================================================*
//Class AvTitProv
Method ExcluiEW7() Class AvTitProv
*==========================================================================================*
EW7->(dbSetOrder(1))
EW7->(dbSeek(xFilial("EW7")+::cChave))
Do While EW7->( !Eof() .AND. Left(&(IndexKey()),Len(xFilial("EW7")+Self:cChave)) == Left(xFilial("EW7")+Self:cChave,Len(EW7->&(IndexKey()))) ) //AOM - 20/04/2012 - Comparar a chave de acordo com o Indice pois a chave é maior que o indice.
   
   If EW7->EW7_DESPES <> ::cDespesa .Or. !Empty(EW7->EW7_TITERP)//NCF - 05/11/2016 - Não Apagar Despesas que possuem número de título (falha na integração - título permanece no ERP Externo) 
      EW7->(DBSkip())
      Loop
   EndIf
   
   EW7->(RecLock("EW7",.F.,.T.))
   EW7->(dbDelete())
   EW7->(MsUnLock())
   EW7->(dbSkip())

EndDo

Return .T.

*==========================================================================================*
//Class AvIntProv
Method EnviaMuro(cTipo,cChave,cSQLChv,oIntEnvia) Class AvIntProv
*==========================================================================================*

If FindFunction("EICINTEI17")
   EasyExRdm("EICINTEI17", cTipo,"DPV",cChave,,cSQLChv,oIntEnvia)   
EndIf

Return .T.

*==========================================================================================*
Function AvProvRecalc(cPoNum,cHawb)//Chamada da AVINTDESP.PRW no Method Envia(nOpc, nReg) Class AvIntDesp
*==========================================================================================*
Private lRecalcProv := .T.

If !Empty(cHawb)
   
   SW6->(dbSetOrder(1))
   If SW6->(dbSeek(xFilial("SW6")+cHawb))
      Private Inclui      := .F.
      Private M->W6_HAWB  := cHawb
   
      EICFI400("ANT_GRV_DI")
      EICFI400("POS_GRV_DI")
   EndIf

ElseIf !Empty(cPoNum)
   
   SW2->(dbSetOrder(1))
   If SW2->(dbSeek(xFilial("SW2")+cPoNum))
      Private M->W2_PO_NUM := cPoNum
   
      EICFI400("ANT_GRV_PO")
      EICFI400("POS_GRV_PO")
   EndIf
   
EndIf

Return Nil

*==========================================================================================*
Function AvProvKill(cPoNum,cHawb)//Chamada da AVINTDESP.PRW no Method Manut(cAlias, nReg, nOpc) Class AvIntDesp
*==========================================================================================*

If !Empty(cHawb)
   
   SW6->(dbSetOrder(1))
   If SW6->(dbSeek(xFilial("SW6")+cHawb))
      If AvFlags("AVINT_PRE_EIC")
         oIntProv := AvIntProv():New()
         oIntProv:DelAllProv(,cHawb,"PRE")
         oIntProv:Grava()
      EndIf
   EndIf

ElseIf !Empty(cPoNum)
   
   SW2->(dbSetOrder(1))
   If SW2->(dbSeek(xFilial("SW2")+cPoNum))      
      If AvFlags("AVINT_PR_EIC") .OR. AvFlags("AVINT_PRE_EIC") //AOM - 23/04/2012 - O titulo PR é gerado quando o parametro de geração de titulos no embarque esta habilitado.
         oIntProv := AvIntProv():New()      
         oIntProv:DelAllProv(cPoNum,,"PR")
         oIntProv:Grava()
      EndIf
   EndIf
   
EndIf

Return Nil


/*
Funcao    ³ EW7ProxSeq
Autor     ³ Tiago Henrique Tudisco dos Santos - THTS
Data      ³ 31/08/2017
Descricao ³ Retorna a proxima sequencia para o campo EW7_SEQ
*/
Static Function EW7ProxSeq(cW7HAWB,cW7PoNum,cW7Proform,cW7Tipo,cW7Fornece,cW7Loja,cW7Despesa)
Local cRet      := StrZero(1,AvSx3("EW7_SEQ",AV_TAMANHO))
Local cQuery    := ""

cQuery := " SELECT MAX(EW7_SEQ) EW7_SEQ "
cQuery += " FROM " + RetSQLName("EW7") + " "
cQuery += " WHERE EW7_FILIAL	= '" + xFilial("EW7")   + "' "

If "EW7_PO_NUM+EW7_HAWB" $ FWX2Unico("EW7")

    cQuery += "   AND EW7_HAWB		= '" + cW7HAWB          + "' "
    cQuery += "   AND EW7_PO_NUM	= '" + cW7PoNum         + "' "

EndIf
//cQuery += "   AND EW7_PROFOR	= '" + cW7Proform       + "' "
cQuery += "   AND EW7_TPTIT		= '" + cW7Tipo          + "' "
cQuery += "   AND EW7_FORN		= '" + cW7Fornece       + "' "
cQuery += "   AND EW7_LOJA		= '" + cW7Loja          + "' "
cQuery += "   AND EW7_DESPES	= '" + cW7Despesa       + "' "
cQuery += "   AND D_E_L_E_T_	= ' '

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPEW7SEQ", .T., .T.)
TcSetField("TMPEW7SEQ","EW7_SEQ","C", AVSX3("EW7_SEQ",AV_TAMANHO), AVSX3("EW7_SEQ",AV_DECIMAL))

If TMPEW7SEQ->(!EOF())
    cRet := StrZero(Val(TMPEW7SEQ->(EW7_SEQ)) + 1,AvSx3("EW7_SEQ",AV_TAMANHO)) //Gera a proxima Sequencia
EndIf

TMPEW7SEQ->(dbCloseArea())

Return cRet