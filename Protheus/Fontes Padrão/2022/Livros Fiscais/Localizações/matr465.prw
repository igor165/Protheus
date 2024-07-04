#INCLUDE "MATR465.CH"  
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR465  ³ Autor ³ Marco Bianchi         ³ Data ³ 26/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera e imprime o relatorio de notas de Credito e Debito.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATR465()

	Local oReport	:= Nil

	Private	 cEspecie	:= "" // Declarada como Private poius é utilizada em Report Def e PrintDialog

	If !Pergunte("MT465A",.T.)
		Return()
	EndIf

	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport		:= Nil
Local cAliasQry		:= GetNextAlias()
Local cPerg			:= ""
Local aOrd			:= {}
Local cAlias		:= ""
Local nTot1			:= 0
Local nTot2			:= 0
Local nTot3			:= 0
Local nRod1			:= 0
Local nRod2			:= 0
Local nRod3			:= 0
Local oSintetico	:= Nil
Local nI1			:= 0
Local nTamData		:= Len(DTOC(MsDate()))

Private	 nX1		:= 0
Private aDadosImp	:= {}

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
//Determina qual o tipo de Nota de Credito deseja imprimir...
If MV_PAR01 == 1
	cEspecie := 'NCC'
	cPerg    := "MT465B"
	cAlias   := "SF1"
ElseIf MV_PAR01 == 2
	cEspecie := 'NCE'   
	cPerg    := "MT465B" 
	cAlias   := "SF2"	
ElseIf MV_PAR01 == 3
	cEspecie := 'NCP'  
	cPerg    := "MT465C"	
	cAlias   := "SF2"	
Else
	cEspecie := 'NCI'
	cPerg    := "MT465C"   
	cAlias   := "SF1"	
EndIf

aOrd := {STR0040,STR0041,STR0042,STR0043} 	//"Nota Fiscal"###"Data de Emissao"###"Cliente"###"Data do Registro"
oReport := TReport():New("MATR465",If((cPaisLoc=="VEN"),STR0079,STR0044),cPerg, {|oReport| ReportPrint(oReport,cAliasQry,oSintetico,@nI1)},STR0044)//Relatorio de Faturas de Credito //Relatorio de Notas de Credito 
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)


//Carrega os parametros padroes do relatorio...
Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cEspecie$"NCC|NCI"
   cAlias := "SF1"
Else   
   cAlias := "SF2"
EndIf   

// Section 1 - Notas Fiscais
oSintetico := TRSection():New(oReport,STR0070,{},aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"Sintetico por Factura"
oSintetico:SetTotalInLine(.F.)

TRCell():New(oSintetico,"AIMP01","   ",STR0040,PesqPict("SF1","F1_DOC")		,TamSX3("F1_DOC")[1]		,/*lPixel*/,{|| aDadosImp[nI1][01] })	// Nota Fiscal
TRCell():New(oSintetico,"AIMP02","   ",STR0045,PesqPict("SF1","F1_SERIE")		,SerieNfId("SF1",6,"F1_SERIE"),/*lPixel*/,{|| aDadosImp[nI1][02] })	// Sertie
TRCell():New(oSintetico,"AIMP03","   ",STR0046,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][03] })	// Emissao
TRCell():New(oSintetico,"AIMP14","   ",STR0047,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][14] })	// Dt. Registro
TRCell():New(oSintetico,"AIMP04","   ",STR0042,PesqPict("SA1","A1_COD")		,TamSX3("A1_COD")[1]		,/*lPixel*/,{|| aDadosImp[nI1][04] })	// Cliente
TRCell():New(oSintetico,"AIMP06","   ",STR0048,PesqPict("SA1","A1_NOME")		,TamSX3("A1_NOME")[1]		,/*lPixel*/,{|| aDadosImp[nI1][06] })	// Nome Cliente
TRCell():New(oSintetico,"AIMP10","   ",STR0049,PesqPict("SF1","F1_ESPECIE")	,TamSX3("F1_ESPECIE")[1]	,/*lPixel*/,{|| aDadosImp[nI1][10] })	// Especie
TRCell():New(oSintetico,"AIMP07","   ",STR0050,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][07] },,,"RIGHT")	// Imp. nao Incluido
TRCell():New(oSintetico,"AIMP08","   ",STR0051,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][08] },,,"RIGHT")	// Imp. Incluido
TRCell():New(oSintetico,"AIMP09","   ",STR0052,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][09] },,,"RIGHT")	// Total de N.Fiscal

