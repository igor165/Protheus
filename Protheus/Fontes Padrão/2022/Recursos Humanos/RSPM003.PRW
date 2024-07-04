#Include "fileio.ch"
#Include "Protheus.ch"
#Include "RSPA090.CH"

#define CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RSPM003  บAutor  ณOswaldo L                       ณ  05/10/17   บฑฑ
ฑฑฬออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data	  ณ BOPS/FNC  ณ  Motivo da Alteracao 		           ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบOswaldo L  |17/10/17|DRHPAG-7555|Carga inicial dos dados                    ณฑฑ
ฑฑณ           |        |           |para tabela fisica ctree(RT0\RT1)          ณฑฑ
ฑฑณ           |        |           |Manter tratativas ctree neste fonte        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RSPM003()
	Local aSays				:= {}
	Local aButtons			:= {}
	Local lOk				:= .F.

	Private cPartLog		:= dtos(Date()) + "_" + StrTran(Time(),":","",1,3)
	Private aEstru			:= {}
	Private aCabec			:= {}
	Private aLstArqs		:= {}
	Private oArqTRBTmp		:= Nil
	Private lLogDados		:= .T.
	Private cSystemPasta	:= ''
	Private aArquivos		:= {}
	Private aTitle			:= {}
	Private aLog			:= {}

	Private aSize			:= {}
	Private aInfo			:= {}
	Private aObj			:= {}
	Private aPObj			:= {}
	Private aPGet			:= {} // Retorna a area util das janelas Protheus 

	aSize := MsAdvSize() // Sera utilizado tres areas na janela 
			// 1ช - Enchoice, sendo 80 pontos pixel 
			// 2ช - MsGetDados, o que sobrar em pontos pixel e para este objeto 
			// 3ช - Rodape que e a propria janela, sendo 15 pontos pixel 
	AADD( aObj, { 100, 100, .T., .T. }) 
		
	// Cแlculo automแtico da dimens๕es dos objetos (altura/largura) em pixel 
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 
	aPObj := MsObjSize( aInfo, aObj ) 

	// Cแlculo automแtico de dimens๕es dos objetos MSGET 
	aPGet := MsObjGetPos( (aSize[3] - aSize[1]), 315, { {004, 024, 240, 270} } )         

	AAdd(aSays, OemtoAnsi(STR0077))//'Devido a otimiza็ใo das rotinas de Pesquisas de Candidatos, foram criadas novas ') //STR0077
	AAdd(aSays, OemtoAnsi(STR0078))//'tabelas no sistema (RT0 e RT1). Esta rotina efetua a carga destas tabelas com as ')//STR0078
	AAdd(aSays, OemtoAnsi(STR0079))//'informa็๕es que se encontram armazenadas em arquivos (extensใo PES\CSV).')//STR0079
	AAdd(aSays, OemtoAnsi(STR0082))//'informa็๕es que se encontram armazenadas em arquivos (extensใo PES\CSV).')//STR0079

	AAdd(aButtons,{01, .T., {|o| lOk := .T., FechaBatch()}})
	AAdd(aButtons,{02, .T., {|o| lOk := .F., FechaBatch()}})

	FormBatch(OemtoAnsi(STR0080), aSays, aButtons)    

	If lOk
		cSystemPasta := cGetFile( STR0070 ,OemToAnsi(STR0071),0,,.T.,GETF_ONLYSERVER+GETF_LOCALFLOPPY+GETF_RETDIRECTORY)
		If Empty(cSystemPasta)
			//MsgInfo("Processo Abortado. Selecione um diret๓rio no qual se encontram os arquivos para importa็ใo.")
			MsgInfo(OemtoAnsi(STR0057))
		Else	
			aArquivos := directory (cSystemPasta + "*.*")
			FWMsgRun(,{|| VarreArqs(1)   },OemtoAnsi(STR0058),OemtoAnsi(STR0059))
			FWMsgRun(,{|| VarreArqs(2)   },OemtoAnsi(STR0075),OemtoAnsi(STR0059))
			
			If Len(aLog) > 0 
				Aadd(aTitle,OemToAnsi(STR0074))
				fMakeLog( { aLog } , aTitle , NIL , NIL , NIL , OemToAnsi(STR0073) ) //"Log dos arquivos verificados pela rotina"
			EndIf
		EndIf
	EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TelaSelecao บAutor  ณOswaldo L                   ณ  19/10/17    บฑฑ
ฑฑฬออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณDescri…o ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                                ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VarreArqs(nProc)
	Local   nInd   := 0
	
	If nProc == 1 
		For nInd := 1 to Len(aArquivos)
			DadosImporta(nInd)
		Next
	Else
		For nInd := 1 to Len(aArquivos)
			PesqImporta(nInd)
		Next
	EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TelaSelecao บAutor  ณOswaldo L                   ณ  19/10/17    บฑฑ
ฑฑฬออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณDescri…o ณ Importa Arquivos de dados, extensใo PES e CSV                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                                ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DadosImporta(nInd)
	Local cFile			:= Alltrim(Upper(aArquivos[nInd][1]))
	Local aOK			:= {}
	Local nPos			:= 0
	Local cArquivo		:= ""
	Local cRDD			:= __LocalDriver
	Private cExt		:= '' 
	Private cCsvFile	:= ''
	Private cTabAlias	:= GetNextAlias()

	aEstru		:= {}
	aCabec		:= {}
	oArqTRBTmp  := Nil
	
	If Select(cTabAlias) > 0
		DbSelectArea(cTabAlias)
		DbCloseArea()
	EndIf

	If !MsFile( cSystemPasta + cFile ,, cRDD )
		aadd(aLog,OemtoAnsi(STR0008)+ ": " + Alltrim(cFile)) //"Nao existe arquivo selecionado"
		Return 
	EndIf

	If  AT(".",cFile) # 0
		nPos := AT(".",cFile)-1
	Else
		nPos := Len(cFile)
	EndIf
		
	If Len(cFile) > 2
		cExt := substr( cFile, Len(cFile)-2,  Len(cFile))
	EndIf

	If Upper(cExt) != "CSV" .And. Upper(cExt) != "PES"
		
		If Upper(cExt) == "RSP"
			//ap๓s a rotina de importa็ใo de dados, executamos a importa็ใo das pesquisas. Ao identificar arquivos RSP, apenas ignorar sem exibir critica ..
			return
		EndIf
			
		aadd(aLog,OemtoAnsi(STR0060)  + Alltrim(cFile)) //"Nao existe arquivo selecionado"
		Return 
	EndIf

	If Upper(cExt) == "CSV"
		cCsvFile := cSystemPasta + cFile
	Else	
		dbUseArea(.T., cRDD, cSystemPasta + cFile,cTabAlias, .F., .F.) 
	EndIf

	If NETERR()
		//MsgInfo(OemtoAnsi(STR0009)) //"Arquivo esta sendo usado"
		Aadd  (aLog, OemtoAnsi(STR0009) + ": " + AllTrim(cFile) )
		
		return
	EndIf

	If Upper(cExt) != "CSV"
		dbselectarea(cTabAlias)
		aOk:=DBSTRUCT()

		If aOk[2][1] # "CURRIC" .And. aOK[3][1] # "NOME"
			Aadd  (aLog,OemtoAnsi(STR0010) + ": " + AllTrim(cFile) )
			If Select(cTabAlias) != 0
				dbSelectArea(cTabAlias)
				dbCloseArea()
			EndIf
			
			return
		EndIf
	EndIf

	A090Monta()

	dbSelectArea(cTabAlias)
	dbGotop()

	GeraRT1(cFile)

	If Select (cTabAlias) > 0
		(cTabAlias)->(DbCloseArea())
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TelaSelecao บAutor  ณOswaldo L                   ณ  19/10/17    บฑฑ
ฑฑฬออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณDescri…o ณ Importa arquivos de pesquisa *.RSP                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                                ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PesqImporta(nInd)
	Local cFile		:= Alltrim(Upper(aArquivos[nInd][1]))
	Local cCodPesq	:=  Upper(cFile)
	Local nPos
	Local cExt
	lLogDados		:= .F.

	If !File(cSystemPasta + cFile)
		aadd(aLog,OemtoAnsi(STR0008)+ ": " + Alltrim(cFile)) //"Nao existe arquivo selecionado"
		Return 
	EndIf	

	If  AT(".",cFile) # 0
		nPos := AT(".",cFile)-1
	Else
		nPos := Len(cFile)
	EndIf
		
	If Len(cFile) > 2
		cExt := substr( cFile, Len(cFile)-2,  Len(cFile))
	EndIf

	If Upper(cExt) != "CSV" .And. Upper(cExt) != "PES"
		
		If Upper(cExt) == "RSP"
			//formato dos arquivo de pesquisa e padrใo PESQ999.RSP
			cCodPesq := strtran(cCodPesq,"PESQ","",1,1)
			cCodPesq := strtran(cCodPesq,".RSP","",1,1)
		
			GeraRT0(cSystemPasta +cFile, cCodPesq)
			return
		Else
			aadd(aLog,OemtoAnsi(STR0069)  + Alltrim(cFile)) //"Nao existe arquivo selecionado"
		EndIf
		
		Return
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraRT0 บAutor  ณOswaldo L                   ณ  19/10/17    บฑฑ
ฑฑฬออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณDescri…o ณ Varre temporแrio e alimenta tabela nova - Ctree                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                                ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function GeraRT0(cArquivo, cPerg)
	Local nHandle  := FT_FUse(cArquivo) 
	Local cString  := ''
	Local nTam     := 0 
	Local cFlag    := ''
	Local nContador:= 0 

	dbSelectArea('RT0')
	RT0->(DbSetOrder(1))
	RT0->(DbSeek( Fwxfilial('RT0') + "RSPA090   " + cPerg    ))
		
	If RT0->(!Eof())
		Aadd  (aLog,OemtoAnsi(STR0061) + AllTrim(cArquivo) )
		return
	EndIf

	If nHandle > 0	
		FT_FGoTop()
		
		While !( FT_FEof() )
			
			cString  := FT_FReadLn()	
					
			If Empty(cString)
				FT_FSkip()
				loop
			EndIf

			nTam     := Len(cString)
			cFlag    := substr(cString,nTam,1)
			
			If substr(cString,1,1) == "*"
			
				cString := strtran(cString,  "*","",1,2)
				
				nTam    := Len (cString)
				cString := substr (cString,1,nTam-1)//desconsidera flag
							
				SX3->(DbSetOrder(2))
				If SX3->( dbSeek( Alltrim(cString) ) )
				
					nContador += 1
					
					reclock('RT0',.T.)
					RT0->RT0_FILIAL := Fwxfilial('RT0')
					RT0->RT0_TELA   := "RSPA090   "
					RT0->RT0_PERG   := cPerg
					RT0->RT0_SEQ    := nContador
					RT0->RT0_CAMPO  := Alltrim(cString)
					RT0->RT0_TIPO   := cFlag
					RT0->RT0_TPCMP  := SX3->X3_TIPO
					MsUnLock()
					
				EndIf
				
			Else
				If RT0->(!Eof())
					MSMM(RT0_CODM  ,,,cString,1,,,"RT0","RT0_CODM")
				EndIf
			EndIf
				
			FT_FSkip()
			
		EndDo
			
		fClose(nHandle)
		
		If nContador >= 1
			aadd(aLog,OemtoAnsi(STR0062)   + Alltrim(cArquivo))
		EndIf
	Else
		Aadd  (aLog,OemtoAnsi(STR0072) + AllTrim(cArquivo) )
	EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraRT1 บAutor  ณOswaldo L                   ณ  19/10/17    บฑฑ
ฑฑฬออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณDescri…o ณ Varre temporแrio e alimenta tabela nova - Ctree                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                                ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function GeraRT1(cPerg)
	Local nCnt			:= 0
	Private aStruct		:= {}
	Private nContador	:= 0
	Private cCabecalho	:= ""

	If (cTabAlias)->(!Eof())
		cPerg := padr(cPerg, TamSx3("RT1_PERG")[1] )
		
		dbSelectArea('RT1')
		RT1->(DbSetOrder(1))
		RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + cPerg ))
		
		If RT1->(!Eof())
			Aadd  (aLog,OemtoAnsi(STR0061) + AllTrim(cPerg) )
		Else	
			aStruct := (cTabAlias)->( dbStruct() )
			cCabecalho := ""
			nContador  := 0
			
			If Len(aStruct) > 0 
				For nCnt := 1 to Len(aStruct)
					cCabecalho += Alltrim(aStruct[nCnt][1]) + ";"
				Next
			
				while (cTabAlias)->(!Eof())
					GrvDadoTab(cPerg)
					(cTabAlias)->(DbSkip())
				End
				
				If nContador >= 1
					aadd(aLog,OemtoAnsi(STR0062)   + Alltrim(cPerg)) 
				EndIf
			EndIf
		EndIf
	EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLerCSV        บAutor  ณOswaldo L.   บ Data ณ 30/08/2017     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLer CSV escolhido. A gera็ใo de CSV passou a ser feita apos บฑฑ
