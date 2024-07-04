#INCLUDE "TMKA380B.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMKA380B  ºAutor  ³Rafael M. Quadrotti º Data ³  01/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Agenda do operador. Marketing Ativo.                        º±±
±±º          ³FUNCOES DO BOTAO OK DA TELA COM OS ITENS QUE SERAO TRABALHA º±±
±±º          ³DOS                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK380OK   ºAutor  ³Rafael M. Quadrotti º Data ³  01/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Botao Ok da tela de contatos. Executa a interacao com o itemº±±
±±º          ³da lista.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: Array com os dados da lista de contatos selecionada. º±±
±±º          ³ExpA2: Array aCols com os itens da lista.                   º±±
±±º          ³ExpA3: Array aHeader com o cabecalho dos itens da Lista.    º±±
±±º          ³ExpO1: Objeto oGetDados com os itens da Lista.              º±±
±±º          ³ExpN1: Linha selecionada na GetDados para execucao.(Lst Voz)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - Agenda do Operador                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³31/03/04³811   ³- Inclusao da Funcao Tk380LdCobra() para ser³±±
±±³          ³        ³      ³executada na confirmacao do item da lista.  ³±±
±±³Andrea F. ³26/07/05³811   ³BOPS 83480 - Enviar o arquivo em anexo que  ³±±
±±³          ³        ³      ³foi atachado ao e-mail.                     ³±±
±±³Andrea F. ³13/10/05³811   ³BOPS 83480 - Tratamento de mudanca de posi- ³±±
±±³          ³        ³      ³cao dos campos da tabela SU6.               ³±±
±±³Conrado Q.³06/11/06³811   ³BOPS 112303 - Trocou-se as mensagens que    ³±±
±±³          ³        ³      ³informam que não há títulos a serem         ³±±
±±³          ³        ³      ³cobrados, ou os títulos existentes estão em ³±±
±±³          ³        ³      ³exceção.                                    ³±±
±±³Norbert W.³09/04/07³912   ³BOPS 122173 - Correcao da montagem do tele- ³±±
±±³          ³        ³      ³fone para contato enviado a Tk380Discar().  ³±±
±±³Norbert W ³25/05/07³811   ³BOPS 126802 - Verificacao do tipo do telefo-³±±
±±³          ³        ³      ³ne a ser utilizado no contato via voz.      ³±±
±±³Michel M. ³21/06/07³811   ³BOPS 127864 - Libera item da lista Cross    ³±±
±±³          ³        ³      ³Posting quando ocorre uma falha no envio do ³±±
±±³          ³        ³      ³email.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk380OK(	aItemSel	,aCols	,aHeader	,oGetDados,;	
					nLiaCols)


Local lRet      	:= .F.															//Retorno da funcao
Local cOperador 	:= TkOperador()													//Retona o codigo do operador ativo no sistema.
Local cStatus   	:= ""      														//Status do item para o Historico de Marketing 
Local lTMKSUSP  	:= ExistBlock("TMKSUSP") 										//Ponto de entrada para transformar o suspect em prospect
Local lTMKAGWEB 	:= ExistBlock("TMKAGWEB") 										//Ponto de entrada para Listas do Tipo WebSite.
Local nAuxOpc 		:= 0															//Indica se a operacao na tela de atendimento sera de INCLUSAO = 3 ou ALTERACAO = 4	
Local aLckCont		:= {}															//Array com as inf. dos contatos.
Local aSend     	:= {}															//Array com os emails que serao enviados e dados para Mala direta.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para listas de voz.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTel			:= ""   														//Numero do Telefone que sera discado
Local cDDD			:= ""           												//Numero do DDD 
Local cDDI			:= ""           												//Numero do DDI
Local lCampScpt 	:= .F.                  										//FLAG para verificar se tem um script de campanha para executar
Local cTipoBkp		:= ""															//Armazena as informacoes de acesso do operador para posterior restauracao.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para listas de Cross Posting.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cEmail    	:= "" 															//Email do contato
Local cAssunto  	:= ""															//Assunto do email
Local cMensagem 	:= ""															//Mensagem do email
Local cAttach   	:= ""           												//Arquivo Atachado
Local cFrom     	:= ""															//Conta de email do usuario (LOGADO) 
Local cServer   	:= SuperGetMV("MV_RELSERV") 								    //Nome do SERVIDOR DE SMTP
Local cAccount  	:= Posicione("SU7",1,xFilial("SU7") + cOperador,"U7_CONTA")		//Conta do email do OPERADOR selecionado para executar a lista
Local cPassword 	:= Posicione("SU7",1,xFilial("SU7") + cOperador,"U7_SENHA") 	//Senha da conta de email do OPERADOR selecionado para executar a lista
Local nPos			:= 0 															//Retorno do Ascan para verificacao do array aSend.
Local nCont			:= 0															//Contador do for para selecao dos contatos para lock.
Local a1AuxLck  	:= {}															//Array 1 auxiliar para tratamento de itens nao enviados.	
Local a2AuxLck  	:= {}															//Array 2 auxiliar para tratamento de itens nao enviados.	
Local a3AuxLck  	:= {}															//Array 3 auxiliar para tratamento de itens nao enviados.	
Local aTlc			:= {}															//Array com os dados do titulo para preenchimento na tela de Telecobranca ATIVA
Local lRetCob		:= .T.															//Retorno da funcao que vai alimentar o array com os dados do titulo
Local lTMK380HR  := ExistBlock("TMK380HR")
/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³	aHeader         Conteudo 			³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³	01              U4_LG - Legenda		³
  ³	02				U6_CODIGO			³
  ³	03				U6_CONTATO			³
  ³	04				U6_NCONTAT			³
  ³	05				U6_CODENT			³
  ³	06				U6_DESCENT			³
  ³	07				U6_ORIGEM			³
  ³	08				U6_DATA				³
  ³	09				U6_HRINI			³
  ³	10				U6_HRFIM			³
  ³	11				U6_STATUS			³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sempre deve-se usar TRIM na busca e comparacao de campos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPLegenda		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U4_LG"		} )                 // 01 - Posicao do campo Legenda
Local nPCodSeq		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_CODIGO"	} )      			// 02 - Posicao do campo Codigo sequencial dos itens da lista no acols		
Local nPCodCon		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_CONTATO"} )                 // 03 - Posicao do campo Codigo do Contato 
Local nPNContato	:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_NCONTAT"} )                 // 04 - Posicao do campo Nome do Contato
Local nPCodEnt		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_CODENT"	} )                 // 05 - Posicao do campo Codigo da Entidade (Chave)
Local nPDescEnt		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_DESCENT"} )                 // 06 - Posicao do campo Descricao da Entidade
Local nPOrigem		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_ORIGEM"	} )                 // 07 - Posicao do campo Origem (1-Lista/ 2-Manual /3-Atendimento)
Local nPData		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_DATA"	} )                 // 08 - Posicao do campo Data
Local nPHrIni		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_HRINI"	} )                 // 09 - Posicao do campo Hora inicial
Local nPHrFim		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_HRFIM"	} )                 // 10 - Posicao do campo Hora final
Local nPStatus		:= Ascan(aHeader,{|x| TRIM(x[2]) == "U6_STATUS"	} )                 // 11 - Posicao do campo Status(1-Nao enviado /2- Em uso/ 3-Enviado)
Local nTipoTel		:= 0															// Tipo do telefone para contato
Local cTipoTel 		:= GetNewPar("MV_TMKTPTE","4")									// Tipo do telefone para contato(quando lido via parametro)
Local nTel			:= 0															// Contador para selecionar um telefone valido
Local aArea  		:= GetArea()
Local aAreaSU6 		:= GetArea("SU6")
Local aAreaOs		:= {}
Local cAvisoOs	:= ""
Local lTK380BLQ  	:= ExistBlock("TK380BLQ")									 	//Ponto de entrada para permitir ou não o bloqueio de cliente.
Local lBlqCli		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Certifica-se que o parametro foi lido corretamente (sem aspas)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipoTel := StrTran(cTipoTel,'"','')
cTipoTel := StrTran(cTipoTel,"'",'')
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cliente esta bloqueado para utilização                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
DbSelectArea("SU6")
DbSetOrder(1)
If DbSeek(xFilial("SU6") + aItemSel[1]+Alltrim(aCols[nLiaCols,nPCodSeq]))
	If lTK380BLQ
		lBlqCli := ExecBlock("TK380BLQ",.F.,.F.,{SU6->U6_ENTIDA, aCols[nLiaCols,nPCodEnt]}) 
	EndIf
	If lBlqCli .And. !ExistCpo(SU6->U6_ENTIDA, aCols[nLiaCols,nPCodEnt])   
		Return(lRet)
	Endif
