#INCLUDE "TMKA273A.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

// Possibilidades de uso do parametro MV_AUTOCOM
#DEFINE DLL_SIGALOJA			0			// Usa somente perifericos da SIGALOJA.DLL
#DEFINE DLL_SIGALOJA_AUTOCOM	1			// Usa perifericos da SIGALOJA.DLL e da AUTOCOM
#DEFINE DLL_AUTOCOM				2			// Usa somente perifericos da AUTOCOM

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmkAbreTef   ³ Autor ³Marcelo Kotaki         ³ Data ³19/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se utiliza TEF e inicializa  suas variaveis       	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS - SX3                                         	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rafael Q. ³17/07/03³811   ³- Implementada validacao de abertura do TEF    ³±±
±±³Cleber M. ³07/11/05³811   ³- BOPS 88251: Multiplas transacoes TEF no Te-  ³±±
±±³          ³        ³      ³levendas usando a DLL Clisitef.                ³±±
±±³Cleber M. ³31/01/06³811   ³- BOPS 92600: Tratamento para nao abrir TEF    ³±±
±±³          ³        ³      ³quando estiver em LINUX.                       ³±±
±±³Fernando  ³16/11/06³811   ³-BOPS 111375: verificar se o usuario tem um 	 ³±±
±±³          ³        ³      ³operador e esse e um vendedor                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmk273AbreTef()

Local aArea	 	 := GetArea()		//Salva a area atual	
Local cCodOper   := ""				//Codigo do Operador	
Local lRet     	 := .T.             //Retorno da funcao - Caso o operador nao use TEF sempre retorna .T.
Local nMVAUTOCOM					//conteudo do parametro MV_AUTOCOM
Local cCodUsr	 := ""				// Codigo do usuario
Local cStationOp := ""
Default cTipTEF  := ""				//Tipo de tef que sera utilizado (DEDICADO/DISCADO)
Default lUsaTEF  := .F.				//Flag que indica se o TEF esta sendo utilizado mas, nao quer dizer que esta ATIVO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No SIGALOJA a variavel de controle de abertura do TEF  e publica porque em MDI o usuario pode abrir varias³ 
//³ rotinas simultaneamente e nesse a transacao de abertura so pode ser feita uma unica vez                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Public lTTEFAberto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel utilizada para a nova DLL Fiscal e para uso do TEF CliSiTEF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Public oAutocom

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao para o novo objeto de TEF  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Public oTEF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel declarada na inicializacao do sistema que controla o uso do TEF (SiTef)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lUsaTef
	cCodUsr := RetCodUsr()
	DbSelectArea("SU7")
    DbSetOrder(4)
    If DbSeek( xFilial("SU7") + cCodUsr )
		
		cCodOper := SU7->U7_COD
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual a configuracao de estacao esta sendo utilizada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SU7->(ColumnPos("U7_ESTACAO")) > 0 .AND. !Empty(SU7->U7_ESTACAO)
			cStationOp := TkPosto(cCodOper,"U7_ESTACAO")	//Pega o codigo da ESTACAO do OPERADOR
		Else
			cStationOp := TkPosto(cCodOper,"U0_ESTACAO") //Pega o codigo da ESTACAO do GRUPO DE ATENDIMENTO
		EndIf 
		
		If !Empty( cStationOp ) 
			cEstacao := cStationOp
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a estacao utiliza o TEF realiza a abertura do TEF         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cStationOp)  //Só faz o processo de TEF se operador estiver estacao.
		
			cTipTef := LjGetStation("TIPTEF")    // Retorna a empresa de TEF escolhida - 1-SITEF ou 2-E-FINANCIAL
			cEmpTef := LjGetStation("TIPOATE")   // Retorna a empresa de TEF escolhida - 1-SITEF ou 2-E-FINANCIAL

			If (cTipTef <> "1") .AND. (cTipTef <> "2")  //1 e 2 = Nao utiliza TEF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se esta usando Remote em Linux e ³
				//³ avisa que nao esta homologado             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If GetRemoteType() == 2
					RestArea(aArea)
					Final(STR0052)	//"O módulo Call Center não está homologado para Linux com TEF"
				Endif
				
				If cTipTEF == "6" //TEF_CLISITEF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa o obj. oAutocom para uso com a CLISITEF  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ValType( oAutocom ) <> "O"
						nMVAUTOCOM := ChkAutocom()								// Verifica o parametro MV_AUTOCOM
						If nMVAUTOCOM == DLL_SIGALOJA_AUTOCOM .OR. nMVAUTOCOM == DLL_AUTOCOM
							oAutocom := Autocom():New()
						EndIf
					EndIf
					
					lUsaTEF := .T.
					If SLG->(ColumnPos("LG_IPSITEF")) == 0
						// "Para utilizar o TEF na modalidade CliSiTEF, é necessário configurar corretamente o " "Atenção"
						MsgStop(STR0051 + "LG_IPSITEF.", STR0050)
						lUsaTEF := .F.
					EndIf
					If SL4->(ColumnPos("L4_FORMAID")) == 0
						// "Para utilizar o TEF na modalidade CliSiTEF, é necessário configurar corretamente o " "Atenção"
						MsgStop(STR0051 + "L4_FORMAID.", STR0050)
						lUsaTEF := .F.
					EndIf
					If !lUsaTEF .OR. ChkAutocom() == DLL_SIGALOJA	// Verifica o parametro MV_AUTOCOM
						// "Para utilizar o TEF na modalidade CliSiTEF, é necessário configurar corretamente o " "Atenção"
						MsgStop(STR0051 + "MV_AUTOCOM.", STR0050)
						lUsaTEF := .F.
					Else
						oTEF 	:= LJTEFAbre()	    //Prepara o objeto TEF e carrega as variáveis necessárias para a utilização do TEF
						lUsaTef := oTef:lAtivo		//Indica se a abertura de terminal foi processada com sucesso
						lRet 	:= lUsaTef
					EndIf							
				
				Else
				
					If cEmpTeF == "1"				// SITEF
						lUsaTEF := .T.
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o TEF nao estiver aberto executa o comando de abertura³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lRet := Loja010T( "A" )
					Endif
					
				Endif
				
			Endif
		Endif
	Endif
Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TKOPERVEND³ Autor ³ Marcelo Kotaki        ³ Data ³ 21/11/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verfica se o NOME DO USUARIO esta no cadastro de vendedor  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TeleVendas                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	   	³±±
±±³          ³        ³      ³                                             	³±±
±±³Fernando  ³16/11/06³811   ³-BOPS 111375: verificar se o usuario tem um 	³±±
±±³          ³        ³      ³operador e esse um vendedor atrelado, ou se o ³±±
±±³          ³        ³      ³usuario atual tem um vendedor e um operador 	³±±
±±³          ³        ³      ³atrelado.										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273OperVend()

Local aArea		:= GetArea()			// Area anterior
Local lCheca    := GetMv("MV_TMKCHK")	//Parametro para validar a existencia no SA3 do nome do usuario	
Local lRet		:= .T.					//Retorno da funcao	
Local cCodUsr	:= ""					// Codigo do usuario

