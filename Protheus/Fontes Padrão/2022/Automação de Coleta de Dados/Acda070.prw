#INCLUDE "Acda070.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDA070  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Transacoes da Producao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA070


PRIVATE cCadastro := STR0001 //"Transacoes da Producao"
PRIVATE aRotina 	:= Menudef() 
mBrowse( 6, 1, 22, 75, "CBI")
Return


Function ACDA070A(cAlias,nReg,nOpc)
Local lRet

If nopc == 3
	lRet:= AxInclui(cAlias,nReg,nOpc)
ElseIf nopc == 4
	lRet:= AxAltera(cAlias,nReg,nOpc)
ElseIf nopc == 5
	lRet:= AxDeleta(cAlias,nReg,nOpc)
EndIF

Return lRet


 /*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 21/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu :=  {	{ STR0002    , "AxPesqui"    	 , 0 , 1},; //"Pesquisar"
				{ STR0003 	 , "AxVisual"    	 , 0 , 2},; //"Visualizar"
				{ STR0004    , "ACDA070A"  		 , 0 , 3},; //"Incluir"
				{ STR0005    , "ACDA070A"        , 0 , 4},; //"Alterar"
				{ STR0006    , "ACDA070A"        , 0 , 5}} //"Excluir"

 
 RETURN aRotMenu


