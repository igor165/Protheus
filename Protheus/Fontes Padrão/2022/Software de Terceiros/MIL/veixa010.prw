#Include "protheus.ch"
#Include "VEIXA010.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VEIXA010 � Autor �  Luis Delorme         � Data � 05/12/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Veiculos                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� xRotAuto : Array com informacoes do VV1                    ���
���          � nOpcAuto : 3-Incluir / 4-Alterar / 5-Excluir               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEIXA010(xRotAuto,nOpcAuto)
Private aRotAuto   := NIL                                // VETOR PARA INTEGRACAO AUTOMATICA
Private lVA010Auto := ( xRotAuto <> NIL)                 // VARIAVEL LOGICA PARA INTEGRACAO AUTOMATICA
Private cCadastro  := OemToAnsi(STR0001)                 // "Veiculos"
Private aMemos     := {{"VV1_OBSMEM","VV1_OBSERV"}}      // CAMPOS VIRTUAIS DE OBSERVACAO
Private aCampos    := {}                                 // CAMPOS QUE SERAO VISTOS NO BROWSE
Private aRotina    := MenuDef()
Private cChassi	   := space(TamSX3("VV1_CHASSI")[1])     // CHASSI DEFAULT DO AXINCLUI (VXA010I)
Private aCfgs      := {}
Private cCfgCodMar := ""
Private cCfgModVei := ""
Private cCfgPacote := ""

//�������������������������������Ŀ
//� Define o  array de integracao �
//���������������������������������
If lVA010Auto
	nOpc       := nOpcAuto								// ARMAZENA A OPCAO (INCLUSAO/EXCLUSAO/ALTERACAO)
	aRotAuto  := VV1->(MSArrayXDB(xRotAuto,,nOpc))		// MONTA O VETOR DE INTEGRACAO A PARTIR DO VETOR DE ENTRADA
	lMsErroAuto := .f.
	MsRotAuto(nOpc,Aclone(aRotAuto),"VV1")				// ROTINA DE EXECUCAO AUTOMATICA DO BROWSE PELO AROTINA[]
	if !lMsErroAuto
		If VXA010TOK(nOpc,.f.)
			VA010ISB1(nOpc) // Grava SB1
		EndIf
	endif
else
	If !AMIIn(11) .or. !FMX_AMIIn({"VEIXA010","VEIXFUNA","OFIIA340","VEIXA340"})
		Return()
	EndIf
	//��������������������������������������������������������������������������������������Ŀ
	//� Define os botoes da rotina somente para o modulo de Locadora de Veiculos - SIGALVEA. �
	//����������������������������������������������������������������������������������������
	If cModulo == "LVE"  // Marcos 31/05/07
		aAdd(aRotina, {STR0013 ,"LVEVEIOPC(1)"  , 0, 4} ) //Opcionais
		aAdd(aRotina, {STR0014 ,"LVEVEIOPC(2)"  , 0, 4} ) //Vis.Opcionais
	EndIf

	If ExistBlock("VX010FBR") // Ponto de Entrada para Filtro no Browse
		cFiltroX10 := ExecBlock("VX010FBR")
		FilBrowse('VV1',{}, cFiltroX10) 	// Filtra Browse
	Endif

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"VV1")
endif
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VXA010I  | Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Inclusao do Veiculo                                        |��
�������������������������������������������������������������������������Ĵ��
��|Observacao� Antes de chamar a funcao externamente, e' necessario       |��
��|          � declarar as variaveis private:                             |��
��|          �      PRIVATE aCampos := {}                                 |��
��|          �      PRIVATE cChassi := <chassi default do cadastro>       |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010I(cAlias,nReg,nOpc)
Local aObjects := {} , aPosObj := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cTmpObs      := ""
Local nOpca        := 0  
Local cTitulo      := STR0026 // Cadastro de Ve�culo
Private aCfgs      := IIF( TYPE('acfgs')      != 'U' ,      aCfgs, {} )
Private nValVda    := IIF( TYPE('nValVda')    != 'U' ,    nValVda, 0.0)
Private cCfgCodMar := IIF( TYPE('cCfgCodMar') != 'U' , cCfgCodMar, "" )
Private cCfgModVei := IIF( TYPE('cCfgModVei') != 'U' , cCfgModVei, "" )
Private cCfgPacote := IIF( TYPE('cCfgPacote') != 'U' , cCfgPacote, "" )
Private aTELA[0][0],aGETS[0]
Private lCancCfg   := .F.
Private aButtons   := {}
//
if Type("aCampos")=="U"
	aCampos := {}
	cChassi := space(TamSX3("VV1_CHASSI")[1])
endif
//
begin transaction
//
if TYPE("lVA010Auto")=="U"
	lVA010Auto := .f.
endif
//
If lVA010Auto
	nOpca := AxIncluiAuto(cAlias,,,nOpc,nReg)
Else
	aAdd( aButtons , { "BONUS"    , {|| VXA010OPC(nOpc) }  , STR0013 } ) // Opcionais
	aAdd( aButtons , { "CONTAINR" , {|| VX010CfgVei(nOpc)} , STR0020 } ) // Conf. de Ve�culo
	FM_NEWBOT("VX010BOT","aButtons",{nOpc}) // Ponto de Entrada para Manutencao do aButtons - Definicao de Botoes na EnchoiceBar

	cAliasEnchoice:="VV1"
                                        
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VV1")
	
	aCampos := {}
	Do While !eof() .and. x3_arquivo == "VV1"
		if X3USO(x3_usado).and. (Iif(X3Obrigat(x3_campo),.t.,cNivel>=x3_nivel))
			aadd(aCampos,x3_campo)
		Endif
		&("M->"+x3_campo):= CriaVar(x3_campo)
		dbskip()
	Enddo
	DbSelectArea("VV1")


	aObjects := {}
	AAdd( aObjects, { 0, 0 , .T., .T. } ) 

	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)    

	DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

	EnChoice(cAliasEnchoice,nReg,nOpc,,,,aCampos,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||nOpca:=1,If(!obrigatorio(aGets,aTela),nOpca := 0,If(FS_OK(nOpc),oDlg1:End(),nOpca := 0) )},{||nOpca := 0,oDlg1:End()},,aButtons)

EndIf

