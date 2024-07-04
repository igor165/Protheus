#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE FILIAL 			1
#DEFINE EVENT 			2
#DEFINE DATAINI			3
#DEFINE DATAFIM			4
#DEFINE TRANSMITIDOS	5
#DEFINE TAF_KEY			6
#DEFINE TIPOEVENTO		7
#DEFINE OWNER			8

Static lVersaoFwt := GetVersao(.F.) >= '12'

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFR121
Emissão do relatório de conferencia do eSocial

@author TOTVS
@since 05/09/2018
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Function TAFR121()

	Local aProfile		:= {}
	Local oReport		:= Nil
	Local lContinua		:= .T.
	Local cPerg			:= "TAFR121"
	Local oTabFilSel	:= Nil //Tabela temporaria com as filiais selecionadas
	Local oTabEvtSel	:= Nil //Tabela temporaria com os eventos selecionados
	Local aFilSel		:= {}
	Local aParamBox		:= {}
	Local aRetParam		:= {}
	Local cAliasTmp		:= ""
	Local cIndex1		:= ""
	Local cIndex2		:= ""
	Local lPermCont		:= IIf(FindFunction("PROTDATA"),ProtData(),.T.)
	Local oProfile 		:= Nil
	
	If lPermCont

		oProfile := FWProfile():New()

		oProfile:SetUser(RetCodUsr())
		oProfile:SetProgram(FunName())
		oProfile:Load()

		aProfile := oProfile:GetProfile()

		aAdd(aParamBox, {2, "Seleciona filiais"		, Iif(Empty(aProfile), 1			, aProfile[1])	, {"1=Sim", "2=Não"}												, 40	, ".T."	, .T.				})
		aAdd(aParamBox, {2, "Seleciona eventos"		, Iif(Empty(aProfile), 1			, aProfile[2])	, {"1=Sim", "2=Não"}												, 40	, ".T."	, .T.				})
		aAdd(aParamBox, {1, "Data De"   			, Iif(Empty(aProfile), dDataBase	, aProfile[3])	, ""																, '.T.'	, ""	, ".T.", 50	, .T.	})
		aAdd(aParamBox, {1, "Data Até"  			, Iif(Empty(aProfile), dDataBase	, aProfile[4])	, ""																, '.T.'	, ""	, ".T.", 50	, .T.	})
		aAdd(aParamBox, {2, "Trasmitidos"			, Iif(Empty(aProfile), 1			, aProfile[5])	, {"1=Todos", "2=Sem Retorno", "3=Inconsistentes", "4=Consistentes"}, 70	, ".T."	, .T.				})
		aAdd(aParamBox, {1, "TAFKEY"  				, Iif(Empty(aProfile), Space(99)	, aProfile[6])	, ""																, '.T.'	, ""	, ".T.", 100, .F.	})
		aAdd(aParamBox, {2, "Tipo Eventos"			, Iif(Empty(aProfile),				, aProfile[7])	, {"M=Periódicos", "E=Não Periódicos", "C=Tabela"}					, 60	, ".T."	, .T.				})
		aAdd(aParamBox, {1, "Owner"  				, Iif(Empty(aProfile), Space(99)	, aProfile[8])	, ""																, '.T.'	, ""	, ".T.", 100, .F.	})	
		
		lContinua := ParamBox(aParamBox, "Filtros", @aRetParam)

		oProfile:SetProfile(aRetParam)
		oProfile:Save()

		//--------------------
		// Seleção de filiais
		//--------------------
		If lContinua
			lContinua := TAFR121Fil(@aFilSel, aRetParam)
		EndIf
		
		//--------------------
		// Seleção de eventos
		//--------------------
		If lContinua
			lContinua := TAFR121Evt(@oTabEvtSel, @cAliasTmp, @cIndex1, @cIndex2, aRetParam)
		EndIf
		
		//-----------------------------------
		// Montagem e impressao do relatorio
		//-----------------------------------
		If lContinua
			oReport := ReportDef(cPerg,@aFilSel,@oTabFilSel,@oTabEvtSel, @cAliasTmp, aRetParam)
			oReport:PrintDialog()
		EndIf
		
		//------------------
		// Limpeza do array
		//------------------
		ASize(aFilSel,0)
		aFilSel := Nil
		
		//-----------------------------------------------------
		// Exclui a tabela temporaria das Filiais selecionadas
		//-----------------------------------------------------
		If lVersaoFwt .And. oTabFilSel <> Nil
			oTabFilSel:Delete()
		EndIf
		
		//-----------------------------------------------------
		// Exclui a tabela temporaria dos eventos selecionados
		//-----------------------------------------------------
		If lVersaoFwt
			If oTabEvtSel <> Nil
				oTabEvtSel:Delete()
			EndIf
		Else
			FErase( cAliasTmp + GetDBExtension() )
			FErase( cIndex1 + OrdBagExt() )
			FErase( cIndex2 + OrdBagExt() )
		EndIf

		FWFreeObj(oProfile)
		FWFreeArray(aParamBox)
		FWFreeArray(aRetParam)
		FWFreeArray(aProfile)

	EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição de layout do relatório

@author TOTVS
@since 05/09/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function ReportDef(cPerg,aFilSel,oTabFilSel,oTabEvtSel,cAliasTmp, aRetParam)
Local oSection	:= Nil
Local oReport	:= Nil
Local cAliasQry	:= GetNextAlias()
Local cReport	:= "TAFR121"
Local cTitulo	:= "Conferência eSocial"
Local cDescri	:= "Relatório para conferência dos eventos do e-Social. Projetado para geração de Planilha, para outros tipos, recomendasse a remoção de colunas por meio do recurso de personalização do relatório."
Local bDescErro	:= {|| TAFR121Dsc(cAliasQry) }

                       //cReport ,cTitle  ,uParam ,bAction                                                                           ,cDescription ,lLandscape ,uTotalText ,lTotalInLine ,cPageTText ,lPageTInLine ,lTPageBreak ,nColSpace
