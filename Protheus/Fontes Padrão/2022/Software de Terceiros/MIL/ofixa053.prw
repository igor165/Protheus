#include "Protheus.ch"
#include "OFIXA053.ch"
#include "fileio.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXA053   | Autor | Luis Delorme          | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Consulta e alteração do DEF calculado a ser enviado          |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA053()
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
dbSelectArea("VDB")
dbSetOrder(1)
//
mBrowse( 6, 1,22,75,"VDB")
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA053V    | Autor |                       | Data |          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA053V(cAlias,nReg,nOpc)
Local lRet := .f.
//
lRet = OXA053(NIL,NIL,2)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA053A    | Autor |                       | Data |          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA053A(cAlias,nReg,nOpc)
Local lRet := .f.
//
lRet = OXA053(NIL,NIL,4)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXA053     | Autor |                       | Data |          |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Chamada da Tela Principal                                    |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA053(xAutoCab,xAutoItens, nOpc)

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
DBSelectArea("VDB")
lRet := OXX053(alias(),Recno(),nOpc)
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Fun‡„o    |    OXX053   | Autor |                      | Data |          |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descri‡„o | Tela Principal                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXX053(cAlias,nReg,nOpc)
//
Local nCntFor
Local aObjsPrin 	:= {}
Local aSizeAut		:= MsAdvSize(.t.)
//################################################################
//# Variaveis da Enchoice                                        #
//################################################################
Local aCpos 		:= {}
Local nModelo 		:= 1
Local lF3 			:= .f.
Local lMemoria 		:= .t.
Local lColumn 		:= .f.
Local cATela 		:= ""
Local lNoFolder 	:= .t.
Local lProperty 	:= .f.
// Variavel que armazena os campos que serao mostrados pela enchoice
Private aCpoEncS 	:= {}
Private oDiagLog := OFVisualizaDados():New()
//################################################################
//# Especifica o espacamento entre os objetos principais da tela #
//################################################################
// 					{ LARGURA,	ALTURA,	AUTOSIZE LARGURA,	AUTOSIZE ALTURA	} )
AAdd( aObjsPrin, 	{ 0,		50,		.T.,				.F. 			} )
AAdd( aObjsPrin, 	{ 0,		40,		.T.,				.T. 			} )

//					{	LINHA INICIAL	COLUNA INICIAL	LINHA FINAL		COLUNA FINAL	MARGEM HORIZONTAL	MARGEM VERTICAL }
aInfo 			:=	{ 	aSizeAut[ 1 ],	aSizeAut[ 2 ],	aSizeAut[ 3 ],	aSizeAut[ 4 ],	3,					3				}
aPosObjsPrin 	:=	MsObjSize( aInfo, aObjsPrin )
//###############################################
//# Cria variaveis M->????? da Enchoice do PAI  #
//###############################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VDB")
//
aCpoEncS  	:= {}	// ARRAY DE CAMPOS DA ENCHOICE
aCpos		:= {} 	// ARRAY DE CAMPOS DA ENCHOICE EDITAVEIS
//
cPAInEdit 	:= "" // CAMPOS DO PAI NAO EDITAVEIS
//
cPAInMostra := "" // CAMPOS DO PAI NAO MOSTRADOS
//
While !Eof().and.(x3_arquivo=="VDB")
	// MONTA OS CAMPOS QUE APARECERAO NA DA ENCHOICE
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cPAInMostra)
		AADD(acpoEncS,x3_campo)
	EndIf
	// MONTA VARIAVEIS DE MEMORIA QUE ARMAZENAM AS INFORMACOES DA ENCHOICE
	if !(Alltrim(x3_campo)+"," $ cPAInMostra)
		If Inclui
			&("M->"+x3_campo):= CriaVar(x3_campo)
		Else
			If x3_context == "V"
				&("M->"+x3_campo):= CriaVar(x3_campo)
			Else
				&("M->"+x3_campo):= &("VDB->"+x3_campo)
			EndIf
		EndIf
	endif
	// MONTA CAMPOS EDITAVEIS
	If ( x3_context != "V" )
		if !(Alltrim(x3_campo) $ cPAInEdit) .and.  !(Alltrim(x3_campo)+"," $ cPAInMostra)
			aAdd(aCpos,X3_CAMPO)
		endif
	endif
	DbSkip()
