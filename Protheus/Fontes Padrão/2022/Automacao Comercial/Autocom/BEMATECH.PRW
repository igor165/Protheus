#INCLUDE "Protheus.ch"

Function Bematech_Dummy			// Funcao "Dummy" para poder gerar o Patch
Return(NIL)

CLASS LJBematech
//	DATA 
	
	METHOD New		 ()
	METHOD IFAbrir	 (cModelo, cPorta) 
	METHOD IFLeituraX()
	METHOD IFPegCupom(cCancelamento)
	METHOD IFAbrECF	 ()
	METHOD IFStatus  (cTipo)
ENDCLASS

METHOD New() CLASS LJBematech
Return

METHOD IFAbrir(cModelo, cPorta) CLASS LJBematech
Local nRet := ExecDLL("Bematech_FI_AbrePortaSerial")
//::TrataRetornoBematech( nRet )
If nRet <> 1
	MsgStop("Erro na abertura da porta")
EndIf
nRet := ExecDLL("Bematech_FI_LeituraX")
If nRet <> 1
	MsgStop("Erro na abertura da porta")
EndIf

Return(nRet)

METHOD IFLeituraX() CLASS LJBematech
//Local nRet := ExecDLL("Bematech_FI_LeituraX")
nRet := ExecDLL("Bematech_FI_RetornoImpressora")
Return(nRet)

METHOD IFPegCupom(cCancelamento) CLASS LJBematech
Local nRet := ExecDLL("Bematech_FI_NumeroCupom")
Return(nRet)

METHOD IFAbrECF(cCancelamento) CLASS LJBematech
Return(0)

METHOD IFStatus(cTipo)CLASS LJBematech
Return(0)
