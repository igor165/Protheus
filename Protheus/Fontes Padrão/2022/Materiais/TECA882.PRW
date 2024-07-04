#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA881.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA882

Realiza a listagem das Munições
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA882()

Local oDlg			:= Nil								// Dialog Principal
Local aSize		:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local oBrw			:= Nil								// Objeto do Browse
Local oBrwM		:= Nil								// Objeto do Browse
Local aColumns	:= {}								// Array com as colunas para o browse
Local aList		:= {}								// Array com os dados a serem apresentados
Local oColumns	:= Nil
Local lPerg		:= .T.

//Ativa o Pergunte
lPerg := Pergunte("TECA882",.T.)

If !lPerg
	Return
EndIf

//Cria o Array para exibição dos dados
MsgRun(STR0005,STR0004,{ || aList := At882QryMun() })	


//Atualiza o Array em Ordem Numerica
asort(aList,,, {|x,y| x[2] < y[2] }) 

//Cria a tela para o browse
DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL //"Lista de Disponibilidade"
	
	DEFINE FWFORMBROWSE oBrwM DATA ARRAY ARRAY aList LINE BEGIN 1 OF oDlg
		
		
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][1] }") TITLE ""	SIZE 1 PICTURE "@BMP" IMAGE OF oBrwM
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][2] }") TITLE TxSX3Campo("TE2_CODPRO")[1] 	SIZE TamSX3("TE2_CODPRO")[1] 	OF oBrwM
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][3] }") TITLE TxSX3Campo("B1_DESC")[1] 	    SIZE TamSX3("B1_DESC")[1] 	    OF oBrwM          													
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][4] }") TITLE TxSX3Campo("TER_CODIGO")[1] 	SIZE TamSX3("TER_CODIGO")[1] 	OF oBrwM   
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][5] }") TITLE TxSX3Campo("TER_DESCRI")[1] 	SIZE TamSX3("TER_DESCRI")[1] 	OF oBrwM   
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][6] }") TITLE TxSX3Campo("TFP_SALDO")[1]	    SIZE TamSX3("TFP_SALDO")[1] 	OF oBrwM   
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][7] }") TITLE TxSX3Campo("TE2_LOTE")[1]	    SIZE TamSX3("TE2_LOTE")[1]  	OF oBrwM   
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][8] }") TITLE TxSX3Campo("TFQ_ORIMUN")[1]	    SIZE TamSX3("TFQ_ORIMUN")[1]	OF oBrwM 
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][9] }") TITLE TxSX3Campo("TFQ_DESTIN")[1]	    SIZE TamSX3("TFQ_DESTIN")[1]	OF oBrwM 
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][10] }") TITLE TxSX3Campo("TFQ_DMOVIM")[1]	SIZE TamSX3("TFQ_DMOVIM")[1] 	OF oBrwM   
		ADD COLUMN oColumns DATA &("{ || aList[oBrwM:At()][11] }") TITLE TxSX3Campo("TFO_DTRET")[1]	    SIZE TamSX3("TFO_DTRET")[1] 	OF oBrwM   	
		
		//Adiciona o Botão para a Legenda
		ADD Button oBtLegend Title STR0002 Action "At882LegMun()" OPERATION MODEL_OPERATION_VIEW   Of oBrwM //"Legenda"
			
		//Adiciona o Botão para a Legenda
		ADD Button oBtRefresh Title STR0003 Action {|| At882Refresh(aList,oBrwM)} OPERATION MODEL_OPERATION_VIEW   Of oBrwM //"Legenda"
		
			
	ACTIVATE FWFORMBROWSE oBrwM
		
	
ACTIVATE DIALOG oDlg CENTERED

