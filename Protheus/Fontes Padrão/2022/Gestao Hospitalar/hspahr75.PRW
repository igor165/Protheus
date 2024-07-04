#INCLUDE "HSPAHR75.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR75 บ       ณ Antonio Carlos     บ Data ณ 25/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA AMBULATORIAL COMPLEMENTAR              บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR75()

Local oReport
If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPR75",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE
	HSPAHR75R3()
EndIF
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 25/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2, oSection3, oSection4, oSection5, oSection6, oSection7
Local oCell
Local oTotaliz1
Local oBreak1

oReport := TReport():New("HSPAHR75",HS_MontCabe(STR0011, MV_PAR05, MV_PAR06),"HSPR75",{|oReport| R75IMP(oReport)},STR0001 + " " + STR0002)  
 //"Agenda Complementar"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1:= TRSection():New(oReport,STR0018,{"GM8"})  //"Data de Agendamento"
oSection1:SetTotalText(STR0012)    //" Total   : "
oSection1:SetHeaderBreak(.T.)      //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oSection1:SetPageBreak(.T.)
oCell := TRCell():New(oSection1,"GM8_DATAGE","GM8",STR0019,,20,,) //"Data de Agend.:"
oCell := TRCell():New(oSection1,"cDATAGE","GM8","",,20,,{||cDATAGE:=HS_SEMANA(DOW(QRYR75->GM8_DATAGE))})

oSection2:= TRSection():New(oSection1,STR0008,{"SRA"}) //"M้dico.:"
oSection2:SetHeaderBreak(.T.)
oSection2:SetPageBreak(.F.) 
oCell := TRCell():New(oSection2,"RA_NOME","SRA",STR0008,,20,,)      //"M้dico: "

oSection3:= TRSection():New(oSection2,STR0009,{"GCS"})   //"Local : "
oSection3:SetHeaderBreak(.T.)
oSection3:SetPageBreak(.F.)
oCell := TRCell():New(oSection3,"GCS_NOMLOC","GCS",STR0009,,35)   //"Local : "              

oSection4:= TRSection():New(oSection3,STR0015,{"GM6"})  //"    Disponibilidade "
oSection4:SetHeaderBreak(.T.)
oSection4:SetPageBreak(.F.)
oCell := TRCell():New(oSection4,"GM6_DESDIS","GM6",STR0020,,35)                  //"Disp..:"

oSection5:= TRSection():New(oSection4,STR0031,{"GM8"})       //"Agenda"
oSection5:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oSection5:SetPageBreak(.F.)
oSection5:SetHeaderSection(.T.)  //Define se cabecalho da celula sera impresso na quebra da secao.
oSection5:SetHeaderPage(.T.)
oCell := TRCell():New(oSection5,"GM8_HORAGE","GM8",STR0021) //"Hora"
oCell := TRCell():New(oSection5,"cTIPAGE"   ,"GM8","",,3,,{||cTIPAGE:=IIF(QRYR75->GM8_TIPAGE  == "1",STR0022,"")}) //"E"
oCell := TRCell():New(oSection5,"          ","   "," ",,5)  
oCell := TRCell():New(oSection5,"GM8_NOMPAC","GM8",STR0023)   //"Nome"
oCell := TRCell():New(oSection5,"GM8_TELPAC","GM8",STR0024,,30) //"Telefone"
oCell := TRCell():New(oSection5,"GM8_REGGER","GM8",)
oCell := TRCell():New(oSection5,"GM8_DATCAD","GM8",STR0029,,10)  //"Marcado em"
oCell := TRCell():New(oSection5,"GM8_HORCAD","GM8",)

oSection6:=TRSection():New(oSection5,STR0032,{"GCM","GA7","GM8"})       //"Descri็ใo Conv๋nio"
oSection6:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oSection6:SetPageBreak(.F.)
oSection6:SetHeaderSection(.T.)  //Define se cabecalho da celula sera impresso na quebra da secao.
oSection6:SetHeaderPage(.T.)
oSection6:lReadOnly := .T.
oCell := TRCell():New(oSection6,"       ","   "," ",,17)  
oCell := TRCell():New(oSection6,"cDESC  ","GA7",STR0025,,45,,{||cDESC:=IIF(!Empty(QRYR75->GM8_CODPRO),QRYR75->GA7_DESC,"")}) //"Procedimento"
oCell := TRCell():New(oSection6,"cDESPLA","GCM",STR0026,,40,,{||cDESPLA:=IIF(!Empty(QRYR75->GM8_CODPLA),QRYR75->GCM_DESPLA,"")}) //"Plano"
oCell := TRCell():New(oSection6,"  ","  ",STR0027,,20,,{||IIF(Empty(QRYR75->GM8_CODAGE),STR0018,STR0028)}) //"1a. Vez"###"Sim"###"Nใo"
oCell := TRCell():New(oSection6,"GM8_CODUSU","GM8",STR0030)  //"Por"

