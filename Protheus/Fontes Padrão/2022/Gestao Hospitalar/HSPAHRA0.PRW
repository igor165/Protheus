#INCLUDE "HSPAHRA0.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
                                   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRA0 บ Autor ณ DANIEL PEIXOTO     บ Data ณ  18/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA AMBULATORIAL                           บฑฑ
ฑฑบ          ณ ESTATISTICA DAS MARCACOES NO PERIODO                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRA0()

Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	If FunName() <> "HSPAHM29"
  	Pergunte("HSPRA0",.F.)
  Else
   MV_PAR01 := "01" 
   MV_PAR02 := "01" 
   MV_PAR03 := M->GM8_DATAGE
   MV_PAR04 := M->GM8_DATAGE
   MV_PAR05 := 1
  EndIf                                                
  oReport := ReportDef() 
  oReport:PrintDialog()  
 Else  
  HSPAHRA0R3()  
 EndIf    
 
Return(Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ DANIEL PEIXOTO        ณ Data ณ 14/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()

 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz1, oTotaliz2
 Local aOrdem  := {}
 Local cTitulo := ""
 Local bFormula

 cTitulo := HS_MontCabe(STR0008, MV_PAR03, MV_PAR04)  //"Marca็ใo no Perํodo" 
 
 oReport := TReport():New("HSPAHRA0", OemToAnsi(cTitulo), "HSPRA0", {|oReport| RA0IMP(oReport)}, "Este relatorio tem por objetivo a impressao da estatistica das marca็๕es ambulatoriais.")
 oReport:SetTotalText("Total Geral de Marca็๕es... ") // texto impresso antes da somatoria de oTotaliz
 
 oSection1 := TRSection():New(oReport, OemToAnsi("Usuario"), {"GM8"}, /*aOrdem*/)
 oCell := TRCell():New(oSection1, "GM8_CODUSU", "GM8", "Usuแrio")                           
 oCell := TRCell():New(oSection1, "TOTUSU", "   ", "Qtde"    , "@E 999,999", 7,, { || QRYGM8->TOTUSU })
 oCell := TRCell():New(oSection1, "PERUSU", "   ", "Perc.(%)", "@E 999.999", 7,, { || (QRYGM8->TOTUSU / nTotGer) * 100 })
 
 oTotaliz1 := TRFunction():new(oSection1:Cell("TOTUSU"), "TOTUSU", "SUM"    ,,"Total de Marcacoes    ==>",/*cPicture*/,/*uFormula*/, .F.)	

Return(oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณ RA0Imp   ณ Autor ณ DANIEL PEIXOTO        ณ Data ณ 18/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RA0IMP(oReport)

Local cOrder  := "%%"
Local cCond   := "%%"
Local cCodUsu := ""

Private nTotGer := 0

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณTransforma parametros Range em expressao SQL                            ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 MakeSqlExpr("HSPRA0")

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery do relat๓rio da secao 1                                           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport:Section(1):BeginQuery()		
 If MV_PAR05 == 1 
   cOrder := "%GM8_FILAGE, GM8_CODUSU%" 
 Else
   cOrder := "%GM8_FILAGE, TOTUSU DESC%" 
 EndIf 
 
 cCond := "%GM8_STATUS IN ('1','3','4','5','6')%"
 
	BeginSql Alias "QRYGM8"
 	SELECT COUNT(*) AS TOTGER
  FROM %table:GM8% GM8
  WHERE GM8_FILIAL = %xFilial:GM8% AND GM8.%NotDel%
        AND GM8_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GM8_DATCAD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND %Exp:cCond%
 EndSql 	
	
 oReport:Section(1):EndQuery(/*ExpA1*/)
 nTotGer := QRYGM8->TOTGER
 DbCloseArea()
	
	BeginSql Alias "QRYGM8"
 	SELECT GM8.GM8_FILAGE, GM8.GM8_CODUSU, COUNT(*) AS TOTUSU
  FROM %table:GM8% GM8
  WHERE GM8_FILIAL = %xFilial:GM8% AND GM8.%NotDel%
        AND GM8_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GM8_DATCAD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND %Exp:cCond%
  GROUP BY GM8_FILAGE, GM8_CODUSU 
  ORDER BY %Exp:cOrder%
 EndSql 	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMetodo EndQuery ( Classe TRSection )                                    ณ
	//ณ                                                                        ณ
	//ณPrepara o relat๓rio para executar o Embedded SQL.                       ณ
	//ณ                                                                        ณ
	//ณExpA1 : Array com os parametros do tipo Range                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport:Section(1):EndQuery(/*ExpA1*/)

	oReport:Section(1):SetParentQuery()
	
 oReport:SetMeter(RecCount())
 DbSelectArea("QRYGM8")
 oReport:Section(1):Init(.T.)

 Do While !QRYGM8->(Eof())
 	If oReport:Cancel()
	 	Exit
	 EndIf

	 If cCodUsu <> QRYGM8->GM8_CODUSU
   oReport:Section(1):PrintLine()			
   cCodUsu := QRYGM8->GM8_CODUSU
	 EndIf
	 
  oReport:IncMeter()
  QRYGM8->(dbskip())
 Enddo

oReport:Section(1):Finish()
 

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRA0 บ Autor ณ GILSON DA SILVA    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA AMBULATORIAL                           บฑฑ
ฑฑบ          ณ ESTATISTICA DAS MARCACOES NO PERIODO                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRA0R3()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
 Local cDesc2 := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
 Local cDesc3 := ""
 Local Titulo := STR0003 //"Estatํstica das Marca็๕es no Perํodo"
 Local Cabec1 := ""
 Local Cabec2 := STR0006 //"Usuแrio                                                  Qtde.                %"
 Local aOrd   := {}
 Local aArea  := GetArea()

 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private tamanho     := "P"
 Private nomeprog    := "HSPAHRA0"
 Private nTipo       := 15
 Private aReturn     := {STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administra็ใo"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private m_pag       := 01
 Private wnrel       := "HSPAHRA0"
 Private cString     := ""
 Private aRegistros  := {}
 Private nLin        := 80
 Private aVetor      := {}
 Private cCodImp     := ""
 Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Da Filial                                                 ณ
 //ณ MV_PAR02	Ate a Filial                                              ณ
 //ณ MV_PAR03 Data Inicial das Marcacoes                                ณ
 //ณ MV_PAR04	Data Final das Marcacoes                                  ณ
 //ณ MV_PAR05	Ordem de Impressao  1=Nome    2= Quantidade Decrescente   ณ
 //| MV_PAR06 Grafico ?                                                 |
 //| MV_PAR07 Impressora ?                                              |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPRA0"    
 
 If FunName() <> "HSPAHM29"
  Pergunte(cPerg, .T.)
 Else
  MV_PAR01 := "01" 
  MV_PAR02 := "01" 
  MV_PAR03 := M->GM8_DATAGE
  MV_PAR04 := M->GM8_DATAGE
  MV_PAR05 := 1
 EndIf                                                
                                                                                                  
 nMaxLin := HS_MaxLin(cCodImp)
 nLin    := nMaxLin * 2

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                        
 //ณ Monta a interface padrao com o usuario...                           ณ                        
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)
 If nLastKey == 27
  Return
 EndIf
 SetDefault(aReturn, cString)
 If nLastKey == 27
  Return
 EndIf
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo)}, Titulo)
 
 RestArea(aArea)
 
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Gilson da Silva    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo)

 Local nInt    := 0
 Local nTotal  := 0
 Local nCtaFor := 0
 Local cSQL    := ""
 
 cSQL := "SELECT GM8.GM8_FILAGE, GM8.GM8_CODUSU, COUNT(*) AS TOTUSU "
 cSQL += "FROM " + RetSQLName("GM8") + " GM8 "                                   
 cSQL += "WHERE GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
 cSQL += "AND GM8.GM8_FILAGE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cSQL += "AND GM8.GM8_DATCAD BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 cSQL += "AND GM8.GM8_STATUS IN ('1', '3', '4', '5', '6') "
 cSQL += "GROUP BY GM8.GM8_FILAGE, GM8.GM8_CODUSU "

 If MV_PAR05 == 1
  cSQL += "ORDER BY GM8.GM8_FILAGE, GM8.GM8_CODUSU"
 Else
  cSQL += "ORDER BY GM8.GM8_FILAGE, TOTUSU DESC"
 EndIf 
                         
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If EOF()
  HS_MsgInf(STR0012, STR0013, STR0014) //"Nenhum agendamento foi encontrado para a sele็ใo efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
 EndIf

 Titulo := STR0008 //"Marca็ใo no Perํodo"
 Cabec1 := STR0011 + Dtoc(MV_PAR03) + STR0009 + Dtoc(MV_PAR04) // "Perํodo de  " ###"  a  "
 
 SetRegua(1000)

 While !EOF()                                                                                
  aAdd(aRegistros, {QRY->GM8_FILAGE, QRY->GM8_CODUSU, QRY->TOTUSU})
  nTotal += QRY->TOTUSU
  DbSkip()
  IncRegua()    
 EndDo 

 If Len(aRegistros) <> 0
  
  If MV_PAR06 == 2 /* se visualiza grafico carteziano...*/
   For nCtaFor := 1 To Len(aRegistros) /* prepara um vetor contendo o percentual eixo y e usuarios + total de agendamento */
    aAdd(aVetor, {(Val(Str(((aRegistros[nCtaFor, 3] / nTotal) * 100), 6, 2))), AllTrim(SubStr(aRegistros[nCtaFor, 2], 1, 13)) + " " + AllTrim(Str(((aRegistros[nCtaFor, 3] / nTotal) * 100), 6, 2)) + "%"})
   Next   
   /* cria o objeto para contrucao do grafico */
   oGraf := hsGRAF():NEW("AGENDA AMBULATORIAL", "MARCACAO NO PERIODO " + DtoC(MV_PAR03) +" a " + DtoC(MV_PAR04) + "    totalizando " + Str(nTotal, 5, 0) + " marcacoes", "Percentual % dos usuarios", "", "USUARIOS ", "", aVetor, 1, 1, 0, 0, 2, 20, 6, 6, 25, 20)
  EndIf
  
  For nInt := 1 To Len(aRegistros)
   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   If lAbortPrint
    @nLin, 000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
    Exit
   EndIf     
          
  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ Impressao do cabecalho do relatorio. . .                            ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
    Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
  	 nLin := 09   
   EndIf    
  
   @nLin, 000 PSAY aRegistros[nInt, 2] //Nome do Usuario  
   @nLin, 055 PSAY Transform(aRegistros[nInt, 3], "@E 999,999")
   @nLin, 074 PSAY Transform((aRegistros[nInt, 3] / nTotal) * 100, "@E 999.99")  //Percentual do Usuario.
   nLin++
  Next 
  
	 nLin++
  @nLin, 047 PSAY STR0010 + Transform(nToTal, "@E 999,999")//"Total : "
 EndIf
 
 SET DEVICE TO SCREEN
 DbCloseArea()

 If aReturn[5] == 1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf

 MS_FLUSH()
 
 DBSelectArea("GM8")
 DbClearFilter()
Return()