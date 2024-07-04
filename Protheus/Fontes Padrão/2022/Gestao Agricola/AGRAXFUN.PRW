#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'AGRAXFUN.CH'

#DEFINE BUFFER_LEITURA	32
#DEFINE PORTASERIAL  'S'
#DEFINE PORTATCPIP   'T'
#DEFINE MSECONDS_WAIT 		1000
#DEFINE TRIES_TO_CONNECT 	3
#DEFINE TRIES_TO_READ    	3

Static nPsosVale1		:= 2   // Numero de capturas iguais para considerar o Peso (ex. nPesoVld1 := 2 ,
Static lEhTeste			:=  IIF( IsInCallStack( 'TESTAR' ),.T., .F.)
Static __cAliasC	:= Nil	//Tabela Temporaria para consulta
Static __oArqTemp	:= Nil	//Variavel utilizada para a consulta padrão DX6GRP

// Indica que tenho q ter 3 pesagens iguais para considerar o peso, razão
// pode ser o excesso de vento na região da balança )

/** {Protheus.doc} AGRX003A
Captura de peso da balança
Parametros
@npeso		:= Ponteiro de variavel que irá conter o Peso
lMostra		:= Indica se mostra a tela de  Peso;
aBal		:= Array Identificando : [01] codigo da Balança, [2] Permite Pesagem Automatica, [3] Permite Pesagem Manual
cMask 		:= Mascara do Campo de Pesagem padrão é "@E 999,999,999" pois são Balanças rodoviarias
@lPesagManu	:= identificará se a pesagem foi feita de forma automatica ou manual

@author: 	Ricardo Tomasi
@since: 	12/07/2010
@Uso: 		Generico Agro
*/
Function AGRX003A( nPeso, lMostra, aBal, cMask, lPesagManu, nPeso1, nPeso2) 
	Local aAreaAtu 		:= GetArea()
	Local aAreaDX6		:= DX6->(GetArea() )
	Local aAreaDX5		:= DX5->(GetArea() )
	Local oDlg     		:= Nil
	Local oBtn1    		:= Nil
	Local oBtn2    		:= Nil
	Local oFont    		:= Nil
	Local oPeso			:= Nil
	Local cId			:= __cUserID
	Local cBalanca 		:= CriaVar('DX5_CODIGO', .f.)
	Local nPesoCapt		:= 0	

	Local __lPsAuto  	:= .F.
	Local __lPsManual	:= .F.
	Local nPesoST 		:= 0
	Local cLib          := ""

	Default nPeso		:= 0
	Default lMostra		:= .t.
	Default aBal		:= {}

	Default lPesagManu	:= .f.   // Identifica se a Pesagem foi feita de Forma Automatica

	/*cMask = alterado o tipo da picture com base nos campos de quantidade SD1.
	Parametro: Formato para campos de peso no romaneio. Caso não tenha conteúdo,
	ou não exista o parâmetro, será considerado o formato @E 999,999.*/
	Default cMask		:= SuperGetMV("MV_OGPICPS",,"@E 999,999")
	Default nPeso1		:= 0
	Default nPeso2		:= 0
	
	Private _lUsuar  	:= .F.
	Private _lGrupo		:= .F.
	
	nPesoST := Abs(nPeso1 - nPeso2)

	If Len( aBal ) > 0
		cBalanca      	:= aBal[ 1 ]
		__lPsAuto       := aBal[ 2 ]
		__lPsManual     := aBal[ 3 ]
	EndIf

	// Validação de Usuário X Balança
	If GetRpoRelease() < "12.1.023"
		dbSelectArea( "DX6" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "DX6" ) + cId + cBalanca )
			If DX6_STATUS <> "1" // 1=Autorizado
				Help(,,STR0010,,STR0011 + Chr(10) + Chr(13) +  "[ " + STR0012 + cId + "; " + STR0013 + cBalanca + " ]" , 1, 0 )  //"Ajuda"###"Usuario não autorizado a efetuar pesagens nesta balança!"###"Usuário: "###"Balança: "
				RestArea( aAreaAtu )
				RestArea( aAreaDX6 )
				RestArea( aAreaDX5 )
				Return( Nil )
			EndIf
		Else
			Help(,,STR0010,,STR0014 + Chr(10) + Chr(13) +  "[ " + STR0012 + cId + "; " + STR0013 + cBalanca + " ]" , 1, 0 ) //"Ajuda"###"Usuario não cadastrado para utilizar esta balança!"###"Usuário: "###"Balança: "
			RestArea( aAreaAtu )
			RestArea( aAreaDX6 )
			RestArea( aAreaDX5 )
			Return( Nil )
		EndIf
	Else
	
		If .NOT. Empty(cBalanca)
		
			AX003BPUSM(cId, Iif (.NOT. Empty(cBalanca),cBalanca,"")) //Busca balança por usuário sem mensagens
		
			If .NOT. _lUsuar		
				AX003BpGSM(cId, Iif (.NOT. Empty(cBalanca),cBalanca,""))
			EndIf 
			
			If .NOT. _lUsuar .AND. .NOT. _lGrupo
		//		Help(" ",1,"NOBALXUSR")"Não foi encontrado relacionamento de usuário ou grupo de usuário x balança. 
		//		Verifique se existe balança cadastrada no 'Cadastro de Balanças' e
		//		também se existe permissão no cadastro de 'Usuário x Balança' para o usuário ou o grupo de usuário."
				MsgAlert(STR0036)
				cBalanca := ""
			
				RestArea( aAreaAtu )
				RestArea( aAreaDX6 )
				Return(Nil)
			EndIf
		Else
			Help(" ",1,"NOBALXUSR")
			RestArea( aAreaAtu )
			RestArea( aAreaDX6 )
			Return(Nil)
		EndIf
	EndIf

	DX5->(dbSelectArea("DX5"))
	DX5->(dbSetOrder(1))
	If DX5->(MsSeek( xFilial( "DX5" ) + cBalanca ))
		If lMostra

			oFont := TFont():New( 'Arial', , 232, , .t. )
			oDlg  := TDialog():New( 000, 000, 330, 1024, STR0030, , , , , CLR_BLACK, CLR_WHITE, , , .t. )	//"Peso da Balança"
			oTimeClose	:= TTimer():New( 0800, { || /*oTimeClose:Deactivate(),*/ oDlg:End()}, oDlg )   //Timer que irá fechar a Janela apos a pasegem Automatica ser capturada
			oPeso := TGet():New( 01, 01, { |u| If( PCount() > 0, nPeso := u, nPeso ) } , oDlg, 512, 120, cMask, /*validacao*/, CLR_RED, CLR_WHITE, oFont, .f., , .t., , .f., { || __lPsManual }/*when*/, .f., .f., , .f., .f., ,"nPeso", , , , )			
			
			GetRemoteType(@cLib)
			If "HTML" $ cLib
				oPeso:SetCss("TGet {max-height: inherit;}")
			EndIf
			
			oSay1Pes	:= TSay():New(130,  5, {|| OemToAnsi( STR0037 ) } ,oDlg                          , , , .f., .f., .f., .t., , , Len(STR0037)*4, 010 ) //"1ª Pesagem"
			oG1Pes		:= TGet():New(138,  5, {|| nPeso1}, oDlg, 40,10, cMask, { || .T.}     ,      ,          , , .F., , .T., , .F., {|| .f.},   ,   ,,   ,   ,,"nPeso1",,,,,.T.)

			oSay2Pes	:= TSay():New(130, 55, {|| OemToAnsi( STR0038 ) } ,oDlg                          , , , .f., .f., .f., .t., , , Len(STR0038)*4, 010 ) //"2ª Pesagem"
			oG2Pes		:= TGet():New(138, 55, {|| nPeso2}, oDlg, 40,10, cMask, { || .T.}     ,       ,         , , .f., , .t., , .f., {|| .f.},,,,,,,,,,,,.T.)
			
			oSay3Pes	:= TSay():New(130,105, {|| OemToAnsi( STR0039 ) } ,oDlg                          , , , .f., .f., .f., .t., , , Len(STR0039)*4, 010 ) //"Subtotal""
			oG3Pes		:= TGet():New(138,105, {|| nPesoST},oDlg, 40,10, cMask, { || .T.}     ,       ,         , , .f., , .t., , .f., {|| .f.},,,,,,,,,,,,.T.)
	
			oBtn1 := TButton():New( 150, 421, STR0015 , oDlg, { || nPeso := AGRX003B( ), oPeso:CtrlRefresh(),nPesoCapt:=nPeso,IIf( nPeso>0 .or. lEhTeste, oTimeClose:Activate(), .t.) }, 40, 10, , , .f., .t., .f., , .f., { || __lPsAuto } /*when*/, , .f. ) //#Capturar
			oBtn2 := TButton():New( 150, 471, STR0016 , oDlg, { || IIF(nPeso > 0, oDlg:End(), .f. ) }, 40, 10, , , .f., .t., .f., , .f., , , .f. )	//#Confirmar
			oDlg:Activate( , , , .t., , , ,)
		Else
			If __lPsAuto
				nPeso 		:= AGRX003B( )
				nPesoCapt	:= nPeso    //Tratamento para Identificar se Peso Foi Digitado para Qdo o tipo de Pesagem está ambos
			EndIf
		EndIf
	EndIf
	DX5->(DbCloseArea())

	IF nPeso != nPesoCapt   // Se o Peso não Bate com o Peso Capturado Indica que a Pesagem foi inserida de forma manual.
		lPesagManu := .t.	//pesagem manual
	Else
		lPesagManu := .f.	//pesagem auto
	EndIf

	RestArea( aAreaAtu )
	RestArea( aAreaDX6 )
	RestArea( aAreaDX5 )

