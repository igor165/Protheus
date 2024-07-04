#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGXTEL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "JPEG.CH"
#INCLUDE "FILEIO.CH"   
#INCLUDE "SMARTCTI.CH"   

#DEFINE USE_MODEM  		"1"
#DEFINE USE_CTI    		"2"
#DEFINE USE_MANUAL		"3"    
#DEFINE USE_SMARTCTI	"4"

#DEFINE RECEPTIVO  1
#DEFINE ATIVO      2

Static nHandle  	:= -1 	//Handle da CTI se a DLL nao estiver aberta ( nHandle == -1 ) significa que e necessario abrir a comunicacao com a mesma
Static lHold    	:= .F.	//Ligacao em espera
Static lPause   	:= .F.
Static lRecPlay 	:= .F.
Static lReceptAct 	:= .F.  // Modo Receptivo (Listner) esta Ativado com .T.
Static lSgCTILog  	:= .F.  // Grava ou nao o LOG
Static lAbreCti		:= .F.
Static lLinhaAtiva	:= .F.
Static cCodUsLog	:= IIF(TYPE("__cUserID") = "U",SPACE(6),__cUserID)  

//Variaveis do SmartCTI - Inicio
Static oAgtSmartCTI 	:= NIL         	//Instancia do objeto AgentSmartCTI.  
Static lShowMessage 	:= .F.         	//Controla a exibicao de mensagens apos o envio de comandos pela interface de
											//usuario. 
Static lInCall 		:= .F.				//Indica se ha uma chamada ativa no ramal
Static lCallInHold 	:= .F.				//Indica se ha uma chamada na espera
Static oBtnPausa    	:= Nil				//Objeto do botão de Pausa
Static oSayMsg	   		:= Nil				//Objeto do label indicando Status de pausa na tela. 
Static cMultiGrp    	:= ""				//Grupos para enviar logon/logoff ready e not ready usando apenas 1 comando (grupos separados por vírgula - Digitro)

Static aIDCham			:= {}				//Array para armazenar o CallID.

Static lMotObrig	:= .T.					// Indica se o Motivo da Ligação será obrigatorio

//Variaveis do SmartCTI - Fim

/*
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Codigos de solicitacao para a SIGACTI.DLL	

	01 - Conexao Ativa		
	02 - Login do Agente		
	03 - Logout do Agente		
	04 - Discagem Externa - REALIZACAO DE CHAMADAS - DISCAGEM VIA CTI
	05 - Recepcao de Ligacao	
	06 - Transferencia de Chamada
	07 - Conferencia		
	08 - Consulta ao Supervisor		
	09 - Chamada em Espera		
	10 - Retorno de Chamada em Espera		
	11 - Usuario Disponível		
	12 - Usuario em Pausa		
	13 - Pendulo (Alterna entre chamadas)		
	14 - Cancelamento de Chamadas		
	15 - Status de Chamada		
	16 - Status do Usuario		
	17 - Fax		
	18 - Siga-me		
	19 - Pendencias
	20 - Inicio de Gravacao
	21 - Fim de Gravacao 
	22 - Reproducao da Gravacao
	23 - LISTA AS CTI'S HOMOLOGADAS
	24 - Discagem via Modem
	25 - Encerra comunicacao com Modem
	26 - FECHAMENTO DA CTI
	27 - Pulso Verificador
    31 - Atender
    32 - Desligar
    33 - Recepcao de Ligacao Ativa
    99 - Leituras das strings de tradução da tela de discagem do modem
	999 - VERSAO DA SIGACTI.DLL

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Tabela com codigo de retorno do Middle
	
	00	Sucesso
	01	Usuario Invalido
	02	Numero de Telefone Invalido
	03	Opcao Invalida
	04	Arquivo de Fax nao Encontrado
	05	Identificacao de Chamada Invalida
	06	Identificacao de Chamada Existente
	07	Tamanho da Solicitacao Invalido
	08	Sem Tom de Discar
	09	Sem Toque
	10	Ocupado
	11	Nao Responde
	12	Atendido por Maquina
	13	Atendido por Fax
	14	Destinatario Desligou durante a Saudacao
	15	Falha Durante o Envio de Fax

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Tabela com codigo de retorno da API
	
	01 Erro de retorno do Equipamento CTI ( Nao respondeu a um comando enviado )
	03 Erro ao registrar o Equipamento CTI ( Padrao: GENERIC )
	05 Erro ao Ativar CTI
	06 Erro ao Conectar a CTI
	07 Erro ao Desconectar a CTI
	08 Erro ao Efetuar uma ligacao
	09 Erro ao Receber uma ligacao
	10 Erro ao Transferir uma ligacao
	11 Erro ao criar uma conferencia
	12 Erro ao criar uma consulta 
	13 Erro Hold
   	14 Erro UnHold                                  
	15 Erro ao ativar um usuario
	16 Erro ao efetuar uma pausa
	17 Erro ao alteranar uma ligacao
	18 Erro ao abortar uma ligacao
	19 Erro ao checar o status da ligacao
	20 Erro ao checar o status do usuario
	21 Erro ao efetuar uma chamada para FAX
	22 Erro Follow-me
	23 Erro chegar Pendencias
	24 Erro ao iniciar a gravacao
	25 Erro ao Finalizar a gravacao	
	26 Erro ao executar uma gravacao
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SigaCall  ºAutor  ³Marcelo Kotaki        º Data ³  07/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abertura de um novo REMOTE para o LISTNER DE LIGACAO         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function SigaCall( lPergunta )

Local cComand   := ""									// Linha de comando
Local cArqDel	:= ""									// Arquivo de recepcao da CTI para o PROTHEUS
Local aLixo	 	:= {}									// Array com os arquivos do usuario logado que ja estao no diretorio de recepcao
Local lTMKOPLI  := ExistBlock( 'TMKOPLI' )				// P.E. para validacao do LISTENER - com espera de retorno
Local aRet		:= IIF(lTMKOPLI,{},NIL)					// Array de retorno do P.E. 
Local lRet		:= .T.									// Flag para uso do Listner - SEMPRE DEFAULT = TRUE
Local cTela 	:= "28|"+STR0056+"|"					// Atendimento Receptivo
Local cDirTX 	:= SGDirTx()	            			// Funcao para pegar o diretorio de TX	
Local cDirRX 	:= SGDirRx()							// Funcao para pegar o diretorio de RX 
Local cTipoCTI  := TkPosto(TkOperador(),"U0_TIPOCTI")   // Tipo de Hardware do cadastro de estacao
Local nCont 	:= 0									// Contador 

//Implementacao do SmartCTI - Inicio
Local cPIN 	:= ""                                      	// Codigo do operador no CTI
Local cGroup:= ""										// Codigo do DAC no CTI 
Local oEvts
Default lPergunta := .T.
//Implementacao do SmartCTI - Fim
               
//Pergunta se deseja habilitar o recebimento de ligações telefônicas ?                      
If lPergunta .AND. FindFunction("SGPergunta")
	lRet := SGPergunta() 
	If !lRet 
	   Return(.T.)
	Endif   
Endif


If cTipoCTI <> USE_CTI .AND. cTipoCTI <> USE_SMARTCTI	// 2 - Cti .AND. 4 - SmartCTI  
	Help(" ",1,"SEMCTI")
	Return(lRet)
Endif	

If Funname(1) == "SIGACALL"
   MsgInfo(STR0155,STR0156)
   //"Sr. usuário, para que a integração com o equipamento de Telefonia funcione corretamente, por favor, entre novamente no sistema.","Atenção"
   Return(.T.)	
Endif


// Validacao de BARRAS 
If Subs(cDirTX,Len(cDirTX),1) <> "\"
	cDirTX += "\"
Endif

If Subs(cDirRX,Len(cDirRX),1) <> "\"
	cDirRX += "\"
Endif
cArqDel	:= cDirRX+__cUserID+".CTI"  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apaga qualquer arquivo que tenha sido "esquecido" no diretorio de RX          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoCTI == USE_CTI
	aLixo := Directory(cArqDel)
	For nCont := 1 TO Len(aLixo)
		Ferase(ALLTRIM(cDirRx)+aLixo[nCont][1])
	Next nCont	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para a validacao do Listner e alteracao dos diretorios de TROCA - TX e RX ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKOPLI
	aRet := ExecBlock( 'TMKOPLI', .F., .F., {} )
	If (ValType(aRet) <> "A")
		lRet := .T.
	Else
		lRet := IIF(ValType(aRet[1]) == "L",aRet[1],.T.) 
	Endif
Endif

lSgCTILog := SuperGetMV("MV_TKCTILG",.F.)   //Verifica se deve gravar ou nao um log das operacoes com a SIGACTI
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
Do Case 
	Case cTipoCTI == USE_CTI	//2 - CTI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz a abertura da DLL³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SGOpen(__cUserId)        
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se ja existe uma instancia do atendimento receptivo no ar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !SgListnerOn(cTela)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conseguir abrir a DLL³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAbreCTI
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conecta o usuario na CTI³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SGLoginUser() //Usuario,Ramal		
		                If lRet         		                	
							cComand := GetRemoteExeName() + " -Q -P=SGPOPUP -E="  +;  			 				 // Funcao de PopUp
										GetEnvServer() + " -A=" +;   			             // Ambiente do Servidor
										cEmpAnt + "|" + cFilAnt + "|"  +;    			             // Empresa e Filial
										StrZero(nModulo,2)      + "|"  +;				             // Modulo
										ALLTRIM(__cUserID)	    + "|"  +;   			             // Codigo do Usuario
										" -M"    						    			             // Multiplas Instancias
														
							lReceptAct := .T. // Receptivo ativo
							
							WinExec(cComand)
						Endif
					Endif
				Endif
			Endif
		Endif
			
	Case cTipoCTI == USE_SMARTCTI .AND. nModulo == 13	//4 - SmartCTI | Verifica se é modulo 13 para não abrir quando for outros módulos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz a abertura da API³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
		SGVerifGrpAtendDAC()
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
		lRet := SMCTIOpen(__cUserId)
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-2"),)
		oEvts := TMKAActiveEvt():New()
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-3"),)
		oAgtSmartCTI:AddEventListener(TMKAActiveEvt():New())	//Adiciona a classe de eventos	
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-4"),)				
		If lRet         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Conecta o usuario na CTI³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := SMCTILoginUser(@cPIN, @cGroup) //Realiza o Login no CTI	 
			If lRet				                 
				cComand := GetRemoteExeName() +  " -Q -P=SGPOPUP -E="  +;			 	 // Funcao de PopUp
							GetEnvServer() + ' -A="' +;   			       			     // Ambiente do Servidor
							SgCodePar(Encript(cEmpAnt + "|" + cFilAnt + "|"  +;    			     // Empresa e Filial
							StrZero(nModulo,2)      + "|"  +;				             // Modulo
							ALLTRIM(__cUserID)	    + "|"  +;   			             // Codigo do Usuario
							cTipoCTI    			+ "|"  +;    			             // Tipo de CTI
							Trim(cPIN) 				+ "|"  +;							 // Codigo do operador no CTI
							Trim(cGroup)    		+ "|"  +;							 // Codigo do DAC no CTI														
							Trim(oAgtSmartCTI:cDevice)    		 + "|"  +;				 // Número do ramal														
							AllTrim(Str(oAgtSmartCTI:iLinkID)) 	 + "|"  +;				 // Identificador do Middleware
							AllTrim(oAgtSmartCTI:cAgentPass)	 + "|",0),0)  +;				 // Senha do Agente																																			
							'" -M'                         							     // Multiplas Instancias
											
				lReceptAct := .T. // Receptivo ativo														
				WinExec(cComand)
			EndIf
		EndIf
		If !lRet
			MsgInfo(STR0159,"")				//Não foi possível iniciar o Listener de Ligações
			If MsgYesNo(STR0193,STR0001)	// "Deseja Tentar Novamente ?"#"Listner de Ligação"
				oAgtSmartCTI:Close()
				oAgtSmartCTI := NIL
				SigaCall()
			EndIf			
		EndIf
End Case
	
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)	
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGOpen()  ³ Autor ³Marcelo Kotaki             ³ Data ³07/05/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Abre a SIGACTI.DLL				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MP8    						                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGOpen(cCod)

Local nRet    	:= 0					// Codigo de Retorno da funcao de abertura
Local cCti    	:= SuperGetMV("MV_TMKCTI")	// Tipo de CTI/URA/CT que esta sendo utilizada Ex: Lucent , Generic
Local cServer 	:= SuperGetMV("MV_TMKSERV")	// Nome da maquina onde esta o servidor da CTI/URA/CT utilizada
Local cPort   	:= SuperGetMV("MV_TMKPORT")	// Porta onde o PROTHEUS CLIENT vai se conectar	
Local aBuffer 	:= {}					// Array com a composicao dos parametros do arquivo de TX
Local lRet	  	:= .F.					// Retorno dessa funcao
Local aUser		:= {}					// Array auxiliar 
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario utiliza CTI e se existe uma configurada ³ 
//³Se a DLL nao estiver aberta ( nHandle == -1 ) significa que e ³
//³necessario abrir a comunicacao com a mesma					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nHandle < 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pela codigo do usuario logado no PROTHEUS - SIGACFG³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
	PswOrder(1)
	If PswSeek(cCod)
       aUser := PswRet(1)
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abre a comunicacao com a DLL e determina o HANDLE dessa comunicacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	    If SGDllOpen()     
			Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-2"),)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o usuario esta configurado adequadamente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aUser) > 0
				If !Empty(aUser[1][19]) .AND. !Empty(cCti)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se pode continuar ou se esta com incompatibilidade de versao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SGCTIVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Abre a comunicacao com solicitacao "0"³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nRet := SGSendCti(0 , {cCti + "|" + cServer + "|" + cPort}, @aBuffer)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o retorno foi positivo³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (nRet >= 0)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se abriu a comunicacao manda o comando de CONEXAO ATIVA  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nRet := SGActive()
						If nRet >= 0
							lRet := .T.
						Endif	    
                
					Endif
				Endif	
		
			Endif
		Endif	
		
	Endif
Endif

Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)		
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGCTIVer  ³ Autor ³Marcelo Kotaki         ³ Data ³07/05/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a compatibilidade da SigaCTI e o RPO               ³±±
±±³          ³Para chamar esta funcal e necessário que a sigaCTI ja esteja³±±
±±³          ³com a comunicacao aberta.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MP8 														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGCTIVer()

Local nRet 		:= -1                	// Retorno negativo
Local cCti   	:= SuperGetMV("MV_TMKCTI")	// Modelo da CTI			
Local aBuffer 	:= {}					// Parametros
Local cVersion  := SGCheckVer()			// Versao da SIGACTI.DLL
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
nRet := SGSendCti( 999 , {cCti} , @aBuffer )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o retorno foi negativo ou a versao da DLL e diferente do BUILD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nRet == -2) 

	// "A SIGACTI.DLL e ou SIGACTI.INI nao encontrada ou com problemas, 
	// verifique se a mesma esta no diretorio do Protheus Remote. 
	// Ex: c:\ap6\bin\remote"
	MsgStop(STR0059) 
	Final(STR0028) // "Incompatibilidade com a SIGACTI.DLL"
	
ElseIf (nRet == -1) .OR. (aBuffer[1] < cVersion)
	// "Existe incompatibilidade entre a versao do Repositorio do Protheus com a SIGACTI.DLL","Por favor, atualize os arquivos SIGACTI.INI e SIGACTI.DLL versao: "
	// "Voce pode obter a nova versao no endereco: ftp://ftp.microsiga.com.br/Ap6/1-Master/Sigacti/." "Atencao"	

	MsgStop(STR0025 + Chr(13)+Chr(10) + STR0026 + cVersion + Chr(13)+Chr(10) + STR0079, STR0027) 
	Final(STR0028) // "Incompatibilidade com a SIGACTI.DLL"

ElseIf aBuffer[1] > cVersion
	//"Existe incompatibilidades entre a versao do Repositorio Protheus e a SIGACTI.DLL Por favor, atualize o Repositório Protheus.","Atencao"
	MsgStop(STR0025 + Chr(13)+Chr(10) + STR0029 , STR0027) 
	Final(STR0028) //"Incompatibilidade com a SIGACTI.DLL"
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGCheckVer³ Autor ³Marcelo Kotaki         ³ Data ³07/05/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de verssao da SIGACTI.DLL                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ VERSAO ³        ³SINTAXE DO CODIGO DA VERSAO               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³04/02/03  ³0.2.2.1 ³        ³                                          ³±±
±±³          ³        ³        ³                                          ³±±
±±³          ³        ³        ³                                          ³±±
±±³          ³        ³        ³ 9.9.9.1                                  ³±±
±±³          ³        ³        ³ - - - -                                  ³±±
±±³          ³        ³        ³ | | | |                                  ³±±
±±³          ³        ³        ³ | | | +----> ID                          ³±±
±±³          ³        ³        ³ | | +------> Qtd.de Eqtos. Homologados   ³±±
±±³          ³        ³        ³ | +--------> Versao da DLL               ³±±
±±³          ³        ³        ³ +----------> Atualizado mediante as      ³±±
±±³          ³        ³        ³              manutencoes efetuadas.      ³±±
±±³          ³        ³        ³                                          ³±±
±±³15/09/04  ³0.3.3.2 ³        ³Funcao para leitura das STR,no SIGACTI.INI³±±
±±³27/07/05  ³0.3.3.3 ³        ³Validacao do handle na SIGACTI.DLL p/ MDI ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MP8	  						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGCheckVer()
Return("0.3.3.3")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGActive  ³ Autor ³Marcelo Kotaki         ³ Data ³07/05/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a CTI esta ativada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MP8	  						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGActive()

Local nRet    := -1			// Retorno negativo
Local nTipSol := 1			// Tipo da Solicitacao 1
Local aBuffer := {}			// Parametros
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
nRet := SGSendCti( nTipSol , {}, @aBuffer)
If nRet >= 0
	lAbreCTI := .T.
Else
	lAbreCTI := .F.
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)	
Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SGSendCti    ³ Autor³Marcelo Kotaki       ³Data  ³ 07/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia os dados da solicitacao do PROTHEUS para a CTI       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MP8  												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGSendCti(nTipSol, aParam, aBuffer)

Local nCont	 	:= 0 						// Contador auxiliar
Local cParam 	:= ""						// Composicao do arquivo de TX - baseado no manual da SIGACTI	
Local cBuffer	:= SPACE(500)			   	// Parametros de composicao do arquivo TX	
Local nRet   	:= -1                      	// Codigo de Retorno da funcao enviada a SIGACTI.DLL
Local cComando 	:= ""                      	// Codigo do Comando para gravacao do LOG.
Local cDirTX 	:= SGDirTx()	            // Funcao para pegar o diretorio de TX	
Local cDirRX 	:= SGDirRx()				// Funcao para pegar o diretorio de RX 
Local cCodAux 	:= SPACE(6)					// Codigo auxiliar com o codigo do usuario da 1 Thread e da 2 Thread
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o usuario for identificado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __cUserId <> NIL
	cCodAux	:= __cUserId
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para garantir a integridade da variavel de memoria    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodAux)
	cCodAux := cCodUsLog		// Se a variavel de memoria do Protheus esta com NIL, assume a variavel auxliar criada na 2 THREAD
Endif

// Validacao de BARRAS 
If Subs(cDirTX,Len(cDirTX),1) <> "\"
	cDirTX += "\"
Endif

If Subs(cDirRX,Len(cDirRX),1) <> "\"
	cDirRX += "\"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a DLL esta aberta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle >= 0 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o Protheus estiver TRANSMITINDO grava o LOG      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipSol <> 5

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia dados para a CTI³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cParam := ALLTRIM(Str(nHandle)) + "|" + cCodAux + "|" + cDirTX + "|" + cDirRX + "|"
		
		If (Len(aParam) > 0)
			For nCont := 1 To Len(aParam)
				cParam += aParam[nCont] + "|"
			Next nCont
		Endif
		
		cBuffer	:= cParam+SPACE(500-Len(cParam))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente se nao for atendimento receptivo grava o LOG³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ProcName(1) <> "SGOPEN"
			cComando := ALLTRIM(StrZero(nTipSol,2,0))
		Else
			cComando := ALLTRIM(Str(nTipSol))
		Endif	
		SgLogDLL(TRIM(cBuffer), ProcName(1), TRIM(Str(ProcLine(1))), .T.,cComando )
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa pela DLL o comando solicitado pelo usuario ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := ExeDllRun2( nHandle, nTipSol, cBuffer)
			
	Else
		    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existem algum arquivo para o Protheus no diretorio de RECEPCAO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := MsAvalOut(nTipSol,@cBuffer,cDirRx)
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avaliar o retorno do arquivo de TX e de RX ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SGCheckRet(nRet,nTipSol,cBuffer,@aBuffer)

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao abriu retorna -2 - Indica que a DLL nao esta no diretorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet := -2 
	
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³SGDllOpen  ³ Autor ³Marcelo Kotaki        ³ Data ³  07/05/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se a SIGACTI.DLL esta aberta                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³MP8	      									   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                     
Static Function SGDllOpen()

Local lRet		:= .F.		// Retorno da Funcao
Local cBuffer	:= ""		// Idioma
Local cIdioma 	:= ""

Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
cIdioma := Upper( Left( FWRetIdiom(), 2 ) )
Do Case
	Case cIdioma == 'PT'
		cBuffer	:="POR"
	Case cIdioma == 'ES'
		cBuffer	:= "ESP"
	Case cIdioma == 'EN'
		cBuffer	:="ING"
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o HANDLE de abertura for negativo tenta abrir a SIGACTI.DLL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0

	nHandle := ExecInDLLOpen("SIGACTI.DLL")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao conseguiu abrir a DLL - Causas: Nao esta no diretorio ou a versao do Windows esta incorreta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nHandle >= 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Na abertura da DLL, seta a lingua que esta sendo executado para definir as strings do formulario  ³
		//³de discagem (MODEM),  atraves do arquivo SIGACTI.INI                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBuffer	:= ALLTRIM(Str(nHandle)) + "|" +cBuffer+'|'
		nRet 	:= ExeDllRun2( nHandle, 99, cBuffer)
		If nRet >= 0
			lAbreCTI := .T.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorna TRUE confirmando a abertura da DLL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet	 := .T.	
		Endif	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao foi encontrado do arquivo SIGACTI.INI para os outros idiomas ou nao conseguiu abrir a DLL³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nRet == 9) .OR. (nRet < 0) 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecha a DLL 				   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ExecInDllClose(nHandle)

			lRet := .F.
		Endif

	Endif
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SGCheckRet   ³ Autor³Marcelo Kotaki       ³Data  ³ 07/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Avalia o retorno do comando enviado pela CTI para o PROTHEUS³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³MP8	  												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGCheckRet(nRet, nTipSol, cBuffer, aBuffer)

Local cComando 	:= ""		// Descricao do comando para registro do LOG 
Local cDescErro := ""		// Descricao do erro retornado
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Le o resultado da resposta enviada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBuffer:= SGReaDbuf("|",cBuffer)

If Len(aBuffer) > 2 
	cComando := TRIM(aBuffer[2])
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente se nao for Atendimento receptivo ou ativo grava o LOG³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nTipSol <> 5) .AND. (nTipSol <> 33)
	SgLogDLL(TRIM(cBuffer), ProcName(2), TRIM(Str(ProcLine(2))), .F.,cComando)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o retorno foi positivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nRet > 0)                
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a mensagem esta completa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Len(aBuffer) >= 3 ) 
	
		Help(" ",1,"ERROCTI",,;
			Chr(10)+Chr(13) + STR0063 + aBuffer[2]+ " - " + SGRetSlCod( Val(aBuffer[2]) )+; //"Enviado: "
			Chr(10)+Chr(13) + STR0064 + aBuffer[3]+ " - " + Iif(Len(aBuffer)>=4,aBuffer[4],""),3,5) 				//"Retornado: "
	Else
		MsgStop(STR0123) // Falha na comuicação da CTI com o Protheus - Contacte o fabricante
	Endif
	
ElseIf (nRet < 0)   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avalia qual foi o tipo de erro e retorna a descricao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDescErro := SgAvalErro(nRet)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se retornou TimeOut no pulso verificador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipSol == 27 
		lReceptAct := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o retorno foi negativo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help(" ",1,"ERROCTI",,cDescErro + ALLTRIM(Str(nRet)) ,3,5) //"Erro na execucao da solicitacao!" "Retorno"
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(nRet)

/*
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGPOPUP   ºAutor  ³Marcelo Kotaki        º Data ³  04/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara o ambiente da Tela Principal para o 2¦ Remote         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MP8                                                           º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGPopUp(cParam)
Local cTheme  := GetTheme() 		// Tema definido no INI do SRV (Ocean/Classic)
Local aScreen := GetScreenRes()     // Array com as dimensoes da Tela Pai
Local oWSpaceFolder
Local oWSpace1
Local cPrmAx := ""
Public cCurrentACDGroup	:= ""		//Grava o Grupo DAC da última chamada atendida

Private oMainWnd					// Owner ficticio
cPrmAx := Encript( cParam , 0 )//Parâmetro auxiliar
cParam := Encript(SgCodePar(cParam,1),1)
//Define tema Ocean quando não houver tema setado ou STANDARD (Fontes brancas em botao branco fica ilegivel) 
If Trim(cTheme) == "" .OR. cTheme == "STANDARD"
	cTheme = "OCEAN"
EndIf
PtSetTheme(cTheme)

oMainWnd := TWindow():New( 0, 0, 0, 0, STR0194,,,,,,,,CLR_BLACK,CLR_WHITE,,,,,,,.T. ) //"Protheus - Call Center"
 
oWSpaceFolder := TWorkspaceFolder():New(oMainWnd,0,0,0,0)
oWSpaceFolder:Align := CONTROL_ALIGN_ALLCLIENT

oWSpace1 := TWorkSpace():New(STR0001, oWSpaceFolder) //Listener de Ligações
 
oMainWnd:bInit := {|self| SGDialog(cParam,cPrmAx) }   
oMainWnd:Activate("MAXIMIZED")  
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGDialog  ºAutor  ³Marcelo Kotaki      º Data ³  12/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela com o Remote de Listener de comunicacao	      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MP8                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGDialog(cParam,cPrmAx)

Local oDlgWait     	       						// Tela do Listner
Local oTimer              						// Timer para ler o conteudo do diretorio de RX
Local cEmp       	:= ""						// Empresa   	
Local cFil       	:= ""						// Filial	 
Local aParam     	:= {}    					// Array com os parametros recebidos da 1 thread
Local aUser      	:= {}    					// Array com dados do usuario 
Local lPulso	 	:= .T.						// Envia o sinal de pulso - comando 27   
Local oFont			:= Nil						// Fonte utilizada para exibir as informações do operador

//Implementacao do SmartCTI - Inicio
Local cTipoCTI		:= USE_CTI					// Tipo de CTI	- padrão: 2 - SigaCTI
Local cPIN                                     	// Codigo do operador no CTI
Local cGroup                                    // Codigo do DAC no CTI
Local cDevice									// Numero do ramal
Local iLinkID									// Identificacao do Middleware
Local cAgentPass								// Senha do Agente
Local AgentState	:= 0						// Estado do agente logado no ramal no Grupo
// AgentState: [(25=LOGOUT) - (26=LOGIN) - (27=POS_ATENDIMENTO) - (28=LIVRE) - (29=OCUPADO) - (30=PAUSA)]
//Implementacao do SmartCTI - Fim

Local nI		:= 0							// Controle de Loop
Local nQtdGroup := 0							// Quantidade de Grupos de Atendimento do Operador
Local aObjects 	:= {}										// Usado para divisão da tela
Local lSendReadyInLogon := .T.						// indica se envia comando de ready (Disponicel) ao logar no protheus
Local oPanTop
Local oPanBot
Local cTextHtml   
Local oList     		//Objeto Tlistbox
Local aDac := {}        // Array com os grupos dac's
Local nList := 0        
Local oFontDAC          //Fonte para cabecalho dos grupos dac

Private nModulo    := 99    					// O listner nao conta como novo usuario
Private lRefresh   := .T.   					// Atualizacao de Tela 
Private lMSHelpAuto:= NIL   					// Atualizacao de Tela 
Private __cInterNet:= NIL   					// Indica se esta sendo utilizado pelo browser
Private lProspect  := .F.                       // Prospect TRUE ou FALSE 	
Private cEstacao   := ""						// Codigo da Estacao (TEF)
Private nModAnt    := 0     					// Modulo anterior (13) ou (97)

Default cPrmAx := ""

Public iSMLinkID								// Identificacao do Middleware (Publica para poder acessar do Fonte TMKARECEPTIVEEVT)
  
lReceptAct := .T. 								// Modo de atendimento Receptivo esta ATIVO

AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Separa os parametros recebidos			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aParam   := SGReaDbuf("|", cParam, .T.)

If Empty( aParam ) .And. !Empty( cPrmAx )
	cPrmAx := Encript( cPrmAx , 1 )
	If At( "|" , cPrmAx ) > 0
		aParam := SGReaDbuf( "|" , cPrmAx , .T. )
		If ValType( aParam ) <> "A"
			aParam := {}
		EndIf
	EndIf
EndIf

If Len(aParam) > 0
	cEmp     := aParam[1]
	cFil     := aParam[2]
	nModAnt  := Val(aParam[3])
	If Len(aParam) > 4 
		cTipoCTI 	:= aParam[5]
		cPIN	 	:= aParam[6]
		cGroup	 	:= aParam[7]
		cMultiGrp	:= cGroup
		cDevice	 	:= aParam[8]
		iLinkID	 	:= Val(aParam[9])
		iSMLinkID 	:= iLinkID                                      
		cAgentPass	:= aParam[10]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o codigo STATIC porque esta na 2 thread³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodUsLog := aParam[4]
	PswOrder(1)
	If PswSeek(cCodUsLog)
		aUser := PswRet(1)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o ambiente de trabalho			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RPCSETTYPE(3)
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil FUNNAME "SGPOPUP" TABLES "SA1","SU5","SU7","SUS","SUV","SU0","SUA","SUB","SUC","SUD","SUK","ACI","SU8","SU4","SU6","AGI"
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO-POS EXECUÇÃO PREPARE ENVIRONMENT"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o usuario a ser utilizado pela thread³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__cUserId := cCodUsLog

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta as variaveis para a exibicao dos helps ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqHlp     := "SIGAADV" + RetExtHlp() 	// Nome do arquivo de HELP
__cInterNet := NIL
HELP        := .F.
lMSHelpAuto := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para a validacao do usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !SgCheckUser()
	Return(.F.)
Endif

lSgCTILog := SuperGetMV("MV_TKCTILG")   // Verifica se deve gravar ou nao um log das operacoes com a SigaCTI
lPulso	  := SuperGetMV("MV_TMKCT27")   // Verifica se vai gerar nao o comando de pulso para a CTI         
lSendReadyInLogon := SuperGetMV("MV_TKREADY",,.T.)   // Verifica se envia comando de disponível (Ready) ao logar
//lMACD := SuperGetMV("MV_TMKMACD",,.F.)   // Indica se um grupo de atendimento pode contar mais de um grupo DAC (ACD)

nConfTimer			:= SuperGetMV("MV_TMKTIME",,100000)  	//Parametro com o tempo do Timer
lConfAgState		:= SuperGetMV("MV_TMKAGST",,.F.) 		//Parametro que indica se vai ser utilizado o AgentState na verficação

Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO-1"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a CTI esta ativa					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cTipoCTI == USE_SMARTCTI
		SMCTIOpen(cCodUsLog, cDevice, iLinkID, .F., cAgentPass)			
		oAgtSmartCTI:AddEventListener(TMKAReceptiveEvt():New())	//Adiciona a classe de eventos
		//Habilita a exibicao de mensagens da API
		oAgtSmartCTI:EnableUserMsg(.T.)		
		If lSendReadyInLogon
			oAgtSmartCTI:Ready("", "")
		EndIF
	Case cTipoCTI == USE_CTI
		SGOpen(cCodUsLog)   
	Otherwise
		SGOpen(cCodUsLog)   
End Case		
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-1"),)
//Configura o bloco de codigo para a substituição do SystemStatus pelo AgentState
If !lConfAgState
	bSubSyStatus := {||IIF(!SMSystemStatus(),(lReceptAct := .F.,oDlgWait:End()),"")}
Else
	bSubSyStatus := {||IIF(!SGCheckAgState(),(lReceptAct := .F.,oDlgWait:End()),"")}
EndIf

DEFINE MSDIALOG oDlgWait FROM 0,0 TO 220,420 PIXEL TITLE STR0056 STYLE DS_MODALFRAME //"Atendimento Receptivo"/
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
oDlgWait:lEscClose := .F.
SetKEY( 24, NIL)
SetKEY( -33, NIL)

oPanTop := TPanel():New( 0, 0, , oDlgWait, , , , , , 0, 0, ,  )
oPanTop:Align := CONTROL_ALIGN_ALLCLIENT     

oPanBot := TPanel():New( 0, 0, , oDlgWait, , , , ,/*CLR_YELLOW*/, 0, 25 , )
oPanBot:Align := CONTROL_ALIGN_BOTTOM

