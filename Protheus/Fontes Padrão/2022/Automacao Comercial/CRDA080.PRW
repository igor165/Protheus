#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA080.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "CRDDEF.CH"

Static oTimerCrd                   //Objeto do timer 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRDA080   ³ Autor ³Viviane M. Fernandes   ³ Data ³05.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de clientes bloqueados por crédito, ordenado de    ³±±
±±³          ³acordo com a  data e hora de bloqueio.                      ³±±
±±³          ³Chamada da tela de desbloqueio de crédito, pela rotina do   ³±±
±±³          ³menu "Analiza próx".					                  	  ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³								                       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³15/06/05  ³Kotaki/Machima ³Retirada do filtro da mBrowse para mostrar  ³±±
±±³          ³               ³todos os registros do cadastro de credito.  ³±± 
±±³          ³               ³Apresentar a legenda para os status bloquea-³±± 
±±³          ³               ³do e nao-bloqueado. Criacao do PE CRD080LIB ³±± 
±±³03/03/06  ³Andrea F.      ³BOPS 94380 - Tratar o filtro na Mbrowse para³±±
±±³          ³               ³base de dados AS400.                        ³±± 
±±³03/06/06  ³Machima        ³BOPS 100947 - Correcao para nao permitir que³±±
±±³			 ³				 ³2 ou mais analistas avaliem o mesmo cliente ³±±
±±³02/08/06  ³Machima        ³BOPS 104402-Nao permitir que dois analistas ³±±
±±³			 ³				 ³avaliem o mesmo cliente                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDA080()

Local lAS400	 	:= TcSrvType() == "AS/400"								// Identifica se o banco de dados eh AS400
Local aCores        := {{"MA7->MA7_BLOQUE == '1'" , "BR_VERMELHO"   },;  	// Bloqueado - VERMELHO
						{"MA7->MA7_BLOQUE <> '1'" , "BR_VERDE"      }}    	// Nao-bloqueados - VERDE

Private aRotina 	:= MenuDef()
Private cCadastro	:= STR0002			   						    		// Titulo da rotina - "Classificação de cliente"
Private cString  	:= "MA7"
Private oCrdMBrowse                                                 		// Objeto da mBrowse

DbSelectArea("MA7")
DbSetOrder(4)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando  estiver utilizando o banco de dados AS400 a opcao de filtro da³
//³mbrowse nao estara disponivel. O filtro devera ser tratado na Mbrowse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAS400
	DbSeek(xFilial("MA7"))
	MBrowse( 06, 01, 15, 75, "MA7",,,,,,,"CRDA080Top","CRDA080Bot",,{|| CrdAtualiza() } )
Else
	DbSeek(xFilial("MA7"),.T.)
	MBrowse( 06, 01, 15, 75, "MA7",,,,,,aCores,,,,{|| CrdAtualiza() } )
Endif	

If ValType(oTimerCrd) == "O"
   oTimerCrd:DeActivate()	
EndIf  

