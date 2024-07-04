#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH" 

Static aEvtRot	:= TAFRotinas(,,.T.,2)
Static aSM0		:= FWLoadSM0()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMigr001
Importa��o de arquivos hist�ricos do eSocial 
para migra��o de software terceiros para o TAF
@author  Victor A. Barbosa
@since   04/10/2018
@version  1
/*/
//-------------------------------------------------------------------
Function TAFMigr001(lProcess)  


Private lInExec		:= .F. // Private por conta do controle de "click" e enable/disable dos objetos visuais.
Private aSlice		:= {}  // Private para guardar os registros que foram fatiados.
Private aSliced		:= {}  // Private para guardar a nomeclatura dos XMLs que foram "fatiados" e mover para outro diret�rio posteriormente.
Private aXMLCopy	:= {}  // Private para guardar os XMLs que tiveram �xito na importa��o e posteriormente mover para outra pasta.
Private aNotImport	:= {}

Default lProcess		:= .F.


If GetNewPar("MV_TAFAMBE") == "1" 
	If !FWIsInCallStack( "TafMarkBrw" ) 
		// Monta o Wizard
		Migr01Wizd(lProcess)
	EndIf
Else
	MsgAlert("Para utiliza��o do migrador, a empresa dever� estar operando em ambiente de produ��o.")
EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Wizd
Monta o Wizard com os passos
@author  Victor A. Barbosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Wizd(lProcess)

Local oNewPag   := Nil
Local oStepWiz  := Nil
Local lRadio	:= .F.

Default lProcess := .F.


oStepWiz := FWWizardControl():New()
oStepWiz:ActiveUISteps()

oNewPag := oStepWiz:AddStep("1")
oNewPag:SetStepDescription("Observa��es")
oNewPag:SetConstruction( { |Panel1| Migr01Pag1(Panel1) } )
oNewPag:SetNextAction( {|| .T. } )
oNewPag:SetCancelAction( {|| .T.} )

oNewPag := oStepWiz:AddStep("2")
oNewPag:SetStepDescription("Par�metros e Processamento")
oNewPag:SetConstruction( { |Panel2| Migr01Pag2(Panel2, lRadio, lProcess ) } )
oNewPag:SetNextAction( {|| !MigrInExec() } )
oNewPag:SetCancelAction( {|| .T. })

oNewPag:SetPrevWhen({|| !MigrInExec() })
oNewPag:SetCancelWhen({|| !MigrInExec() }) 


oStepWiz:Activate()



Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Pag1
Painel com os descritivos da solu��o
@author  Victor A. Babrosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Pag1(oPanel)

TSay():New(25, 20, {||  TAFMigrText("BEMVINDO")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
TSay():New(45, 20, {||  TAFMigrText("ASSIST")        }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
TSay():New(95, 20, {||  TAFMigrText("TITETAPAS")     }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
TSay():New(120, 25, {|| TAFMigrText("TEXTETAPAS")    }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Pag2
Painel com os par�metros
@author  Victor A. Babrosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Function Migr01Pag2(oPanel, lRadio, lProcess)

Local cDirImp   	:= Space(150)
Local aSubDiret		:= {}
Local aItems    	:= {"Somente Importar", "Somente Processar", "Importar e Processar", "Processar Rejeitados"}
Local oButtonFile   := Nil
Local oButtonProc	:= Nil
Local oSayFile  	:= Nil
Local oSayExec		:= Nil
Local oRadio		:= Nil
Local oGetFile		:= Nil
Local oGetThrd		:= Nil
Local nRadio		:= 1
Local cNumThrd		:= Space(02)
Local oTButtonSel	:= Nil

Default lRadio 		:= .F.
Default lProcess	:= .F.


oSayExec := TSay():New(20, 10, { || "Tipo de Execu��o" }, oPanel,,,,,, .T.,,, 200,20)

oRadio := TRadMenu():New(30, 10, aItems,, oPanel,,,,,,,, 100, 12,,,, .T.)
oRadio:bSetGet := { |u| Iif( PCount() == 0, nRadio, nRadio := u ) }  

oSayExec := TSay():New(72, 10, { || "N� de Threads: " }, oPanel,,,,,, .T.,,, 60,60)

oGetThrd := TGet():New(70, 55, { | u | If( PCount() == 0, cNumThrd, cNumThrd := u ) }, oPanel, 10, 10, "", { || VldNumThrd( @cNumThrd ) } , 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cNumThrd,,,,)
oGetThrd:Disable()

oSayFile := TSay():New(80, 10, { || "Diret�rio" }, oPanel,,,,,, .T.,,, 200,20)

oGetFile := TGet():New(90, 10, { || cDirImp }, oPanel, 160, 009, "",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cDirImp,,,,)
oButtonFile  := TButton():New( 90, 172, OemToAnsi("..."), oPanel, {|| aSubDiret := Migr01File(oButtonProc, @cDirImp) }, 25, 10,,, .F., .T., .F.,, .F.,,, .F.)


oButtonProc  := TButton():New( 120, 105, OemToAnsi("Processar Eventos"), oPanel, {|| Migr01Barra(oPanel, aSubDiret, oButtonFile, oButtonProc, oRadio, oGetFile, oGetThrd, nRadio, Val(cNumThrd), lProcess, lRadio ) },; 
																							80, 15,,, .F., .T., .F.,, .F.,,, .F. )

oTButtonSel  := TButton():New( 150, 105, "Selecionar",oPanel,{|| TafMarkBrw(lProcess)  }, 80, 15,,, .F., .T., .F.,, .F.,,, .F. )

														 
If GetRemoteType() <> 5
	oSayExec:setCSS( TAFMigrCSS("TEXTTITLE") )
	oRadio:setCSS( TAFMigrCSS("RADIO") )
	oSayExec:setCSS( TAFMigrCSS("TEXTTITLE") )
	oButtonFile:setCSS( TAFMigrCSS("BTFILE") )
	oSayFile:setCSS( TAFMigrCSS("TEXTTITLE") )
	oButtonProc:setCSS( TAFMigrCSS("BTPROC") )
	oTButtonSel:setCSS( TAFMigrCSS("BTPROC") )
EndIf

// Seta a��o no radio ap�s defini��o dos componentes visuais
oRadio:bChange := { || Migr01Radio(nRadio, oButtonProc, oButtonFile, oGetFile, oGetThrd ) } 


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01File
Sele��o do diret�rio a ser importado e valida��o da estrutura de pastas
@author  Victor A. Barbosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01File(oButtonProc, cDirPai)

Local cDirImp	:= cGetFile('Arquivo xml|*.xml' , 'Diret�rio', , 'C:\', .F., nOR(GETF_LOCALHARD, GETF_MULTISELECT,GETF_RETDIRECTORY), .T.,.T.)
Local aSubDiret	:= {}
Local aSubOk	:= {}
Local nX		:= 0
Local nPosEmp	:= 0

If ExistDir(cDirImp)
	
	aSubDiret := Directory(cDirImp + "*.*", "D")

	If Len(aSubDiret) > 0
		For nX := 1 To Len(aSubDiret)
			nPosEmp := aScan( aSM0, { |x| AllTrim(x[18]) == AllTrim(aSubDiret[nX][1]) } )
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
			MsgAlert("N�o foi encontrado nenhuma pasta com CNPJs informados no diret�rio.", "Aten��o")
		EndIf
	Else
		cDirImp := ""
		MsgAlert("N�o foram encontrados subdiret�rios.")
	EndIf
Else
	cDirImp := ""
	MsgAlert("Diret�rio inv�lido ou n�o selecionado", "Aten��o")
EndIf

Return(aSubOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Barra
Monta a barra de progresso na parte de baixo do painel 2 da wizard
@author  Victor A. Barbosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Barra(oPanel, aSubDiret, oButtonFile, oButtonProc, oRadio, oGetFile, oGetThrd, nRadio, nNumThrd, lProcess, lRadio)

Local cTextProc	:= ""
Local nMeter	:= 0
Local oMeter	:= Nil
Local oSaySep	:= Nil
Local oSayProc	:= Nil

Local cSql		:= ""
Local cAliasQry := getNextAlias()  
Local nCount	:= ""

Default lProcess := .F.
Default lRadio	 := .F.


lInExec := .T. 


cSql := " SELECT COUNT(*) REGISTROS_V2A FROM " + RetSQLName("V2A")
cSql += " WHERE V2A_OK <> '' "

TCQuery cSql New Alias &cAliasQry  
nCount := (cAliasQry)->(REGISTROS_V2A) 

If nCount > 0
	lProcess := .T.
EndIf


If nRadio == 4 //--> CheckBox "Processar Rejeitados"
	lRadio := .T.
EndIf

If lRadio .And. !lProcess
	MsgStop( 'Selecione algum evento para processar.', 'Advert�ncia' )
Else


	// Desabilita os bot�es
	oButtonFile:Disable()
	oButtonProc:Disable()
	oRadio:Disable()
	oGetFile:Disable()
	oGetThrd:Disable()

	oSaySep := TSay():New(140, 02, { || Replicate("_", 150) }, oPanel,,,,,, .T.,,, 300,20)
	oSaySep:setCSS( TAFMigrCSS("LINESEPARADOR") )

	cTextProc := "Iniciando Processamento..."

	oSayProc := TSay():New(170, 100, { || cTextProc }, oPanel,,,,,, .T.,,, 300,20)
	oSayProc:setCSS( TAFMigrCSS("TEXTTITLE") )

	oMeter := TMeter():New( 180, 100, { |u| Iif( Pcount() > 0, nMeter := u, nMeter) }, 100, oPanel, 100, 16,, .T.)
	oMeter:setCSS("METER")
	oMeter:SetTotal(0)
	oMeter:Set(0)


	// Chama as fun��es de processamento
	Migr01Proc(aSubDiret, oSayProc, oMeter, nRadio, nNumThrd, lProcess )
EndIf


If Select( cAliasQry ) > 0
	( cAliasQry)->( DbCloseArea() )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Proc
Encapsula as fun��es de processamento
@author  Victor A. Barbosa
@since   05/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Proc(aSubDiret, oSay, oMeter, nRadio, nNumThrd, lProcess)

Local aFilesXML := {}
Local nExec		:= 0
Local nQtdTot	:= 0
Local nX		:= 0
Local lRadio	:= .F. //--> Acrescentado lRadio para controlar qual RadioButton foi checado.

Default lProcess := .F.

oSay:CtrlRefresh()

oSay:setText("Verificando diret�rio")
oSay:CtrlRefresh()

If nRadio == 1 .Or. nRadio == 3  

	For nX := 1 To Len(aSubDiret)  
		nExec := 0
		While Len( aFilesXML := Migr01Dir(aSubDiret[nX][1], nExec) ) > 0

			// Processa o lote de XML lido
			Migr01Lote(aFilesXML, oSay, oMeter, aSubDiret[nX][1], aSubDiret[nX][3], @nQtdTot, aSubDiret[nX][4])

			aFilesXML := {}
			aSize(aFilesXML, 0)
			nExec++
		EndDo

	Next nX

	// Se houve registros "fatiados", move o XML "fatiado" para outro diret�rio e processa os XMLs gerados
	If Len(aSliced) > 0
		
		If Len(aSliced) > 0
			FWMsgRun(, {|| Migr01Copy(aSliced) }, "Aguarde...", "Movendo XMLs consolidados para outro diret�rio." )
		EndIf

		//Processa os XMLs que foram gerados
		FWMsgRun(, {|oFWRun| Migr01Pend(oFWRun) }, "Aguarde...", "Verificando XMLs gerados atrav�s do Lote." )

	EndIf

	If Len(aXMLCopy) > 0
		FWMsgRun(, {|| Migr01Copy(aXMLCopy) }, "Aguarde...", "Movendo XMLs processados para outro diret�rio." )
	EndIf

	If Len(aNotImport) > 0
		FWMsgRun(, {|| Migr01Rel(aNotImport) }, "Aguarde...", "Gerando Inconsist�ncias." )
	EndIf
	
EndIf

If nRadio == 2 .Or. nRadio == 3  
	Migr01ToTAF(oSay, oMeter, nNumThrd, lRadio, lProcess)  
EndIf

If nRadio == 4 //--> CheckBox "Processar Rejeitados"
	lRadio := .T.
	Migr01ToTAF(oSay, oMeter, nNumThrd, lRadio, lProcess)  
EndIf

MsgAlert("Processamento Finalizado", "Aten��o")
lInExec := .F.

If ValType(oMeter) <> "U"
	oSay:setText("Processamento Finalizado.")
	oMeter:Free()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Dir
Retorna os XML's do diret�rio
Controla pagina��o dos arquivos, pois a fun��o directory retorna 10.000 arquivos por vez
@author  Victor A. Barbosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Dir(cDirImp, nExec)

Local cFlagParameters := "N:" + cValToChar( (nExec * 10000) )
Local aFiles		  := {}

If Right(cDirImp, 1) <> "\"
	cDirImp += "\"
EndIf

aFiles := Directory(cDirImp + "*.xml", cFlagParameters)

Return(aFiles)

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Lote
Processamento do lote de XML
@author  Victor A. Barbosa
@since   05/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Lote(aFilesXML, oSay, oMeter, cDirImp, cFilProc, nQtdTot, cCNPJ)

Local nX 		:= 0
Local oVOMigr	:= TAFVOMigr():New()

oMeter:SetTotal( Len(aFilesXML) )

For nX := 1 To Len(aFilesXML)

	nQtdTot ++
	oMeter:Set(nX)
	oSay:setText("XMLs Processados: " + cValToChar(nQtdTot) )
	ProcessMessages() // For�a atualiza��o no smartclient

	oVOMigr:SetFileXML(aFilesXML[nX][1])

	//Realiza as valiada��es e grava o XML na V2A
	Migr01Grv( oVOMigr, cDirImp, cFilProc, cCNPJ )

	oVOMigr:Clear()

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Grv
Realiza as valida��es e grava o XML na V2A
@author  Victor A. Barbosa
@since   05/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Grv( oVOMigr, cPath, cFilProc, cCNPJ )

Local cMessage		:= ""
Local cV2AEnvio		:= "" // XML "Envio" gravado na V2A
Local cV2AReceipt	:= "" // XML "Recibo" gravado na V2A
Local cXmlBuffer	:= ""
Local cXMLEncode 	:= ""
Local cXMLDecode	:= ""
Local lInsert		:= .T.
Local lSuccess		:= .T.
Local lUpdError		:= .F.
Local oXML 			:= tXMLManager():New()
Local nPosFim		:= 0

V2A->( dbSetOrder(2) )

If Right(cPath, 1) <> "\"
	cPath += "\"
EndIf

cXmlBuffer := Migr01Reader( cPath + oVOMigr:GetFileXML() )

If "<?xml" $ cXmlBuffer
	nPosFim 	:= At(">", cXmlBuffer)
	cXmlBuffer := SubStr( cXmlBuffer, nPosFim + 1)
EndIf

cXMLDecode	:= TAFDecUTF8(cXmlBuffer)	// For�o a decodifica��o do arquivo
cXMLEncode	:= EncodeUTF8(cXMLDecode)	// Codifico o arquivo apenas uma vez

// Se for retorno de XML em lote, transforma o lote em arquivos unit�rios e processa posteriormente.
If "ConsultarLoteEventosResponse" $ cXMLEncode .Or. "retornoProcessamentoLoteEventos" $ cXMLEncode .Or. "envioLoteEventos" $ cXMLEncode
	Migr01Slice(cXMLEncode, cPath, cFilProc, cCNPJ)
	
	aAdd( aSliced, { cPath,; 
			oVOMigr:GetFileXML() } )

Else
	//Grava o XML sem Decode 
	oVOMigr:SetXML( cXMLDecode )
	//Faz o Parse com o XML com Encode, caso contrario capota a aplica��o
	If oXml:Parse( cXMLEncode) // Faz o parser para garantir que � um v�lido

		// Valida o XML e retorna o tipo do mesmo
		nTipo := Migr01Type(oXML, oVOMigr, cCNPJ, cFilProc)

		// Valida se o empregador do XML � o mesmo do diret�rio de pastas
		If ( nTipo == 1 .AND. (AllTrim(oVOMigr:GetCNPJXml()) == SubStr(AllTrim(oVOMigr:GetCNPJ()), 1, 8) .OR. AllTrim(oVOMigr:GetCNPJXml()) == AllTrim(oVOMigr:GetCNPJ()))) .OR. ( nTipo == 2 .AND. Empty( oVOMigr:GetCNPJXml() ) )

			If nTipo == 1 .Or. nTipo == 2
					
				If V2A->( MsSeek( xFilial("V2A") + oVOMigr:GetID() + oVOMigr:GetCNPJ() ) )
					lInsert     := .F.
					cV2AEnvio   := V2A->V2A_XMLERP
					cV2AReceipt := V2A->V2A_RECIBO
				EndIf

				// --> Se for altera��o, verifica se o registro j� foi integrado
				If !lInsert
					If V2A->V2A_STATUS == "5"
						lSuccess := .F.
						cMessage := "Registro j� processado"
					EndIf

					// Valida��o para n�o efetuar a sobreposi��o das informa��es j� existentes na base
					If V2A->V2A_STATUS <> '5' .And. nTipo == 1 .And. !Empty( oVOMigr:GetXML() ) .And. !Empty(cV2AEnvio)
						lSuccess := .F.
						cMessage := "XML de envio j� informado, registro ignorado."

						// Guarda os XMLs que j� foram processados para mover para o diret�rio de processado com sucesso
						aAdd( aXMLCopy, { cPath,; 
										oVOMigr:GetFileXML() } )

					EndIf

					// Erro no processamento, pode reintegrar...
					If V2A->V2A_STATUS == "6"
						
						lSuccess  	:= .T.
						lUpdError 	:= .T.
						cV2AReceipt	:= V2A->V2A_RECIBO

					EndIf

					If !Empty( oVOMigr:GetReceipt() ) .And. !Empty(cV2AReceipt)
						lSuccess := .F.
						cMessage := "XML de recibo j� informado, registro ignorado."

						// Guarda os XMLs que j� foram processados para mover para o diret�rio de processado com sucesso
						aAdd( aXMLCopy, { cPath,; 
										oVOMigr:GetFileXML() } )

					EndIf

				EndIf

				If lSuccess
						
					// Verifica o status do registro
					Migr01Status(oVOMigr, cV2AEnvio, cV2AReceipt, lInsert, lUpdError)
									
					If RecLock("V2A", lInsert)            
						V2A->V2A_FILIAL := xFilial( "V2A" )
						V2A->V2A_CNPJ	:= oVOMigr:GetCNPJ()

						If nTipo == 1
							V2A->V2A_XMLERP := oVOMigr:GetXML()
							V2A->V2A_EVENTO := oVOMigr:GetEvent()
							V2A->V2A_INDEVT	:= oVOMigr:GetTypeEvent()
							V2A->V2A_CHVERP := oVOMigr:GetFileXML()
							V2A->V2A_ALIAS	:= oVOMigr:GetAliasEvent()
							V2A->V2A_FILDES	:= MigrFilTAF( oVOMigr:GetCNPJ() )
								
							If V2A->V2A_EVENTO == "S-3000"
								V2A->V2A_RECEXC	:= oVOMigr:GetDelReceipt()
							EndIf

						ElseIf nTipo == 2
							V2A->V2A_RECIBO := oVOMigr:GetReceipt()
							V2A->V2A_DHPROC	:= oVOMigr:GetTimeProc()

							// Verifica se existe o XML Totalizador
							If V2A->V2A_EVENTO $ "S-1200|S-1210|S-1295|S-1299|S-2299" 
								V2A->V2A_XMLTOT := Migr01Tot(oXML)
							EndIf

						EndIf

						If TAFColumnPos("V2A_DTIMP") .And. TAFColumnPos("V2A_HRIMP")
							V2A->V2A_DTIMP	:= Date()
							V2A->V2A_HRIMP	:= SubStr(Time(), 1, 5)
						EndIf

						V2A->V2A_CHVGOV := oVOMigr:GetId()
						V2A->V2A_STATUS := oVOMigr:GetStatus()
						V2A->( MsUnlock() )

						// Guarda os XMLs de sucesso para mover para outro diret�rio.
						aAdd( aXMLCopy, { cPath,; 
										oVOMigr:GetFileXML() } )

					Else
						cMessage := "Falha ao reservar registro para atualiza��o, tente novamente."
						lSuccess := .F.
					EndIf
					
				EndIf

			EndIf
        Else
            
            If oVOMigr:GetCNPJ() == Nil .Or. Empty( oVOMigr:GetCNPJ() )
                aAdd( aNotImport, { oVOMigr:GetFileXML(),;
                            "CNPJ n�o encontrado para o grupo de empresas: " + FWGrpCompany() + "."} )
            Else
                aAdd( aNotImport, { oVOMigr:GetFileXML(),;
                                    "CNPJ informado no empregador do XML � diferente da raiz de CNPJ do diret�rio."} )
            EndIf

		EndIf
	Else
		aAdd( aNotImport, { oVOMigr:GetFileXML(),;
								"Arquivo XML inv�lido."} )
	EndIf

	If !Empty(cMessage)
		aAdd( aNotImport, { oVOMigr:GetFileXML(),;
								cMessage} )
	EndIf

EndIf

// Limpa da mem�ria as classes de interfaces criadas por tXMLManager
DelClassIntF()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Type
Realiza a a valida��o do arquivo XML e retorna o mesmo por refer�ncia
@author  Victor A. Barbosa
@since   05/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Type(oXML, oVOMigr, cCNPJ, cFilProc)

Local aChildXML		:= oXml:DOMGetChildArray()
Local cTagProt		:= "retornoenvioloteeventos"
Local cTagRetEvt	:= "retornoevento"
Local cTagRetProc	:= "retornoprocessamentoloteeventos"
Local cNameSpace	:= ""
Local cXMLTratado	:= ""
Local cStringXML	:= oVOMigr:GetXML()
Local nPosNS		:= 0
Local nType			:= 0
Local nPosEmp		:= 0
Local nPosEvt		:= 0
Local lHasReceipt	:= .F.
Local aParam        := {}
Local aNameSpace    := {}

If Len(aChildXML) > 0
	
	nPosEvt	:= aScan( aEvtRot, {|x| Lower(x[9]) == Lower(aChildXML[1][1]) } )

	// Se n�o encontrou no nada no n� pai, verifica se no primeiro n�vel do filho existe algo
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
        oVOMigr:SetAliasEvent( aEvtRot[nPosEvt][3] )
        
        // Utilizada para registrar o path do XML
		cXMLTratado := StrTran( cStringXML, "'", '"' )
		
		aNameSpace := oXML:DOMGetNsList()
		nPosNs := aScan(aNameSpace,{|ns|AllTrim(ns[1]) == "xmlns"})
		If nPosNs > 0
			cNameSpace := aNameSpace[nPosNs][2]
		Else
			TafConOut("NameSpace n�o declarado. Verifique o Arquivo: " + cXMLTratado)
		EndIf 

        oXml:XPathRegisterNS( "ns1", cNameSpace )
    EndIf

    If Len(aChildXML) > 0
    
        If ExistBlock("TAFMIGRCNPJ")
            aParam := {cCNPJ, oVOMigr:GetXML(), oVOMigr:GetEvent(), oXML}
            cCNPJ := ExecBlock( "TAFMIGRCNPJ", .F., .F., aParam )
        EndIf

        nPosEmp	:= aScan( aSM0, { |x| AllTrim(x[1]) == AllTrim(FWGrpCompany()) .And. AllTrim(x[18]) == AllTrim(cCNPJ) } )

		If nPosEmp > 0

			Do Case
				Case nPosEvt > 0
					
					nType := 1

					oVOMigr:SetId( oXml:XPathGetAtt( "/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() ,"Id") )
					
					// Seta o tipo do Evento
					Migr01TpEvt(oXML, cNameSpace, oVOMigr)

					// Seta o CNPJ do empregador
					Migr01CNPJ(oXML, oVOMigr)

					// No evento S-3000 seta o protocolo do evento que est� sendo exclu�do
					If oVOMigr:GetEvent() == "S-3000"
						Migr01Exc(oXML, oVOMigr)
					EndIf

				Case nPosEvt <= 0 .And. Lower(aChildXML[1][1]) == cTagRetProc .Or. Lower(aChildXML[1][1]) == cTagRetEvt
					nType 	:= 2
				Case nPosEvt <= 0 .And. Lower(aChildXML[1][1]) == cTagProt
					nType := 3
			EndCase

			// --> Verifica se obteve o retorno
			If nType == 2
					
				oVOMigr:SetId( Migr01ID( cStringXML, "Id" ) )
				lHasReceipt := Migr01Receipt(oXML, oVOMigr)

				// Se n�o encontrou o recibo no XML de retorno, devolve zero, para n�o gravar nada na V2A
				If !lHasReceipt
					nType := 0
				EndIf

			EndIf

			oVOMigr:SetCNPJ(cCNPJ)

		EndIf
	
	EndIf

	IIF(Len(aChildXML) > 0, TAFConOut( "Nao foi poss�vel obter os nos filhos do XML. Verifique o arquivo: " + oVOMigr:GetFileXML() ), NIL)

Else
	TAFConOut( "Nao foi poss�vel obter os nos filhos do XML. Verifique o arquivo: " + oVOMigr:GetFileXML() )
EndIf

Return( nType )

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01ID
Retorna o ID do XML
@author  Victor A. Barbosa
@since   05/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01ID(cXML,cAttId)

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
/*/{Protheus.doc} Migr01Receipt
Retorna o recibo do arquivo xml
@author  Victor A. Barbosa
@since   03/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Receipt(oXML, oVOMigr)

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

