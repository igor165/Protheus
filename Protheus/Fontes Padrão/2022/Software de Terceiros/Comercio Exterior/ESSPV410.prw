#INCLUDE "PROTHEUS.CH"
#include "average.ch"

//nOpc
#Define INCLUIR 3
#Define EXCLUIR 5
#Define CANCELAR 10

/*
Programa : ESSPV410.PRW
Autor    : WFS
Data     : jul/2015
Objetivo : Adapter para processamento do processo de venda de servi�os (integra��o EAI)
*/

/*
Fun��o   : ESSPV410
Autor    : WFS
Data     : jul/2015
Objetivo : Criticar as parametriza��es para integra��o do processo de venda via EAI.
Revis�o  :
*/
*--------------------------------------------------------------------
Function ESSPV410()
*--------------------------------------------------------------------
Local lRet:= .T.

Begin Sequence

   /* A mensagem ser� exibida apenas quando estiver desabilitada a integra��o do EEC com Logix,
      caso contr�rio, teremos um retorno de mensagem sempre que n�o houver itens de servi�o na
      mensagem. */
   If !AvFlags("ESS_EAI")
      If !AvFlags("EEC_LOGIX")
         EasyHelp("A integra��o com o Easy Siscoserv n�o est� habilitada. Verifique o par�metro MV_ESS_EAI.", "Aten��o")
      EndIf
      lRet:= .F.
      Break
   EndIf

End Sequence

Return lRet

/*
Fun��o     : PV410RECEB
Autor      : WFS
Data       : jul/2015
Objetivo   : Processar o recebimento da mensagem SALESORDER para a cria��o do processo
             de venda de servi�o.
Par�metros : oMessage - mensagem
Retotno    : oExecAuto - dados para execu��o da rotina autom�tica
Revis�o    :
*/
Function PV410RECEB(oMessage)
Local oBusinessCont  := oMessage:GetMsgContent()
Local oInformation   := oMessage:GetMsgInfo()
Local oCapa          := ERec():New()
Local oItens         := ETab():New()
Local oParams        := ERec():New()
Local oExecAuto      := EExecAuto():New()
Local i, nCont, nQuant //as Integer
Local oItServ
Local cOrigem, cNumProc, cPaymentTermCode, cCurrencyCode //as caracter
Local aListItens //as Array

