#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA631.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA631()
CheckList de Operacao
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA631()
Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias("SGR")
	oBrowse:SetDescription(STR0001) //CheckList de operações
	oBrowse:Activate()
 
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'ViewDef.MATA631' OPERATION 2 ACCESS 0 //Visualizar
//  A Inclusão do checklist é feita pelo mata632
//	ADD OPTION aRotina TITLE STR0003 ACTION 'ViewDef.MATA631' OPERATION 3 ACCESS 0 //Incluir
//  A opção de Altera é chamada no mata680/mata681 apresentando o checklist cadastrado e campos 
//  para o usuário marcar, os itens que já foram completados.
	ADD OPTION aRotina TITLE STR0004 ACTION 'ViewDef.MATA631' OPERATION 4 ACCESS 0 //Alterar
//  A exclusão do checklist é feita pelo mata632
//	ADD OPTION aRotina TITLE STR0005 ACTION 'ViewDef.MATA631' OPERATION 5 ACCESS 0 //Excluir

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCab  := FWFormStruct(1,"SGR",{|cCampo| !AllTrim(cCampo) $ "GR_ITCHK|GR_DESC"})
Local oStruSGR  := FWFormStruct(1,"SGR",{|cCampo| AllTrim(cCampo) $ "GR_ITCHK|GR_DESC"})
Local oModel    := Nil                                	

If FunName() != "MATA630"                             
	CamposFIL(.T.,@oStruSGR) //-- Carrega campo de conclusao checklist      
EndIf                                               

oModel:= MPFormModel():New("MATA631" ,  /*bPreValidacao*/  , { |oModel| A631PosMod( oModel ) } , { |oModel| A631Commit( oModel ) },/*Cancel*/)   
oModel:AddFields("MATA631_CAB",/*cOwner*/,oStruCab)
oModel:GetModel("MATA631_CAB"):SetDescription("Operação") //Operacao

oModel:AddGrid("MATA631_SGR","MATA631_CAB",oStruSGR,,{|oModel| A630LinOk(oModel)})
oModel:GetModel("MATA631_SGR"):SetDescription("CheckList") //CheckList

If FunName() = "MATA630"
	oModel:SetRelation("MATA631_SGR",{{"GR_FILIAL","xFilial('SGR')"},{"GR_PRODUTO","SG2->G2_PRODUTO"},{"GR_ROTEIRO","SG2->G2_CODIGO"},{"GR_OPERAC","aCols[n,GDFieldPos('G2_OPERAC')]"}},SGR->(IndexKey(1)))
Else
	oModel:SetRelation("MATA631_SGR",{{"GR_FILIAL","xFilial('SGR')"},{"GR_PRODUTO","M->H6_PRODUTO"},{"GR_ROTEIRO","c631Rot"},{"GR_OPERAC","M->H6_OPERAC"}},SGR->(IndexKey(1)))
	oModel:GetModel("MATA631_SGR"):SetNoInsertLine(.T.)
EndIf

oModel:GetModel("MATA631_SGR"):SetUniqueLine({"GR_ITCHK"})
oModel:GetModel("MATA631_SGR"):SetOptional(.T.)
oModel:SetPrimaryKey({})

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oStruCab := FWFormStruct(2,"SGR",{|cCampo| !AllTrim(cCampo) $ "GR_ITCHK|GR_DESC"})
Local oStruSGR := FWFormStruct(2,"SGR",{|cCampo| AllTrim(cCampo) $ "GR_ITCHK|GR_DESC"})
Local oModel := FWLoadModel("MATA631")

If FunName() != "MATA630"
	oStruSGR:SetProperty("*" , MVC_VIEW_CANCHANGE,.F.)
	CamposFIL(.F.,@oStruSGR) //-- Carrega campo de conclusao checklist      
EndIf  
	
oView := FWFormView():New()
oView:SetUseCursor(.F.)
oView:SetModel(oModel)
oView:EnableControlBar(.T.)

oView:AddField("HEADER_SGR",oStruCab,"MATA631_CAB")   
oView:CreateHorizontalBox("CABEC",10)
oView:SetOwnerView("HEADER_SGR","CABEC")

oView:AddGrid("GRID_SGR",oStruSGR,"MATA631_SGR")
oView:CreateHorizontalBox("GRID",90)
oView:SetOwnerView("GRID_SGR","GRID")
                                                      
oView:AddIncrementField( 'GRID_SGR', 'GR_ITCHK' )

Return oView                                       


