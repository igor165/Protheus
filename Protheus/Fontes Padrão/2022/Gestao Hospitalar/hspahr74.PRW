#INCLUDE "HSPAHR74.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR74 บ Autor ณ GILSON DA SILVA    บ Data ณ  14/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA CANCELADA POR TRANSFERENCIA.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR74()

Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR74",.T.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 Else  
  HSPAHR74R3()  
 EndIf    
 
Return(Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ DANIEL PEIXOTO        ณ Data ณ 14/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz1, oTotaliz2
 Local aOrdem  := {}
 Local cTitulo := ""
 Local bFormula

// AADD(aOrdem ,"Filial Agend + Data Agenda" )

 cTitulo := HS_MontCabe(STR0011, MV_PAR03, MV_PAR04)  //"Agenda Cancelada por Transferencia"
 
 oReport := TReport():New("HSPAHR74",OemToAnsi(cTitulo),"HSPR74",{|oReport| R74IMP(oReport)},"Este relatorio tem por objetivo a impressao dos agendamentos cancelados por transferencia.")
 oReport:SetTotalText(STR0017) // texto impresso antes da somatoria de oTotaliz  //"Total Geral
 
 oReport:ParamReadOnly() //Desabilitando Botใo de parโmetros do Relat๓rio.
 
 oSection1 := TRSection():New(oReport,OemToAnsi("Profissional"),{"GMA","SRA"}, /*aOrdem*/)
 oCell := TRCell():New(oSection1,"GMA_CODCRM","GMA")
 oCell := TRCell():New(oSection1,"RA_NOME"   ,"SRA")  
 If MV_PAR07 == 2 //Salta Pagina
  oSection1:SetPageBreak(.T.)
 EndIf
 
 oSection2 := TRSection():New(oSection1,OemToAnsi("Data Cancel."),{"GMA"}, /*aOrdem*/)
 oCell := TRCell():New(oSection2,"GMA_DATCAN","GMA")
 
 oSection3 := TRSection():New(oSection2,OemToAnsi("Agendamentos"),{"GM8","GA7","GCM","GCS","GM7"}, /*aOrdem*/)
 oCell := TRCell():New(oSection3,"GMA_HORCAN","GMA","Hr Canc."   ,"@99:99",8 ) 
 oCell := TRCell():New(oSection3,"GA7_DESC"  ,"GA7",             ,        ,20)
 oCell := TRCell():New(oSection3,"GMA_NOMPAC","GMA",             ,        ,20)
 oCell := TRCell():New(oSection3,"GMA_TELPAC","GMA",             ,        ,15)
 oCell := TRCell():New(oSection3,"GMA_USUCAD","GMA","Agendado Por",       ,15)
 oCell := TRCell():New(oSection3,"GMA_DATAGE","GMA","Dt. Agdto"  ,        ,10)  
 oCell := TRCell():New(oSection3,"GMA_HORAGE","GMA","Hora"       ,"@99:99",5 )  
 oCell := TRCell():New(oSection3,"GCM_DESPLA","GCM",             ,        ,25)  
 oCell := TRCell():New(oSection3,"GCS_NOMLOC","GCS",             ,        ,25)  
 oCell := TRCell():New(oSection3,"GM8_DATAGE","GM8","Dt. Transf" ,        ,10)  
 oCell := TRCell():New(oSection3,"GM8_HORAGE","GM8","Hora"       ,"@99:99",5 )
 oCell := TRCell():New(oSection3,"GM7_ORICAN","GM7",             ,        ,10,, { || HS_RDescrB("GM7_ORICAN", QRYGMA->GM7_ORICAN) })
 oCell := TRCell():New(oSection3,"GM7_DESCAN","GM7",             ,        ,10,, { || QRYGMA->GM7_DESCAN})  
 
 oTotaliz2 := TRFunction():new(oSection3:Cell("GMA_HORCAN"),"","COUNT",,"Total de Agendamentos ==>",/*cPicture*/,/*uFormula*/,.T.)
 
 oTotaliz1 := TRFunction():new(oSection1:Cell("GMA_CODCRM"),"","COUNT",,STR0013,/*cPicture*/,/*uFormula*/,.F.)	  //"Total do Medico      ==>"

Return( oReport )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R74Imp   ณ Autor ณ DANIEL PEIXOTO        ณ Data ณ 14/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R74IMP(oReport)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณTransforma parametros Range em expressao SQL                            ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 MakeSqlExpr("HSPR74")

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery do relat๓rio da secao 1                                           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport:Section(1):BeginQuery()		

	BeginSql Alias "QRYGMA"
 	SELECT GMA.GMA_CODPLA, GMA.GMA_CODCRM, SRA.RA_NOME, GMA.GMA_NOMPAC, GCM.GCM_DESPLA, GMA.GMA_DATCAN,
         GMA.GMA_HORCAN, GMA.GMA_DATAGE, GMA.GMA_HORAGE, GA7.GA7_DESC, GCS.GCS_NOMLOC, GMA.GMA_TELPAC,
         GMA.GMA_USUCAD, GM8.GM8_HORAGE, GM8.GM8_DATAGE, GMA.GMA_CODCAN, GM7.GM7_ORICAN, GM7.GM7_DESCAN
  FROM %table:GMA% GMA
 				  JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GMA.GMA_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel%
       JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GMA.GMA_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%NotDel%
       JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GMA.GMA_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%
       JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GMA.GMA_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
       JOIN %table:GM7% GM7 ON GM7.GM7_CODCAN = GMA.GMA_CODCAN AND GM7.GM7_FILIAL = %xFilial:GM7% AND GM7.%NotDel%
       JOIN %table:GM8% GM8 ON GM8.GM8_FILAGE = GMA.GMA_FILAGE AND GM8.GM8_CODAGE = GMA.GMA_NOVAGE AND GM8.GM8_FILIAL = %xFilial:GM8% AND GM8.%NotDel%
  WHERE GMA.GMA_FILIAL = %xFilial:GMA% AND GMA.%NotDel%
        AND GMA.GMA_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GMA.GMA_DATCAN BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND GMA.GMA_CODCRM BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
  ORDER BY RA_NOME, GMA_DATCAN, GMA_HORCAN
 EndSql 	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMetodo EndQuery ( Classe TRSection )                                    ณ
	//ณ                                                                        ณ
	//ณPrepara o relat๓rio para executar o Embedded SQL.                       ณ
	//ณ                                                                        ณ
	//ณExpA1 : Array com os parametros do tipo Range                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport:Section(1):EndQuery(/*ExpA1*/)
	
	oReport:Section(1):Section(1):SetParentQuery()
	oReport:Section(1):Section(1):SetParentFilter({ |cParam| QRYGMA->GMA_CODCRM == cParam },{ || QRYGMA->GMA_CODCRM })
	
	oReport:Section(1):Section(1):Section(1):SetParentQuery()
	oReport:Section(1):Section(1):Section(1):SetParentFilter({ |cParam| QRYGMA->GMA_CODCRM + DTOS(QRYGMA->GMA_DATCAN) == cParam },{ || QRYGMA->GMA_CODCRM + DTOS(QRYGMA->GMA_DATCAN) })
 
 oReport:Section(1):Print() // processa as informacoes da tabela principal

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR74 บ Autor ณ GILSON DA SILVA    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA CANCELADA POR TRANSFERENCIA.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracoesณ 11/07/06 - Patricia Queiroz                                บฑฑ
ฑฑบ          ณ - Inclusao de uma linha pontilhada apos a impressao de     บฑฑ
ฑฑบ          ณ   cada horario.                                            บฑฑ
ฑฑบ          ณ - Inclusao do codigo do medico.                            บฑฑ
ฑฑบ          ณ - Utilizacao da funcao HS_MontCabe para montar o cabecalho บฑฑ
ฑฑบ          ณ de acordo com os parametros informados pelo usuario.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR74R3()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Locais                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3 := ""
Local Titulo := STR0003 //"Agenda Cancelada por Transferida."
Local Cabec1 := ""
Local Cabec2 := ""
Local aOrd   := {}
Local aArea  := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Privadas                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "G"
Private nomeprog    := "HSPAHR74"
Private nTipo       := 15
Private aReturn     := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private m_pag       := 01
Private wnrel       := "HSPAHR74"
Private cString     := ""
Private aRegistros  := {}
Private nLin        := 80

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PARAMETROS                                                         ณ
//ณ MV_PAR01	Da Filial                                              ณ
//ณ MV_PAR02	Ate a Filial                                           ณ
//ณ MV_PAR03	Da Data Transferencia                                  ณ
//ณ MV_PAR04	Ate a Data Transferencia                               ณ
//ณ MV_PAR05	Do Profissional                                        ณ
//ณ MV_PAR06	Ate o Profissional                                     ณ
//ณ MV_PAR07	Salta pg P/Medico   "Sim" ou "Nao"                     ณ
//| MV_PAR08    Impressora ?                                           |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPerg := "HSPR74"
If FunName() <> "HSPAHM29"
	Pergunte(cPerg,.T.)
Else
	mv_par01 := "01"
	mv_par02 := "01"
	mv_Par03 := M->GM8_DATAGE
	mv_Par04 := M->GM8_DATAGE
	mv_Par05 := M->GM8_CODCRM
	mv_Par06 := M->GM8_CODCRM
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)

