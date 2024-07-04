#INCLUDE "TMKXFUNF.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkAtuTlv  บAutor  ณVendas Clientes     บ Data ณ  24/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de integracao entre Televendas e Faturamento, utili- บฑฑ
ฑฑบ          ณzada basicamente para manter os dados do orcamento televen- บฑฑ
ฑฑบ          ณdas de acordo com a posicao do pedido de venda associado.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Numero do pedido de vendas                          บฑฑ
ฑฑบ          ณExpN2 - Status do atendimento (1-Atend;2-Liberado;3-Nf)     บฑฑ
ฑฑบ          ณExpC3 - Numero da Nota Fiscal de saida                      บฑฑ
ฑฑบ          ณExpC4 - Serie da Nota Fiscal de saida                       บฑฑ
ฑฑบ          ณExpD5 - Emissao da Nota Fiscal de saida                     บฑฑ
ฑฑบ          ณExpL6 - Se ้ estorno parcial da Nota Fiscal de saida        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER/FATURAMENTO                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkAtuTlv(	cPedido	,nStatus	,cNumNf		,cSerNF	,;
					dDataNf	,lEstorno	)

Local aArea		:= GetArea()				// Salva os dados de posicionamento do alias atual
Local aAreaSUA	:= SUA->(GetAreA())		// Salva os dados de posicionamento do SUA
Local cStatus	:= ""						// Status a ser gravado no orcamento Televendas

Default cNumNf	:= ""						// Numero da nota fiscal gerada para o pedido do Televendas
Default cSerNF	:= ""						// Serie da nota fiscal gerada para o pedido do Televendas
Default dDataNf	:= Ctod("")					// Emissao da nota fiscal gerada para o pedido do Televendas
Default lEstorno:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAnalisa qual o status a ser gravado de acordo com oณ
//ณparametro nStatus recebido na chamada da funcao    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case nStatus == 1
		cStatus	:= "SUP"	// Atendimento
	Case nStatus == 2
		cStatus	:= "LIB"	// Pedido Liberado
	Case nStatus == 3
		cStatus	:= "NF."	// NF Emitida 
	Case nStatus == 4   // Por eliminacao de residuo, utiliza o status cancelado
		cStatus	:= "CAN"	// NF cancelada 
EndCase

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o orcamento do Televendas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SUA")
DbSetOrder(8) //UA_FILIAL+UA_NUMSC5
If DbSeek(xFilial("SUA")+cPedido)      
	If cStatus == "CAN"
		If AllTrim(SUA->UA_STATUS) == "NF."
			cStatus := "NF."
		ElseIf AllTrim(SUA->UA_STATUS) == "LIB"
			cStatus := "CAN"
		ElseIf AllTrim(SUA->UA_STATUS) == "SUP"
			cStatus := "CAN"
		Else	
			cStatus := cStatus
		EndIf	
	ElseIf cStatus == "SUP"		//Se for estorno de documento e exclusใo de nota fiscal
		//Se for um estorno de documento e jแ teve um item faturado, deixa o status como NF.
		If AllTrim(SUA->UA_STATUS) == "NF." .And. lEstorno
			cStatus := "NF."
		Else
			cStatus := cStatus
		EndIf
	Else
		cStatus := cStatus
	EndIf

	RecLock("SUA",.F.)
	Replace UA_STATUS	With cStatus
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe for limpeza de resํduo nใo atualiza o n๚mero da nf do televendasณ
	//ณporque o resํduo nใo foi emitido.                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lEstorno .And. nStatus <> 4
		Replace UA_DOC		With cNumNf
		//Replace	UA_SERIE	With cSerNF    
		SerieNfId ("SUA",1,"UA_SERIE",,,,cSerNF)  //aten็ใo o campo cSernf deve vir com o conteudo composto da chave unica (mata460/mata461)
		Replace UA_EMISNF	With dDataNf
	EndIf    
	
	If nStatus == 4 .And. (cStatus == "CAN")
		Replace UA_CANC   	With "S"
		MSMM(,TamSx3("UA_OBSCANC")[1],,"Eliminado por resํduo",1,,,"SUA","UA_CODCANC")
	EndIf

	MsUnLock()
EndIf

RestArea(aAreaSUA)
RestArea(aArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkLstScr  บAutor  ณVendas Clientes     บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLista todos os scripts de campanha ja respondidos por deter-บฑฑ
ฑฑบ          ณminada entidade, com opcao de visualizacao das respostas ou บฑฑ
ฑฑบ          ณexecucao de um script                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcEntidade - Codigo da entidade origem (ex: SA1, ACH, SUS...)บฑฑ
ฑฑบ          ณcCodigo   - Codigo que identifica a entidade (ex: A1_COD)   บฑฑ
ฑฑบ          ณcLoja     - Loja que complementa o codigo da entidade.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKA341, TMKA260, MATA030                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkLstScr( nOpc, cEntidade, cCodigo, cLoja)

Local i				:= 0								// Contador de laco FOR
Local aEnt			:= {}								// Array com os c๓digos de entidades desta entidade (SA1, SU5 e ACH)
Local aScripts		:= {}								// Array com os Scripts jแ respondidos pela entidade
Local aContatos		:= {}								// Array com todos os contatos desta entidade
Local lTodos		:= .T.								// Exibe todos os status de script?
Local lTreeOpen		:= .T.								// Exibe as respostas do script abertas

aEnt := TkFindEnt( cEntidade, cCodigo, cLoja )

AC8->( dbSetOrder(2) )	//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON

// Localiza todos contatos da entidade.
For i := 1 to Len( aEnt )
	If !Empty( aEnt[i,2] )
		If AC8->( dbSeek( xFilial("AC8")+aEnt[i,1]+xFilial(aEnt[i,1])+aEnt[i,2]+aEnt[i,3] ) )
			While !AC8->(Eof()) .AND. (AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+RTrim(AC8_CODENT)) == ;
						xFilial("AC8")+aEnt[i,1]+xFilial(aEnt[i,1])+RTrim(aEnt[i,2]+aEnt[i,3]) )
									  
				If aScan(aContatos,AC8->AC8_CODCON ) == 0
					aAdd( aContatos, AC8->AC8_CODCON )
				EndIf

				AC8->( dbSkip() )
			End
		EndIf
	EndIf
Next i

aScripts := TkLoadScr( aContatos, aEnt )

TkDlgScr( nOpc, cEntidade, aScripts, aEnt, aContatos, lTodos , cCodigo, cLoja, lTreeOpen )

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkLoadScr บAutor  ณVendas Clientes     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega o array aScripts com todos os scritps da entidade.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKXFUNF                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkLoadScr( aContatos, aEnt )

Local i				:= 0								// Contador de laco FOR
Local aScripts		:= {}								// Array com os Scripts jแ respondidos pela entidade

SU5->( dbSetOrder(1) )	//U5_FILIAL+U5_CODCONT
ACI->( dbSetOrder(2) )	//ACI_FILIAL+ACI_CODCON+ACI_ENTIDA+ACI_CHAVE
SUO->( dbSetOrder(1) )	//UO_FILIAL+UO_CODCAMP
SUZ->( dbSetOrder(1) )	//UZ_FILIAL+UZ_CODSCRI

// Localiza todos os scripts de todos os contatos da entidade.
For i := 1 to Len( aContatos )	
	SU5->( dbSeek( xFilial("SU5")+Left(aContatos[i],6) ) )	// Cadastro do contato
			
	If ACI->( dbSeek( xFilial("ACI")+Left(aContatos[i],6) ) )

		While ACI->( !Eof() .AND. ACI_FILIAL+ACI_CODCON == xFilial("ACI")+Left(aContatos[i],6) )
						
			// Testa se esta execucao foi feita por esta entidade, pois o contato pode ser da varias entidades.
			If	( ACI->ACI_ENTIDA == "ACH" .AND. aEnt[1,2]+aEnt[1,3] <> Alltrim( ACI->ACI_CHAVE ) ) .OR. ;
				( ACI->ACI_ENTIDA == "SUS" .AND. aEnt[2,2]+aEnt[2,3] <> Alltrim( ACI->ACI_CHAVE ) ) .OR. ;
				( ACI->ACI_ENTIDA == "SA1" .AND. aEnt[3,2]+aEnt[3,3] <> Alltrim( ACI->ACI_CHAVE ) )

				ACI->( dbSkip() )
				Loop
			EndIf
						
			SUO->( dbSeek( xFilial("SUO")+ACI->ACI_CODCAM ) )	// Campanha
			SUZ->( dbSeek( xFilial("SUZ")+ACI->ACI_CODSCR ) )	// Configura็ใo do Script
						
			aAdd( aScripts, { ACI->ACI_CODIGO, ACI->ACI_DATA  , ACI->ACI_CODCON,;
							  SU5->U5_CONTAT , ACI->ACI_CODCAM, SUO->UO_DESC   ,;
							  ACI->ACI_CODSCR, SUZ->UZ_DESC   , ACI->ACI_ROTINA,;
							  ACI->ACI_ATEND , ACI->ACI_ENTIDA } )
	
			ACI->( dbSkip() )
		End
	EndIf
Next i

If Empty( aScripts )
	aAdd( aScripts, { "", "", "", "", "", "", "", "", "", "", "" } )
EndIf

// Ordena os scripts por data e depois codigo
aScripts := aSort( aScripts,,, {|x,y| DToS(x[2])+x[1] < DToS(y[2])+y[1] } )

Return aScripts


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkDlgScr  บAutor  ณVendas Clientes     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a janela para exibicao dos scripts da entidade.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKXFUNF                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkDlgScr(	nOpc		, cEntidade	, aScripts	, aEnt	,;
							aContatos	, lTodos    , cCodigo   , cLoja ,;
							lTreeOpen 	)