Return (NIL)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 13.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CRDA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina  := {	{STR0001 ,"CRA080Aval"    ,0 ,2 ,0 ,.T. } ,;				// Rotinas do menu da funcao //"Analisa Próx."
						{STR0025 ,"CRA080Legenda" ,0 ,2 ,0 ,.T. } } 		   		//"Legenda"
	Local aRotAdic := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("CRD080ROT")
		aRotAdic := ExecBlock("CRD080ROT", .F., .F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdAtualizºAutor  ³Microsiga           º Data ³  06/15/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualizacao do browse para apresentar os registros de cadas-º±±
±±º          ³tro do credito                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CrdAtualiza(oCrdMBrowse)

If oTimerCrd == NIL
	DEFINE TIMER oTimerCrd INTERVAL 10000 ACTION ( CRDTimer() ) OF GetWndDefault()	  	
	oTimerCrd:Activate()	
Endif	

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDTimer  ºAutor  ³Microsiga           º Data ³  06/15/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Execucao do timer para atualizacao do browse                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDTimer(nRecnoMA7)

Local lAS400		:= .F.
DEFAULT nRecnoMA7   := 0

// Alterado a atribuição da variável, pois estava dando erro de compilação "Never used"
lAS400		:= TcSrvType() == "AS/400"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Comandos para executar o refresh no browse de maneira ³
//³a mostrar ao avaliador o status de credito atualizado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCrdMBrowse := GetObjBrow()
oCrdMBrowse:ResetLen()
#IFDEF TOP
	If lAS400
		oCrdMBrowse:SetFilter(IndexKey(),CRDA080Top(),CRDA080Bot())
  	Else
		SetMbTopFilter("MA7","")      
	Endif	
#ELSE	
	oCrdMBrowse:SetFilter(IndexKey(),,)
#ENDIF	
oCrdMBrowse:GoTop()
oCrdMBrowse:Default()
oCrdMBrowse:Reset()
oCrdMBrowse:Refresh()
sysrefresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Re-posiciona no registro do cliente avaliado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRecnoMA7 > 0
   MA7->(DbGoto(nRecnoMA7))
EndIf   

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³ CRA080Aval  ºAutor³Microsiga           º Data ³  05/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Avaliacao do credito                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³SIGACRD												      º±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³               Alteracoes desde sua criacao                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA  ³ Programador   ³BOPS  ³Manutencao Efetuada                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³17/04/06 ³Marcos Roberto ³DELLA ³Incluido os parametro cliente e loja  º±±
±±³         ³               ³VIA   ³na chamada da funcao CRM010_006 para  º±± 
±±³         ³               ³      ³forcar a busca do mesmo cli. no SA1   º±± 
±±º04/04/07 ³Conrado Quilles³122711|Alterada a utilização da chamada      º±±
±±º         ³               ³      |SubStr(cUsuario,7,15) por cUserName   º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRA080Aval(cAlias, nRecno, nOpc )

Local aArea		:= GetArea()           		// Salva area de trabalho
Local nTipo 	:= 3             			// Liberação para efetivação  (mesma tela do ntipo 1 com a opcao de liberar crédito)
Local nRecnoMA7 := 0                       	// Recno no registro do MA7 para re-posicionamento na funcao CrdTimer()
Local nRecnoMAR := 0                       	// Recno do MAR gerado pelo CRDA080
Local cCliente	:= ""                      	// Codigo do cliente
Local cLoja   	:= ""                  		// Loja
Local lRet		:= .F.						// Retorno Default
Local cMV_LibNiv:= SuperGetMv("MV_LIBNIV") 	// Nivel minimo do usuario para liberacao de credito.
Local lErro		:= .F.						// Flag de controle de erro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o nivel do usuario logado for menor que a permissao de avalicao CONFIGURADA  ³
//³pelo MV_LIBNIV para o analista de Credito nao permite avaliar a proxima venda   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cNivel < cMV_LibNiv
	Msgstop(STR0003, STR0004) //"Usuario sem permissão de liberar crédito para cliente","Usuário sem Permissão de liberação"
Else
	DbSelectArea("MA7")
	DbSetOrder(4)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³IMPORTANTE: NAO trocar este comando por MsSeek porque em algumas situacoes   ³
	//³o cache do registro nao estava com o status Bloqueado, assim, foi "forcado" a³
	//³buscar na base para evitar esta situacao - Machima					        ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DbSeek(xFilial( "MA7" ) + "1" )	// Procura pelo primeiro cadastro de credito bloqueado
	
		While !Eof() .AND. MA7->MA7_BLOQUE == "1"
			// Se for possivel fazer um lock no registro liberar para a analise de credito
			If CRDSEMABLO( "CRDA080"  ,Recno()  ,@nRecnoMAR )
			    nRecnoMA7  := MA7->(Recno())
				lErro := .F.
				Exit
			Else
				lErro := .T.
			Endif			
			MA7->(DbSkip())
		End         
		CrdTimer(nRecnoMA7)						
	Else
		MsgStop(STR0005,STR0006) //"Não há registros para serem liberados.""Atenção !"
		CrdTimer()				
		Return(lRet)
	Endif

	If lErro
		MsgStop( STR0007, STR0008 ) //"Todos os créditos estão sendo analisados ou não existem registros para liberação.","Atenção"
		CrdTimer()				
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o cadastro de credito nao estiver BLOQUEADO sai da funcao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MA7->MA7_BLOQUE <> "1"
		Return(lRet)
	Endif
	
	cCliente:= MA7_CODCLI
	cLoja   := MA7_LOJA
	RegToMemory("MA7",.F.)
	
	DbSelectArea("SA1")
	Dbsetorder(1)
	If DbSeek(xFilial("SA1")+cCliente+cLoja)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esse regtomemory garante a abertura do cadastro de clientes para a tela de avaliacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RegToMemory("SA1",.F.)
	
		//Chamada da rotina de liberacao de credito ( nTipo possui valor 3 )
		CRM010_006(	nTipo		,; 	//01 Tipo de operacao
					cCliente	,;	//02 Codigo do cliente 
					cLoja		,;	//03 LOJA 
					nRecnoMAR	,; 	//04 Numero do registro no MAR
					.T.)			//05 Utilizado para diferenciar a mensagem do botao Ok
	
		// Liberar o bloqueio do registro (semaforo)
		DbSelectArea("MAR")
		If nRecnoMAR > 0
		   DbGoto(nRecnoMAR)
		   ConOut("4. CRDA080 - Exclui registro no MAR. Recno: " + MAR->MAR_REGIST + ;
	       	   	   " Rotina: " + MAR->MAR_ROTINA + " Usuario MAR: " + MAR->MAR_USUARI + ;
	       	   	   " Usuario: " + cUserName + ;
	       	   	   " Cliente: " + cCliente+"/"+cLoja)		   
		Endif
		RecLock("MAR",.F.)
		DbDelete()
		MsUnlock()
		
		WriteSx2("MAR")

		lRet := .T.
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a area antes de chamar a funcao CrdTimer() porque ela tem  ³
//³que atualizar o browse posicionado no ALIAS MA7.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

CrdTimer()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³ CRA080_002  ºAutor³Viviane M. Fernandesº Data ³  05/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Ao confirmar a liberacao de credito, ele processará esta    º±±
±±º         ³ rotina para retirar o status de pendente do cliente         º±±
±±º         ³ saindo da visualizacao ou da liberacao de credito           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPN1: Tipo da Consulta/Liberação                            º±±
±±º         ³EXPC2: Cliente a ser liberado                                º±±
±±º         ³EXPC3: Loja                                                  º±±
±±º         ³EXPN4: Valor a que deve ser liberado                         º±±
±±º         ³EXPC5: Valor do combo(se escolheu SIM ou NAO)                º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP7-Telecobrança-Cadastro de Questionário Socio Ecom. socialº±±
±±ÃÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA  ³ Programador   ³Manutencao Efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³01/09/06 ³Marcos Roberto ³Alteracao para gravar o codigo do usuario    ³±±
±±³         ³               ³que liberou/rejeitou o credito               ³±± 
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRA080_002(	nTipo	, cCliente	,cLoja	, nExcedido	,;
						cCombo	, nValor )

Local cLinha 		:= ""
Local nSaldo 		:= IIf(SuperGetMv("MV_LIMMAX")>0, ( (SA1->A1_LC * SuperGetMv("MV_LIMMAX") )/100) ,0)
Local cMotTra 		:= Space(50)
Local lRetMsgGet2	:= .T.         
Local cUserCrd		:= ""								//Variavel utilizada para armazenar o codigo do usuario que sera gravado na tabela MAH
Local nMvCRDStat	:= SuperGetMV("MV_CRDSTAT",,1)		//Retorna se a busca do status vai ser via RPC ou Web Service


// Se for a consulta do cliente nao repassar os dados             
If nTipo == 2
	Return .T.
Endif          
// Armazena o codigo do usuario
cUserCrd := CRDX080USR()

DbSelectArea("MA7")
DbSetorder(1)

If DbSeek(xFilial("MA7")+cCliente+cLoja)
	
	// Verificar se o status continua como bloqueado ou transferido para o crediario
	If MA7->MA7_BLOQUE <> "1" .AND. MA7->MA7_BLOQUE <> "4"
		MsgStop(STR0009) //"Esta venda foi cancelada."
		Return .T.
	Endif
	
	If nExcedido > nSaldo .AND. cCombo == STR0013  //"SIM"
		cLinha := STR0010+Chr(13)+Chr(10) //"O valor ultrapassa o limite permitido de liberação. "
		cLinha += STR0011 + TransForm( nSaldo,"@E 99,999,999.99" )+Chr(13)+Chr(10) //"Valor Permitido para liberação: "
		cLinha += STR0012+TransForm(nValor,"@E 99,999,999.99")+Chr(13)+Chr(10) //"Valor a ser liberado: "
		cLinha += STR0023+TransForm(nExcedido,"@E 99,999,999.99") //"Valor excedido: "
		MsgStop(cLinha,STR0006) //"Atenção !"
		
		Return .F.
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a tela de observacao de usuario quando for passar para o crediario³
		//³DELLA VIA                                                               ³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCombo <> STR0013 .And. cCombo <> STR0015   //"SIM"###"NAO"
			cMotTra 	:= Space(50)
			lRetMsgGet2	:= .T.
			While lRetMsgGet2 .And. Empty(cMotTra)
				lRetMsgGet2 := MsgGet2(STR0017,STR0018,@cMotTra,,{|| .t.}) //'Transferência para crediário'###"Qual o motivo da transferência:"
				If lRetMsgGet2 .And. Empty(cMotTra)
					MsgStop(STR0019) //"Digite a mensagem para o analista do crediário."
				Endif
			End
		Endif
	
		Begin Transaction
		
		If Reclock("MA7",.F.)
			
			/*
			Status do MA7_BLOQUE
			status "1" - bloqueado
			status "2" - desbloqueado
			status "3" - Rejeitado
			status "4" - Crediario
			status "0" - valor volta a ser 0 no momento da venda
			*/
			If cCombo == STR0013  //"SIM"
				
				// limpando os registros do MA7
				DbSelectArea("MA7")
				
				M->MA7_BLOQUE := MA7->MA7_BLOQUE :=  Str(DESBLOQ,1)
				M->MA7_MOTBL  := MA7->MA7_MOTBL  :=  STR0014 //"Liberado pelo Analista de Crédito"
				
				M->MA7_DATABL := MA7->MA7_DATABL :=  dDatabase
				M->MA7_HORABL := MA7->MA7_HORABL :=  Time()
				M->MA7_USRBL  := MA7->MA7_USRBL  :=  substr(Alltrim(cUsuario),1,15)
				
				M->MA7_VLRBL  := MA7->MA7_VLRBL  :=  0
				M->MA7_DTHSDS := MA7->MA7_DTHRDS :=  Inverte(MA7->MA7_DATABL) + Inverte(StrTran(MA7_HORABL,":",""))
				
				M->MA7_LC     := MA7->MA7_LC     :=  nValor
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o status do contrato para Liberado para diferenciar do contrato que nao foi enviado ao ³
				//³Crediario																					   ³				
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTipo == 3 				
					DbSelectArea("MAH")
					DbSetorder(1)
					If DbSeek(xFilial("MAH")+MA7->MA7_CONTRA)					
					   RecLock("MAH",.F.)
					   Replace MAH->MAH_STATUS	With Str(ST_LIB,1)  
					   If MAH->(FieldPos("MAH_USRCRD")) > 0
					      Replace MAH->MAH_USRCRD	With cUserCrd
					   Endif	
					   MsUnlock()
					Endif				
				Endif
			Elseif cCombo == STR0015  //"NAO"
				If ExistBlock("CRD0801")
					lRet := ExecBlock("CRD0801",.F.,.F.)
				Else
					M->MA7_BLOQUE := MA7->MA7_BLOQUE :=  Str(REJEITADO,1)
					M->MA7_DATABL := MA7->MA7_DATABL :=  dDatabase
					M->MA7_HORABL := MA7->MA7_HORABL :=  Time()
					M->MA7_USRBL  := MA7->MA7_USRBL  :=  substr(Alltrim(cUsuario),1,15)
					M->MA7_VLRBL  := MA7->MA7_VLRBL  :=  0
					M->MA7_DTHSDS := MA7->MA7_DTHRDS :=  Inverte(MA7->MA7_DATABL) + Inverte(StrTran(MA7_HORABL,":",""))
					M->MA7_LC     := MA7->MA7_LC     :=  0
					If FunName() = "CRDA180"
						M->MA7_MOTBL  := MA7->MA7_MOTBL  :=  STR0024   //"Rejeitado pela Fila de Crediario"
					Else
						M->MA7_MOTBL  := MA7->MA7_MOTBL  :=  STR0016   //"Rejeitado pelo Analista de Crédito"
					Endif
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o status do contrato para Rejeitado para controle de re-avaliacao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTipo == 3   
					
					DbSelectArea("MAH")
					DbSetorder(1)
					If DbSeek(xFilial("MAH")+MA7->MA7_CONTRA)					
					   RecLock("MAH",.F.)
					   Replace MAH->MAH_STATUS	With Str(ST_REJ,1)
					   If MAH->(FieldPos("MAH_USRCRD")) > 0
					      Replace MAH->MAH_USRCRD	With cUserCrd
					   Endif	
					   MsUnlock()
					Endif				
				Endif				
			Else				
				If lRetMsgGet2
					M->MA7_BLOQUE := MA7->MA7_BLOQUE :=  Str(CREDIARIO,1)
					M->MA7_MOTBL  := MA7->MA7_MOTTRA  :=  cMotTra
					
					M->MA7_DATABL := MA7->MA7_DATABL :=  dDatabase
					M->MA7_HORABL := MA7->MA7_HORABL :=  Time()
					M->MA7_USRBL  := MA7->MA7_USRBL  :=  Substr(Alltrim(cUsuario),1,15)
					
					//Nao deve ser alterado o valor do bloqueio quando for para crediario
					M->MA7_VLRBL  := MA7->MA7_VLRBL
					
					M->MA7_DTHSDS := MA7->MA7_DTHRDS :=  Inverte(MA7->MA7_DATABL) + Inverte(StrTran(MA7_HORABL,":",""))
					M->MA7_LC     := MA7->MA7_LC     :=  0
					
					DbSelectArea("MAH")
					DbSetorder(1)
					If DbSeek(xFilial("MAH")+MA7->MA7_CONTRA)
					   RecLock("MAH",.F.)
					   Replace MAH->MAH_STATUS 	With Str(ST_CRED,1)
					   If MAH->(FieldPos("MAH_USRCRD")) > 0
					      Replace MAH->MAH_USRCRD	With cUserCrd
					   Endif	
					   MsUnlock()
					Endif				 
				Endif
			Endif
			DbSelectArea("MA7")										
			MsUnlock()
			
			If ExistBlock("CRD080GRV")
				ExecBlock("CRD080GRV",.F.,.F.,{cCombo})
			Endif

			MA7->(FkCommit())

			If nMvCRDStat == 1			
				CRD080Status( cCliente, cLoja )
			EndIf	
		Else
			MsgStop(STR0020, STR0021) //"Dados complementares do cliente sendo analisado por outro usuário"###"Cliente em atualização"
		Endif
		
		End Transaction		
	Endif
Else
	MsgStop(STR0022) //"Cliente nao encontrado"
Endif

If ExistBlock("CRD080LIB")
	ExecBlock("CRD080LIB",.F.,.F.,{cCombo})
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDSEMABLOºAutor  ³Vendas Clientes     º Data ³  09/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe algum usuario utilizando do mesmo regis-º±±
±±º          ³ tro.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Rotina chamadora                                   º±±
±±º			 ³ ExpN2 - Recno do MA7										  º±±
±±º			 ³ ExpN3 - Recno do MAR para controle do lock de cliente      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDSEMABLO( cRotina  ,nRegistro  ,nRecnoMAR )

Local aArea    := GetArea()         // Area atual
Local lRet     := .T.               // Indica se registro no MAR esta bloqueado por outro usuario

DbSelectArea("MAR")
DbSetOrder(1)
cRotina := cRotina + Space(Len(MAR->MAR_ROTINA)-Len(cRotina))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³*** Nao substituir por MsSeek ***³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DbSeek(xFilial("MAR")+cRotina+StrZero(nRegistro,10,0))
	RecLock("MAR",.T.)
	Replace MAR->MAR_FILIAL With xFilial("MAR")
	Replace MAR->MAR_ROTINA With cRotina
	Replace	MAR->MAR_USUARI With cUserName
	Replace MAR->MAR_REGIST With StrZero(nRegistro,10,0)
	MsUnlock()
	nRecnoMAR       := Recno()
	ConOut("1. CRDA080 - Inclui novo registro no MAR. Recno: " + MAR->MAR_REGIST + ;
	       " Rotina: " + MAR->MAR_ROTINA + " Usuario: " + MAR->MAR_USUARI + ;
	       " Cliente: " + MA7->MA7_CODCLI+"/"+MA7->MA7_LOJA)		   
ElseIf AllTrim(cUserName) <> AllTrim(MAR->MAR_USUARI )
	ConOut("2. CRDA080 - Encontrou registro no MAR. Recno: " + MAR->MAR_REGIST + ;
	       " Rotina: " + MAR->MAR_ROTINA + " Usuario MAR: " + MAR->MAR_USUARI + ;
	       " Usuario: " + cUserName + ;
	       " Cliente: " + MA7->MA7_CODCLI+"/"+MA7->MA7_LOJA)		   
	lRet  := .F.
Endif
RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD080LegendaºAutor  ³Fernando Machima º Data ³  15/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legenda do browse de liberacao de credito                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD                                                    º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMachima   ³15/06/05³811   ³- Inicio do desenvolvimento  				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRA080Legenda()

Local cLegenda  := STR0028          // "Liberacao de Credito"
Local aCores 	:= {}				// Array Default com as definicoes de cores

aCores := {	{"BR_VERDE"		,STR0026 },;					//"Nao-Bloqueado"         
            {"BR_VERMELHO" 	,STR0027 }}				      	//"Bloqueado"         
            
BrwLegenda(cLegenda,STR0025,aCores )  //"Legenda"	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD080StatºAutor  ³ Luiz Felipe Couto  º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade executar um RPC com um caixaº±±
±±º          ³ requisitante executando uma funcao neste caixa para a      º±±
±±º          ³ atualizacao do status, e por consequencia a resposta da    º±±
±±º          ³ avaliacao do crediario.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1: Codigo do Cliente para avaliacao do crediario       º±±
±±º          ³ ExpC2: Loja do Cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaCRD                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRD080Status( cCliente, cLoja )

Local cIPRPC		:= ""					//IP para RPC
Local cPortaRPC		:= ""					//Porta para RPC
Local cEnvRPC		:= ""					//Environment para RPC
Local aRetStatus	:= {}					//Retorno da Funcao WSCRD110 - Status do bloqueio de crediario
Local lRetorno		:= .T.					//Retorno da Funcao
Local oServer								//Conexao com o servidor do caixa requisitante

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do servidor do caixa requisitante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MA7->( DbSetOrder( 1 ) )

If MA7->( DbSeek( xFilial( "MA7" ) + PadR( cCliente, 6 ) + PadR( cLoja, 2 ) ) )
	If 	MA7->( FieldPos( "MA7_IPRPC" ) ) > 0 .AND. MA7->( FieldPos( "MA7_PORRPC" ) ) > 0 .AND.;
		MA7->( FieldPos( "MA7_ENVRPC" ) ) > 0

		cIPRPC 		:= AllTrim( MA7->MA7_IPRPC )
		cPortaRPC 	:= AllTrim( MA7->MA7_PORRPC )
		cEnvRPC 	:= AllTrim( MA7->MA7_ENVRPC )
	Else
		ConOut( "***** CRD080Status *****" )
		ConOut( "Favor criar os seguintes campos na base de dados de acesso do crediario:" )
		ConOut( "------------------------" )
		ConOut( "MA7_IPRPC : Caracter" )
		ConOut( "Tipo: Caracter" )
		ConOut( "Tamanho: 15" )
		ConOut( "Descricao: IP para RPC" )
		ConOut( "------------------------" )
		ConOut( "MA7_PORRPC" )
		ConOut( "Tipo: Caracter" )
		ConOut( "Tamanho: 5" )
		ConOut( "Descricao: Porta para RPC" )
		ConOut( "------------------------" )
		ConOut( "MA7_ENVRPC" )
		ConOut( "Tipo: Caracter" )
		ConOut( "Tamanho: 100" )
		ConOut( "Descricao: Environment para RPC" )
		ConOut( "************************" )
		
		lRetorno := .F.
	Endif
Endif

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao faz RPC caso IP recebido do client seja 127.0.0.1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cIPRPC == "127.0.0.1"
		ConOut( "***** CRD080Status *****" )
		ConOut( "IP: " + cIPRPC )
		ConOut( "Favor atualizar a chave TCP->server do arquivo ap7rmt.ini, para o nome da maquina." )
		ConOut( "************************" )
	
		lRetorno := .F.
	Endif
Endif

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o caixa esta utilizando RPC ou WebServices³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cIPRPC ) .AND. !Empty( cPortaRPC ) .AND. !Empty( cEnvRPC )
	
		ConOut( "***** CRD080Status *****" )
		ConOut( "IP: " + cIPRPC )
		ConOut( "Porta: " + cPortaRPC )
		ConOut( "Env: " + cEnvRPC )
		ConOut( "************************" )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Consulta Status de bloqueio de crediario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetStatus 	:= WSCRD110( cCliente, cLoja )
		
		ConOut( "Iniciando RPC... Server [" + cIPRPC + "] Porta [" + cPortaRPC + "] Ambiente " + cEnvRPC + "..." )
		 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria a conexao RPC com o caixa requisitante³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CREATE RPCCONN oServer ON SERVER cIPRPC PORT Val( cPortaRPC ) ENVIRONMENT cEnvRPC EMPRESA "00" FILIAL "00" CLEAN
		 
		If oServer == NIL
			UserException( "Falha de conexão - RPC" )
		Endif
		 
		ConOut( "RPC Conectado... Executando Funcao para verificacao de Status..." )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a funcao CRDGravaStatus no caixa requisitante³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oServer:CallProc( "CRDGravaStatus", cCliente, cLoja, aRetStatus[1], aRetStatus[2] )
		 
		ConOut( "Finalizando RPC... Server [" + cIPRPC + "] Porta [" + cPortaRPC + "] Ambiente " + cEnvRPC + "..." )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha a conexao RPC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CLOSE RPCCONN oServer
		 
		ConOut( "RPC Finalizado..." )
	Endif
