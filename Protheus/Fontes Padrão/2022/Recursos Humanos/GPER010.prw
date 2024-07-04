#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'GPER010.CH'

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: GPER010.PRW Autor: PHILIPE.POMPEU Data:31/07/2015               ***
***********************************************************************************
***Descrição..: Relatório de Beneficios por Entidade                            ***
***********************************************************************************
***Uso........:                                                                 ***
***********************************************************************************
***Parâmetros.:                                                                 ***
***********************************************************************************
***Retorno....: Nil - Valor Nulo                                                ***
***********************************************************************************
***                ALTERAÇÕES FEITAS DESDE A CONSTRUÇÃO INICIAL                 ***
***********************************************************************************
***Chamado....:                                                                 ***
***********************************************************************************
±±³Victor A.   ³18/07/2016³ TVJBTN ³ Adicionado validação para barrar a impressão**
±±³            ³          ³        ³ caso a entidade não esteja preenchida.      **
***********************************************************************************/

/*/{Protheus.doc} GPER010
	Realiza a impressão do Relatório de Benefícios p/ Entidade
@author PHILIPE.POMPEU
@since 04/05/2015
@version P12
@return Nil, Valor Nulo
/*/
Function GPER010()
	Local	aArea 	:= GetArea()
	Local	oReport:= Nil
	
	oReport := GetReport()
	
	if(oReport <> Nil)
		oReport:PrintDialog()
	endIf
	
	oReport := Nil
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} GetReport
	Retorna um objeto TReport com seções pré-definidas;
@author PHILIPE.POMPEU
@since 04/05/2015
@version P12
@return oReport, Instância da Classe TReport
/*/
Static Function GetReport()
	Local oReport	:= Nil
	Local oSecFil	:= Nil
	Local oSecCab		:= Nil
	Local oSecItems	:= Nil
	
	Local cRptTitle	:= OemToAnsi(STR0001)
	Local cRptDescr	:= OemToAnsi(STR0002)
	Local aOrderBy	:= {}
	Local cNomePerg	:=	"GPR010"
	
	aAdd(aOrderBy,OemToAnsi(STR0003))
	
	Pergunte(cNomePerg,.F.)
	
	DEFINE REPORT oReport NAME 'GPER010' TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg)} DESCRIPTION cRptDescr
	 	
	DEFINE SECTION oSecFil	OF oReport TITLE cRptTitle	TABLES "SLY" ORDERS aOrderBy
		DEFINE CELL NAME "LY_FILIAL" 	OF 	oSecFil ALIAS "SLY"
		
	DEFINE SECTION oSecCab	OF oSecFil TITLE '' 			TABLES "SLY"		
		DEFINE CELL NAME "LY_ALIAS" 	OF 	oSecCab ALIAS "SLY"
		DEFINE CELL NAME "LY_CHVENT" 	OF 	oSecCab ALIAS "SLY"
		DEFINE CELL NAME "ENTDESCR" 	OF 	oSecCab Title OemToAnsi(STR0004) SIZE 50	
	
	DEFINE SECTION oSecItems	OF oSecCab TITLE '' 			TABLES "SLY"		
		DEFINE CELL NAME "LY_TIPO"		OF 	oSecItems ALIAS "SLY" SIZE 10
		DEFINE CELL NAME "LY_CODIGO"	OF 	oSecItems ALIAS "SLY" SIZE 10
		DEFINE CELL NAME "DESCRICAO"	OF 	oSecItems Title OemToAnsi(STR0018)
		DEFINE CELL NAME "LY_DTINI" 	OF 	oSecItems ALIAS "SLY" 
		DEFINE CELL NAME "LY_DTFIM" 	OF 	oSecItems ALIAS "SLY"
				
		DEFINE CELL NAME "VALOR" 	OF 	oSecItems Title OemToAnsi(STR0008) SIZE 16 PICTURE "@E 999,999,999,999.99"
		DEFINE CELL NAME "VALOREMP"	OF 	oSecItems Title OemToAnsi(STR0009) SIZE 16 PICTURE "@E 999,999,999,999.99"
		DEFINE CELL NAME "VALORFUNC"OF 	oSecItems Title OemToAnsi(STR0011) SIZE 16 PICTURE "@E 999,999,999,999.99"	

Return oReport

/*/{Protheus.doc} PrintReport
	Realiza a impressão do objeto oReport recebido via parâmetro;
	Objeto oReport deve ter certas caracteristicas pré-definidas;
