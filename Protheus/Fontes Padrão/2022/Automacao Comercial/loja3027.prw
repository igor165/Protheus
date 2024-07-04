#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Loja3027 ³ Autor ³                 		³ Data ³  13/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que define a prioridade da regra de desconto.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                		    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Funçao é chamada do Painel de Gestão (fonte:loja303)			³±±
±±³            do método(Lj3catregdesc), retorna Array (filial,Prod, %)		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function Loja3027(cfil,cRegra,dDtRegra)

Local aProdRegra	:= {}
Local aProdutos		:= {}
Local cLoja			:= ""
Local cCliente		:= ""
Local cTipoProd		:= ""
Local nX			:= 0
Local nDescPer		:= 0 
Local nQtd			:= 1
Local lPainel		:= .T.
Default cfil		:= ""
Default cRegra		:= ""
Default dDtRegra	:= ctod(" / /    ")

//////// Localizar a regra e retornar um array com todos os Produtos da (regra), se tiver categoria transformar em Produtos.

DbselectArea("MB8")
DbSetOrder(1)

If DbSeek(xFilial("MB8")+cRegra)
	While !Eof() .and. Alltrim(MB8->MB8_CODREG) == Alltrim(cRegra)
		IF !EMPTY(MB8->MB8_CODPRO)
			AADD(aProdRegra,{MB8->MB8_CODPRO,cCliente,cTipoProd})  //// SE PRODUTO JA ADD NO ARRAY
			
		elseif !EMPTY(MB8->MB8_CATEGO)         /// SE CATEGORIA , BUSCA NA ACV TODOS OS PRODUTOS DA CATEGORIA E ADD NO ARRAY
			
			DbselectArea("ACV")
			DbSetOrder(1)
			If DbSeek(xFilial("ACV")+MB8->MB8_CATEGO)         ///StrZero(cTabPreco,3)
				While !Eof() .and. Alltrim(ACV->ACV_CATEGO) == Alltrim(MB8->MB8_CATEGO)
					AADD(aProdRegra,{ACV->ACV_CODPRO,cCliente,cTipoProd})
					ACV->(DbSkip())
				End
			Endif
			
			DbselectArea("MB8")
			DbSetOrder(1)
			
		Endif
		
		MB8->(DbSkip())
	End
Endif


//// com o Array de todos os produtos, validar o desconto de cada produto com a funçao : RGDesIte (fonte:Loja3025)
For nX :=1  to Len(aProdRegra)
	nDescPer := 0
	
	/// receb o percentual de desconto , fazendo calculo se acumula ou nao as regras , fonte: loja3025   
	//  RGDesIte(cProduto, cCliente, cTipoProd, cLoja, dDataInicio)
	nDescPer := RGDesIte(aProdRegra[nX][1],aProdRegra[nX][2],aProdRegra[nX][3],cLoja,dDtRegra,nQtd,lPainel)
	
	/// array aProdutos ira retornar para a funçao Lj3RegDesc - loja303 - Painel de gestão
	AADD(aProdutos,{xFilial("MB8"),aProdRegra[nX][1],nDescPer})
Next nX
Return(aProdutos)

