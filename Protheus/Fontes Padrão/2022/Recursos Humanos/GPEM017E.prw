#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "GPEM017E.CH"
#include "FILEIO.CH"

Static aSM0		:= FWLoadSM0()

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM017E
Importação de arquivos históricos do eSocial
para migração de software terceiros para o GPE
@author  Silvia Taguti
@since   22/12/2020
@version  1
/*/
//-------------------------------------------------------------------
Function GPEM017E(lProcess)

Local   lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Private lInExec		:= .F.
Private aSlice		:= {}
Private aSliced		:= {}
Private aXMLCopy	:= {}
Private aNotImport	:= {}

Default lProcess		:= .F.

If lMiddleware
	If !FWIsInCallStack( "GPEMarkBrw" )
		// Monta o Wizard
		Gpem17Wizd(lProcess)
	EndIf
Else
	MsgAlert(STR0006)  //"Para utilização do migrador, a empresa deverá operar com o Middleware ativado."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Gpem17Wizd
Monta o Wizard com os passos
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function Gpem17Wizd(lProcess)

Local oPanel    := Nil
Local oNewPag   := Nil
Local oStepWiz  := Nil
Local lRadio	:= .F.

Default lProcess := .F.

oStepWiz := FWWizardControl():New()
oStepWiz:ActiveUISteps()

oNewPag := oStepWiz:AddStep("1")
oNewPag:SetStepDescription(STR0007)  //"Observações"
oNewPag:SetConstruction( { |Panel1| MigrPag1(Panel1) } )
oNewPag:SetNextAction( {|| .T. } )
oNewPag:SetCancelAction( {|| .T.} )

oNewPag := oStepWiz:AddStep("2")
oNewPag:SetStepDescription(STR0008)  //"Parâmetros e Processamento"
oNewPag:SetConstruction( { |Panel2| MigrPag2(Panel2, lRadio, lProcess ) } )
oNewPag:SetNextAction( {|| !MigrInExec() } )
oNewPag:SetCancelAction( {|| .T. })

oNewPag:SetPrevWhen({|| !MigrInExec() })
oNewPag:SetCancelWhen({|| !MigrInExec() })
oStepWiz:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Pag1
Painel com os descritivos da solução
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrPag1(oPanel)

TSay():New(25, 20, {||  fText("BEMVINDO")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
TSay():New(45, 20, {||  fText("ASSIST")        }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
TSay():New(95, 20, {||  fText("TITETAPAS")     }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
TSay():New(120, 25, {|| fText("TEXTETAPAS")    }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Pag2
Painel com os parâmetros
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Function MigrPag2(oPanel, lRadio, lProcess)

Local cDirImp   	:= Space(150)
Local aSubDiret		:= {}
Local oButtonFile   := Nil
Local oButtonProc	:= Nil
Local oSayFile  	:= Nil
Local oSayExec		:= Nil
Local oRadio		:= Nil
Local oGetFile		:= Nil
Local oGetThrd		:= Nil
Local nRadio		:= 1
Local cFilProc		:= ""
Local cNumThrd		:= "01"

Default lRadio 		:= .F.
Default lProcess	:= .F.

oSayExec := TSay():New(50, 10, { || STR0001 }, oPanel,,,,,, .T.,,, 200,20)//"Parâmetros Importação"

oSayFile := TSay():New(80, 10, { || STR0010 }, oPanel,,,,,, .T.,,, 200,20)  //"Diretório"

oGetFile := TGet():New(90, 10, { || cDirImp }, oPanel, 160, 009, "",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cDirImp,,,,)
oButtonFile  := TButton():New( 90, 172, OemToAnsi("..."), oPanel, {|| aSubDiret := MigrFile(oButtonProc, @cDirImp) }, 25, 10,,, .F., .T., .F.,, .F.,,, .F.)

oButtonProc  := TButton():New( 120, 105, OemToAnsi(STR0011), oPanel, {|| MigrBarra(oPanel, aSubDiret, oButtonFile, oButtonProc, oRadio, oGetFile, oGetThrd, nRadio, Val(cNumThrd), lProcess, lRadio ) },;
																							80, 15,,, .F., .T., .F.,, .F.,,, .F. )
If GetRemoteType() <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
	oSayExec:setCSS( fCSS("TEXTTITLE") )
	oButtonFile:setCSS( fCSS("BTFILE") )
	oSayFile:setCSS( fCSS("TEXTTITLE") )
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrFile
Seleção do diretório a ser importado e validação da estrutura de pastas
@author  Silvia Taguti
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrFile(oButtonProc, cDirPai)

Local cDirImp	:= cGetFile(STR0012 , STR0010, , STR0013, .F., nOR(GETF_LOCALHARD, GETF_MULTISELECT,GETF_RETDIRECTORY), .T.,.T.) //"Arquivo xml|*.xml"//"Diretório"//"C:\"
Local aSubDiret	:= {}
Local aSubOk	:= {}
Local nX		:= 0
Local nPosEmp	:= 0

If ExistDir(cDirImp)

	aSubDiret := Directory(cDirImp + "*.*", "D")

	If Len(aSubDiret) > 0
		For nX := 1 To Len(aSubDiret)
			nPosEmp := aScan( aSM0, { |x| x[18] == aSubDiret[nX][1] } )
			If nPosEmp > 0
				aAdd( aSubOk, {;
								cDirImp + aSubDiret[nX][1],;
								aSM0[nPosEmp][1],;
								aSM0[nPosEmp][2],;
								aSM0[nPosEmp][18];
							  };
					)
			EndIf
		Next nX

		If Len(aSubOk) > 0
			cDirPai := cDirImp
			oButtonProc:Enable()
		Else
			cDirImp := ""
			MsgAlert(STR0014, STR0015) //"Não foi encontrado nenhuma pasta com CNPJs informados no diretório.", "Atenção"
		EndIf
	Else
		cDirImp := ""
		MsgAlert(STR0016) //"Não foram encontrados subdiretórios."
	EndIf
Else
	cDirImp := ""
	MsgAlert(STR0017, STR0015)  //"Diretório inválido ou não selecionado"
EndIf

Return(aSubOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Barra
Monta a barra de progresso na parte de baixo do painel 2 da wizard
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrBarra(oPanel, aSubDiret, oButtonFile, oButtonProc, oRadio, oGetFile, oGetThrd, nRadio, nNumThrd, lProcess, lRadio)

Local cTextProc	:= ""
Local nMeter	:= 0
Local oMeter	:= Nil
Local oSaySep	:= Nil
Local oSayProc	:= Nil
Local aFiles	:= {}

Default lProcess := .F.
Default lRadio	 := .F.

lInExec := .T.

If Len(aSubDiret) == 0
	MsgAlert(STR0017, STR0015)  //"Diretório inválido ou não selecionado"
	Return
Endif

If lRadio .And. !lProcess
	MsgStop( STR0018, STR0019 )  //Advertência'//"Selecione algum evento para importar."
Else
	// Desabilita os botões
	oButtonFile:Disable()
	oButtonProc:Disable()
	oGetFile:Disable()

	oSaySep := TSay():New(140, 02, { || Replicate("_", 150) }, oPanel,,,,,, .T.,,, 300,20)
	oSaySep:setCSS( fCSS("LINESEPARADOR") )

	cTextProc := STR0020   //"Iniciando Processamento..."

	oSayProc := TSay():New(170, 100, { || cTextProc }, oPanel,,,,,, .T.,,, 300,20)
	oSayProc:setCSS( fCSS("TEXTTITLE") )

	oMeter := TMeter():New( 180, 100, { |u| Iif( Pcount() > 0, nMeter := u, nMeter) }, 100, oPanel, 100, 16,, .T.)
	oMeter:setCSS("METER")
	oMeter:SetTotal(0)
	oMeter:Set(0)
	// Chama as funções de processamento
	MigrProc(aSubDiret, oSayProc, oMeter, nRadio, nNumThrd, lProcess )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Proc
Encapsula as funções de processamento
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrProc(aSubDiret, oSay, oMeter, nRadio, nNumThrd, lProcess)

Local aFilesXML := {}
Local nExec		:= 0
Local nQtdTot	:= 0
Local nX		:= 0
Local lRadio	:= .F. //--> Acrescentado lRadio para controlar qual RadioButton foi checado.

Default lProcess := .F.

oSay:CtrlRefresh()

oSay:setText(STR0021)  //"Verificando diretório"
oSay:CtrlRefresh()

If nRadio == 1 //.Or. nRadio == 3

	For nX := 1 To Len(aSubDiret)
		nExec := 0
		While Len( aFilesXML := MigrDir(aSubDiret[nX][1], nExec) ) > 0

			// Processa o lote de XML lido
			MigrLote(aFilesXML, oSay, oMeter, aSubDiret[nX][1], aSubDiret[nX][3], @nQtdTot, aSubDiret[nX][4])

			aFilesXML := {}
			aSize(aFilesXML, 0)
			nExec++
		EndDo
	Next nX

	// Move o XML para outro diretório e processa os XMLs gerados
	If Len(aSliced) > 0
		If Len(aSliced) > 0
			FWMsgRun(, {|| MigrCopy(aSliced) }, STR0022, STR0023 ) //"Aguarde..." "Movendo XMLs consolidados para outro diretório."
		EndIf

		//Processa os XMLs que foram gerados
		FWMsgRun(, {|oFWRun| MigrPend(oFWRun) }, STR0022, STR0024 )  //"Aguarde..." "Verificando XMLs gerados através do Lote."
	EndIf

	If Len(aXMLCopy) > 0
		FWMsgRun(, {|| MigrCopy(aXMLCopy) }, STR0022, STR0025 ) //"Aguarde..." "Movendo XMLs processados para outro diretório."
	EndIf

	If Len(aNotImport) > 0
		FWMsgRun(, {|| MigrRel(aNotImport) }, STR0022, STR0025 ) //"Aguarde..." //"Gerando Inconsistências."
	EndIf
EndIf

MsgAlert(STR0027, STR0015)  //"Importação Finalizada", "Atenção"
lInExec := .F.

If ValType(oMeter) <> "U"
	oSay:setText(STR0027)  //"Importação Finalizada."
	oMeter:Free()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Dir
Retorna os XML's do diretório
Controla paginação dos arquivos, pois a função directory retorna 10.000 arquivos por vez
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrDir(cDirImp, nExec)

Local cFlagParameters := "N:" + cValToChar( (nExec * 10000) )
Local aFiles		  := {}

If Right(cDirImp, 1) <> "\"
	cDirImp += "\"
EndIf

aFiles := Directory(cDirImp + "*.xml", cFlagParameters)

Return(aFiles)

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrLote
Processamento do lote de XML
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrLote(aFilesXML, oSay, oMeter, cDirImp, cFilProc, nQtdTot, cCNPJ)

Local nX 		:= 0
Local oVOMigr	:= GPEVOMigr():New()

oMeter:SetTotal( Len(aFilesXML) )

For nX := 1 To Len(aFilesXML)

	nQtdTot ++
	oMeter:Set(nX)
	oSay:setText(STR0028 + cValToChar(nQtdTot) )  //"XMLs Processados: "
	ProcessMessages() // Força atualização no smartclient

	oVOMigr:SetFileXML(aFilesXML[nX][1])

	//Realiza as valiadações e grava o XML na RED
	MigrGrv( oVOMigr, cDirImp, cFilProc, cCNPJ )
	oVOMigr:Clear()

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrGrv
Realiza as validações e grava o XML na RED
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrGrv( oVOMigr, cPath, cFilProc, cCNPJ )

Local cMessage		:= ""
Local cREDEnvio		:= "" 	// XML "Envio" gravado na RED
Local cREDReceipt	:= "" 	// XML "Recibo" gravado na RED
Local cXmlBuffer	:= ""
Local cXMLEncode 	:= ""
Local cXMLDecode	:= ""
Local lInsert		:= .T.
Local lSuccess		:= .T.
Local lUpdError		:= .F.
Local oXML 			:= tXMLManager():New()
Local nPosFim		:= 0

RED->( dbSetOrder(2) )

If Right(cPath, 1) <> "\"
	cPath += "\"
EndIf

cXmlBuffer := MigrReader( cPath + oVOMigr:GetFileXML() )

If "<?xml" $ cXmlBuffer
	nPosFim 	:= At(">", cXmlBuffer)
	cXmlBuffer := SubStr( cXmlBuffer, nPosFim + 1)
EndIf

// Para gravar no banco deve-se retirar o Encode por conta do Charset do Banco.
cXMLEncode  := EncodeUTF8(cXmlBuffer)

If Empty(cXMLEncode)
	cXMLDecode := DecodeUTF8(cXmlBuffer)
	cXMLEncode := cXmlBuffer
Else
	cXMLDecode := cXmlBuffer
EndIf

// Se for retorno de XML em lote, transforma o lote em arquivos unitários e processa posteriormente.
If "ConsultarLoteEventosResponse" $ cXmlBuffer .Or. "retornoProcessamentoLoteEventos" $ cXmlBuffer .Or. "envioLoteEventos" $ cXmlBuffer
	MigrSlice(cXmlBuffer, cPath, cFilProc, cCNPJ)

	aAdd( aSliced, { cPath,	oVOMigr:GetFileXML() } )
Else
	//Grava o XML sem Decode
	oVOMigr:SetXML( cXMLDecode )
	//Faz o Parse com o XML com Encode
	If oXml:Parse( cXMLEncode) // Faz o parser para garantir que é um válido

		// Valida o XML e retorna o tipo do mesmo
		nTipo := MigrType(oXML, oVOMigr, cCNPJ, cFilProc)
		// Valida se o empregador do XML é o mesmo do diretório de pastas
		If ( nTipo == 1 .And. oVOMigr:GetCNPJXml() == SubStr(oVOMigr:GetCNPJ(), 1, 8) ) .Or. ( nTipo == 2 .And. Empty( oVOMigr:GetCNPJXml() ) )

			If nTipo == 1 .Or. nTipo == 2
				If RED->( MsSeek( xFilial("RED") + oVOMigr:GetID() + oVOMigr:GetCNPJ() ) )
					lInsert     := .F.
					cREDEnvio   := RED->RED_XMLERP
					cREDReceipt := RED->RED_RECIBO
				EndIf

				// --> Se for alteração, verifica se o registro já foi integrado
				If !lInsert
					If RED->RED_STATUS == "5"
						lSuccess := .F.
						cMessage := STR0029     		//"Registro já processado"
					EndIf

					// Validação para não efetuar a sobreposição das informações já existentes na base
					If RED->RED_STATUS <> '5' .And. nTipo == 1 .And. !Empty( oVOMigr:GetXML() ) .And. !Empty(cREDEnvio)
						lSuccess := .F.
						cMessage := STR0030   			//"XML de envio já informado, registro ignorado."

						// Guarda os XMLs que já foram processados para mover para o diretório de processado com sucesso
						aAdd( aXMLCopy, { cPath, oVOMigr:GetFileXML() } )

					EndIf
					// Erro no processamento, pode reintegrar...
					If RED->RED_STATUS == "6"
						lSuccess  	:= .T.
						lUpdError 	:= .T.
						cREDReceipt	:= RED->RED_RECIBO
					EndIf

					If !Empty( oVOMigr:GetReceipt() ) .And. !Empty(cREDReceipt)
						lSuccess := .F.
						cMessage := STR0031   		//"XML de recibo já informado, registro ignorado."

						// Guarda os XMLs que já foram processados para mover para o diretório de processado com sucesso
						aAdd( aXMLCopy, { cPath, oVOMigr:GetFileXML() } )

					EndIf
				EndIf

				If lSuccess
					// Verifica o status do registro
					MigrStatus(oVOMigr, cREDEnvio, cREDReceipt, lInsert, lUpdError)

					If RecLock("RED", lInsert)
						RED->RED_FILIAL := xFilial( "RED" )
						RED->RED_CNPJ	:= oVOMigr:GetCNPJ()
						If nTipo == 1
							RED->RED_XMLERP := oVOMigr:GetXML()
							RED->RED_EVENTO := oVOMigr:GetEvent()
							RED->RED_INDEVT	:= oVOMigr:GetTypeEvent()
							RED->RED_CHVERP := oVOMigr:GetFileXML()
							RED->RED_FILDES	:= MigrFilGPE( oVOMigr:GetCNPJ() )

							If RED->RED_EVENTO == "S-3000"
								RED->RED_RECEXC	:= oVOMigr:GetDelReceipt()
							EndIf
						ElseIf nTipo == 2
							RED->RED_RECIBO := oVOMigr:GetReceipt()
							RED->RED_DHPROC	:= oVOMigr:GetTimeProc()

							// Verifica se existe o XML Totalizador
							If RED->RED_EVENTO $ "S-1200|S-1210|S-1295|S-1299|S-2299"
								RED->RED_XMLTOT := MigrTot(oXML)
							EndIf
						EndIf
						RED->RED_DTIMP	:= Date()
						RED->RED_HRIMP	:= SubStr(Time(), 1, 5)
						RED->RED_CHVGOV := oVOMigr:GetId()
						RED->RED_STATUS := oVOMigr:GetStatus()
						RED->( MsUnlock() )

						// Guarda os XMLs de sucesso para mover para outro diretório.
						aAdd( aXMLCopy, { cPath, oVOMigr:GetFileXML() } )

					Else
						cMessage := STR0032  				//"Falha ao reservar registro para atualização, tente novamente."
						lSuccess := .F.
					EndIf
				EndIf
			EndIf
        Else
            If oVOMigr:GetCNPJ() == Nil .Or. Empty( oVOMigr:GetCNPJ() )
                aAdd( aNotImport, { oVOMigr:GetFileXML(), STR0033 + FWGrpCompany() + "."} )     //"CNPJ não encontrado para o grupo de empresas: "
            Else
                aAdd( aNotImport, { oVOMigr:GetFileXML(), STR0034} )  //"CNPJ informado no empregador do XML é diferente da raiz de CNPJ do diretório."
            EndIf
		EndIf
	Else
		aAdd( aNotImport, { oVOMigr:GetFileXML(), STR0035} ) //"Arquivo XML inválido."
	EndIf

	If !Empty(cMessage)
		aAdd( aNotImport, { oVOMigr:GetFileXML(), cMessage} )
	EndIf
EndIf

// Limpa da memória as classes de interfaces criadas por tXMLManager
DelClassIntF()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Type
Realiza a a validação do arquivo XML e retorna o mesmo por referência
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrType(oXML, oVOMigr, cCNPJ, cFilProc)

Local 	aChildXML		:= oXml:DOMGetChildArray()
Local 	cTagProt		:= STR0036    	//"retornoenvioloteeventos"
Local 	cTagRetEvt	:= STR0037		//"retornoevento"
Local 	cTagRetProc	:= STR0038		//"retornoprocessamentoloteeventos"
Local 	cNameSpace	:= ""
Local 	cXMLTratado	:= ""
Local 	cStringXML	:= oVOMigr:GetXML()
Local 	nPosNS		:= 0
Local 	nType			:= 0
Local 	nPosEmp		:= 0
Local 	nPosEvt		:= 0
Local 	lHasReceipt	:= .F.
Local 	aParam        := {}
Local 	aNameSpace    := {}
Private aEvtRot	:= TAFRotinas(,,.T.,2)

If Len(aChildXML) > 0
	nPosEvt	:= aScan( aEvtRot, {|x| Lower(x[9]) == Lower(aChildXML[1][1]) } )

	// Se não encontrou no nada no nó pai, verifica se no primeiro nível do filho existe algo
	If nPosEvt <= 0
		If Lower(aChildXML[1][1]) <> cTagRetEvt .And. Lower(aChildXML[1][1]) <> cTagRetProc
			oXML:DOMChildNode()
			aChildXML	:= oXml:DOMGetChildArray()

			If Len(aChildXML)
				nPosEvt	:= aScan( aEvtRot, {|x| Lower(x[9]) == Lower(aChildXML[1][1]) } )
			EndIf
        EndIf
    EndIf

    If nPosEvt > 0
        oVOMigr:SetTagMain(aEvtRot[nPosEvt][9])
		oVOMigr:SetEvent(aEvtRot[nPosEvt][4])
        // Utilizada para registrar o path do XML
		cXMLTratado := StrTran( cStringXML, "'", '"' )

		aNameSpace := oXML:DOMGetNsList()
		nPosNs := aScan(aNameSpace,{|ns|AllTrim(ns[1]) == "xmlns"})
		If nPosNs > 0
			cNameSpace := aNameSpace[nPosNs][2]
		Else
			ConOut(STR0039 + cXMLTratado)    //"NameSpace não declarado. Verifique o Arquivo: "
		EndIf
        oXml:XPathRegisterNS( "ns1", cNameSpace )
    EndIf

    If Len(aChildXML) > 0

        If ExistBlock("GPEMIGRCNPJ")
            aParam := {cCNPJ, oVOMigr:GetXML(), oVOMigr:GetEvent(), oXML}
            cCNPJ := ExecBlock( "GPEMIGRCNPJ", .F., .F., aParam )
        EndIf

        nPosEmp	:= aScan( aSM0, { |x| x[1] == FWGrpCompany() .And. x[18] == cCNPJ } )

		If nPosEmp > 0
			Do Case
				Case nPosEvt > 0
					nType := 1
					oVOMigr:SetId( oXml:XPathGetAtt( STR0040 + oVOMigr:GetTagMain() , STR0041) )    //"/ns1:eSocial/ns1:" //"Id"
					// Seta o tipo do Evento
					MigrTpEvt(oXML, cNameSpace, oVOMigr)

					// Seta o CNPJ do empregador
					MigrCNPJ(oXML, oVOMigr)
					// No evento S-3000 seta o protocolo do evento que está sendo excluído
					If oVOMigr:GetEvent() == STR0042		//"S-3000"
						MigrExc(oXML, oVOMigr)
					EndIf

				Case nPosEvt <= 0 .And. Lower(aChildXML[1][1]) == cTagRetProc .Or. Lower(aChildXML[1][1]) == cTagRetEvt
					nType 	:= 2
				Case nPosEvt <= 0 .And. Lower(aChildXML[1][1]) == cTagProt
					nType := 3
			EndCase

			// --> Verifica se obteve o retorno
			If nType == 2
				oVOMigr:SetId( MigrID( cStringXML, STR0041 ) )  //"Id"
				lHasReceipt := MigrReceipt(oXML, oVOMigr)
				// Se não encontrou o recibo no XML de retorno, devolve zero, para não gravar nada na RED
				If !lHasReceipt
					nType := 0
				EndIf
			EndIf

			oVOMigr:SetCNPJ(cCNPJ)
		EndIf
	Else
		ConOut( STR0043 + oVOMigr:GetFileXML() )   //"Nao foi possível obter os nos filhos do XML. Verifique o arquivo: "
	EndIf
Else
	ConOut( STR0043 + oVOMigr:GetFileXML() )    //"Nao foi possível obter os nos filhos do XML. Verifique o arquivo: "
EndIf

Return( nType )

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrID
Retorna o ID do XML
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrID(cXML,cAttId)

Local nAt  	:= 0
Local cURI 	:= ""
Local nSoma	:= Len( cAttId ) + 2

nAt := At( cAttId + '=', cXml )

If nAt > 0
	cURI:= SubStr( cXml, nAt + nSoma )
	nAt := At( '"', cURI )
	If nAt == 0
		nAt := At( "'", cURI )
	EndIf
	cURI	:= SubStr( cURI, 1, nAt-1 )
EndIf

Return( cUri )

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrReceipt
Retorna o recibo do arquivo xml
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrReceipt(oXML, oVOMigr)

Local lFoundNode	:= .F.
Local cCodRet		:= ""
Local cReceipt      := ""

oXml:XPathRegisterNS( "ns1", "http://www.esocial.gov.br/schema/lote/eventos/envio/retornoProcessamento/v1_3_0" )
oXml:XPathRegisterNS( "ns2", "http://www.esocial.gov.br/schema/evt/retornoEvento/v1_2_0" )

// ContMatic
If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos")

	If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:status")
		cCodRet := oXml:XPathGetNodeValue("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:status/ns1:cdResposta")
	EndIf

	If cCodRet $ "201|202"
		If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos")
			If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos/ns1:evento/ns1:retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo")
				lFoundNode 	:= .T.
				oVOMigr:SetReceipt(oXml:XPathGetNodeValue("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos/ns1:evento/ns1:retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo/ns2:nrRecibo"))
				oVOMigr:SetTimeProc(oXml:XPathGetNodeValue("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos/ns1:evento/ns1:retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:dhProcessamento"))
			EndIf
		EndIf
	EndIf
// TSS - TOTVS Service Sped
ElseIf oXml:XPathHasNode("/evento/retornoEvento")

	If oXml:XPathHasNode("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
		cCodRet := oXml:XPathGetNodeValue("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
	EndIf

	If cCodRet $ "201|202"
		If oXml:XPathHasNode("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo")
			lFoundNode 	:= .T.
			oVOMigr:SetReceipt(oXml:XPathGetNodeValue("/evento/retornoEvento/ns2:eSocial/ns2 :retornoEvento/ns2:recibo/ns2:nrRecibo"))
			oVOMigr:SetTimeProc(oXml:XPathGetNodeValue("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:dhProcessamento"))
		EndIf
	EndIf

// ProSoft
ElseIf oXml:XPathHasNode("/Prosoft/evento/retornoEvento")

	If oXml:XPathHasNode("/Prosoft/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
		cCodRet := oXml:XPathGetNodeValue("/Prosoft/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
	EndIf

	If cCodRet $ "201|202"
		If oXml:XPathHasNode("/Prosoft/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo")
			lFoundNode 	:= .T.
			oVOMigr:SetReceipt(oXml:XPathGetNodeValue("/Prosoft/evento/retornoEvento/ns2:eSocial/ns2 :retornoEvento/ns2:recibo/ns2:nrRecibo"))
			oVOMigr:SetTimeProc(oXml:XPathGetNodeValue("/Prosoft/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:dhProcessamento"))
		EndIf
	EndIf

// Dominos
ElseIf oXml:XPathHasNode("/ns2:eSocial/ns2:retornoEvento")

	If oXml:XPathHasNode("/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
		cCodRet := oXml:XPathGetNodeValue("/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
	EndIf

	If cCodRet $ "201|202"
		If oXml:XPathHasNode("/ns2:eSocial/ns2:retornoEvento/ns2:recibo")
			lFoundNode := .T.
			cReceipt := oXml:XPathGetNodeValue("/ns2:eSocial/ns2:retornoEvento/ns2:recibo/ns2:nrRecibo")
			oVOMigr:SetReceipt(cReceipt)
			oVOMigr:SetTimeProc(oXml:XPathGetNodeValue("/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:dhProcessamento"))
		EndIf
	EndIf

// Sênior
ElseIf oXml:XPathHasNode("/eSocial/retornoEvento")

	If oXml:XPathHasNode("/eSocial/retornoEvento/processamento/cdResposta")
		cCodRet := oXml:XPathGetNodeValue("/eSocial/retornoEvento/processamento/cdResposta")
	EndIf

	If cCodRet $ "201|202"
		If oXml:XPathHasNode("/eSocial/retornoEvento/recibo")
			lFoundNode := .T.
			oVOMigr:SetReceipt(oXml:XPathGetNodeValue("/eSocial/retornoEvento/recibo"))
			oVOMigr:SetTimeProc(oXml:XPathGetNodeValue("/eSocial/retornoEvento/processamento/dhProcessamento"))
		EndIf
	EndIf

EndIf

Return(lFoundNode)

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrStatus
Retorna o status de acordo com regras

Status Possíveis:
    1-Somente Envio
    2-Somente Término
    3-Completo sem Processar
    4-Envio Processado
    5-Completo Processado
**************************************************************************************
Regra para lInsert == false

(Obrigatoriamente o registro deve possuir ou "Recibo" ou "Envio" )
1 - Verifica se foi informado o XML de "Envio" de um "Recibo" informado anteriormente
2 - Verifica se foi informado o XML de "Recibo" de um "Envio" informado anteriormente
**************************************************************************************
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Function MigrStatus(oVOMigr, cREDEnvio, cREDRecibo, lInsert, lUpdError)

Local cStatusRet := ""
Local cXMLESoc	 := oVOMigr:GetXML()
Local cRecibo	 := oVOMigr:GetReceipt()

Default lUpdError := .F.

If !lUpdError

	If lInsert // --> Persiste as regras de inclusão
		If !Empty(cXMLESoc) .And. Empty(cRecibo)
			cStatusRet := "1"
		ElseIf ( Empty(cXMLESoc) .Or. STR0037 $ cXMLESoc) .And. !Empty(cRecibo)  //"retornoEvento"
			cStatusRet := "2"
		ElseIf !Empty(cXMLESoc) .And. !Empty(cRecibo)
			cStatusRet := "3"
		EndIf

	Else // --> Persiste as regras de alteração
		If 	Empty(cREDEnvio) .And. !Empty(cXMLESoc) .And. !Empty(cREDRecibo) .Or.;
			Empty(cREDRecibo) .And. !Empty(cRecibo) .And. !Empty(cREDEnvio) .Or.;
			Empty(cXMLESoc) .And. !Empty(cRecibo) .And. !Empty(cREDEnvio) .And. !Empty(cREDRecibo)
			cStatusRet := "3"
		EndIf
	EndIf

Else
	If Empty(cREDRecibo)
		cStatusRet := "1"
	Else
		cStatusRet := "3"
	EndIf
EndIf

oVOMigr:SetStatus(cStatusRet)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrReader
Leitura do arquivo XML
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrReader(cFileXML)

Local cBuffer	:= ""
Local aFileXML	:= GPEReadFl(cFileXML)
Local nX		:= 0

If aFileXML[2]
	cBuffer := aFileXML[3]
EndIf

// Tratamento para ajustar os namespaces não tratados, devido as alterações do governo
For nX := 1 To 9
	cBuffer := StrTran(cBuffer, STR0044 + cValToChar(nX) , STR0045 )  //"retornoEvento/v1_2_" //"retornoEvento/v1_2_0"
Next nX

Return(cBuffer)

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrTot
Verifica se existe o XML Totalizador e seta o conteúdo no atributo
@author  Silvia Taguti
@since   23/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrTot(oXML)

Local cString	:= ""

If oXML:XPathDelNode( "/evento/retornoEvento" )
	cString := oXML:Save2String()
EndIf

cString	:= StrTran(cString, '<?xml version="1.0">', '' )
cString	:= StrTran(cString, '<?xml version="1.0"?>', '' )

Return( cString )

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrTpEVT
Seta o tipo do Evento
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Function MigrTpEVT(oXML, cNameSpace, oVOMigr)

Local cXMLEvento    := oVOMigr:GetXML()

// Verifica o tipo de envio ao governo
If oXml:XPathHasNode("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEvento/ns1:indRetif")
    oVOMigr:SetTypeEvent(oXml:XPathGetNodeValue("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEvento/ns1:indRetif"))
EndIf
// Se está vazio é sinal que é evento de tabela ou totalizador que será analisado abaixo
If Empty( oVOMigr:GetTypeEvent() )
    If At( "<inclusao>", cXMLEvento ) > 0
        oVOMigr:SetTypeEvent("3")
    ElseIf At( "<alteracao>", cXMLEvento ) > 0
        oVOMigr:SetTypeEvent("4")
    ElseIf At( "<exclusao>", cXMLEvento ) > 0
        oVOMigr:SetTypeEvent("5")
    EndIf
EndIf

// Verifica se é evento totalizador ou evento de exclusão
If Empty( oVOMigr:GetTypeEvent() ) .And. oVOMigr:GetEvent() $ "S-1295|S-1299|S-1298|S-2190|S-3000|S-5001|S-5002|S-5011|S-5012"
    oVOMigr:SetTypeEvent("1")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrExc
Seta o recibo de exclusão, no qual o S-3000 está excluindo.
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrExc(oXML, oVOMigr)

Local cRet := ""

oXml:XPathRegisterNS( "ns1", "http://www.esocial.gov.br/schema/evt/evtExclusao/v02_04_02" )

If oXml:XPathHasNode("/ns1:eSocial/ns1:evtExclusao/ns1:infoExclusao")
	oVOMigr:SetDelReceipt( oXml:XPathGetNodeValue("/ns1:eSocial/ns1:evtExclusao/ns1:infoExclusao/ns1:nrRecEvt") )
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrInExec
Retorna se o migrador está em execução de acordo com o semáforo
@author  Silvia Taguti
@since   29/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrInExec()
Return( lInExec )

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrSlice
Transforma o lote de XMLs em arquivos XMLs unitários
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrSlice(cXML, cPath, cFilProc, cCNPJ)

Local xTotaliz	:= Nil
Local xEvt		:= Nil
Local nPosIni	:= 0
Local nPosFim	:= 0
Local nX		:= 0
Local nY		:= 0
Local cWarning	:= ""
Local cError	:= ""

Private oXMLSlice := Nil

// Remove as informações de cabeçalho do lote e as tags de fechamento.

cXML := MigrDelNS(cXML)

nPosIni	:= At( "<eSocial", cXML )
cXML 	:= SubStr(cXML, nPosIni )
nPosFim := rAt( "</eSocial>", cXML )
cXml 	:= SubStr(cXML, 1, nPosFim + 9 )

//Parser do XML para geração do outros arquivos
oXMLSlice 	:= XMLParser(cXML, "", @cError, @cWarning)

If Empty(cError) .And. Empty(cWarning)

	//Ajuste para o segundo xml
	If Type("oXMLSlice:_eSocial:_RetornoProcessamentoLoteEventos") != "U"

		If XmlChildEx( oXMLSlice:_eSocial:_RetornoProcessamentoLoteEventos, "_RETORNOEVENTOS" ) <> Nil

			xEvt := oXMLSlice:_eSocial:_RetornoProcessamentoLoteEventos:_RetornoEventos:_Evento

			If ValType(xEvt) == "A"
				For nX := 1 To Len(xEvt)
					// Criação do "subxml" do retorno do recibo
					MigrCreate(xEvt[nX], cPath, cFilProc, cCNPJ, "rec", "")

					// Criação do "subxmls" dos totalizadores
					xTotaliz := XMLChildEx(xEvt[nX], "_TOT")

					If xTotaliz <> Nil
						If ValType(xTotaliz) == "A"
							For nY := 1 To Len(xTotaliz)
								MigrCreate(xTotaliz[nY], cPath, cFilProc, cCNPJ, "tot", xTotaliz[nY]:_TIPO:TEXT)
							Next nY
						ElseIf ValType(xTotaliz) == "O"
							MigrCreate(xTotaliz, cPath, cFilProc, cCNPJ, "tot", xTotaliz:_TIPO:TEXT)
						EndIf
					EndIf
				Next nX

			ElseIf ValType(xEvt) == "O"
				MigrCreate(xEvt, cPath, cFilProc, cCNPJ, "rec", "")
			EndIf
		Else
			ConOut( STR0046 ) //"Nó de Retorno não encontrado."
		EndIf

	ElseIf Type("oXMLSlice:_eSocial:_envioLoteEventos:_eventos") != "U"

		xEvt := oXMLSlice:_eSocial:_envioLoteEventos:_eventos:_evento
		If ValType(xEvt) == "A"
			For nX := 1 To Len(xEvt)
				// Criação do "subxml" do retorno do recibo
				MigrCreate(xEvt[nX], cPath, cFilProc, cCNPJ, "rec", "")

				// Criação do "subxmls" dos totalizadores
				xTotaliz := XMLChildEx(xEvt[nX], "_TOT")

				If xTotaliz <> Nil
					If ValType(xTotaliz) == "A"
						For nY := 1 To Len(xTotaliz)
							MigrCreate(xTotaliz[nY], cPath, cFilProc, cCNPJ, "tot", xTotaliz[nY]:_TIPO:TEXT)
						Next nY
					ElseIf ValType(xTotaliz) == "O"
						MigrCreate(xTotaliz, cPath, cFilProc, cCNPJ, "tot", xTotaliz:_TIPO:TEXT)
					EndIf
				EndIf
			Next nX

		ElseIf ValType(xEvt) == "O"
			MigrCreate(xEvt, cPath, cFilProc, cCNPJ, "rec", "")
		EndIf
	Else
		ConOut( STR0046 )   //"Nó de Retorno não encontrado."
	EndIf
Else
	ConOut( STR0047 + cError )  //"Error: "
	ConOut( STR0048 + cWarning )  //"Warning: "
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrCreate
Cria os arquivos XMLs
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrCreate(oEvento, cPath, cFilProc, cCNPJ, cPrefixo, cTotaliz)

Local cStrSlice  := XMLSaveStr(oEvento)
Local cDirNewXml := cPath + "slice_" + DTOS(Date()) + "\"
Local cIdXML	 := ""
Local cNomeXML	 := ""
Local nQtdFile	 := 2
Local nPosFim	 := 0
Local nPosIni	 := 0

If !ExistDir(cDirNewXml)
	MakeDir(cDirNewXml)
EndIf

If cPrefixo <> 'tot'
	cIdXML	:= oEvento:_ID:TEXT
Else
	// Verifica qual o tipo do totalizador
	Do Case
		Case cTotaliz == "S5001"
			cIdXML	:= oEvento:_ESOCIAL:_EVTBASESTRAB:_ID:TEXT
		Case cTotaliz == "S5002"
			cIdXML	:= oEvento:_ESOCIAL:_EVTIRRFBENEF:_ID:TEXT
		Case cTotaliz == "S5011"
			cIdXML	:= oEvento:_ESOCIAL:_EVTCS:_ID:TEXT
		Case cTotaliz == "S5012"
			cIdXML	:= oEvento:_ESOCIAL:_EVTIRRF:_ID:TEXT
	EndCase
EndIf

cNomeXML := cIdXML + "_" + cPrefixo + "_" + cTotaliz + "_R1.xml"

// Remove as informações de cabeçalho do lote e as tags de fechamento.
nPosIni		:= At( "<eSocial", cStrSlice )
cStrSlice 	:= SubStr(cStrSlice, nPosIni )
nPosFim 	:= At( "</eSocial>", cStrSlice )
cStrSlice 	:= SubStr(cStrSlice, 1, nPosFim + 9 )
cStrSlice	:= FwNoAccent(cStrSlice)

//Se existir XML com o mesmo nome, não sobrepõe ... "Acumula" ...
While File(cDirNewXml + cNomeXML)
	cNomeXML := cIdXML + "_" + cPrefixo + "_" + cTotaliz + "_R" + cValToChar(nQtdFile) + ".xml"
	nQtdFile++
EndDo

If MemoWrite(cDirNewXml + cNomeXML , cStrSlice)
	aAdd( aSlice, {	cPath,;
					cDirNewXml,;
					cNomeXML,;
					cFilProc,;
					cCNPJ,;
					cStrSlice})
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrMove
Move o arquivo passado por parâmetro para outro diretório
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrMove(aFileXML, nCopy)

Local cPath		:= aFileXML[1]
Local cNomeFile := aFileXML[2]
Local cNewDir	:= cPath + "sliced_" + DTOS(Date()) + "\"

If nCopy == 1
	cNewDir	:= cPath + "sliced_" + DTOS(Date()) + "\"
ElseIf nCopy == 2
	cNewDir	:= cPath + "success_" + DTOS(Date()) + "\"
EndIf

If !ExistDir(cNewDir)
	MakeDir(cNewDir)
EndIf

__CopyFile(cPath + cNomeFile, cNewDir + cNomeFile)

FErase(cPath + cNomeFile)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrPend
Processa os arquivos pendentes
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrPend(oFWRun)

Local nX 		:= 0
Local nQtdTot	:= Len(aSlice)
Local oVOMigr	:= GPEVOMigr():New()

For nX := 1 To nQtdTot

	SetIncPerc( oFWRun, "3", nQtdTot, nX )

	oVOMigr:SetFileXML( aSlice[nX][3] )

	MigrGrv( oVOMigr, aSlice[nX][2], aSlice[nX][4], aSlice[nX][5] )

	oVOMigr:Clear()
Next nX

Return

/*/{Protheus.doc} VldNumThrd
Validação do número de threads
@author Silvia Taguti
@since   28/12/2020
@version 1
/*/
Static Function VldNumThrd( cNumThrd )

Local lRet := .T.

If !Empty(cNumThrd)
	If Val(cNumThrd) < 1 .Or. Val(cNumThrd) > 10
		lRet := .F.
		MsgInfo(STR0049, STR0050)  //"O número de threads para este processo de ser um valor entre 1 e 10.", "Aviso"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrCopy
Encapsula a copia de arquivos em lote
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrCopy(aXMLCopy)

Local nX := 0

For nX := 1 To Len(aXMLCopy)
	MigrMove(aXMLCopy[nX], 2)
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrFilGPE
Retorna a Filial do GPE conforme CNPJ
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Function MigrFilGPE(cCNPJ)

Local aArea 	:= GetArea()
Local nPosEmp	:= 0
Local cFilSM0	:= ""

nPosEmp := aScan( aSM0, { |x| AllTrim(x[18]) == AllTrim(cCNPJ) } )

If nPosEmp > 0
	cFilSM0 := aSM0[nPosEmp][1] + aSM0[nPosEmp][2]
EndIf

RestArea(aArea)

Return(cFilSM0)

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrDelNS
Remove NS desnecessários
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrDelNS(cXML)

Local nX := 0

For nX := 1 To 10
	cXML := StrTran(cXML, "ns" + cValToChar(nX) + ":", "" )
Next nX

cXML := StrTran( cXML, 'xmlns:ds="http://www.w3.org/2000/09/xmldsig#"', '')
cXML := StrTran( cXML, 'xmlns:xs="http://www.w3.org/2001/XMLSchema"', '')

Return(cXML)

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrCNPJ
Seta o CNPJ do arquivo XML
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrCNPJ(oXML, oVOMigr)

Local cXMLEvento    := oVOMigr:GetXML()

// Verifica o tipo de envio ao governo
If oXml:XPathHasNode("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEmpregador/ns1:nrInsc")
    oVOMigr:SetCNPJXml( oXml:XPathGetNodeValue("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEmpregador/ns1:nrInsc") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrRel
Realiza a impressão do relatório de importação de arquivos
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrRel(aNotImport)

GPERMig02(aNotImport)    //Analisar

Return

Static Function fText(cInfo)

Local cRet 		:= ""

If cInfo == "BEMVINDO"
	cRet := '<font size="6" color="#0c9abe"><b>'+STR0002+'</b></font>'//"Bem-vindo..."
	cRet += '<br/>'
ElseIf cInfo == "ASSIST"
	cRet += '<font size="5" color="#888">'+STR0003	//"Este é um assistente de importação dos XMLs transmitidos através de "
	cRet += '<br/>'
	cRet += STR0004									//"sistemas terceiros para o Middleware"
	cRet += '<br/>'
	cRet += '<br/>'
	cRet += STR0005+'</font>'//'Certifique-se que o ambiente está com acesso exclusivo.'
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fCSS
Fonte genérico contendo os Cascade Style (CSS) utilizados nas interfaces
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fCSS(cIDCSS)

Local cCSS := ""

Do Case
	Case cIDCSS == "TEXTTITLE"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #000000;"
		cCSS += "}"
	Case cIDCSS == "BTPROC"
		cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: #FFFFFF;"
		cCSS += "padding: 2px 5px;"
		cCSS += "text-align: center; "
		cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 16px; "
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS += "QPushButton:hover { "
		cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
		cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;"
		cCSS +=	"}"
	Case cIDCSS == "LINESEPARADOR"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #BBBBBB;"
		cCSS += "}"
EndCase

Return(cCSS)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRMig02
Relatório com os status de importação do Migrador
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Function GPERMig02(aNotImport)

Default aNotImport := {}

If MsgYesNo( STR0051 + Chr(10) + Chr(13) + STR0052, STR0053 ) //"Foram encontrados inconsistências na importação do arquivo."//"Deseja visualizar?"//"TOTVS"
    MigrPrint(aNotImport)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RMigr02Print
Efetua a impressão do relatório
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrPrint(aNotImport)

Local oExcel 	:= FWMSExcel():New()
Local oExcelApp	:= Nil
Local cAba  	:= STR0054 		//"Registros"
Local cTabela	:= STR0054 		//"Registros"
Local cArquivo	:= "import_" + DTOS(Date()) + "_" + StrTran(Time(), ":", "") + ".xls"
Local cPath		:= cGetFile( STR0010 + "|*.*", STR0055, 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )  //"Diretório" //"Procurar"
Local cDefPath	:= GetSrvProfString( STR0056, STR0057 ) //"StartPath", "\system\"
Local nX		:= 0

oExcel:AddWorkSheet(cAba)
oExcel:AddTable(cAba, cTabela)

oExcel:AddColumn(cAba, cTabela, STR0058	, 1, 1, .F.)   //"Arquivo"
oExcel:AddColumn(cAba, cTabela, STR0059	, 1, 1, .F.)   //"Mensagem"

For nX := 1 To Len(aNotImport)

    oExcel:AddRow(cAba,;
				  cTabela,;
                  { aNotImport[nX][1],;
				  	aNotImport[nX][2];
				  })
Next nX

If !Empty(oExcel:aWorkSheet)

    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)

    CpyS2T(cDefPath+cArquivo, cPath)

    FErase(cDefPath+cArquivo)

    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
    oExcelApp:SetVisible(.T.)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEVOMigr
Classe que reprenta o VO (Value Object) utilizado pelo Migrador
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Class GPEVOMigr From LongClassName

    Data cReceipt
    Data cXMLErp
    Data cEvent
    Data cFileXML
    Data cIdXML
    Data cStatus
    Data cTypeEvent
    Data cTimeProc
    Data cTagMain
    Data cIndEvent
    Data cCNPJ
    Data cBranch
    Data cDelReceipt
    Data cCNPJXML

    Method New() Constructor
    // Setters
    Method SetReceipt()
    Method SetXML()
    Method SetEvent()
    Method SetFileXML()
    Method SetID()
    Method SetStatus()
    Method SetTypeEvent()
    Method SetTimeProc()
    Method SetTagMain()
    Method SetIndEvent()
    Method SetCNPJ()
    Method SetAliasEvent()
    Method SetBranch()
    Method SetDelReceipt()
    Method SetCNPJXml()
    // Getters
    Method GetReceipt()
    Method GetXML()
    Method GetEvent()
    Method GetFileXML()
    Method GetID()
    Method GetStatus()
    Method GetTypeEvent()
    Method GetTimeProc()
    Method GetTagMain()
    Method GetCNPJ()
    Method GetAliasEvent()
    Method GetBranch()
    Method GetDelReceipt()
    Method GetCNPJXml()
    Method Clear()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Method New() Class GPEVOMigr
Return( self )

//Setters
Method SetReceipt(cReceipt)         Class GPEVOMigr; self:cReceipt      := cReceipt;        Return
Method SetXML(cXMLErp)              Class GPEVOMigr; self:cXMLErp       := cXMLErp;         Return
Method SetEvent(cEvent)             Class GPEVOMigr; self:cEvent        := cEvent;          Return
Method SetFileXML(cFileXML)         Class GPEVOMigr; self:cFileXML      := cFileXML;        Return
Method SetID(cIdXML)                Class GPEVOMigr; self:cIdXML        := cIdXML;          Return
Method SetStatus(cStatus)           Class GPEVOMigr; self:cStatus       := cStatus;         Return
Method SetTypeEvent(cTypeEvent)     Class GPEVOMigr; self:cTypeEvent    := cTypeEvent;      Return
Method SetTimeProc(cTimeProc)       Class GPEVOMigr; self:cTimeProc     := cTimeProc;       Return
Method SetTagMain(cTagMain)         Class GPEVOMigr; self:cTagMain      := cTagMain;        Return
Method SetCNPJ(cCNPJ)               Class GPEVOMigr; self:cCNPJ         := cCNPJ;           Return
Method SetBranch(cBranch)           Class GPEVOMigr; self:cBranch       := cBranch;         Return
Method SetDelReceipt(cDelReceipt)   Class GPEVOMigr; self:cDelReceipt   := cDelReceipt;     Return
Method SetCNPJXml(cCNPJXml)         Class GPEVOMigr; self:cCNPJXml      := cCnpjXML;        Return

//Getters
Method GetReceipt()         Class GPEVOMigr;    Return(self:cReceipt)
Method GetXML()             Class GPEVOMigr;    Return(self:cXMLErp)
Method GetEvent()           Class GPEVOMigr;    Return(self:cEvent)
Method GetFileXML()         Class GPEVOMigr;    Return(self:cFileXML)
Method GetID()              Class GPEVOMigr;    Return(self:cIdXML)
Method GetStatus()          Class GPEVOMigr;    Return(self:cStatus)
Method GetTypeEvent()       Class GPEVOMigr;    Return(self:cTypeEvent)
Method GetTimeProc()        Class GPEVOMigr;    Return(self:cTimeProc)
Method GetTagMain()         Class GPEVOMigr;    Return(self:cTagMain)
Method GetCNPJ()            Class GPEVOMigr;    Return(self:cCNPJ)
Method GetBranch()          Class GPEVOMigr;    Return(self:cBranch)
Method GetDelReceipt()      Class GPEVOMigr;    Return(self:cDelReceipt)
Method GetCNPJXml()         Class GPEVOMigr;    Return(self:cCnpjXML)

//-------------------------------------------------------------------
/*/{Protheus.doc} Method - Clear
Limpa os atributos da Classe
@author  Silvia Taguti
@since   28/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Method Clear() Class GPEVOMigr

