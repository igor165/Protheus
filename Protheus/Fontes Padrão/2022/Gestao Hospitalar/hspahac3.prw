#include "HSPAHAC3.CH"
#include "protheus.CH"
#include "topconn.CH"
#include "colors.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Setores de Plant�o                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHAC3()
Private aRotina := {{OemtoAnsi(STR0001), "axPesqui" , 0,1},; //"Pesquisar"
					{OemtoAnsi(STR0002), "HS_AC3"	, 0,2},; //"Visualizar"
					{OemtoAnsi(STR0003), "HS_AC3"	, 0,3},; //"Incluir"
					{OemtoAnsi(STR0004), "HS_AC3"	, 0,4},; //"Alterar"
					{OemtoAnsi(STR0005), "HS_AC3"	, 0,5},; //"Excluir"
					{OemtoAnsi(STR0006), "HS_AC3APO", 0,4} } //"Apontar"


If HS_ExisDic({{"T", "GN3"}}) .and. HS_ExisDic({{"T", "GN4"}})
	DbSelectArea("GN3")
	mBrowse(06, 01, 22, 75, "GN3")
	Return(Nil)
EndIf

/*
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � HS_AC3                                                     ���
���          � Cadastro de Escalas de Plant�o                             ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/*/
Function HS_AC3(cAlias, nReg, nOpc)
Local nOpcA  := 0
Local lOk 			:= .F.
Local nCont		:= 0
Local bCampo	:= {|nCPO| Field(nCPO)}
Local cCadastro:=" "
Local nGDOpc 		:= (GD_INSERT + GD_UPDATE + GD_DELETE)
Local nPosDel		:= 0
Local nIt						:= 0
Local nCpo					:= 0
Local aSize    := {},  aObjects := {},  aInfo, aPObjs

Private oDlg					:= Nil
Private oGetGEF		:= Nil
Private aHeadGEF := {}
Private aColsGEF := {}
Private nUsadGEF := 0
Private nOpcE    := aRotina[nOpc, 4]
Private aTela 			:= {}
Private aGets    := {}
Private aHeader 	:= {}
Private aCols    := {}
Private nUsado   := 0
Private oGN3
Private lGDVazio := .F.

RegToMemory("GN3",(nOpcE == 3)) //Gera variaveis de memoria para o GN3

// n�o permite altera��o em escala com apontamentos
If nOpc==4 .and. HS_CountTB("GN4", "GN4_NRSEQP  = '" + M->GN3_NRSEQP + "'")  > 0
 	HS_MsgInf("Plant�o possui apontamentos, altera��o inv�lida","Valida Altera��o","Plant�o M�dico")
 	Return
EndIf

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Cadastro de Setores de Plant�o") From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd

oGN3 := MsMGet():New("GN3", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGN3:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela)  .And. FS_VldGN3() .And. IIf(nOpcE == 5, FS_ValExcl(), .T.), oDlg:End(), nOpcA == 0)},;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	 Begin Transaction
   FS_GrvAC3(nReg)
	 End Transaction  
  //grava o numero sequencial do plant�o
  While __lSx8
   ConfirmSx8()
  EndDo  
Else
  While __lSx8
   RollBackSx8()
  EndDo     
EndIf
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � HS_AC3APO                                                  ���
���          � Apontamento de Escalas dos Setores de Plant�o              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_AC3APO(cAlias, nReg, nOpc)
Local nOpcA    := 0
Local nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE
Local aSize    := {},  aObjects := {},  aInfo := {}, aPObjs := (), aCpoAlt := {}
Local cCadastro := 'Escala de Plant�o'
Local bFS_Troca  	:= {||FS_Troca(aRotina[nOpc,4],"T")} // Troca M�dico
Local bFS_Falta  	:= {||FS_FltCnc(aRotina[nOpc,4],"F")} // Falta
Local bFS_Cance  	:= {||FS_FltCnc(aRotina[nOpc,4],"C")} // Cancela Escala de Plant�o

Private aButtons    := {} , cIdOpc := " "
Private aTela  := {}, aGets   := {}, nOpcE := 0, nOpcG := 0, pForACols := 0
Private aCGN4	 := {}, aHGN4   := {}, nUGN4 := 0, nLGN4 := 0, oGN4
Private nGN4DATINI := 0, nGN4HORINI := 0, nGN4DATFIN := 0, nGN4HORFIN := 0, nGN4TXTOBS := 0
Private nGN4NRSEQE := 0, nGN4CRM    := 0, nGN4NOMMED := 0,  nGN4STAREG := 0, nGN4NREXTM := 0
Private nGN4PROSUB := 0, nGN4NOMSUB := 0, nGN4OBSERV := 0, nGN4OBSGER := 0, nGN4STATUS := 0
Private lAltera := .T.

//aCposVis := {"GN4_OBSGER", "GN4_PROSUB","GN4_NOMSUB", "GN4_STATUS", "GN4_OBSERV","GN4_NREXTM"}

//Adciona o botao na enchoicebar
Aadd(aButtons	, {'responsa',{||Eval(bFS_Troca)},STR0007, STR0008}) //"Troca M�dico de Plant�o"###"Troca"
Aadd(aButtons	, {'dbg09',{||Eval(bFS_Falta)},STR0009, STR0009}) //"Falta"###"Falta"
Aadd(aButtons	, {'SduDrpTbl',{||Eval(bFS_Cance)},STR0010, STR0011}) //"Cancela Plant�o"###"Cancela"

RegToMemory("GN3", .F.)

Inclui := .F.

HS_BDados("GN4", @aHGN4, @aCGN4, @nUGN4, 1,," GN4.GN4_NRSEQP = '" + M->GN3_NRSEQP + "'",.T.,,,,,,,,,,,,,,,,,,,,)
nGN4STAREG := aScan(aHGN4, {| aVet | aVet[2] == "HSP_STAREG"})
nGN4NRSEQE := aScan(aHGN4, {| aVet | aVet[2] == "GN4_NRSEQE"})
nGN4DATINI := aScan(aHGN4, {| aVet | aVet[2] == "GN4_DATINI"})
nGN4HORINI := aScan(aHGN4, {| aVet | aVet[2] == "GN4_HORINI"})
nGN4DATFIN := aScan(aHGN4, {| aVet | aVet[2] == "GN4_DATFIN"})
nGN4HORFIN := aScan(aHGN4, {| aVet | aVet[2] == "GN4_HORFIN"})
nGN4CRM    := aScan(aHGN4, {| aVet | aVet[2] == "GN4_CODCRM"})
nGN4NOMMED := aScan(aHGN4, {| aVet | aVet[2] == "GN4_NOMMED"})
nGN4PROSUB := aScan(aHGN4, {| aVet | aVet[2] == "GN4_PROSUB"})
nGN4NOMSUB := aScan(aHGN4, {| aVet | aVet[2] == "GN4_NOMSUB"})
nGN4OBSERV := aScan(aHGN4, {| aVet | aVet[2] == "GN4_OBSERV"})
nGN4OBSGER := aScan(aHGN4, {| aVet | aVet[2] == "GN4_OBSGER"})
nGN4STATUS := aScan(aHGN4, {| aVet | aVet[2] == "GN4_STATUS"})
nGN4NREXTM := aScan(aHGN4, {| aVet | aVet[2] == "GN4_NREXTM"}) 

