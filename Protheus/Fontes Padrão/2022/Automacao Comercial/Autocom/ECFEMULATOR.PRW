#INCLUDE "PROTHEUS.CH"

Function LJECFEmulator_Dummy			// Funcao "Dummy" para poder gerar o Patch
Return(NIL)

CLASS LJECFEmulator
	DATA cBuffer
	
	METHOD New()
	METHOD IFAbrir   (cModelo, cPorta)
	METHOD IFFechar  (cPorta)
	METHOD IFLeituraX()
	METHOD IFAbrECF  ()
	METHOD IFStatus  (cTipo)	
	METHOD IFPegPDV  ()
	METHOD IFPegCupom(cCancelamento)
	METHOD IFAbreCup (cCliente)
	METHOD IFPegSerie(aBuff)	
	METHOD IFReducaoZ(cMapaRes) 
	METHOD IFRegItem (cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade) 
	METHOD IFLeAliq  ()
	METHOD IFLeAliIss() 
	METHOD IFLeConPag() 
	METHOD IFGrvCondP(cCondicao) 
	METHOD IFCancItem(cNumitem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota) 
	METHOD IFCancCup (cSupervisor)
	METHOD IFFechaCup(cMensagem)	
	METHOD IFPagto	 (cPagto, cVinculado) 
	METHOD IFDescTot (cVlrDesconto) 
	METHOD IFMemFisc (cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo)	  
	METHOD IFAdicAliq(cAliquota, cTipo)	      
	METHOD IFAbrCNFis(cCondicao, cValor, cTotalizador, cTexto)	
	METHOD IFTxtNFis (cTexto, nVias) 	
	METHOD IFFchCNFis()	   
	METHOD IFRelGer  (cTexto, nVias)
	METHOD IFTotNFis (cNumero, cDescricao)                           
	METHOD IFAutentic(cVezes, cValor, cTexto) 
	METHOD IFGaveta  () 
	METHOD IFFchECF  () 	
	METHOD IFSupr    (cTipo, cValor, cForma, cTotal)
	METHOD IFPedido  (cTEF, cTexto, cValor, cCondPgTEF)
	METHOD IFRecbNFis(cTotalizador, cValor, cForma)
	METHOD IFAcresTot(cVlrAcrescimo)

	// Metodos auxiliares
	METHOD GetINI    (cNomeChave, cConteudo)
	METHOD WriteLog(cTexto)
ENDCLASS

//------------------------------------------------------------------------------
METHOD New() CLASS LJECFEmulator
Return

//------------------------------------------------------------------------------
METHOD IFAbrir(cModelo, cPorta) CLASS LJECFEmulator
Local nRet := If(::GetINI("Status do ECF") == "ON", 0, 1)
::WriteLog("IFAbrir   ("+cModelo+","+cPorta+") -> "+AllTrim(Str(nRet)))
Return(nRet)