If nOpca == 1 // TODO: Validacao do segmento
	if Len(aCfgs) > 0
		if VV1->VV1_CODMAR == cCfgCodMar .AND. VV1->VV1_MODVEI == cCfgModVei
			if !lCancCfg
				VA380GRVCFG( VV1->VV1_CHAINT , aCfgs , nValVda , cCfgPacote )
			EndIf
		Else
			DisarmTransaction()
			MSGInfo(STR0023, STR0008) // Voc� mudou o modelo ou a marca do ve�culo para uma diferente da configura��o do ve�culo, favor selecionar novamente a configura��o do mesmo. / Aten��o
			Return .F.
		Endif
	Endif

	DbSelectArea("VV1")

	// Alterado para MSMM com a op��o 3 (leitura) que se iguala a E_MSMM (que pode estar com algum problema)
	cTmpObs := MSMM(VV1->VV1_OBSMEM, TamSx3("VV1_OBSERV")[1],,, 3,, .t.)

	// Dados informados e Log de Inclus�o
	cTmpObs := Alltrim(cTmpObs) + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
		"*** " + left(Alltrim(UsrRetName(__CUSERID)), 15) + " "         +;
		Transform(dDataBase,"@D") + "-" + Transform(time(),"@R 99:99")  +;
		STR0012 + " ***" + Chr(13) + Chr(10)                            +; // hs
		Repl("_", TamSx3("VV1_OBSERV")[1] - 4) + Chr(13) + Chr(10)

	MSMM(VV1->VV1_OBSMEM, TamSx3("VV1_OBSERV")[1],, cTmpObs, 1,,, "VV1", "VV1_OBSMEM")

	// TODO: Gravacao do VO5
	If ExistBlock("VA010DPGR")
		ExecBlock("VA010DPGR", .f., .f., {VV1->VV1_CHAINT, nOpc, nReg})
	EndIf
Else
	RollBackSx8() // Volta CHAINT
	DisarmTransaction()
EndIf
//
End Transaction
//
Return (nOpca==1)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VXA010V  | Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Visualizacao do Veiculo                                    |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010V(cAlias,nReg,nOpc)
Private aButtons := {}
CpoVXA010()
aAdd( aButtons , { "BONUS" , {|| VXA010OPC(nOpc) } , STR0013 } ) // Opcionais
FM_NEWBOT("VX010BOT","aButtons",{nOpc}) // Ponto de Entrada para Manutencao do aButtons - Definicao de Botoes na EnchoiceBar
AxVisual(cAlias,nReg,nOpc,aCampos,,,,aButtons)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VX010BCO | Autor � Thiago	         | Data �  18/11/11   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Chamada da funcao Banco de conhecimento.                   |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VX010BCO(cAlias,nReg,nOpc)
nOpc := 4
FGX_MSDOC(cAlias,nReg,nOpc)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VX010CfgVei | Autor � Vinicius        | Data �  18/11/11   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Chamada da funcao Configuracao de Veiculo                  |��
��| O funcionamento da configuracao � feita da seguinte maneira, temos 3  |��                                                                       
��| variaveis private 2 guardando marca e modelo da config selecionada    |��                                                                    
��| e 1 para salvar as configura��es no formato de gravacao do veiva380   |��                                                                     
��| as 2 variaveis de marca e modelo servem de guia para evitar gravacao  |��                                                                       
��| erronea dos dados de configuracao, em caso de troca de modelo e marca |��                                                                        
��| especificamente                                                       |��                 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VX010CfgVei(cAlias, nReg, nOpc)
	aCfgs := {}
	cCfgPacote := ""
	If ! Empty(M->VV1_CODMAR) .AND. ! Empty(M->VV1_MODVEI)
		cCfgCodMar := M->VV1_CODMAR
		cCfgModVei := M->VV1_MODVEI
		If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configura��o ? 
			aAux := VEIA242( M->VV1_CODMAR , M->VV1_MODVEI , M->VV1_SEGMOD , M->VV1_CHAINT , .t. )
			If len(aAux) > 0
				cCfgPacote    := aAux[1]
				nValVda       := aAux[3]
				aCfgs         := aAux[4]
				M->VV1_SUGVDA := nValVda
			EndIf
		Else
			VV2->(DbSeek( xFilial('VV2') + M->VV1_CODMAR + M->VV1_MODVEI + M->VV1_SEGMOD ))
			aAux := VA380CONFIG(M->VV1_CHAINT, M->VV1_CODMAR, VV2->VV2_GRUMOD, @aCfgs , M->VV1_MODVEI , M->VV1_SEGMOD )
			if aAux != nil
				aCfgs         := aAux[1]
				If len(aCfgs) == 0
					aAdd(aCfgs,{}) // Somente EXCLUIR os registros da Base
				EndIf
				nValVda       := aAux[2]
				M->VV1_SUGVDA := nValVda
			else
				lCancCfg := .T.
			Endif
		EndIf
	Else
		MSGInfo(STR0024, STR0008) // Por favor antes de configurar o ve�culo, selecione o modelo e a marca do mesmo. / Aten��o
	EndIf
Return aCfgs

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VXA010E  | Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Exclusao do Veiculo                                        |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010E(cAlias,nReg,nOpc)
	Local aFuncs := {,,,}
	Private aButtons := {}
	If VA010VlDel()
		aFuncs[1] := { || .t. } // --> Bloco de c�digo que ser� processado antes da exibi��o das informa��es na tela
		aFuncs[2] := { || .t. } // --> Bloco de c�digo para processamento na valida��o da confirma��o da exclus�o
		aFuncs[3] := { || VXA0100021_Dentro_Transacao_Delecao( VV1->VV1_CHAINT ) } // --> Bloco de c�digo que ser� executado dentro da transa��o da AxFunction()
		aFuncs[4] := { || .t. } // --> Bloco de c�digo que ser� executado fora da transa��o da AxFunction()
		aAdd( aButtons , { "BONUS" , {|| VXA010OPC(nOpc) } , STR0013 } ) // Opcionais
		CpoVXA010()
		RegToMemory("VV1",.f.)
		FM_NEWBOT("VX010BOT","aButtons",{nOpc}) // Ponto de Entrada para Manutencao do aButtons - Definicao de Botoes na EnchoiceBar
		AxDeleta(cAlias,nReg,nOpc,,,aButtons,aFuncs,aRotAuto)
	EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VXA010A  | Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Alteracao do Veiculo                                       |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010A(cAlias,nReg,nOpc)
Local nOpca1        := 0
Local cPlaAnt       := ""
Local lVV1_PLAANT   := VV1->(FieldPos("VV1_PLAANT")) > 0
Local lGrvConf      := .f.
Private aButtons    := {}
Private aCfgs       := IIF( TYPE('acfgs')      != 'U' ,      aCfgs, {} )
Private nValVda     := IIF( TYPE('nValVda')    != 'U' ,    nValVda, 0.0)
Private cCfgCodMar  := IIF( TYPE('cCfgCodMar') != 'U' , cCfgCodMar, "" )
Private cCfgModVei  := IIF( TYPE('cCfgModVei') != 'U' , cCfgModVei, "" )
Private cCfgPacote  := IIF( TYPE('cCfgPacote') != 'U' , cCfgPacote, "" )
Private lCancCfg    := .F.