self:SetReceipt("")
self:SetXML("")
self:SetEvent("")
self:SetFileXML("")
self:SetID("")
self:SetStatus("")
self:SetTypeEvent("")
self:SetTimeProc("")
self:SetTagMain("")
self:SetCNPJ("")
self:SetBranch("")
self:SetDelReceipt("")
self:SetCNPJXml("")

Return

/*/{Protheus.doc} TAFReadFl
Le o arquivo e retorna seu conteudo, tratando o tamanho maximo da string do Protheus
@return array, [1] Tamanho do arquivo - [2] Status da leitura .T./.F. - [3] Conteudo do arquivo
@author  Silvia Taguti
@since   28/12/2020
@version 1.0
/*/
Static Function GPEReadFl( cFilePath )

Local nFileLen := 0
Local lStRead  := .T.
Local cContent := ""
Local cBuffer  := ""
Local nHdlFile := -1 //Handle para leitura do arquivo
Local nPosFile := 0
Local nByteLeft:= 0
Local nBlock   := 512
Local nMemoMega := Val( GetSrvProfString( "TOPMEMOMEGA", "" ))
Local nMaxStr   := If(nMemoMega > 0, nMemoMega * 1048575 , 1048575)  //tamanho maximo string do protheus, conforme TOPMEMOMEGA

