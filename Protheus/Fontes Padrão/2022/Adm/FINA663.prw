#INCLUDE "FINA663.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA663
Rotina de Log de erro no processo de sincronização
do Sistema Protheus com o Sistema Reserve

@author Totvs
@since 31-08-2013
@version P11 R9
/*/
//-------------------------------------------------------------------
Function FINA663()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FL0')
oBrowse:SetDescription( STR0010 )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0011	ACTION 'VIEWDEF.FINA663' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.FINA663' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE STR0013	ACTION 'FINA663Exc'		OPERATION 20 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruFL0	:= FWFormStruct(1,'FL0')
Local oModel	:= MPFormModel():New('FINA663')

oModel:AddFields('FL0MASTER',,oStruFL0)
oModel:SetDescription(STR0014)
oModel:GetModel('FL0MASTER'):SetDescription(STR0010)

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel('FINA663')
Local oStruFL0	:= FWFormStruct(2,'FL0')
Local oView

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_FL0',oStruFL0,'FL0MASTER')
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_FL0', 'TELA' )

Return oView

//-------------------------------------------------------------------
// Importação dos dados
//-------------------------------------------------------------------
Function FINA663Log(aCampos)
Local oModel	:= Nil
Local oAux	:= Nil
Local oStruct	:= Nil
Local nI	:= 0
Local nPos	:= 0
Local lRet	:= .T.
Local aAux	:= {}
Local cAlias	:= "FL0"

Default aCampos := {}

DbSelectArea(cAlias)
DbSetOrder(1)

oModel := FWLoadModel('FINA663')
oModel:SetOperation(3)
oModel:Activate()

// Instanciamos apenas referentes à dados
oAux := oModel:GetModel( cAlias + 'MASTER' )

// Obtemos a estrutura de dados
oStruct := oAux:GetStruct()

aAux := oStruct:GetFields()

For nI := 1 To Len( aCampos )

	// Verifica se os campos passados existem na estrutura do modelo
	If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aCampos[nI][1]) } ) ) > 0

		// È feita a atribuição do dado ao campo do Model
		If !( lAux := oModel:SetValue( cAlias + 'MASTER', aCampos[nI][1], aCampos[nI][2] ) )
			// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
			// o método SetValue retorna .F.
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nI

If lRet
	// Faz-se a validação dos dados, note que diferentemente das tradicionais
	// "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		oModel:CommitData()
	EndIf
EndIf

If !lRet
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()
	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior
	AutoGrLog( STR0001	+ ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem:"
	AutoGrLog( STR0002		+ ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: "
	AutoGrLog( STR0003	+ ' [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro: "
	AutoGrLog( STR0004			+ ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
	AutoGrLog( STR0005					+ ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: "
	AutoGrLog( STR0006				+ ' [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro: "
	AutoGrLog( STR0007			+ ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução: "
	AutoGrLog( STR0008				+ ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído: "
	AutoGrLog( STR0009				+ ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior: "
	MostraErro()
EndIf

// Desativamos o Model
oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
Function FINA663Exc
Local cAliasFL0	:= ""
Local cWhere		:= "%%" 

If Pergunte("FINA663")

	cAliasFL0 := GetNextAlias()
	
	If !Empty(MV_PAR03)
		cWhere := "% AND FL0_ENTIDA = '" + MV_PAR03 + "'%"
	EndIf

	BeginSQL Alias cAliasFL0
	SELECT	FL0.R_E_C_N_O_
	FROM	%Table:FL0% FL0
	WHERE	FL0.FL0_FILIAL = %XFilial:FL0%
			AND FL0.FL0_DATA	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND FL0.%NotDel%
			%Exp:cWhere%
	EndSQL

	DbSelectArea("FL0")
	DbSetOrder(1)

	While (cAliasFL0)->(!EOF())
		FL0->(DbGoto((cAliasFL0)->R_E_C_N_O_))
		RecLock("FL0",.F.)
		FL0->(DbDelete())
		FL0->(MsUnlock())
	(cAliasFL0)->(DbSkip())
	EndDo

EndIf

Return
