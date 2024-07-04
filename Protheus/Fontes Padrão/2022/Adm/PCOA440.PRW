#INCLUDE "PCOA440.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤยยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOA440  ณ AUTOR ณ Joใo Gon็alves Oliveira ณ DATA ณ 08.11.2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa para cadastramento de regras de movimentos            ณฑฑ 
ฑฑณ          ณ relacionados                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOA440                                                        ณฑฑ
ฑฑณ_DESCRI_  ณ Programa para cadastramento de movimentos relacionados         ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal      ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o       ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina       ณฑฑ
ฑฑณ          ณ selecionada.                                                   ณฑฑ
ฑฑณ          ณ Exemplo: PCOA440(2) - Executa a chamada da funcao de visua-    ณฑฑ
ฑฑณ          ณ                        zacao da rotina.                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA440(nCallOpcx,lAuto,aCposVs,aRecnos,lProc)
Local lRet      := .T.
Local xOldInt
Local lOldAuto
Local cFiltro

Default lAuto := .F.
Default lProc := .F.

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif
EndIf

Private aCposVisual	:= aCposVs
Private cCadastro	:= STR0001 //"Manuten็ใo de Regras de Receitas Relacionadas"
Private aRotina := MenuDef()

dbSelectArea("AM5")
dbSetOrder(1)
If nCallOpcx <> Nil
	lRet := A440DLG("AM5",AM5->(RecNo()),nCallOpcx,lAuto,aRecnos,lProc)
Else

	cFiltro	:= PcoFilConf("AM5",.T.,.T.,.T.)
	
	If !Empty(cFiltro)

		MBrowse(6,1,22,75,"AM5",,,,,,,,,,,,,,cFiltro)

	EndIf
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA440DLG   บAutor  ณJoใo Gon็alves Oliveira บ Data ณ 07.11.2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visualiza็ใo บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus10                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A440DLG(cAlias,nRecnoAM5,nCallOpcx,lAuto,aRecnos,lProc)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {}
Local aUsButtons := {}
Local oEnchALR
Local aCposNot,aCposEnch

Local aHeadALP
Local aColsALP
Local nLenAM5   := 0  // Numero de campos em uso no AM5
Local nLinALP   := 0  // Linha atual do acols
Local aRecALP   := {} // Recnos dos registros
Local nGetD
Local cRegra

Local aCposAuto 
Local aUsField
Local aAreaAM5 := AM5->(GetArea()) // Salva Area do AM5 
Local aAreaALP := ALP->(GetArea()) // Salva Area do ALP
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local nPosRelac
Local nPosIDRef
Local nPosIdent
Local nPosUM
Local lOk := .F.
Local nX
Local aId_ALP, nPos_Id, nRegAux

If ValType(lAuto) != "L"
	lAuto := .F.
EndIf

aCposNot	:= {} 
aCposEnch	:= {}

Private INCLUI  := (nCallOpcx = 3 .OR. nCallOpcx == 6)
Private oGdALP
PRIVATE aTELA[0][0],aGETS[0]

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif
EndIf

