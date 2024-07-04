#Include 'TMSAF68A.ch'
#Include 'Protheus.ch'

/*{Protheus.doc} TF68LegCTE
Exibe Legendas de Autenticação do CTe na SEFAZ
@type Function
@author Valdemar Roberto Mognon
@since 27/04/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TF68LegCTE() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_AMARELO" ,STR0001})	//-- Não Transmitido
Aadd(aLegenda,{"BR_VERDE"   ,STR0002})	//-- Documento Aguardando
Aadd(aLegenda,{"BR_AZUL"    ,STR0003})	//-- Doc. Autorizado
Aadd(aLegenda,{"BR_VERMELHO",STR0004})	//-- Doc. Não Autorizado
Aadd(aLegenda,{"BR_PRETO"   ,STR0005})	//-- Doc. com Falha na Comunicação

BrwLegenda(STR0006,STR0006,aLegenda)	//-- Autenticação SEFAZ

Return Aclone(aLegenda)

/*{Protheus.doc} TF68StaCTE
Exibe Status de Autenticação do CTe na SEFAZ
@type Function
@author Valdemar Roberto Mognon
@since 27/04/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TF68StaCTE(cFilDoc,cDoc,cSerie) 
Local cRet    := ""
Local aAreaDT6:= DT6->(GetArea())

DT6->(DbSetOrder(1))
If DT6->(DbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie)) 

	If DT6->DT6_SITCTE == StrZero(1,Len(DT6->DT6_SITCTE))		//-- Doc Aguardando
		cRet := "BR_VERDE"
	ElseIf DT6->DT6_SITCTE == StrZero(0,Len(DT6->DT6_SITCTE))	//-- Não Transmitido
		cRet := "BR_AMARELO"
	ElseIf DT6->DT6_SITCTE == StrZero(3,Len(DT6->DT6_SITCTE))	//-- Doc. Não Autorizado
		cRet := "BR_VERMELHO"
	ElseIf DT6->DT6_SITCTE == StrZero(2,Len(DT6->DT6_SITCTE))	//-- Doc. Autorizado
		cRet := "BR_AZUL"
	ElseIf DT6->DT6_SITCTE == StrZero(5,Len(DT6->DT6_SITCTE))	//-- Doc. com Falha na Comunicação
		cRet := "BR_PRETO"
	Else
		cRet := "BR_AMARELO"
	EndIf
EndIf

RestArea(aAreaDT6)
FwFreeArray(aAreaDT6)
Return cRet

/*{Protheus.doc} TF68LegFat
Exibe Legendas de Faturamento Doctos
@type Function
@author Vanessa
@since 05/07/2021
@version P12 R12.1.33
@param nFolder
@return logico
*/
Function TF68LegFat() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE"   ,STR0048})	//-- Aguardando Faturamento
Aadd(aLegenda,{"BR_AZUL"    ,STR0049})	//-- Doc. Faturado

BrwLegenda(STR0050,STR0050,aLegenda)

Return Aclone(aLegenda)

/*{Protheus.doc} TF68StaFat
Exibe Status de Faturamento Documento
@type Function
@author Vanessa
@since 05/07/2021
@version P12 R12.1.33
@param nFolder
@return logico
*/
Function TF68StaFat(cFilDoc,cDoc,cSerie) 
Local cRet    := ""
Local aAreaDT6:= DT6->(GetArea())

DT6->(DbSetOrder(1))
If DT6->(DbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie)) 

	If Empty(DT6->DT6_NUM)		//-- Doc Aguardando Faturamento
		cRet := "BR_VERDE"
	Else						//-- Doc Faturado
		cRet := "BR_AZUL"
	EndIf
EndIf

RestArea(aAreaDT6)
FwFreeArray(aAreaDT6)
Return cRet