Local aParScript	:= {}								// Dados do script executado
Local oDlgScripts										// Janela com a listagem de scripts
Local oSay												// Label superior
Local oScripts											// ListBox com os dados
Local oBmpLeg1											// Bitmap do primeiro item da legenda
Local oSayLeg1											// Label do primeiro item da legenda
Local oBmpLeg2											// Bitmap do segundo item da legenda
Local oSayLeg2											// Label do segundo item da legenda
Local oBmpLeg3											// Bitmap do terceiro item da legenda
Local oSayLeg3											// Label do terceiro item da legenda
Local oChkTodos											// CheckBox para exibir todos os status
Local oBtDetalhar										// Botao para detalhamento da resposta
Local oBtIncluir										// Botao para incluir uma nova resposta de script
Local oBtFechar											// Botao para fechar a janela

Local oDlgParam	 										// Objeto dialog
Local oGrpContato										// Objeto moldura superior
Local oGrpCamp											// Objeto moldura inferior
Local oContato											// Combobox para selecao do contato
Local oCampanhas										// ListBox com as campanhas
Local oBtOk												// Botao Ok
Local oBtCancelar										// Botao Cancelar
Local oLbOk												// Imagem do botao confirmar
Local oLbNo												// Imagem do botao cancelar  
Local oChkTree											// Checkbox para selecao de TREE aberto ou fechado
Local aCampanhas :={}
Local nX
Local aContTmp   :={}
Local aPDFields	:= {}
Local aPDCols	:= {} 

Default lTreeOpen := .F.

aPDFields := {"U5_CONTAT","A1_NOME","US_NOME","ACH_RAZAO"}
FATPDLoad(Nil, Nil, aPDFields)

oLbNo	:= LoadBitmap(Nil, "LBNO" )
oLbOk	:= LoadBitmap(Nil, "LBOK" ) 

aContatos := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListagem dos contatosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AC8->( dbSetOrder(2) )	//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
SU5->( dbSetOrder(1) )	//U5_FILIAL+U5_CODCONT
                                                               
AC8->( dbSeek( xFilial("AC8")+cEntidade+xFilial(cEntidade)+cCodigo+cLoja ) )
While !AC8->(Eof()) .AND. (AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+RTrim(AC8_CODENT)) == ;
	xFilial("AC8")+cEntidade+xFilial(cEntidade)+RTrim(cCodigo+cLoja))
						  
	SU5->( dbSeek( xFilial("SU5")+AC8->AC8_CODCON ) )
	aAdd( aContatos, AC8->AC8_CODCON + " - " + SU5->U5_CONTAT )
	
	AC8->( dbSkip() )
End

If Len( aContatos ) == 0
	Help( " ", 1, "SEM CONTAT" )	//Nenhum contato cadastrado para esta entidade
	cContato := ""	// Zera o codigo de contato
	Return aParScript
EndIf

If Len(aContatos) > 1
	aAdd( aContTmp,"< selecione o contato >" )	//"< selecione o contato >"
	For nX := 1 to Len(aContatos)
		AAdd(aContTmp,aContatos[nX])
	Next nX
	aContatos	:= aClone(aContTmp)
	aContTmp	:= {}
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListagem das campanhasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// Identifica as campanhas disponํveis
SUO->( dbSetOrder(1) )	//UO_FILIAL+UO_CODCAMP
SUO->( dbSeek( xFilial("SUO") ) )
While SUO->( !Eof() .AND. UO_FILIAL == xFilial("SUO") )

	If ( dDatabase >= SUO->UO_DTINI .OR. Empty( SUO->UO_DTINI ) ) .AND.;
	   ( dDatabase <= SUO->UO_DTFIM .OR. Empty( SUO->UO_DTFIM ) )
		aAdd( aCampanhas, { .F., SUO->UO_CODCAMP, SUO->UO_DESC, SUO->UO_TIPO, SUO->UO_DTINI, SUO->UO_DTFIM } )
	EndIf

	SUO->(DbSkip())
End

If Len(aCampanhas) == 0  
	MsgInfo(STR0036) //"Nenhuma campanha foi identificada para a execu็ใo deste script"
	Return aParScript
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oDlgScripts := MSDIALOG():Create()
oDlgScripts:cName := "oDlgScripts"
oDlgScripts:cCaption := STR0001 //"Scripts de campanha"
oDlgScripts:nLeft := 0
oDlgScripts:nTop := 0     
oDlgScripts:nWidth := 634
oDlgScripts:nHeight := 550
oDlgScripts:lShowHint := .F.
oDlgScripts:lCentered := .T.

oSay := TSAY():Create(oDlgScripts)
oSay:cName := "oSay"
oSay:cCaption := STR0002 //"Scripts de campanha jแ respondidos pelos contatos da entidade"
oSay:nLeft := 8
oSay:nTop := 8
oSay:nWidth := 336
oSay:nHeight := 17
oSay:lShowHint := .F.
oSay:lReadOnly := .F.
oSay:Align := 0
oSay:lVisibleControl := .T.
oSay:lWordWrap := .F.
oSay:lTransparent := .F.

//{ ACI_CODIGO, ACI_DATA, ACI_CODCON, U5_CONTAT, ACI_CODCAM, UO_DESC, ACI_CODSCR, UZ_DESC, ACI_ROTINA, ACI_ATEND }
oScripts := TWBrowse():New( 28/2/*<nRow>*/, 08/2/*<nCol>*/, 611/2/*<nWidth>*/, 190/2/*<nHeigth>*/, /*<Flds>*/,;
							{ " ", STR0003, STR0004, STR0005, STR0006, STR0007 }/*<aHeaders>*/,; //"Data"###"Contato"###"Campanha"###"Script"###"Rotina"
							{ 8, 30, 90, 90, 90, 100 }/*<aColSizes>*/, oDlgScripts /*<oDlg>*/,,,,,,,,,,,,,,.T. )
oScripts:bLDblClick	:=	{|| If( !Empty(oScripts:aArray[oScripts:nAt,1]),;
								TkVisScr( oScripts:aArray[oScripts:nAt,1], oScripts:aArray[oScripts:nAt,7], lTreeOpen ),;
								Nil ) }
								
aPDCols := {"","","U5_CONTAT","","",""}

If FATPDActive() .And. FTPDUse(.T.)
	oScripts:aObfuscatedCols := FATPDColObfuscate(aPDCols)
EndIf
						
TkFilScr( cEntidade, @oScripts, aScripts, lTodos )

oBmpLeg1 := TBITMAP():Create(oDlgScripts)
oBmpLeg1:cName := "oBmpLeg1"
oBmpLeg1:nLeft := 8
oBmpLeg1:nTop := 222
oBmpLeg1:nWidth := 16
oBmpLeg1:nHeight := 16
oBmpLeg1:lShowHint := .F.
oBmpLeg1:lReadOnly := .F.
oBmpLeg1:Align := 0
oBmpLeg1:lVisibleControl := .T.
oBmpLeg1:cResName := "BR_AZUL"
oBmpLeg1:lStretch := .F.
oBmpLeg1:lAutoSize := .T.

oSayLeg1 := TSAY():Create(oDlgScripts)
oSayLeg1:cName := "oSayLeg1"
oSayLeg1:cCaption := STR0008 //"Respondido como Suspect"
oSayLeg1:nLeft := 25
oSayLeg1:nTop := 222
oSayLeg1:nWidth := 145
oSayLeg1:nHeight := 17
oSayLeg1:lShowHint := .F.
oSayLeg1:lReadOnly := .F.
oSayLeg1:Align := 0
oSayLeg1:lVisibleControl := .T.
oSayLeg1:lWordWrap := .F.
oSayLeg1:lTransparent := .F.

oBmpLeg2 := TBITMAP():Create(oDlgScripts)
oBmpLeg2:cName := "oBmpLeg2"
oBmpLeg2:nLeft := 208
oBmpLeg2:nTop := 222
oBmpLeg2:nWidth := 16
oBmpLeg2:nHeight := 16
oBmpLeg2:lShowHint := .F.
oBmpLeg2:lReadOnly := .F.
oBmpLeg2:Align := 0
oBmpLeg2:lVisibleControl := .T.
oBmpLeg2:cResName := "BR_AMARELO"
oBmpLeg2:lStretch := .F.
oBmpLeg2:lAutoSize := .T.

oSayLeg2 := TSAY():Create(oDlgScripts)
oSayLeg2:cName := "oSayLeg2"
oSayLeg2:cCaption := STR0009 //"Respondido como Prospect"
oSayLeg2:nLeft := 225
oSayLeg2:nTop := 222
oSayLeg2:nWidth := 145
oSayLeg2:nHeight := 17
oSayLeg2:lShowHint := .F.
oSayLeg2:lReadOnly := .F.
oSayLeg2:Align := 0
oSayLeg2:lVisibleControl := .T.
oSayLeg2:lWordWrap := .F.
oSayLeg2:lTransparent := .F.

oBmpLeg3 := TBITMAP():Create(oDlgScripts)
oBmpLeg3:cName := "oBmpLeg3"
oBmpLeg3:nLeft := 408
oBmpLeg3:nTop := 222
oBmpLeg3:nWidth := 16
oBmpLeg3:nHeight := 16
oBmpLeg3:lShowHint := .F.
oBmpLeg3:lReadOnly := .F.
oBmpLeg3:Align := 0
oBmpLeg3:lVisibleControl := .T.
oBmpLeg3:cResName := "BR_VERDE"
oBmpLeg3:lStretch := .F.
oBmpLeg3:lAutoSize := .T.

