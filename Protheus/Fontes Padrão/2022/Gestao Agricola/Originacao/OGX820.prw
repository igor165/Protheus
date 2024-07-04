#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGX820.ch"
#Include 'tbiconn.ch'
#INCLUDE "FWMVCDEF.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

Static cLastFolder

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX820R
Função para execução através do pergunte 
Atualização do Plano de Vendas
@author tamyris.g	
@since 06/02/2019
@version P12
@type OGX820R()
/*/    
//-------------------------------------------------------------------
Function OGX820R()
	//MV_PAR01 – Unidade de Negocio De ?
	//MV_PAR02 – Unidade de Negocio Até ?
	//MV_PAR03 – Safra De ?
	//MV_PAR04 – Safra Até ?
	//MV_PAR05 – Grp Produto De ?
	//MV_PAR06 – Grp Produto Até ?
	//MV_PAR07 – Produto De ?
	//MV_PAR08 – Produto Até ?

	Private _cUniNeg := ''
	Private _cGrProd := ''
	Private _cSafra  := ''
	Private _cProd  := ''
	Private _cCodPla  := ''

	Pergunte("OGX820",.T.)

	Processa({|| OGX820Exe(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08) }, STR0004, STR0005 ) //Atualização do Plano de Vendas ## "AGUARDE"



Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX820Exe
Atualização do Plano de Vendas
@author tamyris.g	
@since 23/08/2018
@version P12
@type OGX820SCH()
/*/    
//-------------------------------------------------------------------
Function OGX820Exe(pFilDe,pFilAte,pSafraDe,pSafraAte,pGrpProDe,pGrpProAte,pCodProDe,pCodProAte)

	Local cAliasQry  := GetNextAlias()
	Local cQuery  	 := ""

	Private AGRResult := AGRViewProc():New()

	AGRResult:EnableLog("plano_vendas", STR0004 + If (IsBlind()," - Schedule","")) //Atualização do Plano de Vendas

	cQuery := " SELECT * , N8Y.R_E_C_N_O_ AS N8Y_RECNO "
	cQuery += " FROM " + RetSqlName("N8Y") + " N8Y "
	cQuery += " WHERE N8Y_ATIVO = '1' 
	cQuery += "    AND N8Y_FILIAL >= '" + pFilDe     + "' "
	cQuery += "    AND N8Y_FILIAL <= '" + pFilAte    + "' "
	cQuery += "    AND N8Y_SAFRA  >= '" + pSafraDe   + "' "
	cQuery += "    AND N8Y_SAFRA  <= '" + pSafraAte  + "' "
	cQuery += "    AND N8Y_GRPROD >= '" + pGrpProDe  + "' "
	cQuery += "    AND N8Y_GRPROD <= '" + pGrpProAte + "' "
	cQuery += "    AND N8Y_CODPRO >= '" + pCodProDe  + "' "
	cQuery += "    AND N8Y_CODPRO <= '" + pCodProAte + "' "
	cQuery += "    AND N8Y_STAPLA <> '3' " //Desconsidera planos finalizados
	cQuery += "    AND N8Y_STAPLA <> '1' " //Desconsidera planos Não iniciado	

	cQuery := ChangeQuery(cQuery)	 
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->( !Eof() )

		cTitulo := (cAliasQry)->N8Y_FILIAL + " - " + RetTitle("N8Y_SAFRA")  + ": " + (cAliasQry)->N8Y_SAFRA + " - " 
		cTitulo += RetTitle("N8Y_GRPROD") + ": " + AllTrim((cAliasQry)->N8Y_GRPROD)  + "/" + AllTrim((cAliasQry)->N8Y_CODPRO)

		conout(ctitulo)
		conout(STR0002)
		AGRResult:Add( cTitulo  )
		AGRResult:Add( STR0002  ) //Iniciando Atualização Plano de Vendas

		DbSelectArea("N8Y")
		N8Y->(DbGoTop())
		N8Y->(dbGoTo( (cAliasQry)->N8Y_RECNO ) )

		If OGX820( .T.)
			AGRResult:Add( STR0001  ) //Plano de Vendas atualizado com sucesso
		Else
			AGRResult:Add( STR0003  ) //Ocorreram erros na atualização do Plano de Vendas
		End

		AGRResult:Add( "" )

		(cAliasQry)->( DbSkip() )
	EndDo
	(cAliasQry)->(DbcloseArea())

	AGRResult:AGRLog:Save()
	AGRResult:AGRLog:EndLog()

	If !IsBlind()
		AGRResult:Show(STR0004, STR0004, "Erros")
	EndIf

Return .T.

/** {Protheus.doc} OGX820
Rotina para atualização do plano de vendas

@param: 	cAlias - Tabela 
@param: 	nReg - Registro para atualizacao
@param: 	nAcao - Tipo de atualizacao
@param: 	lAuto - Se automatica para nao exibir mensagens
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	09/07/2018
@Uso: 		OGA250 - Romaneio
*/
Function OGX820(lAuto)
	Local nQtdFat := 0
	Local nQtRes  := 0
	Local nQtEstq := 0
	Local aProd := {}

	Private __cUnMedPro := Posicione("SB1",1,xFilial("SB1")+N8Y->N8Y_CODPRO,'B1_UM')
	Private __cUnMedPla := N8Y->N8Y_UM1PRO
	Private __cCodPro   := N8Y->N8Y_CODPRO
	Private __nTotQtVen := 0

	If Empty(N8Y->N8Y_CODPRO)
		//Busca o primeiro produto do grupo de produtos
		dbSelectArea("SB1")
		dbSetOrder(4)
		dbGoTop()
		If dbSeek(fwxFilial("SB1")+ N8Y->N8Y_GRPROD,.t.)
			__cUnMedPro := SB1->B1_UM
			__cCodPro   := SB1->B1_COD
		EndIf
	EndIF

	Begin Transaction

		//Se última atualização não ocorreu na data atual, realiza a cópia dos Volumes Disponíveis e Itens
		If N8Y->N8Y_DTATUA <> dDataBase

			//Seta registro como inativo
			RecLock("N8Y",.f.)
			N8Y->N8Y_ATIVO = '2'
			N8Y->(MsUnlock())

			//Realiza a cópia dos registros
			OGX820Copy()
		Else
			//Caso esteja atualizando o plano no mesmo dia, zerar campos
			dbSelectArea("N8W")
			N8W->(dbSetOrder(1))
			If N8W->(dbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA ))
				While N8W->(!EOF()) .And. N8W->(N8W_FILIAL + N8W_CODPLA) == N8Y->(N8Y_FILIAL + N8Y_CODPLA)
					RecLock("N8W",.f.)
					If N8Y->N8Y_TIPVOL == "2" //Base Financeiro
						N8W->N8W_QTPRVE := 0 //Qtde Planejada a Vender
					Else
						N8W->N8W_QTPRRE := 0 //Qtde Planejada a Receber
					EndIF 
					N8W->N8W_PERREC := 0 //% Rec Financeiro 
					N8W->N8W_QTDREC := 0 //Quantidade Recebida
					N8W->N8W_SLDREC := 0 //Saldo a Receber
					N8W->N8W_QTDVEN := 0 //Qtde Vendida
					N8W->N8W_QTDFAT := 0 //Qtde Faturada
					/*A Vender Faturamento*/
					N8W->N8W_VPRTD1 := 0 //Valor Total Previsto Fat - Demonstrativo
					N8W->N8W_VPRTD2 := 0 //Valor Total Previsto Fat - Demonstrativo 2ª Moeda
					N8W->N8W_VPRTF1 := 0 //Valor Total Previsto Fat - Financeiro
					N8W->N8W_VPRTF2 := 0 //Valor Total Previsto Fat - Financeiro 2ª Moeda
					N8W->(MsUnlock())
					N8W->(dbSkip())
				EndDo
			EndIf
			N8W->(DbcloseArea())
		EndIF

		//Data de Atualização
		RecLock("N8Y",.f.)
		N8Y->N8Y_DTATUA := dDataBase
		N8Y->N8Y_HRATUA  := Substr( Time(), 1, 5 )     
		N8Y->(MsUnlock())

		/*** ATUALIZAÇÕES NO VOLUME DISPONÍVEL ***/
		//1 - Atualizar Qtd Prev Produção e Qtd Produzida
		aProd := AtuQtdProd()

		//2 - Atualizar Quantidade Reservada
		nQtRes := AtuQtdRes()

		//3 - Atualiza Estoque
		nQtEstq := AtuQtdEst() 

		//4 - Atualiza Quantidade Faturada
		nQtdFat := AtuQtdFat()

		RecLock("N8Y",.f.)			
		If Len(aProd) > 0
			N8Y->N8Y_QTPPRO := ConvUnMed(aProd[1]         ,1,__cCodPro,TamSx3('N8Y_QTPPRO')[2] )  
			N8Y->N8Y_QTPRDZ := ConvUnMed(aProd[2]         ,1,__cCodPro,TamSx3('N8Y_QTPRDZ')[2] )   
			N8Y->N8Y_QTAPRO := ConvUnMed(aProd[1]-aProd[2],1,__cCodPro,TamSx3('N8Y_QTAPRO')[2] )   
			N8Y->N8Y_DTIPPR := StoD(aProd[3])
			N8Y->N8Y_DTFPPR := StoD(aProd[4])
		EndIF
		N8Y->N8Y_QTRESE := ConvUnMed(nQtRes,1,__cCodPro,TamSx3('N8Y_QTRESE')[2])			
		N8Y->N8Y_QTESTO := ConvUnMed(nQtEstq,1,__cCodPro,TamSx3('N8Y_QTESTO')[2]) 
		N8Y->N8Y_QTDFAT := ConvUnMed(nQtdFat,1,__cCodPro,TamSx3('N8Y_QTDFAT')[2])			
		N8Y->N8Y_QTDCOM := N8Y->(N8Y_QTAPRO - N8Y_QTARRE - N8Y_QTRESE + N8Y_QTESTO + N8Y_QTDFAT )
		N8Y->N8Y_HRATUA  := Substr( Time(), 1, 5 )
		N8Y->(MsUnlock())

		//Buscar o Volume disponível por Unid. Negoc, Grupo e Produto para atualizar os períodos

		/*** ATUALIZAÇÕES NO ITEM DO PLANO DE VENDAS ***/ 

		///Busca o índice relacionado à moeda do plano para buscar a Taxa de Conversão
		__cIndPla := getIndMoed(N8Y->N8Y_MOEDA)

		//Distribuição do Volume Disponível - Quantidade Prevista Venda
		AtuQtPrVen()

		//Atualiza Qtd Vendida
		AtuQtdVen()

		//Replanejamento de Períodos Vencidos
		RepPerVenc()

		//Replanejamento do saldo quando o Qtd Vendida ultrapassa a Qtd prevista
		ReplSdoVen()

		//Auto-Healing - Corrige diferenças de arredondamento originadas no Replanejamento
		AjustaPerc()

		//Cálculo Preços A Vender (Previsto) Faturamento do Plano 
		AtuPrcPV() 

		//Atualiza Qtd Prev a Receber e Preços conforme condições de Pagamento
		AtuQtdRec()

	End Transaction

	If !lAuto
		msgalert(STR0001)
	EndIf

	Return .T.

	/*/{Protheus.doc} OGX820Copy()
	Realiza a cópia dos Itens do Plano (N8W) e Sdo Disponível (N8Y)
	@type  Static Function
	@author tamyris.g	
	@since 09/07/2018
	@version 1.0
	/*/
Function OGX820Copy()
	Local aN8Y := {}
	Local aN8W := {}
	Local cCodPla := ""

	// INICIA A CÓPIA - grava no array os dados que serão copiados *** 
	OG880DTCPY(Nil, @aN8Y, @aN8W)

	cFilBkp  := cFilAnt
	cFilAnt  := N8Y->N8Y_FILIAL

	//Realiza a cópia da N8Y - Volumes disponíveis			
	OG880CPN8Y(aN8Y, @cCodPla)

	//Realiza a cópia da N8W - Itens do Plano
	OG880CPN8W(aN8W,cCodPla,'3')

	cFilAnt := cFilBkp

	Return .T.

	/*/{Protheus.doc} AtuQtdProd()
	Atualiza Quantidade Prevista Prod e Quantidade Produção
	@type  Static Function
	@author tamyris.g	
	@since 15/08/2018
	@version 2.0
	MV_AGRO035 -> http://tdn.totvs.com/pages/viewpage.action?pageId=407111530
	/*/
Static Function AtuQtdProd()
	Local aPrdCnj   := {}
	Local aAuxPai   := {} 
	Local aAuxFilho := {} 
	Local aAux      := {} // {Qtd. Prevista, Qtd. Produzida, Dt. Inicial, Dt. Final}
	Local nQtdePrev := 0	

	//Verifica se o grupo de produtos possuí um produto que esta contido em um conjunto
	aPrdCnj := fGetPrdOri()			

	//Se o parametro estiver ativo e a função fGetPrdOri() retornar registros
	If SuperGetMV("MV_AGRO035",.F.,.F.) .AND. !Empty(aPrdCnj)

		//fGetQtdSC2() busca as OP's do produto que dá origem aos demais
		aAuxPai := fGetQtdSC2("", aPrdCnj[1], N8Y->N8Y_SAFRA)

		//Calcula a quantidade prevista de produção do produto relacionado com base no percentual do conjunto
		nQtdePrev := aAuxPai[1] * (aPrdCnj[3] / 100)

		//Obtém a quantidade produzida do produto gerado
		aAuxFilho := fGetQtdSC2(N8Y->N8Y_GRPROD, N8Y->N8Y_CODPRO, N8Y->N8Y_SAFRA)

		//Data mais antiga de inicio das OP's
		dDataIni := aAuxFilho[3]

		//Data mais recente das OP's
		dDataFim := aAuxFilho[4]

		aAux := { nQtdePrev, aAuxFilho[2], dDataIni, dDataFim }

	Else 

		aAux := fGetQtdSC2(N8Y->N8Y_GRPROD, N8Y->N8Y_CODPRO, N8Y->N8Y_SAFRA)

	EndIf

	Return aAux

	/*/{Protheus.doc} AtuQtdRes()
	Atualiza Quantidade Reservada
	@type  Static Function
	@author tamyris.g	
	@since 09/07/2018
	@version 1.0
	/*/
