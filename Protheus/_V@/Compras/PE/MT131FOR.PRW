#Include 'Protheus.ch'
#include 'fwmvcdef.ch'

//Igor Oliveira 12/07/2024 - Ponto utilizado para acrescentar informações na geração da cotação
User Function MT131FOR()
    Local aFornec   := PARAMIXB[1] // Retornará todos os fornecedores sugeridos pelo sistema
    Local nRecno    := SA2->(RECNO())


    if MsgYesNo("O Produto: "+SB1->B1_COD+" - "+AllTrim(SB1->B1_DESC)+" | Possui indicação de fornecedor. Deseja adciona-lo à cotação?")
        if SA2->(DbSeek(FWxFilial("SA2")+SB1->B1_XFORNEC+SB1->B1_XLOJA))
            
            aAdel(aFornec,Len(aFornec))
            aSize(aFornec,Len(aFornec)-1)
            
            aAdd(aFornec, {SB1->B1_XFORNEC,SB1->B1_XLOJA,"SUGESTAO","SA2",SA2->(Recno())})
            
        endif
    endif

    SA2->(DbGoTo(nRecno))

Return aFornec

/*
aFornec[1,1]  - Codigo Fornecedor

aFornec[1,2] - Loja Fornecedor

aFornec[1,3] - Criterio

aFornec[1,4] - Alias

aFornec[1,5] - Recno (Alias) 
*/

//Validações do Usuário.