@author PHILIPE.POMPEU
@since 04/05/2015
@version P12
@param oReport, objeto, Instância da Classe TReport
@param cNomePerg, caractere, Nome do Grupo de Perguntas do dicionário de dados
@return Nil, Valor Nulo
/*/
Static Function PrintReport(oReport,cNomePerg)
	Local oSecFil		:= oReport:Section(1)
	Local oSecCab		:= oSecFil:Section(1)
	Local oSecItems	:= oSecCab:Section(1)
	Local oBreakItems	:= Nil
	Local oBreakFil	:= Nil
	Local oBreakUni	:= Nil
	Local oBreakEmp	:= Nil
	Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
	Local cLayoutGC 	:= ''
	Local nStartEmp	:= 0
	Local nStartUnN	:= 0
	Local nEmpLength	:= 0
	Local nUnNLength	:= 0	
	Local cMyAlias	:= GetNextAlias()
	Local cQuery		:= ''
	Local cDefault	:= ''
	Local aConsultas	:= {}	
	Local cTitFil		:= ''
	Local cTitUniNeg	:= ''
	Local cTitEmp		:= ''
	Local cTitCab		:= ''
	Local cTitItems	:= ''
	Local cCampo		:= ''
	Local cEntidade	:= Upper(AllTrim(MV_PAR02))	
	Local cFunJoin	:= ''	
	Local bOnPrintLn	:= {||oSecCab:Cell("ENTDESCR"):SetValue(BranchName((cMyAlias)->LY_CHVENT))}	
	Local cCateg 		:= ''
	Local cSitua 		:= ''
	Local cWhere 		:= ''	
	Local cWhereRG2		:= ''
	Local lVrVa		:= IIF(((MV_PAR05== 1).OR.(MV_PAR06== 1)),.T.,.F.)
	Local aVrVa		:= {}
	Local aPeriodos	:= {}
	Local lPlano		:= IIF(MV_PAR07== 1,.T.,.F.)	
	Local lOutros		:= IIF(MV_PAR10== 1,.T.,.F.)
	Local lTemAberto	:= .F.
	Local lTemFechado	:= .F.
	Local cJoinBen	:=''
	Local aIntervalo	:= GetInterval(MV_PAR03,MV_PAR04,MV_PAR01)
	Local aTpPlanos	:= {'1'} //1=Titular;2=Dependente;3=Agregado
	
	// Se a entidade não tiver preenchida, barra a impressão do relatório.
	If Empty(MV_PAR02)
		MsgAlert(STR0020 + Chr(10) + Chr(13) + STR0021, STR0022)
		Return
	EndIf
	
	if(lVrVa .Or. lPlano .Or. lOutros)	
		oSecItems:Cell("VALOR"):Disable();		
		
		cCampo		:= EntityField(cEntidade)
		cFunJoin	:= EntityJoin(cEntidade) + GetFuncJoin(cEntidade)
				
		if(cEntidade == 'SM0')
			oSecCab:OnPrintLine(bOnPrintLn)	
		endIf		
				
		cCateg := BreakOpt(MV_PAR11)		
		if!(Empty(cCateg))
			cWhere+=' AND RA_CATFUNC IN('+ cCateg +') '
		endIf	
		
		cSitua := BreakOpt(MV_PAR12)
		if!(Empty(cSitua))			
			cWhere+=' AND RA_SITFOLH IN('+ cSitua +') '				
		endIf
		
		if!(Empty(cWhere))			
			cEntidade :="'"+cEntidade+"'"
			cWhere := cEntidade +' '+ cWhere 
		Else
			cEntidade :="'"+cEntidade+"'"
			cWhere := cEntidade
		endIf		
		
		cDefault := "SELECT LY_FILIAL,LY_ALIAS,LY_CHVENT,"+ cCampo + " AS ENTDESCR,LY_TIPO,LY_CODIGO,@DESCRICAO@ AS DESCRICAO,LY_DTINI,LY_DTFIM,@ORIGEM@ AS ORIGEM,@TABELA@ AS TABELA,"
		cDefault += "SUM(@VALOR@) AS VALOR,SUM(@VLREMP@) AS VALOREMP,SUM(@VLRFUN@) AS VALORFUNC " 
		cDefault += " FROM "+ RetSqlName('SLY') + " SLY "
		cDefault += " @JOIN_ENTIDADE@"
		cDefault += " @JOIN_BENEFICIO@"
		cDefault += " WHERE"
		cDefault += " LY_FILIAL = '"+ FWxFilial('SLY')+"'"
		cDefault += " AND"
		cDefault += " SLY.D_E_L_E_T_ = ''"		
		
		if(Len(aIntervalo) == 2)				
			cDefault += " AND"			
			cDefault += " LY_DTINI >='"+ aIntervalo[1] +"' and LY_DTFIM <= '"+  aIntervalo[2]  +"'"
		endIf
		
		cDefault += " AND"
		cDefault += " LY_ALIAS ="+ cWhere		
		
		if(cCampo == "'VAZIO'" .OR. cCampo == "''")
			cDefault += " GROUP BY LY_FILIAL,LY_ALIAS,LY_CHVENT,LY_TIPO,LY_CODIGO,@DESCRICAO@,LY_DTINI,LY_DTFIM "
		Else		
			cDefault += " GROUP BY LY_FILIAL,LY_ALIAS,LY_CHVENT,"+ cCampo +",LY_TIPO,LY_CODIGO,@DESCRICAO@,LY_DTINI,LY_DTFIM "
		endIf
				
		if(lVrVa)
			
			if(MV_PAR05== 1)
				aAdd(aVrVa,'D')//VR
			endIf			
			if(MV_PAR06== 1)
				aAdd(aVrVa,'E')//VA
			endIf			
			
			aPeriodos := GetPeriods(SubStr(aIntervalo[1],1,6),SubStr(aIntervalo[2],1,6),aVrVa)
			
			lTemAberto := (aScan(aPeriodos,{|x|(x[2])}) > 0 )
			lTemFechado:= (aScan(aPeriodos,{|x|(!x[2])}) > 0 )
			
			if(lTemAberto)				
				aAdd(aConsultas,cDefault)			
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@ORIGEM@'	, "'VRVA'")
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@TABELA@'	, "'VRVA'")
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@VALOR@'	, 'R0_VALCAL')
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLREMP@'	, 'R0_VLREMP')
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLRFUN@'	, 'R0_VLRFUNC')
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@DESCRICAO@'		, 'RFO.RFO_DESCR')						
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_ENTIDADE@'	, cFunJoin)			 
				
				cJoinBen:=" INNER JOIN "+RetSqlName('SR0')+" SR0 ON (R0_FILIAL ='" + FwxFilial('SR0') +"' "
				cJoinBen+=" AND R0_CODIGO = LY_CODIGO AND SR0.D_E_L_E_T_ = SLY.D_E_L_E_T_ AND "+ GetVrVAJoin((MV_PAR05 == 1),(MV_PAR06 == 1)) +" AND R0_MAT=SRA.RA_MAT)"
				cJoinBen+=" INNER JOIN "+RetSqlName('RFO')+" RFO ON (RFO_FILIAL ='" + FwxFilial('RFO') +"' "
				cJoinBen+=" AND RFO_CODIGO = LY_CODIGO AND RFO.D_E_L_E_T_ = SLY.D_E_L_E_T_ AND "+ GetVrVAJoin((MV_PAR05 == 1),(MV_PAR06 == 1),'RFO_TPVALE') +")"
	
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_BENEFICIO@'	, cJoinBen)
			endIf
			
			if(lTemFechado)			
				aAdd(aConsultas,cDefault)
				aTail(aConsultas):= StrTran(aTail(aConsultasadmi), '@ORIGEM@'	, "'VRVA'")
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@TABELA@'	, "'VRVA'")			
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@VALOR@'	, 'RG2_VALCAL')
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLREMP@'	, 'RG2_CUSEMP')
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLRFUN@'	, 'RG2_CUSFUN')
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@DESCRICAO@'	, 'RFO.RFO_DESCR')						
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_ENTIDADE@'	, cFunJoin)			 
				
				cJoinBen:=" INNER JOIN "+RetSqlName('RG2')+" RG2 ON (RG2_FILIAL ='" + FwxFilial('RG2') +"' "
				cJoinBen+=" AND RG2_CODIGO = LY_CODIGO AND RG2.D_E_L_E_T_ = SLY.D_E_L_E_T_ AND "	
				
				cWhereRG2 :=  GetWhere('RG2_PERIOD',aPeriodos)				
				If !Empty(cWhereRG2)
					cJoinBen+= cWhereRG2 + ' AND '
				EndIf
				
				cJoinBen+= GetVrVAJoin((MV_PAR05 == 1),(MV_PAR06 == 1),'RG2_TPVALE') +"  AND RG2_MAT=SRA.RA_MAT)"
				
				cJoinBen+=" INNER JOIN "+RetSqlName('RFO')+" RFO ON (RFO_FILIAL ='" + FwxFilial('RFO') +"' "
				cJoinBen+=" AND RFO_CODIGO = LY_CODIGO AND RFO.D_E_L_E_T_ = SLY.D_E_L_E_T_ AND "+ GetVrVAJoin((MV_PAR05 == 1),(MV_PAR06 == 1),'RFO_TPVALE') +")"
				
				aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_BENEFICIO@'	, cJoinBen)			
			endIf			
						
		endIf
		
		if(lOutros)
			aAdd(aConsultas,cDefault)			
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@ORIGEM@'	, "'OUTR'")
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@TABELA@'	, "'OUTR'")
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VALOR@'	, 'RIR_VALCAL')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLREMP@'	, 'RIR_VLREMP')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLRFUN@'	, 'RIR_VLRFUN')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@DESCRICAO@'		, 'RIS.RIS_DESC')						
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_ENTIDADE@'	, cFunJoin)							
				
			
			cJoinBen:=" INNER JOIN "+ RetSqlName('RIR')+" RIR ON (RIR_FILIAL ='"+ FwxFilial('RIR')+"'"
			cJoinBen+=" AND LY_TIPO = RIR_TPBENE AND RIR_COD = LY_CODIGO AND RIR.D_E_L_E_T_ = SLY.D_E_L_E_T_ AND "
			cJoinBen+=" RIR_PERIOD >='"+ SubStr(aIntervalo[1],1,6) +"' AND RIR_PERIOD <='"+ SubStr(aIntervalo[2],1,6) +"' AND RIR_MAT = SRA.RA_MAT)"
			  
			cJoinBen+=" INNER JOIN "+ RetSqlName('RIS')+" RIS ON (RIS_FILIAL ='"+ FwxFilial('RIS')+"'"
			cJoinBen+=" AND LY_TIPO = RIS_TPBENE AND RIS_COD = LY_CODIGO AND RIS.D_E_L_E_T_ = SLY.D_E_L_E_T_)"
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_BENEFICIO@'	, cJoinBen)
			
			aAdd(aConsultas,cDefault)			
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@ORIGEM@'	, "'OUTR'")
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@TABELA@'	, "'OUTR'")
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VALOR@'	, 'RIQ_VALCAL')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLREMP@'	, 'RIQ_VLREMP')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLRFUN@'	, 'RIQ_VLRFUN')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@DESCRICAO@'		, 'RIS.RIS_DESC')						
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_ENTIDADE@'	, cFunJoin)							
				
			
			cJoinBen:=" INNER JOIN "+ RetSqlName('RIQ')+" RIQ ON (RIQ_FILIAL ='"+ FwxFilial('RIQ')+"'"
			cJoinBen+=" AND LY_TIPO = RIQ_TPBENE AND RIQ_COD = LY_CODIGO AND RIQ.D_E_L_E_T_ = SLY.D_E_L_E_T_ AND RIQ_MAT=SRA.RA_MAT)"
			  
			cJoinBen+=" INNER JOIN "+ RetSqlName('RIS')+" RIS ON (RIS_FILIAL ='"+ FwxFilial('RIS')+"'"
			cJoinBen+=" AND LY_TIPO = RIS_TPBENE AND RIS_COD = LY_CODIGO AND RIS.D_E_L_E_T_ = SLY.D_E_L_E_T_)"
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_BENEFICIO@'	, cJoinBen)			
		endIf		
		
		
		if(lPlano)
			aAdd(aConsultas,cDefault)			
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@ORIGEM@'	, 'RHR_ORIGEM')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@TABELA@'	, "'PLAN'")
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VALOR@'	, '0')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLREMP@'	, 'RHR_VLREMP')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLRFUN@'	, 'RHR_VLRFUN')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@DESCRICAO@'		, "G0_DESCR")						
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_ENTIDADE@'	, cFunJoin)			
			
			cJoinBen:=" INNER JOIN "+ RetSqlName('SG0')+" SG0 ON (G0_FILIAL ='"+ FwxFilial('SG0')+"'"
			cJoinBen+=" AND LY_TIPO = 'PS' AND G0_CODIGO = LY_CODIGO AND SG0.D_E_L_E_T_ = SLY.D_E_L_E_T_)"
			
			cJoinBen+=" INNER JOIN "+ RetSqlName('SJX')+" SJX ON (JX_FILIAL ='"+ FwxFilial('SJX')+"'"
			cJoinBen+=" AND JX_CODIGO = G0_CODIGO AND SJX.D_E_L_E_T_ = SG0.D_E_L_E_T_)"
			
			
			if(MV_PAR08 == 1)
				//Dependentes
				aAdd(aTpPlanos,'2')										
			endIf		
			if(MV_PAR09 == 1)
				//Agregados
				aAdd(aTpPlanos,'3')						
			endIf		
			
			
			cJoinBen+=" INNER JOIN "+ RetSqlName('RHR')+" RHR ON (RHR_FILIAL ='"+ FwxFilial('RHR')+"' AND "+TpPlano(aTpPlanos)
			cJoinBen+=" AND RHR_CODFOR = JX_CODFORN AND RHR_TPPLAN = JX_TPPLANO AND RHR_PLANO = JX_PLANO AND RHR_PD = JX_PD AND RHR.D_E_L_E_T_ = '' AND RHR_MAT=SRA.RA_MAT)"
			
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_BENEFICIO@'	, cJoinBen)
			aTail(aConsultas)+=',RHR_ORIGEM'
			
			//
			aAdd(aConsultas,cDefault)			
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@ORIGEM@'	, 'RHS_ORIGEM')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@TABELA@'	, "'PLAN'")
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VALOR@'	, '0')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLREMP@'	, 'RHS_VLREMP')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@VLRFUN@'	, 'RHS_VLRFUN')
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@DESCRICAO@'		, "G0_DESCR")						
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_ENTIDADE@'	, cFunJoin)			
			
			cJoinBen:=" INNER JOIN "+ RetSqlName('SG0')+" SG0 ON (G0_FILIAL ='"+ FwxFilial('SG0')+"'"
			cJoinBen+=" AND LY_TIPO = 'PS' AND G0_CODIGO = LY_CODIGO AND SG0.D_E_L_E_T_ = SLY.D_E_L_E_T_)"
			
			cJoinBen+=" INNER JOIN "+ RetSqlName('SJX')+" SJX ON (JX_FILIAL ='"+ FwxFilial('SJX')+"'"
			cJoinBen+=" AND JX_CODIGO = G0_CODIGO AND SJX.D_E_L_E_T_ = SG0.D_E_L_E_T_)"
			
			cJoinBen+=" INNER JOIN "+ RetSqlName('RHS')+" RHS ON (RHS_FILIAL ='"+ FwxFilial('RHS')+"' AND "+ TpPlano(aTpPlanos,'RHS_ORIGEM')
			cJoinBen+=" AND RHS_CODFOR = JX_CODFORN AND RHS_TPPLAN = JX_TPPLANO AND RHS_PLANO = JX_PLANO AND RHS_PD = JX_PD AND RHS.D_E_L_E_T_ = '' AND RHS_MAT=SRA.RA_MAT)"
			
			aTail(aConsultas):= StrTran(aTail(aConsultas), '@JOIN_BENEFICIO@'	, cJoinBen)
			aTail(aConsultas)+=',RHS_ORIGEM'
		endIf
		
		if(Len(aConsultas) > 0 )			
			cQuery := GetUnion(aConsultas)
			cQuery := '%'+cQuery+'%'
		Else
			Help(,,'HELP',,OemToAnsi(STR0019),1,0 )
			Return (.F.)		
		endIf		
		
		BEGIN REPORT QUERY oSecFil
			BeginSql alias cMyAlias	
				SELECT  LY_FILIAL,LY_ALIAS,LY_CHVENT,ENTDESCR,LY_TIPO,LY_CODIGO,DESCRICAO,LY_DTINI,LY_DTFIM,
				ORIGEM,TABELA,SUM(VALOR) AS VALOR,SUM(VALOREMP) AS VALOREMP,SUM(VALORFUNC) AS VALORFUNC
				FROM ( 
				%exp:cQuery%
				) RESULTADO
				GROUP BY LY_FILIAL,LY_ALIAS,LY_CHVENT,ENTDESCR,LY_TIPO,LY_CODIGO,ORIGEM,TABELA,
				DESCRICAO,LY_DTINI,LY_DTFIM
				ORDER BY LY_FILIAL,LY_ALIAS,LY_CHVENT,LY_TIPO,LY_CODIGO
			EndSql
		END REPORT QUERY oSecFil
		
		oSecCab:SetParentQuery()
		oSecCab:SetParentFilter({|cParam|(cMyAlias)->LY_FILIAL == cParam},{||(cMyAlias)->LY_FILIAL})
		
		DEFINE BREAK oBreakItems OF oReport WHEN {|| ((cMyAlias)->LY_FILIAL + (cMyAlias)->LY_ALIAS)}
		oBreakItems:SetTotalInLine(.T.)			
		
		oSecItems:SetParentQuery()
		oSecItems:SetParentFilter({|cParam| ((cMyAlias)->LY_FILIAL + (cMyAlias)->LY_ALIAS + (cMyAlias)->LY_CHVENT) == cParam},{|| ((cMyAlias)->LY_FILIAL + (cMyAlias)->LY_ALIAS + (cMyAlias)->LY_CHVENT) })		
				
		
		if(lCorpManage)		
			cLayoutGC 	:= FWSM0Layout(cEmpAnt)
			nStartEmp	:= At("E",cLayoutGC)
			nStartUnN	:= At("U",cLayoutGC)
			nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
			nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))
			
			//QUEBRA FILIAL
			DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->LY_FILIAL }		
			oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
			oBreakFil:SetTotalText({||cTitFil})
			oBreakFil:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("LY_CHVENT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT		
			
			//QUEBRA UNIDADE DE NEGÓCIO
			DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->LY_FILIAL, nStartUnN, nUnNLength) }		
			oBreakUni:OnBreak({|x|cTitUniNeg := OemToAnsi(STR0006) +" " + x, oReport:ThinLine()})
			oBreakUni:SetTotalText({||cTitUniNeg})
			oBreakUni:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("LY_CHVENT")  FUNCTION COUNT	BREAK oBreakUni NO END SECTION NO END REPORT
			
			//QUEBRA EMPRESA
			DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->LY_FILIAL, nStartEmp, nEmpLength) }		
			oBreakEmp:OnBreak({|x|cTitEmp := OemToAnsi(STR0007) + " " + x, oReport:ThinLine()})
			oBreakEmp:SetTotalText({||cTitEmp})
			oBreakEmp:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("LY_CHVENT")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT			
		Else
			//QUEBRA FILIAL
			DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->LY_FILIAL}		
			oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0005) +" " + x, oReport:ThinLine()})
			oBreakFil:SetTotalText({||cTitFil})
			oBreakFil:SetTotalInLine(.T.)			
			DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("LY_CHVENT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT	
		endIf
		
		oSecFil:Print()
	Else
		Help(,,'HELP',,OemToAnsi(STR0015),1,0 )
	endIf		
Return Nil

/*/{Protheus.doc} fEntidade
	Lista as Entidades vinculados à cCriteiro
