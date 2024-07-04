#Include 'tbiconn.ch'
#Include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include "OGX300.ch"

/*/{Protheus.doc} OGX300D
Atualiza indices de commodity de bolsa de referência - N8U

@author claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cBolsa, caracter, codigo da bolsa de referencia(N8C) a ser atualizado
@param cIndice, caracter, codigo do indice(NK0) a ser atualizado
@return Bolean, Retorna .T. se conseguiu atualizar alguma cotação de indice, senão retorna .F.
/*/
Function OGX300D(cBolsa,cIndice) 	
	Local lRet := .T.
	Local lGrvLog := .F. //define se esta função OGX300B grava o log
	
	If TYPE("_AGRResult") == "U" //se ainda não tenha sido declarada em funções que chamam esta função
		Private _AGRResult := AGRViewProc():New()
 		_AGRResult:EnableLog("OGX300D.log", STR0025 ,"2",.F.) //###"Integração API externa - Atualização da cotação de moedas e indices de Mercado"
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
		lRet := ATUINDBOLSA(cBolsa,cIndice)
	EndIf
	
	If lGrvLog //função OGX300D grava o log
		_AGRResult:AGRLog:Save()
		_AGRResult:AGRLog:EndLog()		
		_AGRResult:Show() //mostra log na tela		
	EndIf
	
Return lRet

