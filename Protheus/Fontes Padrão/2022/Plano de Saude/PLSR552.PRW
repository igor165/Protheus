#INCLUDE "PLSR552.CH"
#INCLUDE "PROTHEUS.CH"         

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PLSR552  ³ Autor ³ TOTVS                 ³ Data ³ 19/03/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de atendimentos importados - Ressarcimento SUS     ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPLS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION PLSR552()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	If ValType(oReport) <> "O"
		Return NIL	
	EndIf
	oReport:PrintDialog()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄ--ÄÄÄÄÄ¿±±±
±±³Funcao    ³ReportDef ³ Autor ³TOTVS                ³ Data ³ 19/03/2013 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄ--ÄÄÄ´±±±
±±³Descricao ³                                                            ³±±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR552()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±                             
±±³ Uso      ³ SIGAPLS                                                    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function ReportDef()

Local oReport, oAtend, oProced 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport := TReport():New("PLSR552",STR0001,"PLR552",{|oReport| ReportPrint(oReport,oAtend, oProced)},STR0002) //"Ressarcimento SUS"##"Atendimentos importados"
oReport:SetLandscape()

Pergunte("PLR552",.F.)  
  
oAtend := TRSection():New(oReport,"Ressarcimento",{"TRB"},{"TESTE"},/*Campos do SX3*/,/*Campos do SIX*/) //
oAtend:SetTotalInLine(.F.)
TRCell():New(oAtend,"IDANS"    ,"B0R",STR0003,/*Picture*/       ,015,/*lPixel*/,/*{|| code-block de impressao }*/) //"Ident. ANS."
TRCell():New(oAtend,"OFICIO"   ,"B0R",STR0004,/*Picture*/       ,006,/*lPixel*/,/*{|| code-block de impressao }*/) //"N. Oficio"
TRCell():New(oAtend,"NUMPRO"   ,"B0R",STR0005,/*Picture*/       ,012,/*lPixel*/,/*{|| code-block de impressao }*/) //"Num.Processo"
TRCell():New(oAtend,"CODIGO"   ,"B0R",STR0006,/*Picture*/       ,008,/*lPixel*/,/*{|| code-block de impressao }*/) //"Atendimento"
TRCell():New(oAtend,"STATUS"   ,"B0R",STR0007,/*Picture*/       ,020,/*lPixel*/,/*{|| code-block de impressao }*/) //"Status"
TRCell():New(oAtend,"CODCCO"   ,"B0R",STR0008,/*Picture*/       ,013,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cod. CCO"
TRCell():New(oAtend,"BENEFI"   ,"B0R",STR0009,/*Picture*/       ,030,/*lPixel*/,/*{|| code-block de impressao }*/) //"Beneficiário"
TRCell():New(oAtend,"CODRDA"   ,"B0R",STR0010,/*Picture*/       ,012,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cod.RDA"
TRCell():New(oAtend,"NOMRDA"   ,"B0R",STR0011,/*Picture*/       ,030,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nome RDA"
TRCell():New(oAtend,"MESPRO"   ,"B0R",STR0012,/*Picture*/       ,002,/*lPixel*/,/*{|| code-block de impressao }*/) //"Mes Proc."
TRCell():New(oAtend,"ANOPRO"   ,"B0R",STR0013,/*Picture*/       ,004,/*lPixel*/,/*{|| code-block de impressao }*/) //"Ano Proc."
TRCell():New(oAtend,"DATPRO"   ,"B0R",STR0014,/*Picture*/       ,010,/*lPixel*/,/*{|| code-block de impressao }*/) //"Dt.Processo"
TRCell():New(oAtend,"VALOR"    ,"B0R",STR0015,"@E 99,999,999.99",014,/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr. Servico"
TRCell():New(oAtend,"AIHAPA"   ,"B0R",STR0016,/*Picture*/       ,013,/*lPixel*/,/*{|| code-block de impressao }*/) //"AIH/APAC N."

oProced := TRSection():New(oAtend,"Ressarcimento",{"TRB"},{"TESTE_2"},/*Campos do SX3*/,/*Campos do SIX*/)// 
oProced:SetTotalInLine(.F.)
TRCell():New(oProced,"SEQUEN" ,,STR0017,/*Picture*/      ,004,/*lPixel*/,/*{|| code-block de impressao }*/) //"Sequencia"
TRCell():New(oProced,"TUNEP"  ,,STR0018,/*Picture*/      ,035,/*lPixel*/,/*{|| code-block de impressao }*/) //"Proced. Tunep"
TRCell():New(oProced,"DESTUN" ,,STR0019,/*Picture*/      ,075,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descr. Procedimento"
TRCell():New(oProced,"PROCED" ,,STR0020,/*Picture*/      ,035,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cod. Procedim."
TRCell():New(oProced,"DESPRO" ,,STR0019,/*Picture*/      ,075,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descr. Procedimento"
TRCell():New(oProced,"QTDPRO" ,,STR0021,/*Picture*/      ,007,/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtd"
TRCell():New(oProced,"VLRAPR" ,,STR0022,"@E 9,999,999.99",025,/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr.Apres."
TRCell():New(oProced,"DATPRO" ,,STR0023,/*Picture*/      ,025,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data Proced."
TRCell():New(oProced,"STATUS" ,,STR0024,/*Picture*/      ,045,/*lPixel*/,/*{|| code-block de impressao }*/) //"Status"
TRCell():New(oProced,"CODLDP" ,,STR0025,/*Picture*/      ,025,/*lPixel*/,/*{|| code-block de impressao }*/) //"Lc Dig PEG"
TRCell():New(oProced,"CODPEG" ,,STR0026,/*Picture*/      ,025,/*lPixel*/,/*{|| code-block de impressao }*/) //"Codigo PEG"
TRCell():New(oProced,"NUMERO" ,,STR0027,/*Picture*/      ,025,/*lPixel*/,/*{|| code-block de impressao }*/) //"Numero Guia" 
TRCell():New(oProced,"OPEMOV" ,,STR0028,/*Picture*/      ,022,/*lPixel*/,/*{|| code-block de impressao }*/) //"Operadora"
TRCell():New(oProced,"DESINC" ,,STR0029,/*Picture*/      ,150,/*lPixel*/,/*{|| code-block de impressao }*/) //"Desc. Incremento"
				
Return(oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄ--ÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³TOTVS                ³ Data ³19/03/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄ--ÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport,oAtend,oProced)
//Local oProced	:= oReport:Section(1)  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do relatorio...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cIDANS    := ""
Local cOFICIO   := ""
Local cNUMPRO   := ""
Local cCODIGO   := ""
Local cSTATUS   := ""
Local cCODCCO   := ""
Local cBENEFI   := ""
Local cCODRDA   := ""
Local cNOMRDA   := ""
Local cMESPRO   := ""
Local cANOPRO   := ""
Local cDATPRO   := ""
Local cVALOR    := ""
Local cAIHAPA   := ""
Local cAliasB0R := ""
Local cWhere    := ""
Local aRetBene  := {}

Private cDesc1    := STR0001
Private cSigaadv  := Upper(AllTrim(GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() ))) 

cTitulo := alltrim(Upper(cDesc1)) + " - Periodo: " + dtoc(mv_par06) + " a " + dtoc(mv_par07)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa vetor com log de ocorrencias                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aLog := {}


If EMPTY(mv_par01+mv_par02+mv_par03)
	MsgInfo(STR0034) 				//"Os parâmetros não foram corretamente preenchidos !!!"
	Return NIL
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona indices                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
B0R->(DBSetOrder(1)) // Ressarcimento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona...					                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
B0R->(DbSeek(xFilial("B0R")+mv_par01))
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()	

cAliasB0R := GetNextAlias() 

If !EMPTY(mv_par01)
	cWhere += "B0R_IDANS = '" + AllTrim(mv_par01) + "' AND "
EndIf
If !EMPTY(mv_par02)
	cWhere += "B0R_MESPRO = '" + AllTrim(mv_par02) + "' AND "
EndIf
If !EMPTY(mv_par03)
	cWhere += "B0R_ANOPRO = '" + AllTrim(mv_par03) + "' AND "
EndIf
If mv_par04 <> 4 // TODOS
	cWhere += "B0R_STATUS = '" + AllTrim(STR(mv_par04)) + "' AND "
EndIf
cWhere := "%"+ Substr(cWhere,1,LEN(cWhere)-4) +"%"

BeginSql Alias cAliasB0R

	SELECT B0R_IDANS, B0R_OFICIO, B0R_NUMPRO, B0R_CODIGO, B0R_STATUS, B0R_CODRDA, B0R_NOMRDA, B0R_MESPRO, B0R_USUARI, 
	       B0R_ANOPRO, B0R_DATPRO, B0R_DATEVE, B0R_VALOR, B0R_AIHAPA, B0R_CODOPE, B0R_CODCCO

	FROM %table:B0R% B0R           
	
	WHERE B0R_FILIAL    = %xFilial:B0R% 
		AND B0R_DATEVE  >= %Exp:dtos(mv_par06)% 
		AND B0R_DATEVE  <= %Exp:dtos(mv_par07)% 
		AND B0R.%NotDel%
		AND %exp:cWhere%
EndSql  

cDebug := GetLastQuery()[2]		//Para debugar a query

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³                                                                        ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³                                                                        ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

oReport:OnPageBreak({|| oReport:SetTitle(STR0001),.T.} )	   		

oAtend:Cell("IDANS" ):SetBlock({|| cIDANS  }) 
oAtend:Cell("OFICIO"):SetBlock({|| cOFICIO })
oAtend:Cell("NUMPRO"):SetBlock({|| cNUMPRO })
oAtend:Cell("CODIGO"):SetBlock({|| cCODIGO })
oAtend:Cell("STATUS"):SetBlock({|| cSTATUS })
oAtend:Cell("CODCCO"):SetBlock({|| cCODCCO })
oAtend:Cell("BENEFI"):SetBlock({|| cBENEFI })
oAtend:Cell("CODRDA"):SetBlock({|| cCODRDA })
oAtend:Cell("NOMRDA"):SetBlock({|| cNOMRDA })
oAtend:Cell("MESPRO"):SetBlock({|| cMESPRO })
oAtend:Cell("ANOPRO"):SetBlock({|| cANOPRO })
oAtend:Cell("DATPRO"):SetBlock({|| cDATPRO })
oAtend:Cell("VALOR"):SetBlock({||  cVALOR  })
oAtend:Cell("AIHAPA"):SetBlock({|| cAIHAPA })
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter((cAliasB0R)->(LastRec()))
dbSelectArea(cAliasB0R) 
oReport:Section(1):Init()
oReport:PrintText("")       
oReport:SkipLine() 

If ! (cAliasB0R)->(Eof())
    oAtend:Init() 
	While !oReport:Cancel() .And. !(cAliasB0R)->(Eof())
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Verifica se foi cancelada a impressao                                 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oReport:Cancel() 
			Exit
		EndIf 
	           
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Inicializa variaveis                                               ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIDANS  := (cAliasB0R)->B0R_IDANS
		cOFICIO := (cAliasB0R)->B0R_OFICIO
		cNUMPRO := (cAliasB0R)->B0R_NUMPRO
		cCODIGO := (cAliasB0R)->B0R_CODIGO
		Do Case
		   Case (cAliasB0R)->B0R_STATUS == "1" 
		       	cSTATUS :=STR0030//Autorizada
		   Case (cAliasB0R)->B0R_STATUS == "2" 
				cSTATUS := STR0031//Atendimento Incompleto
		   Case (cAliasB0R)->B0R_STATUS == "3" 
				cSTATUS :=STR0032//Cancelado
		   Case (cAliasB0R)->B0R_STATUS == "4" 
				cSTATUS :=STR0033//Gerado C.Medicas
		EndCase  
		cCODCCO := (cAliasB0R)->B0R_CODCCO
		aRetBene := PLA553Ben((cAliasB0R)->B0R_CODCCO)
		cBENEFI := IIF( aRetBene[1][1],Substr(aRetBene[14],1,30),"" )
		cCODRDA := (cAliasB0R)->B0R_CODRDA
		cNOMRDA := Substr((cAliasB0R)->B0R_NOMRDA,1,30)
		cMESPRO := (cAliasB0R)->B0R_MESPRO
		cANOPRO := (cAliasB0R)->B0R_ANOPRO
		cDATPRO := (cAliasB0R)->B0R_DATPRO
		cVALOR  := (cAliasB0R)->B0R_VALOR
		cAIHAPA := (cAliasB0R)->B0R_AIHAPA
		
	   	If mv_par05 == 2	    
		    oAtend:Init() 		
		Endif
		oReport:IncMeter()
		oAtend:PrintLine()
 	
 	   If mv_par05 == 2//Procedimentos 
		   dbSelectArea("B0W") 
		   If B0W->(DbSeek(xFilial("B0W")+(cAliasB0R)->(B0R_CODOPE+B0R_CODIGO)))			   
	   	   	   oProced:Init()    
			   While (xFilial("B0R")+(cAliasB0R)->(B0R_CODOPE+B0R_CODIGO))== B0W->(B0W_FILIAL+B0W_OPEMOV+B0W_CODIGO) 
			
				   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				   //³ Inicializa variaveis                                               ³
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						
					oProced:Cell("SEQUEN"):SetBlock({|| B0W->B0W_SEQUEN })//"Sequencia" 
					oProced:Cell("TUNEP"):SetBlock ({|| B0W->B0W_CDPADP+"-"+B0W->B0W_TUNEP  })//"Procedim. Tunep"
					oProced:Cell("DESTUN"):SetBlock({|| Substr( Posicione('BR8',1,xFilial('BR8')+B0W->B0W_CDPADP+B0W->B0W_TUNEP ,'BR8_DESCRI'),1,35) }) //"Descr. Procedim. Tunep"
	                oProced:Cell("PROCED"):SetBlock({|| B0W->B0W_CODPAD+"-"+B0W->B0W_CODPRO })//"Cod. Procedim."
	                oProced:Cell("DESPRO"):SetBlock({|| Substr( Posicione('BR8',1,xFilial('BR8')+B0W->B0W_CODPAD+B0W->B0W_CODPRO,'BR8_DESCRI'),1,35) }) //"Descr. Procedimento" 
					oProced:Cell("QTDPRO"):SetBlock({|| B0W->B0W_QTDPRO })//"Qtd"
					oProced:Cell("VLRAPR"):SetBlock({|| B0W->B0W_VLRAPR })//"Vlr.Apres."
					oProced:Cell("DATPRO"):SetBlock({|| B0W->B0W_DATPRO })//"Data Proced."
					Do Case
					   Case B0W->B0W_STATUS == "1" 
					       	oProced:Cell("STATUS"):SetBlock({|| STR0030  })//Autorizada
					   Case B0W->B0W_STATUS == "2" 
							oProced:Cell("STATUS"):SetBlock({|| STR0031  })//Atendimento Incompleto
					   Case B0W->B0W_STATUS == "3" 
							oProced:Cell("STATUS"):SetBlock({|| STR0032  })//Cancelado
					   Case B0W->B0W_STATUS == "4" 
							oProced:Cell("STATUS"):SetBlock({|| STR0033  })//Gerado C.Medicas
					EndCase					
					oProced:Cell("CODLDP"):SetBlock({||  B0W->B0W_CODLDP })//"Cd Lc Dig PG"
					oProced:Cell("CODPEG"):SetBlock({||  B0W->B0W_CODPEG })//"Codigo PEG"
					oProced:Cell("NUMERO"):SetBlock({||  B0W->B0W_NUMERO })//"Numero Guia"
					oProced:Cell("OPEMOV"):SetBlock({||  B0W->B0W_OPEMOV })//"Operadora"
					oProced:Cell("DESINC"):SetBlock({||  B0W->B0W_DESINC })//"Desc Increm."
					oProced:PrintLine()
					
				    B0W->(DBSkip())
    		   	      		   	    
		   	   Enddo
			   If mv_par05 == 2
			     oProced:Finish()
			   	 oReport:SkipLine()
				 oReport:ThinLine()
				 oReport:ThinLine()
				 oReport:SkipLine()
			   Endif 	   
		   Endif      
       Endif
     
	   (cAliasB0R)->(DBSkip())
		If mv_par05 == 2
			oAtend:Finish()
		Endif	
	Enddo 
	
	oReport:Section(1):Finish()
	oProced:PrintLine()
	oProced:Finish()
	
	oReport:EndPage()
Endif	
Return 