// Section 2 -  Quebra por Data de Emissao
oQuebraE := TRSection():New(oReport,STR0071,{},,/*Campos do SX3*/,/*Campos do SIX*/) //"Sintetico por Emision"
oQuebraE:SetTotalInLine(.F.)
TRCell():New(oQuebraE,"EMISSAO"	,"   ",STR0046,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][03] })			// Emissao
TRCell():New(oQuebraE,"QE1"		,"   ",STR0040,PesqPict("SF1","F1_DOC")		,TamSX3("F1_DOC")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Nota Fiscal
TRCell():New(oQuebraE,"QE2"		,"   ",STR0045,PesqPict("SF1","F1_SERIE")	    ,SerieNfId("SF1",6,"F1_SERIE")		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Sertie
TRCell():New(oQuebraE,"QE3"		,"   ",STR0047,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,/*{|| code-block de impressao }*/)	// Dt. Registro
TRCell():New(oQuebraE,"QE4"		,"   ",STR0042,PesqPict("SA1","A1_COD")		,TamSX3("A1_COD")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Cliente
TRCell():New(oQuebraE,"QE5"		,"   ",STR0048,PesqPict("SA1","A1_NOME")	,TamSX3("A1_NOME")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Nome Cliente
TRCell():New(oQuebraE,"QE6"		,"   ",STR0049,PesqPict("SF1","F1_ESPECIE")	,TamSX3("F1_ESPECIE")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// Especie
TRCell():New(oQuebraE,"NTOT1"	,"   ",STR0050,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot1 },,,"RIGHT")						// Imp. nao Incluido
TRCell():New(oQuebraE,"NTOT2"	,"   ",STR0051,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot2 },,,"RIGHT")						// Imp. Incluido
TRCell():New(oQuebraE,"NTOT3"	,"   ",STR0052,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot3 },,,"RIGHT")						// Total de N.Fiscal

// Section 3 -  Quebra por Cliente
oQuebraC := TRSection():New(oReport,STR0072,{},,/*Campos do SX3*/,/*Campos do SIX*/)
oQuebraC:SetTotalInLine(.F.)
TRCell():New(oQuebraC,"CLIENTE","   ",STR0042,PesqPict("SF1","F1_FORNECE")	,TamSX3("F1_FORNECE")[1]	,/*lPixel*/,{|| aDadosImp[nI1][04] })			// Cliente
TRCell():New(oQuebraC,"NOME"	,"   ",STR0048,PesqPict("SA1","A1_NOME")   	,TamSX3("A1_NOME")[1]		,/*lPixel*/,{|| aDadosImp[nI1][06] })			// Nome Cliente
TRCell():New(oQuebraC,"QC1"		,"   ",STR0040,PesqPict("SF1","F1_DOC")		,TamSX3("F1_DOC")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Nota Fiscal
TRCell():New(oQuebraC,"QC2"		,"   ",STR0045,PesqPict("SF1","F1_SERIE")	    ,SerieNfId("SF1",6,"F1_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)	// Sertie
TRCell():New(oQuebraC,"QC3"		,"   ",STR0046,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,/*{|| code-block de impressao }*/)	// Emissao
TRCell():New(oQuebraC,"QC4"		,"   ",STR0047,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,/*{|| code-block de impressao }*/)	// Dt. Registro
TRCell():New(oQuebraC,"QC5"		,"   ",STR0049,PesqPict("SF1","F1_ESPECIE")	,TamSX3("F1_ESPECIE")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// Especie
TRCell():New(oQuebraC,"NTOT1"	,"   ",STR0050,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot1 },,,"RIGHT")						// Imp. nao Incluido
TRCell():New(oQuebraC,"NTOT2"	,"   ",STR0051,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot2 },,,"RIGHT")						// Imp. Incluido
TRCell():New(oQuebraC,"NTOT3"	,"   ",STR0052,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot3 },,,"RIGHT")						// Total de N.Fiscal
        
// Section 4 -  Quebra por Data de Registro
oQuebraD := TRSection():New(oReport,STR0073,{},,/*Campos do SX3*/,/*Campos do SIX*/) //"Sintetico por Fch. de Registro"
oQuebraD:SetTotalInLine(.F.)
TRCell():New(oQuebraD,"REGISTRO"	,"  " ,STR0047,PesqPict("SF1","F1_DTDIGIT")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][14] })			// Data do Regsitro
TRCell():New(oQuebraD,"QR1"			,"   ",STR0040,PesqPict("SF1","F1_DOC")		,TamSX3("F1_DOC")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Nota Fiscal
TRCell():New(oQuebraD,"QR2"			,"   ",STR0045,PesqPict("SF1","F1_SERIE")	   ,SerieNfId("SF1",6,"F1_SERIE")		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Sertie
TRCell():New(oQuebraD,"QR3"			,"   ",STR0046,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,/*{|| code-block de impressao }*/)	// Dt. Registro
TRCell():New(oQuebraD,"QR4"			,"   ",STR0042,PesqPict("SA1","A1_COD")		,TamSX3("A1_COD")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Cliente
TRCell():New(oQuebraD,"QR5"			,"   ",STR0048,PesqPict("SA1","A1_NOME")	,TamSX3("A1_NOME")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)	// Nome Cliente
TRCell():New(oQuebraD,"QR6"			,"   ",STR0049,PesqPict("SF1","F1_ESPECIE")	,TamSX3("F1_ESPECIE")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// Especie
TRCell():New(oQuebraD,"NTOT1"		,"   ",STR0050,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot1 },,,"RIGHT")						// Imp. nao Incluido
TRCell():New(oQuebraD,"NTOT2"		,"   ",STR0051,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot2 },,,"RIGHT")						// Imp. Incluido
TRCell():New(oQuebraD,"NTOT3"		,"   ",STR0052,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nTot3 },,,"RIGHT")						// Total de N.Fiscal                                 

// Section 5 -  Analitico
oAnalitico := TRSection():New(oReport,STR0074,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Analitico por Factura"
oAnalitico:SetTotalInLine(.F.)
TRCell():New(oAnalitico,"AIMP01","   ",STR0040,PesqPict("SF1","F1_DOC")		,TamSX3("F1_DOC")[1]		,/*lPixel*/,{|| aDadosImp[nI1][01] })	// Nota Fiscal
TRCell():New(oAnalitico,"AIMP02","   ",STR0045,PesqPict("SF1","F1_SERIE")		,SerieNfId("SF1",6,"F1_SERIE")		,/*lPixel*/,{|| aDadosImp[nI1][02] })	// Serie
TRCell():New(oAnalitico,"AIMP10","   ",STR0046,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][10] })	// Emissao
TRCell():New(oAnalitico,"AIMP03","   ",STR0047,PesqPict("SF1","F1_DTDIGIT")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][03] })	// Dt. Registro
TRCell():New(oAnalitico,"AIMP08","   ",STR0053,PesqPict("SF1","F1_ESPECIE")	,TamSX3("F1_ESPECIE")[1]	,/*lPixel*/,{|| aDadosImp[nI1][08] })	// Especie
If cEspecie$"NCC|NCE"			
	TRCell():New(oAnalitico,"AIMP04","   ",STR0042,PesqPict("SF1","F1_FORNECE")	,TamSX3("F1_FORNECE")[1]	,/*lPixel*/,{|| aDadosImp[nI1][04] })	// Cliente
	TRCell():New(oAnalitico,"AIMP06","   ",STR0048,PesqPict("SF1","F1_FORNECE")	,TamSX3("F1_FORNECE")[1]	,/*lPixel*/,{|| aDadosImp[nI1][06] })	// Loja
Else
	TRCell():New(oAnalitico,"AIMP04","   ",STR0055,PesqPict("SF1","F1_FORNECE")	,TamSX3("F1_FORNECE")[1]	,/*lPixel*/,{|| aDadosImp[nI1][04] })	// Prov:
	TRCell():New(oAnalitico,"AIMP06","   ",STR0048,PesqPict("SF1","F1_FORNECE")	,TamSX3("F1_FORNECE")[1]	,/*lPixel*/,{|| aDadosImp[nI1][06] })	// Loja
EndIf

// Section 6 - Itens
oItens := TRSection():New(oReport,STR0075,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Items"
oItens:SetTotalInLine(.F.)
TRCell():New(oItens,"AIMP1101","   ",STR0056,PesqPict("SB1","B1_COD")		,TamSX3("B1_COD")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][01] })		// Produto
TRCell():New(oItens,"AIMP1102","   ",STR0057,PesqPict("SB1","B1_DESC")	,TamSX3("B1_DESC")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][02] })		// Descricao
TRCell():New(oItens,"AIMP1103","   ",STR0058,PesqPict("SD1","D1_TES")		,TamSX3("D1_TES")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][03] })		// Tes
TRCell():New(oItens,"AIMP1104","   ",STR0059,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][04] },,,"RIGHT")		// Imp N. Incl.
TRCell():New(oItens,"AIMP1105","   ",STR0060,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][05] },,,"RIGHT")		// Imp Incl.
TRCell():New(oItens,"AIMP1106","   ",STR0061,PesqPict("SD1","D1_LOCAL")	,TamSX3("D1_LOCAL")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][06] })		// Local
TRCell():New(oItens,"AIMP1107","   ",STR0062,PesqPict("SD1","D1_QUANT")	,TamSX3("D1_QUANT")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][07] },,,"RIGHT")		// Quantidade
TRCell():New(oItens,"AIMP1108","   ",STR0063,PesqPict("SD1","D1_VUNIT")	,TamSX3("D1_VUNIT")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][08] },,,"RIGHT")		// Valor Unit.
TRCell():New(oItens,"AIMP1109","   ",STR0064,PesqPict("SD1","D1_TOTAL")	,TamSX3("D1_TOTAL")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][09] },,,"RIGHT")		// Valor Total

