#include "Protheus.ch"
#include "Ofioa390.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OFIOA390  ³ Autor ³ Andre                 ³ Data ³ 12/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cadastro do layout do PEF                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³Autor    ³Descricao                                         ³±±
±±³          ³         ³                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA390

Local i

DEFINE FONT oFtTexto NAME "MS LineDraw" SIZE 07,8

Private aNewBot := {{STR0007,"EDITOR()",STR0008},{STR0009,"IMPORTAPF()",STR0010}}
For i:=1 to Len(aNewBot)
    Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
Next
PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006)  // //"Layout de digitacao do PEF"
Private nUsado := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VZ2")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OA390     ³ Autor ³ Andre                 ³ Data ³ 12/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de criacao da tela para cadastramento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³Autor    ³Descricao                                         ³±±
±±³          ³         ³                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA390(cAlias, nReg, nOpc)

Local bCampo   := { |nCPO| Field(nCPO) } , nCntFor := 0 , _ni := 0 , _lRet := .t.
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 
Local nPosRec := 0
Private aTELA[0][0],aGETS[0]
Private aCols := {}, aHeader := {} , aCpoEnchoice  :={}
Private nLenAcols := 0

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
   Otherwise      && Excluir
        nOpcE:=5
        nOpcG:=5
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VZ2",.T.)

aCpoEnchoice  :={}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VZ2")
While !Eof().and.(x3_arquivo=="VZ2")
   If X3USO(x3_usado).and.cNivel >=x3_nivel
      AADD(aCpoEnchoice,x3_campo)
      &("M->"+x3_campo):= CriaVar(x3_campo)
   Endif
   dbSkip()
End
If !(Inclui)
   DbSelectArea("VZ2")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VZ3")
aHeader:={}
While !Eof().And.(x3_arquivo=="VZ3")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ "VZ3_CODMAR#VZ3_CODIGO")
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      &("M->"+x3_campo) := CriaVar(x3_campo)
   Endif
   dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VZ3")
ADHeadRec("VZ3",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

aCols:={}
dbSelectArea("VZ3")
dbSetOrder(1)
dbSeek(xFilial("VZ3")+M->VZ2_CODMAR+M->VZ2_CODIGO)

If nOpc == 3 .Or. !Found()
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VZ3"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf	
   Next
Else
   While !eof() .And. VZ3->VZ3_FILIAL == xFilial("VZ3") .and. M->VZ2_CODIGO == VZ3->VZ3_CODIGO
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VZ3->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VZ3"
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
   cTitulo       :=STR0006   //"Grupo de Ferramentas & Ferramentas"
   cAliasEnchoice:="VZ2"
   cAliasGetD    :="VZ3"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"

   DEFINE MSDIALOG oDlg1 TITLE cTitulo From 9,0 to 28,80	of oMainWnd

      EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)

      oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)

   ACTIVATE MSDIALOG oDlg1 ON INIT FG_EnchoiceBar(oDlg1,{|| if(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_GRV390(nOpc),oDlg1:End(),.f.) },{|| oDlg1:End() },,aNewBot)

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FS_KEY390 ³ Autor ³ Andre                 ³ Data ³ 12/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de verificacao de duplicidade na chave principal     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³Autor    ³Descricao                                         ³±±
±±³          ³         ³                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_KEY390()
                             
