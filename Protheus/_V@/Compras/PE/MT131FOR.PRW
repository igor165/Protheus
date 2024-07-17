#Include 'Protheus.ch'
#include 'fwmvcdef.ch'

//Igor Oliveira 12/07/2024 - Ponto utilizado para acrescentar informações na geração da cotação
User Function MT131FOR()
    Local aFornec   := PARAMIXB[1] // Retornará todos os fornecedores sugeridos pelo sistema
    Local nRecno    := SA2->(RECNO())


    //if MsgYesNo("O Produto: "+SB1->B1_COD+" - "+AllTrim(SB1->B1_DESC)+" | Possui indicação de fornecedor. Deseja adciona-lo à cotação?")
        if SA2->(DbSeek(FWxFilial("SA2")+SB1->B1_XFORNEC+SB1->B1_XLOJA))
            
            aDel(aFornec,Len(aFornec))
            aSize(aFornec,Len(aFornec)-1)
            
            aAdd(aFornec, {SB1->B1_XFORNEC,SB1->B1_XLOJA,"SUGESTAO","SA2",SA2->(Recno())})
            
        endif
    //endif

    SA2->(DbGoTo(nRecno))

Return aFornec

User Function MT131C8() //Exibe informações de outros campos da SC8 no grid de fornecedores
    Local cCamposC8 := "|C8_DATPRF|C8_TAXAFIN)" 
// O retorno deve começar com uma barra vertical ( | ) e ir intercalando o nomes do campos com barras verticais.
Return cCamposC8

User Function MTA131C8() //Ponto utilizado para acrescentar informações na geração da cotação

Local oModFor := PARAMIXB[1]

//Customizações do usuario
oModFor:LoadValue("C8_CONTATO","TSTPE - "+oModFor:GetValue("C8_FORNECE"))

Return

/*
aFornec[1,1]  - Codigo Fornecedor

aFornec[1,2] - Loja Fornecedor

aFornec[1,3] - Criterio

aFornec[1,4] - Alias

aFornec[1,5] - Recno (Alias) 
*/

//Validações do Usuário.
