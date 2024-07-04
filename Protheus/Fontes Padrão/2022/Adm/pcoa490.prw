#INCLUDE "PCOA490.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA490  � AUTOR � Jo�o Gon�alves Oliveira � DATA � 12.01.08 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Cadastro de Planilhas de Planejamento Or�ament�rio           ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA490                                                      ���
���_DESCRI_  � Programa de Cadastro de Planejamento Or�ament�rio            ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA020(2) - Executa a chamada da funcao de visua-  ���
���          �                       zacao da rotina.                       ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static lPnjR2	:= NIL

Function PCOA490(nCallOpcx,cPlanej,cVersao)

Private cCadastro	:= STR0001 //"Cadastro de Planejamento Or�ament�rio "
Private aRotina := MenuDef()
Private cChvALV
Private _cVerPlan
Private cIDPlanej:= STR0030

loadVar490()

If cPlanej<>nil .and. cVersao<>nil

	_cVerPlan	:= cVersao
	A490Param( nCallOpcx , cPlanej , cVersao )

Else

	If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	
		If nCallOpcx <> Nil
			PCO490INC(,,nCallOpcx)
		Else
			mBrowse(6,1,22,75,"ALV")
		EndIf
		
	EndIf

EndIf

Return

Static Function A490Param( nCallOpcx , cPlanej , cVersao )

//Local aConfig := {}

/*
	If ParamBox({{ 3 , "Revisar Planejamento" ,1,{ "Receita" , "Despesa" , "Mov. n�o Oper." , "Folha de Pagamento" },100,,.F.} },;
		"Revis�o de Planejamento"  ,aConfig,,,,,,,"PcoRevPnj",,.T.)

		DbSelectArea("ALV")
		DbSetOrder(1)
		DbSeek( xFilial("ALV") + cPlanej )
		
		Do Case
			
			Case aConfig[1]=1

				PCOA493("ALV",ALV->(Recno()), nCallOpcx , nil ,cVersao )
			
			Case aConfig[1]=2
			
				PCOA492("ALV",ALV->(Recno()), nCallOpcx , nil , cVersao )

			Case aConfig[1]=3
			
				PCOA494("ALV",ALV->(Recno()), nCallOpcx , nil , cVersao )

			Case aConfig[1]=4
			
				PCOA496("ALV",ALV->(Recno()), nCallOpcx , nil , cVersao )
		
		End
	
	EndIf
*/

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva    � Data�17/11/06   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���     
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina
Local aSubRotina

If lPnjR2
	// Planejamento vers�o P-10 R2
	aRotina 	:= {		{ STR0002				,		"AxPesqui"  		, 0 , 1, ,.F.},;    //"Pesquisar"
								{ STR0003			, 		"AxVisual"  		, 0 , 2},;  //"Visualizar"
								{ STR0004			, 		"PCO490INC"  		, 0 , 3},;	//"Incluir"
								{ STR0020			, 		"Pco490TpPl" 		, 0 , 4},;	//"Planejar"
								{ STR0005			,		'PCO490ALT'			, 0 , 4},;	//"Alterar"
								{ STR0006			,		'PcoDelePnj'		, 0 , 5},; 	//"Excluir"
								{ STR0022			,		'PcoGerOrc'			, 0 , 4}}	//"Gerar Planilha"
								
Else
	// Planejamento vers�o P-10 R1.3 Descontinuado
	aSubRotina := {  	{ OemtoAnsi(STR0025) 		,'PCOA493( nil , nil , 4 )'  , 0, 4 },; // "Receitas"
							{ OemtoAnsi(STR0026)	,'PCOA492( nil , nil , 4 )'  , 0, 4 },; // "Despesas"
							{ OemtoAnsi(STR0027)	,'PCOA494( nil , nil , 4 )'  , 0 , 4},; // "N�o Operacionais"
							{ OemtoAnsi(STR0028)	,'PCOA496( nil , nil , 4 )'  , 0 , 4}}  // "Folha de Pagamento"
	
	aRotina 	:= {		{ STR0002				,"AxPesqui"  				, 0 , 1, ,.F.},;    //"Pesquisar"
								{ STR0003			,"Pco490Dlg"  				, 0 , 2},;  //"Visualizar"
								{ STR0004			,"Pco490Dlg"  				, 0 , 3},;	//"Incluir"
								{ STR0020			, aClone(aSubRotina) 		, 0 , 4},;	//"Alterar"
								{ STR0005			,'Pco490Dlg'				, 0 , 4},;	//"Alterar"
								{ STR0006			,'PcoPnjDel'				, 0 , 5},; 	//"Excluir"
								{ STR0022			,'PcoGerPnj'				, 0 , 4}}	//"Gerar Planilha"
								
