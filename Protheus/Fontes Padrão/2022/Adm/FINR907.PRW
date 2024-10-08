#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FINR907.CH"

//旼컴컴컴컴컴컴컴컴��
//쿟ipo de Relatorio �
//읕컴컴컴컴컴컴컴컴��
#DEFINE ANALITICO	       		1
#DEFINE SINTETICO	          	2


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑INR907   튍utor  쿌lvaro Camillo Neto � Data �  04/01/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝elatorio de conferencia de Processo de Ajuste  Contas a     볍�
굇�          � Pagar                                                      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGAFIN                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function FINR907()
Local oReport	:= nil

Private cTitulo	:= STR0001//"T�tulos em processo de AVP"
Private cPerg	:= "FIN907"

#IFNDEF TOP
	Help(" ",1,"FINNAOTOP",,STR0002,1,0)//"Processo dispon�vel apenas para ambiente TOPCONNECT / TOTVSDBACCESS"
	Return( .F. )
#ENDIF

If Pergunte(cPerg,.T.)
	oReport := ReportDef()
	oReport:PrintDialog()
Endif
Return


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝eportDef 튍utor  쿌lvaro Camillo Neto � Data �  04/01/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿏efini豫o do Relatorio                                      볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � FINR907                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function ReportDef()

Local oReport	:= nil
Local oFIQ   	:= nil
Local oFIS		:= nil
Local cDesc		:= STR0003 //"Esse relat�rio tem o objetivo de listar os t�tulos a pagar em processo de ajuste de valor presente, demonstrando o valor presente do titulo e suas movimenta寤es"
Local nX		:= 0


DEFINE REPORT oReport NAME "FINR907" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| RepFR907(oReport,cPerg)} DESCRIPTION cDesc
	oReport:DisableOrientation()
	oReport:SetLandScape()
	oReport:ParamReadOnly()
	Pergunte(cPerg,.F.)
	DEFINE SECTION oFIQ OF oReport TITLE STR0004 TABLES "FIQ","SE2","SA2" //"T�tulo em AVP"
		DEFINE CELL NAME "E2_PREFIXO" 	  	OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME "E2_NUM" 	  	  	OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME "E2_PARCELA" 		OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME "E2_TIPO" 			OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME "E2_FORNECE" 		OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME "E2_LOJA" 			OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME "A2_NOME" 			OF oFIQ ALIAS "SA2"
		DEFINE CELL NAME "E2_EMISSAO" 		OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME "E2_VALOR" 		OF oFIQ ALIAS "SE2"
		DEFINE CELL NAME 'FIQ_DTAVP'	 	OF oFIQ ALIAS "FIQ"
		DEFINE CELL NAME 'FIQ_SEQ'			OF oFIQ ALIAS "FIQ"
		DEFINE CELL NAME 'FIQ_VLRAVP' 		OF oFIQ ALIAS "FIQ"
		DEFINE CELL NAME 'FIQ_TAXAVP'		OF oFIQ ALIAS "FIQ"
		DEFINE CELL NAME 'FIQ_PERIOD' 		OF oFIQ ALIAS "FIQ" SIZE 15
		DEFINE CELL NAME 'FIQ_STATUS' 		OF oFIQ ALIAS "FIQ" SIZE 15

		oFIQ:SetAutoSize()
		oFIQ:SetHeaderPage(.T.)
		oFIQ:SetLinesBefore(1)

		If MV_PAR01 == ANALITICO
			For nX := 1 To Len(oFIQ:aCell)
				oFIQ:Cell(nX):SetBorder("BOTTOM")
			Next
			DEFINE SECTION oFIS OF oFIQ TITLE STR0005 TABLES "FIS" //"Movimentos de AVP"
				DEFINE CELL NAME "FIS_DTAVP"	OF oFIS ALIAS "FIS"
				DEFINE CELL NAME "FIS_PROC"		OF oFIS ALIAS "FIS"
				DEFINE CELL NAME "FIS_TIPAVP"	OF oFIS ALIAS "FIS" SIZE 15
				DEFINE CELL NAME "FIS_VLRAVP"	OF oFIS ALIAS "FIS"
				oFIS:SetAutoSize()
				oFIS:SetHeaderPage(.T.)
				oFIS:SetLinesBefore(0)
		EndIf
Return oReport


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝epFR907  튍utor  � Alvaro Camillo Neto� Data �  13/02/09   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Realiza a query dos dados                                  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � FINR904                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function RepFR907(oReport,cPerg)

Local oFIQ		:= oReport:Section(1)
Local oFIS		:= Nil
Local cStatus	:= "E"
Local cAliasQry	:= ""

Pergunte(cPerg,.F.)

cAliasQry := GetNextAlias()

