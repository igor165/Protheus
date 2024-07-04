#Include "GTPR311.ch"
#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

Static cAliasQry := GetNextAlias()
Static cPerg     := PadR('GTPR311',10)

/*/{Protheus.doc} GTPR311
(long_description)
@type function
@author henrique.toyada
@since 31/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR311()

Local oReport

IF Pergunte(cPerg,.T.)
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf
	
Return()


/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author henrique.toyada
@since 31/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()
Local oReport
Local oSecLinha
Local cAlColab := "GIC"

QryRel311()

oReport := TReport():New(STR0001,STR0001,cPerg,{|oReport| PrintReport(oReport)},STR0002) //STR0001 //"Este relatorio ira imprimir o relatório Geração/Acumulo Passagens" //"Geração/Acumulo Passagens"
oReport:SetTotalInLine(.F.)
oSecLinha := TRSection():New(oReport,"QDMP",{cAlColab} )
TRCell():New(oSecLinha,"GIC_LINHA" ,cAlColab,STR0003,,TamSX3("GIC_LINHA")[1] + 3,,,,,,,,,,,.T.) //"LINHA"
TRCell():New(oSecLinha,"GI2_PREFIX",cAlColab,STR0009,,TamSX3("GI2_PREFIX")[1]   ,,,,,,,,,,,.T.) //"Prefixo"
TRCell():New(oSecLinha,"TMP_LINHA" ,cAlColab,STR0004,,TAMSX3("GI3_NLIN")[1],,,,,,,,,,,.T.) //"DESCRIÇÃO "
TRCell():New(oSecLinha,"GIC_LOCORI",cAlColab,STR0007,,TamSX3("GIC_LOCORI")[1] + 3   ,,,,,,,,,,,.T.)
TRCell():New(oSecLinha,"TMP_LOCORI",cAlColab,STR0004,,TAMSX3("GI1_DESCRI")[1]   ,,,,,,,,,,,.T.) //"DESCRIÇÃO "
TRCell():New(oSecLinha,"GIC_LOCDES",cAlColab,STR0008,,TamSX3("GIC_LOCDES")[1] + 3   ,,,,,,,,,,,.T.)
TRCell():New(oSecLinha,"TMP_LOCDES",cAlColab,STR0004,,TAMSX3("GI1_DESCRI")[1]   ,,,,,,,,,,,.T.) //"DESCRIÇÃO "
TRCell():New(oSecLinha,"TMP_QTD"   ,cAlColab,STR0005,,07                        ,,,,,,,,,,,.T.) //"QUANT"

oSecLinha:SetHeaderPage(.T.)

TRFunction():New(oSecLinha:Cell('TMP_QTD'),,'SUM',,,,,.F.,.T.,.F.,oSecLinha,,,)
	
Return(oReport)


/*/{Protheus.doc} PrintReport
(long_description)
@type function
@author henrique.toyada
@since 31/10/2018
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PrintReport(oReport)
	
	Local aArea		:= GetArea()
	Local oSecLinha := oReport:Section(1)
	Local cValLin   := ""
	Local nBilhete  := 0
	Local nCont     := 0 
	Local aInfQry   := AjustArray()

	oSecLinha:Init()
	
	For nCont := 1 To Len(aInfQry)
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()
		
		//Verifica a Linha e calculando os Bilhetes
		nNext := IIF(nCont == Len(aInfQry),nCont,nCont + 1)
		If (EMPTY(cValLin) .OR. cValLin == aInfQry[nCont,1]+aInfQry[nCont,4]+aInfQry[nCont,6])
		
			nBilhete += aInfQry[nCont,8]
			
			cValLin := aInfQry[nCont,1]+aInfQry[nCont,4]+aInfQry[nCont,6]
		EndIf		
			
		If cValLin != aInfQry[nNext,1]+aInfQry[nNext,4]+aInfQry[nNext,6] .OR. Len(aInfQry) == nCont
			oSecLinha:Cell("GIC_LINHA" ):SetValue(aInfQry[nCont,1])
			oSecLinha:Cell("GI2_PREFIX"):SetValue(aInfQry[nCont,2])
			oSecLinha:Cell("TMP_LINHA" ):SetValue(aInfQry[nCont,3])
			oSecLinha:Cell("GIC_LOCORI"):SetValue(aInfQry[nCont,4])
			oSecLinha:Cell("TMP_LOCORI"):SetValue(aInfQry[nCont,5])
			oSecLinha:Cell("GIC_LOCDES"):SetValue(aInfQry[nCont,6])
			oSecLinha:Cell("TMP_LOCDES"):SetValue(aInfQry[nCont,7])
			oSecLinha:Cell("TMP_QTD"   ):SetValue(IIF(nBILHETE == 0,aInfQry[nCont,8],nBILHETE))
			oReport:FatLine()
			oSecLinha:PrintLine()
			oReport:SkipLine(1)
			nBilhete := 0
			cValLin := aInfQry[nNext,1]+aInfQry[nNext,4]+aInfQry[nNext,6]
		EndIf

	Next nCont
	
	oSecLinha:Finish()
	
	RestArea(aArea)
Return


