#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TRMA220()
Cadastro de Servidores de Conteudo

@author Rogerio Ribeiro da Cruz
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function TRMA220()
	Local oMBrowse := FWMBrowse():New()	
	oMBrowse:SetAlias("RAT")
	oMBrowse:Activate()	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PESQBRW"         OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.TRMA220" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.TRMA220" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.TRMA220" OPERATION 4 ACCESS 143
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.TRMA220" OPERATION 5 ACCESS 144
	ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.TRMA220" OPERATION 8 ACCESS 0	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do modelo da regra de negocios

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := MPFormModel():New("TRMA220", NIL, NIL, {|oModel| TRMA220Commit(oModel)})
	Local oStructRAT := FWFormStruct(1, "RAT")
	oStructRAT:RemoveField("RAT_FILIAL")

	oModel:AddFields("TRMA220_RAT", NIL, oStructRAT)
	oModel:SetPrimaryKey({"RAT_CODIGO"})
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView := FWFormView():New()	
	Local oModel := FWLoadModel("TRMA220")	
	Local oStructRAT := FWFormStruct(2, "RAT")
	oStructRAT:RemoveField("RAT_FILIAL")
	
	oView:SetModel(oModel)
	oView:AddField("TRMA220_RAT", oStructRAT)   
	
	oView:CreateHorizontalBox("FIELDS", 100)
	
	oView:SetOwnerView("TRMA220_RAT", "FIELDS")
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} CommitTRMA220

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TRMA220Commit(oModel)
	Local oWSSrvCnt, oSrvCnt
	Local nOldSet := SetVarNameLen(255)
		
	FWFormCommit(oModel)

	If SuperGetMv("MV_TRMINTG", NIL, .F.)		
		oWSSrvCnt:= EPMWSNew("ServidorConteudo")
		
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .OR.;
		   oModel:GetOperation() == MODEL_OPERATION_INSERT

			oSrvCnt:= ServidorConteudoWSService_ServidorConteudoWSHolder():New()
			oSrvCnt:cCdExterno := oModel:GetModel("TRMA220_RAT"):GetValue("RAT_CODIGO")
			oSrvCnt:cDescricao := oModel:GetModel("TRMA220_RAT"):GetValue("RAT_DESC")
			oSrvCnt:cServidorConteudo := oModel:GetModel("TRMA220_RAT"):GetValue("RAT_OUTROS")
	        oSrvCnt:cServidorGravacao := oModel:GetModel("TRMA220_RAT"):GetValue("RAT_VIDEO")
	        oSrvCnt:cServidorPosTeste := oModel:GetModel("TRMA220_RAT"):GetValue("RAT_POSTES")
	        oSrvCnt:cServidorPreTeste := oModel:GetModel("TRMA220_RAT"):GetValue("RAT_PRETES")
	        oSrvCnt:cServidorRts := oModel:GetModel("TRMA220_RAT"):GetValue("RAT_SINCRO")			       

			If !oWSSrvCnt:InsertServidorConteudo(oSrvCnt)
				Alert("Erro: " + GetWSCError())
			ElseIf !Empty(oWSSrvCnt:cReturn)
				Alert("Erro: " + oWSSrvCnt:cReturn)
			EndIf
		ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
			If !oWSSrvCnt:deleteServidorConteudo( oModel:GetModel("TRMA220_RAT"):GetValue("RAT_CODIGO") )
				Alert("Erro: " + GetWSCError())
			ElseIf !Empty(oWSSrvCnt:cReturn)
				Alert("Erro: " + oWSCert:cReturn)
			EndIf		
		EndIf
	EndIf
	
	SetVarNameLen(nOldSet)		
Return .T.
