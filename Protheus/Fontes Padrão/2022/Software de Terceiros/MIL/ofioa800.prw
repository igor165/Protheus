#include "ofioa800.ch"
#include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ofioa800 � Autor �  Luis Delorme         � Data � 05/11/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Grupo de Componentes Controlados               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOA800

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001)  // Cadastro de Opcionais
Private nUsado := 0
Private aCpoMostra := {"VSX_CODAGM","VSX_DESAGM"}

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

mBrowse( 6, 1,22,75,"VSX")

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OA800Vis � Autor �  Luis Delorme         � Data � 05/11/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza   Grupo de Componentes Controlados               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA800Vis(cAlias,nReg,nOpc)

AxVisual(cAlias,nReg,nOpc,aCpoMostra)

return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OA800    � Autor �  Luis Delorme         � Data � 05/11/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Grupo de Componentes Controlados               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA800(cAlias, nReg, nOpc)

Local bCampo   := { |nCPO| Field(nCPO) } , nCntFor := 0 , _ni := 0 , _lRet := .t.
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private nLenaCols := 0
Private aTELA[0][0],aGETS[0]
Private aCols := {}, aHeader := {} , aCpoEnchoice  := {}
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg

//��������������������������������������������������������������Ŀ
//� Opcoes de acesso para a Modelo 3                             �
//����������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("VSX",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VSX")
While !Eof().and.(x3_arquivo=="VSX")
	If X3USO(x3_usado).and.cNivel >=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Endif
	dbSkip()
End

If !(Inclui)
	DbSelectArea("VSX")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0
dbSelectArea("SX3")
dbSeek("VZZ")
aHeader:={}
aAlter:={}
While !Eof().And.(x3_arquivo=="VZZ")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VZZ_CODAGM])
		nUsado:=nUsado+1
		aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
		IF SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		ENDIF
	Endif
	dbSkip()
End

dbSelectArea("VZZ")
ADHeadRec("VZZ",aHeader)
nUsado :=Len(aHeader)

aCols:={}
dbSelectArea("VZZ")
dbSetOrder(1)
dbSeek(xFilial("VZZ")+M->VSX_CODAGM)

If nOpc == 3 .Or. !Found()
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VZZ"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
Else
	While !eof() .And. VZZ->VZZ_FILIAL == xFilial("VZZ") .and. M->VSX_CODAGM == VZZ->VZZ_CODAGM
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VZZ->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VZZ"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
			
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End
	nLenaCols := Len(aCols)
Endif

If Len(aCols)>0
	
	
	//��������������������������������������������������������������Ŀ
	//� Cria variaveis M->????? da Enchoice                          �
	//����������������������������������������������������������������
	//	RegToMemory("VSO",.t.) // .t. para carregar campos virtuais
	//RegToMemory("VST",.t.) // .t. para carregar campos virtuais
	aCpoEnchVVY := {}
	nOpcE   := nOpc
	nOpcG   := nOpc
	//	aHeader := {}
	//	aCols := {}
	
	//��������������������������������������������������������������Ŀ
	//� Executa a Modelo 3                                           �
	//����������������������������������������������������������������
	cTitulo       :=STR0002   //Cadastro de Opcionais
	cAliasEnchoice:="VSX"
	cAliasGetD    :="VZZ"
	cLinOk        :="FG_OBRIGAT()"
	cTudOk        :="AlwaysTrue()"
	cFieldOk      :="FG_MEMVAR().and. OA800LOK()"
	
	/*   DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5]	of oMainWnd PIXEL   //28
	
	EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1]+006,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	
	oGetDados := MsGetDados():New(89,1,157,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
	*/
	FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchVVY,,@aHeader,@aCols,cFieldOk,cLinOk,,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,,,,,,,,20,aAlter)
	//    FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchVSO,,@aHeadAg,@aColsAg,cFieldOk,cLinOk,,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,cEnchNView,cGetDNView,1,"VST->VST_FILIAL+VST->VST_TIPO+VST->VST_CODIGO"  ,xFilial("VST")+"3"+VSO->VSO_NUMIDE,)
	//       n:= oAuxGetDados:nAt
	//       oAuxGetDados:oBrowse:bChange    := {|| FG_AALTER("VVY",nLenAcols,oAuxGetDados) }
	
	ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg,{|| if(oAuxGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.OA800GRA(nOpc),oAuxDlg:End(),.f.) },{|| oAuxDlg:End() })
	
Endif

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OA800GRA � Autor �  Luis Delorme         � Data � 05/11/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o do Grupo de Componentes Controlados               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA800GRA(nOpc)

Private lMsHelpAuto := .t., lMsFinalAuto := .F.


If !FS_VALGRAOA800( nOpc , .t. )
	MostraErro()
	Return( .f. )
EndIf

