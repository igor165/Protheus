#include "OFIPA910.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} OFIPA910
Substituicao de Itens Manual 
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Function OFIPA910

Private cCadastro := STR0005 //Substituicao de itens manual
Private aRotina := MenuDef()

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar o modulo de Oficina ou Auto Peças             //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIPA910"})
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VE9")

Return

/*/{Protheus.doc} OFIPA910Vis
Chamada da Visualizacao da Substituicao de Itens
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Function OFIPA910Vis()
	OFIPA910TELA("VE9",VE9->(RecNo()),2) // Visualizar
Return

/*/{Protheus.doc} OFIPA910Inc
Chamada da Inclusao da Substituicao de Itens
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Function OFIPA910Inc()
	OFIPA910TELA("VE9",0,3) // Incluir
Return

/*/{Protheus.doc} OFIPA910Exc
Chamada da Exclusao da Substituicao de Itens
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Function OFIPA910Exc()
	OFIPA910TELA("VE9",VE9->(RecNo()),5) // Excluir
Return

/*/{Protheus.doc} OFIPA910TELA
Tela de Inclusao e Exclusao da Substituicao de Itens
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Static Function OFIPA910TELA(cAlias,nReg,nOpc)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lOk     := .f.
Local cNroSub := ""
Local nCntFor := 0
Local cAux    := ""
Private M->VE9_GRUITE := space( TamSx3('VE9_GRUITE')[1] )
Private M->VE9_ITEANT := space( TamSx3('VE9_ITEANT')[1] )
Private M->VE9_DESANT := ""
Private M->VE9_GRUNOV := space( TamSx3('VE9_GRUITE')[1] )
Private M->VE9_ITENOV := space( TamSx3('VE9_ITENOV')[1] )
Private M->VE9_DESNOV := ""
Private M->VE9_QTDADE := 0
If nOpc <> 3 // Visualizar ou Excluir
	M->VE9_GRUITE := VE9->VE9_GRUITE
	M->VE9_ITEANT := VE9->VE9_ITEANT
	M->VE9_DESANT := FM_SQL("SELECT B1_DESC FROM "+RetSqlName("SB1")+" WHERE B1_FILIAL='"+xFilial("SB1")+"' AND B1_GRUPO='"+M->VE9_GRUITE+"' AND B1_CODITE='"+M->VE9_ITEANT+"' AND D_E_L_E_T_=' '")
	If VE9->(FieldPos("VE9_GRUNOV")) > 0
		M->VE9_GRUNOV := VE9->VE9_GRUNOV
	Else
		M->VE9_GRUNOV := VE9->VE9_GRUITE
	EndIf
	M->VE9_ITENOV := VE9->VE9_ITENOV
	M->VE9_DESNOV := FM_SQL("SELECT B1_DESC FROM "+RetSqlName("SB1")+" WHERE B1_FILIAL='"+xFilial("SB1")+"' AND B1_GRUPO='"+M->VE9_GRUNOV+"' AND B1_CODITE='"+M->VE9_ITENOV+"' AND D_E_L_E_T_=' '")
	M->VE9_QTDADE := VE9->VE9_QTDADE
	cAux := " "+Transform(VE9->VE9_DATSUB,"@D")
EndIf