Static Function AtuQtdRes()

	Local nQtde := 0

	//Selecionar reservas 
	cAliasQry  := GetNextAlias()
	cQuery := "SELECT SUM(NJB_QTDPRO) NJB_QTDPRO "
	cQuery += " FROM "+RetSqlName("NJB") + " NJB "

	cQuery += " INNER JOIN " + RetSqlName("NJ2") + " NJ2 "
	cQuery += "   ON NJ2.NJ2_FILIAL = '" + xFilial('NJ2') + "'"
	cQuery += "  AND NJ2.NJ2_TIPRES = NJB.NJB_TIPRES "
	cQuery += "  AND NJ2.NJ2_TIPOOP = '2' "
	cQuery += "  AND NJ2.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "   ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
	cQuery += "  AND SB1.B1_COD =  NJB.NJB_CODPRO"
	cQuery += "  AND SB1.B1_GRUPO =  '" + N8Y->N8Y_GRPROD + "'"
	cQuery += "  AND SB1.D_E_L_E_T_ = '' "

	cQuery += " WHERE NJB_FILIAL = '" + xFilial("NJB") + "'"
	cQuery += "   AND NJB.NJB_CODSAF = '" + N8Y->N8Y_SAFRA + "'"
	cQuery += "   AND NJB.NJB_FILPVN LIKE '" + AllTrim(N8Y->N8Y_FILIAL) + "%'"

	If !Empty(N8Y->N8Y_CODPRO)
		cQuery += "   AND NJB.NJB_CODPRO = '" +  N8Y->N8Y_CODPRO + "' "
	EndIF
	cQuery += "   AND NJB.NJB_STATUS IN ('1')"
	cQuery += "   AND (NJB.NJB_DATVEN = '' OR NJB.NJB_DATVEN >= '" + DToS(dDataBase) + " ') "
	cQuery += "   AND NJB.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		nQtde := (cAliasQry)->NJB_QTDPRO
	EndIf
	(cAliasQry)->(DbcloseArea())

	Return nQtde

	/*/{Protheus.doc} AtuQtdEst()
	Busca as quantidades do produto no estoque SB2/SB8
	@type  Static Function
	@author rafael.kleestadt
	@since 13/07/2018
	@version 1.0
	@param oView, object, objeto da View de dados
	@return nQtdEst, numeric, quantidade do produto no estoque SB2/SB8
	@example
	MV_RASTRO => http://tdn.totvs.com/display/PROT/MV_RASTRO
	@see http://tdn.totvs.com/display/PROT/DT+Planejamento+de+Vendas
	/*/
Static Function AtuQtdEst()
	Local lMvRastro := IIF(SuperGetMv('MV_RASTRO', , .F.) == 'S', .T., .F.)
	Local nQtdEst   := 0

	If !Empty(N8Y->N8Y_CODPRO)

		lCntLtPro := IIF(Posicione("SB1", 1, FwXFilial("SB1")+N8Y->N8Y_CODPRO, "B1_RASTRO") <> 'N', .T., .F.)

		If lMvRastro .And. lCntLtPro
			nQtdEst := QtdSb8(N8Y->N8Y_CODPRO)
		Else
			nQtdEst := QtdSb2(N8Y->N8Y_CODPRO)
		EndIf

	ElseIf !Empty(N8Y->N8Y_GRPROD)

		SB1->(DbSelectArea("SB1"))
		SB1->(DbSetOrder(4))//B1_FILIAL+B1_GRUPO+B1_COD
		If SB1->(DbSeek(FwxFilial("SB1")+N8Y->N8Y_GRPROD))
			While SB1->(!EoF()) .And. SB1->B1_GRUPO == N8Y->N8Y_GRPROD

				lCntLtPro := IIF(Posicione("SB1", 1, FwXFilial("SB1")+SB1->B1_COD, "B1_RASTRO") <> 'N', .T., .F.)

				If lMvRastro .And. lCntLtPro
					nQtdEst += QtdSb8(SB1->B1_COD)
				Else
					nQtdEst += QtdSb2(N8Y->N8Y_CODPRO)
				EndIf

				SB1->(dbSkip())
			EndDo
		EndIf
		SB1->(dbCloseArea())

	EndIf

	Return nQtdEst

	/*/{Protheus.doc} QtdSb8()
	Função para retornar o saldo do produto conforme a safra contida no lote
	@type  Static Function
	@author rafael.kleestadt
	@since 10/07/2018
	@version 1.0
	@param cProduto, Caractere, Código do Produto a ser pesquisado
	@return nQtdEst, numeric, soma da quantidade no estoque do produto
	@example
	MV_AGRO028 => Posição inicial e tamanho do código da Safra dentro do campo lote, EX: '65', Lote:0000018/19 => safra 18/19.
	@see http://tdn.totvs.com/display/PROT/DT+Planejamento+de+Vendas
	/*/
Static Function QtdSb8(cProduto)
	Local nQtdEst   := 0
	Local cSafraLot := SuperGetMv('MV_AGRO028', , .F.)
	Local nIni      := SubStr( cSafraLot, 1, 1 )
	Local nTam      := SubStr( cSafraLot, 2, 1 )
	Local cQuery    := ''
	Local cAliasQry	:= GetNextAlias()

	cQuery := " SELECT SB8.B8_SALDO AS SALDO, SB8.B8_FILIAL AS FILIAL "
	cQuery += "   FROM " + RetSqlName("SB8") + " SB8 "
	cQuery += "  WHERE SB8.B8_PRODUTO = '" + cProduto + "' "
	cQuery += "    AND SUBSTRING(SB8.B8_LOTECTL,"+ nIni +","+ nTam +") = '"+ AllTrim(N8Y->N8Y_SAFRA) +"' "			
	cQuery += "    AND SB8.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	DbselectArea( cAliasQry )
	(cAliasQry)->(DbGoTop())

	While ( cAliasQry )->( !Eof() )

		If SUBSTRING((cAliasQry)->FILIAL,1,Len(AllTrim(N8Y->N8Y_FILIAL))) == AllTrim(N8Y->N8Y_FILIAL)
			nQtdEst += (cAliasQry)->SALDO
		EndIf

		(cAliasQry)->( DbSkip() )
	EndDo
	(cAliasQry)->( DbCloseArea() )

	Return nQtdEst

	/*/{Protheus.doc} QtdSb2()
	Função para retornar o saldo do produto no estoque
	@type  Static Function
	@author rafael.kleestadt
	@since 10/07/2018
	@version 1.0
	@param cProduto, Caractere, Código do Produto a ser pesquisado
	@return nQtdEst, numeric, soma da quantidade no estoque do produto
	@example
	(examples)
	@see http://tdn.totvs.com/display/PROT/DT+Planejamento+de+Vendas
	/*/
Static Function QtdSb2(cProduto)
	Local nQtdEst   := 0
	Local cQuery    := ''
	Local cAliasQry	:= GetNextAlias()

	cQuery := " SELECT SB2.B2_QATU AS SALDO,  SB2.B2_FILIAL AS FILIAL"
	cQuery += "   FROM " + RetSqlName("SB2") + " SB2 "
	cQuery += "  WHERE SB2.B2_COD = '" + cProduto + "' "			
	cQuery += "    AND SB2.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	DbselectArea( cAliasQry )
	(cAliasQry)->(DbGoTop())

	While ( cAliasQry )->( !Eof() )

		If SUBSTRING((cAliasQry)->FILIAL,1,Len(AllTrim(N8Y->N8Y_FILIAL))) == AllTrim(N8Y->N8Y_FILIAL)
			nQtdEst += (cAliasQry)->SALDO
		EndIf

		(cAliasQry)->( DbSkip() )
	EndDo
	(cAliasQry)->( DbCloseArea() )

	Return nQtdEst


	/*/{Protheus.doc} AtuQtdFat()
	Atualiza Quantidade Faturada
	@type  Static Function
	@author tamyris.g	
	@since 12/07/2018
	@version 1.0
	/*/
Static Function AtuQtdFat()

	Local nQtde := 0

	//Selecionar reservas 
	cAliasQry  := GetNextAlias()
	cQuery := "SELECT SUM(N9A_QTDNF) N9A_QTDNF "
	cQuery += " FROM "+RetSqlName("N9A") + " N9A "

	cQuery += " INNER JOIN " + RetSqlName("NJR") + " NJR "
	cQuery += "   ON NJR.NJR_FILIAL = '" + xFilial('NJR') + "'"
	cQuery += "  AND NJR.NJR_CODCTR =  N9A.N9A_CODCTR"
	cQuery += "  AND NJR.NJR_CODSAF = '" + N8Y->N8Y_SAFRA + "'"
	If !Empty(N8Y->N8Y_CODPRO)
		cQuery += "   AND NJR.NJR_CODPRO = '" +  N8Y->N8Y_CODPRO + "' "
	EndIF
	cQuery += "  AND NJR.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "   ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
	cQuery += "  AND SB1.B1_COD =  NJR.NJR_CODPRO"
	cQuery += "  AND SB1.B1_GRUPO =  '" + N8Y->N8Y_GRPROD + "'"
	cQuery += "  AND SB1.D_E_L_E_T_ = '' "

	cQuery += " WHERE N9A_FILIAL = '" + xFilial("N9A") + "'"
	cQuery += "   AND N9A.N9A_FILORG LIKE '" + AllTrim(N8Y->N8Y_FILIAL) + "%'"

	cQuery += "   AND N9A.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		nQtde := (cAliasQry)->N9A_QTDNF
	EndIf
	(cAliasQry)->(DbcloseArea())

	Return nQtde

	/*/{Protheus.doc} AtuQtPrVen()
	Atualiza Quantidade Planejada a Vender e a Receber
	@type  Static Function
	@author tamyris.g	
	@since 12/07/2018
	@version 1.0
	/*/
Static Function AtuQtPrVen(aVolDisp)

	Local nVrIndice := 0

	dbSelectArea("N8W")
	N8W->(dbSetOrder(1))
	If N8W->(dbSeek(N8Y->N8Y_FILIAL+N8Y->N8Y_CODPLA))
		While N8W->(!EOF()) .And. N8W->(N8W_FILIAL+N8W_CODPLA) == N8Y->(N8Y_FILIAL+N8Y_CODPLA)

			//Busca taxa de conversão para períodos não vencidos
			nVrIndice := 0
			If N8W->N8W_DTINIC >= FirstDate(dDataBase) .And. !Empty(__cIndPla)
				//pegar o índice conforme a moeda do plano
				nVrIndice := getVlIndic(__cIndPla)
			EndIf

			RecLock("N8W",.F.)
			If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
				N8W->N8W_QTPRVE := N8Y->N8Y_QTDCOM * N8W->N8W_PERVEN / 100
				N8W->N8W_SLDVEN := N8W->N8W_QTPRVE - N8W->N8W_QTDVEN
			Else
				N8W->N8W_QTPRRE := N8Y->N8Y_QTDCOM * N8W->N8W_PERREC / 100
				N8W->N8W_SLDREC := N8W->N8W_QTPRRE - N8W->N8W_QTDREC
			EndIF
			If nVrIndice <> 0
				N8W->N8W_TAXCON := nVrIndice
			EndIF
			N8W->(MsUnlock())

			N8W->(dbSkip())
		EndDo
	EndIf
	N8W->(DbcloseArea())

	Return .T.


	/*/{Protheus.doc} AtuPrcPV()
	Atualiza Preços da posição "A Vender Faturamento" do Plano de Vendas
	@type  Static Function
	@author tamyris.g	
	@since 12/07/2018
	@version 1.0
	/*/
Static Function AtuPrcPV()

	Private aComp := {} //{ {Componente, Valor}, {Componente, Valor} }

	dbSelectArea("N8W")
	N8W->(dbSetOrder(1))
	If N8W->(dbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA ))
		While N8W->(!EOF()) .And. N8W->(N8W_FILIAL + N8W_CODPLA) == N8Y->(N8Y_FILIAL + N8Y_CODPLA) 

			//Não recalcula períodos vencidos	
			If N8W->N8W_DTINIC >= FirstDate(dDataBase)
				aComp := {}
				calcPrcComp()
			EndIF

			N8W->(dbSkip())
		EndDo
	EndIf
	N8W->(DbcloseArea())


Return .T.

/*{Protheus.doc} calcPrcComp
Cálcula os valores dos componentes
@author tamyris.g
@since 25/07/2018
@version undefined
@param oModel, object, descricao
@param cUmPrc, characters, descricao
@param c1aUmPrd, characters, descricao
@type function
*/
Static Function calcPrcComp()

	//Calcula componentes diferente de Resultado
	N8Z->(DbSelectArea("N8Z"))
	N8Z->(DbSetOrder(1))//N8Z_FILIAL+N8Z_SAFRA+N8Z_GRPROD+N8Z_CODPRO+N8Z_TIPMER+N8Z_MOEDA
	If N8Z->(DbSeek(xFilial("N8Z")+N8W->(N8W_SAFRA+N8W_GRPROD+N8W_CODPRO+N8W_TIPMER) + PadR(Alltrim(Str(N8W->N8W_MOEDA)),TamSx3('N8Z_MOEDA')[1] ) ))
		While N8Z->(!EOF()) .And. N8Z->N8Z_FILIAL == xFilial("N8Z") .And. ;
		N8Z->(N8Z_SAFRA+N8Z_GRPROD+N8Z_CODPRO+N8Z_TIPMER) == N8W->(N8W_SAFRA+N8W_GRPROD+N8W_CODPRO+N8W_TIPMER) .And. ;
		N8Z->N8Z_MOEDA == N8W->N8W_MOEDA

			IF !N8Z->N8Z_CALCUL $ "R|T" //Se Tipo de Cálculo NÃO for RESULTADO ou TRIBUTOS
				nVlPrc := OGX820LNCP()
				aAdd(aComp, {N8Z->N8Z_CODCOM , nVlPrc, N8Z->N8Z_UNIMED, N8Z->N8Z_MOEDA } )
			EndIf

			N8Z->(dbSkip())
		EndDo
	EndIf

	//Calcula componentes do Tipo Resultado, após calcular os demais componentes
	N8Z->(DbSelectArea("N8Z"))
	N8Z->(DbSetOrder(2))//N8Z_FILIAL+N8Z_SAFRA+N8Z_GRPROD+N8Z_CODPRO+N8Z_TIPMER+N8Z_MOEDA+N8Z_ORDEM
	If N8Z->(DbSeek(xFilial("N8Z")+N8W->(N8W_SAFRA+N8W_GRPROD+N8W_CODPRO+N8W_TIPMER) + PadR(Alltrim(Str(N8W->N8W_MOEDA)),TamSx3('N8Z_MOEDA')[1] ) ))
		While N8Z->(!EOF()) .And. N8Z->N8Z_FILIAL == xFilial("N8Z") .And. ;
		N8Z->(N8Z_SAFRA+N8Z_GRPROD+N8Z_CODPRO+N8Z_TIPMER) == N8W->(N8W_SAFRA+N8W_GRPROD+N8W_CODPRO+N8W_TIPMER) .And. ;
		N8Z->N8Z_MOEDA == N8W->N8W_MOEDA

			IF N8Z->N8Z_CALCUL $ "R|T" //Se Tipo de Cálculo for RESULTADO ou TRIBUTOS

				nVlPrc := OGX820CTPP()

				aAdd(aComp, {N8Z->N8Z_CODCOM , nVlPrc, N8Z->N8Z_UNIMED, N8Z->N8Z_MOEDA } )

				/*Se preço Negociado ou Demonstrativo*/
				cTpPrc := Posicione("NK7", 1, xFilial("NK7") + N8Z->N8Z_CODCOM, "NK7_TIPPRC")

				If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
					If cTpPrc == '2' //Negociado
						RecLock("N8W",.F.)
						N8W->N8W_VLUPFI := nVlPrc
						N8W->N8W_VUPFI2 := IIF(N8Y->N8Y_MOEDA == 1,nVlPrc,convMoedPl(nVlPrc, N8Y->N8Y_MOEDA, 2) )
						N8W->N8W_VLTPFI := Round(N8W->N8W_VLUPFI * N8W->N8W_SLDVEN, TamSX3( "N8W_VLUPFI" )[2] )
						N8W->N8W_VTPFI2 := Round(N8W->N8W_VUPFI2 * N8W->N8W_SLDVEN, TamSX3( "N8W_VLUPFI" )[2] )
						N8W->(MsUnlock())
					ElseIF cTpPrc == '3' //Demonstrativo
						RecLock("N8W",.F.)
						N8W->N8W_VLUPDE := nVlPrc
						N8W->N8W_VUPDE2 := IIF(N8Y->N8Y_MOEDA == 1,nVlPrc,convMoedPl(nVlPrc, N8Y->N8Y_MOEDA, 2) )   
						N8W->N8W_VLTPDE := Round(N8W->N8W_VLUPDE * N8W->N8W_SLDVEN, TamSX3( "N8W_VLTPDE" )[2] )                                        
						N8W->N8W_VTPDE2 := Round(N8W->N8W_VUPDE2 * N8W->N8W_SLDVEN, TamSX3( "N8W_VLTPDE" )[2] )                                       
						N8W->(MsUnlock())
					EndIf
				Else //Base Financeiro
					If cTpPrc == '2' //Negociado
						RecLock("N8W",.F.)
						N8W->N8W_VPRUF1 := nVlPrc
						N8W->N8W_VPRUF2 := IIF(N8Y->N8Y_MOEDA == 1,nVlPrc,convMoedPl(nVlPrc, N8Y->N8Y_MOEDA, 2) )
						N8W->N8W_VPRTF1 := Round(N8W->N8W_VPRUF1 * N8W->N8W_SLDREC, TamSX3( "N8W_VPRUF1" )[2] )
						N8W->N8W_VPRTF2 := Round(N8W->N8W_VPRUF2 * N8W->N8W_SLDREC, TamSX3( "N8W_VPRUF2" )[2] )
						N8W->(MsUnlock())
					ElseIF cTpPrc == '3' //Demonstrativo
						RecLock("N8W",.F.)
						N8W->N8W_VPRUD1 := nVlPrc
						N8W->N8W_VPRUD2 := IIF(N8Y->N8Y_MOEDA == 1,nVlPrc,convMoedPl(nVlPrc, N8Y->N8Y_MOEDA, 2) )   
						N8W->N8W_VPRTD1 := Round(N8W->N8W_VPRUD1 * N8W->N8W_SLDREC, TamSX3( "N8W_VPRUD1" )[2] )                                        
						N8W->N8W_VPRTD2 := Round(N8W->N8W_VPRUD2 * N8W->N8W_SLDREC, TamSX3( "N8W_VPRUD2" )[2] )                                        
						N8W->(MsUnlock())
					EndIf
				EndIF
			EndIf

			N8Z->(dbSkip())
		EndDo
	EndIf

	N8Z->(DbCloseArea())