/*/{Protheus.doc} ATUINDBOLSA
Busca os Indices de commodity de bolsa de referencia(N8U), 
chama função para buscar as cotações dos indices na API M2M
e chama função para atualizar/gravar as cotações dos indices no protheus(NK0/NK1)

@author claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cCodInd, caracter, codigo do indice(NK0) a ser atualizado
@return Bolean, Retorna .T. se conseguiu atualizar alguma cotação de indice, senão retorna .F.
/*/
Static Function ATUINDBOLSA(cCodBolsa,cCodInd)
	Local lRet 	  	:= .F.
	Local aArea := GetArea()
	Local aAreaN8C := N8C->(GetArea())
	Local aAreaN8U := N8U->(GetArea())
	Local cTicker 	:= ""
	Local oJsonAPI	 := {} 	//retorno dos dados da API
	Local cUrl		:= ""
	Local cChaveSeek :=	""
	Local cVldSeek	:= ""
	Local nX        := 0	
	Private aErros  := {}
	
	Default cCodBolsa := ""
	Default cCodInd := ""

	cChaveSeek := FWxFilial( "N8C" )
	cVldSeek := "N8C->N8C_FILIAL"

	If !Empty(cCodBolsa) //se enviado codigo do da bolsa de referencia N8C
		cChaveSeek := FWxFilial( "N8C" ) + ALLTRIM(cCodBolsa) //irá atualizar os indices da bolsa de referencia do indice passado no parametro
		cVldSeek := "N8C->N8C_FILIAL+ALLTRIM(N8C->N8C_CODIGO)"
	ElseIf !Empty(cCodInd) //se enviado codigo do indice NK0
		dbSelectAreA("NK0") //"NK0 - Indices de Mercado"
		NK0->(dbSetOrder(1))
		NK0->(DbGoTop())
		If NK0->(dbSeek(FWxFilial( "NK0" ) + cCodInd ))
			If !Empty(NK0->NK0_CODBOL) .AND. Empty(NK0->NK0_CODP2) //verifica se tem codigo de bolsa de referencia
				cChaveSeek := FWxFilial( "NK0" ) + ALLTRIM(NK0->NK0_CODBOL) //irá atualizar os indices da bolsa de referencia do indice passado no parametro
				cVldSeek := "N8C->N8C_FILIAL+ALLTRIM(N8C->N8C_CODIGO)"
			Else
				Return .F. //retorna falso pois indice não tem codigo de bolsa de referencia
			EndIf
		EndIf
	EndIf

	dbSelectArea("N8C") //bolsa de referencia
	N8C->(dbSetOrder(1))
	N8C->(DbGoTop())
	If N8C->(dbSeek(cChaveSeek))//N8C - Bolsa de referencia
		_AGRResult:Add( STR0022 )
		ConOut(STR0022) //"Iniciando atualização da cotação de indices de bolsa de referencia..." 
		While !N8C->( EOF()) .and. cChaveSeek == &cVldSeek
			If !Empty(N8C->N8C_URLINT)//tem url de integração com parceiro para atualização de indice 
				cUrl := Alltrim(N8C->N8C_URLINT)
				dbSelectArea("N8U") //N8U - Indices de commodity da bolsa de referencia
				N8U->(dbSetOrder(4))
				N8U->(DbGoTop())
				If N8U->(dbSeek(xFilial( "N8U" ) + N8C->N8C_CODIGO + "1")) //SE REGISTRO ATIVO PARA A BOLSA
					While !N8U->( EOF()) .and. N8U->N8U_CODBOL == N8C->N8C_CODIGO .and. N8U->N8U_INDINT == "1"
						cTicker := Alltrim(N8U->N8U_CODP2)	
						_AGRResult:Add( STR0033 + Alltrim(N8C->N8C_CODIGO) + ' - ' + Alltrim(N8C->N8C_DESCR) + " - " + STR0034 + cTicker ) //###"Buscando cotação para o indice de bolsa de referencia " ###"Ticker: "
						oJsonAPI := COTINDBOLSA(cTicker,cUrl) //chama função para buscar a cotação do indice
						If !Empty(oJsonAPI)
							GRVINDBOLSA(oJsonAPI)
							lRet := .T.
							If len(aErros) == 0
								_AGRResult:Add( STR0028 ) //###"Atualização realizada com sucesso"
							Else
								_AGRResult:Add( "STR0035" ) //###"Atualização concluída, porém houveram inconsistências no processo de atualização:"
								
								For nX := 1 To len(aErros)
									_AGRResult:Add( aErros[nX]) 
								Next nX
							EndIf
						Else
							_AGRResult:Add( STR0029 + cTicker + " - " + STR0032) //###"Não foi encontrado dados para o ticker " ###"Indice não atualizado"
						EndIf						
						N8U->( DbSkip() )
					EndDo
				EndIf
			EndIf
			N8C->( DbSkip() )
		EndDo
		_AGRResult:Add( STR0024 )//###"Finalizado atualização da cotação de indices."
		_AGRResult:Add("")	
	EndIf
	
	RestArea(aAreaN8U)
	RestArea(aAreaN8C)
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} COTINDBOLSA
Busca a cotação do indice de bolsa de referencia na API M2M

@author claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param cTicker, caracter, Codigo do indice(N8U) para a API
@param cURL, caracter, URL(N8C) de integração do indice na M2M
@return Object, Retorna o objeto Json da API
/*/
Static Function COTINDBOLSA(cTicker, cURL)
	Local oJsonAPI	:= ""
	Local lContinua := .T.
	Local nTent		:= 0 //numero de tentaivas para encontrar uma data com a cotação futura, geralmente é dia util
	Local dData 	:= DDATABASE //dia atual menos um dia
	Local cData		:= "" 
	Local cUrlEnv	:= ""
	
	While lContinua .and. nTent < 7 //maximo de tentaivas igual a 7(dias)
		nTent += 1

		cData := Year2Str(dData) +"-"+ Month2Str(dData) +"-"+ Day2Str(dData)

		cUrlEnv := cURL + "token="+Escape(_cToken)+"&ticker="+cTicker+"&startDate="+cData

		oJsonAPI := OGX300RGET(cUrlEnv) //integra com a API retornando os dados

		If Empty(oJsonAPI) .or. ( !Empty(oJsonAPI) .and. Len(oJsonAPI:response) > 0  ) 
			lContinua := .F. //para o while
		EndIf

		dData := DAYSUB(dData, 1) //subtrai mais um dia para tentar novamente

	EndDo

Return oJsonAPI

/*/{Protheus.doc} GRVINDBOLSA
Realiza a gravação/atualização das cotações dos indice(NK0/NK1) conforme dados retornados da API