/*{Protheus.doc} TF68LegAVB
Exibe Legenda de Averbação do CTe
@type Function
@author Valdemar Roberto Mognon
@since 27/04/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TF68LegAVB() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE"       ,STR0007})	//-- Aguardando Averbação
Aadd(aLegenda,{"BR_LARANJA"     ,STR0008})	//-- Falha de Comunicação
Aadd(aLegenda,{"BR_AZUL"        ,STR0009})	//-- Averbado
Aadd(aLegenda,{"BR_VERMELHO"    ,STR0011})	//-- Recusado
Aadd(aLegenda,{"BR_VERDE_ESCURO",STR0012})	//-- Aguardando Cancelamento
Aadd(aLegenda,{"BR_AMARELO"     ,STR0013})	//-- Falha de Comunicação para Cancelamento
Aadd(aLegenda,{"BR_CANCEL"      ,STR0014})	//-- Averbação Cancelada
Aadd(aLegenda,{"BR_VIOLETA"     ,STR0015})	//-- Cancelamento Recusado
Aadd(aLegenda,{"BR_CANCEL"      ,STR0016})	//-- Documento Cancelado Antes da Averbação

BrwLegenda(STR0010,STR0010,aLegenda)	//-- Averbação CTe

Return Aclone(aLegenda)

/*{Protheus.doc} TF68AvbCTE
Exibe Status de Averbação do CTe
@type Function
@author Valdemar Roberto Mognon
@since 27/04/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TF68AvbCTE(cFilDoc,cDoc,cSerie) 
Local cRet    := ""
Local aAreas  := {DL5->(GetArea()),GetArea()}
Local cDL5Qry := GetNextAlias()

BeginSql alias cDL5Qry
    SELECT
        DL5.R_E_C_N_O_ RECDL5
    FROM
        %table:DL5% DL5
    WHERE
        DL5.DL5_FILIAL= %xfilial:DL5% AND
		DL5.DL5_FILDOC = %exp:cFilDoc% AND
		DL5.DL5_DOC = %exp:cDoc% AND
		DL5.DL5_SERIE = %exp:cSerie% AND
        DL5.%notDel%
EndSql

If !(cDL5Qry)->(Eof())
	DL5->( DbGoTo( (cDL5Qry)->RECDL5 ) )
	If DL5->DL5_STATUS == StrZero(0,Len(DL5->DL5_STATUS))		//-- Aguardando Averbação
		cRet := "BR_VERDE"
	ElseIf DL5->DL5_STATUS == StrZero(1,Len(DL5->DL5_STATUS))	//-- Falha de Comunicação
		cRet := "BR_LARANJA"
	ElseIf DL5->DL5_STATUS == StrZero(2,Len(DL5->DL5_STATUS))	//-- Averbado
		cRet := "BR_AZUL"
	ElseIf DL5->DL5_STATUS == StrZero(3,Len(DL5->DL5_STATUS))	//-- Recusado
		cRet := "BR_VERMELHO"
	ElseIf DL5->DL5_STATUS == StrZero(4,Len(DL5->DL5_STATUS))	//-- Aguardando Cancelamento
		cRet := "BR_VERDE_ESCURO"
	ElseIf DL5->DL5_STATUS == StrZero(5,Len(DL5->DL5_STATUS))	//-- Falha de Comunicação para Cancelamento
		cRet := "BR_AMARELO"
	ElseIf DL5->DL5_STATUS == StrZero(6,Len(DL5->DL5_STATUS))	//-- Averbação Cancelada
		cRet := "BR_CANCEL"
	ElseIf DL5->DL5_STATUS == StrZero(7,Len(DL5->DL5_STATUS))	//-- Cancelamento Recusado
		cRet := "BR_VIOLETA"
	ElseIf DL5->DL5_STATUS == StrZero(8,Len(DL5->DL5_STATUS))	//-- Documento Cancelado Antes da Averbação
		cRet := "BR_CANCEL"
	EndIf
Else
	cRet := "BR_VERDE"
EndIf

(cDL5Qry)->(DbCloseArea())
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet

//-----------------------------------------------------------
/*/{Protheus.doc} TF68LegBrw
//Monta Legendas do Browse das Rotinas
@author Katia
@since 22/04/2021
@version 12.1.33
/*/
//-----------------------------------------------------------
Function TF68LegBrw(oBrowse,cAlias)

If cAlias == 'DTX' 
	oBrowse:AddLegend( "Empty(DTX->DTX_NUMCTC)" , "BR_VERDE"    , STR0017 ) //Em Aberto
	oBrowse:AddLegend( "!Empty(DTX->DTX_NUMCTC)", "BR_VERMELHO" , STR0018 ) //Com Contrato Gerado

ElseIf cAlias == 'DTW' 
	oBrowse:AddLegend( "DTW->DTW_STATUS == '1'" , 'BR_VERDE'   , STR0017 )   //Em Aberto
	oBrowse:AddLegend( "DTW->DTW_STATUS == '2'" , 'BR_VERMELHO', STR0019 )   //Encerrado
	oBrowse:AddLegend( "DTW->DTW_STATUS == '9'" , 'BR_PRETO'   , STR0020 )   //Cancelado
EndIf

Return 

/*{Protheus.doc} TF68StaMDFE
Exibe Status de Autenticação do Manifesto na SEFAZ
@type Function
@author Fabio Marchiori Sampaio
@since 17/05/2021
@version P12 R12.1.29
@param nFolder
@return 
*/
Function TF68StaMDFE(cFilMan,cManife,cSerie) 
Local cRet    := ""
Local aAreaDTX:= DTX->(GetArea())

