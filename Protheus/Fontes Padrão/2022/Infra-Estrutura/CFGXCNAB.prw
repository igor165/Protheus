#Include 'Protheus.ch'

#define TAM_AGENCIA 04
#define TAM_DVAGENC 01
#define TAM_DVCONTA 01

Static lFKFCed := AliasInDic("FKF") .and. FKF->(ColumnPos("FKF_CEDENT") > 0)

/*/{Protheus.doc} CNABAGENC
	Retorna Informa��es da Ag�ncia de Acordo com registro posicionado na SEA

	@type  Function
	@author Alison Lemes
	@since 18/09/2019
	@version P12

	@param cTab, charactere, Tabela de Origem

	@return aRet, array, [01] - Ag�ncia, [02] - D�gito Verificador da Ag�ncia

	/*/
Function CNABAGENC(cTab)
	Local aRet     := {} //Array de Retorno
	Local cAgencia := "" //C�digo da Ag�ncia
	Local cDVAgenc := "" //D�gito Verificador da Ag�ncia

	Default cTab := "SEA"

	If (cTab == "SEA")
		cAgencia := AllTrim(StrTran(SEA->EA_AGEDEP, "-", ""))
	Else //SE2
		cAgencia := AllTrim(StrTran(IIf(Empty(SE2->E2_FORAGE), SA2->A2_AGENCIA, SE2->E2_FORAGE), "-", ""))
	EndIf

	//Verificar se a Ag�ncia possui Tamanho maior
	If (Len(cAgencia) > TAM_AGENCIA)
		//Ag�ncia e D�gito no mesmo campo
		cDVAgenc := SubStr(cAgencia, TAM_AGENCIA + 01, TAM_DVAGENC)
		cAgencia := Left(cAgencia, TAM_AGENCIA)
	ElseIf (cTab == "SEA")
		cDVAgenc := CNABDVAG()
	Else
		If (Empty(SE2->E2_FORCTA)) //Fornecedor
			cDVAgenc := AllTrim(SA2->A2_DVAGE)
		Else //T�tulo a Pagar
			cDVAgenc := AllTrim(SE2->E2_FAGEDV)
		EndIf
	EndIf

	//Compondo Array de Retorno
	aRet := {cAgencia, cDVAgenc}
Return aRet

/*/{Protheus.doc} CNABCONTA
	Retorna Informa��es da Conta de Acordo com registro posicionado na SEA

	@type  Function
	@author Alison Lemes
	@since 18/09/2019
	@version P12

	@param cTab, charactere, Tabela de Origem

	@return aRet, array, [01] - Conta, [02] - D�gito Verificador da Conta

	/*/
Function CNABCONTA(cTab)
	Local aRet     := {} //Array de Retorno
	Local cConta   := "" //C�digo da Conta
	Local cDVConta := "" //D�gito Verificador da Conta

	Default cTab := "SEA"

	If (cTab == "SEA")
		cConta   := AllTrim(StrTran(SEA->EA_NUMCON, "-", ""))
		cDVConta := CNABDVCC()
	Else //SE2
		cConta := AllTrim(StrTran(IIf(Empty(SE2->E2_FORCTA), SA2->A2_NUMCON, SE2->E2_FORCTA), "-", ""))

		If (Empty(SE2->E2_FORCTA))
			cDVConta := AllTrim(SA2->A2_DVCTA)
		Else
			cDVConta := AllTrim(SE2->E2_FCTADV)
		EndIf
	EndIf

	//Verificar se possui Digito Verificador de Conta
	If (Empty(cDVConta))
		//Conta e D�gito no mesmo campo
		cDVConta := Right(cConta, TAM_DVCONTA)
		cConta   := SubStr(cConta, 01, Len(cConta) - TAM_DVCONTA)
	EndIf

	//Compondo Array de Retorno
	aRet := {cConta, cDVConta}
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNABDVAG()
Digito verificador ag�ncia.

@author  Leonardo Castro
@since   15/06/2018
@version Protheus 12.1.20
/*/
//-------------------------------------------------------------------
Function CNABDVAG()
Return POSICIONE("SA6", 1, xFilial("SA6") + SEA->EA_PORTADO + SEA->EA_AGEDEP + SEA->EA_NUMCON, "A6_DVAGE")

//-------------------------------------------------------------------
/*/{Protheus.doc} CNABDVCC()
Digito verificador conta corrente.

