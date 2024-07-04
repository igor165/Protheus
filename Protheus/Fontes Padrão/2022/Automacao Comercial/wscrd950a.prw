#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSCRD950A.CH"      

WSSTRUCT WScrdRetBX
	WSDATA Seleciona	AS Boolean
	WSDATA Saldo		AS Float
	WSDATA NumTitulo	AS String
	WSDATA DataCRD   	AS Date			
	WSDATA NumRecno		AS Integer
	WSDATA Saldo2		AS Float
	WSDATA MvMoeda     	AS String
	WSDATA Moeda     	AS Integer
	WSDATA Prefixo     	AS String
	WSDATA Parcela		AS String
	WSDATA Tipo     	AS String
ENDWSSTRUCT

WSSTRUCT WSCRDVABX
	WSDATA CRDPre1		AS Float
	WSDATA CRDPre2		AS String
	WSDATA CRDPre3		AS String
	WSDATA CRDPre4		AS String
	WSDATA CRDPre5		AS Float
	WSDATA CRDPre6		AS Float
	WSDATA CRDPre7		AS Float
ENDWSSTRUCT

WSSTRUCT WSCRDArrBX
	WSDATA VerArrBX AS ARRAY OF WSCRDVABX
ENDWSSTRUCT


WSSERVICE FRTCRDBX DESCRIPTION  STR0001 //"Serviço de Resgate de Vale Compra"  

	WSDATA aCRDValeC	AS WSCRDArrBX
	WSDATA nCRDUsada 	AS Float
	WSDATA nUsado	 	AS Float 
	WSDATA cMotivo		AS String 	
	WSDATA nCRDGerada 	AS Float
	WSDATA cL1Doc 		AS String
	WSDATA cL1Serie 	AS String
	WSDATA cL1Oper 		AS String
	WSDATA dL1EmisNf	AS Date
	WSDATA cL1Cliente	AS String
	WSDATA cL1Loja		AS String
	WSDATA nL1Credit	AS Float
	WSDATA cSerEst		AS String
	WSDATA cCodVale  	AS String
	WSDATA nValor		AS Float
	WSDATA nTotPag 		AS Float
	WSDATA cOpc         AS String
	WSDATA nLinha 		AS Integer
	WSDATA nCRDGerRet	AS Float
	
	WSMETHOD FRTCRD02  DESCRIPTION STR0002 //"Metodo para realizar a baixa de Vale Compras"
ENDWSSERVICE

WSSERVICE DELCRDX DESCRIPTION  STR0003 //"Serviço de delecao da CRD" 

	WSDATA cBxFilial	AS String
	WSDATA cBxDoc		AS String
	WSDATA cBxSerie		AS String
	WSDATA cBxCliente	AS String
	WSDATA cBxLoja		AS String
	WSDATA NADA 		AS Boolean
	
	WSMETHOD FRTDELCRD DESCRIPTION STR0004 //"Metodo para realizar a delecao da CRD"
ENDWSSERVICE



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³FRTBXCRD  ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a baixa das CRDs selecionadas           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - CRDs da venda        							  ³±±
±±³          ³ ExpN2 - CRD a baixar         							  ³±±
±±³          ³ ExpN3 - CRD a gerar          							  ³±±
±±³          ³ ExpC4 - Doc da venda         							  ³±±
±±³          ³ ExpC5 - Serie da venda       							  ³±±
±±³          ³ ExpC6 - Operador da venda    							  ³±±
±±³          ³ ExpD7 - Data de emissao      							  ³±±
±±³          ³ ExpC8 - Cliente da venda     							  ³±±
±±³          ³ ExpC9 - Loja da venda        							  ³±±
±±³          ³ ExpN10 - Credito utilizado    							  ³±±
±±³          ³ ExpC11 - Serie a gerar        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.                   						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//WSMETHOD FRTCRD02 WSRECEIVE aCRDValeC, cCodVale, nValor,  nTotPag, cOpc, nLinha WSSEND nCRDGerRet WSSERVICE  FRTCRDBX
WSMETHOD FRTCRD02 WSRECEIVE aCRDValeC, cL1Cliente, cL1Loja, nUsado, cL1Doc,	cL1Serie, cMotivo   WSSEND nCRDGerRet WSSERVICE  FRTCRDBX
																												 		
Local aVales	:= {}								//CRD selecionadas//
Local nX		:= 0								//Contador de For
conout("Baixa")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recebe o aCRDValeC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( ::aCRDValeC:VerArrBX )
	conout("Baixa1")
	AAdd( aVales, Array( 12 ))
	conout("add aVales 1 ")
	aVales[nX][1] := ::aCRDValeC:VerArrBX[nX]:CRDPRE1
	conout("add aVales 2 ")
	aVales[nX][2] := ::aCRDValeC:VerArrBX[nX]:CRDPRE2
	aVales[nX][3] := ::aCRDValeC:VerArrBX[nX]:CRDPRE3
	aVales[nX][4] := ::aCRDValeC:VerArrBX[nX]:CRDPRE4
	aVales[nX][5] := ::aCRDValeC:VerArrBX[nX]:CRDPRE5
	aVales[nX][6] := ::aCRDValeC:VerArrBX[nX]:CRDPRE6
	aVales[nX][7] := ::aCRDValeC:VerArrBX[nX]:CRDPRE7

	Crd240GrvMaz( "", aVales[nX][4] , cMotivo, "1" )

Next nX	

conout("Crd240FinRes")
Crd240FinRes(	cL1Cliente,	cL1Loja, aVales, nUsado,;
						cL1Doc,		cL1Serie )

Return(.T.)
