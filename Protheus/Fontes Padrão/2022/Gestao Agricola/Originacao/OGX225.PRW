#include "protheus.ch"
#include "ogx225.ch"

#DEFINE _CRLF CHR(13)+CHR(10)
#DEFINE _NMODAGRO 67

/*** {Protheus.doc} OGX225A
Rotina chamada através do Pedido de Venda
MATA410/FATXFUN->A460Estorna()
Esta função irá validar se existe registro na tabela SC9 - Liberação de itens do pedido
relacionado com a NJ5 - Agendamento de carga. Caso existir retorna .F. e impede que a
função A460Estorna exclua o registro na SC9.
@author: 	Marcelo R. Ferrari
@since: 	08/11/2016
@Uso: 		SIGAAGR - Gestão Agrícola ***/
Function OGX225A()
	Local lRet := .T.
	Local cAliasQry := GetNextAlias()
	Local cQuery   := ""
	Local lInverte   := .F.
	Local cMarca     := ""
	Local nTpEstorno

	//Se for liberacao automatica, permite atualizar SC9, pois e necessario alterar C9_BLCRED
	If IsInCallStack("A456LIBAUT")
		Return(lRet)
	EndIf

	//Verifica se o item já possui um agendamento - NJ5 relacionado
	cQuery := "SELECT distinct '1' Existe "
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName("NJ5") + " NJ5 ON SC9.C9_FILIAL  = NJ5.NJ5_FILIAL AND "
	cQuery += " SC9.C9_PEDIDO  = NJ5.NJ5_NUMPV  AND
	cQuery += " SC9.C9_ITEM    = NJ5.NJ5_ITEM   AND
	cQuery += " SC9.C9_PRODUTO = NJ5.NJ5_PRODUT AND
	cQuery += " SC9.C9_SEQUEN  = NJ5.NJ5_SEQUEN
	cQuery += " WHERE SC9.C9_FILIAL = '" + fwxFilial("SC9") + " '"
	cQuery += " AND SC9.C9_PEDIDO   = '" + SC9->C9_PEDIDO + "' "
	cQuery += " AND SC9.C9_ITEM     = '" + SC9->C9_ITEM + "' "
	cQuery += " AND SC9.C9_PRODUTO  = '" + SC9->C9_PRODUTO + "' "

	//Se estiver sendo executado a função de estorno de liberação
	If IsInCallStack("Ma461Est2") .OR. IsInCallStack("Ma461Estor")
		cQuery += " AND SC9.C9_SEQUEN   = '" + SC9->C9_SEQUEN + "' "  //SEQUENCIA DO REGISTRO DA SC9

		Pergunte("MT461A",.F.)
		nTpEstorno := MV_PAR02
		If nTpEstorno = 2
			lInverte   := ThisInv()
			cMarca     := ThisMark()
			If ( lInverte )
				cQuery += "AND SC9.C9_OK<>'"+cMarca+"' "
			Else
				cQuery += "AND SC9.C9_OK='"+cMarca+"' "
			EndIf
		EndIf

		cQuery += " AND SC9.D_E_L_E_T_ = '' "
		cQuery += " AND NJ5.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		(cAliasQry)->(dbGoTop())
		IF (cAliasQry)->Existe = "1"
			lRet := .F.
			If IsInCallStack("MATA460A")
				Help(,, STR0009 /*"Atenção"*/,, STR0011 + SC9->C9_PEDIDO , 1, 0 )
				/*"Não é possível realizar o estorno. Existe Programação de Entrega relacionada ao pedido "*/
			EndIf
		EndIf
	EndIf

Return lRet

/** {Protheus.doc} OGX225B
Rotina chamada através do Pedido de Venda
MATA410->A410LinOk()
MATA410->A410ValDel
Esta função tem a finalidade de impedir a deleção da linha no GRID
no programa MATA410
@author: 	Marcelo R. Ferrari
@since: 	08/11/2016
@Uso: 		SIGAAGR - Gestão Agrícola
**/
Function OGX225B(pRet)
	Local lRet := pRet
	Local cAliasQry := GetNextAlias()
	Local cQuery   := ""

	Default pRet := .T.

	If !( (IsInCallStack("A410LinOk")) .OR. (IsInCallStack("A410ValDel")) )
		Return pRet
	EndIf

	//Verifica se o item já possui uma liberação na SC9
	//com agendamento na NJ5
	cQuery := "SELECT distinct '1' Existe "
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName("NJ5") + " NJ5 ON SC9.C9_FILIAL  = NJ5.NJ5_FILIAL AND "
	cQuery += " SC9.C9_PEDIDO  = NJ5.NJ5_NUMPV  AND
	cQuery += " SC9.C9_ITEM    = NJ5.NJ5_ITEM   AND
	cQuery += " SC9.C9_PRODUTO = NJ5.NJ5_PRODUT AND
	cQuery += " SC9.C9_SEQUEN  = NJ5.NJ5_SEQUEN
	cQuery += " WHERE SC9.C9_FILIAL = '" + fwxFilial("SC9") + " '"
	cQuery += " AND SC9.C9_PEDIDO   = '" + SC6->C6_NUM + "' "
	cQuery += " AND SC9.C9_ITEM     = '" + SC6->C6_ITEM + "' "
	cQuery += " AND SC9.C9_PRODUTO  = '" + SC6->C6_PRODUTO + "' "

	cQuery += " AND SC9.D_E_L_E_T_ = '' "
	cQuery += " AND NJ5.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	(cAliasQry)->(dbGoTop())
	IF (cAliasQry)->Existe = "1"
		If (IsInCallStack("A410ValDel"))
			lRet := .F.
			//If IsBlind()
			// #O item não pode ser excluído pois possui registro de Liberação/Agendamento
			Alert(STR0001)
			//EndIf
		EndIf
	EndIf
Return lRet