If lAuto .And. !(nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .F.
EndIf

If nCallOpcx == 4
	If aRecnos != NIL .And. ! Empty(aRecnos)
		nRegAux := ALP->(Recno())
		aId_ALP := {}
		For nX := 1 TO Len(aRecnos)
			dbSelectArea("ALP")
			dbGoto(aRecnos[nX])
			If (nPos_Id	:=	ASCAN(aId_ALP, {|x| x[1] == ALP->ALP_ID}))==0
				aAdd(aId_ALP, {ALP->ALP_ID,{aRecnos[nX]}})
			Else
				AAdd(aId_ALP[nPos_Id][2],aRecnos[nX])
			EndIf
		Next
		dbGoto(nRegAux)
	EndIf
EndIf

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 480,650 PIXEL //"Manuten็ใo das Regras de Movimentos Relacionados"
	oDlg:lMaximized := .T.
EndIf

aCposAuto := {} 

// Carrega dados do AM5 para memoria
RegToMemory("AM5",INCLUI)
//M->AM5_codigo := IIf(nCallOpcx == 6,GetSXENum("AM5","AM5_CODIGO"),M->AM5_codigo)

If !lAuto
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Enchoice com os dados do cabe็alho                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If (nCallOpcx <> 3 .AND. nCallOpcx <> 6)
		aEnchAuto	:= GetAheader("AM5")
		aEval( aEnchAuto , {|x| aAdd(aCposEnch , x[2] )})
  		oEnchAM5 := MSMGet():New('AM5',,nCallOpcx,,,,aCposEnch,{0,0,46,23},,,,,,oDlg,,,,,,,,,)
	Else
		oEnchAM5 := MSMGet():New('AM5',,nCallOpcx,,,,/*aCposEnch*/,{0,0,46,23},,,,,,oDlg,,,,,,,,,)
		aEnchAuto := GetaHeader("AM5")
	EndIf
	oEnchAM5:oBox:Align := CONTROL_ALIGN_TOP
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader do ALP                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadALP := GetaHeader("ALP",,{"ALP_CODIGO","ALP_DESCR"},,aCposVisual, .T. /*lWalk_Thru*/)

nLenALP  := Len(aHeadALP) + 1

nPosRelac 	:= AScan(aHeadALP,{|x| Upper(AllTrim(x[2])) == "ALP_TIPO"})
nPosIDRef 	:= AScan(aHeadALP,{|x| Upper(AllTrim(x[2])) == "ALP_IDREF"})
nPosIdent 	:= AScan(aHeadALP,{|x| Upper(AllTrim(x[2])) == "ALP_IDENT"})
nPosUM    	:= AScan(aHeadALP,{|x| Upper(AllTrim(x[2])) == "ALP_UM"})

nPos_ALI_WT := AScan(aHeadALP,{|x| Upper(AllTrim(x[2])) == "ALP_ALI_WT"})
nPos_REC_WT := AScan(aHeadALP,{|x| Upper(AllTrim(x[2])) == "ALP_REC_WT"})

If nPosRelac > 0

	//
	//--- Chamado TGYM72 - 12/04/2013
	If Empty( AMD->AMD_ALIAS )

		aHeadALP[nPosRelac,9] := "ALQ"
		aHeadALP[nPosRelac,6] := "ExistCpo('ALQ',ALLTRIM(M->ALP_TIPO))"		

	Else

		aHeadALP[nPosRelac,9] := AMD->AMD_ALIAS
		aHeadALP[nPosRelac,6] := "ExistCpo('" + AMD->AMD_ALIAS + "',ALLTRIM(M->ALP_TIPO))"

	EndIf
	//--- Chamado TGYM72 - 12/04/2013 -- Fim
	
EndIf

If nPosIDRef > 0
	aHeadALP[nPosIDRef][4] := 0
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aCols do ALP                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aColsALP := {}
DbSelectArea("ALP")
DbSetOrder(1)
DbSeek(xFilial("ALP")+AM5->AM5_CODIGO)

cRegra := ALP->ALP_FILIAL + ALP->ALP_CODIGO
While nCallOpcx != 3 .And. !Eof() .And. ALP->ALP_FILIAL + ALP->ALP_CODIGO == cRegra
	If aRecnos == Nil .Or. AScan(aRecnos,ALP->(Recno())) > 0
		AAdd(aColsALP,Array( nLenALP ))
		nLinALP++
		// Varre o aHeader para preencher o acols
		AEval(aHeadALP, {|x,y| aColsALP[nLinALP][y] := If(Alltrim(x[2])$"ALP_ALI_WT|ALP_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })	
		
		If nPosIdent > 0 .And. !Empty(ALP->ALP_IDREF)
			aAuxArea := GetArea()
			AK6->(dbSetOrder(1))
			AK6->(dbSeek(xFilial()+ALP->ALP_CLASSE))
			If ! Empty(AK6->AK6_VISUAL)
				dbSelectArea(Substr(ALP->ALP_IDREF,1,3))
				dbSetOrder(Val(Substr(ALP->ALP_IDREF,4,2)))
				dbSeek(Substr(ALP->ALP_IDREF,6,Len(ALP->ALP_IDREF)))
				aColsALP[nLinALP][nPosIdent] := &(ALP->ALP_VISUAL)
			EndIf
			RestArea(aAuxArea)
		EndIf
		If nPosUM > 0
			AK6->(dbSetOrder(1))
			AK6->(dbSeek(xFilial()+ALP->ALP_CLASSE))
			aAuxArea := GetArea()
			If !Empty(AK6->AK6_UM)
				If !Empty(ALP->ALP_IDREF)
					dbSelectArea(Substr(ALP->ALP_IDREF,1,3))
					dbSetOrder(Val(Substr(ALP->ALP_IDREF,4,2)))
					dbSeek(Substr(ALP->ALP_IDREF,6,Len(ALP->ALP_IDREF)))
				EndIf
				aColsALP[nLinALP][nPosUM] := &(AK6->AK6_UM)
			EndIf
			RestArea(aAuxArea)
		EndIf
		
		If nPos_ALI_WT > 0
			aColsALP[nLinALP][nPos_ALI_WT] := "ALP"
		EndIf
		
		If nPos_REC_WT > 0
			aColsALP[nLinALP][nPos_REC_WT] := ALP->(Recno())
		EndIf
		
		// Deleted
		aColsALP[nLinALP][nLenALP] := .F.
		AAdd( aRecALP, ALP->( Recno() ) )		
	Endif
	// Adiciona o Recno no aRec	
	ALP->(DbSkip())
EndDo

// Verifica se nใo foi criada nenhuma linha para o aCols
If Len(aColsALP) = 0
	AAdd(aColsALP,Array( nLenALP ))
	nLinALP++
	// Varre o aHeader para preencher o acols
	AEval(aHeadALP, {|x,y| aColsALP[nLinALP][y] := IIf(Upper(AllTrim(x[2])) == "ALP_ID", StrZero(1,Len(ALP->ALP_ID)),  If(!(x[2]$"ALP_ALI_WT|ALP_REC_WT"), CriaVar(AllTrim(x[2])), NIL) ) })
	
	If nPos_ALI_WT > 0
		aColsALP[nLinALP][nPos_ALI_WT] := "ALP"
	EndIf
	
	If nPos_REC_WT > 0
		aColsALP[nLinALP][nPos_REC_WT] := 0
	EndIf
	
	// Deleted
	aColsALP[nLinALP][nLenALP] := .F.
EndIf

If !lAuto
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ GetDados com as Regras                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nCallOpcx = 3 .Or. nCallOpcx = 4 .or. nCallOpcx = 6
		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf
	oGdALP:= MsNewGetDados():New(0,0,100,100,nGetd,"ALPLinOK",,"+ALP_ID",,,9999,,,,oDlg,aHeadALP,aColsALP)
	oGdALP:AddAction("ALP_IDENT",{||PCOIdentF3("ALP")})
	oGdALP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdALP:CARGO := AClone(aRecALP)
	
	aButtons := aClone(AddToExcel(aButtons,{{"ENCHOICE",,oEnchAM5:aGets,oEnchAM5:aTela},{"GETDADOS",,oGdALP:aHeader,oGdALP:aCols} } ))	
	If nCallOpcx != 3
		AM5->(RestArea(aAreaAM5)) // Retorna Area para que os dados da enchoice aparecam corretos
		oEnchAM5:Refresh()
	EndIf
	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT (oGdALP:oBrowse:Refresh(),EnchoiceBar(oDlg,{|| Processa({|| lOk := A440Ok(nCallOpcx,oGdALP:Cargo,aEnchAuto,oGdALP:aCols,oGdALP:aHeader,.T., aId_ALP,nRecnoAM5)},'Gravando regras...'), If(lOk, oDlg:End(),NIL) },{|| lCancel := .T., oDlg:End() },,aButtons))
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdALP:oBrowse:Refresh(),EnchoiceBar(oDlg, ;
		{|| Processa( {|| lOk := A440Ok(nCallOpcx,oGdALP:Cargo,aEnchAuto,oGdALP:aCols,oGdALP:aHeader,.T., aId_ALP,nRecnoAM5)},'Gravando regras...'), If(lOk,oDlg:End(),NIL)},;
		{|| lCancel := .T., oDlg:End() },,aButtons) )
	EndIf
Else
	lCancel := !A440Ok(nCallOpcx,aRecALP,aEnchAuto,aColsALP,aHeadALP,lProc, aId_ALP,nRecnoAM5)
EndIf

If __lSX8 .And. lCancel
	RollBackSX8()
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaAM5) 
RestArea(aAreaALP)
Return !lCancel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A440Ok   บAutor  ณ Joใo Gon็alves de Oliveira บ Data ณ  09/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao do botao OK da enchoice bar, valida e faz o tratamento      บฑฑ
ฑฑบ          ณ das informacoes.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A440Ok(nCallOpcx,aRecALP,aEnchAuto,aColsALP,aHeadALP,lProc,aId_ALP,nRecnoAM5)
Local nI
Local nX
Local aAreaAM5	:= AM5->(GetArea())
Local aAreaALP	:= ALP->(GetArea())
Local nPosItem  := AScan(aHeadALP,{|x| Upper(AllTrim(x[2])) == "ALP_ID"})
DEFAULT lProc	:=	.F.
If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If INCLUI
	If ! ExistChav('AM5',M->AM5_CODIGO)
		Return .F.
	Endif
Endif

If ! A440Vld(nCallOpcx,aRecALP,aEnchAuto,aColsALP,aHeadALP)
	Return .F.
EndIf

AM5->(DbSetOrder(1))
If lProc
	ProcRegua(Len(aColsALP))
Endif

If nCallOpcx = 3 .Or. nCallOpcx == 6 // Inclusao ou C๓pia
	Reclock("AM5",.T.)
	// Grava Campos do Cabecalho
	For nX := 1 To Len(aEnchAuto)
		FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
	Next nX

	// Grava campos que nao estao disponiveis na tela
	Replace AM5_CFGPLN With MV_PAR01
	Replace AM5_TPCOD  With MV_PAR02
	Replace AM5_VARCOD With MV_PAR03
	Replace AM5_FILIAL With xFilial()
	MsUnlock()				
	
	// Grava Regras
	For nI := 1 To Len(aColsALP)
		If lProc
			If nI == 1
				IncProc(STR0013)	// 'Atualizando regras...'
			Else
				IncProc()
			Endif
		Endif
		If aColsALP[nI][Len(aColsALP[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("ALP",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no acols
		AEval(aHeadALP,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALP[nI][y])), ) })	
		
		// Grava campos que nao estao disponiveis na tela	
		Replace ALP_FILIAL With xFilial()			
		Replace ALP_CODIGO With AM5->AM5_CODIGO 	
		MsUnlock()			
	Next nI	
ElseIf nCallOpcx = 4 // Alteracao	
	// Grava Regras
	AM5->(dbGoTo(nRecnoAM5))
	Reclock("AM5",.F.)
	// Grava Campos do Cabecalho
	For nX := 1 To Len(aEnchAuto)
		FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
	Next nX
		
	// Grava campos que nao estao disponiveis na tela
	Replace AM5_FILIAL With xFilial()
	MsUnlock()				
	
	For nI := 1 To Len(aColsALP) 
		If lProc
			If nI == 1
				IncProc(STR0013)	// 'Atualizando regras...'
			Else
				IncProc()
			Endif
		Endif
		If nI <= Len(aRecALP) .And. aRecALP[nI] > 0
			ALP->(DbGoto(aRecALP[nI]))
			Reclock("ALP",.F.)
		Else
			If aColsALP[nI][Len(aColsALP[nI])] // Verifica se a linha esta deletada
				Loop                   
			Else
				Reclock("ALP",.T.)
			EndIf
		EndIf
		
		If aColsALP[nI][Len(aColsALP[nI])] // Verifica se a linha esta deletada
			ALP->(DbDelete())
		Else			
			If aId_ALP != NIL
				nPos_Id	:=	ASCAN(aId_ALP, {|x| x[1] == aColsALP[nI, nPosItem]})
				
				If nPos_Id == 0 .And. nPosItem > 0					
					cId_Ant := aColsALP[nI, nPosItem]   //salva o Id atual
					cId_ALP := A440Id_Next_ALP()  // Gerar novo Id
					aAdd(aId_ALP, {cId_ALP, { 0 }})  // agregar ao array para os proximos
					
					//substituir todos os itens pelo novo codigo do item(ALP_ID)
					aColsALP[nI, nPosItem] := cId_ALP  //joga no acols novo Id
				EndIf
			EndIf
						
			// Varre o aHeader e grava com base no acols
			AEval(aHeadALP,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALP[nI][y])), ) })			
		
			// Grava campos que nao estao disponiveis na tela			
			Replace ALP_FILIAL With xFilial()			
			Replace ALP_CODIGO With AM5->AM5_codigo
			MsUnlock()			
		EndIf		
	Next nI
