#INCLUDE "veipr860.ch"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPR860 ³ Autor ³ Andr‚                 ³ Data ³ 22/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Posicao do Participante                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPR860

Local aVP11:={} , aVP12:={} , aVP41:={} , aVP42:={} , aVP21:={} , aVP22:={}
Local _ni,j,i,x := 0

Private cGrupo1 := "     "
Private cCota1 := "    "
Private cDescr := " "
Private cNomCl := " "

PRIVATE aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 }  //### //"Zebrado"###"Administracao"

cAlias  := "VP3"
cNomRel := "VEIPR860"
cPerg  := "VEI860"
cTitulo := STR0003 //"Posicao do Participante"
cDesc1  := STR0003 //"Posicao do Participante"
aOrdem  := {STR0004} //"Grupo+Cota"
lHabil  := .f.
cTamanho:= "P"
nOpca   := 0

//if !Pergunte("VEI860",.T.)      // Pergunta qual o Grupo/Cota a Processar?
  // Return
//Endif


NomeRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,,,lHabil,,,cTamanho)

if nLastKey == 27
   Return
Endif
                                                                            
Pergunte("VEI860",.F.)      // Pergunta qual o Grupo/Cota a Processar?

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set Device  to Printer

cbTxt    := Space(10)
cbCont   := 0
cString  := "VP3"
Li       := 80
m_Pag    := 1
wnRel    := "POSPART"
cTitulo  := STR0003 //"Posicao do Participante"
cabec1   := ""
cabec2   := ""
nomeprog := "VEIR860"
tamanho  := "M"
nCaracter:= 15
nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
aPosGru  := {}

