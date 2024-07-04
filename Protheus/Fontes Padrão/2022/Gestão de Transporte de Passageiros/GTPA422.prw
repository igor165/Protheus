#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA422.CH'

Static cSXBGI8RET	:= ""

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA422
Demostrativo de passagens 

@sample		GTPA422()

@author 		Yuki Shiroma
@since 			05/10/2017
@version 		P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA422()
	
Local oBrowse := Nil
	
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GY3')
oBrowse:AddLegend('GY3_STATUS == "1"',"GREEN"	,STR0007)  //"Baixado"
oBrowse:AddLegend('GY3_STATUS == "2"',"YELLOW"	,STR0008)//"Aberto"
oBrowse:SetDescription(STR0001)	//"Demostrativo de Passagens"
oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@sample		MenuDef()

@return		aRotina - Array de opções do menu

@author		Enaldo Cardoso
@since			02/10/2014
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	
Local aRotina := {}
	
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA422' OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA422' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA422' OPERATION 4 ACCESS 0	//'Alterar'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA422' OPERATION 5 ACCESS 0	//'Excluir'
	
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados.

@sample		ModelDef()

@return		oModel - Modelo de dados.

@author		Yuki Shiroma
@since			05/10/2017
@version		P12
/*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()
	
Local oModel	:= Nil
Local oStruGY3	:= FWFormStruct(1,'GY3')
Local oStruGIC	:= FWFormStruct(1,'GIC')
Local bLinePre	:= {|oMdlGIC,nLine,cAcao,cCampo|GTPA422PreLin(oMdlGIC,nLine,cAcao,cCampo)}
Local bCommit	:= {|oModel|GTPA422Grv(oModel)}
Local bPosValid	:= {|oModel|TP422TdOK(oModel)}

If !(GtpIsInPoui())
	oStruGY3:SetProperty('*', MODEL_FIELD_VALID, {|| .T. } ) 
EndIf

//gatilhos para realizar a carga do bilhete
oStruGY3:AddTrigger("GY3_CODEMI", "GY3_CODEMI"  ,{ || .T. }, { |oMdlGY3| A422TrigBil(oMdlGY3) } )
//Gatilho para realizar limpeza do campo numero movimento ao gatilhar tipo documento
oStruGY3:AddTrigger("GY3_TIPO", "GY3_TIPO"  ,{ || .T. }, { |oMdlGY3| A422TrigTp(oMdlGY3) } )
//Gatilho para descrição da agencia
oStruGY3:AddTrigger("GY3_CODAG", "GY3_DESAGE"  ,{ || .T. }, { |oMdlGY3| A422TrigAG(oMdlGY3) } )
//Gatilho para  realizar o recalculo
oStruGIC:AddTrigger("GIC_VLACER", "GIC_VLACER"  ,{ || .T. }, { |oMdlGIC,cCampo,xValue,nLinha| A422TrgTotAce(oMdlGIC,cCampo,xValue,nLinha) } )

//Validação do numero da sequencia do lote
oStruGY3:SetProperty('GY3_SEQLT', MODEL_FIELD_VALID, {|oMdlGY3| A422VldLt(oMdlGY3) } )

//Validação Agência/Usuário
oStruGY3:SetProperty('GY3_CODAG', MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue| ValidUserAg(oMdl,cField,cNewValue,cOldValue) } )


// Validação da data de entrega
oStruGY3:SetProperty('GY3_DTENTR', MODEL_FIELD_VALID, {|oMdlGY3| VldDtEntr(oMdlGY3) } ) 

oStruGY3:SetProperty("GY3_TPBILH" 	, MODEL_FIELD_INIT, {|| "1" }) //1=DAPE;2=Ficha Receita;3=Informatizadas                                                                                         

//Validação Emissor 
oStruGY3:SetProperty('GY3_CODEMI', MODEL_FIELD_VALID, {|oMdl,cField,cNewValue,cOldValue|A422VldTB(oMdl,cField,cNewValue,cOldValue) } )

oStruGY3:SetProperty('GY3_CODEMI',MODEL_FIELD_OBRIGAT, .T. )

oStruGIC:SetProperty("*",MODEL_FIELD_OBRIGAT, .F. )

oModel := MPFormModel():New('GTPA422',/*bPreValid*/,bPosValid ,/*bCommit*/,/*bCancel*/)
oModel:SetCommit(bCommit)	

oModel:AddFields('GY3MASTER',/*cOwner*/,oStruGY3)