Return( Nil )


/** {Protheus.doc} AGRX003B
Retorna Peso Estabilizado da Balança
@author: 	Ricardo Tomasi
@since: 	12/07/2010
@Uso: 		Generico Agro
*/

Function AGRX003B( )
	Local cTitulo		:= STR0017 		//#"Integração de Balanças"
	Local cMensagem		:= STR0018 		//#"Aguardando estabilização do peso... Visor  "
	Local oTimer		:= Nil
	Local nFor01		:= 0
	Private oDlg		:= Nil
	Private aCap		:= {}
	Private nSeq		:= 1
	Private nCap		:= 0
	Private oSay		:= Nil
	Private nPsosVale1	:= 2   // Numero de capturas iguais para considerar o Peso (ex. nPesoVld1 := 2 ,

	If DX5->(FieldPos("DX5_LERVEZ")) > 0
		nPsosVale1 := DX5->( DX5_LERVEZ )
	Endif

	//O IF abaixo foi colocado conforme conversa com o Joaquim, pois os clientes estavam deixando o campo 
	//DX5_LERVEZ zerado, ocasionando erro na balança
	If nPsosVale1 < 2
		nPsosVale1 := 2
	EndIf

	For nFor01 := 1 to   nPsosVale1    //adiiconando a qtd de pensagesn que são necessarias para considerar 1 peso valido
		aAdd( aCap, 0 )
	Next nPosVale1


	oDlg 		:= TDialog():New( 000, 000, 090, 320, cTitulo, , , , , CLR_BLACK, CLR_WHITE, , , .t. )
	oTimer 		:= TTimer():New( 0, { || AGRX003F( ),oTimer:Deactivate(), oDlg:End()}, oDlg )
	oSay		:= TSay():New( 010, 010, { || cMensagem + "[ " + Str( nCap ) + " ]" }, oDlg, , , , , , .t., CLR_RED, CLR_WHITE, 460, 020 ) 		//#Cancelar
	oTBut 		:= TButton():New( 030, 060, STR0019, oDlg, { || oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. )
	oDlg:Activate( , , , .t., { || .t. }, , { || oTimer:Activate() } )

Return( nCap )


/** {Protheus.doc} AGRX003C
Valida conexão com balança
@author: 	Ricardo Tomasi
@since: 	12/07/2010
@Uso: 		Generico Agro
*/
Function AGRX003C(cPorta, cBaudRate, cParity, cData, cStop, cTimeOut, cScript, cTpRead, cIpServer, cPrtaIPSer,nWait4Read )
	// Vars de Conexao com Serial
	Local cSettings		:= AllTrim( cBaudRate )+','+AllTrim( cParity )+','+AllTrim( cData )+','+AllTrim( cStop )+','+AllTrim( cTimeOut )
	Local nHdlePorta
	//--End VArs de Comunicacao Serial--
	// Vars de Conexao com Tsokect ( TCPIP)
	Local oSocket
	Local nSockResp  := 0
	///		Local atSocketC	:= ClassMethArray( oSocket ) // Encontrando os Methodos da classe
	//--End Vars de Comunicação TCPIP

	Local nFor01	:= 0
	Local nHdll  	:= 0
	Local nCont  	:= 0 
	Local cPortaMs := AllTrim(cPorta) + ':' + AllTrim(cSettings)
	Local cConteudo := ''

	Do Case
		Case cTpRead == PORTASERIAL  		 //Comunicação Serial

		nHdlePorta	:= fOpenPort( cPorta, cSettings, 2 ) // Tentando conectar
		If nHdlePorta == -1 //caso não conecte com o fOpenPort, irá tentar com o MsOpenPort

			FClose( nHdlePorta )

			MsOpenPort(nHdll, cPortaMs)
			cConteudo := space(100)

			While (Empty(cConteudo) .AND. nCont < 50)
				MsRead(nHdll, @cConteudo)
				nCont++
			EndDo

			MsClosePort(nHdll)
			If Empty(cConteudo)
				Help(,,STR0010,,STR0021 + Chr(10) + Chr(13) +  "[ " + cPorta + " ]" , 1, 0 )  //"Ajuda"####não foi possivel conectar com a balança, na Porta"
				Return( .F. )
			EndIf         
		Else 
			FClose( nHdlePorta )
		EndIf

		Case cTpRead == PORTATCPIP // Para conectar Utilizar Endereco do Servidor (padraoIP), Porta do servidor IP, timeout

		//		IF nWait4Read < MSECONDS_WAIT    // Ajustando o Tempo de Espera para Pelo menos 2000 milessegundos
		//			nWait4Red := MSECONDS_WAIT
		//		EndIF

		oSocket 	:= tSocketClient():New()   //Criando a Clase
		For nFor01 := 1 to TRIES_TO_CONNECT   // tenta conectar N vezes
			nSockResp := oSocket:Connect( val(cPrtaIPSer),Alltrim(cIpServer),Val( cTimeOut ) ) 
			//Verificando se a conexao foi efetuada com sucesso
			IF !( oSocket:IsConnected() )  //ntSocketConnected == 0 OK
				oSocket:CloseConnection()
				Help(,,STR0010,,STR0027 + Chr(10) + Chr(13) +  "[ " + Alltrim( cIpServer ) + "/" + Alltrim( cPrtaIPSer ) + " ]" , 1, 0 )  //"Ajuda"####não foi possivel conectar com a balança. no endereço "
				//ConOut( oSocket:GetError() )
				Return(.f.)

			EndIF
		Next
		oSocket:CloseConnection()   //Fechando a Conexão
	EndCase

Return( .t. )

/** {Protheus.doc} AGRX003D
Integra com a balança e captura o peso 
@author: 	Ricardo Tomasi
@since: 	12/07/2010
@Uso: 		Generico Agro
*/
Function AGRX003D(cPorta, cBaudRate, cParity, cData, cStop, cTimeOut, cScript, cTpRead, cIpServer, cPrtaIPSer,nWait4Read )
	// Vars de Conexao com Serial
	Local cParte		:= Space( 1 )
	Local cSettings		:= AllTrim( cBaudRate )+','+AllTrim( cParity )+','+AllTrim( cData )+','+AllTrim( cStop )+','+AllTrim( cTimeOut )
	Local nHdlePorta
	Local nBytes		:= 0
	//--End VArs de Comunicacao Serial--
	// Vars de Conexao com Tsokect ( TCPIP)
	Local oSocket
	Local nSockResp  := 0
	Local nSockRead  := 0
	Local cBuffer	 := ''
	///		Local atSocketC	:= ClassMethArray( oSocket ) // Encontrando os Methodos da classe
	//--End Vars de Comunicação TCPIP


	Local nFor01		:= 0
	Local nFor02		:= 0
	Local nRetorno		:= 0
	Local cConteudo		:= ""
	Local nHdll  	:= 0
	Local nCont  	:= 0
	Local cPortaMs := AllTrim(cPorta) + ':' + AllTrim(cSettings)

	Do Case
		Case cTpRead == PORTASERIAL  		 //Comunicação Serial

		nHdlePorta	:= fOpenPort( cPorta, cSettings, 2 ) // Tentando conectar

		IF nHdlePorta == -1 //caso não conecte com o fOpenPort, irá tentar com o MsOpenPort

			FClose( nHdlePorta )

			MsOpenPort(nHdll, cPortaMs)

			cConteudo := space(100)

			While (Empty(cConteudo) .AND. nCont < 50)
				MsRead(nHdll, @cConteudo)
				nCont++
			EndDo

			MsClosePort(nHdll)

			If Empty(cConteudo)
				Help(,,STR0010,,STR0021 + Chr(10) + Chr(13) +  "[ " + cPorta + " ]" , 1, 0 )  //"Ajuda"####não foi possivel conectar com a balança na Porta#
				Return 0
			EndIf    
		Else 
			For nFor01 := 1 to TRIES_TO_READ  		// tenta conectar N vezes
				cConteudo := ''
				For nFor02 := 1 to BUFFER_LEITURA   //32
					cParte := Space( 1 )
					nBytes := FRead( nHdlePorta, @cParte, 1 )
					If Empty( nBytes )
						Exit
					EndIf
					cConteudo += cParte
				Next nFor02
				IF ! Empty( cConTeudo )
					Exit
				EndIF
			Next nFor01
			FClose( nHdlePorta )	
		EndIf

		Case cTpRead == PORTATCPIP // Para conectar Utilizar Endereco do Servidor (padraoIP), Porta do servidor IP, timeout


		//IF nWait4Read < MSECONDS_WAIT    // Ajustando o Tempo de Espera para Pelo menos 2000 milessegundos
		//	nWait4Red := MSECONDS_WAIT
		//EndIF

		oSocket 	:= tSocketClient():New()   	//Criando a Clase
		For nFor01 := 1 to TRIES_TO_CONNECT   	// tenta conectar N vezes
			nSockResp := oSocket:Connect( val(cPrtaIPSer),Alltrim(cIpServer),Val( cTimeOut ) )
			//Verificamos se a conexao foi efetuada com sucesso
			IF !( oSocket:IsConnected() )  //ntSocketConnected == 0 OK
				Help(,,STR0010,,STR0020 + Chr(10) + Chr(13) +  "[ " + StrZero( nFor01,3 ) + " ]" , 1, 0 )  //"Ajuda"####não foi possivel conectar com a balança na Porta#
			ElseIF nSockResp == 0   // Conexão Ok
				Exit
			EndIF
		Next

		IF nSockResp == 0 // Indica que Está conectado // Enviando um Get Para Capturar o Peso
			Sleep ( nWait4Read )
			For nFor01 := 1 To TRIES_TO_READ
				cBuffer := ""
				nSockRead = oSocket:Receive( @cBuffer,  Val( cTimeout ) )
				IF( nSockRead > 0 )
					cConteudo := cBuffer
					Exit
				Else
					cConteudo := ''
				Endif
			Next nFor01
			///oSocket:CloseConnection()   //Fechando a Conexão
		Else
			Help(,,STR0010,,STR0027 + Chr(10) + Chr(13) +  "[ "  + cIpServer + "/" + cPrtaIPSer + " ]" , 1, 0 )  //"Ajuda"####não foi possivel conectar com a balança. Tentavia:# ###"Balança: "
		EndIF
		oSocket:CloseConnection()   //Fechando a Conexão
	EndCase



	//	IF IsInCallStack( 'TESTAR' ) /*.and. lShowCFG */ .and. len(alltrim(cconteudo)) > 0 //Indica que está testando a comunicação e que devemos mostrar esta mensagem
	IF lEhTeste
		AGRXFUNCFG( cConteudo ) // Mostra tela Explicativa de Config da Balança;
	EndIF


	If .Not. Empty( AllTrim( cScript ) )   			// Irá Aplicar o Script no cConteudo
		cScript := "{||" +  Alltrim(cScript) + "}"  //Transformando o Script em bloco de codigo
		cConteudo := Eval( &( cScript ) )
		nRetorno := Val( cConteudo )
	Else
		nRetorno := 0
	EndIf

Return( nRetorno )

/** {Protheus.doc} AGRX003E
Valida usuário x Balança e carrega as configurações de pesagem

@author: 	Ricardo Tomasi
@since: 	12/07/2010
@Uso: 		Generico Agro
*/
Function AGRX003E( lPergunta, cPergunte, cCodBal )
	Local aAreaAtu		:= GetArea()

	Local cId			:= __cUserID
	Local cBalanca		:= CriaVar('DX5_CODIGO',.f.)
	Local __lPsAuto		:= .f.
	Local __lPsManual	:= .f.
	Local __lPsNao		:= .t.
	Local lRet          := .f.
	Default lPergunta	:= .t.
	Default cCodBal		:= ""
	
	Private _lUsuar		:= .F.
	Private _lGrupo		:= .F.
	Private _cGrp		:= ""
	
	If GetRpoRelease() < "12.1.023"
	
		dbSelectArea( "DX6" ) // Usuários X Balanças
		dbSetOrder( 1 )
		If dbSeek( xFilial( "DX6" ) + cId )
			While .Not. Eof() .And. DX6_FILIAL = xFilial( "DX6" ) .And. DX6_CODUSU = cId
				If DX6_STATUS = "1"
					lRet = .T.
					Exit
				EndIf
				dbSkip()
			EndDo
			If lRet
				Pergunte( cPergunte, lPergunta )
				cBalanca := MV_PAR01
			EndIf
		Else
			Help(" ",1,"NOBALXUSR")
		EndIf
	
		If .Not. Empty( AllTrim( cBalanca ) )
			dbSelectArea( "DX5" )	//Balanças
			dbSetOrder( 1 )
			If dbSeek( xFilial( "DX5" ) + cBalanca )
				dbSelectArea( "DX6" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "DX6" ) + cId + cBalanca )
					If DX6_STATUS = "1"
						__lPsAuto   := ( DX6_MODAL = "0" .Or. DX6_MODAL = "2" )
						__lPsManual := ( DX6_MODAL = "1" .Or. DX6_MODAL = "2" )
						__lPsNao    := .f.
					Else
						Help(,,STR0010,, STR0011 , 1, 0 ) //# "Ajuda" ###"Usuario não autorizado a efetuar pesagens nesta balança!"
						__lPsNao := .t.
					EndIf
				Else
					Help(,,STR0010,,STR0014, 1, 0 )  //###"Ajuda###"Usuario não cadastrado para utilizar esta balança!"
					__lPsNao := .t.
				EndIf
				If __lPsAuto
					If .Not. AGRX003C( DX5->DX5_TIPPOR, DX5->DX5_TIPVEL, DX5->DX5_TIPPAR, DX5->DX5_NBITDA, DX5->DX5_NBITPA, DX5->DX5_TIMOUT, DX5->DX5_SCRIPT,DX5->DX5_TIPLEI,DX5->DX5_IPSERV,DX5->DX5_PORSER, DX5->DX5_INTLEI  )
						Help( , , STR0010, , STR0023, 1, 0 ) //###"Ajuda"###"Não sera possivel fazer pesagem automatica pois ha problemas na comunicação com a balança!"
						__lPsAuto := .f.
					EndIf
				EndIf
				If .Not. __lPsAuto .And. .Not. __lPsManual
					__lPsNao := .t.
	
				EndIf
			Else
				Help(,,STR0010,,STR0024, 1, 0 ) //###"Ajuda"###"Codigo da balança informado, não cadastrado!"
				__lPsNao := .t.
			EndIf
		EndIf
	
		RestArea( aAreaAtu )
	Else
		//--Habilita o pergunte para gravar o código da balança
		If Empty(cCodBal)
			Pergunte( cPergunte, lPergunta )
			cBalanca := MV_PAR01
		Else
			cBalanca := cCodBal
		EndIf
		
		AX003BPUSM(cId, Iif (.NOT. Empty(cBalanca),cBalanca,"")) //Busca balança por usuário sem mensagens
		
		If .NOT. _lUsuar		
			AX003BpGSM(cId, Iif (.NOT. Empty(cBalanca),cBalanca,""))
		EndIf 
		
		If .NOT. _lUsuar .AND. .NOT. _lGrupo
	//		Help(" ",1,"NOBALXUSR")"Não foi encontrado relacionamento de usuário ou grupo de usuário x balança. 
	//		Verifique se existe balança cadastrada no 'Cadastro de Balanças' e
	//		também se existe permissão no cadastro de 'Usuário x Balança' para o usuário ou o grupo de usuário."
			MsgAlert(STR0036)
			cBalanca := ""
		EndIf
		
		//--Se balança não for Vazia
		If .Not. Empty( AllTrim( cBalanca ) )
			DX5->(dbSelectArea("DX5"))	//Balanças
			DX5->(dbSetOrder(1))
			If DX5->(MsSeek(FWxFilial( "DX5" ) + cBalanca ))
				//--Para a balança com usuario
				IF _lUsuar 
					DX6->(dbSelectArea("DX6"))
					DX6->(dbSetOrder(1))
					If DX6->(MsSeek( FWxFilial("DX6") + cId + cBalanca ))
						If DX6->DX6_STATUS = "1"
							__lPsAuto   := ( DX6->DX6_MODAL = "0" .Or. DX6->DX6_MODAL = "2" )
							__lPsManual := ( DX6->DX6_MODAL = "1" .Or. DX6->DX6_MODAL = "2" )
							__lPsNao    := .f.
						Else
							Help(,,STR0010,, STR0011 , 1, 0 ) //# "Ajuda" ###"Usuario não autorizado a efetuar pesagens nesta balança!"
							__lPsNao := .t.
						EndIf
					
					Else	
						Help(,,STR0010,,STR0014, 1, 0 )  //###"Ajuda###"Usuario não cadastrado para utilizar esta balança!"
						__lPsNao := .t.
					EndIf
					
					If __lPsAuto
						If .Not. AGRX003C( DX5->DX5_TIPPOR, DX5->DX5_TIPVEL, DX5->DX5_TIPPAR, DX5->DX5_NBITDA, DX5->DX5_NBITPA, DX5->DX5_TIMOUT, DX5->DX5_SCRIPT,DX5->DX5_TIPLEI,DX5->DX5_IPSERV,DX5->DX5_PORSER, DX5->DX5_INTLEI  ) 
							Help( , , STR0010, , STR0023, 1, 0 ) //###"Ajuda"###"Não sera possivel fazer pesagem automatica pois ha problemas na comunicação com a balança!"
							__lPsAuto := .f.
						EndIf
					EndIf
					
					If .Not. __lPsAuto .And. .Not. __lPsManual
						__lPsNao := .t.
		
					EndIf
					DX6->(dbclosearea())
				EndIf	//_lUsuar
				
				//-- Para balança com grupo de usuario
				IF _lGrupo
					DX6->(dbSelectArea( "DX6" ))
					DX6->(dbGoTop())
					DX6->(dbSetOrder(3))
					If DX6->(MsSeek(FWxFilial("DX6") + _cGrp + cBalanca ))
						If DX6->DX6_STATUS = "1"
							__lPsAuto   := ( DX6->DX6_MODAL = "0" .Or. DX6->DX6_MODAL = "2" )
							__lPsManual := ( DX6->DX6_MODAL = "1" .Or. DX6->DX6_MODAL = "2" )
							__lPsNao    := .f.
						Else
							Help(,,STR0010,, STR0028 , 1, 0 ) //# "Ajuda" ###"Usuário do grupo não autorizado a efetuar pesagens nesta balança!"
							__lPsNao := .t.
						EndIf
					Else
						Help(,,STR0010,,STR0031, 1, 0 )  //###"Ajuda###"Usuário do grupo não cadastrado para utilizar esta balança!"
						__lPsNao := .t.
					EndIf
					
					If __lPsAuto
						If .Not. AGRX003C( DX5->DX5_TIPPOR, DX5->DX5_TIPVEL, DX5->DX5_TIPPAR, DX5->DX5_NBITDA, DX5->DX5_NBITPA, DX5->DX5_TIMOUT, DX5->DX5_SCRIPT,DX5->DX5_TIPLEI,DX5->DX5_IPSERV,DX5->DX5_PORSER, DX5->DX5_INTLEI  ) 
							Help( , , STR0010, , STR0023, 1, 0 ) //###"Ajuda"###"Não sera possivel fazer pesagem automatica pois ha problemas na comunicação com a balança!"
							__lPsAuto := .f.
						EndIf
					EndIf
					
					If .Not. __lPsAuto .And. .Not. __lPsManual
						__lPsNao := .t.
		
					EndIf
					DX6->(dbclosearea())
				EndIf	//_lGrupo
	
			Else
				Help(,,STR0010,,STR0024, 1, 0 ) //###"Ajuda"###"Código da balança informado não está cadastrado."
				__lPsNao := .t.
			EndIf
			DX5->(dbclosearea())
		EndIf
	
		RestArea( aAreaAtu )
	EndIf
	