//Ponto de entrada executado antes da abertura da tela
If ExistBlock("HSAC3APT")
	ExecBlock("HSAC3APT",.F.,.F.,Nil)
EndIf

//numeracao sequencial do primeiro detalhe - preencher com zeros a esquerda
If Empty(aCGN4[1, nGN4NRSEQE])
	aCGN4[1, nGN4NRSEQE] := StrZero(1, Len(GN4->GN4_NRSEQE))
EndIf

Inclui := .T.
DbSelectArea("GN3")
nOpcA := 0

aSize    := MsAdvSize(.T.)
AAdd( aObjects, {100, 30, .T., .T. } )
AAdd( aObjects, {100, 70, .T., .T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5]	PIXEL of oMainWnd

EnChoice("GN3",nReg,nOpc,,,,, { aPObj[1,1], aPObj[1,2], aPObj[1,3], aPObj[1,4] },aCpoAlt, 3,,,,,, .F.,,,.T.)

oGN4 := MsNewGetDados():New( aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4], nGDOpc,,,"+GN4_NRSEQE",,,999,,,, oDlg, aHGN4, aCGN4)
oGN4:oBrowse:align := CONTROL_ALIGN_BOTTOM
oGN4:oBrowse:BlDblClick := {|| IIF(nGN4OBSGER > 0, HS_PRECPME(oGN4, nGN4OBSGER, "GN4", "_OBSGER"), .T.)}
//oGN4:oBrowse:bAdd       := {|| HS_GDAtrib(oGN4, {{nGN4StaReg, "BR_VERMELHO"}}, 3)}  
oGN4:cFieldOk           := "HS_GDAtrib(oGN4, {{nGN4StaReg, 'BR_AMARELO', 'BR_VERDE'}}, 4)"
oGN4:oBrowse:bDelete    := {|| Iif(FS_VerDesp("FLTCNC") .And. Empty(oGN4:aCols[oGN4:nAt,nGN4NREXTM]),{HS_GDAtrib(oGN4, {{nGN4StaReg, "BR_CINZA", "BR_VERDE"}}, 5),oGN4:DelLine()},Nil)}
oGn4:oBrowse:bChange    := {|| lAltera:= Empty(oGN4:aCols[oGN4:oBrowse:nAt, nGN4NREXTM])}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1,IIf(oGN4:TudoOk() .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0) } , ;
{|| nOpcA := 0, oDlg:End()},,aButtons)

If nOpcA == 1
	Begin Transaction
	FS_GrvAC3a()
	End Transaction
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � HS_VLDAC3                                                  ���
���          � VALIDA OS CAMPOS DA GN3 E GN4                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VldAC3()
Local lRet    := .T.
Local nForGN4 := 0
Local aArea   := GetArea()
Local cConcat := Iif(TcGetDb() = "MSSQL"," + "," || ")

// valida o setor
If ReadVar() == "M->GN3_CODLOC"
	If !Empty(M->GN3_CODLOC) .And. !(lRet := HS_SeekRet("GCS", "M->GN3_CODLOC", 1, .F.,"GN3_NOMLOC", "GCS_NOMLOC"))
		HS_MsgInf(STR0012, STR0013, STR0014) //"Setor n�o encontrado"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
Endif

If ReadVar() == "M->GN3_HORFIN"            
	//consiste data final
	IF !Empty(M->GN3_DATFIN) .AND. !Empty(M->GN3_HORFIN) .AND. !Empty(M->GN3_HORINI) .AND. DTOS(M->GN3_DATFIN) + M->GN3_HORFIN <= DTOS(M->GN3_DATINI) + M->GN3_HORINI
		HS_MsgInf(STR0015,STR0013,STR0014 ) //"O per�odo final do plant�o � anterior ao per�odo inicial!"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
Endif

If ReadVar() == "M->GN3_DATINI"
	//consiste data final
	IF !Empty(M->GN3_DATFIN) .AND. !Empty(M->GN3_HORFIN) .AND. !Empty(M->GN3_HORINI) .AND. DTOS(M->GN3_DATFIN) + M->GN3_HORFIN <= DTOS(M->GN3_DATINI) + M->GN3_HORINI
		HS_MsgInf(STR0015,STR0013,STR0014 ) //"O per�odo final do plant�o � anterior ao per�odo inicial!"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
EndIf

If ReadVar() == "M->GN3_DATFIN"
	//consiste data final
	IF !Empty(M->GN3_DATFIN) .AND. !Empty(M->GN3_HORFIN) .AND. !Empty(M->GN3_HORINI) .AND. DTOS(M->GN3_DATFIN) + M->GN3_HORFIN <= DTOS(M->GN3_DATINI) + M->GN3_HORINI
		HS_MsgInf(STR0015,STR0013,STR0014 ) //"O per�odo final do plant�o � anterior ao per�odo inicial!"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
EndIf

If ReadVar() == "M->GN3_HORINI"
	//consiste data final
	IF !Empty(M->GN3_DATFIN) .AND. !Empty(M->GN3_HORFIN) .AND. !Empty(M->GN3_HORINI) .AND. DTOS(M->GN3_DATFIN) + M->GN3_HORFIN <= DTOS(M->GN3_DATINI) + M->GN3_HORINI
		HS_MsgInf(STR0015,STR0013,STR0014 ) //"O per�odo final do plant�o � anterior ao per�odo inicial!"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf   
EndIf

