#INCLUDE "HSPAHA24.ch"
#include "protheus.CH"
#include "colors.CH"
#INCLUDE "TOPCONN.CH"

/*/.
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA24  บ Autor ณ Manoel             บ Data ณ  27/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE PROFISSIONAIS                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAlteracoesณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑบ          ณ Patricia Q. 23/05/06  -> Criacao da funcao HS_VldGD, para  บฑฑ
ฑฑบ          ณ                          evitar duplicidade de registros.  บฑฑ
ฑฑบ          ณ                          Correcao da funcao para gravacao  บฑฑ
ฑฑบ          ณ                          dos dados.                        บฑฑ
ฑฑบ          ณ                          Gravar o CPF na tabela SRA para   บฑฑ
ฑฑบ          ณ                          carregar a informacao no Browse.  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA24()
Private cCadastro	:= OemToAnsi(STR0001)                         //"Profissionais"
Private lGFR		:= HS_LocTab("GFR", .F.)
Private cPerg		:= PADR("HSPFUN", Len(SX1->X1_GRUPO))
Private lErro		:= .F. 
Private cAlias		:="SRA" 
Private cFilA24		:= ""
Private aRotina		:= MenuDef()
Private aRotiA24	:={}


aRotiA24    := aClone(aRotina) 

If !Pergunte(cPerg,.T.)
	Return()
EndIf

aRotina:= aRotiA24
dbSelectArea(cAlias)
If !Empty(MV_PAR01)
	mBrowse(06, 01, 22, 75, "SRA",,,,,,,,,,,,,, "RA_CODFUNC = '" + MV_PAR01 + "'")
Else
	mBrowse(06, 01, 22, 75, "SRA",,,,,,,,,,,,,, "RA_CODFUNC >= '" + MV_PAR01 + "'")
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAH241  บ Autor ณ Manoel             บ Data ณ 28/01/02    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Chama a Funcao de Cadastro de Profissionais                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MntA24(cAliasA24, nRegA24, nOpcA24)
Local lAltPre := .F., nGDOpc := IIf(StrZero(aRotina[nOpcA24, 4], 2) $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)

Private aTela := {}, aGets := {}, aSTela := {{},{}}, aSGets := {{},{}}
Private aHGFB := {}, aCGFB := {}, nUGFB := 0, nLGFB := 0, oGFB
Private aHGFP := {}, aCGFP := {}, nUGFP := 0, nLGFP := 0, oGFP
Private aHGFE := {}, aCGFE := {}, nUGFE := 0, nLGFE := 0, oGFE
Private oSRA
Private nGFBSeqFon := 0, nGFBNumTel := 0
Private nGFESeqCRM := 0, nGFECodLoc := 0, nGFECodPre := 0
Private nGFPSeqEsp := 0, nGFPCodEsp := 0, nQtdItens  := 0

If StrZero(aRotina[nOpcA24, 4], 2) $ "03/04"
	Altera := .T.
EndIf

DbSelectArea("SRA")
//RegToMemory("SRA", aRotina[nOpcA24, 4] == 3)
RegToMemory("SRA", .F.)

If !(aRotina[nOpcA24, 4] == 3)
	DbSelectArea("GBJ")
	DbSetOrder(1) //GBJ_FILAL + GBJ_CRM
	DbSeek(xFilial("GBJ") + M->RA_CODIGO)
EndIf

RegToMemory("GBJ", aRotina[nOpcA24, 4] == 3)

HS_BDados("GFB", @aHGFB, @aCGFB, @nUGFB, 1, "", IIf(aRotina[nOpcA24, 4] # 3, "GFB->GFB_CODPRO == '" + M->GBJ_CRM + "'", Nil))
nGFBSeqFon := aScan(aHGFB, {| aVet | aVet[2] == "GFB_SEQFON"})
nGFBNumTel := aScan(aHGFB, {| aVet | aVet[2] == "GFB_NUMTEL"})

nQtdItens  := HS_BDados("GFP", @aHGFP, @aCGFP, @nUGFP, 1, "", IIf(aRotina[nOpcA24, 4] # 3, "GFP->GFP_CODCRM == '" + M->GBJ_CRM + "'", Nil))
nGFPSeqEsp := aScan(aHGFP, {| aVet | aVet[2] == "GFP_ITEESP"})
nGFPCodEsp := aScan(aHGFP, {| aVet | aVet[2] == "GFP_CODESP"})

If aRotina[nOpcA24, 4] == 3 .Or. nQtdItens == 0
	aCGFP[1, nGFPSeqEsp] := Soma1(aCGFP[1, nGFPSeqEsp], Len(aCGFP[1, nGFPSeqEsp]))
EndIf


If StrZero(aRotina[nOpcA24, 4], 2) $ "03/04"
	If EMPTY(aCGFB[1, nGFBSeqFon])
		aCGFB[1, nGFBSeqFon] := Soma1(aCGFB[1, nGFBSeqFon], Len(aCGFB[1, nGFBSeqFon]))
	EndIf
EndIf

HS_BDados("GFE", @aHGFE, @aCGFE, @nUGFE, 1, "", IIf(aRotina[nOpcA24, 4] # 3, "GFE->GFE_CODCRM == '" + M->GBJ_CRM + "'", Nil))
nGFESeqCRM := aScan(aHGFE, {| aVet | aVet[2] == "GFE_SEQCRM"})
nGFECodLoc := aScan(aHGFE, {| aVet | aVet[2] == "GFE_CODLOC"})
nGFECodPRe := aScan(aHGFE, {| aVet | aVet[2] == "GFE_CODPRE"})

If StrZero(aRotina[nOpcA24, 4], 2) $ "03/04"
	If EMPTY(aCGFE[1, nGFESeqCRM])
		aCGFE[1, nGFESeqCRM] := Soma1(aCGFE[1, nGFESeqCRM], Len(aCGFE[1, nGFESeqCRM]))
	EndIf
EndIf

nOpca := 0
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 030, .T., .T. } )
AAdd( aObjects, { 100, 070, .T., .T.,.T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGDs := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
//oSRA := MsMGet():New("SRA", nRegA24, nOpcA24,,,,, aPObjs[1],, 3,,,, oDlg,,, .F., "aSTela[1]", .F.)
oSRA := MsMGet():New("SRA", nRegA24, 2,,,,, aPObjs[1],, 3,,,, oDlg,,, .F., "aSTela[1]", .F.)
oSRA:oBox:Align := CONTROL_ALIGN_ALLCLIENT
aSTela[1] := aClone(aTela)
aSGets[1] := aClone(aGets)
aGets := {}
aTela := {}

@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder2 SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0007, STR0008, STR0009, STR0010 //"Dados Complementares"###"Telefones"###"Prestadores"###"Especialidades Medicas"
oFolder2:Align := CONTROL_ALIGN_BOTTOM

oGBJ := MsMGet():New("GBJ", nRegA24, nOpcA24,,,,, aPGDs[1],, 3,,,, oFolder2:aDialogs[1],,, .F., "aSTela[2]", .F.)
oGBJ:oBox:align := CONTROL_ALIGN_ALLCLIENT
aSTela[2] := aClone(aTela)
aSGets[2] := aClone(aGets)

oGFB := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,, "+GFB_SEQFON",,,,,,, oFolder2:aDialogs[2], aHGFB, aCGFB)
oGFB:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGFP := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,, "+GFP_ITEESP",,,,,,, oFolder2:aDialogs[4], aHGFP, aCGFP)
oGFP:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
oGFP:oBrowse:bDelete := {|| IIF( oGFP:aCols[oGFP:oBrowse:nAt][Len(oGFP:aCols[oGFP:oBrowse:nAt])], HS_VldGD(oGFP:aCols[oGFP:oBrowse:nAt][nGFPCodEsp]), oGFP:DELLINE())}

oGFE := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,, "+GFE_SEQCRM",,,,,,, oFolder2:aDialogs[3], aHGFE, aCGFE)
oGFE:oBrowse:align   := CONTROL_ALIGN_ALLCLIENT
oGFE:oBrowse:bDelete := {|| IIf(FS_AltPre(2, .T.), oGfe:DELLINE(), .F.)}
//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIf(HS_CpoObr(aSGets, aSTela, {"RA_CODIGO"}), (nOpcA := 1, oDlg:End()), .F.)}, ;
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| (nOpcA := 1, IIf(FS_CNSDUP(), oDlg:End(),nOpcA := 0))}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpca == 1
	Begin Transaction
	FS_GrvA24(nOpcA24, @lAltPre)
	If !lErro
		FS_GrvGFB(nOpcA24)
		FS_GrvGFP(nOpcA24)
		FS_GrvGFE(@lAltPre,nOpcA24)
	EndIf
	
	// Colocado para desabilitar a validacao da alteracao do prestador que por enquanto
	// nao sera feita e deveremos avaliar melhor essa situa็ao, com vigencia ou algo parecido
	//If lAltPre
	// HS_GrvCPre(SRA->RA_CODIGO)
	//EndIf
	lErro := .F.
	End Transaction
	
	While __lSx8
		ConfirmSx8()
	End
Else
	While __lSx8
		RollBackSx8()
	End
EndIf
Return(.T.)

Static Function FS_GrvA24(nOpcA24, lAltPre)
Local lAchouSra := .F., lAchouGbj := .F.

If StrZero(aRotina[nOpcA24, 4], 2) $ "03/04"
	Altera := .T.
EndIf

If aRotina[nOpcA24, 4] # 2 // nao for consulta
	DbselectArea("SRA")
	DbSetOrder(1) // RA_FILIAL + RA_MAT
	lAchouSra := DBSeek(xFilial("SRA") + M->RA_MAT)
	
	If Inclui .or. Altera
		
		//GRAVA CADASTRO DE FUNCIONARIOS  -- SRA
		RecLock("SRA", .F.)
		SRA->RA_CODIGO := M->GBJ_CRM
		MsUnlock()
		
//		If !Empty(AllTrim(M->RA_CODIGO))
			//GRAVA DADOS ADICIONAIS DO CADASTRO DE FUNCIONARIOS  -- GBJ
			DbSelectArea("GBJ")
			DbSetOrder(1)//GBJ_FILAL + GBJ_CRM
			lAchouGbj := DbSeek(xFilial("GBJ") + M->RA_CODIGO)
			
			If lAchouGbj .And. GBJ->GBJ_CODPRE <> M->GBJ_CODPRE
				lAltPre := .T.
			EndIf
			
			RecLock("GBJ", !lAchouGbj)
			HS_GRVCPO("GBJ")
			GBJ->GBJ_FILIAL := xFilial("GBJ")
			MsUnlock()
			DbSelectArea("SRA")
//		EndIf
	Else  // exclusao                                                            
		If !FS_VerProf(M->RA_CODIGO) // Caso o profissional tenha lancamentos nใo exclui
			HS_MSGINF(STR0027,STR0011,STR0028) //"Esse profissional nใo pode ser excluido pois o mesmo esta sendo utilizado por outros registros de lancamentos no sistema!""Aten็ใo" "Valida็ใo Exclusใo"
			DisarmTransaction()
			lErro := .T.
			Return(Nil)
		EndIf                                                                           		
		If lAchouSra
			//APAGA O CRM DO CADASTRO DE FUNCIONARIOS  -- SRA
			RecLock("SRA", .F.)
				SRA->RA_CODIGO := Space(Len(SRA->RA_CODIGO))
			MsUnlock()
			// verifica se funcionario tem dados adicionais (GBJ) se tiver exclui			
			DbSelectArea("GBJ")
			DbSetOrder(1)//GBJ_FILAL + GBJ_CRM
			If DbSeek(xFilial("GBJ") + M->RA_CODIGO)
				RecLock("GBJ", .F., .T.)
				DBDelete()
				MsUnlock()
				WriteSx2("GBJ")
			EndIf
		Endif
	Endif
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA24  บAutor  ณRogerio Tabosa      บ Data ณ  18/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica a existencia de lancamentos e atendimentos        บฑฑ
ฑฑบ          ณ para o profissional a ser excluido                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑบ          ณ cCrm = Codigo do CRM do medico a ser verificado            บฑฑ
ฑฑบ          ณ aTables=Vetor com os alias das tabelas a serem verificadas บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VerProf(cCrm,aTables)  
Local aArea 	:= GetArea() 
Local cSql      := ""
Local lRet      := .T.
Local nLin		:= 0

Default aTables :=    {	{"GCY","_CODCRM"},;
						{"GD5","_CODCRM"},;
						{"GD6","_CODCRM"},;
						{"GD7","_CODCRM"},;
						{"GE5","_CODCRM"},;
						{"GE6","_CODCRM"},;
						{"GE7","_CODCRM"}}

For nLin := 1 to Len(aTables)
	cSql := "SELECT 1 FROM " + RetSqlName(aTables[nLin,1]) 
	cSql += " WHERE " + aTables[nLin,1] + aTables[nLin,2] + " = '" + cCrm + "' AND " + aTables[nLin,1] 
	cSql += "_FILIAL = '" + xFilial(aTables[nLin,1]) + "' AND D_E_L_E_T_ <> '*' "
	
	cSQL := ChangeQuery(cSQL)
	TCQUERY cSQL NEW ALIAS "QRYVRF"	
	
	If !QRYVRF->(Eof())
		QRYVRF->(DbCloseArea())
		lRet := .F.
		Exit
	EndIf 
	QRYVRF->(DbCloseArea())
Next nLin


RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA24  บAutor  ณMicrosiga           บ Data ณ  28/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VldA24()
Local lRet      := .T.
Local nPosACols := 0
Local cCampo    := ReadVar()

If cCampo == "M->GBJ_CODPRE"
	If !Empty(M->GBJ_CODPRE) .And. !(lRet := FS_AltPre(1))
		HS_MsgInf(STR0012, STR0011, STR0018) //"Prestador nใo pode ser alterado porque ja existem depesas faturadas pra ele"###"Aten็ใo"###"Cadastro de Profisionais"
	ElseIf !Empty(M->GBJ_CODPRE) .And. !(lRet := HS_SeekRet("GAZ", "M->GBJ_CODPRE", 1, .F., "GBJ_NOMPRE", "GAZ_FANPRE"))
		HS_MsgInf(STR0013, STR0011, STR0018) //"Prestador nใo cadastrado"###"Aten็ใo"###"Cadastro de Profissionais"
	EndIf
	
ElseIf cCampo == "M->GBJ_CODPRO"
	If !Empty(M->GBJ_CODPRO) .And. !(lRet := HS_SeekRet("GA7", "M->GBJ_CODPRO", 1, .F., "GBJ_DESCPR", "GA7_DESC"))
		HS_MsgInf(STR0014, STR0011, STR0018) //"Procedimento nใo encontrado"###"Aten็ใo"###"Cadastro de Profissionais"
	ElseIf !(lRet := GA7->GA7_CODESP $ M->GBJ_ESPEC1 + "/" + M->GBJ_ESPEC2 + "/" + M->GBJ_ESPEC3)
		If (!(lRet := aScan(oGFP:aCols, {| aVet | AllTrim(aVet[nGFPCodEsp]) == GA7->GA7_CODESP }) > 0 ))
			HS_MsgInf(STR0015, STR0011, STR0018) //"Procedimento nใo permitido para a especialidade do m้dico"###"Aten็ใo"###"Cadastro de Profissionais"
		Endif
	EndIf
	
ElseIf cCampo == "M->GBJ_CPROPA"
	If !Empty(M->GBJ_CPROPA) .And. !(lRet := HS_SeekRet("GA7","M->GBJ_CPROPA",1,.f.,"GBJ_DPROPA","GA7_DESC"))
		HS_MsgInf(STR0014, STR0011, STR0018) //"Procedimento nใo encontrado"###"Aten็ใo"###"Cadastro de Profissionais"
	EndIf            

ElseIf cCampo $ ("M->GBJ_ESPEC1##M->GBJ_ESPEC2##M->GBJ_ESPEC3")
 If !(lRet := HS_SeekRet("GFR", cCampo, 1, .F.))
  HS_MsgInf(STR0021, STR0011, STR0018) //"Especialidade nใo encontrada"###"Aten็ใo"###"Cadastro de Profissionais"
 ElseIf (!Empty(M->GBJ_ESPEC1) .And. !Empty(M->GBJ_ESPEC2) .And. M->GBJ_ESPEC1 == M->GBJ_ESPEC2) .Or.;
        (!Empty(M->GBJ_ESPEC1) .And. !Empty(M->GBJ_ESPEC3) .And. M->GBJ_ESPEC1 == M->GBJ_ESPEC3) .Or.;
        (!Empty(M->GBJ_ESPEC2) .And. !Empty(M->GBJ_ESPEC3) .And. M->GBJ_ESPEC2 == M->GBJ_ESPEC3) .Or.;
        aScan(oGFP:aCols, {| aVet | aVet[nGFPCodEsp] == &(cCampo) }) <> 0
  HS_MsgInf(STR0024, STR0011, STR0018) //"Especialidade duplicada"###"Aten็ใo"###"Cadastro de Profissionais"
  lRet := .F.
 EndIf	       
 
ElseIf cCampo == "M->GFE_CODLOC"
	If !Empty(M->GFE_CODLOC) .And. !(lRet := HS_SeekRet("GCS", "M->GFE_CODLOC", 1, .f., "GFE_NOMLOC", "GCS_NOMLOC"))
		HS_MsgInf(STR0016, STR0011, STR0018) //"Setor nใo encontrado"###"Aten็ใo"###"Cadastro de Profissionais"
	ElseIf ((nPosACols := aScan(oGFE:aCols, {| aVet | aVet[nGFECodLoc] == M->GFE_CODLOC})) > 0)	.And. (nPosACols <> oGFE:nAt)
		HS_MsgInf(STR0017, STR0011, STR0018) //"Informacao ja cadastrada!"###"Atencao"###"Cadastro Profissional"
		lRet := .F.
	ElseIf !(lRet := FS_AltPre(2))
		HS_MsgInf(STR0019, STR0011, STR0018)  //"Relacionamento ja esta sendo utilizado em despesas faturadas"###"Atencao"###"Cadastro Profissional"
	EndIf
	
ElseIf cCampo == "M->GFE_CODPRE"
	If !Empty(M->GFE_CODPRE) .And. !(lRet := HS_SeekRet("GAZ", "M->GFE_CODPRE", 1, .f., "GFE_NOMPRE", "GAZ_FANPRE"))
		HS_MsgInf(STR0020, STR0011, STR0018) //"Prestador nใo encontrado"###"Aten็ใo"###"Cadastro de Profissionais"
	ElseIf !(lRet := FS_AltPre(2))
		HS_MsgInf(STR0019, STR0011, STR0018) //"Relacionamento ja esta sendo utilizado em despesas faturadas"###"Atencao"###"Cadastro Profissional"
	EndIf
	
ElseIf cCampo == "M->GBJ_CODLOC" .And. !Empty(M->GBJ_CODLOC) // Validacao do setor que o medico utiliza para realizar um agendamento apartir da anamnese //
	If !(lRet := HS_SeekRet("GCS", "M->GBJ_CODLOC", 1, .F., "GBJ_NOMLOC", "GCS_NOMLOC")) 
		HS_MsgInf(STR0016, STR0011, STR0018) //"Setor nใo encontrado"###"Aten็ใo"###"Cadastro de Profissionais"
	ElseIf !(lRet := (GCS->GCS_IDEATI == "1"))
		HS_MsgInf(STR0025, STR0011, STR0018) //"Setor informado nใo esta ativo"###"Aten็ใo"###"Cadastro de Profissionais"		
	ElseIf !(lRet := (GCS->GCS_TIPLOC == "5"))
		HS_MsgInf(STR0026, STR0011, STR0018) //"Setor informado deve ser do tipo marca็ใo"###"Aten็ใo"###"Cadastro de Profissionais"	
	EndIf
EndIf
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_GrvGFB ณ Autor ณ MARCELO JOSE          ณ Data ณ 31.08.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ GRAVA ARQUIVO DE TELEFONES DO PROFISSIONAL  NEWGET FOLDER 2ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGFB(nOpcA24)
Local nItem 				:= 0
Local cAliasOld := Alias(), lAchou := .F.
Local cGfbNumTel := ""

For nItem := 1 To Len(oGFB:aCols)
	cGfbNumTel := StrTran(oGFB:aCols[nItem, nGFBNumTel], "(", "")
	cGfbNumTel := StrTran(oGFB:aCols[nItem, nGFBNumTel], ")", "")
	cGfbNumTel := StrTran(oGFB:aCols[nItem, nGFBNumTel], "-", "")
	
	DbSelectArea("GFB")
	DbSetOrder(1)// GFB_FILIAL + GFB_CODPRO + GFB_SEQFON
	lAchou := IIf(!Empty(oGFB:aCols[nItem, nGFBSeqFon]), DbSeek(xFilial("GFB") + M->GBJ_CRM + oGFB:aCols[nItem, nGFBSeqFon]), .F.)
	If (oGFB:aCols[nItem, Len(oGFB:aCols[nItem])] .And. lAchou) .OR. StrZero(aRotina[nOpcA24, 4], 2) $ "05" /* exclusao */
		RecLock("GFB", .F., .T.)
		DbDelete()
		MsUnlock()
		WriteSx2("GFB")
	Else
		If !Empty(AllTrim(cGfbNumTel))
			RecLock("GFB", !lAchou)
			HS_GRVCPO("GFB", oGFB:aCols, oGFB:aHeader, nItem)
			GFB->GFB_FILIAL := xFilial("GFB")
			GFB->GFB_CODPRO := M->GBJ_CRM
			GFB->GFB_LOGARQ := HS_LogArq()
			MsUnlock()
		EndIf
	EndIf
