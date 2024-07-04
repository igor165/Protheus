#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TURXFUN.CH'

#DEFINE TP_LOGIC_RET	1 // (.T. , .F.)
#DEFINE TP_CHAR1_RET	2 // ("1" = Sim, "2" = Não"
#DEFINE TP_CHAR2_RET	3 // ("SIM",NÃO") 
#DEFINE TP_CHAR3_RET	4 // ("TRUE","FALSE")
#DEFINE TP_CHAR4_RET	5 // ("VERDADEIRO","FALSO")
#DEFINE TP_NUMB_RET 	6 // ( 1 = SIM, 2 = NÃO)

Static cFilAuxAnt	:= ""
Static cFilAuxFat	:= ""
Static cFilPst 		:= ""
Static cCodPst 		:= ""
Static cTurApura    := ""
Static cTurRetPath	:= ""	//Diretório retonardo pega função cGetFile(..) em Consulta Específica (F3)
Static cTurNaturez	:= "" 	//Natureza utilizada na geração da NFS

Static aTurTables	:= {}
Static aTurMultFil	:= {}
Static aTurSChrHtm	:= {} 
Static aTurPxlsStr	:= {}
Static aSetCpos		:= {}
Static aTblCods     := {{'AC8', 'AC8_CODCON'}, ; 	// CONTACTRELATIONSHIP (CONTATO X ENTIDADE)
				        {'ACY', 'ACY_GRPVEN'}, ; 	// COSTUMERGROUP (GRUPO DE CLIENTES)
				        {'AGT', 'AGT_CODIGO'}, ; 	// CORPORATEGROUP (GRUPO DE SOCIETARIOS)
				        {'G3A', 'G3A_CODIGO'}, ; 	// TRAVELRATE (CADASTRO TAXAS)
				        {'G3B', 'G3B_CODIGO'}, ; 	// PASSENGERTERMINAL (TERMINAL DE PASSAGEIROS)
				        {'G3C', 'G3C_CODIGO'}, ; 	// SERVICECLASS (CLASSE DE SERVICOS)
				        {'G3D', 'G3D_CODIGO'}, ; 	// AGENCYCREDITCARD (CARTOES DE CREDITO TURISMO)
				        {'G3E', 'G3E_CODIGO'}, ; 	// ADDITIONALENTITYTYPE (TIPOS DE ENTIDADES)
				        {'G3F', 'G3F_TIPO'  }, ; 	// ADDITIONALENTITY (ENTIDADE ADICIONAL X CLIENTE)
				        {'G3G', 'G3G_ITEM'  }, ; 	// ADDITIONALENTITY (ENTIDADE ADICIONAL X CLIENTE X ITEM)
				        {'G3H', 'G3H_CODAGE'}, ; 	// TRAVELAGENT (AGENTES DE VIAGENS)
				        {'G3J', 'G3J_CODIGO'}, ; 	// CUSTOMERCREDITCARD (CARTOES DE CREDITO DO CLIENTE)
				        {'G3M', 'G3M_CODIGO'}, ; 	// SERVICESTATION (CADASTRO DE POSTO DE ATENDIMENTO)
				        {'G3N', 'G3N_CODIGO'}, ; 	// TRAVELPAYMENTTERM (FORMAS DE PAGAMENTO)
				        {'G3O', 'G3O_ITEM'  }, ; 	// TRAVELPAYMENTTERM (FORMAS DE PAGAMENTO X GRUPOS DE PRODUTO)
				        {'G3P', 'G3P_NUMID' }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - CABEÇALHO)
				        {'G3Q', 'G3Q_IDITEM'}, ; 	// SALEREGISTRY (REGISTRO DE VENDA - ITEM DE VENDA)
				        {'G3R', 'G3R_IDITEM'}, ; 	// SALEREGISTRY (REGISTRO DE VENDA - DOCUMENTO DE RESERVA)
				        {'G3S', 'G3S_CODPAX'}, ; 	// SALEREGISTRY (REGISTRO DE VENDA - PASSAGEIRO)
				        {'G3T', 'G3T_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - AEREO)
				        {'G3U', 'G3U_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - HOTEL)
				        {'G3V', 'G3V_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - CARRO)
				        {'G3W', 'G3W_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - RODOVIARIO)
				        {'G3X', 'G3X_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - TREM)
				        {'G3Y', 'G3Y_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - CRUZEIRO)
				        {'G3Z', 'G3Z_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - PACOTE)
				        {'G40', 'G40_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - TOUR)
				        {'G41', 'G41_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - SEGURO)
				        {'G42', 'G42_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - VISTO)
				        {'G43', 'G43_ID'    }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - OUTROS)
				        {'G45', 'G45_SEQ'   }, ;	// SALEREGISTRY (REGISTRO DE VENDA - TARIFAS COTADAS)
				        {'G46', 'G46_SEQTAX'}, ; 	// SALEREGISTRY (REGISTRO DE VENDA - TAXAS)
				        {'G47', 'G47_SEQ'   }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - EXTRAS)
				        {'G49', 'G49_SEQ'   }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - IMPOSTOS)
				        {'G4D', 'G4D_SEQ'   }, ; 	// SALEREGISTRY (REGISTRO DE VENDA - DADOS DO CARTAO)
				        {'G4F', 'G4F_CODIGO'}, ; 	// VISATYPE (TIPOS DE VISTO)
				        {'G4G', 'G4G_CODIGO'}, ; 	// INSURANCEPLAN (PLANOS DE SEGUROS)
				        {'G4H', 'G4H_CODIGO'}, ; 	// SHIP (NAVIOS)
				        {'G4I', 'G4I_CODIGO'}, ; 	// CABINTYPE (TIPOS DE CABINE)
				        {'G4J', 'G4J_CODIGO'}, ; 	// APARTMENTTYPE (TIPOS DE APARTAMENTO)
				        {'G4K', 'G4K_CODIGO'}, ; 	// FRONTSYSTEM (SISTEMAS DE ORIGEM)
				        {'G4L', 'G4L_CODIGO'}, ; 	// TRAVELCUSTOMER (CADASTRO DE COMPLEMENTO DE CLIENTE)
				        {'G4R', 'G4R_FORNEC'}, ; 	// TRAVELVENDOR (CADASTRO DE COMPLEMENTO DE FORNECEDOR)
				        {'G4Y', 'G4Y_CODIGO'}, ; 	// VEHICLECATEGORY (CATEGORIAS DE VEICULOS)
				        {'G4Z', 'G4Z_CODIGO'}, ; 	// VEHICLETYPE (CADASTRO DE TIPOS DE VEICULO)
				        {'G50', 'G50_CODIGO'}, ; 	// DIRECTIONTYPE (TRANSMISSAO/DIRECAOVEICULO)
				        {'G51', 'G51_CODIGO'}, ; 	// FUELTYPE (TIPOS DE COMBUSTIVEL/AR
				        {'G5M', 'G5M_CODIGO'}, ; 	// VENDORGROUP (GRUPOS DE FORNECEDORES)
				        {'G5O', 'G5O_CODIGO'}, ; 	// BROADCASTTYPE (TIPO EMISSAO)
				        {'G5R', 'G5R_CODIGO'}, ; 	// TAX (CADASTRO DE IMPOSTOS TURISMO)
				        {'G5S', 'G5S_CODIGO'}, ; 	// CITY (CADASTRO DE CIDADES TURISMO)
				        {'G5T', 'G5T_CODIGO'}, ; 	// CURRENCY (CADASTRO DE MOEDAS TURISMO)
				        {'G8M', 'G8M_CODIGO'}, ; 	// ROADLINESTRETCH (CADASTRO DE LINHAS E TRECHOS)
				        {'G8N', 'G8N_CODIGO'}, ; 	// ROADLINESTRETCH (CADASTRO DE LINHAS E TRECHOS - ITEM)
				        {'G8O', 'G8O_CODIGO'}, ; 	// BROKERSYSTEM (SISTEMAS DE BROKER)
				        {'G8P', 'G8P_CODIGO'}, ; 	// REFUNDREASON (MOTIVO DE REEMBOLSO)
				        {'G8Q', 'G8Q_CODIGO'}, ;	// AGENCYCREDITCARD (CARTOES DE CREDITO TURISMO - CLASSIFICAÇÃO DE CARTÕES)
				        {'SA1', 'A1_COD'    }, ; 	// CUSTOMERVENDOR (CLIENTES)
				        {'SA2', 'A2_COD'    }, ; 	// CUSTOMERVENDOR (FORNECEDORES)
				        {'SB1', 'B1_COD'    }, ; 	// ITEM (PRODUTOS)
				        {'SBM', 'BM_GRUPO'  }, ; 	// FAMILY (GRUPO DE PRODUTOS)
				        {'SU5', 'U5_CODCONT'}} 		// CONTACT (CONTATOS)

Static _TURDIRRET   := ""


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURXMAKEID

Função que retorna o InternalId da Entidade de acordo com o valor interno gerado

@sample 	TURAMakeId(cId, cAlias, cEmp, cFil)
@param		cId - String com o Código da Entidade
			cAlias - String com o Alias da Entidade
			cEmp - String com o Código da Empresa da integração  
			cFil - String com o Código da Filial da integração, se vier vazio pega a filial logada  
@return   	cRet - String com a Chave completa da Entidade                           
@author	Jacomo Lisa
@since		20/09/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------------------
Function TURXMakeId(cId, cAlias, cEmp, cFil)

Local   cRet := ""
Default cEmp := cEmpAnt
Default cFil := xFilial(cAlias)
If !Empty(cId)
	cRet := RTrim(cEmp) + '|' + RTrim(cFil) + '|' + RTrim(cId)
Endif

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURXRETID

Função que retorna o InternalId da Entidade de acordo com o valor externo recebido

@sample 	TURXRETID(cMarca, cAlias, cCampo, cExtID, cIntID, nOrdem)
@param		cMarca - String com a Marca da integração
			cAlias - String com o Alias da Entidade
			cCampo - String com o nome do Campo que será verificado no DE/PARA 
			cExtId - String com a Chave EXTERNA da entidade 
			cIntId - String com a Chave INTERNA da entidade 
			nOrdem - Inteiro onde é informada a posição do Array que deverá ser retornada
@return   	aRet - Array com os valores que compõem a chave da entidade                          
@author	Jacomo Lisa
@since		20/09/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------------------
Function TURXRetId(cMarca, cAlias, cCampo, cExtID, cIntID, nOrdem, cErro)

Local aRet		 := NIL
Default nOrdem := 0
cErro		:= ""
cIntID := AllTrim(CFGA070INT(cMarca, cAlias, cCampo, cExtID))
If !Empty(cIntID)
	If nOrdem > 0
		aRet := Alltrim(Separa(cIntID, '|')[nOrdem])
	Else
		aRet := Separa(cIntID, '|' )
	EndIf
Else
	cErro := Alltrim(TRX2Name( cAlias ))+': '+cExtID + STR0039//' Não encontrado no Dê/Para'
Endif

Return aRet

/*/{Protheus.doc} TRX2Name
Função que retorna a descrição da tabela
@author elton.alves
@since 16/09/2015
@version 1.0
@param cAlias, Caracter, Alias da tabela
@return Caracter, Nome da tabela
/*/
Function TRX2Name( cAlias )
	
	Local cRet := ''
	
	If SX2->( DbSeek( cAlias ) )
		
		cRet := Capital( X2Nome() )
		
	End If
	
Return cRet


//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TxGetNdXml()
Função utilizada para validar e pegar o valor da Tag.

@type 		Function
@author 	Jacomo Lisa
@since 	16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function TxGetNdXml(oXml,cNode,oModel,cCampo,xVal )
Local lRet	:= .T.
Default xVal:= nil 
If oXml:XPathHasNode( cNode ) .or. "INTERNALID" $ UPPER(cNode)     
	If Valtype(xVal) == 'U'
		xVal := TxRetVal(oXml:XPathGetNodeValue(cNode),cCampo)
	Endif
	lRet	:= TxSetVal(oModel,cCampo,xVal) 
Endif

Return lRet

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TxRetVal()
Função utilizada para retornar valores validos para o campo

@type 		Function
@author 	Jacomo Lisa
@since 	16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function TxRetVal(xVal,cCampo)
Local xRet := nil
SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))
	If SX3->X3_TIPO == 'C'
		xRet := Padr(Alltrim( xVal ),SX3->X3_TAMANHO  )	
	ElseIf SX3->X3_TIPO == 'D'
		xRet := TxDtStamp(Alltrim(xVal),.F.)
	ElseIf SX3->X3_TIPO == 'N'
		xRet := Val(Alltrim(xVal))
	ElseIf SX3->X3_TIPO == 'L'
		xRet := TURXLogic(Alltrim(xVal), TP_LOGIC_RET) 
	ElseIf SX3->X3_TIPO == 'M'
		xRet := Alltrim( xVal )	
	ENDIF
Endif
Return xRet

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TxSetVal()
Função utilizada para validar e carregar os valores no campo.

@type 		Function
@author 	Jacomo Lisa
@since 	16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------

Function TxSetVal(oModel,cCampo,xValue)
Local lRet := .T.
If ValType(aSetCpos) <> "A" .or. Len(aSetCpos) == 0 
	aSetCpos := {'G3Q_CLIENT','G3R_FORNEC','G3R_FORREP','G3T_CODFOR','G3T_LOJAF','G3T_DTSAID','G3T_HRINI' ,;
				'G3U_DTINI','G3U_HRINI','G3V_DTINI','G3V_HRINI','G3W_LINHA','G3W_DTINI','G3W_HRINI',;
				'G3X_DTINI','G3X_HRINI','G3X_HRFIM','G3Y_DTINI','G3Y_HRINI','G3Z_DTINI','G3Z_HRINI',;
				'G40_DTINI','G40_HRINI','G41_DTINI','G43_DTINI','G43_DTFIM' }
Endif
If oModel:GetValue(cCampo) <> xValue 
//	If ascan(aSetCpos,{|x| x == Alltrim(cCampo) }) > 0  
//		TI034Ajust(oModel,cCampo)
//	Endif
	lRet := oModel:SetValue(cCampo,xValue)
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TXDTSTAMP

Função que retorna o respectivo valor de campos utilizados como LÓGICO / BOOLEANO

@sample 	TxDtStamp(xInfo, lTipo, lOnlyDate)
@param		xInfo		- Variável que pode ser String/Lógica/Inteiro com valor a ser comparado
			lTipo		- Se .T. xRet := Formato "AAAA-MM-DDt00:00:00-03:00", Se .F. xRet := "DD/MM/AAAA"
			lOnlyDate	- Define se o retorno será só com Data ou Junto com o Horario (Apenas para lTipo = .T.)
@return   	xRet		- Se lTipo = .T. xRet := Formato "AAAA-MM-DDt00:00:00-03:00", Se .F. xRet := "DD/MM/AAAA"
@author	Jacomo Lisa
@since		11/11/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TxDtStamp(xInfo, lTipo, lOnlyDate)

Local xRet  := ""
Local nType := 3
Local cTime := Time()

Default lTipo     := .T.
Default xInfo     := Date()
Default lOnlyDate := .T.

//Tipo = .T. -> Funcionalidade normal do TimeStampo. Retorno no formato "AAAA-MM-DDt00:00:00-03:00"
If !Empty(xInfo)
	If lTipo
	   
	   If ValType(xInfo) == "C"
	       xInfo := cToD(xInfo)
	   EndIf
	
	   xRet := FWTimeStamp( nType, xInfo, cTime )
	   
	   If lOnlyDate // Tratamento para retornar somente "AAAA-MM-DD"
	      xRet := SubStr(xRet , 1, At("T", xRet)-1 )
	   EndIf
	
	//Tipo = .F. -> Inverte o formato de TimeStamp para data Normal. Retorna uma data   
	Else
	   
	   //Pegando a data:
	   If At("T", xInfo) > 0
	      xInfo := SubStr(xInfo , 1, At("T", xInfo)-1 ) //"2011-12-20T00:00:00-03:00" -> "2011-12-20"
	   EndIf
	   
	   //Retirando os '-':
	   xInfo := StrTransf(xInfo,"-","") //"2011-12-20" -> "20111220"
	   
	   //Formatando a data
	   xRet := SToD(xInfo) //"20111220" -> "20/12/2011"
	   
	EndIf
Else
	xRet := If(!lTipo,SToD(xInfo),"")
EndIf

Return xRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURXLOGIC

Função que retorna o respectivo valor de campos utilizados como LÓGICO / BOOLEANO

@sample 	TURXLogic(xValue, nTypeRet)
@param		xValue - Variável que pode ser String/Lógica/Inteiro com valor a ser comparado
			nTypeRet - Inteiro que informa o tipo de retorno  
@return   	xRet                           
@author	Jacomo Lisa
@since		20/09/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------------------
Function TURXLogic(xValue, nTypeRet)

Local xRet

If ValType(xValue) == "C"
	If upper(xValue) == "SIM" .Or. xValue == "1" .Or. upper(xValue) == "TRUE" .Or. upper(xValue) == "VERDADEIRO"
		if nTypeRet == TP_LOGIC_RET
			xRet := .T.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "1"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "SIM"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "TRUE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "VERDADEIRO"
		Else
			xRet := 1
		Endif
	Else
		if nTypeRet == TP_LOGIC_RET
			xRet := .F.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "2"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "NÃO"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "FALSE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "FALSO"
		Else
			xRet := 2
		Endif
	Endif
	
ElseIf ValType(xValue) == "L"
	IF xValue
		if nTypeRet == TP_LOGIC_RET
			xRet := .T.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "1"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "SIM"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "TRUE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "VERDADEIRO"
		Else
			xRet := 1
		Endif
	Else
		if nTypeRet == TP_LOGIC_RET
			xRet := .F.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "2"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "NÃO"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "FALSE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "FALSO"
		Else
			xRet := 2
		Endif
	Endif

ElseIf ValType(xValue) == "N"
	IF xValue == 1 
		if nTypeRet == TP_LOGIC_RET
			xRet := .T.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "1"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "SIM"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "TRUE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "VERDADEIRO"
		Else
			xRet := 1
		Endif
	Else
		if nTypeRet == TP_LOGIC_RET
			xRet := .F.
		ElseIf nTypeRet == TP_CHAR1_RET
			xRet := "2"
		ElseIf nTypeRet == TP_CHAR2_RET
			xRet := "NÃO"
		ElseIf nTypeRet == TP_CHAR3_RET
			xRet := "FALSE"
		ElseIf nTypeRet == TP_CHAR4_RET
			xRet := "FALSO"
		Else
			xRet := 2
		Endif
	Endif
Endif

Return xRet


//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TxValCpo()
Função utilizada para validar se o campo existe na estrutura

@type 		Function
@author 	Jacomo Lisa
@since 	16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function TxValCpo(aEstru,cCampo)

Return ascan(aEstru,{|x| x[3] == Alltrim(cCampo) }) > 0  

/*/{Protheus.doc} TURXSLDIF
Função que verifica o saldo do cliente a pagar
@type function
@author osmar.junior
@since 04/08/2016
@version 1.0
@param cCodCli, character, (Código do Cliente)
@param cLoja, character, (Loja do Cliente)
@param cSegTur, character, (Segmento - Corporativo/Evento/Lazer)
@return $nSaldo, $Valor do saldo
/*/
Function TURXSLDIF(cCodCli,cLoja,cSegTur)
Local nSaldo		:= 0
Local cAliasAux 	:= GetNextAlias()
Local cCONINU		:= SPACE(TAMSX3('G4C_CONINU')[1])
Local cExpLoja	:= '%%'


If !Empty(cLoja)
	cExpLoja := "%G4C_LOJA ='"+cLoja+"' AND%"
EndIF

BeginSQL Alias cAliasAux
	SELECT SUM(CASE WHEN G4C_PAGREC = '1' THEN (G4C_VALOR*-1) ELSE G4C_VALOR END) SALDO 
	FROM %Table:G4C% G4C
	WHERE 
	G4C_FILIAL =	%XFilial:G4C% AND
	G4C_CLIFOR =	'1' AND
	G4C_CODIGO =	%Exp:cCodCli%	 AND
	%Exp:cExpLoja%
	G4C_SEGNEG =	%Exp:cSegTur%	 AND
	G4C_CONINU =	%Exp:cCONINU% AND
	G4C.%NotDel%

EndSQL
                                                                                                                 
If !( (cAliasAux)->(Eof()) )

	nSaldo:= (cAliasAux)->SALDO
		
Endif	

(cAliasAux)->(DbCloseArea())

Return nSaldo

/*/{Protheus.doc} TurGetNatur
Utilizada na mata461.prx para obter a natureza das NF de saída do módulo de Turismo
@type function
@author Anderson Toledo
@since 17/06/2016
@version 1.0
/*/
Function TurGetNatur()

Return cTurNaturez

//------------------------------------------------------------------------------
/*/{Protheus.doc} TURxCond

Função para montagem de parcelas conforme condição de pagamento do Turismo

@sample	TURxCond()
@author    José Domingos Caldana Jr
@since     11/08/2016
@version 	12.1.13
/*/
//------------------------------------------------------------------------------

Function TURxCond(nValor,cCondPgto,dData)
		
Local aArea		:= GetArea()
Local aParcelas	:= {}
		
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
If SE4->(DbSeek(xFilial('SE4')+cCondPgto))
	If SE4->E4_TIPO == '9'
		aParcelas := TA009Cond( cCondPgto, nValor, dData )
	Else
		aParcelas := Condicao( nValor, cCondPgto,,dData  )
	EndIf
EndIf

RestArea(aArea)

Return aParcelas

/*/{Protheus.doc} TA009Cond
Função para calculo de parcelas do Tipo 9 utilizando o complemento cadastrado
@author Anderson Toledo
@since 28/04/2016
@version 
/*/
Function TA009Cond( cCondPgto, nValor, dData )
	Local aParcelas 	:= {}
	Local aExcecoes	:= {}
	Local aDow 		:= { 'DIASEG', 'DIATER', 'DIAQUA', 'DIAQUI', 'DIASEX', 'DIASAB', 'DIADOM' }
	Local cCampoSimu	:= ''
	Local dDtCont		:= ctod( ' / / ' )
	Local dDtVenc		:= ctod( ' / / ' )
	Local nQtdPar		:= 0
	Local nVlrParc  	:= 0
	Local nVlrDif		:= 0
	Local nX			:= 0
	
	DEFAULT dData	:= dDataBase

	G66->( dbSetOrder(1) ) 
	If G66->( dbSeek( xFilial( 'G66' ) + cCondPgto ) )
		//Adiciona as excessões
		For nX := 1 to 32
			If nX <= 31
				cCampoSimu := 'G66_DIAM' + cValToChar(nX)
			Else
				cCampoSimu := 'G66_UDIA'
			Endif
			
			aAdd( aExcecoes, { cCampoSimu, SubStr( G66->G66_DIAMES,nX,1 ) == 'S' } )
		Next
		
		For nX := 1 to len(aDow)
			aAdd( aExcecoes, { 'G66_' + aDow[nX], SubStr( G66->G66_DIASEM,nX,1 ) == 'S'} )
		Next
		
		
		nVlrParc  	:= nValor / G66->G66_QTDPAR
		
		// Calcula o valor das parcelas
		If SuperGetMv( 'MV_ARRDPRC',.F.,"1" ) = '1'
			
			nVlrParc := Round( nVlrParc, 2 )
			
		Else
			
			nVlrParc := NoRound( nVlrParc, 2 )
			
		EndIf

		// Calcula se há diferença dpo somatório das parcelas com o valor total de faturamento
		nVlrDif := nValor - ( nVlrParc * G66->G66_QTDPAR )
	
		// Verifica a data do início da contagem
		If G66->G66_INCCNT == '1' // Fechamento
			dDtCont := dData
		
		ElseIf G66->G66_INCCNT == '2' // Fora da Semana
		
			dDtCont := dData + ( 8 - Dow( dData ) )
		
		Else // Fora do Mês
		
			dDtCont := DaySum( LastDate( dData ), 1 )
		
		EndIf
		
		// Calcula primeiro vencimento
		dDtVenc := TRSomaDias( dDtCont, G66->G66_QTDDIA + G66->G66_QTDIAT, G66->G66_CONTG, G66->G66_FERIAD, aExcecoes)
		
		For nX := 1 To G66->G66_QTDPAR
		
			If SuperGetMv( 'MV_DIFPARC',.F.,"1"  ) == '1' .And. nX == 1 // Verifica se adciona diferença de soma de parcelas na primeira parcela
			
				aAdd( aParcelas, { dDtVenc, nVlrParc + nVlrDif } )
			
			ElseIf SuperGetMv( 'MV_DIFPARC',.F.,"1" ) == '2' .And. nX == nQtdPar  // Verifica se adciona diferença de soma de parcelas na última parcela
			
				aAdd( aParcelas, { dDtVenc, nVlrParc + nVlrDif } )
			
			Else
			
				aAdd( aParcelas, { dDtVenc, nVlrParc } )
			
			EndIf
		
			dDtVenc := TRSomaDias( dDtVenc, G66->G66_QTDDIA , G66->G66_CONTG, G66->G66_FERIAD, aExcecoes )
		
		Next nX
		
		
		
	EndIf

Return aParcelas


/*/{Protheus.doc} TRSomaDias
Calcula da data final de um intervalo somando uma quantidade de dias e considerandos serão corridos ou dias úteis, também trata as exceções e se o dia é um feriado
@author Elton Teodoro Alves
@since 20/07/2015
@version 1.0
@param dData, Data, Data de Fechamento
@param nDias, Numero, Quantidade de dias de intervalo entre as datas
@param cContag, Caractere, Indica o tipo de contagem 1=Dias Corridos / 2=Dias úteis
@param cFeriad, Caractere, Indica o tipo de tratamento quando vencimento é feriado 1=Mantém / 2=Antecipa / 3=Posterga
@param aExcecoes, Array, Contém a lista de exceções de datas de vencimento
@return Data Retorna data calcula a fim do intervalo
/*/
Function TRSomaDias( dData, nDias, cContag, cFeriad, aExcecoes )
	
	Local dRet := dData
	Local aDow := { 'DIADOM', 'DIASEG', 'DIATER', 'DIAQUA', 'DIAQUI', 'DIASEX', 'DIASAB' }
	Local nX   := 1
	
	If cContag == '1' // Considera dias corridos
		
		dRet := DaySum( dRet, nDias )
		
	ELse
		// Considera dias  úteis
		Do While nX <= nDias
			
			// Verifica se a data não é uma Sexta-Feira, Sábado ou Feriado e salta incremento.
			If !( Dow( dRet ) == 6 .Or. Dow( dRet ) == 7 .Or. TRFeriado( dRet ) )
				
				nX++
				
			EndIf
			
			dRet := DaySum( dRet, 1 )
			
		EndDo
		
	EndIf
	
	// Trata as execeçoes definidas, se é um dia do mês e/ou dia da semana permitido para vencimento.
	Do While aExcecoes[ aScan( aExcecoes, { | X | X[ 1 ] == 'G66_DIAM' + cValToChar( Day( dRet ) ) } )][ 2 ] .Or.;
			aExcecoes[ aScan( aExcecoes, { | X | X[ 1 ] == 'G66_' + aDow[ Dow( dRet ) ] } ) ][ 2 ]
		
		dRet := DaySum( dRet, 1 )
		
	EndDo
	
	//Trata se dia é feriado conforme definido em G66_FERIAD
	If ! cFeriad == '1' // Mantém
		
		Do While TRFeriado( dRet )
			
			If cFeriad == '2' // Antecipa
				
				dRet := DaySub( dRet, 1 )
				
			Else // Posterga
				
				dRet := DaySum( dRet, 1 )
				
			EndIf
			
		EndDo
		
	EndIF
	
Return dRet

/*/{Protheus.doc} TRFeriado
Verifica se uma data é ou não feriado
@author Elton Teodoro Alves
@since 20/07/2015
@version 1.0
@param dData, Data, Data a ser verificada
@return Lógico Indica se a data é um feriado
/*/
Function TRFeriado( dData )
	
	Local lRet  := .F.
	Local aArea := GetArea()
	Local cDia  := Day2Str( dData)
	Local cMes  := Month2Str( dData)
	
	DbSelectArea( 'SP3' )
	
	DbSetOrder( 1 ) // P3_FILIAL+Dtos(P3_DATA)
	
	lRet := DbSeek( xFilial( 'SP3' ) + dToS( dData ) )
	
	DbSetOrder( 2 ) // P3_FILIAL+P3_MESDIA+P3_FIXO
	
	lRet := DbSeek( xFilial( 'SP3' ) + cMes + cDia + 'S' ) .Or. lRet
	
	RestArea( aArea )
	
Return lRet

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TxSetNode()

Função utilizada para validar e carregar os valores no campo.

@type 		Function
@author 	Jacomo Lisa
@since 		16/05/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function TI034Ajust(oModel, cCampo)

Local lRet     := .T.
Default cCampo := ""

Do Case
	//G3Q ----------------------
	Case cCampo == "G3Q_CLIENT"
		If !Empty(oModel:GetValue('G3Q_LOJA'))
			lRet := oModel:LoadValue('G3Q_LOJA', "")
		EndIf

	//G3R ----------------------	
	Case cCampo == "G3R_FORNEC"
		If !Empty(oModel:GetValue('G3R_LOJA'))
			lRet := oModel:LoadValue('G3R_LOJA', "")
		EndIf
	Case cCampo == "G3R_FORREP"
		If !Empty(oModel:GetValue('G3R_LOJREP'))
			lRet := oModel:LoadValue('G3R_LOJREP', "")
		EndIf

	//G3T ----------------------	
	Case cCampo == "G3T_CODFOR"
		If !Empty(oModel:GetValue('G3T_LOJAF'))
			lRet := oModel:LoadValue('G3T_LOJAF', "")
		EndIf
	Case cCampo == "G3T_DTSAID"
		If !Empty(oModel:GetValue('G3T_DTCHEG'))
			lRet := oModel:LoadValue('G3T_DTCHEG', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3T_HRINI'))
			lRet := oModel:LoadValue('G3T_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3T_HRFIM'))
			lRet := oModel:LoadValue('G3T_HRFIM', "")
		EndIf
	Case cCampo == "G3T_HRINI"
		If !Empty(oModel:GetValue('G3T_HRFIM'))
			lRet := oModel:LoadValue('G3T_HRFIM', "")
		EndIf

	//G3U ----------------------	
	Case cCampo == "G3U_DTINI"
		If !Empty(oModel:GetValue('G3U_DTFIM'))
			lRet := oModel:LoadValue('G3U_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3U_HRINI'))
			lRet := oModel:LoadValue('G3U_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3U_HRFIM'))
			lRet := oModel:LoadValue('G3U_HRFIM', "")
		EndIf
	Case cCampo == "G3U_HRINI"
		If !Empty(oModel:GetValue('G3U_HRFIM'))
			lRet := oModel:LoadValue('G3U_HRFIM', "")
		EndIf

	//G3V ----------------------	
	Case cCampo == "G3V_DTINI"
		If !Empty(oModel:GetValue('G3V_DTFIM'))
			lRet := oModel:LoadValue('G3V_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3V_HRINI'))
			lRet := oModel:LoadValue('G3V_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3V_HRFIM'))
			lRet := oModel:LoadValue('G3V_HRFIM', "")
		EndIf
	Case cCampo == "G3V_HRINI"
		If !Empty(oModel:GetValue('G3V_HRFIM'))
			lRet := oModel:LoadValue('G3V_HRFIM', "")
		EndIf

	//G3W ----------------------	
	Case cCampo == "G3W_LINHA"
		If !Empty(oModel:GetValue('G3W_TRECHO'))
			lRet := oModel:LoadValue('G3W_TRECHO', "")
		EndIf
	Case cCampo == "G3W_DTINI"
		If !Empty(oModel:GetValue('G3W_DTFIM'))
			lRet := oModel:LoadValue('G3W_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3W_HRINI'))
			lRet := oModel:LoadValue('G3W_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3W_HRFIM'))
			lRet := oModel:LoadValue('G3W_HRFIM', "")
		EndIf
	Case cCampo == "G3W_HRINI"
		If !Empty(oModel:GetValue('G3W_HRFIM'))
			lRet := oModel:LoadValue('G3W_HRFIM', "")
		EndIf

	//G3X ----------------------	
	Case cCampo == "G3X_DTINI"
		If !Empty(oModel:GetValue('G3X_DTFIM'))
			lRet := oModel:LoadValue('G3X_DTFIM', CtoD(""))
		EndIf

	//G3Y ----------------------	
	Case cCampo == "G3Y_DTINI"
		If !Empty(oModel:GetValue('G3Y_DTFIM'))
			lRet := oModel:LoadValue('G3Y_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3Y_HRINI'))
			lRet := oModel:LoadValue('G3Y_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3Y_HRFIM'))
			lRet := oModel:LoadValue('G3Y_HRFIM', "")
		EndIf
	Case cCampo == "G3Y_HRINI"
		If !Empty(oModel:GetValue('G3Y_HRFIM'))
			lRet := oModel:LoadValue('G3Y_HRFIM', "")
		EndIf

	//G3Z ----------------------	
	Case cCampo == "G3Z_DTINI"
		If !Empty(oModel:GetValue('G3Z_DTFIM'))
			lRet := oModel:LoadValue('G3Z_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G3Z_HRINI'))
			lRet := oModel:LoadValue('G3Z_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G3Z_HRFIM'))
			lRet := oModel:LoadValue('G3Z_HRFIM', "")
		EndIf
	Case cCampo == "G3Z_HRINI"
		If !Empty(oModel:GetValue('G3Z_HRFIM'))
			lRet := oModel:LoadValue('G3Z_HRFIM', "")
		EndIf

	//G40 ----------------------	
	Case cCampo == "G40_DTINI"
		If !Empty(oModel:GetValue('G40_DTFIM'))
			lRet := oModel:LoadValue('G40_DTFIM', CtoD(""))
		EndIf
		If !Empty(oModel:GetValue('G40_HRINI'))
			lRet := oModel:LoadValue('G40_HRINI', "")
		EndIf
		If !Empty(oModel:GetValue('G40_HRFIM'))
			lRet := oModel:LoadValue('G40_HRFIM', "")
		EndIf
	Case cCampo == "G40_HRINI"
		If !Empty(oModel:GetValue('G40_HRFIM'))
			lRet := oModel:LoadValue('G40_HRFIM', "")
		EndIf

	//G41 ----------------------	
	Case cCampo == "G41_DTINI"
		If !Empty(oModel:GetValue('G41_DTFIM'))
			lRet := oModel:LoadValue('G41_DTFIM', CtoD(""))
		EndIf

	//G43 ----------------------	
	Case cCampo == "G43_DTINI"
		If !Empty(oModel:GetValue('G43_DTFIM'))
			lRet := oModel:LoadValue('G43_DTFIM', CtoD(""))
		EndIf