// valida o cadastro de m�dicos GBJ
If ReadVar() == "M->GN4_CODCRM"

	// Verifica se o campo deve estar liberado ou travado   
	If HS_CountTB("GN4", "GN4_NRSEQP  = '" + M->GN3_NRSEQP + "' AND GN4_NRSEQE = '" + oGN4:aCols[oGN4:nAt, nGN4NRSEQE] + "'")  > 0
		HS_MsgInf(STR0016, STR0013, STR0014) //"O M�dico n�o pode ser alterado, utilize a fun��o de troca!"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
            
	// Valida existencia
	If !(lRet := HS_SeekRet("SRA", "M->GN4_CODCRM", 11,.F.,"GN4_NOMMED","RA_NOME"))
		HS_MsgInf(STR0017, STR0013, STR0014) //"Profissional n�o encontrado"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf

	// verifica se o m�dico j� possui escala cadastrada para outro setor no per�odo
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
		IF HS_CountTB("GN4", "GN4_CODCRM  = '" + M->GN4_CODCRM + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])+oGN4:aCols[oGN4:nAt, nGN4HORINI]+"' BETWEEN GN4_DATINI "+cConcat+" GN4_HORINI AND GN4_DATFIN "+cConcat+" GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
			HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
			Return(.F.)
		EndIf
	Endif

	// Verifica se possui despesa lancada no periodo do plant�o a ser incluido
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
		If !FS_VerDesp("CRM")                                                                          
			Return(.F.)
		EndIf              
	EndIf

	// verifica se a data n�o sobrepoe um per�odo j� digitado em Escala de Plant�o
	If Len(oGN4:aCols)>1
		For nForGN4 := 1 to Len(oGN4:aCols)
			//consiste data inicial
			IF (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI] >= DTOS(oGN4:aCols[nForGN4, nGN4DATINI]) + oGN4:aCols[nForGN4, nGN4HORINI]) .AND. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI] <= DTOS(oGN4:aCols[nForGN4, nGN4DATFIN]) + oGN4:aCols[nForGN4, nGN4HORFIN]) .AND. oGN4:aCols[nForGN4, nGN4NRSEQE]<>oGN4:aCols[oGN4:nAt, nGN4NRSEQE] .AND. oGN4:aCols[nForGN4, nGN4CRM]=M->GN4_CODCRM  .AND. oGN4:aCols[nForGN4, nGN4STATUS]<>"3"
				HS_MsgInf(STR0019,STR0013,STR0014 ) //"O per�odo digitado j� est� contemplado em Escala anterior para esse M�dico!"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
			//consiste data final
			IF (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] >= DTOS(oGN4:aCols[nForGN4, nGN4DATINI]) + oGN4:aCols[nForGN4, nGN4HORINI]) .AND. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] <= DTOS(oGN4:aCols[nForGN4, nGN4DATFIN]) + oGN4:aCols[nForGN4, nGN4HORFIN])  .AND. oGN4:aCols[nForGN4, nGN4NRSEQE]<>oGN4:aCols[oGN4:nAt, nGN4NRSEQE] .AND. oGN4:aCols[nForGN4, nGN4CRM]=M->GN4_CODCRM .AND. oGN4:aCols[nForGN4, nGN4STATUS]<>"3"
				HS_MsgInf(STR0019,STR0013,STR0014 ) //"O per�odo digitado j� est� contemplado em Escala anterior para esse M�dico!"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		Next
	EndIf
EndIf

// verifica se a data de in�cio est� dentro do per�odo selecionado
If ReadVar() == "M->GN4_DATINI"
	If (M->GN4_DATINI < M->GN3_DATINI) .OR. (M->GN4_DATINI > M->GN3_DATFIN)
		HS_MsgInf(STR0020,STR0013,STR0014 ) //"A data digitada est� fora do per�odo selecionado para esse Local de Atendimento"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] <= DTOS(M->GN4_DATINI)+oGN4:aCols[oGN4:nAt, nGN4HORINI]
		HS_MsgInf(STR0021,STR0013,STR0014 ) //"A Data/Hora final � anterior a Data/Hora inicial"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .AND. DTOS(M->GN4_DATINI) <> DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])
		HS_MsgInf(STR0053,STR0013,STR0014) //"A Data Inicial deve ser igual a Data Final do apontamento"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI])
		If (DTOS(M->GN4_DATINI) + oGN4:aCols[oGN4:nAt, nGN4HORINI] < DTOS(M->GN3_DATINI) + M->GN3_HORINI) .OR. (DTOS(M->GN4_DATINI) + oGN4:aCols[oGN4:nAt, nGN4HORINI] > DTOS(M->GN3_DATFIN) + M->GN3_HORFIN)
			HS_MsgInf(STR0024,STR0013,STR0014 ) //"A Data/Hora digitada est� fora do per�odo selecionado para esse Local de Atendimento"###"Aten��o"###"Cadastro de Plant�o"
			Return(.F.)
		EndIf
	EndIf
	// Verifica se possui despesa lancada no periodo do plant�o a ser incluido
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM])
		If !FS_VerDesp("DATINI")                                                                          
			Return(.F.)
		EndIf              
	EndIf	
	// verifica se o m�dico j� possui escala cadastrada para outro setor no per�odo
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
		If "DB2" $ Upper(TCGETDB())
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(M->GN4_DATINI)+oGN4:aCols[oGN4:nAt, nGN4HORINI]+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])+oGN4:aCols[oGN4:nAt, nGN4HORFIN]+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		Else
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(M->GN4_DATINI)+oGN4:aCols[oGN4:nAt, nGN4HORINI]+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])+oGN4:aCols[oGN4:nAt, nGN4HORFIN]+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		EndIf
	EndIf
EndIf

If ReadVar() == "M->GN4_DATFIN"
	If (M->GN4_DATFIN < oGN4:aCols[oGN4:nAt, nGN4DATINI])
		HS_MsgInf(STR0022,STR0013,STR0014 ) //"A Data Final � anterior a Data Inicial da Escala de Plant�o"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If (M->GN4_DATFIN < M->GN3_DATINI) .OR. (M->GN4_DATFIN > M->GN3_DATFIN)
		HS_MsgInf(STR0020,STR0013,STR0014 ) //"A data digitada est� fora do per�odo selecionado para esse Local de Atendimento"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .AND. DTOS(M->GN4_DATFIN) <> DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])
		HS_MsgInf(STR0054,STR0013,STR0014) //"A Data Final deve ser igual a Data Inicial do apontamento"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
		If Len(DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI])>0 .and. DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] <= DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI]
			HS_MsgInf(STR0021,STR0013,STR0014 ) //"A Data/Hora final � anterior a Data/Hora inicial"###"Aten��o"###"Cadastro de Plant�o"
			Return(.F.)
		EndIf
	EndIf
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN]) 
		If (DTOS(M->GN4_DATFIN) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] < DTOS(M->GN3_DATINI) + M->GN3_HORINI) .OR. (DTOS(M->GN4_DATFIN) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] > DTOS(M->GN3_DATFIN) + M->GN3_HORFIN)
			HS_MsgInf(STR0024,STR0013,STR0014 ) //"A Data/Hora digitada est� fora do per�odo selecionado para esse Local de Atendimento"###"Aten��o"###"Cadastro de Plant�o"
			Return(.F.)
		EndIf
	EndIf
	// Verifica se possui despesa lancada no periodo do plant�o a ser incluido
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM])
		If !FS_VerDesp("DATFIN")                                                                          
			Return(.F.)
		EndIf              
	EndIf	
	// verifica se o m�dico j� possui escala cadastrada para outro setor no per�odo
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
		If "DB2" $ Upper(TCGETDB())
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])+oGN4:aCols[oGN4:nAt, nGN4HORINI]+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(M->GN4_DATFIN)+oGN4:aCols[oGN4:nAt, nGN4HORFIN]+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		Else
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])+oGN4:aCols[oGN4:nAt, nGN4HORINI]+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(M->GN4_DATFIN)+oGN4:aCols[oGN4:nAt, nGN4HORFIN]+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		EndIf
	EndIf