Return( { cBalanca, __lPsAuto, __lPsManual, __lPsNao } )

/** {Protheus.doc} AGRX003F
Auxilia na estabilização da balaça

@author: 	Ricardo Tomasi
@since: 	12/07/2010
@Uso: 		Generico Agro
*/
Function AGRX003F(  )

	Local nFor01 	:= 0
	Local nPesoAux	:= 0
	Local nLastPeso := 0
	Local lPesoOk	:= .t.
	Local nOperacao :=  SuperGetMv('MV_AGRO042', , 1 )  // 1- nivel binario 2- nivel numerico 3- sem conferencia

	If nSeq >  nPsosVale1
		nSeq := 1
	EndIf

	nCap := AGRX003D( DX5->DX5_TIPPOR, DX5->DX5_TIPVEL, DX5->DX5_TIPPAR, DX5->DX5_NBITDA, DX5->DX5_NBITPA, DX5->DX5_TIMOUT, DX5->DX5_SCRIPT,DX5->DX5_TIPLEI,DX5->DX5_IPSERV,DX5->DX5_PORSER, DX5->DX5_INTLEI  )

	aCap[ nSeq ] := nCap

	oSay:Refresh()

	IF lEhTeste
		Return( .t. )
	EndIF
	// Verifica se o Ultimo Peso Capturado corresponde aos Outros Pesos já Capturados
	// Tratando com StrTran é para o Caso de Haver uma mascara com decimais
	// desta forma garanto que a funcao nAnd não retorne um resultado
	// errado poi a nAnd nao trabalha com numeros com casas decimais.

	If ExistBlock( 'AGRXFUNPS' )
		acap := ExecBlock('AGRXFUNPS',.F.,.F., {acap} )
	Endif
	IF nSeq == nPsosVale1

		lPesoOk	:= .t.
		for nfor01 := 1 to nPsosVale1 - 1

			nPesoAux  :=  Val(StrTran(StrTran(cvaltochar( acap[ nFor01     ] ),',',''),'.',''))
			nLastpeso :=  Val(StrTran(StrTran(cvaltochar( acap[ nPsosVale1 ] ),',',''),'.',''))
			If nOperacao == 1 //nível binario
				IF .not. nAnd( nLastPeso, nPesoAux ) == nLastPeso
					lPesoOk := .f.
					Exit
				EndIF
			ElseIf nOperacao == 2 //nivel numerico
				IF .not. nPesoAux == nLastPeso
					lPesoOk := .f.
					Exit
				EndIF		
			EndIf
		nExt nFor01

		IF lPesoOk
			nCap := aCap[ 1 ]
			oDlg:End()
		EndIF
	EndIF

	nSeq ++

