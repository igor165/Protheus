#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINR841.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR841  ³ Autor ³ William Pires          ³ Data ³ 13/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Disponibilidade Financeira                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Localizacao Republica Dominicana	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ACTUALIZACIONES SUFRIDAS DESDE EL DESARROLLO.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ FECHA  ³ BOPS     ³  MOTIVO DE LA ALTERACION            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano  ³09/12/16³SERINN001-140³se quita la creacion de tablas tem³±±
±±³              ³        ³          ³-porales y se asigna FWTemporaryTable³±±
±±³              ³        ³          ³en fun ReportPrint                   ³±±
±±³              ³        ³          ³En fun FINR841 actualiza TRepInUse() ³±±
±±³              ³        ³          ³si !TRepInUse() entonces mostrara msg³±±
±±³Alf. Medrano  ³12/01/17³SERINN001-140³Merge Main vs 12.1.15             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINR841()

Local oReport
Local aArea	:= GetArea()
Local lRet := .F.

Private cBanco	   := STR0074					//"BANCO"
Private cMoeda	   := STR0075					//"MONEDA"
Private cSaldoIni  := STR0062 + CRLF + STR0063	//"SALDO " ## "INICIO MES"
Private cReceitas  := STR0064 + CRLF + STR0065	//"DEPOSITOS Y " ## "CREDITOS"
Private cDespesas  := STR0066 + CRLF + STR0067	//"CHEQUES Y " ## " CARGOS"
Private cOutros    := STR0068					//"OTROS"
Private cSaldoAtu  := STR0069 + CRLF + STR0070	//"BALANCE " ## "ACTUAL"
Private cLimCred   := STR0071 + CRLF + STR0072	//"LINEA DE " ## "CREDITO"
Private cDiponivel := STR0073					//"DISPONIBLE"

Private cPerg	   := "FINR841"
Private aSelFil	   := {}
Private lTodasFil  := .F.
Private oTmpTable

//USO APENAS PARA TOP
#IFDEF TOP
	If TcSrvType() == "AS/400"
		HELP("FINR841",1,"HELP","FINR841",STR0076 + " TOPCONNECT",1,0)	//"Esta rotina está disponível somente para uso com"
		Return .F.
	EndIf
#ELSE
	HELP("FINR841",1,"HELP","FINR841",STR0076 + " TOPCONNECT",1,0)	//"Esta rotina está disponível somente para uso com"
	Return .F.
#ENDIF

If !TRepInUse()
	HELP("FINR841",1,"HELP","FINR841",STR0076 + " TREPORT",1,0)	//"Esta rotina está disponível somente para uso com"
	Return .F.
EndIf

lRet := Pergunte(cPerg,.T.)

If lRet

	If MV_PAR01 == 1 .AND. Len(aSelFil) <= 0
		aSelFil := AdmGetFil(@lTodasFil)
		If Len(aSelFil) <= 0
			Return
		EndIf
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()

EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ William Pires	  º Data ³  13/05/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 												              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport	 := NIL
Local oSecReg	 := NIL
Local oTxtFilial := NIL
Local cReport	 := "FINR841" 	//Nome do relatorio
Local cTitulo 	 := STR0001		//Relatorio Disponibilidade Financeira
Local cDescri 	 := STR0002		//Esta rotina irá emitir o Relatório Disponibilidade Financeira de um determinado período
Local cPerg		 := "FINR841"	//Nome do grupo de perguntas

Pergunte(cPerg,.F.)
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
oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo, oSecReg, oTxtFilial)}, cDescri)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//					Secao 01: Saldos das Moedas							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Este relatorio nao permite a personalizacao de exibicao de celulas > parametro uTable desabilitado
oSecReg := TRSection():New(oReport,cTitulo,/*uTable*/,/*aOrdem*/)