EndIf

If ReadVar() == "M->GN4_HORINI" 
	If !HS_VldHora(M->GN4_HORINI)
		HS_MsgInf(STR0023, STR0013, STR0014) //"Hora inicial inv�lida"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)                                                         
	EndIf		
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN]) .and. DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] <= DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + M->GN4_HORINI
		HS_MsgInf(STR0021,STR0013,STR0014 ) //"A Data/Hora final � anterior a Data/Hora inicial"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + M->GN4_HORINI < DTOS(M->GN3_DATINI) + M->GN3_HORINI) .OR. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + M->GN4_HORINI > DTOS(M->GN3_DATFIN) + M->GN3_HORFIN)
		HS_MsgInf(STR0024,STR0013,STR0014 ) //"A Data/Hora digitada est� fora do per�odo selecionado para esse Local de Atendimento"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	// verifica se a data n�o sobrepoe um per�odo j� digitado em Escala de Plant�o
	If Len(alltrim(oGN4:aCols[oGN4:nAt, nGN4CRM]))>0 //consiste somente se o m�dico foi selecionado
		If Len(oGN4:aCols)>1
			For nForGN4 = 1 to Len(oGN4:aCols)
				IF (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + M->GN4_HORINI >= DTOS(oGN4:aCols[nForGN4, nGN4DATINI]) + oGN4:aCols[nForGN4, nGN4HORINI]) .AND. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + M->GN4_HORINI <= DTOS(oGN4:aCols[nForGN4, nGN4DATFIN]) + oGN4:aCols[nForGN4, nGN4HORFIN]) .AND. oGN4:aCols[nForGN4, nGN4NRSEQE]<>oGN4:aCols[oGN4:nAt, nGN4NRSEQE] .AND. oGN4:aCols[nForGN4, nGN4CRM]=oGN4:aCols[oGN4:nAt, nGN4CRM]  .AND. oGN4:aCols[nForGN4, nGN4STATUS]<>"3"
					HS_MsgInf(STR0019,STR0013,STR0014 ) //"O per�odo digitado j� est� contemplado em Escala anterior para esse M�dico!"###"Aten��o"###"Cadastro de Plant�o"
					Return(.F.)
				EndIf
			Next
		EndIf
	EndIf
	// Verifica se possui despesa lancada no periodo do plant�o a ser incluido
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM])
		If !FS_VerDesp("HORINI")                                                                          
			Return(.F.)
		EndIf
	EndIf	
	// verifica se o m�dico j� possui escala cadastrada para outro setor no per�odo
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
		If "DB2" $ Upper(TCGETDB()) 
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])+M->GN4_HORINI+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])+oGN4:aCols[oGN4:nAt, nGN4HORFIN]+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		Else
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])+M->GN4_HORINI+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])+oGN4:aCols[oGN4:nAt, nGN4HORFIN]+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		EndIf
	EndIf
EndIf

If ReadVar() == "M->GN4_HORFIN"
	If !HS_VldHora(M->GN4_HORFIN)
		HS_MsgInf(STR0025, STR0013, STR0014) //"Hora final inv�lida"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)                                                         
	EndIf		
	If Len(DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI])>0 .and. DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + M->GN4_HORFIN <= DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI]
		HS_MsgInf(STR0021,STR0013,STR0014 ) //"A Data/Hora final � anterior a Data/Hora inicial"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	If (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + M->GN4_HORFIN < DTOS(M->GN3_DATINI)+M->GN3_HORINI) .OR. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])+M->GN4_HORFIN > DTOS(M->GN3_DATFIN)+M->GN3_HORFIN)
		HS_MsgInf(STR0024,STR0013,STR0014 ) //"A Data/Hora digitada est� fora do per�odo selecionado para esse Local de Atendimento"###"Aten��o"###"Cadastro de Plant�o"
		Return(.F.)
	EndIf
	// verifica se a data n�o sobrepoe um per�odo j� digitado em Escala de Plant�o
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM]) //consiste somente se o m�dico foi selecionado
		If Len(oGN4:aCols)>1
			For nForGN4 = 1 to Len(oGN4:aCols)
 				IF (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + M->GN4_HORFIN >= DTOS(oGN4:aCols[nForGN4, nGN4DATINI]) + oGN4:aCols[nForGN4, nGN4HORINI]) .AND. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + M->GN4_HORFIN <= DTOS(oGN4:aCols[nForGN4, nGN4DATFIN]) + oGN4:aCols[nForGN4, nGN4HORFIN])  .AND. oGN4:aCols[nForGN4, nGN4NRSEQE]<>oGN4:aCols[oGN4:nAt, nGN4NRSEQE] .AND. oGN4:aCols[nForGN4, nGN4CRM]=oGN4:aCols[oGN4:nAt, nGN4CRM]  .AND. oGN4:aCols[nForGN4, nGN4STATUS]<>"3"
 					HS_MsgInf(STR0019,STR0013,STR0014 ) //"O per�odo digitado j� est� contemplado em Escala anterior para esse M�dico!"###"Aten��o"###"Cadastro de Plant�o"
 					Return(.F.)
 				EndIf
 			Next
	 	EndIf
	EndIf
	// Verifica se possui despesa lancada no periodo do plant�o a ser incluido
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM])
		If !FS_VerDesp("HORFIN")                                                                          
			Return(.F.)
		EndIf              
	EndIf
	// verifica se o m�dico j� possui escala cadastrada para outro setor no per�odo
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4CRM]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI])
		If "DB2" $ Upper(TCGETDB())
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])+oGN4:aCols[oGN4:nAt, nGN4HORINI]+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])+M->GN4_HORFIN+"' BETWEEN GN4_DATINI || GN4_HORINI AND GN4_DATFIN || GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		Else
			IF HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])+oGN4:aCols[oGN4:nAt, nGN4HORINI]+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0 .or.  HS_CountTB("GN4", "GN4_CODCRM  = '" + oGN4:aCols[oGN4:nAt, nGN4CRM] + "' AND '" +DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])+M->GN4_HORFIN+"' BETWEEN GN4_DATINI+GN4_HORINI AND GN4_DATFIN+GN4_HORFIN AND GN4_NRSEQP <> '"+M->GN3_NRSEQP+"'")  > 0
				HS_MsgInf(STR0018, STR0013, STR0014) //"Profissional j� est� cadastrado em outro plant�o nesse per�odo"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		EndIf
	EndIf
