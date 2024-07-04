#INCLUDE "veipr840.ch"

#Include "protheus.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPR840 ³ Autor ³ Andr‚                 ³ Data ³ 28/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Lances                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPR840                 

Local _ni,x,i,j := 0
Private oGrupo1,oCota1
Private cGrupo1:= "     "
Private cDescr := " "
Private aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 }  //### //"Zebrado"###"Administracao"

cAlias  := "VP3"
cNomRel := "VEIPR840"                       
cPerg   := "VEI840"
cTitulo := STR0003 //"Relatorio de Lances"
cDesc1  := STR0003 //"Relatorio de Lances"
aOrdem  := {"Grupo+Cota"}
lHabil  := .f.
cTamanho:= "P"
nOpca   := 0

//If !Pergunte("VEI840",.t.)      // Pergunta qual o Grupo a Processar?
  // Return
//EndIf

NomeRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,,,lHabil,,,cTamanho)

if nLastKey == 27
   Return
Endif

Pergunte(cPerg,.f.)

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set Device  to Printer

cbTxt    := Space(10)
cbCont   := 0
cString  := "VP3"
Li       := 80
m_Pag    := 1
wnRel    := "VEIPR840"
cTitulo  := STR0003 //"Relatorio de Lances"
cabec1   := ""
cabec2   := ""
nomeprog := "VEIR840"
tamanho  := "M"
nCaracter:= 15
nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
aPosGru  := {}
Inclui   := .F.

dbSelectArea("VP4")
DbGotop()

nUsado:=0
dbSelectArea("SX3")
dbSeek("VP4")
aVP41:={}

While !Eof().And. (x3_arquivo==("VP4"))
  if X3USO(x3_usado).and.cNivel>=x3_nivel
      nUsado:=nUsado+1
      aadd(aVP41,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
           x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context } )
      wVar := "M->"+x3_campo
      &wVar := CriaVar(x3_campo)
   Endif
   dbSkip()
End

aVP42:={}
dbSelectArea("VP4")
dbSetOrder(1)

If !Empty(mv_par01)
   DbSeek(xFilial("VP4")+ mv_par01)
Else
   DbSeek(xFilial("VP4"))
Endif

While !eof() .and. VP4->VP4_FILIAL == xFilial("VP4")
                                                     
	If !Empty(MV_PAR01) .or. !Empty(MV_PAR02)

    	If VP4->VP4_CODGRU < MV_PAR01 .or. VP4->VP4_CODGRU > MV_PAR02 

      		exit

		EndIf

	EndIf                                               

   AADD(aVP42,Array(nUsado+1))
   For _ni:=1 to nUsado
       aVP42[Len(aVP42),_ni]:=If(aVP41[_ni,10] # "V",FieldGet(FieldPos(aVP41[_ni,2])),CriaVar(aVP41[_ni,2] ))
   Next
   aVP42[Len(aVP42),nUsado+1]:=.F.
   DbSelectArea("VP4")
   dbSkip()
Enddo
             
If Len(aVP42) # 0

	@ nLin,0 PSAY Repl("*",132)
	
	Col := 001
	nLin++
	
	For x:=1 to Len(aVP41)
		
		If nLin >= 60
		        
	   		nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
			@ nLin,0 PSAY Repl("*",132)
			@ nLin++              
			
		EndIf  
	
	    @ nLin,Col PSAY aVP41[x,1]    // Imprime Dados do Lance
	
	    If Col < 133
	    
	       If aVP41[x,4] > Len(aVP41[x,1])
	       
	          Col := Col + aVP41[x,4]+1
	          
	       Else
	       
	          Col := Col + Len(aVP41[x,1])+1
	          
	       EndIf
	       
	    Else   
	    
	       Col := 001
	       nLin++
	    
	    EndIf
	    
	Next
	
	Col := 001
	nLin++
	
	If nLin >= 60
		        
	   	nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
		@ nLin,0 PSAY Repl("*",132)
		@ nLin++              
			
	EndIf  
	
	@ nLin++,0 PSAY Repl("=",132)
	
	cGrpAnt := aVP42[1,1]
	
	For i:=1 to Len(aVP42)
	
		If nLin >= 60
		        
	   		nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
			@ nLin,0 PSAY Repl("*",132)
			@ nLin++              
			
		EndIf  
		
		If aVP42[i,1] # cGrpAnt
	    
	    	@ nLin++,0 PSAY Repl("-",132)
		
		Endif
		
		cGrpAnt := aVP42[i,1]
	   	
	   	For j:=1 to Len(aVP41)
	    
		    If nLin >= 60
		        
	   			nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
				@ nLin,0 PSAY Repl("*",132)
				@ nLin++              
			
			EndIf  
	   
	    	If aVP41[j,8] == "C"
	        
	        	@ nLin,Col PSAY aVP42[i,j]    // Imprime Dados do Lance
			
			ElseIf aVP41[j,8] == "N"
	        
	        	aVP42[i,j] := Trans(aVP42[i,j],aVP41[j,3])
	         	@ nLin,Col PSAY aVP42[i,j]    // Imprime Dados do Lance
	         	
			Else
			
	        	@ nLin,Col PSAY aVP42[i,j]    // Imprime Dados do Lance
	        	
			EndIf
	      	
	      	If Col < 133
	        
	        	If aVP41[j,4] > Len(aVP41[j,1])
	            	
	            	Col := Col + aVP41[j,4]+1
	            	
				Else
				
	            	Col := Col + Len(aVP41[j,1])+1
	         
				Endif
				
			Else
			
	        	Col := 001
	         
	      	Endif
	      	
	   	Next
	   	
	   	Col := 001
	   	nLin++
	   	
	Next
	
	@ nLin++,0 PSAY Repl("=",132)

EndIf

Set Printer to
Set Device  to Screen

If aReturn[5] == 1  

	OurSpool(NomeRel)

EndIf       

//Return(.t.)


////////////////////
Function ValLan(Arg)

if Arg == 1
   cGrupo1 := StrZero(Val(cGrupo1),5)
   if cGrupo1 == "00000"
      cDescr := STR0004 //"Todos os Grupos              "
      Return .f.
   Endif
   cDescr := Space(30)
   DbSelectArea("VP3")
   DbGotop()
   If DbSeek(xFilial("VP3")+cGrupo1)
      cDescr := VP3->VP3_DESGRU
   Else
      cDescr := STR0005 //"Nao Encontrado ...           "
      oGrupo1:refresh()
      Return .f.
   EndIf
EndIf

Return .t.
