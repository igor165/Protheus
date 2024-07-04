#define CRLF chr(13)+chr(10)

#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSAREXP.ch'
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAEXP
Exportação de RPS

@author David

@since 17/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSAEXP()

If MsgYesNo("Rotina descontinuada, utilizar a rotina de Lote de RPS [PLSRPS4], gostaria de visualizar a documentação da nova rotina? (ao clicar em Sim, será aberta a página da documentação no navegador padrão)", "Atenção!")
	cURL := "http://tdn.totvs.com.br/pages/viewpage.action?pageId=427043079" 	
	shellExecute("Open", cURL, "", "", 1)
endIf

Return