oSayLeg3 := TSAY():Create(oDlgScripts)
oSayLeg3:cName := "oSayLeg3"
oSayLeg3:cCaption := STR0010 //"Respondido como Cliente"
oSayLeg3:nLeft := 425
oSayLeg3:nTop := 222
oSayLeg3:nWidth := 145
oSayLeg3:nHeight := 17
oSayLeg3:lShowHint := .F.
oSayLeg3:lReadOnly := .F.
oSayLeg3:Align := 0
oSayLeg3:lVisibleControl := .T.
oSayLeg3:lWordWrap := .F.
oSayLeg3:lTransparent := .F.

oChkTodos := TCHECKBOX():Create(oDlgScripts)
oChkTodos:cName := "oChkTodos"
oChkTodos:cCaption := STR0011 //"Exibir respostas de todas as entidades"
oChkTodos:nLeft := 8
oChkTodos:nTop := 247
oChkTodos:nWidth := 202
oChkTodos:nHeight := 17
oChkTodos:cVariable := "lTodos"
oChkTodos:bSetGet := {|u| If(PCount()>0,lTodos:=u,lTodos), TkFilScr( cEntidade, @oScripts, aScripts, lTodos ) }
oChkTodos:lShowHint := .F.
oChkTodos:lReadOnly := .F.
oChkTodos:Align := 0
oChkTodos:lVisibleControl := .T.

oChkTree := TCHECKBOX():Create(oDlgScripts)
oChkTree:cName := "oChkTree"
oChkTree:cCaption := STR0039
oChkTree:nLeft := 230
oChkTree:nTop := 247
oChkTree:nWidth := 230
oChkTree:nHeight := 17
oChkTree:cVariable := "lTreeOpen"
oChkTree:bSetGet := {|u| If(PCount()>0,lTreeOpen:=u,lTreeOpen)}
oChkTree:lShowHint := .F.
oChkTree:lReadOnly := .F.
oChkTree:Align := 0
oChkTree:lVisibleControl := .T.

oBtDetalhar := TBUTTON():Create(oDlgScripts)
oBtDetalhar:cName := "oBtDetalhar"
oBtDetalhar:cCaption := STR0012 //"Detalhar"
oBtDetalhar:nLeft := 436
oBtDetalhar:nTop := 690
oBtDetalhar:nWidth := 52
oBtDetalhar:nHeight := 22
oBtDetalhar:bAction := {|| TkVisScr( oScripts:aArray[oScripts:nAt,1], oScripts:aArray[oScripts:nAt,7], lTreeOpen ) }
oBtDetalhar:bWhen := {|| oScripts:nAt > 0 .AND. !Empty( oScripts:aArray[oScripts:nAt,1] ) }
oBtDetalhar:lShowHint := .F.
oBtDetalhar:lReadOnly := .F.
oBtDetalhar:lVisibleControl := .T.                   

oGrpContato := TGROUP():Create(oDlgParam)
oGrpContato:cName := "oGrpContato"
oGrpContato:cCaption := "Contato"

oGrpContato:nLeft := 4
oGrpContato:nTop := 280
oGrpContato:nWidth := 213
oGrpContato:nHeight := 48
oGrpContato:lShowHint := .F.
oGrpContato:lReadOnly := .F.
oGrpContato:Align := 0
oGrpContato:lVisibleControl := .T.

oContato := TCOMBOBOX():Create(oDlgParam)
oContato:cName := "oContato"
oContato:cCaption := ""
oContato:nLeft := 12
oContato:nTop := 300
oContato:nWidth := 200  
oContato:nHeight := 21
oContato:lShowHint := .F.
oContato:lReadOnly := .F.
oContato:Align := 0
oContato:bSetGet := {|u| If(PCount()>0,cContato:=u,cContato) }
oContato:lVisibleControl := .T.
oContato:aItems := aContatos
oContato:nAt := 1

If FATPDActive() .And. FTPDUse(.T.)
	oContato:lObfuscate := FATPDIsObfuscate("U5_CONTAT")
EndIf


oGrpCamp := TGROUP():Create(oDlgParam)
oGrpCamp:cName := "oGrpCamp"
oGrpCamp:cCaption := "Campanha"
oGrpCamp:nLeft := 4
oGrpCamp:nTop := 330
oGrpCamp:nWidth := 616
oGrpCamp:nHeight := 150
oGrpCamp:lShowHint := .F.
oGrpCamp:lReadOnly := .F.
oGrpCamp:Align := 0
oGrpCamp:lVisibleControl := .T.

//{ ACI_CODIGO, ACI_DATA, ACI_CODCON, U5_CONTAT, ACI_CODCAM, UO_DESC, ACI_CODSCR, UZ_DESC, ACI_ROTINA, ACI_ATEND }
oCampanhas := TWBrowse():New( 350/2/*<nRow>*/, 12/2/*<nCol>*/, 600/2/*<nWidth>*/, 134/2/*<nHeigth>*/, /*<Flds>*/,;
								{ " ", "C๓digo", "Descri็ใo", "Tipo", "Inํcio", "Fim" }/*<aHeaders>*/,;	//"C๓digo", "Descri็ใo", "Tipo", "Inํcio", "Fim"
							{ 8, 30, 90, 30, 30 }/*<aColSizes>*/, oDlgParam/*<oDlg>*/,,,,,,,,,,,,,,.T. )
oCampanhas:bLDblClick	:=	{|| Tk271MkCmp( @oCampanhas, @aCampanhas ) }
oCampanhas:SetArray( aCampanhas )
oCampanhas:bLine	:=	{|| {If( oCampanhas:aArray[oCampanhas:nAt,1], oLbOk, oLbNo ),;											// Marcado/Desmarcado
							 oCampanhas:aArray[oCampanhas:nAt,2],;																// Codigo
							 oCampanhas:aArray[oCampanhas:nAt,3],;																// Descricao
							 If( oCampanhas:aArray[oCampanhas:nAt,4] == "1", "Receptivo",;										// "Receptivo"
							 If( oCampanhas:aArray[oCampanhas:nAt,4] == "2", "Ativo", "" )),;									// "Ativo"
							 oCampanhas:aArray[oCampanhas:nAt,5],;																// Data inicio
							 oCampanhas:aArray[oCampanhas:nAt,6] } }															// Data fim
oCampanhas:Refresh()   


oBtOk := TBUTTON():Create(oDlgParam)
oBtOk:cName := "oBtOk"
oBtOk:cCaption := "Detalhar"
oBtOk:nLeft := 510
oBtOk:nTop := 260
oBtOk:nWidth := 52
oBtOk:nHeight := 22
oBtOk:lShowHint := .F.
oBtOk:lReadOnly := .F.
oBtOk:lVisibleControl := .T.
oBtOk:bAction := {|| If( !Empty(oScripts:aArray[oScripts:nAt,1]),;
					TkVisScr( oScripts:aArray[oScripts:nAt,1], oScripts:aArray[oScripts:nAt,7],lTreeOpen ),;
					Nil ) }


oBtIncluir := TBUTTON():Create(oDlgScripts)
oBtIncluir:cName := "oBtIncluir"
oBtIncluir:cCaption := STR0013 //"Incluir"
oBtIncluir:nLeft := 453
oBtIncluir:nTop := 485
oBtIncluir:nWidth := 52
oBtIncluir:nHeight := 22
oBtIncluir:bAction := {||	TkIncScr( nOpc, cEntidade, aContatos, aEnt, @oScripts, lTodos,@oContato,@oCampanhas),;
							aScripts := TkLoadScr( aContatos, aEnt ),;
							oScripts:Refresh() }
oBtIncluir:bWhen := {|| nOpc == 4 }
oBtIncluir:lShowHint := .F.
oBtIncluir:lReadOnly := .F.
oBtIncluir:lVisibleControl := .T.

oBtCancelar := TBUTTON():Create(oDlgParam)
oBtCancelar:cName := "oBtCancelar"
oBtCancelar:cCaption := "Sair"
oBtCancelar:nLeft := 510
oBtCancelar:nTop := 485
oBtCancelar:nWidth := 52
oBtCancelar:nHeight := 22
oBtCancelar:lShowHint := .F.
oBtCancelar:lReadOnly := .F.
oBtCancelar:lVisibleControl := .T.
oBtCancelar:bAction := {|| oDlgScripts:End() }

FATPDLogUser("TKDLGSCR")      

oDlgScripts:Activate()

FATPDUnload()

Return aParScript    
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkIncScr  บAutor  ณVendas Clientes     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta um novo script e grava esta execucao.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKXFUNF                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkIncScr(	nOpc	, cEntidade	, aContatos	, aEnt	,;
							oScripts, lTodos , oContato	,oCampanhas)

Local aArea			:= GetArea()
Local aAreaSA3		:= SA3->(GetArea())
Local aParScript	:= {}		// Dados do script executado
Local lExibe        := .F. 	   	// exibe a tela de contatos
Local lContinua		:= .T.		// Verifica se o usuario pode executar script

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o script foi acionado atraves da workarea, verifica se oณ
//ณgrupo do representante atual possui permissao para executarณ
//ณscripts                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If IsInCallStack("FATA320")

	SA3->(DbSetOrder(7))	//A3_FILIAL+A3_CODUSR
	ACA->(DbSetOrder(1))	//ACA_FILIAL+ACA_GRPREP

	If 	SA3->(DbSeek(xFilial("SA3") + __cUserId))	 	.AND.;
		ACA->(DbSeek(xFilial("ACA") + SA3->A3_GRPREP))	.AND.;
		ACA->ACA_SCRIPT == "1"

		lContinua	:= .T.

	Else

		MsgInfo(STR0037,STR0038)//"Usuario sem acesso para execucao de scripts a partir da workarea."###"Acesso negado"
		lContinua	:= .F.

	EndIf

EndIf

