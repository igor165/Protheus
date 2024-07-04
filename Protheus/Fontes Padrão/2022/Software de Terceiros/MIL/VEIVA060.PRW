#INCLUDE "veiva060.ch"
#Include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ VEIVA060 ณ Autor ณ Emilton               ณ Data ณ 28/09/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Cadastro de Opcionais / Acessorios e Eqptos do Veiculo     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VEIVA060

Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006) //"Cadastro de Opcionais & Equipamentos do Veiculo"
Private cGruFor   := "04"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VV1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA060     บAutor  ณFabio               บ Data ณ  10/05/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VA060(cAlias,nReg,nOpc)

Local bCampo := { |nCPO| Field(nCPO) }
Local i      := 0
Local aOrdem := {}
Local nCntFor := 0
Local _ni	  := 0

Private nOpcX := nOpc
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  := {} , nControlAba := 1 , nLenOpc:=0 , nLenEqp:=0
Private aCols    := {} , aHeader    := {}
Private aColsOpc := {} , aHeaderOpc := {}
Private aColsEqp := {} , aHeaderEqp := {}

Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nLinhas := 0

if nOpc = 3 .or. nOpc = 4 //inclusao / alteracao
   if VV1->(RecCount()) = 0
      MsgInfo(STR0009,STR0010) //Nenhum veiculo cadastrado... # Atencao!
   Endif
Endif      

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VV1",.t.)         // .t. para carregar campos virtuais

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV1")
While !Eof().And.(x3_arquivo=="VV1")

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      AADD(aCpoEnchoice,x3_campo)
   Endif

   &("M->"+x3_campo):= CriaVar(x3_campo)

   dbSkip()

End

   DbSelectArea("VV1")

   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next

If nOpc == 3 //inclusao
   nOpcE := 2
   nOpcG := 3
Elseif nOpc == 4 //alteracao
   nOpcE := 2
   nOpcG := 4
Elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
Else
   nOpcE := 2
   nOpcG := 5
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
&& Opcionais / Acessorios
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VV6")
While !Eof().And.(x3_arquivo=="VV6")
   
   If !(Alltrim(x3_campo) $ [VV6_NUMATE/VV6_CHAINT/VV6_DESGRU]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
      aAdd(aHeaderOpc,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif   
   
   &("M->"+x3_campo) := CriaVar(x3_campo)

   dbSkip()

End

dbSelectArea("VV6")
ADHeadRec("VV6",aHeaderOpc)

&& Equipamentos do Veiculo
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VVZ")
While !Eof().And.(x3_arquivo=="VVZ")
   
   If !(Alltrim(x3_campo) $ [VVZ_CHAINT]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
      aAdd(aHeaderEqp,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif   
   
   &("M->"+x3_campo) := CriaVar(x3_campo)

   dbSkip()

End

dbSelectArea("VVZ")
ADHeadRec("VVZ",aHeaderEqp)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aCols da getdados                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aColsOpc :={}
aColsEqp :={}

&& Opcionais / Acessorios
dbSelectArea("VV6")                                 
dbSetOrder(1)
dbSeek(xFilial("VV6")+M->VV1_CHAINT)

Do While !eof() .And. VV6->VV6_CHAINT == M->VV1_CHAINT ;
                .And. VV6->VV6_FILIAL == xFilial("VV6")

   aAdd(aColsOpc,Array(Len(aHeaderOpc)+1))
   For _ni:=1 to Len(aHeaderOpc)

		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderOpc[_ni,2])
			aColsOpc[Len(aColsOpc),_ni] := VV6->(RecNo())
		ElseIf IsHeadAlias(aHeaderOpc[_ni,2])
			aColsOpc[Len(aColsOpc),_ni] := "VV6"
		Else
         aColsOpc[Len(aColsOpc),_ni]:=If(aHeaderOpc[_ni,10] != "V",FieldGet(FieldPos(aHeaderOpc[_ni,2])),CriaVar(aHeaderOpc[_ni,2]))
      EndIf
         
   Next
   aColsOpc[Len(aColsOpc),Len(aHeaderOpc)+1]:=.F.
   
   nLenOpc := Len(aColsOpc)
   
   DbSelectArea("VV6")
   DbSkip()
       
EndDo

If Len(aColsOpc) == 0

   aColsOpc:={Array(Len(aHeaderOpc)+1)}
   aColsOpc[1,Len(aHeaderOpc)+1]:=.F.

   For _ni:=1 to Len(aHeaderOpc)
   
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderOpc[_ni,2])
			aColsOpc[Len(aColsOpc),_ni] := 0
		ElseIf IsHeadAlias(aHeaderOpc[_ni,2])
			aColsOpc[Len(aColsOpc),_ni] := "VV6"
		Else
         aColsOpc[1,_ni]:=CriaVar(aHeaderOpc[_ni,2])
      EndIf
         
   Next                

EndIf   

&& Equipamentos do Veiculo
dbSelectArea("VVZ")
dbSetOrder(1)
dbSeek( xFilial() + M->VV1_CHAINT )

Do While !eof() .And. VVZ->VVZ_CHAINT == M->VV1_CHAINT ;
                .And. VVZ->VVZ_FILIAL == xFilial("VVZ")

   aAdd(aColsEqp,Array(Len(aHeaderEqp)+1))
   For _ni:=1 to Len(aHeaderEqp)

		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderEqp[_ni,2])
			aColsEqp[Len(aColsEqp),_ni] := VVZ->(RecNo())
		ElseIf IsHeadAlias(aHeaderEqp[_ni,2])
			aColsEqp[Len(aColsEqp),_ni] := "VVZ"
		Else
         aColsEqp[Len(aColsEqp),_ni]:=If(aHeaderEqp[_ni,10] != "V",FieldGet(FieldPos(aHeaderEqp[_ni,2])),CriaVar(aHeaderEqp[_ni,2]))
      EndIf
         
   Next
   aColsEqp[Len(aColsEqp),Len(aHeaderEqp)+1]:=.F.
   
   nLenEqp := Len(aColsEqp)

   DbSelectArea("VVZ")
   DbSkip()
       
EndDo

If Len(aColsEqp) == 0

   aColsEqp:={Array(Len(aHeaderEqp)+1)}
   aColsEqp[1,Len(aHeaderEqp)+1]:=.F.

   For _ni:=1 to Len(aHeaderEqp)
   
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderEqp[_ni,2])
			aColsEqp[Len(aColsEqp),_ni] := 0
		ElseIf IsHeadAlias(aHeaderEqp[_ni,2])
			aColsEqp[Len(aColsEqp),_ni] := "VVZ"
		Else
         aColsEqp[1,_ni]:=CriaVar(aHeaderEqp[_ni,2])
      EndIf
         
   Next                

EndIf   

//DbSelectArea("VV1")
//DbSetOrder(1)
//DbSeek( xFilial("VV1") + M->VV1_CHAINT )

If Len( aHeaderOpc ) > 0 .And. Len( aHeaderEqp ) > 0

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Executa a Modelo 3                                           ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   cTitulo       :=STR0006
   cAliasEnchoice:="VV1"
   cAliasGetD    :="VV6"
   cLinOk        :="FS_VLPASTAS()"
   cTudOk        :="FS_PASTASG()"
   cFieldOk      :="FG_MEMVAR(),FS_VA060VALID()"
   nLinhas       := 99

   && Monta arquivo para nao dar problema na hora de montar a tela
   aOrdem := {}
   i := 0
   aAdd(aOrdem, { "oGetOpc" , 1 , Len(aHeaderOpc) } )
   aAdd(aOrdem, { "oGetEqp" , 2 , Len(aHeaderEqp) } )

   aSort(aOrdem,,,{|x,y| x[3] < y[3] } )

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 34,80	of oMainWnd
   
   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,75,315},,3,,,,oDlg,,.F.,,,.F.,,,,,.T.)

   SetEnch("")
   @ 072,001 FOLDER oFolder SIZE 315,175 OF oDlg PROMPTS STR0007,STR0008 PIXEL //"&Opcionais / Acessorios" / "Equipamentos do Veiculo"
   && Abas do Folder
   FG_INIFOLDER("oFolder")

   && Monta Get'sdados
   For i := 1 to Len( aOrdem )

      FS_ABA( aOrdem[i,2] )
      &( aOrdem[i,1] ) := MsGetDados():New(001,001,105,312,nOpcG,cLinOk,cTudOk,"", If(nOpcG==2.Or.nOpcG==5,.F.,.T.) ,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[aOrdem[i,2]])
	  
   Next

   oGetOpc:oBrowse:bChange := {|| FS_AALTER("VV6",nLenOpc,oGetOpc) }
   oGetEqp:oBrowse:bChange := {|| FG_AALTER("VVZ",nLenEqp,oGetEqp,aHeaderEqp) }

   oFolder:bSetOption := {|| FS_SETOPTION(oFolder:nOption) }
   oFolder:bChange    := {|| FS_ABA(oFolder:nOption) }

   ACTIVATE MSDIALOG oDlg ON INIT ( EnChoiceBar(oDlg,{|| nOpca := 1,FS_SETOPTION(oFolder:nOption),If(obrigatorio(aGets,aTela).And.&(cTudOk) .And. FS_GRAOPCEQP( nOpc ) , oDlg:End(), nOpca:=0 ) } , {||nOpca := 0,oDlg:End()}) , FS_ABA( 1 ) ) CENTER
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ABA    บAutor  ณFabio               บ Data ณ  08/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControla abas                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ABA(nAba)

