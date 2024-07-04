#INCLUDE "HSPAHRB9.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRB9  บ Autor ณ ANTONIO CARLOS     บ Data ณ  17/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio REG.de NasciMENTOS                               บฑฑ
ฑฑบ          ณ ATUALIZADO POR DANIEL PEIXOTO                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRB9()

Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRB9",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHRB9R3()  
 EndIF    
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 17/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell

 oReport := TReport():New("HSPAHRB9",STR0003,"HSPRB9",{|oReport| RB9IMP(oReport)}, STR0001 + STR0002 + STR0003) 
 //###"Livro de Registro de Nascimentos"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
 
//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0004,{"GB2","SRA","GCZ","GCM"})
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection1,"GB2_REGATE","GB2",STR0004) //"Atendimento"
 oCell := TRCell():New(oSection1,"GB2_MAE"   ,"GB2",)
 oCell := TRCell():New(oSection1,"cNomeCon"," ",STR0006,,35,,{||FS_NomeCon()})  //"Conv๋nio / Plano"
 oCell := TRCell():New(oSection1,"cTipoParto" ,"GB2",STR0007,,7,,{||cTipoParto:=IIf(GB2->GB2_TIPO=="0",STR0024,STR0025)})  //"Parto"###"CESAREA"###"NORMAL"
 oCell := TRCell():New(oSection1,"cMEDICO"   ,"SRA",STR0008,,TamSX3("RA_NOME")[1],,{||HS_INIPADR("SRA",11, ("GB2")->GB2_CODCRM, "RA_NOME",,.F.)}) //"Obstetra"

 oSection2 := TRSection():New(oSection1,STR0004+"/"+STR0012,{"GB2","GF4"})
 oSection2:SetHeaderPage(.T.)
 oSection2:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection2,"          ","   ",,,12)
 oCell := TRCell():New(oSection2,"GB2_DTNASC","GB2",)
 oCell := TRCell():New(oSection2,"GB2_HORNAS","GB2",)
 oCell := TRCell():New(oSection2,"GB2_SEXO"  ,"GB2",) //0-"M"asculino 1-"F"eminino
 oCell := TRCell():New(oSection2,"cTIPALTA","GF4",STR0012,,TamSX3("GF4_DSTPAL")[1],,{|| HS_INIPADR("GF4", 1, ("GB2")->GB2_TPALTA, "GF4_DSTPAL",,.F.)}) //"Tipo Alta"
 oCell := TRCell():New(oSection2,"GB2_ALTURA","GB2",STR0013) //"Estatura"
 oCell := TRCell():New(oSection2,"GB2_PESO"  ,"GB2",)
 oCell := TRCell():New(oSection2,"GB2_PT"    ,"GB2",)
 oCell := TRCell():New(oSection2,"GB2_PC"    ,"GB2",)
 oCell := TRCell():New(oSection2,"GB2_APGAR" ,"GB2",STR0017) //"Apgar 01 min"
 oCell := TRCell():New(oSection2,"GB2_APGAR2","GB2",STR0018) //"Apgar 05 min"
                                                                               
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return( oReport )


Static Function FS_NomeCon()
 cNomeCon := " "
 DbSelectArea("GCZ")
 DbSetOrder(2)        
 If DbSeek(xFilial("GCZ")+trim(GB2->GB2_REGATE))   // Busca O REGISTRO NA GUIA
  DbSelectArea("GA9")
  DbSetOrder(1)         
  If DbSeek( xFilial("GA9")+trim(GCZ->GCZ_CODCON))  // Busca a Descricao  CONVENIO
 		cNomeCon := substr(Trim( GA9->GA9_NREDUZ )	, 1, 18)
   DbSelectArea("GCM")
   DbSetOrder(2)         
   If DbSeek( xFilial("GCM")+trim( GCZ->GCZ_CODPLA ) ) //BUSCA DESCRICAO PLANO       
    cNomeCon := cNomeCon+" / "+substr(transform(Trim(GCM_DESPLA ), "@!" ), 1, 30-len(cNomeCon) )         
   EndIf       
  EndIf  
 EndIf  
Return(cNomeCon)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณRB9Imp    ณ Autor ณ Antonio Carlos        ณ Data ณ 17/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RB9IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cFiltro   := "" 

cFiltro := "@GB2_FILIAL = '"+xFilial("GB2")+"' AND D_E_L_E_T_ <> '*' "   
cFiltro += " AND GB2_DTNASC BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "

