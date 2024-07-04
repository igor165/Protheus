#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "GTPA809.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA809
Função responsavel pela Retirada de Encomendas
@type Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@param cId, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Function GTPA809()

FWExecView(STR0001, "GTPA809",MODEL_OPERATION_INSERT,,,,,GtpBtnView(),,,, )//"Retirada"

SetKey( VK_F5 , ) 

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrCab	:= FWFormModelStruct():New()
Local oStrG99	:= FWFormStruct(1,"G99")
Local oStrGIR	:= FWFormStruct(1,"GIR") //Formas de Pagamento
Local bPosValid	:= {|oMdl| ModelPosValid(oMdl) }
Local bCommit	:= {|oMdl| ModelCommit(oMdl) }
Local bPreLine  := {|oModel,nLine,cAction,cField,uValue| VldPreLine(oModel,nLine,cAction,cField,uValue)}

SetModelStruct(oStrCab,oStrG99, oStrGIR)

oModel := MPFormModel():New('GTPA809', /*bPreValidacao*/, bPosValid,/*bCommit*/, /*bCancel*/ )
oModel:SetCommit(bCommit)
oModel:AddFields('MASTER',/*cOwner*/,oStrCab,/*bPre*/,/*bPos*/,/*bLoad*/)
oModel:AddGrid('G99DETAIL','MASTER',oStrG99,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*bLoad*/)

//Grid - GIR -- Formas de Pagamento
oModel:AddGrid("DETAILGIR", "G99DETAIL", oStrGIR, bPreLine)
oModel:SetRelation("DETAILGIR", {{"GIR_FILIAL", "xFilial('GIR')"}, {"GIR_CODIGO", "G99_CODIGO"}}, GIR->(IndexKey(1)))

oModel:SetDescription(STR0002) //"Encomendas"

oModel:GetModel('MASTER'):SetDescription(STR0003)//'Dados para Filtro'
oModel:GetModel('G99DETAIL'):SetDescription(STR0002)//"Encomendas"
oModel:GetModel("DETAILGIR"):SetDescription(STR0058)//"Formas de Pagamento" 

oModel:GetModel('MASTER'):SetOnlyQuery( .T. )
oModel:GetModel('G99DETAIL'):SetOnlyQuery( .T. )

oModel:GetModel('G99DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('G99DETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel("DETAILGIR"):SetMaxLine(1)

oModel:SetPrimaryKey({})

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelPosValid

@type Static Function
@author jacomo.fernandes
@since 04/12/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet		:= .T.
Local oMdlCab	:= oModel:GetModel("MASTER")
Local oMdlG99	:= oModel:GetModel("G99DETAIL")
Local oMdlGIR	:= oModel:GetModel("DETAILGIR")
Local cMdlId    := oModel:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If lRet .AND. !oMdlG99:SeekLine({{'G99_MARK',.T.}})
	lRet		:= .F.
	cMsgErro	:= STR0004//"Não foi marcado nenhuma Encomenda para ser retirada"
	cMsgSol	    := STR0005//"Marque ao menos uma Encomenda para continuar com o processo"
Endif

If lRet .AND. oMdlGIR:SeekLine({{'GIR_TIPPAG','4'}})
	lRet		:= .F.
	cMsgErro	:= STR0059//"Existe encomenda com o tipo de pagamento 'Pago na retirada'."
	cMsgSol	    := STR0060//"Altere a forma de pagamento."
EndIf

If GtpGetRules('ENVIAEMAIL', .F., , .F.)
        
    If lRet .and. oMdlG99:SeekLine({{'G99_MARK',.T.},{"A1_EMAIL",SPACE(TamSx3('A1_EMAIL')[1])} })
        If !FwAlertNoYes(I18n(STR0006,{AllTrim(oMdlG99:GetValue('G99_NOMREM')) }),STR0007)//"Email do Remetente #1 não informado, deseja continuar assim mesmo?"##"Envio de Email"
            lRet		:= .F.
            cMsgErro	:= I18n(STR0008,{AllTrim(oMdlG99:GetValue('G99_NOMREM')) })//"Email do Remetente #1 não informado"
            cMsgSol	    := STR0009//"Informe o email para continuar com o processo"
        Endif
    Endif
    If lRet .and. FwAlertYesNo(STR0010,STR0007)//"Deseja enviar email para o(s) Remetente(s)?"##"Envio de Email"
        lRet := oMdlCab:SetValue("ENVIA_EMAIL",.T.)
    Endif
Endif


If lRet .and. oMdlG99:SeekLine({{'G99_MARK',.T.},{"G99_TOMADO",'3'} })
	
	If !FwAlertNoYes(STR0011+Chr(13)+Chr(10);//"Existem encomendas selecionadas da qual o tomador é o destinatário."
					+STR0012+Chr(13)+Chr(10)+Chr(13)+Chr(10);//"Realize a cobrança dos mesmos para continuar o processo"
					+STR0013,STR0014)//"Deseja Continuar?"##"Atenção!!!"
		lRet		:= .F.
		cMsgErro	:= STR0015//"Processo abortado pelo usuário"
		cMsgSol	    := ""
	Endif
Endif

oMdlG99:GoLine(1)

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,,cMdlId,,"ModelPosValid",cMsgErro,cMsgSol)
Endif

Return lRet