Begin Transaction
FS_VALGRAOA800(nOpc)
End Transaction

lMsHelpAuto := .f.

Return( .t. )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OA800GRA � Autor �  Luis Delorme         � Data � 05/11/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o do Grupo de Componentes Controlados               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA800LOK(nOpc)

Private lMsHelpAuto := .t., lMsFinalAuto := .F.

if Readvar() == "M->VZZ_GRUITE"
	M->VZZ_CODITE := space(TamSX3("VZZ_CODITE")[1])
	M->VZZ_DESITE := space(TamSX3("VZZ_CODITE")[1])
	aCols[n,fg_posvar("VZZ_CODITE","aHeader")] := space(TamSX3("VZZ_CODITE")[1])
	aCols[n,fg_posvar("VZZ_DESITE","aHeader")] := space(TamSX3("VZZ_CODITE")[1])
endif


Return( .t. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_VALGRAOA800 � Autor �Emilton           � Data � 27/09/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o do Grupo de Componentes Controlados               ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Veiculos                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_VALGRAOA800( nOpc , lValid )

Local lRet := .t.
Local ix1  := 0 
Local cString

Private lMsHelpAuto := .t.

If TCCanOpen(RetSqlName("VZZ"))
	cString := "DELETE FROM "+RetSqlName("VZZ")+ " WHERE VZZ_FILIAL = '"+ xFilial("VZZ")+"' AND VZZ_CODAGM= '"+M->VSX_CODAGM+"'"
	TCSqlExec(cString)
endif

lValid := If( lValid == NIL , .f. , lValid )

//��������������������������������������������������������������Ŀ
//� Executar processamento                                       �
//����������������������������������������������������������������
If nOpc != 2
	
	dbSelectArea("VSX")
	dbSetOrder(1)
	dbSeek(xFilial("VSX")+M->VSX_CODAGM)
	
	// Grava arquivo Pai
	If Inclui .or. Altera
		//		If !lValid
		RecLock("VSX", !Found() )
		FG_GRAVAR("VSX")
		MsUnlock()
		//		EndIf
	EndIf
	
	
	// Grava arquivo Filho
	For ix1 := 1 to len(oAuxGetDados:aCols)
		
		If ix1 > Len(oAuxGetDados:aCols) // .or. oAuxGetDados:aCols[ix1,Len(oAuxGetDados:aCols[ix1])] .or. Empty(oAuxGetDados:aCols[ix1,FG_POSVAR("VZZ_CODITE")])
			Loop
		Endif
		
		dbselectArea("VZZ")
		dbSetOrder(1)
		dbseek(xFilial("VZZ")+M->VSX_CODAGM+oAuxGetDados:aCols[ix1,FG_POSVAR("VZZ_GRUITE")]+oAuxGetDados:aCols[ix1,FG_POSVAR("VZZ_CODITE")])
		If (Inclui .or. Altera) .And. !oAuxGetDados:aCols[ix1,Len(oAuxGetDados:aCols[ix1])]
			//			If !lValid
			RecLock("VZZ", !Found() )
			FG_GRAVAR("VZZ",oAuxGetDados:aCols,aHeader,ix1)
			VZZ->VZZ_FILIAL := xFilial("VZZ")
			VZZ->VZZ_CODAGM := M->VSX_CODAGM
			MsUnlock()
			//			EndIf
		ElseIf Found()
			// Deleta
			RecLock("VZZ",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VZZ")
		Endif
	Next
	
	// Exclui arquivo Pai
	dbSelectArea("VSX")
	If !(Inclui .Or. Altera) .And. Found()
		// Deleta
		RecLock("VSX",.F.,.T.)
		dbdelete()
		MsUnlock()
		WriteSx2("VSX")
	Endif
	
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OF800CODITE    � Autor �Thiago            � Data � 14/11/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao no campo codigo do item.                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Veiculos                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OF800CODITE()

nPos := Ascan(aCols,{|x| x[FG_POSVAR("VZZ_GRUITE","aHeader")]+x[FG_POSVAR("VZZ_CODITE","aHeader")] == M->VZZ_GRUITE+M->VZZ_CODITE .and. x[len(x)] == .f. })
if nPos > 0 
   MsgStop(STR0008) 
   return(.f.)
Endif
  
Return(.t.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  MenuDef    �Autor  �Emilton             � Data �  28/09/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � MenuDef                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := { { STR0003 ,"axPesqui", 0 , 1},; 	//Pesquisar
{ STR0004 ,"OA800", 0 , 2},; 	//Visualizar
{ STR0005 ,"OA800", 0 , 3},; 	//Incluir
{ STR0006 ,"OA800", 0 , 4},; 	//Alterar
{ STR0007 ,"OA800", 0 , 5}}  	//Excluir

Return aRotina