EndIf             

// valida Gera Valor
If ReadVar() == "M->GN4_GERVAL"
	// Verifica se possui despesa lancada no periodo do plant�o a ser incluido
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
		If !FS_VerDesp("")                                                                          
			Return(.F.)
		EndIf              
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_GRVAC3                                                  ���
���          � Valida datas para n�o haver sobreposi��o e grava os dados  ���
���          � da GN3                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvAC3(nReg)
Local lRet := .T.

DbSelectArea("GN3")
If nOpcE <> 3
	DbGoTo(nReg)
EndIf

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
 RecLock("GN3", (nOpcE == 3))
 HS_GrvCpo("GN3")
 MsUnlock()
EndIf

Return(lRet)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_VLDGN3                                                  ���
���          � Valida os registros da GN3                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_VldGN3()
Local   lRet  := .T.
Local   cSql  := ""
Local cConcat := Iif(TcGetDb() = "MSSQL"," + "," || ")
Local aArea   := GetArea()

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	
	// valida datas para n�o haver sobreposi��o
	cSql := " SELECT COUNT(*) TOTREG FROM "+ RetSqlName("GN3") + " GN3 "
	cSql += " WHERE GN3.GN3_NRSEQP<>'"+M->GN3_NRSEQP+"' AND GN3.GN3_CODLOC='"+M->GN3_CODLOC+"' AND ('"+DTOS(M->GN3_DATINI)+"'"+cConcat+"'"+M->GN3_HORINI  +"'  BETWEEN (GN3.GN3_DATINI"+cConcat+" GN3.GN3_HORINI) AND  (GN3.GN3_DATFIN"+cConcat+" GN3.GN3_HORFIN)
	cSql += " OR '"+DTOS(M->GN3_DATFIN)+"'"+cConcat+"'"+M->GN3_HORFIN  +"'  BETWEEN (GN3.GN3_DATINI"+cConcat+" GN3.GN3_HORINI) AND  (GN3.GN3_DATFIN"+cConcat+" GN3.GN3_HORFIN))
	cSql += " AND GN3.GN3_FILIAL = '" + xFilial("GN3") + "' AND GN3.D_E_L_E_T_ <> '*' "
	cSql := ChangeQuery(cSql)

	TCQUERY cSQL NEW ALIAS "QRY"
	DbSelectArea("QRY")
	DbGoTop()
	If  QRY->TOTREG >0
		HS_MsgInf(STR0026, STR0027, STR0028) //"Existe Escala de Plant�o cadastrada para esse per�odo!"###"Atencao"###"Inclusao nao permitida"
 	lRet := .F.
 EndIf  
	QRY->(DbCloseArea())
EndIf
RestArea(aArea)
Return(lRet) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_GRVAC3A                                                 ���
���          � Grava os registros da GN4 (matriz)                         ���
���          � OBS: N�o foi usado o GRVCPO devido ao campo GN4_OBSGER     ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvAC3a()
Local   cAlias    := "GN4"
Local   nOrd      := 1
Local   cChave    := ""
Local   cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local   cAliasOld := Alias(), lAchou := .F.
Local   nItem := 0, nix
Private pForaCols := 0 , cTeste := ""

For nItem := 1 To Len(oGN4:aCols)
 If oGN4:aCols[nItem, nGN4StaReg] <> "BR_VERDE"
	 pForaCols := nItem
	 DbSelectArea(cAlias)
	 DbSetOrder(nOrd)
	 lAchou := DbSeek(xFilial(cAlias) + M->GN3_NRSEQP + oGN4:aCols[nItem, nGN4NRSEQE] )
	 If ((!Inclui .And. !Altera) .Or. oGN4:aCols[nItem, Len(oGN4:aCols[nItem])]) .And. lAchou /* exclusao */
	 	RecLock(cAlias, .F., .T.)
	 	DbDelete()
	 	MsUnlock()
	 	WriteSx2(cAlias)
	 Else
		 If Inclui .Or. Altera
		 	If !oGN4:aCols[nItem, Len(oGN4:aCols[nItem])]
		 		RecLock(cAlias, !lAchou)
			 	// Grava todos os campos exceto os campos tipo MEMO
			 	For nIx := 1 to Len(oGN4:aHeader)
				 	DbSelectArea("SX3")
				 	DbSetOrder(2)
				 	DbSeek(oGN4:aHeader[nix,2])
				 	DbSelectArea(cAlias)
				 	If (alltrim(oGN4:aHeader[nix,2]) <> "HSP_STAREG") .and. (SX3->X3_TIPO != "M" .AND. SX3->X3_CONTEXT != "V")
				 		&(cAlias + "->" + oGN4:aHeader[nix,2]) := oGN4:aCols[nItem,nix]
				 	EndIf
				 Next
				
				 // Grava outras informa��es
				 &(cPref + "_FILIAL") := xFilial(cAlias)
				 &(cPref + "_NRSEQP") := M->GN3_NRSEQP
				 &(cPref + "_CODLOC") := M->GN3_CODLOC
				 If !Empty(Alltrim(oGN4:aCols[nItem,nGN4OBSERV])) // S� grava se tiver dados
				 	If oGN4:aCols[nItem,nGN4STATUS]=="1"
				 		&(cPref + "_OBSGER") := &(cPref + "_OBSGER")  + STR0029 +DTOC(Date()) +"-"+ Time() +STR0030+ cUserName + " : " + oGN4:aCols[nItem,nGN4OBSERV] + CHR(13)+CHR(10) //"Troca efetuada em "###"h por "
				 	EndIf
				 	If oGN4:aCols[nItem,nGN4STATUS]=="2"
				 		&(cPref + "_OBSGER") := &(cPref + "_OBSGER") + STR0031 +DTOC(Date()) +"-"+ Time() +STR0030+ cUserName + " : " + oGN4:aCols[nItem,nGN4OBSERV] + CHR(13)+CHR(10) //"Falta apontada em "###"h por "
				 	EndIf
				 	If oGN4:aCols[nItem,nGN4STATUS]=="3"
				 		&(cPref + "_OBSGER") := &(cPref + "_OBSGER") + STR0032 +DTOC(Date()) +"-"+ Time() +STR0030+ cUserName + " : " + oGN4:aCols[nItem,nGN4OBSERV] + CHR(13)+CHR(10) //"Cancelamento em "###"h por "
				 	EndIf
				 EndIf
				 MsUnlock()
			 EndIf
		 EndIf
	 EndIf
 EndIf
