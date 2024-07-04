#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "WSLOJ035.CH"


Function WSL0J030()
Return Nil


WSSERVICE LOJGERDADDR DESCRIPTION STR0001 //"Busca dados para Template Drogaria" 

	WSDATA Estacao AS String
	
	WSDATA cProduto As String
	WSDATA cLote     As String
	WSDATA cConfirme  As String
	WSDATA lAchou    As Boolean


	WSDATA StLink	AS String
	
	WSDATA cFil					As String					//Define se realiza a exportacao dos Dados de Saida
	WSDATA cEmp					As String					//Define se realiza a exportacao dos Dados de Saida

	WSMETHOD GetLote  DESCRIPTION STR0002 //"Consulta Lote"          

ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³GetLote 	³ Autor ³ Venda Clientes        ³ Data ³02/09/2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza consulta de lote                      			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  ExpC1 =  Produto			³±±
±±³		ExpC2 =	 Lote
		ExpC3 =  Empresa
		ExpC4 =  Filial   								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ lAchou - Resultado do processamento			                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD GetLote WSRECEIVE cProduto, cLote, cEmp, cFil WSSEND lAchou WSSERVICE LOJGERDADDR

Local lPrepEnv		:= If (FindFunction('LjPreparaWs'),LjPreparaWs(cEmp, cFil), .F.)	//faz prepare Environment 
Local cLocal        := "" // Armazem do produto  

Default cProduto 	:= "" 
Default cLote		:= ""
Default cEmp		:= "" 
Default cFil		:= ""


::lAchou :=.F.

DbSelectArea("SB1")
DbSetOrder(1)        

If DbSeek( xFilial("SB1")+cProduto)
	
	cLocal := SB1->B1_LOCPAD
	DbSelectArea("SB8")
	DbSetOrder(3)        
		   
	cProduto :=  SubStr(cProduto,1,TamSX3("B8_PRODUTO")[1]) 	//Formata a variavel no tamanho correto do campo
    	::lAchou := DbSeek( xFilial("SB8")+cProduto+cLocal+cLote) 
        
EndIf

Return(.T.)