oSection7:=TRSection():New(oSection6,STR0014,{"GM8"})   //"   Observacao"   
oSection7:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oSection7:SetPageBreak(.F.)
oSection7:SetHeaderSection(.T.)  //Define se cabecalho da celula sera impresso na quebra da secao.
oSection7:SetHeaderPage(.T.)
oSection7:lReadOnly := .T.
oCell := TRCell():New(oSection7,"          ","   "," ",,17)  
oCell := TRCell():New(oSection7,"cMemo","GM8",STR0014,,,,{||	cMemo := HS_IniPadr("GM8", 1, QRYR75->GM8_CODAGE, "GM8_OBSERV",, .F.)})   //" Observacao"

oSection1:SetTotalInLine(.T.)

DEFINE FUNCTION FROM oSection5:Cell("GM8_NOMPAC") OF oSection1 FUNCTION COUNT TITLE " ===> " NO END REPORT 

Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R75Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 25/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R75IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)
Local oSection6 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)
Local oSection7 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)
Local	cCond := "%%"

MakeSqlExpr(oReport:uParam)

If !EMPTY(MV_PAR07)  //data digitacao
 If EMPTY(MV_PAR08) //hr digitacao
	 cCond := "% GM8.GM8_DATCAD >= '" + DTOS(MV_PAR07) + "' %"
 Else 
  cCond := "% ((GM8.GM8_DATCAD = '" + DTOS(MV_PAR07) + "' AND GM8.GM8_HORCAD >= '" + MV_PAR08 + ;
           "') OR GM8.GM8_DATCAD > '" + DTOS(MV_PAR07) + "') %"
 EndIf
Else
  cCond := "% ((GM8.GM8_DATCAD = '" + DTOS(MV_PAR07) + "' AND GM8.GM8_HORCAD >= '" + MV_PAR08 + ;
           "') OR GM8.GM8_DATCAD > '" + DTOS(MV_PAR07) + "') %"  
EndIf 

oSection1:BeginQuery()
BeginSql alias "QRYR75"
 SELECT GM8_FILAGE, GM8_CODCRM, GM8_REGGER, GM8_NOMPAC, GM8_CODPLA, GM8_DATAGE, GCM_DESPLA, GM8_TIPAGE,
        GM8_TELPAC, GM8_HORAGE, GM8_CODPRO, GA7_DESC, GM8_DATCAD, GM8_HORCAD, GM8_CODUSU, GCS_NOMLOC, GM8_CODDIS,
        GM6_DESDIS, GM8_CODAGE, RA_NOME  
      FROM %table:GM8% GM8 
      JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GM8.GM8_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%notDel%
      JOIN %table:GM6% GM6 ON GM6.GM6_CODDIS = GM8.GM8_CODDIS AND GM6.GM6_FILIAL = %xFilial:GM6% AND GM6.%notDel%
      JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GM8.GM8_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%notDel%
 LEFT JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GM8.GM8_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%notDel%
 LEFT JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GM8.GM8_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%notDel%
 WHERE GM8.GM8_FILIAL = %xFilial:GM8% AND GM8.%notDel%
   AND GM8.GM8_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND GM8.GM8_CODLOC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
   AND GM8.GM8_DATAGE BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%
   AND GM8.GM8_CODCRM BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
   AND GM8.GM8_STATUS = %Exp:'1'% 
   OR  GM8.GM8_STATUS = %Exp:'5'%
   AND GA7.GA7_CODESP BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR12%
   AND %Exp:cCond%
 ORDER BY GM8_FILAGE, GM8_CODDIS, GM8_DATAGE, GM8_HORAGE , GM8_CODPRO  
EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYR75")->GM8_DATAGE == G }, {|| ("QRYR75")->GM8_DATAGE})
	oSection3:SetParentQuery()                                                                                                                                                                                             
 oSection3:SetParentFilter( {|H| ("QRYR75")->RA_NOME    + DTOC(("QRYR75")->GM8_DATAGE) == H },                                                                                                                                   {|| ("QRYR75")->RA_NOME    +  DTOC(("QRYR75")->GM8_DATAGE)})
	oSection4:SetParentQuery()                                                                                                                                                                                                                               
 oSection4:SetParentFilter( {|I| ("QRYR75")->GCS_NOMLOC +      ("QRYR75")->RA_NOME    + DTOC(("QRYR75")->GM8_DATAGE) == I },                                                                                                    {|| ("QRYR75")->GCS_NOMLOC +        ("QRYR75")->RA_NOME     + DTOC(("QRYR75")->GM8_DATAGE)})
	oSection5:SetParentQuery()
 oSection5:SetParentFilter( {|J| ("QRYR75")->GM6_DESDIS +      ("QRYR75")->GCS_NOMLOC +      ("QRYR75")->RA_NOME    + DTOC(("QRYR75")->GM8_DATAGE) == J },                                                                      {|| ("QRYR75")->GM6_DESDIS +       ("QRYR75")->GCS_NOMLOC  +       ("QRYR75")->RA_NOME    + DTOC(("QRYR75")->GM8_DATAGE)})
	oSection6:SetParentQuery()
 oSection6:SetParentFilter( {|K| ("QRYR75")->GM8_HORAGE +      ("QRYR75")->GM6_DESDIS +      ("QRYR75")->GCS_NOMLOC +      ("QRYR75")->RA_NOME    + DTOC(("QRYR75")->GM8_DATAGE) == K },                                       {|| ("QRYR75")->GM8_HORAGE +        ("QRYR75")->GM6_DESDIS  +      ("QRYR75")->GCS_NOMLOC +       ("QRYR75")->RA_NOME    + DTOC(("QRYR75")->GM8_DATAGE)})
	oSection7:SetParentQuery()
 oSection7:SetParentFilter( {|L| ("QRYR75")->GA7_DESC   +      ("QRYR75")->GM8_HORAGE +      ("QRYR75")->GM6_DESDIS +      ("QRYR75")->GCS_NOMLOC +      ("QRYR75")->RA_NOME          +  DTOC(("QRYR75")->GM8_DATAGE) == L }, {|| ("QRYR75")->GA7_DESC    +        ("QRYR75")->GM8_HORAGE  +      ("QRYR75")->GM6_DESDIS +       ("QRYR75")->GCS_NOMLOC +      ("QRYR75")->RA_NOME     + DTOC(("QRYR75")->GM8_DATAGE)}) 

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYR75->(LastRec()))
                   
Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR75R3บ Autor ณ GILSON DA SILVA    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA AMBULATORIAL                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR75R3()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Locais                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2 := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3 := ""
Local Titulo := STR0003 //"Agenda Ambulatorial."
Local Cabec1 := ""
Local Cabec2 := ""
Local Cabec3 := ""
Local aOrd   := {}
Local aArea  := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Privadas                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "HSPAHR75"
Private nTipo       := 15
Private aReturn     := {STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administra็ใo"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private m_pag       := 01
Private wnrel       := "HSPAHR75"
Private cString     := ""
Private aRegistros  := {}
Private nLin        := 80
Private cCodImp := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

cPerg := "HSPR75"
If FunName() <> "HSPAHM29"
	If !Pergunte(cPerg, .T.)
		Return()
	EndIf
Else
	MV_PAR01 := "01"
	MV_PAR02 := "01" 
 MV_PAR03 := M->GM8_DATAGE
	MV_PAR04 := M->GM8_DATAGE	
	MV_PAR05 := M->GM8_DATAGE
	MV_PAR06 := M->GM8_DATAGE
	MV_PAR07 := M->GM8_DATCAD
 MV_PAR09 := M->GM8_CODCRM
 MV_PAR10 := M->GM8_CODCRM
	MV_PAR11 := ""
 MV_PAR12 := "ZZ"
EndIf

nMaxLin := HS_MaxLin(cCodImp)
nLin := nMaxLin * 2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)
If nLastKey == 27
	Return()
EndIf

SetDefault(aReturn, cString)
If nLastKey == 27
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1, Cabec2, Cabec3, Titulo)}, Titulo)

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

Static Function RunReport(Cabec1, Cabec2, Cabec3, Titulo)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variแveis locais.                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cGM8_DATAGE := ""
Local cGM8_CODDIS := ""
Local nCont       := 0
Local nLinTotal   := 0
Local l1Vez       := .F.
Local cSQL 	      := ""
Local cMemo	      := ""

Private nTotal    := 0

Titulo := HS_MontCabe(STR0011, IIF(Empty(MV_PAR05), " ", CTOD(HS_DTOC(MV_PAR05, 1))), IIF(Empty(MV_PAR06), " ", CTOD(HS_DTOC(MV_PAR06, 1)))) //"Agenda Complementar"