@author claudineia.reinert
@since 05/06/2018
@version P12
@type function
@param oJsonAPI, Object, Objeto Json retornado da API
/*/
Static Function GRVINDBOLSA(oJsonAPI)
	Local aArea := GetArea()
	Local nX 		:= 0 
	Local dDataAtual := DDATABASE
	Local dDateTicker := nil
	Local cMesAno	:= ''
	Local nRecNK0   := 0

	For nX := 1 To Len(oJsonAPI:response)
		cCodTicker 		:= oJsonAPI:response[nX]:ticker
		nValorTicker	:= oJsonAPI:response[nX]:verticeValue
		dDateTicker		:= STOD(StrTran(SubSTR(oJsonAPI:response[nX]:verticeDate,1, 10),'-',''))
		cMesAno			:= substr(DToC(dDateTicker),4,7) //concatena MM/AAAA
		
		If !Empty(N8U->N8U_FORIND)
			cCodTicker := FormCodTkt(cCodTicker,N8U->N8U_FORIND)
		EndIf

		If !Empty(cCodTicker) //se não for em branco/vazio grava o indice

			nRecNK0 := GetDataSQL("SELECT R_E_C_N_O_ FROM " + RetSqlName('NK0') + " WHERE NK0_FILIAL = '" + xFilial("NK0") + "' AND NK0_INDICE = '" + AllTrim(cCodTicker) + "' AND D_E_L_E_T_ = ' ' " )
			/** 
			*** OBS: Adicionado condição .OR. devido se procurar por exemplo CCDM e no banco tiver CCDM18 o dbSeek irá retornar true, pois encontrou o CCDM em parte de algum indice.
			***      Não necessario while, pois o dbSetOrder ja ordena pelo indice, então se existir o CCDM, este será encontrato por primeiro no dbSeek
			**/
			dbSelectArea("NK0") 
			NK0->(dbSetOrder(1))
			If nRecNK0 == 0   //correção vitor Só cria quando não existe indice
				// se não tem o ticker/indice salvo na NK0 então cria registro na NK0
				RecLock("NK0",.T.)  //Bloqueia o registro para alteração
				NK0->NK0_INDICE	:= cCodTicker
				NK0->NK0_DESCRI := cCodTicker 
				NK0->NK0_UM1PRO := N8U->N8U_UM1PRO
				NK0->NK0_MOEDA  := N8U->N8U_MOEDA
				NK0->NK0_TPCOTA := N8U->N8U_TPCOTA
				NK0->NK0_CODPRO := N8U->N8U_CODPRO
				NK0->NK0_CODBOL := N8U->N8U_CODBOL
				NK0->NK0_DATVEN := dDateTicker
				NK0->NK0_VMESAN	:= AGRMesAno(cMesAno, 1) //Retorna ex: JAN/2018
				NK0->NK0_MESBOL	:= AGRMesAno(cMesAno, 2) //Retorna ex: 201901
				NK0->(MsUnlock()) //Libera o registro
	
				If AllTrim(NK0->NK0_VMESAN) = '000000' .OR. AllTrim(NK0->NK0_MESBOL) = '000000'
					aAdd(aErros, STR0036 + AllTrim(NK0->NK0_INDICE) +; 
						   STR0037 + DToC(dDateTicker) + ". (" +cMesAno+")" ) //". Informação recebida na integração: "
				EndIf
			Else
			   NK0->(DbGoTo(nRecNK0))
			   If AllTrim(NK0->NK0_MESBOL) = '000000' .and. AGRMesAno(cMesAno, 2) != '000000'  //correção vitor Só atualiza se MES BOLSA ESTIVER ERRADO
			   		RecLock("NK0",.F.)
			   		NK0->NK0_DATVEN := dDateTicker
			   		NK0->NK0_VMESAN	:= AGRMesAno(cMesAno, 1) //Retorna ex: JAN/2018
			   		NK0->NK0_MESBOL	:= AGRMesAno(cMesAno, 2) //Retorna ex: 201901
					NK0->(MsUnlock()) //Libera o registro
			   EndIf
			EndIf

			dbSelectArea("NK1") 
			NK1->(dbSetOrder(1))
			/** 
			*** OBS: Adicionado condição .AND. devido se procurar por exemplo CCDM e no banco tiver CCDM18 o dbSeek irá retornar true, pois encontrou o CCDM em parte de algum indice.
			***      Não necessario while, pois o dbSetOrder ja ordena pelo indice, então se existir o CCDM, este será encontrato por primeiro no dbSeek
			**/			
			If NK1->(dbSeek(xFilial("NK1")+DTOS(dDataAtual)+cCodTicker)) .AND. AllTrim(cCodTicker) == AllTrim(NK1->NK1_INDICE) 
				//Se já existe registro na NK1 para o índice, atualiza
				RecLock("NK1",.F.)  //Bloqueia o registro para alteração
				NK1->NK1_VALOR := nValorTicker
				NK1->(MsUnlock()) //Libera o registro
			Else 
				//Se não existe registro na NK1 para o índice, insere
				RecLock("NK1",.T.)  //Bloqueia o registro para alteração
				NK1->NK1_DATA   := dDataAtual //data atual 
				NK1->NK1_INDICE := cCodTicker
				NK1->NK1_VALOR  := nValorTicker
				NK1->(MsUnlock()) //Libera o registro
			EndIf
		EndIf

	Next nX

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} OGX300DUIB
Função que verifica se usa indice de bolsa de referencia(N8C/N8U)