DEFINE FONT oFont NAME "Arial" SIZE 0,14 
oFontDAC:=TFont():New('Arial',,14,,.T.)
	
	cTextHtml := SGGetAgTxt() //Label com Dados e Status do Agente 

	@ 02,02 SAY oSayMsg Var cTextHtml PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanTop 
	@ 30,31.5 SAY STR0199 SIZE 50 , 8 FONT oFontDAC	OF oPanTop PIXEL  //Cod.DAC 
	@ 30,61 SAY STR0200	SIZE 50 , 8 FONT oFontDAC	OF oPanTop PIXEL  //Num.DAC 
	@ 30,91 SAY STR0201	SIZE 50 , 8 FONT oFontDAC	OF oPanTop PIXEL  //Nome do Grupo 
	aDac:=SGPRODAC(cMultiGrp)  // Array para o TListBox
	oList:= TListBox():New(2.8,4, {|u| if( Pcount( )>0, nList:= u,nList ) } ,@aDac,150,40,,oDlgWait) // List que mostra todos os grupos dac's logado

	If(cTipoCTI == USE_SMARTCTI)
		@ 05,10 BUTTON OemToAnsi(STR0174) SIZE 50,14 MESSAGE STR0176 OF oPanBot PIXEL ;  	//Desconectar
			ACTION (lReceptAct := .F.,oDlgWait:End())
		//Verifica Status do agente para montar tele indicando pausa ou disponível
		AgentState := (oAgtSmartCTI:AgentState(oAgtSmartCTI:cDevice))
		@ 05,80 BUTTON oBtnPausa PROMPT OemToAnsi(STR0181) SIZE 50,14 MESSAGE STR0179 + chr(13) + chr(10) + STR0180 OF oPanBot PIXEL ;  	//Indisponível
		ACTION (TkSndPausa(/*aGAtend, */oBtnPausa, oSayMsg,(IIf(cTipoCTI == USE_SMARTCTI, oAgtSmartCTI:cDevice,SgRetRamal()))))
		If (AgentState = 30) .OR. (AgentState = 16)//Agente em pausa
			TkUpdNotReady()
		Else
			TkUpdReady()
		EndIf
		@ 05,152 BUTTON oBtnTroca PROMPT STR0202 SIZE 50,14 MESSAGE STR0196 OF oPanBot PIXEL ;  	//Alterar Grupo DAC#"Exibe tela para seleção de Grupos DAC"
		ACTION (SndCom(.F.,{}),SndCom(.T.,SGNewScreen()),oList:SetArray(SGPRODAC(cMultiGrp))) //Manda Logoff para os grupos ja logados e 1 comando de Logon para os selecionados na tela
									
	Else
		@ 05,152 BUTTON OemToAnsi(STR0002) SIZE 50,14 OF oPanBot PIXEL ;  	//Cancelar
			ACTION (IIf(cTipoCTI <> USE_SMARTCTI,(oTimer:End(),oTimer1:End()),""),lReceptAct := .F.,oDlgWait:End())	
	EndIf	
	
	If(cTipoCTI == USE_SMARTCTI)
		DEFINE TIMER oTimer1 INTERVAL nConfTimer ACTION Eval(bSubSyStatus) OF oDlgWait	        	
	Else
		DEFINE TIMER oTimer INTERVAL 1000 ACTION SGReceiveCall(oTimer,nModAnt) OF oDlgWait
		DEFINE TIMER oTimer1 INTERVAL nConfTimer ACTION IIF(!SGPulse(oTimer1),oDlgWait:End(),"") OF oDlgWait					
	EndIf                               
	
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-1"),)	
If(cTipoCTI == USE_SMARTCTI)	
	ACTIVATE MSDIALOG oDlgWait CENTER ON INIT (oTimer1:Activate())
Else
	ACTIVATE MSDIALOG oDlgWait CENTER ON INIT (oTimer:Activate(),IIF(lPulso,oTimer1:Activate(),""))
EndIf	
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o usuario realmente cancelou o LISTNER - o FLAG do atendimento nao sera mais receptivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lReceptAct := .F.

Do Case
	Case cTipoCTI == USE_SMARTCTI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desconecta o usuario da CTI ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SMCTILogOut(cPIN, cGroup) 
		
	Case cTipoCTI == USE_CTI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desconecta o usuario da CTI ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SGLogOut()
		                
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha a DLL 				   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ExecInDllClose(nHandle)
	Otherwise
		SGOpen(cCodUsLog)   
End Case

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reseta o ambiente de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RESET ENVIRONMENT
MS_QUIT()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaGrupoSU0  ºAutor  ³VENDAS - CRM          º Data ³  23/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta array com os grupos do operador encontrados na SU0           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function MontaGrupoSU0(aGrupo, nQtd, cCodSU0)
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
	DbSelectArea("SU0")//Tabela de Grupos de Atendimento
	DbSetOrder(1)
	DbSeek(xFilial("SU0") + cCodSU0)
	While !SU0->(Eof()) .AND. SU0->U0_FILIAL == xFilial("SU0") .AND. SU0->U0_CODIGO==cCodSU0 ;
		.AND. AllTrim(SU0->U0_ACDGRP) <> ""

		AAdd(aGrupo,{.F., SU0->U0_CODIGO, SU0->U0_NOME, SU0->U0_ACDGRP })
		nQtd += 1
		SU0->(DbSkip())
	End
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)	
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkSndPausa     ºAutor  ³VENDAS - CRM          º Data ³  06/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manda comando de Ready/NotReady                                    º±±
±±º          ³A atualização do botão de do label ocorre pelo evento do PABX.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function TkSndPausa(/*aGrpAtend, */oBtn, oSayMsg, cRamal)
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
	If lPause //Tira Pausa (Fica disponível)
		oAgtSmartCTI:Ready(AllTrim(Posicione("SU7", 1, xFilial("SU7") + TkOperador(), "U7_AGENTID")),cMultiGrp)
	Else //Fica em pausa (Indisponível)
		oAgtSmartCTI:NotReady(AllTrim(Posicione("SU7", 1, xFilial("SU7") + TkOperador(), "U7_AGENTID")),cMultiGrp)
	EndIF
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkSndCom       ºAutor  ³VENDAS - CRM          º Data ³  14/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manda comando de Logon/Logoff para os grupos que estiverem selecio-º±±
±±º          ³nados na tela de selecao de Grupos (armazenados em cMultiGrp)      º±±
±±º          ³Os grupos estao separados por virgula                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function SndCom(lCom, aACDGRPAt)
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
	If lCom
		oAgtSmartCTI:Logon(AllTrim(Posicione("SU7", 1, xFilial("SU7") + TkOperador(), "U7_AGENTID")),cMultiGrp)
	Else
		oAgtSmartCTI:Logoff(AllTrim(Posicione("SU7", 1, xFilial("SU7") + TkOperador(), "U7_AGENTID")),cMultiGrp)
	EndIF
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkVerifCanLogoffºAutor  ³VENDAS - CRM          º Data ³  14/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se pode deslogar ou não                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                                º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function TkVerifCanLogoff()
	Local lRet
	Local nI
	Local nFound := 0
	lRet = .T.
	For nI = 1 to Len(oLbx:aArray)
		If oLbx:aArray[nI,1]
			nFound += 1
		EndIF
	Next
	If nFound = 1 .AND. oLbx:AArray[oLbx:nAt,1] //Significa que a pessoa está tentando deslogar do único grupo logado.
		msgalert(STR0183) //Não é possível deslogar de todos os grupos!
		lRet = .F.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGReceiveCall  ºAutor  ³Marcelo Kotaki        º Data ³  04/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe mensagens no diretorio de recepcaos do usuario  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Static Function SGReceiveCall(oTimer, nModAnt)

Local aBuffer    := {}	// Retorno da DLL
Local nCall 	 := 0 	// Tipo de ligacao que foi enviada pela CTI - ATIVA ou RECEPTIVA
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
nModulo := nModAnt
ProcessMessages()
oTimer:DeActivate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe ligacao ATIVA OU RECEPTIVA para o usuario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SGSendCti( 5, {}, @aBuffer) == 0) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe os dados do cliente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(aBuffer) >= 5) // Verifica se a mensagem esta completa
		If aBuffer[2] == "05"
			nCall := RECEPTIVO
		Else
			nCall := ATIVO
		Endif			
		SgLogDLL(TRIM(aBuffer[5]), ProcName(0), ALLTRIM(Str(ProcLine(0))), .F.,TRIM(aBuffer[2]) )
		SGShowProfile(aBuffer, nModAnt,nCall)
	Endif
Endif

oTimer:Activate()
ProcessMessages()
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
nModulo := 99
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGLoginUserºAutor  ³Marcelo Kotaki         º Data ³  04/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza a tabela SUV - com os Usuarios que serao Receptivos    º±±
±±º          ³O registro tem um Flag marcado com Lock() - indica que o        º±±
±±º          ³Operador esta ativo e pronto para receber a transferencia dos   º±±
±±º          ³chamados                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGLoginUser()

Local lRet   := .F.						// Retorno da funcao
Local lLock  := .T.						// Flag para o registro	
Local nTipSol:= 2						// Comando
Local aUser  := {}						
Local aParam := {}
Local aBuffer:= {}
Local cServer:= SuperGetMV("MV_TMKSERV")
Local cTmp	 := SPACE(4)
Local oDlgRamal
Local nRet	 := -1
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o modulo for o Call Center verifica se o posto de venda trabalha como ATIVO     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AMIIn(13,73) .AND. !SgRotina()
	MsgStop(STR0113,STR0027) //"O Operador nao esta cadastrado para ser Receptivo","Atencao"
	Return(lRet)
Endif
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as informacoes do usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PswOrder(1)
If PswSeek(cCodUsLog)
	aUser := PswRet(1)
Endif		

// Nome
Aadd(aParam,ALLTRIM(aUser[1][2]))

// Senha
Aadd(aParam,ALLTRIM(aUser[1][3]))

// Ramal 
cTmp := aUser[1][20]

// Verifica se o ramal utilizado é o mesmo cadastrado no configurador
DEFINE MSDIALOG oDlgRamal FROM 0,0 TO 070,200 PIXEL TITLE STR0061 //"Ramal"

	@ 05,10 SAY STR0060 SIZE 70,10 OF oDlgRamal PIXEL //"Infome seu ramal atual"
	@ 15,10 MSGET oGetRamal VAR cTmp PIXEL SIZE 40,10 OF oDlgRamal VALID !Empty(cTmp)
   
	@ 15,55 BUTTON STR0062 SIZE 40,12 OF oDlgRamal PIXEL ACTION oDlgRamal:End() //"Confirmar"
		
ACTIVATE MSDIALOG oDlgRamal CENTER

// Atualiza o array de usuario
aUser[1][20] := ALLTRIM(cTmp)

//Ramal
Aadd(aParam,ALLTRIM(aUser[1][20]))

//Grupo
Aadd(aParam,ALLTRIM(aUser[1][12]))

//Server
Aadd(aParam,ALLTRIM(cServer))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza um lock no registro para assim indicar que o usuário esta ativo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aUser[1][19])
	DbSelectArea("SUV")
	DbSetOrder(1)
	If DbSeek(xFilial("SUV") + cCodUsLog)
		lLock:= .F.
	Endif
	
	RecLock("SUV",lLock)
	UV_FILIAL  := xFilial("SUV")
	UV_USUARIO := cCodUsLog
	UV_RAMAL   := cTmp
	DbCommit()       
	MsUnLock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia o comando de LOGIN DO AGENTE para a CTI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet := SGSendCti( nTipSol, aParam, @aBuffer) 
	If nRet >= 0 
		lRet:= .T.
	Endif
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGLogOut  ºAutor  ³Marcelo Kotaki         º Data ³  04/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza na tabela SUV - quais os atendentes INATIVOS e SEM    º±±
±±º          ³FLAG de LOCK                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGLogOut()

Local aBuffer:= {}
Local nRet	 := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desloga o usuario na CTI - Se o resultado for positivo muda o FLAG da variavel lABRECTI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRet := SGSendCti( 3, {}, @aBuffer)
If nRet == 0 
	lAbreCTI := .F.
Endif	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGShowProfile ºAutor  ³Marcelo Kotaki       º Data ³  04/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Screen-Pop para ligacoes                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MP8	                                                           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SGShowProfile(ExpA1, ExpN2, ExpN3, ExpC4)           			   ³±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Buffer de dados recebido do CTI.                        ³±±
±±³          ³ ExpN2 = Numero do modulo anterior.                              ³±±
±±³          ³ ExpN3 = Tipo de chamada. (ATIVO/RECEPTIVO)                      ³±±
±±³          ³ ExpO1 = Tipo de CTI utilizado pelo operador.                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGShowProfile(aBuffer,	nModAnt,	nCall,	cTipoCTI)

Local cCodCont  	:= ""       							// Codigo do Contato
Local cNomeCont 	:= ""									// Nome do Contato
Local cTelCont  	:= ""									// Telefone do Contato
Local cEmailCont	:= ""									// E-mail do Contato
Local cCodCli   	:= ""									// Codigo do Cliente
Local cLojaCli  	:= ""									// Lojda do Cliente
Local cNomeCli  	:= ""									// Nome do Cliente
Local cTelCli   	:= ""									// Telefone do Cliente	
Local cEmailCli 	:= ""									// Email do Cliente
Local cHPageCli 	:= ""       							// Site do Cliente
Local oDlg													// Tela
Local nButton   	:= 0			
Local nLin      	:= 0
Local nHeight  		:= 330
Local lPopCTI   	:= ExistBLock( 'POPCTI' )	   			// P.E. para inclusao de botoes especificos
Local lTKPopUp  	:= ExistBLock( 'TKPOPUP' )   			// P.E. para substituicao da tela de POP-UP 	
Local lRet			:= .T.						   			// Retorno do P.E. TKPopUp
Local cEntAlias		:= ""						   			// Alias
Local nCont 		:= 0 
Local cTela 		:= '28|'+STR0003+'|'		   			//Perfil de cliente
Local cNomeEnt		:= ""						   			//Nome da entidade que devera aparecer na tela do Receptivo
Local oHashDic		:= NIL						   			//HashTable contendo as informações do CTI quanto Tipo==4
Local lIncNew		:= .F.									//Inidca se foi adicionado um novo chamado na ligação recebida pela tela de teleatendimento.
Local lIUDB			:= SuperGetMV("MV_TMKIUDB",,.F.)   		//Indica se os dados da chamada vem pelos dados associados, ou se é necessário buscar via base de dados. Se for via base de dados, o Protheus recebe um ID (indice da tabela) junto com o número de B (ID = Ultimos 5 dígitos do número de B)
Local nX

Local oTelefonia	:= Nil
Local oMenu01 		:= Nil

