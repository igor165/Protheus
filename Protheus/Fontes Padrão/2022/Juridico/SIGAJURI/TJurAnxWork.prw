#INCLUDE "PROTHEUS.CH"
#INCLUDE "TJURANXWORK.CH"

//Function Dummy
Function __TJurAnxWork()
	ApMsgInfo( I18n(STR0001, {"TJurAnxWork"}) )	//STR0001 //"Utilizar Classe ao invés da função #1"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe de anexos do WorkSite

@author Willian Kazahaya
@since  20/11/2018
/*/
//-------------------------------------------------------------------
CLASS TJurAnxWork FROM TJurAnexo
	Data oGed
	Data cDll
	Data cServer
	Data lCheckTrust
	Data cGedDb
	Data cGedServer
	Data cGedUser
	Data cGedPassword
	Data lCloud 
	
	Data cGedId
	Data cGedStr

	Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, cIndice, lInterface, lEntPFS) CONSTRUCTOR

	// Metodos GED
	Method GedNew()
	Method GedConnect()
	Method GedLogin()
	Method GedLogout()
	Method GedDisconnect()
	Method GedCommand(cOperacao, cFile, cNomeTemp)
	Method GedFichaWork()
	Method GedAttach()
	
	Method DesmembraFileGed( cFile )
	
	// Método de botões
	Method Abrir()
	Method Importar()
	Method Anexar()
	
	Method GetCliCaso()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New(cTitulo, cEntidade, cFilEnt, cCodEnt, cIndice)
Inicializador da Classe

@param  cTitulo    - Título da tela
@param  cEntidade  - Entidade utilizada no anexo
@param  cFilEnt    - Filial da entidade
@param  cCodEnt    - Código da entidade
@param  cIndice    - Índice da entidade utilizado para buscar o XXX_CAJURI
@param  lInterface - Indica se demonstra a Interface
@param  lEntPFS    - Indica se é uma entidade do SIGAPFS
                     Necessário devido ao uso da fila de sincronização - LegalDesk
@param  lCloud     - Indica se o Worksite utilizado é o IManage Cloud - 
                     Se estiver ativo irá autenticar o usuário via SAML (Olhar GedConnect())

@author Willian Kazahaya
@since  20/11/2018
/*/
//-------------------------------------------------------------------
Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, cIndice, lInterface, lEntPFS) CLASS TJurAnxWork
Local lRet     := .T.
Local aButtons := {}

Default lInterface := .T.
Default lEntPFS    := .F.

	Self:cDll        := AllTrim(SuperGetMV('MV_JGEDDLL',,'SIGAGEDW.dll'))
	Self:cServer     := AllTrim(SuperGetMV('MV_JGEDSER',,'WORKSITE'))
	Self:lCheckTrust := SuperGetMV('MV_JGEDTL' ,,.T.)
	Self:cGedDb      := SuperGetMV('MV_JGEDDAN',,'')
	Self:cGedUser    := Encode64(SuperGetMV('MV_JUSREXT',,''))
	Self:cGedPassword:= Encode64(SuperGetMV('MV_JPWDEXT',,''))
	Self:lHtml       := ( GetRemoteType() == 5 )
	Self:lCloud      := SuperGetMV('MV_JGEDCLD' ,,.F.)
	
	lRet := Self:lHtml .OR. Self:GedNew()

	If lRet
		_Super:New(cTitulo, cEntidade, cFilEnt, cCodEnt, cIndice, lInterface, lEntPFS)
		
		//Seta botões
		Aadd(aButtons, {STR0004	, {|| Processa({|| Self:Abrir()}		, STR0002, STR0003, .F.)}, 2})	//STR0004	STR0002	STR0003 //"Aguarde" //"Abrindo arquivos" //"Abrir"
		Aadd(aButtons, {STR0006	, {|| Processa({|| Self:Importar()}		, STR0002, STR0005, .F.)}, 3})	//STR0006	STR0002	STR0005 //"Importando arquivos" //"Aguarde" //"Importar"

		If !Self:lHtml
			Aadd(aButtons, {STR0025	, {|| Processa({|| Self:Anexar()}	, STR0002, STR0026, .F.)}, 3})	//"Anexar"	"Aguarde"	"Anexar arquivos"
		Endif

		Aadd(aButtons, {STR0008	, {|| Processa({|| Self:Excluir()}  	, STR0002, STR0007, .F.)}, 5})	//STR0008	STR0002	STR0007 //"Excluindo arquivos" //"Aguarde" //"Excluir"
		Self:GetCliCaso()
		Self:SetUrl( Self:cServer )
		Self:SetButton( aButtons )

		Self:SetShowUrl( .T. )
		
		If lInterface
			Self:Activate()
		EndIf

	Else
		JurMsgErro(STR0009 +GetMV('MV_JGEDSER',,'WORKSITE')) // STR0009 //"Falha Conexão com o servidor GED - "
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GedNew()
Abertura de nova conexão GED

