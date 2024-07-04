#INCLUDE "Ofifa710.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIFA710 ³ Autor ³  Fabio                ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Planos de Revisao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIFA710

PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006) //"Planos de Revisao"
Private nUsado    := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VF0")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OF710     ºAutor  ³Fabio               º Data ³  09/02/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Tela                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OF710(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local bCampo  := { |nCPO| Field(nCPO) }
Local _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 
Private aTELA[0][0],aGETS[0] 
Private nOpcX := nOpc
Private aCpoEnchoice  :={} , aCols := {} , aHeader := {}
Private nLenAcols := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VF0",.t.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VF0")
While !Eof().and.(x3_arquivo=="VF0")
   If X3USO(x3_usado).and.cNivel>=x3_nivel
      AADD(aCpoEnchoice,x3_campo)
   Endif
   
   &("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
   DbSkip()
End

If !(Inclui)
   DbSelectArea("VF0")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
   Case nOpc == 3 && Incluir
        nOpcE:=3
        nOpcG:=3
   Case nOpc == 4 && Alterar
        nOpcE:=4
        nOpcG:=4
   Case nOpc == 2 && Visualizar
        nOpcE:=2
        nOpcG:=2
   Otherwise        && Excluir
        nOpcE:=5
        nOpcG:=5
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VF1")
aHeader:={}
While !Eof().And.(x3_arquivo=="VF1")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VF1_CODMAR/VF1_DESMAR/VF1_CODPLA/VF1_DESPLA])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      
      &("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
   Endif
   dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VF1")
ADHeadRec("VF1",aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VF1")
dbSetOrder(1)
dbSeek(xFilial("VF1")+M->VF0_CODMAR+M->VF0_CODPLA)

If nOpc == 3 .Or. !(Found())
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
   
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VF1"
		Else
         aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
      EndIf                           
      
   Next
Else
   aCols:={}
   While !Eof() .And. VF1->VF1_FILIAL == xFilial("VF1") .And. VF1->VF1_CODMAR+VF1->VF1_CODPLA == VF0->VF0_CODMAR+VF0->VF0_CODPLA
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado

			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VF1->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VF1"
			Else
            aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
         EndIf
            
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End
   nLenaCols     := Len(aCols)
Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0006
   cAliasEnchoice:="VF0"
   cAliasGetD    :="VF1"
   cLinOk        :="FG_OBRIGAT()"
   cLinOk        :="If( FS_VLPLANO() , FG_OBRIGAT() , .f. )"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR() .and. OF170FILDOK()"
   
   // Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 83 , .T., .F. } )  //Cabecalho
	AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
	//tamanho para resolucao 1024*768
	//aSizeAut[3]:= 508 
	//aSizeAut[5]:= 1016  
	// Fator de reducao de 0.8
	//for nCntFor := 1 to Len(aSizeAut)
	//	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
	//next   
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)    
	
   DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

       EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
       oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
       oGetDados:oBrowse:bChange    := {|| FG_AALTER("VF1",nLenaCols,oGetDados) }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If( oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_FA710GRA(nOpc) , oDlg:End() , .f. ) },{|| oDlg:End() })

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIFA710  ºAutor  ³Microsiga           º Data ³  09/02/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FA710GRA(nOpc)
              
Private lMsHelpAuto := .t.
Private lMsFinalAuto := .f.                      

&& Valida a delecao                  
If !FS_VALGRA710( nOpc , .t. )
     
   MostraErro()
	lMsHelpAuto := .f.
	Return( .f. )
	                    
EndIf
        
&& Movimentacao                                   
Begin Transaction
	               
FS_VALGRA710( nOpc )
	
End Transaction	

lMsHelpAuto := .f.

Return( .t. )

Static Function FS_VALGRA710( nOpc , lValid )

