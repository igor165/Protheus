#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'FINA010.ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010EVDOM
Eventos do MVC para a Rep�blica Dominicana, qualquer regra que se aplique somente para Rep�blica Dominicana
deve ser criada aqui, se for uma regra geral deve estar em FINA010EVDEF.

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type class
 
@author Rodrigo Oliveira
@since 25/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
CLASS FINA010EVDOM From FWModelEvent
	
	DATA nOpc
 	DATA nRecSED
 	
	METHOD New() CONSTRUCTOR
	
	METHOD ModelPosVld()
	
ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da classe FINA010EVDOM

@type Method

@author Rodrigo Oliveira
@since 25/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD New() CLASS FINA010EVDOM

Return Self

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Executa a valida��o do modelo antes de realizar a grava��o dos dados.
Se retornar falso, n�o permite gravar.

Verifica se h� t�tulos a receber, Titulos a pagar, movimentos bancarios e lancamentos de multiplas naturezas feitos 
associados a  natureza

@type Method
 
@author Rodrigo Oliveira
@since 25/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD ModelPosVld() CLASS FINA010EVDOM
Local lRet 		As Logical
Local nOpc		As Numeric
Local aSaveFRN	As Array  
Local aSaveSE1	As Array  
Local oModel	As Object
Local oModelSED As Object

	lRet		:= .T.
	aSaveFRN 	:= FRN->(GetArea())
	aSaveSE1 	:= SE1->(GetArea())
	oModel		:= FwModelActivate()
	oModelSED	:= oModel:GetModel("SEDMASTER")
	::nOpc := oModel:GetOperation()
 	
	If ::nOpc != MODEL_OPERATION_DELETE
		DbSelectArea("SE1")
		SE1->(DbSetOrder(3))
		If(SE1->(MsSeek(xFilial("SE1") + oModelSED:GetValue("ED_CODIGO"))))

			Help(" ",1,"HELP",STR0017,STR0018,1,0)
			lRet := .F.

		Else
			DbSelectArea("SE2")
			SE2->(DbSetOrder(2))
			If(SE2->(MsSeek(xFilial("SE2") + oModelSED:GetValue("ED_CODIGO"))))

				Help(" ",1,"HELP",STR0017,STR0018,1,0)
				lRet := .F.
		
			Else
				DbSelectArea("SE5")
				SE5->(DbSetOrder(4))
				If(SE5->(MsSeek(xFilial("SE5") + oModelSED:GetValue("ED_CODIGO"))))

					Help(" ",1,"HELP",STR0017,STR0018,1,0)
					lRet := .F.

				Else
					DbSelectArea("SEV")
					SEV->(DbSetOrder(3))
					If(SEV->(MsSeek(xFilial("SEV") + oModelSED:GetValue("ED_CODIGO"))))
						
							Help(" ",1,"HELP",STR0017,STR0018,1,0)
							lRet := .F.

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
RestArea(aSaveSE1)
RestArea(aSaveFRN)

Return lRet