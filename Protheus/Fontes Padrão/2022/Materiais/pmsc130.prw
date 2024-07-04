#INCLUDE "pmsc130.ch"
#Include "Protheus.ch"
#Include "prconst.ch"
#include "PMSICONS.CH"

//Codigos HTML
#Define HTMO ' <B><font color="#FF0000"><I> '
#Define HTMC ' </B></font></I> '

//getdados
#define GD_INSERT 1
#define GD_UPDATE 2
#define GD_DELETE 4
#define NTAMGET0 4
#define NTAMGET1 6
#define NTAMGET2 2
#define NTAMGET3 6
#define NTAMGET4 4
#define NTAMGET5 2

//Definicao dos aCols
#define DRaCols0 {{STR0001,255,255,255,.F.},{STR0002,255,255,255,.F.},{STR0003,255,255,255,.F.}} //"Totalizador"###"Grupo"###"Detalhe"
#define DRaCols1 {{Space(60),Space(nTamProd),Space(nTamProd),Space(nTamGrProd),Space(nTamGrProd),Space(255),.F.}}
#define DRaCols2 {{"ICMS",0,.F.},{"ISS",0,.F.},{"IPI",0,.F.},{"PIS",0,.F.},{"COFINS",0,.F.}}
#define DRaCols3 {{Space(60),Space(nTamRecur),Space(nTamRecur),Space(nTamEquip),Space(nTamEquip),Space(255),.F.}}
#define DRaCols4 {{Space(60),Space(nTamSX5),Space(nTamSX5),Space(255),.F.}}
#define DRaCols5 {{Space(60),Space(255),.F.}}

//Defines das posicoes do vetor tela
#define MATRIZAVET {{'1','1','1','1','1','1','1'},'',{},{},{},{},{},{}}
#define NPOSTIPOCM 1,1
#define NPOSDETFAT 1,2
#define NPOSDETCST 1,3
#define NPOSDETIMP 1,4
#define NPOSDETHRS 1,5
#define NPOSDETDDI 1,5
#define NPOSDETDIN 1,7
#define NPOSFILGEN 2
#define NPOSAPRODS 3
#define NPOSAIMPOS 4
#define NPOSADESPE 5
#define NPOSARECUR 6
#define NPOSAFROMS 7
#define NPOSACORES 8

//Definicoes Estaticas
Static nTamProd   := TamSx3("B1_COD")[1]
Static nTamRecur  := TamSx3("AE8_RECURS")[1]
Static nTamSX5    := TamSx3("X5_CHAVE")[1]
Static nTamGrProd := TamSx3("BM_GRUPO")[1]
Static nTamEquip  := TamSx3("AE8_EQUIP")[1]

//( <nRed> + ( <nGreen> * 256 ) + ( <nBlue> * 65536 ) )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PMSC130   ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Relatorio de acompanhamento de rentabilidade.              ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ MP811 - PMS                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function PMSC130(cProjeto)

Local lRet1    := .T.
Local aConfig  := {}
Local aRet     := {}
Local aRetHrs  := {}
Local aRetDes  := {}

Local aAreaAF8 := AF8->(GetArea())

Private lPM130Cust := ExistBlock("PM130Cust")

DEFAULT cProjeto := ""

If !Empty(cProjeto)
	AF8->(DbSetOrder(1))
	If !AF8->(MsSeek(xFilial("AF8")+cProjeto))
		MsgAlert(STR0004) //"Projeto n„o encontrado!"
		lRet1 := .F.
	EndIf
EndIf


If lRet1 .And. PMSCRConf(@aConfig)
	Processa({|| lRet1 := PM130Calc(AF8->AF8_PROJET,AF8->AF8_REVISA,AF8->AF8_FINISH,aConfig,@aRet,@aRetHrs,@aRetDes) } , STR0005) //"Calculando dados."
	If lRet1
		FATPDLogUser('PMSC130')
		PM130TVis(aRet,aRetHrs,aRetDes,aConfig,AF8->AF8_DESCRI)
	Else
		MsgAlert(STR0006) //"N„o h· dados para consulta"  

	EndIf  
	
EndIf

AF8->(RestArea(aAreaAF8))

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PMSCRConf ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Tela do configurador de relatorio                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function PMSCRConf(aVet) 

Local lRet := .F.
Local oDlg
Local oFolder
Local oGDLDQ0,oGDLDQ1,oGDLDQ2,oGDLDQ3,oGDLDQ4,oGDLDQ5
Local bKeyF4     := SetKey(VK_F4)
Local cArquivo   := "\profile\padrao.pms"
Local cArqAnt    := ""
Local aDetAS     := {'1','1','1','1','1','1','1'}
Local cFilGen    := Space(255)
Local cDirProf   := "SERVIDOR\profile\"
Local nGetd      := GD_UPDATE+GD_INSERT+GD_DELETE
Local aHeader0 := {}
Local aHeader1 := {}
Local aHeader2 := {}
Local aHeader3 := {}
Local aHeader4 := {}
Local aHeader5 := {}
Local aCols0   := DRaCols0
Local aCols1   := DRaCols1
Local aCols2   := DRaCols2
Local aCols3   := DRaCols3
Local aCols4   := DRaCols4
Local aCols5   := DRaCols5
Local lFuncPale := .T.

DEFAULT aVet := {}

SetKey(VK_F4,{|| If(lFuncPale .And. oFolder:nOption == 1,PM130Palet(@oGDLDQ0,@lFuncPale),) })

/*
Posicoes do aHaeader
01 - SX3->X3_TITULO
02 - SX3->X3_CAMPO
03 - SX3->X3_PICTURE
04 - SX3->X3_TAMANHO
05 - SX3->X3_DECIMAL
06 - SX3->X3_VALID
07 - SX3->X3_USADO
08 - SX3->X3_TIPO
09 - SX3->X3_F3
10 - SX3->X3_CONTEXT
11 - SX3->X3_CBOX
12 - SX3->X3_RELACAO
13 - SX3->X3_WHEN
14 - SX3->X3_VISUAL
15 - SX3->X3_VLDUSER
16 - SX3->X3_PICTVAR
17 - SX3->X3_OBRIGAT
*/

//GetDados Impostos
Aadd(aHeader0,{STR0007 ,"cTLinha" ,"@!"   ,20,0,,,"C",,"V",,,,"V",,,}) //"Tipo Linha"
Aadd(aHeader0,{STR0008 ,"nRed"    ,"999"  ,3 ,0,,,"N",,"V",,,,"A",,,}) //"Vermelho"
Aadd(aHeader0,{STR0009 ,"nGren"   ,"999"  ,3 ,0,,,"N",,"V",,,,"A",,,}) //"Verde"
Aadd(aHeader0,{STR0010 ,"nBlue"   ,"999"  ,3 ,0,,,"N",,"V",,,,"A",,,}) //"Azul"

//GetDados Grupo de Produtos
Aadd(aHeader1,{STR0011 ,"CNOMEGRUPO","@!S30",        60,0,"!Vazio()",,"C",       ,"V",             ,   ,,"A",,,}) //"Nome do Totalizador"
Aadd(aHeader1,{STR0012 ,"CDE"       ,""     ,nTamProd  ,0,          ,,"C","SB1  ","V",             ,   ,,"A",,,}) //"Codigo De"
Aadd(aHeader1,{STR0013 ,"CATE"      ,""     ,nTamProd  ,0,          ,,"C","SB1  ","V",             ,   ,,"A",,,}) //"Codigo AtÈ"
Aadd(aHeader1,{STR0014 ,"CGDE"      ,""     ,nTamGrProd,0,          ,,"C","SBM  ","V",             ,   ,,"A",,,}) //"Grupo De"
Aadd(aHeader1,{STR0015 ,"CGATE"     ,""     ,nTamGrProd,0,          ,,"C","SBM  ","V",             ,   ,,"A",,,}) //"Grupo AtÈ"
Aadd(aHeader1,{STR0016 ,"CEXFIL"    ,"@!S30",       255,0,          ,,"C",       ,"V",             ,   ,,"A",,,}) //"Exp.Filtro"

//GetDados Impostos
Aadd(aHeader2,{STR0017 ,"cImp" ,"@!"           ,20,0,,,"C",,"V",,,,"V",,,}) //"Imposto"
Aadd(aHeader2,{STR0018 ,"nAliq","99999.99999"  ,11,5,,,"N",,"V",,,,"A",,,}) //"Aliquota %"

//GetDados Grupo de Produtos
Aadd(aHeader3,{STR0011 ,"CNOMEGRUPO","@!S30",       60,0,"!Vazio()",,"C",       ,"V",             ,   ,,"A",,,}) //"Nome do Totalizador"
Aadd(aHeader3,{STR0012 ,"CDE"       ,""     ,nTamRecur,0,          ,,"C","AE8  ","V",             ,   ,,"A",,,}) //"Codigo De"
Aadd(aHeader3,{STR0013 ,"CATE"      ,""     ,nTamRecur,0,          ,,"C","AE8  ","V",             ,   ,,"A",,,}) //"Codigo AtÈ"
Aadd(aHeader3,{STR0019 ,"CGDE"      ,""     ,nTamEquip,0,          ,,"C","AED  ","V",             ,   ,,"A",,,}) //"Equipe De"
Aadd(aHeader3,{STR0020 ,"CGATE"     ,""     ,nTamEquip,0,          ,,"C","AED  ","V",             ,   ,,"A",,,}) //"Equipe AtÈ"
Aadd(aHeader3,{STR0016 ,"CEXFIL"    ,"@!S30",      255,0,          ,,"C",       ,"V",             ,   ,,"A",,,}) //"Exp.Filtro"

//GetDados Depesas Diretas
Aadd(aHeader4,{STR0011 ,"CNOMEGRUPO","@!S30",     60,0,"!Vazio()",,"C",       ,"V",             ,   ,,"A",,,}) //"Nome do Totalizador"
Aadd(aHeader4,{STR0021 ,"CDE"       ,""     ,nTamSX5,0,          ,,"C","FD   ","V",             ,   ,,"A",,,}) //"De"
Aadd(aHeader4,{STR0022 ,"CATE"      ,""     ,nTamSX5,0,          ,,"C","FD   ","V",             ,   ,,"A",,,}) //"AtÈ"
Aadd(aHeader4,{STR0016 ,"CEXFIL"    ,"@!S30",    255,0,          ,,"C",       ,"V",             ,   ,,"A",,,}) //"Exp.Filtro"

//GetDados Impostos
Aadd(aHeader5,{STR0023 ,"CTOT" ,"@!S30",  60,0,"!Empty(CTOT)"      ,,"C",       ,"V",             ,   ,,"A",,,}) //"Nome do Acumulador"
Aadd(aHeader5,{STR0024 ,"CFORM","@!S60", 255,0,"PM130VlForm(CFORM)",,"C",       ,"V",             ,   ,,"A",,,}) //"Formula (Ex. TOT1 * 0.20)"

oDlg := MSDialog():New(0,0,450,740,STR0025,,,,,,,,,.T.,,,) //"Configurador do relatÛrio de acompanhamento de rentabilidade."

TGroup():New(02,02,025,362,STR0026,oDlg,,,.T.,) //" Arquivo "
TGroup():New(27,02,170,362,STR0027,oDlg,,,.T.,) //" Consulta "

TSay():New(010,08, {||STR0028},oDlg,,,,,,.T.,,,35,17,,,,,,) //"Nome:"
TGet():New(009,30,bSETGET(cArquivo),oDlg,250,10,,,,,,,,.T.,,,,,,,.T.,,,,,,)
SButton():New(008,292, 14, {|| cArqAnt := cArquivo, cArquivo := AllTrim(cGetFile(STR0029,STR0030,0,cDirProf,.T.,,.T.)) , If(!Empty(cArquivo), If(PM130RWF(cArquivo,@aVet),PM130MVet(@cFilGen,@aDetAS,@oGDLDQ0,@oGDLDQ1,@oGDLDQ2,@oGDLDQ3,@oGDLDQ4,@oGDLDQ5,aVet,2), ) , cArquivo := cArqAnt ) },,) //"Arquivos de Relatorio  |*.PMS"###"Abrir Arquivo"
SButton():New(008,328, 13, {|| cArqAnt := cArquivo, cArquivo := AllTrim(cGetFile(STR0029,STR0031,0,cDirProf,.F.,,.T.)) , If(!Empty(cArquivo), If(PM130MVet(cFilGen,aDetAS,oGDLDQ0,oGDLDQ1,oGDLDQ2,oGDLDQ3,oGDLDQ4,oGDLDQ5,@aVet,1),(PM130RWF(cArquivo,aVet,.T.),PM130MVet(@cFilGen,@aDetAS,@oGDLDQ0,@oGDLDQ1,@oGDLDQ2,@oGDLDQ3,@oGDLDQ4,@oGDLDQ5,aVet,2)), ) , cArquivo := cArqAnt ) },,) //"Arquivos de Relatorio  |*.PMS"###"Salvar Arquivo"
oFolder := TFolder():New(35,07,{STR0032,STR0033,STR0034,STR0035,STR0036,STR0037}, ,oDlg,1,,,.T.,.T., 350,130, ) //"Geral"###"Grupos Produto"###"Impostos"###"Recursos"###"Despesas diretas"###"Despesas indiretas"
TSay():New(175,08, {||STR0038},oDlg,,,,,,.T.,,,120,17,,,,,,) //"Filtro GenÈrico:"
TGet():New(173,50,bSETGET(cFilGen),oDlg,310,10,,,,,,,,.T.,,,,,,,,,,,,,)
SButton():New(192,296, 15, {|| If((lRet := PM130VlForm(oGDLDQ5:aCols[oGDLDQ5:nAt][2]) ), oDlg:End(), ) },,)
SButton():New(192,332, 02, {|| oDlg:End() },,)