DbSelectArea("VP1")
DbSetOrder(1)
DbGotop()
if DbSeek(xFilial("VP1")+mv_par01+mv_par02)

   ////////////// Criacao do Array VP1

   nUsado:=0
   dbSelectArea("SX3") 
   dbsetorder(1)
   dbSeek("VP1")
   aVP11:={}
   While !Eof().And.(x3_arquivo=="VP1")
      if X3USO(x3_usado).and.cNivel>=x3_nivel
         nUsado:=nUsado+1
         aadd(aVP11,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
              x3_tamanho, x3_decimal,x3_valid,;
              x3_usado, x3_tipo, x3_arquivo, x3_context } )
      Endif
      dbSkip()
   End

   aVP12:={}
   dbSelectArea("VP1")
   dbSetOrder(1)
   dbSeek(xFilial("VP1")+mv_par01+mv_par02)
   While !eof() .and. VP1->VP1_CODGRU+VP1->VP1_NUMCOT == mv_par01+mv_par02
       AADD(aVP12,Array(nUsado+1))
       For _ni:=1 to nUsado
           aVP12[Len(aVP12),_ni]:=FieldGet(FieldPos(aVP11[_ni,2]))
       Next
       aVP12[Len(aVP12),nUsado+1]:=.F.
       dbSkip()
   End

   ////////////// Criacao do Array VP4

   nUsado:=0
   dbSelectArea("SX3")
   dbSeek("VP4")
   aVP41:={}
   While !Eof().And.(x3_arquivo=="VP4")
      if X3USO(x3_usado).and.cNivel>=x3_nivel.and.!(x3_campo $ [VP4_CODGRU#VP4_NUMCOT#VP4_CODCLI#VP4_NOMCLI])
         nUsado:=nUsado+1
         aadd(aVP41,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
              x3_tamanho, x3_decimal,x3_valid,;
              x3_usado, x3_tipo, x3_arquivo, x3_context } )
      Endif 
     
      dbSkip()
   End

   aVP42:={}
   dbSelectArea("VP4")
   dbSetOrder(1)
   dbSeek(xFilial("VP4")+mv_par01+mv_par02)
   While !eof() .and. VP4->VP4_CODGRU+VP4->VP4_NUMCOT == mv_par01+mv_par02
       AADD(aVP42,Array(nUsado+1))
       For _ni:=1 to nUsado
           aVP42[Len(aVP42),_ni]:=FieldGet(FieldPos(aVP41[_ni,2]))
       Next
       aVP42[Len(aVP42),nUsado+1]:=.F.
       dbSkip()
   End

   ////////////// Criacao do Array VP2

   nUsado:=0
   dbSelectArea("SX3")
   dbSeek("VP2")
   aVP21:={}
   While !Eof().And.(x3_arquivo=="VP2")
      if X3USO(x3_usado).and.cNivel>=x3_nivel.and.!(x3_campo $ [#VP2_LOJA#VP2_VALBEM#VP2_ACRPAG#VP2_VALDIF#VP2_DESPAG#VP2_PERIDE#VP2_PERLAN#VP2_PARPAG#VP2_PERANT#VP2_LANANT#VP2_SALANT#VP2_VALANT#VP2_PGTANT#VP2_PARANT])
         nUsado:=nUsado+1
         aadd(aVP21,{ TRIM(X3Titulo()), x3_campo,x3_tipo, if(x3_tipo#"N",x3_picture,"@E 999,999.99"),;
              x3_tamanho, x3_decimal,x3_valid,;   //
              x3_usado, x3_tipo, x3_arquivo, x3_context } )
      Endif
      dbSkip()
   End

   aVP22:={}
   dbSelectArea("VP2")
   dbSetOrder(1)
   dbSeek(xFilial("VP2")+mv_par01+mv_par02)
   While !eof() .and. VP2->VP2_CODGRU+VP2->VP2_NUMCOT ==mv_par01+mv_par02
       AADD(aVP22,Array(nUsado+1))
       For _ni:=1 to nUsado
           aVP22[Len(aVP22),_ni]:=FieldGet(FieldPos(aVP21[_ni,2]))
       Next
       aVP22[Len(aVP22),nUsado+1]:=.F.
       dbSkip()
   End

Endif
@ nLin,0 PSAY Repl("*",132)
For i:=1 to Len(aVP12)

	If nLin >= 60

	   	nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		@ nLin,0 PSAY Repl("*",132)
		@ nLin++

	EndIf

   For j:=1 to Len(aVP11)

		If nLin >= 60

		   	nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			@ nLin,0 PSAY Repl("*",132)
			@ nLin++

		EndIf

      @ ++nLin,001 PSAY aVP11[j,1]      // Imprime Dados do Participante
      @ nLin  ,015 PSAY aVP12[i,j]      // Imprime Dados do Participante
      if j+1 <= Len(aVP11)
         j++
         @ nLin,040 PSAY  aVP11[j,1]   // Imprime Dados do Participante
         @ nLin,055 PSAY  aVP12[i,j]   // Imprime Dados do Participante
      Endif
    Next
Next

@ ++nLin,1 PSAY Repl("-",131)

Col := 001
nLin++
For x:=1 to Len(aVP41)

	If nLin >= 60

	   	nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		@ nLin,0 PSAY Repl("*",132)
		@ nLin++

	EndIf

    @ nLin,Col PSAY  aVP41[x,1]    // Imprime Dados do Lance

    if Col < 133
       Col := Col + Len(aVP41[x,1])+5
    Else
       Col := 001
       nLin++
    Endif

Next

Col := 001
nLin++

For i:=1 to Len(aVP42)

	If nLin >= 60

	   	nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		@ nLin,0 PSAY Repl("*",132)
		@ nLin++

	EndIf

   For j:=1 to Len(aVP41)

		If nLin >= 60

		   	nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			@ nLin,0 PSAY Repl("*",132)
			@ nLin++

		EndIf

      if aVP41[j,8] == "C"
         @ nLin,Col PSAY  aVP42[i,j]    // Imprime Dados do Lance
      Elseif aVP21[j,8] == "N"
         aVP42[i,j] := Trans(aVP42[i,j],aVP41[j,3])
         @ nLin,Col PSAY  aVP42[i,j]    // Imprime Dados do Lance
      Else
         @ nLin,Col PSAY  aVP42[i,j]    // Imprime Dados do Lance
      Endif
      if Col < 133
          Col := Col + aVP41[j,4]+10
      Else
          Col := 001
          nLin++
      Endif
   Next
   Col := 001
   nLin++
Next

@ nLin,0 PSAY Repl("-",132)

Col := 001
nLin++

For x:=1 to Len(aVP21)
    If nLin >= 60
       nLin := 1
       nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
       @ nLin,0 PSAY Repl("*",132)
       @ nLin++
    EndIf
    @ nLin,Col PSAY  Substr(aVP21[x,1],1,aVP21[x,5])    // Imprime Dados da Parcela
    if Col < 133
       if aVP21[x,3] == "N" .and. aVP21[x,5] < 10
          Col := Col + aVP21[x,5]+6
       Else
          Col := Col + aVP21[x,5]+1
       Endif   
    Else
       Col := 001
       nLin++
    Endif
Next

Col := 001
nLin++

For i:=1 to Len(aVP22)
	If nLin >= 60
       nLin := 1
       nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
       @ nLin,0 PSAY Repl("*",132)
       @ nLin++
    EndIf
    For j:=1 to Len(aVP21)
       If nLin >= 60
          nLin := 1
          nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
          @ nLin,0 PSAY Repl("*",132)
          @ nLin++
       EndIf

       If aVP21[j,3] == "C"
          @ nLin,Col PSAY  aVP22[i,j]    // Imprime Dados da Parcela
       Elseif aVP21[j,3] == "N"
          aVP22[i,j] := Trans(aVP22[i,j],aVP21[j,4])
          @ nLin,Col PSAY  aVP22[i,j]    // Imprime Dados da Parcela
       Else
          @ nLin,Col PSAY  aVP22[i,j]    // Imprime Dados da Parcela
       Endif

       if Col < 133
          if aVP21[j,3] == "N" .and. aVP21[j,5] < 10
             Col := Col + aVP21[j,5]+4
          Else
             Col := Col + aVP21[j,5]+1
          Endif   
       Else
          Col := 001
          nLin++
       Endif
   Next

   Col := 001
   nLin++

Next

@ nLin++,0 PSAY Repl("=",132)

Set Printer to
Set Device  to Screen

If aReturn[5] == 1

	OurSpool(NomeRel)

EndIf       
	
Return(.t.)                                                                

////////////////////

Function Valida(Arg)

if Arg == 1

   mv_par01 := StrZero(Val(mv_par01),5)
   DbSelectArea("VP3")
   DbGotop()

   if DbSeek(xFilial("VP3")+mv_par01)
      cDescr := VP3->VP3_DESGRU
      Return .t.
   Endif

Elseif Arg == 2

   mv_par02 := StrZero(Val(mv_par02),4)
   DbSelectArea("VP1")
   DbGotop()

   if DbSeek(xFilial("VP1")+mv_par01+mv_par02)
      cCodCli := VP1->VP1_CODCLI
      DbSelectArea("SA1")
      DbGotop()
      if DbSeek(xFilial("  ")+cCodCli)
         cNomCl := SA1->A1_NOME
         Return .t.
      Else
         Return .f.
      Endif
   Endif

Endif

Return .f.