Enddo
//###################################################################
//# Cria variaveis de memoria, aHeader e aCols da MsNewGetDados 1   #
//###################################################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VDC")
//
aHeaderF1		:= {}	// ARRAY DE CAMPOS DA MSNEWGETDADOS
aAlterF1 		:= {}	// ARRAY DE CAMPOS DA MSNEWGETDADOS EDITAVEIS
aColsF1 		:= {}	// ITENS DA MSNEWGETDADOS
//
cFIL1nEdit 		:= ""	// CAMPOS DO PAI NAO EDITAVEIS
//
cFIL1nMostra 	:= "VDC_CODDEF,VDC_DATA,"	// CAMPOS QUE NAO APARECERAO NA MSNEWGETDADOS
//
nUsadoF1:=0
//
While !Eof().And.(x3_arquivo=="VDC")
	If  X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cFIL1nMostra)
		nUsadoF1:=nUsadoF1+1
		Aadd(aHeaderF1,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO,".T."})
		if x3_usado != "V" .and. (INCLUI .or. ALTERA)
			if !(Alltrim(x3_campo)+"," $ cFIL1nEdit)
				aAdd(aAlterF1,x3_campo)
			endif
		endif
	EndIf
	DbSkip()
EndDo
// Cria aCols
If INCLUI
	aColsF1 := { Array(nUsadoF1 + 1) }
	aColsF1[1,nUsadoF1+1] := .F.
	For nCntFor:=1 to nUsadoF1
		aColsF1[1,nCntFor]:=CriaVar(aHeaderF1[nCntFor,2])
	Next
Else
	aColsF1:={}
	// TODO: POSICIONAMENTO DA TABELA FILHO
	dbSelectArea("VDC")
	dbSetOrder(1)
	dbSeek(xFilial("VDC") + VDB->VDB_CODDEF + DTOS(VDB->VDB_DATA) )
	// TODO: LACO DA TABELA FILHO
	While !eof() .and. VDC->VDC_FILIAL + VDC->VDC_CODDEF  + DTOS(VDC->VDC_DATA) == xFilial("VDC") + VDB->VDB_CODDEF + DTOS(VDB->VDB_DATA)
		AADD(aColsF1,Array(nUsadoF1+1))
		For nCntFor:=1 to nUsadoF1
			if aHeaderF1[nCntFor,10] == "V"
				SX3->(DBSetOrder(2))
				SX3->(DBSeek(aHeaderF1[nCntFor,2]))
				aColsF1[Len(aColsF1),nCntFor] := &(sx3->x3_relacao)
			else
				aColsF1[Len(aColsF1),nCntFor] := FieldGet(FieldPos(aHeaderF1[nCntFor,2]))
			endif
		Next
		aColsF1[Len(aColsF1),nUsadoF1+1]:=.F.
		DbSkip()
	EndDo
EndIf
RegToMemory("VDC",IIF(nopc==3,.t.,.f.))
//
If !lAutomat
	//
	If VISUALIZA .and. FindFunction( "OX052LogCalculo" )
		AADD( aNewBot , { "PMSCOLOR", {|| OXA053LogCalculo() } , STR0026 } ) // "Visualiza Cálculo"
	EndIf
	//
	//
	SETKEY(VK_F4,{||OA053MHIST()})
	//
	//####################################################
	//# Montagem da tela                                 #
	//####################################################
	//
	cF1LinOk	:="OA053LOK()"
	cF1FieldOk	:="OA053FOK()"
	cF1TudoOk	:="OA053TOK()"
	//#####################################################
	//# Define a tela                                     #
	//#####################################################
	oDlg := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,,,,,.t.)
	//#####################################################
	//# Monta a enchoice do com os campos necessarios     #
	//#####################################################
	aPosEnchoice := aClone(aPosObjsPrin[1])
	oEnch := MSMGet():New( cAlias, nReg, 2, , , ,aCpoEncS, aPosEnchoice, aCpos, nModelo, , , , oDlg, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)
	//#############################################################################
	//# MsNewGetDados 1                                                           #
	//#############################################################################
	oGetDados1 := MsNewGetDados():New(;
		aPosObjsPrin[2,1], aPosObjsPrin[2,2], aPosObjsPrin[2,3],aPosObjsPrin[2,4],;
		3,;
		cF1LinOk,;
		cF1TudoOk,;
		,;
		aAlterF1,0,0,cF1FieldOk,,,oDlg,@aHeaderF1,@aColsF1 )
	oGetDados1:oBrowse:bDelete       := {||OA053DEL() }
	// ######################
	// # Ativacao da janela #
	// ######################
	oDlg:bInit := {|| ;
		EnchoiceBar(oDlg,;
			{ || IIf( OA053TOK(nOpc) , OA053PROC(nOpc) , .t.) } ,;
			{ || OA053SAIR(nOpc) },,aNewBot ;
		)}
	oDlg:lCentered := .T.
	oDlg:Activate()
	//
Else
	//################################################################
	//# Monta Enchoice e GetDados automaticamente para a integracao  #
	//################################################################
	If EnchAuto("VDB",aAutoCab)
		MsGetDAuto(aAutoItens,"OA053FLOK()",	{|| OA053TOK(nOpc).AND.OA053PROC(nOpc) },aAutoCab,nOpc)
	EndIf
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA053FOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK da MSGETDADOS                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA053FOK()

