#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER790.CH"
#include "report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER790   บAutor  ณAbel Ap. Ribeiro    บ Data ณ  09/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Relatorio de Conferencia do IRS                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Portugal                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณFrancisco Jrณ04/01/09ณ031142ณCompatibilizacao para Gestao Corporativa  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPER790()
Local oReport 
Private cAlias		:= "RGO"

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	Pergunte("GPR790",.F.)
   	oReport := ReportDef()
	oReport:PrintDialog()	
EndIF    

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณ Rogerio Vaz Melonioบ Data ณ  09/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()
Local oReport 
Local oSection1,oSection2,oSection3
Local cDesc		:= STR0001                   // "Relatorio de Conferencia Declara็ใo IRS"
Local aOrd      := {STR0002,STR0003}         // "Matricula"###"Nome"
DEFINE 	REPORT oReport NAME "GPER790" TITLE (OemToAnsi(STR0001)) + " " + STR(MV_PAR09,4)  ;
		PARAMETER "GPR790" ACTION {|oReport| R790Imp(oReport)}   DESCRIPTION OemtoAnsi(STR0014)
		// ###"Relatorio de Conferencia do IRS""###"Este relat๓rio exibe informa็๕es de funcionแrios para a declara็ใo do IRS."
	DEFINE SECTION o1RGP OF oReport ORDERS aOrd TABLES "RGO" 
		o1RGP:SetLineStyle()	// Impressao da descricao e conteudo do campo na mesma linha
		
		//------------------------------------------------------------------
		// oSection1 = usado para montar o cabe็alho do relatorio
		// "Filial"###"Matricula :"###"Nome :"###"Estabelecimento"###"Categoria
		//------------------------------------------------------------------
		DEFINE CELL NAME "FILIAL" 	 OF o1RGP TITLE STR0004 SIZE 10 // "Filial "
		DEFINE CELL NAME "MATRICULA" OF o1RGP TITLE STR0002 SIZE 20 // "Matricula"
		DEFINE CELL NAME "NOME" 	 OF o1RGP TITLE STR0003 SIZE 40 // "Nome "
		DEFINE CELL NAME "CAT"   	 OF o1RGP TITLE STR0005 SIZE 30 // "Categoria "
		
		//-----------------------------------------------------------------------------------------------------------------------------------
		// oSection2 = usado para fazer a imprimir os campos da tabela RGO
		//"| Verba   | Tipo Ren. | Vlr.Rendimentos  |          Valor Retido     | Valor Desconto Obrig.| Valor Quotiza็oes Sind. | Valores Isentos IRS  "
		//-----------------------------------------------------------------------------------------------------------------------------------
        DEFINE SECTION o2RGP OF oReport   TOTAL IN COLUMN
        	o2RGP:SetHeaderSection(.F.)
        	
   		If mv_par10 = 1 // se imprime historico
			DEFINE CELL NAME "VERBA" 		OF o2RGP TITLE STR0006 SIZE 15 ALIGN LEFT  // "| Verba "
		Else
			DEFINE CELL NAME "VERBA" 		OF o2RGP TITLE STR0014 SIZE 15 ALIGN LEFT  // "TOTAL GERADO"
		Endif                         

        DEFINE CELL NAME "TIPOREN" 		OF o2RGP TITLE STR0016 SIZE 05 ALIGN CENTER PICTURE "@!"              // " | Tipo Rend. "
		DEFINE CELL NAME "VLRREND" 		OF o2RGP TITLE STR0007 SIZE 10 ALIGN RIGHT  PICTURE "@E 999,999,999.99" // " | Vlr.Rendimentos    "
		DEFINE CELL NAME "VLRRETI" 		OF o2RGP TITLE STR0008 SIZE 15 ALIGN RIGHT  PICTURE "@E 999,999,999.99" // " | Valor Retido       "
		DEFINE CELL NAME "VLRDESO" 		OF o2RGP TITLE STR0009 SIZE 25 ALIGN RIGHT  PICTURE "@E 999,999,999.99" // " | Valor Desc. Obrig. "
        DEFINE CELL NAME "VLRQSIN" 		OF o2RGP TITLE STR0010 SIZE 20 ALIGN RIGHT  PICTURE "@E 999,999,999.99" // " | Valor Quotiz.Sind. "
		DEFINE CELL NAME "VLRISEN" 		OF o2RGP TITLE STR0011 SIZE 05 ALIGN RIGHT  PICTURE "@E 999,999,999.99" // " | Valor Rem.Isenta IRS "
        
        //-----------------------------------------------------------------------------------------------------------------------------------
		// oSection3 = usado para fazer a imprimir somente o cabecalho
		//"| Verba   | Tipo Ren. | Vlr.Rendimentos  |          Valor Retido     | Valor Desconto Obrig.| Valor Quotiza็oes Sind. | Valores Isentos IRS  "
		//-----------------------------------------------------------------------------------------------------------------------------------
	    
        DEFINE SECTION o3RGP OF oReport 
		
		If mv_par10 = 1 // se imprime historico
			DEFINE CELL NAME "VERBA" 	OF o3RGP TITLE STR0006 SIZE 15 ALIGN LEFT  // "| Verba "
		Else
			DEFINE CELL NAME "VERBA" 	OF o3RGP TITLE STR0014 SIZE 15 ALIGN LEFT  // "TOTAL GERADO"
		Endif

		DEFINE CELL NAME "TIPOREN" 		OF o3RGP TITLE STR0016 SIZE 10 ALIGN RIGHT  // " | Tipo Rend. "
		DEFINE CELL NAME "VLRREND" 		OF o3RGP TITLE STR0007 SIZE 20 ALIGN RIGHT  // " | Vlr.Rendimentos    "
		DEFINE CELL NAME "VLRRETI" 		OF o3RGP TITLE STR0008 SIZE 20 ALIGN RIGHT  // " | Valor Retido       "
		DEFINE CELL NAME "VLRDESO" 		OF o3RGP TITLE STR0009 SIZE 20 ALIGN RIGHT  // " | Valor Desc. Obrig. "
        DEFINE CELL NAME "VLRQSIN" 		OF o3RGP TITLE STR0010 SIZE 20 ALIGN RIGHT  // " | Valor Quotiz.Sind. "
		DEFINE CELL NAME "VLRISEN" 		OF o3RGP TITLE STR0011 SIZE 20 ALIGN RIGHT  // " | Valor Rem.Isenta IRS "
        

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR790IMP      บAutor  ณ Abel Ap. Ribeiroบ Data ณ  09/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R790Imp(oReport)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Declaracao de variaveis                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//-- Objeto
Local oSection1 	:= oReport:Section(1)
Local oSection2 	:= oReport:Section(2)
Local oSection3 	:= oReport:Section(3)