Next

DbSelectArea(cAliasOld)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_TROCA                                                   ���
���          � Habilita entrada de dados para a troca do Plant�o          ���
���          � Somente para status=0                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_Troca(nOpc,cIdOpc)
Private oCodCRM, oNOMCRM, cNomCRM, oMotiv
Private cMotivo:=SPACE(LEN(oGN4:aCols[oGN4:nAt,nGN4OBSERV]))
Private cCodCRM:=SPACE(LEN(GN4->GN4_CODCRM))
Private nGDX_NREXTM  := 0
Private nGDX_TIPLAN  := 0
Private nGDX_VALLAN  := 0
Private oDlGdx

// n�o permite apontamento qdo plant�o j� foi pago
If oGN4:aCols[oGN4:nAt, nGN4StaReg] <> "BR_VERDE"
	HS_MsgInf(STR0033, STR0013, STR0014) //"Troca inv�lida para plant�o alterado/exclu�do. Confirme ou cancele a opera��o anterior para habilitar essa fun��o."###"Aten��o"###"Cadastro de Plant�o"
	Return()
EndIf

DbSelectArea("GN4")
DbSetOrder(1)
DbGotop()
IF DbSeek(xFilial("GN4") + GN3->GN3_NRSEQP + oGN4:aCols[oGN4:nAt,nGN4NRSEQE])
	If oGN4:aCols[oGN4:nAt,nGN4STATUS] == '0' .and. Empty(oGN4:aCols[oGN4:nAt,nGN4NREXTM])
		
		DEFINE MSDIALOG oDlGdx TITLE OemToAnsi(STR0034) From 007,000 to 017,047	of oMainWnd //"Troca de Plant�o"
		
		@ 015, 004 SAY OemToAnsi(STR0035) OF oDlGdx PIXEL COLOR CLR_BLUE //"M�dico Substituto"
		@ 025, 004 MSGET oCodCRM VAR cCodCRM PICTURE "@!" F3 "MED" VALID FS_VLDCRM(cCodCRM) SIZE 26,8  OF oDlGdx PIXEL COLOR CLR_BLACK
		@ 025, 037 MSGET oNOMCRM VAR cNomCRM PICTURE "@!" SIZE 140,8 OF oDlGdx PIXEL COLOR CLR_BLACK When .F.
		@ 045, 004 Say OemToAnsi(STR0036) Size 20, 00 PIXEL COLOR CLR_BLUE OF oDlGdx //"Motivo" //"Motivo"
		@ 055, 004 MSGet oMotiv Var cMotivo Picture "@!" Valid !Empty(cMotivo) Size 180,8 PIXEL OF oDlGdx
		
		ACTIVATE MSDIALOG oDlGdx CENTERED ON INIT EnchoiceBar(oDlGdx, {|| nOpcA := 1,Iif(Fs_vldTrc(),Fs_atuGN4(cIdOpc),.F.)}, {|| nOpcA := 0, oDlGdx:End()})

	Else
		nOpcA := 0
		HS_MsgInf(STR0037, STR0013, STR0014) //"Op��o desabilitada para esta escala de plant�o"###"Aten��o"###"Cadastro de Plant�o"
	EndIf
EndIf
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_FLTCNC                                                  ���
���          � Habilita entrada de motivo para Falta e Cancelamento       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_FltCnc(nOpc,cIdOpc)
Local cTitTela := ''
Private oCodCRM, oNOMCRM, cNomCRM, oMotiv, aArea
Private cMotivo:=SPACE(LEN(oGN4:aCols[oGN4:nAt,nGN4OBSERV]))
Private nGDX_NREXTM  := 0
Private nGDX_TIPLAN  := 0
Private nGDX_VALLAN  := 0
Private oDlGdx

// n�o permite apontamento qdo plant�o j� foi pago
If oGN4:aCols[oGN4:nAt, nGN4StaReg] <> "BR_VERDE"
	HS_MsgInf(STR0038, STR0013, STR0014) //"Falta/Cancelamento inv�lido para plant�o alterado/exclu�do. Confirme ou cancele a opera��o anterior para habilitar essa fun��o."###"Aten��o"###"Cadastro de Plant�o"
	Return()
EndIf

// n�o permite apontamento qdo plant�o j� foi pago
If !Empty(oGN4:aCols[oGN4:nAt,nGN4NREXTM])
	HS_MsgInf(STR0039, STR0013, STR0014) //"Falta/Cancelamento inv�lido para esta escala de plant�o. Emiss�o de extrato do Profissional j� efetuada."###"Aten��o"###"Cadastro de Plant�o"
	Return()
EndIf

// n�o permite falta p/ status 2 ou 3
If (oGN4:aCols[oGN4:nAt,nGN4STATUS] == "2" .or. oGN4:aCols[oGN4:nAt,nGN4STATUS] == "3") .and. cIdOpc=="F"
	nOpcA := 0
	HS_MsgInf(STR0040, STR0013, STR0014) //"Falta n�o pode ser apontada para esta escala de plant�o"###"Aten��o"###"Cadastro de Plant�o"
	Return()
EndIf

// n�o permite cancelamento para status 2
If oGN4:aCols[oGN4:nAt,nGN4STATUS] == "3"  .and. cIdOpc=="C"
	nOpcA := 0
	HS_MsgInf(STR0041, STR0013, STR0014) //"Cancelamento inv�lido para esta escala de plant�o"###"Aten��o"###"Cadastro de Plant�o"
	Return()
EndIf

	// Verifica se possui despesa lancada no periodo do plant�o a ser incluido
	If !Empty(oGN4:aCols[oGN4:nAt, nGN4DATINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORINI]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) .and. !Empty(oGN4:aCols[oGN4:nAt, nGN4HORFIN])
	  If !FS_VerDesp("FLTCNC")                                                                          
   	Return(.F.)            
	  EndIf
 EndIf	


IIf (cIdOpc=="F",cTitTela:=STR0042,cTitTela:=STR0043) //"Falta em Plant�o"###"Cancelamento de Plant�o"