aCols   := {}
aHeader := {}

If nAba == 1

   aHeader := aClone( aHeaderOpc )
   aCols   := aClone( aColsOpc )

   If Type("oGetOpc") != "U" .And. Type("oGetEqp") != "U"
      oGetOpc:oBrowse:Enable()
      oGetEqp:oBrowse:Disable()
      n := oGetOpc:oBrowse:nAt
      oGetOpc:oBrowse:Refresh()
   EndIf   

ElseIf nAba == 2

   aHeader := aClone( aHeaderEqp )
   aCols   := aClone( aColsEqp )

   If Type("oGetOpc") != "U" .And. Type("oGetEqp") != "U"
      oGetOpc:oBrowse:Disable()
      oGetEqp:oBrowse:Enable()
      n := oGetEqp:oBrowse:nAt
      oGetEqp:oBrowse:Refresh()
   EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SETOPTIบAutor  ณFabio               บ Data ณ  08/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida mudanca de aba                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
Static Function FS_SETOPTION(nAba)

Local nColuna := 0 
Local _nReg

If nAba == 1

   aHeaderOpc := aClone( aHeader )
   aColsOpc   := aClone( aCols )

ElseIf nAba == 2

   aHeaderEqp := aClone( aHeader )
   aColsEqp   := aClone( aCols )

EndIf      
For _nReg := 1 to Len(aCols)
   if aCols[_nReg,1] == "1" .and. Empty(aCols[_nReg,2]) 
      MsgInfo(STR0011,STR0010)// Campo codigo opcional deve ser informado... # atencao
      Return(.f.)
   Endif   
Next

If nOpcX==2 .or. nOpcX == 5
	Return .T.
Endif	
&& Verifica caso tenha sido digitado algum conteudo na linha se todo os campos obrigatorios foram informados
For nColuna := 1 to Len(aHeader)
   
    If !Empty(aCols[n,nColuna])
   
       if !Empty(M->VVZ_SEQUEN) .or. !Empty(M->VVZ_DESEQP)
	       If !FG_OBRIGAT() .Or. !FS_VLPASTAS()
	          Return(.f.)
	       Else
    	      Exit
	       EndIf          
      Endif
    EndIf
    
Next   

Return(.t.)                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGRAOPCEQP บAutor  ณEmilton             บ Data ณ  29/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAOPCEQP( nOpc )

Private lMsHelpAuto := .t., lMsFinalAuto := .f.
If !FS_VALGRAOPCEQP( nOpc , .t. )

   MostraErro()
   Return( .f. )

EndIf
                                       
Begin Transaction

   FS_VALGRAOPCEQP( nOpc )

End Transaction
lMsHelpAuto := .f.


Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGRAOPCEQP บAutor  ณEmilton             บ Data ณ  29/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VALGRAOPCEQP( nOpc , lValid )
   
Local nReg := 0    
Private lMsErroAuto := .f. , lMsHelpAuto := .t.
                                            
lValid := If( lValid == NIL , .f. , lValid )

