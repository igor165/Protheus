#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA871B.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA871B
Configurador de regra de cliente

@author Varejo
@since 20/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Static cRetCpo := ''
Function LOJA871B()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MG7' )
oBrowse:SetDescription(STR0002) //"Configurador Regra Cliente"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw"  		       OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.LOJA871B"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.LOJA871B"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.LOJA871B"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.LOJA871B"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMG7 := FWFormStruct(1,"MG7",{|cCampo| (AllTrim(cCampo) $ "MG7_CODIGO|MG7_DESCRI|")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(1,"MG7",{|cCampo| !(AllTrim(cCampo) $ "MG7_CODIGO|MG7_DESCRI|")})// Informe que os campos do cabecalho nao devem aparecer nos itens
Local oModel := Nil  // objeto modelo

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA871B",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
//colocar validacao da linha depois de digitar colocar aspas ""
oModel:AddFields("MG7MASTER", Nil/*cOwner*/, oStructMG7 ,/*Pre-Validacao*/,{||.T.},/*Carga*/)

oModel:SetPrimaryKey( { "MG7_FILIAL","MG7_CODIGO","MG7_CAMPO" } )

oModel:AddGrid  ('MG7GRID' , 'MG7MASTER',     oStructIt, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/{|oModel| Lj871VldGrd() }, /*BLoad*/ )
                       
oModel:SetRelation( "MG7GRID", { { "MG7_FILIAL", "xFilial('MG7')" }, { "MG7_CODIGO", "MG7_CODIGO" } }, MG7->( IndexKey( 1 ) ) )

oModel:GetModel( 'MG7GRID' ):SetUniqueLine( { 'MG7_CAMPO','MG7_FORMUL' } )
                                                                 
oModel:GetModel("MG7MASTER"):SetDescription(STR0002) //"Configurador Regra Cliente"

