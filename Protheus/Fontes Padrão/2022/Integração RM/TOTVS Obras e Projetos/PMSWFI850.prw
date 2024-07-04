#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"            
#include "tbiconn.ch"
#include "topconn.ch"
#INCLUDE "PMSWFI850.CH"
#DEFINE _EOL chr(13) + chr(10)

/* --------------------------------------------------------------------------------------
WStruct		stPesq
Autor		Jandir Deodato
Data		19/01/2012
Descricao	Pesquisa dos Títulos a pagar/receber
-------------------------------------------------------------------------------------- */
WSStruct stPesq

	WSData c_TipoAdt as String
	WSData c_Empre as String
	WSData c_Fili as String
	WSData c_Projet as String
	WSData c_TipoCli as String
	WSData c_loja as String
	WSData c_CodCli as String
	WSData c_moed as String

EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stRetPesq
Autor		Jandir Deodato
Data		19/01/2012
Descricao	Retorno da Pesquisa dos titulos a pagar/receber
-------------------------------------------------------------------------------------- */
WSStruct stRetPesq

	WSData c_CodAdt as String
	WSData c_Descr as String
	WSData c_TipoAdt as String
	WSData c_Empre as String
	WSData c_Fili as String
	WSData c_Projet as String
	WSData c_Moed as String
	WSData c_TipoCli as String
	WSData c_Loja as String
	WSData c_CodCli as String
	WSData d_Incl	as Date
	WSData d_venc as Date
	WSData n_valor as Float
	WSData n_Liberado as Integer
	WSData c_Ccusto as String
	WSData c_Prefixo as String
	WSData c_Parcela as String
	WSData c_Tipo as String
	WSData c_Revisa as String
	WSData c_Tarefa as String
	WSData c_EDT as String
	

EndWSStruct
/* --------------------------------------------------------------------------------------
WStruct		stARetPesq
Autor		Jandir Deodato
Data		19/01/2012
Descricao	Array do retorno da pesquisa
-------------------------------------------------------------------------------------- */
WSStruct stARetPesq

	WSData sARetPesq as array of stRetPesq

EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stBloqueia
Autor		Jandir Deodato
Data		19/01/2012
Descricao	Titulo a ser bloqueado no Protheus
-------------------------------------------------------------------------------------- */
WSStruct stBloqueia

	WSData c_Empre as String
	WSData c_Fili as String
	WSData c_Projeto as String
	WSData c_CodAdt as String
	WSData n_Liberado as Integer
	WSData c_TipoAdt as String
	WSData c_Prefixo as String
	WSData c_Parcela as String
	WSData c_Tipo as String
	WSData c_Fornece as String
	WSData c_Loja as String
	WSData c_Revisa as String
	WSData c_Tarefa as String
	WSData c_EDT as String
	
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stRet
Autor		Jandir Deodato
Data		19/01/2012
Descricao	Retorno
-------------------------------------------------------------------------------------- */
WSStruct stRet

	WSData c_Ret as String
	
	
EndWSStruct

/* --------------------------------------------------------------------------------------
WebService	WSFINA850
Autor		Jandir Deodato 
Data		19/01/2012
Descricao	Web Service FINA850_840 - Ordem de Pago e Recebimentos diversos - TOP X Protheus
-------------------------------------------------------------------------------------- */

WSService WSFINA850 Description STR0001//"Ordem de Pago e Recebimentos diversos - TOP X Protheus"
    
    //Declaração de variaveis
	WSData sPesq	    as stPesq
	WSData ARetPesq	 as stARetPesq
	WSData sRet		as stRet
	WSData sBloqueia as stBloqueia
	//WSData oPesquisa as stRetPesq
	
	//Declaracaoo de metodos
	WSMethod Pesquisa			description STR0002 //"Pesquisa dos títulos a Pagar/Receber"
	WSMethod Bloquear			description STR0003 //"Bloqueia ou Desbloqueia um título a Pagar"

