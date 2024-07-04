#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include "topconn.ch"
#Include "APWIZARD.CH"    
#Include "FWBROWSE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA014
Tela de reajuste 
@author Fábio Siqueira dos Santos
@since 25/07/2016
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA014()

If MsgYesNo("Rotina descontinuada, utilizar a rotina de Tabela de Preços -> Reajuste de Preço, gostaria de visualizar a documentação do novo processo? (ao clicar em Sim, será aberta a página da documentação no navegador padrão)", "Atenção!")
	cURL := "https://tdn.totvs.com/x/79W2Hg" 	
	shellExecute("Open", cURL, "", "", 1)
endIf

return