Return .T.

/*{Protheus.doc} OGX820LNCP
Cálcula a linha do componente - baseado no OGX400LNCP
@author tamyris.g
@since 25/07/2018
@version undefined
@param oModel, object, descricao
@param cUmPrc, characters, descricao
@param c1aUmPrd, characters, descricao
@type function
*/
Static Function  OGX820LNCP(cUmPrc,c1aUmPrd, cProduto) 
	Local nValor := 0


	nCont := 0
	cAliasQry2  := GetNextAlias()
	cQuery2 := "SELECT NCV_VALOR  "
	cQuery2 += " FROM " + RetSqlName("NCV") + " NCV "
	cQuery2 += " WHERE NCV.NCV_FILIAL  = '" + xFilial("NCV") + "' "
	cQuery2 += "   AND NCV.NCV_SAFRA  = '" + N8Z->N8Z_SAFRA + "' "
	cQuery2 += "   AND NCV.NCV_GRPROD = '" + N8Z->N8Z_GRPROD + "' "
	cQuery2 += "   AND NCV.NCV_CODPRO = '" + N8Z->N8Z_CODPRO + "' "
	cQuery2 += "   AND NCV.NCV_TIPMER = '" + N8Z->N8Z_TIPMER + "' "
	cQuery2 += "   AND NCV.NCV_MOEDA  = '" + AllTrim(Str(N8Z->N8Z_MOEDA)) + "' "
	cQuery2 += "   AND NCV.NCV_CODCOM = '" + N8Z->N8Z_CODCOM + "' "
	cQuery2 += "   AND (NCV.NCV_FILCOM = '' OR NCV.NCV_FILCOM LIKE '" + AllTrim(N8W->N8W_FILIAL) + "%' )"
	cQuery2 += "   AND NCV.NCV_DATVIG <= '" + DtoS(N8W->N8W_DTFINA) + "' "
	cQuery2 += "   AND NCV.D_E_L_E_T_ = '' "
	cQuery2 += " ORDER BY NCV_DATVIG DESC, NCV_FILCOM DESC "
	cQuery2 := ChangeQuery(cQuery2)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQry2,.F.,.T.)

	dbSelectArea(cAliasQry2)
	(cAliasQry2)->(dbGoTop())
	If (cAliasQry2)->(!Eof() )
		nValor := (cAliasQry2)->NCV_VALOR
	EndIf
	(cAliasQry2)->(DbcloseArea())

	nVrIndice := getVlIndic(N8Z->N8Z_INDICE)

	//Converte os valores conforme Unidade de Medida do Item e Moeda Corrente
	If N8Z->N8Z_CALCUL $ "T"
		If !Empty(N8Z->N8Z_PERAPL)
			nValor := nValor *  (N8Z->N8Z_PERAPL / 100)
		EndIF
	Else
		nValor := ConvVlItPl(nValor)
	EndIf

return nValor

/*{Protheus.doc} OGX820CTPP
Atualiza os valores dos campos totalizadores
@author tamyris.g	
@since 25/07/2018
@version undefined
@param 
@type function
*/
Static Function OGX820CTPP() //totalizar os componentes de resultado

	Local nValorComp := 0
	Local nPos       := 0
	Local nValor     := 0

	//procurar na N75 - verificar necessidade de converter os valores (Uniddade de Medida e Moeda)
	DbselectArea( "N75" )
	DbSetOrder( 1 )
	DbGoTop()
	If dbSeek( xFilial( "N75" ) +  N8Z->N8Z_CODCOM )
		While !N75->( EoF() ) .And. N75->( N75_FILIAL + N75_CODCOM ) == xFilial( "N75" ) + N8Z->N8Z_CODCOM

			//Procura o componente
			nPos := aScan( aComp, { |x| AllTrim( x[1] ) == AllTrim(N75->(N75_CODCOP) ) } )
			//seekline
			if nPos > 0
				nValorComp := aComp[npos][2] 
				nValor += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorComp //fazer tratamento de unidade de medida
			endif

			N75->( dbSkip() )
		enddo
	endif   

	/* Se o componente tiver um % de aplicação, o valor calculado deverá ser reduzido para o % de aplicação informado */ 
	/* Ex.: % Aplicação: 40%, valor calculado do componente = 1,00, valor final 1 * 40/100 = 0,40. */
	If !Empty(N8Z->N8Z_PERAPL)
		nValor := nValor *  (N8Z->N8Z_PERAPL / 100)
	EndIF

return nValor

/*{Protheus.doc} ConvVlItPl
Converte os valores conforme Unidade de Medida e Moeda do Item do Plano de Vendas
@author tamyris.g	
@since 25/07/2018
@version undefined
@param 
@type function
*/
Static Function ConvVlItPl(nValor)

	Local nDecCompon := TamSx3('N7C_VLRCOM')[2]

	/*Calcula os valores, conforme a unidade de medida do plano*/
	If N8Z->N8Z_UNIMED <> __cUnMedPla //Se as unidades de medida forem diferentes
		nValor := Round(OGX700UMVL(nValor,N8Z->N8Z_UNIMED,__cUnMedPla,__cCodPro) ,nDecCompon ) //preco
	EndIF

	//Converte os valores para a moeda corrente
	If N8Z->N8Z_MOEDA2 <> 1
		nValor:= convMoedPl(nValor, N8Z->N8Z_MOEDA2, 1 )
	EndIF 

	/* Se o componente tiver um % de aplicação, o valor calculado deverá ser reduzido para o % de aplicação informado */ 
	/* Ex.: % Aplicação: 40%, valor calculado do componente = 1,00, valor final 1 * 40/100 = 0,40. */
	If !Empty(N8Z->N8Z_PERAPL)
		nValor := nValor *  (N8Z->N8Z_PERAPL / 100)
	EndIF

	Return nValor

	/*/{Protheus.doc} convMoedPl()
	Converte Valores de/para Moeda Corrente
	@type  Static Function
	@author tamyris.g	
	@since 09/08/2018
	@param nValOri valor que será convertido
	@param cMoedaExt moeda externa
	@param nOpc 1-Moeda Externa para corrente. 2-Moeda corrente para externa
	@version 1.0
	/*/
Static Function convMoedPl(nValOri, cMoedaExt, nOpc)

	Local nValor     := 0
	Local nTaxaConv  := 0
	Local cIndice    := ""
	Local nDecCompon := TamSx3('N8W_VLUPDE')[2] //casa decimais componentes

	//Se for a Moeda do plano usa a taxa de conversão gravada
	If cMoedaExt == N8Y->N8Y_MOEDA 
		nTaxaConv := N8W->N8W_TAXCON
	Else
		//Senão, verifica se a moeda informada possui índice 
		cIndice := getIndMoed(cMoedaExt)

		//Caso tenha índice, busca o valor do mesmo 
		If !Empty(cIndice)
			nTaxaConv := getVlIndic(cIndice)
		EndIF
	EndIF

	If !Empty(nTaxaConv) /*TEM TAXA DE CONVERSÃO*/
		// 1- Moeda Externa para Corrente - divide o valor pela taxa
		// 2- Moeda Corrente para Externa - multiplica o valor pela taxa 
		nValor := IIf(nOpc == 1, nValOri * nTaxaConv, nValOri / nTaxaConv )
	Else //Senão, realiza a conversão padrão do protheus

		IF nOpc == 1 //Moeda Externa para corrente
			nValor := xMoeda(nValOri, cMoedaExt, 1 , N8W->N8W_DTFINA , nDecCompon)
		Else //Moeda corrente para externa
			nValor := xMoeda(nValOri, 1 , cMoedaExt, N8W->N8W_DTFINA , nDecCompon)
		EndIF
	EndIF
	Return nValor

	/*/{Protheus.doc} AtuQtdRec()
	Atualiza Qtd Prev a Receber conforme condições de Pagamento
	@type  Static Function
	@author tamyris.g	
	@since 09/08/2018
	@version 1.0
	/*/
Static Function AtuQtdRec()

	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local cQuery2    := ""
	Local cAliasQry2 := GetNextAlias()

	cQuery := "SELECT N8W_FILIAL, N8W_GRPROD, N8W_CODPRO, N8W_TIPMER, N8W_MOEDA, N8W_DTINIC, NCU_MESANO, " 
	If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
		cQuery += " N8W_VLUPFI, N8W_VUPFI2, N8W_VLUPDE, N8W_VUPDE2, (N8W_QTPRVE * NCU_PERREC) AS QTDREC " 
	Else
		cQuery += " N8W_VPRUF1, N8W_VPRUF2, N8W_VPRUD1, N8W_VPRUD2, (N8W_QTPRRE * NCU_PERREC) AS QTDREC "
	EndIf
	cQuery += " FROM "+RetSqlName("N8W") + " N8W "
	cQuery += " INNER JOIN "+RetSqlName("NCU") + " NCU "
	//Lê todas as condições de recebimento do plano de vendas
	cQuery += "    ON NCU.D_E_L_E_T_ = '' "
	cQuery += "   AND NCU.NCU_FILIAL = N8W.N8W_FILIAL "
	cQuery += "   AND NCU.NCU_CODPLA = N8W.N8W_CODPLA "
	cQuery += "   AND NCU.NCU_SEQITE = N8W.N8W_SEQITE "
	//Lê todos os itens do plano de vendas
	cQuery += " WHERE N8W.D_E_L_E_T_ = '' "
	cQuery += "   AND N8W.N8W_FILIAL = '" + N8Y->N8Y_FILIAL + "'"
	cQuery += "   AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA  + "'"  
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		While .Not. (cAliasQry)->( Eof() ) 

			dDataIni := SToD((cAliasQry)->N8W_DTINIC)

			cMes := SubStr((cAliasQry)->NCU_MESANO,1,2)
			cAno := SubStr((cAliasQry)->NCU_MESANO,4,4)
			dDataIni := StoD(cAno+cMes+'01')

			//Encontra o item do plano de vendas correspondente para atualizar a Qtde Recebimento
			cQuery2 := "SELECT N8W.R_E_C_N_O_ AS N8W_RECNO"
			cQuery2 += " FROM "+RetSqlName("N8W") + " N8W "
			cQuery2 += " WHERE N8W.D_E_L_E_T_ = '' "
			cQuery2 += "   AND N8W.N8W_FILIAL = '" + N8Y->N8Y_FILIAL + "'"
			cQuery2 += "   AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA  + "'" 
			cQuery2 += "   AND N8W.N8W_GRPROD = '" + (cAliasQry)->N8W_GRPROD + "' "
			cQuery2 += "   AND N8W.N8W_CODPRO = '" + (cAliasQry)->N8W_CODPRO + "' "
			cQuery2 += "   AND N8W.N8W_TIPMER = '" + (cAliasQry)->N8W_TIPMER  + "' "
			cQuery2 += "   AND N8W.N8W_MOEDA  = "  + AllTrim(Str((cAliasQry)->N8W_MOEDA)) + " "
			cQuery2 += "   AND N8W.N8W_DTINIC = '" + DtoS(dDataIni) + "' "

			cQuery2 := ChangeQuery( cQuery2 )

			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2), cAliasQry2,.T.,.T.)

			dbSelectArea(cAliasQry2)
			(cAliasQry2)->(dbGoTop())
			If (cAliasQry2)->(!Eof() )

				nValor := (cAliasQry)->QTDREC / 100

				dbSelectArea("N8W")
				N8W->(dbGoTop())
				N8W->(DbGoTo( (cAliasQry2)->N8W_RECNO ))

				RecLock("N8W",.F.)
				If N8Y->N8Y_TIPVOL == "1" //Base Faturamento

					N8W->N8W_QTPRRE += nValor
					N8W->N8W_SLDREC := N8W->N8W_QTPRRE
					/*Valores Demosntrativo*/
					N8W->N8W_VPRTD1 += nValor * (cAliasQry)->N8W_VLUPDE
					N8W->N8W_VPRTD2 += nValor * (cAliasQry)->N8W_VUPDE2
					/*Valores Financeiro*/
					N8W->N8W_VPRTF1 += nValor * (cAliasQry)->N8W_VLUPFI
					N8W->N8W_VPRTF2 += nValor * (cAliasQry)->N8W_VUPFI2

					/*Calcula valores unitários com base no total / qtde previsto */
					If N8W->N8W_QTPRRE <> 0
						/*Valores Demosntrativo*/
						N8W->N8W_VPRUD1 := N8W->N8W_VPRTD1 / N8W->N8W_QTPRRE
						N8W->N8W_VPRUD2 := N8W->N8W_VPRTD2 / N8W->N8W_QTPRRE
						/*Valores Financeiro*/
						N8W->N8W_VPRUF1 := N8W->N8W_VPRTF1 / N8W->N8W_QTPRRE
						N8W->N8W_VPRUF2 := N8W->N8W_VPRTF2 / N8W->N8W_QTPRRE
					EndIF
				Else //Base Financeiro
					N8W->N8W_QTPRVE += nValor
					N8W->N8W_SLDVEN := N8W->N8W_QTPRVE
					/*Valores Demosntrativo*/
					N8W->N8W_VLTPDE += nValor * (cAliasQry)->N8W_VPRUD1
					N8W->N8W_VTPDE2 += nValor * (cAliasQry)->N8W_VPRUD2
					/*Valores Financeiro*/
					N8W->N8W_VLTPFI += nValor * (cAliasQry)->N8W_VPRUF1
					N8W->N8W_VTPFI2 += nValor * (cAliasQry)->N8W_VPRUF2

					/*Calcula valores unitários com base no total / qtde previsto */
					If N8W->N8W_QTPRVE <> 0
						/*Valores Demosntrativo*/
						N8W->N8W_VLUPDE := N8W->N8W_VLTPDE / N8W->N8W_QTPRVE
						N8W->N8W_VUPDE2 := N8W->N8W_VTPDE2 / N8W->N8W_QTPRVE
						/*Valores Financeiro*/
						N8W->N8W_VLUPFI := N8W->N8W_VLTPFI / N8W->N8W_QTPRVE
						N8W->N8W_VUPFI2 := N8W->N8W_VTPFI2 / N8W->N8W_QTPRVE
					EndIF

				EndIF

				N8W->(MsUnlock())
				N8W->(DbcloseArea())

			EndIF

			(cAliasQry2)->(DbcloseArea()) 

			(cAliasQry)->( dbSkip() )
		EndDo

	EndIf
	(cAliasQry)->(DbcloseArea())					
	Return 


	/*/{Protheus.doc} AtuQtdVen()
	Atualiza Quantidade Vendida do Plano de Vendas
	@type  Static Function
	@author tamyris.g	
	@since 12/07/2018
	@version 1.0
	/*/