//
CpoVXA010()
//
Begin Transaction
//
aAdd( aButtons , { "BONUS"    , {|| VXA010OPC(nOpc)  } , STR0013 } ) // Opcionais
aAdd( aButtons , { "CONTAINR" , {|| VX010CfgVei(nOpc)} , STR0020 } ) // Conf. de Ve�culo
FM_NEWBOT("VX010BOT","aButtons",{nOpc}) // Ponto de Entrada para Manutencao do aButtons - Definicao de Botoes na EnchoiceBar
cPlaAnt := VV1->VV1_PLAVEI
nOpca1 := AxAltera(cAlias,nReg,nOpc,aCampos,,,,"VXA010TOK(nOpc,.f.).and.VEIVA600()",,,aButtons,,IIF(TYPE("aRotAuto")=="U",NIL,aRotAuto))
If nOpca1 == 1
	If lVV1_PLAANT .and. cPlaAnt <> VV1->VV1_PLAVEI .and. Empty(VV1->VV1_PLAANT) .and. ( Subs(cPlaAnt,5,1) >= "0" .and. Subs(cPlaAnt,5,1) <= "9" ) .and. ( Subs(VV1->VV1_PLAVEI,5,1) <= "0" .or. Subs(VV1->VV1_PLAVEI,5,1) >= "9" )
		RecLock("VV1",.f.)
		VV1->VV1_PLAANT := cPlaAnt
		MsUnlock()
		VXA0100012_AtualizaPlacaMercosul()
	Endif
	if aCfgs != nil // Mesmo que seja = 0 deve entrar para poder excluir a configura��o atual
		If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configura��o ? 
			If (VV1->VV1_CODMAR == cCfgCodMar .AND. VV1->VV1_MODVEI == cCfgModVei .And. Len(aCfgs) > 0)
				lGrvConf := .t. 
			EndIf
		Else
			if (VV1->VV1_CODMAR == cCfgCodMar .AND. VV1->VV1_MODVEI == cCfgModVei .And. Len(aCfgs) > 0) .Or. (Len(aCfgs) == 0)
				lGrvConf := .t. 
			Endif
		EndIf
		If lGrvConf
			VA380GRVCFG( VV1->VV1_CHAINT , aCfgs , nValVda , cCfgPacote )
		ElseIf Len(aCfgs) > 0
			DisarmTransaction()
			MSGInfo(STR0023, STR0008) // Voc� mudou o modelo ou a marca do ve�culo para uma diferente da configura��o do ve�culo, favor selecionar novamente a configura��o do mesmo. / Aten��o
			Return .F.
		EndIf
	Endif
	VA010ISB1(nOpc) // Grava SB1
	If ExistBlock("VA010DPGR")
		ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,nOpc,nReg})
	EndIf
Else
	DisarmTransaction()
EndIf
//
End Transaction
//
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �CpoVXA010 | Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Levantamento dos Campos utilizados na Tela                 |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CpoVXA010()
DbSelectArea("SX3")
dbseek("VV1")
aCampos := {}
Do While !eof() .and. x3_arquivo == "VV1"
	if X3USO(x3_usado).and. (Iif(X3Obrigat(x3_campo),.t.,cNivel>=x3_nivel))
		aadd(aCampos,x3_campo)
	Endif
	dbskip()
Enddo
DbSelectArea("VV1")
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �VA010VlDel| Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Validacao da Exclusao do Veiculo                           |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VA010VlDel()

Local aArquivos := {}
Local lRet  := .f.
Local nRegs := 0 

aadd(aArquivos,{"VVG",2,VV1->VV1_CHAINT ,})
aadd(aArquivos,{"VVA",3,VV1->VV1_CHAINT ,})
aadd(aArquivos,{"VO1",4,VV1->VV1_CHAINT ,})
aAdd(aArquivos,{"VF3",3,VV1->VV1_CHAINT ,})
aAdd(aArquivos,{"VF4",1,VV1->VV1_CHAINT ,})
aAdd(aArquivos,{"VS1",2,VV1->VV1_CHAINT ,})
aAdd(aArquivos,{"VFB",8,VV1->VV1_CHAINT ,})

lRet:= FG_DELETA(aArquivos)

If lRet 	
	nRegs:= FM_SQL(" SELECT COALESCE(count(*),0) as COUNT FROM "+RetSQLName('VQ0')+" WHERE VQ0_CHAINT = '"+VV1->VV1_CHAINT+"' AND D_E_L_E_T_ = ' ' ")
	If nRegs > 0 
		MsgStop(STR0032,STR0008)//("O Chassi selecionado ja possui um pedido. Impossivel continuar. / Atencao")	 	
		lRet:= .f.	
	Else
		lRet:= .t.
	endIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VXA010TOK| Autor � Andre Luis Almeida | Data �  09/01/15   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Tudo OK da Inclusao/Alteracao                              |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010TOK(nOpcTOK,lVldDupl)
Local lRet       := .t.
Default lVldDupl := .f.

If !Empty(M->VV1_CHASSI) // Tratamento necess�rio para chamada visa MSExecAuto
	M->VV1_CHASSI := padr(ltrim(M->VV1_CHASSI),TamSX3("VV1_CHASSI")[1])
EndIf

If lVldDupl // Valida Duplicidade ?
	// CHASSI
	If !Empty(M->VV1_CHASSI)
		lRet := ExistChav("VV1",M->VV1_CHASSI,2,"EXICHASSI")
	EndIf
EndIf
If lRet .and. ExistBlock("VXA010OK") // Ponto de Entrada no Tudo OK da rotina
	lRet := ExecBlock("VXA010OK",.f.,.f.,{nOpcTOK})
