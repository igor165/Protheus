#include 'protheus.ch'
#include 'parmtype.ch'

user function mt150rot()
local aRotina := ParamIXB	

AAdd(aRotina, { "Relat�rio de Cota��o", "u_SendWF", 0 , 4, 0, .f.})
AAdd(aRotina, { "Exporta Excel", "u_vacomr05", 0 , 4, 0, .f.})

return aRotina

user function SendWF(cAlias, nReg, nOpc)
local lEnvia := .t.
    if !Empty(SC8->C8_WFDT)
        lEnvia := (Aviso("Workflow de cota��o", "J� foi enviado o workflow de solicita��o de cota��o para o fornecedor. Deseja reenviar?", {"Sim", "N�o"}) == 1)
    endif

    if lEnvia
        U_VACOMR10({SC8->C8_NUM, SC8->C8_FORNECE+SC8->C8_LOJA, SC8->C8_NUMPRO},,{})
        //U_MT131WF({{SC8->C8_NUM, SC8->C8_FORNECE+SC8->C8_LOJA, SC8->C8_NUMPRO}})
    endif
return nil
