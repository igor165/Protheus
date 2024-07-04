#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CNTA301.CH"
#INCLUDE "GCTXDEF.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} CNTA301
Programa de manutenção de Contratos - Venda

@author Leandro.Moura
@since 23/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function CNTA301()
Return
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Rotina para montagem da view da manutenção de contratos - Tipo Venda

@author Leandro.Moura
@since 23/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil

	CNTSetFun("CNTA301")

	oView := FWLoadView("CNTA300")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTGetFun()
Rotina para montagem do model da manutenção de contratos - venda

@author Antenor Silva
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	//-- Seta função chamadora
	CNTSetFun("CNTA301")

	oModel := FWLoadModel("CNTA300")	

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} CN301ViewVd
Função que retorna a View do Pedido de Venda vinculado à Medição
@author miguel.santos
@since 20/07/2015
*/
//-------------------------------------------------------------------
Function CN301ViewVd(oModel)
	Local oModelCND 	:= Nil
	Local cPedido 		:= ""

	// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
	Private aRotina   	:= {}
	Private INCLUI    	:= .F.
	Private ALTERA    	:= .F.
	Private l120Auto	:= .F.
	Private nTipoPed  	:= 1
	Private cCadastro 	:= ""

	DEFAULT oModel 		:= FWModelActive()
	oModelSC5 	:= oModel:GetModel("SC5DETAIL")
	oModelCND 	:= oModel:GetModel("CNDDETAIL")
	cPedido 	:= oModelSC5:GetValue('C5_NUM')

	//--Monta o aRotina para compatibilizacao
	AAdd( aRotina, { '' , '' , 0, 1 } )
	AAdd( aRotina, { '' , '' , 0, 2 } )
	AAdd( aRotina, { '' , '' , 0, 3 } )
	AAdd( aRotina, { '' , '' , 0, 4 } )
	AAdd( aRotina, { '' , '' , 0, 5 } )

	If SC5->(DbSeek(xFilial("SC5")+cPedido))
		cCadastro    := STR0042	//"Pedido de Venda"
		A410Visual("SC5",SC5->( Recno()),2)
	Else
		Help('',1,'CNTA300SPD') //A Planilha selecionada não possui Pedidos!
	EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} CN301posic
Função para inicializar a variável aRotina antes da chamada da função a120Posic na ViewDef
@author Diego Bezerra
@since 17/08/2018
*/
//-------------------------------------------------------------------

Function CN301posic(cAlias, nReg, nNum, cChar, lBol)
	Private aRotina   	:= {}

	//--Monta o aRotina para compatibilizacao
	AAdd( aRotina, { '' , '' , 0, 1 } )
	AAdd( aRotina, { '' , '' , 0, 2 } )
	AAdd( aRotina, { '' , '' , 0, 3 } )
	AAdd( aRotina, { '' , '' , 0, 4 } )
	AAdd( aRotina, { '' , '' , 0, 5 } )

	a120Posic(cAlias ,nReg, nNum, cChar, lBol)
Return
