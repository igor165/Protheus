// 浜様様様曜様様様様�
// � Versao � 9      �
// 藩様様様擁様様様様�
#include "Veivm020.ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VEIvm020 � Autor �  Andre                � Data � 06/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Cadastro de Veiculos em TRANSITO                           咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVM020()

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define o cabecalho da tela de atualizacoes                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Local aIndVV1 := {}

Private cCadastro := OemToAnsi(STR0001)
Private cChassi, cChaInt
Private aMemos:={{"VV1_OBSMEM","VV1_OBSERV"}}
Private aCampos := {}
Private aRotina := MenuDef()
Private cIndex , cChave , cCond , nIndex := 0
Private aNewBot := {}

DbSelectArea("VV1")
RetIndex()
DbSetOrder(1)
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := "VV1->VV1_SITVEI == '2'"
bFiltraBrw := {|| FilBrowse("VV1",@aIndVV1,@cCond) }
Eval(bFiltraBrw)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
mBrowse( 6, 1,22,75,"VV1")

dbSelectArea("VV1")
RetIndex("VV1")
dbClearFilter()
aEval(aIndVV1,{|x| Ferase(x[1]+OrdBagExt())})

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � Vei020V  � Autor �  Andre                � Data � 06/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Visualizar registro do Veiculo em TRANSITO                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function Vei020V(cAlias,nReg,nOpc)

CpoVei020()
AxVisual(cAlias,nReg,nOpc,aCampos)

DbSelectArea("VV1")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � Vei020I  � Autor �  Andre                � Data � 06/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Incluir registro do Veiculo em TRANSITO                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function Vei020I(cAlias,nReg,nOpc)

CpoVei020()
aNewBot := {}

If ( ExistBlock("VM020ABT") )
	aNewBot := ExecBlock("VM020ABT",.f.,.f.)
EndIf

If MSGYESNO(STR0007) //"Deseja escolher um carro j� cadastrado?"
	nCodigo := FS_BuscaVeic() // MV_PAR01
	If ! Empty(MV_PAR01)
		DbSelectArea("VV1")
		DbSetOrder(2)
		If( DbSeek( xFilial("VV1") + MV_PAR01 ) )
			If Empty(VV1->VV1_SITVEI)
				// "Deseja realmente mudar a Situa艫o do chassi: "
				If MSGYESNO((STR0010)+ ALLTRIM(VV1->VV1_CHASSI) + STR0011) // " para 'Em Transito' ?"
					RecLock( "VV1", .F. )
					VV1->VV1_SITVEI := "2"
					MsUnlock()
					FS_FENT020()
					VXA010GVO5(VV1->VV1_CHAINT,nOpc)
				Else
					MSGInfo(STR0012) // "Opera艫o cancelada."
				EndIf
			Else
				MSGInfo(STR0008) //"Situa艫o do ve�culo inv�lida"
			EndIf
		EndIf
	Else
		MSGInfo(STR0009) //"Sele艫o inv�lida"
	EndIf
Else
	If AxInclui(cAlias,nReg,nOpc,aCampos,,,"VM020VALSEG()",,,aNewBot) == 1
		RecLock( "VV1", .F. )
		VV1->VV1_SITVEI := "2"
		MsUnlock()

		FS_FENT020()
		VXA010GVO5(VV1->VV1_CHAINT,nOpc)
	EndIf
EndIf


If ExistBlock("VA010DPGR")
	ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,nOpc,nReg})
EndIf

dbSelectArea("VV1")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � Vei020A  � Autor �  Andre                � Data � 06/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Alterar registro do Veiculo em TRANSITO                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function Vei020A(cAlias,nReg,nOpc)

CpoVei020()
cChaInt := VV1->VV1_CHAINT
cChassi := VV1->VV1_CHASSI
aNewBot := {}

If ( ExistBlock("VM020ABT") )
	aNewBot := ExecBlock("VM020ABT",.f.,.f.)
EndIf
nOpca1 := AxAltera(cAlias,nReg,nOpc,aCampos,,,,"VM020VALSEG()",,,aNewBot)

if nOpca1 == 1
	
	RecLock("VV1",.f.)
	VV1->VV1_SITVEI := "2"
	MsUnlock()
	
	FS_FENT020()
	
	if cChassi # VV1->VV1_CHASSI
		FS_ALTvm020()
	Endif
	FG_AltLocal()
	
	VXA010GVO5(VV1->VV1_CHAINT,nOpc)
	If ExistBlock("VA010DPGR")
		ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,nOpc,nReg})
	EndIf
	
Endif


DbSelectArea("VV1")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � CpoVei020� Autor �  Andre                � Data � 06/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Levanta campos para montar a tela do Veiculo em TRANSITO   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function CpoVei020()

DbSelectArea("SX3")
dbseek("VV1")
aCampos := {}