//Geral
TSay():New(007,08, {||STR0039},oFolder:aDialogs[1],,,,,,.T.,,,85,17,,,,,,) //"Det. Faturamento:"
TComboBox():New(006,60, bSETGET(aDetAS[2]),{STR0040,STR0041,STR0042},60,21,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,) //"1=Detalhe"###"2=Grupo"###"3=Totalizador"
TSay():New(022,08, {||STR0043},oFolder:aDialogs[1],,,,,,.T.,,,85,17,,,,,,) //"Det. Custo:"
TComboBox():New(021,60, bSETGET(aDetAS[3]),{STR0040,STR0041,STR0042},60,21,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,) //"1=Detalhe"###"2=Grupo"###"3=Totalizador"
TSay():New(037,08, {||STR0044},oFolder:aDialogs[1],,,,,,.T.,,,85,17,,,,,,) //"Tipo do Custo:"
TComboBox():New(036,60, bSETGET(aDetAS[1]),IIf(!lPM130Cust,{STR0045,STR0046},{STR0045,STR0046,STR0047}),60,21,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,) //"1=Std."###"2=CMV"###"1=Std."###"2=CMV"###"3=Ponto de Entrada"
TSay():New(052,08, {||STR0048},oFolder:aDialogs[1],,,,,,.T.,,,85,17,,,,,,) //"Det. Impostos:"
TComboBox():New(051,60, bSETGET(aDetAS[4]),{STR0040,STR0042},60,21,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,) //"1=Detalhe"###"3=Totalizador"
TSay():New(067,08, {||STR0049},oFolder:aDialogs[1],,,,,,.T.,,,85,17,,,,,,) //"Det. Hr. Alocadas:"
TComboBox():New(066,60, bSETGET(aDetAS[5]),{STR0040,STR0041,STR0042},60,21,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,) //"1=Detalhe"###"2=Grupo"###"3=Totalizador"
TSay():New(082,08, {||STR0050},oFolder:aDialogs[1],,,,,,.T.,,,85,17,,,,,,) //"Det. Desp. Diretas:"
TComboBox():New(081,60, bSETGET(aDetAS[6]),{STR0040,STR0041,STR0042},60,21,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,) //"1=Detalhe"###"2=Grupo"###"3=Totalizador"
TSay():New(097,08, {||STR0051},oFolder:aDialogs[1],,,,,,.T.,,,85,17,,,,,,) //"Det. Desp. Indiretas:"
TComboBox():New(096,60, bSETGET(aDetAS[7]),{STR0040,STR0042},60,21,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,) //"1=Detalhe"###"3=Totalizador"
TGroup():New(20,140,80,325,STR0052,oFolder:aDialogs[1],,,.T.,) //" Cores - Precione F4 para Paleta de Cores "
oGDLDQ0 := MsNewGetDados():New(28,145,75,320,GD_UPDATE,,,,,,5,,,,oFolder:aDialogs[1],aHeader0,aCols0)
oGDLDQ0:oBrowse:lUseDefaultcolors := .F.
oGDLDQ0:oBrowse:SetBlkBackColor({|| ( oGDLDQ0:aCols[oGDLDQ0:nAt][2] + ( oGDLDQ0:aCols[oGDLDQ0:nAt][3] * 256 ) + ( oGDLDQ0:aCols[oGDLDQ0:nAt][4] * 65536 ) ) })
	
//Grupos Produto
oGDLDQ1 := MsNewGetDados():New(002,002,115,345,nGetd,"PM130VlLin(1)",,,,,9999,,,,oFolder:aDialogs[2],aHeader1,aCols1)

//Impostos
oGDLDQ2 := MsNewGetDados():New(002,002,115,345,GD_UPDATE,,,,,,5,,,,oFolder:aDialogs[3],aHeader2,aCols2)

//Recursos
oGDLDQ3 := MsNewGetDados():New(002,002,115,345,nGetd,"PM130VlLin(1)",,,,,9999,,,,oFolder:aDialogs[4],aHeader3,aCols3)

//Despesas diretas
oGDLDQ4 := MsNewGetDados():New(002,002,115,345,nGetd,"PM130VlLin(3)",,,,,9999,,,,oFolder:aDialogs[5],aHeader4,aCols4)

//Despesas indiretas
oGDLDQ5 := MsNewGetDados():New(002,002,115,220,nGetd,"PM130VlForm(aCols[n][2])",,,,,9999,,,,oFolder:aDialogs[6],aHeader5,aCols5)
TGroup():New(20,230,90,340,STR0053,oFolder:aDialogs[6],,,.T.,) //" Expressıes para formula "
TSay():New(27,240, {|| STR0054 },oFolder:aDialogs[6],,,,,,.T.,,,100,17,,,,,,) //"TOT1 = FATURAMENTO BRUTO"
TSay():New(37,240, {|| STR0055 },oFolder:aDialogs[6],,,,,,.T.,,,100,17,,,,,,) //"TOT2 = IMPOSTOS"
TSay():New(47,240, {|| STR0056 },oFolder:aDialogs[6],,,,,,.T.,,,100,17,,,,,,) //"TOT3 = FATURAMENTO LIQUIDO"
TSay():New(57,240, {|| STR0057 },oFolder:aDialogs[6],,,,,,.T.,,,100,17,,,,,,) //"TOT4 = CUSTOS DIRETOS"
TSay():New(67,240, {|| STR0058 },oFolder:aDialogs[6],,,,,,.T.,,,100,17,,,,,,) //"TOT5 = HORAS ALOCADAS"
TSay():New(77,240, {|| STR0059 },oFolder:aDialogs[6],,,,,,.T.,,,100,17,,,,,,) //"TOT6 = DESPESAS DIRETAS"

//Prepara Arquivo.
PM130MVet(cFilGen,aDetAS,oGDLDQ0,oGDLDQ1,oGDLDQ2,oGDLDQ3,oGDLDQ4,oGDLDQ5,@aVet,1)
If File(cArquivo)
	PM130RWF(cArquivo,@aVet)
Else
	PM130RWF(cArquivo,aVet,.T.)
EndIf
PM130MVet(@cFilGen,@aDetAS,@oGDLDQ0,@oGDLDQ1,@oGDLDQ2,@oGDLDQ3,@oGDLDQ4,@oGDLDQ5,aVet,2)

oDlg:Activate(,,,.T.)

If lRet
	If PM130MVet(cFilGen,aDetAS,oGDLDQ0,oGDLDQ1,oGDLDQ2,oGDLDQ3,oGDLDQ4,oGDLDQ5,@aVet,1)
	Else
		MsgAlert(STR0060) //"Erro ao montar vetor."
		lRet := .F.
	EndIf
EndIf

SetKey(VK_F4,bKeyF4)

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130VlLin∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Validacao da linha.                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PM130VlLin(nDlg)
Local lRet := .F.

If !Empty(aCols[n][1])
	If aCols[n][2] <= aCols[n][3]
		lRet := .T.
	Else
		MsgAlert(STR0061) //'Filtro "CÛdigo De,AtÈ" inv·lido.'
	EndIF
	If nDlg == 1
		If lRet .And. aCols[n][4] <= aCols[n][5]
			lRet := .T.
		Else
 			MsgAlert(STR0062) //'Filtro "Grupo De,AtÈ" inv·lido.'
			lRet := .F.
		EndIF
	EndIf
Else
	MsgAlert(STR0063) //"Nome do totalizador obrigatÛrio."
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130VlForm∫Autor ≥Carlos A. Gomes Jr. ∫ Data ≥  26/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Validacao da linha.                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PM130VlForm(cFormu)
Local lRet := .F.
Local xTeste, oErro
Local bErrBlock := ErrorBlock()
Local lErro := .F.

If !Empty(cFormu)

	cFormu := AllTrim(StrTran(cFormu,"TOT1","1"))
	cFormu := AllTrim(StrTran(cFormu,"TOT2","2"))
	cFormu := AllTrim(StrTran(cFormu,"TOT3","3"))
	cFormu := AllTrim(StrTran(cFormu,"TOT4","4"))
	cFormu := AllTrim(StrTran(cFormu,"TOT5","5"))
	cFormu := AllTrim(StrTran(cFormu,"TOT6","6"))
	ErrorBlock( {|e| lErro := .T., oErro := e } )
	xTeste := &(cFormu)
	ErrorBlock(bErrBlock)

	If lErro
		MsgStop(HTMO+STR0096+HTMC+"<BR><BR>"+STR0097+"<BR><BR>" +oErro:description, STR0098) //"Existe um erro na formula!" ##"Verifique o erro abaixo :" ##"ERRO NA FORMULA!"
	ElseIf ValType(xTeste) == "N"
		lRet := .T.
	Else
		MsgStop(STR0099)
	EndIf
Else
	MsgStop(STR0100)
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130MVet ∫Autor  ≥Microsiga           ∫ Data ≥  04/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Monta vetor com vari·veis.                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PM130MVet(cFilGen,aDetAS,oGDLDQ0,oGDLDQ1,oGDLDQ2,oGDLDQ3,oGDLDQ4,oGDLDQ5,aVet,nOPc)

Local lRet := .T.

DEFAULT cFilGen   := Space(255)
DEFAULT aDetAS    := {'1','1','1','1','1','1','1'}
DEFAULT aVet      := {}
DEFAULT nOPc      := "1"

If nOpc == 1
	aVet := MATRIZAVET

	aVet[NPOSTIPOCM] := aDetAS[1]
	aVet[NPOSDETFAT] := aDetAS[2]
	aVet[NPOSDETCST] := aDetAS[3]
	aVet[NPOSDETIMP] := aDetAS[4]
	aVet[NPOSDETHRS] := aDetAS[5]
	aVet[NPOSDETDDI] := aDetAS[6]
	aVet[NPOSDETDIN] := aDetAS[7]

	aVet[NPOSFILGEN] := cFilGen

	AEval(oGDLDQ1:aCols,{|x,y| If(!x[NTAMGET1+1].And.!Empty(x[1]),AAdd(aVet[NPOSAPRODS],x),) })
	AEval(oGDLDQ2:aCols,{|x,y| If(!x[NTAMGET2+1].And.!Empty(x[1]),AAdd(aVet[NPOSAIMPOS],x),) })
	AEval(oGDLDQ3:aCols,{|x,y| If(!x[NTAMGET3+1].And.!Empty(x[1]),AAdd(aVet[NPOSARECUR],x),) })
	AEval(oGDLDQ4:aCols,{|x,y| If(!x[NTAMGET4+1].And.!Empty(x[1]),AAdd(aVet[NPOSADESPE],x),) })
	AEval(oGDLDQ5:aCols,{|x,y| If(!x[NTAMGET5+1].And.!Empty(x[1]),AAdd(aVet[NPOSAFROMS],x),) })
	AEval(oGDLDQ0:aCols,{|x,y| If(!x[NTAMGET0+1].And.!Empty(x[1]),AAdd(aVet[NPOSACORES],x),) })
	
	If Len(aVet[NPOSACORES]) == 0
		aVet[NPOSACORES] := DRaCols0
	EndIf
	If Len(aVet[NPOSAPRODS]) == 0
		aVet[NPOSAPRODS] := DRaCols1
	EndIf
	If Len(aVet[NPOSAIMPOS]) == 0
		aVet[NPOSAIMPOS] := DRaCols2
	EndIf
	If Len(aVet[NPOSARECUR]) == 0
		aVet[NPOSARECUR] := DRaCols3
	EndIf
	If Len(aVet[NPOSADESPE]) == 0
		aVet[NPOSADESPE] := DRaCols4
	EndIf
	If Len(aVet[NPOSAFROMS]) == 0
		aVet[NPOSAFROMS] := DRaCols5
	EndIf

ElseIf nOpc == 2
	
	cFilGen   := aVet[NPOSFILGEN]

	aDetAS[1] := aVet[NPOSTIPOCM]
	aDetAS[2] := aVet[NPOSDETFAT]
	aDetAS[3] := aVet[NPOSDETCST]
	aDetAS[4] := aVet[NPOSDETIMP]
	aDetAS[5] := aVet[NPOSDETHRS]
	aDetAS[6] := aVet[NPOSDETDDI]
	aDetAS[7] := aVet[NPOSDETDIN]
	
	oGDLDQ0:aCols := aVet[NPOSACORES]
	oGDLDQ1:aCols := aVet[NPOSAPRODS]
	oGDLDQ2:aCols := aVet[NPOSAIMPOS]
	oGDLDQ3:aCols := aVet[NPOSARECUR]
	oGDLDQ4:aCols := aVet[NPOSADESPE]
	oGDLDQ5:aCols := aVet[NPOSAFROMS]
	oGDLDQ0:Refresh()
	oGDLDQ1:Refresh()
	oGDLDQ2:Refresh()
	oGDLDQ3:Refresh()
	oGDLDQ4:Refresh()
	oGDLDQ5:Refresh()
