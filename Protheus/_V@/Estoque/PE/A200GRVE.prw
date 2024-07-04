#include "RWMake.ch"
#include "Protheus.ch"
#include "TopConn.ch"

user function A200GRVE()
// local nOpc := ParamIXB[1]
local aArea := GetArea()
local cTime := ""
local cSeq  := ""

// Cria ZG1 caso n�o exista
DBSelectArea("ZG1")
ZG1->(DBSetOrder(1))

// paramIXB[1] -> N, nOpc
// paramIXB[2] -> L, Mapa de diverg�ncias ativo
// paramIXB[3] -> A, RECNO de cada componente exclu�do da tabela SG1 p/ nOpc == 5
// paramIXB[4] -> A, {RECNO do registro, [1- Inclus�o, 2- Exclus�o, 3- Altera��o]}

// se for inclus�o ou altera��o e houve alguma opera��o com registro da SG1
if (ParamIXB[1] == 3 .or. ParamIXB[1] == 4) .and. !Empty(ParamIXB[4])

    begin transaction

    // Calcula nova sequ�ncia
    cSeq := u_NextSeq("G1_SEQ")

    // Atualiza campo sequ�ncia da estrutura
    TCSqlExec("update " + RetSqlName("SG1") +;
                   " set G1_ENERG = " + AllTrim(Str(M->G1_ENERG)) +;
                      ", G1_SEQ = '" + cSeq + "'" +;
                 " where G1_FILIAL = '" + FWxFilial("SG1") + "'" +;
                   " and G1_COD = '" + cProduto + "'" +;
                   " and D_E_L_E_T_ = ' '" ;
                 )
    
    // Cria historico da estrutura
    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                              " select G1_FILIAL, G1_COD, G1_COMP, G1_TRT, G1_QUANT, G1_PERDA, G1_INI, G1_FIM, G1_OBSERV, G1_FIXVAR, G1_GROPC"+;
                                    ", G1_OPC, G1_REVINI, G1_REVFIM, G1_NIV, G1_NIVINV, G1_POTENCI, G1_VECTOR, G1_OK, G1_TIPVEC, G1_VLCOMPE,"+;
                                    ", G1_ENERG, G1_SEQ " +;
                                " from " + RetSqlName("SG1") + " SG1" +;
                               " where SG1.G1_FILIAL = '" + FWxFilial("SG1") + "'" +;
                                 " and SG1.G1_COD = '" + cProduto + "'" +;
                                 " and SG1.G1_SEQ = '" + cSeq + "'" +;
                                 " and SG1.D_E_L_E_T_ = ''" ;
                                         ), "TMPSG1", .f., .t.) 
        cTime := Time()
        while !TMPSG1->(Eof())
            RecLock("ZG1", .t.)
                ZG1->ZG1_FILIAL := TMPSG1->G1_FILIAL
                ZG1->ZG1_COD    := TMPSG1->G1_COD
                ZG1->ZG1_COMP   := TMPSG1->G1_COMP
                ZG1->ZG1_TRT    := TMPSG1->G1_TRT
                ZG1->ZG1_QUANT  := TMPSG1->G1_QUANT
                ZG1->ZG1_PERDA  := TMPSG1->G1_PERDA
                ZG1->ZG1_INI    := SToD(TMPSG1->G1_INI)
                ZG1->ZG1_FIM    := SToD(TMPSG1->G1_FIM)
                ZG1->ZG1_OBSERV := TMPSG1->G1_OBSERV
                ZG1->ZG1_FIXVAR := TMPSG1->G1_FIXVAR
                ZG1->ZG1_GROPC  := TMPSG1->G1_GROPC
                ZG1->ZG1_OPC    := TMPSG1->G1_OPC
                ZG1->ZG1_REVINI := TMPSG1->G1_REVINI
                ZG1->ZG1_REVFIM := TMPSG1->G1_REVFIM
                ZG1->ZG1_NIV    := TMPSG1->G1_NIV
                ZG1->ZG1_NIVINV := TMPSG1->G1_NIVINV
                ZG1->ZG1_POTENC := TMPSG1->G1_POTENCI
                ZG1->ZG1_VECTOR := TMPSG1->G1_VECTOR
                ZG1->ZG1_OK     := TMPSG1->G1_OK
                ZG1->ZG1_TIPVEC := TMPSG1->G1_TIPVEC
                ZG1->ZG1_VLCOMP := TMPSG1->G1_VLCOMPE
                ZG1->ZG1_ENERGI := TMPSG1->G1_ENERG
                ZG1->ZG1_SEQ    := TMPSG1->G1_SEQ
                ZG1->ZG1_DTALT  := Date()
                ZG1->ZG1_HRALT  := cTime
                ZG1->ZG1_CODUSU :=  __cUserId
            MsUnlock()
            TMPSG1->(DbSkip())
        end
    TMPSG1->(DbCloseArea())
    end transaction
endif

RestArea(aArea)
return nil

