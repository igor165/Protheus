#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'RSPA230.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RSPA230  ³ Autor ³ Leandro Drumond                   ³ Data ³ 17/05/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Caracteristicas                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSPA230()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA230()
Local cFiltraRh
Local oBrwRS6  
 
oBrwRS6 := FWmBrowse():New()		
oBrwRS6:SetAlias( 'RS6' )
oBrwRS6:SetDescription( STR0001 )   //"Cadastro de Caracteristicas"
		
//Inicializa o filtro utilizando a funcao FilBrowse
cFiltraRh := CHKRH("RSPA230","RS6","1")

//Filtro padrao do Browse conforme tabela RS6
oBrwRS6:SetFilterDefault(cFiltraRh)
	
oBrwRS6:Activate()

Return( Nil )

/*
{Protheus.doc} MenuDef
Menu Funcional
@author Leandro Drumond
@since 17/05/2016
@version 1.0
*/
Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina Title STR0004  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.RSPA230'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.RSPA230'	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0007  Action 'VIEWDEF.RSPA230'	OPERATION 4 ACCESS 0 //"Atualizar"
	ADD OPTION aRotina Title STR0008  Action 'VIEWDEF.RSPA230'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina

/*
{Protheus.doc} ModelDef
Modelo de dados e Regras de preenchimento parao cadastro
@author Leandro Drumond
@since 17/05/2016
@version 1.0
*/
Static Function ModelDef()	
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruRS6 := FWFormStruct( 1, 'RS6', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruRS7 := FWFormStruct( 1, 'RS7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local bPosValid 	:= { |oModel| Rsp230PosVal( oModel )}
Local bLinOk 		:= { |oGrid| Rsp230LinOk( oGrid )}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('RSPA230', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )
//RollBackSX8()
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'RSPA230_MRS6', /*cOwner*/, oStruRS6, /*bLOkVld*/, /*bTOkVld*/, /*bCarga*/ )

// Adiciona Grid no modelo
oModel:AddGrid( 'RSPA230_MRS7', 'RSPA230_MRS6', oStruRS7, /*bLinePre*/, bLinOk, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz o Relacionamento dos arquivos
oModel:SetRelation( 'RSPA230_MRS7', {{"RS7_FILIAL", 'xFilial( "RS7" )'}, {"RS7_TIPO", 'RS6_CODIGO'}}, RS7->(IndexKey(1)) )

oModel:GetModel( "RSPA230_MRS7" ):SetOptional(.T.)
oModel:GetModel( "RSPA230_MRS7" ):SetUniqueLine( { 'RS7_DESC' } )

oModel:SetDescription( STR0001 )   //"Cadastro de Características"

Return oModel

/*
{Protheus.doc} ViewDef
Visualizador de dados do Cadastro de Características
@author Leandro Drumond
@since 17/05/2016
@version 1.0
*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'RSPA230' )

// Cria a estrutura a ser usada na View
Local oStruRS6 := FWFormStruct( 2, 'RS6' )
Local oStruRS7 := FWFormStruct( 2, 'RS7' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'RSPA230_VRS6', oStruRS6, 'RSPA230_MRS6' )

//Adiciona Grid na interface
oView:AddGrid( 'RSPA230_VRS7', oStruRS7, 'RSPA230_MRS7' )

oStruRS7:RemoveField("RS7_FILIAL")
oStruRS7:RemoveField("RS7_TIPO")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'FORMRS6' , 50 )
oView:CreateHorizontalBox( 'FORMRS7' , 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'RSPA230_VRS6', 'FORMRS6' )
oView:SetOwnerView( 'RSPA230_VRS7', 'FORMRS7' )

oView:AddIncrementField("RSPA230_MRS7","RS7_SEQ")
	
Return oView

/*
{Protheus.doc} Rsp230LinOk
Pos validação da rotina
@author Leandro Drumond
@since 17/05/2016
@version 1.0
*/
Static Function Rsp230LinOk( oGrid )
Local lRet		 := .T.
Local nOperation := oGrid:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
	If Empty(oGrid:GetValue("RS7_DESC"))
		Help( ,, STR0002,, STR0009, 1, 0) //"Alternativa deve ser informada."
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
{Protheus.doc} Rsp230PosVal
Pos validação da rotina
@author Leandro Drumond
@since 17/05/2016
@version 1.0
*/
Static Function Rsp230PosVal( oModel )
Local lRet		 := .T.
Local nOperation := oModel:GetOperation()
Local nLinhas	 := 0
Local nPos		 := 0
Local oGrid		 := oModel:GetModel( "RSPA230_MRS7" )
Local nLinAtual	 := 0

Begin Sequence
	If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
		If oModel:GetModel("RSPA230_MRS6"):GetValue('RS6_RESP') <> "3" //Diferente de dissertativo
			nLinAtual	:= oGrid:GetLine()
			nLinhas 	:= oGrid:Length()
			
			If nLinhas == 0
				Help( ,, STR0002,, STR0003, 1, 0)
				lRet := .F.
				Break
			EndIf
			
			For nPos := 1 to nLinhas
				oGrid:GoLine( nPos )
				If !Rsp230LinOk( oGrid )
					lRet := .F.
					Break
				EndIf
			Next nPos
			oGrid:GoLine( nLinAtual )
		EndIf
	EndIf
End Sequence
	
Return( lRet )

/*
{Protheus.doc} Rsp230VldTp
Validação do campo RS6_RESP
@author Leandro Drumond
@since 17/05/2016
@version 1.0
*/
Function Rsp230VldTp()
Local oModel	:= FWModelActive()
Local oGrid
Local nPos		:= 0
Local nLinhas	:= 0
Local cTipo		:=  oModel:GetModel("RSPA230_MRS6"):GetValue("RS6_RESP")

oGrid := oModel:GetModel("RSPA230_MRS7")
nLinhas := oGrid:Length()

If !(cTipo $ "1*2")//Apaga alternativas
	oGrid:SetNoDeleteLine(.F.)
	For nPos := 1 to nLinhas
		oGrid:GoLine(nPos)
		oGrid:DeleteLine()
	Next nPos
EndIf

If !(cTipo $ "1*2")//Não permite inclusão e exclusão de linhas
	oGrid:SetNoDeleteLine(.T.)
	oGrid:SetNoInsertLine(.T.)
Else
	oGrid:SetNoDeleteLine(.F.)
	oGrid:SetNoInsertLine(.F.)
EndIf

Return .T.

/*
{Protheus.doc} Rsp230When
When do campo RS7_DESC
@author Leandro Drumond
@since 17/05/2016
@version 1.0
*/
Function Rsp230When()
Local lRet 		:= .F.
Local oModel	:= FWModelActive() 

If oModel:GetModel("RSPA230_MRS6"):GetValue("RS6_RESP") $ "1*2" //Habilita edição do GRID
	lRet := .T.
EndIf

Return lRet