//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSecReg,"A6_NOME"   ,"SA6",cBanco    ,/*cPicture*/		      ,25					 ,,,	   ,,,,,.T.,,,)
TRCell():New(oSecReg,"A6_MOEDA"  ,"SA6",cMoeda    ,/*cPicture*/		      ,  					 ,,,"RIGHT",,,,,.T.,,,)
TRCell():New(oSecReg,"A6_SALANT" ,"SA6",cSaldoIni ,/*cPicture*/		      ,  					 ,,,	   ,,,,,.T.,,,)
TRCell():New(oSecReg,"VL_RECEITA",	   ,cReceitas ,"@E 999,999,999,999.99",TamSX3("A6_SALATU")[1],,,	   ,,,,,.T.,,,)
TRCell():New(oSecReg,"VL_DESPESA",	   ,cDespesas ,"@E 999,999,999,999.99",TamSX3("A6_SALATU")[1],,,	   ,,,,,.T.,,,)
TRCell():New(oSecReg,"VL_OUTROS" ,	   ,cOutros   ,"@E 999,999,999,999.99",TamSX3("A6_SALATU")[1],,,	   ,,,,,.T.,,,)
TRCell():New(oSecReg,"A6_SALATU" ,"SA6",cSaldoAtu ,/*cPicture*/		      ,  					 ,,,	   ,,,,,.T.,,,)
TRCell():New(oSecReg,"A6_LIMCRED","SA6",cLimCred  ,/*cPicture*/		      ,  					 ,,,	   ,,,,,.T.,,,)
TRCell():New(oSecReg,"VL_DISPONI",	   ,cDiponivel,"@E 999,999,999,999.99",TamSX3("A6_SALATU")[1],,,	   ,,,,,.T.,,,)

//Definindo alinhamento do cabeçalho das céluas
oSecReg:Cell("A6_NOME"   ):SetHeaderAlign("LEFT")
oSecReg:Cell("A6_MOEDA"  ):SetHeaderAlign("RIGHT")
oSecReg:Cell("A6_SALANT" ):SetHeaderAlign("RIGHT")
oSecReg:Cell("VL_RECEITA"):SetHeaderAlign("RIGHT")
oSecReg:Cell("VL_DESPESA"):SetHeaderAlign("RIGHT")
oSecReg:Cell("VL_OUTROS" ):SetHeaderAlign("RIGHT")
oSecReg:Cell("A6_SALATU" ):SetHeaderAlign("RIGHT")
oSecReg:Cell("A6_LIMCRED"):SetHeaderAlign("RIGHT")
oSecReg:Cell("VL_DISPONI"):SetHeaderAlign("RIGHT")

oSecReg:SetHeaderPage(.T.)//Define se imprime cabeçalho das células no topo da página


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//					Secao 02: Total por Filial							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTxtFilial := TRSection():New(oReport,"TOTAL")

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oTxtFilial,"E5_FILIAL","",STR0079,,70,,,,,,,,,,,.T.)
oTxtFilial:SetHeaderSection(.F.)
oTxtFilial:Cell("E5_FILIAL"):SetHeaderAlign("LEFT")

//Desabilita o botao Parametros
oReport:ParamReadOnly()

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportPrint  ºAutor  ³ William Pires  º Data ³  13/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINR841                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport, cTitulo, oSecReg, oTxtFilial)

Local aCampos     := {}
Local aFilTrb	  := {}
Local aMoedasTrb  := {}
Local aTotMoeda	  := {0,0,0,0,0,0,0}
Local aTotFil	  := {0,0,0,0,0,0,0}

Local dDataDe	  := MV_PAR02
Local dDataAte	  := MV_PAR03
Local dDataRef	  := MV_PAR12

Local cQuery      := ""
Local cAliasTrb   := ""
Local cAliasQry   := ""
Local cIndTrb	  := ""
Local cFil		  := ""
Local cQryBco	  := ""
Local cQryBcoAnt  := ""
Local cQryMoed	  := ""
Local cQryMoedAnt := ""

Local nTpSelFil	  := MV_PAR01
Local nBcoDe	  := MV_PAR04
Local nBcoAte	  := MV_PAR05
Local nNatDe	  := MV_PAR06
Local nNatAte	  := MV_PAR07
Local nMoeda	  := MV_PAR09
Local nTpConvData := MV_PAR11

Local nMoed
Local nReceita	  := 0
Local nDespesa	  := 0
Local nSaldoIni   := 0
Local nSaldoAtu   := 0
Local nDispon	  := 0
Local nOutros	  := 0
Local nLimCred	  := 0
Local nPasso	  := 0
Local nPasFil	  := 0
Local nPosic	  := 0
Local nX		  := 0
Local nY		  := 0

Local lAtuSldIni  := .F.
Local lSomaRec    := .F.
Local lSomaDes    := .F.
Local lSomaOut    := .F.
Local lPrtTotMRef := .F.
Local lImpMoedRef := .F.
Local lImpFil	  := .F.