If lContinua
	Tk271Script( nOpc, @aParScript, cEntidade, lExibe ,@oContato ,@oCampanhas )
	
	If !Empty( aParScript )
		TkGrvCamp( aParScript )
	
		// Recarrega os scripts da entidade apos a gravacao e atualiza o listbox
		aScripts := TkLoadScr( aContatos, aEnt )
		
		TkFilScr( cEntidade, @oScripts, aScripts, lTodos )
		
	EndIf
EndIf
            
RestArea(aAreaSA3)
RestArea(aArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkFindEnt บAutor  ณVendas Clientes     บ Data ณ  29/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza os 3 codigos de entidades de um mesmo suspect, ou  บฑฑ
ฑฑบ          ณseja, suspect, prospect e cliente.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcEntidade - Alias da entidade que se tem em maos            บฑฑ
ฑฑบ          ณcCodigo   - Codigo da entidade que se tem em maos           บฑฑ
ฑฑบ          ณcLoja     - Loja da entidade que se tem em maos             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRet - Array com 3 linhas, com codigo e loja das entidades  บฑฑ
ฑฑบ          ณ       relacionadas.                                        บฑฑ
ฑฑบ          ณ     - aRet[1]: { "ACH", ACH_CODIGO, ACH_LOJA }             บฑฑ
ฑฑบ          ณ     - aRet[2]: { "SUS", US_COD, US_LOJA }                  บฑฑ
ฑฑบ          ณ     - aRet[3]: { "SA1", A1_COD, A1_LOJA }                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKXFUNF - TkLstScr                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkFindEnt( cEntidade, cCodigo, cLoja )

Local aRet		:= {{ "ACH", "", "" },;
					{ "SUS", "", "" },;
					{ "SA1", "", "" }}			// Array de retorno
Local aArea		:= GetArea()					// Salva area atual
Local aAreaACH	:= ACH->( GetArea() )			// Salva area da ACH
Local aAreaSUS	:= SUS->( GetArea() )			// Salva area da SUS
Local aAreaSA1	:= SA1->( GetArea() )			// Salva area da SA1
Local cFilACH	:= ACH->(DbFilter())			// Salva o fitro do ACH
Local cFilSUS	:= SUS->(DbFilter())			// Salva o fitro do SUS
Local cFilSA1	:= SA1->(DbFilter())			// Salva o fitro do SA1 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRemove os filtros atuaisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ACH->(DbClearFilter())
SUS->(DbClearFilter())
SA1->(DbClearFilter())

If cEntidade == "ACH"	// Suspect

	aRet[1] := { "ACH", cCodigo, cLoja }
	
	ACH->( dbSetOrder(1) )
	ACH->( dbSeek( xFilial("ACH")+cCodigo+cLoja ) )
	
	SUS->( dbSetOrder(1) )	//US_FILIAL+US_COD+US_LOJA
	If SUS->( dbSeek( xFilial("SUS")+ACH->( ACH_CODPRO+ACH_LOJPRO ) ) )
		aRet[2] := { "SUS", SUS->US_COD, SUS->US_LOJA }
		
		SA1->( dbSetOrder(1) )	//A1_FILIAL+A1_COD+A1_LOJA
		If SA1->( dbSeek( xFilial("SA1")+SUS->( US_CODCLI+US_LOJACLI ) ) )
			aRet[3] := { "SA1", SA1->A1_COD, SA1->A1_LOJA }
		EndIf
	EndIf

ElseIf cEntidade == "SUS"	// Prospect

	aRet[2] := { "SUS", cCodigo, cLoja }

	SUS->( dbSetOrder(1) )	//US_FILIAL+US_COD+US_LOJA
	SUS->( dbSeek( xFilial("SUS")+cCodigo+cLoja ) )
	
	ACH->( dbSetOrder(4) )	//ACH_FILIAL+ACH_CODPRO+ACH_LOJPRO
	If ACH->( dbSeek( xFilial("ACH")+SUS->( US_COD+US_LOJA ) ) )
		aRet[1] := { "ACH", ACH->ACH_CODIGO, ACH->ACH_LOJA }
	EndIf
	
	SA1->( dbSetOrder(1) )	//A1_FILIAL+A1_COD+A1_LOJA
	If SA1->( dbSeek( xFilial("SA1")+SUS->( US_CODCLI+US_LOJACLI ) ) )
		aRet[3] := { "SA1", SA1->A1_COD, SA1->A1_LOJA }
	EndIf

ElseIf cEntidade == "SA1"	// Cliente

	aRet[3] := { "SA1", cCodigo, cLoja }

	SA1->( dbSetOrder(1) )	//A1_FILIAL+A1_COD+A1_LOJA
	SA1->( dbSeek( xFilial("SA1")+cCodigo+cLoja ) )

	SUS->( dbSetOrder(5) )	//US_FILIAL+US_CODCLI+US_LOJACLI
	If SUS->( dbSeek( xFilial("SUS")+cCodigo+cLoja ) )
		aRet[2] := { "SUS", SUS->US_COD, SUS->US_LOJA }
	
		ACH->( dbSetOrder(4) )	//ACH_FILIAL+ACH_CODPRO+ACH_LOJPRO
		If ACH->( dbSeek( xFilial("ACH")+SUS->( US_COD+US_LOJA ) ) )
			aRet[1] := { "ACH", ACH->ACH_CODIGO, ACH->ACH_LOJA }
		EndIf
	EndIf
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura filtros das tabelasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cFilACH)
	DbSelectArea("ACH")
	Set Filter To &cFilACH
EndIf

If !Empty(cFilSUS)
	DbSelectArea("SUS")
	Set Filter To &cFilSUS
EndIf

If !Empty(cFilSA1)
	DbSelectArea("SA1")
	Set Filter To &cFilSA1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura o posicionamento das tabelasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ACH->( RestArea( aAreaACH ) )
SUS->( RestArea( aAreaSUS ) )
SA1->( RestArea( aAreaSA1 ) )
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkFilScr  บAutor  ณVendas Clientes     บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltra o listbox aScripts de acordo com a selecao do usuarioบฑฑ
ฑฑบ          ณno checkbox oChkTodos.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKXFUNF - TkLstScr()                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkFilScr( cEntidade, oScripts, aScripts, lTodos )

Local aFiltered	:= {}											// Array filtrado
Local oBmp		:= LoadBitmap(Nil, "")
Local oAmarelo	:= LoadBitmap(Nil, "BR_AMARELO" )	// Legenda Amarela
Local oAzul		:= LoadBitmap(Nil, "BR_AZUL" )		// Legenda Azul
Local oVerde	:= LoadBitmap(Nil, "BR_VERDE" )		// Legenda Verde
 
If lTodos 
	aFiltered := aClone( aScripts ) 
Else
	aEval( aScripts, {|x| If( x[11] == cEntidade, aAdd( aFiltered, aClone(x) ), nil ) } )
EndIf

If Empty( aFiltered )
	aAdd( aFiltered, { "", "", "", "", "", "", "", "", "", "", "" } )
EndIf

oScripts:SetArray( aFiltered )  
oScripts:bLine		:=	{|| {If( oScripts:aArray[oScripts:nAt,11] == "SA1", oVerde,;											// Cor Verde = Cliente
							 If( oScripts:aArray[oScripts:nAt,11] == "SUS", oAmarelo,;											// Cor Amarelo = Prospect
							 If( oScripts:aArray[oScripts:nAt,11] == "ACH", oAzul, oBmp ))),;									// Cor Azul = Suspect
							 oScripts:aArray[oScripts:nAt,2],;																	// Data
							 oScripts:aArray[oScripts:nAt,3] + " " + Alltrim(oScripts:aArray[oScripts:nAt,4]),;					// Contato
							 oScripts:aArray[oScripts:nAt,5] + " " + Alltrim(oScripts:aArray[oScripts:nAt,6]),;					// Campanha
							 oScripts:aArray[oScripts:nAt,7] + " " + Alltrim(oScripts:aArray[oScripts:nAt,8]),;					// Script
							 If( oScripts:aArray[oScripts:nAt,9] == "1", STR0015 + oScripts:aArray[oScripts:nAt,10],;	// Rotina TMK //"Telemarketing "
							 If( oScripts:aArray[oScripts:nAt,9] == "2", STR0016 + oScripts:aArray[oScripts:nAt,10],;	// Rotina TLV //"Televendas "
							 If( oScripts:aArray[oScripts:nAt,9] == "3", STR0017 + oScripts:aArray[oScripts:nAt,10],;	// Rotina TCB //"Telecobran็a "
							 If( oScripts:aArray[oScripts:nAt,9] == "4", STR0046 + oScripts:aArray[oScripts:nAt,10],;	// Rotina TEA //"Teleatendimento "
							 If( oScripts:aArray[oScripts:nAt,9] == " ", STR0018, " " ))))) } }									// Agenda do operador ou Cadastro //"Outros"

oScripts:DrawSelect()  

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณTkVisScr     บAutorณVendas Clientes     บ Data ณ  29/11/07   บฑฑ
ฑฑฬอออออออออุอออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณOferece uma visualizacao de um script de campanha ja         บฑฑ
ฑฑบ         ณrespondido.                                                  บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno  ณ.T.                                                          บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametroณcCodigo - Codigo da execucao do script (ACI_CODIGO)          บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณCALL CENTER - TMKXFUNF - TkLstScr                            บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkVisScr( cCodigo, cNullPar, lTreeOpen )

