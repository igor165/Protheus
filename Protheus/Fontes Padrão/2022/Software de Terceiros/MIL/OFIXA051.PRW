// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "OFIXA051.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXA051   | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Cadastro de Contas do DEF                                    |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA051()
//

Private cCadastro := STR0001
Private aRotina   := MenuDef()

//
// Validacao de Licencas DMS
//
If !OFValLicenca():ValidaLicencaDMS()
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VD9")
dbSetOrder(1)
//
mBrowse( 6, 1,22,75,"VD9")
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA051V    | Autor |                       | Data |          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA051V(cAlias,nReg,nOpc)
Local lRet := .f.
//
lRet = OXA051(NIL,NIL,2)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA051I    | Autor |                       | Data |          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA051I(cAlias,nReg,nOpc)
Local lRet := .f.
//
lRet = OXA051(NIL,NIL,3)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA051A    | Autor |                       | Data |          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA051A(cAlias,nReg,nOpc)
Local lRet := .f.
//
lRet = OXA051(NIL,NIL,4)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA051E    | Autor |                       | Data |          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA051E(cAlias,nReg,nOpc)
Local lRet := .f.
//
lRet = OXA051(NIL,NIL,5)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA051     | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |  Montagem da Tela                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA051(xAutoCab,xAutoItens, nOpc)

Private aAutoCab   := {} 	// Cabecalho da Integracao
Private aAutoItens := {}	// Itens da Integracao
Private lAutomat   := ( xAutoCab <> NIL  .and. xAutoItens <> NIL )
Private aNewBot    := {}

//######################################################################################
//# Se for detectado que trata-se de integracao faz os vetores receberem os parametros #
//######################################################################################
If lAutomat
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
EndIf

// #####################################################
// # Na integracao as variaveis abaixo nao existirao,  #
// # por isso precisamos carrega-las manualmente       #
// #####################################################
VISUALIZA := (nOpc == 2)
INCLUI    := (nOpc == 3)
ALTERA    := (nOpc == 4)
EXCLUI    := (nOpc == 5)
//#############################################################################
//# Chama a tela                                                              #
//#############################################################################
DBSelectArea("VD9")
lRet := OXX051(alias(),Recno(),nOpc)
//
Return lRet

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Fun‡„o    |    OXA051   | Autor | Luis Delorme         | Data | 30/04/12 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descri‡„o | Tela Principal                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXX051(cAlias,nReg,nOpc)
Local nCntFor, nCntFor1, nCntFor2, nCntFor3, nCntFor4
Local aObjsPrin 	:= {}
Local aSizeAut		:= MsAdvSize(.t.)

//################################################################
//# Variaveis da Enchoice                                        #
//################################################################
Local aCpos      := {}
Local nModelo    := 1
Local lF3        := .f.
Local lMemoria   := .t.
Local lColumn    := .f.
Local cATela     := ""
Local lNoFolder  := .t.
Local lProperty  := .f.

// Variavel que armazena os campos que serao mostrados pela enchoice
Private aCpoEncS := {}
//################################################################
//# Especifica o espacamento entre os objetos principais da tela #
//################################################################
// 					{ LARGURA,	ALTURA,	AUTOSIZE LARGURA,	AUTOSIZE ALTURA	} )
AAdd( aObjsPrin, 	{ 0,		115,		.T.,				.F. 			} )
AAdd( aObjsPrin, 	{ 0,		 40,		.T.,				.T. 			} )
AAdd( aObjsPrin, 	{ 0,		 40,		.T.,				.T. 			} )
//					{	LINHA INICIAL	COLUNA INICIAL	LINHA FINAL		COLUNA FINAL	MARGEM HORIZONTAL	MARGEM VERTICAL }
aInfo         := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObjsPrin  := MsObjSize( aInfo, aObjsPrin )