ENDWSSERVICE

/*--------------------------------------------------------------------------------------
WSMethod	Pesquisa
Autor		Jandir Deodato
Data		19/01/2012
Descricao	Pesquisa titulos a pagar/receber
Retorno		ARetPesq
--------------------------------------------------------------------------------------*/
WSMethod Pesquisa WSReceive sPesq WSSEND ARetPesq  WSSERVICE WSFINA850

Local cFili		:=""
Local cEmpre		:="" 
Local lRet 		:= .T.
Local cTipoAdt	:=""
Local cProjet		:=""
Local cloja 		:=""
Local cCodCli		:=""
Local cmoed		:=""
Local cQuery
Local cTipoCli	:=""
Local nX
Local cX
local aArea:= GetArea()
Local nValor
Local cAliasTMP

If !(AliasInDic("SEK"))
	lret:=.F.
	SetSoapFault("WSFINA850",OemToAnsi(STR0016 ))//a tabela de ordens de pago nao foi encontrada no sistema
ElseIf !(AliasInDic("SEL"))
	lret:=.F.
	SetSoapFault("WSFINA850",OemToAnsi(STR0017 ))//a tabela de recibo de cobrança nao foi encontrada no sistema
Endif
//Verificação da empresa e filial

IF lRet
	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFili := (::sPesq:c_Fili) 
			cEmpre :=	(::sPesq:c_Empre) 
			lRet :=PMSSM0Env(@cEmpre,@cFili)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSFINA850",STR0018)//Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
			lRet:= .F.
		Endif
	Else
		cFili := Padr( Alltrim(::sPesq:c_Fili)  ,Len(cFilAnt) )
		cEmpre := Padr( Alltrim(::sPesq:c_Empre) ,Len(cEmpAnt) )
		lRet :=PMSSM0Env(cEmpre,cFili)
	Endif
	If !lREt
		SetSoapFault("WSFINA850",OemToAnsi(STR0009))//"Empresa/Filial Inexistente ou não autorizada.Verifique" 
	Endif
Endif
If lRet
	nX:=1
	cX :=CValToChar(nX)
	cMoed		:= AllTrim(::sPesq:c_Moed)
	While  nX<100 .And. !(AllTrim(GetNewPar("MV_SIMB"+cX,'')) == cMoed) //verificando a moeda 
		nX++
		cX :=CValToChar(nX)
	EndDo
		cMoed:=AllTrim(GetNewPar("MV_SIMB"+cX,''))
	If Empty(cmoed)  
		SetSoapFault("WSFINA850",OemToAnsi(STR0008))//"Moeda não existe no Protheus, verifique!"
		lRet:=.F.
	Endif