/** {Protheus.doc} OGX225C
Rotina chamada através do Pedido de Venda
MATA410/FATXFUN->A440Qtdl()
Função para validar o saldo do item do pedido, verificando
a quantidade que está sendo liberada -  a quantidade que
já está na tabela SC9, MESMO que ainda não tenha sido
feito o agendamento na NJ5
@author: 	Marcelo R. Ferrari
@since: 	08/11/2016
@Uso: 		SIGAAGR - Gestão Agrícola
**/
Function OGX225C(nQtdVen, nQtdLib)
	Local aArea := GetArea()
	Local lRet := .T.
	//Soma a quantidade de itens liberados com agendamento
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nQtdLibC9 := 0
	Local nQtdSaldo := 0

	Default nQtdVen := 0
	Default nQtdLib := 0

	dbselectarea('SB5')
	dbSetOrder(1)
	if MsSeek(fwXfilial('SB5')+SC6->C6_PRODUTO) .and. (SB5->B5_SEMENTE=='1')
		//Na primeira etapa verifica se existe registro na SC9/NJ5
		//Se encontrar e a chamada da tela vier do MATA410, então não permite editar o campo
		//pois a liberação deve ser feita pela tela de liberação
		If IsInCallStack("MATA410")
			cQuery := "SELECT distinct '1' Existe "
			cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
			cQuery += " INNER JOIN " + RetSqlName("NJ5") + " NJ5 ON SC9.C9_FILIAL  = NJ5.NJ5_FILIAL AND "
			cQuery += " SC9.C9_PEDIDO  = NJ5.NJ5_NUMPV  AND
			cQuery += " SC9.C9_ITEM    = NJ5.NJ5_ITEM   AND
			cQuery += " SC9.C9_PRODUTO = NJ5.NJ5_PRODUT AND
			cQuery += " SC9.C9_SEQUEN  = NJ5.NJ5_SEQUEN
			cQuery += " WHERE SC9.C9_FILIAL = '" + fwxFilial("SC6") + " '"
			cQuery += " AND SC9.C9_PEDIDO   = '" + SC6->C6_NUM + "' "
			cQuery += " AND SC9.C9_ITEM     = '" + SC6->C6_ITEM + "' "
			cQuery += " AND SC9.C9_PRODUTO  = '" + SC6->C6_PRODUTO + "' "
			cQuery += " AND SC9.D_E_L_E_T_ = '' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			(cAliasQry)->(dbGoTop())
			While !(Eof())
				If ((cAliasQry)->EXISTE) = "1"
					lRet := .F.
					//#"Já existe liberação de pedido com agendamento."
					//# "Utiliza a tela de Liberação de pedidos para liberar"
					//#"Efetuar novas liberações"
					MsgAlert( STR0002 + _CRLF + STR0003+ _CRLF + STR0004 )
					Return .F.
				EndIf
				Exit
			End
			(cAliasQry)->(dbclosearea())
			cQuery := ""
		EndIf


		//Faz a validação do valor digitado com o saldo.
		cQuery := "SELECT (SUM(C9_QTDLIB)) QTD_LIBC9 "
		cQuery += "  FROM " +RetSqlName("SC9") +" SC9 "
		cQuery += " WHERE SC9.C9_FILIAL = '" + fwxFilial("SC6") + "' "
		cQuery += " AND SC9.C9_PEDIDO = '" + SC6->C6_NUM + "' "
		cQuery += " AND SC9.C9_ITEM = '" + SC6->C6_ITEM + "' "
		cQuery += " AND SC9.C9_BLCRED NOT IN ('03') "  //Registro estornado. (To-do: Verificar se este registro pode ser recuperado)
		cQuery += " AND SC9.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		(cAliasQry)->(dbGoTop())
		While !(Eof())
			If !Empty((cAliasQry)->QTD_LIBC9)
				nQtdLibC9 := (cAliasQry)->QTD_LIBC9
			EndIf
			Exit
		End

		IF nQtdLib > ( nQtdVen - nQtdLibC9 )
			nQtdSaldo := ( nQtdVen - nQtdLibC9 )
			//"A quantidade de liberação informada é superior ao saldo disponível: "
			MsgAlert(STR0005 + cValToChar(nQtdSaldo) )
			lRet := .F.
		EndIf
	Endif
	RestArea(aArea)
Return lRet


/** {Protheus.doc} OGX225D
Rotina chamada através do Pedido de Venda
MATA410/FATXFUN->A460Estorna()
Impede a deleção do registro na SC9 a partir do programa
Fatxfun->A460Estorna quando é feita a digitação do campo
quantidade liberada no programa mata410
@author: 	Marcelo R. Ferrari
@since: 	08/11/2016
@Uso: 		SIGAAGR - Gestão Agrícola
**/
Function OGX225D(cAlias)
	Local lRet := .T.

	If IsInCallStack("MATA410")
		If .NOT.(OGX225A())
			(cAlias)->(DbRecall())
		EndIf
	EndIf
Return lRet


/** {Protheus.doc} OGX225e
Rotina chamada através do Pedido de Venda
MATA410/MATA410A->A410MULTT()
Impede a deleção do registro na SC9 a partir do programa
Fatxfun->A460Estorna quando é feita a digitação do campo
quantidade liberada no programa mata410
@author: 	Marcelo R. Ferrari
@since: 	08/11/2016
@Uso: 		SIGAAGR - Gestão Agrícola
**/
Function OGX225E()
	Local lRet := .T.
	Local cAliasQry := GetNextAlias()
	Local nQtdVenMem := 0//M->C6_QTDVEN
	Local nQtdLibSum := 0
	Local nQtdLibC9  := 0
	Local nQtdLibMem := 0

	// Verificar todas as liberacoes validas para o pedido na digitacao da quantidade liberada
	cQuery := "SELECT (SUM(C9_QTDLIB)) QTD_LIBC9 "
	cQuery += "  FROM " +RetSqlName("SC9") +" SC9 "
	cQuery += " WHERE SC9.C9_FILIAL = '" + fwxFilial("SC6") + "' "
	cQuery += " AND SC9.C9_PEDIDO = '" + SC6->C6_NUM + "' "
	cQuery += " AND SC9.C9_ITEM = '" + SC6->C6_ITEM + "' "
	cQuery += " AND SC9.C9_BLCRED NOT IN ('03') "  //Registro estornado. (To-do: Verificar se este registro pode ser recuperado)
	cQuery += " AND SC9.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	(cAliasQry)->(dbGoTop())
	While !(Eof())
		If !Empty((cAliasQry)->QTD_LIBC9)
			nQtdLibC9 := (cAliasQry)->QTD_LIBC9
		EndIf
		Exit
	End

	RegToMemory("SC6", .F., .F.)
	nQtdVenMem := M->C6_QTDVEN
	If !Empty(M->C6_QTDLIB)
		nQtdLibMem := M->C6_QTDLIB
	EndIf

	//Total liberado na SC9 + Qtde sendo liberada no pedido
	nQtdLibSum := nQtdLibMem + nQtdLibC9
	IF ( nQtdVenMem < nQtdLibSum )
		// #"O campo Quantidade Vendida não pode ser inferior ao total já liberado." #"Total Liberado: "
		MsgAlert(STR0006+ _CRLF + ;
		STR0007+ cValToChar(nQtdLibSum) )
		lRet := .F.
	EndIf

	If IsInCallStack("MATA410")
		If .NOT.(OGX225G())
			DbSelectArea("SC6")
			SC6->( RecLock("SC6",.F.) )
			SC6->(DbRecall())
			SC6->(MsUnlock())
		EndIf
	EndIf