oModel:AddGrid('GICDETAIL','GY3MASTER',oStruGIC, bLinePre, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:GetModel('GICDETAIL'):SetMaxLine(999999)
oModel:GetModel("GICDETAIL"):SetUniqueLine({"GIC_CODIGO"})
oModel:GetModel('GICDETAIL'):SetOptional(.T.)
oModel:GetModel("GICDETAIL"):SetOnlyQuery(.T.) 

oModel:SetDescription(STR0001)	//"Demostrativo de Passagens"
oModel:GetModel('GY3MASTER'):SetDescription(STR0001)	//"Demostrativo de Passagens"

oModel:GetModel("GICDETAIL"):SetNoInsertLine(.T.)

//Validação na ativação do modelo
oModel:SetVldActivate({|oModel| GA422VldAc(oModel)})
oModel:SetRelation( 'GICDETAIL', { { 'GIC_FILIAL', 'xFilial( "GIC" )' }, { 'GIC_CODGY3', 'GY3_CODIGO' } }, GIC->(IndexKey(8)))
		
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface.

@sample		ViewDef()

@return		oView - Retorna a View

@author		Yuki Shiroma
@since			05/10/2014
@version		P12
/*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()
	
Local oModel	:= ModelDef()
Local oView		:= FWFormView():New()
Local oStruGY3	:= FWFormStruct(2, 'GY3')
Local oStruGIC	:= FWFormStruct(2, 'GIC')

oStruGIC:SetProperty("GIC_CODIGO", MODEL_FIELD_INIT, {|| (.F.)})
//Removendo os campos da GIC
oStruGIC:RemoveField("GIC_CODGY3")
oStruGIC:RemoveField("GIC_DTVIAG")
oStruGIC:RemoveField("GIC_ECF")
oStruGIC:RemoveField("GIC_DTVIAG")
oStruGIC:RemoveField("GIC_HORA")
oStruGIC:RemoveField("GIC_AGENCI")
oStruGIC:RemoveField("GIC_COLAB")
oStruGIC:RemoveField("GIC_NCOLAB")
oStruGIC:RemoveField("GIC_DESAGE")
oStruGIC:RemoveField("GIC_REQDSC")
oStruGIC:RemoveField("GIC_MOTCAN")
oStruGIC:RemoveField("GIC_CODREQ")
oStruGIC:RemoveField("GIC_CARGA")
oStruGIC:RemoveField("GIC_BILREF")
oStruGIC:RemoveField("GIC_HRVEND")
oStruGIC:RemoveField("GIC_SERIE")
oStruGIC:RemoveField("GIC_SUBSER")
oStruGIC:RemoveField("GIC_NUMCOM")
oStruGIC:RemoveField("GIC_TIPDOC")
oStruGIC:RemoveField("GIC_NOTA")
oStruGIC:RemoveField("GIC_CLIENT")
oStruGIC:RemoveField("GIC_LOJA")
oStruGIC:RemoveField("GIC_STAPRO")
oStruGIC:RemoveField("GIC_FILNF")
oStruGIC:RemoveField("GIC_SERINF")
oStruGIC:RemoveField("GIC_REQTOT")
oStruGIC:RemoveField("GIC_MOTREJ")
oStruGIC:RemoveField("GIC_NUMDOC")
oStruGIC:RemoveField("GIC_CODGQ6")
oStruGIC:RemoveField("GIC_PERCOM")
oStruGIC:RemoveField("GIC_PERIMP")
oStruGIC:RemoveField("GIC_VALCOM")
oStruGIC:RemoveField("GIC_VALIMP")

oStruGY3:RemoveField("GY3_TOTACE")
oStruGY3:RemoveField("GY3_CODARR")
oStruGY3:RemoveField("GY3_CODGQ6")
oStruGY3:RemoveField("GY3_TPBILH")


oStruGY3:SetProperty('GY3_CODIGO', MVC_VIEW_CANCHANGE, .F.)

oStruGIC:SetProperty('*', MVC_VIEW_CANCHANGE , .F. )
//oStruGIC:SetProperty('GIC_VLACER', MVC_VIEW_CANCHANGE , .T. )

oView:SetModel(oModel)

oView:SetDescription(STR0001)	//"Demostrativo de Passagens"

oView:AddField('VIEW_GY3' ,oStruGY3,'GY3MASTER')

oView:AddGrid('VIEW_GIC' ,oStruGIC,'GICDETAIL')

oView:addUserButton("Imprimir DAPE"	, "", {|| FwMsgRun(,{|| GTPR019()},"Impressão DAPE","Aguarde...." )}   ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} )	
oView:addUserButton("Carrega Bilhete"	, "", {|oView| VldLoadBil(oView) }   ,,,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} )

oView:CreateHorizontalBox('TELA', 40)
oView:CreateHorizontalBox('GRID', 60)
oView:SetOwnerView('VIEW_GY3','TELA')
oView:SetOwnerView('VIEW_GIC','GRID')

GA422FldOrd(oStruGY3)

Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface.

@sample		ViewDef()

@return		oView - Retorna a View

@author		Yuki Shiroma
@since			05/10/2014
@version		P12
/*/
//------------------------------------------------------------------------------------------
Function A422TrigBil(oMdlGY3)

Local oModel	:= oMdlGY3:GetModel()
Local oMdlGIC	:= oModel:GetModel("GICDETAIL")
Local nA		:= 0
If !oMdlGIC:IsEmpty() 
	For nA	:= 1 to oMdlGIC:Length()
				
		If	!oMdlGIC:IsDeleted(nA)
			oMdlGIC:GoLine(nA)
			oMdlGIC:DeleteLine()
		EndIf	

	Next
	
	oMdlGIC:ClearData()

EndIf


Return oMdlGY3:GetValue('GY3_CODEMI')

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA422PreLin
Validação para nao poder deletar linha ja deleta relacionada a outra registro

@param 		oMdlG55 modelo da alias G55
			nLine Linha da grid
			cAcao Ação realizada na linha
			cCampo nome do campo posicionado 
			
@sample		GTPA422PreLin()
@return		Gerar Serviços
@author		Inovação 
@since		17/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function GTPA422PreLin(oMdlGIC,nLine,cAcao,cCampo)
Local oModel	:= FwModelActive()
Local lRet		:= .T.
Local nPed		:= 0
Local nPedTab	:= 0
Local nTar		:= 0
Local nTarTab	:= 0
Local nTax		:= 0
Local nTaxTab	:= 0
Local nSegFac	:= 0
Local nSgTab	:= 0	
Local nOutVl	:= 0
Local nVlTot	:= 0

If cAcao == "DELETE" .And. !oMdlGIC:IsDeleted()
	//Realiza o recalculo do valor total e valor de acerto quando a linha for deletada
	nPed		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TOTPED") - oMdlGIC:GetValue("GIC_PED")
	nPedTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TPEDTB") - oMdlGIC:GetValue("GIC_PEDTAB")
	nTar		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TOTTAR") - oMdlGIC:GetValue("GIC_TAR")
	nTarTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TTARTB") - oMdlGIC:GetValue("GIC_TARTAB")
	nTax		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TTXEMB") - oMdlGIC:GetValue("GIC_TAX")
	nTaxTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TTXEBT") - oMdlGIC:GetValue("GIC_TAXTAB")
	nSegFac		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TSGFAC") - oMdlGIC:GetValue("GIC_SGFACU")
	nSgTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TSGFCT") - oMdlGIC:GetValue("GIC_SGTAB ")
	nOutVl		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_OTVL") - oMdlGIC:GetValue("GIC_OUTTOT")
	nVlTot		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_VALTOT") - oMdlGIC:GetValue("GIC_VALTOT")

/*	If oMdlGIC:GetValue("GIC_VLACER") != 0
		nTotAce		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TOTACE")  - oMdlGIC:GetValue("GIC_VLACER")
	ElseIf oMdlGIC:GetValue("GIC_VLACER") == 0
		nTotAce = nVlTot
	EndIf
*/

	oModel:GetModel("GY3MASTER"):SetValue("GY3_TTARTB",nTarTab)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TTXEBT",nTaxTab)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TPEDTB",nPedTab)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TSGFCT",nSgTab)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTTAR",nTar)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TTXEMB",nTax)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTPED",nPed)
	oModel:GetModel("GY3MASTER"):LoadValue("GY3_TSGFAC",nSegFac)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_OTVL",nOutVl)
	oModel:GetModel("GY3MASTER"):SetValue("GY3_VALTOT",nVlTot)
