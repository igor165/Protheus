#INCLUDE "JURA256.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA256
Rastreamento de Fatura

@author Luciano Pereira dos Santos
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA256()
Local oBrw256 := Nil

oBrw256 := FWMBrowse():New()
oBrw256:SetDescription( STR0004 ) //"Rastreamento de recebimentos por casos da fatura"
oBrw256:SetAlias( 'SE1' )
oBrw256:SetMenuDef('JURA256')
oBrw256:SetFilterDefault("!Empty(E1_JURFAT)")
JurSetLeg( oBrw256, 'SE1' )
JurSetBSize( oBrw256 )
oBrw256:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Luciano Pereira dos Santos
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, 'PesqBrw'         , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, 'VIEWDEF.JURA256' , 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, 'VIEWDEF.JURA256' , 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Rastreamento de Fatura

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructSE1 := FWFormStruct( 1, "SE1",{|cCampo| J256SE1Cpo(cCampo)})
Local oStructOHI := FWFormStruct( 1, "OHI" )
Local oEvent     := JA256Event():New()

oStructSE1 := J256whenF(oStructSE1)

oModel:= MPFormModel():New( "JURA256", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "SE1MASTER", NIL/*cOwner*/, oStructSE1, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid(  "OHIDETAIL", "SE1MASTER" /*cOwner*/, oStructOHI, /*Pre-Validacao*/, /*Pos-Validacao*/, /*bPre*/, /*bPost*/ )

oModel:GetModel( "SE1MASTER" ):SetDescription( STR0005 ) // "Titulo"
oModel:GetModel( "OHIDETAIL" ):SetDescription( STR0006 ) // "Recebimentos por casos"

oModel:SetRelation("OHIDETAIL", {{"OHI_FILIAL", "xFilial('OHI')" }, {"OHI_CHVTIT", "SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)"}}, OHI->(IndexKey(2)))

oModel:SetOptional( "OHIDETAIL", .T. )
oModel:GetModel("OHIDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("OHIDETAIL"):SetNoUpdateLine(.T.)
oModel:GetModel("OHIDETAIL"):SetNoDeleteLine(.T.)

oModel:InstallEvent("JA256Event", /*cOwner*/, oEvent)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Itens de desdobramento

@author Luciano Pereira dos Santos
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA256" )
Local oStructSE1 := FWFormStruct( 2, "SE1", {|cCampo| J256SE1Cpo(cCampo)})
Local oStructOHI := FWFormStruct( 2, "OHI")
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

oStructOHI:RemoveField("OHI_FILIAL")
oStructOHI:RemoveField("OHI_CESCR")
oStructOHI:RemoveField("OHI_CFATUR")
If (cLojaAuto == "1") // Loja Automática
	oStructOHI:RemoveField("OHI_CLOJA")
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("JURA256_SE1", oStructSE1, "SE1MASTER")
oView:AddGrid("JURA256_OHI" , oStructOHI, "OHIDETAIL")

oView:CreateHorizontalBox("FORMFIELD", 30)
oView:CreateHorizontalBox("FORMGRID",  70)

oView:SetOwnerView("JURA256_SE1", "FORMFIELD")
oView:SetOwnerView("JURA256_OHI", "FORMGRID")

oView:AddIncrementField("JURA256_OHI","OHI_ITEM")

oView:EnableTitleView("JURA256_OHI")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J256whenF(oStruct)
Rotina para desabilitar os campos das estrutura

@Param oStruct    Estrutura da tabela

@Return oStruct   Estrutura da tabela alterada

@author Luciano Pereira dos Santos
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J256whenF(oStruct)
Local aStruct := oStruct:GetFields()
Local nI      := 1

For nI := 1 to Len(aStruct)
	oStruct:SetProperty(aStruct[nI][MODEL_FIELD_IDFIELD], MODEL_FIELD_WHEN, {||.F.})
Next nI

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J256SE1Cpo(cCampo)
Função para selecionar os campos do Model da tabela NXA

@param cCampo campo da estrutura.

@Return .T. para campos que pode ser carregado no modelo

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J256SE1Cpo(cCampo)
Local cCampos  := 'E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_EMISSAO|E1_VENCTO|E1_INSS|E1_PIS|E1_COFINS|E1_CSLL|E1_VALOR'
Local lRet     := .F.
Local cNomeCpo := AllTrim(cCampo)

If cNomeCpo $ cCampos
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA256Event
Classe interna implementando o FWModelEvent, para execução de funções
nos eventos do modelo.

@author Luciano Pereira dos Santos
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA256Event FROM FWModelEvent
	Method New()
	Method ModelPosVld()

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Metodo de inicialização da Classe FWModelEvent.

@author Luciano Pereira dos Santos
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class JA256Event
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model.

@author Luciano Pereira dos Santos
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA256Event
Local lRet       := .T.
Local nOperation := oModel:GetOperation()

If nOperation != MODEL_OPERATION_VIEW
	lRet := JurMsgErro(STR0007,, STR0008) //#"Operação não permitida."  ##"Essa rotina só permite a operação de visualização."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J256GrvRas
Grava o rastreamento da baixa por casos da fatura.

@param  nSE1Recno, Recno do registro SE1
@param  nSE5Recno, Recno do registro SE5
@param  nRegCmp  , Recno do registro SE1 compensado (RA)
@param  lSincLG  , Indica se grava na fila de sincronização

@return lRast    , Sucesso ou falha na gravação do rastreamento

@author  Jonatas Martins
@since   08/02/2018
/*/
//-------------------------------------------------------------------
Function J256GrvRas(nSE1Recno, nSE5Recno, nRegCmp, lSincLG)
	Local aAreas       := {SE1->(GetArea()), SE5->(GetArea()), OHI->(GetArea()), GetArea()}
	Local aDados       := {}
	Local aDadosFat    := {}
	Local aDadosNXA    := {}
	Local cSincOper    := ""
	Local cJurFat      := ""
	Local cFilFat      := ""
	Local cEscrit      := ""
	Local cFatura      := ""
	Local lContinue    := .T.
	Local lRast        := .T.
	Local lZeraOHI     := .F.
	Local lIsLiq       := .F. // Usada para indicar que não deve considerar os abatimentos no valor recebido (liquidação)
	Local lExistOHT    := AliasIndic("OHT")
	Local nFat         := 0
	Local nTotVlFatH   := 0
	Local nTotVlFatD   := 0
	Local nTotVlRemb   := 0
	Local nTotVlTrib   := 0
	Local nTotVlTxAd   := 0
	Local nTotVlGros   := 0
	Local nTotVlAcre   := 0
	Local nTotVlAbat   := 0
	Local nTaxaMoe     := 0
	Local nValAcess    := 0
	Local nVlDesc      := 0
	Local nVlAcres     := 0
	Local nAbatimentos := 0
	Local nValBxLiq    := 0
	Local nValBxBrt    := 0
	Local nFVlAcres    := 0
	Local nFVlDesc     := 0
	Local nFVlVarCam   := 0
	Local nFVlAcreLq   := 0 // Valor de acréscimo na liquidação
	Local nFVlDescAc   := 0
	Local nFValBxLiq   := 0
	Local nFValBxBrt   := 0
	Local nTamFil      := 0
	Local nTamEsc      := 0
	Local nTamFat      := 0
	Local nTotAcresLq  := 0
	Local nVlAcreLqBx  := 0
	Local nVlDescAcre  := 0
	Local nSaldoOHH    := 0
	Local nAbatFat     := 0
	Local lCpoGrsHon   := NXA->(ColumnPos("NXA_VGROSH")) > 0 .And. NXC->(ColumnPos("NXC_VGROSH")) > 0 // @12.1.2310

	Default nSE1Recno  := 0
	Default nSE5Recno  := 0
	Default nRegCmp    := 0
	Default lSincLG	   := .T.

	If AliasIndic("OHI") // Proteção devido ao congelamento do release
		Iif( SE1->(Recno()) == nSE1Recno, Nil, SE1->( DbGoTo( nSE1Recno ) ))

		If lExistOHT
			cFilterOHT := " SELECT OHT_FILFAT, OHT_FTESCR, OHT_CFATUR, OHT_VLFATH, OHT_VLFATD, OHT_VLREMB, OHT_VLTRIB, OHT_VLTXAD, OHT_VLGROS, OHT_ACRESC, OHT_ABATIM FROM " + RetSqlName("OHT") + " OHT"
			cFilterOHT +=  " WHERE OHT.OHT_FILIAL = '" + xFilial("OHT")  + "'"
			cFilterOHT +=    " AND OHT.OHT_FILTIT = '" + SE1->E1_FILIAL  + "'"
			cFilterOHT +=    " AND OHT.OHT_PREFIX = '" + SE1->E1_PREFIXO + "'"
			cFilterOHT +=    " AND OHT.OHT_TITNUM = '" + SE1->E1_NUM     + "'"
			cFilterOHT +=    " AND OHT.OHT_TITPAR = '" + SE1->E1_PARCELA + "'"
			cFilterOHT +=    " AND OHT.OHT_TITTPO = '" + SE1->E1_TIPO    + "'"
			cFilterOHT +=    " AND OHT.D_E_L_E_T_ = ' '"

			aDadosFat := JurSQL(cFilterOHT, {"*"})

			aEval(aDadosFat, {|aX| nTotVlFatH += aX[4], nTotVlFatD += aX[5], nTotVlRemb += aX[6],;
			                       nTotVlTrib += aX[7], nTotVlTxAd += aX[8], nTotVlGros += aX[9],;
			                       nTotVlAcre += aX[10], nTotVlAbat += aX[11]})
		Else
			nTamFil   := TamSX3("NXA_FILIAL")[1]
			nTamEsc   := TamSX3("NXA_CESCR")[1]
			nTamFat   := TamSX3("NXA_COD")[1]
			cJurFat   := Strtran(SE1->E1_JURFAT,"-","")
			cFilFat   := Substr(cJurFat, 1, nTamFil)
			cEscrit   := Substr(cJurFat, nTamFil + 1, nTamEsc)
			cFatura   := Substr(cJurFat, nTamFil + nTamEsc + 1, nTamFat)
			nTotVlAbat := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO)

			If lCpoGrsHon // @12.1.2310
				aDadosNXA := JurGetDados("NXA", 1, cFilFat + cEscrit + cFatura, {"NXA_FILIAL", "NXA_CESCR", "NXA_COD", "NXA_VLFATH", "NXA_VLFATD","NXA_VLREMB","NXA_VLTRIB", "NXA_VLTXAD", "NXA_VLGROS", "NXA_VGROSH"})
			Else
				aDadosNXA := JurGetDados("NXA", 1, cFilFat + cEscrit + cFatura, {"NXA_FILIAL", "NXA_CESCR", "NXA_COD", "NXA_VLFATH", "NXA_VLFATD","NXA_VLREMB","NXA_VLTRIB", "NXA_VLTXAD", "NXA_VLGROS"})
			EndIf
			
			If Len(aDadosNXA) > 0
				nTotVlFatH := aDadosNXA[4] + IIF(lCpoGrsHon, aDadosNXA[10], 0) // @12.1.2310 - Soma valor de Gross Up de Honorários
				nTotVlFatD := aDadosNXA[5]
				nTotVlRemb := aDadosNXA[6]
				nTotVlTrib := aDadosNXA[7]
				nTotVlTxAd := aDadosNXA[8]
				nTotVlGros := aDadosNXA[9]
				AAdd(aDadosNXA, 0) // Acréscimos financeiros
				AAdd(aDadosNXA, nTotVlAbat) // Abatimentos
				AAdd(aDadosFat, aDadosNXA) // Somente para manter a mesma estrutura de quando utilizar a OHT
			EndIf
		EndIf

		If SE1->( ! Eof() ) .And. Len(aDadosFat) > 0
			BEGIN TRANSACTION
				SE5->(DbGoTo(nSE5Recno))
				If SE5->( ! Eof() ) .And. SE5->E5_TIPO <> PadR("RA", TamSX3("E5_TIPO")[1]) ;  // Ignora baixas de Adiantamento
					.And. !(AllTrim(SE5->E5_MOTBX) $ "CNF") // Ignora baixas de cancelamento de fatura e liquidação
					
					// Se o registro do movimento posicionado for de desconto / juros / multas, então localiza o movimento da baixa
					If AllTrim(SE5->E5_TIPODOC) $ "DC|JR|MT"
						SE5->( DbSetOrder(21) )
						lContinue := SE5->( DbSeek( SE5->E5_FILIAL + SE5->E5_IDORIG + PadR("BA" , TamSX3("E5_TIPODOC")[1]) ) )
					EndIf

					If lContinue
						nSaldoOHH    := J256SldOHH() // Saldo do título na OHH
						lZeraOHI     := nSaldoOHH == 0 // Indica se a baixa será feita somente com valores de acréscimos gerados na liquidação (multas, juros)
						lIsLiq       := AllTrim(SE5->E5_MOTBX) == "LIQ" // Indica se a baixa está sendo feita pela liquidação
						nTaxaMoe     := IIf(SE5->E5_TXMOEDA == 0, 1, 1 / SE5->E5_TXMOEDA) // Taxa de conversão para moeda da baixa
						nValAcess    := J256ValAce( SE5->E5_IDORIG )
						nVlDesc      := ( SE5->E5_VLDESCO * nTaxaMoe ) + IIf( nValAcess < 0, nValAcess * (-1), 0 ) // - Descontos - Decrescimo - Valores Acessórios (Subtrair)
						nVlAcres     := ( ( SE5->E5_VLJUROS + SE5->E5_VLMULTA ) * nTaxaMoe ) + IIf( nValAcess > 0, nValAcess, 0 ) // + Acréscimo + Tx. Permanência + Multa + Valores Acessórios (Somar)
						nAbatimentos := IIf(SE1->E1_SALDO > 0, 0, SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO)) // Valor de impostos e abatimentos dos títulos - Usado somente se o saldo estiver zerado
						nValBxLiq    := IIf(SE5->E5_TIPODOC == "CP" .Or. nTaxaMoe == 1, SE5->E5_VALOR, SE5->E5_VLMOED2) // Valor líquido da baixa
						nValBxBrt    := nValBxLiq + nAbatimentos // Valor bruto da baixa

						If !lIsLiq .And. !Empty(SE1->E1_NUMLIQ) // Baixa de título gerado pela liquidação
							nTotAcresLq := SE1->E1_VALOR - nTotVlFatH - nTotVlFatD // Total de acréscimo (gerado pela liquidação) do título = Valor do título - Valor total das faturas que foram liquidadas
							nVlAcreLqBx := IIf(nValBxBrt - nVlAcres + nVlDesc > nSaldoOHH, nValBxBrt - nSaldoOHH - nVlAcres + nVlDesc, 0) // Acréscimo (gerado pela liquidação) a ser considerado na baixa atual
						
							If nVlAcreLqBx > 0 .And. nVlDesc > nSaldoOHH
								nVlDescAcre := nVlDesc - nSaldoOHH // Desconto que será aplicado sobre o acréscimo gerado pela liquidação
								nVlDesc     -= nVlDescAcre // Retira o desconto sobre acréscimo do desconto total
							EndIf
						EndIf
						
						// Na liquidação dependendo da natureza utilizada a baixa não considera o valor dos abatimentos.
						// Então nesse caso não podemos considerar os abatimentos na recomposição feita abaixo.
						If lIsLiq .And. nValBxLiq == (nSaldoOHH + nVlAcres + nTotVlAcre - nVlDesc - nVlDescAcre) // Se .T. indica que os impostos (abatimentos) não foram considerados no valor da baixa feita pela liquidação
							nVlAcres  += nTotVlAcre // Necessário em caso de reliquidação - Adiciona o acréscimo feito na liquidação anterior
							nValBxBrt := nValBxLiq - nVlAcres + nVlDesc + nVlDescAcre // Recomposição do valor da baixa sem os valores adicionais e sem os abatimentos
						Else
							nValBxBrt := nValBxBrt - nVlAcres + nVlDesc + nVlDescAcre // Recomposição do valor da baixa sem os valores adicionais
							If nValBxBrt >= nVlAcreLqBx
								// nValBxBrt deve conter o valor das faturas a ser considerado na baixa.
								// Por isso é necessário remover também o acréscimo de liquidação para não distorcer a distribuição dos
								// valores entre as faturas e seus casos
								nValBxBrt -= nVlAcreLqBx
							EndIf
						EndIf

						nValBxLiq := nValBxLiq - nVlAcreLqBx + nVlDescAcre // Retira o acréscimo do valor da baixa para cálculo de proporções, depois adiciona o valor proporcionalizado, conforme o acréscimo de cada fatura na liquidação.

						For nFat := 1 To Len(aDadosFat)
							cFilFat := aDadosFat[nFat][1]
							cEscrit := aDadosFat[nFat][2]
							cFatura := aDadosFat[nFat][3]

							If nAbatimentos > 0
								// Pega os abatimentos da fatura, para distribuir no valor recebido (OHI_VLCREC)
								// Isso é necessário pois em casos de baixas de títulos gerados pela liquidação, 
								// o nAbatimentos terá o imposto de todas as faturas envolvidas na liquidação.
								If Len(aDadosFat) == 1
									nAbatFat := nAbatimentos
								Else
									nAbatFat := aDadosFat[nFat][11]
								EndIf
							EndIf

							// Busca casos da fatura
							aDados := LoadData(cFilFat, cEscrit, cFatura, lCpoGrsHon) // @12.1.2310

							// Gravação dos dados na OHI
							If Len(aDados) > 0
								// Cálculo da proporção entre o valor de uma fatura sobre o total de todas as faturas
								nFVlAcreLq := RatPontoFl(aDadosFat[nFat][10]                    , nTotVlAcre             , nVlAcreLqBx    , 2) // Valor de acréscimo gerado pela liquidação a ser considerado na baixa (esse acréscimo está embutido no valor do título)
								nFVlDescAc := RatPontoFl(aDadosFat[nFat][10]                    , nTotVlAcre             , nVlDescAcre    , 2) // Valor de desconto sobre o acréscimo gerado pela liquidação a ser considerado na baixa (esse acréscimo está embutido no valor do título)
								nFValBxLiq := RatPontoFl(aDadosFat[nFat][4] + aDadosFat[nFat][5], nTotVlFatH + nTotVlFatD, nValBxLiq      , 2) + nFVlAcreLq - nFVlDescAc // Valor da Baixa "Líquido" (Recebido) = Valores da Fatura + Acréscimo calculado acima
								nFValBxBrt := RatPontoFl(aDadosFat[nFat][4] + aDadosFat[nFat][5], nTotVlFatH + nTotVlFatD, nValBxBrt      , 2) // Valor da Baixa "Bruto" (desconsiderando acréscimos, descontos e abatimentos)
								nFVlAcres  := RatPontoFl(aDadosFat[nFat][4] + aDadosFat[nFat][5], nTotVlFatH + nTotVlFatD, nVlAcres       , 2) // Valor de Acréscimos na baixa
								nFVlDesc   := RatPontoFl(aDadosFat[nFat][4] + aDadosFat[nFat][5], nTotVlFatH + nTotVlFatD, nVlDesc        , 2) + nFVlDescAc // Valor de Descontos na baixa
								nFVlVarCam := RatPontoFl(aDadosFat[nFat][4] + aDadosFat[nFat][5], nTotVlFatH + nTotVlFatD, SE5->E5_VLCORRE, 2) // Valor da Variação Cambial na baixa

								lRast := GrvRastOHI(aDados, nRegCmp, nFValBxBrt, nFVlAcres, nFVlDesc, nFVlVarCam, nFValBxLiq, nFVlAcreLq, nTotAcresLq, lZeraOHI, nAbatFat)
								
								If !lRast
									DisarmTransaction()
									Exit
								EndIf
								// Atualiza fila de sincronização
								If lSincLG 
									cSincOper := GetSincOper(aDados[1][1], aDados[1][2], .T.)
									lRast := lRast .And. J170GRAVA("JURA256", xFilial("NXA") + aDados[1][1] + aDados[1][2], cSincOper)
								EndIf
							EndIf
						Next
					EndIf
				EndIf
			END TRANSACTION
		EndIf
	EndIf

	Aeval( aAreas , {|aArea| RestArea( aArea ) } )
Return ( lRast )

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadData
Busca casos da fatura vínculado ao título.

@param  cFilFat   , Filial da Fatura
@param  cEscrit   , Escritório da Fatura
@param  cFatura   , Código da Fatura
@param  lCpoGrsHon, Define a existência dos campos de Gross up de Honorários

@return aDadosQry, Dados dos casos da fatura

@author  Jonatas Martins
@since   08/02/2018
/*/
//-------------------------------------------------------------------
Static Function LoadData(cFilFat, cEscrit, cFatura, lCpoGrsHon)
	Local cQryNXC    := ""
	Local cQryOHT    := ""
	Local aDadosNXC  := {}
	Local aDadosOHT  := {}
	Local nCaso      := 0
	Local nTotHon    := 0 // Valor total de honorários na fatura
	Local nTotDesp   := 0 // Valor total de despesas na fatura
	Local nFatDesRem := 0 // Valor de Despesa Reembolsável da Fatura
	Local nFatDesTri := 0 // Valor de Despesa Tributável da Fatura
	Local nFatTxAdm  := 0 // Valor de Taxa Adm. da Fatura
	Local nFatGross  := 0 // Valor de Gross Up da Fatura
	Local lBxTitLiq  := FWAliasInDic("OHT") .And. !Empty(SE1->E1_NUMLIQ) .And. !FWIsInCallStack("FINA460") // Baixa Manual de título gerado através da liquidação
	Local lReliq     := AllTrim(SE5->E5_MOTBX) == "LIQ" .And. !Empty(SE1->E1_NUMLIQ) // Reliquidação
	
	cQryNXC := " SELECT NXC_CESCR , NXC_CFATUR, NXC_CCLIEN, NXC_CLOJA , NXC_CCONTR, "
	cQryNXC +=        " NXC_CCASO , NXC_VLHFAT + " + IIF(lCpoGrsHon, "NXC_VGROSH", "0") + " NXC_VLHFAT, " // @12.1.2310
	cQryNXC +=        " NXC_VLDFAT, 0 VALDESCH, 0 VALACRESH, 0 VALDESCD, 0 VALACRESD, "
	cQryNXC +=        " NXC_VLREMB, NXC_VLTRIB, NXC_VLGROS, NXC_VLTXAD, NXC_DRATF, NXC_ARATF, NXC_VLHFAT + " + IIF(lCpoGrsHon, "NXC_VGROSH", "0") + " + NXC_VLDFAT TOTALCAS "
	cQryNXC +=   " FROM " + RetSqlName("NXC") + " "
	cQryNXC +=  " WHERE NXC_FILIAL = '" + cFilFat + "'"
	cQryNXC +=    " AND NXC_CESCR  = '" + cEscrit + "'"
	cQryNXC +=    " AND NXC_CFATUR = '" + cFatura + "'"
	cQryNXC +=    " AND D_E_L_E_T_ = ' ' "

	aDadosNXC := JurSQL(cQryNXC, {"NXC_CESCR" , "NXC_CFATUR", "NXC_CCLIEN", "NXC_CLOJA" ,;
	                              "NXC_CCONTR", "NXC_CCASO" , "NXC_VLHFAT", "NXC_VLDFAT",;
	                              "VALDESCH"  , "VALACRESH" , "VALDESCD"  , "VALACRESD" ,;
	                              "NXC_VLREMB", "NXC_VLTRIB", "NXC_VLTXAD", "NXC_VLGROS",;
	                              "NXC_DRATF" , "NXC_ARATF" , "TOTALCAS"})

	If lBxTitLiq .Or. lReliq // Baixa Manual de título gerado através da liquidação
		aEval(aDadosNXC, {|x| nTotHon += x[7], nTotDesp += x[8], nFatDesRem += x[13], nFatDesTri += x[14], nFatTxAdm += x[15], nFatGross += x[16] })

		cQryOHT += " SELECT OHT_VLFATH, OHT_VLFATD, OHT_VLREMB, OHT_VLTRIB, OHT_VLTXAD, OHT_VLGROS"
		cQryOHT +=   " FROM " + RetSqlName("OHT") 
		cQryOHT +=  " WHERE OHT_FILIAL = '" + xFilial("OHT") + "'"
		cQryOHT +=    " AND OHT_FILFAT = '" + cFilFat + "'"
		cQryOHT +=    " AND OHT_FTESCR = '" + cEscrit + "'"
		cQryOHT +=    " AND OHT_CFATUR = '" + cFatura + "'"
		cQryOHT +=    " AND OHT_FILTIT = '" + SE1->E1_FILIAL + "'"
		cQryOHT +=    " AND OHT_PREFIX = '" + SE1->E1_PREFIXO + "'"
		cQryOHT +=    " AND OHT_TITNUM = '" + SE1->E1_NUM + "'"
		cQryOHT +=    " AND OHT_TITPAR = '" + SE1->E1_PARCELA + "'"
		cQryOHT +=    " AND OHT_TITTPO = '" + SE1->E1_TIPO + "'"
		cQryOHT +=    " AND OHT_NUMLIQ = '" + SE1->E1_NUMLIQ + "'"
		cQryOHT +=    " AND D_E_L_E_T_ = ' ' "

		aDadosOHT :=  JurSQL(cQryOHT, {"OHT_VLFATH", "OHT_VLFATD", "OHT_VLREMB", "OHT_VLTRIB", "OHT_VLTXAD", "OHT_VLGROS"})

		For nCaso := 1 To Len(aDadosNXC)
			aDadosNXC[nCaso][7]  := RatPontoFl(aDadosNXC[nCaso][7] , nTotHon   , aDadosOHT[1][1], 2)
			aDadosNXC[nCaso][8]  := RatPontoFl(aDadosNXC[nCaso][8] , nTotDesp  , aDadosOHT[1][2], 2)
			aDadosNXC[nCaso][13] := RatPontoFl(aDadosNXC[nCaso][13], nFatDesRem, aDadosOHT[1][3], 2)
			aDadosNXC[nCaso][14] := RatPontoFl(aDadosNXC[nCaso][14], nFatDesTri, aDadosOHT[1][4], 2)
			aDadosNXC[nCaso][15] := RatPontoFl(aDadosNXC[nCaso][15], nFatTxAdm , aDadosOHT[1][5], 2)
			aDadosNXC[nCaso][16] := RatPontoFl(aDadosNXC[nCaso][16], nFatGross , aDadosOHT[1][6], 2)
			aDadosNXC[nCaso][17] := 0 // Zera desconto da fatura
			aDadosNXC[nCaso][18] := 0 // Zera acrescimo da fatura
			aDadosNXC[nCaso][19] := aDadosNXC[nCaso][7] + aDadosNXC[nCaso][8]
		Next nCaso
	EndIf

Return (aDadosNXC)

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRastOHI
Grava o rastreamento da baixa por casos da fatura.

@param  aDados    , array   , Dados dos casos da fatura
@param  nRegCmp   , numérico, Recno do registro SE1 compensado (RA)
@param  nValCRec  , numérico, Valor da Baixa (desconsiderando acréscimos, descontos e abatimentos)
@param  nVlAcres  , numérico, Valor de Acréscimos
@param  nVlDesc   , numérico, Valor da Descontos
@param  nVlVarCam , numérico, Valor da Variação Cambial
@param  nValSE5   , numérico, Valor da Baixa na SE5
@param  nVlAcreLq , numérico, Valor de Acréscimos gerados na liquidação (FO1) proporcional por fatura
@param  nTotAcreLq, numérico, Valor Total de Acréscimos gerados na liquidação (FO1)
@param  lZeraOHI  , lógico  , Indica se a baixa será feita somente 
                              com valores de acréscimos gerados na liquidação (multas, juros)

@return lInsertOHI , logico  , Sucesso ou falha na inclusão do rastreamento

@author  Jonatas Martins
@since   08/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Static Function GrvRastOHI(aDados, nRegCmp, nValCRec, nVlAcres, nVlDesc, nVlVarCam, nValSE5, nVlAcreLq, nTotAcreLq, lZeraOHI, nAbatimentos)
	Local aDadosCas    := {}
	Local nVal         := 0
	Local cItem        := ""
	Local cChvTit      := ""
	Local cEscrit      := aDados[1][1]
	Local cFatura      := aDados[1][2]
	Local lInsertOHI   := .T.
	Local cMoedaFat    := JurGetDados('NXA', 1, xFilial('NXA') + cEscrit + cFatura, 'NXA_CMOEDA')
	Local lDespTrib    := OHI->(ColumnPos("OHI_VLREMB")) > 0 // Proteção
	Local lCpoNatRec   := OHI->(ColumnPos("OHI_NATREC")) > 0 // Proteção
	Local lCpoMoeda    := OHI->(ColumnPos("OHI_CMOEDA")) > 0 // Proteção
	Local lCpoTpBx     := OHI->(ColumnPos("OHI_MOTBX")) > 0  // Proteção
	Local lIsMovBco    := JIsMovBco(SE5->E5_MOTBX) .Or. AllTrim(SE5->E5_MOTBX) == "CMP" // Indica se a Natureza da baixa movimenta banco
	Local nValor       := 0
	Local nTotCaso     := 0
	Local nAbatCaso    := 0
	Local nTamVlcRec   := TamSX3("OHI_VLCREC")[2]
	Local nSaldoAbat   := nAbatimentos
	
	Default nRegCmp    := 0
	
	cItem   := GetItem( cEscrit , cFatura )
	cChvTit := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

	//-----------------------------
	// Calcula valores por casos
	//-----------------------------
	aDadosCas := CalRatCas(aDados, cEscrit, cFatura, nValCRec, nVlDesc, nVlAcres + nVlAcreLq, SE5->E5_DATA, nTotAcreLq)

	aEval(aDadosCas, {|x| nTotCaso += x[7] + x[8] }) // Proporção entre os casos para usar na distribuição dos impostos

	For nVal := 1 To Len( aDadosCas )

		If nAbatimentos > 0 // Distribuição dos abatimentos/impostos
			If nVal == Len(aDadosCas) // Último caso
				nAbatCaso := nSaldoAbat
			Else
				If lZeraOHI // Caso a última baixa tenha somente valores de acréscimos feitos na liquidação
					nAbatCaso := RatPontoFl(aDadosCas[nVal][10], nVlAcreLq, nAbatimentos, nTamVlcRec) // Valor de impostos proporcional ao valor do acréscimo do caso
				Else
					nAbatCaso := RatPontoFl(aDadosCas[nVal][7] + aDadosCas[nVal][8], nTotCaso, nAbatimentos, nTamVlcRec) // Valor de impostos proporcional ao valor do caso
				EndIf
				nSaldoAbat -= nAbatCaso
			EndIf
		EndIf

		If RecLock("OHI", .T.)
			cItem := Soma1( cItem )
			OHI->OHI_FILIAL := xFilial("OHI")
			OHI->OHI_ITEM   := cItem
			OHI->OHI_CESCR  := aDadosCas[nVal][1]  // Escritório
			OHI->OHI_CFATUR := aDadosCas[nVal][2]  // Fatura
			OHI->OHI_CCLIEN := aDadosCas[nVal][3]  // Cliente
			OHI->OHI_CLOJA  := aDadosCas[nVal][4]  // Loja
			OHI->OHI_CCONTR := aDadosCas[nVal][5]  // Contrato
			OHI->OHI_CCASO  := aDadosCas[nVal][6]  // Caso
			OHI->OHI_VLHCAS := IIF(lZeraOHI, 0, aDadosCas[nVal][7]) // Valor Honorários do Caso
			OHI->OHI_VLDCAS := IIF(lZeraOHI, 0, aDadosCas[nVal][8]) // Valor Despesas do Caso
			OHI->OHI_VLDESH := IIF(lIsMovBco, aDadosCas[nVal][9], aDadosCas[nVal][7])  // Valor de desconto no honorário do caso
			OHI->OHI_VLACRH := aDadosCas[nVal][10] // Valor de acréscimo no honorário do caso
			OHI->OHI_VLDESD := IIF(lIsMovBco, aDadosCas[nVal][11], aDadosCas[nVal][8]) // Valor de desconto na despesa do caso
			OHI->OHI_VLACRD := aDadosCas[nVal][12] // Valor de acréscimo na despesa do caso
			If lDespTrib
				OHI->OHI_VLREMB := IIF(lZeraOHI, 0, aDadosCas[nVal][13]) // Valor Despesas Reembolsável do Caso
				OHI->OHI_VLTRIB := IIF(lZeraOHI, 0, aDadosCas[nVal][14]) // Valor Despesas Tributável do Caso
				OHI->OHI_VLTXAD := IIF(lZeraOHI, 0, aDadosCas[nVal][15]) // Valor de Taxa Administrativa
				OHI->OHI_VLGROS := IIF(lZeraOHI, 0, aDadosCas[nVal][16]) // Valor de Gross Up
				OHI->OHI_CMOERE := SE5->E5_MOEDA       // Moeda do Recebimento
				OHI->OHI_VARCAM := nVlVarCam           // Variação Cambial / Correção Monetária
			EndIf
			OHI->OHI_DTAREC := SE5->E5_DATA
			If lIsMovBco
				nValor := OHI->(OHI_VLHCAS - OHI_VLDESH + OHI_VLACRH + OHI_VLDCAS - OHI_VLDESD + OHI_VLACRD)
				nValor := IIf(nAbatCaso > nValor, 0, nValor - nAbatCaso)
			EndIf
			OHI->OHI_VLCREC := nValor
			OHI->OHI_CHVTIT := cChvTit
			OHI->OHI_SE5SEQ := SE5->E5_SEQ
			OHI->OHI_IDORIG := SE5->E5_IDORIG
			If lCpoNatRec
				OHI->OHI_NATREC := J256NatRec(nRegCmp)
				OHI->OHI_COTAC  := IIF(SE5->E5_TXMOEDA == 0, 1, SE5->E5_TXMOEDA)
			EndIf
			If lCpoMoeda
				OHI->OHI_CMOEDA := cMoedaFat
			EndIf
			If lCpoTpBx
				OHI->OHI_MOTBX := SE5->E5_MOTBX
			EndIf
			OHI->( MsUnLock() )
		Else
			lInsertOHI := .F.
			Exit
		EndIf
	Next nVal

Return ( lInsertOHI )

//-------------------------------------------------------------------
/*/{Protheus.doc} J256NatRec
Obtem a natureza vinculada ao banco da baixa. Quando for compensação 
busca a natureza vinculada ao banco do título de RA.

@param   nRegCmp , numerico, Recno do registro SE1 compensado (RA)

@return  cNatRec, caractere, Natureza de recebimento

@author  Jonatas Martins
@since   02/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function J256NatRec(nRegCmp)
	Local aAreaSE1  := {}
	Local cNatRec   := ""
	
	If nRegCmp == 0 .Or. Empty(SE5->E5_DOCUMEN)
		cNatRec := JurBusNat("", SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA)
	Else 
		//==============
		// Compensação
		//==============
		aAreaSE1 := SE1->(GetArea())
		SE1->(DbGoTo(nRegCmp))
		If SE1->(! Eof())
			cNatRec := JurBusNat("", SE1->E1_PORTADO, SE1->E1_AGEDEP, SE1->E1_CONTA)
		EndIf
		RestArea(aAreaSE1)
	EndIf

Return (cNatRec)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetItem
Rotina de cálculo de rateio do valor da baixa entre os casos da fatura

@param  cEscrit, caracter, Código do Escritório da Fatura
@param  cFatura, caracter, Código da Fatura

@return cItem  , caracter, Último item da tabela de rastreamento por fatura

@author  Luciano Santos
@since   08/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Static Function GetItem( cEscrit , cFatura )
	Local cQryRes  := ""
	Local cQryItem := ""
	Local cItem    := ""

	cQryItem := "SELECT MAX(OHI_ITEM) OHI_ITEM "+ CRLF
	cQryItem += "FROM " + RetSqlName("OHI") + " " + CRLF
	cQryItem += "WHERE OHI_FILIAL = '" + xFilial("OHI") + "' " + CRLF
	cQryItem +=   "AND OHI_CESCR = '" + cEscrit + "' " + CRLF
	cQryItem +=   "AND OHI_CFATUR = '" + cFatura + "' " + CRLF
	cQryItem +=   "AND D_E_L_E_T_ = ' ' "

	cQryRes := GetNextAlias()
	cQryItem  := ChangeQuery( cQryItem )

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryItem),cQryRes,.T.,.T.)

	If (cQryRes)->( ! Eof() ) .And. ! Empty( (cQryRes)->OHI_ITEM )
		cItem := (cQryRes)->OHI_ITEM
	Else
		cItem := StrZero( 0 , TamSX3("OHI_ITEM")[1] )
	EndIf

	(cQryRes)->( DbCloseArea() )

Return ( cItem )

//-------------------------------------------------------------------
/*/{Protheus.doc} CalRatCas
Rotina de cálculo de rateio do valor da baixa entre os casos da fatura

@param  aDados    , Dados dos casos da fatura
@param  cChvTit   , Chave para localizar os recebimentos por casos
@param  nValCRec  , Valor do recebimento
@param  nDescRec  , Valor do descontos
@param  nAcreRec  , Valor do acrescimo
@param  dDtMov    , Data da movimentação (SE5)
@param  nTotAcreLq, Valor Total de Acréscimos gerados na liquidação (FO1)

@return aDados    , Dados rateados dos casos da fatura

@author  Thiago Malaquias
@since   08/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Static Function CalRatCas(aDados, cEscrit, cFatura, nValCRec, nDescRec, nAcreRec, dDtMov, nTotAcreLq)
	Local nTotHon    := 0 // Valor total de horarios na fatura
	Local nTotDesp   := 0 // Valor total de despesas na fatura
	Local nTotFat    := 0 // Valor total da fatura
	Local nCasos     := 0 // Posição da linha do caso da fatura no array aDados
	Local cTpPriori  := SuperGetMv('MV_JTPRIO',,'1') //1-Prioriza despesas 2-Proporcional
	Local nTamVlH    := TamSX3("OHI_VLHCAS")[2]
	Local nTamVlD    := TamSX3("OHI_VLDCAS")[2]
	Local nDecVlacrH := TamSX3("OHI_VLACRH")[2]
	Local nDecVlacrD := TamSX3("OHI_VLACRD")[2]
	Local nDecVldesH := TamSX3("OHI_VLDESH")[2]
	Local nDecVldesD := TamSX3("OHI_VLDESD")[2]
	Local aSaldosOHH := {} // Recebe os saldos (honorario e despesa) da tabela OHH
	Local lDespTrib  := OHH->(ColumnPos("OHH_VLREMB")) > 0
	Local lCpoFatur  := OHH->(ColumnPos("OHH_CFATUR")) > 0
	Local nFatDesRem := 0 // Valor de Despesa Reembolsável da Fatura
	Local nFatDesTri := 0 // Valor de Despesa Tributável da Fatura
	Local nFatTxAdm  := 0 // Valor de Taxa Adm. da Fatura
	Local nFatGross  := 0 // Valor de Gross Up da Fatura
	Local nFatTotTri := 0 // Valor Total de Despesas Tributáveis (Despesa Tributável + Taxa Adm. + Gross Up)
	Local nBaseRemb  := 0
	Local nBaseTrib  := 0
	Local nBaseTxAd  := 0
	Local nBaseGros  := 0
	Local nBaseDesp  := 0
	Local cUltAnoMes := J256AnoMes()

	If  cTpPriori == '1'
		aEval(aDados, {|x| nTotHon += x[7], nTotDesp += x[8], nFatDesRem += x[13], nFatDesTri += x[14], nFatTxAdm += x[15], nFatGross += x[16] })
	Else
		aEval(aDados, {|x| x[7] := x[7] - x[17] + x[18] , nTotHon += x[7], nTotDesp += x[8], nFatDesRem += x[13], nFatDesTri += x[14], nFatTxAdm += x[15], nFatGross += x[16] } )
	EndIf

	nTotFat := nTotHon + nTotDesp

	nFatTotTri := nFatDesTri + nFatTxAdm + nFatGross

	aDados := RatVlAcres(aDados, nAcreRec, nDecVlacrH, nDecVlacrD) // Faz o rateio de Acréscimo primeiro priorizando os honorários

	cTitulo := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

	If lDespTrib
		If lCpoFatur
			aSaldosOHH := JurGetDados("OHH", 3, cEscrit + cFatura + cTitulo + cUltAnoMes, {"OHH_VLFATH", "OHH_VLFATD", "OHH_SDREMB", "OHH_SDTRIB", "OHH_SDTXAD", "OHH_SDGROS"} )
		Else
			aSaldosOHH := JurGetDados("OHH", 1, cTitulo + cUltAnoMes, {"OHH_VLFATH", "OHH_VLFATD", "OHH_SDREMB", "OHH_SDTRIB", "OHH_SDTXAD", "OHH_SDGROS"} )
		EndIf
	Else
		aSaldosOHH := JurGetDados("OHH", 1, cTitulo + cUltAnoMes, {"OHH_VLFATH", "OHH_VLFATD"} )
	EndIf

	For nCasos := 1 To Len(aDados)

		// Rateio de Honorarios e Despesas
		If cTpPriori == '1' // 1-Prioriza despesas
			If nCasos == 1  // Primeiro Caso
				aDados   := J256PriDes(aDados, cEscrit, cFatura, nValCRec, nDecVldesD, aSaldosOHH[2], "OHI", cTitulo) // Faz o rateio na despesa primeiro para calcular o rateio no honorário
				nTotDesp := 0
				aEval(aDados, {|x| nTotDesp += x[8] }) // Soma o novo valor do total de despesas rateado (Verifica se tem excedente para o honorário)
			EndIf
			If !Empty(aSaldosOHH[1]) .And. nValCRec >= nTotDesp
				aDados[nCasos][7] := RatPontoFl(aDados[nCasos][7], nTotHon, (nValCRec - nTotDesp), nTamVlH) // Valor de recebimento rateado pelo valor de honorarios do caso
			Else
				aDados[nCasos][7] := 0
			EndIf
			
		Else // 2-Proporcional

			// Reajuste dos valores dos casos
			aDados[nCasos][7]  := RatPontoFl(aDados[nCasos][7] , nTotFat, nValCRec, nTamVlH) // Valor de recebimento rateado pelo valor de honorarios do caso
			aDados[nCasos][8]  := RatPontoFl(aDados[nCasos][8] , nTotFat, nValCRec, nTamVlD) // Valor de recebimento rateado pelo valor de despesas totais do caso
			aDados[nCasos][13] := RatPontoFl(aDados[nCasos][13], nTotFat, nValCRec, nTamVlD) // Valor de recebimento rateado pelo valor de despesas reembolsáveis do caso
			aDados[nCasos][14] := RatPontoFl(aDados[nCasos][14], nTotFat, nValCRec, nTamVlD) // Valor de recebimento rateado pelo valor de despesas tributáveis do caso
			aDados[nCasos][15] := RatPontoFl(aDados[nCasos][15], nTotFat, nValCRec, nTamVlD) // Valor de recebimento rateado pelo valor de taxa administrativa do caso
			aDados[nCasos][16] := RatPontoFl(aDados[nCasos][16], nTotFat, nValCRec, nTamVlD) // Valor de recebimento rateado pelo valor de taxa gross up do caso
			aDados[nCasos][19] := RatPontoFl(aDados[nCasos][19], nTotFat, nValCRec, nTamVlD) // Valor de recebimento rateado pelo valor do total do caso
		EndIf

	Next nCasos
	
	aDados := RatVlDesc(aDados, nDescRec, nDecVldesH, nDecVldesD) // Faz o rateio de Desconto depois para aplicar o maximo de valor possivel nos honorários
	
	If lDespTrib
		If cTpPriori == '1' // Prioriza Despesa
			// Valores com base na proporção entre baixa e o valor da parcela utilizadas para ajuste de saldo
			nBaseRemb := Round(IIf(nValCRec > aSaldosOHH[3], aSaldosOHH[3], nValCRec), nTamVlD)
			nBaseTrib := Round(IIf(nValCRec > aSaldosOHH[3], IIf(nValCRec - aSaldosOHH[3] < aSaldosOHH[4] + aSaldosOHH[5] + aSaldosOHH[6], (nValCRec - aSaldosOHH[3]) * (nFatDesTri / nFatTotTri) , aSaldosOHH[4] ), 0 ), nTamVlD)
			nBaseTxAd := Round(IIf(nValCRec > aSaldosOHH[3], IIf(nValCRec - aSaldosOHH[3] < aSaldosOHH[4] + aSaldosOHH[5] + aSaldosOHH[6], (nValCRec - aSaldosOHH[3]) * (nFatTxAdm  / nFatTotTri) , aSaldosOHH[5] ), 0 ), nTamVlD)
			nBaseGros := Round(IIf(nValCRec > aSaldosOHH[3], IIf(nValCRec - aSaldosOHH[3] < aSaldosOHH[4] + aSaldosOHH[5] + aSaldosOHH[6], (nValCRec - aSaldosOHH[3]) * (nFatGross  / nFatTotTri) , aSaldosOHH[6] ), 0 ), nTamVlD)
		Else // Proporcional
			// Valores com base na proporção entre baixa e o valor da parcela utilizadas para ajuste de saldo
			If SE1->E1_SALDO == 0 .Or. SE1->E1_SALDO <= nTotAcreLq // Se o saldo for menor ou igual ao acréscimo, o saldo deve ser ajustado de forma que fique zerado
				nBaseRemb := aSaldosOHH[3]
				nBaseTrib := aSaldosOHH[4]
				nBaseTxAd := aSaldosOHH[5]
				nBaseGros := aSaldosOHH[6]
			Else
				nBaseRemb := RatPontoFl(nValCRec, nTotFat, nFatDesRem, nTamVlD)
				nBaseTrib := RatPontoFl(nValCRec, nTotFat, nFatDesTri, nTamVlD)
				nBaseTxAd := RatPontoFl(nValCRec, nTotFat, nFatTxAdm , nTamVlD)
				nBaseGros := RatPontoFl(nValCRec, nTotFat, nFatGross , nTamVlD)
			EndIf
		EndIf

		nBaseDesp := nBaseRemb + nBaseTrib + nBaseTxAd + nBaseGros // Base de despesa total
		If nBaseDesp > 0
			aDados := AjustSaldo(aDados, nBaseRemb, 0, 13, .T.) // Ajusta saldo do arredondamento do rateio para Despesas Reembolsáveis
			aDados := AjustSaldo(aDados, nBaseTrib, 0, 14, .T.) // Ajusta saldo do arredondamento do rateio para Despesas Tributáveis
			aDados := AjustSaldo(aDados, nBaseTxAd, 0, 15, .T.) // Ajusta saldo do arredondamento do rateio para Taxa Administrativa
			aDados := AjustSaldo(aDados, nBaseGros, 0, 16, .T.) // Ajusta saldo do arredondamento do rateio para Taxa Gross Up
			aDados := AjustSaldo(aDados, nBaseDesp, 0, 8 , .T.) // Faz o ajuste do valor de despesa total. Pois pode estar diferente dos valores de despesas desmembrados
		EndIf
	EndIf

	If cTpPriori == '2' // Proporcional
		For nCasos := 1 To Len(aDados) // Ajusta valor de honorários após os ajustes no total das despesas
			If aDados[nCasos][7] + aDados[nCasos][8] <> aDados[nCasos][19]
				aDados[nCasos][7] := aDados[nCasos][19] - aDados[nCasos][8]
			EndIf
		Next
	EndIf

	aDados := AjustSaldo(aDados, nValCRec,  7,  8) // Ajusta saldo do arredondamento do rateio para honorarios e despesas
	aDados := AjustSaldo(aDados, nDescRec,  9, 11) // Ajusta saldo do arredondamento do rateio para descontos
	aDados := AjustSaldo(aDados, nAcreRec, 10, 12) // Ajusta saldo do arredondamento do rateio para acréscimos

Return ( aDados )

//-------------------------------------------------------------------
/*/{Protheus.doc} RatVlAcres
Rotina de cálculo de rateio dos valores de acrescimos entre os casos 
da fatura

@param  aDados  , Dados da fatura/caso
@param  nValAcre, Valor de acréscimo do movimento
@param  nDecVlH , Número de casas decimais referentes aos acréscimos de Honorários
@param  nDecVlD , Número de casas decimais referentes aos acréscimos de Despesas

@author Jorge Martins / Jonatas Martins
@since  11/12/2020
/*/
//-------------------------------------------------------------------
Static Function RatVlAcres(aDados, nValAcre, nDecVlH, nDecVlD)
Local nCasos      := 0  // Posição da linha do caso da fatura no array aDados
Local nTotHon     := 0  // Total de honorários na fatura
Local nTotDesp    := 0  // Total de despesas na fatura
Local nPosH       := 10 // Posição no array referente aos valores de acréscimos de Honorários
Local nPosD       := 12 // Posição no array referente aos valores de acréscimos de Despesas
Local nTotAcreHon := 0  // Armazena o total de acréscimos de honorários que foram distribuídos

	If Len(aDados) > 0
		aEval(aDados, {|x| nTotHon += x[7], nTotDesp += x[8]})

		If nTotHon > 0 // Se existir valor de honorários rateia todo o acréscimo nos honorários dos casos
			For nCasos := 1 to Len(aDados)
				aDados[nCasos][nPosH] := RatPontoFl(aDados[nCasos][7], nTotHon, nValAcre, nDecVlH)
				nTotAcreHon += aDados[nCasos][nPosH]
			Next nCasos

			If nValAcre > 0 .And. nTotAcreHon == 0
				// Se o valor de acréscimo for muito pequeno e não foi possível ratear entre os casos
				// joga esse acréscimo no primeiro caso que tiver honorário
				For nCasos := 1 to Len(aDados)
					If aDados[nCasos][7] > 0
						aDados[nCasos][nPosH] := nValAcre
						Exit
					EndIf
				Next nCasos
			EndIf

			aDados := AjustSaldo(aDados, nValAcre, nPosH, 0) // Ajusta saldo do arredondamento do rateio para acréscimos nos honorários
		Else // Senão rateia todo o acréscimo nas despesas dos casos
			For nCasos := 1 to Len(aDados)
				aDados[nCasos][nPosD] := RatPontoFl(aDados[nCasos][8], nTotDesp, nValAcre, nDecVlD)
			Next nCasos
			aDados := AjustSaldo(aDados, nValAcre, 0, nPosD) // Ajusta saldo do arredondamento do rateio para acréscimos nas despesas
		EndIf
	EndIf

Return ( aDados )

//-------------------------------------------------------------------
/*/{Protheus.doc} RatVlDesc
Rotina de cálculo de rateio dos valores de descontos entre os casos 
da fatura

@param  aDados  , Dados da fatura/caso
@param  nTotDesc, Valor de desconto do movimento
@param  nDecVlH , Número de casas decimais referentes aos descontos de Honorários
@param  nDecVlD , Número de casas decimais referentes aos descontos de Despesas

@author Jorge Martins / Jonatas Martins
@since  11/12/2020
/*/
//-------------------------------------------------------------------
Static Function RatVlDesc(aDados, nTotDesc, nDecVlH, nDecVlD)
Local nTotHon     := 0  // Total de honorários na fatura
Local nTotDesp    := 0  // Total de despesas na fatura
Local nAtuDescHon := 0  // Total de descontos atual nos honorários na fatura
Local nAtuDescDes := 0  // Total de descontos atual nas despesas na fatura
Local nTotAcreHon := 0  // Total de acréscimos nos honorários na fatura
Local nTotAcreDes := 0  // Total de acréscimos nas despesas na fatura
Local nPosValH    := 7  // Posição no array referente aos valores de descontos de Honorários
Local nPosValD    := 8  // Posição no array referente aos valores de descontos de Despesas
Local nPosDescH   := 9  // Posição no array referente aos valores de descontos de Despesas
Local nPosDescD   := 11 // Posição no array referente aos valores de descontos de Despesas
Local nPosAcreH   := 10 // Posição no array referente aos valores de descontos de Despesas
Local nPosAcreD   := 12 // Posição no array referente aos valores de descontos de Despesas

	If Len(aDados) > 0
		aEval(aDados, {|x| nTotHon  += x[7], nTotAcreHon += x[10], nTotDesp += x[8], nTotAcreDes += x[12]})

		// Distribui os descontos nos seguintes valores
		aDados := GetVlDesc(aDados, @nTotDesc, @nAtuDescHon, nPosValH , nTotHon    , nPosDescH, nDecVlH) // Honorários
		aDados := GetVlDesc(aDados, @nTotDesc, @nAtuDescDes, nPosValD , nTotDesp   , nPosDescD, nDecVlD) // Despesas
		aDados := GetVlDesc(aDados, @nTotDesc, @nAtuDescHon, nPosAcreH, nTotAcreHon, nPosDescH, nDecVlH) // Acréscimos de honorários
		aDados := GetVlDesc(aDados, @nTotDesc, @nAtuDescDes, nPosAcreD, nTotAcreDes, nPosDescD, nDecVlD) // Acréscimos de despesas
	EndIf

Return ( aDados )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVlDesc
Rotina de cálculo de rateio descontos / acrescimo no valor honorarios do casos da fatura

@param  aDados   , Dados da fatura/caso
@param  nTotDesc , Total de desconto do movimento
@param  nAtuDesc , Total de desconto já aplicado na posição informada no nPosVal
@param  nPosVal  , Posição de identificação do valor no array de fatura/caso
@param  nTotVal  , Valor total (de todos os registros) por posição informada no nPosVal
@param  nPosDesc , Posição de identificação do desconto no array de fatura/caso
@param  nDecVl   , Número de casas decimais referente valores de desconto

@return aDados   , array aDados com os valores de descontos / acrescimo rateados para honorario.

@author Jorge Martins / Jonatas Martins
@since  11/12/2020
/*/
//-------------------------------------------------------------------
Static Function GetVlDesc(aDados, nTotDesc, nAtuDesc, nPosVal, nTotVal, nPosDesc, nDecVl)
Local nValDesc    := 0 // Verifica se o valor recebido excede o total de honorários/despesas
Local nCasos      := 0 // Posição da linha do caso da fatura no array aDados
Local nTotValDesc := 0 // Armazena o total de descontos que foram distribuídos

	If nTotDesc > 0  // Verifica se ainda existe desconto a ser distribuído nas despesas
		nValDesc := Iif((nTotVal > nTotDesc), nTotDesc, nTotVal) // Aplica o maximo possível do desconto para o valor (honorário, despesa)
		nAtuDesc += nValDesc // Soma os descontos aplicado sobre "honorários + acréscimos de honorários" ou "despesas + acréscimo de despesas"
		For nCasos := 1 to Len(aDados)
			aDados[nCasos][nPosDesc] += RatPontoFl(aDados[nCasos][nPosVal], nTotVal, nValDesc, nDecVl)
			nTotValDesc += aDados[nCasos][nPosDesc]
		Next nCasos

		If nTotVal > 0 .And. nTotDesc > 0 .And. nTotValDesc == 0
			// Avalia se existe um valor (nTotVal) para jogar o desconto e 
			// se o valor de desconto for muito pequeno (ex: R$ 0,01) e não foi possível ratear entre os casos
			// joga esse desconto no primeiro caso que tiver valor
			For nCasos := 1 to Len(aDados)
				If (aDados[nCasos][7] > 0 .And. nPosDesc == 9) .Or.; // Desconto de Honorários
				   (aDados[nCasos][8] > 0 .And. nPosDesc == 11)      // Desconto de Despesas
					aDados[nCasos][nPosDesc] := nTotDesc
					Exit
				EndIf
			Next nCasos
		EndIf
		
		If nPosDesc == 9 // Desconto de Honorários
			aDados := AjustSaldo(aDados, nAtuDesc, nPosDesc, 0) // Ajusta saldo do arredondamento do rateio para desconto nos honorários
		ElseIf nPosDesc == 11 // Desconto de Despesas
			aDados := AjustSaldo(aDados, nAtuDesc, 0, nPosDesc) // Ajusta saldo do arredondamento do rateio para desconto nas despesas
		EndIf
		nTotDesc -= nValDesc // Desconta o valor do desconto de despesas do total
	EndIf

Return ( aDados )

//-------------------------------------------------------------------
/*/{Protheus.doc} RatPontoFl(nValUnt, nValtot, nValRat, nDecRet)
Rotina de cálculo de rateio do valor proporcional do lançamento (honorario/despesas) entre os casos da fatura

@param  nValUnt , numerico, Valor unitário do lançamento (honorarios/Despesa) por caso
@param  nValtot , numerico, Valor total do lançamento na fatura
@param  nValRat , numerico, Valor a ser rateado entre os casos
@param  nDecRet , numerico, Precisão decimal do valor calculado

@return nRet    , numerico, Valor ratedo do lançamento

@Obs: Necessário ratear por ponto flutuante para minimizar distorções no rateio de valor com grandes diferenças
de dimensão entre honorários e despesas.

@author  Luciano Pereira dos Santos
@since   08/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Function RatPontoFl(nValUnt, nValtot, nValRat, nDecRet)
Local nRet       := 0
Local nDec       := 20 // Numero e casas decimais para cálculo de ponto flutuante
Local fPerLanCas := DEC_CREATE("0",32,nDec) // Percentual do valor do lançamento (honorarios/Despesa) no caso pelo total da fatura
Local nValLanRat := 0 // Valor do lançamento rateado

	fPerLanCas := DEC_DIV(DEC_CREATE(cValToChar(nValUnt), 32, nDec), DEC_CREATE(cValToChar(nValtot), 32, nDec))
	nValLanRat := Val(cValToChar(DEC_RESCALE(DEC_MUL(DEC_CREATE(nValRat,32,nDec), fPerLanCas),8,0)))
	nRet       := Round(nValLanRat, nDecRet)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J256PriDes()
Rotina de cálculo de rateio do valor de despesas da baixa entre os casos da fatura
conforme o parametro MV_JTPRIO

@param  aDados    , Dados da fatura/caso
@param  cEscrit   , Código do Escritório da Fatura
@param  cFatura   , Código da Fatura
@param  nValCRec  , Valor recebido
@param  nDecVlDp  , Número de casas decimais referente aos valores de Despesas
@param  nTotDesTit, Total de Despesa no título
@param  cAlias    , Define de onde está sendo chamado a rotina
@param  cTitulo   , Chave do titulo do Contas a Receber
@param  lInclui   , Verifica se será gravado um novo registro na OHH
@param  aValFat   , Valores originais da fatura
@param  cAnoMes   , Ano-Mês da movimentação da OHH (usado somente via UPDRASTR)
@param  lValorOHT , Indica se os valores vieram da OHT

@return aDados    , aDados com os valores de despesa rateados.

@Obs Necessario ratear a despesa antes para calcular o rateio de honorários
@author  Luciano Pereira dos Santos
@since   08/02/2018
/*/
//-------------------------------------------------------------------
Function J256PriDes(aDados, cEscrit, cFatura, nValCRec, nDecVlDp, nTotDesTit, cAlias, cTitulo, lInclui, aValFat, cAnoMes, lValorOHT)
	Local aDespUtil  := {}
	Local aDespPri   := {0, 0, 0, 0, 0} // Valores de Despesas - [1] Total | [2] Reembolsável | [3] Tributável | [4] Tx. Adm. | [5] Gross Up
	Local nTotDesCas := 0 // Valor total de despesas dos Casos
	Local nTotalDesp := 0
	Local nCasos     := 0
	Local nValParc   := 0 // Valor total da parcela
	Local lParc1     := .F. // Indica que é a primeira parcela

	Local nFatTotHon := 0 // Valor Total de Honorários da Fatura
	Local nFatTotDes := 0 // Valor Total de Despesas da Fatura
	Local nFatDesRem := 0 // Valor de Despesa Reembolsável da Fatura
	Local nFatDesTri := 0 // Valor de Despesa Tributável da Fatura
	Local nFatTxAdm  := 0 // Valor de Taxa Adm. da Fatura
	Local nFatGross  := 0 // Valor de Gross Up da Fatura
	Local nFatTotTri := 0 // Valor Total de Despesas Tributáveis (Despesa Tributável + Taxa Adm. + Gross Up)

	Local nOHHDesRem := 0 // Valor de Despesa Reembolsável da Posição Histórica Ctas Receber
	Local nOHHDesTri := 0 // Valor de Despesa Tributável da Posição Histórica Ctas Receber
	Local nOHHTxAdm  := 0 // Valor de Taxa Adm. da Posição Histórica Ctas Receber
	Local nOHHGross  := 0 // Valor de Gross Up da Posição Histórica Ctas Receber
	Local nOHHTotTri := 0 // Valor Total de Despesas Tributáveis (Despesa Tributável + Taxa Adm. + Gross Up)

	Local lDespTrib  := OHH->(ColumnPos("OHH_VLREMB")) > 0
	Local lCpoFatur  := OHH->(ColumnPos("OHH_CFATUR")) > 0
	Local cUltAnoMes := J256AnoMes()

	Default aDados     := {}
	Default cEscrit    := ""
	Default cFatura    := ""
	Default cTitulo    := ""
	Default nDecVlDp   := 0
	Default lInclui    := .F.
	Default aValFat    := {}
	Default cAnoMes    := Nil
	Default lValorOHT  := .F.

	If cAlias == "OHI"
		aDespUtil := GetTotDesp(cEscrit, cFatura, cTitulo) // Total de despesas utilizadas no caso.
		lParc1    := aDespUtil[1] == 0
		
		aEval(aDados, {|x| nTotDesCas += x[8], nFatDesRem += x[13], nFatDesTri += x[14], nFatTxAdm += x[15], nFatGross += x[16] })
		nFatTotTri := nFatDesTri + nFatTxAdm + nFatGross

		If lDespTrib
			If lCpoFatur
				aDadosOHH := JurGetDados("OHH", 3, cEscrit + cFatura + cTitulo + cUltAnoMes, {"OHH_VLREMB", "OHH_VLTRIB", "OHH_VLTXAD", "OHH_VLGROS"} )
			Else
				aDadosOHH := JurGetDados("OHH", 1, cTitulo + cUltAnoMes, {"OHH_VLREMB", "OHH_VLTRIB", "OHH_VLTXAD", "OHH_VLGROS"} )
			EndIf
			If Len(aDadosOHH) == 4
				nOHHDesRem := aDadosOHH[1]
				nOHHDesTri := aDadosOHH[2]
				nOHHTxAdm  := aDadosOHH[3]
				nOHHGross  := aDadosOHH[4]
				nOHHTotTri := nOHHDesTri + nOHHTxAdm + nOHHGross
			EndIf
		EndIf

		aDespPri[1] := Iif(nTotDesTit - aDespUtil[1] > nValCRec, nValCRec, nTotDesTit - aDespUtil[1]) // Despesa Total
		aDespPri[2] := J256CalRem(aDespUtil[2], nValCRec, nOHHDesRem) // Despesa Reembolsável
		aDespPri[3] := J256CalTri(lParc1, aDespUtil[3], nValCRec, aDespPri[1], aDespPri[2], nOHHDesTri, nOHHTotTri, nOHHDesRem) // Despesa Tributável
		aDespPri[4] := J256CalTri(lParc1, aDespUtil[4], nValCRec, aDespPri[1], aDespPri[2], nOHHTxAdm , nOHHTotTri, nOHHDesRem) // Taxa Administrativa
		aDespPri[5] := J256CalTri(lParc1, aDespUtil[5], nValCRec, aDespPri[1], aDespPri[2], nOHHGross , nOHHTotTri, nOHHDesRem) // Taxa Gross Up

		For nCasos := 1 to Len(aDados)
			aDados[nCasos][13] := RatPontoFl(aDados[nCasos][13], nFatDesRem, aDespPri[2], nDecVlDp) // Valor de recebimento rateado pelo valor de despesas reembolsáveis do caso
			aDados[nCasos][14] := RatPontoFl(aDados[nCasos][14], nFatDesTri, aDespPri[3], nDecVlDp) // Valor de recebimento rateado pelo valor de despesas tributáveis do caso
			aDados[nCasos][15] := RatPontoFl(aDados[nCasos][15], nFatTxAdm , aDespPri[4], nDecVlDp) // Valor de recebimento rateado pelo valor de taxa administrativa do caso
			aDados[nCasos][16] := RatPontoFl(aDados[nCasos][16], nFatGross , aDespPri[5], nDecVlDp) // Valor de recebimento rateado pelo valor de taxa gross up do caso
		Next nCasos

		aDados := AjustSaldo(aDados, aDespPri[2], 0, 13) // Ajusta saldo do arredondamento do rateio para Despesas Reembolsáveis
		aDados := AjustSaldo(aDados, aDespPri[3], 0, 14) // Ajusta saldo do arredondamento do rateio para Despesas Tributáveis
		aDados := AjustSaldo(aDados, aDespPri[4], 0, 15) // Ajusta saldo do arredondamento do rateio para Taxa Administrativa
		aDados := AjustSaldo(aDados, aDespPri[5], 0, 16) // Ajusta saldo do arredondamento do rateio para Taxa Gross Up

		For nCasos := 1 to Len(aDados)
			nTotalDesp := aDados[nCasos][13] + aDados[nCasos][14] + aDados[nCasos][15] + aDados[nCasos][16]
			If lDespTrib .And. nTotalDesp > 0
				aDados[nCasos][8] := nTotalDesp // Valor de Despesas do caso somado pelos itens de despesas gravador acima
			Else
				aDados[nCasos][8] := RatPontoFl(aDados[nCasos][8], nTotDesCas, aDespPri[1], nDecVlDp) // Valor de recebimento rateado pelo valor de despesas do caso
			EndIf
		Next nCasos

		If !lDespTrib
			aDados := AjustSaldo(aDados, aDespPri[1], 0, 8) // Faz o ajuste do valor de despesa total. Pois pode estar diferente dos valores de despesas desmembrados
		EndIf

		aDespPri := aClone(aDados)

	Else

		If Len(aValFat) >= 6
			nFatTotHon := aValFat[1]
			nFatTotDes := aValFat[2]
			nFatDesRem := aValFat[3]
			nFatDesTri := aValFat[4]
			nFatTxAdm  := aValFat[5]
			nFatGross  := aValFat[6]
		EndIf

		If lValorOHT
			aDespPri[1] := nFatTotDes
			aDespPri[2] := nFatDesRem
			aDespPri[3] := nFatDesTri
			aDespPri[4] := nFatTxAdm
			aDespPri[5] := nFatGross
		Else
			aDespUtil   := J255GetDes(cEscrit, cFatura, lInclui, cAnoMes, cTitulo) // Total de despesas gravadas nas parcelas
		
			lParc1      := aDespUtil[1] == 0
			nValParc    := IIf(nFatTotHon + nFatTotDes > SE1->E1_VALOR, SE1->E1_VALOR, nFatTotHon + nFatTotDes) // SE1->E1_VALOR // Valor total da parcela
			nFatTotTri  := nFatDesTri + nFatTxAdm + nFatGross

			aDespPri[1] := Iif(nTotDesTit - aDespUtil[1] > nValParc, nValParc, nTotDesTit - aDespUtil[1]) // Valor total de despesas (Desp Reemb + Desp Trib + Tx Adm. + Gross UP)
			aDespPri[2] := J256CalRem(aDespUtil[2], nValParc, nFatDesRem) // Despesa Reembolsável
			aDespPri[3] := J256CalTri(lParc1, aDespUtil[3], nValParc, aDespPri[1], aDespPri[2], nFatDesTri, nFatTotTri, nFatDesRem) // Despesa Tributável
			aDespPri[4] := J256CalTri(lParc1, aDespUtil[4], nValParc, aDespPri[1], aDespPri[2], nFatTxAdm , nFatTotTri, nFatDesRem) // Taxa Administrativa
			aDespPri[5] := J256CalTri(lParc1, aDespUtil[5], nValParc, aDespPri[1], aDespPri[2], nFatGross , nFatTotTri, nFatDesRem) // Taxa Gross Up
		EndIf
	EndIf

Return (aDespPri)

//-------------------------------------------------------------------
/*/{Protheus.doc} J256CalRem()
Calcula o valor para distribuição dos valores de despesas reembolsáveis

@param  nValUtil   , Valor de despesa reembolsável já utilizado
@param  nValParc   , Valor da parcela atual
@param  nDesRemTot , Valor de despesa reembolsável da fatura ou OHH

@author  Abner Fogaça / Jorge Martins
@since   14/02/2020
/*/
//-------------------------------------------------------------------
Function J256CalRem(nValUtil, nValParc, nDesRemTot)
	Local nValor := 0

	If nValUtil == 0 // Primeira vez que será atribuído valor
		nValor := IIf(nValParc < nDesRemTot, nValParc, nDesRemTot)
	Else
		If nDesRemTot != nValUtil // Valor já utilizado (parcelas anteriores) diferente do valor de despesa reembolsável total (fatura ou OHH)
			If nValParc < (nDesRemTot - nValUtil)
				nValor := nValParc
			Else
				nValor := nDesRemTot - nValUtil
			EndIf
		EndIf
	EndIf

	nValor := IIf(nValor < 0, 0, nValor)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J256CalTri()
Calcula o valor para distribuição dos valores de despesas tributáveis
(despesa tributável, taxa administrativa e taxa gross up).

@param  lParc1     , Indica se é a primeira parcela
@param  nValUtil   , Valor já utilizado (Caso seja 1ª parcela será 0)
@param  nValParc   , Valor da parcela atual
@param  nTotDesPar , Valor Total de despesas da parcela atual
@param  nDesRemPar , Valor de despesa reembolsável da parcela atual
@param  nFatValTri , Valor da despesa tributável da fatura (despesa tributável ou taxa administrativa ou taxa gross up)
@param  nFatTotTri , Valor total de despesa tributável da fatura (despesa tributável + taxa administrativa + taxa gross up)
@param  nDesRemTot , Valor de despesa reembolsável da fatura ou  OHH

@author  Abner Fogaça / Jorge Martins
@since   14/02/2020
/*/
//-------------------------------------------------------------------
Function J256CalTri(lParc1, nValUtil, nValParc, nTotDesPar, nDesRemPar, nFatValTri, nFatTotTri, nDesRemTot)
	Local nValor    := 0
	Local nPropTrib := nFatValTri / nFatTotTri // Calcula proporção de um dos 3 valores sobre o total (Desp Trib + Tx Adm. + Gross Up)

	If lParc1 .And. nValUtil == 0
		If nFatTotTri > nValParc - nDesRemTot // Verifica se o Total Tributável é maior que o valor da parcela menos o valor de Desp. Reembolsável
			If nValParc > nDesRemTot
				nValor := (nValParc - nDesRemTot) * nPropTrib
			EndIf
		ElseIf nValParc >= nFatValTri
			nValor := nFatValTri
		EndIf
	Else
		If nDesRemTot != nValUtil
			If nValParc < (nFatValTri - nValUtil - nDesRemPar)
				nValor := (nValParc - nDesRemPar) * nPropTrib
			Else
				nValor := (nTotDesPar - nDesRemPar) * nPropTrib
			EndIf
		EndIf
	EndIf

	nValor := IIf(nValor < 0, 0, nValor)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTotDesp
Rotina de cálculo de rateio do valor da baixa entre os casos da fatura por título

@param  cEscrit , Código do Escritório da Fatura
@param  cFatura , Código da Fatura
@param  cTitulo , Chave do título na SE1

@return aDesp   , Valor total da despesa

@author  Thiago Malaquias
@since   08/02/2018
/*/
//-------------------------------------------------------------------
Static Function GetTotDesp(cEscrit, cFatura, cTitulo)
Local aDesp     := {0, 0, 0, 0, 0}
Local cQuery    := ""
Local cQryRes   := ""
Local lDespTrib := OHI->(ColumnPos("OHI_VLREMB")) > 0 // Proteção

Default cTitulo := ""

	cQuery := " SELECT SUM(OHI_VLDCAS) OHI_VLDCAS "
	If lDespTrib
		cQuery +=   ", SUM(OHI_VLREMB) OHI_VLREMB, SUM(OHI_VLTRIB) OHI_VLTRIB, SUM(OHI_VLTXAD) OHI_VLTXAD, SUM(OHI_VLGROS) OHI_VLGROS "
	EndIf
	cQuery +=  " FROM " + RetSqlName("OHI") + " "
	cQuery += " WHERE OHI_FILIAL = '" + xFilial("OHI") + "' "
	cQuery +=   " AND OHI_CESCR  = '" + cEscrit + "' "
	cQuery +=   " AND OHI_CFATUR = '" + cFatura + "' "
	cQuery +=   " AND OHI_CHVTIT = '" + cTitulo + "' "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	cQryRes := GetNextAlias()
	cQuery  := ChangeQuery( cQuery )

	DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cQryRes, .T., .T.)

	If (cQryRes)->(!Eof()) .And. !Empty((cQryRes)->OHI_VLDCAS)
		aDesp[1] := (cQryRes)->OHI_VLDCAS
		If lDespTrib
			aDesp[2] := (cQryRes)->OHI_VLREMB
			aDesp[3] := (cQryRes)->OHI_VLTRIB
			aDesp[4] := (cQryRes)->OHI_VLTXAD
			aDesp[5] := (cQryRes)->OHI_VLGROS
		EndIf
	EndIf

	(cQryRes)->(DbCloseArea())

Return aDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustSaldo(aDados, nValor, nVldPosH, nVldPosD)
Rotina de ajuste de saldo do arredondamento do rateio com o valor total

@param  aDados ,   array   , Dados da fatura/caso
@param  nValConf,  numerico, Valor Total para verificar o ajuste de saldo do rateio
@param  nVldPosH,  numerico, Posição no array referente aos valores de honorarios
@param  nVldPosD,  numerico, Posição no array referente aos valores de despesa
@param  lForceAj,  logico  , Força o ajuste no valor que realmente está diferente do esperado,
                             diferente das outras chamadas, em que a diferença é aplicada 
                             no maior valor encontrado.

@return aDados , array   , array aDados com o ajuste de saldo realizado.

@author  Luciano Pereira dos Santos
@since   12/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Static Function AjustSaldo(aDados, nValConf, nVldPosH, nVldPosD, lForceAj)
	Local nPosD    := 0
	Local nMaiorD  := 0
	Local nTotDesp := 0
	Local nPosH    := 0
	Local nMaiorH  := 0
	Local nTotHon  := 0
	Local nValDiff := 0
	Local nI       := 0

	Default aDados    := {}
	Default nValConf  := 0
	Default nVldPosD  := 0
	Default nVldPosH  := 0
	Default lForceAj  := .F.

	For nI := 1 To Len(aDados)
		If nVldPosH > 0
			If nMaiorH <= aDados[nI][nVldPosH]
				nMaiorH := aDados[nI][nVldPosH]
				nPosH := nI
			EndIf
			nTotHon += aDados[nI][nVldPosH]
		EndIf

		If nVldPosD > 0
			If lForceAj
				If aDados[nI][8] <> aDados[nI][13] + aDados[nI][14] + aDados[nI][15] + aDados[nI][16]
					nPosD := nI
				EndIf
			Else
				If nMaiorD <= aDados[nI][nVldPosD]
					nMaiorD := aDados[nI][nVldPosD]
					nPosD := nI
				EndIf
			EndIf
			nTotDesp += aDados[nI][nVldPosD]
		EndIf

	Next nI

	nValDiff := nValConf - (nTotHon + nTotDesp)

	If nValDiff != 0
		If (nPosH > 0) .And. (nMaiorH > 0)
			aDados[nPosH][nVldPosH] += nValDiff
			aDados[nPosH][nVldPosH] := IIf(aDados[nPosH][nVldPosH] > 0, aDados[nPosH][nVldPosH], 0)
		Elseif (nPosD > 0)
			aDados[nPosD][nVldPosD] += nValDiff // Aplica a diferença no total de despesas
			aDados[nPosD][nVldPosD] := IIf(aDados[nPosD][nVldPosD] > 0, aDados[nPosD][nVldPosD], 0)
		EndIf
	EndIf

Return ( aDados )


//-------------------------------------------------------------------
/*/{Protheus.doc} J256DelRas
Remove rastreamento dos casos da fatura no cancelamento da baixa
a receber.

@param  nSE1Recno, numerico, Recno do registro SE1
@param  nSE5Recno, numerico, Recno do registro SE5
@param  aOHIBxAnt, Array,    Valor total de baixas de honorários e despesas

@return lCancBx  , logico  , Sucesso ou falha na gravação do rastreamento

@author  Jonatas Martins
@since   09/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Function J256DelRas(nSE1Recno, nSE5Recno, aOHIBxAnt)
Local aAreas    := {SE1->(GetArea()), SE5->(GetArea()), OHI->(GetArea()), GetArea()}
Local cTmpOHI   := ""
Local cEscrit   := ""
Local cFatura   := ""
Local cTitulo   := ""
Local lCancBx   := .T.

Default nSE1Recno := 0
Default nSE5Recno := 0

	//--------------------------------------------
	// Proteção devido ao congelamento do release
	//---------------------------------------------
	If AliasIndic("OHI")
		SE1->( DbGoTo( nSE1Recno ) )
		cTitulo := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

		If SE1->( ! Eof() ) .And. JurIsJuTit(nSE1Recno)
			SE5->( DbGoTo( nSE5Recno ) )

			If SE5->( ! Eof() ) .And. SE5->E5_TIPO <> PadR( "RA" , TamSX3("E5_TIPO")[1] )
				cTmpOHI := GetDataCan()

				If (cTmpOHI)->( ! Eof() )
					aOHIBxAnt := J255TotBx(cTitulo)
					lCancBx   := DeleteOHI( cTmpOHI )
					//---------------------------------
					// Atualiza fila de sincronização
					//---------------------------------
					cEscrit   := OHI->OHI_CESCR
					cFatura   := OHI->OHI_CFATUR
					lCancBx   := lCancBx .And. J170GRAVA( "JURA256" , xFilial("NXA") +  cEscrit + cFatura , GetSincOper( cEscrit , cFatura ) )
				EndIf
				(cTmpOHI)->( DbCloseArea() )
			EndIf
		EndIf
	EndIf

	Aeval( aAreas , {|aArea| RestArea( aArea ) } )
Return ( lCancBx )


//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataCan
Busca registros do rastreamento vinculados a baixa cancelada

@return cTmpOHI, caracter, Alias temporário

@author  Jonatas Martins
@since   09/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Static Function GetDataCan()
	Local cChvTit := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
	Local cSE5Seq := SE5->E5_SEQ
	Local cTmpOHI := GetNextAlias()

	BeginSql Alias cTmpOHI
		SELECT R_E_C_N_O_ nRecno
		FROM %Table:OHI%
		WHERE OHI_FILIAL = %xFilial:OHI%
			AND OHI_CHVTIT = %Exp:cChvTit%
			AND OHI_SE5SEQ = %Exp:cSE5Seq%
			AND %NotDel%
	EndSql

Return ( cTmpOHI )


//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteOHI
Deleta resgistro vinculados a baixa cancelada na tabela de rastreamento

@param  cTmpOHI    , caracter, Alias temporário
@return lDelOHI    , logico  , Sucesso ou falha na exclusão do registro

@author  Jonatas Martins
@since   09/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Static Function DeleteOHI( cTmpOHI )
	Local lDelOHI := .T.

	BEGIN TRANSACTION
		While (cTmpOHI)->( ! Eof() )
			OHI->( DbGoTo( (cTmpOHI)->nRecno ) )

			If OHI->( ! Eof() ) .And. RecLock("OHI", .F.)
				OHI->( DbDelete() )
				OHI->( MsUnLock() )
			Else
				lDelOHI := .F.
				DisarmTransaction()
				Exit
			EndIf

			(cTmpOHI)->( DbSkip() )
		EndDo
	END TRANSACTION

Return ( lDelOHI )


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSincOper
Verifica se existe registro de rastreamento e retorna a operação para
fila de sincronização

@param  cEscrit   , caracter  , Código do escritório
@param  cFatura   , caracter  , Código da fatura
@param  lInclui   , logico    , Se verdadeiro operação de inclusão
@return cSincOper , caraceter , Tipo da operação: 4=Alteração; 5=Exclusão

@author  Jonatas Martins
@since   09/02/2018
@version 12.1.20
/*/
//-------------------------------------------------------------------
Static Function GetSincOper( cEscrit , cFatura , lInclui )
	Local cSincOper  := 0

	Default cEscrit := ""
	Default cFatura := ""
	Default lInclui := .F.

	OHI->( DbSetOrder(1) ) //OHI_FILIAL, OHI_CESCR, OHI_CFATUR, OHI_CCONTR, OHI_ITEM
	If OHI->( DbSeek( xFilial("OHI") + cEscrit  + cFatura ) )
		cSincOper := "4"
	Else
		cSincOper := IIF( lInclui , "3", "5" )
	EndIf

Return ( cSincOper )


//-------------------------------------------------------------------
/*/{Protheus.doc} J256FCarga
Função de filtro para carga inicial

@param   cKey   , caracter  , Chave do registro
@return  lFilter, logico    , Verdadeiro/Falso

@author  Jonatas Martins
@since   09/02/2018
@version 12.1.20
@obs     Função chamada no fonte JURA170
/*/
//-------------------------------------------------------------------
Function J256FCarga( cKey )
	Local aAreas  := {SE1->(GetArea()), GetArea()}
	Local lFilter := .F.

	Default cKey   := ""

	SE1->( DbSetOrder(1) ) 
	If SE1->( DbSeek( cKey )) 
		lFilter := !Empty(SE1->E1_JURFAT)
	EndIf
	
	Aeval( aAreas , {|cArea| RestArea(cArea)} )

Return ( lFilter )


//-------------------------------------------------------------------
/*/{Protheus.doc} J256ValAce
Calcula valores acessórios da baixa.

@param  cSE5IdOri, caractere, Id de origem dos dados da SE5

@return nValor   , numérico , Valores acessórios

@author  Jorge Martins / Bruno Ritter
@since   25/10/2018
/*/
//-------------------------------------------------------------------
Function J256ValAce(cSE5IdOri)
Local aAreas    := {SE5->(GetArea()), GetArea()}
Local aTamE1Vl  := {}
Local cAliasAce := GetNextAlias()
Local cTipoDoc  := ""
Local nValor    := 0
Local nTamVl    := 0
Local nTamDec   := 0

	aTamE1Vl := TamSX3("E1_VALOR")
	nTamVl := aTamE1Vl[01]
	nTamDec := aTamE1Vl[02]
	cTipoDoc  := "VA"

	BeginSql Alias cAliasAce

		COLUMN E5_VLMOED2 AS NUMERIC (nTamVl, nTamDec)

		SELECT SUM(CASE WHEN SE5.E5_VLMOED2 IS NULL THEN 0 ELSE  SE5.E5_VLMOED2 END) E5_VLMOED2
		  FROM %Table:SE5% SE5 
		 WHERE SE5.E5_FILIAL = %xFilial:SE5%
		   AND SE5.E5_IDORIG = %Exp:cSE5IdOri%
		   AND SE5.E5_TIPODOC =  %Exp:cTipoDoc%
		   AND SE5.%NotDel%  
	EndSql

	nValor := (cAliasAce)->E5_VLMOED2
	(cAliasAce)->(DbCloseArea())
	Aeval(aAreas, {|aArea| RestArea(aArea)})

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J256AnoMes
Identifica o último registro na OHH para o título.

@return cAnoMes, Ano Mês do último registro na OHH para o título

@author  Jorge Martins / Bruno Ritter
@since   05/03/2020
/*/
//-------------------------------------------------------------------
Static Function J256AnoMes()
	Local cAnoMes := ""
	Local cQuery  := ""
	Local aAnoMes := {}

	cQuery := " SELECT MAX(OHH_ANOMES) ANOMES "
	cQuery +=   " FROM " + RetSqlName("OHH") + " "
	cQuery +=  " WHERE OHH_FILIAL = '" + SE1->E1_FILIAL + "' "
	cQuery +=    " AND OHH_PREFIX = '" + SE1->E1_PREFIXO + "' "
	cQuery +=    " AND OHH_NUM    = '" + SE1->E1_NUM + "' "
	cQuery +=    " AND OHH_PARCEL = '" + SE1->E1_PARCELA + "' "
	cQuery +=    " AND OHH_TIPO   = '" + SE1->E1_TIPO + "' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "

	aAnoMes := JurSQL(cQuery, {"ANOMES"},,,.F.)

	If Len(aAnoMes) > 0
		cAnoMes := aAnoMes[1][1]
	EndIf

	JurFreeArr(@aAnoMes)

Return cAnoMes

//-------------------------------------------------------------------
/*/{Protheus.doc} J256SldOHH
Indica o Saldo restante para baixa do título

@return nSaldoOHH, Saldo do título

@author  Jorge Martins / Jonatas Martins / Abner Oliveira
@since   18/11/2020
/*/
//-------------------------------------------------------------------
Static Function J256SldOHH()
	Local cAnoMes    := J256AnoMes()
	Local cQryOHH    := ""
	Local aSaldoOHH  := {}
	Local nSaldoOHH  := 0

	cQryOHH :=  " SELECT SUM(OHH_SALDO) OHH_SALDO "
	cQryOHH +=    " FROM " + RetSqlName("OHH") + " "
	cQryOHH +=   " WHERE OHH_FILIAL = '" + SE1->E1_FILIAL + "' "
	cQryOHH +=     " AND OHH_ANOMES = '" + cAnoMes + "' "
	cQryOHH +=     " AND OHH_PREFIX = '" + SE1->E1_PREFIXO + "' "
	cQryOHH +=     " AND OHH_NUM    = '" + SE1->E1_NUM + "' "
	cQryOHH +=     " AND OHH_PARCEL = '" + SE1->E1_PARCELA + "' "
	cQryOHH +=     " AND OHH_TIPO   = '" + SE1->E1_TIPO + "' "
	cQryOHH +=     " AND D_E_L_E_T_ = ' ' "

	aSaldoOHH := JurSQL(cQryOHH, {"OHH_SALDO"})

	nSaldoOHH := IIf(Len(aSaldoOHH) > 0, aSaldoOHH[1][1], 0)

	JurFreeArr(@aSaldoOHH)

Return nSaldoOHH