cSQL := "SELECT GM8.GM8_FILAGE, GM8.GM8_CODCRM, GM8.GM8_REGGER, GM8.GM8_NOMPAC, GM8.GM8_CODPLA, GM8.GM8_DATAGE, "
cSQL += " GCM.GCM_DESPLA, GM8.GM8_TIPAGE, GM8.GM8_TELPAC, GM8.GM8_HORAGE, GM8.GM8_CODPRO, GA7.GA7_DESC , GM8.GM8_DATCAD, "
cSQL += " GM8.GM8_HORCAD, GM8.GM8_CODUSU, GCS.GCS_NOMLOC, GM8.GM8_CODDIS, GM6.GM6_DESDIS, GM8_CODAGE, SRA.RA_NOME  "
cSQL += " FROM " + RetSQLName("GM8") + " GM8"
cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GM8.GM8_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GM6") + " GM6 ON GM6.GM6_CODDIS = GM8.GM8_CODDIS AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GM8.GM8_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GM8.GM8_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*'"
cSQL += " LEFT JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GM8.GM8_CODPRO AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*'"
cSQL += " WHERE "
cSQL += " GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
cSQL += " AND GM8.GM8_FILAGE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cSQL += " AND GM8.GM8_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cSQL += " AND GM8.GM8_DATAGE BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
cSQL += " AND GM8.GM8_CODCRM BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " AND GM8.GM8_STATUS = '1' OR GM8.GM8_STATUS = '5' "
cSQL += " AND GA7.GA7_CODESP  BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
If !EMPTY(MV_PAR07)  //data digitacao
	If EMPTY(MV_PAR08) //hr digitacao
		cSQL += " AND GM8.GM8_DATCAD >= '" + DTOS(MV_PAR07) + "' "
	Else
		cSQL += " AND ((GM8.GM8_DATCAD = '" + DTOS(MV_PAR07) + "' AND GM8.GM8_HORCAD >= '" + MV_PAR08 + "') "
		cSQL += "      OR GM8.GM8_DATCAD > '" + DTOS(MV_PAR07) + "') "
	EndIf
EndIf

cSQL += " ORDER BY GM8_FILAGE, GM8_CODDIS, GM8_DATAGE, GM8_HORAGE , GM8_CODPRO"

TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()