Endif
If lRet
	dbSelectArea('AFR')//garantindo a abertura das tabelas pelo webservice
	dbSelectArea('AFT')
	dbSelectArea('SEK')
	dbSelectArea('SEL')
	dbSelectArea('SE1')
	dbSelectArea('SE2')
	cTipoAdt	:= ::sPesq:c_TipoAdt
	cProjet	:= ::sPesq:c_Projet
	cLoja		:= ::Spesq:c_Loja
	cCodCli	:= ::sPesq:c_CodCli
	cTipoCli	:=::sPesq:c_TipoCli
	
	If Alltrim(Upper(cTipoAdt)) == "P" .And. Alltrim(Upper(cTipoCli)) == "F"
		cQuery := "SELECT AFR.AFR_FILIAL,AFR.AFR_PREFIX,AFR.AFR_NUM,AFR.AFR_PARCEL,AFR.AFR_TIPO,AFR.AFR_FORNEC,AFR.AFR_LOJA,"
		cQuery	+= "AFR.AFR_PROJET,AFR.AFR_REVISA,AFR.AFR_VALOR1,AFR.AFR_VALOR2,"
		cQuery += "AFR.AFR_VALOR3,AFR.AFR_VALOR4,AFR.AFR_VALOR5,AFR.AFR_DATA,AFR.AFR_VENREA,AFR.AFR_TAREFA,"
		cQuery += " SE2.E2_MOEDA,SE2.E2_EMISSAO  FROM " + RetSqlName("AFR")+" AFR INNER JOIN "
		cQuery +=	RetSqlName("SEK")+" SEK ON "
		cQuery += " AFR.AFR_FILIAL = SEK.EK_FILIAL AND AFR.AFR_PREFIX=SEK.EK_PREFIXO AND AFR.AFR_NUM=SEK.EK_NUM "
		cQuery += " AND AFR.AFR_PARCEL=SEK.EK_PARCELA AND AFR.AFR_TIPO=SEK.EK_TIPO AND AFR.AFR_FORNEC=SEK.EK_FORNECE AND AFR.AFR_LOJA=SEK.EK_LOJA "
		cQuery	+= " INNER JOIN " +RetSqlName("SE2")+" SE2 ON "
		cQuery += " AFR.AFR_FILIAL = SE2.E2_FILIAL AND AFR.AFR_PREFIX=SE2.E2_PREFIXO AND AFR.AFR_NUM=SE2.E2_NUM "
		cQuery += " AND AFR.AFR_PARCEL=SE2.E2_PARCELA AND AFR.AFR_TIPO=SE2.E2_TIPO AND AFR.AFR_FORNEC=SE2.E2_FORNECE AND AFR.AFR_LOJA=SE2.E2_LOJA "
		cQuery += " WHERE AFR.AFR_FILIAL = '" + xFilial("AFR",cFili) + "'"
		cQuery += " AND AFR.AFR_PROJET = '" + cProjet + "'"
		cQuery += " AND AFR.AFR_FORNEC = '" + cCodCli + "'"
		cQuery += " AND AFR.AFR_LOJA = '" + cLoja + "'"
		cQuery += " AND AFR.AFR_VIAINT = ' ' "
		cQuery += " AND AFR.D_E_L_E_T_ = ' ' "
		cQuery += " AND SE2.E2_FILIAL = '" + xFilial("SE2",cFili) + "'"
		cQuery +=	" AND SE2.E2_FORNECE = '" + cCodCli + "'"
		cQuery += " AND SE2.E2_LOJA = '" + cLoja + "'"
		cQuery += " AND (SE2.E2_ORIGEM = 'FINA085A' OR SE2.E2_ORIGEM='FINA850') "
		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
		cQuery += " AND SEK.EK_FILIAL = '" + xFilial("SEK",cFili) + "'"
		cQuery += " AND SEK.EK_FORNECE = '" + cCodCli + "'"
		cQuery += " AND SEK.EK_LOJA = '" + cLoja + "'"
		cQuery += " AND SEK.EK_TIPODOC = 'PA' "
		cQuery += " AND SEK.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		cAliasTMP:=GetNextAlias()
		If Select(cAliasTMP)>0
			(cAliasTMP)->(dbCloseArea())
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTMP, .T., .T.)
		If (cAliasTMP)->(!EOF())
			(cAliasTMP)->(dbGoTop())
			While (cAliasTMP)->(!EOF())
					//If nX <6 //moedas do financeiro
						//nValor:=(cAliasTMP)->&("AFR_VALOR"+cValToChar(nX))
					//Else
					nValor:=xMoeda((cAliasTMP)->AFR_VALOR1,(cAliasTMP)->E2_MOEDA,nX,StoD((cAliasTMP)->E2_EMISSAO))
					//Endif
					aAdd( ::ARetPesq:sARetPesq, ( WsClassNew( 'stRetPesq' ) ) )
					aTail( ::ARetPesq:sARetPesq ):c_CodAdt	:=rTrim((cAliasTMP)->AFR_NUM)
					aTail( ::ARetPesq:sARetPesq ):c_Descr	:= AllTrim(STR0004) //"PAGAMENTO ANTECIPADO"
					aTail( ::ARetPesq:sARetPesq ):c_TipoAdt	:="P"
					aTail( ::ARetPesq:sARetPesq ):c_Empre	:=cEmpre
					aTail( ::ARetPesq:sARetPesq ):c_Fili	:=cFili
					aTail( ::ARetPesq:sARetPesq ):c_Projet	:=rTrim((cAliasTMP)->AFR_PROJET)
					aTail( ::ARetPesq:sARetPesq ):c_Moed	:=cMoed
					aTail( ::ARetPesq:sARetPesq ):c_TipoCli	:=cTipoCli
					aTail( ::ARetPesq:sARetPesq ):c_Loja	:=rTrim((cAliasTMP)->AFR_LOJA)
					aTail( ::ARetPesq:sARetPesq ):c_CodCli	:=rTrim((cAliasTMP)->AFR_FORNEC)
					aTail( ::ARetPesq:sARetPesq ):d_Incl	:=StoD((cAliasTMP)->E2_EMISSAO)
					aTail( ::ARetPesq:sARetPesq ):d_Venc	:=StoD((cAliasTMP)->AFR_VENREA)
					aTail( ::ARetPesq:sARetPesq ):n_Valor	:=nValor
					aTail( ::ARetPesq:sARetPesq ):n_Liberado	:=0
					aTail( ::ARetPesq:sARetPesq ):c_cCusto	:=GetMv("MV_RMCCUST")
					aTail( ::ARetPesq:sARetPesq ):c_Prefixo	:=rTrim((cAliasTMP)->AFR_PREFIX)
					aTail( ::ARetPesq:sARetPesq ):c_Parcela	:=rTrim((cAliasTMP)->AFR_PARCEL)
					aTail( ::ARetPesq:sARetPesq ):c_Tipo	:=rTrim((cAliasTMP)->AFR_TIPO)
					aTail( ::ARetPesq:sARetPesq ):c_Revisa	:=rTrim((cAliasTMP)->AFR_REVISA)
					aTail( ::aRetPesq:sAretPesq ):c_Tarefa := rTrim((cAliasTMP)->AFR_TAREFA)
					aTail( ::aRetPesq:sAretPesq ):c_EDT := ""
					
					(cAliasTMP)->(dbSkip())
			EndDo
		Else
			SetSoapFault("WSFINA850",STR0005)//"Não existe registro relacionado a esta consulta"
			lRet:=.F.
		Endif
		(cAliasTMP)->(dbCloseArea())
	ElseIf Alltrim(Upper(cTipoAdt)) =="R" .and. Alltrim(Upper(cTipoCli)) == "C"
		cQuery := "SELECT AFT.AFT_FILIAL,AFT.AFT_PREFIX,AFT.AFT_NUM,AFT.AFT_PARCEL,AFT.AFT_TIPO,AFT.AFT_CLIENT,AFT.AFT_LOJA,"
		cQuery	+= "AFT.AFT_PROJET,AFT.AFT_REVISA,AFT.AFT_VALOR1,AFT.AFT_VALOR2,AFT.AFT_VALOR3,AFT.AFT_VALOR4,AFT.AFT_VALOR5,"
		cQuery += "AFT.AFT_DATA,AFT.AFT_VENREA,AFT.AFT_TAREFA,AFT.AFT_EDT,"
		cQuery += "SE1.E1_MOEDA, SE1.E1_EMISSAO FROM " + RetSqlName("AFT")+" AFT INNER JOIN "
		cQuery +=	RetSqlName("SEL")+" SEL ON "
		cQuery += " AFT.AFT_FILIAL = SEL.EL_FILIAL AND AFT.AFT_PREFIX=SEL.EL_PREFIXO AND AFT.AFT_NUM=SEL.EL_NUMERO "
		cQuery += " AND AFT.AFT_PARCEL=SEL.EL_PARCELA AND AFT.AFT_TIPO=SEL.EL_TIPO AND AFT.AFT_CLIENT=SEL.EL_CLIENTE AND AFT.AFT_LOJA=SEL.EL_LOJA "
		cQuery	+= " INNER JOIN " +RetSqlName("SE1")+" SE1 ON "
		cQuery += " AFT.AFT_FILIAL = SE1.E1_FILIAL AND AFT.AFT_PREFIX=SE1.E1_PREFIXO AND AFT.AFT_NUM=SE1.E1_NUM "
		cQuery += " AND AFT.AFT_PARCEL=SE1.E1_PARCELA AND AFT.AFT_TIPO=SE1.E1_TIPO AND AFT.AFT_CLIENT=SE1.E1_CLIENTE AND AFT.AFT_LOJA=SE1.E1_LOJA "
		cQuery += " WHERE AFT.AFT_FILIAL = '" + xFilial("AFT",cFili) + "'"
		cQuery += " AND AFT.AFT_PROJET = '" + cProjet + "'"
		cQuery += " AND AFT.AFT_CLIENT = '" + cCodCli + "'"
		cQuery += " AND AFT.AFT_LOJA = '" + cLoja + "'"
		cQuery += " AND AFT.AFT_VIAINT = ' ' "
		cQuery += " AND AFT.D_E_L_E_T_ = ' ' "
		cQuery += " AND SE1.E1_FILIAL = '" + xFilial("SE1",cFili) + "'"
		cQuery +=	" AND SE1.E1_CLIENTE = '" + cCodCli + "'"
		cQuery += " AND SE1.E1_LOJA = '" + cLoja + "'"
		cQuery += " AND (SE1.E1_ORIGEM = 'FINA087A' OR SE1.E1_ORIGEM='FINA840') "
		cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SEL.EL_FILIAL = '" + xFilial("SEL",cFili) + "'"
		cQuery += " AND SEL.EL_CLIENTE = '" + cCodCli + "'"
		cQuery += " AND SEL.EL_LOJA = '" + cLoja + "'"
		cQuery += " AND SEL.EL_TIPODOC = 'RA' "
		cQuery += " AND SEL.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		cAliasTMP:=GetNextAlias()
		If Select(cAliasTMP)>0
			(cAliasTMP)->(dbCloseArea())
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTMP, .T., .T.)
		If (cAliasTMP)->(!EOF())
			(cAliasTMP)->(dbGoTop())
			While (cAliasTMP)->(!EOF())
				//If nX <6 //moedas do financeiro
				//nValor:=(cAliasTMP)->&("AFT_VALOR"+cValToChar(nX))
				//Else
				nValor:=xMoeda((cAliasTMP)->AFT_VALOR1,(cAliasTMP)->E1_MOEDA,nX,StoD((cAliasTMP)->E1_EMISSAO))
				//Endif
				aAdd( ::ARetPesq:sARetPesq, ( WsClassNew( 'stRetPesq' ) ) )
				aTail( ::ARetPesq:sARetPesq ):c_CodAdt	:=Trim((cAliasTMP)->AFT_NUM)
				aTail( ::ARetPesq:sARetPesq ):c_Descr	:= AllTrim(STR0006) //"RECEBIMENTO ANTECIPADO"
				aTail( ::ARetPesq:sARetPesq ):c_TipoAdt	:="R"
				aTail( ::ARetPesq:sARetPesq ):c_Empre	:=cEmpre
				aTail( ::ARetPesq:sARetPesq ):c_Fili	:=cFili
				aTail( ::ARetPesq:sARetPesq ):c_Projet	:=rTrim((cAliasTMP)->AFT_PROJET)
				aTail( ::ARetPesq:sARetPesq ):c_Moed	:=cMoed
				aTail( ::ARetPesq:sARetPesq ):c_TipoCli:=cTipoCli
				aTail( ::ARetPesq:sARetPesq ):c_Loja	:=rTrim((cAliasTMP)->AFT_LOJA)
				aTail( ::ARetPesq:sARetPesq ):c_CodCli	:=rTrim((cAliasTMP)->AFT_CLIENT)
				aTail( ::ARetPesq:sARetPesq ):d_Incl	:=StoD((cAliasTMP)->E1_EMISSAO)
				aTail( ::ARetPesq:sARetPesq ):d_Venc	:=StoD((cAliasTMP)->AFT_VENREA)
				aTail( ::ARetPesq:sARetPesq ):n_Valor	:=nValor
				aTail( ::ARetPesq:sARetPesq ):n_Liberado	:=0
				aTail( ::ARetPesq:sARetPesq ):c_cCusto	:=GetMv("MV_RMCCUST")
				aTail( ::ARetPesq:sARetPesq ):c_Prefixo	:=rTrim((cAliasTMP)->AFT_PREFIX)
				aTail( ::ARetPesq:sARetPesq ):c_Parcela	:=rTrim((cAliasTMP)->AFT_PARCEL)
				aTail( ::ARetPesq:sARetPesq ):c_Tipo	:=rTrim((cAliasTMP)->AFT_TIPO)
				aTail( ::ARetPesq:sARetPesq ):c_Revisa	:=rTrim((cAliasTMP)->AFT_REVISA)
				aTail( ::aRetPesq:sAretPesq ):c_Tarefa := rTrim((cAliasTMP)->AFT_TAREFA)
				aTail( ::aRetPesq:sAretPesq ):c_EDT	:= rTrim((cAliasTMP)->AFT_EDT)
				(cAliasTMP)->(dbSkip())
			EndDo
		Else
			SetSoapFault("WSFINA850",STR0005)//"Não existe registro relacionado a esta consulta"
			lRet:=.F.
		Endif
		(cAliasTMP)->(dbCloseArea())
	Else
		SetSoapFault("WSFINA850",STR0007)//"O código do adiantamento não existe ou código do Cliente/Fornecedor Inválido. Verifique no TOP!"
		lRet:= .F.
	Endif