Else
	lRet := .F.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130RWF  ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/06/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Leitura e Gravacao do vetor de configuracao da consulta     ∫±±
±±∫          ≥de acompanhamento de rentabilidade em arquivo.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ [1] - Nome do arquivo.                                     ∫±±
±±∫          ≥ [2] - Vetor a ser gravado.                                 ∫±±
±±∫          ≥ [3] - .T. para gravar ou .F. para Ler. (Defult .F.)        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Retorno   ≥ .T. - Funcionou / .F. - Nao Funcionou                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PM130RWF(cFName,aVet,lWrite)
Local lRet     := .F.

Default lWrite := .F.
Default cFName := ""
Default aVet   := {}

If Empty(cFName)
	MsgAlert(STR0064) //"Nome do arquivo nao informado!"
ElseIf lWrite
	If File(cFName) .And. !MsgYesNo(STR0065+cFName+STR0066) //"Arquivo "###" j· existe! Sobrepıe?"
		MsgAlert(STR0067) //"GravaÁ„o cancelada pelo usu·rio!"
	Else
		__VSave(aVet,cFName)
		If File(cFName)
			lRet := .T.
		Else
			UserException("CREATEFILE ["+cFName+"] ")
		EndIf
	EndIf
Else
	If !File(cFName)
		MsgAlert(STR0065+cFName+STR0068) //"Arquivo "###" n„o encontrado!"
	Else
		aVet := __VRestore(cFName)
		If Len(aVet) == 6
			AAdd(aVet,DRaCols5)
			AAdd(aVet,DRaCols0)
		ElseIf Len(aVet) == 7
			AAdd(aVet,DRaCols0)
		EndIf
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130Calc ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/07/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Monta o vetor de acompanhamento de rentabilidade.           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PM130Calc(cProjeto,cRevisa,dDtFim,aVet,aRet,aRetHrs,aRetDes,aVetTots)

Local lRet      := .F.
Local aAreaAE8  := AE8->(GetArea())
Local aAreaAFS  := AFS->(GetArea())
Local aAreaAFI  := AFI->(GetArea())
Local aAreaAFN  := AFN->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aAreaAFA  := AFA->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSD3  := SD3->(GetArea())
Local aAreaSD2  := SD2->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local aAreaAJC  := AJC->(GetArea())
Local nProd     := 0
Local nRProd    := 0
Local nRProdTot := 0
Local nQuantAFA   := 0
Local nTpAFA      := 1
Local nValSD2     := 0
Local nValSD3     := 0
Local nValSD1     := 0
Local nQtdSD3     := 0
Local nPsVlPisSa  := 0
Local nValCofins  := 0
Local cFilSB1		:= xFilial("SB1")
Local cFilSC6		:= xFilial("SC6")
Local cFilSD1		:= xFilial("SD1")
Local cFilSD2		:= xFilial("SD2")
Local cFilSD3		:= xFilial("SD3")
Local cFilAF9		:= xFilial("AF9")
Local cFilAFA		:= xFilial("AFA")
Local cFilAFB		:= xFilial("AFB")
Local cFilAFI		:= xFilial("AFI")
Local cFilAFN		:= xFilial("AFN")
Local cFilAFR		:= xFilial("AFR")
Local cFilAFS		:= xFilial("AFS")
Local cFilAFU		:= xFilial("AFU")
Local cFilAE8		:= xFilial("AE8")
Local cFilAJC		:= xFilial("AJC")

//Variaveis com os dados dos impostos (PIS e COFINS)
Local aRelImp2    := {}
Local lPMS130PV	:= EXISTBLOCK("PMS130PV")

DEFAULT aRet      := {}
//               |   Vendido  |   Previsto  |  Realizado  |
// { Grupo, Prod, Qtd , Valor , Qtd , Valor , Qtd , Valor , {Impostos} , Nivel }

Private cCodProd := ""
Private cGruProd := ""
Private cTarefa  := ""
Private cTES     := "NNNNN3"

SB1->(DbSetOrder(1))
ProcRegua(9)
SC6->(DbSetOrder(8))
IncProc()
If SC6->(MsSeek(cFilSC6+cProjeto))
	Do While SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_PROJPMS == cProjeto
		nTpAFA := 1
		cCodProd := SC6->C6_PRODUTO
		cGruProd := Posicione("SB1",1,cFilSB1+cCodProd,"B1_GRUPO")
		cTarefa  := SC6->C6_TASKPMS
		cTes     := VeTES(SC6->C6_TES)
		If Substr(cTes,1,1) == "S" .And. Empty(aVet[NPOSFILGEN]) .Or. SC6->(&(aVet[NPOSFILGEN]))
			If (nProd := AScan( aVet[NPOSAPRODS], { |x,y| x[2]<=cCodProd .And. cCodProd<=x[3] .And. x[4]<=cGruProd .And. cGruProd<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0
				Do While nTpAFA < 3

					nValSC6 := 0
					If nTpAFA == 1
						nValSC6 := SC6->C6_VALOR
					Else
						If aVet[NPOSTIPOCM] == "1"
							If SB1->(MsSeek(cFilSB1+cCodProd))
								nValSC6 := SC6->C6_QTDVEN * RetFldProd(SB1->B1_COD,"B1_CUSTD")
							EndIf
						ElseIf aVet[NPOSTIPOCM] == "3" .And. lPM130Cust
							nValSC6 := ExecBlock("PM130Cust",.F.,.F.) * SC6->C6_QTDVEN
						Else
							nValSC6  := SC6->C6_QTDVEN * PegaCMAtu(cCodProd,SC6->C6_LOCAL)[1]
						EndIf
					EndIf

					If (nRProdTot := AScan(aRet,{|x,y| x[1] == aVet[NPOSAPRODS][nProd][1] .And. x[10] == StrZero(nTpAFA,1) + "1" })) > 0
						aRet[nRProdTot][3] += SC6->C6_QTDVEN
						aRet[nRProdTot][4] += nValSC6
						If Substr(cTes,2,1) == "S"
							aRet[nRProdTot][9][1][1] += nValSC6 * (aVet[NPOSAIMPOS][1][2] / 100)
						EndIf
						If Substr(cTes,3,1) == "S"
							aRet[nRProdTot][9][1][2] += nValSC6 * (aVet[NPOSAIMPOS][2][2] / 100)
						EndIf
						If Substr(cTes,4,1) == "S"
							aRet[nRProdTot][9][1][3] += nValSC6 * (aVet[NPOSAIMPOS][3][2] / 100)
						EndIf
						aRet[nRProdTot][9][1][4] += nValSC6 * (aVet[NPOSAIMPOS][4][2] / 100)
						aRet[nRProdTot][9][1][5] += nValSC6 * (aVet[NPOSAIMPOS][5][2] / 100)
					Else
						AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], Space(nTamProd), SC6->C6_QTDVEN, nValSC6, 0, 0, 0, 0,;
						            { {Iif(Substr(cTes,2,1) == "S", nValSC6 * (aVet[NPOSAIMPOS][1][2] / 100) , 0),;
						               Iif(Substr(cTes,3,1) == "S", nValSC6 * (aVet[NPOSAIMPOS][2][2] / 100) , 0),;
						               Iif(Substr(cTes,4,1) == "S", nValSC6 * (aVet[NPOSAIMPOS][3][2] / 100) , 0),;
						               nValSC6 * (aVet[NPOSAIMPOS][4][2] / 100),;
						               nValSC6 * (aVet[NPOSAIMPOS][5][2] / 100)},;
						              {0,0,0,0,0}, {0,0,0,0,0} },;
						            StrZero(nTpAFA,1) + "1"})
					EndIf
	
					If (nRProd := AScan(aRet,{|x,y| x[1]+x[2] == aVet[NPOSAPRODS][nProd][1] + SC6->C6_PRODUTO .And. x[10] == StrZero(nTpAFA,1) + "2" })) > 0
						aRet[nRProd][3] += SC6->C6_QTDVEN
						aRet[nRProd][4] += nValSC6
						If Substr(cTes,2,1) == "S"
							aRet[nRProd][9][1][1] += nValSC6 * (aVet[NPOSAIMPOS][1][2] / 100)
						EndIf
						If Substr(cTes,3,1) == "S"
							aRet[nRProd][9][1][2] += nValSC6 * (aVet[NPOSAIMPOS][2][2] / 100)
						EndIf
						If Substr(cTes,4,1) == "S"
							aRet[nRProd][9][1][3] += nValSC6 * (aVet[NPOSAIMPOS][3][2] / 100)
						EndIf
						aRet[nRProd][9][1][4] += nValSC6 * (aVet[NPOSAIMPOS][4][2] / 100)
						aRet[nRProd][9][1][5] += nValSC6 * (aVet[NPOSAIMPOS][5][2] / 100)
					Else
						AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], SC6->C6_PRODUTO, SC6->C6_QTDVEN, nValSC6, 0, 0, 0, 0,;
						            { {Iif(Substr(cTes,2,1) == "S", nValSC6 * (aVet[NPOSAIMPOS][1][2] / 100) , 0),;
						            	 Iif(Substr(cTes,3,1) == "S", nValSC6 * (aVet[NPOSAIMPOS][2][2] / 100) , 0),;
						            	 Iif(Substr(cTes,4,1) == "S", nValSC6 * (aVet[NPOSAIMPOS][3][2] / 100) , 0),;
						            	 nValSC6 * (aVet[NPOSAIMPOS][4][2] / 100),;
						            	 nValSC6 * (aVet[NPOSAIMPOS][5][2] / 100)},;
						            	{0,0,0,0,0}, {0,0,0,0,0} },;
						            StrZero(nTpAFA,1) + "2"})
					EndIf

					nTpAFA++
				EndDo
			EndIf
		EndIf
		SC6->(DbSkip())
	EndDo
EndIf

If lPMS130PV
	aRet := Execblock("PMS130PV", .F. , .F. , { aRet , aVet , cProjeto , cRevisa , dDtFim } )