Local lRet := .t. , i := 0
lValid := If( lValid == NIL , .f. , lValid )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2

   DbSelectArea("VF0")  
   DbSetOrder(1)
   DbSeek(xFilial("VF0")+M->VF0_CODMAR+M->VF0_CODPLA)
                                            
   && Grava arquivo pai
	If !lValid	

	   If ( nOpc == 3 .Or. nOpc == 4 ) 
	
	      If !RecLock("VF0", !Found() )
	         Help("  ",1,"REGNLOCK")
	         lRet := .f.
	         DisarmTransaction()
	         Break               
	      EndIf
		         
	      FG_GRAVAR("VF0")
	      MsUnlock()
	      
	   EndIf
	
	   && grava arquivo filho
	   For i:=1 to len(aCols)
	
          If i > nLenaCols .and. aCols[i,Len(aCols[i])]
             Loop
          EndIf
          
	      DbSelectArea("VF1")
	      DbSetOrder(1)
	      DbSeek(xFilial("VF1")+M->VF0_CODMAR+M->VF0_CODPLA+aCols[i][FG_POSVAR("VF1_ORDCRO")]+aCols[I][FG_POSVAR("VF1_CODGRU")]+aCols[I][FG_POSVAR("VF1_CODINC")])
	 
	      If ( nOpc == 3 .Or. nOpc == 4 ) .And. !aCols[i,len(aCols[I])]
	
	         If !RecLock("VF1",  !Found() )
	            Help("  ",1,"REGNLOCK")
	            lRet := .f.
	            DisarmTransaction()
	            Break               
	         EndIf
	            
	         FG_GRAVAR("VF1",aCols,aHeader,i)
	         VF1->VF1_FILIAL := xFilial("VF1")
	         VF1->VF1_CODMAR := M->VF0_CODMAR
	         VF1->VF1_CODPLA := M->VF0_CODPLA
	         MsUnlock()
	
	      ElseIf Found()
	        
	         If !RecLock("VF1",.F.,.T.)
	            Help("  ",1,"REGNLOCK")
	            lRet := .f.
	            DisarmTransaction()
	            Break               
	         EndIf
	            
	         dbdelete()
	         MsUnlock()
	         WriteSx2("VF1")
	            
	      Endif
	      
	   Next
   
	EndIf

   && Exclui arquivo pai
   DbSelectArea("VF0")  
                                            
   If !( nOpc == 3 .Or. nOpc == 4 ) .And. Found()
        
	    If lValid 
          
          	////////////////////////////////////////////////////////////////
          	// Verifica se o PLANO DE REVISAO esta sendo utilizado no VV1 //
          	////////////////////////////////////////////////////////////////
     		If FM_SQL("SELECT VV1.R_E_C_N_O_ RECVV1 FROM "+RetSQLName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_PLAREV='"+VF0->VF0_CODPLA+"' AND VV1.D_E_L_E_T_ = ' '") > 0
				SX2->(DbSeek("VV1"))
				Help("  ",1,"CANCELDEL",,"VV1"+"- "+OemToAnsi(X2Nome() ),4,1)
		        lRet := .f.
    	    	DisarmTransaction()
        		Break
	     	EndIf

          	////////////////////////////////////////////////////////////////
          	// Verifica se o PLANO DE REVISAO esta sendo utilizado no VV2 //
          	////////////////////////////////////////////////////////////////
     		If FM_SQL("SELECT VV2.R_E_C_N_O_ RECVV2 FROM "+RetSQLName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_PLAREV='"+VF0->VF0_CODPLA+"' AND VV2.D_E_L_E_T_ = ' '") > 0
				SX2->(DbSeek("VV2"))
				Help("  ",1,"CANCELDEL",,"VV2"+"- "+OemToAnsi(X2Nome() ),4,1)
		        lRet := .f.
    	    	DisarmTransaction()
        		Break
	     	EndIf
		
		Else
	
	      If !RecLock("VF0",.F.,.T.)
	         Help("  ",1,"REGNLOCK")
	         lRet := .f.
	         DisarmTransaction()
	         Break               
	      EndIf
	         
	      dbdelete()
	      MsUnlock()
	      WriteSx2("VF0")
          
		EndIf

   Endif
   
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OF170FILOKºAutor  ³Ricardo Farinelli   º Data ³  21/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o campo digitado na getdados.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OF170FILDOK()

Local nPos := 0
Local nPos2:= 0
Local cStr1:= ""
Local cStr2:= ""
Local nwnk := 0

If nOpcX == 2 .or. nOpcX == 5 
	Return .t.
Endif  

If !aCols[n,Len(aCols[n])] .and. ReadVar() == "M->VF1_CODINC"
	nPos := FG_POSVAR("VF1_CODGRU")
	nPos2:= FG_POSVAR("VF1_CODINC")
	If nPos >0 .and. nPos2>0
		cStr1 := aCols[n,nPos]+M->VF1_CODINC
		For nwnk := 1 to Len(aCols)
			If !aCols[nwnk,Len(aCols[nwnk])] .and. nwnk <> n
				cStr2 := aCols[nwnk,nPos]+aCols[nwnk,nPos2]
				If cStr1==cStr2
					Help(" ",1,"EXISTCHAV")
					Return (.f.)
				Endif	  
			Endif
		Next
	Endif
Endif	
		  
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLPLANOºAutor  ³Fabio               º Data ³  04/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a Opcional ja foi cadastrado                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLPLANO()

Local nReg    := 0   
Local ix1     := 0   
              
FG_MEMVAR()
               
For ix1 := 1 to len(aCols)

   If aCols[ix1,nUsado+1]
      loop
   EndIf                                                         
   If aCols[ix1,FG_POSVAR("VF1_ORDCRO")]+aCols[ix1,FG_POSVAR("VF1_CODGRU")]+aCols[ix1,FG_POSVAR("VF1_CODINC")] == M->VF1_ORDCRO+M->VF1_CODGRU+M->VF1_CODINC
      nReg ++
      If nReg > 1
         Help("  ",1,"EXISTCHAV")
         Return( .f. )
      EndIf
   Else 
      Loop
   EndIf
   
Next              

Return( .t. )    

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //"Pesquisar"
                     { STR0002 ,"OF710" , 0 , 2},; //"Visualizar"
                     { STR0003 ,"OF710" , 0 , 3},; //"Incluir"
                     { STR0004 ,"OF710" , 0 , 4},; //"Alterar"
                     { STR0005 ,"OF710" , 0 , 5}} //"Excluir"
Return aRotina
