#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TRMA230  ³ Autor ³Rogerio Ribeiro da Cruz³ Data ³ 09/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Conteudos dos cursos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TRMA230()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ Programador  ³Chamado³Manutencao Efetuada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³21.07.2014³Cecilia Carv. ³TPZSOX ³Incluido o fonte da 11 para a 12 e e-³±±
±±³          ³              ³       ³fetuada alimpeza.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//-------------------------------------------------------------------
Function TRMA230()
	Local oMBrowse := FWMBrowse():New()	
	oMBrowse:SetAlias("RAV")
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
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.TRMA230" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.TRMA230" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.TRMA230" OPERATION 4 ACCESS 143
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.TRMA230" OPERATION 5 ACCESS 144
	ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.TRMA230" OPERATION 8 ACCESS 0	
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
	Local oModel     := MPFormModel():New("TRMA230", NIL, Nil, {|oModel| TRMA230Commit(oModel)})
	Local oStructRAV := FWFormStruct(1, "RAV")
	oStructRAV:RemoveField("RAV_FILIAL")

	oModel:AddFields("TRMA230_RAV", NIL, oStructRAV)
	oModel:SetPrimaryKey({"RAV_CODIGO"})
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
	Local oModel := FWLoadModel("TRMA230")	
	Local oStructRAV := FWFormStruct(2, "RAV")
	oStructRAV:RemoveField("RAV_FILIAL")
		
	oView:SetModel(oModel)
	
	oView:AddField("TRMA230_RAV", oStructRAV)   	
	oView:CreateHorizontalBox("FIELDS", 100)	
	oView:SetOwnerView("TRMA230_RAV", "FIELDS")
Return oView






//-------------------------------------------------------------------
/*/{Protheus.doc} CommitTRMA230

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TRMA230Commit(oModel)
	Local oWSConteudo, oConteudo
	Local nOldSet := SetVarNameLen(255)	

	FWFormCommit(oModel)

	If SuperGetMv("MV_TRMINTG", NIL, .F.)
		oWSConteudo:= EPMWSNew("Conteudo")
		
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .OR.;
		   oModel:GetOperation() == MODEL_OPERATION_INSERT
		
			oConteudo						  := ConteudoWSService_ConteudoWSHolder():New()
			oConteudo:cCdExterno 			  := oModel:GetModel("TRMA230_RAV"):GetValue("RAV_CODIGO")
	        oConteudo:cSigla 				  := AllTrim(oModel:GetModel("TRMA230_RAV"):GetValue("RAV_CODIGO"))
	        oConteudo:cTitulo 				  := AllTrim(oModel:GetModel("TRMA230_RAV"):GetValue("RAV_TITULO"))
			oConteudo:cDescricao 			  := AllTrim(oModel:GetModel("TRMA230_RAV"):GetValue("RAV_DESC"))
			oConteudo:cCdContentServerExterno := oModel:GetModel("TRMA230_RAV"):GetValue("RAV_SRVCNT")
			If oModel:GetModel("TRMA230_RAV"):GetValue("RAV_TIPO") == "4"//Scorm
				oConteudo:cUrl 					  := RTrim( oModel:GetModel("TRMA230_RAV"):GetValue("RAV_URL") )
			ElseIf Empty( xFilial( "SQQ" ) )
	        	oConteudo:cUrl 					  := xFilial( "SQQ" ) + RTrim( oModel:GetModel("TRMA230_RAV"):GetValue("RAV_URL") )
	  		Else
	  			oConteudo:cUrl 					  := xFilial( "RAV" ) + RTrim( oModel:GetModel("TRMA230_RAV"):GetValue("RAV_URL") )
	  		EndIf
	        oConteudo:nTipoOAExterno 		  := Val(oModel:GetModel("TRMA230_RAV"):GetValue("RAV_TIPO"))	        
	        oConteudo:cCdIdiomaExterno 		  := GetLangType(oModel:GetModel("TRMA230_RAV"):GetValue("RAV_IDIOMA"))
			
			If !oWSConteudo:InsertConteudo(oConteudo)
				Alert("Erro: " + GetWSCError())
			ElseIf !Empty(oWSConteudo:cReturn)
				Alert("Erro: " + oWSConteudo:cReturn)
			EndIf
		ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
			oWSConteudo:deleteConteudo( oModel:GetModel("TRMA230_RAV"):GetValue("RAV_CODIGO") )
		EndIf
	EndIf
		
	SetVarNameLen(nOldSet)	
Return .T.

Function GetLangType(cType)
	Local cRet:= ""

	Do Case
		Case cType == "1"
			cRet:= "pt_BR"
		Case cType == "2"
			cRet:=  "en_US" 
		Case cType == "3"
			cRet:= "es_MX"
	EndCase	
Return cRet