oSection1:SetIdxOrder(4) 
oSection1:SetFilter(cFiltro) 
oSection2:SetParentFilter({|G|GB2->GB2_REGATE==G},{||GB2->GB2_REGATE})
oSection1:Print() 
oReport:SetMeter(GB2->(LastRec()))
 
Return( NIL )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRB9R3บ Autor ณ PAULO JOSE         บ Data ณ  06/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio REG.de NasciMENTOS                               บฑฑ
ฑฑบ          ณ ATUALIZADO POR DANIEL PEIXOTO                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRB9R3

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""  
Local cPict          := ""
Local titulo         := STR0003    //titulo  //"Livro de Registro de Nascimentos"
Local nLin           := 80
                     
Local Cabec1         := padr( STR0004, 08 )+ ;  //"Atendimento"
																								padr( STR0005 , 46 )+ ;  //"Nome da Mae"
																								padr( STR0006, 31 )+ ;  //"Convenio / Plano"
																								padr( STR0007, 16 )+ ;  //"Parto"
																								padr( STR0008, 36 )     //"Obstetra"
																																																
Local Cabec2         := padr( "", 15 )+ ; 
																				    padr( STR0009, 15 )+ ;  //"Data Nasc."
																								padr( STR0010, 06 )+ ;  //"Hora"
																								padr( STR0011, 06 )+ ;  //"Sexo"
																								padr( STR0012, 31 )+ ;  //"Tipo Alta"
																								padr( STR0013, 12 )+ ;  //"Estatura"
																								padr( STR0014, 09 )+ ;  //"Peso"
																								padr( STR0015, 07 )+ ;  //"PT"
																								padr( STR0016, 07 )+ ;  //"PC"
																								padr( STR0017, 12 )+ ;  //"Apgar 1 min"
																								padr( STR0018, 11 )    																								 //"Apgar 5 min"
																								
Local imprime        := .T.
Local aOrd := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"     // P=80 M=132 G=220
Private nomeprog     := "HSPAHRB9" // nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { STR0019, 1, STR0020, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRB9" // nome do arquivo usado para impressao em disco

//Variaveis pra 
Private dDataInicial := ctod("  /  /  ")
Private dDataFinal   := ctod("  /  /  ")

Private cString := "GB2"

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

dbSelectArea(cString)
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a Perguntas para o usuario...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPRB9"

 If !Pergunte(cPerg,.T.)
   return
 EndIf         

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
	 
 dDataInicial := ( mv_par01 )  // data inicial
 dDataFinal   := ( mv_par02 )  // data final 
 

 //
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  06/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nI        := 0
Local aGB2_Dados:= {} 

Local nGB2_REGATE := 1 
Local nGB2_MAE    := 2 
//Local nGB2_CODCON := 3 Nao usado mais
Local nGB2_TIPO   := 4
Local nGB2_CODMED := 5 
Local nGB2_DTNASC := 6 
Local nGB2_HORNAS := 7 
Local nGB2_SEXO   := 8 
Local nGB2_TPALTA := 9
Local nGB2_ALTURA := 10
Local nGB2_PESO   := 11 
Local nGB2_PT     := 12 
Local nGB2_PC     := 13
Local nGB2_APG1   := 14
Local nGB2_APG2   := 15

Local cNomeMedico := " "
Local cDescAlta   := " "
Local cTipoParto  := " " 
Local cNomeCon    := " "         
Local cSexo       := " "         


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//SetRegua(RecCount())

dbSelectArea(cString)
dbSetOrder(4)

dbGoTop()

While !EOF() .and. ( GB2->GB2_DTNASC <= dDataFinal )
   
   If lAbortPrint
      @nLin,00 PSAY STR0023 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif  
          
   //Coloca os Registros da tabela na Matriz
   AADD( aGB2_Dados,( {GB2->GB2_REGATE , ;    																		
   										trim(GB2->GB2_MAE ) , ;   																		
   										"", ;   																		
                      GB2->GB2_TIPO   , ;   																		   													 					
											GB2->GB2_CODCRM , ;   																		
   										GB2->GB2_DTNASC , ;   																		
   										GB2->GB2_HORNAS , ;   																		
   										GB2->GB2_SEXO   , ;   																		
   										GB2->GB2_TPALTA , ;   																		   														 				
   										transform( GB2->GB2_ALTURA, "@E 9.999"  ) , ;
   										transform( GB2->GB2_PESO  , "@E 9.999"  ) , ;
   										transform( GB2->GB2_PT    , "@E 999.99" ) , ;
   										transform( GB2->GB2_PC    , "@E 9.999"  ) , ;
   										transform( GB2->GB2_APGAR , "@E 999"    ) , ;
   										transform( GB2->GB2_APGAR2, "@E 999"    )  }		) )    
   
   dbSkip() // passa para o proximo registro da tabela
   
