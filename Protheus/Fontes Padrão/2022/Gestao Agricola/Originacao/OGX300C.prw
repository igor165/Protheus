#Include 'tbiconn.ch'
#Include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include "OGX300.ch"

/*/{Protheus.doc} OGX300C
Busca os Indices de mercado(NK0), 
chama função para buscar as cotações dos indices na API M2M
e chama função para atualizar/gravar as cotações dos indices no protheus(NK1) 

@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodInd, caracter, codigo do indice(NK0) a ser atualizado
@return Bolena, Retorna .T. se conseguiu atualizar alguma cotação de indice de mercado
/*/
Function OGX300C(cCodInd)
	Local lRet := .T.
	Local lGrvLog := .F. //define se esta função OGX300B grava o log
	
	If TYPE("_AGRResult") == "U" //se ainda não tenha sido declarada em funções que chamam esta função
		Private _AGRResult := AGRViewProc():New()
		_AGRResult:EnableLog("OGC300C.log", STR0025 ,"2",.F.) //###"Integração API externa - Atualização da cotação de moedas e indices de Mercado"
		lGrvLog := .T.
	EndIf
	
	If TYPE("_cToken") == "U" //se ainda não tenha sido declarada em funções que chamam esta função
		Private _cToken := ""
		If .not. OGX300AUT() //gera o token
			//If .not. IsBlind() //TEM INTERFACE COM O USUARIO
				//MsgInfo(STR0008,STR0007)//"Erro Conexão: Não foi possivel realizar a conexão com a API. Verifique os parametros de integração(MV_AGRO200,MV_AGRO201,MV_AGRO202) ou a conexão com a internet."
				//_AGRResult:Add( STR0008 )
			//EndIf
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		lRet := ATUINDCURVE(cCodInd)
	EndIf
	
	If lGrvLog //função OGX300C grava o log
		_AGRResult:AGRLog:Save()
		_AGRResult:AGRLog:EndLog()		
		_AGRResult:Show() //mostra log na tela		
	EndIf
	
Return lRet

Static Function ATUINDCURVE(cCodInd)

	Local lRet 	  	:= .F. 
	Local cTicker 	:= ""
	Local oJsonAPI	:= {} 	//retorno dos dados da API
	Local cChaveSeek :=	""
	Local cVldSeek	:= ""
	Local aArea := GetArea()
	Local dVencInd := nil

	Private _cUrlFuturo := SuperGetMv("MV_AGRO204")
	If TYPE("_cToken") == "U"  //se ainda não tenha sido declarada em funções que chamam esta função
		Private _cToken := ""
		If .not. OGX300AUT() //gera o token
			return .F.
		EndIf
	EndIf

	Default cCodInd := ""

	If Empty(cCodInd)
		cChaveSeek := FWxFilial( "NK0" )
		cVldSeek := "NK0->NK0_FILIAL"
	Else
		cChaveSeek := FWxFilial( "NK0" ) + ALLTRIM(cCodInd)
		cVldSeek := "NK0->NK0_FILIAL+ALLTRIM(NK0->NK0_INDICE)"
	EndIf

	dbSelectAreA("NK0") //"NK0 - Indices de Mercado"
	NK0->(dbSetOrder(1))
	NK0->(DbGoTop())
	If NK0->(dbSeek(cChaveSeek))
		_AGRResult:Add( STR0005 ) //###//"Iniciando atualização da cotação de indices de mercado ..."
		While !NK0->( EOF()) .and. cChaveSeek == &cVldSeek
			oJsonAPI := {}
			If !Empty(NK0->NK0_CODP2)
				cTicker := Alltrim(NK0->NK0_CODP2) //indice/ticker 
				dVencInd := NK0->NK0_DATVEN
				cCodInd := Alltrim(NK0->NK0_INDICE)
				If !Empty(cTicker) .and. ( empty(dVencInd) .or. dVencInd >= DDATABASE )
					_AGRResult:Add( STR0031 + Alltrim(NK0->NK0_INDICE) + ' - ' + Alltrim(NK0->NK0_DESCRI) + " - " + STR0034 + cTicker) //###"Buscando cotação para o indice de mercado " ###"Ticker: "
					oJsonAPI := COTINDCURVE(cCodInd,cTicker,dVencInd) //chama função para buscar a cotação do indice de mercado
					If !Empty(oJsonAPI) .and. Len(oJsonAPI:response:curves[1]:values) > 0 
						GRVINDCURVE(cCodInd,dVencInd,oJsonAPI:response:curves[1]:values) 
						lRet := .T.
						_AGRResult:Add( STR0028 ) //###"Atualização realizada com sucesso"
					Else
						_AGRResult:Add( STR0029 + cTicker + " - " + STR0032) //###"Não foi encontrado dados para o ticker " ###"Indice não atualizada"
					EndIf
				EndIf
			EndIf
			NK0->( DbSkip() )
		EndDo
		_AGRResult:Add( STR0024 ) //###"Finalizado atualização da cotação de Indices."
		_AGRResult:Add("")	
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} COTINDCURVE
Busca a cotação do indice de mercado na API M2M