Local lTdMoedas   := (MV_PAR08 == 2)						//.T. para gerar saldo em todas as moedas. Esta opcao desconsidera os parametros 09 a 12
Local lConvMoeda  := (MV_PAR08 == 1 .AND. MV_PAR10 == 1)	//.T. para converter todas as outras moedas pela Moeda Referencia (MV_PAR09)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               	   ³
//³ mv_par01               Seleciona Filiais			 ?             	   ³
//³ mv_par02               Periodo De 					 ?             	   ³
//³ mv_par03               Periodo Ate 					 ?             	   ³
//³ mv_par04               Do Banco         			 ?             	   ³
//³ mv_par05               Ate o Banco      			 ?             	   ³
//³ mv_par06               Da Natureza      			 ?             	   ³
//³ mv_par07               Ate a Natureza   			 ?             	   ³
//³ mv_par08               Moeda (Selecionar/Todas)		 ?             	   ³
//³ mv_par09               Moeda Referencia 			 ?             	   ³
//³ mv_par10               Outras Moedas              	 ?             	   ³
//³ mv_par11               Conv. Moedas pela Data		 ?			   	   ³
//³ mv_par12               Data Ref. para Conversao  	 ?			       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos campos do Arquivo de Trabalho                            ³
//³                                                                        ³
//³ aCampos {"ExpC1","ExpC2",ExpN3,ExpN4}							   	   ³
//³ ExpC1 : Nome do campo                                                  ³
//³ ExpC2 : Tipo do campo no formato Caracter                              ³
//³ ExpC3 : Tamanho do campo                                               ³
//³ ExpB4 : Qtde de decimais se o campo for do tipo numerico  			   ³
//³ 																	   ³
//³ TamSX3(NomeDoCampo)[1],TamSX3(NomeDoCampo)[2]						   ³
//³ 1=Tamanho do campo 2=Qtde decimal									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCampos, { "E5_FILIAL" , "C", TamSX3("E5_FILIAL" )[1] , 0 })
Aadd(aCampos, { "A6_COD"    , "C", TamSX3("A6_COD"    )[1] , 0 })
Aadd(aCampos, { "A6_NOME"   , "C", TamSX3("A6_NOME"   )[1] , 0 })
Aadd(aCampos, { "A6_MOEDA"  , "C", TamSX3("A6_MOEDA"  )[1] , 0 })
Aadd(aCampos, { "A6_SALANT" , "N", TamSX3("A6_SALANT" )[1] , TamSX3("A6_SALATU" )[2] })
Aadd(aCampos, { "VL_RECEITA", "N", TamSX3("A6_SALATU" )[1] , TamSX3("A6_SALATU" )[2] })
Aadd(aCampos, { "VL_DESPESA", "N", TamSX3("A6_SALATU" )[1] , TamSX3("A6_SALATU" )[2] })
Aadd(aCampos, { "VL_OUTROS" , "N", TamSX3("A6_SALATU" )[1] , TamSX3("A6_SALATU" )[2] })
Aadd(aCampos, { "A6_SALATU" , "N", TamSX3("A6_SALATU" )[1] , TamSX3("A6_SALATU" )[2] })
Aadd(aCampos, { "A6_LIMCRED", "N", TamSX3("A6_LIMCRED")[1] , TamSX3("A6_LIMCRED")[2] })
Aadd(aCampos, { "VL_DISPONI", "N", TamSX3("A6_SALATU" )[1] , TamSX3("A6_SALATU" )[2] })

cAliasTrb := CriaTrab(NIL , .F. )								// Atribui nome do Arquivo de Trabalho
oTmpTable := FWTemporaryTable():New(cAliasTrb)
oTmpTable:SetFields( aCampos ) 
//crea indice
oTmpTable:AddIndex('T1ORD', {"A6_COD","A6_MOEDA"})
//Creacion de la tabla
oTmpTable:Create()

dbSelectArea(cAliasTrb)

cAliasQry := GetNextAlias()

