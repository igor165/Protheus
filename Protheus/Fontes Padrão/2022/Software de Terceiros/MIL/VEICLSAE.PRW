////////////////
// Versao 004 //
////////////////


#include "protheus.ch"
#include "ap5mail.ch"

/*/{Protheus.doc} mil_ver
Versao do fonte modelo novo
@author Andre Luis Almeida
@since 05/12/2017
@version undefined

@type function
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007480_1"

Function VEICLSAE()
Return()

/*/{Protheus.doc} DMS_EstoqueConfig
	Classe criada para encapsular dados de configuracoes do estoque, referentes a parametros ou não
	
	@author Vinicius Gati
	@since  30/07/2014
/*/
Class DMS_EstoqueConfig
	Method New() Constructor
	Method getEstoqueReserva()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_EstoqueConfig
	
	@author Vinicius Gati
	@since  30/07/2014
/*/
Method New() Class DMS_EstoqueConfig
Return Self

/*/{Protheus.doc} EstoqueReserva
	Retorna o codigo do estoque de reserva

	@author Vinicius Gati
	@since  30/07/2014
/*/
Method getEstoqueReserva() Class DMS_EstoqueConfig
Return GetNewPar("MV_RESITE", "")


/*/{Protheus.doc} DMS_EmailHelper
	Classe criada facilitar envio de emails
	
	@author Vinicius Gati
	@since  30/07/2014
/*/
CLASS DMS_EmailHelper
	DATA nSecMax
	DATA cTimeMax

	Method New() CONSTRUCTOR
	Method Send()
	Method SendTemplate()
EndClass

/*/{Protheus.doc} New
	Inicia dados base do email

	@author Vinicius Gati
	@since  07/08/2014

/*/
Method New() Class DMS_EmailHelper
Return SELF