Default cTipoCTI := USE_CTI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizo novamente o codigo do usuario pela variavel publica para manter a compatibilizacao com o Protheus³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__cUserId := cCodUsLog

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o nModulo para o codigo real do modulo para poder acesar as rotinas de dados dos clientes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nModulo:= nModAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica quem e o contato e o cliente.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIUDB
	aBuffer[4] := "5"	//Indica que os dados da chamada vem via Base de Dados.
End IF
SGDataRead( aBuffer[4], aBuffer[5] , @cCodCont , @cNomeCont,;
			@cTelCont , @cEmailCont, @cCodCli  , @cLojaCli,;
			@cNomeCli , @cTelCli   , @cEmailCli, @cHPageCli,;
			@cEntAlias, @oHashDic  , aBuffer[6], aBuffer[7])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para a exibicao de tela de usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTKPopUp
   lRet := U_TKPOPUP(	cCodCont, cNomeCont, cTelCont, cEmailCont,;
           			  	cCodCli , cLojaCli , cNomeCli, cTelCli,;
			           	cEmailCli, cHPageCli,aBuffer	,nCall)
	If ValType(lRet) == "L"
		If !lRet
	   		Return(.T.)                       
	   	Endif
	Endif   		
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para criacao de novos botoes na tela de POP-UP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPopCTI        
	aBtnCTI:= U_POPCTI(@cCodCli,@cLojaCli,@oDlg)                

	If (ValType( aBtnCTI ) == "A") .AND. (Len(aBtnCti) > 0)
		nHeight+= (Len(aBtnCti) * 15) + 40
	Endif
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
If nCall == 1 // RECEPTIVO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tela Principal                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomeEnt :=	Posicione("SX2",1,cEntAlias,"X2NOME()") 
	cNomeEnt :=	IIf(!Empty(cNomeEnt),cNomeEnt,STR0014)
	DEFINE MSDIALOG oDlg FROM  16,0 TO nHeight,510 TITLE STR0056 + " - " + cNomeEnt PIXEL //"Atendimento Receptivo - [Nome da entidade]"
	
		//Dados do Contato
	
		@ 01, 3 TO  60 , 200 OF oDlg  PIXEL
		@ 10, 10 SAY STR0010  SIZE 50 , 8 OF oDlg PIXEL COLOR CLR_RED	//"Contato"
		@ 10, 50 SAY cCodCont SIZE 100, 8 OF oDlg PIXEL
	
		@ 20, 10 SAY STR0011	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Nome"
		@ 20, 50 SAY cNomeCont	SIZE 100, 8	OF oDlg PIXEL
	
		@ 30, 10 SAY STR0012	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Telefone"
		@ 30, 50 SAY cTelCont	SIZE 100, 8	OF oDlg PIXEL
	
		@ 40, 10 SAY STR0013	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"E-mail"
		@ 40, 50 SAY cEmailCont	SIZE 100, 8	OF oDlg PIXEL
	
		//Dados do Cliente
	
		@ 65, 3 TO  125, 200 OF oDlg  PIXEL

		@ 70, 10 SAY STR0158 + "/" + STR0119 SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_BLUE	//"Código/Loja"
		@ 70, 50 SAY cCodCli + cLojaCli	SIZE 100, 8	OF oDlg PIXEL
	
		@ 80, 10 SAY STR0011	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_BLUE	//"Nome"
		@ 80, 50 SAY cNomeCli	SIZE 100, 8	OF oDlg PIXEL
	
		@ 90, 10 SAY STR0012	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_BLUE	//"Telefone"
		@ 90, 50 SAY cTelCli	SIZE 100, 8	OF oDlg PIXEL
	
		@ 100, 10 SAY STR0013 	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_BLUE	//"E-mail"
		@ 100, 50 SAY cEmailCli	SIZE 100, 8	OF oDlg PIXEL
	
		@ 110, 10 SAY STR0015	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_BLUE	//"Web Site"
		@ 110, 50 SAY cHPageCli	SIZE 100, 8	OF oDlg PIXEL
	
		@ 04, 207 BUTTON STR0004  SIZE 44, 11	OF oDlg PIXEL ACTION (SGButton(1, cCodCli, cLojaCli, cCodCont, cEntAlias))	//"Telemarketing"
		@ 18, 207 BUTTON STR0005  SIZE 44, 11	OF oDlg PIXEL ACTION (SGButton(2, cCodCli, cLojaCli, cCodCont, cEntAlias)) 	//"Televendas"
		@ 33, 207 BUTTON STR0006  SIZE 44, 11	OF oDlg PIXEL ACTION (SGButton(3, cCodCli, cLojaCli, cCodCont, cEntAlias)) 	//"Telecobranca"
		@ 48, 207 BUTTON STR0007  SIZE 44, 11	OF oDlg PIXEL ACTION (SGButton(4, cCodCli, cLojaCli, cCodCont, cEntAlias))	//"Financeiro"
		@ 63, 207 BUTTON STR0008  SIZE 44, 11	OF oDlg PIXEL ACTION (SGButton(5, cCodCli, cLojaCli, cCodCont, cEntAlias))	//"O.Servicos" 
		
		If SuperGetMV("MV_TMKPESQ",,.F.) 
			@ 78, 207 BUTTON STR0009  SIZE 44, 11	OF oDlg PIXEL ACTION (SGPesqCli(@cCodCont,@cNomeCont,@cEmailCont,@cCodCli,@cNomeCli,@cTelCli,@cEmailCli,@cHPageCli,@cEntAlias ,oDlg))	//"Contatos"  
		Else 
			@ 78, 207 BUTTON STR0009  SIZE 44, 11	OF oDlg PIXEL ACTION (SGButton(6, cCodCli, cLojaCli, cCodCont, cEntAlias))	//"Contatos"
		EndIf 
		
		@ 93, 207 BUTTON STR0021 SIZE 44, 11 OF oDlg PIXEL ACTION (SGButton(7, cCodCli, cLojaCli, cCodCont, cEntAlias, cTipoCTI, oHashDic, @lIncNew), oDlg:End(), nModulo:= 99)   //"Atender"		

		   
		nLin:= 108
		
		If lPopCTI        
			If ValType( aBtnCTI ) == "A"
				If !Empty( aBtnCTI ) 

					If (Len(aBtnCTI) > 7) 
						nButton := 7
					Else
						nButton := Len(aBtnCTI)
					Endif
						
					nLin:= 93
					For nCont:= 1 To nButton 		                       
						TButton():New(nLin, 207,ALLTRIM(aBtnCTI[nCont,1]), oDlg ,aBtnCTI[nCont,2],44,12,,,.F.,.T.,.F.,,.F.,,,.F.)
			
						nLin+= 15
					Next nCont
				Endif	
			Endif
	
		Else
			@ 93, 207 BUTTON STR0021 SIZE 44, 11 OF oDlg PIXEL ACTION (SGButton(7, cCodCli, cLojaCli, cCodCont, cEntAlias, cTipoCTI, oHashDic, @lIncNew), oDlg:End(), nModulo:= 99)   //"Atender"		
	    	
	    	//Botão de Telefonia
	    	oMenu01 := tMenu():new(0, 0, 0, 0, .T., , oDlg)

			//Monta os botões no item do Menu
			SGMnuAtivo(,,,,,,,,,,,,,,,,,,,@oMenu01,.T.)

			@ 108, 207 BUTTON oTelefonia PROMPT STR0205  SIZE 44, 11	OF oDlg PIXEL 	//"Telefonia"

			oTelefonia:setPopupMenu(oMenu01)
			
	    Endif
	   
	   nLin+= 15
	   DEFINE SBUTTON FROM nLin,213 TYPE 2 ACTION (oDlg:End(), nModulo:= 99) ENABLE OF oDlg  // Cancelar
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-1"),)
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (SGListnerOn(cTela), SendToFore())
	Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-2"),)
	If FindFunction("TK010Anota") .And. AliasInDic("AGK")
		TK010Anota(AllTrim(TkOperador()), lIncNew, val(aBuffer[7])/*Numero de B*/,lMotObrig)
	EndIf
	
	If aBuffer[4] == "5" .And. FindFunction("P_TMKFIMAT")
		P_TMKFIMAT( aBuffer[6], aBuffer[7], aBuffer[5] )
	EndIf

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tela Principal                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
	cNomeEnt :=	Posicione("SX2",1,cEntAlias,"X2NOME()") 
	cNomeEnt :=	IIf(!Empty(cNomeEnt),cNomeEnt,STR0014)	
	DEFINE MSDIALOG oDlg FROM  16,0 TO 210,410 TITLE STR0170 + " - " + cNomeEnt PIXEL  //"Atendimento Ativo"
	
		//Dados do Contato

		@ 01, 3 TO  40 , 200 OF oDlg  PIXEL COLOR CLR_RED
		@ 10, 10 SAY STR0010	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Contato"
		@ 10, 50 SAY cCodCont	SIZE 100, 8	OF oDlg PIXEL COLOR CLR_RED
	
		@ 20, 10 SAY STR0011	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Nome"
		@ 20, 50 SAY cNomeCont	SIZE 100, 8	OF oDlg PIXEL COLOR CLR_RED               
	
		@ 30, 10 SAY STR0012	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Telefone"
		@ 30, 50 SAY cTelCont	SIZE 100, 8	OF oDlg PIXEL COLOR CLR_RED
	
		//Dados do Cliente

		@ 45, 3 TO  80, 200 OF oDlg  PIXEL COLOR CLR_RED
		@ 50, 10 SAY STR0158	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Codigo"
		@ 50, 50 SAY cCodCli 	SIZE 100, 8	OF oDlg PIXEL COLOR CLR_RED
	
		@ 50, 90 SAY STR0171	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Loja"
		@ 50,110 SAY cLojaCli	SIZE 100, 8	OF oDlg PIXEL COLOR CLR_RED
	
		@ 60, 10 SAY STR0011	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Nome"
		@ 60, 50 SAY cNomeCli	SIZE 100, 8	OF oDlg PIXEL COLOR CLR_RED
	
		@ 70, 10 SAY STR0012	SIZE 50 , 8	OF oDlg PIXEL COLOR CLR_RED	//"Telefone"
		@ 70, 50 SAY cTelCli	SIZE 100, 8	OF oDlg PIXEL COLOR CLR_RED
	
		@ 85,150 BUTTON STR0021	ACTION (SGButton(7, cCodCli, cLojaCli, cCodCont, cEntAlias, cTipoCTI, oHashDic), oDlg:End(), nModulo:= 99)	SIZE 44, 11	OF oDlg PIXEL	//"Atender"
		Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-1"),)
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (SGListnerOn(cTela), SendToFore())
	Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM-2"),)	
Endif

//Retorna valor da varivel
lMotObrig	:= .T.

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SGReaDbuf    ³ Autor³Fabio Rogerio Pereira³Data  ³ 30/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Separa o retorno da solicitacao enviada para a CTI.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³MP8	 												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGReaDbuf(cSep, cBuffer, lIncluiVazio)

Local aBuffer:= {}
Local nPos   := 0
Local cString:= "" 

Default lIncluiVazio := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Separa as informacoes recebidas da SIGACTI.DLL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPos:= 1 To Len(cBuffer)
	If (SubStr(cBuffer,nPos,1) == cSep)		
		If !Empty(cString) .OR. lIncluiVazio  
			Aadd(aBuffer,cString)          
			cString:= ""
		Endif
	Else
		cString+= SubStr(cBuffer,nPos,1)
	Endif		
Next nPos
Return(aBuffer)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SGDataRead   ³ Autor³Fabio Rogerio Pereira³Data  ³ 01/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica os dados do contato/cliente.				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MP8  												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGDataRead( cTipo		,cID		,cCodCont	,cNomeCont,;
							cTelCont	,cEmailCont	,cCodCli	,cLojaCli,;
							cNomeCli	,cTelCli	,cEmailCli	,cHPageCli,;
							cEntAlias	,oHashDic	,cNumA		,cNumB	)


Local cDDD   := CriaVar("U5_DDD",.F.)
Local lAchou := .F.							// Flag de localizacao positiva na base de dados

Local cAlias := ""
Local nOrdem := 0
Local cChave := ""
Local cEntid := "" 
Local cCodEmp := ""

Local cAni    := ""
Local cPictDDD:= PesqPict("SU5","U5_DDD")       

Local lTmkAni := ExistBlock( 'TMKANI' )
Local aRet	  := {}
Local nCnt	  := 0
Local aTempCallData
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os campos de identificacao - display³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodCont  := ""
cNomeCont := STR0024  //"Contato nao identificado"   
cEmailCont:= ""
cTelCont  := ""

cCodCli   := ""
cLojaCli  := ""
cNomeCli  := STR0023 //"Cliente Nao Identificado"
cTelCli   := ""
cEmailCli := ""
cHPageCli := ""
cEntAlias := ""
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a identificacao esta sendo feita por CODIGO - 1) Pesquisa pela composicao exata no Cadastro de Clientes           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipo == "1")
	If ! lAchou
		DbSelectarea("SA1")
		DbSetorder(1)	//Codigo do Cliente  
		If DbSeek(xFilial("SA1")+cID)
			lAchou := .T.
			cAlias := "SA1"
			nOrdem := 1
			cChave := SA1->A1_COD+SA1->A1_LOJA
		Endif
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a identificacao esta sendo feita por CNPJ - 2) Pesquisa pela composicao exata no Cadastro de Clientes e Prospects ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipo == "2")
	If ! lAchou
		DbSelectarea("SA1")
		DbSetorder(3)
		If DbSeek(xFilial("SA1")+cID)
			lAchou := .T.
			cAlias := "SA1"
			nOrdem := 3
			cChave := SA1->A1_CGC
		Endif
	Endif
	
	If ! lAchou
		DbSelectarea("SUS")
		DbSetorder(4)
		If DbSeek(xFilial("SUS")+cID)
			lAchou := .T.
			cAlias := "SUS"
			nOrdem := 1
			cChave := SUS->US_CGC
		Endif
	Endif
	
	If ! lAchou
		DbSelectarea("SA2")
		DbSetorder(4)
		If DbSeek(xFilial("SA2")+cID)
			lAchou := .T.
			cAlias := "SA2"
			nOrdem := 4
			cChave := SA2->A2_CGC
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a identificacao esta sendo feita por TELEFONE - 1) Pesquisa pela composicao exata no Cadastro de Contatos/Clientes e Prospects  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipo == "3")  //Identificacao por Telefone

    // Telefone com 8 numeros + DDD = 10 bytes
	If Len(TRIM(cId)) >= 10
		cDDD := Left(cId,2) //
		cAni := Substr(cId,3, Len(TRIM(cId))-2 )
	                             //123456789012345
		cAni := Transform(cAni,"@R 999999999999999")
		cDDD := Transform(cDDD,cPictDDD)
		
	Endif

    // Telefone com 7 numeros + DDD = 9 bytes
	If Len(TRIM(cId)) == 9
		cDDD := Left(cId,2) //
		cAni := Substr(cId,3, Len(TRIM(cId))-2 )
	                             //123456789012345
		cAni := Transform(cAni,"@R 999999999999999")
		cDDD := Transform(cDDD,cPictDDD)
	Endif
	
    // Telefone SEM DDD - 7 ou 8 bytes
	If Len(TRIM(cId)) < 9
		cAni := cId	
		cDDD := SPACE(4)	// Nesse caso os cadastros do PROTHEUS precisam estar sem DDD
	Endif	
	                      
	//Indica o telefone recebida da aplicação de CTI, usado quando o telefone não é identificado
	cTelCont  := cAni + " " + cDDD

	DbSelectArea("SU5")
	
	If !lAchou
		DbSetOrder(5) //Telefone Comercial 1 - U5_FILIAL+U5_FCOM1+U5_DDD+U5_CODPAIS
		If DbSeek(xFilial("SU5") + cAni + cDDD)
			lAchou := .T.
			cAlias := "SU5"
			nOrdem := 5
			cChave := SU5->U5_FCOM1+cDDD
		Endif
	Endif
	
	If !lAchou
		DbSetOrder(6) //Telefone Comercial 2 - U5_FILIAL+U5_FCOM2+U5_DDD+U5_CODPAIS
		If DbSeek(xFilial("SU5") + cAni + cDDD)
			lAchou := .T.
			cAlias := "SU5"
			nOrdem := 6
			cChave := SU5->U5_FCOM2+cDDD
		Endif
	Endif
	
	If !lAchou
		DbSetOrder(7) //Fax	- U5_FILIAL+U5_FAX+U5_DDD+U5_CODPAIS
		If DbSeek(xFilial("SU5") + cAni + cDDD)
			lAchou := .T.
			cAlias := "SU5"
			nOrdem := 7
			cChave := SU5->U5_FAX+cDDD
		Endif
	Endif

	If !lAchou
		DbSetOrder(4) //Celular	- U5_FILIAL+U5_CELULAR+U5_DDD+U5_CODPAIS
		If DbSeek(xFilial("SU5") + cAni + cDDD)
			lAchou := .T.
			cAlias := "SU5"
			nOrdem := 4
			cChave := SU5->U5_CELULAR+cDDD
		Endif
	Endif

	If !lAchou
		DbSetOrder(3) //Telefone Residencial - U5_FILIAL+U5_FONE+U5_DDD+U5_CODPAIS
		If DbSeek(xFilial("SU5") + cAni + cDDD)
			lAchou := .T.
			cAlias := "SU5"
			nOrdem := 3
			cChave := SU5->U5_FONE+cDDD
		Endif
	Endif
	
	If !lAchou  
		DbSelectArea("SA1")
		DbSetOrder(4) //Telefone - A1_FILIAL+A1_TEL+A1_DDD+A1_DDI
		If DbSeek(xFilial("SA1") + cAni + cDDD)
			lAchou := .T.
			cAlias := "SA1"
			nOrdem := 4
			cChave := SA1->A1_TEL+cDDD
		Endif
	Endif	

	If !lAchou    
		DbSelectArea("SUS")
		DbSetOrder(3) //Telefone - US_FILIAL+US_TEL+US_DDD+US_DDI
		If DbSeek(xFilial("SUS") + cAni + cDDD)
			lAchou := .T.
			cAlias := "SUS"
			nOrdem := 3
			cChave := SUS->US_TEL+cDDD
		Endif
	Endif	
	
Endif

If (cTipo == "4" .OR. cTipo == "5")
	If (cTipo == "5")
		If FindFunction( "P_TMKGETAS" )
			cID := P_TMKGETAS( cNumA, cNumB, cID )
		EndIf
	EndIf
	
	oHashDic := LJCHashTable():New()
	aTempCallData := StrTokArr(cID,"|")
	For nCnt = 1 to Len(aTempCallData)
		If at("=",aTempCallData[nCnt]) > 0
			oHashDic:Add(/*Key*/SubStr(aTempCallData[nCnt],1,At("=",aTempCallData[nCnt])-1),;
						  /*Value*/SubStr(aTempCallData[nCnt],At("=",aTempCallData[nCnt])+1,Len(aTempCallData[nCnt])))
		EndIf
	Next
	
	If oHashDic:Contains("ADE_CODCON") .AND. (oHashDic:ElementKey("ADE_CODCON") != "")
		lAchou := .T.
		cAlias := "SU5"
		nOrdem := 1 // U5_FILIAL + U5_CODCONT
		cChave := oHashDic:ElementKey("ADE_CODCON")
		If oHashDic:Contains("ADE_ENTIDA")
			cEntid  := oHashDic:ElementKey("ADE_ENTIDA")//Alias
		EndIf
		If oHashDic:Contains("ADE_CHAVE")
			cCodEmp := Pad( oHashDic:ElementKey("ADE_CHAVE") , TamSx3("AC8_CODENT")[1] )//Codigo entidade
		EndIf
	End IF
	
	If oHashDic:Contains("ADE_CODREP") .AND. (oHashDic:ElementKey("ADE_CODREP") != "")
		//cAlias := "SU5"
		//nOrdem := 1 // U5_FILIAL + U5_CODCONT
		cNomeCont := STR0187  //"Representante TOTVS"
		//cChave := oHashDic:ElementKey("ADE_CODCON")
	End IF
EndIf

#IFNDEF TOP
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a identificacao esta sendo feita por TELEFONE - Pesquisa pela composicao CONTIDA no Cadastro de Contatos/Clientes e Prospects  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAchou
		cAlias := "SU5"		//Telefone Residencial

		DbSelectarea("SU5")
		DbSetOrder(3) //Como a busca sera por CONTIDO nao importa a sequencia
		DbSeek(xFilial("SU5"))
		While (!Eof()) .AND. (SU5->U5_FILIAL == xFilial("SU5"))
			If (TRIM(U5_FCOM1) $ cAni)
				lAchou := .T.
				nOrdem := 5			//Telefone Comercial 1
				cChave := SU5->U5_FCOM1
				Exit
			Endif

			If (TRIM(U5_FCOM2) $ cAni)
				lAchou := .T.
				nOrdem := 6			//Telefone Comercial 2
				cChave := SU5->U5_FCOM2
				Exit
			Endif
                   
			If (TRIM(U5_FAX) $ cAni)
				lAchou := .T.
				nOrdem := 7				//Fax
				cChave := SU5->U5_FAX
			Endif

			If (TRIM(U5_CELULAR) $ cAni)
				lAchou := .T.
				nOrdem := 4         	//Telefone Celular
				cChave := SU5->U5_CELULAR
				Exit
			Endif

			If (TRIM(U5_FONE) $ cAni)
				lAchou := .T.
				nOrdem := 3
				cChave := SU5->U5_FONE	//Telefone Residencial
				Exit
			Endif

			DbSkip()
		End		
	Endif	

	If !lAchou
		DbSelectarea("SA1")
		DbSetOrder(4) //Telefone
		DbSeek(xFilial("SA1"))
		While (!Eof()) .AND. (SA1->A1_FILIAL == xFilial("SA1"))
			If (TRIM(A1_TEL) $ cAni)
				lAchou := .T.
				cAlias := "SA1"
				nOrdem := 4
				cChave := SA1->A1_TEL
				Exit
			Endif
			Dbskip()
		End
	Endif
		
	If !lAchou
		DbSelectarea("SUS")
		DbSetOrder(3) //Telefone
		DbSeek(xFilial("SUS"))
		While (!Eof()) .AND. SUS->US_FILIAL == xFilial("SUS")
			If (TRIM(US_TEL) $ cAni)
				lAchou := .T.
				cAlias := "SUS"
				nOrdem := 3
				cChave := SUS->US_TEL
				Exit
			Endif
			Dbskip()
		End	
	Endif
#ENDIF

If !lAchou  .AND. lTMKANI

	aRet := U_TMKANI(cTipo,cID)
	If (ValType(aRet) <> "A")
		cChave := ""
	Else
		cAlias := IIF(ValType(aRet[1]) == "C",aRet[1],"") 
		nOrdem := IIF(ValType(aRet[2]) == "N",aRet[2],0)
		cChave := IIF(ValType(aRet[3]) == "C",aRet[3],"") 

		If !Empty(cAlias) .AND. (nOrdem > 0) .AND. !Empty(cChave)		
			lAchou := .T.
		Endif	
	Endif 
Endif