@author claudineia.reinert
@since 05/06/2018
@version P12
@type function
@return Bolean, Retorna .T. se existe cadastro de indice de commodity de bolsa de referencia, senão retorna .F.
/*/
Function OGX300DUIB()
	Local lRet := .F.
	Local cAliasQry := GetNextAlias()
	Local cQuery := ""

	If TableInDic("N8U") .and. TableInDic("N8C") 

		cQuery := "SELECT count(N8U_CODBOL) AS NUMREG "
		cQuery += " FROM " + RETSQLNAME('N8U') + ' N8U '
		cQuery += " WHERE N8U.N8U_FILIAL = '"+ FWxFilial('N8U') + "'"
		cQuery += " AND N8U.D_E_L_E_T_ = ' ' "
		cQuery += " AND N8U.N8U_CODP2 <> '' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
		dbSelectArea(cAliasQry)
		If (cAliasQry)->( !Eof() ) .AND. (cAliasQry)->(NUMREG) > 0
			lRet := .T. //usa indice de bolda de referencia
		Endif
		(cAliasQry)->( dbCloseArea() )

	EndIf

Return lRet

Static Function FormCodTkt(cCodTicker, cFormat)
	Local cNewCod 	:= ""
	Local aFormat 	:= StrTokArr( AllTrim(cFormat), "," ) //1-4
	Local aPos		:= {} //armazena posição quando separado por hifen(-)
	Local nX		:= 0
	
	//OBS: a Validação se esta correto a formatação deve ser realizado na função de validação do campo N8U_FORIND,
	// para ja trazer correto aqui, não precisando de novas validações
	
	For nX = 1 to Len(aFormat)
		If AT("-",aFormat[nX])
			aPos := StrTokArr( aFormat[nX], "-" ) //1-4
			cNewCod += SUBSTR(cCodTicker, VAL(AllTrim(aPos[1])), ( VAL(AllTrim(aPos[2])) - VAL(AllTrim(aPos[1])) + 1 ) ) 
		Else
			cNewCod += SUBSTR(cCodTicker, VAL(AllTrim(aFormat[nX])), 1)
		EndIf
	Next nX	
	
Return cNewCod
