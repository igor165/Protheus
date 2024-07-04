#INCLUDE "HSPAHRAG.ch"
#include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRAG  บ Autor ณ ANTONIO CARLOS     บ Data ณ  21/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA CANCELADA POR TRANSFERENCIA            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRAG()

Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRAF",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHRAGR3()  
 EndIF    
Return(Nil)     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 21/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4, oSection5
 Local oCell

 oReport := TReport():New("HSPAHRAG",HS_MontCabe(STR0033, MV_PAR03, MV_PAR04),"HSPRAG",{|oReport| RAGIMP(oReport)}, STR0001 + STR0002 + STR0003) //"Reserva Cir. Cancel. P/Transfer๋ncia"

 oSection1 := TRSection():New(oReport,STR0034,{"GMM","SRA","GBJ"}) //"M้dico"
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oCell := TRCell():New(oSection1,"GMM_CODCRM","GMM",STR0034)                                                     // 01-Medico 
 oCell := TRCell():New(oSection1,"RA_NOME","SRA"," ",,25)                                                        // 02-Descricao do Medico 
 oCell := TRCell():New(oSection1,"GBJ_TEL","GBJ",STR0035)                                                        // 03-Telefone do Medico  

 oSection2 := TRSection():New(oSection1,STR0036,{"GMM"}) //"Data"
 oSection2:SetTotalInLine(.F.)
 oCell := TRCell():New(oSection2,"GMM_DATCAN","GMM",STR0018)                                                       // 04-Data
 oCell := TRCell():New(oSection2,"cDatCan","GMM","",,20,,{|| "- " + HS_SEMANA(DOW(GMM_DatCan))})                   // 05-Data Por Extenso
                                                                                                               
 oSection3 := TRSection():New(oSection2,STR0037,{"GMM","GA7"}) //"Hora"
 oSection3:SetHeaderPage(.T.)
 oSection3:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection3,"GMM_HORCAN","GMM",STR0037)                                                       // 06-Hora 
 oCell := TRCell():New(oSection3,"GA7_DESC"  ,"GA7",STR0038)                                                       //"Procedimento"
 oCell := TRCell():New(oSection3,"GMM_NOMPAC","GMM",STR0039,,35)                                                   //"Nome"
 oCell := TRCell():New(oSection3,"GMM_TELPAC","GMM",STR0035)                                                      // 09-Telefone  
 oCell := TRCell():New(oSection3,"GMM_USUCAN","GMM",STR0040)                                                      // 10-Cancelado Por 
 oCell := TRCell():New(oSection3,"GMM_DATAGE","GMM",STR0041,,12)                                                  // 11-Data Agendadto"
 oCell := TRCell():New(oSection3,"GMM_HORAGE","GMM",STR0037)                                                       // 12-Hora Agendado 

	DEFINE FUNCTION FROM oSection3:Cell("GMM_HORCAN") OF oSection1 FUNCTION COUNT TITLE STR0013+" =>"                  // Totaliza por Medico 
	DEFINE FUNCTION FROM oSection3:Cell("GMM_HORCAN") OF oSection2 FUNCTION COUNT TITLE STR0042                        // Totaliza por Data
	                                                                                                                    
 oSection4 := TRSection():New(oSection3,OemToAnsi(STR0043),{"GCM","GCS","GMJ"})                                    //"Plano"
 oSection4:SetHeaderPage(.T.)
 oSection4:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection4,"GCM_DESPLA","GMM",STR0043)                                                        // 13-Plano  
 oCell := TRCell():New(oSection4,"GCS_NOMLOC","GCS",STR0044,,90)                                                    // 14-Setor  
 oCell := TRCell():New(oSection4,"GMJ_DATAGE","GMJ",STR0045)                                                        // 15-Data Transf.  
 oCell := TRCell():New(oSection4,"GMJ_HORAGE","GMJ",STR0037)                                                         // 16-Hora 

 oSection5 := TRSection():New(oSection4,OemToAnsi(STR0046),{"GM7"}) //"Responsแvel/Motivo"
 oSection5:SetHeaderPage(.T.)
 oSection5:SetHeaderBreak(.F.)                                                                                
 
 oCell := TRCell():New(oSection5,"GM7_ORICAN","GM7",STR0047)                                                        // 17-Responsavel 
 oCell := TRCell():New(oSection5,"GM7_DESCAN","GM7",STR0048)                                                        // 18-Motivo 

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณ RAGImp   ณ Autor ณ Antonio Carlos        ณ Data ณ 21/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RAGIMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
 Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()

 BeginSql alias "QRYGMM"

 SELECT GMM_HORAGE, GMM_HORAFI, GMM_NOMPAC, GMM_DATAGE, GMM_DATCAN, GMM_TELPAC, GMM_REGGER, GMM_CODPLA, GMM_CODPRO, GMM_HORCAN, GMM_USUCAN, 
        GMM_CODCRM, GMM_NOVAGE, GMM_CODCAN, GMM_USUCAD, GM7_ORICAN, GM7_DESCAN, GCM_DESPLA, GA7_DESC  , RA_NOME   , GCS_NOMLOC, GMJ_DATAGE, 
        GMJ_HORAGE, GBJ_TEL 
   FROM %table:GMM% GMM
        JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GMM.GMM_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%NotDel%
        JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GMM.GMM_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%
        JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GMM.GMM_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel%
   LEFT JOIN %table:GM7% GM7 ON GM7.GM7_CODCAN = GMM.GMM_CODCAN AND GM7.GM7_FILIAL = %xFilial:GM7% AND GM7.%NotDel%
        JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GMM.GMM_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
   LEFT JOIN %table:GMJ% GMJ ON GMJ.GMJ_CODAGE = GMM.GMM_NOVAGE AND GMJ.GMJ_FILIAL = %xFilial:GMJ% AND GMJ.%NotDel%
        JOIN %table:GBJ% GBJ ON GBJ.GBJ_CRM    = GMM.GMM_CODCRM AND GBJ.GBJ_FILIAL = %xFilial:GBJ% AND GBJ.%NotDel%
   WHERE GMM.GMM_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND GMM.%NotDel% AND GMM.GMM_CODAGE = GMM.GMM_SEQAGE  
   AND GMM.GMM_DATAGE BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)% 
   AND GMM.GMM_CODCRM BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
   ORDER BY RA_NOME, GMM_DATCAN, GMM_HORCAN 