If lAchou
	
	Do Case
		Case (cAlias == "SU5")
			
			DbSelectarea(cAlias)
			DbSetorder(nOrdem)
			If DbSeek(xFilial("SU5") + cChave)
				cCodCont  := SU5->U5_CODCONT
				cNomeCont := ALLTRIM(SU5->U5_CONTAT)
				cEmailCont:= ALLTRIM(SU5->U5_EMAIL)
				cTelCont  := IIF(cTipo == "3",cChave,SU5->U5_FCOM1)
				
				//Pega os dados da entidade no arquivo de relacionamento
				DbSelectArea("AC8")
				DbSetOrder(1)

				If !Empty( cEntid ) .And. !Empty( cCodEmp )
					DbSeek(xFilial("AC8") + cCodCont + cEntid + xFilial(cEntid) + cCodEmp )
				Else
					DbSeek(xFilial("AC8") + cCodCont,.T.)
				EndIf

				If Found()					
					cCodCli  := LEFT(AC8->AC8_CODENT,(Len(ALLTRIM(AC8->AC8_CODENT))-2))
					cLojaCli := Substr(AC8->AC8_CODENT,Len(ALLTRIM(AC8->AC8_CODENT))-1,2)
					cEntAlias:= AC8->AC8_ENTIDA
					
					DbSelectArea(AC8->AC8_ENTIDA)
					DbSetOrder(1)
					If DbSeek(xFilial(AC8->AC8_ENTIDA) + AC8->AC8_CODENT)
						cNomeCli := TkEntidade(AC8->AC8_ENTIDA,AC8->AC8_CODENT,1)
						cTelCli  := TkEntidade(AC8->AC8_ENTIDA,AC8->AC8_CODENT,6)
						cEmailCli:= TkEntidade(AC8->AC8_ENTIDA,AC8->AC8_CODENT,7)
						cHPageCli:= TkEntidade(AC8->AC8_ENTIDA,AC8->AC8_CODENT,8)
					Endif
				Endif
				
			Endif
			
			
		OtherWise
			
			If (cAlias == "SA1")
			
				DbSelectArea(cAlias)
				DbSetorder(nOrdem)
				If DbSeek(xFilial("SA1") + cChave)
					cCodCli   := SA1->A1_COD
					cLojaCli  := SA1->A1_LOJA
					cNomeCli  := SA1->A1_NOME
					cTelCli   := SA1->A1_TEL
					cEmailCli := SA1->A1_EMAIL
					cHPageCli := SA1->A1_HPAGE
					cEntAlias := "SA1"
					lProspect := .F.
				Endif
			
			Endif
					
			If (cAlias == "SUS")
			
				DbSelectArea(cAlias)
				DbSetorder(nOrdem)
				If DbSeek(xFilial("SUS") + cChave)
					cCodCli   := SUS->US_COD
					cLojaCli  := SUS->US_LOJA
					cNomeCli  := SUS->US_NOME
					cTelCli   := SUS->US_TEL
					cEmailCli := SUS->US_EMAIL
					cHPageCli := SUS->US_URL
					cEntAlias := "SUS"
					lProspect := .T.
				Endif	
				
             Endif

			 If !Empty(cCodCli) .AND. !Empty(cLojaCli)
			 
				// Procura pelo 1 contato do AC8 para essa entidade
				DbSelectArea("AC8")
				DbSetorder(2)  //AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
				If DbSeek(xFilial("AC8") + cAlias + xFilial(cAlias) + cCodCli + cLojaCli) 
				
					While (!Eof()) .AND. ;
						  (AC8->AC8_FILIAL == xFilial("AC8")) .AND.;
						  (AC8->AC8_ENTIDA == cAlias) 		  .AND.;
						  (AC8->AC8_FILENT == xFilial(cAlias)) .AND.;
						  (ALLTRIM(AC8->AC8_CODENT) == ALLTRIM(cCodCli + cLojaCli))
						
						DbSelectArea("SU5")
						DbSetorder(1)
						If DbSeek(xFilial("SU5") + AC8->AC8_CODCON)
							cCodCont  := SU5->U5_CODCONT
							cNomeCont := ALLTRIM(SU5->U5_CONTAT)
							cEmailCont:= ALLTRIM(SU5->U5_EMAIL)
							cTelCont  := IIF(cTipo == "3",cChave,SU5->U5_FCOM1)
							Exit
						Endif
						
						DbSelectArea("AC8")
						DbSkip()
					End 
					
				Endif  
			Endif	
	EndCase
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SGButton ³ Autor ³ Fabio Rogerio Pereira ³ Data ³02/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o ACTION dos botoes da tela de POP-UP              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SGButton( 	nBtn, 		cCliente,	cLoja, cCodCont,;
							cEntAlias, 	cTipoCTI, oHashDic, lIncNew)
Local aScreen := GetScreenRes()
Local cChave 
Local cChaveStr
Local lAtuCham := .F.
Local lSGMngCl := ExistBlock("TKMNGCL")						// P.E. para substitui a verifica de qual a tela de atendimento o Operador tem acesso.

Default cTipoCTI := TkPosto(TkOperador(),"U0_TIPOCTI")

Private cCadastro:= ""
Private AcBrowse := "xxxxxxxxxx"   //Variavel para controle de acesso a mbrowse
Private aRotina  := {}             //Rotina da MBrowse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aumenta oMainWnd para corrigir tamanho da funcao MSADVSIZE   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMainWnd:Move(0,0,aScreen[1],aScreen[2])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Telemarketing		                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	(nBtn == 1)
	SUC->(DbSetOrder(2))
	If	SUC->(DbSeek(xFilial("SUC") + cEntAlias + cCliente + cLoja))
		cCadastro:=	STR0004											//"Telemarketing"
		aRotina	 := {{ STR0016  , "AxPesqui"        , 0 , 1},; 		//"Pesquisar"
					{  STR0017  , "TK271CallCenter" , 0 , 2}} 		//"Visualizar"

		If lProspect
			mBrowse( 6, 1,22,75,"SUC",,,,,,,'xFilial("SUC") + "SUS" + SUS->US_COD + SUS->US_LOJA' , 'xFilial("SUC") + "SUS" + SUS->US_COD + SUS->US_LOJA' )
		Else                                                                                                                               
			mBrowse( 6, 1,22,75,"SUC",,,,,,,'xFilial("SUC") + "SA1" + SA1->A1_COD + SA1->A1_LOJA' , 'xFilial("SUC") + "SA1" + SA1->A1_COD + SA1->A1_LOJA' )			
		Endif
	
	Else
	
		Help(" ",1,"SEMDADOS")
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Televendas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nBtn == 2
	SUA->(DbSetOrder(6))
	If	SUA->(DbSeek(xFilial("SUA") + cCliente + cLoja))
		cCadastro:=	STR0005											//"Televendas"
		aRotina	 := {{ STR0016, "AxPesqui"        , 0 , 1},;		//"Pesquisar"
					{  STR0017, "TK271CallCenter" , 0 , 2}} 		//"Visualizar"

		If lProspect
			mBrowse( 6, 1,22,75,"SUA",,,,,,,'xFilial("SUA") + SUS->US_COD + SUS->US_LOJA' , 'xFilial("SUA") + SUS->US_COD + SUS->US_LOJA' )
		Else
			mBrowse( 6, 1,22,75,"SUA",,,,,,,'xFilial("SUA") + SA1->A1_COD + SA1->A1_LOJA' , 'xFilial("SUA") + SA1->A1_COD + SA1->A1_LOJA' )
		Endif
	Else
	
		Help(" ",1,"SEMDADOS")
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Telecobranca                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nBtn == 3
	ACF->(DbSetOrder(2))
	If	ACF->(DbSeek(xFilial("ACF") + cCliente + cLoja))
		cCadastro:=	STR0006											//"Telecobranca"
		aRotina	 := {{ STR0016, "AxPesqui"        , 0 , 1},;		//"Pesquisar"
					{  STR0017, "TK271CallCenter" , 0 , 2}} 		//"Visualizar"

		If lProspect
			mBrowse( 6, 1,22,75,"ACF",,,,,,,'xFilial("ACF") + SUS->US_COD + SUS->US_LOJA' , 'xFilial("ACF") + SUS->US_COD + SUS->US_LOJA' )
		Else
			mBrowse( 6, 1,22,75,"ACF",,,,,,,'xFilial("ACF") + SA1->A1_COD + SA1->A1_LOJA' , 'xFilial("ACF") + SA1->A1_COD + SA1->A1_LOJA' )
		Endif
	Else
		
		Help(" ",1,"SEMDADOS")
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Financeiro                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nBtn == 4
	If !lProspect
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1") + cCliente + cLoja)
			
			aRotina	:=	{{STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
					     {STR0002, "AxVisual" , 0 , 2},;  //"Visualizar"
						 {STR0003, "FC010CON" , 0 , 2},;  //"Consultar"
						 {STR0004, "FC010IMP" , 0 , 4}}   //"Impressao"

			Pergunte("FIC010",.T.)
			
			Fc010Con("SA1",SA1->(Recno()),2)
		Endif
	Else
		Help(" ",1,"SEMDADOS")
	Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Ordem de Servico                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nBtn == 5
	AB6->(DbSetOrder(3))
	If	AB6->(DbSeek(xFilial("AB6") + cCliente + cLoja))
		cCadastro:=	STR0020									//"Ordem de Servico"
		aRotina	 := {{ STR0016, "AxPesqui" , 0 , 1},; 		//"Pesquisar"
					{  STR0017, "AxVisual" , 0 , 2}} 		//"Visualizar"

		If !lProspect
			mBrowse( 6, 1,22,75,"AB6",,,,,,,'xFilial("AB6") + SA1->A1_COD + SA1->A1_LOJA' , 'xFilial("AB6") + SA1->A1_COD + SA1->A1_LOJA' )
		Endif
	Else
		
		Help(" ",1,"SEMDADOS")
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Contatos                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nBtn == 6       
                            
    SU5->(DbGoTop())
    If cTipoCTI == USE_SMARTCTI
		SU5->(DbSetOrder(1))		  		    	
		cChave := cCodCont
		cChaveStr := 'xFilial("SU5") + SU5->U5_CODCONT'
	ElseIf lProspect
		SU5->(DbSetOrder(4))               
		cChave := cCliente + cLoja
		cChaveStr := 'xFilial("SU5") + SUS->US_COD + SUS->US_LOJA'
	Else
		SU5->(DbSetOrder(2))		  		
		cChave := cCliente + cLoja
		cChaveStr := 'xFilial("SU5") + SA1->A1_COD + SA1->A1_LOJA'		
    Endif           

    
	If SU5->(DbSeek(xFilial("SU5") + cChave))
  
		cCadastro:=	STR0009								//"Contatos"
		aRotina	 := {{ STR0016, "AxPesqui" , 0 , 1},; 	//"Pesquisar"
				     { STR0017, "AxVisual" , 0 , 2}} 	//"Visualizar"

		mBrowse( 6, 1,22,75,"SU5",,,,,,,cChaveStr , cChaveStr )

	Else
		
		Help(" ",1,"SEMDADOS")
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Atendimento                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nBtn == 7
     
	
	//Valiadação para saber se o operador tem acesso ao Atendimento rapido de chamado
	dbSelectArea("SU7")
	SU7->(dbSetOrder(1))
   	If dbSeek (xFilial("SU7")+TkOperador())  
		If SU7->(FIELDPOS("U7_ATURAP")) > 0 .AND. SU7->U7_ATURAP == "1" .AND. FINDFUNCTION("TK510ATURP")     // Permissão no operador  
			lAtuCham := TK510ATURP()
		Else
			dbSelectArea("SU0")
			SU0->(dbSetOrder(1))
			If dbSeek (xFilial("SU0")+SU7->U7_POSTO) // Permissão pelo grupo
				If SU0->(FIELDPOS("U0_ATURAP")) > 0 .AND.  SU0->U0_ATURAP =="1".AND. FINDFUNCTION("TK510ATURP") 
					lAtuCham := TK510ATURP()
				EndIf 
			EndIf 
	   	EndIf 
   	EndIf
	
	If !lAtuCham 	   	
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   		//³ Envia o comando de Atender (31)                              ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		SGAtender(cTipoCTI)	
   		If lSGMngCl
			lIncNew := ExecBlock("TKMNGCL",.F.,.F.,{cCliente,cLoja,cCodCont,cEntAlias, oHashDic, lIncNew} )
		Else
   			SGManager(cCliente,cLoja,cCodCont,cEntAlias, oHashDic, @lIncNew)
   		EndIf	
 	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Diminui oMainWnd para nao aparecer na tela                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMainWnd:Move(aScreen[2]+1000,0,1,1)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGManager     ºAutor  ³Fabio Rogerio   º Data ³  17/04/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Verifica qual a tela de atendimento o Operador tem acesso e º±±
±±º          ³executa                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP7                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGManager(cCliente,	cLoja,	cCodCont,	cEntAlias, oHashDic, lIncNew)
Local cAlias   := ""	// Alias a ser utilizado no atendimento
Local aChamado := {}	// Array com informacoes do cliente utilizadas no Field Service
Local cTmkCtAt := SuperGetMV("MV_TMKCTAT",.F.,"1")    	// Parametro que indica o tipo de atendimento realizado
													//pelo operador na rotina de CTI quando o atendimento 
													//selecionado para ele for igual a "4 - Todos".
Local lUseTeleService := .F.	// Indica se o atendimento será realizado pela rotina de TeleAtendimento
Local lSGTlSvc        := ExistBlock("TKTLSVC")			// P.E. para substitui a verifica de qual a tela de atendimento o Operador tem acesso.

Private aRotina:= {}	// Array utilizado na abertura da MBrowse.

//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Call Center³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
If (nModulo == 13)                           

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tipo de atendimento do cliente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TMKOPERADOR(NIL,cCodUsLog)
		Return(.F.)
	Else
		Do Case
			Case (TkGetTipoAte() == "1")	// 1 - TELEMARKETING
				cAlias := "SUC"

			Case (TkGetTipoAte() == "2")	// 2 - TELEVENDAS 
				cAlias := "SUA"

			Case (TkGetTipoAte() == "3")	// 3 - TELECOBRANCA
				cAlias := "ACF"
				
			Case (TkGetTipoAte() == "4") 	// 4 - TODOS
				If FindFunction("_ISTMKTS") .AND. _ISTMKTS()
					If cTmkCtAt == "1"
						cAlias := "SUC"			
					ElseIf cTmkCtAt == "2"
						lUseTeleService := .T.
					Else
						If MsgYesNo(STR0169, STR0056) //"Este será um atendimento de Telemarketing, Televendas ou Telecobrança?" # "Atendimento Receptivo"
							cAlias := "SUC"
						Else
							lUseTeleService := .T.
						EndIf
					EndIf
				Else
					cAlias := "SUC"
				EndIf
				
			Case (TkGetTipoAte() == "5") 	// 5 - TMK X TLV
				cAlias := "SUC"			

			Case (TkGetTipoAte() == "6") 	// 6 - TeleAtendimento
				If FindFunction("_ISTMKTS") .AND. _ISTMKTS()
					lUseTeleService := .T.
				Else
					cAlias := "SUC"
				EndIf
							
			OtherWise
		   		cAlias := "SU5"
			
		EndCase
		If !lUseTeleService         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa a tela de atendimento do Call Center.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			INCLUI:= .T.
			aRotina		:= {  { STR0016  	,"AxPesqui"        ,0,1 },; //"Pesquisar"
							  { STR0017		,"TK271CallCenter" ,0,2 },; //Visualizar
							  { STR0018	 	,"TK271CallCenter" ,0,3 },; //"Incluir"
							  { STR0019		,"TK271CallCenter" ,0,4 }} 	//"Alterar"
	
			TK271CallCenter(	cAlias	,0		,3			,Nil,; 
								cCliente,cLoja	,cCodCont	,cEntAlias	,;
								Nil		,Nil)
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa a tela de TeleAtendimento            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			INCLUI := .T.
			ALTERA := .F.
			If lSGTlSvc
	   			lIncNew := ExecBlock("TKTLSVC",.F.,.F.,{cCodCont, cEntAlias, cCliente+cLoja, oHashDic, lIncNew})
	   		Else
				SGTeleService(cCodCont,	cEntAlias,	cCliente+cLoja, oHashDic, @lIncNew)		
			EndIf
		EndIf
	Endif          


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Field Service³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf (nModulo == 28)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a tela de inclusao do chamado tecnico³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aChamado,{"AB1_CODCLI",cCliente})
	Aadd(aChamado,{"AB1_LOJA"  ,cLoja})
	Aadd(aChamado,{"AB1_CONTAT",cCodCont})
	
	Teca300("At300Inclu",aChamado)
Endif

nModulo:= 99	//Garante que o Listner fique com modulo igual a 99 

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGClose   ³ Autor ³Fabio Rogerio Pereira  	³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Encerra a comunicacao com a CTI e com a DLL                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP7    						                              	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGClose()
Local nRet    := -1						//Retorno negativo
Local aBuffer := {}                		//Parametros
Local cCti    := SuperGetMV("MV_TMKCTI")		//Modelo da CTI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario utiliza CTI e se existe CTI configurada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PswOrder(1)
If PswSeek(cCodUsLog)
	If !Empty(PswRet(1)[1][19]) .AND. !Empty(cCti)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha a comunicacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet:= SGSendCti( 26 , {cCti}, @aBuffer)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha a SIGACTI.DLL ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ExecInDllClose(nHandle)
	Endif
Endif
	
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGMnuAtivoºAutor  ³Marcelo Kotaki       º Data ³  19/03/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe as opcoes de discagem ativa para CTI ou MODEM          º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Numero de Telefone para Discagem Direta            ³±±
±±³          ³ ExpC2 -> Entidade Selecionada (SA1,SUS,ACH,SU2,...)         ³±±
±±³          ³ ExpC3 -> Chave da Entidade				                   ³±±
±±³          ³ ExpC4 -> Codigo do Contato                                  ³±±
±±³          ³ ExpN1 -> Linha Inicial do PopUp Menu                        ³±±
±±³          ³ ExpN2 -> Coluna Inicial do PopUp Menu                       ³±±
±±³          ³ ExpU1 -> Tela que ira conter o PopUpMenu                    ³±±
±±³          ³ ExpL1 -> Utiliza Discagem ?                                 ³±±
±±³          ³ ExpL2 -> Utiliza Transferencia ?                            ³±±
±±³          ³ ExpL3 -> Utiliza Conferencia ?                              ³±±
±±³          ³ ExpL4 -> Utiliza Ligacao em Espera ?                        ³±±
±±³          ³ ExpL5 -> Utiliza Consulta ao Supervisor ?                   ³±±
±±³          ³ ExpL6 -> Utiliza Pausa ?                                    ³±±
±±³          ³ ExpL7 -> Utiliza Siga-me ?                                  ³±±
±±³          ³ ExpL8 -> Utiliza Gravacao de Chamada ?                      ³±±
±±³          ³ ExpL9 -> Utiliza Reproducao de Chamada ?                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGMnuAtivo(cTel		,cEntida	,cChave		,cContato,;
					nLin		,nCol		,oDlg		,lDisk,;
					lTransfer	,lConfer	,lHold		,lSuper,;
					lPausa		,lFollowme	,lRecord	,lPlay,;
					lRamal		,lPendulo	,lRetrieve	,oMenu01,lCham,;
					nTipoTel) 
Local oMenu
Local cCTI 			:= ""
Local lRet 			:= .F.
Local cTipoCTI    		:= TkPosto(TkOperador(),"U0_TIPOCTI")
Local cTmkCfgR      	:= SuperGetMV("MV_TMKCFGR")   //Verifica quais os recursos de ativo que a CTI pode executar - 10 Opcoes
Local aTmkCfgR      	:= {}
Local nCont 			:= 0

Local oMenuIt			:= Nil
Local oMenuIt1		:= Nil
Local oMenuIt2		:= Nil
Local oMenuIt3		:= Nil		 
Local oMenuIt4		:= Nil	
Local oMenuIt5		:= Nil	

Local cMenuItem		:= ""
Local aPDFields 	:= {"U5_CONTAT","U5_FONE","U5_FAX","U5_FCOM1","U5_FCOM2","U5_CELULAR","U5_EMAIL"}
	
DEFAULT lDisk	   		:= .T. 	    //Discagem
DEFAULT lTransfer 	:= .T. 	    //Transferencia
DEFAULT lConfer		:= .T.		 	//Conferencia
DEFAULT lHold	   		:= .T.			//Espera (Hold)        04
DEFAULT lSuper	   	:= .T.		 	//Consulta Supervisor
DEFAULT lPause	   	:= .T.		 	//Pausa
DEFAULT lFollowme 	:= .T.		 	//Siga-me
DEFAULT lRecord   	:= .T.		 	//Gravacao 
DEFAULT lPlay     	:= .T.		 	//Reproducao
DEFAULT lRamal    	:= .T.		 	//Discagem Interna     30
DEFAULT cEntida   	:= ""        	//Entidade
DEFAULT cChave    	:= ""     	 	//Chave da Entidade
DEFAULT cContato  	:= ""     	 	//Contato
DEFAULT cTel      	:= Space(16) 	//Telefone
DEFAULT lPendulo		:= .T.		 	//Pendulo
DEFAULT lLinhaAtiva 	:= .F.		 	//Linha Ativa
DEFAULT lRetrieve		:= .F.		 	//Retrieve

DEFAULT lCham			:= .F.			// Verifica se a chamada foi feita a partir da tela de recepção de Chamadas (SGShowProfile) 
DEFAULT oMenu01		:= Nil			// Objeto do menu de telefonia na tela de recepção de chamadas(SGShowProfile)	
DEFAULT	nTipoTel	:= Nil

Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo de discagem a ser realizada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	case cTipoCTI == USE_MODEM 		// 1 - Modem
		cCTI := ""
		If !lAbreCTI
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a abertura da DLL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SGOpen(__cUserId)        
				SGActive()
			Endif	
		Endif
			

	case cTipoCTI == USE_CTI      		// 2 - Cti   
		cCTI := SuperGetMV("MV_TMKCTI")    
		
	case cTipoCTI == USE_MANUAL		// 3 - Manual
		cCTI := ""

	case cTipoCTI == USE_SMARTCTI 			//4 - SmartCTI
		cCTI := "SMARTCTI"
			
	case Empty(cTipoCTI) 			// Discagem Manual
		cCTI := ""                  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Assume que discagem sera manual porque o campo no grupo de atendimento esta vazio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTipoCTI:= USE_MANUAL		
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o operador estiver usando CTI tem a validacao de VERSAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCTI)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se o parametro MV_TMKCFGR foi atualizado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(cTmkCfgR) <> 14)	// O parametro deve possuir 14 Bytes.
		MsgStop(STR0130)		//"O parâmetro MV_TMKCFGR não esta configurado corretamente. Este parâmetro deve conter 14 caracteres. Para sua configuração verifique a documentação do sistema."
	    Return(lRet)
	Endif
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se ja existir o numero do telefone nao exibe o menu popup.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If cTipoCTI == USE_MANUAL		 // 3 - Manual	
	If Empty(cTel)
		MsgInfo(STR0208)		 //"A entidade nao tem telefone cadastrado, por favor verifique o cadastro da Entidade e do Contato"
	Else 

		If ExistBlock("TK380LM")
			lRet :=	ExecBlock("TK380LM",.F.,.F.,{cEntida, cChave, cContato, cTel, cTipoCTI})
			lRet :=	If(ValType(lRet) == "L", lRet, .F.)
		Else
			// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
			aPDFields := {"U5_CONTAT","U5_FONE","U5_FAX","U5_FCOM1","U5_FCOM2","U5_CELULAR","U5_EMAIL"}
			FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
			cTel := FATPDObfuscate(cTel, TkFieldType(nTipoTel) )        
			FATPDUnLoad()
			MsgInfo(STR0077+cTel) 	 //"Por favor disque para o numero a seguir: "
 
			If TmkOk(STR0160) //"Confirma o sucesso da chamada ?"
				lRet := .T.
			Endif
		EndIf
	Endif
	