EndIf
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �VA010ISB1 | Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Inclusao/Alteracao do SB1 refente ao Veiculo               |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VA010ISB1(nOpcA)
Local cCodSB1   := Left(GetMv("MV_GRUVEI")+Space(10),TamSX3("B1_GRUPO")[1])+"_"+VV1->VV1_CHAINT
Local aVetSB1   := {}
Local lRet      := .t.
Local oVeiculos := DMS_Veiculo():New()
ConfirmSX8()
If GetNewPar("MV_MIL0003","1")  == "1"// Cria registro no SB1 quando for cadastrado um ve�culo na rotina Ve�culos Mod. 2 (VEIXA010)? (0=N�o / 1=Sim) - CARACTERE
	nOpcA := 3
	DBSelectArea("SB1")
	DBSetOrder(1)
	if dbSeek(xFilial("SB1")+cCodSB1)
		nOpcA := 4
	endif
	If nOpcA <> 3 // Altera��o
		aAdd(aVetSB1,{"B1_DESC"    ,VV1->VV1_CHASSI })
		aAdd(aVetSB1,{"B1_LOCPAD"  ,VV1->VV1_LOCPAD })
		aAdd(aVetSB1,{"B1_PRV1"    ,VV1->VV1_SUGVDA })
		aAdd(aVetSB1,{"B1_ORIGEM"  ,VV1->VV1_PROVEI })
		aAdd(aVetSB1,{"B1_POSIPI"  ,VV1->VV1_POSIPI })
		aAdd(aVetSB1,{"B1_GRTRIB"  ,VV1->VV1_GRTRIB })
		If SB1->(FieldPos("B1_CHASSI")) > 0
			aAdd(aVetSB1,{"B1_CHASSI"  ,VV1->VV1_CHASSI })
		Endif
		If VV1->(FieldPos("VV1_CONTA")) > 0
			aAdd(aVetSB1,{"B1_CONTA"   ,VV1->VV1_CONTA  }) 
			aAdd(aVetSB1,{"B1_CC"      ,VV1->VV1_CC     }) 
			aAdd(aVetSB1,{"B1_ITEMCC"  ,VV1->VV1_ITEMCC })
			aAdd(aVetSB1,{"B1_CLVL"    ,VV1->VV1_CLVL   })
		EndIf
		If VV1->(FieldPos("VV1_CEST")) > 0 .and. SB1->(FieldPos("B1_CEST")) > 0
			aAdd(aVetSB1,{"B1_CEST"    ,VV1->VV1_CEST   })
		EndIf

		// Bloqueio/Desbloqueio de Chassi
		If VV1->(FieldPos("VV1_MSBLQL")) > 0 .and. SB1->(FieldPos("B1_MSBLQL")) > 0
			aAdd(aVetSB1,{"B1_MSBLQL"  ,VV1->VV1_MSBLQL })
		EndIf

		// Grupo TI
		If VV1->(FieldPos("VV1_GRPTI")) > 0 .and. SB1->(FieldPos("B1_GRPTI")) > 0
			aAdd(aVetSB1,{"B1_GRPTI"  ,VV1->VV1_GRPTI })
		EndIf
	EndIf
	lRet := oVeiculos:CriaPeca(VV1->VV1_CHAINT,nOpcA,aVetSB1,"VA010AB1") // Inclui/Altera SB1 do Veiculo
	If !lRet
		MostraErro()
		Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo no SB1
		lMsErroAuto := .f.
	Endif
Endif

return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �VA010Chassi| Autor � Luis Delorme      | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Carrega automaticamente o CHASSI do Veiculo                |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VA010Chassi()
M->VV1_CHASSI := padr(ltrim(cChassi),TamSX3("VV1_CHASSI")[1])                                                 
return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �VA010CHKPD| Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Validacoes no Pedido de Compra                             |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VA010CHKPD()
if  Empty(M->VV1_ITPED)
	return .t.
endif
DBSelectArea("SC7")
if !DBSeek(xFilial("SC7")+M->VV1_NUMPED+M->VV1_ITPED)
	return .f.
endif
if Empty(M->VV1_CHASSI)
	MsgStop(STR0007,STR0010) // Preencha o campo CHASSI antes de escolher o item do pedido de compra. / Atencao
	return .f.
endif

FGX_VV2(M->VV1_CODMAR, M->VV1_MODVEI, M->VV1_SEGMOD)
if VV2->VV2_PRODUT != SC7->C7_PRODUTO
	MsgStop(STR0025,STR0010) // O modelo do ve�culo n�o corresponde ao modelo do pedido de compra para o item escolhido. / Atencao
	return .f.
endif
return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � VEI010R  � Autor � Andre Luis Almeida � Data �  22/11/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Chamada da Montagem de Tela - Replicar                     ���
�������������������������������������������������������������������������͹��
���Uso       � Sigavei                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010R(cAlias,nReg,nOpc)
DbSelectArea("VV1")
If RecCount() > 0
	If nOpc > 3
		nOpc := 3
	EndIf
	VEIX10ROK(cAlias,nReg,nOpc)
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VEIX10ROK �Autor  � Andre Luis Almeida � Data �  22/11/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Monta Tela - Replicar                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Sigavei                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEIX10ROK(cAlias,nReg,nOpc)
Local bCampo   := { |nCPO| Field(nCPO) }
Local i , j
Local lInclui
Local nCntFor,_ni := 0
Local cCpoVV1 := "VV1_CHASSI/VV1_PLAVEI/VV1_RENAVA/"
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  :={} , nControlAba := 1
Private aCols := {} , aHeader := {}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nLinhas := 0, nOpcc := nOpc
cCpoVV1 += GetNewPar("MV_NREPVV1","")
Inclui := .f.
Altera := .f.
//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("VV1",.t.)
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV1")
While !Eof().And.(x3_arquivo=="VV1")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. !(Alltrim(x3_campo) $ ("VV1_CHAINT/"+cCpoVV1))
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	dbSkip()         
End                                               

nOpcE := 4
nOpcG := 4
//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VV1")
While !Eof().And.(x3_arquivo=="VV1")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. Alltrim(x3_campo) $ (cCpoVV1)
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,".t.",;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	dbSkip()
End
If !Inclui
	DbSelectArea("VV1")     
	cCampos := "VV1_CHAINT/VV1_FILENT/VV1_TRACPA/VV1_ULTMOV/VV1_FILSAI/VV1_NUMTRA/VV1_SITVEI/VV1_3EIXO /VV1_ARQIMG/VV1_BITMAP/VV1_BONFAB/VV1_BXAEST/VV1_CAMBIO/VV1_CEPANT/"
	cCampos += "VV1_CHARED/VV1_CIDANT/VV1_CODCON/VV1_CODFRO/VV1_CODGAR/VV1_DATETG/VV1_DATPED/VV1_DATPRO/VV1_DATREP/VV1_DATVEN/VV1_DTUVEN/VV1_DESADM/VV1_DESLOC/VV1_DESPLA/"
	cCampos += "VV1_DOCIND/VV1_DONOVU/VV1_DTECAP/VV1_DTEVDA/VV1_DTHEMI/VV1_DTHRES/VV1_DTHVAL/VV1_DTSUBS/VV1_ENDANT/VV1_ESTANT/VV1_ESTPLA/VV1_FILENT/VV1_FILSAI/VV1_HORRES/"
	cCampos += "VV1_HORVEN/VV1_ITPED /VV1_JUREST/VV1_KILVEI/VV1_KMS   /VV1_LJPANT/VV1_LJPATU/VV1_LOCALI/VV1_MEDMKM/VV1_MINGER/VV1_MINVEN/VV1_MNCOMV/VV1_MNVLVD/VV1_MUNPLA/"
	cCampos += "VV1_NOMANT/VV1_NUMDIF/VV1_NUMLOT/VV1_NUMMOT/VV1_NUMPED/VV1_NUMTRA/VV1_OBSMEM/VV1_OBSPEN/VV1_OPCFAB/VV1_PEDFAB/VV1_PESDOC/VV1_PLAREV/VV1_PLAVEI/VV1_PRCACO/"
	cCampos += "VV1_PRIREV/VV1_PROANT/VV1_PROATU/VV1_RENAVA/VV1_RESERV/VV1_SERMOT/VV1_SIGWEB/VV1_SITDOC/VV1_STATUS/VV1_SUGVDA/VV1_TRACPA/VV1_ULTMOV/VV1_VEIACO/VV1_VENFAB/"
	cCampos += "VV1_VENIPV/VV1_VENSEG/"
	For nCntFor := 1 TO FCount()
		if !(EVAL(bCampo,nCntFor) $ cCampos)
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Endif
	Next