//###############################################
//# Cria variaveis M->????? da Enchoice do PAI  #
//###############################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VD9")
aCpos := {} // ARRAY DE CAMPOS DA ENCHOICE EDITAVEIS
While !SX3->(Eof()) .AND. (SX3->X3_ARQUIVO == "VD9")
	// MONTA OS CAMPOS QUE APARECERAO NA DA ENCHOICE
	If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
		AADD(acpoEncS,SX3->X3_CAMPO)
	EndIf

	// MONTA VARIAVEIS DE MEMORIA QUE ARMAZENAM AS INFORMACOES DA ENCHOICE
	If Inclui
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		If SX3->X3_CONTEXT == "V"
			&("M->"+SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
		Else
			&("M->"+SX3->X3_CAMPO) := &("VD9->"+SX3->X3_CAMPO)
		EndIf
	EndIf

	// MONTA CAMPOS EDITAVEIS
	If SX3->X3_CONTEXT != "V"
		aAdd(aCpos,SX3->X3_CAMPO)
	endif
	DbSkip()
Enddo
//###################################################################
//# Cria variaveis de memoria, aHeader e aCols da MsNewGetDados 1   #
//###################################################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VDA")
//
aHeaderF1    := {} // ARRAY DE CAMPOS DA MSNEWGETDADOS
aAlterF1     := {} // ARRAY DE CAMPOS DA MSNEWGETDADOS EDITAVEIS
aColsF1      := {} // ITENS DA MSNEWGETDADOS
cFIL1nMostra := "VDA_CODDEF,VDA_CODCON,"	// CAMPOS QUE NAO APARECERAO NA MSNEWGETDADOS
nUsadoF1     := 0
cX3FilEm     := "0=N/A;"
aFilComp     := {}

aGrp := FWAllGrpCompany()
for nCntFor1 := 1 to Len(aGrp)
	cGrupo := aGrp[nCntFor1]
	aEmp   := FWAllCompany(cGrupo)

	if Len(aEmp) == 0
		aAdd(aEmp, "")
	endif

	for nCntFor2 := 1 to Len(aEmp)
		cEmp := aEmp[nCntFor2]
		aUni := FWAllUnitBusiness(cEmp,cGrupo)

		if Len(aUni) == 0
			aAdd(aUni, "")
		endif

		for nCntFor3 := 1 to Len(aUni)
			cUnidade := aUni[nCntFor3]
			aFil := FWAllFilial(cEmp, cUnidade, cGrupo)

			for nCntFor4 := 1 to Len(aFil)
				cFilial := aFil[nCntFor4]
				cNomeFil := FWFilialName(cGrupo, cEmp + cUnidade +  cFilial, 2)

				if ! Empty(cNomeFil)
					if Ascan(aFilComp, { |x| x[1] + x[2] + x[3] + x[4] == cGrupo + cEmp + cUnidade + cFilial }) == 0
						aAdd(aFilComp, {;
							cGrupo    ,; //1
							cEmp      ,; //2
							cUnidade  ,; //3
							cFilial   ,; //4
							cNomeFil   ; //5
						})
						cX3FilEm += Left(cGrupo+cUnidade+cFilial+SPACE(8), Len(VDA->VDA_ACUMEM)) + "=" + Alltrim(cNomeFil)+";"
					endif
				endif

			next
		next
	next
next

While !SX3->(Eof()) .AND. (SX3->X3_ARQUIVO == "VDA")
	If  X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL .and. !(Alltrim(SX3->X3_CAMPO)+"," $ cFIL1nMostra)
		nUsadoF1 := nUsadoF1+1

		Aadd(aHeaderF1,{;
			AllTrim(X3Titulo()),; // 01
			SX3->X3_CAMPO      ,; // 02
			SX3->X3_PICTURE    ,; // 03
			SX3->X3_TAMANHO    ,; // 04
			SX3->X3_DECIMAL    ,; // 05
			SX3->X3_VALID      ,; // 06
			SX3->X3_USADO      ,; // 07
			SX3->X3_TIPO       ,; // 08
			SX3->X3_F3         ,; // 09
			SX3->X3_CONTEXT    ,; // 10
			IIF(Alltrim(SX3->X3_CAMPO) == "VDA_ACUMEM",cX3FilEm,X3CBOX()),; // 11
			SX3->X3_RELACAO    ,; // 12
			".T."               ; // 13
		})

		if SX3->X3_USADO != "V" .and. (INCLUI .or. ALTERA)
			aAdd(aAlterF1,SX3->X3_CAMPO)
		endif
	EndIf
	DbSkip()
EndDo

If INCLUI
	aColsF1 := { Array(nUsadoF1 + 1) }
	aColsF1[1,nUsadoF1+1] := .F.
	For nCntFor:=1 to nUsadoF1
		aColsF1[1,nCntFor]:=CriaVar(aHeaderF1[nCntFor,2])
	Next
Else
	aColsF1 := {}
	// POSICIONAMENTO DA TABELA FILHO
	dbSelectArea("VDA")
	dbSetOrder(1)
	dbSeek(xFilial("VDA") + VD9->VD9_CODDEF + VD9->VD9_CODCON)
	// LACO DA TABELA FILHO
	While !eof() .and. VDA->VDA_FILIAL + VDA->VDA_CODDEF  + VDA->VDA_CODCON == xFilial("VDA") + VD9->VD9_CODDEF + VD9->VD9_CODCON
		AADD(aColsF1,Array(nUsadoF1+1))
		For nCntFor:=1 to nUsadoF1
			if aHeaderF1[nCntFor,10] == "V"
				SX3->(DBSetOrder(2))
				SX3->(DBSeek(aHeaderF1[nCntFor,2]))
				aColsF1[Len(aColsF1),nCntFor] := &(SX3->X3_RELACAO)
			else
				aColsF1[Len(aColsF1),nCntFor] := FieldGet(FieldPos(aHeaderF1[nCntFor,2]))
			endif
		Next
		aColsF1[Len(aColsF1),nUsadoF1+1] := .F.
		DbSkip()
	EndDo
EndIf

RegToMemory("VDA",IIF(nopc==3,.t.,.f.))
//###################################################################
//# Cria variaveis de memoria, aHeader e aCols da MsNewGetDados 2   #
//###################################################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VDE")
//
aHeaderF2		:= {}	// ARRAY DE CAMPOS DA MSNEWGETDADOS
aAlterF2 		:= {}	// ARRAY DE CAMPOS DA MSNEWGETDADOS EDITAVEIS
aColsF2 		:= {}	// ITENS DA MSNEWGETDADOS
cFIL2nMostra 	:= "VDE_CODDEF,VDE_CODCON,"	// CAMPOS QUE NAO APARECERAO NA MSNEWGETDADOS
//
nUsadoF2 := 0
//
While !SX3->(Eof()) .AND. (SX3->X3_ARQUIVO == "VDE")
	If  X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .and. !(Alltrim(SX3->X3_CAMPO)+"," $ cFIL2nMostra)
		nUsadoF2 := nUsadoF2+1

		Aadd(aHeaderF2,{;
			AllTrim(X3Titulo()),; // 01
			SX3->X3_CAMPO      ,; // 02
			SX3->X3_PICTURE    ,; // 03
			SX3->X3_TAMANHO    ,; // 04
			SX3->X3_DECIMAL    ,; // 05
			SX3->X3_VALID      ,; // 06
			SX3->X3_USADO      ,; // 07
			SX3->X3_TIPO       ,; // 08
			SX3->X3_F3         ,; // 09
			SX3->X3_CONTEXT    ,; // 10
			X3CBOX()           ,; // 11
			SX3->X3_RELACAO    ,; // 12
			".T."               ; // 13
		})

		if SX3->X3_USADO != "V" .and. (INCLUI .or. ALTERA)
			aAdd(aAlterF2, SX3->X3_CAMPO)
		endif
	EndIf
	DbSkip()
EndDo

// Cria aCols
If INCLUI
	aColsF2 := { Array(nUsadoF2 + 1) }
	aColsF2[1,nUsadoF2+1] := .F.
	For nCntFor := 1 to nUsadoF2
		aColsF2[1,nCntFor] := CriaVar(aHeaderF2[nCntFor,2])
	Next
Else
	aColsF2 := {}

	// POSICIONAMENTO DA TABELA FILHO
	dbSelectArea("VDE")
	dbSetOrder(1)
	dbSeek(xFilial("VDE") + VD9->VD9_CODDEF + VD9->VD9_CODCON)

	// LACO DA TABELA FILHO
	While !eof() .and. VDE->VDE_FILIAL + VDE->VDE_CODDEF  + VDE->VDE_CODCON == xFilial("VDE") + VD9->VD9_CODDEF + VD9->VD9_CODCON
		AADD(aColsF2,Array(nUsadoF2+1))
		For nCntFor:=1 to nUsadoF2
			if aHeaderF2[nCntFor,10] == "V"
				SX3->(DBSetOrder(2))
				SX3->(DBSeek(aHeaderF2[nCntFor,2]))
				aColsF2[Len(aColsF2),nCntFor] := &(SX3->X3_RELACAO)
			else
				aColsF2[Len(aColsF2),nCntFor] := FieldGet(FieldPos(aHeaderF2[nCntFor,2]))
			endif
		Next
		aColsF2[Len(aColsF2),nUsadoF2+1] := .F.
		DbSkip()
	EndDo
EndIf

RegToMemory("VDE",IIF(nopc==3,.t.,.f.))

If lAutomat
	//################################################################
	//# Monta Enchoice e GetDados automaticamente para a integracao  #
	//################################################################
	If EnchAuto("VD9",aAutoCab)
		MsGetDAuto(aAutoItens,"OA051FLOK()",	{|| OA051TOK(nOpc).AND.OA051PROC(nOpc) },aAutoCab,nOpc)
	EndIf
Else
	//####################################################
	//# Montagem da tela                                 #
	//####################################################
	cF1LinOk    := "OA051LOK()"
	cF1FieldOk	:= "OA051FOK()"
	cF1TudoOk	  := "OA051TOK()"
	cF2LinOk	  := "OA051LOK2()"
	cF2FieldOk	:= "OA051FOK2()"
	cF2TudoOk	  := "OA051TOK()"

	//#####################################################
	//# Define a tela                                     #
	//#####################################################
	oDlg := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,,,,,.t.)

	//#####################################################
	//# Monta a enchoice do com os campos necessarios     #
	//#####################################################
	aPosEnchoice := aClone(aPosObjsPrin[1])
	oEnch := MSMGet():New( cAlias, nReg, nOpc, , , ,aCpoEncS, aPosEnchoice, aCpos, nModelo, , , , oDlg, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)

	//#############################################################################
	//# MsNewGetDados 1                                                           #
	//#############################################################################
	oGetDados1 := MsNewGetDados():New(aPosObjsPrin[2,1], aPosObjsPrin[2,2], aPosObjsPrin[2,3] ;
	,aPosObjsPrin[2,4],3,cF1LinOk,cF1TudoOk,,aAlterF1,0,Len(aColsF1),cF1FieldOk,,,oDlg,@aHeaderF1,@aColsF1 )
	oGetDados1:oBrowse:bDelete       := {||OA051DEL() }

	//#############################################################################
	//# MsNewGetDados 2                                                           #
	//#############################################################################
	oGetDados2 := MsNewGetDados():New(aPosObjsPrin[3,1], aPosObjsPrin[3,2], aPosObjsPrin[3,3] ;
	,aPosObjsPrin[3,4],3,cF2LinOk,cF2TudoOk,,aAlterF2,0,999,cF2FieldOk,,,oDlg,@aHeaderF2,@aColsF2 )
	oGetDados2:oBrowse:bDelete := { || OA051DEL2() }

	// ######################
	// # Ativacao da janela #
	// ######################
	oDlg:bInit := { || EnchoiceBar(oDlg, { || If(OA051TOK(nOpc),OA051PROC(nOpc),.t.) } , { || OA051SAIR(nOpc) },,aNewBot ) }
	oDlg:lCentered := .T.
	oDlg:Activate()
