#INCLUDE "HSPAHR23.ch"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR23  บ Autor ณ Bruno S. P. Santos           28/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio dos materiais e medicamentos nใo atualizados     บฑฑ
ฑฑบ          ณ durante a importa็ใo da lista de pre็o                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR23()

 Local oReport
  If FindFunction("TRepInUse") .And. TRepInUse() 
  	Pergunte("HSPR23",.F.)
   oReport := ReportDef() 
   oReport:PrintDialog()  
  Else  
   HSPAHR23R3()  
  EndIF    
Return( Nil )     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Bruno S. P. Santos    ณ Data ณ 28/05/07 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell

 oReport := TReport():New("HSPAHR23",STR0003 +" - "+STR0020,"HSPR23",{|oReport| R23IMP(oReport)}, STR0001 +" "+STR0002) 
 
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0004,{"GCA"}) 
 
 oCell := TRCell():New(oSection1,"GCA_CODTAB","GCA",STR0004) 
 oCell := TRCell():New(oSection1,"GCA_DESCRI","GCA",STR0007,,60)     
 oCell := TRCell():New(oSection1,"GCA_DATGER","GCA",STR0013,,10)     
 oCell := TRCell():New(oSection1,"cDataRef","",STR0021,,10,,{|| MV_PAR02})   
 
 oSection2 := TRSection():New(oSection1,STR0005,{"GCB","QRYR23"})//Produtos
 oCell := TRCell():New(oSection2,"GCB_CODPRO","GCB", STR0006) //"C๓digo Produto"
 oCell := TRCell():New(oSection2,"B1_DESC"   ,"GCB", STR0007,,30) //"Descri็ใo."
  
 oCell := TRCell():New(oSection2,"GCB_PRCVEN","GCB", STR0014)
 oCell := TRCell():New(oSection2,"GCB_PRCVUC","GCB", STR0015)
 oCell := TRCell():New(oSection2,"GCB_DATVIG","GCB", STR0016)
 oCell := TRCell():New(oSection2,"GCB_ORIGEM","GCB", STR0017,,10,, {|| IIF(("QRYR23")->GCB_ORIGEM == '0' ,STR0018,STR0019) })//"Importado"###"Digitado"
                                                                                                           
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณR23Imp    ณ Autor ณ Bruno S. P. Santos    ณ Data ณ 28/05/07 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R23IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      

 oSection1:BeginQuery()

 BeginSql alias "QRYR23"     
  
  SELECT GCA.GCA_CODTAB, GCA.GCA_DESCRI, GCA.GCA_DATGER, SB1.B1_DESC, GCB.GCB_PRODUT, 
         GCB.GCB_PRCVEN, GCB.GCB_PRCVUC, GCB.GCB_DATVIG, GCB.GCB_ORIGEM, GCB.GCB_CODPRO
    FROM %table:GCA%  GCA 
    JOIN %table:GCB%  GCB ON GCB.GCB_FILIAL = %xFilial:GCB%  AND GCB.%NotDel%   
     AND GCB.GCB_CODTAB = GCA.GCA_CODTAB 
    JOIN %table:SB1% SB1 ON SB1.B1_COD = GCB.GCB_PRODUT AND SB1.B1_FILIAL =  %xFilial:SB1%  AND SB1.%NotDel%  
   WHERE GCA_CODTAB = %Exp:MV_PAR01% AND GCA.GCA_FILIAL = %xFilial:GCA% AND GCA.%NotDel%
				     AND GCB.GCB_DATVIG = (SELECT MAX(GCB_DATVIG) 
				                             FROM %table:GCB% GCB2 
				                            WHERE GCB2.GCB_FILIAL = GCB.GCB_FILIAL 
				                              AND GCB2.GCB_PRODUT = GCB.GCB_PRODUT
				                              AND GCB2.%NotDel%
				                              AND GCB2.GCB_DATVIG < %Exp:DTOS(MV_PAR02)%)	
				     AND NOT EXISTS (SELECT 'X' 
				                       FROM  %table:GCB% GCB3 
				                      WHERE GCB3.GCB_FILIAL = GCB.GCB_FILIAL AND GCB3.GCB_PRODUT = GCB.GCB_PRODUT 
				                        AND GCB3.%NotDel%
				                        AND GCB3.GCB_CODTAB = GCB.GCB_CODTAB
				                        AND GCB3.GCB_DATVIG = %Exp:DTOS(MV_PAR02)%)  
 EndSql

 oSection1:EndQuery()
 oSection2:SetParentQuery() 
 oSection2:SetParentFilter( {|G| ("QRYR23")->GCA_CODTAB  == G }, {|| ("QRYR23")->GCA_CODTAB})

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYR23->(LastRec()))
 
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR23R3บ Autor ณ Bruno S. P. Santos บ Data ณ  28/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de atendimentos por usuario                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR23R3()
 Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3        := STR0003 
 Local aOrd          := {}

 Private Titulo      := ""
 
 Private Cabec       := PADR(STR0006,21)+" "+PADR(STR0007,39)+" "+PADR(STR0014,18)+" "+PADR(STR0015,18)+" "+PADR(STR0016,18)+STR0017
 Private Cabec2      := ""
 
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR23"
 Private nTipo       := 18
 Private aReturn     := {STR0008, 1, STR0009, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 80
  
 Private cCodTab := "", cCodPro := ""
 Private dDatRef 

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	C๓digo da Tabela                                        ณ
 //ณ MV_PAR02	Data de Refer๊ncia(Importa็ใo)                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPR23",.T.)
  Return()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 
 cCodTab  := mv_par01
 dDatRef  := mv_par02
 
 Titulo := STR0003+" - "+STR0020 
 //Cabec2  := STR0020
 
 wnrel := SetPrint("GCA", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 
 SetDefault(aReturn, "GCA")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport() }, Titulo)
 
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
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR23 บ Autor ณ Bruno S. P. Santos บ Data ณ  28/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Execucao do relatorio                                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local cSql     := "" 
 Private nLin    := nMaxLin * 2
 
 cSQL := " 	 SELECT GCA.GCA_CODTAB, GCA.GCA_DESCRI, GCA.GCA_DATGER, SB1.B1_DESC, GCB.GCB_PRODUT, "
 cSQL += "          GCB.GCB_PRCVEN, GCB.GCB_PRCVUC, GCB.GCB_DATVIG, GCB.GCB_ORIGEM, GCB.GCB_CODPRO "
	cSQL += "    FROM " + RetSQLName("GCA") + " GCA "
 cSQL += "    JOIN " + RetSQLName("GCB") + " GCB ON GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*' "
 cSQL += "     AND GCB.GCB_CODTAB = GCA.GCA_CODTAB "
 cSQL += "    JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GCB.GCB_PRODUT AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
 cSQL += "     AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += "   WHERE GCA_CODTAB = '"+cCodTab+"' AND GCA.GCA_FILIAL = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' "
 cSQL += "         AND GCB_DATVIG = (SELECT MAX(GCB_DATVIG) "
	cSQL += "                         FROM " + RetSQLName("GCB") + " GCB2 "
	cSQL += "                         WHERE GCB2.GCB_FILIAL = GCB.GCB_FILIAL "
	cSQL += "                            AND GCB2.GCB_PRODUT = GCB.GCB_PRODUT "
	cSQL += "                            AND GCB2.D_E_L_E_T_ <> '*' "
 cSQL += "                            AND GCB2.GCB_DATVIG < '" + DTOS(dDatRef) + "')	"
 cSQL += "        AND NOT EXISTS (SELECT 'X' "
 cSQL += "                       FROM " + RetSQLName("GCB") + " GCB3 "
 cSQL += "                       WHERE GCB3.GCB_FILIAL = GCB.GCB_FILIAL AND GCB3.GCB_PRODUT = GCB.GCB_PRODUT "
 cSQL += "                           AND GCB3.D_E_L_E_T_ <> '*' "
 cSQL += "                           AND GCB3.GCB_CODTAB = GCB.GCB_CODTAB"
 cSQL += "                           AND GCB3.GCB_DATVIG = '" + DTOS(dDatRef) + "')  "

 cSQL := ChangeQuery(cSQL)    
 
 TCQUERY cSQL NEW ALIAS "QRY"

 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0010, STR0011, STR0012) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Verifique a sele็ใo"
  DbCloseArea()
  Return(nil)
 Endif 
 
 FS_CABEC()
 cCodTab := ""            
 While !Eof()
  If cCodTab # QRY->GCA_CODTAB                                           
   cCodTab := QRY->GCA_CODTAB
   
   nLin++
   @nLin,000 PSAY STR0004 + " : "
   @nLin,018 PSAY QRY->GCA_CODTAB+" - "+QRY->GCA_DESCRI 
   
   nLin++
   @nLin,000 PSAY STR0013 + " : "
   @nLin,018 PSAY STOD(QRY->GCA_DATGER)
   
   nLin++
   @nLin,000 PSAY STR0021 + " : "
   @nLin,018 PSAY dDatRef
   
   nLin++
   @nLin,000 PSAY Replicate("-",limite)  

  EndIf
  nLin++      
   
  @nLin,000 PSAY QRY->GCB_CODPRO       
  @nLin,022 PSAY QRY->B1_DESC      
  @nLin,060 PSAY Transform(QRY->GCB_PRCVEN,"@E 999,999.99") //Transform(FS_DescGBC(("QRY")->GCA_CODTAB,("QRY")->GCB_CODPRO,"GCB_PRCVEN"),"@E 999,999.99") 
  @nLin,080 PSAY Transform(QRY->GCB_PRCVUC,"@E 999,999.99") //Transform(FS_DescGBC(("QRY")->GCA_CODTAB,("QRY")->GCB_CODPRO,"GCB_PRCVUC"),"@E 999,999.99") 
  @nLin,103 PSAY STOD(QRY->GCB_DATVIG)//FS_DescGBC(("QRY")->GCA_CODTAB,("QRY")->GCB_CODPRO,"GCB_DATVIG")
  @nLin,120 PSAY IIF(QRY->GCB_ORIGEM == '0' ,STR0018,STR0019)//IIF(FS_DescGBC(("QRY")->GCA_CODTAB,("QRY")->GCB_CODPRO,"GCB_ORIGEM")== '0' ,STR0018,STR0019)
         
 If nLin+1 > nMaxLin
  FS_Cabec()
 Endif   
  
 DbSkip()
End 
DbCloseArea()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Bruno S. P. Santos บ Data ณ  28/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 7
Return()