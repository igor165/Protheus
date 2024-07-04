#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FATA150.CH"
STATIC __nTamBase := NIL
STATIC __cCodBase := NIL
STATIC lCat		:= SuperGetMV("MV_LJCATPR",,.F.) 	//Verifica variavel logica para acesso � rotina
STATIC cFiltro	:= ""								//variavel de controle de Filtro
Static lIntegDef	:= FWHasEAI("FATA150",.T.,,.T.) .And. FWHasEAI("MATA010",.T.,,.T.)	//Se esta config. integra��o de mensagem de produto com categoria
Static aCadCat		:= {}							//Array com os registros originais antes da altera��o, utilizado na Integra��o de Mensagem unica

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA150  � Autor � Eduardo Riera         � Data �06.09.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Amarracao Categoria x Grupos de Produtos       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FATA150()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FATA150()

Local oMBrowse	:= Nil
Local aLegenda	:= {}
Local nX		:= 0

Private cCadastro	:= STR0008                     		//Amarra��o Categoria x Grupo ou Produto
PRIVATE aRotina := MenuDef()

//�����������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                           �
//�������������������������������������������������������������������������
dbSelectArea("ACV")
dbSetOrder(1)
If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 ) .AND. lCat 
	Pergunte("LJ801",.T.)
	If  MV_PAR01 == 1
		cFiltro := "ACV->ACV_SUVEND <> '1'" 
	Else
		cFiltro := Iif( MV_PAR01 == 2, "ACV->ACV_SUVEND = '1'" ,"")
	EndIf
	MsFilter(cFiltro)
	mBrowse( 6,1,22,75,"ACV")
Else
	
	If Pergunte("FATA150",.T.)
	   INCLUI := .F.	
	
		//�����������������������������������������������������������������������Ŀ
		//� Endereca a funcao de BROWSE                                           �
		//�������������������������������������������������������������������������
		dbSelectArea("ACV")
		dbSetOrder(1)
		
		If mv_par01 == 1
			Aadd(aLegenda,{".T.","BR_VERDE", STR0016})  // "Categoria com Amarra��o"
		ElseIf mv_par01 == 2
			Aadd(aLegenda,{"Empty(ACV->ACV_CODPRO)"	, "BR_VERMELHO"	, STR0017 + " " + STR0018 }) // "Categoria sem Amarra��o" ## "por Produto"
		   	Aadd(aLegenda,{"!Empty(ACV->ACV_CODPRO)"	, "BR_VERDE"		, STR0016 + " " + STR0018 }) // "Categoria com Amarra��o" ## "por Produto"
		ElseIf mv_par01 == 3
			Aadd(aLegenda,{"Empty(ACV_GRUPO)"			, "BR_VERMELHO"	, STR0017 + " " + STR0019 }) // "Categoria sem Amarra��o" ## "por Grupo"
		   	Aadd(aLegenda,{"!Empty(ACV_GRUPO)"			, "BR_VERDE"		, STR0016 + " " + STR0019 }) // "Categoria com Amarra��o" ## "por Grupo"
		ElseIf mv_par01 == 4
			Aadd(aLegenda,{"Empty(ACV_REFGRD)"			, "BR_VERMELHO"	, STR0017 + " " + STR0020 }) // "Categoria sem Amarra��o" ## "por Grade"
			Aadd(aLegenda,{"!Empty(ACV_REFGRD)"		, "BR_VERDE"		, STR0016 + " " + STR0020 }) // "Categoria com Amarra��o" ## "por Grade"
		EndIf  
		
		oMBrowse := FWMBrowse():New()
		oMBrowse:SetAlias("ACV")			
		oMBrowse:SetDescription( cCadastro )
		
		// Adiciona as legendas no browse.
		For nX := 1 To Len(aLegenda)
			oMBrowse:AddLegend(aLegenda[nX][1],aLegenda[nX][2],aLegenda[nX][3])
		Next nX
		
		oMBrowse:SetAttach( .T. )
		//Se n�o for SIGACRM inibe a exibi��o do gr�fico
		If nModulo <> 73
			oMBrowse:SetOpenChart( .F. )
		EndIf
		oMBrowse:SetTotalDefault('ACV_FILIAL','COUNT',STR0033) // 'Total de Registros'
		oMBrowse:Activate()	
		
	EndIf

EndIf 

Return ( .T. )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150Manut � Autor � Eduardo Riera        � Data �06.09.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao no Cadastro de Amarracao Categoria x Grupo      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150Manut(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��� Fernando   �14/02/07�119225�Altera��o feita para usar a FilgetDados   ���
���            �        �      �na montagem do Aheader e Acols            ���
��� Fernando   �15/03/07�121315�Altera��o feita para na inclus�o o campo  ���
���            �        �      �Categoria vir vazio                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150Manut(cAlias, nRecno, nOpc)

Local aArea     := GetArea()
Local aRecNo    := {}
Local aSize     := MsAdvSize(.T.)
Local aObjects  := {}
Local aInfo     := {}
Local nOpcA    	:= 0
Local nCntFor  	:= 0
Local nUsado   	:= 0
Local nSaveSx8  := GetSX8Len()
Local cAliasACV := "ACV"
Local lQuery    := .F.
Local oDlg
Local oGetD 

Local nIndex := 0
Local cSeek  	:= Nil
Local cWhile 	:= Nil

Local lFt150Grv	:= ExistBlock("FT150GRV")  
Local aFt150CpoCab	:= {} // Campos do Cabecalho da tela (enchoice)

Local aVisual := {}
Local aAltera := {}
Local oEnch

Local cQuery    := ""
Local aStruACV  := {} 
Local cFt150Seq	:= ""
Local cDescProd	:= ""

Local aNoFields  := {}
Local aYesFields := {}

//��������������������������������Ŀ
//�Tratamento para e-Commerce      �
//����������������������������������
Local lECommerce 	:= SuperGetMV("MV_LJECOMM",,.F.) 
Local lECCia 		:= SuperGetMV("MV_LJECOMO",,.F.)

//���������������������������������������Ŀ
//�Tratamento Integracao POS - Synthesis  �
//�����������������������������������������
Local lIntPOS := (SuperGetMV("MV_LJSYNT",,"0") == "1")

//����������������������������������������������������������Ŀ
//�Cria xHeader, xCols para amarracao do Filtro e-Commerce   �
//������������������������������������������������������������
Local xHeader       := {}         //aHeader para a amarracao do Filtro e-Commerce.
Local xCols         := {}         //aCols para a amarracao do Filtro e-Commerce.
Local xCopia        := {}         //Copia do xCols inicial para comparar na gravacao e identificar o que foi alterado/excluido.
Local xAltera       := {}         //Campos que podem ser alterados na grid.
Local xCombo        := {}         //Valores dos Conteudos dos Filtros que servirao como combobox na grid.
Local xFiltros      := {}         //Controla os codigos dos filtros no aHeader

Local aButton       := {}

PRIVATE bRefresh	:= {|| oGetd:oBrowse:Refresh() }	// Bloco de codigo que sera chamado na funcao
PRIVATE aHeader 	:= {}
PRIVATE aCols   	:= {}
PRIVATE lCopia 		:= aRotina[nOpc][4] == 8

RegToMemory(cAlias,INCLUI)

//������������������������������������������������������Ŀ
//� Montagem do aHeader.                                 �
//��������������������������������������������������������
If nOpc <>3
	If ( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 )  .AND.  lCat 
		cFt150Seq := ACV->ACV_SEQPRD
	EndIf
Else
	If ( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 )  .AND.  lCat 
		cFt150Seq	:= CriaVar("ACV_SEQPRD",.F.)
	EndIf	
EndIf
dbSelectArea( cAliasACV )

#IFDEF TOP
	lQuery := .T.
	
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("ACV")+" ACV "
	cQuery += "WHERE "
	cQuery += "ACV.ACV_FILIAL = '"+xFilial("ACV")+"' AND "
	cQuery += "ACV.ACV_CATEGO ='"+M->ACV_CATEGO+"' AND "
	cQuery += "ACV.D_E_L_E_T_= ' ' "
	//������������������������������������������������Ŀ
	//�Se for Release  11.5 Ordena por Sequencia	   �
	//��������������������������������������������������
  		If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 )  .AND.  lCat 
	    cQuery += "ORDER BY "+SqlOrder(ACV->(IndexKey(6)))
	Else		
		cQuery += "ORDER BY "+SqlOrder(ACV->(IndexKey()))
	Endif
	cQuery := ChangeQuery(cQuery)

 	
#ELSE 
	//������������������������������������������������������������Ŀ
	//�Se Estiver no Release 11.5 DbSetOrder (6) caso contrario (1)�
	//��������������������������������������������������������������
	If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 )  .AND.  lCat 
		DbSetOrder(6)				//Filial + Sequ�ncia        
		DbSeek( xFilial("ACV") + cFt150Seq )
	Else
		DbSetOrder(1)              // Filial + Categoria + Grupo + Produto 
		DbSeek( xFilial("ACV") + M->ACV_CATEGO )
	EndIf		
#ENDIF

//��������������������������������������������������Ŀ
//�Se Estiver no Release 11.5 � ORdenado por ACV_SEQ �
//����������������������������������������������������
If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 )  .AND.  lCat 
   	cSeek  := xFilial("ACV") + ACV->ACV_SEQPRD
 	cWhile :="ACV->ACV_FILIAL + ACV->ACV_SEQPRD"
Else                                      
 	cSeek  := xFilial("ACV") + ACV->ACV_CATEGO
  	cWhile 	:="ACV->ACV_FILIAL + ACV->ACV_CATEGO"
EndIf

DbSelectArea("ACV")
DbCloseArea()
//������������������������������������������������������������������������������������������Ŀ
//�nOpc = 6 (Ordenar)                                                                        �
//�Caso a opcao seja ordenar chama fun��o para nova funcionalidade do projeto de ordena��o   �
//��������������������������������������������������������������������������������������������
If(nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72)  .AND.  lCat .AND. nOpc == 6
	aAdd(aNoFields, "ACV_CATEGO")
	aAdd(aNoFields, "ACV_DESCAT")

	If lCopia
		aEval(aNoFields, {|cCampo|  &("M->"+cCampo):= CriaVar(cCampo,.T.) } )
	EndIf

	aAdd(aVisual,"NOUSER")
	aEval(aNoFields, {|cCampo| aAdd(aVisual, cCampo) } )

	Aadd(aHeader,	{"","UP","@BMP",20,00,,,"C",,"V" } )
	Aadd(aHeader,	{"","DOWN","@BMP",20,00,,,"C",,"V" } )
	Aadd(aHeader,	{"Ordem","ORDEM"," ",20,00,,,"C",,"V" } )

	FillGetDados(	nOpc 		, "ACV", 1 , cSeek,;
					{||&(cWhile)}, /*{|| bCond,bAct1,bAct2}*/, aNoFields/*aNoFields*/,;
					/*aYesFields*/, /*lOnlyYes*/, cQuery, /*bMontAcols*/, IIf(nOpc<>3,.F.,.T.),;
					aHeader, /*aColsAux*/,{||Ft150Rec(aRecNo,cQuery,nOpc)} , /*bBeforeCols*/,;
					/*bAfterHeader*/, "ACV", {|cField|Ft150GD(cField)}/*bCriaVar*/)

	If lQuery
		DbSelectArea(cAliasACV)
		DbCloseArea()
		DbSelectArea("ACV")
	EndIf