EndIf

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | OA051VLDE  | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Rotina de validacao da ENCHOICE a ser chamada no SX3 dos     |##
##|          | campos da tabela PAI                                         |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051VLDE()
Local cPrimEmp := "0"
if ! Empty(cX3FilEm)
	aValues := STRTOKARR(cX3FilEm, ';')
	if LEN(aValues) > 1
		cPrimEmp := STRTOKARR(aValues[2], '=')[1]
	end
end

// ############################################################################
If ReadVar() == "M->VD9_CODDEF"
	// ############################################################################
	if INCLUI
		// Nesse readvar precisamos popular as filiais que utilizam o def na acols a partir
		// das configurações das tabelas VD7/VD8 caso seja uma inclusão
		DBSelectArea("VD8")
		DBSetOrder(1)
		DBSeek(xFilial("VD8")+M->VD9_CODDEF)
		oGetDados1:aCols := {}
		while !eof() .and. xFilial("VD8")+M->VD9_CODDEF == VD8->VD8_FILIAL + VD8->VD8_CODDEF
			if VD8->VD8_ATIVO == "1"
				AADD(oGetDados1:aCols,Array(nUsadoF1+1))
				oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_CODFIL","aHeaderF1")] := VD8->VD8_CODFIL
				oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_CODEMP","aHeaderF1")] := VD8->VD8_CODEMP
				oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_DESFIL","aHeaderF1")] := FWFilialName(VD8->VD8_CODEMP, VD8->VD8_CODFIL)
				oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_ATIVO","aHeaderF1" )] := "1"
				oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_ACUMEM","aHeaderF1")] := cPrimEmp
				oGetDados1:aCols[Len(oGetDados1:aCols),nUsadoF1+1] := .f.
			endif
			DbSkip()
		EndDo 
		if Len(oGetDados1:aCols) == 0
			AADD(oGetDados1:aCols,Array(nUsadoF1+1))
			oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_CODFIL","aHeaderF1")] := ""
			oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_CODEMP","aHeaderF1")] := ""
			oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_DESFIL","aHeaderF1")] := ""
			oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_ATIVO","aHeaderF1" )] := ""
			oGetDados1:aCols[Len(oGetDados1:aCols),fg_posvar("VDA_ACUMEM","aHeaderF1")] := ""
			oGetDados1:aCols[Len(oGetDados1:aCols),nUsadoF1+1] := .f.
		Endif		
		n := 1
		oGetDados1:nAt := 1
		oGetDados1:oBrowse:Refresh()
	endif