@author PHILIPE.POMPEU
@since 04/05/2015
@version P12
@param cCriterio, caractere, critério do qual as entidades devem ser listadas
@param lSoUma, lógico, se verdadeiro só deixa escolher 1 por vez
@return Logico, verdadeiro se executado com sucesso
/*/
Function fEntidade(cCriterio,lSoUma)
	Local	aArea 	:= GetArea()
	Local	cMyAlias 	:= GetNextAlias()	
	Local	cTemp	:= ''
	Local	aOptions := {}
	Local	aResult := {}
	Local	cResult := ''
	Local	nI := 0
	Local uParam
	Default lSoUma := .T. 
	
	if(Empty(cCriterio))		
		if !(Type("MV_PAR01") == "U" )
			cCriterio := MV_PAR01 	
		endIf		
	endIf
	
	BeginSql alias cMyAlias
		SELECT JS_TABELA 
		FROM %table:SJS%
		WHERE
		JS_FILIAL = %xFilial:SJS%
		AND
		%notDel%
		AND
		JS_CDAGRUP = %exp:cCriterio%
		ORDER BY JS_FILIAL,JS_CDAGRUP,JS_SEQ
	EndSql
	
	while ( (cMyAlias)->(!Eof()) )
	
		if((cMyAlias)->JS_TABELA <> 'SRA')			
			cTemp := GetEntName((cMyAlias)->JS_TABELA)
			
			if !(Empty(cTemp))			
				aAdd(aOptions,cTemp)
			endIf
		endIf
											
		(cMyAlias)->(dbSkip())
	End				
	(cMyAlias)->( dbCloseArea() )
	
	if(f_Opcoes(@aResult,OemToAnsi(STR0010),aOptions,,,,lSoUma,0,100,,,,,,.T.))
				
		for nI:= 1 to Len(aResult)
		
			cTemp := GetEntCode(aResult[nI])
			
			if !(Empty(cTemp))			
				
				cResult += cTemp
			endIf			
			if(nI < Len(aResult))
				cResult+=','
			endIf
						
		next nI		
	endIf 

	uParam := Alltrim(ReadVar())
			
	&uParam:= cResult
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} GetEntName
 Retorna o Alias da Entidade
@author PHILIPE.POMPEU
@since 04/05/2015
@version P12
@param cCode, caractere, Alias da Entidade
@return cResult, Descrição da Entidade
@example
	cDescript := GetEntName("SRA")
	cDescript => "Funcionários"
/*/
Static Function GetEntName(cCode)
	Local	nPos := 0
	Local	cResult := ''
	Local	aNomes	:= GetEntList()
		
	nPos := aScan(aNomes,{|x|x[1]== cCode})
	if(nPos > 0)
		cResult := aNomes[nPos,2]
	endIf
	
	aNomes := {}	