Else
	Pergunte("FATA150",.F.)
	
	aNoFields:={}
	Do Case
		
		Case mv_par01 == 1 //-- Por Categoria
			
			nIndex := 1 //-- ACV_FILIAL+ACV_CATEGO+ACV_GRUPO+ACV_CODPRO
			cSeek  := xFilial("ACV") + M->ACV_CATEGO
			cWhile := "ACV->ACV_FILIAL + ACV->ACV_CATEGO"
			
			aAdd(aNoFields, "ACV_CATEGO")
			aAdd(aNoFields, "ACV_DESCAT")
			
		Case mv_par01 == 2 //-- Por Produto
			If Empty(M->ACV_CODPRO) .and. !Inclui
				HELP("",1,"FT150E01",,RetTitle("ACV_CODPRO")) //-- Registro n�o dispon�vel para esta op��o de visualiza��o
				Return (.F.)
			Else
				nIndex := 5 //-- ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
				cSeek  := xFilial("ACV") + M->ACV_CODPRO
				cWhile := "ACV->ACV_FILIAL + ACV->ACV_CODPRO"
				cDescProd := M->ACV_DESPRO
			EndIf	
			aAdd(aNoFields, "ACV_CODPRO")
			aAdd(aNoFields, "ACV_DESPRO")
			
		Case mv_par01 == 3 //-- Por Grupo
			If Empty(M->ACV_GRUPO) .and. !Inclui
				HELP("",1,"FT150E01",,RetTitle("ACV_GRUPO")) //-- Registro n�o dispon�vel para esta op��o de visualiza��o
				Return (.F.)
			Else
				nIndex := 2 //-- ACV_FILIAL+ACV_GRUPO+ACV_CODPRO+ACV_CATEGO
				cSeek  := xFilial("ACV") + M->ACV_GRUPO
				cWhile := "ACV->ACV_FILIAL + ACV->ACV_GRUPO"
			EndIf
			aAdd(aNoFields, "ACV_GRUPO")
			aAdd(aNoFields, "ACV_DESGRU")
			
		Case mv_par01 == 4 //-- Por Grade
			If Empty(M->ACV_REFGRD).and. !Inclui
				HELP("",1,"FT150E01",,RetTitle("ACV_REFGRD")) //-- Registro n�o dispon�vel para esta op��o de visualiza��o
				Return (.F.)
			Else		
				nIndex := 4 //-- ACV_FILIAL+ACV_GRUPO+ACV_REFGRD+ACV_CATEGO
				cSeek  := xFilial("ACV") + Space(Len(ACV->ACV_GRUPO)) + M->ACV_REFGRD
				cWhile := "ACV->ACV_FILIAL + ACV->ACV_GRUPO + ACV->ACV_REFGRD"
			EndIf	
			aAdd(aNoFields, "ACV_REFGRD")
			aAdd(aNoFields, "ACV_DESREF")
			
	EndCase
	
	If lCopia
		aEval(aNoFields, {|cCampo|  &("M->"+cCampo):= CriaVar(cCampo,.T.) } )
	EndIf
	
	aAdd(aVisual,"NOUSER")
	aEval(aNoFields, {|cCampo| aAdd(aVisual, cCampo) } )
	
	If mv_par01 != 1
		aAdd(aNoFields, "ACV_CODPRO")
		aAdd(aNoFields, "ACV_DESPRO")
		aAdd(aNoFields, "ACV_GRUPO")
		aAdd(aNoFields, "ACV_DESGRU")
		aAdd(aNoFields, "ACV_REFGRD")
		aAdd(aNoFields, "ACV_DESREF")
	EndIf
	
	FillGetDados(	nOpc 		, "ACV", nIndex, cSeek,;
						{||&(cWhile)}, /*{|| bCond,bAct1,bAct2}*/, aNoFields,;
						/*aYesFields*/, /*lOnlyYes*/, /*/cQuery/*/, /*bMontAcols*/, IIf(nOpc<>3,.F.,.T.),;
						/*aHeaderAux*/, /*aColsAux*/,Iif(!lCopia,{||Ft150Rec(aRecNo,,nOpc)},Nil) , /*bBeforeCols*/,;
						/*bAfterHeader*/, "ACV")

EndIf

If lIntegDef
	//Faz a copia do aCols para se ter as categorias incialmente
	aCadCat := aClone(aCols)
EndIf

If lCopia
	nOpc := 3 //-- Inclus�o
	INCLUI := .T.
	ALTERA := .F.
EndIf

If (mv_par01 == 1) .And. lECommerce .And. !lECCia //-- Por Categoria
	If  lECommerce .And. ChkFile("MF9") .And. ChkFile("MFA") .And. ChkFile("MFB") .And. ChkFile("MFC")
        Aadd(aButton, {"SIMULACAO",{|| Ft150ECFiltro(@xHeader, @xCols, @xCopia, @xAltera, @xCombo, @xFiltros, M->ACV_CATEGO) },STR0032 } )  //"Filtro e-Commerce"
	EndIf
EndIf	

//������������������������������������������������������Ŀ
//� Ativa a Dialog.                                      �
//��������������������������������������������������������
aAdd( aObjects, { 100, 15, .T., .T. })
aAdd( aObjects, { 100, 85, .T., .T. })
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( cAlias, nRecno, nOpc,,,,aVisual, aPosObj[1],Iif(INCLUI,Nil,{})/*aAltera*/,,,,,,,.T. )

	oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],If(nOpc==6, 2,nOpc),"FT150LinOK", "FT150TudOk",,.T.,,,, 99999 )
	
	//�������������������������������������������������������������������Ŀ
	//�Chama fun��o para que faz o Swap quando for Release 11.5 e nOpc = 6�
	//���������������������������������������������������������������������
	If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 )  .AND.  lCat .AND. nOpc == 6
		oGetd:oBrowse:bLDblClick := {| uOpc,nCol | Ft150Swp(nCol, oGetd:oBrowse:bLDblClick) }
		oGetd:oBrowse:bChange := { |a, b, c, d| Ft150Col( a, b, c, d) }
	EndIf

	If nOpc <> 3 .And. MV_PAR01 == 2 //-- Por Produto
		M->ACV_DESPRO := cDescProd
	EndIf
		
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetD:TudoOk(),(nOpcA:= 1,oDlg:End()),.T.)},{||oDlg:End()},, aButton )

If nOpc > 2 .And. nOpcA == 1
	//������������������������������������������������Ŀ
	//� Funcao responsavel pela atualizacao do arquivo �
	//��������������������������������������������������
	BEGIN TRANSACTION
	
		//���������������������������������������Ŀ
		//�Tratamento Integracao POS - Synthesis  �
		//�����������������������������������������
		If lIntPOS
			Ft150POS()
		EndIf
	
		If Ft150Grv( nOpc-2, aNoFields, aRecNo)
			//Integrando Produto com categoria
			If lIntegDef 
				Processa( {|| Ft150PreInteg() }, STR0035, STR0036 ) //"Integrando os produtos das categorias" ##"Aguarde..."
			EndIf

			While (GetSx8Len() > nSaveSx8)
				ConfirmSx8()
			EndDo
			EvalTrigger() 

			If  (mv_par01 == 1) .And. lECommerce .And. !lECCia .And. (Len(xCols) > 0) //-- Por Categoria
			    Ft150ECGrv(aHeader, aCols, xHeader, xCols, xCopia, xFiltros, M->ACV_CATEGO)
			EndIf    
		Else
			While (GetSx8Len() > nSaveSx8)	
				RollBackSxe()
			Enddo	
		EndIf
	END TRANSACTION	
	If lFt150Grv
		aCopy(aVisual,aFt150CpoCab,2)
		
		If mv_par01 == 1 //-- Por Categoria
			ExecBlock("FT150GRV",.F.,.F.,{M->ACV_CATEGO,nOpc-2,aHeader,aCols,aClone(aFt150CpoCab)})
		Else
			ExecBlock("FT150GRV",.F.,.F.,{"",nOpc-2,aHeader,aCols,aClone(aFt150CpoCab)})
		EndIf
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//� Restaura a Integridade da Tela de Entrada.                             �
//��������������������������������������������������������������������������
RestArea(aArea)
If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 ) .AND. lCat .AND. !Empty(cFiltro)
	MsFilter(cFiltro)
EndIf
Return(.T.) 

//-------------------------------------------------------------------
/*/{Protheus.doc} Ft150ECFiltro
Amarracao Categoria X Produto X Filtro X Conteudo e-Commerce.
@sample   Ft150ECFiltro(xHeader, xCols, xCopia, xAltera, xCombo, aFiltros, cCategoria) 
@param    xHeader    - Header contendo os campos da amarracao 
@param    xCols      - aCols contendo os dados da amarracao. 
@param    xCopia     - Copia do aCols contendo os dados da amarracao antes de serem alterados pelo usuario. 
@param    xAltera    - Campos que podem ser alterados pelo usuario. 
@param    xCombo     - matriz com as opcoes de combo de cada filtro. 
@param    aFiltros   - matriz com o codigo e descricao de cada filtro, pois no dialogo sera apresentada somente a descricao.
@param    cCategoria - codigo da categoria que esta sendo amarrada aos filtros.
@return   lRet (Boolean) - sempre verdadeiro.

@author   Antonio C Ferreira
@since    23/04/2013
@version  P11.5
/*/
//-------------------------------------------------------------------

Static Function Ft150ECFiltro(xHeader, xCols, xCopia, xAltera, xCombo, aFiltros, cCategoria) 

Local aArea         := GetArea()
Local aAreaACU      := ACU->( GetArea() )

Local nA, nB
//���������������������������������������Ŀ
//�Salva aHeader, aCols e N               �
//�����������������������������������������
Local zHeader       := AClone(aHeader)
Local zCols         := AClone(aCols)
Local nN            := N 
//���������������������������������������Ŀ
//�Cria aHeader, aCols novo               �
//�����������������������������������������
Local nLenACols     := Len(aCols) //Obtem o tamanho do aCols
//���������������������������������������Ŀ
//�Variaveis gerais                       �
//�����������������������������������������
Local nLenConteudo  := 0
Local nPos          := 0
Local cFiltro       := ""
Local aAltera       := AClone(xAltera)
Local cCombo        := ""
Local aCombo        := AClone(xCombo)
//���������������������������������������Ŀ
//�Variaveis do Dialogo                   �
//�����������������������������������������                     
Local oDlg, oGetd    
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize(.T.)
Local nOpcA     := 0    

Default cCategoria := ""

N := 1

MFA->( DbSetOrder(1) ) //MFA_FILIAL+MFA_ECFILT+MFA_ECITEM

MFB->( DbSetOrder(1) ) //MFB_FILIAL+MFB_ECCATE+MFB_ECFILT

MFC->( DbSetOrder(1) ) //MFC_FILIAL+MFC_ECCATE+MFC_ECPROD+MFC_ECFILT+MFC_ECCONT