/*/{Protheus.doc} QryRel311
(long_description)
@type function
@author henrique.toyada
@since 31/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function QryRel311()
	
Local aArea		:= GetArea()
Local cQryGI4   := ""
Local cQryGI2   := ""
Local cQryGIC   := ""

Pergunte(cPerg,.F.)
	
	IF !Empty(MV_PAR01)
		cQryGI2 +="	AND GI2.GI2_ORGAO='"+ MV_PAR01 +"' " + Chr(13)
	EndIf
	IF MV_PAR06 = 1 //Ativo
		cQryGI2 +=" AND GI2.GI2_MSBLQL='2' " + Chr(13)
	ElseIF MV_PAR06 = 2 //Inativo
		cQryGI2 +="	AND GI2.GI2_MSBLQL='1' " + Chr(13)
	EndIf
	If !Empty(MV_PAR08)
		cQryGI2 +="	AND GI2_TIPLIN = '" + MV_PAR08 + "' " + Chr(13)
	EndIf
	
	cQryGI2 := "%"+cQryGI2+"%"
	
	IF MV_PAR07 = 1 //2=Ativo
		cQryGI4 +="	AND GI4.GI4_MSBLQL = '2' " + Chr(13)
	ElseIf MV_PAR07 = 2 //1=Inativo
		cQryGI4 +="	AND GI4.GI4_MSBLQL = '1' " + Chr(13)
	EndIf
	
	If MV_PAR09 = 1 //1-Com CCS
		cQryGI4 +="	AND GI4_CCS <> ' ' " + Chr(13)
	ElseIf MV_PAR09 = 2 //2-Sem CCS
		cQryGI4 +="	AND GI4_CCS = ' ' " + Chr(13)
	EndIf
	
	cQryGI4 := "%"+cQryGI4+"%"
	
	IF !(Empty(MV_PAR02)) .OR. !(Empty(MV_PAR03))  
		cQryGIC +=" AND GIC_LINHA BETWEEN '" + MV_PAR02 + "' And '" +  MV_PAR03 + "' "	+ Chr(13)
	EndIF
	
	IF !(Empty(MV_PAR04)) .OR. !(Empty(MV_PAR05))  
		cQryGIC +=" AND GIC_DTVIAG BETWEEN '" + DtoS(MV_PAR04) + "' And '" +  DtoS(MV_PAR05) + "' "	+ Chr(13)
	EndIF
	
	cQryGIC := "%"+cQryGIC+"%"
	
BeginSQL Alias cAliasQry

	SELECT 	GIC_LINHA,GIC_LOCORI,GIC_LOCDES,GIC_CODSRV,GIC_DTVIAG, 
			GYN_LOCORI,GYN_LOCDES,COUNT(GIC_CODIGO) As BILHETE 	
	FROM %Table:GIC% GIC 
	INNER JOIN %Table:GYN% GYN 
		ON GYN_FILIAL = %xFilial:GYN% 
		AND GYN_CODIGO = GIC_CODSRV 
		AND GYN_TIPO = '1' 
		AND GYN_FINAL = '1' 
		AND GYN.%NotDel%
	INNER JOIN %Table:GID% GID 
		ON GID.GID_FILIAL = %xFilial:GID% 
		AND GID.GID_COD = GIC.GIC_CODGID		
		AND GID.GID_SENTID = GIC.GIC_SENTID 
		AND GID.%NotDel%
	INNER JOIN %Table:GI2% GI2  
		ON GI2.GI2_FILIAL = %xFilial:GI2% 
		AND GI2.GI2_COD = GIC.GIC_LINHA
		%Exp:cQryGI2%
		AND GI2.%NotDel%
	INNER JOIN %Table:GI4% GI4  
		ON GI4.GI4_FILIAL = %xFilial:GI4% 
		AND GI4.GI4_LINHA = GIC.GIC_LINHA	
		AND GI4.GI4_LOCORI = GIC.GIC_LOCORI	
		AND GI4.GI4_LOCDES = GIC.GIC_LOCDES	
		AND GI4.GI4_HIST = '2'				
		AND GI4.%NotDel%
		%Exp:cQryGI4%
	WHERE GIC.%NotDel% 
		  %Exp:cQryGIC%
		  AND GIC_NUMDOC != '' 
	GROUP BY GIC_LINHA,GIC_LOCORI,GIC_LOCDES,GIC_CODSRV,GIC_DTVIAG,GYN_LOCORI,GYN_LOCDES 
	ORDER BY GIC_LINHA,GIC_LOCORI,GIC_LOCDES,GIC_CODSRV 
EndSQL



Return

/*/{Protheus.doc} AjustArray
(long_description)
@type function
@author henrique.toyada
@since 01/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AjustArray()

Local aInfQry := {}

	(cAliasQry)->(DbGoTop())
	
	While (cAliasQry)->(!Eof())
		AADD(aInfQry,{;
			(cAliasQry)->GIC_LINHA,;
			Alltrim(Posicione("GI2",1,xFilial("GI2")+(cAliasQry)->GIC_LINHA,"GI2_PREFIX")),;
			AllTrim(TPNOMELINH((cAliasQry)->GIC_LINHA)),;
			(cAliasQry)->GIC_LOCORI,;
			(Alltrim(Posicione("GI1", 1, xFilial("GI1")+(cAliasQry)->GIC_LOCORI, "GI1_DESCRI"))),;
			(cAliasQry)->GIC_LOCDES,;
			Alltrim(Posicione("GI1", 1, xFilial("GI1")+(cAliasQry)->GIC_LOCDES, "GI1_DESCRI")),;
			(cAliasQry)->BILHETE;
		})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Return aInfQry
