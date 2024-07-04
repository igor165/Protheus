#INCLUDE "TURA042A.ch"
#Include "Totvs.ch"
#Include "FWMVCDef.ch" 

/*/{Protheus.doc} TA042Vencto
Função para obter a data de vencimento da fatura da conciliação
@type function
@author Thiago TavaresT34CMPATIFT34CMPATIF
@since 02/02/2017
@version 1.0
/*/
Function TA042Vencto(nValor, cCondicao)

Local aArea   := GetArea()
//Local oModel  := TA042AGetMdl()
Local aRet    := {}
Local dVencto := SToD('')

dVencto := ddatabase//oModel:GetValue('G8C_MASTER', 'G8C_VENCIM')

DbSelectArea('SE4')
SE4->(DbSetOrder(1))		// E4_FILIAL+E4_CODIGO
If SE4->(DbSeek(xFilial('SE4') + cCondicao))
	If SE4->E4_TIPO == Alltrim(GetMv('MV_TURTPCD', , 'C')) 		//Parâmetro do Tipo de Condição de Pagamento
		aRet := TURxCond(nValor, cCondicao, dVencto)
	EndIf
EndIf
SE4->(DbCloseArea())

RestArea(aArea)

Return aRet 
