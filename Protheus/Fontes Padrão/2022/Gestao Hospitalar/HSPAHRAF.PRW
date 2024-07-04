#INCLUDE "HSPAHRAF.ch"
#include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRAF  บ Autor ณ ANTONIO CARLOS     บ Data ณ  20/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA RESERVA CIRURGICA CANCELADA                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRAF()

Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRAF",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHRAFR3()  
 EndIF    
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 20/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4, oSection5
 Local oCell

 oReport := TReport():New("HSPAHRAF",HS_MontCabe(STR0003, MV_PAR03, MV_PAR04),"HSPRAF",{|oReport| RAFIMP(oReport)}, STR0001 + STR0002 + STR0003)

 oSection1 := TRSection():New(oReport,STR0010,{"GML","SRA","GBJ"})
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oCell := TRCell():New(oSection1,"GML_CODCRM","GML",STR0010)                                               // 01-Medico
 oCell := TRCell():New(oSection1,"RA_NOME","SRA"," ",,25)                                                  // 02-Descricao do Medico 
 oCell := TRCell():New(oSection1,"GBJ_TEL","GBJ",STR0011)                                                  // 03-Telefone do Medico 

 oSection2 := TRSection():New(oSection1,STR0035,{"GML"}) //"Data"
 oSection2:SetTotalInLine(.F.)
 oCell := TRCell():New(oSection2,"GML_DATCAN","GML",STR0035)                                               // 04-Data //"Data"
 oCell := TRCell():New(oSection2,"cDatCan","GML","",,20,,{|| "- " + HS_SEMANA(DOW(GML_DatCan))})           // 05-Data Por Extenso
                                                                                                               
 oSection3 := TRSection():New(oSection2,STR0036,{"GML","GA7"}) //"Hora"
 oSection3:SetHeaderPage(.T.)
 oSection3:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection3,"GML_HORCAN","GML",STR0036)                                               // 06-Hora //"Hora"
 oCell := TRCell():New(oSection3,"GA7_DESC"  ,"GA7",STR0037)                                               // 07-Procedimento  //"Procedimento"
 oCell := TRCell():New(oSection3,"GML_NOMPAC","GML",STR0038,,35)                                           // 08-Paciente  //"Nome"
 oCell := TRCell():New(oSection3,"GML_TELPAC","GML",STR0011)                                               // 09-Telefone 
 oCell := TRCell():New(oSection3,"GML_USUCAN","GML",STR0039)                                               // 10-Cancelado Por //"Cancelado Por"
 oCell := TRCell():New(oSection3,"GML_DATAGE","GML",STR0040)                                               // 11-Data Agendado  //"Data Agdto"
 oCell := TRCell():New(oSection3,"GML_HORAGE","GML",STR0036)                                               // 12-Hora Agendado //"Hora"

	DEFINE FUNCTION FROM oSection3:Cell("GML_HORCAN") OF oSection1 FUNCTION COUNT TITLE STR0013+" =>"         // Totaliza por Medico 
	DEFINE FUNCTION FROM oSection3:Cell("GML_HORCAN") OF oSection2 FUNCTION COUNT TITLE STR0041               // Totaliza por Data //"Total Por Data =>"
                                                                                                                   
 oSection4 := TRSection():New(oSection3,OemToAnsi(STR0042),{"GCM","GCS"})                                  //"Plano" //"Plano"
 oSection4:SetHeaderPage(.T.)
 oSection4:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection4,"GCM_DESPLA","GML",STR0042)                                               // 13-Plano  //"Plano"
 oCell := TRCell():New(oSection4,"GCS_NOMLOC","GCS",STR0043)                                               // 14-Setor  //"Setor"

 oSection5 := TRSection():New(oSection4,OemToAnsi(STR0044),{"GM7"}) //"Responsavel/Motivo"
 oSection5:SetHeaderPage(.T.)
 oSection5:SetHeaderBreak(.F.)                                                                                
 
 oCell := TRCell():New(oSection5,"GM7_ORICAN","GM7",STR0045)                                               // 15-Responsavel //"Responsavel"
 oCell := TRCell():New(oSection5,"GM7_DESCAN","GM7",STR0046)                                               // 16-Motivo //"Motivo"

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณ RAFImp   ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 17/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RAFIMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
 Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()

 BeginSql alias "QRYGML"
   SELECT GML.GML_HORAGE, GML.GML_HORAFI, GML.GML_NOMPAC, GML.GML_DATAGE, GML.GML_DATCAN, GML.GML_TELPAC, GML.GML_REGGER, GML.GML_CODPLA, 
          GML.GML_CODPRO, GML.GML_HORCAN, GML.GML_USUCAN, GML.GML_CODCRM, GML.GML_CODCAN, GML.GML_USUCAD, 
          GM7.GM7_ORICAN, GM7.GM7_DESCAN, GCM.GCM_DESPLA, GA7.GA7_DESC  , SRA.RA_NOME  ,GBJ.GBJ_TEL , GCS.GCS_NOMLOC  
   FROM %table:GML% GML
        JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GML.GML_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%NotDel%
        JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GML.GML_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%
        JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GML.GML_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel%
   LEFT JOIN %table:GM7% GM7 ON GM7.GM7_CODCAN = GML.GML_CODCAN AND GM7.GM7_FILIAL = %xFilial:GM7% AND GM7.%NotDel%
        JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GML.GML_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
        JOIN %table:GBJ% GBJ ON GBJ.GBJ_CRM    = GML.GML_CODCRM AND GBJ.GBJ_FILIAL = %xFilial:GBJ% AND GBJ.%NotDel%
   WHERE GML.GML_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND GML.%NotDel% AND GML.GML_CODAGE = GML.GML_SEQAGE  
   AND GML.GML_DATAGE BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)% 
   AND GML.GML_CODCRM BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
   ORDER BY SRA.RA_NOME, GML.GML_DATCAN, GML.GML_HORCAN 