If nOpc == 2
   Return(.t.)
EndIf

&& Salvar aCols e aHeader p/ o vetor de origem
If !FS_SETOPTION(oFolder:nOption)
   Return(.f.)
EndIf

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek( xFilial("VV1") + M->VV1_CHAINT )

&& Grava Opcionais / Acessorios
If !lValid

   For nReg := 1 to Len(aColsOpc)

      If aColsOpc[nReg,Len(aColsOpc[nReg])]
         Loop
      EndIf
      
      DbSelectArea("VV6")
      DbSetOrder(1)
      DbSeek( xFilial("VV6") + M->VV1_CHAINT + aColsOpc[nReg,FG_POSVAR("VV6_GRUITE","aHeaderOpc")] + aColsOpc[nReg,FG_POSVAR("VV6_CODITE","aHeaderOpc")] )
             
      If nOpc != 5 .And. !aColsOpc[nReg,Len(aColsOpc[nReg])] .And. ;
	      Iif(aColsOpc[nReg,FG_POSVAR("VV6_TIPREG","aHeaderOpc")]=="2",!Empty( aColsOpc[nReg,FG_POSVAR("VV6_GRUITE","aHeaderOpc")] ),;
				!Empty( aColsOpc[nReg,FG_POSVAR("VV6_CODOPC","aHeaderOpc")] ))      
     
         RecLock("VV6", !Found() )
         FG_GRAVAR("VV6",aColsOpc,aHeaderOpc,nReg)
         VV6->VV6_FILIAL := xFilial("VV6")
         VV6->VV6_CHAINT := M->VV1_CHAINT
         VV6->VV6_GRUITE := aColsOpc[nReg,FG_POSVAR("VV6_GRUITE","aHeaderOpc")]
         VV6->VV6_CODITE := aColsOpc[nReg,FG_POSVAR("VV6_CODITE","aHeaderOpc")]
         MsUnLock()
 
      ElseIf Found()    
      
         && Deleta Servico
         RecLock("VV6",.F.,.T.)
         dbdelete()
         MsUnlock()
         WriteSx2("VV6")
      
      EndIf   
   
   Next

   && Grava Equipamentos do Veiculo
   For nReg := 1 to Len(aColsEqp)

      If aColsEqp[nReg,Len(aColsEqp[nReg])]
         Loop
      EndIf
      
      DbSelectArea("VVZ")
      DbSetOrder(1)
      DbSeek( xFilial("VVZ") + M->VV1_CHAINT + aColsEqp[nReg,FG_POSVAR("VVZ_SEQUEN","aHeaderEqp")] )
   
      If nOpc != 5 .And. !aColsEqp[nReg,Len(aColsEqp[nReg])] .And. !Empty( aColsEqp[nReg,FG_POSVAR("VVZ_SEQUEN","aHeaderEqp")] )

         RecLock("VVZ", !Found() )
         FG_GRAVAR("VVZ",aColsEqp,aHeaderEqp,nReg)
         VVZ->VVZ_FILIAL := xFilial("VVZ")
         VVZ->VVZ_CHAINT := VV1->VV1_CHAINT
         VVZ->VVZ_SEQUEN := aColsEqp[nReg,FG_POSVAR("VVZ_SEQUEN","aHeaderEqp")]
         MsUnLock()
   
      ElseIf Found()
      
         && Deleta Servico
         RecLock("VVZ",.F.,.T.)
         dbdelete()
         MsUnlock()
         WriteSx2("VVZ")
   
      EndIf
   
   Next

EndIf    