DbSelectArea("GN4")
DbSetOrder(1)
DbGotop()
IF DbSeek(xFilial("GN4") + GN3->GN3_NRSEQP + oGN4:aCols[oGN4:nAt,nGN4NRSEQE])

	DEFINE MSDIALOG oDlGdx TITLE OemToAnsi(cTitTela) From 007,000 to 015,047	of oMainWnd
	
	@ 025, 004 Say OemToAnsi(STR0036) Size 20, 00 PIXEL COLOR CLR_BLUE OF oDlGdx //"Motivo" //"Motivo"
	@ 035, 004 MSGet oMotiv Var cMotivo Picture "@!" Valid !Empty(cMotivo) Size 180,8 PIXEL OF oDlGdx
	
	ACTIVATE MSDIALOG oDlGdx CENTERED ON INIT EnchoiceBar(oDlGdx, {|| nOpcA := 1, Fs_atuGN4(cIdOpc)}, {|| nOpcA := 0, oDlGdx:End()})
	nOpcA := 0
	
EndIf
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_ATUGN4                                                  ���
���          � Atualiza os campos na linha qdo for Troca / Falta / Cance- ���
���          � lamento                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fs_atuGN4(cIdOpc)

if nOpcA == 1
	DbSelectArea("GN4")
	RecLock("GN4", .F.)
	If cIdOpc == "T"    // atualiza campos somente para troca
		oGN4:aCols[oGN4:nAt,nGN4CRM]    := cCodCRM
		HS_SeekRet("SRA", "cCodCRM",11,.F.,"oGN4:aCols[oGN4:nAt,nGN4NOMMED]","RA_NOME")
		oGN4:aCols[oGN4:nAt,nGN4OBSERV] := cMotivo
		oGN4:aCols[oGN4:nAt,nGN4STATUS] := "1"
	EndIf
	If cIdOpc == "F"
		oGN4:aCols[oGN4:nAt,nGN4OBSERV] := cMotivo
		oGN4:aCols[oGN4:nAt,nGN4STATUS] := "2"
	EndIf
	If cIdOpc == "C"
		oGN4:aCols[oGN4:nAt,nGN4OBSERV] := cMotivo
		oGN4:aCols[oGN4:nAt,nGN4STATUS] := "3"
	EndIf
	oGN4:aCols[oGN4:nAt, nGN4StaReg] := "BR_AMARELO"
	MsUnlock()
	oDlGdx:End()
EndIf
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_VLDCRM                                                  ���
���          � Valida se o m�dico escolhido na troca � v�lido             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_VLDCRM(cCodCRM, nOk, oTran)
Local lRet := .T.


If cCodCRM == oGN4:aCols[oGN4:nAt,nGN4PROSUB]
	HS_MsgInf(STR0044,STR0045,STR0046) //"Troca inv�lida! M�dico identico ao anterior."###"Valida Troca"###"Plant�o M�dico"
	lRet := .F.
EndIf
If !HS_SeekRet("SRA","cCodCRM",11,.F.)
	HS_MsgInf(STR0047,STR0045,STR0046) //"M�dico Inv�lido"###"Valida Troca"###"Plant�o M�dico"
	lRet := .F.
Else
	cNomCRM := SRA->RA_NOME
	cCodCRM := SRA->RA_CODIGO
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_VldTrc                                                  ���
���          � Verifica se possui escala de plant�o para o Setor na troca ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_VldTrc()
Local lRet	 := .T.
Local nForGN4 
  
 // n�o permite apontamento qdo plant�o j� foi pago
 If !Empty(oGN4:aCols[oGN4:nAt,nGN4NREXTM])
 	HS_MsgInf(STR0048, STR0013, STR0014) //"Troca inv�lida para esta escala de plant�o. Emiss�o de extrato do Profissional j� efetuada."###"Aten��o"###"Cadastro de Plant�o"
 	Return()
 EndIf

	// verifica se a data n�o sobrepoe um per�odo j� digitado em Escala de Plant�o
	If Len(oGN4:aCols)>1
		For nForGN4 = 1 to Len(oGN4:aCols)
   //consiste data inicial
			IF (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI] >= DTOS(oGN4:aCols[nForGN4, nGN4DATINI]) + oGN4:aCols[nForGN4, nGN4HORINI]) .AND. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI]) + oGN4:aCols[oGN4:nAt, nGN4HORINI] <= DTOS(oGN4:aCols[nForGN4, nGN4DATFIN]) + oGN4:aCols[nForGN4, nGN4HORFIN]) .AND. oGN4:aCols[nForGN4, nGN4NRSEQE]<>oGN4:aCols[oGN4:nAt, nGN4NRSEQE] .AND. oGN4:aCols[nForGN4, nGN4CRM]= cCodCRM .AND. oGN4:aCols[nForGN4, nGN4STATUS]<>"3"
				HS_MsgInf(STR0019,STR0013,STR0014 ) //"O per�odo digitado j� est� contemplado em Escala anterior para esse M�dico!"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
   //consiste data final
   IF (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] >= DTOS(oGN4:aCols[nForGN4, nGN4DATINI]) + oGN4:aCols[nForGN4, nGN4HORINI]) .AND. (DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN]) + oGN4:aCols[oGN4:nAt, nGN4HORFIN] <= DTOS(oGN4:aCols[nForGN4, nGN4DATFIN]) + oGN4:aCols[nForGN4, nGN4HORFIN])  .AND. oGN4:aCols[nForGN4, nGN4NRSEQE]<>oGN4:aCols[oGN4:nAt, nGN4NRSEQE] .AND. oGN4:aCols[nForGN4, nGN4CRM]=cCodCRM .AND. oGN4:aCols[nForGN4, nGN4STATUS]<>"3"
				HS_MsgInf(STR0019,STR0013,STR0014 ) //"O per�odo digitado j� est� contemplado em Escala anterior para esse M�dico!"###"Aten��o"###"Cadastro de Plant�o"
				Return(.F.)
			EndIf
		Next
	EndIf 
	
If lRet == .T.
	oGN4:aCols[oGN4:nAt,nGN4PROSUB] := oGN4:aCols[oGN4:nAt,nGN4CRM]
	oGN4:aCols[oGN4:nAt,nGN4NOMSUB] := oGN4:aCols[oGN4:nAt,nGN4NOMMED]
EndIf                   

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_VALEXECL                                                ���
���          � Verifica se possui escala de plant�o para o Setor          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ValExcl()
Local lRet	 := .T.
Local aArea      := GetArea()

If nOpcE == 5 //Exclusao
	//verifica se n�o possui escala para esse setor
	cSql := "SELECT COUNT(*) AS Reg"
	cSql += " FROM "
	cSql += " " + RetSqlName("GN4") + " GN4"
	cSql += " WHERE GN4.GN4_FILIAL = '"+ xFilial("GN4") +"' AND ""
	cSql += " GN4.GN4_NRSEQP = '" + Trim(M->GN3_NRSEQP) + "' AND GN4.D_E_L_E_T_ <> '*'"
	cSql := ChangeQuery(cSql)
	
	TCQUERY cSql NEW ALIAS "TMPPLA"
	DbSelectArea("TMPPLA")
	DbGotop()
	If TMPPLA->Reg > 0
		HS_MsgInf(STR0049, STR0013, STR0050)//"Existe Escala de Plant�o cadastrada para esse Local de Atendimento. Impossivel Exclui-lo!"###"Aten��o"###"Exclusao nao permitida"
		lRet := .F.
	Else
		RecLock("GN3", .F.)
		DbDelete()
		MsUnlock()
	EndIf
	DbSelectArea("TMPPLA")
	DbCloseArea()
