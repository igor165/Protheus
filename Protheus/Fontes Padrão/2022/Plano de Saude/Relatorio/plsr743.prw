
#INCLUDE "PROTHEUS.CH"
static objCENFUNLGP := CENFUNLGP():New()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSR743  ³ Autor ³ Alexandre Inacio Lemes³ Data ³25/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relacao de usuarios ativos em determinado mes sepa-³±±
±±³          ³ rado por operadora e pessoa fisica ou juridica.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR743(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsR743()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	PlsR743R3()
EndIf
                                               
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef³Autor  ³Alexandre Inacio Lemes ³Data  ³25/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relacao de usuarios ativos em determinado mes sepa-³±±
±±³          ³ rado por operadora e pessoa fisica ou juridica.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local cTitle := "Relatorio de Inclusoes e Exclusao de Usuarios por Produto" //"Relatorio de Inclusoes e Exclusao de Usuarios por Produto"
Local oReport 
Local oSection1 
Local oSection2 
Local oCell         
Local oBreak
Local pQuant	:= "@EZ 9999999"
Local pQuantG	:= "@E 9999999"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01    Operadora                                        ³
//³ mv_par02    Produto de                                       ³
//³ mv_par03    Produto ate                                      ³
//³ mv_par04    Mes/Ano de                                       ³
//³ mv_par05    Mes/Ano Ate                                      ³
//³ mv_par06    Fisica/Juridica/Todos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("PLR741",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New("PLSR743",cTitle,"PLR741", {|oReport| ReportPrint(oReport)},"Este programa tem como objetivo imprimir a relacao sintetica de usuarios incluidos e excluidos mes a mes")//"Este programa tem como objetivo imprimir a relacao sintetica de usuarios incluidos e excluidos mes a mes"
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1:= TRSection():New(oReport,"Categoria",{"BA1","BA2","TRB"},/*aOrdem*/)
oSection1:SetHeaderSection(.F.)
TRCell():New(oSection1,"PFPJ"     ,"TRB","Categoria"/*Titulo*/,"@!"     ,40,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:SetNoFilter("BA2")
oSection1:SetReadOnly(.T.)

oSection2:= TRSection():New(oSection1,"Produtos",{"BA1","BA2","TRB"},/*aOrdem*/)
oSection2:SetHeaderPage()
oSection2:SetNoFilter("BA2")
oSection2:SetReadOnly(.T.)

TRCell():New(oSection2,"PRODUTO"  ,"TRB","Produtos ","@!"  ,20  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"MES01EXC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES01INC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES02EXC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES02INC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES03EXC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES03INC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES04EXC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES04INC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES05EXC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES05INC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES06EXC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"MES06INC" ,     ,/*Titulo*/,pQuant,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"TOTALEXC" ,     ,"--- Total"+CRLF+"Excl.",pQuantG,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"TOTALINC" ,     ,"Geral ---"+CRLF+"Incl.",pQuantG,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection2,"RESULTADO",     ,"Resultado"+CRLF+"Incl-Excl",pQuantG,	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

oBreak := TRBreak():New(oSection1,oSection1:Cell("PFPJ"),"Subtotal",.F.)
TRFunction():New(oSection2:Cell("MES01EXC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Exclusoes do primeiro mes"
TRFunction():New(oSection2:Cell("MES01INC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Inclusoes do segundo mes"
TRFunction():New(oSection2:Cell("MES02EXC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Exclusoes do primeiro mes"
TRFunction():New(oSection2:Cell("MES02INC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Inclusoes do segundo mes"
TRFunction():New(oSection2:Cell("MES03EXC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Exclusoes do primeiro mes"
TRFunction():New(oSection2:Cell("MES03INC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Inclusoes do segundo mes"
TRFunction():New(oSection2:Cell("MES04EXC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Exclusoes do primeiro mes"
TRFunction():New(oSection2:Cell("MES04INC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Inclusoes do segundo mes"
TRFunction():New(oSection2:Cell("MES05EXC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Exclusoes do primeiro mes"
TRFunction():New(oSection2:Cell("MES05INC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Inclusoes do segundo mes"
TRFunction():New(oSection2:Cell("MES06EXC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Exclusoes do primeiro mes"
TRFunction():New(oSection2:Cell("MES06INC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Inclusoes do segundo mes"
TRFunction():New(oSection2:Cell("TOTALEXC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Exclusoes Geral"          
TRFunction():New(oSection2:Cell("TOTALINC") ,NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total de Inclusoes Geral"          
TRFunction():New(oSection2:Cell("RESULTADO"),NIL,"SUM",oBreak,,pQuantG,/*uFormula*/,.F.,.T.) //"Total do Reusultado"               

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Alexandre Inacio Lemes ³Data  ³01/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relacao de usuarios ativos em determinado mes sepa-³±±
±±³          ³ rado por operadora e pessoa fisica ou juridica.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1) 

Local aMeses    := { 'Janeiro','Fevereiro','Marco','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'}
Local aStruct   := {}

Local cArqTrab  := CriaTrab(Nil,.F.)
Local cArqTot   := ""
Local cSQL      := ""
Local cMesIni   := mv_par04
Local cMesFim   := mv_par05
Local cAno      := ""
                
Local dDatIni   := CTOD("01/"+Left(cMesIni,2)+"/"+Right(cMesIni,2))
Local dDatFim   := dDataBase

Local nQtdMes   := QtdMes(cMesIni, cMesFim)
Local nMes		:= 0
Local nX        := 0

Local oTempTRB

If nQtdMes > 6
	MsgStop("Colocar periodo menor ou igual a 06 meses!")
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de Trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aStruct , {"DATBAS"    ,"D",08, 0} )
Aadd(aStruct , {"BA3_TIPOUS","C",01, 0} )
Aadd(aStruct , {"BA3_CODPLA","C",04, 0} )
Aadd(aStruct , {"TOTINCL"   ,"N",10, 0} )
Aadd(aStruct , {"TOTEXCL"   ,"N",10, 0} )
Aadd(aStruct , {"PRODUTO"   ,"C",20, 0} )
Aadd(aStruct , {"PFPJ"      ,"C",40, 0} )

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TRB" )
oTempTRB:SetFields( aStruct )
oTempTRB:AddIndex( "INDTRB",{ "BA3_TIPOUS","BA3_CODPLA","DATBAS" } )
	
if( select( "TRB" ) > 0 )
	TRB->( dbCloseArea() )
endIf
	
oTempTRB:Create()
      
cTitulo:= "Relacao de Exclusoes e Inclusoes de Usuarios por Produto  ===> Operadora : "+mv_par01+" - "+ Padr(Posicione("BA0",1,xFilial("BA0")+mv_par01,"BA0_NOMINT"),45)
oReport:SetTitle(cTitulo)

For nX := 1 TO nQtdMes

	dDatIni := CTOD("01/"+Left(cMesIni,2)+"/"+Right(cMesIni,2))
	
	If Val(Left(cMesIni,2)) + 1 > 12
		cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
		nMesIni := 1
	Else
		cAno    := StrZero(Val(Right(cMesIni,4)),4)
		nMesIni := Val(Left(cMesIni,2)) + 1
	EndIf

	oSection2:Cell("MES"+StrZero(nX,2)+"EXC"):SetTitle( PadL(aMeses[Val(Left(cMesIni,2))],9,'-') + CRLF + "Excl.")
	oSection2:Cell("MES"+StrZero(nX,2)+"INC"):SetTitle("/"+Right(cMesIni,2)+'------' + CRLF + "Incl.")
	
	cMesIni := StrZero(nMesIni,2)+cAno
	
	dDatFim := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) ) - 1
	
	cSQL := "SELECT BA3.BA3_TIPOUS, BA3.BA3_CODPLA,COUNT(BA1_CODEMP) AS TOTUSU FROM  "
	cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
	//--relacionar usuario com familia
	cSQL += "WHERE "
	cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
	cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
	cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
	cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
	//--considerar somente registros validos
	cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
	//--condicao principal
	cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
	//--faixa de produtos
	cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
	cSQL += "	AND "
	cSQL += "	BA1.BA1_DATINC >='"+DTOS(dDatIni)+"' AND BA1.BA1_DATINC <= '"+DTOS(dDatFim)+"' "
	
	If mv_par06 == 1
		cSQL += " AND BA3_TIPOUS = '1' "
	ElseIf mv_par06 == 2
		cSQL += " AND BA3_TIPOUS = '2' "
	EndIf
	
	cSQL += " GROUP BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	cSQL += " ORDER BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	
	PLSQuery(cSQL,cArqTrab)
	
	(cArqTrab)->(DbGoTop())
	
	dbSelectArea(cArqTrab)
	
	While (cArqTrab)->(! Eof())
		RecLock("TRB",.T.)
		TRB->DATBAS 	:= dDatFim
		TRB->BA3_TIPOUS := (cArqTrab)->BA3_TIPOUS
		TRB->BA3_CODPLA := (cArqTrab)->BA3_CODPLA
		TRB->TOTINCL 	:= (cArqTrab)->TOTUSU
		TRB->PRODUTO    := Padr( Posicione("BI3",1,xFilial("BI3")+mv_par01+TRB->BA3_CODPLA,"BI3_NREDUZ"), 20)

		If TRB->BA3_TIPOUS == "1"
			TRB->PFPJ := "*** P E S S O A    F I S I C A ***     "
		ElseIf TRB->BA3_TIPOUS == "2"
			TRB->PFPJ := "*** P E S S O A    J U R I D I C A  ***"
		ElseIf Empty(TRB->BA3_TIPOUS)
			TRB->PFPJ := "***    ***                             "
		EndIf
		TRB->(MsUnlock())

		(cArqTrab)->(DbSkip())
	EndDo

	(cArqTrab)->(dbCloseArea())
	
	cSQL := "SELECT BA3.BA3_TIPOUS, BA3.BA3_CODPLA,COUNT(BA1_CODEMP) AS TOTUSU FROM "
	cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
	//--relacionar usuario com familia
	cSQL += "WHERE "
	cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
	cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
	cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
	cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
	//--considerar somente registros validos
	cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
	//--condicao principal
	cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
	//--faixa de produtos
	cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
	cSQL += "	AND "
	cSQL += "	BA1.BA1_DATBLO >='"+DTOS(dDatIni)+"' AND BA1.BA1_DATBLO <= '"+DTOS(dDatFim)+"' "
	
	If mv_par06 == 1
		cSQL += " AND BA3_TIPOUS = '1' "
	ElseIf mv_par06 == 2
		cSQL += " AND BA3_TIPOUS = '2' "
	EndIf
	
	cSQL += " GROUP BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	cSQL += " ORDER BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	
	PLSQuery(cSQL,cArqTrab)
	
	(cArqTrab)->(DbGoTop())
	
	dbSelectArea(cArqTrab)
	
	While (cArqTrab)->(!Eof())
		If TRB->(! dbSeek((cArqTrab)->(BA3_TIPOUS+BA3_CODPLA+DTOS(dDatFim))))
			RecLock("TRB",.T.)
			TRB->DATBAS 	:= dDatFim
			TRB->BA3_TIPOUS := (cArqTrab)->BA3_TIPOUS
			TRB->BA3_CODPLA := (cArqTrab)->BA3_CODPLA
			TRB->PRODUTO    := Padr( Posicione("BI3",1,xFilial("BI3")+mv_par01+TRB->BA3_CODPLA,"BI3_NREDUZ"), 20)

			If TRB->BA3_TIPOUS == "1"
				TRB->PFPJ := "*** P E S S O A    F I S I C A ***     "
			ElseIf TRB->BA3_TIPOUS == "2"
				TRB->PFPJ := "*** P E S S O A    J U R I D I C A  ***"
			ElseIf Empty(TRB->BA3_TIPOUS)
				TRB->PFPJ := "***    ***                             "
			EndIf
	
        Else
			RecLock("TRB",.F.)
		EndIf
		TRB->TOTEXCL 		+= (cArqTrab)->TOTUSU
		TRB->(MsUnlock())

		(cArqTrab)->(DbSkip())
	EndDo
	(cArqTrab)->(dbCloseArea())

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita celulas fora do periodo selecionado               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := nQtdMes+1 TO 6
	oSection2:Cell("MES"+StrZero(nX,2)+"EXC"):Disable()
	oSection2:Cell("MES"+StrZero(nX,2)+"INC"):Disable()
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Relatorio                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
oSection1:Init()
oReport:SetMeter(RecCount())		

While !oReport:Cancel() .And. TRB->(!Eof()) 
	
	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()

	cTipo := TRB->BA3_TIPOUS
	aSubTot := {}

	oSection1:PrintLine()
	oReport:SkipLine()
	
	While !oReport:Cancel() .And. TRB->(! Eof() .And. BA3_TIPOUS == cTipo)

		cProd := TRB->BA3_CODPLA
		nExclusao := 0
		nInclusao := 0
		
		oSection2:Init()
		oSection2:Cell("PRODUTO"):SetValue(TRB->PRODUTO)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializacao de todas as celulas elegiveis para impressao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX :=1 To nQtdMes
			oSection2:Cell("MES"+StrZero(nX,2)+"EXC"):SetValue(0)
			oSection2:Cell("MES"+StrZero(nX,2)+"INC"):SetValue(0)
		Next

		While !oReport:Cancel() .And. TRB->(! Eof() .And. BA3_TIPOUS+TRB->BA3_CODPLA == cTipo+cProd)
			
			nMes := QtdMes(mv_par04, StrZero(Month( TRB->DATBAS ),2)+"/"+StrZero(Year( TRB->DATBAS ),4))
			
            If nMes == 1
				oSection2:Cell("MES01EXC"):SetValue(TRB->TOTEXCL)
				oSection2:Cell("MES01INC"):SetValue(TRB->TOTINCL)
            ElseIf nMes == 2
				oSection2:Cell("MES02EXC"):SetValue(TRB->TOTEXCL)
				oSection2:Cell("MES02INC"):SetValue(TRB->TOTINCL)
            ElseIf nMes == 3
				oSection2:Cell("MES03EXC"):SetValue(TRB->TOTEXCL)
				oSection2:Cell("MES03INC"):SetValue(TRB->TOTINCL)
            ElseIf nMes == 4
				oSection2:Cell("MES04EXC"):SetValue(TRB->TOTEXCL)
				oSection2:Cell("MES04INC"):SetValue(TRB->TOTINCL)
            ElseIf nMes == 5
				oSection2:Cell("MES05EXC"):SetValue(TRB->TOTEXCL)
				oSection2:Cell("MES05INC"):SetValue(TRB->TOTINCL)
            ElseIf nMes == 6
				oSection2:Cell("MES06EXC"):SetValue(TRB->TOTEXCL)
				oSection2:Cell("MES06INC"):SetValue(TRB->TOTINCL)
            EndIf
			nInclusao += TRB->TOTINCL
			nExclusao += TRB->TOTEXCL
			
			TRB->(DbSkip())
		EndDo
		
		oSection2:Cell("TOTALEXC"):SetValue(nExclusao)
		oSection2:Cell("TOTALINC"):SetValue(nInclusao)
		oSection2:Cell("RESULTADO"):SetValue(nInclusao-nExclusao)

		oSection2:PrintLine()

	EndDo
EndDo

oSection1:Finish()
oSection2:Finish()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if( select( "TRB" ) > 0 )
	oTempTRB:delete()
endIf   

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR743R3  ºAutor  ³Paulo Carnelossi   º Data ³  31/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relacao de usuarios ativos em determinado mes sepa- º±±
±±º          ³rado por operadora e pessoa fisica ou juridica              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR743R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao sintetica de "
Local cDesc2 := "usuarios incluidos e excluidos mes a mes"
Local cDesc3 := ""
Local cString := "BA1"
Local Tamanho := "G"
Local aAlias := {}

PRIVATE cTitulo:= "Relatorio de Inclusoes e Exclusao de Usuarios por Produto"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR741"
Private nomeprog:= "PLSR743" 
Private nLastKey:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1:= ""
cabec2:= ""
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "PLR743"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

aAlias := {"BA0","BI3"}
objCENFUNLGP:setAlias(aAlias)

RptStatus({|lEnd| PLSR743Imp(@lEnd,wnRel,cString)},cTitulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR743Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 31/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao relacao de Inclusao e Exclusao de Usuarios por mes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR743Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR743Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo
Local nPos, nPosTot, nCol, nExclusao, nInclusao

LOCAL cSQL, cSQL2
Local cArqTrab  := CriaTrab(nil,.F.)

Local cCodOpe  := mv_par01
Local cProd
Local lTitulo, cCodEmp, cCodPro, cDatExc
Local aMeses   := { 'Janeiro','Fevereiro','Marco','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'}
Local nQtdMes, nAuxQtdMes,nX

Local aStruct  := { {"DATBAS", "D", 8, 0}, {"BA3_TIPOUS", "C", 1, 0}, {"BA3_CODPLA", "C", 04, 0}, {"TOTINCL", "N", 10, 0}, {"TOTEXCL", "N", 10, 0} }
Local oTempTRB

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TRB" )
oTempTRB:SetFields( aStruct )
oTempTRB:AddIndex( "INDTRB",{ "BA3_TIPOUS","BA3_CODPLA","DATBAS" } )
	
if( select( "TRB" ) > 0 )
	TRB->( dbCloseArea() )
endIf
	
oTempTRB:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cTitulo :=	"Relacao de Exclusoes e Inclusoes de Usuarios por Produto "
cTitulo +=  "   ===> Operadora : "+cCodOpe+" - "+  objCENFUNLGP:verCamNPR( "BA0_NOMINT" , Padr(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"),45) )

nTipo:=GetMv("MV_COMP")

cMesIni := mv_par04
cMesFim := mv_par05

nQtdMes := QtdMes(cMesIni, cMesFim)

If nQtdMes > 6
	MsgStop("Colocar periodo menor ou igual a 06 meses!")
	Return
EndIf


Cabec1 := Space(21)
Cabec2 := PadR("Produtos",21)

For nX := 1 TO nQtdMes
	
	Cabec1 += " +"+PadC(aMeses[Val(Left(cMesIni,2))]+"/"+Right(cMesIni,2),17,"-")+"+"
	Cabec2 += PadL("Excl.     Incl.",20)
	
	dDatIni := CTOD("01/"+Left(cMesIni,2)+"/"+Right(cMesIni,2))
	
	If Val(Left(cMesIni,2)) + 1 > 12
		cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
		nMesIni := 1
	Else
		cAno    := StrZero(Val(Right(cMesIni,4)),4)
		nMesIni := Val(Left(cMesIni,2)) + 1
	EndIf
	
	cMesIni := StrZero(nMesIni,2)+cAno
	
	dDatFim := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) ) - 1
	
	cSQL := "SELECT BA3.BA3_TIPOUS, BA3.BA3_CODPLA,COUNT(BA1_CODEMP) AS TOTUSU FROM  "
	cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
	//--relacionar usuario com familia
	cSQL += "WHERE "
	cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
	cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
	cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
	cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
	//--considerar somente registros validos
	cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
	//--condicao principal
	cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
	//--faixa de produtos
	cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
	
	cSQL += "	AND "
	
	cSQL += "	BA1.BA1_DATINC >='"+DTOS(dDatIni)+"' AND BA1.BA1_DATINC <= '"+DTOS(dDatFim)+"' "
	
	If mv_par06 == 1
		cSQL += " AND BA3_TIPOUS = '1' "
	ElseIf mv_par06 == 2
		cSQL += " AND BA3_TIPOUS = '2' "
	EndIf
	
	cSQL += " GROUP BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	cSQL += " ORDER BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	
	PLSQuery(cSQL,cArqTrab)
	
	(cArqTrab)->(DbGoTop())
	
	dbSelectArea(cArqTrab)
	SetRegua(RecCount())
	
	While (cArqTrab)->(! Eof())
		
		IncRegua()
		
		TRB->(dbAppend())
		
		TRB->DATBAS 		:= dDatFim
		TRB->BA3_TIPOUS 	:= (cArqTrab)->BA3_TIPOUS
		TRB->BA3_CODPLA 	:= (cArqTrab)->BA3_CODPLA
		TRB->TOTINCL 		:= (cArqTrab)->TOTUSU
		
		(cArqTrab)->(DbSkip())
		
	EndDo
	
	(cArqTrab)->(dbCloseArea())
	
	cSQL := "SELECT BA3.BA3_TIPOUS, BA3.BA3_CODPLA,COUNT(BA1_CODEMP) AS TOTUSU FROM "
	cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
	//--relacionar usuario com familia
	cSQL += "WHERE "
	cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
	cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
	cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
	cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
	//--considerar somente registros validos
	cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
	//--condicao principal
	cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
	//--faixa de produtos
	cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
	
	cSQL += "	AND "
	
	cSQL += "	BA1.BA1_DATBLO >='"+DTOS(dDatIni)+"' AND BA1.BA1_DATBLO <= '"+DTOS(dDatFim)+"' "
	
	If mv_par06 == 1
		cSQL += " AND BA3_TIPOUS = '1' "
	ElseIf mv_par06 == 2
		cSQL += " AND BA3_TIPOUS = '2' "
	EndIf
	
	cSQL += " GROUP BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	cSQL += " ORDER BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	
	PLSQuery(cSQL,cArqTrab)
	
	(cArqTrab)->(DbGoTop())
	
	dbSelectArea(cArqTrab)
	SetRegua(RecCount())
	
	While (cArqTrab)->(! Eof())
		
		IncRegua()
		
		If TRB->(! dbSeek((cArqTrab)->(BA3_TIPOUS+BA3_CODPLA+DTOS(dDatFim))))
			
			TRB->(dbAppend())
			
			TRB->DATBAS 		:= dDatFim
			TRB->BA3_TIPOUS 	:= (cArqTrab)->BA3_TIPOUS
			TRB->BA3_CODPLA 	:= (cArqTrab)->BA3_CODPLA
			
		EndIf
		
		TRB->TOTEXCL 		+= (cArqTrab)->TOTUSU
		
		(cArqTrab)->(DbSkip())
		
	EndDo
	
	(cArqTrab)->(dbCloseArea())
	
Next nX

Cabec1 += " +"+PadC("Total Geral",17,"-")+"+"
Cabec2 += PadL("Excl.     Incl.",20)

Cabec1 += " +"+PadC("RESULTADO",17,"-")+"+"
Cabec2 += PadC("I-E",20)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se nao existir registros...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTotGer := {}
dbSelectArea("TRB")

SetRegua(RecCount())

TRB->(dbGotop())

While TRB->( ! Eof())
	
	IncRegua()
	
	If TRB->BA3_TIPOUS == "1"
		cSubTitulo := "*** P E S S O A    F I S I C A ***   "
		
	ElseIf TRB->BA3_TIPOUS == "2"
		cSubTitulo := "*** P E S S O A    J U R I D I C A  ***   "
		
	ElseIf Empty(TRB->BA3_TIPOUS)
		cSubTitulo := "***    ***                     "
		
	EndIf
	
	cTipo := TRB->BA3_TIPOUS
	aSubTot := {}
	
	If li > 58
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		lTitulo := .T.
	EndIf
	
	@ li,000 PSAY cSubTitulo
	li +=2
	
	While TRB->(! Eof() .And. BA3_TIPOUS == cTipo)
		
		cProd := TRB->BA3_CODPLA
		lTitulo := .T.
		nExclusao := 0
		nInclusao := 0
		
		If li > 58
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			lTitulo := .T.
			
			@ li,000 PSAY cSubTitulo
			li+=2
			
		EndIf
		
		While TRB->(! Eof() .And. BA3_TIPOUS+TRB->BA3_CODPLA == cTipo+cProd)
			
			If lTitulo
				@ li,00 PSay objCENFUNLGP:verCamNPR( "BI3_NREDUZ", Padr( Posicione("BI3",1,xFilial("BI3")+mv_par01+TRB->BA3_CODPLA,"BI3_NREDUZ"), 20) )
				lTitulo := .F.
			EndIf
			
			nAuxQtdMes := QtdMes(mv_par04, StrZero(Month( TRB->DATBAS ),2)+"/"+StrZero(Year( TRB->DATBAS ),4))
			nCol := (nAuxQtdMes*20) + 1
			
			@ li,nCol 		PSay Str(TRB->TOTEXCL,10)
			@ li,nCol+10 	PSay Str(TRB->TOTINCL,10)
			
			nInclusao += TRB->TOTINCL
			nExclusao += TRB->TOTEXCL
			
			//incrementa sub-total
			nPos := Ascan(aSubTot, {|aVal| aVal[1] == TRB->DATBAS})
			
			If nPos == 0
				aAdd(aSubTot, { TRB->DATBAS, 0, 0})
				aSubTot[Len(aSubTot)][2] += TRB->TOTEXCL
				aSubTot[Len(aSubTot)][3] += TRB->TOTINCL
			Else
				aSubTot[nPos][2] += TRB->TOTEXCL
				aSubTot[nPos][3] += TRB->TOTINCL
			EndIf
			
			TRB->(DbSkip())
			
		EndDo
		
		nCol := ((nQtdMes+1)*20)+1
		@ li,nCol 		PSay Str(nExclusao,10)
		@ li,nCol+10 	PSay Str(nInclusao,10)
		@ li,nCol+22	PSay Str(nInclusao-nExclusao,10)
		
		li++
		
	EndDo
	
	@ li,00 PSay Repl("-",220)
	li++
	@ li,00 PSay " **SUB TOTAL**"
	
	nInclusao := nExclusao := 0
	cMesIni := mv_par04
	
	For nX := 1 TO nQtdMes
		
		If Val(Left(cMesIni,2)) + 1 > 12
			cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
			nMesIni := 1
		Else
			cAno    := StrZero(Val(Right(cMesIni,4)),4)
			nMesIni := Val(Left(cMesIni,2)) + 1
		EndIf
		
		cMesIni := StrZero(nMesIni,2)+cAno
		
		dDatBas := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
		
		nPos := ASCAN(aSubTot, {|aVal| aVal[1] == dDatBas-1})
		
		If nPos > 0
			
			nAuxQtdMes := QtdMes(mv_par04, StrZero(Month( aSubTot[nPos][1] ),2)+"/"+StrZero(Year( aSubTot[nPos][1] ),4))
			nCol := (nAuxQtdMes*20) + 1
			
			@ li,nCol 		PSay Str(aSubTot[nPos][2],10)
			@ li,nCol+10 	PSay Str(aSubTot[nPos][3],10)
			
			nExclusao += aSubTot[nPos][2]
			nInclusao += aSubTot[nPos][3]
			
			//incrementa array do Total Geral
			nPosTot := Ascan(aTotGer, {|aVal| aVal[1] == aSubTot[nPos][1]})
			
			If nPosTot == 0
				aAdd(aTotGer, { aSubTot[nPos][1], 0, 0})
				aTotGer[Len(aTotGer)][2] += aSubTot[nPos][2]
				aTotGer[Len(aTotGer)][3] += aSubTot[nPos][3]
			Else
				aTotGer[nPosTot][2] += aSubTot[nPos][2]
				aTotGer[nPosTot][3] += aSubTot[nPos][3]
			EndIf
			
		EndIf
		
	Next nX
	
	nCol := ((nQtdMes+1)*20)+1
	@ li,nCol 		PSay Str(nExclusao,10)
	@ li,nCol+10 	PSay Str(nInclusao,10)
	@ li,nCol+22	PSay Str(nInclusao-nExclusao,10)
	
	li++
	
	@ li,00 PSAY Repl("-",220)
	li += 2
	
EndDo

@ li,00 PSay " **TOTAL GERAL**"

nExclusao := nInclusao := 0
cMesIni   := mv_par04

For nX := 1 TO nQtdMes
	
	If Val(Left(cMesIni,2)) + 1 > 12
		cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
		nMesIni := 1
	Else
		cAno    := StrZero(Val(Right(cMesIni,4)),4)
		nMesIni := Val(Left(cMesIni,2)) + 1
	EndIf
	
	cMesIni := StrZero(nMesIni,2)+cAno
	
	dDatBas := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
	
	nPos := ASCAN(aTotGer, {|aVal| aVal[1] == dDatBas - 1})
	
	If nPos > 0
		
		nAuxQtdMes := QtdMes(mv_par04, StrZero(Month( aTotGer[nPos][1] ),2)+"/"+StrZero(Year( aTotGer[nPos][1] ),4))
		nCol := (nAuxQtdMes*20) + 1
		
		@ li,nCol 		PSay Str(aTotGer[nPos][2],10)
		@ li,nCol+10 	PSay Str(aTotGer[nPos][3],10)
		
		nExclusao += aTotGer[nPos][2]
		nInclusao += aTotGer[nPos][3]
		
	EndIf
	
Next nX

nCol := ((nQtdMes+1)*20)+1
@ li,nCol 	 	PSay Str(nExclusao,10)
@ li,nCol+10  	PSay Str(nInclusao,10)
@ li,nCol+22  	PSay Str(nInclusao-nExclusao,10)
li++

@ li,00 PSAY Repl("=",220)
li ++

If li != 80
	roda(cbcont,cbtxt,tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if( select( "TRB" ) > 0 )
	oTempTRB:delete()
endIf

dbSelectArea("BA1")
Set Device To Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR367AnoMes ºAutor ³Paulo Carbelossi  º Data ³ 07/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao Pergunte Mes/Ano Inicial e Final                  º±±
±±º          ³PLR367                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR367AnoMes(cMesAno)
Local lRet := .F.

If cMesAno == "99/9999"
	lRet := .T.
ElseIf cMesAno == Space(7)
	lRet := .T.	
ElseIf Subs(cMesAno, 3, 1) == "/" .And. Len(Trim(cMesAno)) == 7 .And. ;
		Val(Subs(cMesAno,1,2)) >= 01 .And. Val(Subs(cMesAno,1,2)) <= 12 .And. ;
		Val(Subs(cMesAno, 4)) <= 9999 .And. Len(Trim(Subs(cMesAno, 4))) == 4
	lRet := .T.
EndIf


Return(lret)
