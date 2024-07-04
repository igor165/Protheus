#INCLUDE "Ofiga030.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGA030 ³ Autor ³  Renata               ³ Data ³ 08/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusao de Garantia de Peca de Estoque E Balcao no VGA/VG5³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GARANTIA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



Function OFIGA030

Local cChave, cCond

Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0005)   //"Garantia Solicitada" //"Garantia Estoque/Balcao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("VGA")
DbSetOrder(1)
                          
cIndex := CriaTrab(nil,.f.)
cChave  := IndexKey()  //"VGA_FILIAL+VGA_CODMAR+VGA_NUMOSV+VGA_ESPGAR"
cCond   := 'VGA_EXPGAR=="S".and.VGA_IMPOSV=="N".and.VGA_TRANSM=="N".and.VGA_ESPGAR=="S"'
IndRegua("VGA",cIndex,cChave,,cCond,STR0006) //"Aguarde, filtrando registros..."

DbSelectArea("VGA")
nIndex := RetIndex("VGA")
#IFNDEF TOP
   DbSetIndex(cIndex+ordBagExt())
#ENDIF
DbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VGA",,,,"VGA_EXPGAR=='S'.AND.VGA_ESPGAR=='S'.and.VGA_IMPOSV=='N'.and.VGA_TRANSM=='N'")

DbSelectArea("VGA")
RetIndex("VGA")
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GA030     ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MODELO 3                                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GA030(cAlias,nReg,nOpc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GA030(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nUsado := 0 , nCntFor := 0 , _ni := 0
Private aTELA[0][0],aGETS[0] 
Private aCpoEnchoice:={} , aCols := {} , aHeader := {} , nLenaCols:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VGA",.t.)         // .t. para carregar campos virtuais

aCpoEnchoice:={}

DbSelectArea("SX3")
DbGotop()
DbSetOrder(1)
DbSeek("VGA")

While !Eof().and.(x3_arquivo=="VGA")
   if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VGA_ESPGAR/VGA_CODREV/VGA_GRUREV/VGA_DNRESP/VGA_KILGAR/VGA_SEGMOD/VGA_AUTFAB/VGA_CHAINT/VGA_VALTPO/VGA_TEMPAD/VGA_CHAINT/VGA_CHASSI/VGA_NUMOSV/VGA_IMPOSV/VGA_TRANSM/VGA_DATRET/VGA_DATTRA/VGA_DATCRE/VGA_VALCRE/VGA_LANCRE/VGA_DATDEB/VGA_VALDEB/VGA_LANDEB/VGA_CODEST/VGA_DIFPGT/VGA_SITUAC/VGA_EXPGAR/VGA_NFIPEC/VGA_NFISER/VGA_SERNFI/VGA_NFIFEC/VGA_SERFEC/VGA_DATFEC])
      AADD(aCpoEnchoice,x3_campo)
   Endif

   &("M->"+x3_campo) := CriaVar(x3_campo)
   
   DbSkip()
End

If !(Inclui)
   DbSelectArea("VGA")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

if nOpc == 3
   nOpcE := 3
   nOpcG := 3
elseif nOpc == 4
   nOpcE := 4
   nOpcG := 4
elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
else
   nOpcE := 5
   nOpcG := 5
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VG5")

aHeader:={}

While !Eof().And.(x3_arquivo=="VG5")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VG5_NUMOSV/VG5_NUMNFI/VG5_SERIEN/VG5_CODMAR/VG5_DESMAR/VG5_DESGRU/VG5_CODSER/VG5_SERINT/VG5_DESSER/VG5_TEMPAD/VG5_TRANSM/VG5_SEREXT])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )

      &("M->"+x3_campo) := CriaVar(x3_campo)
      
   Endif
   DbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VG5")
ADHeadRec("VG5",aHeader)
nUsado :=Len(aHeader)

aCols:={}
DbSelectArea("VG5")
DbSetOrder(2)
DbSeek(xFilial("VG5")+M->VGA_CODMAR+M->VGA_NUMNFI+M->VGA_SERIEN)

If Inclui .Or. !Found()
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VG5"
		Else
         aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
      EndIf   
   Next
Else
   While !Eof() .And. VG5->VG5_FILIAL == xFilial("VG5") .And. M->VGA_CODMAR+M->VGA_NUMNFI+M->VGA_SERIEN == VG5->VG5_CODMAR+VG5->VG5_NUMNFI+VG5->VG5_SERIEN
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado

			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VG5->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VG5"
			Else
            aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
         EndIf   

       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End
   nLenaCols:=Len(aCols)
Endif

dbSelectArea("VGA")