@author Willian Kazahaya
@since  20/11/2018
/*/
//-------------------------------------------------------------------
Method GedNew() CLASS TJurAnxWork
Local lRet := .F.

	lRet := Self:GedConnect()

	If lRet
		lRet := Self:GedLogin()
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GedConn()
Conexão com GED

@author Willian Kazahaya
@since  20/11/2018
/*/
//-------------------------------------------------------------------
Method GedConnect() CLASS TJurAnxWork
Local lRet := .F.

	Self:oGed := JurGED():New(Self:cServer, Self:cDll)
	lRet := Self:oGed:Connect()

	If !lRet
		JurMsgErro(STR0010) // STR0010 //"Falha Conexão com GED"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GedLogin()
Login GED

@author Willian Kazahaya
@since  20/11/2018
/*/
//-------------------------------------------------------------------
Method GedLogin() CLASS TJurAnxWork
Local lRet := .F.

	lRet := Self:oGed:LogIn( Self:lCheckTrust, Self:lCloud )

	If !lRet
		JurMsgErro( STR0011 ) // STR0011 //"Falha Login com GED"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GedLogOUT()
Logout GED

@author Willian Kazahaya
@since  20/11/2018
/*/
//-------------------------------------------------------------------
Method GedLogout() CLASS TJurAnxWork
Local lRet := .F.

	lRet := Self:oGed:Logout()

	If !lRet
		JurMsgErro( STR0012 ) // STR0012 //"Falha LogOut com GED"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GedDisconnect()
Desconecta do GED

@author Willian Kazahaya
@since  20/11/2018
/*/
//-------------------------------------------------------------------
Method GedDisconnect() CLASS TJurAnxWork
Local lRet := .F.

	lRet := Self:oGed:Finish()

	If !lRet
		JurMsgErro( STR0013 ) // STR0013 //"Falha na finalização da conexão com GED"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCommand()
Monta o comando de Importação e Exportação

@author Willian Kazahaya
@since  26/11/2018
/*/
//-------------------------------------------------------------------
Method GedCommand(cOperacao, cFile, cNomeTemp) CLASS TJurAnxWork
Local cRet       := ""
Local cPastaTemp := GtTempPath()
Local cFichaWork := Self:GedFichaWork()

Default cOperacao := ""
Default cNomeTemp := GeraNomTmp(cPastaTemp)

	If cOperacao == "I"
		cRet := 'SGGED32 I ' + Self:cServer        + ' ';
		                     + Self:cGedDb         + ' ';
		                     + Self:cGedUser       + ' ';
		                     + Self:cGedPassword   + ' ';
		                     + Self:cCliLoja       + ' ';
		                     + Self:cCasoCliente   + ' "';
		                     + cPastaTemp+cNomeTemp+ '" "';
		                     + cPastaTemp+cFile    + '" "';
		                     + cFichaWork          + '" '
	ElseIf cOperacao == "E"
		cRet := "SGGED32 E " + AllTrim(Self:cServer)        + ' ';
		                     + AllTrim(Self:cGedUser)       + ' ';
		                     + AllTrim(Self:cGedPassword)   + ' ';
		                     + AllTrim(Self:cDocumento)     + ' "';
		                     + AllTrim(cPastaTemp)          + '" ';
		                     + AllTrim(cFile)
	ElseIf cOperacao == "A"
		cRet := SuperGetMV('MV_JWSPESQ',,'1')  + ' ' ;
              + SuperGetMV('MV_JNRCCLI',,'25') + ' ' ;
              + Self:cCliLoja + ' ' ;
              + SuperGetMV('MV_JNRCCAS',,'26') + ' ' ;
              + Self:cCasoCliente
	Else
		cRet := cFile + ;
		        "??" + Self:cCliLoja + ;
				"??" + Self:cCasoCliente + ;
				"??" + Self:cGedDb + ;
				"??" + cFichaWork
	EndIf
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GedFichaWork()
Monta a Ficha do Worksite