Return( Nil )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRBoxTxt
Retorna a descrição de uma opção de um campo do tipo box

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: GENERICO
/*/
//------------------------------------------------------------------------------------------
Function AGRTxtBox(cOpc,cCpo)
	Local aAreaBox  := GetArea()
	Local cTextoBox := cOpc
	Local cCol1		:= ""
	Local lCol1		:= .F.
	Local cCol2		:= ""
	Local lCol2		:= .F.
	Local cSegTxt	:= ""
	Local cInSeg	:= ""
	Local aCBox		:= {}
	Local nBox

	cTxtBox := Posicione("SX3",2,cCpo,"X3_CBOX")

	For nBox := 1 to Len(cTxtBox)
		cInSeg := Substr(cTxtBox,nBox,1)
		If cInSeg == "="
			cCol1 := cSegTxt
			cSegTxt := ""
			lCol1 := .T.
		ElseIf cInSeg == ";" .or. nBox == Len(cTxtBox)
			If cInSeg <> ";"
				cCol2 := cSegTxt+cInSeg							/// SE ACABOU O TEXTO ADICIONA O ULTIMO CARACTER PENDENTE AO TEXTO
			Else
				cCol2 := cSegTxt
			Endif
			cSegTxt := ""
			lCol2 := .T.
		Else
			cSegTxt += cInSeg
		Endif
		If lCol1 .and. lCol2
			aAdd(aCBox,{cCol1,cCol2})
			lCol1 := .F.
			lCol2 := .F.
		Endif
	Next

	If ValType(aCBOx[Len(aCBOX),2]) == "U"					//// CASO SEJA UM COMBOBOX DE APENAS UMA OPCAO (1=Texto1) POR EXEMPLO
		aCBOx[Len(aCBOX),2] := cSegTxt
	Endif

	nInCBox := Ascan(aCBox,{|x| x[1] == cOpc })

	If nInCBox > 0
		If !Empty(aCBox[nInCBox,2])
			cTextoBox := aCBox[nInCBox,2]
		Endif
	Endif
	RestArea(aAreaBox)
Return cTextoBox

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRVLDS
Retorna se o código do produto possui complemento com dados válidos.

@param: cCodigo
@author: Cleber Maldonado
@since: 18/02/2013
@Uso: GENERICO
/*/
//------------------------------------------------------------------------------------------
Function AgrVldS(cCodigo)
	Local lRet := .T.

	dbSelectArea("SB5")
	dbSetOrder(1)

	If MsSeek(xFilial("SB5")+cCodigo) .And. SB5->B5_SEMENTE == "1"
		Do Case
			Case Empty(SB5->B5_CULTRA)
			lRet := .F.
			Case Empty(SB5->B5_CATEG)
			lRet := .F.
			Case Empty(SB5->B5_PENE)
			lRet := .F.
			Case Empty(SB5->B5_CTVAR)
			lRet := .F.
		EndCase
	Else
		lRet := .F.
	Endif

	If !lRet
		Help(,,STR0010,,STR0025, 1, 0 ) //###"Ajuda"###"Produto selecionado não tem complementos de sementes."
	Endif

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AgrxfunCfg
Funçaõ Auxiliar que Ajuda na Cfg. da Balança Mostrando Retorno e como
proceder para configura o campo script da DX5;