EndIf
aChassi := {}
dbSelectArea("VV1")
If Len(aCols) == 0
	aCols:={Array(Len(aHeader)+1)}
	aCols[1,Len(aHeader)+1]:=.F.
	For _ni:=1 to Len(aHeader)
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
EndIf
If Len( aCols ) > 0
	//��������������������������������������������������������������Ŀ
	//� Executa a Modelo 3                                           �
	//����������������������������������������������������������������
	cTitulo       :=STR0001 // Veiculos
	cAliasEnchoice:="VV1"
	cAliasGetD    :="VV1"
	cLinOk        :="AllwaysTrue()"
	cTudOk        :="AllwaysTrue()"
	cFieldOk      :="AllwaysTrue()"
	nLinhas       := 1000
	aSizeAut	:= MsAdvSize(.t.)
	lModOk := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,,,,{aSizeAut[7],0,aSizeAut[6],aSizeAut[5]},2*aSizeAut[6]/3)
EndIf
if lModOk
	for i := 1 to Len(aCols)
	    if !aCols[i,Len(aCols[i])]
			xRotAuto := {}
			aAdd(xRotAuto,{"VV1_FILIAL"  ,xFilial("VV1")    	,Nil})
			aAdd(xRotAuto,{"VV1_CHAINT"  ,GetSXENum("VV1","VV1_CHAINT")    	,Nil})
			ConfirmSX8()
			dbSelectArea("SX3")
			DbSetOrder(1)
			dbSeek("VV1")
			While !Eof().And.(x3_arquivo=="VV1")
				if !(Alltrim(x3_campo)+"/" $ cCpoVV1+"VV1_CHAINT/")
					aAdd(xRotAuto,{x3_campo, &("M->"+x3_campo), NIL })
				endif
				DBSkip()
			enddo
			//
			for j := 1 to Len(aHeader)
				aAdd(xRotAuto,{aHeader[j][2], aCols[i][j], NIL })
			next
			//
			begin transaction
			lMsErroAuto := .f.
			MSExecAuto({|x,y| VEIXA010(x,y)},xRotAuto,3)
			if lMsErroAuto
				DisarmTransaction()
				MostraErro()
				i := Len(aCols)+1 // Sair fora do laco FOR
			Endif
			end transaction
		endif
	next
Endif
Return

/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Funcao�VXA010LVEI�Autor� Manoel / Andre Luis Almeida	�Data� 08/05/12 ���
�����������������������������������������������������������������������Ĵ��
���Descr.� Chamada da FG_POSVEI                                         ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/
Function VXA010LVEI()
Local nOpca := 0
Private cLevChas := space(TamSX3("VV1_CHASSI")[1])
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0017) FROM 01,05 TO 8,50 OF oMainWnd  //Pesquisa Chassi
	@ 035,004 SAY STR0018 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE  //Veiculo:
	@ 035,025 MSGET oLevChas VAR cLevChas F3 "VV1" PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
ACTIVATE MSDIALOG oLevPesq CENTER ON INIT EnchoiceBar(oLevPesq,{|| nOpca := 1,oLevPesq:End()},{|| oLevPesq:End()})
DbSelectArea("VV1")
If nOpca > 0
	FG_POSVEI("cLevChas",)
endif       
Return()