oReport := TReport():New(cReport ,cTitulo ,cPerg  ,{|oReport| PrintReport(oReport,cPerg,cAliasQry,@aFilSel,@oTabFilSel,@oTabEvtSel,cAliasTmp, aRetParam)} ,cDescri      ,.T.        ,           ,.F.          ,           ,             ,            ,         )

//----------------------------------------------------------------------
// Configura a tela de paramêtros para vir selecionado a opção planilha
//----------------------------------------------------------------------
oReport:NDEVICE := IMP_EXCEL //IMP_PDF|IMP_DISCO|IMP_SPOOL|IMP_EMAIL|IMP_HTML|IMP_PDF|IMP_ODF|IMP_PDFMAIL|IMP_MAILCOMPROVA

oReport:SetLandscape(.T.)   //Define a orientação de página do relatório como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
oReport:DisableOrientation() // Desabilita a seleção Retrato/Paisagem

                          //oParent ,cTitle ,uTable    ,aOrder ,lLoadCells ,lLoadOrder ,uTotalText ,lTotalInLine ,lHeaderPage ,lHeaderBreak ,lPageBreak ,lLineBreak ,nLeftMargin ,lLineStyle ,nColSpace ,lAutoSize ,cCharSeparator ,nLinesBefore ,nCols ,nClrBack ,nClrFore ,nPercentage
oSection := TRSection():New(oReport ,       ,cAliasQry ,       ,           ,           ,           ,             ,            ,             ,           ,           ,            ,           ,          ,          ,               ,             ,      ,         ,         ,           )

           //oParent  ,cName       ,cAlias    ,cTitle               ,cPicture ,nSize ,lPixel ,bBlock    ,cAlign ,lLineBreak ,cHeaderAlign ,lCellBreak ,nColSpace ,lAutoSize ,nClrBack ,nClrFore ,lBold
TRCell():New(oSection ,"FILIAL"    	,cAliasQry ,"Filial"             			,         ,12    ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"TAFTICKET" 	,cAliasQry ,"TAF Ticket"         			,         ,36    ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"TAFKEY"    	,cAliasQry ,"Chave ERP (TAFKEY)" 			,         ,50    ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"EVENTO"    	,cAliasQry ,"Evento"             			,         ,8     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"STATUS"    	,cAliasQry ,"Status"             			,         ,      ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"CHVNEGOC"  	,cAliasQry ,"Chave de Negócio"   			,         ,50    ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"SEQERR"    	,cAliasQry ,"Sequencia da Inconsistência"  	,         ,3     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"CODERR"    	,cAliasQry ,"Código da Inconsistência"     	,         ,10    ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"DCERRO"    	,cAliasQry ,"Descrição da Inconsistência"  	,         ,50    ,       ,bDescErro ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"DATA"      	,cAliasQry ,"Data da Inconsistência"        ,         ,8     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"HORA"      	,cAliasQry ,"Hora da Inconsistência"        ,         ,8     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"PROTOCOLO" 	,cAliasQry ,"Protocolo"          			,         ,25    ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"TOTINSS"   	,cAliasQry ,"Totalizador INSS"   			,         ,3     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"TOTIRRF"   	,cAliasQry ,"Totalizador IRRF"   			,         ,3     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"TOTCINSS"  	,cAliasQry ,"Tot. Cons. INSS"    			,         ,3     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"TOTCIRRF"  	,cAliasQry ,"Tot. Cons. IRRF"    			,         ,3     ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )
TRCell():New(oSection ,"OWNER"  	,cAliasQry ,"Origem"    		 			,         ,40    ,       ,          ,       ,           ,             ,           ,          ,.T.       ,         ,         ,     )

//----------------------------------------------------------------------
// Tratamento para apresentar a descrição dos status ao invés do código
//----------------------------------------------------------------------
oReport:Section(1):Cell("STATUS"):SetCBox(' =Não Processado;0=Válido - Pronto para Transmissão;1=Inválido;2=Aguardando Retorno do Governo;3=Inconsistente;4=Aceito pelo RET')

Return oReport

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Rotina de Impressão de dados

@author TOTVS
@since 05/09/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function PrintReport(oReport,cPerg,cAliasQry,aFilSel,oTabFilSel,oTabEvtSel,cAliasTmp, aRetParam)
Local oSection	:= oReport:Section(1)
Local cQuery	:= ""

//----------------------------------------------------------------------------------------------------------
// Caso o relatório tenha sido alterado para um formato de impressao diferente de Planilha, avisa o cliente
// que é recomendada a personalização para remoção das colunas, para não ocorrer corte das informações
//----------------------------------------------------------------------------------------------------------
If oReport:NDEVICE != IMP_EXCEL
	Help(" ",1,"TAFR121",,'Selecionada geração diferente de "Planilha".',1,0,,,,,,{'Para outros tipos de geração, utilize o recurso "Personalizar" para remover as colunas excedentes.' })
EndIf

cQuery := "%" + TAFR121Qry(@aFilSel,@oTabFilSel,@oTabEvtSel,cAliasTmp, aRetParam) + "%"

BEGIN REPORT QUERY oSection

BeginSql alias cAliasQry

SELECT * FROM (%Exp:cQuery%) TAFR121 ORDER BY FILIAL, TAFTICKET, TAFKEY, EVENTO, SEQERR, DATA, HORA

EndSql

END REPORT QUERY oSection

oSection:Print()

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR121Qry

Query para consulta dos dados