//Fator de reducao 60%
for nCntFor := 3 to 6
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.60)
next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
//
AAdd( aObjects, { 0, 00, .T. , .T. } ) // label 1 parte superior
AAdd( aObjects, { 0, 20, .T. , .F. } ) // CAMPOS - DE
AAdd( aObjects, { 0, 00, .T. , .T. } ) // label 1 parte inferior
//
AAdd( aObjects, { 0, 00, .T. , .T. } ) // label 2 parte superior
AAdd( aObjects, { 0, 20, .T. , .F. } ) // CAMPOS - PARA
AAdd( aObjects, { 0, 00, .T. , .T. } ) // label 2 parte inferior
//
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oOFIPA910 TITLE cCadastro FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] PIXEL // OF oMainWnd PIXEL
	oOFIPA910:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] TO aPos[3,3],aPos[3,4] LABEL (STR0040+cAux) OF oOFIPA910 PIXEL // Substituido
	@ aPos[2,1]+000,aPos[2,2]+005 SAY STR0042 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Grupo
	@ aPos[2,1]+010,aPos[2,2]+005 MSGET oVE9_GRUITE VAR M->VE9_GRUITE PICTURE "@!" F3 "SBM" SIZE 35,10 VALID OFIPA910FOK() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON WHEN nOpc == 3
	@ aPos[2,1]+000,aPos[2,2]+045 SAY STR0043 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Código do Item
	@ aPos[2,1]+010,aPos[2,2]+045 MSGET oVE9_ITEANT VAR M->VE9_ITEANT PICTURE "@!" F3 "B12" SIZE 100,10 VALID OFIPA910FOK() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON WHEN nOpc == 3
	@ aPos[2,1]+000,aPos[2,2]+150 SAY STR0044 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Descrição
	@ aPos[2,1]+010,aPos[2,2]+150 MSGET oVE9_DESANT VAR M->VE9_DESANT PICTURE "@!" SIZE aPos[2,4]-160,10 OF oOFIPA910 PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[4,1],aPos[4,2] TO aPos[6,3],aPos[6,4] LABEL (STR0041+cAux) OF oOFIPA910 PIXEL // Substituto
	@ aPos[5,1]+000,aPos[5,2]+005 SAY STR0042 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Grupo
	@ aPos[5,1]+010,aPos[5,2]+005 MSGET oVE9_GRUNOV VAR M->VE9_GRUNOV PICTURE "@!" F3 "SBM" SIZE 35,10 VALID OFIPA910FOK() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON WHEN nOpc == 3
	@ aPos[5,1]+000,aPos[5,2]+045 SAY STR0043 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Código do Item
	@ aPos[5,1]+010,aPos[5,2]+045 MSGET oVE9_ITENOV VAR M->VE9_ITENOV PICTURE "@!" F3 "B12" SIZE 100,10 VALID OFIPA910FOK() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON WHEN nOpc == 3
	@ aPos[5,1]+000,aPos[5,2]+150 SAY STR0044 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Descrição
	@ aPos[5,1]+010,aPos[5,2]+150 MSGET oVE9_DESNOV VAR M->VE9_DESNOV PICTURE "@!" SIZE aPos[5,4]-210,10 OF oOFIPA910 PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[5,1]+000,aPos[5,4]-052 SAY STR0017 SIZE 50,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Quantidade
	@ aPos[5,1]+010,aPos[5,4]-052 MSGET oVE9_QTDADE VAR M->VE9_QTDADE PICTURE "@E 9999,999" SIZE 45,10 VALID positivo() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON WHEN nOpc == 3
ACTIVATE MSDIALOG oOFIPA910 CENTER ON INIT (EnchoiceBar(oOFIPA910,{|| IIf(OFIPA910TOK(nOpc),( lOk := .t. , oOFIPA910:End() ),.f.) },{ || oOFIPA910:End()},,))

If lOk // Ok na TELA
	//
	If nOpc == 3 // Incluir
		Begin Transaction
			cNroSub := GetSXENum("VE9","VE9_NROSUB")
			ConfirmSX8()
			DbSelectArea("VE9")
			RecLock("VE9",.t.)
			FG_GRAVAR("VE9")
			VE9->VE9_FILIAL := xFilial("VE9")
			VE9->VE9_NROSEQ := "000001"
			VE9->VE9_NROSUB := cNroSub
			VE9->VE9_DATSUB := dDataBase
			VE9->VE9_QTDSUB := 0
			If VE9->(FieldPos("VE9_SEGMEN")) > 0
				VE9->VE9_SEGMEN := "04" // Substituicao manual
			EndIf
			MsUnlock()
			DbSelectArea("SB1")
			DbSetOrder(7)
			If DbSeek(xFilial("SB1")+M->VE9_GRUITE+M->VE9_ITEANT)
				RecLock("SB1",.f.)
				SB1->B1_DATASUB := dDataBase
				MsUnlock()
			EndIf
		End Transaction
	ElseIf nOpc == 5  // Excluir
		Begin Transaction
			DbSelectArea("VE9")
			RecLock("VE9",.f.,.t.)
			DbDelete()
			MsUnlock()
		End Transaction
	EndIf
	//