Do While !eof() .and. x3_arquivo == "VV1"
	if X3USO(x3_usado).and.cNivel>=x3_nivel .and. !Alltrim(x3_campo) $ "VV1_TRACPA#VV1_NUMTRA"
		aadd(aCampos,x3_campo)
	Endif
	DbSkip()
Enddo
DbSelectArea("VV1")

Return .T.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �FS_ALTvm020� Autor �  Andre               � Data � 06/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Altera CHASSI no VVG / VVA / SB1                           咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_ALTvm020()

DbSelectArea("VVG")
DbSetOrder(2)
If DbSeek(xFilial("VVG")+cChaInt)
	While  VVG->VVG_FILIAL == xFilial("VVG") .and. VVG->VVG_CHAINT == cChaInt .and. !eof()
		RecLock("VVG",.f.)
		VVG->VVG_CHASSI := VV1->VV1_CHASSI
		MsUnlock()
		dbskip()
	Enddo
Endif

DbSelectArea("VVA")
DbSetOrder(3)
DbGoTop()
If dbseek(xFilial("VVA")+cChaInt)
	While VVA->VVA_FILIAL == xFilial("VVA") .and. VVG->VVG_CHAINT == cChaInt .and. !eof()
		RecLock("VVA",.f.)
		VVA->VVA_CHASSI := VV1->VV1_CHASSI
		MsUnlock()
		Dbskip()
	Enddo
Endif

DbSelectArea("SB1")
DbSetOrder(1)
DbGoTop()
If dbseek(xFilial("SB1")+cChaInt)
	While SB1->B1_FILIAL == xFilial("SB1") .and. Alltrim(SB1->B1_COD) == cChaInt .and. !eof()
		RecLock("SB1",.f.)
		SB1->B1_DESC := VV1->VV1_CHASSI
		MsUnlock()
		DbSkip()
	Enddo
Endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_FENT020� Autor � Rubens             � Data �  09/04/10   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Informar FILENT na gravacao do veiculo                     艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FENT020()

// Declaracao da ParamBox
Local aRet      := {}
Local aParamBox := {}
Local aCombo    := {}
Local cFilSD2   := ""
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
if VV1->(FieldPos("VV1_FILENT")) == 0
	Return
endif
If Len(aSM0) > 0
	cFilSD2 := ""
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		cFilSD2 += "'"+xFilial("SD2")+"',"
	Next
	cFilSD2 := left(cFilSD2,len(cFilSD2)-1)
	aCombo := &( "{" + cFilSD2 + "}" )
	cFilAnt := cBkpFilAnt
EndIf
AADD(aParamBox,{2,RetTitle("VV1_FILENT"),IIF(!Empty(VV1->VV1_FILENT),VV1->VV1_FILENT,xFilial("SD2")),aCombo,50,"",.F.})
if ParamBox(aParamBox,Alltrim(VV1->VV1_CHASSI),@aRet,,,,,,,,.F.)
	if !Empty(aRet[1])
		RecLock("VV1",.f.)
		VV1->VV1_FILENT := aRet[1]
		MsUnlock()
	endif
endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様曜様様様用様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VM020VALSEG�Autor  �Microsiga          � Data �  03/01/01   艮�
臼麺様様様様謡様様様様様擁様様様溶様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Valida segmento do Modelo                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VM020VALSEG()

If Posicione("VE4",1, xFilial("VE4") + M->VV1_CODMAR , "VE4_SEGMOD" ) == "1" .and. Empty( M->VV1_SEGMOD )
	
	Help("  ",1,"SEGMODNVAL")
	Return( .f. )
	
EndIf

Return( .t. )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様曜様様様用様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � MenuDef   �Autor  �Microsiga          � Data �  03/01/01   艮�
臼麺様様様様謡様様様様様擁様様様溶様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � MENUDEF montagem do aRotina                                艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := {	{ STR0002 ,"AxPesqui", 0 , 1},;		// Pesquisar
					{ STR0003 ,"Vei020V" , 0 , 2},;		// Visualizar
					{ STR0004 ,"Vei020I" , 0 , 3},;		// Incluir
					{ STR0005 ,"Vei020A" , 0 , 4}}		// Alterar
Return aRotina


/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様曜様様様用様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa FS_BuscaVeic � Autor � Vinicius Gati     � Data �  01/11/14   艮�
臼麺様様様様謡様様様様様擁様様様溶様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Pesquisa Avancada do Veiculo (parte do Chassi,...)         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Static Function FS_BuscaVeic()
	Local aRet     := {}
	Local aParamBox:= {}
	DbSelectArea("VV1")
	AADD(aParamBox,{1,STR0013,space(TamSx3("VV1_CHASSI")[1]),"@!",'FG_POSVEI("MV_PAR01",)',"VV1",".t.",80,.t.}) // Identificacao do Veiculo
	ParamBox(aParamBox,STR0005,@aRet,,,,,,,,.f.) // Pesquisa Avan�ada
Return()