If cPaisLoc == "EUA"
	TRCell():New(oItens,"AIMP1110","   ",STR0078,PesqPict("SD1","D1_TOTAL")	,TamSX3("D1_TOTAL")[1]		,/*lPixel*/,{|| aDadosImp[nI1][11][nX1][10] },,,"RIGHT")		// Valor Total sem desconto
EndIf	

// Section 7 - Rodape dos itens
oRodape := TRSection():New(oReport,STR0076,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Pie de Pag Items"
oRodape:SetTotalInLine(.F.)
TRCell():New(oRodape,"AIMP14","   ",STR0065,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][14] })		// Registro
TRCell():New(oRodape,"AIMP09","   ",STR0066,PesqPict("SF1","F1_COND")		,TamSX3("F1_COND")[1]		,/*lPixel*/,{|| aDadosImp[nI1][09] })		// Cond.Pag.
TRCell():New(oRodape,"AIMP12","   ",STR0067,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][12] },,,"RIGHT")		// Tot.Imp.Nao Incl
TRCell():New(oRodape,"AIMP13","   ",STR0068,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][13] },,,"RIGHT")		// Tot.Imp.Incl
TRCell():New(oRodape,"AIMP07","   ",STR0069,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| aDadosImp[nI1][07] },,,"RIGHT")		// "Total N.Fiscal"

// Section 8 - Total Geral (por nota fiscal e com impressao dos itens)
oTotRod := TRSection():New(oReport,STR0077,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Total Gen."
oTotRod:SetTotalInLine(.F.)
TRCell():New(oTotRod,"ATOTROD14"	,"   ",STR0077,PesqPict("SF1","F1_EMISSAO")	,nTamData					,/*lPixel*/,{|| aDadosImp[nI1][14] })	// Registro
TRCell():New(oTotRod,"ATOTROD09"	,"   ","",PesqPict("SF1","F1_COND")	,TamSX3("F1_COND")[1]		,/*lPixel*/,{|| aDadosImp[nI1][09] })	// Cond.Pag.
TRCell():New(oTotRod,"NROD1"		,"   ",STR0067,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nRod1 },,,"RIGHT")				// Tot.Imp.Nao Incl
TRCell():New(oTotRod,"NROD2"		,"   ",STR0068,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nRod2 },,,"RIGHT")				// Tot.Imp.Incl
TRCell():New(oTotRod,"NROD3"		,"   ",STR0069,PesqPict("SF1","F1_VALBRUT")	,TamSX3("F1_VALBRUT")[1]	,/*lPixel*/,{|| nRod3 },,,"RIGHT")				// "Total N.Fiscal"
     
oReport:Section(1):Setedit(.F.)
oReport:Section(2):Setedit(.F.)
oReport:Section(3):Setedit(.F.)
oReport:Section(4):Setedit(.F.)
oReport:Section(5):Setedit(.F.)
oReport:Section(6):Setedit(.F.)
oReport:Section(7):Setedit(.F.)
oReport:Section(8):Setedit(.F.)

Return (oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Eduardo Riera          ³ Data ³04.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasQry,oSintetico,nI1)

Local nTotGImpDis	:= 0
Local nTotGImpInc	:= 0
Local nI			:= 0
Local nX			:= 0
Local cQuebra		:= ""
Local lQuebra		:= .T.
Local lRet			:= .F.
Local cAliasSF1		:= ""
Local cAliasSD1		:= ""
Local cAliasSF2		:= ""
Local cAliasSD2		:= ""         
Local cNome			:= ""
Local cNomeCli		:= ""

Private nOrdem	:= oReport:Section(1):GetOrder()                                      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

// SetBlock: faz com que as variaveis locais possam ser utilizadas em outras funcoes nao precisando declara-las como provate
oReport:Section(2):Cell("NTOT1" ):SetBlock({|| nTot1})
oReport:Section(2):Cell("NTOT2" ):SetBlock({|| nTot2})
oReport:Section(2):Cell("NTOT3" ):SetBlock({|| nTot3})
oReport:Section(3):Cell("NTOT1" ):SetBlock({|| nTot1})
oReport:Section(3):Cell("NTOT2" ):SetBlock({|| nTot2})
oReport:Section(3):Cell("NTOT3" ):SetBlock({|| nTot3})
oReport:Section(4):Cell("NTOT1" ):SetBlock({|| nTot1})
oReport:Section(4):Cell("NTOT2" ):SetBlock({|| nTot2})
oReport:Section(4):Cell("NTOT3" ):SetBlock({|| nTot3})
oReport:Section(8):Cell("NROD1" ):SetBlock({|| nRod1})
oReport:Section(8):Cell("NROD2" ):SetBlock({|| nRod2})
oReport:Section(8):Cell("NROD3" ):SetBlock({|| nRod3})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDadosImp	:= {}
If cEspecie$"NCC|NCI"
	PesqSF1(@aDadosImp,@nTotGImpDis,@nTotGImpInc,cAliasQry,oReport,@lRet,@cAliasSF1,@cAliasSD1)
Else
	PesqSF2(@aDadosImp,@nTotGImpDis,@nTotGImpInc,cAliasQry,oReport,@lRet,@cAliasSF2,@cAliasSD2)
EndIf
	
If oReport:Section(1):GetOrder() == 2	
	//Quebra por data de emissao...
	aSort(aDadosImp,,,{|x,y| DToS(x[3])+x[1]+x[2]+x[4]+x[5] < DToS(y[3])+y[1]+y[2]+y[4]+y[5]})		
ElseIf oReport:Section(1):GetOrder() == 3
	//Quebra por cliente
	aSort(aDadosImp,,,{|x,y| x[4]+x[5]+x[1]+x[2]+DToS(x[3]) < y[4]+y[5]+y[1]+y[2]+DToS(y[3])})
Else
	//Quebra por data de digitacao...
	aSort(aDadosImp,,,{|x,y| DToS(x[14])+x[1]+x[2]+x[4]+x[5] < DToS(y[14])+y[1]+y[2]+y[4]+y[5]})		
EndIf

If oReport:Section(1):GetOrder() == 1	.And. mv_par05 == 2		// Nao Lista Itens
	oReport:Section(1):Init()	
ElseIf oReport:Section(1):GetOrder() == 2    
   cNome := "EMISSAO"
ElseIf oReport:Section(1):GetOrder() == 3
   cNome 	:= "CLIENTE"
   cNomeCli := "NOME"
ElseIf oReport:Section(1):GetOrder() == 4
   cNome := "REGISTRO"
EndIf   