Local aQuadro
Local nX, nY
Local nOrdem		:= oSection1:GetOrder()
Local cOrdem		:= ""  
Local lPri          := .T.
Private aFunc, aTotal
Private aVerba	:= {}
Private cFilProc

Gpem790Verba()  // Monta o array aVerba com codigo das verbas que serao consideradas na totalizacao 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz filtro no arquivo...                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                          ณ
//ณ mv_par01        //  Da Filial                                 ณ
//ณ mv_par02        //  Ate a Filial                              ณ
//ณ mv_par03        //  Matricula De                              ณ
//ณ mv_par04        //  Matricula Ate                             ณ
//ณ mv_par05        //  Nome De                                   ณ
//ณ mv_par06        //  Nome At้                                  ณ
//ณ mv_par07        //  Mes De                                    ณ
//ณ mv_par08        //  Mes Ate                                   ณ
//ณ mv_par09        //  Ano Base                                  ณ
//ณ mv_par10        //  Imprime Historico?                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cFilDe 		:= MV_PAR01
cFilAte		:= MV_PAR02
cMatDe		:= MV_PAR03
cMatAte		:= MV_PAR04
cNomeDe		:= MV_PAR05
cNomeAte	:= MV_PAR06
cMesDe	    := MV_PAR07
cMesAte     := MV_PAR08                
cAno        := STR(MV_PAR09,4)

cDtPesqI    := StrZero(MV_PAR09, 4 )+ cMesDe
cDtPesqF    := Strzero(MV_PAR09, 4 )+ cMesAte          