Static Function AtuQtdVen()

	Local cQuery  := ""
	Local cAliasQry  := GetNextAlias()
	Local cAliasN9K	 := GetNextAlias()
	Local cAliasN9J  := GetNextAlias()
	Local cAliasNJM  := GetNextAlias()

	cGrupo   := Posicione('SB1', 1, xFilial('SB1') + N8Y->N8Y_CODPRO, 'B1_GRUPO')

	cQuery := " SELECT * FROM " + RetSqlName('N9A') + " N9A "
	cQuery += " INNER JOIN " + RetSqlName('NJR') + " NJR ON N9A_CODCTR = NJR_CODCTR AND NJR.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON SB1.B1_COD = NJR.NJR_CODPRO AND SB1.B1_GRUPO = '" + N8Y->N8Y_GRPROD + "' AND SB1.D_E_L_E_T_ = '' " 

	cQuery += " WHERE N9A.D_E_L_E_T_ = ''   "
	cQuery += "   AND N9A.N9A_FILORG LIKE '" + AllTrim(N8Y->N8Y_FILIAL) + "%'"
	cQuery += "   AND NJR.NJR_CODSAF = '" + N8Y->N8Y_SAFRA + "'"
	If !empty(N8Y->N8Y_CODPRO)
		cQuery += "  AND NJR.NJR_CODPRO = '" + N8Y->N8Y_CODPRO + "'"
	EndIf
	cQuery += "  AND NJR.NJR_TIPO   = 	'2' " //Vendas
	cQuery += "  AND NJR.NJR_MODELO = 	'2' " //Contrato
	cQuery += "  AND NJR.NJR_STATUS <> 	'E' " //Cancelado
	cQuery += "  AND N9A.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
	DbSelectArea( cAliasQry ) 
	While (cAliasQry)->(!Eof())

		/* Atualiza Quantidade Vendida*/

		//Data Prevista
		cDataIni := Posicione('NNY', 1, xFilial('NNY') + (cAliasQry)->N9A_CODCTR  + (cAliasQry)->N9A_ITEM, 'NNY_DATFIM')

		//Se tem quantidade faturada, a qtd vendida deve ser atualizada de acordo com a data faturamento
		IF (cAliasQry)->N9A_QTDNF <> 0 

			cMesAno := ""
			BeginSql Alias cAliasNJM
				SELECT *  FROM %table:NJM% NJM
				WHERE NJM_FILIAL  = %Exp:(cAliasQry)->N9A_FILORG%
				AND NJM_CODCTR  = %Exp:(cAliasQry)->NJR_CODCTR%
				AND NJM_ITEM    = %Exp:(cAliasQry)->N9A_ITEM%
				AND NJM_SEQPRI  = %Exp:(cAliasQry)->N9A_SEQPRI%	 
				AND NJM.%notDel%
			EndSQL

			DbSelectArea( cAliasNJM )		
			(cAliasNJM)->( dbGoTop() )
			IF .Not. (cAliasNJM)->( Eof( ) )
				While (cAliasNJM)->(!Eof())

					nQuant := 0
					DbSelectArea("NJJ")
					NJJ->(DbSetOrder(1)) // NJJ_FILIAL+NJJ_CODROM
					If NJJ->(DbSeek((cAliasNJM)->NJM_FILIAL+(cAliasNJM)->NJM_CODROM))		
						If NJJ->NJJ_TIPO $ "6|7|8|9" // Devoluções
							nQuant -= (cAliasNJM)->NJM_QTDFIS
						Else
							nQuant += (cAliasNJM)->NJM_QTDFIS
						EndIf							
					EndIf

					GetN8W(cAliasQry,1,nQuant,LastDay(StoD((cAliasNJM)->NJM_DOCEMI)),nQuant )

					(cAliasNJM)->(DbSkip())
				EndDo
			EndIF
			(cAliasNJM)->(dbCloseArea())

			//Se ainda tem saldo não faturado
			If (cAliasQry)->N9A_QUANT > (cAliasQry)->N9A_QTDNF

				//Envia somente o que não tem nota
				nQuant := (cAliasQry)->N9A_QUANT - (cAliasQry)->N9A_QTDNF

				//Se período ainda não ocorreu, é atualizado na data prevista
				If cDataIni >= dDataBase
					GetN8W(cAliasQry,1,nQuant,cDataIni)
				Else //Senão, é atualizado no mês corrente
					GetN8W(cAliasQry,1,nQuant,LastDay(dDataBase))
				EndIF
			EndIF

		Else //Se nada foi faturado

			nQuant  := (cAliasQry)->N9A_QUANT

			//Se período ainda não ocorreu, é atualizado na data prevista
			If cDataIni >= dDataBase
				GetN8W(cAliasQry,1,nQuant,cDataIni)
			Else //Senão, é atualizado no mês corrente
				GetN8W(cAliasQry,1,nQuant,LastDay(dDataBase))
			EndIF
		EndIF

		/*Atualiza as previsões financeiras*/
		dbSelectArea("NN7")
		NN7->(dbGoTop())
		NN7->( dbSetOrder( 1 ) )
		NN7->( dbSeek( xFilial( "NN7" ) + (cAliasQry)->( NJR_CODCTR ) ) )
		While .Not. NN7->( Eof() ) .And. NN7->NN7_FILIAL = xFilial("NN7") .And. NN7->NN7_CODCTR = (cAliasQry)->NJR_CODCTR

			IF NN7->NN7_TIPEVE == '1'
				BeginSql Alias cAliasN9K
					SELECT SUM(N9K_QTDVNC) AS N9K_QTDVNC
					FROM %table:N9K% N9K
					WHERE N9K_FILORI  = %Exp:(cAliasQry)->NJR_FILIAL%
					AND N9K_CODCTR  = %Exp:(cAliasQry)->NJR_CODCTR%
					AND N9K_ITEMPE  = %Exp:(cAliasQry)->N9A_ITEM%
					AND N9K_ITEMRF  = %Exp:(cAliasQry)->N9A_SEQPRI%	 
					AND N9K_SEQPF   = %Exp:NN7->NN7_ITEM% 
					AND N9K.%notDel%
				EndSQL

				DbSelectArea( cAliasN9K )		
				(cAliasN9K)->( dbGoTop() )
				IF .Not. (cAliasN9K)->( Eof( ) )
					nTotQtd := (cAliasN9K)->N9K_QTDVNC
				EndIF
				(cAliasN9K)->(dbCloseArea())		
			Else
				BeginSql Alias cAliasN9J
					SELECT SUM(N9J_QTDE - N9J_QTDEVT ) AS N9J_QTDE  
					FROM %table:N9J% N9J
					WHERE N9J_FILIAL  = %Exp:(cAliasQry)->NJR_FILIAL%
					AND N9J_CODCTR  = %Exp:(cAliasQry)->NJR_CODCTR%
					AND N9J_ITEMPE  = %Exp:(cAliasQry)->N9A_ITEM%
					AND N9J_ITEMRF  = %Exp:(cAliasQry)->N9A_SEQPRI%
					AND N9J_SEQPF   = %Exp:NN7->NN7_ITEM%	      
					AND N9J.%notDel%
				EndSQL

				DbSelectArea( cAliasN9J )		
				(cAliasN9J)->( dbGoTop() )
				IF .Not. (cAliasN9J)->( Eof( ) )
					nTotQtd := (cAliasN9J)->N9J_QTDE
				EndIF
				(cAliasN9J)->(dbCloseArea())
			EndIf

			GetN8W(cAliasQry,2,nTotQtd,NN7->NN7_DTVENC)

			NN7->( dbSkip() )
		EndDo

		/* Se não localizar nenhum, ignorar */
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->( dbCloseArea() )

	Return .T.

	/*/{Protheus.doc} GetN8W()
	Busca o item do plano de venda correspondente ao contrato para atualização
	@type  Static Function
	@author tamyris.g	
	@since 14/09/2018
	@version 1.0
	/*/	
Function GetN8W(cAliasQry,nTipo,nQuant,cDataIni,nQtdNF)
	Local cQuery2 := ""
	Local cAliasQry2 := GetNextAlias()

	Local lTemReg := .F.
	Local nTotal := 0
	Local cPeriodo  := ""

	Default nQtdNF  := 0

	/* Tenta enquadrar a venda nos itens do plano */
	cPeriodo := ""
	nTotal := 0

	/*Conversão para unidade de medida do plano*/
	nQuant  := ConvUnMed(nQuant ,1,__cCodPro,TamSx3('N8W_QTDVEN')[2]) 
	nQtdNF  := ConvUnMed(nQtdNF ,1,__cCodPro,TamSx3('N8W_QTDFAT')[2])

	//Busca item do plano de vendas com mesmo produto / grupo de produto / mercado e moeda
	cQueryAux := "SELECT  N8W.R_E_C_N_O_ AS N8W_RECNO, N8W_QTPRVE, N8W_MESANO, N8W_CODREG, N8W_FILIAL "
	cQueryAux += " FROM "+RetSqlName("N8W") + " N8W "
	cQueryAux += " WHERE  N8W.D_E_L_E_T_ = '' "
	cQueryAux += "   AND N8W.N8W_FILIAL = '" + N8Y->N8Y_FILIAL + "'"
	cQueryAux += "   AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA + "'"
	cQueryAux += "   AND N8W.N8W_TIPMER = '" + (cAliasQry)->NJR_TIPMER + "'" 
	cQueryAux += "   AND N8W.N8W_MOEDA  = "  + Alltrim(str(fBmoedapv(N8Y->N8Y_MOEDA , (cAliasQry)->NJR_MOEDA))) 
	//Data inicial da entrega para localizar o período
	cQueryIni := "   AND N8W.N8W_DTINIC  <= '" + DtoS(cDataIni)  + "'"
	cQueryFim := "   AND N8W.N8W_DTFINA  >= '" + DToS(cDataIni)  + "'"

	/**Realiza a primeira busca completa               --------------*/
	cQuery2 := cQueryAux + cQueryIni + cQueryFim
	cQuery2 := ChangeQuery( cQuery2 )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2), cAliasQry2,.T.,.T.)
	dbSelectArea(cAliasQry2)
	(cAliasQry2)->(dbGoTop())
	If (cAliasQry2)->(!Eof() )
		lTemReg := .T.

		AtuN8W(nTipo,(cAliasQry2)->N8W_RECNO,nQuant,nQtdNF,fBmoedapv(N8Y->N8Y_MOEDA , (cAliasQry)->NJR_MOEDA), (cAliasQry)->NJR_TIPMER)

	EndIf
	(cAliasQry2)->(DbcloseArea())

	/**Se não encontrou, verifica se tem a filial no plano e cria o item no período corrente*/ 
	If !lTemReg
		cQuery2 := cQueryAux 
		cQuery2 := ChangeQuery( cQuery2 )

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2), cAliasQry2,.T.,.T.)
		dbSelectArea(cAliasQry2)
		(cAliasQry2)->(dbGoTop())
		If (cAliasQry2)->(!Eof() )
			lTemReg := .T.

			cSeqIte :=  GetSXENum("N8W","N8W_SEQITE")
			ConfirmSX8()	

			RecLock("N8W",.T.)
			N8W->N8W_SEQITE := cSeqIte
			N8W->N8W_FILIAL := N8Y->N8Y_FILIAL
			N8W->N8W_SAFRA  := N8Y->N8Y_SAFRA 
			N8W->N8W_CODPLA := N8Y->N8Y_CODPLA
			N8W->N8W_DTATUA := N8Y->N8Y_DTATUA 
			N8W->N8W_HRATUA := N8Y->N8Y_HRATUA
			N8W->N8W_GRPROD := N8Y->N8Y_GRPROD
			N8W->N8W_CODPRO := N8Y->N8Y_CODPRO
			N8W->N8W_TIPMER := (cAliasQry)->NJR_TIPMER
			N8W->N8W_MOEDA  := fBmoedapv (N8Y->N8Y_MOEDA, (cAliasQry)->NJR_MOEDA)
			N8W->N8W_UM1PRO := __cUnMedPla
			N8W->N8W_DTINIC := FirstDate(cDataIni)
			N8W->N8W_DTFINA := LastDate(cDataIni)
			N8W->N8W_MESANO := AllTrim(StrZero(Month(N8W->N8W_DTINIC),2)) + "/" + AllTrim(Str(Year(N8W->N8W_DTINIC))) 
			N8W->(MsUnlock())

			AtuN8W(nTipo, N8W->( RecNo() ),nQuant,nQtdNF,fBmoedapv (N8Y->N8Y_MOEDA, (cAliasQry)->NJR_MOEDA) , (cAliasQry)->NJR_TIPMER)

			N8W->(DbcloseArea())

		EndIf
		(cAliasQry2)->(DbcloseArea())
	EndIf
	Return .T. 

	/*/{Protheus.doc} AtuN8W()
	Realiza atualização de valores na N8W
	@type  Static Function
	@author tamyris.g	
	@since 10/08/2018
	@version 1.0
	/*/	
