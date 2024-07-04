#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Class Estab
	data cod_estab_erp
	data des_estab
	Method New()
EndClass

Method New() Class Estab
	self:cod_estab_erp := ""
	self:des_estab := ""
Return

WSRESTFUL establishment DESCRIPTION "API para interação com estabelecimento(Grupo de Empresa e Filial do Protheus)"
	 
	WSDATA count      AS INTEGER
	WSDATA startIndex AS INTEGER
	 
	WSMETHOD GET DESCRIPTION "Retorna todos estabelecimentos(Grupo de empresas e Filiais cadastrados no Protheus, concatenado com um | )" WSSYNTAX "/establishment"
 
END WSRESTFUL
 
// O metodo GET nao precisa necessariamente receber parametros de querystring, por exemplo:
// WSMETHOD GET WSSERVICE spike 
WSMETHOD GET WSRECEIVE startIndex, count WSSERVICE establishment

	Local aEstab := {}
	Local oEstab
	Local aArea		:= SM0->(GetArea())
	
	OpenSM0()
	SM0->(dbGotop())
	
	while SM0->(! Eof())
		
		oEstab := Estab():New()
		
		oEstab:cod_estab_erp := SM0->M0_CODIGO + "." + AllTrim(SM0->M0_CODFIL)
		oEstab:des_estab := AllTrim(SM0->M0_NOME) + " - " + AllTrim(SM0->M0_FILIAL)
		
		aAdd(aEstab, oEstab)		
		
		SM0->(dbSkip())
	end
	 
	// define o tipo de retorno do método
	::SetContentType("application/json")	 

	::SetResponse(FWJsonSerialize(aEstab,.F.,.T.))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura area                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aArea)

Return .T.
 