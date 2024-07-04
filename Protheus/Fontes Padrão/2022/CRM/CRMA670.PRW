#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "CRMA670.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA670()

Cadastro de Script x Rotinas  

@param	Nenhum

@return Nenhum

@author  Eduardo Gomes Junior
@since	  18/05/2015
@version  12
/*/
//------------------------------------------------------------------------------
Function CRMA670()

Local oMBrowse  := Nil // Browse da lista de scripts executados

Private aRotina := MenuDef()

oMBrowse:= FWMBrowse():New()//		Criando Browser e Layer
oMBrowse:SetAlias("A05")
oMBrowse:SetDescription(STR0001)	//"Script x Rotinas"
oMBrowse:Activate()	

Return

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Rotina para criar as opções de menu disponiveis 

@param	Nenhum

@return array contendo as opcoes disponiveis

@author Eduardo Gomes Junior	 
@since	 18/05/2015
@version  12
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.CRMA670' OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina Title STR0003 	Action 'VIEWDEF.CRMA670' OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina Title STR0004 	Action 'VIEWDEF.CRMA670' OPERATION 4 ACCESS 0	//"Alterar"
ADD OPTION aRotina Title STR0005 	Action 'VIEWDEF.CRMA670' OPERATION 5 ACCESS 0	//"Excluir"

Return aRotina

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Modelo de dados 

@param	 Nenhum

@return  oModel - objeto contendo o modelo de dados

@author Eduardo Gomes Junior
@since	  18/05/2015
@version  12
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel      	:= Nil
Local oStructA05		:= FWFormStruct(1,"A05")
Local oStructA06		:= FWFormStruct(1,"A06")

oModel := MPFormModel():New("CRMA670")

oModel:AddFields("A05MASTER",/*cOwner*/,oStructA05,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oStructA06:RemoveField("A06_CODSCR")

oModel:AddGrid( "A06DETAIL", "A05MASTER", oStructA06 )

oModel:SetRelation( 'A06DETAIL', { { 'A06_FILIAL', 'xFilial( "A06" )' }, { 'A06_CODSCR', 'A05_CODSCR' } }, A06->( IndexKey( 1 ) ) )

oModel:SetDescription(STR0001)	//"Script X Rotinas"

oModel:SetPrimaryKey( { "A05_FILIAL", "A05_CODSCR" } )

oModel:GetModel("A05MASTER"):SetDescription(STR0001)	//"Script X Rotinas"
oModel:GetModel("A06DETAIL"):SetDescription(STR0006)	//"Item do Script X Funções"

oModel:GetModel("A06DETAIL"):SetUniqueLine({"A06_ACAOUS"})

Return oModel

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()

ViewDef - Visão do model 

@param	 Nenhum

@return  oView - objeto contendo a visão criada

@author Eduardo Gomes Junior
@since	 18/05/2015
@version  12
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView	  		:= FWFormView():New()
Local oModel	  		:= FwLoadModel("CRMA670") 
Local oStructA05  	:=  FWFormStruct(2,"A05")
Local oStructA06  	:=  FWFormStruct(2,"A06")

//	Associa o View ao Model
oView:SetModel( oModel )//Define que a view vai usar o model

oStructA06:RemoveField("A06_CODSCR")

oView:SetDescription(STR0001)	//"Script X Rotinas"

oView:AddField("VIEW_A05_FIELD", oStructA05, "A05MASTER" )

oView:AddGrid( "VIEW_A06_FIELD" , oStructA06, "A06DETAIL" )

oView:AddIncrementField( "VIEW_A06_FIELD", "A06_ORDEM" )

oView:EnableTitleView("VIEW_A05_FIELD",STR0010)	//"Script"
oView:EnableTitleView("VIEW_A06_FIELD",STR0006)	//"Item do Script X Funções"

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( "VIEW_A05_FIELD", "SUPERIOR" )
oView:SetOwnerView( "VIEW_A06_FIELD", "INFERIOR" )

Return (oView)

//----------------------------------------------------------
/*/{Protheus.doc} A670VdRtPrd()

A670VdRtPrd - Aplica validacao nos campos A05_ROTINA e A06_ACAOUS

@param	 cQlOpcao - "1" = Validacao no campo A05_ROTINA / "2" = Validacao no campo A06_ACAOUS

@return  lRetorno - Verdadeiro/Falso

@author Eduardo Gomes Junior
@since	 18/05/2015
@version  12
/*/
//----------------------------------------------------------
Function A670VdRtPrd(cQlOpcao)

Local lRetorno	:= .T.
Local cRotina		:= Nil
Local cConteudo	:= Nil

Default cQlOpcao := ""

If	cQlOpcao == "1"
	
	cConteudo	:= FwFldGet("A05_ROTINA")
	
	If	Substr(cConteudo,2,1) == "_"		
		Help("",1,"HELP","CRMA670",STR0007,1)	//"Não é permitido informar rotina de usuário"
		lRetorno := .F.
	Endif 
	
Endif 	 
 
If	cQlOpcao == "2"
	cConteudo	:= FwFldGet("A06_ACAOUS")
Endif

If	lRetorno

	If	"(" $ cConteudo .or. ")" $ cConteudo 	
		Help("",1,"HELP","CRMA670",STR0008,1)	//"Não informar parênteses () no final da rotina"
		lRetorno := .F.
	Endif 

	//Valida existencia da rotina no RPO
	If	!Empty(cQlOpcao) .and. !FindFunction(cConteudo)
		Help("",1,"HELP","CRMA670",STR0009,1)	//"Rotina informada não encontrada"
		lRetorno := .F.
	Endif
	
Endif 	

Return lRetorno