EndIf

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA051FOK   | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK da MSGETDADOS                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051FOK()

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA051FOK2  | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK da MSGETDADOS                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051FOK2()

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA051LOK   | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | LinOK da MSNEWGETDADOS 1                                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051LOK()
Local nCntFor
Local lTudoBranco := .t.
// ############################################################
// # Pula registros deletados                                 #
// ############################################################
If oGetDados1:aCols[oGetDados1:nAt,len(oGetDados1:aCols[oGetDados1:nAt])]
	Return .t.
EndIf
// ############################################################
// # Verifica se trata-se de uma linha inteiramente em branco #
// ############################################################
For nCntFor:=1 to Len(aHeaderF1)
	if !Empty(oGetDados1:aCols[oGetDados1:nAt,nCntFor])
		lTudoBranco := .f.
	endif
Next
if lTudoBranco
	return .t.
endif
// ############################################################
// # Verifica campos obrigatorios                             #
// ############################################################
For nCntFor:=1 to Len(aHeaderF1)
	If X3Obrigat(aHeaderF1[nCntFor,2])  .and. (Empty(oGetDados1:aCols[oGetDados1:nAt,nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderF1[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA051LOK2  | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | LinOK da MSNEWGETDADOS 1                                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051LOK2()
Local nCntFor
// ############################################################
// # Verifica campos obrigatorios                             #
// ############################################################
For nCntFor:=1 to Len(aHeaderF2)
	If X3Obrigat(aHeaderF2[nCntFor,2])  .and. (Empty(oGetDados2:aCols[oGetDados2:nAt,nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderF2[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next

return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |   OA051TOK | Autor |                       | Data |          |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verifica se tudo esta preenchido corretamente                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051TOK(nOpc)
Local nCntFor
Local nVDECCTERP := FG_POSVAR("VDE_CCTERP", "aHeaderF2")
Local nVDEOPER   := FG_POSVAR("VDE_OPER"  , "aHeaderF2")
Local nVDETIPSAL := FG_POSVAR("VDE_TIPSAL", "aHeaderF2")


if EXCLUI
	return .t.
endif
// ############################################################
// # Verifica campos obrigatorios da Enchoice                 #
// ############################################################
For nCntFor:=1 to Len(acpoEncS)
	If X3Obrigat(acpoEncS[nCntFor]) .and. Empty(&("M->"+acpoEncS[nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(acpoEncS[nCntFor]),4,1)
		Return .f.
	EndIf
Next

// Validaçao campo VD9_Tipo = "3 - CCTERP"
If M->VD9_TIPO == "3"
	For nCntFor := 1 To Len(oGetDados2:aCols)
		// Campos VDE_CCTERP, VDE_OPER e VDE_TIPSAL obrigatórios
		If !oGetDados2:aCols[nCntFor, Len(oGetDados2:aCols[nCntFor])] .And.;
			(Empty(oGetDados2:aCols[nCntFor, nVDECCTERP]) .Or. Empty(oGetDados2:aCols[nCntFor, nVDEOPER]) .Or. Empty(oGetDados2:aCols[nCntFor, nVDETIPSAL]))
			MsgStop(STR0033 + ": " + AllTrim(RetTitle("VDE_CCTERP")) + ", " + AllTrim(RetTitle("VDE_OPER")) + ", " + AllTrim(RetTitle("VDE_TIPSAL")) + ".", STR0003) // Informe os campos obrigatórios / Atenção
			Return .f.
		EndIf
	Next
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------------------------------+------+----------+##
##|Fun‡„o    |  OA051DEL  |  Luis Delorme                 | Data | 30/04/12 |##
##+----------+------------+-------------------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051DEL()

return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------------------------------+------+----------+##
##|Fun‡„o    |  OA051DEL  |  Luis Delorme                 | Data | 30/04/12 |##
##+----------+------------+-------------------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051DEL2()

oGetDados2:aCols[oGetDados2:nAt,len(oGetDados2:aCols[oGetDados2:nAt])] := !oGetDados2:aCols[oGetDados2:nAt,len(oGetDados2:aCols[oGetDados2:nAt])]

return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |  OA051SAIR | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Processa a saida da rotina                                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA051SAIR(nOpc)
if nOpc == 2
	oDlg:End()
	return .t.
endif
if MsgYesNo(STR0002,STR0003)
	oDlg:End()
	return .t.
endif
//
return .f.
/*
===============================================================================
###############################################################################
##+----------+--------------+-------+---------------------+------+----------+##
##|Fun‡…o    | OA051PROC    | Autor | Luis Delorme        | Data | 30/04/12 |##
##+----------+--------------+-------+---------------------+------+----------+##
##|Descri‡…o | Processa a saida da rotina                                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OA051PROC()
Local nCntFor, nCntFor2 
Local cCodCon := ""
Local cAliasVD9 := "SQLVD9"
//
// ############################################################
// # Verifica se trata-se de EXCLUSAO                         #
// ############################################################
if EXCLUI
	if MsgYesNo(STR0004,STR0003)
		
		BEGIN TRANSACTION //-------------------------------------------------------
		
		DBSelectArea("VDA")
		DBSeek(xFilial("VDA")+M->VD9_CODDEF+M->VD9_CODCON)
		while !eof() .and.  VDA->VDA_FILIAL + VDA->VDA_CODDEF + VDA->VDA_CODCON == xFilial("VDA") + M->VD9_CODDEF + VD9->VD9_CODCON
			reclock("VDA",.f.,.t.)
			dbdelete()
			msunlock()
			DBSkip()
		enddo
		DBSelectArea("VD9")
		if DBSeek(xFilial("VD9")+M->VD9_CODDEF+M->VD9_CODCON)
			reclock("VD9",.f.,.t.)
			dbdelete()
			msunlock()
		endif
		
		END TRANSACTION //---------------------------------------------------------
		
		oDlg:End()
		return .t.
	else
		return .f.
	endif
endif
// ############################################################
// # Verifica se trata-se de VISUALIZACAO                     #
// ############################################################
if VISUALIZA
	oDlg:end()
	return .t.
endif
//
if INCLUI .or. ALTERA
	if MsgYesNo(STR0005,STR0003)
		//
		BEGIN TRANSACTION //---------------------------------------------------------
		
		// ###########################
		// # Gravação da Tabela PAI  #
		// ###########################
		
		if INCLUI
			M->VD9_CODCON := GetSXENum("VD9","VD9_CODCON")
			lAchou := .F.
		else
			lAchou := DBSeek(xFilial("VD9")+M->VD9_CODDEF+M->VD9_CODCON)
		Endif

		DBSelectArea("VD9")
		DbSetOrder(1)
		reclock("VD9", INCLUI)
		VD9_FILIAL := xFilial("VD9")
		FG_GRAVAR("VD9")
		ConfirmSX8()
		msunlock()
		
		// ############################
		// # Gravação da Tabela FILHO #
		// ############################
		
		DbSelectArea("VDA")
		for nCntFor := 1 to Len(oGetDados1:aCols)
			//
			nPosChave1 := VD9->VD9_CODDEF
			nPosChave2 := VD9->VD9_CODCON
			nPosChave3 := oGetDados1:aCols[nCntFor,FG_POSVAR("VDA_CODEMP","aHeaderF1")]
			nPosChave4 := oGetDados1:aCols[nCntFor,FG_POSVAR("VDA_CODFIL","aHeaderF1")]
			//
			if INCLUI
				lAchou := .F.
			else
				lAchou := DBSeek(xFilial("VDA") + nPosChave1 + nPosChave2 + nPosChave3 + nPosChave4)
			end

			if ! oGetDados1:aCols[nCntFor,len(oGetDados1:aCols[nCntFor])]
				reclock("VDA", INCLUI)
				VDA->VDA_FILIAL := xFilial("VDA")
				VDA->VDA_CODDEF := VD9->VD9_CODDEF
				VDA->VDA_CODCON := VD9->VD9_CODCON
				for nCntFor2 := 1 to Len(aHeaderF1)
					if aHeaderF1[nCntFor2,10] <> "V"
						&(aHeaderF1[nCntFor2,2]) := oGetDados1:aCols[nCntFor,nCntFor2]
					endif
				next
			elseif lAchou .AND. ALTERA
				reclock("VDA",.f.,.t.)
				dbdelete()
				msunlock()
			endif
		next
		//
		// ############################
		// # Gravação da Tabela FILHO #
		// ############################
		
		DbSelectArea("VDE")
		lAchou := DBSeek(xFilial("VDE")+VD9->VD9_CODDEF+VD9->VD9_CODCON)
		
		aAnt := {}
		while !eof() .and. xFilial("VDE")+VD9->VD9_CODDEF+VD9->VD9_CODCON == VDE->VDE_FILIAL + VDE->VDE_CODDEF + VDE->VDE_CODCON
			aAdd(aAnt,{VDE->VDE_CCTERP,VDE->VDE_CCUSTO,.f.})
			DbSelectArea("VDE")
			DBSkip()
		enddo
		//
		for nCntFor := 1 to Len(oGetDados2:aCols)
			if Empty(oGetDados2:aCols[nCntFor,1])
				Loop
			Endif
			//
			nPosChave1 := VD9->VD9_CODDEF
			nPosChave2 := VD9->VD9_CODCON
			nPosChave3 := oGetDados2:aCols[nCntFor,FG_POSVAR("VDE_CCTERP","aHeaderF2")]
			nPosChave4 := oGetDados2:aCols[nCntFor,FG_POSVAR("VDE_CCUSTO","aHeaderF2")]
			//
			nPosAAnt := aScan(aAnt, {|x| x[1]+x[2] == nPosChave3+nPosChave4})
			if nPosAAnt > 0
				aAnt[nPosAAnt,3] = .t.
			endif
			//
			if INCLUI
				lAchou := .F.
			else
				lAchou := DBSeek(xFilial("VDE")+nPosChave1+nPosChave2+nPosChave3+nPosChave4)
			end
			if !oGetDados2:aCols[nCntFor,len(oGetDados2:aCols[nCntFor])]
				reclock("VDE",!lAchou)
				VDE->VDE_FILIAL := xFilial("VDE")
				VDE->VDE_CODDEF := VD9->VD9_CODDEF
				VDE->VDE_CODCON := VD9->VD9_CODCON
				for nCntFor2 := 1 to Len(aHeaderF2)
					if aHeaderF2[nCntFor2,10] <> "V"
						&(aHeaderF2[nCntFor2,2]) := oGetDados2:aCols[nCntFor,nCntFor2]
					endif
				next
			elseif lAchou .AND. ALTERA
				reclock("VDE",.f.,.t.)
				dbdelete()
				msunlock()
			endif
		next
		for nCntFor := 1 to Len(aAnt)
			if !aAnt[nCntFor,3] .and. DBSeek(xFilial("VDE")+VD9->VD9_CODDEF+VD9->VD9_CODCON+aAnt[nCntFor,1]+aAnt[nCntFor,2])
				reclock("VDE",.f.,.t.)
				dbdelete()
				msunlock()
			endif
		next
		
		END TRANSACTION //---------------------------------------------------------
		
		oDlg:End()
		return .t.
	endif
endif
//
return .f.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Orcamento de Pecas e Servicos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ OemtoAnsi(STR0006) 	,"AxPesqui"   , 0 , 1},;			// Pesquisar
{ OemtoAnsi(STR0007),"OXA051V"    , 0 , 2},;	// Visualizar
{ OemtoAnsi(STR0008),"OXA051I"    , 0 , 3},;	// Incluir
{ OemtoAnsi(STR0009),"OXA051A"    , 0 , 4},;	// Alterar
{ OemtoAnsi(STR0010),"OXA051E"    , 0 , 5},; // Excluir
{ STR0031,"OFIIJD01"    , 0 , 6},; // Importação
{ STR0032,"OIJD01EXP"    , 0 , 7},; // Exportação
{ STR0011,"OXA051C" , 0 , 5},;	// Conf DEF p/ Cta Contab 
{ STR0012,"OXA051N"    , 0 , 5} }	// Ctas Ctbs não Relac 
//
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA051C  ³ Autor ³ Thiago									  ³ Data ³ 30/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conferencia DEF p/ Cta Contab 	   				                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA051C() 
Local aAtivo := X3CBOXAVET("VD9_ATIVO","1")
Local aParamBox := {}
Local aRet      := {}  
Local cAliasVD9 := "SQLVD9"
Local cNomRel   := "OFIXA051"
Local aIntCab := {} // Cabeçalhos da função FGX_VISINT
Local aIntIte := {} // Itens da função FGX_VISINT
                                                        
aAdd(aIntCab,{STR0013, "C",45,"@!"})
aAdd(aIntCab,{STR0014, "C",45,"@!"}) 
aAdd(aIntCab,{STR0015, "N",45,"@!"})
aAdd(aIntCab,{STR0016, "N",45,"@!"})
aAdd(aIntCab,{STR0017, "N",45,"@!"})


aAdd(aParamBox,{1,STR0018,Space(TamSX3("VD9_CODDEF")[1]),"@!","","VD7","",0,.f.}) 
aAdd(aParamBox,{1,STR0019,Space(TamSX3("VD9_CONCTA")[1]),"@!","","CT1","",100,.t.}) 
aAdd(aParamBox,{2,STR0020,"",aAtivo,80,"",.f.}) 

If ParamBox(aParamBox,STR0021,@aRet,,,,,,,,.f.)
 
	cQuery := "SELECT  VD9.VD9_CODDEF, VD9.VD9_CONCTA, VD9.VD9_DESCRI, VD9.VD9_CPODEF, VD9.VD9_TIPO, VDE.VDE_CCTERP "
	cQuery += "FROM "
	cQuery += RetSqlName( "VD9" ) + " VD9 " 
	cQuery += " JOIN "+RetSQLName("VDE")+" VDE ON  VDE.VDE_FILIAL  = '"+xFilial('VDE')+"' AND VD9.VD9_CODCON = VDE.VDE_CODCON AND VD9.VD9_CODDEF = VDE.VDE_CODDEF AND VDE.VDE_CCTERP = '"+aRet[2]+"' AND VDE.D_E_L_E_T_=' ' "
	cQuery += "WHERE " 
	cQuery += "VD9.VD9_FILIAL='"+ xFilial("VD9")+ "' AND "
	if !Empty(aRet[1])
		cQuery += "VD9.VD9_CODDEF='"+aRet[1]+ "' AND "
	Endif
	if !Empty(aRet[3])
		cQuery += "VD9.VD9_ATIVO='"+aRet[3]+ "' AND "
	Endif
	cQuery += "VD9.D_E_L_E_T_=' '"                                             
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD9, .T., .T. )
	
	Do While !( cAliasVD9 )->( Eof() )
	     
	   Aadd(aIntIte,{(cAliasVD9 )->VD9_CODDEF, (cAliasVD9 )->VDE_CCTERP, (cAliasVD9 )->VD9_DESCRI, (cAliasVD9 )->VD9_CPODEF, (cAliasVD9 )->VD9_TIPO})

		dbSelectArea(cAliasVD9)
		( cAliasVD9 )->(dbSkip())
	Enddo
	( cAliasVD9 )->( dbCloseArea() )

	if Len(aIntIte) > 0 
		FGX_VISINT(cNomRel , STR0022 , aIntCab , aIntIte , .t. )
	Else
		MsgInfo(STR0023)
	Endif
					
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA051N  ³ Autor ³ Thiago									  ³ Data ³ 30/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Contas Contábeis na Relacionadas ao DFA			                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA051N() 
Local aAtivo  := X3CBOXAVET("VD9_ATIVO","1")
Local aClasse := X3CBOXAVET("CT1_CLASSE","1")
Local aParamBox := {}
Local aRet      := {}  
Local cAliasCT1 := "SQLCT1"
Local cNomRel   := "OFIXA051"
Local aIntCab := {} // Cabeçalhos da função FGX_VISINT
Local aIntIte := {} // Itens da função FGX_VISINT
                                                        
aAdd(aIntCab,{STR0024,"C",45,"@!"})
aAdd(aIntCab,{STR0025,"N",45,"@!"})
aAdd(aIntCab,{STR0026,"N",45,"@!"})


aAdd(aParamBox,{2,STR0027,"",aAtivo,80,"",.f.}) 
aAdd(aParamBox,{2,STR0028 ,"",aClasse,80,"",.f.}) 

If ParamBox(aParamBox,STR0029,@aRet,,,,,,,,.f.)
 
	cQuery := "SELECT CT1_CONTA, CT1_DESC01, CT1_CLASSE "
	cQuery += "FROM "
	cQuery += RetSqlName( "CT1" ) + " CT1 " 
	cQuery += "WHERE " 
	cQuery += "CT1.CT1_FILIAL='"+ xFilial("CT1")+ "' AND "
	if !Empty(aRet[2])
		cQuery += "CT1.CT1_CLASSE='"+aRet[2]+ "' AND "
	Endif
	cQuery += "NOT EXISTS (SELECT DISTINCT VDE_CCTERP FROM "+RetSQLName("VDE")+" VDE 
	if !Empty(aRet[1])
		cQuery += "LEFT JOIN "+RetSqlName("VD9")+" VD9 ON (VD9.VD9_FILIAL='"+xFilial("VD9")+"' AND VD9.VD9_CODCON = VDE.VDE_CODCON AND VD9.VD9_CODDEF = VDE.VDE_CODDEF AND VD9.VD9_ATIVO='"+aRet[1]+"' AND VD9.D_E_L_E_T_=' ') "
	Endif	
	cQuery += "WHERE VDE.VDE_FILIAL='"+xFilial("VDE")+"' AND VDE.VDE_CCTERP = CT1.CT1_CONTA AND VDE.D_E_L_E_T_=' ') AND "
	cQuery += "CT1.D_E_L_E_T_=' '"                                             
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasCT1, .T., .T. )
	
	Do While !( cAliasCT1 )->( Eof() )
	     
	   Aadd(aIntIte,{( cAliasCT1 )->CT1_CONTA, ( cAliasCT1 )->CT1_DESC01, ( cAliasCT1 )->CT1_CLASSE})

		dbSelectArea(cAliasCT1)
		( cAliasCT1 )->(dbSkip())
	Enddo
	( cAliasCT1 )->( dbCloseArea() )

	if Len(aIntIte) > 0 
		FGX_VISINT(cNomRel , STR0029 , aIntCab , aIntIte , .t. )
	Else
		MsgInfo(STR0030)
	Endif	
					
Endif

Return(.t.)
