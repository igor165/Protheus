#INCLUDE "HSPAHR73.ch"                                                 
#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR73  บ Autor ณ ANTONIO CARLOS     บ Data ณ  17/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA CANCELADA                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR73()

Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR73",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR73R3()  
 EndIF    
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 06/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4, oSection5
 Local oCell
 Local oTotaliz1, oTotaliz2
 Local oBreak

 oReport := TReport():New("HSPAHR73",HS_MontCabe(STR0003, MV_PAR03, MV_PAR04),"HSPR73",{|oReport| R73IMP(oReport)}, STR0001 + STR0002 + STR0003)

 oSection1 := TRSection():New(oReport,STR0008,{"GM9","SRA"})
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oCell := TRCell():New(oSection1,"GM9_CODCRM","GM9",STR0008)                                                     // 01-Medico
 oCell := TRCell():New(oSection1,"RA_NOME","GM9"," ")                                                            // 02-Descricao do Medico 
 
 oSection2 := TRSection():New(oSection1,STR0010,{"GM9"})
 oSection2:SetTotalInLine(.F.)
 oCell := TRCell():New(oSection2,"GM9_DATCAN","GM9",STR0010)                                                      // 03-Data
 oCell := TRCell():New(oSection2,"cDatCan","GM9","",,20,,{|| "- " + HS_SEMANA(DOW(GM9_DatCan))})                  // 03-Data Por Extenso

 oSection3 := TRSection():New(oSection2,STR0011,{"GM9","GA7"})
 oSection3:SetHeaderPage(.T.)
 oSection3:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection3,"GM9_HORCAN","GM9",STR0011)                                                      // 04-Hora
 oCell := TRCell():New(oSection3,"GA7_DESC","GA7",STR0017)                                                        // 05-Procedimento 
 oCell := TRCell():New(oSection3,"GM9_NOMPAC","GM9",STR0018)                                                      // Nome    : 
 oCell := TRCell():New(oSection3,"GM9_DATAGE","GM9",STR0019)                                                      // 07-Data Agendado 
 oCell := TRCell():New(oSection3,"GM9_HORAGE","GM9"," ")                                                          // 08-Hora Agendado

	DEFINE FUNCTION FROM oSection3:Cell("GM9_HORCAN") OF oSection1 FUNCTION COUNT TITLE STR0008+"=>"                  // Totaliza por Medico 
	DEFINE FUNCTION FROM oSection3:Cell("GM9_HORCAN") OF oSection2 FUNCTION COUNT TITLE STR0010+"=>"                  // Totaliza por Data
                                                                                                                   
 oSection4 := TRSection():New(oSection3,STR0020,{"GCM","GCS"}) //"Plano"
 oSection4:SetHeaderPage(.T.)
 oSection4:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection4,"GCM_DESPLA","GM9",STR0020)                                                        // 09-Plano 
 oCell := TRCell():New(oSection4,"GCS_NOMLOC","GCS",STR0021)                                                        // 10-Setor 

 oSection5 := TRSection():New(oSection4,OemToAnsi(STR0009),{"GM7"})
 oSection5:SetHeaderPage(.T.)
 oSection5:SetHeaderBreak(.F.)                                                    
 oCell := TRCell():New(oSection5,"GM7_ORICAN","GM7",STR0022)                                                        // 11-Responsavel
 oCell := TRCell():New(oSection5,"GM7_DESCAN","GM7",STR0023)                                                        // 12-Motivo

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R73Imp   ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 17/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R73IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
 Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()

 BeginSql alias "QRYGM9"
   SELECT GM9_CODCRM, RA_NOME, GM9_DATCAN, GM9_HORCAN, GM9_CODPRO, GA7_DESC, GM9_NOMPAC, GM9_DATAGE, GM9_HORAGE, GM9_CODPLA, GCM_DESPLA,;
          GM9_CODLOC, GCS_NOMLOC, GM9_CODCAN, GM7_DESCAN, GM7_ORICAN 
   FROM %table:GM9% GM9                                   
   JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GM9.GM9_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel%
   JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GM9.GM9_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel% 
   JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GM9.GM9_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%NotDel%  
   JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GM9.GM9_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
   JOIN %table:GM7% GM7 ON GM7.GM7_CODCAN = GM9.GM9_CODCAN AND GM7.GM7_FILIAL = %xFilial:GM7% AND GM7.%NotDel%
   WHERE GM9.GM9_FILIAL = %xFilial:GM9% AND GM9.%notDel%
   AND GM9.GM9_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND GM9.GM9_DATCAN BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
   AND GM9.GM9_CODCRM BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%    
   ORDER BY RA_NOME, GM9_DATCAN, GM9_HORCAN
