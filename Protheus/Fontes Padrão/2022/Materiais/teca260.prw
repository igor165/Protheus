#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TECA260.CH'

Function TECA260()

MsgInfo(STR0079) //"Assistente Para Cancelamento de Contratos: Rotina Descontinuada!"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260CBOX บAutor  ณVendas e CRM        บ Data ณ  24/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณA partir do nome do campo, localiza no SX3 e retorna array  บฑฑ
ฑฑบ          ณde 2 posicoes {codigo,descri็ใo} do X3_CBOX                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA - Array contendo as opcoes do ComboBox do campo.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Nome do campo do tipo ComboBox.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function At260CBox( cCampoX3 )

Local nI 		:= 0				// Incremento utilizado no loco For.
Local aBox 		:= {}				// Opcoes do campo.
Local aBoxAux  	:= {}				// Opcoes do campo Aux.
Local aRet     	:= {}				// Array com as opcoes do campo separado por elemento.

Default cCampoX3 := ""

dbSelectArea("SX3")
dbSetOrder(2)

If !Empty(cCampoX3) .And. MsSeek(cCampoX3,.F.)

	aBox := STRTOKARR(AllTrim(X3Cbox()), ';')
	For nI := 1 to Len(aBox)
		aBoxAux := STRTOKARR(aBox[nI], '=')
		aAdd(aRet,aBoxAux )
	Next nI

EndIf

