#INCLUDE "veipr820.ch"

#Include "protheus.ch"
#Include "Fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPR820 ³ Autor ³ Andr‚                 ³ Data ³ 27/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Participantes                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION VEIPR820

Local _ni,i,j := 0
Private oGrupo1,oCota1

Private cGrupo1 := "     "
Private cCota1 := "    "
Private cDescr := " "
Private cNomCl := " "

PRIVATE aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 }  //### //"Zebrado"###"Administracao"

cAlias  := "VP1"
cNomRel := "VEIPR820"
cGPerg  := "VPR820"
cTitulo := STR0003 //"Relatorio de Participantes"
cDesc1  := STR0003 //"Relatorio de Participantes"
aOrdem  := {STR0004} //"Codigo"
lHabil  := .f.
cTamanho:= "P"
nOpca   := 0
NomeRel := SetPrint(cAlias,cNomRel,cGPerg,@cTitulo,cDesc1,,,lHabil,,,cTamanho)

if nLastKey == 27
   Return
Endif

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set Device  to Printer

cbTxt    := Space(10)
cbCont   := 0
cString  := "VP1"
Li       := 80
m_Pag    := 1
wnRel    := "VEIPR820"
cTitulo  := STR0003 //"Relatorio de Participantes"
cabec1   := ""
cabec2   := ""
nomeprog := "VEIR820"
tamanho  := "M"
nCaracter:= 15
nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
aPosGru  := {}

DbSelectArea("VP1")
DbGotop()

nUsado:=0
dbSelectArea("SX3")
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


DbSelectArea( "VP1" )
DbSetOrder(1)

If Empty(MV_PAR01)

	DbSeek( xFilial("VP1") )

Else

	DbSeek( xFilial("VP1") + MV_PAR01 )        

EndIf 

Do While !Eof() .AND. VP1->VP1_FILIAL == XFILIAL("VP1")

    If (VP1->VP1_CODGRU >= MV_PAR01 .or.Empty(MV_PAR01)) .and. (VP1->VP1_CODGRU <= MV_PAR02 .or. Empty(MV_PAR02))

       AADD(aVP12,Array(nUsado+1))
       For _ni:=1 to nUsado 	
           aVP12[Len(aVP12),_ni]:=FieldGet(FieldPos(aVP11[_ni,2]))
       Next
       aVP12[Len(aVP12),nUsado+1]:=.F.
    EndIf
    dbSkip()

EndDo

@ nLin,0 PSAY Repl("*",132)
@ nLin++              

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

      	If j+1 <= Len(aVP11)

        	 j++
	         @ nLin,040 PSAY  aVP11[j,1]   // Imprime Dados do Participante
    	     @ nLin,055 PSAY  aVP12[i,j]   // Imprime Dados do Participante

	    Endif
	    
	Next
	
	@ nLin++,0 PSAY Repl("-",132)
	
Next

@ nLin++,0 PSAY Repl("*",132)

Set Printer to
Set Device  to Screen

If aReturn[5] == 1  

	OurSpool(NomeRel)

EndIf       

Return .f.