@author Willian Kazahaya
@since  28/11/2018
/*/
//-------------------------------------------------------------------
Method GedFichaWork() CLASS TJurAnxWork
Local cFichaWork := ""
Local cAlias     := GetNextAlias()
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryOrd    := ""
Local cQuery     := ""

	cQrySel := " SELECT NZH_FILIAL "
	cQrySel +=       " ,NZH_CAMPO " 
    cQrySel +=       " ,NZH_TIPO " 
    cQrySel +=       " ,NZH_VALOR "
    
    cQryFrm := " FROM " + RetSqlName("NZH") + " NZH "
    
    cQryWhr := " WHERE D_E_L_E_T_ = ' ' "
    cQryOrd := " ORDER BY NZH_FILIAL "
    cQryOrd +=         " ,NZH_CAMPO "
	
	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F. )
	
	While (cAlias)->(!Eof())
		If !Empty(cFichaWork)
			cFichaWork += "||"
		EndIf
		
		cFichaWork += AllTrim( (cAlias)->(NZH_CAMPO) ) + "!!" +;
		              AllTrim( (cAlias)->(NZH_TIPO)  ) + "!!" +;
		              AllTrim( (cAlias)->(NZH_VALOR) )
		
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( DbCloseArea() )
Return cFichaWork 

//-------------------------------------------------------------------
/*/{Protheus.doc} Abrir()
Download e Abertura do Documento

@author Willian Kazahaya
@since  26/11/2018
/*/
//-------------------------------------------------------------------
Method Abrir() CLASS TJurAnxWork
Local aDocsSel      := Self:GetRegSelecionado()
Local cCommand      := ""
Local lRet          := .F.
Local cPastaTemp    := GtTempPath()
Local cDirProtheus  := "\SPOOL\"
Local cFile         := ""
Local nDocs         := 0
Local nRet          := 0
Local cJFLGURL      := SuperGetMV('MV_JFLGURL' ,,"") // Paleativo de integração IManage/Lefosse - Willian

	// Verifica se há Documentos Selecionados
	If Len(aDocsSel) > 0
		For nDocs := 1 To Len(aDocsSel)
			Self:cDocumento := aDocsSel[nDocs][4]


			If Self:lHtml
				cFile    := AllTrim(aDocsSel[nDocs][6]) + "." +  AllTrim(aDocsSel[nDocs][5])
				cCommand := Self:GedCommand("E", cFile)
			
				lRet := WaitRunSrv( cCommand, .T., cPastaTemp )
				
				If lRet 
					If File(cDirProtheus + cFile)
						nRet := CpyS2TW( cDirProtheus + cFile , .T./*Envia p/ Navegador*/ )
						
	                    If (nRet == 0)
	                        ApMsgInfo(STR0014)  //STR0014 //"Exportação do arquivo finalizada!"
	                    ElseIf (nRet == -1)
	                        JurMsgErro(STR0015)  //STR0015 //"Diretório não é um diretório no servidor!"
	                    ElseIf (nRet == -2)
	                        JurMsgErro(STR0016)  //STR0016 //"Arquivo não existe no servidor!"
	                    ElseIf (nRet == -3)
	                        JurMsgErro(STR0017)  //STR0017 //"Falha na transmissão para o Servidor Web (Remote HTML)!"
	                    ElseIf (nRet == -4)
	                        JurMsgErro(STR0018)  //STR0018 //"Falha na transmissão para o Client Web (navegador de internet)!"
	                    EndIf
	
	                    delete file &(cDirProtheus+cFile)
					Else
						JurMsgErro( STR0019 )  //STR0019 //"Problema para exportar o arquivo!"
	                    Break
					EndIf
				EndIf
			Else
				If ( Empty(cJFLGURL))
					cFile := AllTrim(aDocsSel[nDocs][4])
					lRet := Self:oGed:GetFile( cFile )
				
					If !lRet
						JurMsgErro( STR0020 ) // STR0020 //"Falha ao abrir documento!"
						Break
					EndIf
				Else// Willian - IManage - Lefosse
					Self:SetDocumento(BldUrlW10(aDocsSel[nDocs][4]))
					_Super:Abrir()
				EndIf
			EndIf
		Next
	Else
		JurMsgErro( STR0021 )  // STR0021 //"Nenhum documento foi selecionado!"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BldUrlW10(cFile)