Local aAreaACI		:= ACI->( GetArea() )		// Salva area da ACI
Local aAreaSU5		:= SU5->( GetArea() )		// Salva area da SU5
Local aAreaSUO		:= SUO->( GetArea() )		// Salva area da SUO
Local aAreaSUZ		:= SUZ->( GetArea() )		// Salva area da SUZ
Local aAreaEnt		:= {}						// Salva area da entidade usada no script
Local cAliasEnt		:= ""						// Alias da entidade usada no script
Local oDlgScript								// Objeto referente a Dialog principal do Fonte. (Cadastro)
Local oGrpTop									// GroupBox superior
Local oBtFechar									// Botใo para fechar a tela
Local oTreeScript								// Objeto do Tree da tela de cadastro de Script.
Local oBmpLeg1									// Primeiro BitMap da legenda
Local oSayLeg1									// Primeiro Label da legenda
Local oBmpLeg2									// Segundo BitMap da legenda
Local oSayLeg2									// Segundo Label da legenda
Local oBmpLeg3									// Terceiro BitMap da legenda
Local oSayLeg3									// Terceiro Label da legenda
Local oLblCampanha								// Label Campanha
Local oLblScript								// Label Script
Local oLblContato								// Label Contato
Local oLblEntidade								// Label Entidade
Local oLblData									// Label Data
Local oLblRotina								// Label Rotina
Local oCampanha									// Texto da Campanha
Local oScript									// Texto do Script
Local oContato									// Texto do Contato
Local oEntidade									// Texto da Entidade
Local oData										// Texto da Data
Local oRotina									// Texto da Rotina
Local oFont14									// Objeto fonte Arial tamanho 14 bold

// Posiciona todas as tabelas
ACI->( dbSetOrder(1) )	//ACI_FILIAL+ACI_CODIGO
ACI->( dbSeek( xFilial("ACI")+cCodigo ) )

SU5->( dbSetOrder(1) )	//U5_FILIAL+U5_CODCONT
SU5->( dbSeek( xFilial("SU5")+ACI->ACI_CODCON ) )

SUO->( dbSetOrder(1) )	//UO_FILIAL+UO_CODCAMP
SUO->( dbSeek( xFilial("SUO")+ACI->ACI_CODCAM ) )

SUZ->( dbSetOrder(1) )	//UZ_FILIAL+UZ_CODSCRI
SUZ->( dbSeek( xFilial("SUZ")+ACI->ACI_CODSCR ) )

cAliasEnt := ACI->ACI_ENTIDA
If Empty(cAliasEnt)
	Return(.T.)
EndIf
aAreaEnt := (cAliasEnt)->( GetArea() )

(cAliasEnt)->( dbSetOrder(1) )
(cAliasEnt)->( dbSeek( xFilial(cAliasEnt)+ACI->ACI_CHAVE ) )


oDlgScript := MSDIALOG():Create()
oDlgScript:cName := "oDlgScript"
oDlgScript:cCaption := STR0019 //"Script de Campanha - Visualizar"
oDlgScript:nLeft := 0
oDlgScript:nTop := 0
oDlgScript:nWidth := 723
oDlgScript:nHeight := 563
oDlgScript:lShowHint := .F.
oDlgScript:lCentered := .T.

oFont14 := TFont():New( "Arial" /*<cName>*/, 0 /*<nWidth>*/, 14 /*<nHeight>*/, /*<.from.>*/,;
                     	.T. /*<.bold.>*/, /*<nEscapement>*/,, /*<nWeight>*/, /*<.italic.>*/,;
						/*[<.underline.>]*/,,,,,, /*<oDevice>*/ )

oGrpTop := TGROUP():Create(oDlgScript)
oGrpTop:cName := "oGrpTop"
oGrpTop:nLeft := 8
oGrpTop:nTop := 8
oGrpTop:nWidth := 700
oGrpTop:nHeight := 105
oGrpTop:lShowHint := .F.
oGrpTop:lReadOnly := .F.
oGrpTop:Align := 0
oGrpTop:lVisibleControl := .T.

oLblCampanha := TSAY():Create(oDlgScript)
oLblCampanha:cName := "oLblCampanha"
oLblCampanha:cCaption := STR0020 //"Campanha:"
oLblCampanha:nLeft := 16
oLblCampanha:nTop := 16
oLblCampanha:nWidth := 65
oLblCampanha:nHeight := 17
oLblCampanha:lShowHint := .F.
oLblCampanha:lReadOnly := .F.
oLblCampanha:Align := 0
oLblCampanha:lVisibleControl := .T.
oLblCampanha:lWordWrap := .F.
oLblCampanha:lTransparent := .F.

oLblScript := TSAY():Create(oDlgScript)
oLblScript:cName := "oLblScript"
oLblScript:cCaption := STR0021 //"Script:"
oLblScript:nLeft := 16
oLblScript:nTop := 40
oLblScript:nWidth := 65
oLblScript:nHeight := 17
oLblScript:lShowHint := .F.
oLblScript:lReadOnly := .F.
oLblScript:Align := 0
oLblScript:lVisibleControl := .T.
oLblScript:lWordWrap := .F.
oLblScript:lTransparent := .F.

oLblContato := TSAY():Create(oDlgScript)
oLblContato:cName := "oLblContato"
oLblContato:cCaption := STR0022 //"Contato:"
oLblContato:nLeft := 16
oLblContato:nTop := 64
oLblContato:nWidth := 65
oLblContato:nHeight := 17
oLblContato:lShowHint := .F.
oLblContato:lReadOnly := .F.
oLblContato:Align := 0
oLblContato:lVisibleControl := .T.
oLblContato:lWordWrap := .F.
oLblContato:lTransparent := .F.

oLblEntidade := TSAY():Create(oDlgScript)
oLblEntidade:cName := "oLblEntidade"
oLblEntidade:cCaption := STR0023 //"Entidade:"
oLblEntidade:nLeft := 16
oLblEntidade:nTop := 88
oLblEntidade:nWidth := 65
oLblEntidade:nHeight := 17
oLblEntidade:lShowHint := .F.
oLblEntidade:lReadOnly := .F.
oLblEntidade:Align := 0
oLblEntidade:lVisibleControl := .T.
oLblEntidade:lWordWrap := .F.
oLblEntidade:lTransparent := .F.

oLblData := TSAY():Create(oDlgScript)
oLblData:cName := "oLblData"
oLblData:cCaption := STR0024 //"Data:"
oLblData:nLeft := 450
oLblData:nTop := 16
oLblData:nWidth := 65
oLblData:nHeight := 17
oLblData:lShowHint := .F.
oLblData:lReadOnly := .F.
oLblData:Align := 0
oLblData:lVisibleControl := .T.
oLblData:lWordWrap := .F.
oLblData:lTransparent := .F.

oLblRotina := TSAY():Create(oDlgScript)
oLblRotina:cName := "oLblRotina"
oLblRotina:cCaption := STR0025 //"Rotina:"
oLblRotina:nLeft := 450
oLblRotina:nTop := 40
oLblRotina:nWidth := 65
oLblRotina:nHeight := 17
oLblRotina:lShowHint := .F.
oLblRotina:lReadOnly := .F.
oLblRotina:Align := 0
oLblRotina:lVisibleControl := .T.
oLblRotina:lWordWrap := .F.
oLblRotina:lTransparent := .F.

oCampanha := TSAY():Create(oDlgScript)
oCampanha:cName := "oCampanha"
oCampanha:cCaption := ACI->ACI_CODCAM + "  " + Alltrim( SUO->UO_DESC )
oCampanha:nLeft := 80
oCampanha:nTop := 16
oCampanha:nWidth := 360
oCampanha:nHeight := 17
oCampanha:lShowHint := .F.
oCampanha:lReadOnly := .F.
oCampanha:Align := 0
oCampanha:lVisibleControl := .T.
oCampanha:lWordWrap := .F.
oCampanha:lTransparent := .F.
oCampanha:oFont := oFont14
oCampanha:nClrText := CLR_BLUE

oScript := TSAY():Create(oDlgScript)
oScript:cName := "oScript"
oScript:cCaption := ACI->ACI_CODSCR + "  " + Alltrim( SUZ->UZ_DESC )
oScript:nLeft := 80
oScript:nTop := 40
oScript:nWidth := 360
oScript:nHeight := 17
oScript:lShowHint := .F.
oScript:lReadOnly := .F.
oScript:Align := 0
oScript:lVisibleControl := .T.
oScript:lWordWrap := .F.
oScript:lTransparent := .F.
oScript:oFont := oFont14
oScript:nClrText := CLR_BLUE

oContato := TSAY():Create(oDlgScript)
oContato:cName := "oContato"
oContato:cCaption := ACI->ACI_CODCON + "  " + Alltrim( FATPDObfuscate(SU5->U5_CONTAT,"U5_CONTAT") )
oContato:nLeft := 80
oContato:nTop := 64
oContato:nWidth := 360
oContato:nHeight := 17
oContato:lShowHint := .F.
oContato:lReadOnly := .F.
oContato:Align := 0
oContato:lVisibleControl := .T.
oContato:lWordWrap := .F.
oContato:lTransparent := .F.
oContato:oFont := oFont14
oContato:nClrText := CLR_BLUE

oEntidade := TSAY():Create(oDlgScript)
oEntidade:cName := "oEntidade"
oEntidade:cCaption := Alltrim( ACI->ACI_CHAVE ) + "  " + If( ACI->ACI_ENTIDA == "SA1", Alltrim(	FATPDObfuscate(SA1->A1_NOME,"A1_NOME") ) + STR0033,; //" (CLIENTE)"
														If( ACI->ACI_ENTIDA == "SUS", Alltrim( 	FATPDObfuscate(SUS->US_NOME,"US_NOME") ) + STR0034,; //" (PROSPECT)"
														If( ACI->ACI_ENTIDA == "ACH", Alltrim( 	FATPDObfuscate(ACH->ACH_RAZAO,"ACH_RAZAO") ) + STR0035, "" ))) //" (SUSPECT)"