Endif
RestArea(aAreaSU6)
RestArea(aArea)

If lTMK380HR
	lRetBlk := ExecBlock("TMK380HR",.F.,.F.,{ aCols[nLiaCols][nPHrIni] , aCols[nLiaCols][nPHrFim] })
	If (ValType(lRetBlk) == "L") .And. !lRetBlk
		Return(lRetBlk)
	Endif 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ligacao esta sendo efetuada fora do horario definido na lista de contato.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Time() < aCols[nLiaCols][nPHrIni]) .OR. (Time() >= aCols[nLiaCols][nPHrFim])

	If !TmkOk(STR0004) //	"Ligacao fora do Horario. Deseja prosseguir com a Ligacao?"
		Return(lRet)
	Endif	
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona SU4 na lista selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4") + aItemSel[1],.T.)

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Lista de Voz 			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (VAL(SU4->U4_FORMA) == VOZ)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa variavel com as informacoes para execucao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aLckCont	:= {}
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera Status do SU6 marcando registro com em uso.³
			//³Listas de voz executam 1 registro por vez.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³aLckCont - Array com os contatos para Lock³
			//³aLckCont[x][1] = Lista                    ³
			//³aLckCont[x][2] = Codigo Seq. do SU6       ³
			//³aLckCont[x][3] = Contato                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd(aLckCont,{	aItemSel[1],;              		
							aCols[nLiaCols][nPCodSeq],;
							aCols[nLiaCols][nPCodCon]	}	)
            
            cStatus := '2' // Em uso
            
            If Tk380Lock(aLckCont,cStatus)//Trava registros do SU6 como em uso.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A tela de atendimento do Telecobranca, utiliza um array aTlc que          ³
				//³contem os titulos que serao negociados, para preenchimento no atendimento.³
                //³Essa funcao e executada nesse momento, pois antes mesmo de discar para o  ³ 
                //³contato, e necessario saber se a cobranca dos titulos podera ser executada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aItemSel[7] $ "3" //Telecobranca
					lRetCob := Tk380LdCobra(@aTlc, cOperador, aCols[nLiaCols,nPCodEnt],aItemSel[8])  //aTlc,Codigo do Operador,Codigo da Entidade ,Codigo do Atendimento 
                Endif
                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a funcao Tk380LdCobra() retornar .F., significa que nao ha titulos³
				//³para negociacao, portanto a lista devera ser finalizada.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If !lRetCob
			        cStatus := "3" // Encerrado
		        	Tk380Lock(aLckCont,cStatus)		//Encerra o item da LISTA pois nao ha titulos para cobranca
		        	MsgStop(STR0016,STR0001) // "Nao há títulos para serem cobrados pois todos os títulos desse cliente já foram pagos ou os títulos para serem cobrados estão em exceção."	//	"Atenção"
		        	// Para a próxima versão, alterar o Help TMK380STIT substituindo-o pelo texto acima.
					//Help(" ",1,"TMK380STIT")		//"Nao ha titulos para serem cobrados pois todos os titulos desse cliente ja foram pagos."
		        	Return(lRetCob)
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega os campos que compoem o telefones no cadastro de contatos		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTipoTel := Val(SU4->U4_TIPOTEL)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Certifica que o tipo do telefone esta gravado corretamente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTipoTel == 0
					nTipoTel := Val(cTipoTel)
				EndIf
				
				cDDD := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],8,,nTipoTel))	//Codigo do Contato
				cDDI := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],9,,nTipoTel))
				cTel := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],nTipoTel))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao existir telefone cadastrado, percorre o cadastro do contato a fim de identificar um telefone para discagem. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF Empty(cTel)                                
					If !Empty(aCols[nLiaCols][nPCodCon])
						For nTel:= 1 to 5
							cTel := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],nTel))
							If !Empty(cTel)
								Exit
							Endif
					    Next nTel
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o SCRIPT no cabecalho da lista estiver VAZIO nao tem SCRIPT para ser executado. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lCampScpt := !Empty(SU4->U4_SCRIPT) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa as funcoes de discagem  e atualiza o status do item ESCOLHIDO ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Tk380Discar(	cOperador					,cDDI				,cDDD						,cTel			,;	
					 			aCols[nLiaCols][nPCodCon]	,SU6->U6_ENTIDA		,aCols[nLiaCols][nPCodEnt]	,aItemSel[1]	,;
								aCols[nLiaCols][nPCodSeq],nTipoTel)
											
					If !Empty(SU6->U6_REGSLA)   
						Tk061FimSLA(SU6->U6_REGSLA)
					EndIf			
											   				
								
		            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se existir Script Executa. 					 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCampScpt
						lRet := Tk380Script(3				,SU4->U4_CODCAMP			,SU4->U4_SCRIPT     		,aCols[nLiaCols][nPCodCon],;
											SU6->U6_ENTIDA	,aCols[nLiaCols][nPCodEnt]	,NIL                		,NIL             	,;
											cOperador		,aItemSel[1]				,aCols[nLiaCols][nPCodSeq]	,NIL             	,;
											NIL)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso o Script tenha sido trabalhado atualiza o Status do SU6			³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lRet
							cStatus := "3" // Encerrado
							Tk380Lock(aLckCont,cStatus)// Fecha item.
							lRet := .T.
	                    
		   	                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atualiza o historico de marketing 		      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cStatus := "5"  //Executado - STATUS DO HISTORICO DE MARKETING	 			
							Tk400Hist(aItemSel[1],aLckCont[1][2],cStatus)  	
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³RdMake Padrão para transformar Suspects em Prospects através ³
							//³de uma acao de marketing                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SU6->U6_ENTIDA == "ACH"
								If lTMKSUSP
									U_TMKSUSP(aCols[nLiaCols][nPCodEnt])
								Endif	
							Endif
							
						Else
							Tk380Lock(aLckCont,"1")//Libera registros do SU6.
	                 Endif
		
				
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa tela de atendimento receptivo.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Posicione("SUC",1,xFilial("SUC")+SU4->U4_CODLIG,"UC_CODIGO")
						Posicione("SUA",1,xFilial("SUA")+SU4->U4_CODLIG,"UA_NUM")
						Posicione("ACF",1,xFilial("ACF")+SU4->U4_CODLIG,"ACF_CODIGO")
							
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Encerra item da lista porque a tela de atendimento receptivo ja  ³
						//³faz parte de outro fonte e seu resultado nao influencia a agenda.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cStatus := '3' // Encerrado
						Tk380Lock(aLckCont,cStatus)// Fecha item.
	                    lRet := .T.
		                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o historico de marketing 		      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cStatus := "5"  //Executado - STATUS DO HISTORICO DE MARKETING	 			
						Tk400Hist(aItemSel[1],aLckCont[1][2],cStatus)  	
							
						nAuxOpc := 3// Inclusao
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³Apresenta a tela de Atendimento de acordo com o tipo de lista         ³
						//³de contato selecionado.                                               ³
						//³As listas de contatos do tipo "Todos" foram retiradas e substituídas  ³
						//³por "Tmk".                                                            ³
						//³Na versao 7 o sistema avaliava os folders da tela de atendimento      ³
						//³para abertura de acordo com o perfil do operador, porem nao respeitava³
						//³as listas de contatos.                                                ³
						//³Neste versao os dois pontos serao avaliados.                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						If aItemSel[7] == '1' .OR. aItemSel[7] == '4'// TeleMarketing OU Todos.
						
							If !Empty(SU6->U6_NUMOS)
								aAreaOs := GetArea()
								DbSelectAreA("AB6")
								DbSetOrder(1)
								DbSeek(XFilial("AB6")+SU6->U6_NUMOS)
								DbSelectArea("SL2")
								DbSetOrder(1)
								DbSeek(XFilial("SL2")+AB6->AB6_NUMLOJ)
								cAvisoOs := STR0017 //"Os Seguintes Itens Devem Ter Confirmação:"
								Do While !SL2->(Eof()) .AND. AB6->AB6_NUMLOJ == SL2->L2_NUM
									If !Empty(SL2->L2_FDTENTR) .OR. !Empty(SL2->L2_FDTMONT)
										cAvisoOs += CRLF+STR0020+SU6->U6_NUMOS //"O.S. :"
										If !Empty(SL2->L2_FDTENTR)
											cAvisoOs += STR0018+DTOC(SL2->L2_FDTENTR) //" Entrega :"
										EndIf
										If !Empty(SL2->L2_FDTMONT)
											cAvisoOs += STR0019+DTOC(SL2->L2_FDTMONT) // " Montagem :"
										EndIf
									EndIf
									DbSkip()
								End
								RestArea(aAreaOs)											
							EndIf						
						
							//O Operador nao executa Todas as rotinas de atendimento e nao executa tmk.						
							If !(TkGetTipoAte() $ "145") 	
								//Atencao","Este operador não possui acesso ao atendimento TeleMarketing. Verifique suas permissoes."
								Help(" ",1,"TMK380ACEM")

							ElseIf TkGetTipoAte() $ "45" 
								cTipoBkp := TkGetTipoAte()
								//Abre somente a tela de Telemarketing
								TkGetTipoAte("1") 	
								
								Tk380CallCenter(	aLckCont[1][3]	,SU6->U6_ENTIDA		,aCols[nLiaCols,nPCodEnt]	,SUC->(Recno())	,;
													nAuxOpc			,Nil, cAvisoOs)
												
								//Restaura as informacoes anteriores.
								TkGetTipoAte(cTipoBkp)
								 	
							ElseIf TkGetTipoAte() == "1"
								Tk380CallCenter(	aLckCont[1][3]	,SU6->U6_ENTIDA		,aCols[nLiaCols,nPCodEnt]	,SUC->(Recno()),;
													nAuxOpc			,Nil)
							Endif
						
						ElseIf aItemSel[7] == '2' // TeleVendas
						
							//O Operador nao executa Todas as rotinas de atendimento E nao executa tmk.		
							If !(TkGetTipoAte() $ "245")	
								//"Atencao","Este operador não possui acesso ao atendimento Televendas. Verifique suas permissoes."
								Help(" ",1,"TMK380ACET")
							
							ElseIf TkGetTipoAte() $ "4;5"
								cTipoBkp := TkGetTipoAte()
								//Abre somente a tela de Televendas.
								TkGetTipoAte("2") 	
								Tk380CallCenter(	aLckCont[1][3]	,SU6->U6_ENTIDA		,aCols[nLiaCols,nPCodEnt],	SUA->(Recno()),;
													nAuxOpc		   	,Nil)

								//Restaura as informacoes anteriores.
								TkGetTipoAte(cTipoBkp) 	
								
							ElseIf TkGetTipoAte() == "2"
								Tk380CallCenter(	aLckCont[1][3]	,SU6->U6_ENTIDA		,aCols[nLiaCols,nPCodEnt],	SUA->(Recno()),;
													nAuxOpc		   	,Nil)
							Endif
						
						ElseIf aItemSel[7] == '3' // Telecobranca
						
							//O Operador nao executa Todas as rotinas de atendimento e nao executa tmk.
							If TkGetTipoAte() <> "4" .AND.	TkGetTipoAte() <> "3"	

								//Atencao","Este operador não possui acesso ao atendimento Televendas. Verifique suas permissoes."
								Help(" ",1,"TMK380ACEC")
								
								
							ElseIf TkGetTipoAte() == "4"
								//Abre somente a tela de TeleCobranca.
								TkGetTipoAte("3") 	

								Tk380CallCenter(	aLckCont[1][3] 	,SU6->U6_ENTIDA		,aCols[nLiaCols,nPCodEnt], ACF->(Recno()),;
													nAuxOpc			,aTlc)
								TkGetTipoAte("4") 	//Restaura as informacoes anteriores.
								
								
							ElseIf TkGetTipoAte() == "3"
								
								Tk380CallCenter(	aLckCont[1][3]	,SU6->U6_ENTIDA		,aCols[nLiaCols,nPCodEnt], ACF->(Recno()),;
													nAuxOpc		   	,aTlc)
							Endif
						ElseIf aItemSel[7] == '5' // TeleAtendimento
						    
							//O Operador nao executa Todas as rotinas de atendimento E nao executa teleatendimento.		
							If !(TkGetTipoAte() $ "46")	
								//"Atencao","Este operador não possui acesso ao atendimento Televendas. Verifique suas permissoes."
								Help(" ",1,"TMK380ACET")
								
							ElseIf FindFunction("_ISTMKTS") .AND. TkGetTipoAte() $ "4;6" 
								Tk380TeleService(aLckCont[1][3]	,	SU6->U6_ENTIDA	,	aCols[nLiaCols,nPCodEnt],	SU4->U4_CODLIG)								
							Endif						
						Endif
					
	    				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Posiciona SU4 novamente pq o atendimento pode ter desposicionado o alias|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SU4")
						DbSetOrder(1)
						DbSeek(xFilial("SU4") + aItemSel[1])
							
					Endif 
				Else

					Tk380Lock(aLckCont,"1")//Libera registros do SU6.

				Endif
			Endif //Lock
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Lista de Contato Pendente.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (VAL(SU4->U4_FORMA) == PENDENCIA)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa variavel com as informacoes para execucao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aLckCont	:= {}
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera Status do SU6 marcando registro com em uso.³
			//³Listas de voz executam 1 registro por vez.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³aLckCont - Array com os contatos para Lock.³
			//³aLckCont[x][1] = Lista					  ³
			//³aLckCont[x][2] = Codigo Seq. do SU6        ³
			//³aLckCont[x][3] = Contato					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			Aadd(aLckCont,{	aItemSel[1],;
							aCols[nLiaCols][nPCodSeq],;
							aCols[nLiaCols][nPCodCon]	})
			
			cStatus := "2" // Em uso
			
			If Tk380Lock(aLckCont,cStatus)//Trava registros do SU6 como em uso.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A tela de atendimento do Telecobranca, utiliza um array aTlc que          ³
				//³contem os titulos que serao negociados, para preenchimento no atendimento.³
                //³Essa funcao e executada nesse momento, pois antes mesmo de discar para o  ³ 
                //³contato, e necessario saber se a cobranca dos titulos podera ser executada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aItemSel[7] $ "3" //Telecobranca
					lRetCob := Tk380LdCobra( @aTlc, cOperador, aCols[nLiaCols,nPCodEnt],aItemSel[8])  //aTlc ,Codigo do Operador,Codigo da Entidade ,Codigo do Atendimento
                Endif
                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a funcao Tk380LdCobra() retornar .F., significa que nao ha titulos³
				//³para negociacao, portanto a lista devera ser finalizada.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If !lRetCob
			        cStatus := "3" // Encerrado
		        	Tk380Lock(aLckCont,cStatus)	//Encerra o item da LISTA pois nao ha titulos para cobranca
		        	MsgStop(STR0016,STR0001)	//	"Nao há títulos para serem cobrados pois todos os títulos desse cliente já foram pagos ou os títulos para serem cobrados estão em exceção."	// "Atenção"
		        	// Para a próxima versão, alterar o Help TMK380STIT substituindo-o pelo texto acima.
					//Help(" ",1,"TMK380STIT")		//"Nao ha titulos para serem cobrados pois todos os titulos desse cliente ja foram pagos."
		        	Return(lRetCob)
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega os campos que compoem o telefones no cadastro de contatos		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTipoTel := Val(SU4->U4_TIPOTEL)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Certifica que o tipo do telefone esta gravado corretamente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTipoTel == 0
					nTipoTel := Val(cTipoTel)
				EndIf

				cDDD := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],8,,nTipoTel))	//Codigo do Contato
				cDDI := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],9,,nTipoTel))
				cTel := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],nTipoTel))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao existir telefone cadastrado, percorre o cadastro do contato a fim de identificar um telefone para discagem. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF Empty(cTel)                                
					If !Empty(aCols[nLiaCols][nPCodCon])
						For nTel:= 1 to 5
							cTel := AllTrim(TkDadosContato(aCols[nLiaCols][nPCodCon],nTel))
							If !Empty(cTel)
								Exit
							Endif
					    Next nTel
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa as funcoes de discagem  e atualiza o status do item ESCOLHIDO ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Tk380Discar(	cOperador					,cDDI				,cDDD						,cTel			,;
								aCols[nLiaCols][nPCodCon]	,SU6->U6_ENTIDA		,aCols[nLiaCols][nPCodEnt]	,aItemSel[1]	,;
								aCols[nLiaCols][nPCodSeq],nTipoTel)
					
					
					If !Empty(SU6->U6_REGSLA)   
						Tk061FimSLA(SU6->U6_REGSLA)
					EndIf			
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa tela de atendimento receptivo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Posicione("SUC",1,xFilial("SUC")+SU4->U4_CODLIG,"UC_CODIGO")
					Posicione("SUA",1,xFilial("SUA")+SU4->U4_CODLIG,"UA_NUM")
					Posicione("ACF",1,xFilial("ACF")+SU4->U4_CODLIG,"ACF_CODIGO")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ENCERRAMENTO DA LISTA.											    ³
					//³A lista de contato pendente sera encerrada neste momento e caso      ³
					//³ela seja reagendada o fonte TMKA271 ira REABRILA atraves de alteracao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cStatus := "3" // Encerrado
					Tk380Lock(aLckCont,cStatus)// Fecha item.
					lRet := .T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o historico de marketing 		      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cStatus := "5"  //Executado - STATUS DO HISTORICO DE MARKETING
					Tk400Hist(aItemSel[1],aLckCont[1][2],cStatus)
					
					nAuxOpc := 4 // Alteracao
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Apresenta a tela de Atendimento de acordo com o tipo de lista  de contato selecionado ³
					//³As listas de contatos do tipo Todos foram retiradas e substituidas por Tmk.	 		 ³
					//³                                                                      				 ³
					//³Na versão 7 o sistema avaliava os folders da tela de atendimento para abertura de 	 ³
					//³acordo com o perfil do operador, porem nao respeitava as listas de contatos. 		 ³
					//³                                                                      				 ³
					//³Neste versao os dois pontos serao avaliados.                          				 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aItemSel[7] == "1" .OR. aItemSel[7] == "4"	// TeleMarketing OU Todos.
						
						//O Operador nao executa Todas as rotinas de atendimento E nao executa tmk.
						If !(TkGetTipoAte() $ "145")

							//"Atencao","Este operador nao possui acesso ao atendimento TeleMarketing. Verifique suas permissoes."
							Help(" ",1,"TMK380ACM")

						ElseIf (TkGetTipoAte() $ "45")

							cTipoBkp := TkGetTipoAte()
							TkGetTipoAte("1") 	//Abre somente a tela de Telemarketing
							Tk380CallCenter(	aLckCont[1][3]	, SU6->U6_ENTIDA, aCols[nLiaCols,nPCodEnt], SUC->(Recno()),;
												nAuxOpc		   	, Nil)

							TkGetTipoAte(cTipoBkp) 	//Restaura as informacoes anteriores.
							
						ElseIf TkGetTipoAte() == "1"

							Tk380CallCenter(	aLckCont[1][3]	, SU6->U6_ENTIDA	,aCols[nLiaCols,nPCodEnt]	,SUC->(Recno()),;
												nAuxOpc			,Nil)
			
						Endif
						
					ElseIf aItemSel[7] == "2" // TeleVendas
						
						//O Operador nao executa Todas as rotinas de atendimento E nao executa tmk.
						If !(TkGetTipoAte() $ "245")
							Help(" ",1,"TMK380ACET")//"Atenção","Este operador não possui acesso ao atendimento Televendas. Verifique suas permissões."

						ElseIf (TkGetTipoAte() $ "45")
							cTipoBkp := TkGetTipoAte()

							TkGetTipoAte("2") 	//Abre somente a tela de Televendas.

							Tk380CallCenter(	aLckCont[1][3],	SU6->U6_ENTIDA	,aCols[nLiaCols,nPCodEnt]	,SUA->(Recno()),;
												nAuxOpc		   ,Nil)
							TkGetTipoAte(cTipoBkp) 	//Restaura as informacoes anteriores.

						ElseIf TkGetTipoAte() == "2"
							Tk380CallCenter(	aLckCont[1][3],	SU6->U6_ENTIDA	,aCols[nLiaCols,nPCodEnt]	,SUA->(Recno()),;
												nAuxOpc		   ,Nil)
						Endif
						
					ElseIf aItemSel[7] == "3" // Telecobranca
						
						//O Operador nao executa Todas as rotinas de atendimento E nao executa tmk.
						If TkGetTipoAte() <> "4" .AND.	TkGetTipoAte() <> "3"
							//"Atencao","Este operador não possui acesso ao atendimento Televendas. Verifique suas permissoes."
							Help(" ",1,"TMK380ACEC")

						ElseIf TkGetTipoAte() == "4"

							TkGetTipoAte("3") 	//Abre somente a tela de Telecobranca.
							Tk380CallCenter(	aLckCont[1][3],	SU6->U6_ENTIDA	,aCols[nLiaCols,nPCodEnt]		,ACF->(Recno()),;
												nAuxOpc		   ,aTlc)
							TkGetTipoAte("4") 	//Restaura as informacoes anteriores.

						ElseIf TkGetTipoAte() == "3"
							Tk380CallCenter(	aLckCont[1][3]	,SU6->U6_ENTIDA		,aCols[nLiaCols,nPCodEnt]	,ACF->(Recno()),;
												nAuxOpc		   	,aTlc)
						Endif
					ElseIf aItemSel[7] == '5' // TeleAtendimento
					
						//O Operador nao executa Todas as rotinas de atendimento E nao executa teleatendimento.		
						If !(TkGetTipoAte() $ "46")	
							//"Atencao","Este operador não possui acesso ao atendimento Televendas. Verifique suas permissoes."
							Help(" ",1,"TMK380ACET")
						
						ElseIf FindFunction("_ISTMKTS") .AND. TkGetTipoAte() $ "4;6" 
							Tk380TeleService(aLckCont[1][3]	,	SU6->U6_ENTIDA	,	aCols[nLiaCols,nPCodEnt],	SU4->U4_CODLIG)														
						Endif											
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posiciona SU4 novamente pq o atendimento pode ter desposicionado o alias|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SU4")
					DbSetOrder(1)
					DbSeek(xFilial("SU4") + aItemSel[1])
					
				Else
					Tk380Lock(aLckCont,"1")//Libera registros do SU6.
				Endif

			Endif //Lock
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Lista Cross Posting - e-mail³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (VAL(SU4->U4_FORMA) == CROSSPOSTING)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retira a criptografia da senha de e-mail do operador para utiliza-la no envio de e-mail.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If !Empty(cPassword)
				cPassword := Embaralha(cPassword,1)
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe o SMTP Server³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cServer)
				Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
				Return(lRet)
			Endif

			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o email do usuario do sistema esta preenchido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFrom := UsrRetMail(__cUserID)
			If Empty(cFrom)
				Help(" ",1,"TMK380SREM") //"Remetente não informado. Verifique o cadastro do usuário."
				Return(lRet)
			Endif		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa variavel com as informacoes para execucao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aLckCont	:= {}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera Status do SU6 marcando registro com em uso.³
			//³Listas de voz executam 1 registro por vez.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³aLckCont - Array com os contatos para Lock.³
			//³aLckCont[x][1] = Lista					  ³
			//³aLckCont[x][2] = Codigo Seq. do SU6        ³
			//³aLckCont[x][3] = Contato					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            For nCont := 1 To Len(aCols)
	            Aadd(aLckCont,{aItemSel[1],aCols[nCont][nPCodSeq],aCols[nCont][nPCodCon]})
         	Next nCont   
            
            cStatus := "2" // Em uso
            If Tk380Lock(aLckCont,cStatus)//Trava registros do SU6 como em uso.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A tela de atendimento do Telecobranca, utiliza um array aTlc que          ³
				//³contem os titulos que serao negociados, para preenchimento no atendimento.³
                //³Essa funcao e executada nesse momento, pois antes mesmo de discar para o  ³ 
                //³contato, e necessario saber se a cobranca dos titulos podera ser executada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aItemSel[7] $ "3" //Telecobranca
					lRetCob := Tk380LdCobra( @aTlc, cOperador, aCols[nLiaCols,nPCodEnt],aItemSel[8])  //aTlc,Codigo do Operador,Chave,Codigo do Atendimento
                Endif
                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a funcao Tk380LdCobra() retornar .F., significa que nao ha titulos³
				//³para negociacao, portanto a lista devera ser finalizada.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If !lRetCob 
			        cStatus := "3" // Encerrado
		        	Tk380Lock(aLckCont,cStatus)//Encerra o item da LISTA pois nao ha titulos para cobranca
		        	MsgStop(STR0016, STR0001)	//	"Nao há títulos para serem cobrados pois todos os títulos desse cliente já foram pagos ou os títulos para serem cobrados estão em exceção."	\\	"Atenção"
		        	// Para a próxima versão, alterar o Help TMK380STIT substituindo-o pelo texto acima.
					//Help(" ",1,"TMK380STIT")		//"Nao ha titulos para serem cobrados pois todos os titulos desse cliente ja foram pagos."
		        	Return(lRetCob)
				Endif
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a conta e senha do operador nao tenha sido cadastrada³
				//³solicita-os no momento do envio de e-mail.                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If TkAccount(@cAccount,@cPassword)
	         	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica o assunto, mensagem e anexos para o envio do e-mail ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cAssunto := SU4->U4_ASSUNTO
					cMensagem:= MSMM(SU4->U4_CODMENS,80) 
					cAttach  := SU4->U4_ATTACH
									
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrega os e-mails dos usuarios para envio³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SU6")
					DbSetOrder(1)
					If DbSeek(xFilial("SU6") + aItemSel[1])
						While 	(!Eof())							.AND.;
							 	(SU6->U6_FILIAL == xFilial("SU6")) 	.AND.;
							 	(SU6->U6_LISTA == aItemSel[1]	)
						
							cEmail := AllTrim(Posicione("SU5",1,xFilial("SU5") + SU6->U6_CONTATO,"U5_EMAIL")) 

							MsgRun( STR0005,"",;  //"Enviando de E-mail..."
									{ ||lRet:= TkSendMail(	cAccount	,cPassword	,cServer	,cFrom				,;
															cEmail		,cAssunto	,cMensagem	,Alltrim(cAttach)) } )
								
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Identificacao do envio de e-mail atraves do array aSend.        ³
							//³                                                                ³
							//³ Se o retorno for .T. o sistema ira identificar que o -email    ³
							//³foi enviado ao contato XX.(gravacao no array)                   ³
							//³ Se o retorno for .F. o sistema ira identificar que o -email    ³
							//³não foi enviado ao contato XX e irá salvar a informação do      ³
							//³e-mail com problemas no array de resultados. (gravacao no array)³
							//³                                                                ³
							//³Esta identificacao sera utilizada no momento da gravacao        ³
							//³dos resultados da lista e os contatos que nao foram trabalhados ³
							//³ficarao em aberto.                                              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lRet 
							    Aadd(aSend,{SU6->U6_CODIGO,lRet,""})
	        				Else
							    Aadd(aSend,{SU6->U6_CODIGO,lRet,cEmail})
	           				Endif                                        
	           				
							cEmail := ""     

							If !Empty(SU6->U6_REGSLA)   
								Tk061FimSLA(SU6->U6_REGSLA)
							EndIf									
							
							DbSelectArea("SU6")
							DbSkip()
						End 
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualizacao do array aLckCont                               ³
						//³Se o email foi enviado para o contato do array este item    ³
						//³permanecera para ser fechado.                               ³
						//³Caso contrário este item sera retirado do array e o registro³
						//³do contato ficará pendente de Envio de Email no SU6.        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						
						a1AuxLck := {}
						a2AuxLck := {}
						a3AuxLck := {}
						a1AuxLck := aClone(aLckCont)// Trabalha array temporario
						
						For nCont:= 1 To Len(a1AuxLck)
							nPos := Ascan(aSend,{|aVal| aVal[1]== a1AuxLck[nCont][2]})  
							If nPos > 0
								If !aSend[nPos][2] // se nao foi enviado
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³1)Este item do array nao foi executado e nao deve ser fechado, por isso     ³
									//³ele saira do array.                                                         ³
									//³Altera conteudo do array para um valor inexistente.                         ³
									//³Em seguida, exclui o item.                                                  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					        	    Aadd(a3AuxLck, Array(Len(a1Auxlck[nCont])))
					        	    ACopy(a1Auxlck[nCont], a3AuxLck[Len(a3AuxLck)])
					        	    a1Auxlck[nCont][1]:="ZZZZZZ"//Lista
					        	    a1Auxlck[nCont][2]:="ZZZZZZ"//Item do Su6
					        	    a1Auxlck[nCont][3]:="ZZZZZZ"//Contato
						        Endif
						    Endif    
						Next nCont	
						
						For nCont := 1 To Len(a1AuxLck)
							If  a1AuxLck[nCont][1] <> "ZZZZZZ" .AND.;
								a1AuxLck[nCont][2] <> "ZZZZZZ" .AND.;
								a1AuxLck[nCont][3] <> "ZZZZZZ" 
								Aadd(a2AuxLck,a1AuxLck[nCont])
							Endif	
						Next nCont
						
						
				        cStatus := "3" // Encerrado
				 		Tk380Lock(a2AuxLck,cStatus)// Fecha item.
				 		lRet := .T.

				        cStatus := "1" // Liberado				 		
				 		Tk380Lock(a3AuxLck,cStatus)//Libera registros do SU6.
	   	                
	        	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o historico de marketing 		      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cStatus := "7"  //ENVIADO
						For nCont := 1 To Len(a2AuxLck)
							Tk400Hist(aItemSel[1],a2AuxLck[nCont][2],cStatus)  	
						Next nCont
	   	            
	           	    Endif
				Else
	               	Tk380Lock(aLckCont,"1")//Libera registros do SU6.
				Endif	
			Endif //Lock    
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Lista para mala Direta³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (VAL(SU4->U4_FORMA) == MALADIRETA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa variavel com as informacoes para execucao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aLckCont	:= {}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera Status do SU6 marcando registro com em uso.³
			//³Listas de voz executam 1 registro por vez.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³aLckCont - Array com os contatos para Lock.³
			//³aLckCont[x][1] = Lista					  ³
			//³aLckCont[x][2] = Codigo Seq. do SU6        ³
			//³aLckCont[x][3] = Contato					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            For nCont := 1 To Len(aCols)
	            Aadd(aLckCont,{aItemSel[1],aCols[nCont][nPCodSeq],aCols[nCont][nPCodCon]})
         	Next nCont   
            
            cStatus := "2" // Em uso
            If Tk380Lock(aLckCont,cStatus)//Trava registros do SU6 como em uso.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A tela de atendimento do Telecobranca, utiliza um array aTlc que          ³
				//³contem os titulos que serao negociados, para preenchimento no atendimento.³
                //³Essa funcao e executada nesse momento, pois antes mesmo de discar para o  ³ 
                //³contato, e necessario saber se a cobranca dos titulos podera ser executada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aItemSel[7] $ "3" //Telecobranca
					lRetCob := Tk380LdCobra(@aTlc, cOperador, aCols[nLiaCols,nPCodEnt],aItemSel[8])  //aTlc,Codigo do Operador,Chave,Codigo do Atendimento
                Endif
                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a funcao Tk380LdCobra() retornar .F., significa que nao ha titulos³
				//³para negociacao, portanto a lista devera ser finalizada.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If !lRetCob 
			        cStatus := "3" // Encerrado
		        	Tk380Lock(aLckCont,cStatus)	//Encerra o item da LISTA pois nao ha titulos para cobranca
		        	MsgStop(STR0016, STR0001)	//	"Nao há títulos para serem cobrados pois todos os títulos desse cliente já foram pagos ou os títulos para serem cobrados estão em exceção."	//	"Atenção"
		        	// Para a próxima versão, alterar o Help TMK380STIT substituindo-o pelo texto acima.
					//Help(" ",1,"TMK380STIT")		//"Nao ha titulos para serem cobrados pois todos os titulos desse cliente ja foram pagos."
		        	Return(lRetCob)      
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a lista para a impressao da mala direta.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SU6")
				If DbSeek(xFilial("SU6") + aItemSel[1])
					While 	(!Eof())							.AND.;
							(SU6->U6_FILIAL == xFilial("SU6")) 	.AND.;
							(SU6->U6_LISTA == aItemSel[1])

						AAdd(aSend,{	SU6->U6_FILIAL,;				// Filial
										SU6->U6_LISTA,;       			// Lista
										SU6->U6_CODIGO,;				// Codigo
										SU6->U6_FILENT,;				// Chave da Entidade
										SU6->U6_ENTIDA,;				// Filial da Entidade
										SU6->U6_CODENT,;				// Codigo da Entidade
										"1",;							// Origem da Interacao
										SU6->U6_CONTATO,;				// Codigo do Contato
										SU6->U6_DATA,;					// Data
										SU6->U6_HRINI,;			 		// Hora Inicial
										SU6->U6_HRFIM,;			 		// Hora Final
										"1"})					  		// Status da Interacao   
										
						If !Empty(SU6->U6_REGSLA)   
							Tk061FimSLA(SU6->U6_REGSLA)
						EndIf			
									
						DbSkip()
                	End
                
            	    DbSelectArea("SU4")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa a impressao da mala direta e das etiquetas.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := Tk061Mala(SU4->U4_LISTA,SU4->U4_MALADIR,SU4->U4_LABEL,SU4->U4_ETIQUET)  
            		
			        cStatus := "3" // Encerrado
			 		Tk380Lock(aLckCont,cStatus)// Fecha item.
			 		lRet := .T.
    	                
        	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o historico de marketing 		      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cStatus := "8"  //Impresso
					For nCont := 1 To Len(aLckCont)
						Tk400Hist(aItemSel[1],aLckCont[nCont][2],cStatus)  	
					Next nCont

            	
            	Else
                	Tk380Lock(aLckCont,"1")//Libera registros do SU6.
            	Endif
        	Endif //Lock
            
		Case (VAL(SU4->U4_FORMA) == WEBSITE) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para utilizacao de Listas Web.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Permite que as listas web geradas com  tipo WebSite, sejam trabalhadas.      ³
			//³Pode ser enviado o codigo de algum dos tipos de listas acima trabalhados para³
			//³facilitar a customizacao.                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTmkAgWeb
				U_TMKAGWEB(	aItemSel	,aCols	,aHeader	,oGetDados,;	
							nLiaCols)
			Endif
		EndCase

Endif   	
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk380Lock ºAutor  ³Rafael M. Quadrotti º Data ³  01/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Status dos registros do SU6.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: Array com os contatos para Modificacao.              º±±
±±º          ³ExpC1: Status para o qual o registro sera alterado.         º±±
±±º          ³ExpL1: Identifica se os registros ja encerrados poderao ser º±±
±±º          ³alterados.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Agenda do Operador                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk380Lock(aLckCont,cStatus,lForceU6)
Local aArea 	:= GetArea() 			// Salva alias aberto para restauracao posterior
Local lRet		:= .F.					// Retorno da funcao.
Local nFor		:= 0 					// Contador for.
Local aStatus	:= Tk380Box("U6_STATUS")// Retorna as opcoes do campo.
Local cCodOPer	:= TkOperador()

DEFAULT lForceU6 := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³cStatus      ³
//³1- Em Aberto ³
//³2 - Em uso   ³
//³3 - Encerrado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aLckCont - Array com os contatos para Lock.³
//³aLckCont[x][1] = Lista					  ³
//³aLckCont[x][2] = Codigo Seq. do SU6 		  ³
//³aLckCont[x][3] = Contato					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SU6")
DbSetOrder(1)//Codigo da Lista + Codigo Sequencial do SU6 

For nFor := 1 To Len(aLckCont)
	If DbSeek( xFilial("SU6") + aLckCont[nFor][1] + aLckCont[nFor][2] )	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No status 1 o contato pode ser trabalhado normalmente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  SU6->U6_STATUS == "1"
			If SimpleLock()
				Replace SU6->U6_STATUS With cStatus
				If cStatus == "2"
					Replace SU6->U6_CODOPER With cCodOPer
				EndIf
				MsUnLock()
				DbCommit()
				lRet := .T.
			Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No status 2 o contato pode ser trabalhado para 1- Em Aberto ou 3 - Encerrado.³
		//³Porem nunca podera ser locado novamente. 									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf SU6->U6_STATUS == "2"
			//Só permite selecionar um contato em atendimento, se for o mesmo operador.
			If cStatus == "2" .And. SU6->U6_CODOPER <> cCodOPer
				MsgStop(STR0006 + aLckCont[nFor][3] + STR0007  ) //"O contato "###" ja esta sendo utilizado por outra operação."
		    Else
		    	If SimpleLock()
					Replace SU6->U6_STATUS With cStatus 
					If cStatus == "3"
						Replace SU6->U6_CODOPER With cCodOPer 
					ElseIf cStatus == "1" .And. !Empty(SU6->U6_CODOPER)
						Replace SU6->U6_CODOPER With Space(Len(cCodOPer))
					Endif
					MsUnLock()
					DbCommit()
					lRet := .T.
				Endif	
		    Endif

		ElseIf SU6->U6_STATUS == "3"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No status 2 o Registro nao pode ser alterado.								³
			//³Porem ha uma abertura para sua reutilizacao que dependera de um flag enviado ³
			//³para a funcao. Opcao emergencial.											³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			MsgStop(STR0006 + aLckCont[nFor][3] + STR0008  )	 //"O contato "###" ja foi encerrado."
			If lForceU6
				If TmkOk(STR0009+aStatus[Val(cStatus)] +" ? ") //"Deseja alterar seu Status para "
			    	If SimpleLock()
						Replace SU6->U6_STATUS With cStatus 
						MsUnLock()
						DbCommit()
						lRet := .T.
					Endif	
				Endif	
			Endif	
		Endif	
	Endif
Next nFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o Status 3 - Encerramento.                         ³
//³Encerra a lista de voz se nao existirem itens restantes.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cStatus == "3"
	Tk380FechaLista(aLckCont)
Endif

RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk380Discar     º  Autor³Rafael M. Quadrotti     ºData  ³  19/01/04º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a dicagem para listas de Voz.				                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1:Codigo do operador.                                       	 º±±
±±º          ³EXPC2:Codigo do DDI do telefone a ser chamado.                  	 º±±
±±º          ³EXPC3:Codigo do DDD do telefone a ser chamado.                  	 º±±
±±º          ³EXPC4:Numero do telefone a ser chamado.                         	 º±±
±±º          ³EXPC5:Codigo do contato.                                        	 º±±
±±º          ³EXPC6:Codigo da Entidade.(Ex. SA1)                              	 º±±
±±º          ³EXPC7:Chave da entidade. (Chave primaria do alias)              	 º±±
±±º          ³EXPC8:Codigo da lista de contato.                               	 º±±
±±º          ³EXPC9:Codigo do item da lista de Contato.                       	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP8 Lista de Contatos		                                     	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk380Discar(cOperador	,cDDI		,cDDD	,cTel,;
					cCodCont	,cEntidade	,cChave	,cLista,;
					cItem,nTipoTel)

Local cOperEst  := TkPosto(cOperador,"U0_OPEREST")		//Operadora dentro do estado
Local cOperFora := TkPosto(cOperador,"U0_OPEFEST")		//Operadora fora do estado
Local cExterna  := TkPosto(cOperador,"U0_EXTERNA")		//Comando para linha externa
Local cEst	    := SuperGetMv("MV_ESTADO")				//Estado de onde se esta fazendo a ligacao (ATENDIMENTO ATIVO)
Local cDigDDD   := SuperGetMv("MV_TMKDDD")				//Codigo que PRECEDE a discagem DDD - 0 
Local cEstTel   := ""									//Estado PARA onde se esta fazendo a ligacao 	
Local cOperadora:= ""									//Codigo para usar a discagem por uma OPERADORA
Local lRet      := .F.									//Retorno da funcao
Local cDDOri	:= SuperGetMv("MV_TMKFRDD")				//DDD de origem - do cliente usuario
Local lOperadora:= .F.

Local cMun		:= ""                                    	//Municipio do contato/entidade
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³2 Regras para identificar se utiliza o codigo da operadora e compor o numero para discagem:          ³
//³                                                                                                     ³
//³1- Se o DDD da empresa usuaria (MV_TMKFRDD) for diferente da entidade a qual ira realizar a ligacao, ³
//³sera utilizado o codigo da operadora informada no cadastro de grupo de atendimento.                  ³
//³Se deixar esse parametro em branco, vai considerar a proxima regra.                                  ³
//³                                                                                                     ³
//³2- Se o Estado do contato/entidade for o mesmo estado da empresa usuaria protheus,                   ³
//³verifica se os municipios sao os mesmos                                                              ³
//³Se os municipios nao forem os mesmos, indica que vai utilizar o codigo da operadora.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o estado e o municipio esta Localizado o contato ou a entidade.     ³
//³Primeiro verifico para o contato, se nao estiver preenchido verifico da entidade. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCodCont)
	cEstTel	:= TkDadosContato(cCodCont,7)
	cMun	:= TkDadosContato(cCodCont,11)
Endif 

If !Empty(cChave)
	If Empty(cEstTel)
		cEstTel	:= TkEntidade(cEntidade,cChave,4)
	Endif
	If Empty(cMun)
		cMun	:= TkEntidade(cEntidade,cChave,3)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o DDD da entidade for diferente do DDD da empresa usuaria usa os codigos de operadora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cDDOri)
	If TRIM(cDDOri) <> TRIM(cDDD)
		lOperadora := .T.
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se estao no mesmo estado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cEst == cEstTel)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a cidade do cliente (Cobranca) for a mesma do contato nao usa operadora ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ALLTRIM(UPPER(SM0->M0_CIDCOB)) <> ALLTRIM(UPPER(cMun)) .AND. !Empty(SM0->M0_CIDCOB)
			lOperadora := .T.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a cidade do cliente (Entrega) for a mesma do contato nao usa operadora ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIF  ALLTRIM(UPPER(SM0->M0_CIDENT)) <> ALLTRIM(UPPER(cMun)) .AND. !Empty(SM0->M0_CIDENT)
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
	If (cEst == cEstTel) .AND. !Empty(cDDD)
	
		Do Case
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao para quando o parametro MV_TMKFRDD estiver preenchido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case !Empty(cDDOri) .AND. TRIM(cDDOri) <> TRIM(cDDD)
				cOperadora:= cDigDDD + cOperEst + cDDD
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao apenas do estado  e DDD³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Case Empty(cDDOri) 
    			cOperadora:= cDigDDD + cOperEst + cDDD 
    		
    		OtherWise	
				cOperadora:= cDigDDD + cOperEst
				
    	EndCase		
	    
	ElseIf (cEst <> cEstTel) .AND. !Empty(cDDD)
        
		cOperadora:= cDigDDD + cOperFora + cDDD

	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o numero a ser discado por Modem / CTI              ³