@param: cConteudo
@author: Emerson Celho
@since: 22122014
@Uso: GENERICO
@Retorno: Nennhum (Apenas mostra Mensagem explicativa de Como Proceder )
/*/
//------------------------------------------------------------------------------------------

Static Function AgrxfunCfg ( cConteudo )

	Local oFwLayer	:= Nil

	Local cEOL     := Chr(13) + Chr(10)
	Local oCN14_N	:= TFont():New("Courier New" ,,14,,.T.,,,,,.F.)  // Negrito

	Local oDlg		:= Nil
	Local nI	:= 0
	Local nx   := 0
	Default cConteudo := STR0009 //'Não foi possível Capturar o Retorno'

	IF Empty ( cConteudo )
		cConteudo := STR0026	// ###'Não foi possível Capturar o Retorno'
	ElseIF Len(cConteudo) < 32
		cConteudo := Padr(cConteudo,32, '')
	EndIF

	/*
	*------------------------------------------------------------+
	! Monta tela para seleção dos arquivos contidos no diretório !
	*------------------------------------------------------------+
	*/
	oDlg := TDialog():New( 0 /*aCords[ 1 ]*/, 0 /*aCords[ 2 ]*/, 330/*aCords[ 3 ]/1.8*/, 710/*aCords[ 4 ]/1.7*/, STR0001/*"Configuração de Balança"*/, , , , , CLR_BLACK, CLR_WHITE, , , .t. )
	oDlg:lEscClose := .F.

	//--<< Cria Layer >>--
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )


	//--<<Cria 3  colunas no Layer>>--
	oFwLayer:addCollumn('Col01',50,.F.)
	oFwLayer:addCollumn('Col02',25,.f.)
	oFwLayer:addCollumn('Col03',25,.f.)
	//--<< Cria 2 Janelas na Coluna da Esquerda do Layer >>--
	oFwLayer:addWindow('Col01','C1_Win01',STR0002/*'Retorno de comunicação com a balança'*/,030,.f.,.F.,{|| },,{|| })
	oFwLayer:addWindow('Col01','C1_Win02',STR0003/*'Atenção:'*/,060,.f.,.T.,{|| },,{|| })

	//--<<Cria 2 janela na Coluna da Direita >>--]
	oFwLayer:addWindow('Col02','C1_Win03',STR0004/*'Retorno da Balança Caracter a Caracter'*/,090,.f.,.T.,{|| },,{|| })
	oFwLayer:addWindow('Col03','C1_Win04',STR0004/*'Retorno da Balança Caracter a Caracter'*/,090,.f.,.T.,{|| },,{|| })
	//oPnDir := oFWLayer:GetColPanel( 'Col02' )

	//--<< pega o Painel das duas Janelas que estão na coluna 1 do Layer >>>--
	oPnLeft01 := oFwLayer:getWinPanel('Col01','C1_Win01')  // Get panel da Janela esquerda de cima
	oPnLeft02 := oFwLayer:getWinPanel('Col01','C1_Win02') // Get panel da Janela esquerda de baixo
	//--<< Pega o Panel das Janelas da Direita >--
	oPnLeft   := oFwLayer:getWinPanel('Col02','C1_Win03') // Get panel da Janela esquerda de baixo
	oPnRight  := oFwLayer:getWinPanel('Col03','C1_Win04') // Get panel da Janela esquerda de baixo


	//Get do Retorno da Balança
	@ 001, 001 GET oMultiGe1 VAR cConteudo OF oPnLeft01 MULTILINE SIZE 126, 019 COLORS 8404992, 16777215 READONLY HSCROLL PIXEL

	//Montando a mensagem abaixo do Retorno da Comunicação>>--
	aMsgem:={}
	cMensAux :=''

	nTamline := 48
	cMensagem:= STR0005 //"Ajuste o campo Script, para retornar somente os caracteres ref. ao peso;"

	aMsgem := justTexto( cMensagem , nTamLine)
	For nI:=1 to len (aMsgem)
		cMensAux+=aMsgem[nI]
		cMensAux+=cEOL
	next nI


	cMensagem:= STR0006 //"-Para isso identifique o Caracter que indica o inicio do envio dos dados;"
	aMsgem := justTexto( cMensagem , nTamLine)

	For nI:=1 to len (aMsgem)
		cMensAux+=aMsgem[nI]
		cMensAux+=cEOL
	next nI

	cMensagem:= STR0007 //"-Inclua uma formula no Campo Script Ex: Substr(cConteudo,at(Chr(002),cConteudo)+3,7);"
	aMsgem := justTexto( cMensagem , nTamLine)
	For nI:=1 to len (aMsgem)
		cMensAux+=aMsgem[nI]
		cMensAux+=cEOL
	next nI


	cMensagem:= STR0008 //"-É importante que utilize at() para identificar onde se inicia o peso, pois isto torna o retorno mais dinamico."
	aMsgem := justTexto( cMensagem , nTamLine)

	For nI:=1 to len (aMsgem)
		cMensAux+=aMsgem[nI]
		cMensAux+=cEOL
	next nI
	cMensAux+=cEOL

	//--<< Show msg, abaixo do Get de Retorno >>--
	oSay1      := TSay():New( 001,001,{||cMensAux},oPnLeft02,,oCN14_N,.F.,.F.,.F.,.T.,CLR_BLUE,/*CLR_WHITE*/,203,090)

	//--<< Jan. Direita mostro o Retorno caracter a Caracter com seu codigo Ascii >>--
	cChar	:=''
	aMsgem	:={}
	for nx:=1 to len(cconteudo)
		IF Substr(cconteudo,nX,1) == Chr(13)
			cChar:='CR'
		ElseIF Substr(cconteudo,nX,1) == Chr(10)
			cChar:='LF'
		Else
			cChar:= Substr(cconteudo,nX,1)
		EndIF
		aAdd(aMsgem, "Char[" + strzero(nx,2) + ']=' + Padl(cChar,2) + "    Asc=" + strzero(asc(cChar),3) )
	next
	//-->>Monto a Mensagem em Duas colunas O alianhamento so funciona pq utilizo fonte Courier new<<--
	cMensagem := ''
	for nX:=1 to 16  // Nr. de linhas do 1a. janela da col dir.
		cMensagem += aMsgem[nX] + cEol
	nExt nX

	cMensagem1:=''
	for nX:=17 to len(aMsgem)  // Alimenta o oSay, da Col direita Jan direita
		cMensagem1 += aMsgem[nX] + cEol
	nExt nX


	//Cria Label e Ancora na Janela da Direita
	oSay2      := TSay():New( 001,001,{||cMensagem},oPnLeft,,oCN14_N,.F.,.F.,.F.,.T.,CLR_BLUE,/*CLR_WHITE*/,203,200)
	oSay3      := TSay():New( 001,001,{||cMensagem1},oPnRight,,oCN14_N,.F.,.F.,.F.,.T.,CLR_BLUE,/*CLR_WHITE*/,203,200)

	//Botao Fechar
	oBtn1 := TButton():New( 150,315,"OK",oDlg,{|| oDlg:End()},040,010,,,,.T.,,"",,,,.F. )

	oDlg:Activate( , , , .t., { || .t. }, , { || } )
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} JustTexto
Funçaõ Auxiliar que Justifica texto passado, de acordo com o nr de caracteres
que é cabem na linha;
Atenção: Para a rotina runcionar sempre Utiliza-la mas o objeto q for receber
o texto seja ele de tela ou de impressão utilize fonte courier new que não dife-
rencia o tamanho do caracter, e trata todos caracteres com o mesmo tamanho. Ex.
o spaço tem o mesmo tamanho de uma letra M, e assim por diante.