Função responsável por extrair informações do Comando do Worksite
para abrir arquivos no IManage 10 - Web

@obs Essa função é uma solução paleativa para resolver o problema da
     integração existente na Lefosse

@author Willian Kazahaya
@since  17/08/2021
/*/
//-------------------------------------------------------------------
Static Function BldUrlW10(cFile)
Local cFullUrl    := ""
Local aCommand    := StrToKArr(cFile, "!") // !nrtdms:0:!session:10.171.67.66:!database:DOCS:!document:247,1:
Local cDatabase   := ""
Local cIdDocument := ""
Local nI          := 0
Local cJFLGURL    := SuperGetMV('MV_JFLGURL' ,,"") // Paleativo de integração IManage/Lefosse - Willian
	/*
		fnCreateFile('SIGAGEDW.LOG', 'URL Abertura: ' + plcObjectID);
		urlServer := 'worksite.totvs.com.br';
		Database := 'DOCS';
		IdDocument := '249';
		Version := '1';
		openURL := 'https://' + urlServer + '/work/web/dialogs/link/d/' + Database + '!' + IdDocument + '.'  + Version;
	*/

	For nI := 1 to Len(aCommand)
		If (At("database:", aCommand[nI] ) > 0)
			cDatabase := StrToKArr(aCommand[nI], ':')[2]
		ElseIf (At("document:", aCommand[nI] ))
			cIdDocument := StrTran(StrToKArr(aCommand[nI], ':')[2],",",".")
		EndIf
	Next nI
	cFullUrl := cJFLGURL + '/work/web/dialogs/link/d/' + cDatabase + '!' + cIdDocument
Return cFullUrl

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar()
Download e Abertura do Documento

