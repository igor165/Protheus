#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "WSResGET.CH"

/*{Protheus.doc} WSResGET
WebService para o Protheus receber a notificacao dos processos do pedido de viagem no Reserve 
e integrar o SIGAPCO possibilitando a continuidade ou bloqueio do pedido
@author TOTVS
@since 28/12/2015
@version 12.1.7 Fev 2016
*/
Function WSResGET ; Return

//--------------------------------------------------------------------------
// Estrutura do Request
//--------------------------------------------------------------------------

//ProcessarPedidosRQ
WSSTRUCT StruProcessarPedidosRQ
	WSDATA Acao		AS STRING		OPTIONAL
	WSDATA Pedido	AS StruPedido	OPTIONAL
ENDWSSTRUCT

//Pedido
WSSTRUCT StruPedido
	WSDATA Empresa				AS STRING				OPTIONAL
	WSDATA IDPedido				AS INTEGER				OPTIONAL
	WSDATA IDGrupo				AS INTEGER				OPTIONAL
	WSDATA IDRemarcacao			AS INTEGER				OPTIONAL
	WSDATA Tipo					AS INTEGER				OPTIONAL
	WSDATA DataCriacao			AS DATE					OPTIONAL
	WSDATA Status				AS INTEGER				OPTIONAL
	WSDATA OrigemPedido			AS INTEGER				OPTIONAL
	WSDATA DataExclusao			AS DATE					OPTIONAL
	WSDATA Excluido				AS BOOLEAN				OPTIONAL
	WSDATA Solicitante			AS StruSolicitante		OPTIONAL
	WSDATA Responsavel			AS StruResponsavel		OPTIONAL
	WSDATA TotalFee				AS FLOAT				OPTIONAL
	WSDATA FormaPgto			AS INTEGER				OPTIONAL
	WSDATA EmpresaAFaturar		AS STRING				OPTIONAL
	WSDATA Emissor				AS StruEmissor			OPTIONAL
	WSDATA DataEmissao			AS DATE					OPTIONAL
	WSDATA DataAutorizacao		AS DATE					OPTIONAL
	WSDATA StatusAutorizacao	AS INTEGER				OPTIONAL
	WSDATA Autorizador			AS StruAutorizador		OPTIONAL
	WSDATA CodAutorizacao		AS STRING				OPTIONAL
	WSDATA CCusto				AS STRING				OPTIONAL
	WSDATA CodigoCCustoCliente	AS STRING				OPTIONAL
	WSDATA Motivo				AS STRING				OPTIONAL
	WSDATA Projeto				AS STRING				OPTIONAL
	WSDATA CodigoProjetoCliente	AS STRING				OPTIONAL
	WSDATA Atividade			AS STRING				OPTIONAL
	WSDATA CampoExtra1			AS STRING				OPTIONAL
	WSDATA CampoExtra2			AS STRING				OPTIONAL
	WSDATA CampoExtra3			AS STRING				OPTIONAL
	WSDATA DataMigracao			AS DATE					OPTIONAL
	WSDATA Passageiros			AS StruPassageiros		OPTIONAL
	WSDATA ReservaEscolhida		AS StruReservaEscolhida	OPTIONAL
ENDWSSTRUCT

//Solicitante
WSSTRUCT StruSolicitante
	WSDATA ID			AS INTEGER	OPTIONAL
	WSDATA CPF			AS STRING	OPTIONAL
	WSDATA RG			AS STRING	OPTIONAL
	WSDATA Matricula	AS STRING	OPTIONAL
	WSDATA Nome			AS STRING	OPTIONAL
	WSDATA Email		AS STRING	OPTIONAL
ENDWSSTRUCT

//Responsavel
WSSTRUCT StruResponsavel
	WSDATA ID			AS INTEGER	OPTIONAL
	WSDATA CPF			AS STRING	OPTIONAL
	WSDATA RG			AS STRING	OPTIONAL
	WSDATA Matricula	AS STRING	OPTIONAL
	WSDATA Nome			AS STRING	OPTIONAL
	WSDATA Email		AS STRING	OPTIONAL
ENDWSSTRUCT

//Emissor
WSSTRUCT StruEmissor
	WSDATA Emissor		AS STRING	OPTIONAL
	WSDATA EmissorEmail	AS STRING	OPTIONAL
