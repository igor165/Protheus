#INCLUDE "HSPAHRAC.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRAC  บ Autor ณ ANTONIO CARLOS     บ Data ณ  21/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Posicao de Estoque por Fแrmaco Analํtico      บฑฑ 
ฑฑบAlteracao:ณ Acrescentar Unidade de Medida e fazer ณ Data ณ  27/07/06   บฑฑ
ฑฑบ          ณ uma Quebra e totalizacao pela UM                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHRAC()
 Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRAC",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHRACR3()  
 EndIF
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 21/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3
 Local oCell
 Local oTotaliz1, oTotaliz2

 oReport := TReport():New("HSPAHRAC",STR0001,"HSPRAC",{|oReport| RACIMP(oReport)}, STR0004 + " " + STR0005 + " " + STR0001)

//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0018,{"GBI","GA0"})                 //"Fแrmaco"
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetHeaderPage(.T.)
 oCell := TRCell():New(oSection1,"GBI_FARMAC","GBI",STR0018)                   //"Fแrmaco"
 oCell := TRCell():New(oSection1,"GA0_DESC","GA0","Descricao ")

 oSection2 := TRSection():New(oSection1,STR0017,{"SB1"})                        //"Produto"
 oSection2:SetReadOnly(.F.)
 oSection2:Hide()
 oCell := TRCell():New(oSection2,"B1_UM","SB1",)     

 oSection3 := TRSection():New(oSection2,STR0029,{"SB1","SB2","SA2"})   //"Dados Adicionais dos Produtos"
 oSection3:SetHeaderBreak(.F.)
 oSection3:SetHeaderPage(.T.)
 oCell := TRCell():New(oSection3,"B1_COD","SB1",STR0017)                        //"Cod. Produto"
 oCell := TRCell():New(oSection3,"B1_DESC","SB1","Descricao")                           //"Descricao" 
 oCell := TRCell():New(oSection3,"B1_UM","SB1",STR0027)                         //"Und Medida"
 oCell := TRCell():New(oSection3,"B2_LOCAL","SB2",STR0019)                      //"Armaz."
 oCell := TRCell():New(oSection3,"B2_QATU","SB2",STR0020,"999999")              //"Sld Atual"
 oCell := TRCell():New(oSection3,"B2_CM1","SB2",STR0021)                        //"Custo Unit"
 oCell := TRCell():New(oSection3,"B2_VATU1","SB2",STR0022,"99,999,999.99")      //"Sld.Fin.Atu."
 oCell := TRCell():New(oSection3,"B1_UCOM","SB1",STR0023)                       //"Dt.Ult.Compra"
 oCell := TRCell():New(oSection3,"B1_UPRC","SB1",STR0024)                       //"Vl.Ult.Compra"
 oCell := TRCell():New(oSection3,"cFornece","  ",STR0025,,,,{||FS_Fornec()})   //"Fornecedor"

 oSection3:SetTotalInLine(.F.)
 oSection3:SetTotalText(STR0028)
 oTotaliz1 := TRFunction():new(oSection3:Cell("B2_QATU"),,"SUM",," ==>","999999",,.T.,.T.,.F.,,)
 oTotaliz2 := TRFunction():new(oSection3:Cell("B2_VATU1"),,"SUM",," ==>","99,999,999.99",,.T.,.T.,.F.,,)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RACImp   ณ Autor ณ Antonio Carlos        ณ Data ณ 21/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RACIMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()

 BeginSql alias "QRYRAC"
   SELECT GBI_FARMAC, GBI_TIPO, GBI_GRUFAR, GA0_CODFAR, GA0_DESC, B1_COD, B1_DESC, B1_UM, B1_UCOM, B1_UPRC, B2_COD, B2_LOCAL, B2_QATU, B2_CM1, ;
          B2_VATU1, GAN_DESC 
   FROM %table:GBI% GBI 
   JOIN %table:GA0% GA0 ON GA0.GA0_CODFAR = GBI.GBI_FARMAC AND GA0.GA0_FILIAL = %xFilial:GA0% AND GA0.%notDel% 
   JOIN %table:SB1% SB1 ON SB1.B1_COD     = GBI.GBI_PRODUT AND SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.%notDel%    
   JOIN %table:SB2% SB2 ON SB2.B2_COD     = SB1.B1_COD     AND SB2.B2_FILIAL  = %xFilial:SB2% AND SB2.%notDel%     
   JOIN %table:GAN% GAN ON GAN.GAN_GRUFAR = GBI.GBI_GRUFAR AND GAN.GAN_FILIAL = %xFilial:GAN% AND GAN.%notDel%     
   WHERE GBI.GBI_FILIAL = %xFilial:GBI%  AND GBI.%NotDel% 
   AND GBI.GBI_TIPO     = '1'  
   AND SB2.B2_LOCAL   BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND GBI.GBI_GRUFAR BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%  
   AND GBI.GBI_FARMAC BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
   ORDER BY GBI_FARMAC, B1_COD, B1_UM
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|P| ("QRYRAC")->GBI_FARMAC == P }, {|| ("QRYRAC")->GBI_FARMAC } )  // Quebra por Farmaco
oSection3:SetParentQuery()                                                                      
oSection3:SetParentFilter( {|G| ("QRYRAC")->B1_UM + ("QRYRAC")->GBI_FARMAC == G }, {|| ("QRYRAC")->B1_UM + ("QRYRAC")->GBI_FARMAC} )  // Quebra por UM
oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYRAC->(LastRec()))
                   