//RetIndex("VGA")

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0005    //"Garantia de Estoque"
   cAliasEnchoice:="VGA"
   cAliasGetD    :="VG5"
   cLinOk        :="If(FS_LGA030(nOpcG),FG_OBRIGAT(),.f.)"
   cTudOk        :="If(FS_OrdVw('M->VG5_ORDITE','VGA->VGA_NUMOSV'), FS_GAOK() ,.f.)"
   cFieldOk      :="FG_MEMVAR().And.FS_INT().And.FS_EXIPEC()"

   If !(Inclui)
      DbSelectArea("VGA")
      dbgotop()
      DbSetOrder(2)
      dbSeek(xFilial("VGA")+M->VGA_CODMAR+M->VGA_NUMNFI+M->VGA_SERIEN)
   Endif

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd   
   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
   oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
   oGetDados:oBrowse:bChange := {|| FG_AALTER("VG5",nLenaCols,oGetDados) }
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_GRAGPB(nOpc),oDlg:End(),.f.) },{|| oDlg:End() })

//   Help(" ",1,"OFIGA03001") 
   
Endif

DbSelectArea("VGA")
DbSetOrder(nIndex+1)


//dbSelectArea("VGA")
//dbSetOrder(1)                               
//cIndex := CriaTrab(nil,.f.)
//cChave  := IndexKey()  //"VGA_FILIAL+VGA_CODMAR+VGA_NUMOSV+VGA_ESPGAR"
//cCond   := 'VGA_EXPGAR=="S".and.VGA_IMPOSV="N".and.VGA_TRANSM="N"'
//IndRegua("VGA",cIndex,cChave,,cCond,"Aguarde, filtrando registros...")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIGA030  ºAutor  ³Microsiga           º Data ³  08/16/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAGPB(nOpc)