ENDWSSTRUCT

//Autorizador
WSSTRUCT StruAutorizador
	WSDATA ID			AS INTEGER	OPTIONAL
	WSDATA CPF			AS STRING	OPTIONAL
	WSDATA RG			AS STRING	OPTIONAL
	WSDATA Matricula	AS STRING	OPTIONAL
	WSDATA Nome			AS STRING	OPTIONAL
	WSDATA Email		AS STRING	OPTIONAL
ENDWSSTRUCT

//Passageiros
WSSTRUCT StruPassageiros
	WSDATA Passageiro AS StruPassageiro OPTIONAL
ENDWSSTRUCT

//Passageiro
WSSTRUCT StruPassageiro
	WSDATA ID			AS INTEGER		OPTIONAL
	WSDATA Nome			AS STRING		OPTIONAL
	WSDATA Email		AS STRING		OPTIONAL
	WSDATA Matricula	AS STRING		OPTIONAL
	WSDATA Autorizado	AS INTEGER		OPTIONAL
	WSDATA Bilhete		AS STRING		OPTIONAL
ENDWSSTRUCT

//ReservaEscolhida
WSSTRUCT StruReservaEscolhida
	WSDATA SisRes				AS STRING						OPTIONAL
	WSDATA Localizador			AS STRING						OPTIONAL
	WSDATA OrigemReserva		AS INTEGER						OPTIONAL
	WSDATA DataReserva			AS DATE							OPTIONAL
	WSDATA TarifaPorPax			AS FLOAT						OPTIONAL
	WSDATA TaxaPorPax			AS FLOAT						OPTIONAL
	WSDATA TaxaServico			AS FLOAT						OPTIONAL
	WSDATA TarifaAcordo			AS FLOAT						OPTIONAL
	WSDATA TarifaPromocional	AS FLOAT						OPTIONAL
	WSDATA Cambio				AS FLOAT						OPTIONAL
	WSDATA Moeda				AS FLOAT						OPTIONAL
	WSDATA MoedaTaxa			AS FLOAT						OPTIONAL
	WSDATA Multa				AS FLOAT						OPTIONAL
	WSDATA Total				AS FLOAT						OPTIONAL
	WSDATA ItensReserva			AS ARRAY OF ItemReserva	OPTIONAL
	WSDATA PrazoEmissao			AS DATE							OPTIONAL
	WSDATA Politicas			AS StruPoliticas				OPTIONAL
ENDWSSTRUCT

//ItemReserva
WSSTRUCT ItemReserva
	WSDATA Internacional		AS BOOLEAN 					OPTIONAL
	WSDATA Acomodacao			AS StruAcomodacao			OPTIONAL
	WSDATA Seguro				AS StruSeguro				OPTIONAL
	WSDATA LocacaoCarro			AS StruLocacaoCarro			OPTIONAL
	WSDATA PassagemRodoviario	AS StruPassagemRodoviario	OPTIONAL
	WSDATA PassagemAereo		AS StruPassagemAereo		OPTIONAL
ENDWSSTRUCT

//Acomodacao
WSSTRUCT StruAcomodacao
	WSDATA IDHotel				AS INTEGER	OPTIONAL
	WSDATA NomeHotel			AS STRING	OPTIONAL
	WSDATA CNPJHotel			AS STRING	OPTIONAL
	WSDATA CodCidade			AS STRING	OPTIONAL
	WSDATA Cidade				AS STRING	OPTIONAL
	WSDATA Checkin				AS DATE		OPTIONAL
	WSDATA Checkout				AS DATE		OPTIONAL
	WSDATA Categoria			AS STRING	OPTIONAL
	WSDATA CategoriaDescricao	AS STRING	OPTIONAL
	WSDATA Diarias				AS INTEGER	OPTIONAL
ENDWSSTRUCT

//Seguro
WSSTRUCT StruSeguro
	WSDATA IDSeguradora		AS INTEGER	OPTIONAL
	WSDATA NomeSeguradora	AS STRING	OPTIONAL
	WSDATA CodCidade		AS STRING	OPTIONAL
	WSDATA Cidade			AS STRING	OPTIONAL
	WSDATA InicioValidade	AS DATE		OPTIONAL
	WSDATA FimValidade		AS DATE		OPTIONAL
	WSDATA Plano			AS STRING	OPTIONAL
	WSDATA PlanoDescricao	AS STRING	OPTIONAL
	WSDATA Diarias			AS INTEGER	OPTIONAL