aFilProc := {}
dbSelectArea("SM0")
cEmpFilOld := CNUMEMP
cEmpFilAtu := CEMPANT + cFilDe
dbSeek(cEmpFilAtu,.T.)    // Indice M0_CODIGO + M0_CODFIL
While !Eof() .And. SM0->M0_CODIGO+FWGETCODFILIAL <= CEMPANT+cFilAte
	aAdd(aFilProc,{FWGETCODFILIAL,SM0->M0_FILIAL+"/"+SM0->M0_NOME+"/"+M0_NOMECOM,SM0->M0_CGC})
	dbSkip()
EndDo

dbSelectArea("SRA")
dbSetOrder(1)
dbSelectArea( "RGO" )
#IFDEF TOP
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr("GPR790")
	cAliasRGO	:= GetNextAlias()
	oSection1:BeginQuery()

	cOrdem += "%RGO_FILIAL, RGO_MAT%"


	BeginSql alias cAliasRGO                                            
	SELECT DISTINCT RGO.RGO_FILIAL,RGO.RGO_MAT,RGO.RGO_ANO,RGO_TIPREN,RGO.RGO_VLRREN,RGO.RGO_VLRRET,RGO.RGO_QUOTSI,RGO.RGO_VLISEN,RGO.RGO_DESOBR,SRA.RA_NOME,SRA.RA_CATFUNC
	FROM %table:RGO% RGO
	INNER JOIN %table:SRA% SRA ON 
    RGO.RGO_FILIAL   = SRA.RA_FILIAL 
    AND RGO.RGO_MAT  = SRA.RA_MAT

	WHERE	RGO.RGO_FILIAL 	 >= %exp:cFilDe%   AND RGO.RGO_FILIAL <= %exp:cFilAte% AND
			RGO.RGO_MAT  	 >= %exp:cMatDe%   AND RGO.RGO_MAT    <= %exp:cMatAte% AND
			SRA.RA_NOME      >= %exp:cNomeDe%  AND SRA.RA_NOME    <= %exp:cNomeAte% AND
   		    RGO.RGO_ANO 	 = %exp:cANO% AND	
		  	RGO.%notDel%   
			ORDER BY %exp:cOrdem%
	EndSql                                                                 
	oSection1:EndQuery()
#ELSE             
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeAdvplExpr("GPR790")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a ordem selecionada                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If nOrdem == 1
		cOrdem += "%RA_FILIAL, RA_MAT%"
	ElseIf nOrdem == 2
		cOrdem += "%RA_FILIAL, RA_NOME%"
	Endif
	cCond	:= '(cAliasRGO)->RGO_FILIAL >= "' 	+ cFilDe	 + '".AND.  (cAliasRGO)->RGO_FILIAL <= "'	+ cFilAte + '".AND.'
	cCond	+= '(cAliasRGO)->RGO_MAT	>= "' 	+ cMatDe 	 + '".AND. 	(cAliasRGO)->RGO_MAT	<= "'	+ cMatAte + '".AND.'
	cCond	+= '(cAliasRGO)->RA_NOME	>= "' 	+ cNomeDe 	 + '".AND. 	(cAliasRGO)->RGO_NOME	<= "'	+ cNomeAte + '".AND.'
	cCond	+= '(cAliasRGO)->RGO_ANO	 = "' 	+ cANO   	 + '"'
  	oSection1:SetFilter(cCond,cOrdem) 
