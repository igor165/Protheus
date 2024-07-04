#INCLUDE "ORGR060.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa     ³ ORGR060  ³ Autor ³ Tania Bronzeri        ³ Data ³04/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao    ³ Relacao de Postos x Ocupantes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ SigaOrg - Arquitetura Organizacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PROGRAMADOR  ³ DATA   ³CHAMADO/REQ³  MOTIVO DA ALTERACAO 					³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Mohanad Odeh ³26/03/14³M_RH003    ³Versao 12                              ³±±
±±³             ³        ³315902     ³                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGR060()
Local oReport   
Local aArea 		:= GetArea()
Private cAliasQry	:= "RCL"
Private cAliasRCX	:= "RCX"

PRIVATE aFldRot 	:= {'RA_NOME', 'RD0_NOME'}
PRIVATE aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
PRIVATE lOfuscaSRA 	:= .F. 
PRIVATE lOfuscaRD0 	:= .F. 
PRIVATE aFldOfusca	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaSRA := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RD0_NOME" } ) > 0
		lOfuscaRD0 := FwProtectedDataUtil():IsFieldInList( "RD0_NOME" )
	ENDIF
EndIf

//VERIFICA AS PERGUNTAS SELECIONADAS
Pergunte("ORG60R",.F.) 

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³04/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Postos x Ocupantes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGR060                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ORGR060 - Generico                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2
Local oSection3
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002) //"Relatorio de Postos x Ocupantes" ### "Sera impresso de acordo com os parametros solicitados pelo usuario."
Private aOrd    := {OemToAnsi(STR0003)}	//"Departamento / Posto"
Private cTitulo	:= OemToAnsi(STR0001)	//"Relatorio de Postos x Ocupantes"

