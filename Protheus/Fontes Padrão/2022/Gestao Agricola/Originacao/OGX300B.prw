#Include�'tbiconn.ch'
#Include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include "OGX300.ch"

/*/{Protheus.doc} OGX300B
Busca os indices de moedas(NJ7),  
chama fun��o para buscar as cota��es de moeda(atual e futura) na API M2M
e chama fun��o para atualizar/gravar as cota��es das moedas no protheus(SM2)

@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodMoeda, caracter, codigo do moeda a ser atualizado
@return Bolean, Retona .T. se conseguiu atualizar alguma cota��o de moeda, sen�o retona .F.
/*/
Function OGX300B(cCodMoeda)
	Local lRet := .T.
	Local lGrvLog := .F. //define se esta fun��o OGX300B grava o log
	
	If TYPE("_AGRResult") == "U" //se ainda n�o tenha sido declarada em fun��es que chamam esta fun��o
		Private _AGRResult := AGRViewProc():New()
		_AGRResult:EnableLog("OGC300B.log", STR0025 ,"2",.F.) //###"Integra��o API externa - Atualiza��o da cota��o de moedas e indices de Mercado"
		lGrvLog := .T.
	EndIf
		
	If TYPE("_cToken") == "U" //se ainda n�o tenha sido declarada em fun��es que chamam esta fun��o
		Private _cToken := ""
		If .not. OGX300AUT() //gera o token
			lRet := .F.
		EndIf
	EndIf
	
	If lRet 
		lRet := ATUMOEDA(cCodMoeda)
	EndIf
	
	If lGrvLog //fun��o OGX300B grava o log
		_AGRResult:AGRLog:Save()
		_AGRResult:AGRLog:EndLog()		
		_AGRResult:Show() //mostra log na tela		
	EndIf
	
Return lRet

Static Function ATUMOEDA(cCodMoeda)
	Local lRet 	  	:= .F. 
	Local cTicker 	:= ""
	Local oJsonAPI	:= {} 	//retorno dos dados da API
	Local cChaveSeek :=	""
	Local cVldSeek	:= ""
	Local aArea := GetArea()

	Private _cUrlAtual := SuperGetMv("MV_AGRO203")
	Private _cUrlFuturo := SuperGetMv("MV_AGRO204")
	
	Default cCodMoeda := ""

	If Empty(cCodMoeda)
		cChaveSeek := FWxFilial( "NJ7" )
		cVldSeek := "NJ7->NJ7_FILIAL"
	Else
		cChaveSeek := FWxFilial( "NJ7" ) + ALLTRIM(cCodMoeda)
		cVldSeek := "NJ7->NJ7_FILIAL+ALLTRIM(NJ7->NJ7_CODPRO)"
	EndIf

	dbSelectAreA("NJ7") //"NJ7 - Moeda Protheus x Externas"
	NJ7->(dbSetOrder(1))
	NJ7->(DbGoTop())
	If NJ7->(dbSeek(cChaveSeek))
		_AGRResult:Add(STR0004)	//###"Iniciando atualiza��o da cota��o de moedas"
		
		While !NJ7->( EOF()) .and. cChaveSeek == &cVldSeek
			oJsonAPI := {}
			If !Empty(NJ7->NJ7_IDEXT1)
				cTicker := Alltrim(NJ7->NJ7_IDEXT1) //indice/ticker cota��o atual
				cCodMoeda := Alltrim(NJ7->NJ7_CODPRO)
				_AGRResult:Add( STR0027 + Alltrim(NJ7->NJ7_CODPRO) + ' - ' + Alltrim(NJ7->NJ7_DESCRI) + " - " + STR0034 + cTicker ) //###"Buscando cota��o PTAX para a moeda " ###"Ticker: "
				oJsonAPI := COTATUMOEDA(cCodMoeda,cTicker) //chama fun��o para buscar a cota��o atual(PTAX) da moeda
				If !Empty(oJsonAPI) .and. Len(oJsonAPI:response:values) > 0 
					GRVMOEDA(cCodMoeda,oJsonAPI:response:values,"A") 
					_AGRResult:Add( STR0028 ) //###"Atualiza��o realizada com sucesso"
					lRet := .T.
				Else
					_AGRResult:Add( STR0029 + cTicker + " - " + STR0014) //###"N�o foi encontrado dados para o ticker " ###"Moeda n�o atualizada"
				EndIf
			EndIf
			If !Empty(NJ7->NJ7_IDEXT2)
				cTicker := Alltrim(NJ7->NJ7_IDEXT2) //indice/ticker cota��o futura
				cCodMoeda := Alltrim(NJ7->NJ7_CODPRO)
				_AGRResult:Add( STR0030 + Alltrim(NJ7->NJ7_CODPRO) + ' - ' + Alltrim(NJ7->NJ7_DESCRI) + " - " + STR0034 + cTicker ) //###"Buscando cota��o Futura para a moeda " ###"Ticker: "
				oJsonAPI := COTFUTMOEDA(cCodMoeda,cTicker) //chama fun��o para buscar as cota��es futura da moeda
				If !Empty(oJsonAPI) .and. Len(oJsonAPI:response:curves[1]:values) > 0 
					GRVMOEDA(cCodMoeda,oJsonAPI:response:curves[1]:values,"F") 
					_AGRResult:Add( STR0028 ) //###"Atualiza��o realizada com sucesso"
					lRet := .T.
				Else
					_AGRResult:Add( STR0029 + cTicker + " - " + STR0014) //###"N�o foi encontrado dados para o ticker " ###"Moeda n�o atualizada"
				EndIf
			EndIf
			NJ7->( DbSkip() )
		EndDo
		_AGRResult:Add(STR0023)	//"Finalizado atualiza��o da cota��o de moedas."
		_AGRResult:Add("")			
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} COTATUMOEDA
Busca a cota��o atual da moeda na API