@Author		TOTVS
@Since		24/09/2018
@Version	12.1.17
/*/
//---------------------------------------------------------------------
Static Function TAFR121Qry(aFilSel, oTabFilSel, oTabEvtSel, cAliasTmp, aRetParam)

	Local aTAFKEY		:= {}
	Local cQuery		:= ""
	Local cTAFKEY		:= aRetParam[TAF_KEY]
	Local cAliasLay		:= ""
	Local cLayout		:= ""
	Local cCmpData		:= ""
	Local cTipoEvt		:= ""
	Local cIniEsoc		:= SuperGetMv('MV_TAFINIE',.F.," ")
	Local cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"02_04_01")
	Local cStatus		:= "' ','0','1',"
	Local cAliasEvt		:= "" 
	Local lTAFKEY		:= .F.
	Local nX			:= 0

	If lVersaoFwt
		cAliasEvt := oTabEvtSel:GetAlias()
	Else
		cAliasEvt := cAliasTmp
	EndIf

	//---------------------------------------------------
	// Tratamento para adequacao do TAFKEY, se informado
	//---------------------------------------------------
	If !Empty( cTAFKEY )
		aTAFKEY	:=	StrToKArr( cTAFKEY, "," )

		cTAFKEY := ""

		For nX := 1 to Len( aTAFKEY )
			cTAFKEY += "'" + AllTrim( aTAFKEY[nX] ) + "'" + ","
		Next nX

		cTAFKEY := SubStr( cTAFKEY, 1, Len( cTAFKEY ) - 1 )

		lTAFKEY	:= !Empty( cTAFKEY )
	EndIf

	//-----------------------------------------------------------------------
	// Montagem dos status conforme seleção do parametro Status Transmitidos
	//-----------------------------------------------------------------------
	If cValToChar(aRetParam[TRANSMITIDOS]) == "1" //Todos
		cStatus += "'2','3','4'"
	ElseIf cValToChar(aRetParam[TRANSMITIDOS]) == "2" //Sem retorno
		cStatus += "'2'"
	ElseIf cValToChar(aRetParam[TRANSMITIDOS]) == "3" //Inconsistentes
		cStatus += "'3'"
	ElseIf cValToChar(aRetParam[TRANSMITIDOS]) == "4" //Consistentes
		cStatus += "'4'"
	EndIf

	DBSelectArea(cAliasEvt)
	(cAliasEvt)->(DBGoTop())
	While (cAliasEvt)->(!EOF())

		If Empty((cAliasEvt)->MARK)
			(cAliasEvt)->(DBSkip())
			Loop
		EndIf

		cAliasLay	:= AllTrim((cAliasEvt)->ALIAS)	//Alias do Evento
		cLayout		:= (cAliasEvt)->EVENTO			//Layout
		cCmpData	:= AllTrim((cAliasEvt)->CPODAT)	//Campo que determina o periodo ou data do evento
		cTipoEvt	:= (cAliasEvt)->TIPO			//Tipo do Evento (I-Inicial,M-Mensal,E-Eventual,C-Carga,T-Totalizador)

		If !Empty(cQuery)
			cQuery += " UNION ALL "
		EndIf

		cQuery += "SELECT DISTINCT "
		cQuery +=	" ISNULL(" + cAliasLay + "." + cAliasLay + "_FILIAL ,' ') FILIAL "
		cQuery +=	" ,ISNULL(TAFXERP.TAFTICKET,'Entrada manual') TAFTICKET "
		cQuery +=	" ,ISNULL(TAFXERP.TAFKEY,'Entrada manual') TAFKEY "
		cQuery +=	" ,'" + cLayout + "' EVENTO "
		cQuery +=	" ," + cAliasLay + "." + cAliasLay + "_STATUS STATUS "
		cQuery +=	" , ISNULL(V2H.V2H_SEQERR, ' ') SEQERR "
		cQuery +=	" , ISNULL(V2H.V2H_CODERR, ' ') CODERR "
		cQuery +=	" , ISNULL(V2H.V2H_DATA, ' ') DATA "
		cQuery +=	" , ISNULL(V2H.V2H_HORA, ' ') HORA "
		cQuery +=	" , ISNULL(V2H.R_E_C_N_O_, 0) V2H_RECNO "
		cQuery +=	" , ISNULL(T0X.R_E_C_N_O_, 0) T0X_RECNO "
		cQuery +=	" ," + cAliasLay + "." + cAliasLay + "_PROTUL PROTOCOLO "
		cQuery +=	" , ISNULL(TAFST2.TAFOWNER, '') OWNER "

		//------------------------------------------
		// Obtem a chave de negócio conforme evento
		//------------------------------------------
		cQuery += TAFR121Chv(cLayout,1)

		//-------------------------------------------
		// Coluna para identificar se há totalizador
		//-------------------------------------------
		cQuery += TAFR121Tot(cLayout,1)

		cQuery += "FROM " + RetSqlName( cAliasLay ) + " " + cAliasLay + " "

		//-------------------------------------------------------------------------------------------
		// Realiza join com a C9V para montagem da chave de negócio do funcionário (Nome, CPF, etc.)
		//-------------------------------------------------------------------------------------------
		cQuery += TAFR121Chv(cLayout,2)

		//---------------------------------------------------------------------
		// Realiza join com as tabela de totalização para identificar o status
		//---------------------------------------------------------------------
		cQuery += TAFR121Tot(cLayout,2)

		If cLayout == "S-2200"
			cQuery += " INNER JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
			cQuery += " AND C9V_ID = CUP_ID AND C9V_FILIAL = CUP_FILIAL "
			cQuery += " AND C9V_VERSAO = CUP_VERSAO "
			cQuery += " AND CUP.D_E_L_E_T_ = ' ' "
			cQuery += TafMonPVinc(cIniEsoc,cVerSchema,cLayout,DToS(aRetParam[DATAINI]),DToS(aRetParam[DATAFIM]),cTipoEvt)
		EndIf

		//----------------------------------------------------------
		// Efetua JOIN com a TAFXERP para obter o Ticket e o TAFKEY
		//----------------------------------------------------------
		cQuery += If(lTAFKEY," INNER "," LEFT ") + " JOIN TAFXERP TAFXERP "
		cQuery += " ON TAFXERP.TAFALIAS = '" + cAliasLay + "' "
		cQuery += " AND TAFXERP.TAFRECNO = " + cAliasLay + ".R_E_C_N_O_ "
		
		If lTAFKEY
			cQuery += " AND TAFXERP.TAFKEY IN ( " + cTAFKEY + " ) "
		EndIf
		cQuery += " AND TAFXERP.D_E_L_E_T_ = ' ' "

		// Efetua JOIN com a TAFST2 para obter o Owner 
		cQuery += If(lTAFKEY," INNER "," LEFT ") + " JOIN TAFST2 TAFST2 "
		cQuery += " ON TAFXERP.TAFKEY = TAFST2.TAFKEY "
		cQuery += " AND TAFXERP.TAFTICKET = TAFST2.TAFTICKET "
		cQuery += " AND TAFST2.TAFCODMSG = '2' "
		cQuery += " AND TAFST2.TAFSTATUS = '3' "

		cQuery += " AND TAFST2.D_E_L_E_T_ = ' ' "

		//--------------------------------------------------------------------
		// Efetua JOIN com a V2H para obter:
		//  - Data de entrada no TSS
		//  - Hora de entrada no TSS
		//  - Código do erro
		//  - Descrição do erro
		//--------------------------------------------------------------------
		cQuery += "LEFT JOIN " + RetSqlName("V2H") + " V2H "
		cQuery += "  ON V2H.V2H_EVENTO = '" + cLayout + "' "
		cQuery += "  AND V2H.V2H_IDCHVE LIKE '%'||" + cAliasLay + "." + cAliasLay + "_ID||'%' "
		cQuery += "  AND V2H.D_E_L_E_T_ = ' ' "

		// Efetua o Join com a T0X
		cQuery += " LEFT JOIN " + RetSQLName("T0X") + " T0X "
		cQuery += " ON T0X.T0X_IDEVEN = '" + cLayout + "' "
		cQuery += " AND T0X.T0X_IDCHVE LIKE '%'||" + cAliasLay + "." + cAliasLay + "_ID||'%' "
		cQuery += " AND T0X.D_E_L_E_T_ = ' ' "

		cQuery += "WHERE " + cAliasLay + "." + cAliasLay + "_STATUS IN (" + cStatus + ") "

		//--------------------------------------------------------------------------------------
		// Filtra utilizando o evento devido as tabelas serem utilizadas para mais de um evento
		//--------------------------------------------------------------------------------------
		If cAliasLay $ "C9V|C91"
			cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_NOMEVE = '" + StrTran( cLayout, "-", "" ) + "' "
		EndIf

		cQuery += "  AND " + cAliasLay + ".D_E_L_E_T_ =  ' ' "

		If cAliasLay == "CM6"
			cQuery += "  AND ( CM6_ATIVO = '1' OR CM6_STASEC = 'E' OR ( CM6_ATIVO = '2' AND CM6_STATUS NOT IN ('4','7') AND CM6_PROTUL = ' ' ) )"
		ElseIf TafColumnPos( cAliasLay + "_STASEC" )
			cQuery += "  AND (" + cAliasLay + "." + cAliasLay + "_ATIVO = '1'  OR " + cAliasLay + "." +cAliasLay + "_STASEC = 'E' )"
		Else
			cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "
		EndIf

		//----------------------------------------------------------------------
		// Eventos de tabela não usam o S-3000 por isso desconsidero o Status E
		//----------------------------------------------------------------------
		If cTipoEvt != "C"
			cQuery += " AND " + cAliasLay + "_STATUS <> 'E'
		EndIf

		If cTipoEvt == "M" .Or. cAliasLay == "CMJ"
			cQuery += " AND (((" + cAliasLay + "." + cCmpData + " BETWEEN '" + AnoMes(aRetParam[DATAINI]) + "' AND '" + AnoMes(aRetParam[DATAFIM]) + "')"
			cQuery += " OR (" + cAliasLay + "." + cCmpData + " BETWEEN '" + Month2Str(aRetParam[DATAINI]) + Year2Str(aRetParam[DATAINI]) + "' AND '" + Month2Str(aRetParam[DATAFIM]) + Year2Str(aRetParam[DATAFIM]) + "')"
			cQuery += " OR (" + cAliasLay + "." + cCmpData + " BETWEEN '" + AllTrim(Str(Year(aRetParam[DATAINI]))) + "' AND '" + AllTrim(Str(Year(aRetParam[DATAFIM]))) + "'))"
			cQuery += " OR (" + cAliasLay + "_INDAPU = ' ' "
			cQuery += " AND " + cAliasLay + "." + cCmpData + " = ' ' AND '" + cAliasLay + "' = 'CMJ')" //Gera o evento 3000 quando nao for mensal.
			cQuery += ")"
		ElseIf cTipoEvt == "E" .And. !Empty(AllTrim(cCmpData)) .And. cAliasLay != "CMJ"
			cQuery += " AND " + cAliasLay + "." + cCmpData + " >= '" + DtoS( aRetParam[DATAINI] ) + "'"
			cQuery += " AND " + cAliasLay + "." + cCmpData + " <= '" + DtoS( aRetParam[DATAFIM] ) + "'"
		EndIf

		//Só pego S-1000 da matriz
		If cAliasLay == "C1E"
			cQuery += " AND C1E_MATRIZ = 'T' "
		EndIf

		If cLayout == "S-2300"
			cQuery += TafMonPSVinc(cIniEsoc,cVerSchema,cLayout,DToS( aRetParam[DATAINI] ),DToS( aRetParam[DATAFIM] ))
		EndIf

		If cAliaslay ==  "CM6"
			cQuery+= " AND (( "
			cQuery+= TafMonPAfast(cVerSchema,DToS( aRetParam[DATAINI] ),DToS( aRetParam[DATAFIM] ))
			cQuery+= " ) "
		EndIf

		If cAliasLay == "C1E"
			cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_FILTAF IN"
		Else
			cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_FILIAL IN"
		Endif

		If lVersaoFwt

			cQuery += " ( "
			cQuery += TafMonPFil(cAliasLay, @oTabFilSel, aFilSel)
			cQuery += " ) "

		Else

			cQuery += T121P11Fil(cAliasLay, @oTabFilSel, aFilSel)
			
		EndIf

		If cAliaslay ==  "CM6"
			cQuery += ")"
		EndIf

		//Só considera Evento do eSocial
		If AllTrim( cLayout ) $ "S-1070"
			cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_ESOCIA = '1' "
		EndIf

		If !Empty( aRetParam[OWNER] )
			cQuery += " AND TAFST2.TAFOWNER = '" + AllTrim( aRetParam[OWNER] ) + "' "
		EndIf

	(cAliasEvt)->(DBSkip())

	EndDo

Return cQuery

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR121Chv

Retorna a condição para chave de negócio.

@Author		TOTVS
@Since		24/09/2018
@Version	12.1.17
/*/
//---------------------------------------------------------------------
Static Function TAFR121Chv(cLayout,nTipo)
Local cQry		:= ""
Local cChvFunc	:= " ,'Nome: ' || RTRIM(C9V.C9V_NOME) || ' | CPF: ' || RTRIM(C9V.C9V_CPF) || ' | NIS: ' || RTRIM(C9V.C9V_NIS) CHVNEGOC "

