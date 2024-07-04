#Include 'PROTHEUS.CH'
#Include 'XMLXFUN.CH'
#Include 'FILEIO.CH'
#Include 'MATA411.CH'
#Include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cEvent	:= '' //Guarda mensagens de log para descrição do Event Viewer

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA411
Rotina para integracao do Pedido de Vendas através do TOTVS
Colaboração. Essa rotina deve ser acionada através de Job, chamando
a função MA411Job().

@sample 	MATA411()

@author	Danilo Dias
@since		02/10/2012
@version	P11.7
/*/
//-------------------------------------------------------------------
Function MATA411()
	
Local lUsaColab := UsaColaboracao("6")

If lUsaColab
	MA411RecCol()
Else
	Ma411RecDoc()
EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MA411Job
Função de acionamento do recebimento de pedido de venda para ser
executada via Job.

@sample 	MA411Job( aParam )
@param		aParam		Parâmetros para preparação do ambiente.
{ cEmpresa, cFilial, cUsuario }

@author	Danilo Dias
@since		02/10/2012
@version	P11.7
/*/
//-------------------------------------------------------------------
Main Function MA411Job( aParam )
	
Local cUsaColab 	:= ""	//Parametro que indica se usa TOTVS Colaboração
Local lUsaColab		:= .F.	//Verifica se usa TOTVS Colaboração 2.0 para recebimento
Local cLog			:= ""	//Mensagem de log da execução da rotina

Local xParam3		:= aParam[3]

RpcSetEnv( aParam[1], aParam[2], aParam[3] )	//Inicializa ambiente

cUsaColab := SuperGetMV( "MV_SPEDCOL", .F., "N" )
lUsaColab := UsaColaboracao("6")

//Executa apenas se parametrizado para usar TOTVS Colaboração
If lUsaColab
	//-- TOTVS Colaboracao 2.0
	lUsaColab := ColCheckUpd()
	If !lUsaColab
		cLog := STR0037	//"UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0"
		GravarLog( cLog, ProcName() )
	Else
		ConOut( "[COLABORACAO MATA411 PV " + DtoC( date() ) + " - " + time() + " ] " +STR0038+ CRLF )//"Iniciando processo de geracao do pedido de venda"
		MA411RecCol(Nil,Nil,xParam3)	//Aciona função de recebimento de documentos TOTVS Colaboração 2.0
		
		ConOut( "[COLABORACAO MATA411 PV " + DtoC( date() ) + " - " + time() + " ] " + STR0040+ CRLF ) //"Finalizando processo de geracao do pedido de venda"
	EndIf
Else
	If ( cUsaColab == "S" )
		MA411RecDoc()	//Aciona função de recebimento de documentos
	Else
		cLog := STR0030	//"Parâmetro MV_SPEDCOL não está configurado para utilizar TOTVS Colaboração."
		GravarLog( cLog, ProcName() )
	EndIf
EndIf

RpcClearEnv()	//Limpa ambiente criado
	
Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA411RecCol
Recebe documentos através do TOTVS Colaboração 2.0.

@sample 	MA411RecDoc( dDtInic, dDtFim )
@param		dDtInic	Data inicial para recebimento de documentos
@param		dDtFim		Data final para recebimento de documentos

@author	Leonardo Kichitaro
@since		17/09/2014
@version	P11.8
/*/
//----------------------------------------------------------------------------
Function MA411RecCol( dDtInic, dDtFim, xParam3 )
	
Local oDoc
Local oXML
Local lUsaColab		:= .F.	//Verifica se usa TOTVS Colaboração 2.0 para recebimento
Local lGerPed		:= .T.
Local aDocColFil	:= {}
Local aQueue		:= {"005","025","027"}
Local nLenQueue		:= Len(aQueue)
Local aSm0			:= FWLoadSM0()
Local nSM0			:= 0
Local nI			:= 0
Local nY			:= 0
Local nX			:= 0
Local nZ			:= 0
Local nTag			:= 0
Local nRec			:= 0		// Número de pedidos recebidos
Local nErro			:= 0		// Número de erros ocorridos na recepção de pedidos
Local cXML			:= ""
Local cMsg			:= ""		// Mensagem para gravação no log
Local cCNPJ			:= ""
Local cEmp			:= ""
Local cFil			:= ""
Local cLog			:= ""
Local cError		:= ""	//Mensagem de erro na manipulação do arquivo com XML recebido
Local cWarning		:= ""	//Mensagem de alerta na manipulação do arquivo com XML recebido
Local nCount		:= 0

//Data padrão para recebimento de documentos
Default dDtInic	:= CToD( "01/01/2000" )
Default dDtFim	:= Date()

ConOut( "[COLABORACAO MATA411 PV " + DtoC( date() ) + " - " + time() + " ] " +STR0041+ CRLF )//"JOB Iniciado"

oDoc := ColaboracaoDocumentos():new()
For nY := 1 To nLenQueue
	oDoc:cFlag		:= "0"
	oDoc:cQueue		:= aQueue[nY]
	oDoc:cTipoMov	:= "2"
	
	If oDoc:buscaListaDocumentos()
		If ValType("oDoc:aNomeArq") <> "U" .And. Len(oDoc:aNomeArq) > 0
			aDocColFil := {}
			For nX := 1 To Len(oDoc:aNomeArq)
				oDoc:cNomeArq	:= oDoc:aNomeArq[nX,1]
				oDoc:cFlag		:= "0"
				oDoc:Consultar()
				
				cXml := oDoc:cXmlRet
				nTag := At('</BusinessEvent>',cXml)
				If nTag <> 0
					cXml := SubStr(cXml,nTag+16)
				EndIf
				
				oXML := XMLParser( cXML, "_", @cError, @cWarning )
				
				If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
					
					//----------------------------------------------------------------------------
					// Busca o CNPJ/CPF para verificar no SigaMat e definir empresa/filial
					//----------------------------------------------------------------------------
					If ( XmlChildEx( oXML:_BUSINESSCONTENT, '_VENDORGOVINFO' ) != Nil )
						If ( ValType( oXML:_BUSINESSCONTENT:_VendorGovInfo:_Id ) != 'A' )
							XmlNode2Arr( oXML:_BUSINESSCONTENT:_VendorGovInfo:_Id, '_ID' )
						EndIf
						
						For nI := 1 To Len( oXML:_BUSINESSCONTENT:_VendorGovInfo:_Id )
							If	( oXML:_BUSINESSCONTENT:_VendorGovInfo:_Id[nI]:_Name:Text == "CNPJ" ) .Or.;
									( oXML:_BUSINESSCONTENT:_VendorGovInfo:_Id[nI]:_Name:Text == "CPF" )
								cCNPJ := oXML:_BUSINESSCONTENT:_VendorGovInfo:_Id[nI]:Text
								Exit
							EndIf
						Next( nI )
					EndIf
					
					// Verifica se existe mais de uma filial com mesmo CNPJ, neste caso a validação para importação da nota será feita pela inscricao estadual
					cEmp := ""
					cFil := ""
					For nSM0 := 1 To Len(aSm0)
						If cCNPJ $ aSm0[nSM0][18]
							cEmp := aSm0[nSM0][1]
							cFil := aSm0[nSM0][2]
							Exit
						EndIf
					Next( nSM0 )
					
					If !Empty(cEmp) .And. !Empty(cFil)
						Aadd(aDocColFil,{cEmp,cFil,cCNPJ,oDoc:aNomeArq[nX,1],cXML})
					EndIf
				Else
					cLog := STR0007 + " [ " +oDoc:cNomeArq+ " ] " + CRLF	//"Falha na leitura do arquivo XML recebido."
					cLog += IIf( Empty( cWarning ), cError, cWarning )
					GravarLog( cLog, ProcName() )
				EndIf
				
			Next( nX )
			
			Asort(aDocColFil,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
			For nZ := 1 To Len(aDocColFil)
				//---------------------------------------------------------------
				// Cria semáforo para não ocorrer encavalamento de agendamento e
				//  consequentemente gerar pedidos duplicados
				//---------------------------------------------------------------
				If LockByName( aDocColFil[ nZ, 4 ] )
					lGerPed	:= .T.
					If cEmpAnt <> aDocColFil[nZ][1] .Or. cFilAnt <> aDocColFil[nZ][2]
						RpcClearEnv()	//Limpa ambiente criado
						RpcSetEnv( aDocColFil[nZ][1], aDocColFil[nZ][2], xParam3 )	//Inicializa ambiente
						lUsaColab := UsaColaboracao("6")
						
						//Executa apenas se parametrizado para usar TOTVS Colaboração
						If lUsaColab
							//-- TOTVS Colaboracao 2.0
							lUsaColab := ColCheckUpd()
							If !lUsaColab
								lGerPed	:= .F.
								cLog := STR0037	//"UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0"
								GravarLog( cLog, ProcName() )
							EndIf
						EndIf
					EndIf
					
					If lGerPed
						If ( !MA411GrvDoc( {StrTran(Upper(aDocColFil[nZ][4]),".XML",""),aDocColFil[nZ][5]} ) )
							nErro 	+= 1	//Incrementa quantidade de erros ocorridos
							cMsg 	+= STR0001 + " [" + STR0029 + aDocColFil[nZ][4] + "]" + CRLF	//"Erro na gravação do Pedido de Venda." | "Documento: "
						Else
							oDoc:cNomeArq	:= aDocColFil[nZ][4]
							oDoc:cFlag		:= "1"
							
							oDoc:flegadocumento()
						EndIf
					EndIf
					
					nRec += 1	//Incrementa quantidade de pedidos recebidos
					
				EndIf
			Next( nZ )
			
			//Encerra o recebimento de documentos
			If ( nRec > 0 )
				cMsg += cValToChar(nRec) + " " + STR0002 + CRLF	//"pedido(s) recebido(s)."
			Else
				cMsg += STR0003 + CRLF	//"Nenhum pedido pendente no servidor."
			EndIf
			
			If ( nErro > 0 )
				cMsg += cValToChar(nErro) + " " + STR0004 + CRLF	//"erro(s)."
			EndIf
			
			cMsg += CRLF + "**************************************************************************************************"
			GravarLog( cMsg, ProcName() )
		Else
		    
			ConOut( "[COLABORACAO MATA411 PV " + DtoC( date() ) + " - " + time() + " ] " +STR0039+ CRLF )//"Sem documentos a serem processados!"
		EndIf
	EndIf
	
	// Retira os Locks
	For nCount := 1 To Len( aDocColFil )
		If LockByName( aDocColFil[ nCount, 4 ] )
			UnLockByName( aDocColFil[ nCount, 4 ] )
		EndIf
	Next( nCount )
	
Next( nY )

ConOut( "[COLABORACAO MATA411 PV " + DtoC( date() ) + " - " + time() + " ] " +STR0042+ CRLF )//"JOB Finalizado"

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA411RecDoc
Recebe documentos através do TOTVS Colaboração.

@sample 	MA411RecDoc( dDtInic, dDtFim )
@param		dDtInic	Data inicial para recebimento de documentos
@param		dDtFim		Data final para recebimento de documentos

@author	Danilo Dias
@since		02/10/2012
@version	P11.7
/*/
//----------------------------------------------------------------------------
Function MA411RecDoc( dDtInic, dDtFim )
Local lRet		:= .T.		// Retorno da função

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA411GrvDoc
Grava Pedidos de Venda recebidos via TOTVS Colaboração.

