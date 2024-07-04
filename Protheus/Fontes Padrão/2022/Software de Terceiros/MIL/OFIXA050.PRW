// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "OFIXA050.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXA050   | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Rotina de cadastro de cabeçalhos de DEF                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA050()
//
Local nCntFor2, nCntFor3, nCntFor4
Private cCadastro 		:= STR0001
Private aRotina   := MenuDef()
Private  aFilComp := {}
Private nNroGetSxe := 0

//
// Validacao de Licencas DMS
//
If !OFValLicenca():ValidaLicencaDMS()
	Return
EndIf

aEmp := FWAllCompany(SM0->M0_CODIGO)
if Len(aEmp) == 0
	aAdd(aEmp, "")
endif
for nCntFor2 := 1 to Len(aEmp)
	aUni := FWAllUnitBusiness(aEmp[nCntFor2],SM0->M0_CODIGO)
	if Len(aUni) == 0
		aAdd(aUni, "")
	endif
	for nCntFor3 := 1 to Len(aUni)  
		aFil := FWAllFilial(aEmp[nCntFor2],aUni[nCntFor3],SM0->M0_CODIGO)
		for nCntFor4 := 1 to Len(aFil)
			cNomeFil := FWFilialName(SM0->M0_CODIGO,aEmp[nCntFor2]+aUni[nCntFor3]+aFil[nCntFor4],2)    
			if !Empty(cNomeFil)
				if Ascan(aFilComp,{ |x| x[1] + x[2] + x[3] + x[4] == SM0->M0_CODIGO,aEmp[nCntFor2]+aUni[nCntFor3]+aFil[nCntFor4]}) == 0
					aAdd(aFilComp,{SM0->M0_CODIGO,aEmp[nCntFor2],aUni[nCntFor3],aFil[nCntFor4],cNomeFil })
				endif
			endif
		next
	next
next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VD7")
dbSetOrder(1)
//
mBrowse( 6, 1,22,75,"VD7")
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA050V    | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA050V(cAlias,nReg,nOpc)
Local lRet := .f.  
//
lRet = OXA050(NIL,NIL,2)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA050I    | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA050I(cAlias,nReg,nOpc)
Local lRet := .f.  
//
lRet = OXA050(NIL,NIL,3)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA050A    | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA050A(cAlias,nReg,nOpc)
Local lRet := .f.  
//
lRet = OXA050(NIL,NIL,4)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA050E    | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA050E(cAlias,nReg,nOpc)
Local lRet := .f.  
//
lRet = OXA050(NIL,NIL,5)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA050     | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Monta a tela de cadastro                                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA050(xAutoCab,xAutoItens, nOpc)

Private aAutoCab 		:= {} 	// Cabecalho da Integracao
Private aAutoItens 		:= {}	// Itens da Integracao
Private lAutomat 		:= ( xAutoCab <> NIL  .and. xAutoItens <> NIL )
Private aNewBot := { }
//######################################################################################
//# Se for detectado que trata-se de integracao faz os vetores receberem os parametros #
//######################################################################################
If lAutomat
	aAutoCab	:= xAutoCab
	aAutoItens	:= xAutoItens
EndIf
// #####################################################
// # Na integracao as variaveis abaixo nao existirao,  #
// # por isso precisamos carrega-las manualmente       #
// #####################################################
VISUALIZA	:= nOpc==2
INCLUI 		:= nOpc==3
ALTERA 		:= nOpc==4
EXCLUI 		:= nOpc==5
//#############################################################################
//# Chama a tela                                                              #
//#############################################################################
DBSelectArea("VD7")
lRet := OXX050(alias(),Recno(),nOpc)
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Fun‡„o    |    OXA050   | Autor | Luis Delorme         | Data | 30/04/12 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descri‡„o | Tela Principal                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXX050(cAlias,nReg,nOpc)
	Local nCntFor, nCntFor2
	Local aObjsPrin 	:= {}
	Local aSizeAut		:= MsAdvSize(.t.)
	//################################################################
	//# Variaveis da Enchoice                                        #
	//################################################################
	Local nModelo 		:= 1
	Local lF3 			  := .f.
	Local lMemoria 		:= .t.
	Local lColumn 		:= .f.
	Local cATela 	    := ""
	Local lNoFolder 	:= .t.
	Local lProperty 	:= .f.
	// Variavel que armazena os campos que serao mostrados pela enchoice