@author  Leonardo Castro
@since   15/06/2018
@version Protheus 12.1.20
/*/
//-------------------------------------------------------------------
Function CNABDVCC()
Return POSICIONE("SA6", 1, xFilial("SA6") + SEA->EA_PORTADO + SEA->EA_AGEDEP + SEA->EA_NUMCON, "A6_DVCTA")


//-------------------------------------------------------------------
/*/{Protheus.doc} CNABCED()
Retorna o cedente/benefici�rio do boleto banc�rio.

@param   cChaveSE2 (opicional) - Chave de pesquisa do IDDoc do t�tulo correspondente.

@return  aRet - Array contendo os dados do fornecedor cedente/benefici�rio do boleto.
aRet[1] - (caractere) Tipo de inscri��o (1-CPF / 2-CNPJ)
aRet[2] - (caractere) N�mero da inscri��o (CPF ou CNPJ)
aRet[3] - (caractere) Nome do cedente/benefici�rio
aRet[4] - (caractere) Os tr�s campos acima concatenados

@author  Felipe Raposo
@since   26/08/2019
@version Protheus 12.1.25
/*/
//-------------------------------------------------------------------
Function CNABCED(cChaveSE2 as character)

Local aRet       as array
Local aArea      as array
Local aSA2Area   as array
Local cIdDoc     as character

// Chave de pesquisa para o ID do t�tulo.
If cChaveSE2 == nil
	cChaveSE2 := SE2->(E2_FILIAL + "|" + E2_PREFIXO + "|" + E2_NUM + "|" + E2_PARCELA + "|" + E2_TIPO + "|" + E2_FORNECE + "|" + E2_LOJA)
Endif

// Se estiver buscando a mesma chave, n�o efetuar as pesquisas no banco novamente.
Static aSE2ChvCed := {"", nil}
If aSE2ChvCed[1] == cChaveSE2
	aRet := aSE2ChvCed[2]
Else
	aArea    := GetArea()
	aSA2Area := SA2->(GetArea())
	aRet := {"", "", "", "", .F.}

	// Localiza o complemento do t�tulo.
	If lFKFCed
		cIdDoc := FINBuscaFK7(cChaveSE2, "SE2")
		FKF->(dbSetOrder(1))  // FKF_FILIAL, FKF_IDDOC.
		If FKF->(msSeek(xFilial() + cIdDoc, .F.))
			SA2->(dbSetOrder(1))  // A2_FILIAL, A2_COD, A2_LOJA.
			If SA2->(msSeek(xFilial() + FKF->(FKF_CEDENT + FKF_LOJACE), .F.))
				aRet[1] := If(SA2->A2_TIPO == "F", "1", "2")
				aRet[5] := .T.
			Endif
		Endif
	Endif

	// Se n�o encontrou fornecedor na tabela de complementos (FKF), pesquisa no t�tulo (SE2).
	If empty(aRet[1])
		SA2->(dbSetOrder(1))  // A2_FILIAL, A2_COD, A2_LOJA.
		If SA2->(msSeek(xFilial() + SE2->(E2_FORNECE + E2_LOJA), .F.))
			aRet[1] := If(SA2->A2_TIPO == "F", "1", "2")
		Endif
	Endif

	// Se encontrou um fornecedor, preenche o restante dos campos.
	If !empty(aRet[1])
		aRet[2] := PadL(AllTrim(SA2->A2_CGC), 15, "0")
		aRet[3] := RTrim(SA2->A2_NOME)
		aRet[4] := aRet[1] + aRet[2] + aRet[3]
	Endif

	RestArea(aSA2Area)
	RestArea(aArea)
	FWFreeArray(aSA2Area)
	FWFreeArray(aArea)

	// Guarda o resultado em cache para n�o efetuar pesquisa novamente.
	aSE2ChvCed[1] := cChaveSE2
	aSE2ChvCed[2] := aRet
Endif

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FNLINCNAB()
Retorna o n�mero de linhas gravadas no arquivo envio do CNAB Modelo 2
para ser informado no trailer do arquivo.

@author  Leonardo Castro
@since   15/06/2018
@version Protheus 12.1.20
/*/
//-------------------------------------------------------------------
Function FNLINCNAB() As Numeric

	Local nRet As Numeric

	// Vari�veis PRIVATE dos fontes FINA150/FINA430
	nTotLinArq	:= IIF(Type("nTotLinArq") == "U", 0, nTotLinArq)
	nLotCnab2	:= IIF(Type("nLotCnab2")  == "U", 0, nLotCnab2)

	nRet := nTotLinArq       // Soma o n�mero de linhas de detalhes gravados no arquivo.
	nRet += (nLotCnab2 * 2)  // Multiplico o n�mero de lotes para saber a quantidade de Headers e Trailers de lote.
	nRet += 2                // Soma 2 para linhas de Header e Trailer de arquivo.