Endif

Return (lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRDA080Top³ Autor ³Viviane M. Fernandes   ³ Data ³05.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que retorna o registro inicial que deverá ser visuali³±±
±±³			 ³zado na mbrowse, sempre respeitando o índice que foi traba- ³±±
±±³			 ³lhado anteriormente.O retorno da função deverá retornar     ³±±
±±³			 ³todos os campos que fazem parte da chave de índice.		  ³±±
±±³			 ³Utilizado índice inverso, por isso trazemos o mais antigo   ³±±
±±³			 ³pelo MAX                                                    ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CRDA080								               	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³MA7->MA7_FILIAL+MA7->MA7_BLOQUE+DTOS(MA7_DATABL)+MA7_HORABL ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDA080Top()

Local aArea		:= GetArea()
Local cRetorno 	:= "" // variavel sera utilizada para filtrar a mbrowse

DbSelectArea("MA7")
DbSetOrder(4)// data mais recente
DbSeek(xFilial("MA7")+"1")

If !EOF()
	cRetorno := MA7->MA7_FILIAL+MA7->MA7_BLOQUE+"  "+DTOS(MA7_DATABL)+MA7_HORABL
EndIf

RestArea(aArea)

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRDA080Bot³ Autor ³Viviane M. Fernandes   ³ Data ³05.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que retorna o último registro  que deverá ser visuali³±±
±±³			 ³zado na mbrowse, sempre respeitando o índice que foi traba- ³±±
±±³			 ³lhado anteriormente.O retorno da função deverá retornar     ³±±
±±³			 ³todos os campos que fazem parte da chave de índice.		  ³±±
±±³			 ³Utilizado índice inverso, por isso trazemos o mais recente  ³±±
±±³			 ³pelo MIN             										  ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CRDA080						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³MA7->MA7_FILIAL+MA7->MA7_BLOQUE+DTOS(MA7_DATABL)+MA7_HORABL ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDA080Bot()

Local cRetorno 	:=""
Local aArea		:= GetArea() //Guarda a area atual

DBSelectArea("MA7")
DbSetOrder(5) //indice invertido
DbSeek(xFilial("MA7")+"1")

If !EOF()
	cRetorno:= MA7_FILIAL+MA7_BLOQUE+"ZZ"+DTOS(MA7_DATABL)+MA7_HORABL
EndIf

DbSelectArea("MA7")
DbSetOrder(4)

RestArea(aArea)

Return(cRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CRDX080USR³ Autor ³ Marcos Roberto Andrade³ Data ³28.08.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o codigo do Usuario Corrente.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void CRDX080USR()                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ RetC1  - Codigo do usuario corrente.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³04/04/07  |Conrado Q      ³BOPS 122711: Alterada a utilização da cham. ³±±
±±³          ³               ³SubStr(cUsuario,7,15) por cUserName         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CRDX080USR()
Local aArea		:= GetArea() 		//Guarda a area atual
Local cCodUser	:= "" 				//Codigo do usuario de retorno

PswOrder(2)
If PswSeek(cUserName)	//Procura o nome do usuário
	cCodUser := PswRet(1)[1][1]	//Armazena o codigo do usuario
EndIf

RestArea(aArea)

Return cCodUser