Static Function AtuN8W(nTipo,RecN8W, nQtVend , nQtFat, nMoeda, cMercado)
	dbSelectArea("N8W")
	N8W->(dbGoTop())
	N8W->(DbGoTo( RecN8W ))

	IF N8Y->N8Y_TIPVOL == AllTrim(Str(nTipo))
		__nTotQtVen += nQtVend
	EndIf

	RecLock("N8W",.F.)

	If nTipo == 1 //Vendido Faturamento

		N8W->N8W_QTDVEN += nQtVend
		N8W->N8W_QTDFAT += nQtFat		
		N8W->N8W_SLDVEN := N8W->N8W_QTPRVE - N8W->N8W_QTDVEN
		
	Else //Vendido Recebimento
		N8W->N8W_QTDREC += nQtVend
		N8W->N8W_SLDREC := N8W->N8W_QTPRRE - N8W->N8W_QTDREC
	EndIF
	N8W->(MsUnlock())
	N8W->(DbcloseArea())

	Return .T.

	/*/{Protheus.doc} RepPerVenc()
	Os períodos que estão vencidos (mês menor que o mês da data do plano) e que possuem saldo a vender 
	precisam ser replanejados nos períodos seguinte.
	@type  Static Function
	@author tamyris.g	
	@since 03/09/2018
	@version 1.0
	/*/	
Static Function RepPerVenc()

	Local nQtd := 0
	Local nQtdTot := 0
	Local cSeqIte := '0000000001'
	Local dDtFina := dDataBase

	//Monta a clausula para ler os itens do plano de vendas atual
	cWhere := " FROM "+RetSqlName("N8W") + " N8W "
	cWhere += " WHERE N8W.D_E_L_E_T_ = '' "
	cWhere += "   AND N8W.N8W_FILIAL = '" + N8Y->N8Y_FILIAL + "'"
	cWhere += "   AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA  + "'"

	//Verifica se existem itens de períodos vencidos (anterior ao atual) e com saldo a vender
	cAliasQry := GetNextAlias()
	cQuery := "SELECT  N8W.R_E_C_N_O_ AS N8W_RECNO, N8W_FILIAL, N8W_GRPROD, N8W_CODPRO, N8W_TIPMER, N8W_MOEDA, N8W_UM1PRO, N8W_CODREG, N8W_SLDVEN "
	cQuery += cWhere 
	cQuery += "   AND N8W.N8W_DTINIC < '" + DtoS(FirstDate( dDataBase)) + "' "
	If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
		cQuery += "   AND N8W_SLDVEN > 0 "
	Else //Base Recebimento
		cQuery += "   AND N8W_SLDREC > 0 "
	EndIF

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		While (cAliasQry)->(!Eof()) 

			nQtd := (cAliasQry)->N8W_SLDVEN 
			nQtdTot := N8Y->N8Y_QTDCOM

			dbSelectArea("N8W")
			N8W->(dbGoTop())
			N8W->(DbGoTo( (cAliasQry)->N8W_RECNO ))

			//O saldo a vender do perído vencido deve ser zerado
			RecLock("N8W",.F.)
			If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
				N8W->N8W_QTPRVE -= nQtd
				N8W->N8W_SLDVEN := N8W->N8W_QTPRVE - N8W->N8W_QTDVEN
				If nQtdTot <> 0
					N8W->N8W_PERVEN := N8W->N8W_QTPRVE / nQtdTot * 100
				EndIF
			Else //Base Recebimento
				N8W->N8W_QTPRRE -= nQtd
				N8W->N8W_SLDREC := N8W->N8W_QTPRRE - N8W->N8W_QTDREC
				If nQtdTot <> 0
					N8W->N8W_PERREC := N8W->N8W_QTPRRE / nQtdTot * 100
				EndIF
			EndIF
			N8W->(MsUnlock())
			N8W->(DbcloseArea())

			//Joga o saldo dos períodos vencidos para o mês atual
			cAliasQry2 := GetNextAlias()
			cQuery2 := "SELECT N8W.R_E_C_N_O_ AS N8W_RECNO " + cWhere
			cQuery2 += "   AND N8W.N8W_FILIAL = '" + (cAliasQry)->N8W_FILIAL + "'" 
			cQuery2 += "   AND N8W.N8W_GRPROD = '" + (cAliasQry)->N8W_GRPROD + "' "
			cQuery2 += "   AND N8W.N8W_CODPRO = '" + (cAliasQry)->N8W_CODPRO  + "' "
			cQuery2 += "   AND N8W.N8W_TIPMER = '" + (cAliasQry)->N8W_TIPMER + "' "
			cQuery2 += "   AND N8W.N8W_MOEDA  = '" + AllTrim(Str((cAliasQry)->N8W_MOEDA))  + "' "
			cQuery2 += "   AND N8W.N8W_DTINIC = '" + DtoS(FirstDate( dDataBase)) + "' "

			cQuery2 := ChangeQuery( cQuery2 )
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2), cAliasQry2,.T.,.T.)
			dbSelectArea(cAliasQry2)
			(cAliasQry2)->(dbGoTop())
			If (cAliasQry2)->(!Eof() )

				dbSelectArea("N8W")
				N8W->(dbGoTop())
				N8W->(DbGoTo( (cAliasQry2)->N8W_RECNO ))
				RecLock("N8W",.F.)
				If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
					N8W->N8W_QTPRVE += nQtd
					N8W->N8W_SLDVEN := N8W->N8W_QTPRVE - N8W->N8W_QTDVEN
					If nQtdTot <> 0
						N8W->N8W_PERVEN := N8W->N8W_QTPRVE / nQtdTot * 100
					EndIF
				Else //Base Recebimento
					N8W->N8W_QTPRRE += nQtd
					N8W->N8W_SLDREC := N8W->N8W_QTPRRE - N8W->N8W_QTDREC
					If nQtdTot <> 0
						N8W->N8W_PERREC := N8W->N8W_QTPRRE / nQtdTot * 100
					EndIF
				EndIF
				N8W->(MsUnlock())

				N8W->(DbcloseArea())
			Else //Se não existir no mês atual, criar um registro com as mesmas características

				cSeqIte :=  GetSXENum("N8W","N8W_SEQITE")
				ConfirmSX8()	

				RecLock("N8W",.T.)
				N8W->N8W_SEQITE := cSeqIte
				N8W->N8W_FILIAL := N8Y->N8Y_FILIAL
				N8W->N8W_SAFRA  := N8Y->N8Y_SAFRA 
				N8W->N8W_CODPLA := N8Y->N8Y_CODPLA
				N8W->N8W_DTATUA := N8Y->N8Y_DTATUA 
				N8W->N8W_HRATUA := N8Y->N8Y_HRATUA
				N8W->N8W_GRPROD := (cAliasQry)->N8W_GRPROD
				N8W->N8W_CODPRO := (cAliasQry)->N8W_CODPRO
				N8W->N8W_TIPMER := (cAliasQry)->N8W_TIPMER
				N8W->N8W_MOEDA  := (cAliasQry)->N8W_MOEDA 
				N8W->N8W_UM1PRO := (cAliasQry)->N8W_UM1PRO
				N8W->N8W_DTINIC := FirstDate(dDataBase)
				N8W->N8W_DTFINA := LastDate(dDataBase)
				N8W->N8W_MESANO := AllTrim(StrZero (Month(N8W->N8W_DTINIC),2)) + "/" + AllTrim(Str(Year(N8W->N8W_DTINIC))) 
				If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
					N8W->N8W_QTPRVE := nQtd
					N8W->N8W_SLDVEN := nQtd
					If nQtdTot <> 0
						N8W->N8W_PERVEN := N8W->N8W_QTPRVE / nQtdTot * 100
					EndIF
				Else //Base Recebimento
					N8W->N8W_QTPRRE := nQtd
					N8W->N8W_SLDREC := nQtd
					If nQtdTot <> 0
						N8W->N8W_PERREC := N8W->N8W_QTPRRE / nQtdTot * 100
					EndIF
				EndIf
				dDtFina := N8W->N8W_DTFINA
				N8W->(MsUnlock())

				N8W->(DbcloseArea())
			EndIF
			(cAliasQry2)->(DbcloseArea()) 

			(cAliasQry)->(DbSkip())
		EndDo
	EndIF

	(cAliasQry)->(DbcloseArea()) 

	Return .T.

	/*/{Protheus.doc} ReplSdoVen()
	Os períodos não vencidos e que possuem quantidade vendida/faturada maior 
	que a quantidade prevista precisam ser replanejados nos demais períodos. 
	@type  Static Function
	@author tamyris.g	
	@since 30/08/2018
	@version 1.0
	/*/	
Static Function ReplSdoVen()

	Local aSldRepl := { /*Filial, Grp.Prod, Prod, Vol.Total, Saldo a Distribuir, Saldo Meses Positivos*/ }
	Local nQtdTot  := 0
	Local nCont    := 0
	Local nNovoSld := 0
	Local cCampo   :=  IIF(N8Y->N8Y_TIPVOL == "1","N8W_SLDVEN", "N8W_SLDREC")

	//Verificar se o volume total vendido for maior que o saldo disponível
	If __nTotQtVen > N8Y->N8Y_QTDCOM

		//Envia e-mail de alerta
		OGX820MAIL(__nTotQtVen,N8Y->N8Y_QTDCOM)

		//Bloqueia o Plano de Vendas
		RecLock("N8Y",.f.)
		N8Y->N8Y_STAPLA := '4'
		N8Y->(MsUnlock())

	Else 
		///Monta a clausula para ler os itens do plano de vendas atual
		cWhere := " FROM "+RetSqlName("N8W") + " N8W "
		cWhere += " WHERE N8W.D_E_L_E_T_ = '' "
		cWhere += "   AND N8W.N8W_FILIAL = '" + N8Y->N8Y_FILIAL + "'"
		cWhere += "   AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA  + "'"

		//Leitura para verificar e totalizar os períodos do plano que necessitam ajuste
		cAliasQry := GetNextAlias()
		cQuery := "SELECT  N8W.R_E_C_N_O_ AS N8W_RECNO, N8W_FILIAL, N8W_GRPROD, N8W_CODPRO, N8W_QTDVEN, " + cCampo + " AS N8W_SALDO " 
		cQuery += cWhere + "   AND " + cCampo + " <> 0 "   

		cQuery := ChangeQuery( cQuery )
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(!Eof() )
			While (cAliasQry)->(!Eof()) 

				nQtdTot := N8Y->N8Y_QTDCOM

				//Buscar Saldo a Reprogramar por Unid. Negoc, Grupo e Produto
				if (nPos := aScan(aSldRepl,{|x| allTrim(x[1])+allTrim(x[2])+allTrim(x[3]) == alltrim((cAliasQry)->N8W_FILIAL)+alltrim((cAliasQry)->N8W_GRPROD)+alltrim((cAliasQry)->N8W_CODPRO) })) > 0
					If (cAliasQry)->N8W_SALDO < 0
						aSldRepl[nPos][5] += Abs((cAliasQry)->N8W_SALDO)
					Else
						aSldRepl[nPos][6] += Abs((cAliasQry)->N8W_SALDO)
					EndIF
				else
					If (cAliasQry)->N8W_SALDO < 0
						aAdd(aSldRepl, {(cAliasQry)->N8W_FILIAL , (cAliasQry)->N8W_GRPROD , (cAliasQry)->N8W_CODPRO, nQtdTot, Abs((cAliasQry)->N8W_SALDO), 0  })
					Else
						aAdd(aSldRepl, {(cAliasQry)->N8W_FILIAL , (cAliasQry)->N8W_GRPROD , (cAliasQry)->N8W_CODPRO, nQtdTot, 0, Abs((cAliasQry)->N8W_SALDO)  })
					EndIF
				endif

				(cAliasQry)->(DbSkip())
			EndDo
		EndIF

		//Verifica se existem períodos com saldo negativo, ou seja, com a quantidade vendida maior que a prevista
		For nCont := 1 To Len(aSldRepl)

			//Se tem saldo negativo a distribuir e ao menos um período positivo para receber o rateio
			If aSldRepl[nCont][5] > 0 .And. aSldRepl[nCont][6] > 0

				cAliasQry2 := GetNextAlias()
				cQuery2 := "SELECT N8W.R_E_C_N_O_ AS N8W_RECNO, " + cCampo + " AS N8W_SALDO " + cWhere
				cQuery2 += "   AND N8W.N8W_FILIAL = '" + aSldRepl[nCont][1] + "'" 
				cQuery2 += "   AND N8W.N8W_GRPROD = '" + aSldRepl[nCont][2] + "' "
				cQuery2 += "   AND N8W.N8W_CODPRO = '" + aSldRepl[nCont][3] + "' "
				cQuery2 += "   AND " +  cCampo + " <> 0 "
				cQuery2 := ChangeQuery( cQuery2 )

				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2), cAliasQry2,.T.,.T.)

				dbSelectArea(cAliasQry2)
				(cAliasQry2)->(dbGoTop())
				If (cAliasQry2)->(!Eof() )
					While (cAliasQry2)->(!Eof()) 

						dbSelectArea("N8W")
						N8W->(dbGoTop())
						N8W->(DbGoTo( (cAliasQry2)->N8W_RECNO ))

						RecLock("N8W",.F.)

						//No mês que está sendo replanejado, o previsto passa a ser igual ao vendido (aumenta)
						If (cAliasQry2)->N8W_SALDO < 0

							If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
								N8W->N8W_QTPRVE := N8W->N8W_QTDVEN
								N8W->N8W_SLDVEN := 0
							Else //Base Financeiro
								N8W->N8W_QTPRRE := N8W->N8W_QTDREC
								N8W->N8W_SLDREC := 0
							EndIF 
						Else
							//O replanejamento deve ser feito entre todos os meses do plano de vendas que tenham saldo positivo
							// Nos meses para os quais o saldo está sendo redistribuído, o previsto diminui
							nNovoSld := aSldRepl[nCont][5] / aSldRepl[nCont][6] * (cAliasQry2)->N8W_SALDO //Rateio
							If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
								N8W->N8W_QTPRVE -= nNovoSld
								N8W->N8W_SLDVEN := N8W->N8W_QTPRVE - N8W->N8W_QTDVEN
							Else //Base Financeiro
								N8W->N8W_QTPRRE -= nNovoSld
								N8W->N8W_SLDREC := N8W->N8W_QTPRRE - N8W->N8W_QTDREC
							EndIF
						EndIf

						//Caso o valor negativo ultrapassar todo o saldo previsto, não recalcula o %
						If aSldRepl[nCont][4] <> 0 .And. aSldRepl[nCont][6] >= aSldRepl[nCont][5] 
							If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
								N8W->N8W_PERVEN := N8W->N8W_QTPRVE / aSldRepl[nCont][4] * 100
							Else //Base Financeiro
								N8W->N8W_QTDREC := N8W->N8W_QTPRRE / aSldRepl[nCont][4] * 100
							EndIF
						EndIF

						N8W->(MsUnlock())
						N8W->(DbcloseArea())

						(cAliasQry2)->(DbSkip())
					EndDo
				EndIF
				(cAliasQry2)->(DbcloseArea()) 
			EndIF
		Next nCont

		(cAliasQry)->(DbcloseArea())
	EndIF 