//³Digito Externo + Operadora + Telefone (DDI + DDD + Numero)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTel := AllTrim(cExterna) + AllTrim(cOperadora)+ AllTrim(cTel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa as funcoes de discagem. e atualiza o status da chamada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SGMnuAtivo(cTel,cEntidade,cChave,cCodCont,,,,,,,,,,,,,,,,,,nTipoTel) 
	lRet := .T. 
Else
	Tk380Falha(cLista,cItem)
Endif

Return(lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK380Falha    ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 19/01/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe as possiveis falhas para o historico de marketing			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Expc1: Codigo da lista de contatos                             	 ³±±
±±³          ³Expc2: Codigo do item da lista de contatos                     	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP8 Agenda do operador                                        	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Hanna C.  ³11/09/07³131694³A tela nao pode ser encerrada sem que antes o ope- ³±±
±±³          ³        ³      ³dor selecione um motivo. Nao sera possivel encerrar³±±
±±³          ³        ³      ³a tela utilizando o botao Esc ou clicando-se no 'X'³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk380Falha(cLista,cItem)
Local oDlg			 									// Janela principal.
Local aFalha:= {STR0011,STR0012,STR0013,STR0014} 		// Tipos de Erros na discagem - "Ocupado","Erro","Falha","Sem Linha"
Local nFalha:= 0										// Posicao da falha determinada
Local oFalha 											// Objeto de tela

DEFINE MSDIALOG oDlg FROM 00,00 TO 200,300 TITLE STR0015 PIXEL OF oMainWnd STYLE DS_MODALFRAME STATUS //"Status da Discagem"

    @ 05,05 TO 80,145 LABEL "" OF oDlg PIXEL
	@ 10,10 RADIO oFalha VAR nFalha PROMPT aFalha[1],aFalha[2],aFalha[3],aFalha[4] OF oDlg SIZE 130,16 PIXEL

	DEFINE SBUTTON FROM 83 ,115 TYPE 1 PIXEL ACTION (IIF (nFalha <> 0, (Tk400Hist(cLista,cItem,StrZero(nFalha,1)),oDlg:End()), .F. )) ENABLE OF oDlg
	oDlg:LESCCLOSE := .F.
  
ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)                                                    



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK380FechaLista³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 19/01/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia e encerra SU4.                                        	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³Expa1: Array com os dados dos registros reservados.            	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Michel M. ³21/06/07³710   ³BOPS 127864 - Verifica se o parametro aLckCont     ³±±
±±³          ³        ³      ³recebido e um array.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³AP8 Agenda do operador                                        	 ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk380FechaLista(aLckCont)
Local lRet   := .F.   			 // Flag que define se a lista sera encerrada.
Local aArea  := GetArea("SU4")	 // Salva alias para posterior restauracao
Local lFecha := .T.				 // Identifica se a lista deve ser encerrada.