//	oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTACE",nTotAce)
	
ElseIf cAcao == "UNDELETE" 

	If oModel:GetModel("GY3MASTER"):GetValue("GY3_TPBILH") == "1"
		If !(oMdlGIC:GetValue("GIC_TIPO")  == "E" .And. oMdlGIC:GetValue("GIC_ORIGEM") == "1")
			lRet	:= .F.
		EndIf
	ElseIf oModel:GetModel("GY3MASTER"):GetValue("GY3_TPBILH") == "2"
		If !(oMdlGIC:GetValue("GIC_TIPO") != "E" .And. oMdlGIC:GetValue("GIC_ORIGEM") == "1")
			lRet	:= .F.
		EndIf
	ElseIf oModel:GetModel("GY3MASTER"):GetValue("GY3_TPBILH") == "3"
		If  !(oMdlGIC:GetValue("GIC_ORIGEM") == "2")
			lRet	:= .F.
		EndIf
	EndIf
	If lRet
		//Realiza o recalculo do valor total e valor de acerto quando a linha for desdeletada
		nPed		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TOTPED") + oMdlGIC:GetValue("GIC_PED")
		nPedTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TPEDTB") + oMdlGIC:GetValue("GIC_PEDTAB")
		nTar		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TOTTAR") + oMdlGIC:GetValue("GIC_TAR")
		nTarTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TTARTB") + oMdlGIC:GetValue("GIC_TARTAB")
		nTax		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TTXEMB") + oMdlGIC:GetValue("GIC_TAX")
		nTaxTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TTXEBT") + oMdlGIC:GetValue("GIC_TAXTAB")
		nSegFac		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TSGFAC") + oMdlGIC:GetValue("GIC_SGFACU")
		nSgTab		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TSGFCT") + oMdlGIC:GetValue("GIC_SGTAB ")
		nOutVl		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_OTVL") + oMdlGIC:GetValue("GIC_OUTTOT")
		nVlTot		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_VALTOT") + oMdlGIC:GetValue("GIC_VALTOT")
/*		If oMdlGIC:GetValue("GIC_VLACER") != 0
			nTotAce		:= nTotAce		:= oModel:GetModel("GY3MASTER"):GetValue("GY3_TOTACE") + oMdlGIC:GetValue("GIC_VLACER")
		ElseIf oMdlGIC:GetValue("GIC_VLACER") == 0
			nTotAce = nVlTot
		EndIf
*/		
		//Realiza a carga do totalizador 
		oModel:GetModel("GY3MASTER"):SetValue("GY3_TTARTB",nTarTab)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_TTXEBT",nTaxTab)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_TPEDTB",nPedTab)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_TSGFCT",nSgTab)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTTAR",nTar)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_TTXEMB",nTax)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTPED",nPed)
		oModel:GetModel("GY3MASTER"):LoadValue("GY3_TSGFAC",nSegFac)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_OTVL",nOutVl)
		oModel:GetModel("GY3MASTER"):SetValue("GY3_VALTOT",nVlTot)
//		oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTACE",nTotAce)
	Else
		Help( ,, 'Help',"GTPA422PreLin", STR0012, 1, 0 )//"Não foi possivel desdeletar o bilhete, pois nao é o mesmo tipo de bilhete selecionado no demostrativo"
	EndIf		
EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA422Grv

Bloco de commit customizado, para relizar o vinculo do demostrativo 
com o bilhetes e sequencia do lote selecionado e desvincula na hora 
da deleção

@param 		oModel 
			
@sample		A422TrigAG()
@author		Yuki Shiroma 
@since		17/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function GTPA422Grv(oModel)