ENDWSSTRUCT

//LocacaoCarro
WSSTRUCT StruLocacaoCarro
	WSDATA IDLocadora			AS STRING	OPTIONAL
	WSDATA NomeLocadora			AS STRING	OPTIONAL
	WSDATA CodCidadeRetirada	AS STRING	OPTIONAL
	WSDATA CidadeRetirada		AS STRING	OPTIONAL
	WSDATA CodCidadeDevolucao	AS STRING	OPTIONAL
	WSDATA CidadeDevolucao		AS STRING	OPTIONAL
	WSDATA DataRetirada			AS DATE		OPTIONAL
	WSDATA DataDevolucao		AS DATE		OPTIONAL
	WSDATA TipoVeiculo			AS STRING	OPTIONAL
	WSDATA LocalRetirada		AS STRING	OPTIONAL
	WSDATA LocalDevolucao		AS STRING	OPTIONAL
	WSDATA Diarias				AS INTEGER	OPTIONAL
ENDWSSTRUCT

//PassagemRodoviario
WSSTRUCT StruPassagemRodoviario
	WSDATA Voo				AS STRING	OPTIONAL
	WSDATA CodCia			AS STRING	OPTIONAL
	WSDATA NomeCia			AS STRING	OPTIONAL
	WSDATA CodOrigem		AS STRING	OPTIONAL
	WSDATA Origem			AS STRING	OPTIONAL
	WSDATA CodDestino		AS STRING	OPTIONAL
	WSDATA Destino			AS STRING	OPTIONAL
	WSDATA Saida			AS DATE		OPTIONAL
	WSDATA Chegada			AS DATE		OPTIONAL
	WSDATA Classe			AS STRING	OPTIONAL
	WSDATA ClasseDescricao	AS STRING	OPTIONAL
	WSDATA BaseTarifaria	AS STRING	OPTIONAL
	WSDATA Status			AS STRING	OPTIONAL
ENDWSSTRUCT

//PassagemAereo
WSSTRUCT StruPassagemAereo
	WSDATA Voo				AS STRING	OPTIONAL
	WSDATA CodCia			AS STRING	OPTIONAL
	WSDATA NomeCia			AS STRING	OPTIONAL
	WSDATA CodOrigem		AS STRING	OPTIONAL
	WSDATA Origem			AS STRING	OPTIONAL
	WSDATA CodDestino		AS STRING	OPTIONAL
	WSDATA Destino			AS STRING	OPTIONAL
	WSDATA Saida			AS DATE		OPTIONAL
	WSDATA Chegada			AS DATE		OPTIONAL
	WSDATA Classe			AS STRING	OPTIONAL
	WSDATA ClasseDescricao	AS STRING	OPTIONAL
	WSDATA BaseTarifaria	AS STRING	OPTIONAL
	WSDATA Status			AS STRING	OPTIONAL
ENDWSSTRUCT

//Politicas
WSSTRUCT StruPoliticas
	WSDATA MenorTarifa			AS INTEGER	OPTIONAL
	WSDATA AntecedenciaMinima	AS INTEGER	OPTIONAL
	WSDATA CiaPreferencial		AS INTEGER	OPTIONAL
	WSDATA SelecionarCia		AS INTEGER	OPTIONAL
ENDWSSTRUCT

//--------------------------------------------------------------------------
// Estrutura do Response
//--------------------------------------------------------------------------

//ProcessarPedidosRS
WSSTRUCT StruProcessarPedidosRS
	WSDATA PedidoRS	AS StruPedidoRS	OPTIONAL
	WSDATA Erro		AS StruErro		OPTIONAL
ENDWSSTRUCT

//PedidoRS
WSSTRUCT StruPedidoRS
	WSDATA Acao		AS STRING	OPTIONAL //ENUM
	WSDATA IDPedido	AS INTEGER	OPTIONAL
	WSDATA Valor	AS STRING	OPTIONAL
	WSDATA Mensagem	AS STRING	OPTIONAL