If cLayout == "S-1000"
	If nTipo == 1
		cQry :=	" , 'Filial TAF: ' || RTRIM(C1E.C1E_FILTAF) || ' | Razão Social: ' || RTRIM(C1E.C1E_NOME) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1005"
	If nTipo == 1
		cQry :=	" , 'Nr.Insc.Est.: ' || RTRIM(C92.C92_NRINSC) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1010"
	If nTipo == 1
		cQry :=	" , 'Cod.Rubrica: ' || RTRIM(C8R.C8R_CODRUB) || ' | Desc.Rubrica: ' || RTRIM(C8R.C8R_DESRUB) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1020"
	If nTipo == 1
		cQry :=	", 'Cod.Lotação: ' || RTRIM(C99.C99_CODIGO) || ' | Desc.Lotação: ' || RTRIM(C99.C99_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1030"
	If nTipo == 1
		cQry :=	", 'Cód Cargo: ' || RTRIM(C8V.C8V_CODIGO) || ' | Nome Cargo: ' || RTRIM(C8V.C8V_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1035"
	If nTipo == 1
		cQry :=	", 'Evento: ' || RTRIM(T5K.T5K_EVENTO) || ' | Descrição: ' || RTRIM(T5K.T5K_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1040"
	If nTipo == 1
		cQry :=	", 'Cód Função: ' || RTRIM(C8X.C8X_CODIGO) || ' | Descr Função: ' || RTRIM(C8X.C8X_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1050"
	If nTipo == 1
		cQry :=	", 'Cód Turno: ' || RTRIM(C90.C90_CODIGO) || ' | Descr Turno: ' || RTRIM(C90.C90_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1060"
	If nTipo == 1
		cQry :=	", 'Cód Amb Trab: ' || RTRIM(T04.T04_CODIGO) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1070"
	If nTipo == 1
		cQry :=	", 'Num.Proc.: ' || RTRIM(C1G.C1G_NUMPRO) || ' | Descrição: ' || RTRIM(C1G.C1G_DESCRI) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1080"
	If nTipo == 1
		cQry :=	", 'CNPJ Op.Port: ' || RTRIM(C8W.C8W_CNPJOP) CHVNEGOC "
	EndIf