/*/{Protheus.doc} VldPreLine
(long_description)
@type function
@author henrique.toyada
@since 17/12/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uValue, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldPreLine(oMdl,nLine,cAction,cField,uValue)
Local lRet		:= .T.
Local oModel    := oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cSolucao	:= ""

If cMdlId == "DETAILGIR"

	IF (cAction == "SETVALUE")
		// Se a linha está sendo modificada deve subtrair o valor da requisição atual do total
		IF !(oMdl:GetValue("GIRVALID", nline))
			lRet := .F.
			cMsgErro := STR0061//"Não é possível alterar tipo de pagamento da encomenda."
			cSolucao := STR0062//"Efetue a alteração apenas dos que estiverem como 'Pago na retirada'."
		ENDIF
		 
	EndIf    

Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,'GT809mPreLine',cMsgErro,cSolucao)
Endif


Return lRet 

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelCommit

@type Static Function
@author jacomo.fernandes
@since 04/12/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelCommit(oModel)
Local lRet	        := .T.
Local aAreaG99      := G99->(GetArea())
Local aAreaG9Q      := G9Q->(GetArea())
Local aAreaGIR      := GIR->(GetArea())
Local oMdlCab	    := oModel:GetModel("MASTER")
Local oMdlG99	    := oModel:GetModel("G99DETAIL")
Local oMdlGIR	    := oModel:GetModel("DETAILGIR")
Local cMdlId        := oModel:GetId()
Local cMsgErro	    := ""
Local cMsgSol	    := ""
Local n1		    := 0
Local lEnvEmail     := oMdlCab:GetValue("ENVIA_EMAIL")
Local aEmail        := {}
Local oDadosEmail   := nil
Local cUserLog		:= AllTrim(RetCodUsr())


Begin Transaction

	For n1 := 1 To oMdlG99:Length()
		If !oMdlG99:IsDeleted(n1) .and. oMdlG99:GetValue('G99_MARK',n1)
			G99->(DbGoTo(oMdlG99:GetValue("G99RECNO",n1) ) )
			G99->(RecLock('G99',.F.))
				G99->G99_STAENC := "5" //Retirada
				G99->G99_USURET := cUserLog
			G99->(MsUnlock())

			G9Q->(DbGoTo(oMdlG99:GetValue("G9QRECNO",n1)))
			G9Q->(RecLock('G9Q',.F.))
				G9Q->G9Q_STAENC := "4" //RetiradO
			G9Q->(MsUnlock())
            If lEnvEmail
                oDadosEmail := JsonObject():new()
                oDadosEmail["PRODUTO"]      := AllTrim(oMdlG99:GetValue("G99_CODPRO",n1))+" - "+AllTrim(oMdlG99:GetValue("G99_DESPRO",n1))
                oDadosEmail["SERIE"]        := AllTrim(oMdlG99:GetValue("G99_SERIE" ,n1))
                oDadosEmail["NUMERO"]       := AllTrim(oMdlG99:GetValue("G99_NUMDOC",n1))
                oDadosEmail["REMETENTE"]    := AllTrim(oMdlG99:GetValue("G99_NOMREM",n1))
                oDadosEmail["DESTINATARIO"] := AllTrim(oMdlG99:GetValue("G99_NOMDES",n1))
                oDadosEmail["AGENCIA"]      := AllTrim(oMdlG99:GetValue("G99_DESREC",n1))
                oDadosEmail["EMAIL"]        := AllTrim(oMdlG99:GetValue("A1_EMAIL"  ,n1))
                
                aAdd(aEmail,oDadosEmail)
                
            Endif
		Endif
		If oMdlG99:GetValue("GIRVALID",n1) .and. oMdlG99:GetValue('G99_MARK',n1)
			oMdlG99:GoLine(n1)
			GIR->(DbGoTo(oMdlG99:GetValue("GIRRECNO",n1) ) )
			GIR->(RecLock('GIR',.F.))
			GIR->GIR_TIPPAG := oMdlGIR:GetValue("GIR_TIPPAG")
			GIR->GIR_TPCART := oMdlGIR:GetValue("GIR_TPCART") 
			GIR->GIR_CODADM := oMdlGIR:GetValue("GIR_CODADM") 
			GIR->GIR_ESTAB  := oMdlGIR:GetValue("GIR_ESTAB" ) 
			GIR->GIR_NUMPAR := oMdlGIR:GetValue("GIR_NUMPAR") 
			GIR->GIR_NSU    := oMdlGIR:GetValue("GIR_NSU"	) 
			GIR->GIR_AUT    := oMdlGIR:GetValue("GIR_AUT"	) 
			GIR->(MsUnlock())
		EndIf
	Next

End Transaction

If lEnvEmail .and. !Empty(aEmail)
    SendMail(aEmail)
Endif


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

RestArea(aAreaGIR)
RestArea(aAreaG99)
RestArea(aAreaG9Q)

GtpDestroy(aAreaG99)
GtpDestroy(aAreaG9Q)
GtpDestroy(aEmail)

Return lRet
	

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@param oStrCab, object, (Descrição do parâmetro)
@param oStrG99, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrCab,oStrG99,oStrGir)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bWhen     := {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

If ValType(oStrCab) == "O"
	GTPxCriaCpo(oStrCab,{"G99_CODREC","G99_DESREC","G99_CLIREM","G99_LOJREM","G99_NOMREM","G99_CLIDES","G99_LOJDES","G99_NOMDES","G99_SERIE","G99_NUMDOC"},.T.)
	
	oStrCab:AddField(STR0016,STR0016,"G99_DOCREM"  ,"C",TamSx3("A1_CGC")[1] ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"CPF/CNPJ Remetente" 	 
	oStrCab:AddField(STR0017,STR0017,"G99_DOCDES"  ,"C",TamSx3("A1_CGC")[1] ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"CPF/CNPJ Destinatario" 
	oStrCab:AddField(STR0018,STR0018,"G99_DTINI"   ,"D",8                   ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Dt Inicial"   
    oStrCab:AddField(STR0019,STR0019,"G99_DTFIM"   ,"D",8                   ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Dt Final"     
    oStrCab:AddField(STR0020,STR0020,"ENVIA_EMAIL" ,"L",1                   ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Envia Email?"
    
	oStrCab:SetProperty('*'	    		,MODEL_FIELD_OBRIGAT, .F. )
	oStrCab:SetProperty('G99_CODREC'	,MODEL_FIELD_OBRIGAT, .T. )

	oStrCab:AddTrigger("G99_CODREC","G99_CODREC",{||.T.},bTrig)
	oStrCab:AddTrigger("G99_CLIREM","G99_CLIREM",{||.T.},bTrig)
	oStrCab:AddTrigger("G99_LOJREM","G99_LOJREM",{||.T.},bTrig)
	oStrCab:AddTrigger("G99_CLIDES","G99_CLIDES",{||.T.},bTrig)
	oStrCab:AddTrigger("G99_LOJDES","G99_LOJDES",{||.T.},bTrig)
	oStrCab:AddTrigger("G99_DOCREM","G99_DOCREM",{||.T.},bTrig)
	oStrCab:AddTrigger("G99_DOCDES","G99_DOCDES",{||.T.},bTrig)

	oStrCab:SetProperty("G99_CODREC",MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_CLIREM",MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_LOJREM",MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_CLIDES",MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_LOJDES",MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_DOCREM",MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_DOCDES",MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_DTINI" ,MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_DTFIM" ,MODEL_FIELD_VALID, bFldVld)
	oStrCab:SetProperty("G99_SERIE" ,MODEL_FIELD_VALID, bFldVld)

	
Endif

If ValType(oStrG99) == "O"
    oStrG99:SetProperty('*'	    ,MODEL_FIELD_OBRIGAT, .F. )
    GTPxCriaCpo(oStrG99,{"A1_EMAIL"},.T.)
    
	oStrG99:AddField(''			,''			,'LEGENDA'		,'BT'	,1	,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrG99:AddField(""         ,""         ,"G99_MARK"   	,"L"	,1	,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrG99:AddField("G99RECNO" ,"G99RECNO" ,"G99RECNO"   	,"N"	,16	,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)
	oStrG99:AddField("G9QRECNO" ,"G9QRECNO" ,"G9QRECNO"   	,"N"	,16	,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)
	oStrG99:AddField("GIRRECNO" ,"GIRRECNO" ,"GIRRECNO" 	,"N"	,16 ,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)
	oStrG99:AddField(""         ,""         ,"GIRVALID"	,"L",01,0,NIL,NIL,NIL,.F.,NIL,.F.,.T.,.T.)
Endif

If ValType(oStrGIR) == "O"
	oStrGIR:SetProperty('*'	    ,MODEL_FIELD_OBRIGAT, .F. )
    oStrGIR:SetProperty("GIR_TPCART", 	MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_NUMPAR",	MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_NSU",	 	MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_AUT", 		MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_CODADM", 	MODEL_FIELD_WHEN, bWhen)

    oStrGIR:SetProperty("GIR_TIPPAG",	MODEL_FIELD_VALID, bFldVld)
    
    oStrGIR:AddTrigger("GIR_TIPPAG" ,"GIR_TIPPAG" ,{||.T.}, bTrig)
	oStrGIR:AddTrigger("GIR_TPCART" ,"GIR_TPCART" ,{||.T.}, bTrig)
	oStrGIR:AddTrigger("GIR_CODADM" ,"GIR_CODADM" ,{||.T.}, bTrig)
	oStrGIR:AddField(""         ,""         ,"GIRVALID"	,"L",01,0,NIL,NIL,NIL,.F.,NIL,.F.,.T.,.T.)
    
Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldWhen
Função responsavel pelo When dos Campos
@type function
@author henrique.toyada
@since 17/12/2019
@version 1.0
@param uVal, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet		:= .T.
Local cMdlId	:= oMdl:GetID()

Do Case
	Case cMdlId == "DETAILGIR"
		If cField $ 'GIR_TPCART|GIR_NUMPAR|GIR_NSU|GIR_AUT|GIR_CODADM'
			lRet := oMdl:GetValue('GIR_TIPPAG') == '2'
		Endif
EndCase

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local oView		:= FwViewActive()
Local aAreaAux  := {}

Do Case
	Case cField == "G99_CODREC"
		oMdl:LoadValue('G99_DESREC', Posicione('GI6',1,xFilial('GI6')+uVal,"GI6_DESCRI") ) 
	
	Case  AllTrim(cField) $  "G99_CLIREM/G99_LOJREM"
		SetDadosCliente(oMdl,1)

	Case AllTrim(cField) $ "G99_CLIDES/G99_LOJDES"
		SetDadosCliente(oMdl,2)		
	Case cField == "G99_DOCREM"
		SetDadosCliente(oMdl,3)		
	Case cField == "G99_DOCDES"
		SetDadosCliente(oMdl,4)	
	Case cField == "GIR_CODADM"	
		oMdl:SetValue("GIR_DESADM",POSICIONE("SAE",1,XFILIAL("SAE")+uVal,"AE_DESC"))
	Case cField == 'GIR_TIPPAG' 
    
    	//If  uVal != '2'
	    	oMdl:ClearField("GIR_TPCART")
	    	oMdl:ClearField("GIR_NSU"   )
	    	oMdl:ClearField("GIR_AUT"   )
	    	oMdl:ClearField("GIR_NUMPAR")
	    	oMdl:ClearField("GIR_CODADM")
			oMdl:ClearField("GIR_DESADM")
			oMdl:ClearField("GIR_ESTAB ")
 
    	//Endif
    	
    Case cField == 'GIR_TPCART'
    	oMdl:SetValue('GIR_NUMPAR',	1)
EndCase

If !IsBlind() .and. ValType(oView) == "O" .AND. oView:IsActive()
	oView:Refresh()
Endif

GtpDestroy(aAreaAux)

Return uVal


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDadosCliente

@type Static Function
@author jacomo.fernandes
@since 03/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetDadosCliente(oMdl,nTipo)
Local aAreaSA1	:= SA1->(GetArea())
Local cSeek		:= ""

If nTipo == 1
	nOrd	:= 1
	cSeek	+= AllTrim(oMdl:GetValue("G99_CLIREM"))
	cSeek	+= AllTrim(oMdl:GetValue("G99_LOJREM"))
ElseIf nTipo == 2
	nOrd	:= 1
	cSeek	+= AllTrim(oMdl:GetValue("G99_CLIDES"))
	cSeek	+= AllTrim(oMdl:GetValue("G99_LOJDES"))
ElseIf nTipo == 3
	nOrd	:= 3
	cSeek	:= oMdl:GetValue("G99_DOCREM")
ElseIf nTipo == 4
	nOrd	:= 3
	cSeek	:= oMdl:GetValue("G99_DOCDES")
Endif

SA1->(DbSetOrder(nOrd))
SA1->(DbSeek(xFilial('SA1')+cSeek))

If nTipo == 1 .or. nTipo == 3
	oMdl:LoadValue("G99_CLIREM",SA1->A1_COD)
	oMdl:LoadValue("G99_LOJREM",SA1->A1_LOJA)
	oMdl:LoadValue("G99_NOMREM",SA1->A1_NOME)
	oMdl:LoadValue("G99_DOCREM",SA1->A1_CGC)
Else
	oMdl:LoadValue("G99_CLIDES",SA1->A1_COD)
	oMdl:LoadValue("G99_LOJDES",SA1->A1_LOJA)
	oMdl:LoadValue("G99_NOMDES",SA1->A1_NOME)
	oMdl:LoadValue("G99_DOCDES",SA1->A1_CGC)
Endif


RestArea(aAreaSA1)

GtpDestroy(aAreaSA1)

Return 


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet      := .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId    := oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
        lRet := .T.
	Case cField == "G99_CODREC" 
		IF !GTPExistCpo('GI6',uNewValue)
            lRet        := .F.
            cMsgErro	:= STR0021//"Agencia selecionada não encontrada ou se encontra inativa"
            cMsgSol	    := STR0022//"Selecione uma agencia valida"
        ElseIf !GxVldAgEnc(uNewValue)
            lRet        := .F.
            cMsgErro	:= STR0023//"Agencia selecionada não é do tipo de Encomenda"
            cMsgSol	    := STR0024//"Selecione uma agencia valida"
        ElseIf !ValidUserAg(oMdl,cField,uNewValue,uOldValue)
            lRet        := .F.
        Endif
	Case cField == "G99_CLIREM" .or. cField == "G99_LOJREM"
		If !GxVlCliFor('SA1',oMdl:GetValue("G99_CLIREM"),oMdl:GetValue("G99_LOJREM"))
			lRet := .F.
		Endif
	
	Case cField == "G99_CLIDES" .or. cField == "G99_LOJDES"
		If !GxVlCliFor('SA1',oMdl:GetValue("G99_CLIDES"),oMdl:GetValue("G99_LOJDES"))
			lRet := .F.
		Endif
	
	Case cField == "G99_DOCREM" .or. cField == "G99_DOCDES"
		If !GTPExistCpo('SA1',uNewValue,3)//Pesquisa por CPF
			lRet        := .F.
            cMsgErro	:= STR0063//"Cliente selecionado não encontrado ou se encontra inativo"//
            cMsgSol	    := STR0064//"Selecione um cliente valido"//
		Endif

	Case cField == "G99_DTINI" .or. cField == "G99_DTFIM" 
		If !Empty(oMdl:GetValue("G99_DTINI")) .and. ;
            !Empty(oMdl:GetValue("G99_DTFIM")) .and. ;
            ( oMdl:GetValue("G99_DTINI") > oMdl:GetValue("G99_DTFIM") )

            lRet		:= .F.
            cMsgErro	:= STR0065//"Data Inicial maior que a Data Final"//
            cMsgSol		:= STR0066//"Informe uma Data menor que a Data Final"//
        Endif
	Case cField == "G99_SERIE"
		IF !GTPxIsDigit(uNewValue)
            lRet        := .F.
            cMsgErro	:= STR0067//"Serie informada se encontra em formato alfanumérico"//
            cMsgSol	    := STR0068//"Para geração do Conhecimento de Transporte, a Série deve estar em formato numérico"//
        ElseIf A460Especie(uNewValue) <> "CTE"
            lRet        := .F.
            cMsgErro	:= STR0069//"Série informada não possuí vinculo à especie CTE"//
            cMsgSol	    := STR0070//"Verifique a parametrização fiscal da Especie"//
        Endif
	Case cField == "GIR_TIPPAG"
    	lRet := VldOpcPag(oModel,@cMsgErro,@cMsgSol)
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldOpcPag
@type Function
@author henrique.toyada
@since 17/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function VldOpcPag(oModel, cMsgErro, cMsgSol)
Local lRet 		:= .T.
Local cCliRem	:= oModel:GetModel('G99DETAIL'):GetValue('G99_CLIREM')
Local cLojRem	:= oModel:GetModel('G99DETAIL'):GetValue('G99_LOJREM')
Local cCliDes	:= oModel:GetModel('G99DETAIL'):GetValue('G99_CLIDES')
Local cLojDes	:= oModel:GetModel('G99DETAIL'):GetValue('G99_LOJDES')
Local cTomador	:= oModel:GetModel('G99DETAIL'):GetValue('G99_TOMADO')
Local cTipPag	:= oModel:GetModel('DETAILGIR'):GetValue('GIR_TIPPAG')

If cTipPag == '1'
	H65->(DBSETORDER(2))
	If H65->(DBSEEK(XFILIAL("H65") + oModel:GetModel('MASTER'):GetValue('G99_CODREC') + '1'))
		cMsgErro := "Opção inválida para agência bloqueada"
		cMsgSol  := "Efetue o desbloqueio da agência."
		lRet     := .F.
	EndIf
EndIf

If cTomador == '0' //Remetente

	If cTipPag == '3'  // Faturado
	
		If !(GIL->(dbSeek(xFilial('GIL')+cCliRem+cLojRem)))
			cMsgErro := STR0071//'Opção inválida para clientes sem contrato' //
			cMsgSol	 := STR0072//'Selecione outra forma de pagamento' //
			lRet	 := .F.
		ElseIf (GIL->(dbSeek(xFilial('GIL')+cCliRem+cLojRem))) .And. GIL->GIL_TPFRET == '2'
			cMsgErro := STR0073//'Tipo de contrato do cliente não permite esta opção' //
			cMsgSol	 := STR0074//'Selecione outra forma de pagamento' //
			lRet	 := .F.
		Endif
	Endif

Else //Destinatário

	If cTipPag =='3' // Faturado
	
		If !(GIL->(dbSeek(xFilial('GIL')+cCliDes+cLojDes)))
			cMsgErro := STR0071//'Opção inválida para clientes sem contrato' //
			cMsgSol	 := STR0072//'Selecione outra forma de pagamento' //
			lRet	 := .F.
		ElseIf (GIL->(dbSeek(xFilial('GIL')+cCliDes+cLojDes))) .And. GIL->GIL_TPFRET == '1'
			cMsgErro := STR0073//'Tipo de contrato do cliente não permite esta opção' //
			cMsgSol	 := STR0074//'Selecione outra forma de pagamento' //
			lRet	 := .F.
		Endif
	
	Endif
	
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA809')
Local oStrCAB	:= FWFormViewStruct():New()
Local oStrG99	:= FWFormStruct(2, "G99")
Local oStrGIR   := FWFormStruct(2, "GIR")

SetViewStruct(oStrCAB,oStrG99,oStrGIR)

oView:SetModel(oModel)

oView:AddField('VIEW_CAB' ,oStrCAB,'MASTER')
oView:AddGrid('VIEW_G99',oStrG99,'G99DETAIL')
oView:AddGrid("GRID_VIEWGIR" , oStrGIR, "DETAILGIR")

oView:CreateHorizontalBox('UPPER', 30)
oView:CreateHorizontalBox('BOTTOM', 50)
oView:CreateHorizontalBox('BOX_PAGAMENTO', 20)

oView:SetOwnerView('VIEW_CAB','UPPER')
oView:SetOwnerView('VIEW_G99','BOTTOM')
oView:SetOwnerView("GRID_VIEWGIR"  , "BOX_PAGAMENTO")

oView:SetDescription(STR0002) //'Encomendas'

oView:EnableTitleView("VIEW_G99")
oView:EnableTitleView("GRID_VIEWGIR")

oView:SetViewProperty("VIEW_G99", "GRIDSEEK", {.T.})
oView:SetViewProperty("VIEW_G99", "GRIDFILTER", {.T.})
oView:addIncrementField("GRID_VIEWGIR", "GIR_SEQ")

oView:AddUserButton( STR0033+" <F5>", "", {|oView| FwMsgRun(,{|| ExecFilter(oView)}	,STR0034,STR0035)} ,,VK_F5,,.T./* lShowBar */) //"Filtrar","Filtro", "Realizando o filtro dos registros..."
oView:AddUserButton( STR0036        , "", {|oView| FwMsgRun(,{|| MarcarTodos(oView)},STR0037,STR0038)} ,,     ,,.T./* lShowBar */)//"(Des)Marcar Todos","(Des)Marcando", "Realizando a (Des)marcação dos registros..."