cQuery += "SELECT " + CRLF
cQuery += " SA6.A6_COD, SA6.A6_NOME, SA6.A6_AGENCIA, SA6.A6_NUMCON, SA6.A6_LIMCRED, SA6.A6_MOEDA, " + CRLF
cQuery += " SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_VALOR, SE5.E5_RECPAG, SE5.E5_TIPODOC, " + CRLF
cQuery += " SE5.E5_TIPO, SE5.E5_NATUREZ, SE5.E5_SITUACA, SE5.E5_NUMCHEQ " + CRLF
cQuery += "FROM " + CRLF
cQuery += " " + RetSqlName("SE5") + " SE5, " + RetSqlName("SA6") + " SA6 " + CRLF
cQuery += "WHERE " + CRLF

If nTpSelFil = 2	//Nao seleciona filiais, usa filial corrente
	cQuery += " SE5.E5_FILIAL = '" + xFilial("SE5") + "' AND " + CRLF
ElseIf !lTodasFil
	cQuery += " E5_FILIAL " + GetRngFil(aSelFil, "SE5") + " AND " + CRLF
EndIf

cQuery += " SE5.E5_BANCO    = SA6.A6_COD AND " + CRLF
cQuery += " SE5.E5_AGENCIA  = SA6.A6_AGENCIA AND " + CRLF
cQuery += " SE5.E5_CONTA    = SA6.A6_NUMCON AND "  + CRLF
cQuery += " SE5.E5_DATA    >= '" + DTOS(dDataDe)   + "' AND " + CRLF
cQuery += " SE5.E5_DATA    <= '" + DTOS(dDataAte)  + "' AND " + CRLF
cQuery += " SE5.E5_BANCO   >= '" + nBcoDe  + "' AND " + CRLF
cQuery += " SE5.E5_BANCO   <= '" + nBcoAte + "' AND " + CRLF
cQuery += " SE5.E5_NATUREZ >= '" + nNatDe  + "' AND " + CRLF
cQuery += " SE5.E5_NATUREZ <= '" + nNatAte + "' AND " + CRLF

//Verifica quais Moedas serao consideradas no relatorio
If !lTdMoedas .AND.	!lConvMoeda
	cQuery += " SA6.A6_MOEDA = " + STR(nMoeda,2) + " AND " + CRLF
Else
	cQuery += " SA6.A6_MOEDA >= 1  AND " + CRLF
	cQuery += " SA6.A6_MOEDA <= 99 AND " + CRLF
EndIf

//filtra motivos de baixa que geram movimentacao financeira
cQuery += " SE5.E5_TIPODOC NOT IN " + FormatIn("DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL/BA","/") + " AND " + CRLF
cQuery += " SE5.E5_SITUACA <> 'C' AND " + CRLF
cQuery += " SE5.D_E_L_E_T_ = ' ' AND " + CRLF
cQuery += " SA6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY " + CRLF
cQuery += " SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_BANCO, SE5.E5_MOEDA "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

//Ajusta a estrutura dos campos que não são do tipo caractere
TCSetField(cAliasQry,"A6_LIMCRED","N",14,2)
TCSetField(cAliasQry,"A6_MOEDA"	 ,"N", 2,0)
TCSetField(cAliasQry,"E5_DATA"   ,"D", 8,0)
TCSetField(cAliasQry,"E5_VALOR"	 ,"N",14,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Filtra os registros para compor os saldos num novo TRB				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasQry)	//Posiciona ponteiro do TRB
(cAliasQry)->(dbGoTop())