ElseIf nCallOpcx = 5 // Exclusao
	// Exclui Regra	
	AM5->(DbGoto(nRecnoAM5))		
	Reclock("AM5",.F.)
	AM5->(DbDelete())
	MsUnLock()	
	
	For nI := 1 To Len(aColsALP)
		If lProc
			If nI == 1
				IncProc(STR0013)	// 'Atualizando regras...'
			Else
				IncProc()
			Endif
		Endif
		If nI <= Len(aRecALP) .And. aRecALP[nI] > 0
			ALP->(DbGoto(aRecALP[nI]))		
			Reclock("ALP",.F.)
			ALP->(DbDelete())
			MsUnLock()
		EndIf
	Next nI	
EndIf

AM5->(RestArea(aAreaAM5))
ALP->(RestArea(aAreaALP))
If __lSX8
	ConfirmSX8()
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A440Vld  บAutor  ณGuilherme C. Leal   บ Data ณ  11/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de validacao dos campos.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A440Vld(nCallOpcx,aRecALP,aEnchAuto,aColsALP,aHeadALP)
Local nI
If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .T.
EndIf

If ( AScan(aEnchAuto,{|x| If(Alltrim(x[2])$"ALP_ALI_WT|ALP_REC_WT", .F., x[17] .And. Empty( &( "M->" + x[2] ) ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsALP)
	If ! aColsALP[nI,Len(aHeadALP)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(aHeadALP,{|x,y| if(Alltrim(x[2])$"ALP_ALI_WT|ALP_REC_WT", .F. , x[17] .And. Empty(aColsALP[nI][y])) })
		If nPosField > 0
			SX2->(dbSetOrder(1))
			SX2->(MsSeek("ALP"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0008+ AllTrim(aHeadALP[nPosField][1])+CHR(10)+CHR(13)+STR0009+Str(nI,3,0),3,1) //"Campo: "###"Linha: "
			Return .F.
		EndIf
	EndIf
Next nI
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoxGD1LinOKณ Autor ณ Edson Maricate      ณ Data ณ 17-12-2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณValidacao da LinOK da Getdados                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณPCOXFUN                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ALPLinOK()
Local lRet			:= .T.
Local nPosOper		:= aScan(aHeader,{|x|AllTrim(x[2])=="ALP_OPER"})
Local nPosClasse	:= aScan(aHeader,{|x|AllTrim(x[2])=="ALP_CLASSE"})
Local nPosIDRef		:= aScan(aHeader,{|x|AllTrim(x[2])=="ALP_IDREF"})
Local nPosField

If !aCols[n][Len(aCols[n])]
	dbSelectArea("AK6")
	dbSetOrder(1)
	dbSeek(xFilial()+aCols[n][nPosClasse])
	
	If AK6->AK6_OBRIGA=="1" .And. Empty(aCols[n][nPosIDRef])
		HELP("  ",1,"PCONOCHAVE")
		lRet	:= .F.
	EndIf
	
	If lRet .And. AK6->AK6_OPER=="1" .And. Empty(aCols[n][nPosOper])
		HELP("  ",1,"PCONOOPER")
		lRet	:= .F.
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica os campos obrigatorios do SX3.              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n)
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A440VldCO บ Autor ณ Gustavo Henrique  บ Data ณ  20/01/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se a conta orcamentaria selecionada para a          บฑฑ
ฑฑบ          ณ regra eh sintetica                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Codigo da conta orcamentaria                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID do campo AM5_CO                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A440VldCO( cCO )
Local lRet		:= .T.
Local aAreaAK5	:= AK5->( GetArea() )

AK5->( dbSetOrder( 1 ) )
AK5->( dbSeek( xFilial("AK5") + cCO ) )

lRet := (AK5->AK5_TIPO == "2")

If ! lRet
	Aviso( STR0011, STR0012, {"Ok"} )		// "Aten็ใo" ### "Informe uma conta orcamentแria analํtica."
EndIf
                                          	
RestArea( aAreaAK5 )
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA440Id_Next_AM5บAutor  ณPaulo Carnelossi บ Data ณ 31/03/06  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณRetorna Proximo ALP_ID para o lote em edicao                บฑฑ
ฑฑบ          ณUtilizado quando usuario resolve colocar + 1 item na altera-บฑฑ
ฑฑบ          ณcao da regra quando o parametro MV_PCOVISL esta com         บฑฑ
ฑฑบ          ณconteudo "2" (somente edita regras alteradas/Pcodetlan()    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A440Id_Next_ALP()
Local aArea := GetArea()
Local aAreaALP := AM5->(GetArea()) 
Local nItALP := 0

dbSelectArea("AM5")
dbSetOrder(1)
If dbSeek(xFilial("ALP")+M->AM5_CODIGO)
	While ALP->(!Eof().And.ALP_FILIAL+ALP_CODIGO == ;
		xFilial("ALP")+M->ALP_CODIGO)
		nItALP := VAL(ALP->ALP_ID)
		AM5->(dbSkip())
	End
EndIf

nItALP++
cItALP := StrZero(nItALP, Len(ALP->ALP_ID))

RestArea(aAreaALP)
RestArea(aArea)
Return(cItALP)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ17/11/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {{STR0002,"AxPesqui",0,1,,.F.},;    //"Pesquisar"
{ STR0003, "A440DLG"   ,0,2},; //"Visualizar"
{ STR0004, "A440DLG"   ,0,3},; //"Incluir"
{ STR0005, "A440DLG"   ,0,4},; //"Alterar"
{ STR0006, "A440DLG"   ,0,5},; //"Excluir"
{ STR0014, "A440DLG"   ,0,3}}  //"Copiar"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona botoes do usuario no aRotina                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock( "PCOA4401" )
	//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
	//P_Eณ browse da tela de lan็amentos                                          ณ
	//P_Eณ Parametros : Nenhum                                                    ณ
	//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
	//P_Eณ               Ex. :  User Function PCOA4401                            ณ
	//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
	//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType( aUsRotina := ExecBlock( "PCOA4401", .F., .F. ) ) == "A"
		AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf
Return(aRotina)
