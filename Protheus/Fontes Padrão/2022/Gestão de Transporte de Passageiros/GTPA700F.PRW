#Include "GTPA700F.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"

/*/{Protheus.doc} GTPA700F()
 * chamada da view
 * type  Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param não há
 * return não há
/*/
Function GTPA700F()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //STR0001 //"Fechar"

If CHKFILE("GQN")
	FWExecView('', 'VIEWDEF.GTPA700F', MODEL_OPERATION_INSERT, , {|| .T. },,,aButtons,{|| GTP700Fech()})
Else 
	MsgAlert(STR0002, STR0003) //"Não é possivel gerar a consulta, tabela GQN não existe. " //"Atenção! "
EndIf

Return 


/*/{Protheus.doc} ModelDef()
 * modelo de dados 
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param não há
 * return oModel
/*/
Static Function ModelDef()
Local oModel := Nil
Local oCab   := FWFormModelStruct():New()
Local oGrid  := FWFormStruct(1, "GQN")

ModelStruct(oCab, oGrid)

oModel := MPFormModel():New('GTPA700F',/*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:SetDescription(STR0004) 

oModel:AddFields('CABMASTER',/*cOwner*/, oCab)
oModel:GetModel("CABMASTER"):SetDescription("Filtro")

oModel:AddGrid('GQNDETAIL','CABMASTER', oGrid)
oModel:GetModel("GQNDETAIL"):SetDescription(STR0004) //Saldos da conta corrente
oModel:GetModel('GQNDETAIL'):SetMaxLine(999999)

oModel:SetPrimarykey({})

Return oModel


/*/{Protheus.doc} ViewDef()
 * View
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param não há
 * return oView
/*/
Static Function ViewDef()
Local oView  := Nil
Local oCab   := FWFormViewStruct():New()
Local oGrid  := FWFormStruct(2, "GQN")  
Local oModel := FWLoadModel("GTPA700F")  

ViewStruct(oCab, oGrid)

oView := FWFormView():New()

oView:SetModel(oModel)	

oView:AddField("VIEW_CAB",oCab,"CABMASTER")
oView:AddGRID("VIEW_GRID",oGrid,"GQNDETAIL")

OView:GetModel('GQNDETAIL'):SetNoDeleteLine(.T.)
OView:GetModel('GQNDETAIL'):SetNoInsertLine(.T.)
OView:GetModel('GQNDETAIL'):SetNoUpdateLine(.T.)

oView:CreateHorizontalBox("SUPERIOR" , 15) // Filtro
oView:CreateHorizontalBox("INFERIOR" , 85) // Saldos da conta corrente

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_CAB", "SUPERIOR")

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_GRID", "INFERIOR")

oView:EnableTitleView("VIEW_GRID", STR0004)  //'Saldos da conta corrente'

oView:SetViewProperty("VIEW_GRID", "FILTCAB", {.T.})
oView:SetViewProperty("VIEW_GRID", "DIVGRID", {.T.}) 

oView:AddUserButton(STR0005, "", {|oView| ExecFilt(oView)},,VK_F5 )  //"Executar Filtro"
oView:AddUserButton(STR0006, "", {|oModel| GTPR700F(oModel)})  //"Imprimir"

Return oView


/*/{Protheus.doc} ModelStruct()
 * estrutura do modelo
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param oCab, oGrid
 * return não há
/*/
Static Function ModelStruct(oCab, oGrid)
Local bVld := {|| ZeraGrid()}

oGrid:AddTrigger("GQN_AGENCI", "GQN_DESCAG", {||.T.}, {|oMdl| GetAge(oMdl)})

