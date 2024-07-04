#INCLUDE "PLSR181.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR181   ºAutor  ³  TOTVS             º Data ³  22/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Emite uma carta de glosa para comunicado as RDAs            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSR181() 

Local oReport
Local cPerg   := "PLR181"

Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog() //Tela com botão de parametros
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ReportDef º                            º Data ³  22/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport
Local oSection1,oSection2
Local oCell
Local oTotaliz

oReport := TReport():New("PLSR181",STR0001,"PLR181", {|oReport| R181IMP(oReport)},STR0002) //"Relatório de Glosas"###"Este programa ira emitir uma carta de comunicados de glosas aos RDAs"
oReport:SetLandscape() // Imprimir relatório em formato paisagem
oReport:SetPageFooter( 10  , {||oReport:printText(mv_par09)})	// Imprime mensagem Rodapé

oSection1 := TRSection():New(oReport,STR0003, {"BD6"},{OemToAnsi(STR0004),OemToAnsi(STR0005)}) //"Prestadores"###"Data/Nome"###"Nome/Data"
oSection1:SetHeaderBreak(.T.)	//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetPageBreak(.T.)		//Indica quebra de pagina no final da secao
oSection1:SetHeaderPage(.T.)	//Indica que cabecalho da secao sera impresso no topo da pagina
oSection1:SetHeaderSection(.F.) //Indica se cabecalho da secao sera impresso (padrao)

oCell := TRCell():New(oSection1,"BD7_CODRDA","TrbR161")//"Codigo RDA"
oCell := TRCell():New(oSection1,"BD7_NOMRDA","TrbR161","",,30)//"Nome RDA"
oCell := TRCell():New(oSection1,"_cMsg3",,"",,130,,{||_cMsg3:=AllTrim(mv_par06)+" "+cValToChar(mv_par07)})//"Msg1 e Msg2"
oCell := TRCell():New(oSection1,"_Emiss",,STR0006,,30,,{||_Emiss:=(STR0006+" "+DtoC(dDataBase))}) //"Emissão"
oCell := TRCell():New(oSection1,"cMesAno",,STR0007,,40,,{||cMesAno:=TrbR161->(STR0007+" "+BD7_MESPAG+" "+BD7_ANOPAG)}) //"Mes/Ano de Pgto"

oSection2 := TRSection():New(oSection1,STR0008,{"TrbR161"}) //"Procedimentos Glosados"
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.)  

oCell := TRCell():New(oSection2,"BD7_NOMUSR","TrbR161",,,40) //"Usuario""
oCell := TRCell():New(oSection2,"BD7_DATPRO","TrbR161") //"Data Proced."
oCell := TRCell():New(oSection2,"cCodUnm","TrbR161",STR0009,,,,{||cCodUnm:=ValidUnm(TrbR161->BD7_CODUNM,TrbR161->BD7_CODTPA,TrbR161->BD6_CODOPE)}) //"Und"
oCell := TRCell():New(oSection2,"BD6_QTDPRO","TrbR161") //"Qtd Realizad"
oCell := TRCell():New(oSection2,"BD7_CODPRO","TrbR161") //"Cod. Proc."
oCell := TRCell():New(oSection2,"BD6_DESPRO","TrbR161",,,30)//"Desc. Proc.
oCell := TRCell():New(oSection2,STR0010,"",STR0011,,50,,{||POSICIONE("BDX",1,xFilial("BDX") + TrbR161->BD6_CODOPE + TrbR161->BD6_CODLDP + TrbR161->BD6_CODPEG + TrbR161->BD6_NUMERO + TrbR161->BD6_ORIMOV + TrbR161->BD6_CODPAD + TrbR161->BD7_CODPRO + TrbR161->BD6_SEQUEN,"BDX_DESGLO")}) //"Motivo"###"Motivo de Glosa"
oCell := TRCell():New(oSection2,"BD7_VLRGLO","TrbR161")//"Vlr. Glosas"
oCell := TRCell():New(oSection2,"BD7_VLRPAG","TrbR161")//"Vlr. Pagto"
oCell := TRCell():New(oSection2,"nValTot","TrbR161",STR0012,"@E 999,999,999.99",10,,{|| nValTot := TrbR161->BD7_VALORI }) //"Vlr Apr."