@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodInd, caracter, codigo do indice(NK0) a ser atualizado
@param cTicker, caracter, Tiker(NK0) para busca na API
@param dDataVenc, Date, Data de vencimento(NK0) do indice
@return Object, Objeto Json retonado da API
/*/
Static Function COTINDCURVE(cCodInd,cTicker, dDataVenc)
	Local cJson 	:= ""
	Local oObjJSON 	:= JsonObject():New() 
	Local oJsonAPI	:= ""
	Local lContinua := .T.
	Local nTent		:= 0 //numero de tentaivas para encontrar uma data com a cotação futura, geralmente é dia util
	Local dData 	:= DDATABASE //dia atual menos um dia

	While lContinua .and. nTent < 7 //maximo de tentaivas igual a 7(dias)
		nTent += 1

		//Setando no ObjJSON os parâmetros de curva e data
		oObjJSON["ticker"]    := cTicker
		oObjJSON["curveDate"] := Year2Str(dData) +"-"+ Month2Str(dData) +"-"+ Day2Str(dData) 

		cJson := FWJsonSerialize(oObjJSON) //converte para uma string JSON

		oJsonAPI := OGX300RPOST( _cUrlFuturo, cJson ) //integra com a API retornando os dados

		If Empty(oJsonAPI) .or. ( !Empty(oJsonAPI) .and. Len(oJsonAPI:response:curves) > 0 .and. Len(oJsonAPI:response:curves[1]:values) > 0 ) 
			lContinua := .F. //para o while
		EndIf
		dData := DAYSUB(dData, 1) //subtrai mais um dia para tentar novamente

	EndDo

Return oJsonAPI

/*/{Protheus.doc} GRVINDCURVE
Realiza a gravação/atualização das cotações de indice de mercado no protheus(NK1) conforme dados retornados da API

@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodInd, caracter, codigo do indice(NK0) a ser atualizado
@param dDataVenc, Date, Data de vencimento(NK0) do indice
@param oValores, Object, Objeto Json com os valores retornados da API
/*/
Static Function GRVINDCURVE(cCodInd, dDataVenc, oValores)
	Local dDataAPI := Nil
	Local dDataAtual := DDATABASE
	Local nX := 0

	dbSelectArea("NK1") 
	NK1->(dbSetOrder(1))

	//Verifica se é DOLAR_FUTURO ou outra moeda e limpa os valores
	LimpaIndices(cCodInd, dDataAtual)

	For nX := 1 To Len(oValores)
		dDataAPI := STOD(StrTran(SubSTR(oValores[nX]:date ,1, 10),'-',''))

		If !empty(dDataVenc)  //se indice tem data de vencimento - DAGROGAP-1104 
			If( dDataAPI = dDataVenc) //se a data do indice na M2M for igual a data de vencimento do indice(NK0)
				//atualizar indice para a data atual com o valor do indice da data de vencimento não precisa atualizar para as demais datas DAGROGAP-1104
				If NK1->(dbSeek(xFilial("NK1") + DTOS(dDataAtual) + cCodInd))
					RecLock("NK1",.F.)  //Bloqueia o registro para alteração
					NK1->NK1_VALOR := oValores[nX]:value
					NK1->(MsUnlock()) //Libera o registro
					exit //sai do for
				Else
					RecLock("NK1",.T.)	
					NK1->NK1_DATA   := dDataAtual
					NK1->NK1_INDICE := cCodInd
					NK1->NK1_VALOR  := oValores[nX]:value
					NK1->(MsUnlock()) //Libera o registro
					exit //sai do for
				endif
			EndIf
		ElseIf NK1->(dbSeek(xFilial("NK1")+DTOS(dDataAPI)+cCodInd)) //Localiza o registro atraves da chave - Se já existe registro na NK1 para o índice, atualiza
			RecLock("NK1",.F.)  //Bloqueia o registro para alteração
			NK1->NK1_VALOR := oValores[nX]:value
			NK1->(MsUnlock()) //Libera o registro
			NK1->( DbSkip() )
		Else //Se não existe registro na NK1 para o índice, insere
			RecLock("NK1",.T.)  //Bloqueia o registro para alteração
			NK1->NK1_DATA   := dDataAPI
			NK1->NK1_INDICE := cCodInd
			NK1->NK1_VALOR  := oValores[nX]:value
			NK1->(MsUnlock()) //Libera o registro
		EndIF
	Next nX

Return .T.

Static Function LimpaIndices(cIndice, dData)
	Local lRet := .T.
	Local cSqlDel := ""
	Local nStatus := 0
	Local lIndMoeda := .F.

	lIndMoeda := 'S' == GetDataSql("SELECT DISTINCT 'S' RES FROM " + RetSqlName("NJ7") + " NJ7 " + ;
	                               "WHERE NJ7_FILIAL = '" + FWxFilial("NJ7") + "' " + ;
	                               "AND NJ7_INDICE = '" + cIndice + "' " )
	
	
	If lIndMoeda  //Se o indice for associado a uma moeda Ex: DOLAR_FUTURO
		          //Apaga os registros existentes na tabela de índices futuros
		cSqlDel := "DELETE FROM " + RetSqlName("NK1") + " " + ;
		           "WHERE NK1_FILIAL = '" + FWxFilial("NK1") + "' " + ;
				   "AND NK1_INDICE = '" + cIndice + "' " + ;
				   "AND NK1_DATA > '" + DTOS(dData) + "' "

		nStatus := TcSqlExec(cSqlDel)

		If (nStatus < 0)
			Conout("TCSQLError() " + TCSQLError())
			lRet := .f.
		endif
	EndIf

Return lRet