if readvar() # "M->VDC_VALOR"
	return .f.
endif

DBSelectArea("VD9")
DBSetOrder(1)
cCodCon := oGetDados1:aCols[oGetDados1:nAt,FG_POSVAR("VDC_CODCON","aHeaderF1")]
if DBSeek(xFilial("VD9")+VDB->VDB_CODDEF+cCodCon)
	if VD9->VD9_TIPO $ "02568"
		MsgStop(STR0019)
		return .f.
	endif
endif

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OA053LOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | LinOK da MSNEWGETDADOS 1                                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA053LOK()
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
// Aviso("Aviso","Linha da MSNEWGETDADOS OK !",{"OK"})
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |   OA053TOK | Autor |                       | Data |          |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verifica se tudo esta preenchido corretamente                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA053TOK(nOpc)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------------------------------+------+----------+##
##|Fun‡„o    |  OA053DEL  |  Luis Delorme                 | Data | 20/05/09 |##
##+----------+------------+-------------------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA053DEL()
//
Return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |  OA053SAIR | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Processa a saida da rotina                                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA053SAIR(nOpc)
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
##|Fun‡…o    | OA053PROC    | Autor | Luis Delorme        | Data | 20/05/09 |##
##+----------+--------------+-------+---------------------+------+----------+##
##|Descri‡…o | Gera o DEF escolhido                                         |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OA053PROC(nOpc)
Local nCntFor, nCntFor2

VISUALIZA	:= nOpc==2
INCLUI 		:= nOpc==3
ALTERA 		:= nOpc==4
EXCLUI 		:= nOpc==5


// ############################################################
// # Verifica se trata-se de VISUALIZACAO                     #
// ############################################################
if VISUALIZA
	oDlg:end()
	return .t.
endif
//
if ALTERA
	if MsgYesNo(STR0004,STR0003)
		//
		BEGIN TRANSACTION //---------------------------------------------------------

		DBSelectArea("VDB")
		DbSetOrder(1)
		DBSeek(xFilial("VDB") + M->VDB_CODDEF + DTOS(M->VDB_DATA))

		// ############################
		// # Gravação da Tabela FILHO #
		// ############################

		DbSelectArea("VDC")
		DbSetOrder(1)

		aFaltInfo := {}
		aResolv := {}
		aFaltantes := {}
		lFim := .f.

		for nCntFor := 1 to Len(oGetDados1:aCols)
			//
			if DBSeek(xFilial("VDC")+VDB->VDB_CODDEF+DTOS(VDB->VDB_DATA)+oGetDados1:aCols[nCntFor,fg_posvar("VDC_CODCON","aHeaderF1")])
				if VDC->VDC_VALOR != oGetDados1:aCols[nCntFor,fg_posvar("VDC_VALOR","aHeaderF1")]
					reclock("VDC",.f.)
					VDC->VDC_VALOR := oGetDados1:aCols[nCntFor,fg_posvar("VDC_VALOR","aHeaderF1")]
					msunlock()
				endif
				VD9->(DBSeek(xFilial("VD9")+VDB->VDB_CODDEF+oGetDados1:aCols[nCntFor,FG_POSVAR("VDC_CODCON","aHeaderF1")]))
				if VD9->VD9_TIPO $ "25"
					aAdd(aFaltantes, {VD9->VD9_CPODEF, .f.})
				else
					aAdd(aResolv,{VD9->VD9_CPODEF,VDC->VDC_VALOR})
				endif
			endif
			//
		next
		//
		// R E C A L C U L O
		//
		VD9->(DBSetOrder(2))
		lAindaFalta := .t.
		while lAindaFalta
			lAindaFalta := .f.
			for nCntFor := 1 to Len(aFaltantes)
				if aFaltantes[nCntFor,2]
					loop
				endif
				lAindaFalta := .t.
				VD9->(DBSeek(xFilial("VD9")+VDB->VDB_CODDEF+aFaltantes[nCntFor,1]))
				nPosAcols := aScan(oGetDados1:aCols, {|x| Alltrim(x[FG_POSVAR("VDC_CODCON","aHeaderF1")]) == Alltrim(VD9->VD9_CODCON)})
				nVal := 0
				if VD9->VD9_TIPO == "5" // Se a conta representa um acumulado de outra devemos calcular
					nPos = aScan(aResolv, {|x| Alltrim(x[1]) == Alltrim(VD9->VD9_ACUMUL)})
					if nPos > 0
						cCodConAc:=FM_SQL("SELECT VD9.VD9_CODCON FROM "+RetSQLName("VD9")+" VD9 WHERE VD9.VD9_FILIAL='"+xFilial("VD9")+"' AND VD9.VD9_CPODEF='"+VD9->VD9_ACUMUL+"' AND VD9.D_E_L_E_T_=' '")
						nVal += aResolv[nPos,2]
						for nCntFor2 = Month(VDB->VDB_DATA) to 1 step -1
							dDataSeek := ctod("01/"+ STRZERO(nCntFor2,2)+"/"+Right(STRZERO(Year(VDB->VDB_DATA),4),2))-1
							if VDC->(DBSeek(xFilial("VDC")+VDB->VDB_CODDEF+dtos(VDB->VDB_DATA)+Alltrim(cCodConAc)))
								nVal += VDC->VDC_VALOR
							endif
						next
						// remove a conta dos faltantes e insere nos resolvidos
						aFaltantes[nCntFor,2] := .t.
						aAdd(aResolv,{VD9->VD9_CPODEF, IIF(nVal==NIL,0,nVal) })
						//
						VDC->(DBSeek(xFilial("VDC")+VDB->VDB_CODDEF+DTOS(VDB->VDB_DATA)+VD9->VD9_CODCON))
						if VDC->VDC_VALOR != nVal
							reclock("VDC",.f.)
							VDC->VDC_VALOR := nVal
							msunlock()
						endif
					endif
				elseif VD9->VD9_TIPO == "2" // Se a conta representa uma expressão devemos calculá-la
					// se a função FMX_CALXPDEF retornar uma string, a conta é faltante, caso contrário o resultado está em nVal
					cResFalt :=  FMX_CALXPDEF(VD9->VD9_CODCON,VD9->VD9_EXPRES,aResolv,nVal)
					if Empty(cResFalt)
						// remove a conta dos faltantes e insere nos resolvidos
						aFaltantes[nCntFor,2] := .t.
						aAdd(aResolv,{VD9->VD9_CPODEF, IIF(nVal==NIL,0,nVal) })
						//
						VDC->(DBSeek(xFilial("VDC")+VDB->VDB_CODDEF+DTOS(VDB->VDB_DATA)+VD9->VD9_CODCON))
						if VDC->VDC_VALOR != nVal
							reclock("VDC",.f.)
							VDC->VDC_VALOR := nVal
							msunlock()
						endif
						nCntFor = nCntFor - 1
					endif
				endif
			next
		enddo


		END TRANSACTION //---------------------------------------------------------

		oDlg:End()
		return .t.
	endif