Next

DbSelectArea(cAliasOld)
Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_GrvGFP ณ Autor ณ MARCELO JOSE          ณ Data ณ 24.02.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ GRAVA ARQUIVO DE ESPECIALIDADES MEDICAS                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGFP(nOpcA24)
Local nItem 				:= 0
Local cAliasOld := Alias(), lAchou := .F.


For nItem := 1 To Len(oGFP:aCols)
	
	DbSelectArea("GFP")
	DbSetOrder(1)// GFP_FILIAL + GFP_CODCRM + GFP_ITEESP
	lAchou := IIf(!Empty(oGFP:aCols[nItem, nGFPSeqEsp]), DbSeek(xFilial("GFP") + M->GBJ_CRM + oGFP:aCols[nItem, nGFPSeqEsp]), .F.)
	If (oGFP:aCols[nItem, Len(oGFP:aCols[nItem])] .And. lAchou) .OR. StrZero(aRotina[nOpcA24, 4], 2) $ "05" /* exclusao */
		RecLock("GFP", .F., .T.)
		DbDelete()
		MsUnlock()
		WriteSx2("GFP")
	Else
		If !Empty(oGFP:aCols[nItem, nGFPCodEsp]) .and. !oGFP:aCols[nItem, Len(oGFP:aCols[nItem])] 
			RecLock("GFP", !lAchou)
			HS_GRVCPO("GFP", oGFP:aCols, oGFP:aHeader, nItem)
			GFP->GFP_FILIAL := xFilial("GFP")
			GFP->GFP_CODCRM := M->GBJ_CRM
			GFP->GFP_LOGARQ := HS_LogArq()
		EndIf
	EndIf
