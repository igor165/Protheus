#include "average.ch"
#include "TOTVS.ch"
#include "PROTHEUS.ch"
#include "TOPCONN.ch"
/*
Funcao     : EECAF233()
Parametros : Nenhum
Retorno    : .T
Objetivos  : - Fechamento de Contrato de Cambio - 
             Integracao do Fechamento de Contrato de Cambio para efetivacao da baixa de titulos em moeda estrangeira
Autor      : Bruno Akyo Kubagawa  - Baixa a Receber no Exterior
Data/Hora  : 10/01/2012
*/
Function EECAF233()
local lRet := .T.
Local nOpc := 3
Private aRotina   := MenuDef()

   if !Empty(TMP->EEQ_PGT)
      varinfo("LiquidaTitulo","Liquida")
      nOpc := 3
   elseif Empty(TMP->EEQ_PGT)
      varinfo("LiquidaTitulo","Estorna")
      nOpc := 5
   endif

   lRet := EasyEnvEAI("EECAF233",nOpc)

Return lRet


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF233Man" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF233Man" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF233Man" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF233Man" , 0 , 5}} //"Excluir"
        
Return aRotina


Function AF233Man(cAlias,nReg,nOpc)

Return Nil

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")
	oEasyIntEAI:SetModule("EEC",29) 
	//*** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF233ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF233ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	//***
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

Function AF233ASENB(oEasyMessage) 
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oRequest  := ENode():New()
Local oRec      := ENode():New()
Local aOrd      := SaveOrd({"EC6","EEQ"})
Local cEmpMsg   := SM0->M0_CODIGO
Local cFilMsg   := AvGetM0Fil() 
Local cParam, nPosDiv
Local oListAcRecDoc
Local oAcRecDoc
Local nDCEntryValue  := 0
Local nEntryValue := nVlrFCam := 0
Local lEstorno := empty(EEQ->EEQ_PGT)
Local cBanco,cAgencia,cConta,i
Local aTitVAl    := {}

If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0033",,"")) )
   If (nPosDiv := At('/',cParam)) > 0
      cEmpMsg := Substr(cParam,1,nPosDiv-1) 
      cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
   Else
      cEmpMsg := cParam 
      cFilMsg := cParam         
   EndIf  