Endif
RestArea(aArea)
Return lRet

/*--------------------------------------------------------------------------------------
WSMethod	Bloquear
Autor		Jandir Deodato
Data		19/01/2012
Descricao	Bloqueia ou desbloqueia um título a pagar
Retorno		sRet
--------------------------------------------------------------------------------------*/
WSMethod Bloquear WSReceive sBloqueia WSSEND sRet  WSSERVICE WSFINA850

Local cFili :=""
Local cEmpre :=""
Local cCodAdt :=""
Local nLiberado
Local cTipoAdt:=""
Local lRet :=.T.
Local cPrefixo :=""
Local cParcela :=""
Local cTipo :=""
Local cFornece :=""
Local cCliente:=""
Local cLoja :=""
Local cRevisa:=""
Local cProjeto :=""
Local aArea := GetArea()
Local cTarefa:="" 
Local cEdt := "" 
Local aAreaAFR
Local aAreaAFT
Local cAliasTMP
Local cQuery

dbSelectArea("AFR")
aAreaAFR := AFR->(GetArea())
dbSelectArea("AFT")
aAreaAFT := AFT->(GetArea())

If !(AliasInDic("SEK"))
	lret:=.F.
	SetSoapFault("WSFINA850",OemToAnsi(STR0016 ))//a tabela de ordens de pago nao foi encontrada no sistema