If lCheca
	cCodUsr := RetCodUsr()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pelo operador do usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("SU7")
    DbSetOrder(4)
    If DbSeek( xFilial("SU7") + cCodUsr )
		DbSelectArea("SA3")
		DbSetOrder(1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura por um vendedor atrelado ao operador.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If !DbSeek( xFilial("SA3") + SU7->U7_CODVEN )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o usuario tem algum vendedor atrelado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSetOrder(7)
			If !DbSeek( xFilial("SA3") + cCodUsr )
				lRet := .F.
			EndIf
		EndIf		
	EndIf    
	RestArea(aArea)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271ValOper   ³ Autor ³Marcelo Kotaki         ³ Data ³29/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Configura o rodape da tela de acordo com o Posto de venda do     ³±±
±±³          ³operador selecionado                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Nome do campo do SUA onde esta o codigo do operador      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS - SX3                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  	   ³±±
±±³          ³        ³      ³                                            	   ³±±
±±³          ³        ³      ³                                            	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273ValOper(cCampo)

Local cDesconto := CriaVar("U0_DESCONT",.F.)		//Opcao de "desconto" do Posto de Venda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver utilizando a rotina de entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Habilita/Desabilita o campo de desconto no Total, dependendo do posto de Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (TkGetTipoAte() == "2") .OR. (TkGetTipoAte() == "4") //Televendas ou Ambos

		cDesconto := TkPosto(M->&(cCampo),"U0_DESCONT")		//Opcao de "desconto" do Posto de Venda
	
		If (AllTrim(cDesconto) == "2") .OR. (AllTrim(cDesconto) == "3")
			aObj[DESCONTO]:Enable()
		Else
			aObj[DESCONTO]:Disable()
		Endif
	Endif
	
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK271Vendedor ³ Autor ³Fabio Rogerio Pereira³ Data ³05/04/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida‡„o do vendedor informado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas - SX3                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	    ³±±
±±³          ³        ³      ³                                              ³±±
±±³          ³        ³      ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273Vendedor()

Local aArea	:= GetArea()			//Salva a area atual
Local cVend := &(ReadVar())			//Le o conteudo do campo "vendedor" 
Local lRet  := .T.					//Retorno da funcao

If !Empty(cVend)
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek(xFilial("SA3") + M->UA_VEND)
		M->UA_DESCVEN:= SA3->A3_NOME
		If TkAtuComis() .And. Empty(M->UA_COMIS)
			M->UA_COMIS := SA3->A3_COMIS
		EndIf
	Else                                 
		M->UA_VEND		:= ""
		M->UA_DESCVEN	:= ""	
		lRet := .F.		
	Endif	
Endif

RestArea(aArea)
Return(lRet)
     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk273HTlv ³ Autor ³Marcelo Kotaki         ³ Data ³ 08/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Hist¢rico das ligacoes atendidas pelo Televendas           ³±±
±±³          ³ OBSERVACAO: Essa consulta tambem e usada na Agenda do      ³±±
±±³          ³ Operador porem sem o acesso ao botao de OK                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³01/06/04³811   ³- Passagem de parametro na funcao Tk273OrcPed±±
±±³          ³        ³      ³para correto posicionamento na tabela SUA.  ³±±
±±³Tatiana C.³23/02/07³811   ³- Retirado o recalculo de impostos que anula³±±
±±³          ³        ³      ³o valor do frete na visualizacao do pedido  ³±±
±±³          ³        ³      ³no historico de atendimento.                ³±±
±±³Conrado Q.³30/03/07³811   ³- Bops: 120898: Salva a area atual e restau ³±±
±±³          ³        ³      ³ ra no retorno da função.                   ³±±
±±³Conrado Q.³02/04/07³811   ³- Bops: 122095: Só utilizada aPosicoes      ³±±
±±³          ³        ³      ³ depois de inicializada.                    ³±±
±±³Michel M. ³18/04/07³9.12  ³-Bops: 124386 - Incluido o uso da funcao    ³±±
±±³          ³        ³      ³Tk273Refresh() para atualizar as informacoes³±±
±±³          ³        ³      ³no rodape apos escolher o historico.        ³±±
±±³Conrado Q.³14/05/07³10    ³-Bops: 124959 - Alterada a ordem de execução³±±
±±³          ³        ³      ³das funções Tk273RodImposto e MaColsToFis   ³±±
±±³          ³        ³      ³para o correto cálculo, além da atualização ³±±
±±³          ³        ³      ³do aValores através do bloco bRefresh.      ³±±
±±³Norbert W.³27/07/07³10    ³- Bops 128000 - Alterado o recalculo dos    ³±±
±±³          ³        ³      ³itens do atendimento, pois os valores do    ³±±
±±³          ³        ³      ³desconto do Suframa estavam incorretos.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Tk273HTlv( nOpc			,lHabilita		,oFolderTlv	,oEnchTlv,;
					cCodPagto		,cDescPagto		,cCodTransp	,cTransp,;
					cCob			,cEnt			,cCidadeC	,cCepC,;
					cUfC			,cBairroE		,cBairroC	,cCidadeE,;
					cCepE			,cUfE			,nLiquido	,nTxJuros,;
					nTxDescon		,nVlJur			,aParcelas	,nEntrada,;
					nFinanciado		,nNumParcelas	,nValorCC	,aColsTlv,;
					cCodAnt			,cCliAnt, cLock)
								
Local lTMKVHO   := ExistBlock("TMKVHO")						// P.E. para TLV
Local oMonoAs	:= TFont():New( "Courier New", 6, 0 )		// Fonte				
Local cCodPed	:= ""                                       // Codigo do atendimento
Local oDlgHist	:= Nil										// Tela do historico
Local oLbx		:= Nil										// Listbox com os registros do cabecalho	
Local oGetHist	:= Nil										// Getdados com os itens do atendimento
Local oObsMemo	:= Nil										// MEMO da observacao do atendimento
Local cObsMemo	:= ""										// Descricao do memo	
Local oCancMemo	:= Nil										// MEMO do cancelamento do atendimento
Local cCancMemo	:= ""                                       // Descricao do cancelamento
Local nEscolha 	:= 0										// Opcao OK ou CANCELA
Local aLigacoes := {}										// Array com o cabecalho do atendimento
Local lRet		:= .F.									 	// Retorno da funcao
Local l380 	 	:= .F.                                      // Flag que indica quem chamou essa rotina (pre-atendimento ou nao).
Local aFirst[1][Len(aHeader)+1]								// Array vazio
Local nAnt		:= n										// Salva o "n" atual
Local aColAnt  	:= aClone(aCols)							// Salva o acols atual
Local nLinha	:= 0										// Contador auxiliar do FOR/NEXT
Local nPQtd     := 0										// Posicao da Quantidade
Local nPVrUnit  := 0										// Posicao do Valor Unitario
Local nPVlrItem := 0										// Posicao do Valor do item 
Local aArea		:= GetArea()								// Salva a area atual
Local aHeaderBk := aClone(aHeader)
// Bitmaps das legendas do historico
Local oBmp1													// Atendimento 												
Local oBmp2 												// Orcamento
Local oBmp3 												// Aberto
Local oBmp4 												// Liberado
Local oBmp5 												// Faturado 
Local oBmp6 												// Cancelado
Local oBmp7 												// Em Carga (integracao com OMS)
Local nPTes := Ascan(aHeader, {|x|AllTrim(x[2]) == "UB_TES"})
Local nPValDesc	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UB_VALDESC"})	

Local lTK273Abr	:= ExistBlock("TK273ABR")					// Controle de ponto de entrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pergunte - TMKH02                                                             ³
//³MV_PAR01 - Da Emissao                                                         ³
//³MV_PAR02 - Ate a Emissão                                                      ³
//³MV_PAR03 - Do Operador                                                        ³
//³MV_PAR04 - Ate o Operador                                                     ³
//³MV_PAR05 - Operacao: (1-Todos 2-Atendimento 3-Orcamento 4-Faturamento		 ³
//³MV_PAR06 - Marketing:(1-Todos 2-Receptivo 3-Ativo 4-Fax 5-Representante)      ³
//³MV_PAR07 - Ocorrencia                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             
Local cPerg		:= "TMKH02"                             	// Pergunte exibida para filtrar os atendimentos exibidos no historico
Local aPDFields := {"UA_DESCCLI","A3_NOME","U5_CONTAT","A4_NOME","UA_ENDENT","UA_MUNE","UA_CEPE"}
Local aPDCols	:= {}

Default cLock := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a consulta foi executada direto da Agenda do Operador - Nesse caso o botao de OK nao sera exibido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Upper(FUNNAME()) == "TMKA380"
	l380 := .T.
Else
	l380 := .F.
Endif	
                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver utilizando a rotina de entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )                       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Força a execução da validação do campo em foco.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk273ExecCampo({||.T.})