If 	Len(aLckCont) > 0 .AND.;
	Len(aLckCont[1]) > 0

	DbSelectArea("SU6")
	DbSetOrder(1)
	
	#IfDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Filtra todas as atividades para o operador na database.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery:=	" SELECT *" +;
					" 	FROM " + RetSqlName("SU6") + " SU6 " 				+;
					" 	WHERE	U6_FILIAL = '" + xFilial("SU6") + "' AND "	+; 
					" 			U6_LISTA = '" + aLckCont[1][1]  + "' AND "  +;
					" 			U6_STATUS <> '3' AND " 						+;
					" 			D_E_L_E_T_ <> '*'" 
		cQuery+=	" ORDER BY U6_FILIAL,U6_LISTA,U6_CODIGO"
			
		cQuery := ChangeQuery(cQuery)
		DbSelectArea("SU6")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SU6", .F., .T.)
	#ELSE	
		DbSeek(xFilial("SU6")+aLckCont[1][1]) 
	#ENDIF
	
	While ((!Eof()) .AND. (SU6->U6_LISTA == aLckCont[1][1]))
		If	SU6->U6_STATUS <> "3"  // Diferente de nao executado
			lFecha := .F.
		    Exit
		Endif
	
		DbSkip()
	End
	
	#IFDEF TOP
		DbSelectArea("SU6")
		DbCloseArea()
		ChkFile("SU6")
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encerra a Lista de Contatos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFecha
		lRet := .T.
		DbSelectArea("SU4")
		DbSetOrder(1)
		If DbSeek(xFilial("SU4") + aLckCont[1][1])
			RecLock("SU4",.F.)
			Replace SU4->U4_STATUS With "2" //Lista Encerrada
			MsUnLock()
			DbCommit()
	
			If !Empty(SU4->U4_OPERAD)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza tarefa no SU7 - Operador³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Tk380TarefaU7(SU4->U4_OPERAD) 	// Subtrai em um o U7_TAREFA que gerencia a quantidade de tarefas do Operador.
			Endif	
		Endif	
	Endif
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk380LdCobra   ³Autor  ³ Andrea Farias         ³ Data ³ 31/03/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao executada ao confirmar o item da lista antes de discar para ³±±
±±³          ³o contato. 														 ³±±
±±³			 ³1)Tem como objetivo carregar os titulos vencidos do cliente em 	 ³±±
±±³          ³array para preenchimento dos itens da tela de atendimento ativo de ³±± 
±±³          ³Telecobranca. 			                                         ³±±
±±³          ³2)Se todos os titulos do cliente foram pagos, o item da lista sera ³±±
±±³          ³encerrado e o atendimento nao sera executado.                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array que contera os dados dos titulos para atendimento TLC ³±±
±±³          ³ExpC2: Codigo do Operador que ira executar a lista             	 ³±±
±±³          ³ExpC3: Chave da Entidade                                       	 ³±±
±±³          ³ExpC4: Codigo do Atendimento Pendente                          	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP811																 ³±±
±±³          ³                                                                 	 ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                                ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³28/10/05³811   ³BOPS 87882 - Basear-se nos titulos existentes na   ³±±
±±³          ³        ³      ³tabela SK1 quando nao existir atendimento.         ³±±
±±³Conrado Q.³06/11/06³811   ³BOPS 112303 - Quando o titulo do cliente esta em   ³±±
±±³          ³        ³      ³exceção não adiciona-o para cobrança.              ³±±
±±ÈÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk380LdCobra(aTlc , cOperador, cChave,cAtend)