Else  				// Discagem via SigaCTI (Modem ou PABX)
	If Empty(cTel)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica quais os recursos que a CTI pode executar no ATIVO³
	  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cTmkCfgR)
		   For nCont := 1 TO Len(cTmkCfgR)
		       If Substr(cTmkCfgR,nCont,1) == "T"
		       	  Aadd(aTmkCfgR,.T.)
		 	   Else
		 	   	  Aadd(aTmkCfgR,.F.)
		 	   Endif	  
		   Next nCont     
		   
		   If Len(aTmkCfgR) >= 9
			   lDisk	   	:= aTmkCfgR[1] 	     //Discagem				1
			   lDesligar	:= aTmkCfgR[2]		 //Desligar				2
			   lTransfer 	:= aTmkCfgR[3] 	     //Transferencia        3
			   lConfer		:= aTmkCfgR[4]		 //Conferencia          4
			   lHold	   	:= aTmkCfgR[5]		 //Espera (Hold)        5 
			   lRetrieve	:= aTmkCfgR[5]		 //Retrieve 			5 Habilitado quando o HOLD estiver habilitado	
			   lSuper	   	:= aTmkCfgR[6]		 //Consulta Supervisor  6
			   lPausa	   	:= aTmkCfgR[7]		 //Pausa                7
			   lDisponivel  := aTmkCfgR[8]		 //Disponivel           8
			   lFollowme 	:= aTmkCfgR[9]		 //Siga-me              9
			   lIniRecord  	:= aTmkCfgR[10]		 //Inicio Gravacao      10
			   lFimRecord	:= aTmkCfgR[11]		 //Fim Gravacao         11
			   lPlay     	:= aTmkCfgR[12]		 //Reproducao           12
			   lRamal    	:= aTmkCfgR[13]		 //Discagem Interna     13
			   lPendulo		:= aTmkCfgR[14]		 //Pendulo				14			   
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao existir CTI habilita somente a discagem por modem.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cCTI) 
			lDisk	    := .T. //Discagem
			lDesligar	:= .F. //Desligar
			lTransfer 	:= .F. //Transferencia
			lConfer	 	:= .F. //Conferencia
			lHold	    := .F. //Espera (Hold)
			lSuper	 	:= .F. //Consulta Supervisor
			lPausa	 	:= .F. //Pausa
			lDisponivel	:= .F. //Disponivel
			lFollowme 	:= .F. //Siga-me
			lIniRecord  := .F. //Inicio Gravacao 
			lFimRecord	:= .F. //Fim Gravacao
			lPlay     	:= .F. //Reproducao
		    lRamal    	:= .F. //Discagem Interna     
		    lPendulo	:= .F. //Pendulo 
		    lRetrieve	:= .F. //Retrieve
		Endif
		
		If !lCham
		MENU oMenu POPUP
			
			If lDisk
				MENUITEM STR0030 ACTION lRet:= SGCommand(	"1"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //"Discar"
			EndIf
			
			If lDesligar
				MENUITEM STR0124 ACTION lRet:= SGCommand(	"2"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //"Desligar" //"Desligar"
			Endif
			
			If lTransfer
					If cTipoCTI == USE_SMARTCTI .AND. Len(aIDCham) > 1   		//4 - SmartCTI
					MENUITEM STR0031 ACTION lRet:= SGCommand(	"G"			,cCTI	,cEntida	,cChave,;
																cContato	,cTel, cTipoCTI) //Transferencia de chamada em consulta
				Else			
					MENUITEM STR0031 ACTION lRet:= SGCommand(	"3"			,cCTI	,cEntida	,cChave,;
																cContato	,cTel, cTipoCTI) //Transferencia
				EndIf
			Endif
			
			If lConfer
				MENUITEM STR0032 ACTION lRet:= SGCommand(	"4"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //Conferencia
			Endif
			
			If lHold
				MENUITEM STR0033 ACTION lRet:= SGCommand(	"5"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //Hold
			Endif 
			
			If lRetrieve
				If cTipoCTI == USE_SMARTCTI    		//4 - SmartCTI   
					MENUITEM STR0161 ACTION lRet:= SGCommand(	"F"			,cCTI	,cEntida	,cChave,;
																cContato	,cTel, cTipoCTI) //"Retorna da espera"
				EndIf
			EndIf 						
			
			If lSuper
				MENUITEM STR0034 ACTION lRet:= SGCommand(	"6"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //Consulta ao Supervisor
			Endif
			
			If lPausa     //Parametro recebido na funcao
				MENUITEM STR0035 ACTION lRet:= SGCommand(	"7"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //Pausa
			EndIf
			
			If lDisponivel
				MENUITEM STR0122 ACTION lRet:= SGCommand(	"8"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //Disponivel
			Endif

			If lFollowme
				MENUITEM STR0036 ACTION lRet:= SGCommand(	"9"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //Siga-me
			Endif
			
			If lIniRecord
				MENUITEM STR0037 ACTION lRet:= SGCommand(	"A"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //Gravacao
			Endif
			
			If lFimRecord
				MENUITEM STR0125 ACTION lRet:= SGCommand(	"B"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //"Fim da gravacao" //"Fim da gravação"
			Endif
			
			If lPlay
				MENUITEM STR0126 ACTION lRet:= SGCommand(	"C"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //"Reproducao" //"Reproducao"
			Endif

			If lRamal
				MENUITEM STR0121 ACTION lRet:= SGCommand(	"D"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //"Discagem Interna"
			Endif
			
			If lPendulo
				MENUITEM STR0127 ACTION lRet:= SGCommand(	"E"			,cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) //"Pendulo" //"Pendulo"
			EndIf 
		
		ENDMENU
		Else
			If lTransfer					
				oMenuIt := tMenuItem():new(oMenu01, STR0031, , , ,{|| lRet:= SGCommand(IIF((cTipoCTI == USE_SMARTCTI .AND. Len(aIDCham) > 1),"G","3"),;
																			cCTI,cEntida,cChave,cContato,cTel,cTipoCTI,.T.) },,,,,,,,,.T.)
				oMenu01:add(oMenuIt)			
			Endif	
			
			If lHold
				oMenuIt1 := tMenuItem():new(oMenu01, STR0033, , , ,{|| lRet:= SGCommand("5",cCTI	,cEntida	,cChave,;
															cContato	,cTel, cTipoCTI) }, , , , , , , , , .T.)		
				oMenu01:add(oMenuIt1)
			Endif 
				
			If lRetrieve
				If cTipoCTI == USE_SMARTCTI    		//4 - SmartCTI   
					oMenuIt2 := tMenuItem():new(oMenu01, STR0161, , , ,{|| lRet:= SGCommand("F",cCTI	,cEntida	,cChave,;
																	cContato	,cTel, cTipoCTI) }, , , , , , , , , .T.)		
					oMenu01:add(oMenuIt2)
				EndIf
			EndIf 						
				
			If lSuper
				oMenuIt3 := tMenuItem():new(oMenu01, STR0034, , , ,{|| lRet:= SGCommand("6",cCTI	,cEntida	,cChave,;
																cContato	,cTel, cTipoCTI) }, , , , , , , , , .T.)		
				oMenu01:add(oMenuIt3)
			Endif
			
			If lPendulo
				oMenuIt4 := tMenuItem():new(oMenu01, STR0127, , , ,{|| lRet:= SGCommand("E",cCTI	,cEntida	,cChave,;
																cContato	,cTel, cTipoCTI) }, , , , , , , , , .T.)		
				oMenu01:add(oMenuIt4)
			EndIf 
			
			If lDesligar
				oMenuIt5 := tMenuItem():new(oMenu01, STR0124, , , ,{|| lRet:= SGCommand("2",cCTI	,cEntida	,cChave,;
																cContato	,cTel, cTipoCTI) }, , , , , , , , , .T.)		
				oMenu01:add(oMenuIt5)
			Endif	
		EndIf
		
		If SetMdiChild()
			nCol *= 2
		EndIf
		If !lCham
			oMenu:Activate(nCol,nLin,oDlg)
		EndIf	
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a conexão suporta ativo.             ³
		//³Caso contrário, exibe a tela para discagem manual³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	cTipoCTI <> USE_SMARTCTI .OR.;
			( 	cTipoCTI == USE_SMARTCTI .AND.; 
				(Type("oAgtSmartCTI:Bound") == "U" .OR.;
				(Type("oAgtSmartCTI:Bound") <> "U" .AND. oAgtSmartCTI:Bound $ "2|3"))) // Outbound # Both
			 
			lRet:= SGCommand(	"1"			,cCTI	,cEntida	,cChave,;
								cContato	,cTel, cTipoCTI)  //Discagem direta.
		Else
			If Empty(cTel)
				MsgInfo(STR0078)		 //"A entidade nao tem telefone cadastrado, por favor verifique o cadastro da Entidade e do Contato"
			Else
				MsgInfo(STR0077+cTel) 	 //"Por favor disque para o numero a seguir: "

				If TmkOk(STR0160) //"Confirma o sucesso da chamada ?"
					lRet := .T.
				Endif		
			Endif							
		EndIf	

	Endif
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGCommand ³ Autor ³Fabio Rogerio Pereira  ³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa os comandos de ATIVO para CTI/MODEM                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP7    						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Opcao do Menu PopUp selecionado                   ³±±
±±³          ³ ExpC2 -> Modelo da CTI utilizada                           ³±±
±±³          ³ ExpC3 -> Alias da Entidade 		                          ³±±
±±³          ³ ExpC4 -> Chave da Entidade                                 ³±±
±±³          ³ ExpC5 -> Codigo do Contato                                 ³±±
±±³          ³ ExpC6 -> Numero do Telefone                                ³±±
±±³          ³ ExpC7 -> Tipo de integracao CTI                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGCommand(	cMenuItem	,cCTI	,cEntida	,cChave,;
							cContato	,cTel, 	cTipoCTI,lRecpView,cListDac,cGrpDAC)  

Local nRet   	:= 0
Local aBuffer	:= {}
Local lRet   	:= .F.

Default lRecpView	:= .F.		// Indica que a transferencia foi feita através da tela de recepção de chamadas
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a CTI/MODEM esta ativa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCTI) 
	Do Case
		Case cTipoCTI == USE_SMARTCTI	//4 - SmartCTI			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a abertura da API³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                 			
			If ValType(oAgtSmartCTI) == "U"          
				lAbreCTI := .F.
				If SMCTIOpen(__cUserId)
					lAbreCTI := .T.
					oAgtSmartCTI:AddEventListener(TMKAActiveEvt():New())	//Adiciona a classe de eventos
				Else             
					oAgtSmartCTI:Close()
					oAgtSmartCTI = NIL					
				EndIf
			EndIf          
			         
		Otherwise         				// CTI/MODEM
			If !lAbreCTI
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faz a abertura da DLL³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
				
				If SGOpen(__cUserId)        
					SGActive()
				Endif	
			Endif	
	EndCase				
		

Endif

Do Case
	
	Case (cMenuItem $ "1369D") .AND. ((cTipoCTI <> USE_SMARTCTI) .OR. (cTipoCTI == USE_SMARTCTI .AND. lAbreCTI)) 	//Discagem, Transferencia, Consulta, Siga-me, Discagem Interna
		nRet:= SGSkinTel(cMenuItem,cCTI,cEntida,cChave,cContato,cTel,cTipoCTI)
		If lRecpView
			lMotObrig	:= .F.
		Endif	
			
	Case (cMenuItem == "2") .AND. lAbreCTI 		//DesLigar    
		If cTipoCTI == USE_SMARTCTI
			nRet := oAgtSmartCTI:ConnectionClear("")		
			If nRet <> SMARTCTI_SUCCESS
				MsgInfo( oAgtSmartCTI:DescError(nRet,,.F.), "Protheus")
			EndIf			
		Else
			nRet:= SGSendCti(32, {}, @aBuffer) //Desligar
		EndIf
	
	Case (cMenuItem == "4") .AND. lAbreCTI 		//Conferencia
		If cTipoCTI == USE_SMARTCTI
		 	nRet := oAgtSmartCTI:Conference()
			If nRet <> SMARTCTI_SUCCESS
				MsgInfo( oAgtSmartCTI:DescError(nRet,,.F.), "Protheus")
			EndIf					 	
		Else
			nRet:= SGSendCti(7, {}, @aBuffer)
		EndIf

	Case (cMenuItem == "5") .AND. lAbreCTI 		//Espera (Hold)
		If cTipoCTI == USE_SMARTCTI		
		   	nRet := oAgtSmartCTI:Hold()
			If (nRet == SMARTCTI_SUCCESS)
				lCallInHold := .T.
			Endif		   	
			If nRet <> SMARTCTI_SUCCESS
				MsgInfo( oAgtSmartCTI:DescError(nRet,,.F.), "Protheus")
			EndIf						
		Else
			nRet:= SGSendCti( IIF(lHold,10,9), {}, @aBuffer) // Espera (Hold) e retorno de Espera
			If (nRet == 0)
				lHold:= !lHold
			Endif
		EndIf
	Case (cMenuItem $ "78") .AND. lAbreCTI //Pausa
		If cTipoCTI == USE_SMARTCTI
		    If (cMenuItem $ "8")
		    	nRet := oAgtSmartCTI:Ready("", "")		    	
				If (nRet == SMARTCTI_SUCCESS)
					lPause := .F.
				Endif				    	
		    Else                                  
		    	nRet := oAgtSmartCTI:NotReady("", "")		    
				If (nRet == SMARTCTI_SUCCESS)
					lPause := .T.
				Endif		
		    EndIf		    
			If nRet <> SMARTCTI_SUCCESS
				MsgInfo( oAgtSmartCTI:DescError(nRet,,.F.), "Protheus")
			EndIf							    		    
		Else
			nRet:= SGSendCti( IIF(lPause,11,12), {}, @aBuffer) // Se o status estiver em "Pausa" envia o comando de "Usuario Disponivel"
			If (nRet == 0)
				lPause:= !lPause
			Endif
		EndIf

	Case (cMenuItem $ "ABC") .AND. lAbreCTI //Inicializa Gravacao / Finaliza gravacao / Reproducao
		nRet:= SGRecPlay(cMenuItem, cTipoCTI)


	Case (cMenuItem == "E") .AND. lAbreCTI //Pendulo
		If cTipoCTI == USE_SMARTCTI   
			nRet := oAgtSmartCTI:Alternate()
			lCallInHold := .T.
			If nRet <> SMARTCTI_SUCCESS
				MsgInfo( oAgtSmartCTI:DescError(nRet,,.F.), "Protheus")
			EndIf						
		Else	
			nRet:= SGSendCti(13, {}, @aBuffer)
		EndIf
		
	Case (cMenuItem == "F") .AND. lAbreCTI //Retrieve		
		If cTipoCTI == USE_SMARTCTI    
			nRet := oAgtSmartCTI:Retrieve()			
			If (nRet == SMARTCTI_SUCCESS)
				//lHold:= .F.
				lCallInHold := .F.
			Endif		   				   
			If nRet <> SMARTCTI_SUCCESS
				MsgInfo( oAgtSmartCTI:DescError(nRet,,.F.), "Protheus")
			EndIf						
		EndIf	

	Case (cMenuItem == "G") .AND. lAbreCTI //Transferencia de chamada em consulta		
		If cTipoCTI == USE_SMARTCTI    
			nRet := oAgtSmartCTI:Transfer()			
			If (nRet == SMARTCTI_SUCCESS)
				//lHold:= .F.
				lCallInHold := .F.
				If lRecpView
					lMotObrig	:= .F.
				EndIf
			Endif		   				   
			If nRet <> SMARTCTI_SUCCESS
				MsgInfo( oAgtSmartCTI:DescError(nRet,,.F.), "Protheus")
			EndIf						
		EndIf	
		
	Case (cMenuItem == "L") .And. lAbreCTI //Lista de Chamadas em espera
		If cTipoCTI == USE_SMARTCTI
			cListDac := oAgtSmartCTI:GetCallList(cGrpDAC)
			If !Empty(cListDac)
				nRet := SMARTCTI_SUCCESS
			EndIf
		Else
			MsgInfo( oAgtSmartCTI:DescError(Val(aListDac[3]),,.F.), "Protheus")
		EndIf		
EndCase

If nRet == 0
	lRet:= .T.
Else
	lRet:= .F.
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGSkinTel ³ Autor ³Fabio Rogerio Pereira  ³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe o telefone virtual para executar a discagem automatica³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP7    						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Opcao do Menu PopUp selecionado                   ³±±
±±³          ³ ExpC2 -> Modelo da CTI utilizada                           ³±±
±±³          ³ ExpC3 -> Codigo da Entidade		                          ³±±
±±³          ³ ExpC4 -> Chave da Entidade                                 ³±±
±±³          ³ ExpC5 -> Codigo do Contato                                 ³±±
±±³          ³ ExpC6 -> Numero do Telefone                                ³±±
±±³          ³ ExpC7 -> Tipo de integracao CTI utilizada                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGSkinTel(	cMenuItem,	cCTI,	cEntidade,	cChave,;
							cContato,	cTel,	cTipoCTI)

Local oDlg											// Tela do Telefone        
Local cTitle     	:= ""							// Titulo da janela do telefone de acordo com a opcao do menu
Local oCursor										// Cursor para mudar a seta do mouse
Local oTel											// Get com o numero do telefone (digitado)
Local cTelefone  	:= cTel 
Local cRota	   	:= cTel
Local cDescCon   	:= ""							// Nome do Contato
Local oTelCont									// Listbox com os telefones do Contato
Local aTelCont   	:= {}
Local nTelCont   	:= 0
Local cDescEnt   	:= "" 							// Nome da Entidade
Local oTelEnt										// Listbox com os telefones da Entidade
Local nTelEnt    	:= 0
Local aTelEnt    	:= {}
Local cComplTel  	:= ""							// Complemento para Discagem - Posto de Venda
													//Array para montar o titulo do telefone e o comando de discagem para envio
Local aTipSol    	:= {	{"1",STR0039 ,4},;  	//"Discagem Automatica"  			
				    	{"3",STR0040 ,6},;  		//"Transferencia"
				   	    {"4",STR0041 ,7},;  		//"Conferencia"
					    {"6",STR0042 ,8},;  		//"Consulta ao Supervisor"
					    {"9",STR0043,18},;  		//"Siga-Me"
						{"D",STR0121,30}}   		//"Discagem Interna"
Local nTipSol    	:= 0							// Comando com o tipo de solicitacao para o envio do arquivo
Local nPos       	:= 0							// Contador	
Local oBtn       	:= Array(12)					// Botoes do Telefone
Local nWidth     	:= 0							// Tamanho da largura da Tela
Local nRet       	:= -1							// Retorno do comando de discagem enviado	
Local lContato   	:= .F.							// Flag se existe contato selecionado
Local lChave     	:= .F.							// Flag se existe entidade selecionada

Local lAtivaRota	:= SuperGetMv("MV_TKATROT", , .F.)  //Parametro para ativação da rota telefonica

nPos    := Ascan(aTipSol,{|x| x[1] == cMenuItem}) 					
cTitle  := aTipSol[nPos,2]
cDescCon:= Left(IIF(!Empty(cContato),Posicione("SU5",1,xFilial("SU5") + cContato,"U5_CONTAT"),""),30)
cDescEnt:= Left(IIF(!Empty(cEntidade + cChave),TkEntidade(cEntidade,cChave,1),""),30)

nTipSol := IIF(Empty(cCTI),24,aTipSol[nPos,3]) //Verifica se usa modem ou CTI
lContato:= IIF(Empty(cContato),.F.,.T.)
lChave  := IIF(Empty(cChave),.F.,.T.)
nWidth  := IIF((!lContato .AND. !lChave) .Or. (nPos <> 1),285,420)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os telefones de contato e entidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContato
	aTelCont := SGReadTel("SU5",cContato)
Endif

If lChave
	aTelEnt	 := SGReadTel(cEntidade,cChave)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao foi informado um Telefone - Indica que o Operador nao sabe que numero sera usado             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cTelefone)
	DEFINE MSDIALOG oDlg FROM  300,20 TO 570,nWidth TITLE cTitle  PIXEL 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria o cursor para as imagens do telefone virtual.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE CURSOR oCursor HAND

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria o fundo com a imagem de um telefone com gancho.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    @ 00,00  JPEG RESOURCE "TEL_TELEFONE" SIZE 220,150 OF oDlg PIXEL
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Get para informar o numero do telefone pela figura ou pelo teclado do computador ³
		// Monta o campo de Rota se o parametro MV_TKATROT estiver ativo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtivaRota 
			@ 22,75 MSGET oTel VAR cTelefone Picture "9999999999999999" SIZE 45,11 OF oDlg PIXEL 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria as imagens com os caracteres 1..0 , C e ","³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@80,225 BTNBMP RESOURCE "TEL_DISCAR" SIZE 22,22 ACTION SGAtivo(nTipSol,@cTelefone,cCTI,@oDlg, cTipoCTI, cRota) OF oDlg WHEN .T.
		
			//Get para informar o numero da rota
			@ 40,70  SAY STR0206 SIZE 50,8 OF oDlg PIXEL COLORS (CLR_RED,CLR_RED) RAISED
			@ 40,90 MSGET oRota VAR cRota MESSAGE STR0207 Picture "9" SIZE 1,11 OF oDlg PIXEL //"Digite a Rota"
					
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Get para informar o numero do telefone pela figura ou pelo teclado do computador ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ 22,75 MSGET oTel VAR cTelefone Picture "9999999999999999" SIZE 45,11 OF oDlg PIXEL 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria as imagens com os caracteres 1..0 , C e ","³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@80,185 BTNBMP RESOURCE "TEL_DISCAR" SIZE 22,22 ACTION SGAtivo(nTipSol,@cTelefone,cCTI,@oDlg, cTipoCTI) OF oDlg WHEN .T.	
		EndIf
		
		@ 55,65  JPEG oBtn[1]   RESOURCE "TEL_1"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("1",@cTelefone,oTel) BORDER CURSOR oCursor//"1"
		@ 55,85  JPEG oBtn[2]   RESOURCE "TEL_2"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("2",@cTelefone,oTel) BORDER CURSOR oCursor//"2"
		@ 55,105 JPEG oBtn[3]   RESOURCE "TEL_3"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("3",@cTelefone,oTel) BORDER CURSOR oCursor//"3"
		@ 75,65  JPEG oBtn[4]   RESOURCE "TEL_4"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("4",@cTelefone,oTel) BORDER CURSOR oCursor//"4"
		@ 75,85  JPEG oBtn[5]   RESOURCE "TEL_5"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("5",@cTelefone,oTel) BORDER CURSOR oCursor//"5"
		@ 75,105 JPEG oBtn[6]   RESOURCE "TEL_6"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("6",@cTelefone,oTel) BORDER CURSOR oCursor//"6"
		@ 95,65  JPEG oBtn[7]   RESOURCE "TEL_7"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("7",@cTelefone,oTel) BORDER CURSOR oCursor//"7"
		@ 95,85  JPEG oBtn[8]   RESOURCE "TEL_8"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("8",@cTelefone,oTel) BORDER CURSOR oCursor//"8"
		@ 95,105 JPEG oBtn[9]   RESOURCE "TEL_9"	  	SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("9",@cTelefone,oTel) BORDER CURSOR oCursor//"9"
		@115,65  JPEG oBtn[10]  RESOURCE "TEL_C"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("C",@cTelefone,oTel) BORDER CURSOR oCursor//"C"
		@115,85  JPEG oBtn[11]  RESOURCE "TEL_0"   		SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel("0",@cTelefone,oTel) BORDER CURSOR oCursor//"0"
		@115,105 JPEG oBtn[12]  RESOURCE "TEL_VIRGULA" 	SIZE 25,25 OF oDlg PIXEL ON CLICK SGKeyTel(",",@cTelefone,oTel) BORDER CURSOR oCursor//","
/*
		For nImage:= 1 To 13          
			oBtn[nImage]:oCursor:= oCursor
		Next nImage
*/
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avalia o complemento do Telefone. Caso seja necessario utilizar o campo U0_EXTERNA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Quando MV_TMKROTA estiver ativo não concatenará rota no telefone.
		If !SuperGetMV("MV_TMKROTA",.F.,.F.)
			cComplTel := TkPosto(TkOperador(),"U0_EXTERNA") 
		EndIf		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Objetos para a criacao da agenda telefonica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If lContato
			@ 01,135 SAY cDescCon SIZE 50,8 OF oDlg PIXEL COLORS (CLR_RED,CLR_RED) RAISED // Nome do Contato
			@ 10,135 LISTBOX oTelCont VAR nTelCont ITEMS aTelCont SIZE 55,50 OF oDlg PIXEL ;
					 ON CHANGE (cTelefone:= ALLTRIM(cComplTel)+ aTelCont[oTelCont:nAT],oTel:Refresh())
    	Endif
	    	
    	If lChave
			@ 65,135 SAY cDescEnt SIZE 50,8 OF oDlg PIXEL COLORS (CLR_RED,CLR_RED) RAISED //Nome da Entidade	
			@ 75,135 LISTBOX oTelEnt VAR nTelEnt ITEMS aTelEnt SIZE 55,50 OF oDlg PIXEL ;
					 ON CHANGE (cTelefone:=ALLTRIM(cComplTel)+ aTelEnt[oTelEnt:nAT],oTel:Refresh())
    	Endif
	    
	ACTIVATE MSDIALOG oDlg CENTER

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso ja foi informado o numero do telefone executa a discagem sem exibir a tela do telefone virtual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet:= SGDiskNumber(nTipSol,@cTelefone,cCTI,NIL, cTipoCTI)
Endif
	
Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGKeyTel  ³ Autor ³Fabio Rogerio Pereira  ³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o numero do telefone atraves dos botoes pressionados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP7    						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Caracter do botao pressionado                     ³±±
±±³          ³ ExpC2 -> Numero do telefone a ser montado                  ³±±
±±³          ³ ExpU1 -> Get com o telefone a ser discado                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGKeyTel(cKey,cTelefone,oTel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o numero do telefone. Caso pressionou "C" limpa o numero a ser discado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cKey == "C")
	cTelefone:= Space(16)
Else
	cTelefone:= ALLTRIM(cTelefone) + cKey 
	cTelefone+= Space(16 - Len(cTelefone))
Endif          

oTel:Refresh()
		
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGReadTel ³ Autor ³Fabio Rogerio Pereira  ³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os telefones do contato e entidade selecionada      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP7    						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Codigo da Entidade 			                      ³±±
±±³          ³ ExpC2 -> Chave da Entidade                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGReadTel(cEntidade,cChave)

Local aTel		:= {}
Local cOperEst  := TkPosto(TkOperador(),"U0_OPEREST")	// Operadora dentro do estado
Local cOperFora := TkPosto(TkOperador(),"U0_OPEFEST")	// Operadora fora do estado
Local cEstLocal := SuperGetMV("MV_ESTADO")					// Estado de onde se esta fazendo a ligacao (ATENDIMENTO ATIVO)
Local cTmkDDI   := SuperGetMV("MV_TMKDDI")					// Codigo que PRECEDE a discagem DDI - 00
Local cTmkDDD   := SuperGetMV("MV_TMKDDD")					// Codigo que PRECEDE a discagem DDD - 0 
Local cDDIPais  := SuperGetMV("MV_TMKPAIS")					// Pais de origem
Local cEstTel   := ""									// Estado PARA onde se esta fazendo a ligacao 	
Local cOperadora:= ""									// Codigo para usar a discagem por uma OPERADORA
Local lDDD      := .F.									// Flag para uso de DDD na composicao do telefone
Local lDDI      := .F.									// Flag para uso de DDI na composicao do telefone	
Local lOperadora:= .F.									// Flag para uso de Operadora na composicao do telefone
Local cDDOri	:= SuperGetMV("MV_TMKFRDD")					// DDD de origem - do cliente usuario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o estado esta Localizado o contato ou a entidade.                   ³
//³Primeiro verifico para o contato, se nao estiver preenchido verifico da entidade. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cChave) .AND. cEntidade == "SU5"
	cEstTel:= TkDadosContato(cChave,7)
Endif

If Empty(cEstTel)
	If !Empty(cChave)
		cEstTel	:= TkEntidade(cEntidade,cChave,4)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o numero a ser discado por Modem / CTI              ³
//³Digito Externo + Operadora + Telefone (DDI + DDD + Numero)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea(cEntidade)
DbSetOrder(1)
If DbSeek(xFilial(cEntidade) + cChave,.T.)
	Do Case
		
		Case (cEntidade == "SU2")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(SU2->U2_DDD)
					lOperadora := .T.
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SU2->U2_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIf ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SU2->U2_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   

				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica qual sera a operadora utilizada para realizar o DDD.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOperadora
				If (cEstLocal == cEstTel) .AND. !Empty(SU2->U2_DDD)
					cOperadora:= cTmkDDD + cOperEst
					
				ElseIf (cEstLocal <> cEstTel) .AND. !Empty(SU2->U2_DDD)
					cOperadora:= cTmkDDD + cOperFora
				Endif
			Endif
			
			If !Empty(SU2->U2_TEL)		// Somente se o telefone estiver preenchido
				If !Empty(cOperadora)
					Aadd(aTel,ALLTRIM(cOperadora + SU2->U2_DDD + SU2->U2_TEL))
				Else
					Aadd(aTel,ALLTRIM(SU2->U2_TEL))
				Endif
			Endif	
			
		Case (cEntidade == "AC4")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(AC4->AC4_DDI)
				If (ALLTRIM(AC4->AC4_DDI) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(AC4->AC4_DDD)
					lOperadora := .T.
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(AC4->AC4_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(AC4->AC4_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   
				
				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
				
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora
						If (cEstLocal == cEstTel) .AND. !Empty(AC4->AC4_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.
						
						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(AC4->AC4_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.						
						Endif
					Endif 
				Endif	
			Endif
			
			If !Empty(AC4->AC4_TEL)
				If !Empty(cOperadora)
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,AC4->AC4_DDI,"") + IIF(lDDD,AC4->AC4_DDD,"") + AC4->AC4_TEL))	
				Else
					Aadd(aTel,ALLTRIM(AC4->AC4_TEL))				
				Endif
			Endif	
			
		Case (cEntidade == "ACH")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(ACH->ACH_DDI)
				If (ALLTRIM(ACH->ACH_DDI) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(ACH->ACH_DDD)
					lOperadora := .T.
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(ACH->ACH_CIDADE)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(ACH->ACH_CIDADE)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   
				
				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
					
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora
						If (cEstLocal == cEstTel) .AND. !Empty(ACH->ACH_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.						
						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(ACH->ACH_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.
						Endif
					Endif
				Endif	
			Endif
			
			If !Empty(ACH->ACH_TEL)
				If !Empty(cOperadora)
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,ACH->ACH_DDI,"") + IIF(lDDD,ACH->ACH_DDD,"") + ACH->ACH_TEL))
				Else
					Aadd(aTel,ALLTRIM(ACH->ACH_TEL))
				Endif
			Endif	

		Case (cEntidade == "SA1")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SA1->A1_DDI)
				If (ALLTRIM(SA1->A1_DDI) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(SA1->A1_DDD)
					lOperadora := .T.
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SA1->A1_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SA1->A1_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   
				
				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
			
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora	
						If (cEstLocal == cEstTel) .AND. !Empty(SA1->A1_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.
							
						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(SA1->A1_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.
						Endif
					Endif
				Endif	
			Endif

			If !Empty(SA1->A1_TEL)
				If !Empty(cOperadora) 
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SA1->A1_DDI,"") + IIF(lDDD,SA1->A1_DDD,"") + SA1->A1_TEL))
				Else
					Aadd(aTel,ALLTRIM(SA1->A1_TEL))
				Endif
			Endif	

		Case (cEntidade == "SA2")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SA2->A2_DDI)
				If (ALLTRIM(SA2->A2_DDI) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(SA2->A2_DDD)
					lOperadora := .T.
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SA2->A2_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SA2->A2_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   

				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
			
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora
						If (cEstLocal == cEstTel) .AND. !Empty(SA2->A2_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.
						
						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(SA2->A2_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.
						Endif
					Endif
				Endif
			Endif
			
			If !Empty(SA2->A2_TEL)
				If !Empty(cOperadora)
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SA2->A2_DDI,"") + IIF(lDDD,SA2->A2_DDD,"") + SA2->A2_TEL))
				Else
					Aadd(aTel,ALLTRIM(SA2->A2_TEL))
				Endif
			Endif	
	
		Case (cEntidade == "SA3")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SA3->A3_DDI)
				If (ALLTRIM(SA3->A3_DDI) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(SA3->A3_DDD)
					lOperadora := .T.
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SA3->A3_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF  ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SA3->A3_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   
				
				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
			
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora
						If (cEstLocal == cEstTel) .AND. !Empty(SA3->A3_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.
						
						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(SA3->A3_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.
						Endif
					Endif
				Endif
			Endif
			
            If !Empty(SA3->A3_TEL)
				If !Empty(cOperadora)
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SA3->A3_DDI,"") + IIF(lDDD,SA3->A3_DDD,"") + SA3->A3_TEL))
				Else
					Aadd(aTel,ALLTRIM(SA3->A3_TEL))
				Endif
			Endif	

		Case (cEntidade == "SA4")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SA4->A4_DDI)
				If (ALLTRIM(SA4->A4_DDI) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(SA4->A4_DDD)
					lOperadora := .T.
				Endif	
			Else
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SA4->A4_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SA4->A4_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   
				Endif
			Endif	
			
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora
						If (cEstLocal == cEstTel) .AND. !Empty(SA4->A4_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.

						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(SA4->A4_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.
						Endif
					Endif
				Endif
			Endif
						
            If !Empty(SA4->A4_TEL)
				If !Empty(cOperadora)
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SA4->A4_DDI,"") + IIF(lDDD,SA4->A4_DDD,"") + SA4->A4_TEL))
				Else
					Aadd(aTel,ALLTRIM(SA4->A4_TEL))
				Endif
			Endif	
			
		Case (cEntidade == "SUS")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SUS->US_DDI)
				If (ALLTRIM(SUS->US_DDI) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(SUS->US_DDD)
					lOperadora := .T.
				Endif	
			Else
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SUS->US_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF  ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SUS->US_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   
					
				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
			
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora
						If (cEstLocal == cEstTel) .AND. !Empty(SUS->US_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.			
						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(SUS->US_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.
						Endif
					Endif
				Endif
			Endif

            If !Empty(SUS->US_TEL)
				If !Empty(cOperadora)
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SUS->US_DDI,"") + IIF(lDDD,SUS->US_DDD,"") + SUS->US_TEL))
				Else
					Aadd(aTel,ALLTRIM(SUS->US_TEL))
				Endif
			Endif	
	
		Case (cEntidade == "SU5")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o pais de origem e o pais das ligacoes 					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SU5->U5_CODPAIS)
				If (ALLTRIM(SU5->U5_CODPAIS) <> cDDIPais)
					cOperadora := cTmkDDI + cOperFora
					lDDI := .T.
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDDOri)
				If TRIM(cDDOri) <> TRIM(SU5->U5_DDD)
					lOperadora := .T.
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se estao no mesmo estado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEstLocal == cEstTel)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(SU5->U5_MUN)) .AND. !Empty(SM0->M0_CIDCOB)
					   lOperadora := .T.
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIF  ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(SU5->U5_MUN)) .AND. !Empty(SM0->M0_CIDENT)
					   lOperadora := .T.
					Endif				   

				Elseif !Empty(cEstTel) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estados diferentes sera obrigatorio o uso da operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOperadora := .T.
				Endif
			Endif
	
			If Empty(cOperadora)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera a operadora utilizada para realizar o DDD.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cEstTel)
					If lOperadora
						If (cEstLocal == cEstTel) .AND. !Empty(SU5->U5_DDD)
							cOperadora:= cTmkDDD + cOperEst
							lDDD := .T.
						ElseIf (cEstLocal <> cEstTel) .AND. !Empty(SU5->U5_DDD)
							cOperadora:= cTmkDDD + cOperFora
							lDDD := .T.
						Endif
					Endif
				Endif
			Endif
			
			If !Empty(cOperadora)
				If !Empty(TRIM(SU5->U5_FCOM1))
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SU5->U5_CODPAIS,"") + IIF(lDDD,SU5->U5_DDD,"") + SU5->U5_FCOM1))
                Endif
				If !Empty(TRIM(SU5->U5_FCOM2))
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SU5->U5_CODPAIS,"") + IIF(lDDD,SU5->U5_DDD,"") + SU5->U5_FCOM2))
                Endif
				If !Empty(TRIM(SU5->U5_CELULAR))
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SU5->U5_CODPAIS,"") + IIF(lDDD,SU5->U5_DDD,"") + SU5->U5_CELULAR))
                Endif
				If !Empty(TRIM(SU5->U5_FONE))
					Aadd(aTel,ALLTRIM(cOperadora + IIF(lDDI,SU5->U5_CODPAIS,"") + IIF(lDDD,SU5->U5_DDD,"") + SU5->U5_FONE))
                Endif
			Else
				IIF(!Empty("SU5->U5_FCOM1")		,Aadd(aTel,SU5->U5_FCOM1)	,"")
				IIF(!Empty("SU5->U5_FCOM2")		,Aadd(aTel,SU5->U5_FCOM2)	,"")
				IIF(!Empty("SU5->U5_CELULAR")	,Aadd(aTel,SU5->U5_CELULAR)	,"")
				IIF(!Empty("SU5->U5_FONE")		,Aadd(aTel,SU5->U5_FONE)	,"")
			Endif
	EndCase
