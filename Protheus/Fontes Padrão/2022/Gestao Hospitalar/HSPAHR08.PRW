#INCLUDE "HSPAHR08.ch"
#Include "protheus.ch"
#Include "TopConn.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR08 บ       ณ Antonio Carlos     บ Data ณ 24/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Agendas X Medico X Enderecos                     บฑฑ 
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR08()

Local oReport
If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPR08",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE
	HSPAHR08R3()
EndIF
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 24/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2, oSection3, oSection4, oSection5
Local oCell

oReport := TReport():New("HSPAHR08",STR0003,"HSPR08",{|oReport| R08IMP(oReport)},STR0001 + " " + STR0002)   //"Agendas por Medico com enderecos"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
oReport:SetPortrait()          

oSection1 := TRSection():New(oReport,STR0010,{"QRYR08"})  //"Data de Agendamento"
oSection1:SetHeaderBreak(.T.)    //Indica se cabecalho da secao sera impresso em cada quebra
oSection1:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
oSection1:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
oSection1:SetPageBreak(.T.)      //Indica quebra de pagina no final da secao
oSection1:SetNoFilter({"QRYR08"})     
oCell := TRCell():New(oSection1,"GM8_DATAGE","QRYR08",STR0010,,20,,)   //"Data de Agend.:"
oCell := TRCell():New(oSection1,"cDATAGE","QRYR08","",,20,,{||cDATAGE:=HS_SEMANA(DOW(QRYR08->GM8_DATAGE))})

oSection2 := TRSection():New(oSection1,STR0011,{"QRYR08"})   //"M้dico"
oSection2:SetHeaderBreak(.T.)    //Indica se cabecalho da secao sera impresso em cada quebra
oSection2:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
oSection2:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)            
oSection2:SetNoFilter({"QRYR08"})     
oCell := TRCell():New(oSection2,"RA_NOME","QRYR08",STR0011,,20,,)   //"M้dico.:"
oCell := TRCell():New(oSection2,"GCS_NOMLOC","QRYR08",STR0012,,35)  //"Setor.: "                 
oCell := TRCell():New(oSection2,"GM6_DESDIS","QRYR08",STR0013,,35)  //"Disp..:"                 

oSection3 := TRSection():New(oSection2,STR0019,{"QRYR08"})          //"Horแrios"      
oSection3:SetHeaderBreak(.T.)    //Indica se cabecalho da secao sera impresso em cada quebra
oSection3:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
oSection3:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
oSection3:SetNoFilter({"QRYR08"})     
oCell := TRCell():New(oSection3,"GM8_HORAGE","QRYR08",STR0015,)     //"Hora "
oCell := TRCell():New(oSection3,"GM8_REGGER","QRYR08",STR0016)      //"Prontuแrio"
oCell := TRCell():New(oSection3,"GBH_NOME"  ,"QRYR08",STR0020,,35)  //"Nome"  
oCell := TRCell():New(oSection3,"GSD_DESEND","QRYR08",STR0017)      //"Endere็o"
oCell := TRCell():New(oSection3,"GBH_TEL"   ,"QRYR08")
oCell := TRCell():New(oSection3,"GCM_DESPLA","QRYR08")
oCell := TRCell():New(oSection3,"GM8_CODPRO","QRYR08",STR0018)      //"Procedimento"
oCell := TRCell():New(oSection3,"GA7_DESC"  ,"QRYR08","",,20)

oSection3:SetParentRecno()
                                                                                                    
oSection3:SetTotalText(STR0014)    //"Total Agenda...: "

oTotaliz := TRFunction():new(oSection3:Cell("GM8_HORAGE"),,"COUNT",,"",,,.T.,.F.,.F.,oSection1) 

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R08Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 24/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R08IMP(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)

Local	cCond := "%%"

MakeSqlExpr(oReport:uParam)
oSection1:BeginQuery()

If !EMPTY(MV_PAR05)
 cCond := "%GM8.GM8_CODLOC = '" + MV_PAR05 + "' %"
Else
 cCond := "%GM8.GM8_CODLOC <> '" + STR(Len(MV_PAR05)) + "'%"
EndIf