EndIf

CursorWait()
aCols := aClone(aFirst)
n	  := Len(aCols)	

If !Pergunte(cPerg,.T.) 
	aCols := aClone(aColAnt)
	n 	  := nAnt  
	RestArea(aArea)
	Return(lRet)
Endif	

DbSelectArea("SUA")
DbSetOrder(7)		//FILIAL+CLIENTE+LOJA+STR(UA_DIASDAT,8,0)+STR(UA_HORADAT,8,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona todas a liga‡oes desse cliente indexando por ordem de liga‡ao decrescente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If ( TcSrvType()<>"AS/400" )
		cQuery := "SELECT * "
		cQuery += "FROM " + RetSqlName("SUA") + " SUA "
		cQuery += "WHERE "
		cQuery += 		"SUA.UA_FILIAL='"  + xFilial("SUA") + "' AND "
		cQuery += 		"SUA.UA_CLIENTE='" + M->UA_CLIENTE  + "' AND "
		cQuery += 		"SUA.UA_LOJA='"    + M->UA_LOJA     + "' AND "
		cQuery += 		"SUA.UA_PROSPEC='" + IIF(lProspect,'T','F') + "' AND "
		cQuery += 		"SUA.UA_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' AND "
		cQuery += 		"SUA.UA_OPERADO BETWEEN '" + MV_PAR03 + "' AND  '" + MV_PAR04 + "' AND "

		If MV_PAR05 <> 1 //Todas
			cQuery += 	"SUA.UA_OPER = '" + STR(MV_PAR05-1,1) + "' AND "
		Endif

        If MV_PAR06 <> 1 //Todos
           	cQuery += 	"SUA.UA_TMK = '" + STR(MV_PAR06-1,1) + "' AND "   
		Endif

        If !Empty(MV_PAR07)//Ocorrencia 
           	cQuery += 	"SUA.UA_CODLIG = '"+ MV_PAR07 + "' AND "   
		Endif

		cQuery += 		"SUA.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY " + SqlOrder(IndexKey())		
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMK',.T.,.T.)
		DbSelectArea("TMK")
		While (!Eof())
			
			AAdd(aLigacoes, {	TK273OrcPed(TMK->UA_DOC,TMK->UA_OPER,TMK->UA_CANC,TMK->UA_NUM),;// 01 - Status
								TMK->UA_NUM,;													// 02 - Atendimento
								DTOC(STOD(TMK->UA_EMISSAO)),;									// 03 - Data	
								Posicione("SA3",1,xFilial("SA3")+TMK->UA_VEND,"A3_NOME"),;		// 04 - Vendedor
								Tk273OperTlv(TMK->UA_OPER),;									// 05 - Operacao
								IIF(!Empty(TMK->UA_CODCONT),Posicione("SU5",1,xFilial("SU5")+TMK->UA_CODCONT,"U5_CONTAT"),TMK->UA_DESCNT),;	// 06 - Contato
								TMK->UA_NUMSC5,;												// 07 - Pedido
								Tk273Status(TMK->UA_STATUS),;									// 08 - Status
								Transform(TMK->UA_VLRLIQ,"@E 999,999,999.99"),;					// 09 - Valor
								Posicione("SUO",1,xFilial("SUO")+TMK->UA_CODCAMP,"UO_DESC"),;	// 10 - Campanha	
								TMK->UA_DOC+"/"+TMK->&(SerieNfId("SAU",3,"UA_SERIE")),;			// 11 - NF/SERIE
								DTOC(STOD(TMK->UA_EMISNF)),;									// 12 - Emissao
								Posicione("SE4",1,xFilial("SE4")+TMK->UA_CONDPG,"E4_DESCRI"),;	// 13 - Condicao de Pagto
								Posicione("SA4",1,xFilial("SA4")+TMK->UA_TRANSP,"A4_NOME"),;	// 14 - Transportadora	
								TMK->UA_ENDENT,;												// 15 - Endereco Entrega
								TMK->UA_MUNE,;													// 16 - Cidade Entrega
								TMK->UA_CEPE,;													// 17 - Cep Entrega
								DTOC(STOD(TMK->UA_PROXLIG)),;									// 18 - Retorno
								TMK->UA_HRPEND,;                                               	// 19 - Hora 	
								TMK->UA_CODOBS,;                                               	// 20 - Codigo Observacao
								TMK->UA_CODCANC} )                                             	// 21 - Codigo do Cancelamento
			DbSkip()
		End
		DbSelectArea("TMK")
		DbCloseArea()
		If Len(aLigacoes) <= 0
			Help(" ",1,"SEMDADOS" )
			aCols	:= aClone(aColAnt)
			n		:= nAnt
		   	CursorArrow()
		   	RestArea(aArea)
		   	Return(lRet)
		Endif
		
	Else
		DbSeek(xFilial("SUA")+M->UA_CLIENTE+M->UA_LOJA)
		cCodLig :=SUA->UA_NUM

		While (!Eof()) 							  	.AND.;
			  (xFilial("SUA") 	== SUA->UA_FILIAL)	.AND.;
			  (SUA->UA_CLIENTE 	== M->UA_CLIENTE)  	.AND.;  
	   	  	  (SUA->UA_LOJA 	== M->UA_LOJA)   

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o intervalo de datas do atendimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUA->UA_EMISSAO < MV_PAR01 .OR. SUA->UA_EMISSAO > MV_PAR02
				DbSelectArea("SUA") 
				Dbskip()
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o intervalo de codigos do operador ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUA->UA_OPERADO < MV_PAR03 .OR. SUA->UA_OPERADO > MV_PAR04
				DbSelectArea("SUA") 
				Dbskip()
				Loop
			Endif
    		
    		If MV_PAR05 <> 1 //Todas (Operacao)
    			If SUA->UA_OPER  <> STR(MV_PAR05-1,1)
    				DbSelectArea("SUA") 
			   		Dbskip()
					Loop					 
				Endif
			Endif
					
    		If MV_PAR06 <> 1 //Ambas (Marketing)
    			If MV_PAR06 == 2 .AND. SUA->UA_TMK <> "1" //Receptivo
    				DbSelectArea("SUA")
			   		Dbskip()
					Loop					 

	    		ElseIf MV_PAR06 == 3 .AND. SUA->UA_TMK <> "2"//Ativo
    				DbSelectArea("SUA") 
			   		Dbskip()
					Loop					 

    			ElseIf MV_PAR06 == 4 .AND. SUA->UA_TMK <> "3" //Receptivo
    				DbSelectArea("SUA")
			   		Dbskip()
					Loop					 

	    		ElseIf MV_PAR06 == 5 .AND. SUC->UA_TMK <> "4"//Ativo
    				DbSelectArea("SUA") 
			   		Dbskip()
					Loop					 
                   Endif           
               Endif    
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Filtra a ocorrencia informada no parametro³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If !Empty(MV_PAR07)
	        	If SUA->UA_CODLIG <> MV_PAR07
	        		DbSelectArea("SUA")
	        		Dbskip()
	        		Loop
	        	Endif
	        Endif
	        		 
			If (lProspect == SUA->UA_PROSPEC)

					AAdd(aLigacoes, {	TK273OrcPed(SUA->UA_DOC,SUA->UA_OPER,SUA->UA_CANC,SUA->UA_NUM),;// 01 - Status
										SUA->UA_NUM,;													// 02 - Atendimento
										DTOC(SUA->UA_EMISSAO),;											// 03 - Data	
										Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_NOME"),;		// 04 - Vendedor
										Tk273OperTlv(SUA->UA_OPER),;									// 05 - Operacao
										IIF(!Empty(SUA->UA_CODCONT),Posicione("SU5",1,xFilial("SU5")+SUA->UA_CODCONT,"U5_CONTAT"),SUA->UA_DESCNT),;	// 06 - Contato
										SUA->UA_NUMSC5,;												// 07 - Pedido
										Tk273Status(SUA->UA_STATUS),;									// 08 - Status
										Transform(SUA->UA_VLRLIQ,"@E 999,999,999.99"),;					// 09 - Valor
										Posicione("SUO",1,xFilial("SUO")+SUA->UA_CODCAMP,"UO_DESC"),;	// 10 - Campanha	
										SUA->UA_DOC+"/"+SUA->&(SerieNfId("SAU",3,"UA_SERIE")),;			// 11 - NF/SERIE
										DTOC(SUA->UA_EMISNF),;											// 12 - Emissao
										Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI"),;	// 13 - Condicao de Pagto
										Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NOME"),;	// 14 - Transportadora	
										SUA->UA_ENDENT,;												// 15 - Endereco Entrega
										SUA->UA_MUNE,;													// 16 - Cidade Entrega
										SUA->UA_CEPE,;													// 17 - Cep Entrega
										DTOC(SUA->UA_PROXLIG),;											// 18 - Retorno
										SUA->UA_HRPEND,;                                               	// 19 - Hora 	
										SUA->UA_CODOBS,;                                               	// 20 - Codigo Observacao
										SUA->UA_CODCANC} )                                             	// 21 - Codigo do Cancelamento
			  Endif						
			  DbSkip()
		End   
		
		If Len(aLigacoes) <= 0
			Help(" ",1,"SEMDADOS" )
			aCols	:= aClone(aColAnt)
			n		:= nAnt
		   	CursorArrow()
		   	RestArea(aArea)
		   	Return(lRet)
		Endif     
	Endif