Endif

Return(aTel)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGDiskNumber ³ Autor ³Fabio Rogerio Pereira  ³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Envia o comando de discagem para CTI/MODEM e encerra a         ³±±
±±³          ³comunicacao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP7    						                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Numero da Solicitacao do Recurso                     ³±±
±±³          ³ ExpC1 -> Numero do Telefone a ser discado                     ³±±
±±³          ³ ExpC2 -> Modelo da CTI					                     ³±±
±±³          ³ ExpC3 -> Codigo do Atendimento / Codigo da Lista (SU6 -Item)  ³±±
±±³          ³ ExpC4 -> Tipo de integracao CTI utilizada.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGDiskNumber(	nTipSol,	cTel,	cCTI,	cCodLig,; 
								cTipoCTI, cRota)

Local nRet    	:= 0
Local aBuffer 	:= {}
Local aParam 	:= {} 
Local cPhoneNumber	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o conteudo do telefone para garantir a discagem - somente quando for CTI  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCTI)
	cTel := SgLimpaTel(cTel)
Endif	

If cTipoCTI == USE_SMARTCTI 
	SMSetShowUsrMsg(.T.)
	DEFAULT cCodLig := ""
	
	If nTipSol == 04  //Discagem Externa
		cPhoneNumber := AllTrim(cCodLig) + AllTrim(cTel)	
	Else
		cPhoneNumber := AllTrim(cTel)
	Endif				    
	Do Case

		Case nTipSol == 06	//"Transferencia"   
			nRet := oAgtSmartCTI:OneStepCallTransfer(cPhoneNumber)	   
			
		Case nTipSol == 07	//"Conferencia"     
			nRet := oAgtSmartCTI:Conference()	
			
		Case nTipSol == 08	//"Consulta ao Supervisor"
			nRet := oAgtSmartCTI:Consultation(cPhoneNumber,cRota)	
			
		Case nTipSol == 18	//"Siga-Me"              
			nRet := oAgtSmartCTI:Redirect(cPhoneNumber)	
			
		Otherwise	// 04 - "Discagem Automatica" / 30 -"Discagem Interna" 	
			nRet := oAgtSmartCTI:MakeCall(cPhoneNumber)	                            
			
	EndCase		    
	If nRet <> SMARTCTI_SUCCESS
		MsgInfo( oAgtSmartCTI:DescError(nRet, STR0167 + cPhoneNumber + Chr(13) + Chr(10) + STR0168 + oAgtSmartCTI:cDevice ,.F.), STR0001)	// "Telefone: " "Ramal: "
		If nRet == SMARTCTI_INVALIDUSER
			If MsgYesNo(STR0193,STR0001)	// "Deseja Tentar Novamente ?"#"Listner de Ligação"			
				oAgtSmartCTI:Close()
				oAgtSmartCTI := NIL
				SMCTIOpen(__cUserId)
				SGDiskNumber(nTipSol, cTel, cCTI, cCodLig, cTipoCTI)				
			EndIf			
		EndIf
	EndIf
Else
	DEFAULT cCodLig := "000000"

	If nTipSol == 04  //Discagem Externa
		aParam := {cCodLig,cTel}	
	Else
		aParam := {cTel}
	Endif		
	nRet := SGSendCti( nTipSol, aParam, @aBuffer)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha a comunicacao com o MODEM.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nRet == 0 .AND. Empty(cCTI)
		SGSendCti( 25, {}, @aBuffer)
	Endif
EndIf	
	
Return(nRet)