Begin Sequence            

    If  Empty(cCategoria)
        Help( " ", 1, "FT150ECFiltro", , STR0025, 1 )   //"C�odigo da Categoria em branco!"
        Break
    EndIf    

    If  !( Empty(Posicione("ACU",1,xFilial("ACU")+cCategoria,"ACU_CODPAI")) )
        Help( " ", 1, "FT150ECFiltro", , STR0026, 1 )   //"Deve ser a Categoria Pai para amarrar com o Filtro!"
        Break
    EndIf
                              
    If  lECommerce .AND. ACU->(FieldPos("ACU_ECFLAG") <= 0)
        Help( " ", 1, "FT150ECFiltro", , STR0027, 1 )   //"Campo Status e-Commerce n�o configurado na tabela de Categoria!"
        Break
    EndIf
                              
    If  Empty(ACU->ACU_ECFLAG)
        Help( " ", 1, "FT150ECFiltro", , STR0028, 1 )   //"A Categoria deve ser Categoria e-Commerce para utilizar a Amarra��o do Filtro!"
        Break
    EndIf
                              
	//�������������������������������������������������Ŀ
	//�Ira configurar xHeader e xCols na primeira vez.  �
	//���������������������������������������������������                     
	If  Empty(xHeader)
		//���������������������������������������Ŀ
		//�Monta xHeader, xCols                   �
		//�����������������������������������������                     
		Aadd(xHeader,	{STR0030  /*Titulo*/,"PRODUTO"  /*Campo*/," "/*Picture*/,TamSX3("ACV_CODPRO")[1]/*Tamanho*/,00/*Decimal*/,/*Valid*/,/*Usado*/,"C"/*Tipo*/,/*F3*/,"V"/*Context*/,/*CBOX*/,/*Relacao*/ } )  //"Produto"
		Aadd(xHeader,	{STR0031  /*Titulo*/,"DESCRICAO"/*Campo*/," "/*Picture*/,TamSX3("B1_DESC")[1]   /*Tamanho*/,00/*Decimal*/,/*Valid*/,/*Usado*/,"C"/*Tipo*/,/*F3*/,"V"/*Context*/,/*CBOX*/,/*Relacao*/ } )  //"Descri��o"
	
		//���������������������������������������Ŀ
		//�Obtem os filtros para o xHeader        �
		//�����������������������������������������                     
		MFB->( DbSeek(xFilial("MFB")+cCategoria) )
	
		Do  While !( MFB->(Eof()) ) .And. (MFB->MFB_FILIAL+Alltrim(MFB->MFB_ECCATE) == xFilial("MFB")+Alltrim(cCategoria))
		    cFiltro := StrTran(Alltrim(Posicione("MF9",1,xFilial("MF9")+MFB->MFB_ECFILT,"MF9_ECNOME"))," ", "_")
		    
			//��������������������������������������������Ŀ
			//�Obtem os Conteudos do Filtro como ComboBox  �
			//����������������������������������������������                     
			MFA->( DbSeek(xFilial("MFA")+MFB->MFB_ECFILT) )
			
		    cCombo       := ""
		    nLenConteudo := 0

			Do  While !( MFA->(Eof()) ) .And. (MFA->MFA_FILIAL+MFA->MFA_ECFILT == xFilial("MFA")+MFB->MFB_ECFILT)
			
				If  !( Empty(cCombo) )
			    	cCombo += ";"
			    EndIf
			    	
			    cCombo += Alltrim(MFA->MFA_ECDESC)
			    
			    If  (Len(Alltrim(Alltrim(MFA->MFA_ECDESC))) > nLenConteudo)
			    	nLenConteudo := Len(Alltrim(Alltrim(MFA->MFA_ECDESC)))
			    EndIf
			    
				MFA->( DbSkip() )
		    EndDo
		    
		    aadd(aAltera, cFiltro)
		    
		    aadd(xHeader,  {cFiltro/*Titulo*/,cFiltro/*Campo*/,""/*Picture*/,nLenConteudo/*Tamanho*/,00/*Decimal*/,/*Valid*/,/*Usado*/,"C"/*Tipo*/,/*F3*/,"V"/*Context*/,cCombo/*CBOX*/,/*Relacao*/ } )
	
	        aadd(aFiltros, {MFB->MFB_ECFILT, cFiltro})
	        
	        aadd(aCombo, cCombo)
	        
			MFB->( DbSkip() )
		EndDo
	
	    //Coluna final vazia
	    aadd(xHeader,  {""/*Titulo*/,"X"/*Campo*/,""/*Picture*/,2/*Tamanho*/,00/*Decimal*/,/*Valid*/,/*Usado*/,"C"/*Tipo*/,/*F3*/,"V"/*Context*/,/*CBOX*/,/*Relacao*/ } )
		
		//���������������������������������������Ŀ
		//�Prepara xCols                          �
		//�����������������������������������������                     
		For nA := 1 to nLenACols
	
			aadd(xCols, Array(Len(xHeader)+1))
		   	ATail(ATail(xCols)) := .F.  //Mesmo que esteja excluido na Amarracao Categoria X Produto ira aparecer sem a exclusao aqui.
	
			xCols[nA][1] := GDFieldGet("ACV_CODPRO",nA)
			xCols[nA][2] := GDFieldGet("ACV_DESPRO",nA)
			
			For nB := 3 to Len(xHeader)
				xCols[nA][nB] := Space(xHeader[nB][4])
			Next nB
			
			//��������������������������������������������Ŀ
			//�Obtem a Amarracao ja gravada                �
			//����������������������������������������������                     
			MFC->( DbSeek(xFilial("MFC")+PadR(cCategoria,Len(MFC->MFC_ECCATE))+PadR(xCols[nA][1],Len(MFC->MFC_ECPROD))) )
			
			Do  While !( MFC->(Eof()) ) .And. (MFC->MFC_FILIAL+MFC->MFC_ECCATE+MFC->MFC_ECPROD == xFilial("MFC")+PadR(cCategoria,Len(MFC->MFC_ECCATE))+PadR(xCols[nA][1],Len(MFC->MFC_ECPROD)))
			    nPos := Ascan(aFiltros, {|x| x[1] == MFC->MFC_ECFILT })  //Verifica a posicao do filtro no aCols
			    
			    If  (nPos > 0)
			    	xCols[nA][nPos+2] := Posicione("MFA",1, xFilial("MFA")+MFC->MFC_ECFILT+MFC->MFC_ECCONT,"MFA_ECDESC")   //Passa a descricao do conteudo ja gravado para o aCols
			    EndIf
			     
				MFC->( DbSkip() )
			EndDo
			
	    Next nA
	    
		//����������������������������������������������Ŀ
		//�Copia do xCols para comparar na gravacao.     �
		//������������������������������������������������
	    xCopia := AClone(xCols)
	    
    EndIf

	//����������������������������������������������Ŀ
	//�Substitui aHeader, aCols por xHeader e xCols  �
	//������������������������������������������������
	aHeader := AClone(xHeader)
	aCols   := AClone(xCols)
	//������������������������������������������������������Ŀ
	//� Ativa a Dialog.                                      �
	//��������������������������������������������������������
	aAdd( aObjects, { 100, 100, .T., .T. })
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

		oGetd := MsGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],4,/*"LinOK"*/, /*"TudOk"*/,,.F.,aAltera,2/*ColunasFreeze*/,, 99999,,,,,,.T./*UsaFreeze*/ )
		
		For nA := 1 to Len(aCombo)
			oGetd:aInfo[nA+2][2] := aCombo[nA]
		Next nA
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetD:TudoOk(),(Help(" ",1,"MA412CanPV",,STR0029,1),nOpcA:= 1,oDlg:End()),.T.)},{||oDlg:End()} )  //"Para gravar as altera��es desta tela precisa confirmar a grava��o na tela de Amarra��o Categoria X Produto!"

End Sequence

If  (nOpcA == 1)
	//������������������������������������������������Ŀ
	//�Restaura xCols com os dados alterados em tela.  �
	//��������������������������������������������������
	xCols := AClone(aCols)
EndIf

//�����������������������������������������Ŀ
//�Restaura xAltera, xCombo                 �
//�������������������������������������������
xAltera := AClone(aAltera)
xCombo  := AClone(aCombo)
	
//���������������������������������������Ŀ
//�Restaura aHeader, aCols e N            �
//�����������������������������������������
aHeader := AClone(zHeader)
aCols   := AClone(zCols)
N       := nN

RestArea(aAreaACU)
RestArea(aArea)

Return .T.            

//-------------------------------------------------------------------
/*/{Protheus.doc} Ft150ECGrv
Gravacao da Amarracao do Filtro do e-Commerce.
@sample   Ft150ECGrv(aHeader, aCols, xHeader, xCols, xCopia, xFiltros, cCategoria)
@param    aHeader    - aHeader da Amarracao Categoria X Produto
@param    aCols      - aCols contendo os dados da amarracao. 
@param    xHeader    - aHeader da Amarracao Filtro e-Commerce 
@param    xCols      - aCols da Amarracao Filtro e-Commerce 
@param    xCopia     - Copia do aCols contendo os dados da amarracao antes de serem alterados pelo usuario para comparar na gravacao. 
@param    xAltera    - Campos que podem ser alterados pelo usuario. 
@param    aFiltros   - matriz com o codigo e descricao de cada filtro, pois no dialogo sera apresentada somente a descricao.
@param    cCategoria - codigo da categoria que esta sendo amarrada aos filtros.
@return   lRet (Boolean) - sempre verdadeiro.

@author   Antonio C Ferreira
@since    23/04/2013
@version  P11.5
/*/
//-------------------------------------------------------------------

Static Function Ft150ECGrv(aHeader, aCols, xHeader, xCols, xCopia, xFiltros, cCategoria)

Local aArea     := GetArea()

Local nA
Local nB
Local nPos
Local nLenXCols := Len(xCols)        
Local nLenLinha := Len(xHeader)
Local cFiltro   := ""
Local cConteudo := ""        

MFC->( DbSetOrder(1) )  //MFC_FILIAL+MFC_ECCATE+MFC_ECPROD+MFC_ECFILT+MFC_ECCONT

For nA := 1 to nLenXCols

    //Se a linha do aCols da Amarracao Categoria X Produto estiver excluida, excluira tambem toda Amarracao Filtro e-Commerce da linha.
	If  GDDeleted(nA, aHeader, aCols) 
	
	    For nB := 3 to nLenLinha
	        If  !( Empty(xCopia[nA][nB]) )  //Na exclusao ira verificar pela copia do xCols pois nao interessa as alteracoes em tela.
	        	nPos      := Ascan(xFiltros, {|x| x[2] == xHeader[nB][2]})
	        	cFiltro   := xFiltros[nPos][1]
	        	cConteudo := Posicione("MFA",2,xFilial("MFA")+cFiltro+xCopia[nA][nB],"MFA_ECITEM")  //Obtem o codigo do Conteudo do Filtro
	        	//Se existe o registro devera ser excluido
	    		If  MFC->( DbSeek(xFilial("MFC")+PadR(cCategoria,Len(MFC->MFC_ECCATE))+PadR(xCopia[nA][1],Len(MFC->MFC_ECPROD))+cFiltro+cConteudo) )
	    			RecLock("MFC",.F.)
	    			MFC->MFC_ECDTEX := Space(8) //Limpa o campo para exportacao do e-Commerce
	    			MFC->( DbDelete() )
	    			MFC->( MsUnLock() )
	    		EndIf
	    	EndIf		
	    Next nB
	
	Else

	    For nB := 3 to nLenLinha
	        If  (xCopia[nA][nB] <> xCols[nA][nB])
	        	nPos      := Ascan(xFiltros, {|x| x[2] == xHeader[nB][2]})
	        	cFiltro   := xFiltros[nPos][1]
	        	
	        	If  !( Empty(xCopia[nA][nB]) )
		        	cConteudo := Posicione("MFA",2,xFilial("MFA")+cFiltro+xCopia[nA][nB],"MFA_ECITEM")  //Obtem o codigo do Conteudo do Filtro pelo xCopia 
		        	//Se existe o registro devera ser excluido
		    		If  MFC->( DbSeek(xFilial("MFC")+PadR(cCategoria,Len(MFC->MFC_ECCATE))+PadR(xCopia[nA][1],Len(MFC->MFC_ECPROD))+cFiltro+cConteudo) )
		    			RecLock("MFC",.F.)
		    			MFC->MFC_ECDTEX := Space(8) //Limpa o campo para exportacao do e-Commerce
		    			MFC->( DbDelete() )
		    			MFC->( MsUnLock() )
		    		EndIf
	    		EndIf                                                       
	    		
	    		//Inclui o valor novo caso esteja preenchido
	        	If  !( Empty(xCols[nA][nB]) )
	        		cConteudo := Posicione("MFA",2,xFilial("MFA")+cFiltro+xCols[nA][nB],"MFA_ECITEM")  //Obtem o codigo do Conteudo do Filtro pelo xCols
	        		RecLock("MFC",.T.)
	        		MFC->MFC_FILIAL := xFilial("MFC")
	        		MFC->MFC_ECCATE := cCategoria
	        		MFC->MFC_ECPROD := xCols[nA][1]
	        		MFC->MFC_ECFILT := cFiltro
	        		MFC->MFC_ECCONT := cConteudo
	        		MFC->MFC_ECFLAG := 'A'
	    			MFC->( MsUnLock() )
	        	EndIf	
	    	EndIf		
	    Next nB
	
	EndIf

