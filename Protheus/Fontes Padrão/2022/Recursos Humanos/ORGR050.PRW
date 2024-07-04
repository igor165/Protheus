#INCLUDE "orgr050.ch"
#INCLUDE "protheus.ch"      
#INCLUDE "report.ch"
      
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa     ³ ORGR050  ³ Autor ³ Tania Bronzeri        ³ Data ³02/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Relacao de Ocupantes X Postos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ SigaOrg - Arquitetura Organizacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Cecilia Carv.³07/08/14³TQEQKP³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³             ³        ³      ³a limpeza.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGR050()
	Local oReport   
	Local aArea 		:= GetArea()
	Private cAliasQry	:= "SRA"
	Private cAliasRCL	:= "RCL"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte("ORG50R",.F.)      
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
	RestArea( aArea )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³02/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Ocupantes x Postos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGR050                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ORGR050 - Generico                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
	Local oReport 
	Local oSection1 
	Local oSection2
	Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002)		//"Cadastro de Ocupantes x Postos" ### "Ser  impresso de acordo com os parametros solicitados pelo usu rio."
	Private aOrd    := {OemToAnsi(STR0003), OemToAnsi(STR0004)}	//"Codigo da Pessoa" ### "Nome da Pessoa"
	Private cTitulo	:= OemToAnsi(STR0001)							//"Cadastro de Ocupantes x Postos"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao dos componentes de impressao                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE REPORT oReport NAME "ORGR050" TITLE cTitulo PARAMETER "ORG50R" ACTION {|oReport| ORG50Imp(oReport)} DESCRIPTION OemtoAnsi(STR0005)	//"Este relatorio emite as indicacoes de postos ocupados para cada ocupante."
	
		DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0006) TABLES "SRA" ORDERS aOrd	//"Ocupante"
	
			DEFINE CELL NAME "RA_FILIAL"  	OF oSection1 ALIAS "SRA"
			DEFINE CELL NAME "RA_MAT"  	OF oSection1 ALIAS "SRA" 
			DEFINE CELL NAME "RA_NOME" 	OF oSection1 ALIAS "SRA"