@param: cTextEdit	=> Linha de texto com um Enter no final;
nTamcol  	=> tamanho da linha em caracteres ex. 60
@author: Emerson Celho
@since: 22122014
@Uso: GENERICO
@Retorno: Texto justificado .
/*/
//------------------------------------------------------------------------------------------

Static Function JustTexto(cTextEdit,nTamCol)
	********************************************
	Local r := 0
	Local t :=0
	Parameters cTextEdit, nTamCol

	//cTextEdit   := ""
	aTextResult := {}

	/*
	For s := 1 To Len( cTextJust )
	cTextEdit += AllTrim( cTextJust[s] ) + Space( 01 )
	Next s
	*/
	nTotLinhas  := MLCount( cTextEdit , nTamCol )

	For t := 1 To nTotLinhas
		aAdd( aTextResult , MemoLine( cTextEdit , nTamCol , t ) )
		nCodAsc  := 170
		aTextResult[t] := AllTrim( aTextResult[t] )
		aTextResult[t] := StrTran( aTextResult[t] , " " , Chr( nCodAsc ) )

		While .T.
			If Len( AllTrim( aTextResult[t] ) ) == nTamCol .Or. t == nTotLinhas
				For r := 170 To nCodAsc
					aTextResult[t] := StrTran( aTextResult[t] , Chr( r ) , " " )
				Next r
				Exit
			EndIf

			nPosSpaco := At( Chr( nCodAsc ) , aTextResult[t] )
			If nPosSpaco > 0
				aTextResult[t] := SubStr( aTextResult[t] , 1 , nPosSpaco - 1 ) + Space( 02 ) + ;
				SubStr( aTextResult[t] , nPosSpaco + 1 , ( nTamCol - ( nPosSpaco - 1 ) ) )
				aTextResult[t] := AllTrim( aTextResult[t] )
				aTextResult[t] := StrTran( aTextResult[t] , Chr( nCodAsc ) , Chr( nCodAsc + 1 ) )
			Else
				nPosSpaco := At( Space( 02 ) , aTextResult[t] )
				aTextResult[t] := SubStr( aTextResult[t] , 1 , nPosSpaco - 1 ) + Space( 03 ) + ;
				SubStr( aTextResult[t] , nPosSpaco + 2 , ( nTamCol - ( nPosSpaco - 2 ) ) )
			EndIf
			nCodAsc  += 1
		EndDo
	Next t

Return aTextResult

/*/{Protheus.doc} AX003BPUSM
 Busca balança por usuário sem mostrar alerta
@author silvana.torres
@since 12/11/2018
@version undefined
@param cId, characters, código do usuário
@param cBalanca, characters, balança
@type function
/*/
Function AX003BPUSM(cId, cBalanca)

	DX6->(dbSelectArea("DX6"))
	DX6->(dbSetOrder(1)) //Filial+usuario+balança
	
	If DX6->(MsSeek(FWxFilial( "DX6" ) + cId + cBalanca ))
	
		While .NOT. DX6->(Eof()) .AND. DX6->(DX6_FILIAL) = FWxFilial( "DX6" ) .AND. DX6->DX6_CODUSU = cId 
		
			If DX6->DX6_STATUS = "1" .AND. ((.NOT. Empty(cBalanca) .AND. DX6->DX6_CODBAL = cBalanca) .OR. Empty(cBalanca))
				If DX6->DX6_MODAL $ "1|2" //--1=Manual 2=Ambos
					//--Se todos os campos de data e hora não forem vazios - verifica os intervalos
					If .NOT. Empty(DX6->DX6_DTINI) .AND. .NOT. Empty(DX6->DX6_HRINI) .AND. .NOT. Empty(DX6->DX6_DTFIM) .AND. .NOT. Empty(DX6->DX6_HRFIM)
						//--Data do DIA/SISTEMA é maior que a Data GRAVADA?  
						//--Data do DIA/SISTEMA é menor que a DATA GRAVADA? 
						IF  ( dToS(Date()) + SubStr(Time(),1 ,5) >= dToS(DX6->DX6_DTINI) + DX6->DX6_HRINI ) .AND.;
						    ( dToS(Date()) + SubStr(Time(),1 ,5) <= dToS(DX6->DX6_DTFIM) + DX6->DX6_HRFIM )  
							_lUsuar := .T.
							Exit
						Else
							_lUsuar := .F.
						EndIf
					Else
						_lUsuar := .T.
						Exit						
					EndIf						
				Else
					_lUsuar := .T.
					Exit
				EndIf		
			EndIf
			
			DX6->(dbSkip())
		EndDo				
	EndIf
	DX6->(dbclosearea())
	
Return .T.

/*/{Protheus.doc} AX003BpGSM
Busca balança por grupo sem mensagem de alerta
@author silvana.torres
@since 12/11/2018
@version undefined
@param cId, characters, código do usuário 
@param cBalanca, characters, balança
@type function
/*/
Function AX003BpGSM(cId, cBalanca)
	
	Local nCont		:= 0
	Local aGrupos	:= {}
	
	aGrupos := UsrRetGrp( cUserName, cId)		//--Busca os grupos para o usuário logado
			
	for nCont := 1 to len(aGrupos)
		
		_cGrp := aGrupos[nCont]
		
		DX6->(dbSelectArea("DX6"))
		DX6->(dbGoTop())
		DX6->(dbSetOrder(3))
		
		If DX6->(MsSeek(FWxFilial( "DX6" ) + aGrupos[nCont] + cBalanca))	
		
			While .NOT. DX6->(Eof()) .AND. DX6->DX6_FILIAL = FWxFilial( "DX6" ) .AND. DX6->DX6_GRPUSR = aGrupos[nCont] .AND. DX6->DX6_STATUS = "1"	//1-Autorizado / 2-Desautorizado
				  
				If (.NOT. Empty(cBalanca) .AND. DX6->DX6_CODBAL = cBalanca) .OR. Empty(cBalanca) 
					If DX6->DX6_MODAL $ "1|2" //--1=Manual 2=Ambos
						//--Se todos os campos de data e hora não forem vazios - verifica os intervalos
						If .NOT. Empty(DX6->DX6_DTINI) .AND. .NOT. Empty(DX6->DX6_HRINI ) .AND. .NOT. Empty(DX6->DX6_DTFIM) .AND. .NOT. Empty(DX6->DX6_HRFIM)
							//--Data do DIA/SISTEMA é maior que a Data GRAVADA?  
							//--Data do DIA/SISTEMA é menor que a DATA GRAVADA? 
							IF  ( dToS(Date()) + SubStr(Time(),1 ,5) >= dToS(DX6->DX6_DTINI) + DX6->DX6_HRINI ) .AND.;
							    ( dToS(Date()) + SubStr(Time(),1 ,5) <= dToS(DX6->DX6_DTFIM) + DX6->DX6_HRFIM )
								_lGrupo := .T.
								Exit
							Else
								//Help(NIL, NIL, STR0010, NIL, STR0034 + Chr(10) + Chr(13) +  "[ " + STR0012 + cId + "; " + STR0013 + cBalanca + " ]", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0035})	
								//"Balança vinculada com usuário não disponivel."###"Usuário"###"Balança"###"Verifique com o administrador do sistema."
								_lGrupo := .F.
							EndIf
						Else
							_lGrupo := .T.
							Exit
						EndIf
					Else
						_lGrupo := .T.
						Exit
					EndIf	
				EndIf		
				
				DX6->(dbSkip())
			EndDo
		EndIf
		DX6->(dbclosearea())
		
		If _lGrupo 
			Exit
		EndIf
			
	nExt nCont