Return .T.

/*{Protheus.doc} AjustaPerc
Auto-Healing - Corrige diferenças de arredondamento causadas pelo replanejamento do plano
@author tamyris.g
@since 13/09/2018
@type function
*/
Static Function  AjustaPerc() 

	Local nSomaPer  := 0	
	Local nSomaQtd  := 0
	Local nMaiorPer := 0
	Local nRecno

	nSomaPer  := 0
	nSomaQtd  := 0	
	nMaiorPer := 0

	//Leitura para verificar e totalizar os períodos do plano que necessitam ajuste
	cAliasQry := GetNextAlias()
	cQuery := "SELECT  N8W.R_E_C_N_O_ AS N8W_RECNO," 
	If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
		cQuery += " N8W_PERVEN N8W_PERC , N8W_QTPRVE AS N8W_QTD"
	Else //Base Recebimento
		cQuery += " N8W_PERREC N8W_PERC , N8W_QTPRRE AS N8W_QTD "
	EndIF 
	cQuery += " FROM "+RetSqlName("N8W") + " N8W "
	cQuery += " WHERE N8W.D_E_L_E_T_ = '' "
	cQuery += "   AND N8W.N8W_FILIAL = '" + N8Y->N8Y_FILIAL + "'"
	cQuery += "   AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA  + "'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		While (cAliasQry)->(!Eof()) 

			nSomaPer += (cAliasQry)->N8W_PERC
			nSomaQtd += (cAliasQry)->N8W_QTD

			If (cAliasQry)->N8W_PERC >= nMaiorPer
				nMaiorPer := (cAliasQry)->N8W_PERC
				nRecno    := (cAliasQry)->N8W_RECNO
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo
	EndIF
	(cAliasQry)->(DbcloseArea()) 

	//Lança a diferença no item com maior percentual
	If (nSomaPer <> 100 .Or. nSomaQtd <> N8Y->N8Y_QTDCOM) .And. !Empty(nRecno)
		dbSelectArea("N8W")
		N8W->(dbGoTop())
		N8W->(DbGoTo( nRecno ))
		RecLock("N8W",.F.)
		If N8Y->N8Y_TIPVOL == "1" //Base Faturamento
			N8W->N8W_PERVEN += 100 - nSomaPer 
			N8W->N8W_QTPRVE += N8Y->N8Y_QTDCOM - nSomaQtd
			N8W->N8W_SLDVEN := N8W->N8W_QTPRVE - N8W->N8W_QTDVEN
		Else  //Base Recebimento
			N8W->N8W_PERREC += 100 - nSomaPer 
			N8W->N8W_QTPRRE += N8Y->N8Y_QTDCOM - nSomaQtd
			N8W->N8W_SLDREC := N8W->N8W_QTPRRE - N8W->N8W_QTDREC
		EndIf
		N8W->(MsUnlock())
		N8W->(DbCloseArea())
	EndIf

Return .T.

/*{Protheus.doc} getIndMoed
Retornar o índice de acordo com a moeda do plano
@author tamyris.g
@since 05/09/2018
@type function
*/
Static Function  getIndMoed(nMoeda) 
	Local cIndice := ""

	cAliasQry := GetNextAlias()
	cQuery := "SELECT NJ7_INDICE FROM "+RetSqlName("NJ7") + " NJ7 "
	cQuery += " WHERE NJ7.D_E_L_E_T_ = '' "
	cQuery += "   AND NJ7.NJ7_FILIAL = '" + xFilial("NJ7") + "'"
	cQuery += "   AND NJ7.NJ7_CODPRO = '" + AllTrim(Str(nMoeda)) + "'" 
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)
	dbSelectArea(cAliasQry)
	If (cAliasQry)->(!Eof() )
		cIndice := (cAliasQry)->NJ7_INDICE
	EndIF
	(cAliasQry)->(DbcloseArea())

return cIndice

/*{Protheus.doc} getVlIndic
Retornar o valor do índice conforme o item do plano de vendas
@author tamyris.g
@since 05/09/2018
@type function
*/
Static Function  getVlIndic(cIndice) 
	Local nValor     := 0
	local cTipo      := "" //Tipo Algodão
	Local cUfOrig    := ""
	Local cUfDest    := "" 

	/* Critérios:                                                                                          */
	/* - Considerar p/ cada período a data final, para fins de busca de valores nos índices.               */
	/* - Ao buscar os valores dos índices, considerar que o índice, quando tabelado pode estar por região. */
	/* - A região vai estar na N8W (item do plano).                                                        */
	aAllFil  := FWAllFilial(FWCodEmp("N8W"),FWUnitBusiness("N8W"))
	IF !Empty(aAllFil)   
	   cFilOrig := FWCodEmp("N8W") + FWUnitBusiness("N8W") + aAllFil[1]
	Else 
	   cFilOrig := N8W->N8W_FILIAL
	EndIF  
	  
	cUfOrig  := POSICIONE("SM0",1,cEmpAnt+cFilOrig,"M0_ESTENT")

	nVrIndice := 0
	dbSelectArea("NK0")
	NK0->( dbSetOrder(1) )
	If NK0->(DbSeek(xFilial("NK0") + cIndice ))
		nValor := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, N8W->N8W_DTFINA, N8W->N8W_CODPRO, cTipo, N8W->N8W_SAFRA, cUfOrig, cUfDest, "", N8W->N8W_CODREG )
	EndIF

	return nValor

	/*/{Protheus.doc} fGetPrdOri()
	Busca o produto pai e o conjunto com base no produto filho que esta contido no grupo de prod. do volume disponivel do plano de vendas.
	@type  Static Function
	@author rafael.kleestadt
	@since 14/09/2018
	@version 1.0
	@param param, param_type, param_descr
	@return aRet, array, array com produto pai e código do conjunto.
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fGetPrdOri()
	Local aRet      := {}
	Local cAliasQry := GetNextAlias()
	Local cQryDXC   := "" 
	Local cCodProd  := N8Y->N8Y_CODPRO 
	Local cProdOri  := "" 
	Local cConj     := ""
	Local nPercF    := 0 //Percentual tipo Fixo
	Local nPercS    := 0 //Percentual Sobra

	//Procura para a filial um conjunto onde o produto informado esteja contido
	DbSelectArea("DXC")
	DXC->(DbSetOrder(5)) //DXC_FILIAL+DXC_CODPRO
	If DXC->(DbSeek(FwxFilial("DXC")+N8Y->N8Y_CODPRO))

		cConj := DXC->DXC_CODIGO

	EndIf

	//Se não encontrar nos produtos, pesquisa nos produtos produção
	If Empty(cConj)

		cQryDXC := " SELECT DXC.DXC_CODIGO, DXC.DXC_CODPRO "
		cQryDXC += "   FROM " + RetSqlName("DXC") + " DXC "
		cQryDXC += "  WHERE DXC.D_E_L_E_T_ = '' "
		cQryDXC += "    AND DXC.DXC_FILIAL = '" + xFilial('DXC') + "'"
		cQryDXC += "    AND DXC.DXC_PRDPRO = '" +  N8Y->N8Y_CODPRO + "' "

		cQryDXC := ChangeQuery( cQryDXC )
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryDXC), cAliasQry,.T.,.T.)
		DbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(!Eof())

			cConj    := (cAliasQry)->(DXC_CODIGO)
			cCodProd := (cAliasQry)->(DXC_CODPRO)

		EndIf
		(cAliasQry)->(DbcloseArea())

	EndIf

	//campo que guarda o produto origem do conjunto
	dbSelectArea('DXE')
	DXE->(dbSetOrder(1))
	If DXE->(dbSeek(fwxFilial('DXE')+cConj))
		cProdOri := DXE->DXE_CODPRO	
	Endif

	//Obtém o percentual de rendimento conforme o produto e o tipo de percentual
	DbSelectArea("DXC")
	DXC->(DbSetOrder(1)) //DXC_FILIAL+DXC_CODIGO+DXC_ITEM
	DXC->(DbGoTop())
	If DXC->(DbSeek(FwxFilial("DXC")+cConj))

		While DXC->(!EOF()) .AND. DXC->(DXC_FILIAL+DXC_CODIGO) == FwxFilial("DXC")+cConj

			If DXC->DXC_CODPRO == cCodProd
				If DXC->DXC_TIPO == '1' //1=Fixo

					nPerc := DXC->DXC_PERC

				ElseIf DXC->DXC_TIPO == '2' //2=Variavel

					nPercF += Posicione("DXE", 1, FwxFilial("DXE")+DXC->DXC_CODIGO, "DXE_RDMED")

					nPercS := 100 - nPercF

					nPerc := (nPercS * DXC->DXC_PERC) / 100

				Else //3=Realizado

					nPerc := Posicione("DXE", 1, FwxFilial("DXE")+DXC->DXC_CODIGO, "DXE_RDMED")

				EndIf

				EXIT
			EndIf

			DXC->(DbSkip())
		EndDo

	EndIf
	DXC->(DbcloseArea())

	//Se encontrou um conjunto
	If !Empty(cConj)
		aRet := {cProdOri, cConj, nPerc}
	EndIf

	Return aRet

	/*/{Protheus.doc} fGetQtdSC2()
	Obtém a quantidade prevista, produzida e as datas de inicio e fim das ordens de produção.
	@type  Static Function
	@author rafael.kleestadt
	@since 14/09/2018
	@version 1.0
	@param cGrpProd, caractere, código do grupo de produto do volume disponivel posicionado
	@param cCodProd, caractere, código do produto do volume disponivel posicionado
	@param cSafra, caractere, safra do volume disponivel posicionado
	@return aAux, array, array contendo a quantidade prevista, produzida e as datas de inicio e fim das ordens de produção.
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fGetQtdSC2(cGrpProd, cCodProd, cSafra)
	Local cAliasQry := GetNextAlias()
	Local cQuery    := "" 
	Local nQtdePrev := 0
	Local nQtdeProd := 0
	Local dDataIni  := '29991231'
	Local dDataFim  := '19000101'
	Local aAux      := {}

	//Selecionar ordens de produção 
	cQuery := "SELECT C2_QUANT, C2_QUJE, C2_TPOP, C2_DATRF, C2_DATPRI, C2_DATPRF "
	cQuery += " FROM "+RetSqlName("SC2") + " SC2 "

	If !Empty(cGrpProd)
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "         ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
		cQuery += "        AND SB1.B1_COD =  SC2.C2_PRODUTO"
		cQuery += "        AND SB1.B1_GRUPO =  '" + cGrpProd + "'"
		cQuery += "        AND SB1.D_E_L_E_T_ = '' "
	EndIf

	cQuery += " WHERE SC2.C2_FILIAL LIKE '" + AllTrim(N8Y->N8Y_FILIAL) + "%'"
	cQuery += "   AND SC2.C2_CODSAF = '" + cSafra + "'"

	If !Empty(cCodProd)
		cQuery += "   AND SC2.C2_PRODUTO = '" +  cCodProd + "' "
	EndIF

	cQuery += "  AND SC2.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasQry,.T.,.T.)
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )

		While ( cAliasQry )->( !Eof() )

			dDataIni := IIf((cAliasQry)->C2_DATPRI < dDataIni ,(cAliasQry)->C2_DATPRI,dDataIni)
			dDataFim := IIf((cAliasQry)->C2_DATPRF > dDataFim ,(cAliasQry)->C2_DATPRF,dDataFim)

			If (cAliasQry)->C2_TPOP == "F" .And. !Empty((cAliasQry)->C2_DATRF) //Encerrada ou Encerrada Parcialmente
				nQtdePrev += (cAliasQry)->C2_QUJE
			Else
				nQtdePrev += (cAliasQry)->C2_QUANT
			EndIf
			nQtdeProd += (cAliasQry)->C2_QUJE

			(cAliasQry)->( DbSkip() )
		EndDo
	EndIf
	(cAliasQry)->(DbcloseArea())

	aAux := {nQtdePrev, nQtdeProd, dDataIni, dDataFim }

Return aAux


/*/{Protheus.doc} ConvUnMed
//Converter unidade de medida
@author tamyris.g	
@since 24/09/2018
@version 1.0
@param nValor - Valor que será convertido
nTipo - 1 - conversão de volume / 2-conversão de preço
@type function
/*/
Static Function ConvUnMed(nValor,nTipo,cCodPro,nDec)
	Local nQtUM := 1

	If __cUnMedPro <> __cUnMedPla
		If nTipo == 1 //Conversão de volume
			nQtUM := AGRX001(__cUnMedPro,__cUnMedPla,1,cCodPro)
		Else //Conversão de preço
			nQtUM := AGRX001(__cUnMedPla,__cUnMedPro,1,cCodPro)
		EndIF
	EndIf
	nValor := Round(nvalor * nQtUM , nDec)

Return nValor


/*{Protheus.doc} OGX820MAIL
//Rotina de envio de e-mail
@author tamyris.g	
@since 12/03/2019
@version 1.0
@type function */
Function OGX820MAIL(nVolVend,nVolDisp)

	Local aArea	   := GetArea()
	Local cAssunto := STR0007 //"Volume Vendido maior que Disponível a Comercializar " 
	Local cEmails  := SuperGetMV("MV_AGRO037",.F.,"") 
	Local cMsg     := ""
	Local cUsuario := RetCodUsr() // Obtém o codigo do usuário logado
	Local cUsrMail := UsrRetMail(cUsuario) // Obtém o e-mail do usuário logado
	Local cRemet   := IIF(Empty(cUsrMail),SuperGetMV("MV_RELFROM",.F.,""),cUsrMail)
	Local cMsgRet  := ""

	//Local aAnexos := { { "1", "arquivo.txt", "C:\arquivo.txt" } , { "1", "arquivos2.txt", "C:\arquivo2.txt" } }

	If !Empty(cEmails)
		cDescPro := IIf(!Empty(N8Y->N8Y_CODPRO),Posicione("SB1", 1, FwxFilial("SB1")+N8Y->N8Y_CODPRO, "B1_DESC"),Posicione("SBM", 1, FwxFilial("SBM")+N8Y->N8Y_GRPROD, "BM_DESC"))

		cMsg := STR0006 + ", <br><br>" //Prezado
		cMsg += STR0007 + ". " + STR0008 + "<br><br>"  //"Volume Vendido maior que o Saldo Disponível para Comercialização # Favor avaliar."
		cMsg += STR0009 + Alltrim(N8Y->N8Y_FILIAL) + "<br>" //"Unidade de Negócio: "
		cMsg += STR0010 + Alltrim(N8Y->N8Y_SAFRA)  + "<br>" //"Safra: "
		cMsg += STR0011 + AllTrim(cDescPro)        + "<br>" //"Produto: "
		cMsg += STR0012 + AllTrim(Transform(nVolVend, '@E 999,999,999,999.99')) + AllTrim(N8Y->N8Y_UM1PRO) + "<br>" //"Volume Vendido: "
		cMsg += STR0013 + AllTrim(Transform(nVolDisp, '@E 999,999,999,999.99')) + AllTrim(N8Y->N8Y_UM1PRO) + "<br><br>" //Disponível para Comercialização: "
		cMsg += STR0014 //Atenciosamente

		cMsgRet := OGX017MAIL(cAssunto,cEmails,cMsg, cRemet, {})
	EndIF

	RestArea(aArea)