ENDWSSTRUCT

//Erro
WSSTRUCT StruErro
	WSDATA CodErro	AS STRING	OPTIONAL
	WSDATA Mensagem	AS STRING	OPTIONAL
ENDWSSTRUCT

//--------------------------------------------------------------------------
// Definicao do Web Service
//--------------------------------------------------------------------------
WSSERVICE ReserveGet
	WSDATA ProcessarPedidosRQ AS StruProcessarPedidosRQ
	WSDATA ProcessarPedidosRS AS StruProcessarPedidosRS
	WSMETHOD ProcessarPedidos
ENDWSSERVICE

/*{Protheus.doc} ProcessarPedidos
Metodo para receber os dados do aplicativo ReserveGET
@author TOTVS
@since 28/12/2015
@version 12.1.7 Fev 2016
*/
WSMETHOD ProcessarPedidos WSRECEIVE ProcessarPedidosRQ  WSSEND ProcessarPedidosRS WSSERVICE ReserveGet
Local cRet		:= ""
Local cErro		:= ""
Local cMsgReduz	:= ""
Local cEmpBkp	:= ""
Local cFilBkp	:= ""
Local lRet		:= .T.
Local cEmpRes	:= ""
Local cFilRes	:= ""
Local lRestAmb	:= .F.
Local lRestFil	:= .F.
Local lWSRGProc	:= ExistBlock("WSRGProc")

//--------------------------------------------------
// Verifica se as Tags necessarias foram informadas
//--------------------------------------------------
If !WSResGetVl(@cErro,::ProcessarPedidosRQ)
	lRet := .F.
	cRet := "Bloquear"
EndIf

//----------------------
// Abertura de Ambiente
//----------------------
If lRet

	If Type('cEmpAnt') == 'U'

		If Select("SM0") <= 0
			OpenSM0()
		EndIf

		SM0->(DbGoTop())

		RpcSetType(3)
		RpcSetEnv(SM0->M0_CODIGO,SM0->M0_CODFIL,,,"PCO","WSResGET")

	EndIf

	//-------------------------------------------------
	// Abertura do ambiente de acordo com a tabela FL2
	//-------------------------------------------------
	DbSelectArea("FL2")
	FL2->(DbSetOrder(2))
	If FL2->(DbSeek(XFilial("FL2")+::ProcessarPedidosRQ:Pedido:Empresa))
		DbSelectArea("SM0")
		SM0->(DbSetOrder(1))
		If SM0->(DbSeek(FL2->FL2_BKOEMP))
			cEmpRes := SM0->M0_CODIGO
			cFilRes := PadR(SM0->M0_CODFIL, FWSizeFilial(cEmpRes))

				If cEmpAnt != cEmpRes
					cEmpBkp := cEmpAnt
					cFilBkp := cFilAnt

					RpcSetType(3)
					RpcClearEnv()
					RpcSetEnv(cEmpRes,cFilRes,,,"PCO","WSResGET")

					lRestAmb := .T.

				ElseIf cFilAnt != cFilRes

					cFilBkp := cFilAnt

					cFilAnt := cFilRes

					lRestFil := .T.

				EndIf

		Else
			lRet	:= .F.
			cErro	+= STR0001 //'A configuração da tabela FL2 possui registro que não se relaciona corretamento ao Protheus.'
			cRet	:= "Bloquear"
		EndIf
	Else
		lRet	:= .F.
		cErro	+= STR0002//'Codigo informado na tag EMPRESA nao configurado no Protheus (FL2).'
		cRet	:= "Bloquear"
	EndIf
EndIf

//--------------------------
// Integracao com o SIGAPCO
//-------------------------- 
If lRet
	//Ponto de entrada para manipulacao dos dados recebidos e da resposta para o Reserve
	If lWSRGProc
		ExecBlock("WSRGProc",.F.,.F.,{::ProcessarPedidosRQ,::ProcessarPedidosRS})
	Else
		WSResGetCO(@cRet,@cErro,::ProcessarPedidosRQ)
	EndIf
EndIf

cMsgReduz	:= WSResGetRA(SubStr(cErro,1,138)) //Limitacao para ser exibido no site Reserve