RestArea(aArea)
Return

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

Static Function RunReport(Cabec1,Cabec2,Titulo)
Local cFilAge_De  := mv_par01
Local cFilAge_Ate := mv_par02
Local dDatCan_De  := mv_par03
Local dDatCan_Ate := mv_par04
Local cCodCRM_De  := mv_par05
Local cCodCRM_Ate := mv_par06
Local nSaltPag    := mv_par07

Local cGMA_DATCAN := ""            

Local cGMA_CODCRM := ""
Local nInt        := 0
Local nTotGer     := 0
Local nTotal      := 0
Local nTotMed     := 0
Local cMotCan     := ""
Local cRespCan    := ""
Local cSQL        := "" 
Local lImpDat     := .F. //variavel responsavel pela impressao da data apos a quebra 

Titulo := HS_MontCabe(STR0011, dDatCan_De, dDatCan_Ate)  //"Agenda Cancelada por Transferencia"

cSQL := "SELECT GMA.GMA_CODPLA, GMA.GMA_CODCRM, SRA.RA_NOME, GMA.GMA_NOMPAC, GCM.GCM_DESPLA, "
cSQL +=        "GMA.GMA_DATCAN, GMA.GMA_HORCAN, GMA.GMA_DATAGE, GMA.GMA_HORAGE, "
cSQL +=        "GA7.GA7_DESC, GCS.GCS_NOMLOC, GMA.GMA_TELPAC, GMA.GMA_USUCAD, "
cSQL +=        "GM8.GM8_HORAGE, GM8.GM8_DATAGE, GMA.GMA_CODCAN"

