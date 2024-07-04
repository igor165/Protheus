#include "protheus.ch"

/*
 * CRIAR PARAMETROS
 * ----------------
 * Parametro:     VA_MOVTRAT
 * Tipo:          C
 * Descri��o:     Parametro customizado usado pela rotina vaest004. Tipo de movimento (SF5) utilizado para apontamento automatizado de trato.
 *
 * Parametro:     VA_CCPRDTR
 * Tipo:          C
 * Descri��o:     Parametro customizado usado pela rotina vaest004. Centro de custo utilizado para apontamento automatizado da Alimenta��o.
 *
 * Parametro:     VA_ICPRDTR
 * Tipo:          C
 * Descri��o:     Par�metro customizado usado pela rotina vaest004. Item contabil utilizado para apontamento automatizado da batida. 
 * 
 * Parametro:     VA_CLPRDTR
 * Tipo:          C
 * Descri��o:     Par�metro customizado usado pela rotina vaest004. Classe de valor utilizado para apontamento automatizado da batida. 
 */
/*/{Protheus.doc} vesta004

 Apontamento de alimenta��o de animais

@type function
@author JRScatolon Informatica

@param cIndividuo, Caractere, C�digo do produto do animal envolvido
@param cRacao, Caractere, C�digo do produto ra��o usado na alimenta��o
@param nQuant, Num�rico, quantidade de ra��o usada na alimenta��o

@return numero da ordem de produ��o

@obs Caso seja criada a vari�vel cNumOP como privada essa fun��o ir� preencher o numero da ordem de produ��o no momento de sua cria��o
@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/

user function vaest004(cIndividuo, cRacao, nQuant, cArmz, cArmzRac)
local aArea := GetArea()
local cMovTrat := GetMV("VA_MOVTRAT")
local cCC := GetMV("VA_CCPRDTR")
Local cIC:= GetMV("VA_ICPRDBA")
Local cClvl:= GetMV("VA_CLPRDBA")

default cArmz := ""
default cArmzRac := ""

cIndividuo := PadR(cIndividuo, TamSX3("B1_COD")[1])
cRacao := PadR(cRacao, TamSX3("B1_COD")[1])

DbSelectArea("SC2")
DbSetorder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL+B1_COD

DbSelectArea("SB2")
DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

if SB1->(DbSeek(xFilial("SB1")+cIndividuo))

    if Empty(cArmz)
        cArmz := SB1->B1_LOCPAD
    endif

    if SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cArmz)) .and. SB2->B2_QATU > 0
        //if SB2->B2_QATU == 1 // n�o � possivel executar essa valida��o devido ao desvio de escopo. � necess�rio aceitar mais de um animal devido aos apontamentos nas fazendas.
            if SB1->(DbSeek(xFilial("SB1")+cRacao))
                if Empty(cArmzRac)
                    cArmzRac := SB1->B1_LOCPAD
                endif
                if SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cArmzRac)) .and. nQuant <= SB2->B2_QATU
                    aEmpenho := { { cIndividuo,  cArmz,          1 },;
                                  { SB1->B1_COD, cArmzRac, nQuant } }
                    cNumOP := ""
                    cNumOP := u_CriaOp(cIndividuo, 1, cArmz)
                    u_LimpaEmp(cNumOP)
                    u_AjustEmp(cNumOP, aEmpenho)
                    u_ApontaOP(cNumOp, cMovTrat, cCC, cIC, cClvl)
                else
                    MsgStop("N�o existe saldo suficiente para apontar a alimenta��o [" + AllTrim(cRacao) + "] do animal [" + AllTrim(cIndividuo) + "]." )
                endif
            else
                MsgStop("Racao [" + AllTrim(cRacao) + "] n�o foi encontrada no cadastro de produtos." )
            endif
        //else
        //    MsgStop("O Animal [" + AllTrim(cIndividuo) + "] possui saldo em estoque inv�lido para essa opera��o. Por favor verifique se o produto se trata de um animal." )
        //endif
    else
        MsgStop("O Animal [" + AllTrim(cIndividuo) + "] n�o possui saldo em estoque. Por favor verifique." )
    endif
else
    MsgStop("O Animal [" + AllTrim(cIndividuo) + "] n�o cadastrado. Por favor verifique." )
endif

return cNumOp
