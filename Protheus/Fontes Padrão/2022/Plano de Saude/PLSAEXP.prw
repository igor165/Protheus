#define CRLF chr(13)+chr(10)

#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSAREXP.ch'
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAEXP
Exporta��o de RPS

@author David

@since 17/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSAEXP()

If MsgYesNo("Rotina descontinuada, utilizar a rotina de Lote de RPS [PLSRPS4], gostaria de visualizar a documenta��o da nova rotina? (ao clicar em Sim, ser� aberta a p�gina da documenta��o no navegador padr�o)", "Aten��o!")
	cURL := "http://tdn.totvs.com.br/pages/viewpage.action?pageId=427043079" 	
	shellExecute("Open", cURL, "", "", 1)
endIf

Return