/*       
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �VXA010NCM  � Autor �Rafael goncalves       � Data � 05/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � valida se cliente usa tabela vcm para tratar valid         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010NCM(nPotMot) 
Local lRet := .f.
Local _sAlias := Alias()

DbSelectArea("VCM")
DbSetOrder(1)

If FieldPos("VCM_POSIPI") # 0 //UTILIZA TABELA VCM
	DbSelectArea("VV2")
	DbSetOrder(4)
	DbSeek(xFilial("VV2")+M->VV1_MODVEI)
	                                                          
	DbSelectArea("VCM")
	DbSetOrder(1)
	If DbSeek(xFilial("VCM")+VV2->VV2_TIPVEI+str(M->VV1_POTMOT,6,1))
		lRet := .t.
		M->VV1_POSIPI := VCM->VCM_POSIPI	        
	EndIF 
	//tipo de servico em branco
	If !lRet 
		DbSelectArea("VCM")
		DbSetOrder(1)
		If DbSeek(xFilial("VCM")+"  "+str(M->VV1_POTMOT,6,1))
			lRet := .t.
			M->VV1_POSIPI := VCM->VCM_POSIPI        
		EndIF 
	EndIF 
	
Else//nao utiliza tabela VCM
	M->VV1_POSIPI := ""    
EndIf
if !Empty(_sAlias)          
	dbSelectArea(_sAlias)
Else 
	dbSelectArea("VV1")
Endif	
Return(lRet)

/*       
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VXA010GVO5� Autor �  Emilton              � Data � 28/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava automaticamente o VO5                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010GVO5(cChaInt,nOpc_)

//��������������������������������������������������������������Ŀ
//� GRAVA O VO5 A PARTIR DO VV1 AUTOMATICAMENTE   O              �
//����������������������������������������������������������������

aVetValid := {}
If FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)

	Do Case
	Case nOpc_ == 4  // Alteracao

		RecLock("VO5",.f.)
			VO5->VO5_FILIAL := xFilial("VO5")
			VO5->VO5_CHAINT := VV1->VV1_CHAINT
			VO5->VO5_TIPOPE := VV1->VV1_TIPOPE
			VO5->VO5_GRASEV := VV1->VV1_GRASEV
			VO5->VO5_DATVEN := VV1->VV1_DATVEN
			VO5->VO5_PRIREV := VV1->VV1_PRIREV
			VO5->VO5_VEIACO := VV1->VV1_VEIACO
		MsUnlock()

	Case nOpc_ == 5  // Exclusao

		nReg := VO5->(RecNo())
		AxDeleta("VO5",nReg,nOpc_)

	EndCase

Else

	If nOpc_ == 3  // Inclusao
		RecLock("VO5",.t.)
			VO5->VO5_FILIAL := xFilial("VO5")
			VO5->VO5_CHAINT := VV1->VV1_CHAINT
			VO5->VO5_TIPOPE := VV1->VV1_TIPOPE
			VO5->VO5_GRASEV := VV1->VV1_GRASEV
			VO5->VO5_DATVEN := VV1->VV1_DATVEN
			VO5->VO5_PRIREV := VV1->VV1_PRIREV
			VO5->VO5_VEIACO := VV1->VV1_VEIACO
		MsUnlock()
	EndIf

EndIf

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � MenuDef  | Autor � Luis Delorme       | Data �  10/12/08   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � MenuDef - monta opcoes no aRotina                          |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {	{ STR0002 ,"AxPesqui", 0 , 1,,.f.},;	// Pesquisar
{ STR0003 ,"VXA010V" , 0 , 2},;  		// Visualizar
{ STR0004 ,"VXA010I" , 0 , 3},;  		// Incluir
{ STR0005 ,"VXA010A" , 0 , 4},;  		// Alterar
{ STR0006 ,"VXA010E" , 0 , 5},;  		// Excluir
{ STR0011 ,"VXA010LVEI", 0, 1 },;		// Pesquisar Chassi
{ STR0009 ,"VXA010R" , 0 , 5},; 		// Replicar
{ STR0004+" "+GetNewPar("MV_MIL0106","AMS") ,"VXA010IAMS" , 0 , 3},;  	// Incluir
{ STR0016 ,"VX010BCO" , 0 , 7}} // Bco Conhecimento

If (ExistBlock("VX010MD")) // Ponto de Entrada para adicionar opes no Menu
	aRotina := ExecBlock("VX010MD", .f., .f., {aRotina})
EndIf
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � VXA010OPC| Autor � Andre Luis Almeida | Data �  08/05/13   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Preenche o M->VV1_OPCFAB com os opcionais selecionados     |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010OPC(nOpc)
Local aObjects := {} , aPosObj := {} , aInfo := {} //aPosObjApon := {} , "
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)		
Local cOpcFab  := M->VV1_OPCFAB
Local nTam     := at("/",cOpcFab)
Local aAcesso  := {}
Local lOk      := .f.
Local lAltOpc  := ( nOpc==3 .or. nOpc==4 ) // Deixa alterar
Local lSelec   := .f.
Private oOkTik := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik := LoadBitmap( GetResources() , "LBNO" )
If nTam > 1
	nTam--
EndIf
If nTam <= 0
	nTam := VVW->(TamSx3("VVW_CODOPC")[1])
EndIf
//levanta as informacoes 
DbSelectArea("VVM")
DbSetOrder(1)
If dbSeek(xFilial("VVM")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD)
	While !EOF() .and. xFilial("VVM")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD == VVM->VVM_FILIAL+VVM->VVM_CODMAR+VVM->VVM_MODVEI+VVM_SEGMOD
		dbSelectArea("VVW")
		dbSetOrder(1)
		If dbSeek(xFilial("VVW")+VVM->VVM_CODMAR+VVM->VVM_CODOPC)
			aAdd( aAcesso , { .f. , alltrim(VVW->VVW_CODOPC) , VVW->VVW_DESOPC } ) 
        	If left(VVW->VVW_CODOPC,nTam) $ cOpcFab
				aAcesso[ len(aAcesso) , 1 ] := .t.
			EndIf
		EndIf
		dbSelectArea("VVM")
		dbSkip()
	EndDo
EndIf
If len(aAcesso) <= 0
	aAdd( aAcesso , { .f. , "" , "" } )
	lAltOpc := .f.
EndIf
// Configura os tamanhos dos objetos													  		
aObjects := {}
AAdd( aObjects, { 1 , 1 , .T. , .T. } ) // Listbox 
// Fator de reducao de 0.7
For nTam := 1 to Len(aSizeAut)
	aSizeAut[nTam] := INT(aSizeAut[nTam] * 0.7)
next   
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize(aInfo,aObjects,.F.)    

DEFINE MSDIALOG oOpcionais TITLE STR0013 From aSizeAut[7],000 TO aSizeAut[6]-5,aSizeAut[5] of oMainWnd STYLE DS_MODALFRAME STATUS PIXEL // Opcionais

@ aPosObj[1,1]+002,aPosObj[1,2]+002 LISTBOX oLbAce FIELDS HEADER "",STR0013,STR0019 COLSIZES 10,40,200 SIZE aPosObj[1,4]-2,aPosObj[1,3]-aPosObj[1,1]-10 OF oOpcionais PIXEL ON DBLCLICK IIf(lAltOpc,aAcesso[oLbAce:nAt,01]:=!aAcesso[oLbAce:nAt,01],.t.) // Opcionais / Descricao
oLbAce:SetArray(aAcesso)
oLbAce:Align := CONTROL_ALIGN_ALLCLIENT
oLbAce:bLine := { || { IIf(aAcesso[oLbAce:nAt,01],oOkTik,oNoTik) , aAcesso[oLbAce:nAt,02] , aAcesso[oLbAce:nAt,03] }}
oLbAce:bHeaderClick := {|oObj,nCol| IIf( nCol==1 .and. lAltOpc , ( lSelec := !lSelec , aEval( aAcesso , { |x| x[1] := lSelec } ) , oLbAce:Refresh() ) ,Nil) , }

ACTIVATE MSDIALOG oOpcionais CENTER ON INIT  EnchoiceBar(oOpcionais,{ || lOk := .t., oOpcionais:End()},{|| oOpcionais:End() } ) 
If lOk .and. lAltOpc
	M->VV1_OPCFAB := ""
	For nTam := 1 to len(aAcesso)
		If aAcesso[nTam,1]
			M->VV1_OPCFAB += aAcesso[nTam,2]+"/"
		EndIf
	Next
	M->VV1_OPCFAB := left( M->VV1_OPCFAB + space(200) , VV1->(TamSx3("VV1_OPCFAB")[1]) )
EndIf
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � FS_OK    | Autor � Thiago			 | Data �  02/08/16   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Tudo OK.												     |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_OK(nOpc)
//
M->VV1_CHASSI := padr(ltrim(M->VV1_CHASSI), TamSX3("VV1_CHASSI")[1])
//
If !FS_CriaSemaforo(M->VV1_CHASSI)
	Return .f.
EndIf

if !(VXA010TOK(nOpc, .t.) .And. VEIVA600())
	Return(.f.)
Endif

Begin Transaction

&& Grava Arquivo Pai
DbSelectArea("VV1")

If nOpc == 3
	RecLock("VV1", .t.)
	FG_GRAVAR("VV1")
	MsUnlock()

	// FG_GRAVAR n�o est� considerando o campo VV1_OBSERV (MEMO Antigo)
	MSMM(VV1->VV1_OBSMEM, TamSx3("VV1_OBSERV")[1],, M->VV1_OBSERV, 1,,, "VV1", "VV1_OBSMEM")
EndIf

VA010ISB1(nOpc) // Grava SB1
End Transaction

FS_LiberaSemaforo(M->VV1_CHASSI)
Return(.t.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � FS_CriaSemaforo | Autor � Thiago		  | Data �  02/08/16   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Semafaro.															     |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_CriaSemaforo(cNome)

	Local nCntTent := 1
	Local lOk

	cNome := "VEIXA010" + AllTrim(cNome)

	While !( lOk := LockByName( cNome , .f. /* lEmpresa */ , .f. /* lFilial */ , .t. ))
		MsAguarde( {|| Sleep(10000) } , STR0027 + ALLTRIM(STR(nCntTent)), STR0028) // Semaforo de processamento... tentativa / Aguarde.
		nCntTent++

		If nCntTent > 10
			lOk := .f.
			Exit
		EndIf
	EndDo