@author Willian Kazahaya
@since  28/11/2018
/*/
//-------------------------------------------------------------------
Method Importar() CLASS TJurAnxWork
Local lContinua  := .F.
Local lRet       := .T.
Local nQtdArqs   := 0
Local nI         := 0
Local cErroFile  := ""
Local cArqNome   := ""
Local cCommand   := ""
Local cNomeTemp  := ""
Local cFile      := ""
Local cPastaTemp := GtTempPath()
Local cGetId     := ""
Local cGetStr    := ""

	Self:SetOperation(3)
	
	If Self:lInterface
		// Chama a tela de seleção de arquivos
		lContinua := _Super:Importar()
	Else
		lContinua := .T.
	EndIf
	
	// Verifica se foi selecionado algum arquivo para importar
	If lContinua
		// Pega a quantidade de arquivos selecionados
		nQtdArqs := Len(Self:aArquivos)

		// Se houver mais de um arquivo selecionado
		If nQtdArqs > 0 

			// Loop
			For nI := 1 To nQtdArqs
				If Self:lInterface
					IncProc( I18N(STR0022, 	{cValToChar(nI), cValToChar(nQtdArqs)}) )		//STR0022 //"Importando arquivo(s) #1 de #2"
				EndIf

				// Busca o nome do arquivo
				cArqNome := Self:RetArquivo(Self:aArquivos[nI], .T.)
				
				// Verifica se é SmartHtml ou Se o Objeto do Ged foi instanciado
				If Self:lHtml .OR. Self:oGed == Nil
					// Operação de inclusão
					cNomeTemp  := GeraNomTmp(cPastaTemp)
				
					// Copia o Arquivo para o Spool
					Self:ManipulaDoc(3, cArqNome,StrTran(Self:aArquivos[nI],cArqNome,""),"\SPOOL\")
				
					// Monta o comando do Ged e Executa
					cCommand := Self:GedCommand( 'I', cArqNome, cNomeTemp)

					// Executa o comando que envia o arquivo para o GED
					WaitRunSrv( cCommand, .T., cPastaTemp )
				
					// Feita a cópia, o arquivo no Spool é excluido
					Self:ManipulaDoc(5, cArqNome,StrTran(Self:aArquivos[nI],cArqNome,""),,)

					If File(cPastaTemp + cNomeTemp)
						// Le o arquivo para pegar a linha de comando
						cFile := MemoRead( "\SPOOL\" + cNomeTemp )
					Else
						lRet := .F.
					EndIf

				Else
					cFile := Self:GedCommand("", Self:aArquivos[nI])
					cFile := PadR(cFile,255)

					Self:oGed:cPath := SUBSTR( cFile, 1, RAt("\", cFile) -1 )
				
					lRet := Self:oGed:UpFile(@cFile, @cGetId, @cGetStr)
				EndIf

				// Verifica se o arquivo do GED existe
				If lRet 
					// Desmembra o retorno do cFile
					aNumDados := Self:DesmembraFileGed(cFile)
					conout("cGetStr:" + cGetStr + " | cFile:" + cFile)
					conout("aNumDados: " + aNumDados[1] + " | " + aNumDados[2] + " | " + aNumDados[3] + " | " + aNumDados[4])
					// Grava os dados
					Self:GravaNUM(aNumDados[1], aNumDados[2], aNumDados[3], aNumDados[4], /**/)
				Else
					cErroFile += cFile + ";"
				EndIf
			Next
			
			// Verificação de Erro
			If !Empty(cErroFile)
				JurMsgErro(STR0023 + cErroFile ) //STR0023  //"Falha UpFile com GED! Os seguintes arquivos não foram importados: "
				lRet := .F.
			EndIf 
		EndIf
	
		If lRet
			If Self:lInterface
				Self:AtualizaGrid()
			EndIf
		EndIf		 
	EndIf
	
Return lRet
	
