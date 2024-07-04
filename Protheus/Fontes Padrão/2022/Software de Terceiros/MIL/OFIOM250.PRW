/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM250 ³ Autor ³  Fabio                ³ Data ³ 27/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tipo de Servico para agrupar secoes de oficina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "OFIOM250.ch"
FUNCTION OFIOM250(cCodMar,cPedFab,cGruIte,cCodIte,nOpc)
                                                                      
Local aColsSalva:={} , aHeaderSalva:={} , nSalva:=0 , aSx1Alter:={}
PRIVATE aRotina := MenuDef()
Private cIndex, cChave, cCond , nIndex
PRIVATE cCadastro := OemToAnsi(STR0001)

If Type("aCols") # "U"                 
	aColsSalva:=aClone(aCols)
EndIf	
If Type("aHeader") # "U"                 
	aHeaderSalva:=aClone(aHeader)
EndIf	
If Type("n") # "U"                 
	nSalva:=n
EndIf	
                                                    
cPedFab := If(cPedFab#NIL,cPedFab,"")
cGruIte := If(cGruIte#NIL,cGruIte,"")
cCodIte := If(cCodIte#NIL,cCodIte,"")
nOpc    := If(nOpc   #NIL,nOpc   ,2 )

&& Parametro automaticos                 
If cCodMar#NIL                                                         

	Aadd( aSx1Alter , {"01",cCodMar,"","","","","","","","","","","","","",""} )
	Aadd( aSx1Alter , {"02","Nao"  ,"","","","","","","","","","","","","",""} )
	Aadd( aSx1Alter , {"03",cPedFab,"","","","","","","","","","","","","",""} )
	Aadd( aSx1Alter , {"04",cGruIte,"","","","","","","","","","","","","",""} )
	Aadd( aSx1Alter , {"05",cCodIte,"","","","","","","","","","","","","",""} )

	FG_AltSx1("OFI25X","A", aSx1Alter )

EndIf                

If !Pergunte("OFI25X",.t.) 
   Return
EndIf              

DbSelectArea("VEO")
DbSetOrder(1)

If MV_PAR02 == 2

	DbSelectArea("VEO")
	DbSetOrder(2)

	DbSelectArea("VEI")
	DbSetOrder(1)
	
	cIndex  := CriaTrab(nil,.f.)
	cChave  := IndexKey()
	cCond   := 'VEI->VEI_CODMAR == MV_PAR01 .And. VEO->( DbSeek( xFilial("VEO")+VEI->VEI_CODMAR+VEI->VEI_PEDFAB + If(!Empty(MV_PAR04),MV_PAR04,"") + If(!Empty(MV_PAR05),MV_PAR05,"") ) )'

	If !Empty(MV_PAR03)
   	cCond += ".And. VEI->VEI_PEDFAB == MV_PAR03"
	EndIf	
	
	IndRegua("VEI",cIndex,cChave,,cCond,STR0006)
	     
	DbSelectArea("VEI")
	nInd := RetIndex("VEI")+1
	#IFNDEF TOP
	   dbSetIndex(cIndex+ordBagExt())
	#ENDIF
	dbSetOrder(nInd)

	If cCodMar#NIL	
		OM250("VEI", Recno() , nOpc)
	Else
		mBrowse( 6, 1,22,75,"VEI")
	EndIf
		
	DbSelectArea("VEI")
	RetIndex()
	DbsetOrder(1)
	#IFNDEF TOP
	   If File(cIndex+OrdBagExt())
	      fErase(cIndex+OrdBagExt())
	   Endif
	#ENDIF

Else

	DbSelectArea("VEO")
	DbSetOrder(1)
	
	cIndex  := CriaTrab(nil,.f.)
	cChave  := IndexKey()
	cCond   := 'VEO->VEO_CODMAR == MV_PAR01'
	
	If !Empty(MV_PAR03)
   	cCond += ".And. VEO->VEO_NPEDFB == MV_PAR03"
	EndIf	
	
	If !Empty(MV_PAR04)
   	cCond += ".And. VEO->VEO_GRUITE == MV_PAR04"
	EndIf	
	
	If !Empty(MV_PAR05)
   	cCond += ".And. VEO->VEO_CODITE == MV_PAR05"
	EndIf
		
	IndRegua("VEO",cIndex,cChave,,cCond,STR0006)
	     
	DbSelectArea("VEO")
	nInd := RetIndex("VEO")+1
	#IFNDEF TOP
	   dbSetIndex(cIndex+ordBagExt())
	#ENDIF
	dbSetOrder(nInd)

	If cCodMar#NIL	
		OM250("VEO", Recno() , nOpc)
	Else
		mBrowse( 6, 1,22,75,"VEO")
	EndIf
	
	DbSelectArea("VEO")
	RetIndex()
	DbsetOrder(1)
	#IFNDEF TOP
	   If File(cIndex+OrdBagExt())
	      fErase(cIndex+OrdBagExt())
	   Endif
	#ENDIF

EndIf
    
&& Restaura configuracao do browse
If Type("aCols") # "U"                 
	aCols:=aClone(aColsSalva)
EndIf	
If Type("aHeader") # "U"                 
	aHeader:=aClone(aHeaderSalva)
EndIf	
If Type("n") # "U"                 
	n:=nSalva
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM250     ºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Tela                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM250(cAlias, nReg, nOpc)

Local bCampo   := { |nCPO| Field(nCPO) } , _ni := 0 , nCntFor := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nUsado := 0
//Local cGruIte := VEO->VEO_GRUITE  Emilton
//Local cCodIte := VEO->VEO_CODITE  Emilton
Local cGruIte := MV_PAR04
Local cCodIte := MV_PAR05

Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  :={}

aRotina := { { STR0002 ,"", 0 , 1}  ,;    && Pesquisar
              { STR0003 ,"", 0 , 2} ,;    && Visualizar
              { STR0005 ,"", 0 , 3} ,;    && Alterar
              { STR0005 ,"", 0 , 4} ,;    && Alterar
              { STR0006 ,"", 0 , 5} }     && Excluir

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VEI",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VEI")
While !Eof().and.(x3_arquivo=="VEI")
   If X3USO(x3_usado).and.x3_nivel>0
      AADD(aCpoEnchoice,x3_campo)
   Endif
   &("M->"+x3_campo) := CriaVar(x3_campo)
   dbSkip()
End
If !(Inclui)
   DbSelectArea("VEI")
   For nCntFor := 1 TO FCount()
       M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
   Case nOpc == 3 && Alterar
        nOpc :=4
        nOpcE:=2
        nOpcG:=5
   Case nOpc == 2 && Visualizar
        nOpc :=2
        nOpcE:=2
        nOpcG:=2
   Otherwise      && Excluir
        nOpc :=5
        nOpcE:=5
        nOpcG:=5
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VEO")
aHeader:={}
While !Eof().And.(x3_arquivo=="VEO")

   If X3USO(x3_usado).And.cNivel>=x3_nivel .And. ( MV_PAR02==1 .Or. !( Alltrim(x3_campo) $ "VEO_CODMAR/VEO_NPEDFB") )
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif

   &("M->"+x3_campo) := CriaVar(x3_campo)
   
   dbSkip()
End

aCols:={}
DbSelectArea("VEO")

If MV_PAR02 == 2

	DbSetOrder(2)
	DbSeek( xFilial() + VEI->VEI_CODMAR + VEI->VEI_PEDFAB )

	While !eof() .And. VEO->VEO_FILIAL == xFilial("VEO") .and. VEO->VEO_CODMAR+VEO->VEO_NPEDFB == VEI->VEI_CODMAR+VEI->VEI_PEDFAB
	    AADD(aCols,Array(nUsado+1))
	    For _ni:=1 to nUsado
	        aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	    Next
	    aCols[Len(aCols),nUsado+1]:=.F.
	    dbSkip()
	End

Else

//	DbSetOrder(nInd)  Emilton
//	DbSeek( xFilial() + MV_PAR01 + cGruIte + cCodIte ) Emilton
	DbSetOrder(1)
	DbSeek( xFilial())

//	While !eof() .And. VEO->VEO_FILIAL == xFilial("VEO") .and. VEO->VEO_CODMAR+VEO->VEO_GRUITE+VEO->VEO_CODITE == MV_PAR01 + cGruIte + cCodIte  Emilton
	While !eof() .And. VEO->VEO_FILIAL == xFilial("VEO") 
	
	   If !Empty(MV_PAR01)
	      If MV_PAR01 != VEO->VEO_CODMAR
	         dbSkip()
	         Loop
	      EndIf
       EndIf	      
	   If !Empty(MV_PAR03)
	      If MV_PAR03 != VEO->VEO_NPEDFB
	         dbSkip()
	         Loop
	      EndIf
       EndIf	      
	   If !Empty(MV_PAR04)
	      If MV_PAR04 != VEO->VEO_GRUITE
	         dbSkip()
	         Loop
	      EndIf
       EndIf	      
	   If !Empty(MV_PAR05)
	      If MV_PAR05 != VEO->VEO_CODITE
	         dbSkip()
	         Loop
	      EndIf
       EndIf	      
	      
	    AADD(aCols,Array(nUsado+1))
	    For _ni:=1 to nUsado
	        aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	    Next
	    aCols[Len(aCols),nUsado+1]:=.F.
	    dbSkip()
	End

EndIf


If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0001
   cAliasEnchoice:="VEI"
   cAliasGetD    :="VEO"
   cLinOk        :="AllwaysTrue()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"

   DEFINE MSDIALOG oDlg1 TITLE cTitulo From 9,0 to 28,80	of oMainWnd
   
   If MV_PAR02==2
	   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
	EndIf   
   
   oGetDados := MsGetDados():New(If(MV_PAR02==2,75,16),1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpc > 2 .and. nOpc < 5,.t.,.f.),,,,,cFieldOk)
   
   ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| if(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_OM250GRA(nOpc),oDlg1:End(),.f.) },{|| oDlg1:End() })

