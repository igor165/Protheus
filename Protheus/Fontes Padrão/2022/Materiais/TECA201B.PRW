#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "TECA201B.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TECA201B  ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Equipes X Atendentes                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP     	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TECA201B  

Local oBrowse	:= Nil     

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AAX')
oBrowse:SetDescription(STR0001) //'Equipes X Atendentes'
oBrowse:Activate()

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Modelo de Dados de Equipes X Atendentes                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TECA201B                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()   
 
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel    := Nil														   		// Objeto que contem o modelo de dados.
Local oStruAAX 	:= FWFormStruct(1,'AAX',/*bAvalCampo*/,/*lViewUsado*/)				// Objeto que contem a estrutura do cabecalho de vistoria.
Local oStruAAY 	:= FWFormStruct(1,'AAY',/*bAvalCampo*/,/*lViewUsado*/)				// Objeto que contem a estrutura de produtos.
Local aEstrut	:= {} 												   				// Array que contem as estruturas.
Local aAux		:= {}
Local bCommit   := {|oModel| At201bCmt(oModel)}    									// Bloco de commit.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona as Estruturas no Array aEstrut. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aEstrut,oStruAAX)
aAdd(aEstrut,oStruAAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia o modelo de dados Vistoria Tecnica. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := MPFormModel():New('TECA201B',/*bPreValidacao*/,/*bPosValid*/,bCommit,/*bCancel*/)   

aAux := FwStruTrigger(;
'AAY_CODTEC'  ,;
'AAY_NOMTEC'  ,;
'AA1->AA1_NOMTEC'  ,;
.T.,;
'AA1',;
1,;
'xFilial("AA1")+M->AAY_CODTEC')      
oStruAAY:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
   

oStruAAX:SetProperty('AAX_CODEQU',MODEL_FIELD_WHEN,.F.)  
oStruAAX:SetProperty('AAX_NOME',MODEL_FIELD_WHEN,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no modelo de dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddFields('AAXMASTER',/*cOwner*/,oStruAAX,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/ )
oModel:AddGrid('AAYDETAIL','AAXMASTER',oStruAAY,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do relacionamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation('AAYDETAIL',{{'AAY_FILIAL','xFilial("AAY")'},{'AAY_CODEQU','AAX_CODEQU'}},AAY->( IndexKey(1)))

oModel:GetModel('AAYDETAIL'):SetUniqueLine({'AAY_CODTEC'}) // Não permite repetir o código do atendente

oModel:GetModel('AAXMASTER'):SetOnlyView(.T.)
oModel:GetModel('AAXMASTER'):SetOnlyQuery(.T.) 
oModel:GetModel('AAYDETAIL'):SetOptional( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Adiciona a descricao do Modelo de Dados| 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetDescription(STR0001)	//"Equipes X Atendentes"


Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface do cadastro de Equipes X Atendentes               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TECA201B                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()
            
Local oModel	:= FWLoadModel( 'TECA201B' ) // Objeto que contem o modelo de dados
Local oStruAAX 	:= FWFormStruct( 2, 'AAX' )  // Objeto que contem a estrutura de Equipes
Local oStruAAY 	:= FWFormStruct( 2, 'AAY' )  // Objeto que contem a estrutura de Equipes X Atendentes
Local aEstrut	:= {}     					 // Array que contem as estruturas.
Local oView		:= Nil 

aAdd(aEstrut,oStruAAX)
aAdd(aEstrut,oStruAAY)

oStruAAY:RemoveField("AAY_CODEQU") //Remove o campo para não ser visualizado pelo usuario.
oStruAAY:RemoveField("AAY_NOMEQU") 

// Instancia a interface
oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField('VIEW_AAX',oStruAAX,'AAXMASTER')	//Adiciona os campos no cabecalho. 

oView:AddGrid('VIEW_AAY',oStruAAY,'AAYDETAIL')	//Adiciona os campos no grid. 

oView:CreateHorizontalBox( 'MASTER' ,20 ) // Equipes
oView:CreateHorizontalBox( 'DETAL' , 80 ) // Equipes X Atendentes

oView:SetOwnerView( 'VIEW_AAX', 'MASTER' )// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_AAY', 'DETAL' )

Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criação do MenuDef                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TECA201B                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TECA201B' OPERATION 2 ACCESS 0  //'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA201B' OPERATION 4 ACCESS 0  //'Alterar'

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At201bCmt ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Bloco de Commit                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TECA201B                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function At201bCmt(oModel)

	FWModelActive(oModel)
	FWFormCommit(oModel,NIL,NIL,NIL)

Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At201BHas
	Verifica se um atendente pertence a uma equipe
	Quando a pesquisa é realizada por código de usuário, se o usuário não estiver vinculado a 
	algum atendente... a visualização/edição é permitida.

@sample 	At201BHas() 

@param	 	Nenhum
@version  	V12 
@since    	23/04/2013 
@return		ExpL, Logico, pertence (.T.) ou não (.F.) a equipe

@param		ExpC, Caracter, código do atendente para consultar
@param		ExpC, Caracter, código da equipe a validar
@param		ExpC, Caracter, código do usuário a realizar a validação
/*/
//------------------------------------------------------------------------------
Function At201BHas( cCodEqp, cCodAtd, cUsr, lShowHelp )

Local lRet        := .F.
Local lBuscaAAY   := .T.

Local aSave       := GetArea()
Local aSaveAAY    := AAY->(GetArea())
Local aSaveAA1    := AA1->(GetArea())

DEFAULT cCodEqp   := ''
DEFAULT cCodAtd   := ''
DEFAULT cUsr      := ''
DEFAULT lShowHelp := .F.

If !Empty(cCodEqp) .And. ( !Empty(cCodAtd) .Or. !Empty(cUsr) )
	
	If !Empty(cUsr) .And. Empty(cCodAtd)
		
		DbSelectArea('AA1')
		AA1->( DbSetOrder( 4 )) //AA1_FILIAL+AA1_CODUSR
		
		If AA1->( DbSeek( xFilial('AA1')+cUsr ) )
			cCodAtd := AA1->AA1_CODTEC
		Else
			lRet := .T.
			lBuscaAAY := .F.
		EndIf
	EndIf
	
	If lBuscaAAY
		DbSelectArea('AAY')
		AAY->(DbSetOrder(1)) // AAY_FILIAL+AAY_CODEQU+AAY_CODTEC
		
		lRet := AAY->(DbSeek(xFilial('AAY')+cCodEqp+cCodAtd))
		If !lRet
			lShowHelp := .T.
		EndIf
	EndIf
	
EndIf

If !lRet .And. lShowHelp
	Help( " ", 1, "AT201BHASPERM", , STR0004+ CRLF +;  // 'Atendente não pertence a equipe.'
										STR0005 + cCodAtd + CRLF +;  // 'Código Atendente: '
										STR0006 + cCodEqp, 1, 0 )  // 'Equipe: '
EndIf

RestArea(aSaveAA1)
RestArea(aSaveAAY)
RestArea(aSave)

Return lRet