endif
//
return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |OA053LTOK   | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verifica se as aCols estao preenchidas corretamente          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA053LTOK(nOpc)
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |  OXA053I   | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Chamada da Impressão do DEF                                  |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA053I()

Local cDesc1  := STR0005
Local cDesc2  := STR0006
Local cDesc3  := STR0007

Private cString  := "VDC"
Private Tamanho  := "M"
Private aReturn  := { STR0028,2,STR0029,2,2,1,"",1 } // Zebrado / Administracao
Private wnrel    := "OFIXA053"
Private NomeProg := "OFIXA053"
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := STR0008+dtoc(VDB->VDB_DATA)
Private cPerg    := "OXA053I"
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := STR0009
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "
Private Cabec2   := " "

//
// "Tipo de Relatorio" - "N" - 1 - "Completo","Sem Definiçao"
// "Mostra Zerados"    - "N" - 1 - "Sim","Nao
// "Gera Consolidado"  - "N" - 1 - "Sim","Nao
//
Pergunte(cPerg,.F.)
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------
RptStatus({|lEnd| RelDbfImp(@lEnd) }, Titulo, STR0010, .T. )
//
return .f.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RelDbfImp ³ Autor ³ Luis Delorme                      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressão do DEF                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RelDbfImp(lEnd)
Local nCntFor, nCntFor2
Local cAliasVD9 := "SQLVD9"

If Select("SQLVD9") > 0
	SQLVD9->(DbCloseArea())
EndIf

cSQLVD8 := GetNextAlias()
cQuery := "SELECT VD8.VD8_CODFIL"
cQuery += " FROM " + RetSqlName("VD8") + " VD8"
cQuery += " WHERE VD8_CODDEF = '"+VDB->VDB_CODDEF+"' AND VD8_ATIVO = '1' "
cQuery += " AND VD8_FILIAL = '"+xFilial("VD8")+"'"
cQuery += " AND VD8.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cSQLVD8, .T., .T. )
cFilSqlIn := ""
While !( (cSQLVD8)->(Eof()) )
	cFilSqlIn += "'"+Alltrim((cSQLVD8)->(VD8_CODFIL))+"',"
	(cSQLVD8)->( dbSkip() )