//-------------------------------------------------------------------
/*/{Protheus.doc} A631TudoOk(oModel)
Valida Model para concluir com a inclusão
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return lRet (Continua com gravação)
/*/
//-------------------------------------------------------------------
Static Function A630LinOk(oModel)
Local cDesc  := AllTrim(oModel:GetValue("GR_DESC")) 
Local oGrid  := oModel:GetModel("MATA631_SGR")
Local lRet 	 := .T.

If Empty(cDesc) .And. Empty(oGrid:Length())
	Help(" ",1,"OBRIGAT2")		//"Descrição do Check List "
	lRet:= .F.
EndIf

Return lRet             

//-------------------------------------------------------------------
/*/{Protheus.doc} A128Commit()
Grava checkList no array aItensChk que sera gravado apenas na confirmacao
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A631Commit(oModel)
Local nOperation := oModel:GetOperation()      
Local nPosCab    := 0
Local nX		 := 0
Local nY    	 := 0
Local oEncho	 := oModel:GetModel("MATA631_CAB")
Local oGrid      := oModel:GetModel("MATA631_SGR")  
Local aSaveLines := FWSaveRows()
Local aCpsModel  := oGrid:GetStruct():GetFields()
Local lRet		 := .T.

If Type("aItensChk") == "A"
	If (nPosCab := aScan(aItensChk,{|x| x[1] == FWFldGet("GR_OPERAC")})) == 0
		aAdd(aItensChk,{FWFldGet("GR_OPERAC"),{}})
		nPosCab := Len(aItensChk)
	EndIf
	aItensChk[nPosCab,2] := {}
	For nX := 1 To oGrid:Length()
		oGrid:GoLine(nX)
		aAdd(aItensChk[nPosCab,2],Array(SGR->(FCount()) + 1))			
		For nY := 1 To Len(aCpsModel)
			aTail(aItensChk[nPosCab,2])[SGR->(FieldPos(aCpsModel[nY,3]))] := FwFldGet(aCpsModel[nY,3])
		Next nY
		aTail(aTail(aItensChk[nPosCab,2])) := oGrid:IsDeleted()
	Next nX	
EndIf                    

FWRestRows( aSaveLines )

Return .T.
    
    
//-------------------------------------------------------------------
/*/{Protheus.doc} A631PosMod()
Pos validacao de estrutura
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A631PosMod(oModel)
Local oGrid      := oModel:GetModel("MATA631_SGR")  
Local aSaveLines := FWSaveRows() 
Local aCpsModel  := oGrid:GetStruct():GetFields()
Local lRet		 := .T.   
Local nX		 := 0

If FunName() != "MATA630"
	For nX := 1 To oGrid:Length()
		oGrid:GoLine(nX)
		If !FwFldGet(aCpsModel[3,3])		
			Help(" ",1,"OBRIGAT2")		//"Descrição do Check List "
			lRet:= .F.
			Exit					
		EndIf
	Next nX	
EndIf 

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CamposFIL()
Monta estrutura de campo para modelo e view do marcador de checklist.
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CamposFIL(lModel,oStru)

If lModel //-- Instancia de modelo
	//-- Campo Concluido
	oStru:AddField(	"Concluido"      	,;	// [01]  C   Titulo do campo  - Produto
					"Concluido"			,;	// [02]  C   ToolTip do campo - Código do Produto
					"GR_CONCLUI"		,;	// [03]  C   Id do Field
					"L"					,;	// [04]  C   Tipo do campo
					1					,;	// [05]  N   Tamanho do campo
					0					,;	// [06]  N   Decimal do campo
					NIL					,;	// [07]  B   Code-block de validação do campo
					NIL					,;	// [08]  B   Code-block de validação When do campo
					NIL					,;  // [09]  A   Lista de valores permitido do campo
					.F.					,;  // [10]  L   Indica se o campo tem preenchimento obrigatório
					NIL					,;	// [11]  B   Code-block de inicializacao do campo
					NIL					,;	// [12]  L   Indica se trata-se de um campo chave
					NIL					,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.					)   // [14]  L   Indica se o campo é virtual

Else	//-- Instancia de view
	//-- Campo Concluido
	oStru:AddField(	"GR_CONCLUI"		,;	// [01]  C   Nome do Campo
					"08"				,;	// [02]  C   Ordem
					"Concluido" 		,;	// [03]  C   Titulo do campo
					"Concluido"			,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"L"					,;  // [06]  C   Tipo do campo
					""					,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.T.					,;	// [10]  L   Indica se o campo é alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.F.					,;	// [16]  L   Indica se o campo é virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo
					
EndIf

Return