oEntidade:nLeft := 80
oEntidade:nTop := 88
oEntidade:nWidth := 600
oEntidade:nHeight := 17
oEntidade:lShowHint := .F.
oEntidade:lReadOnly := .F.
oEntidade:Align := 0
oEntidade:lVisibleControl := .T.
oEntidade:lWordWrap := .F.
oEntidade:lTransparent := .F.
oEntidade:oFont := oFont14
oEntidade:nClrText := CLR_BLUE

oData := TSAY():Create(oDlgScript)
oData:cName := "oData"
oData:cCaption := DToC( ACI->ACI_DATA )
oData:nLeft := 514
oData:nTop := 16
oData:nWidth := 90
oData:nHeight := 17
oData:lShowHint := .F.
oData:lReadOnly := .F.
oData:Align := 0
oData:lVisibleControl := .T.
oData:lWordWrap := .F.
oData:lTransparent := .F.
oData:oFont := oFont14
oData:nClrText := CLR_BLUE

oRotina := TSAY():Create(oDlgScript)
oRotina:cName := "oRotina"
oRotina:cCaption :=	If( ACI->ACI_ROTINA == "1", STR0026 + ACI->ACI_ATEND + ")",;	// Rotina TMK //"Telemarketing ("
					If( ACI->ACI_ROTINA == "2", STR0027 + ACI->ACI_ATEND + ")",;	// Rotina TLV //"Televendas ("
					If( ACI->ACI_ROTINA == "3", STR0028 + ACI->ACI_ATEND + ")",;	// Rotina TCB //"Telecobran็a ("
					If( ACI->ACI_ROTINA == "4", STR0047 + ACI->ACI_ATEND + ")",;	// Rotina TEA //"Teleatendimento ("
					If( ACI->ACI_ROTINA == " ", STR0018, " " )))))					// Agenda do operador ou Cadastro //"Outros"
oRotina:nLeft := 514
oRotina:nTop := 40
oRotina:nWidth := 170
oRotina:nHeight := 17
oRotina:lShowHint := .F.
oRotina:lReadOnly := .F.
oRotina:Align := 0
oRotina:lVisibleControl := .T.
oRotina:lWordWrap := .F.
oRotina:lTransparent := .F.
oRotina:oFont := oFont14
oRotina:nClrText := CLR_BLUE

oTreeScript := DbTree():New( 122/2 /*<nTop>*/, 08/2 /*<nLeft>*/, 490/2 /*<nBottom>*/, 708/2 /*<nRight>*/,;
							 oDlgScript /*<oWnd>*/, /*<{uChange}>*/, /*<{uRClick}>*/,;
							 .T. /*<.lCargo.>*/, /*<.lDisable.>*/ )

TkLoadTree( cCodigo, ACI->ACI_CODSCR, @oTreeScript, lTreeOpen )

oBmpLeg1 := TBITMAP():Create(oDlgScripts)
oBmpLeg1:cName := "oBmpLeg1"
oBmpLeg1:nLeft := 8
oBmpLeg1:nTop := 501
oBmpLeg1:nWidth := 16
oBmpLeg1:nHeight := 16
oBmpLeg1:lShowHint := .F.
oBmpLeg1:lReadOnly := .F.
oBmpLeg1:Align := 0
oBmpLeg1:lVisibleControl := .T.
oBmpLeg1:cResName := "FOLDER13"
oBmpLeg1:lStretch := .F.
oBmpLeg1:lAutoSize := .T.

oSayLeg1 := TSAY():Create(oDlgScripts)
oSayLeg1:cName := "oSayLeg1"
oSayLeg1:cCaption := STR0029 //"Pergunta"
oSayLeg1:nLeft := 35
oSayLeg1:nTop := 505
oSayLeg1:nWidth := 65
oSayLeg1:nHeight := 17
oSayLeg1:lShowHint := .F.
oSayLeg1:lReadOnly := .F.
oSayLeg1:Align := 0
oSayLeg1:lVisibleControl := .T.
oSayLeg1:lWordWrap := .F.
oSayLeg1:lTransparent := .F.

oBmpLeg2 := TBITMAP():Create(oDlgScripts)
oBmpLeg2:cName := "oBmpLeg2"
oBmpLeg2:nLeft := 108
oBmpLeg2:nTop := 501
oBmpLeg2:nWidth := 16
oBmpLeg2:nHeight := 16
oBmpLeg2:lShowHint := .F.
oBmpLeg2:lReadOnly := .F.
oBmpLeg2:Align := 0
oBmpLeg2:lVisibleControl := .T.
oBmpLeg2:cResName := "FOLDER11"
oBmpLeg2:lStretch := .F.
oBmpLeg2:lAutoSize := .T.

oSayLeg2 := TSAY():Create(oDlgScripts)
oSayLeg2:cName := "oSayLeg2"
oSayLeg2:cCaption := STR0030 //"Resposta Selecionada"
oSayLeg2:nLeft := 135
oSayLeg2:nTop := 505
oSayLeg2:nWidth := 145
oSayLeg2:nHeight := 17
oSayLeg2:lShowHint := .F.
oSayLeg2:lReadOnly := .F.
oSayLeg2:Align := 0
oSayLeg2:lVisibleControl := .T.
oSayLeg2:lWordWrap := .F.
oSayLeg2:lTransparent := .F.

oBmpLeg3 := TBITMAP():Create(oDlgScripts)
oBmpLeg3:cName := "oBmpLeg3"
oBmpLeg3:nLeft := 278
oBmpLeg3:nTop := 501
oBmpLeg3:nWidth := 16
oBmpLeg3:nHeight := 16
oBmpLeg3:lShowHint := .F.
oBmpLeg3:lReadOnly := .F.
oBmpLeg3:Align := 0
oBmpLeg3:lVisibleControl := .T.
oBmpLeg3:cResName := "FOLDER6"
oBmpLeg3:lStretch := .F.
oBmpLeg3:lAutoSize := .T.

oSayLeg3 := TSAY():Create(oDlgScripts)
oSayLeg3:cName := "oSayLeg3"
oSayLeg3:cCaption := STR0031 //"Resposta Nใo Selecionada"
oSayLeg3:nLeft := 305
oSayLeg3:nTop := 505
oSayLeg3:nWidth := 145
oSayLeg3:nHeight := 17
oSayLeg3:lShowHint := .F.
oSayLeg3:lReadOnly := .F.
oSayLeg3:Align := 0
oSayLeg3:lVisibleControl := .T.
oSayLeg3:lWordWrap := .F.
oSayLeg3:lTransparent := .F.

oBmpLeg4 := TBITMAP():Create(oDlgScripts)
oBmpLeg4:cName := "oBmpLeg4"
oBmpLeg4:nLeft := 473
oBmpLeg4:nTop := 501
oBmpLeg4:nWidth := 16
oBmpLeg4:nHeight := 16
oBmpLeg4:lShowHint := .F.
oBmpLeg4:lReadOnly := .F.
oBmpLeg4:Align := 0
oBmpLeg4:lVisibleControl := .T.
oBmpLeg4:cResName := "NOTE"
oBmpLeg4:lStretch := .F.
oBmpLeg4:lAutoSize := .T.

oSayLeg4 := TSAY():Create(oDlgScripts)
oSayLeg4:cName := "oSayLeg4"
oSayLeg4:cCaption := STR0032 //"Resposta Dissertativa"
oSayLeg4:nLeft := 500
oSayLeg4:nTop := 505
oSayLeg4:nWidth := 145
oSayLeg4:nHeight := 17
oSayLeg4:lShowHint := .F.
oSayLeg4:lReadOnly := .F.
oSayLeg4:Align := 0
oSayLeg4:lVisibleControl := .T.
oSayLeg4:lWordWrap := .F.
oSayLeg4:lTransparent := .F.

oBtFechar := TBUTTON():Create(oDlgScript)
oBtFechar:cName := "oBtFechar"
oBtFechar:cCaption := STR0014 //"Fechar"
oBtFechar:nLeft := 656
oBtFechar:nTop := 501
oBtFechar:nWidth := 52
oBtFechar:nHeight := 22
oBtFechar:lShowHint := .F.
oBtFechar:lReadOnly := .F.
oBtFechar:lVisibleControl := .T.
oBtFechar:bAction := {|| oDlgScript:End() }

oDlgScript:Activate()

ACI->( RestArea( aAreaACI ) )
SU5->( RestArea( aAreaSU5 ) )
SUO->( RestArea( aAreaSUO ) )
SUZ->( RestArea( aAreaSUZ ) )
(cAliasEnt)->( RestArea( aAreaEnt ) )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkLoadTreeบAutor  ณVendas Clientes     บ Data ณ  29/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a tree de acordo com a estrutura do script dinamico   บฑฑ
ฑฑบ          ณe as respostas dadas pelo usuario durante a execucao.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodigo   - Codigo da execucao de resposta no ACI           บฑฑ
ฑฑบ          ณcScript   - Codigo do script utilizado na execucao          บฑฑ
ฑฑบ          ณoTreeScript - Objeto da Tree                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKXFUNF - TkVisScr                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkLoadTree( cCodigo, cScript, oTreeScript, lOpenTree )
Local aTreeScript	:= {}		// Itens da Tree
Local nTree			:= 0		// Utilizado no laco do tree
Local nItem			:= 0		// Utilizado nos laco do item (respostas) 

Default lOpenTree	:= .F.

SUP->( dbSetOrder(2) ) //UP_FILIAL+UP_CODCAMP+UP_CARGO
SUP->( dbSeek( xFilial("SUP")+cScript ) )
While SUP->( !Eof() .AND. UP_FILIAL+UP_CODCAMP == xFilial("SUP")+cScript )

	If !Empty( SUP->UP_TIPOOBJ )	//Significa que se trata de uma pergunta
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se existem respostas para a pergunta.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aResposta := TkGetResp( cCodigo, cScript, SUP->UP_CARGO, SUP->UP_TIPOOBJ )
		
		aAdd( aTreeScript, { SUP->UP_IDTREE, SUP->UP_CARGO, SUP->UP_DESC,;
							 MSMM(SUP->UP_CODOBS,80), SUP->UP_TIPOOBJ, aResposta } )
	EndIf

	SUP->( dbSkip() )