Return lRet

/** {Protheus.doc} OGX225f
Rotina chamada através do Pedido de Venda - MATA410
Ponto de entrada para criar criar no menu na acao relacionada
a opcao para Agendamento de carga
@author: 	Marcelo R. Ferrari
@since: 	08/11/2016
@Uso: 		SIGAAGR - Gestão Agrícola
**/
Function OGX225F(paRotina)
	Local aRotina := paRotina
	//Agendamento de Carga
	aAdd(aRotina, {OemToAnsi(STR0008),"AGRA870"	,0, 3, 0 ,NIL} )

Return aRotina


/*** {Protheus.doc} OGX225G
Rotina chamada através do Pedido de Venda
MATA410/FATXFUN->A460Estorna()
Esta função irá validar se existe registro na tabela SC9 - Liberação de itens do pedido
relacionado com a NJ5 - Agendamento de carga. Caso existir retorna .F. e impede que a
função A460Estorna exclua o registro na SC9.

@author: 	Marcelo R. Ferrari
@since: 	08/11/2016
@Uso: 		SIGAAGR - Gestão Agrícola ***/
Function OGX225G()
	Local lRet := .T.
	Local cAliasQry := GetNextAlias()
	Local cQuery   := ""

	//Verifica se o item já possui um agendamento - NJ5 relacionado
	cQuery := "SELECT distinct '1' Existe "
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName("NJ5") + " NJ5 ON SC9.C9_FILIAL  = NJ5.NJ5_FILIAL AND "
	cQuery += " SC9.C9_PEDIDO  = NJ5.NJ5_NUMPV  AND
	cQuery += " SC9.C9_ITEM    = NJ5.NJ5_ITEM   AND
	cQuery += " SC9.C9_PRODUTO = NJ5.NJ5_PRODUT AND
	cQuery += " SC9.C9_SEQUEN  = NJ5.NJ5_SEQUEN
	cQuery += " WHERE SC9.C9_FILIAL = '" + fwxFilial("SC9") + " '"
	cQuery += " AND SC9.C9_PEDIDO   = '" + SC6->C6_NUM + "' "
	cQuery += " AND SC9.C9_ITEM     = '" + SC6->C6_ITEM + "' "
	cQuery += " AND SC9.C9_PRODUTO  = '" + SC6->C6_PRODUTO + "' "
	cQuery += " AND SC9.D_E_L_E_T_ = '' "
	cQuery += " AND NJ5.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	(cAliasQry)->(dbGoTop())
	IF (cAliasQry)->Existe = "1"
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} OGX225H
Função de chamada SQL com novo select para selecionar programações de entrega 
 aprovadas na montagem de carga(OMSA200)