//-------------------------------------------------------------------
/*/{Protheus.doc} Anexar()
Anexa o documento do GED na NUM

@author Willian Kazahaya
@since  04/12/2018
/*/
//-------------------------------------------------------------------
Method Anexar() CLASS TJurAnxWork
Local aNumDados := {}
Local cFile := Self:GedCommand("A")

	If !Empty( Self:GedAttach( @cFile ) )
		If !Empty(cFile)
			Self:oGed:cPath := SUBSTR( cFile, 1, RAt("\", cFile) -1 )
			aNumDados := Self:DesmembraFileGed(cFile)
			Self:GravaNUM(aNumDados[1], aNumDados[2], aNumDados[3], aNumDados[4], /**/)
			
			If self:lInterface
				Self:AtualizaGrid()			
			EndIf
		EndIf
	Else
		JurMsgErro( STR0024 ) // STR0024 //"Falha ao anexar documento!"
	EndIf		
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}  GedAttach(cFile)
Chamada da função de Anexar do GED

@author Willian Kazahaya
@since  04/12/2018
/*/
//-------------------------------------------------------------------
Method GedAttach(cFile) CLASS TJurAnxWork
Local cGetId  := ""
Local cGetStr := ""

	If !( Self:oGed:Attach( @cFile, @cGetId, @cGetStr  ) )
		JurMsgErro( STR0027 ) // "Falha Attach com GED" 
		cFile := ""
	EndIf
	
Return cFile

//-------------------------------------------------------------------
/*/{Protheus.doc} DesmembraFileGed(cFile)
Desmembra o File do GED para Gravação

@param cFile - Comando retornado do GED

@return aInfoNUM - Array com as informações da NUM
        [1] - NUM_NUMERO
        [2] - NUM_DOC
        [3] - NUM_DESC
        [4] - NUM_EXTEN
@author Willian Kazahaya
@since  28/11/2018
/*/
//-------------------------------------------------------------------
Method DesmembraFileGed( cFile ) CLASS TJurAnxWork
Local aInfoNUM := {}
Local nPos     := 0
Local cDoc     := ""
Local cNumero  := ""
Local cExtensao:= ""
Local cDescFile:= ""
	cFile := StrTran(cFile, Chr(13)+Chr(10),"")
	
	nPos := At( ' ', cFile )
	cDoc := SubStr( cFile, 1, nPos - 1 )
	cFile := SubStr( cFile, nPos + 1 )

	nPos := At( ' ', cFile )
	cNumero := SubStr( cFile, 1, nPos - 1 )
	cFile := SubStr( cFile, nPos + 1 )

	nPos := At( ' ', cFile )
	cExtensao := SubStr( cFile, 1, nPos - 1 )
	
	cDescFile := SubStr( cFile, nPos + 1 )

	aAdd(aInfoNUM, AllTrim(cNumero  ) )
	aAdd(aInfoNUM, AllTrim(cDoc     ) )
	aAdd(aInfoNUM, AllTrim(cDescFile) )
	aAdd(aInfoNUM, AllTrim(cExtensao) )
	
Return aInfoNUM
//-------------------------------------------------------------------
/*/{Protheus.doc} GetCliCaso()
Busca o Cliente/Loja e Caso do Processo

@author Willian Kazahaya
@since  28/11/2018
/*/
//-------------------------------------------------------------------
Method GetCliCaso() CLASS TJurAnxWork
Local aCliCaso  := {}

	If Self:cEntidade == "NSZ"
		aCliCaso := JURCLICAS0(Self:cCodEnt, .F.)
	ElseIf &(Self:cEntidade + "->(ColumnPos('" + Self:cEntidade + "_CAJURI'))")> 0
		aCliCaso := JURCLICAS0(&(Self:cEntidade + "->" + Self:cEntidade + "_CAJURI"), .F.)
	EndIf
	
	If len(aCliCaso) > 0
		Self:cCliLoja     := aCliCaso[1][1]
		Self:cCasoCliente := aCliCaso[1][2]
	Else
		Self:cCliLoja     := ""
		Self:cCasoCliente := ""
	EndIf

Return aCliCaso

/*/--------------------------------------/*/
/*/--------------------------------------/*/
/*/              Functions               /*/
/*/--------------------------------------/*/
/*/--------------------------------------/*/
//-------------------------------------------------------------------
/*/{Protheus.doc} GeraNomTmp(cPastaTemp)
Gera nome ne arquivo temporario de retorno do GED

@author SIGAJURI
@since
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraNomTmp(cPastaTemp)

Local cNomeArq := 'GED' + DtoS(Date()) + StrTran(Time(), ':', '') + '.GED'
	
	Do While File(cPastaTemp + cNomeArq)
		Inkey(0.5)
		cNomeArq := 'GED' + DtoS(Date()) + StrTran(Time(), ':', '') + '.GED'
	EndDo

Return cNomeArq

//-------------------------------------------------------------------
/*/{Protheus.doc} GtTempPath()
Monta o Path Temporário

@author Willian Kazahaya
@since 30/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GtTempPath()
Local cDirProtheus  := "\SPOOL\"
Local cPastaTemp    := "" 

	cPastaTemp := cBIFixPath( GetPvProfString( GetEnvServer(), "ROOTPATH", "" , GetADV97() ) + cDirProtheus, "\" )

Return cPastaTemp
