Return cResult

/*/{Protheus.doc} GetEntCode
 Retorna o Alias da Entidade
@author PHILIPE.POMPEU
@since 04/05/2015
@version P12
@param cDescript, caractere, Descrição(nome) da Entidade
@return cResult, Alias da Entidade
@example
	cCode := GetEntCode("Funcionários")	
	cCode => "SRA"
/*/
Static Function GetEntCode(cDescript)	
	Local	nPos := 0
	Local	cResult := ''
	Local	aNomes	:= GetEntList()
	
	nPos := aScan(aNomes,{|x|x[2] == cDescript})
			
	if(nPos > 0)
		cResult := aNomes[nPos,1]
	endif	
	
	aNomes := {}
Return cResult

/*/{Protheus.doc} GetEntList
	Retorna a lista de Entidades
@author PHILIPE.POMPEU
@since 04/05/2015
@version P12
@return aResult, vetor multidimensional com as entidades e suas descrições
@example
	//Ex do retorno:
	aResult [1] => aResult [1,1] => 'SRA', aResult [1,2] => 'Funcionarios'
	aResult [2] => aResult [2,1] => 'SM0', aResult [2,2] => 'Filiais'
	 
/*/
Static Function GetEntList()
	Local	cNomes	:= ''
	Local	aTemp	:= {}
	Local	aResult:= {}
	
	cNomes := fCrgTabBen()
	aTemp	:= StrTokArr(cNomes,';')	
	aEval(aTemp,{|x| aAdd(aResult,StrTokArr(x,'='))})
	aTemp := {}
	
