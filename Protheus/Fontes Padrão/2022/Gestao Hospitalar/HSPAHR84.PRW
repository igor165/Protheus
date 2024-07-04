#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "REPORT.CH
#INCLUDE "HSPAHR84.CH"   



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR84  º Autor ³ MICROSIGA          º Data ³  23/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Acomodacoes Divergentes                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Microsiga                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAHR84()
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Pacientes Internados em Acomodações Divergentes"
Local cPict          := ""
local  titulo       := STR0003 //"Pacientes Internados em Acomodações Divergentes"
Local nLin         := 80

Local Cabec1       := STR0010 //"Reg. Atend.   Pront.         Paciente                                   Data Int.    Hora     Perm.     Acomod. Dir          Acomod. Int            Usuario Atend."	
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private aTipoAcomod := {STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019}//"Ambulatorio" # "Enfermaria" # "Apartamento" # "Suite" # "Sala Cirurgica" # "Uti" # "Uti-Neo" # "Semi-Uti"
Private lEnd         := .F.
Private lAbortPrint  := .F.

Private oTotaliz
Private limite           := 220
Private tamanho          := "M"
Private nomeprog         := "HSPAHR84" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { STR0005, 1, STR0004, 2, 2, 1, "", 1}  //"Zebrado" # "Administracao"
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "HSPAHR84" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nCount		   := 0

Private cRegGer_de    := ""   //Variaveis de Filtro
Private cRegGer_ate   := ""
Private cRegAte_de    := ""  
Private cRegAte_ate   := ""
Private dDatAte_de    := "" 
Private dDatAte_ate   := ""
Private lVerif        := .F. // Usado para entrar no R3 ou no R4

 If FindFunction("TRepInUse") .And. TRepInUse() 
  lVerif := .T.
 EndIf
  
If !Pergunte("HSPR84",.T.)
 return
endif

 cRegGer_de      := mv_par01  //Variaveis de Filtro
 cRegGer_ate     := mv_par02
 cRegAte_de      := mv_par03 
 cRegAte_ate     := mv_par04
 dDatAte_de      := mv_par05         
 dDatAte_ate     := mv_par06 
 
 If lVerif
  pergunte("HSPR84",.F.)
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

  aReturn[4] := 2
  nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
 EndIf
 
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef ³ Autor ³ Rogerio / Giuvany     ³ Data ³ 29/07/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

Static Function ReportDef()
 
 Local oReport 
 Local oSection1
 Local oCell
 Local oBreak  
 Local oTotaliza
 
 oReport := TReport():New("HSPAHR84",STR0003,"HSPR84",{|oReport| R84IMP(oReport)}, STR0001 + STR0002)

 oReport:SetTotalInLine(.F.)
 
 oSection1 := TRSection():New(oReport, "", "QRYSQL")
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetHeaderSection(.T.)
 oSection1:SetTotalInLine(.F.)      
 
 oCell := TRCell():New(oSection1,"GCY_REGATE","QRYSQL",STR0020,, 12) 
 oCell := TRCell():New(oSection1,"GCY_REGGER","QRYSQL",STR0021,, 12) 
 oCell := TRCell():New(oSection1,"GCY_NOME","QRYSQL",STR0022,, 30) 
 oCell := TRCell():New(oSection1,"GCY_DATATE","QRYSQL",STR0023,, 12)   
 oCell := TRCell():New(oSection1,"GCY_HORATE","QRYSQL",STR0028,, 12)    
 oCell := TRCell():New(oSection1,"Data Int.","QRYSQL","",, 12)  
 oCell := TRCell():New(oSection1,"cPerm","QRYSQL",STR0024,, 7,,{|| cPerm := CValToChar(DateDiffDay(("QRYSQL")->GCY_DATATE, dDataBase))})    
 oCell := TRCell():New(oSection1,"cAcmP","QRYSQL",STR0025,, 15,,{|| cAcmP := aTipoAcomod[Val(("QRYSQL")->Acomod_P) + 1]})  
 oCell := TRCell():New(oSection1,"cAcmA","QRYSQL",STR0026,, 15,,{|| cAcmA := aTipoAcomod[Val( ("QRYSQL")->Acomod_A) + 1]})    
 oCell := TRCell():New(oSection1,"GCY_ATENDE","QRYSQL",STR0027,, 15) 


 oTotaliz := TRFunction():new(oSection1:Cell("GCY_REGGER"),,"COUNT",,,"@E 9999"   ,,.F.,.T.,.F.)	      //totalizador
 
