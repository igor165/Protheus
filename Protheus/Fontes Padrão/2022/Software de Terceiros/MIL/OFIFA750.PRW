#INCLUDE "Ofifa750.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIFA750 ³ Autor ³  Fabio                ³ Data ³ 20/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Componente do Veiculos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION OFIFA750

PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006) //"Componentes do Veiculo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VV1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AP750     ºAutor  ³Fabio               º Data ³  09/06/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AP750(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local _ni := 0 , nCntFor := 0, _lRet := .t. , lProcura := .t. , i := 0 , nUsado := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  :={} , aCols := {} , aHeader := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VV1",.t.)         // .t. para carregar campos virtuais

dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VV1")
While !Eof().and.(x3_arquivo=="VV1")
   if X3USO(x3_usado).and.cNivel>=x3_nivel.And.(Alltrim(x3_campo) $ [VV1_CHASSI/VV1_CODMAR/VV1_DESMAR/VV1_MODVEI/VV1_DESMOD/VV1_PROATU/VV1_NOMPRO])
      AADD(aCpoEnchoice,x3_campo)
   Endif
   dbSkip()
End

if !Inclui
   DbSelectArea("VV1")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operacao a ser executada Ex: Inclusao                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
   nOpcE := 2
   nOpcG := 3
Elseif nOpc == 4
   nOpcE := 2
   nOpcG := 4
Elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
Else
   nOpcE := 2
   nOpcG := 5
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")       
DbSetOrder(1)
dbSeek("VF9")
aHeader:={}
While !Eof().And.(x3_arquivo=="VF9")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VF9_CHAINT])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      if inclui
         &("M->"+x3_campo) := CriaVar(x3_campo)
      Endif   
   Endif
   dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VF9")
ADHeadRec("VF9",aHeader)
nUsado :=Len(aHeader)

DbSelectArea("VF9")
DbSetOrder(1)
DbSeek(xFilial()+M->VV1_CHAINT)

aCols:={}

If nOpc == 3 .And. !(Found())
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VF9"
		Else
         aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
      EndIf   
   Next
Else
   While !Eof() .And. VF9->VF9_FILIAL == xFilial("VF9") .And. VF9->VF9_CHAINT == M->VV1_CHAINT
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
       
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VF9->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VF9"
			Else
            aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
         EndIf
            
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       DbSkip()
   End
Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0001
   cAliasEnchoice:="VV1"
   cAliasGetD    :="VF9"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR(),FS_C750()"

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
   oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_FA750GRA(nOpc), oDlg:End() , .f. ) },{|| oDlg:End() })CENTER

Endif

Return

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIFA750  ºAutor  ³Microsiga           º Data ³  09/06/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FA750GRA(nOpc)
           
Local lRet := .t.  , i := 0
Private lMsHelpAuto := .t.
Private lMsFinalAuto := .f.

If nOpc # 2
                           
   Begin Transaction
   
      For i:=1 to len(aCols)

         DbSelectArea("VF9")
         DbSetOrder(1)
         DbSeek( xFilial("VF9") + M->VV1_CHAINT + aCols[I,FG_POSVAR("VF9_NUMIDE")] + aCols[I,FG_POSVAR("VF9_GRUITE")] + aCols[I,FG_POSVAR("VF9_CODCOM")] )

// 3rd - farinelli
         If (nOpc == 3 .Or. nOpc == 4) 
           If !aCols[i,Len(aCols[i])]

             RecLock("VF9", !Found() )
             FG_GRAVAR("VF9",aCols,aHeader,i)
             VF9->VF9_FILIAL := xFilial("VF9")
             VF9->VF9_CHAINT := M->VV1_CHAINT
             MsUnlock()
           Else
             If Found()
               RecLock("VF9", .F.)
               Dbdelete()
               WriteSx2("VF9")
               MsUnlock()
             Endif
           Endif
         ElseIf Found()

            If !RecLock("VF9", !Found() )
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            VF9->VF9_DATFIN := If( Empty(aCols[I,FG_POSVAR("VF9_DATFIN")]) , DdataBase , aCols[I,FG_POSVAR("VF9_DATFIN")] )
            MsUnlock()

         Endif

      Next
   
   End Transaction
   
Endif
   
If !lRet
   MostraErro()
EndIf
lMsHelpAuto := .f.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_C750  ³ Autor ³  Fabio                ³ Data ³ 28/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Testa Duplicidade / Valida campos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_C750()

Local nPosReg := 0

If ReadVar() $ "M->VF9_GRUITE/M->VF9_CODCOM"
   
   nPosReg := Ascan(aCols, {|x| x[FG_POSVAR("VF9_GRUITE")] + x[FG_POSVAR("VF9_CODCOM")] == M->VF9_GRUITE+M->VF9_CODCOM } )
 
   If nPosReg # 0 .And. nPosReg # n
   
      Help("  ",1,"EXISTCHAV")
      Return(.f.)
      
   Endif
   
   If ReadVar() == "M->VF9_CODCOM"
   
      VF7->(DbSetOrder(1))
      VF7->(DbSeek(xFilial("VF7")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+M->VF9_GRUITE+M->VF9_CODCOM))
      acols[n,FG_POSVAR("VF9_NUMIDE")] := VF7->VF7_NUMIDE
      
   EndIf                     
   
Endif

If ReadVar() == "M->VF9_NUMIDE"

   DbSelectArea("VF7")
   DbSetOrder(1)
   If !DbSeek( xFilial("VF7") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + M->VF9_GRUITE + M->VF9_CODCOM + M->VF9_NUMIDE )
      Return(.f.)
   EndIf
   
EndIf

Return(.t.)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //Pesquisar
                     { STR0002 ,"Ap750", 0 , 2},;  //Visualizar
                     { STR0003 ,"Ap750", 0 , 3},;  //Incluir
                     { STR0004 ,"Ap750", 0 , 4},;  //Alterar
                     { STR0005 ,"Ap750", 0 , 5} }  //Retirar
Return aRotina