Local lRet		:=.F.																// Retorno da Funcao
Local aArea		:= GetArea()														// Salva a area atual
Local cFilOrig	:= ""																// Filial de origem do titulo	
Local cCliente	:= Trim(Substr(cChave,1,TAMSX3("UA_CLIENTE")[1]))					// Codigo do Cliente
Local cLoja		:= Trim(Substr(cChave,(TAMSX3("UA_CLIENTE")[1])+1,LEN(cChave)))		// Codigo da Loja

If !Empty(cAtend)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o conteudo da chave com o codigo do cliente e loja³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCliente) .AND. !Empty(cLoja)
                     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se todos os titulos do atendimento estao pagos. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Tk280Pago(cAtend,cOperador,cCliente,cLoja)
			lRet:= .F.
			Return(lRet)
		Endif	
	Endif
Endif
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando for uma pendencia, carrega o array aTlc de acordo com os titulos gra- ³
//³vados no atendimento, caso contrario, carrega os titulos vencidos existentes.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cAtend)
	DbSelectArea("ACG") 
	DbsetOrder(1)
	If Dbseek(xFilial("ACG")+cAtend) 	
		While !Eof() .AND. 	ACG->ACG_FILIAL == xFilial("ACG") .AND. ;
							ACG->ACG_CODIGO	== cAtend

			Aadd(aTlc, {ACG->ACG_PREFIX,;
		 				ACG->ACG_TITULO,;
						ACG->ACG_PARCEL,;
						ACG->ACG_TIPO,;
						ACG->ACG_FILORI})  //Filial de origem do titulo
	    
			DbSelectArea("ACG")
			Dbskip()
		End
		
	Endif