Endif
AE8->(DbSetOrder(1))
AFA->(DbSetOrder(1))
IncProc()
If AFA->(MsSeek(cFilAFA+cProjeto+cRevisa))
	Do While AFA->AFA_FILIAL == cFilAFA .AND. AFA->AFA_PROJET == cProjeto .AND. AFA->AFA_REVISA == cRevisa

		nTpAFA := 1
		Do While nTpAFA < 3
			
			If nTpAFA == 2
				cCodProd := AFA->AFA_PRODUT
			Else
				cCodProd := Iif(Empty(AFA->AFA_PRODFA),AFA->AFA_PRODUT,AFA->AFA_PRODFA)
			EndIf

			If Empty(cCodProd)
				cCodProd := STR0069 //"SERVI«O - Outros"
			EndIf

			cGruProd := Posicione("SB1",1,cFilSB1+cCodProd,"B1_GRUPO")
			
			cTarefa  := AFA->AFA_TAREFA
	
			// verifica a quantidade do produto
			AF9->(dbSetOrder(1))
			AF9->(MsSeek(cFilAF9 + AFA->AFA_PROJET + AFA->AFA_REVISA + AFA->AFA_TAREFA))
			If AF9->(Eof()) .Or. (AF9->AF9_FATURA != "1" .And. nTpAFA == 1)
				nTpAFA++
				Loop
			Else
				nQuantAFA := PmsPrvAFA(AFA->(RecNo()),StoD("19800101"),dDtFim,AF9->(RecNo()))
			EndIf
			
			If nTpAFA == 1
				If AF9->AF9_BDI == 0
					nBDI := 1+(PmsGetBDIPad("AFC",AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI,AF9->AF9_UTIBDI) / 100)
				Else
					nBDI := 1+(AF9->AF9_BDI / 100)
				EndIf
			Else
				nBDI := 1
			EndIf
	
			If Empty(aVet[NPOSFILGEN]) .Or. AFA->(&(aVet[NPOSFILGEN]))
				If (nProd := AScan( aVet[NPOSAPRODS], { |x,y| x[2]<=cCodProd .And. cCodProd<=x[3] .And. x[4]<=cGruProd .And. cGruProd<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0
					If (nRProdTot := AScan(aRet,{|x,y| x[1] == aVet[NPOSAPRODS][nProd][1] .And. x[10] == StrZero(nTpAFA,1) + "1" })) > 0
						aRet[nRProdTot][5] += nQuantAFA
						aRet[nRProdTot][6] += nQuantAFA * AFA->AFA_CUSTD * nBDI
						aRet[nRProdTot][9][2][1] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][1][2] / 100)
						aRet[nRProdTot][9][2][2] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][2][2] / 100)
						aRet[nRProdTot][9][2][3] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][3][2] / 100)
						aRet[nRProdTot][9][2][4] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][4][2] / 100)
						aRet[nRProdTot][9][2][5] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][5][2] / 100)
					Else
						AAdd(aRet, {aVet[NPOSAPRODS][nProd][1], Space(nTamProd), 0, 0, nQuantAFA, nQuantAFA * AFA->AFA_CUSTD * nBDI, 0, 0,;
						            { {0,0,0,0,0},;
						              {nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][1][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][2][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][3][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][4][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][5][2] / 100)},;
						              {0,0,0,0,0} },;
						            StrZero(nTpAFA,1) + "1"})
					EndIf
	
					If (nRProd := AScan(aRet,{|x,y| x[1]+x[2] == aVet[NPOSAPRODS][nProd][1] + cCodProd .And. x[10] == StrZero(nTpAFA,1) + "2" })) > 0
						aRet[nRProd][5] += nQuantAFA
						aRet[nRProd][6] += nQuantAFA * AFA->AFA_CUSTD * nBDI
						aRet[nRProd][9][2][1] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][1][2] / 100)
						aRet[nRProd][9][2][2] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][2][2] / 100)
						aRet[nRProd][9][2][3] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][3][2] / 100)
						aRet[nRProd][9][2][4] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][4][2] / 100)
						aRet[nRProd][9][2][5] += nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][5][2] / 100)
					Else
						AAdd(aRet, {aVet[NPOSAPRODS][nProd][1], cCodProd, 0, 0, nQuantAFA, nQuantAFA * AFA->AFA_CUSTD * nBDI, 0, 0,;
						            { {0,0,0,0,0},;
						              {nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][1][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][2][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][3][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][4][2] / 100),;
						               nQuantAFA * AFA->AFA_CUSTD * nBDI * (aVet[NPOSAIMPOS][5][2] / 100)},;
						              {0,0,0,0,0} },;
						            StrZero(nTpAFA,1) + "2"})
					EndIf
				EndIf
			EndIf

			nTpAFA++
		EndDo
		
	 	If !Empty(AFA->AFA_RECURS)	.And. (Empty(aVet[NPOSFILGEN]) .Or. AFA->(&(aVet[NPOSFILGEN]))) .And. AE8->(MsSeek(cFilAE8+AFA->AFA_RECURS))
			If (nProd := AScan( aVet[NPOSARECUR], { |x,y| x[2]<=AFA->AFA_RECURS .And. AFA->AFA_RECURS<=x[3] .And. x[4]<=AE8->AE8_EQUIP .And. AE8->AE8_EQUIP<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0
				nQuantAFA := PmsPrvAFA(AFA->(RecNo()),StoD("19800101"),dDtFim,AF9->(RecNo()))
				If (nRProd := AScan(aRetHrs,{|x,y| x[1] == aVet[NPOSARECUR][nProd][1] .And. x[9] == "01" })) > 0
					aRetHrs[nRProd][5] += nQuantAFA
					aRetHrs[nRProd][6] += nQuantAFA * AFA->AFA_CUSTD
				Else
					AAdd(aRetHrs,{ aVet[NPOSARECUR][nProd][1], Space(nTamRecur), 0, 0, nQuantAFA, nQuantAFA * AFA->AFA_CUSTD, 0, 0 , "01"} )
				EndIf
				
				If (nRProd := AScan(aRetHrs,{|x,y| x[1]+x[2] == aVet[NPOSARECUR][nProd][1]+AFA->AFA_RECURS .And. x[9] == "02" })) > 0
					aRetHrs[nRProd][5] += nQuantAFA
					aRetHrs[nRProd][6] += nQuantAFA * AFA->AFA_CUSTD
				Else
					AAdd(aRetHrs,{ aVet[NPOSARECUR][nProd][1], AFA->AFA_RECURS, 0, 0, nQuantAFA, nQuantAFA * AFA->AFA_CUSTD, 0, 0 , "02"} )
				EndIf
			EndIf
		EndIf
			
		AFA->(DbSkip())
	EndDo
EndIf

SD2->(DbSetOrder(4))
AFS->(DbSetOrder(1))
IncProc()
If AFS->(MsSeek(cFilAFS+cProjeto+cRevisa))
	Do While AFS->AFS_FILIAL == cFilAFS .AND. AFS->AFS_PROJET == cProjeto .AND. AFS->AFS_REVISA == cRevisa
		cCodProd := AFS->AFS_COD
		cGruProd := Posicione("SB1",1,cFilSB1+cCodProd,"B1_GRUPO")
		cTarefa  := AFS->AFS_TAREFA
		nTpAFA   := 1
		If SD2->(MsSeek(cFilSD2+AFS->AFS_NUMSEQ))

			cTes := VeTES(SD2->D2_TES)
			aRelImp2 := MaFisRelImp("MT100",{ "SD2" })

			Do While nTpAFA < 3

				If Substr(cTes,6,1) == StrZero(nTpAFA,1) .And. ((Substr(cTes,1,1) == "S" .And. Substr(cTes,6,1) == "1") .Or. Substr(cTes,6,1) == "2") .And. Empty(aVet[NPOSFILGEN]) .Or. AFS->(&(aVet[NPOSFILGEN]))
					If (nProd := AScan( aVet[NPOSAPRODS], { |x,y| x[2]<=cCodProd .And. cCodProd<=x[3] .And. x[4]<=cGruProd .And. cGruProd<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0

						nValSD2    := Iif(nTpAFA == 1,SD2->D2_TOTAL,SD2->D2_CUSTO1)
						nPsVlPisSa := 0
						nValCofins := 0
						If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
							nPsVlPisSa := SD2->( FieldGet( FieldPos(aRelImp2[nScanPis,2]) ) )
						EndIf
						If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
							nValCofins := SD2->( FieldGet( FieldPos(aRelImp2[nScanCof,2]) ) )
						EndIf
					
						If (nRProdTot := AScan(aRet,{|x,y| x[1] == aVet[NPOSAPRODS][nProd][1] .And. x[10] == StrZero(nTpAFA,1) + "1" })) > 0
							aRet[nRProdTot][7] += SD2->D2_QUANT
							aRet[nRProdTot][8] += nValSD2

							aRet[nRProdTot][9][3][1] += SD2->D2_VALICM
							aRet[nRProdTot][9][3][2] += SD2->D2_VALIPI
							aRet[nRProdTot][9][3][3] += SD2->D2_VALISS
							aRet[nRProdTot][9][3][4] += nPsVlPisSa
							aRet[nRProdTot][9][3][5] += nValCofins

						Else
							AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], Space(nTamProd), 0, 0, 0, 0, SD2->D2_QUANT, nValSD2,;
							            { {0,0,0,0,0},{0,0,0,0,0},;
							            	{ SD2->D2_VALICM, SD2->D2_VALIPI, SD2->D2_VALISS, nPsVlPisSa, nValCofins} },;
							            StrZero(nTpAFA,1) + "1" })
						EndIf
	
						If (nRProd := AScan(aRet,{|x,y| x[1]+x[2] == aVet[NPOSAPRODS][nProd][1] + AFS->AFS_COD .And. x[10] == StrZero(nTpAFA,1) + "2" })) > 0
							aRet[nRProd][7] += SD2->D2_QUANT
							aRet[nRProd][8] += nValSD2

							aRet[nRProd][9][3][1] += SD2->D2_VALICM
							aRet[nRProd][9][3][2] += SD2->D2_VALIPI
							aRet[nRProd][9][3][3] += SD2->D2_VALISS
							aRet[nRProd][9][3][4] += nPsVlPisSa
							aRet[nRProd][9][3][5] += nValCofins

						Else
							AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], AFS->AFS_COD, 0, 0, 0, 0, SD2->D2_QUANT, nValSD2,;
							            { {0,0,0,0,0},{0,0,0,0,0},;
							            	{ SD2->D2_VALICM, SD2->D2_VALIPI, SD2->D2_VALISS, nPsVlPisSa, nValCofins} },;
							            StrZero(nTpAFA,1) + "2" })
						EndIf
					EndIf
				EndIf
				nTpAFA++
			
			EndDo
		EndIf
		AFS->(DbSkip())
	EndDo
EndIf

SD1->(DbSetOrder(1))
AFN->(DbSetOrder(1))
IncProc()
If AFN->(MsSeek(cFilAFN+cProjeto+cRevisa))
	Do While AFN->AFN_FILIAL == cFilAFN .AND. AFN->AFN_PROJET == cProjeto .AND. AFN->AFN_REVISA == cRevisa

		cCodProd := AFN->AFN_COD
		cGruProd := Posicione("SB1",1,cFilSB1+cCodProd,"B1_GRUPO")
		cTarefa  := AFN->AFN_TAREFA
		nTpAFA   := 2
		If SD1->(MsSeek(cFilSD1+AFN->AFN_DOC+AFN->AFN_SERIE+AFN->AFN_FORNEC+AFN->AFN_LOJA+AFN->AFN_COD+AFN->AFN_ITEM))

			If Empty(aVet[NPOSFILGEN]) .Or. AFN->(&(aVet[NPOSFILGEN]))
				If (nProd := AScan( aVet[NPOSAPRODS], { |x,y| x[2]<=cCodProd .And. cCodProd<=x[3] .And. x[4]<=cGruProd .And. cGruProd<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0

					Do While nTpAFA < 3
						
						nQtdSD1 := PmsAFNQUANT("QUANT")
						nValSD1 := ( SD1->D1_CUSTO / SD1->D1_QUANT ) * nQtdSD1
						If (nRProdTot := AScan(aRet,{|x,y| x[1] == aVet[NPOSAPRODS][nProd][1] .And. x[10] == StrZero(nTpAFA,1) + "1" })) > 0
							aRet[nRProdTot][7] += nQtdSD1
							aRet[nRProdTot][8] += nValSD1
						Else
							AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], Space(nTamProd), 0, 0, 0, 0, nQtdSD1, nValSD1,;
							            { {0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0} },;
							            StrZero(nTpAFA,1) + "1" })
						EndIf
						If (nRProd := AScan(aRet,{|x,y| x[1]+x[2] == aVet[NPOSAPRODS][nProd][1] + AFN->AFN_COD .And. x[10] == StrZero(nTpAFA,1) + "2" })) > 0
							aRet[nRProd][7] += nQtdSD1
							aRet[nRProd][8] += nValSD1
						Else
							AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], AFN->AFN_COD, 0, 0, 0, 0, nQtdSD1, nValSD1,;
							            { {0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0} },;
							            StrZero(nTpAFA,1) + "2" })
						EndIf

						nTpAFA++
					EndDo
				EndIf
			EndIf
		EndIf

		AFN->(DbSkip())
	EndDo
EndIf

DbSelectArea("AJC")
AJC->(DbSetOrder(1))
IncProc()
If AJC->(MsSeek(cFilAJC+"1"+cProjeto+cRevisa))
	Do While AJC->AJC_FILIAL == cFilAJC .AND. AJC->AJC_PROJET == cProjeto .AND. AJC->AJC_REVISA == cRevisa

		cCodProd := AJC->AJC_COD
		cGruProd := Posicione("SB1",1,cFilSB1+cCodProd,"B1_GRUPO")
		cTarefa  := AJC->AJC_TAREFA
		nTpAFA   := 2
		If Empty(aVet[NPOSFILGEN]) .Or. AJC->(&(aVet[NPOSFILGEN]))
			If (nProd := AScan( aVet[NPOSAPRODS], { |x,y| x[2]<=cCodProd .And. cCodProd<=x[3] .And. x[4]<=cGruProd .And. cGruProd<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0

				Do While nTpAFA < 3
					nValAJC := ( AJC->AJC_CUSTO1 / AJC->AJC_QUANT )// * nQtdAJC
					If (nRProdTot := AScan(aRet,{|x,y| x[1] == aVet[NPOSAPRODS][nProd][1] .And. x[10] == StrZero(nTpAFA,1) + "1" })) > 0
						aRet[nRProdTot][7] += AJC->AJC_QUANT
						aRet[nRProdTot][8] += nValAJC
					Else
						AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], Space(nTamProd), 0, 0, 0, 0, AJC->AJC_QUANT, nValAJC, { {0,0,0,0,0},{0,0,0,0,0}, {0,0,0,0,0} }, StrZero(nTpAFA,1) + "1" } )
					EndIf
					If (nRProd := AScan(aRet,{|x,y| x[1]+x[2] == aVet[NPOSAPRODS][nProd][1] + AJC->AJC_COD .And. x[10] == StrZero(nTpAFA,1) + "2" })) > 0
						aRet[nRProd][7] += AJC->AJC_QUANT
						aRet[nRProd][8] += nValAJC
					Else
						AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], AJC->AJC_COD, 0, 0, 0, 0, AJC->AJC_QUANT, nValAJC, { {0,0,0,0,0},{0,0,0,0,0}, {0,0,0,0,0} }, StrZero(nTpAFA,1) + "2" } )
					EndIf
					nTpAFA++
				EndDo
			EndIf
		EndIf

		AJC->(DbSkip())
	EndDo
EndIf