ElseIf cLayout $ "S-1200|S-1202"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = C91_TRABAL  AND C9V_FILIAL = C91_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1207"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T62_CPF AND C9V_FILIAL = T62_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1210"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T3P_BENEFI AND C9V_FILIAL = T3P_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1250"
	If nTipo == 1
		cQry :=	", 'Nr Inscrição: ' || RTRIM(CMR.CMR_INSCES) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1260"
	If nTipo == 1
		cQry :=	", 'Nr Ins Rural: ' || RTRIM(T1M.T1M_NRINSC) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1270"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T2A.T2A_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1280"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T3V.T3V_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1295"
	If nTipo == 1
		cQry :=	", 'Id. Resp.: ' || RTRIM(T72.T72_IDRESP) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1298"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T1S.T1S_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1299"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(CUO.CUO_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-1300"
	If nTipo == 1
		cQry :=	", 'ID: ' || RTRIM(T3Z.T3Z_ID) CHVNEGOC "
	EndIf

ElseIf cLayout == "S-2190"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T3A_CPF AND C9V_FILIAL = T3A_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2200"
	If nTipo == 1
		cQry :=	cChvFunc
	EndIf

ElseIf cLayout == "S-2205"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T1U_CPF AND C9V_FILIAL = T1U_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2206"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T1V_CPF AND C9V_FILIAL = T1V_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2210"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM0_TRABAL AND C9V_FILIAL = CM0_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2220"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = C8B_FUNC AND C9V_FILIAL = C8B_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2230"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM6_FUNC AND C9V_FILIAL = CM6_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2240"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM9_FUNC AND C9V_FILIAL = CM9_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2241"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T3B_IDTRAB AND C9V_FILIAL = T3B_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2250"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CM8_TRABAL AND C9V_FILIAL = CM8_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2260"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T87_TRABAL AND C9V_FILIAL = T87_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2298"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CMF_FUNC AND C9V_FILIAL = CMF_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2299"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CMD_FUNC AND C9V_FILIAL = CMD_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2300"
	If nTipo == 1
		cQry :=	cChvFunc
	EndIf

ElseIf cLayout == "S-2306"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T0F_CPF AND C9V_FILIAL = T0F_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2399"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = T92_TRABAL AND C9V_FILIAL = T92_FILIAL"
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2400"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_CPF = T5T_CPF AND C9V_FILIAL = T5T_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-3000"
	If nTipo == 1
		cQry :=	cChvFunc
	Else
		cQry := " INNER JOIN " + RetSqlName("C9V") + " C9V ON "
		cQry += " C9V_ID = CMJ_TRABAL AND C9V_FILIAL = CMJ_FILIAL "
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
	EndIf

Else
	If nTipo == 1
		cQry :=	" ,'Não identificada' CHVNEGOC "
	EndIf

EndIf

Return cQry

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR121Tot

Retorna a condição para os totalizadores