@author joaquim.burjack
@since 01/02/2017
@type function
/*/
Function OGX225H()
	Local cQry := ""
	
	cQry += " INNER JOIN "+RetSqlName("NJ5")+" NJ5"
	cQry += " ON SC9.C9_FILIAL = NJ5.NJ5_FILIAL "
	cQry += " AND SC9.C9_PEDIDO = NJ5.NJ5_NUMPV    "
	cQry += " AND SC9.C9_ITEM   = NJ5.NJ5_ITEM     "
	cQry += " AND SC9.C9_SEQUEN = NJ5.NJ5_SEQUEN   "
	cQry += " AND SC9.C9_PRODUTO = NJ5.NJ5_PRODUT  "
	cQry += " AND NJ5.NJ5_DTPROG BETWEEN '" + DtoS(mv_par15) + "'"
	cQry += " AND '"+ DtoS(mv_par16) + "' "
	cQry += " AND NJ5.D_E_L_E_T_ = '' "
	cQry += " AND (NJ5.NJ5_STATUS = 2 OR NJ5.NJ5_STATUS = 3) "

Return cQry


/*/{Protheus.doc} OGX225I
// Responsável pela geração automática de agendamento(GFE) a partir da montagem de carga(OMS).
@author brunosilva
@since 10/02/2017
@version undefined
@param nOperation, numeric, descricao
@param cVeiculo, characters, descricao
@param cMotorista, characters, descricao
@param nRoman, numeric, descricao
@param cDakTransp, characters, descricao
@type function
/*/
Function OGX225I(nOperation,cVeiculo,cMotorista,cDakTransp,nRoman,cCarga,cSequen,cOper,cSeqOp,cMsg)
	Local aArea := GetArea()
	Local oModel := FWLoadModel("GFEA517")
	Local cSql := {}
	Local cRet
	Local lUpdnrom := OGX225VAL(DAK->DAK_CAMINH, DAK->DAK_COD, DAK->DAK_SEQCAR)
	Local lOG225TRA := ExistBlock('OG225TRA')
	Local lRet := .T.

	Default cDakTransp := Criavar("A4_COD",.F.)
	if (nOperation = 3 .or. nOperation = 4) .and. !Empty(cDakTransp) .and.  !Empty(cOper);
	.and. !Empty(cSeqOp)
		If lOG225TRA
			cRet := ExecBlock('OG225TRA',.F.,.F.)
			If ValType(cRet) == 'C'
				cDakTransp := cRet
			EndIf
		EndIf
		If ! lUpdnrom
			dbSelectArea("GWV")
			dbSetOrder(7)
			If !(dbSeek(FWxFilial("GWV")+nRoman))
				oModel:SetOperation( 3 )
				nNrAgen := GETSXENUM("GWV","GWV_NRAGEN")		
			Else
				oModel:SetOperation( 4 )
				nNrAgen := GWV->GWV_NRAGEN

			EndIf

			oModel:Activate()

			If !oModel:IsActive()
				cMsg := oModel:GetErrorMessage()[6]
				lRet := .F.
				RollBackSX8()
			Else
				cSql := " FROM  " + RetSqlName("NJ5") + " NJ5,  " + RetSqlName("SC9") + " SC9 "
				cSql += " WHERE SC9.C9_FILIAL = NJ5.NJ5_FILIAL "
				cSql += "  AND SC9.C9_PEDIDO = NJ5.NJ5_NUMPV    "
				cSql += "  AND SC9.C9_ITEM   = NJ5.NJ5_ITEM     "
				cSql += "  AND SC9.C9_SEQUEN = NJ5.NJ5_SEQUEN   "
				cSql += "  AND SC9.C9_PRODUTO = NJ5.NJ5_PRODUT  "
				cSql += "  AND SC9.C9_CARGA  = '"+ cCarga +"'   "
				cSql += "  AND SC9.C9_SEQCAR = '"+ cSequen +"'  "
				cSql += "  AND SC9.D_E_L_E_T_ = ''             "
				cSql += "  AND NJ5.D_E_L_E_T_ = ''             "

				oModel:SetValue('GFEA517_GWV', 'GWV_NRAGEN', nNrAgen )
				oModel:SetValue('GFEA517_GWV', 'GWV_SEQ', cSeqOp )
				oModel:SetValue('GFEA517_GWV', 'GWV_CDEMIT', cDakTransp )	
				oModel:SetValue('GFEA517_GWV', 'GWV_CDOPER', cOper)
				oModel:SetValue('GFEA517_GWV', 'GWV_DTAGEN', STOD(GetDataSql( "SELECT NJ5.NJ5_DTPROG" + cSql ) ))
				oModel:SetValue('GFEA517_GWV', 'GWV_HRAGEN', GetDataSql( "SELECT NJ5.NJ5_HRPROG" + cSql ) )
				oModel:SetValue('GFEA517_GWV', 'GWV_NRROM' , nRoman )

				//Inserção ddas tabela de Veiculo e Motorista!
				If !(Empty(M->GWN_CDTPVC))
					oModel:SetValue('GFEA517_GWY', 'GWY_NRAGEN', nNrAgen)
					oModel:SetValue('GFEA517_GWY', 'GWY_CDTPVC', M->GWN_CDTPVC)
				EndIf

				If !(Empty(M->GWN_CDMTR))
					oModel:SetValue('GFEA517_GX1', 'GX1_NRAGEN', nNrAgen)
					oModel:SetValue('GFEA517_GX1', 'GX1_CDMTR', M->GWN_CDMTR)
				EndIf

				//			If (oModel:GetOperation() = 3 .or.  oModel:GetOperation() = 4) .and. lRet
				//				If oModel:VldData()
				//					FWFORMCOMMIT(oModel)
				//					ConfirmSX8()
				//				Else                            
				//					cMsg := "Inconsistencia no agendamento de carga" + CRLF + CRLF + oModel:GetErrorMessage()[6]//
				//					lRet := .F.
				//				EndIf
				//			EndIf
				FWFORMCOMMIT(oModel)
				ConfirmSX8()
			EndIF
		Endif
	EndIf
	oModel:Deactivate()
	RestArea(aArea)
Return lRet


/*{Protheus.doc} OGX225L
Valida a Eliminação de um resíduo
@author jean.schulze
@since 27/09/2017
@version undefined

@type function
*/
Function OGX225L()
	Local lRet := OGX225G()
	if !lRet //temos NJ5 Vinculada
		Help(,, STR0009 /*"Atenção"*/,, "Não é possível eliminar resíduos de um pedido quando houver programação de entrega para o mesmo.", 1, 0 )		
	endif
return lRet

/*/{Protheus.doc} AGRMVCDel
// Função genérica p/ exclusão em telas MVC sem a explosão da tela.
@author brunosilva
@since 08/05/2017
@version undefined
@param cModel = Fonte que contem o Model onde será feita a exclusão.
@type function
/*/
Function AGRMVCDel(cModel)

	Local aErro := {}
	Local oModel := FwLoadModel(cModel)

	If MSGYESNO( "Atenção", "Confirmar a exclusão?" )
		oModel:SetOperation(MODEL_OPERATION_DELETE)
		//Executa a validação real de exclusão
		If !oModel:Activate() .Or. !oModel:VldData()
			aErro := oModel:GetErrorMessage()
			Help(,, "Atenção",,( AllToChar(aErro[6]) + CRLF +;
			AllToChar(aErro[7]) + CRLF + CRLF +;
			"Campo: " + AllToChar(aErro[2]) + CRLF +;
			"Valor: " + AllToChar(aErro[9])) , 1, 0 )
			oModel:DeActivate()
			FreeObj(oModel)
		Else
			oModel:CommitData()
			oModel:DeActivate()
			FreeObj(oModel)
		End
	End
Return 

/*/{Protheus.doc} OGX225NF
// Responsável pelo tratamento da moeda que vai pra nota fiscal se o PV for gerado 
// por um Acordo de troca. (Moeda  = NKT_VRPAUT) e não a moeda do dia.
@author brunosilva
@since 24/05/2017
@version undefined
@type function
/*/
Function OGX225MOE()
	Local aArea    := GetArea()
	Local nRet     := nOgTxTroca
	Local cTrc     := Nil

	cTrc := Posicione("SC5",1,FWxFilial("SC5")+SC5->C5_NUM,"C5_TRCNUM")
	If !Empty(cTrc)
		nRet := Posicione("NKT",1,FWxFilial("NKT")+cTrc,"NKT_VRPAUT")
	EndIf

	RestArea(aArea)
