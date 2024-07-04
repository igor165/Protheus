#Include "TopConn.CH"
#Include "Protheus.ch"
#Include "PLSR951.ch"

//-----------------------------------------------------------------------
/*/{Protheus.doc} PLSR951
Relatório de Documentos Pendentes.

@author Rodrigo Morgon
@since 06.08.2015
@version P12 				
/*/
//-----------------------------------------------------------------------
Function PLSR951(lAuto)
Local oReport
default lAuto := .F.

If lauto 
	oReport := ReportDef()
	PL951Email()
else
	If IsBlind()
		//Geração automatica do relatório via Schedule
		PL951Email() 
	Else
		//Geração manual via remote
		oReport := ReportDef()
		oReport:PrintDialog()
	Endif
Endif

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Cria células que serão impressas no relatório

@author Rodrigo Morgon
@since 06.08.2015
@version P12 				
/*/
//-----------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oSection
Local cPerg := "PLSR951"

Pergunte(cPerg,.F.)

oReport:= TReport():New("PLSR951",STR0001,cPerg,{|oReport|PrintReport(oReport)},STR0001)//"Relação de Documentos"
oReport:SetLandscape(.T.)
oReport:SetTotalInLine(.T.)
oReport:lParamPage := (.F.)

oSection := TRSection():New(oReport,"Documentos Redes de Atendimento",{"BC8","BAU","BD2"})
oSection:SetTotalInLine(.F.)
oSection:SetHeaderPage(.T.)  
oSection:SetHeaderSection(.T.)

TRCell():New(oSection,"BC8_CODIGO"	,"PLSR951",STR0002,,10,,,,,,,,,,,,.F.)	//"RDA"
TRCell():New(oSection,"BAU_NOME"	,"PLSR951",STR0003,,,,,,,,,,,,,,.F.)	//"Descricao"
TRCell():New(oSection,"BC8_CODDOC"	,"PLSR951",STR0004,,,,,,,,,,,,,,.F.)	//"Cod. Doc."
TRCell():New(oSection,"BD2_DESCRI"	,"PLSR951",STR0005,,50,,,,,,,,,,,,.F.)	//"Documento"	
TRCell():New(oSection,"BC8_DOCENT"	,"PLSR951",STR0006,,8,,,,,,,,,,,,.F.)	//"Status"

oFunction := TRFunction():New(oSection:Cell('BC8_CODIGO'),"Total: ", 'COUNT' )

oFunction:lEndSection := .T.
oFunction:lEndReport  := .F.

Return oReport

//-----------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Busca dados para impressão do relatório

@author 	Rodrigo Morgon
@since 		06.08.2015
@version 	P12 		
@param		oReport	Objeto do relatório TReport						
/*/
//-----------------------------------------------------------------------
Static Function PrintReport(oReport)
Local cQuery 		:= ""
Local nRegis		:= 0
Local aDados  	:= {}
Local nI      	:= 0
Local oSection 	:= oReport:Section(1) 
Private cAlias	:= "PLSR951"

aDados:= PL951Query()

nRegis := len(aDados)
oReport:SetMeter(nRegis) 
	
For nI:= 1 to nRegis
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf				    
	
	If nI == 1 
		oSection:Init()
	Endif	
	
	oSection:Cell("BC8_CODIGO"):SetValue(aDados[nI][1])
	oSection:Cell("BAU_NOME"):SetValue(aDados[nI][2])
	oSection:Cell("BC8_CODDOC"):SetValue(aDados[nI][3])
	oSection:Cell("BD2_DESCRI"):SetValue(aDados[nI][4])
	oSection:Cell("BC8_DOCENT"):SetValue(aDados[nI][5])
	oSection:PrintLine()		
	
	If nI == nRegis
		oSection:Finish()
	Endif	
Next
	
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} PL951Email
Envio do relatorio em formato .csv por e-mail via schedule.

@author 	Rodrigo Morgon
@since 		06.08.2015
@version 	P12 		
				