//			DEFINE CELL NAME "RA_TIPO"    	OF oSection1 ALIAS "SRA"
//			DEFINE CELL NAME "RA_DTADMI"  	OF oSection1 ALIAS "SRA"
//			DEFINE CELL NAME "MATRICULA"    OF oSection1 TITLE OemToAnsi(STR0007) ;	//"Funcionario"
//				BLOCK {||EntGetInfo("SRA","RA_MAT",(cAliasQry)->RA_MAT)}
			
			oSection1:SetHeaderBreak(.T.)                                                                         
	
	
		DEFINE SECTION oSection2 OF oSection1 TITLE OemToAnsi(STR0008) TABLES "RCL", "SQ3", "SRJ", "RCX" ORDERS aOrd	//"Postos"
			
			DEFINE CELL NAME "RCL_POSTO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0009) SIZE 10	//Posto
			DEFINE CELL NAME "RCX_SUBST"	OF oSection2 ALIAS "RCX" 			
			DEFINE CELL NAME "RCL_CARGO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0010) SIZE 10	//Cargo
			DEFINE CELL NAME "Q3_DESCSUM"	OF oSection2 ALIAS "SQ3"
			DEFINE CELL NAME "RCL_FUNCAO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0011) SIZE 8	//Funcao
			DEFINE CELL NAME "RJ_DESC"		OF oSection2 ALIAS "SRJ"
			DEFINE CELL NAME "RCL_CC"		OF oSection2 ALIAS "RCL"
	 		DEFINE CELL NAME "RCL_SALAR"	OF oSection2 ALIAS "RCL"
			DEFINE CELL NAME "RCL_ENCARG"	OF oSection2 ALIAS "RCL"

			If cPaisLoc == "BRA"
				DEFINE CELL NAME "RCL_FGTS"		OF oSection2 ALIAS "RCL"
			EndIf

			DEFINE CELL NAME "RCL_BENEF"	OF oSection2 ALIAS "RCL" 
			DEFINE CELL NAME "RCL_DTINI"	OF oSection2 ALIAS "RCL" 
			DEFINE CELL NAME "RCL_DTFIM"	OF oSection2 ALIAS "RCL" 
	                

			TRPosition():New(oSection2, "SQ3", 1, {|| RhFilial("SQ3",(cAliasRCL)->RCL_FILIAL)+(cAliasRCL)->RCL_CARGO})
			TRPosition():New(oSection2, "SRJ", 1, {|| RhFilial("SRJ",(cAliasRCL)->RCL_FILIAL)+(cAliasRCL)->RCL_FUNCAO})
	
			oSection2:SetLeftMargin(5)	                            

		oReport:SetLandscape(.T.)			//seleciona paisagem
		oReport:lDisableOrientation:= .T. 	//desabilita opcao de orientacao do papel
		oReport:oPage:nPaperSize:= 9 		//pre-seleciona papel A4 (Sulfite) 210x297mm 
		oReport:SetColSpace(4)
	
Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ORG50Imp   ³ Autor ³ Tania Bronzeri        ³ Data ³02/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Ocupantes x Postos                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ORG50Imp(oReport)
	Local oSection1 := oReport:Section(1)				//Ocupantes
	Local oSection2 := oReport:Section(1):Section(1)  	//Postos
	Local cFiltro 	:= ""  
	Local cFiltData	:= ""
	Local cFiltSRA	:= ""
	Local cFiltRD0	:= ""
	Local cJoinSQ3	:= ""
	Local cJoinSRJ	:= ""
	Local cJoinRCL	:= ""
	
	Private cOrdem:= ""
	Private nOrdem	:= oSection1:GetOrder()
	Private lAnalit	:= Iif(mv_par06==1,.T.,.F.)		//Analitico / Sintetico
		
	cAliasQry := GetNextAlias()
	cAliasRCL := cAliasQry
                             
	Pergunte("ORG50R", .F.)
	cFiltData:= "RCL.RCL_DTINI >= '"+dtos(mv_par04)+"' AND (RCL.RCL_DTFIM <= '"+dtos(mv_par05)+"' or RCL.RCL_DTFIM='')"
	
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr("ORG50R")

	cFiltSRA := cFiltData                                	
	If !Empty(mv_par01);	cFiltSRA += " AND " + StrTran(mv_par01, "RD0_FILIAL", "RA_FILIAL") ;	EndIf
	If !Empty(mv_par02);	cFiltSRA += " AND " + StrTran(mv_par02, "RD0_CODIGO", "RA_MAT");	EndIf    
	cFiltSRA := "%" + cFiltSRA + "%"

	cFiltData+= " AND RCX.RCX_FILOCU = RCL.RCL_FILIAL "
	cFiltRD0 := cFiltData 
	If !Empty(mv_par01);	cFiltRD0 += " AND " + StrTran(mv_par01, "RA_FILIAL", "RD0_FILIAL") ;	EndIf
	If !Empty(mv_par02);	cFiltRD0 += " AND " + StrTran(mv_par02, "RA_MAT", "RD0_CODIGO");	EndIf    
      	cFiltRD0 := "%" + cFiltRD0 + "%"
      	
	cJoinSQ3 += "%"
	cJoinSQ3 += FWJoinFilial( "SQ3", "RCL" )
	cJoinSQ3 += "%"
	
	cJoinSRJ += "%"
	cJoinSRJ += FWJoinFilial( "SRJ", "RCL" )
	cJoinSRJ += "%"
	
	cJoinRCL += "%"
	cJoinRCL += FWJoinFilial( "RCX", "RCL" )
	cJoinRCL += "%"
		
	BEGIN REPORT QUERY oSection1
		If nOrdem == 1
			cOrdem := "%1,2%"
		Else
			cOrdem := "%1,3%"
		EndIf

		BeginSql alias cAliasQry
			COLUMN RCL_SALAR AS NUMERIC(12, 2)
			COLUMN RCL_BENEF AS NUMERIC(12, 2)
			COLUMN RCL_ENCARG AS NUMERIC(12, 2)
			COLUMN RCX_DTINI AS DATE
			COLUMN RCX_DTFIM AS DATE

			SELECT
				SRA.RA_FILIAL, 
				SRA.RA_MAT, 
				SRA.RA_NOME,
				RCL.RCL_FILIAL, 					 
				RCL.RCL_POSTO, 
				RCL.RCL_CC, 
				RCL.RCL_FUNCAO, 
				RCL.RCL_CARGO, 
				RCL.RCL_SALAR, 
				RCL.RCL_BENEF, 
				RCL.RCL_ENCARG, 
				RCL.RCL_DTINI, 
				RCL.RCL_DTFIM, 
				RCX.RCX_SUBST,
				RCX.RCX_FILFUN,
				RCX.RCX_MATFUN,
				SQ3.Q3_DESCSUM,
				SRJ.RJ_DESC  
			FROM  
				%table:SRA% SRA
			LEFT JOIN %table:RCX% RCX 
			ON  RCX.RCX_MATFUN = SRA.RA_MAT 
				AND RCX.RCX_FILFUN = SRA.RA_FILIAL 
				AND RCX.%notDel%  
			LEFT JOIN %table:RCL% RCL 
			ON  %exp:cJoinRCL% AND RCL.RCL_POSTO = RCX.RCX_POSTO
				AND RCL.%notDel%
			LEFT JOIN %table:SQ3% SQ3
			ON %exp:cJoinSQ3% 
				AND	SQ3.Q3_CARGO = RCL.RCL_CARGO
				AND ( SQ3.Q3_CC = RCL.RCL_CC OR SQ3.Q3_CC = '' )
				AND SQ3.%notDel%
			LEFT JOIN %table:SRJ% SRJ
			ON %exp:cJoinSRJ%
				AND SRJ.RJ_FUNCAO = RCL.RCL_FUNCAO
				AND SRJ.%notDel%   
			WHERE   
				%exp:cFiltSRA% AND
				SRA.%notDel%      
			UNION
			SELECT					
				RD0.RD0_FILIAL, 
				RD0.RD0_CODIGO, 
				RD0.RD0_NOME,
				RCL.RCL_FILIAL, 					 
				RCL.RCL_POSTO, 
				RCL.RCL_CC, 
				RCL.RCL_FUNCAO, 
				RCL.RCL_CARGO, 
				RCL.RCL_SALAR, 
				RCL.RCL_BENEF, 
				RCL.RCL_ENCARG, 
				RCL.RCL_DTINI, 
				RCL.RCL_DTFIM, 
				RCX.RCX_SUBST,
				RCX.RCX_FILFUN,
				RCX.RCX_MATFUN,
				SQ3.Q3_DESCSUM,
				SRJ.RJ_DESC  
			FROM  
				%table:RD0% RD0
			LEFT JOIN %table:RCX% RCX 
			ON  RCX.RCX_CODOCU = RD0.RD0_CODIGO
			AND RCX.RCX_FILOCU = RD0.RD0_FILIAL 
			AND RCX.%notDel%  
			LEFT JOIN %table:RCL% RCL 
			ON   %exp:cJoinRCL% AND RCL.RCL_POSTO = RCX.RCX_POSTO
			AND RCL.%notDel%
			LEFT JOIN %table:SQ3% SQ3
			ON %exp:cJoinSQ3% 
			AND	SQ3.Q3_CARGO = RCL.RCL_CARGO
			AND ( SQ3.Q3_CC = RCL.RCL_CC OR SQ3.Q3_CC = '' )
			AND SQ3.%notDel%
			LEFT JOIN %table:SRJ% SRJ
			ON %exp:cJoinSRJ%
			AND SRJ.RJ_FUNCAO = RCL.RCL_FUNCAO
			AND SRJ.%notDel% 
			WHERE   
				%exp:cFiltRD0% AND
				RD0.%notDel%
			ORDER BY
				%exp:cOrdem%
		EndSql                                

	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	END REPORT QUERY oSection1// PARAM mv_par01, mv_par02, mv_par03
	
	oSection2:SetParentQuery(.T.)
	oSection2:SetParentFilter( { |cParam| (CAliasQry)->RCX_MATFUN == cParam },{ || (cAliasQry)->RA_MAT })

	If !lAnalit
		oSection2:Hide()
		//oSection2:SetLineCondition({||Org50OcupAtu()}) -- CASO SEJA NECESSARIO RESTAURAR O RELATORIO SINTETICO ANTERIOR. LUIS
	EndIf
	
	//oSection1:SetLineCondition({||Org50ExistOcup(lAnalit)}) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da impressao do fluxo do relatório ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter( (cAliasQry)->(LastRec()) )  
	
	(cAliasQry)->( dbGoTop() )
	
	oSection1:Print()