EndIf
Return

/*/{Protheus.doc} OFIPA910FOK
FieldOK da Tela de Substituicao de Itens
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Static Function OFIPA910FOK()
Local lRet := .t.
Do Case
	Case ReadVar() == "M->VE9_GRUITE"
		If !Empty(M->VE9_GRUITE)
			DbSelectArea("SBM")
			DbSetOrder(1)
			If !DbSeek(xFilial("SBM")+M->VE9_GRUITE)
				lRet := .f.
			EndIf
		EndIf
		If lRet .and. !Empty(M->VE9_ITEANT)
			DbSelectArea("SB1")
			DbSetOrder(7)
			If !DbSeek(xFilial("SB1")+M->VE9_GRUITE+M->VE9_ITEANT)
				M->VE9_ITEANT := space( TamSx3('VE9_ITEANT')[1] )
				M->VE9_DESANT := ""
				oVE9_ITEANT:Refresh()
			Else
				M->VE9_DESANT := SB1->B1_DESC
			EndIf
		EndIf
		oVE9_DESANT:Refresh()
	Case ReadVar() == "M->VE9_ITEANT"
		M->VE9_DESANT := ""
		If !Empty(M->VE9_ITEANT)
			If FG_POSSB1("M->VE9_ITEANT","SB1->B1_CODITE","M->VE9_GRUITE")
				M->VE9_GRUITE := SB1->B1_GRUPO
				M->VE9_DESANT := SB1->B1_DESC
			Else
				lRet := .f.
			EndIf
		EndIf
		oVE9_GRUITE:Refresh()
		oVE9_DESANT:Refresh()
	Case ReadVar() == "M->VE9_GRUNOV"
		If !Empty(M->VE9_GRUNOV)
			DbSelectArea("SBM")
			DbSetOrder(1)
			If !DbSeek(xFilial("SBM")+M->VE9_GRUNOV)
				lRet := .f.
			EndIf
		EndIf
		If lRet .and. !Empty(M->VE9_ITENOV)
			DbSelectArea("SB1")
			DbSetOrder(7)
			If !DbSeek(xFilial("SB1")+M->VE9_GRUNOV+M->VE9_ITENOV)
				M->VE9_ITENOV := space( TamSx3('VE9_ITENOV')[1] )
				M->VE9_DESNOV := ""
				oVE9_ITENOV:Refresh()
			Else
				M->VE9_DESNOV := SB1->B1_DESC
			EndIf
		EndIf
		oVE9_DESNOV:Refresh()
	Case ReadVar() == "M->VE9_ITENOV"
		M->VE9_DESNOV := ""
		If !Empty(M->VE9_ITENOV)
			If FG_POSSB1("M->VE9_ITENOV","SB1->B1_CODITE","M->VE9_GRUNOV")
				M->VE9_GRUNOV := SB1->B1_GRUPO
				M->VE9_DESNOV := SB1->B1_DESC
			Else
				lRet := .f.
			EndIf
		EndIf
		oVE9_GRUNOV:Refresh()
		oVE9_DESNOV:Refresh()
EndCase
Return lRet

/*/{Protheus.doc} OFIPA910TOK
TudoOK da Tela de Substituicao de Itens
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Static Function OFIPA910TOK(nOpc)
Local cTexto  := ""
Local lGruNov := VE9->(FieldPos("VE9_GRUNOV")) > 0
Local cNroSub := ""
Local cGrupo  := ""
Local cItem   := ""
Local nRecVE9 := 0
Local cQuery  := ""
If nOpc == 3
	If Empty(M->VE9_GRUITE) .or. Empty(M->VE9_GRUNOV)
		MsgStop(STR0023,STR0010) //"Grupo do item deve ser informado..."###"Atencao"
		Return .f.
	EndIf
	If Empty(M->VE9_ITEANT) .or. Empty(M->VE9_ITENOV)
		MsgStop(STR0024,STR0010) //"Codigo do item deve ser informado..."###"Atencao"
		Return .f.
	Endif
	If !lGruNov
		If M->VE9_GRUITE <> M->VE9_GRUNOV
			MsgStop(STR0009,STR0010) //"Grupo do item tem que ser igual..."###"Atencao"
			Return .f.
		EndIf
	EndIf
	If M->VE9_ITEANT == M->VE9_ITENOV
		MsgStop(STR0011,STR0010) // Item duplicado! / Atencao
		Return .f.
	EndIf
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSqlName("VE9")
	cQuery += " WHERE VE9_FILIAL='"+xFilial("VE9")+"'"
	cQuery += "   AND VE9_GRUITE='"+M->VE9_GRUITE+"'"
	cQuery += "   AND VE9_ITEANT='"+M->VE9_ITEANT+"'"
	If lGruNov
		cQuery += " AND VE9_GRUNOV='"+M->VE9_GRUNOV+"'"
	EndIf
	cQuery += "   AND VE9_ITENOV='"+M->VE9_ITENOV+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	If FM_SQL(cQuery) > 0
		MsgStop(STR0049,STR0010) // Cadastro duplicado! / Atencao
		Return .f.
	EndIf
	cTexto := (STR0018) //"Confirma substituicao?"