#ELSE

	DbSelectArea("SUA")
	DbSetOrder(7) // UA_FILIAL+UA_CLIENTE+UA_LOJA+STR(UA_DIASDAT,8,0)+STR(UA_HORADAT,8,0)
	DbSeek(xFilial("SUA")+M->UA_CLIENTE+M->UA_LOJA)
	cCodPed :=SUA->UA_NUM

	While (!Eof()) 							   .AND.;
		  (xFilial("SUA") 	== SUA->UA_FILIAL).AND.;
		  (SUA->UA_CLIENTE 	== M->UA_CLIENTE) .AND.;  
		  (SUA->UA_LOJA 	== M->UA_LOJA)                                    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o intervalo de datas do atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUA->UA_EMISSAO < MV_PAR01 .OR. SUA->UA_EMISSAO > MV_PAR02
			DbSelectArea("SUA") 
			Dbskip()
			Loop
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o intervalo de codigos do operador ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUA->UA_OPERADO < MV_PAR03 .OR. SUA->UA_OPERADO > MV_PAR04
			DbSelectArea("SUA") 
			Dbskip()
			Loop
		Endif
    	
    	If MV_PAR05 <> 1 //Todas (Operacao)
    		If SUA->UA_OPER  <> STR(MV_PAR05-1,1)
    			DbSelectArea("SUA") 
		   		Dbskip()
				Loop					 
			Endif
		Endif
				
    	If MV_PAR06 <> 1 //Ambas (Marketing)
    		If MV_PAR06 == 2 .AND. SUA->UA_TMK <> "1" //Receptivo
    			DbSelectArea("SUA")
		   		Dbskip()
				Loop					 
	    	ElseIf MV_PAR06 == 3 .AND. SUA->UA_TMK <> "2"//Ativo
    			DbSelectArea("SUA") 
				Dbskip()
				Loop					 
    		ElseIf MV_PAR06 == 4 .AND. SUA->UA_TMK <> "3" //Receptivo
   				DbSelectArea("SUA")
		   		Dbskip()
				Loop					 
    		ElseIf MV_PAR06 == 5 .AND. SUA->UA_TMK <> "4"//Ativo
   				DbSelectArea("SUA") 
		   		Dbskip()
				Loop					 
            Endif           
        Endif    
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Filtra a ocorrencia informada no parametro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !Empty(MV_PAR07)
	      	If SUA->UA_CODLIG <> MV_PAR07
	       		DbSelectArea("SUA")
	       		Dbskip()
	       		Loop
	       	Endif
	    Endif
	        			  
		If (lProspect == SUA->UA_PROSPEC)

				AAdd(aLigacoes, {	TK273OrcPed(SUA->UA_DOC,SUA->UA_OPER,SUA->UA_CANC,SUA->UA_NUM),;			// 01 - Status
									SUA->UA_NUM,;													// 02 - Atendimento
									DTOC(SUA->UA_EMISSAO),;											// 03 - Data	
									Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_NOME"),;		// 04 - Vendedor
									Tk273OperTlv(SUA->UA_OPER),;									// 05 - Operacao
									IIF(!Empty(SUA->UA_CODCONT),Posicione("SU5",1,xFilial("SU5")+SUA->UA_CODCONT,"U5_CONTAT"),SUA->UA_DESCNT),;	// 06 - Contato
									SUA->UA_NUMSC5,;												// 07 - Pedido
									TK273Status(SUA->UA_STATUS),;									// 08 - Status
									Transform(SUA->UA_VLRLIQ,"@E 999,999,999.99"),;					// 09 - Valor
									Posicione("SUO",1,xFilial("SUO")+SUA->UA_CODCAMP,"UO_DESC"),;	// 10 - Campanha	
									SUA->UA_DOC+"/"+SUA->&(SerieNfId("SAU",3,"UA_SERIE")),;			// 11 - NF/SERIE
									DTOC(SUA->UA_EMISNF),;											// 12 - Emissao
									Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI"),;	// 13 - Condicao de Pagto
									Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NOME"),;	// 14 - Transportadora	
									SUA->UA_ENDENT,;												// 15 - Endereco Entrega
									SUA->UA_MUNE,;													// 16 - Cidade Entrega
									SUA->UA_CEPE,;													// 17 - Cep Entrega
									DTOC(SUA->UA_PROXLIG),;											// 18 - Retorno
									SUA->UA_HRPEND,;                                               	// 19 - Hora 	
									SUA->UA_CODOBS,;                                               	// 20 - Codigo Observacao
									SUA->UA_CODCANC} )                                             	// 21 - Codigo do Cancelamento
	    Endif
		DbSkip()
	End 
		
	If Len(aLigacoes) <= 0
		Help(" ",1,"SEMDADOS" )
		aCols	:= aClone(aColAnt)
		n		:= nAnt
		CursorArrow()
		RestArea(aArea)
		Return(lRet)
	Endif