End

// Inicia o preenchimento do Tree
oTreeScript:BeginUpdate()
oTreeScript:Reset()

For nTree:= 1 To Len(aTreeScript)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao das perguntas no tree. O setimo parametro indica o nivel  do tree. 1-Mesmo nivel, ณ
	//ณ 2-um nivel abaixo.             															 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If oTreeScript:TreeSeek(aTreeScript[nTree,1]) 
		If lOpenTree
			oTreeScript:AddTree(aTreeScript[nTree,3],.T.,"FOLDER12","FOLDER13",,,aTreeScript[nTree,2])
		Else
			oTreeScript:AddItem(aTreeScript[nTree,3],aTreeScript[nTree,2], "FOLDER12","FOLDER13", , ,2)
		EndIf
	Else     
		If lOpenTree                                                                                       
			oTreeScript:AddTree(aTreeScript[nTree,3],.T.,"FOLDER12","FOLDER13",,,aTreeScript[nTree,2])
		Else
			oTreeScript:AddItem(aTreeScript[nTree,3],aTreeScript[nTree,2], "FOLDER12","FOLDER13", , ,1)
		EndIf
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao das respostas no tree.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oTreeScript:TreeSeek(aTreeScript[nTree,2])
	For nItem:= 1 To Len(aTreeScript[nTree,6])
		If (aTreeScript[nTree,6,nItem] <> Nil) 
			oTreeScript:AddItem(aTreeScript[nTree,6,nItem,2],aTreeScript[nTree,6,nItem,1],;
								aTreeScript[nTree,6,nItem,3],aTreeScript[nTree,6,nItem,4], , ,2)
		Endif
	Next nItem

	If lOpenTree
		oTreeScript:EndTree()
	EndIf	
Next nTree

oTreeScript:EndUpdate()
oTreeScript:Refresh()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkGetResp บAutor  ณVendas Clientes     บ Data ณ  29/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณL๊ as alternativas de determinada questao do script e as    บฑฑ
ฑฑบ          ณsinaliza de acordo com a resposta do usuario.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodigo   - Codigo da execucao de resposta no ACI           บฑฑ
ฑฑบ          ณcScript   - Codigo do script utilizado na execucao          บฑฑ
ฑฑบ          ณcCargoPai - Codigo Cargo da questao                         บฑฑ
ฑฑบ          ณcTipoObj  - Tipo da questao (Unica Esc, Mult.Esc, Dissert)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRet      - Array com as alternativas/respostas da questao  บฑฑ
ฑฑบ          ณ    aRet[n,1] Codigo Cargo do Item para a Tree              บฑฑ
ฑฑบ          ณ    aRet[n,2] Texto para exibicao na Tree                   บฑฑ
ฑฑบ          ณ    aRet[n,3] Recurso da folder quando fechado              บฑฑ
ฑฑบ          ณ    aRet[n,4] Recurso da folder quando aberto               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER - TMKXFUNF - TkLoadTree                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkGetResp( cCodigo, cScript, cCargoPai, cTipoObj )
Local aArea		:= SUP->( GetArea() )	// Salva area
Local aRet		:= {}					// Array de retorno
Local aBkp		:= {}					// Array backup
Local nPos		:= 0					// Ponteiro para busca em array
Local nDiss		:= 1					// Contador de dissertativas para geracao de Cargo
Local lSoResp	:= .T.					// Indica se serao exibidas somente as questoes assinaladas

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤDฟ
//ณAlimenta a Tree com as alternativas das perguntas.       ณ
//ณQuestoes dissertarivas serao tratadas diretamente na SUK ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤDู
If cTipoObj <> "3"	// Questao nao dissertativa nao tem alternativas na SUP
	SUP->( dbSetOrder(1) )
	SUP->( dbSeek( xFilial("SUP")+cScript+cCargoPai ) )
	While SUP->( !Eof() .AND. UP_FILIAL+UP_CODCAMP+UP_IDTREE == xFilial("SUP")+cScript+cCargoPai )
			
		If !Empty( SUP->UP_TIPOOBJ )
			dbSkip()
			Loop
		EndIf
		
		AADD( aRet, { SUP->UP_CARGO, SUP->UP_DESC, "FOLDER5", "FOLDER6" } )
			
		SUP->( dbSkip() )
	End
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤTฟ
//ณLe as respostas do questionario na SUK. Para alternativas selecionadas,  ณ
//ณmuda a cor da pasta para verde; para dissertativas, adiciona a resposta. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤTู
SUK->( dbSetOrder(1) )
SUK->( dbSeek( xFilial("SUK")+cCodigo ) )
While SUK->( !Eof() .and. UK_FILIAL+UK_CODIGO == xFilial("SUK")+cCodigo )

	If cTipoObj == "3" .AND. SUK->UK_CODPERG == cCargoPai // Questใo dissertativa
		aAdd( aRet, { "D"+StrZero(nDiss++, 5), MSMM(SUK->UK_CODMEMO,80), "NOTE", "NOTE" } )
	Else
		nPos := aScan( aRet, {|x| x[1] == SUK->UK_CODRESP } )
		If nPos > 0
			aRet[nPos,3] := "FOLDER10"	// Pasta verde para alternativas escolhidas
			aRet[nPos,4] := "FOLDER11"	// Pasta verde para alternativas escolhidas
			If lSoResp
				AAdd(aBkp,aClone(aRet[nPos]))
			EndIf
		EndIf
	EndIf
	SUK->( dbSkip() )
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSubstitui o array com as respostas assinaladasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lSoResp .AND. (cTipoObj <> "3")
	If Len(aBkp) > 0
		aRet := aClone(aBkp)
	EndIf
EndIf

SUP->( RestArea(aArea) )

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkLibLoja บAutor  ณ Vendas CRM         บ Data ณ  03/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControla o semแforo de edi็ใo de or็amento existente da     บฑฑ
ฑฑบ          ณintegra็ใo entre Call Center e Controle de Lojas.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Opera็ใo, seguindo funcionalidade do primeiro parโ- บฑฑ
ฑฑบ          ณmetro da fun็ใo LJ7XSL1.                                    บฑฑ
ฑฑบ          ณExpC2 - (Opcional) N๚mero do n๚mero do atendimento, se o    บฑฑ
ฑฑบ          ณparโmetro nใo for passado, o SUA deve estar posicionado.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER/FATURAMENTO                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkLibLoja(cOper, cNumTlv)
Local cTMKALOJ		:= SuperGetMv("MV_TMKALOJ")
Local cTMKLOJ		:= SuperGetMv("MV_TMKLOJ")
Local lRet			:= .T.
Local aAreaSUA		:= SUA->(GetArea())
Local aAreaSL1		:= SL1->(GetArea())
Local lPosicionado	:= .T.

If ValType(cNumTlv) <> "U" 
	lPosicionado := .F.
EndIf

If (cTMKALOJ == "S" .And. cTMKLOJ == "S")// .And. Val(SUA->UA_OPER) == ORCAMENTO)

	If !lPosicionado
		DbSelectArea("SUA")
		DbSetOrder(1)
		If DbSeek( xFilial("SUA") + cNumTlv )
			lPosicionado := .T.
		Else
			lPosicionado := .F.
		EndIf
	EndIf

	If lPosicionado
		DbSelectArea("SL1")
		DbSetOrder(1)
		If DbSeek( xFilial("SL1") + SUA->UA_NUMSL1 ) .And. Empty(SL1->L1_DOC)
			lRet := LJ7XSL1(cOper)
		EndIf
	EndIf
EndIf

RestArea(aAreaSUA)
RestArea(aAreaSL1)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkFilAC8  บAutor  ณVendas CRM          บ Data ณ  01/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de consulta (F3) Contatos da entidade                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER/FATURAMENTO                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TkFilAC8(nLin)	

Local lRet			:= .F.

Local nL 			:= 0
Local nI 			:= 0
Local nColRet 		:= 0
Local nPosRet		:= 0
Local nOrd			:= 1
Local nPosEntidade 	:= 0
Local nPosCodEnt   	:= 0
Local nRecno		:= 0

Local cEntidade		:= ""
Local cCodCli		:= ""
Local cCodEnt		:= ""
Local cAliasQry 	:= ""
Local cOrd 			:= ""
Local cSeek 		:= Space(30)
Local cFiltroAC8	:= AC8->(DbFilter())
Local cQry 			:= ""
Local cQuery 		:= ""

Local aRet 			:= {""}	  
Local aOrdem 		:= {}
Local aCpo 			:= {}
Local aHead  		:= {}
Local aCol	   		:= {}
	
Local oDlg
Local oTopPanel
Local oMainPanel
Local oBtnPanel1
Local oBtnPanel2	
Local oOrdem	
Local oSeek
Local oPesq
Local oBtn1
Local oBtn2	
Local oBtn3
Local oGet

Local bClique := { |oGet| lRet := (Len(oGet:aCols) > 0) }

DEFAULT nLin := N
SaveInter()

cCodCli	:= 	aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_CODCLI"})]+;
			aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_LOJCLI"})]

cCodEnt	:=	aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_PROSPE"})]+;
			aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_LOJPRO"})]
        
AAdd( aCpo, "AC8_CODCON" ) 
AAdd( aCpo, "U5_CONTAT" )  
AAdd( aCpo, "AC8_ENTIDA" )
AAdd( aCpo, "AC8_CODENT" )
  	
