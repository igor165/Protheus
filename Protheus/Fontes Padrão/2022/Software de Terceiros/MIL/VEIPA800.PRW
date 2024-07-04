#INCLUDE "veipa800.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPA800 ³ Autor ³  Andre                ³ Data ³ 30/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Bens                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEIPA800

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0006) //"Bens"
Private nUsado := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VP6")

Return


********************************
Function FBENS(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor,_ni  := 0
Private aTELA:=Array(0,0) , aGets:=Array(0) , aCpoEnchoice  :={}
Private nLenAcols := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Inclui
   nOpcE := 3
   nOpcG := 3
Elseif Altera
   nOpcE := 4
   nOpcG := 4
Else
   nOpcE := 5
   nOpcG := 5
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VP6",.f.)
DbSelectArea("VP6")
For nCntFor := 1 TO FCount()
   if INCLUI
      if ValType(FieldGet(nCntFor)) == "C" .or. ValType(FieldGet(nCntFor)) == "M"
         M->&(EVAL(bCampo,nCntFor)) := space(len(FieldGet(nCntFor)))
      Elseif ValType(FieldGet(nCntFor)) == "N"
         M->&(EVAL(bCampo,nCntFor)) := 0
      Elseif ValType(FieldGet(nCntFor)) == "L"
         M->&(EVAL(bCampo,nCntFor)) := " "
      Elseif ValType(FieldGet(nCntFor)) == "D"
         M->&(EVAL(bCampo,nCntFor)) := ctod("")
      Endif
   Else
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VP7")
aHeader:={}
While !Eof().And.(x3_arquivo=="VP7")
   if X3USO(x3_usado).and.cNivel>=x3_nivel.and.!(x3_campo$[VP7_CODBEM])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif
   &("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
   dbSkip()
End

If nOpc == 3
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next
Else
   aCols:={}
   dbSelectArea("VP7")
   dbSetOrder(1)
   dbSeek(xFilial("VP7")+M->VP6_CODBEM)
   While !eof() .and. M->VP6_CODBEM == VP7_CODBEM
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
           aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
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
   cTitulo       := STR0006 //"Bens"
   cAliasEnchoice:="VP6"
   cAliasGetD    :="VP7"
//   cLinOk        :="FS_ATUALVP6(M->VP6_CODBEM)"
   cLinOk        :="If( FS_VLBEM() , FG_OBRIGAT() , .f. )"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"
   aCpoEnchoice  := {}
   wVP7Datatu    := CTOD("")
   wVP7Valbem    := 0

   dbSelectArea("SX3")
   dbSeek("VP6")
   aCpoEnchoice := {}
   While !Eof().and.(x3_arquivo=="VP6")
      if X3USO(x3_usado).and.cNivel>=x3_nivel
         AADD(aCpoEnchoice,x3_campo)
      Endif
      dbSkip()
   End

//   _lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd

      EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
      oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
      oGetDados:oBrowse:bChange    := {|| FG_AALTER("VP7",nLenaCols,oGetDados) }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_PA800GRA(nOpc),oDlg:End(),.f.) },{|| oDlg:End() })

EndIf

Return

//   if _lRet .and. nOpc # 2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOA120  ºAutor  ³Microsiga           º Data ³  08/25/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_PA800GRA(nOpc)
              
If !FS_VALGRAPA800( nOpc , .T. )
   Return( .f. )
EndIf

Begin Transaction
   FS_VALGRAPA800(nOpc)
End Transaction

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOA120  ºAutor  ³Microsiga           º Data ³  08/25/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALGRAPA800(nOpc, lValid)

Local aVetValid := {}
Local i := 0

lValid  := If(lValid == Nil,.f.,lValid)

Private lMsHelpAuto := .f.