ElseIf nOpc == 5
	// Valida se pode executar a Exclusao
	nRecVE9 := VE9->(Recno())
	cNroSub := VE9->VE9_NROSUB
	cGrupo  := IIf(lGruNov,VE9->VE9_GRUNOV,VE9->VE9_GRUITE)
	cItem   := VE9->VE9_ITENOV
	DbSelectArea("VE9")
	DbSetOrder(3)
	If DbSeek(xFilial("VE9")+cItem)
		MsgStop(STR0034+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cGrupo+" "+cItem+" "+STR0045,STR0010) // Item nao pode ser excluido... / já foi substituido. / Atencao
		DbSelectArea("VE9")
		DbSetOrder(1)
		DbGoto(nRecVE9)
		Return .f.
	EndIf
	DbSelectArea("VE9")
	DbSetOrder(1)
	DbGoto(nRecVE9)
	cTexto := (STR0019) // Confirma cancelamento da substituicao?
EndIf
If !Empty(cTexto)
	If !MsgYesNo(cTexto,(STR0010)) // Atencao
		Return .f.
	EndIf
EndIf
Return .t.


/*/{Protheus.doc} OFIPA910Con
Consulta das Substituicoes do Item
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Function OFIPA910Con()
Local oSizeC      := FwDefSize():New(.T.) // Com enchoicebar
Local oSizeL      := FwDefSize():New(.T.) // Com enchoicebar
Private M->VE9_GRUITE := space( TamSx3('VE9_GRUITE')[1] )
Private M->VE9_ITEANT := space( TamSx3('VE9_ITEANT')[1] )
Private M->VE9_DESANT := ""
Private M->VE9_QTDADE := 0
Private aSub1         := {{"","","",ctod(""),0}}
Private aSub2         := {{"","","",ctod(""),0}}

oSizeC:lLateral := .T. // Cálculo vertical
oSizeC:AddObject("C1"    ,  0,   0, .T., .T.) // Coluna 1 50%
oSizeC:AddObject("C2"    ,  0,   0, .T., .T.) // Coluna 2 50%
oSizeC:Process()

oSizeL:lLateral := .f. // Cálculo vertical
oSizeL:AddObject("L1"    ,  0, 45, .T., .F.) // Linha 1 fixa 45pix - Filtro SB1
oSizeL:AddObject("L2"    ,  0,  5, .T., .F.) // Linha 2 fixa  5pix - Titulo Label dos ListBox
oSizeL:AddObject("L3"    ,  0,  0, .T., .T.) // Linha 3 restante   - ListxBox Substituidos/Substitutos
oSizeL:Process()

DEFINE MSDIALOG oOFIPA910 TITLE cCadastro FROM 	oSizeC:aWindSize[1], oSizeC:aWindSize[2] TO oSizeC:aWindSize[3], oSizeC:aWindSize[4] PIXEL

@ oSizeL:GetDimension("L1", "LININI")+000,oSizeC:GetDimension("C1", "COLINI") TO oSizeL:GetDimension("L1", "LINEND"),oSizeC:GetDimension("C2", "COLEND") LABEL "" OF oOFIPA910 PIXEL
@ oSizeL:GetDimension("L1", "LININI")+010,oSizeC:GetDimension("C1", "COLINI")+005 SAY STR0042 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Grupo
@ oSizeL:GetDimension("L1", "LININI")+020,oSizeC:GetDimension("C1", "COLINI")+005 MSGET oVE9_GRUITE VAR M->VE9_GRUITE PICTURE "@!" F3 "SBM" SIZE 35,10 VALID OFIPA910LBX() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON
@ oSizeL:GetDimension("L1", "LININI")+010,oSizeC:GetDimension("C1", "COLINI")+045 SAY STR0043 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Código do Item
@ oSizeL:GetDimension("L1", "LININI")+020,oSizeC:GetDimension("C1", "COLINI")+045 MSGET oVE9_ITEANT VAR M->VE9_ITEANT PICTURE "@!" F3 "B12" SIZE 100,10 VALID OFIPA910LBX() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON
@ oSizeL:GetDimension("L1", "LININI")+010,oSizeC:GetDimension("C1", "COLINI")+150 SAY STR0044 SIZE 40,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Descrição
@ oSizeL:GetDimension("L1", "LININI")+020,oSizeC:GetDimension("C1", "COLINI")+150 MSGET oVE9_DESANT VAR M->VE9_DESANT PICTURE "@!" SIZE oSizeC:GetDimension("C2", "COLEND")-210,10 OF oOFIPA910 PIXEL COLOR CLR_BLUE WHEN .f.
@ oSizeL:GetDimension("L1", "LININI")+010,oSizeC:GetDimension("C2", "COLEND")-052 SAY STR0017 SIZE 50,8 OF oOFIPA910 PIXEL COLOR CLR_BLACK // Quantidade
@ oSizeL:GetDimension("L1", "LININI")+020,oSizeC:GetDimension("C2", "COLEND")-052 MSGET oVE9_QTDADE VAR M->VE9_QTDADE PICTURE "@E 9999,999" SIZE 45,10 VALID positivo() OF oOFIPA910 PIXEL COLOR CLR_BLUE HASBUTTON WHEN .f.

@ oSizeL:GetDimension("L2", "LININI")+000,oSizeC:GetDimension("C1", "COLINI") TO oSizeL:GetDimension("L3", "LINEND"),oSizeC:GetDimension("C1", "COLEND") LABEL STR0046 OF oOFIPA910 PIXEL // Itens Substituidos pelo Item Pesquisado
oLbSub1 := TWBrowse():New(oSizeL:GetDimension("L3", "LININI"),oSizeC:GetDimension("C1", "COLINI")+3,oSizeC:GetDimension("C1", "COLEND")-9,(oSizeL:GetDimension("L3", "LINEND")-oSizeL:GetDimension("L3", "LININI")),,,,oOFIPA910,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
oLbSub1:addColumn( TCColumn():New( STR0042 , { || aSub1[oLbSub1:nAt,1] } ,,,, "LEFT" ,  25 ,.F.,.F.,,,,.F.,) ) // Grupo
oLbSub1:addColumn( TCColumn():New( STR0043 , { || aSub1[oLbSub1:nAt,2] } ,,,, "LEFT" ,  70 ,.F.,.F.,,,,.F.,) ) // Código do Item
oLbSub1:addColumn( TCColumn():New( STR0044 , { || aSub1[oLbSub1:nAt,3] } ,,,, "LEFT" , 130 ,.F.,.F.,,,,.F.,) ) // Descrição
oLbSub1:addColumn( TCColumn():New( STR0008 , { || Transform(aSub1[oLbSub1:nAt,4],"@D") } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Data
oLbSub1:bChange := { || M->VE9_QTDADE := aSub1[oLbSub1:nAt,5] , oVE9_QTDADE:Refresh() }
oLbSub1:nAT := 1
oLbSub1:SetArray(aSub1)

@ oSizeL:GetDimension("L2", "LININI")+000,oSizeC:GetDimension("C2", "COLINI") TO oSizeL:GetDimension("L3", "LINEND"),oSizeC:GetDimension("C2", "COLEND") LABEL STR0047 OF oOFIPA910 PIXEL // Itens Substitutos do Item Pesquisado
oLbSub2 := TWBrowse():New(oSizeL:GetDimension("L3", "LININI"),oSizeC:GetDimension("C2", "COLINI")+3,oSizeC:GetDimension("C1", "COLEND")-9,(oSizeL:GetDimension("L3", "LINEND")-oSizeL:GetDimension("L3", "LININI")),,,,oOFIPA910,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
oLbSub2:addColumn( TCColumn():New( STR0042 , { || aSub2[oLbSub2:nAt,1] } ,,,, "LEFT" ,  25 ,.F.,.F.,,,,.F.,) ) // Grupo
oLbSub2:addColumn( TCColumn():New( STR0043 , { || aSub2[oLbSub2:nAt,2] } ,,,, "LEFT" ,  70 ,.F.,.F.,,,,.F.,) ) // Código do Item
oLbSub2:addColumn( TCColumn():New( STR0044 , { || aSub2[oLbSub2:nAt,3] } ,,,, "LEFT" , 110 ,.F.,.F.,,,,.F.,) ) // Descrição
oLbSub2:addColumn( TCColumn():New( STR0008 , { || Transform(aSub2[oLbSub2:nAt,4],"@D") } ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // Data
oLbSub2:addColumn( TCColumn():New( STR0017 , { || Transform(aSub2[oLbSub2:nAt,5],"@E 9999,999") } ,,,, "RIGHT" , 35 ,.F.,.F.,,,,.F.,) ) // Quantidade
oLbSub2:nAT := 1
oLbSub2:SetArray(aSub2)

ACTIVATE MSDIALOG oOFIPA910 CENTER ON INIT (EnchoiceBar(oOFIPA910,{|| oOFIPA910:End() },{ || oOFIPA910:End()},,))
//
Return

/*/{Protheus.doc} OFIPA910LBX
Montagem dos ListBox
@author Andre Luis Almeida
@since 10/05/2018
@type function
/*/
Static Function OFIPA910LBX()
Local lRet    := .t.
Local cQuery  := ""
Local cQAlSQL := "SQLVE9"
Local cNamVE9 := RetSqlName("VE9")
Local cNamSB1 := RetSqlName("SB1")
Local cFilVE9 := xFilial("VE9")
Local cFilSB1 := xFilial("SB1")
Local cAux    := ""
If VE9->(FieldPos("VE9_GRUNOV")) > 0
	cAux := "VE9_GRUNOV"
Else
	cAux := "VE9_GRUITE"
EndIf
//
aSub1 := {}
aSub2 := {}
//
If OFIPA910FOK() // Valida Digitação do Item
	//
	cQuery := "SELECT VE9.VE9_GRUITE , VE9.VE9_ITEANT , SB1.B1_DESC , VE9.VE9_DATSUB , VE9.VE9_QTDADE "
	cQuery += "  FROM "+cNamVE9+" VE9 "
	cQuery += "  JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUITE AND SB1.B1_CODITE=VE9.VE9_ITEANT AND SB1.D_E_L_E_T_=' ' )"
	cQuery += " WHERE VE9.VE9_FILIAL = '"+cFilVE9+"'"
	cQuery += "   AND VE9."+cAux+" = '"+M->VE9_GRUITE+"'"
	cQuery += "   AND VE9.VE9_ITENOV = '"+M->VE9_ITEANT+"'"
	cQuery += "   AND VE9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		aAdd(aSub1,{ ( cQAlSQL )->( VE9_GRUITE ) ,;
					 ( cQAlSQL )->( VE9_ITEANT ) ,;
					 ( cQAlSQL )->( B1_DESC ) ,;
					 stod( ( cQAlSQL )->( VE9_DATSUB ) ) ,;
					 ( cQAlSQL )->( VE9_QTDADE ) })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	//
	cQuery := "SELECT VE9."+cAux+" AS VE9_GRUNOV , VE9.VE9_ITENOV , SB1.B1_DESC , VE9.VE9_DATSUB , VE9.VE9_QTDADE "
	cQuery += "  FROM "+cNamVE9+" VE9 "
	cQuery += "  JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9."+cAux+" AND SB1.B1_CODITE=VE9.VE9_ITENOV AND SB1.D_E_L_E_T_=' ' )"
	cQuery += " WHERE VE9.VE9_FILIAL = '"+cFilVE9+"'"
	cQuery += "   AND VE9.VE9_GRUITE = '"+M->VE9_GRUITE+"'"
	cQuery += "   AND VE9.VE9_ITEANT = '"+M->VE9_ITEANT+"'"
	cQuery += "   AND VE9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		aAdd(aSub2,{ ( cQAlSQL )->( VE9_GRUNOV ) ,;
					 ( cQAlSQL )->( VE9_ITENOV ) ,;
					 ( cQAlSQL )->( B1_DESC ) ,;
					 stod( ( cQAlSQL )->( VE9_DATSUB ) ) ,;
					 ( cQAlSQL )->( VE9_QTDADE ) })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	//
Else
	lRet := .f. // Problema na digitação do Item
EndIf
//
DbSelectArea("VE9")
//
If len(aSub1) <= 0
	aSub1 := {{"","","",ctod(""),0}}
EndIf
oLbSub1:nAt := 1
oLbSub1:SetArray(aSub1)
oLbSub1:Refresh()
M->VE9_QTDADE := aSub1[oLbSub1:nAt,5]
oVE9_QTDADE:Refresh()
//
If len(aSub2) <= 0
	aSub2 := {{"","","",ctod(""),0}}
EndIf
oLbSub2:nAt := 1
oLbSub2:SetArray(aSub2)
oLbSub2:Refresh()
//
Return lRet

/*/{Protheus.doc} MenuDef
Montagem do MenuDef
@author Andre Luis Almeida
@since 09/05/2018
@type function
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0001 ,"axPesqui"   , 0 , 1},; // Pesquisar
					{ STR0002 ,"OFIPA910Vis", 0 , 2},; // Visualizar
					{ STR0003 ,"OFIPA910Inc", 0 , 3},; // Incluir
					{ STR0004 ,"OFIPA910Exc", 0 , 5},; // Excluir
					{ STR0048 ,"OFIPA910Con", 0 , 2}}  // Consultar
Return aRotina