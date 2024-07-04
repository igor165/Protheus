#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TECR960.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR960()
Relatório de Ficha de Localização

@sample 	TECR960()
@return		oReport, 	Object,	Objeto do relatório de Ficha de Localização

@author 	Kaique Schiller
@since		27/05/2019
/*/

//--------------------------------------------------------------------------------------------------------------------
Function TECR960()
Local cPerg		:= "TECR960"
Local oReport	:= Nil

If TRepInUse() 
	Pergunte(cPerg,.F.)	
	oReport := Rt960RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()	
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt960RDef()
Ficha de Localização - monta as Sections para impressão do relatório

@sample Rt960RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		29/05/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt960RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2 	:= Nil				
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR960",STR0001,cPerg,{|oReport| Rt960Print(oReport, cPerg, cAlias1)},STR0001) //"Ficha de Localização"

oSection1 := TRSection():New(oReport	,FwX2Nome("TGY") ,{"AA1"},,,,,,,,,,,,,.T.)
DEFINE CELL NAME "TGY_ATEND" OF oSection1 ALIAS "AA1"
DEFINE CELL NAME "TGY_NOMTEC" OF oSection1 TITLE STR0005 SIZE (TamSX3("AA1_NOMTEC")[1]) BLOCK {|| Posicione("AA1",1, xFilial("AA1")+PadR(Trim((cAlias1)->TGY_ATEND), TamSx3("AA1_NOMTEC")[1]),"AA1->AA1_NOMTEC") } 	//"Nome Atend."

oSection2 := TRSection():New(oSection1	,FwX2Nome("TGY") ,{"TGY","ABS","SRJ"},,,,,,,,,,3,,,.T.)
DEFINE CELL NAME "ABS_LOCAL"		OF oSection2 ALIAS "ABS" TITLE STR0006 //"Código Local"
DEFINE CELL NAME "ABS_DESCRI"		OF oSection2 ALIAS "ABS"
DEFINE CELL NAME "ABS_CODIGO"		OF oSection2 ALIAS "ABS" TITLE STR0007 //"Código Cliente" 
DEFINE CELL NAME "ABS_LOJA"			OF oSection2 ALIAS "ABS"
DEFINE CELL NAME "ABS_NOMECLI"  	OF oSection2 TITLE STR0008 SIZE (TamSX3("A1_NOME")[1]) BLOCK {|| Posicione("SA1",1, xFilial("SA1")+PadR(Trim((cAlias1)->(ABS_CODIGO+ABS_LOJA)), TamSx3("A1_NOME")[1]),"SA1->A1_NOME") } //"Nome Cliente"      																	
DEFINE CELL NAME "TGY_ESCALA"		OF oSection2 ALIAS "TGY"  				 
DEFINE CELL NAME "TGY_TURNO"		OF oSection2 ALIAS "TGY"
DEFINE CELL NAME "TGY_CODTFF"		OF oSection2 ALIAS "TGY" TITLE STR0004
DEFINE CELL NAME "RJ_DESC"  		OF oSection2 TITLE STR0009 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Func."
DEFINE CELL NAME "TGY_DTINI"		OF oSection2 ALIAS "TGY"
DEFINE CELL NAME "TGY_ULTALO"		OF oSection2 ALIAS "TGY"
DEFINE CELL NAME "TGY_ENTRA1"		OF oSection2 ALIAS "TGY" TITLE STR0002 BLOCK {|| At960HrAlc("E",cAlias1) } //"Hr. Entrada"
DEFINE CELL NAME "TGY_SAIDA1"		OF oSection2 ALIAS "TGY" TITLE STR0003 BLOCK {|| At960HrAlc("S",cAlias1) } //"Hr. Saída"   
DEFINE CELL NAME "COBERTURA"		OF oSection2 ALIAS "TGY" TITLE STR0010 //"Cobertura" 

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt960Print()
Endereço de Cliente - monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt960Print(oReport, cPerg, cAlias1)

@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum

@author 	Kaique Schiller
@since		29/05/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt960Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1) 	
Local cSim		:= STR0011
Local cNao      := STR0012

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT TGY.TGY_ATEND,
		   TGY.TGY_ESCALA,
		   TGY.TGY_TURNO,
		   TGY.TGY_SEQ,
		   ABS.ABS_CODIGO,
		   ABS.ABS_LOJA,
		   ABS.ABS_LOCAL,
		   ABS.ABS_DESCRI,
		   TGY.TGY_DTINI,
		   TGY.TGY_ULTALO,
		   TGY.TGY_DTFIM,
		   TGY.TGY_ENTRA1,
		   TGY.TGY_SAIDA1,
		   TGY.TGY_ENTRA2,
		   TGY.TGY_SAIDA2,
		   TGY.TGY_ENTRA3,
		   TGY.TGY_SAIDA3,
		   TGY.TGY_ENTRA4,
		   TGY.TGY_SAIDA4,
		   TGY.TGY_CODTFF,
		   TFF.TFF_FUNCAO,
		   %Exp:cNao% COBERTURA //Não
	FROM %table:TGY% TGY
	INNER JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF% AND
								  TFF.TFF_COD 	 = TGY_CODTFF    AND
								  TFF.%NotDel% 								  
	INNER JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%  AND
	 							  TFL.TFL_CODIGO = TFF.TFF_CODPAI AND 
	 							  TFL.%NotDel% 
	INNER JOIN %table:TFJ% TFJ ON TFJ.TFJ_FILIAL = %xFilial:TFJ%  AND
	 							  TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND 
	 							  TFJ.%NotDel% 
	INNER JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%  AND
	 							  ABS.ABS_LOCAL  = TFL.TFL_LOCAL  AND 
	 							  ABS.%NotDel% 
	WHERE TGY.TGY_FILIAL=%xFilial:TGY%
  	  AND TGY.%NotDel% 
 	  AND TGY.TGY_ATEND  BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
 	  AND TGY.TGY_ULTALO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
 	  AND TFL.TFL_LOCAL  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% 
 	  AND TFF.TFF_FUNCAO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% 
      AND TFJ.TFJ_CONTRT BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
	UNION ALL
	SELECT TGZ.TGZ_ATEND  TGY_ATEND,
		   TGZ.TGZ_ESCALA TGY_ESCALA,
		   TGZ.TGZ_TURNO  TGY_TURNO,
		   TGZ.TGZ_SEQ 	  TGY_SEQ,
		   ABS.ABS_CODIGO,
		   ABS.ABS_LOJA,
		   ABS.ABS_LOCAL,
		   ABS.ABS_DESCRI,
		   TGZ.TGZ_DTINI  TGY_DTINI,
		   TGZ.TGZ_DTFIM  TGY_ULTALO,
		   TGZ.TGZ_DTFIM  TGY_DTFIM,
		   "" TGY_ENTRA1,
		   "" TGY_SAIDA1,
		   "" TGY_ENTRA2,
		   "" TGY_SAIDA2,
		   "" TGY_ENTRA3,
		   "" TGY_SAIDA3,
		   "" TGY_ENTRA4,
		   "" TGY_SAIDA4,
		   TGZ.TGZ_CODTFF,
		   TFF.TFF_FUNCAO,
		   %Exp:cSim% COBERTURA //Sim
	FROM %table:TGZ% TGZ
	INNER JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF% AND
								  TFF.TFF_COD 	 = TGZ_CODTFF    AND
								  TFF.%NotDel% 								  
	INNER JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%  AND
	 							  TFL.TFL_CODIGO = TFF.TFF_CODPAI AND 
	 							  TFL.%NotDel% 
	INNER JOIN %table:TFJ% TFJ ON TFJ.TFJ_FILIAL = %xFilial:TFJ%  AND
	 							  TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND 
	 							  TFJ.%NotDel% 
	INNER JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%  AND
	 							  ABS.ABS_LOCAL  = TFL.TFL_LOCAL  AND 
	 							  ABS.%NotDel% 
	WHERE TGZ.TGZ_FILIAL=%xFilial:TGZ%
  	  AND TGZ.%NotDel% 
 	  AND TGZ.TGZ_ATEND  BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
 	  AND (TGZ.TGZ_DTINI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
 	   OR TGZ.TGZ_DTFIM  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%)
 	  AND TFL.TFL_LOCAL  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% 
 	  AND TFF.TFF_FUNCAO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% 
      AND TFJ.TFJ_CONTRT BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%  
	ORDER BY TGY.TGY_ATEND,TGY.TGY_DTINI
   	
EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TGY_ATEND == cParam},{|| (cAlias1)->TGY_ATEND })

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960HrAlc()
Seleciona o horário de entrada e saida do posto.

@sample 	At960HrAlc(cTip,cAlias1)

@param		cTip, 		String,	E = Entrada, S = Saida.
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum

@author 	Kaique Schiller
@since		29/05/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At960HrAlc(cTip,cAlias1)
Local nX	   := 0
Local cEscala  := ""
Local cTurno   := ""
Local cSeq	   := ""
Local xHrRet   := ""
Local cDiaSem  := ""
Local cCodEftv := ""
Local cAliasTemp:= ""

//Verifica se existe horário flexivel na TGY caracter.
If cTip == "E" .And. !Empty((cAlias1)->TGY_ENTRA1)
	xHrRet := (cAlias1)->TGY_ENTRA1

Elseif cTip == "S"
	For nX := 1 to 4
		If !Empty(&("(cAlias1)->TGY_SAIDA" + cValToChar(nX)))
			xHrRet := &("(cAlias1)->TGY_SAIDA" + cValToChar(nX))
		EndIf
	Next nX
Endif

If Empty(xHrRet)

	//Verifica qual é o primeiro horário da escala conforme o turno e a sequencia.
	cEscala := (cAlias1)->TGY_ESCALA
	cTurno  := (cAlias1)->TGY_TURNO
	cSeq	:= (cAlias1)->TGY_SEQ

	cAliasTemp := GetNextAlias()

	BeginSql Alias cAliasTemp

		SELECT 	TGW.TGW_HORINI,
				TGW.TGW_HORFIM,
				TGW.TGW_DIASEM,
				TGW.TGW_EFETDX
		FROM 
			%table:TGW% TGW
		INNER JOIN %table:TDX% TDX ON TDX.TDX_FILIAL = %xFilial:TDX% AND
			TDX.TDX_CODTDW = %Exp:cEscala%  AND
			TDX.TDX_TURNO  = %Exp:cTurno%   AND
			TDX.TDX_SEQTUR = %Exp:cSeq%     AND
			TDX.TDX_COD    = TGW.TGW_EFETDX AND
			TDX.%NotDel%

		WHERE TGW.TGW_FILIAL = %xFilial:TGW% AND
			  TGW.%NotDel%

		ORDER BY TGW.TGW_FILIAL,TGW.TGW_EFETDX,TGW.TGW_DIASEM,TGW_HORINI

	EndSql

	(cAliasTemp)->(DbGoTop())

	cDiaSem  := (cAliasTemp)->TGW_DIASEM
	cCodEftv := (cAliasTemp)->TGW_EFETDX

	While (cAliasTemp)->(!EOF()) .And. cDiaSem == (cAliasTemp)->TGW_DIASEM .And. cCodEftv == (cAliasTemp)->TGW_EFETDX
		If cTip == "E"
			xHrRet :=  (cAliasTemp)->TGW_HORINI
			Exit

		Elseif cTip == "S"
			xHrRet :=  (cAliasTemp)->TGW_HORFIM
		Endif
	
		(cAliasTemp)->(dbSkip())
	EndDo

	(cAliasTemp)->(dbCloseArea())

	If Empty(xHrRet)

		cAliasTemp := GetNextAlias()

		BeginSql Alias cAliasTemp

			SELECT 	SPJ.PJ_ENTRA1, SPJ.PJ_SAIDA1,
					SPJ.PJ_ENTRA2, SPJ.PJ_SAIDA2, 
					SPJ.PJ_ENTRA3, SPJ.PJ_SAIDA3,
					SPJ.PJ_ENTRA4, SPJ.PJ_SAIDA4
			FROM 
				%table:SPJ% SPJ
			WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
				AND SPJ.PJ_TURNO = %Exp:cTurno%
				AND SPJ.PJ_SEMANA = %Exp:cSeq%
				AND SPJ.PJ_TPDIA = 'S'
				AND SPJ.%NotDel%

			ORDER BY SPJ.PJ_FILIAL,SPJ.PJ_TURNO,SPJ.PJ_SEMANA,SPJ.PJ_DIA

		EndSql

		(cAliasTemp)->(DbGoTop())

		If (cAliasTemp)->(!EOF())
			For nX := 1 To 4
				If cTip == "E"
					xHrRet :=  cValtoChar((cAliasTemp)->PJ_ENTRA1)
					Exit
				Elseif cTip == "S" .And. &("(cAliasTemp)->PJ_SAIDA"+cValtoChar(nX)) <> 0
					xHrRet :=  cValToChar(&("(cAliasTemp)->PJ_SAIDA"+cValtoChar(nX)))
				Endif
			Next nX
		Endif
		(cAliasTemp)->(dbCloseArea())
	Endif
Endif

If Valtype(xHrRet) == "C"
	xHrRet := Val(xHrRet)
Endif

xHrRet := Atr960CvHr(xHrRet)

Return xHrRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Atr960CvHr
Realiza conversão de hora para formato utilizado pela rotina

@since 03/06/2019
@author Kaique Schiller
@param nHora, numérico, Hora no formato Inteiro
@return String, Hora em String no formato utilizado pela rotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Atr960CvHr(nHoras)
Local nHora := Int(nHoras)
Local nMinuto := (nHoras - nHora)*100

Return(StrZero(nHora, 2) + ":" + StrZero(nMinuto, 2))