/*/
//-----------------------------------------------------------------------
Static Function PL951Email() 
Local aDados    := {}
Local nI        := 0
Local cMontaTxt := "" 
Local cDirGrava := "" //Diretório onde será armazenado a geração do relatório
Local cDestino  := "" //Email de destino do relatório  
Local aAnexo    := {}
Local nMesAtual := val(SubStr(DtoS(date()),5,2))
 
aDados:= PL951Query()

cDirGrava  := GetNewPar("MV_PLDIRDA","C:\")
cDestino   := alltrim(MV_PAR06)

If !Empty(aDados)
	//Monta o cabecalho da planilha de relatório
	cMontaTxt += STR0002 + ";"	//"RDA"
	cMontaTxt += STR0003 + ";"	//"Descrição"
	cMontaTxt += STR0004 + ";"	//Cod.Doc."
	cMontaTxt += STR0005 + ";"	//"Documento"
	cMontaTxt += STR0006 + ";"	//"Status"
	cMontaTxt += CRLF 
	
	//Carrega os registros na planilha
	For nI:= 1 to len(aDados)
	   cMontaTxt += aDados[nI][1] + ";"
	   cMontaTxt += aDados[nI][2] + ";"
	   cMontaTxt += aDados[nI][3] + ";"
	   cMontaTxt += aDados[nI][4] + ";"
	   cMontaTxt += aDados[nI][5] + ";"
	   cMontaTxt += CRLF 
	Next
	
	cDirAnexo := alltrim(cDirGrava) + "\Documentos_RDA_" + SubStr(DtoS(date()),7,2) + "_" + SubStr(DtoS(date()),5,2) + "_" + SubStr(DtoS(date()),1,4) + ".csv"
	
	If File(cDirGrava)
		//adicionando o arquivo como anexo
		aadd(aAnexo,cDirAnexo)
			
		//criar arquivo texto vazio a partir do root path no servidor
		nHandle := FCREATE(cDirAnexo)
			
		FWrite(nHandle,cMontaTxt)
			
		//encerra gravação no arquivo
		FClose(nHandle)
			
		//envia o arquivo via email 
		PlsWFProc("000001", STR0001, STR0001+SubStr(DtoS(date()),7,2)+"_"+SubStr(DtoS(date()),5,2)+"_"+SubStr(DtoS(date()),1,4), "PLSR951",cDestino, "" ,"" ,"\workflow\WfAutomatico.htm" ,,aAnexo,.F.)//"Relação de Documentos"
	Else
		Plslogfil(STR0009,cDirAnexo)//"Arquivo nao encontrado"		
	EndIf
Endif

Return (Nil)

//-----------------------------------------------------------------------
/*/{Protheus.doc} PL951Query
Filtro dos dados pelos parâmetros fornecidos no schedule

@author 	Rodrigo Morgon
@since 		06.08.2015
@version 	P12 		
				
/*/
//-----------------------------------------------------------------------
Static Function PL951Query()
Local cQuery    := ""
Local cAliasTrb := ""
Local aDados    := {}

cQuery := " SELECT BC8_CODIGO, BAU_NOME, BC8_CODDOC, BD2_DESCRI, (CASE BC8.BC8_DOCENT WHEN '0' THEN 'Pendente' ELSE 'Entregue' END) AS BC8_DOCENT "
cQuery += " FROM " + RetSqlName('BC8') + " BC8"
cQuery += " INNER JOIN " + RetSqlName('BAU') + " BAU ON BAU.BAU_FILIAL = '" + xFilial("BAU") + "' AND BAU.BAU_CODIGO = BC8.BC8_CODIGO AND BAU.D_E_L_E_T_ = ''"  
cQuery += " INNER JOIN " + RetSqlName('BD2') + " BD2 ON BD2.BD2_FILIAL = '" + xFilial("BD2") + "' AND BD2.BD2_CODDOC = BC8.BC8_CODDOC AND BD2.D_E_L_E_T_ = ''"		
cQuery += " WHERE "			
cQuery += " BC8.BC8_FILIAL = '"			+ xFilial("BC4") + "' AND"
cQuery += " BC8.BC8_CODIGO BETWEEN '"	+ mv_par01 + "' AND '" + mv_par02 + "' AND"
cQuery += " BC8.BC8_CODDOC BETWEEN '"	+ mv_par03 + "' AND '" + mv_par04 + "' AND"
cQuery += " BC8.BC8_DOCENT = '"			+ IIF(mv_par05 == 1, '0','1') + "' AND" 
cQuery += " BC8.D_E_L_E_T_ = ''"
cQuery += " ORDER BY BC8.BC8_CODIGO, BC8.BC8_CODDOC "

cQuery := ChangeQuery(cQuery)

cAliasTrb := GetNextAlias()

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
dbSelectArea(cAliasTrb)
dbGoTop()
 
While !(cAliasTrb)->(Eof())
	 aAdd( aDados, {	(cAliasTrb)->BC8_CODIGO,		;
	 					(cAliasTrb)->BAU_NOME, 		;
	 					(cAliasTrb)->BC8_CODDOC, 	;
	 					(cAliasTrb)->BD2_DESCRI, 	;
	 					(cAliasTrb)->BC8_DOCENT } )
 	(cAliasTrb)->(dbSkip())
Enddo

(cAliasTrb)->(dbCloseArea())
	
Return aDados

//-----------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Função responsável por habilitar o schedule na utilização do relatório.

@author 	Rodrigo Morgon
@since 		06.08.2015
@version 	P12 		
				
/*/
//-----------------------------------------------------------------------
Static Function SchedDef()
Local aParam
Local aOrd     := {}
aParam := { "R","PLSR951","BC8",aOrd,STR0001} 
Return aParam