Return nRet

/*/{Protheus.doc} OGX225J
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 15/08/2017
@version undefined
@param aParam, array, descricao
@type function
/*/
Function OGX225J(aParam)
	Local nPrcVen	:= aParam[1]
	Local nPrUnit	:= aParam[2]
	Local aVar	 	:= {}
	Local x1        := 0
	Local aLPvlNfs  := aParam[3]
	Local lUltimo   := .F.
	Local lAdd      := .T.
	Local Dolly     := {}

	Private nTam       := len(aLPvlNfs)
	Private nTamI1     := len(aLPvlNfs[1])    
	Private nOgTxTroca := 0
	Private nTotDocOM  := 0
	If Empty(SC9->C9_CARGA)
		Return aParam
	Else
		If !(IsInCallStack("AGRA900"))
			Private lOGNFTRC := (SuperGetMV("MV_AGRUBS"))
		EndIf 

		nTotDocOM += a410Arred( SC9->C9_PRCVEN   *  SC9->C9_QTDLIB    ,"C6_VALOR")

		For x1 := 1 to nTamI1
			If ValType(aLPvlNfs[1, x1]) = 'A' .AND. Len(aLPvlNfs[1, x1]) = 3 
				lAdd := !(aLPvlNfs[1, x1, 1] == "nTRCTotMER")
			EndIf
		Next x1 

		If lAdd  
			//Adiciono um novo elemento no ponteiro do Array que deve guardar
			//a somatória do valor das mercadorias como a variável nTRCTotMER (agra900)
			aAdd( aLPvlNfs[1], {"nTRCTotMER", 0, 0} )
			nTamI1 := nTamI1 + 1
		EndIF

		//---- Agroindustria
		// Para Levar para o padrão devo  Copiar o IF Inteiro e ajustar na altura o m460prc, para averiguar se é do trocas
		If FindFunction("OGXUtlOrig") 		//Encontra a função
			If OGXUtlOrig()					// Retorna se tem integração com Agro/originação modulo 67
				If (FindFunction("fOGTxBart1"))	//Encontra a função
					aVar 	 := fOGTxBart1(aParam[1], aParam[2], aLPvlNfs )   // preço de venda e  preço unitario
					nPrcVen  := aVar[1]
					nPrUnit  := aVar[2]
					aLPvlNfs := aVar[3]
					lUltimo  := aVar[4]
				EndIf
			EndIf
		EndIf
		//------

		If lUltimo
			//Como o Array aLPvlNfs[]1] foi descaracterizado para guardar o total das mercadorias,
			//este elemento é eliminado voltando ao tamanho original
			Dolly := aClone(aLPvlNfs[1])
			aLPvlNfs[1] := {}
			x1 := 0
			For x1 := 1 to nTamI1 - 1
				aAdd(aLPvlNfs[1], Dolly[x1])
			Next x1
		EndIf
	Endif
Return aVar