Return

/*/{Protheus.doc} OGX820IMP
Função para importação
@type  Function
@author tamyris.ganzenmueller / rafael.kleestadt
@since 29/06/2018
@version 1.1
@param cOpc, caractere, '1' = Itens do Plano / '2' = Componentes de Preço
@return True, logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGX820IMP(cOpc,lAutomato)

	If N8Y->N8Y_STAPLA $ '3|4'
		HELP(' ',1,AllTrim(RetTitle("N8Y_STAPLA")),,AllTrim(RetTitle("N8Y_STAPLA"))+STR0016,2,0,,,,,, {AllTrim(RetTitle("N8Y_STAPLA")) + STR0017})
		Return .F. //Status Plano ### Status Plano ###" Inválido!" ### " não permite alteração." 
	EndIf

   IF !lAutomato
   		oProcess := MsNewProcess():New({|| ProcImp(cOpc)}, STR0018, STR0019) //"Importação" ### "Iniciando Processo"
   		oProcess:Activate()
   Else 
   		ProcImp(cOpc, lAutomato)
   EndIf	

Return .T.

/** {Protheus.doc} ProcImp
Função para importação
@author tamyris.ganzenmueller / rafael.kleestadt / Vanilda.Moggio
@since 29/06/2018
@version 1.1
@param cOpc, caractere, '1' = Itens do Plano / '2' = Componentes de Preço
@return True, logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function ProcImp(cOpc,lAutomato)
    Local cArqImp    := IIF(cOpc = "1", GetSrvProfString("RootPath","") + "\baseline\Layout - n8w.csv" ,GetSrvProfString("RootPath","") + "\baseline\ncu.csv")
	Local cFile      := IIF(!lAutomato,cGetFile( STR0020 + " (*.CSV) |*.csv| ",STR0021,,cLastFolder,.T.,,.F.), cArqImp)
	Local aCabecalho := {}
	Local nX         := 0
	Local nY         := 0
	Local nColunas   := 0
	Local aLinhas    := {}
	Local cLinhaErro := ""
	Local nPos       := 0
    
	Private oVwProc  := Nil
	Private lErroVal
	Private lTotal
	Private aItens   := {}
	Private aErros   := {}
	Private aColunas := {}
	Private aCpoDetNCU := {}

 	If !Empty(cFile)
		cLastFolder := SubStr(cFile,1,Rat(If(isSRVunix(),"/","\"),cFile) )
		
		If !lAutomato
		   CursorWait()
		EndIF
		
		If !lAutomato
			nHandle := FT_FUse(cFile)
			If nHandle = -1 
				MsgAlert(STR0022) //"Arquivo informado não existe."
				Return
			EndIf
		EndIf

		If UPPER(right(AllTrim(cFile),4)) != ".CSV"
			MsgAlert(STR0023) //"Arquivo deve possuir a extensão .CSV"
			CursorArrow()
			Return
		EndIf
        
        If !lAutomato
			oProcess:setRegua1(4)
			oProcess:incRegua1(OemToAnsi(STR0024)) //"Realizando leitura do arquivo..."
		EndIF	
		
		FT_FUSE(cFile)
		FT_FGOTOP()        
		While !FT_FEOF()		 
			aAdd(aLinhas,FT_FREADLN())			
			FT_FSKIP()						
		EndDo
        FT_FUSE()

		If Len(aLinhas) < 2
			MsgAlert(STR0025) //"Arquivo aparenta estar vazio ou não possui as informações para importação. Certifique-se que as colunas e os dados necessários estão no arquivo para importação."
			CursorArrow()
			Return
		EndIf

		aCabecalho := StrToKarr(aLinhas[1],";")
		nColunas := Len(aCabecalho)

		If nColunas < 6 .OR. (cOpc = '1' .AND. nColunas < 7)
			//OBRIGATORIO no arquivo ter as 6 colunas para importação "Condições de Recebimento"" ou as 9 colunas para importação "Itens do Plano de Vendas"
			MsgAlert(STR0025) //"Arquivo aparenta estar vazio ou não possui as informações para importação. Certifique-se que as colunas e os dados necessários estão no arquivo para importação.")
			CursorArrow()
			Return
		EndIf

        If !lAutomato
		    Pergunte("OGA820", .T.)
		EndIf
		    
		lTotal := IIF(MV_PAR01 = 1,.T.,.F. )


		If !lAutomato
		    oVwProc := AGRViewProc():New()
        ENDIF
         
		lErroVal := .F.
        
        If !lAutomato
        	oProcess:setRegua2(Len(aLinhas)-1)
			oProcess:incRegua1(OemToAnsi(STR0026)) //"Validando as linhas do arquivo..."
		EndIF
		
		For nX := 2 To Len(aLinhas)
			If !lAutomato
			   oProcess:incRegua2(OemToAnsi("Linha " + cValToChar(nX-1)))
			EndIF
			If Len(StrTokArr2(aLinhas[nX],";")) == 0
				Loop
			Endif
			aColunas := StrTokArr2(aLinhas[nX],";",.T.)

			If Len(aColunas) != nColunas
				aAdd(aErros,{nX,STR0027}) //"possui uma quantidade de colunas diferente do cabeçalho.Verifique."
				lErroVal := .T.
				Loop
			ElseIf Len(aColunas) < 1
				aAdd(aErros,{nX,STR0028 + "(;)."}) //"arquivo aparenta estar vazio ou não possui caracter separador de colunas"
				lErroVal := .T.
				Loop
			EndIf

			//Para tratar percentual de vendas 
			If cOpc = '1'	

				If Empty(aColunas[1])
					aColunas[1] := xFilial("N8W")
				EndIF

				If Len(aColunas) < 7
					Loop
				EndIF 
				if (nPos := aScan(aItens,{|x| allTrim(x[1])+allTrim(x[2])+allTrim(x[3]) == alltrim(aColunas[1])+alltrim(aColunas[2])+alltrim(aColunas[3]) })) > 0
					aItens[nPos][4] += Val(aColunas[7])
				else
					//           [1]N8W_FILIAL  [2]N8W_GRPPRO [3]N8W_CODPRO [7]N8W_PERVEN 
					aAdd(aItens, {aColunas[1] , aColunas[2] , aColunas[3] , Val(aColunas[7]) })
				endif	
			EndIF
		Next nX

		If !lErroVal

			//Se for total, deve excluir os registros
			If lTotal
				If cOpc = '1'		
					dbSelectArea("N8W") //Itens do plano de venda
					N8W->(dbSetOrder(3))
					If N8W->(dbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_SAFRA + N8Y->N8Y_CODPLA ))
						While N8W->(!EOF()) .And. N8W->(N8W_FILPLA + N8W_SAFRA + N8W_CODPLA) == N8Y->(N8Y_FILIAL + N8Y_SAFRA + N8Y_CODPLA)
							If N8W->N8W_DTATUA == N8Y->N8Y_DTATUA //Somente para a data atual do plano
								RecLock("N8W",.f.)
								N8W->(dbDelete())
								N8W->(MsUnlock())
							EndIF
							N8W->(dbSkip())
						EndDo
					EndIf
				ElseIf cOpc = '2'
					dbSelectArea("NCU")
					NCU->(dbSetOrder(1))
					If NCU->(dbSeek(FwXFilial("NCU") + N8Y->N8Y_CODPLA ))
						While NCU->(!EOF()) .And. NCU->(NCU_FILIAL +  NCU_CODPLA) == FwXFilial("NCU") + N8Y->N8Y_CODPLA
							RecLock("NCU",.f.)
							NCU->(dbDelete())
							NCU->(MsUnlock())
							NCU->(dbSkip())
						EndDo
					EndIf
				EndIF	
			EndIf
			If !lAutomato
				oProcess:setRegua2(Len(aLinhas)-1)
				oProcess:incRegua1(OemToAnsi(STR0029)) //"Processando as linhas do arquivo..."
			EndIF
			
			For nX := 2 To Len(aLinhas)
				If !lAutomato
					oProcess:incRegua2(OemToAnsi(STR0030 + cValToChar(nX-1))) //"Linha "
				EndIF
				aColunas := StrTokArr2(aLinhas[nX],";",.T.)
				If cOpc = '1' //Itens do Plano de Vendas
					If Len(aColunas) < 7
						Loop
					EndIF

					If Empty(aColunas[1])
						aColunas[1] := cFilAnt
					EndIF

					ImpItem(nX)
				Else
					If Len(aColunas) < 6
						Loop
					EndIF
					ImpCondRec(nX) //Condições de Recebimento
				EndIF

			Next nX
			
			fGravaNCU()
			
		EndIf

		//Tratamento para percentual - 100%
		If cOpc = '1' //Itens do Plano de Vendas
			ValidPerc(cOpc)
		EndIf
        
	    If !lAutomato    
			nY := 0
			For nX := 1 To Len(aErros)
				If nY != aErros[nX,1]
					nY := aErros[nX,1]
					cLinhaErro := STR0031 + cValToChar(nY) //"Erro(s) na linha "
					oVwProc:AddErro( cLinhaErro + ": " + aErros[nX,2] )
				Else
					oVwProc:AddErro( Space(Len(cLinhaErro + ": ")) + aErros[nX,2] )
				EndIf
			Next nX
			CursorArrow()
			If Len(aErros) == 0
				oVwProc:Add("")
				oVwProc:Add(STR0032) //"O arquivo foi importado com sucesso!"
			EndIf
		
			oVwProc:Show(STR0018, STR0033, STR0034, STR0035 + STR0036 ) //"Importação" ### "Itens do Plano de Vendas" ### "Erros" ### "Uma ou mais linhas do arquivo não foram importadas com sucesso." ### " Clique em 'Erros' para mais detalhes."
			FreeObj(oVwProc)
		EndIf
	EndIf
	aSize(aColunas   ,0)
	aSize(aLinhas    ,0)

Return .T.

/*/{Protheus.doc} ImpItem
Função para importação de itens do plano de vendas / Gravação
@author tamyris.ganzenmueller / rafael.kleestadt
@since 29/06/2018
@version 1.1
@param nX, numeric, linha do arq .csv a ser processada
@return True, logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpItem(nX)

	Local aErro     := {}
	Local oModelN8Y := Nil
	Local oModelN8W := Nil
	Local nPos      := 0
	Local nOper     := 3
	Local nI        := 0
	Local cFilBkP   := ""
	Local cMesAno   := ""

	If FirstDate( SToD(aColunas[6]) ) < N8Y->N8Y_DTIPPR .Or. FirstDate( SToD(aColunas[6]) ) > N8Y->N8Y_DTFPPR 
		aAdd(aErros,{nX, STR0038 + STR0039 }) //"Data Inválida " ### "Informe uma data que esteja entre a data inicial e final do Plano de Vendas."
		Return .T.
	EndIf

	cFilBKP := cFilAnt
	cFilAnt := PadR(aColunas[1],TamSx3('N8W_FILIAL')[1])

	If !Empty(aColunas[6])
		cMesAno := Month2Str(SToD(aColunas[6]))+'/'+Year2Str(SToD(aColunas[6]))
	EndIF

	//Diferencial - alterar só a configuração
	If !lTotal
		cAliasQry  := GetNextAlias()
		cQuery := " SELECT * "
		cQuery += "   FROM " + RetSqlName("N8W") + " N8W "
		cQuery += "  WHERE N8W.N8W_FILIAL = '" + FwxFilial('N8W') + " '"
		cQuery += "    AND N8W.N8W_SAFRA  = '" + N8Y->N8Y_SAFRA + "' "
		cQuery += "    AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA + "' "
		cQuery += "    AND N8W.N8W_GRPROD = '" + PadR(aColunas[2],TamSx3('N8W_GRPROD')[1]) + "' "
		cQuery += "    AND N8W.N8W_CODPRO = '" + PadR(aColunas[3],TamSx3('N8W_CODPRO')[1]) + "' "
		cQuery += "    AND N8W.N8W_TIPMER = '" + PadR(aColunas[4],TamSx3('N8W_TIPMER')[1]) + "' "
		cQuery += "    AND N8W.N8W_MOEDA2 = '" + PadR(aColunas[5],TamSx3('N8W_MOEDA2')[1]) + "' "
		cQuery += "    AND N8W.N8W_DTATUA = '" + DToS(N8Y->N8Y_DTATUA) + "' "
		cQuery += "    AND N8W.N8W_MESANO = '" + cMesAno/* AllTrim(Str(Year(SToD(aColunas[6])))) + "/" + AllTrim(StrZero (Month(SToD(aColunas[6])),2)) */ + "' "
		cQuery += "    AND N8W.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(!Eof() )
			nOper := 4

			cSeqItem := (cAliasQry)->N8W_SEQITE

		EndIf
		(cAliasQry)->(DbcloseArea())

	EndIf

	aFldN8W := {}
	If nOper == 3
		aAdd( aFldN8W, { 'N8W_FILIAL', xFilial('N8W') } )
		aAdd( aFldN8W, { 'N8W_FILPLA', xFilial("N8Y") } )
		aAdd( aFldN8W, { 'N8W_SAFRA' , N8Y->N8Y_SAFRA } ) 
		aAdd( aFldN8W, { 'N8W_CODPLA', N8Y->N8Y_CODPLA } )
		aAdd( aFldN8W, { 'N8W_CODPRO', PadR(aColunas[3],TamSx3('N8W_CODPRO')[1] ) } )
		aAdd( aFldN8W, { 'N8W_GRPROD', PadR(aColunas[2],TamSx3('N8W_GRPROD')[1] ) } )
		aAdd( aFldN8W, { 'N8W_TIPMER', PadR(aColunas[4],TamSx3('N8W_TIPMER')[1] ) } )
		aAdd( aFldN8W, { 'N8W_MOEDA2', PadR(aColunas[5],TamSx3('N8W_MOEDA2')[1] ) } )
		aAdd( aFldN8W, { 'N8W_DTINIC', SToD(aColunas[6])})
		aAdd( aFldN8W, { 'N8W_DTATUA', N8Y->N8Y_DTATUA})
	EndIf

	aAdd( aFldN8W, { 'N8W_PERVEN', Val(aColunas[7])})
	aAdd( aFldN8W, { 'N8W_MESANO', cMesAno  } )


	oModelN8Y := FWLoadModel( 'OGA830' )
	oModelN8W := oModelN8Y:GetModel("N8WUNICO")
	oModelN8Y:SetOperation( MODEL_OPERATION_UPDATE )
	oModelN8W:SetNoUpdateLine(.F.)

	If oModelN8Y:Activate()

		// Obtemos a estrutura de dados do cabeçalho
		oStruct := oModelN8W:GetStruct()
		aAux    := oStruct:GetFields()

		//Se for Total adiciona linha e posiciona
		If nOper == 3
			If nX > 2
				oModelN8W:AddLine()
			EndIf
			oModelN8W:GoLine(oModelN8W:Length())
		Else
			oModelN8W:SeekLine({ {"N8W_SEQITE", cSeqItem} }) // Posiciona na previsão referente a reserva
		EndIf

		lRet := .T.
		For nI := 1 To Len( aFldN8W )
			// Verifica se os campos passados existem na estrutura do cabeçalho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldN8W[nI][1] ) } ) ) > 0
				// È feita a atribuição do dado aos campo do Model do cabeçalho
				If !oModelN8W:SetValue( aFldN8W[nI][1],aFldN8W[nI][2] )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo) o método SetValue retorna .F.
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next

		If lRet
			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet := (oModelN8Y:VldData() )) 
				// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
				lRet := ( oModelN8Y:CommitData()) 
			EndIf

		EndIf

		cFilAnt := cFilBKP

		If lRet 
			oModelN8Y:DeActivate() // Desativamos o Model
			oModelN8Y:Destroy()    // Destroi o objeto do model
		Else
			// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
			aErro := oModelN8Y:GetErrorMessage()

			oModelN8Y:DeActivate() // Desativamos o Model
			oModelN8Y:Destroy()    // Destroi o objeto do model

			aAdd(aErros,{nX, STR0042 + ' [' + AllToChar( aErro[1] ) + ']' + Chr(10) + Chr(13) + ; //"Id do formulário de origem:"
			STR0043 + ' [' + AllToChar( aErro[2] ) + ']' + Chr(10) + Chr(13) + ; //"Id do campo de origem: "    
			STR0044 + ' [' + AllToChar( aErro[3] ) + ']' + Chr(10) + Chr(13) + ; //"Id do formulário de erro: " 
			STR0045 + ' [' + AllToChar( aErro[4] ) + ']' + Chr(10) + Chr(13) + ; //"Id do campo de erro: "      
			STR0046 + ' [' + AllToChar( aErro[5] ) + ']' + Chr(10) + Chr(13) + ; //"Id do erro: "               
			STR0047 + ' [' + AllToChar( aErro[6] ) + ']' + Chr(10) + Chr(13) + ; //"Mensagem do erro: "         
			STR0048 + ' [' + AllToChar( aErro[7] ) + ']' + Chr(10) + Chr(13) + ; //"Mensagem da solução: "      
			STR0049 + ' [' + AllToChar( aErro[8] ) + ']' })                      //"Valor atribuído: "          
			lErroVal := .T.
		EndIf
	EndIf	