#ENDIF
dbSelectArea(cAliasRGO)
dbGoTop()
//-- Define o total da regua da tela de processamento do relatorio
oReport:SetMeter(100)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIniciando a oSection 1 com o Init()ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1:Init()
For nY := 1 To Len(aFilProc)
	cFilAtu := aFilProc[nY][1] // empresa + Filial a processar
	dbSelectArea(cAliasRGO)
		// Processa enquanto for mesma filial + ano + mes

	    cMatAnt := ""
        
			
		While !Eof() .And. (cAliasRGO)->RGO_FILIAL+(cAliasRGO)->RGO_ANO <= cFilAtu+cANO
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Movimenta Regua Processamento                                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//-- Incrementa a r้gua da tela de processamento do relat๓rio
		  	
		  	oReport:IncMeter()            
		  	
			//-- Verifica se o usuแrio cancelou a impressใo do relatorio

			If oReport:Cancel()
				Exit
			EndIf      
			If (cAliasRGO)->RGO_ANO <> cANO
				(cAliasRGO)->( DbSkip() )
				Loop	
			Endif
			
			
			aQuadro    := {STR0015,0,0,0,0,0,0}
			aTotal     := {STR0012,0,0,0,0,0,0} // Total
			aQuadro[1] :=  (cAliasRGO)->RGO_TIPREN
			aQuadro[2] :=  (cAliasRGO)->RGO_VLRREN
			aQuadro[3] :=  (cAliasRGO)->RGO_VLRRET
			aQuadro[4] :=  (cAliasRGO)->RGO_DESOBR
			aQuadro[5] :=  (cAliasRGO)->RGO_QUOTSI
			aQuadro[6] :=  (cAliasRGO)->RGO_VLISEN
			
			aFunc := {}
			
			GPR790SRD()

			IF  (cAliasRGO)->RGO_MAT <> cMatAnt 
			   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			   //ณ Impressao do Cabecalho do Funcionario                        ณ
			   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			   oSection1:Cell("FILIAL")   :SetBlock({|| ((cAliasRGO)->RGO_FILIAL)	})
			   oSection1:Cell("MATRICULA"):SetBlock({|| ((cAliasRGO)->RGO_MAT)  	})
			   oSection1:Cell("NOME")     :SetBlock({|| SRA->RA_NOME 	 })
			   oSection1:Cell("CAT")      :SetBlock({|| SRA->RA_CATFUNC + " - "+fDesc("SX5","28"+SRA->RA_CATFUNC,"X5DESCRI()",11,SRA->RA_FILIAL)})

			   // Faz a impressao da oSection1 ou seja do cabe็alho do funcionario.
			   oReport:SkipLine(-2)
			   
			   oSection1:PrintLine()
			       
			   oReport:SkipLine(1)
			   oReport:PrintText(REPLICATE("_",139),oReport:Row(),oReport:Col())
			   oReport:SkipLine(1)
			                                                                       
			   oReport:PrintText(STR0006+STR0016+STR0007+STR0008+STR0009+STR0010+STR0011,oReport:Row(),oReport:Col())
               oReport:SkipLine(1)
			   oReport:PrintText(REPLICATE("_",139),oReport:Row(),oReport:Col())
               oReport:SkipLine(1)
			  
			ENDIF
            
            oSection2:Init()               
            oReport:SkipLine(-1)
			                   
            oSection2:Cell("VERBA")      :SetBlock({|| STR0014	})	        // TOTAL GERADO
			
			oSection2:Cell("TIPOREN")    :SetBlock({|| aQuadro[1]	})	    // Vlr.Rendimentos    "
		    
            If mv_par10 == 1
               oSection2:Cell("TIPOREN"):HIDE()	                            // TIPO Rendimento
            ELSE
               oSection2:Cell("TIPOREN"):SHOW()	                            // TIPO Rendimento
            ENDIF                              
                        
		    oSection2:Cell("VLRREND")    :SetBlock({|| aQuadro[2]	})	    // Vlr.Rendimentos    "
		    oSection2:Cell("VLRRETI")    :SetBlock({|| aQuadro[3]	})	    // Valor Retido       "
		    oSection2:Cell("VLRDESO")    :SetBlock({|| aQuadro[4]	})	    // Valor Desconto Obrig."
		    oSection2:Cell("VLRQSIN")    :SetBlock({|| aQuadro[5]	})	    // Valor quotiza็oes Sind. "
		    oSection2:Cell("VLRISEN")    :SetBlock({|| aQuadro[6]	})	    // Valor Rem.Isenta IRS "
		    oSection2:PrintLine()
          
			If mv_par10 == 1 // se foi selecionada opcao para imprimir historico
			   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			   //ณ Impressao dos Valores da tabela SRD                          ณ
			   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
			   
			   oReport:SkipLine(1)
			   oReport:PrintText(STR0015,oReport:Row(),oReport:Col())
			   oReport:SkipLine(1)
			   
               oReport:PrintText(replicate("=",LEN(STR0015)),oReport:Row(),oReport:Col())
			   oReport:SkipLine(2)
			                                                                                                                                
			   For nX := 1 to Len(aFunc) 
			        oSection2:Cell("VERBA")          :SetBlock({|| aFunc[nX][1]	})	    // Verba
			        oSection2:Cell("VLRREND")        :SetBlock({|| aFunc[nX][2]	})	    // Vlr.Rendimentos    "
			        oSection2:Cell("VLRRETI")        :SetBlock({|| aFunc[nX][3] })	    // Valor Retido       "
			        oSection2:Cell("VLRDESO")        :SetBlock({|| aFunc[nX][4]	})	    // Valor Desconto Obrig."
			        oSection2:Cell("VLRQSIN")        :SetBlock({|| aFunc[nX][5]	})	    // Valor quotiza็oes Sind. "
			        oSection2:Cell("VLRISEN")        :SetBlock({|| aFunc[nX][6]	})	    // Valor Rem.Isenta IRS "
					oSection2:PrintLine()
				Next nX          
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Impressao dos Totais de cada coluna do SRD                   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				 IF Len(aFunc) > 1     
				    oReport:SkipLine(1)
					oSection2:Cell("VERBA")      :SetBlock({|| STR0012 })   	    // Total 
			        oSection2:Cell("VLRREND")    :SetBlock({|| aTotal[2]	})	    // Vlr.Rendimentos    "
			        oSection2:Cell("VLRRETI")    :SetBlock({|| aTotal[3]    })	    // Valor Retido       "
			        oSection2:Cell("VLRDESO")    :SetBlock({|| aTotal[4]    })	    // Valor Desconto Obrig."
			        oSection2:Cell("VLRQSIN")    :SetBlock({|| aTotal[5]	})	    // Valor quotiza็oes Sind. "
			        oSection2:Cell("VLRISEN")    :SetBlock({|| aTotal[6]	})	    // Valor Rem.Isenta IRS "
				    oSection2:PrintLine()
				 endif   
				    oReport:PrintText(replicate("=",138),oReport:Row(),oReport:Col())
				    oReport:SkipLine(2)
			   
				    // Impressao da oSection2 ou seja do corpo do relatorio.
          ENDIF
          
          	cMatAnt := (cAliasRGO)->RGO_MAT
			oSection2:Finish()
		
			oReport:SkipLine()
			oReport:ThinLine()
			dbSelectArea(cAliasRGO)
			dbSkip()
		Enddo