//------------------------------------
// Resposta para o ReserveGET
//------------------------------------
If !lWSRGProc //Se o ponto de entrada estiver configurado, a atribuicao da resposta deve estar la
	::ProcessarPedidosRS:PedidoRS:Acao		:= cRet
	::ProcessarPedidosRS:PedidoRS:IDPedido	:= ::ProcessarPedidosRQ:Pedido:IDPedido
	::ProcessarPedidosRS:PedidoRS:Valor	:= ""
	::ProcessarPedidosRS:PedidoRS:Mensagem	:= cMsgReduz
	::ProcessarPedidosRS:Erro:CodErro		:= ""
	::ProcessarPedidosRS:Erro:Mensagem		:= ""
EndIf

//-------------------------------------------------
// Fecha o ambiente aberto
//-------------------------------------------------
If lRet

	If lRestAmb

		RpcSetType(3)

		RpcClearEnv()

		RpcSetEnv(cEmpBkp,cFilBkp,,,"PCO","WSResGET")

	ElseIf lRestFil

		cFilAnt := cFilBkp

	EndIf

EndIf

Return .T.

/*{Protheus.doc} WSResGetCO
Funcao de Integracao do ReserveGET com o SIGAPCO
@author TOTVS
@since 28/12/2015
@version 12.1.7 Fev 2016
*/
Static Function WSResGetCO(cRet,cErro,oProcPedRQ)
Local lRet		:= .T.
Local aDados	:= {}
Local cEvento	:= ""
Local cAcao		:= Upper(oProcPedRQ:Acao)
Local nTamCli	:= 0
Local nTamLoja	:= 0
Local nTamAux	:= 0
Local cTpServ	:= oProcPedRQ:Pedido:Tipo
Local nX		:= 0
Local nTamItem	:= 0

//----------------
// Obtem o evento
//----------------
If lRet

	Do Case

		Case cAcao == "PEDIDOINICIOUNOTIFICACAO"
			cEvento := "1"

		Case cAcao == "PEDIDONOTIFICADO"
			cEvento := "2"

		Case cAcao == "PEDIDOINICIOUAUTORIZACAO"
			cEvento := "3"

		Case cAcao == "PEDIDOAUTORIZADO"
			cEvento := "4"

		Case cAcao == "PEDIDOINICIOUEMISSAO"
			cEvento := "5"

		Case cAcao == "PEDIDOEMITIDO"
			cEvento := "6"

		Case cAcao == "PEDIDOCANCELADO"
			cEvento := "7"

		OtherWise
			lRet	:= .F.
			cRet	:= "Bloquear" //Verificar se nesse caso o pedido é bloqueado ou nao é realizada nenhuma acao
			cErro	+= STR0003 //"Tag ACAO inválida ou nao informada."

	EndCase

EndIf