ฑฑบ          ณProj.Soyuz com autoriza็ใo do frame                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function LerCSV ()
	Local   aLstRegs    := {} 
	Local   cSeparador  := ";"
	Local   nLinha      := 0
	Local   nCont       := 1
	Local   aCampos     := {}
	Local   cGrvCampo   := ''
	Private aCSVCabec   := {}

	FT_FUse( cCsvFile )//Abre o Arquivo
	FT_FGoTop()

	while !FT_FEof()
		nLinha += 1
		
		If nLinha == 1//cabe็alho
			aCSVCabec :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )
			CriaTempDoCSV()//cria temporario
		Else
			If oArqTRBTmp <> Nil //insere dados do CSV no temporแrio
				aLstRegs :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )
				
				If Len(aLstRegs) > 0 
				
					dbselectarea(cTabAlias)
				
					Reclock(cTabAlias,.T.)
					For nCont := 1 to Len(aEstru)
						cGrvCampo     := "(cTabAlias)->("  + AllTrim(aEstru[nCont][1]) + ")"
						
						If aEstru[nCont][2] $ "L"
							If aLstRegs[nCont] == "0"
								&cGrvCampo    := .F.
							Else
								&cGrvCampo    := .T.
							EndIf
						End
						
						If aEstru[nCont][2] $ "D"
							&cGrvCampo    := ctod(aLstRegs[nCont])
						EndIf
						
						If !(aEstru[nCont][2] $ "L|D")
						
							If (aEstru[nCont][2]) == "N"
								nCont := nCont
								&cGrvCampo    := Val(aLstRegs[nCont])
							Else
								&cGrvCampo    := aLstRegs[nCont]
							EndIf
							
						EndIf
					Next
					MsUnLock()
				EndIf
			EndIf
		EndIf
		
		FT_FSkip()
	End

	FT_FUse()

return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A090Montaณ Autor ณ Cristina Ogura        ณ Data ณ 03.02.98 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Monta o arquivo de trabalho e o cabecalho do listbox       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ nSelec := opcao selecionada                                ณฑฑ
ฑฑณ          ณ           1- Nova pesquisa                                 ณฑฑ
ฑฑณ          ณ           2- Consulta pesquisa                             ณฑฑ
ฑฑณ          ณ aCampos := Campos a serem gravados                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ RSPM003                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function A090Monta()
	Local i	:= 0

	If Upper(cExt) != "CSV" 
		aEstru	:= {}
		aCabec	:= {}
			
		dbSelectArea(cTabAlias)
		aEstru:= DBSTRUCT()
		
		For i:=1 To Len(aEstru)
			If aEstru[i][1] $ "CURRIC/NOME/FONE/VAGA"
					Aadd(aCabec,aEstru[i][1])
			Else
					If "RS6_" $ aEstru[i][1]
						DbSelectArea("RS6")
						DbSeek(xFilial("RS6")+SubStr(aEstru[i][i],5))
						aAdd(aCabec,AllTrim(RS6->RS6_DESC))
					Else
						dbSelectArea("SX3")
						dbSetOrder(2)
						dbSeek(aEstru[i][1])
						Aadd(aCabec,Alltrim(X3Titulo()))
					EndIf
			EndIf
		Next i
	Else
		LerCSV()
	EndIf

	dbSelectArea("SX3")
	dbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaTempDoCSV บAutor  ณOswaldo L.   บ Data ณ 30/08/2017     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria temporaria com base no CSV lido                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function CriaTempDoCSV()
	Local i				:= 0
	Local cCampo		:= ""
	Local aCampos		:= {}
	Local aLstIndices	:= {}

	For i := 1 to Len(aCSVCabec)

		dbSelectArea("SX3")
		dbSetOrder(2)
		If !(aCSVCabec[i] $ "SEL|CURRIC|NOME|FONE|VAGA") ; //arquivos da rspa090 tem estes campos sempre fixos no inicio  
			.And. dbSeek(aCSVCabec[i]) 
			Aadd(aCampos,{	aCSVCabec[i],;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_TIPO})
		EndIf
	Next i

	If Len(aCSVCabec) > 0
		// Campos fixos do Arquivo
		aEstru:={}
		Aadd(aEstru, { "SEL"	,"L",01, 0 } )
		Aadd(aEstru, { "CURRIC" ,"C",06, 0 } )
		Aadd(aEstru, { "NOME" 	,"C",40, 0 } )
		Aadd(aEstru, { "FONE"	,"C",40, 0 } )
		Aadd(aEstru, { "VAGA"	,"C",06, 0 } )

		aCabec:={}
		Aadd(aCabec,"")
		Aadd(aCabec,UPPER(STR0026))	//"CURRIC"
		Aadd(aCabec,UPPER(STR0028))	//"NOME"
		Aadd(aCabec,UPPER(STR0027))	//"FONE"
		Aadd(aCabec,UPPER(STR0039))	//"VAGA"
		
		// Campos diferentes de Memo
		For i:=1 To Len(aCampos) 
			If aCampos[i][4] != "M"	.and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
				cCampo := AllTrim(aCampos[i][1])
				If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
					Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
					Aadd(aCabec,aCampos[i][1])
				EndIf
			EndIf
		Next i
		
		// Campos Memos
		For i:=1 To Len(aCampos)
			If aCampos[i][4] == "M" .and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
				cCampo := AllTrim(aCampos[i][1])
				If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
					Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
					Aadd(aCabec,aCampos[i][1])
				EndIf
			EndIf	
		Next i	
		
		aLstIndices := {}

		AAdd( aLstIndices, {"CURRIC"})
		AAdd( aLstIndices, {"NOME"})
		oArqTRBTmp := RhCriaTrab(cTabAlias, aEstru, aLstIndices)
		(cTabAlias)->(DbSetOrder(1))
	EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GrvDadoTab  บAutor  ณOswaldo L                   ณ  19/10/17    บฑฑ
ฑฑฬออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณDescri…o ณ Grava informa็๕es na tabela generica                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ RSPM003                                                         ณฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvDadoTab(cPerg)
	Local cLinhaReg	:= ''
	Local nLoop		:= 0
	Local cDe		:= ''

	If Len(aStruct) > 0
		nContador += 1
		
		If nContador == 1
			reclock('RT1',.T.)
			RT1->RT1_FILIAL := Fwxfilial('RT1')
			RT1->RT1_TELA   := "RSPA090   "
			RT1->RT1_PERG   := cPerg
			RT1->RT1_SEQ    := nContador
			RT1->RT1_HEAD   := 'S'
			MsUnLock()
			
			MSMM(RT1_CODM  ,,,cCabecalho,1,,,"RT1","RT1_CODM")		
			nContador += 1
		EndIf
		
		cLinhaReg := ''
		
		For nLoop := 1 to Len(aStruct)
			cDe     := "(cTabAlias)->("      + AllTrim(aStruct[nLoop][1]) + ")"
			
			Do Case
				Case aStruct[nLoop][2] == "C"
					
					cLinhaReg += Iif ( Empty(AllTrim(&cDe)), " ", AllTrim(&cDe) ) 
					
				Case aStruct[nLoop][2] == "M"
					
					cLinhaReg += Iif ( Empty(AllTrim(&cDe)), " ", AllTrim(&cDe) ) 
				
				Case aStruct[nLoop][2] == "L"
					
					If (&cDe) == .F.
						cLinhaReg += "0"
					Else
						cLinhaReg += "1"
					EndIf
				
				Case aStruct[nLoop][2] == "N"
					
					cLinhaReg +=  Iif ( Empty(AllTrim(STR(&cDe))), " ", AllTrim(STR(&cDe)) ) 
				
				Case aStruct[nLoop][2] == "D"
					
					cLinhaReg += dtoc(&cDe)
			EndCase
			
			cLinhaReg += ";" 
		Next
		
		reclock('RT1',.T.)
		RT1->RT1_FILIAL := Fwxfilial('RT1')
		RT1->RT1_TELA   := "RSPA090"
		RT1->RT1_PERG   := cPerg
		RT1->RT1_SEQ    := nContador
		RT1->RT1_HEAD   := 'N'
		MsUnLock()
		
		MSMM(RT1_CODM  ,,,cLinhaReg,1,,,"RT1","RT1_CODM")
	EndIf

return