/** {Protheus.doc} OGX
Rotina para Calculo da Conversão utilizando a
Taxa de moeda especifica do Acordo de Trocas

@param:		-   Preço de Venda
-	Preço Unitario
@Retorno: 	-	Array com 2 posicoes
-	Array[1]	-> Preço de    Venda Convertido pela Txa do Acordo Trocas
-	Array[2]	-> Preço 	Unitario Convertido pela Txa do Acordo Trocas
@author: 	-	Equipe AgroIndustria
@since: 	-	10/08/2016
@Uso: 		-	SIGAARM - Originação de Grãos
*/
Function fOGTxBart1(pPrcVenda, pPrcUnit, pPvlNfs)

	Local nMenorVrUn	:= 0
	Local nPrcVenda	 := pPrcVenda
	Local nPrcUnit	 := pPrcUnit

	Local nC6Qtdven	 := SC6->C6_QTDVEN
	Local nC6VALOR	 := SC6->C6_VALOR
	Local nTotItem   := A410ARRED(xMoeda(nC6VALOR,SC5->C5_MOEDA,1,ddatabase,8) ,'D2_TOTAL')
	Local cDocUltIt	 :=  pPvlNfs[nTam, 1 ] + pPvlNfs[nTam, 2 ]  //Identifica o ultimo item que compoe a NF ( SC9->C9_PEDIDO,SC9->C9_ITEM )
	Local lUltimo    := .F.
	Local nTRCTotMER := pPvlNfs[1, nTamI1, 2 ]	
	Local nTRCTotDoc := pPvlNfs[1, nTamI1, 3 ]
	Local lTemTrc 	 := .F.

	If FindFunction("OGX225MOE") .AND. (SuperGetMV("MV_AGRUBS"))
		nOgTxTroca := OGX225MOE()

		if nOgTxTroca > 0
			lTemTrc := .T.
			nTotItem   := A410ARRED(nC6Valor * nOgTxTroca, 'D2_TOTAL')
		endIf
	EndIf

	if lTemTrc 
		nTRCTotDoc +=  A410ARRED( nTotDocOM * nOgTxTroca, 'D2_TOTAL' )
		pPvlNfs[1, nTamI1, 3 ]	:= nTRCTotDoc

		//----Variavel Private Agra900 -----

		If Type("lOGNFTRC") == "L" .and.  lOGNFTRC == .t. // Indica que é um processo do Trocas

			/*	IF ! Type("nTRCTotMER") == "N"    // tem q vir do AGRA900
			_SetNamedPrvt( "nTRCTotMER" 	, 0 										, "MAPVLNFS" )   	// Total das Mercadorias Pela NF
			_SetNamedPrvt( "nOgTxTroca" 	, 61									, "MAPVLNFS" )   		// Txa Utilizada no Acordo de Trocas
			_SetNamedPrvt( "nTrcTotDoc"		, A410ARRED( 1834.25 * nOgTxTroca, 'D2_TOTAL' )	, "MAPVLNFS" )	// total das Mercadorias Pelo PV
			_SetNamedPrvt(  "cDocUltIt"		, '01488105' 								, "MAPVLNFS" )   	// identifica o Ultimo item Do Docto SC6->(C6_PEDIDO + C6_ITEM)
			EndIF
			*/		

			nPrcVenda	:=  a410arred(nTotItem / nC6Qtdven, 'D2_PRCVEN')

			nPrcVenda 	:=  fOGChkBar1(nPrcVenda , nOgTxTroca,.F. )

			nTotItem   	:= A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	//Total Calc. do Item

			nTotDocOM += a410Arred( SC9->C9_PRCVEN   *  SC9->C9_QTDLIB    ,"C6_VALOR")

			IF SC6->(C6_NUM + C6_ITEM ) == cDocUltIt // É o Ultimo item do Faturamento da Troca					
				lUltimo    := .T.
				IF ! ( nTRCTotMER +  nTotItem ) = nTrcTotDoc	// Indica que o Total da NF. em Moeda 1, NAO Bate com o 
					// Total de Moeda 1 encontrado pelo total dos itens que compoe a NF x pela taxa do trocas
					// Ex total Doc (Baseando em um PV) = 256,24 * Taxa Troca = 66,436 = (256,24 * 66,436 = 17023,56)
					// Tenho que ter o total da NF. exatamente Igual para garantir a Taxa do Trocas 
					//Ajustando o Arredondamento
					nMenorVrUn := 1/VAL('1'+STRZERO(0,TamSx3('C6_PRCVEN')[2]))	// Menor unidade a Adicionar no Vr. Unitario
					IF ( nTRCTotMER +  nTotItem ) > nTrcTotDoc    				// Indica que o Total Calc. na NF. está maior entao tenho q diminuir o Vr. unitario
						nMenorVrUN *= (-1 ) 	//Tenho q Subtrair
					EndIF
					nCalc := ( nTRCTotMER +  nTotItem ) - nTrcTotDoc

					While (nCalc  != 0)//( nTRCTotMER +  nTotItem ) = nTrcTotDoc	
						/*If ABS(nCalc) > 0.1
						nMenorVrUN := 0.1

						ElseIf ABS(nCalc) > 0.01
						nMenorVrUN := 0.01

						ElseIf ABS(nCalc) > 0.001
						nMenorVrUN := 0.001

						ElseIf ABS(nCalc) > 0.0001
						nMenorVrUN := 0.0001

						Else*/
						If ABS(nCalc) > 0.00001
							nMenorVrUN := 0.00001

						ElseIf ABS(nCalc) > 0.000001
							nMenorVrUN := 0.000001
						EndIf

						IF nCalc > 0
							nMenorVrUN *= (-1 )
						Else
							nMenorVrUN *= ( 1 )
						EndIF			

						nPrcVenda += nMenorVrUN
						nTotItem  := A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	

						nCalc := ( nTRCTotMER +  nTotItem ) - nTrcTotDoc
					EndDO

					nPrcVenda 	:=  fOGChkBar1(nPrcVenda , nOgTxTroca,.T. )

				EndIF

			ELSE
				nTRCTotMER   += nTotItem
				pPvlNfs[1, nTamI1, 2] := nTRCTotMER 
			EndIF
			nPrcUnit := nPrcVenda
		Else // Mesmo não sendo de troca tenho q converter pois estou utilizando o PE, para o padrao devo tirar fora
			nPrcVen	:= xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8)
			nPrUnit	:= xMoeda(nPrUnit,SC5->C5_MOEDA,1,dDataBase,8)
		EndIF
	endIf

return ( {nPrcvenda, nPrcunit, pPvlNfs, lUltimo  } )


/** {Protheus.doc} OGX
Função Auxiliar para Averiguar que o vr. de venda/unitario
encontrado na conversão; Se dividido pela taxa de conversão 
resulte no valor unitario do PV;

@param:		-   nPrcVenda	-	Preço de Venda
-	nOgTxTroca	-	Txa de Conversão
-   lUltimItem	-	Indica se é o ultimo Item do docto fiscal
@Retorno: 	-	Preço de Venda
@author: 	-	Equipe AgroIndustria
@since: 	-	10/08/2016
@Uso: 		-	SIGAARM - Originação de Grãos
*/
Function fOGChkBar1(nPrcVenda , nOgTxTroca, lUltimItem )
	Local nMenorVrUn	:= 0
	Local nTotitem		:= 0
	Local nPrcVndAux	:= 0
	Local nValor        := 0

	nMenorVrUn := 1/VAL('1'+STRZERO(0,TamSx3('C6_PRCVEN')[2]))			// Menor unidade a Adicionar no Vr. Unitario

	IF ! a410arred(nPrcVenda / nOgTxTroca, 'C6_PRCVEN') = SC9->C9_PRCVEN .and. ! lUltimItem 	// Indica que o Vr. Unitario encontrado convertido para
		// a Moeda do PV não está correspondente ao do PV
		//Garanto q o Vr. unitario encontrato , qdo convertido para MOEDA do PV
		// Fique igual ao do PV
		IF a410arred(nPrcVenda / nOgTxTroca, 'C6_PRCVEN') > SC9->C9_PRCVEN  // Indica que o Vr. Unitario na Moeda do PV esta <  que o Vr. que está no PV
			nMenorVrUN *= (-1 ) 	//Tenho q Subtrair
		EndIF

		nValor := A410ARRED( nPrcVenda / nOgTxTroca, 'C6_PRCVEN') 
		While ! nValor  = SC9->C9_PRCVEN
			/*If (SC9->C9_PRCVEN - nValor ) > 0.001
			nMenorVrUN := 0.001
			ElseIf (SC9->C9_PRCVEN - nValor) > 0.0001
			nMenorVrUN := 0.0001
			Else*/If (SC9->C9_PRCVEN - nValor) > 0.00001
			nMenorVrUN := 0.00001
		ElseIf (SC9->C9_PRCVEN - nValor) > 0.000001
			nMenorVrUN := 0.000001
		EndIf

		nPrcVenda += nMenorVrUN
		nValor := A410ARRED( nPrcVenda / nOgTxTroca, 'C6_PRCVEN')
	EndDO

	IF nMenorVrUn > 0
		nMenorVrUN *= (-1 )
	Else
		nMenorVrUN *= ( 1 )
	EndIF

	nTotItem   	:= A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	//Total Calc. do Item

	nPrcVndAux := nPrcVenda
	While (.t.)
		IF A410ARRED( nPrcVndAux * SC9->C9_QTDLIB, 'D2_TOTAL') == nTotItem .and.;
		A410ARRED( nPrcVndAux / nOgTxTroca, 'C6_PRCVEN') == SC9->C9_PRCVEN
			nPrcVenda := nPrcVndAux
			nPrcVndAux += nMenorVrUN
		Else
			Exit
		EndIF
	EndDO
	ElseIF lUltimItem // Quando é o Ultimo 
		nTotItem   	:= A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	//Total Calc. do Item

		nPrcVndAux := nPrcVenda
		While (.t.)
			nPrcVndAux += nMenorVrUN
			IF A410ARRED( nPrcVndAux * SC9->C9_QTDLIB, 'D2_TOTAL') == nTotItem
				Exit
			Else
				nPrcVenda := nPrcVndAux
			EndIF
		EndDO
	EndIF