//CRIACAO DOS COMPONENTES DE IMPRESSAO
DEFINE REPORT oReport NAME "ORGR060" TITLE cTitulo PARAMETER "ORG60R" ACTION {|oReport| ORG60Imp(oReport)} DESCRIPTION OemtoAnsi(STR0004)	//"Emite relacao de Postos com seus Ocupantes atuais e anteriores."

	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0005) TABLES "RCL", "SQB" ORDERS aOrd	//"Departamento"

		DEFINE CELL NAME "RCL_FILIAL"  	OF oSection1 ALIAS "RCL"
		DEFINE CELL NAME "RCL_DEPTO"  	OF oSection1 ALIAS "RCL" 
		DEFINE CELL NAME "QB_DESCRIC" 	OF oSection1 ALIAS "SQB" 

		TRPosition():New(oSection1,"SQB",1,{|| RhFilial("SQB",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_DEPTO})

		oSection1:SetHeaderBreak(.T.)                                                                    
		oSection1:SetLineStyle()          

	DEFINE SECTION oSection2 OF oSection1 TITLE OemToAnsi(STR0006) TABLES "RCL", "SQ3", "SRJ" ORDERS aOrd	 //"Postos"

		DEFINE CELL NAME "RCL_POSTO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0007) SIZE TamSx3("RCL_POSTO")[1]+2	//Posto
		DEFINE CELL NAME "RCL_CARGO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0008) SIZE 10	//Cargo
		DEFINE CELL NAME "Q3_DESCSUM"	OF oSection2 ALIAS "SQ3"
		DEFINE CELL NAME "RCL_FUNCAO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0009) SIZE 10	//Funcao
		DEFINE CELL NAME "RJ_DESC"		OF oSection2 ALIAS "SRJ"
 		DEFINE CELL NAME "RCL_SALAR"	OF oSection2 ALIAS "RCL"
		DEFINE CELL NAME "RCL_BENEF"	OF oSection2 ALIAS "RCL"
		DEFINE CELL NAME "RCL_ENCARG"	OF oSection2 ALIAS "RCL"
		DEFINE CELL NAME "RCL_NPOSTO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0021) SIZE 10 //"Maximo"
		DEFINE CELL NAME "RCL_OPOSTO"	OF oSection2 ALIAS "RCL" TITLE OemToAnsi(STR0022) SIZE 10 //"Ocupados" 

		If cPaisLoc == "BRA"
			DEFINE CELL NAME "RCL_FGTS"		OF oSection2 ALIAS "RCL"
		EndIf

		TRPosition():New(oSection2,"SQ3",1,{|| RhFilial("SQ3",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_CARGO})
		TRPosition():New(oSection2,"SRJ",1,{|| RhFilial("SRJ",(cAliasQry)->RCL_FILIAL)+(cAliasQry)->RCL_FUNCAO})

	DEFINE SECTION oSection3 OF oSection2 TITLE OemToAnsi(STR0010) TABLES "RCX", "RD0", "SRA" ORDERS aOrd	//"Historico"

		DEFINE CELL NAME "RCX_DTINI"	OF oSection3 ALIAS "RCX" 
		DEFINE CELL NAME "RCX_DTFIM"	OF oSection3 ALIAS "RCX"               
		DEFINE CELL NAME "FILOCU"  		OF oSection3 TITLE OemToAnsi(STR0017) ;  // "Fil. Ocupante"
			BLOCK{|| IIF((cAliasQry)->RCX_TIPOCU == "1", (cAliasQry)->RCX_FILFUN, (cAliasQry)->RCX_FILOCU) }
		DEFINE CELL NAME "CODOCU"		OF oSection3 TITLE OemToAnsi(STR0018) ; // "Cod. Ocupante"
			BLOCK{|| IIF((cAliasQry)->RCX_TIPOCU == "1", (cAliasQry)->RCX_MATFUN, (cAliasQry)->RCX_CODOCU ) }
		DEFINE CELL NAME "NOMEOCU"		OF oSection3 TITLE OemToAnsi(STR0019) SIZE 10 ; //"Nome Ocupante"
			BLOCK{|| IIF((cAliasQry)->RCX_TIPOCU == "1", If(lOfuscaSRA,Replicate('*',15),(cAliasQry)->RA_NOME), If(lOfuscaRD0,Replicate('*',15),(cAliasQry)->RD0_NOME )) }
		DEFINE CELL NAME "SUBST"			OF oSection3 TITLE STR0020 SIZE 10 ;		//"Titular?"
			BLOCK{|| IIF((cAliasQry)->RCX_SUBST == "1", STR0023, STR0024) }  //"Substituto" ### "Titular" 

		TRPosition():New(oSection3,"RD0",1,{|| RhFilial("RD0",(cAliasRCX)->RCX_FILIAL)+(cAliasRCX)->RCX_CODOCU})

		oSection2:SetLeftMargin(02)
		oSection3:SetLeftMargin(08)

	oReport:SetColSpace(2)		

Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ORG60Imp   ³ Autor ³ Tania Bronzeri        ³ Data ³04/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Postos x Ocupantes                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ORG60Imp(oReport)
Local oSection1	:= oReport:Section(1)				//Departamentos
Local oSection2	:= oReport:Section(1):Section(1)  	//Postos
Local oSection3	:= oSection2:Section(1)				//Historico
Local cFiltro 	:= "" 
Local cJoinSQ3	:= ""
Local cJoinSQB	:= ""
Local cJoinSRJ	:= ""
Local cStatus	:= ""
Local cTitPos	:= ""
Local nReg		:= 0
Local oBreakPost

Private cOrdem	:= ""
Private cSts		:= MV_PAR04						// Status a Imprimir
Private cSubst	:= IIF(MV_PAR05==1, '2', "%" + "'1', '2'" + "%" )						// Exibe substitutos
Private lAnalit	:= Iif(MV_PAR06==1,.T.,.F.)		// Analitico / Sintetico

If lAnalit
	oSection3:Enable()
Else
	oSection3:Disable()
	cSubst := '2'
EndIf

If MV_PAR05 == 1
	oSection3:Cell("SUBST"):Disable()	
Endif

cAliasQry := GetNextAlias()
cAliasRCX := cAliasQry

//MODIFICA VARIAVEIS PARA A QUERY
cStatus := ""
For nReg:=1 to Len(cSts)
	cStatus += "'"+Subs(cSts,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSts)
		cStatus += "," 
	Endif
Next nReg        
cStatus := "%" + cStatus + "%"

//TRANSFORMA PARAMETROS DO TIPO RANGE EM EXPRESSAO ADVPL PARA SER UTILIZADA NO FILTRO
MakeSqlExpr("ORG60R")

DEFINE BREAK oBreakPost OF oSection1 WHEN oSection1:Cell("RCL_DEPTO") TITLE STR0025 //"Total de Postos"

oBreakPost:OnBreak({|x|cTitPos:=STR0025})
oBreakPost:SetTotalText({||cTitPos})

DEFINE FUNCTION FROM oSection2:Cell("RCL_POSTO") FUNCTION COUNT BREAK oBreakPost TITLE STR0026 NO END SECTION // "Postos "
DEFINE FUNCTION FROM oSection2:Cell("RCL_NPOSTO") FUNCTION SUM BREAK oBreakPost TITLE STR0027 NO END SECTION // "Quantidade Maxima "
DEFINE FUNCTION FROM oSection2:Cell("RCL_OPOSTO") FUNCTION SUM BREAK oBreakPost TITLE STR0028 NO END SECTION // "Quantidade Ocupados "
oSection1:SetTotalInLine(.T.)

BEGIN REPORT QUERY oSection1

cOrdem  := "%RCL.RCL_FILIAL,RCL.RCL_DEPTO,RCL.RCL_POSTO%"

cJoinSQ3 := "%"
cJoinSQ3 += FWJoinFilial( "RCL", "SQ3" )
cJoinSQ3 += "%"

cJoinSQB := "%"
cJoinSQB += FWJoinFilial( "RCL", "SQB" )
cJoinSQB += "%"

cJoinSRJ := "%"
cJoinSRJ += FWJoinFilial( "RCL", "SRJ" )
cJoinSRJ += "%"

BEGINSQL ALIAS cAliasQry
	COLUMN RCL_SALAR AS NUMERIC(12,2)
	COLUMN RCL_BENEF AS NUMERIC(12,2)
	COLUMN RCL_ENCARG AS NUMERIC(12,2)
	COLUMN RCX_DTINI AS DATE
	COLUMN RCX_DTFIM AS DATE

	SELECT 	
		RCL.RCL_FILIAL, 
		RCL.RCL_DEPTO,  
		RCL.RCL_POSTO, 
		RCL.RCL_CARGO,  
		RCL.RCL_FUNCAO, 
		RCL.RCL_SALAR, 
		RCL.RCL_BENEF, 	
		RCL.RCL_ENCARG,
		RCL.RCL_NPOSTO, // QTDE MAX
		RCL.RCL_OPOSTO, // QTDE OCUP
		RCX.RCX_DTINI,	
		RCX.RCX_DTFIM, 
		RCX.RCX_FILOCU,
		RCX.RCX_FILFUN,
		RCX.RCX_CODOCU, 
		RCX.RCX_TIPOCU, 
		RCX.RCX_POSTO, 
		RCX.RCX_FILIAL,						
		RCX.RCX_MATFUN,
		RCX.RCX_SUBST,
		RD0.RD0_NOME,
		SQ3.Q3_DESCSUM,
		SQB.QB_DESCRIC,
		SRJ.RJ_DESC,
		SRA.RA_NOME
	FROM %table:RCL% RCL 
	LEFT JOIN %table:RCX% RCX
		ON  RCL.RCL_POSTO = RCX.RCX_POSTO 
		AND RCL.RCL_FILIAL = RCX.RCX_FILIAL
		AND RCX.RCX_SUBST IN (%exp:Upper(cSubst)%) 
		AND RCX.%notDel% 
	LEFT JOIN %table:SRA% SRA
		ON	RCX.RCX_MATFUN = SRA.RA_MAT 
		AND RCX.RCX_FILFUN = SRA.RA_FILIAL 
		AND SRA.%notDel% 
	LEFT JOIN %table:RD0% RD0
		ON	RCX.RCX_CODOCU = RD0.RD0_CODIGO 
		AND RCX.RCX_FILOCU = RD0.RD0_FILIAL 			
		AND RD0.%notDel% 
	LEFT JOIN %table:SQ3% SQ3
		ON	%exp:cJoinSQ3%
		AND SQ3.Q3_CARGO = RCL.RCL_CARGO 			
		AND SQ3.%notDel% 
	LEFT JOIN %table:SQB% SQB
		ON	%exp:cJoinSQB%
		AND SQB.QB_DEPTO = RCL.RCL_DEPTO 			
		AND SQB.%notDel% 
	LEFT JOIN %table:SRJ% SRJ
		ON	%exp:cJoinSRJ%
		AND SRJ.RJ_FUNCAO = RCL.RCL_FUNCAO 			
		AND SRJ.%notDel% 		
	WHERE 
		RCL.RCL_STATUS IN (%exp:Upper(cStatus)%)
		AND RCL.%notDel%
	ORDER BY 
		%exp:cOrdem%
ENDSQL

//PREPARA RELATORIO PARA EXECUTAR A QUERY GERADA PELO EMBEDDED SQL PASSANDO COMO PARAMETRO A PERGUNTA OU VETOR COM PERGUNTAS 
//DO TIPO RANGE QUE FORAM ALTERADOS PELA FUNCAO MAKESQLEXPR PARA SEREM ADICIONADOS A QUERY
END REPORT QUERY oSection1 PARAM mv_par01, mv_par02, mv_par03

oSection2:SetParentQuery(.T.)
oSection2:SetParentFilter({|cParam|(cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO == cParam },{||(cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO })

oSection3:SetParentQuery(.T.)
oSection3:SetParentFilter( { |cParam| (cAliasQry)->RCX_FILIAL+(cAliasQry)->RCX_POSTO == cParam },{ || (cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_POSTO })

//INICIO DA IMPRESSAO DO FLUXO DO RELATORIO
oReport:SetMeter( (cAliasQry)->(LastRec()) )  

(cAliasQry)->( dbGoTop() )

oSection1:Print()

Return
                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fOrg60Sta ºAutor  ³Tania Bronzeri      º Data ³ 04/12/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona Status de Postos para impressao.       			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAORG                                             	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fOrg60Sta()
Local cTitulo	:=	""
Local MvParDef	:=	""
Local l1Elem 	:= .F. 
Local MvPar		:= ""
Local oWnd
Local cTipoAu
Private aResul	:={}

oWnd := GetWndDefault()
MvPar	:=	&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet	:=	Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

cTitulo := STR0012 //"Imprimir Status de Postos"
aResul  := {STR0013,STR0014,STR0016,STR0015} //"Vago" ### "Ocupado" ### "Congelado" ### "Cancelado"
 
MvParDef	:=	"1234"

f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,04)		// Chama funcao f_Opcoes
&MvRet := mvpar 					   	// Devolve Resultado

Return