SX3->(dbSetOrder(2)) 

For nI := 1 To Len( aCpo ) 

	SX3->(dbSeek(aCpo[nI]))
        	    	
	SX3->(AAdd(aHead,{	RTrim(X3Titulo()),X3_CAMPO, ;
						"",X3_TAMANHO,;
						X3_DECIMAL, X3_VALID, ;
						X3_USADO, X3_TIPO, ;
						X3_F3, X3_CONTEXT}))	
Next nI    

AAdd( aOrdem, STR0004)		//"Contato"
AAdd( aOrdem, STR0040)		//"Cod.Entidade"

If !Empty(cCodEnt)
	cEntidade	:= "SUS"
Else
	cEntidade	:= "SA1"
EndIf

#IFDEF TOP	   
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSelecao de campos do AC8ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	cQuery := " SELECT AC8_CODCON, AC8_ENTIDA, AC8_CODENT,U5_CODCONT, U5_CONTAT "
  	cQuery += " FROM " + RetSqlName("AC8") +" AC8 "
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณJoin com SU5ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤู
  	cQuery += " INNER JOIN " + RetSqlName("SU5") + " SU5 "
  	cQuery += " ON AC8.AC8_CODCON =  SU5.U5_CODCONT "
	cQuery += " AND SU5.U5_FILIAL = '" + xFilial("SU5") + "'" 
	
	If TcSrvType() != "AS/400"
		cQuery += " AND SU5.D_E_L_E_T_ = '' "
	Else
		cQuery += " AND SU5.@DELETED@ = '' "
	EndIf	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCondicoes de selecao do AC8ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  	cQuery += " WHERE AC8.AC8_FILIAL = '" + xFilial("AC8") + "'"   	
	cQuery += " AND AC8.AC8_ENTIDA = '"+cEntidade+"'"

	If  !EMPTY(cCodEnt)
	  	cQuery += " AND AC8.AC8_CODENT = '" +cCodEnt+"'"      
  	Else
		cQuery += " AND AC8.AC8_CODENT = '" +cCodCli+"'"
	Endif  	
	
	If TcSrvType() != "AS/400"
		cQuery += " AND AC8.D_E_L_E_T_ = '' "
	Else
		cQuery += " AND AC8.@DELETED@ = '' "
	EndIf		
	
	cAliasQry := GetNextAlias()
	
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .F. )

#ELSE 

	cAliasQry	:= "AC8"
	DbSelectArea("AC8")
	DbClearFilter()
	Set Filter To &("AC8->AC8_CODENT == '" + cCodEnt + Space(tamsx3("AC8_CODENT")[1]-Len(cCodEnt)) +"'"+;
					" .AND. AC8->AC8_ENTIDA == '"+cEntidade+"'" )
     	
#ENDIF

(cAliasQry)->(DbGoTop())

While (cAliasQry)->(!EOF())
	AAdd( aCol, Array( Len( aCpo ) + 1 ) )
	nL := Len( aCol )
	
	#IFDEF TOP
		For nI := 1 To Len( aCpo )
			aCol[ nL, nI ] := (cAliasQry)->(FieldGet( FieldPos( aCpo[nI] ) ) )
		Next nI
	#ELSE
		For nI := 1 To Len( aCpo )
			If aCpo[nI] == "U5_CONTAT"
				aCol[ nL, nI ] := Posicione("SU5",1,xFilial("SU5")+(cAliasQry)->AC8_CODCON,"U5_CONTAT")
			Else
				aCol[ nL, nI ] := (cAliasQry)->(FieldGet( FieldPos( aCpo[nI] ) ) )
			EndIf
		Next nI
	#ENDIF
	
	aCol[nL,Len(aCpo)+1] := .F.
	(cAliasQry)->(dbSkip())
End

#IFDEF TOP
	(cAliasQry)->(dbCloseArea())
#ENDIF
   
DEFINE MSDIALOG oDlg TITLE STR0041 FROM 0,0 TO 390,515 PIXEL //"Contatos da Entidade"
	// Definicao de paineis
	@ 0,0 MSPANEL oTopPanel SIZE 250,43
	oTopPanel:Align := CONTROL_ALIGN_TOP
                       
	@ 0,0 MSPANEL oMainPanel SIZE 250,39
	oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 0,0 MSPANEL oBtnPanel1 SIZE 250,15
	oBtnPanel1:Align := CONTROL_ALIGN_BOTTOM
	
	@ 0,0 MSPANEL oBtnPanel2 SIZE 250,15 OF oBtnPanel1
	oBtnPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	// Definicao dos objetos
   	@  3,  3 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 210,36 ON CHANGE (nOrd:=oOrdem:nAt) PIXEL OF oTopPanel 
	@ 17,  3 MSGET oSeek VAR cSeek SIZE 210,10 PIXEL OF oTopPanel
	@  3,215 BUTTON oPesq PROMPT STR0042 SIZE 40,11 PIXEL OF oTopPanel ACTION (TkFilPsq(nOrd,cSeek,oGet)) //"Pesquisar"

	DEFINE SBUTTON oBtn1 FROM 2,2 TYPE 1 ENABLE OF oBtnPanel2 ONSTOP STR0043 ACTION ( Eval(bClique,oGet) ,oDlg:End()) //"Ok"
	oBtn1:lAutDisable := .f.
	
	DEFINE SBUTTON oBtn3 FROM 2,32 TYPE 2 ENABLE OF oBtnPanel2 ONSTOP STR0044 ACTION (oDlg:End()) //"Cancelar"

	oGet := MsNewGetDados():New(5,5,100,232,0,,,,,,,,,,oMainPanel,aHead,aCol)
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet:oBrowse:blDblClick := {|| Eval(bClique,oGet), oDlg:End()}

ACTIVATE MSDIALOG oDlg CENTERED	

If lRet 
	nPosCodEnt   := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "AC8_CODENT" } )	
	nPosEntidade := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "AC8_ENTIDA" } )	
	nPosCto 	 := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "AC8_CODCON" } )
	nPosNome 	 := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "U5_CONTAT" } )
			
	DbSelectArea("AC8")
	AC8->(DBSETORDER(1)) // AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
	lRet := AC8->( DBSEEK(XFILIAL("AC8")+ (oGet:aCols[oGet:nAT ,nPosCto])  +  ALLTRIM(oGet:aCols[oGet:nAT ,nPosEntidade]))) 
	
	If !lRet
		MsgStop(STR0045)//"Nenhum contato foi selecionado"
	EndIf
	
EndIf

RestInter()

AC8->(DbClearFilter())

If !Empty(cFiltroAC8)
	nRecno	:= AC8->(Recno())
	DbSelectArea("AC8")
	Set Filter To &cFiltroAC8
	DbGoto(nRecno)
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTkFilPsq  บAutor  ณVendas CRM          บ Data ณ  01/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de consulta (F3) Contatos da entidade                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnOrd  - Ordem de pesquisa                                   บฑฑ
ฑฑบ          ณcSeek - Chave de pesquisa                                   บฑฑ
ฑฑบ          ณoGet  - Objeto da GetDados                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER/FATURAMENTO                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TkFilPsq(nOrd,cSeek,oGet)

Local nP 		:= 0
Local nColRef	:= 0

If nOrd == 1 
	nColRef	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="AC8_CODCON"})
Else
	nColRef	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="AC8_CODENT"})
EndIf
	
nP := AScan( oGet:aCols, {|x| AllTrim(cSeek) == AllTrim(x[nColRef])} )

If nP > 0      
	oGet:GoTo(nP)
	oGet:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKFree   บAutor  ณVendas CRM          บ Data ณ  30/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLibera a mem๓ria utilizada por um objeto ou array de objetosบฑฑ
ฑฑบ          ณ   Para a libera็ใo de mem๓ria em cascata dos objetos,      บฑฑ
ฑฑบ          ณ   se a classe implementar o m้todo free ele serแ chamado.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณuPar - Objeto ou array de objetos                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER/FATURAMENTO                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKFree( uPar )	
Local nCount	:= 1							// Contador 
Local nAux		:= 0							// Variavel auxiliar para o Len                    
Local cMethFn	:= "MethIsMemberOf"		// A chamada da fun็ใo "MethIsMemberOf" deve ser feita atrav้s de macro-execu็ใo para evitar erros como "Invalid funcion type", em versใo posterior a 11 esse met๓do pode ser substituido pelo tradicional.

If FindFunction( cMethFn )   
	If ValType( uPar ) == "A"
   	nAux := Len( uPar )
		For nCount := 1 TO nAux
			If &cMethFn.(uPar[nCount], 'free' , ) 
				uPar[nCount]:free()
			Endif
			FreeObj( uPar[nCount] )
			uPar[nCount] := Nil
		Next nCount
                               
	ElseIf ValType( uPar ) == "O"
		If &cMethFn.( uPar, 'free' , )
			uPar:free()
		Endif
		FreeObj( uPar )
		uPar := Nil
	Endif
Endif

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKChkColor บAutor  ณVendas CRM        บ Data ณ  20/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Substitui uma legenda colorida por legenda num้rica.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcLegenda - String da imagem original                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER/FATURAMENTO                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKChkColor( cLegenda )
	Local cRet := ""

	aCor := FWChkColor( { {,cLegenda} } )
	cRet := aCor[1][2]

Return cRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuแrio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serใo verificados.
    @param aFields, Array, Array com todos os Campos que serใo verificados, utilizado 
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
    Finaliza o gerenciamento dos campos com prote็ใo de dados.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

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
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun็ใo deve utilizada somente ap๓s 
    a inicializa็ใo das variaveis atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta fun็ใo deve utilizada somente ap๓s a inicializa็ใo das variaveis 
    atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
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
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

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
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

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
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

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