Return aResult

/*/{Protheus.doc} BranchName
	Obtem o nome da Filial baseado no código informado
@author PHILIPE.POMPEU
@since 05/05/2015
@version P12
@param cBranch, caractere, código da filial
@return cResult, nome da filial
/*/
Static Function BranchName(cBranch)
	Local aArea	:= SM0->(GetArea())
	Local cResult := ''
	Local cCode	:= ''
	
	cCode := cEmpAnt + SUBSTR(cBranch,1,TamSX3('RA_FILIAL')[1])	
	cResult := AllTrim(Posicione('SM0',1,cCode,'M0_FILIAL'))
	
	RestArea(aArea)
Return cResult

/*/{Protheus.doc} BreakOpt
	Transforma a variável cOptions numa cláusula IN
@author PHILIPE.POMPEU
@since 06/05/2015
@version P12
@param cOptions, caractere, Opcoes à serem postar numa cláusula IN
@param lAspas, lógico, Se verdadeiro coloca Aspas em cada opção do IN
@return cResult, cláusula IN do SQL. (Ex: '1','2','A' ou 0,1,2)
/*/
Static Function BreakOpt(cOptions,lAspas)
	Local cResult := ''
	Local cLetra	:= ''
	Local nI := 0
	Default lAspas := .T.	
	
	cOptions := IIF(ValType(cOptions) != 'C',cValToChar(cOptions),cOptions) 		
	cOptions := RTrim(cOptions)			
	if!(Replicate('*',Len(cOptions)) == cOptions)
		
		for nI:= 1 to Len(cOptions)
			cLetra := SubStr(cOptions,nI,1)
			if(cLetra <> '*')
				if(lAspas)						
					cResult += "'" + cLetra + "'"
				Else
					cResult += cLetra
				endIf
				cResult += ','				
			endIf
		next nI
	endIf
	
	cResult:= SubStr(cResult,1,Len(cResult)-1) 
			
Return cResult

/*/{Protheus.doc} GetUnion
	Retorna uma consulta a partir do vetor fornecido
@author PHILIPE.POMPEU
@since 08/05/2015
@version P12
@param aQueries, vetor, vetor contendo um conjunto de queries à serem unidas
@param cUnionType, caractere, tipo do union(UNION, UNION ALL). Default: UNION
@return cResult, retorna uma string formada à partir de cada uma das posições de aQueries concatenadas com cUnionType
/*/
Static Function GetUnion(aQueries,cUnionType)
	Local cResult	:= ''	
	Local nI := 0
	Default cUnionType := 'UNION'
	
	for nI:= 1 to Len(aQueries)
		cResult += aQueries[nI]		
		if(nI < len(aQueries))
			cResult+=' ' + cUnionType + ' ' 
		endIf		
	next nI
	
Return cResult

/*/{Protheus.doc} GetVrVAJoin
(long_description)
@author PHILIPE.POMPEU
@since 08/05/2015
@version P12
@param lVR, ${param_type}, (Descrição do parâmetro)
@param lVA, ${param_type}, (Descrição do parâmetro)
@return cResult, ${return_description}
/*/
Static Function GetVrVAJoin(lVR,lVA,cCampo)
	Local cResult := ''
	Local aTemp	:= {}
	Local nI := 0
	Default cCampo = 'R0_TPVALE'
	
	if(lVR)
		aAdd(aTemp,"(LY_TIPO = 'VR' AND "+ cCampo +" ='1')")
	endIf
	
	if(lVA)
		aAdd(aTemp,"(LY_TIPO = 'VA' AND "+ cCampo +" ='2')")
	endIf
	
	for nI:= 1 to Len(aTemp)
		cResult+= aTemp[nI]
		if(nI < len(aTemp))
			cResult+=' OR '
		endIf
	next nI
	
	cResult:='('+ cResult + ')'
	