EndIf

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario na EnchoiceBar                              �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA4901" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Classes Orcamentarias                                �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA0201                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA4901", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf							
Return(aRotina)

Function Pco490Dlg(cAlias,nRecno,nCallOpcx)

Local aEnch 	:= {}
Local aCposNot	:= {}

If !lPnjR2

	aCposNot := {"ALV_CFGPLN"}

EndIf

aEval( GetaHeader(cAlias,,aCposNot) , {|x| aAdd(aEnch,x[2]) } )

Do Case
	Case  nCallOpcx == 2

		AxVisual(cAlias,nRecno,nCallOpcx,aEnch)

	Case  nCallOpcx == 3

		AxInclui(cAlias,nRecno,nCallOpcx,aEnch)

	Case  nCallOpcx == 5

		AxAltera(cAlias,nRecno,nCallOpcx,aEnch)

EndCase

Return

// **********************
// Planejamento P10 R2 *
// **********************
						
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pco490TpPl�Autor  �Acacio Egas         � Data �  07/29/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Seleciona o tipo de planejamento a planejar.               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pco490TpPl()

Local aParam := {}
Local aCombo := {{},{}}
Local aRet	 := {}
Local lRet   := PCO490VAP() // Verifica se usuario tem acesso a planilha

If lRet

	DbSelectArea("AMB")
	DbSetOrder(1)
	If !DbSeek(xFilial("AMB")+ALV->ALV_CFGPLN)
	 //MEnsagem de erro
			aAdd(aCombo[1],"01-"+STR0025) // "Receitas"
			aAdd(aCombo[1],"02-"+STR0026) // "Despesas"
			aAdd(aCombo[1],"03-"+STR0027) // "N�o Operacionais"
			aAdd(aCombo[1],"04-"+STR0028) // "Folha de Pagamento"
	
		aAdd(aParam,{2,STR0029,"   ",aCombo[1],100,,.T.}) // "Tipo de Planejamento"
		If Parambox(aParam,STR0030,aRet) // "Planejamento"
		
			cChvALV	:= ALV->ALV_CODIGO+ALV->ALV_VERSAO
			_cVerPlan	:= ALV->ALV_VERSAO
			
			If SubStr(aRet[1],1,2)=='01'
				PCOA493( nil , nil , 4 )
			ElseIf  SubStr(aRet[1],1,2)=='02'
				PCOA492( nil , nil , 4 )
			ElseIf  SubStr(aRet[1],1,2)=='03'
				PCOA494( nil , nil , 4 )
			Else
				PCOA496( nil , nil , 4 )
			EndIf
	
		EndIf
								
	Else
		DbSelectArea("AM1")
		DbSetOrder(2)
		DbSeek(xFilial("AM1")+ALV->ALV_CFGPLN)
		Do While AM1->(!Eof()) .and. xFilial("AM1")+ALV->ALV_CFGPLN==AM1->AM1_FILIAL+AM1->AM1_CFGPLN
			aAdd(aCombo[1],AM1->AM1_CODIGO + "-" + Capital(AM1->AM1_DESCR))
			aAdd(aCombo[2],AM1->(Recno()))
			AM1->(DbSkip())
		EndDo
		aAdd(aParam,{2,STR0029,"   ",aCombo[1],100,,.T.}) // "Tipo de Planejamento"
		If Parambox(aParam,STR0030,aRet) // "Planejamento"
		
			cChvALV	:= ALV->ALV_CODIGO+ALV->ALV_VERSAO
			_cVerPlan	:= ALV->ALV_VERSAO
			
			pco490Plan(ALV->ALV_CFGPLN,SubStr(aRet[1],1,3))
	
		EndIf
	EndIf
	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �pco490Plan�Autor  �Acacio Egas         � Data �  07/29/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Abre o planejamento de um determinado tipo de planejamento.���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function pco490Plan(cCfgPlan,cTpPlan)