/*/{Protheus.doc} Send
	Atualiza o grupo do produto e propaga a atualização por todos os modulos de concessionária

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method Send(aData) Class DMS_EmailHelper
	Local nIdx     := 1
	Local lEnviado := lConectado := .F.
	Local cError   := "nenhum"
	//
	Local cMailConta := GetNewPar("MV_EMCONTA", 'dpm_info@itmil.com.br') // Usuario/e-mail de envio
	Local cMailSenha := GetNewPar("MV_EMSENHA", "DPM_qwe123!@#") // Senha e-mail de envio
	Local cMailServer:= GetNewPar("MV_RELSERV", 'smtp.itmil.com.br:587') // Server de envio
	Local lAutentica := GetMv("MV_RELAUTH",,.t.)          // Determina se o Servidor de E-mail necessita de Autenticacao
	Local cUserAut   := Alltrim(GetNewPar("MV_RELAUSR",'' )) // Usuario para Autenticacao no Servidor de E-mail
	Local cPassAut   := Alltrim(GetNewPar("MV_RELAPSW",'' )) // Senha para Autenticacao no Servidor de E-mail
	
	oData    := DMS_DataContainer():New(aData)
	cSubject := oData:GetValue('assunto'  , '')
	cBody    := oData:GetValue('mensagem' , '')
	cOrigem  := oData:GetValue('origem'   , '')
	cDestino := oData:GetValue('destino'  , '')
	cArquivo := oData:GetValue('arquivo'  , '')
	
	if EMPTY(cMailConta)
		cMailConta := 'dpm_info@itmil.com.br'
		if EMPTY(cUserAut)
			cUserAut := cMailConta
		EndIf
	EndIf
	If EMPTY(cMailSenha)
		cMailSenha := "DPM_qwe123!@#"
		if EMPTY(cPassAut)
			cPassAut := cMailSenha
		EndIf
	EndIf
	if EMPTY(cMailServer)
		cMailServer := 'smtp.itmil.com.br:587'
	EndIf

	If EMPTY(cOrigem)
		cOrigem  := cMailConta
	EndIf
	If EMPTY(cDestino)
		cDestino := cMailConta
	EndIf

	self:cTimeMax := ( Val(Substr(Time(),1,2))*60*60 ) + ( Val(Substr(Time(),4,2))*60 ) + Val(Substr(Time(),7,2)) + 60 // um minuto pra enviar o email

	if ! EMPTY(cMailServer)
		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lConectado
		If lAutentica
			If ! MailAuth(cUserAut,cPassAut)
				DISCONNECT SMTP SERVER
				conout("VEICLSAE: Falha de conexão com servidor de email. cMailConta:" + cMailConta + ' cMailSenha:' + cMailSenha + ' cUserAut: ' + cUserAut + ' cPassAut:' + cPassAut)
				return .F.
			EndIf
		EndIf
	Else
		conout("VEICLSAE: Falha de conexão com servidor de email. cMailConta:" + cMailConta + ' cMailSenha:' + cMailSenha + ' cUserAut: ' + cUserAut + ' cPassAut:' + cPassAut)
		conout("VEICLSAE: Parâmetros de envio de email não configurados, favor configurar: MV_EMCONTA MV_RELSERV MV_EMSENHA MV_RELAUTH MV_RELAUSR MV_RELAPSW.")
		return .F.
	EndIf

	if lConectado
		For nIdx := 1 To 15 // 15 é o numero de tentativas maximo
			If EMPTY(cArquivo)
				SEND MAIL FROM cOrigem TO cDestino SUBJECT cSubject BODY cBody                     FORMAT TEXT RESULT lEnviado
			Else
				SEND MAIL FROM cOrigem TO cDestino SUBJECT cSubject BODY cBody ATTACHMENT cArquivo FORMAT TEXT RESULT lEnviado
			EndIf

			If lEnviado .Or. self:cTimeMax <= ( Val(Substr(Time(),1,2))*60*60 ) + ( Val(Substr(Time(),4,2))*60 ) + Val(Substr(Time(),7,2))
				EXIT
			Else
				GET MAIL ERROR cError
				conout("VEICLSAE: Falha de envio de email: " + cError)
			EndIf
		Next
	Else
		GET MAIL ERROR cError
		conout("VEICLSAE: Falha de envio de email: " + cError)
	EndIf

	DISCONNECT SMTP SERVER
Return lEnviado

/*/{Protheus.doc} SendTemplate
	Metodo que enviará email de acordo com um template que existirá no nosso servidor itmil.com.br
	Vários poderão ser criados e utilizados a vontade por aqui, eles estão na  pasta /email/ no servidor

	no template, onde existir uma tag nesse exemplo: {{:teste}}, será colocado no lugar o conteúdo passado
	por parametro no aData com :... conforme exemplo abaixo.

	@param aData, DMS_DataContainer, contendo template, titulo, assunto, corpo array com dados, e detalhes que é um array com dados também
		sendo o primeiro elemento sempre o cabeçalho seguido dos itens.
	@example {
		{'template', 'order'},
		{'assunto', 'Criação de Pedido X'},
		{'origem'  , 'origem@itmil.com.br'   },;
		{'destino' , 'destino@itmil.com.br' },;
		{':titulo', 'Pedido X'},
		{':dados_template1', 'TESTE'},
		{':corpo',  {{'Item', 'quantidade'},{'LEITE', 1}, {'Pão', 9}} },
		{':detalhes',  {{'Item', 'detalhe'},{'Coca', 'Estava caro'}, {'Manteiga', 'Não disponível'}} }
	}
	@author Vinicius Gati
	@since  21/05/2014
/*/
Method SendTemplate(aData) Class DMS_EmailHelper
	Local nIdx   := 1
	Local oDados := DMS_DataContainer():New(aData)
	Local oUtil  := DMS_Util():New()
	Local cDados

	cHtmlPage := Httpget('http://www.itmil.com.br/email/'+oDados:GetValue('template')+'.html')

	for nIdx := 1 to LEN(aData)
		cSym := aData[nIdx][1]
		if left(cSym,1) == ":"
			if valtype(aData[nIdx][2]) == "A" // tabela em html
				cDados := oUtil:GerHtmlTable( aData[nIdx][2] )
			else
				cDados := aData[nIdx][2]
			end
			cHtmlPage := STRTRAN(cHtmlPage, "{{"+cSym+"}}", cDados)
		end
	next

	lEnv := self:Send({;
		{'assunto' , oDados:GetValue('assunto') },;
		{'mensagem', EncodeUtf8(cHtmlPage)      },;
		{'origem'  , oDados:GetValue('origem')  },;
		{'destino' , oDados:GetValue('destino') } ;
	})
Return lEnv

/*/{Protheus.doc} DMS_EstoqueConfig
	Classe criada para encapsular dados de configuracoes do estoque, referentes a parametros ou não
	
	@author Vinicius Gati
	@since  30/07/2014