EndCase

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} T34CmpAtIF
	Alimenta array aCmpAtuIf

@since		13/04/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Function T34CmpAtIF()

Local aCampos := {}

//Campos que ao ser atualizado refazem Item Financeiro
//G3Q - Item de Venda
aAdd(aCampos, {"G3Q_OPERAC"})
aAdd(aCampos, {"G3Q_DESPOP"})
aAdd(aCampos, {"G3Q_TPDOC" })
aAdd(aCampos, {"G3Q_DOC"   })
aAdd(aCampos, {"G3Q_DTINC" })
aAdd(aCampos, {"G3Q_EMISS" })
aAdd(aCampos, {"G3Q_CLIENT"})
aAdd(aCampos, {"G3Q_LOJA"  })
aAdd(aCampos, {"G3Q_PROD"  })
aAdd(aCampos, {"G3Q_FORMPG"})
aAdd(aCampos, {"G3Q_MOEDCL"})
aAdd(aCampos, {"G3Q_TXCAMB"})
aAdd(aCampos, {"G3Q_TARIFA"})
aAdd(aCampos, {"G3Q_TAXA"  })
aAdd(aCampos, {"G3Q_EXTRA" })
aAdd(aCampos, {"G3Q_DESTIN"})
aAdd(aCampos, {"G3Q_STATUS"})
aAdd(aCampos, {"G3Q_ACORDO"})
aAdd(aCampos, {"G3Q_SOLIC" })
aAdd(aCampos, {"G3Q_NATURE"})