BeginSql alias "QRYR08"
 SELECT GM8_CODAGE, GM8_CODCRM, GM8_DATAGE, GM8_CODLOC, GCS_NOMLOC, GM8_CODDIS, GM6_DESDIS, GM8_HORAGE,;
        GM8_REGGER, GBH_NOME, GBH_TEL, GCM_DESPLA, GM8_CODPRO, GA7_DESC, GSD_DESEND, RA_NOME
      FROM %table:GM8% GM8
      JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GM8.GM8_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%notDel%
      JOIN %table:GM6% GM6 ON GM6.GM6_CODDIS = GM8.GM8_CODDIS AND GM6.GM6_FILIAL = %xFilial:GM6% AND GM6.%notDel%
      JOIN %table:GBH% GBH ON GBH.GBH_CODPAC = GM8.GM8_REGGER AND GBH.GBH_FILIAL = %xFilial:GBH% AND GBH.%notDel%
      JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GM8.GM8_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%notDel%
      JOIN %table:GSB% GSB ON GSB.GSB_REGGER = GM8.GM8_REGGER AND GSB.GSB_FILIAL = %xFilial:GSB% AND GSB.%notDel%
      JOIN %table:GSD% GSD ON GSD.GSD_CODEND = GSB.GSB_CODEND AND GSD.GSD_FILIAL = %xFilial:GSD% AND GSD.%notDel%
      JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GM8.GM8_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%notDel%
	LEFT JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GM8.GM8_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%notDel%
 WHERE GM8.GM8_FILIAL = %xFilial:GM8% AND GM8.%notDel%
   AND GM8.GM8_DATAGE BETWEEN %Exp:DTOS(MV_PAR06)% AND %Exp:DTOS(MV_PAR07)%
   AND GM8.GM8_CODCRM BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND GM8.GM8_CODPRO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
   AND %Exp:cCond%
 ORDER BY GM8_FILIAL, GM8_DATAGE, RA_NOME, RA_CODIGO, GCS_NOMLOC, GCS_CODLOC, GM6_DESDIS, GM6_CODDIS, GM8_HORAGE,;
          GBH_NOME, GM8_REGGER
EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYR08")->GM8_DATAGE == G }, {|| ("QRYR08")->GM8_DATAGE})
	oSection3:SetParentQuery()
 oSection3:SetParentFilter( {|H| ("QRYR08")->RA_NOME + DTOC(("QRYR08")->GM8_DATAGE) == H }, {|| ("QRYR08")->RA_NOME + DTOC(("QRYR08")->GM8_DATAGE)})

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(GCY->(LastRec()))
                   
Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR08R3บ Autor ณ Daniel Peixoto     บ Data ณ  10/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Agendas X Medico X Enderecos                     บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR08R3()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Agendas por Medico com enderecos"
 Local aOrd   := {}
 
 Private Titulo      := cDesc3
 Private Cabec1      := ""
 Private Cabec2      := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR08" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 
 Private cPerg       := "HSPR08"

 Private cRegGer     := ""
 Private cCodLoc     := ""
 Private cCodPro     := ""
 Private dDatAge_De  := ""
 Private dDatAge_Ate := ""
 
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao


 If !Pergunte(cPerg,.T.)
  return
 EndIf

 cDoCodCrm   := MV_PAR01
 cAteCodCrm  := MV_PAR02
 cDoCodPro   := MV_PAR03
 cAteCodPro		:= MV_PAR04
 cDoCodLoc   := MV_PAR05
 dDatAge_De  := MV_PAR06
 dDatAge_Ate := MV_PAR07
 
 nMaxLin := HS_MaxLin(cCODIMP)
  
 wnrel := SetPrint("", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport("") }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  06/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql    	:= ""
 Local cCodCrm   	:= ""
 Local cRegGer   	:= ""
 Local cDatAge   	:= ""
 Local cCodDis   	:= ""
 Local cCodLoc			 := ""
 Local cHorAge				:= ""
 Local nTotAge    := 0
 
 Private nLin    	:= nMaxLin * 2
 
 cSQL := "SELECT "
 cSQL += "GM8.GM8_CODAGE, GM8.GM8_CODCRM, GM8.GM8_DATAGE, GM8.GM8_CODLOC, GCS.GCS_NOMLOC, GM8.GM8_CODDIS, GM6.GM6_DESDIS, GM8.GM8_HORAGE, "
 cSQL += "GM8.GM8_REGGER, GBH.GBH_NOME, GBH.GBH_TEL, GCM.GCM_DESPLA, GM8.GM8_CODPRO, GA7.GA7_DESC, GSD.GSD_DESEND, SRA.RA_NOME"
 cSQL += " FROM " + RetSQLName("GM8") + " GM8"
 cSQL += " 		   	JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GM8.GM8_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += "      	JOIN " + RetSQLName("GM6") + " GM6 ON GM6.GM6_CODDIS = GM8.GM8_CODDIS AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.D_E_L_E_T_ <> '*' "
 cSQL += "      	JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GM8.GM8_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += "      	JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GM8.GM8_CODPRO AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " 				 	JOIN " + RetSQLName("GSB") + " GSB ON GSB.GSB_REGGER = GM8.GM8_REGGER AND GSB.GSB_FILIAL = '" + xFilial("GSB") + "' AND GSB.D_E_L_E_T_ <> '*' "       
 cSQL += " 				 	JOIN " + RetSQLName("GSD") + " GSD ON GSD.GSD_CODEND = GSB.GSB_CODEND AND GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' "       
 cSQL += " 				 	JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GM8.GM8_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'  "       
	cSQL += " 				 	LEFT JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GM8.GM8_CODPLA AND GCM.GCM_FILIAL  = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "

 cSQL += " WHERE "
 cSQL += " GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
 cSQL += " AND GM8.GM8_DATAGE BETWEEN '" + DTOS(dDatAge_De) + "' AND '" + DTOS(dDatAge_Ate) + "' "
 cSQL += " AND GM8.GM8_CODCRM BETWEEN '" + cDoCodCrm + "' AND '" + cAteCodCrm + "'"
 cSQL += " AND GM8.GM8_CODPRO BETWEEN '" + cDoCodPro + "' AND '" + cAteCodPro + "'"
 
 If !EMPTY(cDoCodLoc)
  cSQL += " AND GM8.GM8_CODLOC = '" + cDoCodLoc + "' "
 EndIf
 
 cSQL += " ORDER BY GM8.GM8_FILIAL, GM8.GM8_DATAGE, SRA.RA_NOME, SRA.RA_CODIGO, GCS.GCS_NOMLOC, GCS.GCS_CODLOC, GM6.GM6_DESDIS, GM6.GM6_CODDIS, GM8.GM8_HORAGE, GBH.GBH_NOME, GM8.GM8_REGGER"
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0006, STR0007, STR0008) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Agendas por Medico com enderecos"
  DbCloseArea()
  Return()
 Endif 
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(200)
 While !EOF()                                                                                
  IncRegua()
                      
  If nLin+2 > nMaxLin
   FS_Cabec()
   nLin ++ 
  ElseIf cDatAge <> QRY->GM8_DATAGE .Or. cCodCrm <> QRY->GM8_CODCRM .Or. cCodLoc <> QRY->GM8_CODLOC .Or. cCodDis <> QRY->GM8_CODDIS
   @nLin, 000 PSAY STR0014 + TRANSFORM(nTotAge, "@E 999,999") //"Total Agenda...: "
   nTotAge := 0
   FS_Cabec()
   nLin ++ 
  Endif

  If cDatAge <> QRY->GM8_DATAGE .Or. cCodCrm <> QRY->GM8_CODCRM .Or. cCodLoc <> QRY->GM8_CODLOC .Or. cCodDis <> QRY->GM8_CODDIS
   
   cDatAge := QRY->GM8_DATAGE
   cCodCrm := QRY->GM8_CODCRM
   cCodLoc := QRY->GM8_CODLOC
   cCodDis := QRY->GM8_CODDIS                                                                                                        	
 
                    										//           1	        2         3									4									5									6									7									8									9									0         1         2         3
                     									//"0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12
   @nLin++, 000 PSAY STR0009 //"Hora  Paciente                    Endere็o             Telefone      Plano                          Procedimento"
   @nLin++, 000 PSAY "----- --------------------------- -------------------- ------------- ------------------------------ ------------------------------"
  EndIf
  
  @nLin, 034 PSAY SUBSTR(QRY->GSD_DESEND, 1, 20) /* Endereco */
  
  If cHorAge <> QRY->GM8_HORAGE .Or. cRegGer <> QRY->GM8_REGGER
   @nLin, 000 PSAY QRY->GM8_HORAGE
   @nLin, 006 PSAY QRY->GM8_REGGER + "-" + SUBSTR(QRY->GBH_NOME,1,20)
			@nLin, 055 PSAY QRY->GBH_TEL 
   @nLin, 069 PSAY QRY->GCM_DESPLA 
   @nLin, 100 PSAY QRY->GM8_CODPRO + "-" + SUBSTR(QRY->GA7_DESC,1,20)
   cRegGer	:= QRY->GM8_REGGER
   cHorAge	:= QRY->GM8_HORAGE
  EndIf 
  
  nTotAge ++
  nLin += 2
  
  DbSkip()
 End    
 
 @nLin, 000 PSAY STR0014 + TRANSFORM(nTotAge, "@E 999,999") //"Total Agenda...: "

 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
 DBCloseArea()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec1 := STR0010 + DTOC(STOD(QRY->GM8_DATAGE)) + " - " + DiaSemana(STOD(QRY->GM8_DATAGE), 11)    //"Data de Agend.:"
 Cabec2 := STR0011 + SUBSTR(QRY->RA_NOME, 1, 30) + STR0012 + SUBSTR(QRY->GCS_NOMLOC, 1, 30)	+ STR0013 + SUBSTR(QRY->GM6_DESDIS, 1, 40) //"M้dico........:"###" Setor.:"###" Disp..:"
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 8
Return()