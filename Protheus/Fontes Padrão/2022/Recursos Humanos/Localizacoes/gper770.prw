#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER770.CH"
#include "report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER770   ºAutor  ³Rogerio Vaz Melonio º Data ³  09/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatorio de Conferencia do Quadro de Pessoal             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Localizacao Portugal                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  FNC ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alex        ³08/01/10³026193³Adaptacao para a Gestao corporativa       ³±±
±±³            ³        ³ /2009³Respeitar o grupo de campos de filiais.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER770()
Local oReport 
Private cAlias		:= "RGP"

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	Pergunte("GPR770",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                          ³
	//³ mv_par01        //  Da Filial                                 ³
	//³ mv_par02        //  Ate a Filial                              ³
	//³ mv_par03        //  Do Estabelecimento                        ³
	//³ mv_par04        //  Ate o Estabelecimento                     ³
	//³ mv_par05        //  Do IRCT                                   ³
	//³ mv_par06        //  Ate o IRCT                                ³
	//³ mv_par07        //  Matricula De                              ³
	//³ mv_par08        //  Matricula Ate                             ³
	//³ mv_par09        //  Ano/Mes                                   ³
	//³ mv_par10        //  Imprime Historico?                        ³
	//³ mv_par11        //  Somente Diferencas?                       ³
	//³ mv_par12        //  Tipo de Relatorio                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	oReport := ReportDef()
	oReport:PrintDialog()	
EndIF    

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³ Rogerio Vaz Melonioº Data ³  09/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport 
Local oSection1,oSection2,ofontmens
Local cDesc		:= STR0001  // "RELATORIO DE CONFERENCIA DO QUADRO DE PESSOAL "
Local aOrd      := {STR0002,STR0003} // "Matricula"###"Nome"



DEFINE 	REPORT oReport NAME "GPER770" TITLE (OemToAnsi(STR0001)) ;
		PARAMETER "GPR770" ACTION {|oReport| R770Imp(oReport)}   DESCRIPTION OemtoAnsi(STR0016)
		// ###"RELATORIO DE CONFERENCIA DO QUADRO DE PESSOAL "
		// ###"Este relatório exibe informações de funcionários para a declaração do Quadro de Pessoal."

	DEFINE SECTION o1RGP OF oReport
		o1RGP:SetLeftMargin(6)
		o1RGP:SetLineStyle()	// Impressao da descricao e conteudo do campo na mesma linha

		DEFINE CELL NAME "MATRICULA" OF o1RGP TITLE STR0002 SIZE 40 // "Matricula"
		DEFINE CELL NAME "NACION" 	 OF o1RGP TITLE STR0023 SIZE 40 // "Nacionalidade"
		DEFINE CELL NAME "FORMAC" 	 OF o1RGP TITLE STR0024 SIZE 40 // "Formação Escolar"

		DEFINE CELL NAME "NOME" 	 OF o1RGP TITLE STR0003 SIZE 45 // "Nome "
		DEFINE CELL NAME "CATEGO" 	 OF o1RGP TITLE STR0021 SIZE 31 // "Categoria Profissional"
		DEFINE CELL NAME "TIPOCO" 	 OF o1RGP TITLE STR0026 SIZE 30 // "Tipo de Contrato"
		        

		DEFINE CELL NAME "PROMOC" 	 OF o1RGP TITLE STR0019 SIZE 29 // "Data Última Promoção"
		DEFINE CELL NAME "PROFIS" 	 OF o1RGP TITLE STR0022 SIZE 44 // "Profissão"
		DEFINE CELL NAME "REGIME" 	 OF o1RGP TITLE STR0027 SIZE 30 // "Regime Dur. Trabalho"
		                                                           
	
		DEFINE CELL NAME "CONTRO" 	 OF o1RGP TITLE STR0020 SIZE 24 // "Controle Remun. Base"
		DEFINE CELL NAME "SITUAC" 	 OF o1RGP TITLE STR0025 SIZE 32 // "Situaçao na Profissão"
		DEFINE CELL NAME "PERIODO" 	 OF o1RGP TITLE STR0028 SIZE 30 // "Periodo Normal Trabalho"
		

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// oSection2 = usado para fazer a imprimir os campos da tabela RGP
		//"| Vlr.QP   | Remuneração Base | Premios e Subs. Regulares | Valor de Hora Extras | Prestações Irregulares | Horas Normais | Horas Extras "
		//-----------------------------------------------------------------------------------------------------------------------------------------
	DEFINE SECTION o2RGP OF oReport 

		o2RGP:SetLeftMargin(6)

		DEFINE CELL NAME "VERBA" 		OF o2RGP TITLE STR0007 SIZE 15 ALIGN LEFT  // "Verbas"
		DEFINE CELL NAME "REMUBA" 		OF o2RGP TITLE STR0008 SIZE 20 ALIGN RIGHT  PICTURE "@E 999,999.99" // " | Remuneração Base   "
		DEFINE CELL NAME "PREMIO" 		OF o2RGP TITLE STR0009 SIZE 20 ALIGN RIGHT  PICTURE "@E 999,999.99" // " | Prem./Subs.Regul.  "
		DEFINE CELL NAME "TRBSUP" 		OF o2RGP TITLE STR0010 SIZE 20 ALIGN RIGHT  PICTURE "@E 999,999.99" // " | Valor Hora Extra   "
		DEFINE CELL NAME "IRREGU" 		OF o2RGP TITLE STR0011 SIZE 20 ALIGN RIGHT  PICTURE "@E 999,999.99" // " | Prest.Irregulares  "
		DEFINE CELL NAME "HRNORM" 		OF o2RGP TITLE STR0012 SIZE 20 ALIGN RIGHT  PICTURE "@E 999,999.99" // " | Qtd.Horas Normais  "
		DEFINE CELL NAME "HRSUPL" 		OF o2RGP TITLE STR0013 SIZE 20 ALIGN RIGHT  PICTURE "@E 999,999.99" // " | Qtd. Horas Extras  "            

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER770   ºAutor  ³ Rogerio Vaz Melonioº Data ³  09/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R770Imp(oReport)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Declaracao de variaveis                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Objeto
Local o1RGP 	:= oReport:Section(1)
Local o2RGP 	:= oReport:Section(2)
Local o3RGP 	:= oReport:Section(3)
Local o4RGP 	:= oReport:Section(4)
Local o5RGP 	:= oReport:Section(5)
Local o6RGP 	:= oReport:Section(6)
Local iEmp      := 0
Local aQuadro
Local nX, nY
Local nOrdem		:= o1RGP:GetOrder()
Local cOrdem		:= ""

Private aFunc, aTotal
Private aVerba	:= {}
Private cFilProc
Private aListEmp	:= fGetSM0(.T.)

Gpem770Verba()  // Monta o array AVerba com codigo das verbas que serao consideradas na totalizacao de valores do Quadro de Pessoal
				// esta funcao esta no fonte GPEM770.PRW
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz filtro no arquivo...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                          ³
	//³ mv_par01        //  Da Filial                                 ³
	//³ mv_par02        //  Ate a Filial                              ³
	//³ mv_par03        //  Do Estabelecimento                        ³
	//³ mv_par04        //  Ate o Estabelecimento                     ³
	//³ mv_par05        //  Do IRCT                                   ³
	//³ mv_par06        //  Ate o IRCT                                ³
	//³ mv_par07        //  Matricula De                              ³
	//³ mv_par08        //  Matricula Ate                             ³
	//³ mv_par09        //  Ano/Mes                                   ³
	//³ mv_par10        //  Imprime Historico?                        ³
	//³ mv_par11        //  Somente Diferencas?                       ³
	//³ mv_par12        //  Tipo de Relatorio                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilDe 		:= MV_PAR01
cFilAte		:= MV_PAR02
cEstDe 		:= MV_PAR03
cEstAte		:= MV_PAR04
cIrcDe 		:= MV_PAR05
cIrcAte		:= MV_PAR06
cMatDe		:= MV_PAR07
cMatAte		:= MV_PAR08
nAnoMes		:= MV_PAR09

aFilProc := {}

For iEmp := 1 to Len(aListEmp)
	Aadd(aFilProc,{aListEmp[iEmp][SM0_CODFIL],aListEmp[iEmp][SM0_FILIAL]+"-"+aListEmp[iEmp][SM0_NOME],aListEmp[iEmp][SM0_CGC]})
Next iEmp

aAdd(aFilProc,{"02","02-TESTE",""})
dbSelectArea("SRA")
dbSetOrder(1)
dbSelectArea( "RGP" )
#IFDEF TOP
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr("GPR770")
	cAliasRGP	:= GetNextAlias()
	//oSection1:BeginQuery()
	o1RGP:BeginQuery()
	If nOrdem == 1
		cOrdem += "%RGP_FILIAL, RGP_ANOMES, RGP_CODEST, RGP_IRCT, RGP_MATRIC%"
	ElseIf nOrdem == 2
		cOrdem += "%RGP_FILIAL, RGP_ANOMES, RGP_CODEST, RGP_IRCT, RGP_NOME%"
	Endif
	BeginSql alias cAliasRGP
	SELECT RGP.*
	FROM %table:RGP% RGP 
	WHERE	RGP.RGP_FILIAL 	>= %exp:cFilDe%   AND RGP.RGP_FILIAL <= %exp:cFilAte% AND
			RGP.RGP_CODEST	>= %exp:cEstDe%   AND RGP.RGP_CODEST <= %exp:cEstAte% AND
			RGP.RGP_IRCT	>= %exp:cIrcDe%   AND RGP.RGP_IRCT <= %exp:cIrcAte% AND
			RGP.RGP_MATRIC	>= %exp:cMatDe%   AND RGP.RGP_MATRIC <= %exp:cMatAte% AND
			RGP.RGP_ANOMES	 = %exp:nAnoMes% AND	
		  	RGP.%notDel%   
			ORDER BY %exp:cOrdem%
	EndSql
	o1RGP:EndQuery()
#ELSE             
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeAdvplExpr("GPR770")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a ordem selecionada                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOrdem == 1
		cOrdem := "RGP_FILIAL + RGP_ANOMES + RGP_CODEST + RGP_IRCT + RGP_MATRIC"
	ElseIf nOrdem == 2
		cOrdem := "RGP_FILIAL + RGP_ANOMES + RGP_CODEST + RGP_IRCT + RGP_NOME"
	Endif
	cCond	:= '(cAliasRGP)->RGP_FILIAL >= "' 	+ cFilDe	 + '".AND.  (cAliasRGP)->RGP_FILIAL <= "'	+ cFilAte + '".AND.'
	cCond	+= '(cAliasRGP)->RGP_CODEST	>= "' 	+ cEstDe 	 + '".AND. 	(cAliasRGP)->RGP_CODEST	<= "'	+ cEstAte + '".AND.'
	cCond	+= '(cAliasRGP)->RGP_IRCT	>= "' 	+ cIrcDe 	 + '".AND. 	(cAliasRGP)->RGP_IRCT	<= "'	+ cIrcAte + '".AND.'
	cCond	+= '(cAliasRGP)->RGP_MATRIC	>= "' 	+ cMatDe 	 + '".AND. 	(cAliasRGP)->RGP_MATRIC	<= "'	+ cMatAte + '".AND.'
	cCond	+= '(cAliasRGP)->RGP_ANOMES	 = "' 	+ nAnoMes 	 + '"'
  	o1RGP:SetFilter(cCond,cOrdem) 
#ENDIF        


dbSelectArea(cAliasRGP)
dbGoTop()
//-- Define o total da regua da tela de processamento do relatorio
oReport:SetMeter(100)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Iniciando a oSection 1 com o Init()³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nY := 1 To Len(aFilProc)                
    If oReport:nRow>2885
		oReport:EndPage()
    Endif
	cFilAtu := aFilProc[nY][1] // empresa + Filial a processar
	dbSelectArea(cAliasRGP)
		// Processa enquanto for mesma filial + ano + mes
//		While !Eof() .And. (cAliasRGP)->RGP_FILIAL==cFilAtu
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Movimenta Regua Processamento                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Incrementa a régua da tela de processamento do relatório
		  	oReport:IncMeter()
			//-- Verifica se o usuário cancelou a impressão do relatorio
			If oReport:Cancel()
				Exit                                              
			EndIf      
			If (cAliasRGP)->RGP_ANOMES <> nAnoMes
				(cAliasRGP)->( DbSkip() )
				Loop	
			Endif
		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho do Funcionario                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText( STR0004+": "+aFilProc[nY][2], oReport:Row(), 010 )
		oReport:PrintText( Replicate("_",160), oReport:Row(), 010 )
		oReport:SkipLine(2)		
		While !Eof() .And. (cAliasRGP)->RGP_FILIAL==cFilAtu         
			cEstAtu := (cAliasRGP)->RGP_CODEST
			oReport:PrintText(  STR0006+": "+(cAliasRGP)->RGP_CODEST, oReport:Row(), 040 )
			oReport:PrintText( Replicate("_",150), oReport:Row(), 040 )
			oReport:SkipLine(2)		

			While !Eof() .And. (cAliasRGP)->RGP_CODEST==cEstAtu
				cIRCTAtu := (cAliasRGP)->RGP_IRCT                                               
				oReport:PrintText(  STR0005+": "+((cAliasRGP)->RGP_IRCT)+"-"+AllTrim(FDESC("RGD",(cAliasRGP)->RGP_IRCT,"RGD_DESCRI")), oReport:Row(), 070 )				
				oReport:PrintText( Replicate("_",140), oReport:Row(), 070 )
				oReport:SkipLine(1)		

				While !Eof() .And. (cAliasRGP)->RGP_IRCT==cIRCTAtu  
				    If oReport:nRow>2885
						oReport:EndPage()
				    Endif
					aQuadro := {STR0017,0,0,0,0,0,0}
					aTotal := {STR0015,0,0,0,0,0,0} // Total
					aQuadro[2] :=  (cAliasRGP)->RGP_REMUBA
					aQuadro[3] :=  (cAliasRGP)->RGP_PREMIO
					aQuadro[3] :=  (cAliasRGP)->RGP_TRBSUP
					aQuadro[5] :=  (cAliasRGP)->RGP_IRREGU
					aQuadro[6] :=  (cAliasRGP)->RGP_HRNORM
					aQuadro[7] :=  (cAliasRGP)->RGP_HRSUPL	
					aFunc := {}
					GPR770SRD()
					If mv_par11 = 1 // se foi escolhida opcao de imprimr apenas as diferencas
						If (aQuadro[2] == aTotal[2]) .And. (aQuadro[3] == aTotal[3]) .And. (aQuadro[4] == aTotal[4]) .And. (aQuadro[5] == aTotal[5]) ;
							.And. (aQuadro[6] == aTotal[6]) .And. (aQuadro[7] == aTotal[7]) // se o valor que foi gravado no RGP eh igual a soma das verbas no SRD
							(cAliasRGP)->( DbSkip() ) // ignora o registro
							Loop	
						Endif
					Endif
					oReport:SkipLine(1)		
					
					o1RGP:Init()    
					
					o1RGP:Cell("MATRICULA") :SetBlock({|| "  " + ((cAliasRGP)->RGP_MATRIC+Space(40-Len((cAliasRGP)->RGP_MATRIC)))})
					o1RGP:Cell("NOME")      :SetBlock({|| "  " + ((cAliasRGP)->RGP_NOME) 										 })
					o1RGP:Cell("PROMOC")    :SetBlock({|| "  " + (Dtoc((cAliasRGP)->RGP_ULTPRO))	}) //  "Data Última Promoção"
					o1RGP:Cell("CONTRO")	:SetBlock({|| "  " + (x3FieldToCbox("RGP_CONTRO",(cAliasRGP)->RGP_CONTRO)) }) // "Controle Remuneração Base"
					o1RGP:Cell("CATEGO")    :SetBlock({|| "  " + ((cAliasRGP)->RGP_CATEGO)+"-"+AllTrim(FDESC("RGG",(cAliasRGP)->RGP_CATEGO+RGP->RGP_IRCT,"RGG_DESCRI"))}) // "Categoria Profissional"
					o1RGP:Cell("PROFIS")    :SetBlock({|| "  " + ((cAliasRGP)->RGP_CODPRO)+"-"+AllTrim(fDescRCC("S029",(cAliasRGP)->RGP_CODPRO,1,6,7,60))}) // "Profissão"   
					o1RGP:Cell("NACION")    :SetBlock({|| "  " + ((cAliasRGP)->RGP_CODNAC)+"-"+AllTrim(Tabela("34",(cAliasRGP)->RGP_CODNAC))}) // "Nacionalidade"
					o1RGP:Cell("FORMAC")   	:SetBlock({|| "  " + ((cAliasRGP)->RGP_CODHAB)+"-"+AllTrim(fDescRCC("S028",(cAliasRGP)->RGP_CODHAB,1,3,4,60))	}) // "Formação Escolar"
					o1RGP:Cell("SITUAC")	:SetBlock({|| "  " + (x3FieldToCbox("RGP_SITPRO", (cAliasRGP)->RGP_SITPRO)) }) // "Situaçao na Profissão"
					o1RGP:Cell("TIPOCO")    :SetBlock({|| "  " + (x3FieldToCbox("RGP_TIPOCO", (cAliasRGP)->RGP_TIPOCO))}) // "Tipo de Contrato"
					o1RGP:Cell("REGIME")    :SetBlock({|| "  " + (x3FieldToCbox("RGP_REGIME", (cAliasRGP)->RGP_REGIME))}) // "Regime Duração Trabalho"
				   	o1RGP:Cell("PERIODO")   :SetBlock({|| "  " + (Transform((cAliasRGP)->RGP_PERNOR/10,"@R 99.9"))}) // "Periodo Normal Trabalho"
					o1RGP:PrintLine()
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Impressao dos Valores da tabela RGP                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					o2RGP:Init()     
					o2RGP:Cell("VERBA")     :SetBlock({|| STR0018   	})	    // Total Gerado
					o2RGP:Cell("REMUBA")    :SetBlock({|| aQuadro[2]	})	    // Remuneração Base
					o2RGP:Cell("PREMIO")    :SetBlock({|| aQuadro[3]	})	    // Prem./Subs.Regul.
					o2RGP:Cell("TRBSUP")    :SetBlock({|| aQuadro[4]	})	    // Valor Hora Extra
					o2RGP:Cell("IRREGU")    :SetBlock({|| aQuadro[5]	})	    // Prest.Irregulares
					o2RGP:Cell("HRNORM")    :SetBlock({|| aQuadro[6]	})	    // Qtd.Horas Normais
					o2RGP:Cell("HRSUPL")    :SetBlock({|| aQuadro[7]	})	    // Qtd. Horas Extras
					o2RGP:PrintLine()

					If mv_par10 = 1 // se foi selecionada opcao para imprimir historico          
						oReport:SkipLine(1)						
						oReport:PrintText( STR0029, oReport:Row(), 100 )//Historico de Movimentos
						oReport:SkipLine(1)						
						oReport:PrintText( Replicate("-",Len(Alltrim(STR0029))), oReport:Row(), 100 )						
						oReport:SkipLine(1)							
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Impressao dos Valores da tabela SRD                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nX := 1 to Len(aFunc)
							o2RGP:Cell("VERBA")     :SetBlock({|| aFunc[nX][1]	})	    // Verba
							o2RGP:Cell("REMUBA")    :SetBlock({|| aFunc[nX][2]	})	    // Remuneração Base
							o2RGP:Cell("PREMIO")    :SetBlock({|| aFunc[nX][4]	})	    // Prem./Subs.Regul. // ordem invertida
							o2RGP:Cell("TRBSUP")    :SetBlock({|| aFunc[nX][3]	})	    // Valor Hora Extra  // ordem invertida
							o2RGP:Cell("IRREGU")    :SetBlock({|| aFunc[nX][5]	})	    // Prest.Irregulares
							o2RGP:Cell("HRNORM")    :SetBlock({|| aFunc[nX][6]	})	    // Qtd.Horas Normais
							o2RGP:Cell("HRSUPL")    :SetBlock({|| aFunc[nX][7]	})	    // Qtd. Horas Extras
							o2RGP:PrintLine() 
						Next nX

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Impressao dos Totais de cada coluna do SRD                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aFunc)>1
							o2RGP:Cell("VERBA")     :SetBlock({|| aTotal[1]	})	    // Total
							o2RGP:Cell("REMUBA")    :SetBlock({|| aTotal[2]	})	    // Remuneração Base
							o2RGP:Cell("PREMIO")    :SetBlock({|| aTotal[4]	})	    // Prem./Subs.Regul. // ordem invertida
							o2RGP:Cell("TRBSUP")    :SetBlock({|| aTotal[3]	})	    // Valor Hora Extra  // ordem invertida
							o2RGP:Cell("IRREGU")    :SetBlock({|| aTotal[5]	})	    // Prest.Irregulares
							o2RGP:Cell("HRNORM")    :SetBlock({|| aTotal[6]	})	    // Qtd.Horas Normais
							o2RGP:Cell("HRSUPL")    :SetBlock({|| aTotal[7]	})	    // Qtd. Horas Extras
							o2RGP:PrintLine()                                       
						Endif	
						o2RGP:Finish()						
						// Impressao da oSection4 ou seja do corpo do relatorio.
						oReport:SkipLine(1)					
						oReport:PrintText( Replicate("=",140), oReport:Row(), 090 )						
						oReport:SkipLine(1)
					Endif
					
					    
					DbSelectArea(cAliasRGP)
					(cAliasRGP)->(DbSkip())
				Enddo
				oReport:SkipLine(1)					
				oReport:PrintText( Replicate("_",150), oReport:Row(), 040 )						
				oReport:SkipLine(2)
			Enddo
		Enddo