EndIf

   nEAIRecNo:= EEQ->(RecNo())

   EC6->(DbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   EC6->(DbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey(EEQ->EEQ_EVENT,"EC6_ID_CAM")))

	//Lista de Títulos: Listar todas as parcelas de câmbio associadas a este contrato. - ListOfAccountReceivableDocument
   aEAIRecnos := MovExtTit({EEQ->EEQ_FILIAL,EEQ->EEQ_NROP,EEQ->EEQ_BANC,EEQ->EEQ_AGEN,EEQ->EEQ_NCON},Alltrim(str(nEAIRecNo)))
 
   // A parcela posicionada não é adicionada quando se estorna pagamento específico dela e há demais parcelas pagas no mesmo contrato de fechamento.
   If !lEstorno
      aadd(aEAIRecnos,{ nEAIRecNo, EEQ->(EEQ_FINNUM+EEQ_SEQBX), AF200VLFCam("EEQ") })
   Endif

   For i:=1 To Len(aEAIRecnos)
      If ( nPos := aScan( aTitVal, {|x|  x[1] == aEAIRecnos[i][2]  }) ) > 0
         aTitVal[nPos][2] += aEAIRecnos[i][3]
         aAdd(aTitVal[nPos][3],aEAIRecnos[i][1])            
      Else
         aAdd(aTitVal,{aEAIRecnos[i][2],aEAIRecnos[i][3],{ aEAIRecnos[i][1] },.F.})
      EndIf
   Next i

   if len(aTitVal) > 0
      oListAcRecDoc := ENode():New()
      for nPosDiv := 1 to len(aTitVal)
         EEQ->(dbgoto(aTitVal[nPosDiv][3][1]))         
         //AccountReceivableDocument
         nVlrFCam := aTitVal[nPosDiv][2]
         oAcRecDoc := ENode():New()            
         oAcRecDoc:SetField('CompanyInternalId'    ,cEmpMsg)                        //InternalId da Empresa|Filial do título
         oAcRecDoc:SetField('CompanyId'            ,cEmpMsg)
         oAcRecDoc:SetField('BranchId'             ,cFilMsg)
         oAcRecDoc:SetField('AccountReceivableDocumentInternalId' , EEQ->(recno())) //Identificador único do título a receber que foi baixado e corresponde ao lote do contrato de cambio
         oAcRecDoc:SetField('DocumentPrefix'       ,EEQ->EEQ_PREFIX)                //Prefixo (Série) do título
         oAcRecDoc:SetField('DocumentNumber'       ,EEQ->EEQ_FINNUM)                //Número do Título
         oAcRecDoc:SetField('DocumentParcel'       ,RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)),1,.T. ) ) //Parcela do Título - ORIGEM
         oAcRecDoc:SetField('DocumentTypeCode'     ,EEQ->EEQ_TPTIT)                 //Tipo do Título
         oAcRecDoc:SetField("DischargeSequence"    ,EEQ->EEQ_SEQBX)                 //Sequência da Baixa. Utilizado para estornar a baixa.
         oAcRecDoc:SetField("PaymentValue"         ,nVlrFCam )           //Valor do pagamento
         oListAcRecDoc:SetField("AccountReceivableDocument",oAcRecDoc)
         nEntryValue   += nVlrFCam 
         nDCEntryValue += nVlrFCam * EEQ->EEQ_TX
      next nPosDiv
   ElseIf lEstorno                                                                  //Adiciona no xml a parcela a ser estornada uma vez que ela é a única parcela ainda paga no contrato de fechamento.
      EEQ->(dbgoto(nEAIRecno))
      nVlrFCam := AF200VLFCam("EEQ")
      oListAcRecDoc := ENode():New()
      oAcRecDoc     := ENode():New()
      oAcRecDoc:SetField('CompanyInternalId'    ,cEmpMsg)
      oAcRecDoc:SetField('CompanyId'            ,cEmpMsg)
      oAcRecDoc:SetField('BranchId'             ,cFilMsg)
      oAcRecDoc:SetField('AccountReceivableDocumentInternalId' , EEQ->(recno()))
      oAcRecDoc:SetField('DocumentPrefix'       ,EEQ->EEQ_PREFIX)
      oAcRecDoc:SetField('DocumentNumber'       ,EEQ->EEQ_FINNUM)
      oAcRecDoc:SetField('DocumentParcel'       ,RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)),1,.T. ) ) //ORIGEM
      oAcRecDoc:SetField('DocumentTypeCode'     ,EEQ->EEQ_TPTIT)
      oAcRecDoc:SetField("DischargeSequence"    ,EEQ->EEQ_SEQBX)
      oAcRecDoc:SetField("PaymentValue"         ,nVlrFCam)
      oListAcRecDoc:SetField("AccountReceivableDocument",oAcRecDoc)
      nEntryValue   += nVlrFCam
      nDCEntryValue += nVlrFCam * EEQ->EEQ_TX
   Endif

   EEQ->(dbgoto(nEAIRecNo))
   oRequest:SetField("Operation", "EECAF233")
   if !lEstorno
      oRequest:SetField("Event" ,"upsert" )
   else
      if len(aTitVal) > 0
         oRequest:SetField("Event" ,"upsert" )
      else
         oRequest:SetField("Event" ,"delete" )
      endif
   endif

   oBusiness:SetField('InternalId'              ,EEQ->EEQ_NROP)                         //Identificação do Movimento Financeiro
   oBusiness:SetField('CompanyInternalId'       ,"")                                    //InternalId da Empresa|Filial do Movimento Financeiro 
   oBusiness:SetField('CompanyId'               ,cEmpMsg)                               //Identificação da Empresa do Movimento Financeiro
   oBusiness:SetField('BranchId'                ,cFilMsg)                               //Identificação da Filial do Movimento Financeiro
   oBusiness:SetField('ContractNumber'          ,EEQ->EEQ_NROP)                         //Número do contrato de câmbio
   oBusiness:SetField('ContractDate'            ,EasyTimeStamp(If(!lEstorno,EEQ->EEQ_DTNEGO,M->EEQ_DTNEGO),.T.,.T.))//Data de efetivação do contrato de câmbio
   
   SYF->(dbSetOrder(1),dbSeek(xFilial()+EEQ->EEQ_MOEDA))//YF_FILIAL+YF_MOEDA            //Identificador único da moeda da baixa
   If EC6->EC6_TXCV == "2" //COMPRA 
      oBusiness:SetField('CurrencyInternalId'   ,SYF->YF_CODCERP)
   Else                    //VENDA
      oBusiness:SetField('CurrencyInternalId'   ,SYF->YF_CODVERP)
   EndIf

   oBusiness:SetField('EntryValue'              ,str(nEntryValue))                      //Valor da Movimentação Financeira na moeda do contrato
   oBusiness:SetField('DefaultCurrencyEntryValue',Str(nDCEntryValue))                   //Valor da movimentação financeira na moeda padrão do sistema, já ajustado para evitar divergência de arredondamento
   oBusiness:SetField('CurrencyRate'            ,If(!lEstorno,EEQ->EEQ_TX,M->EEQ_TX))   //Taxa da moeda na efetivação do contrato

   cBanco  := EEQ->EEQ_BANC                                                             //NCF - 25/10/2019 - complemento dos dados bancários
   cAgencia:= EEQ->EEQ_AGEN
   cConta  := EEQ->EEQ_NCON
       
   SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
   If SA6->(DBSeek(xFilial() + cBanco + cAgencia + cConta))
      If !Empty(SA6->A6_DVAGE)
         cAgencia:= AllTrim(SA6->A6_AGENCIA) + "-" + SA6->A6_DVAGE 
      EndIf
      If !Empty(SA6->A6_DVCTA)
         cConta:= AllTrim(SA6->A6_NUMCON) + "-" + SA6->A6_DVCTA 
      EndIf      
   EndIf

   oBusiness:SetField('BankInternalId'          ,cBanco)                                 //Identificador de Integração do Banco do Movimento Financeiro
   oBusiness:SetField('Agency'                  ,cAgencia)                               //Número de identificação da agência bancária onde ocorreu o movimento bancário
   oBusiness:SetField('NumberAccount'           ,cConta)                                 //Número de identificação da conta bancária onde ocorreu o movimento bancário.
   oBusiness:SetField('MovementDate'            ,EasyTimeStamp(EEQ->EEQ_PGT,.T.,.T.))    //Data da Movimentação Financeira EEQ_PGT
   oBusiness:SetField('DocumentType'        ,"2"/*EEQ->EEQ_TPTIT*/)                      //NCF - 25/10/2019 - No Xsd a tag é 'DocumentType' e o valor fixo 2 conforme alinhado com Rafael silva (TOTVS - Joinville)
   //oBusiness:SetField('DocumentNumber'          ,EEQ->EEQ_FINNUM)                        //Número do Documento que Originou o Movimento: Enviar o número do título EEQ_FINNUM
   oBusiness:SetField('BatchNumber'             ,EEQ->EEQ_INTERN)                        ////Número do Lote (É utilizado para modificação ou exclusão)
   oBusiness:SetField("ListOfAccountReceivableDocument",oListAcRecDoc)                   // LISTA DOS TÍTULOS BAIXADOS A SER ENVIADOS PARA O LOGIX COM O MESMO CONTRATO DE CÂMBIO
   //oBusiness:SetField('FinancialCode'           ,EC6->EC6_NATFIN)                        //<FinancialCode></FinancialCode> - Código da Natureza (Protheus) 
   
   oRec:SetField('BusinessEvent',oRequest)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)

   RestOrd(aOrd,.T.)
   
