#INCLUDE "plsa973.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

// Define
#DEFINE PLSMONEY "@E 99,999,999,999.99"

#DEFINE __aCdCri198 {"09Q","Habilita checagem DE/PARA TUSS!"}

// Define de pastas
STATIC TISVERS 	   	:= GetNewPar("MV_TISSVER","3.03.01")
STATIC cSemaforo   	:= "PLSXML973.SMF"
STATIC cFileTmp	   	:= "XMLTMP"
STATIC cDirRaiz	   	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\") )
STATIC cDirTemp	   	:= PLSMUDSIS( cDirRaiz+"TEMP\" )
STATIC cDirCaiEn   	:= PLSMUDSIS( cDirRaiz+"CAIXAENTRADA\" )
STATIC cDirCEBkp   	:= cDirCaiEn
STATIC cDirCaiSa   	:= PLSMUDSIS( cDirRaiz+"CAIXASAIDA\" )
STATIC cDirProce   	:= PLSMUDSIS( cDirRaiz+"PROCESSADOS\" )
STATIC cDirNaPro   	:= PLSMUDSIS( cDirRaiz+"NAOPROCESSADOS\" )
STATIC cDirSchema  	:= PLSMUDSIS( cDirRaiz+"SCHEMAS\" )
STATIC cDirLog	   	:= PLSMUDSIS( cDirRaiz+"LOG\" )
STATIC cDirUpload  	:= PLSMUDSIS( cDirRaiz+"UPLOAD\")
STATIC cDirDownld  	:= PLSMUDSIS( cDirRaiz+"DOWNLOAD\")
STATIC lOnline 	   	:= .F.
STATIC cDirOnl	   	:= "ONLINE\"

// Variaveis Static
STATIC lLog 	  	:= Iif(GetNewPar("MV_LOGSCHE","1")=="1",.T.,.F.)
STATIC cPerg	  	:= "PLS973" + Space(4)
STATIC lOkXml	  	:= .T.
STATIC lProcLog	  	:= .T.
STATIC aMatShema  	:= {}
STATIC cValHash   	:= ""
STATIC aMatCab	  	:= {}
STATIC aMatPre	  	:= {}
STATIC aMatOpe	  	:= {}
STATIC aMatEpi	  	:= {}
STATIC aResultado 	:= {}
STATIC aMatBWT	  	:= {}
STATIC aUnMed	  	:= {}
STATIC cPrefANS   	:= Iif(TISVERS < "2.02.02" .OR. TISVERS >= "3" ,"ans:","ansTISS:")
STATIC lVerTISS   	:= Iif( AllTrim(TISVERS) >= "2.02.02" .AND. AllTrim(TISVERS) < "3",.T.,.F. )
STATIC __aTpPart  	:= PlRConTPA()
STATIC aPathTag   	:= {}
STATIC lLogTissOn 	:= Iif(GetNewPar("MV_PTLOGTO","0")=="1",.T.,.F.) .And. IsInCallStack("PROCONLINE")
STATIC lNoGerFil  	:= .F.	
STATIC lPlsXmlMat := ExistBlock("PLSXMLMAT")

/*/{Protheus.doc} PLSA973
Importação de arquivos XML
#tissver 2.x,3.x

@type Function
@author Alexander Santos
@since 17/05/2007
@version 1.0.
/*/
Function PLSA973()
	LOCAL aArea		:= GetArea()
	LOCAL nI		:= 0
	LOCAL aSays     := {}
	LOCAL aButtons  := {}
	LOCAL cCadastro := STR0001    //"Importação de Guias no Padrão TISS"
	LOCAL aMatDir   := {cDirRaiz,cDirTemp,cDirCaiEn,cDirCaiSa,cDirProce,cDirNaPro,cDirSchema,cDirLog }
	PRIVATE lSxbBXX	:= .T.

// Retorna ao diretorio original
	cDirCaiEn := cDirCEBkp

// Verifica se as pastas base estao criadas e cria
	For nI:=1 To  Len(aMatDir)
		If !ExistDir(aMatDir[nI])
			If MakeDir( aMatDir[nI] ) <> 0
				MsgAlert(STR0002+aMatDir[nI]+STR0003)//"Impossível criar diretorio ( "###" ) "
				Return
			EndIf
		EndIf
	Next

// Says
	AADD(aSays,STR0004) //"Esta opção permite a importação de guias no Padrão TISS."
	AADD(aSays,"")
	AADD(aSays,STR0005) //"Clique no botão OK para iniciar o processamento"

// Exibe janela de processamento
	If GetRpoRelease()=="R1.1"
		tNewProcess():New("PLSA973","Importação TISS",{|oSelf|ProcTiss(cDirCaiEn,oSelf)},cCadastro,"",,.F.,,,.T.,.T. )
	Else

	// Monta botoes para janela de processamento
		AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
		AADD(aButtons, { 1,.T.,{|| Processa( {|| Pergunte(cPerg,.F. ),PLSA973PRO(cDirCaiEn) }, STR0006,STR0006,.F. ) } } )//"Processando Importação"###"Processando Importação"
		AADD(aButtons, { 2,.T.,{|| FechaBatch() } } )

	// Exibe janela de processamento
		FormBatch( cCadastro, aSays, aButtons,,250 )
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} PLSA973PRO
Importacao de notas padrao TISS
#tissver 2.x

@type Function
@author Alexander Santos
@since 17/05/2007
@version 1.0
/*/
Function PLSA973PRO(cDirFiles,cDirOnline,lOnL,cSforo,cFTmp,lFileUniq,cTissVerOn)
	LOCAL cCodPeg 		:= MV_PAR01
	LOCAL cCodRda		:= AllTrim(MV_PAR04)
	LOCAL aRet			:= {}
	DEFAULT cDirOnline 	:= cDirOnl
	DEFAULT lOnL	  	:= lOnline
	DEFAULT cSforo      := cSemaforo
	DEFAULT cFTmp       := cFileTmp
	DEFAULT lFileUniq	:= .F.
	DEFAULT cTissVerOn := ""
	
	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Iniciando PLSA973PRO (PLSA973)", "tissonanalise.log")
	EndIf
	
	If lOnL
		cCodPeg := ""
		cCodRda := ""
	Endif

// Redefine o STATIC
	lOnline   := lOnL
	cSemaforo := cSforo
	cFileTmp  := cFTmp

// Se for on-line redefino as pastas
	If lOnL .And. At(cDirOnline,cDirProce)==0
		cDirOnl		:= cDirOnline
		cDirCaiEn	:= StrTran(cDirCaiEn,cDirRaiz,cDirRaiz+cDirOnl)
		cDirCaiSa	:= StrTran(cDirCaiSa,cDirRaiz,cDirRaiz+cDirOnl)
		cDirProce	:= StrTran(cDirProce,cDirRaiz,cDirRaiz+cDirOnl)
		cDirNaPro  	:= StrTran(cDirNaPro,cDirRaiz,cDirRaiz+cDirOnl)
		cDirLog		:= StrTran(cDirLog,cDirRaiz,cDirRaiz+cDirOnl)
	EndIf

// Se nao for online
	If !lOnline

		Processa( {|| ProcTiss(cDirFiles,,lFileUniq,cCodRda) }, STR0007,STR0008,.F. )//"Processando"###"Aguarde..."
	Else
		cFileXML := cDirFiles
		cFileDel  := SubStr(SubStr(cFileXml,Rat(PLSMUDSIS("\"),cFileXml)+1,Len(cFileXml)),Rat("_",cFileXml)-Rat(PLSMUDSIS("\"),cFileXml),1)
		aRet := ProcTiss(cDirFiles,nil,lFileUniq,cCodRda,nil,nil,nil,cTissVerOn)
	EndIf
    
	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Finalizando PLSA973PRO (PLSA973)", "tissonanalise.log")
	EndIf
Return aRet

/*/{Protheus.doc} ProcTiss
Processa a importacao de guias Padrao TISS
#tissver 2.x,3.x

@type Function
@author Alexander Santos
@since 17/03/2007
@version 1.0
/*/
Function ProcTiss(cDirFiles,oSelf,lFileUniq,cRdaPath,l974,oProcess,cCodPeg,cTissVerBXX,lBg,cXMLString)
	LOCAL nFor,nI,nY
	LOCAL nQtdFiles   := 0
	LOCAL cFileTISS   := ""
	LOCAL cFileHas	  := ""
	LOCAL cArqRet	  := ""
	LOCAL cMsg		  := ""
	LOCAL cDatHor	  := ""
	LOCAL cMsgCri	  := ""
	LOCAL nIniSeg	  := Seconds()
	LOCAL aFiles      := {}
	LOCAL aResGeral   := {}
	LOCAL cOldRaiz    := cDirRaiz
	LOCAL cTipoGlosa  := ""
	PRIVATE l974Xml	  := .f.
	DEFAULT lFileUniq := .F.
	DEFAULT oSelf	  := nil
	DEFAULT l974	  := .f.
	DEFAULT oProcess  := nil
	DEFAULT cCodPeg	  := ""
	DEFAULT cTissVerBXX := ""
	DEFAULT lBg			:= .F. //Define se a rotina é utilizada em background. Se for, néo podemos exibir nenhuma forma de interacao com usuario, como alertas, barras, etc
	Default cXMLString := ""

	//Declarando variaveis que estavam sem declaração no codigo
	PRIVATE cArLgOri := ""
	PRIVATE cArLgDes := ""
	
	If lLogTissOn 
		PlsPtuLog(PLSRetTime() + " - Iniciando ProcTiss (PLSA973)", "tissonanalise.log")
	EndIf
	
	If !Empty(cTissVerBXX)
		TISVERS := cTissVerBXX // atualizo a versao da TISS para o arquivo, usado a partir da TISS 3 q desconsidera o parametro MV_TISVER
	EndIf

	l974Xml := l974
	if l974Xml
		lOkXml 	:= .T.
	endIf

// Retorna ao diretorio original
	If !lOnline
		cDirCaiEn := cDirCEBkp
	Endif

// Diretorio informado pelo usuario
	if !l974Xml
		If !Empty(MV_PAR03) .or. lOnline
			If !lOnline
				cDirRaiz   := PLSMUDSIS(AllTrim(MV_PAR03) + Iif(Right(MV_PAR03,1) != PLSMUDSIS('\'),'\',''))
			Endif
			cDirTemp   := PLSMUDSIS(StrTran(cDirTemp,cOldRaiz,cDirRaiz))
			cDirCaiEn  := PLSMUDSIS(StrTran(cDirCaiEn,cOldRaiz,cDirRaiz) + If(!Empty(cRdaPath),cRdaPath + "\" ,""))
			cDirFiles  := PLSMUDSIS(StrTran(cDirFiles,cOldRaiz,cDirRaiz) + If(!Empty(cRdaPath),cRdaPath + "\" ,""))
			cDirCaiSa  := PLSMUDSIS(StrTran(cDirCaiSa,cOldRaiz,cDirRaiz))
			cDirProce  := PLSMUDSIS(StrTran(cDirProce,cOldRaiz,cDirRaiz))
			cDirNaPro  := PLSMUDSIS(StrTran(cDirNaPro,cOldRaiz,cDirRaiz))
			cDirSchema := PLSMUDSIS(StrTran(cDirSchema,cOldRaiz,cDirRaiz))
			cDirLog    := PLSMUDSIS(StrTran(cDirLog,cOldRaiz,cDirRaiz))
			aMatDir    := {cDirRaiz,cDirTemp,cDirCaiEn,cDirCaiSa,cDirProce,cDirNaPro,cDirSchema,cDirLog}

		// Verifica se as pastas base estao criadas e cria
			For	nI:=1 To  Len(aMatDir)
			If !ExistDir(aMatDir[nI])
				If MakeDir( aMatDir[nI] ) <> 0
					If !lOnline .AND. !lBg
						MsgAlert(STR0002+aMatDir[nI]+STR0003)//"Impossível criar diretorio ( "###" ) "
						Return
					Else
						Return {STR0002+aMatDir[nI]+STR0003}
					Endif
				EndIf
			EndIf
		Next

	ElseIf !Empty(cRdaPath)

		cDirCaiEn := PLSMUDSIS(cDirCaiEn + cRdaPath + "\")
		cDirFiles := PLSMUDSIS(cDirFiles + cRdaPath + "\")
	EndIf
else
	cDirTemp   := PLSMUDSIS(StrTran(cDirTemp,cOldRaiz,cDirRaiz))
	cDirCaiEn  := PLSMUDSIS(StrTran(cDirCaiEn,cOldRaiz,cDirRaiz) + cRdaPath + "\")
	cFileTISS  := PLSMUDSIS(cDirFiles)
	cDirCaiSa  := PLSMUDSIS(StrTran(cDirCaiSa,cOldRaiz,cDirRaiz))
	cDirProce  := PLSMUDSIS(StrTran(cDirProce,cOldRaiz,cDirRaiz))
	cDirNaPro  := PLSMUDSIS(StrTran(cDirNaPro,cOldRaiz,cDirRaiz))
	cDirSchema := PLSMUDSIS(StrTran(cDirSchema,cOldRaiz,cDirRaiz))
	cDirLog    := PLSMUDSIS(StrTran(cDirLog,cOldRaiz,cDirRaiz))
endIf

_cTISTRAN:= "tissV"+StrTran(TISVERS,".","_")+".XSD"
_cTISGUIA:= "tissGuiasV"+StrTran(TISVERS,".","_")+".XSD"
_cTISCOMP:= "tissComplexTypesV"+StrTran(TISVERS,".","_")+".XSD"
_cTISSIMP:= "tissSimpleTypesV"+StrTran(TISVERS,".","_")+".XSD"


// Verifica se os arquivos de Shema existem
if !l974Xml
	If !File(cDirSchema+_cTISTRAN)
		cMsg += _cTISTRAN+","
	EndIf
	If !File(cDirSchema+_cTISGUIA)
		cMsg += _cTISGUIA+","
	EndIf
	If !File(cDirSchema+_cTISCOMP)
		cMsg += _cTISCOMP+","
	EndIf
	If !File(cDirSchema+_cTISSIMP)
		cMsg += _cTISSIMP+","
	EndIf
	If !Empty(cMsg)
		If !lOnline .AND. !lBg
			MsgAlert(STR0009+SubStr(cMsg,1,( Len(cMsg)-1 ) )+STR0010)//"Arquivo(s) de Schemas não encontrado(s) ( "###" )"
			Return
		Else
			Return {STR0009+SubStr(cMsg,1,( Len(cMsg)-1 ) )+STR0010}//"Arquivo(s) de Schemas não encontrado(s) ( "###" )"
		EndIf
	EndIf
ENDIF


// Aquivos xml	da caixa de entrada
if !l974Xml
	If !lFileUniq
		aFiles := Directory( cDirFiles+STR0011 )  //"*.XML"
	Else
		aFiles := Directory( cDirFiles )
	EndIf
	nQtdFiles := Len(aFiles)

	// Verifica se o arquivo de log existe e renomeia
	If File(cDirLog+STR0012)  //"XMLLOG.TXT"
		cArLgOri := cDirLog+STR0012
		If !Empty(mv_par01)
			cArLgDes := AllTrim(cValToChar(cDirLog)+cValToChar(STR0013)+cValToChar(PlsIntPad())+cValToChar(MV_PAR01)+cValToChar(STR0015))
		Else
			cArLgDes := AllTrim(cValToChar(cDirLog)+cValToChar(STR0013)+cValToChar(DtoS(Date()))+StrTran(cValToChar(Time()),cValToChar(STR0014),"")+cValToChar(STR0015))
		EndIf
		If fREname(cArLgOri,cArLgDes) == -1//"XMLLOG.TXT"
			If !lOnline .AND. !lBg
				MsgAlert(STR0016)//"Impossível renomear arquivo de LOG ( XMLLOG.TXT )"
				Return
			EndIf
		EndIf
	EndIf

	// REGUA
	If !lOnline .AND. !lBg
		If GetRpoRelease()=="R1.1"
			oSelf:SetRegua1(nQtdFiles)
		Else
			ProcRegua(nQtdFiles)
		EndIf
	EndIf
else
	nQtdFiles := 1
endIf

// Carregando
If nQtdFiles > 0

	// Processando arquivos xml
	If Empty(cMsg)

		// Carrega Matriz
		If Len(aMatBWT) == 0
			BWT->( DbGoTop() )
			BWT->( DbSeek(Xfilial("BWT"))) 
			While !BWT->( Eof() ) .AND. xFilial("BWT") == BWT->BWT_FILIAL
				AaDd(aMatBWT,{ BWT->BWT_CODOPE,BWT->BWT_CODPAR,BWT->BWT_CODEDI } )
				BWT->( DbSkip()	)
			EndDo

			// Carrega Matriz
			aUnMed := PLSXBKC()
		EndIf
		if !l974Xml

			// Processamento dos arquivo
			For nFor := 1 To Len(aFiles)

				// Segue no processamento do arquivo
				lOkXml := .T.

				// Nome do arquivo
				cFileTISS := Lower( AllTrim(aFiles[nFor,1]) )

				// Log do arquivo
				PLSLOGX(STR0022+DtoC( Date() )+STR0023+Time()+STR0003+" - ["+Iif(!ISSRVUNIX(),"SO Windows","SO Linux")+"]",,.F.)//"Inicio do Processamento ( "###" - "###" ) "
				PLSLOGX("",,.F.)
				PLSLOGX("",,.F.)
				PLSLOGX(STR0024+cFileTISS+STR0003,,.F.) //"Arquivo ("###" ) "
				PLSLOGX("",,.F.)

				// Verifica se a sequencia foi informada
				cFileSeq := SubStr(SubStr(cFileXml,Rat(PLSMUDSIS("\"),cFileXml)+1,Len(cFileXml)),1,Rat("_",cFileXml)-Rat(PLSMUDSIS("\"),cFileXml)-1)
				If !lOnline // no online isso nao eh necessario pois quem monta o arquivo sou eu
					If Val(cFileSeq) == 0 .or. Len(cFileSeq) > 20 .or. Len(cFileSeq) <= 0
						PLSLOGX("Numero sequencial no nome do arquivo invalido ( "+cFileTISS+" ) ",.F.)
						cMsg := "Numero sequencial no nome do arquivo invalido ( "+cFileTISS+" ) "
					EndIf
				Endif

				// Verifica delimitador
				cFileHas  := AllTrim( SubStr(SubStr(cFileXml,Rat(PLSMUDSIS("\"),cFileXml)+1,Len(cFileXml)),Rat("_",cFileXml)-Rat(PLSMUDSIS("\"),cFileXml)+1,Rat(".",cFileXml)-Rat("_",cFileXml)-1) )

				If !lOnline// no online isso nao eh necessario pois quem monta o arquivo sou eu
					If cFileDel <> "_"
						PLSLOGX(STR0026+cFileTISS+STR0003,.F.)//"Delimitador não encontrado no nome do arquivo ( "###" ) "
						cMsg := STR0026+cFileTISS+STR0003
					EndIf
				Endif


				// Vefica hash contido no arquivo
				cFileHas  := AllTrim( SubStr(SubStr(cFileXml,Rat(PLSMUDSIS("\"),cFileXml)+1,Len(cFileXml)),Rat("_",cFileXml)-Rat(PLSMUDSIS("\"),cFileXml)+1,Rat(".",cFileXml)-Rat("_",cFileXml)-1) )
				If Len(cFileHas) <> 32
					PLSLOGX(STR0027+cFileTISS+" ) ",.F.)// " ) " "Tamanho do hash no nome do arquivo invalido ( "
				EndIf

				// Processamento
				If lOkXml
					cDatHor := AllTrim(DtoS(aFiles[nFor,3]))+AllTrim(StrTran(aFiles[nFor,4],":",""))
					If !lOnline .AND. !lBg
						If GetRpoRelease()=="R1.1"
							oSelf:incRegua1(STR0028+cFileSeq+STR0029+AllTrim(Str((nFor*100)/nQtdFiles,3))+STR0030)//"Arquivo "###"...  "###"% concluído"
						Else
							IncProc(STR0028+cFileSeq+STR0029+AllTrim(Str((nFor*100)/nQtdFiles,3))+STR0030)//"Arquivo "###"...  "###"% concluído"
							ProcessMessage()
						Endif
					EndIf
					if !lBg
						aArqRet := ProcFile(cFileTISS,cDatHor,cFileHas)
					Else
						aArqRet := ProcFile(cFileTISS,cDatHor,cFileHas,oProcess,cCodPeg,l974,lBg)
					EndIf
					If ValType(aArqRet)=="A"
				    	If aArqRet[1] == nil
					    	lOkXML 	:= .F.
					    	cArqRet	:= nil
					    	cMsg		:= aArqRet[2]
							if len(aArqRet) >= 5
								cTipoGlosa := aArqRet[5]
							endif
					    Else	
					    	cArqRet	:= aArqRet[1]
					    	cMsg		:= ""
					    Endif
					Endif					    
				Else
					If Empty(cMsg)
						cMsg := STR0031 //"Nenhum arquivo XML encontrado para processamento"
					Endif
					PLSGRVARQ(cFileTISS,cCodPeg)
				EndIf

				// Log de Termino
				PLSLOGX("",,.F.)
				PLSLOGX(STR0032+Time()+STR0033+AllTrim( Str( (Seconds()-nIniSeg)/60,12,3) )+" )",,.F.) //"Fim do Processamento ( "###" ) Duração ( "
				PLSLOGX("",,.F.)

				// Verifica retorno
				For nY:=1 To Len(aResultado)
					AaDd(aResGeral,aResultado[nY])
				Next
				aResultado := {}
			Next
		else
			aArqRet := ProcFile(cFileTISS,cDatHor,cFileHas,oProcess,cCodPeg,l974,lBg,,cXMLString)
			If ValType(aArqRet)=="A"
		    	If aArqRet[1] == nil
			    	lOkXML 	:= .F.
			    	cArqRet	:= nil
			    	cMsg		:= aArqRet[2]
			    Else	
			    	cArqRet	:= aArqRet[1]
			    	cMsg		:= .F.
			    Endif
			Else
				// Ouve algum erro no processamentos
				// Tais como exclusao do arquivo na pasta
				// e não posso atualizar o status de acatado para processado
				cMsg		:= .T.
			Endif				
		endIf
	Else
		If !lOnline .AND. !lBg
			MsgAlert(cMsg)
			Return
		Else
			Return {cMsg}
		EndIf
	EndIf

	if !l974Xml

		//Resultado
		If nQtdFiles == 0 .And. !lOnline .AND. !lBg
			PutHelp("PPLSA973FIL",{STR0034,STR0035},{},{},.f.)//"Não foi encontrado arquivos no    "###"diretório informado."
			PutHelp("SPLSA973FIL",{STR0036,STR0037},{},{},.f.)//"Confira o diretório    "###"informado."
			Help("",1,"PLSA973FIL")
		Else

			// LOG em arquivo
			If lLog
				For nI:=1 To Len(aResGeral)
					PLSLOGFIL( aResGeral[nI,1],cDirLog+STR0012 )  //"XMLLOG.TXT"

					If lOnline
						If aResGeral[nI,2] == 4
							cMsg += AllTrim(aResGeral[nI,1])+", "
						EndIf

						If aResGeral[nI,4]
							If 'NUM. GUIA PRESTADOR' $ AllTrim(aResGeral[nI,1])
								cMsgCri += Chr(13) + AllTrim(StrTran(aResGeral[nI,1],"Tiss    -","") ) + Chr(13) + Chr(13)
							Else
								cMsgCri += AllTrim(StrTran(aResGeral[nI,1],"Tiss    -","") ) + Chr(13)
							EndIf
						EndIf

						If !Empty(aResGeral[nI,5])
							cTipoGlosa := aResGeral[nI,5]
						EndIf
					EndIf
				Next
				cMsg := Left(cMsg,Len(cMsg)-2)
			EndIf

			//Marca como processado - RDA E ARQUIVO
			If lOkXml .And. !Empty(MV_PAR04)
				PLSXMLPRO(MV_PAR04,cFileTISS)//BXX_STATUS=3=Processado
			EndIf

			//Mostra as criticas
			If !lOnline .AND. !lBg
				PlsCriGen(aResGeral, { {STR0038,"@C",1000} } , STR0039,,,,,,,,,,,,,,,,,,,,TFont():New("Courier New",7,14,,.F.,,,,.F.,.F.))	     //"Status"###"  Resultado "
			EndIf
		Endif
	endIf
Else
	If !lOnline .AND. !lBg
		MsgAlert(STR0031)//"Nenhum arquivo XML encontrado para processamento"
	Else
		cMsg := STR0031  //"Nenhum arquivo XML encontrado para processamento"
	EndIf
EndIf
if !l974Xml
	If !lOnline .AND. !lBg
		If GetRpoRelease()=="R1.1" .and. lArqTiss
			oSelf:SaveLog("Processamento XML Realizado!")
		Endif
	EndIf
endIf
                    
If lLogTissOn
	PlsPtuLog(PLSRetTime() + " - Finalizando ProcTiss (PLSA973)", "tissonanalise.log")
EndIf

Return {cMsg,cArqRet,cMsgCri,lOkXML,cTipoGlosa}

/*/{Protheus.doc} ProcFile
Processa a importacao do XML
#tissver 2.x,3.x

@type Function
@author Alexander Santos
@since 17/03/2007
@version 1.0
/*/
static Function ProcFile(cFileTISS,cDatHor,cFileHas,oProcess,cCodPeg,l974,lBg,cSoapXML,cXMLString)
	LOCAL nI,nPos,nH,nPos2
	LOCAL oXml      := NIL
	LOCAL cArqRet   := ""
	LOCAL cNameSpace:= ""
	LOCAL cNameEleme:= ""
	LOCAL cErro  	:= ""
	LOCAL cAviso 	:= ""
	LOCAL cEncod 	:= ""
	LOCAL aRet		:= {}
	LOCAL aMatXCab	:= {}
	LOCAL aMatXPre	:= {}
	LOCAL aMatXEpi	:= {}
	LOCAL aMatAux	:= {}
	LOCAL I			:=0
	Local cDirBCon	:= ""
	Local cNomArC		:= ""
	Local lVldMatr	:= .T. //Validou matricula do usuario ?
	Local lVldLote	:= .T. //Validou lote de guia xml ?
	Local cMsgRet	:= ""
	Local lCancelGui := .F. //Indica se e uma solicitacao de cancelamento
	local aAreaBCI	:= BCI->(getArea())      
	local cNameArq	:= ""
	local cLogin    := ""
	local cSenha    := ""
	Local lstringOk	:= .F.

	DEFAULT cFileHas:= ""
	DEFAULT cDatHor := ""
	DEFAULT cCodPeg	:= ""
	DEFAULT l974	:= .F.
	DEFAULT lBg		:= .F.
	DEFAULT cSoapXML := ""
	Default cXMLString := ""

	lstringOk := !(empty(cXMLString))

	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Iniciando ProcFile (PLSA973)", "tissonanalise.log")
	EndIf	
	
	//Posiciono na BCI, para verificar o tipo de origem. Se for WSDL, preciso indicar outra cixa de entrada - ONLINE
	//Se transacao PTU Online, nao gerou o arquivo XML
	//Vai sempre passar por aqui agora que não vai mais ter arquivo
	if lNoGerFil .And. !Empty(cSoapXML)
		oXml := XmlParser(cSoapXML,"_",@cErro,@cAviso)
	elseif lstringOk
		oXml := XmlParser(cXMLString,"_",@cErro,@cAviso)
	else
	
		BCI->(dbsetorder(14))	
		If ( BCI->(dbseek(xFilial("BCI") + cCodPeg)) .and. BCI->BCI_ORIGEM == "2" ) // vem do TISS ONLINE 
			cDirCaiEn := PLSMUDSIS( cDirRaiz+"online\caixaentrada\" )	
			cNameArq 	:= alltrim(cFileTISS)
		else
			cFileSeq := SubStr(SubStr(cFileTISS,Rat(PLSMUDSIS("\"),cFileTISS)+1,Len(cFileTISS)),1,Rat("_",cFileTISS)-Rat(PLSMUDSIS("\"),cFileTISS)-1)
	   		cFileDel := SubStr(SubStr(cFileTISS,Rat(PLSMUDSIS("\"),cFileTISS)+1,Len(cFileTISS)),Rat("_",cFileTISS)-Rat(PLSMUDSIS("\"),cFileTISS),1)
			cFileHas := AllTrim( SubStr(SubStr(cFileTISS,Rat(PLSMUDSIS("\"),cFileTISS)+1,Len(cFileTISS)),Rat("_",cFileTISS)-Rat(PLSMUDSIS("\"),cFileTISS)+1,Rat(".",cFileTISS)-Rat("_",cFileTISS)-1) )
			cNameArq := alltrim(cFileTISS)
		endif
		//Algumas vezes o arquivo não é copiado corretamente para a caixa de entrada. Desta forma, iremos verificar se existe na pasta e se não copiar do banco de Conhecimento 
		//para a caixa de entrada
		If ( !File(cDirCaiEn +cNameArq) )
			cDirBCon := PLSMUDSIS(MsDocPath()+"\")  //pego diret? do Banco de Conhecimento
			cNomArC  := cNameArq
			
			//Verifico se a pasta do prestador existe na caixa de entrada. Se não crio novamente.
			if !ExistDir(cDirCaiEn)
				If MakeDir( cDirCaiEn ) <> 0
					if !lOnline .AND. !lBg
						msgstop(STR0137 + cNomArC + STR0150)  //"Não foi possível criar arquivo ( " -  " ) na Caixa de Entrada da pasta TISS. O processo será interrompido." 
					Else
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0137 + cNomArC + STR0150, 0, 0, {})//"Não foi possível criar arquivo ( " -  " ) na Caixa de Entrada da pasta TISS. O processo será interrompido."
					EndIf
					Return nil
				EndIf
			EndIf	
				
			//Insiro o arquivo na pasta			
			If ( File(cDirBCon + cNomArC ) )
				__CopyFile( cDirBCon+cNomArC , cDirCaiEn+cNomArC )
			Elseif !lOnline .AND. !lBg
				msgstop(STR0024 + cNomArC + STR0149 )  //"#Arquivo (" - ") não existe na Caixa de Entrada da pasta TISS e Banco de Conhecimento."  
				Return nil
			Else
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0024 + cNomArC + STR0149, 0, 0, {})//"#Arquivo (" - ") não existe na Caixa de Entrada da pasta TISS e Banco de Conhecimento."
				Return nil
			EndIf
		EndIf		
					
		oXml := XmlParserFile(cDirCaiEn+cNameArq,"_",@cErro,@cAviso) 
	endIf

	If !Empty(cErro)
		If !lOnline .AND. !lBg
			msgstop(cErro)
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cErro, 0, 0, {})
		Endif
		return nil
	Endif
	If !Empty(cAviso)
		If !lOnline .AND. !lBg
			msgstop(cAviso)
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cErro, 0, 0, {})
		Endif
		return nil
	Endif
	cEncod := SubStr(iif(lNoGerFil .And. !empty(cSoapXML),cSoapXML,MemoRead(cDirCaiEn+cFileTISS)),20,30)
	If ( nPos := At( 'utf',Lower(cEncod) ) ) > 0
		cEncod := Upper(SubStr(cEncod,nPos,5))
	ElseIf ( nPos := At( 'iso',Lower(cEncod) ) ) > 0
		cEncod := Upper(SubStr(cEncod,nPos,10))
	Else
		cEncod	:= "ISO-8859-1"
	EndIf

	aMatAux 	:= classDataArr(oXml)
	nPos 		:= ( At("_",SubStr( aMatAux[Len(aMatAux),1],2 ) )+1 )
	cNameSpace 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],1,nPos ) )
	cNameEleme 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],(nPos+1) ) )

// Estrutura bruta
	oObjXml := XmlChildEx(oXml,cNameSpace+cNameEleme)

// Verifica cabecalho
	If XmlNodeExist(oObjXml,cNameSpace+"CABECALHO")
		If ValType( &( "oObjXml:"+cNameSpace+"CABECALHO" ) ) == "O"
			aAux := PLSMONSTR( PLSAJMAT(cNameSpace, classDataArr( &( "oObjXml:"+cNameSpace+"CABECALHO" ) ) ) ,Len(cNameSpace) )
			AaDd( aMatXCab,"CABECALHO" )
			For nI:=1 To Len(aAux)
				AaDd(aMatXCab,aAux[nI])
			Next
		EndIf
	EndIf

// Verifica Mensagem
	If XmlNodeExist(oObjXml,cNameSpace+"PRESTADORPARAOPERADORA")
		If ValType( &( "oObjXml:"+cNameSpace+"PRESTADORPARAOPERADORA" ) ) == "O"
			aMatXPre := { "PRESTADORPARAOPERADORA",PLSMONSTR( PLSAJMAT(cNameSpace, classDataArr( &( "oObjXml:"+cNameSpace+"PRESTADORPARAOPERADORA" ) ) ) ,Len(cNameSpace) )[1] }
		EndIf
	EndIf

// Verifica Epilogo
	If XmlNodeExist(oObjXml,cNameSpace+"EPILOGO")
		If ValType( &( "oObjXml:"+cNameSpace+"EPILOGO" ) ) == "O"
			aMatXEpi := { "EPILOGO",PLSMONSTR( PLSAJMAT(cNameSpace, classDataArr( &( "oObjXml:"+cNameSpace+"EPILOGO" ) ) ) ,Len(cNameSpace) )[1] }
		EndIf
	EndIf

// Não tem erros na matriz static aresultado continua
	lSlvOk := lOkXml
	If lOkXml

		// Processamento
		lSlvOk := lOkXml
		If (TISVERS >= "3")

			// Monta um array do arquivo XML com as tags seus caminhos e valores
			aMatAux := PXMLTOARR(aMatAux)
		EndIf

		If aScan( aMatAux,{|x|Upper(x[1])=="DATASOLICITACAO"} )  > 0 .And. PVLRTAGXML(aMatAux, "TIPOTRANSACAO") $ "SOLICITACAO_PROCEDIMENTOS"
			If STOD(replace(aMatAux[aScan( aMatAux,{|x|Upper(x[1])=="DATASOLICITACAO"})][3],"-","")) < dDataBase
				Return ({nil,EncodeUtf8("Data Preenchida Incorretamente"),,,"1323"})
			EndIf
		EndIf

		If lOnline .AND. GetNewPar("MV_PLVLTOE",.F.)
		// Esse tratamento de se da para validação do arquivo de importação da Tiss-on-line
		// Para que o sistema verifique se ja foi importado o arquivo

			// Verifica se a RDA está cadastrada para dar sequência ou não na gravação da guia. Verifica CNPJ/CPF/Cód prestador 
			Do Case
				case aScan( aMatAux,{|x|Upper(x[1])=="CNPJ"} )  > 0
					BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
					nPosX := aScan( aMatAux,{|x|Upper(x[1])=="CNPJ"} )
					
				case aScan( aMatAux,{|x|Upper(x[1])=="CPF"} )  > 0
					BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
					nPosX := aScan( aMatAux,{|x|Upper(x[1])=="CPF"} )
						
				case aScan( aMatAux,{|x|Upper(x[1])=="CODIGOPRESTADORNAOPERADORA"} )  > 0
					BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
					nPosX := aScan( aMatAux,{|x|Upper(x[1])=="CODIGOPRESTADORNAOPERADORA"} )				
			endcase

			if nPosX == 0 .Or. !BAU->(MsSeek(xFilial("BAU")+ alltrim(aMatAux[nPosX,3	])))
				return ({nil,EncodeUtf8("Código do prestador inválido   "),,,"1203"})
			endif		

			if GetNewPar("MV_PLLGSN", .F.) .And. ;
			PVLRTAGXML(aMatAux, "TIPOTRANSACAO") $ "SOLICITACAO_PROCEDIMENTOS,SOLICITA_STATUS_AUTORIZACAO,CANCELA_GUIA,VERIFICA_ELEGIBILIDADE"
			
				cLogin := PVLRTAGXML(aMatAux, "LOGINSENHAPRESTADOR\LOGINPRESTADOR")
				cSenha := PVLRTAGXML(aMatAux, "LOGINSENHAPRESTADOR\SENHAPRESTADOR")
				
				if empty(cLogin) .Or. empty(cSenha)
					//Campos de login e senha nao informados na estrutura
					return ({nil,EncodeUtf8("PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM"),,,"3100"})
				else
					BSW->(dbSetOrder(1))
					If BSW->(MsSeek(xfilial("BSW") + Upper(cLogin) + Space( tamsx3("BSW_LOGUSR")[1] - Len(cLogin) ) ))
						If Alltrim(cSenha) <> Alltrim(BSW->BSW_SENHA)
							//Senha inválida
							return ({nil,EncodeUtf8("CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"),,,"3111"})
						endIF
					else
						//Login não existe -> login inválido
						return ({nil,EncodeUtf8("CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"),,,"3111"})
					endIf
				endIf
			endIf

			ccTexto:="" // Validando Hash
			For i:=1 to (len(aMatAux)-1)
				If at("nSeqGui",aMatAux[i,3])=0
					ccTexto+=Alltrim(aMatAux[i,3])
				Endif	
			Next
			ccTexto:=md5(ccTexto)
		
			If cFileHas <> ccTexto // Validando Hash
				return({nil,EncodeUtf8("Hash invalido   ")})	//"Hash inválido, Diferença entre informado e a validação do conteu?o"	
			Endif		

			If ( nPos1 := aScan( aMatAux,{|x|Upper(x[1])=="NUMEROGUIAPRESTADOR"} ) ) > 0
				aAreaBD5		:= BD5->(GetArea())
				aAreaBE4		:= BE4->(GetArea())
				aAreaBA1		:= BA1->(GetArea())

				cNumGuiaPrest	:= aMatAux[nPos1,3]
				nPos2 := aScan( aMatAux,{|x|Upper(x[1])=="NUMEROCARTEIRA"} )
				If nPos2 > 0
					cNumCarteira := PlMatValida(aMatAux[nPos2,3], "")
				Else
					cNumCarteira := ""
				EndIf

				// não podem haver os caracteres > e < nas mensagens do tiss Online, se tiver, ele vai bagunçar o retorno, pq vamos achar que uma tag começou/fechou indevidamente

				// se for transacao de cancelamento, nao valida a matricula
				lCancelGui := aScan( aMatAux,{|x|Upper(x[3])=="CANCELA_GUIA"} ) > 0 
				
				if !lCancelGui
					If !Empty(cNumCarteira)
					
						BA1->(dbSetOrder(2))//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
						If !BA1->(DbSeek(xFilial("BA1")+cNumCarteira))
							BA1->(dbSetOrder(5))//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
							If !BA1->(DbSeek(xFilial("BA1")+cNumCarteira))	
								lVldMatr   := .F.
							EndIf	       		
						Endif
					Else
						lVldMatr := .F.			
					EndIf
				Endif
				
				If !Empty(cNumGuiaPrest) .and. cNumGuiaPrest <> 'HAT'
					BD5->(dbSetOrder(6))//BD5_FILIAL + BD5_NUMIMP
					If BD5->(DbSeek(xFilial("BD5")+cNumGuiaPrest))
						lVldLote   := .F.
					Endif

					
					BE4->(dbSetOrder(6))//BE4_FILIAL + BE4_NUMIMP
					If BE4->(DbSeek(xFilial("BE4")+cNumGuiaPrest))
						lVldLote   := .F.
					Endif
					
					cAliasTrb :=GetNextAlias()
					BeginSql Alias cAliasTrb 
						SELECT BCI_ARQUIV FROM %table:BCI% BCI WHERE BCI.BCI_FILIAL = %exp:xFilial("BCI")%  AND BCI.BCI_ARQUIV in  (%exp:cFileTISS%)    AND BCI.%notDel%
					Endsql
					If (cAliasTrb)->(!Eof())

						(cAliasTrb)->(DbCloseArea())
						lVldLote := .F.
					Else
						(cAliasTrb)->(DbCloseArea())										
					Endif
				Endif
				
				If ExistBlock("PLPRCTON")
					aPLPRCTON := ExecBlock("PLPRCTON",.F.,.F.,{lVldMatr,cNumCarteira,lVldLote,cNumGuiaPrest,aMatAux})
					If Len(aPLPRCTON) >= 2
						lVldMatr := aPLPRCTON[1]
						lVldLote := aPLPRCTON[2]
					EndIf
				EndIf
				
				If lCancelGui //Cancelamento de Guia nao valida matricula (nao existe esta tag)
					lVldMatr := .T.
				EndIf
					
				If !lVldMatr
					cMsgRet := STR0126//"Matricula do usuario invalida  "
				EndIf
					
				If !lVldLote
					cMsgRet += Iif(Empty(cMsgRet),""," ") + STR0124//"Lote de guia XML já importado para esta RDA!"
				EndIf
					
				If !lVldMatr .Or. !lVldLote
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsgRet, 0, 0, {})
					return({nil,cMsgRet})
				EndIf
					
				RestArea(aAreaBA1)
				RestArea(aAreaBD5)
				RestArea(aAreaBE4)
			Endif
		
		Endif

		aRet := PLSTPTRAN(cFileTISS,cDatHor,aMatXCab,aMatXPre,aMatXEpi,cFileHas,oProcess,cCodPeg,lSlvOk,aMatAux, lBg, l974Xml)		
		If Empty(aRet[1])
			lSlvOk := .F.
		Endif
	EndIf

// Processamento com controle de transação
	If lSlvOk
		if !l974Xml
			If !lOnline .AND. !lBg
				If GetRpoRelease()=="R1.1"
					oSelf:incRegua1("Preparando arquivo de retorno...")
				Else
					IncProc("Preparando arquivo de retorno...")
					ProcessMessage()
				Endif
			Endif
			nH := PLSAbreSem(cSemaforo)
			if !lNoGerFil
				FErase(PLSMUDSIS(cDirTemp+cFileTmp))
			endIf
		//Se o retorno do PLSTPTRAN tiver somente uma posicao no array pode ser o xml de retorno caso o cliente mude a funcao da validacao na BVR
			If ExistBlock("PLSOBSXML")
				cArqRet := PLSPROCRES(aRet,cEncod,,,,,,,,,aMatAux)
			ElseIf (TISVERS >= "3" .AND. Len(aRet) == 1)
				cArqRet := aRet[1]
			Else
				cArqRet := PLSPROCRES(aRet,cEncod,,,,,,,,,aMatAux, aRet[9])
			EndIf
			PLSFechaSem(nH,cSemaforo)
		endIf
	EndIf

// Verfica se a pasta existe e processamento e move para processado ou nao
	if !lNoGerFil
		PLSGRVARQ(PLSMUDSIS(cFileTISS),cCodPeg)
	endIf

	oXml := nil
	oObjXml := nil
	DelClassIntF()
    
	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Finalizando ProcFile (PLSA973)", "tissonanalise.log")
	EndIf
	
	restarea(aAreaBCI)
Return({cArqRet,''})

/*/{Protheus.doc} PLSGRVARQ
Move o arquivo para pasta de processado ou nao proc
#tissver 2.x,3.x

@type Function
@author Alexander Santos
@since 17/03/2007
@version 1.0
/*/
Function PLSGRVARQ(cFileTISS,cCodPeg)
	LOCAL cNameDir	:= ""
	DEFAULT cCodPeg	:= ""

// Se nao teve critica fatal move para processado
	If lOkXml
		cNameDir := cDirProce+DtoS( Date() )
		If !ExistDir(cNameDir)
			If MakeDir( cNameDir ) <> 0
				PLSLOGX(STR0002+cNameDir+STR0003,.F.) //"Impossível criar diretorio ( "###" ) "
			EndIf
		EndIf
	Else
		cNameDir := cDirNaPro+DtoS( Date() )
		If !ExistDir(cNameDir)
			If MakeDir( cNameDir ) <> 0
				PLSLOGX(STR0002+cNameDir+STR0003,.F.) //"Impossível criar diretorio ( "###" ) "
			EndIf
		EndIf
	EndIf

// Coloca o arquivo em processado ou naoprocessado
	If !File(PLSMUDSIS( cNameDir+"\"+cFileTISS ) )
		If fREname( cDirCaiEn+cFileTISS , PLSMUDSIS( cNameDir+"\"+cFileTISS ) ) == -1
			PLSLOGX(STR0049+PLSMUDSIS( cNameDir+"\"+cFileTISS )+STR0010,.F.)//"Impossível mover o arquivo de processamento para a pasta ( "###" )"
		EndIf
	Else
		If fREname( cDirCaiEn+cFileTISS , PLSMUDSIS( cNameDir+"\"+DtoS(Date())+StrTran(Time(),":","")+cFileTISS ) ) == -1
			PLSLOGX(STR0049+PLSMUDSIS( cNameDir+"\"+DtoS(Date())+StrTran(Time(),":","")+cFileTISS )+STR0003,.F.)//"Impossível mover o arquivo de processamento para a pasta ( "###" ) "
		EndIf
	EndIf

Return

/*/{Protheus.doc} PLSLOGX
Ajusta matriz bruta
cTipoGlosa reprasenta o SimpleType dm_tipoGlosa

#tissver 2.x

@type Function
@author Alexander Santos
@since 12/05/2007
@version 1.0
/*/
Function PLSLOGX(cMsg,lXml,lTpCri,lCrit,cTipoGlosa)
	LOCAL nTpCri  	:= 0
	DEFAULT lTpCri 	:= .T.
	DEFAULT lXml	:= .T.
	DEFAULT lCrit	:= .F.
	DEFAULT cTipoGlosa := ""

// Retira abertura e fechamento de tag xml
	cMsg := StrTran(StrTran(StrTran(cMsg,'->','-'),'<',' '),'>',' ')
	cMsg := iif(!Empty(cTipoGlosa),Upper(FwNoAccent(cMsg)),cMsg)

// Variavel que define o processamento de um arquivo
	If lOkXml
		lOkXml := lXml
	EndIf

// Defini se a critica e fatal ou informativa
	If lTpCri
		If lXml
			nTpCri := 2
		Else
			nTpCri := 4
		EndIf

	// Ajusta informacao de criticas
		If nTpCri <> 0 .And. AsCan( aResultado,{|x|x[2] == nTpCri} ) == 0
			If nTpCri == 2
				AaDd(aResultado, { "",1,Len(aResultado),lCrit,cTipoGlosa } )
				AaDd(aResultado, { STR0050,1,Len(aResultado),lCrit,cTipoGlosa } ) //"***** Informações *****"
				AaDd(aResultado, { "",1,Len(aResultado),lCrit,cTipoGlosa } )
			Else
				AaDd(aResultado, { "",3,Len(aResultado),lCrit,cTipoGlosa } )
				AaDd(aResultado, { STR0051,3,Len(aResultado),lCrit,cTipoGlosa } ) //"***** Tipo de critica que não processa o arquivo *****"
				AaDd(aResultado, { "",3,Len(aResultado),lCrit,cTipoGlosa } )
			EndIf
		EndIf
	EndIf

// Alimenta a matriz de log
	AaDd(aResultado, { cMsg,nTpCri,Len(aResultado),lCrit,cTipoGlosa } )

Return

/*/{Protheus.doc} PLSAJMAT
Ajusta matriz bruta
#tissver 2.x

@type Function
@author Alexander Santos
@since 12/05/2007
@version 1.0
/*/
Function PLSAJMAT(cNameSpace,aMat)
	LOCAL nI
	LOCAL aMatAux := {}

// Ajusta matriz com base no elementname
	For nI:=1 To Len(aMat)
		If At(cNameSpace,aMat[nI,1]) > 0
			AaDd(aMatAux,aMat[nI])
		EndIf
	Next

Return(aMatAux)

/*/{Protheus.doc} PLSARRAY
Monta um array e procura conteudo no mesmo
@type function
@author TOTVS
@since 16/05/07
@version 1.0
/*/
Function PLSARRAY(cString,cDelimit,cFind,cCodPeg)
	LOCAL nPos    := 0
	LOCAL nPFind  := 0
	LOCAL aRet    := {}
	DEFAULT cFind := ""
	DEFAULT cCodPeg := ""

// Verifica se foi informado delimitador no final
	If Right(cString,1) <> cDelimit
		cString += cDelimit
	EndIf

// Monta array
	If !Empty(cString)
		While ( nPos := At( cDelimit, cString ) ) > 0
			AaDd( aRet,StrTran(SubStr( cString, 1, nPos-1 ),"'","") )
			cString := SubStr( cString, nPos+1, Len(cString) )
		EndDo

	// Verifica se existe na matriz
		If Len(aRet)>0 .And. !Empty(cFind)
			nPFind := aScan( aRet,{ |x|AllTrim(x)==AllTrim(cFind) } )
		EndIf
	EndIf

Return( { IiF(nPFind>0,.T.,.F.) , nPFind , aRet } )

/*/{Protheus.doc} PLSMONSTR
Monta estrutura detalhada
@type function
@author TOTVS
@since 22.05.07
@version 1.0
/*/
Function PLSMONSTR(aMat,nTam,cCodPeg)
	LOCAL nX,nI,nH
	LOCAL aAux 	  	:= {}
	LOCAL aMatAux 	:= {}
	LOCAL cElemento := ""
	LOCAL cConteudo := ""
	DEFAULT cCodPeg := ""

// For para gravar a estrutura no aruqivo
	For nX:=1 To Len(aMat)
		If ValType(aMat[nX]) <> "O"
			For nI:=1 To Len(aMat[nX])
				If ValType(aMat[nX,nI]) == "O"
					If ValType( aMat[nX,nI]:REALNAME ) == "C" .And. ValType( aMat[nX,2]:TEXT ) == "C"

						cElemento := Upper( SubStr( aMat[nX,2]:REALNAME,nTam ) )
						cConteudo :=  StrTran( StrTran( StrTran( aMat[nX,2]:TEXT ,Chr(13),""),Chr(10),""),Chr(9),"")

						If !Empty(cConteudo)
							cElemento := "CP_"+cElemento
						EndIf
						AaDd( aAux, { cElemento,cConteudo } )

						aMatAux := PLSMONSTR( classDataArr(aMat[nX,nI]) , nTam,cCodPeg )

						If Len(aMatAux) > 0
							For nH:=1 To Len(aMatAux)
								If Empty(aAux[Len(aAux),2])
									aAux[Len(aAux),2] := aMatAux[nH]
								Else
									AaDd( aAux[Len(aAux)], aMatAux[nH] )
								EndIf
							Next
						EndIf
					EndIf
				ElseIf ValType(aMat[nX,nI]) == "A"
					aMatAux := PLSMONSTR( aMat[nX,nI] , nTam,cCodPeg )
					If Len(aMatAux) > 0
						For nH:=1 To Len(aMatAux)
							AaDd( aAux , aMatAux[nH] )
						Next
					EndIf
				EndIf
			Next
		Else
			If ValType(aMat[nX]) == "O"
				If ValType( aMat[nX]:REALNAME ) == "C" .And. ValType( aMat[nX]:TEXT ) == "C"

					cElemento := Upper( SubStr( aMat[nX]:REALNAME,nTam ) )
					cConteudo := StrTran( StrTran( StrTran( aMat[nX]:TEXT ,Chr(13),""),Chr(10),""),Chr(9),"")

					If !Empty(cConteudo)
						cElemento := "CP_"+cElemento
					EndIf

					AaDd( aAux, { cElemento,cConteudo } )

					aMatAux := PLSMONSTR( classDataArr(aMat[nX]) , nTam,cCodPeg )

					If Len(aMatAux) > 0
						For nH:=1 To Len(aMatAux)
							If Empty(aAux[Len(aAux),2])
								aAux[Len(aAux),2] := aMatAux[nH]
							Else
								AaDd( aAux[Len(aAux)], aMatAux[nH] )
							EndIf
						Next
					EndIf
				EndIf
			EndIf
		EndIf
	Next

Return(aAux)

/*/{Protheus.doc} PLSDESCH
Conta quantidade de elementos de CH
@type function
@author TOTVS
@since 22.05.07
@version 1.0
/*/
Function PLSDESCH(aMat,aMatX,cOrig,cCodPeg)
	LOCAL nX        := 0
	LOCAL nCont 	:= 0
	LOCAL lOp		:= .F.
	LOCAL cElemento := ""
	LOCAL cEleCh	:= ""
	LOCAL cEleChFI	:= ""
	DEFAULT cCodPeg := ""

// Conta elementos de CH
	For nX:=1 To Len(aMat)
		If ValType(aMat[nX]) <> "A" .And. At("_NC",aMat[nX]) == 0
			cElemento := Upper( aMat[nX] )
			lOp       := At("_OP",cElemento) > 0
			cElemento := AllTrim( StrTran(cElemento,"_CH","") )
			cElemento := AllTrim( StrTran(cElemento,"_OP","") )

			If ValType(aMatX[2]) == "A"
				If ( nPos := aScan( aMatX,{|x|x[1] == cElemento },2 ) ) > 0
					nCont++
					cEleChFI += AllTrim( StrTran(cElemento,"CP_","") ) + ","
				EndIf
			EndIf

			cEleCh += AllTrim( StrTran(cElemento,"CP_","") ) + ","

		EndIf
	Next

// Se todos os elementos do choice forem opcionais nao trata
	If lOp
		nCont:=1
	EndIf

// Verifica resultado
	If nCont>1
	//PLSLOGX(STR0055+cEleCh+STR0056+cEleChFI+STR0057+cOrig,.F.) //"Informe somente um elemento da sequencia ( "###" ), encontrado(s) ( "###" ).  Origem -> "
	ElseIf nCont==0
	//PLSLOGX(STR0058+cEleCh+STR0057+cOrig,.F.) //"Informe pelo menos um elemento da sequencia ( "###" ).  Origem -> "
	EndIf

Return(nCont==1)

/*/{Protheus.doc} PLSVLDXML
Valida XML com base no Schemas
@type function
@author TOTVS
@since 22.05.07
@version 1.0
/*/
Function PLSVLDXML( aMatS,aMatX,cOrig,aMatDad,lEleCh,cCodPeg )
	LOCAL nX,nY		:= 0
	LOCAL nB,nH		:= 0
	LOCAL nPosFid	:= 0
	LOCAL cElemento	:= ""
	LOCAL cOrigCor  := ""
	LOCAL cConteudo	:= ""
	LOCAL lAchou	:= .F.
	LOCAL lFind		:= .T.
	LOCAL lCampo    := .F.
	LOCAL lCh	    := .F.
	LOCAL lOp	    := .F.
	LOCAL lElOpc	:= .F.
	LOCAL lCaOpc  	:= .F.
	LOCAL aRet		:= {}
	LOCAL aAuxX		:= {}
	DEFAULT cOrig	:= "\"
	DEFAULT aMatDad	:= {}
	DEFAULT lEleCh	:= .F.
	DEFAULT cCodPeg	:= ""




// Origem
	cOrigCor := cOrig

// Todos os elementos do shema para validar o xml de recebido
	For nX:=1 To Len(aMatS)
		If ValType( aMatS[nX] ) <> "A" .And. At(";",aMatS[nX]) == 0
			lAchou 	  := .F.
			lElOpc	  := .F.
			lCaOpc	  := .F.
			lNillAble := .F.
			cElemento := Upper( aMatS[nX] )
			lCampo    := At("CP_",cElemento) > 0
			lCh		  := At("_CH",cElemento) > 0
			lOp       := At("_OP",cElemento) > 0
			lEx       := At("EX_",cElemento) > 0
			_aRet	  := PLSBUSELE( "CP_:NIL",aMatX,.F.,cCodPeg )
			If _aRet[1]
				aMatX[_aRet[3],1] := "CP_:NIL"
				lNillAble := Iif(aMatX[_aRet[3],2]=='true',.T.,.F.)
			EndIf
			cElemento := AllTrim( StrTran(cElemento,"_CH","") )
			cElemento := AllTrim( StrTran(cElemento,"_OP","") )
			cElemento := AllTrim( StrTran(cElemento,"_NC","") )
			Iif(lCampo,lCaOpc:=lOp,lElOpc:=lOp )

		// Verifica existencia
			aRet 	  := PLSBUSELE( cElemento,aMatX,lCampo,cCodPeg )
			lAchou 	  := aRet[1]
			cConteudo := aRet[2]
			nPosFid	  := aRet[3]
			cElemento := AllTrim( StrTran(cElemento,"CP_","") )

		// Retorno
			If !lAchou .And. !lCaOpc .And. !lElOpc .And. !lEleCh .And. !lEx .And. !lNillAble
				PLSLOGX(STR0059+cElemento+STR0060+cOrigCor,.F.) //"Elemento não encontrado ( "###" ) na origem -> "
			ElseIf lAchou
				If (Empty( AllTrim(cConteudo) ) .and. ALLTRIM(UPPER(cElemento))<>"CODIGO" ) .And. lCampo .And. !lCaOpc  // Incluido o codigo no Array para posterior Validação
					PLSLOGX(STR0061+cElemento+STR0062+cOrigCor,.F.) //"Conteudo do elemento ( "###" ) não informado.  Origem -> "
					If lEleCh
						AaDd( aMatDad, { cElemento,"",cOrigCor } )
					EndIf
				ElseIf !Empty(cConteudo) .And. !lCampo
					PLSLOGX(STR0063+cElemento+STR0064+cOrigCor,.F.) //"Elemento ( "###" ) não deve receber conteudo.  Origem -> "
				Else
					AaDd( aMatDad, { cElemento,cConteudo,Iif( !Empty(cConteudo),cOrigCor,"" ) } )

				// Campos no formato de matriz
					If lCampo .And. Len(aMatX)>2
						nPosFid++
						For nY:=nPosFid To Len(aMatX)
							aRet   	  := PLSBUSELE( "CP_"+cElemento,@aMatX,lCampo,cCodPeg )
							lAchou 	  := aRet[1]
							cConteudo := aRet[2]
							If lAchou
								AaDd( aMatDad, { cElemento,cConteudo,Iif( !Empty(cConteudo),cOrigCor,"" ) } )
							Else
								Exit
							EndIf
						Next
					EndIf
				EndIf
			EndIf

		// Verifica elemento Choice
			If lCh .And. lAchou
				lEleCh := PLSDESCH( aMatS[nX+1] , IiF( ValType(aMatX[nPosFid])<>"A" , aMatX , aMatX[nPosFid] ) , cOrigCor+cElemento+"\")
				lAchou := lEleCh
			EndIf

	// Se achou
		ElseIf lAchou

			aAuxX := aMatX
			If !lCampo .And. nPosFid > 0
				If ValType( aMatX[nPosFid] ) == "A"
					aAuxX := aMatX[nPosFid]
				ElseIf Len( aMatX ) == 2
					aAuxX := aMatX[nPosFid+1]
				EndIf
				If Len(aMatS)>=nX+1 .And. cElemento <> "CABECALHO"
					If  ValType(aMatS[nX+1]) <> "A"
						nPosFid := 0
					EndIf
				Else
					nPosFid := 0
				EndIf
			EndIf

			If At(";",cElemento) == 0 .And. !lCampo
				cOrig += cElemento+"\"
			EndIf
			lFind := .T.
			While lFind
				PLSVLDXML( aMatS[nX],aAuxX,cOrig,aMatDad,Iif(lCh,lEleCh,lCh),cCodPeg )

				For nB:=1 To Len(aAuxX)
					If ValType(aAuxX[nB]) == 'A' .And. At("CP_",aAuxX[nB,1]) == 0 .And. At("*",aAuxX[nB,1]) == 0
						nPosnH 	  := 0
						For nH:=1 To Len(aMatS)
							If ValType(aMatS[nH]) <> 'A' .And. At("EX_",aMatS[nH]) > 0 .And. aAuxX[nB,1] == Upper( AllTrim( StrTran(aMatS[nH],"EX_","") ) )
								nPosnH := nH+1
								Exit
							EndIf
						Next
						If nPosnH>0
							If At(";",aAuxX[nB,1]) == 0 .And. !lCampo
								cOrig += aAuxX[nB,1]+"\"
							EndIf

							PLSVLDXML( aMatS[nPosnH],aAuxX[nB],cOrig,aMatDad,Iif(lCh,lEleCh,lCh),cCodPeg )
						EndIf
					EndIf
				Next

				If At(";",cElemento) == 0 .And. !lCampo
					aRet  := PLSBUSELE( cElemento,aMatX,lCampo,cCodPeg)
					lFind := aRet[1]
					If lFind
						aAuxX := aMatX[aRet[3]]
						AaDd( aMatDad, { cElemento,"","" } )
					EndIf
				Else
					lFind := .F.
				EndIf
			EndDo
			cOrig  := cOrigCor
		EndIf
	Next

Return(aMatDad)

/*/{Protheus.doc} PLSBUSELE
Busca Elemento na matriz
@type function
@author TOTVS
@since 22.05.07
@version 1.0
/*/
Function PLSBUSELE(cElemento,aMatX,lCampo,cCodPeg)
	LOCAL nPos		:= 0
	LOCAL cConteudo := ""
	LOCAL lFind 	:= .F.
	LOCAL lFEle 	:= .F.
	DEFAULT cCodPeg := ""

// Procura elemento na matriz
	If ( lFEle := ( nPos := aScan(aMatX,{|x| ValType(x) == "C" .AND. x == cElemento } ) ) == 0 )
		If ValType(aMatX) == "A" .AND. Len(aMatX)>=2 .And. ValType(aMatX[2]) == "A"
			nPos := aScan( aMatX,{|x|x[1] == cElemento },2 )
			If lCampo .And. nPos == 0
				nPos := aScan( aMatX,{|x|x[1] == AllTrim( StrTran(cElemento,"CP_","") ) },2 )
			EndIf
		Else
			nPos := 0
		EndIf
	EndIf

// Se achou
	If nPos>0
		lFind := .T.
		If !lFEle
			aMatX[nPos]	:= "*"+aMatX[nPos]
		Else
			aMatX[nPos,1] := "*"+aMatX[nPos,1]
		EndIf
		If lCampo
			If ValType(aMatX[nPos]) == "A"
				cConteudo := aMatX[nPos,2]
			Else
				cConteudo := aMatX[2]
			EndIf
		EndIf
	EndIf

Return( {lFind,cConteudo,nPos} )

/*/{Protheus.doc} PLSTPTRAN
Processamento conforme tipo de transacao
@type function
@author TOTVS
@since 22.05.07
@version 1.0
/*/
Function PLSTPTRAN(cNomeArq,cDatHor,aMatXCab,aMatXPre,aMatXEpi,cFileHas,oProcess,cCodPeg,lOk,aDadosXml,lBg, l974Xml)
	LOCAL nI
	LOCAL nPos		:= 0
	LOCAL nPosAux	:= 0
	LOCAL nPosNext	:= 0
	LOCAL nTotGui	:= 0
	LOCAL cTpTran	:= ""
	LOCAL cGuia		:= ""
	LOCAL cTpGuias	:= ""
	LOCAL cTranRet  := ""
	LOCAL cOrigem	:= ""
	LOCAL cTagOri	:= ""
	LOCAL cNomApl	:= ""
	LOCAL cVerApl	:= ""
	LOCAL cFabApl	:= ""
	LOCAL lHasAr	:= .F.
	LOCAL lHasCo	:= .F.
	LOCAL nIniSeg	:= Seconds()
	LOCAL aMatAux 	:= {}
	LOCAL aMatNew 	:= {}
	LOCAL aRet	    := {}
	LOCAL aMatRet   := {}
	LOCAL aMatC   	:= {}
	LOCAL aMatM   	:= {}
	LOCAL cTipo     := ""
	LOCAL aRetTrans	:= {}
	LOCAL xRetTrans	:= {}
	LOCAL cExpVld		:= ""
	LOCAL cCodRP
	LOCAL nIdx
	LOCAL aDadosRet	:= {}
	LOCAL cTpCab := ""			//1,5
	LOCAL cCCCab := ""			//2,6
	LOCAL cCodRda := ""		//3,15
	LOCAL cNomRda := ""		//4
	LOCAL cMatric := ""		//7
	LOCAL cNomeUsu := ""		//8
	LOCAL cNumeSeq := ""		//9,13
	LOCAL cNumAut := ""		//10
	LOCAL cNumAut2 := ""		//17
	LOCAL lAchouNAut := .F.		//18
	LOCAL lHonorario := .F.	//11
	LOCAL lResIntern := .F.	//12
	LOCAL dDatPro := ""		//14
	LOCAL cCNES := ""			//16
	LOCAL dDatAtend := Stod("")  //20
	LOCAL lExisBVR	:= .F.
	LOCAL aDadUsrRet:= {}
	LOCAL cStTiss := ""
	LOCAL j	:=0
	LOCAL i	:=0
	PRIVATE aDados	:= aDadosXml //dados do XML a partir da versao 3 da TISS
	PRIVATE cTipoRD	:= ""
	DEFAULT oProcess:= nil
	DEFAULT cCodPeg	:= ""
	DEFAULT lOk	:= lOkXML
	DEFAULT lBg	:= .F.
	Default l974Xml	:= .F.

	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Iniciando PLSTPTRAN (PLSA973)", "tissonanalise.log")
	EndIf
	
	If (TISVERS < "3")


	// Valida Cabecalho
		AaDd( aMatRet , PLSVLDXML(aMatCab,aMatXCab,nil,nil,nil,cCodPeg) )

	// Valida Corpo
		AaDd( aMatRet , PLSVLDXML(aMatPre,aMatXPre,nil,nil,nil,cCodPeg) )

	// Valida Epilogo
		AaDd( aMatRet , PLSVLDXML(aMatEpi,aMatXEpi,nil,nil,nil,cCodPeg) )

	// Verifica campos do software gerador - verao >= 2_02_02
		If lVerTISS
			cNomApl := PLSPEGCON("NOMEAPLICATIVO",aMatRet[1],cCodPeg)
			cVerApl := PLSPEGCON("VERSAOAPLICATIVO",aMatRet[1],cCodPeg)
			cFabApl := PLSPEGCON("FABRICANTEAPLICATIVO",aMatRet[1],cCodPeg)
		EndIf


	// Ajusta cabecalho
		For nI:=1 To Len(aMatRet[1])
			If !Empty(aMatRet[1,nI,2])
				AaDd(aMatC,aMatRet[1,nI])
			EndIf
		Next


	// Tipos de Guias Prestador para Operadora TISS <= 2.02.03
		cTpGuias :=	"GUIACONSULTA,"							//Lote Guias
		cTpGuias +=	"GUIASP_SADT,"							//Lote Guias
		cTpGuias +=	"GUIAHONORARIOINDIVIDUAL,"				//Lote Guias
		cTpGuias +=	"GUIARESUMOINTERNACAO,"					//Lote Guias
		cTpGuias +=	"GUIAODONTOLOGIA,"				   		//Lote Guias 					- Pendente
		cTpGuias +=	"GUIACONSULTAREAPRESENTACAO,"			//Lote Guias
		cTpGuias +=	"GUIASP_SADTREAPRESENTACAO,"			//Lote Guias
		cTpGuias +=	"GUIAHONORARIOINDIVIDUALREAPRESENTACAO,"//Lote Guias
		cTpGuias +=	"GUIARESUMOINTERNACAOREAPRESENTACAO,"	//Lote Guias
		cTpGuias +=	"GUIAODONTOLOGIAREAPRESENTACAO,"		//Lote Guias 					- Pendente
		cTpGuias +=	"GUIASOLICITACAOSADT,"                  //Solicitacao Procedimento
		cTpGuias +=	"GUIASOLICINTERNACAO,"					//Solicitacao Procedimento
		cTpGuias +=	"GUIASOLICITACAOPRORROGACAO,"			//Solicitacao Procedimento
		cTpGuias +=	"GUIASOLICITACAOODONTOLOGIA,"			//Solicitacao Procedimento 		- Pendente
		cTpGuias +=	"VERIFICAELEGIBILIDADE,"				//Verifica Elegibilidade
		cTpGuias +=	"DADOSGUIA,"							//Cancela Guia
		cTpGuias +=	"CANCELA_GUIA,"							//Cancela Guia
		cTpGuias +=	"IDENTIFICACAOSOLICITACAO,"             //Solicitacao Status Autorizacao
		cTpGuias +=	"SOLICITACAODEMONSTRATIVORETORNO,"		//Solicitacao Demostrativo
		cTpGuias +=	"DEMONSTRATIVOANALISECONTA,"			//Demonstrativos Retorno
		cTpGuias +=	"DEMONSTRATIVOODONTOLOGIA,"             //Demonstrativos Retorno
		cTpGuias +=	"DEMONSTRATIVOPAGAMENTO,"               //Demonstrativos Retorno
		cTpGuias +=	"DETALHEPROTOCOLO,"						//Solicitacao Status Protocolo
		cTpGuias += "RECURSOGUIA,"                          //solicitação de recurso de glosa
		cTpGuias += "RECURSOPROTOCOLO"						//solicitação de recurso de glosa

	// Procura o tipo de guia
		cGuia := PLSPCONGR(cTpGuias,"",aMatRet[2],"E",nil,.F.,nil,cCodPeg)

		If !Empty(cGuia)
			nPos	 := aScan(aMatRet[2],{|x|x[1] == cGuia },(nPos+1) )
			nPosAux	 := nPos

			While nPosAux > 0
				For nI:=1 To (nPos-1)
					AaDd(aMatAux,aMatRet[2,nI])
				Next
				nPosNext := aScan(aMatRet[2],{|x|x[1] == cGuia },(nPosAux+1) )
				If nPosAux>nPos .And. nPosNext == 0
					nPosNext := Len(aMatRet[2])+1
				EndIf
				If nPosNext > 0
					For nI:=nPosAux To (nPosNext-1)
						AaDd(aMatAux,aMatRet[2,nI])
					Next
				ElseIf nPosAux == nPos
					aMatAux := aMatRet[2]
				EndIf
				nPosAux := nPosNext
				If Len(aMatAux) > nPos
					For nI:=1 To Len(aMatAux)
						If !Empty(aMatAux[nI,2])
							AaDd(aMatNew,aMatAux[nI])
						EndIf
					Next
					AaDd(aMatM,aMatNew)
				EndIf
				If nPosNext == Len(aMatRet[2])+1
					nPosAux := 0
				EndIf
				aMatAux := {}
				aMatNew := {}
			EndDo
		Else
			PLSLOGX(STR0068+cTpGuias+" ) ",.F.) //"Tipo de guia não encontrado ( "
		EndIf
	Else

		// Tipos de Guias Prestador para Operadora
		cTpGuias :=	P973TpGui()


		// Procura o tipo de guia
		cGuia := PLSTPGUIA(cTpGuias, aDados)

		If !Empty(cGuia)
			nPos	 := aScan(aDados,{|x| StrTran(StrTran(x[1],"-",""),"_","") == StrTran(StrTran(cGuia,"-",""),"_","") },(nPos+1) )
			nPosAux	 := nPos

			//  cabecalho														 					³
			For nI:=1 To (nPos-1)
				If !Empty(aDados[nI,3])
					AaDd(aMatC,aDados[nI])
				EndIf
			Next

			While nPosAux > 0
				For nI:=1 To (nPos-1)
					AaDd(aMatAux,aDados[nI])
				Next
				nPosNext := aScan(aDados,{|x| StrTran(StrTran(x[1],"-",""),"_","") == StrTran(StrTran(cGuia,"-",""),"_","") },(nPosAux+1) )
				If nPosAux>nPos .And. nPosNext == 0
					nPosNext := Len(aDados)+1
				EndIf
				If nPosNext > 0
					For nI:=nPosAux To (nPosNext-1)
						AaDd(aMatAux,aDados[nI])
					Next
				ElseIf nPosAux == nPos
					aMatAux := aDados
				EndIf
				nPosAux := nPosNext
				If Len(aMatAux) > nPos
					For nI:=1 To Len(aMatAux)
						If !Empty(aMatAux[nI,3])
							AaDd(aMatNew,aMatAux[nI])
						EndIf
					Next
					AaDd(aMatM,aMatNew)

				EndIf
				If nPosNext == Len(aDados)+1
					nPosAux := 0
				EndIf
				aMatAux := {}
				aMatNew := {}
			EndDo
			
			//Teve um caso em que algumas PEGs importadas multiplicavam as guias
			//A única situação  em que foi identificada que poderia gerar isso era
			//se o aMatM chegasse maior do que deveria na hora do For do PLSLGSP3
			//Foi incluído esse if pra garantir que o aMatM não importe uma quantidade
			//de guias maior do que a que foi submetida
			If (Select("BXX") > 0 .and. BXX->BXX_QTDGUI > 0 .and. Len(aMatM) > BXX->BXX_QTDGUI)
				aSize(aMatM, BXX->BXX_QTDGUI)
			EndIf
		Else
			PLSLOGX(STR0068+cTpGuias+" ) ",.F.) //"Tipo de guia não encontrado ( "
		EndIf

	EndIf


// Verifica se em consulta ou sp-sadt ou internacao
	Do Case
	Case cGuia $ "GUIACONSULTA,GUIACONSULTAREAPRESENTACAO"
		cTipo 	:= "1"
	Case cGuia $ "GUIASOLICITACAOSADT,GUIASP_SADT,GUIASP_SADTREAPRESENTACAO,SOLICITACAOSP_SADT"
		cTipo 	:= "2"
	Case cGuia $ "GUIASOLICINTERNACAO,GUIASOLICITACAOPRORROGACAO,GUIAHONORARIOINDIVIDUAL,GUIAHONORARIOINDIVIDUALREAPRESENTACAO,GUIARESUMOINTERNACAO,GUIARESUMOINTERNACAOREAPRESENTACAO,SOLICITACAOINTERNACAO,SOLICITACAOPRORROGACAO"
		cTipo 	:= "3"
	Case cGuia $ "GUIAODONTOLOGIA,GUIAODONTOLOGIAREAPRESENTACAO,GUIAODONTO,SOLICITACAOODONTOLOGIA"
		cTipo 	:= "4"
	EndCase


// Verifica tipo de transacao recebida e o retorno
	If TISVERS < "3" .AND. Len(aMatRet) > 0 .AND. Len(aMatRet[1]) > 0
		cTpTran  := PLSPEGCON("TIPOTRANSACAO",aMatRet[1],cCodPeg)
		cNumeSeq := PLSPEGCON("SEQUENCIALTRANSACAO",aMatRet[1],cCodPeg)

	// Dados para informacao do destino do retorno
		cTagOri	 := "registroANS"
		cOrigem  := PLSPCONGR(Upper(cTagOri),'\CABECALHO\ORIGEM\',aMatRet[1],nil,nil,nil,nil,cCodPeg)
		If Empty(cOrigem)
			cTagOri	 := 'CPF'
			cOrigem  := AllTrim( PLSPCONGR(Upper(cTagOri),"CABECALHO\ORIGEM\CODIGOPRESTADORNAOPERADORA",aMatRet[1],nil,nil,nil,nil,cCodPeg) )
			If Empty(cOrigem)
				cTagOri	 := 'CNPJ'
				cOrigem  := AllTrim( PLSPCONGR(Upper(cTagOri),"CABECALHO\ORIGEM\CODIGOPRESTADORNAOPERADORA",aMatRet[1],nil,nil,nil,nil,cCodPeg) )
				If Empty(cOrigem)
					cTagOri	 := 'cnpjPagador'
					cOrigem  := AllTrim( PLSPCONGR(Upper(cTagOri),"CABECALHO\ORIGEM",aMatRet[1],nil,nil,nil,nil,cCodPeg) )
					If Empty(cOrigem)
						cTagOri	 := 'codigoPrestadorNaOperadora'
						cOrigem  := PLSPCONGR(Upper(cTagOri),"CABECALHO\ORIGEM\CODIGOPRESTADORNAOPERADORA",aMatRet[1],nil,nil,nil,nil,cCodPeg)
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf (TISVERS >= "3")
		cTpTran  := PVLRTAGXML(aDados, "TIPOTRANSACAO")
		cNumeSeq := PVLRTAGXML(aDados, "SEQUENCIALTRANSACAO")

	// Dados para informacao do destino do retorno
		cTagOri	 := "REGISTROANS"
		cOrigem  := PVLRTAGXML(aDados, "\CABECALHO\ORIGEM\" + cTagOri)
		If Empty(cOrigem)
			cTagOri	 := 'CPF'
			cOrigem  := PVLRTAGXML(aDados, "\CABECALHO\ORIGEM\IDENTIFICACAOPRESTADOR\" + cTagOri)
			If Empty(cOrigem)
				cTagOri	 := 'CNPJ'
				cOrigem  := PVLRTAGXML(aDados, "\CABECALHO\ORIGEM\IDENTIFICACAOPRESTADOR\" + cTagOri)
				If Empty(cOrigem)
					cTagOri	 := 'codigoPrestadorNaOperadora'
					cOrigem  := PVLRTAGXML(aDados, "\CABECALHO\ORIGEM\IDENTIFICACAOPRESTADOR\" + cTagOri)
				EndIf
			EndIf
		EndIf
	EndIf



// Tipo de transacao e retorno
	Do Case
	Case cTpTran $ "ENVIO_LOTE_GUIAS,RE_APRESENTACAO_GUIA"
		cTranRet := "PROTOCOLO_RECEBIMENTO=protocoloRecebimento"
	Case cTpTran == "SOLICITACAO_PROCEDIMENTOS"
		If (TISVERS < "3")
			cTranRet := "RESPOSTA_SOLICITACAO=autorizacaoServico"//AUTORIZACAO_ODONTOLOGIA=autorizacaoServico
		Else
			cTranRet := "RESPOSTA_SOLICITACAO=autorizacaoProcedimento"
		EndIf
	Case cTpTran $ "SOLICITA_STATUS_AUTORIZACAO,STATUS_AUTORIZACAO"
		cTranRet := "STATUS_AUTORIZACAO=situacaoAutorizacao"
	Case cTpTran == "CANCELA_GUIA"
		cTranRet := "CANCELAMENTO_GUIA_RECIBO=reciboCancelaGuia"
	Case cTpTran == "VERIFICA_ELEGIBILIDADE"
		cTranRet := "SITUACAO_ELEGIBILIDADE=respostaElegibilidade"
	Case cTpTran == "SOLIC_STATUS_PROTOCOLO"
		cTranRet := "SITUACAO_PROTOCOLO=situacaoProtocolo"
	Case cTpTran == "SOLIC_DEMONSTRATIVO_RETORNO"
		cTranRet := "DEMONSTRATIVO_PAGAMENTO=demonstrativosRetorno_demonstrativoPagamento,"+;
			"DEMONSTRATIVO_ANALISE_CONTA=demonstrativosRetorno_demonstrativoAnaliseConta,"+;
			"DEMONSTRATIVO_ODONTOLOGIA=demonstrativosRetorno_demonstrativoPagamentoOdonto"
	Case cTpTran == "SOLIC_STATUS_RECURSO_GLOSA"
		cTranRet := "RESPOSTA_RECURSO_GLOSA=respostaRecursoGlosa"
	Case cTpTran == "RECURSO_GLOSA"
		cTranRet := "RECEBIMENTO_RECURSO_GLOSA=recebimentoRecursoGlosa"
	EndCase


// Processamento
	If lOk
		//  Verifica tipo de transacao com a transacao
		If At(cGuia,"GUIASOLICITACAOSADT,SOLICITACAOSP_SADT,SOLICITACAOSPSADT,GUIASOLICINTERNACAO,SOLICITACAOINTERNACAO,GUIASOLICITACAOPRORROGACAO,SOLICITACAOPRORROGACAO,GUIAODONTO") > 0 .And. cTpTran=="ENVIO_LOTE_GUIAS"
			PLSLOGX(STR0069+cTpTran+STR0070+cGuia+STR0003,.F.)	 //"Tipo de transação ( "###" ) invalido para o tipo de guia ( "###" ) "
		EndIf

		If !PlsAliasExi("BVR") .AND. cTpTran $ "ENVIO_LOTE_GUIAS,RE_APRESENTACAO_GUIA,SOLICITACAO_PROCEDIMENTOS"
			nTotGui := Len(aMatM)
			// Ajusta posiçao do Array TISS 2 x TISS 3
			PlsAjsArT(@aMatC)
			if l974Xml .And. !lBg
				oProcess:setRegua2(nTotGui)
			endIf

			For nI:=1 To nTotGui
				PlsAjsArT(@aMatM, nI)
				If lOk
					If l974Xml .And. !lBg
						oProcess:IncRegua2("Guia ["+cValToChar(nI)+"] do total ["+cValToChar(nTotGui)+"]")
					endIf

					xRft := PLSLGSP3( cGuia,cNomeArq,cDatHor,aMatC,aMatM[nI],lHasAr,lHasCo, .F.,cCodPeg,lOk,nI,/*aMatBWT*/, lBg, l974Xml)

					AaDd( aRet, xRft)
					If !lProcLog
						Exit
					EndIf
				EndIf
			Next

			// Mostra log de processamento

			If lProcLog
				PLSMOSPRC(aMatM,aRet,cCodPeg)
			EndIf
			lProcLog := .T.
		Else
			If PlsAliasExi("BVR")
				BVR->(DbSelectArea("BVR"))
				BVR->(DbSetOrder(1)) //BVR_FILIAL+BVR_TISVER+BVR_TRANS
				If cTpTran $ "ENVIO_LOTE_GUIAS,RE_APRESENTACAO_GUIA,SOLICITACAO_PROCEDIMENTOS"
					lExisBVR := (BVR->(MsSeek(xFilial("BVR")+TISVERS+cTpTran)))
				EndIf
				If cTpTran $ "ENVIO_LOTE_GUIAS,RE_APRESENTACAO_GUIA,SOLICITACAO_PROCEDIMENTOS" .AND. !lExisBVR
					nTotGui := Len(aMatM)
					// Ajusta posiçao do Array TISS 2 x TISS 3
					PlsAjsArT(@aMatC)
					if l974Xml .And. !lBg
						oProcess:setRegua2(nTotGui)
					endIf

					For nI:=1 To nTotGui
						PlsAjsArT(@aMatM, nI)
						If lOk
							If l974Xml .And. !lBg
								oProcess:IncRegua2("Guia ["+cValToChar(nI)+"] do total ["+cValToChar(nTotGui)+"]")
							endIf

							xRft := PLSLGSP3(cGuia, cNomeArq, cDatHor, aMatC, aMatM[nI], lHasAr, lHasCo, .F., cCodPeg, lOk, nI,/*aMatBWT*/, lBg, l974Xml)
									
							If xRft[2,1]
								BA1->( dbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
								BA1->( msSeek( xFilial("BA1")+allTrim(xRft[1,7]) ) )
										
								aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.f.,dDataBase)

								//Esse item de faz necessario para valdiar a matricula do usuario nesse momento pois ja passou pelo  PLSLGSP3  
								If !aRetFun[1]
										
									BA1->( dbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
									BA1->( msSeek( xFilial("BA1")+allTrim(xRft[1,7]) ))
									aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.f.,dDataBase)
											
									If !aRetFun[1]
										xRft[2,1]:=.F.
										xRft[2,6]:= xRft[2,5] //Negados
											
												
										For i:=1 to Len(aRetFun[2])
											For j:=1 to Len(xRft[2,5])	
												aadd(xRft[2,4],{xRft[2,5,j,1],aRetFun[2,i,1],aRetFun[2,i,2],xRft[2,5,j,2],xRft[2,5,j,3],'','',{.f.,""}})
											Next j	
										Next i

										xRft[2,5]:={}			//Autorizados
									Endif
								EndIf
							Endif

							AaDd( aRet, xRft)
							If !lProcLog
								Exit
							EndIf
						EndIf
					Next
				//EndIf

					// Mostra log de processamento

					If lProcLog
						PLSMOSPRC(aMatM,aRet,cCodPeg)
					EndIf
					lProcLog := .T.

				ElseIf (BVR->(MsSeek(xFilial("BVR")+TISVERS+cTpTran)))
					nLines := MLCount( BVR->BVR_EXPVLD )

					For nI := 1 to nLines
						if !(empty(memoLine(BVR->BVR_EXPVLD,,nI)))
							cExpVld += alltrim(strTran(strTran(memoLine(BVR->BVR_EXPVLD,,nI), chr(10), ""), chr(13),""))
						endIf
					next nI


					// Comentado o tratamento do erro pois conflitava com a execução de importaçao das guias anter
					//Begin Sequence
					xRetTrans := &(cExpVld)

					If (ValType(xRetTrans) == "C")
						//caso a funcao da transacao retorne um dado do tipo string, quer dizer que o cliente customizou a transacao na tabela BVR e retornou somente o XML
						Return { xRetTrans }
					ElseIf (ValType(xRetTrans) == "A")
						aRetTrans := xRetTrans
					EndIf

					//End Sequence
					//ErrorBlock(oError)
					cAteRN := ""

					For nI := 1 To Iif (len(aRetTrans) > 0, len(aRetTrans), 1)
						If (cTpTran $ "VERIFICA_ELEGIBILIDADE,CANCELA_GUIA,SOLIC_STATUS_PROTOCOLO,SOLICITA_STATUS_AUTORIZACAO,RECURSO_GLOSA,SOLIC_STATUS_RECURSO_GLOSA,SOLIC_DEMONSTRATIVO_RETORNO")

							//Preciso Ajustar para qual tipo de relatório é o certo. cTipoRD possui a informação
							IIF (cTpTran == "SOLIC_DEMONSTRATIVO_RETORNO", cTranRet := cTipoRD, "")

							cCodRP := PVLRTAGXML(aDados, "\DADOSPRESTADOR\CPFCONTRATADO,\DADOSCONTRATADO\CPFCONTRATADO", nI)
							cCodRP := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
							nIdx := 4
							If (Empty(cCodRP))
								cCodRP := PVLRTAGXML(aDados, "\DADOSPRESTADOR\CNPJCONTRATADO,\DADOSCONTRATADO\CNPJCONTRATADO", nI)
								If (Empty(cCodRP))
									cCodRP := PVLRTAGXML(aDados, "\DADOSPRESTADOR\CODIGOPRESTADORNAOPERADORA,\DADOSCONTRATADO\CODIGOPRESTADORNAOPERADORA", nI)
									nIdx := 1
								EndIf
							EndIf

							cCodRda := ""
							cNomRda := ""
							cTpCab := ""
							cCCCab := ""
							cCNES := ""

							//Se Status Autorizacao, a guia ja existe, uso a RDA da guia 
							if cTpTran == "SOLICITA_STATUS_AUTORIZACAO" .And. len(aRetTrans) > 0
								BEA->(DbSetOrder(1))
								if BEA->(DbSeek(xFilial("BEA")+aRetTrans[1,2]))
									nIdx   := 1
									cCodRP := BEA->BEA_CODRDA
								endIf
							endIf

							BAU->( DbSetOrder( nIdx ) ) //BAU_FILIAL + BAU_CPFCGC ou  BAU_CODIGO ou BAU_CODBB0
							If BAU->( MsSeek( xFilial("BAU")+cCodRP ) )
								cCodRda := BAU->BAU_CODIGO
								cNomRda := AllTrim(BAU->BAU_NOME)
								cTpCab  := AllTrim(BAU->BAU_TIPPE)
								cCCCab  := AllTrim(BAU->BAU_CPFCGC)
								cCNES 	:= AllTrim(BAU->BAU_CNES)
							EndIf

							cMatric := PVLRTAGXML(aDados, "\NUMEROCARTEIRA", nI)
							cNomeUsu := PVLRTAGXML(aDados, "\NOMEBENEFICIARIO", nI)
							dDatPro := PVLRTAGXML(aDados, "\DATAREGISTROTRANSACAO", nI)
							cAteRN := ""
							If (cTpTran $ "CANCELA_GUIA,SOLIC_STATUS_PROTOCOLO,SOLICITA_STATUS_AUTORIZACAO")
								If (cTpTran $ "SOLIC_STATUS_PROTOCOLO")
									cNumAut := aRetTrans[nI, 2]
									cNumeSeq := PVLRTAGXML(aDados, "\NUMEROPROTOCOLO", nI)
								Else
									cNumAut := PVLRTAGXML(aDados, "\NUMEROGUIAPRESTADOR", nI)
									cNumAut2 := PVLRTAGXML(aDados, "\NUMEROGUIAOPERADORA", nI)
								EndIf

								//Pesquisa Guia pelo Numero do Prestador ou da Operadora
								If !Empty(cNumAut) .OR. !Empty(cNumAut2)
									BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
									if !Empty(cNumAut) .And. BEA->( MsSeek( xFilial("BEA")+cNumAut ) )
										lAchouNAut := .T.
									endIf

									if !lAchouNAut .And. !Empty(cNumAut2) .And. BEA->( MsSeek( xFilial("BEA")+cNumAut2 ) )
										cNumAut := iif(!Empty(cNumAut2),cNumAut2,cNumAut)
										lAchouNAut := .T.
									endIf

									//Busca no NUMIMP com o dado de numeroGuiaPrestador
									if !lAchouNAut .And. !Empty(cNumAut) 
										BEA->(DbSetOrder(9)) //BEA_FILIAL+BEA_NUMIMP
										if BEA->( MsSeek( xFilial("BEA")+cNumAut ) )
											If PVLRTAGXML(aDados, "\TIPOTRANSACAO", nI) $ "SOLICITA_STATUS_AUTORIZACAO"
												cNumAut := PTrazSolAut(cNumAut)
											Else
												cNumAut := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
											EndIf
											lAchouNAut := .T.
										endIf
									endIf
								EndIf

								If !Empty(cNumAut)
									If !lAchouNAut
										PLSLOGX(STR0132+cNumAut+STR0003,.F.,,,"2906") //"Guia não encontrada -> ( "###" ) "
									Else

										If (cTpTran == "SOLIC_STATUS_PROTOCOLO" .OR. cTpTran == "SOLICITA_STATUS_AUTORIZACAO")

											// Se for atendimento de intercambio devolve a matricula antiga
											cAteRN := If(BEA->BEA_ATERNA=='1','S','N')
											aDadUsrRet := PLSDADUSR(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),'1',.F.,dDatabase)   
											If len(aDadUsrRet) >= 45 .And. aDadUsrRet[45] <> PlsIntPad()
												If !Empty(BEA->BEA_MATANT)
											 		cMatric := BEA->BEA_MATANT
												ElseIf !Empty(aDadUsrRet[3])
													cMatric := aDadUsrRet[3]
												Else
													cMatric := aDadUsrRet[2]
												EndIf	
											Else
												cMatric := BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
											EndIf
											cNomeUsu := BEA->BEA_NOMUSR

											If (cTpTran == "SOLIC_STATUS_PROTOCOLO")
												dDatPro := BEA->BEA_DTDIGI //Data de envio do lote de guias de cobrança para a operadora
												if(len(aRetTrans[nI]) > 9)
													cStTiss := aRetTrans[nI,10]
												endIf
											ElseIf (cTpTran == "SOLICITA_STATUS_AUTORIZACAO")
												dDatPro := BEA->BEA_VALSEN //Data correta da validade na liberação 
											EndIf
										Else
											dDatPro := BEA->BEA_DATPRO
										EndIf
										dDatAtend := BEA->BEA_DATPRO
									EndIf
								Else
									PLSLOGX(STR0132+cNumAut+STR0003,.F.,,,"2906") //"Guia não encontrada -> ( "###" ) "
								EndIf
							EndIf
						EndIf

						aRetAux := {}
						aAdd(aRetAux, cTpCab) 					//1
						aAdd(aRetAux, cCCCab) 					//2
						aAdd(aRetAux, cCodRda) 				//3
						aAdd(aRetAux, cNomRda) 				//4
						aAdd(aRetAux, cTpCab) 					//5
						aAdd(aRetAux, cCCCab) 					//6
						aAdd(aRetAux, cMatric) 				//7
						aAdd(aRetAux, cNomeUsu) 				//8
						aAdd(aRetAux, cNumeSeq) 				//9
						aAdd(aRetAux, cNumAut) 				//10
						aAdd(aRetAux, lHonorario) 				//11
						aAdd(aRetAux, lResIntern) 				//12
						aAdd(aRetAux, cNumeSeq) 				//13
						aAdd(aRetAux, Iif(ValType(dDatPro) == "D",dDatPro, PLSAJUDAT(dDatPro))) 		//14
						aAdd(aRetAux, cCodRda) 				//15
						aAdd(aRetAux, cCNES)					//16
						aAdd(aRetAux, 0)//17
						aAdd(aRetAux, cAteRN)//18
						aAdd(aRetAux, cStTiss) // 19
						aAdd(aRetAux, dDatAtend) //20
						aAdd(aDadosRet, aRetAux)
					Next

					For nI := 1 To Len(aDadosRet)
						aAdd(aRet, { ;
							Iif(Len(aDadosRet) < nI, aDadosRet[Len(aDadosRet)], aDadosRet[nI]), ;
							Iif(Len(aRetTrans) == 0, Nil, Iif(Len(aRetTrans) < nI, aRetTrans[Len(aRetTrans)], aRetTrans[nI])) ;
							})
					Next

				EndIf
			Endif	
		EndIf

		PLSLOGX("",,.F.)
		PLSLOGX(STR0072+AllTrim( Str( (Seconds()-nIniSeg)/60,12,3) )+STR0003,,.F.) //### //### //"Duração do processamento da guia (checagem de regras e gravação da guia) ( "###" ) "
		PLSLOGX("",,.F.)
	EndIf

// Retorno com dados mais nao consegue processar
	If Len(aMatM)>0 .And. Len(aRet)==0
		aRet := {{}}
	EndIf
	
	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Finalizando PLSTPTRAN (PLSA973)", "tissonanalise.log")
    EndIf
    
Return( { aRet,cTranRet,cNumeSeq,cOrigem,cTagOri,cNomApl,cVerApl,cFabApl, aRetTrans, cGuia } )

/*/{Protheus.doc} PLSMOSPRC
Mostra dados do processamento da guia
@type function
@author TOTVS
@since 22.05.07
@version 1.0
/*/
Function PLSMOSPRC(aMatM,aRet,cCodPeg)
	LOCAL nI,nY
	LOCAL lCab	  := .T.
	LOCAL lIntRes := .F.
	LOCAL aMatCri := {}
	LOCAL aMatInf := {}
	LOCAL aRetCri := {}
	LOCAL cMsgS	  := ""
	LOCAL cMsgN	  := ""
	LOCAL cMsgAT  := ""
	LOCAL cMsgNT  := "NAO AUTORIZADA"   //"NAO AUTORIZADA"
	LOCAL cMsgAP  := "AUTORIZACAO PARCIAL"  //"AUTORIZACAO PARCIAL"
	LOCAL nTotNGrv:= 0
	LOCAL nTotAP  := 0
	LOCAL nTotAT  := 0
	LOCAL nTotNT  := 0
	LOCAL nVAprTot:= 0
	LOCAL cTexto := ""
	LOCAL cCodInt := PlsIntPAd()
	DEFAULT aMatM :={}
	DEFAULT aRet  :={}


	BXX->(DbSetORder(6))
	If !Empty(cCodPeg) .And. BXX->(MsSeek(xFilial("BXX")+cCodInt+cCodPeg))
		BXX->(Reclock("BXX",.F.))

		If Len(aRet) > 0
			If Len(aRet[1]) > 0


				cTexto := "****** INICIO - INFORMACAO DO PROCESSAMENTO DO ARQUIVO ******"+CRLF
				cTexto += ""+CRLF

				For nI:=1 To Len(aRet)

					If aRet[nI,1,11] .Or. aRet[nI,1,12]
						lIntRes := .T.
						cMsgN   := "GUIA NAO ATUALIZADA"
						cMsgS   := "GUIA ATUALIZADA"
						cMsgAT  := ""
						cMsgNT  := ""
						cMsgAP  := ""
					Else
						cMsgN   := "GUIA NAO GRAVADA"
						cMsgS   := "GUIA GRAVADA"
						cMsgAT  := ""
						cMsgNT  := ""
						cMsgAP  := ""
					EndIf
					If Len(aRet[nI,2]) > 0
						cTexto +=  IiF( Empty(aRet[nI,2,2]) , cMsgN+"  --  " , cMsgS + STR0084 + aRet[nI,2,2] + STR0085 )  + IiF( lIntRes , "" , Iif( aRet[nI,2,1] .And. Len(aRet[nI,2,4] ) > 0 , cMsgAP , IiF( aRet[nI,2,1] , cMsgAT , cMsgNT ) ) )+CRLF
						If Empty(aRet[nI,2,2])
							nTotNGrv++
						EndIf
						If aRet[nI,2,1] .And. Len(aRet[nI,2,4])>0
							nTotAP++
						ElseIf aRet[nI,2,1]
							nTotAT++
						Else
							nTotNT++
						EndIf

						aMatInf := aRet[nI,2,10]
						If Len(aMatInf)>0
							cTexto += Space(3)+"** INFORMACOES COMPLEMENTARES"+CRLF
							For nY := 1 To Len(aMatInf)
								If !Empty(AllTrim(aMatInf[nY,2]))
									If AllTrim(aMatInf[nY,2]) == "NIL"
										cTexto +=  Space(3) + AllTrim(aMatInf[nY,1])+CRLF
									Else
										If AllTrim(aMatInf[nY,1]) == "VALOR TOTAL APR" //"VALOR TOTAL APR"
											cTexto +=   Space(3) + AllTrim(aMatInf[nY,1]) + Space( 25-Len( AllTrim(aMatInf[nY,1]) ) )+STR0088+AllTrim(TransForm( Val( aMatInf[nY,2] ),PLSMONEY) )+STR0089 +CRLF //### //### //" - [ "###" ]"
											nVAprTot += Val( aMatInf[nY,2] )
										Else
											If AllTrim(aMatInf[nY,1]) == 'NUM. GUIA PRESTADOR' .And. Len(aRet[nI,2,4])>0
												cTexto +=  Space(3) + AllTrim(aMatInf[nY,1]) + Space( 25-Len( AllTrim(aMatInf[nY,1]) ) )+STR0088+AllTrim(aMatInf[nY,2])+STR0089+CRLF   //### //### //" - [ "###" ]"
											Else
												cTexto +=  Space(3) + AllTrim(aMatInf[nY,1]) + Space( 25-Len( AllTrim(aMatInf[nY,1]) ) )+STR0088+AllTrim(aMatInf[nY,2])+STR0089+CRLF  //### //### //" - [ "###" ]"
											EndIf
										EndIf
									EndIf
								EndIf
							Next
							cTexto +=""+CRLF
						EndIf

						aMatCri := aRet[nI,2,4]
						lCab 	:= .T.
						For nY := 1 To Len(aMatCri)
							If !Empty( aMatCri[nY,2] )
								aRetCri := PLSRETCRI(aMatCri[nY,2])
								If lCab
									cTexto +=""+CRLF
									cTexto +=Space(3)+STR0090+CRLF   //"** CRITICA(S)"
									cTexto +=""+CRLF
									lCab := .F.
								EndIf
								cExiCri := aMatCri[nY,2]
								cTexto +=Space(3)+STR0091+AllTrim(aMatCri[nY,4])+"-"+AllTrim(aMatCri[nY,5])+STR0092+AllTrim(aMatCri[nY,2])+STR0023+AllTrim(aMatCri[nY,3])+CRLF //###### //###### //###### //"Sistema -> ("###") -  "###" - "
								cTexto +=Space(3)+STR0093+Space( 5+Len( AllTrim(aMatCri[nY,4])+"-"+AllTrim(aMatCri[nY,5]) ) )+AllTrim(aRetCri[1,1]+STR0023+aRetCri[1,2])+CRLF //### //### //### //"Tiss    -> "###" - "
							EndIf
						Next
						cTexto +=""+CRLF
					Else
						cTexto += cMsgN + "  --  " + IiF( lIntRes , "" , cMsgNT )+CRLF
						nTotNGrv := Len(aMatM)
					EndIf

				Next
				cTexto +=""+CRLF
				cTexto +="Numero de nota(s) no arquivo     ( "+StrZero(Len(aMatM),10)+STR0003+CRLF //"Numero de nota(s) no arquivo     ( "###" ) "
				If lIntRes
					cTexto +="Numero de nota(s) Atualizada(s)     ( "+StrZero(Len(aMatM)-nTotNGrv-nTotNT,10)+STR0003+CRLF //"Numero de nota(s) Atualizada(s)     ( "###" ) "
					cTexto +="Numero de nota(s) nao Atualizada(s) ( "+StrZero(nTotNGrv+nTotNT,10)+STR0003+CRLF //"Numero de nota(s) não Atualizada(s) ( "###" ) "
				Else
					cTexto +="Numero de nota(s) Gravada(s)     ( "+StrZero(Len(aMatM)-nTotNGrv,10)+STR0003+CRLF //"Numero de nota(s) Gravada(s)     ( "###" ) "
					cTexto +="Numero de nota(s) nao Gravada(s) ( "+StrZero(nTotNGrv,10)+STR0003+CRLF //"Numero de nota(s) não Gravada(s) ( "###" ) "
					cTexto +="--------------------------------------------------------------"+CRLF//"--------------------------------------------------------------"
					cTexto +="Total Apr. Arqv.      ( " + AllTrim(TransForm(BXX->BXX_VLRTOT,PLSMONEY)) + STR0003 + CRLF //"Total Apr. Arqv.      ( "###" ) "
				EndIf
				cTexto +=""+CRLF
				cTexto +="****** FIM - INFORMACAO DO PROCESSAMENTO DO ARQUIVO ******"+CRLF//"****** FIM - INFORMAÇÃO DO PROCESSAMENTO DO ARQUIVO ******"
				cTexto +=""+CRLF

				RestArea(BXX->(GetArea()))
				MSMM(,TamSX3("BXX_DETREG")[1],,ansiToOem(cTexto),1,,,"BXX","BXX_CODREG")
			Endif
		Else
			cTexto +=""+CRLF
			cTexto +="****** NADA FOI PROCESSADO ******"+CRLF//"****** NADA FOI PROCESSADO ******"
			cTexto +=""+CRLF

			RestArea(BXX->(GetArea()))
			MSMM(,TamSX3("BXX_DETREG")[1],,ansiToOem(cTexto),1,,,"BXX","BXX_CODREG")

		EndIf
		BXX->(MsUnlock())
	Endif


Return()


/*/{Protheus.doc} PLSIVRDA
Verifica a rda e inclui o solicitante
@type function
@author TOTVS
@since 25.06.08
@version 1.0
/*/
Function PLSIVRDA(cCodRP,nIdx,cES,aDados)
	DEFAULT cES := ""

// Verifica a rda
// Ponto de Entrada PLSCODRP para se verificar se o cCodRP foi passado errado
// caso tenha sido passado errado o PE retorna a infomação desejada
	If Existblock("PLSCODRP")
		cCodRP := ExecBlock("PLSCODRP",.F.,.F.,{cCodRP,nIdx})
	Endif
	If !Empty(cCodRP)
		BAU->( DbSetOrder( nIdx ) ) //BAU_FILIAL + BAU_CPFCGC ou  BAU_CODIGO ou BAU_CODBB0
		If BAU->( MsSeek( xFilial("BAU")+cCodRP ) )

			If aDados <> NIL
				AaDd( aDados, {"CODRDA",BAU->BAU_CODIGO } )
				AaDd( aDados, {"NOMRDA",AllTrim(BAU->BAU_NOME) } )
				AaDd( aDados, {"TPCRDA",AllTrim(BAU->BAU_TIPPE) } )
				AaDd( aDados, {"CCRDA",AllTrim(BAU->BAU_CPFCGC) } )
			EndIf

			If !Empty(cES) .and. !Empty(BAU->BAU_CODBB0)
				PLSIVPRO(BAU->BAU_CODBB0,"","","",1,cES,aDados)
				If !BAU->( Found() ) // esse item foi tratado para os casos de prestador pessoa fisica onde bau_codbb0 assim não ocasionando a critica X24, item despocionando
					BAU->( MsSeek( xFilial("BAU")+cCodRP ) )
				Endif
			EndIf

		EndIf
	EndIf

Return

/*/{Protheus.doc} PLSIVPRO
Verifica o profissional
#tissver 2.x,3.x

@type Function
@author Alexander Santos
@since 17/03/2007
@version 1.0
/*/
Function PLSIVPRO(cCodProf,cSigla,cCrm,cUf,nIdx,cES,aDados,lInc,cCbos,lOdonto)
	LOCAL cChave  := ""
	LOCAL nOrdBAU := BAU->(IndexOrd())
	LOCAL nRecBAU := BAU->(Recno())
	DEFAULT cES   := ""
	DEFAULT lInc  := .F.
	DEFAULT cCbos := ''
	Default lOdonto	:= .F.
	cUf    := upper(padr(cUf,TamSX3("BB0_ESTADO")[1]))
	cCrm   := upper(padr(cCrm,TamSX3("BB0_NUMCR")[1]))
	cSigla := upper(padr(cSigla,TamSX3("BB0_CODSIG")[1]))

// Definindo a Chave
	If nIdx == 4
		cChave := cUf+cCrm+cSigla
	Else
		cChave := cCodProf
		If Empty(cChave) .and. !Empty(cUf) .and. !Empty(cCrm) .and. !Empty(cSigla)
			cChave := cUf+cCrm+cSigla
			nIdx   := 4
		Endif
	EndIf

// Verifica o profissional
	If !Empty(cChave)
		BB0->( DbSetOrder( nIdx ) ) //BB0_FILIAL + BB0_CODIGO ou BB0_CGC ou BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
		If BB0->( MsSeek( xFilial("BB0")+cChave ) )
			If cES == "S" .And. aDados <> NIL     //Solicitante
				AaDd( aDados, { "OPESOL" , BB0->BB0_CODOPE } )
				AaDd( aDados, { "CDPFSO" , BB0->BB0_CODIGO } )
			ElseIf cES == "E" .And. aDados <> NIL //Executante
				cCdPfEx1 := BB0->BB0_CODIGO
				AaDd( aDados, { "CDOPEX" , BB0->BB0_CODOPE } )
				AaDd( aDados, { "CDPFEX" , cCdPfEx1 } )
			EndIf
		EndIf
	EndIf
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
Return

/*/{Protheus.doc} PLSXPROF
Verifica o profissional/RDA
#tissver 2.x,3.x

@type Function
@author Alexander Santos
@since 25/06/2008
@version 1.0
/*/
Function PLSXPROF(cTipo,cCodRP,cNum,cNumImp,cOrigem,nIdx,cData,cHora,cES,aDados,aMatC)
	DEFAULT cES    := ""
	DEFAULT aDados := {}
	DEFAULT aMatC  := {}

	If !Empty(cCodRP)

		If !BAU->( Found() )

			If GetNewPar("MV_PCRDXML",'1') == '1'//se este parametro estiver ligado se ele nao acha a rda ele sempre pega a rda do cabecalho
				If Len(aMatC) <> 0
					cRet := AllTrim( PLSPCONGR("CPF,CNPJ,CODIGOPRESTADORNAOPERADORA","CABECALHO\ORIGEM\CODIGOPRESTADORNAOPERADORA",aMatC) )
					cRet := padr(cRet,TamSX3("BAU_CPFCGC")[1])
					nIdx 	:= 4
					If Empty(cRet)
						cRet := AllTrim( PLSPCONGR("cnpjPagador","CABECALHO\ORIGEM",aMatC) )
						cRet := padr(cRet,TamSX3("BAU_CPFCGC")[1])
						If Empty(cRet)
							cRet     := PLSPCONGR("CODIGOPRESTADORNAOPERADORA","CABECALHO\ORIGEM\CODIGOPRESTADORNAOPERADORA",aMatC)
							cRet     := padr(cRet,TamSX3("BAU_CPFCGC")[1])
							nIdx 	 := 1
						EndIf
					EndIf

					BAU->( DbSetOrder( nIdx ) ) //BAU_FILIAL + BAU_CPFCGC ou  BAU_CODIGO ou BAU_CODBB0
					BAU->( MsSeek( xFilial("BAU")+cRet ) )
				Endif
			Endif

			If ExistBlock("PLSXMLPROF") .and. !BAU->(Found())

				If cTipo == "R"
					If cES == "S"
						cTipo := "S"
					ElseIf cES == "E"
						cTipo := "CE"
					EndIf
				EndIf

				cCodRP := ExecBlock( "PLSXMLPROF",.F.,.F.,{cTipo,cCodRP,cNum,cNumImp,cOrigem,nIdx,PLSAJUDAT(cData),cHora,aMatC} )

				PLSIVRDA(cCodRP,1,cES,aDados)

				If !BAU->( Found() )
					PLSIVRDA(GetNewPar("MV_PLSRDAG",'999999'),1,cES,aDados) //assumo RDA generica
				Endif

			Endif
		Endif
	EndIf

Return

/*/{Protheus.doc} PLSXSCU
Verifica o crm.
@type function
@author TOTVS.
@since 25.06.08.
@version 1.0
/*/
Function PLSXSCU(cCodProf,cSigla,cCrm,cUf,cES,aDados,cObsoleto,lInc,cNome,cCbos,cData,aMatM)
	LOCAL aRetProf   	:= {}
	local aRetFnc		:= {}
	LOCAL lCriou	 	:= .F.
	LOCAL aRet	 	 	:= {.t.,{}}
	local lIncluDir		:= GetNewPar("MV_PLINCSO",'1') == "1"
	local lExtPEInc		:= ExistBlock("PLSXMLSCU")
	DEFAULT cCodProf 	:= ""
	DEFAULT cObsoleto	:= nil
	DEFAULT lInc	 	:= .T.
	DEFAULT cNome	 	:= ""
	DEFAULT cCbos	 	:= ""
	DEFAULT cData	 	:= ""
	DEFAULT aMatM	 	:= {}


	cCrm  	  := UPPER(padr(cCrm,TamSx3('BB0_NUMCR')[1]))   //atencao a alteracao que havia sido feita aqui causou efeito colateral na importacao xml.. nao voltar..
	cSigla	  := UPPER(padr(cSigla,TamSx3('BB0_CODSIG')[1]))
	cUf		  := UPPER(padr(cUf,TamSx3('BB0_ESTADO')[1]))
	cCodOpe   := PlsIntPad()

	If !Empty( AllTrim(cSigla)+AllTrim(cCrm)+AllTrim(cUf) ) .Or. !Empty(cCodProf)

		if ( lIncluDir .or. !lExtPEInc )
			cNome := iif(Empty(cNome),"PROFISSIONAL GENERICO XML", cNome)
			aRetFnc := PlSveProfAll( cNome, cSigla, cUf, cCrm, cCodOpe, '', '2', '', {} )
			lCriou := aRetFnc[1]

		ELSEIF lExtPEInc
			aRetProf := ExecBlock( "PLSXMLSCU",.F.,.F.,{cSigla,cCrm,cUf,cCodProf,cEs,cNome,cCbos} )

			cSigla 	:= UPPER(padr(aRetProf[1], TamSx3('BB0_CODSIG')[1]))
			cCrm 	:= UPPER(padr(aRetProf[2], TamSx3('BB0_NUMCR')[1])) 
			cUf 	:= UPPER(padr(aRetProf[3], TamSx3('BB0_ESTADO')[1]))

			If Len(aRetProf)>3
				cCbos 	:= aRetProf[4]
			Endif

			//Para garantir que criou/alterou e está posicionado no item certo, para gravar BQ1
			If !Empty(cUf) .and. BB0->( MsSeek( xFilial("BB0")+cUf+cCrm+cSigla+cCodOpe ) )
				lCriou := .T.
			endif
		ENDIF	

		//Apos criar o Profissional de Saude, alimenta a tabela BQ1 (Especialidades Profissionais de Saude) com a especialidade enviada no arquivo.
		If lCriou .and. PLSALIASEXI('BQ1') .and. !Empty(cCbos)
			lCria := .f.

			BQ1->(DbSetORder(1))
			BTQ->(DbSetOrder(1))
			cEspec	:= AllTrim(PLSVARVINC('24','BAQ',cCBOS))
			lCria :=  !BQ1->(MsSeek(xFilial('BQ1')+BB0->BB0_CODIGO+cEspec)) .and. BTQ->(MsSeek(xFilial("BTQ")+"24"+cCBOS))

			If lCria
				PlSveEspQ1(cCodOpe, BB0->BB0_CODIGO, cEspec, '', cCBOS, {})
			Endif

		Endif

		PLSIVPRO("",cSigla,cCrm,cUf,4,cES,aDados)

	EndIf

Return aRet

/*/{Protheus.doc} PLSXPAD
Verifica o codpad e procedimento.
@type function
@author TOTVS
@since 25.06.08
@version 1.0
/*/
Function PLSXPAD(cCodPad,cCodPro,cDescric,cTpProc,cTipGui,cVersao,dDatRea)
	LOCAL aMatPad := {}
	DEFAULT cTpProc := ""
	DEFAULT cTipGui := '08'
	DEFAULT cVersao := GetNewPar("MV_TISSVER","2.02.03")
	DEFAULT dDatRea := cTod("")

	IF Empty(cTpProc)
		BR8->(DbSetOrder(1))
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
			cTpProc := BR8->BR8_TPPROC
		Endif
	Endif

	If ExistBlock("PLSXMLPAD")
		aMatPad := ExecBlock( "PLSXMLPAD",.F.,.F.,{cCodPad,cCodPro,cDescric,cTpProc,cTipGui,cVersao,dDatRea} )
		If ValType(aMatPad) == "A"
			cCodPad  := aMatPad[1]
			cCodPro  := padr(aMatPad[2],tamsx3("BR8_CODPSA")[1])
			cDescric := If(Len(aMatPad)>=3,aMatPad[3],cDescric)
		Else
			cCodPad := aMatPad
		EndIf
	EndIf

Return


/*/{Protheus.doc} PLSVEB
Verifica elegibilidade
@type function
@author TOTVS
@since 25.06.08
@version 1.0
/*/
Function PLSVEB(aDados)
	Local dData 		:= PLSAJUDAT(PVLRTAGXML(aDados, "\CABECALHO\IDENTIFICACAOTRANSACAO\DATAREGISTROTRANSACAO"))
	Local cHora 		:= SubStr(PVLRTAGXML(aDados, "\CABECALHO\IDENTIFICACAOTRANSACAO\HORAREGISTROTRANSACAO"),1,8)
	Local cMatric 		:= PVLRTAGXML(aDados, "\VERIFICAELEGIBILIDADE\NUMEROCARTEIRA")
	Local cNomeUsu 	:= PVLRTAGXML(aDados, "\VERIFICAELEGIBILIDADE\NOMEBENEFICIARIO")
	Local cRegAns		:= PVLRTAGXML(aDados, "\CABECALHO\DESTINO\REGISTROANS")
	Local lVerCons      := GetNewPar("MV_PLCONEL","0") == "1"
	Local cCodCon       := ""
	Local aDadUsr       := {}
	Local aRetCons      := {}
	
// Dados da Operadora
	If !Empty(cRegAns)
		BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
		If !BA0->( MsSeek( xFilial("BA0")+cRegAns ) )
			PLSLOGX(STR0106+cRegAns+STR0107,.F.,,,"5006") //"Operadora não encontrada  -> ( "###" ) informação no  \CABECALHO\DESTINO "
		EndIf
	EndIf

	aRet := PLSA090USR(cMatric,dData,cHora,"BE1",.F.,.T.,nil,nil,nil,nil,"","",.T.,cNomeUsu,CtoD(""),,.T.)
	aRet := { aRet[1],"","",aRet[2],{},{},0,"","",{} }

	//Verifica elegibilidade da consulta
	if lVerCons .And. aRet[1]
	
		cCodCon := GetMV("MV_PLSCDCO")
		aDadUsr := PLSGETUSR()

		if !Empty(cCodCon) .And. len(aDadUsr) > 0 
			// Checa algumas regras
			aRetCons := PLSAUTP(Date(),;
						StrTran(Time(),":",""),;
						Subs(cCodCon,1,2),;
						Subs(cCodCon,3,16),;
						1,;
						aDadUsr,;
						0,;
						{},;
						"1",;
						.F.,;
						"",;
						.T.,;
						"1",;
						.F.,;
						"",;
						"",;
						subs(dtoc(Date()),1,4),;
						subs(dtoc(Date()),5,2))

			if len(aRetCons) > 0 .And. !aRetCons[1]
				aRet := { aRetCons[1],"","",iif(aRetCons[1],{},aRetCons[2]),{},{},0,"","",{} }
			endIf

		endIf	
	endIf

	If ExistBlock("PLSA973VAL")
          aRet := ExecBlock( " PLSA973VAL ",.F.,.F.,{aDados,aRet,dData,cHora}) 
          aRet := { aRet[1],"","",aRet[2],{},{},0,"","",{} }
    EndIf

Return( { aRet } )


/*/{Protheus.doc} PLSCGB
Cancela Guia
@type function
@author TOTVS
@since 29.10.13
@version 1.0
/*/
Function PLSCGB(aDados)
LOCAL nI			:= 1
LOCAL cCodRP		:= ""
LOCAL nIdx			:= 4
LOCAL cCodRda		:= ""
LOCAL cOpeMov		:= ""
LOCAL cNumAut		:= ""
LOCAL cNumAut2 		:= ""
LOCAL cMsg			:= ""
LOCAL cRet			:= ""
LOCAL cCodTpGuia 	:= ""
LOCAL cTipoGuia 	:= ""
LOCAL aRet			:= {}
LOCAL aRetAux		:= {}
LOCAL nCountTag 	:= PLCOUNTTAG({"\NUMEROGUIAPRESTADOR"}, aDados)
LOCAL lAchouNAut 	:= .F.
LOCAL lUnimeds   	:= IiF( AllTrim( GETNEWPAR("MV_PLSUNI","1") )=="1", .T. , .F. )
LOCAL cMotCanc   	:= ""
LOCAL lPLSTMLLIB	:= ExistBlock("PLSTMLLIB")

// RDA Contratada
cCodRP 	:= allTrim( PVLRTAGXML(aDados, "\DADOSPRESTADOR\CPFCONTRATADO,\DADOSPRESTADOR\CNPJCONTRATADO"))
cCodRP 	:= cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
nIdx	:= 4

if empty(cCodRP)
	cCodRP 	:= PVLRTAGXML(aDados, "\DADOSPRESTADOR\CODIGOPRESTADORNAOPERADORA")
	nIdx 	:= 1
endIf

BAU->( DbSetOrder( nIdx ) ) //BAU_FILIAL + BAU_CPFCGC ou  BAU_CODIGO ou BAU_CODBB0
if BAU->( MsSeek( xFilial("BAU") + cCodRP ) )
	cCodRda := BAU->BAU_CODIGO
endIf

// Codigo da Operadora
cRegAns  := PVLRTAGXML(aDados, "\CABECALHO\DESTINO\REGISTROANS")

if ! empty(cRegAns)
	
	BA0->( dbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
	if BA0->( MsSeek( xFilial("BA0")+cRegAns ) )
		cOpeMov := BA0->(BA0_CODIDE+BA0_CODINT)
	else
		PLSLOGX(STR0106+cRegAns+STR0107,.F.,,,"5006") //"Operadora não encontrada  -> ( "###" ) informação no  \CABECALHO\DESTINO "
	endIf
	
endIf

// Pegando dados da Guia
cCodTpGuia	:= PVLRTAGXML(aDados, "\TIPOGUIA")
cTipoGuia   := iIf( cCodTpGuia == "1", "Solicitação", iIf( cCodTpGuia=="2", "Faturamento", "" ) )

for nI := 1 to nCountTag

	cRet := ""
	cMsg := ""

	cNumAut	 := PVLRTAGXML(aDados, "NUMEROGUIAPRESTADOR", nI)
	cNumAut2 := PVLRTAGXML(aDados, "NUMEROGUIAOPERADORA", nI)
	
	if ! empty(cNumAut) .or. ! empty(cNumAut2)
		
		BEA->( dbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
		
		if ! BEA->( msSeek( xFilial("BEA") + cNumAut ) )
		
			if BEA->( msSeek( xFilial("BEA") + cNumAut2 ) )
				lAchouNAut 	:= .t.
				cNumAut 	:= cNumAut2
			endIf
			
		else
			lAchouNAut := .t.
		endIf
		
	else
		PLSLOGX(STR0132+cNumAut+STR0003,.F.,,,"2906") //"Guia não encontrada -> ( "###" ) "
	endIf

	// Procura pelo numero do impresso o numero da liberacao
	if lPLSTMLLIB
		cNumAut := execBlock( "PLSTMLLIB",.F.,.F.,{ cNumAut,cOpeMov,cCodRda,"","","" } )
	endIf

	// Posiciona na Guia
	if !lAchouNAut
		cRet 	:= "3" 		//Guia inexistente
		cMsg 	:= STR0131 	//"Guia inexistente"
	endIf

	//Verifica se e uma guia de intercambioe precisa realizar comunicacao PTU Online    
	if lUnimeds
		cMotCanc := GetNewPar("MV_PLCATPT","Solicitação  de cancelamento")
	endIf
	
	// processa a guia
	if empty(cMsg)
		
		if lOkXml
		
			cMsg := PLSA090CAN( .t., cMotCanc )

			// Verifica o processamento do cancelamento
			if empty(cMsg) .Or. cMsg == "A Guia ja esta CANCELADA!"
				cRet := "1" //Cancelado com sucesso
				cMsg := STR0133 + " Guia de [ "+cTipoGuia+" ]" //"Cancelado com sucesso"
			else
				cRet := "2" //Não cancelado
				cMsg := STR0134+cMsg+STR0089 + " Guia de [ "+cTipoGuia+" ]"  //"Não cancelado - [ "###" ]"
			endIf
			
			aRetAux := { {cRet,cMsg,"","","","",""} }
			
			aAdd(aRet, { Iif(cRet<>"1",.F.,.T.),cNumAut,cCodTpGuia,aRetAux,{},{},0,"","",{} } )
			
		endIf
		
	else
	
		aRetAux := { {cRet,cMsg,"","","","",""} }
		aAdd(aRet, { Iif(cRet<>"1",.F.,.T.),cNumAut,cCodTpGuia,aRetAux,{},{},0,"","",{} } )
		
	endIf
	
next

Return( aRet )


/*/{Protheus.doc} PLSSPB
Situacao do Protocolo
@type function
@author TOTVS
@since 29.10.13
@version 1.0
/*/
Function PLSSPB(aDados)
	LOCAL nIdx	   	:= 0
	LOCAL cCodRda 	:= ""
	LOCAL cCodRP	:= ""
	LOCAL cRegAns	:= ""
	LOCAL aRet		:= {}
	LOCAL aMatGui	:= {}
	LOCAL aValores	:= {}
	LOCAL nI 		:= 1
	LOCAL nCountTag := PLCOUNTTAG({"\NUMEROPROTOCOLO"}, aDados)
	LOCAL cTpTrans	:= PVLRTAGXML(aDados, "TIPOTRANSACAO")
	LOCAL cStTiss := ""

// RDA Contratada
	cCodRP := AllTrim( PVLRTAGXML(aDados, "\DADOSPRESTADOR\CPFCONTRATADO,\DADOSPRESTADOR\CNPJCONTRATADO"))
	cCodRP := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
	nIdx 	:= 4
	If Empty(cCodRP)
		cCodRP := PVLRTAGXML(aDados, "\DADOSPRESTADOR\CODIGOPRESTADORNAOPERADORA")
		nIdx 	:= 1
	EndIf

	BAU->( DbSetOrder( nIdx ) ) //BAU_FILIAL + BAU_CPFCGC ou  BAU_CODIGO ou BAU_CODBB0
	If BAU->( MsSeek( xFilial("BAU")+cCodRP ) )
		cCodRda := BAU->BAU_CODIGO
	EndIf


// Codigo da Operadora
	cRegAns  := PVLRTAGXML(aDados, "\CABECALHO\DESTINO\REGISTROANS")
	If !Empty(cRegAns)
		BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
		If BA0->( MsSeek( xFilial("BA0")+cRegAns ) )
			cOpeMov := BA0->(BA0_CODIDE+BA0_CODINT)
		Else
			PLSLOGX(STR0106+cRegAns+STR0107,.F.,,,"5006") //"Operadora não encontrada  -> ( "###" ) informação no  \CABECALHO\DESTINO "
		EndIf
	EndIf


// Numeros dos Protocolos
	If lOkXml
		SIX->( DbSetOrder(1) )
		If SIX->( MsSeek("BEA16") )
			For nI := 1 To nCountTag
				cNumPro := PVLRTAGXML(aDados, "\NUMEROPROTOCOLO", nI)
				cNumPro := cNumPro+Space( TamSX3("BEA_LOTGUI")[1]-Len(cNumPro) )

				BEA->( DbSetOrder(16) ) //BEA_FILIAL + BEA_OPERDA + BEA_CODRDA + BEA_LOTGUI
				If BEA->( MsSeek( xFilial("BEA")+cOpeMov+cCodRda+cNumPro ) )

					If BCI->( FieldPos("BCI_STTISS") ) > 0
						BCI->(dbSetOrder(15))
						if(BCI->(msSeek(xFilial("BCI")+BEA->BEA_LOTGUI)))
							cStTiss := BCI->BCI_STTISS
						else
							cStTiss := "7"
						endIf
					endIf

					While !BEA->( Eof() ) .And. AllTrim(BEA->(BEA_CODRDA+BEA_LOTGUI)) == AllTrim(cCodRda+cNumPro)

						lConSadt	:= IiF( Empty( AllTrim(BEA->(BEA_ANOINT+BEA_MESINT+BEA_NUMINT)) ),.T.,.F. )
						aMatGui		:= MontaGUIA( BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) , lConSadt)

						If (cTpTrans == "SOLIC_STATUS_PROTOCOLO")
					    //             (cCodOpe,    cRdaDe,       cRdaAte,       cAno,          cMes,          cClaPre, cLocRda , cNFSSDe, cNFSSAte,cNmTitPg,cPEGDe, cPEGAte)
							aRetDad := PLSDACM(PlsIntPad(), BEA->BEA_CODRDA, BEA->BEA_CODRDA, BEA->BEA_ANOAUT, BEA->BEA_MESAUT, , , , ,,BEA->BEA_CODPEG, BEA->BEA_CODPEG, .T.)

							aValores := {}
							aAdd(aValores, aRetDad[29])//29 Valor Processado Guia 1
							aAdd(aValores, aRetDad[30])//30 Valor Liberado Guia 2
							aAdd(aValores, aRetDad[31])//31 Valor Glosa Guia 3
							aAdd(aValores, aRetDad[33])//33 Valor Processado Fatura 4
							aAdd(aValores, aRetDad[34])//34 Valor Liberado Fatura 5
							aAdd(aValores, aRetDad[35])//35 Valor Glosa Fatura 6
							aAdd(aValores, aRetDad[36])//36 Valor Processado Protocolo 7
							aAdd(aValores, aRetDad[37])//37 Valor Liberado Protocolo 8
							aAdd(aValores, aRetDad[38])//38 Valor Glosa Protocolo 9
							if(!empty(cStTiss))
								aAdd(aValores, cStTiss)    // Status Protocolo Tiss 10
							endif
						EndIf
						aAdd(aMatGui, aValores)

						aAdd(aRet, aMatGui)

						BEA->( DbSkip() )
					EndDo
				Else
					PLSLOGX("Lote não encontrado -> ( "+cNumPro+" ) para este Prestador ( "+cCodRda+" ) ")
				EndIf
			Next
		Else
			PLSLOGX("Não existe o indice 16 na tabela BEA",.F.)
		EndIf
	EndIf

Return( aRet )


/*/{Protheus.doc} PLSSAB
Status Autorizacao
@type function
@author TOTVS
@since 25.10.13
@version 1.0
/*/
Function PLSSAB(aDados)
	LOCAL cRegAns	:= ""
	LOCAL cOpeMov	:= ""
	LOCAL cNumAut	:= ""
	Local cNuAutAux := ""
	LOCAL nI		:= 1
	LOCAL nCountTag := PLCOUNTTAG({"\IDENTIFICACAOSOLICITACAO\NUMEROGUIAPRESTADOR"}, aDados)
	LOCAL aRet		:= {}
	LOCAL lPLSTMLLIB := ExistBlock("PLSTMLLIB")
	LOCAL lFindGui  := .F.
	Local lSolStat	:= .F.
	Local lHaPenFin := .F. // Verifica se há pendencia financeira

// Dados da Operadora
	cRegAns		:= PVLRTAGXML(aDados, "\CABECALHO\DESTINO\REGISTROANS")
	If !Empty(cRegAns)
		BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
		If BA0->( MsSeek( xFilial("BA0")+cRegAns ) )
			cOpeMov := BA0->(BA0_CODIDE+BA0_CODINT)
		Else
			PLSLOGX(STR0106+cRegAns+STR0107,.F.,,,"5006") //"Operadora não encontrada  -> ( "###" ) informação no  \CABECALHO\DESTINO "
		EndIf
	EndIf

	For nI := 1 To nCountTag

	// Dados da Solicitacao
		cNumAut := PVLRTAGXML(aDados, "\IDENTIFICACAOSOLICITACAO\NUMEROGUIAPRESTADOR", nI)

	// Procura pelo numero do impresso o numero da liberacao
		If lPLSTMLLIB
			cNumAut := ExecBlock( "PLSTMLLIB",.F.,.F.,{ cNumAut,cOpeMov,"","","","" } )
		EndIf

	// Procura a Guia
		If !Empty(cNumAut)
			BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
			If BEA->( MsSeek( xFilial("BEA")+cNumAut ) )
				lFindGui := .T.
				If BEA->BEA_STATUS == '5' // Caso tenha pendencia financeira mudaremos o status
					lHaPenFin := .T.
				Endif	

			elseIf PVLRTAGXML(aDados, "\TIPOTRANSACAO", nI) $ "SOLICITA_STATUS_AUTORIZACAO"
				cNuAutAux := cNumAut
				BEA->(DbSetOrder(9)) //BEA_FILIAL+BEA_NUMIMP
				if BEA->( MsSeek( xFilial("BEA")+cNumAut ) ) 
					cNumAut  := PTrazSolAut(cNumAut)
					lFindGui := .T.
					lSolStat := .T.
					If BEA->BEA_STATUS == '5' // Caso tenha pendencia financeira mudaremos o status
						lHaPenFin := .T.
					Endif	
				Else 
					cNumAut  := cNuAutAux
				endIf

			EndIf

			if lFindGui
				lConSadt := Iif( Empty( AllTrim(BEA->(BEA_ANOINT+BEA_MESINT+BEA_NUMINT)) ),.T.,.F. )
				aAdd(aRet, MontaGUIA(cNumAut,lConSadt, lSolStat, lHaPenFin))
			else
				PLSLOGX(STR0132+cNumAut+STR0003,,,,"2906") //"Guia não encontrada -> ( "###" ) "
			endIf
		Else
			PLSLOGX(STR0132+cNumAut+STR0003,,,,"2906") //"Guia não encontrada -> ( "###" ) "
		EndIf
	Next

Return( aRet )

/*/{Protheus.doc} MontaGUIA
Monta dados da guia procedimento e criticas
@type function
@author TOTVS
@since 28.04.20
@version 1.0
/*/
Function MontaGUIA(cNumAut,lConSadt, lSolStat,lHaPenFin)
	LOCAL cSql    		:= ""
	LOCAL cCodGlo 		:= ""
	LOCAL cDesGlo 		:= ""
	LOCAL nI      		:= 0
	LOCAL cOpeMov 		:= IiF( lConSadt ,"OPEMOV", "CODOPE" )
	LOCAL cComp   		:= IiF( lConSadt ,"AUT", "INT" )
	LOCAL aAlias  		:= IiF( lConSadt ,{"BE2"}, {"BEJ","BQV"} )
	LOCAL aAliasC 		:= IiF( lConSadt ,{"BEG"}, {"BEL","BQZ"} )
	LOCAL aRet    		:= {}
	LOCAL aEventosAut	:= {}
	LOCAL aEventosNeg	:= {}
	LOCAL aCriticas 	:= {}
	LOCAL lExiAudit := .F.
	LOCAL cAudito   := ""

	Default lSolStat := .F.
	Default lHaPenFin:= .F.  // Verifica se há pendencia financeira

	BR8->( DbSetOrder(1) )//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN

// Pega os Procedimentos
	For nI := 1 To Len(aAlias)

		cAlias  := aAlias[nI]
		cAliasC := aAliasC[nI]

		lExiAudit := &( cAlias+"->( FieldPos('"+cAlias+"_AUDITO') )" ) > 0

		cSQL := "SELECT "+cAlias+"_SEQUEN,"+cAlias+"_CODPAD,"+cAlias+"_CODPRO,"+cAlias+"_QTDPRO,"+cAlias+"_QTDSOL,"+cAlias+"_STATUS "
		if lExiAudit
			cSQL += ","+cAlias+"_AUDITO "
		endIf
		cSQL += "FROM "+BE2->(RetSQLName(cAlias))+" WHERE "
		cSQL += cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "
		cSQL += cAlias+"_"+cOpeMov+" = '"+Subs(cNumAut,1,4)+"' AND "
		cSQL += cAlias+"_ANO"+cComp+" = '"+Subs(cNumAut,5,4)+"' AND "
		cSQL += cAlias+"_MES"+cComp+" = '"+Subs(cNumAut,9,2)+"' AND "
		cSQL += cAlias+"_NUM"+cComp+" = '"+Subs(cNumAut,11,8)+"' AND "
		cSQL += "D_E_L_E_T_ = ' '"
		PLSQuery(cSQL,"TRBSQL")

	// Set indice das Criticas
		&( cAliasC+"->( DbSetOrder(1) )" )

	// Area
		While ! TRBSQL->( Eof() )
			cSeqMov := &("TRBSQL->"+cAlias+"_SEQUEN")
			cCodPad := &("TRBSQL->"+cAlias+"_CODPAD")
			cCodPro := &("TRBSQL->"+cAlias+"_CODPRO")
			nQtdAut := &("TRBSQL->"+cAlias+"_QTDPRO")
			nQtdSol := &("TRBSQL->"+cAlias+"_QTDSOL")
			lAutori := Iif(&("TRBSQL->"+cAlias+"_STATUS")=="1",.T.,.F.)
			if lExiAudit
				cAudito := &("TRBSQL->"+cAlias+"_AUDITO")
			endIf	
			BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )

		// Eventos Autorizados
			If lAutori .and. !lHaPenFin
				AaDd(aEventosAut,{cSeqMov,cCodPad,cCodPro,nQtdSol,BR8->BR8_DESCRI,nQtdAut,"1"})
			Else
				if lExiAudit .and. !lHaPenFin
					AaDd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,BR8->BR8_DESCRI,nQtdAut,cAudito})
				else
					AaDd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,BR8->BR8_DESCRI,nQtdAut})
				endIf
			// Criticas
				If &( cAliasC+"->( MsSeek( '"+xFilial(cAliasC)+cNumAut+"' ) )" )
					While ! &(cAliasC+"->(Eof())") .And.;
							&(cAliasC+"->("+cAliasC+"_"+cOpeMov+"+"+cAliasC+"_ANO"+cComp+"+"+cAliasC+"_MES"+cComp+"+"+cAliasC+"_NUM"+cComp+")") == cNumAut .And. !Empty(&(cAliasC+"->"+cAliasC+"_CODGLO")) // colocado o !empty() por conta que rodava mais de uma vez dentro da mesma guia fazendo com que criasse a mesma crítica com o mesmo conceito.
						cCodGlo := &( cAliasC+"->"+cAliasC+"_CODGLO" )
						B53->(DbSetOrder(1)) //B53_FILIAL + B53_NUMGUI + B53_ORIMOV
						B72->(dbSetOrder(1)) //B72_FILIAL+B72_ALIMOV+B72_RECMOV+B72_SEQPRO+B72_CODGLO+B72_CODPAD+B72_CODPRO
						If B53->(DBSeek(xFilial("B53")+Iif(lSolStat, cNumAut, BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))) .And. ;
							B72->(DbSeek(xFilial("B72")+B53->B53_ALIMOV + B53->B53_RECMOV+cSeqMov)) //Seek nas duas tabelas pra reposicionar a B72 pela B53 e pegar o motivo de ter recusado.
							cCodGlo := B72->B72_MOTIVO
						EndIf
						If BCT->(DbSeek(xFilial("BCT") + Subs(cNumAut,1,4)+cCodGlo)) //Posicionamento no código da glosa na tabela BCT que vai buscar a descrição da crítica
							cDesGlo := BCT->BCT_DESCRI
							AaDd( aCriticas,{cSeqMov,cCodGlo,cDesGlo,cCodPad,cCodPro} )
						EndIf	
						&(cAliasC+"->(DbSkip())")
					EndDo
				EndIf
			EndIf

			TRBSQL->( DbSkip() )
		Enddo
		TRBSQL->( DbCloseArea() )
	Next


// Retorno
	aRet := {	Len(aEventosAut)>0,;									//1
	Iif(lSolStat, cNumAut, BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)),;	//2
	BEA->BEA_SENHA,;       									//3
	aCriticas,;            									//4
	aEventosAut,;          									//5
	aEventosNeg,;          									//6
	0,;		               									//7
	"",;            										//8
	"",;          											//9
	{}}               										//10

Return( aRet )

/*/{Protheus.doc} PLSAJUDAT
Ajusta Data
@type function
@author TOTVS
@since 28.04.08
@version 1.0
/*/
Function PLSAJUDAT(cData)

//Quando é subimissão de XML, esta passando em varios processamentos, e por ser publico, algum lugar esta alterando a tipagem
	If ValType(cData) == "D"
		Return(cData)
	EndIf

	dData := StrTran(cData,"-","")

	If At('/',dData) == 0
		If !Empty( dData ) .And. Empty( StoD( dData ) )
			dData := CtoD(Left(dData,2)+"/"+SubStr(dData,3,2)+"/"+Right(dData,4))
		Else
			dData := StoD( dData )
		EndIf
	Else
		dData := CtoD( dData )
	EndIf

Return(dData)

/*/{Protheus.doc} PLSPEGCON
Pega o conteudo do campo da matriz
@type function
@author TOTVS
@since 26.05.07
@version 1.0
/*/
Function PLSPEGCON(cVar,aDad,cCodPeg)
	LOCAL nPos
	LOCAL lObrig := ( Right(cVar,3) <> "_OP" )
	LOCAL lCampo := ( Left(cVar,3) == "CP_" )
	LOCAL cVal 	 := ""
	DEFAULT cCodPeg	:= ""

//Pesquisa na matriz e pega o valor
	nPos := aScan( aDad,{|x|AllTrim(x[1]) == AllTrim(cVar) } )
	If nPos > 0
		If Len( aDad[nPos] ) >= 2
			cVal := aDad[nPos,2]
			If Empty(cVal) .And. lCampo .And. lObrig
				cVal := "NIL"
			EndIf
		ElseIf lObrig
			cVal := "NIL"
		EndIf
	ElseIf lObrig
		cVal := "NIL"
	EndIf

Return cVal

/*/{Protheus.doc} PLSPCONGR
Pega o conteudo do campo da matriz e verifica origem
@type function
@author TOTVS
@since 26.05.07
@version 1.0
/*/
Function PLSPCONGR(cChave,cOrigem,aDad,cTp,lLimp,lAjus,lMat,cCodPeg,nLimitPes,lMatAntPto)
	LOCAL nI		:= 1
	LOCAL nPos		:= 0
	LOCAL cVal 		:= ""
	LOCAL aMatPes 	:= {}
	Local nZ		:= 0

	DEFAULT cTp		:= "C"
	DEFAULT lLimp	:= .F.
	DEFAULT lMat	:= .F.
	DEFAULT lAjus	:= .T.
	DEFAULT cCodPeg	:= ""
	DEFAULT nLimitPes := 0
	DEFAULT lMatAntPto:= .F.

//Encontra o próximo procedimento da guia. Caso não seja passado o parâmetro, não faz a verificação
	If cChave == "CODIGOPROCEDIMENTO" .AND. nLimitPes > 0

	//Se o valor não é o inicial, então iremos começas de onde paramos da outra vez
		nI := nLimitPes

		While ( nZ < 2 .AND. nI <= Len(aDad) )
			if aDad[nI][1] == "CODIGOPROCEDIMENTO" .AND. cOrigem $ aDad[nI][3]
				nZ++

			//Se somou no nZ duas vezes, então achou o próximo procedimento
				if nZ == 2
					exit
				EndIf
			EndIf
			nI++
		EndDo

	//Importante: para usar o nLimitPes no processo, passar o parâmetro por referência na chamado do PLSPCONGR
		nLimitPes := nI //Guarda a posição que comça o próximo procedimento. Caso não haja próximo, guarda o tamanho do array
	EndIf

//Implementa o delimitador
	If At(",",cChave) == 0
		cChave+=","
	EndIf

//Monta matriz de pesquisa
	aMatPes :=	PLSARRAY( cChave,"," )

//Verifica se a chave encontrada esta na origem correta
	For nI:=1 To Len(aMatPes[3])
		If ( nPos := aScan( aDad,{|x|AllTrim(x[1]) == AllTrim(aMatPes[3,nI]) .And. Iif( !Empty(cOrigem),AllTrim(cOrigem) $ AllTrim(x[3]),.T.) } ) ) > 0 .and. ;
				(nLimitPes == 0 .OR. nLimitPes == 1 .or. nPos < nLimitPes)
			cVal := AllTrim(aDad[nPos,2])
			If cTp == "E"
				cVal := AllTrim(aDad[nPos,1])
			EndIf
			If lLimp
				aDad[nPos,1] := "*"+aDad[nPos,1]
			EndIf
			Exit
		EndIf
		If !Empty(cVal)
			Exit
		EndIf
	Next

// Retira caracteres especiais
	If !lMatAntPto //Excessão para caso de matrículas antigas com pontuação
		cVal := alltrim(fwcutoff(cVal))
		If lAjus
			cVal := PLSDELIM(cVal)
		EndIf
	Endif

Return( IiF(lMat,{cVal,nPos},cVal) )

/*/{Protheus.doc} PLSDELIM
Retira Caracteres especiais
@type function
@author TOTVS
@since 31.05.07
@version 1.0
/*/
Function PLSDELIM(cString,cDecimal)
	LOCAL nI
	LOCAL nTam
	LOCAL cCar       := ""
	LOCAL cCaracter  := "!@#$%¨&*()_+{}^~><:;/][|\.',-"
	DEFAULT cDecimal := ""

//Verifica se foi informado com uma ou duas posicoes
	If !Empty(cDecimal)
		nPosV := Len(SubStr(cString,RAT(",",cString),Len(cString)))
		nPosP := Len(SubStr(cString,RAT(".",cString),Len(cString)))
		nTam := Iif(nPosP==nPosV,0,Iif(nPosP<nPosV, nPosP-1 , nPosV-1 ))
	EndIf

//Retira caracteres
	For nI:=1 To Len(cCaracter)
		cCar 	:= AllTrim( SubStr(cCaracter,nI,1) )
		cString := StrTran( cString,cCar,"" )
	Next

//Para valores com decimais
	If !Empty(cDecimal)
		cString := Left(cString,Len(cString)-nTam) + cDecimal + Iif( Empty(Right(cString,nTam)),"00",Right(cString,nTam) )
	EndIf

Return(cString)

/*/{Protheus.doc} PLSPROCRES
Monta xml de retorno
@type function
@author TOTVS
@since 12.05.07
@version 1.0
/*/
Function PLSPROCRES(aRetZ,cEncod,lFault,cCodErro,cDesErro,cObsErro,cFTmp,cRdaOri,cDirOnline,lOnL,aDados, aDadRel)
LOCAL nI,nY      	:= 0
LOCAL nCont			:= 0
LOCAL lCriCab 	 	:= .F.
LOCAL lCriDir	 	:= .T.
LOCAL lInc		 	:= .T.
LOCAL lFaultLoc  	:= .F.
LOCAL cTpCab   		:= ""
LOCAL cCCCab	 	:= ""
LOCAL cArqRet	 	:= ""
LOCAL cHash			:= ""
LOCAL cRda	  	 	:= ""
LOCAL cNomeRda 		:= ""
LOCAL cMatric 	 	:= ""
LOCAL cNomeUsu	 	:= ""
LOCAL cNumeLot	 	:= ""
LOCAL cNumAut 	 	:= ""
LOCAL cNumGui 	 	:= ""
LOCAL cNumSen 		:= ""
LOCAL cAteRN		:= ""
LOCAL aMatAut 	 	:= ""
LOCAL aMatNeg 	 	:= ""
LOCAL cStatus	 	:= ""
LOCAL cNumeAux	 	:= ""
LOCAL cVersao    	:= StrTran(TISVERS,"_",".")
LOCAL cTranRet	 	:= SubStr(aRetZ[2],1,At("=",aRetZ[2])-1)
LOCAL cTagRet	 	:= SubStr(aRetZ[2],At("=",aRetZ[2])+1)
LOCAL cOrigem	 	:= aRetZ[4]
LOCAL cTagOri	 	:= aRetZ[5]
LOCAL cData   	 	:= DtoS(Date())
LOCAL dDatPro 	 	:= SToD("")
LOCAL cTime   	 	:= Time()
LOCAL aMatCri	 	:= {}
LOCAL aMatAux    	:= {}
LOCAL aRet		 	:= {}
LOCAL aTrb		 	:= {}
LOCAL aValores		:= {}
LOCAL cNumeSeq 		:= aRetZ[3]
LOCAL cNomApl  		:= Iif(lVerTISS,aRetZ[6],"")
LOCAL cVerApl	 	:= Iif(lVerTISS,aRetZ[7],"")
LOCAL cFabApl	 	:= Iif(lVerTISS,aRetZ[8],"")
LOCAL cTipoGuia 	:= ""
Local cTipGui		:= '01'
Local nVlrUnit		:= 0
local nVlrProcLot	:= 0
local nVlrGlosLot	:= 0
local nVlrLibeLot	:= 0
Local cObs 			:= ""
local cTpGuia       := ""
local dValSen
local lPLSOBSXML 	:= Existblock("PLSOBSXML")   
local dDtVaSe    	:= GetNewPar("MV_PLPRZLB",30)
local lDadValPTU 	:= .F.
Local dDatAtend     := Stod("")
local cNomVar		:= ""
local aDadErr		:= {aRetZ,cEncod,lFault,cCodErro,cDesErro,cObsErro,cFTmp,cRdaOri,cDirOnline,lOnL,aDados, aDadRel}
local cDtHrEvt		:= PLSRetTime()
local cNomeSoc		:= ''
local cNumeroCNS    := ' '
local cGuia	 		:= Iif(len(aRetZ) >= 10 .and. !Empty(aRetZ[10]), aRetZ[10], "")

DEFAULT cEncod		:= "ISO-8859-1"
DEFAULT lFault   	:= .F.
DEFAULT cCodErro 	:= "9999"
DEFAULT cDesErro 	:= ""
DEFAULT cObsErro 	:= ""
DEFAULT cFTmp    	:= cFileTmp
DEFAULT cRdaOri  	:= PlsIntPad()
DEFAULT lOnL	  	:= lOnline
DEFAULT cDirOnline	:= cDirOnl
Default aDadRel		:= {}

lNoGerFil := iif( (FwIsInCallStack("ProcOnLine") .and. FwIsInCallStack("HttpSoapFault")), .f., lNoGerFil)

If lLogTissOn
	PlsPtuLog(PLSRetTime() +" - Iniciando PLSPROCRES (PLSA973)", "tissonanalise.log")
EndIf
// Implementa mensagens informativas
	If !lFault

		For nI:=1 To Len(aResultado)

		// Pega mensagens informativas
			If aResultado[nI,2] == 2
				If !Empty(aResultado[nI,1])
					cObsErro += AllTrim(aResultado[nI,1])+", "
				EndIf
			//seleciona sempre o primeiro codigo de erro que encontrar
				If !Empty(aResultado[nI,5]) .AND. Empty(cCodErro)
					cCodErro := aResultado[nI,5]
				EndIf

		// Pega erro no processamento
			ElseIf aResultado[nI,2] == 4
				If !Empty(aResultado[nI,1])
					cDesErro += AllTrim(aResultado[nI,1])+", "
				EndIf
			//seleciona sempre o primeiro codigo de erro que encontrar
				If !Empty(aResultado[nI,5]) .AND. Empty(cCodErro)
					cCodErro := aResultado[nI,5]
				EndIf
			EndIf
		Next

		cDesErro := AllTrim(SubStr(Left(cDesErro,Len(cDesErro)-2),1,500))
		cObsErro := AllTrim(SubStr(Left(cObsErro,Len(cObsErro)-2),1,240))

	// Se existe mensagem de erro
		If !Empty(cDesErro)
			lFault := .T.
		EndIf

	// Titulo do erro
		If Empty(cDesErro) .And. !Empty(cObsErro)
			lFaultLoc:= .T.
			cDesErro := "Mensagem Informativa"
		ElseIf !Empty(cDesErro) .And. Empty(cObsErro)
			cObsErro := "Observacao nao informada"
		EndIf

	// Pega somente os dados
		aRet := aRetZ[1]
	EndIf

// Redefine Variaveis
	cNumeLot := cNumeSeq
	cRda	 := cRdaOri
	cFileTmp := cFTmp
	lOnline  := lOnL

// Se for on-line redefino as pastas
	If lOnL .And. At(cDirOnline,cDirProce)==0
		cDirOnl		:= cDirOnline
		cDirCaiEn	:= StrTran(cDirCaiEn,cDirRaiz,cDirRaiz+cDirOnl)
		cDirCaiSa	:= StrTran(cDirCaiSa,cDirRaiz,cDirRaiz+cDirOnl)
		cDirProce	:= StrTran(cDirProce,cDirRaiz,cDirRaiz+cDirOnl)
		cDirNaPro  	:= StrTran(cDirNaPro,cDirRaiz,cDirRaiz+cDirOnl)
		cDirLog		:= StrTran(cDirLog,cDirRaiz,cDirRaiz+cDirOnl)
	EndIf

//Dados que nao devem ser diferentes
	If !lFault .And. !Len(aDadRel) > 0
		If Len(aRet) > 0 .And. Len(aRet[1]) >= 2
			cTpCab   := AllTrim(aRet[1,1,1])
			cCCCab	 := AllTrim(aRet[1,1,2])
			
			if Len(aRet[1][1]) >= 9
				cNumeLot := AllTrim(aRet[1,1,9])
				if Len(aRet[1][1]) >= 13
					cNumeSeq := AllTrim(aRet[1,1,13])
					if Len(aRet[1][1]) >= 15
						cRdaOri	 := AllTrim(aRet[1,1,15])
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If Len(aRetZ) > 0 .And. Len(aRetZ[1]) > 0
			cTpCab   := AllTrim(aRetZ[1,1,1,1])
			cCCCab	 := AllTrim(aRetZ[1,1,1,2])
			
			if Len(aRetZ[1][1]) >= 9
				cNumeLot := AllTrim(aRetZ[1,1,1,9])
				if Len(aRetZ[1][1][1]) >= 13
					cNumeSeq := AllTrim(aRetZ[1,1,1,13])
					if Len(aRetZ[1][1][1]) >= 15
						cRdaOri	 := AllTrim(aRetZ[1,1,1,15])
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

//Ajusta Data
	cData := PLSXMLDTV(cData)

// Dados da Operadora
	BA0->( DbSetOrder(1) ) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->( MsSeek( xFilial("BA0")+PlsIntPad() ) )

	if lFault .or. lFaultLoc
		cNomVar := iif(lFault, " - LFAULT", " - LFAULTLOC")
		PlsPtuLog(cDtHrEvt + iif(cCodErro == "9999", " - 9999 - ", " - ") + "ENTRADA: " + ArrTokStr(aDadErr) + CRLF, "tissonanalise.log" )
		PlsPtuLog(cDtHrEvt + cNomVar + " - aResultado: " + ArrTokStr(aResultado) + CRLF, "tissonanalise.log" )
	endif 

// Raiz Mais Cabecalho
	Cabecalho(cEncod,cTranRet,cNumeSeq,cData,cTime,lFault,lFaultLoc,cCodErro,cDesErro,cObsErro,AllTrim(BA0->BA0_SUSEP),cTpCab,cCCCab,cVersao,cOrigem,cTagOri)

// Dados tag principal com base no conteudo ctagret
	If (!lFault .AND. TISVERS < "3") .OR. (!lFaultLoc .AND. !lFault .AND. TISVERS >= "3")

	//Dados do corpo do xml
		Do Case

		//Dados do LOTEGUIAS
		Case cTranRet == "PROTOCOLO_RECEBIMENTO"

			//Processa guia por guia
			For nI:=1 To Len(aRet)
				aMatCri	    := {}
				aMatAux     := {}
				aMatCri 	:= {}
				aMatAut 	:= {}
				aMatNeg 	:= {}

				cRda 	 	:= AllTrim(aRet[nI,1,3])
				cNomeRda 	:= AllTrim(aRet[nI,1,4])
				cTpPessoa	:= AllTrim(aRet[nI,1,5])
				cCPFCGC	 	:= AllTrim(aRet[nI,1,6])
				cMatric 	:= aRet[nI,1,7]
				cNomeUsu	:= aRet[nI,1,8]
				cNumGui  	:= aRet[nI,1,10]
				If Len(aRet[nI,1]) > 16
					cValTot 	:= Alltrim(Str(aRet[nI,1,17]))
				Else
					cValTot 	:= "0"
				EndIf
				If Len(aRet[nI,1]) > 17
					cAtenRN 	:= AllTrim(aRet[nI,1,18])
				Else
					cAtenRN 	:= "N"
				EndIf


				//Matriz de processamento
				If Len(aRet[nI,2])>0
					cNumAut 	:= aRet[nI,2,2] 	//Numero da Autorizacao
					cNumSen 	:= aRet[nI,2,3] 	//Senha

					//Matric dados,itens e criticas
					aMatCri 	:= aRet[nI,2,4] 	//Criticas
					aMatAut 	:= aRet[nI,2,5] 	//Autorizados
					aMatNeg 	:= aRet[nI,2,6] 	//Negados

					// Ajusta criticas
					aMatAux := AjCriticas(aMatCri)
					aMatCri := aMatAux[1]
					lCriCab := aMatAux[2]
				Else
					lFault := .T.
				EndIf

				// Se o retorno do processamento foi ok
				If !lFault

					// Inclui somente uma vez
					If lInc

						// Raiz da Resposta
						CorpoRaiz(cTranRet,cTagRet,.T.)

						// Sub Raiz
						PLSGRVXML( "A","protocoloRecebimento" )

						If TISVERS < "3"


							// Protocolo
							PLSGRVXML( "AF","numeroProtocoloRecebimento",cNumeLot )

							// DadosOperadora
							DadosOperadora("dadosOperadora")
						Else
							PLSGRVXML( "AF","registroANS",AllTrim(BA0->BA0_SUSEP) )
						EndIf

						// DadosPrestador
						DadosPrestador("dadosPrestador",cTpPessoa,cCPFCGC,cNomeRda,cRda)

						PLSGRVXML( "AF","numeroLote",cNumeLot )
						PLSGRVXML( "AF","dataEnvioLote",cData )
						If TISVERS < "3"
							PLSGRVXML( "A","mensagemDetalheProtocolo" )
							PLSGRVXML( "AF","numeroProtocolo",cNumeLot )
							PLSGRVXML( "A","guias" )
						Else
							PLSGRVXML( "A","detalheProtocolo" )
							PLSGRVXML( "AF","numeroProtocolo",cNumeLot )
							PLSGRVXML( "AF","valorTotalProtocolo",cValTot )
							PLSGRVXML( "A","dadosGuiasProtocolo" )
						EndIf
						lInc := .F.
					EndIf


					// Msg de Protocolo
					PLSGRVXML( "A","dadosGuia" + IIf(TISVERS >= "3", "s","" ))
					PLSGRVXML( "AF","numeroGuiaPrestador",cNumGui )
					If !Empty(cNumAut)
						PLSGRVXML( "AF","numeroGuiaOperadora",cNumAut )
					EndIf

					// Beneficiario
					Beneficiario("dadosBeneficiario",cMatric,cNomeUsu, cAtenRN)

					// Data realizacao
					PLSGRVXML( "AF","dataRealizacao",cData )


					// Opcional somente se tiver critica da nota
					If lCriCab .AND. TISVERS >= "3"
						For nY:=1 To Len(aMatCri)
							Glosa("glosaGuia",aMatCri[nY,2],aMatCri[nY,3])
						Next
					EndIf


					// Matriz de procedimentos
					PLSGRVXML( "A",IIf(TISVERS >= "3", "procedimentosRealizados","procedimentos" ) )

						// Procedimentos Autorizados
					For nY:=1 To Len(aMatAut)
						PLSGRVXML( "A",IIf(TISVERS >= "3", "procedimentoRealizado","dadosProcedimento" ) )
						If TISVERS >= "3"
							PLSGRVXML( "AF","dataExecucao", cData )
						EndIf

						cSlvPad := If(Len(aMatAut[nY])>=10,aMatAut[nY][10],'')
						cSlvPro := If(Len(aMatAut[nY])>=10,aMatAut[nY][11],'')
						Procedimento("procedimento",aMatAut[nY,3],aMatAut[nY,2],nil,aMatAut[nY,5],cVersao,cSlvPad,cSlvPro)

						PLSGRVXML( "AF","quantidadeExecutada",AllTrim( Str( aMatAut[nY,6] ) ) )

						If TISVERS >= "3"
							nVlrUnit := P973VlrPro(cRda,aMatAut[nY,2],aMatAut[nY,3],cMatric)
							PLSGRVXML( "AF","valorUnitario", Str(nVlrUnit))
							PLSGRVXML( "AF","valorTotal", Str(nVlrUnit * aMatAut[nY,6]))
						EndIf
						PLSGRVXML( "F",IIf(TISVERS >= "3", "procedimentoRealizado","dadosProcedimento" ) )
					Next

						// Matriz de procedimentos negados
					For nY:=1 To Len(aMatNeg)
						PLSGRVXML( "A",IIf(TISVERS >= "3", "procedimentoRealizado","dadosProcedimento" ) )
						If TISVERS >= "3"
							PLSGRVXML( "AF","dataExecucao", cData )
						EndIf
						cSlvPad := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][10],'')
						cSlvPro := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][11],'')
						Procedimento("procedimento",aMatNeg[nY,3],aMatNeg[nY,2],nil,aMatNeg[nY,5],cVersao,cSlvPad,cSlvPro)

						PLSGRVXML( "AF","quantidadeExecutada","0" )

						If TISVERS >= "3"
							PLSGRVXML( "AF","valorUnitario", "0")
							PLSGRVXML( "AF","valorTotal", "0")
						EndIf

								// Se nao for critica de sistema
						If !lCriCab

									// Procura a critica correspondente
							If ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
								PLSGRVXML( "A",IIf(TISVERS >= "3", "glosasProcedimento","relacaoGlosa" ) )
								While ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
									aMatCri[nPos,1] := "*"+aMatCri[nPos,1]

									If TISVERS >= "3"
										PLSGRVXML( "A","motivoGlosa" )
										PLSGRVXML( "AF","codigoGlosa",aMatCri[nPos,2] )
										PLSGRVXML( "AF","descricaoGlosa",aMatCri[nPos,3] )
										PLSGRVXML( "F","motivoGlosa" )
									Else
										Glosa("tipoGlosa",aMatCri[nPos,2],aMatCri[nPos,3])
									EndIf
								EndDo
								If TISVERS >= "3"
									PLSGRVXML( "AF","valorGlosaProcedimento", "0")
								EndIf
								PLSGRVXML( "F",IIf(TISVERS >= "3", "glosasProcedimento","relacaoGlosa" ) )
							EndIf
						EndIf
						PLSGRVXML( "F",IIf(TISVERS >= "3", "procedimentoRealizado","dadosProcedimento" ) )
					Next
					PLSGRVXML( "F",IIf(TISVERS >= "3", "procedimentosRealizados","procedimentos" ) )

					// Opcional somente se tiver critica da nota
					If lCriCab .AND. TISVERS < "3"
						For nY:=1 To Len(aMatCri)
							Glosa("codigoGlosaGuia",aMatCri[nY,2],aMatCri[nY,3])
						Next
					EndIf
					PLSGRVXML( "F","dadosGuia" + IIf(TISVERS >= "3", "s","" ))
				EndIf
			Next
			If !lFault
				If !lInc
					PLSGRVXML( "F","guias" )
					PLSGRVXML( "F","mensagemDetalheProtocolo" )
					PLSGRVXML( "F","protocoloRecebimento" )
				EndIf
			EndIf

		//Dados do Solicitacao de Servico e Status Autorizacao
		Case cTranRet $ "RESPOSTA_SOLICITACAO,STATUS_AUTORIZACAO,AUTORIZACAOPROCEDIMENTO"

			//Processa guia por guia
			For nI:=1 To Len(aRet)
				BA1->(dbSetOrder(2))//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
				If BA1->(DbSeek(xFilial("BA1")+aRet[nI,1,7]))
					cNomeUsu	:= BA1->BA1_NOMUSR

					If BA1->( FieldPos("BA1_NOMSOC") ) > 0	.And. TISVERS >="4.00.01"
						cNomeSoc	:= BA1->BA1_NOMSOC
					EndIF
					BTS->(DbSetOrder(1))
					BTS->(MsSeek(xFilial("BTS") + BA1->BA1_MATVID))			
					If BA1->( FieldPos("BTS_NRCRNA") ) > 0	.And. TISVERS < "4"	
						cNumeroCNS:= BTS->BTS_NRCRNA
					EndIF
				Else
					BA1->(dbSetOrder(5))//BA1_FILIAL+BA1_MATANT+BA1_TIPANT
					If BA1->(DbSeek(xFilial("BA1")+aRet[nI,1,7]))
						cNomeUsu	:= BA1->BA1_NOMUSR
						If BA1->( FieldPos("BA1_NOMSOC") ) > 0	.And. TISVERS >="4.00.01"
							cNomeSoc	:= BA1->BA1_NOMSOC
						EndIF
						
						BTS->(DbSetOrder(1))
						BTS->(MsSeek(xFilial("BTS") + BA1->BA1_MATVID))	
						If BA1->( FieldPos("BTS_NRCRNA") ) > 0	.And. TISVERS < "4"	
							cNumeroCNS:= BTS->BTS_NRCRNA
						EndIF			
					Else	
						cNomeUsu	:= aRet[nI,1,8]
						If TISVERS >="4.00.01"
							cNomeSoc	:= ''
						EndIF
						If TISVERS < "4"
							cNumeroCNS:= ''
						EndIF
					Endif	
				Endif	
	
	
				//Carga dos Dados
				aMatCri	    := {}
				aMatAux     := {}
				aMatCri 	:= {}
				aMatAut 	:= {}
				aMatNeg 	:= {}

				cRda 	 	:= AllTrim(aRet[nI,1,3])
				cNomeRda 	:= AllTrim(aRet[nI,1,4])
				cTpPessoa	:= AllTrim(aRet[nI,1,5])
				cCPFCGC	 	:= AllTrim(aRet[nI,1,6])
				If Len(aRet[nI,1]) >= 16
					cCNES	 	:= AllTrim(aRet[nI,1,16])
				Else
					cCNES	 	:= ''
				Endif
				cMatric 	:= aRet[nI,1,7]
				If Empty(cNomeUsu)
					cNomeUsu	:= aRet[nI,1,8]
				EndIf	
				cNumGui  	:= aRet[nI,1,10]
				dDatPro		:= aRet[nI,1,14]     //Data Procedimento
				cAteRN 		:= ""
				If Len(aRet[nI,1]) >= 18
					cAteRN 	:= AllTrim(aRet[nI,1,18])
				Endif

				//Matriz de processamento
				If Len(aRet[nI,2])> 0
					cNumAut 	:= aRet[nI,2,2] 	//Numero da Autorizacao
					cNumSen 	:= aRet[nI,2,3] 	//Senha
					if len(aRet[1,2,5]) > 0 .And. len(aRet[nI,1]) > 19
						dDatAtend   := aRet[nI,1,20]    //Data da Guia
					endIf
					If len(aRet[nI,2,5]) > 0 
						If !Empty(aRet[nI,1,14]) .And. cTranRet != "STATUS_AUTORIZACAO"
							//Verifico se e guia de intercambio
							if GetNewPar("MV_PLSUNI","1") == "1" .And. Substr(aRet[nI,1,7],1,4) <> PlsIntPad()
								BEA->(DbSetOrder(1)) //BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
								if BEA->(DbSeek(xFilial("BEA")+aRet[nI,2,2])) .And. BEA->BEA_COMUNI == "1"
									lDadValPTU := .T.
								endIf
							endIf
							dValSen   := iif(lDadValPTU,BEA->BEA_VALSEN,dDtVaSe + aRet[nI,1,14])     
							 
						Else 	 		
							dValSen   := aRet[nI,1,14]	//Validade Senha
						EndIf	
					EndIf	
					
					if cGuia $ "GUIASOLICINTERNACAO,SOLICITACAOINTERNACAO" .And. GetNewPar("MV_PLSGRSN","0") == "0"
						dValSen := nil
					endIf

					//Matric dados,itens e criticas
					aMatCri 	:= aRet[nI,2,4] 	//Criticas
					aMatAut 	:= aRet[nI,2,5] 	//Autorizados
					aMatNeg 	:= aRet[nI,2,6] 	//Negados

					// Ajusta criticas
					aMatAux := AjCriticas(aMatCri)
					aMatCri := aMatAux[1]
				Else
					lFault := .T.
				EndIf

				// Se o retorno do processamento foi ok
				If !lFault

					// Inclui somente uma vez
					If lInc

						// Raiz da Resposta
						cTagAux := CorpoRaiz(cTranRet,cTagRet,.T.)
						lInc := .F.
					EndIf

					//Autorizacao de Servico
					PLSGRVXML( "A",cTagAux )
					If (TISVERS < "3")

							// IdentificacaoAutorizacao
						IdentAutorizacao("identificacaoAutorizacao",DtoS(dDatPro),cNumGui,cNumAut)

							// Beneficiario
						Beneficiario("beneficiario",cMatric,cNomeUsu)

							// DadosPrestador
						DadosPrestador("prestadorAutorizado",cTpPessoa,cCPFCGC,cNomeRda,cRda)

							// Informa a Senha da autorizacao
						If !Empty(cNumSen)
							PLSGRVXML( "A","dadosAutorizacao" )
							PLSGRVXML( "AF","senhaAutorizacao",cNumSen )
							PLSGRVXML( "F","dadosAutorizacao" )
						EndIf

							// Procedimentos
						If Len(aMatAut)>0 .Or. Len(aMatNeg) > 0
							PLSGRVXML( "A","procedimentos" )

									// Procedimentos Autorizados
							For nY:=1 To Len(aMatAut)
								PLSGRVXML( "A","procedimento" )

								cSlvPad := If(Len(aMatAut[nY])>=10,aMatAut[nY][10],'')
								cSlvPro := If(Len(aMatAut[nY])>=10,aMatAut[nY][11],'')
								Procedimento("identificacaoProcedimentos",aMatAut[nY,3],aMatAut[nY,2],nil,aMatAut[nY,5],cVersao,cSlvPad,cSlvPro)

								PLSGRVXML( "AF","quantidadeSolicitada",AllTrim( Str( aMatAut[nY,4] ) ) )
								PLSGRVXML( "AF","quantidadeAutorizada",AllTrim( Str( aMatAut[nY,6] ) ) )
								PLSGRVXML( "AF","statusSolicitacaoProcedimento","1" )

											// Ponto de Entrada PLSOBSXML para manipulação da TAG de Observação do XML
								If lPLSOBSXML
									cObs := ExecBlock("PLSOBSXML",.F.,.F.,{aRet})
								Endif

								If !Empty(cObs)
									PLSGRVXML( "AF","observacao",AllTrim(cObs) )
								Endif
								PLSGRVXML( "F","procedimento" )
							Next

									// Matriz de procedimentos negados
							For nY:=1 To Len(aMatNeg)

								PLSGRVXML( "A","procedimento" )

								cSlvPad := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][10],'')
								cSlvPro := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][11],'')
								Procedimento("identificacaoProcedimentos",aMatNeg[nY,3],aMatNeg[nY,2],nil,aMatNeg[nY,5],cVersao,cSlvPad,cSlvPro)

								PLSGRVXML( "AF","quantidadeSolicitada",AllTrim( Str( aMatNeg[nY,4] ) ) )
								PLSGRVXML( "AF","quantidadeAutorizada","0" )

								If aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) .And. x[4] == .T. } ) > 0
									cStatus := "2"	//"Em análise"
								Else
									cStatus := "3"	//"Negado"
								EndIf

								PLSGRVXML( "AF","statusSolicitacaoProcedimento",cStatus )

											// Procura a critica correspondente
								If ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
									PLSGRVXML( "A","glosas" )
									While ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
										aMatCri[nPos,1] := "*"+aMatCri[nPos,1]
										Glosa("motivoGlosa",aMatCri[nPos,2],aMatCri[nPos,3])
									EndDo
									PLSGRVXML( "F","glosas" )
								EndIf
								PLSGRVXML( "F","procedimento" )
							Next
							PLSGRVXML( "F","procedimentos" )
						EndIf
					Else
						If (nPO:= aScan(aDados,{|x| 'SP_SADT' $ alltrim(x[1]) })) > 0
							cTipGui := '02'
						Elseif (nPO:= aScan(aDados,{|x| 'INTERNACAO' $ alltrim(x[1]) })) > 0
							cTipGui := '03'
						Endif

						//If cTipGui $ '02'
						//	PLSGRVXML( "A","autorizacaoServico" )
						//ElseIF 
						If cTipGui $ '03'
							PLSGRVXML( "A","autorizacaoInternacao" )
						ElseIF cTipGui $ '01' .AND. cTagAux != "autorizacaoServico"
							If cGuia $ 'SOLICITACAOPRORROGACAO'
								PLSGRVXML( "A","autorizacaoProrrogacao" )
							elseif cGuia $ 'SOLICITACAOODONTOLOGIA'
								PLSGRVXML( "A","autorizacaoServicoOdonto" )
							else
							PLSGRVXML( "A","autorizacaoServico" )
							Endif
						Endif

						If cTipGui $ '03' .OR. cGuia $ 'SOLICITACAOPRORROGACAO'
							PLSGRVXML( "A","autorizacaoDosServicos" )
						Endif

						DadosAutorizacao("dadosAutorizacao", cNumGui, cNumAut, cNumSen, IIF(ValType(dValSen)<>"U",Dtos(dValSen),""),Dtos(dDatAtend))
						If Empty(cAteRN)
							If (nPO:= aScan(aDados,{|x| alltrim(x[1]) == 'ATENDIMENTORN'})) > 0
								cAteRn := aDados[nPO][2]
							Else
								cAteRn := 'N'
							Endif
						Endif
											
						If TISVERS >= "3.05.00"
							cTpGuia   := StrTran(PLSPCONGR(P973TpGui(),"",aDados,"E",nil,.F.,nil,nil),"-","_")
							cTpEtaAut := iif(Empty(PLSPCONGR("CODIGONAOPERADORA","SOLICITACAOPROCEDIMENTO\"+cTpGuia+"\DADOSEXECUTANTE",aDados)),"1","2")
							PLSGRVXML( "AF","tipoEtapaAutorizacao",cTpEtaAut )
						EndIf
						
						Beneficiario("dadosBeneficiario",cMatric,cNomeUsu,cAteRn,cNumeroCNS, cNomeSoc)
	
						PLSGRVXML( "A","prestadorAutorizado" )
						DadosPrestador("dadosContratado",cTpPessoa,cCPFCGC,cNomeRda,cRda)
						PLSGRVXML( "AF","cnesContratado", If (Empty(cCNES), "9999999", cCNES))
						PLSGRVXML( "F","prestadorAutorizado" )
						
						
						If (Len(aMatNeg) > 0)

							if cTranRet == "STATUS_AUTORIZACAO" .And. len(aMatNeg[1]) > 6 
								If  Len(aMatAut) > 0 .And. aScan(aMatNeg,{|x| x[7] == "1" } ) == 0   
									cStatus := "7"	//"Autorizado parcialmente"
								ElseIf aScan(aMatNeg,{|x| x[7] == "1" } ) > 0
									cStatus := "2"	//"Em análise"
								Else
									cStatus := "3"	//"Negado"
								EndIf
							else 
								If  Len(aMatAut) > 0 .And. aScan(aMatCri,{|x| x[4] == .T. } ) == 0   
									cStatus := "7"	//"Autorizado parcialmente"
								ElseIf aScan(aMatCri,{|x| x[4] == .T. } ) > 0
									cStatus := "2"	//"Em análise"
								Else
									cStatus := "3"	//"Negado"
								EndIf
							endIf	

							PLSGRVXML( "AF","statusSolicitacao",cStatus )
						Else
							PLSGRVXML( "AF","statusSolicitacao","1" )
						EndIf

						If (Len(aMatNeg) > 0 .OR. Len(aMatAut)>0)
							PLSGRVXML( "A","servicosAutorizados" )
							If (Len(aMatNeg) > 0)

									// Matriz de procedimentos negados
								For nY:=1 To Len(aMatNeg)
								//	PLSGRVXML( "A","servicosAutorizados" )
									PLSGRVXML( "A","servicoAutorizado" )

									cSlvPad := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][10],'')
									cSlvPro := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][11],'')

									If TISVERS >= "3.04.00"
										PLSGRVXML( "AF","sequencialItem", Strzero(nY,4))
									Endif	

									Procedimento("procedimento",aMatNeg[nY,3],aMatNeg[nY,2],nil,aMatNeg[nY,5],cVersao,cSlvPad,cSlvPro)

									PLSGRVXML( "AF","quantidadeSolicitada",AllTrim( Str( aMatNeg[nY,4] ) ) )
									PLSGRVXML( "AF","quantidadeAutorizada","0" )


									// Procura a critica correspondente
									PLSGRVXML( "A", "motivosNegativa")
									If ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
										While ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
											aMatCri[nPos,1] := "*"+aMatCri[nPos,1]
											Glosa("motivoNegativa",aMatCri[nPos,2],aMatCri[nPos,3])
										EndDo
									EndIf
									PLSGRVXML( "F", "motivosNegativa")

									PLSGRVXML( "F","servicoAutorizado" )
								//	PLSGRVXML( "F","servicosAutorizados" )
								Next

							EndIf

							If (Len(aMatAut)>0)

									// Procedimentos Autorizados

								For nY:=1 To Len(aMatAut)
								//	PLSGRVXML( "A","servicosAutorizados" )
									PLSGRVXML( "A","servicoAutorizado" )


									cSlvPad := If(Len(aMatAut[nY])>=10,aMatAut[nY][10],'')
									cSlvPro := If(Len(aMatAut[nY])>=10,aMatAut[nY][11],'')

									If TISVERS >= "3.04.00"
										PLSGRVXML( "AF","sequencialItem", Strzero(nY,4))
									Endif
									Procedimento("procedimento",aMatAut[nY,3],aMatAut[nY,2],,aMatAut[nY,5],cVersao,cSlvPad,cSlvPro)

									PLSGRVXML( "AF","quantidadeSolicitada",AllTrim( Str( aMatAut[nY,4] ) ) )
									PLSGRVXML( "AF","quantidadeAutorizada",AllTrim( Str( aMatAut[nY,6] ) ) )
									if len(aMatAut[nY]) >= 12 .and. aMatAut[nY,12]  > 0
										PLSGRVXML( "AF","valorAutorizado",AllTrim( Str( aMatAut[nY,12] ) ) )
									endif

									PLSGRVXML( "F","servicoAutorizado" )
								//	PLSGRVXML( "F","servicosAutorizados" )
								Next

							EndIf
							PLSGRVXML( "F","servicosAutorizados" )

							If lPLSOBSXML
								cObs := ExecBlock("PLSOBSXML",.F.,.F.,{aRet})
							Endif
							If !Empty(cObs)
								PLSGRVXML( "AF","observacao",AllTrim(cObs) )
							Endif
						EndIf
						If cTipGui $ '03' .OR. cGuia $ 'SOLICITACAOPRORROGACAO'
							PLSGRVXML( "F","autorizacaoDosServicos" )
						Endif

						//If cTipGui $ '02'
						//	PLSGRVXML( "F","autorizacaoServico" )
						//ElseIF cTipGui $ '03'
						If cTipGui $ '03'
							PLSGRVXML( "F","autorizacaoInternacao" )
						ElseIF cTipGui $ '01' .AND. cTagAux != "autorizacaoServico"
							If cGuia $ 'SOLICITACAOPRORROGACAO'
								PLSGRVXML( "F","autorizacaoProrrogacao" )
							elseif cGuia $ 'SOLICITACAOODONTOLOGIA'
								PLSGRVXML( "F","autorizacaoServicoOdonto" )
							else
							PLSGRVXML( "F","autorizacaoServico" )
							Endif
						Endif


					EndIf

					//Autorizacao de Servico
					PLSGRVXML( "F",cTagAux )
				EndIf
			Next

		//Dados do Solicitacao de Servico e Status Autorizacao
		Case cTranRet $ "SITUACAO_PROTOCOLO"

			//Processa guia por guia
			For nI:=1 To Len(aRet)

				//Carga dos Dados
				aMatCri	    := {}
				aMatAux     := {}
				aMatCri 	:= {}
				aMatAut 	:= {}
				aMatNeg 	:= {}

				cRda 	 	:= AllTrim(aRet[nI,1,3])
				cNomeRda 	:= AllTrim(aRet[nI,1,4])
				cTpPessoa	:= AllTrim(aRet[nI,1,5])
				cCPFCGC	 	:= AllTrim(aRet[nI,1,6])
				cNumGui  	:= aRet[nI,1,10]

				cMatric 	:= aRet[nI,1,7]
				cNomeUsu	:= aRet[nI,1,8]
				cNumeLot 	:= AllTrim(aRet[nI,1,9])
				cNumeSeq 	:= AllTrim(aRet[nI,1,13])
				dDatPro		:= aRet[nI,1,14]     //Data de envio do lote de guias de cobrança para a operadora

				//Matriz de processamento
				If Len(aRet[nI,2])>0
					cNumAut 	:= aRet[nI,2,2] 	//Numero da Autorizacao

					//Matric dados,itens e criticas
					aMatCri 	:= aRet[nI,2,4] 	//Criticas
					aMatAut 	:= aRet[nI,2,5] 	//Autorizados
					aMatNeg 	:= aRet[nI,2,6] 	//Negados

					// Ajusta criticas
					aMatAux := AjCriticas(aMatCri)
					aMatCri := aMatAux[1]

					// Valores do Protocolo, Guia
					aValores := aRet[nI,2,11]
					//1 Valor Processado Guia
					//2 Valor Liberado Guia
					//3 Valor Glosa Guia
					//4 Valor Processado Fatura
					//5 Valor Liberado Fatura
					//6 Valor Glosa Fatura
					//7 Valor Processado Protocolo
					//8 Valor Liberado Protocolo
					//9 Valor Glosa Protocolo
				Else
					lFault := .T.
				EndIf

				// Se o retorno do processamento foi ok
				If !lFault

					// Inclui somente uma vez
					If lInc

						// Raiz da Resposta
						CorpoRaiz(cTranRet,cTagRet,.T.)


						// DadosOperadora
						If (TISVERS < "3")
							DadosOperadora("identificacaoFontePagadora")
						Else
							PLSGRVXML( "A", cTagRet)
							PLSGRVXML( "AF","identificacaoOperadora",AllTrim(BA0->BA0_SUSEP) )
						EndIf

						// DadosPrestador
						DadosPrestador("dadosPrestador",cTpPessoa,cCPFCGC,cNomeRda,cRda)

						PLSGRVXML( "A","lote" )
						lInc := .F.
					EndIf
					If (TISVERS < "3")

						// Detalhe do lote
						If cNumeLot <> cNumeAux
							cNumeAux := cNumeLot
							PLSGRVXML( "A","detalheLote" )

							PLSGRVXML( "AF","numeroProtocolo",cNumeLot )
							PLSGRVXML( "AF","numeroLote",cNumeLot )
							cData := DtoS(dDatPro)
							cData := PLSXMLDTV(cData)
							PLSGRVXML( "AF","dataEnvioLote",cData )
							PLSGRVXML( "AF","status",Iif( Len(aMatAut)==0 .And. Len(aMatNeg)==0,"7",Iif(Len(aMatNeg)>0,"2","1") ) )

							PLSGRVXML( "A","guias")
						EndIf

						// Todos as guias do lote
						If Len(aMatAut)>0 .Or. Len(aMatNeg)>0
							PLSGRVXML( "A","detalheguiaMedica")

								// Identificacao guia
							PLSGRVXML( "A","identificacaoGuia")
							PLSGRVXML( "AF","registroANS",AllTrim(BA0->BA0_SUSEP) )
							cData := DtoS(dDatPro)
							cData := PLSXMLDTV(cData)
							PLSGRVXML( "AF","dataEmissaoGuia", cData )
							PLSGRVXML( "AF","numeroGuiaPrestador",cNumGui )
							If !Empty(cNumAut)
								PLSGRVXML( "AF","numeroGuiaOperadora",cNumAut )
							EndIf
							PLSGRVXML( "F","identificacaoGuia")

								// Procedimentos
							PLSGRVXML( "A","procedimentosAnalisados" )

									// Procedimentos Autorizados
							For nY:=1 To Len(aMatAut)
								PLSGRVXML( "A","procedimento" )

								cSlvPad := If(Len(aMatAut[nY])>=10,aMatAut[nY][10],'')
								cSlvPro := If(Len(aMatAut[nY])>=10,aMatAut[nY][11],'')

								Procedimento("identificacaoProcedimentos",aMatAut[nY,3],aMatAut[nY,2],nil,aMatAut[nY,5],cVersao,cSlvPad,cSlvPro)

								PLSGRVXML( "AF","quantidadeSolicitada",AllTrim( Str( aMatAut[nY,4] ) ) )
								PLSGRVXML( "AF","quantidadeAutorizada",AllTrim( Str( aMatAut[nY,6] ) ) )
								PLSGRVXML( "AF","statusSolicitacaoProcedimento","1" )
								PLSGRVXML( "F","procedimento" )
							Next

									// Matriz de procedimentos negados
							For nY:=1 To Len(aMatNeg)

								PLSGRVXML( "A","procedimento" )

								cSlvPad := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][10],'')
								cSlvPro := If(Len(aMatNeg[nY])>=10,aMatNeg[nY][11],'')

								Procedimento("identificacaoProcedimentos",aMatNeg[nY,3],aMatNeg[nY,2],nil,aMatNeg[nY,5],cVersao,cSlvPad,cSlvPro)

								PLSGRVXML( "AF","quantidadeSolicitada",AllTrim( Str( aMatNeg[nY,4] ) ) )
								PLSGRVXML( "AF","quantidadeAutorizada", "0")

								If aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) .And. x[4] == .T. } ) > 0
									cStatus := "2"	//"Em análise"
								Else
									cStatus := "3"	//"Negado"
								EndIf

								PLSGRVXML( "AF","statusSolicitacaoProcedimento",cStatus )

											// Procura a critica correspondente
								If ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
									PLSGRVXML( "A","glosas" )
									While ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
										aMatCri[nPos,1] := "*"+aMatCri[nPos,1]
										Glosa("motivoGlosa",aMatCri[nPos,2],aMatCri[nPos,3])
									EndDo
									PLSGRVXML( "F","glosas" )
								EndIf
								PLSGRVXML( "F","procedimento" )
							Next
							PLSGRVXML( "F","procedimentosAnalisados" )
							PLSGRVXML( "F","detalheguiaMedica")
						EndIf


						//Fecha o lote
						If Len(aRet)>=(nI+1)
							If AllTrim(aRet[nI+1,1,9]) <> cNumeAux
								PLSGRVXML( "F","guias")
								PLSGRVXML( "F","detalheLote" )
							EndIf
						Else
							PLSGRVXML( "F","guias")
							PLSGRVXML( "F","detalheLote" )
						EndIf
					Else
						If cNumeLot <> cNumeAux
							cNumeAux := cNumeLot

							PLSGRVXML( "A", "detalheLote")
							if(len(aRet[nI,1]) > 18) .AND. !Empty(aRet[nI,1,19])
								PLSGRVXML( "AF","statusProtocolo", aRet[nI,1,19])
							else
								PLSGRVXML( "AF","statusProtocolo",Iif( Len(aMatAut)==0 .And. Len(aMatNeg)==0,"7",Iif(Len(aMatNeg)>0,"2","1") ) )
							endif
							PLSGRVXML( "AF","numeroProtocolo",cNumeLot )
							PLSGRVXML( "AF","numeroLote",cNumeLot )

							cData := DtoS(dDatPro)
							cData := PLSXMLDTV(cData)
							PLSGRVXML( "AF","dataEnvioLote",cData )

							nVlrProcLot := 0
							nVlrGlosLot := 0
							nVlrLibeLot := 0
							For nY := 1 To Len(aRet)
								If cNumeLot == AllTrim(aRet[nY,1,9])
									nVlrProcLot	+= aRet[nY,2,11,1]
									nVlrGlosLot	+= aRet[nY,2,11,3]
									nVlrLibeLot += aRet[nY,2,11,2]
								EndIf
							Next

							ValorTotal("valorTotalLote",Str(nVlrProcLot),Str(nVlrGlosLot),Str(nVlrLibeLot))

							PLSGRVXML( "A", "guiasTISS")
						EndIf

						PLSGRVXML( "A", "guiasMedicas")
						PLSGRVXML( "A", "guias")

						PLSGRVXML( "AF","numeroGuiaPrestador",cNumGui )
						If !Empty(cNumAut)
							PLSGRVXML( "AF","numeroGuiaOperadora",cNumAut )
						EndIf
						Beneficiario("dadosBeneficiario",cMatric,cNomeUsu,"N")

						PLSGRVXML( "AF", "dataRealizacao", cData)
						ValorTotal("vlInformadoGuia",Str(aValores[1]),Str(aValores[3]),Str(aValores[2]))

						If Len(aMatAut)>0 .Or. Len(aMatNeg)>0
							PLSGRVXML( "A", "procedimentosRealizados")


									// Procedimentos Autorizados
							For nY:=1 To Len(aMatAut)
								PLSGRVXML( "A","procedimentoRealizado" )

								PLSGRVXML( "AF","dataExecucao", "2013-01-01")

								cSlvPad := If(Len(aMatAut[nY])>=10,aMatAut[nY][10],'')
								cSlvPro := If(Len(aMatAut[nY])>=10,aMatAut[nY][11],'')

								Procedimento("procedimento",aMatAut[nY,3],aMatAut[nY,2],nil,aMatAut[nY,5],cVersao,cSlvPad,cSlvPro)

								PLSGRVXML( "AF","quantidadeExecutada",AllTrim( Str( aMatAut[nY,6] ) ) )

								nVlrUnit := P973VlrPro(cRda,aMatAut[nY,2],aMatAut[nY,3],cMatric)
								PLSGRVXML( "AF","valorUnitario", Str(nVlrUnit))
								PLSGRVXML( "AF","valorTotal", Str(nVlrUnit * aMatAut[nY,6]))
								PLSGRVXML( "F","procedimentoRealizado" )
							Next


									// Matriz de procedimentos negados
							For nY:=1 To Len(aMatNeg)

								PLSGRVXML( "A","procedimentoRealizado" )

								PLSGRVXML( "AF","dataExecucao", )

								cSlvPad := If(Len(aMatAut[nY])>=10,aMatAut[nY][10],'')
								cSlvPro := If(Len(aMatAut[nY])>=10,aMatAut[nY][11],'')
								Procedimento("procedimento",aMatNeg[nY,3],aMatNeg[nY,2],nil,aMatAut[nY,5],cVersao,cSlvPad,cSlvPro)

								PLSGRVXML( "AF","quantidadeExecutada",AllTrim( Str( aMatNeg[nY,6] ) ) )

								nVlrUnit := P973VlrPro(cRda,aMatNeg[nY,2],aMatNeg[nY,3],cMatric)
								PLSGRVXML( "AF","valorUnitario", Str(nVlrUnit))
								PLSGRVXML( "AF","valorTotal", Str(nVlrUnit * aMatNeg[nY,6]))

											// Procura a critica correspondente
								If ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
									PLSGRVXML( "A","glosasProcedimento" )
									While ( nPos := aScan(aMatCri,{|x|x[1] == AllTrim(aMatNeg[nY,1]+aMatNeg[nY,3]) } ) ) > 0
										aMatCri[nPos,1] := "*"+aMatCri[nPos,1]
										Glosa("motivoGlosa",aMatCri[nPos,2],aMatCri[nPos,3])
									EndDo
									PLSGRVXML( "AF","valorGlosaProcedimento", )
									PLSGRVXML( "F","glosasProcedimento" )
								EndIf
								PLSGRVXML( "F","procedimentoRealizado" )
							Next

							PLSGRVXML( "F", "procedimentosRealizados")
						EndIf

						PLSGRVXML( "F", "guias")
						PLSGRVXML( "F", "guiasMedicas")

						If Len(aRet)>=(nI+1)
							If AllTrim(aRet[nI+1,1,9]) <> cNumeAux
								PLSGRVXML( "F", "guiasTISS")
							EndIf
						Else

							PLSGRVXML( "F", "guiasTISS")
						EndIf
					EndIf
				EndIf
			Next
			If !lFault
				PLSGRVXML( "F","detalheLote")
				PLSGRVXML( "F","lote" )
				If (TISVERS >= "3")
					PLSGRVXML( "F", cTagRet)
				EndIf
			EndIf

		//Dados do VERIFICA ELEGIBILIDADE
		Case cTranRet == "SITUACAO_ELEGIBILIDADE"
			BA1->(dbSetOrder(2))//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
			If Len(aRet[1]) > 0
				If BA1->(DbSeek(xFilial("BA1")+aRet[1,1,7]))
					cMatric 	:= BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
					cNomeUsu	:= BA1->BA1_NOMUSR
					
					BTS->(DbSetOrder(1))
					BTS->(MsSeek(xFilial("BTS") + BA1->BA1_MATVID))				
					cNumeroCNS:= BTS->BTS_NRCRNA
				Else
					BA1->(dbSetOrder(5))//BA1_FILIAL+BA1_MATANT+BA1_TIPANT
					If BA1->(DbSeek(xFilial("BA1")+aRet[1,1,7]))
						cMatric 	:= BA1->BA1_MATANT
						cNomeUsu	:= BA1->BA1_NOMUSR
					
						BTS->(DbSetOrder(1))
						BTS->(MsSeek(xFilial("BTS") + BA1->BA1_MATVID))
						cNumeroCNS:= BTS->BTS_NRCRNA
					Else	
						cMatric 	:= aRet[1,1,7]
						cNomeUsu	:= aRet[1,1,8]
						cNumeroCNS:= ''
					Endif	
				Endif
				If BA1->( FieldPos("BA1_NOMSOC") ) > 0	.And. TISVERS >="4.00.01"
					cNomeSoc:= Iif(!Empty(BTS->BTS_NOMSOC),Alltrim(BTS->BTS_NOMSOC),Alltrim(BA1->BA1_NOMSOC))	
				Endif	

				// Raiz da Resposta
				If !lFault
					CorpoRaiz(cTranRet,cTagRet,.T.)

					If (TISVERS < "3")

						// DadosOperadora
						DadosOperadora("dadosOperadora")

						// Beneficiario
						Beneficiario("dadosBeneficiario",cMatric,cNomeUsu)

						// Resposta Solicitacao
						PLSGRVXML( "AF","respostaSolicitacao",Iif(aRet[1,2,1],"true","false"),,,,.F. )
					Else
						PLSGRVXML( "A", "reciboElegibilidade")

						// DadosOperadora
						PLSGRVXML( "AF","registroANS",AllTrim(BA0->BA0_SUSEP) )

						// Beneficiario
						PLSGRVXML( "AF","numeroCarteira",cMatric )
						PLSGRVXML( "AF","nomeBeneficiario",cNomeUsu )

						If BA1->( FieldPos("BA1_NOMSOC") ) > 0 .and. !Empty(cNomeSoc)
							PLSGRVXML( "AF","nomeSocialBeneficiario",cNomeSoc )
						EndIf

						If !Empty(cNumeroCNS) .and. TISVERS < "4"
							PLSGRVXML( "AF","numeroCNS",cNumeroCNS )
						Endif	
						
						If TISVERS >= "3.05.00"
							/* Opcoes
							<!--01	Tarja magnética-->
							<!--02	Código de barras-->
							<!--03	Cartão de identificação-->
							<!--04	QR code-->
							<!--05	Impressão digital-->
							<!--06	Leitura facial-->
							<!--07	Leitura de íris-->
							<!--08	Leitura da geometria da mão-->
							*/
							PLSGRVXML( "AF","tipoIdent","03" )
						EndIf
						// Resposta Solicitacao
						PLSGRVXML( "AF","respostaSolicitacao",Iif(aRet[1,2,1],"S","N"),,,,.F. )
					EndIf

					// Pega as criticas
					If !Empty(aRet[1,2,4])
						aTrb := aRet[1,2,4]
						For nY := 1 To Len(aTrb)
							If !Empty(aTrb[nY,1])
								AaDd( aMatAux,{StrZero(nY,3),aTrb[nY,1],aTrb[nY,2],"",StrZero(nY,3),""} )
							EndIf
						Next
						aMatAux := AjCriticas(aMatAux)
						aMatCri := aMatAux[1]

						// Motivo da Negativa
						If Len(aMatCri)>=1
							If (TISVERS < "3")
								Glosa("motivoNegacao",aMatCri[1,2],aMatCri[1,3])
							Else
								Glosa("motivosNegativa_motivoNegativa",aMatCri[1,2],aMatCri[1,3])
							EndIf
						EndIf
					EndIf
				Endif
				If !(TISVERS < "3")
					PLSGRVXML( "F", "reciboElegibilidade")
				EndiF
			EndIf


		//Dados do CANCELAMENTO_GUIA_RECIBO
		Case cTranRet == "CANCELAMENTO_GUIA_RECIBO"

			//Processa guia por guia
			For nI:=1 To Len(aRet)
				aMatCri	:= {}
				dDatPro	:= aRet[nI,1,14]     //Data Procedimento
				cNumGui	:= aRet[nI,1,10]     //Numero guia prestador

				cRda 	 	:= AllTrim(aRet[nI,1,3])
				cNomeRda 	:= AllTrim(aRet[nI,1,4])
				cTpPessoa	:= AllTrim(aRet[nI,1,5])
				cCPFCGC	 	:= AllTrim(aRet[nI,1,6])
				cTipoGuia 	:= aRet[nI,2,3]


				//Matriz de processamento
				If Len(aRet[nI,2])>0

					cNumAut := aRet[nI,2,2] 	//Numero da Autorizacao

					//Matric dados,itens e criticas
					aMatCri := aRet[nI,2,4] 	//Criticas
				Else
					lFault := .T.
				EndIf

				// Se o retorno do processamento foi ok
				If !lFault

					// Inclui somente uma vez
					If lInc

						// Raiz da Resposta
						CorpoRaiz(cTranRet,cTagRet,.T.)

						// DadosOperadora
						If (TISVERS < "3")
							DadosOperadora("operadora")
						Else
							PLSGRVXML( "A", cTagRet)
							PLSGRVXML( "AF","registroANS",AllTrim(BA0->BA0_SUSEP) )
							DadosPrestador("dadosPrestador",cTpPessoa,cCPFCGC,cNomeRda,cRda)
						EndIf

						// operadora FIM
						PLSGRVXML( "A","guiasCanceladas" )
						lInc := .F.
					EndIf

					// Dados da guia
					PLSGRVXML( "A","dadosGuia" )
					If (TISVERS < "3")
						PLSGRVXML( "A","identificacaoFontePagadora" )
						PLSGRVXML( "AF","registroANS",AllTrim(BA0->BA0_SUSEP) )
						PLSGRVXML( "F","identificacaoFontePagadora" )
						cData := DtoS(dDatPro)
						cData := PLSXMLDTV(cData)
						PLSGRVXML( "AF","dataEmissaoGuia", cData )
						PLSGRVXML( "AF","numeroGuiaPrestador",cNumGui )
						If !Empty(cNumAut)
							PLSGRVXML( "AF","numeroGuiaOperadora",cNumAut )
						EndIf

							// Status do cancelamento
						PLSGRVXML( "AF","statusCancelamento",aMatCri[1,1] )
						PLSGRVXML( "AF","observacao",Left(AllTrim(aMatCri[1,2]),240) )
					Else
						PLSGRVXML( "AF","numeroGuiaPrestador",cNumGui )
						PLSGRVXML( "AF","tipoGuia", cTipoGuia)
						PLSGRVXML( "AF","statusCancelamento",aMatCri[1,1] )
					EndIf
					PLSGRVXML( "F","dadosGuia" )
				EndIf
			Next
			If !lFault
				PLSGRVXML( "F","guiasCanceladas" )
				PLSGRVXML( "F", cTagRet)
			EndIf

		EndCase

	// Fechamento da tag raiz do corpo
		If !lFault
		//Necessário verificar se é demonstrativo, pois se não, coloca as tags em ordem errada e o xml não é validado. Não fecha em nível correto.
			IF (cTranRet $ "DEMONSTRATIVO_ANALISE_CONTA, DEMONSTRATIVO_PAGAMENTO, DEMONSTRATIVO_ODONTOLOGIA" )
				aMtmp := {}
				aMtp := SEPARA(cTagRet, "_")
				cTagRet := aMtp[2] + "_" + aMtp[1]
			ENDIF
			CorpoRaiz(cTranRet,cTagRet,.F.)
		EndIf
	EndIf

	If (lFault .OR. lFaultLoc) 
		CorpoRaiz(cTranRet,cTagRet,.T.)

		If "autorizacaoProcedimento" $ cTagRet //Isso corrige o retorno do web service de solicitação de procedimentos, tem que ver a estrutura dos demais futuramente
			PLSGRVXML( "A", "autorizacaoProcedimento")
		EndIf
			PLSGRVXML( "A", "mensagemErro")
			PLSGRVXML( "AF","codigoGlosa", cCodErro)
			PLSGRVXML( "AF","descricaoGlosa", cDesErro + " " + cObsErro)
			PLSGRVXML( "F", "mensagemErro")
		If "autorizacaoProcedimento" $ cTagRet
			PLSGRVXML( "F", "autorizacaoProcedimento")
		EndIf		
		CorpoRaiz(cTranRet,cTagRet,.F.)
	EndIf

// Se a origem nao foi encontrada como rda pego o conteudo do arquivo
	If cRdaOri == PlsIntPad() .And. !Empty(cOrigem)
		cRdaOri := cOrigem
	EndIf

// Epilogo
	cHash := Epilogo()

// Para garantir que o lbuffer da logfil coloca o conteudo restante abuffer no arquivo
	PlsLogFil("",cFileTmp,.F.,,.T.,cDirTemp,.F.)

// Renomeia arquivo
	If File(cDirTemp+cFileTmp)

	//Cria diretorio se nao existir
		If !ExistDir(cDirCaiSa+cRdaOri)
			If MakeDir(cDirCaiSa+cRdaOri) <> 0
				PLSLOGX(STR0002+cDirCaiSa+cRdaOri+STR0003) //"Impossível criar diretorio ( "###" ) "
				If fREname(cDirTemp+cFileTmp , cDirLog+"XMLERROGRA.TXT" ) == -1
					PLSLOGX(STR0135+cDirLog+"XMLERROGRA.TXT ) ") //"Não foi possível criar arquivo de errolog ( "
				EndIf
				If File(cDirTemp+cFileTmp) .And. FErase(cDirTemp+cFileTmp) == -1
					PLSLOGX(STR0136) //"Não foi possível deletar arquivo temporario XMLTMP"
				EndIf
				lCriDir := .F.
			EndIf
		EndIf
		If lCriDir
			cArqRet := PLSMUDSIS( cRdaOri+"\"+StrZero(Val(cNumeLot),20)+"_"+cHash+".XML" )

		// Para garantir que o arquivo ja esta fechado
			While fREname(cDirTemp+cFileTmp , cDirCaiSa+cArqRet ) == -1 .And. nCont<=10
				nCont++
			EndDo
			If nCont>10
				PLSLOGX(STR0137+PLSMUDSIS( cDirCaiSa+cRdaOri+"\"+StrZero(Val(cNumeLot),20)+"_"+cHash ) + STR0003) //### //### //"Não foi possível criar arquivo ( "###" ) "
			EndIf

			If File(cDirTemp+cFileTmp) .And. FErase(cDirTemp+cFileTmp) == -1
				PLSLOGX(STR0136) //"Não foi possível deletar arquivo temporario XMLTMP"
			EndIf
		EndIf
	EndIf

// Registra a transacao
	If SIX->( MsSeek("BSA2") )
		BSA->( DbSetOrder(2) )//BSA_FILIAL + BSA_CONTEU
		If !BSA->( MsSeek( xFilial("BSA") + AllTrim(cRdaOri) + StrZero( Val(cNumeLot),20 ) + StrZero( Val(cNumeSeq),12 ) ) )
			BSA->( RecLock("BSA",.T.) )
			BSA->BSA_FILIAL := xFilial("BSA")
			BSA->BSA_NUMSEQ := DToS( Date() ) + StrTran( Time(),":","" )
			BSA->BSA_IDENT  := "XML"
			BSA->BSA_VARIAV := ""
			BSA->BSA_CONTEU := AllTrim(cRdaOri) + StrZero( Val(cNumeLot),20 ) + StrZero( Val(cNumeSeq),12 )
			If lVerTISS .And. BSA->( FieldPos("BSA_NOMAPL") ) > 0 .And. BSA->( FieldPos("BSA_VERAPL") ) > 0 .And. BSA->( FieldPos("BSA_FABAPL") ) > 0
				BSA->BSA_NOMAPL	:= cNomApl
				BSA->BSA_VERAPL	:= cVerApl
				BSA->BSA_FABAPL	:= cFabAPl
			EndIf
			BSA->( MsUnLock() )
		EndIf
	EndIf
	
	If lLogTissOn
		PlsPtuLog(PLSRetTime()+" - Finalizando PLSPROCRES (PLSA973)", "tissonanalise.log")
	EndIf
Return cArqRet

/*/{Protheus.doc} Cabecalho
Cabecalho do Retorno
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function Cabecalho(cEncod,cTranRet,cNumeSeq,cData,cTime,lFault,lFaultLoc,;
		cCodErro,cDesErro,cObsErro,cSusep,cTpCab,cCCCab,cVersao,cOrigem,cTagOri)

// Raiz
	PLSGRVXML( "A","mensagemTISS",,,.T.,cEncod )

	// Inicio CABECALHO
	PLSGRVXML( "A","cabecalho_identificacaoTransacao" )

	// Identificacao Transacao
	PLSGRVXML( "AF","tipoTransacao",cTranRet)
	PLSGRVXML( "AF","sequencialTransacao",AllTrim( cNumeSeq ) )
	PLSGRVXML( "AF","dataRegistroTransacao",cData )
	PLSGRVXML( "AF","horaRegistroTransacao",cTime )
	PLSGRVXML( "F","identificacaoTransacao" )

	// Falha Negocio
	If lFault .Or. lFaultLoc 
		//5002	NAO FOI POSSIVEL VALIDAR O ARQUIVO XML
		PLSGRVXML( "AF","falhaNegocio",Iif (AllTrim(cCodErro) == "9999", "5002", AllTrim(cCodErro)))
	EndIf

	// Origem
	PLSGRVXML( "A","origem" )
	PLSGRVXML( "AF","registroANS",cSusep )
	PLSGRVXML( "F","origem" )

	// Destino
	If lFault
		PLSGRVXML( "A","destino" )
		If !Empty(cOrigem)
			PLSGRVXML( "AF",cTagOri,cOrigem )
		Else
			PLSGRVXML( "AF","registroANS",cSusep )
		EndIf
		PLSGRVXML( "F","destino" )

	Else
		If (TISVERS < "3")
			PLSGRVXML( "A","destino_codigoPrestadorNaOperadora" )
		Else
			PLSGRVXML( "A","destino_identificacaoPrestador" )
		EndIf
		If !Empty(cTpCab)
			If cTpCab == "J"
				PLSGRVXML( "AF","CNPJ",AllTrim(cCCCab) )
			Else
				PLSGRVXML( "AF","CPF",AllTrim(cCCCab) )
			EndIf
		EndIf
		If (TISVERS < "3")
			PLSGRVXML( "F","codigoPrestadorNaOperadora" )
		Else
			PLSGRVXML( "F","identificacaoPrestador" )
		EndIf
		PLSGRVXML( "F","destino" )
	EndIf

	// Versao
	PLSGRVXML( "AF","Padrao",cVersao )

	// Final do CABECALHO
	PLSGRVXML( "F","cabecalho" )

Return

/*/{Protheus.doc} CorpoRaiz
Tag Raiz inicio e fim do conteudo da resposta
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function CorpoRaiz(cTranRet,cTagRet,lTipo,lRepet)
	LOCAL cTagAux := ""
	Default lRepet := .F.

	If lTipo

	// Dados do OperadoraParaPrestador, cTagRet  INICIO
		If cTranRet == "RESPOSTA_SOLICITACAO"
			PLSGRVXML( "A","operadoraParaPrestador" )
			cTagAux := cTagRet
		ElseIF (!lRepet)
			cTagRet := SubStr(cTagRet, 1, 21)
			PLSGRVXML( "A","operadoraParaPrestador_"+cTagRet)

		//Status da Autorizacao
			If cTranRet == "STATUS_AUTORIZACAO"
				If (TISVERS < "3")
					cTagAux := "dadosAutorizacao"
				Else
					cTagAux := "autorizacaoServico"
				EndIf
			EndIf
		ELSEIF (cTranRet == "DEMONSTRATIVO_ANALISE_CONTA" .AND. lRepet)
			PLSGRVXML( "A","demonstrativoAnaliseConta")
		EndIf

	Else

	// Fechamento Tag
		If cTranRet <> "RESPOSTA_SOLICITACAO"
			PLSGRVXML( "F",cTagRet)
		EndIf

		PLSGRVXML( "F","operadoraParaPrestador")
	EndIf

Return(cTagAux)

/*/{Protheus.doc} Epilogo
Fim do retorno
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function Epilogo()
	LOCAL cHash := ""
	PLSGRVXML( "A","epilogo")
	cHash := PLSGRVXML( "AF","hash","" )
	PLSGRVXML( "F","epilogo")
	PLSGRVXML( "F","mensagemTISS")

Return(cHash)

/*/{Protheus.doc} Beneficiario
Implementa dados da tag Beneficiario
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function Beneficiario(cTag,cMatric,cNomeUsu,cAtendRn,cNumeroCNS,cNomeSoc)
	LOCAL cPlano := "PLANO NAO ENCONTRADO"

	DEFAULT cAtendRn := "N"
    DEFAULT cNumeroCNS:=""
    
	If (TISVERS < "3")
		BA3->( DbSetOrder(1) ) //BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
		If BA3->( MsSeek( xFilial("BA3")+Subs( PPLTROMAT(cMatric) ,1,14 ) ) )
			BI3->( DbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
			If BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) ) )
				cPlano := AllTrim(BI3->BI3_NREDUZ)
			EndIf
		Endif
	EndIf

// Beneficiario INICIO
	PLSGRVXML( "A",cTag )
	PLSGRVXML( "AF","numeroCarteira",cMatric )
	If (TISVERS >= "3")
		PLSGRVXML( "AF","atendimentoRN",cAtendRn )   
				
	EndIf
	//Nome do benefeciario na versao 4.00 Jul/21 sai do escopo do dadosBeneficiario
	If (TISVERS < "4")
		PLSGRVXML( "AF","nomeBeneficiario",cNomeUsu )
	EndIf
	If (TISVERS < "3")
		PLSGRVXML( "AF","nomePlano",cPlano )
	Else
		//Retira o numero da carteira nacional de saude na versao 4.00 Jul/21
		If (TISVERS < "4")
			If !Empty(cNumeroCNS)
				PLSGRVXML( "AF","numeroCNS",cNumeroCNS )
			Endif	
		Endif
	EndIf
	PLSGRVXML( "F",cTag )
	//Nome do benefeciario na versao 4.00 Jul/21 sai do escopo do dadosBeneficiario
	//Nome social entra na versao 4.00 Jul/21
	If (TISVERS >= "4")
		PLSGRVXML( "AF","nomeBeneficiario",cNomeUsu )
		If !empty(cNomeSoc)
			PLSGRVXML( "AF","nomeSocialBeneficiario",cNomeSoc )
		EndIf
	EndIf
	

// Beneficiario Fim


Return

/*/{Protheus.doc} DadosOperadora
Implementa a tag dados da operadora
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function DadosOperadora(cTag)

// DadosOperadora INICIO
	If !Empty(cTag)
		PLSGRVXML( "A",cTag )
	EndIf

	If !Empty(BA0->BA0_SUSEP)
		PLSGRVXML( "A","operadoraRegulada")
		PLSGRVXML( "AF","registroANS",AllTrim(BA0->BA0_SUSEP) )
		PLSGRVXML( "AF","CNPJ",AllTrim(BA0->BA0_CGC) )
		PLSGRVXML( "AF","nomeOperadora",AllTrim(BA0->BA0_NOMINT) )
		PLSGRVXML( "F","operadoraRegulada")
	Else
		PLSGRVXML( "A","entidadeNaoRegulada")
		PLSGRVXML( "AF","CNPJ",AllTrim(BA0->BA0_CGC) )
		PLSGRVXML( "AF","nomeOperadoraEntidade",AllTrim(BA0->BA0_NOMINT) )
		PLSGRVXML( "F","entidadeNaoRegulada")
	EndIf

	If !Empty(cTag)
		PLSGRVXML( "F",cTag )
	EndIf

// DadosOperadora FIM


Return

/*/{Protheus.doc} DadosPrestador
Implementa a tag dados da prestador
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function DadosPrestador(cTag,cTpPessoa,cCPFCGC,cNomeRda,cRda)

// DadosPrestador INICIO
	PLSGRVXML( "A",cTag )
	If (TISVERS < "3")
		PLSGRVXML( "A","identificacao" )
		If !Empty(cTpPessoa)
			If cTpPessoa == "J"
				PLSGRVXML( "AF","CNPJ",cCPFCGC )
			Else
				PLSGRVXML( "AF","CPF",cCPFCGC )
			Endif
		Else
			PLSGRVXML( "AF","codigoPrestadorNaOperadora",cRda )
		EndIf
		PLSGRVXML( "F","identificacao" )
	Else
		If !Empty(cTpPessoa)
			If cTpPessoa == "J"
				PLSGRVXML( "AF","cnpjContratado",cCPFCGC )
			Else
				PLSGRVXML( "AF","cpfContratado",cCPFCGC )
			Endif
		Else
			PLSGRVXML( "AF","codigoPrestadorNaOperadora",cRda )
		EndIf
	EndIf
	//Retira o nome do contratado executante na versao 4.00 Jul/21
	If (TISVERS < "4")
		PLSGRVXML( "AF","nomeContratado",cNomeRda )
	EndIf	
	PLSGRVXML( "F",cTag )

Return

/*/{Protheus.doc} Procedimento
Implementa a tag de procedimento
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function Procedimento(cTag,cCodpro,cCodPad,cOpeMov,cDescric,cVersao,cSlvPad,cSlvPro)

	LOCAL cLocalExec	:= "5"
	LOCAL cTipoGrv		:= "1"
	LOCAL cCodTabela	:= ""
	LOCAL cCodProc		:= ""
	DEFAULT cDescric	:= ''
	DEFAULT cCodpro 	:= ''
	DEFAULT cCodPad 	:= ''
	DEFAULT cOpeMov		:= PlsIntPad()
	DEFAULT cVersao     := GetNewPar("MV_TISSVER","2.02.03")
	DEFAULT cSlvPad		:= ''
	DEFAULT cSlvPro     := ''
	PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))

	If (TISVERS < "3")
		If PLSPOSGLO(cOpeMov,__aCdCri198[1],__aCdCri198[2],cLocalExec,"1",cTipoGrv)
			aRetTuss := PLSDPTUSS('S',cCodPad,cCodPro)
			If !Empty(aRetTuss[1])
				cCodPad := aRetTuss[1]
				cCodPro := aRetTuss[2]
				cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
			EndIf
		EndIf
		PLSXPAD(@cCodPad,@cCodPro,@cDescric,nil,nil,cVersao)
	Endif

// Procedimento INICIO
	PLSGRVXML( "A",cTag )
	If (TISVERS < "3")
		PLSGRVXML( "AF","codigo",cCodpro )
		PLSGRVXML( "AF","tipoTabela",cCodPad )
	Else
        //retorno sempre o que foi enviado no xml
		If !Empty(cSlvPad+cSlvPro)
			PLSGRVXML( "AF","codigoTabela",  cSlvPad)
			PLSGRVXML( "AF","codigoProcedimento", cSlvPro)
			PLSGRVXML( "AF","descricaoProcedimento", EncodeUtf8(PLSNoAcento(Left(Alltrim(cDescric), 150))) )
		Else

			BR8->(DbSetOrder(3)) //BR8_FILIAL+BR8_CODPSA+BR8_CODPAD
			If (BR8->(MsSeek(xFilial("BR8")+cCodpro+cCodPad)))

				cPadBkp 	:= PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCodPad,.T.)

				cCodProc 	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodPad,  Alltrim(cCodPad+cCodpro), .F. ,aTabDup, @cPadBkp)
				cCodTabela  := cPadBkp
				cDescric 	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., cCodTabela,  Alltrim(cCodPad+cCodpro))


				If (Empty(cCodTabela))
					// NÃO PODE RETORNAR PARA O PRESTADOR QUE NÃO TEM DE/PARA POIS ESSA É UMA INFORMAÇÃO
					// PERTINENTE AO CADASTRO DA OPERADORA DEVE SER VERIFICADO DENTRO DO PLS PLSLOGFIL
					//PLSLOGX("Codigo da Tabela nao encontrado no De/Para.",.F.)
					PLSLOGFIL( "TransacoesOnline: Codigo da Tabela nao encontrado no De/Para. " + Time(),DIRLOG+"ONLINELOG.TXT" )
					PLSGRVXML( "AF","codigoTabela",  cCodPad)
				Else
					PLSGRVXML( "AF","codigoTabela",  cCodTabela)
				EndIf
				If (Empty(cCodProc))
					// NÃO PODE RETORNAR PARA O PRESTADOR QUE NÃO TEM DE/PARA POIS ESSA É UMA INFORMAÇÃO
					// PERTINENTE AO CADASTRO DA OPERADORA DEVE SER VERIFICADO DENTRO DO PLS PLSLOGFIL
					//PLSLOGX("Codigo do Procedimento nao encontrado no De/Para. "+BR8->(BR8_CODPAD+BR8_CODPSA),.F.)
					PLSLOGFIL( "TransacoesOnline: Codigo do Procedimento nao encontrado no De/Para. "+BR8->(BR8_CODPAD+BR8_CODPSA) + " " + Time(),DIRLOG+"ONLINELOG.TXT" )
					PLSGRVXML( "AF","codigoProcedimento", cCodPro)
					cDescric := "PROCEDIMENTO GENÉRICO"
				Else
					PLSGRVXML( "AF","codigoProcedimento", cCodProc)
				EndIf
			Else
				//PLSLOGX("Procedimento nao encontrado. "+cCodPad+cCodpro,.F.)
				PLSLOGFIL( "Procedimento nao encontrado. "+cCodPad+cCodpro + " " + Time(),DIRLOG+"ONLINELOG.TXT" )
			EndIf
			PLSGRVXML( "AF","descricaoProcedimento", cDescric )
		Endif
	EndIf
	PLSGRVXML( "F",cTag )

// Procedimento INICIO




Return

/*/{Protheus.doc} Glosa
Implementa a tag de Glosa
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function Glosa(cTag,cCodGlo,cDesGlo)
	Local aTag := StrTokarr(cTag, "_")
	Local nI := Len(aTag)

// Glosa INICIO
	PLSGRVXML( "A",cTag )

	PLSGRVXML( "AF","codigoGlosa",cCodGlo )
	PLSGRVXML( "AF","descricaoGlosa",cDesGlo )

	For nI := Len(aTag) To 1 Step -1
		PLSGRVXML( "F",aTag[nI] )
	Next

// Glosa FIM


Return

/*/{Protheus.doc} IdentAutorizacao
Implementa a tag de Glosa
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function IdentAutorizacao(cTag,cData,cNumGui,cNumAut)

// IdentificacaoAutorizacao INICIO
	PLSGRVXML( "A",cTag )

	PLSGRVXML( "A","identificacaoFontePagadora" )
	PLSGRVXML( "AF","registroANS",AllTrim(BA0->BA0_SUSEP) )
	PLSGRVXML( "F","identificacaoFontePagadora" )
	cData := PLSXMLDTV(cData)
	PLSGRVXML( "AF","dataEmissaoGuia", cData )
	PLSGRVXML( "AF","numeroGuiaPrestador",cNumGui )
	If !Empty(cNumAut)
		PLSGRVXML( "AF","numeroGuiaOperadora",cNumAut )
	EndIf

	PLSGRVXML( "F",cTag )


Return

/*/{Protheus.doc} DadosAutorizacao
Implementa a tag de dadosAutorizacao
@type function
@author TOTVS
@since 25.10.13
@version 1.0
/*/
Static Function DadosAutorizacao(cTag, cNumGui, cNumAut, cNumSen, cValSen, cDatAtend)
Default cValSen := ""
Default cDatAtend := ""

	PLSGRVXML( "A",cTag )
	PLSGRVXML( "AF", "numeroGuiaPrestador", cNumGui)
	If (!Empty(cNumAut))
		PLSGRVXML( "AF", "numeroGuiaOperadora", cNumAut)
	EndIF
	If !Empty(cDatAtend)
		cDatAtend := PLSXMLDTV(cDatAtend)
		PLSGRVXML( "AF", "dataAutorizacao", cDatAtend)
	EndIf
	If (!Empty(cNumSen))
		PLSGRVXML( "AF", "senha", cNumSen)
	EndIf
	If !Empty(cValSen)
		cValSen := PLSXMLDTV(cValSen)
		PLSGRVXML( "AF", "dataValidadeSenha", cValSen)
	EndIf
	PLSGRVXML( "F",cTag )
Return

/*/{Protheus.doc} PLSGRVXML
Grava arquivo xml
@type function
@author TOTVS
@since 31.05.07
@version 1.0
/*/
Function PLSGRVXML(cTp,cDescri,cConteudo,cNameSpace,lRaiz,cEncod,lUpper)
	LOCAL nI			:= 0
	LOCAL lHash 		:= Iif(cDescri=="hash",.T.,.F.)
	LOCAL aRet 			:= PLSARRAY(cDescri,"_")[3]
	DEFAULT lRaiz		:= .F.
	DEFAULT cNameSpace	:= Iif(lVerTISS,"ansTISS","ans")
	DEFAULT cConteudo	:= ""
	DEFAULT cEncod	 	:= "ISO-8859-1"
	DEFAULT lUpper		:= .T.



// Cria ou abre o arquivo
	For nI:=1 To Len(aRet)
		cDescri := aRet[nI]

	// Retirna acentuacao
		If !Empty(cConteudo)
			If lUpper
				cConteudo := Upper( PLSXMLTACE( AllTrim( cConteudo) ) )
			Else
				cConteudo := PLSXMLTACE( AllTrim( cConteudo) )
			EndIf
		Else
			cConteudo := Upper( PLSXMLTACE( 'NULL' ) )
		EndIf

	// Ajusta tag
		Do Case
		Case cTp == "A"
			If lRaiz
				If lVerTISS
					cDescri := '<?xml version="1.0" encoding="'+AllTrim(cEncod)+'"?>'+Chr(10)+'<'+cNameSpace+':'+cDescri+' xsi:schemaLocation="http://www.ans.gov.br/padroes/tiss/schemas http://www.ans.gov.br/padroes/tiss/schemas" xmlns:'+StrTran(cPrefANS,":","")+'="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
				Else
					cDescri := '<?xml version="1.0" encoding="'+AllTrim(cEncod)+'"?>'+Chr(10)+'<'+cNameSpace+':'+cDescri+' xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas">'
				EndIF
			Else
				cDescri := "<"+cNameSpace+":"+cDescri+">"
			EndIf
		Case cTp == "F"
			If cDescri <> "respostaElegibilidadeWS"
				cDescri := "</"+cNameSpace+":"+cDescri+">"
			Else
				cDescri := "</"+cNameSpace+":"+SubStr(cDescri, 1, 21)+">"
			EndIf
		Case cTp == "AF"

			// Junta o conteudo para calculo do HASH
			If !Empty( cConteudo ) .And. cConteudo <> 'NULL'
				cValHash += cConteudo
			EndIf

			// Calcula o HASH
			If lHash
				cConteudo := Upper( MD5(cValHash,2) )
				cValHash  := ""
			EndIf

			// Monta elemento e conteudo
			If !Empty( cConteudo )
				cDescri := "<"+cNameSpace+":"+cDescri+">" + cConteudo + "</"+cNameSpace+":"+cDescri+">"
			Else
				cDescri := ""
			EndIf
		EndCase

	// Insere elementos e tags
		If !Empty(cDescri)
			If lNoGerFil
				cXmlResp := iif( valtype(cXmlResp) != "U", cXmlResp, "")
				cXmlResp += iif(At("ISO",Upper(cEncod) ) > 0,cDescri,EncodeUtf8(cDescri))
			Else
				If At("ISO",Upper(cEncod) ) > 0
					PlsLogFil(cDescri,cFileTmp,.T.,,.T.,cDirTemp,.F.)
				Else
					PlsLogFil(EncodeUtf8(cDescri),cFileTmp,.T.,,.T.,cDirTemp,.F.)
				EndIf
			EndIf
		EndIf
	Next





Return(cConteudo)

/*/{Protheus.doc} AjCriticas
Ajusta criticas
@type function
@author TOTVS
@since 04.02.08
@version 1.0
/*/
Static function AjCriticas(aMatCri)
	LOCAL nY 	  := 0
	LOCAL lCriCab := .F.
	LOCAL aMatAux := {}
	LOCAL aRetCri := {}

	For nY := 1 To Len(aMatCri)
		If !Empty( aMatCri[nY,2] )
			If Empty( aMatCri[nY,5] )
				lCriCab := .T.
			EndIf
			aRetCri := PLSRETCRI(aMatCri[nY,2])
			AaDd( aMatAux,{ AllTrim(aMatCri[nY,1]+aMatCri[nY,5]),aRetCri[1,1],aRetCri[1,2],aRetCri[1,3] } )
		EndIf
	Next

Return( { aMatAux,lCriCab } )

/*/{Protheus.doc} PLSXMLDTV
Ajusta data conforme versao
@type function
@author TOTVS
@since 13.06.08
@version 1.0
/*/
Function PLSXMLDTV(cData)

	cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,2)

Return(cData)

/*/{Protheus.doc} PLSAJULIB
Ajusta sequen conforme liberacao
@type function
@author TOTVS
@since 13.06.08
@version 1.0
/*/
Function PLSAJULIB(cNumLib,aItens)
	LOCAL nI	  := 0
	LOCAL cSeqMax := '001'
	LOCAL aAuxSeq := {}

// Posiciona na liberacao														³
	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT
	If BEA->( MsSeek(xFilial("BEA")+cNumLib) )
		BE2->( DbSetOrder(1) )//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
		If BE2->( MsSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)) )

		// Limpa as sequencias															³
			For nI:=1 To Len(aItens)
				PLSPUTDAD(aItens[nI],"SEQMOV","")
			Next

		// Atualiza a sequencia														³
			While ! BE2->( Eof() ) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == ;
					xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

			// Atualiza ou limpa a sequencia												³
				For nI:=1 To Len(aItens)
					cSeqMov := PLSRETDAD(aItens[nI],"SEQMOV")

					If !Empty(cSeqMov)
						Loop
					EndIf

					cCodPad := PLSRETDAD(aItens[nI],"CODPAD")
					cCodPro := PLSRETDAD(aItens[nI],"CODPRO")

					If AllTrim( cCodPad+cCodPro ) == AllTrim( BE2->(BE2_CODPAD+BE2_CODPRO) )
						PLSPUTDAD(aItens[nI],"SEQMOV",BE2->BE2_SEQUEN)
						aAdd(aAuxSeq,BE2->BE2_SEQUEN)
						If BE2->BE2_SEQUEN > cSeqMax
							cSeqMax := BE2->BE2_SEQUEN
						EndIf
						Exit
					EndIf
				Next

				BE2->(DbSkip())
			EndDo
		EndIf

	// Verifica se tem algum item sem sequencia e coloca o max + 1					³
		aSort(aAuxSeq)
		cSeqMov := "001"

		For nI := 1 TO Len(aItens)
			If Empty(PLSRETDAD(aItens[nI],"SEQMOV"))
				cSeqMov := NextSeq(aAuxSeq,cSeqMov)
				PLSPUTDAD(aItens[nI],"SEQMOV",cSeqMov)
				cSeqMov := Soma1(cSeqMov)
			EndIf
		Next
	EndIf

Return

/*/{Protheus.doc} NextSeq
Retorna a proxima sequencia para o aItens
@type function
@author TOTVS
@since 31/08/2016
@version 1.0
/*/
Static Function NextSeq(aAuxSeq,cSeqMov)
	Local nFor	:= 0
	Default aAuxSeq := {}
	Default cSeqMov := "001"

	For nFor := 1 TO Len(aAuxSeq)
		If aScan(aAuxSeq,{|x| AllTrim (x) == AllTrim(cSeqMov)}) > 0
			cSeqMov := Soma1(cSeqMov)
		EndIf
	Next nFor

Return cSeqMov

/*/{Protheus.doc} ValorTotal
Implementa o ComplexType ct_valorTotal
@type function
@author TOTVS
@since 30/10/13
@version 1.0
/*/
Static function ValorTotal(cTag,cVlrProces,cVlrGlosa,cVlrLibera)

	PLSGRVXML("A",cTag)

	PLSGRVXML("AF","valorProcessado",cVlrProces)
	PLSGRVXML("AF","valorGlosa",cVlrGlosa)
	PLSGRVXML("AF","valorLiberado",cVlrLibera)

	PLSGRVXML("F",cTag)
Return

/*/{Protheus.doc} PlRConTPA
Carga inicial de dados
@type function
@author TOTVS
@since 17.01.20
@version 1.0
/*/
function PlRConTPA()
local aLista := {}

if valType(__aTpPart) == "U"
	__aTpPart := {}
endIf

if empty(__aTpPart)
	
	BKC->(dbSetOrder(1))
	BD3->(dbSetOrder(1))
	BD3->(dbGotop())

	while ! BD3->(Eof())

		aLista := {}
		
		if BKC->(msSeek(xFilial("BKC")+BD3->BD3_CODIGO+PLSINTPAD()))

			while ! BKC->(eof()) .And. BKC->(BKC_FILIAL+BKC_CODIGO+BKC_CODOPE) == xFilial("BKC")+BD3->BD3_CODIGO+PLSINTPAD()
				
				aadd(aLista,{allTrim(BKC->BKC_CODPAR),allTrim(BKC->BKC_CODIGO)})
				
			BKC->(dbSkip())
			enddo
			
		endIf
		
		aadd(__aTpPart,{BD3->BD3_CODIGO,aLista})
		
	BD3->(dbSkip())
	endDo
	
endIf

return(__aTpPart)

/*/{Protheus.doc} PXMLUsrGe
(long_description)
@type function
@author TOTVS
@since 17.01.20
@version 1.0
/*/
Function PXMLUsrGe(cOpeOri)
	LOCAL cMatric
	LOCAL cCodInt
	LOCAL cCodEmp 		:= GetNewPar("MV_PLSGEIN","0001")
	LOCAL cModulo   	:= IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(cOpeOri+cCodEmp+"99999999")),Modulo11(cOpeOri+cCodEmp+"99999999"))
	LOCAL cMatrAntGen   := cOpeOri+cCodEmp+"99999999"+cModulo
	LOCAL cNomeUsr 		:= "USUARIO GENERICO"
	LOCAL aRet		    := {}

// Verifica se existe o usuario generico...
	BA1->(DbSetOrder(5))
	If ! BA1->(MsSeek(xFilial("BA1")+cMatrAntGen))

      // Se nao existir inclui...
		cCodInt := PLSINTPAD()
		cMatric := PLPROXMAT(cCodInt,cCodEmp)

		BA3->(RecLock("BA3",.T.))
		BA3->BA3_FILIAL := xFilial("BA3")
		BA3->BA3_CODINT := cCodInt
		BA3->BA3_CODEMP := cCodEmp
		BA3->BA3_ROTINA := "IMPXML"
		BA3->BA3_MATRIC := cMatric
		BA3->BA3_MATANT := cMatrAntGen
		BA3->BA3_HORACN := StrTran(SubStr(Time(),1,5),":","")
		BA3->BA3_COBNIV := "0"
		BA3->BA3_VENCTO := 0
		BA3->BA3_DATBAS := dDataBase
		BA3->BA3_DATCIV := dDataBase
		BA3->BA3_TIPOUS := "2"
		BA3->BA3_USUOPE := PLSRtCdUsr()
		BA3->BA3_MODPAG := "2"
		BA3->BA3_CODPLA := GetNewPar("MV_PLSPLPE","0001")
		BA3->BA3_VERSAO := GetNewPar("MV_PLSVRPE","0001")
		BA3->BA3_FORPAG := GetNewPar("MV_PLSFCPE","101")
		BA3->BA3_DATCON := Date()
		BA3->BA3_HORCON := StrTran(SubStr(Time(),1,5),":","")
		BA3->(MsUnLock())

		BA1->(RecLock("BA1",.T.))
		BA1->BA1_FILIAL := xFilial("BA1")
		BA1->BA1_CODINT := BA3->BA3_CODINT
		BA1->BA1_CODEMP := BA3->BA3_CODEMP
		BA1->BA1_MATRIC := BA3->BA3_MATRIC
		BA1->BA1_CONEMP := BA3->BA3_CONEMP
		BA1->BA1_VERCON := BA3->BA3_VERCON
		BA1->BA1_SUBCON := BA3->BA3_SUBCON
		BA1->BA1_VERSUB := BA3->BA3_VERSUB
		BA1->BA1_IMAGE  := "ENABLE"
		BA1->BA1_TIPREG := "00"//MUDAR
		BA1->BA1_DIGITO := IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG)),Modulo11(BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG))
		BA1->BA1_NOMUSR := cNomeUsr
		BA1->BA1_TIPUSU := SuperGetMv("MV_PLCDTIT")
		BA1->BA1_GRAUPA := GetMv("MV_PLCDTGP")
		If BA1->(FieldPos("BA1_ENDCLI")) > 0
			BA1->BA1_ENDCLI := "0"
		Endif
		BA1->BA1_SEXO   := ""
		BA1->BA1_MATEMP := ""
		BA1->BA1_MATANT := cMatrAntGen
		BA1->BA1_ESTCIV := ""
		BA1->BA1_CPFUSR := ""
		BA1->BA1_DRGUSR := ""
		BA1->BA1_DATINC := ctod("")
		BA1->BA1_DATNAS := ctod("")
		BA1->BA1_DATCAR := ctod("")
		BA1->BA1_CBTXAD := "1"
		BA1->BA1_OPEORI := cOpeOri
		BA1->BA1_OPEDES := cCodInt
		BA1->BA1_OPERES := cCodInt
		BA1->BA1_LOCATE := "2"
		BA1->BA1_LOCCOB := "2"
		BA1->BA1_LOCEMI := "2"
		BA1->BA1_LOCANS := "2"
		BA1->(MsUnLock())

      // Esta funcao analise a criacao de uma nova vida ou nao...
		PLSA766ANV(nil,.F.)

      // Grava no usuario a vida criada ou a ja existente...
		BA1->(RecLock("BA1",.F.))
		BA1->BA1_MATVID := BTS->BTS_MATVID
		BA1->(MsUnLock())
	Endif

Return(aRet)

/*/{Protheus.doc} _RtPos
@type function
@author TOTVS
@since 17.01.05
@version 1.0
/*/
Function _RtPos(cCampo,aArray)

Return aScan(aArray,{|x| x[1] == cCampo})

/*/{Protheus.doc} P973VlrPro
@type function
@author TOTVS
@since 17.01.05
@version 1.0
/*/
Function P973VlrPro(cCodRda,cCodPad,cCodPro,cMatric)
	LOCAL nValor		:= 0
	LOCAL cAno			:= ""
	LOCAL cMes			:= ""
	LOCAL aDadUsr		:= PLSDADUSR(cMatric,'1',.F.,dDatabase,,,"NAO_VALIDAR_CARTAO")
	LOCAL aDadRDA		:= PLSDADRDA(PlsIntPad(),cCodRda,"1",dDataBase,"","")

	cAno := Alltrim(Str(Year(dDataBase)))
	cMes := Alltrim(Str(month(dDataBase)))


// Retorna Valor
	aValor := PLSCALCEVE(cCodPad,cCodPro,cMes,cAno,;
		PlsIntPad(),cCodRda,aDadRDA[15],"",;
		aDadRDA[12],1,dDataBase,"1",/*cPadInt*/ "",/*::RegAte*/,0,aDadUsr,"",;
		{},nil,nil,nil,nil,"",{},nil,"",0,{},nil,dDataBase,"",{},"",.F.,0,{},nil,;
		.F.,100,"","",1,1,{},"","",,,/*::RegInt*/,"","")

	If ValType(aValor) == "A"
		If Len(aValor) >= 2
			nValor := aValor[2]
		Endif
	Endif

Return nValor

/*/{Protheus.doc} PlRetUnp
Dada uma participacao retorna as unidades que estao a ela relacionadas
@type function
@author TOTVS
@since 17.01.05
@version 1.0
/*/
Function PlRetUnp(cTipPar)
	LOCAL aRet  := {}
	LOCAL aUnds := {}

	If Type('__Xudns') == 'U'
		PUBLIC __Xudns := {}
	Endif

	nI:= aScan(__Xudns,{|x| alltrim(x[1]) == alltrim(cTipPar) })
	If nI > 0
		aRet := __Xudns[nI][2]
	Else
		cSql := " SELECT BKC_CODIGO FROM "+RetSqlName('BKC')
		cSql += " WHERE BKC_FILIAL = '"+xFilial('BKC')+"' "
		cSql += " AND BKC_CODPAR = '"+cTipPar+"' "
		cSql += " AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLBKC",.F.,.T.)

		While !PLBKC->(Eof())
			aadd(aUnds,alltrim(PLBKC->BKC_CODIGO))
			PLBKC->(DbSkip())
		Enddo
		aadd(__Xudns,{alltrim(cTipPar),aUnds})
		aRet := __Xudns[Len(__Xudns)][2]
		PLBKC->(DbCloseArea())
	Endif

Return aRet

/*/{Protheus.doc} PlsAjsArT
Ajusta a posição do Array que na TISS 2 esta dif da TISS 3
@type function
@author TOTVS
@since 15/01/14
@version 1.0
/*/
Static Function PlsAjsArT(aMatAjus, nPos)
	Local nI 		:= 0
	Local cPos2	:= ""
	Local cPos3	:= ""

	Default nPos := 0
	If nPos > 0
		For nI := 1 to Len(aMatAjus[nPos])
			cPos2	:= aMatAjus[nPos,nI,2]
			If "\" $ cPos2
				cPos3	:= aMatAjus[nPos,nI,3]
				aMatAjus[nPos,nI,2] := cPos3
				aMatAjus[nPos,nI,3] := cPos2
			EndIf
		Next nI
	Else
		For nI := 1 to Len(aMatAjus)
			cPos2	:= aMatAjus[nI,2]
			If "\" $ cPos2
				cPos3	:= aMatAjus[nI,3]
				aMatAjus[nI,2] := cPos3
				aMatAjus[nI,3] := cPos2
			EndIf
		Next nI
	EndIf

Return()

/*/{Protheus.doc} PLSLGSP3
Processamento da importacao do XML. Prepara os dados e os envia ao PLSXMOV para gravação
#tissver 2.x,3.x

@type Function
@author PLS
@since 16/01/2014
@version 1.0
/*/
Function PLSLGSP3(cGuia,cNomeArq,cDatHor,aMatC,aMatM,lHasAr,lHasCo,lLotGui,cCodPeg,lOk,nSeqGui,aMatBWT, lBg, l974Xml, dDatRea)
LOCAL nQtd			:= 0
LOCAL nIdx			:= 0
LOCAL nPos			:= 1
LOCAL nPosVlrApr	:= 0
LOCAL nPosXX		:= 1
LOCAL cTpCab 		:= ""
LOCAL cCCCab		:= ""
LOCAL cTipo 		:= ""
LOCAL cOrigem		:= ""
LOCAL cObs			:= ""
LOCAL cSigla  		:= ""
LOCAL cCrm 	  		:= ""
LOCAL cUf 	  		:= ""
LOCAL cCodRP		:= ""
LOCAL cRdaOri  		:= ""
LOCAL cNomRda		:= ""
LOCAL cNomCont		:= ""
LOCAL cMatric		:= ""
LOCAL cNomeUsu		:= ""
LOCAL cData			:= ""
LOCAL cHora			:= ""
LOCAL cDtFimFat 	:= ""
LOCAL cHrFimFat 	:= ""
LOCAL cDtIniFat 	:= ""
LOCAL cHrIniFat 	:= ""
LOCAL cNumSen		:= ""
LOCAL cNumeLot  	:= ""
LOCAL cNumeSeq		:= ""
LOCAL cNumImp		:= ""
LOCAL cNumAut		:= ""
LOCAL cLocalExec	:= "1"
LOCAL cNumEvo		:= ""
LOCAL cCodPad		:= ""
LOCAL cCNES			:= ""
LOCAL cCodLoc		:= ""
LOCAL cNumImpOp		:= ""
LOCAL cNumEvoOp 	:= ""
LOCAL cCrmRda   	:= ""
LOCAL cSlgRda   	:= ""
LOCAL cEstRda   	:= ""
LOCAL cNomPre		:= ""
LOCAL cCodPro   	:= ""
LOCAL cGuiPri		:= ""
LOCAL cNumeDN		:= ""
LOCAL cDescric		:= ""
LOCAL cConPrEx 		:= ""
LOCAL cNomRdEx 		:= ""
LOCAL cTipPOr		:= ""
LOCAL cSeqBXX   	:= ""
LOCAL cVersao   	:= StrTran(TISVERS,"_",".")
LOCAL nTamObs   	:= (TamSX3("BEA_MSG01")[1])
LOCAL cOpeMov		:= PlsIntPad()
LOCAL cArqImp   	:= Left( cNomeArq,At(".",cNomeArq)-1 )
LOCAL lEvolu		:= .F.
LOCAL lInter		:= .F.
LOCAL lResInt   	:= .F.
LOCAL lHonor		:= .F.
LOCAL lAchouVlr 	:= .F.
LOCAL lImpXml   	:= .T.
LOCAL aTpPRec		:= {}
LOCAL aRet    		:= {}
LOCAL aRetAux		:= {}
LOCAL aDados  		:= {}
LOCAL aEspCbXML		:= {}
LOCAL aMatIte 		:= {}
LOCAL aEspItXML		:= {}
LOCAL aItens  		:= {}
LOCAL aRetTag		:= {}
LOCAL aMatPro		:= {}
LOCAL aMatEqu		:= {}
LOCAL aDadUsrRet	:= {}
Local cCodldp		:=	""
Local cChave		:=	""
LOCAL nI			:= 1
LOCAL nE			:= 1
LOCAL nP			:= 1
LOCAL dDatAcat  	:= dDataBase
LOCAL nt			:= 0
LOCAL cCnpjPres 	:=""
LOCAL nJ	    	:=0
LOCAL nValorTotG	:= 0
LOCAL nVlrTotPrc	:= 0
LOCAL cPadConSol	:= ""
LOCAL cCidSol		:= ""
LOCAL nDiasSol		:= 0
LOCAL nRedAcr 		:= 0
LOCAL cEspExe		:= ""
LOCAL cCodEsp		:= ""
LOCAL cEspSol		:= ""
LOCAL cCboSol		:= ""
LOCAL cCboExe		:= ""
LOCAL lNInfPar		:= .F.
Local dDataAnt 		:= PLSAJUDAT("")
Local nLimite		:= 1 //Essa variavel ira tratar se a ocorrencia da Tag esta dentro do procedimento atual.
Local lTisOnl       := IsInCallStack("PROCONLINE")
//Eh usado no PLSPCONGR, ultimo parametro atual [nLimitPes]. Caso ocorra uma situacao
//Em que uma tag de um procedimento esta sendo considerada em um outro procedimento da
//Guia, verifique se este parametro esta sendo passado na chamada do PLSPCONGR dessa tag.
Local cPadIntSol	:= ""
Local lPLSXMLAUN    := ExistBlock("PLSXMLAUN")
Local lisOdonto		:= .F.
Local aProfOdo		:= {}
Local cCrmS			:= ""
Local cUfS			:= ""
Local nIJ			:= 0
local nEspPos		:= 0
local nEsp			:= 0
local nTip			:= 0
local lEspF			:= .f.
local cIndCli		:= ""
local cCobEsp		:= "" //Cobertura especial Versao 4.0 TISS
Local cRdaExe		:= ""
Local cTipQui		:= ""
Local cJustTe		:= ""
Local cTipRad		:= ""
Local dDatPro		:= ""
Local aReProc		:= {}
Local nProc 		:= 0
Local cToken    	:= "" 
Local cTipAte   	:= ""
Local cTipAtePad 	:= ""
Local cNumProto 	:= ""
Local cTipAteTiss 	:= ""
Local cTagOdonto 	:= ""
Local lOriSol 		:= .F.
Local cAusenciaCod 	:= ""
local cFace 		:= ""
local cStrFrm		:= ""
local cMatAntPt		:= ""
local oJsonHAT      := NIL
local lGuiaHAT      := .F.
local aRetVld		:= {}
local lGeraSenha    := .T.

DEFAULT lLotGui		:= .F.
DEFAULT cCodPeg 	:= ""
DEFAULT lOk			:= lOkXml
DEFAULT nSeqGui 	:= 0
DEFAULT aMatBWT 	:={}
Default lBg 		:= .F.
Default l974Xml		:= .F.
Default dDatRea 	:= cTod("")

PRIVATE lPlsCTEs 	:= GetNewPar('MV_PLSCTES','0') == '1'
PRIVATE aErrVarVin	:= {.F., "", "", ""}
PRIVATE aTabDup 	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
Private cHshLib		:= ""

If lLogTissOn
	PlsPtuLog(PLSRetTime() + " - Iniciando PLSLGSP3 (PLSA973)", "tissonanalise.log")
EndIf

// Indices
BAX->( DbSetOrder(1) ) //BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
BAQ->( DbSetOrder(4) ) //BAQ_FILIAL + BAQ_CODINT + BAQ_CBOS


// Verifica se em consulta ou sp-sadt ou internacao
Do Case
Case cGuia $ "GUIACONSULTA,GUIACONSULTAREAPRESENTACAO"
	cTipo 	:= "1"
	cOrigem	:= "1" //Execucao
	cTipGui	:= "01"
	cTipAtePad := "04"
Case cGuia $ "GUIASOLICITACAOSADT,SOLICITACAOSP_SADT,SOLICITACAOSP-SADT"
	cTipo 	:= "2"
	cOrigem	:= "2" //Solicitacao
	cTipGui	:= "02"
	lImpXml	:= .F.
	cTipAtePad := "05"
Case cGuia $ "GUIASP_SADT,GUIASPSADT,GUIASP-SADT,REAPRESENTACAO,GUIASP_SADTREAPRESENTACAO"
	cTipo 	:= "2"
	cOrigem	:= "1" //Execucão
	cTipGui	:= "02"
	cTipAtePad := "05"
Case cGuia $ "GUIASOLICINTERNACAO,SOLICITACAOINTERNACAO"
	lInter   := .T.
	cTipo 	:= "3"
	cOrigem	:= "2" //Solicitacao
	cTipGui	:= "03"
	lImpXml	:= .F.
	cTipAtePad := "07"
	lGeraSenha := GetNewPar("MV_PLSGRSN","0") == "1"
Case cGuia $ "GUIASOLICITACAOPRORROGACAO, SOLICITACAOPRORROGACAO"
	lInter   := .T.
	lEvolu   := .T.
	cTipo 	:= "3"
	cOrigem	:= "2" //Solicitacao
	cTipGui	:= "11"
	lImpXml	:= .F.
	cTipAtePad := "07"
Case cGuia $ "GUIAHONORARIOINDIVIDUAL,GUIAHONORARIOINDIVIDUALREAPRESENTACAO,GUIAHONORARIOS"
	lInter   := .T.
	lHonor	:= .T.
	cTipo 	:= "3"
	cOrigem	:= "1" //Execucao
	cTipGui	:= "06"
	cTipAtePad := "07"
Case cGuia $ "GUIARESUMOINTERNACAO,GUIARESUMOINTERNACAOREAPRESENTACAO"
	lResInt  := .T.
	cTipo 	:= "3"
	cOrigem	:= "1" //Execucao
	cTipGui	:= "05"
	cTipAtePad := "07"
Case cGuia $ "SOLICITACAOODONTOLOGIA"
	cTipo 		:= "4"
	cOrigem		:= "2" //Solicitacao
	cTipGui		:= "13"
	lisOdonto	:= .T.
	lImpXml		:= .F.
	cTipAtePad  := "05"
Case cGuia $ "GUIAODONTOLOGIA,GUIAODONTOLOGIAREAPRESENTACAO,GUIAODONTO"
	cTipo 	:= "4"
	cOrigem	:= "1" //Execucão
	cTipGui	:= "13"
	lisOdonto	:= .T.
	cTipAtePad  := "05"
EndCase

//Carrego Json do HAT com regras especificas
if cTipGui	== "02" .And. PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia,aMatM,nil,nil,nil,nil,cCodPeg) == 'HAT'
	oJsonHAT := JsonObject():New()
	cObs  := PLSPCONGR("OBSERVACAO",cGuia,aMatM,,,.F.,nil,cCodPeg)
	if !empty(cObs) .And. empty(oJsonHAT:fromJson(cObs))
		lGuiaHAT := .T.
	endIf
endif

//Troco tipo de Guia para Consulta - HAT
if lGuiaHAT .And. ValType(oJsonHAT['isCons']) != "U" .And. oJsonHAT['isCons']
	cTipGui := '01'
endIf

//******** TAMANHO DO CAMPO CODIGO DA SIGLA DO CONSELHO *****//
BTP->(DbSetOrder(1))
If BTP->(msSeek(xFilial("BTP")+"26"))
	nTamSigla := BTP->BTP_TAMCOD
EndIf

// Verificando se a Peg Já existe  na Importação do XML
// para não criar duas BCI para a mesma RDA com BCI_CODLDP diferentes

If l974Xml .or. IsInCallStack('PLSIMPBATCH')	//	TUXB79
	
	BXX->(dbSetOrder(6))//BXX_FILIAL + BXX_CODINT +  BXX_CODPEG
	If BXX->(msSeek(xFilial("BXX")+cOpeMov+cCodPeg))
		cChave   := BXX->BXX_CHVPEG
		dDatAcat := BXX->BXX_DATMOV
	Endif
	
	BCI->(dbSetOrder(1))//BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
	If BCI->(msSeek(xFilial("BCI")+cChave)) .and. empty(BCI->BCI_PROCES)
		cCodldp	 := BCI->BCI_CODLDP
	Endif
	//se for imp xml tem q ser igual a 5
	cLocalExec:= "5"
Endif

 If IsInCallStack("PROCONLINE") // garanto que se estiver vindo do Tiss on line ele vai para o local de digitação generico..
	cCodldp:= PLSRETLDP(9)
 Endif



// Matriz cabecalho da guia
AaDd( aDados, {"DATACA"	, dDatAcat } )
AaDd( aDados, {"TP_CLIENTE"	, "XML" } )											//Tipo de Transacao
AaDd( aDados, {"CODLDP"		, If (!empty(cCodldp),cCodldp,If(PLSOBRPRDA(),PLSRETLDP(9),PLSRETLDP(2))) } )	//Local de Digitacao
AaDd( aDados, {"IMPXML"		, lImpXml } )  										//aqui ele define se vai gravar a guia somente ou se vai ter liberacao...
AaDd( aDados, {"AUDEMP"		, .T. } )  											//Critica da operadora se manda para auditoria
AaDd( aDados, {"GERSEN"		, lGeraSenha } )									//Gerar senha de autorizacao
AaDd( aDados, {"TPGRV"		, "4" } )											//Tipo de Gravacao
AaDd( aDados, {"TIPOMAT"   	, "" } )											//Matricula Procura a antiga depois a nova
AaDd( aDados, {"LVALOR"		, .T. } ) 											//indica que o evento sera valorizado
AaDd( aDados, {"LRETVPF"	, .T. } ) 											//indica que devera ser retornado o valor da participacao financeira
AaDd( aDados, {"LREGPAGATO"	, .F. } ) 											//indica se ira checar regra de "pagar o evento no ato"
AaDd( aDados, {"INCAUTIE"  	, .T. } )											//Se o usuario for de intercambio e nao existir ele inclui
AaDd( aDados, {"TIPO"      	, AllTrim( cTipo ) } )								//Tipo de Guia
AaDd( aDados, {"ORIGEM"    	, cOrigem } )										//Origem
AaDd( aDados, {"CHKREG"    	, .T. } ) 											//Se vai checar regras ou nao
AaDd( aDados, {"ARQIMP"		, cArqImp} ) 										//Nome do Arquivo+Data e Hora
AaDd( aDados, {"NRAOPE"		, "" } )											//Numero autorizacao operadora
AaDd( aDados, {"NRAEMP"		, "" } )    										//Numero autorizacao empresa
//AaDd( aDados, {"MSG01"		, "" } )											//Mensagem 1
//AaDd( aDados, {"MSG02"		, "" } )											//Mensagem 2
AaDd( aDados, {"MSG03"		, "" } )											//Mensagem 3
AaDd( aDados, {"NATJURI"	, "" } )											//Natureza juridica
AaDd( aDados, {"AREAABR"	, "" } )								 			//Abrangencia
AaDd( aDados, {"INTERN" 	, lInter } )										//Interncao
AaDd( aDados, {"EVOLU"	, lEvolu } )										//Evolucao (Prorrogacao)
AaDd( aDados, {"HORIND" 	, lHonor } )										//Honorario Individual
AaDd( aDados, {"RESINT" 	, lResInt } )										//Resumo de Internacao
AaDd( aDados, {"LNMUDF" 	, .F. } )										//Se nao muda fase para processamento de XML
AaDd( aDados, {"TIPGUI" 	, cTipGui } )
AaDd( aDados, {"XMLORIY"    , .T.} )										//origem XML	//	TUTEOE


// Data e hora
If ExistBlock("PLSXMLDAT")
	aRetTag := ExecBlock( "PLSXMLDAT",.F.,.F.,{cGuia} )
	cData 	:= PLSPCONGR(aRetTag[1],cGuia+AllTrim(aRetTag[2]),aMatM,nil,.F.,nil,nil,cCodPeg)
EndIf

// Se entrou no ponto de entrada mais nao retornou nada
If cTipo == "1" .And. Empty(cData)
	cData := PLSPCONGR("DATAATENDIMENTO",cGuia + "\DADOSATENDIMENTO\DATAATENDIMENTO",aMatM,nil,.F.,nil,nil,cCodPeg)
EndIf

If cTipo $ "1,2,4" .Or. (cTipo == "3" .And. cOrigem == "2") .Or. lHonor
	If Empty(cData)
		cData := PLSPCONGR("DATAEXECUCAO",cGuia + "\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO",aMatM,nil,nil,nil,nil,cCodPeg)
		If Empty(cData)
			cData := PLSPCONGR("DATAEXECUCAO",cGuia + "\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,nil,nil,nil,cCodPeg)
		EndIf
		If Empty(cData)
			cData := PLSPCONGR("DATASOLICITACAO",cGuia,aMatM,nil,nil,.F.,nil,cCodPeg)
		EndIf
		If Empty(cData)
			cData := PLSPCONGR("DATAINICIOFATURAMENTO",cGuia,aMatM,nil,nil,.F.,nil,cCodPeg)
		EndIf
		If Empty(cData)
			cData := PLSPCONGR("DATAEMISSAOGUIA",cGuia,aMatM,nil,nil,.F.,nil,cCodPeg)
		EndIf
	EndIf
	If Empty(cData)
		cData:=PLSPCONGR("DATAATENDIMENTO",cGuia,aMatM,nil,nil,.F.,nil,cCodPeg)
	EndIf

	cTagOdonto := IIF( "SOLIC" $ cGuia, "\PROCEDIMENTOSSOLICITADOS", "\PROCEDIMENTOSEXECUTADOS")

	If EmpTy(cData) .AND.  "ODONTO" $ cGuia
		cData := PLSPCONGR("DATAREALIZACAO",cGuia+cTagOdonto,aMatM,nil,.F.,nil,nil,cCodPeg)
	EndIf

	If Empty(cHora)
		// Foi retirada a inclusão da hora da guia de consulta,
		// pois como não existe tag específica, não podemos arbitrariamente informar um horário.
		// No caso do horário de transação, pode haver complicações se a operadora utilizar
		// pagamento de horário especial, pois se o prestador gerar um xml
		// dentro do horário especial, receberá o adicional indevidamente
		If cTipo $ "1,2"	  //Entendimento estendido para SADT
			cHora := ""
		Else
			cHora := PLSPCONGR("HORAREGISTROTRANSACAO","\CABECALHO\IDENTIFICACAOTRANSACAO",aMatC,nil,nil,nil,nil,cCodPeg)
		EndIf
	EndIf
Else
	cData := PLSPCONGR("DATAINICIOFATURAMENTO",cGuia + "\DADOSINTERNACAO",aMatM,nil,nil,nil,nil,cCodPeg)
	cHora := PLSPCONGR("HORAINICIOFATURAMENTO",cGuia + "\DADOSINTERNACAO",aMatM,nil,nil,nil,nil,cCodPeg)
EndIf

If empTy(cHora) .AND. lOnline
	cHora := StrTran(Time(), ":", "")
EndIf
// Data e Hora do Atendimento
If Len(cHora)>8
	cHora := SubStr(StrTran(cHora, ":", ""),1,8)
EndIf

// Mesmo pegando a data no tratamento acima nao deixo atribuir para a matriz³
// pois a data correta e vai ser retirada da tag DADOSATENDIMENTO 		 	³
If cTipo $ "1,2,3,4" //Estendido para SADT e Solicitacao de Internacao
	AaDd( aDados, {"DATPRO", PLSAJUDAT(cData) } )
EndIf
AaDd( aDados, {"HORAPRO", cHora } )

// Numero da guia principal
If cTipo == "2"
	cGuiPri := PLSPCONGR("NUMEROGUIAPRINCIPAL,GUIAPRINCIPAL,NUMEROGUIAPRESTADOR",cGuia + "\CABECALHOGUIA\",aMatM,nil,nil,nil,nil,cCodPeg)
	If Empty(cGuiPri)
		cGuiPri := PLSPCONGR("NUMEROGUIAPRINCIPAL",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
	EndIf
ElseIf cTipo == "3" .AND. lEvolu
	cGuiPri := PLSPCONGR("NRGUIAREFERENCIADA",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
ElseIf cTipo == "4"
	cGuiPri := PLSPCONGR("NUMEROGUIAPRINCIPAL",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)	
EndIf

AaDd( aDados, {"GUIPRI" , cGuiPri  } )

// Identificador da guia
If lEvolu
	cNumImp 	:= PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
	cNumEvo 	:= PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
	
	cNumImpOp 	:= PLSPCONGR("NUMEROGUIAOPERADORA",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
	cNumEvoOp 	:= PLSPCONGR("NUMEROGUIAOPERADORA",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
	
	If !Empty(cNumImpOp)
		cNumImp := cNumImpOp
	EndIf
	
	If !Empty(cNumEvoOp)
		cNumEvo := cNumEvoOp
	EndIf
Else
	cNumImp		:= PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
	cNumImpOp	:= PLSPCONGR("NUMEROGUIAOPERADORA",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
	If Empty(cNumImp) .AND. cTipo = "1"
		cNumImp		:= PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia+ "\CABECALHOCONSULTA",aMatM,nil,nil,nil,nil,cCodPeg)
	EndIf
	If Empty(cNumImp) .AND. cTipo = "2"
		cNumImp		:= PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia+ "\CABECALHOSOLICITACAO",aMatM,nil,nil,nil,nil,cCodPeg)
		If Empty(cNumImp)
			cNumImp		:= PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia+ "\CABECALHOGUIA",aMatM,nil,nil,nil,nil,cCodPeg)
		EndIf
	EndIf
	If Empty(cNumImp) .AND. cTipo = "3"
		cNumImp		:= PLSPCONGR("NUMEROGUIAPRESTADOR",cGuia+ "\CABECALHOGUIA",aMatM,nil,nil,nil,nil,cCodPeg)
	EndIf
	
	// Numero da Senha de autorizacao
	If (cTipo == "2" .Or. cTipo == "3") .And. cOrigem == "1"
		
		if cTipGui == "13"
			cNumSen := PLSPCONGR("SENHAAUTORIZACAO",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
		else
			cNumSen := PLSPCONGR("SENHA",cGuia+"\DADOSAUTORIZACAO",aMatM,nil,nil,nil,nil,cCodPeg)
		endif

		If cTipGui $ "02"
			If Empty(cNumSen) .and. !Empty(cNumImpOp)
				cNumSen := cNumImpOp
			Endif
		Endif
		
	EndIf
EndIf

// Pega o numero da operado ao inves da prestadora para gravacao
If GetNewPar("MV_PLSNUIM",.F.)
	cNumImp := cNumImpOp
Endif

// Pega a solicitacao de internacao
If lResInt
	//Indica se a operadora vai trabalhar com a senha ou com nro de autorizacao na internacao
	If GetNewPar("MV_PLSENIN",'1') == '1'
		cNumSen := PLSPCONGR("NUMEROGUIASOLICITACAOINTERNACAO",cGuia,aMatM,,.T.,nil,nil,cCodPeg)
		If Empty(cNumSen)
			cSlvTag := "\DADOSAUTORIZACAO"
			cNumSen := PLSPCONGR("SENHA",cGuia+cSlvTag,aMatM,nil,nil,nil,nil,cCodPeg)
		Endif
	Else
		cSlvTag := "\DADOSAUTORIZACAO"
		cNumSen := PLSPCONGR("SENHA",cGuia+cSlvTag,aMatM,nil,nil,nil,nil,cCodPeg)
		If Empty(cNumSen)
			cNumSen := PLSPCONGR("NUMEROGUIASOLICITACAOINTERNACAO",cGuia,aMatM,,.T.)
		Endif
	Endif
EndIf

If lHonor
	
	If Empty(cNumSen)
		
		If ! Empty(cGuiPri)
			cNumSen := cGuiPri
		Endif
		
		If Empty(cNumSen)
			cNumSen := PLSPCONGR("SENHA",cGuia,aMatM,,.T.)
		EndIf
		
	Endif
	
Endif

// Codigo da Operadora ORIGEM
cRdaOri := PLS973VRDA(AllTrim( PLSPCONGR("CPF,CNPJ,CODIGOPRESTADORNAOPERADORA","CABECALHO\ORIGEM\IDENTIFICACAOPRESTADOR",aMatC,nil,nil,nil,nil,cCodPeg) ))
If Len(alltrim(cRdaOri)) <= TamSX3("BAU_CODIGO")[1]
	cRdaOri := Right(Replicate("0", TamSX3("BAU_CODIGO")[1]) + cRdaOri, TamSX3("BAU_CODIGO")[1])
	nIdx 	 := 1
Else
	cRdaOri := cRdaOri+Space( TamSX3("BAU_CPFCGC")[1]-Len(cRdaOri) )
	nIdx 	:= 4
EndIf
If Empty(cRdaOri)
	xRdaOri  := PLSPCONGR("CODIGOPRESTADORNAOPERADORA","CABECALHO\ORIGEM\IDENTIFICACAOPRESTADOR",aMatC)
	cRdaOri  := xRdaOri
	If Len(alltrim(xRdaOri)) > TamSX3("BAU_CODIGO")[1]//se eh maior significa que o prestador mandou o cnpj na TAG  de codigo
		nIdx 	 := 4
	Else
		cRdaOri := padr(cRdaOri,6)
		nIdx 	 := 1
	Endif
EndIf

If !Empty(cRdaOri)
	BAW->(DbSetOrder(3))
	cRdaAnt := cRdaOri+Space( TamSX3("BAW_CODANT")[1]-Len(cRdaOri) )
	If BAW->(MsSeek(xFilial("BAW")+cOpeMov+cRdaAnt))
		cRdaOri := BAW->BAW_CODIGO
		nIdx 	:= 1
	Endif
Endif

// RDA
PLSIVRDA(cRdaOri,nIdx,,aDados)
//Pego o local de atendimento de acordo com o CNES. Se nao tiver CNES na guia, continua como era, pegando o primeiro local. PL973RETLOC esta no PLSA973l
If CTIPGUI == "06" //Para guia de honorários tem que pegar dessa TAG pra achar o local certo
	cCnes := PLSPCONGR("CNESCONTRATADOEXECUTANTE",cGuia,aMatM,,.T.)
elseif CTIPGUI == "13"
	cCnes := PLSPCONGR("CNESEXEC",cGuia,aMatM,,.T.)
Else
	cCnes := PLSPCONGR("CNES",cGuia,aMatM,,.T.)
EndIf
If !Empty(cCnes)
	If Ascan(aDados,{|x| X[1] =='CODRDA'}) > 0
		cCodLoc := PL973RETLOC(aDados[ASCAN(ADADOS,{|x| X[1] =='CODRDA'}),2],cOpeMov,cCnes)
		AaDd( aDados, {"CODLOC" , cCodLoc } )
	Endif
EndIf

// Ponto de entrada
PLSXPROF("R",cRdaOri,"1",cNumImp,cOrigem,nIdx,cData,cHora,,aDados,aMatC)
If BAU->( Found() )
	cRdaOri	  := BAU->BAU_CODIGO
	cNomRda   := AllTrim(BAU->BAU_NOME)
	cTpCab 	  := AllTrim(BAU->BAU_TIPPE)
	cCCCab	  := AllTrim(BAU->BAU_CPFCGC)
	cTipPOr	  := AllTrim(BAU->BAU_TIPPRE)
Else
	cRdaOri	  := GetNewPar("MV_PLSRDAG",'999999')
	cNomRda   := AllTrim(Posicione("BAU",1,xFilial("BAU")+GetNewPar("MV_PLSRDAG",'999999'),"BAU_NOME"))
	cTpCab 	  := AllTrim(BAU->BAU_TIPPE)
	cCCCab	  := AllTrim(BAU->BAU_CPFCGC)
	cTipPOr	  := AllTrim(BAU->BAU_TIPPRE)
Endif
cRdaGuia := cRdaOri

//Informacoes complementares para processamento no PLSXMOV
If !Empty(cRdaOri)
	AaDd( aDados, {"RDAORI" , cRdaOri } )
	AaDd( aDados, {"ORINME" , cNomRda } )
	AaDd( aDados, {"ORITPE" , cTpCab } )
	AaDd( aDados, {"ORIDOC" , cCCCab } )
	cNomRda := ""
EndIf

cToken := PLSPCONGR("CODVALIDACAO",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
if !Empty(cToken)
	AaDd( aDados, {"TOKEDI" , cToken } )
endIf

// Codigo da Operadora DESTINO
cRegAns   := PLSPCONGR("REGISTROANS","CABECALHO\DESTINO",aMatC,nil,nil,nil,nil,cCodPeg)
cCnpjPres := PLSPCONGR("CNPJ","CABECALHO\DESTINO\IDENTIFICACAOPRESTADOR",aMatC)
If !Empty(cRegAns)
	BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
	If BA0->( MsSeek( xFilial("BA0")+cRegAns ) )
		cOpeMov := BA0->(BA0_CODIDE+BA0_CODINT)
		AaDd( aDados, { "OPEMOV", cOpeMov } )
		AaDd( aDados, { "OPEINT", cOpeMov } )
	Else
		AaDd( aDados, { "OPEMOV", PlsIntPad() } )
		AaDd( aDados, { "OPEINT", PlsIntPad() } )
	EndIf
Elseif !Empty(cCnpjPres)   /// pega pelo CNPJPAGADOR
	BA0->( DbSetOrder(4) ) //BA0_FILIAL+BA0_SUSEP
	If BA0->( MsSeek( xFilial("BA0")+cCnpjPres ) )
		cOpeMov := BA0->(BA0_CODIDE+BA0_CODINT)
		AaDd( aDados, { "OPEMOV", cOpeMov } )
		AaDd( aDados, { "OPEINT", cOpeMov } )
		
	Else
		AaDd( aDados, { "OPEMOV", PlsIntPad() } )
		AaDd( aDados, { "OPEINT", PlsIntPad() } )
	EndIf
Else
	AaDd( aDados, { "OPEMOV", PlsIntPad() } )
	AaDd( aDados, { "OPEINT", PlsIntPad() } )
Endif


//RDA e Profissional executante de cada guia
Do Case
	
	// Consulta
Case cTipo == "1"
	cNomCont := AllTrim( PLSPCONGR("NOMECONTRATADO",cGuia+"\CONTRATADOEXECUTANTE",aMatM,nil,.F.,nil,nil,cCodPeg) )
	cCodRP 	 := AllTrim( PLSPCONGR("CPFCONTRATADO,CNPJCONTRATADO",cGuia+"\CONTRATADOEXECUTANTE",aMatM,nil,.T.,nil,nil,cCodPeg) )
	cCodRP 	 := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
	dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAATENDIMENTO",cGuia+"\DADOSATENDIMENTO",aMatM,nil,nil,nil,nil,cCodPeg)))
	
	nIdx 	 := 4
	If Empty(cCodRP)
		xRdaOri  := Alltrim(PLSPCONGR("CODIGOPRESTADORNAOPERADORA",cGuia+"\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg))
		If Len(xRDAOri) > TamSX3("BAU_CODIGO")[1]
			cCodRP 	 := xRdaOri+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
			nIdx 	 := 4
			BAU->(DbSetOrder(nIdx))
			If !(BAU->(MsSeek(xFilial("BAU")+xRDAOri)))
				
				xRdaOri 	 := AllTrim( PLSPCONGR("CPFCONTRATADO,CNPJCONTRATADO,CODIGOPRESTADORNAOPERADORA","",aMatC,nil,.F.,nil,nil,cCodPeg) )
				
				If Len(xRdaOri) > TamSX3("BAU_CODIGO")[1]
					cCodRP 	 := xRdaOri+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
					nIdx 	 := 4
				else
					cRdaOri := StrZero(Val(cRdaOri),TamSX3("BAU_CODIGO")[1])
					nIdx 	 := 1
				EndIf
			EndIf
		Else
			cRdaOri := StrZero(Val(cRdaOri),TamSX3("BAU_CODIGO")[1])
			nIdx 	 := 1
		Endif
	EndIf
	
	If !Empty(cCodRP)
		PLSIVRDA(cCodRP,nIdx,"E",aDados)
		PLSXPROF("R",cCodRP,"2",cNumImp,cOrigem,nIdx,cData,cHora,"E",aDados,aMatC)
	EndIf
	
	If BAU->( Found() ) .AND. !Empty(cCodRP)
		cCodRP	  := BAU->BAU_CODIGO
		cNomRda	  := Alltrim(BAU->BAU_NOME)
	Else
		cCodRP	  := cRdaOri
	Endif
	cRdaGuia := cCodRP
	
	// Local de Atendimento
	cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL",cGuia+"\PROFISSIONALEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
	If !Empty(cVincBkp)
		cSigla := cVincBkp
	EndIf
	cCrm 	:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+"\PROFISSIONALEXECUTANTE",aMatM,,.F.,.F.,nil,cCodPeg)
	cUf 	:= PLSPCONGR("UF",cGuia+"\PROFISSIONALEXECUTANTE",aMatM,,.T.,nil,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('59', nil, cUf)
	If !Empty(cVincBkp)
		cUf := cVincBkp
	EndIf
	
	cNome   := PLSPCONGR("NOMEPROFISSIONAL",cGuia+"\PROFISSIONALEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg)
	
	//Trata a especialidade do membro
	aAdd(aEspItXML,aClone(PlTrCBOIMP('2',cGuia,aMatM,cOrigem,cTipGui,.F.)))
	cEspExe := aEspItXML[Len(aEspItXML)][1]
	cCboExe := aEspItXML[Len(aEspItXML)][2]
	
	//Trata a especialidade do Prestador contratado
	cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,cEspExe,dDatRea,cCodLoc,lPlsCTEs,.T.)
	aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
	
	//Zera as informacoes para o proximo Item
	PlsFreArr(@aEspItXML)
	
	aAdd(aDados,{"CODESP",cCodEsp})
	aAdd(aDados,{"ESPEXE",cEspExe})
	
	nIdx 	:= 4
	
	PLSIVPRO("",cSigla,cCrm,cUf,nIdx,"E",aDados)
	PLSXSCU("",cSigla,cCrm,cUf,"E",aDados,NIL,NIL,cNome,cCboExe,cData)
	
	If BB0->( Found() )
		cSlgRda := BB0->BB0_CODSIG //Sigla
		cCrmRda := BB0->BB0_NUMCR  //Numero
		cEstRda := BB0->BB0_ESTADO //Estado
		cNomPre := BB0->BB0_NOME
	EndIf

	//SADT e ODONTO
Case cTipo == "2" .OR. cTipo == "4"
	
	If cOrigem == "1"
		cNomCont := AllTrim( PLSPCONGR("NOMECONTRATADO",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,nil,.F.,nil,nil,cCodPeg) )
		cCodRP   := AllTrim( PLSPCONGR("CPFCONTRATADO,CNPJCONTRATADO",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg) )
	Else
		cNomCont := AllTrim( PLSPCONGR("NOMECONTRATADO",cGuia+"\DADOSSOLICITANTE\CONTRATADOSOLICITANTE	",aMatM,,.F.,nil,nil,cCodPeg) )
		cCodRP 	 := AllTrim( PLSPCONGR("CPFCONTRATADO,CNPJCONTRATADO",cGuia+"\DADOSSOLICITANTE\CONTRATADOSOLICITANTE",aMatM,,.F.,nil,nil,cCodPeg) )
	EndIf
	cCodRP := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
	nIdx 	:= 4
	If Empty(cCodRP)
		If cOrigem == "1"
			cCodRP := PLS973VRDA(AllTrim(PLSPCONGR("CODIGOPRESTADORNAOPERADORA",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg)))
		Else
			cCodRP := PLS973VRDA(Alltrim(PLSPCONGR("CODIGOPRESTADORNAOPERADORA",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg)))
			
			cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,,.F.,.F.,nil,cCodPeg)
			cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
			
			If !("ODONTO" $ cGuia)
				dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg)))
			else
				dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAREALIZACAO",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg)))
			EndIf
			
			If !Empty(cVincBkp)
				cSigla := cVincBkp
				cVincBkp := ""
			EndIf
			
			cCrm 	:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,,.F.,.F.,nil,cCodPeg)
			cUf 	:= PLSPCONGR("UF",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,,.T.,.F.,nil,cCodPeg)
			cVincBkp	:= PLSVARVINC('59', nil, cUf)
			
			If !Empty(cVincBkp)
				cSigla := cVincBkp
			EndIf
			
			//Trata a especialidade do membro
			aAdd(aEspItXML,aClone(PlTrCBOIMP('1',cGuia,aMatM,cOrigem,cTipGui)))
			cEspSol := aEspItXML[Len(aEspItXML)][1]
			cCboSol := aEspItXML[Len(aEspItXML)][2]
			
			//Trata a especialidade do Prestador contratado
			cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,cEspExe,dDatRea,cCodLoc,lPlsCTEs,.T.)
			aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
			
			//Zera as informacoes para o proximo Item
			PlsFreArr(@aEspItXML)
			
			aAdd(aDados,{"ESPSOL",cEspSol})
			// Tiss on line tem o executante portanto tenho que exibir o retorno da função cCodEsp
			If lTisOnl
				aAdd(aDados,{"CODESP",cCodEsp})			
			EndIf	
		EndIf
			
		nIdx := 1
		if lisOdonto .and. (empty(cCodRP) .or. cCodRP == "000000")
			cCodRP := cRdaOri
		endif
		If Len(cCodRP) > TamSX3("BAU_CODIGO")[1]
			cCodRP 	 := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
			BAU->(DbSetOrder(4))
			If !(BAU->(MsSeek(xFilial("BAU")+cCodRP)))
				cCodRP  := StrZero(Val(cRdaOri),TamSX3("BAU_CODIGO")[1])
			Else
				cCodRP := BAU->BAU_CODIGO
			EndIf
		Else
			cRdaOri := StrZero(Val(cCodRP),TamSX3("BAU_CODIGO")[1])
		Endif
		
	Else 
		If lTisOnl .And. cOrigem == "2"

			dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg)))
                                
			aAdd(aEspItXML,aClone(PlTrCBOIMP('1',cGuia,aMatM,cOrigem,cTipGui,nil,cCodPeg)))
			cEspSol := aEspItXML[Len(aEspItXML)][1]
			cCboSol := aEspItXML[Len(aEspItXML)][2]
			
			cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,cEspExe,dDatRea,cCodLoc,lPlsCTEs,.T.)
			aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
			
			PlsFreArr(@aEspItXML)
			
			aAdd(aDados,{"ESPSOL",cEspSol})
			aAdd(aDados,{"CODESP",cEspSol})			
		EndIf		
	EndIf
	
	PLSIVRDA(cCodRP,nIdx,,aDados)
	PLSXPROF("R",cCodRP,"5",cNumImp,cOrigem,nIdx,cData,cHora,nil,aDados,aMatC)
	
	If BAU->( Found() )
		cConPrEx := BAU->BAU_CODIGO
		cNomRdEx := BAU->BAU_NOME
	Else
	
		cConPrEx := ""
		cNomRdEx := ""
	Endif
	
	If cOrigem == "1"
		
		nIdx 	:= 4
		cCodPCPL := ""
		
		cCodRP 	:= 	 AllTrim( PLSPCONGR("CPFCONTRATADO,CNPJCONTRATADO",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg) )
		cCodRP 	:= cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
		cNome 		:= 	 AllTrim( PLSPCONGR("NOMECONTRATADO",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg) )
		
		If !("ODONTO" $ cGuia)
			dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg)))
		else
			dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAREALIZACAO",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg)))
		EndIf
		
		nIdx 	:= 3
		
		If Empty(cCodRP)
			cCodRP 	:= StrZero(Val(PLSPCONGR("CODIGOPRESTADORNAOPERADORA",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg)),6)
			nIdx	:= 1
			//Significa que foi enviado o BAU_CODRDA na TAG <CODIGOPRESTADORNAOPERADORA>
			If Len(alltrim(cCodRP)) == 6
				nOrdBAU := BAU->(IndexOrd())
				nRecBAU := BAU->(Recno())
				BAU->(DbSetOrder(1))
				If  BAU->(MsSeek(xFilial("BAU")+padr(cCodRP,6))) .and. !Empty(BAU->BAU_CODBB0)
					cCodRP := BAU->BAU_CODBB0
				Endif
				BAU->(DbGoTo(nRecBAU))
				BAU->(DbSetOrder(nOrdBAU))
			Endif
		EndIf
		
		PLSIVPRO("",'','','',nIdx,"E",aDados)
		PLSXSCU("",'','','',"E",aDados,NIL,NIL,cNome,NIL,cData,aMatM)
		
		If BB0->( Found() )
			cCodPCPL := BB0->BB0_CODIGO
		Else
			cCodPCPL := ""
		Endif
		
		If !Empty(cCodPCPL)
			If BB0->( Found() )
				cCodRP  := PLSRETDAD( aDados,"CODRDA","" )
				cNomRda := PLSRETDAD( aDados,"NOMRDA","" )
				cSlgRda := BB0->BB0_CODSIG
				cCrmRda := BB0->BB0_NUMCR
				cEstRda := BB0->BB0_ESTADO
				cNomPre := BB0->BB0_NOME
				
				cCodBAU := ""
				cEspExe := ""
				
				nRecBAU := BAU->(Recno())
				nOrdBAU := BAU->(IndexOrd())
				BAU->(DbSetOrder(5))
				If BAU->(MsSeek(xFilial("BAU")+BB0->BB0_CODIGO))
					cCodBAU := BAU->BAU_CODBB0
					//Trata a especialidade do membro
					aAdd(aEspItXML,aClone(PlTrCBOIMP('2',cGuia,aMatM,cOrigem,cTipGui,.F.)))
					cEspExe := aEspItXML[Len(aEspItXML)][1]
					cCboExe := aEspItXML[Len(aEspItXML)][2]
					
					//Trata a especialidade do Prestador contratado
					cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,Iif(!Empty(cEspExe),cEspExe,cEspSol),dDatRea,cCodLoc,lPlsCTEs,.T.)
					aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
					
					//Zera as informacoes para o proximo Item
					PlsFreArr(@aEspItXML)
				Endif
				BAU->(DbGoTo(nRecBAU))
				BAU->(DbSetOrder(nOrdBAU))
				
				aSlvBWT := aClone(aMatBWT)
				lEntrou := .F.
				
				While ( nPos := aScan( aMatBWT,{ |x|x[3]=='12' } ) ) > 0
					AaDd( aTpPRec,{ aMatBWT[nPos,2],If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cCodBAU,cEspExe,PlRetUnp(aMatBWT[nPos,2]) } )
					lEntrou := .T.
					
					nSize := Len(aMatBWT)
					aDel(aMatBWT,nPos)
					aSize(aMatBWT,nSize-1)
				Enddo
				
				If !lEntrou
					nPosGPart := IIf(Len(aMatEqu) >= 2 .AND. !Empty(aMatEqu[1]),aMatEqu[2],aScan(aMatM,{|x| 'GRAUPART' $ AllTrim(x[1])}))
					If GetNewPar("MV_PLSPART",.F.) .AND. nPosGPart <> 0
						//AaDd( aTpPRec,{ aMatM[nPosGPart][2] ,If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cCodBAU,cEspExe,PlRetUnp( aMatM[nPosGPart][2])  } )
						AaDd( aTpPRec,{ AllTrim(PLSVARVINC('35','BWT', aMatM[nPosGPart][2])) ,If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cCodBAU,cEspExe,PlRetUnp( AllTrim(PLSVARVINC('35','BWT', aMatM[nPosGPart][2])) )  } )
					Else
						AaDd( aTpPRec,{ GetNewPar("MV_PLSNAPL","O"),If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cCodBAU,cEspExe,PlRetUnp(GetNewPar("MV_PLSNAPL","O"))  } )
					EndIf
				EndIf
				
				aMatBWT := aClone(aSlvBWT)
				AaDd( aDados, {"ATPARG" , aTpPRec } )
				aTpPRec := {}
				
				cNomRda := ""
				cCrmRda := ""
				cSlgRda := ""
				cEstRda := ""
				cNomPre := ""
			EndIf
		EndIf
		If lisOdonto
			csigla := "CRO"
		else
			cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.F.,nil,nil,cCodPeg)
			cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
			If !Empty(cVincBkp)
				cSigla := cVincBkp
			EndIf
		endIf
		
		If lisOdonto
			cCrmS 	:= PLSPCONGR("CROSOLIC",cGuia+"\DADOSPROFISSIONAISRESPONSAVEIS",aMatM,nil,.F.,.F.,nil,cCodPeg)
			cUfS 	:= PLSPCONGR("UFSOLIC",cGuia+"\DADOSPROFISSIONAISRESPONSAVEIS",aMatM,nil,.T.,nil,nil,cCodPeg)
			aadd(aProfOdo, {cCrmS, cUfs, "S"})

			cCrm 	:= PLSPCONGR("CROEXEC",cGuia+"\DADOSPROFISSIONAISRESPONSAVEIS",aMatM,nil,.F.,.F.,nil,cCodPeg)
			cUf 	:= PLSPCONGR("UFEXEC",cGuia+"\DADOSPROFISSIONAISRESPONSAVEIS",aMatM,nil,.T.,nil,nil,cCodPeg)
			aadd(aProfOdo, {cCrm, cUf, "E"})
			
		else
			cCrm 	:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.F.,.F.,nil,cCodPeg)
			cUf 	:= PLSPCONGR("UF",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.T.,nil,nil,cCodPeg)
		endIf

		cVincBkp	:= PLSVARVINC('59', nil, cUf)
		If !Empty(cVincBkp)
			cUf := cVincBkp
		EndIf
		cNome	:= PLSPCONGR("NOMEPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.F.,nil,nil,cCodPeg)

		//Trata a especialidade do membro
		aAdd(aEspItXML,aClone(PlTrCBOIMP('1',cGuia,aMatM,cOrigem,cTipGui)))
		cEspSol := aEspItXML[Len(aEspItXML)][1]
		cCboSol := aEspItXML[Len(aEspItXML)][2]
		
		//Trata a especialidade do Prestador contratado
		cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,Iif(!Empty(cEspExe),cEspExe,cEspSol),dDatRea,cCodLoc,lPlsCTEs,.T.)
		aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
		
		//Zera as informacoes para o proximo Item
		PlsFreArr(@aEspItXML)
		
		aAdd(aDados,{"ESPSOL",cEspSol})
		
		nIdx 	:= 4
		
		if ! lisOdonto
			PLSIVPRO("",cSigla,cCrm,cUf,nIdx,"S",aDados,.F., nil, lisOdonto)
			PLSXSCU("",cSigla,cCrm,cUf,"S",aDados,NIL,.F.,cNome,cCboSol,cData,aMatM )
		Else
			for nIJ := 1 to len(aProfOdo)
				cVincBkp	:= PLSVARVINC('59', nil, aProfOdo[nIJ,2])
				cNome 		:= PLSPCONGR(iif( aProfOdo[nIJ,3] == "S", "NOMEPROFSOLIC", "NOMEPROFEXEC"), cGuia+"\DADOSPROFISSIONAISRESPONSAVEIS",aMatM,nil,.F.,nil,nil,cCodPeg)  
				If !Empty(cVincBkp)
					aProfOdo[nIJ,2] := cVincBkp
				EndIf
				PLSIVPRO("",cSigla,aProfOdo[nIJ,1],aProfOdo[nIJ,2],nIdx,aProfOdo[nIJ,3],aDados,.F., nil, lisOdonto)
				PLSXSCU("",cSigla,aProfOdo[nIJ,1],aProfOdo[nIJ,2],aProfOdo[nIJ,3],aDados,NIL,.F.,cNome,IIF(aProfOdo[nIJ,3]=="S",cCboSol,""),cData,aMatM )
			next
		EndIf
		
	ElseIf cOrigem == "2"
		cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.F.,nil,nil,cCodPeg)
		cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
		If !Empty(cVincBkp)
			cSigla := cVincBkp
		EndIf
		cCrm 	:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.F.,.F.,nil,cCodPeg)
		
		if empty(cUf)
			cUf 	:= PLSPCONGR("UF",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.F.,nil,nil,cCodPeg)
		endif
		
		cVincBkp	:= PLSVARVINC('59', nil, cUf)
		If !Empty(cVincBkp)
			cUf := cVincBkp
		EndIf
		cNome	:= PLSPCONGR("NOMEPROFISSIONAL",cGuia+"\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE",aMatM,nil,.F.,nil,nil,cCodPeg)
		
		If !("ODONTO" $ cGuia)
			dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg)))
		else
			dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAREALIZACAO",cGuia+"\PROCEDIMENTOSSOLICITADOS",aMatM,nil,.F.,nil,nil,cCodPeg)))
		EndIf
		
		//Trata a especialidade do membro
		aAdd(aEspItXML,aClone(PlTrCBOIMP('1',cGuia,aMatM,cOrigem,cTipGui)))
		cEspSol := aEspItXML[Len(aEspItXML)][1]
		cCboSol := aEspItXML[Len(aEspItXML)][2]
		
		//Trata a especialidade do Prestador contratado
		cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,Iif(!Empty(cEspExe),cEspExe,cEspSol),dDatRea,cCodLoc,lPlsCTEs,.T.)
		aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
		
		//Zera as informacoes para o proximo Item
		PlsFreArr(@aEspItXML)

		aAdd(aDados,{"ESPSOL",cEspSol})
			
		nIdx 	:= 4
		
		PLSIVPRO("",cSigla,cCrm,cUf,nIdx,"S",aDados,.T.)
		PLSXSCU("",cSigla,cCrm,cUf,"S",aDados,NIL,.T.,cNome,cCboSol,cData )
		
		cUf := ""
		
	EndIf
	
	//GRI
Case cTipo == "3" .And. !lHonor
	
	If cOrigem == "1"
		cNomCont	:= ""
		cCodRP 	 := AllTrim( PLSPCONGR("CPFCONTRATADO,CNPJCONTRATADO",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg) )
	Else
		cNomCont := AllTrim( PLSPCONGR("NOMEPROFISSIONAL",cGuia+"\IDENTIFICACAOSOLICITANTE\DADOSPROFISSIONALCONTRATADO",aMatM,,.F.,nil,nil,cCodPeg) )
		cCodRP 	 := AllTrim( PLSPCONGR("CPFCONTRATADO,CNPJCONTRATADO",cGuia+"\IDENTIFICACAOSOLICITANTE\DADOSCONTRATADO",aMatM,,.F.,nil,nil,cCodPeg) )
	EndIf
	cCodRP := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
	nIdx := 4
	
	If Empty(cCodRP)
		If cOrigem == "1"
			cCodRP := AllTrim(PLSPCONGR("CODIGOPRESTADORNAOPERADORA",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg))
		Else
			cCodRP := Alltrim(PLSPCONGR("CODIGOPRESTADORNAOPERADORA",cGuia+"\DADOSEXECUTANTE\CONTRATADOEXECUTANTE",aMatM,,.F.,nil,nil,cCodPeg))
		EndIf
		nIdx := 1
		
		If Len(cCodRP) > TamSX3("BAU_CODIGO")[1]
			cCodRP 	 := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
			BAU->(DbSetOrder(4))
			If !(BAU->(MsSeek(xFilial("BAU")+cCodRP)))
				cCodRP  := StrZero(Val(cRdaOri),TamSX3("BAU_CODIGO")[1])
				
			Else
				cCodRP := BAU->BAU_CODIGO
				
			EndIf
		Else
			cRdaOri := StrZero(Val(cCodRP),TamSX3("BAU_CODIGO")[1])
		Endif
		
	EndIf
	
	PLSIVRDA(cCodRP,nIdx,,aDados)
	PLSXPROF("R",cCodRP,"5",cNumImp,cOrigem,nIdx,cData,cHora,,aDados,aMatC)
	
	If BAU->( Found() )
		cCodRP	  := BAU->BAU_CODIGO
		cNomRda   := AllTrim(BAU->BAU_NOME)
	Else
		cCodRP	  := cRdaOri
		cNomRda   := AllTrim(Posicione("BAU",1,xFilial("BAU")+GetNewPar("MV_PLSRDAG",'999999'),"BAU_NOME"))
	EndIf
	cRdaGuia := cCodRP
	
	If cOrigem == "2"
		
		if cTipGui == "11"

			cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL",cGuia+"\DADOSPROFISSIONALSOLICITANTE",aMatM,,.F.,nil,nil,cCodPeg)
			cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
			If !Empty(cVincBkp)
				cSigla := cVincBkp
			EndIf
			cUf 	:= PLSPCONGR("UF",cGuia+"\DADOSPROFISSIONALSOLICITANTE",aMatM,,.T.,nil,nil,cCodPeg)
			cVincBkp	:= PLSVARVINC('59', nil, cUf)
			If !Empty(cVincBkp)
				cUf := cVincBkp
			EndIf
			cNome	:= PLSPCONGR("NOMEPROFISSIONAL",cGuia+"\DADOSPROFISSIONALSOLICITANTE",aMatM,,.F.,nil,nil,cCodPeg)
			cCrm 	:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+"\DADOSPROFISSIONALSOLICITANTE",aMatM,,.F.,nil,nil,cCodPeg)
		else
			cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL",cGuia+"\IDENTIFICACAOSOLICITANTE\DADOSPROFISSIONALCONTRATADO",aMatM,,.F.,nil,nil,cCodPeg)
			cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
			If !Empty(cVincBkp)
				cSigla := cVincBkp
			EndIf
			cCrm 	:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+"\IDENTIFICACAOSOLICITANTE\DADOSPROFISSIONALCONTRATADO",aMatM,,.F.,.F.,nil,cCodPeg)
			cUf 	:= PLSPCONGR("UF",cGuia+"\IDENTIFICACAOSOLICITANTE\DADOSPROFISSIONALCONTRATADO",aMatM,,.T.,nil,nil,cCodPeg)
			cVincBkp	:= PLSVARVINC('59', nil, cUf)
			If !Empty(cVincBkp)
				cUf := cVincBkp
			EndIf
			cNome	:= PLSPCONGR("NOMEPROFISSIONAL",cGuia+"\IDENTIFICACAOSOLICITANTE\DADOSPROFISSIONALCONTRATADO",aMatM,,.F.,nil,nil,cCodPeg)
		endIf

		//Trata a especialidade do membro
		aAdd(aEspItXML,aClone(PlTrCBOIMP('1',cGuia,aMatM,cOrigem,cTipGui)))
		cEspSol := aEspItXML[Len(aEspItXML)][1]
		cCboSol := aEspItXML[Len(aEspItXML)][2]
		
		//Trata a especialidade do Prestador contratado
		cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,cEspExe,dDatRea,cCodLoc,lPlsCTEs,.T.)
		aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
		 
		//Zera as informacoes para o proximo Item
		PlsFreArr(@aEspItXML)
		
		aAdd(aDados,{"ESPSOL",cEspSol})
		
		nIdx	:= 4
		
		PLSIVPRO("",cSigla,cCrm,cUf,nIdx,"S",aDados)
		PLSXSCU("",cSigla,cCrm,cUf,"S",aDados,nil,NIL,cNome,cCboSol,cData)
		
	EndIf
	dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg))) //devido a validação PlMatValida
	
	//GHI
Case cTipo == "3" .And. lHonor
	
	aTpPRec := {}
	cNomCont	:= AllTrim(PLSPCONGR("NOMECONTRATADOEXECUTANTE",cGuia+"\DADOSCONTRATADOEXECUTANTE",aMatM,nil,.F.,nil,nil,cCodPeg))
	cCodRP		:= AllTrim(PLSPCONGR("CODIGONAOPERADORA",cGuia+"\DADOSCONTRATADOEXECUTANTE",aMatM,nil,.F.,nil,nil,cCodPeg))
	
	If Len(cCodRP) > TamSX3("BAU_CODIGO")[1]
		cCodRP 	 := cCodRP+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCodRP) )
		BAU->(DbSetOrder(4))
		If !(BAU->(MsSeek(xFilial("BAU")+cCodRP)))
			cCodRP  := StrZero(Val(cRdaOri),TamSX3("BAU_CODIGO")[1])
			
		Else
			cCodRP := BAU->BAU_CODIGO
			
		EndIf
	Else
		cRdaOri := StrZero(Val(cCodRP),TamSX3("BAU_CODIGO")[1])
	Endif
	
	nIdx 	 := 1
	
	//Muda o indice para procurar no BAU pelo CPF/CNPJ
	If Len(alltrim(cCodRP)) > TamSX3("BAU_CODIGO")[1]
		nIdx 	 := 4
	else
		cCodRP := padr(cCodRP,6)
	endif
	
	PLSIVRDA(cCodRP,nIdx,,aDados)
	PLSXPROF("R",cCodRP,"6",cNumImp,cOrigem,nIdx,cData,cHora,,aDados,aMatC)
	
	If BAU->( Found() )
		cCodRP	  := BAU->BAU_CODIGO
		cNomRda   := AllTrim(BAU->BAU_NOME)
	Else
		cCodRP	  := cRdaOri
		cNomRda   := AllTrim(Posicione("BAU",1,xFilial("BAU")+GetNewPar("MV_PLSRDAG",'999999'),"BAU_NOME"))
	EndIf
	cRdaGuia := cCodRP
	
	dDatRea := PLSAJUDAT(alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+"\PROCEDIMENTOSREALIZADOS",aMatM,,,.F.,nil,cCodPeg))) //devido a validação PlMatValida

EndCase

cRdaExe := PLSPCONGR("CODIGONAOPERADORA",cGuia+"\DADOSEXECUTANTE",aMatM,nil,nil,nil,nil,cCodPeg)
If lTisOnl .And. !Empty(cRdaExe)
	AAdd( aDados, {"RDAEXECUTANTE" , cRdaExe})
EndIf

//Tratamento para substituir o CNPJ/CPF do prestador pelo codigo do sistema
If Len(alltrim(cCodRP)) > 6
	nOrdBAU := BAU->(IndexOrd())
	nRecBAU := BAU->(Recno())
	BAU->(DbSetOrder(4))
	If  BAU->(MsSeek(xFilial("BAU")+cCodRP))
		If !Empty(BAU->BAU_CODBB0)
			cCodRP := BAU->BAU_CODBB0
		Else
			cCodRP := BAU->BAU_CODIGO
		EndIf
	Endif
	BAU->(DbGoTo(nRecBAU))
	BAU->(DbSetOrder(nOrdBAU))
Endif

// Dados do Beneficiario
If lHonor
	cMatric  	:= PLSPCONGR("NUMEROCARTEIRA",cGuia+"\BENEFICIARIO",aMatM,nil,nil,nil,nil,cCodPeg)
	cNomeUsu 	:= PLSPCONGR("NOMEBENEFICIARIO",cGuia+"\BENEFICIARIO",aMatM,nil,nil,.F.,nil,cCodPeg)
	cAtenRN		:= PLSPCONGR("ATENDIMENTORN",cGuia+"\BENEFICIARIO",aMatM,nil,nil,.F.,nil,cCodPeg)
	cMatAntPt	:= PLSPCONGR("NUMEROCARTEIRA",cGuia+"\BENEFICIARIO",aMatM,nil,nil,nil,nil,cCodPeg,,.t.)
Else // 1, 2, 3
	If "ODONTO" $ cGuia
		cAtenRN	:= IIF( EmpTy( PLSPCONGR("ATENDIMENTORN",cGuia,aMatM,nil,nil,.F.,nil,cCodPeg) ), "N", PLSPCONGR("ATENDIMENTORN",cGuia,aMatM,nil,nil,.F.,nil,cCodPeg) )
		cMatric  := PLSPCONGR("NUMEROCARTEIRA",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
		cNomeUsu := PLSPCONGR("NOMEBENEFICIARIO",cGuia,aMatM,,,.F.,nil,cCodPeg)
		cMatAntPt:= PLSPCONGR("NUMEROCARTEIRA",cGuia,aMatM,nil,nil,nil,nil,cCodPeg,,.t.)
	Else 
		cAtenRN	:= IIF( EmpTy( PLSPCONGR("ATENDIMENTORN",cGuia+"\DADOSBENEFICIARIO",aMatM,nil,nil,.F.,nil,cCodPeg) ), "N", PLSPCONGR("ATENDIMENTORN",cGuia+"\DADOSBENEFICIARIO",aMatM,nil,nil,.F.,nil,cCodPeg) )
		cMatric  := PLSPCONGR("NUMEROCARTEIRA",cGuia+"\DADOSBENEFICIARIO",aMatM,nil,nil,nil,nil,cCodPeg)
		cNomeUsu := PLSPCONGR("NOMEBENEFICIARIO",cGuia+"\DADOSBENEFICIARIO",aMatM,,,.F.,nil,cCodPeg)
		cMatAntPt:= PLSPCONGR("NUMEROCARTEIRA",cGuia+"\DADOSBENEFICIARIO",aMatM,nil,nil,nil,nil,cCodPeg,,.t.)
	EndIf
EndIf

//Valido para aceitar: Matricula PLS, Matricula Antiga, Matricula da Empresa
cMatric := PlMatValida(cMatric, "", dDatRea,cMatAntPt)

If !Empty(cMatric)
	AaDd( aDados, {"USUARIO" , cMatric  } )
Else
	aRetuGe := PXMLUsrGe(PlsIntPad())
	If Len(aRetuGe) > 0
		AaDd( aDados, {"USUARIO" , aRetuGe[1]  } )
	EndIf
EndIf

AaDd( aDados, {"NOMUSR" , cNomeUsu } )
AaDd( aDados, {"VIACAR" , "" } )
AaDd( aDados, {"ATENRN",iif(cAtenRN=="S","1","0")})

if cTipGui == "11"
	cNumSen := cGuiPri
endIf

// Procura pelo numero do impresso o numero da liberacao
If ExistBlock("PLSTMLLIB")
	cNumAut := ExecBlock( "PLSTMLLIB",.F.,.F.,{ cNumSen,cOpeMov,cCodRP,cTipo,cMatric,cGuiPri,lHonor,lEvolu,cTipo == "3" .And. !lHonor } )
Else
	cNumAut := cNumSen
EndIf

// Verifica se existe a solicitacao
If lResInt .Or. lHonor .Or. lEvolu
	If !Empty(cNumAut)
		BE4->( DbSetOrder(2) ) //BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
		If BE4->( MsSeek( xFilial("BE4")+padr(cNumAut,18) ) )
			AaDd( aDados, { "NUMSOL", cNumAut } )
			AaDd( aDados, { "NUMPEG", BE4->( BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO ) } )
		Else
			BE4->( DbSetOrder(7) )
			If !(empTy(cNumAut)) .AND. BE4->( MsSeek( xFilial("BE4")+padr(cNumAut,TamSX3("BE4_SENHA")[1]) ) )
				AaDd( aDados, { "NUMSOL", cNumAut } )
				AaDd( aDados, { "NUMPEG", BE4->( BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO ) } )
			Endif
		Endif
		If BE4->(Found())
			cPadConSol	:= BE4->BE4_PADCON
			cPadIntSol	:= BE4->BE4_PADINT
			cCidSol	:= BE4->BE4_CID
			nDiasSol	:= BE4->BE4_DIASIN
		EndIf
	EndIf
EndIf

// Numero do Lote
cNumeLot := AllTrim(PLSPCONGR("NUMEROLOTE","\PRESTADORPARAOPERADORA\LOTEGUIAS",aMatC,nil,nil,nil,nil,cCodPeg))
cNumeSeq := AllTrim(PLSPCONGR("SEQUENCIALTRANSACAO","\CABECALHO\IDENTIFICACAOTRANSACAO",aMatC,nil,nil,nil,nil,cCodPeg))

If Empty(cNumeLot)
	cNumeLot := cNumeSeq
EndIf

// Dados complementares
AaDd( aDados, {"LOTGUI" , cNumeLot} )
AaDd( aDados, {"SEQTRA" , cNumeSeq} )
AaDd( aDados, {"NUMPRE"	, cNumImp } )
AaDd( aDados, {"NUMIMP"	, cNumImp } )
AaDd( aDados, {"TIPPAR"	, __aTpPart } )

// Consulta
cTipCon := PLSPCONGR("TIPOCONSULTA",cGuia+"\DADOSATENDIMENTO",aMatM,nil,nil,.F.,nil,cCodPeg)
cVincBkp	:= PLSVARVINC('52', , cTipCon)
If !Empty(cVincBkp)
	cTipCon := cVincBkp
EndIf

if lGuiaHAT .And. cTipGui == "01" .And. ValType(oJsonHAT['tpCons']) != "U"
	cTipCon  := oJsonHAT['tpCons']
	cVincBkp := PLSVARVINC('52', , cTipCon)
	If !Empty(cVincBkp)
		cTipCon := cVincBkp
	EndIf
endIf

AaDd( aDados, {"TIPCON" , cTipCon } )
If cTipo=="1"
	AaDd( aDados, {"DATPRO" , PLSAJUDAT( PLSPCONGR("DATAATENDIMENTO",cGuia+"\DADOSATENDIMENTO",aMatM,nil,.F.,nil,nil,cCodPeg) ) } )
	cTipAte 	:= cTipAtePad
	cTipAteTiss := cTipAte
	cVincBkp	:= PLSVARVINC('50',, cTipAte)
	cTipAte 	:= iif( !Empty(cVincBkp), cVincBkp, cTipAtePad)
Else
	If !lisOdonto
		cTipCon := PLSPCONGR("TIPOCONSULTA",cGuia+"\DADOSATENDIMENTO",aMatM,nil,nil,.F.,nil,cCodPeg)
		cVincBkp	:= PLSVARVINC('52', , cTipCon)
		If !Empty(cVincBkp)
			cTipCon := cVincBkp
		EndIf
		AaDd( aDados, {"TIPCON" , cTipCon} )
		cTipAte := PLSPCONGR("TIPOATENDIMENTO",cGuia+"\DADOSATENDIMENTO",aMatM,,,.F.,nil,cCodPeg)
		cTipAteTiss := cTipAte
		cVincBkp	:= PLSVARVINC('50',, cTipAte)
		If !Empty(cVincBkp)
			cTipAte := cVincBkp
		EndIf
		
	else
		cTipAte := '04' //Fixo consulta para preenchimento de campos obrigatórios. Pode ser removido quando a estrutura da guia SADT e Odonto forem diferentes
		cTipAteTiss := cTipAte

		AAdd( aDados, {"TIPATO", PLSPCONGR("TIPOATENDIMENTO",cGuia,aMatM,,,.F.,nil,cCodPeg)} )

		AAdd( aDados, {"DATTERMINO", PLSPCONGR("DATATERMINOTRAT",cGuia,aMatM,,,.F.,nil,cCodPeg)} )
		AAdd( aDados, {"TIPFAT", PLSPCONGR("TIPOFATURAMENTO",cGuia,aMatM,,,.F.,nil,cCodPeg)} )
		
		
	EndIf
EndIf
AaDd( aDados, {"TIPATE" , iif(!Empty(cTipAteTiss),cTipAteTiss,cTipAtePad) } )
AaDd( aDados, {"TIPPAC" , iif(!Empty(cTipAte),cTipAte,cTipAtePad) } )

//campos da TISS 4.00.00 - são combos que já seguem o padrão TISS, por isso sem de-para
AAdd( aDados, {"REGATDW", PLSPCONGR("REGIMEATENDIMENTO",cGuia+"\DADOSATENDIMENTO",aMatM,,,.F.,nil,cCodPeg)} )
AAdd( aDados, {"SADOCUW", PLSPCONGR("SAUDEOCUPACIONAL" ,cGuia+"\DADOSATENDIMENTO",aMatM,,,.F.,nil,cCodPeg)} )
AAdd( aDados, {"COBESPW", PLSPCONGR("COBERTURAESPECIAL",cGuia+"\DADOSATENDIMENTO",aMatM,,,.F.,nil,cCodPeg)} )

If cTipo == "2"
	AaDd( aDados, {"INDCLI" , PLSPCONGR("INDICACAOCLINICA",cGuia,aMatM,,,.F.,nil,cCodPeg) } )
	//Envia a cobertura especial na Versao 4.00
	If cVersao >= '4'
		AaDd( aDados, {"COBESP" , PLSPCONGR("COBERTURAESPECIAL",cGuia,aMatM,,,.F.,nil,cCodPeg) } )
	Endif
	cCarAte := PLSPCONGR("CARATERATENDIMENTO",cGuia,aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('23',, cCarAte)
	If !Empty(cVincBkp)
		cCarAte := cVincBkp
	EndIf
	AaDd( aDados, {"TIPADM" , cCarAte } )

ElseIf cTipo == "3" .AND. cOrigem = "2" // Internação Solicitação
	cCarAte := PLSPCONGR("CARATERATENDIMENTO",cGuia + "\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('23',, cCarAte)
	If !Empty(cVincBkp)
		cCarAte := cVincBkp
	EndIf
	AaDd( aDados, {"TIPADM" , cCarAte } )
	AaDd( aDados, {"INDCLI" , PLSPCONGR("INDICACAOCLINICA",cGuia + "\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg) } )
ElseIf cTipo == "3" .AND. !lHonor
	
	cCarAte := PLSPCONGR("CARATERATENDIMENTO",cGuia + "\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('23',, cCarAte)
	If !Empty(cVincBkp)
		cCarAte := cVincBkp
	EndIf
	AaDd( aDados, {"TIPADM" , cCarAte } )
	
EndIf

//<Codigo Diagnostico>
If cTipo == "3" .AND. cOrigem == "1" .AND. !lHonor
	cCid := PLSPCONGR("DIAGNOSTICO",cGuia+"\DADOSSAIDAINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	If Empty(cCid)
		cCid := cCidSol
	EndIf
ElseIf cTipo == "3" .AND. !lHonor
	cCid := PLSPCONGR("DIAGNOSTICOCID",cGuia+"\HIPOTESESDIAGNOSTICAS",aMatM,,,.F.,nil,cCodPeg)
	If Empty(cCid)
		cCid := cCidSol
	EndIf
Else
	cCid := ""
EndIf

If !Empty(cCid)
	AaDd( aDados, {"CIDPRI" , cCid } )
Endif

//<IndicadorAcidente>
If cTipo == "1" .OR. cTipo == "2"
	cIndAci := PLSPCONGR("INDICACAOACIDENTE",cGuia,aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('36',, cIndAci)
	If !Empty(cVincBkp)
		cIndAci := cVincBkp
	EndIf
	
ElseIf cTipo == "3" .AND. cOrigem == "1" .AND. !lHonor
	cIndAci := PLSPCONGR("INDICADORACIDENTE",cGuia + "\DADOSSAIDAINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('36',, cIndAci)
	If !Empty(cVincBkp)
		cIndAci := cVincBkp
	EndIf
	
ElseIf cTipo == "3" .AND. !lHonor
	cIndAci := PLSPCONGR("INDICADORACIDENTE",cGuia+"\HIPOTESESDIAGNOSTICAS",aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('36',, cIndAci)
	If !Empty(cVincBkp)
		cIndAci := cVincBkp
	EndIf
Else
	cIndAci := ""
EndIf

if lGuiaHAT .And. cTipGui	== "01" .And. ValType(oJsonHAT['indAci']) != "U"
	cIndAci  := oJsonHAT['indAci']
	cVincBkp := PLSVARVINC('36',, cIndAci)
	If !Empty(cVincBkp)
		cIndAci := cVincBkp
	EndIf
endIf

cIndCli := PLSPCONGR("INDICACAOCLINICA",cGuia+"\DADOSSOLICITACAO",aMatM,,,.F.,nil,cCodPeg)
if !empty(cIndCli)	
	aadd( aDados, {"INDCLI" , cIndCli } )
endif
If !Empty(cIndAci)
	AaDd( aDados, {"INDACI" , cIndAci } )
Endif
//Envia a cobertura especial na Versao 4.00
If cVersao >= '4'
	cCobEsp := PLSPCONGR("COBERTURAESPECIAL",cGuia,aMatM,,,.F.,nil,cCodPeg)
	If !empty(cCobEsp)	
		aadd( aDados, {"COBESP" , cCobEsp } )
	Endif
Endif
AaDd( aDados, {"NUMIMP" , cNumImp } )
AaDd( aDados, {"NUMLIB" , cNumAut } )

//Internacao
If cTipo == "2"
	
	cCarAte := PLSPCONGR("CARATERATENDIMENTO",cGuia + "\DADOSSOLICITACAO",aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('23',, cCarAte)
	If !Empty(cVincBkp)
		cCarAte := cVincBkp
	EndIf
	
	AaDd( aDados, {"CARSOL" , cCarAte } )
ElseIf ctipo == "3"
	AaDd( aDados, {"AUNMED" , aUnMed } )
	
	cCarAte := PLSPCONGR("CARATERATENDIMENTO",cGuia + "\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('23',, cCarAte)
	If !Empty(cVincBkp)
		cCarAte := cVincBkp
	EndIf
	
	AaDd( aDados, {"CARSOL" , cCarAte } )
	
	// Evolucao/Resumo
	If lEvolu
		
		cTipAco := PLSPCONGR("TIPOACOMODACAOSOLICITADA",cGuia+"\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
		cVincBkp	:= PLSVARVINC('49',, cTipAco)
		If !Empty(cVincBkp)
			cTipAco := cVincBkp
		EndIf
		
		If Empty(cTipAco)
			cTipAco := cPadIntSol
		EndIf
		cQtdDia := PLSPCONGR("QTDIARIASADICIONAIS",cGuia+"\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
		/* Regra removida pois era era relacionada a prorrogacao diretamente na Internacao BE4
		If Empty(cQtdDia)
			cQtdDia := Alltrim(Str(nDiasSol))
		EndIf */
		AaDd( aDados, {"PADINT" , cTipAco } )
		AaDd( aDados, {"QDISOL" , iif(empty(cQtdDia),0,Val(cQtdDia)) } )
		If !(empTy(cPadConSol))
			AAdd( aDados, {"PADCON" , cPadConSol})
		EndIf
	Else
		If !Empty(cPadConSol)
			AaDd( aDados, {"PADCON" , cPadConSol } ) // Pego a informacao da Solicitaçao assim como é feito no remote quando a GRI é referenciada
		EndIf
		If !(empTy(cPadIntSol))
			AAdd( aDados, {"PADINT" , cPadIntSol})
		EndIf
	EndIf
	
	cTipInt := ""
	cGrpInt := PLSPCONGR("TIPOINTERNACAO",cGuia + "\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	cTipInt := PLSVARVINC('57', 'BQR', cGrpInt) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
	
	AaDd( aDados, {"TPEVEN" , cGrpInt } )
	AaDd( aDados, {"TIPINT" , cTipInt } )
	
	cRegInt := PLSPCONGR("REGIMEINTERNACAO",cGuia + "\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	
	cVincBkp	:= PLSVARVINC('41',, cRegInt)
	If !Empty(cVincBkp)
		cRegInt := cVincBkp
	EndIf
	
	If Empty(cRegInt)
		cRegInt := '1'
	Endif
	
	AaDd( aDados, {"REGINT" , cRegInt } )
	AaDd( aDados, {"EMGEST" , PLSPCONGR("EMGESTACAO",cGuia+"\INTERNACAOOBSTETRICA",aMatM,,,.F.,nil,cCodPeg) } )
	
	
	// Monta numerdo de declaracaoes
	nQtdNV 	:= 0
	nQtdNM 	:= 0
	cNumeDN 	:= ""
	cNumeOB 	:= ""
	cCidOB		:= ""
	
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Array criado para diferenciar a estrutura do RN ou do Paciente principal
	// da Guia pois a declaracao de obito por exemplo pode ser tanto do RN como
	// da MAE de acordo com a <IndicadorDORN> (Sim ou Nao)
	// aDeclaracoes [1] = declaracaoNascido
	// aDeclaracoes [2] = diagnosticoObito
	// aDeclaracoes [3] = declaracaoObito
	// aDeclaracoes [4] = indicadorDORN
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	While !Empty( ( aMatNasc := PLSPCONGR("DECLARACAONASCIDO",cGuia+"\DADOSINTERNACAO\DECLARACOES",aMatM,nil,.T.,nil,.T.,cCodPeg) )[1] )
		nPosDec := aMatNasc[2]
		cNumeDN += aMatNasc[1]+","
		nQtdNV ++
		aMatM[nPosDec,1] := "*"+aMatM[nPosDec,1]
	EndDo
	While !Empty( ( aMatOb := PLSPCONGR("DIAGNOSTICOOBITO",cGuia+"\DADOSINTERNACAO\DECLARACOES",aMatM,nil,.T.,nil,.T.,cCodPeg) )[1] )
		nQtdNM ++
		cCidOB := aMatOb[1]
		nPosDec := aMatOb[2]
		For nI := (nPosDec+1) To (nPosDec + 2)
			If aMatM[nI][1] == "DECLARACAOOBITO"
				cNumeOB += aMatM[nI][2]+","
			EndIf
			If aMatM[nI][1] == "INDICADORDORN"
				If Alltrim(Upper(aMatM[nI][2])) == "S" // Quer dizer que o indicador é do RN
					nQtdNM ++
					cCidOB := ""
				EndIf
			EndIf
		Next nI
		aMatM[nPosDec,1] := "*"+aMatM[nPosDec,1]
		
	EndDo
	
	cNumeDN := Left( cNumeDN,Len(cNumeDN)-1 )
	AaDd( aDados, {"NRDCNV" , cNumeDN  } )
	
	cNumeOB := Left( cNumeOB,Len(cNumeOB)-1 )
	AaDd( aDados, {"NRDCOB" , cNumeOB  } )
	
	AaDd( aDados, {"QTNASV" , nQtdNV	} )
	AaDd( aDados, {"QTNASM" , nQtdNM 	} )
	
	cCid2 := PLSPCONGR("DIAGNOSTICO",cGuia+"\DADOSSAIDAINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	If !Empty(cCid2)
		AaDd( aDados, {"CID2" 	, cCid2 } )
	Endif
	
	AaDd( aDados, {"QDISOL"	, Val(PLSPCONGR("QTDIARIASSOLICITADAS",cGuia + "\DADOSINTERNACAO",aMatM,,,.F.,nil,cCodPeg)) } )
	AaDd( aDados, {"DATPRVINT", PLSAJUDAT( PLSPCONGR("DATASUGERIDAINTERNACAO",cGuia + "\DADOSHOSPITALSOLICITADO",aMatM,,,.F.,nil,cCodPeg) ) } )
	
	AaDd( aDados, {"CGCSOLT", PLSPCONGR("CODIGOINDICADONAOPERADORA",cGuia + "\DADOSHOSPITALSOLICITADO",aMatM,,,.F.,nil,cCodPeg) } )

	AaDd( aDados, {"RDACON", PLSPCONGR("CODIGOPRESTADORNAOPERADORA",cGuia + "\IDENTIFICACAOSOLICITANTE\DADOSDOCONTRATADO",aMatM,,,.F.,nil,cCodPeg) } )

	cIndAci := PLSPCONGR("INDICADORACIDENTE",cGuia+"\DADOSSAIDAINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	cVincBkp	:= PLSVARVINC('36',, cIndAci)
	If !Empty(cVincBkp)
		cIndAci := cVincBkp
	EndIf
	AaDd( aDados, {"INDACI" ,  cIndAci} )
	
	cTipAlt := PLSPCONGR("MOTIVOENCERRAMENTO",cGuia+"\DADOSSAIDAINTERNACAO",aMatM,,,.F.,nil,cCodPeg)
	cTipAlt := PLSVARVINC('39','BIY', cTipAlt) //Tabela 39 TISS - Motivo de encerramento
	
	AaDd( aDados, {"CIDOBT" , cCidOB } )
	AaDd( aDados, {"NRDCOB" , IIf(Substr(cNumeOB,Len(cNumeOB),1) == ",", Substr(cNumeOB,1,Len(cNumeOB)-1),cNumeOB) } )
	AaDd( aDados, {"TIPALT" ,cTipAlt } )
	
	cTipFat := alltrim(PLSPCONGR("TIPOFATURAMENTO",cGuia+"\DADOSINTERNACAO" ,aMatM,,,.F.,nil,cCodPeg))
	cVincBkp := alltrim(PLSVARVINC('55', , cTipFat))
	If !Empty(cVincBkp)
		cTipFat := cVincBkp
	Else
		//<!--1- Parcial-->	<!--2- Final-->	<!--3- Complementar-->	<!--4- Total-->
		If cTipFat == "1"
			cTipFat := "P"
		ElseIf cTipFat == "2"
			cTipFat := "T"
		ElseIf cTipFat == "3"
			cTipFat := "P"
		ElseIf cTipFat == "4"
			cTipFat := "T"
		EndIf
	EndIf
	
	//A data de alta deve ser preenchida no Resumo de Internacao por mais que o resumo nao seja total, senao nao e possivel mudar a fase da guia
	cDtFimFat 	:= PLSDELIM( PLSPCONGR("DATAFINALFATURAMENTO",cGuia,aMatM,,,.F.,nil,cCodPeg) )
	cHrFimFat 	:= PLSDELIM( PLSPCONGR("HORAFINALFATURAMENTO",cGuia,aMatM,,,.F.,nil,cCodPeg) )
	AaDd( aDados, {"DTALTA"	, PLSAJUDAT(SubStr(cDtFimFat,1,8)) } )
	AaDd( aDados, {"HRALTA"	, SubStr(cHrFimFat,1,8) } )
	
	AaDd( aDados, {"DTFIMFAT" , PLSAJUDAT(SubStr(cDtFimFat,1,8)) } )
	AaDd( aDados, {"HRFIMFAT" , SubStr(cHrFimFat,1,8) } )
	
	cDtIniFat 	:= PLSDELIM( PLSPCONGR("DATAINICIOFATURAMENTO",cGuia,aMatM,,,.F.,nil,cCodPeg) )
	cHrIniFat 	:= PLSDELIM( PLSPCONGR("HORAINICIOFATURAMENTO",cGuia,aMatM,,,.F.,nil,cCodPeg) )
	AaDd( aDados, {"DTINIFAT" , PLSAJUDAT(SubStr(cDtIniFat,1,8)) } )
	AaDd( aDados, {"HRINIFAT" , SubStr(cHrIniFat,1,8) } )
	AaDd( aDados, {"TIPFAT" , cTipFat } )
	
EndIf

// Observacao
cObs := PLSPCONGR("OBSERVACAO",cGuia,aMatM,,,.F.,nil,cCodPeg)
AaDd( aDados, {"MSGALL" , cObs } )
AaDd( aDados, {"MSG01" , SubStr(cObs,1,nTamObs)  } )
AaDd( aDados, {"MSG02" , SubStr(cObs,nTamObs+1,Len(cObs)) } )
AaDd( aDados, {"CODPEG" , cCodPeg } )

//Itens - CONSULTA
If cTipo =="1"
	aMatIte := {}
	AaDd( aMatIte, {"SEQMOV" , "001" } )
	cSlvDes := ""
	cCodPad := PLSPCONGR("CODIGOTABELA",cGuia+"\DADOSATENDIMENTO\PROCEDIMENTO",aMatM,,,.F.,nil,cCodPeg)
	cSlvPad := cCodPad
	cCodPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+"\DADOSATENDIMENTO\PROCEDIMENTO",aMatM,,,nil,nil,cCodPeg)
	cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
	cSlvPro := cCodPro
	
	cCodPad := Alltrim(PLSVARVINC('87', 'BR4', cCodPad)) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
	cCodPad := padr(cCodPad,tamsx3("BR8_CODPAD")[1])
	cCodPro := PLSVARVINC(cSlvPad, 'BR8', cCodPro,cSlvPad+cCodPro) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
	cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
	dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+"\DADOSATENDIMENTO\DATAATENDIMENTO",aMatM,nil,nil,nil,nil,cCodPeg)))
	
	//Trata a especialidade do membro
	aAdd(aEspItXML,aClone(PlTrCBOIMP('2',cGuia,aMatM,cOrigem,cTipGui)))
	cEspExe := aEspItXML[Len(aEspItXML)][1]
	cCboExe := aEspItXML[Len(aEspItXML)][2]
	
	//Trata a especialidade do Prestador contratado
	cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,cEspExe,dDatRea,cCodLoc,lPlsCTEs,.T.)
	aAdd(aEspItXML[Len(aEspItXML)],cCodEsp)
	
	//Zera as informacoes para o proximo Item
	PlsFreArr(@aEspItXML)
	
	aAdd(aDados,{"CODESP",cCodEsp})
	aAdd(aMatIte,{"ESPEXE",cEspExe})
	aAdd(aMatIte,{"ESPPE",cEspExe})
	
	// Mantido o Ponto de Entrada
	PLSXPAD(@cCodPad,@cCodPro,@cDescric,,cTipGui,cVersao,dDatRea)
	
	BR8->(DbSetOrder(1))
	If !BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .and. cOrigem <> '2'
		//Caso nao encontre com uma tabela e porque e a outra (criado por casos de mais de uma tabela padrao vinculado a mesma terminologia ex.: 01 e 02 -->> 22
		If !PChkTabDup(@cCodPad,cCodPro,cSlvPad)
			cCodPad := GetNewPar("MV_PLCDPXM","01")
			cCodPro := GetNewPar("MV_PLPSPXM","99999994")
			cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		Elseif Empty(cDescric) //Ideal é sempre pegar a descrição fornecida pelo prestador, caso um dia alguem reclame pegar somente as genéricas do PTU
			cDescric := Alltrim(BR8->BR8_DESCRI)
		EndIf
	Elseif Empty(cDescric)
		cDescric := Alltrim(BR8->BR8_DESCRI)
	EndIf
	
	AaDd( aMatIte, {"CODPAD" , cCodPad } )
	AaDd( aMatIte, {"CODPRO" , cCodPro} )
	AaDd( aMatIte, {"SLVPAD" , cSlvPad } )
	AaDd( aMatIte, {"SLVPRO" , cSlvPro} )
	AaDd( aMatIte, {"SLVDES" , cSlvDes} )
	AaDd( aMatIte, {"QTD"	 , 1 } )
	AaDd( aMatIte, {"QTDAUT" , 1 } )
	cVlrPro := StrTran( PLSPCONGR("VALORPROCEDIMENTO",cGuia+"\DADOSATENDIMENTO\PROCEDIMENTO",aMatM,,,.F.,nil,cCodPeg),',',"." )
	AaDd( aMatIte, {"VLRAPR" , Val(cVlrPro) } )
	//::::::::::::::: Somatoria do Valor Total da Guia ::::::::::::::: \\
	nValorTotG += Val(cVlrPro)
	AaDd(aItens,aMatIte)
Else
	lOriSol := cOrigem == "2"
	cZCamProc	:= IIF( !("ODONTO" $ cGuia), "\PROCEDIMENTOSSOLICITADOS\PROCEDIMENTO", Iif(!("SOLIC" $ cGuia),"\PROCEDIMENTOSEXECUTADOS\PROCSOLIC","\PROCEDIMENTOSSOLICITADOS\PROCSOLIC"))
	cZProcs	:= IIF( !("ODONTO" $ cGuia), "\PROCEDIMENTOSSOLICITADOS", IIF(lOriSol, "\PROCEDIMENTOSSOLICITADOS","\PROCEDIMENTOSEXECUTADOS"))
	cZqtdProc	:= IIF( !("ODONTO" $ cGuia), "QUANTIDADESOLICITADA", "QTDPROC")
	cCont := "001"
	
	While !Empty( ( cCodPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+cZCamProc,aMatM,nil,iif("ODONTO" $ cGuia,nil,.T.),nil,nil,cCodPeg) ) )
		aMatIte := {}
		cRegDen := ""
		nPosProc := 0
		AaDd( aMatIte, {"SEQMOV" , cCont } )
		cCont := soma1(cCont)
		cStrFrm := ""
		cFace	:= ""
		
		cCodPad := PLSPCONGR("CODIGOTABELA",cGuia+cZCamProc,aMatM,nil,.T.,.F.,nil,cCodPeg)
		cSlvPad := cCodPad
		cDescric:= PLSPCONGR("DESCRICAOPROCEDIMENTO",cGuia+cZCamProc,aMatM,nil,.T.,.F.,nil,cCodPeg)
		cSlvDes := cDescric
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		cSlvPro := cCodPro
		
		cCodPad := Alltrim(PLSVARVINC('87', 'BR4', cCodPad)) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
		cCodPad := padr(cCodPad,tamsx3("BR8_CODPAD")[1])
		cCodPro := PLSVARVINC(cSlvPad, 'BR8', cCodPro,cSlvPad+cCodPro) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		
		PLSXPAD(@cCodPad,@cCodPro,@cDescric,,cTipGui,cVersao)
			

		If "ODONTO" $ cGuia
			//Informações de ODONTO.
			nPosProc := aScan (aMatM,{ |x|x[1] == "CODIGOPROCEDIMENTO" .and. alltrim(cSlvPro) == alltrim(x[2])})
			cTesteD := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+cZCamProc,aMatM,nil,.T.,nil,nil,cCodPeg)
			nPosProc := nPosProc + 2 
			If aMatM[nPosProc][1] == "CODREGIAO"
				cRegDen := PLSPCONGR("CODREGIAO",cGuia+"\PROCEDIMENTOSEXECUTADOS\DENTEREGIAO",aMatM,,.T.,nil,nil,cCodPeg)
				cRegDen := PLSVARVINC('42', 'B04', allTrim(cRegDen))
				nPosProc++
			Else
				If aMatM[nPosProc][1] == "CODDENTE"
					cRegDen := PLSPCONGR("CODDENTE",cGuia+"\PROCEDIMENTOSEXECUTADOS\DENTEREGIAO",aMatM,,.T.,nil,nil,cCodPeg)
					cRegDen := PLSVARVINC('28', 'B04', allTrim(cRegDen))
					nPosProc++
				EndIf
			EndIf
			
			If aMatM[nPosProc][1] == "DENTEFACE"
				If cOrigem == "1"
					cFace := PLSPCONGR("DENTEFACE",cGuia+"\PROCEDIMENTOSEXECUTADOS",aMatM,,.T.,nil,nil,cCodPeg)
					cFace := PLSVARVINC('32', 'B09', allTrim(cFace))
				Else
					cFace := PLSPCONGR("DENTEFACE",cGuia+"\PROCEDIMENTOSSOLICITADOS",aMatM,,.T.,nil,nil,cCodPeg)
					cFace := PLSVARVINC('32', 'B09', allTrim(cFace))
				Endif
				nPosProc++
			EndIf

		EndIf		
			
		BR8->(DbSetOrder(1))
		If !BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .and. cOrigem <> '2' //nao eh uma solicitacao
			If !PChkTabDup(@cCodPad,cCodPro,cSlvPad) // Caso nao encontre com uma tabela é porque é a outra (criado por casos de mais de uma tabela padrao vinculado a mesma terminologia ex.: 01 e 02 -->> 22
				cCodPad := GetNewPar("MV_PLCDPXM","01")
				cCodPro := GetNewPar("MV_PLPSPXM","99999994")
				cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
			Elseif Empty(cDescric) //Ideal é sempre pegar a descrição fornecida pelo prestador, caso um dia alguem reclame pegar somente as genéricas do PTU
				cDescric := Alltrim(BR8->BR8_DESCRI)
			EndIf
		Elseif Empty(cDescric)
			cDescric := Alltrim(BR8->BR8_DESCRI)
		EndIf
				
		AaDd( aMatIte, {"CODPAD" , cCodPad } )
		AaDd( aMatIte, {"CODPRO" , cCodPro } )
		AaDd( aMatIte, {"DESPRO" , cDescric } )
		AaDd( aMatIte, {"SLVPAD" , cSlvPad } )
		AaDd( aMatIte, {"SLVPRO" , cSlvPro} )
		AaDd( aMatIte, {"SLVDES" , cSlvDes} )
		
		//Inclui dente no array
		B05->(dbSetorder(1))
		if !B05->(msSeek(xFilial("B05")+cCodPad+cCodPro+alltrim(cRegDen)))
			PlGrvDntW(cCodPad, cCodPro, cRegDen, cDescric)
		EndIf
		AaDd( aMatIte, {"DENTE" , allTrim(cRegDen) } )

		//Inclui face no dente
		if !empty(cFace)
			aRetVld := PlRtDOdoFc(cFace, cCodpad, cCodPro, cRegDen)
			if aRetVld[1] .and. aRetVld[2]
				AaDd( aMatIte, {"FACE" , alltrim(cFace) } )
				aAdd( aMatIte, {"DESOFACE" , alltrim(aRetVld[3]) } )
			endif	
		endif	

		//Verifica se o procedimento e de tipo pacote e alimenta os itens para gravacao da B43
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .And. BR8->BR8_TPPROC == "6"
			AaDd( aMatIte, {"PACPRO" , PlRetPac(PLSIntPad(),cRdaOri,cCodPad,cCodPro,,dDatRea) } )
		EndIf

		nQtd := Val( PLSPCONGR(cZqtdProc,cGuia+cZProcs,aMatM,,.T.,.F.,nil,cCodPeg) )
		nVlrProcOd := Val( PLSPCONGR("VALORPROC",cGuia+cZProcs,aMatM,,.T.,.F.,nil,cCodPeg) )

		AaDd( aMatIte, {"QTD" , nQtd } )
		AaDd( aMatIte, {"QTDAUT" , nQtd } )
		AaDd( aMatIte, {"VLRAPR" , nVlrProcOd } )
			
		// Incluir tratamento quando for EVOLUCAO (PRORROGACAO)
		If lEvolu
			AaDd( aMatIte, {"NUMIMP" , cNumImp } )
		EndIf
		If Len(aTpPRec) >0
			AaDd( aMatIte, {"ATPPAR" , aTpPRec } )
		Endif
		
		AaDd(aItens,aMatIte)
	EndDo
	
	// Procedimentos Solicitados
	While !Empty( ( cCodPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+"\PROCEDIMENTOSADICIONAIS\PROCEDIMENTO",aMatM,nil,.T.,nil,nil,cCodPeg) ) )
		aMatIte := {}
		AaDd( aMatIte, {"SEQMOV" , cCont } )
		cCont := soma1(cCont)
		cSlvDes := ""
		cCodPad := PLSPCONGR("CODIGOTABELA",cGuia+"\PROCEDIMENTOSADICIONAIS\PROCEDIMENTO",aMatM,nil,.T.,.F.,nil,cCodPeg)
		cSlvPad := cCodPad
		
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		cSlvPro := cCodPro
		
		cCodPad := Alltrim(PLSVARVINC('87', 'BR4', cCodPad)) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
		cCodPad := padr(cCodPad,tamsx3("BR8_CODPAD")[1])
		cCodPro := PLSVARVINC(cSlvPad, 'BR8', cCodPro,cSlvPad+cCodPro) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		
		PLSXPAD(@cCodPad,@cCodPro,@cDescric,,cTipGui,cVersao)
		
		BR8->(DbSetOrder(1))
		If !BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .and. cOrigem <> '2' //nao eh uma solicitacao
			If !PChkTabDup(@cCodPad,cCodPro,cSlvPad) // Caso nao encontre com uma tabela é porque é a outra (criado por casos de mais de uma tabela padrao vinculado a mesma terminologia ex.: 01 e 02 -->> 22
				cCodPad := GetNewPar("MV_PLCDPXM","01")
				cCodPro := GetNewPar("MV_PLPSPXM","99999994")
				cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
			Elseif Empty(cDescric) //Ideal é sempre pegar a descrição fornecida pelo prestador, caso um dia alguem reclame pegar somente as genéricas do PTU
				cDescric := Alltrim(BR8->BR8_DESCRI)
			EndIf
		Elseif Empty(cDescric)
			cDescric := Alltrim(BR8->BR8_DESCRI)
		EndIf
		
		AaDd( aMatIte, {"CODPAD" , cCodPad } )
		AaDd( aMatIte, {"CODPRO" , cCodPro } )
		AaDd( aMatIte, {"DESPRO" , cDescric } )
		AaDd( aMatIte, {"SLVPAD" , cSlvPad } )
		AaDd( aMatIte, {"SLVPRO" , cSlvPro} )
		AaDd( aMatIte, {"SLVDES" , cSlvDes} )
		
		//Verifica se o procedimento e de tipo pacote e alimenta os itens para gravacao da B43
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .And. BR8->BR8_TPPROC == "6"
			AaDd( aMatIte, {"PACPRO" , PlRetPac(PLSIntPad(),cRdaOri,cCodPad,cCodPro,,dDatRea) } )
		EndIf
		
		nQtd := Val( PLSPCONGR("QUANTIDADESOLICITADA",cGuia+"\PROCEDIMENTOSADICIONAIS",aMatM,,.T.,.F.,nil,cCodPeg) )
		AaDd( aMatIte, {"QTD" , nQtd } )
		AaDd( aMatIte, {"QTDAUT" , nQtd } )
		AaDd( aMatIte, {"VLRAPR" , 0 } )
		
		
		// Incluir tratamento quando for EVOLUCAO (PRORROGACAO)
		If lEvolu
			AaDd( aMatIte, {"NUMIMP" , cNumImp } )
		EndIf
		If Len(aTpPRec) >0
			AaDd( aMatIte, {"ATPPAR" , aTpPRec } )
		Endif
		
		AaDd(aItens,aMatIte)
	EndDo
	
	cTagPart2 := ""
	If lHonor
		cTagProc 		:= "\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\PROCEDIMENTO"
		cTagMae		:= "\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO"
		cTagVo			:= "\PROCEDIMENTOSREALIZADOS"
		cTagEquip		:= "\PROFISSIONAIS"
		cTagPart		:= "GRAUPARTICIPACAO"
	Else
		cTagProc 		:= "\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\PROCEDIMENTO"
		cTagMae		:= "\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO"
		cTagVo			:= "\PROCEDIMENTOSEXECUTADOS"
		cTagPart		:= "GRAUPART"
		cTagPart2		:= "NOMEPROF"
		If cTipo == "2"
			cTagEquip		:= "\EQUIPESADT"
		Else
			cTagEquip		:= "\IDENTEQUIPE\IDENTIFICACAOEQUIPE"
		EndIf
	EndIf
	
	// Procedimentos Realizados\Executados
	While !Empty( ( aMatPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+cTagProc,aMatM,nil,.F.,nil,.T.,cCodPeg, @nLimite) )[1] )
		lAchouVlr  := .F. //Reinicializa a variavel de valor apresentado
		nPosVlrApr := 0 //Reinicializa a posicao da tag CODIGO para verificar se foi informado o valor do procedimento
		if cCodPro <> aMatPro[1]
			cDescric := ''
		endif
		cCodPro := aMatPro[1]
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		cSlvPro := cCodPro
		cSlvDes := ""
		aMatIte := {}
		AaDd( aMatIte, {"SEQMOV" , cCont } )
		cCont := soma1(cCont)
		
		cCodPad := Alltrim(PLSPCONGR("CODIGOTABELA",cGuia+cTagProc,aMatM,nil,.T.,.F.,nil,cCodPeg))
		cSlvPad := cCodPad
		
		cCodPad := Alltrim(PLSVARVINC('87', 'BR4', cCodPad)) // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS
		cCodPad := padr(cCodPad,tamsx3("BR8_CODPAD")[1])
		cCodPro := Alltrim(PLSVARVINC(cSlvPad, 'BR8', cCodPro,cSlvPad+cCodPro)) // Vinculo Terminologia
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		dDatRea := PLSAJUDAT(Alltrim(PLSPCONGR("DATAEXECUCAO",cGuia+cTagVo,aMatM,nil,nil,nil,nil,cCodPeg)))
		
		cSeqTISS := PLSPCONGR("SEQUENCIALITEM",cGuia+cTagMae,aMatM,,.T.,.F.,nil,cCodPeg)
		
		If empTy(cSeqTISS)
			cSeqTISS := PLSPCONGR("SEQUENCIALITEM",cGuia+"\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTO",aMatM,,.T.,.F.,nil,cCodPeg)
		endIf
		
		If Empty(cDescric)
			cDescric:= UPPER(PLSPCONGR("DESCRICAOPROCEDIMENTO",cGuia+"\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTO",aMatM,nil,.T.,.F.,nil,cCodPeg))
		Endif
		
		If Empty(cCodPro)
			cCodPro:= UPPER(PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+"\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTO",aMatM,nil,.T.,.F.,nil,cCodPeg))
		Endif
		
		PLSXPAD(@cCodPad,@cCodPro,@cDescric,,cTipGui,cVersao,dDatRea)
		
		BR8->(DbSetOrder(1))
		If !BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .and. cOrigem <> '2'
			// Caso nao encontre com uma tabela é porque é a outra (criado por casos de mais de uma tabela padrao vinculado a mesma terminologia ex.: 01 e 02 -->> 22
			If !PChkTabDup(@cCodPad,cCodPro,cSlvPad)
				cCodPad := GetNewPar("MV_PLCDPXM","01")
				cCodPro := GetNewPar("MV_PLPSPXM","99999994")
				cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
			Elseif Empty(cDescric) //Ideal é sempre pegar a descrição fornecida pelo prestador, caso um dia alguem reclame pegar somente as genéricas do PTU
				cDescric := Alltrim(BR8->BR8_DESCRI)
			EndIf
		Elseif Empty(cDescric)
			cDescric := Alltrim(BR8->BR8_DESCRI)
		EndIf
		
		AaDd( aMatIte, {"SQTISS" , cSeqTISS } )
		AaDd( aMatIte, {"CODPAD" , cCodPad } )
		AaDd( aMatIte, {"CODPRO" , cCodPro } )
		AaDd( aMatIte, {"DESPRO" , cDescric } )
		AaDd( aMatIte, {"SLVPAD" , cSlvPad } )
		AaDd( aMatIte, {"SLVPRO" , cSlvPro} )
		AaDd( aMatIte, {"SLVDES" , cSlvDes} )
		
		//Verifica se o procedimento e de tipo pacote e alimenta os itens para gravacao da B43
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .And. BR8->BR8_TPPROC == "6"
			AaDd( aMatIte, {"PACPRO" , PlRetPac(PLSIntPad(),cRdaOri,cCodPad,cCodPro,,dDatRea) } )
		EndIf
		
		nQtd := Val( PLSPCONGR("QUANTIDADEEXECUTADA",cGuia+cTagMae,aMatM,nil,.T.,.F.,nil,cCodPeg) )
		AaDd( aMatIte, {"QTD" , nQtd } )
		AaDd( aMatIte, {"QTDAUT" , nQtd } )
		nRedAcr := Val( PLSPCONGR("REDUCAOACRESCIMO",cGuia+cTagMae,aMatM,nil,.T.,.F.,nil,cCodPeg) )
		
		cViaAces := PLSPCONGR("VIAACESSO",cGuia+cTagMae,aMatM,nil,.T.,.F.,nil,cCodPeg, @nLimite)
		cVincBkp := PLSVARVINC('61', 'BGR', cViaAces) // Vinculo Terminologia de Via de Acesso Tabela 61 TISS
		
		If !Empty(cVincBkp)
			cViaAces := cVincBkp
		EndIf
		
		If !Empty(cViaAces)
			BGR->(DbSetOrder(1))
			If BGR->(MsSeek(xFilial("BGR") + cOpeMov + cViaAces))
				AaDd( aMatIte, {"PERVIA" , BGR->BGR_PERC } )
				AaDd( aMatIte, {"VIAACE" , BGR->BGR_CODVIA } )
			EndIf
		Endif
		
		//	TUWSJO - Se não existir equipe de RDA no XML, vai pagar o RDA da Guia
		IF EMPTY(aMatEqu)
			cCodRP := BXX->BXX_CODRDA
			cRDAOri := cCodRP
		ENDIF
		
		//eu carrego todas as composicoes possiveis ou seja, vou pegar o que tiver no bd4
		aSlvTprec := aClone(aTpPRec)
		If Len(aTpPRec) == 0
			For nPos:=1 to Len (aMatBWT)
				AaDd( aTpPRec,{ aMatBWT[nPos,2],If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,'','',PlRetUnp(aMatBWT[nPos,2]) } )
			Next
		Endif
		If Len(aTpPRec) > 0
			AaDd( aMatIte, {"ATPPAR" , aTpPRec } )
		Endif
		aTpPRec := aClone(aSlvTprec)
		
		// Verifica se foi informado valor ao procedimento processado
		nPosVlrApr := aScan (aMatM,{ |x|x[1] == "CODIGOPROCEDIMENTO" .and. alltrim(cSlvPro) == alltrim(x[2]) .And. cTagVo $ x[3]})
		If nPosVlrApr <> 0
			nPosVlrApr ++
			While nPosVlrApr <= len(aMatM) .And. aMatM[nPosVlrApr][1] <> "CODIGOPROCEDIMENTO"
				
				// Se achar a tag de valor, alimenta o array com o que foi apresentado nela
				If aMatM [nPosVlrApr][1] == "VALORUNITARIO"
					nVlrApr := Val( strtran( PLSPCONGR("VALORUNITARIO",cGuia+cTagMae,aMatM,nil,.T.,.F.,nil,cCodPeg),',',"." ) )
					nVlrTotPrc := Val( strtran( PLSPCONGR("VALORTOTAL",cGuia+cTagMae,aMatM,nil,.T.,.F.,nil,cCodPeg),',',"." ) )
					
					nVlrApr := nVlrTotPrc / nQtd //O valor apresentado unitário é o total Dividido pela quantidade
					
					AaDd( aMatIte, {"VLRAPR" , nVlrApr } )
					lAchouVlr := .T.
					Exit
				EndIf
				nPosVlrApr ++
			EndDo
		EndIf
		
		// Se nao achou a tag de valor alimenta o Array com o valor zerado
		If !lAchouVlr
			AaDd( aMatIte, {"VLRAPR" , 0 } )
		EndIf
		
		dDataXX := PLSAJUDAT( PLSPCONGR("DATAEXECUCAO",cGuia+cTagMae,aMatM,nil,.T.,nil,nil,cCodPeg) )
		
		AaDd( aMatIte, {"HORINI" , SubStr(PLSPCONGR("HORAINICIAL",cGuia+cTagMae,aMatM,nil,.T.,nil,nil,cCodPeg),1,6) } )
		AaDd( aMatIte, {"HORFIM" , SubStr(PLSPCONGR("HORAFINAL",cGuia+cTagMae,aMatM,nil,.T.,nil,nil,cCodPeg),1,6) } )
		AaDd( aMatIte, {"DATPRO" , dDataXX} )
		
		If EmpTy(dDataAnt) .AND. !(Empty(dDataXX))
			AaDd( aDados, {"DATPRO" , dDataXX } ) //Adiciona a data do procedimento BD6 para a data da Guia BD5
		EndIf
		dDataAnt := dDataXX
		
		lMemEqui := .F.
		aTpPRe2  := {}
		aPosEnv  := {}
		
		// Pega o tipo de participacao e equipe
		While !Empty( (aMatEqu := PLSPCONGR(If(Empty(cTagPart2),cTagPart,cTagPart+','+cTagPart2),cGuia+cTagMae + cTagEquip,aMatM,nil,nil,nil,.T.,cCodPeg) )[1] ) .And. VerMembro(aMatEqu[2],aMatPro[2],aMatM,cTipGui)
			
			cSigla 	:= ""
			cCrm 	:= ""
			cUf 	:= ""
			cNome   := ""
			//se o prestador nao mandou a posicao do profissional eu devo considerar que pode ser qualquer uma!!
			If Len(aMatEqu[1]) > 2
				aMatEqu[1] := "" //quando ele nao manda o grau de participacao eu gravo vazio para ele considerar todas
				For nJ:=0 to 13
					AaDd( aPosEnv, strzero(nJ,2)  )
				Next
				//eu pego o nome do profssional aqui pois ele vai marcar com *e nao pegar o profisisonal 2 vezes
				cNome   	:= PLSPCONGR("NOMEPROFISSIONAL,NOMEPROF",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg,aMatEqu[2]+9)
			Else
				AaDd( aPosEnv, aMatEqu[1]  )//posicao do profissional enviada pelo prestador
				//eu pego o nome do profssional aqui pois ele vai marcar com *e nao pegar o profisisonal 2 vezes
				cNome   	:= PLSPCONGR("NOMEPROFISSIONAL,NOMEPROF",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg,aMatEqu[2]+9)
			Endif
			
			aMatM[aMatEqu[2],1] := "*"+aMatM[aMatEqu[2],1]
			cCdMbEq := PLSPCONGR("CPFCONTRATADO",cGuia+cTagMae + cTagEquip + "\CODPROFISSIONAL",aMatM,nil,.T.,.F.,nil,cCodPeg,aMatEqu[2]+9)
			cCdMbEq := cCdMbEq+Space( TamSX3("BAU_CPFCGC")[1]-Len(cCdMbEq) )
			
			If !lHonor
				
				cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL,CONSELHO",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg,aMatEqu[2]+9)
				cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
				If !Empty(cVincBkp)
					cSigla := cVincBkp
				EndIf
				cCrm 		:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg,aMatEqu[2]+9)
				cUf 		:= PLSPCONGR("UF",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg)
				cVincBkp	:= PLSVARVINC('59',, cUf)
				If !Empty(cVincBkp)
					cUf := cVincBkp
				EndIf
				
			Else
				cSigla 	:= PLSPCONGR("CONSELHOPROFISSIONAL,CONSELHO",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg,aMatEqu[2]+9)
				cVincBkp	:= PLSVARVINC('26', , STRZERO(VAL(cSigla),2))
				If !Empty(cVincBkp)
					cSigla := cVincBkp
				EndIf
				
				cCrm 		:= PLSPCONGR("NUMEROCONSELHOPROFISSIONAL",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg,aMatEqu[2]+9)
				cUf 		:= PLSPCONGR("UF",cGuia+cTagMae + cTagEquip,aMatM,,.T.,.F.,nil,cCodPeg)
				cVincBkp	:= PLSVARVINC('59',, cUf)
				If !Empty(cVincBkp)
					cUf := cVincBkp
				EndIf
				
			EndIf
			nIdx 	:= 4
			
			//Trata a especialidade do membro
			aAdd(aEspItXML,aClone(PlTrCBOIMP('2',cGuia,aMatM,cOrigem,cTipGui)))
			cEspExe := aEspItXML[Len(aEspItXML)][1]
			cCboExe := aEspItXML[Len(aEspItXML)][2]
			
			PLSIVPRO("",cSigla,cCrm,cUf,nIdx,"E",aDados)
			PLSXSCU("",cSigla,cCrm,cUf,"E",NIL,nil,nil,cNome,cCboExe,cData)
			
			If BB0->( Found() )
				cCdMbEq := BB0->BB0_CODIGO
			EndIf
			
			cCodBAU := ""
			
			If BB0->( Found() )
				cSlgRda := BB0->BB0_CODSIG
				cCrmRda := BB0->BB0_NUMCR
				cEstRda := BB0->BB0_ESTADO
				cNomPre := BB0->BB0_NOME
				//Aqui eu faco um tratamento para que leve la para o BD7 o codigo
				//da RDA (se o profissional for uma RDA) executante no campo BD7_CDPFPR
				nRecBAU := BAU->(Recno())
				nOrdBAU := BAU->(IndexOrd())
				BAU->(DbSetOrder(5))
				If BAU->(MsSeek(xFilial("BAU")+BB0->BB0_CODIGO))
					cCodBAU := BAU->BAU_CODBB0
				Endif
				BAU->(DbGoTo(nRecBAU))
				BAU->(DbSetOrder(nOrdBAU))
			EndIf
	
			//Trata a especialidade do Prestador contratado
			cCodEsp := PlRtEspPre(cOpeMov,cRdaOri,cEspExe,dDatRea,cCodLoc,lPlsCTEs,.T.)
			aAdd(aEspItXML[Len(aEspItXML)], IIF( ValType(cCodEsp) == "C", cCodEsp, cCodEsp[1][1]))
			
			// Monta o tipo de participacao conforme a tabela bwt de/para
			aSlvBWT := aClone(aMatBWT)
			lEntrou := .F.
			while Len(aMatBWT) > 0 .and. ( nPos := aScan( aMatBWT,{ |x|x[3]==aMatEqu[1] .or. Empty(aMatEqu[1]) } ) ) > 0
				AaDd( aTpPRe2,{ aMatBWT[nPos,2],If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cCodBAU,cEspExe,PlRetUnp(aMatBWT[nPos,2]) } )
				//Adiciona a participacao no array de especialidades para localizar a composicao correta na gravacao da BD7.
				aAdd(aEspItXML[Len(aEspItXML)],aMatBWT[nPos,2])
				
				lEntrou := .T.
				nSize 	:= Len(aMatBWT)
				
				aDel(aMatBWT,nPos)
				aSize(aMatBWT,nSize-1)
				
			endDo

			If !lEntrou

				nPosGPart := IIf(Len(aMatEqu) >= 2 .AND. !Empty(aMatEqu[1]),aMatEqu[2],aScan(aMatM,{|x| 'GRAUPART' $ AllTrim(x[1])}))

				If getNewPar("MV_PLSPART",.f.) .and. nPosGPart <> 0
					If ascan(aTpPRe2, {|x| x[1] == AllTrim(PLSVARVINC('35','BWT', aMatM[nPosGPart][2]))}) == 0
						AaDd( aTpPRe2,{ AllTrim(PLSVARVINC('35','BWT', aMatM[nPosGPart][2])) ,If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cCodBAU,cEspExe,PlRetUnp( AllTrim(PLSVARVINC('35','BWT', aMatM[nPosGPart][2])) )  } )
					EndIf
				Else
					AaDd( aTpPRe2,{ GetNewPar("MV_PLSNAPL","O"),If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cCodBAU,cEspExe,PlRetUnp( GetNewPar("MV_PLSNAPL","O")) } )
				EndIf
				
			EndIf
			
			aMatBWT := aClone(aSlvBWT)
			
			cCdMbEq  := ""
			cCrmRda := ""
			cSlgRda := ""
			cEstRda := ""
			cNomPre := ""
		EndDo
		
		//Posicao profissional enviada para um determinado evento
		AaDd( aMatIte, {"POSENV" , aClone(aPosEnv) } )
		
		// Marca no Array aMatM o Procedimento utilizado
		cCodPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+cTagProc,aMatM,nil,.T.,nil,nil,cCodPeg)
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		aClonTp := {}
		
		If Len(aEspItXML) > 0
			//Especialidades dos Executantes
			aAdd(aMatIte, {"ESPXML" , aClone(aEspItXML) } )
			
			//Alimenta na Matriz geral que sera utilizada no aDados
			aAdd(aEspCbXML,aClone(aEspItXML))
			
			//Zera as informacoes para o proximo Item
			PlsFreArr(@aEspItXML)
		EndIf
		
		If Len(aTpPRe2) > 0
			lMemEqui := .T.
			//Se a participacao for enviada via TAG de equiep, o sistema desconsidera todas as participacoes e so grava as participacaoes da equipe
			For nPosXX:=1 to Len(aMatIte)
				If alltrim(aMatIte[nPosXX][1]) == "ATPPAR"
					aClonTp := aClone(aMatIte[nPosXX][2])
					nSize := Len(aMatIte)
					aDel(aMatIte,nPosXX)
					aSize(aMatIte,nSize-1)
					exit
				Endif
			Next
			
			AaDd( aMatIte, {"ATPPAR" , aClone(aTpPRe2) } )
			
			// se a operadora quiser que independente dos membros de equipe o sistema sempre importe as demais unidades - referentes ao CUSTO e FILME (BD7's)
			// ela deve informar neste parametro as classes de operadora que ela deseja que esta regra seja valida.
			// IMPORTANTE - Se as classes que identificam as RDAS DE COOPERATIVAS estiverem neste parametro, pode dar problema
			// por exemplo, a COOPERATIVA DE ANESTESISTAS DE BELO HORIZONTE manda so o AUX no arquivo. Se ele entrar nesse if
			// o sistema ira importar o CUSTO e FILME por exemplo.
			// unidades referentes ao CUsto e Filme:
			// aUnidades := {"COP","COR","UCO","FIL","DOP","CRR","INC","TCR","VDI","VMD","VMT","VTX","REA"}
			
			If  alltrim(cTipPOr) $ GetNewPar("MV_PTRTAEV",'')
				xPt := aScan(aMatIte,{|x| x[1] == "ATPPAR"})
				
				aUnidades := {"COP","COR","UCO","FIL","DOP","CRR","INC","TCR","VDI","VMD","VMT","VTX","REA"}
				If lPLSXMLAUN
					aUnidades := ExecBlock( "PLSXMLAUN",.F.,.F.,aUnidades )
				Endif
				
				For nI:=1 to Len(aClonTp)
					If (nPos := aScan(aMatIte[xPt][2],{|x| alltrim(x[1]) == alltrim(aClonTp[nI][1])})) == 0
						aadd(aMatIte[xPt][2],aClone(aClonTp[nI]))
						aMatIte[xPt][2][Len(aMatIte[xPt][2])][11] := aClone(aUnidades)
					Endif
				Next
			Endif
		Endif

		//pesquiso posição do ATPPAR
		nEspPos := aScan(aMatIte,{|x| x[1] == "ATPPAR"})
		lEspF := .f.
		if nEspPos > 0
			for nEsp := 1 to len(aMatIte[nEspPos,2])
				for nTip := 1 to len(aMatIte[nEspPos,2,nEsp,11])
					// prioridade nas unidades abaixo para setar a especialidade
					if aMatIte[nEspPos,2,nEsp,11,nTip] $ "PPM,HM,HMR,REA"
						aadd( aMatIte, {"ESPPE" , aMatIte[nEspPos,2,nEsp,10] } )
						lEspF := .t.
						exit
					endif
				next
				// se encontrado uma das especialidades saimos do loop
				if lEspF
					exit
				endif	
				if nEsp == len(aMatIte[nEspPos,2])
					// caso não encontramos, setamos a do primeiro array
					aadd( aMatIte, {"ESPPE" , aMatIte[nEspPos,2,1,10] } )
				endif 			
			next
		else
			if len(aEspItXML) > 0
				aadd(aMatIte, {"ESPPE" , aEspItXML[1] })
			endif
		endif
		//se o prestador esta mandando participacoes que ele ja mandou de um determinado procedimento, eu sou obrigado a criar outro evento,
		//pois de fato sao 2 procedimentos distintos... mesmo que a hora e data seja a mesma (porque os hospitais erram mto a digitacao...)
		lForPro := .F.
		For nI:= 1 to Len(aPosEnv)
			If _RtPos('CODPAD',aMatIte) > 0 .and. _RtPos('CODPRO',aMatIte) > 0 .and. _RtPos('HORINI',aMatIte) > 0  .and. _RtPos('HORFIM',aMatIte) > 0 .and. ;
					_RtPos('DATPRO',aMatIte) > 0 .and. _RtPos('QTDAUT',aMatIte) > 0 .and. _RtPos('ATPPAR',aMatIte) > 0  .and. _RtPos('VLRAPR',aMatIte) > 0
				//VARIAVEIS DE POSICIONAMENTO
				
				For nT := 1 To Len(aItens)
					nPCODPAD1 := _RtPos('CODPAD',aItens[nT])
					nPCODPAD2 := _RtPos('CODPAD',aMatIte)
					nPCODPRO1 := _RtPos('CODPRO',aItens[nT])
					nPCODPRO2 := _RtPos('CODPRO',aMatIte)
					nPHORINI1 := _RtPos('HORINI',aItens[nT])
					nPHORINI2 := _RtPos('HORINI',aMatIte)
					nPHORFIM1 := _RtPos('HORFIM',aItens[nT])
					nPHORFIM2 := _RtPos('HORFIM',aMatIte)
					nPDATPRO1 := _RtPos('DATPRO',aItens[nT])
					nPDATPRO2 := _RtPos('DATPRO',aMatIte)
					nPQTDAUT1 := _RtPos('QTDAUT',aItens[nT])
					nPQTDAUT2 := _RtPos('QTDAUT',aMatIte)
					xVCODPAD2 := aMatIte[nPCODPAD2,2]
					xVCODPRO2 := aMatIte[nPCODPRO2,2]
					xVHORINI2 := aMatIte[nPHORINI2,2]
					xVHORFIM2 := aMatIte[nPHORFIM2,2]
					xVDATPRO2 := aMatIte[nPDATPRO2,2]
					xVQTDAUT2 := aMatIte[nPQTDAUT2,2]
					
					If aItens[nT,nPCODPAD1, 2] == xVCODPAD2 .AND.;
							aItens[nT,nPCODPRO1][2] == xVCODPRO2   .and. ;//CODPRO
						aItens[nT,nPHORINI1][2] == xVHORINI2   .and. ;//HORINI
						aItens[nT,nPHORFIM1][2] == xVHORFIM2   .and. ;//HORFIN
						aItens[nT,nPDATPRO1][2] == xVDATPRO2  .and. ;//DATPRO
						aItens[nT,nPQTDAUT1][2] == xVQTDAUT2  .and. (nJ:=_RtPos('POSENV',aItens[nT])) > 0
						
						If aScan(aItens[nT][nJ][2],{|x| x == aPosEnv[nI] }) > 0
							
							lForPro := .T.
							exit
							
						Endif
					EndIf
				Next nT
				
			Endif
		Next
		
		
		// Indica se os eventos deverão ser aglutinados ou se ele
		// ira criar um BD6 para cada evento enviado a regra de aglutinacao eh
		// data + hora + evento + tipo tabela + qtd
		// Nao se soma a quantidade pois o cara esta informando as parta	1234icipacoes
		// em separado referente a um mesmo evento, ou seja, eh um evento so com
		// com varias participacoes												 |
		// O PADRAO EH SEMPRE AGLUTINAR - QUANDO TEM MEMBRO DE EQUIPE				 |
		If lMemEqui .and. !lForPro .And. GetNewPar("MV_PLTISME",.T.) .AND. !lNInfPar	//	TUTXA1
			If _RtPos('CODPAD',aMatIte) > 0 .and. _RtPos('CODPRO',aMatIte) > 0 .and. _RtPos('HORINI',aMatIte) > 0  .and. _RtPos('HORFIM',aMatIte) > 0 .and. ;
					_RtPos('DATPRO',aMatIte) > 0 .and. _RtPos('QTDAUT',aMatIte) > 0 .and. _RtPos('ATPPAR',aMatIte) > 0  .and. _RtPos('VLRAPR',aMatIte) > 0
				lEnAqu := .F.
				For nT:=1 to Len(aItens)
					
					nPCODPAD1 := _RtPos('CODPAD',aItens[nT])
					nPCODPAD2 := _RtPos('CODPAD',aMatIte)
					nPCODPRO1 := _RtPos('CODPRO',aItens[nT])
					nPCODPRO2 := _RtPos('CODPRO',aMatIte)
					nPHORINI1 := _RtPos('HORINI',aItens[nT])
					nPHORINI2 := _RtPos('HORINI',aMatIte)
					nPHORFIM1 := _RtPos('HORFIM',aItens[nT])
					nPHORFIM2 := _RtPos('HORFIM',aMatIte)
					nPDATPRO1 := _RtPos('DATPRO',aItens[nT])
					nPDATPRO2 := _RtPos('DATPRO',aMatIte)
					nPQTDAUT1 := _RtPos('QTDAUT',aItens[nT])
					nPQTDAUT2 := _RtPos('QTDAUT',aMatIte)
					xVCODPAD2 := aMatIte[nPCODPAD2,2]
					xVCODPRO2 := aMatIte[nPCODPRO2,2]
					xVHORINI2 := aMatIte[nPHORINI2,2]
					xVHORFIM2 := aMatIte[nPHORFIM2,2]
					xVDATPRO2 := aMatIte[nPDATPRO2,2]
					xVQTDAUT2 := aMatIte[nPQTDAUT2,2]
					
					If aItens[nT,nPCODPAD1, 2] == xVCODPAD2 .AND.;
							aItens[nT,nPCODPRO1][2] == xVCODPRO2   .and. ;//CODPRO
						aItens[nT,nPHORINI1][2] == xVHORINI2   .and. ;//HORINI
						aItens[nT,nPHORFIM1][2] == xVHORFIM2   .and. ;//HORFIN
						aItens[nT,nPDATPRO1][2] == xVDATPRO2  .and. ;//DATPRO
						aItens[nT,nPQTDAUT1][2] == xVQTDAUT2
						
						nPos:=nT
						
						aItens[nPos][_RtPos('VLRAPR',aItens[nPos])][2] += aMatIte[_RtPos('VLRAPR',aMatIte)][2]    //VLRAPR
						//nesta regra eu garanto que vou importar todas as composicoes que foram de fato enviadas pelo prestador
						//se a posicao 11 do array estiver vazia significa que o prestador me mandou esta composicao
						//sei isso por causa deste For nI:=1 to Len(aClonTp) la encima
						If (nJ:=_RtPos('ATPPAR',aMatIte)) > 0 .and. (xPto:=_RtPos('ATPPAR',aItens[nPos])) > 0
							For nP:=1 to Len(aMatIte[nJ][2])
								If  (nZo := aScan(aItens[nPos][xPto][2],{|x| alltrim(x[1]) == alltrim(aMatIte[nJ][2][nP][1]) })) > 0
									If Len(aItens[nPos][xPto][2][nZo][11]) > 0 .and. Empty(aItens[nPos][xPto][2][nZo][7])//testo se o profissional ainda nao foi preenchido, se nao foi ainda significa que a participacao ta livre, entao eu uso ela
										//If Len(aMatIte[nJ][2][nP][11]) == 0 //----------------esse if aqui com passar do tempo passou a gerar problema em nao gravar todas as composicoes enviadas, mudei pelo Empty(aItens[nPos][xPto][2][nZo][7]) ali acima
										For nE:=1 To Len(aItens[nPos][xPto][2][nZo])
											If ValType(aItens[nPos][xPto][2][nZo][nE]) <> 'A'
												aItens[nPos][xPto][2][nZo][nE] := aMatIte[nJ][2][nP][nE]
											Else
												aItens[nPos][xPto][2][nZo][nE] := aClone(aMatIte[nJ][2][nP][nE])
											Endif
										Next
										//Endif
									Endif
								Else
									aadd(aItens[nPos][xPto][2],aClone(aMatIte[nJ][2][nP]))
								Endif
								
							Next
						Endif
						//neste array eu tenho efetivamente todas as participacoes que realmente foram enviadas para um determinado procedimento
						If (nJ:=_RtPos('POSENV',aItens[nPos])) > 0
							For nP:=1 to Len(aPosEnv)
								aadd(aItens[nPos][nJ][2],aPosEnv[nP])
							Next
						Endif
						lEnAqu := .T.
						exit
					Endif
				Next nT
				If !lEnAqu
					aMatIte := aSort( aMatIte,,, { |x, y| x[1] < y[1] } )
					AaDd(aItens,aClone(aMatIte))
				Endif
			Else
				aMatIte := aSort( aMatIte,,, { |x, y| x[1] < y[1] } )
				AaDd(aItens,aClone(aMatIte))
			Endif
		Else
			aMatIte := aSort( aMatIte,,, { |x, y| x[1] < y[1] } )
			AaDd(aItens,aClone(aMatIte))
		Endif
	EndDo
	
	// Outras Despesas
	nLimite := 1
	While !Empty( ( cCodPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,.F.,nil,nil,cCodPeg, @nLimite) ) )
		lAchouVlr  := .F. //Reinicializa a variavel de valor apresentado
		nPosVlrApr := 0 //Reinicializa a posicao da tag CODIGO para verificar se foi informado o valor do procedimento
		cCodProxml	:=	""
		aMatIte := {}
		AaDd( aMatIte, {"SEQMOV" , cCont } )
		cCont := soma1(cCont)
		
		cCodPad := PLSPCONGR("CODIGOTABELA",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,.T.,.F.,nil,cCodPeg)
		cSlvPad := cCodPad
		cDescric := PLSPCONGR("DESCRICAOPROCEDIMENTO",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,.T.,.F.,nil,cCodPeg)
		cSlvDes := cDescric		
		
		cCodPad := PLSVARVINC('87', 'BR4', cCodPad) // Vinculo Terminologia de tipo de tabelas Tabela 87 TISS
		cCodPad := padr(cCodPad,tamsx3("BR8_CODPAD")[1])
		
		cCodPro := StrTran( StrTran( strTran( cCodPro, chr(9), ""), chr(10), ""), chr(13), "")
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		cSlvPro := cCodPro
		
		cCodPro := PLSVARVINC(cSlvPad, 'BR8', cCodPro,cSlvPad+cCodPro) // Vinculo Terminologia de procedimento Tabela 22 TISS
		
		// Tipo de Despesa
		cTpProc := AllTrim(PLSPCONGR("CODIGODESPESA",cGuia+"\OUTRASDESPESAS\DESPESA",aMatM,nil,.T.,.F.,nil,cCodPeg))
//		sequencialItem, itemVinculado
//		cTpProc := AllTrim(PLSPCONGR("CODIGODESPESA",cGuia+"\OUTRASDESPESAS\DESPESA",aMatM,nil,.T.,.F.,nil,cCodPeg))
		AaDd( aMatIte, {"SQTISS" , PLSPCONGR("SEQUENCIALITEM",cGuia+"\OUTRASDESPESAS\DESPESA",aMatM,,.T.,.F.,nil,cCodPeg) } )
		AaDd( aMatIte, {"IDOUTD" , PLSPCONGR("ITEMVINCULADO" ,cGuia+"\OUTRASDESPESAS\DESPESA",aMatM,,.T.,.F.,nil,cCodPeg) } )
		
		cSlvTpPr:= cTpProc
		cVincBkp := PLSVARVINC('25', "", cTpProc) // Vinculo Terminologia de Codigo da despesa Tabela 25 TISS
		If Empty(cVincBkp) // Se nao tem terminologia executa a regra antiga
			Do Case
			Case cTpProc == "01"
				cTpProc := "7" 	//Gases Medicinais
			Case cTpProc == "02"
				cTpProc := "2" 	//Medicamento
			Case cTpProc == "03"
				cTpProc := "1" 	//Material
			Case cTpProc == "04"
				cTpProc := "3" 	//Taxas
			Case cTpProc == "05"
				cTpProc := "4" 	//Diarias
			Case cTpProc == "06"
				cTpProc := "8" 	//Alugueis
			EndCase
		Else
			cTpProc := cVincBkp
		EndIf
		
		cCodProxml:=cCodPro
		dDatRea := PLSAJUDAT( PLSPCONGR("DATAEXECUCAO",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,nil,nil,nil,cCodPeg) )
		
		If Empty(cCodPro)
			cCodPro:= UPPER(PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+"\OUTRASDESPESAS\DESPESA",aMatM,nil,.T.,.F.,nil,cCodPeg))
		Endif
		
		If Empty(cDescric)
			cDescric:= UPPER(PLSPCONGR("DESCRICAOPROCEDIMENTO",cGuia+"\OUTRASDESPESAS\DESPESA",aMatM,nil,.T.,.F.,nil,cCodPeg))
		Endif
		
		PLSXPAD(@cCodPad,@cCodPro,@cDescric,@cTpProc,cTipGui,cVersao,dDatRea)
		
		BR8->(DbSetOrder(1))
		If !BR8->( MsSeek(xFilial("BR8")+cCodPad+Alltrim(cCodPro)) ) .and. cOrigem <> '2' //nao eh uma solicitacao
			If !PChkTabDup(@cCodPad,Alltrim(cCodPro),cSlvPad) // Caso nao encontre com uma tabela é porque é a outra (criado por casos de mais de uma tabela padrao vinculado a mesma terminologia ex.: 01 e 02 -->> 22
				cCodPad := GetNewPar("MV_PLCDPXM","01")
				cCodPro := GetNewPar("MV_PLPSPXM","99999994")
				cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
			Elseif Empty(cDescric) //Ideal é sempre pegar a descrição fornecida pelo prestador, caso um dia alguem reclame pegar somente as genéricas do PTU
				cDescric := Alltrim(BR8->BR8_DESCRI)
			EndIf
		Elseif Empty(cDescric)
			cDescric := Alltrim(BR8->BR8_DESCRI)
		EndIf
		
		AaDd( aMatIte, {"CODPAD" , cCodPad } )
		AaDd( aMatIte, {"CODPRO" , cCodPro } )
		AaDd( aMatIte, {"DESPRO" , cDescric } )
		AaDd( aMatIte, {"SLVPAD" , cSlvPad } )
		AaDd( aMatIte, {"SLVPRO" , cSlvPro} )
		AaDd( aMatIte, {"SLVDES" , cSlvDes} )
		
		//Verifica se o procedimento e de tipo pacote e alimenta os itens para gravacao da B43
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .And. BR8->BR8_TPPROC == "6"
			AaDd( aMatIte, {"PACPRO" , PlRetPac(PLSIntPad(),cRdaOri,cCodPad,cCodPro,,dDatRea) } )
		EndIf
		
		AaDd( aMatIte, {"MEDIDA" , PLSPCONGR("UNIDADEMEDIDA",cGuia + "\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,,.T.,.F.,nil,cCodPeg) } )
		
		nQtd := Val( PLSPCONGR("QUANTIDADEEXECUTADA",cGuia + "\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,,.T.,.F.,nil,cCodPeg) )
		AaDd( aMatIte, {"QTD" , nQtd } )
		AaDd( aMatIte, {"QTDAUT" , nQtd } )
		
		//garanto que o Reducao/acrescimo vai sempre ficar no formato X.XX
		nRedAcr := Val(Left(PadR(StrTran(PLSPCONGR("REDUCAOACRESCIMO",cGuia+cTagMae,aMatM,nil,.T.,.F.,nil,cCodPeg),".",""),3,"0"),3)) / 100
		
		AaDd( aMatIte, {"HORINI" , SubStr(PLSPCONGR("HORAINICIAL",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,.T.,nil,nil,cCodPeg),1,5) } )
		AaDd( aMatIte, {"HORFIM" , SubStr(PLSPCONGR("HORAFINAL",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,,.T.,nil,nil,cCodPeg),1,5) } )
		AaDd( aMatIte, {"DATPRO" , PLSAJUDAT( PLSPCONGR("DATAEXECUCAO",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,,.T.,nil,nil,cCodPeg) ) } )
		
		aSlvTprec := aClone(aTpPRec)
		If Len(aTpPRec) == 0
			For nPos:=1 to Len (aMatBWT)
				AaDd( aTpPRec,{ aMatBWT[nPos,2],If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,'','',PlRetUnp(aMatBWT[nPos,2]) } )
			Next
		Endif
		
		If Len(aTpPRec) == 0	//	TUUPVY
			AaDd( aTpPRec,{ GetNewPar("MV_PLSNAPL","O"),If(Empty(cConPrEx),cCodRP,cConPrEx),If(Empty(cNomRdEx),cNomRda,cNomRdEx),cCrmRda,cSlgRda,cEstRda,cNomPre,.T.,cRdaGuia,cEspExe,PlRetUnp( GetNewPar("MV_PLSNAPL","O")) } )
			AaDd( aDados, {"NINFEQ" , .T. } )
			lNInfPar := .T.
		Else
			AaDd( aDados, {"NINFEQ" , .F. } )
			lNInfPar := .F.
		EndIf
		
		If Len(aTpPRec) > 0
			AaDd( aMatIte, {"ATPPAR" , aTpPRec } )
		Endif
		aTpPRec := aClone(aSlvTprec)
		
		// Verifica se foi informado valor da despesa processada
		nPosVlrApr := aScan (aMatM,{ |x|x[1] == "CODIGOPROCEDIMENTO" .and. (alltrim(cSlvPro) == alltrim(fwcutoff(x[2])) .or. alltrim(cCodProxml) == alltrim(fwcutoff(x[2])) ) .And. "\OUTRASDESPESAS" $ x[3]})
		If nPosVlrApr <> 0
			nPosVlrApr ++
			While nPosVlrApr <= len(aMatM) .And. aMatM[nPosVlrApr][1] <> "CODIGO"
				
				// Se achar a tag de valor, alimenta o array com o que foi apresentado nela
				If aMatM [nPosVlrApr][1] == "VALORUNITARIO"
					nVlrApr := Val( strtran( PLSPCONGR("VALORUNITARIO",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,.T.,.F.,nil,cCodPeg),',',"." ) )
					nVlrTotPrc := Val( strtran( PLSPCONGR("VALORTOTAL",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,.T.,.F.,nil,cCodPeg),',',"." ) )
					//::::::::::::::: Somatoria do Valor Total da Guia ::::::::::::::: \\
					//				nValorTotG += (nQtd * nVlrApr)
					
					nvlrApr := nVlrTotPrc / nQtd //O valor apresentado unitário é o total Dividido pela quantidade
					nValorTotG += nVlrTotPrc
					AaDd( aMatIte, {"VLRAPR" , nVlrApr } )
					lAchouVlr := .T.
					Exit
				EndIf
				nPosVlrApr ++
			EndDo
		EndIf
		
		// Se nao achou a tag de valorunitario alimenta o Array com o valor zerado
		If !lAchouVlr
			AaDd( aMatIte, {"VLRAPR" , 0 } )
		EndIf
		
		// Marca no Array aMatM a Despesa utilizada
		cCodPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+"\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS",aMatM,nil,.T.,nil,nil,cCodPeg)
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		
		AaDd( aMatIte, {"TPPROC" , cTpProc } )
		AaDd(aItens,aMatIte)
	EndDo
	
	// OPME Solicitadas	-- OPMESOLICITADAS\OPMESOLICITADA\IDENTIFICACAOOPME\CODIGOPROCEDIMENTO
	
	If cTipo == "3" .AND. cOrigem == "2"
		cTagMae 	:= "\ANEXOCLINICOPRORROGACAO"
		cTagFull	:= ""
	Else
		cTagMae 	:= "\ANEXOCLINICO"
		cTagFull	:= cTagMae + "\SOLICITACAOOPME\OPMESOLICITADAS\OPMESOLICITADA\IDENTIFICACAOOPME"
	EndIf
	While !Empty( ( cCodPro := PLSPCONGR("CODIGOPROCEDIMENTO",cGuia+cTagFull,aMatM,,.T.,nil,nil,cCodPeg) ) )
		aMatIte := {}
		AaDd( aMatIte, {"SEQMOV" , cCont } )
		cCont := soma1(cCont)
		
		cCodPad := PLSPCONGR("CODIGOTABELA",cGuia+cTagFull,aMatM,,.T.,.F.,nil,cCodPeg,) // Ajustado pois estava na posição do parâmetro errado e assim dando error.log
		cSlvPad := cCodPad
		cDescric := PLSPCONGR("DESCRICAOPROCEDIMENTO",cGuia+cTagFull,aMatM,,.T.,.F.,nil,cCodPeg)
		cSlvDes := cDescric
		cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
		cSlvPro := cCodPro
		
		cCodPad := PLSVARVINC('87', 'BR4', cCodPad) // Vinculo Terminologia de tipo de tabelas Tabela 87 TISS
		cCodPad := padr(cCodPad,tamsx3("BR8_CODPAD")[1])
		cCodPro := PLSVARVINC(cSlvPad, 'BR8', cCodPro,cSlvPad+cCodPro) // Vinculo Terminologia de procedimento Tabela 22 TISS
		
		PLSXPAD(@cCodPad,@cCodPro,@cDescric,,cTipGui,cVersao)
		
		BR8->(DbSetOrder(1))
		If !BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .and. cOrigem <> '2' //nao eh uma solicitacao
			If !PChkTabDup(@cCodPad,cCodPro,cSlvPad) // Caso nao encontre com uma tabela é porque é a outra (criado por casos de mais de uma tabela padrao vinculado a mesma terminologia ex.: 01 e 02 -->> 22
				cCodPad := GetNewPar("MV_PLCDPXM","01")
				cCodPro := GetNewPar("MV_PLPSPXM","99999994")
				cCodPro := padr(cCodPro,tamsx3("BR8_CODPSA")[1])
			Elseif Empty(cDescric) //Ideal é sempre pegar a descrição fornecida pelo prestador, caso um dia alguem reclame pegar somente as genéricas do PTU
				cDescric := Alltrim(BR8->BR8_DESCRI)
			EndIf
		Elseif Empty(cDescric)
			cDescric := Alltrim(BR8->BR8_DESCRI)
		EndIf
		
		AaDd( aMatIte, {"CODPAD" , cCodPad } )
		AaDd( aMatIte, {"CODPRO" , cCodPro } )
		AaDd( aMatIte, {"DESPRO" , cDescric } )
		AaDd( aMatIte, {"SLVPAD" , cSlvPad } )
		AaDd( aMatIte, {"SLVPRO" , cSlvPro} )
		AaDd( aMatIte, {"SLVDES" , cSlvDes} )
		
		//Verifica se o procedimento e de tipo pacote e alimenta os itens para gravacao da B43
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) ) .And. BR8->BR8_TPPROC == "6"
			AaDd( aMatIte, {"PACPRO" , PlRetPac(PLSIntPad(),cRdaOri,cCodPad,cCodPro,,dDatRea) } )
		EndIf
		
		nQtd := Val( PLSPCONGR("QUANTIDADESOLICITADA",cGuia+cTagMae+"\SOLICITACAOOPME\OPMESOLICITADAS\OPMESOLICITADA",aMatM,,.T.,.F.,nil,cCodPeg) )
		AaDd( aMatIte, {"QTD" , nQtd } )
		AaDd( aMatIte, {"QTDAUT" , nQtd } )
		nVlrApr := Val( strtran( PLSPCONGR("VALORSOLICITADO",cGuia+cTagMae+"\SOLICITACAOOPME\OPMESOLICITADAS\OPMESOLICITADA",aMatM,,.T.,.F.,nil,cCodPeg),',',"." ) )
		AaDd( aMatIte, {"VLRAPR" , nVlrApr } )
		AaDd(aItens,aMatIte)
	EndDo
EndIf

If Len(aEspCbXML) > 0
	aAdd(aDados,{"ESPXML", aClone(aEspCbXML) })
	//Zera as informacoes para o proximo Item
	PlsFreArr(@aEspCbXML)
EndIf

// Em alguns casos no XMOV estava indo a RDA em branco, ocasionava geração indevida de PEGs
If Empty(PLSRETDAD( aDados,"CODRDA","" ))
	AaDd( aDados, {"CODRDA" , Iif(Empty(cCodRP),cRdaOri,cCodRP)  } )
EndIf

If BE4->( FieldPos("BE4_CNES") ) > 0 .AND. BD5->( FieldPos("BD5_CNES") ) > 0 .AND. Empty(cCnes)// Tratamento para alguns clientes e essencial essa informação na Guia.
	AaDd( aDados, {"CNES" , PLSPCONGR("CNES","\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIACONSULTA\CONTRATADOEXECUTANTE\",aMatM,nil,.T.,.F.,nil,cCodPeg) } )
ElseIf !Empty(cCnes)
	AaDd( aDados, {"CNES" , cCnes } )
EndIf

cTokEdi := PLSPCONGR("CODVALIDACAO",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
If !Empty(cTokEdi)
	AAdd( aDados, {"TOKEDI" , cTokEdi})
EndIf
cAusenciaCod := PLSPCONGR("AUSENCIACODVALIDACAO",cGuia,aMatM,nil,nil,nil,nil,cCodPeg)
if !Empty(cAusenciaCod)
	AaDd( aDados, {"AUSENCIACOD" , cAusenciaCod } )
endIf

//Retorno a matricula de intercambio para montar arquivo de resposta
aDadUsrRet := PLSDADUSR(cMatric,'1',.F.,dDatabase)
If len(aDadUsrRet) >= 45 .And. aDadUsrRet[45] <> PlsIntPad()
	If lHonor
		cMatric  := PLSPCONGR("NUMEROCARTEIRA",cGuia+"\BENEFICIARIO",aMatM,nil,nil,nil,nil,cCodPeg)
	Else
		cMatric  := PLSPCONGR("NUMEROCARTEIRA",cGuia+"\DADOSBENEFICIARIO",aMatM,nil,nil,nil,nil,cCodPeg)
	EndIf
Else
	gerRegB00(@cNumProto,nil,iif(lInter,"BE4","BEA"),.T.)
	AaDd( aDados, {"PROTOC" , cNumProto } )
EndIf

AaDd(aRetAux,cTpCab)								//1
AaDd(aRetAux,cCCCab)								//2
AaDd(aRetAux,PLSRETDAD( aDados,"CODRDA",cCodRP ))  //3
AaDd(aRetAux,PLSRETDAD( aDados,"NOMRDA",cNomCont ))	//4
AaDd(aRetAux,PLSRETDAD( aDados,"TPCRDA","" ))  		//5
AaDd(aRetAux,PLSRETDAD( aDados,"CCRDA","" ))   		//6
AaDd(aRetAux,cMatric)                           	//7
AaDd(aRetAux,cNomeUsu)                          	//8
AaDd(aRetAux,cNumeLot)                          	//9
AaDd(aRetAux,cNumImp)                          		//10
AaDd(aRetAux,lHonor)                            	//11
AaDd(aRetAux,lResInt)                           	//12
AaDd(aRetAux,cNumeSeq)                          	//13
AaDd(aRetAux,PLSAJUDAT(cData))                  	//14
AaDd(aRetAux,cRdaOri)                           	//15
AaDd(aRetAux,"")                           	//16 CNES
AaDd(aRetAux, nValorTotG )                       //17 Valor Total da Guia
AaDd(aRetAux, cAtenRN )                       //18 Atendimento RN
AaDd(aRetAux, "" )   		                        //19 StTiss
AaDd(aRetAux, PLSAJUDAT(cData) )                    //20 Data Autorizacao

//Limpa o array com os caminhos das tags de CBOS
aPathTag := {}

If (cTipo == "2" .And. cOrigem == "2") .Or. (cTipo == "3" .And. cOrigem == "2")
   
	cTipQui := PLSPCONGR("TUMOR",cGuia,aMatM,,.T.)
	cJustTe := PLSPCONGR("JUSTIFICATIVATECNICA",cGuia,aMatM,,.T.)
	cTipRad := PLSPCONGR("NRDIAS",cGuia,aMatM,,.T.)

	If !Empty(cTipQui)
		aReProc := PLANEPROC("1", "07", aItens, aMatM,)
	ElseIf !Empty(cJustTe)	
		aReProc := PLANEPROC("3", "09", aItens, aMatM,)	
	EndIf
	If !Empty(aReProc) .And. aReProc[1]
		For nProc := 1 to Len(aReProc[3])
			aAdd(aItens, aReProc[3][nProc])//Inserção dos procedimentos QUIMIO na liberação Sadt
		Next nProc
	EndIf

	//Atualiza TIPATE
	if ( nPos := aScan(aDados,{|x|x[1] == "TIPATE"}) ) > 0
		if !Empty(cTipQui)
			aDados[nPos,2] := "08"
		elseIf !Empty(cTipRad)
			aDados[nPos,2] := "09"
		endIf
	endIf

EndIf

if "ODONTO" $ cGuia
/*
Formato esperado do array:
[1] - número do anexo no prestador
[2] - número da guia principal (guia à qual o anexo está vinculado)
[3] - número do anexo na operadora (pode vir em branco)
[4] - Array dos dentes - formato { {[código do dente (numérico)],[código da situação (caractere)]}, ... } 
[5] - informação sobre o campo 9 - sinais clínicos de doença periodontal
[6] - informação sobre o campo 10 - alteração de tecidos moles
[7] - Observação
[8] - Código da RDA
[9] - número da guia principal na operadora (guia à qual o anexo está vinculado, mas o número gerado pelo protheus) (pode vir em branco)
*/
	cTagAne := Upper("\odontoInicial\")
	ctagAneBus := ""

	ctagAneBus := Upper("numeroGuiaAnexo")
	cNSitIniPre := PLSPCONGR(ctagAneBus,cGuia + cTagAne,aMatM,,.T.)

	if !empTy(cNSitIniPre)
		aSituIni := {}
		aDadDente	:= {}
		nDente := 0
		cSituDen := ""

		ctagAneBus := Upper("numeroGuiaReferenciada")
		cNguiPriPre := PLSPCONGR(ctagAneBus,cGuia + cTagAne,aMatM,,.T.)

		ctagAneBus := Upper("numeroGuiaOperadora")
		cNAnexoOpe	:= PLSPCONGR(ctagAneBus,cGuia + cTagAne,aMatM,,.T.)

		ctagAne := Upper("situacaoClinica\dentes\")

		ctagBusWhi := Upper("elementoDentario")
		ctagAneBus := Upper("condicaoClinica")
		While !Empty( nDente := Val(PLSPCONGR(ctagBusWhi,cTagAne,aMatM,,.T.)) )
			cSituDen	:= PLSPCONGR(ctagAneBus,cTagAne,aMatM,,.T.)
			aadd(aDadDente, {nDente, cSituDen})
		endDo

		//Por algum motivo o caminho da tag com [_] (ct_situacaoInicial) não fica certo no array e com isso
		//dá ruim na busca, por isso esses aqu são procurados sem a tag origem 
		//e também pq são as últimas informações da guia, então as anteriores já estão com * do PLSPCONGR

		ctagAneBus := Upper("doencaPeriodontal")
		cSinCli		:= PLSPCONGR(ctagAneBus,'',aMatM,,.T.)

		ctagAneBus := Upper("alteracaoTecidoMole")
		cAltemo		:= PLSPCONGR(ctagAneBus,'',aMatM,,.T.)

		ctagAneBus := Upper("observacao")
		cObsAnex	:= PLSPCONGR(ctagAneBus,'',aMatM,,.T.)

		cCodRda		:= PLSRETDAD( aDados,"CODRDA","" )
		cNguiPriOpe	:= "" //Ver como buscar o dado baseado na guia principal do prestador depois

		aSituIni := {cNSitIniPre, cNguiPriPre, cNAnexoOpe, aclone(aDadDente), cSinCli, cAltemo, cObsAnex, cCodRda, cNguiPriOpe}

		Aadd(aDados, {"SITUINI", aclone(aSituIni)})
		aadd(aDados, {"NUMIMPOD", cNguiPriPre})
	endif

endif
//Processa a guia
If lOk .And. lProcLog
	cNumLib := PLSRETDAD( aDados,"NUMLIB","" )
	If !Empty( cNumLib ) .And. PLSRETDAD( aDados,"ORIGEM","" ) == '1'
		PLSAJULIB(cNumLib,aItens)
	EndIf
	if !l974Xml
		If !lOnline .AND. !lBg
			If GetRpoRelease()=="R1.1"
				oSelf:incRegua1("RDA [" + AllTrim(cRdaOri) + "] Guia Prest. [" + cNumImp + "]")
			Else
				IncProc("Prestador [" + AllTrim(cRdaOri) + "] Guia Prest. [" + cNumImp + "]")
				ProcessMessage()
			Endif
		EndIf
	endIf
	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Iniciando PLSXAUTP (PLSXMOV)", "tissonanalise.log")
	EndIf	

	aRet := PLSXAUTP(aDados,aItens,PLSRETDAD( aDados,"TIPADM",'' ),nil,aMatM)			

	If (cTipo == "2" .And. cOrigem == "2") .Or. (cTipo == "3" .And. cOrigem == "2")
		
		dDatPro	:= PLSRETDAD(aDados,"DATPRO","")

		If !Empty(cTipQui) .And. !Empty(aReProc) .And. aReProc[1] //pego campos de tags obrigatórias do tipo de quimioterapia
			PLANETISS(aDados,aMatM,aItens,"1",dDatPro,cGuia,cMatric, aRet[2])
		ElseIf !Empty(cJustTe) .And. !Empty(aReProc) .And. aReProc[1]
			PLANETISS(aDados,aMatM,aItens,"3",dDatPro,cGuia,cMatric, aRet[2])
		ElseIf !Empty(cTipRad)// pego campos obrigatórios de radioterapia para fazer a comparação de quais dos tipos de anexos clínicos preciso incluir no momento
			PLANETISS(aDados,aMatM,aItens,"2",dDatPro,cGuia,cMatric, aRet[2])
		EndIf
	EndIf

	If lLogTissOn
		PlsPtuLog(PLSRetTime() + " - Finalizando PLSXAUTP (PLSXMOV)", "tissonanalise.log")
	EndIf
	If Type("cHshLib") <> "U"
		cHshLib := ""
	EndIf

	If Len(aRet) > 0 .AND. Len(aRet[10]) > 0
		If (nPos := aScan( aRet[10], {|x| Alltrim(x[1]) == "LOCAL DIGITACAO" .AND. Empty(x[2]) } )) > 0
			aRet[10,nPos,2] := PLSRETDAD( aDados,"CODLDP","" )
		EndIf
		If (nPos := aScan( aRet[10], {|x| Alltrim(x[1]) == "PROTOCOLO" .AND. Empty(x[2]) } )) > 0
			aRet[10,nPos,2] := cCodPeg
		EndIf
	EndIf
	
	BXX->(dbSetOrder(6))//BXX_FILIAL + BXX_CODINT +  BXX_CODPEG
	If BXX->(msSeek(xFilial("BXX")+cOpeMov+cCodPeg)) // ATUALIZO O VALOR DA BXX
		If BXX->BXX_VLRTOT == 0 .AND. nValorTotG > 0 // Atualizo o valor total
			BXX->(Reclock("BXX",.F.))
			BXX->BXX_VLRTOT := nValorTotG
			BXX->(MsUnlock())
		EndIf
	EndIf
	
	//se estou importando um XML vou alimentar a nova tabela BXV com a chave da guia que acabei de criar
	If PlsAliasExi('BXV') .and. l974Xml .and. nSeqGui > 0
		BXX->(dbSetOrder(6))//BXX_FILIAL + BXX_CODINT +  BXX_CODPEG
		If BXX->(msSeek(xFilial("BXX")+cOpeMov+cCodPeg))
			cSeqBXX   := Padr(BXX->BXX_SEQUEN,tamsx3('BXV_CHVALI')[1])
		Endif
		
		cChvGuia := strtran(strtran(strtran(aRet[2],'-',''),space(2),''),space(1),'')
		cSeqGuia := strzero(nSeqGui,3)
		If !Empty(cSeqBXX)
			BXV->(DbSetOrder(1))
			If BXV->(MsSeek(xFilial("BXV")+"BXX"+cSeqBXX+cSeqGuia))
				While !BXV->(Eof()) .and. BXV->(BXV_FILIAL+BXV_ALIAS+BXV_CHVALI+BXV_SEQGUI) == xFilial("BXV")+"BXX"+cSeqBXX+cSeqGuia
					
					BXV->(Reclock("BXV",.F.))
					BXV->BXV_CHVGUI := cChvGuia
					BXV->(MsUnlock())
					
					BXV->(DbSkip())
				Enddo
			Endif
		Endif
	Endif
EndIf

If lLogTissOn
	PlsPtuLog(PLSRetTime() + " - Finalizando PLSLGSP3 (PLSA973)", "tissonanalise.log")
EndIf

Return( { aRetAux,aRet } )

/*/{Protheus.doc} VerMembro
Valida membro de equipe. O objetivo dessa funcao eh verificar se o membro de equipe em questao eh daquele procedimento ou nao.
@type function
@author TOTVS
@since 04/11/14
@version 1.0
/*/
static Function VerMembro(nIndMat,nIndPro,aMatM,cTipGui)
	LOCAL nI 	 := 0
	LOCAL nMenor := 0
	LOCAL nMaior := 0
	LOCAL lRet	 := .T.

	If nIndMat > nIndPro
		nMenor := nIndPro
		nMaior := nIndMat
	Else
		nMenor := nIndMat
		nMaior := nIndPro
	Endif
//percorro do menor para o maior, se todos eles tiverem dentro da TAG PROCEDIMENTOEXECUTADO significa que o membro de equipe
//faz parte daquele procedimnto
	For nI:=nMenor to nMaior                               //se eu passei pela tag codigo procedimento ja to em outro procedimento
		If cTipGui <> '06'
			If !("PROCEDIMENTOEXECUTADO" $ aMatM[nI][3]) .OR. ("CODIGOPROCEDIMENTO" $ alltrim(aMatM[nI][1]) .AND. nI <>nIndPro)
				lRet := .F.
				exit
			Endif
		else
			If !("PROCEDIMENTOREALIZADO" $ aMatM[nI][3] .AND. "PROCEDIMENTOSREALIZADOS" $ aMatM[nI][3]) .OR. ("CODIGOPROCEDIMENTO" $ alltrim(aMatM[nI][1]) .AND. nI <>nIndPro)
				lRet := .F.
				exit
			Endif
		Endif
	Next

return  lRet

/*/{Protheus.doc} PlsIsSen
Valida liberacao
@type function
@author TOTVS
@since 04/11/14
@version 1.0
/*/
Function PlsIsSen(cTipo)
	Local lRet	    := .T.
	Local cMatXML	:= ""
	Local x			:= 0
	Local y			:= 0
	Local lGuiaSen  := .F.
	local lHatAtv	:= GetNewPar("MV_PLSHAT","0") == "1" .and. FWAliasInDic("B2Z")
	local aTipVr	:= {"SENHA", "NUMAUT"}
	local nI		:= 0
	local cSqlT	    := ""
	local cNomBenef := ""
	
	DEFAULT cTipo 	:= '2'

	x := Len(aMapGuia)
	While x > 0 //Tem que olhar de trás pra frente
		If nZaDados >= aMapGuia[x][1]
			lGuiaSen := aMapGuia[x][2]
			Exit
		EndIf
		x--
	EndDo
	
	If !lGuiaSen //Se não tem senha na guia, daéerminou aqui, jáetorna
		lRet := .T.
		lFoundAut := .F.
		nRecnoAut := 0
		Return lRet
	EndIf	
	
	//Pegamos esse do aDados pq ainda não recarregamos a tag da carteirinha no aDadosUnic
	//Devido à ordem das tags no XML
		for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
		If aDados[y][1] == "NUMEROCARTEIRA" 
			cMatXML := aDados[y][3]
		EndIf
		if aDados[y][1] == "NOMEBENEFICIARIO"
			cNomBenef := aDados[y][3]
		endif
		if !Empty(cMatXML) .and. !Empty(cNomBenef)
			exit 
		ENDIF
	Next

	if lPlsXmlMat
		cMatXML := vldMatPeXml(cMatXML,cNomBenef,cMatXML) 
	endif
	
	//Pegamos esse do aDadosUnic pq estamos validando a tag SENHA, então ele já recarregou pro conte?do
	//certo no aDadosUnic
	CNUMSEN:= aDadosUnic[(aScan( aDadosUnic, {|x| x[1]=="SENHA"})),3] // RECARREGANDO A SENHA CNUMSEN

	If cTipo == '2'
		BEA->(DBSETORDER(1))
		If !BEA->( MSSEEK(XFILIAL('BEA')+PADR(ALLTRIM(CNUMSEN),18)))
			BEA->(DBSETORDER(14))
			If !BEA->( MSSEEK(XFILIAL('BEA')+ALLTRIM(CNUMSEN)))

				If BEA->(FieldPos("BEA_GUIPRE"))> 0
					cAliasTrb	:= GetNextAlias()
					BeginSql Alias cAliasTrb
						SELECT BEA.R_E_C_N_O_ FROM %table:BEA% BEA
						WHERE BEA_FILIAL = %exp:xFilial("BEA")%
						AND BEA_GUIPRE 	= %exp:cNumImp%
						AND BEA.%NotDel%
					Endsql

					If (cAliasTrb)->(Eof())
						lRet:=.F.
						lFoundAut := .f.
						nRecnoAut := 0
					Else
						BEA->(DbGoto((cAliasTrb)->R_E_C_N_O_))
						If cMatXML == AllTrim(BEA->(BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO)) .OR. cMatXML == AllTrim(BEA->(BEA_MATANT))
							lFoundAut := .t.
							nRecnoAut := BEA->(Recno())
						else
							lRet:=.F.
							lFoundAut := .f.
							nRecnoAut := 0							
						EndIf
						
					Endif
				(cAliasTrb)->(DbCloseArea())
				Else
					lRet:=.F.
					lFoundAut := .f.
					nRecnoAut := 0
				Endif

				//Se falhou em todas essas buscas, agora verifica se tem HAT ativo
				if !lRet .and. lHatAtv
					for nI := 1 to len(aTipVr)
						cSqlT := " SELECT B2Z.R_E_C_N_O_ REC FROM " + RetSqlname("B2Z") + " B2Z "
						cSqlT += " WHERE B2Z_FILIAL = '" + xFilial("B2Z") + "' "
						cSqlT += "	AND B2Z_OPEMOV = '" + PlsIntPad() + "' "
						cSqlT += " AND B2Z_" +aTipVr[nI] + " = '" + cNUMSEN + "' "
						cSqlT += "	AND B2Z_MATRIC = '" + cMatXML + "' "
						cSqlT += "	AND B2Z.D_E_L_E_T_ = ' ' "
						
						cSqlT:= ChangeQuery(cSqlT)
						TcQuery cSqlT New Alias "TabAutB2Z"

						If TabAutB2Z->(Eof())
							lRet 		:= .f.
							lFoundAut 	:= .f.
							nRecnoAut 	:= 0
						Else
							lRet 	   	:= .t. 
							lFoundAut 	:= .t.
							nRecnoAut 	:= TabAutB2Z->REC
							LPLHAT    	:= .t.
							TabAutB2Z->(dbclosearea())
							exit
						endif
					TabAutB2Z->(dbclosearea())	
					next
				endif	
					
			Else
				If cMatXML == AllTrim(BEA->(BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO)) .OR. cMatXML == AllTrim(BEA->(BEA_MATANT))
					lFoundAut := .t.
					nRecnoAut := BEA->(Recno())
				else
					lRet:=.F.
					lFoundAut := .f.
					nRecnoAut := 0							
				EndIf
			Endif
		Else
			If cMatXML == AllTrim(BEA->(BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO)) .OR. cMatXML == AllTrim(BEA->(BEA_MATANT))
				lFoundAut := .t.
				nRecnoAut := BEA->(Recno())
			else
				lRet:=.F.
				lFoundAut := .f.
				nRecnoAut := 0							
			EndIf
		Endif
	Else
		BE4->(DbSetOrder(2))
		If !BE4->( MSSEEK( XFILIAL('BE4')+PADR(CNUMSEN,18)))
			BE4->(DbSetOrder(7))
			If !BE4->( MSSEEK( XFILIAL('BE4')+CNUMSEN))
				lRet:=.F.
				lFoundAut := .f.
				nRecnoAut := 0
			Else
				if cMatXML == AllTrim(BE4->(BE4_OPEUSR + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO)) .OR. cMatXML == AllTrim(BE4->BE4_MATANT)
					lFoundAut := .t.
					nRecnoAut := BE4->(Recno())
				else
					lRet:=.F.
					lFoundAut := .f.
					nRecnoAut := 0					
				EndIf
			Endif
		Else
			if cMatXML == AllTrim(BE4->(BE4_OPEUSR + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO)) .OR. cMatXML == AllTrim(BE4->BE4_MATANT)
				lFoundAut := .t.
				nRecnoAut := BE4->(Recno())
			else
				lRet:=.F.
				lFoundAut := .f.
				nRecnoAut := 0					
			EndIf
		Endif
	Endif

return lRet

/*/{Protheus.doc} PBusProfs
(long_description)
@type function
@author TOTVS
@since 04.02.15
@version 1.0
/*/
Function PBusProfs(cCodigo,lOnlyRDA,cSigla,cCrm,cCodUf,cNome,cCbos,cData)
	LOCAL lAchou := .f.


	If !Empty(cCodigo)
	//quando a variavel lOnlyRDA estiver .t. eh porque somente devo procurar na RDA
		If lOnlyRDA
			BAU->( DbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO
			lAchou := BAU->( MsSeek( xFilial("BAU")+cCodigo ) )

			If !lAchou
				lAchou := BAU->( MsSeek( xFilial("BAU")+cCodrp ) )
			Endif

		//se naoa chou vou buscar tambem pelo CPF/cnpj
			If !lAchou
				BAU->( DbSetOrder(4) ) //BAU_FILIAL + BAU_CPFCGC
				lAchou := BAU->( MsSeek( xFilial("BAU")+cCodigo ) )
			Endif
			If lAchou
			//retorno true e alimento as variais para serem utilizadas pela rotina
				CCODRP 	:= BAU->BAU_CODIGO
				CNOMRDA := BAU->BAU_NOME
				CNOMPRE := BAU->BAU_NOME
			Else
				CCODRP 	:= ""
				CNOMRDA := ""
				CNOMPRE := ""
			Endif
		Else

			BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
			lAchou := BB0->( MsSeek( xFilial("BB0")+cCodigo ) )
		//se nao achou vou buscar tambem pelo CPF/cnpj
			If !lAchou
				BB0->( DbSetOrder(3) ) //BB0_FILIAL + BB0_CPF
				lAchou := BB0->( MsSeek( xFilial("BB0")+cCodigo ) )
			Endif
			If lAchou
				cCrm	:= BB0->BB0_NUMCR
				cCodRP	:= BB0->BB0_CODIGO
				cSigla	:= BB0->BB0_CODSIG
				cCodUf	:= BB0->BB0_ESTADO
				cCpfCGC	:= BB0->BB0_CGC
				cNome	:= BB0->BB0_NOME
			Else
			//se eu nao achei pode ser que ele tenha me mandado uma rda
			//mas eu nao vou desposicionar minha rda principal
				nRecBAU := BAU->(Recno())
				nOrdBAU := BAU->(Indexord())
				BAU->( DbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO
				lAchou := BAU->( MsSeek( xFilial("BAU")+cCodigo ) )

			//se naoa chou vou buscar tambem pelo CPF/cnpj
				If !lAchou
					BAU->( DbSetOrder(4) ) //BAU_FILIAL + BAU_CPFCGC
					lAchou := BAU->( MsSeek( xFilial("BAU")+cCodigo ) )
				Endif
			//ai pela RDA eu chego no BB0
				If lAchou
					BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CPF
					lAchou := BB0->( MsSeek( xFilial("BB0")+BAU->BAU_CODBB0 ) )
					If lAchou
						cCrm	:= BB0->BB0_NUMCR
						cCodRP	:= BB0->BB0_CODIGO
						cSigla	:= BB0->BB0_CODSIG
						cCodUf	:= BB0->BB0_ESTADO
						cCpfCGC	:= BB0->BB0_CGC
						cNome	:= BB0->BB0_NOME
					Endif
				Endif

				If !lAchou    // JA TENHO O CODIGO DA RDA POSSO USAR TB
					BAU->( DbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO
					lAchou := BAU->( MsSeek( xFilial("BAU")+cCodrp ) )
				Endif

				BAU->(DbGoTo(nRecBAU))
				BAU->(DbSetOrder(nOrdBAU))
				If !lAchou
					cCrm	:= ""
					cCodRP	:= ""
					cSigla	:= ""
					cCodUf	:= ""
					cCpfCGC	:= ""
					cNome	:= ""
				Endif
			Endif
		Endif
	Else
	//se eu nao passei o codigo significa que vou buscar o profissional com base nos dados de crm, cUf enviados...
		PLSIVPRO("",cSigla,cCrm,cCodUf,4,,aDados)
		PLSXSCU("",cSigla,cCrm,cCodUf,"",NIL,NIL,NIL,cNome,NIL,cData)
		lAchou := BB0->( Found() )
	Endif

Return lAchou

/*/{Protheus.doc} PlTrCBOIMP
Retorna os dados de CBOs e Especialidade do arquivo XML conforme tipo de dado solicitado
(Executante ou Solicitante) e origem da transação (Solicitação/Execução).

@type Function
@author victor.silva
@since 31/03/2016
@version 1.0
@return cRet, Retorno com o dado solicitado conforme parametro cTpDad
/*/
Function PlTrCBOIMP(cTpDad,cGuia,aMatM,cOrigem,cTipGui,lChkTag,cCodPeg)
	Local cCamTag		:= ""
	Local cTipPro		:= ""
	Local cCboX		:= ""
	Local cEspX		:= ""
	Local cNome     := ""
	Default lChkTag	:= .T.
	Default cCodPeg := ""

//Conforme passagem de parametros, retorna o caminho da TAG
	PlRtCBOPath(cOrigem,cTpDad,cTipGui,@cCamTag,cGuia)

	if cTipGui != "13"
		cCboX := PLSPCONGR(Iif(cTipGui == "06","CBO","CBOS"), cCamTag, aMatM,nil,lChkTag,.F.,nil)
	else
		cCboX := PLSPCONGR(Iif(cTpDad == "1","CBOSSOLIC","CBOSEXEC2"), cCamTag, aMatM,nil,lChkTag,.F.,nil)
	endif	
	
	// Se guia de solicitacao TISS Online e CBOS generico 999999 nao realizo o De-Para para o 
	// sistema assumir a padrao da RDA ao rodar o PLSXMOV 
	If cCamTag == 'SOLICITACAOSP_SADT\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE' .And. cCboX == '999999'
		cEspX := ''
	Else
		cEspX := AllTrim(PLSVARVINC('24','BAQ',cCboX))
    EndIf
	cNome  := PLSPCONGR("NOMEPROFISSIONAL",cCamTag,aMatM,,.F.,.F.,nil,cCodPeg)

//Ponto de Entrada para realizar o vinculo 1_CBOS->N_ESP
	If ExistBlock("PLTISESP")
		cTipPro:= Iif(cTpDad == "1","S","E")
		aRetPe := ExecBlock("PLTISESP",.F.,.F.,{"2",cTipPro,cNome,cCboX,cEspX,""})
		If ValType(aRetPe) == "A" .And. Len(aRetPe) >= 2
			cEspX := aRetPe[1]
			cCboX := aRetPe[2]
		Endif
	EndIf

Return {cEspX,cCboX}

/*/{Protheus.doc} PlRtCBOPath
Utilizada pela funcao PlTrCBOIMP para retornar o caminho da TAG solicitada.

@type Function
@author victor.silva
@since 31/03/2016
@version 1.0
/*/
Function PlRtCBOPath(cOrigem,cTpDad,cTipGui,cCamTag,cGuia)

/*
Estrutura do aPathTag
	[1] - Origem da transação (1-Execucao/2-Solicitacao)
	[2] - Tipo de dado solicitado (1-Solicitante/2-Executante)
	[3] - Tipo de Guia (01-CONSULTA/02-SADT/03-GIH/05-GRI/06-GHI)
	[4] - Caminho da TAG
*/

	If Len(aPathTag) == 0
	//-- EXECUCAO --
	//Solicitante
		aAdd(aPathTag,{"1","1","02",cGuia + "\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE\"})
		aAdd(aPathTag,{"1","1","13",cGuia + "\DADOSPROFISSIONAISRESPONSAVEIS\"})
	//Executante
		aAdd(aPathTag,{"1","2","01",cGuia + "\PROFISSIONALEXECUTANTE"})
		aAdd(aPathTag,{"1","2","02",cGuia + "\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\EQUIPESADT"})
		aAdd(aPathTag,{"1","2","05",cGuia + "\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\IDENTEQUIPE\IDENTIFICACAOEQUIPE"})
		aAdd(aPathTag,{"1","2","06",cGuia + "\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\PROFISSIONAIS"})
		aAdd(aPathTag,{"1","2","13",cGuia + "\DADOSPROFISSIONAISRESPONSAVEIS\"})

	//-- SOLICITACAO --
	//Solicitante
		aAdd(aPathTag,{"2","1","02",cGuia + "\DADOSSOLICITANTE\PROFISSIONALSOLICITANTE"})
		aAdd(aPathTag,{"2","1","03",cGuia + "\IDENTIFICACAOSOLICITANTE\DADOSPROFISSIONALCONTRATADO\"})
	EndIf

//Busca a posicao do dado solicitado
	nPos := aScan(aPathTag,{|x|(x[1]+x[2]+x[3]) == cOrigem + cTpDad + cTipGui})

	If nPos > 0
		cCamTag := aPathTag[nPos][4]
	EndIf

Return

/*/{Protheus.doc} PlRtEspPre
Retorna a especialidade do prestador.
Se a especialidade do executante esta contida nas especialidades do prestador, retorna a mesma.
Se a especialidade do executante nao for informada na guia porem for guia de SADT,
considera especialidade do solicitante.
Se nenhuma das condicoes forem atendidas, retorna a especialidade principal do Prestador.

@type Function
@author victor.silva
@since 06/04/2016
@version 1.0
@return cRet, Codigo da especialidade do prestador
/*/
Function PlRtEspPre(cCodOpe,cCodRda,cEspPro,dDatRea,cLocEsp,lFullEsp,lImp,cTipRet,lConBlc)
	Local xRet 		:= ""
	Local cEspQry		:= ""
	Local cAliasQry 	:= GetNextAlias()
	Local cEspPla		:= GetNewPar("MV_PESPPLA","'094','055'")
	Local nPos			:= 0
	Local aEsp			:= {}
	Local cWhere		:= ""
	Local cCampos		:= "%BAX_FILIAL, BAX_CODINT, BAX_CODESP, BAX_CODIGO, BAX_ESPPRI, BAX_DATBLO%"
	Local cDatPro		:= DtoS(dDatRea)

	Default lFullEsp	:= GetNewPar('MV_PLSCTES','0') == '1'   
	Default lConBlc		:= .T.
	Default cTipRet		:= "C"
	Default lImp		:= .F.

	//Prevencao de erros no conteudo da query
	cEspPla := AllTrim(cEspPla)
	cEspPla := Iif(SubStr(cEspPla,Len(cEspPla)) <> ",",cEspPla,Right(cEspPla,Len(cEspPla) - 1))
	cEspPla := StrTran(StrTran(cEspPla,"'",""),",","','")

	//Garantia que esta avaliando o Prestador Contratado correto
	If Len(AllTrim(cCodRda)) > 6
		If AllTrim(cCodRda) == AllTrim(BAU->BAU_CPFCGC)
			cCodRda := BAU->BAU_CODIGO
		Else
			BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
			If BAU->(DbSeek(xFilial("BAU") + cCodRda))
				cCodRda := BAU->BAU_CODIGO
			EndIf
		EndIf
	EndIf

	//Preparando parametros da query
	If !Empty(cEspPla)
		cEspQry := cEspPla + "','" + AllTrim(cEspPro)
	Else
		cEspQry := AllTrim(cEspPro)
	EndIf

	//Inicio WHERE
	cWhere := "%"
	//O parametro MV_PLSCTES define se deve considerar as especialidades enviadas (XML + MV_PESPPLA).
	If !lFullEsp
		cWhere += "BAX_CODLOC = '" + cLocEsp + "' AND "
		cWhere += "BAX_CODESP IN ('" + cEspQry + "') AND "
		Iif(lConBlc,cWhere += "(BAX_DATBLO = ' ' OR (BAX_DATBLO <> ' ' AND BAX_DATBLO > '" + cDatPro + "')) AND ",nil)
	Else
		Iif(lConBlc,cWhere += "(BAX_DATBLO = ' ' OR (BAX_DATBLO <> ' ' AND BAX_DATBLO > '" + cDatPro + "')) AND ",nil)
	EndIf
	cWhere += "%"
	// Final WHERE

	BeginSql alias cAliasQry
	SELECT
		%exp:cCampos%
	FROM
		%table:BAX% BAX
		WHERE
		BAX_FILIAL	= 	%xFilial:BAX% AND
		BAX_CODIGO	= 	%exp:cCodRda% AND
		BAX_CODINT	= 	%exp:cCodOpe% AND
		%exp:cWhere%
		BAX.%notdel%
	ORDER BY
		%exp:cCampos%
	EndSql

	If !(cAliasQry)->(Eof())
		//Alimentando o array com os dados das especialidades encontradas na consulta
		While !(cAliasQry)->(Eof())
			/*
			Estrutura do aEsp
			[1] - Codigo da Especialidade
			[2] - Flag informando se eh a especialidade principal (0-Nao/1-Sim)
			[3] - Flag informando se eh igual a especialidade do executante (0-Nao/1-Sim)
			[4] - Flag informando se a especialidade esta bloqueada (0-Nao/1-Sim)
			*/
			aAdd(aEsp,{	(cAliasQry)->BAX_CODESP,;
			(cAliasQry)->BAX_ESPPRI,;
			Iif((cAliasQry)->BAX_CODESP == AllTrim(cEspPro),"1","0"),;
			Iif(lConBlc,"0",Iif(((Empty((cAliasQry)->BAX_DATBLO)) .Or. (!Empty((cAliasQry)->BAX_DATBLO) .And. (cAliasQry)->BAX_DATBLO > cDatPro)),"0","1"))})

			//Proximo resultado
			(cAliasQry)->(DbSkip())

		Enddo

		If cTipRet == "A"
			xRet := aClone(aEsp)
		Else
			//Ordem de prioridade
			/*
			1 - Especialidade do Executante coincide com a especialidade do Prestador
			2 - Especialidade principal do Prestador
			3 - Primeira especialidade encontrada
			*/
			nPos := aScan(aEsp,{|x|(x[3]) == "1"})
			Iif(nPos == 0,nPos := aScan(aEsp,{|x|(x[2]) == "1"}),NIL)

			If nPos > 0
				//Pega a especialidade encontrada conforme ordem de prioridade acima
				xRet := aEsp[nPos][1]
			Else
				//Pega a primeira especialidade encontrada
				(cAliasQry)->(DbGoTop())
				xRet := (cAliasQry)->BAX_CODESP
			EndIf
		EndIf

	ElseIf lImp

		//Nao achou nenhuma especialidade na importacao, retorna a principal para prevencao de inconsistencia.
		If empty(cLocEsp) .or. empty(xRet := PLSPreEsp(cCodRda,cCodOpe,cLocEsp,cDatPro))
			BAX->(DbSetOrder(1)) //BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
			If BAX->(DbSeek(xFilial("BAX") + cCodRda + cCodOpe))
				xRet := BAX->BAX_CODESP
			EndIf
		EndIf

	Endif

	IF Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	Endif

Return xRet

/*/{Protheus.doc} PLSXMLTACE
@type function
/*/
function PLSXMLTACE(cCont)
	PLSDelTra(cCont)
return cCont

/*/{Protheus.doc} PlMatValida..
//Recebe a matricula e devolve a matricula do PLS. Aceita: Matricula do PLS, matricula antiga e Matricula da Empresa.
Se nao encontrar por nenhuma das tres opcoes devolvo o que veio no xml e entra na critica X21
@author romulo.ferrari
@since 09/12/2016
@version 12.1.7

@type function
/*/
Function PlMatValida(cMatXML,cNomUsr, dDataAtend,cMatXMLPt)
Local aAreaBa1	:= BA1->(GetArea())
Local cMatArq	:= cMatXML
Local cMatOrig	:= cMatXML
Local cNovaMat	:= ""

Default cMatXMLPt := ""

BA1->(DbSetOrder(2))
If !BA1->(MsSeek(xFilial("BA1")+cMatXML))
	BA1->(DbSetOrder(5))
	IF BA1->(MsSeek(xFilial("BA1")+cMatXML)) .And. alltrim(BA1->BA1_MATANT) == cMatXML  //Somente se a busca for exata dará .T., ficou assim pq o segundo parâmetro do MsSeek não estava funcionando
		cMatXML := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO )
	Else
		BA1->(DbSetOrder(6)) //BA1_FILIAL+BA1_MATEMP
		If (BA1->(MsSeek(xFilial("BA1")+cMatXML))) .and. (AllTrim(BA1->BA1_MATEMP) == AllTrim(cMatXML))
			cMatXML := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO )
		Else
			BA1->(DbSetOrder(5))
			If !Empty(cMatXMLPt) .and. BA1->(MsSeek(xFilial("BA1")+cMatXMLPt))
				cMatXML := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO )
			Endif
		Endif
	EndIf
EndIf

cMatArq	:= cMatXML

//Ponto de entrada para alterar a matricula
if lPlsXmlMat
	cMatXML := vldMatPeXml(cMatArq,cNomUsr,cMatOrig)
endif

RestArea(aAreaBa1)

Return cMatXML

/*/{Protheus.doc} PlTrazSolAut..
//Função que retorna a última matrícula do beneficiário através do BEA_NUMIMP, já que o sistema busca a primeira que encontrar, fiz a função para reposicionar, e assim poder utilizar em demais rotinas do TISS.
@author r.soares / Rafael Soares
@since 11/08/2020
@version 12.1.27

@type function
/*/
Function PTrazSolAut(cNumAut)
Local cSql := ""

Default cNumAut := ""

cSql := " SELECT BEA_OPEMOV,BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT "
cSql += " FROM "+RetSqlname("BEA") +" BEA "
cSql += " WHERE BEA_FILIAL = '"+xFilial("BEA")+"' "
cSql += " AND BEA_NUMIMP = '"+cNumAut+"' "
cSql += " AND BEA.D_E_L_E_T_ = ' ' " 
cSql +=	" GROUP BY BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT "
cSql += " ORDER BY Min(BEA_ANOAUT) DESC, BEA_MESAUT DESC, BEA_NUMAUT DESC"
cSql := ChangeQuery(cSql)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbBEA",.T.,.F.)

cNumAut := TrbBEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

TrbBEA->(dbCloseArea())

Return cNumAut

/*/{Protheus.doc} PLANETISS..
Função para incluir uma guia de Anex.Clínicos.
@author r.soares
@since 03/12/2020
/*/
function PLANETISS(aDados,aMatM,aItens,cTipo,dDataAt,cGuia,cCodUsu, cGuiaRef)
Local nFor       	:= 0
Local nQtDosDia	 	:= 0
Local nQtdDoses	 	:= 0
Local cTipGui    	:= ""  
Local cNomSol    	:= ""
Local cTelSol    	:= ""
Local cEmailSol  	:= ""
Local cTpAnexo   	:= ""
Local cCidPri    	:= ""
Local cCidSec    	:= ""
Local cCidTer    	:= ""
Local cCidQua    	:= ""
Local cDiagHisPa 	:= ""
Local cInfRelev  	:= ""
Local cDescCirur 	:= ""       
Local cFinali    	:= ""    
Local cEstadi    	:= "" 
Local cEcog      	:= ""
Local cObserv    	:= ""
Local cNodulo    	:= ""
Local cTumor     	:= ""
Local cMetastase 	:= ""
Local cDiaCiclAt 	:= ""
Local cNrtrol    	:= ""
Local cNrAope    	:= ""
Local dDataCirur 	:= ctod("")
Local dDatDia	 	:= ctod("")
Local dDatPre  	 	:= ctod("")
Local aDadBA1    	:= {}
Local aDadUsr    	:= {}
Local aRet       	:= {}
Local aDadB4A    	:= {}
Local aRetorno	 	:= {}
Local aChaveGen  	:= {}
Local aCid		 	:= {"cCidPri", "cCidSec", "cCidTer", "cCidQua"}
Local aMatAux 	 	:= aClone(aMatM)
Local cSexo      	:= PLSRETDAD(aMatM,"SEXO")

Default cTipo		:= ""
Default cGuia		:= ""
Default cCodUsu		:= ""
Default cGuiaRef	:= ""
Default dDataAt		:= ctod("")
Default aDados		:= {}
Default aItens		:= {}

PRIVATE aAutForAnx  := {}

aDadBA1  := BA1->(GetArea())                      

BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
BA1->(dbSeek(xFilial("BA1")+cCodUsu))

aDadUsr  := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO),"1", .F., dDataAt)
aRet  := PLSXVLDCAL(dDataBase,PLSINTPAD(),.F.,"","")
  
//Quimio
If cTipo == "1" 
	cTipGui		:= '07' 
	cTpAnexo   	:= "2"  
	cNomSol    	:= PLSRETDAD(aMatAux,"NOMEPROFISSIONAL")
	cTelSol    	:= PLSRETDAD(aMatAux,"TELEFONEPROFISSIONAL")
	cEmailSol  	:= PLSRETDAD(aMatAux,"EMAILPROFISSIONAL")

	For nFor := 1 To Len(aCid)
		nCid := aScan(aMatAux, {|x| x[1] == "DIAGNOSTICOCID"})	
		If nCid > 0
			&(aCid[nFor]) := aMatAux[nCid][2]
			aMatAux[nCid][1] += "*" 
		Else
			Exit
		EndIf
	Next nFor

	dDataCirur 	:= STOD(StrTran(PLSRETDAD(aMatAux,"DATACIRURGIA"), "-", "" ))       
	dDatDia    	:= STOD(StrTran( PLSRETDAD(aMatAux,"DATASOLICITACAO"), "-", "" ))
	cFinali    	:= PLSRETDAD(aMatAux,"FINALIDADE")  
	cEstadi    	:= PLSRETDAD(aMatAux,"ESTADIAMENTO")
	cEcog      	:= PLSRETDAD(aMatAux,"ECOG")  
	dDatPre    	:= STOD(StrTran( PLSRETDAD(aMatAux,"DTPREVISTAINICIO"), "-", "" ))
	cObserv  	:= PLSRETDAD(aMatAux,"OBSERVACAO")
	cDiagHisPa 	:= PLSRETDAD(aMatAux,"DIAGNOSTICOHISPATOLOGICO")
	cInfRelev  	:= PLSRETDAD(aMatAux,"INFORELEVANTES")    

	cDescCirur 	:= PLSRETDAD(aMatAux,"CIRURGIA")  
	cNodulo    	:= PLSRETDAD(aMatAux,"NODULO")
	cTumor     	:= PLSRETDAD(aMatAux,"*TUMOR")
	cMetastase 	:= PLSRETDAD(aMatAux,"METASTASE")
	nQtDosDia	:= Val(PLSRETDAD(aMatAux,"QTDOSES"))
	nQtdDoses	:= Val(PLSRETDAD(aMatAux,"QTDOSES"))
	cDiaCiclAt 	:= PLSRETDAD(aMatAux,"DIASCICLOATUAL")
//Radio
ElseIf cTipo == "2"
	cTipGui 	:= '08'
	cTpAnexo   	:= "1"      
	cNomSol    	:= PLSRETDAD(aMatAux,"NOMEPROFISSIONAL")
	cTelSol    	:= PLSRETDAD(aMatAux,"TELEFONEPROFISSIONAL")
	cEmailSol  	:= PLSRETDAD(aMatAux,"EMAILPROFISSIONAL")                               
	For nFor := 1 To Len(aCid)
		nCid := aScan(aMatAux, {|x| x[1] == "DIAGNOSTICOCID"})	
		If nCid > 0
			&(aCid[nFor]) := aMatAux[nCid][2]
			aMatAux[nCid][1] += "*" 
		Else
			Exit
		EndIf
	Next nFor
	cDescCirur 	:= PLSRETDAD(aMatAux,"CIRURGIA")  
	dDataCirur 	:= STOD(StrTran(PLSRETDAD(aMatAux,"DATACIRURGIA"), "-", "" ))    
	dDatDia    	:= STOD(StrTran( PLSRETDAD(aMatAux,"DATASOLICITACAO"), "-", "" ))    
	cFinali    	:= PLSRETDAD(aMatAux,"FINALIDADE")  
	cEstadi    	:= PLSRETDAD(aMatAux,"ESTADIAMENTO")
	cEcog      	:= PLSRETDAD(aMatAux,"ECOG")  
	dDatPre    	:= STOD(StrTran( PLSRETDAD(aMatAux,"DTPREVISTAINICIO"), "-", "" ))
	cObserv  	:= PLSRETDAD(aMatAux,"OBSERVACAO")
	cDiagHisPa 	:= PLSRETDAD(aMatAux,"DIAGNOSTICOHISPATOLOGICO") 
	cInfRelev  	:= PLSRETDAD(aMatAux,"INFORELEVANTES") 
	nQtDosDia	:= Val(PLSRETDAD(aMatAux,"DOSECAMPO"))
	nQtdDoses	:= Val(PLSRETDAD(aMatAux,"DOSETOTAL"))
	cDiaCiclAt 	:= PLSRETDAD(aMatAux,"*NRDIAS")

	
//OPME
ElseIf cTipo == "3"
	cTipGui  	:= '09'
	cTpAnexo   	:= "3"
	cNomSol    	:= PLSRETDAD(aMatAux,"NOMEPROFISSIONAL")
	cTelSol    	:= PLSRETDAD(aMatAux,"TELEFONEPROFISSIONAL")
	cEmailSol  	:= PLSRETDAD(aMatAux,"EMAILPROFISSIONAL")
	cObserv  	:= PLSRETDAD(aMatAux,"OBSERVACAO")
	dDatPre    	:= STOD(StrTran( PLSRETDAD(aMatAux,"DTPREVISTAINICIO"), "-", "" ))
	dDatDia    	:= STOD(StrTran( PLSRETDAD(aMatAux,"DATASOLICITACAO"), "-", "" ))

Endif 

//Posiciona indices   
BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO 
BEG->(DbSetOrder(1))//BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN  
 
//Posiciona na Operadora    
BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
BA0->(DbSeek(xFilial("BA0")+PlsIntPad()))
 
//Monta cabecalho B4A 
aadd(aDadB4A,{"B4A_OPEMOV",PlsIntPad() })
aadd(aDadB4A,{"B4A_REGANS",Alltrim(BA0->BA0_SUSEP) })
aadd(aDadB4A,{"B4A_GUIREF",cGuiaRef })
aadd(aDadB4A,{"B4A_DATPRO",Iif(!Empty(PLSRETDAD(aMatAux,"DATAAUTORIZACAO")),STOD(StrTran(PLSRETDAD(aMatAux,"DATAAUTORIZACAO"), "-", "" )),dDataAt) })
aadd(aDadB4A,{"B4A_DATSOL",dDatDia })
aadd(aDadB4A,{"B4A_GUIOPE",PLSRETDAD(aMatAux,"NUMEROGUIAOPERADORA") })
aadd(aDadB4A,{"B4A_MATANT",BA1->BA1_MATANT })
aadd(aDadB4A,{"B4A_OPEUSR",BA1->BA1_CODINT })
aadd(aDadB4A,{"B4A_CODEMP",BA1->BA1_CODEMP })
aadd(aDadB4A,{"B4A_CONEMP",BA1->BA1_CONEMP })
aadd(aDadB4A,{"B4A_SUBCON",BA1->BA1_SUBCON })
aadd(aDadB4A,{"B4A_VERCON",BA1->BA1_VERCON })
aadd(aDadB4A,{"B4A_VERSUB",BA1->BA1_VERSUB })
aadd(aDadB4A,{"B4A_MATRIC",BA1->BA1_MATRIC })
aadd(aDadB4A,{"B4A_TIPREG",BA1->BA1_TIPREG })
aadd(aDadB4A,{"B4A_DIGITO",BA1->BA1_DIGITO })
aadd(aDadB4A,{"B4A_NOMUSR",BA1->BA1_NOMUSR })
aadd(aDadB4A,{"B4A_CANCEL",'0' })
aadd(aDadB4A,{"B4A_PESO"  ,Val(PLSRETDAD(aMatAux,"PESO"))}) 
aadd(aDadB4A,{"B4A_ALTURA",Val(PLSRETDAD(aMatAux,"ALTURA"))}) 
aadd(aDadB4A,{"B4A_SUPCOR", Val(PLSRETDAD(aMatAux,"SUPERFICIECORPORAL"))})
aadd(aDadB4A,{"B4A_IDADE" ,Val(PLSRETDAD(aMatAux,"IDADE"))  })
aadd(aDadB4A,{"B4A_SEXO"  ,cSexo })
aadd(aDadB4A,{"B4A_NOMSOL",cNomSol })
aadd(aDadB4A,{"B4A_TELSOL",cTelSol })
aadd(aDadB4A,{"B4A_EMASOL",cEmailSol })
aadd(aDadB4A,{"B4A_TIPANE",cTpAnexo})
aadd(aDadB4A,{"B4A_TIPGUI",cTipGui})
aadd(aDadB4A,{"B4A_DATDIA",IIf(!Empty(dDatDia),dDatDia,Stod('')) })
aadd(aDadB4A,{"B4A_CIDPRI",cCidPri })
aadd(aDadB4A,{"B4A_CIDSEC",cCidSec })
aadd(aDadB4A,{"B4A_CIDTER",cCidTer })
aadd(aDadB4A,{"B4A_CIDQUA",cCidQua })
aadd(aDadB4A,{"B4A_DIAIMG",PLSRETDAD(aMatAux,"DIAGNOSTICOIMAGEM") })
aadd(aDadB4A,{"B4A_ESTADI",cEstadi  })
aadd(aDadB4A,{"B4A_TIPQUI",PLSRETDAD(aMatAux,"TIPOQUIMIOTERAPIA") })
aadd(aDadB4A,{"B4A_ECOG"  ,cEcog })
aadd(aDadB4A,{"B4A_FINALI",cFinali })
aadd(aDadB4A,{"B4A_PLATER",PLSRETDAD(aMatAux,"PLANOTERAPEUTICO")}) 
aadd(aDadB4A,{"B4A_DIAGCH",cDiagHisPa })
aadd(aDadB4A,{"B4A_INFREL",cInfRelev })
aadd(aDadB4A,{"B4A_CIRURG",cDescCirur})
aadd(aDadB4A,{"B4A_DATCIR",dDataCirur })
aadd(aDadB4A,{"B4A_DATIRR",STOD(StrTran(PLSRETDAD(aMatAux,"DATAIRRADIACAO"), "-", "" )) })
aadd(aDadB4A,{"B4A_QUIMIO",PLSRETDAD(aMatAux,"QUIMIOTERAPIA") })
aadd(aDadB4A,{"B4A_DATQUI",Stod(StrTran(PLSRETDAD(aMatAux,"DATAQUIMIOTERAPIA"), "-", "" )) })
aadd(aDadB4A,{"B4A_ANOPAG",aRet[4] })
aadd(aDadB4A,{"B4A_MESPAG",aRet[5] })
aadd(aDadB4A,{"B4A_JUSTTE",PLSRETDAD(aMatAux,"JUSTIFICATIVATECNICA")  })
aadd(aDadB4A,{"B4A_OBSERV",cObserv })
aadd(aDadB4A,{"B4A_NROCAM",Val(PLSRETDAD(aMatAux,"NUMEROCAMPOS")) })
aadd(aDadB4A,{"B4A_DOSDIA",nQtDosDia })
aadd(aDadB4A,{"B4A_DOSTOT",nQtdDoses })
aadd(aDadB4A,{"B4A_NRODIA",val(cDiaCiclAt) })
aadd(aDadB4A,{"B4A_ESPMAT",PLSRETDAD(aMatAux,"ESPECIFICACAOMATERIAL") })
aadd(aDadB4A,{"B4A_NROCIC",Val(PLSRETDAD(aMatAux,"NUMEROCICLOS")) })
aadd(aDadB4A,{"B4A_CICATU",Val(PLSRETDAD(aMatAux,"CICLOATUAL")) })
aadd(aDadB4A,{"B4A_INTCIC",Val(PLSRETDAD(aMatAux,"INTERVALOCICLOS")) })
aadd(aDadB4A,{"B4A_AREA",PLSRETDAD(aMatAux,"AREAIRRADIADA") })
aadd(aDadB4A,{"B4A_DATPRE",IIf(!Empty(dDatPre),dDatPre,ctod('')) })

//PTU 6.0 + TISS 3.03.00(Campos criados no UPDPLSHG referente a TISS 3.03.00)
If B4A->( FieldPos("B4A_METAST") ) > 0
	aadd(aDadB4A,{"B4A_METAST",cMetastase  })
	aadd(aDadB4A,{"B4A_NODULO",cNodulo  })
	aadd(aDadB4A,{"B4A_TUMOR",cTumor  })
	aadd(aDadB4A,{"B4A_DCICAT",Val(cDiaCiclAt)  })
EndIf
 
//Busca dados da Guia Origem   
If BEA->(DbSeek(xFilial("BEA")+cGuiaRef)) .And. B4A->( FieldPos("B4A_NRTROL") ) > 0 .And. B4A->( FieldPos("B4A_NRAOPE") ) > 0   
	cNrTrol := ""//StrZero( Val( PLSRETDAD(aDados,"NR_IDENT_O",aDados) ),10)  
	BQV->(DbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN                                                                                     
	If BEA->BEA_TIPGUI == '03'//Evolução de Internação
		If BQV->(MsSeek(xFilial("BQV")+cGuiaRef)) 
			aadd(aDadB4A,{"B4A_NRAOPE",BQV->BQV_NRAOPE })
			aadd(aDadB4A,{"B4A_NRTROL",BQV->BQV_NRTROL }) 
			cNrAope	   := BQV->BQV_NRAOPE
			cNrtrol    := BQV->BQV_NRTROL			
		EndIf
	Else
		aadd(aDadB4A,{"B4A_NRAOPE",BEA->BEA_NRAOPE })
		aadd(aDadB4A,{"B4A_NRTROL",BEA->BEA_NRTROL }) 
		cNrAope	   := BEA->BEA_NRAOPE
		cNrtrol    := BEA->BEA_NRTROL
	EndIf
EndIf   				   


aRetorno := PLANEPROC(cTipo, cTipGui, aItens, aMatAux, cTpAnexo, cGuiaRef)

aadd(aDadB4A,{"B4A_AUDITO",IIF(aRetorno[1],'1','0')})

If aRetorno[1] .Or. cTipo == "2"
	aRetorno := PLSA09AGRV(3,PlsIntPad(),'B4C','B4A','BEG',aDadB4A,aRetorno[4],aRetorno[5],aRetorno[6],aRetorno[7],aRetorno[8],aRetorno[9],;
							cTipGui,dDataBase,aRet[4],aRet[5],aChaveGen,.T.)
EndIf

RestArea(aDadBA1)

Return

/*/{Protheus.doc} PLANEPROC..
Função para incluir um procedimento OPME ou Quimioterapia
@author r.soares
@since 10/12/2020
/*/

Function PLANEPROC(cTipo, cTipGui, aItens, aMatM, cTpAnexo, cGuiaRef)
//Carrega aHeaders	  			   
Local lRet       := .T.
Local lEntra	 := .F.
Local lAuditoria := .F.
Local lNCont	 := .F.
Local lReturn	 := .F.
Local lInterna	 := aScan(aMatM, {|x| x[1] == "REGIMEINTERNACAO"}) > 0
Local nI         := 0
Local nQtdPro    := 0
Local nVlrEvent  := 0
Local nDatPro	 := 0
Local nCodPad	 := 0
Local nCodPro	 := 0
Local nDesPro	 := 0
Local nQtDose	 := 0
Local nUniMed	 := 0
Local nViaAdm	 := 0
Local nFreque	 := 0
Local nCodRef	 := 0
Local nOpcFab	 := 0
Local nAutFun	 := 0
Local nValSol	 := 0
Local nPosSeq	 := 0
Local nACodPro	 := 0
Local nCont		 := 1
Local nX		 := 1
Local nSeqMov    := 1  
Local nSeqCri	 := 1 
Local nSeqAux	 := 1
Local nTotDosag  := ""
Local cSequen    := ""
Local cCodPad    := ""
Local cCodPro    := ""
Local cNivAutCri := ""    
Local cUnMedida  := "" 
Local cSeqB4C    := ""
Local cCodAux	 := ""
Local cCodTab	 := ""
Local cDesAux	 := ""
Local cQtdSol	 := ""
Local cAliasPro	 := "B4C"  
Local cAliasCri	 := "BEG"
Local cAliasAut	 := "BE2"
Local dDatPro 	 := ctod("")
Local dDatAux 	 := ctod("")
Local aVetProc 	 := {0}  
Local aVetCri  	 := {0}
Local aCabProc 	 := PLSA09AHea(cTipGui,'1')//PLSA09AHea(strzero(::AutType,2),'1')
Local aDadProc 	 := PLSA09AClB(aCabProc)
Local aCabCri  	 := PLSA09HCHe()  
Local aDadCri  	 := PLSA09HClB(aCabCri) 
Local aCodPro 	 := aClone(aItens)
Local aMatAux	 := aClone(aMatM)

Default cTipo	 := ""
Default cTipGui	 := ""
Default cTpAnexo := ""
Default cGuiaRef := ""
Default aItens	 := {}

If cTipo <> "2" //radioterapia não tem procedimento
	//Insere os demais procedimentos do anexoClínico
	aSize(aCodPro, 1)
	//Zera os campos de conteúdo pois só quero os nomes de procedimentos do aItens
	For nX := 1 to Len(aCodPro[1])
		aCodPro[1][nX][2] := NIL
	Next

	If cTipo == "1" .And. !lInterna //quimio
		cCodTab := "CODIGOTABELA"
		cCodAux := "CODIGOPROCEDIMENTO"
		cDesAux := "DESCRICAOPROCEDIMENTO"
		cQtdSol	:= "QTDOSES"
	ElseIf cTipo == "3" .Or. lInterna  // se for de solicitação de internação ou do tipo OPME
		cCodTab := "*CODIGOTABELA"
		cCodAux := "*CODIGOPROCEDIMENTO"
		cDesAux := "*DESCRICAOPROCEDIMENTO"
		If cTipo != "3" .And. lInterna
			cQtdSol := "QTDOSES"
		ElseIf cTipo == "3" .And. !lInterna
			cQtdSol := "*QUANTIDADESOLICITADA"
			nQtDose := aScan(aMatAux, {|x| x[1] == cQtdSol})
			aMatAux[nQtDose][1] += "*"
			nQtDose := 0
		Else 
			cQtdSol := "QUANTIDADESOLICITADA"
		EndIf
	EndIf

	While aScan(aMatAux, {|x| x[1] == cCodAux}) > 0 //looping que inclui os procedimentos no array do anex.clínicos

		lNCont := .F.

		If nCont > 1 // add uma nova linha.
			aAdd(aCodPro, {})
			aCodPro[Len(aCodPro)] := aClone(aCodPro[1])
			For nX := 1 to Len(aCodPro[Len(aCodPro)])
				aCodPro[Len(aCodPro)][nX][2] := NIL
			Next
		EndIf		

		If cTipo == "1" // posiciona os valores que serão incluídos nos procedimentos de anex. clínicos
			nCodPad := aScan(aMatAux, {|x| x[1] == cCodTab})
			nCodPro := aScan(aMatAux, {|x| x[1] == cCodAux})
			nDesPro := aScan(aMatAux, {|x| x[1] == cDesAux})
			nQtDose := aScan(aMatAux, {|x| x[1] == cQtdSol})
			nUniMed := aScan(aMatAux, {|x| x[1] == "UNIDADEMEDIDA"})
			nViaAdm := aScan(aMatAux, {|x| x[1] == "VIAADMINISTRACAO"})
			nFreque := aScan(aMatAux, {|x| x[1] == "FREQUENCIA"})
			nDatPro := aScan(aMatAux, {|x| x[1] == "DATAPROVAVEL"})
			dDatAux := STOD(sTrTran(aMatAux[nDatPro][2],'-',''))
		ElseIf cTipo == "3"
			nCodPad := aScan(aMatAux, {|x| x[1] == cCodTab})
			nCodPro := aScan(aMatAux, {|x| x[1] == cCodAux})
			nDesPro := aScan(aMatAux, {|x| x[1] == cDesAux})
			nQtDose := aScan(aMatAux, {|x| x[1] == cQtdSol})
			nValSol := aScan(aMatAux, {|x| x[1] == "VALORSOLICITADO"})
			nCodRef := aScan(aMatAux, {|x| x[1] == "CODIGOREFFABRICANTE"})
			nOpcFab := aScan(aMatAux, {|x| x[1] == "OPCAOFABRICANTE"})
			nAutFun := aScan(aMatAux, {|x| x[1] == "AUTORIZACAOFUNCIONAMENTO"})
		EndIf
		
		If At("SOLICITACAOOPME", aMatAux[nCodPro][3]) != 0 .Or. At("SOLICITACAOQUIMIOTERAPIA", aMatAux[nCodPro][3]) != 0 //.Or. At("SOLICITACAOINTERNACAO", aMatAux[nCodPro][3]) != 0
			lEntra := .T.
			dbSelectArea("BR8")
			BR8->(DbSetOrder(1))
			If nCodPad > 0 .And. nCodPro > 0 .And. BR8->( MsSeek(xFilial("BR8")+Alltrim(PLSVARVINC('87', 'BR4', aMatAux[nCodPad][2]))+aMatAux[nCodPro][2]) )
				lRet	:= .T.
				For nX := 1 to Len(aCodPro[nX])
					lReturn := .T.
					Do Case
						Case aCodPro[len(aCodPro)][nX][1] == "SEQMOV"
							aCodPro[len(aCodPro)][nX][2] := StrZero(nCont,3)
						Case aCodPro[len(aCodPro)][nX][1] == "CODPAD"
							aCodPro[len(aCodPro)][nX][2] := Iif(nCodPad > 0 , Alltrim(PLSVARVINC('87', 'BR4', aMatAux[nCodPad][2])),"")
						Case aCodPro[len(aCodPro)][nX][1] == "CODPRO"
							aCodPro[len(aCodPro)][nX][2] := Iif(nCodPro > 0, aMatAux[nCodPro][2],"")
						Case aCodPro[len(aCodPro)][nX][1] == "DESPRO"
							aCodPro[len(aCodPro)][nX][2] := Iif(nDesPro > 0, aMatAux[nDesPro][2],"")
						Case aCodPro[len(aCodPro)][nX][1] == "SLVPAD"
							aCodPro[len(aCodPro)][nX][2] := Iif(nCodPad > 0, aMatAux[nCodPad][2],"")
						Case aCodPro[len(aCodPro)][nX][1] == "SLVPRO"
							aCodPro[len(aCodPro)][nX][2] := Iif(nCodPro > 0, aMatAux[nCodPro][2],"")
						Case aCodPro[len(aCodPro)][nX][1] == "SLVDES"
							aCodPro[len(aCodPro)][nX][2] := Iif(nDesPro > 0, aMatAux[nDesPro][2],"")
						Case aCodPro[len(aCodPro)][nX][1] == "QTD"
							aCodPro[len(aCodPro)][nX][2] := Iif(nQtDose > 0 .And. !Empty(aMatAux[nQtDose][2]),Val(aMatAux[nQtDose][2]), 0)
						Case aCodPro[len(aCodPro)][nX][1] == "QTDAUT"
							aCodPro[len(aCodPro)][nX][2] := Iif(nQtDose > 0 .And. !Empty(aMatAux[nQtDose][2]),Val(aMatAux[nQtDose][2]), 0)
						Case aCodPro[len(aCodPro)][nX][1] == "VLRAPR"
							aCodPro[len(aCodPro)][nX][2] := Iif(nValSol > 0 .And. !Empty(aMatAux[nValSol][2]),Val(aMatAux[nValSol][2]), 0)
						Case aCodPro[len(aCodPro)][nX][1] == "DATINC"
							aCodPro[len(aCodPro)][nX][2] := dDatAux
						Case aCodPro[len(aCodPro)][nX][1] == "NIVEL"
							aCodPro[len(aCodPro)][nX][2] := BR8->BR8_NIVEL
						Case aCodPro[len(aCodPro)][nX][1] == "DESCRI"
							aCodPro[len(aCodPro)][nX][2] := AllTrim(BR8->BR8_DESCRI)
						Case aCodPro[len(aCodPro)][nX][1] == "TPPROC"
							aCodPro[len(aCodPro)][nX][2] := BR8->BR8_TPPROC
						Case aCodPro[len(aCodPro)][nX][1] == "TIPEVE"
							aCodPro[len(aCodPro)][nX][2] := BR8->BR8_TIPEVE
						Case aCodPro[len(aCodPro)][nX][1] == "NIVAUT"
							aCodPro[len(aCodPro)][nX][2] := ANEATTARR(aCodPro[Len(aCodPro)], aItens, "NIVAUT")
						Case aCodPro[len(aCodPro)][nX][1] == "CHVNIV"
							aCodPro[len(aCodPro)][nX][2] := ANEATTARR(aCodPro[Len(aCodPro)], aItens, "CHVNIV")
						Case aCodPro[len(aCodPro)][nX][1] == "NIVCRI"
							aCodPro[len(aCodPro)][nX][2] := ANEATTARR(aCodPro[Len(aCodPro)], aItens, "NIVCRI")
							If !Empty(aCodPro[len(aCodPro)][nX][2])
								lAuditoria := .T.
								lRet	   := .F.
							EndIf

						

					EndCase

				Next nX

				If cTipo == "1"
					Iif ( nViaAdm > 0, aAdd(aCodPro[len(aCodPro)], {"VIAADMINISTRACAO", aMatAux[nViaAdm][2]}), "")
					Iif ( nFreque > 0, aAdd(aCodPro[len(aCodPro)], {"FREQUENCIA", aMatAux[nFreque][2]}), "")
					Iif ( nUniMed > 0, aAdd(aCodPro[len(aCodPro)], {"UNIDADEMEDIDA", aMatAux[nUniMed][2]}), "")
				ElseIf cTipo == "3"
					Iif ( nCodRef > 0, aAdd(aCodPro[len(aCodPro)], {"CODIGOREFFABRICANTE", aMatAux[nCodRef][2]}) , "")
					Iif ( nOpcFab > 0, aAdd(aCodPro[len(aCodPro)], {"OPCAOFABRICANTE", aMatAux[nOpcFab][2]}) , "")
					Iif ( nAutFun > 0, aAdd(aCodPro[len(aCodPro)], {"AUTORIZACAOFUNCIONAMENTO", aMatAux[nAutFun][2]}), "")
				EndIf


			ElseIf !BR8->( MsSeek(xFilial("BR8")+Alltrim(PLSVARVINC('87', 'BR4', aMatAux[nCodPad][2]))+aMatAux[nCodPro][2]) ) .And. !lReturn
				lReturn := .F.
			EndIf
			aMatAux[nCodPad][1] += "*"
			aMatAux[nCodPro][1] += "*"
			aMatAux[nDesPro][1] += "*" 
			If cTipo == "1"
				Iif ( nViaAdm > 0 , aMatAux[nViaAdm][1] += "*" , "")
				Iif ( nFreque > 0 , aMatAux[nFreque][1] += "*" , "")
				Iif ( nDatPro > 0 , aMatAux[nDatPro][1] += "*" , ctod(""))
				Iif ( nUniMed > 0 , aMatAux[nUniMed][1] += "*"  , "")
			ElseIf cTipo == "3"
				Iif ( nCodRef > 0 , aMatAux[nCodRef][1] += "*", "" )
				Iif ( nOpcFab > 0 , aMatAux[nOpcFab][1] += "*", "" )
				Iif ( nValSol > 0 , aMatAux[nValSol][1] += "*", 0 )
				Iif ( nAutFun > 0 , aMatAux[nAutFun][1] += "*", "" )
			EndIf
		ElseIf At("SOLICITACAOOPME", aMatAux[nCodPro][3]) == 0 .Or. At("SOLICITACAOQUIMIOTERAPIA", aMatAux[nCodPro][3]) == 0 //se o procedimento for além dos de anexos clínicos, retiro desse looping, quero só os de anex. clínicos para colocar na B4C
			lNCont := .T.
			aMatAux[nCodPad][1] += "*"
			aMatAux[nCodPro][1] += "*"
			aMatAux[nDesPro][1] += "*" 
		EndIf

		nACodPro := aScan(aCodPro[Len(aCodPro)], {|x| x[1] == "CODPRO"})
		If !lNCont .And. !Empty(aCodPro[len(aCodPro)][nACodPro][2])
			nCont++
		EndIf
		
		If nCont > 1 .And. Empty(aCodPro[len(aCodPro)][nACodPro][2])
			aSize(aCodPro, Len(aCodPro) - 1)
		EndIf
	endDo

	If !lReturn
		Return {lReturn}
	EndIf

	If lEntra
		
		//Monta array de itens no anex.clinico
		For nI:=1 to Len(aCodPro) 

			cSequen := PLSRETDAD(aCodPro[nI],"SEQMOV")
			cSeqB4C := StrZero(nSeqMov,3)
			cCodPad := PLSRETDAD(aCodPro[nI],"CODPAD")
			cCodPro := PLSRETDAD(aCodPro[nI],"CODPRO")
			nQtdPro := Iif(!Empty(PLSRETDAD(aCodPro[nI],"QTD")),PLSRETDAD(aCodPro[nI],"QTD"), 0)
			If cTipo == "1"
				cUnMedida := PLSRETDAD(aCodPro[nI],"UNIDADEMEDIDA") 
				nTotDosag := Iif(!Empty(PLSRETDAD(aCodPro[nI],"QTD")),PLSRETDAD(aCodPro[nI],"QTD"), 0)
				dDatPro   := PLSRETDAD(aCodPro[nI],"DATINC")
			EndIf

			// If BE2->(DbSeek(xFilial("BE2")+cGuiaRef+cSequen))   
			// 	cNivAutCri := &(cAliasAut+"->"+cAliasAut+"_NIVAUT")
			// 	cChaveNiv  := &(cAliasAut+"->"+cAliasAut+"_CHVNIV")  
			// 	lAuditoria := &(cAliasAut+"->"+cAliasAut+"_AUDITO") == "1"            
			// 	lRet       := &(cAliasAut+"->"+cAliasAut+"_STATUS") == "1"
			// EndIf

			If BEA->(DbSeek(xFilial("BEA")+cGuiaRef)) .And. BEG->(DbSeek(xFilial("BEG")+cGuiaRef+cSequen))
	
				While BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == BEG->(BEG_FILIAL)+cGuiaRef+cSequen .And. !BEG->(Eof()) 
					lRet := .F. //Indica que o item foi negado
				
					//Adiciona uma linha em branco para Criticas
					If nSeqCri <> 1
						P09ABlank(aDadCri,aCabCri,aVetCri)
					Endif 
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_SEQUEN",aCabCri)] := cSeqB4C
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_CODGLO",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_CODGLO")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_DESGLO",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_DESGLO")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_CODMOT",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_CODMOT")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_OBSMOT",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_OBSMOT")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_PARTIC",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_PARTIC")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_UNIMED",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_UNIMED")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_SEQCRI",aCabCri)] := Strzero(nSeqCri,3)
					cNivAutCri :=  &(cAliasAut+"->"+cAliasAut+"_NIVCRI")

					nSeqCri++
					BEG->(DbSkip())
				EndDo     
			EndIf	

			//Adiciona uma linha em branco para Procedimentos
			If nSeqMov <> 1
				P09ABlank(aDadProc,aCabProc,aVetProc)
			Endif

			BR8->(DbSetOrder(1))
			BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro)) //Posiciona no procedimento correspondente.
					
			aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_SEQUEN",aCabProc)] := cSeqB4C
			aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_CODPAD",aCabProc)] := cCodPad
			aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_CODPRO",aCabProc)] := cCodPro
			aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_DESPRO",aCabProc)] := AllTrim(BR8->BR8_DESCRI)

			If ValType(PLSRETDAD(aCodPro[nI],"VLRAPR")) $ "U-C"
				nVlrEvent := 0
			Else
				nVlrEvent := PLSRETDAD(aCodPro[nI],"VLRAPR")	
			EndIf
			//Pegando os valores para incluir dentro da B4C aDadProc
			If(PLRETPOS(cAliasPro+"_OPCAO",aCabProc )>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_OPCAO",aCabProc)]  := PLSRETDAD(aCodPro[nI],"OPCAOFABRICANTE"),nil)
			If(PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)] := nQtdPro,nil)
			If(PLRETPOS(cAliasPro+"_VLRUNT",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_VLRUNT",aCabProc)] := nVlrEvent,nil)
			If(PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)] := nQtdPro,nil)
			If(PLRETPOS(cAliasPro+"_VLRUNA",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_VLRUNA",aCabProc)] := If(lRet,nVlrEvent,0),nil)
			If(PLRETPOS(cAliasPro+"_REGANV",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_REGANV",aCabProc)] := PLSRETDAD(aMatAux,"REGISTROANS"),nil)
			If(PLRETPOS(cAliasPro+"_REFMAF",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_REFMAF",aCabProc)] := PLSRETDAD(aCodPro[nI],"CODIGOREFFABRICANTE"),nil)
			If(PLRETPOS(cAliasPro+"_AUTFUN",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_AUTFUN",aCabProc)] := PLSRETDAD(aCodPro[nI],"AUTORIZACAOFUNCIONAMENTO"),nil)
			If(PLRETPOS(cAliasPro+"_VIAADM",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_VIAADM",aCabProc)] := PLSRETDAD(aCodPro[nI],"VIAADMINISTRACAO"),nil)
			If(PLRETPOS(cAliasPro+"_FREQUE",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_FREQUE",aCabProc)] := Val(PLSRETDAD(aCodPro[nI],"FREQUENCIA")), nil)	
			If(PLRETPOS(cAliasPro+"_DATPRO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_DATPRO",aCabProc)] := dDatPro,nil)
			If(PLRETPOS(cAliasPro+"_IMGSTA",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_IMGSTA",aCabProc)] := If(lRet,"ENABLE","DISABLE"),nil)
			If(PLRETPOS(cAliasPro+"_STATUS",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_STATUS",aCabProc)] := If(lRet,"1","0"),nil)
			If(PLRETPOS(cAliasPro+"_AUDITO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_AUDITO",aCabProc)] := IIF(lAuditoria,'1','0'),nil)
			If(PLRETPOS(cAliasPro+"_SALDO",aCabProc )>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_SALDO",aCabProc)]  := nQtdPro,nil)
			If(PLRETPOS(cAliasPro+"_NIVEL",aCabProc )>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NIVEL",aCabProc)]  := BR8->BR8_NIVEL,nil)
			If(PLRETPOS(cAliasPro+"_NIVAUT",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NIVAUT",aCabProc)] := PLSRETDAD(aCodPro[nI],"NIVAUT"),nil)
			If(PLRETPOS(cAliasPro+"_NIVCRI",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NIVCRI",aCabProc)] := PLSRETDAD(aCodPro[nI],"NIVCRI"),nil)
			If(PLRETPOS(cAliasPro+"_CHVNIV",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_CHVNIV",aCabProc)] := PLSRETDAD(aCodPro[nI],"CHVNIV"),nil)
			If(PLRETPOS(cAliasPro+"_NRAOPE",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NRAOPE",aCabProc)] := BEA->BEA_NRAOPE,nil)
			If(PLRETPOS(cAliasPro+"_NRTROL",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NRTROL",aCabProc)] := BEA->BEA_NRTROL,nil)
			If cTipo == "1"
				If(PLRETPOS(cAliasPro+"_UNMED",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_UNMED",aCabProc)]   := cUnMedida,nil)
				If(PLRETPOS(cAliasPro+"_DOSTOT",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_DOSTOT",aCabProc)] := nTotDosag, nil)
				If(PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)] := nTotDosag, nil)		  
				If(PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)] := nTotDosag, nil)
			EndIf
			nSeqMov++        

		Next
	EndIf
EndIf


If ProcName(1) == "PLSLGSP3" .And. !lInterna .And. cTipo != "3"
	nSeqAux := Len(aItens)
	For nX := 1 to len(aCodPro)
		nSeqAux++
		nPosSeq := aScan(aCodPro[nX], {|x| x[1] == "SEQMOV"})
		aCodPro[nX][nPosSeq][2] := StrZero(nSeqAux,3)
	Next nX++
EndIf

Return {lReturn,lAuditoria, aCodPro, aCabProc, aDadProc, aVetProc, aCabCri, aDadCri, aVetCri}

/*/{Protheus.doc} ANEATTARR..
Retorna o array do procedimento do aItens.
@author r.soares
@since 14/12/2020
/*/

Static Function ANEATTARR(aCodPro, aItens, cAlias)
Local nY		:= 0
Local cAux	 	:= ""
Default aCodPro := {}
Default aItens  := {}

For nY := 1 to Len(aItens)
	If aScan(aItens[nY], {|x| Alltrim(x[2]) ==	AllTrim(PLSRETDAD(aCodPro, "CODPRO"))}) > 0 .And. aScan(aItens[nY], {|x| Alltrim(x[1]) == cAlias}) > 0
		cAux := aItens[nY][aScan(aItens[nY], {|x| Alltrim(x[1]) == cAlias})][2]
	EndIf
Next nY

Return cAux


/*/{Protheus.doc} CBOSRda
Retorna o CBOS e codigo da especialidade principal da RDA,
senao tem principal a primeira encontrada e retornada

#tissver 2.x

@type Function
@author Alexander Santos
@since 17/03/2007
@version 1.0
/*/
Function CBOSRda(cCodRda,cCodInt,cCodEsp,cData,cCbosArq)
	Local cEspe 	:= ""  //Codigo da especialidade encontrada no RDA
	Local lEspe 	:= .F. //Indica se encontrou especialidade na RDA
	Local cCBOS		:= ""
	Local cEspAll 	:= GetNewPAr("MV_PESPPLA","'094','055'")
	Local aAreaBAQ	:= BAQ->(GetArea())
	Local aRetEsp	:= {}
	Local nI		:= 0
	DEFAULT cCBOSArq:= ""
	DEFAULT cCodEsp	:= ""
	DEFAULT cData  	:= ''

	cSql := " SELECT BAX_CODESP, BAX_ESPPRI, R_E_C_N_O_ REC FROM "+RetSqlName("BAX")
	cSql += " WHERE BAX_CODINT = '"+cCodInt+"' "
	cSql += " AND BAX_CODIGO   = '"+cCodRda+"' "

	If Empty(cEspAll)
		cSql += " AND BAX_CODESP IN ("+"'"+cCodEsp+"'"+") "
	Else
		cSql += " AND BAX_CODESP IN ("+"'"+cCodEsp+"',"+cEspAll+") "
	Endif

	cSql += " AND (BAX_DATBLO   = ' ' OR (BAX_DATBLO <> ' ' and BAX_DATBLO > '"+ IIF( ValType(cData) == "C", cData, DtoS(cData) )+"'))"
	cSql += " AND D_E_L_E_T_   = ' ' "

	PlsQuery(cSql,"TrbBAX")

	If Empty(cCBOSArq)

		If !TrbBAX->(Eof())
			While !TrbBAX->(Eof())
				BAX->(DbGoTo(TrbBAX->(REC)))
				cEspe := BAX->BAX_CODESP
				TrbBAX->(DbSkip())
			Enddo
		Endif

		If !Empty(cEspe)
			dbSelectArea("BAQ")
			BAQ->(dbSetOrder(1))
			If BAQ->(MsSeek(xFilial("BAQ")+cCodInt+cEspe))
				cCBOS := BAQ->BAQ_CBOS
				lEspe := .T.
			Else
				lEspe := .F.
			EndIf
		Else
			lEspe := .F.
		Endif

	Else
		If !TrbBAX->(Eof())
			While !TrbBAX->(Eof())
				aAdd(aRetEsp,TrbBAX->BAX_CODESP)
				TrbBAX->(DbSkip())
			EndDo
		Endif

		If Len(aRetEsp) > 0
			dbSelectArea("BAQ")
			BAQ->(dbSetOrder(1))
			For nI := 1 to Len(aRetEsp)
				If BAQ->(MsSeek(xFilial("BAQ")+cCodInt+aRetEsp[nI]))
					cEspe := BAQ->BAQ_CODESP
					cCBOS := BAQ->BAQ_CBOS
					lEspe := .T.
					If AllTrim(BAQ->BAQ_CBOS) == AllTrim(cCBOSArq)
						Exit
					Endif
				Else
					lEspe := .F.
				EndIf
			Next nI
		Else
			lEspe := .F.
		Endif
	Endif

	TrbBAX->(DbCloseArea())

	RestArea(aAreaBAQ)

Return({lEspe,cCBOS,cEspe})


//-------------------------------------------------------------------
/*/{Protheus.doc} P973SoPrFi

@author  Renan Sakai
@version P12
@since   15/12/2020
/*/
//-------------------------------------------------------------------
Function P973SoPrFi(cSoapXML,cTissVerOn,cFileHas, lAutoma, aDadAut)
local aResGeral  	:= {}
local aArqRet    	:= {}
local cTipoGlosa 	:= ""
local cMsg       	:= ""
local cMsgCri    	:= ""
local cDatHor		:= fwtimestamp(1) //AllTrim(DtoS(dDataBase)) + AllTrim(StrTran(Time(),":",""))
local cFileTISS 	:= "tissonline"
local nI         	:= 0
local cDtHrEv		:= PLSRetTime()

private l974Xml  	:= .F.
private cXmlResp 	:= ""
default lAutoma		:= .f.
default aDadAut		:= {}

iif( lLogTissOn, PlsPtuLog(PLSRetTime() + " - Iniciando P973SoPrFi (PLSA973)", "tissonanalise.log"), "")

//Redefine Statics
lNoGerFil := .T. //Indica que nao vai gerar arquivos no Server
lOnline   := .T. //Indica que é TISS Online
TISVERS   := cTissVerOn

if !lAutoma
	aArqRet := ProcFile(cFileTISS,cDatHor,cFileHas,nil,nil,.F.,nil,cSoapXML)
else
	aArqRet := aDadAut
endif

if ValType(aArqRet) == "A"
	if aArqRet[1] == nil .or. (lAutoma .and. !empty(aArqRet))
		lOkXML 	   := .F.
		cArqRet	   := nil
		cMsg       := aArqRet[2]
		cTipoGlosa := iif(len(aArqRet) >= 5,aArqRet[5],"")
	else
		cArqRet	:= aArqRet[1]
		cMsg	:= ""
	endIf
endIf

// Verifica retorno
for nI := 1 To Len(aResultado)
	AaDd(aResGeral,aResultado[nI])
next

if !lOkXML
	PlsPtuLog(cDtHrEv + "1- P973SoPrFi - " + cvaltochar(cSoapXML) + cvaltochar(cTissVerOn) + cvaltochar(cFileHas), "tissonanalise.log" )
	PlsPtuLog(cDtHrEv + "2- P973SoPrFi - cMsg/cTipGlosa: " + cvaltochar(cMsg) + "/" + cvaltochar(cTipoGlosa) + CRLF, "tissonanalise.log" )
endif 			

if lLog
	for nI:=1 to Len(aResGeral)
		PLSLOGFIL( aResGeral[nI,1],cDirLog+STR0012 )
		if lOnline
			cMsg += iif( aResGeral[nI,2] == 4, AllTrim(aResGeral[nI,1])+", ", "")

			cMsgCri += iif( (aResGeral[nI,4] .and. 'NUM. GUIA PRESTADOR' $ AllTrim(aResGeral[nI,1])), Chr(13) + AllTrim(StrTran(aResGeral[nI,1],"Tiss	-","") ) + Chr(13) + Chr(13), "")
			cMsgCri += iif( (aResGeral[nI,4] .and. !('NUM. GUIA PRESTADOR' $ AllTrim(aResGeral[nI,1]))), AllTrim(StrTran(aResGeral[nI,1],"Tiss	-","") ) + Chr(13), "")

			cTipoGlosa := iif( !Empty(aResGeral[nI,5]), aResGeral[nI,5], "" )
		endIf
	next
	cMsg := Left(cMsg,Len(cMsg)-2)
endIf 

iif( lLogTissOn, PlsPtuLog(PLSRetTime() + " - Finalizando P973SoPrFi (PLSA973)", "tissonanalise.log"), "" )

Return {cMsg,cArqRet,cMsgCri,lOkXML,cTipoGlosa,cXmlResp}

/*/{Protheus.doc} vldMatPeXml
Função que manipula o ponto de entrada PLSXMLMAT, retornando a matricula definida no PE

@type Function
@author Daniel Silva
@since 07/03/2022
@version 1.0
/*/
static Function vldMatPeXml(cMatArq,cNomUsr,cMatOrig)

local cRetPeMt := ""
local cMatXML  := ""

cRetPeMt := ExecBlock("PLSXMLMAT",.F.,.F.,{cMatArq,cNomUsr,cMatOrig})

if ValType(cRetPeMt) == "C" .And. !Empty(cRetPeMt)
	cMatXML := cRetPeMt 
else
	cMatXML := cMatArq
endif

Return cMatXML


/*/{Protheus.doc} PlGrvDntW
Grava dente, caso nãoe xistir na base. O schema valida se o dente inserido é válido ou não, e para gravar corretamente,
inserimos na B04 e B05.
@since 08/2022
@version 1.0
/*/
function PlGrvDntW(cCodPad, cCodPro, cRegDen, cDescricao)
local cTipoOd	:= padr("1",TamSX3("B04_TIPO")[1])
local cDenteFrm	:= padr(cRegDen,TamSX3("B04_CODIGO")[1])

if !B04->(DbSeek(xFilial("B04") + cDenteFrm + cTipoOd))
	B04->(RecLock("B04", .t.))
		B04->B04_FILIAL := xFilial("B04")
		B04->B04_CODIGO := cRegDen
		B04->B04_DESCRI := cDescricao
		B04->B04_TIPO	:= cTipoOd
	B04->(MsUnlock())
endif
B05->(RecLock("B05", .t.))
	B05->B05_FILIAL := xFilial("B05")
	B05->B05_CODIGO := cRegDen
	B05->B05_CODPAD := cCodPad
	B05->B05_CODPSA := cCodPro
	B05->B05_DESCRI := cDescricao
	B05->B05_TIPO	:= cTipoOd
B05->(MsUnlock())

return .t.


/*/{Protheus.doc} PlRtDOdoFc
Ajusta a string de Face, para o formato que a função P90ODVldDF espera, para retornar se existe a(s) face(s) informada(s).
@since 08/2022
@version 1.0
/*/
function PlRtDOdoFc(cFace, cCodpad, cCodPro, cRegDen)
local aRetVld	:= {}
local cStrFrm	:= ""
local nFor		:= 0

for nFor := 1 to len(cFace) 
	cStrFrm += SUBSTR(cFace, nFor, 1) + "|"
next

aRetVld := P90ODVldDF("F", cCodPad, cCodPro, cRegDen, cStrFrm)

return aRetVld
