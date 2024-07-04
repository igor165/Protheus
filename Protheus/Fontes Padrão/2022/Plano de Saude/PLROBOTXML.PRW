#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "FOLDER.CH"

static aRecProc := {}
static ddatepro := date()
/*
Sugestão de INI

[ONSTART]
JOBS=XML_ROTBOT
REfreshRate=600 ;; a cada 600 segundos o protheus verifica se os jobs estão no ar. é recomendavel a cada 10 minutos

[XML_ROTBOT]
Environment=PRODUCAO
main=XmlRoute

*/

//funcao para chamar a rotina manualmente, sem estar no startjob do server
//para desenvolvedor
user Function rodaXML()

	putGlbValue( "para", "0" )

	DEFINE MSDIALOG oDlg TITLE "Rodando" FROM 0,0 TO  165, 300 PIXEL //"Sobre o TSS..."

	@001, 050 BUTTON oBtn PROMPT "RODAR" SIZE 055, 025 ACTION ( u_rodando() )  OF oDlg PIXEL

	@030, 050 BUTTON oBtn PROMPT "PARAR" SIZE 055, 025 ACTION ( putGlbValue( "para", "1" ) )  OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

return

//------------------------------------------------------------------------------

user function rodando()

	startJob("XmlRoute",GetEnvServer(),.F.)

return

//------------------------------------------------------------------------------

/*/{Protheus.doc} roboProcPeg
//TODO Descrição auto-gerada.
@author henrique.souza/romulo.ferrari
@since 03/02/2017
@version 12.1.7

@type function
/*/
function XmlRoute(lAuto)

	local cLock 	 := "roboProcPeg.lck"
	local lHdl    	 := .F.
	local lHdlThread := .F.
	local maxThread := 0
	local nQtd  	:= 0
	local aRecBxx   := {}
	local cSrvName  := Upper(AllTrim(GetPvProfString( GetEnvServer(), "PLSROBONAME", "", GetADV97() )))//'ROBOPLS01'
	local cEmpPos 	:= Upper(AllTrim(GetPvProfString( GetEnvServer(), "EMPROBOXML", "", GetADV97() )))//'99'
	local cFilPos 	:= Upper(AllTrim(GetPvProfString( GetEnvServer(), "FILROBOXML", "", GetADV97() )))//'01'
	local cCodInt	:= ''

	local nMaxXML	 := 0
	local lOk := .F.
	default lAuto := .f.

	rpcSetType(3)
	rpcSetEnv( cEmpPos, cFilPos,,,'PLS',, )

	//se nao foi definido a tag PLSROBONEME no .INI, utilizamos a porta do server para criar o nome do arquivo de lock
	if empty(cSrvName)
		cSrvName  := "XSUB" +Upper(AllTrim(GetPvProfString( "TCP", "PORT", "", GetADV97() )))
	endIf

	//OBS:Todas as funcoes necesarias para a rotina devem ser chamadas abaixo do RpcSetEnv


	cCodInt	:= PlsIntPad()

	BA0->(dbSetOrder(1))
	IF !BA0->(MsSeek(xfilial("BA0")+cCodInt))

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Operadora padrao nao localizada pela funcao PlsIntPad()" , 0, 0, {})

		RPCClearEnv()

		return

	endIf

	maxThread := getNewPar("MV_PLSMAXT", 15 )

	if ( !empty(cSrvName) )

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "XMLROUTE - " + AllTrim(cSrvName) , 0, 0, {})
		while !killApp() //.and. getGlbValue( "para" ) == "0" //usar este getGlbValue apenas para debug

			//verifica se o server tem thread para processar
			while nQtd <= maxThread

				nQtd++

				cLockThread := cSrvName + allTrim(str(nQtd)) + ".lck"

				lHdlThread := semafControl( cLockThread )

				if ( lHdlThread )

					while !lHdl

						lHdl := semafControl( cLock )

						if ( lHdl )
							exit
						endif

						sleep( 1000 )

					end

					cAlias := getNextAlias()

					BeginSql Alias cAlias

					select r_e_c_n_o_  recbxx
					from %table:BXX% BXX
					where bxx_filial = %exp:xFilial("BXX")%
					and bxx_codint = %exp:cCodInt%
					and bxx_status = '0'//Nao processado
					and bxx_tpnfs  = '1'//Sim
					and bxx_tipgui  != '10'//Recurso de glosa
					and BXX.%notDel%

					EndSql

					if ( !(cAlias)->(Eof()) )

						BXX->(dbGoTo((cAlias)->recbxx))

						BXX->(recLock("BXX",.F.))
						BXX->BXX_STATUS := '4'//Aberto
						BXX->(MsUnlock())

						nRecno := (cAlias)->(recbxx)

						(cAlias)->(dbCloseArea())

						semafControl( cLock, .T., lHdl )

						processaXml( lHdlThread, nRecno, cLockThread, lAuto )

					else

						(cAlias)->(dbCloseArea())

						semafControl( cLock, .T., lHdl )
						semafControl( cLockThread, .T., lHdlThread )

						exit

					endif

				endif
				if !lAuto
					sleep(1500)
				else
					return
				endif

			end

			nQtd := 0
			if lAuto
				semafControl( cLock, .T., lHdl )
				exit
			endif
			sleep( 10000 )

		end

	else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Para que o robo processe deve ser definido o nome deste server atraves do parametro 'ROBONAME' no appserver.ini.", 0, 0, {})

	endif
	if !lAuto
		RPCClearEnv()
	endif