// S�nior
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
/*/{Protheus.doc} Migr01Status
Retorna o status de acordo com regras

Status Poss�veis:
    1-Somente Envio
    2-Somente T�rmino
    3-Completo sem Processar
    4-Envio Processado
    5-Completo Processado

**************************************************************************************
Regra para lInsert == false

(Obrigatoriamente o registro deve possuir ou "Recibo" ou "Envio" )
1 - Verifica se foi informado o XML de "Envio" de um "Recibo" informado anteriormente
2 - Verifica se foi informado o XML de "Recibo" de um "Envio" informado anteriormente
**************************************************************************************

@author  Victor A. Barbosa
@since   03/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Function Migr01Status(oVOMigr, cV2AEnvio, cV2ARecibo, lInsert, lUpdError)

Local cStatusRet := ""
Local cXMLESoc	 := oVOMigr:GetXML()
Local cRecibo	 := oVOMigr:GetReceipt()

Default lUpdError := .F.

If !lUpdError

	If lInsert // --> Persiste as regras de inclus�o
		If !Empty(cXMLESoc) .And. Empty(cRecibo)
			cStatusRet := "1"
		ElseIf ( Empty(cXMLESoc) .Or. "retornoEvento" $ cXMLESoc) .And. !Empty(cRecibo)
			cStatusRet := "2"
		ElseIf !Empty(cXMLESoc) .And. !Empty(cRecibo)
			cStatusRet := "3"
		EndIf

	Else // --> Persiste as regras de altera��o
		If 	Empty(cV2AEnvio) .And. !Empty(cXMLESoc) .And. !Empty(cV2ARecibo) .Or.; 
			Empty(cV2ARecibo) .And. !Empty(cRecibo) .And. !Empty(cV2AEnvio) .Or.;
			Empty(cXMLESoc) .And. !Empty(cRecibo) .And. !Empty(cV2AEnvio) .And. !Empty(cV2ARecibo)
			cStatusRet := "3"
		EndIf
	EndIf

Else
	If Empty(cV2ARecibo)
		cStatusRet := "1"
	Else
		cStatusRet := "3"
	EndIf
EndIf

oVOMigr:SetStatus(cStatusRet)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Reader
Leitura do arquivo XML
@author  Victor A. Barbosa
@since   09/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Reader(cFileXML)

Local cBuffer	:= ""
Local aFileXML	:= TAFReadFl(cFileXML)
Local nX		:= 0

If aFileXML[2]
	cBuffer := aFileXML[3]
EndIf

// Tratamento para ajustar os namespaces n�o tratados, devido as altera��es do governo
For nX := 1 To 9
	cBuffer := StrTran(cBuffer, "retornoEvento/v1_2_" + cValToChar(nX) , "retornoEvento/v1_2_0" )
Next nX

Return(cBuffer)

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Tot
Verifica se existe o XML Totalizador e seta o conte�do no atributo
@author  Victor A. Barbosa
@since   23/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Tot(oXML)

Local cString	:= ""

If oXML:XPathDelNode( "/evento/retornoEvento" )
	cString := oXML:Save2String()
EndIf

cString	:= StrTran(cString, '<?xml version="1.0">', '' )
cString	:= StrTran(cString, '<?xml version="1.0"?>', '' )

Return( cString )

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Radio
Habilita/Desabilita as op��es para pesquisar diret�rio de processamento
@author  Victor A. Barbosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Radio(nRadio, oButton, oButtonSrc, oGetDir, oGetThrd)

If nRadio == 1 .Or. nRadio == 3
	oGetDir:Enable()
	oButtonSrc:Enable()
Else
	oButtonSrc:Disable()
	oGetDir:Disable()
EndIf

If nRadio == 2 .Or. nRadio == 3
	oGetThrd:Enable()
Else
	oGetThrd:Disable()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01ToTAF
Chama a fun��o de migra��o dos dados da tabela V2A para o TAF
@author  Victor A. Barbosa
@since   15/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01ToTAF(oSay, oMeter, nNumThrd, lRadio, lProcess)

Default lRadio := .F.
Default lProcess := .F.


TAFMigr002(oSay, oMeter, nNumThrd, lRadio, lProcess)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01TpEVT
Seta o tipo do Evento
@author  Victor A. Barbosa
@since   24/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Function Migr01TpEVT(oXML, cNameSpace, oVOMigr)

Local cXMLEvento    := oVOMigr:GetXML()

// Verifica o tipo de envio ao governo
If oXml:XPathHasNode("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEvento/ns1:indRetif")
    oVOMigr:SetTypeEvent(oXml:XPathGetNodeValue("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEvento/ns1:indRetif"))
EndIf
// Se est� vazio � sinal que � evento de tabela ou totalizador que ser� analisado abaixo
If Empty( oVOMigr:GetTypeEvent() )
    If At( "<inclusao>", cXMLEvento ) > 0
        oVOMigr:SetTypeEvent("3")
    ElseIf At( "<alteracao>", cXMLEvento ) > 0
        oVOMigr:SetTypeEvent("4")
    ElseIf At( "<exclusao>", cXMLEvento ) > 0
        oVOMigr:SetTypeEvent("5")
    EndIf
EndIf

// Verifica se � evento totalizador ou evento de exclus�o
If Empty( oVOMigr:GetTypeEvent() ) .And. oVOMigr:GetEvent() $ "S-1295|S-1299|S-1298|S-2190|S-3000|S-5001|S-5002|S-5011|S-5012"
    oVOMigr:SetTypeEvent("1")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Exc
Seta o recibo de exclus�o, no qual o S-3000 est� excluindo.
@author  Victor A. Barbosa
@since   29/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Exc(oXML, oVOMigr)

Local cRet := ""

oXml:XPathRegisterNS( "ns1", "http://www.esocial.gov.br/schema/evt/evtExclusao/v02_04_02" )

If oXml:XPathHasNode("/ns1:eSocial/ns1:evtExclusao/ns1:infoExclusao")
	oVOMigr:SetDelReceipt( oXml:XPathGetNodeValue("/ns1:eSocial/ns1:evtExclusao/ns1:infoExclusao/ns1:nrRecEvt") )
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrInExec
Retorna se o migrador est� em execu��o de acordo com o sem�foro
@author  Victor A. Barbosa
@since   04/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrInExec()
Return( lInExec )

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Slice
Transforma o lote de XMLs em arquivos XMLs unit�rios
@author  Victor A. Barbosa
@since   27/11/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Slice(cXML, cPath, cFilProc, cCNPJ)

Local xTotaliz	:= Nil
Local xEvt		:= Nil
Local nPosIni	:= 0
Local nPosFim	:= 0
Local nX		:= 0
Local nY		:= 0
Local cWarning	:= ""
Local cError	:= ""

Private oXMLSlice := Nil

// Remove as informa��es de cabe�alho do lote e as tags de fechamento.

cXML := Migr01DelNS(cXML)

nPosIni	:= At( "<eSocial", cXML )
cXML 	:= SubStr(cXML, nPosIni )
nPosFim := rAt( "</eSocial>", cXML )
cXml 	:= SubStr(cXML, 1, nPosFim + 9 )

//Parser do XML para gera��o do outros arquivos
oXMLSlice 	:= XMLParser(cXML, "", @cError, @cWarning)

If Empty(cError) .And. Empty(cWarning)
	
	//Ajuste para o segundo xml
	If Type("oXMLSlice:_eSocial:_RetornoProcessamentoLoteEventos") != "U"

		If XmlChildEx( oXMLSlice:_eSocial:_RetornoProcessamentoLoteEventos, "_RETORNOEVENTOS" ) <> Nil

			xEvt := oXMLSlice:_eSocial:_RetornoProcessamentoLoteEventos:_RetornoEventos:_Evento

			If ValType(xEvt) == "A"

				For nX := 1 To Len(xEvt)

					// Cria��o do "subxml" do retorno do recibo
					Migr01Create(xEvt[nX], cPath, cFilProc, cCNPJ, "rec", "")
					
					// Cria��o do "subxmls" dos totalizadores
					xTotaliz := XMLChildEx(xEvt[nX], "_TOT")

					If xTotaliz <> Nil
						If ValType(xTotaliz) == "A"
							For nY := 1 To Len(xTotaliz)
								Migr01Create(xTotaliz[nY], cPath, cFilProc, cCNPJ, "tot", xTotaliz[nY]:_TIPO:TEXT)
							Next nY
						ElseIf ValType(xTotaliz) == "O"
							Migr01Create(xTotaliz, cPath, cFilProc, cCNPJ, "tot", xTotaliz:_TIPO:TEXT)
						EndIf
					EndIf
				Next nX

			ElseIf ValType(xEvt) == "O"
				Migr01Create(xEvt, cPath, cFilProc, cCNPJ, "rec", "")
			EndIf
		Else
			TAFConOut( "N� de Retorno n�o encontrado." )
		EndIf
	
	ElseIf Type("oXMLSlice:_eSocial:_envioLoteEventos:_eventos") != "U"
		
		xEvt := oXMLSlice:_eSocial:_envioLoteEventos:_eventos:_evento

		If ValType(xEvt) == "A"

			For nX := 1 To Len(xEvt)

				// Cria��o do "subxml" do retorno do recibo
				Migr01Create(xEvt[nX], cPath, cFilProc, cCNPJ, "rec", "")
					
				// Cria��o do "subxmls" dos totalizadores
				xTotaliz := XMLChildEx(xEvt[nX], "_TOT")

				If xTotaliz <> Nil
					If ValType(xTotaliz) == "A"
						For nY := 1 To Len(xTotaliz)
							Migr01Create(xTotaliz[nY], cPath, cFilProc, cCNPJ, "tot", xTotaliz[nY]:_TIPO:TEXT)
						Next nY
					ElseIf ValType(xTotaliz) == "O"
						Migr01Create(xTotaliz, cPath, cFilProc, cCNPJ, "tot", xTotaliz:_TIPO:TEXT)
					EndIf
				EndIf
			Next nX

		ElseIf ValType(xEvt) == "O"
			Migr01Create(xEvt, cPath, cFilProc, cCNPJ, "rec", "")
		EndIf
	Else
		TAFConOut( "N� de Retorno n�o encontrado." )
	EndIf

Else
	TAFConOut( "Error: " + cError )
	TAFConOut( "Warning: " + cWarning )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Create
Cria os arquivos XMLs
@author  Victor A. Barbosa
@since   27/11/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Create(oEvento, cPath, cFilProc, cCNPJ, cPrefixo, cTotaliz)

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

// Remove as informa��es de cabe�alho do lote e as tags de fechamento.
nPosIni		:= At( "<eSocial", cStrSlice )
cStrSlice 	:= SubStr(cStrSlice, nPosIni )
nPosFim 	:= At( "</eSocial>", cStrSlice )
cStrSlice 	:= SubStr(cStrSlice, 1, nPosFim + 9 )
cStrSlice	:= FwNoAccent(cStrSlice)

//Se existir XML com o mesmo nome, n�o sobrep�e ... "Acumula" ...
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
/*/{Protheus.doc} Migr01Move
Move o arquivo passado por par�metro para outro diret�rio
@author  Victor A. Barbosa
@since   27/11/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Move(aFileXML, nCopy)

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
/*/{Protheus.doc} Migr01Pend
Processa os arquivos pendentes (Gerados na hora de "fatiar")
@author  Victor A. Barbosa
@since   28/11/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Pend(oFWRun)

Local nX 		:= 0
Local nQtdTot	:= Len(aSlice)
Local oVOMigr	:= TAFVOMigr():New()

For nX := 1 To nQtdTot

	SetIncPerc( oFWRun, "3", nQtdTot, nX )

	oVOMigr:SetFileXML( aSlice[nX][3] )
	
	Migr01Grv( oVOMigr, aSlice[nX][2], aSlice[nX][4], aSlice[nX][5] )

	oVOMigr:Clear()
Next nX

Return

/*/{Protheus.doc} VldNumThrd
Valida��o do n�mero de threads
@type  Static Function
@author Diego Santos
@since 28-11-2018
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function VldNumThrd( cNumThrd )