cSQL += "FROM " + RetSQLName("GMA") + " GMA "
cSQL += "JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cSQL +=                                   "AND SRA.RA_CODIGO  = GMA.GMA_CODCRM "
cSQL += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cSQL +=                                    "AND GCM.GCM_CODPLA = GMA.GMA_CODPLA "
cSQL += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
cSQL +=                                    "AND GA7.GA7_CODPRO = GMA.GMA_CODPRO "
cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "    
cSQL +=                                    "AND GCS.GCS_CODLOC = GMA.GMA_CODLOC "
cSQL += "JOIN " + RetSQLName("GM8") + " GM8 ON GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
cSQL +=                                    "AND GM8.GM8_FILAGE = GMA.GMA_FILAGE AND GM8.GM8_CODAGE = GMA.GMA_NOVAGE "

cSQL += "WHERE GMA.GMA_FILIAL = '" + xFilial("GMA") + "' AND GMA.D_E_L_E_T_ <> '*' "
cSQL += " AND GMA.GMA_FILAGE BETWEEN '" + cFilAge_De + "' AND '" + cFilAge_Ate + "' "
cSQL += " AND GMA.GMA_DATCAN BETWEEN '" + DTOS(dDatCan_De) + "' AND '" + DTOS(dDatCan_Ate) + "' "
cSQL += " AND GMA.GMA_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' "