#Endif

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
DEFINE MSDIALOG oDlgHist FROM  50,001 TO 600,750 TITLE STR0013 PIXEL //"Historico" 
	
	@01,02 TO 210,374 LABEL STR0014 +" :"+ FATPDObfuscate(M->UA_DESCCLI,"UA_DESCCLI") OF oDlgHist  PIXEL //"Ultimas Ligacoes" 
	
	@08,05 LISTBOX oLbx FIELDS;
		HEADER ;
			" ",;		// Cores 
			STR0033,;	// Atendimento  
			STR0016,;	// Data  
			STR0017,;	// Vendedor  
			STR0018,;	// Opera‡„o  
			STR0019,;	// Contato  
			STR0020,;	// Pedido  
			STR0021,;	// Status  
			STR0022,;	// Valor  
			STR0023,;	// Campanha  
			STR0024,;	// Nota Fiscal  
			STR0025,;	// Emiss„o NF  
			STR0026,;	// Condi‡„o de Pagto 
			STR0027,;	// Transportadora  
			STR0028,;	// Endere‡o Entrega  
			STR0029,;	// Cidade  
			STR0030,;	// CEP 
			STR0044,;	// Retorno 
			STR0045;	// Hora 
		SIZE 365,100 OF oDlgHist PIXEL  
	
		oLbx:SetArray(aLigacoes)
		oLbx:bLine:={||{aLigacoes[oLbx:nAt,1],;
						aLigacoes[oLbx:nAt,2],;
						aLigacoes[oLbx:nAt,3],;
						aLigacoes[oLbx:nAt,4],;
						aLigacoes[oLbx:nAt,5],;
						aLigacoes[oLbx:nAt,6],;
						aLigacoes[oLbx:nAt,7],;
						aLigacoes[oLbx:nAt,8],;
						aLigacoes[oLbx:nAt,9],;
						aLigacoes[oLbx:nAt,10],;
						aLigacoes[oLbx:nAt,11],;
				        aLigacoes[oLbx:nAt,12],;
				        aLigacoes[oLbx:nAt,13],;
				        aLigacoes[oLbx:nAt,14],;
				        aLigacoes[oLbx:nAt,15],;
				        aLigacoes[oLbx:nAt,16],;
				        aLigacoes[oLbx:nAt,17],;
						aLigacoes[oLbx:nAt,18],;
						aLigacoes[oLbx:nAt,19],;			        
						aLigacoes[oLbx:nAt,20],;			        
						aLigacoes[oLbx:nAt,21]}}			        
		
	oLbx:bChange:= {|| cCodPed:= aLigacoes[oLbx:nAt,2],;
					   Tk273CargaItem(	@cObsMemo	,@cCancMemo				,oObsMemo				,oCancMemo,;
										oGetHist	,aLigacoes[oLbx:nAt,2]	,aLigacoes[oLbx:nAt,20]	,aLigacoes[oLbx:nAt,21] )}
	
	If FATPDActive() .And. FTPDUse(.T.)
		aPDCols := {"","","","A3_NOME","","U5_CONTAT","","","","","","","","A4_NOME","UA_ENDENT","UA_MUNE","UA_CEPE","","","",""}
		oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
	Endif
	
	oLbx:Refresh()
	oLbx:SetFocus(.T.)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pego o codigo do atendimento e carrega o acols com os itens	  ³
	//³deste atendimento se ele existir.                          	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodPed := Eval(oLbx:bLine)[2]
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o acols com os itens da ligacao selecionada.			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SUB")
	TkMontaItens("SUB",cCodPed,"V")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Modificado o valor da variavel N para 1 para que não seja tomado³
	//³como parametro a posicao do acols da tela de atendimento        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	n := 1
	
	oGetHist:= MSGetDados():New(115,5,200,370,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,300)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observa‡„o da liga‡„o										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 212,02 TO 258,124 LABEL STR0031 OF oDlgHist PIXEL  // //"Observa‡„o da liga‡„o" 
	@ 220,05 GET oObsMemo VAR cObsMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
	oObsMemo:oFont := oMonoAs
	oObsMemo:bRClicked := {|| AllwaysTrue() }
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Motivo do Cancelamento se for um or‡amento cancelado  		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 212,133 TO 258,257 LABEL STR0032 OF oCancMemo PIXEL  // //"Motivo do Cancelamento" 
	@ 220,138 GET oCancMemo VAR cCancMemo OF oCancMemo MEMO SIZE 114,35 PIXEL READONLY
	oCancMemo:oFont := oMonoAs
	oCancMemo:bRClicked := {|| AllwaysTrue() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Bitmaps das legendas do historico     ³
	//³                                      ³
	//³Marrom - Atendimento 			     ³
	//³Azul -  Orcamento                     ³
	//³Verde - Aberto                        ³
	//³Amarelo - Liberado                    ³
	//³Vermelho - NF.Emitida                 ³
	//³Preto - Cancelado                     ³
	//³Branco - Em Carga (integracao com OMS)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    // Legendas da Tela
    
	@ 265,05 BITMAP oBmp1 ResName "BR_MARRON" OF oDlgHist Size 10,10 NoBorder When .F. Pixel 
	@ 265,15 SAY STR0033 OF oDlgHist Color CLR_BROWN,CLR_WHITE PIXEL   	//"Atendimento"

	@ 265,55 BITMAP oBmp2 ResName "BR_AZUL" OF oDlgHist Size 10,10 NoBorder When .F. Pixel 
	@ 265,65 SAY STR0002 OF oDlgHist Color CLR_BLUE,CLR_WHITE PIXEL  	//"Orcamento"

	@ 265,105 BITMAP oBmp3 ResName "BR_VERDE" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
	@ 265,115 SAY STR0048 OF oDlgHist Color CLR_GREEN,CLR_WHITE PIXEL  	//"Aberto"

	@ 265,155 BITMAP oBmp4 ResName "BR_AMARELO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
	@ 265,165 SAY STR0046 OF oDlgHist Color CLR_BLACK PIXEL  			//"Liberado"
        
	@ 265,205 BITMAP oBmp5 ResName "BR_VERMELHO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
	@ 265,215 SAY STR0047 OF oDlgHist Color CLR_RED,CLR_WHITE PIXEL  	//"NF.Emitida"

	@ 265,255 BITMAP oBmp6 ResName "BR_PRETO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
	@ 265,265 SAY STR0049 OF oDlgHist Color CLR_BLACK,CLR_WHITE PIXEL  //"Cancelado

	@ 265,305 BITMAP oBmp7 ResName "BR_BRANCO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel
	@ 265,315 SAY "Em Carga" OF oDlgHist Color CLR_BLACK,CLR_WHITE PIXEL  	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o atendimento para a tela do Televendas para a operacao de ALTERACAO                                                 ³
	//³Quando a rotina for executa a partir da Agenda de Operador somente sao feitas inclusoes de atendimento, por isso o flag l380 ³
	//³Quando a operacao for de VISUALIZACAO o historico so pode ser consultado sem alteracao de atendimento.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!l380) .OR. (nOpc <> 2)
		DEFINE SBUTTON FROM 240,300 TYPE 1 	ENABLE OF oDlgHist ACTION (nEscolha:=1,oDlgHist:End())
	Endif	
	
	DEFINE SBUTTON FROM 240,340 TYPE 2 	ENABLE OF oDlgHist ACTION (nEscolha:=0,oDlgHist:End())		

ACTIVATE MSDIALOG oDlgHist CENTER ON INIT CursorArrow()
FATPDUnload()
FATPDLogUser("TK273HTLV")

aCols := aClone(aColAnt)
n	  := nAnt	

If nEscolha == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para verificar se abre ou nao o historico de atendimento.    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTK273Abr
		lTK273Abr := ExecBlock("TK273ABR",.F.,.F.,{} )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Protecao para retorno do ponto de entrada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Valtype(lTK273Abr) == "L"
			If !lTK273Abr
				Return(.F.)
			EndIf
		Endif
			
	Endif

	If lTMKVHO
	   If !U_TMKVHO(cCodPed)
		  aCols := aClone(aColAnt)
		  n	  	:= nAnt	
		  RestArea(aArea)
	      Return(lRet)
	   Endif
	Endif
	
	lRet := .T.
	
	If (nOpc == 4)
		TkLibLoja("D", M->UA_NUM)
	EndIf
	
	If oEnchTlv:cAlias == "SUA" .And. nOpc <> 2
	 	If ((TkGetTipoAte() == "2") .OR. (nFolder == 2)) .And. !Empty(cLock)
			UnLockByName(cLock,.T.,FWModeAccess("SUA",3) == "E",.T.)
	   	cLock := ""
		EndIf

		If !LockByName("SUA"+xFilial("SUA")+cCodPed,.T.,FWModeAccess("SUA",3) == "E",.T.)
			MsgAlert(OemToAnsi(STR0053))
			nOpc := 2 // Visualização
			lHabilita := .F.
			cLock := ""
		Else
			cLock := "SUA"+xFilial("SUA")+cCodPed
		EndIf
	ElseIf oEnchTlv:cAlias == "SUA" .And. nOpc == 2
		If ExistCPO("SUA",M->UA_NUM)
			If !LockByName("SUA"+xFilial("SUA")+cCodPed,.T.,FWModeAccess("SUA",3) == "E",.T.)
				MsgAlert(OemToAnsi(STR0053))
				nOpc := 2 // Visualização
				lHabilita := .F.
				cLock := ""
			Else
				nOpc := 3 // Alteração
				lHabilita := .T.
				cLock := "SUA"+xFilial("SUA")+cCodPed
			EndIf
		EndIf
	EndIf
	
	Tk273NumTlv(@nOpc		,cCodPed		,@lHabilita		,oFolderTlv,;
				@oEnchTlv	,@cCodPagto		,@cDescPagto	,@cCodTransp,;
				@cTransp	,@cCob			,@cEnt			,@cCidadeC,;
				@cCepC		,@cUfC			,@cBairroE		,@cBairroC,;
				@cCidadeE	,@cCepE			,@cUfE			,@nLiquido,;
				@nTxJuros	,@nTxDescon		,@nVlJur		,@aParcelas,;
				@nEntrada	,@nFinanciado	,@nNumParcelas	,@nValorCC,;		
				@aColsTlv	,@cCodAnt		,@cCliAnt		,@cLock)

	nPQtd     := aPosicoes[4][2]
	nPVrUnit  := aPosicoes[5][2]
	nPVlrItem := aPosicoes[6][2]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o valor do suframa na mão, pois quando é Televendas³
	//³off-line, esse valor está desatualizado.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk273Refresh(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula o item para garantir os impostos de acordo com a quantidade informada se houver desconto da SUFRAMA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MaFisFound()

		For nLinha := 1 To Len(aCols)
		
			MaFisAlt("IT_QUANT"		,aCols[nLinha][nPQtd]		,nLinha)
			MaFisAlt("IT_PRCUNI"	,aCols[nLinha][nPVrUnit]	,nLinha)
			MaFisAlt("IT_VALMERC"	,aCols[nLinha][nPVlrItem]	,nLinha)

			If aValores[SUFRAMA] > 0 				
				Tk273Recalc(nLinha,.T.)
			Endif
			
			If cPaisLoc == "BRA" .And. nPValDesc > 0 .And.	nPTes > 0	
				If aCols[nLinha][nPValDesc] > 0 .And. !Empty(aCols[nLinha][nPTes]) 
					SF4->(dbSetOrder(1))
					SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPTes]))
					If SF4->F4_TPIPI == "B"
						MaFisAlt("IT_BASEIPI",MaFisRet(nLinha,"IT_BASEIPI") + aCols[nLinha][nPValDesc],nLinha)				
					EndIf
				EndIf
			EndIf

		Next nLinha

		// Atualiza com os valores do rodape
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])			
		Tk273RodImposto("NF_DESPESA",aValores[DESPESA])              
		Tk273RodImposto("NF_FRETE",aValores[FRETE])
				
		// Atualiza o rodape
		Tk273Refresh()	
		Eval(bFolderRefresh)
		Eval(bRefresh)			
	Endif