Do While (cAliasQry)->(!Eof())

	nPasso++  //Controle para comparacao de Banco+Moeda

	//Verifica se é preciso zerar os saldos na quebra de Banco+Moeda
	If nPasso > 1
		cQryBco  := AllTrim((cAliasQry)->A6_COD)
		cQryMoed := AllTrim(STR((cAliasQry)->A6_MOEDA,2))

		If cQryBco+cQryMoed <> cQryBcoAnt+cQryMoedAnt
			nReceita   := 0
			nDespesa   := 0
			nOutros    := 0
			lAtuSldIni := .T.
		EndIf
	EndIf

	//Atualiza Saldo Inicial na quebra de Banco+Moeda
	If nPasso == 1 .OR. lAtuSldIni
		nSaldoIni := RecSalBco((cAliasQry)->A6_COD,;
		 					   (cAliasQry)->A6_AGENCIA,;
						       (cAliasQry)->A6_NUMCON,;
						       (cAliasQry)->E5_DATA-1)
		lAtuSldIni := .F.

	EndIf

	// Efetua tratamento para titulos produzidos por Receitas, Despesas ou Titulos nao operacionais
	If (cAliasQry)->E5_RECPAG == "R" .AND. !Empty((cAliasQry)->E5_TIPODOC)
		nReceita += (cAliasQry)->E5_VALOR
		lSomaRec := .T.
	ElseIf (cAliasQry)->E5_RECPAG == "P" .AND. !Empty((cAliasQry)->E5_TIPODOC)
		nDespesa += (cAliasQry)->E5_VALOR
		lSomaDes := .T.
	//Receitas Nao Operacionais
	ElseIf (cAliasQry)->E5_RECPAG == "R" .AND. Empty((cAliasQry)->E5_TIPODOC)
		nOutros += (cAliasQry)->E5_VALOR
		lSomaOut := .T.
	//Despesas Nao Operacionais
	ElseIf (cAliasQry)->E5_RECPAG == "P" .AND. Empty((cAliasQry)->E5_TIPODOC)
		nOutros -= (cAliasQry)->E5_VALOR
		lSomaOut := .T.
	Endif

	nSaldoAtu := nSaldoIni + nReceita - nDespesa + nOutros
	nDispon   := nSaldoAtu + (cAliasQry)->A6_LIMCRED

	//Inicializa gravação no TRB que armazenara os saldos bancarios filtrados
	If (cAliasTrb)->(!DbSeek( (cAliasQry)->A6_COD + STR((cAliasQry)->A6_MOEDA,2) ) )
		//Inclusao
		RecLock(cAliasTrb,.T.)
			(cAliasTrb)->E5_FILIAL 	:= (cAliasQry)->E5_FILIAL
			(cAliasTrb)->A6_COD 	:= (cAliasQry)->A6_COD
			(cAliasTrb)->A6_NOME 	:= AllTrim((cAliasQry)->A6_NOME)
			(cAliasTrb)->A6_MOEDA	:= STR((cAliasQry)->A6_MOEDA,2)
			(cAliasTrb)->A6_SALANT  := nSaldoIni
			(cAliasTrb)->VL_RECEITA := nReceita
			(cAliasTrb)->VL_DESPESA := nDespesa
			(cAliasTrb)->VL_OUTROS	:= nOutros
			(cAliasTrb)->A6_SALATU	:= nSaldoAtu
			(cAliasTrb)->A6_LIMCRED	:= (cAliasQry)->A6_LIMCRED
			(cAliasTrb)->VL_DISPONI := nDispon
		MsUnlock()
	Else
		//Alteracao
		RecLock(cAliasTrb,.F.)
			//Acumula Receita, Despesa ou Outros Valores
			IIf(lSomaRec,(cAliasTrb)->VL_RECEITA += (cAliasQry)->E5_VALOR,NIL)
			IIf(lSomaDes,(cAliasTrb)->VL_DESPESA += (cAliasQry)->E5_VALOR,NIL)
			IIf(lSomaOut,(cAliasTrb)->VL_OUTROS  += (cAliasQry)->E5_VALOR,NIL)
			//Atualiza Saldo Atual e Vlr. Disponível
			(cAliasTrb)->A6_SALATU  := nSaldoAtu
			(cAliasTrb)->VL_DISPONI := nDispon
		MsUnlock()
	EndIf

	lSomaRec := .F.
	lSomaDes := .F.
	lSomaOut := .F.

	//Armazena Banco e Moeda para comparação no próximo loop
	cQryBcoAnt  := AllTrim((cAliasQry)->A6_COD)
	cQryMoedAnt := AllTrim(STR((cAliasQry)->A6_MOEDA,2))

	//Array de Filiais
	If AScan(aFilTrb, {|cFil| cFil == (cAliasQry)->E5_FILIAL } ) == 0
		Aadd(aFilTrb, (cAliasQry)->E5_FILIAL )
	EndIf

	//Array de Moedas
	If AScan(aMoedasTrb, {|nMoed| nMoed == (cAliasQry)->A6_MOEDA} ) == 0
		Aadd(aMoedasTrb, (cAliasQry)->A6_MOEDA)
	EndIf

	(cAliasQry)->(DbSkip())
EndDo