oModel:GetModel("MG7GRID"  ):SetDescription(STR0003) //"Configurador Regra Cliente - Item"

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil   // view do modelo
Local oModel       := FWLoadModel("LOJA871B")
Local oStructMG7 := FWFormStruct(2,"MG7",{|cCampo| (AllTrim(cCampo) $ "MG7_CODIGO|MG7_DESCRI")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(2,"MG7",{|cCampo| !(AllTrim(cCampo) $ "MG7_CODIGO|MG7_DESCRI")})// Informe que os campos do cabecalho nao devem aparecer nos itens

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWMG7" , oStructMG7, "MG7MASTER" )
oView:AddGrid (  "VIEWGMG7", oStructIt,  "MG7GRID" )

oView:AddIncrementField( 'VIEWGMG7', 'MG7_ITEM' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMG7' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEWGMG7', 'INFERIOR' )
                               
oView:EnableTitleView( 'VIEWMG7' )
oView:EnableTitleView( 'VIEWGMG7')
                                                       	
Return oView


//-------------------------------------------------------------------
/* LJ870A
Efetua Consulta Especifica SX3
                  
@author  Varejo
@since   27/05/2013
@version 1.0
*/
//------------------------------------------------------------------- 
Function LJ871BA(nTipo)

Local aAreaAtu    := GetArea()                   	//Armazena posicionamento atual da tabela
Local aArray      := {}                           	//Opcoes de Escolha (Array de Opcoes)
Local cEntida 	  := ""                           	//alias para filtro
Local MvPar       := ""                           	//String de Opcoes para Retorno
Local mvRet       := ""                          	 	//String de Opcoes para Retorno  
Local MvParDef    := ""                          	//String de Opcoes para Retorno
Local cTitulo 	  := STR0004							//"Campos do Sistema" Titulo da Coluna com as opcoes
Local nX          := 1                          		//contador
Local nTamChave   := 0                           	//Tamanho da Chave
Local oView	  	 
Local oModel     
Local lRet:= .T.
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default nTipo := 0 // 1= significa que a validação veio do X3_VALID

If !lAutomato
	oView	  	:= FwViewActive()   // Pega view ativa
	oModel      := oView:GetModel()  // Pega o modelo
Else
	oModel := FWModelActive()
EndIf 

oModel 	:= oModel:GetModel('MG7GRID')   
cEntida := "SA1" //Seta o alias para filtro
 
If nTipo == 0
	SX3->(DbGoTop())
	nTamChave:= Len(SX3->X3_CAMPO)+1
	//Carrega array com a estrutura da tabela
	While SX3->(!EOF()) 
		If SX3->X3_ARQUIVO == cEntida
			Aadd(aArray, SX3->X3_ARQUIVO , SX3->X3_CAMPO )
			MvParDef += SX3->X3_CAMPO+"|"
		EndIf	
		SX3->(DbSkip())
	EndDo
	    
	MvPar:=&(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())
		
	If f_Opcoes(   	@MvPar   ,; 	//Variavel de Retorno
		cTitulo         ,;             //Titulo da Coluna com as opcoes
		aArray          ,;             //Opcoes de Escolha (Array de Opcoes)
		MvParDef        ,;             //String de Opcoes para Retorno
						,;             	//Nao Utilizado
						,;             	//Nao Utilizado
		.T.            	,;             	//Se a Selecao sera de apenas 1 Elemento por vez
		nTamChave      	,;         	//Tamanho da Chave
		9999          	,;             	//No maximo de elementos na variavel de retorno
		.F.            	,;             	//Inclui Botoes para Selecao de Multiplos Itens
		.F.            	,;             	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
						,;             	//Qual o Campo para a Montagem do aOpcoes
		.F.            	,;             	//Nao Permite a Ordenacao
		.F.            	,;             	//Nao Permite a Pesquisa
		.T.            	,;             	//Forca o Retorno Como Array
		""          	)				//Consulta F3
		
		For nX:=1 To Len(MvPar)
			cRetCpo:= SubStr(MvPar[nX],1,Len(MvPar[nX])-1)
		Next nX
	EndIf	                  
	//-- valida se existe na sx3
	If !Empty(cRetCpo) .AND. SA1->(FieldPos(cRetCpo)) == 0
		lRet:=	.F.
		Alert(STR0005) //"Campo não existe" 
	Else			
		oModel:SetValue('MG7_CAMPO',cRetCpo)
		oView:Refresh()
	EndIf
Else                  
	cRetCpo:= oModel:GetValue('MG7_CAMPO')
	If SA1->(FieldPos(cRetCpo)) == 0
		lRet:=	.F.
		Alert(STR0005) //"Campo não existe" 
	EndIf
EndIf

RestArea( aAreaAtu )

Return lRet

//-------------------------------------------------------------------
/* LJ870B
Retorno Consulta Especifica SX3                  
@author  Varejo
@since   27/05/2013
@version 1.0
*/
//------------------------------------------------------------------- 
Function LJ871BB()
Return cRetCpo
              


//-------------------------------------------------------------------
/* Lj871VldGrd
Valida se a grid nao esta vazia
@author  Varejo
@since   27/05/2013
@version 1.0
*/
//------------------------------------------------------------------- 
Static Function Lj871VldGrd()

Local lRet        := .T.
Local oView	  	
Local oModel    
Local lAutomato := lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

If !lAutomato
	oView	  	:= FwViewActive()   // Pega view ativa
	oModel      := oView:GetModel()  // Pega o modelo
Else
	oModel := FWModelActive()
EndIf

oModel      := oModel:GetModel('MG7GRID')              	//Pega o modelo

If oModel:IsEmpty()
	MsgInfo(STR0006,STR0007) //#"Campo(s) ou formula(s) deve ser informado !" ##"Atenção"
	lRet:= .F.
EndIf


Return lRet

//-------------------------------------------------------------------
/* Lj871VldCpo
Valida se a grid nao esta vazia
@author  Varejo
@since   27/05/2013
@version 1.0
*/
//------------------------------------------------------------------- 
Function Lj871VldCpo()

Local lRet        := .T.
Local cCampo      :=ReadVar()
Local cConteudo   :=&(ReadVar())
Local oView	  	 
Local oModel     
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

If !lAutomato
	oView	  	:= FwViewActive()   // Pega view ativa
	oModel      := oView:GetModel()  // Pega o modelo
Else
	oModel := FWModelActive()
EndIf

oModel      := oModel:GetModel('MG7GRID')              	//Pega o modelo

If Alltrim(cCampo) == "M->MG7_CAMPO"
	oModel:SetValue('MG7_CAMPO',cConteudo)
	oModel:LoadValue('MG7_FORMUL','')
ElseIf Alltrim(cCampo) == "M->MG7_FORMUL"
	oModel:SetValue('MG7_FORMUL',cConteudo)
	oModel:LoadValue('MG7_CAMPO','')
EndIf


Return lRet