Next

DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_GrvGFE ณ Autor ณ Daniel Peixoto        ณ Data ณ 19.10.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ GRAVA ARQUIVO DE PRESTADORES POR PROFISSIONAL              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGFE(lAltPre,nOpcA24)
Local nItem 				:= 0
Local cAliasOld := Alias()
Local lAchou    := .F.

For nItem := 1 To Len(oGFE:aCols)
	
	DbSelectArea("GFE")
	DbSetOrder(1)// GFE_FILIAL + GFE_CODCRM + GFE_SEQCRM
	lAchou := IIf(!Empty(oGFE:aCols[nItem, nGFESeqCRM]), DbSeek(xFilial("GFE") + M->GBJ_CRM + oGFE:aCols[nItem, nGFESeqCRM]), .F.)
	If (oGFE:aCols[nItem, Len(oGFE:aCols[nItem])] .And. lAchou) .OR. StrZero(aRotina[nOpcA24, 4], 2) $ "05"/* exclusao */
		lAltPre := .T.
		
		RecLock("GFE", .F., .T.)
		DbDelete()
		MsUnlock()
		WriteSx2("GFE")
	Else
		If !EMPTY(oGFE:aCols[nItem, nGFECodLoc]) .And. !EMPTY(oGFE:aCols[nItem, nGFECodPre])
			If !lAchou .Or. (GFE->GFE_CODLOC <> oGFE:aCols[nItem, nGFECodLoc] .Or. GFE->GFE_CODPRE <> oGFE:aCols[nItem, nGFECodPre])
				lAltPre := .T.
			EndIf
			
			RecLock("GFE", !lAchou)
			HS_GRVCPO("GFE", oGFE:aCols, oGFE:aHeader, nItem)
			GFE->GFE_FILIAL := xFilial("GFE")
			GFE->GFE_CODCRM := M->GBJ_CRM
			MsUnlock()
		EndIf
	EndIf
