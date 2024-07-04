#Include 'TOTVS.CH'

/*{Protheus.doc} AGRA870X
Funções Genericas chamadas no AGRA870A
*/
Function Agra870X
//função dummy
Return()


//Função que faz a soma
Function AGr870X1(cCodSaf, cLote,cSubLote, cUM)

Local cQryND6		:= GetNextAlias()
Local cQryNJ6		:= GetNextAlias()
Local cQrySC9		:= GetNextAlias()

Local nQTPVRESER	:=0
Local nQtDirec		:=0
Local nQtPvLbEst	:= 0

Local lloteDirec    := .f.

//Verifica Qt. direcionada do Lote
BeginSQL Alias cQryND6
	SELECT SUM(ND6.ND6_QT) AS QTDIRECIONADA FROM  %Table:ND5% ND5
		INNER JOIN  %Table:ND6% ND6
				ON ND6.%notDel%
			AND ND6.ND6_FILIAL = %xFilial:ND6% 
			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
		INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
			ON SC5.%notDel%
			AND SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
			AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
		WHERE ND5.%notDel%
		AND ND5.ND5_STATUS = '1'
		AND ND5.ND5_FILIAL = %xFilial:ND5% 
		AND ND5.ND5_UM     = %Exp:cUM%
		AND ND6.ND6_LOTE   = %Exp:cLote%
		AND ND6.ND6_SUBLOT = %Exp:cSubLote%
		AND ND5.ND5_CODSAF = %Exp:cCodSaf%
EndSQL

nQtDirec	:= 	(cQryND6)->QTDIRECIONADA

( cQryND6 )->( DbCloseArea() )


cQryND6		:= GetNextAlias()
//Verifica Qt. direcionada do Lote que se encontra em status de substituir ( o pedido nestes casos foi excluido )
BeginSQL Alias cQryND6
	SELECT SUM(ND6.ND6_QT) AS QTDIRECIONADA FROM  %Table:ND5% ND5
		INNER JOIN  %Table:ND6% ND6
				ON ND6.%notDel%
			AND ND6.ND6_FILIAL = %xFilial:ND6% 
			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
		WHERE ND5.%notDel%
		AND ND5.ND5_STATUS = '3'   //Direcionamento que se encontra em substituir
		AND ND5.ND5_FILIAL = %xFilial:ND5% 
		AND ND5.ND5_UM     = %Exp:cUM%
		AND ND6.ND6_LOTE   = %Exp:cLote%
		AND ND6.ND6_SUBLOT = %Exp:cSubLote%
		AND ND5.ND5_CODSAF = %Exp:cCodSaf%
EndSQL

nQtDirec += (cQryND6)->QTDIRECIONADA

( cQryND6 )->( DbCloseArea() )


IF nqtDirec == 0 //indica que não tem nada direcionado a considerar.
   Return lloteDirec
EndIF


// Verificando a quantidade dos pedidos direciondos que estão em Reserva ou em processo de faturamento

BeginSQL Alias cQryNJ6

	SELECT SUM(NJ6.NJ6_QTDE)  AS QTPVRESERV FROM %Table:NJ6%  NJ6
			INNER JOIN %Table:ND5% ND5 
				ON ND5.%notDel%
			AND ND5.ND5_FILIAL = %xFilial:ND5% 
			AND ND5.ND5_STATUS = '1'
			AND ND5.ND5_CODSAF = %Exp:cCodsaf%
			AND ND5.ND5_PEDIDO = NJ6.NJ6_NUMPV
			AND ND5.ND5_ITEM   = NJ6.NJ6_ITEM
			AND ND5.ND5_UM	   = %Exp:cUM%
		INNER JOIN %Table:ND6%  ND6 
			ON  ND6.%notDel%
			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO 
			AND ND6.ND6_FILIAL = ND5.ND5_FILIAL 	
			AND ND6.ND6_PEDIDO = ND5.ND5_PEDIDO
			AND ND6.ND6_ITEMPV = ND5.ND5_ITEM
			AND ND6.ND6_CODSAF = ND5.ND5_CODSAF 
			AND ND6.ND6_LOTE   = %Exp:cLote%
			AND ND6.ND6_SUBLOT = %Exp:cSubLote%
		INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
			ON SC5.%notDel%
			AND SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
			AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')				
		WHERE NJ6.%notDel%
			AND NJ6.NJ6_LOTECT = %exp:cLote%
			AND NJ6.NJ6_NMLOTE = %exp:cSubLote%
			AND NJ6.NJ6_FILIAL = %xFilial:NJ6%
EndSQL

nQTPVRESER 	:=  (cQryNJ6)->QTPVRESERV

( cQryNJ6 )->( DbCloseArea() )

// Verificando a quantidade dos pedidos ja se contra faturado / em faturamento. ( SC9 )

BeginSQL Alias cQrySC9

 		SELECT SUM(C9_QTDLIB) QtPvLbEst
			FROM %Table:SC9%  SC9
			INNER JOIN %Table:ND5% ND5 
			    ON ND5.%notDel%
				AND ND5.ND5_FILIAL = %xFilial:ND5% 
				AND ND5.ND5_STATUS = '1'
				AND ND5.ND5_CODSAF = %Exp:cCodsaf%
				AND ND5.ND5_PEDIDO = SC9.C9_PEDIDO
				AND ND5.ND5_ITEM   = SC9.C9_ITEM
				AND ND5.ND5_UM     = %exp:cUM%
			INNER JOIN %Table:ND6%  ND6 
			    ON  ND6.%notDel%
				AND ND6.ND6_CODIGO = ND5.ND5_CODIGO 
				AND ND6.ND6_FILIAL = ND5.ND5_FILIAL 	
				AND ND6.ND6_PEDIDO = ND5.ND5_PEDIDO
				AND ND6.ND6_ITEMPV = ND5.ND5_ITEM
				AND ND6.ND6_CODSAF = ND5.ND5_CODSAF 
				AND ND6.ND6_LOTE   = %exp:cLote%
				AND ND6.ND6_SUBLOT = %exp:cSubLote%
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
			WHERE SC9.%notDel%
			AND SC9.C9_FILIAL = %xFilial:SC9% 
			AND SC9.C9_BLEST <> '02'
		    AND   //Disconsidero se existe sc9 com reserva referenciada  que ainda não foi deletada.
				( SELECT COUNT (SC0.C0_NUM) FROM  %Table:SC0% SC0
				WHERE SC0.%notDel%
				AND   SC0.C0_NUM = SC9.C9_RESERVA
				AND   SC0.C0_FILIAL = %xFilial:SC0% 
				) = 0 
EndSQL

nQtPvLbEst  :=  (cQrySC9)->QtPvLbEst

( cQrySC9 )->( DbCloseArea() )

IF  (nQtDirec > (nQTPVRESER + nQtPvLbEst)  )  // as Reservas de PVs e possiveis liberações de estoque (sc9)  ( de Pvs. direcionados ) devem ser desconsideradas da qt direcionada...
    lloteDirec := .t.
EndIF	

Return ( lloteDirec )
