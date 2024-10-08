#INCLUDE "PCOA210.ch"
#INCLUDE "PROTHEUS.CH"


Static aCombo := NIL
Static cConteudo := NIL
Static aSelOpc := {}

/*
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA210  � AUTOR � Paulo Carnelossi      � DATA � 25/08/2005 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa para manutencao restricao de acessos usuarios as    潮�
北�          � entidades                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA210                                                      潮�
北砡DESCRI_  � Programa para manutencao restricao de acessos usuarios as    潮�
北�          � entidades                                                    潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOA210(2) - Executa a chamada da funcao de visua-  潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA210(nCallOpcx,lAuto,aCposVs, nUtiliz)


Local lRet      := .T.
Local xOldInt
Local lOldAuto

If ValType(lAuto) != "L" 
	lAuto := .F.
EndIf

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	__cInternet := 'AUTOMATICO'
EndIf

Default nUtiliz := 1


Private aCposVisual	:= aCposVs
Private cCadastro	:= STR0001 //"Manuten玢o de Restricao de Usuarios as Entidades"
Private aRotina := MenuDef()

	dbSelectArea("AL6")
	dbSetOrder(1)
	If nCallOpcx <> Nil
		lRet := A210DLG("AL6",AL6->(RecNo()),nCallOpcx,,,lAuto, nUtiliz)
	Else
		mBrowse(6,1,22,75,"AL6",,,,,,PCOA210Leg() )
	EndIf


lMsHelpAuto := lOldAuto
__cInternet := xOldInt

aCombo := NIL
cConteudo := NIL
aSelOpc := {}

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨210DLG   篈utor  砅aulo Carnelossi    � Data �  25/08/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- 罕�
北�          � zacao                                                      罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function A210DLG(cAlias,nRecnoAL6,nCallOpcx,cR1,cR2,lAuto,nUtiliz)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {{"PESQUISA",{||PcoA210Pesq() },STR0014,STR0013} } //"Consulta Padrao"###"Pesquisa"
Local aUsButtons := {}
Local oEnchAL6

Local aHeadAL7
Local aColsAL7
Local nLenAL7   := 0 // Numero de campos em uso no AL7
Local nLinAL7   := 0 // Linha atual do acols
Local aRecAL7   := {} // Recnos dos registros
Local nGetD
Local cEntidade
Local aCposEnch
Local aUsField
Local aAreaAL6 := AL6->(GetArea()) // Salva Area do AL6
Local aAreaAL7 := AL7->(GetArea()) // Salva Area do AL6
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local nRecAL6 := nRecnoAL6
Local aCpos_Nao := {}
Local oSize
Local nLinIni := 0 
Local nColIni := 0 
Local nLinEnd := 0
Local nColEnd := 0 

DEFAULT nUtiliz := 1

Private INCLUI  := (nCallOpcx = 3)
Private oGdAL7
PRIVATE aTELA[0][0],aGETS[0]

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

If ValType(lAuto) != "L" 
	lAuto := .F.
EndIf

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	__cInternet := 'AUTOMATICO'
EndIf

If lAuto .And. !(nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAL6) == "N" .And. nRecnoAL6 > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAL6)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAL6)))
		Return .F.
	EndIf
	aAreaAL6 := AL6->(GetArea()) // Salva Area do AL6 por causa do Recno e do Indice
EndIf

If nCallOpcx == 5 .And. AL6->AL6_ATIVO == "1"
	Aviso(STR0007, STR0009, {"Ok"}, 2)// "Aten玢o"### "Exclusao nao permitida. Devera ser inativado o uso desta restricao."
	Return .F.
EndIf

If nUtiliz == 2 .OR. nUtiliz == 3
	aAdd(aCpos_Nao, "AL6_CPOITE")
	aAdd(aCpos_Nao, "AL6_CPOMOV")
Else
	If (nCallOpcx == 4 .Or. nCallOpcx == 5) .And. nUtiliz == 1
		If Alltrim(AL6->AL6_ENTIDA) == "AL3"
		   Aviso(STR0007, STR0017,{"Ok"})//"Atencao"###"Para manutencao de acesso na entidade AL3 utilizar rotina Restricao Acesso a Configuracao de Cubos."
		   Return .F.
		EndIf   
	EndIf
EndIf	

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Adiciona botoes do usuario na EnchoiceBar                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA2102" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de configuracao dos lancamentos                                �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA2102                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	If ValType( aUsButtons := ExecBlock( "PCOA2102", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto
	oSize := FwDefSize():New(.T.,,,)
	oSize:AddObject( "CABECALHO",  100, 40, .T., .T. ) 
	oSize:AddObject( "GETDADOS" ,  100, 60, .T., .T. ) 
	oSize:lProp 	:= .T. 
	oSize:Process() 
	
	DEFINE MSDIALOG oDlg TITLE STR0010 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Enchoice com os dados do Processo                                      �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	nLinIni := oSize:GetDimension("CABECALHO","LININI") 
	nColIni := oSize:GetDimension("CABECALHO","COLINI") 
	nLinEnd := oSize:GetDimension("CABECALHO","LINEND")
	nColEnd := oSize:GetDimension("CABECALHO","COLEND") 
EndIf

aCposEnch := PcoCpoEnchoice("AL6", aCpos_Nao)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ponto de entrada para adicionar campos no cabecalho                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA2103" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para adicionar campos no cabecalho          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as os campos a serem adicionados           �
	//P_E�               Ex. :  User Function PCOA2103                            �
	//P_E�                      Return {"AL6_FIELD1","AL6_FIELD2"}                �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ValType( aUsField := ExecBlock( "PCOA2103", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
EndIf
 
// Carrega dados do AL6 para memoria
RegToMemory("AL6",INCLUI)


If nCallOpcx == 3
	If nUtiliz == 2 //se inclusao e restricao configuracao cubo
		M->AL6_ENTIDA := PadR("AL3", Len(AL6->AL6_ENTIDA))
		M->AL6_CONPAD := PadR("AL31", Len(AL6->AL6_CONPAD))
		M->AL6_NOMENT := Posicione("SX2", 1, M->AL6_ENTIDA, "X2NOME()")
		M->AL6_TAMANH := Len(AL3->AL3_CONFIG+AL3->AL3_CODIGO)
		M->AL6_UTILIZ := "2"
	ElseIf nUtiliz == 3 //se inclusao e restricao configuracao cubo
		M->AL6_ENTIDA := PadR("AKN", Len(AL6->AL6_ENTIDA))
		M->AL6_CONPAD := PadR("AKN", Len(AL6->AL6_CONPAD))
		M->AL6_NOMENT := Posicione("SX2", 1, M->AL6_ENTIDA, "X2NOME()")
		M->AL6_TAMANH := Len(AKN->AKN_CODIGO)
		M->AL6_UTILIZ := "3"
	EndIf
EndIf

If !lAuto
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Enchoice com os dados dos Lancamentos                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	
	If nCallOpcx == 2 .OR. nCallOpcx == 5
		oEnchAL6 := MSMGet():New('AL6',,4/*nCallOpcx*/,,,,aCposEnch,{nLinIni,nColIni,nLinEnd,nColEnd},,,,,,oDlg,,,,,,,,,)
	Else
		oEnchAL6 := MSMGet():New('AL6',,nCallOpcx,,,,aCposEnch,{nLinIni,nColIni,nLinEnd,nColEnd},,,,,,oDlg,,,,,,,,,)
	EndIf
	oEnchAL6:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	If nCallOpcx <> 3
		If ( nPos := aScan(oEnchAL6:aGets, {|x|"AL6_CONPAD" $x}) ) > 0
			oEnchAL6:AENTRYCTRLS[nPos]:nAt := Pco210SlF3()
			If nCallOpcx == 2 .OR. nCallOpcx == 5
				oEnchAL6:Disable()
			EndIf
		EndIf
	EndIf
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aHeader do AL7                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aHeadAL7 := GetaHeader("AL7",,aCposEnch,@aEnchAuto,aCposVisual)
nLenAL7  := Len(aHeadAL7) + 1

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aCols do AL7                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