SD3->(DbSetOrder(4))
AFI->(DbSetOrder(1))
IncProc()
If AFI->(MsSeek(cFilAFI+cProjeto+cRevisa))
	Do While AFI->AFI_FILIAL == cFilAFI .AND. AFI->AFI_PROJET == cProjeto .AND. AFI->AFI_REVISA == cRevisa
		cCodProd := AFI->AFI_COD
		cGruProd := Posicione("SB1",1,cFilSB1+cCodProd,"B1_GRUPO")
		cTarefa  := AFI->AFI_TAREFA
		nTpAFA   := 2
		If SD3->(MsSeek(cFilSD3+AFI->AFI_NUMSEQ))

			If Empty(aVet[NPOSFILGEN]) .Or. AFI->(&(aVet[NPOSFILGEN]))
				If (nProd := AScan( aVet[NPOSAPRODS], { |x,y| x[2]<=cCodProd .And. cCodProd<=x[3] .And. x[4]<=cGruProd .And. cGruProd<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0

					Do While nTpAFA < 3
						
						nQtdSD3 := AFI->AFI_QUANT * Iif(SD3->D3_TM > "500",1,-1)
						nValSD3 := ( SD3->D3_CUSTO1 / SD3->D3_QUANT ) * nQtdSD3
						
						If (nRProdTot := AScan(aRet,{|x,y| x[1] == aVet[NPOSAPRODS][nProd][1] .And. x[10] == StrZero(nTpAFA,1) + "1" })) > 0
							aRet[nRProdTot][7] += nQtdSD3
							aRet[nRProdTot][8] += nValSD3
						Else
							AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], Space(nTamProd), 0, 0, 0, 0, nQtdSD3, nValSD3, { {0,0,0,0,0},{0,0,0,0,0}, {0,0,0,0,0} }, StrZero(nTpAFA,1) + "1" } )
						EndIf
	
						If (nRProd := AScan(aRet,{|x,y| x[1]+x[2] == aVet[NPOSAPRODS][nProd][1] + AFI->AFI_COD .And. x[10] == StrZero(nTpAFA,1) + "2" })) > 0
							aRet[nRProd][7] += nQtdSD3
							aRet[nRProd][8] += nValSD3
						Else
							AAdd(aRet,{ aVet[NPOSAPRODS][nProd][1], AFI->AFI_COD, 0, 0, 0, 0, nQtdSD3, nValSD3, { {0,0,0,0,0},{0,0,0,0,0}, {0,0,0,0,0} }, StrZero(nTpAFA,1) + "2" } )
						EndIf

						nTpAFA++
			
					EndDo
				EndIf
			EndIf
		EndIf
		AFI->(DbSkip())
	EndDo
EndIf

AFU->(DbSetOrder(1))
IncProc()
If AFU->(MsSeek(cFilAFU+"1"+cProjeto+cRevisa))
	Do While AFU->AFU_FILIAL == cFilAFU .AND. AFU->AFU_CTRRVS == "1" .AND. AFU->AFU_PROJET == cProjeto .AND. AFU->AFU_REVISA == cRevisa

		If (Empty(aVet[NPOSFILGEN]) .Or. AFU->(&(aVet[NPOSFILGEN]))) .And. AE8->(MsSeek(cFilAE8+AFU->AFU_RECURS))
			If (nProd := AScan( aVet[NPOSARECUR], { |x,y| x[2]<=AFU->AFU_RECURS .And. AFU->AFU_RECURS<=x[3] .And. x[4]<=AE8->AE8_EQUIP .And. AE8->AE8_EQUIP<=x[5] .And. (Empty(x[6]) .Or. &(x[6])) }) ) > 0
				If (nRProd := AScan(aRetHrs,{|x,y| x[1] == aVet[NPOSARECUR][nProd][1] .And. x[9] == "01" })) > 0
					aRetHrs[nRProd][7] += AFU->AFU_HQUANT
					aRetHrs[nRProd][8] += AFU->AFU_CUSTO1
				Else
					AAdd(aRetHrs,{ aVet[NPOSARECUR][nProd][1], Space(nTamRecur), 0, 0, 0, 0, AFU->AFU_HQUANT, AFU->AFU_CUSTO1 , "01"} )
				EndIf
				
				If (nRProd := AScan(aRetHrs,{|x,y| x[1]+x[2] == aVet[NPOSARECUR][nProd][1]+AFU->AFU_RECURS .And. x[9] == "02" })) > 0
					aRetHrs[nRProd][7] += AFU->AFU_HQUANT
					aRetHrs[nRProd][8] += AFU->AFU_CUSTO1
				Else
					AAdd(aRetHrs,{ aVet[NPOSARECUR][nProd][1], AFU->AFU_RECURS, 0, 0, 0, 0, AFU->AFU_HQUANT, AFU->AFU_CUSTO1 , "02"} )
				EndIf
			EndIf
		EndIf

		AFU->(DbSkip())
	EndDo
EndIf

AFB->(DbSetOrder(1))
IncProc()
If AFB->(MsSeek(cFilAFB+cProjeto+cRevisa))
	Do While AFB->AFB_FILIAL == cFilAFB .AND. AFB->AFB_PROJET == cProjeto .AND. AFB->AFB_REVISA == cRevisa
	
		If Empty(aVet[NPOSFILGEN]) .Or. AFB->(&(aVet[NPOSFILGEN]))
			If (nProd := AScan( aVet[NPOSADESPE], { |x,y| x[2]<=AFB->AFB_TIPOD .And. AFB->AFB_TIPOD<=x[3] .And. (Empty(x[4]) .Or. &(x[4])) }) ) > 0
				If (nRProd := AScan(aRetDes,{|x,y| x[1] == aVet[NPOSADESPE][nProd][1] .And. x[9] == "01" })) > 0
					aRetDes[nRProd][5] += 1
					aRetDes[nRProd][6] += AFB->AFB_VALOR
				Else
					AAdd(aRetDes,{ aVet[NPOSADESPE][nProd][1], Space(nTamRecur), 0, 0, 1, AFB->AFB_VALOR, 0, 0, "01"} )
				EndIf
				
				If (nRProd := AScan(aRetDes,{|x,y| x[1]+x[2] == aVet[NPOSADESPE][nProd][1]+AFB->AFB_TIPOD .And. x[9] == "02" })) > 0
					aRetDes[nRProd][5] += 1
					aRetDes[nRProd][6] += AFB->AFB_VALOR
				Else
					AAdd(aRetDes,{ aVet[NPOSADESPE][nProd][1], AFB->AFB_TIPOD, 0, 0, 1, AFB->AFB_VALOR, 0, 0, "02"} )
				EndIf
			EndIf
		EndIf

		AFB->(DbSkip())
	EndDo
EndIf

AFR->(DbSetOrder(1))
IncProc()
If AFR->(MsSeek(cFilAFR+cProjeto+cRevisa))
	Do While AFR->AFR_FILIAL == cFilAFR .AND. AFR->AFR_PROJET  == cProjeto .AND. AFR->AFR_REVISA == cRevisa

		If Empty(aVet[NPOSFILGEN]) .Or. AFR->(&(aVet[NPOSFILGEN]))
			If (nProd := AScan( aVet[NPOSADESPE], { |x,y| x[2]<=AFR->AFR_TIPOD .And. AFR->AFR_TIPOD<=x[3] .And. (Empty(x[4]) .Or. &(x[4])) }) ) > 0
				If (nRProd := AScan(aRetDes,{|x,y| x[1] == aVet[NPOSADESPE][nProd][1] .And. x[9] == "01" })) > 0
					aRetDes[nRProd][5] += 1
					aRetDes[nRProd][6] += AFR->AFR_VALOR1
				Else
					AAdd(aRetDes,{ aVet[NPOSADESPE][nProd][1], Space(nTamRecur), 0, 0, 0, 0, 1, AFR->AFR_VALOR1, "01"} )
				EndIf
				
				If (nRProd := AScan(aRetDes,{|x,y| x[1]+x[2] == aVet[NPOSADESPE][nProd][1]+AFR->AFR_TIPOD .And. x[9] == "02" })) > 0
					aRetDes[nRProd][5] += 1
					aRetDes[nRProd][6] += AFR->AFR_VALOR1
				Else
					AAdd(aRetDes,{ aVet[NPOSADESPE][nProd][1], AFR->AFR_TIPOD, 0, 0, 0, 0, 1, AFR->AFR_VALOR1, "02"} )
				EndIf
			EndIf
		EndIf

		AFR->(DbSkip())
	EndDo
EndIf

IncProc()