Local oModelGIC  := FWLoadModel("GTPA115")
Local oGridGIC   := oModel:GetModel('GICDETAIL')
Local oModelGII	 := FWLoadModel("GTPA102B")
Local nI         := 1
Local lRet 		 := .T. 
Local lGTPA500  := FWIsInCallStack("GTPA500")

If (!lGTPA500)
	GIC->(DBSetOrder(1)) // GIC_FILIAL + GIC_CODIGO

	//Altera a operação para modo de update 
	oModelGIC:SetOperation(MODEL_OPERATION_UPDATE)
	oModelGII:SetOperation(MODEL_OPERATION_UPDATE)

	Begin Transaction
		//Realiza busca de cada bilhete adicionada no grid
		
		For nI := 1 To oGridGIC:Length()
			If GIC->(DBSeek(xFilial("GIC") + oGridGIC:GetValue("GIC_CODIGO", nI) )) 
				//Ativa o modelo
			oModelGIC:Activate()

				// Na inserção ou alteração do demostrativo o código deve ser atualziado no bilhete  
				If !oGridGIC:IsDeleted(nI) .AND. oModel:GetOperation() <> 5
					oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CODGY3"  , oModel:GetModel("GY3MASTER"):GetValue("GY3_CODIGO"))
			//     oModelGIC:GetModel("GICMASTER"):SetValue("GIC_VLACER"   , oGridGIC:GetValue("GIC_VLACER", nI))
					
				ElseIf oGridGIC:IsDeleted(nI) .And. !Empty(oModelGIC:GetModel("GICMASTER"):GetValue("GIC_CODGY3", nI))
					//na hora de deleção tirar todo vinculo com demostrativo
					oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CODGY3"  , "")
			//     oModelGIC:GetModel("GICMASTER"):SetValue("GIC_VLACER"   , 0.00)
				Else
					//na hora de deleção tirar todo vinculo com demostrativo
					oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CODGY3"  , "")
			//      oModelGIC:GetModel("GICMASTER"):SetValue("GIC_VLACER"   , 0.00)
				EndIf
				
				// Commit do FIELD
				If (lRet := oModelGIC:VldData())
					lRet := oModelGIC:CommitData()
				EndIf
				
				//Caso de erro exibi a msg rollback no commit
				If (!lRet)
					JurShowErro( oModelGIC:GetErrormessage() )	
					DisarmTransaction()
					EXIT
				EndIf 
				
				// Desativa o modelo
				oModelGIC:DeActivate()
			Endif
		Next nI
		
		//Realiza busca da sequência do lote de acordo com demostrativo 
		GII->(DBSetOrder(2))
		If GII->(DBSeek(xFilial("GII") + oModel:GetModel("GY3MASTER"):GetValue("GY3_LOTE") + oModel:GetModel("GY3MASTER"):GetValue("GY3_SEQLT") )) .AND. oModel:GetOperation() <> 5 
			//ativa o modelo
			oModelGII:Activate()
			
			//Adiciona o vinculo GII com GY3
			oModelGII:GetModel("GIIMASTER"):SetValue("GII_CODGY3"   , oModel:GetModel("GY3MASTER"):GetValue("GY3_CODIGO"))
			// Flag como utilizado
			oModelGII:GetModel("GIIMASTER"):SetValue("GII_UTILIZ"   , .T.)
			
			//Realiza o commit
			If (lRet := oModelGII:VldData())
				lRet := oModelGII:CommitData()
			EndIf
			
			//Verifica se houve erro no commit
			If (!lRet)
				JurShowErro( oModelGII:GetErrormessage() )	
				DisarmTransaction()
			EndIf 
			
			oModelGII:DeActivate()
		//Caso for uma deleção remover o vinculo com GII	
		Else	 
		
			oModelGII:Activate()
			//Remove o vinculo com GY3 e GII
			oModelGII:GetModel("GIIMASTER"):SetValue("GII_CODGY3"   , "")
			oModelGII:GetModel("GIIMASTER"):SetValue("GII_UTILIZ"   , .F.)
			If (lRet := oModelGII:VldData())
				lRet := oModelGII:CommitData()
			EndIf
			//Verifica se houve erro no commit
			If (!lRet)
				JurShowErro( oModelGII:GetErrormessage() )	
				DisarmTransaction()
			EndIf 
			
			oModelGII:DeActivate()
		EndIf
		// Destrói instância de oModelGIC e oModelGII
		oModelGIC:Destroy()
		oModelGII:Destroy()

		If (lRet)
			// Faz o commit do modelo todo 
		lRet	:= FWFormCommit(oModel)    
		EndIf
		
		If (!lRet)
			JurShowErro( oModel:GetErrormessage() )	
			DisarmTransaction()
		EndIf 
		
	End Transaction 
Else
	FWFormCommit(oModel) 