If mv_par05 == 2		// Nao Lista Itens	
	TRFunction():New(oSintetico:Cell("AIMP07"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSintetico:Cell("AIMP08"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSintetico:Cell("AIMP09"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
EndIf   

nTot1 := 0
nTot2 := 0
nTot3 := 0    
nRod1 := 0
nRod2 := 0
nRod3 := 0
oReport:SetMeter(Len(aDadosImp))
For nI := 1 To Len(aDadosImp)

	nI1 := nI
	If oReport:Section(1):GetOrder() <> 1
		If oReport:Section(1):GetOrder() == 2					// por Emissao
			cQuebra := DToS(aDadosImp[nI][03])
		ElseIf oReport:Section(1):GetOrder() == 3				// por Cliente
			cQuebra := aDadosImp[nI][04]+aDadosImp[nI][05]
		Else													// por Registro
			cQuebra := DToS(aDadosImp[nI][14])	
		EndIf			    
	    
		If lQuebra
			oReport:Section(oReport:Section(1):GetOrder()):Init()
			If cNome <> "" 	
				oReport:Section(oReport:Section(1):GetOrder()):Cell(cNome):Show()		    
			EndIf
			If cNomeCli <> "" 				
				oReport:Section(oReport:Section(1):GetOrder()):Cell(cNomeCli):Show()		    
			EndIf
			If oReport:Section(1):GetOrder() == 2	
				// por Emissao
				oReport:Section(2):Cell("QE1"):Disable()
				oReport:Section(2):Cell("QE2"):Disable()		
				oReport:Section(2):Cell("QE3"):Disable()	
				oReport:Section(2):Cell("QE4"):Disable()	
				oReport:Section(2):Cell("QE5"):Disable()	
				oReport:Section(2):Cell("QE6"):Disable()	
				oReport:Section(2):Cell("NTOT1"):Disable()
				oReport:Section(2):Cell("NTOT2"):Disable()
				oReport:Section(2):Cell("NTOT3"):Disable()
			ElseIf oReport:Section(1):GetOrder() == 3
				// por Cliente
				oReport:Section(3):Cell("QC1"):Disable()	
				oReport:Section(3):Cell("QC2"):Disable()	
				oReport:Section(3):Cell("QC3"):Disable()	
				oReport:Section(3):Cell("QC4"):Disable()	
				oReport:Section(3):Cell("QC5"):Disable()
			Else
				// por Registro
				oReport:Section(4):Cell("QR1"):Disable()		
				oReport:Section(4):Cell("QR2"):Disable()	
				oReport:Section(4):Cell("QR3"):Disable()	
				oReport:Section(4):Cell("QR4"):Disable()	
				oReport:Section(4):Cell("QR5"):Disable()	
				oReport:Section(4):Cell("QR6"):Disable()	
			EndIf

			oReport:Section(oReport:Section(1):GetOrder()):Cell("NTOT1"):Disable()
			oReport:Section(oReport:Section(1):GetOrder()):Cell("NTOT2"):Disable()
			oReport:Section(oReport:Section(1):GetOrder()):Cell("NTOT3"):Disable()
			
			oReport:Section(oReport:Section(1):GetOrder()):PrintLine()
			oReport:Section(1):Init()
			lQuebra := .f.   
		EndIf

	EndIf

	If oReport:Section(1):GetOrder() == 1					// por Nota Fiscal
	    If MV_PAR05 == 2									// Nao Lista Itens
			oReport:Section(1):Cell("AIMP01"):Show()
			oReport:Section(1):Cell("AIMP02"):Show()
			oReport:Section(1):Cell("AIMP03"):Show()
			oReport:Section(1):Cell("AIMP14"):Show()
			oReport:Section(1):Cell("AIMP04"):Show()
			oReport:Section(1):Cell("AIMP06"):Show()
			oReport:Section(1):Cell("AIMP10"):Show()
			oReport:Section(1):Cell("AIMP07"):Show()
			oReport:Section(1):Cell("AIMP08"):Show()
			oReport:Section(1):Cell("AIMP09"):Show()
		EndIf
	ElseIf oReport:Section(1):GetOrder() == 2				// por Data de Emissao
		oReport:Section(1):Cell("AIMP01"):Show()
		oReport:Section(1):Cell("AIMP02"):Show()
		oReport:Section(1):Cell("AIMP03"):Disable()
		oReport:Section(1):Cell("AIMP14"):Show()
		oReport:Section(1):Cell("AIMP04"):Show()
		oReport:Section(1):Cell("AIMP06"):Show()
		oReport:Section(1):Cell("AIMP10"):Show()
		oReport:Section(1):Cell("AIMP07"):Show()
		oReport:Section(1):Cell("AIMP08"):Show()
		oReport:Section(1):Cell("AIMP09"):Show()
	ElseIf oReport:Section(1):GetOrder() == 3				// por Cliente
		oReport:Section(1):Cell("AIMP01"):Show()
		oReport:Section(1):Cell("AIMP02"):Show()
		oReport:Section(1):Cell("AIMP03"):Show()
		oReport:Section(1):Cell("AIMP14"):Show()
		oReport:Section(1):Cell("AIMP04"):Disable()
		oReport:Section(1):Cell("AIMP06"):Disable()
		oReport:Section(1):Cell("AIMP10"):Show()
		oReport:Section(1):Cell("AIMP07"):Show()
		oReport:Section(1):Cell("AIMP08"):Show()
		oReport:Section(1):Cell("AIMP09"):Show()
	Else                                    				// por Data do Registro
		oReport:Section(1):Cell("AIMP01"):Show()
		oReport:Section(1):Cell("AIMP02"):Show()
		oReport:Section(1):Cell("AIMP03"):Show()
		oReport:Section(1):Cell("AIMP14"):Disable()
		oReport:Section(1):Cell("AIMP04"):Show()
		oReport:Section(1):Cell("AIMP06"):Show()
		oReport:Section(1):Cell("AIMP10"):Show()
		oReport:Section(1):Cell("AIMP07"):Show()
		oReport:Section(1):Cell("AIMP08"):Show()
		oReport:Section(1):Cell("AIMP09"):Show()
    EndIf

	If oReport:Section(1):GetOrder() == 1 .And. MV_PAR05 == 1	// Lista Itens apenas se ordem por Nota Fiscal
		oReport:Section(5):Init()
		oReport:Section(5):PrintLine() 
		oReport:Section(5):Finish()		
		
		oReport:Section(6):Init()
		For nX := 1 To Len(aDadosImp[nI][11])  	
			nX1 := nX
			oReport:Section(6):PrintLine()                	
		Next nX      
		oReport:Section(6):Finish()		
		
		If nI1 > 0		
			oReport:Section(7):Init()
			oReport:Section(7):PrintLine() 
			oReport:Section(7):Finish()		
		EndIf
		
		nRod1 += aDadosImp[nI][12]
		nRod2 += aDadosImp[nI][13]
		nRod3 += aDadosImp[nI][07]

	Else	
		oReport:Section(1):PrintLine()                	
	EndIf
	
	If oReport:Section(1):GetOrder() <> 1	
		nTot1 += aDadosImp[nI][07]
		nTot2 += aDadosImp[nI][08]
		nTot3 += aDadosImp[nI][09]
		If (nI == Len(aDadosImp)) .Or.;     
		   ((oReport:Section(1):GetOrder() == 2) .And. (cQuebra <> DTos(aDadosImp[nI+1][03]))) .Or.;
		   ((oReport:Section(1):GetOrder() == 3) .And. (cQuebra <> aDadosImp[nI+1][04]+aDadosImp[nI+1][05])) .Or.; 
		   ((oReport:Section(1):GetOrder() == 4) .And. (cQuebra <> DTos(aDadosImp[nI+1][14]))) 

			If cNome <> "" 	
				oReport:Section(oReport:Section(1):GetOrder()):Cell(cNome):Hide()		
			EndIf
			If cNomeCli <> ""
				oReport:Section(oReport:Section(1):GetOrder()):Cell(cNomeCli):Hide()
			EndIf
			If oReport:Section(1):GetOrder() == 2	
				// por Emissao
				oReport:Section(2):Cell("QE1"):Hide()		
				oReport:Section(2):Cell("QE2"):Hide()		
				oReport:Section(2):Cell("QE3"):Hide()		
				oReport:Section(2):Cell("QE4"):Hide()		
				oReport:Section(2):Cell("QE5"):Hide()		
				oReport:Section(2):Cell("QE6"):Hide()		
			ElseIf oReport:Section(1):GetOrder() == 3
				// por Cliente
				oReport:Section(3):Cell("QC1"):Hide()		
				oReport:Section(3):Cell("QC2"):Hide()		
				oReport:Section(3):Cell("QC3"):Hide()		
				oReport:Section(3):Cell("QC4"):Hide()		
				oReport:Section(3):Cell("QC5"):Hide()		
			Else
				// por Registro
				oReport:Section(4):Cell("QR1"):Hide()		
				oReport:Section(4):Cell("QR2"):Hide()		
				oReport:Section(4):Cell("QR3"):Hide()		
				oReport:Section(4):Cell("QR4"):Hide()		
				oReport:Section(4):Cell("QR5"):Hide()		
				oReport:Section(4):Cell("QR6"):Hide()		
			EndIf
			
			oReport:Section(oReport:Section(1):GetOrder()):Cell("NTOT1"):Show()		
			oReport:Section(oReport:Section(1):GetOrder()):Cell("NTOT2"):Show()		
			oReport:Section(oReport:Section(1):GetOrder()):Cell("NTOT3"):Show()		
			oReport:Section(oReport:Section(1):GetOrder()):PrintLine()

			oReport:Section(1):Finish()	
			oReport:Section(oReport:Section(1):GetOrder()):Finish()	
		
			lQuebra := .T.
			nTot1 	:= 0
			nTot2 	:= 0
			nTot3 	:= 0

		EndIf
	EndIf

	oReport:IncMeter()
Next

If oReport:Section(1):GetOrder() == 1	
	oReport:Section(1):Finish()	
EndIf	

If oReport:Section(1):GetOrder() == 1 .And. MV_PAR05 == 1	// Lista Itens apenas se ordem por Nota Fiscal
	If nI1 > 0
		oReport:Section(8):Init()  
		oReport:Section(8):Cell("ATOTROD14"):Hide()
		oReport:Section(8):Cell("ATOTROD09"):Hide()
		oReport:Section(8):Printline()
		oReport:Section(8):Finish()
	EndIf
EndIf

If lRet
	If !Empty(cAliasSF1)
	   (cAliasSF1)->(dbCloseArea())
	ElseIf !Empty(cAliasSF2)		   
	   (cAliasSF2)->(dbCloseArea())
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncion   ³PesqSF1   º Autor ³ Julio Cesar        ºFecha ³  08-10-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pesquisa os dados referente as notas de credito que estao  º±±
±±º          ³ armazenadas nos arquivos SF1/SD1                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PesqSF1(aDadosImp,nTotGImpDis,nTotGImpInc,cAliasQry,oReport,lRet,cAliasSF1,cAliasSD1)

Local nI		  := 0
Local cChave      := ""
Local cNomeCliFor := ""
Local cCodCliFor  := ""
Local cLoja       := ""
Local aDadosImpDet:= {}
Local nTotImpInc  := 0
Local nTotImpDis  := 0
Local nImpInc     := 0
Local nImpDis     := 0               
Local nValBrut    := 0
Local nVUnit      := 0
Local nDecimais   := MsDecimais(MV_PAR18)
Local aAreaSF1    := {}
Local aAreaSD1    := SD1->(GetArea())
Local cF1DOC      := ""
Local cF1SERIE    := ""
Local dF1EMISSAO  := Ctod("//")
Local cF1ESPECIE  := ""
Local cF1COND     := ""
Local dF1DTDIGIT  := ""
Local nF1MOEDA    := 0
Local nF1TXMOEDA  := 0
Local nF1VALBRUT  := 0
Local nValSDesc   := 0

lRet := .T.

lRet := MQuerySF1(@aAreaSF1,@cAliasSF1,@cAliasSD1,cAliasQry,oReport)

If lRet
	While ValidWhile(1)
	
		cF1DOC      := (cAliasSF1)->F1_DOC
		cF1SERIE    := (cAliasSF1)->&(SerieNfId("SF1",3,"F1_SERIE"))
	 	dF1EMISSAO  := (cAliasSF1)->F1_EMISSAO
		cF1ESPECIE  := (cAliasSF1)->F1_ESPECIE
		cF1COND     := (cAliasSF1)->F1_COND
		dF1DTDIGIT  := (cAliasSF1)->F1_DTDIGIT
		nF1MOEDA    := (cAliasSF1)->F1_MOEDA
		nF1TXMOEDA  := (cAliasSF1)->F1_TXMOEDA
		//Conforme a especie selecionada pelo usuario busca cliente ou fornecedor...
		cCodCliFor  := (cAliasSF1)->F1_FORNECE
		cLoja       := (cAliasSF1)->F1_LOJA
		If cEspecie$"NCC|NCE"
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			SA1->(dbSeek(xFilial("SA1")+cCodCliFor+cLoja))
			cNomeCliFor := SubStr(SA1->A1_NOME,1,35)
		Else
			SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
			SA2->(dbSeek(xFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
			cNomeCliFor := SubStr(SA2->A2_NOME,1,35)
		EndIf
		//Converte o valor para a moeda selecionada pelo usuario...
		If (F1_MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
			nF1VALBRUT := Round(xMoeda((cAliasSF1)->F1_VALBRUT,nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
		Else
			nF1VALBRUT := (cAliasSF1)->F1_VALBRUT
		EndIf
		
		cChave := (cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA

		nValSDesc := 0
		While ValidWhile(2,cChave,cAliasSD1)
		
			aImpInf := TesImpInf((cAliasSD1)->D1_TES)
			For nI := 1 To Len(aImpInf)
				If aImpInf[nI][03] <> "3"
					If (nF1MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
						nImpDis    += Round(xMoeda((cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
						nTotImpDis += Round(xMoeda((cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
						nTotGImpDis+= Round(xMoeda((cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
					Else
						nImpDis    += (cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotImpDis += (cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotGImpDis+= (cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02])))
					EndIf
				Else
					If (nF1MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
						nImpInc    += Round(xMoeda((cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
						nTotImpInc += Round(xMoeda((cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
						nTotGImpInc+= Round(xMoeda((cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
					Else
						nImpInc    += (cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotImpInc += (cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotGImpInc+= (cAliasSD1)->(FieldGet(FieldPos(aImpInf[nI][02])))
					EndIf
				EndIf
			Next nI
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
			//Converte o valor para a moeda selecionada pelo usuario...
			If (nF1MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
				If cPaisLoc == "EUA"
					nVUnit   := Round(xMoeda(((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)/(cAliasSD1)->D1_QUANT,nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
					nValBrut := Round(xMoeda((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC,nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
				Else 
					nVUnit   := Round(xMoeda((cAliasSD1)->D1_VUNIT,nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
					nValBrut := Round(xMoeda((cAliasSD1)->D1_TOTAL,nF1MOEDA,MV_PAR18,dF1EMISSAO,nDecimais+1,nF1TXMOEDA),nDecimais)
				EndIf
			Else
				If cPaisLoc == "EUA"
					nVUnit    := ((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)/(cAliasSD1)->D1_QUANT
					nValBrut  := (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC
					nValSDesc := (cAliasSD1)->D1_TOTAL
				Else
					nVUnit   := (cAliasSD1)->D1_VUNIT
					nValBrut := (cAliasSD1)->D1_TOTAL
				EndIf
			EndIf
			
			AAdd(aDadosImpDet,{SB1->B1_COD, SB1->B1_DESC, (cAliasSD1)->D1_TES, nImpDis,;
			nImpInc, (cAliasSD1)->D1_LOCAL, (cAliasSD1)->D1_QUANT,;
			nVUnit, nValBrut, nValSDesc})
			(cAliasSD1)->(dbSkip())
			nImpDis := 0
			nImpInc := 0
		End
		
		//Caso nao tenha encontrado nenhum registro no arquivo SD1 avanca para o proximo
		//registro do arquivo SF1...
		If Empty(aDadosImpDet)
			dbSkip() // Avanza el puntero del registro en el archivo
			Loop
		EndIf

		If (MV_PAR05 <> 1) .Or. (nOrdem <> 1)
			AAdd(aDadosImp,{cF1DOC, Alltrim(cF1SERIE), dF1EMISSAO, cCodCliFor, cLoja,cNomeCliFor, nTotImpDis,;
			nTotImpInc,nF1VALBRUT, AllTrim(cF1ESPECIE), "", "", "",dF1DTDIGIT})
		Else
			AAdd(aDadosImp,{cF1DOC, Alltrim(cF1SERIE), dF1EMISSAO, cCodCliFor, cLoja,cNomeCliFor, nF1VALBRUT,;
			AllTrim(cF1ESPECIE),cF1COND, dF1EMISSAO, aClone(aDadosImpDet), nTotImpDis, nTotImpInc, dF1DTDIGIT,aDadosImpDet[Len(aDadosImpDet)][10]})
		EndIf
		nTotImpDis   := 0
		nTotImpInc   := 0
		aDadosImpDet := {}
	EndDo
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncion   ³PesqSF2   º Autor ³ Julio Cesar        ºFecha ³  08-10-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pesquisa os dados referente as notas de credito que estao  º±±
±±º          ³ armazenadas nos arquivos SF2/SD2                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PesqSF2(aDadosImp,nTotGImpDis,nTotGImpInc,cAliasQry,oReport,lRet,cAliasSF2,cAliasSD2)

Local cChave      := ""
Local cNomeCliFor := ""
Local cCodCliFor  := ""
Local cLoja       := ""
Local aDadosImpDet:= {}
Local nTotImpInc  := 0
Local nTotImpDis  := 0
Local nImpInc     := 0
Local nImpDis     := 0
Local nValBrut    := 0
Local nPrcVen     := 0 
Local nDecimais   := MsDecimais(MV_PAR18)
Local aAreaSF2    := {}
Local aAreaSD2    := SD2->(GetArea())  
Local nI
Local nF2MOEDA    := 0
Local nF2TXMOEDA  := 0
Local nF2VALBRUT  := 0
Local cF2DOC      := ""
Local cF2SERIE    := ""
Local dF2EMISSAO  := Ctod("//")
Local cF2ESPECIE  := ""
Local cF2COND     := ""
Local dDtDigit    := CTOD("  /  /  ")

Private cCampoData  := IIf(SF2->(FieldPos("F2_DTDIGIT")) > 0,"F2_DTDIGIT", "F2_EMISSAO")

lRet := .T.
                 
lRet := MQuerySF2(@aAreaSF2,@cAliasSF2,@cAliasSD2,cAliasQry,oReport)

If lRet
	While ValidWhile(3)
		
		nF2MOEDA   := (cAliasSF2)->F2_MOEDA
		nF2TXMOEDA := (cAliasSF2)->F2_TXMOEDA
		//Converte o valor para a moeda selecionada pelo usuario...
		If (nF2MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
			nF2VALBRUT := Round(xMoeda(F2_VALBRUT,nF2MOEDA,MV_PAR18,F2_EMISSAO,nDecimais+1,F2_TXMOEDA),nDecimais)
		Else
			nF2VALBRUT := F2_VALBRUT
		EndIf
		cF2DOC     := (cAliasSF2)->F2_DOC
		cF2SERIE   := (cAliasSF2)->&(SerieNfId("SF2",3,"F2_SERIE"))
		dF2EMISSAO := (cAliasSF2)->F2_EMISSAO
		cF2ESPECIE := (cAliasSF2)->F2_ESPECIE
		cF2COND    := (cAliasSF2)->F2_COND
		//Conforme a especie selecionada pelo usuario busca cliente ou fornecedor...
		cCodCliFor  := (cAliasSF2)->F2_CLIENTE
		cLoja       := (cAliasSF2)->F2_LOJA
		dDtDigit    := &(cCampoData)
		
		If cEspecie$"NCC|NCE"
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			SA1->(dbSeek(xFilial("SA1")+cCodCliFor+cLoja))
			cNomeCliFor := SubStr(SA1->A1_NOME,1,35)
		Else
			SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
			SA2->(dbSeek(xFilial("SA2")+cCodCliFor+cLoja))
			cNomeCliFor := SubStr(SA2->A2_NOME,1,35)
		EndIf
		
		cChave := F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
		
		While ValidWhile(4,cChave,cAliasSD2)
			
			aImpInf := TesImpInf((cAliasSD2)->D2_TES)
			For nI := 1 To Len(aImpInf)
				If aImpInf[nI][03] <> "3"
					If (nF2MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
						nImpDis    += Round(xMoeda((cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
						nTotImpDis += Round(xMoeda((cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
						nTotGImpDis+= Round(xMoeda((cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
					Else
						nImpDis    += (cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotImpDis += (cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotGImpDis+= (cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02])))
					EndIf
				Else
					If (nF2MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
						nImpInc    += Round(xMoeda((cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
						nTotImpInc += Round(xMoeda((cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
						nTotGImpInc+= Round(xMoeda((cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02]))),nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
					Else
						nImpInc    += (cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotImpInc += (cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02])))
						nTotGImpInc+= (cAliasSD2)->(FieldGet(FieldPos(aImpInf[nI][02])))
					EndIf
				EndIf
			Next nI
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			//Converte o valor para a moeda selecionada pelo usuario...
			If (nF2MOEDA <> MV_PAR18) .And. (MV_PAR19 == 1)
				nPrcVen  := Round(xMoeda((cAliasSD2)->D2_PRCVEN,nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
				nValBrut := Round(xMoeda((cAliasSD2)->D2_TOTAL,nF2MOEDA,MV_PAR18,dF2EMISSAO,nDecimais+1,nF2TXMOEDA),nDecimais)
			Else
				nPrcVen  := (cAliasSD2)->D2_PRCVEN
				nValBrut := (cAliasSD2)->D2_TOTAL
			EndIf
			AAdd(aDadosImpDet,{SB1->B1_COD, SB1->B1_DESC, (cAliasSD2)->D2_TES, nImpDis,;
			nImpInc, (cAliasSD2)->D2_LOCAL, (cAliasSD2)->D2_QUANT,;
			nPrcVen, nValBrut})
			
			(cAliasSD2)->(dbSkip())
			nImpDis := 0
			nImpInc := 0
		End
		
		//Caso nao tenha encontrado nenhum registro no arquivo SD2 avanca para o proximo
		//registro do arquivo SF2...
		If Empty(aDadosImpDet)
			dbSkip() // Avanza el puntero del registro en el archivo
			Loop
		EndIf
		
		If (MV_PAR05 <> 1) .Or. (nOrdem <> 1)
			AAdd(aDadosImp,{cF2DOC, Alltrim(cF2SERIE), dF2EMISSAO, cCodCliFor, cLoja,;
			cNomeCliFor, nTotImpDis, nTotImpInc,;
			nF2VALBRUT, AllTrim(cF2ESPECIE), "", "", "",;
			dDtDigit})
		Else
			AAdd(aDadosImp,{cF2DOC, Alltrim(cF2SERIE), dF2EMISSAO, cCodCliFor, cLoja,;
			cNomeCliFor, nF2VALBRUT, AllTrim(cF2ESPECIE),;
			cF2COND, dF2EMISSAO, aClone(aDadosImpDet),;
			nTotImpDis, nTotImpInc, dDtDigit})
		EndIf
		
		nTotImpDis   := 0
		nTotImpInc   := 0
		aDadosImpDet := {}
	EndDo
EndIf

RestArea(aAreaSD2)
RestArea(aAreaSF2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidWhileº Autor ³ Julio Cesar        ºFecha ³  08-10-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza a validacao dos loops conforme os parametros       º±±
±±º          ³ recebidos pela funcao.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidWhile(nValid,cChave,cAliasSD)

	Local lRet := .F.
	
	Do Case
		Case nValid == 1
			lRet := !Eof()
		Case nValid == 2
			lRet := !(cAliasSD)->(Eof()) .And. (cAliasSD)->D1_FILIAL+;
			        (cAliasSD)->D1_DOC+(cAliasSD)->D1_SERIE+;
			    	(cAliasSD)->D1_FORNECE+(cAliasSD)->D1_LOJA == F1_FILIAL+cChave
		Case nValid == 3
			lRet := !Eof()
		Case nValid == 4
			lRet :=	!(cAliasSD)->(Eof()) .And. (cAliasSD)->D2_FILIAL+;
			        (cAliasSD)->D2_DOC+(cAliasSD)->D2_SERIE+;
			        (cAliasSD)->D2_CLIENTE+(cAliasSD)->D2_LOJA == F2_FILIAL+cChave
	EndCase

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MQuerySF1 º Autor ³ Julio Cesar        ºFecha ³  08-10-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta as querys para filtro nos arquivos SF1 e SD1         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MQuerySF1(aAreaSF1,cAliasSF1,cAliasSD1,cAliasQry,oReport)

Local cCliFor  := ""
Local cQuery   := ""
Local cCpos    := "" 
Local cCposSD1 := "" 
Local cOrdem   := ""
Local cDocSer  := ""
Local aStru    := {}
Local nPos     := 0
Local nI       := 0
Local nX       := 0
Local cSelect  := ""
Local cIdWhere := ""

//Armazena a area Original...
aAreaSF1 := GetArea()

cAliasSF1 := cAliasQry
cAliasSD1 := cAliasQry
cOrdem := "%" + SqlOrder(SD1->(IndexKey(1))) + "%"
cWhere :="%"
If MV_PAR19 == 2
	cWhere += " AND F1_MOEDA = "+Transform(MV_PAR18,PesqPict("SF1","F1_MOEDA",TamSX3("F1_MOEDA")[1],TamSX3("F1_MOEDA")[2]))
EndIf
cWhere +="%"

//SF1 - Campos de impostos
aStru := SF1->(dbStruct())

While .T.
	nPos := aScan(aStru,{|x| SubStr(x[1],1,9)=="F1_BASIMP" .Or. SubStr(x[1],1,9)=="F1_VALIMP"},nPos+1)
	If nPos == 0
		Exit
	Else
		cCpos += ", "+AllTrim(aStru[nPos][1])
	EndIf
End
cCpos += "%"
//SD1 - Campos de impostos
aStru := SD1->(dbStruct())
cCposSD1 := "%"
While .T.
	nPos := aScan(aStru,{|x| SubStr(x[1],1,9)=="D1_BASIMP" .Or. SubStr(x[1],1,9)=="D1_VALIMP"},nPos+1)
	If nPos == 0
		Exit
	Else
		cCposSD1 += ", "+AllTrim(aStru[nPos][1])
	EndIf
End
cCposSD1 += "%"
//Query para o arquivo SF1...
cSelect :="%F1_FILIAL, F1_DOC,"+ iif(SerieNfId("SF1",3,"F1_SERIE")<> "F1_SERIE", SerieNfId("SF1",3,"F1_SERIE")+", " ," ")
cSelect += "F1_SERIE, F1_FORNECE, F1_LOJA,F1_ESPECIE, F1_EMISSAO, F1_MOEDA, F1_TXMOEDA,F1_VALBRUT,F1_COND, F1_TIPO, F1_TIPODOC, F1_DTDIGIT"
cSelect += cCpos	
cIdWhere:= "% "+SerieNfId("SF1",3,"F1_SERIE")+" >='"+MV_PAR14+"' AND "+SerieNfId("SF1",3,"F1_SERIE")+" <='"+MV_PAR15+"'%"

oReport:Section(1):BeginQuery()	
BeginSql Alias cAliasSF1
	SELECT %Exp:cSelect%
	//query para arquivo SD1	
	,D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA,D1_COD, D1_GRUPO, D1_LOCAL, D1_TES, D1_VUNIT, 
	D1_TOTAL, D1_VALDESC,D1_QUANT %Exp:cCposSD1%
	
	FROM %table:SF1% SF1, %table:SD1% SD1
	
	WHERE F1_FILIAL = %xFilial:SF1%
	AND F1_DOC >= %Exp:MV_PAR12% AND F1_DOC <= %Exp:MV_PAR13%
	AND %Exp:cIdWhere%
	AND F1_FORNECE >= %Exp:MV_PAR08% AND F1_FORNECE <= %Exp:MV_PAR09%
	AND F1_ESPECIE = %Exp:cEspecie%
	AND F1_EMISSAO >= %Exp:DToS(MV_PAR03)% AND F1_EMISSAO <= %Exp:DToS(MV_PAR04)%
	AND F1_DTDIGIT >= %Exp:DToS(MV_PAR20)% AND F1_DTDIGIT <= %Exp:DToS(MV_PAR21)%
	AND SF1.%notdel%
	//---condicao para SD1
	AND D1_FILIAL = %Exp:xFilial("SD1")%
	AND D1_DOC = F1_DOC
	AND D1_SERIE = F1_SERIE
	AND D1_TIPO = F1_TIPO
	AND D1_TIPODOC = F1_TIPODOC
	AND D1_FORNECE = F1_FORNECE
	AND D1_LOJA = F1_LOJA
	AND D1_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND D1_GRUPO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
	AND D1_LOCAL BETWEEN %Exp:MV_PAR10% AND %Exp:MV_PAR11%
	AND D1_TES BETWEEN %Exp:MV_PAR16% AND %Exp:MV_PAR17%
	AND SD1.%notdel%
	//
	%Exp:cWhere%	
	ORDER BY %Exp:cOrdem%
EndSql 
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

dbSelectArea(cAliasSF1)
dbGoTop()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MQuerySF2 º Autor ³ Julio Cesar        ºFecha ³  08-10-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta as querys para filtro nos arquivos SF2 e SD2         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MQuerySF2(aAreaSF2,cAliasSF2,cAliasSD2,cAliasQry,oReport)

Local cCliFor  := ""
Local cQuery   := ""
Local cCpos    := "" 
Local cCposSD2 := "" 
Local cOrdem   := ""
Local cDocSer  := ""
Local aStru    := {}
Local nPos     := 0
Local nI       := 0
Local nX       := 0
Local cSelect  := ""
Local cIdWhere := ""

//Armazena a area Original...
aAreaSF2 := GetArea()

cOrdem := "%" + SqlOrder(SD2->(IndexKey(3))) + "%"
cWhere :="%"
If MV_PAR19 == 2
	cWhere += " AND F2_MOEDA = "+Transform(MV_PAR18,PesqPict("SF2","F2_MOEDA",TamSX3("F2_MOEDA")[1],TamSX3("F2_MOEDA")[2]))
EndIf
cWhere +="%"
cAliasSF2 := cAliasQry
cAliasSD2 := cAliasQry
                              
//SF2 - Acrescenta os campos refentes aos impostos...	
aStru := SF2->(dbStruct())

While .T.
	nPos := aScan(aStru,{|x| SubStr(x[1],1,9)=="F2_BASIMP" .Or. SubStr(x[1],1,9)=="F2_VALIMP"},nPos+1)
	If nPos == 0
		Exit
	Else
		cCpos += ", "+AllTrim(aStru[nPos][1])
	EndIf
End  
cCpos += "%"
//SD2 - Acrescenta os campos refentes aos impostos...	
aStru := SD2->(dbStruct())
cCposSD2 := "%"
While .T.
	nPos := aScan(aStru,{|x| SubStr(x[1],1,9)=="D2_BASIMP" .Or. SubStr(x[1],1,9)=="D2_VALIMP"},nPos+1)
	If nPos == 0
		Exit
	Else
		cCposSD2 += ", "+AllTrim(aStru[nPos][1])
	EndIf
End
cCposSD2 += "%"

cSelect:= "%F2_FILIAL, F2_DOC, "+ iif(SerieNfId("SF2",3,"F2_SERIE")<>"F2_SERIE", SerieNfId("SF2",3,"F2_SERIE")+", " ," ")
cSelect+= "F2_SERIE, F2_CLIENTE, F2_LOJA,F2_ESPECIE, F2_EMISSAO, F2_MOEDA, F2_TXMOEDA, F2_VALBRUT, F2_COND, F2_TIPO, F2_TIPODOC,"

cIdWhere:="%"+SerieNfId("SF2",3,"F2_SERIE")+" >='"+MV_PAR14+"' AND "+SerieNfId("SF2",3,"F2_SERIE")+" <='"+MV_PAR15+"'%"

If AllTrim(cCampoData) == "F2_DTDIGIT"
	
	cSelect+= " F2_DTDIGIT"+cCpos
	
	oReport:Section(1):BeginQuery()	
	BeginSql Alias cAliasQry

		SELECT %Exp:cSelect%
	
		,D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA,
		D2_COD, D2_GRUPO, D2_LOCAL, D2_TES, D2_PRCVEN, D2_TOTAL,
		D2_QUANT, D2_ITEM %Exp:cCposSD2%
	
		FROM %table:SF2% SF2, %table:SD2% SD2
		
		WHERE F2_FILIAL = %Exp:xFilial("SF2")%
		AND F2_DOC >= %Exp:MV_PAR12% AND F2_DOC <= %Exp:MV_PAR13%
		AND %Exp:cIdWhere%
		AND F2_CLIENTE >= %Exp:MV_PAR08% AND F2_CLIENTE <= %Exp:MV_PAR09%
		AND F2_ESPECIE = %Exp:cEspecie%
		AND F2_EMISSAO >= %Exp:DToS(MV_PAR03)% AND F2_EMISSAO <= %Exp:DToS(MV_PAR04)%
		AND F2_DTDIGIT >= %Exp:DToS(MV_PAR20)% AND  F2_DTDIGIT <= %Exp:DToS(MV_PAR21)%
		AND SF2.%notdel%
	
		AND D2_FILIAL = %Exp:xFilial("SD2")%
		AND D2_DOC = F2_DOC
	    AND D2_SERIE = F2_SERIE
	    AND D2_TIPO = F2_TIPO
	    AND D2_TIPODOC = F2_TIPODOC
		AND D2_CLIENTE = F2_CLIENTE
		AND D2_LOJA = F2_LOJA
		AND D2_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND D2_GRUPO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
		AND D2_LOCAL BETWEEN %Exp:MV_PAR10% AND %Exp:MV_PAR11%
		AND D2_TES BETWEEN %Exp:MV_PAR16% AND %Exp:MV_PAR17%
		AND SD2.%notdel%
		ORDER BY %Exp:cOrdem%
	EndSql
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
Else
	cSelect+= cCpos

	oReport:Section(1):BeginQuery()	
	BeginSql Alias cAliasQry

	SELECT %Exp:cSelect%

		,D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA,
		D2_COD, D2_GRUPO, D2_LOCAL, D2_TES, D2_PRCVEN, D2_TOTAL,
		D2_QUANT, D2_ITEM %Exp:cCposSD2%
		
		FROM %table:SF2% SF2, %table:SD2% SD2
		
		WHERE F2_FILIAL = %Exp:xFilial("SF2")%
		AND F2_DOC >= %Exp:MV_PAR12% AND F2_DOC <= %Exp:MV_PAR13%
		AND %Exp:cIdWhere%
		AND F2_CLIENTE >= %Exp:MV_PAR08% AND F2_CLIENTE <= %Exp:MV_PAR09%
		AND F2_ESPECIE = %Exp:cEspecie%
		AND F2_EMISSAO >= %Exp:DToS(MV_PAR03)% AND F2_EMISSAO <= %Exp:DToS(MV_PAR04)%
		AND SF2.%notdel%
	
		AND D2_DOC = F2_DOC
	    AND D2_SERIE = F2_SERIE
	    AND D2_TIPO = F2_TIPO
	    AND D2_TIPODOC = F2_TIPODOC
		AND D2_CLIENTE = F2_CLIENTE
		AND D2_LOJA = F2_LOJA
		AND D2_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND D2_GRUPO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
		AND D2_LOCAL BETWEEN %Exp:MV_PAR10% AND %Exp:MV_PAR11%
		AND D2_TES BETWEEN %Exp:MV_PAR16% AND %Exp:MV_PAR17%
		AND SD2.%notdel%
		ORDER BY %Exp:cOrdem%
	EndSql
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
EndIf

//Seleciona a area referente ao arquivo SF2...
dbSelectArea(cAliasSF2)   
dbGoTop()

Return .T.