Return .T.

/*/{Protheus.doc} AGRXFUNBL
//--Função para validar a balança com usuario ou grupo de usuario
//--Função encontra-se no pergunte do grupo = AGRA500001
 
@author  ana.olegini
@since 	 07/05/2018

@param   cBalanca, characters, Codigo da balança informado no pergunte
@return  lRetorno, .T. para verdadeiro e .F. para falso
/*/
Function AGRXFUNBL(cBalanca)
	Local lRetorno 	:= .T.
	Local cId		:= __cUserID
	Local cNomeBal	:= ""
	
	Private _lUsuar	:= .F.
	Private _lGrupo	:= .F.
	Private _cGrp	:= ""
	
	DX5->(dbSelectArea("DX5"))
	DX5->(dbSetOrder(1))
	If DX5->(MsSeek(FWxFilial("DX5") + cBalanca))
		
		AX003BPUSM(cId, Iif (.NOT. Empty(cBalanca),cBalanca,"")) //Busca balança por usuário sem mensagens
	
		If .NOT. _lUsuar		
			AX003BpGSM(cId, Iif (.NOT. Empty(cBalanca),cBalanca,""))
		EndIf 
		
		If .NOT. _lUsuar .AND. .NOT. _lGrupo
	//		Help(" ",1,"NOBALXUSR")"Não foi encontrado relacionamento de usuário ou grupo de usuário x balança. 
	//		Verifique se existe balança cadastrada no 'Cadastro de Balanças' e
	//		também se existe permissão no cadastro de 'Usuário x Balança' para o usuário ou o grupo de usuário."
			MsgAlert(STR0036)
			cBalanca := ""
			lRetorno := .F.
		EndIf
		
		If lRetorno
			cNomeBal := DX5->DX5_DESCRI
		EndIf
	Else	
		MsgAlert(STR0024) //"Código da balança informado não está cadastrado."
		lRetorno := .F.
	EndIf
	
Return {lRetorno,cNomeBal}


/*/{Protheus.doc} AGRXFUNCN  
//Função da consulta especifica DX6GRP - Usur.Grp.X Balança

@author		Ana Laura Olegini
@since 		08/05/2018
@return 	lRetorno, Retorno lógico - .T. = True .F. = Falso
/*/
Function AGRXFUNCN()
	Local aArea     	:= GetArea()
	Local aFieldFilt 	:= {} 
	Local aSeek 		:= {}
	Local lRetorno     	:= .T.
	Local oBrowse		:= Nil
	Local oDlg	    	:= Nil
	Local oPnDown   	:= Nil
	Local oSize     	:= Nil

	Private _aColumns 	:= {}
	
	//-- Pega a proxima tabela
	__cAliasC 	:= GetNextAlias()
	
	//-- Cria tabela temporaria para browse
	__cAliasC := sFCriaTemp(@_aColumns , @__cAliasC)

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  	// Calculo vertical	
	oSize:Process() 			// Executa os calculos
					       /*nTop*/                  /*nLeft*/               /*nBottom*/              /*nRight*/              /*cCaption*/                  
	oDlg 	:= TDialog():New( oSize:aWindSize[1]/1.55, oSize:aWindSize[2]/1.55, oSize:aWindSize[3]/1.55, oSize:aWindSize[4]/1.55, STR0032 , , , , , CLR_BLACK, CLR_WHITE, , , .T. ) //--"Consulta Específica Usuários ou Grupos X Balança"
	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"), ,oDlg, ,.F. , , , ,oSize:GetDimension("ALL","COLEND")/1.57, oSize:GetDimension("ALL","LINEND")/1.90)

	//-- Filtros da consulta
	aAdd(aFieldFilt, {"DX6_CODBAL", AGRTITULO("DX6_CODBAL"), TamSX3("DX6_CODBAL")[3], TamSX3("DX6_CODBAL")[1], TamSX3("DX6_CODBAL")[2], PesqPict("DX6", "DX6_CODBAL")} )
	
	//-- Pesquisa Indice da consulta
	nTam := TamSX3("DX6_FILIAL")[1] + TamSX3("DX6_CODBAL")[1] + 3
	Aadd(aSeek,{ STR0033 ,{{"", 'C' , nTam, 0 , "@!" }}, 1, .T. } ) //"Filial + Cód. Balança"
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0032)		//"Consulta Específica Usuários ou Grupos X Balança"
	oBrowse:SetTemporary(.T.)	
	oBrowse:SetAlias(__cAliasC)
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetColumns(_aColumns)
	oBrowse:SetOwner(oDlg)	
	oBrowse:SetDoubleClick( {|| .T., oDlg:End() })	
	oBrowse:SetUseFilter(.T.)			//Habilita a utilização do filtro no Browse.
	oBrowse:SetdbFFilter(.T.)
	oBrowse:SetUseCaseFilter(.T.)		//Habilita a utilização do filtro case no Browse.
	oBrowse:SetFieldFilter(aFieldFilt)	//Indica os campos que serão apresentados na edição de filtros.
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:Activate(oPnDown)

	oDlg:Activate( , , , .T., { || .T. }, , { || EnchoiceBar(oDlg,{|| .T., oDlg:End()},{|| oDlg:End() },,/* @aButtons */) } )

	RestArea(aArea)

Return lRetorno


/*{Protheus.doc} sFCriaTemp
Função cria tabela temporaria 
Função da consulta especifica DX6GRP - Usur.Grp.X Balança

@author 	ana.olegini
@since 		08/05/2018
@param 		_aColumns, , descricao
@param 		__cAliasC, , descricao
@return 	return, return_description
*/
Static Function sFCriaTemp(_aColumns , __cAliasC)
	Local aIndices 	:= {}
	Local aCampIni2 := {}

	//Definindo as colunas do Browse	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'DX6_FILIAL'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("DX6_FILIAL"))	  
	_aColumns[Len(_aColumns)]:SetSize( TamSX3("DX6_FILIAL")[1] )
	_aColumns[Len(_aColumns)]:SetDecimal( TamSX3("DX6_FILIAL")[2] )
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento	

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'DX6_CODBAL'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("DX6_CODBAL"))	  
	_aColumns[Len(_aColumns)]:SetSize( TamSX3("DX6_CODBAL")[1] )
	_aColumns[Len(_aColumns)]:SetDecimal( TamSX3("DX6_CODBAL")[2] )
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento	

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'DX6_DESBAL'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(AGRTITULO("DX6_DESBAL"))
	_aColumns[Len(_aColumns)]:SetSize( TamSX3("DX6_DESBAL")[1] )
	_aColumns[Len(_aColumns)]:SetDecimal( TamSX3("DX6_DESBAL")[2] )
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento

	//Limpando temp Table - Funcao do AGRUTIL01
	If __oArqTemp <> Nil
		AGRDLTPTB(@__oArqTemp, NIL, .T.)
	EndIf

	//Definindo as colunas na temp table
	AADD(aCampIni2,{'DX6_FILIAL', TamSX3("DX6_FILIAL")[3],TamSX3("DX6_FILIAL")[1], TamSX3("DX6_FILIAL")[2]})		 	
	AADD(aCampIni2,{'DX6_CODBAL', TamSX3("DX6_CODBAL")[3],TamSX3("DX6_CODBAL")[1], TamSX3("DX6_CODBAL")[2]})
	AADD(aCampIni2,{'DX6_DESBAL', TamSX3("DX6_DESBAL")[3],TamSX3("DX6_DESBAL")[1], TamSX3("DX6_DESBAL")[2]})

	aAdd(aIndices, {"1", "DX6_FILIAL,DX6_CODBAL" })
	
	//-- Cria tabela temporaria - Funcao do AGRUTIL01
	__oArqTemp  := AGRCRTPTB(__cAliasC, {aCampIni2, aIndices },,,,.F. )	
	//-- Funcao cria consulta
	__cAliasC := sFCposCons( @__cAliasC )

