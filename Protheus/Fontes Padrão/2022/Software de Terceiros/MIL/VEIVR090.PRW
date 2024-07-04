#INCLUDE "VEIVR090.ch"
#include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEIVR090  ³ Autor ³Ricardo Farinelli      ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Relatorio de Avaliacao de veiculos efetuada na concessionaria±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao de Concessionarias                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function VEIVR090()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aOrd           := {}
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir as avaliacoes"
Local cDesc2         := STR0002 //" de veiculos executadas na concessionaria, conforme os"
Local cDesc3         := STR0003 //" parametros pre-estabelecidos."
Local cPict          := ""
Local imprime        := .T.
Local wnrel          := "VEIVR090"
Local cString        := "VA7"
Local cIndice        := ""
Local cChave         := ""
Local cCondicao      := ""
Local nIndice 		   := 0

Private titulo       := STR0004 //"Avaliacoes de Veiculos Executadas"
Private nLin         := 80
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G" 
Private Cabec1       := STR0005 //" Data       Nr.Aval.  Marca               Modelo               Combustivel Mod./Fab. Cliente                        Vlr.Inicial  Vlr.Minimo   Vlr.Tabela   Vlr.Opcion.  Vlr.Avarias  Vlr.Ocor.(+) Vlr.Ocor.(-) Vlr.Sugerido"
Private Cabec2       := " ---------- --------  --- --------------- -------------------- ----------- --------- --------- -------------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------"
Private nTipo        := 18
Private aReturn      := {STR0006, 1,STR0007, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "VIR090"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01

//ValidPerg()
pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

cIndice    := CriaTrab(nil,.F.)

cCondicao += "DTOS(VA7_DATA)>='"+Dtos(MV_PAR01)+"' .and. DTOS(VA7_DATA)<='"+Dtos(MV_PAR02)+"'"

cChave := "VA7_FILIAL+DTOS(VA7->VA7_DATA)+VA7_CODAVA"

IndRegua("VA7",cIndice,cChave,,cCondicao,STR0008) //"Aguarde Selecionando Registro para Impressao"

DbSelectArea("VA7")
nIndice := RetIndex("VA7")
#IFNDEF TOP
   dbSetIndex(cIndice+ordBagExt())
#ENDIF
dbSetOrder(nIndice+1)

RptStatus({|lEnd| VEVR090IMP(@lEnd,wnrel,cString)},Titulo)

DbSelectArea("VA7")
RetIndex()

#IFNDEF TOP
   If File(cIndice+OrdBagExt())
      fErase(cIndice+OrdBagExt())
   Endif
#ENDIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VEVR090IMPº Autor ³ Ricardo Farinelli  º Data ³  05/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar para a impressao do relatorio              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function VEVR090IMP(lEnd,wnrel,cString)

Local aTotais  := {} // Vetor totalizado
Local nWnk     := 0
aTotais := Array(1,8)
For nwnk := 1 To len(aTotais[1])
  aTotais[1,nwnk] := 0
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao 1 - Preco Inicial                        ³
//³Posicao 2 - Preco Minimo                         ³
//³Posicao 3 - Preco Tabela                         ³
//³Posicao 4 - Preco Opcionais                      ³
//³Posicao 5 - Preco Avarias                        ³
//³Posicao 6 - Preco Ocorrencias (+)                ³
//³Posicao 7 - Preco Ocorrencias (-)                ³
//³Posicao 8 - Preco Sugerido para Compra           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MV_PAR01 = Data Inicial - Data de inicio ou branco para desde o comeco                                ³
//³MV_PAR02 = Data Final - Data final para o escopo do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

DbselectArea("VA7")

SetRegua(RecCount())

Titulo +=STR0009+dToc(MV_PAR01) //" de "
Titulo +=STR0010+dToc(MV_PAR02) //" a "

VE1->(DbsetOrder(1))
SA1->(DbsetOrder(1))
DbselectArea("VA7")
DbSeek(xFilial("VA7"))
Do While VA7->VA7_FILIAL == xFilial("VA7") .and. !VA7->(Eof())

  If lAbortPrint .or. lEnd
    @nLin,00 PSAY STR0011 //"*** CANCELADO PELO OPERADOR ***"
    Exit
  Endif

  If nLin > 58
    Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
    nLin := 9
  Endif

  @ nLin,001 PSAY DTOC(VA7->VA7_DATA)
  @ nLin,012 PSAY VA7->VA7_CODAVA
  VE1->(Dbseek(xFilial("VA7")+VA7->VA7_MARCA))
  @ nLin,022 PSAY VA7->VA7_MARCA
  @ nLin,026 PSAY Subs(VE1->VE1_DESMAR,1,20)
  @ nLin,042 PSAY Subs(VA7->VA7_MODVEI,1,20)
  @ nLin,063 PSAY X3Combo("VA7_COMBUS",VA7->VA7_COMBUS)
  @ nLin,075 PSAY VA7_ANOMOD+"/"+VA7_ANOFAB
  @ nLin,085 PSAY VA7_CODCLI+"/"+VA7_LOJA
  SA1->(dbseek(xFilial("SA1")+VA7->(VA7_CODCLI+VA7_LOJA)))
  @ nLin,095 PSAY SA1->A1_NREDUZ
  @ nLin,116 PSAY Transform(VA7->VA7_PREINI,"@E 999999999.99")
  @ nLin,129 PSAY Transform(VA7->VA7_PREMIN,"@E 999999999.99")  
  @ nLin,142 PSAY Transform(VA7->VA7_PRETAB,"@E 999999999.99")
  @ nLin,155 PSAY Transform(VA7->VA7_PREOPC,"@E 999999999.99")
  @ nLin,168 PSAY Transform(VA7->VA7_PREAVA,"@E 999999999.99")
  @ nLin,181 PSAY Transform(VA7->VA7_PREOC1,"@E 999999999.99")
  @ nLin,194 PSAY Transform(VA7->VA7_PREOC2,"@E 999999999.99")
  @ nLin,207 PSAY Transform(VA7->VA7_PREPAG,"@E 999999999.99")
  nLin++
  If nLin > 58
    Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
    nLin := 9
  Endif
  aTotais[1,1] += VA7->VA7_PREINI
  aTotais[1,2] += VA7->VA7_PREMIN
  aTotais[1,3] += VA7->VA7_PRETAB
  aTotais[1,4] += VA7->VA7_PREOPC
  aTotais[1,5] += VA7->VA7_PREAVA  
  aTotais[1,6] += VA7->VA7_PREOC1
  aTotais[1,7] += VA7->VA7_PREOC2
  aTotais[1,8] += VA7->VA7_PREPAG
        
  VA7->(Dbskip())
Enddo
nLin++
@ nLin,022 PSAY STR0012 //"Totais do Relatorio: "
@ nLin,116 PSAY Transform(aTotais[1,1],"@E 999999999.99")
@ nLin,129 PSAY Transform(aTotais[1,2],"@E 999999999.99")  
@ nLin,142 PSAY Transform(aTotais[1,3],"@E 999999999.99")
@ nLin,155 PSAY Transform(aTotais[1,4],"@E 999999999.99")
@ nLin,168 PSAY Transform(aTotais[1,5],"@E 999999999.99")
@ nLin,181 PSAY Transform(aTotais[1,6],"@E 999999999.99")
@ nLin,194 PSAY Transform(aTotais[1,7],"@E 999999999.99")
@ nLin,207 PSAY Transform(aTotais[1,8],"@E 999999999.99")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ Ricardo Farinelli  º Data ³  05/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

aAdd(aRegs,{cPerg,"01","Data Inicial      ?","","","mv_ch1","D", 08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})  
aAdd(aRegs,{cPerg,"02","Data Final        ?","","","mv_ch2","D", 08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""}) 

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

dbSelectArea(_sAlias)
Return
*/