Next

DbSelectArea(cAliasOld)
Return(Nil)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DescA24บ Autor ณ Daniel Peixoto     บ Data ณ  19/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao dos campos de descricao.               บฑฑ
ฑฑบ          ณ Chamada do X3_RELACAO do campo de Acordo com o Parametro   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_DescA24(cAlias, nCpo)
Local cCodChave := ""
Local cDescri     := ""

If cAlias == "GFE"
	If nCpo == 1
		cCodChave := IIf(Inclui, "", IIf(Alias() == "TMPGFE", (Alias())->GFE_CODLOC, ""))
		If !EMPTY(cCodChave)
			cDescri := HS_IniPadr("GCS", 1, cCodChave, "GCS_NOMLOC")
		EndIf
	ElseIf  nCpo == 2
		cCodChave := IIf(Inclui, "", IIf(Alias() == "TMPGFE", (Alias())->GFE_CODPRE, ""))
		If !EMPTY(cCodChave)
			cDescri := HS_IniPadr("GAZ", 1, cCodChave, "GAZ_FANPRE")
		EndIf
	EndIf
	
EndIf

Return(cDescri)

Static Function FS_AltPre(nOpcAlt, lPressDel)
Local lRet := .T.
Local cSQL := ""
Local aArea := GetArea()
Local lAchouGfe := .F.