oView:addIncrementField("GRID_VIEWGIR", "GIR_SEQ")

SetKey( VK_F5 ,{|| ExecFilter(oView)} ) 

oView:SetInsertMessage(STR0001,STR0057)//"Retirada"##"Retirada da encomenda realizado com sucesso"

oView:SetViewProperty("VIEW_G99", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| GT809LDbClk(oGrid,cField,nLineGrid,nLineModel)}})

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} GT809LDbClk

@type Static Function
@author henrique.toyada
@since 17/12/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function GT809LDbClk(oView,cField,nLineGrid,nLineModel)

Local oModelG99 := oView:GetModel("G99DETAIL")

If  "LEGENDA" $ cField
	Gt809Legend(oView,cField,.T.)	
ElseIf "G99_MARK" $ cField
	If oModelG99:GetValue('G99_MARK') 
		oModelG99:SetValue('G99_MARK',.F.)
	Else
		oModelG99:SetValue('G99_MARK',.T.)
	Endif
	oView:Refresh()
Endif
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Gt809Legend

@type Static Function
@author henrique.toyada
@since 17/12/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function Gt809Legend(oView,cField,lTela)

Local oLegenda		:= FWLegend():New()
Local oModel		:= oView:GetModel()
Local oMdlAux		:= oModel:GetModel("G99DETAIL")
Local aLegend		:= {}
Local n1			:= 0
Local cRet			:= ""