cSQL += "ORDER BY SRA.RA_NOME, GMA.GMA_DATCAN, GMA.GMA_HORCAN"

cSQL :=  ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()
If EOF()
	HS_MsgInf(STR0017, STR0018, STR0003) //"Nenhum agendamento cancelado foi encontrado para a selecao efetuada!" //"Aten็ใo"
EndIf

SetRegua(RecCount()+RecCount())
While !EOF()
	
	DBSelectArea("GM7")
	DBSetOrder(1)
	If DbSeek(xFilial("GM7") +  QRY->GMA_CODCAN)
		cMotCan  := GM7->GM7_DESCAN
		cRespCan := HS_RDescrB("GM7_ORICAN", GM7->GM7_ORICAN) + " / "
	Else
		cMotCan  := ""
		cRespCan := ""
	EndIf
	
	aAdd(aRegistros, {QRY->GMA_CODPLA,;
	QRY->GMA_CODCRM,;
	QRY->RA_NOME,;
	QRY->GMA_NOMPAC,;
	QRY->GCM_DESPLA,;
	DTOC(STOD(QRY->GMA_DATCAN)),;
	QRY->GMA_HORCAN,;
	DTOC(STOD(QRY->GMA_DATAGE)),;
	QRY->GMA_HORAGE,;
	SUBSTR(QRY->GA7_DESC,1,30),;
	QRY->GCS_NOMLOC,;
	cMotCan,;//Motivo Cancelamento
	cRespCan,;
	QRY->GMA_TELPAC,;
	QRY->GMA_USUCAD,;//Origem do Cancelamento.
	QRY->GM8_HORAGE,;
	STOD(QRY->GM8_DATAGE) })
	
	DbSelectArea("QRY")
	DbSkip()
	IncRegua()
EndDo

