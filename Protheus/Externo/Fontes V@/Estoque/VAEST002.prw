#include "protheus.ch"

/*/{Protheus.doc} vaest002

    Estorna os apontamentos de uma ordem de produ��o, cancela os empenhos e seus apontamentos, de acordo com os parametros.

@type function
@author JRScatolon Informatica 

@param cOP, Caracter, N�mero da ordem de produ��o

@return nil

@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/
user function vaest002(cOP)
local aArea := GetArea()

DbSelectArea("SC2")
DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

DbSelectArea("SB2")
DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

// Procura pela ordem de produ��o
if !SC2->(DbSeek(xFilial("SC2")+cOP+"01001  "))
    UserException("Ordem de produ��o n�o encontrada. N�o � possivel estornar o apontamento.")
endif

// verifica se houve apontamento na OP e a encerra
if SC2->C2_QUJE > 0 
    SB2->(DbSeek(xFilial("SB2")+SC2->C2_PRODUTO+SC2->C2_LOCAL))
    if SaldoSB2() < SC2->C2_QUJE
        UserException("N�o existe saldo suficiente para estornar o apontamento de produ��o. N�o � poss�vel estornar o apontamento. Op: ["+AllTrim(SC2->C2_NUM)+"]")
    endif
    u_EstornOP(cOP)
endif

// remove os empenhos da ordem de produ��o
u_LimpaEmp(cOP)

// encerra a ordem de produ��o
u_ExclOP(cOP)

if !Empty(aArea)
    RestArea(aArea)
endif
return nil