Return oXml

*-------------------------------------------------*
Function AF233ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oRetCont       := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local oBusinessMsg   := oEasyMessage:GetBsnContent()
Local cEvent		 := ""
Local nI
Local aArray		 := {}
Local oList
Local nEEQRec
Local cBatchNumber 	:= If( Upper(EasyGetXMLinfo(,oBusinessEvent, "_Event" )) == "UPSERT" , EasyGetXMLinfo(,oRetCont:_LISTOFINTERNALID:_INTERNALID,"_DESTINATION"), "") //NCF - 11/11/2019 - Quando for Delete, não retorna Lista com BatchNumber.
Local aOrd

aOrd := SaveOrd({"EC6"})

cEvent:= EasyGetXMLinfo(,oBusinessEvent, "_Event" )//Evento do XML

	For nI := 1 To Len(aEAIRecnos) //aEAIREcnos declarada no EasyEAIBuffer(EASYINTEAI.PRW)
		nEEQRec := aEAIRecnos[nI][1] 
		EEQ->(dbGoTo(nEEQRec))
		EEQ->(Reclock("EEQ",.F.))
		If Upper(cEvent) == "UPSERT" .and. !empty(EEQ->EEQ_PGT)
			EEQ->EEQ_INTERN	:= cBatchNumber
		Else
			EEQ->EEQ_INTERN := ""
		EndIf
		EEQ->(MsUnlock())
	Next i
  
  If IsMemVar("nEAIRecno") .And. IsMemVar("aEAIRecnos") .And. aScan(aEAIRecnos,{|x| x[1] == nEAIRecno }) == 0 //Em caso de mensagem do tipo DELETE do contrato
     EEQ->(dbGoTo(nEAIRecno))
     EEQ->(Reclock("EEQ",.F.))
     EEQ->EEQ_INTERN :=  If( Upper(cEvent) == "UPSERT" .and. !empty(EEQ->EEQ_PGT) , cBatchNumber, "" )
     EEQ->(MsUnlock())
  EndIf