//----------------------------------------------
// Alimenta os dados para chamada do PCO
//----------------------------------------------
If lRet
	Aadd(aDados,{"FO6_FILIAL"	,XFilial("FO6")							})
	Aadd(aDados,{"FO6_IDRESE"	,cValToChar(oProcPedRQ:Pedido:IDPedido)	})
	Aadd(aDados,{"FO6_ACAO"		,cEvento								})
	Aadd(aDados,{"FO6_TIPO"		,cValToChar(oProcPedRQ:Pedido:Tipo) 	})

	If oProcPedRQ:Pedido:CCusto <> Nil
		Aadd(aDados,{"FO6_CC",oProcPedRQ:Pedido:CCusto})
	EndIf

	If oProcPedRQ:Pedido:ReservaEscolhida:Total <> Nil
		Aadd(aDados,{"FO6_TOTAL"	,oProcPedRQ:Pedido:ReservaEscolhida:Total})
	EndIf

	If oProcPedRQ:Pedido:TotalFee <> Nil
		Aadd(aDados,{"FO6_TOTFEE",oProcPedRQ:Pedido:TotalFee})
	EndIf

	If oProcPedRQ:Pedido:Motivo <> Nil
		Aadd(aDados,{"FO6_MOTIVO",oProcPedRQ:Pedido:Motivo})
	EndIf

	If oProcPedRQ:Pedido:Projeto <> NIL .And. SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),2,1) == "1"
		nTamLoja	:= TamSX3("FO6_LOJA")[1]
		nTamCli		:= TamSX3("FO6_CLIENT")[1]
		nTamAux		:= Len(Alltrim(oProcPedRQ:Pedido:Projeto)) - nTamLoja

		Aadd(aDados,{"FO6_CLIENT"	,PadR(SubStr(Alltrim(oProcPedRQ:Pedido:Projeto),1,nTamAux),nTamCli," ")	})
		Aadd(aDados,{"FO6_LOJA"		,Right(Alltrim(oProcPedRQ:Pedido:Projeto),nTamLoja)						})
	EndIf

	If oProcPedRQ:Pedido:Atividade <> Nil
		Aadd(aDados,{"FO6_ATIVI",oProcPedRQ:Pedido:Atividade})
	EndIf

	If oProcPedRQ:Pedido:CampoExtra1 <> Nil
		Aadd(aDados,{"FO6_EXTRA1",oProcPedRQ:Pedido:CampoExtra1})
	EndIf

	If oProcPedRQ:Pedido:CampoExtra2 <> Nil
		Aadd(aDados,{"FO6_EXTRA2",oProcPedRQ:Pedido:CampoExtra2})
	EndIf

	If oProcPedRQ:Pedido:CampoExtra3 <> Nil
		Aadd(aDados,{"FO6_EXTRA3",oProcPedRQ:Pedido:CampoExtra3})
	EndIf

	If oProcPedRQ:Pedido:DataCriacao <> Nil
		Aadd(aDados,{"FO6_DTCRIA",oProcPedRQ:Pedido:DataCriacao})
	EndIf

	If oProcPedRQ:Pedido:DataExclusao <> Nil
		Aadd(aDados,{"FO6_DTCANC",oProcPedRQ:Pedido:DataExclusao})
	EndIf

	If oProcPedRQ:Pedido:DataEmissao <> Nil
		Aadd(aDados,{"FO6_DTEMIS",oProcPedRQ:Pedido:DataEmissao})
	EndIf

	If oProcPedRQ:Pedido:DataAutorizacao <> Nil
		Aadd(aDados,{"FO6_DTAUTO",oProcPedRQ:Pedido:DataAutorizacao})
	EndIf

	If oProcPedRQ:Pedido:DataMigracao <> Nil
		Aadd(aDados,{"FO6_DTMIGR",oProcPedRQ:Pedido:DataMigracao})
	EndIf

	If oProcPedRQ:Pedido:ReservaEscolhida:DataReserva <> Nil
		Aadd(aDados,{"FO6_DTRESE",oProcPedRQ:Pedido:ReservaEscolhida:DataReserva})
	EndIf

	If oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva <> Nil .And. Len(oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva) > 0 

		nTamItem := Len(oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva)

		For nX := 1 To nTamItem

			//Passagem Aerea
			If cTpServ == 1 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemAereo <> Nil

				If nX == 1 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemAereo:Saida <> Nil
					Aadd(aDados,{"FO6_DTSAPA",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemAereo:Saida})
				EndIf

				If nX == nTamItem .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemAereo:Chegada <> Nil
					Aadd(aDados,{"FO6_DTCHPA",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemAereo:Chegada})
				EndIf

			//Acomodação
			ElseIf cTpServ == 2 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Acomodacao <> Nil

				If nX == 1 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Acomodacao:Checkin <> Nil
					Aadd(aDados,{"FO6_DTCIAC",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Acomodacao:Checkin})
				EndIf

				If nX == nTamItem .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Acomodacao:Checkout <> Nil
					Aadd(aDados,{"FO6_DTCOAC",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Acomodacao:Checkout})
				EndIf

			//Locacao Carro
			ElseIf cTpServ == 3 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:LocacaoCarro <> Nil

				If nX == 1 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:LocacaoCarro:DataRetirada <> Nil
					Aadd(aDados,{"FO6_DTRELC",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:LocacaoCarro:DataRetirada})
				EndIf

				If nX == nTamItem .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:LocacaoCarro:DataDevolucao <> Nil
					Aadd(aDados,{"FO6_DTDELC",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:LocacaoCarro:DataDevolucao})
				EndIf

			//Seguro
			ElseIf cTpServ == 4 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Seguro <> Nil

				If nX == 1 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Seguro:InicioValidade <> Nil
					Aadd(aDados,{"FO6_DTIVSE",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Seguro:InicioValidade})
				EndIf	

				If nX == nTamItem .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Seguro:FimValidade <> Nil
					Aadd(aDados,{"FO6_DTFVSE",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:Seguro:FimValidade})
				EndIf

			//Passagem Rodoviario
			ElseIf cTpServ == 5 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemRodoviario <> Nil

				If nX == 1 .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemRodoviario:Saida <> Nil
					Aadd(aDados,{"FO6_DTSAPR",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemRodoviario:Saida})
				EndIf

				If nX == nTamItem .And. oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemRodoviario:Chegada <> Nil
					Aadd(aDados,{"FO6_DTCHPR",oProcPedRQ:Pedido:ReservaEscolhida:ItensReserva[nX]:PassagemRodoviario:Chegada})
				EndIf

			EndIf

		Next nX

	EndIf

