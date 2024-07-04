#Include "Protheus.ch"
#Include "VEIVM110.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM110 ³ Autor ³  Manoel               ³ Data ³ 03/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Valor do Bonus de Fabrica / Valor de Venda Acordo ³±±
±±³          ³ e Localizacao do Veiculo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM110

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor, _ni

Private aRotina := {{},{},{},{},{}}					
cCadastro  := OemToAnsi(STR0001) //Altera Bonus de Fabrica e Valor de Acordo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VV1")

//FS_AltVm110()

Inclui := .f.

aRotina := {  {"","" , 0 , 1},;   	  // Pesquisar
					{"","", 0 , 2} ,; // Consultar
					{"","", 0 , 3} ,; // Incluir
					{"","", 0 , 4 },; // Alterar
					{"","", 0 , 5 } } // Excluir

						
nOpcE := 4
nOpcG := 4

Aheader := {}
nUsado:=0

DbSelectArea("SX3")
DbSeek("VV1")
While !Eof().and.(x3_arquivo=="VV1")
   if Alltrim(x3_campo) $ "VV1_CHASSI#VV1_PRCACO#VV1_BONFAB" //#VV1_LOCALI#VV1_DESLOC"
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
	        x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif   
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV1_CHAINT")
While !Eof().and.(x3_arquivo+x3_campo=="VV1VV1_CHAINT") 
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
	        x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	DbSkip()
EndDo
           
RegToMemory("VV1",.f.)
DbSelectArea("VV1")
For nCntFor := 1 TO FCount()
    M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

DbSetOrder(2)
dbgotop()

acols:={}
While !eof() .and. VV1->VV1_FILIAL == xFilial("VV1") 

	If VV1->VV1_ESTVEI == "0" .and. VV1->VV1_SITVEI == "0"
	
		AADD(acols,Array(nUsado+1))
		For _ni:=1 to nUsado
			acols[Len(acols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		Next
		acols[Len(acols),nUsado+1]:=.F.
	Endif
		
	dbSkip()
Enddo

cTitulo    := OemToAnsi(STR0002)	//Altera Valor de Bonus / Acordo / Localizacao
cAliasEnch := "VV1"
cLinOk     := "FG_OBRIGAT"
cTudoOk    := "AllwaysTrue()"
cFieldOk   := "FG_MEMVAR()"

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
nPosAnt:=9999,      nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcG := If(nOpcG==Nil,3,nOpcG)
nOpca := 0
lVirtual := .f.
nLinhas:= 99           
Inclui := .f.
Altera := .t.

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
oGetDados:= MsGetDados():New(15,1,143,315,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk)
//oGetDados:oBrowse:bEditCol := {|| FS_TrataAcols() }
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})

if nOpca == 1
   FS_GvVm110()
Endif



Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GvVm110³ Autor ³  Manoel               ³ Data ³ 03/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava campos alterados                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GvVm110()

Local i_

lMSHelpAuto := .f.
lMSErroAuto := .f.
             
DbSelectArea("VV1")
dbSetOrder(1)

Begin Transaction


For i_ :=1 to len(aCols)
		
	if aCols[i_,len(aHeader)+1]
		loop
	Endif

	If dbSeek(xFilial("VV1")+acols[i_,FG_POSVAR("VV1_CHAINT","aHeader")])
		
		if !recLock("VV1",.f.)
	      Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif	
		VV1->VV1_BONFAB := aCols[i_,FG_POSVAR("VV1_BONFAB","aHeader")]
		VV1->VV1_PRCACO := aCols[i_,FG_POSVAR("VV1_PRCACO","aHeader")]
	    //VV1->VV1_LOCALI := aCols[i_,FG_POSVAR("VV1_LOCALI","aHeader")]
		//VV1->VV1_DESLOC := aCols[i_,FG_POSVAR("VV1_DESLOC","aHeader")]
   Endif
   
Next
	                        
End Transaction

DbSelectArea("VV1")
dbSetOrder(2)
	
if lMsErroAuto
	MostraErro()
   lMSHelpAuto := .f.
   lMSErroAuto := .f.
	lDeleta := .t.
	Return .f.
Endif

lMsHelpAuto := .f.
   
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TRATAACOLS Autor³ Manoel             º Data ³  17/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Trata Acols da Tela de Atualizacao                   		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                        /*
Static Function FS_TrataAcols()

If oGetDados:oBrowse:nAt + 1 <= Len(aCols)

	If !Left(aCols[n,FG_POSVAR("VV1_LOCALI","aHeader")],1) $ "R/O"
		n := ( oGetDados:oBrowse:nAt += 1 )      
		nPosCor := (oGetDados:oBrowse:nColPos - 1)
		oGetDados:oBrowse:nColPos  := 1
		oGetDados:oBrowse:nColPos  := nPosCor
		oGetDados:oBrowse:Refresh()
	Endif
		
EndIf

Return
*/
