#INCLUDE "veipr800.ch"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPR800 ³ Autor ³ Andr‚                 ³ Data ³ 27/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Posicao do Participante                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPR800

Local _ni,i,j	     := 0
Private oGrupo1,oCota1
Private aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 }  //### //"Zebrado"###"Administracao"
Private cGrupo1  := space(5)
Private cCota1   := space(4)
Private cDescr   := " "
Private cNomCl   := " "
Private nLin     := 1
Private Col      := 001

cAlias  := "VP3"
cNomRel := "VEIPR800"
cPerg  := "VEI800"
cTitulo := STR0003 //"Relatorio de Bens"
cDesc1  := STR0003 //"Relatorio de Bens"
aOrdem  := {STR0004} //"Codigo"
lHabil  := .f.
cTamanho:= "P"
nOpca   := 0

//If !PERGUNTE("VEI800",.T.)
  // Return
//EndIf

NomeRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,,,lHabil,,,cTamanho)

if nLastKey == 27
   Return
Endif

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set Device  to Printer

cbTxt    := Space(10)
cbCont   := 0
cString  := "VP3"
Li       := 80
m_Pag    := 1
cabec1   := ""
cabec2   := ""
nomeprog := "VEIPR800"
tamanho  := "M"
nCaracter:= 15
aPosGru  := {}

DbSelectArea("VP6")
DbGotop()

nUsado:=0
dbSelectArea("SX3")
dbSeek("VP6")


aVP61:={}
While !Eof().And.(x3_arquivo=="VP6")
   if X3USO(x3_usado).and.cNivel>=x3_nivel
      nUsado:=nUsado+1
      aadd(aVP61,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
           x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context } )
   Endif
   dbSkip()
End

aVP62:={}
dbSelectArea("VP6")
dbSetOrder(1)
dbGotop()

if !Empty(mv_par01)
   DbSeek(xFilial("VP6")+mv_par01)
Else
   DbSeek(xFilial("VP6"))
Endif

While !eof().And. VP6->VP6_FILIAL == xFilial("VP6")
   if !Empty(mv_par01) .or. !Empty(mv_par02)
      if VP6_CODBEM < MV_PAR01 .or. VP6_CODBEM > MV_PAR02
         Exit
      Endif
   Endif
   AADD(aVP62,Array(nUsado+1))
   For _ni:=1 to nUsado
       aVP62[Len(aVP62),_ni]:=FieldGet(FieldPos(aVP61[_ni,2]))
   Next
   aVP62[Len(aVP62),nUsado+1]:=.F.
   dbSkip()
End

Col  := 001
nLin := 001

FS_CABEC()

Col := 001
nLin++

For i:=1 to Len(aVP62)

   For j:=1 to Len(aVP61)
      if aVP61[j,8] == "C"
         @ nLin,Col PSAY  aVP62[i,j]    // Imprime Dados da Parcela
      Elseif aVP61[j,8] == "N"
         aVP62[i,j] := Trans(aVP62[i,j],aVP61[j,3])
         @ nLin,Col PSAY  aVP62[i,j]    // Imprime Dados da Parcela
      Else
         @ nLin,Col PSAY  aVP62[i,j]    // Imprime Dados da Parcela
      Endif
      if Col < 133
          Col := Col + aVP61[j,4]+4
      Else
          Col := 001
          nLin++
      Endif
   Next

   Col := 001
   nLin++

   if nLin > 65
      nLin := 1
      FS_CABEC()
      nLin++
      nCol := 001
  Endif
      Col := 001
Next

@ nLin++,0 PSAY Repl("=",132)


Set Printer to
Set Device  to Screen

IF aReturn[5] == 1
   ourspool(cNomRel)
Endif


Return .f.




Static Function FS_CABEC()
Local x := 0
nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
For x:=1 to Len(aVP61)
    @ nLin,Col PSAY  Substr(aVP61[x,1],1,aVP61[x,4])    // Imprime Dados da Parcela
    if Col < 133
       Col := Col + aVP61[x,4]+4
    Else
       Col := 001
       nLin++
    Endif
Next
@ ++nLin,0 PSAY Repl("-",132)  


Return