If Len(aRetHrs) > 0
	lRet := .T.
	ASort(aRetHrs,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
EndIf

If Len(aRet) > 0
	lRet := .T.
	ASort(aRet,,,{|x,y| Left(x[10],1)+x[1]+x[2] < Left(y[10],1)+y[1]+y[2] })
EndIf

AE8->(RestArea(aAreaAE8))
SB1->(RestArea(aAreaSB1))
SD3->(RestArea(aAreaSD3))
SD2->(RestArea(aAreaSD2))
SD1->(RestArea(aAreaSD1))
SC6->(RestArea(aAreaSC6))
AFS->(RestArea(aAreaAFS))
AFN->(RestArea(aAreaAFN))
AFI->(RestArea(aAreaAFI))
AF9->(RestArea(aAreaAF9))
AFA->(RestArea(aAreaAFA))
AJC->(RestArea(aAreaAJC))

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130TVis ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/12/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Tela com resultado do calculo.                              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PM130TVis(aRecVet,aRetHrs,aRetDes,aConfig,cNomeProj)

Local oDlg			:= Nil
Local oLbx			:= Nil
Local oFont		:= Nil
Local aHeadCols	:= {}
Local aImpostos	:= {{"ICMS",0,0,0},{"IPI",0,0,0},{"ISS",0,0,0},{"PIS",0,0,0},{"COFINS",0,0,0}}
Local aTelaButto	:= {{BMP_EXCEL,     {|| Acols2Xls(aColDte,aHeadCols)},          STR0101},;	//"Exportar p/Excel"
                	    {BMP_EXCEL,     {|| Acols2Xls2(aColDte,aHeadCols,aConfig)}, STR0102},;	//"Formatado"
                	    {BMP_IMPRESSAO, {|| PM130Imp(aConfig,cNomeProj)},           STR0103}}		//"Imprimir"
Local aPosTots	:= {{STR0054, 1, "TOT1"},;	//"TOT1 = FATURAMENTO BRUTO"
              	    {STR0055, 0, "TOT2"},;	//"TOT2 = IMPOSTOS"
              	    {STR0056, 0, "TOT3"},;	//"TOT3 = FATURAMENTO LIQUIDO"
              	    {STR0057, 0, "TOT4"},;	//"TOT4 = CUSTOS DIRETOS"
              	    {STR0058, 0, "TOT5"},;	//"TOT5 = HORAS ALOCADAS"
              	    {STR0059, 0, "TOT6"},;	//"TOT6 = DESPESAS DIRETAS"
              	    {STR0037, 0, "TOT7"},;	//"DESPESAS INDIRETAS"
              	    {STR0070, 0, "TOT8"}}	//"MARGEM"
Local nTop			:= oMainWnd:nTop+35
Local nLeft		:= oMainWnd:nLeft+10
Local nBottom		:= oMainWnd:nBottom-12
Local nRight		:= oMainWnd:nRight-10
Local nTamForm	:= Len(aConfig[NPOSAFROMS])
Local nInd			:= 0
Local cTipoD		:= ""
Local cValCol		:= ""
Local cPictQtd	:= "@E 999,999,999,999.99"
Local cPictVal	:= "@E 999,999,999,999.99"
Local cFilSB1		:= xFilial("SB1")
Local cFilAE8		:= xFilial("AE8")
Local cFilSX5		:= xFilial("SX5")

DEFAULT aRecVet	:= {}

Private nCorTot	:= ( aConfig[NPOSACORES][1][2] + ( aConfig[NPOSACORES][1][3] * 256 ) + ( aConfig[NPOSACORES][1][4] * 65536 ) )
Private nCorGrp	:= ( aConfig[NPOSACORES][2][2] + ( aConfig[NPOSACORES][2][3] * 256 ) + ( aConfig[NPOSACORES][2][4] * 65536 ) )
Private nCorDet	:= ( aConfig[NPOSACORES][3][2] + ( aConfig[NPOSACORES][3][3] * 256 ) + ( aConfig[NPOSACORES][3][4] * 65536 ) )
Private aColDte	:= {}
Private cTitulo	:= STR0071 //"ACOMPANHAMENTO DE RENTABILIDADE."

If Len(aRecVet) == 0
	MsgInfo(STR0072) //'N„o h· dados para consulta.'
Else

	Aadd(aHeadCols,{STR0073 ,"COLUNA01","",30,0,,,"C",,"V",,,,"V",,,}) //"GRUPO TOTALIZADOR"
	Aadd(aHeadCols,{STR0074 ,"COLUNA02","",15,0,,,"C",,"V",,,,"V",,,}) //"CODIGO"
	Aadd(aHeadCols,{STR0075 ,"COLUNA03","",50,0,,,"C",,"V",,,,"V",,,}) //"DESCRICAO / NOM"
	Aadd(aHeadCols,{STR0076 ,"COLUNA04","",18,0,,,"N",,"V",,,,"V",,,}) //"QUANTIDADE -VEND"
	Aadd(aHeadCols,{STR0077 ,"COLUNA05","",18,0,,,"N",,"V",,,,"V",,,}) //"R$         -VEND"  
	Aadd(aHeadCols,{STR0078 ,"COLUNA06","",18,0,,,"N",,"V",,,,"V",,,}) //"VALOR TOTAL-VEND"
	Aadd(aHeadCols,{STR0079 ,"COLUNA07","",18,0,,,"N",,"V",,,,"V",,,}) //"QUANTIDADE -PREV"
	Aadd(aHeadCols,{STR0080 ,"COLUNA08","",18,0,,,"N",,"V",,,,"V",,,}) //"R$         -PREV"
	Aadd(aHeadCols,{STR0081 ,"COLUNA09","",18,0,,,"N",,"V",,,,"V",,,}) //"VALOR TOTAL-PREV"
	Aadd(aHeadCols,{STR0082 ,"COLUNA10","",18,0,,,"N",,"V",,,,"V",,,}) //"QUANTIDADE -REAL"
	Aadd(aHeadCols,{STR0083 ,"COLUNA11","",18,0,,,"N",,"V",,,,"V",,,}) //"R$         -REAL"
	Aadd(aHeadCols,{STR0084 ,"COLUNA12","",18,0,,,"N",,"V",,,,"V",,,}) //"VALOR TOTAL-REAL"

	AAdd(aColDte,{aPosTots[1][1],"","","","",0,"","",0,"","",0,.F.})

	AEval(aRecVet, {|x,y| If( Left(x[10],1) == "1",;
	                          ( If( aConfig[NPOSDETFAT] == "1" .Or. (aConfig[NPOSDETFAT] == "2" .And. Right(x[10],1) == "1" ),;
	                                AAdd(aColDte, { Iif(Right(x[10],1) == "1",x[1],""),;		 											//Totalizador de Grupo
	                                                    Iif(Right(x[10],1) == "2",x[2],""),;												//Produto
	                                                    Iif(Right(x[10],1) == "2",Posicione("SB1",1,cFilSB1+x[2],"B1_DESC"),""),;		//Descricao
	                                                    Transform(x[3], cPictQtd),;															//Qtd.
	                                                    Transform(Iif(x[3]>0,x[4]/x[3],0), cPictVal),;									//Val. Unit. (media)
	                                                    Transform(x[4], cPictVal),;															//Val. Total
	                                                    Transform(x[5], cPictQtd),;															//Qtd.
	                                                    Transform(Iif(x[5]>0,x[6]/x[5],0), cPictVal),;									//Val. Unit. (media)
	                                                    Transform(x[6], cPictVal),;															//Val. Total
	                                                    Transform(x[7], cPictQtd),;															//Qtd.
	                                                    Transform(Iif(x[7]>0,x[8]/x[7],0), cPictVal),;									//Val. Unit. (media)
	                                                    Transform(x[8], cPictVal), .F.}),),;	 											//Val. Total
	                            If(Right(x[10],1) == "2",;
	                               ( aImpostos[1][2] += x[9][1][1],; //ICMS
	                                 aImpostos[2][2] += x[9][1][2],; //IPI
	                                 aImpostos[3][2] += x[9][1][3],; //ISS
	                                 aImpostos[4][2] += x[9][1][4],; //COFINS
	                                 aImpostos[5][2] += x[9][1][5],; //PIS
	                                 aImpostos[1][3] += x[9][2][1],; //ICMS
	                                 aImpostos[2][3] += x[9][2][2],; //IPI
	                                 aImpostos[3][3] += x[9][2][3],; //ISS
	                                 aImpostos[4][3] += x[9][2][4],; //COFINS
	                                 aImpostos[5][3] += x[9][2][5],; //PIS
	                                 aImpostos[1][4] += x[9][3][1],; //ICMS
	                                 aImpostos[2][4] += x[9][3][2],; //IPI
	                                 aImpostos[3][4] += x[9][3][3],; //ISS
	                                 aImpostos[4][4] += x[9][3][4],; //COFINS
	                                 aImpostos[5][4] += x[9][3][5] ),; //PIS
	                               ( aColDte[aPosTots[1][2]][6]  += x[4],;
	                                 aColDte[aPosTots[1][2]][9]  += x[6],;
	                                 aColDte[aPosTots[1][2]][12] += x[8] )) ), ) })

	AAdd(aColDte, {aPosTots[2][1],"","","","",0,"","",0,"","",0,.F. } )
	aPosTots[2][2] := Len(aColDte)

	AEval(aImpostos, {|x,y| If(aConfig[NPOSDETIMP] == "1",;
	                           AAdd(aColDte, {"",;
	                                          x[1],;
	                                          "",;
	                                          "",;
	                                          "",;
	                                          Transform(x[2], cPictVal),;
	                                          "",;
	                                          "",;
	                                          Transform(x[3], cPictVal),;
	                                          "",;
	                                          "",;
	                                          Transform(x[4], cPictVal),;
	                                          .F.}),),;
	                        aColDte[aPosTots[2][2]][6] += x[2], aColDte[aPosTots[2][2]][9] += x[3], aColDte[aPosTots[2][2]][12] += x[4], })

	AAdd(aColDte, {aPosTots[3][1],"","","","",;
	               aColDte[aPosTots[1][2]][6]-aColDte[aPosTots[2][2]][6],"","",;
	               aColDte[aPosTots[1][2]][9]-aColDte[aPosTots[2][2]][9],"","",;
	               aColDte[aPosTots[1][2]][12]-aColDte[aPosTots[2][2]][12],.F. } )
	aPosTots[3][2] := Len(aColDte)

	AAdd(aColDte, {aPosTots[4][1],"","","","",0,"","",0,"","",0,.F. } )
	aPosTots[4][2] := Len(aColDte)
	
	AEval(aRecVet, {|x,y| If( Left(x[10],1) == "2",;
	                          ( If( aConfig[NPOSDETCST] == "1" .Or. (aConfig[NPOSDETCST] == "2" .And. Right(x[10],1) == "1"),;
	                                AAdd(aColDte, { Iif(Right(x[10],1) == "1",x[1],""),;		 										//Totalizador de Grupo
	                                                Iif(Right(x[10],1) == "2",x[2],""),;							 					//Produto
	                                                Iif(Right(x[10],1) == "2",Posicione("SB1",1,cFilSB1+x[2],"B1_DESC"),""),;		//Descricao
	                                                Transform(x[3], cPictQtd),;															//Qtd.
	                                                Transform(Iif(x[3]>0,x[4]/x[3],0), cPictVal),;										//Val. Unit. (media)
	                                                Transform(x[4], cPictVal),;															//Val. Total
	                                                Transform(x[5], cPictQtd),;															//Qtd.
	                                                Transform(Iif(x[5]>0,x[6]/x[5],0), cPictVal),;										//Val. Unit. (media)
	                                                Transform(x[6], cPictVal),;															//Val. Total
	                                                Transform(x[7], cPictQtd),;															//Qtd.
	                                                Transform(Iif(x[7]>0,x[8]/x[7],0), cPictVal),;										//Val. Unit. (media)
	                                                Transform(x[8], cPictVal),.F. }) ,),;												//Val. Total
	                            If( Right(x[10],1) == "1",;
	                                ( aColDte[aPosTots[4][2]][6]  += x[4],;
	                                  aColDte[aPosTots[4][2]][9]  += x[6],;
	                                  aColDte[aPosTots[4][2]][12] += x[8] ), ) ), )})
	
	AAdd(aColDte, {aPosTots[5][1],"","","","",0,"","",0,"","",0,.F. } )
	aPosTots[5][2] := Len(aColDte)
	
	AEval(aRetHrs, {|x,y| If( aConfig[NPOSDETHRS] == "1" .Or. (aConfig[NPOSDETHRS] == "2" .And. x[9] == "01" ),;
	                          AAdd(aColDte, { Iif(x[9] == "01", x[1], ""),;		 							//Totalizador
			                                   Iif(x[9] == "02", x[2], ""),;									//Analista
			                                   FATPDObfuscate(Posicione("AE8",1,cFilAE8+x[2],"AE8_DESCRI"),"AE8_DESCRI",,.T.),;				//Nome
			                                   Transform(x[3], cPictQtd),;										//Qtd.
			                                   Transform(Iif(x[3]>0,x[4]/x[3],0), cPictVal),;				//Val. Unit. (media)
			                                   Transform(x[4], cPictVal),;					 					//Val. Total
			                                   Transform(x[5], cPictQtd),;										//Qtd.
			                                   Transform(Iif(x[5]>0,x[6]/x[5],0), cPictVal),;				//Val. Unit. (media)
			                                   Transform(x[6], cPictVal),;										//Val. Total
			                                   Transform(x[7], cPictQtd),;										//Qtd.
			                                   Transform(Iif(x[7]>0,x[8]/x[7],0), cPictVal),;				//Val. Unit. (media)
			                                   Transform(x[8], cPictVal),.F. }), ),;							//Val. Total
	                      If( x[9] == "01",;
	                          ( aColDte[aPosTots[5][2]][6]  += x[4],;
	                            aColDte[aPosTots[5][2]][9]  += x[6],;
	                            aColDte[aPosTots[5][2]][12] += x[8]), )} )  

	AAdd(aColDte, {aPosTots[6][1],"","","","",0,"","",0,"","",0,.F. } )
	aPosTots[6][2] := Len(aColDte)
	
	AEval(aRetDes, {|x,y| cTipoD := x[2],;
	                      If( aConfig[NPOSDETDDI] == "1" .Or. (aConfig[NPOSDETDDI] == "2" .And. x[9] == "01"),;
	                          AAdd(aColDte,{ Iif(x[9] == "01",x[1],""),;		 													//Totalizador
	                                         Iif(x[9] == "02",x[2],""),;															//Despesa
	                                         Eval({|| If(SX5->(DbSeek(cFilSX5+"FD"+cTipoD)),AllTrim(X5Descri()),"")}),;		//Descricao
	                                         Transform(x[3], cPictQtd),;															//Qtd.
	                                         Transform(Iif(x[3]>0,x[4]/x[3],0), cPictVal),;										//Val. Unit. (media)
	                                         Transform(x[4], cPictVal),;								 							//Val. Total
	                                         Transform(x[5], cPictQtd),;															//Qtd.
	                                         Transform(Iif(x[5]>0,x[6]/x[5],0), cPictVal),;										//Val. Unit. (media)
	                                         Transform(x[6], cPictVal),;															//Val. Total
	                                         Transform(x[7], cPictQtd),;															//Qtd.
	                                         Transform(Iif(x[7]>0,x[8]/x[7],0), cPictVal),;										//Val. Unit. (media)
	                                         Transform(x[8], cPictVal),.F. }) ,),;												//Val. Total
	                          If(x[9] == "01",;
	                             ( aColDte[aPosTots[6][2]][6]  += x[4],;
	                               aColDte[aPosTots[6][2]][9]  += x[6],;
	                               aColDte[aPosTots[6][2]][12] += x[8] ),)})

	AAdd(aColDte, {aPosTots[7][1],"","","","",0,"","",0,"","",0,.F. } )
	aPosTots[7][2] := Len(aColDte)

	If nTamForm > 0 .And. !Empty(aConfig[NPOSAFROMS][1][1])
		For nInd := 1 To nTamForm
			cValCol := AllTrim(aConfig[NPOSAFROMS][nInd][2])
			AEval(aPosTots,{|x,y| cValCol := StrTran(cValCol,x[3],"aColDte["+StrZero(x[2],5)+"][<nCol>]") })
			If aConfig[NPOSDETDIN] == "1"
				AAdd(aColDte, {aConfig[NPOSAFROMS][nInd][1],;
				               "FORMULA",;
				               AllTrim(aConfig[NPOSAFROMS][nInd][2]),;
				               "",;
				               "",;
				               Transform(&(StrTran(cValCol,"<nCol>","6")), cPictVal),;
				               "",;
				               "",;
				               Transform(&(StrTran(cValCol,"<nCol>","9")), cPictVal),;
				               "",;
				               "",;
				               Transform(&(StrTran(cValCol,"<nCol>","12")), cPictVal),;
				               .F.} )
			EndIf
			aColDte[aPosTots[7][2]][6]  += &(StrTran(cValCol,"<nCol>","6"))
			aColDte[aPosTots[7][2]][9]  += &(StrTran(cValCol,"<nCol>","9"))
			aColDte[aPosTots[7][2]][12] += &(StrTran(cValCol,"<nCol>","12"))
		Next nInd
	EndIf

	AAdd(aColDte, {aPosTots[8][1],"","","","",0,"","",0,"","",0,.F. } )
	aPosTots[8][2] := Len(aColDte)

	aColDte[aPosTots[8][2]][6] := ( aColDte[aPosTots[1][2]][6];
	                                - aColDte[aPosTots[2][2]][6];
	                                - aColDte[aPosTots[4][2]][6];
	                                - aColDte[aPosTots[5][2]][6];
	                                - aColDte[aPosTots[6][2]][6];
	                                - aColDte[aPosTots[7][2]][6] )

	aColDte[aPosTots[8][2]][9] := ( aColDte[aPosTots[1][2]][9];
	                                - aColDte[aPosTots[2][2]][9];
	                                - aColDte[aPosTots[4][2]][9];
	                                - aColDte[aPosTots[5][2]][9];
	                                - aColDte[aPosTots[6][2]][9];
	                                - aColDte[aPosTots[7][2]][9] )

	aColDte[aPosTots[8][2]][12] := ( aColDte[aPosTots[1][2]][12];
	                                 - aColDte[aPosTots[2][2]][12];
	                                 - aColDte[aPosTots[4][2]][12];
	                                 - aColDte[aPosTots[5][2]][12];
	                                 - aColDte[aPosTots[6][2]][12];
	                                 - aColDte[aPosTots[7][2]][12] )

	AEval(aPosTots,{|x,y| aColDte[x[2]][6]   := Transform(aColDte[x[2]][6],  cPictVal),;
	                      aColDte[x[2]][9]   := Transform(aColDte[x[2]][9],  cPictVal),;
	                      aColDte[x[2]][12]  := Transform(aColDte[x[2]][12], cPictVal)} )
	
	oDlg := MSDialog():New(nTop,nLeft,nBottom-80,nRight,cTitulo,,,,,,,,,.T.,,,)
	oDlg:lMaximized := .T.
	
	oFont := TFont():New( "Arial", 0, -10, ,,,,,,,,,,,,)
	
	oLbx := MsNewGetDados():New(14,02,oDlg:nBottom,oDlg:nRight/2-8,0,,,,,,9999,,,,oDlg,aHeadCols,aColDte)
	oLbx:oBrowse:lUseDefaultcolors := .F.
	oLbx:oBrowse:SetBlkBackColor({|| PM130Color(oLbx:aCols,oLbx:nAt,nCorTot,nCorGrp,nCorDet) })
	oLbx:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oLbx:oBrowse:oFont:=oFont

	oDlg:Activate(,,,,EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()},,aTelaButto), ,)

EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥VeTES     ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/12/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna as propriedades do TES onde:                       ∫±±
±±∫          ≥1 = Gera Duplicata                                          ∫±±
±±∫          ≥2 = ICMS                                                    ∫±±
±±∫          ≥3 = IPI                                                     ∫±±
±±∫          ≥4 = ISS                                                     ∫±±
±±∫          ≥5 = Movimenta Estoque                                       ∫±±
±±∫          ≥6 = Mov. Proj. (123)                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VeTES(cCod)

Local cRet     := "NNNNN3"
Local aAreaSF4 := SF4->(GetArea())

DEFAULT cCod := ""

If !Empty(cCod)
	SF4->(DbSetOrder(1))
	If SF4->(MsSeek(xFilial("SF4")+cCod))
		cRet := SF4->F4_DUPLIC+SF4->F4_CREDICM+SF4->F4_CREDIPI+SF4->F4_ISS+SF4->F4_ESTOQUE+SF4->F4_MOVPRJ
	EndIf
EndIf

SF4->(RestArea(aAreaSF4))
Return cRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130Color∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/26/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Retorna a Cor do Browse.                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PM130Color(aVet,nLAt,nCor1,nCor2,nCor3)

Local nRet

DEFAULT nCor1 := 16765864
DEFAULT nCor2 := 13827795
DEFAULT nCor3 := 16777210

nRet := nCor3

If !Empty(aVet[nLAt][1]) .And. !Empty(aVet[nLAt][2])
	nRet := nCor3 //Formulas
ElseIf !Empty(aVet[nLAt][1]) .And. !Empty(aVet[nLAt][4])
	nRet := nCor2 //Grupo
Elseif !Empty(aVet[nLAt][1]) .And. Empty(aVet[nLAt][4])
	nRet := nCor1 //Totalizador
EndIf
Return nRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Acols2Xls ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  04/26/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Transforma aCols para XLS.                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Acols2Xls(aColsXLS,aHeadXLS)

Local cArquivo := CriaTrab(,.F.) + ".csv"
Local nHandle  := 0
Local cDirDocs := MsDocPath()
Local cBarra   := If(issrvunix(), "/", "\")
Local cPath    := AllTrim(GetTempPath())

Local aVetTMP  := {}
Local aVetXLS  := {}
Local lArqLocal := ExistBlock("DIRDOCLOC")

DEFAULT aColsXLS := Iif(Type("aCols")=="A"  ,aCols  ,{})
DEFAULT aHeadXLS := Iif(Type("aHeader")=="A",aHeader,{})

If Len(aColsXLS) == 0
	MsgAlert(STR0085) //"N„o encontrei dados para geraÁ„o da planilha!"
	Return
EndIf

If !ApOleClient("MsExcel")
	MsgAlert(STR0086) //"Microsoft Excel nao instalado!"
	Return
EndIf

If Len(aHeadXLS) > 0
	AEval(aHeadXLS,{|x,y| AAdd(aVetTMP,x[1]) })
	AAdd(aVetXLS,aVetTMP)
EndIf

AEval(aColsXLS,{|x,y| If(!x[Len(x)],AAdd(aVetXLS,x),) })

If lArqLocal
	nHandle := FCreate(cPath + cBarra + cArquivo)
Else
	nHandle := FCreate(cDirDocs + cBarra + cArquivo)
Endif

If nHandle == -1
	MsgAlert(STR0087) //"A planilha n„o pode ser exportada."
	Return
EndIf

AEval(aVetXLS,{|x,y| AEval(x,{|w,z| If(ValType(w)=="C",FWrite(nHandle, w+';' ),If(ValType(w)=="N",FWrite(nHandle, Str(w)+';' ),If(ValType(w)=="D",FWrite(nHandle, DtoC(w)+';' ),))) }) , FWrite(nHandle, CRLF ) })

FClose(nHandle)

// copia o arquivo do servidor para o remote
If !lArqLocal
	CpyS2T(cDirDocs + cBarra + cArquivo, cPath, .T.)
Endif

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath + cArquivo)
oExcelApp:SetVisible(.T.)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130Palet ∫Autor ≥Carlos A. Gomes Jr. ∫ Data ≥  05/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Exibe a Paleta de cores para definicao do Browse.           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PM130Palet(oGDLDQ0,lFuncPale)

Local nColorR := oGDLDQ0:aCols[oGDLDQ0:nAt][2]
Local nColorG := oGDLDQ0:aCols[oGDLDQ0:nAt][3]
Local nColorB := oGDLDQ0:aCols[oGDLDQ0:nAt][4]

DEFAULT lFuncPale := .T.

lFuncPale := .F.

PgrSelColor(@nColorR,@nColorG,@nColorB)

lFuncPale := .T.

oGDLDQ0:aCols[oGDLDQ0:nAt][2] := nColorR
oGDLDQ0:aCols[oGDLDQ0:nAt][3] := nColorG
oGDLDQ0:aCols[oGDLDQ0:nAt][4] := nColorB

oGDLDQ0:Refresh()

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PM130Imp  ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  05/10/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Relatorio grafico.                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PM130Imp(aConfig,cNomeProj)

Local lEnd	    := .F.
Local lImpOk    := .F.
Local oPrint    := PcoPrtIni(cTitulo,.T.,2,,@lImpOk,"PMSC130")

If lImpOk
	RptStatus( {|lEnd| AuPM130Imp(lEnd,oPrint,aConfig,cNomeProj) })
	PcoPrtEnd(oPrint)
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PMSc130   ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  05/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao auxiliar de impressao.                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function AuPM130Imp(lEnd,oPrint,aConfig,cNomeProj)

Local nX
Local aPosCol	:= {}
Local nLin		:= 10000

SetRegua(Len(aColDte))

For nX := 1 To Len(aColDte)
	IncRegua()
	If PcoPrtLim(nLin)
		nLin	:= 200
		PcoPrtCab(oPrint)
		nLin	+= 20

		aPosCol := {600,2870}
		PcoPrtCol(aPosCol,.T.,12)
		PcoPrtCell(PcoPrtPos(01),nLin,PcoPrtTam(01),60,cNomeProj,oPrint,2,2,RGB(230,230,230),,) //Nome do Projeto
		nLin	+= 70
				
		aPosCol := {220,400,600, 1390,1560,1730, 1960,2130,2300, 2530,2700,2870 ,3100}
		PcoPrtCol(aPosCol,.T.,12)

		PcoPrtCell(PcoPrtPos(01),nLin,PcoPrtTam(01),30,STR0073 ,oPrint,2,1,RGB(230,230,230),,) //"GRUPO TOTALIZADOR"
		PcoPrtCell(PcoPrtPos(02),nLin,PcoPrtTam(02),30,STR0074 ,oPrint,2,1,RGB(230,230,230),,) //"CODIGO"
		PcoPrtCell(PcoPrtPos(03),nLin,PcoPrtTam(03),30,STR0095 ,oPrint,2,1,RGB(230,230,230),,)
		PcoPrtCell(PcoPrtPos(04),nLin,PcoPrtTam(04),30,STR0088 ,oPrint,2,1,RGB(230,230,230),,.T.) //"QTD. -VEND"
		PcoPrtCell(PcoPrtPos(05),nLin,PcoPrtTam(05),30,STR0089 ,oPrint,2,1,RGB(230,230,230),,.T.) //"R$   -VEND"
		PcoPrtCell(PcoPrtPos(06),nLin,PcoPrtTam(06),30,STR0078 ,oPrint,2,1,RGB(230,230,230),,.T.) //"VALOR TOTAL-VEND"
		PcoPrtCell(PcoPrtPos(07),nLin,PcoPrtTam(07),30,STR0090 ,oPrint,2,1,RGB(230,230,230),,.T.) //"QTD. -PREV"
		PcoPrtCell(PcoPrtPos(08),nLin,PcoPrtTam(08),30,STR0091 ,oPrint,2,1,RGB(230,230,230),,.T.) //"R$   -PREV"
		PcoPrtCell(PcoPrtPos(09),nLin,PcoPrtTam(09),30,STR0081 ,oPrint,2,1,RGB(230,230,230),,.T.) //"VALOR TOTAL-PREV"
		PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),30,STR0092 ,oPrint,2,1,RGB(230,230,230),,.T.) //"QTD. -REAL"
		PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),30,STR0093 ,oPrint,2,1,RGB(230,230,230),,.T.) //"R$   -REAL"
		PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),30,STR0084 ,oPrint,2,1,RGB(230,230,230),,.T.) //"VALOR TOTAL-REAL"
				
		nLin	+= 35
	EndIf
	
	If lEnd
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0094,oPrint,2,1,RGB(230,230,230)) //"Impressao cancelada pelo operador..."
	Endif

	PcoPrtCell(PcoPrtPos(01),nLin,PcoPrtTam(01),30,aColDte[nX][01],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,)
	PcoPrtCell(PcoPrtPos(02),nLin,PcoPrtTam(02),30,aColDte[nX][02],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,)
	PcoPrtCell(PcoPrtPos(03),nLin,PcoPrtTam(03),30,aColDte[nX][03],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,)
	PcoPrtCell(PcoPrtPos(04),nLin,PcoPrtTam(04),30,aColDte[nX][04],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(05),nLin,PcoPrtTam(05),30,aColDte[nX][05],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(06),nLin,PcoPrtTam(06),30,aColDte[nX][06],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(07),nLin,PcoPrtTam(07),30,aColDte[nX][07],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(08),nLin,PcoPrtTam(08),30,aColDte[nX][08],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(09),nLin,PcoPrtTam(09),30,aColDte[nX][09],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),30,aColDte[nX][10],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),30,aColDte[nX][11],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),30,aColDte[nX][12],oPrint,2,1,PM130Color(aColDte,nX,nCorTot,nCorGrp,nCorDet),,.T.)
	
	nLin	+= 30
Next nX

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Acols2Xls2∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  05/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Transforma aCols para XLS formatado.                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Acols2Xls2(aColsXLS,aHeadXLS,aConfig)