Else
   Help("  ",1,"NOANSWER")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OM250GRºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Tipo de servico secao oficina                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OM250GRA(nOpc)

If !FS_VALGRAOM250( nOpc , .t. )

   MostraErro()
	Return( .f. )

EndIf
                    
Begin Transaction

FS_VALGRAOM250(nOpc)

End Transaction

Return( .t. )

Static Function FS_VALGRAOM250( nOpc , lValid )
          
Local lRet := .t. , i := 0 
                                              
lValid := If( lValid == NIL , .f. , lValid )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2

   && Grava arquivo pai           
	If !lValid
	
	   && grava arquivo filho
      For i:=1 to len(aCols)

         DbSelectArea("VEO")
         
         If MV_PAR02 == 2
	         DbSetOrder(2)
				DbSeek(xFilial("VEO")+VEI->VEI_CODMAR+VEI->VEI_PEDFAB+aCols[I,FG_POSVAR("VEO_GRUITE")]+aCols[I,FG_POSVAR("VEO_CODITE")])
			Else
	         DbSetOrder(1)
				DbSeek(xFilial("VEO")+aCols[I,FG_POSVAR("VEO_CODMAR")]+aCols[I,FG_POSVAR("VEO_GRUITE")]+aCols[I,FG_POSVAR("VEO_CODITE")]+aCols[I,FG_POSVAR("VEO_NPEDFB")]) 
			EndIf
			
			If ( nOpc==5 .Or. aCols[i,Len(aCols[i])] ) .And. Found() 
 
            && Deleta 
            If !RecLock("VEO",.F.,.T.)
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            dbdelete()
            MsUnlock()
            WriteSx2("VEO")
         
         Endif

      Next                  

   EndIf   

Endif
            
Return(lRet)

Static Function MenuDef()
Local aRotina := { { STR0002 ,"axPesqui", 0 , 1},;    && Pesquisar
                  { STR0003 ,"OM250", 0 , 2} ,;    && Visualizar
                  { STR0005 ,"OM250", 0 , 4} ,;    && Alterar
                  { STR0006 ,"OM250", 0 , 5} }     && Excluir
Return aRotina