Else
	DbSelectArea("SK1")
	DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
	If DbSeek(xFilial("SK1") + Alltrim(cChave))
		While	!Eof()							.AND.;
			SK1->K1_FILIAL 	== xFilial("SK1")	.AND.;
			Alltrim(SK1->K1_CLIENTE + SK1->K1_LOJA) == Alltrim(cChave)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o título está em exceção.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SK1->K1_OPERAD == "XXXXXX"
				SK1->(DbSkip())
				Loop
			Endif

			cFilOrig	:= K1_FILORIG

			DbSelectarea("SE1")
			DbSetOrder(1)
			If DbSeek(cFilOrig + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO)
				Aadd(aTlc,{	SE1->E1_PREFIXO	,;		// 01-Prefixo
			 			 	SE1->E1_NUM		,;		// 02-Numero
							SE1->E1_PARCELA	,;		// 03-Parcela
							SE1->E1_TIPO	,;		// 04-Tipo
							cFilOrig}) 				// 05-Filial Origem
            Endif
			
			DbSelectArea("SK1") 
			Dbskip()
		End
	Endif	
Endif
	                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o array contiver titulos para serem cobrados, significa que   ³
//³existem titulos para cobranca, caso contrario, a  funcao retorna ³ 
//³.F. e a tela de atendimento nao sera aberta.			  			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTlc) > 0
	lRet:=.T.