Return lOk

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  � FS_LiberaSemaforo | Autor � Thiago	  | Data �  02/08/16  |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Libera Semaforo.										     |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_LiberaSemaforo( cNome )
	cNome := "VEIXA010" + AllTrim(cNome)
	UnLockByName( cNome, .f. /* lEmpresa */ , .f. /* lFilial */ , .t. )
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �VXA010IAMS| Autor � Andre Luis Almeida | Data �  21/09/17   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Inclusao do AMS                                            |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010IAMS()
Local lOkTela    := .f.
Local ni         := 0
Local cGTr       := ""
Local cNCM       := ""
Local aCpos      := {}
Local aVetVV1    := {}
Local aRetVV1    := {}
Local aVetSB1    := {}
Local cChaIntAMS := ""
Local cSiglaAMS  := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS
Local oVeiculos  := DMS_Veiculo():New()
Local oIHelp     := DMS_InterfaceHelper():New()
Local aObjects   := {}
//
aCpos := {	{	"VV1_CODMAR" , .t. } ,;
			{	"VV1_MODVEI" , .t. } ,;
			{	"VV1_CORVEI" , .t. } ,;
			{	"XXX_QTD"    , .t. } ,;
			{	"VV1_FABMOD" , .t. } ,;
			{	"VV1_CHASSI" , .f. } ,;
			{	"VV1_LOCPAD" , .t. } ,;
			{	"VV1_SUGVDA" , .t. } ,;
			{	"VV1_CODORI" , .f. } ,;
			{	"VV1_PROVEI" , .f. } ,;
			{	"VV1_GRTRIB" , .f. } ,;
			{	"VV1_POSIPI" , .f. } }
//
AAdd( aObjects, { "TELA" , 100 , 100 , .T. , .T. } ) // 100%
//
oSizePri := oIHelp:CreateDefSize(.t., aObjects )
oSizePri:Process()
//
oIHelp:SetDefSize(oSizePri)
oVXA010AMS := oIHelp:CreateDialog(cSiglaAMS+" - "+STR0004) // XXX - Incluir
oIHelp:SetDialog(oVXA010AMS) // ACTIVATE
oIHelp:SetOwnerPvt("VXA010IAMS")
oIHelp:nOpc := 3
oVXA010AMS:lEscClose := .F.
//
oIHelp:Clean()
oIHelp:SetDefSize(oSizePri, "TELA")
oPainel := oIHelp:CreateMGroup({{"TEXTO",""}})
oIHelp:setDialog(oPainel)
//
SX3->(DbSetOrder(2))
For ni := 1 to len (aCpos)
	If left(aCpos[ni,1],3) <> "XXX"
		SX3->(DbSeek(aCpos[ni,1]))
		oIHelp:AddMGetTipo({;
			{'X3_TIPO'    , SX3->X3_TIPO    },;
			{'X3_TAMANHO' , SX3->X3_TAMANHO },;
			{'X3_CAMPO'   , SX3->X3_CAMPO   },;
			{'X3_TITULO'  , SX3->X3_TITULO  },;
			{'X3_VALID'   , IIf(!Empty(SX3->X3_VALID),"vazio().or.("+Alltrim(SX3->X3_VALID)+".and.VXA010VAMS())","VXA010VAMS()") },;
			{'X3_PICTURE' , SX3->X3_PICTURE },;
			{'X3_RELACAO' , SX3->X3_RELACAO },;
			{'X3_CBOX'    , SX3->X3_CBOX    },;
			{'X3_F3'      , SX3->X3_F3      },;
			{'X3_OBRIGAT' , aCpos[ni,2]     } ;
			})
	Else
		If aCpos[ni,1] == "XXX_QTD"
			oIHelp:AddMGetTipo({;
				{'X3_TIPO'    , "N"             },;
				{'X3_TAMANHO' , 3               },;
				{'X3_CAMPO'   , 'XXX_QTD'       },;
				{'X3_TITULO'  , STR0029         },; // Quantidade
				{'X3_PICTURE' , "@E 999"        },;
				{'X3_VALID'   , "M->XXX_QTD>0.and.VXA010VAMS()"    },;
				{'X3_RELACAO' , 1               },;
				{'X3_OBRIGAT' , aCpos[ni,2]     } ;
				})
		EndIf
	EndIf
Next
oEnchParam := oIHelp:CreateMSMGet(.f., { { "ALINHAMENTO" , CONTROL_ALIGN_ALLCLIENT } } ) 
//
M->VV1_LOCPAD := padr(GetNewPar("MV_MIL0107","AM"),TamSX3("VV1_LOCPAD")[1]) // Inicializa Local Padrao (default) para criacao do VV1
//
ACTIVATE MSDIALOG oVXA010AMS ON INIT EnchoiceBar(oVXA010AMS,{|| IIf(VXA010VAMS(.t.,aCpos),(lOkTela:=.t.,oVXA010AMS:End()),.t.) },{|| oVXA010AMS:End() } )
//
If lOkTela
	//
	Begin Transaction
	//
	For ni := 1 to M->XXX_QTD // Qtde Digitada
		cGTr := ""
		cNCM := ""
		VV2->(DbSetOrder(1))
		If VV2->(DbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+VV2->VV2_PRODUT))
				cGTr := SB1->B1_GRTRIB
				cNCM := SB1->B1_POSIPI
			EndIf
		EndIf
		DbSelectArea("VV1")
		//
		cChaIntAMS := ""
		aVetVV1 := {}
		If !Empty(M->VV1_CHASSI)
			aAdd(aVetVV1,{"VV1_CHASSI",M->VV1_CHASSI})
		Else
			cChaIntAMS := GetSXENum("VV1","VV1_CHAINT")
			ConfirmSx8()
			aAdd(aVetVV1,{"VV1_FILIAL",xFilial("VV1")})
			aAdd(aVetVV1,{"VV1_CHAINT",cChaIntAMS})
			aAdd(aVetVV1,{"VV1_CHASSI",cSiglaAMS+"_"+cChaIntAMS})
		EndIf
		aAdd(aVetVV1,{"VV1_CODMAR",M->VV1_CODMAR})
		aAdd(aVetVV1,{"VV1_MODVEI",M->VV1_MODVEI})
		aAdd(aVetVV1,{"VV1_CORVEI",M->VV1_CORVEI})
		aAdd(aVetVV1,{"VV1_SITVEI","0"})
		aAdd(aVetVV1,{"VV1_ESTVEI","0"})
		aAdd(aVetVV1,{"VV1_LOCPAD",M->VV1_LOCPAD})
		aAdd(aVetVV1,{"VV1_SUGVDA",M->VV1_SUGVDA})
		aAdd(aVetVV1,{"VV1_GRASEV","6"}) // SEM CHASSI ( AMS )
		aAdd(aVetVV1,{"VV1_DTHEMI",dToc(Date())+" "+Time()})
		aAdd(aVetVV1,{"VV1_FABMOD",M->VV1_FABMOD})
		aAdd(aVetVV1,{"VV1_COMVEI","9"})
		aAdd(aVetVV1,{"VV1_CODORI",IIf(!Empty(M->VV1_CODORI),M->VV1_CODORI,"2")})
		aAdd(aVetVV1,{"VV1_PROVEI",IIf(!Empty(M->VV1_PROVEI),M->VV1_PROVEI,"1")})
		aAdd(aVetVV1,{"VV1_INDCAL","0"})
		aAdd(aVetVV1,{"VV1_VEIACO","0"})
		aAdd(aVetVV1,{"VV1_TIPVEI","1"})
		aAdd(aVetVV1,{"VV1_PROMOC","0"})
		aAdd(aVetVV1,{"VV1_BLQPRO","0"})
		aAdd(aVetVV1,{"VV1_FOTOS" ,"0"})
		aAdd(aVetVV1,{"VV1_GRTRIB",IIf(!Empty(M->VV1_GRTRIB),M->VV1_GRTRIB,cGTr)})
		aAdd(aVetVV1,{"VV1_POSIPI",IIf(!Empty(M->VV1_POSIPI),M->VV1_POSIPI,cNCM)})

		//
		lOkTela := oVeiculos:CriaVeiculo(cChaIntAMS,3,aVetVV1,"") // Inclui Veiculo VV1
		If !lOkTela
			DisarmTransaction()
			MostraErro()
			Return
		EndIf
		//
		lOkTela := oVeiculos:CriaPeca(VV1->VV1_CHAINT,3,aVetSB1,"VA010AB1") // Inclui SB1 do Veiculo
		If !lOkTela
			DisarmTransaction()
			MostraErro()
			Return
		EndIf
		//
		aadd(aRetVV1,{VV1->VV1_CHAINT, VV1->VV1_CHASSI, VV1->VV1_CODMAR, VV1->VV1_MODVEI})
		//
	Next
	//
	End Transaction
	//