/*/          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SGRecPlay    ³ Autor ³Fabio Rogerio Pereira  ³ Data ³06/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe a tela para a selecao do arquivo de gravacao/reproducao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGA   						                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Opcao do PopUp Menu selecionada                      ³±±
±±³          ³ ExpC2 -> Tipo de integracao CTI.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGRecPlay(cMenuItem, cTipoCTI)
Local oDlg
Local oRecPlay
Local oBtn
Local nRet    := 0
Local nPos    := 0
Local nTipSol := 0
Local cRecPlay:= SPACE(40)
Local aBuffer := {}
Local aTipSol := {	{"A",STR0050 ,20},; //"Gravacao"
					{"B",STR0125 ,21},; //"Fim da Gravacao" //"Fim da gravação"
					{"C",STR0051 ,22}} //Reproducao

nPos    := Ascan(aTipSol,{|x| x[1] == cMenuItem}) 					
cTitle  := aTipSol[nPos,2]
nTipSol := IIF(aTipSol[nPos,3] == 20 .AND. lRecPlay,20,aTipSol[nPos,3])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o comando de inicio de gravacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nTipSol == 20)
	If cTipoCTI == USE_SMARTCTI    
		nRet := oAgtSmartCTI:StartRec()
	Else	
		nRet:= SGSendCti( nTipSol, {}, @aBuffer)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o comando de fim de gravacao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nTipSol == 21)
	If cTipoCTI == USE_SMARTCTI    
		nRet := oAgtSmartCTI:StopRec()
	Else	
		nRet:= SGSendCti( nTipSol, {}, @aBuffer)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tela para a reproducao das chamadas gravadas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nTipSol == 22)
 
	DEFINE MSDIALOG oDlg FROM  300,20 TO 400,280 TITLE cTitle PIXEL 
	
		@ 02,02 TO 20,125  LABEL "" OF oDlg PIXEL
	
		@ 07,05 SAY STR0052 OF oDlg PIXEL //"Arquivo"
		@ 07,35 MSGET oRecPlay VAR cRecPlay OF oDlg PIXEL SIZE 70 ,9
		
		@ 11,210 BTNBMP oBtn RESOURCE "VENDEDOR" SIZE 27,25 OF oDlg PIXEL; //"Escolha o Arquivo" "Chamadas Gravadas (*.*)     | *.* | "
	 	ACTION cRecPlay:= cGetFile(STR0053,STR0054,0,cRecPlay,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) 
	
		DEFINE SBUTTON FROM 25,65 TYPE 1  ENABLE OF oDlg ACTION (nRet:= SGSendCti( nTipSol, {cRecPlay}, @aBuffer), oDlg:End())
		DEFINE SBUTTON FROM 25,95 TYPE 2  ENABLE OF oDlg ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTER
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o status da reproducao/gravacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nRet == 0)
	lRecPlay := !lRecPlay
Endif
	
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SgRotina    ³ Autor ³Fabio R. Pereira    ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o Operador e um atendente receptivo ou ativo     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SgRotina()
Local cPosto := SuperGetMV("MV_POSTO")
Local lRet   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o posto de venda do operador.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SU7")
DbSetorder(4)
If DbSeek(xFilial("SU7") + cCodUsLog)
	cPosto 	:= SU7->U7_POSTO
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o posto de venda do operador trabalha como receptivo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU0")
DbSetOrder(1)
If DbSeek(xFilial("SU0") + cPosto)
	If (SU0->U0_BOUND == "1") .OR. (SU0->U0_BOUND == "3")   //RECEPTIVO - AMBOS
		lRet := .T.
	Endif                
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SGAvalErro  ³ Autor ³Marcelo Kotaki      ³ Data ³ 24/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna uma string com a descricao do codigo de erro       ³±±
±±³          ³ que foi enviado a partir da excucado da SIGACTI.DLL        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGAvalErro(nErro)

Local cMsgErro := STR0157 //"Falha desconhecida"			// Descricao do retorno

Do Case
	Case nErro == -1
		cMsgErro := STR0131 // "Falha no retorno do Equipamento CTI - não respondeu a um comando"

	Case nErro == -3
		cMsgErro := STR0132 //"Falha ao registrar o Equipamento CTI - verifique o software de integração"

	Case nErro == -5
		cMsgErro := STR0133 //"Falha ao tentar ativar a comuicação com a CTI"	

	Case nErro == -6
		cMsgErro := STR0134 //"Falha ao conectar com a CTI"	

	Case nErro == -7
		cMsgErro := STR0135 //"Falha ao desconectar da CTI"	

	Case nErro == -8
		cMsgErro := STR0136 //"Falha ao efetuar uma ligação"	

	Case nErro == -9
		cMsgErro := STR0137 //"Falha ao receber uma ligação"	

	Case nErro == -10
		cMsgErro := STR0138 //"Falha ao transferir uma ligação"	

	Case nErro == -11
		cMsgErro := STR0139 //"Falha ao criar uma conferência"	

	Case nErro == -12
		cMsgErro := STR0140 //"Falha ao criar uma consulta"	

	Case nErro == -13
		cMsgErro := STR0141 // "Falha na tentativa de Hold"	

	Case nErro == -14
		cMsgErro := STR0142 // "Falha na tentativa de UnHold"	

	Case nErro == -15
		cMsgErro := STR0143 //"Falha ao ativar um usuário"	

	Case nErro == -16
		cMsgErro := STR0144 //"Falha ao efetuar uma pausa"	

	Case nErro == -17
		cMsgErro := STR0145 //"Falha ao alteranar uma ligação"	

	Case nErro == -18
		cMsgErro := STR0146 //"Falha ao abortar uma ligação"	

	Case nErro == -19
		cMsgErro := STR0147 //"Falha ao checar o status da ligação"	

	Case nErro == -20
		cMsgErro := STR0148 //"Falha ao checar o status do usuário"	

	Case nErro == -21
		cMsgErro := STR0149 //"Falha ao efetuar uma chamada para FAX"	

	Case nErro == -22
		cMsgErro := STR0150 //"Falha na tentativa de ligar o Follow-me"	

	Case nErro == -23
		cMsgErro := STR0151 //"Falha ao verificar Pendências"	

	Case nErro == -24
		cMsgErro := STR0152 //"Falha ao iniciar a gravação"	

	Case nErro == -25
		cMsgErro := STR0153 //"Falha ao Finalizar a gravação"	

	Case nErro == -26							
		cMsgErro := STR0154 //"Falha ao executar uma gravação"	
EndCase

Return(cMsgErro)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SGCheckUser ³ Autor ³Marcelo Kotaki      ³ Data ³ 04/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para validar o usuario atraves de PONTO DE ENTRADA  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8  		                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SGCheckUser()

Local lTKVALUSER := ExistBlock( 'TKVALUSER' )  //Ponto de Entrada para a validacao do usuario
Local lRet       := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para a validacao do usuario - Se o usuario estiver correto retorna TRUE ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTKVALUSER
	lRet := ExecBlock( 'TKVALUSER', .F., .F., {} )
	lRet := IIf( ValType( lRet ) <> 'L', .T., lRet )
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SGRetRamal  ³ Autor ³Marcelo Kotaki      ³ Data ³ 03/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o ramal atual do usuario pesquisando no SUV        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGRetRamal()

Local cRamal := CriaVar("UV_RAMAL",.F.)		// Numero do Ramal
Local aArea  := GetArea()					// Salva a area atual

DbSelectArea("SUV")
DbSetOrder(1)
If DbSeek(xFilial("SUV") + cCodUsLog)
	cRamal := SUV->UV_RAMAL
Endif

RestArea(aArea)
Return(cRamal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SGPulse     ³ Autor ³Marcelo Kotaki      ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia um pulso para a CTI para saber se o aplicativo dela  ³±±
±±³          ³ esta ativo                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGPulse(oTimer1)
Local aBuffer:= {}
Local lRet 	 := .T.
Local nRet	 := 0 
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe ligacao para o usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcessMessages()
oTimer1:DeActivate()
                   
If !lAbreCTI
	lRet := .F.
Else	

	nRet := SGSendCti( 27, {}, @aBuffer )
	If nRet < 0 .OR. nRet = 99 // TimeOut
		lRet := .F.
	Endif
Endif

oTimer1:Activate()
ProcessMessages()
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SgListnerOn ³ Autor ³Marcelo Kotaki      ³ Data ³ 05/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se ja existe uma instancia criada da tela de      ³±±
±±³          ³ LISTNER de ligacao - Nao podem haver duas telas para isso  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGListnerOn(cBuffer)

Local lRet 	:= .F.		// Retorno da funcao
Local nRet	:= -1		// Retorno da solicitacao da DLL

DEFAULT cBuffer := '28|'+STR0056+'|'		// Atendimento Receptivo
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
// Verifica se a DLL esta carregada
If (nHandle >= 0) 
	nRet := ExeDllRun2( nHandle, 28, cBuffer)
	If nRet > 0
		lRet := .T.   
	Endif
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SGRetSlCod  ³ Autor ³Marcelo Kotaki      ³ Data ³ 04/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a descricao do codigo de solicitacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGRetSlCod( nCod )
Local cCod := STR0083 // "Solicitação desconhecida"

Do Case 
	Case nCod == 0 
		cCod := STR0084 // "Abertura da cti"
	Case nCod == 1
		cCod := STR0085 //"CTI - ativação"
	Case nCod == 2
	   	cCod := STR0086 //"Conexão com a CTI"
	Case nCod == 3
     	cCod := STR0087 //"Desconexão com a CTI"
	Case nCod == 4
		cCod := STR0088 //"Realizacao de chamadas - Discagem via CTI"
	Case nCod == 5
		cCod := STR0089 //"Recebimento de chamadas"
	Case nCod == 6
		cCod := STR0090 //"Transferencia de chamadas"
	Case nCod == 7
		cCod := STR0091 //"Conferencia"
	Case nCod == 8
		cCod := STR0092 //"Consulta ao supervisor"
	Case nCod == 9
		cCod := STR0093 //"Espera"
	Case nCod == 10
		cCod := STR0094 //"Libera espera"
	Case nCod == 11
		cCod := STR0095 //"Ativa usuario"
	Case nCod == 12
		cCod := STR0096 //"Pausa no usuario"
	Case nCod == 13
		cCod := STR0097 //"Alterna chamadas"
	Case nCod == 14
		cCod := STR0098 //"Aborta inicio de chamadas"
	Case nCod == 15
		cCod := STR0099 //"Status da chamada"
	Case nCod == 16
		cCod := STR0100 //"Status do usuario"
	Case nCod == 17
		cCod := STR0101 //"Envio de fax"
	Case nCod == 18
		cCod := STR0102 //"Siga-me. transferencia temporaria de chamadas"
	Case nCod == 19
		cCod := STR0103 //"Pendencias"
	Case nCod == 20
		cCod := STR0104 //"Início de gravacao"
	Case nCod == 21
		cCod := STR0105 //"Fim de gravacao"
	Case nCod == 22
		cCod := STR0106 //"Reproducao da gravacao"
	Case nCod == 23
		cCod := STR0107 //"Lista as CTI's homologadas"
	Case nCod == 24
		cCod := STR0108 //"Realizacao de chamadas via modem"
	Case nCod == 25
		cCod := STR0109 //"Finalizacao de chamadas via modem"
	Case nCod == 26
		cCod := STR0110 //"Fechamento da CTI"
	Case nCod == 27
		cCod := STR0111 //"Pulso de verificacao"
	Case nCod == 999
		cCod := STR0112 //"Versao da sigacti.dll"
EndCase

Return cCod

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ SgLogDll    ³ Autor³Marcelo Kotaki       ³Data  ³ 05/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava um arquivo de Log  para as informacoes trocadas      ³±±
±±³          ³ entre a CTI e o PROTHEUS                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MP8 	  												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SgLogDLL( 	cDados,	cFuncao, cLine, lSend ,;
					cComando )

Local lRet    	:= .T.		// Retorno dessa funcao
Local cNome		:= ""		// Nome do usuario que esta sendo monitorado pelo LOG
Local cRamal	:= ""		// Ramal que foi logado
Local cGrupo	:= ""		// Grupo do usuario
Local cLog    	:= ""		// Campo auxiliar
Local nAux 		:= 0		// Handle de abertura e gravacao do arquivo .LOG
Local cText     := STR0067 	// "Comando enviado em:"
Local cFileLog  := ""       // Nome do arquivo de .LOG
Local aUser 	:= {}		// Array com os dados do usuarlo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente grava se usuria ativou o log. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSgCTILog
	If cComando == "**"
		cComando := "Interno"
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o PROTHEUS enviou um comando - verifica qual o comando³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSend	
		Do Case
		   Case cFuncao == "SGCTIVER"
				cFuncao := STR0114 //"Comparacao da versao da DLL com o Protheus"
				
		   Case cFuncao == "SGOPEN"
				cFuncao := STR0115 //"Abertura da DLL pelo PROTHEUS"
				
		   Case cFuncao == "SGACTIVE"
		   		cFuncao := STR0116 //"Conexao Ativa"
			
		   Case cFuncao == "SGLOGINUSER"
		   		cFuncao := STR0117 //"Login do Agente"
		   		
		   Case cFuncao == "SGLOGOUT"
		   		cFuncao := STR0118 //"Logout do Agente"

		   Case cFuncao == "SGPULSE"
		   		cFuncao := "Pulso de verificacao"
		EndCase
	Endif

	cFileLog  := ALLTRIM(GetPvProfString(GetEnvServer(),"startpath","",GetADV97()))

	// Monta o nome do arquivo de log que sera grava no StartPath (SIGAADV)
	If Subs(cFileLog,Len(cFileLog),1) <> "\"
		cFileLog += "\"
	Endif
	
	cFileLog += "APCTILOG.LOG"
	
	If !lSend 
		cText := STR0068 // 'Comando recebido em: '
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica as informacoes do usuario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aUser) == 0 // Somente pega uma vez para nao ficar pesquisando no PSW (Aumento de performance)
		PswOrder(1)
		If PswSeek(cCodUsLog)
			aUser:= PswRet(1)
		Else
			aUser := Array(1,20)
			aUser[1][2] := STR0082 //"Usuario nao encontrado"
			aUser[1][20] := ""
			aUser[1][12] := ""
	    Endif
	Endif
	
	If Len(aUser) > 0 
		cNome  := aUser[1][2] 	// Nome
		cGrupo := aUser[1][12] 	// Grupo
		cRamal := aUser[1][20] 	// Ramal
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A gravacao das informacoes serao diferentes de acordo com quem envia o arquivo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSend
	
		cLog := "------------------------------------------------------------------------------------------------"+;
				Chr(13)  + Chr(10)  + cText + DToC(Date()) + ' - ' + Time() + Chr(13) + Chr(10)+;
				Chr(13)  + Chr(10)  +;
				Chr(13)  + Chr(10)  +;
				STR0069  + cFuncao	+ Chr(13) + Chr(10) +; //'Funcao: '
				STR0070  + cLine  	+ Chr(13) + Chr(10) +; //'Linha: '
				STR0071  + cNome  	+ Chr(13) + Chr(10) +; //'Usuario: '
				STR0072  + cGrupo 	+ Chr(13) + Chr(10) +; //'Grupo: '
				STR0073  + cRamal 	+ Chr(13) + Chr(10) +; //'Ramal: '
				STR0074  + cDados 	+ Chr(13) + Chr(10) +; //'Dados: '
				STR0080  + cComando	+ Chr(13) + Chr(10) +; //'Comando: '
				Chr(13)  + Chr(10) 	+;
				Chr(13)  + Chr(10)			
	Else
	
		cLog := Chr(13)  + Chr(10)  + cText + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)+;
				Chr(13)  + Chr(10) 	+;
				Chr(13)  + Chr(10) 	+;
				STR0071  + cNome  	+ Chr(13) + Chr(10) +; //'Usuario: '
				STR0072  + cGrupo 	+ Chr(13) + Chr(10) +; //'Grupo: '
				STR0073  + cRamal 	+ Chr(13) + Chr(10) +; //'Ramal: '
				STR0081  + TRIM(cDados) + Chr(13) + Chr(10) +; //"Retorno da CTI: "
				Chr(13)  + Chr(10) +;
				Chr(13)  + Chr(10)				
	Endif
			
	If File(cFileLog)
		nAux := fOpen(cFileLog, FO_READWRITE+FO_SHARED)
	Else
		nAux := fCreate(cFileLog,0)
	Endif
	
    If nAux == -1
    	//Conout(STR0075 + cFileLog + STR0076 + Str(FERROR()))  //'Erro gravando o arquivo de Log: ',' Codigo do Erro: '
    Else
    	FSeek(nAux,0,2)
		FWrite(nAux, cLog)
		FClose(nAux)
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SGCTILogOn   ³ Autor³Fernando Godoy       ³Data  ³ 04/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Liga a gravacao do arquivo de Log                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MP8 	  												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SgCTILogOn()

lSgCTILog := .T.

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SgCTILogOff  ³ Autor³Fernando Godoy       ³Data  ³ 04/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desliga a gravacao do arquivo de Log                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³AP7     												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SgCTILogOff()

lSgCTILog := .F.

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGAtivo   ºAutor  ³Marcelo Kotaki      º Data ³  17/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Fecha a tela de discagem ATIVA se o comando foi enviado com º±±
±±º          ³sucesso (ou seja o equipamento respondeu esse envio)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGAtivo(	nTipSol,	cTel,	cCTI,	oDlg,; 
							cTipoCTI,cRota)
Local nRet := -1      

If !Empty(TRIM(cTel))
	nRet := SGDiskNumber(nTipSol,@cTel,cCTI,NIL, cTipoCTI,cRota)

	If nRet == 0			// Retorno positivo fecha a tela do SgSkinTel()
		oDlg:End()
	Endif
Endif		

Return(NIL)
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGLimpaTelºAutor  ³Marcelo Kotaki      º Data ³  19/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Limpa os caracteres invalidos do telefone que sera discado  º±±
±±º          ³para um envio correto do comando 04 para o equipamento      º±±
±±º          ³- Essa funcao tambem e usada no Cadastro de Prospect        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SgLimpaTel(cTel)
Local nCont		 := 0 
Local cTelNumero := ""  			// Codigo de telefone somente com NUMEROS - sem mascara

For nCont := 1 TO LEN(cTel)
	If (Substr(cTel,nCont,1) $ "0123456789")
		cTelNumero += Substr(cTel,nCont,1)
	Endif	
Next nCont 

Return(cTelNumero)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGAtender ºAutor  ³Marcelo Kotaki         º Data ³  09/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Essa funcao envia o comando de ATENDER para o equipamento CTI  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SGAtender(ExpC1)                                    			 ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Tipo de CTI utilizado pelo operador.                  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGAtender(cTipoCTI)
Local aBuffer:= {}         

Default cTipoCTI := USE_CTI
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
If cTipoCTI = USE_SMARTCTI
    if(!lInCall)
		oAgtSmartCTI:Answer()	
	EndIf	
Else             
	SGSendCti( 31, {}, @aBuffer)
EndIf
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGDesligarºAutor  ³Marcelo Kotaki         º Data ³  09/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Essa funcao envia o comando de DESLIGAR para o equipamento CTI º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGDesligar()
Local aBuffer:= {}
             
SGSendCti( 32, {}, @aBuffer)

Return(.T.)
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGDirRx   ºAutor  ³Microsiga           º Data ³  09/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada para leitura do arquivo de RX              º±±
±±º          ³- USO INTERNO SOMENTE -                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MP8                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function SGDirRx()

Local lTMKRX := ExistBlock( 'TMKRX' ) // P.E. para informar o diretorio de RX
Local cRet	 := SuperGetMV("MV_TMKCTRX")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para alteracao dos diretorios de TROCA -  RX ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKRX
	cRet := ExecBlock( 'TMKRX', .F., .F., {} )
	If (ValType(cRet) <> "C")
		Return(SuperGetMV("MV_TMKCTRX"))	   			//Diretorio de RECEPCAO
	Endif
Endif

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGDirTx   ºAutor  ³Microsiga           º Data ³  09/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada para leitura do arquivo de TX              º±±
±±º          ³- USO INTERNO SOMENTE -                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function SGDirTx()

Local lTMKTX := ExistBLock( 'TMKTX' ) // P.E. para informar o diretorio de TX
Local cRet	 := SuperGetMV("MV_TMKCTTX")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para alteracao dos diretorios de TROCA -  TX ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKTX
	cRet := ExecBlock( 'TMKTX', .F., .F., {} )
	If (ValType(cRet) <> "C")
		Return(SuperGetMV("MV_TMKCTTX"))	   			//Diretorio de TRANSMISSAO
	Endif
Endif

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGJOBPULSOºAutor  ³Marcelo Kotaki        º Data ³  15/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Job para envio do comando de pulso para a CTI                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP6                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function SGJOBPULSO(cEmp,cFil)
Local nRet := 0 	//Retorno das funcoes

Private cPaisLoc := "BRA", __lPYME 
Private __cUserID

cEmp := "99"
cFil := "01"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define  ambiente de trabalho	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ConOut("Empresa....: " +cEmp)
ConOut("Filial.....: " +cFil)

PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil FUNNAME "SGJOBPULSO" TABLES "SU0","SU7"

lSgCTILog := SuperGetMV("MV_TKCTILG",.F.)   //Verifica se deve gravar ou nao um log das operacoes com a SIGACTI

If TRIM(SuperGetMV("MV_TMKCTI")) == "GENERIC"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todas as mensagens que serao exibidas no SERVER devem ser feitas via CONOUT     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConOut("------->>>  Iniciando JOB para envio de PULSO para a CTI conectada...")
	
	While !KillApp() //.AND. (nRet == 0)
		BEGIN SEQUENCE                   
			
			nRet := SGOpen()
			If nRet >= 0
				ConOut("------------------------------------------>>> Enviado comando de PULSO com resposta Positiva")
            Else
   				ConOut("--->>> Enviado comando de PULSO com resposta NEGATIVA - Falha na conexao do SW da plataforma")
		    Endif
			
			Sleep(1000)		//Delay de 5 segundos
		END SEQUENCE
	End       
Endif

RESET ENVIRONMENT

Return(NIL)

*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MsAvalOut ºAutor  ³Marcelo Kotaki      º Data ³  23/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe arquivos para atendimento receptivo no   º±±
±±º          ³diretorio de leitura do Protheus                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus integrado com C.T.I.                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MsAvalOut(nTipSol,cBuffer,cDirRX)

Local cArquivo	:= cDirRx + cCodUsLog+".CTI"
Local nRet		:= 0
Local nHandAux  

If nTipSol == 5 // Atendimento Receptivo
	If File(cArquivo)
		nHandAux := FOpen(cArquivo)
		If nHandAux < 0
			nRet := FError()
		Else
			FRead(nHandAux, @cBuffer,Len(cBuffer))
			FClose(nHandAux)
			If Len(cBuffer) > 0
				cBuffer := Substr(cBuffer,3,Len(cBuffer))
			Endif
			FErase(cArquivo)
		Endif
	Endif
Endif

Return(nRet)			
			           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SMCTIOpen()     ³ Autor ³Michel W. Mosca      ³ Data ³06/11/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Abre a comunicação da API SmartCTI.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MP8    						                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMCTIOpen(ExpC1, ExpC2, ExpN3, ExpL4)                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do usuario no Protheus.              		      ³±±
±±³          ³ ExpC2 = Numero do ramal do operador.              			  ³±±
±±³          ³ ExpC3 = Numero do middleware a ser conectado.               	  ³±±
±±³          ³ ExpL4 = Habilita a exibicao de msgbox da API.              	  ³±±
±±³          ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SMCTIOpen(cCod, cDevice, iLinkID, lShowAPIMessages, cAgentPass)
Local lRet	  	:= .F.					// Retorno dessa funcao
Local aUser		:= {}					// Array auxiliar  

Default lShowAPIMessages	:= .T. 
Default cDevice 			:= "0"
Default iLinkID 			:= 0
Default cAgentPass 			:= ""
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario utiliza CTI e se existe uma configurada ³ 
//³Se a DLL nao estiver aberta ( nHandle == -1 ) significa que e ³
//³necessario abrir a comunicacao com a mesma					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Empty(oAgtSmartCTI))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pela codigo do usuario logado no PROTHEUS - SIGACFG³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PswOrder(1)
	If PswSeek(cCod)
        aUser := PswRet(1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abre a comunicacao com a API ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oAgtSmartCTI := AgentSmartCTI():New(cDevice, iLinkID, cCod, cAgentPass)
		oAgtSmartCTI:EnableUserMsg(lShowAPIMessages)      
		//oAgtSmartCTI:cCodUsrProtheus := cCod
		//oAgtSmartCTI:AddEventListener(TMKAgentEvents():New() )//Adiciona a classe de eventos
   	    If oAgtSmartCTI:Connect() == SMARTCTI_SUCCESS     
   	    	lRet := .T.	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o usuario esta configurado adequadamente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aUser) > 0
				If !Empty(aUser[1][19])
					lAbreCTI := .T.									
				Endif	
		
			Endif		
		Endif			
	Endif
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)		
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SMCTILoginUser  ºAutor  ³Michel Mosca      º Data ³  06/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia o comando de Login do operador no CTI.                    º±±
±±º          ³                                                                º±±
±±º          ³                                                                º±±
±±º          ³                                                                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMCTILoginUser(ExpC1, ExpC2)			                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do usuario no DAC.                   		      ³±±
±±³          ³ ExpC2 = Codigo do DAC.                            			  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SMCTILoginUser(cPIN, cGroup)

Local lRet   := .F.						// Retorno da funcao
Local lLock  := .T.						// Flag para o registro	
Local aUser  := {}						// Array com dados do usuário
Local aParam := {}						// Array com parametros para serem passados à funcao
Local cServer:= SuperGetMV("MV_TMKSERV")		// Endereco IP do servidor RPCCallBack
Local cTmp	 := SPACE(4)				// Variavel auxiliar para ser utilizado no tratamento de string
Local nRet	 := -1 						// Retorno da funcao
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a conexão cti suporta Receptivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Type("oAgtSmartCTI:Bound") <> "U" .AND. !(oAgtSmartCTI:Bound $ "1|3") ) // Inbound # Both
	Help(" ",1,"CTIINBOUND")
	Return(lRet)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o modulo for o Call Center verifica se o posto de venda trabalha como ATIVO     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AmIIn(13,73) .AND. !SgRotina()
	MsgStop(STR0113,STR0027) //"O Operador nao esta cadastrado para ser Receptivo","Atencao"
	Return(lRet)
Endif
            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as informacoes do usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PswOrder(1)
If PswSeek(cCodUsLog)
	aUser := PswRet(1)
Endif		

// Nome
Aadd(aParam,ALLTRIM(aUser[1][2]))

// Senha
Aadd(aParam,ALLTRIM(aUser[1][3]))

// Ramal 
cTmp := aUser[1][20]


// Atualiza o array de usuario
aUser[1][20] := ALLTRIM(cTmp)

//Ramal
Aadd(aParam,ALLTRIM(aUser[1][20]))

//Grupo
Aadd(aParam,ALLTRIM(aUser[1][12]))

//Server
Aadd(aParam,ALLTRIM(cServer))           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Carrega a Identificação do Operador e o Nome do Grupo de Atendimento	   |	
//|para ser enviado no Logon do Operador.                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SMGetAgentID(cCodUsLog, @cPIN, @cGroup)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza um lock no registro para assim indicar que o usuário esta ativo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aUser[1][19])
	DbSelectArea("SUV")
	DbSetOrder(1)
	If DbSeek(xFilial("SUV") + cCodUsLog)
		lLock:= .F.
	Endif
	
	RecLock("SUV",lLock)
	UV_FILIAL  := xFilial("SUV")
	UV_USUARIO := cCodUsLog
	UV_RAMAL   := cTmp
	DbCommit()       
	MsUnLock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia o comando de LOGIN DO AGENTE para a CTI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet := oAgtSmartCTI:Logon(Trim(cPIN),Trim(cGroup))
	If nRet == SMARTCTI_SUCCESS 
		lRet:= .T.
	Endif                         
Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(lRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SMGetAgentID 		ºAutor  ³Michel W. Moscaº Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem o AgentId e o Grupo que deveram ser conectados no CTI.   º±±
±±º          ³                                                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMGetAgentID(ExpC1, ExpC2, ExpC3)                              ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do usuario no Protheus.              		      ³±±
±±³          ³ ExpC2 = Codigo do usuario no DAC.                   		      ³±±
±±³          ³ ExpC3 = Codigo do DAC.                            			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SMGetAgentID(cCodUsLog, cPIN, cGroup)
Local lRet := .F. //Avalia se encontrou o agente
Local aGroups := {} //Grupos usado quando envia somente 1 comando de logon para todos os DACs do operador
Local lSnd1Login := SuperGetMV("MV_TKSND1L",,.F.) // Indica se os logons serão executados 1 por cada DAC (valor .F.) ou se sera enviado apenas 1 comando contendo todos os Grupos (valor .T.)
Local nI := 0
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
cPIN 	:= ""
cGroup  := ""
DbSelectArea("SU7")
DbSetOrder(4)
If DbSeek(xFilial("SU7") + cCodUsLog)
	lRet := .T.
	cPIN := SU7->U7_AGENTID
	DbSelectArea("SU0")			
	If DbSeek(xFilial("SU0") + SU7->U7_POSTO)
		If !lSnd1Login
			cGroup := SU0->U0_ACDGRP
		Else
			//Agroups
			//1 - Indica se esta checado ou não
			//2 - Codigo do Grupo DAC
			//3 - Nome do Grupo DAC
			//4 - Numero do Grupo DAC
			aGroups := SGNewScreen()
			For nI = 1 to Len(aGroups)
				If nI = Len(aGroups)
					cGroup += aGroups[nI][4]
				Else
					cGroup += aGroups[nI][4] + ","
				EndIf
			Next
		EndIf
	EndIf	
EndIf
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SMCTILogOut  		ºAutor  ³Michel W. Moscaº Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia o comando de Logout do operador no CTI.                  º±±
±±º          ³                                                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMCTILogOut(ExpC1, ExpC2)			                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do usuario no DAC.                   		      ³±±
±±³          ³ ExpC2 = Codigo do DAC.                            			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SMCTILogOut(cPIN, cGroup)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desloga o usuario na CTI - Se o resultado for positivo muda o FLAG da variavel lABRECTI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If oAgtSmartCTI:Logoff(Trim(cPIN), Trim(cMultiGrp)) == SMARTCTI_SUCCESS 
	lAbreCTI := .F.
Endif	                   
Return(.T.)               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SMSetShowUsrMsg	ºAutor  ³Michel W. Moscaº Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Indica se deve ser exibido para o usuario a resposta do comandoº±±
±±º          ³                                                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMSetShowUsrMsg(ExpL1)  				                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Habilita a exibicao de msgs. para o usuario 		      ³±±
±±³          ³                                                   			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SMSetShowUsrMsg(lValue)
	lShowMessage := lValue
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SMGetShowUsrMsg	ºAutor  ³Michel W. Moscaº Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se deve ser exibido para o usuario a resposta do 		 º±±
±±º          ³comando.                                                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMGetShowUsrMsg()       				                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                      	      ³±±
±±³          ³                                                   			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SMGetShowUsrMsg()
Return lShowMessage 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SMSetCallInHold	ºAutor  ³Michel W. Moscaº Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atribui na variavel lCallInHold. Indicando que há uma chamada  |±±
±±º          ³em espera.                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMSetCallInHold(ExpL1)  				                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Indica se ha chmada em espera.              		      ³±±
±±³          ³                                                   			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SMSetCallInHold(lValue)
	lCallInHold := lValue
Return Nil          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SMSetInCall       ºAutor  ³Michel W. Moscaº Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atribui na variavel lInCall. Indicando que há uma chamada  	 |±±
±±º          ³ativa no ramal.                                                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMSetInCall(ExpL1) 	 				                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Indica se ha chmada ativa no ramal.         		      ³±±
±±³          ³                                                   			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SMSetInCall(lValue, cCallID, lCleared)

Local nPos := 0

Default cCallID 	:= ""
Default lCleared	:= .F.	

nPos := aScan( aIDCham,cCallID)

If !Empty(cCallID) .AND. nPos == 0 .AND. lValue 
	aAdd(aIDCham,cCallID)
ElseIf lCleared
	aIDCham := {}
EndIf

lInCall := lValue
Return Nil          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SMSystemStatus    ºAutor  ³Michel W. Moscaº Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a conexão com o Middleware.                        	 |±±
±±º          ³                                                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SMSystemStatus(void)  				                          ³±±
±±³          ³                                            	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                     		      ³±±
±±³          ³                                                   			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8	                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SMSystemStatus()
Local lRet := .F.
	       
ProcessMessages()

If(oAgtSmartCTI:SystemStatus() == SMARTCTI_SUCCESS)
	lRet := .T.
Else
	MsgInfo(STR0164,"")	//"Conexão perdida com o Middleware. O receptivo será encerrado."
EndIf            
	
ProcessMessages()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |GetRemoteExeName  ºAutor  ³Michel W. Moscaº Data ³  17/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o nome do executavel Protheus Remote baseando-se no    º±±
±±º          ³nome do arquivo .ini, independente da versao do Protheus.      º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±³Sintaxe   ³ GetRemoteExeName(void)  				                         º±±
±±³          ³                                            	                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±³Parametros³                                                     		     º±±
±±³          ³                                                   			 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetRemoteExeName()
Local cExeName := GETREMOTEININAME() 	// Armazena o nome do executavel
Local nIndex := 0					    // Armazena o resultado da buscar por determinado caracter


//Extrai o nome do arquivo .ini
While .T.
	nIndex := At("\", cExeName)
	If nIndex > 0 
		cExeName := SubStr(cExeName, nIndex+1, Len(cExeName))	
	Else
		Exit
	EndIf
End      
//Extrai o ".ini"
nIndex := At(".ini", cExeName)              
If nIndex > 0 
	cExeName := SubStr(cExeName, 1, nIndex-1)		
EndIf
cExeName += ".exe"

Return cExeName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³SGTeleService   ºAutor³ Vendas Cliente     º Data ³  27/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametos ³ExpC1: Codigo do contato                                 		  º±±
±±º          ³ExpC2: Entidade (alias)                               		  º±±
±±º          ³ExpC3: Chave primaria da entidade          			          º±±
±±º          ³                                      	                      º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGTeleService(cCodCont,	cEntidade,	cChave, oHashDic, lIncNew)
Local oObj		:= TeleServiceUserDialog():New()								// Objeto interface de atendimento do TeleAtendimento
Local nAuxOpc	:= 3 		//Opção a ser exibida na tela - Inclusao
Local lCCT		:= SuperGetMV("MV_TMKCCT",,.T.)

Private aHeader		:= {}		//Array contendo o cabecalho dos campos
Private aCols 		:= {}		//Array com os itens do atendimento incluidos na MsGetDados   

oObj:service := TeleServicing():New() 
oObj:service:load( oObj:GetModel() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia o atendimento |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:service:id <> ""
	oObj:lReadOnly := .F. 
	oObj:SetInfo(cCodCont, cEntidade, cChave)
	oObj:SetHashDic(oHashDic)
	oObj:SetCCT(lCCT)
	If oObj:showDialog("", nAuxOpc)	 
		oObj:service:tableStructureInfo:save()
		oObj:service:whenRecorded:execute({aHeader,aCols,nAuxOpc})	
	EndIf
	lIncNew := oObj:lWereIncluded
EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkUpdReady      ºAutor³ Vendas CRM         º Data ³  02/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza tela indicando Status de Disponível                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkUpdReady()
	lPause := .F.
	oBtnPausa:SetText(STR0181)		//Pausa
	oSayMsg:SetText(SGGetAgTxt())	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkUpdNotReady   ºAutor³ Vendas CRM         º Data ³  02/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza tela indicando Status de Pausa                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkUpdNotReady()
	lPause := .T.
	oBtnPausa:SetText(STR0120)				//Disponível
	oSayMsg:SetText(SGGetAgTxt(STR0182))    //Você está em PAUSA	
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³SGVerifGrpAtendDACºAutor³ Vendas CRM         º Data ³  12/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se algum grupo de atendimento não tem DAC               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGVerifGrpAtendDAC()
Local lRet := .F.
	If AliasIndic("AG9")
		dbSelectArea("AG9")//Tabela de Amarração Operador X Grupos de Atendimento
		DbSetOrder(1)
		DbSeek(xFilial("AG9") + AllTrim(TkOperador()))
		While !AG9->(EOF()) .AND. AG9->AG9_FILIAL==xFilial("AG9") .AND. AllTrim(AG9->AG9_CODSU7)==AllTrim(TkOperador())
			DbSelectArea("AGJ")
			DbSetOrder(2) //AGJ_FILIAL + AGJ_SU0COD
			DbSeek(xFilial("AGJ") + AG9->AG9_CODSU0)
			//Verificando se há amarração entre grupo de Atendimento e Grupo ACD par amanter compatibilidade.
			If AGJ->(EOF())
				lRet := .T.
			EndIf
			AG9->(DbSkip())
		End
	EndIf
	
	If lRet
		/*
		"O sistema está configurado para multiplos grupos DACs por grupo de Atendimento!" STR0184
		"Porém um ou mais grupos de Atendimento não tem grupo DAC associado!" STR0185
		"Contate o administrador do sistema para verificar o cadastro dos Grupos DAC no Grupo de Atendimento!" STR0186
		*/
		msgalert(STR0184 + chr(10) + chr(13) + STR0185 + chr(10) + chr(13) + chr(10) + chr(13) + STR0186)
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³SGNewScreen ºAutor  ³Vendas & CRM          º Data ³  14/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe uma tela para selecao dos grupos DAC do operador para    º±±
±±           ³ que ele selecione quais deseja se logar e só depois o Protheus º±±
±±           ³ envia apenas UM comando com todos os grupos para Logon/Logoff  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGNewScreen()
Local nQtdGroup := 0					// Quantidade de Grupos de Atendimento do Operador
Local lMACD 	:= .F.					// Indica ase usa multiplos grupos DAC por grupo de atendimento
Local aGAtend	:= {} 					// Lista dos Grupos de Atendimento
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )		// Imagem checado
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )    // Imagem sem "check"
Local nI 		:= 0					// Controle de loop
Local aGrpLogged := {}					// Array com os Grupos selecionados pelo Operador para efetuar o Logon.
Local oButConf
Local oCheckGroup
Local lCheckGroup := .F.
Local oPanelBot
Local oPanelGroup
Local oPanelTop
Local oSayMsg
Static oDlgGroup
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
lMACD := SuperGetMV("MV_TMKMACD",,.F.)  // Indica se um grupo de atendimento pode contar mais de um grupo DAC (ACD)

	If AliasIndic("AG9")
		dbSelectArea("AG9")//Tabela de Amarração Operador X Grupos de Atendimento
		DbSetOrder(1)
		DbSeek(xFilial("AG9") + AllTrim(TkOperador()))
		While !AG9->(EOF()) .AND. AG9->AG9_FILIAL==xFilial("AG9") .AND. AllTrim(AG9->AG9_CODSU7)==AllTrim(TkOperador())
		    If !lMACD //Só existe um Grupo DAC por Grupo de ATendimento
		    	MontaGrupoSU0(@aGAtend, @nQtdGroup, AG9->AG9_CODSU0)
			Else //Podem existir vários Grupos DAC por Grupo de Atendimento
				DbSelectArea("AGJ")
				DbSetOrder(2) //AGJ_FILIAL + AGJ_SU0COD
				DbSeek(xFilial("AGJ") + AG9->AG9_CODSU0)
				//Verificando se há amarração entre grupo de Atendimento e Grupo ACD par amanter compatibilidade.
				If AGJ->(EOF())
					MontaGrupoSU0(@aGAtend, @nQtdGroup, AG9->AG9_CODSU0)
				Else
					While !AGJ->(EOF()) .AND. AGJ_FILIAL==xFilial("AGJ") .AND. AGJ->AGJ_SU0COD==AG9->AG9_CODSU0 //Não precisa ver se tem no. do grupo ACD pois é obrigatório
						DbSelectArea("AGI")
						DbSetOrder(1) // AGI_FILIAL + AGI_COD
						DbSeek(xFilial("AGI") + AGJ->AGJ_GICOD)
						If AllTrim(STR(AGI->AGI_NUM)) == AllTrim(TkPosto(TkOperador(),"U0_ACDGRP"))
							If aScan(aGatend,  { |x| AllTrim(x[4]) == AllTrim(STR(AGI->AGI_NUM)) } ) = 0	//Verifica se ja existe o Grupo DAC na lista
								AAdd(aGAtend,{.T., AGI->AGI_COD, AGI->AGI_DACNAM, cValToChar(AGI->AGI_Num) })
								nQtdGroup += 1
							EndIf
						Else
							If aScan(aGatend,  { |x| AllTrim(x[4]) == AllTrim(STR(AGI->AGI_NUM)) } ) = 0	//Verifica se ja existe o Grupo DAC na lista
								AAdd(aGAtend,{.F., AGI->AGI_COD, AGI->AGI_DACNAM, cValToChar(AGI->AGI_Num) })
								nQtdGroup += 1
							EndIf
						EndIF
						AGJ->(DbSkip())
					End
				EndIf
			EndIf
			AG9->(DbSkip())
		End
	EndIf

	If nQtdGroup <= 1
		DEFINE MSDIALOG oDlgGroup FROM 23,180 TO 200,490 TITLE STR0192 PIXEL STYLE DS_MODALFRAME//"GRUPOS DACs"
	Else
		DEFINE MSDIALOG oDlgGroup FROM 00,00 TO 110+(Min(nQtdGroup,10))*20,310 TITLE STR0192 PIXEL STYLE DS_MODALFRAME//Exibe em uma altura de no máximo 10 Grupos // "GRUPOS DACs"
	EndIf
	oDlgGroup:lEscClose := .F.

    @ 155, 000 MSPANEL oPanelBot SIZE 250, 020 OF oDlgGroup COLORS 0, 16777215 RAISED
    @ 003, 050 BUTTON oButConf PROMPT STR0188 SIZE 059, 013 OF oPanelBot ; // "Confirmar"
    		ACTION (aGrpLogged := SGLoadGroupToLogon(aGAtend),If((Len(aGrpLogged) > 0),(aGAtend := aGrpLogged,oDlgGroup:End()),Alert(STR0191))) PIXEL //"Não foram selecionados grupos DAC"
    @ 016, 000 MSPANEL oPanelGroup SIZE 250, 139 OF oDlgGroup COLORS 0, 16777215 RAISED
    @ 001, 001 CHECKBOX oCheckGroup VAR lCheckGroup SIZE 070, 023 OF oPanelGroup COLORS 0, 16777215 PIXEL
    @ 000, 000 MSPANEL oPanelTop SIZE 250, 016 OF oDlgGroup COLORS 0, 16777215 RAISED
    @ 004, 004 SAY oSayMsg PROMPT STR0190 SIZE 241, 010 OF oPanelTop COLORS 0, 16777215 PIXEL //"Selecione os Grupos DAC que deseja se logar."

    oPanelBot:Align := CONTROL_ALIGN_BOTTOM
    oPanelTop:Align := CONTROL_ALIGN_TOP
    oPanelGroup:Align := CONTROL_ALIGN_ALLCLIENT

	oLbx	:= TWBrowse():New( 0, 0, 0, 0,;
      /*[\{|| \{<Flds> \} \}]*/, ;
      {" ",STR0158,STR0189}/*[\{<aHeaders>\}]*/, /*[\{<aColSizes>\}]*/, ; //"Código", "Grupo de Atendimento"
      oPanelGroup, /*<(cField)>*/, /*<uValue1>*/, /*<uValue2>*/,;
      /*[<{uChange}>]*/,;
      {|nRow,nCol,nFlags| /*If(TkVerifCanLogoff()*/,(aGAtend[oLbx:nAt,1] := !aGAtend[oLbx:nAt,1]/*, SndCom(aGAtend[oLbx:nAt,1],aGAtend[oLbx:nAt,4])*/,oLbx:Refresh()/*)*/,NIL)},; //Duplo Clique
      /*[\{|nRow,nCol,nFlags|<uRClick>\}]*/,;
      /*<oFont>*/, /*<oCursor>*/, /*<nClrFore>*/, /*<nClrBack>*/, /*<cMsg>*/,;
      /*<.update.>*/, /*<cAlias>*/, .T. ) 
 	oLbx:Align := CONTROL_ALIGN_ALLCLIENT
 	
 	For nI = 1 to Len(aGAtend)
 		aGAtend[nI][1] := .F.
 	Next
 	
    oLbx:SetArray( aGAtend )
	If len(aGAtend) > 0
		oLbx:bLine := {|| {Iif(aGAtend[oLbx:nAt,1],oOk,oNo),;
    	               aGAtend[oLbx:nAt,2],;
        	           aGAtend[oLbx:nAt,3]}}
	EndIf
  ACTIVATE MSDIALOG oDlgGroup CENTERED
  
  cMultiGrp := ""
  For nI = 1 to Len(aGrpLogged)
  	If Ni = Len(aGrpLogged)
  		cMultiGrp += aGrpLogged[nI][4]
  	Else
  		cMultiGrp += aGrpLogged[nI][4] + ","
  	EndIf
  Next
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return aGrpLogged

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³SGLoadGroupToLogon  ºAutor  ³Vendas & CRM          º Data ³  14/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna um array somente com os Grupos selecionados pelo operador na   º±±
±±           ³ funcao SGNewScreen                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGLoadGroupToLogon(aGAtend)
	Local aRet := {}	// Array contendo somente os Grupo sselecionados pelo operador para efetuar o Logon
	Local nI := 0		// Contador do for
	For nI = 1 To Len(aGAtend)
		If(aGAtend[nI][1]) //Verifica se o checkbox do grupo está selecionado
			AADD(aRet,aGAtend[nI])
		EndIf
	Next
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³SGGetAgTxt		  ºAutor  ³Vendas & CRM          º Data ³  06/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o texto padrão para o Agente/Grupo Logado no DAC               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SGDialog                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                           
*/                                                                                                                                  
Function SGGetAgTxt(cStatus)                                                                                                        