Return nRet

//----------------------------------------------------------------------
/*/{Protheus.doc} FNLOTECNAB()
Retorna o n�mero de lotes gravados no arquivo envio do CNAB Modelo 2
para ser informado no trailer do arquivo e no segundo campo de cada linha do lote.

@author  Leonardo Castro
@since   15/06/2018
@version Protheus 12.1.20
/*/
//----------------------------------------------------------------------
Function FNLOTECNAB() As Numeric

	Local nRet As Numeric

	// Vari�vel PRIVATE dos fontes FINA150/FINA420
	nRet := IIF(Type("nLotCnab2") == "U", 0, nLotCnab2) // Quantidade de lotes do CNAB2

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FNTITLOTE()
Retorna a n�mero de titulos gravados no lote do arquivo de envio
CNAB Modelo 2.

@author  Leonardo Castro
@since   15/06/2018
@version Protheus 12.1.20
/*/
//-------------------------------------------------------------------
Function FNTITLOTE() As Numeric

	Local nRet As Numeric

	// Vari�vel PRIVATE dos fontes FINA150/FINA420
	nRet := IIF(Type("nQtdTitLote") == "U", 0, nQtdTitLote) // N�mero de t�tulos do lote CNAB2

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FNTITARQ()
Retorna a quantidade de titulos gravados no arquivo de envio CNAB Modelo 2.

@author  Leonardo Castro
@since   15/06/2018
@version Protheus 12.1.20
/*/
//-------------------------------------------------------------------
Function FNTITARQ() As Numeric

	Local nRet As Numeric

	// Vari�vel PRIVATE dos fontes FINA150/FINA420
	nRet := IIF(Type("nQtdTotTit") == "U", 0, nQtdTotTit) // N�mero de t�tulos do arquivo do CNAB2

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FNLINLOTE()
Retorna a linha corrente do lote arquivo de envio CNAB Modelo 2.

@author  Leonardo Castro
@since   15/06/2018
@version Protheus 12.1.20
/*/
//-------------------------------------------------------------------
Function FNLINLOTE() As Numeric

	Local nRet As Numeric

	// Vari�vel PRIVATE dos fontes FINA150/FINA420
	nRet := IIF(Type("nQtdLinLote") == "U", 0, nQtdLinLote) // N�mero de linhas do lote CNAB2
	nRet += 1                                               // Somo 1 pois contador inicia do zero

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FNREGLOTE()
Retorna a quantidade de registros (linhas) gravadas no lote arquivo de envio
CNAB Modelo 2.

@author  Felipe Raposo
@since   19/07/2019
@version Protheus 12.1.23
/*/
//-------------------------------------------------------------------
Function FNREGLOTE() As Numeric

	Local nRet As Numeric

	nRet := FNLINLOTE()	// N�mero de linhas do lote CNAB2
	nRet += 1			// Somo 1 para linha de trailer de Lote

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FNRETPIX()
Fun��o chamada pelo CNAB para retornar informa��es PIX
@author  Robson Melo
@since   28/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function FNRETPIX(nOption) as Character

Local cDadosPix as Character
Local cQuery    as Character
Local cAliasQry as Character
Local aArea     as Array

Default nOption := 0

cDadosPix	:= ''
cQuery		:= ''
cAliasQry	:= GetNextAlias()
aArea		:= {}

