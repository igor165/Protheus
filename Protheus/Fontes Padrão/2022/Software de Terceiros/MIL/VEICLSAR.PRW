////////////////
// Versao 003 //
////////////////

#include "protheus.ch"
#include "VEICLSAR.CH"

Function VEICLSAR()
Return()

/*/{Protheus.doc} DMS_RequisicaoFerramenta
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Acopla dados do VD3(Ferramentas movimentadas)
/*/
Class DMS_RequisicaoFerramenta
	Data nId
	Data cSequen
	Data cCodFerramenta
	Data dDtMov
	Data nQtdMov
	Data cCodCabReq

	Method New() CONSTRUCTOR
	Method Sequencia()
	Method CodigoFerramenta()
	Method DataMovimento()
	Method Quantidade()
	Method CabecaRequisicao()
	Method Ferramenta()
	METHOD TipoRequisicao()
	METHOD TipoDevolucao()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_RequisicaoFerramenta

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New(aData) Class DMS_RequisicaoFerramenta
	oData            := DMS_DataContainer():New(adata)
	::nId            := oData:GetValue('R_E_C_N_O_')
	::cSequen        := oData:GetValue('VD3_SEQUEN')
	::cCodFerramenta := oData:GetValue('VD3_CODFER')
	::dDtMov         := oData:GetValue('VD3_DATMOV')
	::nQtdMov        :=	oData:GetValue('VD3_QTDMOV')
	::cCodCabReq     := oData:GetValue('VD3_CODIGO')
Return SELF

Method Sequencia() Class DMS_RequisicaoFerramenta
Return Self:cSequen

Method CodigoFerramenta() Class DMS_RequisicaoFerramenta
Return Self:cCodFerramenta

Method DataMovimento() Class DMS_RequisicaoFerramenta
Return Self:dDtMov

Method Quantidade() Class DMS_RequisicaoFerramenta
Return Self:nQtdMov

Method CabecaRequisicao() Class DMS_RequisicaoFerramenta
Return Self:cCodCabReq

/*/{Protheus.doc} GetFilial
	Retorna o Status de movimentos de Requisicao

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method TipoRequisicao() Class DMS_RequisicaoFerramenta
Return '1'

/*/{Protheus.doc} GetFilial
	Retorna o Status de movimentos de Devolucao

	@author Vinicius Gati
	@since 05/05/2014
/*/
Method TipoDevolucao() Class DMS_RequisicaoFerramenta
Return '0'


/*/{Protheus.doc} DMS_RequisicaoPECA
	Classe criada para buscar e modificar dados referentes a requisicoes de pecas
	
	@author Vinicius Gati
	@since  25/06/2014
/*/
Class DMS_RequisicaoPECA
	Data cNumeroOs

	Method New() Constructor
	Method PecasDuplicadasVSJ()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_RequisicaoPECA
	
	@author Vinicius Gati
	@since  25/06/2014
/*/
Method New(cNumOs) Class DMS_RequisicaoPECA
	self:cNumeroOs := cNumOs
Return Self

/*/{Protheus.doc} New
	Retorna um array contendo dados de produtos que foram requisitados repetidamente com a quantidade total requisitada de cada um para a OS
	excluindo VSJs deletados

	@author Vinicius Gati
	@since  25/06/2014
/*/
Method PecasDuplicadasVSJ() Class DMS_RequisicaoPECA
	Local aResults    := {}
	Local cVSJTblName := RetSqlName('VSJ')
	Local cFilVSJ     := xFilial('VSJ')
	Local cAlias      := 'ReqMesmaPecaDUPL'
	Local cQuery      := ''
	Local nQtdade     := 0
	Local cCacheAlias := Alias()
	Local nB1Nro      := SB1->(RecNo())
	Local nB2Nro      := SB2->(RecNo())
	Local oEstconf    := DMS_EstoqueConfig():New()
	Local cEstReserv  := oEstconf:getEstoqueReserva()

	cQuery += "   SELECT VSJ_GRUITE, VSJ_CODITE, VSJ_NUMLOT, VSJ_LOTECT, SUM(VSJ_QTDITE) as QTDREQTOT , COUNT(*) as NROREQTOT , VSJ_RESPEC "
	cQuery += "     FROM " +cVSJTblName+ " VSJ  "
	cQuery += "    WHERE VSJ.VSJ_FILIAL = '"+cFilVSJ+"' AND VSJ.D_E_L_E_T_ = ' ' AND VSJ.VSJ_NUMOSV = '"+self:cNumeroOs+"' AND VSJ.VSJ_QTDITE > 0 "
	cQuery += " GROUP BY VSJ_GRUITE, VSJ_CODITE, VSJ_NUMLOT, VSJ_LOTECT , VSJ_RESPEC "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )
	(cAlias)->(DbGoTop())     // Posiciona o cursor no início da área de trabalho ativa
	While !(cAlias)->(EOF())  // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo

		// Só retorna quando requisitado mais de uma vez a mesma peça com mesmo lote no mesmo orcamento
		If (cAlias)->NROREQTOT > 1
			// Pega o saldo em estoque do item
			SB1->(dbSetOrder(7))
			SB1->(dbSeek(xFilial("SB1")+ (cAlias)->VSJ_GRUITE + (cAlias)->VSJ_CODITE))
			SB1->(dbSetOrder(1)) // voltando para evitar erros com backoffice
			dbSelectArea("SB2")
			SB2->(dbSetOrder(1))
			If (cAlias)->VSJ_RESPEC == "1"
				cLocReser := cEstReserv
				If Empty( cLocReser )
					MSGALERT( STR0001 )
					aResults := {}
					Exit
				EndIf
			Else
				cLocReser := SB1->B1_LOCPAD
			EndIf
			SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + cLocReser))
			nQtdade := SaldoSb2()
			//

			aRow := {;
				(cAlias)->VSJ_GRUITE ,; // 1
				(cAlias)->VSJ_CODITE ,; // 2
				SB1->B1_DESC         ,; // 3
				(cAlias)->QTDREQTOT  ,; // 4
				nQtdade              ,; // 5
				(cAlias)->VSJ_NUMLOT ,; // 6
				(cAlias)->VSJ_LOTECT  ; // 7
			}
			AADD(aResults, aRow)
		EndIf

		(cAlias)->(DbSkip())
	End
	(cAlias)->(dbCloseArea())

	DbSelectArea(cCacheAlias)
	SB1->(DbGoTo(nB1Nro))
	SB2->(DbGoTo(nB2Nro))
Return aResults