#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA650.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA650

Cadastro de Exceção Territoriais

@sample	CRMA650()

@param		Nenhum

@return	Nenhum

@author	Jonatas Martins
@since		14/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA650()

Local oBrowse := Nil

oBrowse := FWMBrowse():New()

oBrowse:SetCanSaveArea(.T.) 
oBrowse:SetAlias("A01")
oBrowse:SetDescription(STR0001) //"Exceção Territoriais"
oBrowse:DisableDetails()
oBrowse:DisableReport()
oBrowse:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Monta estrutura de funções do Browse

@sample	MenuDef()

@param		Nenhum

@return	aRotina - Array de Rotinas

@author	Jonatas Martins
@since		14/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.CRMA650" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.CRMA650" OPERATION 3 ACCESS 0 //"Incluir" 
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.CRMA650" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.CRMA650" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Monta modelo de dados para Cadastro de Exceção Territoriais.

@sample	ModelDef()

@param		Nenhum

@return	oModel - Modelo de Dados

@author	Jonatas Martins 
@since		14/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStructA01	:= FWFormStruct(1,"A01",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructA02	:= FWFormStruct(1,"A02",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel		:= Nil

//-------------------------------------------------------------------
// Define os gatilhos.  
//-------------------------------------------------------------------
oStructA02:AddTrigger( "A02_NIVAGR", "A02_IDINT",, {| oModel, cField, cValue | CRM650Trigger( oModel, cField, cValue ) } )

oModel := MPFormModel():New("CRMA650",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("A01MASTER",/*cOwner*/,oStructA01,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid("A02DETAIL","A01MASTER",oStructA02,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

//Relacionamentos
oModel:SetRelation("A02DETAIL",{{"A02_FILIAL","xFilial('A02')"},{"A02_CODAGR","A01_CODAGR"}},A02->(IndexKey(1)))

//Validação de linha duplicada
oModel:GetModel("A02DETAIL"):SetUniqueLine({"A02_CODAGR","A02_NIVAGR"})

oModel:SetDescription(STR0001) //"Exceção Territoriais"

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta interface para Cadastro de Exceção Territoriais.

@sample	ViewDef()

@param		Nenhum

@return	oView - Interface do Agrupador de Registros

@author	Jonatas Martins
@since		14/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oStructA01		:= FWFormStruct(2,"A01",/*bAvCpoAOM*/,/*lViewUsado*/)
Local oStructA02		:= FWFormStruct(2,"A02",/*bAvCpoAOM*/,/*lViewUsado*/)
Local oModel			:= FWLoadModel("CRMA650")
Local oView			:= Nil

//Remove campo da visualização
oStructA02:RemoveField("A02_CODAGR")
oStructA02:RemoveField("A02_IDINT")

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField("VIEW_A01",oStructA01,"A01MASTER")
oView:AddGrid("VIEW_A02",oStructA02,"A02DETAIL")

oView:CreateHorizontalBox("SUPERIOR",30)
oView:CreateHorizontalBox("INFERIOR",70)

oView:SetOwnerView("VIEW_A01","SUPERIOR")
oView:SetOwnerView("VIEW_A02","INFERIOR")

//Exibe descrição dos paineis
oView:EnableTitleView("VIEW_A01",STR0006)	//"Agrupador"
oView:EnableTitleView("VIEW_A02",STR0007)	//"Níveis do Agrupador"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA650Niv

Função que retorna a descrição do nível do agrupador ao iniciar a rotina.

@sample	CRMA650Niv()

@param		Nenhum
			
@return	cDescNiv	- Retorna a Descrição do Nível do Agrupador

@author	Jonatas Martins
@since		14/05/2015
@version	12
@obs		Rotina utilizada no configurador como inicializador padrão dos campos A02_DSCNIV e A00_DSCNIV
/*/
//------------------------------------------------------------------------------
Function CRMA650Niv()

Local aArea		:= GetArea()
Local aAreaAOM	:= AOM->(GetArea())
Local oModel		:= FwModelActive()
Local nOperation	:= oModel:GetOperation()
Local cChave		:= ""
Local cDescNiv	:= ""

If nOperation <> MODEL_OPERATION_INSERT

	If oModel:GetId() == "CRMA650"
		cChave := A02->A02_CODAGR + A02->A02_NIVAGR
	ElseIf oModel:GetID() == "CRMA640"
		cChave := A00->A00_CODAGR + A00->A00_NIVAGR
	EndIf
		
	DbSelectArea("AOM")
	AOM->(DbSetOrder(1))
		
	If AOM->(DbSeek(xFilial("AOM")+cChave))
		cDescNiv := AllTrim(AOM->AOM_DESCRI)
	EndIf 
	
EndIf

RestArea(aAreaAOM)
RestArea(aArea)

Return (cDescNiv)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA650Vld

Função que valida se conteúdo digitado no campo A02_CODMBR existe

@sample	CRMA650Vld()

@param		Nenhum
			
@return	lRet	- Retorna .T. se o valor existir

@author	Jonatas Martins
@since		14/05/2015
@version	12
@obs		Rotina utilizada no configurador na validação dos campos A02_CODMBR e A09_CODMBR
/*/
//------------------------------------------------------------------------------
Function CRMA650Vld()

Local aArea		:= GetArea()
Local oMdlActive	:= FwModelActive()
Local cFieldTMbr	:= ""
Local cFieldCodM	:= ""
Local cAlias		:= "" 
Local cValue		:= ""
Local lRet			:= .T.

If oMdlActive <> Nil
	
	//Verifica qual o modelo de dadaos e captura o respectivo campo
	If oMdlActive:GetID() == "CRMA650"
		cFieldTMbr	:= "A02_TPMBRO"
		cFieldCodM	:= "A02_CODMBR" 
	ElseIf oMdlActive:GetID() == "CRMA640"
		cFieldTMbr	:= "A09_TPMBRO"
		cFieldCodM	:= "A09_CODMBR"
	EndIf

	//Obtem o valor a ser avaliado
	Do Case
		Case FwFldGet(cFieldTMbr) == "1" //Unidade de Negócio
			cAlias := "ADK"
			
		Case FwFldGet(cFieldTMbr) == "2" //Papeis do Usuario
			cAlias := "AO3"
			If SuperGetMv("MV_CRMUAZS",, .F.)
				cAlias := "AZS"
			EndIf
			
		Case FwFldGet(cFieldTMbr) == "3" //Equipe de Vendas
			cAlias := "ACA"
	EndCase
	
	cValue := FwFldGet(cFieldCodM)
	
	//Verifica se o valor é válido 
	If !Empty( cAlias ) .And. !Empty( cValue )
		lRet := ExistCpo(cAlias,FwFldGet(cFieldCodM),1)	 		
	EndIf
	
EndIf

RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA650MbVld

Função que valida se o membro escolhido existe no território

@sample	CRMA650MbVld(cCodTer,cTpMem,cCodMem)

@param		cCodTer	-	Código do Território
@param		cTpMem		-	Tipo do Membro
@param		cCodMem	-	Código do Membro

@return 	lRetorno	-	Retorna .T. se o valor inserido for válido  

@author     Jonatas Martins	
@version    12.1.6
@since      30/06/2015
/*/
//------------------------------------------------------------------------------
Function CRMA650MbVld(cCodTer,cTpMem,cCodMem)

Local lRetorno	:= .F.
Local cAlsQry		:=	GetNextAlias()

Default cCodter	:= ""
Default cTpMem	:= ""
Default cCodMem	:= ""

If !Empty(cCodTer) .And. !Empty(cTpMem) .And. !Empty(cCodMem) 
	//------------------------------------------------------------------------------
	// Consulta o banco de dados retornando o tipo e membro do território informado
	//------------------------------------------------------------------------------
	BeginSql Alias cAlsQry	
		SELECT	A09_TPMBRO, A09_CODMBR
		FROM %Table:A09%
		WHERE A09_FILIAL		=	%xFilial:A09%	
			AND A09_CODTER	=	%Exp:cCodTer%	
			AND A09_TPMBRO	=	%Exp:cTpMem%
			AND A09_CODMBR	=	%Exp:cCodMem%
			AND %NotDel%	
	EndSql
	
	//----------------------------------------------------------------------------
	// Verifica se o código e o tipo do membro existe para o território informado 
	//----------------------------------------------------------------------------
	(cAlsQry)->(DbGoTop())
	
	If (cAlsQry)->(!EOF())
		lRetorno := .T.
	EndIf
	
	(cAlsQry)->(DbCloseArea())
EndIf

//--------------------------------
// Exibe mensagem de erro na tela 
//--------------------------------
If !lRetorno
	Help("",1,"HELP","CRMA650VLD",STR0008,1) //"Este membro não pertence ao território escolhido" 
EndIf
 
Return (lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM650Trigger
Trigger do campo A00_IDINT. 

@param oModel, objeto, Modelo de dados. 
@param cField, caracter, Campo a ser pesquisado. 
@param cValue, caracter, Conteúdo do campo a ser pesquisado. 
@return cReturn, caracter, Descrição do campo. 

@author     Valdiney V GOMES
@version    12
@since      18/11/2015
/*/
//------------------------------------------------------------------------------
Static Function CRM650Trigger( oMdlA02, cField, cValue ) 
	Local cReturn 		:= ""
	Local oModel			:= Nil
	Local oMdlA01			:= Nil

	Default oMdlA02		:= Nil 
	Default cField		:= ""
	Default cValue		:= ""
	
	If oMdlA02 <> Nil
		oModel		:= oMdlA02:GetModel()
		oMdlA01	:= oModel:GetModel("A01MASTER")
		If ( cField == "A02_NIVAGR" )	
			//-------------------------------------------------------------------
			// Recupera o ID inteligente do nível do agrupador. 
			//-------------------------------------------------------------------
			cReturn := Posicione( "AOM", 1, xFilial("AOM") + oMdlA01:GetValue("A01_CODAGR") + cValue, "AOM_IDINT" )
		EndIf 
	EndIf
Return cReturn 