Next
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPR770SRD ºAutor  ³ Rogerio Vaz Melonioº Data ³  09/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca as verbas que geraram os valores da tabela RGP       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPR770SRD()
Local nX
cFil := (cAliasRGP)->RGP_FILIAL
cMat := (cAliasRGP)->RGP_MATRIC
SRA->(dbSeek(cFil+cMat))
aAreaRGP := GetArea()
dbSelectArea("SRD")
#IFDEF TOP
	lQuery 		:= .T.
	cAliasSRD 	:= "qPessoalSRD"
	aStru  		:= SRD->(dbStruct())
	cQuery 		:= "SELECT * "		
	cQuery 		+= " FROM "+	RetSqlName("SRD")
	cQuery 		+= " WHERE RD_FILIAL  IN ('" + cFil + "',' ')"
	cQuery 		+= " AND RD_MAT     = '" + cMat+ "'"
	cQuery 		+= " AND RD_ROTEIR IN('FOL','NAT')"
	cQuery 		+= " AND RD_DATARQ = '"+nAnoMes+"'"
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
	(cAliasSRD)->(MsSeek((cAliasRGP)->RGP_FILIAL+(cAliasRGP)->RGP_MATRIC+nAnoMes,.T.))
#ENDIF
While (cAliasSRD)->(!Eof()) .And. (( (cAliasSRD)->RD_FILIAL+(cAliasSRD)->RD_MAT == (cAliasRGP)->RGP_FILIAL+(cAliasRGP)->RGP_MATRIC ).OR.;
 ( (cAliasSRD)->RD_FILIAL+(cAliasSRD)->RD_MAT == "  "+(cAliasRGP)->RGP_MATRIC ))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Despreza os lanctos sem correspondencia de valor no quadro de pessoal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If Ascan(aVerba,{|X| X[1] == (cAliasSRD)->RD_PD } ) == 0
		(cAliasSRD)->( dbSkip() )
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Despreza os lanctos de transferencias de outras empresas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If (cAliasSRD)->RD_EMPRESA # cEmpAnt .And. !Empty((cAliasSRD)->RD_EMPRESA)
		(cAliasSRD)->( dbSkip() )
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Despreza os tipos de roteiros diferentes de FOL/NAT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( (cAliasSRD)->RD_ROTEIR  $ "FOL/NAT" )
		(cAliasSRD)->( dbSkip() )
		Loop
	EndIf
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Esta função buscará os valores das verbas no acumulado,      ³
	//³e suas incidências, e as guardará no array afun, para gravar ³
	//³posteriormente na tabelas RGP.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona a Verba no SRV³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PosSrv((cAliasSRD)->RD_PD,xFilial("SRV"))
	If ! SRV->( eof() ) // se achou verba no SRV
		aAdd(aFunc,Array(7))
		n := Len(aFunc)
		aFunc[n][1] := (cAliasSRD)->RD_PD+"-"+Substr(SRV->RV_DESC,1,20)
		aFunc[n][2] := aFunc[n][3] := aFunc[n][4] := aFunc[n][5] := aFunc[n][6] := aFunc[n][7] := 0
		// [1] Verba,[2] Vlr Base,[3] Vlr. Horas Extras,[4] Premios Regulares,[5] Prestacoes Irregulares,[6] Horas Normais,[7] Horas Extras
		nFator := IIf(SRV->RV_TIPOCOD='1',1,-1)
		nVal :=	(cAliasSRD)->RD_VALOR * nFator
		If SRA->RA_CATFUNC = 'M' // se eh mensalista converte dias para horas
			nRef := (cAliasSRD)->RD_HORAS * (SRA->RA_HRSMES/30) * nFator
		ElseIf SRA->RA_CATFUNC = 'H' // se eh horista 
			nRef := (cAliasSRD)->RD_HORAS * nFator
		Else
			nRef := 0
		Endif
		If SRV->RV_REMUNQP == '01' // Valor Base
			aFunc[n][2] := nVal // Valor Base 
			aFunc[n][6] := nRef // Horas Normais ref. ao Valor Base
		ElseIf SRV->RV_REMUNQP == '02' // Horas Extras (Trabalho Suplementar)
			aFunc[n][3] := nVal // Valor de Horas extras
			aFunc[n][7] := nRef // Horas Extras ref. ao Valor de Horas Extras
		ElseIf SRV->RV_REMUNQP == '03' // Premios e Subsidios Regulares
			aFunc[n][4] := nVal // Valor de Premios e Subsidios Regulares
		ElseIf SRV->RV_REMUNQP == '04' // Prestacoes Irregulares
			aFunc[n][5] := nVal // Valor de Prestacoes Irregulares
		Else // Demais verbas que compoem horas do quadro de pessoal
			If SRV->RV_HORASQP == '1' // Se a verba compoe as horas do Quadro de Pessoal
				If SRV->RV_HE = "S"
					aFunc[n][3] := nVal // Valor de Horas extras
					aFunc[n][7] := nRef // Horas Extras
				Else
					aFunc[n][2] := nVal // Valor Base 
					aFunc[n][6] := nRef // Horas Normais
				Endif
			Endif
		Endif
		aTotal[2] += aFunc[n][2] // Valor Base 
		aTotal[3] += aFunc[n][3] // Valor de Horas extras
		aTotal[4] += aFunc[n][4] // Valor de Premios e Subsidios Regulares
		aTotal[5] += aFunc[n][5] // Valor de Prestacoes Irregulares
		aTotal[6] += aFunc[n][6] // Horas Normais
		aTotal[7] += aFunc[n][7] // Horas Extras
	Endif
	(cAliasSRD)->( dbSkip())
Enddo
#IFDEF TOP
	dbSelectArea(cAliasSRD)
	dbCloseArea()
#ENDIF    
RestArea(aAreaRGP)
Return