EndIF
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TP422TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP422TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGY3	:= oModel:GetModel('GY3MASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGY3:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGY3:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GY3", oMdlGY3:GetValue("GY3_CODIGO")))
		Help( ,, 'Help',"TP422TdOK", STR0006, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} A422VldLt

Realiza validação se sequência do lote e valido
para o lote selecionando

@param	oMdlGY3

@author Yuki Shiroma
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function A422VldLt(oMdlGY3)

Local lRet		:= .T.
Local cAgencia  := oMdlGY3:GetValue("GY3_CODAG")
Local cTpDoc	:= oMdlGY3:GetValue("GY3_TIPO")
Local cSerie	:= oMdlGY3:GetValue("GY3_SERIE")
Local cSubSer	:= oMdlGY3:GetValue("GY3_SUBSER")
Local cNumCom	:= oMdlGY3:GetValue("GY3_COMPL")
Local cLote     := oMdlGY3:GetValue("GY3_LOTE")
Local cSeqLt    := oMdlGY3:GetValue("GY3_SEQLT")
Local dDtEmiss  := oMdlGY3:GetValue("GY3_DTENTR")

If !GA115VldCtr(cAgencia,cTpDoc, cSerie, cSubSer, cNumCom, cSeqLt, dDtEmiss)
    lRet := .F.
Endif

If lRet
	GII->(DBSetOrder(2))
	//Verifica a sequencia do papel relacionando lote selecionado
	If !GII->(DBSeek(xFilial("GII") + cLote + cSeqLt ))
		lRet	:= .F.
	//Verifica se a sequência não está vinculado
	ElseIf !Empty(GII->GII_CODGY3 )
		lRet	:= .F.
	EndIF
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A422TrgTotAce

Gatilho Resposanvel para realizar o calculo do valor total de acerto 
de acordo com novo valor de acerto informado pelo usuário

@param	oMdlGY3

@author Yuki Shiroma
@since 23/10/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Function A422TrgTotAce(oMdlGIC,cCampo,xValue,nLinha)
Local oModel	:= FwModelActive()
Local nTotAce	:= 0
Local nY		:= 0
//Realiza o calculo do valor do acerto
For nY := 1 to oMdlGIC:Length()
	If oMdlGIC:GetValue("GIC_VLACER", nY) != 0
		nTotAce	= (oMdlGIC:GetValue("GIC_VLACER", nY) - oMdlGIC:GetValue("GIC_VALTOT", nY)) + nTotAce
	EndIF
Next

//Caso o valor for igual a zero valor total de acerto será mesma do valor total
If 	nTotAce != 0
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTACE",oModel:GetModel("GY3MASTER"):GetValue("GY3_VALTOT") + (nTotAce))	
ElseIF 	nTotAce == 0
	oModel:GetModel("GY3MASTER"):SetValue("GY3_TOTACE",oModel:GetModel("GY3MASTER"):GetValue("GY3_VALTOT"))	
EndIf
Return (xValue)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA422VldDt

Verifica se o demostrativo ja está baixado, 
assim não podendo sera possivel realizar alteração

@param	cDataIni, cDataFim

@author Yuki Shiroma
@since 23/10/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function GA422VldAc(oModel)
Local lRet		:= .T.
Local oMdlGY3	:= oModel:GetModel("GY3MASTER")
Local lGTPA500  := FWIsInCallStack("GTPA500")

If !lGTPA500
	//Verifica se demostrativo selecionado para alteração está baixada, caso estiver baixada não será possivel realizar a alteração
	If oMdlGY3:GetOperation() == MODEL_OPERATION_UPDATE .Or. oMdlGY3:GetOperation() == MODEL_OPERATION_DELETE
		If GY3->GY3_STATUS == "1"
			Help( ,, 'Help',"GA422VldAc", STR0011, 1, 0 )//O demostrativo selecionado já foi baixada, não será possivel realizar a operação
			lRet	:= .F.
		EndIf
	EndIf
	//Verifica se demostrativo selecionado para exclusão nao está vinculado a uma arrecadação	
	If oMdlGY3:GetOperation() == MODEL_OPERATION_DELETE
		If !Empty(GY3->GY3_CODARR)
			Help( ,, 'Help',"GA422VldAc", STR0016, 1, 0 )//"O Demostrativo selecionado está vinculada a arrecadação, não será possivel realizar a operação"
			lRet	:= .F.
		EndIf 
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A422TrigTp

Limpa os campos ao selecionar tipo de documento

@param	oMdlGY3

@author Yuki Shiroma
@since 23/10/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Function A422TrigTp(oMdlGY3)

oMdlGY3:ClearField("GY3_LOTE")
oMdlGY3:ClearField("GY3_SERIE")
oMdlGY3:ClearField("GY3_SUBSER")
oMdlGY3:ClearField("GY3_COMPL")
oMdlGY3:ClearField("GY3_SEQLT")
oMdlGY3:ClearField("GY3_CODAG")
oMdlGY3:ClearField("GY3_DESAGE")

Return (oMdlGY3:Getvalue("GY3_TIPO"))

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A422TrigAG
Realiza gatilho para agêcia vinculada ao lote selecionando 

@param 		oMdlGY3 modelo da alias GY3
			
@sample		A422TrigAG()
@author		Yuki Shiroma 
@since		17/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function A422TrigAG(oMdlGY3)

oMdlGY3:ClearField("GY3_LOTE")
oMdlGY3:ClearField('GY3_SEQLT')
oMdlGY3:ClearField('GY3_SERIE')
oMdlGY3:ClearField('GY3_SUBSER')
oMdlGY3:ClearField('GY3_COMPL')

oMdlGY3:SetValue('GY3_CODEMI',"")
	
Return (POSICIONE("GI6", 1, XFILIAL("GI6") + oMdlGY3:GetValue("GY3_CODAG") , "GI6_DESCRI"))

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A422VldTB
Verifica se o campo cod emitente foi preenchido, 
caso foi escolhido opção 1 - DAPE no tipo de bilhete

@param 		oMdlGY3 modelo da alias GY3
			
@sample		A422VldTB()
@author		Yuki Shiroma 
@since		17/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function A422VldTB(oMdl,cField,cNewValue,cOldValue)
Local oModel	:= oMdl:GetModel()
Local oMdlGIC	:= oModel:GetModel('GICDETAIL')
Local lRet		:= .T.

lRet:= ExistCpo('GYG',cNewValue)

If  lRet .AND.  !oMdlGIC:IsEmpty() .and. cNewValue <> cOldValue
	lRet	:= FwAlertYesNo( STR0009 + CRLF + STR0010)//"Ao alterar os dados, a grid será recarregada." "Deseja continuar?"
EndIf
If !lRet 
	oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"A422VldTB","Não foi possivel alterar o Emitente")
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A422VldCOL