If Eof()
	MsgStop(STR0017) //"Nenhum dado foi encontrado para a sele็ใo efetuada!"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetRegua(100)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega o vetor aRegistros com todos os dados a serem impressos.    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !EOF()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	Cabec1 := STR0008 + AllTrim(QRY->GM8_CODCRM) + "-" + QRY->RA_NOME + Space(10) // "M้dico: "
	Cabec2 := STR0009 + QRY->GCS_NOMLOC + STR0015 + QRY->GM6_DESDIS // "Local : "###"     Disponibilidade: "
	Cabec3 := STR0010 + DTOC(STOD(QRY->GM8_DATAGE)) + " - " + HS_SEMANA(DOW(STOD(QRY->GM8_DATAGE))) //"Data: "
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		ImpCabec(Cabec1, Cabec2, Cabec3, Titulo)
	EndIf
	
	If cGM8_CODDIS <> QRY->GM8_CODDIS .And. !Empty(cGM8_CODDIS) //Quebra Por Disponibilidade
		@nLin, 000 PSAY STR0012 + Transform(nToTal, "@E 999,999")//"Total     : "
		nLin++
		@nLin, 000 PSAY Repl("-",132)
		nTotal := 0
		ImpCabec(Cabec1, Cabec2, Cabec3, Titulo)
		cGM8_CODDIS := QRY->GM8_CODDIS
		cGm8_DATAGE := QRY->GM8_DATAGE
	EndIf
	
	If cGM8_DATAGE <> QRY->GM8_DATAGE .And. !Empty(cGM8_DATAGE)//Quebra por Data
		nLin++
		@nLin, 000 PSAY STR0012 + Transform(nToTal, "@E 999,999")//"Total     : "
		nLin++
		nTotal := 0
		ImpCab1(HS_DTOC(STOD(QRY->GM8_DATAGE)) + " - " + HS_SEMANA(DOW(STOD(QRY->GM8_DATAGE))) )
		cGm8_DATAGE := QRY->GM8_DATAGE
	EndIf
	
	cGM8_CODDIS := QRY->GM8_CODDIS
	cGm8_DATAGE := QRY->GM8_DATAGE
	
	@nLin, 000 PSAY QRY->GM8_HORAGE //Horario do agendamento
	
	If QRY->GM8_TIPAGE  == "1"
		@nLin, 006 PSAY "E"  //Indica que eh um Encaixe.
	EndIf
	
	@nLin, 010 PSAY QRY->GM8_NOMPAC  //Nome do Paciente
	
	@nLin, 064 PSAY QRY->GM8_TELPAC  //Telefone do Paciente
	
	l1Vez := .F.
	
	If !Empty( QRY->GM8_REGGER )
		@nLin, 099 PSAY PADL(ALLTRIM(QRY->GM8_REGGER), 6) // Prontuario do Paciente
		l1Vez := .F.
	Else
		l1Vez := .T.
	EndIf
	
	@nLin, 117 PSAY QRY->GM8_DATCAD + " " + QRY->GM8_HORCAD 	
	
	nLin++
	
	If Empty(QRY->GM8_CODAGE)
		l1Vez := .T.
	EndIf
	
	If !Empty(QRY->GM8_CODPRO) .Or. !Empty(QRY->GM8_CODPLA) .Or. l1Vez .Or. QRY->GM8_CODUSU
		If !Empty(QRY->GM8_CODPRO)
			@nLin, 010 PSAY QRY->GA7_DESC  // Descricao do procedimento
		EndIf
		If !Empty(QRY->GM8_CODPLA)
			@nLin, 064 PSAY QRY->GCM_DESPLA // Descricao do Plano
		EndIf
		If l1Vez
			@nLin, 101 PSAY STR0016 //"Sim"
		EndIf
		If !Empty(QRY->GM8_CODUSU)
			@nLin, 117 PSAY QRY->GM8_CODUSU	
		EndIf
		nLin++
	EndIf
	
	cMemo     := HS_IniPadr("GM8", 1, QRY->GM8_CODAGE, "GM8_OBSERV",, .F.) // GM8/1
	nLinTotal := MlCount(cMemo)   //Imprime o campo MEMO GM8_OBSERV.
	nLin++
	@ nLin, 010 PSAY "OBS: "
	For nCont := 1 To nLinTotal
		@ nLin, 015 PSAY MemoLine(cMemo, 65 , nCont)
		nLin++
		If nLin >= nMaxLin
			ImpCabec(Cabec1, Cabec2, Cabec3, Titulo)
		EndIf
	Next nCont
	nLin++
	@nLin, 000 PSAY Repl("-", 132)
	nLin += 2
	nTotal++
	
	DbSkip()
	
	If EOF()
		@nLin, 000 PSAY STR0012 + Transform(nToTal, "@E 999,999")//"Total     : "
		nLin++
		@nLin, 000 PSAY Repl("-", 132)
		nTotal := 0
	EndIf
	
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5] == 1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()
DbCloseArea()

Return()

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

Static Function ImpCabec(Cabec1, Cabec2, Cabec3, Titulo)

			/*         1         2         3         4         5         6         7         8         9         10        11        12        13
				0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 */

Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
nLin := 09

@nLin, 000 PSAY  STR0006  //"Hora      Nome                                                  Telefone                       Prontuแrio            Marcado em"
nLin++
@nLin, 000 PSAY  STR0013  //"          Procedimento                                          Plano                               1aVez            Por"
nLin++
@nLin, 000 PSAY  STR0014  //"          Observa็ใo"
nLin++
@nLin, 000 PSAY  Repl("-", 132)
nLin++
If nTotal = 0
	@nLin, 000  PSAY  Cabec3 //"Data :"
	nLIn += 2
EndIf
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณIMPCAB1   บ Autor ณ Gilson da Silva    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Quebra por Data.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ImpCab1(cData)

@nLin, 000 PSAY Repl("-", 132)
@nLin++
@nLin, 000 PSAY STR0010 + cData  //"Data: "
nLin := nLin + 2
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_VlHor  บ Autor ณ Gilson da Silva    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao utilizada para validar a hora informada no parame_  บฑฑ
ฑฑบ          ณ tro MV_PAR08.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
//Funcao utilizada no Valid do campo MV_PAR08    
Function FS_VlHor(cHora) 

Local lRet := .T.

If cHora == "  :  "
	Return(lRet)
ElseIf !(SubStr(cHora, 4, 2) >= "00" .And. SubStr(cHora, 4, 2) <= "59")
	lRet := .F.
ElseIf !(SubStr(cHora, 1, 2) >= "00" .And. SubStr(cHora, 1, 2) <= "23")
	lRet := .F.
EndIf

Return(lRet)