Return( aRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260CCtrtบAutor  ณVendas CRM          บ Data ณ  23/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa no ListBox a informacao passada no MsGet.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Listbox para pesquisa.                              บฑฑ
ฑฑบ          ณExpC2 - Texto pesquisado.                                   บฑฑ
ฑฑบ          ณExpO3 - Get da pesquisa.                                    บฑฑ
ฑฑบ          ณExpL4 - Indica se deve pesquisar do inicio(.T.) ou nao(.F.) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function At260Busca( oBrowse, cString, oPesq, lInicio)

Local nCount 	:= 0	// Contador temporแrio
Local nCount2	:= 0	// Contador temporแrio
Local lAchou	:= .F.	// Se encontrou a informa็ใo desejada

Default oPesq := Nil
Default lInicio := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a variแvel da linha inicial de procura.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(nStartLine) <> "N"
	nStartLine := 1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a variแvel da coluna inicial de procura.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(nStartCol) <> "N"
	nStartCol := 1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe ้ para procurar desde o inํcio.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lInicio
	nStartLine	:= 1
	nStartCol	:= 1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcura em todas as linhas e colunas pelo conte๚do solicitado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCount := nStartLine To Len(oBrowse:aArray)

	For nCount2 := nStartCol To Len(oBrowse:aArray[nCount])
		If ValType(oBrowse:aArray[nCount][nCount2]) == "C"
			If Upper(AllTrim(cString)) $ Upper(AllTrim(oBrowse:aArray[nCount][nCount2]))
				oBrowse:nAt := nCount
				oBrowse:Refresh()
				nStartLine	:= nCount
				nStartCol	:= nCount2 + 1
				lAchou := .T.
				Exit
			EndIf
		ElseIf ValType(oBrowse:aArray[nCount][nCount2]) == "D"
			If cTod(AllTrim(cString)) == oBrowse:aArray[nCount][nCount2]
				oBrowse:nAt := nCount
				oBrowse:Refresh()
				nStartLine	:= nCount
				nStartCol	:= nCount2 + 1
				lAchou := .T.
				Exit
			EndIf
		EndIf
	Next nCount2
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe jแ encontrou um resultado, saia.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAchou
		Exit
	Else
		nStartCol := 1
	EndIf

Next nCount

If oPesq <> Nil
	If lAchou
		oPesq:SetColor(CLR_BLACK,CLR_WHITE)
	Else
		oPesq:SetColor(CLR_WHITE,CLR_HRED)
	Endif
EndIf

Return lAchou

/*//Itens do browse de propostas
#DEFINE P_MARCA 	1				// Marcado / Desmarcado.
#DEFINE P_PROPOS	2				// Nr. proposta.
#DEFINE P_REVISA	3				// Revisao da proposta.
#DEFINE P_OPORTU	4 				// Oportunidade.
#DEFINE P_CLIENT	5               // Cod. Cliente.
#DEFINE P_LOJA  	6  				// Loja
#DEFINE P_NOME  	7 				// Nome do Cliente
#DEFINE P_DATA   	8 				// Emissao
#DEFINE P_TIPO   	9 				// Tipo do contrato

//Itens do Alocacao
#DEFINE	 A_NUMOS	1 				// Nr. O/S
#DEFINE	 A_CODAT	2				// Cod. Atendente
#DEFINE A_ATEND		3				// Nome do Atendente
#DEFINE	 A_DTINI	4				// Data Inicial
#DEFINE A_HRINI		5				// Hora Inicial
#DEFINE	 A_DTFIM	6				// Data Final
#DEFINE	 A_HRFIM	7				// Hora Final
#DEFINE	 A_CHEGOU	8				// Chegou ?

//Itens das Ordens
#DEFINE	O_NUMOS		1				// Nr. O/S
#DEFINE	O_EMISS		2				// Emissao
#DEFINE	O_ATEND		3				// Nome do Atendente
#DEFINE	O_STATUS	4				// Status

//Contratos associados a proposta
#DEFINE	C_CONTRAT	1           	// Contrato
#DEFINE	C_NRCONTR	2               // Nr. Contrato
#DEFINE	C_TPCONT	3   			// Tipo do Contrato
#DEFINE	C_INIVIG	4  				// Inicio da Vig๊ncia
#DEFINE	C_FIMVIG	5				// Fim da Vig๊ncia
#DEFINE	C_STATUS	6 				// Situacao
#DEFINE	C_ALIAS		7	  			// Alias


//Variaveis utilizadas na funcao At260Busca
STATIC nStartLine		// Controle de proxima procura
STATIC nStartCol		// Coluna inicial


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTECA260   บAutor  ณVendas CRM          บ Data ณ  20/12/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณWizard para cancelamento do contrato integrado.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGATEC                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Function TECA260()

Local oPanel		:= Nil												// Objeto Panel.
Local oPesq1		:= Nil												// Objeto MsGet.
Local oPesq2		:= Nil												// Objeto MsGet.
Local oPesq3 		:= Nil 												// Objeto MsGet.
Local oWizard 		:= Nil												// Objeto ApWizard.
Local oLbxProp		:= Nil												// Objeto ListBox de propostas.
Local oLbxAtd		:= Nil												// Objeto ListBox Agenda dos Atendentes.
Local oLbxOS		:= Nil												// Objeto ListBox Ordens de Servicos.
Local oLbxCtrt		:= Nil												// Objeto ListBox Contratos.
Local oOk			:= Nil												// Check Marcado.
Local oNo			:= Nil												// Check Desmarcado.
Local oSayAtd		:= Nil												// Objeto TSay.
Local oSayOS		:= Nil												// Objeto TSay.
Local oSayCtrt		:= Nil												// Objeto TSay.
Local bVldBack		:= Nil												// Bloco de codigo a ser executado para validar o botao "Voltar".
Local bVldNext		:= Nil												// Bloco de codigo a ser executado para validar o botao "Avancar".
Local bFinish 		:= Nil												// Bloco de codigo a ser executado para validar o botao "Finalizar".
Local cPesq1		:= Space(40)										// Inicializa espacos em branco no objeto MsGet.
Local cPesq2		:= Space(40)										// Inicializa espacos em branco no objeto MsGet.
Local cPesq3		:= Space(40)										// Inicializa espacos em branco no objeto MsGet.
Local oTFont		:= oTFont := TFont():New('Arial',,14,.T.,.T.)     // Objeto TFont.
Local cTitle 		:= STR0001   										// Assistente.
Local cWizTitle		:= STR0002   										// Assistente para cancelamento do contrato integrado.
Local chMsg			:= STR0003	 										// Cancelamento do Contrato Integrado.
Local cText 		:= STR0004	 										// Este assistente irแ auxiliar no processo de cancelamento do contrato integrado a partir de uma proposta comercial.
Local aCoord		:= {0,0,480,600} 									// Array contendo as coordenadas da tela.
Local aPeriodo		:= {STR0005,STR0006,STR0007,STR0008,STR0009}		// 1 M๊s"###"3 Meses"###"6 Meses"###"1 Ano"###"5 Anos
Local aMeses		:= {1,3,6,12,60}									// Meses que serao listado no combobox.
Local aPropostas	:= {}												// Array com as propostas.
Local aAgenda		:= {}												// Array com agenda dos atendentes.
Local aOrdServ		:= {}												// Array com as ordens de servicos.
Local aContrat		:= {}												// Array com os contratos.
Local cTxtAtd		:= ""												// Nota para mostrar na tela agenda dos atendentes.
Local cTxtOS		:= ""												// Nota para mostrar na tela ordens de servicos.
Local cTxtCtrt		:= ""												// Nota para mostrar na tela contratos.
Local cPeriodo		:= "" 												// Controla o periodo selecionado.
Local cContMnt 		:= ""												// Numero do contrato de manutencao.
Local cGrpCob  		:= ""												// Numero do grubo de cobertura.
Local cContSrv 		:= ""												// Numero do contrato de prestacao de servicos.
Local lCancela		:= .F.												// Valida se o usuario finalizou o wizard para cancelar o contrato integrado.
Local lPanel		:= .T.												// Ativa o Panel do ApWizard.
Local lNoFirst		:= .F.												// Nao exibe o painel de apresentacao.

//Aborta execucao se for versao 11
If ( !AAH->(FieldPos('AAH_STATUS')) > 0 )
	MsgInfo(STR0010) // "Esta op็ใo estแ indisponํvel para versใo atual."
	Return .F.
EndIf

//Inicializa os objetos que exibirao as imagens
oOk := LoadBitMap(GetResources(), "LBOK")
oNo := LoadBitMap(GetResources(), "LBNO")

aPropostas	:= At260Prop(aMeses[1])

bFinish  := {|| lCancela := At260Fim( oLbxProp  , oLbxAtd   , oLbxOS , @cContMnt ,;
                                       @cContSrv , @cGrpCob ) }

bVldNext := {|| At260VdNxt(	 oWizard  , oLbxProp , oLbxAtd , oLbxOS ,;
                             oLbxCtrt , oSayAtd , oSayOS  , oSayCtrt ,;
                             @aAgenda , @aOrdServ, @aContrat ) }

bVldBack := {|| At260VdBck(	oWizard  , oLbxProp , oLbxAtd  , oLbxOS ,;
                            oSayAtd  , oSayOS   , @aAgenda , @aOrdServ ) }

oWizard := ApWizard():New (cWizTitle,chMsg ,cTitle ,cText ,{|| .T.},{|| .T.} ,lPanel ,cResHead,bExecute,lNoFirst ,aCoord )

//NewPanel Propostas Comerciais
oWizard:newPanel( cWizTitle,STR0011,{||.T. },bVldNext,{|| .T.}, .F., {||.T.} )  // "Selecione uma proposta comercial."

//NewPanel Agenda do Atendente
oWizard:newPanel( cWizTitle,STR0012, {||.T.},bVldNext, {||.T.}, .F., {||.T.} )  // "Cancelamento da Agenda dos Atendentes."

//NewPanel Ordem de Servi็o
oWizard:newPanel( cWizTitle,STR0013, bVldBack, bVldNext, {||.T.}, .F., {||.T.} ) // "Efetiva็ใo da Ordem de Servi็o."

//NewPanel Contrato Integrado
oWizard:newPanel( cWizTitle,STR0014, bVldBack, {|| .T.}, bFinish, .F., {||.T.} ) // "Cancelamento do Contrato Integrado."

//Painel para selecao da proposta
oPanel := oWizard:GetPanel(2)

	@ 005,007 MsGet oPesq1 VAR cPesq1 OF oPanel SIZE 105,10 PIXEL
	@ 005,115 BUTTON STR0015	SIZE 30,12 OF oPanel PIXEL Action(At260Busca(@oLbxProp,cPesq1,@oPesq1,.T.))	// "Pesquisar"
	@ 005,150 BUTTON STR0016	SIZE 30,12 OF oPanel PIXEL Action(At260Busca(@oLbxProp,cPesq1,@oPesq1,.F.))    // "Pr๓ximo"
	@ 007,185 SAY STR0017 OF oPanel PIXEL SIZE 90,9 															// "Proposta do(s) ๚ltimo(s)"
	@ 005,258 COMBOBOX oPeriodo VAR cPeriodo ITEMS aPeriodo OF oPanel SIZE 40,10 PIXEL;
		ON CHANGE (	aPropostas := At260Prop(aMeses[oPeriodo:nAt]),;
		   			oLbxProp:SetArray(aPropostas),;
		   			oLbxProp:bLine := { ||{If( aPropostas[oLbxProp:nAt,P_MARCA],oOk,oNo),;
		   										aPropostas[oLbxProp:nAt,P_PROPOS],;
		   										aPropostas[oLbxProp:nAt,P_REVISA],;
												aPropostas[oLbxProp:nAt,P_OPORTU],;
		   							            aPropostas[oLbxProp:nAt,P_CLIENT],;
		   							            aPropostas[oLbxProp:nAt,P_LOJA  ],;
											    aPropostas[oLbxProp:nAt,P_NOME  ],;
		                                     	aPropostas[oLbxProp:nAt,P_DATA  ],;
	   											X3Combo("ADY_TPCONT",aPropostas[oLbxProp:nAt,P_TIPO])}},;
					oLbxProp:Refresh())

	@ 021,007 LISTBOX oLbxProp FIELDS;
			HEADER  ""		,;
					STR0018	,; 		// "Proposta"
					STR0019	,; 		// "Revisใo"
					STR0020 ,;  	// "Oportunidade"
					STR0021	,; 		// "Cliente"
					STR0022	,; 		// "Loja"
					STR0023	,; 		// "Nome"
					STR0024	,; 		// "Emissใo"
					STR0025	,; 		// "Tipo"
			SIZE 290,138 OF oPanel PIXEL;
			ON dblClick(aEval(aPropostas, {|x|x[P_MARCA] := .F.}), aPropostas[oLbxProp:nAt,P_MARCA] := .T., oLbxProp:Refresh())

	oLbxProp:SetArray(aPropostas)
	oLbxProp:bLine := {||{ If(	 aPropostas[oLbxProp:nAt,P_MARCA],oOk,oNo)	,;
								 aPropostas[oLbxProp:nAt,P_PROPOS]			,;
	                             aPropostas[oLbxProp:nAt,P_REVISA]			,;
	                             aPropostas[oLbxProp:nAt,P_OPORTU]			,;
                                 aPropostas[oLbxProp:nAt,P_CLIENT]			,;
                                 aPropostas[oLbxProp:nAt,P_LOJA  ]			,;
                                 aPropostas[oLbxProp:nAt,P_NOME  ]			,;
                                 aPropostas[oLbxProp:nAt,P_DATA  ]			,;
                                 X3Combo("ADY_TPCONT",aPropostas[oLbxProp:nAt,P_TIPO])}}

// Agendamentos dos Atendentes
oPanel := oWizard:GetPanel(3)

aAgenda := {{"","","","","","","",""}}

	@ 005,007 MsGet oPesq2 VAR cPesq2 OF oPanel SIZE 105,10 PIXEL
	@ 005,115 BUTTON STR0015 SIZE 30,12 OF oPanel PIXEL Action(At260Busca(@oLbxAtd,cPesq2,@oPesq2,.T.))				  // "Pesquisar"
	@ 005,150 BUTTON STR0016 SIZE 30,12 OF oPanel PIXEL Action(At260Busca(@oLbxAtd,cPesq2,@oPesq2,.F.))				  // "Pr๓ximo"
	@ 005,197 BUTTON STR0026 SIZE 35,12 OF oPanel PIXEL Action(At260VAtd(oLbxAtd))					   	   				  // "Visualizar"
	@ 005,237 BUTTON "Grade de Aloca็ใo" SIZE 60,12 OF oPanel PIXEL Action((TECA510(),At260AgAtd(oLbxAtd,oLbxOS,oSayAtd,@aAgenda))) // "Grade de Aloca็ใo"

	@ 021,007 LISTBOX oLbxAtd FIELDS;
			HEADER  STR0028	,;	// "Nr. O/S"
					STR0029 ,;	// "Atendente"
					STR0030 ,;	// "Data Inicial"
					STR0031	,; 	// "Hora Inicial"
					STR0032 ,;	// "Data Final"
			   		STR0033 ,;	// "Hora Final"
			SIZE 290,128 OF oPanel PIXEL ON dblClick(At260VAtd(oLbxAtd))

	oSayAtd := TSay():New(152,007,{|| cTxtAtd },oPanel,,oTFont,,,,.T.,CLR_HRED,CLR_WHITE,290,20)

	oLbxAtd:SetArray(aAgenda)
	oLbxAtd:bLine := {||{	aAgenda[oLbxAtd:nAt,A_NUMOS],;
							aAgenda[oLbxAtd:nAt,A_ATEND],;
							aAgenda[oLbxAtd:nAt,A_DTINI],;
							aAgenda[oLbxAtd:nAt,A_HRINI],;
							aAgenda[oLbxAtd:nAt,A_DTFIM],;
							aAgenda[oLbxAtd:nAt,A_HRFIM]}}
	oLbxAtd:Refresh()

// Ordens de Servicos
oPanel := oWizard:GetPanel(4)

aOrdServ := {{"","","",""}}

	@ 005,007 MsGet oPesq3 VAR cPesq3 OF oPanel SIZE 105,10 PIXEL
	@ 005,115 BUTTON STR0015 	SIZE 30,12 OF oPanel PIXEL Action(At260Busca(@oLbxOS,cPesq3,@oPesq3,.T.)) 	   			   	  // "Pesquisar"
	@ 005,150 BUTTON STR0016	SIZE 30,12 OF oPanel PIXEL Action(At260Busca(@oLbxOS,cPesq3,@oPesq3,.F.))					  // "Pr๓ximo"
	@ 005,207 BUTTON STR0026	SIZE 35,12 OF oPanel PIXEL Action(At260VOS(oLbxOS))                            				  // "Visualizar"
	@ 005,247 BUTTON STR0034	SIZE 50,12 OF oPanel PIXEL Action((TECA450(),At260OrdS(oLbxProp,oLbxOS,oSayOS,@aOrdServ)))  // "Ordem de Servi็o"

	@ 021,007 LISTBOX oLbxOS FIELDS;
			HEADER  STR0028 ,;	// "Nr. O/S"
					STR0024 ,;	// "Emissใo"
					STR0029 ,;	// "Atendente"
					STR0035 ,;	// "Status"
			SIZE 290,128 OF oPanel PIXEL ON dblClick(At260VOS(oLbxOS))

	oSayOS := TSay():New(152,007,{|| cTxtOS },oPanel,,oTFont,,,,.T.,CLR_HRED,CLR_WHITE,290,20)

	oLbxOS:SetArray(aOrdServ)
	oLbxOS:bLine := {||	{	aOrdServ[oLbxOS:nAt,O_NUMOS]  ,;
	                      	aOrdServ[oLbxOS:nAt,O_EMISS]  ,;
							aOrdServ[oLbxOS:nAt,O_ATEND]  ,;
							aOrdServ[oLbxOS:nAt,O_STATUS] }}
	oLbxOS:Refresh()


// Contrato Integrado
oPanel := oWizard:GetPanel(5)

aContrat := {{"","","","","","",""}}

	@ 004,237 BUTTON STR0036 SIZE 60,12 OF oPanel PIXEL Action(At260VCtrt(oLbxCtrt))  // "Visualizar Contrato"
	@ 021,007 LISTBOX oLbxCtrt FIELDS;
			HEADER	STR0037 ,; 	// "Contrato"
					STR0038 ,; 	// "Numero"
					STR0039 ,; 	// "Tipo do Contrato"
					STR0040 ,; 	// "Inicio da Vig๊ncia"
					STR0041 ,;	// "Fim da Vig๊ncia"
					STR0072 ,;	// "Situacao"
			SIZE 290,128 OF oPanel PIXEL ON dblClick(At260VContrt(oLbxCtrt))

	oSayCtrt := TSay():New(152,007,{|| cTxtCtrt },oPanel,,oTFont,,,,.T.,CLR_HRED,CLR_WHITE,290,20)

	oLbxCtrt:SetArray(aContrat)
	oLbxCtrt:bLine := {|| {	 aContrat[oLbxCtrt:nAt,C_CONTRAT] ,;
							 aContrat[oLbxCtrt:nAt,C_NRCONTR] ,;
   					         aContrat[oLbxCtrt:nAt,C_TPCONT]  ,;
	                         aContrat[oLbxCtrt:nAt,C_INIVIG]  ,;
	                         aContrat[oLbxCtrt:nAt,C_FIMVIG]  ,;
	                         aContrat[oLbxCtrt:nAt,C_STATUS]  }}
	oLbxCtrt:Refresh()

oWizard:Activate( .T., {||lCancela .OR. MsgYesNo(STR0042)}, <bInit>, <bWhen> ) // "Confirma a saida do assistente para cancelamento do contrato integrado?"

If lCancela

	Aviso(STR0043,;		   	   											// "Cancelamento do Contrato Integrado"
		  STR0044 + CRLF +;    											// "Contrato(s) cancelado com sucesso."
   	      STR0045 + cContMnt + CRLF +; 									// "Contrato de manutencao: "
   	      IIF(!Empty(cGrpCob),(STR0046	 + cGrpCob	+ CRLF),"") +; 		// "Grupo de Cobertura: "
	      IIF(!Empty(cContSrv),(STR0047  + cContSrv + CRLF),""),; 		// "Contrato de Prestacao de Servicos: "
		  {STR0048},2)													// "OK"
EndIf

Return Nil


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260Prop บAutor  ณVendas CRM          บ Data ณ  20/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarga das propostas comerciais do periodo solicitado        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA - Array contendo as propostas.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Quantidade de meses a considerar (retroativamente). บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260Prop(nQtdMeses)

Local aArea		:= GetArea()        				// Guarda area corrente.
Local aAreaAD1	:= AD1->(GetArea())				// Guarda area da tabela AD1.
Local aAreaADY	:= ADY->(GetArea())				// Guarda area da tabela ADY.
Local aAreaAAH	:= AAH->(GetArea())				// Guarda area da tabela AAH.
Local cFilAD1	:= xFilial("AD1")  					// Filial da tabela AD1.
Local cFilADY	:= xFilial("ADY")					// Filial da tabela ADY.
Local cFilAAH	:= xFilial("AAH")					// Filial da tabela AAH.
Local dCorte	:= dDataBase - (nQtdMeses * 30)		// Data de Corte para filtrar no ListBox.
Local cAliasAD1	:= "AD1"							// Alias AD1.
Local cQuery	:= ""								// Armazena a construcao da query.
Local aProp		:= {}								// Array com as propostas.

DbSelectArea("ADY")
DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS

#IFDEF TOP

	cAliasAD1 := GetNextAlias()

	cQuery := "SELECT AD1_FILIAL, AD1_DATA, AD1_STATUS, AD1_PROPOS, AD1_CODCLI, AD1_LOJCLI"
	cQuery += " FROM " + RetSqlName("AD1") + " AD1 INNER JOIN "+ RetSqlName("AAH") + " AAH"
	cQuery += " ON AD1.AD1_PROPOS = AAH.AAH_PROPOS"
	cQuery += " WHERE AD1.AD1_FILIAL = '" + cFilAD1 + "' AND AD1.AD1_DATA >= '" + DtoS(dCorte) + "'"
	cQuery += " AND AD1.AD1_STATUS = '9' AND AD1.AD1_PROPOS <> ''"
	cQuery += " AND AAH.AAH_FILIAL = '" + cFilAAH	+ "' AND AAH.AAH_STATUS = '1'"
	cQuery += " AND AD1.D_E_L_E_T_ = '' AND AAH.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY AD1.AD1_FILIAL, AD1.AD1_DATA, AD1.AD1_NROPOR"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAD1,.T.,.T.)

	TCSetField(cAliasAD1,"AD1_DATA","D")

	While	!(cAliasAD1)->(Eof()) 				.AND.;
		(cAliasAD1)->AD1_FILIAL == cFilAD1	.AND.;
		(cAliasAD1)->AD1_DATA <= dDataBase

		If (cAliasAD1)->AD1_STATUS == "9" .AND. !Empty((cAliasAD1)->AD1_PROPOS)

			If ADY->(Dbseek(cFilADY + (cAliasAD1)->AD1_PROPOS)) .AND. ADY->ADY_PROCES == "S" .AND. ADY->ADY_TPCONT $ "23"

				cNome := POSICIONE("SA1",1,xFilial("SA1")+ADY->ADY_CODIGO+ADY->ADY_LOJA,"A1_NOME")
				//Considerar os DEFINES no inicio do fonte
				aAdd(aProp,{ .F.						,;	// Marca
							  ADY->ADY_PROPOS			,;	// Proposta
			   			      ADY->ADY_PREVIS			,;	// Revisao Proposta
							  ADY->ADY_OPORTU			,;	// Oportunidade
			   			     (cAliasAD1)->AD1_CODCLI	,;	// Codigo
				             (cAliasAD1)->AD1_LOJCLI	,;	// Loja
				              cNome		   				,;	// Nome do cliente
			               	  ADY->ADY_DATA  			,;	// Emissao
				              ADY->ADY_TPCONT			})	// Tipo de contrato
			EndIf

		EndIf

		(cAliasAD1)->(DbSkip())

	End

#ELSE

	DbSelectArea("AD1")
	DbSetOrder(6) //AD1_FILIAL+AD1_DATA+AD1_NROPOR+AD1_REVISA
	DbSeek(xFilial("AD1") + DtoS(dCorte),.T.)

	DbSelectArea("AAH")
	DbSetOrder(6)


	While !(cAliasAD1)->(Eof()) 				.AND.;
		   (cAliasAD1)->AD1_FILIAL == cFilAD1	.AND.;
		   (cAliasAD1)->AD1_DATA <= dDataBase

		If (cAliasAD1)->AD1_STATUS == "9" .AND. !Empty((cAliasAD1)->AD1_PROPOS)

			If ADY->(Dbseek(cFilADY + (cAliasAD1)->AD1_PROPOS)) .AND. ADY->ADY_PROCES == "S" .AND. ADY->ADY_TPCONT $ "23"

				If AAH->(DbSeek(cFilAAH+(cAliasAD1)->AD1_PROPOS))

					If AAH->AAH_STATUS == "1"

						cNome := POSICIONE("SA1",1,xFilial("SA1")+ADY->ADY_CODIGO+ADY->ADY_LOJA,"A1_NOME")
						//Considerar os DEFINES no inicio do fonte
						aAdd(aProp,{ .F.						,;	// Marca
									  ADY->ADY_PROPOS			,;	// Proposta
									  ADY->ADY_PREVIS			,;	// Revisao Proposta
					   			      ADY->ADY_OPORTU			,;	// Oportunidade
						             (cAliasAD1)->AD1_CODCLI	,;	// Codigo
					             	 (cAliasAD1)->AD1_LOJCLI	,;	// Loja
					   			      cNome		   				,;	// Nome do cliente
						              ADY->ADY_DATA  			,;	// Emissao
						              ADY->ADY_TPCONT			})	// Tipo de contrato

					EndIf

				EndIf

			EndIf

		EndIf
		(cAliasAD1)->(DbSkip())

	End

#ENDIF

#IFDEF TOP
	(cAliasAD1)->(DbCloseArea())
#ENDIF

//Se nao encontrou propostas, inicializa um array vazio
If Len(aProp) == 0
	aProp :={{.F.,"","","","","","","",""}}
EndIf

RestArea(aArea)
RestArea(aAreaAD1)
RestArea(aAreaADY)
RestArea(aAreaAAH)

Return( aProp )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt240VldPrบAutor  ณVendas CRM          บ Data ณ  20/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a selecao da proposta comercial                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso 		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto da listbox de Propostas.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260VldPr(oLbxProp)

Local lRet		:= .T.			// Retorno da validacao.
Local nItSel	:= 0			// Item selecionado no ListBox.

nItSel := aScan(oLbxProp:aArray,{|x| x[P_MARCA] })

If nItSel == 0
	// "Selecione a oportunidade / proposta para cancelamento do contrato integrado"
	MsgInfo(STR0049)
	lRet := .F.
ElseIf Empty(oLbxProp:aArray[nItSel][P_PROPOS])
	 // "Nใo hแ nenhuma oportunidade encerrada com propostas para cancelamento do contrato integrado no perํodo selecionado"
	MsgInfo(STR0050)
	lRet := .F.
EndIf

Return ( lRet )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260VdBckบAutor  ณVendas CRM          บ Data ณ  16/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o botao voltar do wizard.                   		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto ApWizard.	                      			  บฑฑ
ฑฑบ			 ณExpO2 - Objeto Listbox de Propostas.                   	  บฑฑ
ฑฑบ			 ณExpO3 - Objeto Listbox da Agenda dos Atendentes.   	      บฑฑ
ฑฑบ			 ณExpO4 - Objeto Listbox de Ordens de Servicos.		          บฑฑ
ฑฑบ			 ณExpO5 - Objeto TSay Agenda dos Atendentes.			      บฑฑ
ฑฑบ			 ณExpO6 - Objeto TSay Ordens de Servicos.			          บฑฑ
ฑฑบ			 ณExpA7 - Array	Agenda dos Atendentes.			        	  บฑฑ
ฑฑบ			 ณExpA8 - Array	Ordens de Servicos.			        	      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA240                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function At260VdBck( oWizard , oLbxProp , oLbxAtd , oLbxOS ,;
							oSayAtd , oSayOS  , aAgenda , aOrdServ )

Local lBack := .T.   // Retorno da validacao.

Do Case

	Case ( oWizard:nPanel == 4 .AND. Empty(oLbxAtd:aArray[1][1]) )
		oWizard:SetPanel(3)
	Case ( oWizard:nPanel == 5 .AND. Empty(oLbxOS:aArray[1][1]) )
		oWizard:SetPanel(3)
	Case ( oWizard:nPanel == 4 .AND. !Empty(oLbxAtd:aArray[1][1]) )
		At260AgAtd( oLbxAtd,oLbxOS,oSayAtd,@aAgenda )
	Case ( oWizard:nPanel == 5 .AND. !Empty(oLbxOS:aArray[1][1]) )
		At260OrdS( oLbxProp,oLbxOS,oSayOS,@aOrdServ )
EndCase

Return ( lBack )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260VdNxtบAutor  ณVendas CRM          บ Data ณ  16/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o botao avancar do wizard.                   		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto ApWizard.	                      			  บฑฑ
ฑฑบ			 ณExpO2 - Objeto Listbox de Propostas.                   	  บฑฑ
ฑฑบ			 ณExpO3 - Objeto Listbox da Agenda dos Atendentes.   	      บฑฑ
ฑฑบ			 ณExpO4 - Objeto Listbox de Ordens de Servicos.		          บฑฑ
ฑฑบ			 ณExpO5 - Objeto Listbox do Contrato Integrado.		 		  บฑฑ
ฑฑบ			 ณExpO6 - Objeto TSay Agenda dos Atendentes.			      บฑฑ
ฑฑบ			 ณExpO7 - Objeto TSay Ordens de Servicos.			          บฑฑ
ฑฑบ			 ณExpO8 - Objeto TSay Contrato Integrado.					  บฑฑ
ฑฑบ			 ณExpA9 - Array Agenda dos Atendentes.			       		  บฑฑ
ฑฑบ			 ณExpA10 - Array Ordens de Servicos.			        	  บฑฑ
ฑฑบ			 ณExpA11 - Array Contrato Integrado.  		        	      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260VdNxt( oWizard  , oLbxProp , oLbxAtd , oLbxOS   ,;
							oLbxCtrt , oSayAtd  , oSayOS  , oSayCtrt ,;
							aAgenda  , aOrdServ , aContrat )

Local lNext		 := .T.     			 // Retorno da validacao.
Local nCount	 := 0
Local dDataAtual := dDataBase  			 // Data atual.
Local cHrAtual	 := SubStr(Time(),1,5)	 // Hora atua

If ( oWizard:nPanel == 2 .AND. !At260VldPr(oLbxProp) )
	lNext := .F.
EndIf

If lNext .AND. oWizard:nPanel == 2

	lNext :=  At260OrdS(oLbxProp,oLbxOS,oSayOS,@aOrdServ)

	If lNext
		lNext := At260AgAtd(oLbxAtd,oLbxOS,oSayAtd,@aAgenda)
		If !lNext
			oWizard:SetPanel(3)
			lNext := .T.
		EndIf
	Else
		At260Ctrt(oLbxProp,oLbxCtrt,oSayCtrt,@aContrat)
		oWizard:SetPanel(4)
		lNext := .T.
	EndIf

ElseIf lNext .AND. oWizard:nPanel == 3

	AEval(oLbxAtd:aArray,{|x| IIF( ( x[A_DTINI] <= dDataAtual .AND. x[A_HRINI] < cHrAtual ) .OR. ( x[A_DTINI] < dDataAtual ),nCount++,Nil)})

	If nCount == 1

			"Existe um agendamento vigente, para continuar o cancelamento do contrato integrado
			 este agendamento deverแ ser cancelado ou atualizado manualmente."

		Aviso(STR0073,STR0074,{STR0076},2)
		lNext := .F.
	ElseIf nCount > 1

			"Existem agendamentos vigentes, para continuar o cancelamento do contrato integrado
			estes agendamentos deverใo ser cancelados ou atualizados manualmente."

		Aviso(STR0073,STR0075,{STR0076},2)
		lNext := .F.
	EndIf

ElseIf lNext .AND. oWizard:nPanel == 4
	At260Ctrt(oLbxProp,oLbxCtrt,oSayCtrt,@aContrat)
EndIf

Return (lNext)


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณAt260OrdS บAutor  ณVendas CRM          บ Data ณ  17/01/12      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as Ordens de Servicos relacionadas o contrato integrado. บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox de Propostas.    		 	             บฑฑ
ฑฑบ			 ณExpO2 - Objeto Listbox de Ordens de Servicos.	                 บฑฑ
ฑฑบ			 ณExpO3 - Objeto TSay Ordens de Servicos.   	      		     บฑฑ
ฑฑบ			 ณExpO4 - Array Ordens de Servicos.		        			     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260OrdS ( oLbxProp , oLbxOS , oSayOS , aOrdServ)

Local aAreaAAH	:= AAH->(GetArea())		// Guarda a area da tabela AAH.
Local aAreaAAM	:= AAM->(GetArea())		// Guarda a area da tabela AAM.
Local aAreaAB6 	:= AB6->(GetArea())		// Guarda a area da tabela AB6.
Local cFilAAH	:= xFilial("AAH")			// Filial da tabela AAH.
Local cFilAAM	:= xFilial("AAM")			// Filial da tabela AAM.
Local cFilAB6 	:= xFilial("AB6")  			// Filial da tabela AB6.
Local lRet		:= .T.						// Retorno da validacao.
Local cCodProp	:= ""						// Cod. da proposta.
Local cRevProp	:= ""						// Revisao da proposta.
Local cCtrtAAH	:= ""						// Numero do contrato de manutencao.
Local cCtrtAAM	:= ""						// Numero do contrato de prestacao de servicos.
Local aBxStatus := {}            			// Opcoes do campo Tp. Status.
Local nPStatus	:= 0						// Posicao no array do status do contrato.
Local nItSel	:= 0  						// Item selecionado no ListBox.

// Localizo a proposta marcada
nItSel 		:= aScan(oLbxProp:aArray,{|x| x[P_MARCA] })
cCodProp 	:= oLbxProp:aArray[nItSel][P_PROPOS]
cRevProp	:= oLbxProp:aArray[nItSel][P_REVISA]

//Seta o array
aOrdServ := {}

DbSelectArea("AAH")
DbSetOrder(6)

// Localizo o Contrato de Manutencao relacionado a proposta
If AAH->(DbSeek(cFilAAH+cCodProp+cRevProp))
	cCtrtAAH := AllTrim(AAH->AAH_CONTRT)
EndIf

DbSelectArea("AAM")
DbSetOrder(3)

// Localizo o Contrato de Prest. Servicos relacionado a proposta
If AAM->(DbSeek(cFilAAM+cCodProp+cRevProp))
	cCtrtAAM := AllTrim(AAM->AAM_CONTRT)
EndIf

DbSelectArea("AB6")

If AB6->(DbSeek(cFilAB6))

	While ( AB6->(!Eof())  .AND. AB6->AB6_FILIAL == cFilAB6 )

		If ( AB6->AB6_CONTRT $ cCtrtAAH+'|'+cCtrtAAM .AND. ;
			AB6->AB6_TPCONT $ '1|2' .AND. AB6->AB6_STATUS $ 'A|B' )

			aBxStatus := At260CBox("AB6_STATUS")
			nPStatus  := aScan(aBxStatus,{|x| x[1] == AB6->AB6_STATUS})
			aAdd(aOrdServ,{ AB6->AB6_NUMOS	,;			// Nr. O/S
							AB6->AB6_EMISSA	,;			// Emissao
		   					AB6->AB6_ATEND	,;		   	// Atendente
							aBxStatus[nPStatus][2]})  	// Status

		EndIf

		AB6->(DbSkip())
	End

EndIf

If Len(aOrdServ) == 0
	lRet := .F.
	aOrdServ := {{"","","",""}}
ElseIf Len(aOrdServ) == 1

		" * Existe uma Ordem de Servi็o aberta / atendida, durante o processamento para cancelamento do
		contrato integrado esta Ordem de Servi็o serแ efetivada automaticamente."

	oSayOS:SetText(STR0051)
ElseIf Len(aOrdServ) > 1

    	"* Existem Ordens de Servi็os aberta / atendida, durante o processamento para cancelamento do
    	contrato integrado estas Ordens de Servi็os serใo efetivadas automaticamente."

	oSayOS:SetText(STR0052)
EndIf

oLbxOS:SetArray(aOrdServ)
oLbxOS:bLine := {||	{ aOrdServ[oLbxOS:nAt,O_NUMOS],;	// Nr. O/S
		 			  aOrdServ[oLbxOS:nAt,O_EMISS],;   // Emissao
	                  aOrdServ[oLbxOS:nAt,O_ATEND],;   // Atendente
                      aOrdServ[oLbxOS:nAt,O_STATUS] }} // Status

RestArea( aAreaAAH )
RestArea( aAreaAAM )
RestArea( aAreaAB6 )

Return ( lRet )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260AgAtdบAutor  ณVendas CRM          บ Data ณ  17/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca os agendamentos dos atendentes. 				      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox da Agenda dos Atendentes. 	          บฑฑ
ฑฑบ			 ณExpO2 - Objeto Listbox de Ordens de Servicos.	              บฑฑ
ฑฑบ			 ณExpO3 - Objeto TSay Agenda dos Atendentes.  	      		  บฑฑ
ฑฑบ			 ณExpO4 - Array Agenda dos Atendentes.	        			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260AgAtd( oLbxAtd , oLbxOS , oSayAtd , aAgenda )

Local aAreaABB		:= ABB->(GetArea())      	// Guarda a area da tabela AAH.
Local cFilABB		:= xFilial("ABB") 			// Filial da tabela ABB.
Local cNomeAt		:= "" 						// Nome do atendente.
Local lShowPanel 	:= .T.						// Retorno da validacao.
Local nX			:= 0 						// Incremento utilizado no laco For.

// Seta o array
aAgenda := {}

//Agenda do Atendente
DbSelectArea("ABB")
DbSetOrder(3)

For nX := 1 To Len(oLbxOS:aArray)

	If (DbSeek(cFilABB+oLbxOS:aArray[nX][A_NUMOS]))

		While ( ABB->(!Eof()) .AND. ;
				ABB->ABB_NUMOS == oLbxOS:aArray[nX][A_NUMOS])

			If ( ABB->ABB_ATENDE == '2' )

				cNomeAt := Posicione("AA1",1,xFilial("AA1") + ABB->ABB_CODTEC,"AA1_NOMTEC")
				aAdd(aAgenda,{	ABB->ABB_NUMOS	,;		// Nr. O/S
			   					ABB->ABB_CODTEC	,;   	// Cod. Atend
			   					cNomeAt			,;		// Nome do Tecnico
			   					ABB->ABB_DTINI	,;		// Data Inicial
			  					ABB->ABB_HRINI	,;		// Hora Inicial
			   					ABB->ABB_DTFIM	,;		// Data Final
			   					ABB->ABB_HRFIM  ,;		// Hora Final
			   					ABB->ABB_CHEGOU })		// Chegou ?
			EndIf

			ABB->(DbSkip())
		End

	EndIf

Next nX


If Len(aAgenda) == 0
	lShowPanel	:= .F.
	aAgenda := {{"","","","","","","",""}}
ElseIf ( Len(aAgenda) == 1 )

		"* Existe um agendamento em aberto para o atendente, durante o processamento para cancelamento do
		   contrato integrado este agendamento serแ cancelado automaticamente."

	oSayAtd:SetText(STR0053)
ElseIf ( Len(aAgenda) > 1 )

	 	"* Existem agendamentos em aberto para o(s) atendente(s), durante o processamento para cancelamento do
	 	   contrato integrado estes agendamentos serใo cancelados automaticamente."

	oSayAtd:SetText(STR0054)
EndIf


ASort (aAgenda,nInicio,nCont,{|a,b| ( a[A_NUMOS] + a[A_CODAT] + DToS(a[A_DTINI]) + a[A_HRINI] ) < ;
											 ( b[A_NUMOS] + b[A_CODAT] + DToS(b[A_DTINI]) + b[A_HRINI] )})

oLbxAtd:SetArray(aAgenda)
oLbxAtd:bLine := {|| {	aAgenda[oLbxAtd:nAt,A_NUMOS],;  // Nr. O/S
						aAgenda[oLbxAtd:nAt,A_ATEND],;  // Atendente
						aAgenda[oLbxAtd:nAt,A_DTINI],;  // Data Inicial
						aAgenda[oLbxAtd:nAt,A_HRINI],;  // Hora Final
						aAgenda[oLbxAtd:nAt,A_DTFIM],;  // Data Final
						aAgenda[oLbxAtd:nAt,A_HRFIM] }} // Hora Final
oLbxAtd:Refresh()

RestArea(aAreaABB)

Return ( lShowPanel )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260Ctrt บAutor  ณVendas CRM          บ Data ณ  17/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca os contratos associados a proposta comercial.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox de Propostas.    		 	          บฑฑ
ฑฑบ			 ณExpO2 - Objeto Listbox do Contrato Integrado.	              บฑฑ
ฑฑบ			 ณExpO3 - Objeto TSay Contrato Integrado.   	      		  บฑฑ
ฑฑบ			 ณExpO4 - Array Contrato Integrado. 		        		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260Ctrt( oLbxProp , oLbxCtrt , oSayCtrt , aContrat)

Local aAreaAAH		:= AAH->(GetArea())			// Guarda a area da tabela AAH.
Local aAreaAAM		:= AAM->(GetArea())			// Guarda a area da tabela AAM.
Local cFilAAH		:= xFilial("AAH")				// Filial da tabela AAH.
Local cFilAAM		:= xFilial("AAM")				// Filial da tabela AAM.
Local cCodProp		:= "" 							// Cod. da proposta.
Local cRevProp		:= "" 							// Revisao da proposta.
Local aBxContrt		:= {} 							// Opcoes do campo Tp. Status.
Local aBxStatus		:= {}                         	// Opcoes do campo Nr. Contrato.
Local nPContrt		:= 0							// Posicao no array do tipo de contrato.
Local nPStatus		:= 0							// Posicao no array do status do contrato.
Local nItSel		:= 0							// Item selecionado no ListBox.


// Localizo a proposta marcada
nItSel 		:= aScan(oLbxProp:aArray,{|x| x[P_MARCA] })
cCodProp 	:= oLbxProp:aArray[nItSel][P_PROPOS]
cRevProp	:= oLbxProp:aArray[nItSel][P_REVISA]

//Seta o array
aContrat := {}

DbSelectArea("AAH")
DbSetOrder(6)

If ( DbSeek( cFilAAH+cCodProp+cRevProp ) .AND. AAH->AAH_STATUS = '1' )

	aBxContrt := At260CBox("AAH_TPCONT")
	nPContrt := aScan(aBxContrt,{|x| x[1] == AAH->AAH_TPCONT})

	aBxStatus := At260CBox("AAH_STATUS")
	nPStatus := aScan(aBxStatus,{|x| x[1] == AAH->AAH_STATUS})

	aAdd(aContrat,{STR0077,AAH->AAH_CONTRT,aBxContrt[nPContrt][2],;   // "Manuten็ใo"
	AAH->AAH_INIVLD,AAH->AAH_FIMVLD,aBxStatus[nPStatus][2],"AAH"})

EndIf

DbSelectArea("AAM")
DbSetOrder(3)

If ( DbSeek( cFilAAM+cCodProp+cRevProp ) .AND. !( AAM->AAM_STATUS $ '3|4' ) )

	aBxContrt := At260CBox("AAM_TPCONT")
	nPContrt := aScan(aBxContrt,{|x| x[1] == AAM->AAM_TPCONT})

	aBxStatus := At260CBox("AAM_STATUS")
	nPStatus := aScan(aBxStatus,{|x| x[1] == AAM->AAM_STATUS})

	aAdd(aContrat,{STR0078,AAM->AAM_CONTRT,aBxContrt[nPContrt][2],;       // "Servi็os"
	AAM->AAM_INIVIG,AAM->AAM_FIMVIG,aBxStatus[nPStatus][2],"AAM"})

EndIf

If ( Len(aContrat) == 0 )
	aContrat := {{"","","","","","",""}}
ElseIf ( Len(aContrat) == 1 .AND. aContrat[1][7] == "AAH" )
	// "* Ao finalizar o assistente o Contrato de Manuten็ใo serแ cancelado."
	oSayCtrt:SetText(STR0055)
ElseIf ( Len(aContrat) == 1 .AND. aContrat[1][7] == "AAM" )
	// "* Ao finalizar o assistente o Contrato de Presta็ใo Servi็os serแ cancelado."
	oSayCtrt:SetText(STR0056)
ElseIf ( Len(aContrat) == 2 )
	// "* Ao finalizar o assistente o Contrato de Manuten็ใo e Contrato de Presta็ใo de Servi็os serใo cancelados."
	oSayCtrt:SetText(STR0057)
EndIf

oLbxCtrt:SetArray(aContrat)
oLbxCtrt:bLine := {|| {	aContrat[oLbxCtrt:nAt,C_CONTRAT],;  	// Contrato
						aContrat[oLbxCtrt:nAt,C_NRCONTR],; 		// Nr. Contrato
						aContrat[oLbxCtrt:nAt,C_TPCONT],;  		// Tipo do Contrato
						aContrat[oLbxCtrt:nAt,C_INIVIG],; 		// Inicio da Vigencia
						aContrat[oLbxCtrt:nAt,C_FIMVIG],;		// Fim da Vigencia
						aContrat[oLbxCtrt:nAt,C_STATUS]}}		// Situacao
oLbxCtrt:Refresh()

RestArea( aAreaAAH )
RestArea( aAreaAAM )

Return ( .T. )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260VAtd บAutor  ณVendas CRM          บ Data ณ  18/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza o agendamento do atendente.				          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox da Agenda dos Atendentes.   		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260VAtd(oLbxAtd)

Local nReg	 	  := 0              // Numero do registro.
Local nOpc		  := 2				// Visualizar.
Local cAlias	  := "ABB"			// Tabela ABB.

Private cCadastro := STR0057	 	// "Agendamento do Atendente"

DbSelectArea(cAlias)
DbSetOrder(4)


DbSeek(xFilial("ABB")+oLbxAtd:aArray[oLbxAtd:nAt,A_CODAT]+DTOS(oLbxAtd:aArray[oLbxAtd:nAt,A_DTINI])+;
       oLbxAtd:aArray[oLbxAtd:nAt,A_HRINI]+oLbxAtd:aArray[oLbxAtd:nAt,A_NUMOS])

nReg := ABB->(Recno())

AxVisual(cAlias,nReg,nOpc)

Return ( .T. )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260VOS  บAutor  ณVendas CRM          บ Data ณ  18/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza a ordem de servico.						          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox de Ordens de Servicos.      		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260VOS(oLbxOS)

Local nReg		    := 0  			// Numero do registro.
Local cAlias	    := "AB6"		// Tabela AB6.

Private cCadastro	:= STR0034 		// "Ordem de Servi็o"
Private aRotina		:= {}			// Variavel com a opcao visualizar.
Private Inclui		:= .F.			// Caso for inclusao.
Private Altera		:= .F.			// Caso for alteracao.

DbSelectArea("AB6")
DbSetOrder(1)

DbSeek(xFilial("AB6")+oLbxOS:aArray[oLbxOS:nAt,O_NUMOS])
nReg := AB6->(Recno())
aRotina := {{STR0026,"AT450Visua",0	,2}} 	// "Visualizar"
AT450Visua(cAlias,nReg,1)

Return ( .T. )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260VCtrtบAutor  ณVendas CRM          บ Data ณ  18/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza o contrato de manutencao					      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox do Contrato Integrado.      		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260VCtrt(oLbxCtrt)

Local nReg		   := 0

Private cCadastro  := ""		// Nome do formulario.
Private Inclui	   := .F. 		// Caso for inclusao.
Private Altera	   := .F.		// Caso for alteracao.
Private aRotina    := {}		// Variavel com a opcao visualizar.

Do Case

	Case ( oLbxCtrt:aArray[oLbxCtrt:nAt][C_ALIAS] == "AAH" )

		DbSelectArea("AAH")
		DbSetOrder(1)
		DbSeek(xFilial("AAH")+oLbxCtrt:aArray[oLbxCtrt:nAt][C_NRCONTR])
		cCadastro := STR0059 							// "Contrato de Manuten็ao"
		aRotina := {{STR0026,"At200Manut",0,2}}   		// "Visualizar"
		nReg := AAH->(Recno())
		At200Manut( "AAH",nReg, 1 )

	Case ( oLbxCtrt:aArray[oLbxCtrt:nAt][C_ALIAS] == "AAM" )

		DbSelectArea("AAM")
		DbSetOrder(1)
		DbSeek(xFilial("AAM")+oLbxCtrt:aArray[oLbxCtrt:nAt][C_NRCONTR])
		nReg := AAM->(Recno())
		cCadastro := STR0060 							// "Contrato de Prestacao de Servi็os"
		aRotina := {{STR0026,"At250Manut",0,2}}		// "Visualizar"

		At250Manut( "AAM",nReg, 1 )

EndCase

Return ( .T. )




ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260Fim  บAutor  ณVendas CRM          บ Data ณ  16/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o botao finalizar do wizard                   		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox de Propostas.  	                  บฑฑ
ฑฑบ			 ณExpO2 - Objeto Listbox da Agenda dos Atendentes.            บฑฑ
ฑฑบ			 ณExpO3 - Objeto Listbox de Ordens de Servicos.	   	          บฑฑ
ฑฑบ			 ณExpC4 - Numero do contrato de manutencao.	                  บฑฑ
ฑฑบ			 ณExpC5 - Numero do contrato de Prestacao de Servicos.	      บฑฑ
ฑฑบ			 ณExpC6 - Numero do Grupo de Cobertura.   	                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260Fim( oLbxProp , oLbxAtd  , oLbxOS , cContMnt ,;
                          cContSrv , cGrpCob )

Local oProcess  := Nil   		// Objeto MsNewProcess.
Local cTitle    := STR0061 		// "Cancelando o contrato integrado aguarde..."
Local cMsg 		:= ""			// Mensagem apresentada na primeira barra de processamento.
Local lRet 		:= .F.			// Retorno da validacao.

// "Confirma o cancelamento do contrato integrado?"
If MsgYesNo(STR0062)
	oProcess := MsNewProcess():New({|| lRet := At260PCan( oLbxProp  , oLbxAtd   , oLbxOS , @oProcess ,;
														   @cContMnt , @cContSrv , @cGrpCob) },cTitle,cMsg,.F.)
	oProcess:Activate()
EndIf

Return( lRet )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260PCan บAutor  ณVendas CRM          บ Data ณ  23/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa o cancelamento do contrato integrado.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox de Propostas.  	                  บฑฑ
ฑฑบ			 ณExpO2 - Objeto Listbox da Agenda dos Atendentes.            บฑฑ
ฑฑบ			 ณExpO3 - Objeto Listbox de Ordens de Servicos.	   	          บฑฑ
ฑฑบ			 ณExpO4 - Objeto Barra de Processamento.         	   	      บฑฑ
ฑฑบ			 ณExpC5 - Numero do contrato de manutencao.	                  บฑฑ
ฑฑบ			 ณExpC6 - Numero do contrato de Prestacao de Servicos.	      บฑฑ
ฑฑบ			 ณExpC7 - Numero do Grupo de Cobertura.   	                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260PCan( oLbxProp , oLbxAtd  , oLbxOS , oProcess ,;
                           cContMnt , cContSrv , cGrpCob )

Local lRet     := .T.   // Retorno da validacao.

Begin Transaction

// Cancela o agendamento
If lRet
	lRet := At260CanAg(oLbxOS,oLbxAtd,oProcess)
EndIf

// Efetivacao daOrdem de Servi็o
If lRet
	lRet := At260OSEnc(oLbxOS,oProcess)
EndIf

// Cancela os contratos
If lRet
	lRet := At260CCtrt( oLbxProp,oProcess,@cContMnt,@cContSrv,@cGrpCob )
EndIf

If !lRet
	DisarmTransaction()
	// "Problemas ao cancelar o contrato integrado."
	MsgStop(STR0063)
EndIf

End Transaction

MsUnlockAll()

Return ( lRet )



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260CanAgบAutor  ณVendas CRM          บ Data ณ  23/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancela os agendamentos dos atendentes.		              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox de Ordens de Servicos.	 			  บฑฑ
ฑฑบ			  ExpO2 - Objeto Listbox da Agenda dos Atendentes.  	      บฑฑ
ฑฑบ			 ณExpO3 - Objeto Barra de Processamento.         	   	      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260CanAg( oLbxOS, oLbxAtd , oProcess)

Local aAreaABB		:= ABB->(GetArea())     // Guarda a area da tabela ABB.
Local cFilABB		:= xFilial("ABB")		 // Filial da tabela ABB.
Local aOs	   		:= {}					 // Array com as ordens de servicos agrupadas.
Local nX			:= 0 				     // Incremento utilizado no laco For.
Local nPos			:= 0 				     // Posicao do numero da ordem de servico no array aOs.
Local nNrOS			:= 0 					 // Numero da ordem de servico.
Local nTot			:= 1                     // Total de registros a processar.
Local dDataAtual	:= dDataBase  			 // Data atual.
Local cHrAtual 		:= SubStr(Time(),1,5)	 // Hora atual.



//Agrupa os agendamentos por O/S.
For nX := 1 To Len (oLbxAtd:aArray)

	nPos := aScan(aOs,oLbxAtd:aArray[nX][A_NUMOS])

	If nPos == 0
		aAdd(aOs,oLbxAtd:aArray[nX][A_NUMOS])
	EndIf

Next nX

nNrOS := Len(aOS)
oProcess:SetRegua1(nNrOS)
oProcess:SetRegua2(nTot)

//Agenda do Atendente
DbSelectArea("ABB")
DbSetOrder(3)

For nX := 1 To nNrOS

	If (DbSeek(cFilABB+aOs[nX]))
		// "Cancelando o(s) agendamento(s) para O/S - "
		oProcess:IncRegua1(STR0064+ABB->ABB_NUMOS)

		While ( ABB->(!Eof()) .AND. ;
			ABB->ABB_NUMOS == aOs[nX])

			If ( ( ( ABB->ABB_DTINI == dDataAtual .AND. ABB->ABB_HRINI >= cHrAtual ) .OR. ;
			       ( ABB->ABB_DTINI > dDataAtual ) ) .AND. ( ABB->ABB_CHEGOU == 'N' .AND. ABB->ABB_ATENDE == '2' ) )

				RecLock("ABB",.F.)
				DbDelete()
				MsUnLock()

				// "Agendamento cancelado com sucesso..."
				oProcess:IncRegua2(STR0065)
			EndIf
			ABB->(DbSkip())
		End
	EndIf

Next nX

RestArea(aAreaABB)

Return ( .T. )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260OSEncบAutor  ณVendas CRM          บ Data ณ  23/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEncerra as Ordens de Servico em aberto.	                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro / Falso                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO3 - Objeto Listbox de Ordens de Servicos.	              บฑฑ
ฑฑบ			 ณExpO4 - Objeto Barra de Processamento.          		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260OSEnc( oLbxOS , oProcess)

Local aAreaAB7		:= AB7->(GetArea())			// Guarda a area da tabela AB7.
Local aAreaAB8		:= AB8->(GetArea())			// Guarda a area da tabela AB8.
Local cFilAB7		:= xFilial("AB7") 	  			// Filial da tabela AB7.
Local cFilAB8		:= xFilial("AB8")				// Filial da tabela AB8.
Local cAuxFunNam	:= FunName()					// Retorna o nome do programa em execucao a partir do menu.
Local lRet 			:= .T.   						// Retorno da validacao.
Local aCabec		:= {} 							// Cabecalho - AB6.
Local aItem			:= {}							// Itens - AB7.
Local nNrOS			:= 0							// Numero da ordem de servico.
Local nX			:= 0  							// Incremento utilizado no laco For.

Private lMsHelpAuto := .T. // Variavel de controle interno do ExecAuto
Private lMsErroAuto := .F. // Variavel que informa a ocorr๊ncia de erros no ExecAuto


DbSelectArea("AB7")
DbSetOrder(1)

DbSelectArea("AB8")
DbSetOrder(1)

nNrOS := Len(oLbxOS:aArray)

oProcess:SetRegua1(0)
oProcess:SetRegua2(nNrOS)

//Encerra as OS abertas associadas ao contrato
For nX := 1 to nNrOS

	aCabec	:= {}
	aItens	:= {}

	aAdd(aCabec,{"AB6_NUMOS",oLbxOS:aArray[nX,1],Nil})


	AB7->(DbSeek(cFilAB7+oLbxOS:aArray[nX,1]))

	//Define o status final de cada item das OSs e as finaliza
	While !AB7->(Eof()) .AND. AB7->AB7_NUMOS == oLbxOS:aArray[nX,A_NUMOS]

		cTipo := ""

		Do Case
			Case ( AB7->AB7_TIPO == '1' )
		   		If ( AB8->(dbSeek(cFilAB8+AB7->(AB7_NUMOS+AB7_ITEM))) )
		   	   		cTipo := "2"
		   	   	Else
		   	   		cTipo := "5"
		   	   	EndIf
			Case ( AB7->AB7_TIPO $ '34' .AND. AB8->(dbSeek(cFilAB8+AB7->(AB7_NUMOS+AB7_ITEM))) )
				cTipo := "2"
		EndCase

		If !Empty(cTipo)
			aItem := {}
			aAdd(aItem,{"LINPOS"	, "AB7_ITEM",AB7->AB7_ITEM})
			aAdd(aItem,{"AB7_TIPO"  , cTipo		,Nil})
			aAdd(aItens,aItem)
		EndIf

		AB7->(DbSkip())
	End

	If Len(aItens) > 0

		lMsHelpAuto := .T.
		lMsErroAuto := .F.
		SetFunName("TECA450")
		// "Encerrando Ordem de Servi็o"
		oProcess:IncRegua1(STR0066)
		MSExecAuto({|a,b,c,d,e| TECA450(a,b,c,d,e)},NIL,aCabec,aItens,NIL,4)

		If lMsErroAuto
			MostraErro()
			lRet := .F.
		EndIf

		SetFunName(cAuxFunNam)
		// "O/S - " #### " encerrada com sucesso..."
		oProcess:IncRegua2(STR0067+oLbxOS:aArray[nX,1]+STR0068)

	EndIf

Next nX

RestArea(aAreaAB7)
RestArea(aAreaAB8)

Return( lRet )


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt260CCtrtบAutor  ณVendas CRM          บ Data ณ  23/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa o cancelamento do contrato integrado.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto Listbox de Propostas.  	                  บฑฑ
ฑฑบ			 ณExpO4 - Objeto Barra de Processamento.         	   	      บฑฑ
ฑฑบ			 ณExpC5 - Numero do contrato de manutencao.	                  บฑฑ
ฑฑบ			 ณExpC6 - Numero do contrato de Prestacao de Servicos.	      บฑฑ
ฑฑบ			 ณExpC7 - Numero do Grupo de Cobertura.   	                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Static Function At260CCtrt( oLbxProp , oProcess , cContMnt , cContSrv ,;
							cGrpCob )

Local aAreaAAH	:= AAH->(GetArea())     		// Guarda a area da tabela AAH.
Local aAreaAAA	:= AAA->(GetArea())			// Guarda a area da tabela AAA.
Local aAreaAAM	:= AAM->(GetArea()) 			// Guarda a area da tabela AAM.
Local cFilAAH	:= xFilial("AAH")				// Filial da tabela AAH.
Local cFilAAA	:= xFilial("AAA")				// Filial da tabela AAA.
Local cFilAAM	:= xFilial("AAM")				// Filial da tabela AAM.
Local cCodProp	:= "" 							// Cod. da proposta.
Local cRevProp	:= "" 							// Revisao da proposta.
Local nItSel	:= 0         					// Item selecionado no ListBox.
Local nTot		:= 3							// Total de registros a processar.


// Localizo a proposta marcada
nItSel 		:= aScan(oLbxProp:aArray,{|x| x[P_MARCA] })
cCodProp 	:= oLbxProp:aArray[nItSel][P_PROPOS]
cRevProp	:= oLbxProp:aArray[nItSel][P_REVISA]


oProcess:SetRegua1(0)
oProcess:SetRegua2(nTot)

DbSelectArea("AAH")
DbSetOrder(6)

If ( DbSeek( cFilAAH+cCodProp+cRevProp ) .AND. AAH->AAH_STATUS = '1' )

	cContMnt := AAH->AAH_CONTRT
	// "Contrato de Manuten็ใo"
	oProcess:IncRegua1(STR0059)

	RecLock("AAH",.F.)
	AAH->AAH_STATUS := '2'
	MsUnLock()
	// "Cancelado com sucesso..."
	oProcess:IncRegua2(STR0069)

	DbSelectArea("AAA")
	DbSetOrder(1)

	If DbSeek(xFilial("AAA")+AAH->AAH_CODGRP)

		cGrpCob := AAA->AAA_CODGRP
		// "Grupo de Cobertura"
		oProcess:IncRegua1(STR0070)

		RecLock("AAA",.F.)
		AAA->AAA_STATUS := '2'
		MsUnLock()
		// "Cancelado com sucesso..."
		oProcess:IncRegua2(STR0069)

	EndIf

EndIf

DbSelectArea("AAM")
DbSetOrder(3)

If ( DbSeek( cFilAAM+cCodProp+cRevProp ) .AND. !( AAM->AAM_STATUS $ '3|4' ) )

	cContSrv := AAM->AAM_CONTRT
	// "Contrato de Presta็ใo de Servi็os"
	oProcess:IncRegua1(STR0071)

	RecLock("AAM",.F.)
	AAM->AAM_STATUS := '4'
	MsUnLock()
	// "Cancelado com sucesso..."
	oProcess:IncRegua2(STR0069)

EndIf

RestArea(aAreaAAH)
RestArea(aAreaAAA)
RestArea(aAreaAAM)

Return ( .T. )

*/