Return( nPrcVenda )		

/*/{Protheus.doc} OGX225VAL
// Realiza validações na montagem de carga.
@author marcelo.wesan
@since 08/06/2018
@version undefined
@param caracter
@type function
/*/

Function OGX225VAL(cVeiculo, cCarga, cSequen)
	Local aArea     := GetArea()
	Local lRet      := .F.
	Local cRomaneio := ""
	Local cOper     := ""
	lOCAL cSeq      := ""


	Pergunte("OMS200C",.F.)
	//TODO Refatorar-> nao esta performatico
	//Inserindo uma transação para garantir integridade da gravação
	//	Begin transaction
	cCarga := IIF((cCarga <> nil .and. cSequen <> nil),StrZero(Val(cCarga + cSequen),TAMSX3("GWN_NRROM")[1]),"")
	If ! Empty(cVeiculo) .and. !Empty(cCarga) .and. !FWIsInCallStack("Os200Estor")
		dbselectarea('GX6')
		GX6->(dbSetOrder(2))
		GX6->(dbGoTop())
		If GX6->(DbSeek(FwxFilial("GX6") + cVeiculo ))
			While GX6->(!Eof()).AND. GX6->GX6_FILIAL = FwxFilial("GX6") .AND. ALLTRIM(GX6->GX6_CDVEIC) = ALLTRIM(cVeiculo)
				GX3->(dbSetOrder(1))
				If GX3->(DbSeek(FwxFilial("GX3") + GX6->GX6_NRMOV ))
					If !(GX3->GX3_SIT $ "5|6") 
						GWV->(dbSetOrder(4))
						GWV->(DbSeek(FwxFilial("GWV") + GX6->GX6_NRMOV ))
						cRomaneio:= GWV->GWV_NRROM
						cOper    := GWV->GWV_CDOPER
						cSeq     := GWV->GWV_SEQ
						If allTrim(cOper) = allTrim(MV_PAR02) .AND. allTrim(cSeq) = allTrim(MV_PAR03)
							GWV->(dbSetOrder(7))
							If GWV->(DbSeek(FwxFilial("GWV")+ cRomaneio))
								GWN->(dbSetOrder(1))
								If !GWN->(MsSeek(FwxFilial("GWN")+ cRomaneio))
									If RecLock('GWV',.F.)
										GWV->GWV_NRROM := cCarga 
										lRet := VinculaLotes(GWV->GWV_NRMOV)
										GWV->(MsUnlock())
										If ! FWIsInCallStack("Os200Assoc")
											MsgInfo(STR0013 + cVeiculo + STR0014)
										EndIF
									Endif
								Endif
							Endif
						EndIf		
					EndIf			
				Endif	
				GX6->(DbSkip())
			EndDo
		EndIf	
	EndIf	
	//		If !lRet
	//			DisarmTransaction()
	//		Endif
	//	End Transaction
	Pergunte("OMS200",.F.)
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} OGX225CANC
//Realiza o cancelamento do agendamento.
@author marcelo.wesan
@since 08/06/2018
@version undefined
@param caracter
@type function
/*/
Function OGX225CANC(cCodCar,cSeqCar)

	Local aArea     := GetArea()
	Local cRomaneio := cCodCar + cSeqCar
	Local lRet      := .T.

	dbselectarea('GWV')
	GWV->(dbSetOrder(7))
	If  GWV->(MsSeek(FwxFilial("GWV")+ cRomaneio ))
		GFEA517CAN()
	EndIf
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} OGX225VEI
// Valida se existe carga.
@author marcelo.wesan
@since 11/06/2018
@version undefined
@param caracter
@type function
/*/
Function OGX225VEI()

	Local aArea     := GetArea()
	Local lRet      := .T.
	Local cRomaneio := GWV->GWV_NRROM

	GWN->(dbSetOrder(1))
	If ! GWN->(DbSeek(FwxFilial("GWN")+ cRomaneio))
		lRet  := .F.
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} OGX225MNU
//Menu OMSA200(Montagem de Cargas) incluido para chamada de seleção de lotes vinculada a carga posicionada
@author joaquim.burjack
@since 05/06/2018
@version 1.0
@return ${return}, ${return_description}
@param aRotina, array, descricao
@type function
/*/
Function OGX225MNU(aRotina)

	aadd(aRotina,{STR0012,"OGX225SL" , 0 , 3,0,NIL})

Return aRotina

/*/{Protheus.doc} OGX225BW
//Chamada de edição da Seleção de Lotes(AGRA870) 
@author joaquim.burjack
@since 08/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGX225SL()
	Local aArea := GetArea()
	Local cCarga := DAK->DAK_COD //+ DAK->DAK_SEQCAR
	NJ6->(DbSetOrder(1))
	NJ6->(DbSeek(FwXfilial("NJ6") + cCarga,.F.))
	AGRA870PSQ()
	RestArea(aArea)