DTX->(DbSetOrder(2))
If DTX->(DbSeek(xFilial('DTX')+cFilMan+cManife+cSerie)) 

	If Empty(DTX->DTX_STFMDF)
		Do Case
		Case DTX->DTX_STIMDF == StrZero(1,Len(DTX->DTX_STIMDF))	//-- 1 Mdf-e Aguardando  
			cRet := "BR_VERDE"
		Case DTX->DTX_STIMDF == StrZero(0,Len(DTX->DTX_STIMDF))	//-- 0 Nao Transmitido
			cRet := "BR_AMARELO"
		Case DTX->DTX_STIMDF == StrZero(3,Len(DTX->DTX_STIMDF))	//-- 3 Mdf-e Nao Autorizado
			cRet := "BR_VERMELHO"
		Case DTX->DTX_STIMDF == StrZero(2,Len(DTX->DTX_STIMDF))	//-- 2 Mdf-e Autorizado
			cRet := "BR_AZUL"
		Case DTX->DTX_STIMDF == StrZero(5,Len(DTX->DTX_STIMDF))	//-- 5 Mdf-e com Falha na Comunicacao
			cRet := "BR_PRETO"
		OtherWise
			cRet := "BR_AMARELO"
		EndCase
	Else
		Do Case
		Case DTX->DTX_STFMDF == StrZero(1,Len(DTX->DTX_STFMDF))	//-- 1 Mdf-e Aguardando  
			cRet := "BR_VERDE"
		Case DTX->DTX_STFMDF == StrZero(0,Len(DTX->DTX_STFMDF))	//-- 0 Nao Transmitido
			cRet := "BR_AMARELO"
		Case DTX->DTX_STFMDF == StrZero(3,Len(DTX->DTX_STFMDF))	//-- 3 Mdf-e Nao Autorizado
			cRet := "BR_VERMELHO"
		Case DTX->DTX_STFMDF == StrZero(2,Len(DTX->DTX_STFMDF))	//-- 2 Mdf-e Autorizado
			cRet := "BR_MARRON"
		Case DTX->DTX_STFMDF == StrZero(5,Len(DTX->DTX_STFMDF))	//-- 5 Mdf-e com Falha na Comunicacao
			cRet := "BR_PRETO"
		Case DTX->DTX_STATUS == StrZero(3,Len(DTX->DTX_STATUS))	//-- Encerrado
			cRet := "BR_MARRON"
		OtherWise
			cRet := "BR_AMARELO"
		EndCase
	EndIf

EndIf

RestArea(aAreaDTX)
FwFreeArray(aAreaDTX)
Return cRet