Return (oReport)         
                                                                         	`					
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R84Imp   ³ Autor ³ Rogerio / Giuvany     ³ Data ³ 29/07/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

Static Function R84IMP(oReport)

Local oSection1 := oReport:Section(1)

Private cCond1 := ""
Private cCond2 := ""
Private cCond3 := ""
Private cCond4 := ""

 MakeSqlExpr(oReport:uParam)                      
////////////////DBSELECTAREA("GCY") 
 oSection1:BeginQuery() 

cCond1 += "% GCY.GCY_NOME,GCY.GCY_REGATE,GCY.GCY_REGGER,GCY.GCY_DATATE,GCY.GCY_HORATE,GCY.GCY_ATENDE,GCY.GCY_DATSAI ,"
cCond1 += " GAV.GAV_MODELO  ACOMOD_A, GCM.GCM_ACOMOD  ACOMOD_P %"

cCond2 += "% " + RetSqlName("GCY") + " GCY "
cCond2 += " JOIN " + RetSqlName("GAV") + " GAV "
cCond2 += " ON GCY.GCY_QUAINT=GAV.GAV_QUARTO AND GCY.GCY_LEIINT=GAV.GAV_LEITO "
cCond2 += " AND GAV.GAV_FILIAL='" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' " 
cCond2 += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCY.GCY_REGATE=GCZ.GCZ_REGATE 
cCond2 += " AND GCZ.GCZ_FILIAL='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN "  + RetSqlName("GCM") + " GCM ON  GCZ.GCZ_CODPLA=GCM.GCM_CODPLA 
cCond2 += " AND GAV.GAV_MODELO<>GCM.GCM_ACOMOD AND GCM.GCM_FILIAL='" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' %"

//cCond3 += "  % (GCY.GCY_DATSAI='" + SPACE(LEN(GCY->GCY_DATSAI) ) + "')"
cCond3 += "% GCY.GCY_DATSAI='        ' "
cCond3 += " AND GCY.GCY_FILIAL='" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
cCond3 += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_de) + "' AND '" + DTOS(dDatAte_ate) + "'
cCond3 += " AND GCY.GCY_REGGER BETWEEN '" + cRegGer_de + "' AND '" + cRegGer_ate + "'
cCond3 += " AND GCY.GCY_REGATE BETWEEN '" + cRegAte_de + "' AND '" + cRegAte_ate + "' %"

cCond4 += "%GCY_DATATE,GCY_HORATE %"

BeginSql alias "QRYSQL"
 SELECT   	%Exp:cCond1%
 FROM     	%Exp:cCond2%
 WHERE    	%Exp:cCond3%                                      	
 ORDER BY  %Exp:cCond4% 
EndSql 

oSection1:EndQuery() 
	
// oSection1:SetParentQuery()
//	oSection1:SetParentFilter( {|G| ("QRYSQL")->GCY_REGGER  == G }, {|| ("QRYSQL")->GCY_REGGER } )    
 
 oSection1:Print() 
 oReport:SetMeter(QRYSQL->(LastRec())) 

Return 
                                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Giuvany | Rogerio  º Data ³  30/07/08   º±±
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
Local Csql:="" 

DBSELECTAREA("GCY")
  
Csql += " SELECT GCY.GCY_NOME,GCY.GCY_REGATE,GCY.GCY_REGGER,GCY.GCY_DATATE,GCY.GCY_HORATE,GCY.GCY_ATENDE,GCY.GCY_DATSAI, "
Csql += " GAV.GAV_MODELO  ACOMOD_A, GCM.GCM_ACOMOD  ACOMOD_P "
Csql += " FROM " + RetSqlName("GCY") + " GCY "
Csql += " JOIN " + RetSqlName("GAV") + " GAV "
Csql += " ON GCY.GCY_QUAINT=GAV.GAV_QUARTO AND GCY.GCY_LEIINT=GAV.GAV_LEITO "
Csql += " AND GAV.GAV_FILIAL='" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' " 
Csql += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCY.GCY_REGATE=GCZ.GCZ_REGATE 
Csql += " AND GCZ.GCZ_FILIAL='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
Csql += " JOIN "  + RetSqlName("GCM") + " GCM ON  GCZ.GCZ_CODPLA=GCM.GCM_CODPLA 
Csql += " AND GAV.GAV_MODELO<>GCM.GCM_ACOMOD AND GCM.GCM_FILIAL='" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "   
Csql += " WHERE (GCY.GCY_DATSAI='        ' )"
///Csql += " WHERE (GCY.GCY_DATSAI='"+SPACE(LEN(GCY->GCY_DATSAI))+ "')"
Csql += " AND GCY.GCY_FILIAL='" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
Csql += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_de) + "' AND '" + DTOS(dDatAte_ate) + "'
Csql += " AND GCY.GCY_REGGER BETWEEN '" + cRegGer_de + "' AND '" + cRegGer_ate + "'
Csql += " AND GCY.GCY_REGATE BETWEEN '" + cRegAte_de + "' AND '" + cRegAte_ate + "'
Csql += " ORDER BY GCY.GCY_DATATE,GCY.GCY_HORATE" 
TCQUERY Csql NEW ALIAS "QRY" 
DbSelectArea("QRY")
   
dbGotop()

If Eof()     
HS_MSGINF(STR0006,STR0007,STR0008) // "Nenhum dado foi encontrado para a selecao efetuada!" # "Atenção" # s"Validação Relat. Acomodacoes Divergentes."

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

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:
   // @nLin,00 PSAY SA1->A1_COD
//                 1                2                3                4               5                6                7                8               9              10              11              12              13              14              15
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
// "Reg. Atend.   Pront.         Paciente                                   Data Int.    Hora     Perm.     Acomod. Dir          Acomod. Int            Usuario Atend."	

@nLin, 001 Psay QRY->GCY_REGATE
@nLin, 015 Psay QRY->GCY_REGGER
@nLin, 028 Psay QRY->GCY_NOME
@nLin, 073 Psay (STOD(QRY->GCY_DATATE)) 
@nLin, 085 Psay QRY->GCY_HORATE
@nLin, 095 Psay DateDiffDay(STOD(QRY->GCY_DATATE),(dDataBase))
@nLin, 104 Psay aTipoAcomod[val(QRY->ACOMOD_P) + 1]
@nLin, 125 Psay  aTipoAcomod[val(QRY ->ACOMOD_A) + 1]
@nLin, 148 Psay QRY->GCY_ATENDE 

//Imprime abaixo

   nLin := nLin + 1 // Avanca a linha de impressao
   nCount:=nCount+1
   dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo         
nLin++

nLin++

@nLin, 001 Psay "Total Geral: " + Str(nCount)
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
