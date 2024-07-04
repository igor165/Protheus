#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "REPORT.CH
#INCLUDE "HSPAHR85.CH"   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR85  º Autor ³ Rogerio Tabosa     º Data ³  31/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Rastreabilidade de Mat/Med Consumido          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Microsiga                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAHR85()
Local cDesc1	:= STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2	:= STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3	:= STR0003 //"Rastreabilidade de Medicamento/Material Consumido"
Local cPict		:= ""
Local titulo	:= STR0003 //"Rastreabilidade de Medicamento/Material Consumido"
Local nLin		:= 80
Local Cabec1	:= "" //"Prontuario   Prontuario    Paciente               Data Atend.               Setor de Atendimento"	
Local Cabec2	:= "" //STR0011 //"Data Lancto.        Hora    Cod. Setor    Desc. Setor     Produto       Desc. Produto                   Qtd.      Lote    Validade   Armazem     Controlado?"
//Local Cabec3       := STR0012 //"      Cod. Setor    Desc. Setor"
//Local Cabec4       := STR0013 //"           Data Lancto.        Hora    Produto       Desc. Produto                   Qtd.      Lote    Validade   Armazem     Controlado?"            
Local imprime	:= .T.
Local aOrd		:= {}

Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private cCabAux1	:= ""
Private cCabAux2	:= ""
Private cCabAux3	:= ""
Private cCabAux4	:= ""
Private oTotaliz
Private limite		:= 220
Private tamanho		:= "G"
Private nomeprog	:= "HSPAHR85" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo		:= 15
Private aReturn		:= { STR0005, 1, STR0004, 2, 2, 1, "", 1}  //"Zebrado" # "Administracao"
Private nLastKey	:= 0
Private cbtxt		:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private m_pag		:= 01
Private wnrel		:= "HSPAHR85" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nCount		:= 0

Private cLot_de			:= ""   //Variaveis de Filtro
Private cLot_ate		:= ""
Private cRegGer_de		:= ""  
Private cRegGer_ate		:= ""
Private cRegAte_de		:= ""  
Private cRegAte_ate		:= ""
Private cLoc_de			:= ""  
Private cLoc_ate		:= ""
Private dDatAte_de
Private dDatAte_ate
Private cProduto_de		:= ""
Private cProduto_ate	:= ""
Private lVerif			:= .F. // Usado para entrar no R3 ou no R4

Private lTamProd := IIf((TamSx3("GAJ_PROSOL")[1])<=15, .T., .F.) //Impressao do Produto
AjustaSX1()					// Cria novas perguntas, caso as mesmas nao existam.
Cabec1	:= IIF(lTamProd,STR0010,STR0027)

If FindFunction("TRepInUse") .And. TRepInUse() 
	lVerif := .T.
EndIf
  
If !Pergunte("HSPR85",.T.)
	return
endif

cLot_de			:= mv_par01   //Variaveis de Filtro
cLot_ate		:= mv_par02
cRegGer_de		:= mv_par03  
cRegGer_ate		:= mv_par04
cRegAte_de		:= mv_par05  
cRegAte_ate		:= mv_par06
cLoc_de			:= mv_par07  
cLoc_ate		:= mv_par08
dDatAte_de		:= mv_par09
dDatAte_ate		:= mv_par10
cOrder			:= mv_par11
cProduto_de		:= mv_par13
cProduto_ate	:= mv_par14
nMaxLin			:= IIf(Empty(mv_par12), 55, HS_MaxLin(mv_par12))
 
If lVerif
	pergunte("HSPR85",.F.)
	oReport := ReportDef() 
	oReport:PrintDialog() 
Else
	wnrel := SetPrint("GCY",NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho, , .T.)
	If nLastKey == 27
		Return()
	Endif
	SetDefault(aReturn, "GCY")
	If nLastKey == 27
		Return()
	Endif

	aReturn[4]	:= 2
	nTipo 		:= If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
EndIf
 
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef ³ Autor ³ Rogerio Tabosa        ³ Data ³ 31/07/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

Static Function ReportDef()
 