enddo

For nI:=1 to Len(aGB2_Dados)

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   If lAbortPrint
      @nLin,00 PSAY STR0023 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Impressao do cabecalho do relatorio. . .                            ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
      nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   	Endif
   
   nLin := nLin + 1 // Avanca a linha de impressao
   @nLin,000 psay aGB2_Dados[nI][nGB2_REGATE]              
   @nLin,008 psay substr( aGB2_Dados[nI][nGB2_MAE], 1, 45 )   
   
   DbSelectArea("GCZ")
   DbSetOrder(2)        
   
   If DbSeek( xFilial("GCZ")+trim(aGB2_Dados[nI][nGB2_REGATE]) )   // Busca O REGISTRO NA GUIA
     DbSelectArea("GA9")
     DbSetOrder(1)         
      
     If DbSeek( xFilial("GA9")+trim( GCZ->GCZ_CODCON ) )  // Busca a Descricao  CONVENIO
   			cNomeCon := substr(Trim( GA9->GA9_NREDUZ )	, 1, 18   )
   			   
       DbSelectArea("GCM")
       DbSetOrder(2)         
       If DbSeek( xFilial("GCM")+trim( GCZ->GCZ_CODPLA ) ) //BUSCA DESCRICAO PLANO       
         cNomeCon := cNomeCon+" / "+substr(transform( Trim( GCM_DESPLA ), "@!" ), 1, 30-len(cNomeCon) )         
       endif       
            
     endif 			   

   Endif  		  
  
   @nLin,054 psay substr( cNomeCon, 1, 30 )
   
   if aGB2_Dados[nI][nGB2_TIPO] = "0"    
      cTipoParto := STR0024       //"CESAREA"
   elseif aGB2_Dados[nI][nGB2_TIPO] = "1" 
      cTipoParto := STR0025       //"NORMAL"
   endif

   @nLin,085 psay cTipoParto 
      
   DbSelectArea("SRA")
   DbSetOrder(11)
   If DbSeek( xFilial("SRA")+trim(aGB2_Dados[nI][nGB2_CODMED]) )   // Busca a Descricao MEDICO
			   cNomeMedico := AllTrim( SRA->RA_NOME )
   Else
      cNomeMedico := trim(aGB2_Dados[nI][nGB2_CODMED]) 
   Endif      			   
   
   @nLin,101 psay substr( cNomeMedico, 1, 30 )
   
   nLin := nLin + 1 // Avanca a linha de impressao   
   
   @nLin,015 psay aGB2_Dados[nI][nGB2_DTNASC]                
   @nLin,030 psay aGB2_Dados[nI][nGB2_HORNAS]
   
   if aGB2_Dados[nI][nGB2_SEXO] == "0"
      cSexo := "M"
   elseif aGB2_Dados[nI][nGB2_SEXO] == "1"
      cSexo := "F"               
   endif
   
   @nLin,036 psay cSexo 
    
   DbSelectArea("GF4")
   DbSetOrder(1)
   
   If DbSeek( xFilial("GF4")+(aGB2_Dados[nI][nGB2_TPALTA]) )   // Busca A Descricao da ALta   (Cond. Nasc.)
			   cDescAlta := AllTrim( GF4->GF4_DSTPAL )
   Else
      cDescAlta := " "
   Endif      			    
 
   @nLin,042 psay  SUBSTR(cDescAlta, 1, 30)   //SUBSTR(cDescAlta, 1, 11)      // COD. NASC.
     
   @nLin,073 psay aGB2_Dados[nI][nGB2_ALTURA] 
   @nLin,085 psay aGB2_Dados[nI][nGB2_PESO]                
   @nLin,092 psay aGB2_Dados[nI][nGB2_PT] 
   @nLin,101 psay aGB2_Dados[nI][nGB2_PC] 
   @nLin,108 psay aGB2_Dados[nI][nGB2_APG1] 
   @nLin,119 psay aGB2_Dados[nI][nGB2_APG2]  
   
   nLin := nLin + 1 // Avanca a linha de impressao                   
   @nLin,000 psay Replicate("-", 132 )   
   
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cString) 
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

Return