If MV_PAR01 == ANALITICO
	BEGIN REPORT QUERY oFIQ
		BeginSql Alias cAliasQry
			SELECT
				FIQ_FILIAL ,
				FIQ_PREFIX ,
				FIQ_NUM	  ,
				FIQ_PARCEL ,
				FIQ_TIPO   ,
				FIQ_FORNEC ,
				FIQ_LOJA	  ,
				FIQ_SEQ	  ,
				FIQ_STATUS ,
				FIS_FILIAL ,
				FIS_PREFIX ,
				FIS_NUM	  ,
				FIS_PARCEL ,
				FIS_TIPO   ,
				FIS_FORNEC ,
				FIS_LOJA	  ,
				FIS_SEQ	  ,
				FIQ_DTAVP  ,
				FIQ_VLRAVP ,
				FIQ_TAXAVP ,
				FIQ_PERIOD ,
				FIS_DTAVP  ,
				FIS_PROC   ,
				FIS_VLRAVP ,
				FIS_TIPAVP

			FROM  %table:FIQ% FIQ
			INNER JOIN %table:FIS% FIS  ON
				FIQ_FILIAL 		= FIS_FILIAL	AND
				FIQ_PREFIX 		= FIS_PREFIX	AND
				FIQ_NUM	 		= FIS_NUM 		AND
				FIQ_PARCEL 		= FIS_PARCEL 	AND
				FIQ_TIPO 	 	= FIS_TIPO 		AND
				FIQ_FORNEC 		= FIS_FORNEC 	AND
				FIQ_LOJA	 	= FIS_LOJA 		AND
				FIQ_SEQ	 		= FIS_SEQ		AND
				FIS_FILIAL   	= %xfilial:FIS%	AND
				FIS_STATUS		= 'E'			AND
				FIS.%NotDel%
			WHERE
				FIQ_DTAVP 	>= %exp:MV_PAR02%	AND
				FIQ_DTAVP 	<= %exp:MV_PAR03%	AND
				FIQ_PREFIX 	>= %exp:MV_PAR04%	AND
				FIQ_PREFIX 	<= %exp:MV_PAR05%	AND
				FIQ_NUM 	>= %exp:MV_PAR06%	AND
				FIQ_NUM 	<= %exp:MV_PAR07%	AND
				FIQ_PARCEL 	>= %exp:MV_PAR08%	AND
				FIQ_PARCEL 	<= %exp:MV_PAR09%	AND
				FIQ_TIPO 	>= %exp:MV_PAR10%	AND
				FIQ_TIPO 	<= %exp:MV_PAR11%	AND
				FIQ_FORNEC 	>= %exp:MV_PAR12%	AND
				FIQ_LOJA 	>= %exp:MV_PAR13%	AND
				FIQ_FORNEC 	<= %exp:MV_PAR14%	AND
				FIQ_LOJA 	<= %exp:MV_PAR15%	AND
				FIQ_FILIAL   = %xfilial:FIQ% 	AND
				FIQ.%NotDel%
			ORDER BY  FIS_FILIAL,FIS_PREFIX,FIS_NUM,FIS_PARCEL,FIS_TIPO,FIS_FORNEC,FIS_LOJA,FIQ_DTAVP
		EndSql
	END REPORT QUERY oFIQ
Else
	BEGIN REPORT QUERY oFIQ
		BeginSql Alias cAliasQry
			SELECT
				FIQ_FILIAL ,
				FIQ_PREFIX ,
				FIQ_NUM	  ,
				FIQ_PARCEL ,
				FIQ_TIPO   ,
				FIQ_FORNEC ,
				FIQ_LOJA	  ,
				FIQ_SEQ	  ,
				FIQ_DTAVP  ,
				FIQ_VLRAVP ,
				FIQ_STATUS ,
				FIQ_TAXAVP ,
				FIQ_PERIOD
			FROM  %table:FIQ% FIQ
			WHERE
				FIQ_DTAVP 	>= %exp:MV_PAR02%	AND
				FIQ_DTAVP 	<= %exp:MV_PAR03%	AND
				FIQ_PREFIX 	>= %exp:MV_PAR04%	AND
				FIQ_PREFIX 	<= %exp:MV_PAR05%	AND
				FIQ_NUM 	>= %exp:MV_PAR06%	AND
				FIQ_NUM 	<= %exp:MV_PAR07%	AND
				FIQ_PARCEL 	>= %exp:MV_PAR08%	AND
				FIQ_PARCEL 	<= %exp:MV_PAR09%	AND
				FIQ_TIPO 	>= %exp:MV_PAR10%	AND
				FIQ_TIPO 	<= %exp:MV_PAR11%	AND
				FIQ_FORNEC 	>= %exp:MV_PAR12%	AND
				FIQ_LOJA 	>= %exp:MV_PAR13%	AND
				FIQ_FORNEC 	<= %exp:MV_PAR14%	AND
				FIQ_LOJA 	<= %exp:MV_PAR15%	AND
				FIQ_FILIAL  = %xfilial:FIQ% 	AND
				FIQ.%NotDel%
			ORDER BY  FIQ_FILIAL,FIQ_PREFIX,FIQ_NUM,FIQ_PARCEL,FIQ_TIPO,FIQ_FORNEC,FIQ_LOJA,FIQ_DTAVP
		EndSql
	END REPORT QUERY oFIQ
EndIf

If MV_PAR01 == ANALITICO
	oFIS := oReport:Section(1):Section(1)
	oFIS:SetParentQuery()
	oFIS:SetParentFilter({|cParam| (cAliasQry)->(FIQ_FILIAL+FIQ_PREFIX+FIQ_NUM+FIQ_PARCEL+FIQ_TIPO+FIQ_FORNEC+FIQ_LOJA+FIQ_SEQ) == cParam},{|| (cAliasQry)->(FIS_FILIAL+FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+FIS_SEQ)})
EndIf
TRPosition():New(oFIQ, "SE2", 6, {|| xFilial("SE2") + (cAliasQry)->(FIQ_FORNEC+FIQ_LOJA+FIQ_PREFIX+FIQ_NUM+FIQ_PARCEL+FIQ_TIPO) }) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
TRPosition():New(oFIQ, "SA2", 1, {|| xFilial("SA2") + (cAliasQry)->(FIQ_FORNEC+FIQ_LOJA) }) //A2_FILIAL+A2_COD+A2_LOJA

oFIQ:Print()

Return
