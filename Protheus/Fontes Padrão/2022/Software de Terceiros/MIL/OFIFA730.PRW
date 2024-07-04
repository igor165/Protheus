#INCLUDE "Ofifa730.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIFA730  ³ Autor ³  Fabio                ³ Data ³ 30/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Componente e Itens                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIFA730

PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006) //"Componentes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VF6")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AP730     ºAutor  ³Fabio               º Data ³  09/06/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AP730(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local lProcura := .t. , _lRet , i := 0 , nCntFor := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private aTELA[0][0],aGETS[0]
Private  aCpoEnchoice  :={} , aCols := {} , aHeader := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VF6",.t.)         // .t. para carregar campos virtuais

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VF6")
While !Eof().and.(x3_arquivo=="VF6")

   If X3USO(x3_usado).and.cNivel>=x3_nivel
      AADD(aCpoEnchoice,x3_campo)
   Endif
   
   &("M->"+x3_campo):= CriaVar(x3_campo)
   
   DbSkip()
   
End
If !(Inclui)
   DbSelectArea("VF6")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

If nOpc == 3
   nOpcE := 3
   nOpcG := 3
Elseif nOpc == 4
   nOpcE := 4
   nOpcG := 4
Elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
Else
   nOpcE := 5
   nOpcG := 5
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VF8")
aHeader:={}
While !Eof().And.(x3_arquivo=="VF8")
   If X3USO(x3_usado).And.cNivel>=x3_nivel .and. !(Alltrim(x3_Campo) $ [VF8_CODMAR/VF8_DESMAR/VF8_MODVEI/VF8_DESMOD/VF8_CODCOM/VF8_DESCOM/VF8_DESGRU])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )

      &("M->"+x3_campo) := CriaVar(x3_campo)

   Endif
   dbSkip()
End
           
// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VF8")
ADHeadRec("VF8",aHeader)
nUsado :=Len(aHeader)

DbSelectArea("VF8")
DbSetOrder(1)
DbSeek( xFilial() + VF6->VF6_CODMAR + VF6->VF6_MODVEI + VF6->VF6_CODCOM )

aCols:={}
If nOpc == 3 .Or. !Found()
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
   
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VF8"
		Else
         aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
      EndIf
         
   Next
Else
   While !Eof() .And. VF8->VF8_FILIAL == xFilial("VF8") .And. VF8->VF8_CODMAR+VF8->VF8_MODVEI+VF8->VF8_CODCOM == VF6->VF6_CODMAR+VF6->VF6_MODVEI+VF6->VF6_CODCOM
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado           
       
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VF8->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VF8"
			Else
            aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
         EndIf
            
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End
Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0001
   cAliasEnchoice:="VF6"
   cAliasGetD    :="VF8"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"

   DbSelectArea("SX3")
   DbSeek("VF6")

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 43,100	of oMainWnd  
   
   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{12,1,192,395},,3,,,,,,.F.)
   
   oGetDados := MsGetDados():New(193,1,255,395,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_FA730GRA(nOpc), oDlg:End() , .f. ) },{|| oDlg:End() })CENTER

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIFA730  ºAutor  ³Microsiga           º Data ³  09/06/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FA730GRA(nOpc) 

Private lMsHelpAuto := .t.
Private lMsFinalAuto := .f.
If !FS_VALGRA730(nOpc , .t. ) 

   MostraErro()
	lMsHelpAuto := .f.
   Return( .f. )

EndIf                          

Begin Transaction
               
FS_VALGRA730(nOpc) 

End Transaction
lMsHelpAuto := .f.

Return( .t. )

Static Function FS_VALGRA730(nOpc , lValid ) 
          
Local lRet := .t. , i := 0

lValid := If( lValid == NIL , .f. , lValid )
                  
