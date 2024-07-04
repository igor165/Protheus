#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "RwMake.ch"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} RegT046
	(Realiza a geracao do registro T046 do TAF)

	@type Static Function
	@author Vitor Henrique
	@since 16/09/2016

	@param aRegs0210, array, Array com informações do 0210 a serem geradas

	@return Nil, nulo, não tem retorno
	/*/
Function ExtT046(aRegs0210)	

	Local cReg := "T046"
	Local cRegFilho := "T046AA"
	Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
	Local cDataDe := DToS(oWizard:GetDataDe())
	Local cDataAte := DToS(oWizard:GetDataAte())

	Local nI := 1
	Local nCnt := 1
	Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

	Default aRegs0210  := {}

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)

	// Gera todos o registro 0210
	For nI := 1 to Len(aRegs0210)
		FConcTxt(aRegs0210[nI],nHdlTxt)
		
		// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf
	Next

	// Libero Handle do Arquivo
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return Nil