EndIf


//------------------------------------------------
// Chama a rotina do PCO para processamento
//------------------------------------------------
If lRet
	If PCOXRES(aDados,cEvento,@cErro)
		cRet := "ConfirmarOperacao"
	Else
		cRet := "Bloquear"
		lRet := .F.
	EndIf
EndIf

Return

/*{Protheus.doc} WSResGetVl
Função para validar se as tags necessarias para o SIGAPCO foram informadas
@author TOTVS
@since 28/12/2015
@version 12.1.7 Fev 2016
*/
Static Function WSResGetVl(cErro,oProcPedRQ)
Local lRet := .T.

If oProcPedRQ:Pedido:Empresa == Nil .Or. Empty(oProcPedRQ:Pedido:Empresa)
	lRet := .F.
	cErro += STR0004 + ' EMPRESA.' //'Informe a Tag'
EndIf

If oProcPedRQ:Pedido:IDPedido == Nil .And. Empty(oProcPedRQ:Pedido:IDPedido)
	lRet := .F.
	cErro += STR0004 + ' IDPEDIDO.'//'Informe a Tag'
EndIf

If oProcPedRQ:Acao == Nil .Or. Empty(oProcPedRQ:Acao)
	lRet := .F.
	cErro += STR0004 + ' ACAO.'//'Informe a Tag'
EndIf

If oProcPedRQ:Pedido:Tipo == Nil .Or. Empty(oProcPedRQ:Pedido:Tipo)
	lRet := .F.
	cErro += STR0004 + ' TIPO.'//'Informe a Tag'
EndIf

If oProcPedRQ:Pedido:ReservaEscolhida:Total == Nil .Or. Empty(oProcPedRQ:Pedido:ReservaEscolhida:Total)
	lRet := .F.
	cErro += STR0004 + ' TOTAL.'//'Informe a Tag'
EndIf

Return lRet

/*{Protheus.doc} PCOReserve
Devido a necessidade de atender a estrutura de resposta esperada pelo Reserve, essa funcao adequa  
algumas tags que o WebService Protheus inclui no Response independente da estrutura definida. Para  
essa função ser executada, deve ser inserida a seguinte instrução no JOB do WEBSERVICE no server.ini

ONCONNECT=PCOReserve

@author TOTVS
@since 28/12/2015
@version 12.1.7 Fev 2016
*/
Function PCOReserve()
Local cXMLResp	:= ""
Local cXMLRet		:= "" 
Local cPedido		:= "" //ID do pedido de viagem gerado no Reserve
Local cAcao		:= "" //Processo que esta em execucao no Reserve
Local cValor		:= "" //Codigo que o ReserveGET precisa que o Protheus envie. Enviamos o ID do pedido de viagem
Local cMsgUser	:= "" //Mensagem de aviso ou alerta a ser exibido para o usuario e gravado no historico do pedido no Reserve
Local cErro		:= "" //Codigo do erro no Protheus
Local cMsgErro	:= "" //Mensagem detalhando o erro ocorrido
Local cError		:= "" 
Local cWarnning	:= ""
Local oXML			:= Nil

cXMLResp := __WSCONNECT()