EndSql

	oSection1:EndQuery()
	
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYGML")->GML_CODCRM  == G }, {|| ("QRYGML")->GML_CODCRM } )     // Quebra por medico por pagina
	
	oSection3:SetParentQuery()                                                                           // Quebra por Data dentro da pagina
	oSection3:SetParentFilter( {|P| DTOC(("QRYGML")->GML_DATCAN) + ("QRYGML")->GML_CODCRM  == P }, {|| DTOC(("QRYGML")->GML_DATCAN) + ("QRYGML")->GML_CODCRM } )
	
 oSection4:SetParentQuery()
 oSection4:SetParentFilter( {|P| ("QRYGML")->GML_HORCAN + DTOC(("QRYGML")->GML_DATCAN) + ("QRYGML")->GML_CODCRM  == P }, {|| ("QRYGML")->GML_HORCAN + DTOC(("QRYGML")->GML_DATCAN) + ("QRYGML")->GML_CODCRM } )            
 
 oSection5:SetParentQuery()                                                                                                                                     
 oSection5:SetParentFilter( {|P| ("QRYGML")->GCM_DESPLA + ("QRYGML")->GML_HORCAN + DTOC(("QRYGML")->GML_DATCAN) + ("QRYGML")->GML_CODCRM  == P }, {|| ("QRYGML")->GCM_DESPLA + ("QRYGML")->GML_HORCAN + DTOC(("QRYGML")->GML_DATCAN) + ("QRYGML")->GML_CODCRM } )
 

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(GML->(LastRec()))
 
Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRAFR3บ Autor ณ LUIZ PEREIRA S. JR.บ Data ณ  07/03/06   บฑฑ 
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA RESERVA CIRURGICA CANCELADA                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRAFR3()

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Declaracao de Variaveis Locais                                      ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         :=  STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local Titulo         := STR0003 //"Reserva Cirurgica Cancelada."
 Local Cabec1         := ""
 Local Cabec2         := ""
 Local aOrd           := {}
 Local aArea          := GetArea()

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Declaracao de Variaveis Privadas                                    ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHRAF"
 Private nTipo        := 15
 Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao" //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private m_pag        := 01
 Private wnrel        := "HSPAHRAF"
 Private cString      := ""
 Private aRegistros   := {}
 Private nLin         := 80
 
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Da Filial                                                 ณ
 //ณ MV_PAR02	Ate a Filial                                              ณ
 //ณ MV_PAR03	Da Data Transferencia                                     ณ
 //ณ MV_PAR04	Ate a Data Transferencia                                  ณ
 //ณ MV_PAR05	Do Profissional                                           ณ
 //ณ MV_PAR06	Ate o Profissional                                        ณ
 //ณ MV_PAR07	Impressora ?                                              ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPRAF"
 If !Pergunte(cPerg,.T.)
  Return(.T.)
 EndIf
 
 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
                                                                                                  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                        
 //ณ Monta a interface padrao com o usuario...                           ณ                        
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 If nLastKey == 27
  Return
 Endif
 SetDefault(aReturn,cString)
 If nLastKey == 27
  Return
 Endif
 
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Luiz Pereira S. Jr บ Data ณ  07/03/06   บฑฑ
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

 Local cFilialDe  := mv_par01
 Local cFilialAte := mv_par02
 Local dDataDe    := mv_Par03
 Local dDataAte   := mv_Par04
 Local cProfiDe   := mv_Par05
 Local cProfiAte  := mv_Par06
 
 Local cGML_DATCAN := ""      
 Local cGML_CODCRM := ""
 Local nInt        := 0
 Local nTotGer     := 0  
 Local nTotal      := 0
 Local nTotMed     := 0
 Local cMotCan     := ""
 Local cRespCan    := ""
 Local cSQL        := ""
 
 Titulo := STR0003 + Dtoc(dDataDe)+ STR0007 +Dtoc(dDataAte)   //"Reserva Cirurgica Cancelada no Periodo de "###" Ate  " 

 cSQL := "SELECT GML.GML_HORAGE, GML.GML_HORAFI, GML.GML_NOMPAC, GML.GML_DATAGE, GML.GML_DATCAN, GML.GML_TELPAC, GML.GML_REGGER, GML.GML_CODPLA, "
 cSQL +=        "GML.GML_CODPRO, GML.GML_HORCAN, GML.GML_USUCAN, GML.GML_CODCRM, GML.GML_CODCAN, GML.GML_USUCAD, "
 cSQL +=        "GM7.GM7_ORICAN, GM7.GM7_DESCAN, GCM.GCM_DESPLA, GA7.GA7_DESC  , SRA.RA_NOME   , GCS.GCS_NOMLOC  "
 cSQL += "FROM "+ RetSqlName("GML") + " GML "
 cSQL +=         "JOIN "+ RetSqlName("GCM") + " GCM ON GCM.GCM_CODPLA = GML.GML_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSql +=         "JOIN "+ RetSqlName("GA7") + " GA7 ON GA7.GA7_CODPRO = GML.GML_CODPRO AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSql +=         "JOIN "+ RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO  = GML.GML_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql +=    "LEFT JOIN "+ RetSqlName("GM7") + " GM7 ON GM7.GM7_CODCAN = GML.GML_CODCAN AND GM7.GM7_FILIAL = '" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' "
 cSql +=         "JOIN "+ RetSqlName("GCS") + " GCS ON GCS.GCS_CODLOC = GML.GML_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSql += "WHERE GML.GML_FILIAL BETWEEN '" + cFilialDe     + "' AND '" + cFilialAte     + "' AND GML.D_E_L_E_T_ <> '*' AND GML.GML_CODAGE = GML.GML_SEQAGE AND "
 cSql +=       "GML.GML_DATAGE BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' AND "
 cSql +=       "GML.GML_CODCRM BETWEEN '" + cProfiDe  + "' AND '" + cProfiAte  + "' "
 cSql += "ORDER BY SRA.RA_NOME, GML.GML_DATCAN, GML.GML_HORCAN "
	
 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If EOF()
  HS_MsgInf(STR0008, STR0033, STR0034) //"Nenhum agendamento cancelado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
 Endif

 SetRegua(RecCount()+RecCount())
 While !EOF()    
 
  cMotCan  := QRY->GM7_DESCAN
  cRespCan := HS_RDescrB("GM7_ORICAN", QRY->GM7_ORICAN) + " / "

  aAdd(aRegistros, {QRY->GML_CODPLA,;
                    QRY->GML_CODCRM,;
                    QRY->RA_NOME,;
                    QRY->GML_NOMPAC,;
                    QRY->GCM_DESPLA,;
                    DTOC(STOD(QRY->GML_DATCAN)),; 
						              QRY->GML_HORCAN,;                           
                    DTOC(STOD(QRY->GML_DATAGE)),;  
                    QRY->GML_HORAGE,;
                    SUBSTR(QRY->GA7_DESC,1,30),;
                    QRY->GCS_NOMLOC,;
                    cMotCan,;//Motivo Cancelamento
                    cRespCan,;
                    QRY->GML_TELPAC,;
                    QRY->GML_USUCAN })   
                    
  DbSelectArea("QRY")
  DbSkip()
  IncRegua()    
 EndDo  
 
 If Len(aRegistros) <> 0
  For nInt := 1 to Len(aRegistros)
   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   If lAbortPrint
    @nLin,000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***" //"*** CANCELADO PELO OPERADOR ***"
    Exit
   Endif

   Cabec1 := STR0010 + aRegistros[nInt,3] + 	 Space(05) + STR0011	 + Posicione("GBJ", 1, xFilial("GBJ") + aRegistros[nInt,2], "GBJ_TEL")    //"Medico: "###"Telefone: "
  
   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Impressao do cabecalho do relatorio. . .                            ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
    ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[nInt,6])
   Endif    
 
   If cGML_CODCRM <> aRegistros[nInt,2] .And. !Empty(cGML_CODCRM) //Quebra Por Medico
   	nLin ++ 
  	 @nLin,009 PSAY STR0012 + transform(nToTal, "@E 999,999")  //"Total : "
   	nLin :=nLin + 2
   	@nLin,000 PSAY STR0013 + transform(nToTMed, "@E 999,999") //"Total do Medico : "
	   nTotMed := 0
	   nTotal  := 0 
	   
	   nLin := nLin+2
    @nLin, 000 PSAY  STR0010 + aRegistros[nInt,3] + 	 Space(05) + STR0011	 + Posicione("GBJ", 1, xFilial("GBJ") + aRegistros[nInt,2], "GBJ_TEL")    //"Medico: "###"Telefone: "
    nLin++
    
    cGML_CODCRM := aRegistros[nInt,2]
    cGML_DATCAN := aRegistros[nInt,6]
   EndIf 

   If cGML_DATCAN <> aRegistros[nInt,6] .And. !Empty(cGML_DATCAN)//Quebra por Data de Cancelamento
		 	nLin ++ 
   	@nLin,009 PSAY STR0012 + transform(nToTal, "@E 999,999") //"Total : "
   	
	   nLin := nLin + 2
	   ImpData(aRegistros[nInt,6])
	   nTotal := 0 
    cGML_DATCAN := aRegistros[nInt,6]
   EndIf   

   cGML_CODCRM := aRegistros[nInt,2]
   cGML_DATCAN := aRegistros[nInt,6]

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
   nLin++
  
   @nLin,010 PSAY aRegistros[nInt,13] + aRegistros[nInt,12] //Responsavel / Motivo do Cancelamento
   nLin := nLin + 1  
   nTotal++        
   nTotGer++
   nTotMed++
  Next 
 
  If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
   ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[Len(aRegistros),6])
  Endif    

	 nLin := nLin + 2 
 	@nLin,010 PSAY STR0012 + transform(nToTal, "@E 999,999") //"Total : "
	 nLin :=nLin + 2
  @nLin,000 PSAY STR0013 + transform(nToTMed, "@E 999,999") //"Total do Medico : "
	 nLin :=nLin + 2
  @nLin,004 PSAY STR0014 + transform(nToTGer, "@E 999,999") //"Total Geral : "
	 nTotMed := 0
 	nTotal  := 0  
 	nTotGEr := 0                         
 EndIf
 
 DbSelectArea("QRY")
 DbCloseArea()
 
 SET DEVICE TO SCREEN

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
 
 DBSelectArea("GMA")
 DbClearFilter()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณIMPCABEC  บ Autor ณ Gilson da Silva    บ Data ณ  06/03/06   บฑฑ
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
 
/*         1         2         3         4         5         6         7         8         9        10        11        12        13
 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
"Hora   Procedimento                    Nome                                        TELEFONE        AGENDADO POR    DATA AGDTO   HORA"
*/

 @nLin,000 PSAY  STR0015 //"Hora   Procedimento                    Nome                                        Telefone        Cancelado Por   Data Agdto   Hora"
 nLIn ++
	@nLin,000 PSAY  STR0016 //"          Plano                                                  Setor                                             "
 nLIn ++
	@nLin,000 PSAY  STR0017 //"          Responsavel / Motivo"
 nLin ++ 
 @nLin,000 PSAY  Repl("-",132)
 nLin ++       
 ImpData(cDataCan)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณIMPDATA   บ Autor ณ Luiz Pereira S. Jr.บ Data ณ  07/03/06   บฑฑ
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
 @nLin,000 PSAY  STR0018 //"Data: "
 @nLin,006 PSAY cDataCAn + STR0019 + HS_SEMANA(DOW(CTOD(cDataCan))) //" - "
 nLin := nLin + 2
Return()