Local oReport 
Local oSection1,oSection2,oSection3,oSection4
Local oCell
Local oBreak  
Local oTotaliza
                                                                           
 
oReport := TReport():New("HSPAHR85",STR0003,"HSPR85",{|oReport| R85IMP(oReport)}, STR0001 + STR0002)

oReport:SetTotalInLine(.F.)
 
oSection1 := TRSection():New(oReport, "GCY_NOME", "QRYSQL")
oSection1:SetHeaderPage(.T.)
oSection1:SetHeaderBreak(.F.)
oSection1:SetHeaderSection(.T.)
oSection1:SetTotalInLine(.F.)      

oCell := TRCell():New(oSection1,"cPront","QRYSQL","",, 23,,{|| cPront := STR0011 + ("QRYSQL")->GCY_REGGER}) //"Prontuario"
oCell := TRCell():New(oSection1,"cNome","QRYSQL","",, 50,,{|| cNome := STR0012  + ("QRYSQL")->GCY_NOME})   //"Paciente"
                                            
oSection2 := TRSection():New(oSection1, "GCY_REGATE", "QRYSQL")
oSection2:SetHeaderPage(.F.)
oSection2:SetHeaderBreak(.F.) 
oSection2:SetHeaderSection(.F.)  
oSection2:SetTotalInLine(.F.)              
 
oCell := TRCell():New(oSection2,"cRegA","QRYSQL","",, 28,,{|| cRegA := STR0013 + ("QRYSQL")->GCY_REGATE + STR0014  })    //Reg. Atend.  Data Atend.
oCell := TRCell():New(oSection2,"GCY_DATATE","QRYSQL","",, 15) 

oSection3 := TRSection():New(oSection2, "GCY_CODLOC", "QRYSQL")
oSection3:SetHeaderPage(.F.)
oSection3:SetHeaderBreak(.F.)
oSection3:SetHeaderSection(.F.)  
oSection3:SetTotalInLine(.F.)              
 
oCell := TRCell():New(oSection3,"cCodLoc","QRYSQL","",, 15,,{|| cCodLoc := STR0015  + ("QRYSQL")->GCY_CODLOC})  // Cod Setor 
oCell := TRCell():New(oSection3,"cDescLoc","QRYSQL","",, 50,,{|| cDescLoc := STR0016  + ("QRYSQL")->SETORSOLIC}) //'Desc. Setor: '

oSection4 := TRSection():New(oSection3, "GAI_DATSOL", "QRYSQL")
oSection4:SetHeaderPage(.T.)
oSection4:SetHeaderBreak(.F.)
oSection4:SetHeaderSection(.T.)  
oSection4:SetTotalInLine(.F.)              
 