/*/
Class DMS_Estoque
	Method New() Constructor
	Method Transfere()
	Method TransfereLote()
	Method SetItemSD3()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_EstoqueConfig
	
	@author Vinicius Gati
	@since  30/07/2014
/*/
Method New() Class DMS_Estoque
Return Self

/*/{Protheus.doc} Transfere
	Transfere item de um armazem a outro

	Pontos de entrada:

	@author Vinicius Gati
	@since  18/10/2016
/*/
Method Transfere(cB1_COD, cArmFrom, cArmTo, nQtd) Class DMS_Estoque

	Local aItensNew := {}

	Local aItemMov  := {}
	Local oEst      := DMS_Estoque():New()

	BEGIN TRANSACTION

		SB1->(DbSetOrder(1))
		SB1->(DbSeek( xFilial('SB1') + cB1_COD ))
		//
		// Adiciona cabecalho com numero do documento e data da transferencia modelo II
		//
		cDocumento  := Criavar("D3_DOC")
		cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
		cDocumento	:= A261RetINV(cDocumento)
		//
		aadd(aItensNew, { cDocumento, ddatabase })

		aItemMov := oEst:SetItemSD3(SB1->B1_COD ,; //Código do Produto
									cArmFrom    ,;  // Armazém de Origem
									cArmTo      ,; // Armazém de Destino
									            ,; // Localização Origem
									            ,; // Localização Destino
									nQtd        )  // Qtd a transferir

		aAdd(aItensNew, aClone(aItemMov))
		
		If (ExistBlock("VCLSAE1"))
			aItensNew := ExecBlock("VCLSAE1", .f., .f., {aItensNew})
		EndIf

		lMsErroAuto := .F.

		MSExecAuto({|x| MATA261(x)},aItensNew)
	
		If lMsErroAuto
			// Cancela Gravacao
			lRet := .f.
			DisarmTransaction()
			MostraErro()
			cDocumento := "ERRO"
			Break
		EndIf
	END TRANSACTION
	
Return .T.

/*/{Protheus.doc} Transfere
	Transfere item de um armazem a outro e nesse caso levando em consideracao o lote

	@author Vinicius Gati
	@since  19/10/2016
/*/
Method TransfereLote(cB1_COD, cArmFrom, cArmTo, nQtd, cLote, cSubLote) Class DMS_Estoque

	Local aItensNew := {}

	Local aItemMov  := {}
	Local oEst      := DMS_Estoque():New()

	///////////////////////////////////////////////////

	SB1->(DbSetOrder(1))
	SB1->(DbSeek( xFilial('SB1') + cB1_COD ))
	//
	// Adiciona cabecalho com numero do documento e data da transferencia modelo II
	//
	cDocumento  := Criavar("D3_DOC")
	cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
	cDocumento	:= A261RetINV(cDocumento)
	//
	aadd(aItensNew, { cDocumento, ddatabase })

	aItemMov := oEst:SetItemSD3(SB1->B1_COD  ,; //Código do Produto
								cArmFrom     ,;  // Armazém de Origem
								cArmTo       ,; // Armazém de Destino
								             ,; // Localização Origem
								             ,; // Localização Destino
								nQtd         ,; // Qtd a transferir
								cLote        ,; // Nro de lote
								cSubLote      ) // Nro de Sub-Lote

	aAdd(aItensNew, aClone(aItemMov))

	If (ExistBlock("VCLSAE2"))
		aItensNew := ExecBlock("VCLSAE2", .f., .f., {aItensNew})
	EndIf

	lMsErroAuto := .F.

	MSExecAuto({|x| MATA261(x)},aItensNew)

	If lMsErroAuto
		// Cancela Gravacao
		lRet := .f.
		DisarmTransaction()
		MostraErro()
		cDocumento := "ERRO"
	EndIf