@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodMoeda, caracter, codigo da moeda a ser atualizada
@param cTicker, caracter, codigo do ticker(NJ7) para busca na API 
@return Object, Retona o objeto Json da API
/*/
Static Function COTATUMOEDA(cCodMoeda,cTicker)

	Local cJson 	:= ""  
	Local oObjJSON 	:= JsonObject():New() 
	Local oJsonAPI	:= {}
	Local lContinua := .T.
	Local nTent		:= 0 //numero de tentaivas para encontrar uma data com a cota��o atual, geralmente � dia util
	Local dData 	:= DAYSUB(DDATABASE, 1) //dia atual menos um dia, a cota��o para hoje � a cota��o fechada no dia anterior

	While lContinua .and. nTent < 7 //maximo de tentaivas igual a 7(dias)
		nTent += 1

		//Setando no ObjJSON os par�metros de ticker, data inicial e data final
		oObjJSON["ticker"]    := cTicker
		oObjJSON["startDate"] := Year2Str(dData) +"-"+ Month2Str(dData) +"-"+ Day2Str(dData) 
		oObjJSON["endDate"]   := Year2Str(DDATABASE) +"-"+ Month2Str(DDATABASE) +"-"+ Day2Str(DDATABASE) 	
		cJson := FWJsonSerialize(oObjJSON) //converte para uma string JSON

		oJsonAPI := OGX300RPOST( _cUrlAtual, cJson ) //integra com a API retornando os dados

		If Empty(oJsonAPI) .or. ( !Empty(oJsonAPI) .and. Len(oJsonAPI:response:values) > 0)
			lContinua := .F. //interrompe o while
		EndIf
		dData := DAYSUB(dData, 1) //subtrai mais um dia para tentar novamente

	EndDo

Return oJsonAPI

/*/{Protheus.doc} COTFUTMOEDA
Busca a cota��o futura da moeda na API,
e chama fun��o para gravar/atualizar a cota��o no Protheus