enddo
(cSQLVD8)->(DbCloseArea())
cFilSqlIn := Left(cFilSqlIn,Len(cFilSqlIn)-1)

aFaltantes := {}
aResolv := {}

if MV_PAR03 == 1
	if VD9->(FieldPos("VD9_CCUSTA")) > 0 
		cQuery := "SELECT VD9.R_E_C_N_O_, VD9_CPODEF, VD9_CODCON, VD9_CONCTA, VD9_DESCRI, VD9_CCUSTS, VD9_CCUSTA, VD9_CCUSTB, VD9_CCUSTC, VD9_TIPO, VD9_ACUMUL, VD9_EXPRES, SUM(VDC_VALOR) AS SOMA"
	else
		cQuery := "SELECT VD9.R_E_C_N_O_, VD9_CPODEF, VD9_CODCON, VD9_CONCTA, VD9_DESCRI, VD9_CCUSTS, VD9_TIPO, VD9_ACUMUL, VD9_EXPRES, SUM(VDC_VALOR) AS SOMA"
	endif
	cQuery += " FROM " + RetSqlName("VD9") + " VD9"
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("VDC") + " VDC ON ("
	cQuery += " 	VD9_CODDEF = VDC_CODDEF"
	cQuery += " 	AND VD9_CODCON = VDC_CODCON"
	cQuery += " 	AND  VDC_DATA = '"+dtos(VDB->VDB_DATA)+"'"
	cQuery += " 	AND VDC_FILIAL IN ("+cFilSqlIn+") "
	cQuery += " 	AND VDC.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE VD9_CODDEF = '"+VDB->VDB_CODDEF+"'"
	cQuery += " AND VD9_FILIAL = '"+xFilial("VD9")+"'"
	cQuery += " AND VD9.D_E_L_E_T_ = ' '"
	if VD9->(FieldPos("VD9_CCUSTA")) > 0 
		cQuery += " GROUP BY VD9.R_E_C_N_O_, VD9_CPODEF, VD9_CODCON, VD9_CONCTA, VD9_DESCRI,  VD9_CCUSTS, VD9_CCUSTA, VD9_CCUSTB, VD9_CCUSTC, VD9_TIPO, VD9_ACUMUL, VD9_EXPRES"
	else
		cQuery += " GROUP BY VD9.R_E_C_N_O_, VD9_CPODEF, VD9_CODCON, VD9_CONCTA, VD9_DESCRI,  VD9_CCUSTS, VD9_TIPO, VD9_ACUMUL, VD9_EXPRES"	
	endif
	cQuery += " ORDER BY VD9.R_E_C_N_O_"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD9, .T., .T. )
	aVetTudo := {}
	While !(SQLVD9->(Eof()))
		if VD9->(FieldPos("VD9_CCUSTA")) > 0 
			aAdd(aVetTudo, { SQLVD9->VD9_CPODEF, SQLVD9->VD9_CODCON, SQLVD9->VD9_CONCTA, SQLVD9->VD9_DESCRI, SQLVD9->SOMA, Alltrim(SQLVD9->VD9_CCUSTS)+Alltrim(SQLVD9->VD9_CCUSTA)+Alltrim(SQLVD9->VD9_CCUSTB)+Alltrim(SQLVD9->VD9_CCUSTC), SQLVD9->VD9_TIPO, SQLVD9->VD9_ACUMUL, SQLVD9->VD9_EXPRES  } )
		else
			aAdd(aVetTudo, { SQLVD9->VD9_CPODEF, SQLVD9->VD9_CODCON, SQLVD9->VD9_CONCTA, SQLVD9->VD9_DESCRI, SQLVD9->SOMA, SQLVD9->VD9_CCUSTS, SQLVD9->VD9_TIPO, SQLVD9->VD9_ACUMUL, SQLVD9->VD9_EXPRES  } )
		endif
		SQLVD9->(dbSkip())
	enddo
	SQLVD9->(DbCloseArea())