Return cDocumento

/*----------------------------------------------------
 Suavizar a nova verificação de integração com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If FindFunction("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return

/*/{Protheus.doc} SetVetorSD3()
	Transfere item de um armazem a outro e nesse caso levando em consideracao o lote

	@author Renato Vinicius
	@since  22/06/2022
/*/

Method SetItemSD3(cCodPro,cArmOrig,cArmDest,cLocOrig,cLocDest,nQtdTrf,cLotect,cNumLot,cNumSer,dDtValid) Class DMS_Estoque

	Local aItensSD3 := {}

	Local l261IntWMS := a261IntWMS()
	Local oPeca      := DMS_Peca():New()
	Local lCAT83     := V240CAT83()

	Local cD3Poten := criavar('D3_POTENCI')
	Local cD3QtSeg := criavar('D3_QTSEGUM')
	Local cD3Estor := criavar('D3_ESTORNO')
	Local cD3NumSq := criavar('D3_NUMSEQ')
	Local cD3Servi := criavar("D3_SERVIC")
	Local cD3ItemG := criavar("D3_ITEMGRD")
	Local cD3IDDCF := criavar("D3_IDDCF")
	Local cD3Obser := criavar("D3_OBSERVA")
	Local cD3CodLn := ""

	If lCAT83
		cD3CodLn := criavar("D3_CODLAN")
	EndIf

	Default cCodPro  := ""
	Default cArmOrig := ""
	Default cArmDest := ""
	Default cLocOrig := ""
	Default cLocDest := ""
	Default nQtdTrf  := 0
	Default cLotect  := criavar('D3_LOTECTL')
	Default cNumLot  := criavar('D3_NUMLOTE')
	Default cNumSer  := criavar('D3_NUMSERI')
	Default dDtValid := criavar('D3_DTVALID')

	SB1->(DbSetOrder(1))
	SB1->(DbSeek( xFilial('SB1') + cCodPro ))

	oPeca:LoadB1()

	IF !Empty(cLotect) .and. Empty(dDtValid)
		dDtValid := oPeca:LoteDtValid(cLotect)
	EndIf

	If !(Localiza(SB1->B1_COD))
		cLocOrig := Space(15)
		cLocDest := Space(15)
	EndIf

	// sequencia
	// produto, descricao, unidade de medida, local/localizacao origem
	// produto, descricao, unidade de medida, local/localizacao destino
	// numero de serie, lote, sublote, data de validade, qunatidade
	// quantidade na 2 unidade, estorno, numero de sequencia

	// Produto Origem
	AADD( aItensSD3 , SB1->B1_COD )
	AADD( aItensSD3 , SB1->B1_DESC )
	AADD( aItensSD3 , SB1->B1_UM )
	AADD( aItensSD3 , cArmOrig )
	AADD( aItensSD3 , cLocOrig )
	// Produto Destino
	AADD( aItensSD3 , SB1->B1_COD )
	AADD( aItensSD3 , SB1->B1_DESC )
	AADD( aItensSD3 , SB1->B1_UM )
	AADD( aItensSD3 , cArmDest )
	AADD( aItensSD3 , cLocDest )
	//
	AADD( aItensSD3 , cNumSer )
	AADD( aItensSD3 , cLotect )
	AADD( aItensSD3 , cNumLot )
	AADD( aItensSD3 , dDtValid )
	AADD( aItensSD3 , cD3Poten )
	AADD( aItensSD3 , nQtdTrf )
	AADD( aItensSD3 , cD3QtSeg )
	AADD( aItensSD3 , cD3Estor )
	AADD( aItensSD3 , cD3NumSq )
	AADD( aItensSD3 , cLotect )
	AADD( aItensSD3 , dDtValid )

	If l261IntWMS
		AADD( aItensSD3 , cD3Servi )
	EndIf

	AADD( aItensSD3 , cD3ItemG )

	If l261IntWMS
		AADD( aItensSD3 , cD3IDDCF )
	EndIf

	If lCAT83
		AADD( aItensSD3 , cD3CodLn )
		AADD( aItensSD3 , cD3CodLn )
	Endif

	AADD( aItensSD3 , cD3Obser )

Return aItensSD3