Return
              
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Org50ExistOcup ³ Autor ³ Tania Bronzeri   ³ Data ³04/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Line Condition para impressao da section 1        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto SIGAORG                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Org50ExistOcup(lAnalit)
	Local aArea	:= GetArea()
	Local lRet	:=	.T.     
	Default lAnalit	:= .T.
	
	If (cAliasRCL)->(Dbseek(RhFilial("RCL",(cAliasQry)->RA_FILIAL)+(cAliasQry)->RA_MAT))
		lRet:= Iif(!lAnalit,Iif(Empty((cAliasRCL)->RCL_DTFIM),.T.,.F.),.T.)
	Else
		lRet:=	.F.
	EndIf
	
	RestArea(aArea)
Return lRet
                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Org50OcupAtu   ³ Autor ³ Tania Bronzeri   ³ Data ³04/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Line Condition para impressao da section 2        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto SIGAORG                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Org50OcupAtu()
	Local aArea	:= GetArea()
	Local lRet	:=	.T.     
	
	If Empty((cAliasRCL)->RCL_DTFIM)
		lRet	:=	.T.
	Else
		lRet	:=	.F.
	EndIf
	
	RestArea( aArea )
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fChkDtIni³ Autor ³ Claudinei Soares      ³ Data ³ 20.05.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa a Data de Inicio      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fChkDtIni()
Local dData := &(Alltrim(ReadVar()))

If 	Empty(dData) .OR. (!Empty(MV_PAR05).And. dData > MV_PAR05)
	Help(" ",1,".ORG50RIN.")
	dData:= Ctod(" / / ")
	Return (.F.)
Endif
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fChkDtFim³ Autor ³ Claudinei Soares      ³ Data ³ 20.05.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa a Data de Inicio      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fChkDtFim()
Local dData := &(Alltrim(ReadVar()))

If 	Empty(dData	) .OR. dData < MV_PAR04 .Or. Empty(MV_PAR04)
	Help(" ",1,".ORG50RFM.")       	
	Return (.F.)
Endif
Return (.T.)