DbSelectArea(cAliasTrb)
(cAliasTrb)->(DbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Controle de Impressao por Filial										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nY := 1 To Len(aFilTrb)

	//Variaveis que precisar ser zeradas a cada loop de filial
	nPasFil	    := 0
	lPrtTotMRef := .F.
	aTotMoeda   := {0,0,0,0,0,0,0}
	aTotFil   	:= {0,0,0,0,0,0,0}

	//Impressao da descricao da filial
	oReport:SkipLine()
	oTxtFilial:Init()
	oTxtFilial:Cell("E5_FILIAL"):SetValue( GetAdvFval("SM0","M0_FILIAL",cEmpAnt+aFilTrb[nY]) )
	oTxtFilial:PrintLine()
	oTxtFilial:Finish()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Impressao do Saldo da Moeda Ref, se for selecionada opcao de conversao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lConvMoeda .AND. !lTdMoedas

		Do While (cAliasTrb)->(!Eof())

			If (cAliasTrb)->E5_FILIAL == aFilTrb[nY] .AND. Val((cAliasTrb)->A6_MOEDA) == nMoeda

				nPasFil++
				oSecReg:Init()

				oSecReg:Cell(cBanco	   ):SetValue( (cAliasTrb)->A6_NOME    )
				oSecReg:Cell(cMoeda	   ):SetValue( (cAliasTrb)->A6_MOEDA   )
				oSecReg:Cell(cSaldoIni ):SetValue( (cAliasTrb)->A6_SALANT  )
				oSecReg:Cell(cReceitas ):SetValue( (cAliasTrb)->VL_RECEITA )
				oSecReg:Cell(cDespesas ):SetValue( (cAliasTrb)->VL_DESPESA*(-1)) //exibir com sinal negativo
				oSecReg:Cell(cOutros   ):SetValue( (cAliasTrb)->VL_OUTROS  )
				oSecReg:Cell(cSaldoAtu ):SetValue( (cAliasTrb)->A6_SALATU  )
				oSecReg:Cell(cLimCred  ):SetValue( (cAliasTrb)->A6_LIMCRED )
				oSecReg:Cell(cDiponivel):SetValue( (cAliasTrb)->VL_DISPONI )

				oSecReg:PrintLine()

				aTotMoeda[1] += (cAliasTrb)->A6_SALANT	//Saldo Inicial
				aTotMoeda[2] += (cAliasTrb)->VL_RECEITA	//Receitas
				aTotMoeda[3] += (cAliasTrb)->VL_DESPESA	//Despesas
				aTotMoeda[4] += (cAliasTrb)->VL_OUTROS	//Outros
				aTotMoeda[5] += (cAliasTrb)->A6_SALATU	//Saldo Atual
				aTotMoeda[6] += (cAliasTrb)->A6_LIMCRED	//Limite Credito
				aTotMoeda[7] += (cAliasTrb)->VL_DISPONI	//Disponivel

				lPrtTotMRef := .T. //Controle de Impressao do Totalizador Moeda Ref.

			EndIf

			(cAliasTrb)->(DbSkip())
		EndDo

		//Finaliza exibicao da sessao
		If nPasFil > 0
			oSecReg:Finish()
		EndIf

		//Imprime Celulas com o Saldo Total da Moeda Ref.
		If lPrtTotMRef

			oSecReg:Init()

			oSecReg:Cell(cBanco    ):SetValue( STR0077+GetMv("MV_SIMB"+AllTrim(STR(nMoeda,2))) )	//"Total Bancos em "
			oSecReg:Cell(cMoeda    ):SetValue( CValToChar(nMoeda) )
			oSecReg:Cell(cSaldoIni ):SetValue( aTotMoeda[1] )
			oSecReg:Cell(cReceitas ):SetValue( aTotMoeda[2] )
			oSecReg:Cell(cDespesas ):SetValue( aTotMoeda[3]*(-1) )	//exibir valores negativos
			oSecReg:Cell(cOutros   ):SetValue( aTotMoeda[4] )
			oSecReg:Cell(cSaldoAtu ):SetValue( aTotMoeda[5] )
			oSecReg:Cell(cLimCred  ):SetValue( aTotMoeda[6] )
			oSecReg:Cell(cDiponivel):SetValue( aTotMoeda[7] )

			oSecReg:PrintLine()
			oSecReg:Finish()
			oReport:ThinLine()

			//Acumula para exibicao do Total Geral
			aTotFil[1] += aTotMoeda[1]
			aTotFil[2] += aTotMoeda[2]
			aTotFil[3] += aTotMoeda[3]
			aTotFil[4] += aTotMoeda[4]
			aTotFil[5] += aTotMoeda[5]
			aTotFil[6] += aTotMoeda[6]
			aTotFil[7] += aTotMoeda[7]

		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Impressao do Saldo das Outras Moedas com ou sem Conversao				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aMoedasTrb)

		nContReg := 0
		aTotMoeda := {0,0,0,0,0,0,0}

		DbSelectArea(cAliasTrb)
		(cAliasTrb)->(DbGoTop())

		Do While (cAliasTrb)->(!Eof())

			If (cAliasTrb)->E5_FILIAL == aFilTrb[nY] .AND. Val((cAliasTrb)->A6_MOEDA) == aMoedasTrb[nX]

				//Nao deve imprimir o saldo da Moeda Ref. se for seleciona a opcao de conversao
				If lConvMoeda .AND. Val((cAliasTrb)->A6_MOEDA) == nMoeda
					(cAliasTrb)->(DbSkip())
					Loop
				EndIf

				nContReg++
				oSecReg:Init()

				//Imprime saldo sem opcao de conversao
				If !lConvMoeda
					oSecReg:Cell(cBanco	   ):SetValue( (cAliasTrb)->A6_NOME    )
					oSecReg:Cell(cMoeda	   ):SetValue( (cAliasTrb)->A6_MOEDA   )
					oSecReg:Cell(cSaldoIni ):SetValue( (cAliasTrb)->A6_SALANT  )
					oSecReg:Cell(cReceitas ):SetValue( (cAliasTrb)->VL_RECEITA )
					oSecReg:Cell(cDespesas ):SetValue( (cAliasTrb)->VL_DESPESA*(-1))
					oSecReg:Cell(cOutros   ):SetValue( (cAliasTrb)->VL_OUTROS  )
					oSecReg:Cell(cSaldoAtu ):SetValue( (cAliasTrb)->A6_SALATU  )
					oSecReg:Cell(cLimCred  ):SetValue( (cAliasTrb)->A6_LIMCRED )
					oSecReg:Cell(cDiponivel):SetValue( (cAliasTrb)->VL_DISPONI )
				//Imprime saldo convertido pela moeda ref
				Else
					oSecReg:Cell(cBanco	   ):SetValue( (cAliasTrb)->A6_NOME  )
					oSecReg:Cell(cMoeda	   ):SetValue( (cAliasTrb)->A6_MOEDA )
					oSecReg:Cell(cSaldoIni ):SetValue( XMoeda((cAliasTrb)->A6_SALANT , aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/) )
					oSecReg:Cell(cReceitas ):SetValue( XMoeda((cAliasTrb)->VL_RECEITA, aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/) )
					oSecReg:Cell(cDespesas ):SetValue( XMoeda((cAliasTrb)->VL_DESPESA, aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)*(-1) )
					oSecReg:Cell(cOutros   ):SetValue( XMoeda((cAliasTrb)->VL_OUTROS , aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/) )
					oSecReg:Cell(cSaldoAtu ):SetValue( XMoeda((cAliasTrb)->A6_SALATU , aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/) )
					oSecReg:Cell(cLimCred  ):SetValue( XMoeda((cAliasTrb)->A6_LIMCRED, aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/) )
					oSecReg:Cell(cDiponivel):SetValue( XMoeda((cAliasTrb)->VL_DISPONI, aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/) )
				EndIf

				oSecReg:PrintLine()

				aTotMoeda[1] += (cAliasTrb)->A6_SALANT	//Saldo Inicial
				aTotMoeda[2] += (cAliasTrb)->VL_RECEITA	//Receitas
				aTotMoeda[3] += (cAliasTrb)->VL_DESPESA	//Despesas
				aTotMoeda[4] += (cAliasTrb)->VL_OUTROS	//Outros
				aTotMoeda[5] += (cAliasTrb)->A6_SALATU	//Saldo Atual
				aTotMoeda[6] += (cAliasTrb)->A6_LIMCRED	//Limite Credito
				aTotMoeda[7] += (cAliasTrb)->VL_DISPONI	//Disponivel

			EndIf

			(cAliasTrb)->(DbSkip())
		EndDo

		If nContReg > 0
			oSecReg:Finish()

			//Inicio da Impressao dos Totais por Moeda
			oSecReg:Init()

			If !lConvMoeda
				oSecReg:Cell(cBanco    ):SetValue( STR0077+GetMv("MV_SIMB"+AllTrim(STR(aMoedasTrb[nX],2))) ) //"Total Bancos em "
				oSecReg:Cell(cMoeda    ):SetValue( CValToChar(aMoedasTrb[nX]) )
				oSecReg:Cell(cSaldoIni ):SetValue( aTotMoeda[1] )
				oSecReg:Cell(cReceitas ):SetValue( aTotMoeda[2] )
				oSecReg:Cell(cDespesas ):SetValue( aTotMoeda[3]*(-1) )
				oSecReg:Cell(cOutros   ):SetValue( aTotMoeda[4] )
				oSecReg:Cell(cSaldoAtu ):SetValue( aTotMoeda[5] )
				oSecReg:Cell(cLimCred  ):SetValue( aTotMoeda[6] )
				oSecReg:Cell(cDiponivel):SetValue( aTotMoeda[7] )
			Else
				//conversao do saldo nas variaveis para impressao
				nSaldoIni := XMoeda(aTotMoeda[1], aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)
				nReceita  := XMoeda(aTotMoeda[2], aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)
				nDespesa  := XMoeda(aTotMoeda[3], aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)*(-1)
				nOutros	  := XMoeda(aTotMoeda[4], aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)
				nSaldoAtu := XMoeda(aTotMoeda[5], aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)
				nLimCred  := XMoeda(aTotMoeda[6], aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)
				nDispon	  := XMoeda(aTotMoeda[7], aMoedasTrb[nX], nMoeda, IIf(nTpConvData == 2 .AND. !Empty(dDataRef), dDataRef, DDATABASE),2,/*nTaxap*/,/*nTaxad*/)

				//Saldo Total da Moeda Ref. convertido em outra moeda
				oSecReg:Cell(cBanco    ):SetValue( STR0078+GetMv("MV_SIMB"+AllTrim(STR(nMoeda,2))) ) //"Equivalente em "
				oSecReg:Cell(cMoeda    ):SetValue( CValToChar(aMoedasTrb[nX]) )
				oSecReg:Cell(cSaldoIni ):SetValue( nSaldoIni )
				oSecReg:Cell(cReceitas ):SetValue( nReceita  )
				oSecReg:Cell(cDespesas ):SetValue( nDespesa  )	//exibir valores negativos
				oSecReg:Cell(cOutros   ):SetValue( nOutros   )
				oSecReg:Cell(cSaldoAtu ):SetValue( nSaldoAtu )
				oSecReg:Cell(cLimCred  ):SetValue( nLimCred  )
				oSecReg:Cell(cDiponivel):SetValue( nDispon   )

				//Acumula para exibicao do Total Geral
				aTotFil[1] += nSaldoIni
				aTotFil[2] += nReceita
				aTotFil[3] += nDespesa
				aTotFil[4] += nOutros
				aTotFil[5] += nSaldoAtu
				aTotFil[6] += nLimCred
				aTotFil[7] += nDispon

			EndIf

			oSecReg:PrintLine()
			oSecReg:Finish()
			oReport:ThinLine()

		EndIf

	Next nX

	//Imprime linha Total Geral qdo a opcao de conversao for selecionada
	If lConvMoeda
		oSecReg:Init()

		oSecReg:Cell(cBanco    ):SetValue( STR0080 + " ----->")	//"TOTAL GERAL"
		oSecReg:Cell(cMoeda    ):SetValue( CValToChar(nMoeda) )
		oSecReg:Cell(cSaldoIni ):SetValue( aTotFil[1] )
		oSecReg:Cell(cReceitas ):SetValue( aTotFil[2] )
		oSecReg:Cell(cDespesas ):SetValue( aTotFil[3]*(-1) )
		oSecReg:Cell(cOutros   ):SetValue( aTotFil[4] )
		oSecReg:Cell(cSaldoAtu ):SetValue( aTotFil[5] )
		oSecReg:Cell(cLimCred  ):SetValue( aTotFil[6] )
		oSecReg:Cell(cDiponivel):SetValue( aTotFil[7] )

		oSecReg:PrintLine()
		oSecReg:Finish()

		oReport:SkipLine()
		oReport:FatLine()
	EndIf

Next nY


(cAliasQry)->(DbCloseArea())	//Fechando Area da Query
(cAliasTrb)->(DbCloseArea())	//Fechando Area do TRB


If oTmpTable <> Nil  
	oTmpTable:Delete() 
	oTmpTable := Nil 
Endif
Return