Default lTela		:= .F.

If cField == 'LEGENDA'
	aAdd(aLegend,{{|| oMdlAux:GetValue(cField) == "BR_VERDE"	} ,"BR_VERDE"	, STR0075 }) //"Pago"
	aAdd(aLegend,{{|| oMdlAux:GetValue(cField) == "BR_LARANJA"	} ,"BR_LARANJA"	, STR0076 }) //"Pendente recebimento"
Endif

For n1 := 1 To Len(aLegend)
	oLegenda:Add(aLegend[n1][1]	,aLegend[n1][2]		,aLegend[n1][3])
Next

oLegenda:Activate()
If lTela
	oLegenda:View()
Else
	cRet := oLegenda:Execute()
Endif
oLegenda:DeActivate()

GTPDestroy(oLegenda) //Destroi o objeto
GTPDestroy(aLegend)	//Destroi o array
Return cRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@param oStrCab, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrCab,oStrG99,oStrGIR)
Local aFldStr	:= NIL
Local cFieldsIn	:= ""
Local bPvar		:= {|oMdl,cField,uVal| SetViewPVar(oMdl,cField,uVal)}
Local nI		:= 0

If ValType(oStrCab) == "O"

	GTPxCriaCpo(oStrCab,{"G99_CODREC","G99_DESREC","G99_CLIREM","G99_LOJREM","G99_NOMREM","G99_CLIDES","G99_LOJDES","G99_NOMDES","G99_SERIE","G99_NUMDOC"},.F.)

	oStrCab:AddField("G99_DOCREM"  ,"99",STR0016,STR0016,NIL,"C",""     ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"CPF/CNPJ Remetente"
	oStrCab:AddField("G99_DOCDES"  ,"99",STR0017,STR0017,NIL,"C",""     ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"CPF/CNPJ Destinatario"
	oStrCab:AddField("G99_DTINI"   ,"99",STR0018,STR0018,NIL,"D","@D"   ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Dt Inicial"   ,"Data Inicial"    
    oStrCab:AddField("G99_DTFIM"   ,"99",STR0019,STR0019,NIL,"D","@D"   ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Dt Final"     ,"Data Final"      
    
    oStrCab:SetProperty("G99_CODREC",MVC_VIEW_TITULO	,STR0039  )//"Agencia p/ Retirada"
    oStrCab:SetProperty("G99_DESREC",MVC_VIEW_TITULO	,STR0040  )//"Nome da Agencia"    

    oStrCab:SetProperty("G99_DOCREM",MVC_VIEW_PVAR,bPvar)
	oStrCab:SetProperty("G99_DOCDES",MVC_VIEW_PVAR,bPvar)
	
	oStrCab:SetProperty("G99_DESREC",MVC_VIEW_CANCHANGE	,.F.)
	oStrCab:SetProperty("G99_NOMREM",MVC_VIEW_CANCHANGE	,.F.)
	oStrCab:SetProperty("G99_NOMDES",MVC_VIEW_CANCHANGE	,.F.)

	oStrCab:SetProperty("G99_CODREC", MVC_VIEW_ORDEM, '01')
	oStrCab:SetProperty("G99_DESREC", MVC_VIEW_ORDEM, '02')
	
	oStrCab:SetProperty("G99_DOCDES", MVC_VIEW_ORDEM, '03')
	oStrCab:SetProperty("G99_CLIDES", MVC_VIEW_ORDEM, '04')
	oStrCab:SetProperty("G99_LOJDES", MVC_VIEW_ORDEM, '05')
	oStrCab:SetProperty("G99_NOMDES", MVC_VIEW_ORDEM, '06')
	
    oStrCab:SetProperty("G99_DOCREM", MVC_VIEW_ORDEM, '07')
    oStrCab:SetProperty("G99_CLIREM", MVC_VIEW_ORDEM, '08')
	oStrCab:SetProperty("G99_LOJREM", MVC_VIEW_ORDEM, '09')
	oStrCab:SetProperty("G99_NOMREM", MVC_VIEW_ORDEM, '10')
	
	oStrCab:SetProperty("G99_SERIE"	, MVC_VIEW_ORDEM, '11')
	oStrCab:SetProperty("G99_NUMDOC", MVC_VIEW_ORDEM, '12')
	
	oStrCab:SetProperty("G99_DTINI" , MVC_VIEW_ORDEM, '13')
	oStrCab:SetProperty("G99_DTFIM" , MVC_VIEW_ORDEM, '14')

	oStrCab:AddGroup( 'RECEBEDORA'	,'' , '', 2 )
	oStrCab:SetProperty("G99_CODREC", MVC_VIEW_GROUP_NUMBER, "RECEBEDORA" )
	oStrCab:SetProperty("G99_DESREC", MVC_VIEW_GROUP_NUMBER, "RECEBEDORA" )

	oStrCab:AddGroup( 'DESTINATARIO'	,'' , '', 2 )
	oStrCab:SetProperty("G99_CLIDES", MVC_VIEW_GROUP_NUMBER, "DESTINATARIO")
	oStrCab:SetProperty("G99_LOJDES", MVC_VIEW_GROUP_NUMBER, "DESTINATARIO")
	oStrCab:SetProperty("G99_NOMDES", MVC_VIEW_GROUP_NUMBER, "DESTINATARIO")
	oStrCab:SetProperty("G99_DOCDES", MVC_VIEW_GROUP_NUMBER, "DESTINATARIO")
	
	oStrCab:AddGroup( 'REMETENTE'		,'' , '', 2 )
	oStrCab:SetProperty("G99_CLIREM", MVC_VIEW_GROUP_NUMBER, 'REMETENTE')
	oStrCab:SetProperty("G99_LOJREM", MVC_VIEW_GROUP_NUMBER, 'REMETENTE')
	oStrCab:SetProperty("G99_NOMREM", MVC_VIEW_GROUP_NUMBER, 'REMETENTE')
	oStrCab:SetProperty("G99_DOCREM", MVC_VIEW_GROUP_NUMBER, 'REMETENTE')

	oStrCab:AddGroup( 'DOCUMENTO_CTE'	,'' , '', 2 )
	oStrCab:SetProperty("G99_SERIE"	, MVC_VIEW_GROUP_NUMBER, 'DOCUMENTO_CTE')
	oStrCab:SetProperty("G99_NUMDOC", MVC_VIEW_GROUP_NUMBER, 'DOCUMENTO_CTE')

	oStrCab:AddGroup( 'DATA_EMISSAO'	,'' , '', 2 )
	oStrCab:SetProperty("G99_DTINI" , MVC_VIEW_GROUP_NUMBER, 'DATA_EMISSAO')
	oStrCab:SetProperty("G99_DTFIM" , MVC_VIEW_GROUP_NUMBER, 'DATA_EMISSAO')
	
Endif

If ValType(oStrG99) == "O"
    GTPxCriaCpo(oStrG99,{"A1_EMAIL"},.F.)

    oStrG99:SetProperty("A1_EMAIL",MVC_VIEW_TITULO	,STR0041)//"Email Remetente"

    oStrG99:AddField("LEGENDA"		,"01","","",{}	,"BT"	,"",Nil,Nil,.F.,"" ,Nil,Nil,Nil,Nil,.T.,Nil)
    oStrG99:AddField("G99_MARK"   	,"02","","",NIL	,"L"  	,"",NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)
    oStrG99:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
    oStrG99:SetProperty("G99_MARK", MVC_VIEW_CANCHANGE, .T.)
    oStrG99:SetProperty("A1_EMAIL", MVC_VIEW_CANCHANGE, .T.)

	aFldStr := aClone(oStrG99:GetFields())

	cFieldsIn += "LEGENDA|"
	cFieldsIn += "G99_MARK|"
	cFieldsIn += "G99_NOMREM|"
	cFieldsIn += "G99_NOMDES|"
	cFieldsIn += "G99_TOMADO|"
	cFieldsIn += "G99_DESEMI|"
	cFieldsIn += "G99_DESREC|"
	cFieldsIn += "G99_CODPRO|"
	cFieldsIn += "G99_DESPRO|"
	cFieldsIn += "G99_VALOR|"
	cFieldsIn += "G99_SERIE|"
    cFieldsIn += "G99_NUMDOC|"
    cFieldsIn += "A1_EMAIL|"
	
	For nI := 1 to Len(aFldStr)

        If !( AllTrim(aFldStr[nI,1])+"|" $ cFieldsIn) 
            oStrG99:RemoveField(aFldStr[nI,1])
        EndIf

    Next nI

    oStrG99:SetProperty("LEGENDA"   , MVC_VIEW_ORDEM, '01')
    oStrG99:SetProperty("G99_MARK"  , MVC_VIEW_ORDEM, '02')
    oStrG99:SetProperty("G99_SERIE" , MVC_VIEW_ORDEM, '03')
    oStrG99:SetProperty("G99_NUMDOC", MVC_VIEW_ORDEM, '04')
    oStrG99:SetProperty("G99_CODPRO", MVC_VIEW_ORDEM, '05')
    oStrG99:SetProperty("G99_DESPRO", MVC_VIEW_ORDEM, '06')
    oStrG99:SetProperty("G99_NOMREM", MVC_VIEW_ORDEM, '07')
    oStrG99:SetProperty("A1_EMAIL"  , MVC_VIEW_ORDEM, '08')
    oStrG99:SetProperty("G99_NOMDES", MVC_VIEW_ORDEM, '09')
    oStrG99:SetProperty("G99_TOMADO", MVC_VIEW_ORDEM, '10')
    oStrG99:SetProperty("G99_DESEMI", MVC_VIEW_ORDEM, '11')
    oStrG99:SetProperty("G99_DESREC", MVC_VIEW_ORDEM, '12')
	oStrG99:SetProperty("G99_VALOR" , MVC_VIEW_ORDEM, '13')
    
	GtpDestroy(aFldStr)

Endif

If ValType(oStrGIR) == "O"

	oStrGIR:RemoveField("GIR_CODIGO")  
	oStrGIR:RemoveField("GIR_CLIPAG")  
	oStrGIR:RemoveField("GIR_LOJPAG")  
	oStrGIR:RemoveField("GIR_NOMCLI")  
	oStrGIR:RemoveField("GIR_CODIGO") 
	oStrGIR:RemoveField("GIR_DTPAG" ) 
	oStrGIR:RemoveField("GIR_CODFAT")

	oStrGIR:SetProperty("GIR_SEQ" 	,MVC_VIEW_ORDEM, '01')
	oStrGIR:SetProperty("GIR_TIPPAG",MVC_VIEW_ORDEM, '02')
	oStrGIR:SetProperty("GIR_VALOR"	,MVC_VIEW_ORDEM, '03')
	oStrGIR:SetProperty("GIR_TOMADO",MVC_VIEW_ORDEM, '04')
	oStrGIR:SetProperty("GIR_TPCART",MVC_VIEW_ORDEM, '05')
	oStrGIR:SetProperty("GIR_CODADM",MVC_VIEW_ORDEM, '06')
	oStrGIR:SetProperty("GIR_DESADM",MVC_VIEW_ORDEM, '07')
	oStrGIR:SetProperty("GIR_ESTAB" ,MVC_VIEW_ORDEM, '08')
	oStrGIR:SetProperty("GIR_NUMPAR",MVC_VIEW_ORDEM, '09')
	oStrGIR:SetProperty("GIR_NSU"	,MVC_VIEW_ORDEM, '10')
	oStrGIR:SetProperty("GIR_AUT"	,MVC_VIEW_ORDEM, '11')

	oStrGIR:SetProperty('GIR_TOMADO', MVC_VIEW_CANCHANGE , .F.)
	oStrGIR:SetProperty('GIR_VALOR' , MVC_VIEW_CANCHANGE , .F.)
	oStrGIR:SetProperty('GIR_SEQ'   , MVC_VIEW_CANCHANGE , .F.)

EndIf
Return 



//------------------------------------------------------------------------------
/* /{Protheus.doc} ExecFilter
Função responsavel pelo filtro dos dados para serem exibidos na tela
@type Static Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param oView, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ExecFilter(oView,lAsk)
Local oModel    := oView:GetModel()
Default lAsk    := .T.
CursorWait()

If CheckFilter(oModel,lAsk)
    SetDadosCTe(oModel,lAsk)
Endif

oView:Refresh()

CursorArrow()

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} CheckFilter

@type Static Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return lRet, retorno logico
/*/
//------------------------------------------------------------------------------
Static Function CheckFilter(oModel,lAsk)
Local lRet      := .T.
Local oMdlCab   := oModel:GetModel("MASTER")
Local oMdlG99   := oModel:GetModel("G99DETAIL")

If GtpIsInMsg()
    lRet    := .F.
ElseIf Empty(oMdlCab:GetValue('G99_CODREC'))
    FwAlertHelp(STR0042, STR0043,STR0014)//"Não foi informado a agencia recebedora", "Selecione uma agencia para realizar a busca dos dados","Atenção!!"
    lRet := .F.

ElseIf !oMdlG99:IsEmpty() .and. lAsk .AND. !FwAlertYesNo(STR0044,STR0014)//"Existem registro filtrados, deseja refazer o filtro?","Atenção!!"
    lRet    := .F.

Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDadosCTe
Função responsavel pelo preenchimento da grid

@type Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)

/*/
//------------------------------------------------------------------------------
Static Function SetDadosCTe(oModel,lAsk)
Local oMdlCab   := oModel:GetModel('MASTER')
Local oMdlG99   := oModel:GetModel('G99DETAIL')
Local oMdlGIR   := oModel:GetModel('DETAILGIR')
Local cAliasTmp := GetDadosCTe(oMdlCab,lAsk)
Local oStrG99   := oMdlG99:GetStruct()
Local oStrGIR   := oMdlGIR:GetStruct()
Local aFldTab   := (cAliasTmp)->(DbStruct())
Local n1        := 0

oModel:GetModel('G99DETAIL'):SetNoInsertLine(.F.)
oModel:GetModel('G99DETAIL'):SetNoDeleteLine(.F.)

oModel:GetModel('DETAILGIR'):SetNoInsertLine(.F.)
oModel:GetModel('DETAILGIR'):SetNoDeleteLine(.F.)

If !oMdlG99:IsEmpty()
    oMdlG99:ClearData()
Endif

While (cAliasTmp)->(!Eof())

    If !(oMdlG99:IsEmpty())
		oMdlG99:AddLine()
	Endif
	If !(oMdlGIR:IsEmpty())
		oMdlGIR:AddLine()
	Endif
    For n1	:= 1 To Len(aFldTab)
		If oStrG99:HasField(aFldTab[n1][1])
			oMdlG99:LoadValue(aFldTab[n1][1],(cAliasTmp)->&(aFldTab[n1][1]))
		Endif
		If oStrGIR:HasField(aFldTab[n1][1])
			If aFldTab[n1][1] == 'GIR_DTPAG'
				oMdlGIR:LoadValue(aFldTab[n1][1],STOD((cAliasTmp)->&(aFldTab[n1][1])))
			Else
				oMdlGIR:LoadValue(aFldTab[n1][1],(cAliasTmp)->&(aFldTab[n1][1]))
			EndIf
        Endif
    Next
    
    (cAliasTmp)->(DbSkip())
End

oMdlG99:GoLine(1)

oModel:GetModel('DETAILGIR'):SetNoInsertLine(.T.)
oModel:GetModel('DETAILGIR'):SetNoDeleteLine(.T.)

oModel:GetModel('G99DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('G99DETAIL'):SetNoDeleteLine(.T.)

(cAliasTmp)->(DbCloseArea())

Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDadosCTe
Função responsavel pela busca dos dados conforme filtro definido

@type Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param oMdlCab, object, (Descrição do parâmetro)
@return lRet, returno logico
/*/
//------------------------------------------------------------------------------
Static Function GetDadosCTe(oMdlCab,lAsk)
Local cAliasTmp := GetNextAlias()
Local cWhere    := ""

If !Empty(oMdlCab:GetValue("G99_CLIREM"   ))
    cWhere += " AND G99.G99_CLIREM ='"+oMdlCab:GetValue("G99_CLIREM")+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_LOJREM"   ))
    cWhere += " AND G99.G99_LOJREM ='"+oMdlCab:GetValue("G99_LOJREM")+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_DOCREM"   ))
    cWhere += " AND SA1REM.A1_CGC ='"+oMdlCab:GetValue("G99_DOCREM")+"' "
Endif


If !Empty(oMdlCab:GetValue("G99_CLIDES"   ))
    cWhere += " AND G99.G99_CLIDES ='"+oMdlCab:GetValue("G99_CLIDES")+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_LOJDES"   ))
    cWhere += " AND G99.G99_LOJDES ='"+oMdlCab:GetValue("G99_LOJDES")+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_DOCDES"   ))
    cWhere += " AND SA1DES.A1_CGC ='"+oMdlCab:GetValue("G99_DOCDES")+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_SERIE"   ))
    cWhere += " AND G99.G99_SERIE ='"+oMdlCab:GetValue("G99_SERIE")+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_NUMDOC"   ))
    cWhere += " AND G99.G99_NUMDOC ='"+oMdlCab:GetValue("G99_NUMDOC")+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_DTINI"   ))
    cWhere += " AND G99.G99_DTEMIS ='"+DtoS(oMdlCab:GetValue("G99_DTINI"))+"' "
Endif

If !Empty(oMdlCab:GetValue("G99_DTFIM"   ))
    cWhere += " AND G99.G99_DTEMIS ='"+DtoS(oMdlCab:GetValue("G99_DTFIM"))+"' "
Endif

cWhere    := "%"+cWhere+"%"

BeginSql Alias cAliasTmp

	Column G99_MARK as Logical
	Column GIRVALID as Logical
    Column G99_DTEMIS as Date
    Column G99RECNO as Numeric(16,0)
	
    Select 
		'F' AS G99_MARK,
		(Case
			WHEN GIR.GIR_TIPPAG <> '4' THEN 'BR_VERDE'
			WHEN GIR.GIR_TIPPAG = '4' THEN 'BR_LARANJA'
		End)AS LEGENDA,
		(Case
			WHEN GIR.GIR_TIPPAG <> '4' THEN 'F'
			WHEN GIR.GIR_TIPPAG = '4' THEN 'T'
		End)AS GIRVALID,
		SA1REM.A1_NOME AS G99_NOMREM,
		SA1DES.A1_NOME AS G99_NOMDES,
		G99_TOMADO,
		GI6EMI.GI6_DESCRI AS G99_DESEMI,
		GI6REC.GI6_DESCRI AS G99_DESREC,
		G99_CODPRO,
		SB1.B1_DESC AS G99_DESPRO,
		G99_VALOR,
		G99_SERIE,
        G99_NUMDOC,
        SA1REM.A1_EMAIL,
		GIR.GIR_TIPPAG,
		GIR.GIR_TPCART,
		GIR.GIR_NUMPAR,
		GIR.GIR_NSU,
		GIR.GIR_AUT,
		GIR.GIR_VALOR,
		GIR.GIR_DTPAG,
		GIR.GIR_CLIPAG,
		GIR.GIR_LOJPAG,
		GIR.GIR_CODADM,
		GIR.GIR_ESTAB,
		GIR.GIR_TOMADO,
		GIR.GIR_CODIGO,
		GIR.GIR_SEQ,
		G99.R_E_C_N_O_ as G99RECNO,
		G9Q.R_E_C_N_O_ as G9QRECNO,
		GIR.R_E_C_N_O_ as GIRRECNO
    From %Table:G99% G99
        INNER JOIN %Table:GI6% GI6EMI ON
            GI6EMI.GI6_FILIAL = %xFilial:GI6%
            AND GI6EMI.GI6_CODIGO = G99.G99_CODEMI
            AND GI6EMI.%NotDel%
		INNER JOIN %Table:GI6% GI6REC ON
            GI6REC.GI6_FILIAL = %xFilial:GI6%
            AND GI6REC.GI6_CODIGO = G99.G99_CODEMI
            AND GI6REC.%NotDel%
        INNER JOIN %Table:SA1% SA1REM ON
            SA1REM.A1_FILIAL = %xFilial:SA1%
            AND SA1REM.A1_COD = G99.G99_CLIREM
			AND SA1REM.A1_LOJA = G99.G99_LOJREM
            AND SA1REM.%NotDel%
		INNER JOIN %Table:SA1% SA1DES ON
            SA1DES.A1_FILIAL = %xFilial:SA1%
            AND SA1DES.A1_COD = G99.G99_CLIDES
            AND SA1DES.A1_LOJA = G99.G99_LOJDES
			AND SA1DES.%NotDel%
		INNER Join %Table:SB1% SB1 on
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = G99.G99_CODPRO
			AND SB1.%NotDel%
		INNER JOIN %Table:G9Q% G9Q ON
			G9Q.G9Q_FILIAL = G99.G99_FILIAL
			AND G9Q.G9Q_CODIGO = G99.G99_CODIGO
			AND G9Q.G9Q_AGEDES = G99.G99_CODREC
			AND G9Q.%NotDel%
		INNER JOIN %Table:GIR% GIR ON
			GIR.GIR_FILIAL     = G99.G99_FILIAL
			AND GIR.GIR_CODIGO = G99.G99_CODIGO
			AND GIR.%NotDel%
    Where
        G99.G99_FILIAL = %xFilial:G99%
		AND G99.%NotDel%
		and G99.G99_CODREC = %Exp: oMdlCab:GetValue('G99_CODREC') %
        AND G99.G99_STAENC = '4'  //Apenas CT-es recebidas
        %Exp:cWhere%

EndSql

If (cAliasTmp)->(EOF()) .and. lAsk
    FwAlertHelp(STR0045,STR0046,STR0014)//"Não foram encontrados nenhum dados com os parametros informados","Altere os dados para filtro ou verifique se o registro de fato exista","Atenção!!"
Endif

Return cAliasTmp


//------------------------------------------------------------------------------
/* /{Protheus.doc} MarcarTodos

@type Static Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function MarcarTodos(oView)
Local oModel	:= oView:GetModel()
Local oMdlG99	:= oModel:GetModel("G99DETAIL")
Local nX		:= ""
Local lMark		:= .T.

If oMdlG99:Length() > 0
	lMark		:= !oMdlG99:GetValue('G99_MARK')

	For nX := 1 to oMdlG99:Length()
		If !oMdlG99:IsDeleted(nX)
			oMdlG99:GoLine(nX)
			oMdlG99:SetValue('G99_MARK',lMark)

		Endif
	Next
	oMdlG99:GoLine(1)
Endif

Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewPVar(a,b,c,d,e,f,g,h,i,j)

@type Static Function
@author jacomo.fernandes
@since 03/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cPictVar, return_description
/*/
//------------------------------------------------------------------------------
Static Function SetViewPVar(oMdl,cField,uVal)
Local cPictVar	:= nil


If cField == "G99_DOCREM" .or. cField == "G99_DOCDES"
	uVal := StrTran( uVal, "/", "")
	uVal := StrTran( uVal, ".", "")
	uVal := StrTran( uVal, "-", "")
	
	If !Empty(uVal) .and. Len(AllTrim(uVal)) <= 11
		cPictVar := "@R 999.999.999-99"
	Else
		cPictVar := "@R 99.999.999/9999-99"
	Endif
	cPictVar += "%C"
Endif

Return cPictVar



//------------------------------------------------------------------------------
/* /{Protheus.doc} SendMail(aEmail)

@type Static Function
@author jacomo.fernandes
@since 05/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SendMail(aEmail)
Local n1        := 0
Local cFrom     := "noreplay@totvs.com.br"
Local cTo       := ""
Local cCc       := ""
Local cBcc      := ""
Local cSubject  := STR0047//"Retirada de Encomendas"
Local cBody     := ""
Local aAnexos   := {}
Local lUsrEmail := ExistBlock("G809EMAIL")
If GxVldParEmail()

    For n1 := 1 to Len(aEmail)


        cTo := aEmail[n1]["EMAIL"]
        

        If lUsrEmail

            ExecBlock("G809EMAIL", .f., .f., {aEmail[n1],@cFrom, @cTo, @cCc, @cBcc, @cSubject, @cBody, aAnexos})
			cFrom :=PARAMIXB[2]
			cTo :=	PARAMIXB[3]
			cCc :=	PARAMIXB[4]
			cBcc :=	PARAMIXB[5]
			cSubject := PARAMIXB[6]
			cBody := PARAMIXB[7]
			aAnexos := PARAMIXB[8]
        Else
            cBody := GetBodyEmail(aEmail[n1])
        Endif

        GTPXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, aAnexos) 
        
    Next
Else
    FwAlertHelp(STR0048,STR0049,STR0014)//"Parâmetros de email não cadastrados","Informe-os para realizar o envio de email","Atenção!!"
Endif

Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetBodyEmail

@type Static Function
@author jacomo.fernandes
@since 05/12/2019
@version 1.0
@param oDadosEmail, json, (Descrição do parâmetro)
@return cBody, Retorna o corpo do email
/*/
//------------------------------------------------------------------------------
Static Function GetBodyEmail(oDadosEmail)
Local cBody := ""

cBody += '<!doctype html>'
cBody += '<html lang="BR">'
cBody += '<body>'

cBody += "<br>"
cBody += "<p>"  
cBody += "<b>" + oDadosEmail["REMETENTE"]+"</b>,"
cBody += "</p>"
cBody += "<br>"

cBody += "<p>" 
cBody += "<b>"+oDadosEmail["DESTINATARIO"] +"</b>"+STR0050+"<b>"+oDadosEmail["PRODUTO"]+"</b>"//" retirou o produto: "
cBody += "</p>" 

cBody += "<p>" 
cBody += STR0051+'<b>'+oDadosEmail["SERIE"]+'</b>'+STR0052+'<b>'+oDadosEmail["NUMERO"]+'</b>'+STR0053+"<b>"+oDadosEmail["AGENCIA"]+"</b>" //'Série:'##' e Numero:'##" na agencia "
cBody += STR0054+'<b>'+DtoC(dDataBase)+"</b>"+STR0055+"<b>" + Time()+"</b>"//" na data: "##" às "
cBody += "</p>"

cBody += "<p><i>" 
cBody += STR0056//'Este e-mail foi enviado de um endereço de notificação, que não esta habilitado a receber mensagens. Por Favor, não responda esta mensagem.' 
cBody += "</i></p>"

cBody += '</body>'
cBody += '</html>'

Return cBody