@Author		TOTVS
@Since		24/09/2018
@Version	12.1.17
/*/
//---------------------------------------------------------------------
Static Function TAFR121Tot(cLayout,nTipo)
Local cQry := ""

If cLayout == "S-1200"
	If nTipo == 1
		cQry += " ,CASE WHEN T2M.T2M_NRRECI = C91.C91_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTINSS "
		cQry +=	" ,'N/A' TOTIRRF "
		cQry +=	" ,'N/A' TOTCINSS "
		cQry +=	" ,'N/A' TOTCIRRF "
	Else
		cQry += "LEFT JOIN " + RetSqlName("T2M") + " T2M "
		cQry += "  ON T2M.T2M_NRRECI = C91.C91_PROTUL "
		cQry += "  AND T2M.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1210"
	If nTipo == 1
		cQry += " ,CASE WHEN T2G.T2G_RECBAS = T3P.T3P_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTIRRF "
		cQry +=	" ,'N/A' TOTINSS "
		cQry +=	" ,'N/A' TOTCINSS "
		cQry +=	" ,'N/A' TOTCIRRF "
	Else
		cQry += "LEFT JOIN " + RetSqlName("T2G") + " T2G "
		cQry += "  ON T2G.T2G_RECBAS = T3P.T3P_PROTUL "
		cQry += "  AND T2G.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1295"
	If nTipo == 1
		cQry += " ,CASE WHEN T2V.T2V_IDARQB = T72.T72_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTCINSS "

		cQry += " ,CASE WHEN T0G.T0G_NRARQB = T72.T72_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTCIRRF "

		cQry +=	" ,'N/A' TOTINSS "
		cQry +=	" ,'N/A' TOTIRRF "
	Else
		cQry += "LEFT JOIN " + RetSqlName("T2V") + " T2V "
		cQry += "  ON T2V.T2V_IDARQB = T72.T72_PROTUL "
		cQry += "  AND T2V.D_E_L_E_T_ = ' ' "

		cQry += "LEFT JOIN " + RetSqlName("T0G") + " T0G "
		cQry += "  ON T0G.T0G_NRARQB = T72.T72_PROTUL "
		cQry += "  AND T0G.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-1299"
	If nTipo == 1
		cQry += " ,CASE WHEN T2V.T2V_IDARQB = CUO.CUO_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTCINSS "

		cQry += " ,CASE WHEN T0G.T0G_NRARQB = CUO.CUO_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTCIRRF "

		cQry +=	" ,'N/A' TOTINSS "
		cQry +=	" ,'N/A' TOTIRRF "
	Else
		cQry += "LEFT JOIN " + RetSqlName("T2V") + " T2V "
		cQry += "  ON T2V.T2V_IDARQB = CUO.CUO_PROTUL "
		cQry += "  AND T2V.D_E_L_E_T_ = ' ' "

		cQry += "LEFT JOIN " + RetSqlName("T0G") + " T0G "
		cQry += "  ON T0G.T0G_NRARQB = CUO.CUO_PROTUL "
		cQry += "  AND T0G.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2299"
	If nTipo == 1
		cQry += " ,CASE WHEN T2M.T2M_NRRECI = CMD.CMD_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTINSS "
		cQry +=	" ,'N/A' TOTIRRF "
		cQry +=	" ,'N/A' TOTCINSS "
		cQry +=	" ,'N/A' TOTCIRRF "
	Else
		cQry += "LEFT JOIN " + RetSqlName("T2M") + " T2M "
		cQry += "  ON T2M.T2M_NRRECI = CMD.CMD_PROTUL "
		cQry += "  AND T2M.D_E_L_E_T_ = ' ' "
	EndIf

ElseIf cLayout == "S-2399"
	If nTipo == 1
		cQry += " ,CASE WHEN T2M.T2M_NRRECI = T92.T92_PROTUL THEN 'Sim' ELSE 'Não'"
		cQry += "  END TOTINSS "
		cQry +=	" ,'N/A' TOTIRRF "
		cQry +=	" ,'N/A' TOTCINSS "
		cQry +=	" ,'N/A' TOTCIRRF "
	Else
		cQry += "LEFT JOIN " + RetSqlName("T2M") + " T2M "
		cQry += "  ON T2M.T2M_NRRECI = T92.T92_PROTUL "
		cQry += "  AND T2M.D_E_L_E_T_ = ' ' "
	EndIf

Else
	If nTipo == 1
		cQry +=	" ,'N/A' TOTINSS "
		cQry +=	" ,'N/A' TOTIRRF "
		cQry +=	" ,'N/A' TOTCINSS "
		cQry +=	" ,'N/A' TOTCIRRF "
	EndIf

EndIf

Return cQry

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR121Dsc

Tratamento para apresentação do campo Memo (V2H_DCERRO)

Campo Memo do tipo real, não é carregado na tabela temporaria.
Caso seja feito tratamento na query usando o Convert ou Cast, havera
problema para atender as particularidades de cada banco homologado

@Author		TOTVS
@Since		10/09/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function TAFR121Dsc(cAliasQry)
Local cRet := ""

If !Empty((cAliasQry)->V2H_RECNO)
	V2H->(DBGoTo((cAliasQry)->V2H_RECNO))
	cRet += AllTrim( StrTran( V2H->V2H_DCERRO, chr(13)+chr(10)," " ) )
ElseIf !Empty((cAliasQry)->T0X_RECNO)
	T0X->(DBGoTo((cAliasQry)->T0X_RECNO))
	cRet += AllTrim( StrTran( T0X->T0X_DCERRO, chr(13)+chr(10)," " ) )
EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR121Fil

Apresenta as filiais para seleção do usuário.

@Author		TOTVS
@Since		10/09/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function TAFR121Fil(aFilSel, aRetParam)
Local lRet 			:= .T.

                     //lMostratela   ,aListaFil ,lChkUser ,lSped ,lEmpr ,lContEmp ,lCancSel ,lBaseCNPJ)
aFilSel := xFunTelaFil( cValToChar(aRetParam[FILIAL]) == "1" , Nil       ,.T.      ,.F.   ,.F.   ,.F.      ,         ,.T.      )

If Empty(aFilSel) .Or. AScan(aFilSel,{|x| x[1]}) == 0
	lRet := .F.
	Help("Filial não selecionada ou o usuário não possui permissão de acesso.")
EndIf

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFR121Evt
Funcao para selecao dos eventos

@author TOTVS
@since 05/09/2018	
@version 12.1.17
/*/
//--------------------------------------------------------------------------------
Static Function TAFR121Evt(oTabEvtSel, cAliasTmp, cIndex1, cIndex2, aRetParam)

	Local oDlg			:= Nil
	Local aCampos		:= {}
	Local aSeek			:= {}
	Local aEvtEsocial	:= TAFRotinas(,,.T.,2)
	Local nEvento		:= 0
	Local cDscEvento	:= ""
	Local lRet			:= .T.
	Local oMrkBrowse	:= Nil
	Local lSelEvento	:= cValToChar(aRetParam[EVENT]) == "1"
	Local cMarca		:= If(lSelEvento,"  ",GetMark())
	Local cTipoEvt		:= ""

	Default cAliasTmp	:= ""

	//-------------------------------------------
	// Estrutura dos campos da tabela temporaria
	//-------------------------------------------
	AAdd(aCampos,{"MARK"  ,"C",002,0})
	AAdd(aCampos,{"EVENTO","C",006,0})
	AAdd(aCampos,{"DESCRI","C",220,0})
	AAdd(aCampos,{"ALIAS" ,"C",005,0})
	AAdd(aCampos,{"TIPO"  ,"C",001,0})
	AAdd(aCampos,{"CPODAT","C",010,0})

	cTipoEvt := SubStr(aRetParam[TIPOEVENTO], 1, 1)

	//----------------------------------------------------------------------
	// Se o alias estiver aberto, fechar para evitar erros com alias aberto
	//----------------------------------------------------------------------
	If lVersaoFwt .And. oTabEvtSel <> Nil
		oTabEvtSel:Delete()
	EndIf

	//------------------------------
	// Criação da tabela temporaria
	//------------------------------

	cAliasTmp  := GetNextAlias()
	oTabEvtSel := FwTemporaryTable():New(cAliasTmp)
	oTabEvtSel:SetFields(aCampos)
	oTabEvtSel:AddIndex("1",{"EVENTO"})
	oTabEvtSel:AddIndex("2",{"DESCRI"})
	oTabEvtSel:Create()

	//-------------------------------------------------------
	// Alimenta a tabela temporária com os dados dos eventos
	//-------------------------------------------------------
	For nEvento := 1 To Len(aEvtEsocial)

		If !Empty(aEvtEsocial[nEvento][04])					.And.;	//Desconsidera evento em branco
			AllTrim(aEvtEsocial[nEvento][04]) != "TAUTO"	.And.;	//Desconsidera TAUTO
			aEvtEsocial[nEvento][12] $ "C|M|E"						//Carrega somente eventos Iniciais, Mensais e Eventuais

			If aEvtEsocial[nEvento][12] == cTipoEvt

				//---------------------------------
				// Obtem a descrição na tabela C8E
				//---------------------------------
				cDscEvento := GetAdvFVal("C8E","C8E_DESCRI",XFilial("C8E")+aEvtEsocial[nEvento][04],2,"") //C8E_FILIAL+C8E_CODIGO+DTOS(C8E_VALIDA)

				If RecLock(cAliasTmp,.T.)
					(cAliasTmp)->MARK	:= cMarca
					(cAliasTmp)->EVENTO	:= aEvtEsocial[nEvento][04]	//Código do evento
					(cAliasTmp)->DESCRI	:= cDscEvento				//Descrição do evento
					(cAliasTmp)->ALIAS	:= aEvtEsocial[nEvento][03]	//Alias do Evento
					(cAliasTmp)->TIPO	:= aEvtEsocial[nEvento][12]	//Tipo do Evento (I-Inicial,M-Mensal,E-Eventual,C-Carga,T-Totalizador)
					(cAliasTmp)->CPODAT	:= aEvtEsocial[nEvento][06]	//Campo que determina o periodo ou data do evento
					(cAliasTmp)->(MsUnLock())
				EndIf
			
			EndIf

		EndIf

	Next nEvento

	If lSelEvento

		//-----------------------------------------------------------
		// Montagem de janela para apresentar a mark no estilo popup
		//-----------------------------------------------------------
		DEFINE MSDIALOG oDlg TITLE "Eventos" From 0,0 To 600,800 OF oMainWnd PIXEL

		//-------------------------------
		// Define as pesquisas do browse
		//-------------------------------
					//Título da pesquisa ,LookUp        ,Tipo de dados ,Tamanho ,Decimal ,Título do campo ,Máscara
		AAdd(aSeek,{"Evento"           ,{{"Evento"    ,"C"           ,006     ,0       ,"Evento"        ,"@!"}} } )
		If lVersaoFwt
						//Título da pesquisa ,LookUp        ,Tipo de dados ,Tamanho ,Decimal ,Título do campo ,Máscara
			AAdd(aSeek,{"Descrição"        ,{{"Descrição" ,"C"           ,220     ,0       ,"Descrição"     ,"@!"}} } )
		EndIf

		//----------------------------------------------
		// Instancia o objeto com a classe FWMarkBrowse
		//----------------------------------------------
		oMrkBrowse := FWMarkBrowse():New()

		//------------------------------------------------------------------
		// Define a tela de apresentacao da mark, para nao ocupar toda tela
		//------------------------------------------------------------------
		oMrkBrowse:SetOwner(oDlg)

		//------------------
		// Titulo da Janela
		//------------------
		oMrkBrowse:SetDescription("Seleção de Eventos")

		//-----------------------------------
		// Indica o alias que será utilizado
		//-----------------------------------
		oMrkBrowse:SetAlias(cAliasTmp)

		//------------------------------------------------------------------
		// Indica o campo que deverá ser atualizado com a marca no registro
		//------------------------------------------------------------------
		oMrkBrowse:SetFieldMark("MARK")

		//-------------------------------------------------------------------------------
		// Indica o Code-Block executado no clique do header da coluna de marca/desmarca
		//-------------------------------------------------------------------------------
		oMrkBrowse:SetAllMark( { || MarkAll( oMrkBrowse ) } )

		//--------------------------------
		// Remove o botão Imprimir Browse
		//--------------------------------
		oMrkBrowse:DisableReport()

		//---------------------------------------------------------------
		// Remove o botão Filtro, pois não funciona em tabela temporaria
		//---------------------------------------------------------------
		oMrkBrowse:DisableFilter()

		//-----------------------------------------------
		// Indica que o Browse utiliza tabela temporária
		//-----------------------------------------------
		oMrkBrowse:SetTemporary(.T.)

		//----------------------------------------------------------
		// Habilita a utilização da pesquisa de registros no Browse
		//----------------------------------------------------------
		oMrkBrowse:oBrowse:SetSeek(.T.,aSeek)

		//-------------------------------------------------------------------------------------------------------------
		// Ignorar a variavel private aRotina na construção da markbrowse, pois haverá somente um Confirmar e Cancelar
		//-------------------------------------------------------------------------------------------------------------
		oMrkBrowse:SetIgnoreARotina(.T.)

		//-----------------------------
		// Define as colunas do Browse
		//-----------------------------
							//cTitulo     ,bData       ,cTipo ,cPicture ,nAlign ,nSize ,nDecimal ,lEdit ,bValid  ,lImage ,bDoubleClick ,cEditVar ,bHeaderClick ,lDel ,lDetail
		oMrkBrowse:SetColumns({{"Evento"    ,{|| EVENTO} ,"C"   ,"@!"     ,1      ,006   ,0        ,.F.   ,{||.T.} ,.F.	   ,{||.T.}      ,NIL      ,{||.T.}      ,.F.  ,.F.    }})
		oMrkBrowse:SetColumns({{"Descrição" ,{|| DESCRI} ,"C"   ,"@!"     ,1      ,220   ,0        ,.F.   ,{||.T.} ,.F.	   ,{||.T.}      ,NIL      ,{||.T.}      ,.F.  ,.F.    }})

		//---------------------------
		// Adiciona botoes na janela
		//---------------------------
						//cTitle      ,xAction                         ,uParam1 ,nOption
		oMrkBrowse:AddButton("Confirmar" ,{|| lRet := .T. ,NoMark( oMrkBrowse ),CloseBrowse()} ,        ,1      )
	
		oMrkBrowse:AddButton("Cancelar"  ,{|| lRet := .F. ,CloseBrowse()} ,        ,1      )

		//--------------
		// Ativa a tela
		//--------------
		oMrkBrowse:Activate()

		ACTIVATE MSDIALOg oDlg CENTERED

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll

Inverte a indicação de seleção de todos registros da MarkBrowse.

@Param		oMrkBrowse -	MarkBrowse com as informações	

@Return		Nil

@Author		Felipe C. Seolin
@Since		04/09/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MarkAll( oMrkBrowse )
Local cAlias	:= oMrkBrowse:Alias()
Local cMark		:= oMrkBrowse:Mark()
Local nRecno	:= (cAlias)->(Recno())

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. )
		( cAlias )->MARK := Iif( ( cAlias )->MARK == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf

	( cAlias)->( DBSkip() )
EndDo

( cAlias )->( DBGoto( nRecno ) )

oMrkBrowse:Refresh()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} NoMark

Verifica se não foi selecionado nenhum registro e caso sim,
inverte a indicação de seleção de todos registros da MarkBrowse.

@Param		oMrkBrowse -	MarkBrowse com as informações	

@Return		Nil

@Author		Ricardo L. 
@Since		29/05/2020
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function NoMark( oMrkBrowse )
Local cAlias	:= oMrkBrowse:Alias()
Local cMark		:= oMrkBrowse:Mark()
Local nRecno	:= (cAlias)->(Recno())
Local lMark		:= .F.

( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() ) 

	If ( cAlias )->MARK == cMark
		lMark := .T.
	EndIf
	( cAlias)->( DBSkip() )

