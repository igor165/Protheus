#include "tbiconn.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ OFIIA310 ≥ Autor ≥ Manoel Filho          ≥ Data ≥ 08/08/03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Gera arquivo com o Estoque dos Itens Originais SC para en- ≥±±
±±≥          ≥ vio diario do Saldo de Estoque (Arquivo VIO)               ≥±±
±±≥          ≥ 15/07/08 - Nao enviar grupo SCL (problema de balde X litro)≥±±
±±≥          ≥ 03/09/10 - Nao enviar saldo do almoxarifado Manut Externa  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFIIA310(cFil,cMarca)

Local lPE        := ExistBlock("OFA310SD")
Local lOFA310SA  := ExistBlock("OFA310SA")
Local cFilSB1    := xFilial("SB1")
Local cFilSBL    := xFilial("SBL")
Local cFilSBM    := xFilial("SBM")
Local cFilSC7    := xFilial("SC7")
Local cFilVIA    := xFilial("VIA")
Local cFilVI0    := xFilial("VI0")
Local cFilSF1    := xFilial("SF1")
Local cSQLSC7    := "SQLSC7"
Local i          := 0
Local cGrpSdo    := ""

Private cSQLSB2  := "SQLSB2" // utilizado dentro do Ponto de Entrada OFA310SD  quando o parametro for SB2
Private cSQLVI0  := "SQLVI0" // utilizado dentro do Ponto de Entrada OFA310SD  quando o parametro for VI0

If Type("cFil") == "U"        
   cPerg := "OFIA23"
	ValidPerg()
	PERGUNTE(cPerg,.T.)
	cFil   := strzero(Val(Mv_Par01),2)
	cMarca := Mv_Par02
Endif                                

If !Empty(cFilSB1)
   cFilSB1 := cFil
Endif
If !Empty(cFilSBL)
   cFilSBL := cFil
Endif
If !Empty(cFilSBM)
   cFilSBM := cFil
Endif
If !Empty(cFilSC7)
   cFilSC7 := cFil
Endif
If !Empty(cFilVIA)
   cFilVIA := cFil
Endif
If !Empty(cFilVI0)
   cFilVI0 := cFil
Endif
If !Empty(cFilSF1)
   cFilSF1 := cFil
Endif

DbSelectArea("VIO")
//dbgotop()
DbSeek( xFilial("VIO") )

while !eof() .And. VIO->VIO_FILIAL == xFilial("VIO")
   Reclock("VIO",.f.,.t.)
   dbdelete()
   MsUnlock()
   dbskip()
Enddo

DbSelectArea("VIO")
VIO->(DbCloseArea())
if ChkFile("VIO",.T.)
   DbSelectArea("VIO")
   pack
   VIO->(DbCloseArea())
Endif

ChkFile("VIO",.F.)

DbSelectArea("SB2")

aVetor := {}

cPecaAnt := ""
lPula		:= .f.  //Renato 29/09/10

cGrpSdo    := "'"+StrTran( Alltrim(GetMv('MV_GRPSDO')), "/", "','" )
If right( cGrpSdo, 3 ) == "','"

	cGrpSdo  := Left( cGrpSdo, ( Len( cGrpSdo ) - 3 ) ) 
                               
EndIf
cGrpSdo  +=  "'"

cQuery := "SELECT SB1.* , SB2.* , SBM.*   "
cQuery += "FROM "+RetSQLName("SB2")+" SB2 "
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL = '"+cFilSB1+"' AND SB1.B1_COD   = SB2.B2_COD AND SB1.B1_GRUPO  NOT IN ( "+cGrpSdo+" ) AND SB1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SBM")+" SBM ON  SBM.BM_FILIAL = '"+cFilSBM+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_=' ' "
cQuery += "WHERE SB2.B2_FILIAL = '"+cFil+"' AND SB2.B2_LOCAL >= '01' AND SB2.B2_LOCAL <= '50' AND "
cQuery += "SB2.B2_LOCAL <> '"+GetMv("MV_RESITE")+"' AND SB2.B2_LOCAL <> '"+GetMv("MV_BLQITE")+"' AND "
cQuery += "SB2.D_E_L_E_T_=' ' "

If Select(cSQLSB2) > 0
	(cSQLSB2)->(DbCloseArea())
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSB2 , .F. , .T. )