Endif
	
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk380TarefaU7 ºAutor  ³Rafael M. Quadrotti º Data ³  07/15/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a tarefa no SU7 para o operador.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Codigo do operador                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk380TarefaU7(cOperador)

Local lRet   := .F.				// Retorno da funcao
Local aSArea := GetArea()		// Salva a area
Local nVal   := 0				// Contador auxliar

DbSelectArea("SU7")
DbSetOrder(1)
If DbSeek(xFilial("SU7")+ cOperador)
    nVal := SU7->U7_TAREFA
   
    If nVal > 0 
 	   nVal--
	Endif
		
	RecLock("SU7",.F.)
	Replace U7_TAREFA  With  nVal
	MsUnlock()
	DbCommit()
	lRet := .T.
Endif

RestArea(aSArea)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk380TeleServiceºAutor³ Vendas Cliente     º Data ³  18/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametos ³ExpC1: Codigo do contato                                 		  º±±
±±º          ³ExpC2: Entidade (alias)                               		  º±±
±±º          ³ExpC3: Chave primaria da entidade          			          º±±
±±º          ³ExpN4: Registro                       	                      º±±
±±º          ³ExpN5: Opcao da tela de atendimento.	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk380TeleService(cCodCont,	cEntidade,	cChave,	cSU4CodLig)
Local oObj			:= TeleServiceUserDialog():New()								// Objeto interface de atendimento do TeleAtendimento
Local nAuxOpc
Private aHeader		:= {}		//Array contendo o cabecalho dos campos
Private aCols 		:= {}		//Array com os itens do atendimento incluidos na MsGetDados   

oObj:service := TeleServicing():New() 
If oObj:service:load( oObj:GetModel() )
								
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona a tabela do teleatendimento no registro do atendimento pendente |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
	DbSelectArea(oObj:service:tableStructureInfo:master:alias)
	DbSetOrder(1)
	nAuxOpc := 3 
	If DbSeek(xFilial(oObj:service:tableStructureInfo:master:alias) + cSU4CodLig)								
		nAuxOpc := 4 
	EndIf         
	
	If nAuxOpc == 3
		INCLUI := .T.   
		ALTERA := .F.
	Else
		INCLUI := .F.
		ALTERA := .T.
	Endif	
	             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia o atendimento |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
	oObj:lReadOnly := .F. 
	oObj:SetInfo(cCodCont, cEntidade, cChave)
	If oObj:showDialog("Atendimento Ativo", nAuxOpc)	//"Alterar" //"Alterar"
		oObj:service:tableStructureInfo:save()
		oObj:service:whenRecorded:execute({aHeader,aCols,nAuxOpc})
	EndIf  
EndIf
Return Nil