Return .T.

/** {Protheus.doc} ImpCondRec
Função para carregar array para importação das condições de recebimento
@author:    Tamyris Ganzenmueller / rafael.kleestadt
@since 29/06/2018
@version 1.1
@param nX, numeric, linha do arq .csv a ser processada
@return True, logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpCondRec(nX)

	Local nPos := 0
	lOCAL cMesAno  := ''
	lOCAL cMesAno2 := ''
	Local cSeqItem := ''
	
	cMercN8w := PadR(aColunas[1],TamSx3('N8W_TIPMER')[1]) 
	cMoedN8w := PadR(aColunas[2],TamSx3('N8W_Moeda')[1])

	If !Empty(aColunas[3])
		cMesAno := Month2Str(SToD(aColunas[3])) + '/' + Year2Str(date(aColunas[3]))				
		cMesAno2:= Month2Str(SToD(aColunas[4])) + '/' + Year2Str(date(aColunas[4]))
	EndIF


	cAliasN8W  := GetNextAlias()
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSqlName("N8W") + " N8W "
	cQuery += "  WHERE N8W.N8W_FILIAL = '" + FwxFilial('N8W') + " '"
	cQuery += "    AND N8W.N8W_SAFRA  = '" + N8Y->N8Y_SAFRA + "' "
	cQuery += "    AND N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA + "' "
	cQuery += "    AND N8W.N8W_GRPROD = '" + N8Y->N8Y_GRPROD + "' "
	cQuery += "    AND N8W.N8W_CODPRO = '" + N8Y->N8Y_CODPRO + "' "
	cQuery += "    AND N8W.N8W_TIPMER = '" + cMercN8w + "' "
	cQuery += "    AND N8W.N8W_MOEDA2 = '" + cMoedN8w + "' "
	cQuery += "    AND N8W.N8W_MESANO = '" + cMesAno + "' "
	cQuery += "    AND N8W.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasN8W,.F.,.T.)

	dbSelectArea(cAliasN8W)
	(cAliasN8W)->(dbGoTop())
	If (cAliasN8W)->(!Eof() )				
		cSeqItem  := (cAliasN8W)->N8W_SEQITE
		If !lTotal //Diferencial
			If (nPos := aScan(aItens,{|x| allTrim(x[1])+allTrim(x[2])+allTrim(x[3])+allTrim(x[4])== allTrim(FwxFilial('NCU'))+allTrim(N8Y->N8Y_CODPLA)+allTrim(cSeqItem)+allTrim(cMesano2) })) == 0
				// [1]NCU_GRPPRO [2]NCU_CODPRO [3]NCU_TIPMER  [4]NCU_MOEDA 
				aAdd(aItens, {FwxFilial('NCU'), N8Y->N8Y_CODPLA, cSeqItem , cMesano2})

				cAliasQry2  := GetNextAlias()
				cQuery := "SELECT NCU.R_E_C_N_O_ NCU_RECNO  "
				cQuery += " FROM " + RetSqlName("NCU") + " NCU "
				cQuery += " WHERE NCU.NCU_FILIAL = '" + FwxFilial('NCU') + " '"
				cQuery += " AND   NCU.NCU_CODPLA = '" + N8Y->N8Y_CODPLA + "' "
				cQuery += " AND   NCU.NCU_SEQITE = '" + cSeqItem + "' "					
				cQuery += " AND   NCU.NCU_MESANO = '" + cMesano2 + "' "
				cQuery += " AND   NCU.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry2,.F.,.T.)

				dbSelectArea(cAliasQry2)
				(cAliasQry2)->(dbGoTop())
				If (cAliasQry2)->(!Eof() )
					While .Not. (cAliasQry2)->( Eof() ) 

						dbSelectArea("NCU")
						NCU->(dbSetOrder(1))
						NCU->( dbGoto( (cAliasQry2)->(NCU_RECNO) ) )

						NCU->( RecLock( "NCU", .f. ) )
						NCU->(dbDelete())
						NCU->( msUnlock() )

						(cAliasQry2)->( dbSkip() )
					EndDo
				EndIf
				(cAliasQry2)->(DbcloseArea())
			Endif
		EndIf

		aFldNCU := {}

		//If !Empty(N8Y->N8Y_CODPRO)
		//aAdd( aFldNCU, { 'NCU_CODPRO', N8Y->N8Y_CODPRO } )
		//EndIF

		aAdd( aFldNCU, { 'NCU_SEQITE', cSeqItem } )
		aAdd( aFldNCU, { 'NCU_CODPLA', N8Y->N8Y_CODPLA } )
		aAdd( aFldNCU, { 'N8W_MESANO', cMesano  } )
		aAdd( aFldNCU, { 'NCU_MESANO', cMesano2 } )
		aAdd( aFldNCU, { 'NCU_PERREC', Val(aColunas[5])})
		aAdd( aFldNCU, { 'NCU_QTPRRE', Val(aColunas[6])})
		aAdd( aFldNCU, { 'LINHA'     , nX })

		aAdd( aCpoDetNCU, aFldNCU )	 
      	 
	Else 
		aAdd(aErros,{nX, STR0047 + "[ " + cMercN8w + " / " + cMoedN8w+ " / " + cMesano + "] " } ) //"Não encontrou volume para chave"
		lErroVal := .T.
	EndIf
	(cAliasN8W)->(DbcloseArea())
	
Return .T.

/*{Protheus.doc} fGravaNCU
@author vanilda.moggio
@since 18/04/2019
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function fGravaNCU()
	Local nJ := 0
	Local aErro:= {}
	Local nPos := 0
	Local nI := 0
    Local nx := 0
	//coloca numa transação? yeah
	oModelNCU := FWLoadModel( 'OGA830' )
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModelNCU:SetOperation( 4 ) // 4 - alteracao
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModelNCU:Activate()

	oAux := oModelNCU:GetModel( 'NCUUNICO' )
	oAux:SetNoDelete( .f. )
	oAux:SetNoInsert( .f. )
	// Obtemos a estrutura de dados do item
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	
    oModelN8W:= oModelNCU:GetModel('N8WUNICO')
 
	lRet := .T.
	For nI := 1 To Len( aCpoDetNCU )
		// Incluímos uma linha nova
		// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
		If nI > 1
			oAux:AddLine()
		EndIf	
		
		oModelN8W:SeekLine({ {"N8W_SEQITE", aCpoDetNCU[nI][1][2]} }) // Posiciona na previsão referente a reserva			
		
		For nJ := 1 To Len( aCpoDetNCU[nI] )		    
		    
			// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetNCU[nI][nJ][1] ) } ) ) > 0
				oModelNCU:GetModel('NCUUNICO'):GetStruct():SetProperty(aCpoDetNCU[nI][nJ][1], MODEL_FIELD_WHEN,{||.T.})						
				If !( lAux := oModelNCU:SetValue( 'NCUUNICO', aCpoDetNCU[nI][nJ][1], aCpoDetNCU[nI][nJ][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
		If !lRet
			Exit
		EndIf
	Next

	If lRet
		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If ( lRet := (oModelNCU:VldData() )) 
			// Se o dados foram validados faz-se a gravação efetiva dos
			// dados (commit)
			//guarda o código do contrato a ser gravado 
			lRet := ( oModelNCU:CommitData()) 
		EndIf

	EndIf

	If lRet 
		oModelNCU:DeActivate()
	Else
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro := oModelNCU:GetErrorMessage()

		// Desativamos o Model
		oModelNCU:DeActivate()

		aAdd(aErros,{nX, STR0042 + ' [' + AllToChar( aErro[1] ) + ']' + Chr(10) + Chr(13) + ; //"Id do formulário de origem:"
		STR0043 + ' [' + AllToChar( aErro[2] ) + ']' + Chr(10) + Chr(13) + ; //"Id do campo de origem: "    
		STR0044 + ' [' + AllToChar( aErro[3] ) + ']' + Chr(10) + Chr(13) + ; //"Id do formulário de erro: " 
		STR0045 + ' [' + AllToChar( aErro[4] ) + ']' + Chr(10) + Chr(13) + ; //"Id do campo de erro: "      
		STR0046 + ' [' + AllToChar( aErro[5] ) + ']' + Chr(10) + Chr(13) + ; //"Id do erro: "               
		STR0047 + ' [' + AllToChar( aErro[6] ) + ']' + Chr(10) + Chr(13) + ; //"Mensagem do erro: "         
		STR0048 + ' [' + AllToChar( aErro[7] ) + ']' + Chr(10) + Chr(13) + ; //"Mensagem da solução: "      
		STR0049 + ' [' + AllToChar( aErro[8] ) + ']' })                      //"Valor atribuído: "  
		lErroVal := .T.
	EndIf		   
	
	
return 	
/** {Protheus.doc} ValidPerc
//Tratamento quando o percentual for maior que 100%
@author:    Tamyris Ganzenmueller
@since:     06/07/2018
@Uso:       OGA820 */

Static Function ValidPerc(cOpc)

	Local nX
	Local nPerVen := 0
	Local cFilBkp := ""

	IF Len(aItens) > 0
		N8Y->( RecLock( "N8Y", .f. ) )
		N8Y->N8Y_ATIVO = '1'
		N8Y->( msUnlock() )
	EndIf

	For nX := 1 To Len(aItens)

		cFilBKP := cFilAnt
		cFilAnt := PadR(aItens[nX][1],TamSx3('N8W_FILIAL')[1])

		nPerVen := 0
		cQuery1 := "SELECT SUM(N8W_PERVEN) AS PERVEN "
		cQuery2 := "SELECT N8W.R_E_C_N_O_ N8W_RECNO"

		cQuery := " FROM " + RetSqlName("N8W") + " N8W "
		cQuery += " WHERE N8W.N8W_FILIAL = '" + FwxFilial('N8W') + " '"
		cQuery += " AND   N8W.N8W_FILPLA = '" + FwxFilial('N8Y') + "' "
		cQuery += " AND   N8W.N8W_SAFRA  = '" + N8Y->N8Y_SAFRA + "' "
		cQuery += " AND   N8W.N8W_CODPLA = '" + N8Y->N8Y_CODPLA + "' "
		cQuery += " AND   N8W.N8W_GRPROD = '" + PadR(aItens[nX][2],TamSx3('N8W_GRPROD')[1]) + "' "
		cQuery += " AND   N8W.N8W_CODPRO = '" + PadR(aItens[nX][3],TamSx3('N8W_CODPRO')[1] ) + "' "
		cQuery += " AND   N8W.N8W_DTATUA = '" + DToS(N8Y->N8Y_DTATUA) + "' "
		cQuery += " AND   N8W.D_E_L_E_T_ = '' "

		cAliasQry  := GetNextAlias()
		cQuery1 += cQuery
		cQuery1 := ChangeQuery(cQuery1)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery1),cAliasQry,.F.,.T.)

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(!Eof() )
			nPerVen := (cAliasQry)->PERVEN
		EndIf
		(cAliasQry)->(DbcloseArea())

		If nPerVen > 100
			cAliasQry  := GetNextAlias()
			cQuery2 += cQuery
			cQuery2 := ChangeQuery(cQuery2)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQry,.F.,.T.)

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())
			If (cAliasQry)->(!Eof() )

				While .Not. (cAliasQry)->( Eof() ) 

					N8W->( dbSetOrder( 1 ) )
					N8W->( dbGoto( (cAliasQry)->(N8W_RECNO) ) )

					N8W->( RecLock( "N8W", .f. ) )
					N8W->( N8W_PERVEN ) := 0
					N8W->( msUnlock() )

					(cAliasQry)->( dbSkip() )
				EndDo

			EndIf
			(cAliasQry)->(DbcloseArea())

			aAdd(aErros,{nX, STR0037 + "[ " + aItens[nX][1] + "/" + aItens[nX][2] + "/" + aItens[nX][3] + "] " } ) //"Soma do % Venda totalizou mais que 100% para Data, Filial, Grupo de Produto e Produto. O registro foi importado, porém o percentual foi zerado."

		EndIf

		cFilAnt := cFilBKP 

	Next nX
Return .T.


/*/{Protheus.doc} fBmoedapv
RETORNA MOEDA DO PLANO CASO SEJA DIFERENTE DA MOEDA PADRAO 
@author vanilda.moggio
@since 04/04/2019
@version 1.0
@return ${return}, ${return_description}
@param nMoeN8y, numeric, descricalo
@param nMoeNjr, numeric, descricao
@type function
/*/
STATIC FUNCTION fBmoedapv (nMoeN8y,nMoeNjr)
	Local nMoeda:= 1

	IF  nMoeNjr <> 1 
		nMoeda:= nMoeN8y
	ENDIF

Return nMoeda	