aArea := GetArea()
cQuery := "SELECT F72_TPCHV, F72_CHVPIX, F72_ACTIVE  " 
cQuery += "FROM " + RetSQLName("F72") + " F72 "
cQuery += "WHERE F72.F72_COD = '"+SA2->A2_COD+"' AND "
cQuery += "      F72.F72_LOJA     = '"+SA2->A2_LOJA+"' AND "
cQuery += "      F72.F72_ACTIVE   = '1' AND "
cQuery += "      F72.D_E_L_E_T_   = ' '"
cQuery := ChangeQuery( cQuery ) 
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		
If !(cAliasQry)->(EOF())
    If nOption == 1
        cDadosPix:= Alltrim((cAliasQry)->F72_TPCHV)
    ElseIf nOption == 2
        cDadosPix:= Alltrim((cAliasQry)->F72_CHVPIX)
	ElseIf nOption == 3
		//04 = Chave de Endere�amento
        cDadosPix:= '04'
	Endif
Else
	If nOption == 3
		If SA2->A2_TIPCTA == "1" // Conta Corrente
			cDadosPix:= '01'
		ElseIf SA2->A2_TIPCTA == "2" // Poupanca
			cDadosPix:= '03'
		EndIf
	Endif
Endif

(cAliasQry)->(dbCloseArea())

Restarea(aArea)

Return cDadosPix

//-------------------------------------------------------------------
/*/{Protheus.doc} FNURLPIX()
Fun��o chamada pelo CNAB para retornar URL PIX
@author  Robson Melo
@since   28/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function FNURLPIX() as Character


Local cChaveSE2 as Character
Local aInfoPix  as Array
Local cIdDoc	as Character
Local cUrlPix   as Character
Local cQrCode	as Character
Local aArea     as Array

cIdDoc	  := ''
cUrlPix   := ''
cChaveSE2 := ''
aInfoPix  := {}
cQrCode	  := ''
aArea := GetArea()

cChaveSE2:= SE2->(E2_FILIAL + "|" + E2_PREFIXO + "|" + E2_NUM + "|" + E2_PARCELA + "|" + E2_TIPO + "|" + E2_FORNECE + "|" + E2_LOJA)
cIdDoc   := FINBuscaFK7(cChaveSE2, "SE2")

dbSelectArea('FKF')
FKF->( DbSetOrder(1) )
If FKF->( dbSeek(xFilial("FKF") + cIdDoc) )

	cQrCode  := FKF->FKF_PAGPIX
	aInfoPix := FinQRCode(cQrCode,.F.,.T.)

	If Len(aInfoPix) > 1
		cUrlPix:= Alltrim(StrTran( aInfoPix[2], "https://", "" ))
		cUrlPix:= Alltrim(StrTran(cUrlPix, "http://" , "" ))
	EndIf

EndIf

Restarea(aArea)

Return cUrlPix 

//-------------------------------------------------------------------
/*/{Protheus.doc} CNABDJUR()
Fun��o chamada pelo CNAB para retornar Vencimento Juros
@author  Robson Melo
@since   28/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function CNABDJUR() as Character
Local cRet as Character

cRet:= IIF((SE1->E1_VALJUR <> 0 .OR. SE1->E1_PORCJUR <> 0) ,GRAVADATA(SE1->E1_VENCREA,.F.,8), STRZERO(VAL("0"),8,0))

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNABDMULT()
Fun��o chamada pelo CNAB para retornar Vencimento Multa
@author  Robson Melo
@since   28/10/2020
@version P12
/*/
//-------------------------------------------------------------------

Function CNABDMULT() as Character
Local cRet as Character

cRet:=IIF(SE1->E1_MULTA == 0 ,STRZERO(VAL("0"),8,0),GRAVADATA(SE1->E1_VENCREA,.F.,8))

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNABDDESC()
Fun��o chamada pelo CNAB para retornar Vencimento Desconto
@author  Robson Melo
@since   28/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function CNABDDESC() as Character
Local cRet as Character

cRet:=IIF(SE1->E1_DESCFIN == 0 ,STRZERO(VAL("0"),8,0),GRAVADATA(SE1->E1_VENCREA,.F.,8))

Return cRet

//----------------------------------------
/*/{Protheus.doc} FQtdLnLote
Retorna a linha corrente do lote arquivo de 
envio cnab modelo 2 layout TCB

@author Sivaldo Oliveira
@since 24/02/2022
@version P12
/*/
//----------------------------------------
Function FQtdLnLote() As Numeric
	Local nLinhas As Numeric
	
	//Inicializa vari�veis
	nLinhas := IIF(Type("nQtdLnLote") != "U", nQtdLnLote, 0)
	
	nLinhas    += 1
	nQtdLnLote := nLinhas 
Return nLinhas