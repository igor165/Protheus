#include "Protheus.ch"
#include "Veivr160.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVR140 ³ Autor ³ ANDRE F APRILE        ³ Data ³ 18/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio das movimentacoes do caixa                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao de Concessionarias                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVR160

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "VEIVR190"
Private nTipo        := 15
Private aReturn      := { STR0002, 1, STR0003, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "VEIV160"
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "VEIVR190"
Private M->VE6_INDREG:="1"
dbSelectArea("VE6")
dbSetOrder(1)

//Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport 
Local oSection1 
Local oCell

oReport   := TReport():New("VEIVR190",OemToAnsi(STR0001),"",{|oReport| RunReport(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{})

TRCell():New(oSection1,"",,""   ,"@!" ,200,, {|| cStr } )

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RunReport³ Autor ³ ANDRE F APRILE        ³ Data ³ 18/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao de Concessionarias                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
              
Local cont
Local oSection1 := oReport:Section(1)
Local aPagtos := {{"DH",0},{"CH",0},{"CC",0},{"OU",0}}
Local aVencto := {}
Local aTotais := {0,0,0,0}
Local nVencto := 0

Pergunte("VEIV160",.f.)

cAliasSE1 := GetNextAlias()
BeginSql Alias cAliasSE1
   SELECT SE1.*,SA1.A1_NOME FROM %Table:SE1% SE1
   LEFT OUTER JOIN SA1990 SA1 ON ( SA1.A1_FILIAL = %xFilial:SA1% AND SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA)
	WHERE SE1.E1_FILIAL = %xFilial:SE1% 
		AND SE1.%NotDel%
		AND SE1.E1_EMISSAO >= %Exp:MV_PAR01%
		AND SE1.E1_EMISSAO <= %Exp:MV_PAR02%
EndSql

oReport:SetMeter((cAliasSE1)->(RecCount()))
oSection1:Init(.t.)

cStr := STR0004 //".                                                                              [                    Pagamentos                   ]"
oSection1:PrintLine()
cStr := STR0005 //"[Emissao] [Num. Docto] [Ciente                                  ] [     Total] [  Dinheiro] [    Cheque] [    Cartao] [    Outros]"
oSection1:PrintLine()
			
cStr := Repl("-",180)
oSection1:PrintLine()
  
dbSelectArea(cAliasSE1)
cDoc := (cAliasSE1)->E1_NUM
Do While !Eof() .and. (cAliasSE1)->E1_FILIAL == xFilial("SE1")
   if stod((cAliasSE1)->E1_VENCTO) > dDataBase
      cStr := (cAliasSE1)->E1_NUM+" "+(cAliasSE1)->E1_CLIENTE+"-"+(cAliasSE1)->E1_LOJA+" "+substr((cAliasSE1)->A1_NOME,1,30)+"   "+Transform(stod((cAliasSE1)->E1_EMISSAO),"@D")+"   "+Transform(stod((cAliasSE1)->E1_VENCTO),"@D")+"   "
      aadd(aVencto,{cStr, (cAliasSE1)->E1_VALOR })
      nVencto += (cAliasSE1)->E1_VALOR
	   dbSelectArea(cAliasSE1)
   	dbSkip()
      cDoc := (cAliasSE1)->E1_NUM
      Loop
   Endif
   if cDoc <> (cAliasSE1)->E1_NUM
      cStr := Transform(stod((cAliasSE1)->E1_EMISSAO),"@D")+"   "+(cAliasSE1)->E1_NUM+" "+(cAliasSE1)->E1_CLIENTE+"-"+(cAliasSE1)->E1_LOJA+" "+substr((cAliasSE1)->A1_NOME,1,30)+"   "
      cStr += Transform(aPagtos[1,2]+aPagtos[2,2]+aPagtos[3,2]+aPagtos[4,2],"@E 999,999.99")+"   "+Transform(aPagtos[1,2],"@E 999,999.99")+"   "+Transform(aPagtos[2,2],"@E 999,999.99")+"   "+Transform(aPagtos[3,2],"@E 999,999.99")+"   "+Transform(aPagtos[4,2],"@E 999,999.99")
      oSection1:PrintLine()
      aPagtos := {{"DH",0},{"CH",0},{"CC",0},{"OU",0}}
      cDoc := (cAliasSE1)->E1_NUM
   Endif
   nPos := Ascan(aPagtos,{|x| x[1] == alltrim((cAliasSE1)->E1_TIPO) }) 
   if nPos > 0 
      aPagtos[nPos,2] += (cAliasSE1)->E1_VALOR
      aTotais[nPos] += (cAliasSE1)->E1_VALOR
   else
      aPagtos[4,2] += (cAliasSE1)->E1_VALOR
      aTotais[4] += (cAliasSE1)->E1_VALOR
   Endif
   dbSelectArea(cAliasSE1)
   dbSkip()
EndDo

oReport:SkipLine(1)

cStr := Repl("-",180)
oSection1:PrintLine()

cStr := STR0006+space(57)+Transform(aTotais[1]+aTotais[2]+aTotais[3]+aTotais[4],"@E 999,999.99")+"   "+Transform(aTotais[1],"@E 999,999.99")+"   "+Transform(aTotais[2],"@E 999,999.99")+"   "+Transform(aTotais[3],"@E 999,999.99")+"   "+Transform(aTotais[4],"@E 999,999.99")
oSection1:PrintLine()

if Len(aVencto) > 0 
	oReport:SkipLine(2)

	cStr := Repl("-",180)
	oSection1:PrintLine()
	cStr := STR0009
	oSection1:PrintLine()
	cStr := Repl("-",180)
	oSection1:PrintLine()

	oReport:SkipLine(1)

	cStr := STR0007 //"[Num. Docto] [Ciente                                  ] [Emissao] [Vencto ] [     Total]"
	oSection1:PrintLine()
	cStr := Repl("-",180)
	oSection1:PrintLine()

   For cont := 1 to len(aVencto)
       cStr := aVencto[cont,1]+Transform(aVencto[cont,2],"@E 999,999.99")
       oSection1:PrintLine()
   Next
	   
	cStr := Repl("-",180)
	oSection1:PrintLine()

	cStr := STR0008+space(68)+Transform(nVencto,"@E 999,999.99")
	oSection1:PrintLine()
   
Endif

oSection1:Finish()

Return
