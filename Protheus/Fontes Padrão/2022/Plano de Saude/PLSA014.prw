#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include "topconn.ch"
#Include "APWIZARD.CH"    
#Include "FWBROWSE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA014
Tela de reajuste 
@author F�bio Siqueira dos Santos
@since 25/07/2016
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA014()

If MsgYesNo("Rotina descontinuada, utilizar a rotina de Tabela de Pre�os -> Reajuste de Pre�o, gostaria de visualizar a documenta��o do novo processo? (ao clicar em Sim, ser� aberta a p�gina da documenta��o no navegador padr�o)", "Aten��o!")
	cURL := "https://tdn.totvs.com/x/79W2Hg" 	
	shellExecute("Open", cURL, "", "", 1)
endIf

return