EndSql

	oSection1:EndQuery()
	
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYGM9")->GM9_CODCRM  == G }, {|| ("QRYGM9")->GM9_CODCRM } )     // Quebra por medico por pagina
	
	oSection3:SetParentQuery()                                                                           // Quebra por Data dentro da pagina
	oSection3:SetParentFilter( {|P| DTOC(("QRYGM9")->GM9_DATCAN) + ("QRYGM9")->GM9_CODCRM  == P }, {|| DTOC(("QRYGM9")->GM9_DATCAN) + ("QRYGM9")->GM9_CODCRM } )
	
 oSection4:SetParentQuery()
 oSection4:SetParentFilter( {|P| ("QRYGM9")->GM9_HORCAN + DTOC(("QRYGM9")->GM9_DATCAN) + ("QRYGM9")->GM9_CODCRM  == P }, {|| ("QRYGM9")->GM9_HORCAN + DTOC(("QRYGM9")->GM9_DATCAN) + ("QRYGM9")->GM9_CODCRM } )            
 
 oSection5:SetParentQuery()                                                                                                                                     
 oSection5:SetParentFilter( {|P| ("QRYGM9")->GCM_DESPLA + ("QRYGM9")->GM9_HORCAN + DTOC(("QRYGM9")->GM9_DATCAN) + ("QRYGM9")->GM9_CODCRM  == P }, {|| ("QRYGM9")->GCM_DESPLA + ("QRYGM9")->GM9_HORCAN + DTOC(("QRYGM9")->GM9_DATCAN) + ("QRYGM9")->GM9_CODCRM } )
 

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(GM9->(LastRec()))
 
Return( NIL )




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR73R3บ Autor ณ GILSON DA SILVA    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA CANCELADA                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracoesณ 11/08/05 - Mario Arizono      		                           บฑฑ
ฑฑบ          ณ 10/07/06 - Patricia Queiroz                                บฑฑ
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

Function HSPAHR73R3()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Locais                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3 := ""
Local Titulo := STR0003 //"Agenda Cancelada."
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
Private tamanho     := "M"
Private nomeprog    := "HSPAHR73"
Private nTipo       := 15
Private aReturn     := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private m_pag       := 01
Private wnrel       := "HSPAHR73"
Private cString     := ""
Private aRegistros  := {}
Private nLin        := 80

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PARAMETROS                                                         ณ
//ณ MV_PAR01	Da Filial                                               ณ
//ณ MV_PAR02	Ate a Filial                                            ณ
//ณ MV_PAR03	Da data de Cancelamento                                 ณ
//ณ MV_PAR04	Ate a data de Cancelamento                              ณ
//ณ MV_PAR05	Do Profissional                                         ณ
//ณ MV_PAR06	Ate o Profissional                                      ณ
//| MV_PAR07 Impressora ?                                              |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPerg := "HSPR73"
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
Local cFilAge_De  := mv_par01
Local cFilAge_Ate := mv_par02
Local dDatCan_De  := mv_par03
Local dDatCan_Ate := mv_par04
Local cCodCRM_De  := mv_par05
Local cCodCRM_Ate := mv_par06

Local cGM9_DATCAN := ""
Local cGM9_CODCRM := ""
Local nInt        := 0
Local nTotal      := 0
Local nTotMed     := 0
Local cMotCan     := ""
Local cRespCan    := ""
Local cSQL        := ""
Local lImpDat     := .F. //variavel para controlar a impressao da data.

cSQL := "SELECT GM9.GM9_CODCRM, SRA.RA_NOME, GM9.GM9_DATCAN, GM9.GM9_HORCAN, "
cSQL += "GM9.GM9_CODPRO, GA7.GA7_DESC, GM9.GM9_NOMPAC, GM9.GM9_DATAGE, GM9.GM9_HORAGE, "
cSQL += "GM9.GM9_CODPLA, GCM.GCM_DESPLA, GM9.GM9_CODLOC, GCS.GCS_NOMLOC, GM9.GM9_CODCAN "
cSQL += "FROM " + RetSQLName("GM9") + " GM9 "
cSQL += "JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cSQL += "AND SRA.RA_CODIGO  = GM9.GM9_CODCRM "
cSQL += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
cSQL += "AND GA7.GA7_CODPRO = GM9.GM9_CODPRO "
cSQL += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cSQL += "AND GCM.GCM_CODPLA = GM9.GM9_CODPLA "
cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cSQL += "AND GCS.GCS_CODLOC = GM9.GM9_CODLOC "
cSQL += "WHERE GM9.GM9_FILIAL = '" + xFilial("GM9") + "' AND GM9.D_E_L_E_T_ <> '*' "
cSQL += " AND GM9.GM9_FILAGE BETWEEN '" + cFilAge_De + "' AND '" + cFilAge_Ate + "' "
cSQL += " AND GM9.GM9_DATCAN BETWEEN '" + DTOS(dDatCan_De) + "' AND '" + DTOS(dDatCan_Ate) + "' "
cSQL += " AND GM9.GM9_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' "
cSQL += "ORDER BY SRA.RA_NOME, GM9.GM9_DATCAN, GM9.GM9_HORCAN"

cSQL :=  ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()
If EOF()
	HS_MsgInf(STR0015, STR0016, STR0003) //"Nenhum agendamento cancelado foi encontrado para a selecao efetuada!" //"Aten็ใo"//"Agenda Cancelada."
Else
	Titulo := HS_MontCabe(STR0003, MV_PAR03, MV_PAR04)
EndIf