Begin Sequence

   oParams:SetField("cMainAlias", "EJW")
   oParams:SetField("bFunction" , {|oEasyMessage| ESSPV400(oEasyMessage:GetEAutoArray("EJW"),;
                                                           oEasyMessage:GetEAutoArray("EJX"),,;
                                                           oEasyMessage:GetOperation())})

   /* Capa do processo */
   oCapa:SetField("EJW_TPPROC" , "V") //Processo de venda de servi�o

   cOrigem := oInformation:_PRODUCT:_NAME:TEXT
   oCapa:SetField("EJW_ORIGEM", Upper(cOrigem))

   cNumProc := EasyGetXMLinfo('EJW_PROCES', oBusinessCont, "_OrderId")   //EJW_PROCES/ EJX_PROCES
   oCapa:SetField("EJW_PROCES", cNumProc)

   oCapa:SetField("EJW_IMPORT", EasyGetXMLinfo("EJW_IMPORT", oBusinessCont, "_CustomerCode"))                                    
   oCapa:SetField("EJW_LOJIMP", AvKey(".", "EJW_LOJIMP"))
                                    
   cPaymentTermCode:= EasyGetXMLinfo("EJW_CONDPG", oBusinessCont, "_PaymentTermCode")
   SE4->(DBSetOrder(1)) //E4_FILIAL+E4_CODIGO
   If !Empty(cPaymentTermCode) .And. SE4->(DBSeek(xFilial() + AvKey(cPaymentTermCode, "E4_CODIGO")))
      oCapa:SetField("EJW_CONDPG", cPaymentTermCode)                   
   EndIf

   oCapa:SetField("EJW_DTPROC", EasyGetXMLinfo("EJW_DTPROC", oBusinessCont, "_RegisterDate"))

   /* dhini    := EasyGetXMLinfo("EJX_DTPRIN", oBusinessCont, "_dhinidelivery")
   dhfin    := EasyGetXMLinfo("EJX_DTPRF", oBusinessCont, "_dhfindelivery") */

   cCurrencyCode:= EasyGetXMLinfo("EJW_MOEDA", oBusinessCont, "_CurrencyCode")
   cCurrencyCode:= BuscaMoe(cCurrencyCode)
   oCapa:SetField("EJW_MOEDA", cCurrencyCode)

   /* Quando o status for 7, executar o cancelamento do processo de venda. */
   If !Empty(EasyGetXMLinfo(,oBusinessCont, "_Status")) .And. Val(EasyGetXMLinfo(,oBusinessCont, "_Status")) == 7
      oParams:AddField("nOpc", CANCELAR)
      oCapa:SetField("EJW_STTPED", '5')
      oCapa:SetField("EJW_COMPL", EJW->EJW_COMPL + Chr(13) + chr(10) + 'Cancelado no ERP em: ' + DtoC(dDataBase))
   ElseIf AllTrim(Upper(oMessage:GetBsnEvent())) == "DELETE" .Or. lExcluiProc
      /* Se o evento enviado na mensagemm for DELELETE ou se n�o houver itens para um processo existente,
         define a opera��o de exclus�o, a menos que seja uma mensagem de cancelamento. */
      oParams:AddField("nOpc", EXCLUIR)
   EndIf

   /* Itens do processo */
   If IsCpoInXML(oBusinessCont, "_SalesOrderItens")
      aListItens:= oBusinessCont:_SalesOrderItens:_ITEM
      If ValType(aListItens) <> "A"
         aListItens:= {aListItens}
      EndIf
   Else
      aListItens:= {}
   EndIf

   nCont:= 0
   For i:= 1 To Len(aListItens)

      /* Se n�o for item de servi�o, ser� descartado */
	  If AllTrim(Upper(EasyGetXMLinfo(, aListItens[i], "_TypeOperation"))) <> "S"
	     Loop
	  EndIf

      nCont++
      oItServ:= ERec():New()
      oItServ:SetField("EJX_TPPROC", "V") //Tipo do processo - venda de servi�o
      oItServ:SetField("EJX_PROCES", cNumProc)
      oItServ:SetField("EJX_SEQPRC", StrZero(nCont, AvSx3("EJX_SEQPRC", AV_TAMANHO)))
      oItServ:SetField("EJX_ITEM"  , EasyGetXMLinfo("EJX_ITEM", aListItens[i], "_ItemCode"))

      nQuant:= EasyGetXMLinfo("EJX_QTDE" , aListItens[i], "_Quantity")
      If Empty(nQuant)
         nQuant:= 1
      EndIf
      oItServ:SetField("EJX_QTDE"  , nQuant)
      oItServ:SetField("EJX_PRCUN" , EasyGetXMLinfo("EJX_PRCUN", aListItens[i], "_UnityPrice"))
      oItServ:SetField("EJX_VL_MOE", EasyGetXMLinfo("EJX_VL_MOE", aListItens[i], "_TotalPrice"))

      //oItServ:SetField("EJX_UM", EasyGetXMLinfo("EJX_UM", aListItens[i], "_itemunitofmeasure"))
      //oItServ:SetField("EJX_DTPRIN", )
      //oItServ:SetField("EJX_DTPRFI", )
   
      oItens:AddRec(oItServ)
   Next

   oExecAuto:SetField("PARAMS", oParams)
   oExecAuto:SetField("EJW"   , oCapa)
   oExecAuto:SetField("EJX"   , oItens) 

End Sequence

Return oExecAuto


/*
Fun��o     : BuscaMoe
Autor      : AWF
Data       : 10/07/2014
Objetivo   : Buscar a moeda do ERP no cadastro de moedas do m�dulo ESS
Par�metros : cMoeda - recebida na mensagem
Retotno    : cMoeda - c�digo do ERP
Revis�o    :
*/

STATIC FUNCTION BuscaMoe(cMoeda)

SYF->(DBSETORDER(5))//YF_FILIAL+YF_CODVERP
IF SYF->(DBSEEK(xFilial()+cMoeda))//Se nao achar devolve a que veio
   cMoeda:= SYF->YF_MOEDA
ENDIF
SYF->(DBSETORDER(1))//YF_FILIAL+YF_CODVERP
Return cMoeda