Return cResult

/*/{Protheus.doc} fR010Cr
	Validar se existe o código de critério informado na tabela SJQ.
@author PHILIPE.POMPEU
@since 08/05/2015
@version P12
@param cCod, caractere, (Descrição do parâmetro)
@return lResult, ${return_description}
/*/
Function fR010Cr(cCod)
	Local lResult	:= .F.
	Local aArea 	:= SJQ->(GetArea())
	Default cCod := &(ReadVar())
	
	cCod := PadR(cCod,TamSx3("JQ_CODIGO")[1])
		
	SJQ->(dbSetOrder(3))	
	lResult := SJQ->(DbSeek(FwxFilial('SJQ')+ cCod))
	
	if(!lResult)
		Help(,,'HELP',,OemToAnsi(STR0013),1,0 )
	endIf
		
	RestArea(aArea)
Return lResult

/*/{Protheus.doc} fR010Per
	Essa função deverá ser responsável por validar o código de período digitado, 
	se ele está contido entre o período inicial/final do critério e permitir que o pergunte esteja vazio.
@author philipe.pompeu
@since 08/05/2015
@version P12
@param cPeriodo, caractere, (Descrição do parâmetro)
@return lResult, ${return_description}
/*/
Function fR010Per(cPeriodo)
	Local lResult		:= .F.
	Local cMyAlias	:= GetNextAlias()
	
	Default cPeriodo := &(ReadVar())	
	
	if(Empty(cPeriodo))
		Return .T.
	endIf
	
	cPeriodo := PadR(cPeriodo,TamSx3("RFQ_PERIOD")[1])
		
	BeginSql alias cMyAlias
		SELECT RFQ_PERIOD 
		FROM %table:RFQ%
		WHERE
		RFQ_FILIAL = %xFilial:RFQ%
		AND
		%notDel%
		AND
		RFQ_PERIOD = %exp:cPeriodo%
		ORDER BY RFQ_FILIAL,RFQ_PROCES,RFQ_PERIOD
	EndSql	
	
	lResult:= (!(cMyAlias)->(Eof()))
	(cMyAlias)->(dbCloseArea())
	
	if(!lResult)
		Help(,,'HELP',,OemToAnsi(STR0014),1,0 )
	endIf
	
Return lResult


/*/{Protheus.doc} fR013Ftr
	Essa função deverá ser responsável por filtrar apenas os períodos ENTRE a data inicial e final do
	período associado ao critério selecionado no pergunte ‘Critério ?‘ (MV_PAR01) do grupo de perguntas GPR010.
	Para Período Inicial/Final do critério utilizar dados na tabela SRJ (JQ_PERINI/JQ_PERFIM).
@author philipe.pompeu
@since 11/05/2015
@version P12
@param cCriterio, caractere, (Descrição do parâmetro)
@return cResult, ${return_description}
/*/
Function fR013Ftr(cCriterio)
	Local cResult	:= ''
	Local aArea 	:= SJQ->(GetArea())
	Default cCriterio	:= ''	
	
	if(Empty(cCriterio))		
		if !(Type("MV_PAR01") == "U" )
			cCriterio := MV_PAR01 	
		endIf
	endIf
		
	cCriterio := PadR(cCriterio,TamSx3("JQ_CODIGO")[1])	
	SJQ->(dbSetOrder(3))	
	if(SJQ->(DbSeek(FwxFilial('SJQ')+ cCriterio)))
		cResult+= "((RFQ->RFQ_FILIAL == '"	+ FWxFilial('RFQ') + "')"
		cResult+= " .And. (RFQ->RFQ_PERIOD >= '"	+ SJQ->JQ_PERINI + "')"
		cResult+= " .And. (RFQ->RFQ_PERIOD <= '" + SJQ->JQ_PERFIM+"'))"	
	endIf
	
	RestArea(aArea)
	cResult:= "@#" + cResult + "@#"
Return (cResult)

/*/{Protheus.doc} GetInterval
(long_description)
@author philipe.pompeu
@since 11/05/2015
@version P12
@param cDe, caractere, (Descrição do parâmetro)
@param cAte, caractere, (Descrição do parâmetro)
@param cCriterio, caractere, (Descrição do parâmetro)
@return aResult, ${return_description}
/*/
Static Function GetInterval(cDe,cAte,cCriterio)	
	Local aResult := {}
	Local aArea 	:= SJQ->(GetArea())
	Local xTemp
	Default cCriterio := ''	
			
	
	if(Empty(cCriterio))		
		if !(Type("MV_PAR01") == "U" )
			cCriterio := MV_PAR01 
			cCriterio := PadR(cCriterio,TamSx3("JQ_CODIGO")[1])	
		endIf
	endIf
	
	if(Empty(cDe))
		SJQ->(dbSetOrder(3))	
		if(SJQ->(DbSeek(FwxFilial('SJQ')+ cCriterio)))
			cDe := SJQ->JQ_PERINI
		endIf			
	endIf
	
	if(Empty(cAte))
		SJQ->(dbSetOrder(3))
		if(SJQ->(DbSeek(FwxFilial('SJQ')+ cCriterio)))
			cAte := SJQ->JQ_PERFIM
		endIf		
	endIf		
	
	xTemp := cDe + '01'	
	aAdd(aResult,xTemp)	
	xTemp := cAte + '01'	
	xTemp := SToD(xTemp)
	xTemp := LastDate(xTemp)
	xTemp := DtoS(xTemp)	
	aAdd(aResult,xTemp)	
	
	RestArea(aArea)
Return aResult