@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodMoeda, caracter, codigo da moeda a ser atualizada
@param cTicker, caracter, codigo do ticker(NJ7) para busca na API 
@return Object, Retona o objeto Json da API
/*/
Static Function COTFUTMOEDA(cCodMoeda,cTicker)

	Local cJson 	:= ""
	Local oObjJSON 	:= JsonObject():New() 
	Local oJsonAPI	:= ""
	Local lContinua := .T.
	Local nTent		:= 0 //numero de tentaivas para encontrar uma data com a cota��o futura, geralmente � dia util
	Local dData 	:= DAYSUB(DDATABASE, 1) //dia atual menos um dia

	While lContinua .and. nTent < 7 //maximo de tentaivas igual a 7(dias)
		nTent += 1

		//Setando no ObjJSON os par�metros de curva e data
		oObjJSON["ticker"]    := cTicker
		oObjJSON["curveDate"] := Year2Str(dData) +"-"+ Month2Str(dData) +"-"+ Day2Str(dData) 

		cJson := FWJsonSerialize(oObjJSON) //converte para uma string JSON

		oJsonAPI := OGX300RPOST( _cUrlFuturo, cJson ) //integra com a API retornando os dados

		If Empty(oJsonAPI) .or. ( !Empty(oJsonAPI) .and. Len(oJsonAPI:response:curves) > 0 .and. Len(oJsonAPI:response:curves[1]:values) > 0 ) 
			lContinua := .F. //interrompe o while
		EndIf
		dData := DAYSUB(dData, 1) //subtrai mais um dia para tentar novamente

	EndDo

Return oJsonAPI

/*/{Protheus.doc} GRVMOEDA
Realiza a grava��o/atualiza��o das cota��es de moeda no protheus(SM2) conforme dados retornados da API

@author thiago.rover/claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodMoeda, caracter, codigo da moeda a ser atualizada
@param oValores, Object, Objeto Json com os valores retornados da API 
/*/
Static Function GRVMOEDA(cCodMoeda, oValores, cTipo )
	Local cData := ""
	Local dData := nil
	Local nX 	:= 0
	Local aArea := GetArea()

	dbSelectArea("SM2") //"SM2 - Cota��es de Moedas"
	SM2->(dbSetOrder(1)) 

	For nX := 1 To Len(oValores)
		cData := oValores[nX]:date
		dData	:= STOD(StrTran(SubSTR(cData,1, 10),'-','')) 
		
		If cTipo = "A" 
		//se o tipo de indice for ATUAL, soma mais um dia na data que vem do M2M, pois o valor da cota��o de ontem � o valor valido para o dia de hoje(atual) e a cota��o de hoje final do dia � valida para o dia de amanh�
			dData := dData + 1
			
			If dData < DDATABASE
				//se n�o retornou cota��o para hoje(data ATUAL), atualiza com a ultima cota��o encontrada na busca da moeda no M2M.
				//ex: sabado, domingo e segunda recebe cota��o de sexta. Feriados e dias ap�s feriados recebe ultimo dia que retornar cota��o 
				dData := DDATABASE
			EndIf
		EndIf
		
		If SM2->(dbSeek(dData)) //Localiza o registro atraves da chave
			RecLock("SM2",.F.)  //Bloqueia o registro para altera��o
			&("SM2->M2_MOEDA"+cValToChar(Alltrim(cCodMoeda))) := oValores[nX]:value
			SM2->(MsUnlock()) //Libera o registro
		Else
			RecLock("SM2",.T.)  //Bloqueia o registro para altera��o
			SM2->M2_DATA  := dData
			&("SM2->M2_MOEDA"+cValToChar(Alltrim(cCodMoeda))) := oValores[nX]:value
			SM2->(MsUnlock()) //Libera o registro
		EndIf

	Next nX

	RestArea(aArea)

Return .T.