@sample 	MA411GrvDoc( aDocs )
@param		aDoc - Array contendo os dados do documento recebido do TSS
aDoc[1] - cIdTSS
aDoc[2] - cXML

@author	Danilo Dias
@since		02/10/2012
@version	P11.7
/*/
//----------------------------------------------------------------------------
Function MA411GrvDoc( aDocs )
	
Local aArea			:= GetArea()
Local lRet			:= .T.
Local nI			:= 1
Local nHandle		:= 0
Local aErroAuto		:= {}	//Mensagem de erro da ExecAuto
Local cCaminho		:= ""	//Caminho do arquivo com conteúdo XML
Local cArquivo		:= ""	//Nome do arquivo que será criado para guardar o XML
Local cPedCliLog	:= ""	//Carrega o conteudo do C6_PEDCLI
Local cLog			:= ""	//Texto a ser gravado no arquivo de log
Local cXML			:= ""	//XML recebido do TSS
Local oXML			:= Nil	//Objeto com estrutura XML
Local cError		:= ""	//Mensagem de erro na manipulação do arquivo com XML recebido
Local cWarning		:= ""	//Mensagem de alerta na manipulação do arquivo com XML recebido
Local aMaster		:= {}	//Array com dados da Master para atualização do model
Local aDetail		:= {}	//Array com dados da Detail para atualização do model
Local cTESPadrao	:= SuperGetMV( "MV_FATTSPD", .F., "" )
Local nOpc			:= 3
Local lUsaColab		:= UsaColaboracao("6")
Local cErro 		:= ""
Local cFileErro		:= GetSrvProfString( 'StartPath', '' ) + "\XML\deliveryschedule_SalesOrder.log"
Local nTamMax		:= 1040000 //Quase 1MB em Bytes
Local nTamLog 		:= 0
Local lMa411Grv		:= ExistBlock( "MA411Grv" ) //Ponto de entrada para manipular os dados do cabeçalho e itens do pedido antes da geração do pedido.
Local aMa411Grv		:= {}
Local cRetEvent		:= ""
Local nXDockin		:= SuperGetMV( "MV_CROSFAT", .F., 1 )
Local cNomeAuto		:= ""
Local cCrosDocErro	:= ""

Private lMsErroAuto := .F.

cCaminho	:= GetSrvProfString( 'StartPath', '' ) + "XML"

//----------------------------------------------------------
// Verifica se existe o caminho para salvar mensagens
// recebidas, se não existir cria a pasta no server.
//----------------------------------------------------------
If !lUsaColab
	If ( !ExistDir( cCaminho ) )
		If ( !MakeDir( cCaminho ) == 0 )
			cLog := STR0009 + CRLF + Str(FError())	//"Falha na criação da pasta de entrada de documentos no servidor. Verifique as permissões de acesso."
			GravarLog( cLog, ProcName() )
			Return .F.
		EndIf
	EndIf
EndIf

//----------------------------------------------------------
// Efetua a gravação dos documentos recebidos
//----------------------------------------------------------
If !lUsaColab
	cArquivo := cCaminho + "Order_" + AllTrim( aDocs[1] ) + "_" + DToS( Date() ) + StrTran( Time(), ":" ) + ".xml"
	
	nHandle := FCreate( cArquivo )
EndIf

//Valida a criação do arquivo XML
If ( nHandle == -1 )
	If (lLog )
		cLog := STR0006 + "[ " +aDocs[ 1 ]+ " ]" + CRLF + Str(FError())	+ CRLF		//"Falha na criação do arquivo XML. Verifique a existência da pasta de destino e suas permissões."
		GravarLog( cLog, ProcName() )
	EndIf
Else
	cXML := aDocs[2]
	If !lUsaColab
		FWrite( nHandle, cXML )
		FClose( nHandle )
	EndIf
	
	oXML := XMLParser( cXML, "_", @cError, @cWarning )
	
	//Valida se não houve erro no parse
	If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
		
		//---------------------------------------------------------------------
		// Lê dados do XML e monta arrays para gerar o pedido via ExecAuto
		//---------------------------------------------------------------------
		lRet := MA411LeXML( oXML, @aMaster, @aDetail, @nOpc, aDocs[ 1 ], @cPedCliLog )
		
		If ( lRet )
			
			//Grava o pedido via ExecAuto
			//Inicia transação
			Begin Transaction
				
				If lMa411Grv
					aMa411Grv := ExecBlock( "MA411GRV", .F., .F., { aMaster, aDetail, nOpc, cXML } )
					aMaster := aMa411Grv[ 01 ]
					aDetail := aMa411Grv[ 02 ]
				Endif

				If (nXDockin == 0 .Or. nXDockin > 3)	//Se o parâmetro MV_CROSFAT estiver em branco
					lRet := .F.
					cCrosDocErro := STR0058 + cValToChar(nXDockin) + STR0059 //"Valor do parâmetro MV_CROSFAT: " + nXDockin + " Incorreto, favor informar 1, 2 ou 3! "
				ElseIf nXDockin == 1	//Se não utiliza a tag CrossDocking
					MSExecAuto( { |x, y, z| MATA410( x, y, z ) }, aMaster, aDetail, nOpc )
				Else
					If IsCrossDk(oXML)
						If nXDockin == 2
							MA411ProgE( oXML, @aMaster, @aDetail,"" ,nXDockin)
						ElseIf nXDockin == 3
							MA411PedCr(oXML,aMaster,aDetail,nOpc)
						Else
							lRet := .F.
							cCrosDocErro := STR0058 + cValToChar(nXDockin) + STR0059 //"Valor do parâmetro MV_CROSFAT: " + nXDockin + " Incorreto, favor informar 1, 2 ou 3! "
						EndIf
					Else
						lRet := .F.
						cCrosDocErro := STR0060 //"Informe um xml contendo tag CrossDocking: Tag insexistente! "
					EndIf
				EndIf

				If lRet .AND. (!lMsErroAuto)
					//Confirma o documento junto ao servidor TSS
					If !lUsaColab
						If ( MA411Conf( aDocs[1] ) >= 0 )
							
							cLog := STR0008 + aDocs[1] + CRLF	//"Pedido gravado com sucesso. Id: "
							GravarLog( cLog, ProcName() )
							
						Else
							lRet := .F.
							DisarmTransaction()
							cLog := STR0021 + aDocs[1] + CRLF	//'Falha na confirmação do documento! Pedido não gravado.'
							GravarLog( cLog, ProcName() )
						EndIf
					Else
						cLog := STR0008 + aDocs[1] + CRLF + "Número do Pedido: " + AllTrim(SC5->C5_NUM) + CRLF + "Número do Pedido do Cliente: " + cPedCliLog + CRLF	//"Pedido gravado com sucesso. Id: "
						GravarLog( cLog, ProcName() )
					EndIf
				Else
					aErroAuto := GetAutoGRLog()
					cNomeAuto := NomeAutoLog()
					If ValType(cNomeAuto) <> "C"
						cNomeAuto := CriaTrab(,.F.)+".LOG"
					EndIf
					//-------------------------------------------------------------------------------------
					// Abre arquivo de log de erro de rotina automática
					//-------------------------------------------------------------------------------------
					If ( nHandle := FOpen( cFileErro, FO_READWRITE ) ) > 0
						//-------------------------------------------------------------------------------------
						// Verifica o tamanho do arquivo, cria um arquivo novo se ultrapassar 1 Mb
						//-------------------------------------------------------------------------------------
						nTamLog := Len( MemoRead( cFileErro, .T. ) )
						If nTamLog >= nTamMax
							FClose( nHandle )
							If( FErase( cFileErro ) ) != -1
								Conout( I18N( STR0034 +"#1#"+ STR0035, { cFileErro } )  )//"O arquivo de log" #### " ultrapassou o tamanho maximo de 1MB. Arquivo deletado e criado novo. "
								If ( FCreate( cFileErro ) ) > 0
									
									cErro := "[ "
									cErro += I18N( STR0032 + "#1 - #2" + STR0033, { DToc( Date() ), Time() } ) //"O arquivo anterior ultrapassou o tamanho máximo de 1 mb, sendo assim, o arquivo foi deletado e foi criado um novo em: " ####". O histórico não será perdido, se por algum motivo o xml não foi processado o status do mesmo na tabela CKO será igual a '0', isto significa que o schedule tentará processar novamente este registro e senão conseguir processá-lo um novo log será gravado no arquivo. "
									cErro +=  " ]" + CRLF + CRLF
									cErro += "[ " +aDocs[1]+ " ]"
									cErro += CRLF + CRLF
									cErro += MemoRead( cNomeAuto )
									
									FWrite( nHandle, cErro + CRLF, Len( cErro ) + 2 )
									
									FClose( nHandle )
								EndIf
							EndIf
						EndIF
						
						//-------------------------------------------------------------------------------------
						// Posiciona no final do arquivo para nao sobrescrever os dados que já foram gerados
						//-------------------------------------------------------------------------------------
						FSeek( nHandle, 0, 2 )
						cErro := "[ " +aDocs[1]+ " ]"
						cErro += CRLF + CRLF
						If !Empty(cCrosDocErro)
							cErro += cCrosDocErro
							cErro += CRLF
						EndIf
						cErro += MemoRead( cNomeAuto )
						
						FWrite( nHandle, cErro + CRLF, Len( cErro ) + 2 )
						
						FClose( nHandle )
						
					ElseIf ( nHandle := FCreate( cFileErro ) ) > 0
						cErro := "[ " +aDocs[1]+ " ]"
						cErro += CRLF + CRLF
						If !Empty(cCrosDocErro)
							cErro += cCrosDocErro
							cErro += CRLF
						EndIf
						cErro += MemoRead( cNomeAuto )
						
						FWrite( nHandle, cErro + CRLF )
						
						FClose( nHandle )
					Else
						ConOut( "[ " +STR0036+ " ]" + CRLF )//"Falha na criação do arquivo  de erro de rotina automática."
					EndIf
					
					DisarmTransaction()
					lRet := .F.
					cLog := "[MSExecAuto - MATA410]" + CRLF
					cRetEvent := cLog
					
					For nI := 1 To Len( aErroAuto )
						cLog += aErroAuto[nI] + CRLF
					Next nI
					
					If Len(aErroAuto) == 0
						cLog 		+= cErro + CRLF
						cRetEvent	+= "[ " +aDocs[1]+ " ]"
						cRetEvent	+= CRLF + CRLF
						cRetEvent	+= MostraErro( "EventViewer","" )
					EndIf
					
					GravarLog( cLog, ProcName())
				EndIf
			End Transaction
		EndIf
		
		//Trata erro na leitura do XML recebido
	Else
		lRet := .F.
		cLog := STR0007 + CRLF	//"Falha na leitura do arquivo XML recebido."
		cLog += IIf( Empty( cWarning ), cError, cWarning )
		GravarLog( cLog, ProcName() )
	EndIf
	
EndIf

If lUsaColab
	EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cRetEvent, .T. )
EndIf

RestArea(aArea)

Return lRet


//----------------------------------------------------------------------------
/*/{Protheus.doc} MA411LeXML
Lê o arquivo XML e gera os arrays de cabeçalho e itens para a ExecAuto.