Default lPressDel := .F.

Return(lRet) // Colocado para desabilitar a validacao da alteracao do prestador que por enquanto
// nao sera feita e deveremos avaliar melhor essa situa็ao, com vigencia ou algo parecido

If !Inclui
	
	If nOpcAlt == 2
		DbSelectArea("GFE")
		DbSetOrder(1)// GFE_FILIAL + GFE_CODCRM + GFE_SEQCRM
		lAchouGfe := DbSeek(xFilial("GFE") + M->GBJ_CRM + oGFE:aCols[oGFE:nAt, nGFESeqCrm])
		If lPressDel .And. !lAchouGfe
			RestArea(aArea)
			Return(.T.)
		EndIf
	EndIf
	
	cSQL := "SELECT 'GD' TIPO, COUNT(*) CNTDESP"
	cSQL += " FROM " + RetSQLName("GD7") + " GD7 "
	cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_STATUS > '3'"
	cSQL += " WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
	cSQL += " AND GD7.GD7_CODCRM = '" + M->GBJ_CRM + "' "
	
	If nOpcAlt == 1
		cSQL += " AND GD7.GD7_CODPRE = '" + GBJ->GBJ_CODPRE + "' "
	Else
		If lAchouGfe
			cSQL += " AND GD7.GD7_CODLOC = '" + GFE->GFE_CODLOC + "' "
			cSQL += " AND GD7.GD7_CODPRE = '" + GFE->GFE_CODPRE + "' "
		Else
			cSQL += " AND GD7.GD7_CODLOC = '" + oGFE:aCols[oGFE:nAt, nGFECodLoc] + "' "
		EndIf
	EndIf
	
	cSQL += "UNION ALL"
	cSQL += " SELECT 'GE' TIPO, COUNT(* ) CNTDESP"
	cSQL += " FROM " + RetSQLName("GE7") + " GE7 "
	cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_STATUS > '3'"
	cSQL += " WHERE GE7.GE7_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
	cSQL += " AND GE7.GE7_CODCRM = '" + M->GBJ_CRM + "' "
	
	If nOpcAlt == 1
		cSQL += " AND GE7.GE7_CODPRE = '" + GBJ->GBJ_CODPRE + "' "
	Else
		If lAchouGfe
			cSQL += " AND GE7.GE7_CODLOC = '" + GFE->GFE_CODLOC + "' "
			cSQL += " AND GE7.GE7_CODPRE = '" + GFE->GFE_CODPRE + "' "
		Else
			cSQL += " AND GE7.GE7_CODLOC = '" + oGFE:aCols[oGFE:nAt, nGFECodLoc] + "' "
		EndIf
	EndIf
	
	cSQL := ChangeQuery(cSQL)
	
	DBUseArea(.T., "TOPCONN", TcGenQry(,, cSQL), "QRYDESP", .F., .T.)
	
	DbSelectArea("QRYDESP")
	DbGoTop()
	
	While !EOF()
		If QRYDESP->CNTDESP > 0
			lRet := .F.
		End
		DBSkip()
	EndDo
	
	DbCloseArea()
	
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_GrvGFP ณ Autor ณ MARCELO JOSE          ณ Data ณ 24.02.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ GRAVA ARQUIVO DE ESPECIALIDADES MEDICAS                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VLDE24()
 Local lRet := .T.

 If lGFR
 	lRet := HS_SEEKRET("GFR","M->GFP_CODESP",1,.F.,"GFP_NOMESP","GFR_DSESPE")
 Else
 	lRet := HS_SEEKRET("SX5","'EM'+M->GFP_CODESP",1,.F.,"GFP_NOMESP","X5_DESCRI")
 EndIf

 If !lRet
 	HS_MsgInf(STR0021, STR0011, STR0010) //"Especialidade NAO encontrada..."###"Atencao"###"Especialidades Medicas"
 Else
 	lRet := HS_VldGD(M->GFP_CODESP)
 EndIf
 
 If lRet
  If M->GFP_CODESP == M->GBJ_ESPEC1 .Or. M->GFP_CODESP == M->GBJ_ESPEC2 .Or. M->GFP_CODESP == M->GBJ_ESPEC3
   HS_MsgInf(STR0024, STR0011, STR0018) //"Especialidade duplicada"###"Aten็ใo"###"Cadastro de Profissionais"
   lRet := .F.
  EndIf
 EndIf
 
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_VldGD  ณ Autor ณ Patricia Queiroz      ณ Data ณ 23/05/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida a duplicidade de registros no aCols para            ณฑฑ
ฑฑณ          ณ especialidade.                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldGD(cCodEsp)
Local nTot   := 0
Local nItem  := 0 