Verifica se colaborador acertado está vinculado agência selecionada

@param 		oMdlGY3 modelo da alias GY3
			
@sample		A422VldCOL()
@author		Yuki Shiroma 
@since		17/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function A422VldCOL()
Local lRet		:= .T.
Local oModel	:= FwModelActive()
Local oMdlGY3	:= oModel:GetModel("GY3MASTER")

GYG->(DBSetOrder(1))

If GYG->(DBSeek(xFilial("GYG") + oMdlGY3:GetValue("GY3_CODACE") ))
	If !(GYG->GYG_AGENCI == oMdlGY3:GetValue("GY3_CODAG"))
		lRet	:= .F.
	EndIf
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDtEntr

Valida se a data de entrega está em um período válido
para o lote selecionando

@param	oMdlGY3

@author Flavio Martins
@since 27/02/2018
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function VldDtEntr(oMdlGY3)
Local lRet			:=	.T.
//Local cAgencia	:=	oMdlGY3:GetValue('GY3_CODAG')
//Local dDataEntr	:=	oMdlGY3:GetValue('GY3_DTENTR')
//Local aFechPeri	:=	GTPFechPeri(cAgencia)
//Local cStatus		:=	aFechPeri[2]
//Local dDataIni	:=	aFechPeri[3]
//Local dDataFim	:=	aFechPeri[4]
 
/* Retirado temporariamente para permitir digitação das DAPE's pela arrecadação
	If cStatus <> '0'
	
		If dDataEntr < dDataFim

			FwAlertHelp("Data de entrega está fora do período permitido.","Utilize uma data dentro de um período válido.") 		
			lRet := .F.
		
		Endif	
		
		If dDataEntr == dDataFim .And. cStatus > '1'

			FwAlertHelp("Status da Ficha de Remessa para esta data não permite a utilização.","Data de Entrega deve estar dentro de um período aberto.") 		
			lRet := .F.
		
		Endif	
		
	Endif */
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA422FldOrd
Ajusta a ordem dos campos da DAPE

@param	oStruGY3

