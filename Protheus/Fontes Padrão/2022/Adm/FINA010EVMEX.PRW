#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'FINA010.ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010EVMEX
Eventos do MVC para o MÉXICO, qualquer regra que se aplique somente para MÉXICO
deve ser criada aqui, se for uma regra geral deve estar em FINA010EVDEF.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type class
 
@author Rodrigo Oliveira
@since 25/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
CLASS FINA010EVMEX From FWModelEvent
	
	DATA nOpc As Numeric
	
	DATA cEdOpadt	As Character
 	DATA cEdCod		As Character
 	
	METHOD New() CONSTRUCTOR
	
	METHOD ModelPosVld()
	
ENDCLASS
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe FINA010EVMEX

@type Method

@author Rodrigo Oliveira
@since 25/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD New() CLASS FINA010EVMEX

Return Self
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

Verifica se ha titulos associados a natureza no qual se deseja alterar o campo ED_OPERADT

@type Method
 
@author Rodrigo Oliveira
@since 25/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD ModelPosVld(oModel, cID) CLASS FINA010EVMEX
Local lValid 	As Logical 
Local nOpc		As Numeric
Local cEdOpadt	As Character
Local cEdCod	As Character
Local aSaveArea	As Array
Local aSaveSE1	As Array

	lValid		 := .T.
	aSaveArea	 := GetArea()
	aSaveSE1	 := SE1->(GetArea())

	::nOpc := oModel:GetOperation()
	::cEdOpadt	:=	oModel:GetModel("SEDMASTER"):GetValue("ED_OPERADT") 
 	::cEdCod	:= 	oModel:GetModel("SEDMASTER"):GetValue("ED_CODIGO")
 	
	If ::nOpc == MODEL_OPERATION_UPDATE
		If SED->ED_OPERADT <> ::cEdOpadt
			DbSelectArea("SE1")
			SE1->(DbSetorder(3)) //E1_FILIAL+E1_NATUREZ+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_TIPO
			If SE1->(DbSeek(XFilial("SE1") + ::cEdCod ))
				lValid := .F.
				Help(" ",,"FA010OPADT",,I18N(STR0054,{AllTrim(RetTitle("ED_OPERADT"))}),1,0) //"Não é possivel alterar o campo #1[campo]#, pois há titulos associados a natureza."
			EndIf
		EndIf
	EndIf

RestArea(aSaveSE1)
RestArea(aSaveArea)
Return lValid