For nItem := 1 To Len(oGFP:aCols)
	If oGFP:aCols[nItem, nGFPCodEsp] == cCodEsp .And. !oGFP:aCols[nItem, Len(oGFP:aCols[nItem])]
		nTot++
	EndIf
Next nItem

If nTot > 0
	HS_MsgInf(STR0022, STR0011, STR0023) //"Especialidade jแ cadastrada!"###"Valida็ใo de Inclusใo"
	lRet := .F.
Else
	lRet := .T.
EndIf
Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 06/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui" , 0, 1, 0, nil}, ; //"Pesquisar"
                     {OemtoAnsi(STR0003), "HS_MntA24", 0, 2, 0, nil}, ; //"Visualizar"
                     {OemtoAnsi(STR0005), "HS_MntA24", 0, 4, 0, nil}, ; //"Alterar"
                     {OemtoAnsi(STR0006), "HS_MntA24", 0, 5, 0, nil}}   //"Excluir"
                     
//{OemtoAnsi(STR0004), "HS_MntA24", 0, 3, 0, nil}, ; //"Incluir"                     
Return(aRotina)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_GerHelpบAutor  ณMicrosiga           บ Data ณ  11/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fs_GerHelp(aCposHelp)

 Local aHelp := {}, aHelpE := {}, aHelpI := {} 
 Local cHelp := ""
 Local nI    := 0
 
 For nI := 1 to Len(aCposHelp) 
  aHelp := aClone(aCposHelp[nI][2])

 	aHelpE := {} 

	 aHelpI := {}

	 cHelp := aCposHelp[nI][1]

	 PutSx1Help("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)
 Next

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CNSDUP บ       ณRogerio Tabosa      บ Data ณ  15/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada para validaco do campo numero CNS se o    บฑฑ
ฑฑบ          ณ mesmo informado jแ existe para outro paciente/Profissional.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CNSDUP()
Local aAreaOld 	:= GetArea()
Local lRet     	:= .T.
Local lVldCnsPP	:= GetNewPar("MV_VLCNSPP",.T.) //Informa se deseja bloquear a grava็ใo na valida็ใo de duplicidade do CNS para o Paciente e Profissional (.T. = Sim - Padrao /.F. = Nao)

If !Empty(M->GBJ_CODCNS)
	If HS_CountTB("GBH", "GBH_NUMCNS ='" + M->GBJ_CODCNS +"'") > 0
		HS_MSGINF(STR0029,STR0011, STR0018) // "O CNS informado jแ foi atribuido para um paciente!"
		lRet := IIf (lVldCnsPP,.F.,.T.)
	ElseIf 	HS_CountTB("GD4", "GD4_MATRIC ='" + M->GBJ_CODCNS +"'") > 0
		HS_MSGINF(STR0029,STR0011, STR0018)
		lRet := IIf (lVldCnsPP,.F.,.T.)
	ElseIf 	HS_CountTB("GBJ", "GBJ_CODCNS ='" + M->GBJ_CODCNS +"' AND GBJ_CRM <> '" + M->GBJ_CRM + "'") > 0
		HS_MSGINF(STR0030,STR0011, STR0018) // "O CNS informado jแ foi atribuido para outro profissional!"
		lRet := IIf (lVldCnsPP,.F.,.T.)
	EndIf
EndIf

RestArea(aAreaOld)
Return(lRet) 