Return

/*/{Protheus.doc} OGX225MSG
// Valida se existe carga.
@author marcelo.wesan
@since 18/06/2018
@version undefined
@param caracter
@type function
/*/

Function OGX225MSG()

	Help(,,STR0009,, STR0015 , 1, 0 )//Atenção Não é possivel concluir pois não existe carga

Return .F.

/*/{Protheus.doc} OGX225AGE
//Valida o cancelamento do agendamento.
@author marcelo.wesan
@since 18/06/2018
@version undefined
@param caracter
@type function
/*/
Function OGX225AGE()
	//identifico que nao foi cancelado ainda no GFE
	GWV->(dbSetOrder(7))
	If ( GWV->(DbSeek(FwxFilial("GWV")+ DAK->DAK_COD + DAK->DAK_SEQCAR)) .and. GWV->GWV_SIT <> "3"  )
		//Flag de item em Patio para localizar na hora de refazer o vinculo - NJ6_STATUS = "P"
		NJ6->(dbSetOrder(1))
		NJ6->(dbGoTop())
		If ( NJ6->(DbSeek(FwxFilial("NJ6")+ DAK->DAK_COD + DAK->DAK_SEQCAR))  )
			While NJ6->(!Eof()) .and. NJ6->NJ6_FILIAL = FwxFilial("NJ6") .and. NJ6->NJ6_CODCAR = DAK->DAK_COD .and. Empty(NJ6->NJ6_STATUS)
				If RecLock('NJ6',.F.)
					NJ6->NJ6_STATUS := 'P'
					NJ6->(MsUnlock())
				Endif
				NJ6->(DbSkip())
			EndDo
			//"Deseja manter o agendamento? Se opção escolhida for não, o agendamento será cancelado e será necessário realizar um novo agendamento para o veículo."
			If ! MsgYesNo(STR0016,OemToAnsi(STR0009)) 
				//Cancelamento de agendamento
				Processa( { || OGX225CANC(DAK->DAK_COD,DAK->DAK_SEQCAR) }, STR0009, STR0017 )
			EndIf
		Endif	
	Endif
Return
Static Function VinculaLotes(cNrMov)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local cChaveNJS
	Local cChvCarga
	Local cChvPedido
	Local cChvItPedido

	//Localizo a carga antiga atraves da NJS utilizando o Numero do movimento(cNrMov)
	NJS->(dbSetOrder(1))
	NJS->(dbGoTop())
	If NJS->(DbSeek(FwxFilial("NJS") + cNrMov ))
		While NJS->(!Eof()) .and. NJS->NJS_FILIAL = FwxFilial("NJS") .and. NJS->NJS_NRMOV = cNrMov  
			// Se localizou armazena dados da carga estornada (antiga)
			cChaveNJS 	:= NJS->NJS_CHAVE
			cChvCarga	:= Substr(cChaveNJS,2 + TAMSX3("NJS_FILIAL")[1],TAMSX3("DAK_COD")[1])
			cChvPedido	:= Substr(cChaveNJS,2 + TAMSX3("NJS_FILIAL")[1] + 1 + TAMSX3("DAK_COD")[1] + 1 + TAMSX3("DAK_SEQCAR")[1] ,TAMSX3("NJ6_NUMPV")[1])
			cChvItPedido:= Substr(cChaveNJS,2 + TAMSX3("NJS_FILIAL")[1] + 1 + TAMSX3("DAK_COD")[1] + 1 + TAMSX3("DAK_SEQCAR")[1] + 1 + TAMSX3("NJ6_NUMPV")[1] ,TAMSX3("NJ6_ITEM")[1])
			If RecLock('NJS',.F.)
				// Altero a carga da chave da NJS			
				NJS->NJS_CHAVE  := StrTran( cChaveNJS, cChvCarga, DAK->DAK_COD, , 1 )
				If NJ6->(DbSeek(FwxFilial("NJ6") + cChvCarga + DAK->DAK_SEQCAR + cChvPedido + cChvItPedido ))
					While NJ6->(!Eof()) .and. NJ6->NJ6_FILIAL = FwxFilial("NJ6") .and. NJ6->NJ6_CODCAR = cChvCarga .and. NJ6->NJ6_NUMPV = cChvPedido .and. NJ6->NJ6_ITEM = cChvItPedido;
					.and. NJ6->NJ6_STATUS = "P"
						//Altero a carga da NJ6
						If RecLock('NJ6',.F.)
							NJ6->NJ6_CODCAR := DAK->DAK_COD
							NJ6->NJ6_STATUS := " "
							NJ6->(MsUnlock())
						Endif
						NJ6->(DbSkip())
					EndDo 
					NJS->(MsUnlock())
				Endif			
				NJS->(DbSkip())
			Endif
		EndDo
	Endif
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} OGX225RES
//Desfaz a reserva utilizada durante a Seleção de lotes na expedição MOD II
@author joaquim.burjack
@since 20/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGX225RES(cCarga)
	Local aArea		:= GetArea()
	Local aAreaSC9	:= SC9->(GetArea())
	SC9->(dbSetOrder(5))
	SC9->(dbGoTop())
	If SC9->(DbSeek(FwxFilial("SC9") + cCarga ))
		While SC9->(!Eof()) .and. SC9->C9_FILIAL = FwxFilial("SC9") .and. SC9->C9_CARGA = cCarga 
			If !Empty(SC9->C9_RESERVA) .and. AGRIFDBSEEK("SC0",SC9->C9_RESERVA + SC9->C9_PRODUTO + SC9->C9_LOCAL,1,.F.)
				If a430Reserv({3,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},SC0->C0_NUM,SC0->C0_PRODUTO,SC0->C0_LOCAL,SC0->C0_QUANT,;
				{SC0->C0_NUMLOTE,SC0->C0_LOTECTL,SC0->C0_LOCALIZ,SC0->C0_NUMSERI})
				ENdif
			Endif
			SC9->(DbSkip())
		EndDo
	Endif
	RestArea(aArea)
	RestArea(aAreaSC9)
Return