Local i := 0 , lRet := .t.
Private lMsHelpAuto := .t.
Private lMsFinalAuto := .f.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc # 2

   Begin Transaction

      DbSelectArea("VGA")
      DbSetorder(2)
      DbSeek(xFilial("VGA")+M->VGA_CODMAR+M->VGA_NUMNFI+M->VGA_SERIEN)
                                                       
      && grava arquivo pai
      If ( nOpc == 3 .or. nOpc == 4 ) 

         If !RecLock("VGA", !Found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf

         FG_GRAVAR("VGA")
         VGA->VGA_ESPGAR := "S"
         VGA->VGA_IMPOSV := "N"
         VGA->VGA_NUMNFI := M->VGA_NUMNFI
         VGA->VGA_TRANSM := "N"
         VGA->VGA_EXPGAR := "S"
         MsUnlock()
                          
      EndIf   
    
      && grava arquivo filho
      For i:=1 to len(aCols)

         DbSelectArea("VG5")
         DbSetOrder(2)
         Dbseek(xFilial("VG5")+VGA->VGA_CODMAR+VGA->VGA_NUMNFI+VGA->VGA_SERIEN+aCols[I][FG_POSVAR("VG5_PECINT")])

         If ( nOpc == 3 .or. nOpc == 4 ) .And. !aCols[i,len(acols[i])]

            If !RecLock("VG5", !Found() )
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            FG_GRAVAR("VG5",aCols,aHeader,i)
            VG5->VG5_FILIAL := xFilial("VG5")
            VG5->VG5_CODMAR := VGA->VGA_CODMAR
            VG5->VG5_NUMNFI:= VGA->VGA_NUMNFI
            VG5->VG5_SERIEN := VGA->VGA_SERIEN
   	      VG5->VG5_TRANSM := "N"
            MsUnlock()

         ElseIf Found() .And. nLenaCols >= i

            If !RecLock("VG5",.F.,.T.)
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            dbdelete()
            MsUnlock()
            WriteSx2("VG5")

         EndIf

      Next                  
      
      && exclui arquivo pai
      DbSelectArea("VGA")
                                                       
      If !( nOpc == 3 .or. nOpc == 4 ) .And. Found()
    
         If !RecLock("VGA",.F.,.T.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
            
         dbdelete()
         MsUnlock()
         WriteSx2("VGA")

      EndIf

   End Transaction

Endif     

If !lRet
   MostraErro()
EndIf
lMsHelpAuto := .f.


Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ORDVW  ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³verifica a numeracao informada nas pecas                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_OrdVw(nOrdIte,nNumOsv)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OrdVw(nOrdIte,nNumOsv)
           
Local aVetor := {} , i := 0 , k := 0

for i = 1 to len(acols)
   aadd(aVetor,val(acols[i][FG_POSVAR("VG5_ORDITE")])) //VG5_ORDITE 1
next

asort(aVetor)

for k = 1 to len(aVetor)

  if k < len(aVetor)

    If aVetor[k] + 1 < aVetor[k+1]
       Help(" ",1,"OFIGA03002") 
       Return .f.
    Endif

    If aVetor[k] == aVetor[k+1]
       Help(" ",1,"OFIGA03003") 
       Return .f.
    Endif

  Endif

Next

Return .t.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_INT    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca o codigo interno da pecas                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_INT()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_Int()

If readvar() == 'M->VG5_CODITE'

   If !empty(M->VG5_CODITE)
      aCols[N][FG_POSVAR("VG5_PECINT")]:=SB1->B1_COD
   Endif

Endif

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_EXIPEC ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a existencia da peca digitada nos arquivos de notas³±±
±±³          ³fiscais de entrada e saida                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_EXIPEC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EXIPEC()

Local lExi    := .t. , cPecInt := "" , lAchouIt:= .f.

if readvar() == 'M->VG5_CODITE'

   DbSelectArea("SF2")
   DbGotop()
   
   If DbSeek(xFilial("SF2")+M->VGA_NUMNFI+M->VGA_SERIEN)==.t.          //NOTAS SAIDA

      DbSelectArea("SB1")
      DbGotop()
      DbSetOrder(7)
      If DbSeek(xFilial("SB1")+M->VG5_GRUITE+M->VG5_CODITE)==.t.
         cPecInt := SB1->B1_COD
      Endif

      DbSelectArea("SD2")
      DbGotop()
      DbSetOrder(3)
      If DbSeek(xFilial("SD2")+M->VGA_NUMNFI+M->VGA_SERIEN+SF2->F2_CLIENTE)   //NOTAS SAIDA
         Do While !SD2->(eof()) .And. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE == M->VGA_NUMNFI+M->VGA_SERIEN+SF2->F2_CLIENTE
            If cPecInt == SD2->D2_COD
               lAchouIt := .t.
               Exit
            Endif
            SD2->(DbSkip())
         Enddo
        If lAchouIt == .f.
           Help(" ",1,"OFIGA03004") 
           lExi := .f.
        Endif
      Endif
   Endif

   DbSelectArea("SF1")
   DbGotop()
   If DbSeek(xFilial("SF1")+M->VGA_NUMNFI+M->VGA_SERIEN)==.t.          //NOTAS SAIDA

      DbSelectArea("SB1")
      DbGotop()
      DbSetOrder(7)
      If DbSeek(xFilial("SB1")+M->VG5_GRUITE+M->VG5_CODITE)==.t.
         cPecInt := SB1->B1_COD
      Endif

      DbSelectArea("SD1")
      DbGotop()
      DbSetOrder(2)
      If DbSeek(xFilial("SD1")+cPecInt+M->VGA_NUMNFI+M->VGA_SERIEN)==.f.   //NOTAS SAIDA
         Help(" ",1,"OFIGA03004") 
         lExi := .f.
      Endif

   Endif

Endif

Return lExi

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GAOK   ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checa a origem da nota fiscal (entrada ou saida) com o tipo ³±±
±±³          ³da garantia                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GAOK()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GaOk()

Local lvol := .T. , lAchou := .t.

If !alltrim(M->VGA_CODGAR) $ "45"
   Help(" ",1,"OFIGA03005") 
   lVol := .F.                      
   Return lVol
Endif

If alltrim(M->VGA_CODGAR) == "5"   //BALCAO

   DbSelectArea("SF2")
   DbGotop()
   DbSetOrder(1)
   lAchou:=DbSeek(xFilial("SF2")+M->VGA_NUMNFI+M->VGA_SERIEN)          //NOTAS SAIDAS

   If lAchou == .f.
      Help(" ",1,"OFIGA03006")   
      lvol := .f.
   Endif

Else                           //ESTOQUE

   DbSelectArea("SF1")
   DbGotop()
   DbSetOrder(1)
   lAchou:=DbSeek(xFilial("SF1")+M->VGA_NUMNFI+M->VGA_SERIEN)          //NOTAS ENTRADA

  If lAchou == .f.
       Help(" ",1,"OFIGA03007")   
      lvol := .f.
   Endif

Endif

Return lvol

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LGA030 ºAutor  ³Fabio               º Data ³  10/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida registro duplicado                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function FS_LGA030(nOpc)

Local nValLin:=0

FG_MEMVAR()
        
If !aCols[n,Len(aCols[n])]   

	If nOpc==3 .And. !ExistChav("VG5",M->VGA_CODMAR+M->VGA_NUMNFI+M->VGA_SERIEN+M->VG5_PECINT,2)
	
		Return(.f.)     
	
	EndIf
	
	For nValLin:=1 to Len(aCols)
	    
		If !aCols[nValLin,Len(aCols[nValLin])] .And. aCols[nValLin,FG_POSVAR("VG5_PECINT")] == M->VG5_PECINT .and. nValLin#n
           
			Help("  ",1,"EXISTCHAV")
			Return(.f.)

		EndIf
	                           
	Next          

EndIf

Return(.t.)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui", 0, 1},;  //Pesquisar
                     { STR0002 ,"GA030", 0 , 2},;  //Visualizar
                     { STR0003 ,"GA030", 0 , 3},;  //Incluir
                     { STR0004 ,"GA030", 0 , 4}}   //Alterar
                   //{ "Excluir" ,"GA030", 0 , 5}} && Excluir    && Nao pode ser excluido
Return aRotina