Next
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza impressao inicializada pelo metodo Init             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1:Finish()
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPR790SRD บAutor  ณ Abel Ap. Ribeiroบ Data ณ  09/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca as verbas que geraram os valores da tabela RGO       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPR790SRD()
Local nX
cFil := (cAliasRGO)->RGO_FILIAL
cMat := (cAliasRGO)->RGO_MAT
SRA->(dbSeek(cFil+cMat))
aAreaRGO := GetArea()
dbSelectArea("SRD")
#IFDEF TOP
	lQuery 		:= .T.
	cAliasSRD 	:= "IRSSRD"
	aStru  		:= SRD->(dbStruct())
	cQuery 		:= "SELECT * "		
	cQuery 		+= " FROM "+	RetSqlName("SRD")
	cQuery 		+= " WHERE RD_FILIAL  ='" + cFil + "'"
	cQuery 		+= " AND RD_MAT     = '" + cMat+ "'"
	cQuery 		+= " AND RD_ROTEIR IN('FOL','NAT')"
	cQuery 		+= " AND RD_DATARQ BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"'" 
	cQuery 		+= " AND D_E_L_E_T_ = ' ' "
	cQuery 		+= "ORDER BY "+SqlOrder(SRD->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD,.T.,.T.)
	For nX := 1 To len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
			TcSetField(cAliasSRD,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
	dbSelectArea(cAliasSRD)	
#ELSE
	cAliasSRD 	:= "SRD"
	(cAliasSRD)->(MsSeek((cAliasRGO)->RGO_FILIAL+(cAliasRGO)->RGO_MAT+cANO,.T.))
#ENDIF

While (cAliasSRD)->(!Eof()) .And. (cAliasSRD)->RD_FILIAL+(cAliasSRD)->RD_MAT == (cAliasRGO)->RGO_FILIAL+(cAliasRGO)->RGO_MAT
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDespreza os lanctos sem correspondencia de valor no quadro de pessoal ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	If Ascan(aVerba,{|X| X[1] == (cAliasSRD)->RD_PD } ) == 0
		(cAliasSRD)->( dbSkip() )
		Loop
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDespreza os lanctos de transferencias de outras empresasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	If (cAliasSRD)->RD_EMPRESA # cEmpAnt .And. !Empty((cAliasSRD)->RD_EMPRESA)
		(cAliasSRD)->( dbSkip() )
		Loop
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDespreza os tipos de roteiros diferentes de FOL/NATณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If empty((cAliasSRD)->RD_PD)
		(cAliasSRD)->( dbSkip() )
		Loop
	EndIf                      
	If empty((cAliasSRD)->RD_DATARQ)
		(cAliasSRD)->( dbSkip() )
		Loop
	EndIf
	If empty((cAliasSRD)->RD_DATPGT)
		(cAliasSRD)->( dbSkip() )
		Loop
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEsta fun็ใo buscarแ os valores das verbas no acumulado,      ณ
	//ณe suas incid๊ncias, e as guardarแ no array afun, para gravar ณ
	//ณposteriormente na tabelas RGO.                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona a Verba no SRVณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู      
	
	Posicione("SRV",1,xFilial("SRV")+(cAliasSRD)->RD_PD,"RV_DESC")
    

	If ! SRV->( eof() ) // se achou verba no SRV
		aAdd(aFunc,Array(7))
		n := Len(aFunc)

		aFunc[n][1] := (cAliasSRD)->RD_PD+"-"+Substr(SRV->RV_DESC,1,20)
		aFunc[n][2] := aFunc[n][3] := aFunc[n][4] := aFunc[n][5] := aFunc[n][6] := aFunc[n][7] := 0

		// [1] Verba, [2] Vlr.Rendimento,[3] Vlr Retido,[4] Vlr. Desc.Obrig.,[5] Quotiza็oes Sindicais,[6] Rem.Isentas IRS

		
		nVal   := (cAliasSRD)->RD_VALOR 
		
		IF  ALLTRIM(SRV->RV_DIRF) == '1'     // Rendimentos
			aFunc[n][2] := nVal              // Valor dos Rendimentos 
		ElseIf ALLTRIM(SRV->RV_DIRF) == '2'  // Reten็ใo
			aFunc[n][3] := nVal              // Valor de IRS Retido
		ElseIf ALLTRIM(SRV->RV_DIRF) == '3'  // Descontos Obrigat๓rios
			aFunc[n][4] := nVal              // Valor de Descontos Obrigat๓rios
		ElseIf ALLTRIM(SRV->RV_DIRF) == '4'  // Quaotiza็๕es Sindicais
			aFunc[n][5] := nVal              // Valor das Quotiza็๕es 
		ElseIf ALLTRIM(SRV->RV_DIRF) == '5'  // Remunera็๕es Isentas IRS
			aFunc[n][6] := nVal              // Valor Remun. ISentas de IRS 
		Endif
		aTotal[2] += aFunc[n][2] // Valor Rendimentos 
		aTotal[3] += aFunc[n][3] // Valor de IRS Retido
		aTotal[4] += aFunc[n][4] // Valor de Descontos Obrigatorios
		aTotal[5] += aFunc[n][5] // Valor de Quotiza็๕es Sindicais
		aTotal[6] += aFunc[n][6] // Remunera็๕es Isentas de IRS
	Endif
	(cAliasSRD)->( dbSkip())
Enddo
#IFDEF TOP
	dbSelectArea(cAliasSRD)
	dbCloseArea()
#ENDIF    
RestArea(aAreaRGO)
Return
/*/
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFun…o    ณGpem770Verba ณAutorณ Abel Ap. Ribeiro    ณDataณ22/08/2008ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescri…o ณInicializa o array de Verbas   								ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ<Vide Parametros Formais>									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ<Vide Parametros Formais>									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Function Gpem790Verba()
dbSelectArea("SRV")
dbGoTop()
While ! Eof()
	If !SRV->RV_TIPOCOD $ '1/2' // Se nao eh provento nem desconto, desconsidera a verba
		dbSkip()
		Loop
	Endif
	If  Empty(SRV->RV_DIRF)     // sE O CAMPO rv_dirf NAO ESTIVER PREENCHIDO
		dbSkip()
		Loop
	Endif
	aAdd(aVerba,{SRV->RV_COD})
	dbSkip()
EndDo