return

//-------------------------------------------------------------------

static function processaXml( lHdlThread, nRecno, cLockThread, lAuto )
	default lAuto := .f.
	UnLockByName( cLockThread,.T.,.T. )
	if !lAuto
		startJob("executeProcXml",GetEnvServer(),.F.,nRecno, cLockThread)
	else
		executeProcXml( nRecno, cLockThread, lAuto )
	endif

return

//-------------------------------------------------------------------

function executeProcXml( nRecno, cLockThread, lAuto )

	local lHdl
	local cDirRaiz 	:= ""
	local cDirUpload:= ""
	local cDirBkp 	:= ""
	local cEmpPos 	:= ''
	local cFilPos 	:= ''
	//	local bError 	:= errorBlock( {|e| restoreProc( nRecno, e ) } )
	default lAuto := .f.
	cEmpPos 	:= Upper(AllTrim(GetPvProfString( GetEnvServer(), "EMPROBOXML", "", GetADV97() )))//'99'
	cFilPos 	:= Upper(AllTrim(GetPvProfString( GetEnvServer(), "FILROBOXML", "", GetADV97() )))//'01'

	rpcSetType(3)
	rpcSetEnv( cEmpPos, cFilPos,,,'PLS',, )

	lHdl := semafControl( cLockThread )

	begin sequence

		If p973cest()

			cDirRaiz 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\") )
			cDirUpload  := PLSMUDSIS( cDirRaiz+"UPLOAD\")
			cDirBkp 	:= PLSMUDSIS( cDirRaiz+"UPLOAD\BACKUP\")

			//funcao que processa e peg

			BXX->(DbGoTo(nRecno))

			cCodRDA := BXX->BXX_CODRDA
			cFilesU := allTrim( BXX->BXX_ARQIN )

			aRet := {}

			nTotFile	:= 0
			nVlrTot		:= 0
			nTotEve		:= 0
			nTotGui		:= 0
			nCont		:= 0
			nValTot		:= 0
			cNomArq		:= ""
			cMsg		:= ""
			cTipGui		:= ""
			cLotGui		:= ""
			cTissVer	:= ""

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "INICIO PROCESSAMENTO ARQUIVO ["+cDirUpload+cFilesU+"]", 0, 0, {})

			if File(cDirUpload+cFilesU )

				__CopyFile( cDirUpload+cFilesU , cDirBkp+cFilesU )

				ptInternal(1,"Submetendo XML: " + BXX->BXX_SEQUEN)

				aRet := PLSA973L(cDirUpload+cFilesU ,cCodRda,.T.,.F.,@cTipGui,@cLotGui,@nTotEve,@nTotGui,@nValTot,BXX->BXX_SEQUEN,,@cTissVer)

				PLSMANBXX(cCodRDA,cFilesU,cTipGui,cLotGui,nTotEve,nTotGui,nValTot,/*K_Incluir*/ 3 ,/*nRecno*/,/*lProcOk*/,aRet,,,,cTissVer)

				CNULL := PLSINALUP('PLROBOTXML', cCodRDA, .T., .F., cDirUpload+cFilesU,aRet)

				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "FINALIZANDO PROCESSAMENTO ARQUIVO ["+cDirUpload+cFilesU+"]", 0, 0, {})

				If ckTamArq(cDirBkp,cFilesU) > 0
					If FERASE(cDirUpload+cFilesU) == -1
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Arquivo não excluido da pasta'+cDirUpload+cFilesU, 0, 0, {})
					Else
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Arquivo excluido da pasta'+cDirUpload+cFilesU, 0, 0, {})
					Endif
				Endif

			else
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Arquivo não encontrado na pasta ' + cDirUpload, 0, 0, {})
			endIf
		Endif

	end sequence

	semafControl( cLockThread, .T., lHdl )

	if !lAuto
		RPCClearEnv()
	endif
return