oTotaliz := TRFunction():new(oSection2:Cell("BD7_VLRGLO"),,"SUM",,STR0013,"@E 999,999,999.99") //"Total Glosa"
oTotaliz := TRFunction():new(oSection2:Cell("BD7_VLRPAG"),,"SUM",,STR0014,"@E 999,999,999.99") //"Total Vlr Pag"
oTotaliz := TRFunction():new(oSection2:Cell("nValTot"),,"SUM",,STR0015,"@E 999,999,999.99")  //"Total Vlr Apr"

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R181IMP   ºAutor  ³  TOTVS             º Data ³  22/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relatório de Glosas R4                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R181IMP(oReport)  

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cGuiGlo 	:= "% ( BD7_VLRGLO >= 0) %"
Local cOrder	:= "% ( ORDER BY BD6_CODRDA, BD7_NOMUSR, BD7_DATPRO ) %"

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

If mv_par08 == 1 
   cGuiglo:= "% ( BD7_VLRGLO > 0) %"        // Somente as guias glosadas
EndIf

If oSection1:GetOrder() == 1
	cOrder:= "% BD6_CODRDA, BD7_DATPRO, BD7_NOMUSR %"
Else 
	cOrder:= "% BD6_CODRDA, BD7_NOMUSR, BD7_DATPRO %"
EndIf

oSection1:BeginQuery()
BeginSql alias "TrbR161"
 SELECT BD6_CODRDA, BD6_DESPRO, BD6_VALORI, BD7_NOMRDA, BD7_VALORI, BD7_VLRGLO, BD7_VLRPAG, BD7_PERCEN, BD7_CODPRO, BD7_DATPRO, BD7_NOMUSR, BD7_CODRDA, BD7_MESPAG, BD7_ANOPAG, BD7_CODTPA, BD7_CODUNM, BD6_QTDPRO,BD6_CODOPE, BD6_CODLDP, 
 BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV , BD6_CODPAD, BD6_SEQUEN
 FROM %table:BD7% BD7 
 JOIN %table:BD6% BD6 ON BD6.BD6_CODOPE = BD7.BD7_CODOPE
 					 AND BD6.BD6_CODLDP = BD7.BD7_CODLDP
 					 AND BD6.BD6_CODPEG = BD7.BD7_CODPEG
                     AND BD6.BD6_NUMERO = BD7.BD7_NUMERO
                     AND BD6.BD6_ORIMOV = BD7.BD7_ORIMOV
                     AND BD6.BD6_CODPAD = BD7.BD7_CODPAD
                     AND BD6.BD6_CODPRO = BD7.BD7_CODPRO
                     AND BD6.BD6_SEQUEN = BD7.BD7_SEQUEN AND BD6.BD6_FILIAL = %xFilial:BD6% AND BD6.%NotDel%
 JOIN %table:BAU% BAU ON BAU.BAU_CODIGO = BD7.BD7_CODRDA AND BAU.BAU_FILIAL = %xFilial:BAU% AND BAU.%NotDel%
 WHERE BD7.BD7_FILIAL = %xFilial:BD7% AND BD7.%NotDel%  
   AND (BD7_CODOPE = %Exp:mv_par01%)
   AND (BD7_ANOPAG = %Exp:mv_par04%)
   AND (BD7_MESPAG = %Exp:mv_par05%)
   AND ( BD7_SITUAC = '1' ) // Situação Ativa
   AND ( BD7_FASE = '4' )   // Fase Faturada
   AND (BD7_CODOPE||BD7_CODLDP||BD7_CODPEG||BD7_NUMERO IN (SELECT BDX_CODOPE||BDX_CODLDP||BDX_CODPEG||BDX_NUMERO FROM %table:BDX% BDX WHERE BDX.%NotDel%))
   AND (BAU.%NotDel%)
   AND (BAU.BAU_CODIGO >= %Exp:mv_par02% AND BAU.BAU_CODIGO <= %Exp:mv_par03% )
   AND %Exp:cGuiGlo%  		// Somente as guias glosadas
   ORDER BY %Exp:cOrder%
EndSql

oSection1:EndQuery()

oSection2:SetParentQuery()
oSection2:SetParentFilter({|G|("TrbR161")->BD6_CODRDA == G }, {||("TrbR161")->BD6_CODRDA}) 

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(TrbR161->(LastRec()))

	 
Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ VALIDUNM   ³ Autor ³                   ³ Data ³ 22/05/09   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Unidade de medida na tabela BWT                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function VALIDUNM (cCodUnm,cCodTpa, cCodOpe)    

Local cRet 

If Empty(cCodTpa)							//BD7->BD7_CODTPA
	    cRet := cCodUnm 					//BD7_CODUNM
		ElseIf !Empty(cCodUnm)
 			BWT->(dbsetorder(1))
			If BWT->(dbseek(xFilial("BWT")+cCodOpe+cCodTpa)) .and. !Empty(BWT->BWT_CODEDI)
				cRet :=BWT->BWT_CODEDI
			Else
				cRet := cCodUnm				//Unidade
			EndIf
		EndIf													
Return (cRet)