@sample 	MA411LeXML( oXML, aMaster, aDetail )
@param		oXML		Objeto com conteúdo do XML parseado.
@param		aMaster	Array passado por referência para receber o cabeçalho do
Pedido de Venda.
@param		aDetail	Array passado por referência para receber os itens do
Pedido de Venda.
aDocs[ 1 ] Nome do XML para a composição de mensagens

@author	Danilo Dias
@since		03/10/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Function MA411LeXML( oXML, aMaster, aDetail, nOpc, aDocs, cPedCliLog )

Local aArea			:= GetArea()
Local aAreaSA4		:= SA4->( GetArea() )
Local aAreaSC6		:= SC6->( GetArea() )
Local aAreaSA3		:= SA3->( GetArea() )
Local lUsaColab 	:= UsaColaboracao("6")
Local nI			:= 0
Local nJ			:= 0
Local nA			:= 0
Local nContAux   	:= 0
Local cLog			:= ''
Local lLibAuto		:= SuperGetMV( 'MV_FATLBAT', .F., .F. )
Local cTESPadrao	:= SuperGetMV( 'MV_FATTSPD', .F., '' )

Local nFuncao		:= 0			//Identifica a quê a mensagem se destina
Local nObjetivo		:= 0			//Identifica o objetivo do Pedido (Compra ou Venda)
Local cTipoPedido	:= ''			//Identifica o tipo de Pedido
Local cPedCli		:= ''			//Número do Pedido do cliente
Local cPedEmiss		:= ''			//Número do Pedido do emissor
Local dEmissao		:= Date()		//Data de emissão do Pedido
Local dEntrega		:= Date()		//Data de entrega do Pedido
Local cHrEntrega	:= ''			//Hora de entrega do Pedido
Local cTipoFrete	:= ''			//Tipo de Frete
Local nValorFrete	:= 0			//Valor do Frete
Local nPesoLiq		:= 0			//Peso Líquido
Local nPesoBruto	:= 0			//Peso Bruto
Local nPesoTara		:= 0			//Peso Tara
Local nVolumes		:= 0			//Número de Volumes
Local nTipoCli		:= 0 			//Tipo de Cliente
Local nValorSeg		:= 0			//Valor do Seguro
Local cMoeda		:= ''			//Moeda
Local cTabPreco		:= ''			//Tabela de Preços
Local cContrato		:= ''			//Número do contrato com o cliente
Local cCondPag		:= ''			//Condição de Pagamento
Local cTipoPreco	:= ''			//Tipo de Preço
Local aDescontos	:= {}			//Descontos
Local nDescFin		:= 0			//Desconto Financeiro
Local nTotalDesc	:= 0			//Total de Desconto
Local cMensagemNF	:= ''			//Mensagem da Nota Fiscal
Local cIFCliente	:= ''			//Inscrição Federal do cliente
Local cCodCliente	:= ''			//Código do cliente
Local cLojCliente	:= ''			//Loja do Cliente
Local cIFFornec		:= ''			//Inscrição Federal do fornecedor
Local cIFTransp		:= ''			//Inscrição Federal do transportador
Local cCodTransp	:= ''			//Código do transportador
Local cIFCliEnt		:= ''			//Inscrição Federal do cliente de entrega
Local cCliEnt		:= ''			//Código do cliente para entrega
Local cLojEnt		:= ''			//Loja do cliente para entrega

Local cTipoCod		:= ''			//Tipo de código do produto
Local cProduto		:= ''			//Código do Produto
Local cTES			:= ''			//TES utilizada para o item
Local nQuantidade	:= 0			//Quantidade Pedida
Local nQuantBonif	:= 0			//Quantidade bonificada do item
Local nTotBrutoIt	:= 0			//Valor total bruto do item
Local nTotLiqIt		:= 0			//Valor total líquido do item
Local nValorUnLiq	:= 0			//Preço unitário líquido do item
Local nValorUnBru	:= 0			//Preço unitário bruto do item
Local nVlrDescIt	:= 0			//Valor de desconto sobre o item
Local nPercDescIt	:= 0			//Percentual de desconto sobre o item
Local nPerDesc		:= 0			//Percentual de desconto sobre o item em rotina crossdocking
Local nVlrBonIt		:= 0			//Valor de bonificação do item
Local nPercBonIt	:= 0			//Percentual de bonificação do item
Local nVlrUnit		:= 0			//Valor unitário
Local nValDesc		:= 0			//Valor de desconto do item
Local cContratoIt	:= ''			//Número do Contrato do item
Local cVendedor		:= ''			//Código do Vendedor
Local cPrdDif		:= ""
Local cNewProd		:= ""
Local lMA411PRD		:=	ExistBlock("MA411PRD")

Local nValTotBru	:= 0			//Valor bruto total do pedido
Local nValTotLiq	:= 0			//Valor líquido total do pedido
Local lEntFat		:= SuperGetMV( "MV_CENTFAT", .F., .F. ) //Parâmetro que determina se o cliente de entrega será considerado como cliente de faturamento no SC5.
Local lPrdDif		:= SuperGetMV( "MV_FATEDIP", .F., .F. ) //Parâmetro que determina que a busca do produto seja efetuada de forma diferenciada, independente do tipo do produto.

Local xTemp			:= Nil			//Variável temporária de uso geral
Local oXMLContent	:= Nil
Local oXMLItens		:= Nil
Local oXMLSummary	:= Nil

Local lMA411Cli		:= ExistBlock( "MA411Cli" ) //Ponto de entrada para manipular o cliente de faturamento através de tag específica
Local cPECli		:= ""
Local cCliAl		:= GetNextAlias()
Local cTMPACP		:= GetNextAlias()

Default aMaster := {}
Default aDetail := {}
Default aDocs   := {}