Return __cAliasC


/*{Protheus.doc} sFCposCons
Funcao cria consulta 
Função da consulta especifica DX6GRP - Usur.Grp.X Balança

@author 	ana.olegini
@since 		08/05/2018
@param 		__cAliasC, Tabela Temporaria
@return 	__cAliasC, Tabela Temporaria  
*/
Static Function sFCposCons( __cAliasC )
	Local cId		:= __cUserID
	Local cGrp		:= ""
	Local aGrupos	:= {}
	Local aBalanca	:= {}
	Local nX		:= 0

	//-----------------------------------------------
	//--Validação de Usuários ou Grupos X Balança
	//- Tratamento referente a tarefa DAGROUBA-3789
	//-----------------------------------------------	
	dbSelectArea( "DX6" )
	DX6->(dbSetOrder(1))
	DX6->(dbGoTop())
	DX6->(MsSeek(FWxFilial("DX6")))
	
	//--Percorre toda a tabela até o primeiro registro
	While .NOT. Eof() .AND. DX6->(DX6_FILIAL) = FWxFilial( "DX6" ) 
		//--Verifica se o campo de usuário não está vazio
		If .NOT. Empty(DX6->(DX6_CODUSU)) 
			//--Verifica se o usuario é igual ao usuario logado
			If DX6->(DX6_CODUSU) == cId
				//--Verifica se o status esta como autorizado
				If DX6->(DX6_STATUS) = "1"	//1-Autorizado / 2-Desautorizado
					
					If DX6->(DX6_MODAL) $ "1|2" //--1=Manual 2=Ambos
						//--Se todos os campos de data e hora não forem vazios - verifica os intervalos
						If .NOT. Empty(DX6->(DX6_DTINI)) .AND. .NOT. Empty(DX6->(DX6_HRINI) ) .AND. .NOT. Empty(DX6->(DX6_DTFIM)) .AND. .NOT. Empty(DX6->(DX6_HRFIM))
							//--Data do DIA/SISTEMA é maior que a Data GRAVADA?  
							//--Data do DIA/SISTEMA é menor que a DATA GRAVADA? 
							If (Date() >= DX6->(DX6_DTINI) .AND. (Date() > DX6->(DX6_DTINI) .OR. SubStr(Time(),1 ,5) >= DX6->(DX6_HRINI))) .AND.;
							   (Date() <= DX6->(DX6_DTFIM) .AND. (Date() < DX6->(DX6_DTFIM) .OR. SubStr(Time(),1 ,5) <= DX6->(DX6_HRFIM)))
														   
								If (AScan(aBalanca, { |x| x[2] == DX6->(DX6_CODBAL)}) = 0)
									AADD(aBalanca,{ DX6->(DX6_FILIAL), DX6->(DX6_CODBAL) })
								EndIf
							EndIf
						Else
							If (AScan(aBalanca, { |x| x[2] == DX6->(DX6_CODBAL)}) = 0)
								AADD(aBalanca,{ DX6->(DX6_FILIAL), DX6->(DX6_CODBAL) })
							EndIf						
						EndIf
					Else 
						If (AScan(aBalanca, { |x| x[2] == DX6->(DX6_CODBAL)}) = 0)
							AADD(aBalanca,{ DX6->(DX6_FILIAL), DX6->(DX6_CODBAL) })
						EndIf
					EndIf
					
				EndIf	//--DX6->(DX6_CODUSU) == cId
			EndIf	//--DX6->(DX6_STATUS) = "1"
		EndIf	//--.NOT. Empty(DX6->(DX6_CODUSU)) 
		
		//--Verifica se o campo de grupo não está vazio
		If .NOT. Empty(DX6->(DX6_GRPUSR))
			//--Verifica se o status esta como autorizado
			If DX6->(DX6_STATUS) = "1"	//1-Autorizado / 2-Desautorizado			
				cGrp 	:= DX6->(DX6_GRPUSR)				//--Grupo informado no cadastro
				aGrupos := UsrRetGrp( cUserName, cId)		//--Busca os grupos para o usuário logado
				If (AScan(aGrupos, { |x| x == cGrp}) > 0)	//--Verifica se os grupos do usuário estão  
					//If (AScan(aBalanca, { |x| x[2] == DX6->(DX6_CODBAL)}) = 0)
					//	AADD(aBalanca, { DX6->(DX6_FILIAL), DX6->(DX6_CODBAL) })
					//EndIf
					If DX6->(DX6_MODAL) $ "1|2" //--1=Manual 2=Ambos
						//--Se todos os campos de data e hora não forem vazios - verifica os intervalos
						If .NOT. Empty(DX6->(DX6_DTINI)) .AND. .NOT. Empty(DX6->(DX6_HRINI) ) .AND. .NOT. Empty(DX6->(DX6_DTFIM)) .AND. .NOT. Empty(DX6->(DX6_HRFIM))
							//--Data do DIA/SISTEMA é maior que a Data GRAVADA?  
							//--Data do DIA/SISTEMA é menor que a DATA GRAVADA? 
							If (Date() >= DX6->(DX6_DTINI) .AND. (Date() > DX6->(DX6_DTINI) .OR. SubStr(Time(),1 ,5) >= DX6->(DX6_HRINI))) .AND.;
							   (Date() <= DX6->(DX6_DTFIM) .AND. (Date() < DX6->(DX6_DTFIM) .OR. SubStr(Time(),1 ,5) <= DX6->(DX6_HRFIM))) 
							   
								If (AScan(aBalanca, { |x| x[2] == DX6->(DX6_CODBAL)}) = 0)
									AADD(aBalanca,{ DX6->(DX6_FILIAL), DX6->(DX6_CODBAL) })
								EndIf
							EndIf
						Else
							If (AScan(aBalanca, { |x| x[2] == DX6->(DX6_CODBAL)}) = 0)
								AADD(aBalanca,{ DX6->(DX6_FILIAL), DX6->(DX6_CODBAL) })
							EndIf						
						EndIf							
					Else 
						If (AScan(aBalanca, { |x| x[2] == DX6->(DX6_CODBAL)}) = 0)
							AADD(aBalanca,{ DX6->(DX6_FILIAL), DX6->(DX6_CODBAL) })
						EndIf
					EndIf					
					
				EndIf	//--(AScan(aGrupos, { |x| x == cGrp}) > 0)
			EndIf	//--DX6->(DX6_STATUS) = "1"
		EndIf	//--.NOT. Empty(DX6->(DX6_GRPUSR))
		DX6->(dbSkip())
	EndDo
	
	//--Percorre todas as balancas encontradas referente ao usuário ou grupo de usuario
	For nX := 1 TO Len(aBalanca)
		Reclock(__cAliasC, .T.)
			(__cAliasC)->DX6_FILIAL	:=  aBalanca[nX][1]
			(__cAliasC)->DX6_CODBAL :=  aBalanca[nX][2]
			(__cAliasC)->DX6_DESBAL	:=  Posicione("DX5",1,FWxFilial("DX5")+aBalanca[nX][2],"DX5_DESCRI")
		(__cAliasC)->( MsUnlock())
	Next nX

Return __cAliasC


/*{Protheus.doc} AGRXFUNRT
Função de retorno da consulta 
Função da consulta especifica DX6GRP - Usur.Grp.X Balança

@author 	ana.olegini
@since 		08/05/2018
@return 	Sequência da Operação
*/
Function AGRXFUNRT()
	Local cRetorno := (__cAliasC)->DX6_CODBAL
	
	DX6->(dbclosearea())
	(__cAliasC)->(dbclosearea())
	
Return cRetorno