else
		if VD9->(FieldPos("VD9_CCUSTA")) > 0 
			cQuery := " SELECT VD9_CPODEF, VD9_CODCON, VD9_CONCTA, VD9_DESCRI, VDC_VALOR, VD9_CCUSTS, VD9_CCUSTA, VD9_CCUSTB, VD9_CCUSTC, VD9_TIPO, VD9_ACUMUL, VD9_EXPRES"
		else
			cQuery := " SELECT VD9_CPODEF, VD9_CODCON, VD9_CONCTA, VD9_DESCRI, VDC_VALOR, VD9_CCUSTS,  VD9_TIPO, VD9_ACUMUL, VD9_EXPRES"
		endif
		cQuery += " FROM " + RetSqlName("VD9") + " VD9"
		cQuery += " LEFT OUTER JOIN "+ RetSqlName("VDC") + " VDC ON ("
		cQuery += " 	VD9_CODDEF = VDC_CODDEF"
		cQuery += " 	AND VD9_CODCON = VDC_CODCON"
		cQuery += " 	AND  VDC_DATA = '"+dtos(VDB->VDB_DATA)+"'"
		cQuery += " 	AND VDC_FILIAL = '"+xFilial("VDC")+"'"
		cQuery += " 	AND VDC.D_E_L_E_T_ = ' ' )"
		cQuery += " WHERE VD9_CODDEF = '"+VDB->VDB_CODDEF+"'"
		cQuery += " AND VD9_FILIAL = '"+xFilial("VD9")+"'"
		cQuery += " AND VD9.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY VD9.R_E_C_N_O_"
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD9, .T., .T. )

	aFaltantes := {}
	aResolv := {}

	DBSelectArea(cAliasVD9)

	aVetTudo := {}

	While !(SQLVD9->(Eof()))
		if SQLVD9->VD9_TIPO $ "25"
			aAdd(aFaltantes, {SQLVD9->VD9_CPODEF, .f.})
			if VD9->(FieldPos("VD9_CCUSTA")) > 0 
				aAdd(aVetTudo, { SQLVD9->VD9_CPODEF, SQLVD9->VD9_CODCON, SQLVD9->VD9_CONCTA, SQLVD9->VD9_DESCRI, SQLVD9->VDC_VALOR, Alltrim(SQLVD9->VD9_CCUSTS)+Alltrim(SQLVD9->VD9_CCUSTA)+Alltrim(SQLVD9->VD9_CCUSTB)+Alltrim(SQLVD9->VD9_CCUSTC), SQLVD9->VD9_TIPO, SQLVD9->VD9_ACUMUL, SQLVD9->VD9_EXPRES  } )
			else
				aAdd(aVetTudo, { SQLVD9->VD9_CPODEF, SQLVD9->VD9_CODCON, SQLVD9->VD9_CONCTA, SQLVD9->VD9_DESCRI, SQLVD9->VDC_VALOR, SQLVD9->VD9_CCUSTS, SQLVD9->VD9_TIPO, SQLVD9->VD9_ACUMUL, SQLVD9->VD9_EXPRES  } )			
			endif
		else
			lAtivo := .t.
			DBSelectArea("VDA")
			DBSetOrder(1)
			DBSeek(xFilial("VDA")+VDB->VDB_CODDEF+SQLVD9->VD9_CODCON)
			nValAcum := 0
			while !eof().and.VDB->VDB_CODDEF+SQLVD9->VD9_CODCON == VDA->VDA_CODDEF + VDA->VDA_CODCON
				if (Alltrim(VDA->VDA_CODEMP) == Alltrim(cEmpAnt) .and. Alltrim(VDA->VDA_CODFIL) == Alltrim(cFilAnt))
					if VDA->VDA_ATIVO == "0"
						lAtivo := .f.
					endif
				else
					if Alltrim(cFilAnt) == Alltrim(VDA->VDA_ACUMEM)
						DBSelectArea("VDC")
						DBSetOrder(1)
						if DBSeek(Left(Alltrim(VDA->VDA_CODFIL)+space(20),TamSX3("VDC_FILIAL")[1])+VDB->VDB_CODDEF+dtos(VDB->VDB_DATA)+SQLVD9->VD9_CODCON)
							nValAcum += VDC->VDC_VALOR
						endif
					endif
				endif
				DBSelectArea("VDA")
				DBSkip()
			enddo
			if !Empty(VDA->VDA_ACUMEM) .and. Alltrim(cFilAnt) != Alltrim(VDA->VDA_ACUMEM)
				nZeraAcu := 0
			else
				nZeraAcu := 1
			endif
			aAdd(aResolv,{SQLVD9->VD9_CPODEF,IIF(lAtivo,nZeraAcu * (SQLVD9->VDC_VALOR + nValAcum),0)})
			if VD9->(FieldPos("VD9_CCUSTA")) > 0 
				aAdd(aVetTudo,{ SQLVD9->VD9_CPODEF, SQLVD9->VD9_CODCON, SQLVD9->VD9_CONCTA, SQLVD9->VD9_DESCRI, IIF(lAtivo,nZeraAcu * (SQLVD9->VDC_VALOR + nValAcum),0), Alltrim(SQLVD9->VD9_CCUSTS)+Alltrim(SQLVD9->VD9_CCUSTA)+Alltrim(SQLVD9->VD9_CCUSTB)+Alltrim(SQLVD9->VD9_CCUSTC), SQLVD9->VD9_TIPO, SQLVD9->VD9_ACUMUL, SQLVD9->VD9_EXPRES})
			else
				aAdd(aVetTudo,{ SQLVD9->VD9_CPODEF, SQLVD9->VD9_CODCON, SQLVD9->VD9_CONCTA, SQLVD9->VD9_DESCRI, IIF(lAtivo,nZeraAcu * (SQLVD9->VDC_VALOR + nValAcum),0), SQLVD9->VD9_CCUSTS, SQLVD9->VD9_TIPO, SQLVD9->VD9_ACUMUL, SQLVD9->VD9_EXPRES})
			endif
		endif
		SQLVD9->(dbSkip())
	enddo
	//
	// R E C A L C U L O
	//
	lAindaFalta := .t.
	nInfoFal := -1
	aInfoFal := {}
	while lAindaFalta
		lAindaFalta := .f.
		if Len(aInfoFal) == nInfoFal
			IF (nHandle := FCREATE("OXA051DUMP.TXT", FC_NORMAL)) != -1
				for nCntFor = 1 to Len(aInfoFal)
					FWRITE(nHandle, aInfoFal[nCntFor]+CHR(13)+CHR(10))
				next
				FCLOSE(nHandle)
			ENDIF
			return
		endif
		nInfoFal := Len(aInfoFal)
		aInfoFal := {}
		for nCntFor := 1 to Len(aFaltantes)
			if aFaltantes[nCntFor,2]
				loop
			endif
			lAindaFalta := .t.
			nPos := Ascan(aVetTudo,{ |x| Alltrim(x[1]) == Alltrim(aFaltantes[nCntFor,1]) })
			nVal := 0
			if aVetTudo[nPos,7] == "5" // Se a conta representa um acumulado de outra devemos calcular
				nPos2 = aScan(aResolv, {|x| Alltrim(x[1]) == Alltrim(aVetTudo[nPos,8])})
				if nPos2 > 0
					nVal += aResolv[nPos2,2]
					VD9->(DBSetOrder(2))
					if VD9->(DBSeek(xFilial("VD9")+VDB->VDB_CODDEF+Alltrim(aVetTudo[nPos,8])))
						for nCntFor2 = Month(VDB->VDB_DATA) to 1 step -1
							dDataSeek := ctod("01/"+ STRZERO(nCntFor2,2)+"/"+Right(STRZERO(Year(VDB->VDB_DATA),4),2))-1
							if VDC->(DBSeek(xFilial("VDC")+VDB->VDB_CODDEF+dtos(VDB->VDB_DATA)+VD9->VD9_CODCON))
								nVal += VDC->VDC_VALOR
							endif
						next
					endif
					// remove a conta dos faltantes e insere nos resolvidos
					aFaltantes[nCntFor,2] := .t.
					aAdd(aResolv,{aFaltantes[nCntFor,1], IIF(nVal==NIL,0,nVal) })
				else
					aAdd(aInfoFal,aFaltantes[nCntFor,1]+ " A "+aVetTudo[nPos,8])
				endif
			elseif aVetTudo[nPos,7] == "2" // Se a conta representa uma expressão devemos calculá-la
				// se a função FMX_CALXPDEF retornar uma string, a conta é faltante, caso contrário o resultado está em nVal
				cResFalt :=  FMX_CALXPDEF(aVetTudo[nPos,2],aVetTudo[nPos,9],aResolv,nVal)
				if Empty(cResFalt)
					// remove a conta dos faltantes e insere nos resolvidos
					aFaltantes[nCntFor,2] := .t.
					aAdd(aResolv,{aFaltantes[nCntFor,1], IIF(nVal==NIL,0,nVal) })
				else
					aAdd(aInfoFal,aFaltantes[nCntFor,1]+ " E "+cResFalt)
				endif
			endif
		next
	EndDo