Private aCpoEncS 	:= {}
	//################################################################
	//# Especifica o espacamento entre os objetos principais da tela #
	//################################################################
	// { LARGURA,	ALTURA,	AUTOSIZE LARGURA,	AUTOSIZE ALTURA	} )
AAdd( aObjsPrin, 	{ 0,		115,	.T.,				.F. 			} )
AAdd( aObjsPrin, 	{ 0,		40,		.T.,				.T. 			} )
//					{	LINHA INICIAL	COLUNA INICIAL	LINHA FINAL		COLUNA FINAL	MARGEM HORIZONTAL	MARGEM VERTICAL }
aInfo 			:=	{ 	aSizeAut[ 1 ],	aSizeAut[ 2 ],	aSizeAut[ 3 ],	aSizeAut[ 4 ],	3,					3				}
	aPosObjsPrin :=	MsObjSize( aInfo, aObjsPrin )

	//###############################################
	//# Cria variaveis M->????? da Enchoice do PAI  #
	//###############################################
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VD7")
//
aCpoEncS  	:= {}	// ARRAY DE CAMPOS DA ENCHOICE
aCpos		:= {} 	// ARRAY DE CAMPOS DA ENCHOICE EDITAVEIS
//
cPAInEdit 	:= "" // CAMPOS DO PAI NAO EDITAVEIS
//
cPAInMostra := "" // CAMPOS DO PAI NAO MOSTRADOS
//
	While !SX3->(Eof()) .AND. (SX3->X3_ARQUIVO == "VD7")

		// MONTA OS CAMPOS QUE APARECERAO NA DA ENCHOICE
		If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
			AADD(acpoEncS,SX3->X3_CAMPO)
		EndIf

		// MONTA VARIAVEIS DE MEMORIA QUE ARMAZENAM AS INFORMACOES DA ENCHOICE
		If INCLUI
			if SX3->X3_CAMPO == "VD7_CODDEF" .OR. SX3->X3_CAMPO == "VD7_CODAUT"
				&("M->"+SX3->X3_CAMPO) := getsxenum("VD7" , SX3->X3_CAMPO)
				nNroGetSxe := nNroGetSxe + 1
			else 
				&("M->"+SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
			end
		Else
			If x3_context == "V"
				&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
			Else
				&("M->"+SX3->X3_CAMPO):= &("VD7->"+SX3->X3_CAMPO)
			EndIf
		EndIf

		// MONTA CAMPOS EDITAVEIS
	If ( SX3->X3_CONTEXT != "V" )
		if !(Alltrim(SX3->X3_CAMPO) $ cPAInEdit) .and.  !(Alltrim(SX3->X3_CAMPO)+"," $ cPAInMostra)
			aAdd(aCpos,SX3->X3_CAMPO)
		endif
	endif
		DbSkip()
	Enddo

	//###################################################################
	//# Cria variaveis de memoria, aHeader e aCols da MsNewGetDados 1   #
	//###################################################################
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VD8")

	aHeaderF1		 := {}	// ARRAY DE CAMPOS DA MSNEWGETDADOS
	aAlterF1 		 := {}	// ARRAY DE CAMPOS DA MSNEWGETDADOS EDITAVEIS
	aColsF1 		 := {}	// ITENS DA MSNEWGETDADOS
//
cFIL1nEdit 		:= ""	// CAMPOS DO PAI NAO EDITAVEIS
//
cFIL1nMostra 	:= "VD8_CODDEF,"	// CAMPOS QUE NAO APARECERAO NA MSNEWGETDADOS
//
nUsadoF1:=0
	//
	While !SX3->(Eof()) .AND. (SX3->X3_ARQUIVO == "VD8")
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
				X3CBOX()           ,; // 11
				SX3->X3_RELACAO    ,; // 12
				".T."               ; // 13
			})
			if SX3->X3_USADO != "V" .and. (INCLUI .or. ALTERA)
				aAdd(aAlterF1,SX3->X3_CAMPO)
			endif
		EndIf
		DbSkip()
	EndDo

	// Cria aCols
	DBSelectArea("VD8")
	DBSetOrder(1)
	For nCntFor:=1 to Len(aFilComp)
		lAtivo := .f.
		if !INCLUI .and. DBSeek(xFilial("VD8")+VD7->VD7_CODDEF + aFilComp[nCntFor,1]+aFilComp[nCntFor,2]+aFilComp[nCntFor,3]+aFilComp[nCntFor,4])
			lAtivo := (VD8->VD8_ATIVO == "1")
		endif
		AADD(aColsF1,Array(nUsadoF1+1))
		For nCntFor2:=1 to nUsadoF1
			if Alltrim(aHeaderF1[nCntFor2,2]) == "VD8_CODEMP"
				aColsF1[Len(aColsF1),nCntFor2] := aFilComp[nCntFor,1]
			elseif Alltrim(aHeaderF1[nCntFor2,2]) == "VD8_CODFIL"
				aColsF1[Len(aColsF1),nCntFor2] := aFilComp[nCntFor,2]+aFilComp[nCntFor,3]+aFilComp[nCntFor,4]
			elseif Alltrim(aHeaderF1[nCntFor2,2]) == "VD8_DESFIL"
				aColsF1[Len(aColsF1),nCntFor2] := aFilComp[nCntFor,5]
			elseif Alltrim(aHeaderF1[nCntFor2,2]) == "VD8_ATIVO"
				aColsF1[Len(aColsF1),nCntFor2] := IIF(lAtivo,"1","0")
			elseif aHeaderF1[nCntFor2,10] == "V"
				SX3->(DBSetOrder(2))
				SX3->(DBSeek(aHeaderF1[nCntFor2,2]))
				aColsF1[Len(aColsF1),nCntFor2] := &(SX3->X3_RELACAO)
			else
				If INCLUI
					aColsF1[Len(aColsF1),nCntFor2] := SPACE( TAMSX3(Alltrim(aHeaderF1[nCntFor2,2]))[1] )
				Else
					aColsF1[Len(aColsF1),nCntFor2] := FieldGet(FieldPos(aHeaderF1[nCntFor2,2]))
				EndIf
			endif
			aColsF1[Len(aColsF1),nUsadoF1+1]:=.F.
		next
	next

	RegToMemory("VD8",IIF(nopc==3,.t.,.f.))
	//
	If lAutomat
		//################################################################
		//# Monta Enchoice e GetDados automaticamente para a integracao  #
		//################################################################
		If EnchAuto("VD7",aAutoCab)
			MsGetDAuto(aAutoItens,"OA050FLOK()",	{|| OA050TOK(nOpc).AND.OA050PROC(nOpc) },aAutoCab,nOpc)
		EndIf
	Else
		//####################################################
		//# Montagem da tela                                 #
		//####################################################
		cF1LinOk	 := "OA050LOK()"
		cF1FieldOk := "OA050FOK()"
		cF1TudoOk	 := "OA050TOK()"

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
		oGetDados1:oBrowse:bDelete := { || OA050DEL() }

		// ######################
		// # Ativacao da janela #
		// ######################
		oDlg:bInit := {|| EnchoiceBar(oDlg, { || If(OA050TOK(nOpc),OA050PROC(nOpc),.t.) } , { || OA050SAIR(nOpc) },,aNewBot )}
		oDlg:lCentered := .T.
		oDlg:Activate()

	EndIf

	for nCntFor := 1 to nNroGetSxe
		RollBackSx8()
	end

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA050FOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK da MSGETDADOS                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA050FOK()

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA050LOK   | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | LinOK da MSNEWGETDADOS 1                                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA050LOK()
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
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |   OA050TOK |  Luis Delorme                 | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verifica se tudo esta preenchido corretamente                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA050TOK(nOpc)
Local nCntFor