Local aScreenRes	:= FwGetDialogSize(oMainWnd)
Local nWidth		:= aScreenRes[4]
Local nHeight		:= aScreenRes[3]

Local lContinua		:= .T.
Local nCont,nI
Local lEntOrc		:= .F.

Private _aGetValue	:= {}
Private _aGetQuant	:= {}
Private aDataPlnj 	:= {}
Private _aListData 	:= PcoRetPer(ALV->ALV_INIPER,ALV->ALV_FIMPER,ALV->ALV_TPPERI,.F.,aDataPlnj)

Private oPlanej
Private aMenu		:= {}
Private aEntNot		:= {} // Entidade que n�o seram apresentadas da grade de entidades por estarem na estrutura.

DbSelectArea("AM1")
DbSetOrder(2)
If !DbSeek(xFilial("AM1")+cCfgPlan+cTpPlan)
	lContinua	:= .F.
EndIf

If lContinua

	oPlanej := PCOLayer():New(0,0, nWidth, nHeight, Capital(AM1->AM1_DESCR) )
	DbSelectArea("AMB")
	DbGoTop()
	
	//�������������������������������������������������������������������Ŀ
	//�  Maximiza a oDlg principal, deixando o tamanho correto da window  �
	//���������������������������������������������������������������������
	oPlanej:ODLG:LMAXIMIZED := .T.

	// Cria divisao vertical na janela
	oPlanej:addSide(28, STR0031 ) //"Estrutura de Planejamento"

	//Cria  Layouts para a Tela
	oPlanej:AddLayout(STR0032,,.T.) // "Inicio"
	oPlanej:AddLayout(STR0035,,.T.) // "Estrutura"
	oPlanej:AddLayout(STR0030,,.T.) // "Planejamento"
	
	oPlanej:AddWindow(100,"WIN1", STR0031 ,.F.,"SIDE") //"Estrutura de Planejamento"
	
	oPlanej:AddTre("001","WIN1",nil,,/*.T.*/)
	
	
	// Monta Estrutura do Tree
	oPlanej:No_Tree( STR0033 ,"ALV","ALLTRIM(ALV_CODIGO)+'-'+ALV_DESCRI"	,"RPMCPO"	,{|| oPlanej:ShowLayout(STR0032)	}	,MontaBlock("{|oTre,x,y| Pco490Righ('ALV',oTre, x, y)}"),,,.T.,"'" + ALV->ALV_CODIGO + "'") // "Planejamento" ## "Inicio"

	// *************************************************
	//  Prepara a Estrtura do Tipo de Planejamento    *
	// Tabela AMC-Estrutura do Tipo de Planejamento   *
	// *************************************************
    DbSelectArea("AM2")
    DbSetOrder(3)
	DbSeek(xFilial("AM2")+cChvALV + AM1->AM1_CODIGO)

	DbSelectArea("AMC")
	DbSetOrder(1)
	DbSeek(xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO)
	lIni	:= .T.
	lMovimen	:= .F.
	Do While AMC->(!Eof()) .and. xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO==AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD)
		lEntOrc := .F.
		AMC->(DbSkip())
		If AMC->(Eof()) .or. xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO<>AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD)
			lMovimen	:= .T.
		EndIf          
		AMC->(DbSkip(-1))

		If !Empty(AMC->AMC_ENTORC)
			aAdd( aEntNot , { AMC->AMC_NIVEL , AMC->AMC_ENTORC , AMC->AMC_TABELA } )
			&("M->"+Alltrim(AMC->AMC_ENTORC)) := CriaVar(Trim(AMC->AMC_ENTORC),.F.)
			lEntOrc := .T.
		EndIf

		If lIni
			DbSelectArea("AM2")
			DbSetOrder(3)
			DbSeek(xFilial("AM2")+cChvALV + AM1->AM1_CODIGO)
			DbSelectArea(AMC->AMC_TABELA)
			oPlanej:No_Tree( AMC->AMC_DESCTB ,"AM2"/*AMC->AMC_TABELA*/ , Alltrim(AMC->AMC_DESCIT), "SIMULACA"	,MontaBlock("{|| oPlanej:ShowLayout('" + If(lMovimen, STR0030 , STR0035 ) + "')," + If(lEntOrc, "M->"+Alltrim(AMC->AMC_ENTORC) + " := AM2->AM2_AGREG "  , ".T." )+ "}"),MontaBlock("{|oTre,x,y| Pco490Righ('" + AMC->AMC_TABELA +"',oTre, x, y)}"),,MontaBlock("{|| " + AMC->AMC_POSIC + ",.T.}"),.T.,"'" + cChvALV + AM1->AM1_CODIGO + SPACE(8) + "'",4) // "Tipos de Planejamento" ## "PLanej" ## "Estrut"
			lIni:= .F.
        Else
			DbSelectArea(AMC->AMC_TABELA)
			oPlanej:No_Tree( AMC->AMC_DESCTB ,"AM2"/*AMC->AMC_TABELA*/ , Alltrim(AMC->AMC_DESCIT), "SIMULACA"	,MontaBlock("{|| oPlanej:ShowLayout('" + If(lMovimen, STR0030 , STR0035 ) + "')," + If(lEntOrc, "M->"+Alltrim(AMC->AMC_ENTORC) + " := AM2->AM2_AGREG "  , ".T." )+ "}"),MontaBlock("{|oTre,x,y| Pco490Righ('" + AMC->AMC_TABELA +"',oTre, x, y)}"),,MontaBlock("{|| " + AMC->AMC_POSIC + ",.T.}"),.T.,"'" + cChvALV + AM1->AM1_CODIGO + "'+AM2->AM2_ID",4) // "Tipos de Planejamento" ## "PLanej" ## "Estrut"
		EndIf
		AMC->(DbSkip())
	EndDo
	
	// *************
	//  Layout 01 *
	// *************	
	oPlanej:AddWindow( 50 , "L1WIN2" , STR0033 , .F. , STR0032) //"Planilha de Planejamento" ## "Inicio"
		// Cria variaveis de memoria para a MSMGet
		RegToMemory("ALV", .F.,,, FunName())
		//Cria MsmGet
		oPlanej:AddMsm("001", STR0033 , "ALV" , ALV->(Recno()) , "L1WIN2" , STR0032 , {|x| } , {|x| } ) //"Planejamento" ## "Inicio"
	
	oPlanej:AddWindow( 50 , "L1WIN3" , STR0034 , .F. , STR0032) //"Itens do Planejamento" ## "Inicio"
		oPlanej:AddMBrowse("001",STR0034,"AM2",2,'xFilial("AM2")+ cChvALV + AM1->AM1_CODIGO' ,NIL,{"AM2_ID","AM2_AGREG"},"L1WIN3",STR0032,/*bShow*/) // "Itens do Planejamento" ## "Inicio"
	
	// *************
	//  Layout 02 *
	// *************
	oPlanej:AddWindow( 50 , "L2WIN4" , STR0022 , .F. , STR0035) //"Planilha de Planejamento" ## "Estrutura"
		// Cria variaveis de memoria para a MSMGet
		RegToMemory("ALV", .F.,,, FunName())
		//Cria MsmGet
		oPlanej:AddMsm("001", STR0033 , "ALV" , ALV->(Recno()) , "L2WIN4" , STR0035 , {|x| } , {|x| } ) //"Planejamento" ## "Estrutura"
	
	oPlanej:AddWindow( 50 , "L2WIN5" ,STR0036 , .F. , STR0035) //"SUb-Itens do Planejamento" ## "Estrutura"
		oPlanej:AddMBrowse("001",STR0034,"AM2",4,'xFilial("AM2")+ cChvALV + AM1->AM1_CODIGO+AM2->AM2_ID' ,NIL,{"AM2_ID","AM2_AGREG"},"L2WIN5",STR0035,/*bShow*/) // "Itens do Planejamento" ## "Estrutura"
	
	// *************
	//  Layout 03 *
	// *************
	oPlanej:AddWindow( 50 , "L3WIN6" , STR0037 , .T. , STR0030) //"Distribui��o de Entidades" ## "Planejamento"
		
		aCposNot := {}
		For nI := 1 to Len(aEntNot)
			aAdd( aCposNot , aEntNot[nI,2] )
		Next
			
		DbSelectArea("AMD")
		DbSetOrder(1)
		If DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
			nCont	:= 1
			Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO==AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
				// Inclui campos na GetDados		
				aCpos := {"ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
				If ExistBlock("PCOA4902")
					If VALTYPE(aCposUsr := ExecBlock("PCOA4902",ALV->ALV_CFGPLN,AM1->AM1_CODIGO))="A"
						aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
					EndIf
				EndIf
	 			If AMD->AMD_TPVAR=='2'
		 			aAdd(aCpos,"ALX_CODIGO") // Adiciona o item relacionado
	 			EndIf
									//cID				,cTitulo					,cAlias	,nOrder	,cSeek																					,aCposNao	,aCposSim	,cWindow	,cLayout	,bOk	,bChangeUsr																												,bLoad	,bConfirm	,bSave																	,cAutoInc
	 			oPlanej:AddGetDado(	StrZero(nCont,3)	,Capital(AMD->AMD_DESVAR)	,"ALX"	,4		,"xFilial('ALX')+ cChvALV + AM1->AM1_CODIGO + '" + AMD->AMD_VARCOD + "'+AM2->AM2_ID"	,aCposNot	,aCpos		,"L3WIN6"	,STR0030	,		,{|| PcoLoadVal(aDataPlnj,.T.,.F.)	,oPlanej:GetMsm("002"):EnchRefreshAll()	,oPlanej:GetMsm("003"):EnchRefreshAll() }	,		,			,MontaBlock("{|aRecs| PcoALXIni('" + AMD->AMD_VARCOD + "',aRecs) }")	,			) // "PLanej"
				nCont++
				AMD->(DbSkip())
			EndDo
		Else
			Aviso( STR0015 , STR0038 ,{ "OK" }) // "Aten��o" ## "N�o existem varia��es para este tipo de planejamento!"
		EndIf

	oPlanej:AddWindow( 50 , "L3WIN7" , STR0039 , .T. , STR0030) //"Valores de Planejamento" ## "Planejamento"
		// ********************************************************
		//  Gera Variaveis de Memoria para a MsmGetAutoContida   *
		// ********************************************************
		// Gera vari�veis para utiliza��o na MsMGet
		For nI := 1 to Len(_aListData)	
			_SetOwnerPrvt("VLR" + StrZero(nI,3),CriaVar(Trim("ALY_VALOR"),.F.))		
			_SetOwnerPrvt("QTD" + StrZero(nI,3),CriaVar(Trim("ALY_VALOR"),.F.))		
			// Criando campos para a MsmGet
			SX3->(DbSetOrder(2))
			SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
			ADD FIELD _aGetValue TITULO _aListData[nI] CAMPO "VLR" + StrZero(nI,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
			ADD FIELD _aGetQuant TITULO _aListData[nI] CAMPO "QTD" + StrZero(nI,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
		Next	
		//Cria MsmGet
		oPlanej:AddMsm("003", STR0040 , "ALY" , ALY->(Recno()) , "L3WIN7" , STR0030 	, {|| PcoLoadVal(aDataPlnj,.T.,.F.) } , {|x| PcoLoadVal(aDataPlnj,.T.,.T.) } , _aGetQuant ) //"Quantidades"
		oPlanej:AddMsm("002", STR0041 , "ALY" , ALY->(Recno()) , "L3WIN7" , STR0030 	, {|| PcoLoadVal(aDataPlnj,.F.,.F.) } , {|x| PcoLoadVal(aDataPlnj,.F.,.T.,100) } , _aGetValue ) //"Valores"
	
	oPlanej:ShowLayout(STR0032) // "Inicio"
	// Inicializa o Tree
	//AtuAgreg(.t.)
	oPlanej:Activate(,.T.)

EndIf
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PopupMenu �Autor  �Acacio Egas         � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o executada ao clicar bot�o direita no xTree.         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Pco490Righ(cAlias,oTree, x, y)

Local oMenu

oMenu:= PopupMenu(cAlias,@oTree)

If oMenu <> Nil

	oMenu:Activate(x - 35, y - 125, oTree )

EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PopupMenu �Autor  �Acacio Egas         � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Popup executado no xTree                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PopupMenu(cAlias,oTree)

Local nMenu,cVarIni
Local aAreaAMC	:= AMC->(GetArea())
Local lFim		:= .F.
Local aNextEntid:= {}
Local aPrevEntid:= {}

If Len(aMenu)>0 .and. (nMenu := aScan(aMenu,{|x| x[1]==cAlias}))>0
	aMenu[nMenu][2]:Free()
Else
	aAdd(aMenu,{cAlias,nil})
	nMenu := Len(aMenu)
EndIf

If cAlias=="ALV"
	DbSelectArea("AMC")
	DbSetOrder(1)
	DbSeek(xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO)
    aNextEntid	:= {AMC->AMC_TABELA,Capital(Alltrim(AMC->AMC_DESCTB)),Alltrim(AMC->AMC_CHAVE),AMC->AMC_SXB}

	Menu aMenu[nMenu][2] Popup
	MenuItem STR0042 + aNextEntid[2]	Block MontaBLock("{|| Pco490Ent('" + aNextEntid[1] + "','"+ aNextEntid[4 ] + "','" + aNextEntid[3] + "','" + aNextEntid[2] + "',.T.)}") //"Adicionar Item"
	EndMenu
    
Else	        
	
	DbSelectArea("AMC")
	DbSetOrder(1)
	DbSeek(xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO)
	Do While AMC->(!Eof()) .and. xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO==AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD)
		If AMC->AMC_TABELA==cAlias
			lFim	:= .T.
			aPrevEntid	:= {AMC->AMC_TABELA,Capital(Alltrim(AMC->AMC_DESCTB)),Alltrim(AMC->AMC_CHAVE)}
        else
	        lFim	:= .F.
		    aNextEntid	:= {AMC->AMC_TABELA,Capital(Alltrim(AMC->AMC_DESCTB)),Alltrim(AMC->AMC_CHAVE),AMC->AMC_SXB}
		EndIf
		AMC->(DbSkip())
	EndDo

	Menu aMenu[nMenu][2] Popup

	If lFim

		DbSelectArea("AMD")
		DbSetOrder(1)
		DbSeek(xFilial("AMD")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO)
		
		MenuItem STR0044 Block MontaBlock("{|| PcoShowDis('" + AM2->AM2_ID +"' ," + If(AMD->AMD_TIPO=="1",".T.",".F.") + ",'" + AMD->AMD_VARCOD + "')}") //"Visualizar Distribui��o "
		MenuItem STR0045 Block MontaBlock("{|| PcoReprPnj('" + AM2->AM2_ID + "','" + AM1->AM1_CODIGO + "','" + AMD->AMD_VARCOD + "'," + If(AMD->AMD_TIPO=="1",".T.",".F.") + "),oPlanej:ShowLayout(cIDPlanej) }") // "Alterar Distribui��o "
		MenuItem "___________________" Disabled
	EndIf

	MenuItem STR0046 + aPrevEntid[2]	Block MontaBLock("{|| Pco490EDel(" + If(lFim,".T.",".F.") +")}") //"Exclui Item"
	MenuItem "___________________" Disabled

	If lFim

		nTamIndex := Len(xFilial("AMD")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO)
		Do While AMD->(!Eof()) .and. xFilial("AMD")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO==SubStr(AMD->(&(IndexKey())),1,nTamIndex)
			MenuItem STR0047 + Capital(AMD->AMD_DESVAR)	Block MontaBlock("{|| Pco490Ger('" + AMD->AMD_VARCOD +"','" + AMD->AMD_TPVAR +"','" + AMD->AMD_TIPO + "',MontaBlock('{|cItem,cTpPlan,cVar| Paramixb := {cItem,cTpPlan,cVar}," + AMD->AMD_VRUNIT + "}'),.F.)}") // "Gerar "
			MenuItem STR0046 + Capital(AMD->AMD_DESVAR)	Block MontaBlock("{|| Pco490Ger('" + AMD->AMD_VARCOD +"','" + AMD->AMD_TPVAR +"',,,.T.)}") // "Excluir "
			MenuItem "___________________" Disabled
			AMD->(DbSkip())
		EndDo                                                            
		MenuItem STR0048 Block MontaBlock("{|| PcoAltPnj('" + AM2->AM2_ID + "',,,'" + AM1->AM1_CODIGO + "') }") // "Reajustar"
		EndMenu
	Else

		MenuItem STR0042 + aNextEntid[2]	Block MontaBLock("{|| Pco490Ent('" + aNextEntid[1] + "','"+ aNextEntid[4] + "','" + aNextEntid[3] + "','" + aNextEntid[2] + "',.F.)}") //"Adicionar Item"
		EndMenu

	EndIf
EndIf

RestArea(aAreaAMC)

Return aMenu[nMenu][2]

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pco490Ent �Autor  �Acacio Egas         � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Apresenta a parambox para incluir itens de planejamento.   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pco490Ent(cAlias,cSxb,cCpoChv,cDesc,lIni)

Local aRet	:= {}
Local aParam:= {}
Local cChave
Local nTam
Local cIni
Local lRefresh	:= .F.
Local cIdPai	:= ""

DbSelectArea(cAlias)
cIni	:= Space(Len(CriaVar(SubStr(cCpoChv,6))))

aAdd(aParam,{1, cDesc + " de", cIni, "@!", "ExistCpo('" + cAlias + "')", Alltrim(cSxb), ".T." , 100, .T.})
aAdd(aParam,{1, cDesc + " ate", cIni, "@!", "ExistCpo('" + cAlias + "')", Alltrim(cSxb),".T." , 100, .T.})

If Parambox(aParam,STR0049,aRet) // "Incluir item de Planejamento"

	If !lIni
		cIdPai := AM2->AM2_ID
	EndIf
	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbSeek(xFilial(cAlias)+aRet[1])
	cChave := (cAlias)->(INdexKey()) 
	nTam	:= Len(xFilial(cAlias)+aRet[1])
	Do While (cAlias)->(!Eof()) .and. Padr(&(cChave),nTam)>=xFilial(cAlias)+aRet[1] .and. Padr(&(cChave),nTam)<=xFilial(cAlias)+aRet[2]
		RecLock("AM2",.T.)
		AM2->AM2_FILIAL := xFilial("AM2")
		AM2->AM2_PLANEJ := ALV->ALV_CODIGO
		AM2->AM2_VERSAO := _cVerPlan
		AM2->AM2_AGREG  := SubStr((cAlias)->(&(cChave)),Len(xFilial("AM2"))+1)
		AM2->AM2_TIPOPL := AM1->AM1_CODIGO//"001'
		MsUnlock()
		RecLock("AM2",.F.)
		AM2->AM2_ID		:= StrZero(AM2->(Recno()), Len(AM2->AM2_ID) )
		AM2->AM2_IDPAI	:= cIdPai  //so eh preenchido quando eh filho
		MsUnlock()
		DbSelectArea(cAlias)
		(cAlias)->(DbSkip())
	EndDo
	oPlanej:RefreshTre("001") //Atualiza o Tree

EndIf

Return lRefresh

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pco490EDel�Autor  �Acacio Egas         � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Deleta item da estrutura do planejamento tabela AM2.       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pco490EDel(lMov)

Local aArea	:= GetArea()
Local lDel	:= .T.

If lMov

	DbSelectArea("ALX")
	DbSetOrder(3)
	If DbSeek(xFilial("ALX")+AM2->AM2_ID)
		Aviso(STR0015,STR0050 + CHR(13) + STR0051, {"OK"}) // "Aten��o" ## "Existem lan�amentos para este item do planejamento!" ## " Favor excluir os movimentos."
		lDel	:= .F.
	EndIf

Else
	DbSelectArea("AM2")
	DbSetOrder(4)
	If DbSeek(xFilial("AM2")+ cChvALV + AM1->AM1_CODIGO + AM2->AM2_ID)
		Aviso(STR0015,STR0052 + CHR(13) + STR0053, {"OK"}) // "Aten��o" ## "Existem sub-itens relacionanados a este item do planejamento!" ## " Favor excluir os sub-itens."
		lDel	:= .F.
	EndIf
EndIf

RestArea(aArea)

If lDel
		
		RecLock("AM2",.F.,.T.)
		DbDelete()
		MsUnlock()

		oPlanej:RefreshTre("001") //Atualiza o Tree
		oPlanej:ShowLayout(STR0032) // "Inicio"

EndIf

Return

Function Pco490Ger(cVar,cTpVaria,cTpValor,bVlrUnit,lDel)

Local nOpc

Default	cVar	:= ''
Default cTpValor:= '2'
Default lDel   	:= .F.

Private _cVarPnj:= cVar
If lDel
	nOpc	:= 5
EndIf

If !Empty(cTpVaria)
	PcoGerMovs(AM2->AM2_ID,cTpVaria,cVar,nOpc,(cTpValor=='1'),bVlrUnit)
	oPlanej:ShowLayout(STR0030) // "PLanej"
EndIf

Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA490   �Autor  �Microsiga           � Data �  06/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function PCO490INC(cAlias,nRecno,nCallOpcx)

Local aEnch 	:= {}
Local aCposNot	:= {}
Local aUser		:= {}
Local nRet		:= 0

If !lPnjR2
	aCposNot := {"ALV_CFGPLN"}
EndIf

aEval( GetaHeader(cAlias,,aCposNot) , {|x| aAdd(aEnch,x[2]) } )
nRet := AxInclui(cAlias,nRecno,nCallOpcx,aEnch)

If nRet == 1

	PswOrder(2)
	If PswSeek(cUserName,.T.)
		aUser := PswRet(1)
	Else
		Aadd( aUser , {  "000000" , "Administrador" } )
	EndIf

	DbSelectArea("AMU")
	RecLock("AMU",.T.)
	AMU->AMU_FILIAL := xFilial("AMU")
	AMU->AMU_CODPLN := ALV->ALV_CODIGO
	AMU->AMU_ITPLN 	:= "0001"
	AMU->AMU_CODUSR	:= aUser[1,1]
	AMU->AMU_NOMUSR	:= aUser[1,2]
	AMU->(MsUnLock())
	
ElseIf nRet != 1 .And. nRet != 3

	Help(" ",1,"PCOA490001")

EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA490   �Autor  �Microsiga           � Data �  06/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function PCO490ALT(cAlias,nRecno,nCallOpcx)
Local aEnch 	:= {}
Local aCposNot	:= {}

If PCO490VAP() // Verifica se usuario tem acesso a planilha

	If !lPnjR2
		aCposNot := {"ALV_CFGPLN"}
	EndIf
	
	aEval( GetaHeader(cAlias,,aCposNot) , {|x| aAdd(aEnch,x[2]) } )
	AxAltera(cAlias,nRecno,nCallOpcx,aEnch)
	
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCO490VAP �Autor  �Microsiga           � Data �  06/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o usuario da Planilha tem acesso para           ���
���          �manutencao                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �PCOA490                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Function PCO490VAP()
Local lRet		:= .F.
Local cContAce	:= SuperGetMv("MV_PCOCAPL",,"2") // 1=Liga ou 2=Desliga o controle de usuarios
Local aArea		:= {}
Local aAMUArea	:= {}

If cContAce == "1"

	aArea		:= GetArea()
	aAMUArea	:= AMU->(GetArea())
	
	PswOrder(2)
	If PswSeek(cUserName,.T.)
		aUser := PswRet(1)
	EndIf
	
	AMU->(DbSetOrder(1))
	lRet := AMU->(DbSeek(xFilial("AMU")+ALV->ALV_CODIGO+aUser[1,1]))
	
	If !lRet
		Help(" ",1,"PCOA490002")
	EndIf
	
	RestArea(aAMUArea)
	RestArea(aArea)

Else
	lRet := .T.
EndIf

Return lRet

function LoadVar490()

If lPnjR2 == NIL
	lPnjR2	:= !Empty(TAMSX3("AMD_CODIGO"))
EndIF

return 