EndDo

If !lMark
	MarkAll( oMrkBrowse ) 
EndIf

( cAlias )->( DBGoto( nRecno ) )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro dos Santos Oliveira
@since  07/04/2015
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()
Local aParam := {}

aParam := {	"R"			,;	//Tipo R para relatorio P para processo
			"TAFR121"	,;	//Pergunte do relatorio, caso nao use passar ParamDef
			Nil			,;	//cAlias (para Relatorio)
			Nil			,;	//aArray (para Relatorio)
			Nil			}	//Titulo (para Relatorio)

Return( aParam )

//--------------------------------------------------------------------
/*/{Protheus.doc} T121P11Fil

Retorna as filias selecionadas na tela e filtro

@Param	cAliasTab -> Alias do evento
@Return cQryParam -> String com as filiais para uso na query

@Author	Evandro dos Santos Oliveira
@Since	27/06/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function T121P11Fil(cAliasLay, oTabFilSel, aFilSel)

	Local aQryParam	:= {}
	Local cQryParam := ""
	Local cCachFil	:= ""
	Local nY 		:= 0
	
  	For nY := 1 To Len(aFilSel)

  		If aFilSel[nY][1]
			
	  		If cAliasLay == 'C1E'

				AAdd(aQryParam, aFilSel[nY][2])

			Else

				AAdd(aQryParam, xFilial(cAliasLay, aFilSel[nY][2]))

			EndIf

  		EndIf

  	Next

	cCachFil	:= TAFCacheFil(cAliasLay, aQryParam, .T.)
	cQryParam 	:= " ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) " 

Return cQryParam

//--------------------------------------------------------------------
/*/{Protheus.doc} ConvParam

Retorna as filias selecionadas na tela e filtro

@Author	Victor A. Barbosa
@Since	06/06/2019

@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ConvParam(xValue)

If ValType(xValue) == "C"

EndIf

Return