If Upper(httpHeadIn->Main) == "RESERVEGET" .And. !Empty(cXMLResp) .And. AT("PROCESSARPEDIDOS",cXMLResp) > 0 		

	oXML := XMLParser( cXMLResp, "_" , @cError, @cWarnning)

	If oXML <> Nil .And. Empty(cError) .And. Empty(cWarnning)

		cPedido		:= oXMl:_SOAP_ENVELOPE:_SOAP_BODY:_PROCESSARPEDIDOSRESPONSE:_PROCESSARPEDIDOSRESULT:_PEDIDORS:_IDPEDIDO:TEXT
		cAcao		:= oXMl:_SOAP_ENVELOPE:_SOAP_BODY:_PROCESSARPEDIDOSRESPONSE:_PROCESSARPEDIDOSRESULT:_PEDIDORS:_ACAO:TEXT
		cValor		:= oXMl:_SOAP_ENVELOPE:_SOAP_BODY:_PROCESSARPEDIDOSRESPONSE:_PROCESSARPEDIDOSRESULT:_PEDIDORS:_VALOR:TEXT
		cMsgUser	:= oXMl:_SOAP_ENVELOPE:_SOAP_BODY:_PROCESSARPEDIDOSRESPONSE:_PROCESSARPEDIDOSRESULT:_PEDIDORS:_MENSAGEM:TEXT

		cErro		:= oXMl:_SOAP_ENVELOPE:_SOAP_BODY:_PROCESSARPEDIDOSRESPONSE:_PROCESSARPEDIDOSRESULT:_ERRO:_CODERRO:TEXT
		cMsgErro	:= oXMl:_SOAP_ENVELOPE:_SOAP_BODY:_PROCESSARPEDIDOSRESPONSE:_PROCESSARPEDIDOSRESULT:_ERRO:_MENSAGEM:TEXT

	EndIf

	//----------------------------------------------------------------------------------
	// O retorno eh montado manualmente pois o ReserveGET soh aceita a estrutura abaixo
	//----------------------------------------------------------------------------------
	cXMLRet :=	'<?xml version="1.0" encoding="utf-8"?>'
	cXMLRet +=	'<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cXMLRet +=		'<soap:Header/>'
	cXMLRet +=		'<soap:Body>'
	cXMLRet +=			'<ProcessarPedidosRS xmlns="http://www.reserve.com.br/ReserveGET">'
	cXMLRet +=				'<ProcessarPedidosRS>'
	cXMLRet +=					'<Erro>'
	cXMLRet +=						'<CodErro>' + cErro + '</CodErro>'
	cXMLRet +=						'<Mensagem>' + cMsgErro + '</Mensagem>'
	cXMLRet +=					'</Erro>'
	cXMLRet +=					'<PedidoRS>'
	cXMLRet +=						'<Acao>' +  cAcao + '</Acao>'
	cXMLRet +=						'<IDPedido>'+ cPedido +'</IDPedido>'
	cXMLRet +=						'<Valor>' + cValor + '</Valor>'
	cXMLRet +=						'<Mensagem>' + cMsgUser + '</Mensagem>'
	cXMLRet +=					'</PedidoRS>'
	cXMLRet +=				'</ProcessarPedidosRS>'		
	cXMLRet +=			'</ProcessarPedidosRS>'
	cXMLRet +=		'</soap:Body>'
	cXMLRet +=	'</soap:Envelope>'
Else

	cXMLRet := cXMLResp

EndIf

Return cXMLRet

/*{Protheus.doc} WSResGetRA
Remove acentuacoes para correta exibicao no site Reserve
@author TOTVS
@since 05/05/2016
@version 12.1.7
*/
Static Function WSResGetRA(cString)
Local nX		:= 0 
Local nY		:= 0 
Local cSubStr	:= ""
Local cRetorno	:= ""
Local cStrEsp	:= "ÁÃÂÀáàâãÓÕÔóôõÇçÉÊéêºÚú"
Local cStrEqu	:= "AAAAaaaaOOOoooCcEEeerUu" //char equivalente ao char especial

For nX:= 1 To Len(cString)
	cSubStr := SubStr(cString,nX,1)
	nY := At(cSubStr,cStrEsp)
	If nY > 0 
		cSubStr := SubStr(cStrEqu,nY,1)
	EndIf

	cRetorno += cSubStr
Next nX

Return cRetorno