If Len(aRegistros) <> 0
	For nInt := 1 to Len(aRegistros) 
	   lImpDat := .F.
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica o cancelamento pelo usuario...                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAbortPrint
			@nLin,000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		EndIf
		
		Cabec1 := STR0008 + AllTrim(aRegistros[nInt,2]) + "-" + aRegistros[nInt,3] + Space(05) + STR0009  + HS_IniPadr("GBJ", 1, aRegistros[nInt,2], "GBJ_TEL",, .F.) //"Medico: "###"Telefone: "
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[nInt,6])
			lImpDat := .T.
		EndIf
		
		If cGMA_CODCRM <> aRegistros[nInt,2] .And. !Empty(cGMA_CODCRM) //Quebra Por Medico
			nLin ++
			@nLin,009 PSAY STR0013+transform(nToTal, "@E 999,999")//###"Total : "
			nLin := nLin + 2
			@nLin,000 PSAY STR0012+transform(nToTMed, "@E 999,999")//###"Total do Medico : "
			nTotMed := 0
			nTotal  := 0
			If nSaltPag == 2
				ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[nInt,6])
				ImpData(aRegistros[nInt,6])
				lImpDat := .F.
			Else
				nLin := nLin+3
				@nLin, 000 PSAY  STR0008 + AllTrim(aRegistros[nInt,2]) + "-" + aRegistros[nInt,3] + Space(05) + STR0009  + HS_IniPadr("GBJ", 1, aRegistros[nInt,2], "GBJ_TEL",, .F.)   //"Medico: "###"Telefone: "
				nLin := nLin+2
			EndIf
			cGMA_CODCRM := aRegistros[nInt,2]
			cGMA_DATCAN := aRegistros[nInt,6]
		EndIf
		
		If cGMA_DATCAN <> aRegistros[nInt,6] .And. !Empty(cGMA_DATCAN)//Quebra por Data de Cancelamento
			nLin ++
			@nLin,009 PSAY STR0013+transform(nToTal, "@E 999,999")//###"Total : "
			nLin := nLin + 2
			ImpData(aRegistros[nInt,6])
			lImpDat := .F.
			nTotal := 0
			cGMA_DATCAN := aRegistros[nInt,6]
		EndIf
		
		If lImpDat
          ImpData(aRegistros[nInt,6])
		EndIf
		
		cGMA_CODCRM := aRegistros[nInt,2]
		cGMA_DATCAN := aRegistros[nInt,6]
		
		@nLin,000 PSAY aRegistros[nInt,7] //Horario do cancelamento
		@nLin,007 PSAY aRegistros[nInt,10]//Descricao do procedimento
		@nLin,039 PSAY aRegistros[nInt,4] //Nome do Paciente
		@nLin,085 PSAY aRegistros[nInt,14] //Telefone do Paciente
		@nLin,099 PSAY aRegistros[nInt,15] //Nome do Paciente
		@nLin,115 PSAY aRegistros[nInt,8] //Data do Agendamento
		@nLin,128 PSAY aRegistros[nInt,9] //Hora do agendamento
		
		nLin++
		
		@nLin,010 PSAY aRegistros[nInt,5]//Descricao do Plano
		@nLin,065 PSAY aRegistros[nInt,11]//Unidade organizacional
		@nLin,115 PSAY DTOC(aRegistros[nInt,17])// Data Agenda Transferida
		@nLin,128 PSAY aRegistros[nInt,16]  // Hora Agenda Transferida
		nLin++
		
		@nLin,010 PSAY aRegistros[nInt,13] + aRegistros[nInt,12] //Responsavel / Motivo do Cancelamento
		nLin++
		@nLin,000 PSAY  Repl("-",132)
		nLin := nLin + 1
		nTotal++
		nTotGer++
		nTotMed++
	Next
	
	If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[Len(aRegistros),6])
	EndIf
	
	nLin := nLin + 2
	@nLin,010 PSAY STR0013 + transform(nToTal, "@E 999,999")//###"Total : "
	nLin := nLin + 2
	@nLin,000 PSAY STR0012 + transform(nToTMed, "@E 999,999")//###"Total do Medico : "
	nLin := nLin + 2
	@nLin,004 PSAY STR0016 + transform(nToTGer, "@E 999,999")//###"Total Geral : "
	nTotMed := 0
	nTotal := 0
	nTotGEr := 0
	
EndIf

DbSelectArea("QRY")
DbCloseArea()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

DBSelectArea("GMA")
DbClearFilter()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณIMPCABEC  บ Autor ณ Gilson da Silva    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime o Cabecalho do relatorio.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ImpCabec(Cabec1,Cabec2,Titulo,cDataCan)

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 08

/*                              1         2         3         4         5         6         7         8         9        10        11        12        13
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
"Hora   Procedimento                    Nome                                        TELEFONE        AGENDADO POR    DATA AGDTO   HORA"
*/

@nLin,000 PSAY  STR0006 //"Hora   Procedimento                    Nome                                        Telefone        Agendado Por    Data Agdto   Hora"
nLIn ++
@nLin,000 PSAY  STR0014  //"          Plano                                                  Setor                                             Data Transf. Hora"
nLIn ++
@nLin,000 PSAY  STR0015  //"          Responsavel / Motivo"
nLin ++
@nLin,000 PSAY  Repl("-",132)
nLin ++
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณIMPDATA   บ Autor ณ Gilson da Silva    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime a Data e o Dia da semana da transferencia.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpData(cDataCan)

nLin ++
@nLin,000 PSAY  STR0010    //"Data: "
@nLin,006 PSAY cDataCAn + " - " + HS_SEMANA(DOW(CTOD(cDataCan)))
nLin := nLin + 2

Return 