aColsAL7 := {}

If !INCLUI
	DbSelectArea("AL7")
	DbSetOrder(1)
	DbSeek(xFilial()+AL6->AL6_ENTIDADE)
	
	cEntidade := AL6->AL6_FILIAL + AL6->AL6_ENTIDADE
	While nCallOpcx != 3 .And. !Eof() .And. AL7->AL7_FILIAL + AL7->AL7_ENTIDADE == cEntidade
		AAdd(aColsAL7,Array( nLenAL7 ))
		nLinAL7++
		// Varre o aHeader para preencher o acols
		AEval(aHeadAL7, {|x,y| aColsAL7[nLinAL7][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })
	
		// Deleted
		aColsAL7[nLinAL7][nLenAL7] := .F.
		
		// Adiciona o Recno no aRec
		AAdd( aRecAL7, AL7->( Recno() ) )
		
		AL7->(DbSkip())
		
	EndDo
EndIf

// Verifica se n鉶 foi criada nenhuma linha para o aCols
If Len(aColsAL7) = 0
	AAdd(aColsAL7,Array( nLenAL7 ))
	nLinAL7++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAL7, {|x,y| aColsAL7[nLinAL7][y] := IIf(Upper(AllTrim(x[2])) == "AL7_ID", StrZero(1,Len(AL7->AL7_ID)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAL7[nLinAL7][nLenAL7] := .F.
EndIf

If !lAuto
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� GetDados com os Lancamentos                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If nCallOpcx = 3 .Or. nCallOpcx = 4 
		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf

	oGdAL7:= MsNewGetDados():New(3,3,oSize:GetDimension("GETDADOS","YSIZE") - 16,oSize:GetDimension("GETDADOS","XSIZE") - 4,nGetd,"AL7LinOK",,"+AL7_ID",,,9999,,,,oDlg,aHeadAL7,aColsAL7)
	oGdAL7:oBrowse:Align := CONTROL_ALIGN_BOTTOM
	oGdAL7:CARGO := AClone(aRecAL7)
	oGdAL7:oBrowse:Refresh()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(obrigatorio(aGets,aTela) .And. A210Ok(nCallOpcx,nRecAL6,oGdAL7:Cargo,aEnchAuto,oGdAL7:aCols,oGdAL7:aHeader),oDlg:End(),Nil)},{|| lCancel := .T., oDlg:End() },,aButtons)

	
Else
	lCancel := !A210Ok(nCallOpcx,nRecAL6,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7,lAuto)
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaAL7)
RestArea(aAreaAL6)
Return !lCancel

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A210Ok   篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao do botao OK da enchoice bar, valida e faz o         罕�
北�          � tratamento adequado das informacoes.                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A210Ok(nCallOpcx,nRecAL6,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7,lAuto)
Local nI
Local nX
Local aAreaAL7	:= AL7->(GetArea())
Local aAreaAL6	:= AL6->(GetArea())
Local aRecAux   := aClone(aRecAL7)
Local bCampo 	:= {|n| FieldName(n) }

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If !A210Vld(nCallOpcx,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7)
	Return .F.
EndIf

AL6->(DbSetOrder(1))
AL7->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao
	dbSelectArea("AL6")
	Reclock("AL6",.T.)
	// Grava Campos do Cabecalho
	If lAuto
		For nX := 1 To Len(aEnchAuto)
			FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
		Next nX
    Else
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
	EndIf
	AL6->AL6_FILIAL := xFilial("AL6")
	MsUnlock()	

	// Grava Lancamentos
	For nI := 1 To Len(aColsAL7)
		If aColsAL7[nI][Len(aColsAL7[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AL7",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(aHeadAL7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAL7[nI][y])), ) })

		// Grava campos que nao estao disponiveis na tela
		Replace AL7_FILIAL With xFilial()
		Replace AL7_ENTIDA With AL6->AL6_ENTIDA
		Replace AL7_TAMANH With AL6->AL6_TAMANH
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	dbSelectArea("AL6")
	dbGoto(nRecAL6)
	Reclock("AL6",.F.)

	// Grava Campos do Cabecalho
	If lAuto
		For nX := 1 To Len(aEnchAuto)
			FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
		Next nX
    Else
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
	EndIf	
	MsUnlock()	

	// Grava Lancamentos
	dbSelectArea("AL7")
	//primeiro exclui os registros
	For nI := 1 TO Len(aRecAux)
		dbGoto(aRecAux[nI])
		Reclock("AL7",.F.)
		dbDelete()
		MsUnlock()
    Next
	//depois grava novos registros	
	For nI := 1 To Len(aColsAL7)
		If aColsAL7[nI][Len(aColsAL7[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AL7",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(aHeadAL7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAL7[nI][y])), ) })

		// Grava campos que nao estao disponiveis na tela
		Replace AL7_FILIAL With xFilial()
		Replace AL7_ENTIDA With AL6->AL6_ENTIDA
		Replace AL7_TAMANH With AL6->AL6_TAMANH
		MsUnlock()
		
	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	// Grava Lancamentos
	For nI := 1 To Len(aRecAL7)
		dbGoto(aRecAL7[nI])
		Reclock("AL7",.F.)
		dbDelete()
		MsUnlock()
	Next nI
	
	dbSelectArea("AL6")
	dbGoto(nRecAL6)
	Reclock("AL6",.F.)
	dbDelete()
	MsUnlock()

EndIf

AL7->(RestArea(aAreaAL7))
AL6->(RestArea(aAreaAL6))

Return .T.

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A210Vld  篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao de validacao dos campos.                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A210Vld(nCallOpcx,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7)
Local nI
Local nPosTipo
If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .T.
EndIf


If ( AScan(aEnchAuto,{|x| x[17] .And. Empty( &( "M->" + x[2] ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsAL7)
	// Busca por campos obrigatorios que nao estejam preenchidos
	nPosField := AScanx(aHeadAL7,{|x,y| x[17] .And. Empty(aColsAL7[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AL7"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0015+ AllTrim(aHeadAL7[nPosField][1])+CHR(10)+CHR(13)+STR0016+Str(nI,3,0),3,1) //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    矨L7LinOK    � Autor � Paulo Carnelossi    � Data � 25/08/05   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 砎alidacao da LinOK da Getdados                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      砅COXFUN                                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AL7LinOK()
Local lRet			:= .T.

If !aCols[n][Len(aCols[n])]
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Verifica os campos obrigatorios do SX3.              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n) 
	EndIf
EndIf
	
Return lRet

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    砅COA210Leg� Autor � Paulo Carnelossi      � Data � 25/08/05 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Monta as legendas da mBrowse.                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅COA210Leg                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Acaa170                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PCOA210Leg(cAlias)
Local aLegenda := 	{ 	{"BR_VERDE"   , STR0011 },; //"Restri玢o Ativa"
						{"BR_VERMELHO", STR0012 } }//"Restri玢o Inativa"
Local aRet := {}
aRet := {}
	
If cAlias == Nil
	Aadd(aRet, { 'AL6->AL6_ATIVO == "1"', aLegenda[1][1] } )
	Aadd(aRet, { 'AL6->AL6_ATIVO == "2"', aLegenda[2][1] } )
Else
	BrwLegenda(cCadastro,STR0008, aLegenda) //"Legenda"
Endif

Return aRet


Function PcoA210Pesq(o)
Local cContConPad
Local lContinua := .T.

If Alltrim(oGdAL7:aHeader[oGdAL7:oBrowse:ColPos][2]) == "AL7_FX_INI" .Or. ;
	Alltrim(oGdAL7:aHeader[oGdAL7:oBrowse:ColPos][2]) == "AL7_FX_FIN"
	dbSelectArea("SXB")
	dbSetOrder(1)

	If dbSeek(PadR(M->AL6_CONPAD, Len(SXB->XB_ALIAS))+;
				PadR("5", Len(SXB->XB_TIPO))+;
				PadR("01", Len(SXB->XB_SEQ))+;
				PadR(" ", Len(SXB->XB_COLUNA)))
		cContConPad := M->AL6_ENTIDA+"->("+SXB->XB_CONTEM+")"
				
		If ConPad1( , , , PadR(M->AL6_CONPAD, Len(SXB->XB_ALIAS)), , , .F. )
			oGdAL7:aCols[oGdAL7:nAt][oGdAL7:oBrowse:ColPos]:= &(cContConPad)
		EndIf	
	EndIf
EndIf

Return		


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯槐�
北篜rograma  砅coAcess_CfgCubo篈utor 砅aulo Carnelossi � Data � 11/11/05  罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯贡�
北篋esc.     砇otina de manutencao do cadastro de restricao de acesso para罕�
北�          砪onfiguracao de cubo (nOpcx = 0 Inclusao/Alteracao          罕�
北�          �                      nOpcx = 5 Exclusao)                   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PcoAcess_CfgCubo(nOpcx)
Local lAcessoCube
Local nUtiliz := 2
DEFAULT nOpcx := 0

dbSelectArea("AL6")
dbSetOrder(1)

lAcessoCube := dbSeek(xFilial("AL6")+"AL3")

If nOpcx == 0
	If ! lAcessoCube
		PCOA210(3,,, nUtiliz)   //inclusao
	Else
		PCOA210(4,,, nUtiliz)   //alteracao
	EndIf
ElseIf nOpcx == 5
	If lAcessoCube
		PCOA210(5,,, nUtiliz)  //exclusao
	Else
		Aviso(STR0007, STR0020, {"Ok"})  //"Atencao"###"Restricao de acesso a configuracao de cubo nao encontrada."
	EndIf	
EndIf

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅coCpoEnchoice篈utor 砅aulo Carnelossi � Data �  11/11/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砇etorna array com nomes dos campos referente ao alias       罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function PcoCpoEnchoice(cAlias, aCpos_Nao)
Local aCampos := {}
Local aArea := GetArea()
Local aAreaSX3 := SX3->(GetArea())

SX3->(DbSetOrder(1))
SX3->(MsSeek(cAlias))

While ! SX3->(Eof()) .And. SX3->x3_arquivo == cAlias
    If X3USO(SX3->x3_usado) .And. cNivel >= SX3->x3_nivel .And. ;
    	aScan(aCpos_Nao, AllTrim(SX3->x3_campo))==0
	    aAdd(aCampos, AllTrim(SX3->x3_campo))
	EndIf    
	SX3->(DbSkip())
EndDo

RestArea(aArea)
RestArea(aAreaSX3)

Return aCampos

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯槐�
北篜rograma  砅coVisao_Acesso 篈utor 砅aulo Carnelossi � Data � 18/11/05  罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯贡�
北篋esc.     砇otina de manutencao do cadastro de restricao de acesso para罕�
北�          硋isao gerencial (nOpcx = 0 Inclusao/Alteracao               罕�
北�          �                      nOpcx = 5 Exclusao)                   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PcoVisao_Acesso(nOpcx)
Local lAcessoVisao
Local nUtiliz := 3
DEFAULT nOpcx := 0

dbSelectArea("AL6")
dbSetOrder(1)

lAcessoVisao := dbSeek(xFilial("AL6")+"AKN")

If nOpcx == 0
	If ! lAcessoVisao
		PCOA210(3,,, nUtiliz)   //inclusao
	Else
		PCOA210(4,,, nUtiliz)   //alteracao
	EndIf
ElseIf nOpcx == 5
	If lAcessoVisao
		PCOA210(5,,, nUtiliz)  //exclusao
	Else
		Aviso(STR0007, STR0021, {"Ok"})  //"Atencao"###"Restricao de acesso a visao gerencial nao encontrada."
	EndIf	
EndIf

Return


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Ana Paula N. Silva     � Data �29/11/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados     潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	    "A210DLG"  , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A210DLG"  , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"A210DLG"  , 0 , 4},; //"Alterar"
							{ STR0006, 		"A210DLG"  , 0 , 5},; //"Excluir"
							{ STR0008, 		"PCOA210Leg"  , 0 , 2, ,.F.}} //"Legenda"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no aRotina                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA2101" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de lan鏰mentos                                          �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA2101                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA2101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)



//北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪幢�
//北� Funcao Pco210Combo() para realizar  consulta padrao     潮�
//北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪哪哪哪幢�

Function Pco210Combo()
Local cRetorno:= ""
Local nX:= 0
Local cDescri:= ""
Local cCodigo:= ""

If aCombo == NIL
	aCombo:= SeleF3()
EndIf

If cConteudo == NIL
	For nX:=1 to Len(aCombo)
	
		cCodigo:= Subs(aCombo[nX],1, At("-",aCombo[nX])-2 )
		cDescri:= Subs(aCombo[nX],At("-",aCombo[nX])+1 )
		If Empty(cCodigo)
			cCodigo := Space(6)
			cDescri := "Consulta N鉶 Selecionada"
		EndIf
		
		cRetorno += PadR(cCodigo,6)+"="+Alltrim(cDescri) + If(nX == Len(aCombo),"", ";")
	
	Next
	
	cConteudo := cRetorno
Else
	cRetorno := cConteudo
EndIf

Return cRetorno 



Static Function Pco210SlF3()
Local cCodigo := Space(6)
Local nRet    := 1
Local nX
Local nPosArray := 0

If aCombo == NIL
	aCombo:= SeleF3()
EndIf

If ( nPosArray := aScan( aSelOpc, {|x| Alltrim(x[1]) == Alltrim(AL6->AL6_CONPAD) } ) ) == 0

	For nX:=1 to Len(aCombo)
	
		cCodigo:= Subs(aCombo[nX],1, At("-",aCombo[nX])-2 )
		If Empty(cCodigo) .And. Empty(Alltrim(AL6->AL6_CONPAD))
			nRet := 1
			Exit
		Else
			If Alltrim(cCodigo) == Alltrim(AL6->AL6_CONPAD)
				nRet := nX
				Exit
			EndIf
		EndIf
	Next
	aAdd(aSelOpc ,  { cCodigo, nRet} ) 
	
Else
	nRet := aSelOpc[nPosArray,2]
EndIf


Return(nRet)