Static function ckTamArq(cDirBkp,cFile)
	Local oFile
	Local cNomFull := cDirBkp + cFile
	Local nTamFil := 0

	oFile := FWFileReader():New(cNomFull)
	if (oFile:Open())
		nTamFil := oFile:getFileSize()
		oFile:Close()
	endif

Return nTamFil

//-------------------------------------------------------------------

static function semafControl( cLock, lLibera, lHdl )

	default lLibera := .F.

	makeDir(GetPathSemaforo())

	if ( lLibera )
		UnLockByName(cLock,.T.,.T.)
	else
		lHdl := LockByName(cLock,.T.,.T.)
	endif

return lHdl

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³p973cest  ³Autor  ³ Daher			              ³ Data ³ 09.11.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao principal													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function p973cest()
	LOCAL nI	:= 1
	LOCAL lRet  := .T.
	LOCAL cDirRaiz := GetNewPar("MV_TISSDIR","\TISS\")
	LOCAL aDirs := {PLSMUDSIS( cDirRaiz ),;
		PLSMUDSIS( cDirRaiz+"CAIXAENTRADA\" ),;
		PLSMUDSIS( cDirRaiz+"SCHEMAS\" ),;
		PLSMUDSIS( cDirRaiz+"UPLOAD\"),;
		PLSMUDSIS( cDirRaiz+"UPLOAD\BACKUP\") ,;
		PLSMUDSIS( cDirRaiz+"LOG\" ),;
		PLSMUDSIS( cDirRaiz+"TEMP\" ),;
		PLSMUDSIS( cDirRaiz+"CAIXASAIDA\" ),;
		PLSMUDSIS( cDirRaiz+"PROCESSADOS\" ),;
		PLSMUDSIS( cDirRaiz+"NAOPROCESSADOS\" ),;
		PLSMUDSIS( cDirRaiz+"DOWNLOAD\"),;
		PLSMUDSIS( cDirRaiz+"UPLOAD\MANUAL\")}

	For nI:=1 to Len(aDirs)
		If !ExistDir(aDirs[ni])
			If MakeDir( aDirs[ni] ) <> 0
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Diretorio não encontrado e não foi possivel cria-lo ["+aDirs[ni]+")", 0, 0, {})
				lRet := .F.
			EndIf
		EndIf
	Next
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlImport
Robô de importação após a submissão do arquivo XML
@author Oscar Zanin
@since 10/06/2019
@version P12
/*/
//-------------------------------------------------------------------
function XmlImport(lAuto)

	local cLock 	 := "roboImpXML.lck"
	local lHdl    	 := .F.
	local lHdlThread := .F.
	local maxThread := 0
	local nQtd  	:= 0
	local aRecBxx   := {}
	local cSrvName  := Upper(AllTrim(GetPvProfString( GetEnvServer(), "PLSROBOIMP", "", GetADV97() )))//'ROBOPLS01'
	local cEmpPos 	:= Upper(AllTrim(GetPvProfString( GetEnvServer(), "EMPROBOXML", "", GetADV97() )))//'99'
	local cFilPos 	:= Upper(AllTrim(GetPvProfString( GetEnvServer(), "FILROBOXML", "", GetADV97() )))//'01'
	local cCodInt	:= ''

	local nMaxXML	 := 0
	local lOk := .F.
	default lAuto := .f.
	rpcSetType(3)
	rpcSetEnv( cEmpPos, cFilPos,,,'PLS',, )

	//se nao foi definido a tag PLSROBONEME no .INI, utilizamos a porta do server para criar o nome do arquivo de lock
	if empty(cSrvName)
		cSrvName  := "XIMP" + Upper(AllTrim(GetPvProfString( "TCP", "PORT", "", GetADV97() )))
	endIf

	//OBS:Todas as funcoes necesarias para a rotina devem ser chamadas abaixo do RpcSetEnv


	cCodInt	:= PlsIntPad()

	BA0->(dbSetOrder(1))
	IF !BA0->(MsSeek(xfilial("BA0")+cCodInt))

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Operadora padrao nao localizada pela funcao PlsIntPad()" , 0, 0, {})

		RPCClearEnv()

		return

	endIf

	maxThread := getNewPar("MV_PLSMAXT", 15 )

	if ( !empty(cSrvName) )

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "XMLIMPORT - " + AllTrim(cSrvName) , 0, 0, {})
		while !killApp() //.and. getGlbValue( "para" ) == "0" //usar este getGlbValue apenas para debug

			//verifica se o server tem thread para processar
			while nQtd <= maxThread

				nQtd++
				cLockThread := cSrvName + allTrim(str(nQtd)) + ".lck"
				lHdlThread := semafControl( cLockThread )

				if ( lHdlThread )

					while !lHdl

						lHdl := semafControl( cLock )

						if ( lHdl )
							exit
						endif

						sleep( 1000 )
					end

					cAlias := getNextAlias()

					BeginSql Alias cAlias

					select r_e_c_n_o_  recbxx
					from %table:BXX% BXX
					where bxx_filial = %exp:xFilial("BXX")%
					and bxx_codint = %exp:cCodInt%
					and bxx_status = '1'//Acatado
					and BXX.%notDel%

					EndSql

					while !(cAlias)->(Eof())
						if VrecProc((cAlias)->(recbxx))
							exit
						endif
						(cAlias)->(dbskip())
					enddo

					if ( !(cAlias)->(Eof()) )

						BXX->(dbGoTo((cAlias)->recbxx))

						nRecno := (cAlias)->(recbxx)

						(cAlias)->(dbCloseArea())

						semafControl( cLock, .T., lHdl )

						ImpArq()

					else

						(cAlias)->(dbCloseArea())

						semafControl( cLock, .T., lHdl )
						semafControl( cLockThread, .T., lHdlThread )

						exit

					endif
				endif
				if !lAuto
					sleep(1500)
				endif

			end

			if lAuto
				semafControl( cLock, .T., lHdl )
				exit
			endif

			nQtd := 0
			sleep( 10000 )
		end

	else

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Para que o robo processe deve ser definido o nome deste server atraves do parametro 'ROBONAME' no appserver.ini.", 0, 0, {})
	endif

	if !lAuto
		RPCClearEnv()
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpArq
Robô de importação após a submissão do arquivo XML
@author Oscar Zanin
@since 10/06/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function ImpArq()

	Local lTudOk := .F.
	Local cFileXml := Alltrim(BXX->BXX_ARQIN) //aCols[nI,nPos]
	Local cCodPeg  := BXX->BXX_CODPEG //aCols[nI,nPosI]
	Local cCodRda  := BXX->BXX_CODRDA //aCols[nI,nPosIII]
	Local cSeqBXX  := BXX->BXX_SEQUEN //aCols[nI,nPosSeq]
	Local nRecno	:= BXX->(Recno()) //aCols[nI, Len(_aHeaderBXX)]//_aTrbBXX[nI]
	Local cTissVer := BXX->BXX_TISVER
	Local TISVERS  := cTissVer
	Local lQuebra  := .F.
	Local laplquebra := findfunction("PLSA821")

	lTudOk:= VERINCPEG(BXX->BXX_CHVPEG,cCodRda)
	If !lTudOk
		If !empty(BXX->BXX_CHVPEG)
			if !PLSDELMOVZ(BXX->BXX_CHVPEG,"1",lTudOk,BXX->BXX_TIPGUI)
				return(.f.)
			endIf
		endIf
	EndIf

	// processamento
	aRet := procTiss(cFileXml,nil,nil,cCodRda,.T.,nil,cCodPeg,cTissVer, .t.)

	PLSMANBXX(cCodRda,/*cNomArq*/,/*cTipGui*/,/*cLotGui*/,/*nTotEve*/,/*nTotGui*/,/*nVlrTot*/,K_Alterar,nRecno,.t.,aRet)
	If laplquebra
		If BCI->BCI_CODPEG <> cCodPeg
			BCI->(dbsetOrder(1))
			If BCI->(MsSeek(xfilial("BCI")+PLSINTPAD()+PLSRETLDP(2)+cCodPeg))
				lQuebra := PLSA821(.F.)
			endIf
		else
			lQuebra := PLSA821(.F.)
		endIf
	endIf
	addFilaPLS(cCodPeg, PLSRETLDP(2), iif(BXX->BXX_TIPGUI == "07", "02", BXX->BXX_TIPGUI))
	If lQuebra
		P821adFila(cCodPeg, PLSRETLDP(2))
	endIf
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSxHAT002
Robô de integração com o HAT
@author Oscar Zanin
@since 10/06/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSxHAT002()
	ConOut("O robo PLSxHAT002 foi descontinuado, acesse https://tdn.totvs.com/pages/releaseview.action?pageId=636318321 para maiores informações!")
return

function PLSvHAT002()
	ConOut("O robo PLSvHAT002 foi descontinuado, acesse https://tdn.totvs.com/pages/releaseview.action?pageId=636318321 para maiores informações!")
return

//Get in the robot!
static function VrecProc(nRecno)
Local ladd := .f.

if ddatepro < date()
	ddatepro := date()
	aRecProc := {}
endif

if len(aRecProc) > 200
	aRecProc := {}
endif

If empty(aRecProc) .OR. ascan(aRecProc, nRecno) == 0
	aadd(aRecProc, nRecno)
	ladd := .t.
endif

return ladd

//chamada de debug
user function XmlRoute
	XmlRoute(.T.)
return

user function XmlImport
	XmlImport()
return