If EXCLUI
	Return .t.
Endif

// ############################################################
// # Verifica campos obrigatorios da Enchoice                 #
// ############################################################
For nCntFor:=1 to Len(acpoEncS)
	If X3Obrigat(acpoEncS[nCntFor]) .and. Empty(&("M->"+acpoEncS[nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(acpoEncS[nCntFor]),4,1)
		Return .f.
	EndIf
Next
//
If INCLUI .or. ALTERA
	If VD7->(FieldPos("VD7_CALCCT")) > 0
		If (!Empty(M->VD7_CALCCT) .and. M->VD7_CALCCT <> '0') .and. (!Empty(M->VD7_CALICT) .and. M->VD7_CALICT <> '0') // Tentando cadastrar centro de custo e item contábil como filial simultaneamente
			Help(NIL, NIL, STR0011, NIL, STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013})	// Uso Incorreto da Filial Como Entidade Contábil | Não é possível cadastrar um DEF com filial no centro de custo e no item contábil. | Verifique o preenchimento dos campos CC Filial (VD7_CALCCT) e Item Ct. Filial (VD7_CALICT), escolhendo apenas um como filial.
			Return .f.
		EndIf
		If M->VD7_CALCCT == '2' // 2=Estruturado
			If Empty(M->VD7_CCESTR)
				Help(NIL, NIL, STR0014, NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) // Esquema da Estrutura Em Branco | Não é possível cadastrar um DEF com filial estruturada no centro de custo sem informar seu esquema. | Verifique o preenchimento do campo CC Estrutura (VD7_CCESTR).
				Return .f.
			EndIf
		EndIf
		If !Empty(M->VD7_CALCCT) .and. M->VD7_CALCCT <> '0'
			For nCntFor := 1 to Len(oGetDados1:aCols)
				If oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_ATIVO", "aHeaderF1")] == '1' .and. Empty(oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_CC", "aHeaderF1")])
					Help(NIL, NIL, STR0017, NIL, STR0018, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0019}) // Filial no Centro de Custo Em Branco | Não é possível cadastrar um DEF com filial no centro de custo sem informar seu código para cada filial ativa. | Verifique o preenchimento do campo Centro Custo (VD8_CC).
					Return .f.
				EndIf
			Next
		EndIf
		If !Empty(M->VD7_CALICT) .and. M->VD7_CALICT <> '0'
			For nCntFor := 1 to Len(oGetDados1:aCols)
				If oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_ATIVO", "aHeaderF1")] == '1' .and. Empty(oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_ITEMCT", "aHeaderF1")])
					Help(NIL, NIL, STR0020, NIL, STR0021, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0022}) // Filial no Item Contábil Em Branco | Não é possível cadastrar um DEF com filial no item contábil sem informar seu código para cada filial ativa. | Verifique o preenchimento do campo Item Conta (VD8_ITEMCT).
					Return .f.
				EndIf
			Next
		EndIf
	EndIf