Next nA

RestArea(aArea)

Return .T.            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |Ft150Col    �Autor �Jo�o Paulo           � Data � 15/02/11  ���
�������������������������������������������������������������������������͹��
���Descricao � Cria objeto				 						 		  ���
�������������������������������������������������������������������������͹��
���Parametros� oGetDados - Objeto Getdados  				              ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Amarracao Categoria x Grupos de Produtos    	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Ft150Col( oGetDados ) 

Default oGetDados := Nil

//���������������������������������������Ŀ
//�Cria no Acols os Campos para os objetos�
//�����������������������������������������
aCols[N][1] := "TRIUP"
aCols[N][2] := "TRIDOWN"

oGetDados:Refresh()

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |Ft150GD     �Autor �Jo�o Paulo           � Data � 15/02/11  ���
�������������������������������������������������������������������������͹��
���Descricao � Monta tabela Getdados com campos de ordem			 	  ���
�������������������������������������������������������������������������͹��
���Parametros� cField - valor de campo  						          ���
�������������������������������������������������������������������������͹��
���Retorno   � cRet  						  						      ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Amarracao Categoria x Grupos de Produtos    	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft150GD(cField)
Local cRet 		:= ""				// Retorno do CriaVar
Local nPos 		:= 0				// Variavel utilizada em Loop, armazena a posi��o do campo no aHeader

Default cField 	:= "" 

If cField <> "UP" .And. cField <> "DOWN" .AND. cField <> "ORDEM"
	For nPos:=1 To Len(aHeader)-2
		If AllTrim(aHeader[nPos][2]) == AllTrim(cField)
			Exit
		EndIf
	Next nPos
	If ( aHeader[nPos][10] <>  "V" )
		cRet := FieldGet(FieldPos(aHeader[nPos][2]))
	Else
		cRet := CriaVar(aHeader[nPos][2],.T.)
	Endif
Else
	If cField == "UP"
		cRet := "TRIUP"
	ElseIf cField == "DOWN"
		cRet := "TRIDOWN"
	ElseIf cField == "ORDEM"
		cRet :=  len(aCols)
	EndIf
EndIf
                           
Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � Ft150Swp   �Autor �Jo�o Paulo           � Data � 16/02/11  ���
�������������������������������������������������������������������������͹��
���Descricao � Faz swap nas linhas do acols  					 		  ���
�������������������������������������������������������������������������͹��
���Parametros� nCol - n�mero da coluna (dblclick)			              ���
���			 � bBlock - bloco de comando para retorno					  ���
�������������������������������������������������������������������������͹��
���Retorno   � uRet												    	  ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Amarracao Categoria x Grupos de Produtos    	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Ft150Swp(nCol, bBlock )
Local uRet 			:= Nil                     // Vari�vel de Retorno
Local cRecno		:= ""                      // Guarda posi��o do Recno

Default nCol 		:= 0
Default bBlock		:= Nil

If nCol == 1
	If n > 1
		aAux 			:= aCols[n-1]
		cRecno			:= aAux[12]
		aCols[n-1] 		:= aCols[n]
		aCols[n]		:= aAux
		aCols[n][3]		:= aCols[n-1][3]
		aCols[n-1][3]	:= n-1    
	Else
		MsgAlert(STR0011)             	//"N�o � poss�vel mover esse item para cima!"
	EndIf
ElseIf nCol == 2
	If n < len(aCols)
		aAux 			:= aCols [n+1]
		cRecno			:= aAux[12]
		aCols[n+1]		:= aCols[n]
		aCols[n]		:= aAux
		aCols[n][3]		:= aCols[n+1][3]
		aCols[n+1][3]	:= n+1
	Else                           
		MsgAlert(STR0012)				//"N�o � poss�vel mover esse item para baixo!"
	EndIf
EndIf
Eval(bRefresh)

Return uRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |Ft150Rec    �Autor �Fernando Amorim      � Data � 28/02/07  ���
�������������������������������������������������������������������������͹��
���Descricao �Trata as linhas do acols  						 		  ���
�������������������������������������������������������������������������͹��
���Parametros�												              ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Amarracao Categoria x Grupos de Produtos    	  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��� Fernando   �15/03/07�121315�corre��o no tratamento do Recno 	      ���
���            �        �      �caso  seja inclus�o		                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Ft150Rec(aRecNo,cQuery,nOpc)
       
If nOpc<>3
	If cQuery == NIL .Or. ACV->(FieldPos("R_E_C_N_O_")) == 0
		aadd(aRecNo,ACV->(RecNo()))
	Else
		aadd(aRecNo,ACV->R_E_C_N_O_) 
	EndIf
EndIf
    

 
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150Grv   � Autor � Eduardo Riera        � Data �06.09.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao no Cadastro de Amarracao Categoria x Grupo      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150Grv( nOpcao, cFt150Cat )                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 : Opcao de gravacao                                  ���
���          �         [1] Inclusao                                       ���
���          �         [2] Alteracao                                      ���
���          �         [3] Exclusao                                       ���
���          � ExpA2:  Array com campos da Enchoice                       ���
���          � ExpA3:  Array com o codigo dos registros                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Efetuou a gravacao                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ft150Grv( nOpcao, aVisual , aRegACV)

Local nX       	:= 0 					//Utilizada no contador do For
Local nY       	:= 0					//Utilizada no contador do For
Local lTravou  	:= .F. 	
Local lGravou  	:= .F.
Local nUsado   	:= Len(aHeader)
Local lPergun  	:= .F.       			// variavel logica de controle de pergunta
//��������������������������������Ŀ
//�Tratamento para e-Commerce      �
//����������������������������������
Local lECommerce := SuperGetMV("MV_LJECOMM",,.F.) 
Local lCatPai    := .F.   //Se for categoria pai n�o permitira a exclusao se tiver categoria filho. Caso contrario ira limpar o campo ACV_ECDTEX para exportacao.
Local cProduto   := ""    //Obtem o produto para comparacao entre as categorias pai e filho
Local cCategoria := ""    //Obtem a categoria para posicionar na filho.
Local aArea      := {}    //Salva a area geral
Local aAreaACV   := {}    //Salva a area da ACV.

//Limpa variavel para exportacao de dados do ecomerce.		
If  (ACV->(FieldPos("ACV_ECDTEX")) > 0)
	M->ACV_ECDTEX := ""
EndIf	

//����������������������������������Ŀ
//�nOpcao == 4 (Ordenar)             �
//�Op��o s� existe para Release 11.5 �
//������������������������������������

Do Case
	Case nOpcao == 4
		For nX := 1 To Len(aRegACV)
			ACV->(MsGoto(aRegACV[nX]))
			RecLock("ACV",.F.)
			ACV->(dbDelete())
			lGravou := .T.
		Next nX
		For nX := 1 To Len(aRegACV)
			RecLock("ACV",.T.)
			If !aCols[nX][nUsado+1]
				For nY:= 1 To nUsado
					If aHeader[nY][10]<>"V"
						FieldPut(FieldPos(aHeader[nY][2] ), aCols[nX][nY] )
					EndIf
				Next
				REPLACE ACV_SEQPRD	WITH Str(aCols[nX][3],2,0)
				REPLACE ACV_FILIAL	WITH xFilial("ACV")
				REPLACE ACV_CATEGO	WITH M->ACV_CATEGO
				lGravou := .T.
			EndIf
		Next nX			
	Case nOpcao <> 3
		For nX := 1 To Len(aCols)
			If nX <= Len(aRegACV)
				ACV->(MsGoto(aRegACV[nX]))
				RecLock("ACV",.F.)
				lTravou := .T.
			Else
				If !aCols[nX][nUsado+1]
					RecLock("ACV",.T.)
					lTravou := .T.					
				Else
					lTravou := .F.
				EndIf
			EndIf
			If !aCols[nX][nUsado+1]
				For nY:= 1 To nUsado
					If aHeader[nY][10]<>"V"
						FieldPut(FieldPos(aHeader[nY][2] ), aCols[nX][nY] )
					EndIf
				Next     
				REPLACE ACV_FILIAL	WITH xFilial("ACV")
				ACV_FILIAL:= xFilial("ACV")
				ACV->(aEval(aVisual,{|cCampo| Iif(FieldPos(cCampo) > 0,;
															&(cCampo) := &("M->"+AllTrim(cCampo)),;
															Nil ) } ))
				lGravou := .T.
				If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 )  .AND.  nOpcao ==2 
				    If  !lPergun
						lPai:=	Ft150VSug(ACV->ACV_CATEGO,Len(aCols))
						lPergun :=.T.
					EndIf 	
				EndIf   
			Else
				If lTravou
					If  lECommerce .And. ACU->( FieldPos("ACU_ECFLAG") > 0 )
					 //������������������������������������������������������������������������������������Ŀ
					 //�Nao pode excluir o produto da categoria pai se tiver cadastrado na categoria filho  �
					 //��������������������������������������������������������������������������������������
					    aArea    := GetArea()
					    aAreaACV := ACV->( GetArea() )
			
		    		    ACV->( DbSetOrder(5) ) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
						ACU->( DbSetOrder(2) ) //ACU_FILIAL+ACU_CODPAI
			
				        cProduto   := ACV->ACV_CODPROD
				        cCategoria := ACV->ACV_CATEGO
				                                    
						lCatPai := .F.
						ACU->( DbSeek(xFilial("ACU")+cCategoria) )
						
						Do  While ACU->( !Eof() .And. (ACU_FILIAL+ACU_CODPAI == xFilial("ACU")+cCategoria) )
						
							If  !( Empty(ACU->ACU_ECFLAG) ) .And. ACV->( DbSeek(xFilial("ACV")+cProduto+ACU->ACU_COD) )
								Help( " ", 1, "FT150ECGrava", , STR0021 + ACU->ACU_COD, 1 )   //"N�o pode excluir produto da categoria pai sem antes excluir da categoria filho! Categoria: "
								lCatPai := .T.
								Exit
							EndIf
							
							ACU->( DbSkip() )
						EndDo
						
						RestArea(aAreaACV)
						RestArea(aArea)
						            
						If  !( lCatPai )
							ACV->ACV_ECDTEX := ""
						EndIf	
					EndIf
                        
                    If  !( lCatPai )
						ACV->(dbDelete())
						lGravou := .T.
					EndIf	
				EndIf
			EndIf		
	    Next nX
	Case nOpcao == 3
		
		If  lECommerce .And. ACU->( FieldPos("ACU_ECFLAG") > 0 )
		 //������������������������������������������������������������������������������������Ŀ
		 //�Nao pode excluir o produto da categoria pai se tiver cadastrado na categoria filho  �
		 //��������������������������������������������������������������������������������������
		    aArea    := GetArea()
		    aAreaACV := ACV->( GetArea() )
		    ACV->( DbSetOrder(5) ) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
			ACU->( DbSetOrder(2) ) //ACU_FILIAL+ACU_CODPAI
			For nX := 1 To Len(aRegACV)         
			
				ACV->(MsGoto(aRegACV[nX]))
				
		        cProduto   := ACV->ACV_CODPROD
		        cCategoria := ACV->ACV_CATEGO
		                                    
				lCatPai := .F.
				ACU->( DbSeek(xFilial("ACU")+cCategoria) )
				
				Do  While ACU->( !Eof() .And. (ACU_FILIAL+ACU_CODPAI == xFilial("ACU")+cCategoria) )
				
					If  !( Empty(ACU->ACU_ECFLAG) ) .And. ACV->( DbSeek(xFilial("ACV")+cProduto+ACU->ACU_COD) )
						Help( " ", 1, "FT150ECExcluir", , STR0021 + ACU->ACU_COD, 1 )   //"N�o pode excluir produto da categoria pai sem antes excluir da categoria filho! Categoria: "
						lCatPai := .T.
						Exit
					EndIf
					
					ACU->( DbSkip() )
				EndDo
			Next nX
			
			RestArea(aAreaACV)
			RestArea(aArea)
		EndIf
		                    
		If  !( lECommerce ) .Or. !( lCatPai )
			For nX := 1 To Len(aRegACV)
				ACV->( MsGoto(aRegACV[nX]) )
				ACV->( RecLock("ACV",.F.) )
				If  ACV->( (FieldPos("ACV_ECDTEX") > 0) )
					ACV->ACV_ECDTEX := ""
				EndIf
				ACV->(dbDelete())			
				lGravou := .T.
			Next nX
		EndIf	