endif

for nCntFor := 1 to Len(aResolv)
	nPos := Ascan(aVetTudo,{ |x| Alltrim(x[1]) == Alltrim(aResolv[nCntFor,1]) })
	if nPos > 0
		aVetTudo[nPos,5] := aResolv[nCntFor,2]
	endif
next

for nCntFor := 1 to Len(aVetTudo)
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	if aVetTudo[nCntFor,7] == "0"
		cTipo := "(SIN)"
	elseif aVetTudo[nCntFor,7] == "1"
		cTipo := "(CLC)"
	elseif  aVetTudo[nCntFor,7] == "2"
		cTipo := "(EXP)"
	elseif  aVetTudo[nCntFor,7] == "3"
		cTipo := "(CTB)"
	elseif  aVetTudo[nCntFor,7] == "4"
		cTipo := "(CT+)"
	elseif  aVetTudo[nCntFor,7] == "5"
		cTipo := "(ACU)"
	elseif  aVetTudo[nCntFor,7] == "6"
		cTipo := "(ZER)"
	elseif  aVetTudo[nCntFor,7] == "7"
		cTipo := "(XCT)"
	elseif  aVetTudo[nCntFor,7] == "8"
		cTipo := "(BLQ)"
	elseif  aVetTudo[nCntFor,7] == "9"
		cTipo := "(SDF)"
	endif
	//0=Sintetico;1=Calculado;2=Expressao;3=CCTERP;4=Acumulado
	if MV_PAR01 == 2 .and. aVetTudo[nCntFor,7] $ "1234678"
	   loop
	endif
	// SQLVD9->VD9_CPODEF, SQLVD9->VD9_CODCON, SQLVD9->VD9_CONCTA, SQLVD9->VD9_DESCRI, IIF(lAtivo,SQLVD9->VDC_VALOR + nValAcum,0), SQLVD9->VD9_CCUSTS, SQLVD9->VD9_TIPO, SQLVD9->VD9_ACUMUL, SQLVD9->VD9_EXPRES
	if MV_PAR02 == 1 .or. aVetTudo[nCntFor,5] != 0 .or. aVetTudo[nCntFor,7] == "0"
		@ Li, 1   PSay aVetTudo[nCntFor,2] + "-"+Left(aVetTudo[nCntFor,3],18) +" "+ Left(aVetTudo[nCntFor,4],65)+" "+IIF(!Empty(aVetTudo[nCntFor,6]),"("+Alltrim(aVetTudo[nCntFor,6])+")","")+cTipo
		if aVetTudo[nCntFor,7] # "0"
			@ Li, 115  PSay  aVetTudo[nCntFor,5] PICTURE "@E 99,999,999,999.99"
		endif
		li++
	endif