Else
	aHeader := aClone(aHeaderBk)  		
Endif				

RestArea(aArea)
	
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Fun‡„o	 ³TkCargaItem ³ Autor ³ Luis Marcelo Kotaki	 ³ Data ³ 15/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os items gravados em cada atendimento selecionado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	   ³±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk273CargaItem(	cObsMemo	,cCancMemo	,oObsMemo	,oCancMemo,;
								oGetHist	,cCodPed	,cCodObs	,cCodCan)
Local aFirst[1][Len(aHeader)+1]

aCols := aClone(aFirst)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o acols com os itens da ligacao selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkMontaItens("SUB",cCodPed,"V")

oGetHist:oBrowse:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego a observação do orçamento e o motivo do cancelam. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cObsMemo := MSMM(cCodObs,TamSx3("UA_OBS")[1])
oObsMemo:Refresh()

cCancMemo:= MSMM(cCodCan,TamSx3("UA_OBSCANC")[1])
oCancMemo:Refresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkOperTlv  ³ Autor ³Luis Marcelo Kotaki	 ³ Data ³22/07/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o tipo de operacao realizada no ATENDIMENTO selecionado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk273OperTlv(cCampo)
Local cDesc := ""		//Tipo de operacao

Do Case
	Case AllTrim(cCampo) == "1"
		cDesc := STR0001		//"Faturamento"
	Case AllTrim(cCampo) == "2"
		cDesc := STR0002		//"Or‡amento  " 
	Case AllTrim(cCampo) == "3"
		cDesc := STR0033		//"Atendimento" 