If nOpc # 2

   DbSelectArea("VF6")
   DbSetOrder(1)
   DbSeek(xFilial("VF6")+M->VF6_CODMAR+M->VF6_MODVEI+M->VF6_GRUITE+M->VF6_CODCOM)

   && Grava arquivo pai             

	If !lValid
	
      If (nOpc == 3 .Or. nOpc == 4) 

         If !RecLock("VF6", !Found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         FG_GRAVAR("VF6")
         MsUnlock()

      EndIf
      
      && Excluir registro do arquivo filho
      For i:=1 to len(aCols)

          DbSelectArea("VF8")
          DbSetOrder(1)
          DbSeek(xFilial("VF8")+M->VF6_CODMAR+M->VF6_MODVEI+M->VF6_CODCOM+aCols[I,FG_POSVAR("VF8_GRUITE")]+aCols[I,FG_POSVAR("VF8_CODITE")])
          
          If (nOpc == 3 .Or. nOpc == 4) .And. !aCols[i,len(aCols[I])]

             If !RecLock("VF8", !Found() )
                Help("  ",1,"REGNLOCK")
                lRet := .f.
                DisarmTransaction()
                Break               
             EndIf

             FG_GRAVAR("VF8",aCols,aHeader,i)
             VF8->VF8_FILIAL := xFilial("VF8")
             VF8->VF8_CODMAR := M->VF6_CODMAR
             VF8->VF8_MODVEI := M->VF6_MODVEI
             VF8->VF8_CODCOM := M->VF6_CODCOM
             MsUnlock()

          ElseIf Found()
          
             If !RecLock("VF8",.F.,.T.)
                Help("  ",1,"REGNLOCK")
                lRet := .f.
                DisarmTransaction()
                Break               
             EndIf
             
             dbdelete()
             MsUnlock()
             WriteSx2("VF8")
             
          Endif

      Next           
   
	EndIf

   && Excluir registro do arquivo pai
   DbSelectArea("VF6")

   If !(nOpc == 3 .Or. nOpc == 4) .And. Found()

		If lValid
        
         aVetValid := {}
         Aadd(aVetValid,{ "VF7" , 1 , VF6->VF6_CODMAR + VF6->VF6_MODVEI + VF6->VF6_GRUITE + VF6->VF6_CODCOM , NIL })
         Aadd(aVetValid,{ "VF9" , "VF9_GRUITE + VF9_CODCOM" , VF6->VF6_GRUITE + VF6->VF6_CODCOM ,  "DbSeek( xFilial('VV1') + VF9->VF9_CHAINT ) .And. VV1->VV1_CODMAR + VV1->VV1_MODVEI == VF6->VF6_CODMAR + VF6->VF6_MODVEI" })
         Aadd(aVetValid,{ "VFC" , "VFC_CODMAR + VFC_MODVEI + VFC_GRUITE + VFC_CODCOM" , VF6->VF6_CODMAR + VF6->VF6_MODVEI + VF6->VF6_GRUITE + VF6->VF6_CODCOM , NIL })
   
         If !FG_DELETA(aVetValid)
            Return( .f. )
         EndIf
      
		Else

         If !RecLock("VF6",.F.,.T.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         dbdelete()
         MsUnlock()
         WriteSx2("VF6")
          
		EndIf

   EndIf

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_C730  ³ Autor ³  Fabio                ³ Data ³ 28/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Testa Duplicidade                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_C730()    

Local lReturn := .t. , _i := 0

If ReadVar() == [M->VF8_CODITE]
   For _i:=1 to Len(aCols)
      If aCols[_i,FG_POSVAR("VF8_GRUITE")]+aCols[_i,FG_POSVAR("VF8_CODITE")] == M->VF8_GRUITE+M->VF8_CODITE .And. _i # n
         lReturn := .F.
      Endif
   Next
Endif

Return(lReturn)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui",0 , 1},;//Pesquisar
                     { STR0002 ,"Ap730", 0 , 2},;//Visualizar
                     { STR0003 ,"Ap730", 0 , 3},;//Incluir
                     { STR0004 ,"Ap730", 0 , 4},;//Alterar
                     { STR0005 ,"Ap730", 0 , 5} }//Excluir
Return aRotina
