#INCLUDE "veipr850.ch"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPR850 ³ Autor ³ Andr‚                 ³ Data ³ 15/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Posicao dos Grupos                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION VEIPR850

LOCAL i := 0
PRIVATE aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 }  //### //"Zebrado"###"Administracao"

cAlias  := "VP3"
cNomRel := "VEIPR850"
cPerg  := "VPR850"
cTitulo := STR0003 //"Posicao dos Grupos"
cDesc1  := STR0003 //"Posicao dos Grupos"
aOrdem  := {STR0004} //"Grupo"
lHabil  := .f.
cTamanho:= "P"
nOpca   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Pergunte("VPR850",.t.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Grupo Inicial                            ³
//³ mv_par02        //  Grupo Final                              ³
//³ mv_par03        //  Cota Inicial                             ³
//³ mv_par04        //  Cota Final                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

NomeRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,,,lHabil,aOrdem,,cTamanho)

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
wnRel    := "VEIR850"
cTitulo  := STR0003 //"Posicao dos Grupos"
cabec1   := STR0005 //" Grupo  Descricao                 Meses  Cotas        Aquisicao  Antecipac/Lance            Total   Bens Entregues            Saldo"
cabec2   := " -----  ------------------------  -----  -----  ---------------  ---------------  ---------------  ---------------  ---------------"
nomeprog := "POSGRUPO"
tamanho  := "M"
nCaracter:= 15
nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
aPosGru  := {}

// Variaveis p/ Calculo

nCotas := 0         // Quantidade de Cotas no Grupo
nNorma := 0         // Normal
nLa_An := 0         // Valor do Lance / Antecipacao
nTotal := 0         // Total
nBemEn := 0         // Seguro/Outros
nSaldo := 0         // Saldo
sLa_An := 0         // Resumo dos Valores Lances / Antecipacoes
sNorma := 0         // Resumo dos Valores Normais das Parcelas
sBemEn := 0         // Resumo dos Valores dos Bens Entregues
sQtdGr := 0         // Quantidade de Grupos Existente
sQtdCt := 0         // Quantidade de Cotas Existente

DbSelectArea("VP3")
if !Empty(mv_par01) 
   DbSeek(xFilial("VP3")+mv_par01)
Else
   DbSeek(xFilial("VP3"))
EndIf   

xGrupo := VP3_CODGRU

Do While !EOF() .and. VP3->VP3_FILIAL == xFilial("VP3")

   if (xGrupo >= mv_par01 .or. Empty(mv_par01)) .and. (xGrupo <= mv_par02 .or. Empty(mv_par01))

      xGrupo := VP3_CODGRU
      xDesGr := VP3_DESGRU
      xNumMs := VP3_NUMMES

      DbSelectArea("VP1")
      DbGotop()
      DbSeek(xFilial("VP1")+VP3->VP3_CODGRU)

      if mv_par03 # "0001"
         if !DbSeek(xFilial("VP1")+VP3->VP3_CODGRU+mv_par03)
            Return
         Endif
      Endif

      Do while !Eof() .and. VP1->VP1_FILIAL == xFilial("VP1")

         if VP1_CODGRU # xGrupo
            Exit
         Endif

         if (VP1_NUMCOT >= mv_par03 .or. Empty(mv_par03)) .and. (VP1_NUMCOT <= mv_par04 .or. Empty(mv_par04))

            if !Empty(VP1_DATCON)
               DbSelectArea("VP6")
               DbGotop()
               if DbSeek(xFilial("VP6")+VP1->VP1_CODBEM)
                  nBemEn := nBemEn + VP6->VP6_VALBEM
               Endif
               DbSelectArea("VP1")
            Endif

            nCotas++

            DbSelectArea("VP4")
            DbGotop()
            DbSeek(xFilial("VP4")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI)
            wCota := VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI
            Do while !Eof() .and. VP4->VP4_FILIAL == xFilial("VP4")
               if VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI == wCota
                  nLa_An := nLa_An + VP4_VALLAN
               Else
                  Exit
               Endif
               DbSkip()
            Enddo

            DbSelectArea("VP2")
            DbGoTop()
            DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI)
            wCota := VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI
            Do while !EOF() .and. VP2->VP2_FILIAL == xFilial("VP2")
               if VP2->VP2_CODGRU+VP2->VP2_NUMCOT+VP2->VP2_CODCLI == wCota
                  if !Empty(VP2_DATPAG)
                     nNorma := nNorma + VP2_VALPAR
                  Endif
                  DbSkip()
               Else
                  Exit
               Endif
            Enddo

            DbSelectArea("VP1")
            DbSkip()

         Endif

      Enddo

      aadd(aPosGru,xGrupo+"  "+substr(xDesGr,1,24)+"  "+Str(xNumMs,5)+"   "+Str(nCotas,4)+"   "+Trans(nNorma,"@E 999,999,999.99")+"   "+Trans(nLa_An,"@E 999,999,999.99")+"   "+Trans((nNorma+nLa_An),"@E 999,999,999.99")+"   "+Trans(nBemEn,"@E 999,999,999.99")+"   "+Trans((nLa_An+nNorma)-nBemEn,"@E 999,999,999.99"))

      sLa_An := sLa_An + nLa_An
      sNorma := sNorma + nNorma
      sBemEn := sBemEn + nBemEn

      sQtdGr++
      sQtdCt := sQtdCt + nCotas

      nCotas := nLa_An := nNorma := nBemEn := 0

      DbSelectArea("VP3")

      DbSkip()

   Else     
   
      DbSkip()
      
   Endif

Enddo

For i:=1 to Len(aPosGru)

	If nLin >= 58
        
      	nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
    	//@ nLin++ , 00 psay Repl("*",132) 
    	
	EndIf  

   @ nLin++,1 PSAY  aPosGru[i]      // Imprime Dados do Grupo
Next

xDesGr := Space(24)
xNumMs := Space(05)

@ nLin++,0 PSAY Repl("=",132)
@ nLin++,1 PSAY StrZero(sQtdGr,5)+"  "+substr(xDesGr,1,24)+"  "+xNumMs+"   "+StrZero(sQtdCt,4)+"   "+Trans(sNorma,"@E 999,999,999.99")+"   "+Trans(sLa_An,"@E 999,999,999.99")+"   "+Trans((sNorma+sLa_An),"@E 999,999,999.99")+"   "+Trans(sBemEn,"@E 999,999,999.99")+"   "+Trans((sLa_An+sNorma)-sBemEn,"@E 999,999,999.99")

Set Printer to
Set Device  to Screen

If aReturn[5] == 1  

	OurSpool(NomeRel)

EndIf  

Return(.t.)