Endcase          

Return(cDesc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271OrcPed ³ Autor ³Marcelo Kotaki       ³ Data ³ 08/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica quais os pedidos estao liberados e com NF gerada	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³Andrea F. ³31/05/04³811   ³-BOPS:71829 Correcao da exibicao dos Bitmaps³±±
±±³          ³        ³      ³ das Legendas Liberado e Encerrado.         ³±±
±±³Fernando  ³23/10/06³811   ³- BOPS:110887 correcao da exibicao dos      ³±±
±±³          ³        ³      ³Bitmaps para somente mudar para faturado    ³±±
±±³          ³        ³      ³caso todos os itens do ped. sejam faturados ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk273OrcPed(cNF,cOper,cCanc,cNum)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Bitmaps das legendas do historico     ³
//³                                      ³
//³Marrom - Atendimento 			     ³
//³Azul -  Orcamento                     ³
//³Verde - Aberto                        ³
//³Amarelo - Liberado                    ³
//³Vermelho - NF.Emitida                 ³
//³Preto - Cancelado                     ³
//³Branco - Em Carga (integracao com OMS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oAtendimento:= LoadBitmap( GetResources(),"BR_MARRON")        // Bitmap 
Local oOrcamento  := LoadBitmap( GetResources(),"BR_AZUL")			// Bitmap 
Local oAberto	  := LoadBitmap( GetResources(),"BR_VERDE")			// Bitmap 	
Local oLiberado   := LoadBitmap( GetResources(),"BR_AMARELO") 		// Bitmap 
Local oFaturado   := LoadBitmap( GetResources(),"BR_VERMELHO")		// Bitmap 
Local oCancelado  := LoadBitmap( GetResources(),"BR_PRETO")			// Bitmap 
Local oCarga      := LoadBitmap( GetResources(),"BR_BRANCO")		// Bitmap 
Local oRet															// Objeto de Retorno
Local aArea		  := GetArea()										// Salva a area atual

DbSelectArea("SUA")
DbSetOrder(1)
DbSeek(xFilial("SUA")+cNum)

If !Empty(TRIM(cCanc))
	oRet := oCancelado
Else	
	If cOper == "1" //Faturamento
		Do case
			Case Empty(cNF) //Aberto
				oRet := oAberto
				
				If !Empty(SUA->UA_NUMSC5)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifico se esse pedido foi liberado pelo SIGAFAT³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SC9")
					DbSetOrder(1)
					If DbSeek(xFilial("SC9")+SUA->UA_NUMSC5)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se todos os itens estao faturados,           ³
						//³caso um item nao esteja a legenda ficara como liberado³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SC6")
				   		DbSetOrder(1)
						If DbSeek( xFilial( "SC6" ) + SUA->UA_NUMSC5 )
						 
							While !SC6->( Eof() ) .AND. SUA->UA_NUMSC5 == SC6->C6_NUM
								If Empty( SC6->C6_NOTA )
								    oRet := oLiberado
								    Exit
						   		Else
						   			oRet:=oFaturado
								Endif  
								SC6->( DbSkip() )
							End 
							
						 EndIf	
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifico se esse pedido esta em Carga (OMS)      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("DAI")
					DbSetOrder(4)
					If DbSeek(xFilial("DAI")+SUA->UA_NUMSC5)
						oRet := oCarga
					Endif						
					
				Endif
				
			Case !Empty(cNF) // NF. Emitida
				oRet := oFaturado
		Endcase
		
	ElseIf cOper == "2"  //Or‡amento
		oRet := oOrcamento
		
	ElseIf cOper == "3"  //Atendimento
	    oRet := oAtendimento	
	Endif
Endif

RestArea(aArea)
Return(oRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271GETSAE  ³ Autor ³ Rafael M. Quadrotti   ³ Data ³16/04/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pesquisa no SAE o codigo da Admnistradora para gravacao do SL4 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1:Descricao da Adminsitradora.         		             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³String com o codigo mais a descricao da Administradora.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Televendas                                                 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  	 ³±±
±±³          ³        ³      ³                                            	 ³±±
±±³          ³        ³      ³                                            	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                    
Function Tk273GetSAE(cAdm)

Local nElem := 0						//Indice para posicionamento do vetor de administradoras
Local nReg	:= SAE->( RecNo() )		//Registro atual do SAE
Local aInst := {}						//Vetor com o nome das administradoras
Local aReg	:= {}						//Vetor de registros do SAE

If !Empty(cAdm)
	SAE->( dbEval( { || Aadd( aInst, Upper(Left( AE_DESC, 16 ))), ;
	Aadd(aReg , Recno()) } ) )

	For nElem := 1 To Len(aInst)
	    If  (AllTrim(aInst[nElem]) == cAdm)
			Exit
	    Endif
	Next nElem
	
	If (nElem > 0) .AND. (nElem <= Len(aInst))
		SAE->( DbGoTo( aReg[nElem] ) )
		cAdm := SAE->AE_COD + "-" + cAdm
	Else
		//Esta errado o processo de validacao - alterar 710
		Help( " ", 1, "TMKADMFIN" )
		//"A administradora financeira nao foi encontrada. 
		//Os titulos financeiros a receber referentes a esta venda deverão ser implantados manualmente"
	Endif
	SAE->( DbGoTo( nReg ) )
Endif
	
Return(cAdm)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Vend    ³ Autor ³Marcelo Kotaki         ³ Data ³09/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Visualizacao dos dados do Vendedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TeleVendas                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	   	³±±
±±³          ³        ³      ³                                             	³±±
±±³          ³        ³      ³                                             	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273VisVend()

Local aArea		  := GetArea()						// Salva a area atual
Local cVend       := ""                             // Vendedor
Local lRet		  := .F.							// Retorno da funcao
Private cCadastro := STR0034						// "Visualiza‡„o do Cadastro de Vendedores"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente para Televendas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFolder == 1 .AND. (TkGetTipoAte() == "2"	.OR. TkGetTipoAte() == "4")) .OR. (nFolder == 2)
	cVend:= M->UA_VEND
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se foi informado o vendedor.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cVend)
		Help( " ", 1, "FALTA_VEND" )
		Return(lRet)
	Endif
	
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek( xFilial("SA3")+ cVend )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para processamento dos Gets          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcA := AxVisual("SA3",RECNO(),2)
		lRet := .T.
	Endif
Else
	Help(" ",1,"TLVROTINA")
Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK271Pedido ³ Autor ³ Marcelo Kotaki     ³ Data ³ 24/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza o pedido criado pelo TELEVENDAS no SC5/SC6       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TeleVendas                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³10    ³-Revisao do fonte                     	  ³±±
±±³Hanna C   ³11/09/07³10    ³-Para mostrar o pedido de vendas, posiciona ³±±
±±³          ³        ³      ³no SUA o atendimento que esta na memoria    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273Pedido( nFolder )

Local aArea	:= GetArea()		//Salva a area atual
Local lRet	:= .F.              //Retorno da funcao

Private cCadastro := STR0035	//"Visualiza‡„o do Pedido"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente para Televendas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFolder == 1 .AND. TkGetTipoAte() == "2") .OR. (nFolder == 2) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no SUA o atendimento que está carregado na memoria³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SUA" )
	DbSetOrder(1)
	If DbSeek( xFilial("SUA") + M->UA_NUM ) .AND. !Empty( M->UA_NUM )

		If !Empty(SUA->UA_NUMSC5)
			DbSelectArea("SC5")
			DbSetOrder(1)
			If DbSeek( xFilial("SC5")+ SUA->UA_NUMSC5 )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para processamento dos Gets          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lRet := .T.
				A410Visual("SC5",RECNO(),2)
			Endif
		Else 
			Help(" ",1,"NOPEDIDO")
		Endif
	Else 
		Help(" ",1,"NOPEDIDO")
	Endif
Else
	Help(" ",1,"TLVROTINA")
Endif

RestArea( aARea )
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271AvalBonus   ³ Autor ³Marcelo Kotaki         ³ Data ³ 19/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe os bonus que o cliente tem direito			          	 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                   	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	   		 ³±±
±±³          ³        ³      ³                                             		 ³±±
±±³          ³        ³      ³                                             		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273AvalBonus()

Local aBonus   := {}      							// Array com os bonus que o cliente tem direito
Local aBtn	   := Array(4)							// Array com os botoes da enchoicebar
Local nPProd   := 0									// Posicao do Produto
Local nPQuant  := 0									// Posicao da Quantidade
Local nPTes    := 0									// Posicao do Tes       
Local aSize    := MsAdvSize(.T.,.T.,400)			// Tamanho da Janela
Local oDlg											// Janela Bonus
Local oLbx											// Listbox com os bonus
Local oBar											// Barra de Botoes
Local aInfo    := {}								// Informacoes para a divisao da area de trabalho
Local aObjects := {}								// Definicoes dos objetos
Local aPosLabel:= {}								// Posicao do Objeto Label
Local lRet	   := .F.								// Retorno da funcao
	              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se quem esta executando a rotina e Televendas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (TkGetTipoAte() == "4" .AND. nFolder == 2) .OR. (TkGetTipoAte() == "2")
	nPProd  := aPosicoes[1][2]
	nPQuant := aPosicoes[4][2]
	nPTes   := aPosicoes[11][2]
Else
	Help( " ", 1, "TLVROTINA" )
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a funcao que retorna os bonus.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBonus:= FtRgrBonus(aCols,{nPProd,nPQuant,nPTes},M->UA_CLIENTE,M->UA_LOJA,M->UA_TABELA,M->UA_CONDPG,NIL,NIL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao tiver nenhum bonus exibe o help SEMDADOS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aBonus) == 0)
	Help( " ", 1, "SEMDADOS" )
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta o tamanho do Label	       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aObjects := {}