EndCase

Return(lGravou)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150LinOk � Autor � Eduardo Riera        � Data �06.09.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Linha Ok                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150LinOk ( oGetD )                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 : Objeto da GetDados                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Linha Valida                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150LinOk(oGetD)

Local lResult	:= .T.
Local nX		:= 0
Local nUsado    := Len(aHeader)
Local nPCateg   := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_CATEGO'})
Local nPGrupo   := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_GRUPO'})
Local nPProduto := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_CODPRO'})
Local nPProdRef := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_REFGRD'})
Local nPSeqPrd  := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_SEQPRD'})
Local nPDtExp	:= aScan(aHeader, {|x|AllTrim(x[2])=='ACV_ECDTEX'})
Local cCateg    := ""
Local cGrupo    := ""
Local cProdRef  := " "
Local cProduto  := ""
Local cUltSeq   := "" 			// Ultima Sequencia do acols referente o campo ACV_SEQPRD  
Local AcolsBkp	:= {}           // Variavel de backup do aClos
//��������������������������������Ŀ
//�Tratamento para e-Commerce      �
//����������������������������������
Local lECommerce    := SuperGetMV("MV_LJECOMM",,.F.)
Local lECCia		:= SuperGetMV("MV_LJECOMO",,.F.)
Local cCatSuperior  := ""   //Obtem a categoria pai
Local cNomeSuperior := ""   //Obtem a descricao da categoria pai
Local aAreaACV      := NIL

If nPCateg > 0
	cCateg   := aCols[n][nPCateg]
EndIf
If nPGrupo > 0
	cGrupo   := aCols[n][nPGrupo]
EndIf
If nPProduto > 0
	cProduto := aCols[n][nPProduto]
EndIf
If nPProdRef > 0
	cProdRef := aCols[n][nPProdRef]
Endif

AcolsBkp := Aclone(aCols)
If nPSeqPrd > 0 
	If Len(aCols) < 100
		If Inclui 
			If Empty(aCols[n][nPSeqPrd])
				aCols[n][nPSeqPrd]:= Str(n,2,0)
			EndIf
		Else
			//�����������������������������������������������������������������������������������Ŀ
			//�Na altera��o pego a ultima sequencia gerada para continuar gerando novas sequ�ncias�
			//�������������������������������������������������������������������������������������
			If Empty(aCols[n][nPSeqPrd])
				aSort(aCols,,,{|x,y|x[nPSeqPrd] <= y[nPSeqPrd]}) 	
				cUltSeq := aCols[Len(aCols)][nPSeqPrd]
				Acols:= aClone(AcolsBkp)
				aCols[n][nPSeqPrd]:= Str(Val(cUltSeq)+1,2,0)
			EndIf
		EndIf		
	Else 
		//�����������������������������������������������������������������������������������Ŀ
		//�Pego a ultima sequencia gerada para continuar gerando novas sequ�ncias.  		  �
		//�Se possuir mais de 99 registros utilizo fun��o Soma1 pois o campo � caracter de    �
		//� 2 posi�oes, e n�o cabe mais de 99 registros apartir de 99 gerava como **          � 
		//�������������������������������������������������������������������������������������
	    If Inclui .And. Type("lCopia") == "L" .And. !lCopia
			aCols[n][nPSeqPrd]:= Soma1(aCols[n-1][nPSeqPrd])	
		Else
			If Empty(aCols[n][nPSeqPrd])
				aSort(aCols,,,{|x,y|x[nPSeqPrd] <= y[nPSeqPrd]}) 	
				cUltSeq := aCols[Len(aCols)][nPSeqPrd]
				Acols:= aClone(AcolsBkp)
				aCols[n][nPSeqPrd]:= Soma1(cUltSeq) 
			EndIf
		EndIf	
	EndIf	
Endif

If Empty( cCateg + cGrupo + cProduto + cProdRef ) .And. !aCols[n][nUsado+1]
	Help(' ', 1, 'OBRIGAT')
	lResult := .F.
Else
	If lResult .And. !aCols[N][nUsado + 1]

		For nX := 1 To Len( aCols )

			If ( nX != n .And. !aCols[nX][nUsado + 1] )

				If !Empty(cCateg) 
					If nPCateg > 0
						If aCols[nX][nPCateg] == cCateg
							Help(' ', 1, 'JAGRAVADO')
							lResult := .F.
							Exit
						EndIf
					EndIf

				ElseIf !Empty(cGrupo) 
					If nPGrupo > 0
						If aCols[nX][nPGrupo] == cGrupo
							Help(' ', 1, 'JAGRAVADO')
							lResult := .F.
							Exit
						EndIf
					EndIf

				ElseIf !Empty(cProduto)
					If nPProduto > 0
						If aCols[nX][nPProduto] == cProduto
							Help(' ', 1, 'JAGRAVADO')
							lResult := .F.
							Exit
						EndIf				
					EndIf

				ElseIf !Empty(cProdRef) 
					If nPProdRef>0
						If aCols[nX][nPProdRef] == cProdRef
							Help(' ', 1, 'JAGRAVADO')
							lResult := .F.
							Exit
						EndIf
					EndIf
				EndIf

			EndIf

		Next nX

	 //��������������������������������������������������������������������������Ŀ
	 //�Para e-commerce somente permitira cadastrar na categoria filho se estiver �
	 //�cadastrado na categoria pai.                                              �
	 //����������������������������������������������������������������������������
		If  lResult .And. lECommerce .And. !( Empty(Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_ECFLAG")) )
		    cCatSuperior  := Posicione("ACU",1,xFilial("ACU")+M->ACV_CATEGO,"ACU_CODPAI")
		    
		    If  ACU->( FieldPos("ACU_ECFLAG") > 0 ) .And. !( Empty(ACU->ACU_ECFLAG) ) .And. !( Empty(cCatSuperior) ) .AND. !lECCia
		    	aAreaACV := ACV->( GetArea("ACV") )
		    	
		    	If  Empty(Posicione("ACV",5,xFilial("ACV")+PadR(cProduto,Len(ACV->ACV_CODPRO))+cCatSuperior,"ACV_CATEGO"))
   				    cNomeSuperior := Posicione("ACU",1,xFilial("ACU")+cCatSuperior,"ACU_DESC")
		    	    Help( " ", 1, "FT150ECFiltro", , STR0022 + cCatSuperior + "-" + Alltrim(cNomeSuperior) + STR0023, 1 )   //"Este produto deve ser cadastrado na categoria pai: "##" antes de cadastrar nesta categoria para e-commerce!"
		    	    lResult := .F.
		    	EndIf
		    	
		    	RestArea(aAreaACV)
		    EndIf
		EndIf
		
	ElseIf lResult .And. lECommerce .And. aCols[N][nUsado + 1]
		If nPDtExp > 0 .And. !Empty(aCols[N][nPDtExp])
			aCols[N][nPDtExp] := ""
		EndIf
		
	EndIf
EndIf
Return ( lResult )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150TudOk � Autor � Eduardo Riera        � Data �06.09.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Linha Ok                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150TudOk ( oGetD )                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 : Objeto da GetDados                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Linha Valida                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150TudOk(oGetD)
Local lRet := .T.

If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 ) .AND. lCat 
	lRet := .T.
Else
	Pergunte("FATA150",.F.)
	
	Do Case
	
		Case mv_par01 == 1 //-- Por Categoria
			
			If !( lRet := !Empty(M->ACV_CATEGO) )
				Help(' ', 1, 'OBRIGAT')
			EndIf
			
		Case mv_par01 == 2 //-- Por Produto
			
			If !( lRet := !Empty(M->ACV_CODPRO) )
				Help(' ', 1, 'OBRIGAT')
			EndIf
			
		Case mv_par01 == 3 //-- Por Grupo
			
			If !( lRet := !Empty(M->ACV_GRUPO) )
				Help(' ', 1, 'OBRIGAT')
			EndIf
			
		Case mv_par01 == 4 //-- Por Grade
			
			If !( lRet := !Empty(M->ACV_REFGRD) )
				Help(' ', 1, 'OBRIGAT')
			EndIf
			
	EndCase

EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150Vgrp  � Autor � Eduardo Riera        � Data �08.09.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do grupo de produto                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150VGrp ( void )                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Grupo valido                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150VGrp()

Local aArea		:= GetArea()
Local aAreaACU	:= ACU->(GetArea())
Local aAreaACV	:= ACV->(GetArea())
Local lRetorno	:= .T.
Local cGrupo  	:= &(ReadVar())
Local lCpBloq	:= (ACU->(FieldPos("ACU_MSBLQL")) > 0)

Local lMvLjCatGP:= SuperGetMv("MV_LJCATGP",.F.,.F.)


//�����������������������������������������������������������������������Ŀ
//� Verifica se existe o grupo em outra categoria                         �
//�������������������������������������������������������������������������
dbSelectArea("ACU")
dbSetOrder(1) //ACU_FILIAL+ACU_COD

dbSelectArea("ACV")
dbSetOrder(2)

MsSeek(xFilial("ACV")+cGrupo)

While lRetorno .AND. !ACV->(Eof())		.AND.;
	ACV->ACV_FILIAL	== xFilial("ACV")	.AND.;
	ACV->ACV_GRUPO	== cGrupo

	If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 ) .AND. lCat
		If ACV->ACV_CATEGO <> M->ACV_CATEGO
			//��������������������������������������������Ŀ
			//�Verifica se a outra categoria esta bloqueada�
			//����������������������������������������������
			ACU->(DbSeek(xFilial("ACU")+ACV->ACV_CATEGO))
			If lCpBloq .AND. ACU->ACU_MSBLQL == '1'
				lRetorno := .T.
			Else
				lRetorno := .F.
			EndIf
		EndIf
	Else
		Pergunte("FATA150",.F.)
		If MV_PAR01 == 1 //-- Por Categoria
			If ACV->ACV_CATEGO <> M->ACV_CATEGO
				//��������������������������������������������Ŀ
				//�Verifica se a outra categoria esta bloqueada�
				//����������������������������������������������
				ACU->(DbSeek(xFilial("ACU")+ACV->ACV_CATEGO))
				If lCpBloq .AND. ACU->ACU_MSBLQL == '1'
					lRetorno := .T.
				Else
					lRetorno := lMvLjCatGP
				EndIf
			EndIf
		ElseIf MV_PAR01 == 3 .And. Inclui
   		lRetorno := .F.
		Else
	  		lRetorno := .F.
		EndIf	
   EndIf
   ACV->(DbSkip())
   