(cSQLSB2)->(DbGoTop())
While (cSQLSB2)->(!Eof())

	   If lPE
			If !ExecBlock("OFA310SD",.f.,.f.,{"SB2"})
			   (cSQLSB2)->(DbSkip())
			   Loop
			Endif
	   Endif  

  		nQtdSC7 := 0

		// Lendo Pedidos Pendentes
		cQuery := "SELECT SUM(SC7.C7_QUANT-SC7.C7_QUJE) AS QTDSC7 "
		cQuery += "FROM "+RetSQLName("SC7")+" SC7 "
		cQuery += "WHERE SC7.C7_FILIAL = '"+cFil+"' AND SC7.C7_PRODUTO = '"+(cSQLSB2)->B1_COD+"' AND SC7.C7_RESIDUO <> 'S' AND SC7.C7_QUANT <> SC7.C7_QUJE AND "
		cQuery += "SC7.D_E_L_E_T_=' ' "

		If Select(cSQLSC7) > 0
			(cSQLSC7)->(DbCloseArea())
		EndIf
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSC7 , .F. , .T. )
		
     (cSQLSC7)->(DbGoTop())
		While (cSQLSC7)->(!Eof())
		
	         nQtdSC7 += (cSQLSC7)->QTDSC7
		      
		      DbSkip()
		      
		Enddo     
		
		if (cSQLSB2)->B2_COD == cPecaAnt
			nQtdSC7 := 0
		endif

		cPecaAnt := (cSQLSB2)->B2_COD

		//Inicio Renato 28/09/2010 - solicitado Mauricio - customizacao     
		If (cSQLSB2)->B2_QNPT <> 0
			cAno    	:= StrZero(Year(dDataBase),4)
			cMes 		:= StrZero(Month(dDataBase)-1,2) 

  			If cMes == "00"
				cMes := "12"
				cAno := STRZERO(Year(dDataBase)-1,4)
			EndIf      	         		
   	  	
	     	nqtMes   := 0  
     	
     		DbSelectArea("SBL")
			If !dbSeek(cFilSBL+(cSQLSB2)->B1_COD+cAno+cMes,.t.)
				DbSkip(-1)
      	endif
      	
     		While !eof() .and. SBL->BL_FILIAL == cFilSBL .and. SBL->BL_PRODUTO == (cSQLSB2)->B1_COD
     			
  				
      		If cMes == SBL->BL_MES      			
      			cMes := Strzero(Val(cMes)-1,2)
      			nqtMes ++      		      			
      			
		  			If cMes == "00"
						cMes := "12"
						cAno := STRZERO(Year(dDataBase)-1,4)
					EndIf      	         		
		

      			If nqtMes == 12      			
	      			Exit	      			
	      		Endif	      			      			
	      	Else
	      			
	      		Exit
	      				
	   		EndiF	   		      	      		     			
	   		
	  			DbSelectArea("SBL")
	   		DbSkip(-1)
	   	      	
			EndDo

			cABCVend := ""
			
		   If nqtMes >= 1 .and. nqtMes <= 4
		   	cABCVend := "C"
		  	ElseIf nqtMes >= 5 .and. nqtMes <= 8
		  		cABCVend := "B"
			ElseIf nqtMes >= 9 .and. nqtMes <= 12
				cABCVend := "A"
			Else  //If nqtMes <> 0
				cABCVend := "D"
			Endif	   	 
	
	   	If cABCVend $ "A/B"
				If ((cSQLSB2)->B2_QATU + nQtdSC7) > 0 
   				nPos := aScan(aVetor,{|x| x[1] == Subs((cSQLSB2)->B1_CODITE,1,7)})
   				If nPos > 0
  	   				aVetor[nPos,2] := aVetor[nPos,2]+ ((cSQLSB2)->B2_QATU + nQtdSC7)
  					Else
  	   				aadd(aVetor,{Subs((cSQLSB2)->B1_CODITE,1,7),((cSQLSB2)->B2_QATU + nQtdSC7)})
  					Endif
  				Endif	     	
  			Else	
				If ((cSQLSB2)->B2_QATU + (cSQLSB2)->B2_QNPT + nQtdSC7) > 0 // Solicitado pelo Mauricio em 16/05/07   	
	   			nPos := aScan(aVetor,{|x| x[1] == Subs((cSQLSB2)->B1_CODITE,1,7)})
	   			If nPos > 0
   	   			aVetor[nPos,2] := aVetor[nPos,2]+ ((cSQLSB2)->B2_QATU + (cSQLSB2)->B2_QNPT + nQtdSC7)
       			Else
	      		 	aadd(aVetor,{Subs((cSQLSB2)->B1_CODITE,1,7),((cSQLSB2)->B2_QATU + (cSQLSB2)->B2_QNPT + nQtdSC7)})
	  	 			Endif              
      		   	
     			Endif
      		
  			EndIf

	   Else	      
     		
     		If ((cSQLSB2)->B2_QATU + (cSQLSB2)->B2_QNPT + nQtdSC7) > 0 // Solicitado pelo Mauricio em 16/05/07 - regra oficial para projeto
  		  	    nPos := aScan(aVetor,{|x| x[1] == Subs((cSQLSB2)->B1_CODITE,1,7)})
  		  	    If nPos > 0
	     		    aVetor[nPos,2] := aVetor[nPos,2]+ ((cSQLSB2)->B2_QATU + (cSQLSB2)->B2_QNPT + nQtdSC7)
	   	    Else
		  	       aadd(aVetor,{Subs((cSQLSB2)->B1_CODITE,1,7),((cSQLSB2)->B2_QATU + (cSQLSB2)->B2_QNPT + nQtdSC7)})
		     	 Endif              
      	Endif
      
      EndIf
	      
      (cSQLSB2)->(DbSkip())
		