AAdd( aObjects, { 01, 01, .T., .T. , .F.} )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosLabel:= MsObjSize( aInfo, aObjects,  , .T. )
          
DEFINE MSDIALOG oDlg FROM  aSize[7],0 TO aSize[6],aSize[5] TITLE STR0036 PIXEL OF oMainWnd //"Bonus" 
	DEFINE BUTTONBAR oBar 3D TOP OF oDlg
	
	DEFINE BUTTON aBtn[1] RESOURCE "S4WB005N" OF oBar TOOLTIP STR0037 ACTION aBtn[1]:cDefaultAct := "COPY" 	//"Copiar" 
	DEFINE BUTTON aBtn[2] RESOURCE "S4WB006N" OF oBar TOOLTIP STR0038 ACTION aBtn[2]:cDefaultAct := "CUT" 	//"Recortar"
	DEFINE BUTTON aBtn[3] RESOURCE "S4WB007N" OF oBar TOOLTIP STR0039 ACTION aBtn[3]:cDefaultAct := "PASTE" 	//"Colar" 
	DEFINE BUTTON aBtn[4] RESOURCE "OK"       OF oBar TOOLTIP "OK"    ACTION oDlg:End()

	@aPosLabel[1,1] 	, aPosLabel[1,2] 	TO aPosLabel[1,3] , aPosLabel[1,4] LABEL "" OF oDlg  PIXEL
	@aPosLabel[1,1]+3  	, aPosLabel[1,2]+2  LISTBOX oLbx FIELDS ;
		HEADER;
		 	STR0040,;//"Produto"
		 	STR0041,;//"Descricao"
		 	STR0042,;//"Quantidade"
		 	STR0043 ;//"TES"
		SIZE aPosLabel[1,4]-4 ,aPosLabel[1,3]-15 NOSCROLL OF oDlg PIXEL 
	
	oLbx:SetArray(aBonus)
	oLbx:bLine:={||{	aBonus[oLbx:nAt,1],;												//Codigo do Produto
						Posicione("SB1",1,xFilial("SB1") + aBonus[oLbx:nAt,1],"B1_DESC"),;	//Descricao do Produto
						aBonus[oLbx:nAt,2],;												//Quantidade 
						aBonus[oLbx:nAt,3]}}												//Tes
						
	
ACTIVATE MSDIALOG oDlg ON INIT lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271ConTef³ Autor ³Marcelo Kotaki        ³ Data ³27/12/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a consulta do TEF                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³          ³        ³      ³                                            ³±±
±±³Cleber M. ³07/11/05³811   ³- BOPS 88251: Multiplas transacoes TEF no   ³±±
±±³          ³        ³      ³Televendas usando a DLL Clisitef.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Function TK273ConTef()

If (cTipTef == "2" .OR. cTipTef == "3")
	Loja010T("C")
Else
	Help( " ", 1, "SEMCONFTEF" )
Endif            

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273HSUA     ºAutor  ³Marcelo Kotaki  º Data ³  22/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da hora de retorno                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TELEVENDAS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TK273HSUA()

Local cHora := &( ReadVar() )	//Armazena a hora
Local lRet	:= .F.				//Retorno da funcao

If cHora <> "  :  "
	If (M->UA_PROXLIG == M->UA_EMISSAO)
		If cHora >= Time()
			lRet := .T.
		Endif	
	ElseIf (M->UA_PROXLIG > M->UA_EMISSAO)
		If (cHora > "00:00") .AND. (cHora <= "24:00")
			lRet := .T.
		Endif	
	Endif	
Else
	lRet := .T.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Tk273LojaEval º Autor ³ Vendas e CRM  º Data ³  10/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Força a execução do valid do controle que está em foco.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Televendas                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273ExecCampo(bBloco)
Local oTela  := GetWndDefault()	// Pega a tela corrente
Local lValid := .T. 			// Se o campo foi validado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a tela.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTela:CommitControls()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o controle que está com foca tem validação.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(oTela:oCtlFocus==NIL) .and. ValType(oTela:oCtlFocus:bValid) = 'B'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a validação do campo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lValid := Eval(oTela:oCtlFocus:bValid,oTela:oCtlFocus)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o retorno da validação.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(lValid) = 'L' .AND. (lValid = .F.)
		Return lValid
	Else
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o cargo para não executar novamente a validação.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTela:oCtlFocus:Cargo := &(oTela:oCtlFocus:cReadVar)		
		oTela:oCtlFocus:lModified := .f.
		Return Eval(bBloco) // como a tela validou ok, faz o tratamento normal
	EndIf
EndIf

Return Eval(bBloco)

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

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

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
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

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