ElseIf !(AliasInDic("SEL"))
	lret:=.F.
	SetSoapFault("WSFINA850",OemToAnsi(STR0017 ))//a tabela de recibo de cobrança nao foi encontrada no sistema
Endif
//Verificação da empresa e filial
If lRet
	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFili := (::sBloqueia:c_Fili) 
			cEmpre :=	(::sBloqueia:c_Empre) 
			lRet :=PMSSM0Env(@cEmpre,@cFili)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSFINA850",STR0018)//Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
			lRet:= .F.
		Endif
	Else
		cFili := Padr( Alltrim(::sBloqueia:c_Fili)  ,Len(cFilAnt) )
		cEmpre := Padr( Alltrim(::sBloqueia:c_Empre) ,Len(cEmpAnt) )
		lRet :=PMSSM0Env(cEmpre,cFili)
	Endif
	cTipoAdt := ::sBloqueia:c_TipoAdt
	IF !lRet
		SetSoapFault("WSFINA850",STR0009)//"Empresa/Filial Inexistente ou não autorizada. Verifique" 
	Endif
Endif
If lRet
	If AllTrim(Upper(cTipoAdt))=="P"
		cCodAdt := Padr(::sBloqueia:c_CodAdt,TamSX3("AFR_NUM")[1])
		cTipoAdt:= ::sBloqueia:c_TipoAdt
		nLiberado := ::sBloqueia:n_Liberado
		cPrefixo := Padr(::sBloqueia:c_Prefixo,TamSX3("AFR_PREFIX")[1])
		cParcela := Padr(::sBloqueia:c_Parcela,TamSX3("AFR_PARCEL")[1])
		cTipo := Padr(::sBloqueia:c_Tipo,TamSX3("AFR_TIPO")[1])
		cFornece := Padr(::sBloqueia:c_Fornece,TamSX3("AFR_FORNEC")[1])
		cLoja := Padr(::sBloqueia:c_Loja,TamSX3("AFR_LOJA")[1])
		cRevisa := Padr(::sBloqueia:c_Revisa,TamSX3("AFR_REVISA")[1])
		cProjeto := Padr(::sBloqueia:c_Projeto,TamSX3("AFR_PROJET")[1])	
		cTarefa := Padr(::sBloqueia:c_Tarefa,TamSX3("AFR_TAREFA")[1])
		AFR->(dbSetOrder(1))//AFR_FILIAL+AFR_PROJET+AFR_REVISA+AFR_TAREFA+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA
		If AFR->(dbSeek(xFilial("AFR",cFili)+cProjeto+cRevisa+cTarefa+cPrefixo+cCodAdt+cParcela+cTipo+cFornece+cLoja))
			::sRet:c_Ret:= AFR->AFR_NUM
			RecLock("AFR",.F.)
			If nLiberado == 1 .and. AllTrim(AFR->AFR_VIAINT)==""
				AFR->AFR_VIAINT:="S"
			ElseIf  nLiberado == 0 .and. AllTrim(AFR->AFR_VIAINT)=="S"
				AFR->AFR_VIAINT:=""
			ElseIf nLiberado == 1 .and. AllTrim(AFR->AFR_VIAINT)=="S"  
				SetSoapFault("WSFINA850",STR0013)//"Este adiantamento já está bloqueado pelo TOP. Verifique!"
				lRet:=.F.
			ElseIf nLiberado == 0 .and. AllTrim(AFR->AFR_VIAINT)==""
				SetSoapFault("WSFINA850",STR0014)//"Este adiantamento não está bloqueado. Verifique!"
				lRet:=.F.
			Else
				SetSoapFault("WSFINA850",STR0010)//"Código de bloqueio/Desbloqueio inexistente. Verifique!"
				lRet:=.F.
			EndIf
			MsUnlock()
		Else
			SetSoapFault("WSFINA850",STR0011)//"Registro não encontrado na base Protheus. Verifique!"
			lRet:=.F.
		Endif
	ElseIf AllTrim(Upper(cTipoAdt))=="R"
		cCodAdt := Padr(::sBloqueia:c_CodAdt,TamSX3("AFT_NUM")[1])
		cTipoAdt:= ::sBloqueia:c_TipoAdt
		nLiberado := ::sBloqueia:n_Liberado
		cPrefixo := Padr(::sBloqueia:c_Prefixo,TamSX3("AFT_PREFIX")[1])
		cParcela := Padr(::sBloqueia:c_Parcela,TamSX3("AFT_PARCEL")[1])
		cTipo := Padr(::sBloqueia:c_Tipo,TamSX3("AFT_TIPO")[1])
		cCliente := Padr(::sBloqueia:c_Fornece,TamSX3("AFT_CLIENT")[1])
		cLoja := Padr(::sBloqueia:c_Loja,TamSX3("AFT_LOJA")[1])
		cRevisa := Padr(::sBloqueia:c_Revisa,TamSX3("AFT_REVISA")[1])
		cProjeto := Padr(::sBloqueia:c_Projeto,TamSX3("AFT_PROJET")[1])
		cTarefa:=	Padr(::sBloqueia:c_Tarefa,TamSX3("AFT_TAREFA")[1])
		cEdt	:= Padr(::sBloqueia:c_EDT,TamSX3("AFT_EDT")[1])
		cAliasTMP:=GetNextAlias()
		If Select(cAliasTMP)>0
			(cAliasTMP)->(dbCloseArea())
		Endif
		cQuery := "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("AFT")+" WHERE "
		cQuery += "AFT_FILIAL = '"+xFilial("AFT",cFili)+"' AND AFT_PROJET='"+cProjeto+"' AND AFT_REVISA='"+cRevisa+"' AND AFT_TAREFA='"+cTarefa+"'"
		cQuery += " AND AFT_PREFIX='"+cPrefixo+"' AND AFT_NUM='"+cCodAdt+"' AND AFT_PARCEL='"+cParcela+"' AND AFT_TIPO='"+cTipo+"'"
		cQuery += " AND AFT_CLIENT='"+cCliente+"' AND AFT_LOJA='"+cLoja+"' AND AFT_EDT='"+cEdt+"' AND D_E_L_E_T_ =' ' "
		cQuery:=ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTMP, .T., .T.)
		If !Empty((cAliasTMP)->RECNO)
				AFT->(dbGoto((cAliasTMP)->RECNO))//AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_TAREFA+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA
				::sRet:c_Ret:= AFT->AFT_NUM
				RecLock("AFT",.F.)
				If nLiberado == 1 .and. AllTrim(AFT->AFT_VIAINT)==""
					AFT->AFT_VIAINT:="S"
				ElseIf nLiberado ==0 .and. AllTrim(AFT->AFT_VIAINT)=="S"
					AFT->AFT_VIAINT:=""
				ElseIf nLiberado == 1 .and. AllTrim(AFT->AFT_VIAINT)=="S"
					SetSoapFault("WSFINA850",STR0013)//"Este adiantamento já está bloqueado pelo TOP. Verifique!"
					lRet:=.F.
				ElseIf nLiberado == 0 .and. AllTrim(AFT->AFT_VIAINT)==""
					SetSoapFault("WSFINA850",STR0014)//"Este adiantamento não está bloqueado. Verifique!"
					lRet:=.F.
				Else
					SetSoapFault("WSFINA850",STR0010)//"Código de Bloqueio/Desbloqueio Inexistente. Verifique!"
					lRet:=.F.
				EndIf
				MsUnlock()
		Else
			SetSoapFault("WSFINA850",STR0011)//"Registro não encontrado na base Protheus. Verifique!"
			lRet:=.F.
		Endif
		(cAliasTMP)->(dbCloseArea())
	Else
		SetSoapFault("WSFINA850",STR0012)//"Tipo de Adiantamento Inexistente. Verifique!" 
		lRet:=.F.
	Endif
Endif
RestArea(aAreaAFR)
RestArea(aAreaAFT)
RestArea(aArea)
Return lRet

	
User Function Pmwsdummy; Return  // "dummy" function - Internal Use