/*/{Protheus.doc} fR010Vld
	Responsável por realizar a seguinte validação: caso a pergunta “Plano de Saúde” esteja como “Não”, 
	não será possível selecionar “Sim” para a impressão dos planos de dependentes e agregados
@author PHILIPE.POMPEU
@since 11/05/2015
@version P12
@param cPlano, caractere, valor de "Imprime Plano de Saúde?"
@param cDepen, caractere, valor de "Imprime Dependentes?"
@param cAgreg, caractere, valor de "Imprime Agregados?"
@return lResult, verdadeiro caso a opções selecionada esteja correta
/*/
Function fR010Vld(cPlano,cDepen,cAgreg)
	Local lPlano	:= .F.
	Local lDepen	:= .F.
	Local lAgreg	:= .F.
	Local lResult	:= .F.
	Local cNomeVal:= ReadVar()
	Local lIsPergunt:= .F.
	Default cPlano := ''
	Default cDepen := ''
	Default cAgreg := ''
	
	if(Empty(cPlano))		
		if !(Type("MV_PAR07") == "U" )
			cPlano := MV_PAR07										
		endIf
	endIf
	if(Empty(cDepen))		
		if !(Type("MV_PAR08") == "U" )
			cDepen := MV_PAR08				
		endIf
	endIf
	if(Empty(cAgreg))		
		if !(Type("MV_PAR09") == "U" )
			cAgreg := MV_PAR09				
		endIf
	endIf	
	
	lPlano := IIF(cPlano== 1,.T.,.F.)
	lDepen := IIF(cDepen== 1,.T.,.F.)
	lAgreg := IIF(cAgreg== 1,.T.,.F.)
	
	if(!lPlano)		
		if(lDepen .And. cNomeVal=='MV_PAR08')
			lResult:= .F.
			Help(,,'HELP',,OemToAnsi(STR0016),1,0 )
		Else
			lResult := .T.
		endIf
		
		if(lAgreg .And. lResult .And. cNomeVal=='MV_PAR09')
			lResult:= .F.
			Help(,,'HELP',,OemToAnsi(STR0017),1,0 )
		Else
			lResult := .T.
		endIf		
	Else
		lResult := .T.
	endIf
		
Return lResult


/*/{Protheus.doc} EntityJoin
	Faz o Join com a Entidade informada em cEntidade
@author PHILIPE.POMPEU
@since 25/05/2015
@version P12
@param cEntidade, caractere, Entidade que deve ser feito o join
@return cJoin, Join com a Entidade informada
/*/
Static Function EntityJoin(cEntidade)
	Local cJoin := ''
	Local lIntegServ := SuperGetMV('MV_TECXRH',.F.,.F.)
	Default cEntidade = ''
	
	cJoin	:='INNER JOIN '
	Do Case
		Case (cEntidade == 'SQB')			
			cJoin	+= RetSqlName('SQB') + ' SQB ON ('
			cJoin	+= 'QB_FILIAL = LY_FILENT AND QB_DEPTO = LY_CHVENT AND SQB.D_E_L_E_T_ = SLY.D_E_L_E_T_)'
		Case (cEntidade == 'CTT')			
			cJoin	+= RetSqlName('CTT') + ' CTT ON ('
			cJoin	+= 'CTT_FILIAL = LY_FILENT AND CTT_CUSTO = LY_CHVENT AND CTT.D_E_L_E_T_ = SLY.D_E_L_E_T_)'			
		Case (cEntidade == 'SQ3')			
			cJoin	+= RetSqlName('SQ3') + ' SQ3 ON ('
			cJoin	+= 'SQ3.Q3_FILIAL = SLY.LY_FILENT AND SQ3.Q3_CARGO = SLY.LY_CHVENT AND SQ3.D_E_L_E_T_ = SLY.D_E_L_E_T_)'
		Case (cEntidade == 'SRJ')						
			cJoin	+= RetSqlName('SRJ') + ' SRJ ON ('
			cJoin	+= 'RJ_FILIAL = LY_FILENT AND RJ_FUNCAO = LY_CHVENT AND SRJ.D_E_L_E_T_ = SLY.D_E_L_E_T_)'
		Case (cEntidade == 'SR6')			
			cJoin	+= RetSqlName('SR6') + ' SR6 ON ('
			cJoin	+= 'R6_FILIAL = LY_FILENT AND R6_TURNO = LY_CHVENT AND SR6.D_E_L_E_T_ = SLY.D_E_L_E_T_)'
		Case (cEntidade == 'RCE')			
			cJoin	+= RetSqlName('RCE') + ' RCE ON ('
			cJoin	+= 'RCE_FILIAL = LY_FILENT AND RCE_CODIGO = LY_CHVENT AND RCE.D_E_L_E_T_ = SLY.D_E_L_E_T_)'		
		Case (cEntidade == 'RCL')			
			cJoin	+= RetSqlName('RCL') + ' RCL ON ('
			cJoin	+= 'RCL_FILIAL = LY_FILENT AND RCL_POSTO = LY_CHVENT AND RCL.D_E_L_E_T_ = SLY.D_E_L_E_T_)'
		Case (cEntidade == 'SM0')
			cJoin := ''			
		OtherWise
			if(lIntegServ)
				Do Case
					Case (cEntidade == 'SA1')						
						cJoin	+= RetSqlName('SA1') + ' SA1 ON ('
						cJoin	+= 'A1_FILIAL = LY_FILENT AND A1_COD = LY_CHVENT AND SA1.D_E_L_E_T_ = SLY.D_E_L_E_T_)'
					Case (cEntidade == 'ABS')						
						cJoin	+= RetSqlName('ABS') + ' ABS ON ('
						cJoin	+= 'ABS_FILIAL = LY_FILENT AND ABS_LOCAL = LY_CHVENT AND ABS.D_E_L_E_T_ = SLY.D_E_L_E_T_)'
					Case (cEntidade == 'TDX')						
						cJoin	+= RetSqlName('TDX') + ' TDX ON ('
						cJoin	+= 'TDX_FILIAL = LY_FILENT AND TDX_COD = LY_CHVENT AND TDX.D_E_L_E_T_ = SLY.D_E_L_E_T_)'			
				EndCase
			endIf		
	EndCase
Return cJoin

/*/{Protheus.doc} EntityField
Retorna o campo que contém a descrição da Entidade
@author PHILIPE.POMPEU
@since 25/05/2015
@version P12
@param cEntidade, caractere, Entidade que o campo deve vir
@return cCampo, Campo na entidade que contem a sua descrição
/*/
Static Function EntityField(cEntidade)
	Local cCampo := ''
	Local lIntegServ := SuperGetMV('MV_TECXRH',.F.,.F.)	
	Default cEntidade = ''
	Do Case
		Case (cEntidade == 'SQB')
			cCampo	:='QB_DESCRIC'			
		Case (cEntidade == 'CTT')			
			cCampo	:= 'CTT_DESC01'						
		Case (cEntidade == 'SQ3')
			cCampo	:='Q3_DESCSUM'			
		Case (cEntidade == 'SRJ')
			cCampo	:='RJ_DESC'			
		Case (cEntidade == 'SR6')
			cCampo	:='R6_DESC'			
		Case (cEntidade == 'RCE')
			cCampo	:='RCE_DESCRI'					
		Case (cEntidade == 'RCL')		
			cCampo	:="''"			
		Case (cEntidade == 'SM0')
			cCampo	:="'VAZIO'"			
		OtherWise
			if(lIntegServ)
				Do Case
					Case (cEntidade == 'SA1')
						cCampo:='A1_NOME'						
					Case (cEntidade == 'ABS')
						cCampo:='ABS_DESCRI'						
					Case (cEntidade == 'TDX')	
						cCampo:="''"									
				EndCase
			endIf		
	EndCase	