If ( ValType( oXML ) == "O" )
	//Cria variáveis com estrutura do XML para facilitar a codificação
	If lUsaColab
		oXMLContent	:= oXML:_BusinessContent
		oXMLItens	:= oXMLContent:_SalesOrderItens
	Else
		oXMLContent	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
		oXMLItens	:= oXMLContent:_SalesOrderItens
	EndIf
	
	//Abre as tabelas usadas na função
	DbSelectArea('SA1')	//Clientes
	DbSelectArea('SA4')	//Transportadoras
	DbSelectArea('SE4')	//Condição de Pagamento
	DbSelectArea('DA0')	//Tabela de Preços
	DbSelectArea('SB1')	//Cadastro de Produtos
	DbSelectArea('SA3')	//Vendedores
	DbSelectArea('SC6')	//Itens do Pedido de Venda
	
	//-------------------------------------------------------------------------
	// Cabeçalho do Pedido
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	// Lê a função da mensagem
	// 9-Original
	// 16-Proposta
	// 31-Cópia
	// 42-Confirmação
	// 46-Provisória
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_FUNCMSGORDER' ) != Nil )
		nFuncao := Val( oXMLContent:_funcmsgorder:Text )
	EndIf
	
	//-------------------------------------------------------------------------
	// Objetivo do Pedido
	// 1-Compra
	// 2-Venda
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_ORDERPURPOSE' ) != Nil )
		nObjetivo := Val( oXMLContent:_OrderPurpose:Text )
	EndIf
	
	//-------------------------------------------------------------------------
	// Tipo de Pedido (C5_TIPO)
	// 000-Pedido com condições especiais
	// 001-Pedido Normal
	// 002-Pedido de Mercadorias Bonificadas
	// 003-Pedido de Consignação
	// 004-Pedido Vendedor
	// 005-Pedido Comprador
	// 006-Pedido de Demonstração
	// 007-Programação de entrega
	// 008-Contrato fornecimento
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_ORDERTYPECODE' ) != Nil )
		cTipoPedido := oXMLContent:_ordertypecode:Text
	EndIf
	
	//-------------------------------------------------------------------------
	// Número do Pedido do emissor, quando for diferente do comprador (C6_PEDCLI)
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_CUSTOMERORDERID' ) != Nil )
		cPedEmiss := oXMLContent:_CustomerOrderId:Text
	EndIf
	
	//-------------------------------------------------------------------------
	// Data do pedido (C5_EMISSAO)
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_REGISTERDATE' ) != Nil )
		dEmissao := StoD( StrTran( oXMLContent:_RegisterDate:Text, '-' ) )
	EndIf
	
	//-------------------------------------------------------------------------
	// Número do Pedido do comprador (C6_PEDCLI)
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_ORDERID' ) != Nil )
		cPedCli := oXMLContent:_OrderId:Text
	EndIf
	
	//-------------------------------------------------------------------------
	// Data e hora de entrega do item (C6_ENTREG e C6_HORENT)
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_DHINIDELIVERY' ) != Nil )
		xTemp 		:= oXMLContent:_dhinidelivery:Text
		dEntrega	:= StoD( StrTran( SubStr( xTemp, 1, 10 ), "-" ) )
		cHrEntrega	:= StrTran( SubStr( xTemp, 12, 5 ), ":" )
	EndIf
	
	//-------------------------------------------------------------------------
	// Tipo de Frete (C5_TPFRETE)
	// 1-CIF (Frete por conta do vendedor)
	// 2-FOB (Frete por conta do comprador)
	// 3-SFT (Sem frete)
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_FREIGHTTYPE' ) != Nil )
		Do Case
			Case oXMLContent:_FreightType:Text == '1'
				cTipoFrete := 'C'
			Case oXMLContent:_FreightType:Text == '2'
				cTipoFrete := 'F'
			OtherWise
				cTipoFrete := 'C'
		EndCase
	EndIf
	
	//-------------------------------------------------------------------------
	// Valor do Frete (C5_FRETE)
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_FREIGHTVALUE' ) != Nil )
		nValorFrete := Val( oXMLContent:_FreightValue:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Mensagem da Nota Fiscal (C5_MENNOTA)
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_INVOICEMESSAGES' ) != Nil )
		If ( XmlChildEx( oXMLContent:_InvoiceMessages, '_INVOICEMESSAGE' ) != Nil )
			
			//Transforma em array quando o nó de mensagens tiver apenas um item
			If ( ValType( oXMLContent:_InvoiceMessages:_InvoiceMessage ) != 'A' )
				XmlNode2Arr( oXMLContent:_InvoiceMessages:_InvoiceMessage, "_INVOICEMESSAGE")
			EndIf
			
			cMensagemNF := ''
			For nI := 1 To Len( oXMLContent:_InvoiceMessages:_InvoiceMessage )
				
				If ( XmlChildEx( oXMLContent:_InvoiceMessages, '_INVOICEMESSAGE' ) != Nil )
					cMensagemNF += oXMLContent:_InvoiceMessages:_InvoiceMessage[nI]:Text
				EndIf
				
			Next nI
			
		EndIf
	EndIf
	
	//----------------------------------------------------------------------------
	// Peso Líquido (C5_PESOL)
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_NETWEIGHT' ) != Nil )
		nPesoLiq := Val( oXMLContent:_NetWeight:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Peso Bruto (C5_PBRUTO)
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_GROSSWEIGHT' ) != Nil )
		nPesoBruto := Val( oXMLContent:_GrossWeight:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Peso Tara
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_TAREWEIGHT' ) != Nil )
		nPesoTara := Val( oXMLContent:_TareWeight:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Número de volumes (C5_VOLUME1)
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_NUMBEROFVOLUMES' ) != Nil )
		nVolumes := Val( oXMLContent:_NumberOfVolumes:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Tipo de cliente (C5_TIPOCLI)
	// 1-Contribuinte ICMS | 2-Não contribuinte ICMS
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_FINALITY' ) != Nil )
		nTipoCli := Val( oXMLContent:_Finality:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Valor do Seguro (C5_SEGURO)
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_INSURANCEVALUE' ) != Nil )
		nValorSeg := Val( oXMLContent:_InsuranceValue:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Moeda (C5_MOEDA)
	// 1-Real
	// 2-Dolar
	// 3-UFIR
	// 4-EURO
	// 5-IENE
	// 6-Outras
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_CURRENCYID' ) != Nil )
		cMoeda := oXMLContent:_CurrencyId:Text
		
		//Faz um de/para utilizando a tabela XXF
		If ( FindFunction( 'CFGA070INT' ) )
			cMoeda := CFGA070INT( 'TSS', 'SM2', 'MOEDA', cMoeda )
		EndIf
		
		//Se não houver moeda,
		If ( Empty(cMoeda) ) .Or. ( cMoeda == Nil )
			cMoeda := '1'
		EndIf
		
	EndIf
	
	//----------------------------------------------------------------------------
	// Número do contrato (C5_CONTRA)
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_CONTRACTNUMBER' ) != Nil )
		cContrato := oXMLContent:_contractnumber:Text
	EndIf
	
	//----------------------------------------------------------------------------
	// Cliente
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_CUSTOMERGOVINFO' ) != Nil )
		
		If ( ValType( oXMLContent:_CustomerGovInfo:_Id ) != 'A' )
			XmlNode2Arr( oXMLContent:_CustomerGovInfo:_Id, '_ID' )
		EndIf
		
		For nI := 1 To Len( oXMLContent:_CustomerGovInfo:_Id )
			If	( oXMLContent:_CustomerGovInfo:_Id[nI]:_Name:Text == "CNPJ" ) .Or.;
					( oXMLContent:_CustomerGovInfo:_Id[nI]:_Name:Text == "CPF" )
				cIFCliente := oXMLContent:_CustomerGovInfo:_Id[nI]:Text
				Exit
			EndIf
		Next nI
		
		//----------------------------------------------------------------------------
		// Ponto de entrada para alterar o cliente de faturamento com tag específica
		//----------------------------------------------------------------------------
		If lMA411Cli
			cPECli := ExecBlock( "MA411Cli",.F.,.F., { oXMLContent } )
			If ValType( cPECli ) == 'C'
				cIFCliente := cPECli
			EndIf
		EndIf
		
		//----------------------------------------------------------------------------
		// Faz query para saber se existe mais de um cliente com o mesmo CGC, se
		// existir, seleciona apenas o cadastro ativo
		//----------------------------------------------------------------------------
		BeginSQL alias cCliAl
			SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_MSBLQL
			
			FROM %Table:SA1% SA1
			
			WHERE SA1.A1_FILIAL = %xFilial:SA1% AND
			SA1.A1_CGC = %Exp:cIFCliente% AND
			A1_MSBLQL = '2' AND SA1.%NotDel%
			
			ORDER BY A1_COD
		EndSQL
		
		If ( cCliAl )->( !Eof() )
			
			//-----------------------------------------------------------------------------------
			// Independente da quantidade de clientes ativos com o mesmo CGC o pedido é enviado
			// para o primeiro registro encontrado
			//-----------------------------------------------------------------------------------
			cCodCliente := ( cCliAl )->A1_COD
			cLojCliente := ( cCliAl )->A1_LOJA
			
		Else
			If !lEntFat
				cLog := STR0011 + " [ " +aDocs+ " ]" + CRLF	//"Falha na gravação! Cliente não Encontrado."
				If lUsaColab .And. !Empty(cLog)
					EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cLog, .T. )
				EndIf
				GravarLog( cLog, ProcName() )
				Return .F.
			EndIf
		EndIf
		
		( cCliAl )->( DbCloseArea() )
		
	EndIf
	
	//----------------------------------------------------------------------------
	// Cliente Entrega
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_DELIVERYCUSTOMERGOVERNMENTALINFORMATION' ) != Nil )
		
		If ( ValType( oXMLContent:_DeliveryCustomerGovernmentalInformation:_Id ) != 'A' )
			XmlNode2Arr( oXMLContent:_DeliveryCustomerGovernmentalInformation:_Id, '_ID' )
		EndIf
		
		For nI := 1 To Len( oXMLContent:_DeliveryCustomerGovernmentalInformation:_Id )
			If	( oXMLContent:_DeliveryCustomerGovernmentalInformation:_Id[nI]:_Name:Text == "CNPJ" ) .Or.;
					( oXMLContent:_DeliveryCustomerGovernmentalInformation:_Id[nI]:_Name:Text == "CPF" )
				cIFCliEnt := oXMLContent:_DeliveryCustomerGovernmentalInformation:_Id[nI]:Text
				Exit
			EndIf
		Next nI
		
		//----------------------------------------------------------------------------
		// Faz query para saber se existe mais de um cliente com o mesmo CGC, se
		// existir, seleciona apenas o cadastro ativo
		//----------------------------------------------------------------------------
		BeginSQL alias cCliAl
			SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_MSBLQL
			
			FROM %Table:SA1% SA1
			
			WHERE SA1.A1_FILIAL = %xFilial:SA1% AND
			SA1.A1_CGC = %Exp:cIFCliEnt% AND
			A1_MSBLQL = '2' AND SA1.%NotDel%
			
			ORDER BY A1_COD
		EndSQL
		
		If ( cCliAl )->( !Eof() )
			
			//-----------------------------------------------------------------------------------
			// Independente da quantidade de clientes ativos com o mesmo CGC o pedido é enviado
			// para o primeiro registro encontrado
			//-----------------------------------------------------------------------------------
			cCliEnt := ( cCliAl )->A1_COD
			cLojEnt := ( cCliAl )->A1_LOJA
			
		Else
			cLog := STR0014 + " [ " +aDocs+ " ]" + CRLF	//"Cliente para entrega não Encontrado. Será usado o mesmo cliente do pedido."
			GravarLog( cLog, ProcName() )
			If lEntFat .And. Empty(cCodCliente)
				If lUsaColab .And. !Empty(cLog)
					EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cLog, .T. )
				EndIf
				Return .F.
			EndIf
		EndIf
	EndIf
	
	// Considera o cliente de entrega como cliente de faturamento
	If lEntFat .And. !Empty( cCliEnt ) .And. !Empty( cLojEnt )
		//Altera o conteúdo da variável p/ considerar as demais validações
		cCodCliente := cCliEnt
		cLojCliente := cLojEnt
	EndIf
	
	//----------------------------------------------------------------------------
	// Fornecedor
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_VENDORGOVINFO' ) != Nil )
		
		If ( ValType( oXMLContent:_VendorGovInfo:_Id ) != 'A' )
			XmlNode2Arr( oXMLContent:_VendorGovInfo:_Id, '_ID' )
		EndIf
		
		For nI := 1 To Len( oXMLContent:_VendorGovInfo:_Id )
			If	( oXMLContent:_VendorGovInfo:_Id[nI]:_Name:Text == "CNPJ" ) .Or.;
					( oXMLContent:_VendorGovInfo:_Id[nI]:_Name:Text == "CPF" )
				cIFFornec := oXMLContent:_VendorGovInfo:_Id[nI]:Text
				Exit
			EndIf
		Next nI
		
		If ( SM0->M0_CGC != cIFFornec )
			cLog := STR0012 + " [ " +aDocs+ " ]" + CRLF	//"Falha na gravação! CNPJ do fornecedor não pertence à empresa."
			If lUsaColab .And. !Empty(cLog)
				EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cLog, .T. )
			EndIf
			GravarLog( cLog, ProcName() )
			Return .F.
		EndIf
		
	EndIf
	
	//----------------------------------------------------------------------------
	// Transportadora
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_CARRIERGOVINFO' ) != Nil )
		
		If ( ValType( oXMLContent:_CarrierGovInfo:_Id ) != 'A' )
			XmlNode2Arr( oXMLContent:_CarrierGovInfo:_Id, '_ID' )
		EndIf
		
		For nI := 1 To Len( oXMLContent:_CarrierGovInfo:_Id )
			If	( oXMLContent:_CarrierGovInfo:_Id[nI]:_Name:Text == "CNPJ" ) .Or.;
					( oXMLContent:_CarrierGovInfo:_Id[nI]:_Name:Text == "CPF" )
				cIFTransp := oXMLContent:_CarrierGovInfo:_Id[nI]:Text
				Exit
			EndIf
		Next nI
		
		If Empty(cIFTransp)
			SA1->(DbSetOrder(3))	//A1_FILIAL + A1_CGC
			//Procura cliente pelo CNPJ/CPF para pegar transportadora
			If ( SA1->( MsSeek( xFilial('SA1') + cIFCliente ) ) )
				cCodTransp := SA1->A1_TRANSP
			EndIf
		Else
			SA4->(DbSetOrder(3))	//A4_FILIAL + A4_CGC
			SA4->(DbGoTop())
			//Procura transportadora pelo CNPJ/CPF
			If ( SA4->( MsSeek( xFilial('SA4') + cIFTransp ) ) )
				cCodTransp := SA4->A4_COD
			EndIf
		EndIf
				
		If Empty(cCodTransp)
			cLog := STR0013 + CRLF	//"Transportadora não encontrada! Campo ficará em branco no pedido."
			GravarLog( cLog, ProcName() )
		EndIf
		
	EndIf
	
	//----------------------------------------------------------------------------
	// Tabela de Preços (C5_TABELA)
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_PRICETABLENUMBER' ) != Nil )
		cTabPreco := oXMLContent:_pricetablenumber:Text
	EndIf
	
	//Se não foi passada uma tabela ou a tabela não foi encontrada,
	//pega a tabela padrão no cadastro do cliente
	DA0->( DbSetOrder(1) )	//DA0_FILIAL + DA0_CODTAB
	DA1->( DbSetOrder(1) )	//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
	
	If ( Empty( cTabPreco ) ) .Or. ( !DA0->( MsSeek( xFilial('DA0') + cTabPreco ) ) )
		SA1->( DbSetOrder(1) )	//A1_FILIAL + A1_COD + A1_LOJA
		
		If ( SA1->( MsSeek( xFilial('SA1') + cCodCliente + cLojCliente ) ) )
			cTabPreco := SA1->A1_TABELA
		Else
			cLog := STR0015 + CRLF	//"Tabela de preços não informada ou não está cadastrada."
			GravarLog( cLog, ProcName() )
		EndIf
	EndIf
	
	//----------------------------------------------------------------------------
	// Condição de pagamento
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_PAYMENTTERMCODE' ) != Nil )
		cCondPag := oXMLContent:_PaymentTermCode:Text
	EndIf
	
	//Se não foi passada uma condição ou a condição não foi encontrada,
	//pega a condição padrão no cadastro do cliente
	SE4->( DbSetOrder(1) )	//E4_FILIAL + E4_CODIGO
	
	If ( Empty( cCondPag ) ) .Or. ( !SE4->( MsSeek( xFilial('SE4') + cCondPag ) ) )
		SA1->( DbSetOrder(1) )	//A1_FILIAL + A1_COD + A1_LOJA
		
		If ( SA1->( MsSeek( xFilial('SA1') + cCodCliente + cLojCliente ) ) )
			cCondPag := SA1->A1_COND
		Else
			cLog := STR0016 + " [ " +aDocs+ " ]" + CRLF	//"Condição de pagamento não informada ou não está cadastrada."
			GravarLog( cLog, ProcName() )
		EndIf
	EndIf
	
	//----------------------------------------------------------------------------
	// Descontos
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_DISCOUNTS' ) != Nil )
		
		//Transforma em array quando o nó de entrega tiver apenas um item
		If ( ValType( oXMLContent:_Discounts:_Discount ) != 'A' )
			XmlNode2Arr( oXMLContent:_Discounts:_Discount, "_DISCOUNT")
		EndIf
		
		For nI := 1 To Len( oXMLContent:_Discounts:_Discount )
			
			If ( XmlChildEx( oXMLContent:_Discounts, '_DISCOUNT' ) != Nil )
				AAdd( aDescontos, Val( oXMLContent:_Discounts:_Discount[nI]:Text ) )
			EndIf
			
		Next nI
		
	EndIf
	
	//----------------------------------------------------------------------------
	// Desconto Financeiro
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_FINANCIALDISCOUNT' ) != Nil )
		nDescFin := Val( oXMLContent:_FinancialDiscount:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Total de Desconto
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_TOTALDISCOUNT' ) != Nil )
		nTotalDesc := Val( oXMLContent:_TotalDiscount:Text )
	EndIf
	
	//----------------------------------------------------------------------------
	// Tipo de Preço
	// 1-Preço Informado
	// 2-Preço Data de Implantação
	// 3-Preço Data de Faturamento
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_ORDERPRICETYPE' ) != Nil )
		cTipoPreco := oXMLContent:_orderpricetype:Text
	EndIf
	
	//----------------------------------------------------------------------------
	// Vendedor
	//----------------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_SELLERCODE' ) != Nil )
		cVendedor := oXMLContent:_SellerCode:Text
	EndIf
	
	//----------------------------------------------------------------------------
	// Monta array com dados de cabeçalho do pedido
	//----------------------------------------------------------------------------
	AAdd( aMaster, { 'C5_FILIAL'   	, xFilial('SC5')	, Nil } )	//Filial
	AAdd( aMaster, { 'C5_TIPO'		, 'N'				, Nil } )	//Tipo de Pedido
	AAdd( aMaster, { 'C5_CLIENTE'  	, cCodCliente		, Nil } )	//Código do cliente
	AAdd( aMaster, { 'C5_LOJACLI'  	, cLojCliente		, Nil } )	//Loja do cliente
	
	If ( !Empty( cCliEnt ) )
		AAdd( aMaster, { 'C5_CLIENT' , cCliEnt, Nil } )	//Código do cliente para entrega
		AAdd( aMaster, { 'C5_LOJAENT', cLojEnt, Nil } )	//Loja do cliente
	EndIf
	
	If ( !Empty( cCodTransp ) )
		AAdd( aMaster, { 'C5_TRANSP' , cCodTransp, Nil } )	//Código da transportadora
	EndIf

	If ( !Empty( cTipoFrete ) )
		AAdd( aMaster, { 'C5_TPFRETE', cTipoFrete, Nil } )	//Tipo de Frete
	EndIf
	
	//Valida moeda, se for inválida não passa para ExecAuto
	If ( !Empty(cMoeda) ) .And. ( cMoeda != Nil ) .And. ( Valtype( cMoeda ) == 'C' )
		AAdd( aMaster, { 'C5_MOEDA', Val( cMoeda ), Nil } )	//Moeda do Pedido	]
	EndIf
	
	AAdd( aMaster, { 'C5_CONDPAG', cCondPag	, Nil } )	//Condição de pagamento
	AAdd( aMaster, { 'C5_TABELA' , cTabPreco	, Nil } )	//Tabela de Preços
	
	If ( !Empty(cVendedor) )
		AAdd( aMaster, { 'C5_VEND1'  , cVendedor	, Nil } )	//Vendedor
	Else
		SA1->( DbSetOrder(1) )	//A1_FILIAL + A1_COD + A1_LOJA
		If ( SA1->( MsSeek( xFilial('SA1') + cCodCliente + cLojCliente ) ) )
			cVendedor := SA1->A1_VEND
			AAdd( aMaster, { 'C5_VEND1'  , cVendedor	, Nil } )	//Vendedor
		EndIf
	EndIf
	
	AAdd( aMaster, { 'C5_EMISSAO', dDataBase	, Nil } )	//Data de Emissão
	AAdd( aMaster, { 'C5_ORIGEM' , 'MATA411'	, Nil } )	//Origem do Pedido
	AAdd( aMaster, { 'C5_MENNOTA', cMensagemNF	, Nil } )	//Mensagem da NF
	If !Empty(aDescontos)
		For nA := 1 to Len(aDescontos)
			AAdd( aMaster, { 'C5_DESC' + cValToChar(nA)  , aDescontos[nA]	, Nil } )	//Desconto x
		Next
	EndIf
	
	//-------------------------------------------------------------------------
	// Itens do Pedido
	//-------------------------------------------------------------------------
	If ( XmlChildEx( oXMLItens, '_ITEM' ) != Nil )
		
		//Transforma em array quando o nó de entrega tiver apenas um item
		If ( ValType( oXMLItens:_Item ) != 'A' )
			XmlNode2Arr( oXMLItens:_Item, "_ITEM")
		EndIf
		
		For nI := 1 To Len( oXMLItens:_Item )
			
			cProduto 		:= ''
			cTES			:= ''
			nQuantidade		:= 0
			nValDesc		:= 0
			nPerDesc		:= 0
			
			//-------------------------------------------------------------------------
			// Número do Pedido do comprador (C6_PEDCLI)
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_ORDERID' ) != Nil )
				cPedCli := oXMLItens:_Item[nI]:_OrderId:Text
			EndIf
			
			//-------------------------------------------------------------------------
			// Tipo de código do produto
			// EN-Código EA:  EA-8, EA-13 ou DUN-14
			// UP-Código UPC: UPC-A, UPC-E
			// BP-Código de produto da entidade compradora. Designado pelo comprador.
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_TYPECODPROD' ) != Nil )
				cTipoCod := Alltrim( oXMLItens:_Item[nI]:_typecodprod:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Código do Produto (C6_PRODUTO)
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_ITEMCODE' ) != Nil )
				cProduto := AllTrim( oXMLItens:_Item[nI]:_ItemCode:Text )
				If lMA411PRD
					cNewProd	:= Execblock("MA411PRD",.F.,.F.,{cProduto,cTipoCod})
					If ValType(cNewProd) == "C" .And. !Empty(cNewProd)
						cProduto := cNewProd
					EndIf
				EndIf
			EndIf
			
			//---------------------------------------------------------------------------
			// Se utilizar a busca diferencial de produto faz primeiro a busca pelo SA7
			// (indepedente do tipo) Se não encontrar, busca pelo código de barras
			// 	B1_CODBAR - Chamado: TEZDMA
			//---------------------------------------------------------------------------
			If lUsaColab .And. lPrdDif
				SB1->( DbSetOrder( 1 ) )	//B1_FILIAL + B1_COD
				SB1->( DbGoTop() )
				
				SA7->( DbSetOrder( 3 ) )	//A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI
				SA7->( DbGoTop() )
				
				cPrdDif := cProduto
				
				If ( SA7->( MsSeek( xFilial( "SA7" ) + cCodCliente + cLojCliente + cProduto ) ) )
					If ( SB1->( MsSeek( xFilial( "SB1" ) + SA7->A7_PRODUTO ) ) )
						cProduto 	:= SB1->B1_COD
						cTES		:= SB1->B1_TS
					Else
						cProduto := ''
					EndIf
				Else
					//Retorna o código e TES do produto, considerando o campo
					//B1_MSBLQL para os produtos que possuem o código de barras
					MA411ProdBar(@cProduto,@cTes)
				EndIf
				
			Else
				
				Do Case
					//Busca produto pelo código de barras no SB1 (Cadastro de Produtos)
					Case ( ( cTipoCod == 'EN' ) .Or. ( cTipoCod == 'UP' ) )
						//Retorna o código e TES do produto, considerando o campo
						//B1_MSBLQL para os produtos que possuem o código de barras
						MA411ProdBar(@cProduto,@cTes)
						
					//Busca produto na tabela SA7 (Produtos X Clientes)
					Case ( cTipoCod == 'BP' )
						SB1->( DbSetOrder(1) )	//B1_FILIAL + B1_COD
						SB1->( DbGoTop() )
						
						SA7->( DbSetOrder( 3 ) )	//A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_CODCLI
						SA7->( DbGoTop() )
						
						If ( SA7->( MsSeek( xFilial("SA7") + cCodCliente + cLojCliente + cProduto ) ) )
							If ( SB1->( MsSeek( xFilial('SB1') + SA7->A7_PRODUTO ) ) )
								cProduto 	:= SB1->B1_COD
								cTES		:= SB1->B1_TS
							Else
								cProduto := ''
							EndIf
						EndIf
				EndCase
			EndIf
			
			//Se o produto não for encontrado, encerra a gravação do pedido e grava no log
			If ( Empty( cProduto ) )
				
				cLog := STR0020 + " [ " +aDocs+ " ]" + CRLF	//"Falha na gravação! Código do item não encontrado."
				
				If lUsaColab .And. lPrdDif
					cLog := STR0043 + " [ " +aDocs+ " ] " + STR0043 + cPrdDif + CRLF //"Falha na gravação! Produto não encontrado no cadastro de produto x cliente, nem no cadastro de produtos através do código de barras conforme arquivo:  [Numeração do XML] e produto: [Numero do produto]"
				EndIf
				
				If lUsaColab .And. !Empty(cLog)
					EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cLog, .T. )
				EndIf
				
				GravarLog( cLog, ProcName() )
				
				Return( .F. )
			EndIf
			
			//Se o produto não possui TES padrão, busca a TES do parâmetro
			If ( Empty( cTES ) )
				cTES := SuperGetMV( "MV_FATTSPD", .F., '' )
			EndIf
			
			//-------------------------------------------------------------------------
			// Quantidade do item (C6_QTDVEN)
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_QUANTITY' ) != Nil )
				nQuantidade := Val( oXMLItens:_Item[nI]:_Quantity:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Quantidade bonificada do item
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_AMOUNTSUBSID' ) != Nil )
				nQuantBonif := Val( oXMLItens:_Item[nI]:_amountsubsid:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Total bruto
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_TOTALPRICE' ) != Nil )
				nTotBrutoIt := Val( oXMLItens:_Item[nI]:_TotalPrice:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Total líquido
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_VALNETLINEITEM' ) != Nil )
				nTotLiqIt := Val( oXMLItens:_Item[nI]:_valnetlineitem:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Preço unitário líquido do item
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_NETUNITARYPRICE' ) != Nil )
				nValorUnLiq := Val( oXMLItens:_Item[nI]:_netunitaryprice:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Preço unitário bruto do item
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_UNITYPRICE' ) != Nil )
				nValorUnBru := Val( oXMLItens:_Item[nI]:_UnityPrice:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Valor de desconto item
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_UNITVALTRADEDISC' ) != Nil )
				nVlrDescItem := Val( oXMLItens:_Item[nI]:_unitvaltradedisc:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Percentual de desconto sobre o item
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_PERCCOMMDISCOUNT' ) != Nil )
				nPercDescIt := Val( oXMLItens:_Item[nI]:_perccommdiscount:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Valor de bonificação do item
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_BONUSDISCOUNTVALUE' ) != Nil )
				nVlrBonIt := Val( oXMLItens:_Item[nI]:_bonusdiscountvalue:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Percentual de bonificação do item
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_BONUSPERCENTAGE' ) != Nil )
				nPercBonIt := Val( oXMLItens:_Item[nI]:_bonuspercentage:Text )
			EndIf
			
			//-------------------------------------------------------------------------
			// Descontos ItemDiscount
			//-------------------------------------------------------------------------
			If XmlChildEx( oXMLItens:_Item[nI], '_ItemDiscounts' ) != Nil .And. ValType(oXMLItens:_Item[nI]:_ItemDiscounts:_itemDiscount) <> "A"
				XmlNode2Arr(oXMLItens:_item[nI]:_ItemDiscounts:_itemDiscount,"_itemDiscount")
				For nContAux := 1 To len(oXMLItens:_Item[nI]:_ItemDiscounts:_itemDiscount)
					If !Empty(oXMLItens:_Item[nI]:_ItemDiscounts:_itemDiscount[nContAux]:Text)
						nValDesc += Val(oXMLItens:_Item[nI]:_ItemDiscounts:_itemDiscount[nContAux]:Text)
					EndIf
				Next
			EndIf
			
			//-------------------------------------------------------------------------
			// Descontos DiscountPercentage
			//-------------------------------------------------------------------------
			If ValType(oXMLItens:_Item[nI]:_DiscountPercentage) <> "A"
				XmlNode2Arr(oXMLItens:_item[nI]:_DiscountPercentage,"_DiscountPercentage")
			EndIf
			If !Empty(oXMLItens:_Item[nI]:_DiscountPercentage[1]:Text)
				nPerDesc := Val(oXMLItens:_Item[nI]:_DiscountPercentage[1]:Text)
			EndIf
			//-------------------------------------------------------------------------
			// Número do Contrato do item (C6_CONTRT)
			//-------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_Item[nI], '_CONTRACTNUMBER' ) != Nil )
				cContratoIt := oXMLItens:_Item[nI]:_contractnumber:Text
			EndIf
			
			//-------------------------------------------------------------------------
			// Monta Array de itens
			//-------------------------------------------------------------------------
			AAdd( aDetail, {} )
			AAdd( aDetail[nI], { 'C6_ITEM', PadL( cValToChar(nI), 2, '0' ), Nil } )
			AAdd( aDetail[nI], { 'C6_PRODUTO', cProduto, Nil } )		//Código do Produto
			AAdd( aDetail[nI], { 'C6_QTDVEN', nQuantidade, Nil } )	//Quantidade do Produto
			
			//Libera o produto dependendo do conteúdo de MV_FATLBAT
			If ( lLibAuto )
				AAdd( aDetail[nI], { 'C6_QTDLIB', nQuantidade, Nil } )	//Quantidade Liberada
			EndIf
			
			AAdd( aDetail[nI], { 'C6_TES', cTES, Nil } )				//TES
			AAdd( aDetail[nI], { 'C6_CONTRT' , cContratoIt, Nil } )	//Contrato
			AAdd( aDetail[nI], { 'C6_ENTREG' , dEntrega, Nil } )		//Data de entrega
			AAdd( aDetail[nI], { 'C6_HORENT' , cHrEntrega, Nil } )	//Hora de entrega
			AAdd( aDetail[nI], { 'C6_PEDCLI' , cPedCli, Nil } )		//Número do Pedido do Cliente
			
			cPedCliLog := cPedCli
			
			BeginSQL alias cTMPACP
				SELECT ACP.ACP_CODPRO
				
				FROM %Table:ACO% ACO RIGHT JOIN %Table:ACP% ACP ON ACO.ACO_CODREG = ACP.ACP_CODREG
				
				WHERE ACO.ACO_CODCLI=%Exp:cCodCliente%
				AND ACP.ACP_CODPRO = %Exp:cProduto%
				AND ACP.D_E_L_E_T_ = ''
			EndSQL
			
			SB1->( DbSetOrder( 1 ) )
			If Empty( (cTMPACP) -> ACP_CODPRO )
				If !Empty( cTabPreco )
					nVlrUnit := MaTabPrVen(cTabPreco,cProduto,nQuantidade,cCodCliente,cLojCliente,Val(cMoeda),dDataBase)
					If nVlrUnit == 0
						nVlrUnit	:= nValorUnBru
					EndIf
				ElseIf nValorUnBru > 0
					nVlrUnit	:= nValorUnBru
				Else
					If SB1->( DBSeek( xFilial("SB1") + cProduto ) )
						nVlrUnit	:= SB1->B1_PRV1
					EndIf
				EndIf
				AAdd( aDetail[nI], { 'C6_PRCVEN' , nVlrUnit, Nil } )
				AAdd( aDetail[nI], { 'C6_VALOR'  , A410Arred( nVlrUnit * nQuantidade, "C6_VALOR" ), Nil } )
				If nPerDesc >  0
					AAdd( aDetail[nI], { 'C6_DESCONT', nPerDesc, Nil } )
				EndIf
				If nValDesc > 0
					AAdd( aDetail[nI], { 'C6_VALDESC', nValDesc, Nil } )
				EndIf
			EndIf

			( cTMPACP ) -> ( DBCloseArea() )
		Next nI
		
	Else
		//Se a mensagem não contiver itens, encerra e grava o erro no log.
		cLog := STR0010 + " [ " +aDocs+ " ]" + CRLF	//"Falha na gravação! Pedido recebido não possui itens."
		If lUsaColab .And. !Empty(cLog)
			EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cLog, .T. )
		EndIf
		GravarLog( cLog, ProcName() )
		Return .F.
	EndIf
	
	//-------------------------------------------------------------------
	// Summary
	//-------------------------------------------------------------------
	If ( XmlChildEx( oXMLContent, '_SUMMARY' ) != Nil )
		
		//Valor bruto total do pedido
		If ( XmlChildEx( oXMLContent:_Summary, '_ORDERTOTALNETAMOUNT' ) != Nil )
			nValTotBru := oXMLContent:_Summary:_ordertotalnetamount:Text
		EndIf
		
		//Valor líquido total do pedido
		If ( XmlChildEx( oXMLContent:_Summary, '_ORDERTOTALAMOUNT' ) != Nil )
			nValTotLiq := oXMLContent:_Summary:_ordertotalamount:Text
		EndIf
		
	EndIf
	
EndIf

//-------------------------------------------------------------------
// Define a operação realizada no Pedido
//-------------------------------------------------------------------
SC6->( DbSetOrder(11) )	//C6_FILIAL + C6_CLI + C6_LOJA + C6_PEDCLI
SC6->( DbGoTop() )

If ( SC6->( MsSeek( xFilial('SC6') + cCodCliente + cLojCliente + cPedCli ) ) )
	
	nOpc := 4	//Troca a operação para alteração
	AAdd( aMaster, { 'C5_NUM', SC6->C6_NUM, Nil } )	//Adiciona o número do pedido para a ExecAuto localizar
	
	While SC6->( !Eof() ) .And. AllTrim( SC6->C6_PEDCLI ) == AllTrim( cPedCli )
		
		//Valida se existem itens faturados antes de permitir a alteração
		If ( !Empty( SC6->C6_NOTA ) )
			cLog := " [ " +aDocs+ " ] " + STR0024 + CRLF // "Não foi possível realizar a alteração. Pedido possui itens faturados."
			cLog += STR0025 + SC6->C6_NUM + CRLF		// "Número do Pedido: "
			cLog += STR0026 + SC6->C6_PEDCLI + CRLF	// "Número do Pedido do Cliente: "
			cLog += STR0027 + SC6->C6_ITEM + CRLF		// "Item: "
			cLog += STR0028 + SC6->C6_NOTA + CRLF		// "Nota Fiscal: "
			
			//			If lUsaColab .And. !Empty(cLog)
			//				EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cLog, .T. )
			//			EndIf
			GravarLog( cLog, ProcName() )
			Return .F.
		EndIf
		
		SC6->(DbSkip())
		
	EndDo
	
	MA411EstLib( SC6->C6_NUM )	//Estorna a liberação do Pedido
	
	cLog := "Pedido de venda: " +SC6->C6_NUM+ " alterado conforme o arquivo: [ " +aDocs+ " ] .Alteração efetuada conforme o C6_PEDCLI: " +cPedCli+ ". Estornado a liberação do pedido."
	cLog += CRLF + CRLF
	cLog += "A alteração e o estorno foram efetuados, mas o sucesso na gravação dos dados, dependerá do que conteúdo informado no XML. Acompanhe os logs de ExecAuto() na pasta XML dentro do start path"
	If lUsaColab .And. !Empty(cLog)
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, '056', FW_EV_LEVEL_INFO, '', STR0023, cLog, .T. )
	EndIf
	GravarLog( cLog, ProcName() )
	
EndIf

RestArea( aAreaSA3 )
RestArea( aAreaSC6 )
RestArea( aAreaSA4 )
RestArea( aArea )

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA411EnvDoc
Função para envio de documentos ao servidor TOTVS Colaboração.

@sample 	MA411EnvDoc( cIdERP, cIdTSS, cXML )
@param		cIdERP		Id do documento enviado no ERP
@param		cIdTSS		Id do documento enviado no TSS
@param		cXML		XML com conteúdo a ser enviado

@author	Danilo Dias
@since		17/10/2012
@version	P11.7
/*/
//----------------------------------------------------------------------------
Function MA411EnvDoc( cIdERP, cIdTSS, cXML )
Local lRet			:= .T.

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA411Conf
Confirmação de documentos no servidor do TOTVS Colaboração.

@sample 	MA411Conf( cIdTSS )
@param		cIdTSS		Id do documento recebido no servidor do TOTVS Colaboração

@author	Danilo Dias
@since		09/10/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Function MA411Conf( cIdTSS )
	
Return -1

//-------------------------------------------------------------------
/*/{Protheus.doc} MA411EstLib
Estorna a liberação do Pedido de Venda.

@sample 	MA411EstLib( cPedido )
@param		cPedido - Número do pedido a ser estornado

@author	Danilo Dias
@since		16/10/2012
@version	P11.7
/*/
//-------------------------------------------------------------------
Function MA411EstLib( cPedido )
	
Local aArea := GetArea()

Default cPedido := ''

DbSelectArea( 'SC9' )
SC9->( DbSetOrder(1) )	//C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO
SC9->( DbGoTop() )

//Busca o pedido no SC9 - Pedidos Liberados
If ( SC9->( MsSeek( xFilial('SC9') + cPedido ) ) )
	//Estorna item a item do pedido
	While SC9->( !Eof() ) .And. SC9->C9_PEDIDO == cPedido
		
		A460Estorna( .F., .T., 0 )
		SC9->(DbSkip())
		
	EndDo
	
EndIf

RestArea( aArea )
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravarLog
Grava mensagem no arquivo de log.

@sample 	GravarLog( cMsg )
@param		cMsg		Mensagem a ser gravada no log
@param		cFuncao	Funcao que acionou o log

@author	Danilo Dias
@since		11/09/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function GravarLog( cMsg, cFuncao )
	
Local aArea		:= Getarea()
Local cLogFile	:= GetSrvProfString( 'StartPath', '' ) + "\xml\Order.log"
Local cLog		:= ""

Default cMsg 	:= ""
Default cFuncao := ""

// Abre arquivo de Log do recebimento de mensagens
If ( !File( cLogFile, 0, .F. ) )
	nHandleLog := FCreate( cLogFile )
	cLog := STR0005 + ' - ' + STR0023 + CRLF	//"LOG DE TRANSAÇÕES" | "Pedido de Vendas [TOTVS Colaboração]"
	cLog += CRLF + "**************************************************************************************************"
Else
	nHandleLog := FOpen( cLogfile, FO_READWRITE, , .F. )
	cLog := "" + CRLF
EndIf

// Se o arquivo for aberto ou criado com sucesso grava log
If ( nHandleLog != -1 )
	FSeek( nHandleLog, 0, 2 )
	FWrite( nHandleLog, cLog + CRLF )
	
	// Grava log no arquivo
	cLog := "[" + DToC( Date() ) + " " + Time() + "] - " + cFuncao + CRLF + cMsg
	FWrite( nHandleLog, cLog )
	FClose( nHandleLog )
	
	//Guarda mensagem para o Event Viewer
	If ( ValType( cEvent ) == 'C' )
		cEvent := cLog
	EndIf
EndIf

RestArea( aArea )
	
Return Nil

static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
Endif
Return (lUsa)

//-------------------------------------------------------------------
/*/{Protheus.doc} MA411ProgE
Grava Programação de Entrega apartir de Pedidos de Vendas recebidos 
via TOTVS Colaboração.

@sample MA411ProgE(oXML, aMaster, aDetail, cPedCli)
@param	oXML, Objeto com informações recebidas via TOTVS Colaboração.
@param	aMaster, Array com o cabeçalho do pedido de venda.
@param	aDetail, Array com os itens do pedido de venda.
@param	cPedVed, Numero do pedido de venda gerado.

@author	 Lucas Graglia Cardozo
@since	 31/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MA411ProgE(oXML, aMaster, aDetail, cPedVed)
	Local cDatENt  := ""
	Local cHorEnt  := ""
	Local cDatIni  := ""
	Local cHorIni  := ""
	Local cProduto := ""
	Local cTes 	   := ""
	Local cLog	   := ""
	Local cAliCl   := ""
	Local cCliIte  := ""
	Local cLojEnt  := ""
	Local cCnpjCl  := ""
	Local cCodEan  := ""
	Local cTipEnt  := "1"
	Local cStatus  := "01"
	
	Local nX	   := 0
	Local nY	   := 0
	Local nZ	   := 0
	Local nQnt 	   := 0
	Local nScan	   := 0
	Local nItem	   := 0
	Local nCondPag := aScan( aMaster,{|x| X[1] == "C5_CONDPAG" } )
	Local nTabela  := aScan( aMaster,{|x| X[1] == "C5_TABELA" } )
	
	Local cCliCab  := aMaster[3][2]
	Local cLojaCli := aMaster[4][2]
	Local cCondPag := aMaster[nCondPag][2]
	Local cTabela  := aMaster[nTabela ][2]
	Local cPedCli  := aDetail[1][9][2]
	
	Local oModel   := FwLoadModel("MATA412")
	Local oModelD0 := Nil
	Local oModelDX := Nil
	
	Local aSavArea := GetArea()
	Local aItem    := {}
	Local aError   := {}

	Local lAltera  := .T.

	//Posiciona tabela SD0
	DbSelectArea("SD0")
	SD0->( DbSetOrder(2) )	//D0_FILIAL+D0_CLIENTE+D0_LOJA+D0_PEDCLI
	lAltera := SD0->( MsSeek( xFilial("SD0") + cCliCab + cLojaCli + cPedCli) ) 
	If lAltera
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
	Else
		oModel:SetOperation(MODEL_OPERATION_INSERT)
	EndIf
	oModel:Activate()

	If ( oModel:IsActive() ) .And. SDX->(FieldPos("DX_CODCLI") > 0)
		oModelD0 	:= oModel:GetModel("SD0MASTER")
		oModelDX 	:= oModel:GetModel("SDXDETAIL")
		oModelD0:SetValue( "D0_CLIENTE", cCliCab  )
		oModelD0:SetValue( "D0_LOJA"   , cLojaCli )
		oModelD0:SetValue( "D0_PEDCLI" , cPedCli  )
		oModelD0:SetValue( "D0_CONDPAG", cCondPag )
		oModelD0:SetValue( "D0_TABELA" , cTabela  )
		//Se for alteração, o modelo é limpado e será carregado novamente.
		If lAltera
			For nZ := 1 to oModelDX:Length()
				oModelDX:GoLine(nZ)
				If !oModelDX:IsDeleted()
					oModelDX:DeleteLine()
				EndIf
			Next
		EndIf
		aCliLoja := Ma411Cnpj(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM)
		For nX := 1 To Len(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM)
		
			If XmlChildEx(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX], "_CROSSDOCKING") != Nil //Verifico se cada item possui a tag de crossdoking
				
				If ValType(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM) != "A"
					XmlNode2Arr( oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM, '_CROSSDOCKING_ITEM' )
				EndIf

				aItem := oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM
				nItem := Len(aItem)

				For nY := 1 To nItem
					cTipEnt  := "1"
					cProduto := aDetail[nX][2][2]
					cTes 	 := aDetail[nX][5][2]
					nQnt     := Val(aItem[nY]:_quantdelivery:Text)
					
					If nQnt = 0
						cLog := STR0045 + cPedVed + STR0026  + cPedCli //"Programação de entrega não gerada, quantidade não informada ou inválida! REF: Pedido de Venda: " # " Pedido Cliente: "
						GravarLog( cLog, ProcName() )
						Return
					EndIf
					If XmlChildEx(aItem[nY], "_dhinidelivery") != Nil
						cDatIni  := SubStr(aItem[nY]:_dhinidelivery:Text,1,4)
						cDatIni  += SubStr(aItem[nY]:_dhinidelivery:Text,6,2)
						cDatIni  += SubStr(aItem[nY]:_dhinidelivery:Text,9,2)
						cHorIni  := Substr(aItem[nY]:_dhinidelivery:Text,12,2)
						cHorIni  += Substr(aItem[nY]:_dhinidelivery:Text,15,2)
					EndIf
					If XmlChildEx(aItem[nY], "_dhfindelivery") != Nil
						cDatENt  := SubStr(aItem[nY]:_dhfindelivery:Text,1,4)
						cDatENt  += SubStr(aItem[nY]:_dhfindelivery:Text,6,2)
						cDatENt  += SubStr(aItem[nY]:_dhfindelivery:Text,9,2)
						cHorEnt  := Substr(aItem[nY]:_dhfindelivery:Text,12,2)
						cHorEnt  += Substr(aItem[nY]:_dhfindelivery:Text,15,2)
					EndIf
					cCnpjCl  := aItem[nY]:_deliverycnpj:Text
					cCodEan  := aItem[nY]:_deliveryean:Text
					
					nScan := aScan(aCliLoja,{|x| x[3] == cCnpjCl})
					If nScan > 0
						cCliIte := aCliLoja[nScan][1]
						cLojEnt := aCliLoja[nScan][2]
					Else
						cCliIte := cCliCab
						cLojEnt := cLojaCli
					EndIf
					
					oModelDX:AddLine()
					oModelDX:SetValue( "DX_PRODUTO", cProduto          )
					oModelDX:SetValue( "DX_QUANT"  , nQnt              )
					oModelDX:SetValue( "DX_TES"    , cTes 	           )
					oModelDX:SetValue( "DX_TIPENT" , cTipEnt           )
					
					If !EMPTY(cDatENt)
						oModelDX:SetValue( "DX_DATENT" , sTod(cDatENt) )
					EndIf
					
					If !Empty(cHorEnt)
						oModelDX:SetValue( "DX_HORENT" , cHorEnt       )
					EndIf
					
					If !Empty(cDatIni)
						oModelDX:SetValue( "DX_DATINI" , sTod(cDatIni) )
					EndIf
					
					If !Empty(cHorIni)
						oModelDX:SetValue( "DX_HORINI" , cHorIni       )
					EndIf
					
					If !Empty(cCliIte)
						oModelDX:SetValue( "DX_CODCLI" , cCliIte       )
					EndIf
					
					If !Empty(cLojEnt)
						oModelDX:SetValue( "DX_LOJCLI" , cLojEnt       )
					EndIf
					
					If !Empty(cPedCli)
						oModelDX:SetValue( "DX_PEDCLI" , cPedCli       )
					EndIf
					
					If!Empty(cCodEan) 
						oModelDX:SetValue( "DX_CODEAN" , cCodEan  )
					EndIf
				Next nY
			EndIf
		Next nX

		If (oModel:VldData())
			oModel:CommitData()
			cLog := STR0048		//"Programação de entrega Atualizado com sucesso! "
			GravarLog(cLog, ProcName())			
		Else
			aError := oModel:GetErrorMessage()
			cLog := STR0049 + CRLF + CRLF 				//"Erro Programação de Entrega " 
			
			If Len(aError) > 0
				cLog += STR0050 + AllToChar(aError[1]) + "'" + CRLF 	//"Id do Submodelo de Origem: '"
				cLog += STR0051 + AllToChar(aError[2]) + "'" + CRLF		//"Id do Campo de Origem:     '" 
				cLog += STR0052 + AllToChar(aError[3]) + "'" + CRLF		//"Id do Submodelo de Erro:   '"
				cLog += STR0053 + AllToChar(aError[4]) + "'" + CRLF 	//"Id do Campo de Erro:       '"
				cLog += STR0054 + AllToChar(aError[5]) + "'" + CRLF 	//"Id do Erro:                '"
				cLog += STR0055 + AllToChar(aError[6]) + "'" + CRLF		//"Mensagem do Erro:          '"
				cLog += STR0056 + AllToChar(aError[7]) + "'" + CRLF		//"Mensagem da Solução:       '"
				cLog += STR0057 + AllToChar(aError[8]) + "'" + CRLF		//"Valor Atribuido:           '"
			EndIf

			GravarLog( cLog, ProcName() )
		EndIf
		
		oModel:DeActivate()
	EndIf
	
	//Restaura Arrays - Limpa Memoria
	RestArea(aSavArea)
	If !Empty(aItem)
		Asize(aItem,0)
	EndIf

	If !Empty(aError)
		Asize(aError,0)
	EndIf

	If !Empty(aSavArea)
		Asize(aSavArea,0)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IsCrossDk
Verifica se existe Crossdocking no XML

@sample IsCrossDk(oXML)
@param	oXML, Objeto com informações recebidas via TOTVS Colaboração.
@Return	lRet, Verdadeiro quando existe Crossdocking no XML

@author	 Squad CRM/Faturamento
@since	 12/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function IsCrossDk(oXML)
	Local lRet := .F. 
	Local nX   := 0
	Local nLen := 0
	Default oXML :=  Nil 
	
	If Valtype(oXML) <> Nil 
		nLen := Len(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM)
		For nX := 1 To nLen
			If XmlChildEx(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX],'_CROSSDOCKING') != Nil
				lRet := .T.
				Exit
			EndIF
		Next nX
	EndIF
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Ma411Cnpj
Carrega em um array os clientes

@sample Ma411Cnpj(aRetItem)
@param	aRetItem, Objeto com informações recebidas via TOTVS Colaboração.
@Return	AretAux, Retorna array com dados do cliente

@author	 Squad CRM/Faturamento
@since	 12/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function Ma411Cnpj(aRetItem)

Local cAliCl   	:= GetNextAlias()
Local cRetCnpj	:= ""
Local cTemp		:= ""
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local nPos		:= 0
Local AretAux	:= {}
Local aArea		:= GetArea()

Default aRetItem:= {}

For nX := 1 to Len(aRetItem)
	If Valtype(aRetItem[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM) == "O"
		nPos := AT(aRetItem[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM:_deliverycnpj:Text,cRetCnpj)
		If nPos == 0
			cRetCnpj += Iif(nX > 1,"#","") + aRetItem[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM:_deliverycnpj:Text
		Else
			nPos := 0
		EndIf
	Else
		For nY := 1 to Len(aRetItem[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM)
			nPos := AT(aRetItem[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM[nY]:_deliverycnpj:Text,cRetCnpj)
			If nPos == 0
				cRetCnpj += Iif(nX > 1,"#","") + aRetItem[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM[nY]:_deliverycnpj:Text
			Else
				nPos := 0
			EndIf
		Next
	EndIf
Next

cTemp := "%" + FormatIn(cRetCnpj,"#") + "%"
//--------------------------------------------------------------------
// Query para saber se existe mais de um cliente com o mesmo CGC, se
// existir, seleciona o 1 cadastro ativo
//--------------------------------------------------------------------
BeginSQL alias cAliCl
	SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_MSBLQL
	
	FROM %Table:SA1% SA1
	
	WHERE SA1.A1_FILIAL = %xFilial:SA1% AND
	SA1.A1_CGC IN %Exp:cTemp% AND
	A1_MSBLQL = '2' AND SA1.%NotDel%
	
	ORDER BY A1_COD
EndSQL

While !( cAliCl )->( Eof())
	Aadd(AretAux,{(cAliCl)->A1_COD,(cAliCl)->A1_LOJA,(cAliCl)->A1_CGC})
	DbSkip()
EndDo
(cAliCl) -> (DbCloseArea())
RestArea(aArea)
Return (AretAux)
//-------------------------------------------------------------------
/*/{Protheus.doc} MA411PedCr
Carrega em um array os clientes

@sample MA411PedCr(oXML,aMaster,aDetail,nOpc)
@param oXML, Objeto com informações recebidas via TOTVS Colaboração.
@param aMaster, Arry contendo cabeçalho para execatudo do pedido de vendas
@param aDetail, Arry contendo Itens ppara para execatudo do pedido de vendas
@param nOpc, Tipo de operação que será enviada para o execauto do pedido de vendas
@Return	lRet, Variável que informa se ocorreu inclusão do pedido ou não.

@author	 Squad CRM/Faturamento
@since	 12/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function MA411PedCr(oXML,aMaster,aDetail,nOpc)

Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
Local nItem			:= 0

Local lRet 			:= .F.

Local aItem    		:= {}
Local aItens		:= {}
Local aDetailXDo 	:= {}

Default nOpc		:= 3
Default oXML		:= Nil 
Default aMaster 	:= Nil 
Default aDetail 	:= Nil 

For nX := 1 To Len(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM)
	If XmlChildEx(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX], "_CROSSDOCKING") != Nil //Verifico se cada item possui a tag de crossdoking
		If ValType(oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM) != "A" //Verifica se é diferente de array
			XmlNode2Arr( oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM, '_CROSSDOCKING_ITEM' )
		EndIf

		aItem := oXML:_BUSINESSCONTENT:_SalesOrderItens:_ITEM[nX]:_CROSSDOCKING:_CROSSDOCKING_ITEM
		nItem := Len(aItem)
		
		For nY := 1 To nItem
			Aadd(aDetailXDo,{})
			Aadd(aDetailXDo[nZ],{'C6_ITEM'		, PadL(cValToChar(nZ), 2, '0')		, Nil})	//01-Código do item 01
			Aadd(aDetailXDo[nZ],{'C6_PRODUTO'	, aDetail[nX][2][2]					, Nil})	//02-Código do Produto
			Aadd(aDetailXDo[nZ],{'C6_QTDVEN'	, Val(aItem[nY]:_quantdelivery:Text), Nil}) //03-Quantidade
			Aadd(aDetailXDo[nZ],{'C6_PRCVEN'	, aDetail[nX][10][2]				, Nil}) //04-Preco de vendas
			Aadd(aDetailXDo[nZ],{'C6_TES'		, aDetail[nX][5][2]					, Nil})	//05-TES
			Aadd(aDetailXDo[nZ],{'C6_QTDLIB'	, Val(aItem[nY]:_quantdelivery:Text), Nil}) //06-Quantidade liberada
			Aadd(aDetailXDo[nZ],{'C6_CONTRT'	, aDetail[nX][6][2]					, Nil}) //07-Contrato
			Aadd(aDetailXDo[nZ],{'C6_ENTREG'	, aDetail[nX][7][2]					, Nil}) //08-Data de entrega
			Aadd(aDetailXDo[nZ],{'C6_HORENT'	, aDetail[nX][8][2]					, Nil}) //09-Hora de entrega
			Aadd(aDetailXDo[nZ],{'C6_PEDCLI'	, aDetail[nX][9][2]					, Nil}) //10-Pedido do cliente
			nZ := nZ + 1
		Next
	EndIf
Next

MSExecAuto( { |x, y, z| MATA410( x, y, z ) }, aMaster, aDetailXDo, nOpc ) //

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MA411ProdBar
Valida o campo B1_MSBLQL dos produtos que possuem o mesmo código de 
barras, e retorna o código do produto e a TES.

@param cProduto, Código de barras do produto
@param cTes, Tipo de Saída do produto
@Return	Nil, Variáveis cProduto e cTes recebidas como referência

@author	 Squad CRM/Faturamento
@since	 17/08/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function MA411ProdBar(cProduto,cTes)

Local cAliasB1 := GetNextAlias()
Local lTemBlq  := .F.

BeginSQL alias cAliasB1
	SELECT B1_COD, B1_TS, B1_MSBLQL
	FROM %Table:SB1% SB1
	WHERE 	SB1.B1_FILIAL = %xFilial:SB1% AND
			SB1.B1_CODBAR = %exp:cProduto% AND
			SB1.%NotDel%
	
	ORDER BY SB1.B1_FILIAL, SB1.B1_CODBAR
EndSQL

If (cAliasB1)->(Eof())
	cProduto := ""
Else
	While (cAliasB1)->(!Eof()) 
		//Retorna o primeiro produto que não esteja bloqueado,
		//caso contrário retorna o primeiro produto bloqueado encontrado.
		If (cAliasB1)->B1_MSBLQL <> "1"	
			cProduto := (cAliasB1)->B1_COD
			cTes := (cAliasB1)->B1_TS
			Exit
		ElseIf !lTemBlq
			cProduto := (cAliasB1)->B1_COD
			cTes := (cAliasB1)->B1_TS
			lTemBlq := .T.
		EndIf
		(cAliasB1)->(dbSkip())
	EndDo
EndIf

If Select(cAliasB1) > 0
	(cAliasB1)->(dbCloseArea())
EndIf

Return