SetRegua(1000)
While !EOF()
	
	DBSelectArea("GM7")
	DBSetOrder(1)
	If DbSeek(xFilial("GM7") +  QRY->GM9_CODCAN)
		cMotCan  := GM7->GM7_DESCAN
		cRespCan := HS_RDescrB("GM7_ORICAN", GM7->GM7_ORICAN) + " / "
	Else
		cMotCan  := ""
		cRespCan := ""
	EndIf
	
	aAdd(aRegistros, {QRY->GM9_CODPLA,  ; //  1
	QRY->GM9_CODCRM,  ;                //  2
	QRY->RA_NOME,     ;                //  3
	QRY->GM9_NOMPAC,  ;                //  4
	QRY->GCM_DESPLA,  ;                //  5
	QRY->GM9_DATCAN,  ;                //  6
	QRY->GM9_HORCAN,  ;                //  7
	DTOC(STOD(QRY->GM9_DATAGE)), ;    //  8
	QRY->GM9_HORAGE,  ;                //  9
	QRY->GA7_DESC,    ;                // 10
	QRY->GCS_NOMLOC,  ;                // 11
	cMotCan,          ;                // 12
	cRespCan})                         // 13
	
	DbSelectArea("QRY")
	DbSkip()
	IncRegua()
EndDo

If Len(aRegistros) <> 0
	For nInt := 1 to Len(aRegistros)
		lImpdat := .F.
		If lAbortPrint
			@nLin,000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		EndIf
		
		Cabec1 := STR0008 + AllTrim(aRegistros[nInt,2]) + "-" + aRegistros[nInt,3]  //"Medico: "
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[nInt,6])
			lImpDat := .T.
		EndIf
		
		If cGM9_CODCRM <> aRegistros[nInt,2] .And. !Empty(cGM9_CODCRM) //Quebra Por Medico
			nLin ++
			@nLin,009 PSAY STR0013+transform(nToTal, "@E 999,999")//###"Total : "
			nLin :=nLin + 2
			@nLin,000 PSAY STR0012+transform(nToTMed, "@E 999,999")//###"Total do Medico : "
			nTotMed := 0
			nTotal  := 0
			ImpCabec(Cabec1,Cabec2,Titulo,aRegistros[nInt,6])
			ImpData(aRegistros[nInt,6])
			lImpDat := .F.
			cGM9_CODCRM := aRegistros[nInt,2]
			cGM9_DATCAN := aRegistros[nInt,6]
		EndIf
		
		If cGM9_DATCAN <> aRegistros[nInt,6] .And. !Empty(cGM9_DATCAN)//Quebra por Data de Cancelamento
			nLin ++
			@nLin,009 PSAY STR0013+transform(nToTal, "@E 999,999")//###"Total : "
			nLin := nLin + 2
			ImpData(aRegistros[nInt,6])
			lImpDat := .F.
			nTotal := 0
			cGM9_DATCAN := aRegistros[nInt,6]
		EndIf
		
		If lImpDat
			ImpData(aRegistros[nInt,6])
		EndIf
		
		cGM9_CODCRM := aRegistros[nInt,2]
		cGM9_DATCAN := aRegistros[nInt,6]
		
		@nLin,000 PSAY aRegistros[nInt,7]                //Horario do cancelamento
		@nLin,010 PSAY aRegistros[nInt,10]               //Descricao do procedimento
		@nLin,065 PSAY aRegistros[nInt,4]                //Nome do Paciente
		@nLin,112 PSAY aRegistros[nInt,8]                //Data do Agendamento
		@nLin,124 PSAY aRegistros[nInt,9]                //Hora do agendamento
		
		nLin++
		
		@nLin,010 PSAY aRegistros[nInt,5]      					     //Descricao do Plano
		@nLin,065 PSAY aRegistros[nInt,11]         					 //Setor
		
		nLin++
		
		@nLin,010 PSAY aRegistros[nInt,13]+ aRegistros[nInt,12]  //Responsavel / Motivo do Cancelamento
		nLin := nLin + 1
		@nLin,000 PSAY  Repl("-",132)
		nLin := nLin + 1
		nTotal++
		nTotMed++
	Next
	
	nLin := nLin + 2
	@nLin,010 PSAY STR0013+transform(nToTal, "@E 999,999")  //###"Total : "
	nLin :=nLin + 2
	@nLin,000 PSAY STR0012+transform(nToTMed, "@E 999,999")  //###"Total do Medico : "
	nTotMed := 0
	nTotal  := 0
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

DBSelectArea("GM9")
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
@nLin,000 PSAY  STR0006  //"Hora      Procedimento                                           Nome                                           Agendado"
nLIn ++
@nLin,000 PSAY  STR0014  //"          Plano                                                  Setor"
nLIn ++
@nLin,000 PSAY  STR0009  //"          Responsavel / Motivo "
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
ฑฑบDescrio ณ Imprime a Data e o Dia da semana do Cancelamento.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpData(cDataCan)
nLin ++
@nLin,000 PSAY  STR0010    //"Data: "
@nLin,006 PSAY DTOC(STOD(cDataCan)) + " - " + HS_SEMANA(DOW(STOD(cDataCan)))
nLin := nLin + 2
Return