If ( nHdlFile := FOpen( cFilePath,2 ) ) >= 0

	// Posiciona no fim do arquivo, retornando o tamanho do mesmo
	nFileLen := FSeek(nHdlFile, 0, FS_END)

	//Verifica o tamanho do arquivo
	If nFileLen > nMaxStr

		lStRead := .F.
	Else
		// Posiciona no inicio do arquivo
		nPosFile  := FSeek(nHdlFile, 0)
		nByteLeft := nFileLen

		//Percorre o arquivo ate o final
		While nByteLeft > 0
			nPosFile := FRead( nHdlFile, @cBuffer, nBlock )
			cContent += cBuffer
			nByteLeft -= nBlock
		EndDo
	EndIf
	// Fecha arquivo
	FClose(nHdlFile)
Else
	lStRead := .F.
EndIf

cContent := GPEXMLDecode(cContent)

Return { nFileLen, lStRead, cContent }

//----------------------------------------------------------------------------
/*/{Protheus.doc} GPEXMLDecode
Função criada para realizar o decode UTF8 de um XML
@param cXml - xml com codificação
@return cXmlEncoding - xml sem codificação

@author  Silvia Taguti
@since   28/12/2020
@version 1.0
/*/
//---------------------------------------------------------------------------
function GPEXMLDecode(cXml)

	local cStrEncoding := ""
	local cXmlEncoding := ""

	if "<?" $ substr(LTrim(cXml),1,15)

		cStrEncoding := upper(Substr(cXml,1,at("?>",cXml)))

		cXml := RemoveUTF8(cXml)

		if "UTF-8" $ cStrEncoding .or. "8859-1" $ cStrEncoding
			cXmlEncoding := decodeUTF8(cXml)
		endif
	endif

	if empty(cXmlEncoding)
		cXmlEncoding := encodeUTF8(cXml)

		//Se retornar vazio o XML já está em UTF8
		If empty(cXmlEncoding)

			cXmlEncoding := decodeUTF8(cXml)
			//Se retornar vazio o XML está em um formato não esperado.
			if empty(cXmlEncoding)
				cXmlEncoding := cXml
				ConOut(STR0060)  //"Formato de XML não esperado"
				ConOut(cXml)
			endIF
		endIf
	endif

return cXmlEncoding

//----------------------------------------------------------------------------
/*/{Protheus.doc} RemoveUTF8
Retira a Identificação de codificação do inicio do XML
@param cXml - Xml do Evento
@return cXmlRet - Xml Sem a Tag de Encode.
@author Evandro dos Santos O. Teixeira
@since 11/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function RemoveUTF8(cXml)
	Local nStart
	Local cXmlRet

	nStart  := 0
	cXmlRet := ""

	nStart := AT(">",cXml)
	cXmlRet := Substr(cXml,nStart+1,Len(cXml)-(nStart))
	cXmlRet := StrTran(cXmlRet,Chr(13),"")
	cXmlRet := StrTran(cXmlRet,Chr(10),"")

Return cXmlRet