EndIf
Return aRetVV1

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �VXA010VAMS| Autor � Andre Luis Almeida | Data �  22/09/17   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � TudoOK Tela e Validacao dos campos na Inclusao do AMS      |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010VAMS(lTOK,aCpos)
Local ni      := 0
Local lRet    := .t.
Default lTOK  := .f.
Default aCpos := {}
If lTOK // TUDOOK Tela de Inclusao de AMS
	For ni := 1 to len(aCpos)
		If aCpos[ni,2] .and. Empty(&("M->"+aCpos[ni,1]))
			Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCpos[ni,1])) + " (" + aCpos[ni,1] + ")" ,4,1)
			lRet := .f.
			Exit
		EndIf
	Next
Else // VALID dos campos
	Do Case
		Case ReadVar() == "M->VV1_CHASSI"
			If !Empty(M->VV1_CHASSI)
				M->XXX_QTD := 1 // Quando chassi preenchido, a quantidade � somente 1
			EndIf
		Case ReadVar() == "M->XXX_QTD" 
			If M->XXX_QTD > 1
				M->VV1_CHASSI := space(TamSX3("VV1_CHASSI")[1]) // Quando quantidade maior que 1, limpar chassi
			EndIf
	EndCase
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��|Programa  �VXA010SEGMD| Autor � Andre Luis Almeida | Data � 28/11/17   |��
�������������������������������������������������������������������������Ĵ��
��|Descricao � Validacao no Segmento do Modelo do Veiculo                 |��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VXA010SEGMD()
Local lRet := .t.
If !Empty(M->VV1_SEGMOD)
	VVX->(DbSetOrder(1))
	If !VVX->(DbSeek(xFilial("VVX")+M->VV1_CODMAR+M->VV1_SEGMOD))
		lRet := .f.
		MsgStop(STR0030,STR0010) // Segmento do Modelo n�o cadastrado! / Atencao
	Else
		VV2->(DbSetOrder(1))
		If !VV2->(DbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD))
			lRet := .f.
			MsgStop(STR0031,STR0010) // Segmento do Modelo n�o relacionado ao Modelo informado! / Atencao
		EndIf
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} VXA0100012_AtualizaPlacaMercosul()

Atualiza os campos de PLaca de todas as outras tabelas com a nova placa do MercoSul

@author Manoel Filho
@since  15/03/2019
@param  

/*/
Function VXA0100012_AtualizaPlacaMercosul(cAuxPlaca, cAuxPlaAnt)
Local cQuery    := ""
Local cTabPla   := "VA8/VAZ/VC3/VC4/VIK/VIL/VJ3/VJ4/VJ5/VO1/VO5/VSO/VSR/VV0/VB7/"
Local nTotTab   := Len(cTabPla)/4
Local cAliasPla := ""
Local nCont     := 0
//
Default cAuxPlaca  := VV1->VV1_PLAVEI
Default cAuxPlaAnt := VV1->VV1_PLAANT
//
For nCont := 1 to nTotTab
	//
	cAliasPla := subs(cTabPla,(nCont*4)-3,3)
	//
	cQuery := " UPDATE " + RetSQLName(cAliasPla) + " SET "+cAliasPla+"_PLAVEI  = '"+cAuxPlaca+"' "
	cQuery += " WHERE "+cAliasPla+"_PLAVEI  = '"+cAuxPlaAnt+"' AND "+cAliasPla+"_PLAVEI <> ' '" 
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	//
	if TcSqlExec(cQuery) < 0
		conout("Problema na atualiza��o da tabela "+cAliasPla+": " + TCSQLError())
	endif
	//
Next
//
return

/*/{Protheus.doc} VXA0100021_Dentro_Transacao_Delecao()
Executa dentro da Transacao da Delecao do Veiculo (VV1)

@author Andr� Luis Almeida
@since  29/06/2022
/*/
Static Function VXA0100021_Dentro_Transacao_Delecao( cChaInt )
Local lRet      := .t.
Local oVeiculos := DMS_Veiculo():New()
Local oPeca     := DMS_Peca():New()
Local cCodSB1   := ""
VXA010GVO5(cChaInt,5)
If GetNewPar("MV_MIL0003","1")  == "1"// Cria registro no SB1 quando for cadastrado um ve�culo na rotina Ve�culos Mod. 2 (VEIXA010)? (0=N�o / 1=Sim) - CARACTERE
	If GetNewPar("MV_MIL0010","0") == "0" // O M�dulo de Ve�culos trabalhar� com Ve�culos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
		cCodSB1 := oVeiculos:GetB1_COD(cChaInt) // Pega B1_COD do Veiculo
		lRet := oPeca:ExcluiPeca(cCodSB1) // Excluir SB1 correspondente ao VV1
	EndIf
EndIf
Return lRet