EndSql

	oSection1:EndQuery()
	
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYGMM")->GMM_CODCRM  == G }, {|| ("QRYGMM")->GMM_CODCRM } )     // Quebra por medico por pagina
	
	oSection3:SetParentQuery()                                                                           // Quebra por Data dentro da pagina
	oSection3:SetParentFilter( {|P| DTOC(("QRYGMM")->GMM_DATCAN) + ("QRYGMM")->GMM_CODCRM  == P }, {|| DTOC(("QRYGMM")->GMM_DATCAN) + ("QRYGMM")->GMM_CODCRM } )
	
 oSection4:SetParentQuery()
 oSection4:SetParentFilter( {|P| ("QRYGMM")->GMM_HORCAN + DTOC(("QRYGMM")->GMM_DATCAN) + ("QRYGMM")->GMM_CODCRM  == P }, {|| ("QRYGMM")->GMM_HORCAN + DTOC(("QRYGMM")->GMM_DATCAN) + ("QRYGMM")->GMM_CODCRM } )            
 
 oSection5:SetParentQuery()                                                                                                                                     
 oSection5:SetParentFilter( {|P| ("QRYGMM")->GCM_DESPLA + ("QRYGMM")->GMM_HORCAN + DTOC(("QRYGMM")->GMM_DATCAN) + ("QRYGMM")->GMM_CODCRM  == P }, {|| ("QRYGMM")->GCM_DESPLA + ("QRYGMM")->GMM_HORCAN + DTOC(("QRYGMM")->GMM_DATCAN) + ("QRYGMM")->GMM_CODCRM } )
 

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(GMM->(LastRec()))
 