//------------------------------------------------------------------------------
METHOD IFAbrECF() CLASS LJECFEmulator
::WriteLog("IFAbrECF  () -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFFechar() CLASS LJECFEmulator
::WriteLog("IFFechar  () -> 0")
Return 0

METHOD IFLeituraX() CLASS LJECFEmulator
::WriteLog("IFLeituraX  () -> 0")
Return 0

//------------------------------------------------------------------------------
METHOD IFStatus(cTipo) CLASS LJECFEmulator
Local nRet := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo - Indica qual o status quer se obter da impressora                           ³
//³    1 - Obtem a Hora da Impressora                                                 ³
//³    2 - Obtem a Data da Impressora                                                 ³
//³    3 - Verifica o Papel                                                           ³
//³    4 - Verifica se é possível cancelar um ou todos os itens.                      ³
//³    5 - Cupom Fechado ?                                                            ³
//³    6 - Ret. suprimento da impressora                                              ³
//³    7 - ECF permite desconto por item                                              ³
//³    8 - Verifica se o dia anterior foi fechado                                     ³
//³    9 - Verifica o Status do ECF                                                   ³
//³   10 - Verifica se todos os itens foram impressos.                                ³
//³   11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)                      ³
//³   12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim) ³
//³   13 - Verifica se o ECF Arredonda o Valor do Item                                ³
//³   14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)           ³
//³   15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)       ³
//³   16 - Verifica se exige o extenso do cheque                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "1"
	//  1 - Obtem a Hora da Impressora
	oAutocom:cBuffer := Time()
	nRet := 0
ElseIf cTipo == "2"
	//  2 - Obtem a Data da Impressora
	oAutocom:cBuffer := Substr(DToS(dDataBase),7,2)+"/"+Substr(DToS(dDataBase),5,2)+"/"+Substr(DToS(dDataBase),1,4)
	nRet := 0
ElseIf cTipo == "3"
	//  3 - Verifica o Papel
	nRet := 0
ElseIf cTipo == "4"
	//  4 - Verifica se é possível cancelar um ou todos os itens.
	oAutocom:cBuffer := "TODOS"
	nRet := 0
ElseIf cTipo == "5"
	//  5 - Cupom Fechado ?
	nRet := If(::GetINI("Cupom Aberto") == "ON", 7, 0)
ElseIf cTipo == "6"
	//  6 - Ret. suprimento da impressora
	nRet := 0
ElseIf cTipo == "7"
	//  7 - ECF permite desconto por item
	nRet := 11
ElseIf cTipo == "8"
	//  8 - Verifica se o dia anterior foi fechado
	nRet := If(::GetINI("Reducao Z") == "ON", 10, 1)
ElseIf cTipo == "9"
	//  9 - Verifica o Status do ECF
	nRet := 0
ElseIf cTipo == "10"
	// 10 - Verifica se todos os itens foram impressos.
	nRet := 0
ElseIf cTipo == "11"
	// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
	nRet := 1
ElseIf cTipo == "12"
	// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
	nRet := 1
ElseIf cTipo == "13"
	// 13 - Verifica se o ECF Arredonda o Valor do Item
	nRet := 0
ElseIf cTipo == "14"
	// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
	// 0 - Fechada
	nRet := 0
ElseIf cTipo == "15"
	// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
	nRet := 1
ElseIf cTipo == "16"
	// 16 - Verifica se exige o extenso do cheque  
	nRet := 1
	
ElseIf cTipo == "17"
	nRet := 0
	
ElseIf cTipo == "18"
	nRet := 0

Elseif cTipo == "45"
	nRet := 0

Elseif cTipo == "46"
	nRet := 0
EndIf
::WriteLog("IFStatus  ("+cTipo+") -> "+AllTrim(Str(nRet))+"   ("+oAutocom:cBuffer+")")
Return(nRet) 

//------------------------------------------------------------------------------
METHOD IFPegPDV() CLASS LJECFEmulator
oAutocom:cBuffer := ::GetINI("Numero do ECF")
::WriteLog("IFPegPDV  () -> 0   ("+oAutocom:cBuffer+")")
Return(0) 

//------------------------------------------------------------------------------
METHOD IFPegCupom(cCancelamento) CLASS LJECFEmulator
oAutocom:cBuffer := ::GetINI("Numero do Cupom Fiscal")
::WriteLog("IFPegCupom("+cCancelamento+") -> 0   ("+oAutocom:cBuffer+")")
Return(0)

//------------------------------------------------------------------------------
METHOD IFAbreCup(cCliente) CLASS LJECFEmulator
Local nRet := 1
Local cCOO
If ::GetINI("Status do ECF") == "ON"
	If ::GetINI("Cupom Aberto") == "OFF"
		cCOO := ::GetINI("Numero do Cupom Fiscal")
		::GetINI("Numero do Cupom Fiscal", StrZero(Val(cCOO)+1,6,0))
		::GetINI("Cupom Aberto", "ON")
		oAutocom:cBuffer := ::GetINI("Numero do Cupom Fiscal")
		nRet := 0
    Else
		MsgStop("Já existe um cupom aberto...", "ECF Emulator")
		nRet := 1
    EndIf
EndIf
::WriteLog("IFAbreCup ("+cCliente+") -> "+AllTrim(Str(nRet)))
Return(nRet)

//------------------------------------------------------------------------------
METHOD IFPegSerie() CLASS LJECFEmulator
oAutocom:cBuffer := '123456798'
::WriteLog("IFPegSerie() -> 0   ("+oAutocom:cBuffer+")")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFReducaoZ(cMapaRes) CLASS LJECFEmulator
oAutocom:cBuffer := '123456798'
::WriteLog("IFReducaoZ() -> 0   ("+oAutocom:cBuffer+")")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFRegItem(cCodigo, cDescricao, cQtde, cVlrUnit, cVlrDesconto, cAliquota, cVlTotIt, cUnidade) CLASS LJECFEmulator
::WriteLog("IFRegItem ("+cCodigo+","+cDescricao+","+cQtde+","+cVlrUnit+","+cVlrDesconto+","+cAliquota+","+cVlTotIt+","+cUnidade+") -> 0")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFLeAliq() CLASS LJECFEmulator
oAutocom:cBuffer := ::GetINI("Aliquotas ICMS")
::WriteLog("IFLeAliq  () -> 0   ("+oAutocom:cBuffer+")")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFLeAliISS() CLASS LJECFEmulator
oAutocom:cBuffer := ::GetINI("Aliquotas ISS")
::WriteLog("IFLeAliISS() -> 0   ("+oAutocom:cBuffer+")")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFLeConPag() CLASS LJECFEmulator
oAutocom:cBuffer := ::GetINI("Condicoes Pagto")
::WriteLog("IFLeConPag() -> 0   ("+oAutocom:cBuffer+")")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFGrvCondP(cCondicao) CLASS LJECFEmulator
::WriteLog("IFGrvConP("+cCondicao+") -> 0   ("+oAutocom:cBuffer+")")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFCancItem(cNumitem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrDesconto, cAliquota) CLASS LJECFEmulator
::WriteLog("IFCancItem("+cNumItem+","+cCodigo+","+cDescricao+","+cQtde+","+cVlrUnit+","+cVlrDesconto+","+cAliquota+") -> 0")
Return(0)      

//------------------------------------------------------------------------------
METHOD IFCancCup (cSupervisor) CLASS LJECFEmulator
::GetINI("Cupom Aberto", "OFF")
::WriteLog("IFCancCup ("+cSupervisor+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFFechaCup(cMensagem) CLASS LJECFEmulator
::GetINI("Cupom Aberto", "OFF")
::WriteLog("IFFechaCup("+cMensagem+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFPagto(cPagto, cVinculado) CLASS LJECFEmulator
::WriteLog("IFPagto   ("+cPagto+","+cVinculado+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFDescTot (cVlrDesconto) CLASS LJECFEmulator
::WriteLog("IFDescTot ("+cVlrDesconto+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFAcresTot(cVlrAcrescimo)CLASS LJECFEmulator
::WriteLog("IFAcresTot("+cVlrAcrescimo+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFMemFisc(cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo) CLASS LJECFEmulator
::WriteLog("IFMemFisc ("+cDataInicio+","+cDataFim+","+cReducInicio+","+cReducFim+","+cTipo+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFAdicAliq(cAliquota, cTipo) CLASS LJECFEmulator
::WriteLog("IFAdicAliq("+cAliquota+","+cTipo+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFAbrCNFis(cCondicao, cValor, cTotalizador, cTexto) CLASS LJECFEmulator
::WriteLog("IFAbrCNFis("+cCondicao+","+cValor+","+cTotalizador+","+cTexto+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFTxtNFis(cTexto, nVias) CLASS LJECFEmulator
Local nRet := 0
::WriteLog("IFTXTNFis ("+cTexto+","+AllTrim(Str(nVias))+") -> 0")
If ::GetINI("Simula Erro TextoNaoFiscal") == "ON"
	nRet := -1
EndIf
Return(nRet)

//------------------------------------------------------------------------------
METHOD IFFchCNFis() CLASS LJECFEmulator
::WriteLog("IFFchCNFis() -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFTotNFis(cNumero, cDescricao) CLASS LJECFEmulator
::WriteLog("IFToTNFis ("+cNumero+","+cDescricao+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFRelGer (cTexto, nVias) CLASS LJECFEmulator
::WriteLog("IFRelGer  ("+cTexto+","+AllTrim(Str(nVias))+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFAutentic(cVezes, cValor, cTexto) CLASS LJECFEmulator
::WriteLog("IFAutentic("+cVezes+","+cValor+","+cTexto+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFGaveta() CLASS LJECFEmulator
::WriteLog("IFGaveta  () -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFFchECF() CLASS LJECFEmulator
::WriteLog("IFFchECF  () -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFSupr(cTipo, cValor, cForma, cTotal) CLASS LJECFEmulator
::WriteLog("IFSupr    ("+cTipo+","+cValor+","+cForma+","+cTotal+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFPedido(cTEF, cTexto, cValor, cCondPgTEF) CLASS LJECFEmulator
::WriteLog("IFPedido  ("+cTEF+","+cTexto+","+cValor+","+cCondPgTEF+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD IFRecbNFis(cTotalizador, cValor, cForma) CLASS LJECFEmulator
::WriteLog("IFRecbNFis("+cTotalizador+","+cValor+","+cForma+") -> 0")
Return(0)

//------------------------------------------------------------------------------
METHOD GetINI(cNomeChave, cConteudo) CLASS LJECFEmulator
If cConteudo == NIL
	Return(GetPvProfString("ECF Emulator", cNomeChave, "", GetClientDir()+"ecfemul.ini"))
Else
	WritePProString("ECF Emulator", cNomeChave, cConteudo, GetClientDir()+"ecfemul.ini")
EndIf
Return(NIL)

//------------------------------------------------------------------------------
METHOD WriteLog(cTexto) CLASS LJECFEmulator
LJWriteLog(GetClientDir()+"ecfemul.log", DToC(dDataBase)+" "+Time()+"  "+cTexto)
Return(NIL)