If nOpc != 2

   DbSelectArea("VP6")

   If !lValid
   
      if Inclui .or. Altera
         dbSetOrder(1)
         RecLock("VP6",if(inclui,.t.,.f.))
         FG_GRAVAR("VP6")
         VP6->VP6_FILIAL := xFilial("VP6")
         VP6->VP6_CODBEM := M->VP6_CODBEM
         VP6->VP6_DESBEM := M->VP6_DESBEM
         nNro := 0
         For i=len(aCols) to 1 Step -1
             if aCols[i,len(aCols[i])] = .f.
                VP6->VP6_ULTATU := aCols[i,FG_POSVAR("VP7_DATATU")]
                VP6->VP6_VALBEM := aCols[i,FG_POSVAR("VP7_VALBEM")]
                Exit
             Endif
         Next
         MsUnlock()

         dbSelectArea("VP7")
         dbSetOrder(1)
         DbGotop()
         For i=1 to Len(aCols)
      	
             If i > nLenaCols .and. aCols[i,Len(aCols[i])]
                Loop
             EndIf

             if aCols[i,3] = .t.
                if dbSeek(xFilial("VP7")+M->VP6_CODBEM+dtos(aCols[i,FG_POSVAR("VP7_DATATU")]))
                   RecLock("VP7",.f.,.t.)
                   DbDelete()
                   MsUnlock()
                   WriteSx2("VP7")
                Endif
             Else
                RecLock("VP7",if(dbSeek(xFilial("VP7")+M->VP6_CODBEM+dtos(aCols[i,FG_POSVAR("VP7_DATATU")])),.f.,.t.))
                VP7->VP7_FILIAL := xFilial("VP7")
                VP7->VP7_CODBEM := M->VP6_CODBEM
                VP7->VP7_DATATU := aCols[i,FG_POSVAR("VP7_DATATU")]
                VP7->VP7_VALBEM := aCols[i,FG_POSVAR("VP7_VALBEM")]
                FG_GRAVAR("VP7",aCols,aHeader,i)
                MsUnlock()
           
             Endif
         Next
      Else
         DbSeek(xFilial("VP6")+M->VP6_CODBEM)
         RecLock("VP6",.f.,.t.)
         DbDelete()
         MsUnlock()
         WriteSx2("VP6")
         While .t.
            DbSelectArea("VP7")
            if DbSeek(xFilial("VP7")+M->VP6_CODBEM)
               RecLock("VP7",.f.,.t.)
               DbDelete()
               MsUnlock()
               WriteSx2("VP7")
            Else
               Exit
            Endif
         EndDo

      Endif
   Else
		If nOpc == 5
	      aVetValid := {}

	      aAdd(aVetValid, {"VP1" ,"VP1_CODBEM", VP6->VP6_CODBEM  , NIL } )
	
	      If !FG_DELETA( aVetValid )
	         Return( .f. )
	      EndIf
	      x:=0
		Endif
   Endif

EndIf

Return(.t.)

**************************
Function FS_ATUALVP6(Arg1)

   if aCols[Len(aCols),FG_POSVAR("VP7_VALBEM")] == 0
      Return .f.
   Endif

Return .t.

***************************

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DTMENORºAutor  ³Andre Luis          º Data ³  20/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o Bem ja foi cadastrado e a data do cadastro e'º±±
±±º          ³ maior que a anterior.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DTMENOR()

Local ix1     := 0   

FG_MEMVAR()
               
For ix1 := 1 to len(aCols)

   If aCols[ix1,nUsado+1]
      loop
   EndIf
   
   dbSelectArea("VP6")
   dbSetOrder(1)
   If dbSeek(xFilial("VP6")+M->VP6_CODBEM)
	   If M->VP7_DATATU <= VP6->VP6_ULTATU
	      Help("  ",1,"EXISTEDTM")
	      Return( .f. )
	   EndIf
   EndIf
/*    
   If aCols[ix1,FG_POSVAR("VP7_DATATU")] == M->VP7_DATATU
  	  ix2 ++
      If ix2 > 0
         Help("  ",1,"EXISTCHAV")
   	     Return( .f. )
      EndIf
   Else 
      Loop
   EndIf
*/   
Next              

Return( .t. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLBEM  ºAutor  ³Fabio               º Data ³  04/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o Bem ja foi cadastrado                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLBEM()

Local nReg    := 0   
Local ix1     := 0   
              
FG_MEMVAR()
               
For ix1 := 1 to len(aCols)

   If aCols[ix1,nUsado+1]
      loop
   EndIf                                                         
   If aCols[ix1,FG_POSVAR("VP7_DATATU")] == M->VP7_DATATU
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
Local aRotina := { { STR0001,"axPesqui()", 0 , 1},; //Pesquisar
                    { STR0002,"FBens", 0 , 2},;    	//Visualizar
                    { STR0003,"FBens", 0 , 3},;    	//Incluir
                    { STR0004,"FBens", 0 , 4},; 	//Alterar
                    { STR0005,"FBens", 0 , 5} } 	//Excluir
Return aRotina