Return( NIL )




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRAGR3บ Autor ณ LUIZ PEREIRA S. JR.บ Data ณ  06/03/06   บฑฑ 
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA RESERVA CIRURGICA CANCELADA POR TRANSFERENCIA บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRAGR3()

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Declaracao de Variaveis Locais                                      ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local Titulo         := STR0003 //"Reserva Cirurgica Cancelada por Transferencia."
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
 Private tamanho      := "G"
 Private nomeprog     := "HSPAHRAG"
 Private nTipo        := 15
 Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private m_pag        := 01
 Private wnrel        := "HSPAHRAG"
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
 cPerg := "HSPRAG"

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
 
 Local cGMM_DATCAN := ""      
 Local cGMM_CODCRM := ""
 Local nInt        := 0
 Local nTotGer     := 0  
 Local nTotal      := 0
 Local nTotMed     := 0
 Local cMotCan     := ""
 Local cRespCan    := ""
 Local cSQL        := ""
 
 Titulo := STR0006 + Dtoc(dDataDe)+ STR0007 +Dtoc(dDataAte) //"Agenda Cancelada por Transferencia no Periodo de    "###"   Ate  "

 cSQL := "SELECT GMM.GMM_HORAGE, GMM.GMM_HORAFI, GMM.GMM_NOMPAC, GMM.GMM_DATAGE, GMM.GMM_DATCAN, GMM.GMM_TELPAC, GMM.GMM_REGGER, GMM.GMM_CODPLA, "
 cSQL +=        "GMM.GMM_CODPRO, GMM.GMM_HORCAN, GMM.GMM_USUCAN, GMM.GMM_CODCRM, GMM.GMM_NOVAGE, GMM.GMM_CODCAN, GMM.GMM_USUCAD, "
 cSQL +=        "GM7.GM7_ORICAN, GM7.GM7_DESCAN, GCM.GCM_DESPLA, GA7.GA7_DESC  , SRA.RA_NOME   , GCS.GCS_NOMLOC, GMJ.GMJ_DATAGE, GMJ.GMJ_HORAGE "
 cSQL += "FROM "+ RetSqlName("GMM") + " GMM "
 cSQL +=         "JOIN "+ RetSqlName("GCM") + " GCM ON GCM.GCM_CODPLA = GMM.GMM_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSql +=         "JOIN "+ RetSqlName("GA7") + " GA7 ON GA7.GA7_CODPRO = GMM.GMM_CODPRO AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSql +=         "JOIN "+ RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO  = GMM.GMM_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql +=    "LEFT JOIN "+ RetSqlName("GM7") + " GM7 ON GM7.GM7_CODCAN = GMM.GMM_CODCAN AND GM7.GM7_FILIAL = '" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' "
 cSql +=         "JOIN "+ RetSqlName("GCS") + " GCS ON GCS.GCS_CODLOC = GMM.GMM_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSql +=    "LEFT JOIN "+ RetSqlName("GMJ") + " GMJ ON GMJ.GMJ_CODAGE = GMM.GMM_NOVAGE AND GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "
 cSql += "WHERE GMM.GMM_FILIAL BETWEEN '" + cFilialDe     + "' AND '" + cFilialAte     + "' AND GMM.D_E_L_E_T_ <> '*' AND GMM.GMM_CODAGE = GMM.GMM_SEQAGE AND "
 cSql +=       "GMM.GMM_DATAGE BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' AND "
 cSql +=       "GMM.GMM_CODCRM BETWEEN '" + cProfiDe  + "' AND '" + cProfiAte  + "' "
 cSql += "ORDER BY SRA.RA_NOME, GMM.GMM_DATCAN, GMM.GMM_HORCAN "
	
 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If EOF()
  HS_MsgInf(STR0008, STR0031, STR0032) //"Nenhum agendamento cancelado por transferencia foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
 Endif

 SetRegua(RecCount()+RecCount())
 While !EOF()    
 
  cMotCan  := QRY->GM7_DESCAN
  cRespCan := HS_RDescrB("GM7_ORICAN", QRY->GM7_ORICAN) + " / "

  aAdd(aRegistros, {QRY->GMM_CODPLA,;
                    QRY->GMM_CODCRM,;
                    QRY->RA_NOME,;
                    QRY->GMM_NOMPAC,;
                    QRY->GCM_DESPLA,;
                    DTOC(STOD(QRY->GMM_DATCAN)),; 
						              QRY->GMM_HORCAN,;                           
                    DTOC(STOD(QRY->GMM_DATAGE)),;  
                    QRY->GMM_HORAGE,;
                    SUBSTR(QRY->GA7_DESC,1,30),;
                    QRY->GCS_NOMLOC,;
                    cMotCan,;//Motivo Cancelamento
                    cRespCan,;
                    QRY->GMM_TELPAC,;
                    QRY->GMM_USUCAN,;//Origem do Cancelamento.
                    QRY->GMJ_HORAGE,;
                    STOD(QRY->GMJ_DATAGE) })   
                    
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
    @nLin,000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
    Exit
   Endif

   Cabec1 := STR0010 + aRegistros[nInt,3] + 	 Space(05) + STR0011	 + Posicione("GBJ", 1, xFilial("GBJ") + aRegistros[nInt,2], "GBJ_TEL") //"Medico: "###"Telefone: "
  
   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Impressao do cabecalho do relatorio. . .                            ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
    ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[nInt,6])
   Endif    
 
   If cGMM_CODCRM <> aRegistros[nInt,2] .And. !Empty(cGMM_CODCRM) //Quebra Por Medico
   	nLin ++ 
  	 @nLin,009 PSAY STR0012 + transform(nToTal, "@E 999,999") //"Total : "
   	nLin :=nLin + 2
   	@nLin,000 PSAY STR0013 + transform(nToTMed, "@E 999,999") //"Total do Medico : "
	   nTotMed := 0
	   nTotal  := 0 
	   
	   nLin := nLin+2
    @nLin, 000 PSAY  STR0010 + aRegistros[nInt,3] + 	 Space(05) + STR0011	 + Posicione("GBJ", 1, xFilial("GBJ") + aRegistros[nInt,2], "GBJ_TEL")   //"Medico: "###"Telefone: "	 //### //"Medico: "###"Telefone: "
    nLin++
    
    cGMM_CODCRM := aRegistros[nInt,2]
    cGMM_DATCAN := aRegistros[nInt,6]
   EndIf 

   If cGMM_DATCAN <> aRegistros[nInt,6] .And. !Empty(cGMM_DATCAN)//Quebra por Data de Cancelamento
		 	nLin ++ 
   	@nLin,009 PSAY STR0012 + transform(nToTal, "@E 999,999") //"Total : "
	   nLin := nLin + 2
	   ImpData(aRegistros[nInt,6])
	   nTotal := 0 
    cGMM_DATCAN := aRegistros[nInt,6]
   EndIf   

   cGMM_CODCRM := aRegistros[nInt,2]
   cGMM_DATCAN := aRegistros[nInt,6]

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
ฑฑบFuno    ณIMPCABEC  บ Autor ณ Luiz Pereira S. Jr.บ Data ณ  07/03/06   บฑฑ
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
/*          1         2         3         4         5         6         7         8         9        10        11        12        13
	 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
 "Hora   Procedimento                    Nome                                        TELEFONE        AGENDADO POR    DATA AGDTO   HORA"
  */
  
 @nLin,000 PSAY  STR0015 //"Hora   Procedimento                    Nome                                        Telefone        Cancelado Por   Data Agdto   Hora"
 nLIn ++
	@nLin,000 PSAY  STR0016 //"          Plano                                                  Setor                                             Data Transf. Hora"
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