RestOrd(aOrd,.T.)

Return oEasyMessage

*-------------------------------------------------*
Static Function MovExtTit(aChave,cEEQRec)
*-------------------------------------------------*
Local aRet  := {}
Local cQry  := ""
Local cQryEEQ := getnextalias()
Local nPos  := 0

cQry += "Select EEQ_TIPO, EEQ_PGT, EEQ_FILIAL, EEQ_NROP, EEQ_BANC, EEQ_VL,"
cQry += "EEQ_AGEN, EEQ_NCON, EEQ_PARC, EEQ_FINNUM, EEQ_SEQBX,EEQ_VL,EEQ_CGRAFI,R_E_C_N_O_, D_E_L_E_T_ "
If AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
   cQry += ", EEQ_ACRESC, EEQ_DECRES, EEQ_MULTA, EEQ_JUROS"
EndIf
If EEQ->( FieldPos("EEQ_DESCON") ) > 0
   cQry += ", EEQ_DESCON"
EndIf
cQry += " FROM "+retsqlname("EEQ")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += " AND EEQ_TIPO IN ('R','A')"
cQry += " AND EEQ_PGT <> ' '"
cQry += " AND R_E_C_N_O_ <> "+ cEEQRec 
cQry += " AND EEQ_FILIAL = '"+ aChave[1] +"'"
cQry += " AND EEQ_NROP = '"+ aChave[2] +"'"
cQry += " AND EEQ_BANC = '"+ aChave[3] +"'"
cQry += " AND EEQ_AGEN = '"+ aChave[4] +"'"
cQry += " AND EEQ_NCON = '"+ aChave[5] +"'"
cQry += " AND EEQ_MODAL= '2'" //Movimento no Exterior
cQry += " AND EEQ_INTERN= ' ' " //Sem movimentação bancária para a parcela
cQry += " ORDER BY EEQ_PARC"

cQry:=ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cQryEEQ , .F., .T.)

(cQryEEQ)->(DBGoTop())
Do While ((cQryEEQ)->(!Bof()) .AND. (cQryEEQ)->(!Eof()))
   aAdd(aRet, { (cQryEEQ)->R_E_C_N_O_ , (cQryEEQ)->EEQ_FINNUM+(cQryEEQ)->EEQ_SEQBX , AF200VLFCam(cQryEEQ) })
   (cQryEEQ)->(dBSkip())
EndDo

(cQryEEQ)->(DbCloseArea())

Return aRet