Return (.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882QryMun

Verifica a disponibilidade das munições
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At882QryMun()
Local aRet := {}

aRet := At882Qry23()

Return aRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882Qry23

Verifica a disponibilidade das munições
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At882Qry23()
Local aRet		:= {}
Local cAlias	:= GetNextAlias()

If Select("cAlias") > 0 
	(cAlias)->(DbCloseArea())
Endif

If MV_PAR03 == 1
	cWhere := "% TFP.TFP_ENTIDA = '1' " 
	cWhere += "AND TFP.TFP_MOVIM = '1' "
	If !Empty(MV_PAR04) .And. !Empty(MV_PAR05)
		cWhere += " AND TFP.TFP_CODINT   BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' " 	
	EndIf
	cWhere += " %"	
Else
	cWhere := "% TFQ.TFQ_ENTDES = '1' "
	If !Empty(MV_PAR04) .And. !Empty(MV_PAR05)
		cWhere += " AND TFQ.TFQ_DESTIN   BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' " 	
	EndIf
	cWhere += " %"	
EndIf

If MV_PAR03 == 1
	BeginSQL alias cAlias
		SELECT 
			TFP.TFP_CODIGO,
			TFP.TFP_CODINT,
			TFP.TFP_SALDO,
			TFP.TFP_LOTE,
			TFP.TFP_PRODUT,
			SB1.B1_DESC,
			TER.TER_DESCRI
		FROM
			%Table:TFP% TFP
		INNER JOIN 
			%Table:TER% TER  
		ON 
			TER.TER_FILIAL = %xfilial:TER% 
		AND 
			TER.TER_CODIGO = TFP.TFP_CODINT
		AND 
			TER.%NotDel%
		INNER JOIN 
			%Table:SB1% SB1 
		ON 
			SB1.B1_FILIAL = %xfilial:SB1% 
		AND 
			SB1.B1_COD = TFP.TFP_PRODUT
		AND 
			SB1.%NotDel%			
		WHERE
				TFP.TFP_FILIAL = %xfilial:TFP%
			AND
				TFP.TFP_SALDO > 0
			AND
				TFP.TFP_STATUS = '1' 	
			AND
				%Exp:cWhere%
			AND
				TFP.%NotDel%
	EndSQL	

	While (cAlias)->(!Eof())
		
		//Verifico aonde estão as munições
		AAdd( aRet, { "BR_VERDE" ,;
			(cAlias)->TFP_PRODUT,;
			(cAlias)->B1_DESC,;	
			(cAlias)->TFP_CODINT ,;
			(cAlias)->TER_DESCRI,;
			(cAlias)->TFP_SALDO ,;
			(cAlias)->TFP_LOTE,;
			"",;						//Origem
			"",;						//Destino
			"",;						//Movimentação
			"" } )						//Retorno
	
		(cAlias)->(DbSkip())
		
	EndDo

	//Verifica se há alguma agendamento para o cofre
	At882AgMun(@aRet)

Else
		BeginSQL alias cAlias
		SELECT 
			TFQ.TFQ_CODIGO,
			TFO.TFO_ITMOV,
			TFO.TFO_PRODUT,
			TFO.TFO_QTDE,
			TFQ.TFQ_ENTORI,
			TFQ.TFQ_ORIMUN,
			TFQ.TFQ_ENTDES,
			TFQ.TFQ_STATUS,
			TFQ.TFQ_DESTIN,
			TFO.TFO_DTRET,
			TFQ.TFQ_DMOVIM,
			ABS.ABS_DESCRI,
			TE2.TE2_LOTE,
			SB1.B1_DESC
		FROM
			%Table:TFQ% TFQ
		INNER JOIN 
			%Table:ABS% ABS  
		ON 
			ABS.ABS_FILIAL = %xfilial:ABS% 
		AND 
			ABS.ABS_LOCAL = TFQ.TFQ_DESTIN
		AND 
			ABS.%NotDel%
		INNER JOIN 
			%Table:TFO% TFO 
			ON
				TFO.TFO_FILIAL = TFQ.TFQ_FILIAL
			AND 
				TFO.TFO_CDMOV = TFQ.TFQ_CODIGO
			AND 
				TFO.%NotDel%
			
		INNER JOIN 
			%Table:TE2% TE2  
		ON 
			TE2.TE2_FILIAL = %xfilial:TE2% 
		AND 
			TE2.TE2_CODPRO = TFO.TFO_PRODUT
		AND 
			TE2.%NotDel%	
			
		INNER JOIN 
			%Table:SB1% SB1 
		ON 
			SB1.B1_FILIAL = %xfilial:SB1% 
		AND 
			SB1.B1_COD = TFO.TFO_PRODUT
		AND 
			SB1.%NotDel%
				
		WHERE
				TFQ.TFQ_FILIAL = %xfilial:TFQ%
			AND
				TFO.TFO_ITMOV = '3'
			AND
				TFQ.TFQ_MOTIVO = '1' 	
			AND
				TFO.TFO_QTDE > 0
			AND
				%Exp:cWhere%
			AND
				TFQ.%NotDel%
	EndSQL	

	While (cAlias)->(!Eof())
		
		If (cAlias)->TFQ_STATUS = '1'
			If (sToD((cAlias)->TFQ_DMOVIM) > MV_PAR01) .OR. Empty(MV_PAR01)
		
				//Verifico a munição que estão implantadas com data de movimentação
				//maior que a informada
				AAdd( aRet, { "BR_LARANJA" ,;
					(cAlias)->TFO_PRODUT,;
					(cAlias)->B1_DESC,;					
					(cAlias)->TFQ_DESTIN ,;
					(cAlias)->ABS_DESCRI,;
					(cAlias)->TFO_QTDE ,;
					(cAlias)->TE2_LOTE,;
					(cAlias)->TFQ_ORIMUN,;						//Origem
					(cAlias)->TFQ_DESTIN,;						//Destino
					sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
					sToD((cAlias)->TFO_DTRET) } )						//Retorno
			
			ElseIf sToD((cAlias)->TFQ_DMOVIM) < dDataBase 
				//Verifico a munição que estão implantadas com data de movimentação
				//maior que a informada
				AAdd( aRet, { "BR_PINK" ,;
					(cAlias)->TFO_PRODUT,;
					(cAlias)->B1_DESC,;		
					(cAlias)->TFQ_DESTIN ,;
					(cAlias)->ABS_DESCRI,;
					(cAlias)->TFO_QTDE ,;
					(cAlias)->TE2_LOTE,;
					(cAlias)->TFQ_ORIMUN,;						//Origem
					(cAlias)->TFQ_DESTIN,;						//Destino
					sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
					sToD((cAlias)->TFO_DTRET) } )						//Retorno
			EndIf	
		
		ElseIf (cAlias)->TFQ_STATUS = '2' 
				
			If !Empty(MV_PAR02) .AND. (sToD((cAlias)->TFO_DTRET) > MV_PAR02)
				
				//Verifico a munição que estão implantadas com data de movimentação
				//maior que a informada
				AAdd( aRet, { "BR_VERMELHO" ,;
					(cAlias)->TFO_PRODUT,;
					(cAlias)->B1_DESC,;		
					(cAlias)->TFQ_DESTIN ,;
					(cAlias)->ABS_DESCRI,;
					(cAlias)->TFO_QTDE ,;
					(cAlias)->TE2_LOTE,;
					(cAlias)->TFQ_ORIMUN,;						//Origem
					(cAlias)->TFQ_DESTIN,;						//Destino
					sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
					sToD((cAlias)->TFO_DTRET) } )						//Retorno
			
			ElseIf Empty((cAlias)->TFO_DTRET)
				
				//Verifico a munição que estão implantadas com data de movimentação
				//maior que a informada
				AAdd( aRet, { "BR_VERMELHO" ,;
					(cAlias)->TFO_PRODUT,;
					(cAlias)->B1_DESC,;		
					(cAlias)->TFQ_DESTIN ,;
					(cAlias)->ABS_DESCRI,;
					(cAlias)->TFO_QTDE ,;
					(cAlias)->TE2_LOTE,;
					(cAlias)->TFQ_ORIMUN,;						//Origem
					(cAlias)->TFQ_DESTIN,;						//Destino
					sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
					sToD((cAlias)->TFO_DTRET) } )						//Retorno
					
			ElseIf sToD((cAlias)->TFO_DTRET) < dDataBase
				//Verifico a munição que estão implantadas com data de movimentação
				//maior que a informada
				AAdd( aRet, { "BR_PRETO" ,;
					(cAlias)->TFO_PRODUT,;
					(cAlias)->B1_DESC,;			
					(cAlias)->TFQ_DESTIN ,;
					(cAlias)->ABS_DESCRI,;
					(cAlias)->TFO_QTDE ,;
					(cAlias)->TE2_LOTE,;
					(cAlias)->TFQ_ORIMUN,;						//Origem
					(cAlias)->TFQ_DESTIN,;						//Destino
					sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
					sToD((cAlias)->TFO_DTRET) } )						//Retorno
			Else
					AAdd( aRet, { "BR_BRANCO" ,;
					(cAlias)->TFO_PRODUT,;
					(cAlias)->B1_DESC,;		
					(cAlias)->TFQ_DESTIN ,;
					(cAlias)->ABS_DESCRI,;
					(cAlias)->TFO_QTDE ,;
					(cAlias)->TE2_LOTE,;
					(cAlias)->TFQ_ORIMUN,;						//Origem
					(cAlias)->TFQ_DESTIN,;						//Destino
					sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
					sToD((cAlias)->TFO_DTRET) } )						//Retorno
			EndIf	
		EndIf
		
		(cAlias)->(DbSkip())
		
	EndDo
	
	At882OutMun(@aRet)
	
EndIf

(cAlias)->(DbCloseArea())


Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882AgMun

Verifica as munições com agendamento
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At882AgMun(aRet)

At882Ag23(@aRet)

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882Ag23, versão 23

Verifica as munições com agendamento
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At882Ag23(aRet)
Local cAlias	:= GetNextAlias()

If Select("cAlias") > 0 
	(cAlias)->(DbCloseArea())
Endif

If MV_PAR03 == 1
	cWhere := "% (TFO.TFO_ITMOV = '3' " 
	cWhere += "AND TFQ.TFQ_ENTDES = '2' "
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
		cWhere += " AND TFQ.TFQ_DESTIN BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' )" 	
	Else
		cWhere += ")"	
	EndIf
	
	If !Empty(MV_PAR02)	
		cWhere += " AND TFQ.TFQ_DMOVIM >= '" + Dtos(MV_PAR02) + "'"
	EndIf
	cWhere += " %"	
Else
	cWhere := "% (TFO.TFO_ITMOV = '3' " 
	cWhere += "AND TFQ.TFQ_ENTORI = '2' "
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
		cWhere += " AND TFQ.TFQ_ORIMUN BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' )" 	
	Else
		cWhere += ")"	
	EndIf
	
	If !Empty(MV_PAR02)	
		cWhere += " AND TFQ.TFQ_DMOVIM >= '" + Dtos(MV_PAR02) + "'"
	EndIf
	cWhere += " %"		
EndIf

If MV_PAR03 == 1
	BeginSQL alias cAlias
		SELECT 
			TFQ.TFQ_CODIGO,
			TFO.TFO_ITMOV,
			TFO.TFO_PRODUT,
			SB1.B1_DESC,
			TE2.TE2_LOTE,
			TFO.TFO_QTDE,
			TFQ.TFQ_ENTORI,
			TFQ.TFQ_ORIMUN,
			TFQ.TFQ_ENTDES,
			TFQ.TFQ_DESTIN,
			TER.TER_DESCRI,
			TFO.TFO_DTRET,
			TFQ.TFQ_DMOVIM
		FROM
			%Table:TFQ% TFQ
		INNER JOIN 
			%Table:TER% TER  
		ON 
			TER.TER_FILIAL = %xfilial:TER% 
		AND 
			TER.TER_CODIGO = TFQ.TFQ_ORIMUN
		AND 
			TER.%NotDel%
		INNER JOIN 
			%Table:TFO% TFO 
			ON
				TFO.TFO_FILIAL = TFQ.TFQ_FILIAL
			AND 
				TFO.TFO_CDMOV = TFQ.TFQ_CODIGO
			AND 
				TFO.%NotDel%
		INNER JOIN 
			%Table:TE2% TE2  
		ON 
			TE2.TE2_FILIAL = %xfilial:TE2% 
		AND 
			TE2.TE2_CODPRO = TFO.TFO_PRODUT
		AND 
			TE2.%NotDel%	
			
			INNER JOIN 
			%Table:SB1% SB1 
		ON 
			SB1.B1_FILIAL = %xfilial:SB1% 
		AND 
			SB1.B1_COD = TFO.TFO_PRODUT
		AND 
			SB1.%NotDel%
				
		WHERE
				TFQ.TFQ_FILIAL = %xfilial:TFQ%
			AND
				TFQ.TFQ_STATUS = '1' 
			AND
				TFQ.TFQ_MOTIVO = '1' 	
			AND
				%Exp:cWhere%
			AND
				TFQ.%NotDel%
	EndSQL	

	While (cAlias)->(!Eof())
		If sToD((cAlias)->TFQ_DMOVIM) > dDataBase
				//Verifico aonde estão as munições que podem entrar
				AAdd( aRet, { "BR_LARANJA" ,;
					(cAlias)->TFO_PRODUT,;
					(cAlias)->B1_DESC,;		
					(cAlias)->TFQ_DESTIN ,;
					(cAlias)->TER_DESCRI,;
					(cAlias)->TFO_QTDE ,;
					(cAlias)->TE2_LOTE,;
					(cAlias)->TFQ_ORIMUN ,;						//Origem
					(cAlias)->TFQ_DESTIN,;						//Destino
					sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
					sToD((cAlias)->TFO_DTRET) } )						//Retorno
			
		Else	
				//Verifico aonde estão as munições que podem entrar
			AAdd( aRet, { "BR_PRETO" ,;
				(cAlias)->TFO_PRODUT,;
				(cAlias)->B1_DESC,;		
				(cAlias)->TFQ_DESTIN ,;
				(cAlias)->TER_DESCRI,;
				(cAlias)->TFO_QTDE ,;
				(cAlias)->TE2_LOTE,;
				(cAlias)->TFQ_ORIMUN ,;						//Origem
				(cAlias)->TFQ_DESTIN,;						//Destino
				sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
				sToD((cAlias)->TFO_DTRET) } )						//Retorno
		
		
		EndIf
		
		(cAlias)->(DbSkip())		
		
	EndDo

(cAlias)->(DbCloseArea())

EndIf

At882OutMun(@aRet)

Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882OutMun

Verifica as munições que estão de saida
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At882OutMun(aRet)

At882Out23(@aRet)

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882Out23

Verifica as munições que estão de saida
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At882Out23(aRet)
Local cAlias	:= GetNextAlias()

If Select("cAlias") > 0 
	(cAlias)->(DbCloseArea())
Endif

If MV_PAR03 == 1
	cWhere := "% (TFO.TFO_ITMOV = '3' " 
	cWhere += "AND TFQ.TFQ_ENTORI = '1' "
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
		cWhere += " AND TFQ.TFQ_ORIMUN BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' )" 	
	Else
		cWhere += ")"	
	EndIf
	
	If !Empty(MV_PAR02)	
		cWhere += " AND TFQ.TFQ_DMOVIM >= '" + Dtos(MV_PAR02) + "'"
	EndIf
	cWhere += " %"	
Else
	cWhere := "% (TFO.TFO_ITMOV = '3' " 
	cWhere += "AND TFQ.TFQ_ENTORI = '2' "
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
		cWhere += " AND TFQ.TFQ_ORIMUN BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' )" 	
	Else
		cWhere += ")"	
	EndIf
	
	If !Empty(MV_PAR02)	
		cWhere += " AND TFQ.TFQ_DMOVIM >= '" + Dtos(MV_PAR02) + "'"
	EndIf
	cWhere += " %"	
EndIf

If MV_PAR03 == 1

	BeginSQL alias cAlias
		SELECT
			TFQ.TFQ_CODIGO,
			TFO.TFO_ITMOV,
			TFO.TFO_PRODUT,
			SB1.B1_DESC,
			TE2.TE2_LOTE,
			TFO.TFO_QTDE,
			TFQ.TFQ_ENTORI,
			TFQ.TFQ_ORIMUN,
			TFQ.TFQ_ENTDES,
			TFQ.TFQ_DESTIN,
			TER.TER_DESCRI,
			TFO.TFO_DTRET,
			TFQ.TFQ_DMOVIM
		FROM
			%Table:TFQ% TFQ
		INNER JOIN
			%Table:TER% TER
		ON
			TER.TER_FILIAL = %xfilial:TER%
			AND
			TER.TER_CODIGO = TFQ.TFQ_ORIMUN
			AND
			TER.%NotDel%
		INNER JOIN
			%Table:TFO% TFO 
			ON
				TFO.TFO_FILIAL = TFQ.TFQ_FILIAL
			AND 
				TFO.TFO_CDMOV = TFQ.TFQ_CODIGO
			AND 
				TFO.%NotDel%

		INNER JOIN
			%Table:TE2% TE2
		ON
			TE2.TE2_FILIAL = %xfilial:TE2%
			AND
			TE2.TE2_CODPRO = TFO.TFO_PRODUT
			AND
			TE2.%NotDel%
			
			INNER JOIN 
			%Table:SB1% SB1 
		ON 
			SB1.B1_FILIAL = %xfilial:SB1% 
		AND 
			SB1.B1_COD = TFO.TFO_PRODUT
		AND 
			SB1.%NotDel%
			
		WHERE
			TFQ.TFQ_FILIAL = %xfilial:TFQ%
			AND
			TFQ.TFQ_STATUS = '1'
			AND
			TFQ.TFQ_MOTIVO = '1'
			AND
			%Exp:cWhere%
			AND
			TFQ.%NotDel%
	EndSQL

		While (cAlias)->(!Eof())
		If sToD((cAlias)->TFQ_DMOVIM) > dDataBase
			//Verifico aonde estão as munições que estão de saida
			AAdd( aRet, { "BR_AMARELO" ,;
				(cAlias)->TFO_PRODUT,;
				(cAlias)->B1_DESC,;		
				(cAlias)->TFQ_ORIMUN ,;
				(cAlias)->TER_DESCRI,;
				(cAlias)->TFO_QTDE ,;
				(cAlias)->TE2_LOTE,;
				(cAlias)->TFQ_ORIMUN ,;						//Origem
				(cAlias)->TFQ_DESTIN,;						//Destino
				sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
				sToD((cAlias)->TFO_DTRET) } )						//Retorno
		Else
			//Verifico aonde estão as munições que estão de saida
			AAdd( aRet, { "BR_PINK" ,;
				(cAlias)->TFO_PRODUT,;
				(cAlias)->B1_DESC,;		
				(cAlias)->TFQ_ORIMUN ,;
				(cAlias)->TER_DESCRI,;
				(cAlias)->TFO_QTDE ,;
				(cAlias)->TE2_LOTE,;
				(cAlias)->TFQ_ORIMUN ,;						//Origem
				(cAlias)->TFQ_DESTIN,;						//Destino
				sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
				sToD((cAlias)->TFO_DTRET) } )						//Retorno	
		EndIf	
		(cAlias)->(DbSkip())
		
	EndDo

Else
	BeginSQL alias cAlias
		SELECT
			TFQ.TFQ_CODIGO,
			TFO.TFO_ITMOV,
			TFO.TFO_PRODUT,
			SB1.B1_DESC,
			TE2.TE2_LOTE,
			TFO.TFO_QTDE,
			TFQ.TFQ_ENTORI,
			TFQ.TFQ_ORIMUN,
			TFQ.TFQ_ENTDES,
			TFQ.TFQ_DESTIN,
			ABS.ABS_DESCRI,
			TFO.TFO_DTRET,
			TFQ.TFQ_DMOVIM
		FROM
			%Table:TFQ% TFQ
			INNER JOIN
			%Table:ABS% ABS
		ON
			ABS.ABS_FILIAL = %xfilial:ABS%
			AND
			ABS.ABS_LOCAL = TFQ.TFQ_ORIMUN
			AND
			ABS.%NotDel%
		INNER JOIN
			%Table:TFO% TFO 
			ON
				TFO.TFO_FILIAL = TFQ.TFQ_FILIAL
			AND 
				TFO.TFO_CDMOV = TFQ.TFQ_CODIGO
			AND 
				TFO.%NotDel%

		INNER JOIN
			%Table:TE2% TE2
		ON
			TE2.TE2_FILIAL = %xfilial:TE2%
			AND
			TE2.TE2_CODPRO = TFO.TFO_PRODUT
			AND
			TE2.%NotDel%
			
			INNER JOIN 
			%Table:SB1% SB1 
		ON 
			SB1.B1_FILIAL = %xfilial:SB1% 
		AND 
			SB1.B1_COD = TFO.TFO_PRODUT
		AND 
			SB1.%NotDel%
			
		WHERE
			TFQ.TFQ_FILIAL = %xfilial:TFQ%
			AND
			TFQ.TFQ_STATUS = '1'
			AND
			TFQ.TFQ_MOTIVO = '1'
			AND
			%Exp:cWhere%
			AND
			TFQ.%NotDel%
	EndSQL
	
		While (cAlias)->(!Eof())
		If sToD((cAlias)->TFQ_DMOVIM) > dDataBase
			//Verifico aonde estão as munições que estão de saida
			AAdd( aRet, { "BR_AMARELO" ,;
				(cAlias)->TFO_PRODUT,;
				(cAlias)->B1_DESC,;					
				(cAlias)->TFQ_ORIMUN ,;
				(cAlias)->ABS_DESCRI,;
				(cAlias)->TFO_QTDE ,;
				(cAlias)->TE2_LOTE,;
				(cAlias)->TFQ_ORIMUN ,;						//Origem
				(cAlias)->TFQ_DESTIN,;						//Destino
				sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
				sToD((cAlias)->TFO_DTRET) } )						//Retorno
		Else
			//Verifico aonde estão as munições que estão de saida
			AAdd( aRet, { "BR_PINK" ,;
				(cAlias)->TFO_PRODUT,;
				(cAlias)->B1_DESC,;		
				(cAlias)->TFQ_ORIMUN ,;
				(cAlias)->ABS_DESCRI,;
				(cAlias)->TFO_QTDE ,;
				(cAlias)->TE2_LOTE,;
				(cAlias)->TFQ_ORIMUN ,;						//Origem
				(cAlias)->TFQ_DESTIN,;						//Destino
				sToD((cAlias)->TFQ_DMOVIM),;						//Movimentação
				sToD((cAlias)->TFO_DTRET) } )						//Retorno	
		EndIf	
		(cAlias)->(DbSkip())
		
	EndDo
	
EndIf

(cAlias)->(DbCloseArea())


Return(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882LegMun

Legenda da Lista de disponibilidade de munições
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At882LegMun()
Local oLegenda  :=  FWLegend():New() 		// Objeto FwLegend.
                                                  	
oLegenda:Add("","BR_VERDE",STR0011)     	// "Munição Disponivel"				
oLegenda:Add("","BR_AMARELO",STR0012)  	// "Munição com Agendamento de Saida"
oLegenda:Add("","BR_LARANJA",STR0013)  	// "Munição com Agendamento de Entrada"
oLegenda:Add("","BR_VERMELHO",STR0014)  	// "Munição Implantada/ Sem Retorno"
oLegenda:Add("","BR_PRETO",STR0015)  		// "Munição não retornada"
oLegenda:Add("","BR_PINK",STR0016)  		// "Munição não movimentada"
oLegenda:Add("","BR_BRANCO",STR0017)  		// "Munição Implantada/ Com Previsão de Retorno"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil   

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At882Refresh

Atuualiza os parametros e o Browse da lista de munições
@since		29/11/2013 
@version P11 R9
     
@return lRet, Retorna .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At882Refresh(aList,oBrw)
Local lPerg	:= .F.

//Ativa o Pergunte
lPerg := Pergunte("TECA882",.T.)

If lPerg
	//Cria o Array para exibição dos dados
	MsgRun(STR0005,STR0004,{ || aList := At882QryMun() })	
		
	//Atualiza o Array em Ordem Numerica
	asort(aList,,, {|x,y| x[2] < y[2] }) 
	
	oBrw:SetArray(aList)
	
	oBrw:Refresh(.T.)
EndIf
	
Return Nil
