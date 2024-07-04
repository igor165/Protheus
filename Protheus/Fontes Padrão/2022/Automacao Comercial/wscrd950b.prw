#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSCRD950B.CH"

WSSTRUCT LSVC 
	WSDATA Valor 		AS Float 
	WSDATA Validade		AS Date
	WSDATA Ret 		    AS Boolean
ENDWSSTRUCT 

WSSTRUCT DadVale 
	WSDATA CodVale 		AS String 
	WSDATA Valor 		AS Float 
	WSDATA Validade		AS Date
	WSDATA Ret 		    AS Boolean
ENDWSSTRUCT

WSSTRUCT RECARRAY 
	WSDATA VERARRAY		AS Array of DadVale 
ENDWSSTRUCT


WSSERVICE FRTCRDPSVPG DESCRIPTION STR0003 //"Serviço de Pesquisa e Atualização de Status de Vale compra no Pagamento"
           						   	    
	WSDATA cVale	AS String  
	WSDATA CrdLSVC	AS Array of LSVC
	WSDATA Vales	AS RECARRAY	    
	WSDATA Ret		AS Boolean
	
	WSMETHOD CrdPSVcPg   DESCRIPTION STR0002 // "Retorno de pesquisa"  
	WSMETHOD CrdUpdMAV   DESCRIPTION STR0004 // "Atualiza Status do Vale Compra"                      

ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³CrdPSVcPg ³ Autor ³ Venda Clientes        ³ Data ³24/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Servico de Pesquisa de Vale compra no Pagamento.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Vale Compra.                             ³±±

±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Dados do Vale Compra (nValor, dValidade).	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD CrdPSVcPg WSRECEIVE cVale WSSEND CrdLSVC WSSERVICE FRTCRDPSVPG

Local nValor		:= 0
Local dValidade
Local lRet 			:= .T.

AAdd(::CrdLSVC,WSClassNew("LSVC"))

lRet := Crd240ValidUsoVale( cVale, "2", @nValor, @dValidade )

::CrdLSVC[1]:Valor 		:= nValor 
::CrdLSVC[1]:Validade	:= dValidade
::CrdLSVC[1]:Ret 		:= lRet


Return(.T.)
//GERACAO PACOTE PAF-ECF 06/08/2010

//GERACAO PACOTE PAF-ECF 12/08/2010
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³ CrdUpdMAV³ Autor ³ Venda Clientes        ³ Data ³12/01/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Status do Vale Compra.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com Vales Compra e seus respectivos dados.   ³±±
±±³			 ³ (cCodVale,nValor,dValidade)					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpL1 -                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD CrdUpdMAV WSRECEIVE Vales WSSEND Ret WSSERVICE FRTCRDPSVPG

Local lRet 		:= .T. 
Local nX		:= 0
Local aVales	:= Array(Len(Vales:VERARRAY)) 

For nX:=1 To Len(Vales:VERARRAY)

	aVales[nX] := Array(04)
	
	aVales[nX][1] := Vales:VERARRAY[nX]:CodVale
	aVales[nX][2] := Vales:VERARRAY[nX]:Valor
	aVales[nX][3] := Vales:VERARRAY[nX]:Validade
	aVales[nX][4] := Vales:VERARRAY[nX]:Ret
Next nX

lRet := Crd240UpdMAV( aVales, "3",, .T. )	

Return(lRet)