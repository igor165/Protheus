#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWEBSRV.CH" 
#INCLUDE "AUTODEF.CH" 
#INCLUDE "TBICONN.CH"

WSSERVICE WSINCLUNCC DESCRIPTION  "WS para gerar NCC para utilização na proxima Venda." 

	WSDATA cL1Doc 		AS String	OPTIONAL
	WSDATA cL1Serie 	AS String	OPTIONAL
	WSDATA cL1Oper 		AS String	OPTIONAL
	WSDATA dL1EmisNf	AS Date		OPTIONAL
	WSDATA cL1Cliente	AS String	OPTIONAL
	WSDATA cL1Loja		AS String	OPTIONAL
	WSDATA nL1Credit	AS Float	OPTIONAL
	WSDATA cSerEst		AS String	OPTIONAL
	WSDATA lRet			AS Boolean	OPTIONAL
	WSDATA dDatValid    AS Date		OPTIONAL
    WSDATA nValorNcc	AS Float  	OPTIONAL
    WSDATA cEmpPDV	    AS String  	OPTIONAL
	WSDATA cFilPDV	  	AS String  	OPTIONAL
	WSDATA lMvLjPdvPa	AS Boolean 	OPTIONAL
	
	WSMETHOD INCNVTIT DESCRIPTION "Metodo para realizar a Inclusao da NCC"
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  INCNVTIT ³ Autor ³ Vendas Cliente       ³ Data ³ 26/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 	Metodo Gera Titulo para Desconto na Proxima Compra		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	ExpL1:= LJGerTitNV()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³	nValorNcc,cL1Doc,cEmpPDV,cSerEst,cL1Serie,cL1Oper		  ³±±
±±³          ³ 	dL1EmisNf,cL1Cliente,cL1Loja,cFilPDV,dDatValid,lMvLjPdvPa ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³	ExpL1 = .T.            									  ³±±
±±³          ³                                     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ 		 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD INCNVTIT WSRECEIVE	nValorNcc	,	cL1Doc 		,	cEmpPDV		,	cSerEst		,;
							cL1Serie 	,	cL1Oper		,	dL1EmisNf	,	cL1Cliente	,;
							cL1Loja 	,	cFilPDV		,	dDatValid,;		 
							lMvLjPdvPa 	WSSEND lRet WSSERVICE WSINCLUNCC

Local lRet	:= .T. 	//Retorno da funcao

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPDV,cFilPDV)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera novo Titulo para o cliente	  				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet	:= LJGerTitNV(	cL1Doc		,	cL1Serie	,	cL1Oper	 ,	dDatValid,;
						nValorNcc 	,	cL1Cliente	,	cL1Loja  ,	cSerEst  ,;
						dL1EmisNf)

If !lRet
	SetSoapFault("Erro LJGerTitNV", "Erro LJGerTitNV")	
EndIf

Return (lRet)