If ValType(oCab) == "O"
    oCab:AddField(STR0007,; // [01]  C   Titulo do campo // "Codigo"
                  STR0008,; // [02]  C   ToolTip do campo // "Codigo"
                  "AGINI",;	// [03]  C   Id do Field
                  "C",;		// [04]  C   Tipo do campo
                  6,;		// [05]  N   Tamanho do campo
                  0,;		// [06]  N   Decimal do campo
                  bVld,;	// [07]  B   Code-block de validação do campo
                  Nil,;		// [08]  B   Code-block de validação When do campo
                  Nil,;		// [09]  A   Lista de valores permitido do campo
                  .F.,;		// [10]  L   Indica se o campo tem preenchimento obrigatório
                  Nil,;		// [11]  B   Code-block de inicializacao do campo
                  .F.,;		// [12]  L   Indica se trata-se de um campo chave
                  .F.,;		// [13]  L   Indica se o campo pode receber valor em uma operação de update.
                  .T.)		// [14]  L   Indica se o campo é virtual

	oCab:AddField(STR0009,; // 	[01]  C   Titulo do campo // "Codigo"
                  STR0010,; // 	[02]  C   ToolTip do campo // "Codigo"
                  "AGFIN",;	// 	[03]  C   Id do Field
                  "C",;		// 	[04]  C   Tipo do campo
                  6,;		// 	[05]  N   Tamanho do campo
                  0,;		// 	[06]  N   Decimal do campo
                  bVld,;	// 	[07]  B   Code-block de validação do campo
                  Nil,;		// 	[08]  B   Code-block de validação When do campo
                  Nil,;		//	[09]  A   Lista de valores permitido do campo
                  .F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
                  Nil,;		//	[11]  B   Code-block de inicializacao do campo
                  .F.,;		//	[12]  L   Indica se trata-se de um campo chave
                  .F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                  .T.)		// 	[14]  L   Indica se o campo é virtual
        
    oCab:AddField(STR0011,; // [01]  C   Titulo do campo // "Codigo"
                  STR0011,; // [02]  C   ToolTip do campo // "Codigo"
                  "DTDE",;  // [03]  C   Id do Field
                  "D",;	    // [04]  C   Tipo do campo
                  8,;	    // [05]  N   Tamanho do campo
                  0,;	    // [06]  N   Decimal do campo
                  bVld,;    // [07]  B   Code-block de validação do campo
                  Nil,;	    // [08]  B   Code-block de validação When do campo
                  Nil,;	    // [09]  A   Lista de valores permitido do campo
                  .F.,;	    // [10]  L   Indica se o campo tem preenchimento obrigatório
                  Nil,;	    // [11]  B   Code-block de inicializacao do campo
                  .F.,;	    // [12]  L   Indica se trata-se de um campo chave
                  .F.,;	    // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                  .T.)	    // [14]  L   Indica se o campo é virtual
	
	oCab:AddField(STR0012,; // [01]  C   Titulo do campo // "Codigo"
                  STR0012,; // [02]  C   ToolTip do campo // "Codigo"
                  "DTATE",; // [03]  C   Id do Field
                  "D",;	    // [04]  C   Tipo do campo
                  8,;	    // [05]  N   Tamanho do campo
                  0,;	    // [06]  N   Decimal do campo
                  bVld,;	// [07]  B   Code-block de validação do campo
                  Nil,;	    // [08]  B   Code-block de validação When do campo
                  Nil,;	    // [09]  A   Lista de valores permitido do campo
                  .F.,;	    // [10]  L   Indica se o campo tem preenchimento obrigatório
                  Nil,;	    // [11]  B   Code-block de inicializacao do campo
                  .F.,;	    // [12]  L   Indica se trata-se de um campo chave
                  .F.,;	    // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                  .T.)	    // [14]  L   Indica se o campo é virtual

EndIf

Return 


/*/{Protheus.doc} ViewStruct()
 * estrutura da View
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param oCab, oGrid
 * return não há
/*/
Static Function ViewStruct(oCab, oGrid)

oGrid:SetProperty("GQN_AGENCI", MVC_VIEW_ORDEM, '01')
oGrid:SetProperty("GQN_DESCAG", MVC_VIEW_ORDEM, '02')
oGrid:SetProperty("GQN_DATA"  , MVC_VIEW_ORDEM, '03')
oGrid:SetProperty("GQN_CODIGO", MVC_VIEW_ORDEM, '12')

If ValType(oCab) == "O"
	oCab:AddField("AGINI",;	 // [01]  C   Nome do Campo
	               "01",;	 // [02]  C   Ordem
	               STR0013,; // [03]  C   Titulo do campo
	               STR0013,; // [04]  C   Descricao do campo
	               {},;      // [05]  A   Array com Help // "Selecionar"
	               "Get",;   // [06]  C   Tipo do campo
	               "",;		 // [07]  C   Picture
	               NIL,;	 // [08]  B   Bloco de Picture Var
	               "GI6",;	 // [09]  C   Consulta F3
	               .T.,;	 // [10]  L   Indica se o campo é alteravel
	               NIL,;	 // [11]  C   Pasta do campo
	               "",;		 // [12]  C   Agrupamento do campo
	               {},;	     // [13]  A   Lista de valores permitido do campo (Combo)
	               NIL,;	 // [14]  N   Tamanho maximo da maior opção do combo
	               NIL,;	 // [15]  C   Inicializador de Browse
	               .T.,;	 // [16]  L   Indica se o campo é virtual
	               NIL,;	 // [17]  C   Picture Variavel
	               .F.)		 // [18]  L   Indica pulo de linha após o campo

	oCab:AddField("AGFIN",;	 // [01]  C   Nome do Campo
	               "02",;	 // [02]  C   Ordem
	               STR0014,; // [03]  C   Titulo do campo
	               STR0014,; // [04]  C   Descricao do campo
	               {},;      // [05]  A   Array com Help // "Selecionar"
	               "Get",;   // [06]  C   Tipo do campo
	               "",;		 // [07]  C   Picture
	               NIL,;	 // [08]  B   Bloco de Picture Var
	               "GI6",;	 // [09]  C   Consulta F3
	               .T.,;	 // [10]  L   Indica se o campo é alteravel
	               NIL,;	 // [11]  C   Pasta do campo
	               "",;		 // [12]  C   Agrupamento do campo
	               {},;	     // [13]  A   Lista de valores permitido do campo (Combo)
	               NIL,;	 // [14]  N   Tamanho maximo da maior opção do combo
	               NIL,;	 // [15]  C   Inicializador de Browse
	               .T.,;	 // [16]  L   Indica se o campo é virtual
	               NIL,;	 // [17]  C   Picture Variavel
	               .F.)		 // [18]  L   Indica pulo de linha após o campo
	
	
     oCab:AddField("DTDE",;   // [01]  C   Nome do Campo
	                "03",;	  // [02]  C   Ordem
	                STR0011,; // [03]  C   Titulo do campo
	                STR0011,; // [04]  C   Descricao do campo
	                {},;      // [05]  A   Array com Help // "Selecionar"
	                "Get",;	  // [06]  C   Tipo do campo
	                "",;	  // [07]  C   Picture
	                NIL,;	  // [08]  B   Bloco de Picture Var
	                "",;	  // [09]  C   Consulta F3
	                .T.,;	  // [10]  L   Indica se o campo é alteravel
	                NIL,;	  // [11]  C   Pasta do campo
	                "",;	  // [12]  C   Agrupamento do campo
	                {},;	  // [13]  A   Lista de valores permitido do campo (Combo)
	                NIL,;	  // [14]  N   Tamanho maximo da maior opção do combo
	                NIL,;	  // [15]  C   Inicializador de Browse
	                .T.,;	  // [16]  L   Indica se o campo é virtual
	                NIL,;	  // [17]  C   Picture Variavel
	                .F.)	  // [18]  L   Indica pulo de linha após o campo

		
	oCab:AddField("DTATE",; // [01]  C   Nome do Campo
	              "04",;	// [02]  C   Ordem
	              STR0012,; // [03]  C   Titulo do campo
	              STR0012,; // [04]  C   Descricao do campo
	              {},;      // [05]  A   Array com Help // "Selecionar"
	              "Get",;	// [06]  C   Tipo do campo
	              "",;	    // [07]  C   Picture
	              NIL,;	    // [08]  B   Bloco de Picture Var
	              "",;	    // [09]  C   Consulta F3
	              .T.,;	    // [10]  L   Indica se o campo é alteravel
	              NIL,;	    // [11]  C   Pasta do campo
	              "",;	    // [12]  C   Agrupamento do campo
	              {},;	    // [13]  A   Lista de valores permitido do campo (Combo)
	              NIL,;	    // [14]  N   Tamanho maximo da maior opção do combo
	              NIL,;	    // [15]  C   Inicializador de Browse
	              .T.,;	    // [16]  L   Indica se o campo é virtual
	              NIL,;	    // [17]  C   Picture Variavel
	              .F.)	    // [18]  L   Indica pulo de linha após o campo

EndIf	  

Return


/*/{Protheus.doc} ExecFilt()
 * Execulta o filtro 
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param oView
 * return não há
/*/
Static Function ExecFilt(oView)
Local oMdl      := FwModelActive()
Local oGridMdl  := oMdl:GetModel('GQNDETAIL')
Local oGrid     := oView:GetModel('GQNDETAIL')
Local cAgIni    := oView:GetModel('CABMASTER'):GetValue('AGINI')
Local cAgFin    := oView:GetModel('CABMASTER'):GetValue('AGFIN')
Local cAliasGQN := GetNextAlias()
Local dDtDe     := oView:GetModel('CABMASTER'):GetValue('DTDE' )
Local dDtAte    := oView:GetModel('CABMASTER'):GetValue('DTATE')

If Empty(cAgIni) .OR. Empty(cAgFin) .OR. Empty(dDtDe) .OR. Empty(dDtAte)
	Return
EndIf 

If !oGrid:IsEmpty()
	oGridMdl:ClearData()
EndIf

oGrid:SetNoDeleteLine(.F.)
oGrid:SetNoInsertLine(.F.)
oGrid:SetNoUpdateLine(.F.)

BeginSql Alias cAliasGQN
	SELECT
		GQN.GQN_AGENCI, 
		GQN.GQN_CODIGO,
		GQN.GQN_DATA  ,
		GQN.GQN_NUMFCH,
		GQN.GQN_FCHDES,
		GQN.GQN_TPDIFE,
		GQN.GQN_VLDIFE,
		GQN.GQN_ORIGEM,
		GQN.GQN_CDCAIX
    FROM 
        %Table:GQN% GQN
	WHERE
        GQN.GQN_FILIAL = %xFilial:GQN%
		AND GQN.GQN_AGENCI BETWEEN %Exp:cAgIni% AND %Exp:cAgFin%
		AND GQN.GQN_DATA BETWEEN %Exp:dDtDe% AND %Exp:dDtAte%
		AND GQN.%NotDel%
EndSql
	
While !(cAliasGQN)->(Eof())

	IF !(oGrid:Length() <=1 .AND. oGrid:IsEmpty())
		oGrid:AddLine()
	EndIf

	oGrid:LoadValue('GQN_AGENCI', (cAliasGQN)->GQN_AGENCI)
	oGrid:LoadValue('GQN_CODIGO', (cAliasGQN)->GQN_CODIGO)
	oGrid:LoadValue('GQN_DATA'  , STOD((cAliasGQN)->GQN_DATA))
	oGrid:LoadValue('GQN_NUMFCH', (cAliasGQN)->GQN_NUMFCH)
	oGrid:LoadValue('GQN_FCHDES', (cAliasGQN)->GQN_FCHDES)
	oGrid:LoadValue('GQN_TPDIFE', (cAliasGQN)->GQN_TPDIFE)
	oGrid:LoadValue('GQN_VLDIFE', (cAliasGQN)->GQN_VLDIFE)
	oGrid:LoadValue('GQN_ORIGEM', (cAliasGQN)->GQN_ORIGEM)
	oGrid:LoadValue('GQN_CDCAIX', (cAliasGQN)->GQN_CDCAIX)
	oGrid:LoadValue('GQN_AGENCI', (cAliasGQN)->GQN_AGENCI)

	(cAliasGQN)->(dbSkip())

	oGrid:RunTrigger('GQN_AGENCI')
EndDo

(cAliasGQN)->(DbCloseArea())
oGrid:GoLine(1)

oGrid:SetNoDeleteLine(.T.)
oGrid:SetNoInsertLine(.T.)
oGrid:SetNoUpdateLine(.T.)

Return 


/*/{Protheus.doc} GTP700Fech()
 * Inclui o campo fechar 
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param não há
 * return .T.
/*/
Static Function GTP700Fech() 
Local oView	:= FwViewActive()
		
oView:SetModified(.F.)
	
Return .T.


/*/{Protheus.doc} GetAge()
 * Retorna a drescrição da agencia  
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param oMdl
 * return cDesAge
/*/
Static Function GetAge(oMdl)
Local nLin    := oMdl:GetLine()
Local cAge    := oMdl:GetValue('GQN_AGENCI', nLin)
Local cDesAge := Posicione("GI6",1,xFilial("GQN")+cAge,"GI6_DESCRI")

Return cDesAge


/*/{Protheus.doc} ZeraGrid()
 * Limpa a consulta   
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param não há
 * return .T.
/*/
Static Function ZeraGrid()
Local oMdl    := FwModelActive()
Local oView   := FwViewActive()
Local oMdlCab := oMdl:GetModel('CABMASTER')
Local oMdlGri := oMdl:GetModel('GQNDETAIL')

If oMdlCab:GetValue('AGINI') > oMdlCab:GetValue('AGFIN') .AND. !Empty(oMdlCab:GetValue('AGFIN'))

	oMdl:SetErrorMessage(oMdlCab:GetId(),,oMdlCab:GetId(),,,STR0015,)
	Return .F.
EndIf 

If oMdlCab:GetValue('DTDE') > oMdlCab:GetValue('DTATE') .AND. !Empty(oMdlCab:GetValue('DTATE'))

	oMdl:SetErrorMessage(oMdlCab:GetId(),,oMdlCab:GetId(),,,STR0016,)
	Return .F.
EndIf 

if !Empty(oMdlCab:GetValue('AGINI')) .OR. !Empty(oMdlCab:GetValue('AGFIN'));
	.OR. !Empty(oMdlCab:GetValue('DTDE' )) .OR. !Empty(oMdlCab:GetValue('DTATE'))

	If !oMdlGri:IsEmpty()
		oMdlGri:ClearData()
		oView:Refresh()	
	EndIf

EndIf

Return .T.