Local cArquivo := CriaTrab(,.F.) + ".htm"
Local nHandle  := 0
Local cDirDocs := MsDocPath()
Local cBarra   := If(issrvunix(), "/", "\")
Local cPath    := AllTrim(GetTempPath())

Local aVetTMP  := {}
Local aVetXLS  := {}

Local cTxtHtm  := ""
Local x1,x2,cRet,cStilo,cTipo,cnVal
Local t1 := 0
Local t2 := Len(aHeadXLS)
Local lArqLocal := ExistBlock("DIRDOCLOC")

If Len(aColsXLS) == 0
	MsgAlert(STR0085) //"N„o encontrei dados para geraÁ„o da planilha!"
	Return
EndIf

If !ApOleClient("MsExcel")
	MsgAlert(STR0086) //"Microsoft Excel nao instalado!"
	Return
EndIf

If Len(aHeadXLS) > 0
	AEval(aHeadXLS,{|x,y| AAdd(aVetTMP,x[1]) })
	AAdd(aVetXLS,aVetTMP)
EndIf

AEval(aColsXLS,{|x,y| If(!x[Len(x)],AAdd(aVetXLS,x),) })

t1 := Len(aVetXLS)

If lArqLocal
	nHandle := FCreate(cPath + cBarra + cArquivo)
Else
	nHandle := FCreate(cDirDocs + cBarra + cArquivo)
Endif

If nHandle == -1
	MsgAlert(STR0087) //"A planilha n„o pode ser exportada."
	Return
EndIf

cTxtHtm += '<html>'+CRLF
cTxtHtm += '<head>'+CRLF
cTxtHtm += '<style>'+CRLF
cTxtHtm += '<!--table'+CRLF
cTxtHtm += '	{mso-displayed-decimal-separator:"\,";'+CRLF
cTxtHtm += '	mso-displayed-thousand-separator:"\.";}'+CRLF
cTxtHtm += '@page'+CRLF
cTxtHtm += '	{margin:.98in .79in .98in .79in;'+CRLF
cTxtHtm += '	mso-header-margin:.49in;'+CRLF
cTxtHtm += '	mso-footer-margin:.49in;}'+CRLF
cTxtHtm += 'tr'+CRLF
cTxtHtm += '	{mso-height-source:auto;}'+CRLF
cTxtHtm += 'col'+CRLF
cTxtHtm += '	{mso-width-source:auto;}'+CRLF
cTxtHtm += 'br'+CRLF
cTxtHtm += '	{mso-data-placement:same-cell;}'+CRLF
cTxtHtm += '.style0'+CRLF
cTxtHtm += '	{mso-number-format:General;'+CRLF
cTxtHtm += '	text-align:general;'+CRLF
cTxtHtm += '	vertical-align:bottom;'+CRLF
cTxtHtm += '	white-space:nowrap;'+CRLF
cTxtHtm += '	mso-rotate:0;'+CRLF
cTxtHtm += '	mso-background-source:auto;'+CRLF
cTxtHtm += '	mso-pattern:auto;'+CRLF
cTxtHtm += '	color:windowtext;'+CRLF
cTxtHtm += '	font-size:10.0pt;'+CRLF
cTxtHtm += '	font-weight:400;'+CRLF
cTxtHtm += '	font-style:normal;'+CRLF
cTxtHtm += '	text-decoration:none;'+CRLF
cTxtHtm += '	font-family:Arial;'+CRLF
cTxtHtm += '	mso-generic-font-family:auto;'+CRLF
cTxtHtm += '	mso-font-charset:0;'+CRLF
cTxtHtm += '	border:1;'+CRLF
cTxtHtm += '	mso-protection:locked visible;'+CRLF
cTxtHtm += '	mso-style-name:Normal;'+CRLF
cTxtHtm += '	mso-style-id:0;}'+CRLF
cTxtHtm += 'td'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	padding-top:1px;'+CRLF
cTxtHtm += '	padding-right:1px;'+CRLF
cTxtHtm += '	padding-left:1px;'+CRLF
cTxtHtm += '	mso-ignore:padding;'+CRLF
cTxtHtm += '	color:windowtext;'+CRLF
cTxtHtm += '	font-size:10.0pt;'+CRLF
cTxtHtm += '	font-weight:400;'+CRLF
cTxtHtm += '	font-style:normal;'+CRLF
cTxtHtm += '	text-decoration:none;'+CRLF
cTxtHtm += '	font-family:Arial;'+CRLF
cTxtHtm += '	mso-generic-font-family:auto;'+CRLF
cTxtHtm += '	mso-font-charset:0;'+CRLF
cTxtHtm += '	mso-number-format:General;'+CRLF
cTxtHtm += '	text-align:general;'+CRLF
cTxtHtm += '	vertical-align:bottom;'+CRLF
cTxtHtm += '	border:none;'+CRLF
cTxtHtm += '	mso-background-source:auto;'+CRLF
cTxtHtm += '	mso-pattern:auto;'+CRLF
cTxtHtm += '	mso-protection:locked visible;'+CRLF
cTxtHtm += '	white-space:nowrap;'+CRLF
cTxtHtm += '	mso-rotate:0;}'+CRLF
cTxtHtm += '.TotC'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	border:.5pt solid windowtext;'+CRLF
cTxtHtm += '	background:RGB('+StrZero(aConfig[NPOSACORES][1][2],3)+','+StrZero(aConfig[NPOSACORES][1][3],3)+','+StrZero(aConfig[NPOSACORES][1][4],3)+');'+CRLF
cTxtHtm += '	mso-pattern:auto none;}'+CRLF
cTxtHtm += '.TotN'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	border:.5pt solid windowtext;'+CRLF
cTxtHtm += '	mso-number-format:Standard;'+CRLF
cTxtHtm += '	background:RGB('+StrZero(aConfig[NPOSACORES][1][2],3)+','+StrZero(aConfig[NPOSACORES][1][3],3)+','+StrZero(aConfig[NPOSACORES][1][4],3)+');'+CRLF
cTxtHtm += '	mso-pattern:auto none;}'+CRLF
cTxtHtm += '.GrpC'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	border:.5pt solid windowtext;'+CRLF
cTxtHtm += '	background:RGB('+StrZero(aConfig[NPOSACORES][2][2],3)+','+StrZero(aConfig[NPOSACORES][2][3],3)+','+StrZero(aConfig[NPOSACORES][2][4],3)+');'+CRLF
cTxtHtm += '	mso-pattern:auto none;}'+CRLF
cTxtHtm += '.GrpN'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	border:.5pt solid windowtext;'+CRLF
cTxtHtm += '	mso-number-format:Standard;'+CRLF
cTxtHtm += '	background:RGB('+StrZero(aConfig[NPOSACORES][2][2],3)+','+StrZero(aConfig[NPOSACORES][2][3],3)+','+StrZero(aConfig[NPOSACORES][2][4],3)+');'+CRLF
cTxtHtm += '	mso-pattern:auto none;}'+CRLF
cTxtHtm += '.DetC'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	border:.5pt solid windowtext;'+CRLF
cTxtHtm += '	background:RGB('+StrZero(aConfig[NPOSACORES][3][2],3)+','+StrZero(aConfig[NPOSACORES][3][3],3)+','+StrZero(aConfig[NPOSACORES][3][4],3)+');'+CRLF
cTxtHtm += '	mso-pattern:auto none;}'+CRLF
cTxtHtm += '.DetN'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	border:.5pt solid windowtext;'+CRLF
cTxtHtm += '	mso-number-format:Standard;'+CRLF
cTxtHtm += '	background:RGB('+StrZero(aConfig[NPOSACORES][3][2],3)+','+StrZero(aConfig[NPOSACORES][3][3],3)+','+StrZero(aConfig[NPOSACORES][3][4],3)+');'+CRLF
cTxtHtm += '	mso-pattern:auto none;}'+CRLF
cTxtHtm += '.Cabe'+CRLF
cTxtHtm += '	{mso-style-parent:style0;'+CRLF
cTxtHtm += '	border:.5pt solid windowtext;'+CRLF
cTxtHtm += '	background:RGB(192,192,192);'+CRLF
cTxtHtm += '	mso-pattern:auto none;}'+CRLF
cTxtHtm += '-->'+CRLF
cTxtHtm += '</style>'+CRLF
cTxtHtm += '<!--[if gte mso 9]><xml>'+CRLF
cTxtHtm += '	<x:ExcelWorkbook>'+CRLF
cTxtHtm += '	<x:ExcelWorksheets>'+CRLF
cTxtHtm += '	<x:ExcelWorksheet>'+CRLF
cTxtHtm += '	<x:Name>Plan1</x:Name>'+CRLF
cTxtHtm += '	<x:WorksheetOptions>'+CRLF
cTxtHtm += '	<x:Selected/>'+CRLF
cTxtHtm += '	<x:Panes>'+CRLF
cTxtHtm += '	<x:Pane>'+CRLF
cTxtHtm += '	<x:Number>3</x:Number>'+CRLF
cTxtHtm += '	<x:ActiveRow>1</x:ActiveRow>'+CRLF
cTxtHtm += '	<x:ActiveCol>1</x:ActiveCol>'+CRLF
cTxtHtm += '	<x:RangeSelection>$A$1:$c$3</x:RangeSelection>'+CRLF
cTxtHtm += '	</x:Pane>'+CRLF
cTxtHtm += '	</x:Panes>'+CRLF
cTxtHtm += '	<x:ProtectContents>False</x:ProtectContents>'+CRLF
cTxtHtm += '	<x:ProtectObjects>False</x:ProtectObjects>'+CRLF
cTxtHtm += '	<x:ProtectScenarios>False</x:ProtectScenarios>'+CRLF
cTxtHtm += '	</x:WorksheetOptions>'+CRLF
cTxtHtm += '	</x:ExcelWorksheet>'+CRLF
cTxtHtm += '	<x:ExcelWorksheet>'+CRLF
cTxtHtm += '	<x:Name>Plan2</x:Name>'+CRLF
cTxtHtm += '	<x:WorksheetOptions'+CRLF
cTxtHtm += '	<x:ProtectContents>False</x:ProtectContents'+CRLF
cTxtHtm += '	<x:ProtectObjects>False</x:ProtectObjects'+CRLF
cTxtHtm += '	<x:ProtectScenarios>False</x:ProtectScenarios'+CRLF
cTxtHtm += '	</x:WorksheetOptions'+CRLF
cTxtHtm += '	</x:ExcelWorksheet'+CRLF
cTxtHtm += '	<x:ExcelWorksheet'+CRLF
cTxtHtm += '	<x:Name>Plan3</x:Name'+CRLF
cTxtHtm += '	<x:WorksheetOptions'+CRLF
cTxtHtm += '	<x:ProtectContents>False</x:ProtectContents'+CRLF
cTxtHtm += '	<x:ProtectObjects>False</x:ProtectObjects'+CRLF
cTxtHtm += '	<x:ProtectScenarios>False</x:ProtectScenarios'+CRLF
cTxtHtm += '	</x:WorksheetOptions'+CRLF
cTxtHtm += '	</x:ExcelWorksheet'+CRLF
cTxtHtm += '	</x:ExcelWorksheets'+CRLF
cTxtHtm += '	<x:WindowHeight>12270</x:WindowHeight'+CRLF
cTxtHtm += '	<x:WindowWidth>500</x:WindowWidth'+CRLF
cTxtHtm += '	<x:WindowTopX>360</x:WindowTopX'+CRLF
cTxtHtm += '	<x:WindowTopY>30</x:WindowTopY'+CRLF
cTxtHtm += '	<x:ProtectStructure>False</x:ProtectStructure'+CRLF
cTxtHtm += '	<x:ProtectWindows>False</x:ProtectWindows'+CRLF
cTxtHtm += '	</x:ExcelWorkbook>'+CRLF
cTxtHtm += '</xml><![endif]-->'+CRLF
cTxtHtm += '</head>'+CRLF
cTxtHtm += '<body>'+CRLF
cTxtHtm += '<table x:str border=1 cellpadding=1 cellspacing=1>'+CRLF

For x1 := 1 To t2
	cTxtHtm += "	<col style='mso-width-source:userset;mso-width-alt:"+StrZero((aHeadXLS[x1][4]+aHeadXLS[x1][5])*330,8)+"'>"+CRLF
Next

For x1 := 1 To t1
	cTxtHtm += "	<tr>"+CRLF

	cRet := "Det" //Padrao Detalhe
	If !Empty(aVetXLS[x1][1]) .And. !Empty(aVetXLS[x1][2])
		cRet := "Det" //Formulas
	ElseIf !Empty(aVetXLS[x1][1]) .And. !Empty(aVetXLS[x1][4])
		cRet := "Grp" //Grupo
	Elseif !Empty(aVetXLS[x1][1]) .And. Empty(aVetXLS[x1][4])
		cRet := "Tot" //Totalizador
	EndIf

	For x2 := 1 To t2
		cStilo := cRet+aHeadXLS[x2][08]
		cTipo := ""
		If x1 == 1
			cStilo := "Cabe"
		ElseIf aHeadXLS[x2][08] == "N"
			cnVal := AllTrim(StrTran(StrTran(aVetXLS[x1][x2],".",""),",","."))
			cTipo := 'align=right x:num="'+cnVal+'"'
		EndIf
		cTxtHtm += '		<td class='+cStilo+' '+cTipo+'>'+CRLF
		cTxtHtm += '			'+aVetXLS[x1][x2]+CRLF
		cTxtHtm += '		</td>'+CRLF
	Next
	cTxtHtm += "	</tr>"+CRLF
Next
cTxtHtm += '</table>'+CRLF
cTxtHtm += '</body>'+CRLF
cTxtHtm += '</html>'+CRLF

FWrite(nHandle,cTxtHtm)

FClose(nHandle)

// copia o arquivo do servidor para o remote
If !lArqLocal
	CpyS2T(cDirDocs + cBarra + cArquivo, cPath, .T.)
Endif

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath + cArquivo)
oExcelApp:SetVisible(.T.)
Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa funÁ„o quando n„o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informaÁıes enviadas, 
    quando a regra de auditoria de rotinas com campos sensÌveis ou pessoais estiver habilitada
	Remover essa funÁ„o quando n„o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser· utilizada no log das tabelas
    @param nOpc, Numerico, OpÁ„o atribuÌda a funÁ„o em execuÁ„o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n„o esteja aplicada, tambÈm retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    FunÁ„o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive   