Local cTextHtml                                                                                                                 
Static cTipoCTI
Static cCodGrupo
Static cNomGrupo
Static cCodOper
Static cNomOper

cTipoCTI	:= Iif(!Empty(cTipoCTI)	,cTipoCTI	,TkPosto(TkOperador(),"U0_TIPOCTI"))
cCodGrupo	:= Iif(!Empty(cCodGrupo),cCodGrupo	,AllTrim(Posicione("SU7", 1, xFilial("SU7") + TkOperador(), "U7_POSTO")))
cNomGrupo	:= Iif(!Empty(cNomGrupo),cNomGrupo	,TkPosto(TkOperador(),"U0_NOME"))
cCodOper	:= Iif(!Empty(cCodOper)	,cCodOper	,TkOperador())
cNomOper	:= Iif(!Empty(cNomOper)	,cNomOper	,Left(AllTrim(Posicione("SU7", 1, xFilial("SU7") + TkOperador(), "U7_NOME")),15))
            
Default cStatus := STR0057+IIf(cTipoCTI == USE_SMARTCTI, Iif(ValType(oAgtSmartCTI)=="O",oAgtSmartCTI:cDevice,""),SgRetRamal()) //"Aguardando ligacoes no ramal: XXXX. 

// Monta o Texto no formato HTML
cTextHtml := '<table width="100%" cellpadding="0">'
cTextHtml += '<tr><td colspan="2" align="center"><font color="darkred"><b>'
cTextHtml += cStatus 
cTextHtml += '</b></font></td></tr>' 
	
cTextHtml += '<tr><td align="right"><b>'+STR0172+' </b></td><td align="left">' // "Grupo de Atendimento:"
cTextHtml += cCodGrupo + " - " + cNomGrupo +'</td></tr>'
cTextHtml += '<tr><td align="right"><b>'+STR0173+' </b></td><td align="left">' //"Operador:"
cTextHtml += cCodOper + " - " + cNomOper+'</td></tr>'

cTextHtml += '</table>'
	
Return cTextHtml
                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³getObjCTI  		  ºAutor  ³Vendas & CRM          º Data ³  22/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o objeto oAgtSmartCTI                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TmkaReceptiveEvt                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                           
*/                   
Function getObjCTI()
Return oAgtSmartCTI

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³SgCodePar  		  ºAutor  ³Vendas & CRM          º Data ³  18/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codifica/Decodifica o Parametro enviado via WinExec                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaCall                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                           
*/   
Function SgCodePar(cParam,nTipo)
Local cRet 	:= ""
Local aParam:= {}
Local nX	:= 1

If nTipo == 0
	For nX := 1 To Len(cParam)	
		cRet += cValToChar(Asc(Substr(cParam,nX,1)))+"|"	
	Next nX
Else
	aParam := StrTokArr(cParam,"|")
	For nX := 1 To Len(aParam)
		cRet += Chr(Val(aParam[nX]))
	Next nX
EndIf

Return cRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SGABRECTI º Autor ³ Totvs           º Data ³  19/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que sera executada pelo menu Call Center > Atualiza º±±
±±º          ³ coes > Acessar CTI                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SSIM                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SGABRECTI()

PswOrder(1)
If PswSeek(__cUserID)
	If PswRet(1)[1][19]		
		oAgtSmartCTI := NIL
        SigaCall(.F.)
	Else
		Alert(STR0198)
	Endif
Else
	Alert(STR0082)  //"Usuário não encontrado."
Endif
Return         


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SGPergunta  º Autor ³ Totvs         º Data ³  19/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do LISTENER - com espera de retorno              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet deve ser 'Nil' caso não queira que seja feito valida_ º±±
±±º          ³ cao Listner e alteracao dos diretorios de TROCA - TX e RX. º±±
±±º          ³ Nil equivale como o P.E não existisse para o a função que oº±±
±±º          ³ chama (SigaCall do fonte SIGXTEL)                          º±±                 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SGPergunta()

Local	lRet		:=  .T.	
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" INICIO"),)
	If 	Aviso(STR0194,STR0197 ,{STR0203,STR0204},1)=2	// "Protheus - Call Center","Deseja habilitar o recebimento de ligações telefônicas?","Sim","Não"
        lRet   := .F.
	Endif
Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(" FIM"),)
Return lRet       


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SGPesqCliº Autor ³ Totvs             º Data ³  13/03/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chama a tela para pesquisar uma entidande quando ela não   º±±
±±º 		 ³ ela não vier identificada automaticamente e carrega seus   º±± 
±±º 		 ³ dados 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ SGPesqCli(ExpC1, ExpC2, ExpC3, ExpC4,ExpC5, ExpC6, ExpC7,   ³±±
±±³          ³          ExpC8, ExpC9, ExpO10)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do contato		    	                  ³±±
±±³          ³ ExpC2 = Nome do do contato.		                          ³±±
±±³          ³ ExpC3 = E-mail do contato				                  ³±±
±±³          ³ ExpC4 = Codigo do Cliente					              ³±±
±±³          ³ ExpC5 = Nome do Cliente						              ³±±
±±³          ³ ExpC6 = Telefone do Cliente					              ³±±
±±³          ³ ExpC7 = E-mail do Cliente				                  ³±±
±±³          ³ ExpC8 = Home page do Cliente					              ³±±
±±³          ³ ExpC9 = Alias da entidade					              ³±±
±±³          ³ ExpO10 = Tela								              ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SGPesqCli(cCodCont,cNomeCont,cEmailCont,cCodCli,cNomeCli,cTelCli,cEmailCli,cHPageCli,cEntAlias,oDlg)

PRIVATE aRotina := {} 

ALTERA :=.T.  
   
//Chama a tela de pesquisa	
TkSelEnt(.T.)
   
dbSelectArea("SU5")
SU5->(dbSetOrder(1))


// DADOS DO CONTATO
cCodCont	:=	SU5->U5_CODCONT    
cNomeCont	:=	fDesc("SU5",cCodCont,"U5_CONTAT") 
cEmailCont	:=	fDesc("SU5",cCodCont,"U5_EMAIL")
                   
dbSelectArea ("AC8")
AC8->(dbSetOrder(1))
dbSeek(xFilial("AC8")+cCodCont)
//DADOS DO CLIENTE
cCodCli   := AC8->AC8_CODENT //Codigo + Loja
cNomeCli  := Posicione("SA1",1,xFilial("SA1")+ALLTRIM(cCodCli),"A1_NOME")//SA1->A1_NOME
cTelCli   := Posicione("SA1",1,xFilial("SA1")+ALLTRIM(cCodCli),"A1_TEL") //SA1->A1_TEL
cEmailCli := Posicione("SA1",1,xFilial("SA1")+ALLTRIM(cCodCli),"A1_EMAIL")// SA1->A1_EMAIL
cHPageCli := Posicione("SA1",1,xFilial("SA1")+ALLTRIM(cCodCli),"A1_HPAGE")//SA1->A1_HPAGE
cEntAlias := AC8->AC8_ENTIDA

oDlg:Refresh()	

Return()     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SGPRODAC º Autor ³ Totvs             º Data ³  19/03/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega os Grupos DAC's logados no tList   				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ SGPRODAC(ExpC1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Caracter com todos os Grupos Dac's logado          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                                                                                                                       
Static Function SGPRODAC(cMultiGrp)

Local aRet := {}	// Array de retorno
Local nPos := 0		// Variavel do For
Local cString:= ""	// Variavel de Backup no numero do grupo DAC 

aRet:=StrTokArr( @cMultiGrp, ",")   

For nPos:= 1 To Len(aRet) 
	dbSelectarea("AGI")
	dbSetOrder(3)
	If dbSeek(xFilial("AGI")+aRet[nPos])  
		cString:=aRet[nPos] 
		aRet[nPos] := PADR( AllTrim(AGI->AGI_COD), (tamsx3("AGI_COD")[1]))+"        "+cString+"            "+PADR( AllTrim(AGI->AGI_DACNAM), (tamsx3("AGI_DACNAM")[1]))
	EndIf

Next nPos  

Return(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SGCheckAgState  º Autor ³ CRM       º Data ³  04/04/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para verificar o Estado do Agente		              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet será Falso quando a conexão com o LinkCTI não estiver º±±
±±º          ³ Ativa.														    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SGCheckAgState()
Local lRet 			:= .T.	// Retorno da Função			
Local AgentState		:= 0	// Estado do agente logado no ramal no Grupo

//Executa o Comando
AgentState := (oAgtSmartCTI:AgentState(oAgtSmartCTI:cDevice))

Do Case
	Case AgentState == 30
		TkUpdNotReady()
		//Conout("ESTADO_AGENTE_PAUSA")
	Case AgentState == SMARTCTI_DISCONNECTEDLINK		//DISCONNECTEDLINK = 16 
		lRet := .F.
		Conout("DISCONNECTEDLINK")
	//Case AgentState == 29
		//Conout("ESTADO_AGENTE_OCUPADO")
	Case AgentState == 27
		TkUpdNotReady()
		//Conout("ESTADO_AGENTE_POS_ATENDIMENTO")
	Case AgentState == 28
		TkUpdReady()
		//Conout("ESTADO_AGENTE_LIVRE ")
	//Case AgentState == 26
		//Conout("ESTADO_AGENTE_LOGIN")
	//Case AgentState == 25
		//Conout("ESTADO_AGENTE_LOGOUT")			
End Case

Return ( lRet )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