Return( NIL )

Function FS_Fornec()
 cFornece := " "
 cUltFornec   := ""
 DbSelectArea("SD1")                
 DbSetOrder(5)  
 If DbSeek(xFilial("SD1") + QRYRAC->B1_COD) 
  While !Eof() .AND. SD1->D1_FILIAL == xFILIAL("SD1") .AND. D1_COD == QRYRAC->B1_COD
   If DTOC(SD1->D1_DTDIGIT) == DTOC(QRYRAC->B1_UCOM)
    If SD1->D1_TIPO == 'N'    
     cUltFornec := SD1->D1_FORNECE 
    EndIf
   EndIf
   DbSkip()
   Loop    
  EndDo
  DbSelectArea("SA2")                
  DbSetOrder(1)  
  If DbSeek(xFilial("SA2") + cUltFornec)   
   cFornece := SA2->A2_NREDUZ
  EndIf
 EndIf  
Return(cFornece)
  

/*                            
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRACR3บ Autor ณ Gilson da Silva    บ Data ณ  25/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Posicao de Estoque por Fแrmaco Analํtico      บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHRACR3()

 Local aOrd   := {}
 Private Titulo := STR0001 //"Posi็ใo de Estoque por Fแrmaco Analํtico"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private NomeProg    := "HSPAHRAC" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0002, 1, STR0003, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
// Private nTam        := 132 
 Private cAlias      := "GD7"
 
 Private cArmaz_De   := "", cArmaz_Ate    := ""             
 Private cGrupo_De   := "", cGrupo_Ate := ""
 Private cFarma_De   := "", cFarma_Ate := ""

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 Private lTamProd := IIf((TamSx3("GBI_PRODUT")[1])<=15, .T., .F.)
 Private limite      := Iif(lTamProd,132,220)
 Private Tamanho     := Iif(lTamProd,"M","G")

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Do Armazem                                                ณ
 //ณ MV_PAR02	Ate Armazem                                               ณ
 //ณ MV_PAR03	Do Grupo Farmaco                                          ณ
 //ณ MV_PAR04	Ate Grupo Farmaco                                         ณ
 //ณ MV_PAR05	Do Farmaco                                                ณ
 //ณ MV_PAR06	Ate o Farmaco                                             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPRAC"
 If !Pergunte(cPerg,.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 cArmaz_De   := mv_par01
 cArmaz_Ate  := mv_par02
 cGrupo_De   := mv_par03
 cGrupo_Ate  := mv_par04
 cFarma_De   := mv_par05
 cFarma_Ate  := mv_par06 

 wnrel := SetPrint(cAlias, NomeProg, cPerg, @Titulo, STR0004, STR0005, STR0001, .T., aOrd, Iif(lTamProd,.T.,.F.), Tamanho, , .T.) //"Este programa tem como objetivo imprimir relatorio "###"de acordo com os parametros informados pelo usuario."###"Posi็ใo de Estoque por Fแrmaco Analํtico"
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, cAlias)
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| FS_RELHRAC() }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_RELHRACบ Autor ณ Gilson da Silva    บ Data ณ  18/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_RELHRAC()
 Local cSql      := ""  
 Local cFornece  := ""
 Local nTotUM    := 0 
 Local nTotVATU1 := 0 
 Private cFarmaco  := ""
 Private nLin      := nMaxLin * 2
 Private aFarmaco  := {}
 Private Cabec1    := STR0018     //"Fแrmaco"
//                                      1         2         3         4         5         6         7         8         9        10         11       12        13
//                            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
 Private Cabec2 := Iif(lTamProd,STR0007,STR0030) //"Produto                                       Armaz. Sld Atual Custo Unit Sld.Fin.Atu. Dt.Ult.Compra  Vl.Ult.Compra  Fornecedor"

 cSQL :=  "SELECT COUNT(GBI.GBI_TIPO) AS SOMA"  
 cSQL += " FROM " + RetSQLName("GBI") + "  GBI "
 cSQL += " JOIN " + RetSQLName("GA0") + " GA0 ON GA0.GA0_CODFAR = GBI.GBI_FARMAC AND GA0.GA0_FILIAL = '" + xFilial("GA0") + "' AND GA0.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GBI.GBI_PRODUT AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SB2") + " SB2 ON SB2.B2_COD     = SB1.B1_COD AND SB2.B2_FILIAL      = '" + xFilial("SB2") + "' AND SB2.D_E_L_E_T_ <> '*'" 
 cSQL += " JOIN " + RetSQLName("GAN") + " GAN ON GAN.GAN_GRUFAR = GBI.GBI_GRUFAR AND GAN.GAN_FILIAL = '" + xFilial("GAN") + "' AND GAN.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE "
 cSQL += "GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND "
 cSQL += "GBI.GBI_TIPO = '1'  AND " 
 cSQL += "SB2.B2_LOCAL BETWEEN   '" + cArmaz_De + "' AND '" + cArmaz_Ate + "' AND "
 cSQL += "GBI.GBI_GRUFAR BETWEEN '" + cGrupo_De + "' AND '" + cGrupo_Ate + "' AND " 
 cSQL += "GBI.GBI_FARMAC BETWEEN '" + cFarma_De + "' AND '" + cFarma_Ate + "' "
 cSQL += "GROUP BY GBI.GBI_FARMAC "
 cSQL += "ORDER BY GBI.GBI_FARMAC "
  
 TCQUERY cSQL NEW ALIAS "QRY"
 nReg := QRY->SOMA      
 SetRegua(nReg)
 dbCloseArea()

 cSQL := "SELECT  "
 cSQL += "GBI.GBI_FARMAC, GBI.GBI_TIPO, GBI.GBI_GRUFAR, GA0.GA0_CODFAR, GA0.GA0_DESC, "
 cSQL += "SB1.B1_COD,  SB1.B1_DESC, SB1.B1_UM, SB1.B1_UCOM, SB1.B1_UPRC, SB2.B2_COD, SB2.B2_LOCAL, "
 cSQL += "SB2.B2_QATU, SB2.B2_CM1,  SB2.B2_VATU1, GAN_DESC "
 cSQL += " FROM " + RetSQLName("GBI") + "  GBI "
 cSQL += " JOIN " + RetSQLName("GA0") + " GA0 ON GA0.GA0_CODFAR = GBI.GBI_FARMAC AND GA0.GA0_FILIAL = '" + xFilial("GA0") + "' AND GA0.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GBI.GBI_PRODUT AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SB2") + " SB2 ON SB2.B2_COD     = SB1.B1_COD     AND SB2.B2_FILIAL  = '" + xFilial("SB2") + "' AND SB2.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GAN") + " GAN ON GAN.GAN_GRUFAR = GBI.GBI_GRUFAR AND GAN.GAN_FILIAL = '" + xFilial("GAN") + "' AND GAN.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE "
 cSQL += "GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND "
 cSQL += "GBI.GBI_TIPO = '1'  AND " 
 cSQL += "SB2.B2_LOCAL   BETWEEN '" + cArmaz_De + "' AND '" + cArmaz_Ate + "' AND "
 cSQL += "GBI.GBI_GRUFAR BETWEEN '" + cGrupo_De + "' AND '" + cGrupo_Ate + "' AND " 
 cSQL += "GBI.GBI_FARMAC BETWEEN '" + cFarma_De + "' AND '" + cFarma_Ate + "' "
 cSQL += "ORDER BY GBI.GBI_FARMAC, SB1.B1_COD, SB1.B1_UM"

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(nReg)
 
 cFarmaco := QRY->GBI_FARMAC
 cUndMed  := QRY->B1_UM
 
 While !EOF()                                                                                
  IncRegua()                     
  
  If lEnd
	 	@PROW()+1,001 PSAY STR0008 //"CANCELADO PELO OPERADOR"
		 Exit
  Endif       

  cFornece := " "
  cUltFornec   := ""
  DbSelectArea("SD1")                
  DbSetOrder(5)  
  If DbSeek(xFilial("SD1") + QRY->B1_COD) 

   While !Eof() .AND. SD1->D1_FILIAL == xFILIAL("SD1") .AND. D1_COD == QRY->B1_COD
    If DTOC(SD1->D1_DTDIGIT) == DTOC(STOD(QRY->B1_UCOM))
     If SD1->D1_TIPO == 'N'    
      cUltFornec := SD1->D1_FORNECE 
     EndIf
    EndIf
    DbSkip()
    Loop    
   EndDo

   DbSelectArea("SA2")                
   DbSetOrder(1)  
   If DbSeek(xFilial("SA2") + cUltFornec)   
    cFornece := SA2->A2_NREDUZ
   EndIf
  EndIf  
  
  If nLin > nMaxLin
   nLin:= Cabec(Titulo,Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
   nLin++  
   If QRY->GBI_FARMAC == cFarmaco
    @nLin, 000 PSAY QRY->GBI_FARMAC + " - " + QRY->GA0_DESC
    nLin++
   Endif
  EndIf

  If QRY->GBI_FARMAC <> cFarmaco .OR. QRY->B1_UM <> cUndMed

   nLin++
   @nLin, 020 PSAY STR0028  //"Total da Unidade Medida:"
   @nLin, Iif(lTamProd,048,063) PSAY cUndMed
   @nLin, Iif(lTamProd,054,69) PSAY Transform(nTotUM, "99,999,999") 
   @nLin, Iif(lTamProd,077,92) PSAY Transform(nTotVATU1, "99,999,999.99") 
   nLin+=2
   cUndMed   := QRY->B1_UM
   nTotUM    := 0
   nTotVATU1 := 0

   If QRY->GBI_FARMAC <> cFarmaco   
    @nLin, 000 PSAY QRY->GBI_FARMAC + " - " + QRY->GA0_DESC
    cFarmaco := QRY->GBI_FARMAC
    nLin++ 
   EndIf

  EndIf
 
  @nLin, 000 PSAY QRY->B1_COD            
  @nLin, Iif(lTamProd,016,031) PSAY SUBSTR(QRY->B1_DESC,1,30)
  @nLin, Iif(lTamProd,048,063) PSAY QRY->B1_UM 
  @nLin, Iif(lTamProd,051,66) PSAY QRY->B2_LOCAL 
  @nLin, Iif(lTamProd,054,69) PSAY Transform(QRY->B2_QATU, "@E 99,999,999") 
  @nLin, Iif(lTamProd,065,80) PSAY Transform(QRY->B2_CM1 , "@E 999,999.99") 
  @nLin, Iif(lTamProd,077,92) PSAY Transform(QRY->B2_VATU1,"@E 99,999,999.99") 
  @nLin, Iif(lTamProd,092,118) PSAY DTOC(STOD(QRY->B1_UCOM))
  @nLin, Iif(lTamProd,102,128) PSAY Transform(QRY->B1_UPRC, "@E 99,999,999.99") 
  @nLin, Iif(lTamProd,117,143) PSAY Substr(cFornece,1,14)
  nLin++

  nTotUM    := nTotUM + QRY->B2_QATU
  nTotVATU1 := nTotVATU1 + QRY->B2_VATU1

	  DbSelectArea("QRY")
  DbSkip()
 EndDo

 nLin++
 @nLin, 020 PSAY STR0028  //"Total da Unidade Medida:"
 @nLin, Iif(lTamProd,048,063) PSAY cUndMed
 @nLin, Iif(lTamProd,054,69) PSAY Transform(nTotUM, "99,999,999") 
 @nLin, Iif(lTamProd,077,92) PSAY Transform(nTotVATU1, "99,999,999.99") 
 nLin++

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