End

If !lRetorno
	Help(" ",1,"FT150VGRP")
EndIf

RestArea(aAreaACV)
RestArea(aAreaACU)
RestArea(aArea)

Return(lRetorno)

/*���������������������������������������������������������������������������
���Fun��o    �Ft150VPro  � Autor � Eduardo Riera        � Data �08.09.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do codigo de produto                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150VPro ( void )                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Produto valido                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
���������������������������������������������������������������������������*/
Function Ft150VPro()
Local aArea		:= GetArea()
Local aAreaACU	:= ACU->(GetArea())
Local aAreaSB5 	:= SB5->(GetArea())
Local lRetorno 	:= .T.
Local cProduto 	:= &(ReadVar())
Local cGrupo   	:= Space(Len(ACV->ACV_GRUPO))
Local lCpBloq	:= (ACU->(FieldPos("ACU_MSBLQL")) > 0)
Local lB5ECFLAG	:= SB5->(FieldPos("B5_ECFLAG")) > 0
Local lMvLjCatPr:= SuperGetMv("MV_LJCATPR",.F.,.F.)
Local cGetCodPro:= PadR(Alltrim(GdFieldGet("ACV_CODPRO")), Len(ACV_CODPRO))
Local cPosiSB5	:= ""
Local cPosiACV	:= ""
Local cPosiACU	:= ""
//----------------------------------
//|Tratamento para e-Commerce      |
//----------------------------------
Local lECommerce    := SuperGetMV("MV_LJECOMM",,.F.) 
Local lECCia		:= lECommerce .And. SuperGetMV("MV_LJECOMO",,.F.)

If  lECommerce
	cPosiACV := Posicione("ACV",5,xFilial("ACV")+cGetCodPro+M->ACV_CATEGO,"ACV_CODPRO")

	If lB5ECFLAG 
		cPosiSB5 := Posicione("SB5",1,xFilial("SB5")+cGetCodPro,"B5_ECFLAG")
		LjGrvLog("FATA150","Cod. Prod. [" + AllTrim(cGetCodPro) + "] foi procurado na tabela SB5, se o campo B5_ECFLAG N�O estiver " +;
							"preenchido, significa que o produto pode ser incluido ou alterado na grade." , cPosiSB5)
	EndIf

	If ACU->( FieldPos("ACU_ECFLAG") > 0 )
		cPosiACU := Posicione("ACU",1,xFilial("ACU")+M->ACV_CATEGO,"ACU_ECFLAG")
	EndIf

	If !Empty(AllTrim(cGetCodPro)) .And.;
		(Alltrim(cProduto) != AllTrim(cGetCodPro)) .And.;
		( cPosiACV == cGetCodPro ) .And.; //Verifica se ja esta gravado!
		!Empty(cPosiSB5) .And. !Empty(cPosiACU)
		
		Help( " ", 1, "FT150ValProd", , STR0024, 1 )   //"Para produto e-commerce n�o pode alterar o c�digo na amarrac�o da categoria, somente excluir!"	
		lRetorno := .F.
	EndIf
EndIf