If ReadVar() == "M->VZ3_SEQDIG" .And. (FG_Seek("VZ3","M->VZ2_CODMAR+M->VZ2_CODIGO+M->VZ3_SEQDIG",3,.f.) .Or. Ascan(aCols,{|x| x[FG_POSVAR("VZ3_SEQDIG")] == M->VZ3_SEQDIG }) # 0)
   
   Help("  ",1,"EXISTCHAV") 
              
   Return(.f.)
   
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FS_GRV390 ³ Autor ³ Andre                 ³ Data ³ 12/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de GRAVACAO dos dados digitados                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³Autor    ³Descricao                                         ³±±
±±³          ³         ³                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRV390(nOpc)

Local lRet   := .t. , i := 0
Local lValid := .t.

Private lMsHelpAuto := .t.

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2

   dbselectArea("VZ2")  
   dbSetOrder(1)
   lValid := dbseek(xFilial("VZ2")+M->VZ2_CODMAR+M->VZ2_CODIGO)

   If (Inclui .or. Altera) .and. nOpc <> 5

      // Grava arquivo pai
      If !RecLock("VZ2", !lValid )
         Help("  ",1,"REGNLOCK")
         lRet := .f.
         DisarmTransaction()
         Break               
      EndIf
      FG_GRAVAR("VZ2")
      MsUnlock()   
     
      // Grava arquivo filho
      for i:=1 to len(aCols)
	                               
         dbselectArea("VZ3")
         dbSetOrder(1)
         lValid := dbseek(xFilial("VZ3")+M->VZ2_CODMAR+M->VZ2_CODIGO+aCols[i,FG_POSVAR("VZ3_SEQDIG")])

	      // Pula se estiver deletado no aCols
         If aCols[i,Len(aCols[i])]
		      // Apaga arquivo filho
		      if lValid
	   		   If !RecLock("VZ3", .F.,.T. )
	      		   Help("  ",1,"REGNLOCK")
		      		lRet := .f.
  			      	DisarmTransaction()
  	   			   Break               
		      	EndIf
			      dbdelete()
  				   MsUnlock()
     				WriteSx2("VZ3")
		   	Endif	
            Loop
         EndIf

         If !RecLock("VZ3", !lValid )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
	            
         FG_GRAVAR("VZ3",aCols,aHeader,i)
         VZ3->VZ3_FILIAL := xFilial("VZ3")
         VZ3->VZ3_CODMAR := M->VZ2_CODMAR
         VZ3->VZ3_CODIGO := M->VZ2_CODIGO
         MsUnlock()

	   next
	Else
      If nOpc == 5
	      // Apaga arquivo pai
   	   If !RecLock("VZ2", .F.,.T. )
      	   Help("  ",1,"REGNLOCK")
         	lRet := .f.
	         DisarmTransaction()
   	      Break               
      	EndIf
         dbdelete()
         MsUnlock()
         WriteSx2("VZ2")
     
	      // Apaga arquivo filho
   	   for i:=1 to len(aCols)
	         dbselectArea("VZ3")
   	      dbSetOrder(3)
      	   if dbseek(xFilial("VZ3")+M->VZ2_CODMAR+M->VZ2_CODIGO+aCols[i,FG_POSVAR("VZ3_SEQDIG")])
		   	   If !RecLock("VZ3", .F.,.T. )
		      	   Help("  ",1,"REGNLOCK")
   		      	lRet := .f.
	   		      DisarmTransaction()
   	   		   Break               
		      	EndIf
   		      dbdelete()
      		   MsUnlock()
         		WriteSx2("VZ3")
         	Endif	
   		next
	   Endif
   Endif
Endif                        

End Transaction

Return(lRet)
      

Function EDITOR()

Local cObserv  := ""
Local nOpca    := 2
Local cArquivo := GetMv("MV_LPOSFIN")

Imputfile := ft_fuse(cArquivo)
ft_fgotop()
Do While !ft_feof()
   cObserv := cObServ + alltrim(ft_freadln())+CHR(13)+CHR(10)
   ft_fskip()
Enddo
ft_fuse()

DEFINE MSDIALOG oDlgEdt TITLE OemtoAnsi(STR0013) FROM  02,04 TO 35,75 OF oMainWnd //Layout

DEFINE SBUTTON FROM 236,217 TYPE 1 ACTION (nOpca := 1, oDlgEdt:End()) ENABLE OF oDlgEdt
DEFINE SBUTTON FROM 236,248 TYPE 2 ACTION (nOpca := 2, oDlgEdt:End()) ENABLE OF oDlgEdt

@ 237, 005 SAY STR0011 SIZE 200,08 OF oDlgEdt PIXEL COLOR CLR_BLUE
@ 01,01 GET oObserv VAR cObserv OF oDlgEdt MEMO SIZE 280,235 PIXEL
//oObserv:oFont := oFtTexto
oObserv:bRClicked := {|| AllwaysTrue() }
oObserv:lWordWrap := .f.
oObserv:SetFocus()

ACTIVATE MSDIALOG oDlgEdt CENTER

if nOpca == 1
   cNomArq    := cArquivo
   Outputfile := FCREATE(cNomArq,0)
   If FERROR() != 0 .And. OutputFile < 0
      cMsg := OemToAnsi(STR0012)
      MSGSTOP(cMsg)
      Return .f.
   EndIf
   fwrite(outputfile,cObserv)
   fclose(Outputfile)
Endif

Return


Function IMPORTAPF()

Local cLinha
Local cGrupo, cDescr
Local nSeque   := 1
Local cArquivo := GetMv("MV_LPOSFIN")
Local _ni:=0

if !MsgYesNo(STR0014,STR0015) //Confirma importacao do arquivo de layout ? # Atencao...
   Return .f.
Endif

Pergunte("OFM290", .T. )

dbSelectArea("VZ3")
dbSetOrder(2)

ft_fuse(cArquivo)
ft_fgotop()
while .not. ft_feof()
   cLinha := ft_freadln()
   if Empty(cLinha)
      ft_fskip()
      Loop
   Endif   
   if substr(cLinha,1,1) = "["
      cGrupo := substr(cLinha,2,3)
      cDescr := substr(cLinha,6,Len(Alltrim(cLinha))-6)
   else   
      dbSeek(xFilial("VZ3")+allTrim(mv_par01)+alltrim(mv_par02)+cGrupo+strzero(val(substr(cLinha,1,4)),4))
      reclock("VZ3",!found())
      vz3_filial := xfilial("VZ3")
	   vz3_codmar := mv_par01
	   vz3_codigo := alltrim(mv_par02)
   	vz3_seqdig := strzero(nSeque,4)
	   vz3_gructa := cGrupo
	   vz3_codcta := strzero(val(substr(cLinha,1,4)),4)
	   vz3_descta := alltrim(substr(cLinha,5,55))
	   vz3_tipcpo := iif(substr(cLinha,64,1)=="","D","C")
	   vz3_formul := substr(cLinha,61,Len(Alltrim(cLinha)))
	   vz3_txtfor := ""
	   vz3_nompas := cDescr
	   msunlock()
      nSeque++
	endif   
   ft_fskip()
Enddo

aCols:={}
dbSelectArea("VZ3")
dbSetOrder(1)
dbSeek(xFilial("VZ3")+M->VZ2_CODMAR+M->VZ2_CODIGO)

While !eof() .And. VZ3->VZ3_FILIAL == xFilial("VZ3") .and. M->VZ2_CODIGO == VZ3->VZ3_CODIGO
    AADD(aCols,Array(nUsado+1))
    For _ni:=1 to nUsado
       aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
    Next
    aCols[Len(aCols),nUsado+1]:=.F.
    dbSkip()
End

Return
                     
Static Function MenuDef()
Local aRotina := {{ STR0001 ,"axPesqui", 0 , 1},;  //Pesquisar
                    { STR0002 ,"OA390", 0 , 2},;   //Visualizar
                    { STR0003 ,"OA390", 0 , 3},;   //Incluir
                    { STR0004 ,"OA390", 0 , 4},;   //Alterar
                    { STR0005 ,"OA390", 0 , 5}}    //Excluir
Return aRotina