EndIf

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------------------------------+------+----------+##
##|Fun‡„o    |  OA050DEL  |  Luis Delorme                 | Data | 30/04/12 |##
##+----------+------------+-------------------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA050DEL()

return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |  OA050SAIR | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Processa a saida da rotina                                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA050SAIR(nOpc)
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
##|Fun‡…o    | OA050PROC    | Autor | Luis Delorme        | Data | 30/04/12 |##
##+----------+--------------+-------+---------------------+------+----------+##
##|Descri‡…o | Processa a saida da rotina                                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OA050PROC()
Local nCntFor, nCntFor2
Local nIdx:=1
//
// ############################################################
// # Verifica se trata-se de EXCLUSAO                         #
// ############################################################
if EXCLUI
	if MsgYesNo(STR0004,STR0003)
		BEGIN TRANSACTION
		
		DBSelectArea("VD8")
		DBSeek(xFilial("VD8")+M->VD7_CODDEF)
		while !eof() .and.  VD8->VD8_FILIAL + VD8->VD8_CODDEF == xFilial("VD8")+M->VD7_CODDEF
			reclock("VD8",.f.,.t.)
			dbdelete()
			msunlock()
			DBSkip()
		enddo
		DBSelectArea("VD7")
		if DBSeek(xFilial("VD7")+M->VD7_CODDEF)
			reclock("VD7",.f.,.t.)
			dbdelete()
			msunlock()
		endif
		
		END TRANSACTION
		
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
	if MsgYesNo(STR0005,STR0003) // Deseja continuar? | Atencao
		//
		BEGIN TRANSACTION
		
		// ###########################
		// # Gravação da Tabela PAI  #
		// ###########################
		if INCLUI
			lAchou := .F.
		else
			lAchou := DBSeek(xFilial("VD7")+M->VD7_CODDEF)
		end

		DBSelectArea("VD7")
		reclock("VD7", INCLUI)
		VD7_FILIAL := xFilial("VD7")
		FG_GRAVAR("VD7")
		msunlock()

		for nIdx := 1 to nNroGetSxe
			ConfirmSX8()
		end
		nNroGetSxe := 0

		
		// ############################
		// # Gravação da Tabela FILHO #
		// ############################
		
		DbSelectArea("VD8")
		for nCntFor := 1 to Len(oGetDados1:aCols)
			//
			nPosChave1 := VD7->VD7_CODDEF
			nPosChave2 := oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_CODEMP","aHeaderF1")]
			nPosChave3 := oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_CODFIL","aHeaderF1")]
			if Empty(nPosChave2)
				loop
			endif
			//
			if INCLUI
				lAchou := .F.
			else
				lAchou := DBSeek(xFilial("VD8") + nPosChave1 + nPosChave2 + nPosChave3)
			end
			if !oGetDados1:aCols[nCntFor,len(oGetDados1:aCols[nCntFor])]
				If INCLUI
					// Inclusão
					RecLock("VD8", .T.)
				ElseIf ALTERA .And. !lAchou
					// Inclusão de nova linha em registro já existente
					RecLock("VD8", .T.)
				Else
					// Alteração
					RecLock("VD8", .F.)
				EndIf
				VD8->VD8_FILIAL := xFilial("VD8")
				VD8->VD8_CODDEF := VD7->VD7_CODDEF
				for nCntFor2 := 1 to Len(aHeaderF1)
					if aHeaderF1[nCntFor2,10] <> "V"
						&(aHeaderF1[nCntFor2,2]) := oGetDados1:aCols[nCntFor,nCntFor2]
					endif
				next
				VD8->(msunlock())
			elseif lAchou
				reclock("VD8",.f.,.t.)
				dbdelete()
				msunlock()
			endif
		next

		// ############################
		// # Atualização dos VDAs     #
		// ############################

		DBSelectArea("VD9")
		DBSetOrder(1)
		for nCntFor := 1 to Len(oGetDados1:aCols)
			cEmpVD8 := oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_CODEMP","aHeaderF1")]
			cFilVD8 := oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_CODFIL","aHeaderF1")]
			DBSeek(xFilial("VD9")+VD7->VD7_CODDEF)
			while !eof() .and. xFilial("VD9")+VD7->VD7_CODDEF == VD9->VD9_FILIAL+VD9->VD9_CODDEF
				DBSelectArea("VDA")
				DBSetOrder(1)
				If oGetDados1:aCols[nCntFor,len(oGetDados1:aCols[nCntFor])]
					if DBSeek(xFilial("VDA")+VD7->VD7_CODDEF+VD9->VD9_CODCON+cEmpVD8+cFilVD8)
						reclock("VDA",.f.,.t.)
						dbdelete()
						msunlock()
					endif
				else
					DBSeek(xFilial("VDA")+VD7->VD7_CODDEF+VD9->VD9_CODCON+cEmpVD8+cFilVD8)
					if oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_ATIVO","aHeaderF1")] == "0" 
						if found()
							reclock("VDA",.f.,.t.)
							dbdelete()
							msunlock()
						endif
					else
						reclock("VDA",!found())
						VDA_FILIAL := xFilial("VDA")
						VDA_CODFIL := cFilVD8
						VDA_CODEMP := cEmpVD8
						VDA_CODDEF := VD7->VD7_CODDEF
						VDA_CODCON := VD9->VD9_CODCON
						VDA_ATIVO := oGetDados1:aCols[nCntFor,FG_POSVAR("VD8_ATIVO","aHeaderF1")]
						msunlock()
					endif
				endif
				DBSelectArea("VD9")
				DBSkip()
			enddo
		next
		
		END TRANSACTION
		
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
	Local aRotina := {;
		{ STR0006 ,"AxPesqui"   , 0 , 1},; // Pesquisar
		{ STR0007	,"OXA050V"    , 0 , 2},; // Visualizar
		{ STR0008	,"OXA050I"    , 0 , 3},; // Incluir
		{ STR0009	,"OXA050A"    , 0 , 4},; // Alterar
		{ STR0010	,"OXA050E"    , 0 , 5} ; // Excluir
	}
Return aRotina