oCell := TRCell():New(oSection4,"        ","","",, 20)
oCell := TRCell():New(oSection4,"GAI_DATSOL","QRYSQL",STR0017,, 18)//"Data Lancto"
oCell := TRCell():New(oSection4,"GAI_HORSOL","QRYSQL",STR0018,, 15)//"Hora"
oCell := TRCell():New(oSection4,"GAJ_PROSOL","QRYSQL",STR0019,, 20)//"Produto"
oCell := TRCell():New(oSection4,"B1_DESC","QRYSQL",STR0020,, 50)//"Desc. Produto"
oCell := TRCell():New(oSection4,"cQtd","QRYSQL",STR0021 ,, 20,,{|| cQtd := Str(("QRYSQL")->GAJ_QTDSOL,3)})//"Qtd"
oCell := TRCell():New(oSection4,"cLote","QRYSQL",STR0022,, 45,,{|| cLote := '' + Alltrim(("QRYSQL")->GAJ_LOTEFO) + "/" + Alltrim(("QRYSQL")->GAJ_LOTECT) + "/" + Alltrim(("QRYSQL")->GAJ_NUMLOT )})//"Lot.Forn./Lot.Aut./Sub.Lot."
oCell := TRCell():New(oSection4,"GAJ_DTVALI","QRYSQL",STR0023 ,, 18)//"Validade"
oCell := TRCell():New(oSection4,"GAI_ALMORI","QRYSQL",STR0024 ,, 15)//"Arm."
oCell := TRCell():New(oSection4,"CONTROLADO","QRYSQL",STR0025 ,, 20)//"Controlado?"

 
Return (oReport)         
                                                                         	`					
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R84Imp   ³ Autor ³ Rogerio Tabosa        ³ Data ³ 31/07/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

Static Function R85IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
Local cCondi := ""

Private cCond1 := ""
Private cCond2 := ""
Private cCond3 := ""
Private cCond4 := ""
                 
cCondi := " GBI.GBI_PRODUT BETWEEN '" + cProduto_de + "' AND '" + cProduto_ate + "' AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_de) + "' AND '" + DTOS(dDatAte_ate) + "'"            
cCondi += " AND GCY.GCY_REGGER BETWEEN '" + cRegGer_de + "' AND '" + cRegGer_ate + "'
cCondi += " AND GCY.GCY_REGATE BETWEEN '" + cRegAte_de + "' AND '" + cRegAte_ate + "'
cCondi += " AND GCY.GCY_CODLOC BETWEEN '" + cLoc_de + "' AND '" + cLoc_ate + "'
cCondi += " AND GAJ.GAJ_LOTECT BETWEEN '" + cLot_de + "' AND '" + cLot_ate + "'

MakeSqlExpr(oReport:uParam)                      
oSection1:BeginQuery() 

cCond1 += "% GCY.GCY_REGATE, GCY.GCY_REGGER,GCY_NOME, GCY.GCY_DATATE,GCY.GCY_CODLOC,GCSA.GCS_NOMLOC SETORATEND, "
cCond1 += " GAI.GAI_DATSOL,GAI.GAI_HORSOL,GAI.GAI_CODLOC, GCSP.GCS_NOMLOC SETORSOLIC,SB1.B1_DESC,GAJ.GAJ_PROSOL,GAJ.GAJ_ITESOL,  "
cCond1 += " GAJ.GAJ_QTDSOL,GAJ.GAJ_LOTEFO,GAJ.GAJ_LOTECT,GAJ.GAJ_NUMLOT,GAJ.GAJ_DTVALI,GAI.GAI_ALMORI,GBI.GBI_CTRPSC, "
cCond1 += " CASE GBI.GBI_CTRPSC WHEN '0' THEN 'SIM' WHEN '1' THEN 'SIM' ELSE 'NAO' END  CONTROLADO %"

cCond2 += "% " + RetSqlName("GCY") + " GCY "
cCond2 += " JOIN " + RetSqlName("GCS") + " GCSA ON GCSA.GCS_CODLOC=GCY.GCY_CODLOC AND GCSA.GCS_FILIAL='" + xFilial("GCS") + "' AND GCSA.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GAI") + " GAI ON GCY.GCY_REGATE=GAI.GAI_REGATE AND GAI.GAI_FILIAL='" + xFilial("GAI") + "' AND GAI.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GCS") + " GCSP ON GAI.GAI_CODLOC=GCSP.GCS_CODLOC AND GCSP.GCS_FILIAL='" + xFilial("GCS") + "' AND GCSP.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GAJ") + " GAJ ON GAI.GAI_SOLICI=GAJ.GAJ_SOLICI AND GAJ.GAJ_FILIAL='" + xFilial("GAJ") + "' AND GAJ.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD=GAJ.GAJ_PROSOL AND SB1.B1_FILIAL='" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_PRODUT=GAJ.GAJ_PROSOL AND GBI.GBI_FILIAL='" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' %"  

cCond3 += "% " + cCondi + " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' %"

If cOrder == 1 
	cCond4 += "% GCSP.GCS_NOMLOC,GCY_REGGER,GAI_DATSOL,GAI_HORSOL %"
Elseif cOrder == 2
	cCond4 += "% GCY_NOME,GCY_REGGER,GAI_DATSOL,GAI_HORSOL,GCSP.GCS_NOMLOC %"
Else
	cCond4 += "% GAJ_LOTECT,GAJ_LOTEFO,GAJ_NUMLOT,GCY_NOME,GAI_DATSOL,GAI_HORSOL,GCSP.GCS_NOMLOC %"    
Endif

BeginSql alias "QRYSQL"
 SELECT		%Exp:cCond1%
 FROM     	%Exp:cCond2%
 WHERE    	%Exp:cCond3%                                      	
 ORDER BY	%Exp:cCond4% 
EndSql 

oSection1:EndQuery() 
	 
DbSelectArea("QRYSQL")
DbGoTop()                                                                                                                                
 
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G| ("QRYSQL")->GCY_REGGER  == G }, {|| ("QRYSQL")->GCY_REGGER} )    

oSection3:SetParentQuery()                                                                           
oSection3:SetParentFilter( {|P| ("QRYSQL")->GCY_REGATE + ("QRYSQL")->GCY_REGGER  == P }, {|| ("QRYSQL")->GCY_REGATE + ("QRYSQL")->GCY_REGGER } )// Quebra por procedimento/medico por medico/procedimento

oSection4:SetParentQuery()                                                                           
oSection4:SetParentFilter( {|M| ("QRYSQL")->GCY_REGATE + ("QRYSQL")->GCY_REGGER + ("QRYSQL")->GCY_CODLOC == M }, {|| ("QRYSQL")->GCY_REGATE + ("QRYSQL")->GCY_REGGER + ("QRYSQL")->GCY_CODLOC } ) 

oSection1:Print() 
oReport:SetMeter(QRYSQL->(LastRec())) 

Return (Nil)
                                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Rogerio Tabosa     º Data ³  31/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento. R3            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cSql   := "" 
DbSelectArea("GCY")
            
cSql += " SELECT	GCY.GCY_REGATE, GCY.GCY_REGGER,GCY_NOME, GCY.GCY_DATATE,GCY.GCY_CODLOC,GCSA.GCS_NOMLOC SETORATEND, "
cSql += " GAI.GAI_DATSOL,GAI.GAI_HORSOL,GAI.GAI_CODLOC, GCSP.GCS_NOMLOC SETORSOLIC,SB1.B1_DESC,GAJ.GAJ_PROSOL,GAJ.GAJ_ITESOL,  "
cSql += " GAJ.GAJ_QTDSOL,GAJ.GAJ_LOTEFO,GAJ.GAJ_LOTECT,GAJ.GAJ_NUMLOT,GAJ.GAJ_DTVALI,GAI.GAI_ALMORI,GBI.GBI_CTRPSC, "
cSql += " CASE GBI.GBI_CTRPSC WHEN '0' THEN 'SIM' WHEN '1' THEN 'SIM' ELSE 'NAO' END  CONTROLADO "

cSql += " FROM	" + RetSqlName("GCY") + " GCY "
cSql += " JOIN " + RetSqlName("GCS") + " GCSA ON GCSA.GCS_CODLOC = GCY.GCY_CODLOC AND GCSA.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCSA.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GAI") + " GAI  ON GCY.GCY_REGATE = GAI.GAI_REGATE AND GAI.GAI_FILIAL = '" + xFilial("GAI") + "' AND GAI.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GCS") + " GCSP ON GAI.GAI_CODLOC = GCSP.GCS_CODLOC AND GCSP.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCSP.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GAJ") + " GAJ  ON GAI.GAI_SOLICI = GAJ.GAJ_SOLICI AND GAJ.GAJ_FILIAL = '" + xFilial("GAJ") + "' AND GAJ.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("SB1") + " SB1  ON SB1.B1_COD     = GAJ.GAJ_PROSOL AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GBI") + " GBI  ON GBI.GBI_PRODUT = GAJ.GAJ_PROSOL AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "  
cSql += " WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' " 


cSql +=  " AND GBI.GBI_PRODUT BETWEEN '" + cProduto_de + "' AND '" + cProduto_ate + "' AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_de) + "' AND '" + DTOS(dDatAte_ate) + "'"
cSql +=  " AND GCY.GCY_REGGER BETWEEN '" + cRegGer_de + "' AND '" + cRegGer_ate + "'"
cSql +=  " AND GCY.GCY_REGATE BETWEEN '" + cRegAte_de + "' AND '" + cRegAte_ate + "'"
cSql +=  " AND GCY.GCY_CODLOC BETWEEN '" + cLoc_de + "' AND '" + cLoc_ate + "'"		
cSql +=  " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_de) + "' AND '" + DTOS(dDatAte_ate) + "'"
cSql +=  " AND GAJ.GAJ_LOTECT BETWEEN '" + cLot_de + "' AND '" + cLot_ate + "'"
		
If cOrder == 1 
	cSql += " ORDER BY GCSP.GCS_NOMLOC,GCY_REGGER,GAI_DATSOL,GAI_HORSOL "
Elseif cOrder == 2
	cSql += " ORDER BY  GCY_NOME,GCY_REGGER,GAI_DATSOL,GAI_HORSOL,GCSP.GCS_NOMLOC "
Else
	cSql += " ORDER BY GAJ_LOTECT,GAJ_LOTEFO,GAJ_NUMLOT,GCY_NOME,GAI_DATSOL,GAI_HORSOL,GCSP.GCS_NOMLOC "    
Endif

//cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRY" 
DbSelectArea("QRY")
   
dbGotop()

If Eof()     
	HS_MSGINF(STR0006,STR0007,STR0008) // "Nenhum dado foi encontrado para a selecao efetuada!" # "Atenção" # s"Validação Relat. Rastreabilidade Mat/Med."
	dbClosearea()
	return()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
//³                                                                     ³
//³ dbSeek(xFilial())                                                   ³
//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !EOF()
	incRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lAbortPrint
		@nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLin > nMaxLin // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif
	// Coloque aqui a logica da impressao do seu programa...
	// Utilize PSAY para saida na impressora. Por exemplo:
	// @nLin,00 PSAY SA1->A1_COD
	//"                    Data Lancto. Hora    Produto    Desc. Produto                     Qtd.    Lot.Forn./Lot.Aut./Sub.Lot.   Validade   Arm. Controlado?"	

	If cCabAux1 <> QRY->GCY_REGGER
		cCabAux2 := ""
		cCabAux3 := ""
		cCabAux4 := ""
		If cCabAux1 <> ""
			//	@nLin, 001 Psay "---------------------------------------------------------------------------------------------------------------8----------------------------------------------------------------------------------------" 
			nLin++
		EndIf  
		@nLin, 001 Psay STR0026 + QRY->GCY_REGGER//"Pront.: " 
		@nLin, 020 Psay STR0012 + QRY->GCY_NOME //"Paciente: " 
		nLin++
	EndIf

	If cCabAux2 <> QRY->GCY_REGATE
		cCabAux3 := ""
		cCabAux4 := ""
		@nLin, 001 Psay STR0013 + QRY->GCY_REGATE + "  " + STR0014  //"Reg. Atend.: " //"   Data Atend.: "
		@nLin, 037 Psay (STOD(QRY->GCY_DATATE))
		nLin++
	EndIf

	If cCabAux3 <> QRY->GCY_CODLOC
		cCabAux4 := ""
		@nLin, 001 Psay STR0015  + QRY->GCY_CODLOC//"Cod. Setor.: "
		@nLin, 018 Psay STR0016 + QRY->SETORATEND//"Desc. Setor.: " 
		nLin++   
		nLin++
	EndIf
 
	@nLin, IIf(lTamProd, 020,010) Psay (STOD(QRY->GAI_DATSOL))		
	@nLin, IIf(lTamProd, 032,022) Psay GAI_HORSOL		
	@nLin, IIf(lTamProd, 040,030) Psay QRY->GAJ_PROSOL
	@nLin, IIf(lTamProd, 055,065) Psay ALLTRIM(QRY->B1_DESC)
				
	@nLin, IIf(lTamProd, 096,098) Psay ALLTRIM(STR(QRY->GAJ_QTDSOL,3))
	@nLin, IIf(lTamProd, 104,114) Psay ALLTRIM(QRY->GAJ_LOTEFO) +"/"+ ALLTRIM(QRY->GAJ_LOTECT) + "/" + ALLTRIM(QRY->GAJ_NUMLOT)
	@nLin, IIf(lTamProd, 149,153) Psay (STOD(QRY->GAJ_DTVALI))
	@nLin, IIf(lTamProd, 169,168) Psay QRY->GAI_ALMORI
	@nLin, IIf(lTamProd, 183,176) Psay QRY->CONTROLADO
	nLin++

	cCabAux1 := QRY->GCY_REGGER
	cCabAux2 := QRY->GCY_REGATE
	cCabAux3 := QRY->GCY_CODLOC
	cCabAux4 := QRY->GAJ_PROSOL

	//nLin := nLin + 1 // Avanca a linha de impressao
	nCount += 1
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo         
nLin += 2

//@nLin, 001 Psay "TOtal Geral: " + Str(nCount)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QRY")
DbCloseArea()

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
                                 
MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AjustaSX1³ Autor ³ MICROSIGA             ³ Data ³ 25/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica as perguntas incluindo-as caso nao existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uso Generico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()
Local aArea		:= GetArea()
Local aRegs		:= {}
Local i			:= 0
Local j			:= 0
Local lInclui	:= .F.
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}

// Cria grupo de perguntas HSPR85
cPerg	:= PADR("HSPR85",6)
aRegs	:= {}

AADD(aRegs,{cPerg,"01","Do Lote ?                     ","Do Lote ?                     ","Do Lote ?                     ","MV_CH1","C",10,00,00,"G","                                                            ","MV_PAR01       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"02","Ate Lote ?                    ","Ate Lote ?                    ","Ate Lote ?                    ","MV_CH2","C",10,00,00,"G","                                                            ","MV_PAR02       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"03","Do Prontuario ?               ","Do Prontuario ?               ","Do Prontuario ?               ","MV_CH3","C",06,00,00,"G","                                                            ","MV_PAR03       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GBH   ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"04","Ate o Prontuario ?            ","Ate o Prontuario ?            ","Ate o Prontuario ?            ","MV_CH4","C",06,00,00,"G","                                                            ","MV_PAR04       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GBH   ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"05","Reg. Atendimento de           ","Reg. Atendimento de           ","Reg. Atendimento de           ","MV_CH5","C",06,00,00,"G","                                                            ","MV_PAR05       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GCY   ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"06","Reg. Atendimento Ate          ","Reg. Atendimento Ate          ","Reg. Atendimento Ate          ","MV_CH6","C",06,00,00,"G","                                                            ","MV_PAR06       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GCY   ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"07","Setor de                      ","Setor de                      ","Setor de                      ","MV_CH7","C",02,00,00,"G","                                                            ","MV_PAR07       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GCS   ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"08","Setor Ate                     ","Setor Ate                     ","Setor Ate                     ","MV_CH8","C",02,00,00,"G","                                                            ","MV_PAR08       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GCS   ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"09","Da Data Atend. ?              ","Da Data Atend. ?              ","Da Data Atend. ?              ","MV_CH9","D",08,00,00,"G","                                                            ","MV_PAR09       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"10","Ate Data Atend. ?             ","Ate Data Atend. ?             ","Ate Data Atend. ?             ","MV_CHA","D",08,00,00,"G","                                                            ","MV_PAR10       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"11","Ordenar Por ?                 ","Ordenar Por ?                 ","Sort by ?                     ","MV_CHB","N",01,00,02,"C","                                                            ","MV_PAR11       ","Setor          ","               ","               ","                                                            ","               ","Paciente       ","               ","               ","                                                            ","               ","Lote           ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"12","Impressora ?                  ","Impressora ?                  ","Impressora ?                  ","MV_CHC","C",06,00,00,"G","HS_ValidaImp()                                              ","MV_PAR12       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GFJ001","N","   ","          ","                                        ","      "})
IF lTamProd 
	AADD(aRegs,{cPerg,"13","Produto de ?                  ","Produto de ?                  ","Produto de ?                  ","MV_CHD","C",15,00,00,"G","                                                            ","MV_PAR13       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GBI   ","N","   ","          ","                                        "})
	AADD(aRegs,{cPerg,"14","Produto ate ?                 ","Produto ate ?                 ","Produto ate ?                 ","MV_CHE","C",15,00,00,"G","                                                            ","MV_PAR14       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GBI   ","N","   ","          ","                                        "})
Else
	AADD(aRegs,{cPerg,"13","Produto de ?                  ","Produto de ?                  ","Produto de ?                  ","MV_CHD","C",30,00,00,"G","                                                            ","MV_PAR13       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GBI   ","N","   ","          ","                                        "})
	AADD(aRegs,{cPerg,"14","Produto ate ?                 ","Produto ate ?                 ","Produto ate ?                 ","MV_CHE","C",30,00,00,"G","                                                            ","MV_PAR14       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GBI   ","N","   ","          ","                                        "})
Endif

dbSelectArea("SX1")
dbSetOrder(1)
For i := 1 To Len(aRegs)
	lInclui := !dbSeek(cPerg + "    " + aRegs[i,2])
	RecLock("SX1", lInclui)
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Endif
	Next
	MsUnlock()

	aHelpPor := {} ; aHelpSpa := {} ; 	aHelpEng := {}
	IF i == 1
		AADD(aHelpPor,"Selecione o Lote inicial, caso queira  ")
		AADD(aHelpPor,"utilizar o filtro por lote.            ")
	ELSEIF i==2
		AADD(aHelpPor,"Selecione o Lote final, caso queira    ")
		AADD(aHelpPor,"utilizar o filtro por lote.            ")
	ELSEIF i==3
		AADD(aHelpPor,"Selecione o Prontuário inicial, caso   ")
		AADD(aHelpPor,"queira utilizar o filtro por prontuário")
	ELSEIF i==4
		AADD(aHelpPor,"Selecione o Prontuário final, caso     ")
		AADD(aHelpPor,"queira utilizar o filtro por prontuário")
	ELSEIF i==5
		AADD(aHelpPor,"Selecione o Registro de atendimento    ")
		AADD(aHelpPor,"inicial, caso queira utilizar o filtro ")
		AADD(aHelpPor,"por registro de atendimento.           ")
	ELSEIF i==6
		AADD(aHelpPor,"Selecione o Registro de atendimento    ")
		AADD(aHelpPor,"final, caso queira utilizar o filtro   ")
		AADD(aHelpPor,"por registro de atendimento.           ")
	ELSEIF i==7
		AADD(aHelpPor,"Selecione o Setor inicial, caso queira ")
		AADD(aHelpPor,"utilizar o filtro por setor.           ")
	ELSEIF i==8
		AADD(aHelpPor,"Selecione o Setor final, caso queira   ")
		AADD(aHelpPor,"Utilizar o filtro por setor.           ")
	ELSEIF i==9
		AADD(aHelpPor,"Selecione a Data de atendimento inicial")
		AADD(aHelpPor,"caso queira utilizar o filtro por data.")
	ELSEIF i==10
		AADD(aHelpPor,"Selecione a Data de atendimento final, ")
		AADD(aHelpPor,"caso queira utilizar o filtro por data.")
	ELSEIF i==11
		AADD(aHelpPor,"Selecione a ordenação desejada: Setor, ")
		AADD(aHelpPor,"Paciente ou Lote.                      ")
	ELSEIF i==12
		AADD(aHelpPor,"Escolha uma impressora.                ")
	ELSEIF i==13
		AADD(aHelpPor,"Selecione o Produto inicial, caso queir")
		AADD(aHelpPor,"a utilizar o filtro por produto.       ")
	ELSEIF i==14
		AADD(aHelpPor,"Selecione o Produto final, caso queira ")
		AADD(aHelpPor,"utilizar o filtro por produto.         ")
	ENDIF
    PutSX1Help("P."+cPerg+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)
Next

RestArea(aArea)
Return()