Return( !lMsErroAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VA060VAบAutor  ณFabio               บ Data ณ  08/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida Duplicidade                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VA060VALID()
       
If ( ReadVar() $ "M->VVL_DATGAR" .And. aScan(aCols,{|x| x[FG_POSVAR("VVL_DATGAR")] == M->VVL_DATGAR }) # 0 ) .or.;
   ( ReadVar() $ "M->VVM_CODOPC" .And. aScan(aCols,{|x| x[FG_POSVAR("VVM_CODOPC")] == M->VVM_CODOPC }) # 0 ) .or. ;
   ( ReadVar() $ "M->VVP_DATPRC" .And. aScan(aCols,{|x| x[FG_POSVAR("VVP_DATPRC")] == M->VVP_DATPRC }) # 0 ) .or. ;
   ( ReadVar() $ "M->VV0_DATBON" .And. aScan(aCols,{|x| x[FG_POSVAR("VVO_DATBON")] == M->VVO_DATBON }) # 0 )
	
	Help("  ",1,"EXISTCHAV")
	Return(.f.)
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLCONTAบAutor  ณFabio               บ Data ณ  02/21/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se a conta ja foi informada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VLPASTAS()

Local nPosTip := FG_POSVAR("VV6_TIPREG")
Local nPosOpc := FG_POSVAR("VV6_CODOPC")
Local nReg    := 0   
Local ix1     := 0   

FG_MEMVAR()
               
For ix1 := 1 to len(aCols)

   If aCols[ix1,len(aHeader)+1]
      loop
   EndIf                                                         
   If oFolder:nOption == 1
		If !aCols[ix1,Len(aCols[ix1])]
			If aCols[ix1,nPosTip]=="1" // Acessorio original
				If aCols[ix1,nPosOpc] == M->VV6_CODOPC 
	      	   nReg ++
	         	If nReg > 1
						Help(" ",1,"EXISTCHAV")
						Return .f.
					Endif	
				Endif	
			Elseif aCols[ix1,nPosTip]=="2" // Outros Acessorios (SB1)	
		      If aCols[ix1,FG_POSVAR("VV6_GRUITE")]+aCols[ix1,FG_POSVAR("VV6_CODITE")] == ;
	   	   	M->VV6_GRUITE+M->VV6_CODITE 
	      	   nReg ++
	         	If nReg > 1
		            Help("  ",1,"EXISTCHAV")
	   	         Return( .f. )
	      	   EndIf
	      	Endif  
			Endif
		Endif
   Else
		If !aCols[ix1,Len(aCols[ix1])]
	      If aCols[ix1,FG_POSVAR("VVZ_SEQUEN")] == M->VVZ_SEQUEN
	         nReg ++
	         If nReg > 1
	            Help("  ",1,"EXISTCHAV")
	            Return( .f. )
	         EndIf
	      EndIf
	   EndIf
	Endif
	If !FG_OBRIGAT()
		Return (.F.)
	Endif	
Next              

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLCONTAบAutor  ณFabio               บ Data ณ  02/21/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se a conta ja foi informada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_PASTASG()

Local nRegOpc := 0   
Local nRegEqp := 0   
Local ix1     := 0   
/*
If !FS_SETOPTION(oFolder:nOption)
   Return .f.
EndIf
*/
FG_MEMVAR()
oFolder:nOption := 1               
For ix1 := 1 to len(aColsOpc)

   If aColsOpc[ix1,len(aHeaderOpc)+1]
      loop
   EndIf                                                         
   
   If aColsOpc[ix1,FG_POSVAR("VV6_GRUITE","aHeaderOpc")]+aColsOpc[ix1,FG_POSVAR("VV6_CODITE","aHeaderOpc")] == M->VV6_GRUITE+M->VV6_CODITE
      nRegOpc ++
      If nRegOpc > 1
         Help("  ",1,"EXISTCHAV")
         Return( .f. )
      EndIf
   Else 
      Loop
   EndIf
   
Next              
oFolder:nOption := 2               
For ix1 := 1 to len(aColsEqp)

   If aColsEqp[ix1,len(aHeaderEqp)+1]
      loop
   EndIf                                                         
   
   If aColsEqp[ix1,FG_POSVAR("VVZ_SEQUEN","aHeaderEqp")] == M->VVZ_SEQUEN
      nRegEqp ++
      If nRegEqp > 1
         Help("  ",1,"EXISTCHAV")
         Return( .f. )
      EndIf
   Else 
      Loop
   EndIf
   
Next              
oFolder:nOption := 1
Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FORSER บAutor  ณFabio               บ Data ณ  02/21/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtro para apresentar apenas os opcionais Fora de Serie   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_FORSER()                                     

If VV1->VV1_CODMAR != VVM->VVM_CODMAR
   Return .f.
EndIf
If VV1->VV1_MODVEI != VVM->VVM_MODVEI
   Return .f.
EndIf
If VV1->VV1_SEGMOD != VVM->VVM_SEGMOD
   Return .f.
EndIf
If !FG_SEEK("VVW","VVM->VVM_CODMAR+VVM->VVM_CODOPC",1,.f.)
   Return .f.
EndIf
If VVW->VVW_OPCSER == "0"
   return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALIDOPCบAutor  ณFabio               บ Data ณ  02/21/01  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do codigo do opcional                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_VALIDOPC()
                  
If FG_SEEK("VVW","VV1->VV1_CODMAR+M->VV6_CODOPC",1,.f.) .and.;
   FG_SEEK("VVM","VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+VVW->VVW_CODOPC",1,.f.)
   aCols[n,FG_POSVAR("VV6_GRUITE","aHeader")] := VVW->VVW_GRUITE
   aCols[n,FG_POSVAR("VV6_CODITE","aHeader")] := VVW->VVW_CODITE
   aCols[n,FG_POSVAR("VV6_DESITE","aHeader")] := VVW->VVW_DESOPC
   M->VV6_GRUITE                              := VVW->VVW_GRUITE
   M->VV6_CODITE                              := VVW->VVW_CODITE
   M->VV6_DESITE                              := VVW->VVW_DESOPC
   return .t.
Else
   return .f.
EndIf

Return .t.

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FG_AALTER ณ Autor ณ Fabio                 ณ Data ณ 28/09/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Travamento de aCols para Chaves ja gravadas                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcAliasCh - Alias a ser pesquisado                            ณฑฑ
ฑฑณ          ณnLenAcols- Numero de Linhas ja preenchidas                   ณฑฑ
ฑฑณ          ณoNomObj  - Nome do Objeto da GetDados a ser tratado          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_AALTER(cAliasCh,nLenaCols,oNomObj)
       
Local aArea       := {}
Local cSele       := Alias()
Local cVarCh      := ""
Local aAlter      := {}
Local nAlter      :=0
Local nAlterHeader:=0

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "SIX")

DbSelectArea("SIX")      
DbSetOrder(1)
If DbSeek( cAliasCh + "1" )
   cVarCh := Alltrim( SIX->CHAVE )
   cVarCh += "+VV6->VV6_TIPREG+VV6->VV6_CODOPC"
Else
   cVarCh := &(cAliasCh+"->(IndexKey())")
EndIf   
      
Aadd(aAlter,{})
Aadd(aAlter,{})
For nAlterHeader:=1 to Len(aHeader)
   If !( Alltrim( aHeader[nAlterHeader,2] ) $ cVarCh )
      Aadd(aAlter[1],aHeader[nAlterHeader,2] )
   EndIf
   Aadd(aAlter[2],aHeader[nAlterHeader,2] )
Next      
                  
If nLenaCols >= n 
   oNomObj:aAlter := oNomObj:oBrowse:aAlter := aClone(aAlter[1])
Else
   oNomObj:aAlter := oNomObj:oBrowse:aAlter := aClone(aAlter[2])
EndIf   

&& Volta posicoes originais
sRestArea(aArea)

DbSelectArea(cSele)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA060DESC บAutor  ณRicardo Farinelli   บ Data ณ  11/28/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a descricao do acessorio ou do produto             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VA060DESC()              
If VV6->VV6_TIPREG=="1"
	Return Posicione("VVW",1,xFilial("VVW")+VV1->VV1_CODMAR+VV6->VV6_CODOPC,"VVW_DESOPC")
Else
	Return Posicione("SB1",7,xFilial("SB1")+VV6->VV6_GRUITE+VV6->VV6_CODITE,"B1_DESC")
Endif
Return

Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0001) ,"AxPesqui", 0 , 1}   ,; // Pesquisar
                  { OemToAnsi(STR0002) ,"VA060"   , 0 , 2}   ,; // Visualizar
                  { OemToAnsi("Opc/Acess/Eq Veic") ,"VA060"   , 0 , 4}	 ,; // Alterar
                  { OemToAnsi(STR0005) ,"VA060"   , 0 , 5}}		// Excluir
                  //{ OemToAnsi(STR0003) ,"VA060"   , 0 , 3}   ,; // Incluir
Return aRotina