//G3R - Doc. Reserva
aAdd(aCampos, {"G3R_OPERAC"})
aAdd(aCampos, {"G3R_TPDOC" })
aAdd(aCampos, {"G3R_DOC"   })
aAdd(aCampos, {"G3R_DTINC" })
aAdd(aCampos, {"G3R_EMISS" })
aAdd(aCampos, {"G3R_PROD"  })
aAdd(aCampos, {"G3R_FORNEC"})
aAdd(aCampos, {"G3R_LOJA"  })
aAdd(aCampos, {"G3R_FORREP"})
aAdd(aCampos, {"G3R_LOJREP"})
aAdd(aCampos, {"G3R_MOEDA" })
aAdd(aCampos, {"G3R_TXCAMB"})
aAdd(aCampos, {"G3R_TARIFA"})
aAdd(aCampos, {"G3R_TAXA"  })
aAdd(aCampos, {"G3R_EXTRAS"})
aAdd(aCampos, {"G3R_TXREE" })
aAdd(aCampos, {"G3R_STATUS"})
aAdd(aCampos, {"G3R_DESPOP"})
aAdd(aCampos, {"G3R_NATURE"})

//G4A - Rateio
aAdd(aCampos, {"G4A_TPENT" })
aAdd(aCampos, {"G4A_LOJA"  })
aAdd(aCampos, {"G4A_ITEM"  })
aAdd(aCampos, {"G4A_PERRAT"})

//G4B - Informações Adicionais
aAdd(aCampos, {"G4B_LOJA"  })

//G9K - Demonstrativo
aAdd(aCampos, {"G9K_MODO"  })
aAdd(aCampos, {"G9K_CONDPG"}) 

//G4D - Cartão de Turismo
aAdd(aCampos, {"G4D_CODCAR"})
aAdd(aCampos, {"G4D_PROPRI"})

//G4E - Reembolso
aAdd(aCampos, {"G4E_LIMREE"})
aAdd(aCampos, {"G4E_TARUTI"})
aAdd(aCampos, {"G4E_TREEMB"})
aAdd(aCampos, {"G4E_EXREEM"})
aAdd(aCampos, {"G4E_TXREEM"})

Return aCampos