@author Flavio Martins
@since 27/02/2018
@version 12.0
/*/
Static Function GA422FldOrd(oStruGY3)
Local aOrdemCpo	:= {}

AADD(aOrdemCpo, {"GY3_CODIGO",	"GY3_TIPO"})
AADD(aOrdemCpo, {"GY3_TIPO",	"GY3_DESTP"})
AADD(aOrdemCpo, {"GY3_DESTP",	"GY3_CODAG"})
AADD(aOrdemCpo, {"GY3_CODAG",	"GY3_DESAGE",})
AADD(aOrdemCpo, {"GY3_DESAGE",	"GY3_SERIE"})
AADD(aOrdemCpo, {"GY3_SERIE",	"GY3_SUBSER"})
AADD(aOrdemCpo, {"GY3_SUBSER",	"GY3_COMPL"})
AADD(aOrdemCpo, {"GY3_COMPL",	"GY3_LOTE"})
AADD(aOrdemCpo, {"GY3_LOTE",	"GY3_SEQLT"})
AADD(aOrdemCpo, {"GY3_SEQLT",	"GY3_DTENTR"})
AADD(aOrdemCpo, {"GY3_DTENTR",	"GY3_CODEMI"})
AADD(aOrdemCpo, {"GY3_CODEMI",	"GY3_DESEMI"})
AADD(aOrdemCpo, {"GY3_DESEMI",	"GY3_CODACE"})
AADD(aOrdemCpo, {"GY3_CODACE",	"GY3_DESACE"})

GTPOrdVwStruct(oStruGY3, aOrdemCpo)

Return


FUNCTION GA422GTSXB(nOpc)
Local lRet		:= .F.
Local aRetorno 		:= {}
Local cQuery   		:= ""          
Local oLookUp  		:= Nil
Local cMVPAR		:= ReadVar()
Local nRet			:= 0
//Local oMldMaster	:=  FwModelActive()

If cMVPAR == "MV_PAR04" //Série
	cQuery := " SELECT DISTINCT GI8_SERIE" 
	cQuery += " FROM " + RetSqlName("GI8")
	cQuery += " WHERE GI8_FILIAL = '"+xFilial('GI8')+"' AND D_E_L_E_T_ = ' '"
	cQuery += " AND GI8_TPDOC = '"+MV_PAR03+"' "
	oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GI8_SERIE"})
	                                                       
	oLookUp:AddIndice("Série"		, "GI8_SERIE")
	nRet := 1
ElseIf cMVPAR == "MV_PAR05" //Sub Série
	cQuery := " SELECT DISTINCT GI8_SERIE, GI8_SUBSER" 
	cQuery += " FROM " + RetSqlName("GI8")
	cQuery += " WHERE GI8_FILIAL = '"+xFilial('GI8')+"' AND D_E_L_E_T_ = ' '"
	cQuery += " AND GI8_TPDOC = '"+MV_PAR03+"' "
	cQuery += " AND GI8_SERIE = '"+MV_PAR04+"' "
	oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GI8_SERIE", "GI8_SUBSER"})
	                                                       
	oLookUp:AddIndice("SERIE"		, "GI8_SERIE")
	oLookUp:AddIndice("SUBSER"		, "GI8_SUBSER")
	nRet	:= 2
	
ElseIf cMVPAR == "MV_PAR06" //Num Complemento
	cQuery := " SELECT DISTINCT GI8_SERIE, GI8_SUBSER,GI8_NUMCOM" 
	cQuery += " FROM " + RetSqlName("GI8")
	cQuery += " WHERE GI8_FILIAL = '"+xFilial('GI8')+"' AND D_E_L_E_T_ = ' '"
	cQuery += " AND GI8_TPDOC = '"+MV_PAR03+"' "
	cQuery += " AND GI8_SERIE = '"+MV_PAR04+"' "
	cQuery += " AND GI8_SUBSER = '"+MV_PAR05+"' "
	oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GI8_SERIE", "GI8_SUBSER","GI8_NUMCOM"})
	                                                       
	oLookUp:AddIndice("SERIE"		, "GI8_SERIE")
	oLookUp:AddIndice("SUBSER"		, "GI8_SUBSER")
	oLookUp:AddIndice("NUMCOM"		, "GI8_NUMCOM")
	nRet	:= 3
Endif

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	cSXBGI8RET := aRetorno[nRet]
EndIf   

FreeObj(oLookUp)

Return lRet

FUNCTION GA422RTSXB(nOpc)
Local cRet		:= ""
cRet:=	cSXBGI8RET
Return cRet


Static Function VldLoadBil(oView)
Local lOk		:= .T.
Local oMdlGY3	:= oView:GetModel():GetModel('GY3MASTER')
Local cCodColab	:= oMdlGY3:GetValue('GY3_CODEMI')
Local cCodAg	:= oMdlGY3:GetValue('GY3_CODAG')
Local dDtEntr	:= oMdlGY3:GetValue('GY3_DTENTR')

If Empty(cCodAg)
	FwAlertHelp('Agencia não informado','Para continuar o processo de carregamento de Bilhete, favor informar a Agencia','VldLoadBil')
	lOk := .F.
ElseIf Empty(cCodColab)
	FwAlertHelp('Colaborador não informado','Para continuar o processo de carregamento de Bilhete, favor informar o Colaborador Emitente','VldLoadBil')
	lOk := .F.
ElseIf Empty(dDtEntr)
	FwAlertHelp('Data de Entrega não informado','Para continuar o processo de carregamento de Bilhete, favor informar a Data de Entrega','VldLoadBil')
	lOk := .F.
Endif

If lOk .and. PERGUNTE('GTPA422',.T.)
	
	If !Empty(MV_PAR02) .and. dDtEntr < MV_PAR02 
		FwAlertHelp('Data Final de Emissão maior que a data de Entrega do documento','Para continuar o processo de carregamento de Bilhete, favor informar uma data final menor ou igual a data de Entrega','VldLoadBil')
		lOk := .F.
	Endif
	
	If lOk
		FwMsgRun(,{|| LoadBil(oView)},"Carrega Bilhete","Aguarde...." )
	Endif 
Endif

Return

Static Function LoadBil(oView)
Local oModel	:= oView:GetModel()
Local oMdlGY3	:= oModel:GetModel('GY3MASTER')
Local oMdlGIC	:= oModel:GetModel('GICDETAIL')
Local oStruGIC  := oMdlGIC:GetStruct()
Local aFldConv	:= {} 
Local cFields	:= GTPFld2Str(oStruGIC,.t.,aFldConv)
Local cAliasGIC	:= GetNextAlias()
Local cCodColab	:= oMdlGY3:GetValue('GY3_CODEMI')
Local cCodAg	:= oMdlGY3:GetValue('GY3_CODAG')
Local cQuery	:= ""
Local aGICStruct:= nil
Local n1		:= 0
	cFields:="%"+cFields+"%"
	
	If !Empty(MV_PAR01)//Data de Emissão Inicial
		cQuery += " AND GIC.GIC_DTVEND >= '"+DtoS(MV_PAR01)+"' "
	Endif
	
	If !Empty(MV_PAR02) //Data de Emissão Final
		cQuery += " AND GIC.GIC_DTVEND <= '"+DtoS(MV_PAR02)+"' "
	Endif
	
	If !Empty(MV_PAR03)//Tipo de Documento
		cQuery += " AND GIC.GIC_TIPDOC = '"+MV_PAR03+"' "
	Endif
	
	If !Empty(MV_PAR04)//Série
		cQuery += " AND GIC.GIC_SERIE = '"+MV_PAR04+"' "
	Endif
	
	If !Empty(MV_PAR05)//Sub Série
		cQuery += " AND GIC.GIC_SUBSER = '"+MV_PAR05+"' "
	Endif
	
	If !Empty(MV_PAR06)//Numero Complemento
		cQuery += " AND GIC.GIC_NUMCOM = '"+MV_PAR06+"' "
	Endif
	
	
	If !Empty(MV_PAR07) .or. !Empty(MV_PAR08) //Numero do bilhete inicial e final
		cQuery += " AND GIC.GIC_NUMDOC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	Endif
	
	cQuery	:= "%"+cQuery+"%"
	
	BeginSql Alias cAliasGIC
	
		SELECT %Exp:cFields%
		FROM %Table:GIC% GIC
		WHERE 
  			GIC.GIC_FILIAL = %xFilial:GIC%
  			AND GIC.GIC_STATUS NOT IN ('C','D','I')
		  	AND GIC.GIC_TIPO 	= 'E'
		  	AND GIC.GIC_ORIGEM 	= '1'
			AND GIC.GIC_CODGY3 	= ''
  			AND GIC.GIC_COLAB 	= %Exp:cCodColab%
		  	AND GIC.GIC_AGENCI 	= %Exp:cCodAg%
		  	AND GIC.%NotDel%
		  	%Exp:cQuery%
		ORDER BY GIC.GIC_CODIGO	
	
	EndSql
	
	If (cAliasGIC)->(!EoF())
		oModel:GetModel("GICDETAIL"):SetNoInsertLine(.F.)
		aGICStruct:= (cAliasGIC)->(DbStruct())
		DelGIC(oModel)
		
		While (cAliasGIC)->(!EoF())
			
			If !oMdlGIC:SeekLine({{'GIC_CODIGO',(cAliasGIC)->GIC_CODIGO}})
				If !oMdlGIC:IsEmpty() .and. !Empty(oMdlGIC:GetValue('GIC_CODIGO'))
					oMdlGIC:AddLine()
				Endif
				For n1 := 1 to Len(aGicStruct)
				    If oStruGIC:HasField(aGicStruct[n1][1])
				        oMdlGIC:LoadValue(aGicStruct[n1][1],GTPCastType(&(aGicStruct[n1][1]),TamSx3(aGicStruct[n1][1])[3] ))
				    Endif
				Next
				oMdlGIC:LoadValue("GIC_NLOCDE", Posicione('GI1' ,1 ,xFilial("GI1") + oMdlGIC:GetValue("GIC_LOCDES"), "GI1_DESCRI"))
				oMdlGIC:LoadValue("GIC_NLOCOR", Posicione('GI1', 1, xFilial("GI1") + oMdlGIC:GetValue("GIC_LOCORI"), "GI1_DESCRI"))
				oMdlGIC:LoadValue("GIC_NLINHA", TPNOMELINH((cAliasGIC)->GIC_LINHA))
				
				oMdlGY3:LoadValue("GY3_TTARTB"	, oMdlGY3:GetValue("GY3_TTARTB") + (cAliasGIC)->GIC_TARTAB	)
				oMdlGY3:LoadValue("GY3_TTXEBT"	, oMdlGY3:GetValue("GY3_TTXEBT") + (cAliasGIC)->GIC_TAXTAB	)
				oMdlGY3:LoadValue("GY3_TPEDTB"	, oMdlGY3:GetValue("GY3_TPEDTB") + (cAliasGIC)->GIC_PEDTAB	)
				oMdlGY3:LoadValue("GY3_TSGFCT"	, oMdlGY3:GetValue("GY3_TSGFCT") + (cAliasGIC)->GIC_SGFACU	)
				oMdlGY3:LoadValue("GY3_TOTTAR"	, oMdlGY3:GetValue("GY3_TOTTAR") + (cAliasGIC)->GIC_TAR		)
				oMdlGY3:LoadValue("GY3_TTXEMB"	, oMdlGY3:GetValue("GY3_TTXEMB") + (cAliasGIC)->GIC_TAX		)
				oMdlGY3:LoadValue("GY3_TOTPED"	, oMdlGY3:GetValue("GY3_TOTPED") + (cAliasGIC)->GIC_PED 	)
				oMdlGY3:LoadValue("GY3_TSGFAC"	, oMdlGY3:GetValue("GY3_TSGFAC") + (cAliasGIC)->GIC_SGFACU	)
				oMdlGY3:LoadValue("GY3_OTVL"	, oMdlGY3:GetValue("GY3_OTVL"  ) + (cAliasGIC)->GIC_OUTTOT	)
				oMdlGY3:LoadValue("GY3_VALTOT"	, oMdlGY3:GetValue("GY3_VALTOT") + (cAliasGIC)->GIC_VALTOT	)
			Endif
			(cAliasGIC)->(DbSkip())
		End
		oModel:GetModel("GICDETAIL"):SetNoInsertLine(.T.)
	Else
		FwAlertçHelp('Não foram encontrados nenhum bilhete de acordo com os parametros informados')
	Endif
	oMdlGIC:GoLine(1)
	(cAliasGIC)->(DbCloseArea())
Return


Static Function DelGIC(oModel)
Local oMdlGY3	:= oModel:GetModel('GY3MASTER')
Local oMdlGIC	:= oModel:GetModel('GICDETAIL')
Local nA		:= 0

If !oMdlGIC:IsEmpty()
	IF FwAlertNoYes('Existem bilhetes ja preenchido, deseja sobrescreve-los?')
		
		oMdlGY3:LoadValue("GY3_TTARTB"	, 0)
		oMdlGY3:LoadValue("GY3_TTXEBT"	, 0)
		oMdlGY3:LoadValue("GY3_TPEDTB"	, 0)
		oMdlGY3:LoadValue("GY3_TSGFCT"	, 0)
		oMdlGY3:LoadValue("GY3_TOTTAR"	, 0)
		oMdlGY3:LoadValue("GY3_TTXEMB"	, 0)
		oMdlGY3:LoadValue("GY3_TOTPED"	, 0)
		oMdlGY3:LoadValue("GY3_TSGFAC"	, 0)
		oMdlGY3:LoadValue("GY3_OTVL"	, 0)
		oMdlGY3:LoadValue("GY3_VALTOT"	, 0)
		
		For nA	:= 1 to oMdlGIC:Length()
							
			If	!oMdlGIC:IsDeleted(nA)
				oMdlGIC:GoLine(nA)
				oMdlGIC:DeleteLine()
			EndIf	

		Next
		oMdlGIC:ClearData()
	Endif
Endif

Return