If lRetorno .And. lECCia .And. !Empty(cProduto) .And.;
	lB5ECFLAG .And. !( Empty(Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_ECFLAG")))
	
	//Verifica se existem categorias-filhas cadastrada
	If !Empty(M->ACV_CATEGO) .And. !Empty(Posicione("ACU",2,xFilial("ACU")+M->ACV_CATEGO,"ACU_COD"))  //ACU_FILIAL+ACU_CODPAI 
		Help( " ", 1, "FT150ValProd", , STR0034, 1 )   //"Para produto e-commerce s� � poss�vel a amarra��o em categorias sem filhos abaixo"	
		lRetorno := .F.
	EndIf
EndIf

RestArea(aAreaSB5)
RestArea(aAreaACU)

//-----------------------------------------------------
//|Verifica se existe o grupo em outra categoria      |
//-----------------------------------------------------
ACU->(dbSetOrder(1)) //ACU_FILIAL+ACU_COD
ACV->(dbSetOrder(2)) //ACV_FILIAL+ACV_GRUPO+ACV_CODPRO+ACV_CATEGO

ACV->(MsSeek(xFilial("ACV")+cGrupo+cProduto))

While lRetorno .And. !ACV->(Eof())		.And.;
	ACV->ACV_FILIAL	== xFilial("ACV")	.And.;
	ACV->ACV_GRUPO	== cGrupo			.And.;
	ACV->ACV_CODPRO	== cProduto

	If ( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 ) .And. lCat 
		If ACV->ACV_CATEGO <> M->ACV_CATEGO
			//----------------------------------------------
			//|Verifica se a outra categoria esta bloqueada|
			//----------------------------------------------
			ACU->(DbSeek(xFilial("ACU")+ACV->ACV_CATEGO))
			If (lCpBloq .And. ACU->ACU_MSBLQL == '1') .OR. lECCia
				lRetorno := .T.
			Else
				lRetorno := lMvLjCatPr
			EndIf
		EndIf
	Else
		Pergunte("FATA150",.F.)
		If MV_PAR01 == 1 //-- Por Categoria
			If ACV->ACV_CATEGO <> M->ACV_CATEGO
				//----------------------------------------------
				//|Verifica se a outra categoria esta bloqueada|
				//----------------------------------------------
				ACU->(DbSeek(xFilial("ACU")+ACV->ACV_CATEGO))
				If (lCpBloq .AND. ACU->ACU_MSBLQL == '1') .OR. lECCia 
					lRetorno := .T.
				Else
					lRetorno := lMvLjCatPr
				EndIf
			EndIf
		ElseIf MV_PAR01 == 2 .And. Inclui
			lRetorno := .F.
		Else
			lRetorno := .F.
		EndIf	
	EndIf

    ACV->(DbSkip())
End

If !lRetorno
	Help(" ",1,"FT150VPRO")
EndIf

RestArea(aAreaACU)
RestArea(aArea)

Return lRetorno

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150Legenda� Autor � Daniel Leme         � Data � 19.02.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse ou retorna a ���
���          � para o BROWSE                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150Legenda(cAlias, nReg)

Local aLegenda := 	{}	
Local uRetorno := .T.

IF mv_par01 == 1
	Aadd(aLegenda,{"BR_VERDE", STR0016, ".T." })  // "Categoria com Amarra��o"
ElseIf mv_par01 == 2
	Aadd(aLegenda,{"BR_VERMELHO", STR0017 + " " + STR0018,"Empty(ACV->ACV_CODPRO)" }) // "Categoria sem Amarra��o" ## "por Produto"
    Aadd(aLegenda,{"BR_VERDE", STR0016 + " " + STR0018,"!Empty(ACV->ACV_CODPRO)" }) // "Categoria com Amarra��o" ## "por Produto"
ElseIf mv_par01 == 3
	Aadd(aLegenda,{"BR_VERMELHO", STR0017 + " " + STR0019,"Empty(ACV_GRUPO)" }) // "Categoria sem Amarra��o" ## "por Grupo"
    Aadd(aLegenda,{"BR_VERDE", STR0016 + " " + STR0019,"!Empty(ACV_GRUPO)" }) // "Categoria com Amarra��o" ## "por Grupo"
ElseIf mv_par01 == 4
	Aadd(aLegenda,{"BR_VERMELHO", STR0017 + " " + STR0020,"Empty(ACV_REFGRD)" }) // "Categoria sem Amarra��o" ## "por Grade"
	Aadd(aLegenda,{"BR_VERDE", STR0016 + " " + STR0020,"!Empty(ACV_REFGRD)" }) // "Categoria com Amarra��o" ## "por Grade"
EndIf        	
	         			
If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}                                          
	If mv_par01 == 1  
		Aadd(uRetorno, { ALEGENDA[1][3], aLegenda[1][1] } )
    Else
		Aadd(uRetorno, { ALEGENDA[2][3], aLegenda[2][1] } )
		Aadd(uRetorno, { ALEGENDA[1][3], aLegenda[1][1] } )
	EndIf	
Else
	BrwLegenda(cCadastro, STR0015, aLegenda) // "Legenda"
Endif

Return uRetorno

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
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
     
If( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 ) .AND. lCat 
	Private aRotina := {	{STR0002,"AxPesqui"	,0,1,0,.F.},; // "Pesquisar"
								{STR0003,"Ft150Manut",0,2,0,NIL},; // "Visualizar"
								{STR0004,"Ft150Manut",0,3,0,NIL},; // "Incluir"
								{STR0005,"Ft150Manut",0,4,0,NIL},; // "Alterar"
								{STR0006,"Ft150Manut",0,5,0,NIL},;	// "Excluir"
								{STR0013,"Ft150Manut",0,6,0,NIL},;	// "Ordenar"
								{STR0014,"Ft150Manut",0,8,0,NIL},; // "Copiar"
								{STR0009,"Ft150SugVe",0,7,0,NIL}}	// "Sug. Venda"
Else
	Private aRotina := {	{STR0002,"AxPesqui"	,0,1,0,.F.},; // "Pesquisar"
								{STR0003,"Ft150Manut",0,2,0,NIL},; // "Visualizar"
								{STR0004,"Ft150Manut",0,3,0,NIL},; // "Incluir"
								{STR0005,"Ft150Manut",0,4,0,NIL},; // "Alterar"
								{STR0006,"Ft150Manut",0,5,0,NIL},;	// "Excluir"
								{STR0014,"Ft150Manut",0,8,0,NIL},; // "Copiar"
								{STR0015,"Ft150Legenda",0,9,0,NIL}} // "Legenda"
EndIf


If ExistBlock("FT150MNU")
	ExecBlock("FT150MNU",.F.,.F.)
EndIf

Return(aRotina)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150VPrRf � Autor � Patricia Ducca       � Data �02.01.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do codigo de produto refer�ncia de grade         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150VPrRf ( void )                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Codigo  valido                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150VPrRf()

Local aArea		  := GetArea()
Local aAreaACU	  := ACU->(GetArea())
Local lRetorno 	  := .T.
Local cProdRef 	  := &(ReadVar())
Local nPGrupo  	  := 0
Local nPDescr  	  := 0
Local cGrupo   	  := ""
Local lGrade   	  := MaGrade()
Local lReferencia := .F.
Local lCpBloq	  := (ACU->(FieldPos("ACU_MSBLQL")) > 0)

Local lMvLjCatRG := SuperGetMv("MV_LJCATRG",.F.,.F.)

//�����������������������������������������������������������������������Ŀ
//� Verifica se produto eh referencia de grade                            �
//�������������������������������������������������������������������������

If lGrade // utiliza��o de grade ativa
	lReferencia:=MatGrdPrrf(@cProdRef)
	If !lReferencia //
		Help(" ",1,"REFGRADE")
		lRetorno:=.F.
	Else
		Pergunte("FATA150",.F.)
		
		If mv_par01 == 1 .Or. ( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 ) .AND. lCat 

			nPGrupo  	  := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_GRUPO'})
			nPDescr  	  := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_DESREF'})
			cGrupo   	  := aCols[n][nPGrupo]
			//�����������������������������������������������������������������������Ŀ
			//� Verifica se existe o grupo em outra categoria                         �
			//�������������������������������������������������������������������������
			dbSelectArea("ACV")
			dbSetOrder(4) //ACV_FILIAL+ACV_GRUPO+ACV_REFGRD+ACV_CATEGO
			
			MsSeek(xFilial("ACV")+cGrupo+cProdRef)
	
			Do While lRetorno .AND. !ACV->(Eof())		.AND.;
				ACV->ACV_FILIAL	== xFilial("ACV")	.AND.;
				ACV->ACV_GRUPO	   == cGrupo			.AND.;
				ACV->ACV_REFGRD	== cProdRef
				
				If ACV->ACV_CATEGO <> M->ACV_CATEGO
					//��������������������������������������������Ŀ
					//�Verifica se a outra categoria esta bloqueada�
					//����������������������������������������������
					ACU->(DbSeek(xFilial("ACU")+ACV->ACV_CATEGO))
					If lCpBloq .AND. ACU->ACU_MSBLQL == '1'
						lRetorno := .T.
					Else
						lRetorno := lMvLjCatRG
					EndIf
				EndIf
			
				ACV->(DbSkip())
				
			Enddo

			If lRetorno.and.nPDescr>0
				acols[n,nPDescr]:=DescPrRf(cProdRef)
			Endif

		Else
		
	 		lRetorno := lMvLjCatRG

	 	EndIf
			
		If !lRetorno
			Help(" ",1,"FT150VPRO")
		EndIf
		
	Endif
Else
	
	Help(" ",1,"NOGRADE")
	
Endif  

RestArea(aAreaACU)
RestArea(aArea)

Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DescPrRf  �Autor  �Patricia Ducca      � Data �  02/01/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DescPrRF(cProdRef)

Local cDescProd   := ""
Local cBase,cCodBS
Local nTam
Local lContinua	  := .T.
Local lReferencia := .F.

lReferencia:=MatGrdPrrf(@cProdRef)
//������������������������������������������������������������������������Ŀ
//�Checa a origem dos dados e alimenta as variaveis                        �
//��������������������������������������������������������������������������
If lReferencia
	Do Case
		//�������������������������������
		//�A origem eh grade de produtos�
		//�������������������������������
		Case MatOrigGrd() == "SB4"
			dbSelectArea("SB4")
			dbSetOrder(1)
			If ( MsSeek(xFilial("SB4")+cProdRef) )
				cDescProd := SB4->B4_DESC
			EndIf
			//��������������������������������
			//�A origem eh codigo inteligente�
			//��������������������������������
		Case MatOrigGrd() == "SBQ"
			cBase	:= CodBase(cProdRef)
			nTam	:= Len(AllTrim(cBase))+1
			dbSelectArea("SBP")
			dbSetOrder(1)
			If ( MsSeek(xFilial("SBP")+cBase)  )
				dbSelectArea("SBQ")
				dbSetOrder(1)
				MsSeek(xFilial("SBQ")+cBase)
				While lContinua .And. SBQ->(!Eof() .And. BQ_FILIAL+BQ_BASE==xFilial("SBQ")+cBase .And. !BQ_TPGRD$"12")
					If SBP->BP_CODPAD == "2"
						cCodBS  := Substr(cProdRef, SBQ->BQ_INICIO, SBQ->BQ_TAMANHO)
					Else
						cCodBS  := SubStr(cProdRef, nTam, SBQ->BQ_TAMANHO)
						nTam 	+= SBQ->BQ_TAMANHO + 1
					EndIf
					If SBQ->BQ_TIPDEF == "1"
						If (! SBS->(dbSeek(xFilial("SBS") + SBQ->(BQ_BASE + BQ_ID) + cCodBS))) .Or. SBS->BS_ATIVO == "0"
							cCodBS := Space(SBQ->BQ_TAMANHO)
							lContinua := .F.
						Else
							cDescProd += AllTrim(SBS->BS_DESCPRD)+" "
						EndIf
					ElseIf SBQ->BQ_TIPDEF == "2"
						If (! SBX->(dbSeek(xFilial("SBX") + SBQ->BQ_CONJUNT + cCodBS))) .Or. SBX->BX_ATIVO == "0"
							cCodBS := Space(SBQ->BQ_TAMANHO)
							lContinua := .F.
						Else
							cDescProd += AllTrim(SBX->BX_DESCPR)+" "
						EndIf
					ElseIf SBQ->BQ_TIPDEF == "3"
						cDescProd += Padl(AllTrim(cCodBS), SBQ->BQ_TAMANHO, "0")+" "
					Endif
					
					SBQ->( DbSkip() )
				EndDo
				DbSelectArea("SBR")
				DbSetOrder(1)
				If MsSeek(xFilial("SBR")+cBase)
					cDescProd := AllTrim(SBR->BR_DESCPRD)+ " "+cDescProd
				EndIf
				cDescProd := StrTran(cDescProd,Space(2),Space(1))
			EndIf
	EndCase
Endif
Return ( cDescProd )
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CodBase   �Autor  �Patricia D. Aguiar  � Data �  02/01/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o codigo base de produtos gerados pelo cod. intelig.���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CodBase(cBase)  
//������������������������������������������������������������������������Ŀ
//�Inicializa variavel considerando que interface de grade necessita de    �
//�linha e coluna.                                                         �
//��������������������������������������������������������������������������
__nTamBase := If(__nTamBase==NIL,TamSx3("BQ_BASE")[1]-1,__nTamBase) 

If (cBase <> NIL) .And. (Substr(cBase,1,__nTamBase) <> __cCodBase)
	__cCodBase := A093VldBase(cBase)
	__nTamBase := Len(RTrim(__cCodBase))
EndIf
Return (__cCodBase)                                                
                       
                  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A150Desc  �Autor  �Patricia D. Aguiar  � Data �  02/02/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicializador padr�o do campo virtual                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A150Desc()
Local cDescricao := " "
Local cProdRef   := ACV->ACV_REFGRD


If !Empty(cProdRef)    
 	cDescricao:=DescPrRf(cProdRef)
Endif 

Return(cDescricao)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA150VPERG  �Autor  �Daniel Leme  � Data �  19/03/2011      ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o do parametro MV_LJCATPR                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FATA150                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FA150VPERG()

Local lRet := .T.  

If mv_par01 == 2 
	If SuperGetMv("MV_LJCATPR",.F.,.F.) == .F. // Por produto
		HELP("",1,"FT150E02",,"MV_LJCATPR",3) //-- Par�metro n�o est� ativo!    
		lRet := .F.
	EndIf
ElseIf mv_par01 == 3 
	If SuperGetMv("MV_LJCATGP",.F.,.F.) == .F. // Por Grupo
		HELP("",1,"FT150E02",,"MV_LJCATGP",3)  //-- Par�metro n�o est� ativo!    
		lRet := .F.             
	EndIf
ElseIf mv_par01 == 4 // Por Grade	
	If SuperGetMv("MV_LJCATRG",.F.,.F.) == .F.
		HELP("",1,"FT150E02",,"MV_LJCATRG",3) //-- Par�metro n�o est� ativo!    
		lRet := .F.  
	EndIf
EndIf

Return(lRet)    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150VSug  � Autor � Vendas CRM           � Data �29.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtra quando for sugestao de venda.					      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150VSug( cCateg,nRegs )	                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft150VSug( cCateg,nRegs ) 
Local lRet			:= .F.				// Variavel de retorno
Local cSL1TEMP		:= GetNextAlias()	// Pega o proximo Alias Disponivel
Local cSL2TEMP		:= GetNextAlias()	// Pega o proximo Alias Disponivel
Local nQuant		:= 0      			// variavel de codigo de produtos associados
Default	cCateg		:= ""      			// Categoria do Produto
Default nRegs		:= 0       			// Numero de Registros selecionados
#IFDEF TOP
	lRet:=.T.
#ENDIF
If lRet 
	lRet := Empty(ACU->ACU_CODPAI)

EndIf
If lRet
	BeginSql alias cSL1TEMP
	SELECT COUNT(ACV_CATEGO) as CONT
	  FROM %table:ACV% ACV
	 WHERE ACV_CATEGO = %exp:cCateg%   	AND
	 	   ACV_SUVEND = '1'		 		AND
	 	   ACV.%notDel%				
	EndSql
	lRet := ((cSL1TEMP)->CONT == 1)
EndIf   

If lRet 
	nQuant	:= ((cSL1TEMP)->CONT) 
	lRet 	:= nRegs > nQuant 
EndIf
If lRet                          
	BeginSql alias cSL2TEMP
	SELECT COUNT(ACU_COD) as CONT
	  FROM %table:ACU% ACU
	 WHERE ACU_COD IN (SELECT ACU_COD 
	 					 FROM %table:ACU% 
	 					WHERE ACU_CODPAI = %exp:cCateg% AND 
	 						  ACU.%notDel%)
	EndSql
	lRet := ((cSL2TEMP)->CONT) > 0	
EndIf                               

If lRet
  	lRet:=MSGYESNO(STR0010) //"Deseja que o artigo inserido seja relacionado aos outros artigos dessa categoria?", "Deseja que o produto inserido seja relacionado aos outros produtos dessa categoria?"		
  	lRet :=!lRet
EndIf      

If Select(cSL1TEMP) > 0
	(cSL1TEMP)->(DbCloseArea())
EndIf         

If Select(cSL2TEMP) > 0
	(cSL2TEMP)->(DbCloseArea())
EndIf

Return lRet
         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150SugVe � Autor � Vendas CRM           � Data �29.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama wizard de Sugestao de vendas 					      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ft150SugVe()					                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft150SugVe()
	LOJA801()
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150VlDes � Autor � Jo�o Paulo           � Data �28.03.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Descir��o do produto 	    					      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ft150VlDes() 					                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cRetorno                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150VlDes()

Local nPosProd    := 0
Local cRetorno 	  := ""  												 	// Variavel de retorno
Local nPosAcols   := 0
//�������������������������������������������������������������������������������������Ŀ
//�Valida de o campo � em branco para corrigir problema na descri��o do produto no acols�
//���������������������������������������������������������������������������������������
If !INCLUI 
	DbSelectArea("SB1")
	DbSetOrder(1)		  													//Filial + Produto
	If Type("aHeader") == "A" .And. Type("aCols") == "A" .And. (nPosAcols := Len(aCols)) > 0 .And. (nPosProd := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_CODPRO'})) > 0
		If DbSeek(xFilial("SB1") + ACV->ACV_CODPRO)
			If !Empty(aCols[nPosAcols][nPosProd])
				cRetorno := SB1->B1_DESC
			EndIf
		EndIf
	Else
		If DbSeek(xFilial("SB1") + ACV->ACV_CODPRO)
			cRetorno := SB1->B1_DESC
		EndIf
	EndIf
EndIf

Return cRetorno 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft150VlGru � Autor � Vendas CRM           � Data �28.03.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Descir��o do produto 	    					      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ft150VlGru() 					                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cRetorno                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FATA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft150VlGru()

Local nPosGrup    := 0
Local cRetorno 	  := ""  												 	// Variavel de retorno
Local nPosAcols   := 0
//�������������������������������������������������������������������������������������Ŀ
//�Valida de o campo � em branco para corrigir problema na descri��o do produto no acols�
//���������������������������������������������������������������������������������������
If !INCLUI 
	DbSelectArea("SBM")
	DbSetOrder(1)		  													//Filial + Produto
	If Type("aHeader") == "A" .And. Type("aCols") == "A" .And. (nPosAcols := Len(aCols)) > 0 .And. (nPosGrup := aScan(aHeader, {|x|AllTrim(x[2])=='ACV_GRUPO'})) > 0
		If DbSeek(xFilial("SBM") + ACV->ACV_GRUPO)
			If !Empty(aCols[nPosAcols][nPosGrup])
				cRetorno := SBM->BM_DESC
			EndIf
		EndIf
	Else
		If DbSeek(xFilial("SBM") + ACV->ACV_GRUPO)
			cRetorno := SBM->BM_DESC
		EndIf
	EndIf
EndIf

Return cRetorno 

//-------------------------------------------------------------------
/*{Protheus.doc} Ft150POS
Rotina para tratamento dos campos caso tenha integracao com o POS

@param aHeader 		Array com os campos de cabecalho
@param aCols		Array com os itens

@author Leandro.Moura
@since 25/06/2014
@version P11.80
*/
//-------------------------------------------------------------------		
Function Ft150POS()

Local aArea		:= GetArea()		// Armazena ultima area utiliza
Local nPosFlg	:= 0 				// Posicao do campo ACV_POSFLG
Local nPosDt	:= 0				// Posicao do campo ACV_ECDTEX
Local nPosPrd	:= 0				// Posicao do campo ACV_CODPRO  
Local nFor		:= 0 				// Contador do For
Local nUsado   	:= Len(aHeader)		// Informa a quantidade de campos

//������������������������������������������Ŀ
//�Altera flag e campo de data da integracao �
//��������������������������������������������
If ACV->(FieldPos("ACV_POSFLG") > 0) .And. ACV->(FieldPos("ACV_ECDTEX") > 0)

	//�������������������������Ŀ
	//�Busca posicao no aHeader �
	
	//���������������������������
	nPosFlg	:= Ascan(aHeader,{|x| x[2] == "ACV_POSFLG"})
	nPosDt	:= Ascan(aHeader,{|x| x[2] == "ACV_ECDTEX"})	
	nPosPrd	:= Ascan(aHeader,{|x| x[2] == "ACV_CODPRO"})	
	
	If (nPosFlg <> 0) .AND. (nPosDt <> 0) 
	
	    For nFor := 1 to Len(aCols)
	    
	    	If !aCols[nFor][nUsado+1]
	    	
		    	//�������������������������������������������������Ŀ
				//�Caso seja para integracao, limpa o campo de data �
				//���������������������������������������������������
		    	If aCols[nFor][nPosFlg] == "1"
		    		aCols[nFor][nPosDt] := ""
		    	EndIf
	        
				If SB0->(FieldPos("B0_ECDTEX") > 0)	    	
					
					dbSelectArea("SB0")
		   	    	SB0->( DbSetOrder(1) )	
					If SB0->( DbSeek(xFilial("SB0")+aCols[nFor][nPosPrd]) )
						RecLock("SB0",.F.)						
						SB0->B0_ECDTEX := ""
						SB0->( MsUnLock() )					
					EndIf                                               
	            
	            EndIf  
	            
	        EndIf
	        
	    Next nFor 

	EndIf

EndIf

RestArea(aArea)

Return

// -----------------------------------------------------------------
/*/{Protheus.doc} Ft150PreInteg
Fun��o respons�vel por preparar as informa��es para a integra��o

@param		Nil
@author		Felipe Sales Martinez
@since		01/02/2017
@version	1.0
@return		lRet - Se executou com sucesso(.T.) ou com erro(.F.)
/*/
//-------------------------------------------------------------------
Static Function Ft150PreInteg()
Local lRet			:= .T.
Local lBkpAltera	:= .T.
Local cProd			:= ""
Local cGrupo		:= ""
Local cSB1Fil		:= ""
Local aIntegCat		:= {}
Local aArea			:= {}
Local aSB1Area		:= {}
Local nI			:= 0
Local nPosCodPro	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ACV_CODPRO"})
Local nPosGrpPro	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ACV_GRUPO"	})

aIntegCat := Ft150GetArrInt()

If nPosGrpPro > 0 .And. nPosGrpPro > 0 .And. Len(aIntegCat) > 0 

	aArea		:= GetArea()
	aSB1Area	:= SB1->(GetArea())
	cSB1Fil		:= xFilial("SB1")

	//Tratamento para nao deletar o produto mas somente a categoria
	If !INCLUI .And. !ALTERA
		lBkpAltera := ALTERA
		ALTERA := .T.
	Else
		lBkpAltera := ALTERA
	EndIf

	ProcRegua(Len(aIntegCat)) //Definindo o tamanho da regua de progress�o

	For nI := 1 To Len(aIntegCat)

		IncProc() //incrementa a regua de progress�o

		//Se for inclusao nao envia os deletados
		If INCLUI .And. aIntegCat[nI][Len(aHeader)+1]
			Loop
		EndIf

		cProd	:= aIntegCat[nI][nPosCodPro]
		cGrupo	:= aIntegCat[nI][nPosGrpPro]

		//Amarra��o por produto
		If !Empty(cProd)

			SB1->(DBSetOrder(1)) //"B1_FILIAL+B1_COD"
			SB1->(DBSeek(cSB1Fil+cProd))

			If !Ft150ExecInt()
				lRet := .F.
				Exit
			EndIf

		//Amarra��o por grupo de produto
		ElseIf !Empty(cGrupo)

			SB1->(DBSetOrder(4)) //B1_FILIAL+B1_GRUPO+B1_COD
			SB1->(DBSeek(cSB1Fil+cGrupo))

			While SB1->(!EOF()) .And. SB1->(B1_FILIAL+B1_GRUPO) == cSB1Fil+cGrupo 

				If !Ft150ExecInt()
					lRet := .F.
					Exit
				EndIf
				SB1->(DBSkip())
			End

			If !lRet
				Exit
			EndIf
		EndIf

	Next nI

	ALTERA := lBkpAltera
	RestArea(aSB1Area)
	RestArea(aArea)
EndIf

Return lRet

                                                                                                               

// -----------------------------------------------------------------
/*/{Protheus.doc} Ft150ExecInt
Fun��o respons�vel por executar o IntegDef do cadastro de produtos

@obs		IMPORTANTE: A tabela de produto ja deve estar posicionada
@param		Nil
@author		Felipe Sales Martinez
@since		01/02/2017
@version	1.0
@return		lRet - Se executou com sucesso(.T.) ou com erro(.F.)
/*/
//-------------------------------------------------------------------
Static Function Ft150ExecInt()
Local lRet		:= .T.
Local aRetInt	:= {}
Local cMsgRet	:= ""

aRetInt := FwIntegDef("MATA010",,,,"MATA010")

If Valtype(aRetInt) == "A" .And. Len(aRetInt) == 2
	If !aRetInt[1]
		If Empty(AllTrim(aRetInt[2]))
			cMsgRet := STR0037 //"Verificar problema no Monitor EAI"
		Else
			cMsgRet := AllTrim(aRetInt[2])
		Endif
		Conout("Problema na integra��o: "+cMsgRet)
		Aviso(STR0038,cMsgRet,{"Ok"},3) //#"Aten��o"
		lRet := .F.
	Endif
Endif

Return lRet 

// -----------------------------------------------------------------
/*/{Protheus.doc} Ft150GetArrInt
Fun��o respons�vel por retornar somente o array com o registros a 
serem integrados.

@param		Nil
@author		Felipe Sales Martinez
@since		01/02/2017
@version	1.0
@return		aRet - Array com os registros (produto ou grupo de produto) que devem
			ser integrados.
/*/
//-------------------------------------------------------------------
Static Function Ft150GetArrInt()
Local aRet			:= {}	//Retorno da fun��o
Local nPos			:= 0	//Posi��o da informa��o a ser tratada
Local nPosCodPro	:= 0	//Posi��o do campo codigo do produto
Local nPosGrpPro	:= 0	//Posi��o do campo Grupo do produto
Local nPosaHead		:= 0	//Posi��o do conteudo utilizado (ou codigo ou grupo)
Local nI			:= 0	//Contador do loop
Local cProd			:= ""	//Conteudo do campo de codigo de produto
Local cGrupo		:= ""	//Conteudo do campo de grupo de produto
Local cInfo			:= ""	//Conteudo da informa��o do produto ou do grupo de produto
Local lIntegra		:= .F.	//� necess�rio integrar o produto posicionado no loop?
Local lIntgAnt		:= .F.	//� necess�rio integrar o produto antes da altera��o (para retirar da amarra��o em caso de altra��o de informa��o)

//Somente faz a verifica��o quando for altera��o
//do mais (inclusao e exclusao, ser�o utilizados todos os registros do acols.
If ALTERA

	nPosCodPro	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ACV_CODPRO"})
	nPosGrpPro	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ACV_GRUPO"	})

	If nPosCodPro > 0 .And. nPosGrpPro > 0

		For nI := 1 To Len(aCols)

			lIntegra	:= .F.
			lIntgAnt	:= .F. 
			cProd		:= AllTrim(aCols[nI][nPosCodPro])
			cGrupo		:= AllTrim(aCols[nI][nPosGrpPro]) 

			//Determina qual informa��o ser� verifcada (produto ou grupo de produto)
			If !Empty(cProd)
				nPosaHead	:= nPosCodPro
				cInfo		:= cProd
			ElseIf !Empty(cGrupo)
				nPosaHead	:= nPosGrpPro
				cInfo		:= cGrupo
			EndIf

			//Verifica se ja existia a informa��o no inicio do cadastro (no array de backup)
			nPos := aScan(aCadCat, {|x| AllTrim(x[nPosaHead]) == cInfo })

			If nPos == 0 
				//Se nao existir e n�o estiver deletado, significa que � uma inclus�o e deve ser integrado.
				If !aCols[nI][Len(aHeader)+1]
					lIntegra := .T.
				EndIf

				//Verifica se o registro substituido (informa��o antes da altera��o) foi colocado em outro local ou retirar da amarra��o
				//caso nao exista no acols apos altera��o, este produto ou grupo deve ser retirado da integra��o
				If nI <= Len(aCadCat) .And. (aScan(aCols, {|x| AllTrim(x[nPosaHead]) == AllTrim(aCadCat[nI][nPosaHead]) })) == 0 
					lIntgAnt := .T.
				EndIf

			Else
				//Verifica se houve altera��o de dele��o (Se estava habilitado e mudou para deletado)
				If aCadCat[nPos][Len(aHeader)+1] <> aCols[nI][Len(aHeader)+1]
					lIntegra := .T.
				EndIf
			EndIf

			//Adiciona ao array para integra��o 
			If lIntegra .And. aScan(aRet, {|x| AllTrim(x[nPosaHead]) == cInfo }) == 0 
				aAdd(aRet, aClone(aCols[nI]))
			EndIf

			//Integrar o registro anterior para retira-lo da amarra��o
			If lIntgAnt .And. aScan(aRet, {|x| AllTrim(x[nPosaHead]) == AllTrim(aCadCat[nI][nPosaHead])} ) == 0
				aAdd(aRet, aClone(aCadCat[nI]))
			EndIf

		Next nI
	EndIf

Else
	aRet := aClone(aCols)
EndIf

Return aRet

// -----------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de produtos. 

@obs		Foi criada apenas para se configurar o adapter para a amarra��o
			de categoria x produto.
@param xEnt, caracter/Object, Variavel com conteudo xml/obj para envio/recebimento.
@param nTypeTrans, numeric, Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage, caracter, Tipo de mensagem. (Business Type, WhoIs, etc)
@param cVersion, caracter, Vers�o da Mensagem �nica TOTVS
@param cTransac, caracter, Nome da mensagem iniciada no adapter
@param lEAIObj, Logical Recebe XML ou Objeto EAI
@return ${return}, ${return_description}
/*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Default xEnt := ""
Default nTypeTrans := ""
Default cTypeMessage := ""
Default cVersion := ""
Default cTransac := ""
Default lEAIObj := .F.

Return MATI010( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj ) 