/*{Protheus.doc} TF68LegManif
Exibe Legenda de Manifesto
@type Function
@author Fabio Marchiori Sampaio
@since 17/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TF68LegManif() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE"       ,STR0021})	//-- "1 Mdf-e Aguardando"
Aadd(aLegenda,{"BR_AMARELO"     ,STR0022})	//-- "0 Não Transmitido"
Aadd(aLegenda,{"BR_VERMELHO"    ,STR0023})	//-- "3 Mdf-e Não Autorizado"
Aadd(aLegenda,{"BR_AZUL"    	,STR0024})	//-- "2 Mdf-e Autorizado"
Aadd(aLegenda,{"BR_PRETO"    	,STR0025})	//-- "5 Mdf-e com Falha na Comunicação"
Aadd(aLegenda,{"BR_MARRON"    	,STR0019})	//-- "Encerrado"

BrwLegenda(STR0006,STR0006,aLegenda)	//-- Autenticação SEFAZ

Return Aclone(aLegenda)

//-----------------------------------------------------------
/*/{Protheus.doc} TF68LegDT6
//Status dos Documentos de Transporte - DT6
@author Katia
@since 17/05/2021
@version 12.1.33
/*/
//-----------------------------------------------------------
Function TF68LegDT6()
Local aLegenda:= {}

	aAdd(aLegenda, {"DT6_STATUS == '1' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'1')","BR_VERDE",STR0017})		//-- Em aberto
	aAdd(aLegenda, {"DT6_STATUS == '2' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'2')","BR_VERMELHO",STR0035})	//-- Carregado / Indicado para Coleta
	aAdd(aLegenda, {"DT6_STATUS == '3' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'3')","BR_AMARELO",STR0036})	//-- Em Trânsito / Coleta em Processo
	aAdd(aLegenda, {"(DT6_STATUS == '4' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'5')","BR_LARANJA",STR0037})	//-- Chegada Parcial / Documento Informado
	aAdd(aLegenda, {"(DT6_STATUS == '5' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'4')","BR_AZUL",STR0038})		//-- Chegada Final / Coleta Encerrada
	aAdd(aLegenda, {"DT6_STATUS == '6'","BR_CINZA",STR0039})	//-- Indicado para Entrega
	aAdd(aLegenda, {"DT6_STATUS == '7'","BR_MARROM",STR0040})	//-- Entregue
	aAdd(aLegenda, {"DT6_STATUS == '8'","BR_PINK",STR0047})	//-- Entrega Parcial
	aAdd(aLegenda, {"TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'9')","BR_PRETO",STR0041})	//-- Ordem de Coleta Cancelada
	aAdd(aLegenda, {"DT6_STATUS == '9'","BR_CANCEL",STR0042})	//-- Anulado
	aAdd(aLegenda, {"DT6_STATUS == 'A'","BR_BRANCO",STR0043})	//-- Retorno Total
	aAdd(aLegenda, {"DT6_STATUS == 'B'","PMSEDT4",STR0044})		//-- Cancelamento SEFAZ Aguardando
	aAdd(aLegenda, {"DT6_STATUS == 'C'","PMSEDT3",STR0045})		//-- Cancelamento SEFAZ Autorizado
	aAdd(aLegenda, {"DT6_STATUS == 'D'","PMSEDT1",STR0046})		//-- Cancelamento SEFAZ Não Autorizado

Return aLegenda

//-----------------------------------------------------------
/*/{Protheus.doc} TF68StaDTQ
//Status da Viagem - DTQ
@author Katia
@since 17/05/2021
@version 12.1.33
/*/
//-----------------------------------------------------------
Function TF68LegDTQ()
Local aLegenda := {}

	aAdd(aLegenda, {"Posicione('DTQ',2,xFilial('DTQ')+DUD->DUD_FILORI+DUD->DUD_VIAGEM,'DTQ_STATUS')=='1'", "GREEN"	, STR0017} 	) //-- Em Aberto   
	aAdd(aLegenda, {"Posicione('DTQ',2,xFilial('DTQ')+DUD->DUD_FILORI+DUD->DUD_VIAGEM,'DTQ_STATUS')=='5'", "RED"	, STR0026}  ) //-- Fechada
	aAdd(aLegenda, {"Posicione('DTQ',2,xFilial('DTQ')+DUD->DUD_FILORI+DUD->DUD_VIAGEM,'DTQ_STATUS')=='2'", "YELLOW", STR0029}  ) //-- Em Transito 
	aAdd(aLegenda, {"Posicione('DTQ',2,xFilial('DTQ')+DUD->DUD_FILORI+DUD->DUD_VIAGEM,'DTQ_STATUS')=='4'", "ORANGE", STR0027}  ) //-- Chegada em Filial.
	aAdd(aLegenda, {"Posicione('DTQ',2,xFilial('DTQ')+DUD->DUD_FILORI+DUD->DUD_VIAGEM,'DTQ_STATUS')=='3'", "BLUE"	, STR0019} 	) //-- Encerrada
	aAdd(aLegenda, {"Posicione('DTQ',2,xFilial('DTQ')+DUD->DUD_FILORI+DUD->DUD_VIAGEM,'DTQ_STATUS')=='9'", "BLACK"	, STR0020} 	) //-- Cancelada

Return aLegenda


//-----------------------------------------------------------
/*/{Protheus.doc} TF68LegSE1
//Status da Fatura - SE1
@author Katia
@since 17/05/2021
@version 12.1.33
/*/
//-----------------------------------------------------------
Function TF68LegSE1()
Local aLegenda:= {}

	aAdd(aLegenda, {"E1_SITFAT == '3'","BLACK",STR0030})			//-- Fatura Cancelada
	aAdd(aLegenda, {"ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .And. E1_SITUACA $ 'F6'","YELLOW",STR0031})	//-- Fatura Protestada
	aAdd(aLegenda, {"ROUND(E1_SALDO,2) == 0","RED",STR0032})	    //-- Fatura Baixada
	aAdd(aLegenda, {"E1_SITFAT == '2'","BLUE",STR0033})				//-- Fatura Impressa
	aAdd(aLegenda, {".T.","GREEN",STR0034})							//-- Fatura em Aberto
 
Return aLegenda


//-----------------------------------------------------------
/*/{Protheus.doc} TF68LegDTW
//Status das Operações - DTW
@author Katia
@since 17/05/2021
@version 12.1.33
/*/
//-----------------------------------------------------------
Function TF68LegDTW()
Local aLegenda:= {}

	aAdd(aLegenda, { "DTW->DTW_STATUS == '1'" , 'BR_VERDE'    , STR0017} )  //Em Aberto
	aAdd(aLegenda, { "DTW->DTW_STATUS == '2'" , 'BR_VERMELHO', STR0019} )   //Encerrado
	aAdd(aLegenda, { "DTW->DTW_STATUS == '9'" , 'BR_PRETO'   , STR0020} )   //Cancelado

Return aLegenda