Local lRet := .T.

If !Empty(cNumThrd)
	If Val(cNumThrd) < 1 .Or. Val(cNumThrd) > 10
		lRet := .F.
		MsgInfo("O n�mero de threads para este processo de ser um valor entre 1 e 10.", "Aviso")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Copy
Encapsula a copia de arquivos em lote
@author  Victor A. Barbosa
@since   07/12/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Copy(aXMLCopy)

Local nX := 0

For nX := 1 To Len(aXMLCopy)
	Migr01Move(aXMLCopy[nX], 2)
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrFilTAF
Retorna a Filial do TAF conforme CNPJ
@author  Victor A. Barbosa
@since   06/12/2018
@version 1
/*/
//-------------------------------------------------------------------
Function MigrFilTAF(cCNPJ)

Local aArea 	:= GetArea()
Local nPosEmp	:= 0
Local cFilSM0	:= ""
Local cFilTAF	:= ""

nPosEmp := aScan( aSM0, { |x| AllTrim(x[18]) == AllTrim(cCNPJ) } )

If nPosEmp > 0
	cFilSM0 := aSM0[nPosEmp][1] + aSM0[nPosEmp][2]
	cFilTAF := fTafGetFil(cFilSM0)
EndIf

RestArea(aArea)

Return(cFilTAF)

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01DelNS
Remove NS desnecess�rios
@author  Victor A. Barbosa
@since   04/04/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01DelNS(cXML)

Local nX := 0

For nX := 1 To 10 
	cXML := StrTran(cXML, "ns" + cValToChar(nX) + ":", "" )
Next nX

cXML := StrTran( cXML, 'xmlns:ds="http://www.w3.org/2000/09/xmldsig#"', '')
cXML := StrTran( cXML, 'xmlns:xs="http://www.w3.org/2001/XMLSchema"', '')

Return(cXML)

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01CNPJ
Seta o CNPJ do arquivo XML
@author  Victor A. Barbosa
@since   12/06/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01CNPJ(oXML, oVOMigr)

// Verifica o tipo de envio ao governo
If oXml:XPathHasNode("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEmpregador/ns1:nrInsc")
    oVOMigr:SetCNPJXml( oXml:XPathGetNodeValue("/ns1:eSocial/ns1:" + oVOMigr:GetTagMain() + "/ns1:ideEmpregador/ns1:nrInsc") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01Rel
Realiza a impress�o do relat�rio de importa��o de arquivos
@author  Victor A. Barbosa
@since   12/06/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01Rel(aNotImport)

TAFRMig02(aNotImport)

Return