Return cCampo

/*/{Protheus.doc} GetFuncJoin
(long_description)
@author PHILIPE.POMPEU
@since 25/05/2015
@version P12
@param cEntidade, caractere, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetFuncJoin(cEntidade)
	Local cFunJoin	:= ''
	Default cEntidade = ''
		
	cFunJoin := 'INNER JOIN '
	cFunJoin += RetSqlName('SRA') + ' SRA ON ('			
	Do Case
		Case (cEntidade == 'SQB')
			cFunJoin += 'SRA.RA_DEPTO = SQB.QB_DEPTO AND'
		Case (cEntidade == 'CTT')				 	
			cFunJoin += 'SRA.RA_CC = CTT.CTT_CUSTO AND'			
		Case (cEntidade == 'SQ3')
			cFunJoin += 'SRA.RA_CARGO = SQ3.Q3_CARGO AND'
		Case (cEntidade == 'SRJ')
			cFunJoin += 'SRA.RA_CODFUNC = SRJ.RJ_FUNCAO AND'
		Case (cEntidade == 'SR6')
			cFunJoin += 'SRA.RA_TNOTRAB = SR6.R6_TURNO AND'
		Case (cEntidade == 'RCE')
			cFunJoin += 'SRA.RA_SINDICA = RCE.RCE_CODIGO AND'		
		Case (cEntidade == 'RCL')		
			cFunJoin += 'SRA.RA_POSTO = RCL.RCL_POSTO AND'
		Case (cEntidade == 'SM0')
			cFunJoin += 'SRA.RA_FILIAL = LY_CHVENT AND'		
	EndCase	
	cFunJoin +=' SRA.D_E_L_E_T_ = SLY.D_E_L_E_T_'
	
	if(cEntidade <> 'SM0')
		cFunJoin +=" AND SRA.RA_FILIAL ='"+ FWxFilial("SRA") +"'"			
	endIf	
	cFunJoin+=")"
	
Return cFunJoin

/*/{Protheus.doc} TpPlano
@author PHILIPE.POMPEU
@since 27/05/2015
@version P12
@param aTpPlano, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function TpPlano(aTpPlano,cCampo)	
	Local cTemp := ''	
	Local nI := 0
	Default cCampo := 'RHR_ORIGEM'
	
	for nI:= 1 to Len(aTpPlano)
		cTemp+="'"+aTpPlano[nI]+"'"
		if(nI < Len(aTpPlano))
			cTemp+=','
		endIf
	next nI
		
Return (cCampo + " IN("+cTemp+")")


Static Function GetPeriods(cDe,cAte,aVrVa)
	Local cMyAlias	:= GetNextAlias()
	Local aResult	:= {}
	Local aUmPeriodo	:= {}
	Local lEstaAberto	:= .F.
	Local nI := 0
	Local cIn	:= ''
	Local cWhere := ""
	
	for nI:= 1 to Len(aVrVa)
		cIn+="'"+ aVrVa[nI] + "'"
		
		if(nI < Len(aVrVa))
			cIn+=","
		endIf
	next nI
	cIn:= '%'+ cIn + '%'
	
	If !(Empty(cDe))
		cWhere += " RCH_PER >= " + cDe +  " AND "
	EndIf
	
	If !(Empty(cAte))
		cWhere += " RCH_PER <= " + cAte + " AND "
	EndIf
	
	If !(Empty(cWhere))
		cWhere		:= "%" + cWhere + "%"
	Else
		cWhere		:= "% %"
	EndIf
	
	BeginSql alias cMyAlias
		SELECT DISTINCT RCH_FILIAL,RCH_PER,RCH_DTFECH,RCH_PERSEL,RCH_DTINI,RCH_DTFIM
		FROM %table:RCH% RCH
		WHERE RCH_ROTEIR IN(SELECT RY_CALCULO FROM %table:SRY% SRY WHERE RY_TIPO IN (%exp:cIn%) AND SRY.%notDel% AND RY_FILIAL=%xFilial:SRY%)
		AND ((RCH_DTFECH='' AND RCH_PERSEL=1) OR (RCH_DTFECH<>''))
		AND %exp:cWhere%
		RCH_FILIAL = %xFilial:RCH% AND RCH.%notDel%
	EndSql
	
	while ( (cMyAlias)->(!Eof()) )
		if !(aScan(aResult,{|x|x[1] == (cMyAlias)->RCH_PER }) > 0)
			aUmPeriodo := {}
			aAdd(aUmPeriodo,(cMyAlias)->RCH_PER)
			
			lEstaAberto := Empty((cMyAlias)->RCH_DTFECH)
			
			aAdd(aUmPeriodo,lEstaAberto)
			aAdd(aUmPeriodo,{(cMyAlias)->RCH_DTINI,(cMyAlias)->RCH_DTFIM})
			
			aAdd(aResult,aUmPeriodo)
		endIf
		(cMyAlias)->(dbSkip())
	End
	(cMyAlias)->(dbCloseArea())
Return (aResult)


Static Function GetWhere(cCampo,aPeriodos)
	Local cWhere	:= ''
	Local aTemp	:= {}
	Local nI := 0
	
	
	for nI:= 1 to Len(aPeriodos)		
		if(!aPeriodos[nI,2])// Estiver fechado			
			aAdd(aTemp,"'"+aPeriodos[nI,1]+"'")			
		endIf
	next nI
	If Len(aTemp) > 0 
		cWhere := cCampo + ' IN ('
		for nI:= 1 to Len(aTemp)
			cWhere+= aTemp[nI]
			if(nI < Len(aTemp))
				cWhere+=','
			endIf
		next nI
		
		cWhere+=')'
	EndIf	
	aSize(aTemp,0)
	aTemp := Nil
Return cWhere