EndIf
RestArea(aArea)
Return(lRet)            



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � FS_VERDESP                                                 ���
���          � Verifica se possui despesa lan�ada dentro do Plant�o       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_VerDesp(cCpoMem)
Local lRet	 := .T.
Local aArea      := GetArea()
Local cConcat := Iif(TcGetDb() = "MSSQL"," + "," || ")
Local cCRM, cDATINI, cHORINI, cDATFIN, cHORFIN
           
If cCpoMem="CRM"
 cCRM := M->GN4_CODCRM
Else 
 cCRM := oGN4:aCols[oGN4:nAt, nGN4CRM]
EndIf
If cCpoMem="TRCCRM"
 cCRM := cCodCRM
EndIf   
If cCpoMem="FLTCNC"
 cCRM := oGN4:aCols[oGN4:nAt, nGN4CRM]
EndIf
If cCpoMem="DATINI"
 cDATINI := DTOS(M->GN4_DATINI)
Else 
 cDATINI := DTOS(oGN4:aCols[oGN4:nAt, nGN4DATINI])
EndIf   
If cCpoMem="DATFIN"
 cDATFIN := DTOS(M->GN4_DATFIN)
Else 
 cDATFIN := DTOS(oGN4:aCols[oGN4:nAt, nGN4DATFIN])
EndIf   
If cCpoMem="HORINI"
 cHORINI := M->GN4_HORINI
Else 
 cHORINI := oGN4:aCols[oGN4:nAt, nGN4HORINI]
EndIf   
If cCpoMem="HORFIN"
 cHORFIN := M->GN4_HORFIN
Else 
 cHORFIN := oGN4:aCols[oGN4:nAt, nGN4HORFIN]
EndIf   

	 cSql := "SELECT GD7.GD7_CODCRM AS Reg"
 	cSql += " FROM "
 	cSql += " " + RetSqlName("GD7") + " GD7"
 	cSql += " WHERE GD7.GD7_CODLOC='"+GN3->GN3_CODLOC+"'"  
 	cSql += " AND GD7.GD7_DATDES"+cConcat+"GD7.GD7_HORDES "
 	cSql += " BETWEEN '"+cDATINI+cHORINI+"' AND '"+cDATFIN+cHORFIN+"'"
 	cSql += " AND GD7.GD7_CODCRM='"+cCRM+"' AND GD7.GD7_FILIAL = '"+ xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
 	cSql += " UNION "
	 cSql += " SELECT GE7.GE7_CODCRM AS Reg"
 	cSql += " FROM "
 	cSql += " " + RetSqlName("GE7") + " GE7"
 	cSql += " WHERE GE7.GE7_CODLOC='"+GN3->GN3_CODLOC+"'"   
 	cSql += " AND GE7.GE7_DATDES"+cConcat+"GE7.GE7_HORDES "
 	cSql += " BETWEEN ('"+cDATINI+cHORINI+"') AND  ('"+cDATFIN+cHORFIN+"')"
 	cSql += " AND GE7.GE7_CODCRM='"+cCRM+"' AND GE7.GE7_FILIAL = '"+ xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "

 	cSql := ChangeQuery(cSql)
	 TCQUERY cSql NEW ALIAS "TMPPLA"
 	DbSelectArea("TMPPLA")
	 DbGotop()
 	If !TMPPLA->(Eof())   
	 	 	HS_MsgInf(STR0051, STR0013, STR0052)//"Existe Despesa lan�ada para este Profissional no per�odo digitado. Opera��o inv�lida!"###"Aten��o"###"Opera��o nao permitida"
		   lRet := .F.
 	EndIf
 DbCloseArea()  
RestArea(aArea)
Return(lRet)       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC3  � Autor � Monica Y Miyamoto  � Data �  25/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � HS_VERPLA                                                  ���
���          � Verifica se possui escala de plant�o para o Setor          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VerPla(cCRM,cCodLoc,cDatIni,cHorIni)
 Local aRet	    := {.F., ""}
 Local aArea    := GetArea()
 Local cConcat := Iif(TcGetDb() = "MSSQL"," + "," || ") 
//Local cCRM, cCodLoc, cDatIni, cHorIni

	//verifica se possui escala para esse setor
	cSql := "SELECT COUNT(*) AS Reg"
	If HS_ExisDic({{"C", "GN4_GERVAL"}}, .F.) 
	 cSQL +=" , GN4.GN4_GERVAL GERVAL"                                                   
	EndIf 
	cSql += " FROM " + RetSqlName("GN4") + " GN4 "
	cSql += " JOIN " + RetSqlName("GN3") + " GN3 ON GN3.GN3_FILIAL = '"+ xFilial("GN3") +"' AND GN3.GN3_NRSEQP = GN4.GN4_NRSEQP AND GN3.GN3_CODLOC = '"+cCodLoc+"' AND GN3.D_E_L_E_T_ <> '*'"
	cSql += " WHERE GN4.GN4_FILIAL = '"+ xFilial("GN4") +"'"
	cSql += "   AND GN4.GN4_STATUS IN ('0','1') "
	cSql += "   AND GN4.GN4_CODCRM  = '" + cCRM + "'"
	cSql += "   AND '" + DToS(cDATINI) + cHORINI + "' BETWEEN GN4.GN4_DATINI" + cConcat + "GN4.GN4_HORINI  AND GN4.GN4_DATFIN" + cConcat + "GN4.GN4_HORFIN "
	cSql += "   AND GN4.D_E_L_E_T_ <> '*'"
	If HS_ExisDic({{"C", "GN4_GERVAL"}}, .F.) 
	 cSQL +=" GROUP BY GN4_GERVAL"                                                   
	EndIf 
	cSql := ChangeQuery(cSql)
	
	TCQUERY cSql NEW ALIAS "QRYPLA"
	DbSelectArea("QRYPLA")
	DbGotop()
	If QRYPLA->Reg > 0
		aRet[1] := .T.
	EndIf

	If HS_ExisDic({{"C", "GN4_GERVAL"}}, .F.) 
		aRet[2] := QRYPLA->GERVAL
	EndIf 
	
	DbSelectArea("QRYPLA")
	DbCloseArea()
RestArea(aArea)
Return(aRet)