Enddo

// Lendo Transferencias
DbSelectArea("VI0")

aVetNSB1 := {}

cQuery := "SELECT VI0.* , VIA.* "
cQuery += "FROM "+RetSQLName("VI0")+" VI0 "
cQuery += "INNER JOIN "+RetSQLName("VIA")+" VIA ON  VIA.VIA_FILIAL = '"+cFilVIA+"' AND VIA.VIA_CODMAR = VI0.VI0_CODMAR AND VIA.VIA_NUMNFI = VI0.VI0_NUMNFI AND VIA.VIA_SERNFI = VI0.VI0_SERNFI AND VIA.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL  = '"+cFilSB1+"' AND SB1.B1_GRUPO   = VIA.VIA_GRUITE AND SB1.B1_CODITE  = VIA.VIA_CODITE AND SB1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SBM")+" SBM ON  SBM.BM_FILIAL  = '"+cFilSBM+"' AND SBM.BM_GRUPO   = SB1.B1_GRUPO   AND SBM.BM_PROORI  = '1' AND SBM.D_E_L_E_T_=' ' "
cQuery += "WHERE VI0.VI0_FILIAL = '"+cFilVI0+"' AND VI0.VI0_TIPREG = 'TRF' AND VI0.VI0_CODMAR = '"+cMarca+"' AND "
cQuery += "VI0.D_E_L_E_T_=' ' "

If Select(cSQLVI0) > 0
	(cSQLVI0)->(DbCloseArea())
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVI0 , .F. , .T. )

(cSQLVI0)->(DbGoTop())
While (cSQLVI0)->(!Eof())

	   If lPE
			If !ExecBlock("OFA310SD",.f.,.f.,{"VI0"})
			   (cSQLVI0)->(DbSkip())
			   Loop
			Endif
	   Endif  

      DbSelectArea("SF1")
      If !DbSeek(xFilial("SF1")+(cSQLVI0)->VI0_NUMNFI+(cSQLVI0)->VI0_SERNFI+(cSQLVI0)->VI0_CODFOR+(cSQLVI0)->VI0_LOJFOR)
       
	 		 If (cSQLVI0)->VIA_QTDFAT > 0
             nPos := aScan(aVetor,{|x| x[1] == Subs((cSQLVI0)->VIA_CODITE,1,7)})
	          If nPos > 0
	             aVetor[nPos,2] := aVetor[nPos,2] + (cSQLVI0)->VIA_QTDFAT
	          Else
	             aadd(aVetor,{Subs((cSQLVI0)->VIA_CODITE,1,7),(cSQLVI0)->VIA_QTDFAT})
	          Endif              
	       Endif
	       
		Endif    
         
      (cSQLVI0)->(DbSkip())
      
Enddo

If Select(cSQLSB2) > 0
	(cSQLSB2)->(DbCloseArea())
EndIf	
If Select(cSQLSC7) > 0
	(cSQLSC7)->(DbCloseArea())
EndIf	
If Select(cSQLVI0) > 0
	(cSQLVI0)->(DbCloseArea())
EndIf

DbSelectArea("VIO")
// Atualiza Arquivo VIO com os Saldos Atuais
for i = 1 to Len(aVetor)
	// Ponto de Entrada para VerificaÁ„o do Saldo Atual
	If lOFA310SA
		aVetor[i,2] := ExecBlock("OFA310SA", .f., .f., aVetor[i])
	EndIf

	If aVetor[i,2] > 0
		RecLock("VIO",.t.)
		VIO_FILIAL := xFilial("VIO")
		VIO_CODITE := aVetor[i,1]
		VIO_QTDADE := aVetor[i,2]
	   MsUnlock()
	Endif   
   
Next

cMsg := "Os codigos de Peca a seguir nao existem no Arquivo de Produtos (SB1): " + Chr(10)
For i = 1 to Len(aVetNSB1)                                            
    cMsg := cMsg + aVetNSB1[i] + Chr(10)
Next
If !(cMsg == "Os codigos de Peca a seguir nao existem no Arquivo de Produtos (SB1): " + Chr(10))
    if AT(",",GetMv("MV_MAQGPEC")) == 0
       	cSendMsg := "prj_client " + GetMv("MV_MAQGPEC") + " " + '"' + cMsg + '"'
    else
        cSendMsg := "prj_client " + subs(GetMv("MV_MAQGPEC"),1,at(",",GetMv("MV_MAQGPEC"))-1) + " " + '"' + cMsg + '"'
    endif 
    WinExec(cSendMsg)
Endif   

Return


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫FunáÑo    ≥VALIDPERG ∫ Autor ≥ Luis Delorme       ∫ Data ≥  01/03/04   ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function ValidPerg

local _sAlias := Alias()
local aRegs := {}
local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,6)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Filial ","","","mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Marca  ","","","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""})

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