next

If lEnd
	@ Li, aCol[1] PSay cCancel
	Return
Endif

If Li <> 80
	Roda(cbCont,cbTxt,Tamanho)
Endif

If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf

Ms_Flush()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OA053MHIST³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela que exibe o histrórico de geração de um determinado DEF           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA053MHIST()

Local cCodDef := M->VDB_CODDEF
Local cCodCon := oGetDados1:aCols[oGetDados1:nAt,fg_posvar("VDC_CODCON","aHeaderF1")]
Local aVetHist := {}

cQryAl001 := GetNextAlias()
cQuery := "SELECT VDC_DATA, VDC_VALOR FROM "+RetSqlName("VDC")
cQuery += " WHERE VDC_FILIAL ='" + xFilial("VDC") + "' AND VDC_CODDEF='" + cCodDef + "' AND"
cQuery += " VDC_CODCON='" + cCodCon + "' AND D_E_L_E_T_=' ' ORDER BY VDC_DATA"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )

While !(cQryAl001)->(eof())
	aAdd(aVetHist,{ stod( (cQryAl001)->(VDC_DATA) ), Transform( (cQryAl001)->(VDC_VALOR),"@E 999,999,999.99" ) } )
	(cQryAl001)->(DBSkip())
enddo
(cQryAl001)->(dbCloseArea())
DBSelectArea("VD9")

if Len(aVetHist) == 0
	MsgInfo(STR0015,STR0003)
	return .f.
endif

DEFINE MSDIALOG oHistCC TITLE STR0001 FROM 0,0 TO 200,400 OF oMainWnd PIXEL // Avaliacao de Veiculos Usados
@ 3,3 LISTBOX oLbVEITroc FIELDS HEADER  STR0016, STR0017	COLSIZES 40,40 SIZE 196, 95 OF oHistCC PIXEL
oLbVEITroc:SetArray(aVetHist)
oLbVEITroc:bLine := { || { aVetHist[oLbVEITroc:nAt,1],;
							FG_AlinVlrs(aVetHist[oLbVEITroc:nAt,2]) }}
ACTIVATE MSDIALOG oHistCC CENTER

return

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
Local aRotina := {	{ STR0011 	,"AxPesqui"   , 0 , 1},;			// Pesquisar
					{ STR0012	,"OXA053V"    , 0 , 2},;			// Visualizar
					{ STR0027	,"OC2000011_Consultar"    , 0 , 2},;			// Consulta Detalhada por Campo DEF
					{ STR0013	,"OXA053I"    , 0 , 3},;			// Imprimir
					{ STR0014	,"OXA053A"    , 0 , 4} }			// Alterar
//
Return aRotina

Function OXA053LogCalculo()

	Local cCodDef := M->VDB_CODDEF
	Local cCodCon
	Local dDataFechamento := M->VDB_DATA

	cCodCon := oGetDados1:aCols[oGetDados1:nAt,FG_POSVAR("VDC_CODCON","aHeaderF1")]

	OX052LogCalculo(cCodDef, cCodCon, dDataFechamento)

Return
