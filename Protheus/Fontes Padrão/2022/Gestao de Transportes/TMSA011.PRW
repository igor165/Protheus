#Include "PROTHEUS.ch"
#Include "TMSA011.ch"
#DEFINE aPos  {  15,  3, 94, 315 }

Static lTMA010His := ExistBlock("TMA010HIS")
Static l011TudOk
Static l011Min

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA011  ³ Autor ³        Nava           ³ Data ³18.01.2001  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajuste da Tabela de Frete                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Estrutura do Array de Folders                                ³±±
±±³          ³ [1] -> Tipo "N" , Numero do Folder                           ³±±
±±³          ³ [2] -> Tipo "C" , Titulo do Folder                           ³±±
±±³          ³ [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )       ³±±
±±³          ³ [4] -> Tipo "A  , aHeader   da GetDados do Folder            ³±±
±±³          ³ [5] -> Tipo "A" , aCols     da GetDados do Folder            ³±±
±±³          ³ [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder            ³±±
±±³          ³ [7] -> Tipo "C" , cTudoOk   da GetDados do Folder            ³±±
±±³          ³ [8] -> Tipo "O" , oGetDados deste Folder                     ³±±
±±³          ³ [9] -> Tipo "A" , Campos que podem ser alterados             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA011(nRotina)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
Local cFilMbrow := 'DVC_FILIAL == xFilial("DVC")'
Local aSavaFol  := Iif( Type("aFolder")  !="U",aClone(aFolder),	NIL)
Local aCampos   := { { "Cod. Cliente","DVC_CODCLI" },;
							{ "Loja Cliente","DVC_LOJCLI" },;
							{ "Nome Cliente", 'CriaVar("DVC_NOMCLI")' } }
							
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro := STR0001 											//"Ajuste da Tabela de Frete"
Private aRotina	:= MenuDef()
Private aLayOut   := {}
Private aFolder   := {}
Private aItContrat:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Configuracao da Tabela      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLayOut := TMSLayOutTab(,.T.,,{"15"})
If Len(aLayOut)==0
	Return .F.
EndIf

RestArea(aArea)

DVC->(dbSetOrder(2))
	
If nRotina != Nil
	TMSA011Mnt("DVC",DVC->(RecNo()),nRotina)
Else 
	Aadd(aSetKey, { VK_F12 , { || Pergunte("TMA011",.T.) } } )
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	mBrowse( 06, 01, 22, 75, "DVC", aCampos , , , , , , , , , , , , , , , , , cFilMbrow )
	TmsKeyOff(aSetKey)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura os dados de entrada                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aArea )
If !Empty(aSavaFol)
	aFolder := aClone(aSavaFol)
EndIf

RestInter()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Mnt ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manutencao do Ajuste da Tabela de Frete                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Mnt( ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Registro                                            ³±±
±±³          ³ExpC3 - Opcao Selecionada                                   ³±±
±±³          ³ExpL1 - Controla se as Variaveis utilizadas pelo Ajuste deve³±±
±±³          ³        rao ser inicializadas...                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011Mnt(cAlias,nReg,nOpcx,lMemo)

Local aArea     := GetArea()
Local aAreaDT4  := DT4->( GetArea() )
Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize()
Local aTitles   := {}
Local aPages    := {}
Local nGd1      :=nGd2:=nGd3:=nGd4:=0
Local oDlg   , oEnchoice, aGetOld, aTelOld
Local lTudoOk
Local aAlter
Local aVisual   := {}
Local cSeekDT4  := ""
Local cAliasTop := ""
Local cQuery    := ""
Local cSeek
Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local cSqlOri   := ""
Local cSqlDes   := ""
Local aOrigem   := {}
Local aDestino  := {}
Local nCount    := 0
Local lAux      := .F.
Local lRet      := .F.
Local nLoop     := 0
Local lRetTran  := .T.
Local aYesFields:= {}
Local nCont     := 0
Local aDVCStru  := FwFormStruct(2,"DVC")

Private nFolder := 1
Private nOpcao  := nOpcx
Private aGets   := {}
Private aTela   := {}
Private aHeader := {}
Private aCols   := {}
Private oFolder
Private aHeaderDVO    := {}
Private aHeaderDWZ    := {}
Private aHeaderDJT	  := {}
Private aDadosComp    := {}
Private aEst          := {}
Private nGravouUF     := 0
Private cProdOri      := CriaVar('DVC_CODPRO',.F.)
Private aColsDVO      := IIf(Type("aColsDVO")=="U",{},aColsDVO)
Private aColsDWZ      := IIf(Type("aColsDWZ")=="U",{},aColsDWZ)
Private aColsDJT      := IIf(Type("aColsDJT")=="U",{},aColsDJT)
Private aColsDW2      := {}

// -- Variaveis Private para o Calculo de Excedente por subfaixa
Private aColsDY2      := {}

Private lDVOValMax	:= .F.
Private lDVOVlrMax	:= .F.

lDVOValMax := DVO->(ColumnPos("DVO_VALMAX")) > 0
lDVOVlrMax := DVO->(ColumnPos("DVO_VLRMAX")) > 0

//--Chama grupo de perguntas para atualizar
//--as variaveis publicas MV_PARxx
Pergunte("TMA011",.F.)

If	Type('aItContrat')!='A'
	aItContrat:={}
EndIf

If nOpcx <> 2 .And. nOpcx <> 3 .And. Empty(DVC->DVC_SEQTAB)
	//Problema: Este registro se trata de um Reajuste de preco
	//Solucao: Selecione apenas registros de ajuste de preco
	Help("", 1, "TMSA01102") //Este registro se trata de um Reajuste de preco
	//-- Desabilita as Teclas
	TMA011DesTec()	
	Return .F. 
EndIf

cCadastro := IIf( Type("cCadastro")=="U",STR0001, cCadastro) //"Ajuste da Tabela de Frete"

If ValType(lMemo) <> "L"
	Private aCposVis      := {}
	lMemo    := .T.
EndIf

aCposVis := IIf(Type("aCposVis") <> "U", aCposVis, {})

If lMemo
	nOpcx := aRotina[nOpcx][4]
EndIf

If nOpcx == 3 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a Trava com o Nome 'AJUMAN'. Se algum usuario estiver incluindo Ajuste de   ³
	//³ Cliente, a rotina de 'Reajuste da Tabela de Clientes' nao podera ser executada   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LockByName("AJUMAN",.T.,.F.)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Condicao de Alterar/Excluir³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 4 .Or. nOpcx == 5 

	If !Empty(DVC->DVC_CDRORI)
		TmsNivInf(DVC->DVC_CDRORI,@aOrigem,,.T.)
   		cSqlOri += "'" + DVC->DVC_CDRORI + "',"
		If Len(aOrigem) > 0
			For nCount := 1 To Len(aOrigem)
			   cSqlOri += "'" + aOrigem[nCount][1] + "',"
			Next
		EndIf	
		cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)
	EndIf

	If !Empty(DVC->DVC_CDRDES)
		TmsNivInf(DVC->DVC_CDRDES,@aDestino,,.T.)
	    cSqlDes += "'" + DVC->DVC_CDRDES + "',"
		If Len(aDestino) > 0 
			For nCount := 1 To Len(aDestino)
			   cSqlDes += "'" + aDestino[nCount][1] + "',"
			Next
		EndIf
		cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla Historico de Tabela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- O Objetivo deste Ponto de Entrada, e' validar se sera' permitido Alterar/Excluir (independente
   //-- do conteudo do parametro MV_CONTHIS).
   If lTMA010His
	   lAux := ExecBlock("TMA010HIS",.F.,.F.,{nOpcx,DVC->DVC_TABFRE,DVC->DVC_TIPTAB}) 
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf
		lContHis := lAux
	EndIf

	If lContHis
		cAliasTop := GetNextAlias()
		cQuery := " SELECT DT6_TABFRE,DT6_TIPTAB,DT6_CDRORI,DT6_CDRDES,DT8_CDRORI,DT8_CDRDES "
		cQuery += " FROM "
		cQuery += " "+RetSqlName('DT6')+" DT6,"
		cQuery += " "+RetSqlName('DT8')+" DT8 "
		cQuery += " WHERE DT6.DT6_FILIAL  = '"+xFilial("DT6")+"'"
		cQuery += "		AND DT6.DT6_TABFRE  = '"+DVC->DVC_TABFRE+"'"
		cQuery += " 	AND DT6.DT6_TIPTAB  = '"+DVC->DVC_TIPTAB+"'"
		cQuery += " 	AND DT6.DT6_CLICAL  = '"+DVC->DVC_CODCLI+"'"
		cQuery += " 	AND DT6.DT6_LOJCAL  = '"+DVC->DVC_LOJCLI+"'"
	  	cQuery += " 	AND DT6.DT6_SEQTAB <> '"+"00"+"'"
		cQuery += " 	AND DT6.D_E_L_E_T_  = ' '"
		cQuery += " 	AND DT8.DT8_FILIAL  = '"+xFilial("DT8")+"'"	
		cQuery += " 	AND DT8.DT8_TABFRE  = DT6.DT6_TABFRE"
		cQuery += " 	AND DT8.DT8_TIPTAB  = DT6.DT6_TIPTAB"
		cQuery += " 	AND DT8.DT8_SEQTAB  = DT6.DT6_SEQTAB"
		cQuery += " 	AND DT8.DT8_FILDOC  = DT6.DT6_FILDOC"
		cQuery += " 	AND DT8.DT8_DOC     = DT6.DT6_DOC"
		cQuery += " 	AND DT8.DT8_SERIE   = DT6.DT6_SERIE"
		cQuery += " 	AND DT8.D_E_L_E_T_  = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
		While !(cAliasTop)->(EoF())

			If !Empty(DVC->DVC_CDRORI)
				lRet:= (cAliasTop)->DT6_CDRORI $ cSqlOri 
				If lRet
					Exit
				EndIf
			EndIf

			If !Empty(DVC->DVC_CDRDES)
				lRet:= (cAliasTop)->DT6_CDRDES $ cSqlDes
				If lRet
					Exit
				EndIf
			EndIf

			If !Empty((cAliasTop)->DT6_CDRORI)
				lRet:= (cAliasTop)->DT8_CDRORI $ cSqlOri
				If lRet
					Exit
				EndIf
			EndIf

			If !Empty((cAliasTop)->DT6_CDRDES)
				lRet:= (cAliasTop)->DT8_CDRDES $ cSqlDes
				If lRet
					Exit
				EndIf
			EndIf

			(cAliasTop)->(DbSkip())
		EndDo
		(cAliasTop)->(DbCloseArea())

		If lRet
			Help("", 1, "TMSA01002") // Existe CTRC utilizando esta tabela   
			//-- Desabilita as Teclas
			TMA011DesTec()
			UnLockByName("AJUMAN",.T.,.F.) // Libera Lock
			Return .F.
		EndIf

		DT4->(dbSetOrder(5))
		DT4->(MsSeek(cSeekDT4 := xFilial("DT4")+DVC->DVC_TABFRE+DVC->DVC_TIPTAB+DVC->DVC_SEQTAB+DVC->DVC_CDRORI+DVC->DVC_CDRDES))
		While !DT4->(Eof()) .And. ;
			DT4->DT4_FILIAL + DT4->DT4_TABFRE + DT4->DT4_TIPTAB + DT4->DT4_SEQTAB + DT4->DT4_CDRORI + DT4->DT4_CDRDES == cSeekDT4
			If DT4->DT4_STATUS <> "9"
	     		Help("", 1, "TMSA01003") // Existe Cotacao de Frete utilizando esta tabela
		  		RestArea( aAreaDT4 )
				//-- Desabilita as Teclas
				TMA011DesTec()
				UnLockByName("AJUMAN",.T.,.F.) // Libera Lock
	     		Return .F.
			Else
				DT4->(dbSkip())
			Endif
		EndDo
		RestArea( aAreaDT4 )

	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da Getdados a partir do folder    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aObjects := { {  100, 60, .T., .T. },;
					{ 100, 100, .T., .T. } }

aInfo		:= { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 }

aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nCont := 1 to Len(aDVCStru:aFields)	
	// O campo "Mantem Regiao", nao devera aparecer na Tela de cadastro da Tabela de Frete. 
	// Devera aparecer somente na Tela de Valores Minimos
	If GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO") <> 'DVC_TIPFRE' .And. GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO") <> 'DVC_VIGCON'
		Aadd( aVisual, GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO"))
	EndIf
	//Nao inicializa as variaveis informadas na Tela de Complemento do Ajuste (Funcao TMSA011Min)
	//e nem os campos Codigo/Loja de Cliente.
	//Isto e' feito para manter os valores digitados pelo usuario nesta tela
	If nOpcx == 3
		If GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO") == 'DVC_CODPRO'
			M->&(aDVCStru:aFields[nCont][1]):= cProdOri // Mantem o Produto Digitado na Tabela Mae
		EndIf
	
		If Ascan(aCposVis, {|x| x == GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO")}) > 0 .Or. GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO")$'DVC_CODCLI.DVC_LOJCLI.DVC_NOMCLI'
			dbSkip()
			Loop
		EndIf
	EndIf
	If	(GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CONTEXT")== "V"  .Or. Inclui )
		If aDVCStru:aFields[nCont][1] <> "DVC_DESTAB" 
			M->&(aDVCStru:aFields[nCont][1]):= CriaVar(aDVCStru:aFields[nCont][1])					
		EndIf
	Else		
		M->&(aDVCStru:aFields[nCont][1]):= DVC->(FieldGet(FieldPos(aDVCStru:aFields[nCont][1])))
	EndIf

	If (GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO") $'DVC_TABFREúDVC_TIPTABúDVC_DESTIPúDVC_DESTABúDVC_CDRORIúDVC_REGORIúDVC_CDRDESúDVC_REGDESúDVC_CODPROúDVC_TIPFREúDVC_VIGCONúDVC_VIGCON')
		aAdd(aCposVis,GetSX3Cache(aDVCStru:aFields[nCont][1], "X3_CAMPO"))
	EndIf			 	
							
Next nCont    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Escolhe Configuracao da Tabela se for Inclusao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 3 .And. lMemo
	SaveInter()	
	If !TMSABrowse( aLayOut, STR0013 ,,,,.T., { STR0014 , STR0015, STR0059 } ) //"Escolha a Configuração da Tabela de Frete"###"Tabela de Frete"###"Tipo"###"Descricao"
		UnLockByName("AJUMAN",.T.,.F.) //Libera Lock
  		Return .F.
	EndIf
	RestInter()
	nLoop := Ascan( aLayOut, { |aItem| aItem[1] == .T. } )
	M->DVC_TABFRE := Left( aLayOut[ nLoop ][2], 4 )
	M->DVC_TIPTAB := Left( aLayOut[ nLoop ][3], 2 )
	M->DVC_DESTIP := Tabela("M5", M->DVC_TIPTAB,.F.)
	M->DVC_DESTAB := Posicione('DTL',1,xFilial('DTL')+M->DVC_TABFRE+M->DVC_TIPTAB,'DTL->DTL_DESCRI')
	M->DVC_MOEDA := Posicione('DTL',1,xFilial('DTL')+M->DVC_TABFRE+M->DVC_TIPTAB,'DTL_MOEDA')
	If	M->DVC_MOEDA == 0
		M->DVC_MOEDA := 1
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta Variaveis da Enchoice se for Inclusao de Ajuste ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 3
	aGetOld:= Aclone(aGets)
	aTelOld:= Aclone(aTela)
	n      := 1
	If lMemo
		M->DVC_CODCLI := CriaVar('DVC_CODCLI', .F.)
		M->DVC_LOJCLI := CriaVar('DVC_LOJCLI', .F.)
		M->DVC_CDRORI := CriaVar('DVC_CDRORI', .F.)
		M->DVC_REGORI := CriaVar('DVC_REGORI', .F.)
		M->DVC_CDRDES := CriaVar('DVC_CDRDES', .F.)
		M->DVC_REGDES := CriaVar('DVC_REGDES', .F.)
		M->DVC_CODPRO := CriaVar('DVC_CODPRO', .F.)
		M->DVC_CODNEG := CriaVar('DVC_CODNEG', .F.)
		M->DVC_SERVIC := CriaVar('DVC_SERVIC', .F.)
		M->DVC_SEQTAB := StrZero(0,Len(DVC->DVC_SEQTAB))
	EndIf              
	aColsDVO := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sera aberta a Tela de Complemento do Ajuste (DVO), na entrada do programa, para  ³
	//³que o usuario informe os camponentes que serao calculados. Apos a confirmacao da ³
	//³Tela, o folder sera montado apenas com os componentes que tenham o campo         ³
	//³"DVO_CALPAS" (Calcula Pasta) == Sim"                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := TMSA011Min( nOpcx, .T. )
	If !lRet 
		UnLockByName("AJUMAN",.T.,.F.) // Libera Lock		   
		Return 
	EndIf
	//-- Verifica a Sequencia da Tabela
	TM011SeqTab()
	M->DVC_NOMCLI := Posicione("SA1",1,xFilial('SA1')+M->DVC_CODCLI+M->DVC_LOJCLI,"A1_NOME")
	//-- Guarda nesta Variavel o Produto da Tabela Mae, informado na Tela de Compl. de Tab. Frete
	cProdOri := M->DVC_CODPRO
	aGets := Aclone(aGetOld)
	aTela := Aclone(aTelOld)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Folder   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSA011Fol( nOpcx )

If Len(aFolder) == 0
   Help("",1,"TMSA01103") //Tabela Mae Nao Encontrada !!!
	UnLockByName("AJUMAN",.T.,.F.) // Libera Lock		   
	Return .F.                                                                             	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Titles e Pages ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval( aFolder, { | aFolderLine | 	Aadd( aTitles, aFolderLine[2] ), Aadd( aPages,  "AHEADER" ) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Tela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oEnchoice := MsMGet():New( cAlias ,nReg, nOpcx, , , ,aVisual, aPosObj[1], aAlter, 3,,,,,, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha Folders  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder := TFolder():New(	aPosObj[2,1],aPosObj[2,2],aTitles,aPages, oDlg,,,,.T.,.F.,;
aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as GetDados na Ordem INVERSA de Apresentacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := Len( aFolder ) To 1 Step - 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o campo "Item" da GetDados                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFolder := aFolder[nLoop][1]
	aHeader := aClone( aFolder[nLoop][4] )
	aEval(aFolder[nLoop][5], {|x| IIf( Empty(x[GdFieldPos('DVD_ITEM')]), x[GdFieldPos('DVD_ITEM')]:= StrZero(1, Len(DVD->DVD_ITEM)), .T.) })
	aCols   := aClone( aFolder[nLoop][5] )
	
	//  (              nT, nL, nB, nR, nOpc, cLinhaOk, cTudoOk, cIniCpos,lDeleta, aAlter, nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	aFolder[nLoop][8] := MSGetDados():New(	nGd1,nGd2,nGd3,nGd4,nOpcx,;
	aFolder[nLoop][6],aFolder[nLoop][7],"+DVD_ITEM",nOpcx<>2,aFolder[nLoop][9],,,,,,,    ,;
	oFolder:aDialogs[nLoop]	)
	
	//Faz com que itens do Aju. Subf venham marcados como deletados. Por solicitação da Ramos foi modificado.
	If ValType(mv_par01) == "N"  .And. (mv_par01 == 1)//Pergunta para habilitar ou não registros deletados. 1=Sim, 2=Não
		Aeval( aCols, { |x|  IIf(nOpcx<>5, ;
		TMA011AjuFol(aFolder[nLoop][8],nOpcao,cFolder) , .T.) } )
		
		aFolder[nLoop][5] := aClone(aCols)
		aFolder[nLoop][8]:oBrowse:Refresh(.T.)
			If nLoop == 1
				aFolder[nLoop][8]:oBrowse:lDisablePaint := .F.
			Else 
				aFolder[nLoop][8]:oBrowse:lDisablePaint := .T.
			EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acerta OBRIGAT da MsGetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	TMSObgGetDados( aFolder[nLoop][8] )
	
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita o Trocador de Folder³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder:bSetOption:={|nAtu| TMSA011Chg( nAtu, oFolder:nOption ) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama Localizador de Folder Ativo ³
//³ Desenha a EnchoiceBar             ³
//³ Ativa Obrigat da Enchoice         ³
//³ Ativa Obrigat das GetDados        ³
//³ Ativa Dialog  Principal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ACTIVATE MSDIALOG oDlg ON INIT ( TMSA011Loc( nOpcx, oFolder),;
											TMSA011Bar( oDlg, { ||	lTudoOk := ( 	nOpcx != 2 .AND. ;
											Obrigatorio(aGets,aTela) .AND.;
											TMSA011Ok(oFolder:nOption) ), ;
											IIf( lTudoOk, oDlg:End(), Nil ) },;
											{|| oDlg:End() }, nOpcx ))
	
If ( lTudoOk )
	If nOpcx == 3	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Trava pelo Cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		lTudoOk:= MultLock("DVC",{"INC_AJU"+M->DVC_CODCLI+M->DVC_LOJCLI},1)
	EndIf
EndIf

If ( lTudoOk )

		
	Begin Transaction
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo o Proximo Numero do Ajuste ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a Tabela Mae e TRAVA para ³
	//³ Evitar que outra estacao pegue o  ³
	//³ mesmo numero. Tipo SX8            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcx == 3

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a rotina de 'Reajuste da Tabela de Clientes' estiver sendo executada, nao sera³
		//³ permitida a inclusao Manual de Ajuste de Clientes                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		If !MultLock("DVC",{"GERAJU"},1)
			UnLockByName("AJUMAN",.T.,.F.) // Libera Lock
			lRetTran:= .F.
			Break	
		EndIf
	
		DVD->(dbSetOrder(1))
		If DVD->( MsSeek( xFilial("DVC") + M->DVC_TABFRE + M->DVC_TIPTAB + M->DVC_CDRORI + M->DVC_CDRDES + Space(Len(M->DVC_CODCLI+ M->DVC_LOJCLI))+ StrZero(0, Len(DVC->DVC_SEQTAB)) ) )
			RecLock( "DVD", .F. )
		EndIf
      TM011SeqTab()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a Gravacao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CursorWait()
	TMSA011Grv( nOpcx )
	CursorArrow()
	If ( __lSX8 )
		ConfirmSX8()
	EndIf
	EvalTrigger()
	
	End Transaction
	
	If !lRetTran
		Return .F.
	EndIf
		
	If nOpcx == 3  // Inclusao 
		//-- Se o Tipo de Frete for CIF : Regioes de Origem Diferente para mesma Regiao Destino
		//-- Se o Tipo de Frete for FOB : Regioes de Origem Igual para Regioes de Destino Diferente
		If M->DVC_TIPFRE == '1' // CIF
			M->DVC_CDRDES := Space(Len(DVC->DVC_CDRDES))
			M->DVC_REGDES := Space(Len(DUY->DUY_DESCRI))
			If ExistTrigger('DVC_CDRDES')
			   RunTrigger(1,,,,'DVC_CDRDES')
			EndIf			   
		Else
			M->DVC_CDRORI := Space(Len(DVC->DVC_CDRORI))
			M->DVC_REGORI := Space(Len(DUY->DUY_DESCRI))
			If ExistTrigger('DVC_CDRORI')
			   RunTrigger(1,,,,'DVC_CDRORI')
			EndIf			   
		EndIf
			
		// Apos a Gravacao, chamar novamente a Tela de Complemento do Ajuste de Frete,
		// contendo os mesmos valores digitados anteriormente.
		TMSA011Mnt(cAlias,nReg,nOpcx,.F.)
	EndIf
		
Else  

	If ( __lSX8 )
		RollBackSX8()
	EndIf
	
EndIf
	
UnLockByName("AJUMAN",.T.,.F.) //Libera Lock

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade dos dados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

//-- Desabilita as Teclas
TMA011DesTec()

RestArea(aArea)
	
Return NIL
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Grv ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao da Enchoice e das GetDados dos Folders             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Grv( nOpcx, cMasterAlias, cSlaveAlias,  ;           ³±±
±±³          ³             nSlaveOrder, cSlaveSeek, bSlaveFor,;           ³±±
±±³          ³             bSlaveWhile, bMasterRec, bSlaveRec  )          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1        - Opcao do aRotina                             ³±±
±±³          ³ExpC1        - Alias da Enchoice ( Pai )                    ³±±
±±³          ³ExpC2        - Alias da GetDados ( Filhos )                 ³±±
±±³          ³ExpN2        - Ordem para Pesquisa dos Filhos               ³±±
±±³          ³ExpC3        - Chave para Pesquisa dos Filhos               ³±±
±±³          ³ExpB1        - 'For' para Pesquisa dos Filhos               ³±±
±±³          ³ExpB2        - 'While' para Pesquisa dos Filhos             ³±±
±±³          ³ExpB3        - Gravacao de campos adicionais no Master      ³±±
±±³          ³ExpC4        - Gravacao de campos adicionais no Slave       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³- Efetua a gravacao de TUDO, Enchoice e Todas as GetDados   ³±±
±±³          ³- O campo cbSlaveRec eh uma String porem em FORMATO de      ³±±
±±³          ³  codeblock, porque o ultimo parametro eh o nome do campo   ³±±
±±³          ³  que vai armazenar o Numero do Folder.                     ³±±
±±³          ³  Exemplo : cbSlaveRec := "{ || DVD->DVD_CODPAS := '"       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011Grv(nOpcx, cMasterAlias, cSlaveAlias, nSlaveOrder, ;
cSlaveSeek, bSlaveFor, bSlaveWhile, bMasterRec, cbSlaveRec  )

Local aArea      	 := GetArea()
Local aAreaDVC     := DVC->(GetArea())
Local lRetorno   	 := .T.
Local nPosDesPas   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_DESPAS'})
Local nDesPasDWZ   := Ascan(aHeaderDWZ, {|x| AllTrim(x[2]) == 'DWZ_DESPAS'})
Local nPosCalPas   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_CALPAS'})
Local nPosAplAju   := Ascan(aHeaderDVO, {|x| Alltrim(x[2]) == "DVO_APLAJU"})
Local nPosValMin   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_VLRMIN'})
Local nPosValMax   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_VLRMAX'})
Local nPosValExc   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_VLREXC'})
Local nPosPerMin   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_PERMIN'})
Local nPosPerMax   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_PERMAX'})
Local nPosPerExc   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_PERAJU'})
Local nPosCodPas   := Ascan(aHeaderDVO, {|x| AllTrim(x[2]) == 'DVO_CODPAS'})
Local nPos         := 0
Local nPosDesDJT   := IIf(AliasInDic("DJS") , Ascan(aHeaderDJT, {|x| AllTrim(x[2]) == 'DJT_DESPAS'}) , 0)

Local nValor		:= 0
Local nPercMin		:= 0
Local nPercMax		:= 0
Local nPercExc		:= 0
Local nValMin		:= 0
Local nValMax		:= 0
Local nValExc		:= 0
Local aMsgErr		:= {}
Local nSeek, nAt, nTipAju, nPerc
Local cDesc, cCdrOri, cCdrDes
Local aNoEmptyFields
Local ny,nx,nI
Local nLoop
Local nPosItDW2 	:= 0
Local cSeek     	:= ''
Local aColsAux		:= {}
Local nAuxDJT		:= 0
Local cCodPas		:= ""

Default cMasterAlias := "DVC"
Default cSlaveAlias  := "DVD"
Default nSlaveOrder  := 3
Default cSlaveSeek   := xFilial('DVD') + M->DVC_TABFRE + M->DVC_TIPTAB + M->DVC_CDRORI + M->DVC_CDRDES + M->DVC_CODCLI+ M->DVC_LOJCLI + M->DVC_SEQTAB + M->DVC_CODPRO + M->DVC_CODNEG + M->DVC_SERVIC
Default bSlaveFor    := { || .T. }
Default bSlaveWhile  := { || DVD->DVD_FILIAL + DVD->DVD_TABFRE + DVD->DVD_TIPTAB + DVD->DVD_CDRORI + DVD->DVD_CDRDES + DVD->DVD_CODCLI + DVD->DVD_LOJCLI + DVD->DVD_SEQTAB + DVD->DVD_CODPRO + DVD->DVD_CODNEG + DVD->DVD_SERVIC}
Default bMasterRec   := { || NIL }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos a serem gravados alem do ACOLS ( Slave )  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default cbSlaveRec   := 			 "{ || " + ;
									 "DVD->DVD_TABFRE := M->DVC_TABFRE , DVD->DVD_CDRORI := M->DVC_CDRORI, " + ;
									 "DVD->DVD_CDRDES := M->DVC_CDRDES, " + ;
									 "DVD->DVD_CODCLI := M->DVC_CODCLI, " + ;
									 "DVD->DVD_LOJCLI := M->DVC_LOJCLI, " + ;
									 "DVD->DVD_SEQTAB := M->DVC_SEQTAB, " + ;
									 "DVD->DVD_CODPRO := M->DVC_CODPRO, " + ;
									 "DVD->DVD_CODNEG := M->DVC_CODNEG, " + ;
									 "DVD->DVD_SERVIC := M->DVC_SERVIC, " + ;
									 "DVD->DVD_TIPTAB := M->DVC_TIPTAB, DVD->DVD_CODPAS := '"
									
If nOpcx <> 5 // Deleta    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao da Enchoice ( Master )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock( cMasterAlias, nOpcx== 3 .Or. nOpcx==6)
	For nX:=1 TO FCount()
		If "FILIAL"$Field(nX)
			FieldPut(nX,xFilial("DVC"))
		Else
			If Type("M->"+FieldName(nX)) <> "U"
				FieldPut(nX,M->&(FieldName(nX)))
			EndIf
		EndIf
	Next nX		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao Adicional da Enchoice se houver ( Master )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval( bMasterRec )
	MsUnLock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do Complemento do Ajuste de Frete                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aColsDVO)

		DT3->(dbSetOrder(1))
		DT3->(MsSeek( xFilial( "DT3" ) + AllTrim(aColsDVO[nX][nPosCodPas]) ) )					    					
		cFolder := DT3->DT3_CODPAS
		 
		If !aColsDVO[nX][Len(aColsDVO[nX])] // Nao grava o Item se estiver deletado		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ So grava DVO se o campo DVO_CALPAS (Calcula Pasta) for igual a "Sim"  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aColsDVO[nX][nPosCalPas] == '1'

				//-- Faz a Copia do Complemento do Ajuste Principal para as Regioes Destino dos Estados Escolhidos
				If nGravouUF <> 0
					DTK->( DbSetOrder(1) )
					DTK->( MsSeek( xFilial("DTK") + M->DVC_TABFRE + M->DVC_TIPTAB + M->DVC_CDRORI + M->DVC_CDRDES + M->DVC_CODPRO + cFolder ) )
					nValMin := DTK->DTK_VALMIN
					nValMax := DTK->DTK_VALMAX
		            nValExc := DTK->DTK_VALOR
					nTipAju := aColsDVO[nX][nPosAplAju]					

					If nTipAju == '1' //se aplica ajuste por valor
						If Empty(nValMin) .And. Empty(nValExc) .And. Empty(nValMax)
	     				   cCdrOri := M->DVC_CDRORI
	     				   cCdrDes := M->DVC_CDRDES
				     		If TmsTabela( aMsgErr, M->DVC_TABFRE,  M->DVC_TIPTAB, , @cCdrOri, @cCdrDes , , , M->DVC_CODPRO, M->DVC_SERVIC, M->DVC_TABTAR, DT3->DT3_TAXA, cFolder, DT3->DT3_PSQTXA, , , , , , , M->DVC_CODNEG )
								DTK->( MsSeek( xFilial("DTK") + M->DVC_TABFRE + M->DVC_TIPTAB + cCdrOri + cCdrDes + M->DVC_CODPRO + cFolder ) )
								nValMin := DTK->DTK_VALMIN
				            	nValMax := DTK->DTK_VALMAX
					            nValExc := DTK->DTK_VALOR
 		                    EndIf
						EndIf
	               					
						nPercMin := (aColsDVO[nX][nPosValMin]/nValMin) * 100 //-- Calcular o Percentual Minimo
						nPercMax := (aColsDVO[nX][nPosValMax]/nValMax) * 100 //-- Calcular o Percentual Maximo
						nPercExc := (aColsDVO[nX][nPosValExc]/nValExc) * 100 //-- Calcular o Percentual Excedente

						aColsDVO[nX][nPosPerMin] := nPercMin
						aColsDVO[nX][nPosPerMax] := nPercMax
						aColsDVO[nX][nPosPerExc] := nPercExc
					EndIf                
				EndIf
								
				If DVO->(MsSeek(xFilial("DVO")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+;
					 M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO+M->DVC_SERVIC+cFolder+M->DVC_CODNEG ))
					RecLock("DVO",.F.)
				Else
					RecLock("DVO",.T.)
				EndIf
				For nY:= 1 to Len(aHeaderDVO)
					If aHeaderDVO[nY][10] # "V"
						DVO->(FieldPut(FieldPos(Trim(aHeaderDVO[nY][2])),aColsDVO[nX][nY]))
					EndIf
				Next nY
				DVO->DVO_FILIAL := xFilial("DVO")
				DVO->DVO_TABFRE := M->DVC_TABFRE
				DVO->DVO_TABFRE := M->DVC_TABFRE
				DVO->DVO_CDRORI := M->DVC_CDRORI
				DVO->DVO_CDRDES := M->DVC_CDRDES
				DVO->DVO_TIPTAB := M->DVC_TIPTAB
				DVO->DVO_SEQTAB := M->DVC_SEQTAB
				DVO->DVO_CODCLI := M->DVC_CODCLI
				DVO->DVO_LOJCLI := M->DVC_LOJCLI
				DVO->DVO_CODPAS := Posicione( "DT3", 1, xFilial("DT3")+aColsDVO[nX,nPosCodPas], "DT3_CODPAS" )
				DVO->DVO_SERVIC := M->DVC_SERVIC
				DVO->DVO_CODPRO := M->DVC_CODPRO
				DVO->DVO_CODNEG := M->DVC_CODNEG
				MsUnLock()
			EndIf
		ElseIf nOpcx == 4 //Se for alteracao e a Linha do aCols estiver deletada
 			If DVO->(MsSeek(xFilial("DVO")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+;
				 M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO+M->DVC_SERVIC+cFolder+M->DVC_CODNEG ))
				RecLock("DVO",.F.)
				dbDelete()
				MsUnLock()
			EndIf			
		EndIf	
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do Ajuste de TDA                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aColsDWZ)

		DT3->(dbSetOrder(2))
		DT3->(MsSeek( xFilial( "DT3" ) + AllTrim(aColsDWZ[nX][nDesPasDWZ]) ) )					    					
		cFolder := DT3->DT3_CODPAS
		 
		If !aColsDWZ[nX][Len(aColsDWZ[nX])] // Nao grava o Item se estiver deletado
			If DWZ->(MsSeek(xFilial("DWZ")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+;
				 M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO+M->DVC_SERVIC+cFolder+M->DVC_CODNEG ))
				RecLock("DWZ",.F.)
			Else
				RecLock("DWZ",.T.)
			EndIf
			
			For nY:= 1 to Len(aHeaderDWZ)
				If aHeaderDWZ[nY][10] # "V"
					DWZ->(FieldPut(FieldPos(Trim(aHeaderDWZ[nY][2])),aColsDWZ[nX][nY]))
				EndIf
			Next nY
			
			DWZ->DWZ_FILIAL := xFilial('DWZ')
			DWZ->DWZ_TABFRE := M->DVC_TABFRE
			DWZ->DWZ_CDRORI := M->DVC_CDRORI
			DWZ->DWZ_CDRDES := M->DVC_CDRDES
			DWZ->DWZ_TIPTAB := M->DVC_TIPTAB
			DWZ->DWZ_SEQTAB := M->DVC_SEQTAB
			DWZ->DWZ_CODCLI := M->DVC_CODCLI
			DWZ->DWZ_LOJCLI := M->DVC_LOJCLI
			DWZ->DWZ_CODPAS := Posicione( "DT3", 2, xFilial("DT3")+aColsDWZ[nX,nDesPasDWZ], "DT3_CODPAS" )
			DWZ->DWZ_SERVIC := M->DVC_SERVIC
			DWZ->DWZ_CODPRO := M->DVC_CODPRO
			DWZ->DWZ_CODNEG := M->DVC_CODNEG
			
			MsUnLock()
		
		ElseIf nOpcx == 4 //Se for alteracao e a Linha do aCols estiver deletada
 			If DWZ->(MsSeek(xFilial("DWZ")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+;
				 M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO+M->DVC_SERVIC+cFolder+M->DVC_CODNEG ))
				RecLock("DWZ",.F.)
				dbDelete()
				MsUnLock()
			EndIf			
		EndIf	
	Next nX
	
	//-- Gravação Ajuste % Componente (TRT)
	For nX := 1 To Len(aColsDJT)
		aColsAux	:= aColsDJT[nX,2]
		cCodPas		:= aColsDJT[nX,1]
		
		For nAuxDJT := 1 To Len(aColsAux)
			
			DT3->(dbSetOrder(2))
			If DT3->(MsSeek( xFilial( "DT3" ) + AllTrim(aColsAux[nAuxDJT][nPosDesDJT]) ) )					    					
				
				cFolder := DT3->DT3_CODPAS		
						
				//-- Não grava se estiver deletado
				If !aColsAux[nAuxDJT][Len(aColsAux[nAuxDJT])] 
					If DJT->(MsSeek(xFilial("DJT")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+ M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO + M->DVC_SERVIC + cCodPas + cFolder + M->DVC_CODNEG ))
						RecLock("DJT",.F.)
					Else
						RecLock("DJT",.T.)
					EndIf
					
					For nY:= 1 to Len(aHeaderDJT)
						If aHeaderDJT[nY][10] # "V"
							DJT->(FieldPut(FieldPos(Trim(aHeaderDJT[nY][2])),aColsAux[nAuxDJT][nY]))
						EndIf
					Next nY
					
					DJT->DJT_FILIAL := xFilial('DJT')
					DJT->DJT_TABFRE := M->DVC_TABFRE
					DJT->DJT_CDRORI := M->DVC_CDRORI
					DJT->DJT_CDRDES := M->DVC_CDRDES
					DJT->DJT_TIPTAB := M->DVC_TIPTAB
					DJT->DJT_SEQTAB := M->DVC_SEQTAB
					DJT->DJT_CODCLI := M->DVC_CODCLI
					DJT->DJT_LOJCLI := M->DVC_LOJCLI
					DJT->DJT_CODPRO := M->DVC_CODPRO
					DJT->DJT_CODTRT	:= cCodPas
					DJT->DJT_CODPAS := cFolder
					DJT->DJT_SERVIC := M->DVC_SERVIC
					DJT->DJT_CODNEG := M->DVC_CODNEG
					
					MsUnLock()
				Elseif nOpcx == 4 //Se for alteracao e a Linha do aCols estiver deletada
					If DJT->(MsSeek(xFilial("DJT")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+ M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO + M->DVC_SERVIC + cCodPas + cFolder + M->DVC_CODNEG ))
						RecLock("DJT",.F.)
						dbDelete()
						MsUnLock()
					EndIf					
				EndIf
			EndIf
		Next nAuxDJT
		
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DESTRAVA se foi Inclusao de Ajuste   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcx == 3
		DVD->( dbSetOrder(1) )
		If DVD->( MsSeek( xFilial("DVC") + M->DVC_TABFRE + M->DVC_TIPTAB + M->DVC_CDRORI + M->DVC_CDRDES + Space(Len(M->DVC_CODCLI+ M->DVC_LOJCLI)) +  StrZero(0, Len(DVC->DVC_SEQTAB)) + M->DVC_CODNEG ) )
			DVD->( MsUnLock() )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿              
	//³Gravacao das Getdados ( Slave )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop := 1 TO Len( aFolder )
		cFolder := aFolder[nLoop][1]
		aHeader := aFolder[nLoop][4]
		aCols   := aFolder[nLoop][5]
		bRecFields := &(cbSlaveRec + cFolder + "' }")
		aNoEmptyFields := {'DVD_VALATE'}
		n := 1
		If nGravouUF <> 0  // Vai Fazer a Copia dos Ajustes para a Regiao Destino dos Estados Escolhidos
			//-- Verificar o Tipo do Ajuste Aplicado
			cDesc   := aFolder[nLoop][2]
			
			nSeek   := Ascan( aColsDVO, {|x| AllTrim(x[nPosCodPas]) == AllTrim(cFolder) })
			If nSeek > 0
				nTipAju := aColsDVO[nSeek][nPosAplAju]
			EndIf
		EndIf
		
		For nX := 1 to Len(aCols)
			If !aCols[nX][Len(aCols[nX])]
				//-- Nas copias do Ajuste Principal para as Regioes Destino dos Estados Escolhidos,
				//-- Se o Ajuste do Componente for aplicado por VALOR, o Percentual do Ajuste devera ser Calculado ...
				//-- Para Tanto, pegar o Valor do Componente Informado no Ajuste Principal e Dividir pelo
				//-- Valor do Componente Informado na Tabela Mae ...                  
				cCdrOri := M->DVC_CDRORI
				cCdrDes := M->DVC_CDRDES												
				If nGravouUF <> 0 .And. nTipAju == '1' // Se Aplica Ajuste por 'Valor'										
					//-- Posiciona na Tabela Mae, para verificar se foi informada Tabela de Tarifa
					DT0->(dbSetOrder(1))
					DT0->( MsSeek(cChave:=xFilial('DT0')+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+ M->DVC_CDRDES +cProdOri ))
					
					//-- Se existir o Item Gravado no DT1, pega o Valor do campo D1_VALOR, caso contrario,
					//-- verifica se existe Tarifacao, e pega o Valor do campo DG_VALOR.
					nValor := 0
					DT1->(dbSetOrder(1))
					If DT1->(MsSeek(xFilial("DT1") + M->DVC_TABFRE + M->DVC_TIPTAB +M->DVC_CDRORI + ;
						M->DVC_CDRDES+cProdOri+cFolder+aCols[nX][1]))
						nValor := DT1->DT1_VALOR
					Else
						DTG->(dbSetOrder(1))                                            
						DTG->(MsSeek(xFilial("DTG") + M->DVC_TABFRE + M->DVC_TIPTAB+ DT0->DT0_TABTAR+cFolder+aCols[nX][1]))
						nValor := DTG->DTG_VALOR
					EndIf
					
					If Empty(nValor)           
						DT3->(dbSetOrder(1))
						DT3->(MsSeek( xFilial( "DT3" ) + cFolder ) )					    
						cTabTar := DT0->DT0_TABTAR 
			     		If TmsTabela( aMsgErr, M->DVC_TABFRE,  M->DVC_TIPTAB, , @cCdrOri, @cCdrDes , , , M->DVC_CODPRO, M->DVC_SERVIC, @cTabTar, DT3->DT3_TAXA, cFolder, DT3->DT3_PSQTXA, , , , , , , M->DVC_CODNEG )
							dbSelectArea('DT1')
							dbSetOrder(1)
							If DT1->(MsSeek(xFilial("DT1") + M->DVC_TABFRE + M->DVC_TIPTAB + cCdrOri + ;
								cCdrDes+cProdOri+cFolder+aCols[nX][1]))				
								nValor  :=  DT1->DT1_VALOR								
							Else               
								dbSelectArea('DTG')							
								dbSetOrder(1)
								DTG->(MsSeek(xFilial("DTG") + M->DVC_TABFRE + M->DVC_TIPTAB+ cTabTar+cFolder+aCols[nX][1]))								
								nValor  :=  DTG->DTG_VALOR																								
                     EndIf							                     
						EndIf	                     					
						If Empty(nValor)
							Loop
						EndIf		
					EndIf
               					
					nPerc := (GdFieldGet('DVD_VALAJU',nX)/nValor) * 100 // Calcula o Percentual
					GdFieldPut('DVD_PERAJU',nPerc,nX)

				EndIf
				
				DVD->(dbSetOrder(1))
				If  DVD->(MsSeek(xFilial("DVD") + M->DVC_TABFRE + M->DVC_TIPTAB + M->DVC_CDRORI + ;
					M->DVC_CDRDES + M->DVC_CODCLI+ M->DVC_LOJCLI + M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+cFolder+aCols[nX][1]+M->DVC_CODNEG))
					RecLock("DVD",.F.)
				Else
					RecLock("DVD",.T.)
				EndIf
				For nY:= 1 to Len(aHeader)
					If aHeader[nY][10] # "V"
						DVD->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
					EndIf
				Next nY
				Eval( bRecFields )
 				nSeek:= Ascan(aDadosComp,{|x| x[1] == DVD->DVD_CODPAS } )
				//-- Ajuste da Tabela Principal
				If nSeek > 0 .And. nGravouUF == 0
					DVD->DVD_RGOTAB := aDadosComp[nSeek][2][1] // Regiao Origem da Tabela Mae
					DVD->DVD_RGDTAB := aDadosComp[nSeek][2][2] // Regiao Destino da Tabela Mae					
					DVD->DVD_PRDTAB := aDadosComp[nSeek][2][3] // Produto da Tabela Mae
		
				//-- Copia do Ajuste Principal para as Regioes Destino dos Estados Escolhidos
				ElseIf nGravouUF <> 0                                               
					DVD->DVD_RGOTAB := cCdrOri  // Regiao Origem da Tabela Mae				
					DVD->DVD_RGDTAB := cCdrDes  // Regiao Destino da Tabela Mae
					DVD->DVD_PRDTAB := cProdOri // Produto da Tabela Mae
				EndIf
					DVD->DVD_FILIAL := xFilial('DVD')
				MsUnLock()
				
				//-- Gravacao das Sub-Faixas por item
				If (nPos:= Ascan( aColsDW2, { |x| x[1]+x[2] == cFolder + aCols[nX][1] } ) ) > 0
					nPosItDW2 := GDFieldPos("DW2_ITEM",aColsDW2[nPos,4])
					For nY := 1 To Len(aColsDW2[nPos,3])
						cItem := aColsDW2[nPos,3,nY,nPosItDW2]
						If !GdDeleted(nY,aColsDW2[nPos,4],aColsDW2[nPos,3])
							DW2->(DbSetOrder(1))
							If !DW2->(MsSeek(xFilial("DW2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+cFolder+aCols[nX][1]+cItem+M->DVC_CODNEG))
								RecLock("DW2",.T.)
								DW2->DW2_FILIAL := xFilial("DW2")
								DW2->DW2_TABFRE := M->DVC_TABFRE
								DW2->DW2_TIPTAB := M->DVC_TIPTAB
								DW2->DW2_CDRORI := M->DVC_CDRORI
								DW2->DW2_CDRDES := M->DVC_CDRDES
								DW2->DW2_CODCLI := M->DVC_CODCLI
								DW2->DW2_LOJCLI := M->DVC_LOJCLI
								DW2->DW2_SEQTAB := M->DVC_SEQTAB
								DW2->DW2_CODPRO := M->DVC_CODPRO
								DW2->DW2_SERVIC := M->DVC_SERVIC
								DW2->DW2_CODPAS := cFolder
								DW2->DW2_ITEDVD := aCols[nX][1]
								DW2->DW2_CODNEG := M->DVC_CODNEG
							Else
								RecLock("DW2",.F.)
							EndIf
							For nI := 1 To Len(aColsDW2[nPos,4])
								If aColsDW2[nPos,4,nI,10] != 'V'
									DW2->(FieldPut(FieldPos(aColsDW2[nPos,4,nI,2]),GDFieldGet(aColsDW2[nPos,4,nI,2],nY,,aColsDW2[nPos,4],aColsDW2[nPos,3])))
								EndIf
							Next nI
			 				nSeek:= Ascan(aDadosComp,{|x| x[1] == DW2->DW2_CODPAS } )
							//-- Ajuste da Tabela Principal
							If nSeek > 0 .And. nGravouUF == 0
								DW2->DW2_RGOTAB := aDadosComp[nSeek][2][1] // Regiao Origem da Tabela Mae
								DW2->DW2_RGDTAB := aDadosComp[nSeek][2][2] // Regiao Destino da Tabela Mae					
								DW2->DW2_PRDTAB := aDadosComp[nSeek][2][3] // Produto da Tabela Mae
					
							//-- Copia do Ajuste Principal para as Regioes Destino dos Estados Escolhidos
							ElseIf nGravouUF <> 0                                               
								DW2->DW2_RGOTAB := cCdrOri  // Regiao Origem da Tabela Mae				
								DW2->DW2_RGDTAB := cCdrDes  // Regiao Destino da Tabela Mae
								DW2->DW2_PRDTAB := cProdOri // Produto da Tabela Mae
							EndIf
							DW2->(MsUnlock())
						Else
							DW2->(DbSetOrder(1))
							If DW2->(MsSeek(xFilial("DW2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+cFolder+aCols[nX][1]+cItem+M->DVC_CODNEG))
								RecLock("DW2",.F.)
								DW2->(DbDelete())
								DW2->(MsUnlock())
							EndIf
						EndIf
					Next nY
					
					// Excedente por Subfaixa
					// Gravacao do Excedente por subfaixa para cada componente do DW2, na tabela DY2
					cChave := cFolder + aCols[nX][1]
					if (nPosDY2:= Ascan( aColsDY2, { |x| x[1]+x[2] == cChave })) > 0
						DY2->(DbSetOrder(1))
						If Len(aColsDY2[nPosDY2,3]) > 0 .and. !GdDeleted(Len(aColsDY2[nPosDY2,3]) ,aColsDY2[nPosDY2,4],aColsDY2[nPosDY2,3]) 
							If !DY2->(MsSeek(xFilial("DY2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+cFolder+aCols[nX][1]+M->DVC_CODNEG))
								RecLock("DY2",.T.)
								DY2->DY2_FILIAL := xFilial("DY2")
								DY2->DY2_TABFRE := M->DVC_TABFRE
								DY2->DY2_TIPTAB := M->DVC_TIPTAB
								DY2->DY2_CDRORI := M->DVC_CDRORI
								DY2->DY2_CDRDES := M->DVC_CDRDES
								DY2->DY2_CODCLI := M->DVC_CODCLI
								DY2->DY2_LOJCLI := M->DVC_LOJCLI
								DY2->DY2_SEQTAB := M->DVC_SEQTAB
								DY2->DY2_CODPRO := M->DVC_CODPRO
								DY2->DY2_SERVIC := M->DVC_SERVIC
								DY2->DY2_CODPAS := cFolder // aFolder[n1Cnt,1]
								DY2->DY2_ITEDVD := aCols[nX][1]
								DY2->DY2_CODNEG := M->DVC_CODNEG
							Else
								RecLock("DY2",.F.)
							EndIf     		
							For nI := 1 To Len(aColsDY2[nPosDY2,4])
								If aColsDY2[nPosDY2,4,nI,10] != 'V'
									DY2->(FieldPut(FieldPos(aColsDY2[nPosDY2,4,nI,2]),aColsDY2[nPosDY2,3,1,nI]))
								EndIf
							Next
							MsUnlock()
						Else	
							// Excedente por Subfaixa
							// Exclusao do item de Excedente se foi marcado para exclusao ou se o valor estiver zerado
							DY2->(DbSetOrder(1))
							If DY2->(MsSeek(xFilial("DY2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+cFolder+aCols[nX][1]+M->DVC_CODNEG))
								RecLock("DY2",.F.)
								DY2->(DbDelete())
								MsUnlock()
							Endif	
						Endif	
				   Endif
				EndIf			
				
			ElseIf nOpcx == 4 //-- Se For Alteracao e a Linha estiver deletada
				DVD->(dbSetOrder(1))
				If  DVD->(MsSeek(xFilial("DVD") + M->DVC_TABFRE + M->DVC_TIPTAB +M->DVC_CDRORI + ;
					M->DVC_CDRDES + M->DVC_CODCLI+ M->DVC_LOJCLI + M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+cFolder+aCols[nX][1]+M->DVC_CODNEG))
					RecLock("DVD",.F.)
					dbDelete()
					MsUnLock()
				EndIf
				//-- Deleta as sub-faixas

				// Excedente por Subfaixa
				// Exclusao de todos os excedentes da sub faixa que sera apagada abaixo
				DY2->(DbSetOrder(2))
				DY2->(MsSeek(cChaveDY2 := xFilial("DY2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_CODNEG+M->DVC_SERVIC+cFolder+aCols[nX][1]))
				Do While DY2->( ! Eof()) .and. cChaveDY2 == DY2->(xFilial("DY2")+DY2_TABFRE + DY2_TIPTAB + DY2_CDRORI + DY2_CDRDES + DY2_CODCLI + DY2_LOJCLI + DY2_SEQTAB + DY2_CODPRO) + DY2->DY2_CODNEG + DY2->(DY2_SERVIC + DY2_CODPAS + DY2_ITEDVD )
					RecLock("DY2",.F.)
					DY2->(DbDelete())
					MsUnlock()
					DY2->( Dbskip())
				Enddo

				DW2->(dbSetOrder(1))
				If DW2->(MsSeek(xFilial("DW2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+;
					M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+cFolder+aCols[nX][1]+M->DVC_CODNEG))
					RecLock("DW2",.F.)
					dbDelete()
					MsUnLock()
				EndIf

			EndIf
		Next nX
		
	Next nLoop
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for Inclusao de Ajuste,Grava a Tabela para as Regioes de Des-³
	//³tino que fazem parte dos Estados Informados no Botao da Enchoice³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcx == 3 .And. nGravouUF == 0
		nGravouUF++
		CursorWait()
		MsgRun(OemToAnsi( STR0016 ),,{|| TMA011RegDes(nOpcx) }) //Aguarde, gerando ajustes para os Estados informados...
		CursorArrow()
	EndIf
	
ELSE
	
	RecLock( cMasterAlias, .F.)
	DbDelete()
	MsUnLock()
	
	( cSlaveAlias )->( DbSetOrder( nSlaveOrder ) )
	( cSlaveAlias )->( MsSeek( cSlaveSeek	) )
	( cSlaveAlias )->( DbEval( { ||	RecLock( cSlaveAlias, .F. ), DbDelete(), MsUnlock() },bSlaveFor, ;
							{ || 	!Eof() .AND. Eval( bSlaveWhile ) = cSlaveSeeK } ) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Excluir o Complemento do Ajuste de Frete                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DVO->( DbSetOrder( 1 ) )
	If DVO->( MsSeek( xFilial( "DVO" )+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB) )
		DVO->( DbEval( { ||	RecLock( "DVO", .F. ), DbDelete(), MsUnlock() },, ;
					{ || DVO_FILIAL+DVO_CODCLI+DVO_LOJCLI+DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_SEQTAB == ;
					xFilial( "DVO" )+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB} ) )		
	EndIf

	// Excedente por Subfaixa
	// Exclusao de todas os Excedente das subfaixas que serao apagadas abaixo
	DY2->(DbSetOrder(1))
	DY2->(MsSeek(cChaveDY2 := xFilial("DY2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB))
	Do While DY2->( ! Eof()) .and. cChaveDY2 == DY2->(xFilial("DY2")+DY2_TABFRE + DY2_TIPTAB + DY2_CDRORI + DY2_CDRDES + DY2_CODCLI + DY2_LOJCLI + DY2_SEQTAB )
		RecLock("DY2",.F.)
		DY2->(DbDelete())
		MsUnlock()
		DY2->( Dbskip())
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Excluir Ajuste de TDA                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DWZ->( DbSetOrder( 1 ) )
	If DWZ->( MsSeek( xFilial( "DWZ" )+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB) )
		DWZ->( DbEval( { ||	RecLock( "DWZ", .F. ), DbDelete(), MsUnlock() },, ;
					{ || DWZ_FILIAL+DWZ_CODCLI+DWZ_LOJCLI+DWZ_TABFRE+DWZ_TIPTAB+DWZ_CDRORI+DWZ_CDRDES+DWZ_SEQTAB == ;
					xFilial( "DWZ" )+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB} ) )		
	EndIF						
	
	//--- Exclui ajustes DJT
	If AliasInDic("DJT")
		DJT->(dbSetOrder(1))
		If DJT->(MsSeek(xFilial("DJT")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+ M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO + M->DVC_SERVIC  ))
			DJT->( DbEval( { ||	RecLock( "DJT", .F. ), DbDelete(), MsUnlock() },, ;
			{ || DJT_FILIAL+DJT_CODCLI+DJT_LOJCLI+DJT_TABFRE+DJT_TIPTAB+DJT_CDRORI+DJT_CDRDES+DJT_SEQTAB+DJT_CODPRO + DJT_SERVIC == ;
			xFilial("DJT")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+ M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+ M->DVC_CODPRO+M->DVC_SERVIC  } ) )		
		EndIf
	EndIf
	//-- Deleta as sub-faixas
	DW2->(dbSetOrder(1))
	If DW2->(MsSeek(cSeek := xFilial("DW2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB))
		While DW2->(!Eof()) .And. DW2->DW2_FILIAL + DW2->DW2_TABFRE + DW2->DW2_TIPTAB + DW2->DW2_CDRORI + DW2->DW2_CDRDES + DW2->DW2_CODCLI + DW2->DW2_LOJCLI + DW2->DW2_SEQTAB == ;
											xFilial("DW2")  + M->DVC_TABFRE   + M->DVC_TIPTAB   + M->DVC_CDRORI   + M->DVC_CDRDES   + M->DVC_CODCLI   + M->DVC_LOJCLI   + M->DVC_SEQTAB
			RecLock("DW2",.F.)
			dbDelete()
			MsUnLock()
			DW2->(DbSkip())
		EndDo
	EndIf

EndIf

MsUnLockAll()
RestArea( aArea )
RestArea(aAreaDVC)

Return NIL
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Ok  ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Tudo antes da Gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Ok(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1  - Folder Atual                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³Valida Folder a Folder comecando pelo atual                 ³±±
±±³          ³Checa se existe PELO MENOS UM Folder preenchido             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011Ok( nSourceFolder )

Local lReturn    := .F.
Local aSavHead   := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local aSavFold   := {}
Local nSavN      := n
Local nLoop      := 0
Local lEmpty     := .F.
Local lOk        := .F.
Local nSavFolder := nFolder

If l011TudOk ==  Nil
	l011TudOk  := Iif(ValType(l011TudOk)=="L",l011TudOk,ExistBlock("A011TUDOK"))
EndIf

If (nOpcao == 3 .Or. nOpcao == 4)
	If Empty(M->DVC_CODNEG)
		Help(' ', 1, 'TMSA04058') //-- Não é permitido que o código da negociação fique em branco.	
		Return ( .F. )	
	EndIf
EndIf

If nOpcao == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe a Tabela Mae                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DT0->(dbSetOrder(1))
	If !DT0->(MsSeek(xFilial('DT0')+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+cProdOri))
	   Help("",1,"TMSA01103") //Tabela Mae Nao Encontrada !!!                        
		Return ( .F. )
	EndIf
	
	If M->DVC_SEQTAB <> StrZero(1, Len(DVC->DVC_SEQTAB))
		If !MsgYesNo( STR0017 ) //Ja Existe Ajuste cadastrado com estas informacoes. Sera criada uma nova Sequencia para este Ajuste. Confirma ?
			Return ( .F. )
		EndIf
	EndIf		
		
EndIf

aFolder[oFolder:nOption][5] := Aclone(aCols)
aSavFold := aClone(aFolder)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum campo obrigatorio em Branco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
															Empty( aCols[1][aPosCol[2]] ), ;
															lEmpty := .T.	, NIL ) } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se estah vazio e nao sofreu modificacao deleta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
	aCols[1][Len(aHeader)+1] := .T.
EndIf

lEmpty := .T.

If  aFolder[nSourceFolder][8]:TudoOk()
	
	aFolder := AClone(aSavFold)
	aFolder[nSourceFolder][4] 	:= aClone( aHeader )
	aFolder[nSourceFolder][5] 	:= aClone( aCols )
	n := Max(aFolder[nSourceFolder][8]:oBrowse:nAt,1)
	
	lEmpty  := Iif( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. } ) = 0, lEmpty )
	
	lReturn := .T.
	
	For nLoop := 1 TO Len( aFolder )
		
		If nLoop == nSourceFolder
			Loop
		EndIf
		aHeader := aClone( aFolder[nLoop][4] )
		aCols   := aClone( aFolder[nLoop][5] )
		n       := Max(aFolder[nLoop][8]:oBrowse:nAt,1)
		nFolder := nLoop
		lOK     :=.F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe algum campo obrigatorio em Branco ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aeval( aFolder[nLoop][8]:aPosCol, { |aPosCol| 	If ( Empty( aCols[1][aPosCol[2]] ), ;
														lOK := .T.	, NIL ) } )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se esta vazio e nao sofreu modificacao deleta ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOK .AND. ! aFolder[nLoop][8]:lChgField
			aCols[1][Len(aHeader)+1] := .T.
		EndIf
		
		lOK := .F.
		
		If ( aFolder[nLoop][8]:TudoOk() )
			aFolder := AClone(aSavFold)
			lEmpty  := Iif( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. }  ) = 0, lEmpty )
		Else
			aFolder := AClone(aSavFold)
			lReturn := .F.
			Exit
		EndIf
		
	Next nLoop
	
EndIf

If lReturn .AND. lEmpty
	Help(" ",1,"TMSA01006") //"Todas as 'Pastas' estao vazias !!"
	lReturn := .F.
EndIf

If lReturn .And. l011TudOk
	lReturn:=ExecBlock("A011TUDOK",.F.,.F.)
	If ValType(lReturn) # "L"
		lReturn:=.T.
	EndIf
EndIf

aFolder := AClone(aSavFold)
aHeader := aClone(aSavHead)
aCols   := aClone(aSavCols)
N       := nSavN
nFolder := nSavFolder

Return( lReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Bar ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice bar especifica                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Bar(ExpO1,ExpB1,ExpB2,ExpN1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpB1  - Dialog do Window                                   ³±±
±±³          ³ExpB2  - Evento Ok                                          ³±±
±±³          ³ExpB3  - Evento Cancel                                      ³±±
±±³          ³ExpN1  - Opcao da Mbrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Objeto EnchoiceBar                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011Bar( oDlg, bOk, bCancel, nOpcx )

Local aButtons     := {}
Local nCntFor      := 0
Local aSomaButtons := {}
Static aSetKey     := {}

aSetKey     := {}

//-- Nao mostra os Botoes da Enchoice na Exclusao
If nOpcx <> 5                                                                       
	Aadd(aSetKey, {VK_F4 , { || TMSA011Obs() }}) 
	Aadd(aButtons,	{'PLNPROP',{|| TMSA011Obs() }, STR0018 , STR0019 }) //"Observacoes do Componente - <F4>"
	
	Aadd(aSetKey, {VK_F5 , { || TMSA011Min(nOpcx) }} )
	Aadd( aButtons, { "PRECO", { || TMSA011Min( nOpcx ) }, STR0020 , STR0021 } ) //"Complemento do Ajuste de Frete - <F5>"

	If nOpcao == 3
		Aadd(aSetKey, { VK_F6 , { || TMSA011UF() }} )
		Aadd(aButtons	, {"WEB", {|| TMSA011UF()}, STR0022 , STR0023 }) //"Regioes de Destino - <F6>"
	EndIf

	Aadd(aSetKey, { VK_F7  , { || TMSA011Cont() }} )
	Aadd(aSetKey, { VK_F8  , { || TMSA011Des(nOpcx) }} )
	Aadd(aButtons	, {"EDIT",	  {|| TMSA011Cont()}, STR0024 , STR0025 }) //"Contrato do Cliente - <F7>"
	Aadd(aButtons	, {"DESTINOS",{|| TMSA011Des(nOpcx)} , STR0026 , STR0027 }) //"Destinos de Cálculo - <F8>"
	If nOpcao <> 3   
		Aadd(aSetKey, { VK_F9  , { || TMA011Vis()}} ) 
		Aadd(aButtons  , {'BMPORD',  {|| TMA011Vis()}   , STR0028 , STR0029 }) //"Tabela de Frete - <F9>"
	EndIf      
	Aadd(aSetKey, { VK_F10  , { || TMSA011SFx(nOpcx) }} ) 
	Aadd( aButtons, { "RELATORIO", {|| TMSA011SFx(nOpcx) }, STR0030 , STR0031 } ) //"Ajuste da Tabela de Frete - Subfaixa - <F10>"
	Aadd(aSetKey, { VK_F11  , { || TMSA011TDA(nOpcx) }} ) 
	Aadd( aButtons, { "SIMULACA", {|| TMSA011TDA(nOpcx) }, STR0051 , STR0050 } ) //'Ajuste Base Componente Tx. Dif. Acesso - <F11>'
	
	If AliasInDic("DJT")
		Aadd( aButtons, { "SIMULACA", {|| TMSA011TRT(nOpcx) }, "Ajuste Base % Por Componente" , "Ajuste Base % Por Componente" } ) 
	EndIf
	
EndIf           

//-- Botao de atalho para a rotina 'Tabela de Frete por Destinatário'                                              
If nOpcx == 2
 	AAdd( aButtons, { "FRETEDEST", {|| TMSA012Mnt(,,1,,DVC->DVC_TABFRE,DVC->DVC_TIPTAB) }, STR0058 , STR0057 } ) //'Ajuste da Tabela de Frete' - 'Tab.Frete Dest.' 
EndIf	

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM011BUT')
	aSomaButtons:=ExecBlock('TM011BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCntFor:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCntFor])
		Next
	EndIf
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

Return ( EnchoiceBar( oDlg, bOK, bCancel,, aButtons ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Loc ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Localizador de Folder Preenchido                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Loc(ExpN1,ExpO1,ExpL1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1  - Dialog do Window                                   ³±±
±±³          ³ExpO1  - Objeto Folder                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³  - Na Inclusao deleta TODOS os folders menos o 1           ³±±
±±³          ³  - Caso contrario Localiza o primeiro folder preenchido    ³±±
±±³          ³  - Se o Folder 1 nao estiver preenchido :                  ³±±
±±³          ³  - Deleta o Folder 1                                       ³±±
±±³          ³  - Forca Troca do Folder para o Primeiro Preenchido        ³±±
±±³          ³  - Troca Folder dentro do objeto Folder                    ³±±
±±³          ³  - Refresh para refletir a mudanca no Objeto Folder        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011Loc( nOpcx, oFolder)

Local nI
Local nJ
Local nFirstFolderOk := 0
Local lEmpty

For nI := 1 TO Len( aFolder )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Candidato a delecao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Len( aFolder[nI][5] ) == 1
		lEmpty := .F.
		
		For nJ := 1 TO Len( aFolder[nI][8]:aPosCol ) // Valida Obrigat
			If !lEmpty .AND. Empty( aFolder[nI][5][1][aFolder[nI][8]:aPosCol[nJ, 2]] )
				lEmpty := .T.
				Exit
			EndIf
		Next nJ
		
		If lEmpty
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta porque a FillGetDados colocou para Inclusao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			aFolder[nI][5][1][Len( aFolder[nI][4] ) + 1] := .T.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao eh o Folder 1 e ainda nao Localizou nenhum ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
		ElseIf nFirstFolderOk == 0
			nFirstFolderOk := nI
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se tem mais de uma linha e nao eh o Folder 1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	ElseIf nFirstFolderOk == 0
		nFirstFolderOk := nI
	EndIf
	
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita apenas o 1o.  Folder    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Aeval( aFolder, { |aFold| 	aFold[8]:oBrowse:lDisablePaint := .F. } )

aFolder[1][8]:oBrowse:lDisablePaint := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Primeiro Folder Preenchido nao eh o 1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFirstFolderOk > 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o Folder 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aCols[1][Len(aHeader)+ 1] := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Forca Troca do Folder para o primeiro preenchido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	TMSA011Chg( nFirstFolderOk, 1 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Troca o Folder no Objeto Folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oFolder:nOption := nFirstFolderOk
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dah um Refresh para efetivar a mudanca ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oFolder:Refresh()
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Padrao - Folder 1 estah preenchido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aFolder[1][8]:oBrowse:Refresh(.T.)
	
EndIf

Return NIL
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Fol ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega todos os Folder no aFolder                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Fol(nOpcx)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1      - Opcao Selecionada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011Fol(nOpcx)

Local nPosValor,nSeek,nPosValAju,nPosPerAju
Local aHTmp,aArea,aBacNoFields,aAlter
Local cChave,cCampo,cCdrOri,cCdrDes,cCdrOTab,cCdrDTab,cCodPro,cDescComp  
Local cTabTar    := ''
Local nPosCalPas := Ascan(aHeaderDVO, {|x| Alltrim(x[2]) == "DVO_CALPAS"})
Local nPosDesPas := Ascan(aHeaderDVO, {|x| Alltrim(x[2]) == "DVO_DESPAS"})
Local nPosCodPas := Ascan(aHeaderDVO, {|x| Alltrim(x[2]) == "DVO_CODPAS"})
Local cSeekDVE := ''
Local aAreaDT0 := DT0->(GetArea())
Local aAreaDVD := DVD->(GetArea())
Local aAreaDT1 := DT1->(GetArea())
Local lTaxa    := .F.
Local cSeekKey :=	 xFilial("DVD")+M->DVC_TABFRE+M->DVC_TIPTAB +M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO                                 
Local aNoFields := {"DVD_TABFRE","DVD_CDRORI","DVD_CDRDES","DVD_TIPTAB","DVD_CODPAS","DVD_CODNEG","DVD_CODCLI","DVD_LOJCLI","DVD_SEQTAB","DVD_RGDTAB","DVD_CODPRO","DVD_CODNEG","DVD_SERVIC"}
Local aMsgErr   := {}
Local lAchou    := .F.
Local nAster    := 0
Local nCntFor
Local nCont     := 0
Local aDVDStru  := FwFormStruct(2,"DVD")

aDadosComp := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for AJUSTE, seta aAlter e aNoFields ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx <> 4
	aAlter 	:= {"DVD_VALATE","DVD_VALOR","DVD_FATPES","DVD_INTERV", "DVD_VALAJU", "DVD_PERAJU"}
EndIf

aFolder := {}

DVE->( DbSetOrder( 1 ) )
DVE->( MsSeek( cSeekDVE := xFilial("DVE") + M->DVC_TABFRE + M->DVC_TIPTAB ) )

Do While DVE->( !Eof() .And. DVE_FILIAL + DVE_TABFRE + DVE_TIPTAB == cSeekDVE )
	
	aHeader := {}
	aCols   := {}
	cCdrOTab:=''
	cCdrDTab:=''
	aBacNoFields := Aclone(aNoFields)
	
	DT3->(dbSetOrder(1))
	DT3->(MsSeek( xFilial( "DT3" ) + DVE->DVE_CODPAS ) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Na opcao de Inclusao,sera aberta a Tela de Complemento do Ajuste de Frete     ³
	//³(DVO), na Entrada do programa,para que o usuario informe os camponentes  que  ³
	//³serao calculados. Apos a confirmacao da Tela, o folder sera montado apenas    ³
	//³com os componentes que tenham o campo "DVO_CALPAS" (Calcula Pasta) == Sim"    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcx == 3
		nSeek :=Ascan(aColsDVO, {|x|  AllTrim(x[nPosCodPas]) == AllTrim(DT3->DT3_CODPAS) .And. x[nPosCalPas] == '1' })
		If nSeek == 0
			DVE->(dbSkip())
			Loop
		EndIf
	EndIf
		
	If DT3->DT3_FAIXA <> StrZero(1, Len(DT3->DT3_TIPFAI))
		AAdd(aBacNoFields,'DVD_FATPES')
	EndIf                     

	//-- Qdo utilizar sub-faixa, nao sera apresentado 'Valor' e 'Fracao'.
	If !Empty(DT3->DT3_FAIXA2)
		AAdd(aBacNoFields,'DVD_VALOR' )
		AAdd(aBacNoFields,'DVD_INTERV')
		AAdd(aBacNoFields,'DVD_VALAJU')
		AAdd(aBacNoFields,'DVD_PERAJU')
	EndIf
	
   cDescComp := AllTrim(DT3->DT3_DESCRI)
        
	For nCont := 1 to Len(aDVDStru:aFields)	
		If Ascan( aBacNoFields,GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_CAMPO")) == 0 						
			Aadd( aHeader,{GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_TITULO"),GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_CAMPO"),;
			GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_PICTURE"),GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_TAMANHO"),GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_DECIMAL"),;
			GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_VALID"  ),GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_USADO"  ),GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_TIPO"),;
			GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_ARQUIVO"),GetSX3Cache(aDVDStru:aFields[nCont][1], "X3_CONTEXT")} ) 	
		EndIf					
	Next nCont                                                      
	
	// Se for Inclusao ou Alteracao de Ajuste procura a Tabela Mae (DT0) para carregar o aCols
	// do Ajuste com os Itens da Tabela Mae (DT1)
	If nOpcx == 3 .Or. nOpcx == 4  
		DTG->(dbSetOrder(1))
		DVD->(dbSetOrder(1))
		DT0->(dbSetOrder(1))
		DT1->(dbSetOrder(1))
		If nOpcx == 3
			DT0->(MsSeek(cChave:=xFilial('DT0')+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO))
		Else
			DVD->( MsSeek( xFilial("DVD") + M->DVC_TABFRE + M->DVC_TIPTAB + M->DVC_CDRORI + M->DVC_CDRDES + M->DVC_CODCLI + M->DVC_LOJCLI +;
			M->DVC_SEQTAB+ M->DVC_CODPRO+ M->DVC_SERVIC+DVE->DVE_CODPAS+M->DVC_CODNEG))
			DT0->( MsSeek(cChave:=xFilial('DT0')+M->DVC_TABFRE+M->DVC_TIPTAB+DVD->DVD_RGOTAB+DVD->DVD_RGDTAB+DVD->DVD_PRDTAB))
		EndIf
		
		cTabTar := DT0->DT0_TABTAR
		 		
		//-- Se Nao Encontrou o Componente na Tabela Mae, procura nas Regioes Superiores.
		//-- Isto porque, existem componentes que, ao inves, de serem Cadastrados para todas
		//-- as Regioes, sao cadastrados apenas para a "Regiao Pai".Sao chamadas de Taxas Estaduais.
		lTaxa   := .F.  
		nAster  := 0
      cCdrOri := M->DVC_CDRORI
      cCdrDes := M->DVC_CDRDES
      cCodPro := M->DVC_CODPRO		
		If !DTG->(MsSeek(xFilial("DTG") + M->DVC_TABFRE + M->DVC_TIPTAB+cTabTar+DVE->DVE_CODPAS)) .And. ;
			!DT1->( MsSeek( cChave+DVE->DVE_CODPAS ) )
			If TmsTabela( aMsgErr, M->DVC_TABFRE,  M->DVC_TIPTAB, , @cCdrOri, @cCdrDes , , , @cCodPro, M->DVC_SERVIC, @cTabTar, DT3->DT3_TAXA, DVE->DVE_CODPAS, DT3->DT3_PSQTXA, , , , , , , M->DVC_CODNEG )
			   lTaxa    := .T.
			   nAster   := 1
				cSeekKey :=	 xFilial("DT0")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+cCodPro       
				AADD(aDadosComp, {DVE->DVE_CODPAS, {cCdrOri, cCdrDes, cCodPro} })
			EndIf
			If ! Empty( aMsgErr )
				TmsMsgErr( aMsgErr )
				DVE->( dbSkip() )
				Loop
			EndIf
		Else                                                                                		
			cSeekKey :=	 cChave // xFilial("DVD")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+ M->DVC_CDRDES+M->DVC_CODPRO					
			If nOpcx == 3
	  			AADD(aDadosComp, {DVE->DVE_CODPAS, {M->DVC_CDRORI, M->DVC_CDRDES, M->DVC_CODPRO} })
	  		Else 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se For Alteracao, posicionar na Tabela Mae utilizando os campos             ³
				//³ DVD_RGDTAB / DVD_PRDTAB de todos os Componentes do Ajuste                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  		
				AADD(aDadosComp, {DVE->DVE_CODPAS, {DVD->DVD_RGOTAB, DVD->DVD_RGDTAB, DVD->DVD_PRDTAB} })
	  		EndIf	
		EndIf
		
      //-- Se o componente for taxa, os seus valores minimos poderao estar cadastrados no estado. Neste caso,		
		//-- o seek no DVO sera' dado com as regioes de origem / destino retornados pela funcao TMSTabela().
      If nOpcx == 3 .And. lTaxa 
			nSeek :=Ascan(aColsDVO, {|x|  AllTrim(x[nPosCodPas]) == AllTrim(DT3->DT3_CODPAS) })			         
			If nSeek > 0 // Preencher os valores do Complemento do Ajuste de Frete com os valores da Tabela Mae
				DVO->(dbSetOrder(2))
				cSeekDVO := xFilial("DVO")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_CODNEG+M->DVC_SERVIC
				If !DVO->( MsSeek( cSeekDVO + DT3->DT3_CODPAS ) ) .Or. (Empty(DVO->DVO_PERMIN) .And. Empty(DVO->DVO_PERAJU))
					cSeekDVO := xFilial("DVO")+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_CODNEG+M->DVC_SERVIC
					DVO->( MsSeek( cSeekDVO + DT3->DT3_CODPAS ) )					  
				EndIf			                                        
				If !DVO->(Eof())	
					For nCntFor := 1 To Len(aHeaderDVO)
						If	aHeaderDVO[nCntFor,10] != "V"
							aColsDVO[nSeek,nCntFor]:=DVO->(FieldGet(FieldPos(aHeaderDVO[nCntFor,2])))
						EndIf
					Next nCntFor						
					aColsDVO[nSeek][Len(aHeaderDVO)+1]:=.F.
				EndIf		
			EndIf	
		EndIf		
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o aCols do Ajuste com os Itens da Tabela Mae (DT1)                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		DT1->(dbSetOrder(1))
		If DT1->(MsSeek(cSeekKey+DVE->DVE_CODPAS))
			aHTmp   	 	   := Aclone(aHeader)
			aCols          := {}
			nPosValor      := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVD_VALOR' })
			nPosValAju     := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVD_VALAJU'})
			nPosPerAju     := Ascan(aHeader, {|x| Alltrim(x[2]) == "DVD_PERAJU"})
			While !DT1->(Eof()) .And. DT1->(DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS) == cSeekKey + DVE->DVE_CODPAS
				Aadd(aCols,Array(Len(aHTmp)+1))
				For nCntFor := 1 To Len(aHTmp)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 		//³ Troca o Prefixo do aHeader de DVD para DT1                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCampo := StrTran(aHTmp[nCntFor,2],"DVD",PrefixoCpo("DT1"))
					If DT1->(FieldPos(cCampo))> 0   //Nao Remover o FieldPos
						aHTmp[nCntFor,2] := cCampo
						If	aHTmp[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=DT1->(FieldGet(FieldPos(aHTmp[nCntFor,2])))
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHTmp[nCntFor,2])
						EndIf
					Else                                           
						aCols[Len(aCols),nCntFor]:=CriaVar(aHTmp[nCntFor,2])
					EndIf	
				Next nCntFor
//				aEval(aCols, {|x| x[GdFieldPos('DVD_TARIFA')]:= "2"})
				If nPosValor > 0
					aCols[Len(aCols)][nPosValor]   := DT1->DT1_VALOR
				EndIf
				If nPosPerAju > 0
					aCols[Len(aCols)][nPosPerAju]  := IIf( Empty( aCols[Len(aCols)][nPosPerAju]) , 100, aCols[Len(aCols)][nPosPerAju] )
				EndIf
				If nPosValAju > 0
					aCols[Len(aCols)][nPosValAju]  := ( DT1->DT1_VALOR * aCols[Len(aCols)][nPosPerAju] ) / 100
				EndIf
				aCols[Len(aCols),Len(aHTmp)+1] := .F.
				
				//-- Carrega Sub-Faixas
				TMA011SubFx("DW1",DVE->DVE_CODPAS,GDFieldGet('DVD_ITEM',Len(aCols)),,nOpcx)
				
				DT1->(dbSkip())
			EndDo  
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao encontrou o Item na Tab. Mae (DT1),procura na Tabela de Tarifas (DTG) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSeek := AsCan(aCols, {|x| !x[Len(x)]  .And. !Empty(x[GdFieldPos('DVD_VALATE')]) })
		If nSeek == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o campo Tabela de Tarifa estiver preenchido, carregar o acols com os     ³
			//³ componentes da Tabela de Tarifa (DTG).                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DTG->(dbSetOrder(1))
			If !Empty(cTabTar) .And. DTG->(MsSeek(xFilial("DTG") + M->DVC_TABFRE + M->DVC_TIPTAB+cTabTar+DT3->DT3_CODPAS))
				aHTmp  := Aclone(aHeader)
				aArea  := GetArea()
				aCols  := {}
				nPosValor      := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVD_VALOR'})
				nPosValAju     := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVD_VALAJU'})
				nPosPerAju     := Ascan(aHeader, {|x| Alltrim(x[2]) == "DVD_PERAJU"})
				dbSelectArea("DTG")
				Do While !Eof() .And. DTG_FILIAL+DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS == xFilial("DTG")+M->DVC_TABFRE+M->DVC_TIPTAB+cTabTar+DT3->DT3_CODPAS
					Aadd(aCols,Array(Len(aHTmp)+1))
					For nCntFor := 1 To Len(aHTmp)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Troca o Prefixo do AHeader de DVD para DTG                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCampo := StrTran(aHTmp[nCntFor,2],"DVD",PrefixoCpo("DTG"))
						If DTG->(FieldPos(cCampo))> 0   //Nao Remover o FieldPos
							aHTmp[nCntFor,2] := cCampo
							If	aHTmp[nCntFor,10] != "V"
								aCols[Len(aCols),nCntFor]:=FieldGet(FieldPos(aHTmp[nCntFor,2]))
							Else
								aCols[Len(aCols),nCntFor]:=CriaVar(aHTmp[nCntFor,2])
							EndIf
						Else
							aCols[Len(aCols),nCntFor] :=CriaVar(aHTmp[nCntFor,2])
						EndIf
					Next nCntFor
//					aEval(aCols, {|x| x[GdFieldPos('DVD_TARIFA')]:= "1"})
					If nPosValor > 0
						aCols[Len(aCols)][nPosValor]   := DTG->DTG_VALOR
					EndIf
					If nPosPerAju > 0
						aCols[Len(aCols)][nPosPerAju]  := IIf( Empty( aCols[Len(aCols)][nPosPerAju]) , 100, aCols[Len(aCols)][nPosPerAju] )
					EndIf
					If nPosValAju > 0
						aCols[Len(aCols)][nPosValAju]  := ( DTG->DTG_VALOR * aCols[Len(aCols)][nPosPerAju] ) / 100
					EndIf
					aCols[Len(aCols),Len(aHTmp)+1] := .F.

					//-- Carrega Sub-Faixas
					TMA011SubFx("DW0",DVE->DVE_CODPAS,GDFieldGet('DVD_ITEM',Len(aCols)),DTG->DTG_TABTAR,nOpcx)

					DTG->(dbSkip())
				EndDo
				RestArea(aArea)
			Else
				DVE->(dbSkip()) //-- Nao mostrar na Tela componentes vazios 
				Loop	
			EndIf
		EndIf
		
		//-- Monta o Array aFolder, adicionando o aCols e o aHeader
		TMA011AddFol(@aFolder, aHeader, aCols,  aAlter, cDescComp, cCdrOri, cCdrDes, cCdrOTab, cCdrDTab, cCodPro, nOpcx, nAster)
	EndIf // nOpcx==3 .Or. nOpcx==4

	//-- Se for Exclusao, o acols sera montado somente com os Itens gravados no DVD 
   //-- da Origem / Destino Informados ( Nao Chama a funcao TMSTabela() )
	
	//-- Se for Visualizacao, o acols sera montado com os Itens gravados no DVD.
   //-- Se Nao Encontrar os valores para a Origem/Destino informados, chama a TMSTabela().	 	
				
	//-- Se for Alteracao, o acols ja' esta' montado com os da Tabela Mae (DT1 ou DTG).
	//-- Sendo assim, procurar na Tabela de Ajuste (DVD) o Item do aCols e atualizar os
	//-- valores de acordo com o que foi gravado no DVD. Se Nao Encontrar os valores para
	//-- a Origem/Destino informados, chama a TMSTabela().		
	If nOpcx <> 3
		dbSelectArea("DVD")
		dbSetOrder(3)
		lAchou := .F.
		lTaxa  := .F.
		nAster := 0      
		cSeek:=M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODCLI+M->DVC_LOJCLI+M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_CODNEG+M->DVC_SERVIC+DT3->DT3_CODPAS
		If DVD->(MsSeek(xFilial('DVD')+cSeek))											        
		   cCdrOTab := DVD->DVD_RGOTAB
		   cCdrDTab := DVD->DVD_RGDTAB		   
			lAchou   := .T.					
		EndIf			
	   cCdrOri := M->DVC_CDRORI
	   cCdrDes := M->DVC_CDRDES		
	   cCodPro := M->DVC_CODPRO		
		//-- Na Visualizacao/Alteracao, se nao encontrar o componente cadastrado para a regiao origem e destino,
		//-- procura nas Regioes Superiores.		              		
		If !lAchou .And. (nOpcx == 2 .Or. nOpcx == 4)                        
			If TmsTabela( aMsgErr, M->DVC_TABFRE, M->DVC_TIPTAB, , @cCdrOri, @cCdrDes , , , @cCodPro, M->DVC_SERVIC,  , DT3->DT3_TAXA, DVE->DVE_CODPAS, DT3->DT3_PSQTXA, , , , , , , M->DVC_CODNEG )
				cSeek :=	 M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+ M->DVC_CODCLI+ ;
							 M->DVC_LOJCLI + M->DVC_SEQTAB + M->DVC_CODPRO + M->DVC_CODNEG + M->DVC_SERVIC + DT3->DT3_CODPAS
			   lTaxa   := .T.  							 
		 		If DVD->(MsSeek(xFilial("DVD")+cSeek))											        							 
				   cCdrOTab := DVD->DVD_RGOTAB
				   cCdrDTab := DVD->DVD_RGDTAB		   
				   lAchou := .T.  
	 			   //-- Coloca no Folder 1 asterisco, caracterizando que o componente e' originario de outra regiao				   
               nAster := 1
             
            //-- Na Visualizacao so' traz na tela os componentes gravados no Ajuste (DVD); Porem, se nao encontrou  
				//-- ajuste para o componente, verifica se o campo 'Pesq. Tabela' (DT3_PSQTAB) esta igual a 'Sim',
				//-- e carrega o acols deste componente com os dados da Tabela Mae.  
            ElseIf nOpcx ==2
            	If DT3->DT3_PSQTAB == StrZero(1, Len(DT3->DT3_PSQTAB )) .And. DT0->(MsSeek(xFilial("DT0")+cSeek))
					   lAchou := .T.  
		 			   //-- Coloca no Folder 1 asterisco, caracterizando que o componente e' originario de outra regiao				   
      	         nAster := 1            	
      	      EndIf  
            EndIf
            
				If !lAchou .And. nOpcx == 4
				   //-- A Opcao de Alteracao traz na Tela componentes cadastrados no DVD e traz tambem, caso exista, 
				   //-- componentes cadastrados na Tabela MAE, que NAO foram informados no ajuste.
					//-- Os 2 Asteriscos sao mostrados somente na opcao de ALTERACAO diferenciando para o usuario, 
					//-- os componentes que sao originados de outras regioes e que NAO estao sendo cobrados no ajuste                			
					//-- A mudanca da descricao do folder e' feita aqui, porque na alteracao, o folder ja' foi adicionado
					//-- anteriormente com os dados da Tabela mae.
					nSeek := Ascan(aFolder, { |x| Alltrim(x[1]) == DT3->DT3_CODPAS } )		
					If nSeek > 0	
						aFolder[nSeek][2] :=	 cDescComp  + ' ** '
					EndIf										
					//-- Preenche o vetor com a Origem e Destino, para dar seek no DTK 					
					nSeek:= Ascan(aFolder, {|x| x[1] == AllTrim(DT3->DT3_CODPAS) }) 
					If nSeek > 0
						aFolder[nSeek][12] := cCdrOri   //Regiao Origem do Componente
						aFolder[nSeek][13] := cCdrDes   //Regiao Destino do Componente 
					EndIf						
		 		EndIf
			EndIf		
		EndIf   
		
		If lAchou
			Do While DVD->(!Eof()) .And. xFilial('DVD')+cSeek == DVD->DVD_FILIAL + DVD->DVD_TABFRE + DVD->DVD_TIPTAB+ ; 
				DVD->DVD_CDRORI + DVD->DVD_CDRDES + DVD->DVD_CODCLI+ DVD->DVD_LOJCLI + DVD->DVD_SEQTAB+ ;
				DVD->DVD_CODPRO + DVD->DVD_CODNEG + DVD->DVD_SERVIC + DVD->DVD_CODPAS
								
				//-- Posiciona no DT0 de acordo com a Regiao Origem / Destino da Tabela Mae (DVD_RGOTAB/DVD_RGDTAB), 
				//-- para pegar a Tabela de Tarifa.
				DT0->(dbSetOrder(1))
				DT0->(MsSeek(xFilial("DT0")+ M->DVC_TABFRE + M->DVC_TIPTAB + DVD->DVD_RGOTAB + DVD->DVD_RGDTAB) )

				If nOpcx <> 5 .And. nOpcx <> 2
					nSeek := Ascan(aFolder[Len(aFolder)][5],{ |x| x[1] == DVD->DVD_ITEM })
				Else
					dbSelectArea("DVD")
					Aadd(aCols,Array(Len(aHeader)+1))
					For nCntFor := 1 To Len(aHeader)
						If	aHeader[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=FieldGet(FieldPos(aHeader[nCntFor,2]))
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
						EndIf
					Next nCntFor
					//-- O campo DVD_VALOR (Valor) e' virtual. Portanto, e' necessario procurar
					//-- seu valor na Tabela DT1/DTG
					nValor := 0          
					DTG->(dbSetOrder(1))					
					DT1->(dbSetOrder(1))
					If DT1->(MsSeek(xFilial("DT1")+ M->DVC_TABFRE + M->DVC_TIPTAB + DVD->DVD_RGOTAB + DVD->DVD_RGDTAB+DVD->DVD_PRDTAB+;
						DVE->DVE_CODPAS+GdFieldGet('DVD_ITEM',Len(aCols)) ))
						nValor := DT1->DT1_VALOR
					ElseIf DTG->(MsSeek(xFilial("DTG") + M->DVC_TABFRE + M->DVC_TIPTAB+DT0->DT0_TABTAR+DVE->DVE_CODPAS+GdFieldGet('DVD_ITEM',Len(aCols)) ))
						nValor := DTG->DTG_VALOR
					EndIf
					If GDFieldPos("DVD_VALOR") > 0
						GdFieldPut("DVD_VALOR", nValor , Len(aCols))
					EndIf
					If GDFieldPos("DVD_PERAJU") > 0
					  	GdFieldPut("DVD_PERAJU", GdFieldGet('DVD_PERAJU', Len(aCols)), Len(aCols))
					EndIf
					If GDFieldPos("DVD_VALAJU") > 0
						GdFieldPut("DVD_VALAJU", ( nValor * GdFieldGet("DVD_PERAJU",Len(aCols)) ) / 100, Len(aCols) )
					EndIf
					aCols[Len(aCols),Len(aHeader)+1]:=.F.
					nSeek := 0
				EndIf
				If nSeek > 0
					Aeval( aHeader, {|aCampo, nI| Iif(!AllTrim(aHeader[nI][2])$"DVD_VALOR.DVD_VALAJU", ;
											aCols[nSeek][nI] := If( aCampo[10] != 'V' .And. nOpcx<>3,;
											DVD->(FieldGet(FieldPos(aHeader[nI,2]))),  CriaVar(aHeader[nI,2], .T.) ),.T.) } )
					If GDFieldPos('DVD_VALOR') > 0 .And. GDFieldPos("DVD_VALAJU") > 0 .And. GDFieldPos("DVD_PERAJU") > 0
						nValor := GdFieldGet('DVD_VALOR', nSeek)
						GdFieldPut("DVD_VALAJU", ( nValor * GdFieldGet("DVD_PERAJU", nSeek) ) / 100,  nSeek )
					EndIf
					aFolder[Len(aFolder)][5] := Aclone(aCols)
				EndIf
				
				//-- Carrega Sub-Faixas
				TMA011SubFx("DW2",DVD->DVD_CODPAS,DVD->DVD_ITEM,DT0->DT0_TABTAR,nOpcx)

				DVD->(dbSkip())
			EndDo
			
			//-- Se for Visualizacao ou Exclusao Montar o Array aFolder, adicionando o aCols e o aHeader
			If nOpcx == 5 .Or. nOpcx == 2
				TMA011AddFol(@aFolder, aHeader, aCols, aAlter, cDescComp, cCdrOri, cCdrDes, cCdrOTab, cCdrDTab, cCodPro, nOpcx, nAster)				
			Else
				nSeek:= Ascan(aFolder, {|x| x[1] == AllTrim(DT3->DT3_CODPAS) }) 
				If nSeek > 0
					aFolder[nSeek][12] := cCdrOTab  //Regiao Origem da Tabela Mae
					aFolder[nSeek][13] := cCdrDTab  //Regiao Destino da Tabela Mae
				EndIf
			EndIf			
			
		EndIf
		
	Else
		//-- Qdo nao utiliza sub-faixas da tabela de frete.
		If Empty(DT3->DT3_FAIXA2)
			Aeval( aCols, { |x|  x[GdFieldPos('DVD_VALAJU')] := x[GdFieldPos('DVD_VALOR')],;
								 		 x[GdFieldPos('DVD_PERAJU')] := 100 } )
   	EndIf
	EndIf
	
	aBacNoFields := AClone(aNoFields)
	
	DVE->( dbSkip() )
	
EndDo

RestArea(aAreaDT0)
RestArea(aAreaDVD)
RestArea(aAreaDT1)

Return NIL
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Chg ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Troca de Folder                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Chg(ExpN1,ExpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - nTargetFolder - Folder Destino                      ³±±
±±³          ³ExpC2 -  nSourceFolder - Folder Atual                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. se a Troca de Folder foi permitida                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Checa a validacao da Getdados Atual e copia corretamente   ³±±
±±³          ³ aHeader e Acols dos Folders Atual e Destino                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011Chg( nTargetFolder, nSourceFolder )

Local nI
Local lRetorno
Local lEmpty 	:= .F.
Local aSavFold  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a GetDados nao esta deletada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Acols[1][Len(aHeader)+1]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os campos obrigatorios estao vazios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
	Empty( aCols[1][aPosCol[2]] ), ;
	lEmpty := .T.	, NIL ) } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se TODOS estiverem vazios e nao sofre modificacao ³
	//³ deleta para passar no 'OBRIGAT'   				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a Validacao da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSavFold := AClone(aFolder)

If ( lRetorno := aFolder[nSourceFolder][8]:TudoOk() )
	
	aFolder := AClone(ASavFold)
	
	aFolder[nSourceFolder][8]:oBrowse:lDisablePaint := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava aHeader e Acols do Afolder com as mudancas     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFolder[nSourceFolder][4] := aClone( aHeader )
	aFolder[nSourceFolder][5] := aClone( aCols )
	n := Max( aFolder[nTargetFolder][8]:oBrowse:nAt,1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava aHeader e Acols a partir do aFolder            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aClone( aFolder[nTargetFolder][4] )
	aCols   := aClone( aFolder[nTargetFolder][5] )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os campos obrigatorios estao vazios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lEmpty := .F.
	Aeval( aFolder[nTargetFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
	Empty( aCols[1][aPosCol[2]] ), ;
	lEmpty := .T.	, NIL ) } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se TODOS estiverem vazios e nao sofre modificacao ³
	//³ da RECALL porque esta funcao DELETOU !!           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If aCols[1][Len(aHeader)+1] .AND. lEmpty .AND. ;
		! aFolder[nTargetFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .F.
	EndIf
	
	aFolder[nTargetFolder][8]:oBrowse:lDisablePaint := .F.
	aFolder[nTargetFolder][8]:oBrowse:Refresh(.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta Variavel Private nFolder para o Folder Target ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nFolder := nTargetFolder
	
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011LinO³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Linha da Getdados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011LinOk()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Verifica se a Getdados possui INTERVALO de frete jah       ³±±
±±³          ³ existente em outra linha, ou seja, se houve ENTRELACAMENTO ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011LinOk()

Local lReturn     := .T.
Local nPosValAte	:= Ascan( aHeader, { |aField| aField[2] = "DVD_VALATE" } )
Local nPosFatPes	:= Ascan( aHeader, { |aField| aField[2] = "DVD_FATPES" } )
Local nValAte		:= aCols[n][nPosValAte]
Local nValPes   	:= Iif(nPosFatPes > 0, aCols[n][nPosFatPes], 0)

If !GDdeleted(n) .And. (lReturn:=MaCheckCols(aHeader,aCols,n))
	Do Case
		Case  n = 1 // Valida da primeira linha p/ baixo 
			lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.AND. ;
						(nValAte >= aLine[nPosValAte]	.Or.;
						IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) = 0			
		Case  n = Len( aCols ) // Valida da ultima linha p/ cima
			lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.AND. ;
			(nValAte <= aLine[nPosValAte]	.Or.;
			IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )   }, 1, Len( Acols ) - 1 ) = 0			
		OTHER	
			//-- Valida Acima e Abaixo 
	
			lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.AND. ;
									(nValAte <= aLine[nPosValAte] .Or. ;
									IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) = 0
			
			lReturn := lReturn .AND. ;
							Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .AND. ;
							(nValAte >= aLine[nPosValAte] .Or.;
							IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) = 0
	EndCase

	If !lReturn
		HELP(" ",1,"TMSA01007") //"Campo Ate'/Fator Peso Invalido ou ja existente"
	EndIf

	If lReturn .And. !GDdeleted(n)
		If nPosFatPes >0 .And. GDFieldGet('DVD_FATPES',n) < GDFieldGet('DVD_VALATE',n)
		   Help("", 1,"TMSA01008")  //"O Fator de Peso Nao pode ser menor do que o Peso ..."
		   lReturn := .F.
		EndIf
		//-- Valida sub-faixa do componente.
		If lReturn
			If !GDDeleted(n) .And. !TMSA011Vd2(aFolder[nFolder,1],GDFieldGet('DVD_ITEM',n))
				Help("",1,"TMSA01017") //"Nao foi informada a subfaixa para o item."
				lReturn := .F.
			EndIf
		EndIf
	EndIf

EndIf

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Min ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Complemento do Ajuste de Frete                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Min(ExpN1,ExpL1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpL1 - Valida se devera mostrar a Enchoice. Esta Enchoice  ³±±
±±³          ³      so estara disponivel na 1a. Tela de Inclusao do Ajuste³±±
±±³          ³      para que o usuario informe os Dados da Tabela Mae.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011Min( nOpcx, lEnchoice )

Local aArea 		:= GetArea()
Local aAreaDVC    := DVC->(GetArea())
Local aAlter      := {}
Local cSeekDVE    := ''
Local aOldaHeader	:= Aclone( aHeader )
Local aOldaCols	:= Aclone( aCols )
Local aPosEnch		:={}
Local IncOld      := Inclui
Local lRet        := .T.
Local nSeek       := 0
Local aNoFields	:= { "DVO_TABFRE", "DVO_SEQTAB", "DVO_CDRORI", "DVO_CDRDES", "DVO_TIPTAB", "DVO_CODCLI", "DVO_LOJCLI"}
Local aYesFields  := {}
Local nUsado      := 0
Local nOpc        := 0
Local nCntFor     := 0
Local nCont       := 0
Local nSavN       := Iif(Type('n')=="U",1,n)
Local oDlg, oGetD, oEnchoice				   			
Local lNoFields, lYesFields                    
Local nI              
Local cCdrOri, cCdrDes, cCdrOTab, cCdrDTab
Local nx
Local nPosCol		:= 0
Local oSize		:= FwDefSize():New( .T. )
Local aDVOStru  := FwFormStruct(2,"DVO")

Private cFolder
Default lEnchoice    := .F.

//-- Desabilita as Teclas
TmsKeyOff(aSetKey)	

AAdd(aAlter,'DVO_APLAJU')
AAdd(aAlter,'DVO_EXCMIN')
AAdd(aAlter,'DVO_VLRMIN')
AAdd(aAlter,'DVO_PERMIN')
AAdd(aAlter,'DVO_PERMAX')

IF lDVOVlrMax
	AAdd(aAlter,'DVO_VLRMAX')
EndIF

AAdd(aAlter,'DVO_VLREXC')
AAdd(aAlter,'DVO_PERAJU')
AAdd(aAlter,'DVO_INTERV') 

If l011Min ==  Nil
	l011Min  := Iif(ValType(l011Min)=="L", l011Min, ExistBlock("TMSA011MIN"))
EndIf

//-- Este ponto de Entrada foi criado com a finalidade de incluir/excluir os campos do DVC
//-- mostrados na tela de Complemento do Ajuste de Frete. Este Ponto de Entrada devera retornar
//-- o array aCposVis
If l011Min                                                 
	aCposVis := ExecBlock("TMSA011MIN", .F., .F., aCposVis)
	If ValType(aCposVis) <> "A"
		Return .F.
	EndIf
EndIf        

aHeader	:= {}
aCols		:= {}

lNoFields	:= .T.
lYesFields	:= .F.

If nOpcx <> 3
	AAdd(aNoFields,'DVO_APLAJU')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aHeaderDVO) == 0

	For nCont := 1 to Len(aDVOStru:aFields)	
		If Ascan( aNoFields, GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_CAMPO") ) == 0  
			++nUsado			
			Aadd( aHeader,{GetSX3Cache(aDVOStru:aFields[nCont][1] ,"X3_TITULO"),GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_CAMPO"),;
			GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_PICTURE"),GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_TAMANHO"),GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_DECIMAL"),;
			GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_VALID"  ),GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_USADO"  ),GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_TIPO"),;
			GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_ARQUIVO"),GetSX3Cache(aDVOStru:aFields[nCont][1], "X3_CONTEXT" )}) 
		EndIf		
									
	Next nCont     
Else
	aHeader := Aclone(aHeaderDVO)
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aCols para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DVO->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona PRIMEIRO aCols do DVO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsDVO)==0
	If nOpcx <> 3 .And. Len(aFolder) > 0
		For nI := 1 To Len( aFolder )                            
			cFolder  := aFolder[nI][1]	 // Componente	
			cCdrOri  := aFolder[nI][10] // Regiao Origem do Componente
			cCdrDes  := aFolder[nI][11] // Regiao Destino do Componente
			cCdrOTab := aFolder[nI][12] // Regiao Origem da Tabela Mae 
			cCdrDTab := aFolder[nI][13] // Regiao Destino da Tabela Mae 		
			cProduto := aFolder[nI][14] // Produto		
			If DVO->( MsSeek( xFilial( "DVO" )+ M->DVC_CODCLI + M->DVC_LOJCLI + M->DVC_TABFRE + M->DVC_TIPTAB + cCdrOri + ;
							cCdrDes + M->DVC_SEQTAB + cProduto + M->DVC_SERVIC + cFolder + M->DVC_CODNEG) )			
				Aadd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					If	aHeader[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=DVO->(FieldGet(FieldPos(aHeader[nCntFor,2])))
					Else
						aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
					EndIf
				Next nCntFor				
				DTK->(dbSetOrder(1))
				DTK->(MsSeek(xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOTab+cCdrDTab+M->DVC_CODPRO+cFolder))
				aCols[Len(aCols),GdFieldPos('DVO_VALOR')]  := DTK->DTK_VALOR
				aCols[Len(aCols),GdFieldPos('DVO_VALMIN')] := DTK->DTK_VALMIN
				
				IF lDVOValMax
			      aCols[Len(aCols),GdFieldPos('DVO_VALMAX')] := DTK->DTK_VALMAX
				EndIF

				aCols[Len(aCols),GdFieldPos('DVO_VLRMIN')] := (DVO->DVO_PERMIN * aCols[Len(aCols),GdFieldPos('DVO_VALMIN')]) / 100	

				IF lDVOVlrMax
					aCols[Len(aCols),GdFieldPos('DVO_VLRMAX')] := (DVO->DVO_PERMAX * aCols[Len(aCols),GdFieldPos('DVO_VALMAX')]) / 100	
				EndIF
				
				aCols[Len(aCols),GdFieldPos('DVO_VLREXC')] := (DVO->DVO_PERAJU * aCols[Len(aCols),GdFieldPos('DVO_VALOR')]) / 100
				//-- Se nao encontrou item no DVO, traz na tela o item desmarcado
				aCols[Len(aCols),Len(aHeader)+1]   := .F.
				//-- Campos Virtuais
				aCols[Len(aCols),GdFieldPos('DVO_EMINTB')] := DTK->DTK_EXCMIN
				aCols[Len(aCols),GdFieldPos('DVO_FRCTAB')] := DTK->DTK_INTERV
			ElseIf nOpcx <> 2	
				Aadd( aCols, Array( nUsado + 1 ) )
				Aeval( aHeader, {|aCampo, nI|	aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],.T.) } )				
				DTK->(dbSetOrder(1))
				DTK->(MsSeek(xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOTab+cCdrDTab+M->DVC_CODPRO+cFolder))
				aCols[Len(aCols),GdFieldPos('DVO_VALOR')]  := DTK->DTK_VALOR
				aCols[Len(aCols),GdFieldPos('DVO_VALMIN')] := DTK->DTK_VALMIN

				IF lDVOValMax
					aCols[Len(aCols),GdFieldPos('DVO_VALMAX')] := DTK->DTK_VALMAX
				EndIF

				aCols[Len(aCols),GdFieldPos('DVO_VLRMIN')] := (DVO->DVO_PERMIN * aCols[Len(aCols),GdFieldPos('DVO_VALMIN')]) / 100		

				IF lDVOVlrMax
					aCols[Len(aCols),GdFieldPos('DVO_VLRMAX')] := (DVO->DVO_PERMAX * aCols[Len(aCols),GdFieldPos('DVO_VALMAX')]) / 100						
				EndIF

				aCols[Len(aCols),GdFieldPos('DVO_VLREXC')] := (DVO->DVO_PERAJU * aCols[Len(aCols),GdFieldPos('DVO_VALOR')]) / 100														
				//-- Se nao encontrou item no DVO, traz na tela o item deletado 
				aCols[Len(aCols),Len(aHeader)+1]   := .T.
				//-- Campos Virtuais
				aCols[Len(aCols),GdFieldPos('DVO_EMINTB')] := DTK->DTK_EXCMIN
				aCols[Len(aCols),GdFieldPos('DVO_FRCTAB')] := DTK->DTK_INTERV
			EndIf
		Next nI		
		
      //-- Salva o aCols
		aColsDVO := AClone(aCols)        
		                  
		//-- Desmarca todos os itens do aCols
		aEval(aCols, {|x| x[Len(x)] := .F. }) 
		
	Else                   	
	
		Inclui := .T.
		
		DVE->( DbSetOrder( 1 ) )
		DVE->( MsSeek( cSeekDVE := xFilial("DVE") + M->DVC_TABFRE + M->DVC_TIPTAB ) )
		
		Do While DVE->( !Eof() .And. DVE_FILIAL + DVE_TABFRE + DVE_TIPTAB == cSeekDVE )
			
			DT3->(dbSetOrder(1))
			DT3->(MsSeek( xFilial( "DT3" ) + DVE->DVE_CODPAS ))
			
			//-- Se o componente for "Praca de Pedagio" ou o componente for calculado por "Cliente Destinatário" ou "TDA x Região", nao devera aparecer no aCols
		    If DT3->DT3_TIPFAI == StrZero(9, Len(DT3->DT3_TIPFAI)) .Or. DT3->DT3_TIPFAI == "15" .Or. DT3->DT3_TIPFAI == "18"
		   	   DVE->( DbSkip() )                                                            						
			   Loop	
		    EndIf
			cFolder := DVE->DVE_CODPAS 
			Aadd( aCols, Array( nUsado + 1 ) )
			Aeval( aHeader, {|aCampo, nI|	aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],.T.) } )
			aCols[Len(aCols),nUsado+1]:=.F.
			IF lDVOValMax
				Aeval( aCols, {|x, nI| IIf(Empty(aCols[nI,GdFieldPos('DVO_DESPAS')]),aCols[nI,GdFieldPos('DVO_DESPAS')]:=DT3->DT3_DESCRI,.T.),;
					 IIf(Empty(aCols[nI,GdFieldPos('DVO_CODPAS')]),aCols[nI,GdFieldPos('DVO_CODPAS')]:=DT3->DT3_CODPAS,.T.),;
			       aCols[nI,GdFieldPos('DVO_VALMIN')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_VALMIN"),;
                 aCols[nI,GdFieldPos('DVO_VALMAX')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_VALMAX"),;
  			       aCols[nI,GdFieldPos('DVO_VALOR')] :=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_VALOR"),; 
			       aCols[nI,GdFieldPos('DVO_EMINTB')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_EXCMIN"),;
  			       aCols[nI,GdFieldPos('DVO_FRCTAB')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_INTERV") })
	     Else
				Aeval( aCols, {|x, nI| IIf(Empty(aCols[nI,GdFieldPos('DVO_DESPAS')]),aCols[nI,GdFieldPos('DVO_DESPAS')]:=DT3->DT3_DESCRI,.T.),;
					 IIf(Empty(aCols[nI,GdFieldPos('DVO_CODPAS')]),aCols[nI,GdFieldPos('DVO_CODPAS')]:=DT3->DT3_CODPAS,.T.),;
			       aCols[nI,GdFieldPos('DVO_VALMIN')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_VALMIN"),;
  			       aCols[nI,GdFieldPos('DVO_VALOR')] :=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_VALOR"),; 
			       aCols[nI,GdFieldPos('DVO_EMINTB')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_EXCMIN"),;
  			       aCols[nI,GdFieldPos('DVO_FRCTAB')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DTK_INTERV") })
	     EndIF
			DVE->(dbSkip())			
		EndDo                                                                            
		
		//-- Salva o aCols
		aColsDVO := AClone(aCols)            
		
		//-- Deleta os Itens do aCols Auxiliar		
		aEval(aColsDVO, {|x| x[Len(x)] := .T. }) 
				
	EndIf                    
		
Else                        

	aCols := AClone(aColsDVO)		
	If nOpcx == 3 
	   For nI := 1 To Len(aFolder)
			cFolder  := aFolder[nI][1]	 // Componente	
			cCdrOri  := aFolder[nI][10] // Regiao Origem 
			cCdrDes  := aFolder[nI][11] // Regiao Destino 
			cProduto := aFolder[nI][14] // Produto		
			
			nPosCol	:= Ascan( aCols, {|x| AllTrim(x[3]) == AllTrim(cFolder) })
			
			aCols[nPosCol,GdFieldPos('DVO_VALMIN')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+cProduto+cFolder,"DTK_VALMIN")
			IF lDVOValMax
				aCols[nPosCol,GdFieldPos('DVO_VALMAX')]:=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+cProduto+cFolder,"DTK_VALMAX")
			EndIF

			aCols[nPosCol,GdFieldPos('DVO_VALOR')] :=Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+cProduto+cFolder,"DTK_VALOR")	   
			aCols[nPosCol][Len(aCols[nPosCol])] := .F. 
         //-- Campos Virtuais
			aCols[nPosCol,GdFieldPos('DVO_EMINTB')] := Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+cProduto+cFolder,"DTK_EXCMIN")
			aCols[nPosCol,GdFieldPos('DVO_FRCTAB')] := Posicione("DTK",1,xFilial("DTK")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOri+cCdrDes+cProduto+cFolder,"DTK_INTERV")
			
		Next 			
	Else
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados 
	EndIf	       
	
EndIf

If Len(aCols) > 0 
	n:=1
	If lEnchoice  // Mostra Enchoice
// adiciona Enchoice
    oSize:AddObject( "ENCHOICE", 100, 40, .T., .T. ) // Adiciona enchoice

// adiciona grid
    oSize:AddObject( "GRID",100, 60, .T., .T. ) // Adiciona Grid
    
// Dispara o calculo
    oSize:Process()
    nLinIni:=oSize:GetDimension("ENCHOICE","LININI")
    nColIni:=oSize:GetDimension("ENCHOICE","COLINI")
    nLinEnd:=oSize:GetDimension("ENCHOICE","LINEND")
    nColEnd:=oSize:GetDimension("ENCHOICE","COLEND")

	AAdd(aPosEnch,nLinIni)
	AAdd(aPosEnch,nColIni)
	AAdd(aPosEnch,nLinEnd)
	AAdd(aPosEnch,nColEnd)
	
	nLinIni2:=oSize:GetDimension("GRID","LININI")
    nColIni2:=oSize:GetDimension("GRID","COLINI")
    nLinEnd2:=oSize:GetDimension("GRID","LINEND")
    nColEnd2:=oSize:GetDimension("GRID","COLEND")
	
		DEFINE MSDIALOG oDlg TITLE STR0034 From oSize:aWindSize[1],oSize:aWindSize[2] TO ;
		                                        oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL //Complemento do Ajuste de Frete ### "Valores Minimos
		 
			oEnchoice := MsMGet():New('DVC', DVC->(Recno()),3 , , , ,aCposVis,aPosEnch, , 3,,,,,, .T. )
		    
			oGetD := MSGetDados():New(nLinIni2,nColIni2,nLinEnd2,nColEnd2,3,'AllwaysTrue()','AllwaysTrue()',,,,,,Len(aFolder) )
				   		                   
			If ValType(mv_par01) == "N" .And. (mv_par01 == 1)//Pergunta para habilitar ou não registros deletados. 1=Sim, 2=Não
			   			      //Faz com que itens do Aju. Subf venham marcados como deletados. Por solicitação da Ramos foi modificado.
			   TMSA011AjuMin(aColsDVO, aCols)	   			 
			Endif
				
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpc :=1, If (Obrigatorio(aGets,aTela) .And. TMSA011MOk(),oDlg:End(),nOpc := 0)},{||oDlg:End()}) CENTERED
	Else                                                            
	oSize:lLateral:= .F.  // Calculo vertical

    // adiciona grid
    oSize:AddObject( "GRID",100, 10, .T., .T. ) // Adiciona Grid
    // Dispara o calculo
    oSize:Process()
    nLinIni:=oSize:GetDimension("GRID","LININI")
    nColIni:=oSize:GetDimension("GRID","COLINI")
    nLinEnd:=oSize:GetDimension("GRID","LINEND")
    nColEnd:=oSize:GetDimension("GRID","COLEND")
     
    
		DEFINE MSDIALOG oDlg TITLE STR0034 From oSize:aWindSize[1],oSize:aWindSize[2] TO ;
		                                        oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL 
		
			oGetD := MSGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcx,'AllwaysTrue()','AllwaysTrue()',,IIf(nOpcx<>2,.T.,NIL),aAlter,,,Len(aFolder),,,,"TMA011DelDVO" )
		   
		   TMSA011AjuMin(aColsDVO, aCols)	   
		                   
		   oGetD:Refresh(.T.)        	                 		
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpc :=1, oDlg:End()},{||oDlg:End()}) CENTERED
	EndIf
Else
	Help("", 1, "TMSA01109") //Nao foi informado Complemento para este Ajuste
EndIf
	
aHeaderDVO := AClone(aHeader)

If nOpc == 1
	aColsDVO := AClone(aCols)	                              
	For nX:=1 To Len(aCols)
	   If aCols[nX][1] == '2' 
		   nSeek := Ascan(aColsDVO, {|x| x[4] == aCols[nX][4] }) // Descricao do Componente
		   If nSeek > 0 
				aDel(aColsDVO, nSeek)
				aSize(aColsDVO,Len(aColsDVO)-1)
			EndIf	
	   EndIf			
	Next nX	
	If lEnchoice  // Mostra Enchoice
		For nX :=1 To Len(aColsDVO)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso confirme a Tela e tenha marcado todos os campos de "Calcula Pasta" igual a "SIM",             ³
			//³ como algum valor numerico preenchido diferente de 0 O botao F5 ira  mostrar o acols nao deletado   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
			For nI:=1 To Len(aAlter)  
		 		If aHeaderDVO[GdFieldPos(aAlter[nI],aHeaderDVO),8] == "N" .And. aColsDVO[nX][GdFieldPos(aAlter[nI],aHeaderDVO)] <> 0
			  		aColsDVO[nX][Len(aColsDVO[nX])]:= .F.
				EndIf
			Next nI				
		Next nX
	EndIf
EndIf

If nOpcx == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao confirme a Tela ou tenha marcado todos os campos de "Calcula Pasta" igual a "Nao",³
	//³ retorna .F., para nao mostrar a Tela de Complemento no AJUSTE                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSeek := IIf(GdFieldPos('DVO_CALPAS') > 0, Ascan(aCols, {|x| x[GdFieldPos('DVO_CALPAS')] == '1' }), 1)
	
	If  nOpc == 0 .Or. nSeek == 0
		lRet := .F.
	EndIf
EndIf

Inclui  := IncOld
aHeader := aClone( aOldaHeader )
aCols   := aClone( aOldaCols )
n       := nSavN

RestArea( aArea )
RestArea( aAreaDVC )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

Return  lRet
	                                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011AjuM³ Autor ³ Patricia A. Salomao³ Data ³ 19/02/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Os Itens do aCols do DVO aparecerao deletados na 1a. chamada³±±
±±³          ³do 'Botao de Complemento do Ajuste'.Nas outras chamadas,    ³±±
±±³          ³estes itens poderao estar deletados ou nao.Esta funcao serve³±±
±±³          ³para auxiliar a GetDados a mostrar os itens deletados.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011AjuMin(ExpA1,ExpA2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - aCols Auxiliar do DVO                               ³±±
±±³          ³ExpA2 - aCols                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao TMSA011Min()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/	                  
Function  TMSA011AjuMin(aColsDVO, aCols)	 
Local nX
                                    
// Se o Item do aCols Auxiliar estiver deletado, deleta este item tambem no aCols 
// Isto tem que ser feito, para que a GetDados mostre os itens deletados na Tela
For nX := 1 To Len(aColsDVO)                                          
   If aColsDVO[nX][Len(aColsDVO[nX])]
		aCols[nX][Len(aCols[nX])] := .T.  
	EndIf	
Next

Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA011DelDVO ³ Autor ³Patricia A. Salomao ³ Data ³ 24/03/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nao permite desmarcar o componente no Complemento se o mesmo ³±±
±±³          ³ nao estiver no Folder da Tabela de Frete                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011AjuFol(ExpA1,ExpN1,ExpC1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA011DelDVO() 
Local nPosDesPas := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVO_DESPAS'})
Local nPosCodPas := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVO_CODPAS'})
Local cFolder    := Posicione( "DT3", 1, xFilial("DT3")+aCols[n,nPosCodPas], "DT3_CODPAS" )
Local nSeek      := 0

nSeek := Ascan(aFolder, {|x| x[1] == cFolder } )            
//-- O componente nao podera ser desmarcado se nao estiver no Folder  da Tabela 
If nSeek == 0 
	Return .F. 
EndIf 

Return .T.
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011MOk ³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da Tela de Complemento do Ajuste                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011MOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function  TMSA011MOk()
Local aAreaDT0 := DT0->(GetArea())
Local lRet     := .T.

DT0->(dbSetOrder(1))
If !DT0->(MsSeek(xFilial('DT0')+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO))
   Help("",1,"TMSA01103") //Tabela Mae Nao Encontrada !!!                        
	lRet := .F.
EndIf

RestArea(aAreaDT0)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TM011SeqTab³ Autor ³Patricia A. Salomao ³ Data ³ 13/03/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a Sequencia da Tabela de Ajuste                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM011SeqTab()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 -A Funcao esta sendo chamada pelo Campo 'Cod. Produto'³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TM011SeqTab( cTabFre, cTipTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cSeqTab, cCodNeg )    

Local   cSeek     := ""
Local   cAliasDVC := ""
Local   cQuery    := ""
Local   aAreaDVC  := DVC->(GetArea())
Local   lPriSeq   := .F.

Default cTabFre  := Iif(Type("M->DVC_TABFRE") <> "U",M->DVC_TABFRE,Space(Len(DVC->DVC_TABFRE)))
Default cTipTab  := Iif(Type("M->DVC_TIPTAB") <> "U",M->DVC_TIPTAB,Space(Len(DVC->DVC_TIPTAB)))
Default cCdrOri  := Iif(Type("M->DVC_CDRORI") <> "U",M->DVC_CDRORI,Space(Len(DVC->DVC_CDRORI)))
Default cCdrDes  := Iif(Type("M->DVC_CDRDES") <> "U",M->DVC_CDRDES,Space(Len(DVC->DVC_CDRDES)))
Default cCodCli  := Iif(Type("M->DVC_CODCLI") <> "U",M->DVC_CODCLI,Space(Len(DVC->DVC_CODCLI)))
Default cLojCli  := Iif(Type("M->DVC_LOJCLI") <> "U",M->DVC_LOJCLI,Space(Len(DVC->DVC_LOJCLI)))
Default cCodPro  := Iif(Type("M->DVC_CODPRO") <> "U",M->DVC_CODPRO,Space(Len(DVC->DVC_CODPRO)))
Default cServic  := Iif(Type("M->DVC_SERVIC") <> "U",M->DVC_SERVIC,Space(Len(DVC->DVC_SERVIC)))
Default cSeqTab  := ""
Default cCodNeg  := Iif(Type("M->DVC_CODNEG") <> "U",M->DVC_CODNEG,"")

cSeek     := xFilial("DVC") + cTabFre + cTipTab + cCdrOri + cCdrDes + cCodCli + cLojCli
cAliasDVC := ""
cQuery    := ""

cAliasDVC := GetNextAlias()
cQuery := " SELECT MAX(DVC_SEQTAB) DVC_SEQTAB "
cQuery += " FROM "
cQuery += " "+RetSqlName('DVC') + " DVC "
cQuery += " WHERE DVC.DVC_FILIAL = '"+xFilial("DVC")+"'"
cQuery += " AND DVC.DVC_TABFRE = '"+cTabFre+"'"
cQuery += " AND DVC.DVC_TIPTAB = '"+cTipTab+"'"
cQuery += " AND DVC.DVC_CDRORI = '"+cCdrOri+"'"
cQuery += " AND DVC.DVC_CDRDES = '"+cCdrDes+"'"
cQuery += " AND DVC.DVC_CODCLI = '"+cCodCli+"'"
cQuery += " AND DVC.DVC_LOJCLI = '"+cLojCli+"'"
cQuery += " AND DVC.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDVC,.T.,.T.)	
	
If Eof() .Or. Empty((cAliasDVC)->DVC_SEQTAB)
	cSeqTab := StrZero(1, Len(DVC->DVC_SEQTAB))	
	lPriSeq := .T.
Else
	cSeqTab := (cAliasDVC)->DVC_SEQTAB
EndIf		
		
DbCloseArea()

If !lPriSeq
	 // Tem que posicionar novamente no DVC, com a ultima sequencia cadastrada 
	DVC->(DbSetOrder( 8 ))
	DVC->(MsSeek(cSeek+cSeqTab))
	      
	Do While DVC->( !Eof() ) .And. DVC->DVC_FILIAL+DVC->DVC_TABFRE+DVC->DVC_TIPTAB+DVC->DVC_CDRORI+DVC->DVC_CDRDES+DVC->DVC_CODCLI+DVC->DVC_LOJCLI == cSeek
		If DVC->DVC_CODPRO == cCodPro .And. DVC->DVC_CODNEG == cCodNeg .And. DVC->DVC_SERVIC == cServic
			cSeqTab := Soma1( DVC->DVC_SEQTAB )
			Exit
		EndIf
		DVC->(dbSkip())
	EndDo
EndIf	

//-- Atualiza variavel devido a utilizacao da funcao no valid
If Type("M->DVC_SEQTAB") <> "U"
	M->DVC_SEQTAB := cSeqTab
EndIf	
	
RestArea(aAreaDVC)

Return .T.                                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Vld ³ Autor ³Patricia A. Salomao ³ Data ³ 09/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a Validacao de alguns Campos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011Vld()

Local lRet    := .T.
Local cCampo  := ReadVar()
Local cCliGen := ""
Local aArea   := GetArea()
Local nSeek   := 0
Local cFaixa  := ""

If cCampo == "M->DVC_CDRORI"
//	DUY->(dbSetOrder(1))
//	If DUY->(MsSeek(xFilial("DUY")+ &(ReadVar()) )) .And. DUY->DUY_GRPSUP == "MAINGR"
//		Help("", 1, "TMSA01011") // Nao Informe Regiao com grupo superior igual a "MAINGR"
//		lRet:=.F.
//	EndIf
	If !TmsTipReg(M->DVC_CDRORI, StrZero(1, Len(DTN->DTN_TIPREG)))
		lRet := .F.
	EndIf         
	
ElseIf cCampo == "M->DVC_CODPRO"
	If !Inclui
		Help(" ",1,"TMSA01009") //"Campo nao pode ser Alterado"
		Return ( .F. )
	EndIf	           
	If Vazio()
		Return ( .T. )
	EndIf	
	If !ExistCpo("SB1")
		Return ( .F. )
	EndIf	    	
	
ElseIf cCampo == "M->DVC_SERVIC"
	If Vazio()
		Return ( .T. )
	EndIf	
	If	Ascan(aItContrat, { |x| x[3] == &(ReadVar()) }) == 0
		Help("",1,"TMSA05040") // Servico Invalido ...
		Return(.F.)
	EndIf
ElseIf cCampo == "M->DVC_CODCLI" .Or. cCampo == "M->DVC_LOJCLI"
	cCliGen := GetMV("MV_CLIGEN")
	If M->DVC_CODCLI + M->DVC_LOJCLI == cCliGen
		Help("",1,"TMSXFUNB01") //Codigo Invalido.O Codigo Informado e de Cliente Generico (MV_CLIGEN).
		M->DVC_CODCLI := CriaVar("DVC_CODCLI")
		M->DVC_LOJCLI := CriaVar("DVC_LOJCLI")
		lRet := .F.
	Else
		M->DVC_NOMCLI := Posicione("SA1",1,xFilial('SA1')+M->DVC_CODCLI+M->DVC_LOJCLI,"A1_NOME")
	EndIf
	If	lRet .And. !Empty(M->DVC_CODCLI) .And. !Empty(M->DVC_LOJCLI) .And. !Empty(M->DVC_CODNEG)
		lRet := TmsA011Srv()
	EndIf
ElseIf cCampo == "M->DVD_VALATE"
	//-- Realizar a Validacao, somente se o Valor da Faixa Informada for diferente de "999999999.99".
	cFaixa := AllTrim(Str(Int(M->DVD_VALATE)))
	If cFaixa <> Replicate('9',Len(cFaixa))
		nSeek := Ascan(aFolder[oFolder:nOption][5], {|x| M->DVD_VALATE <= x[2] })
		If nSeek <> n
			Help("",1,"TMSA01101",,AllTrim(Str(nSeek)),2,1) //Informe esta faixa na Linha :
			lRet := .F.
		EndIf
	EndIf
ElseIf cCampo == "M->DW2_VALATE"
	//-- Realizar a Validacao, somente se o Valor da Faixa Informada for diferente de "999999999.99".
	cFaixa := AllTrim(Str(Int(M->DW2_VALATE)))
	If cFaixa <> Replicate('9',Len(cFaixa))
		nSeek := Ascan(aCols, {|x| M->DW2_VALATE <= x[2] })
		If nSeek <> n
			Help("",1,"TMSA01101",,AllTrim(Str(nSeek)),2,1) //Informe esta faixa na Linha :
			lRet := .F.
		EndIf
	EndIf
ElseIf cCampo == "M->DVC_CODNEG"
	If !Empty(M->DVC_CODNEG) .And. !Empty(M->DVC_CODCLI) .And. !Empty(M->DVC_LOJCLI)
		lRet := TmsA011Srv()
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Vali³ Autor ³ Nava               ³ Data ³ 18/01/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Coluna da Getdados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Valid()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³Verifica se a Getdados possui INTERVALO de frete jah        ³±±
±±³          ³ existente em outra linha, ou seja, se houve ENTRELACAMENTO ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011Valid()

Local lReturn 		:= .T.
Local nPosValor	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DVD_VALOR" } )
Local nPosValAju	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DVD_VALAJU" } )
Local nPosPerAju	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DVD_PERAJU" } )
Local cReadVar  	:= ReadVar()

Do Case

	Case aCols[n][Len( aHeader ) + 1] // deletado
		lReturn := .T.
		
	Case cReadVar = "M->DVD_VALAJU"
		aCols[n][nPosPerAju]	:= (  M->DVD_VALAJU / aCols[n][nPosValor] ) * 100
		
	Case cReadVar = "M->DVD_PERAJU" .AND. M->DVD_PERAJU <= 0
		lReturn := .F.
		
	Case cReadVar = "M->DVD_PERAJU"
		aCols[n][nPosValAju]	:= aCols[n][nPosValor] * M->DVD_PERAJU / 100		
		
EndCase

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011XBI ³ Autor ³Patricia A. Salomao ³ Data ³ 15/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a Rotina de Inclusao da Tabela de Frete             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011XBI()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta SXB - DVC                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011XBI()

TMSA011(3)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011XBV ³ Autor ³Patricia A. Salomao ³ Data ³ 15/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a Rotina de Visualizacao da Tabela de Frete         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011XBV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta SXB - DVC                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011XBV()

TMSA011(2)

Return
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA011AjuFol ³ Autor ³Patricia A. Salomao ³ Data ³ 15/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera as propriedades do Folder                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011AjuFol(ExpA1,ExpN1,ExpC1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Objeto Getdados do Folder                             ³±±
±±³          ³ExpN1 - Opcao Selecionada                                     ³±±
±±³          ³ExpC1 - Folder                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011AjuFol(aFolder,nOpcao,cFolder)

Local nY

// Se for Inclusao ou Alteracao de Ajuste
DVD->(dbSetOrder(1))
aFolder:oBrowse:bAdd := { || .f. }       // Nao Permite a inclusao de Linhas
For nY:=1 To Len(aCols)
	If IIf(nOpcao <> 4, nY < Len(aCols), .T.) .And. !DVD->(MsSeek(xFilial("DVD") + M->DVC_TABFRE + M->DVC_TIPTAB +M->DVC_CDRORI + ;
		M->DVC_CDRDES + M->DVC_CODCLI+ M->DVC_LOJCLI + M->DVC_SEQTAB+M->DVC_CODPRO+M->DVC_SERVIC+ cFolder +aCols[nY][1] + M->DVC_CODNEG))
		aCols[nY][Len(aHeader)+1] := .T. // Traz todos os elementos deletados, com excecao do ultimo
	EndIf
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA011FilDT³ Autor ³Patricia A. Salomao ³ Data ³ 02/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra o Arquivo DTF                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011XFilDTF()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Filtro da Consulta                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta DTF - DVC (SXB)                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMA011FilDTF()

Return( DTF->(DTF_TABFRE+DTF_TIPTAB) == M->DVC_TABFRE+M->DVC_TIPTAB )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011Whe ³ Autor ³Patricia A. Salomao ³ Data ³ 25/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de Campo (X3_WHEN)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Whe()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011Whe()

Local lRet   := .T.
Local cCampo :=ReadVar()

If cCampo $ 'M->DVD_VALOR.M->DW2_VALOR'
	lRet := .F.  // Se for Ajuste nao Deixar Alterar o campo
ElseIf cCampo $ 'M->DVC_CDRORI.M->DVC_CDRDES' .And. ValType	(oFolder) == "O"
	lRet := .F.  // Não permitir editar os campos de Regiao Origem/Destino na 2a. Tela
ElseIf cCampo$'M->DVC_CODPRO.M->DVC_SERVIC.M->DVO_CALPAS'
	lRet := (nOpcao == 3)   // So deixa alterar estes campos se for Inclusao de Ajuste
ElseIf cCampo$'M->DVO_VLRMIN.M->DVO_PERMIN'
	lRet := !Empty(GdFieldGet('DVO_VALMIN',n) )

ElseIf cCampo$'M->DVO_VLRMAX.M->DVO_PERMAX'
	lRet := !Empty(GdFieldGet('DVO_VALMAX',n) )
	
ElseIf cCampo$'M->DVO_VLREXC.M->DVO_PERAJU'
	lRet := !Empty(GdFieldGet('DVO_VALOR',n) )	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS011WheCl³ Autor ³Patricia A. Salomao ³ Data ³ 25/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de Campo DVC_CODCLI/DVC_LOJCLI (X3_WHEN)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011WheCli()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMA011WheCli()

Return (nOpcao == 3) //So' editar o campo de Codigo/Loja do Cliente se for Inclusao de Ajuste

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA011Est  ³ Autor ³Patricia A. Salomao ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza a Estrutura do Cadastro de Tabela de Frete (DVC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Est()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 -> Utiliza Tabelas de Reajuste de Preco              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA011Est(lReajPrec)

Local aAreaAnt	 := GetArea()
Local aSizeAut	 := MsAdvSize( .F. )
Local aObjects	 := {}
Local aInfo		 := {}
Local aObj		 := {}
Local nOpcA		 := 0
Local cCadOld   := cCadastro
Local aButtons  := {}
Local bSavKeyF4 := SetKey(VK_F4,Nil)
Local bSavKeyF5 := SetKey(VK_F5,Nil)

Local oDlg
Local cNomCli, cTexto
Local oBrowse   := GetMBrowse()

Private lReaj   := IIf(ValType(lReajPrec) == "L",lReajPrec,.F.)
Private oTree

cCadastro	:= STR0037 //'Estrutura de Tabelas'

bSavKeyF4   := SetKey( VK_F4 , { || TMSA011Pes(oTree) } )
bSavKeyF5   := SetKey( VK_F5 , { || TMSA011Vis() } )

Aadd( aButtons, { "PESQUISA", {|| TMSA011Pes(oTree)}, STR0038 , STR0039 }) //"Pesquisar - <F4>"
AAdd( aButtons, {'RELATORIO', {||TMSA011Vis()}, STR0040 , STR0041 }) //"Visualizar Tabela - <F5>"

aSize := MsAdvSize()

AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL

	oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,3], aObj[1,4],oDlg,,,.T.)
	oTree:LShowHint := .F.
	// Monta tree na primeira vez
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()
	// Coloca titulo no TREE
	oTree:BeginUpdate()
	oTree:TreeSeek("")
	If FindFunction('FWPDCanUse') .And. FWPDCanUse()
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) > 0		
			cNomCli := Posicione("SA1",1,xFilial("SA1")+DVC->DVC_CODCLI+DVC->DVC_LOJCLI,"A1_NOME")
		Else				
			cNomCli := Replicate('*',TamSX3('A1_NOME')[1])
		EndIf	
	Else	
		cNomCli := Posicione("SA1",1,xFilial("SA1")+DVC->DVC_CODCLI+DVC->DVC_LOJCLI,"A1_NOME")
	EndIf		
	cTexto  := PadR('Cliente : '+DVC->DVC_CODCLI+'/'+DVC->DVC_LOJCLI + '-'+cNomCli, 150)
	
	oTree:AddItem( cTexto, Padr('0MA-MAINGR', 40), 'FOLDER5','FOLDER6',,,2) //'Tabela de Frete
	
	//-- Chama a rotina de construcao do Tree
	Processa( { || TMA011Monta( @oTree ) }, , STR0042 ) //"Construindo Estrutura..."

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If(nOpca==1,oDlg:End(),nOpca := 0)},{||oDlg:End()},, aButtons )

cCadastro := cCadOld

//-- Desabilita as Teclas
TMA011DesTec()

RestArea(aAreaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA011Monta ³ Autor ³Patricia A. Salomao ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA011Monta(ExpO1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMA011Monta( oTree )

Local aAreaAnt	:=  GetArea()
Local cCargo	:=  ''
Local cSeek		:=  ''
Local cSeek1	:=  ''
Local cSeek2	:=  ''
Local lAchou   :=  .F.
Local cCadOld  := ''
Local cDesc    := ''
Local cProd    := ''
Local cCodNeg  := ''
Local cServic  := ''
Local cSequen  := ''
Local cCodCli  := DVC->DVC_CODCLI
Local cLojCli  := DVC->DVC_LOJCLI

oTree:TreeSeek( Padr('0MA-MAINGR', 40) )
cCargo := oTree:GetCargo()

DVC->( DbSetOrder( 3 ) )
DVC->( MsSeek( cSeek := xFilial('DVC') + cCodCli  + cLojCli, .F. ) )

Do While !DVC->(Eof()) .And. DVC->DVC_FILIAL + DVC->DVC_CODCLI + DVC->DVC_LOJCLI ==  cSeek

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para considerar o Reajuste de Preco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lReaj 
		If Empty( DVC->DVC_SEQTAB )
			DVC->( dbSkip() )
			Loop
		EndIf
	Else
		If !Empty( DVC->DVC_SEQTAB )
			DVC->( dbSkip() )
			Loop		
		EndIf
	EndIf
	
	DUY->( DbSetOrder( 1 ) )
	DUY->( DbSeek( xFilial('DUY') + DVC->DVC_CDRORI ) )
	
	oTree:TreeSeek( cCargo )
	//-- Monta a descricao da pasta.
	cDesc   := PadR( DVC->DVC_CDRORI  + '-' + Capital( DUY->DUY_DESCRI ), 150 )
	
	cCadOld := cCargo
	
	//-- Adiciona nova pasta no tree contendo a Regiao Origem
	cCargo := '01' + DVC->DVC_CDRORI
	oTree:AddItem( cDesc, cCargo,'FOLDER5','FOLDER6',,,2)
	oTree:TreeSeek( cCargo )
	
	cSeek1 := xFilial('DVC') + DVC->DVC_CODCLI + DVC->DVC_LOJCLI + DVC->DVC_CDRORI
	Do While DVC->( ! Eof() .And. DVC->DVC_FILIAL + DVC->DVC_CODCLI + DVC->DVC_LOJCLI + DVC->DVC_CDRORI == cSeek1 )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para considerar o Reajuste de Preco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If !lReaj 
			If Empty( DVC->DVC_SEQTAB )
				DVC->( dbSkip() )
				Loop
			EndIf
		Else
			If !Empty( DVC->DVC_SEQTAB )
				DVC->( dbSkip() )
				Loop		
			EndIf
		EndIf

		DUY->( DbSetOrder( 1 ) )
		DUY->( DbSeek( xFilial('DUY') + DVC->DVC_CDRDES))
		
		cCargo := '01' + DVC->DVC_CDRORI
		oTree:TreeSeek( cCargo )
		//-- Monta a descricao da pasta.
		cDesc  := Padr( DVC->DVC_CDRDES + '-' + Capital( DUY->DUY_DESCRI ), 150 )
		
		//-- Adiciona nova pasta no tree contendo todas as Regioes de Destino Cadastradas para
		//-- a Regiao de Origem
		cCargo := '02' + DVC->DVC_CDRORI+DVC->DVC_CDRDES
		oTree:AddItem( cDesc, cCargo,'FOLDER5','FOLDER6',,,2)
		
		cSeek2 := xFilial('DVC') + DVC->DVC_CODCLI + DVC->DVC_LOJCLI + DVC->DVC_CDRORI + DVC->DVC_CDRDES
		
		Do While DVC->( ! Eof() .And. DVC->DVC_FILIAL + DVC->DVC_CODCLI + DVC->DVC_LOJCLI + DVC->DVC_CDRORI+DVC->DVC_CDRDES == cSeek2 )
			lAchou  := .T.
			cProd   := ''
			cCodNeg := ''
			cServic := ''
			cCargo  := '02' + DVC->DVC_CDRORI+DVC->DVC_CDRDES
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para considerar o Reajuste de Preco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If !lReaj 
				If Empty( DVC->DVC_SEQTAB )    			
    				DVC->( dbSkip() )
					Loop
				EndIf
			Else
				If !Empty( DVC->DVC_SEQTAB )
					DVC->( dbSkip() )
					Loop		
				EndIf
			EndIf

			If DVC->DVC_SEQTAB <> StrZero(0, Len(DVC->DVC_SEQTAB)) .And. !Empty(DVC->DVC_SEQTAB)
				cSequen := STR0043 + DVC->DVC_SEQTAB //"   /  Sequencia : "
			EndIf
			
			If !Empty(DVC->DVC_CODPRO)
				cDesc := Posicione("SB1",1,xFilial("SB1")+ DVC->DVC_CODPRO,"B1_DESC")
				cProd := STR0044 + Substr(cDesc,1,25) //"   /  Produto : "
			EndIf

			If !Empty(DVC->DVC_CODNEG)
                cDesc   := Posicione("DDB",1,xFilial("DDB") + DVC->DVC_CODNEG,"DDB_DESCRI")
                cCodNeg := STR0060 + Substr(cDesc,1,25) //"   /  Negociacao : "
            EndIf
			
			If !Empty(DVC->DVC_SERVIC)
				cDesc   := Tabela("L4", DVC->DVC_SERVIC, .F.)
				cServic := STR0045 + Substr(cDesc,1,25) //"   /  Servico : "
			EndIf
			
			//-- Monta a descricao da pasta.
			cDesc  := PadR( DVC->DVC_TABFRE+'-'+DVC->DVC_TIPTAB + cSequen + cProd + cCodNeg + cServic , 150)
			
			oTree:TreeSeek( cCargo )
			//-- Adiciona nova pasta no tree contendo todas as Configuracoes Cadastradas para as Tabelas com
			//-- esta Regiao de Origem e Destino
			cCargo := '03' + DVC->DVC_CDRORI+DVC->DVC_CDRDES+DVC->DVC_TABFRE+DVC->DVC_TIPTAB+DVC->DVC_SEQTAB+DVC->DVC_CODPRO+DVC->DVC_CODNEG+DVC->DVC_SERVIC
			oTree:AddItem( cDesc, cCargo,'FOLDER5','FOLDER6',,,2)
			
			DVC->(dbSkip())
		EndDo
		
		If !lAchou
			DVC->(dbSkip())
		EndIf
		
	EndDo
	
	cCargo := cCadOld
	
EndDo

oTree:EndUpdate()
oTree:TreeSeek( '0MA-MAINGR' )
oTree:Refresh()

RestArea(aAreaAnt)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA011Vis  ³ Autor ³Patricia A. Salomao ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza a Tabela de Frete Posicionada no Tree            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Vis()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011Vis()

Local lRet      := .T.
Local cCargo    := oTree:GetCargo()
Local aAreaDVC  := DVC->(GetArea())
Local cCodCli   := DVC->DVC_CODCLI
Local cLojCli   := DVC->DVC_LOJCLI

If Left( cCargo, 2 ) == '03' // Pasta que contem a Configuracao da Tabela	
	DVC->( dbSetOrder( 3 ) )
	If DVC->( MsSeek( xFilial( 'DVC' ) + cCodCli + cLojCli + AllTrim(SubStr(cCargo, 3, Len(AllTrim(cCargo))))  ) )
		TMSA011Mnt('DVC' ,DVC->(Recno() ), 2 )
	EndIf	
Else
	Help('',1,'TMSA01015') //Escolha o Lay-Out da Tabela para visualizar ... 
	lRet := .F.
EndIf

//-- Desabilita as Teclas
TMA011DesTec()

RestArea(aAreaDVC)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA011UF   ³ Autor ³Patricia A. Salomao ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta uma Parambox contendo todos os Estados em que o Ajus ³±±
±±³          ³ te podera ser criado                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011UF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011UF()

Local aEstados := {}
Local aRet     := {}
Local lCkb
Local lInv     := .F.
Local nX
Local lRet     := .T.
Local nI	   := 1

//-- Desabilita as Teclas
TmsKeyOff(aSetKey)


	aSX5Tipo := FWGetSX5("12")

	For nI := 1 To Len(aSX5Tipo)
		lCkb := .F.
		aAdd(aEstados, {4,"",lCkb,AllTrim(aSX5Tipo[nI][3]) + " - " + aSX5Tipo[nI][4],80,,.F.} )
	Next

aRet := {}
If ParamBox( aEstados, STR0046 , @aRet, , {{ 5, { |oPanel| TMSA011Marc(aEstados,@aRet,@lInv),oPanel:Refresh() }, STR0047 }} , .T.) //"Tabela de Estados" ### "Marca/Desmarca Todos"
	For nX := 1 To Len(aRet)
		If aRet[nX]
			AADD(aEst, SubStr(aEstados[nX,4],1,2) )
		EndIf
	Next nX
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA011Mar³ Autor ³Patricia A. Salomao    ³ Data ³06.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os CheckBox do PARAMBOX()             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Marc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo a Tabela de Estados                 ³±±
±±³          ³ ExpA2 - Array de controle dos Estados Marcados             ³±±
±±³          ³ ExpL1 - Marca/Desmarca                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA011Marc(aEstados,aRet,lInv)

Local nX

For nX := 1 To Len(aEstados)
	aAdd(aRet,If(lInv,.F.,.T.))
	&("MV_PAR"+StrZero(nx,2)) := If(lInv,.F.,.T.)
Next nX
lInv := !lInv

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA011RegD³ Autor ³Patricia A. Salomao    ³ Data ³07.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Tabelas de Ajuste para as Regioes de Destino pertencen³±±
±±³          ³ tes aos Estados Informados no Botao de Estados (Enchoice)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA011RegDes()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011RegDes(nOpcx)

Local nCntFor
Local cSeek
Local aAreaDT0 := DT0->(GetArea())
Local aAreaDVC := DVC->(GetArea())
Local cCdrDes  := M->DVC_CDRDES
Local cAliasNew,cQuery,cEst := ''

cAliasNew := ""
cEst      := ""
cQuery    := ""
cSeek     := ""

If !Empty(aEst)
	For nCntFor := 1 To Len(aEst)
		cEst += "'" + aEst[nCntFor] + "',"
	Next
	cEst := Substr(cEst,1,Len(cEst) - 1)
	cAliasNew := GetNextAlias()	
	cQuery := " SELECT DISTINCT DUY_GRPVEN "
	cQuery += " FROM "
	cQuery += RetSqlname("DUY") + " DUY,"
	cQuery += RetSqlName("DT0") + " DT0 "
	cQuery += " WHERE "
	cQuery += " DUY_FILIAL = '" + xFilial("DUY") + "'"
	cQuery += " AND DUY_EST IN (" + cEst + ")"
	cQuery += " AND DUY.D_E_L_E_T_ = ' ' "
	cQuery += " AND DT0_FILIAL = '" + xFilial("DT0") + "'"
	cQuery += " AND DT0_TABFRE = '" + M->DVC_TABFRE + "'"
	cQuery += " AND DT0_TIPTAB = '" + M->DVC_TIPTAB + "'"
	cQuery += " AND DT0_CDRORI = '" + M->DVC_CDRORI + "'" 
	cQuery += " AND DT0_CDRDES = DUY_GRPVEN "
	cQuery += " AND DT0_CDRDES <> '" + cCdrDes + "'"
	cQuery += " AND DT0_CODPRO =  '" + cProdOri + "'"
	cQuery += " AND DT0.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	
	Do While (cAliasNew)->( !Eof() )
		M->DVC_CDRDES := (cAliasNew)->DUY_GRPVEN
		TM011SeqTab()
		TMSA011Grv(nOpcx)
		(cAliasNew)->(dbSkip())
	EndDo
	(cAliasNew)->( DbCloseArea() )
EndIf

RestArea(aAreaDT0)                                    
RestArea(aAreaDVC)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA011Pes  ³ Autor ³ Patricia A. Salomao³ Data ³09.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa a Reg. Origem / Destino no Tree                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Pes(ExpO1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011Pes( oTree )

Local cChavePsq1 := CriaVar('DVC_CDRDES', .F.)
Local cChavePsq2 := CriaVar('DVC_CDRORI', .F.)
Local nOpca		  := 0
Local oDlg, oBut1, oBut2, oGetPesq1, oGetPesq2

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 09,0 TO 21.2,43.5 OF oMainWnd

@ 0, 0 BITMAP oBmp RESNAME 'LOGIN' 	OF oDlg	SIZE 30,120 NOBORDER WHEN .F.	PIXEL
@ 14, 30 TO 16 ,400 LABEL '' OF oDlg	PIXEL
@ 22, 40 SAY STR0048 SIZE 40, 09	PIXEL 	//"Localizar"
@ 35, 40 SAY Rtrim(RetTitle("DVC_CDRORI")) SIZE 40, 09	PIXEL
@ 35, 80 MSGET oGetPesq1 VAR cChavePsq1 F3 'DUY' SIZE 80, 10 VALID .T. PIXEL
@ 48, 40 SAY Rtrim(RetTitle("DVC_CDRDES")) SIZE 40, 09	PIXEL
@ 48, 80 MSGET oGetPesq2 VAR cChavePsq2	F3 'DUY' SIZE 80, 10 VALID .T. PIXEL

DEFINE SBUTTON oBut1 FROM 67,  99	TYPE 1 ACTION ( nOpca := 1,oDlg:End() ) ENABLE OF oDlg
DEFINE SBUTTON oBut2 FROM 67, 132	TYPE 2 ACTION ( nOpca := 0,oDlg:End() ) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1 .And. !oTree:TreeSeek("02"+cChavePsq1+cChavePsq2)
	Help(' ',1,'TMSA01016')		//-- Regiao de Origem / Destino Nao Encontradas na Estrutura de Tabelas
	//-- Desabilita as Teclas
	TMA011DesTec()
	Return ( .F. )
EndIf

//-- Desabilita as Teclas
TMA011DesTec()

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA011Con³ Autor ³Patricia A. Salomao    ³ Data ³09.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se o usuario tiver acesso, permite incluir ou alterar o    ³±±
±±³          ³ Contrato do Cliente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Cont()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA011Cont()

Local aContrat  := {}   
Local aArea     := GetArea()
Local IncOld    := Inclui
Local AltOld    := Altera
Local cCadOld   := cCadastro
Local nTipo     := 1
Local cTipFre   := " "
Local aTipFre   := {}                       
Local oTipo, oDlg                        

//-- Desabilita as Teclas
TmsKeyOff(aSetKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe contrato em vigencia para o cliente informado          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AAM")
dbSetOrder(2)
If AAM->(MsSeek(xFilial()+M->DVC_CODCLI+M->DVC_LOJCLI))
	Do While !Eof() .And. AAM->AAM_FILIAL == xFilial("AAM") .And. AAM->AAM_CODCLI+AAM->AAM_LOJA==M->DVC_CODCLI+M->DVC_LOJCLI
      If Empty(AAM->AAM_FIMVIG) .Or. (AAM->AAM_INIVIG <= dDataBase .And. AAM->AAM_FIMVIG >= dDataBase)
         AADD(aTipFre, AAM->AAM_TIPFRE)
	   EndIf            
	   dbSkip()
	EndDo
EndIf     
                                     
If Len(aTipFre) > 1
	DEFINE MSDIALOG oDlg FROM 15,1 TO 145,245 TITLE STR0049 PIXEL //"Visualizar o Contrato :"
	    @ 6 , 11 TO 37, 110 OF oDlg PIXEL
	    @ 11, 13 RADIO oTipo VAR nTipo PROMPT STR0036 , STR0035  OF oDlg PIXEL SIZE 20,10 //"CIF" ### "FOB"
	    DEFINE SBUTTON FROM 47, 82 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
 	cTipFre := AllTrim(Str(nTipo))	
ElseIf Len(aTipFre) == 1
	cTipFre := aTipFre[1]
EndIf

aContrat := TMSContrat(M->DVC_CODCLI, M->DVC_LOJCLI, , , .F., cTipFre,,,,,,,,,,,,,,,,M->DVC_CODNEG)
	
If Len(aContrat) > 0
	dbSelectArea("AAM")
	dbSetOrder(1)
	If AAM->(MsSeek(xFilial()+aContrat[1,1]))
		//-- Verifica se o Usuario tem permissao para alterar o Contrato do Cliente
		If TMSACESSO(,"TECA250",, 4)
			Inclui := .F.
			Altera := .T.
			If FWHasModel("TECA250")
				FwExecView(,"TECA250",4)
			Else
				At250Manut( "AAM", Recno(), 4 )
			EndIf
		EndIf
	EndIf
Else
	//-- Verifica se o Usuario tem permissao para incluir o Contrato do Cliente
	If TMSACESSO(,"TECA250",, 3)
		Inclui := .T.
		Altera := .F.
		If FWHasModel("TECA250")
			FwExecView(,"TECA250",3)
		Else
			At250Manut( "AAM", Recno(), 3 )
		EndIf
	EndIf
EndIf

Inclui    := IncOld
Altera    := AltOld
cCadastro := cCadOld

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura os dados de entrada                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestInter()

RestArea(aArea)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA011Des³ Autor ³Patricia A. Salomao    ³ Data ³09.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se o usuario tiver acesso,permite incluir ou alterar o Desti³±±
±±³          ³no de Calculo do Cliente.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Des()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA011Des(nOpcx)

Local aArea     := GetArea()
Local IncOld    := Inclui
Local AltOld    := Altera
Local cCadOld   := cCadastro
cCadastro := STR0033 //"Destino de Calculo"

//-- Desabilita as Teclas
TmsKeyOff(aSetKey)

dbSelectArea("DTH")
dbSetOrder(1)
If nOpcx == 2
	If	DTH->(MsSeek(xFilial('DTH')+M->DVC_CODCLI+M->DVC_LOJCLI))
		AxVisual('DTH',DTH->(Recno()),2)
	EndIf
Else
	If MsSeek(xFilial("DTH")+M->DVC_CODCLI+M->DVC_LOJCLI)
		//-- Verifica se o Usuario tem permissao para alterar o Destino de Calculo
		If TMSACESSO(,"TMSA090",, 4)
			Inclui := .F.
			Altera := .T.
			AxAltera( "DTH", Recno(), 4 )
		EndIf
	Else
		//-- Verifica se o Usuario tem permissao para incluir o Destino de Calculo
		If TMSACESSO(,"TMSA090",, 3)
			Inclui := .T.
			Altera := .F.
			AxInclui( "DTH", Recno(), 3 )
		EndIf
	EndIf
EndIf
Inclui    := IncOld
Altera    := AltOld
cCadastro := cCadOld

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)


RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA011AddF³ Autor ³Patricia A. Salomao    ³ Data ³07.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o array aFolder                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011AddFol()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array de Folders                                    ³±±
±±³          ³ExpA2 - aHeader                                             ³±±
±±³          ³ExpA3 - aCols                                               ³±±
±±³          ³ExpA4 - Array Contendo os campos que poderao ser alterados  ³±±
±±³          ³ExpC1 - Descricao do Componente                             ³±±
±±³          ³ExpC2 - Regiao Origem do Componente                         ³±±
±±³          ³ExpC3 - Regiao Destino do Componente                        ³±±
±±³          ³ExpC4 - Regiao Origem da Tabela Mae                         ³±±
±±³          ³ExpC5 - Regiao Destino da Tabela Mae                        ³±±
±±³          ³ExpC6 - Produto                                             ³±±
±±³          ³ExpN1 - No. de Astericos para mostrar no Folder             ³±±
±±³          ³ExpN2 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011AddFol(aFolder, aHeader, aCols,  aAlter, cDescComp, cCdrOri, cCdrDes, cCdrOTab, cCdrDTab, cProduto, nOpcx, nAster)

Local nPosValAte
Local cFolderName
Local nAtalho := 1
Local aRetBox := {}
Local cAster  := ' '

Default cCdrOTab := ''
Default cCdrDTab := ''
Default nAster   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Significado da descricao do Folder contendo :                                                       ³      
//³ "  " - Componente cadastrado na Regiao Origem / Destino informados (Nao utilizou a funcao TMSTabela)³
//³ "*"  - Componente originario de outra regiao (Utilizou a funcao TMSTabela)                          ³
//³ "**" - Componente originario de outra regiao, nao cobrado neste ajuste (Utilizou a funcao TMSTabela)³
//³       Os 2 Asteriscos sao mostrados somente na opcao de ALTERACAO para destacar os componentes que  ³
//³       sao originarios de outras regioes e que NAO estao sendo cobrados no ajuste                    ³                
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                        
If !Empty(nAster)
	cAster :=  ' * '
EndIf	
	                   
Aadd( aFolder, {DT3->DT3_CODPAS, ;
					 cDescComp + cAster, ;
					 {}, ;
					 aClone( aHeader ), ;
					 aClone( aCols ), ;
					 "TMSA011LinOk", ;
					 "TMSA011LinOk", ;
					 NIL, ;
					 aAlter,;
					 cCdrOri,;
					 cCdrDes,;
					 cCdrOTab,;
					 cCdrDTab,;
 					 cProduto } )
					
//-- Define letra de atalho para acessar o folder
If	!Empty( DT3->DT3_ATALHO )
	nAtalho := At( DT3->DT3_ATALHO, UPPER(aFolder[ Len(aFolder), 2 ]) )
	If Empty( nAtalho )
		nAtalho := 1
	EndIf
EndIf

aFolder[ Len(aFolder), 2 ] := Stuff( aFolder[ Len(aFolder), 2 ], nAtalho, 0, '&' )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Troca do aHeader refletindo o nome da Pasta do Folder³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nPosValAte	:= Ascan( aFolder[Len(aFolder)][4], { |aField| aField[2] = "DVD_VALATE" } )
           
If Empty(DT3->DT3_FAIXA) .Or. DT3->DT3_FAIXA == StrZero(0, Len(DT3->DT3_FAIXA))
	cFolderName := TMSValField('DT3->DT3_TIPFAI',.F.)
Else
	//-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA
	aRetBox     := RetSx3Box( Posicione('SX3', 2, 'DT3_FAIXA', 'X3CBox()' ),,, Len(DT3->DT3_FAIXA) )

	cFolderName := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA} ), 3 ])
			   
			   
EndIf 
   
aFolder[Len(aFolder)][4][nPosValAte][1] :=  GetSX3Cache("DVD_VALATE", "X3_Titulo" ) + Space( 10 ) + "(" +  cFolderName + ")" //"Ate"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA011Vis ³ Autor ³Wellington A Santos    ³ Data ³20/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama a tela de visualizacao da tabela de frete             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011vis()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011Vis()

//-- Desabilita as Teclas
TmsKeyOff(aSetKey)

TmsVisTbFre(M->DVC_TABFRE,M->DVC_TIPTAB,StrZero(0,Len(M->DVC_SEQTAB)),M->DVC_CDRORI,M->DVC_CDRDES,M->DVC_SERVIC,M->DVC_CODPRO,M->DVC_CODCLI,M->DVC_LOJCLI,M->DVC_CODNEG )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA011ValD³ Autor ³Patricia A. Salomao    ³ Data ³12.02.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Preenche os campos de Valor / Percentual de Ajuste          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011ValDVO()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA011ValDVO()

Local nPerAju := 0
Local nValAju := 0
Local cCampo  := ReadVar()

If cCampo $  "M->DVO_VLRMIN"                                
   nPerAju :=  ( M->DVO_VLRMIN / GdFieldGet('DVO_VALMIN',n) ) * 100
	GdFieldPut('DVO_PERMIN', nPerAju, n)
		
ElseIf cCampo $ "M->DVO_PERMIN" 
   nValAju := ( M->DVO_PERMIN * GdFieldGet('DVO_VALMIN',n) ) / 100		
	GdFieldPut('DVO_VLRMIN', nValAju, n) 				
		
ElseIf cCampo $  "M->DVO_VLRMAX"                                
   nPerAju :=  ( M->DVO_VLRMAX / GdFieldGet('DVO_VALMAX',n) ) * 100
	GdFieldPut('DVO_PERMAX', nPerAju, n)
		
ElseIf cCampo $ "M->DVO_PERMAX" 
   nValAju := ( M->DVO_PERMAX * GdFieldGet('DVO_VALMAX',n) ) / 100		
	GdFieldPut('DVO_VLRMAX', nValAju, n) 
ElseIf cCampo $ "M->DVO_VLREXC" 
	nPerAju :=  ( M->DVO_VLREXC / GdFieldGet('DVO_VALOR',n) ) * 100
	GdFieldPut('DVO_PERAJU', nPerAju, n)		

ElseIf cCampo $ "M->DVO_PERAJU" 
   nValAju := ( M->DVO_PERAJU * GdFieldGet('DVO_VALOR',n) )  / 100		
	GdFieldPut('DVO_VLREXC', nValAju, n) 				
		
EndIf 

Return ( .T. )                                                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA011Obs³ Autor ³Patricia A. Salomao    ³ Data ³26.02.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe Tela contendo o significado dos asteriscos do Folder  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011Obs()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA011Obs()

Local oDlg, oBold, oBmp

DEFINE MSDIALOG oDlg TITLE STR0032 From 2,0 To 13,68 OF oMainWnd //"Observacoes do Componente"

	DEFINE FONT oBold NAME 'Arial' SIZE 0, -16 BOLD                                                       
	
	@ 0, 0 BITMAP oBmp RESNAME 'LOGIN' 	OF oDlg	SIZE 30,220 NOBORDER WHEN .F.	PIXEL
	
	@ 04, 42 TO 55 ,255 LABEL '' OF oDlg	PIXEL

	@ 017,050 SAY '*'  OF oDlg PIXEL SIZE 10,25 COLOR CLR_BLUE FONT oBold
		
	@ 017,062 SAY STR0012 SIZE 150,200 PIXEL //'-   Componente originario de outra regiao '

	@ 030,050 SAY '**'  OF oDlg PIXEL SIZE 10,25 COLOR CLR_BLUE FONT oBold
	
	@ 030,062 SAY STR0011 SIZE 300,300 PIXEL //'-   Componente originario de outra regiao, nao cobrado neste Ajuste '

	DEFINE SBUTTON FROM 66,235 TYPE 1 OF oDlg ENABLE ACTION (oDlg:End())
	
ACTIVATE MSDIALOG oDlg CENTERED 

Return .T. 
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA011DesT³ Autor ³Patricia A. Salomao    ³ Data ³26.02.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Desabilita as Teclas                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011DesTec()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011DesTec()

Set Key VK_F4 To
Set Key VK_F5 To			
Set Key VK_F6 To			
Set Key VK_F7 To			
Set Key VK_F8 To			
Set Key VK_F9 To
Set Key VK_F10 To
Set Key VK_F11 To


Return .T. 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA011Srv³ Autor ³ Alex Egydio           ³ Data ³13.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem os servicos contidos no contrato do cliente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA011Srv()

Local lRet := .T.

TMSPesqServ('DVC',M->DVC_CODCLI,M->DVC_LOJCLI,,,@aItContrat,,M->DVC_TIPFRE,,,.F.,M->DVC_TABFRE,M->DVC_TIPTAB,;
			M->DVC_VIGCON,.F.,M->DVC_CDRORI,M->DVC_CDRDES,,,,,,,,M->DVC_CODNEG)

If	Empty(aItContrat)
	M->DVC_SERVIC := CriaVar('DVC_SERVIC',.F.)
	M->DVC_DESSER := CriaVar('DVC_DESSER',.F.)
	Help('',1,'TMSA01105',,'Cliente : '+M->DVC_CODCLI+' / '+M->DVC_LOJCLI + CHR(13) + CHR(10) +;
	'Tabela : '+M->DVC_TABFRE+' / Tipo : '+M->DVC_TIPTAB + CHR(13) + CHR(10) +;
	'Tipo Frete : '+TmsRetCbx('DVC_TIPFRE',M->DVC_TIPFRE),4,1)	//-- Nao ha contratos utilizando a tabela de frete
	lRet := .F.
ElseIf Len(aItContrat)==1
	M->DVC_DESSER := Tabela('L4',M->DVC_SERVIC,.F.)
EndIf
Return(lRet)

//-- Utilizada para validar se o programa esta atualizado na chamada da TmsCalFret().
Function TMSA011UPD()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA011Vd2  ³ Autor ³ Eduardo de Souza     ³ Data ³ 03/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida sub-faixa para o componente principal.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Vd2()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA011Vd2(cCodPas,cItem)

Local lRet := .F.
Local nPos := 0

//-- Verifica se o componente de frete utiliza sub-faixa.
If Empty(Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_FAIXA2"))
	lRet := .T.
Else
	//-- Verifica se foi informado alguma sub-faixa para o componente.
	If (nPos := Ascan( aColsDW2, { |x| x[1]+x[2] == cCodPas + cItem } )) > 0 .And. ;
			Ascan( aColsDW2[nPos,3], { |x| ! x[Len(x)] } ) > 0
		lRet := .T.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA011SFx  ³ Autor ³ Eduardo de Souza     ³ Data ³ 26/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta Sub-Faixa                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011SFx()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA011SFx(nOpcx)

Local cTitTabFre  := AllTrim(RetTitle("DW2_TABFRE"))
Local cTitTipTab  := AllTrim(RetTitle("DW2_TIPTAB"))
Local cTitCodPas  := AllTrim(RetTitle("DW2_CODPAS"))
Local cTitItem    := AllTrim(RetTitle("DW2_ITEM"  ))
Local oDlgEsp
Local oGetSub
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local nPos        := 0
Local nOpcao      := 0
Local lAchou      := .F.
Local nCnt        := 0
Local cCodPas     := aFolder[nFolder,1]
Local cItem       := GDFieldGet("DVD_ITEM",n)
Local aNoFields   := { "DW2_TABFRE","DW2_ITEDVD" }
Local nPosValAte  := 0
Local aRetBox     := {}
Local cFolderName := ''
Local aButtons    := {}

// Excedente por Subfaixa
// Se existem as tabelas de Excedente deve incluir o botao
Aadd(aButtons,	{'PRECO',{|| TMSA011Comp(nOpcx,cItem) }, STR0053, STR0054 })	

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Verifica se existe o componente de frete.
DT3->(dbSetOrder(1))
If !DT3->(MsSeek(xFilial("DT3")+cCodPas))
	Help("",1,"TMSA01018") //"Componente de frete não encontrado"
	RestInter() //-- Restaura Area
	Return .F.
EndIf

//-- Verifica se o componente utiliza sub-faixa.
If Empty(DT3->DT3_FAIXA2)
	Help("",1,"TMSA01019") //Componente de frete nao configurado para utilizar subfaixa.
	RestInter() //-- Restaura Area
	Return .F.
EndIf

If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
	AAdd(aNoFields,'DW2_FATPES')
EndIf

If (nPos:= Ascan( aColsDW2, { |x| x[1]+x[2] == cCodPas + cItem } ) ) == 0
	TMSFillGetDados(	nOpcx, ;
							"DW2", ;
							1, 	 ;
							xFilial("DW2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cCodPas+cItem , ;
							Iif(nOpcx <> 3,{ || DW2->DW2_FILIAL+DW2->DW2_TABFRE+DW2->DW2_TIPTAB+DW2->DW2_CDRORI+DW2->DW2_CDRDES+DW2->DW2_CODPRO+DW2->DW2_CODPAS+DW2->DW2_ITEDVD },{|| ''   }), ;
							{|| .T.  },;
							aNoFields )
	//-- Inicializa o primeiro item da sub-faixa.
	aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DW2_ITEM')]), x[GdFieldPos('DW2_ITEM')]:= StrZero(1, Len(DW2->DW2_ITEM)), .T.) })
Else
	lAchou   := .T.
	aCols    := AClone(aColsDW2[nPos,3]	)
	aHeader  := AClone(aColsDW2[nPos,4])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Inicio da troca do aHeader refletindo o nome da faixa.
nPosValAte	:= Ascan( aHeader, { |aField| aField[2] = "DW2_VALATE" } )

//-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA2
aRetBox     := RetSx3Box( Posicione('SX3', 2, 'DT3_FAIXA2', 'X3CBox()' ),,, Len(DT3->DT3_FAIXA2) )
cFolderName := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA2} ), 3 ])

aHeader[nPosValAte,1] := GetSX3Cache("DW2_VALATE","X3_Titulo") + Space( 10 ) + "(" +  cFolderName + ")" 
//-- Fim da troca do aHeader refletindo o nome da faixa.

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 020, .T., .T. } )
AAdd( aObjects, { 100, 080, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE STR0010 FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL //"Ajuste de Tabela de Frete - Subfaixa"

@ aPosObj[1,1],010 SAY cTitTabFre + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 35 ,9
@ aPosObj[1,1],043 SAY M->DVC_TABFRE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],060 SAY cTitTipTab + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],095 SAY M->DVC_TIPTAB Of oDlgEsp PIXEL SIZE 10 ,9

@ aPosObj[1,1],115 SAY cTitCodPas + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 35 ,9
@ aPosObj[1,1],150 SAY Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI") Of oDlgEsp PIXEL SIZE 40 ,9

@ aPosObj[1,1],220 SAY cTitItem + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],235 SAY cItem Of oDlgEsp PIXEL SIZE 10 ,9

oGetSub:=MSGetDados():New(aPosObj[2,1]/2, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSA011SLOk()','AllWaysTrue',"+DW2_ITEM",nOpcx<>2)
	If ValType(mv_par01) == "N" .And. (mv_par01 == 1)//Pergunta para habilitar ou não registros deletados. 1=Sim, 2=Não
		//Faz com que itens do Aju. Subf venham marcados como deletados. Por solicitação da Ramos foi modificado.
		//-- Atualiza aCols corrigindo a falha na GetDados
		If(lAchou,aCols := AClone(aColsDW2[nPos,3]),.T.)
		oGetSub:nMax:= Len(aCols)
		oGetSub:Refresh(.T.)
    Endif
ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetSub:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() },,aButtons ) CENTERED

//-- Atualiza array de aCols da sub-faixa
If nOpcao == 1
	If (nPos:= Ascan( aColsDW2, { |x| x[1]+x[2] == cCodPas+cItem } ) ) == 0
		Aadd(aColsDW2,{ cCodPas, cItem, AClone(aCols), AClone(aHeader) } )
	Else
		aColsDW2[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA011SLOk ³ Autor ³ Eduardo de Souza     ³ Data ³ 27/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida linha da sub-faixa                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011SLOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA011SLOk()

Local lRet        := .F.
Local nPosValAte	:= GDFieldPos("DW2_VALATE")
Local nPosFatPes	:= GDFieldPos("DW2_FATPES")
Local nValAte		:= 0
Local nValPes   	:= If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)

If Len(aCols) > 0
	nValAte := aCols[n][nPosValAte]
	lRet := MaCheckCols(aHeader,aCols,n)
	
	//-- Valida se esta deletado
	If lRet
		If GDDeleted(n)
			lRet := .T.
		//-- Na primeira linha Valida p/ baixo
		ElseIf n == 1
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
											(nValAte >= aLine[nPosValAte] .Or. ;
											IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) == 0
		//-- Na ultima linha Valida p/ cima
		ElseIf n == Len( aCols )
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
											(nValAte <= aLine[nPosValAte]	.Or.;
											IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) == 0
		//-- Valida Acima e Abaixo
		Else			
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
											(nValAte <= aLine[nPosValAte] .Or. ;
											IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) == 0
			
			lRet := lRet .And. ;
					   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
											(nValAte >= aLine[nPosValAte] .Or.;
											IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) == 0
		EndIf
		
		If !lRet
			Help(" ",1,"TMSA01107") //"Campo Ate'/Fator Peso Invalido ou ja existente"
		EndIf
	
		If lRet .And. !GdDeleted(n) .And. nPosFatPes >0 .And. GDFieldGet('DW2_FATPES',n) < GDFieldGet('DW2_VALATE',n)
			Help("", 1,"TMSA01108")  //"O Fator de Peso Nao pode ser menor do que o Peso ..."
			lRet := .F.
		EndIf	
	EndIf
Else
	lRet := .T.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011VSFx³ Autor ³ Eduardo de Souza       ³ Data ³ 03/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Coluna da Getdados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011VSFx()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA011VSFx()

Local lReturn 		:= .T.
Local nPosValor	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DW2_VALOR"  } )
Local nPosValAju	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DW2_VALAJU" } )
Local nPosPerAju	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DW2_PERAJU" } )
Local cReadVar  	:= ReadVar()

Do Case

	Case aCols[n][Len( aHeader ) + 1] // deletado
		lReturn := .T.
		
	Case cReadVar = "M->DW2_VALAJU"
		aCols[n][nPosPerAju]	:= (  M->DW2_VALAJU / aCols[n][nPosValor] ) * 100
		
	Case cReadVar = "M->DW2_PERAJU" .AND. M->DW2_PERAJU <= 0
		lReturn := .F.
		
	Case cReadVar = "M->DW2_PERAJU"
		aCols[n][nPosValAju]	:= aCols[n][nPosValor] * M->DW2_PERAJU / 100
		
EndCase

Return lReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMA011SubFx ³ Autor ³ Eduardo de Souza     ³ Data ³ 02/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Sub-Faixas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA011SubFx(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias                                                ³±±
±±³          ³ ExpC2 - Componente de Frete                                  ³±±
±±³          ³ ExpC3 - Item                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011SubFx(cAlias,cCodPas,cItem,cTabTar,nOpcx)

Local aNoFields    := {}
Local aNoFieldsDW2 := {"DW2_TABFRE", "DW2_ITEDVD"}
Local cSeek        := ""
Local bWhile       := { || .T. }
Local aHTmp        := {}
Local nPosValor    := 0
Local nPosValAju   := 0
Local nPosPerAju   := 0
Local cCampo       := ''
Local nCntFor      := 0
Local aArea        := GetArea()
Local nSeek        := 0
Local nValor       := 0
Local nPos         := 0

//-- Posiciona no componente de frete
DT3->(DbSetOrder(1))
DT3->(MsSeek(xFilial("DT3")+cCodPas))

//-- Campos que nao deverao aparecer na getdados
If cAlias == "DW1"
	aNoFields := { "DW1_ITEDT1" }
	If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
		AAdd(aNoFields   ,'DW1_FATPES')
		AAdd(aNoFieldsDW2,'DW2_FATPES')
	EndIf
	cSeek  := xFilial("DW1")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+cProdOri+cCodPas+cItem
	bWhile := { || DW1->(!Eof()) .And. DW1->DW1_FILIAL+DW1->DW1_TABFRE+DW1->DW1_TIPTAB+DW1->DW1_CDRORI+DW1->DW1_CDRDES+DW1->DW1_CODPRO+DW1->DW1_CODPAS+DW1->DW1_ITEDT1 == cSeek }
ElseIf cAlias == "DW0"
	aNoFields := { "DW0_ITEDTG" }
	If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
		AAdd(aNoFields   ,'DW0_FATPES')
		AAdd(aNoFieldsDW2,'DW2_FATPES')
	EndIf
	cSeek  := xFilial("DW0")+M->DVC_TABFRE+M->DVC_TIPTAB+cTabTar+cCodPas+cItem
	bWhile := { || DW0->(!Eof()) .And. DW0->DW0_FILIAL+DW0->DW0_TABFRE+DW0->DW0_TIPTAB+DW0->DW0_TABTAR+DW0->DW0_CODPAS+DW0->DW0_ITEDTG == cSeek }
ElseIf cAlias == "DW2"
	If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
		AAdd(aNoFieldsDW2,'DW2_FATPES')
	EndIf
EndIf

//-- Salva Area
SaveInter()

//-- Cria aHeader do DW2 - Sub-Tarifas da tabela de ajuste
aHeader := TMA011HdDW2(aNoFieldsDW2)

If !Empty(DT3->DT3_FAIXA2)
	If cAlias $ "DW0;DW1"
		If (nPos:= Ascan( aColsDW2, { |x| x[1]+x[2] == cCodPas + cItem } ) ) == 0
			(cAlias)->(dbSetOrder(1))
			(cAlias)->(MsSeek(cSeek))
			aHTmp      := aClone(aHeader)
			aCols      := {}
			nPosValor  := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DW2_VALOR' })
			nPosValAju := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DW2_VALAJU'})
			nPosPerAju := Ascan(aHeader, {|x| Alltrim(x[2]) == "DW2_PERAJU"})
			DbSelectArea(cAlias)
			While Eval(bWhile)
				Aadd(aCols,Array(Len(aHTmp)+1))
				For nCntFor := 1 To Len(aHTmp)
					//-- Troca o Prefixo do AHeader
					cCampo := StrTran(aHTmp[nCntFor,2],"DW2",PrefixoCpo(cAlias))
					If (cAlias)->(FieldPos(cCampo))> 0   //Nao Remover o FieldPos
						aHTmp[nCntFor,2] := cCampo
						If	aHTmp[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=FieldGet(FieldPos(aHTmp[nCntFor,2]))
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHTmp[nCntFor,2])
						EndIf
					Else
						aCols[Len(aCols),nCntFor] :=CriaVar(aHTmp[nCntFor,2])
					EndIf	
				Next nCntFor
				If nPosValor > 0
					aCols[Len(aCols)][nPosValor]   := &(cAlias+'->'+cAlias+'_VALOR')
				EndIf
				If nPosPerAju > 0
					aCols[Len(aCols)][nPosPerAju]  := IIf( Empty( aCols[Len(aCols)][nPosPerAju]) , 100, aCols[Len(aCols)][nPosPerAju] )
				EndIf
				If nPosValAju > 0
					aCols[Len(aCols)][nPosValAju]  := ( &(cAlias+'->'+cAlias+'_VALOR') * aCols[Len(aCols)][nPosPerAju] ) / 100
				EndIf
				//-- Verifica se existe o ajuste do item
				aCols[Len(aCols),Len(aHTmp)+1] := !DW2->(MsSeek(xFilial("DW2") + M->DVC_TABFRE + M->DVC_TIPTAB +M->DVC_CDRORI + ;
															  M->DVC_CDRDES + M->DVC_CODCLI+ M->DVC_LOJCLI + M->DVC_SEQTAB + M->DVC_CODPRO + M->DVC_SERVIC + cCodPas + cItem + aCols[Len(aCols)][1] + M->DVC_CODNEG ))
				(cAlias)->(dbSkip())
			EndDo  
			Aadd(aColsDW2,{ cCodPas, cItem, AClone(aCols), AClone(aHeader) } )

			// Excedente por Subfaixa
			TMA011SubExc(cAlias,cCodPas, cItem, cTabTar, nOpcx, cItem )
		EndIf

	ElseIf cAlias == "DW2"

		aCols := {}
		nPos  := Ascan( aColsDW2, { |x| x[1]+x[2] == DVD->DVD_CODPAS + DVD->DVD_ITEM } )
		If nPos > 0
			aCols := AClone(aColsDW2[nPos,3])
		EndIf
		DW2->(DbSetOrder(2))
		DW2->(MsSeek(cSeek := xFilial("DW2")+DVD->DVD_TABFRE + DVD->DVD_TIPTAB+DVD->DVD_CDRORI+DVD->DVD_CDRDES+DVD->DVD_CODCLI+DVD->DVD_LOJCLI+DVD->DVD_SEQTAB+DVD->DVD_CODPRO+DVD->DVD_CODNEG+DVD->DVD_SERVIC+DVD->DVD_CODPAS+DVD->DVD_ITEM))
		While DW2->(!Eof()) .And. cSeek == DW2->DW2_FILIAL + DW2->DW2_TABFRE + DW2->DW2_TIPTAB+ ; 
			DW2->DW2_CDRORI + DW2->DW2_CDRDES + DW2->DW2_CODCLI+ DW2->DW2_LOJCLI + DW2->DW2_SEQTAB+ ;
			DW2->DW2_CODPRO + DW2->DW2_CODNEG + DW2->DW2_SERVIC + DW2->DW2_CODPAS+ DW2->DW2_ITEDVD
										
			If nOpcx <> 5 .And. nOpcx <> 2
				nSeek := Ascan(aCols,{ |x| x[1] == DW2->DW2_ITEM })
			Else
				dbSelectArea("DW2")
				Aadd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					If	aHeader[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=FieldGet(FieldPos(aHeader[nCntFor,2]))
					Else
						aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
					EndIf
				Next nCntFor
				//-- O campo DW2_VALOR (Valor) e' virtual. Portanto, e' necessario procurar
				//-- seu valor na Tabela DT1/DTG
				nValor := 0          
				DW0->(dbSetOrder(1))
				DW1->(dbSetOrder(1))
				If DW1->(MsSeek(xFilial("DT1")+ M->DVC_TABFRE + M->DVC_TIPTAB + DVD->DVD_RGOTAB + DVD->DVD_RGDTAB+DVD->DVD_PRDTAB+;
					DVD->DVD_CODPAS+DVD->DVD_ITEM+GdFieldGet('DW2_ITEM',Len(aCols)) ))
					nValor := DW1->DW1_VALOR
				ElseIf DW0->(MsSeek(xFilial("DW0") + M->DVC_TABFRE + M->DVC_TIPTAB+cTabTar+DVD->DVD_CODPAS+DVD->DVD_ITEM+GdFieldGet('DW2_ITEM',Len(aCols)) ))
					nValor := DW0->DW0_VALOR
				EndIf
				GdFieldPut("DW2_VALOR", nValor , Len(aCols))
			  	GdFieldPut("DW2_PERAJU", GdFieldGet('DW2_PERAJU', Len(aCols)), Len(aCols))
				GdFieldPut("DW2_VALAJU", ( nValor * GdFieldGet("DW2_PERAJU",Len(aCols)) ) / 100, Len(aCols) )
				aCols[Len(aCols),Len(aHeader)+1]:=.F.
				nSeek := 0
			EndIf
			If nSeek > 0
				Aeval( aHeader, {|aCampo, nI| Iif(!AllTrim(aHeader[nI][2])$"DW2_VALOR.DW2_VALAJU", ;
										aCols[nSeek][nI] := If( aCampo[10] != 'V' .And. nOpcx<>3,;
										DW2->(FieldGet(FieldPos(aHeader[nI,2]))),  CriaVar(aHeader[nI,2], .T.) ),.T.) } )
				nValor := GdFieldGet('DW2_VALOR', nSeek)
				GdFieldPut("DW2_VALAJU", ( nValor * GdFieldGet("DW2_PERAJU", nSeek) ) / 100,  nSeek )
			EndIf
			DW2->(dbSkip())
		EndDo
		//-- Armazena Sub-Tarifas
		If nPos > 0
			aColsDW2[nPos,3] := AClone(aCols)
		Else
			Aadd( aColsDW2, { DVD->DVD_CODPAS, DVD->DVD_ITEM, aClone(aCols), aClone(aHeader) } )
		EndIf

		// Excedente por Subfaixa
		TMA011SubExc(cAlias,DVD->DVD_CODPAS, DVD->DVD_ITEM, cTabTar, nOpcx, DVD->DVD_ITEM)
			
	EndIf
EndIf

//-- Restaura Area
RestInter()
RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMA011HdDW2 ³ Autor ³ Eduardo de Souza     ³ Data ³ 02/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ aHeader da sub-faixa da tabela de ajuste                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA011HdDW2()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011HdDW2(aNoFields)

Local aHeadDW2  := {}
Local aDW2Stru  := FwFormStruct(2,"DW2")
Local nCont	  := 0

For nCont := 1 to Len(aDW2Stru:aFields)	
	If Ascan( aNoFields, GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_CAMPO") ) == 0  					
		Aadd( aHeadDW2,{GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_TITULO"),GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_CAMPO"),;
		GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_PICTURE"),GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_TAMANHO"),GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_DECIMAL"),;
		GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_VALID"  ),GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_USADO"  ),GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_TIPO"),;
		GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_ARQUIVO"),GetSX3Cache(aDW2Stru:aFields[nCont][1], "X3_CONTEXT")})
	EndIf				
Next nCont                                                      

Return aHeadDW2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
     
Private aRotina	:= {	{ STR0002 ,"TmsXPesqui", 0, 1,0,.F. },;	//"Pesquisar"
								{ STR0003 ,"TMSA011Mnt", 0, 2,0,NIL },;	//"Visualizar"
								{ STR0004 ,"TMSA011Mnt", 0, 3,0,NIL },;	//"Incluir"
								{ STR0005 ,"TMSA011Mnt", 0, 4,0,NIL },;	//"Alterar"
								{ STR0006 ,"TMSA011Mnt", 0, 5,0,NIL },; 	//"Excluir"
								{ STR0007 ,"TMSA011Est", 0, 8,0,NIL }}	//"Estrutura"

If ExistBlock("TMA011MNU")
	ExecBlock("TMA011MNU",.F.,.F.)
EndIf

Return(aRotina)


/*/{Protheus.doc} TMSA011TRT
//Complemento do ajuste % Base por Componente 
@author caio.y
@since 10/03/2017
@version undefined
@param nOpcx, numeric, Operação realizada no browse
@type function
/*/
Static Function TMSA011TRT(nOpcx)
Local aArea 		:= GetArea()
Local aAreaDVC    	:= DVC->(GetArea())
Local aAlter      	:= {}
Local cSeekDVE    	:= ''
Local aOldaHeader	:= Aclone( aHeader )
Local aOldaCols		:= Aclone( aCols )
Local IncOld     	:= Inclui
Local lRet        	:= .T.
Local nSeek       	:= 0
Local aNoFields		:= { "DJT_FILIAL", "DJT_TABFRE", "DJT_SEQTAB", "DJT_CDRORI", "DJT_CDRDES", "DJT_TIPTAB", "DJT_CODCLI", "DJT_LOJCLI", "DJT_CODPAS", "DJT_SERVIC", "DJT_CODPRO" }
Local aYesFields  	:= {}
Local nUsado      	:= 0
Local nOpc        	:= 0
Local nCntFor     	:= 0
Local nCont         := 0
Local nSavN       	:= Iif(Type('n')=="U",1,n)
Local cCodPas     	:= aFolder[nFolder,1]
Local oDlg, oGetD, oEnchoice				   			
Local lNoFields, lYesFields                    
Local nI              
Local cCdrOri, cCdrDes, cCdrOTab, cCdrDTab
Local nx
Local nPos			:= 0
Local aDJTStru  := FwFormStruct(2,"DJT")

Private cFolder
Default lEnchoice    := .F.

//-- Verifica se o componente utiliza TDA.
DT3->(dbSetOrder(1))
If DT3->(MsSeek(xFilial("DT3")+cCodPas))
	If DT3->DT3_TIPFAI <> '14'
		Help("",1,"TMSA01024") //-- Componente de frete nao configurado para utilizar TDA.
		Return .F.
	EndIF
EndIf

AAdd(aAlter,'DJT_VLAJUS')

aHeader		:= {}
aCols		:= {}

lNoFields	:= .T.
lYesFields	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDJT) == 0
	For nCont := 1 to Len(aDJTStru:aFields)	
		If Ascan( aNoFields, GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_CAMPO") ) == 0  
			++nUsado			
			Aadd( aHeader,{GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_TITULO"),GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_CAMPO"),;
			GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_PICTURE"),GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_TAMANHO"),GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_DECIMAL"),;
			GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_VALID"  ),GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_USADO"  ),GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_TIPO"),;
			GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_ARQUIVO"),GetSX3Cache(aDJTStru:aFields[nCont][1], "X3_CONTEXT")})
		EndIf							
	Next nCont     
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aCols para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DJT->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona PRIMEIRO aCols do DJT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsDJT) == 0  .Or. ( nPos := aScan(aColsDJT , {|x|x[1] == cCodPas }) ) == 0 
	If nOpcx <> 3 .And. Len(aFolder) > 0
		For nI := 1 To Len( aFolder )                            
			cFolder  := aFolder[nI][1]	 // Componente	
			cCdrOri  := aFolder[nI][10] // Regiao Origem do Componente
			cCdrDes  := aFolder[nI][11] // Regiao Destino do Componente
			cCdrOTab := aFolder[nI][12] // Regiao Origem da Tabela Mae 
			cCdrDTab := aFolder[nI][13] // Regiao Destino da Tabela Mae 		
			cProduto := aFolder[nI][14] // Produto		
			If DJT->( MsSeek( xFilial( "DJT" )+ M->DVC_CODCLI + M->DVC_LOJCLI + M->DVC_TABFRE + M->DVC_TIPTAB + cCdrOri + cCdrDes + M->DVC_SEQTAB + cProduto + M->DVC_SERVIC + cCodPas + cFolder + M->DVC_CODNEG) )	
									
				Aadd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					If	aHeader[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=DJT->(FieldGet(FieldPos(aHeader[nCntFor,2])))
					Else
						aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
					EndIf
				Next nCntFor	
							
				DJS->(dbSetOrder(1))
				If DJS->(MsSeek(xFilial("DJS")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOTab+cCdrDTab+M->DVC_CODPRO+cCodPas+cFolder))			
					aCols[Len(aCols),GdFieldPos('DJT_VLBASE')] := DJS->DJS_PERCEN
	  				aCols[Len(aCols),GdFieldPos('DJT_VLBAJU')] := (DJS->DJS_PERCEN * aCols[Len(aCols),GdFieldPos('DJT_VLAJUS')]) / 100			
	  			EndIf
	  			
  			ElseIf nOpcx <> 2	
  				DT3->(dbSetOrder(1))
				If DT3->(MsSeek( xFilial( "DT3" ) + cFolder ))
					If DT3->DT3_CODPAS <> cCodPas 
					
						Aadd( aCols, Array( nUsado + 1 ) )
						AEval( aHeader, {|aCampo, nI| aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],.T.) } )				
						
						DJS->(dbSetOrder(1))
						If DJS->(MsSeek(xFilial("DJS")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOTab+cCdrDTab+M->DVC_CODPRO+M->DVC_SERVIC+cCodPas+cFolder))			
							aCols[Len(aCols),GdFieldPos('DJT_VLBASE')] := DJS->DJS_PERCEN
		  					aCols[Len(aCols),GdFieldPos('DJT_VLBAJU')] := (DJS->DJS_PERCEN * aCols[Len(aCols),GdFieldPos('DJT_VLAJUS')]) / 100		
	  					EndIf
	  					aCols[Len(aCols),Len(aHeader)+1]   := .T.
	  					
	  				EndIF
  				EndIf
			EndIf
		Next nI		
		
		//-- Salva o aCols
		aAdd( aColsDJT , {cCodPas , AClone(aCols) } )    
		nPos	:= Len(aColsDJT)
		        
		//-- Desmarca todos os itens do aCols
		aEval(aCols, {|x| x[Len(x)] := .F. }) 
	Else                   	
		Inclui := .T.
		nI := 0
		DVE->( DbSetOrder( 1 ) )
		DVE->( MsSeek( cSeekDVE := xFilial("DVE") + M->DVC_TABFRE + M->DVC_TIPTAB ) )
		
		Do While DVE->( !Eof() .And. DVE_FILIAL + DVE_TABFRE + DVE_TIPTAB == cSeekDVE )
			
			DT3->(dbSetOrder(1))
			DT3->(MsSeek( xFilial( "DT3" ) + DVE->DVE_CODPAS ))
			
			IF (ascan(aColsDvo,{|x| x[4]== DT3->DT3_DESCRI })) > 0 .And. (DT3->DT3_CODPAS <> cCodPas  )
				nI++
		 		cFolder := DVE->DVE_CODPAS 
				Aadd( aCols, Array( nUsado + 1 ) )
				Aeval( aHeader, {|aCampo, nI|	aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],.T.) } )
				aCols[Len(aCols),nUsado+1]:=.F.
				aCols[nI,GdFieldPos('DJT_VLBASE')] := Posicione("DJS",1,xFilial("DJS")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO + cCodPas +cFolder,"DJS_PERCEN")
	  		EndIF
			DVE->(dbSkip())			
		
		EndDo      
		                                                                      
		aAdd( aColsDJT , {cCodPas , AClone(aCols) } ) 
		nPos	:= Len(aColsDJT)  
		       
		//-- Deleta os Itens do aCols Auxiliar		
		aEval(aColsDJT[Len(aColsDJT),2], {|x| x[Len(x)] := .T. }) 

   EndIf

Else
	nPos	:= aScan(aColsDJT , {|x|x[1] == cCodPas })	
	aCols 	:= AClone(aColsDJT[nPos,2])	
	
	If nOpcx <> 3 
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados 
	EndIf	       
	
EndIf

If Len(aCols) > 0 
	n:=1
	DEFINE MSDIALOG oDlg TITLE STR0052 From 9,0 To 27.5,80 OF oMainWnd //'Ajuste Base Componente Taxa de Dificil Acesso'
		
		oGetD := MSGetDados():New(15,3,138,314,nOpcx,'AllwaysTrue()','AllwaysTrue()',,IIf(nOpcx<>2,.T.,NIL),aAlter,,,Len(aCols),,,,"TM011DelDJT" )
		   
		TM011AjTDA(aColsDJT[nPos,2], aCols)	   
		                   
		oGetD:Refresh(.T.)        	                 		
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpc :=1, oDlg:End()},{||oDlg:End()}) CENTERED

Else
	Help("", 1, "TMSA01109") //Nao foi informado Complemento para este Ajuste
EndIf
	
aHeaderDJT := AClone(aHeader)
IF nOpc == 1
	aColsDJT[nPos,2] := AClone(aCols)
EndIF

Inclui  := IncOld
aHeader := aClone( aOldaHeader )
aCols   := aClone( aOldaCols )
n       := nSavN

RestArea( aArea )
RestArea( aAreaDVC )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011TDA ³ Autor ³ Andre Sperandio    ³ Data ³ 14.Abr.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Complemento do Ajuste de TDA                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011TDA(ExpN1,ExpL1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpL1 - Valida se devera mostrar a Enchoice. Esta Enchoice  ³±±
±±³          ³      so estara disponivel na 1a. Tela de Inclusao do Ajuste³±±
±±³          ³      para que o usuario informe os Dados da Tabela Mae.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA011TDA( nOpcx, lEnchoice )

Local aArea 		:= GetArea()
Local aAreaDVC    	:= DVC->(GetArea())
Local aAlter      	:= {}
Local cSeekDVE    	:= ''
Local aOldaHeader	:= Aclone( aHeader )
Local aOldaCols		:= Aclone( aCols )
Local IncOld      	:= Inclui
Local lRet        	:= .T.
Local nSeek       	:= 0
Local aNoFields		:= { "DWZ_FILIAL", "DWZ_TABFRE", "DWZ_SEQTAB", "DWZ_CDRORI", "DWZ_CDRDES", "DWZ_TIPTAB", "DWZ_CODCLI", "DWZ_LOJCLI", "DWZ_CODPAS", "DWZ_SERVIC", "DWZ_CODPRO" }
Local aYesFields  	:= {}
Local nUsado      	:= 0
Local nOpc        	:= 0
Local nCntFor     	:= 0
Local nCont       	:= 0
Local nSavN       	:= Iif(Type('n')=="U",1,n)
Local cCodPas     	:= aFolder[nFolder,1]
Local oDlg, oGetD, oEnchoice				   			
Local lNoFields, lYesFields                    
Local nI              
Local cCdrOri, cCdrDes, cCdrOTab, cCdrDTab
Local nx
Local aDJTStru  := FwFormStruct(2,"DJT")
Local aDWZStru  := FwFormStruct(2,"DWZ")

Private cFolder
Default lEnchoice    := .F.

//-- Verifica se o componente utiliza TDA.
DT3->(dbSetOrder(1))
If DT3->(MsSeek(xFilial("DT3")+cCodPas))
	If DT3->DT3_TIPFAI <> '13'
		Help("",1,"TMSA01024") //-- Componente de frete nao configurado para utilizar TDA.
		Return .F.
	EndIF
EndIf

AAdd(aAlter,'DWZ_VLAJUS')

aHeader	:= {}
aCols		:= {}

lNoFields	:= .T.
lYesFields	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDWZ) == 0

	For nCont := 1 to Len(aDWZStru:aFields)	
			If Ascan( aNoFields, GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_CAMPO") ) == 0  
				++nUsado 		
				Aadd( aHeader,{GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_TITULO"),GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_CAMPO"),;
				GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_PICTURE"),GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_TAMANHO"),GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_DECIMAL"),;
				GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_VALID"  ),GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_USADO"  ),GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_TIPO"),;
				GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_ARQUIVO"),GetSX3Cache(aDWZStru:aFields[nCont][1], "X3_CONTEXT")})				
			EndIf				
	Next nCont    
Else
	aHeader := Aclone(aHeaderDWZ)
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aCols para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DWZ->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona PRIMEIRO aCols do DWZ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsDWZ) == 0
	If nOpcx <> 3 .And. Len(aFolder) > 0
		For nI := 1 To Len( aFolder )                            
			cFolder  := aFolder[nI][1]	 // Componente	
			cCdrOri  := aFolder[nI][10] // Regiao Origem do Componente
			cCdrDes  := aFolder[nI][11] // Regiao Destino do Componente
			cCdrOTab := aFolder[nI][12] // Regiao Origem da Tabela Mae 
			cCdrDTab := aFolder[nI][13] // Regiao Destino da Tabela Mae 		
			cProduto := aFolder[nI][14] // Produto		
			If DWZ->( MsSeek( xFilial( "DWZ" )+ M->DVC_CODCLI + M->DVC_LOJCLI + M->DVC_TABFRE + M->DVC_TIPTAB + cCdrOri + ;
							cCdrDes + M->DVC_SEQTAB + cProduto + M->DVC_SERVIC + cFolder + M->DVC_CODNEG) )			
				Aadd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					If	aHeader[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=DWZ->(FieldGet(FieldPos(aHeader[nCntFor,2])))
					Else
						aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
					EndIf
				Next nCntFor				
				DVY->(dbSetOrder(1))
				DVY->(MsSeek(xFilial("DVY")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOTab+cCdrDTab+M->DVC_CODPRO+cFolder))			
				aCols[Len(aCols),GdFieldPos('DWZ_VLBASE')] := DVY->DVY_VLBASE
  				aCols[Len(aCols),GdFieldPos('DWZ_VLBAJU')] := (DVY->DVY_VLBASE * aCols[Len(aCols),GdFieldPos('DWZ_VLAJUS')]) / 100		
  			ElseIf nOpcx <> 2	
  				DT3->(dbSetOrder(1))
				DT3->(MsSeek( xFilial( "DT3" ) + cFolder ))
				IF !(DT3->DT3_TIPFAI $ '13/14' )
				
					Aadd( aCols, Array( nUsado + 1 ) )
					Aeval( aHeader, {|aCampo, nI|	aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],.T.) } )				
					DVY->(dbSetOrder(1))
					DVY->(MsSeek(xFilial("DVY")+M->DVC_TABFRE+M->DVC_TIPTAB+cCdrOTab+cCdrDTab+M->DVC_CODPRO+cFolder))			
			      aCols[Len(aCols),GdFieldPos('DWZ_VLBASE')] := DVY->DVY_VLBASE
  					aCols[Len(aCols),GdFieldPos('DWZ_VLBAJU')] := (DVY->DVY_VLBASE * aCols[Len(aCols),GdFieldPos('DWZ_VLAJUS')]) / 100		
  					aCols[Len(aCols),Len(aHeader)+1]   := .T.
  				EndIF
			EndIf
		Next nI		
		
      //-- Salva o aCols
		aColsDWZ := AClone(aCols)        
		                  
		//-- Desmarca todos os itens do aCols
		aEval(aCols, {|x| x[Len(x)] := .F. }) 
	Else                   	
		Inclui := .T.
		nI := 0
		DVE->( DbSetOrder( 1 ) )
		DVE->( MsSeek( cSeekDVE := xFilial("DVE") + M->DVC_TABFRE + M->DVC_TIPTAB ) )
		
		Do While DVE->( !Eof() .And. DVE_FILIAL + DVE_TABFRE + DVE_TIPTAB == cSeekDVE )
			
			DT3->(dbSetOrder(1))
			DT3->(MsSeek( xFilial( "DT3" ) + DVE->DVE_CODPAS ))
			
			IF (ascan(aColsDvo,{|x| x[4]== DT3->DT3_DESCRI })) > 0 .And. !(DT3->DT3_TIPFAI $ '13/14' )
				nI++
		 		cFolder := DVE->DVE_CODPAS 
				Aadd( aCols, Array( nUsado + 1 ) )
				Aeval( aHeader, {|aCampo, nI|	aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],.T.) } )
				aCols[Len(aCols),nUsado+1]:=.F.
				aCols[nI,GdFieldPos('DWZ_VLBASE')] := Posicione("DVY",1,xFilial("DVY")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cFolder,"DVY_VLBASE")
	  		EndIF
			DVE->(dbSkip())			
		
		EndDo                                                                            
		//-- Salva o aCols
		aColsDWZ := AClone(aCols)            
		//-- Deleta os Itens do aCols Auxiliar		
		aEval(aColsDWZ, {|x| x[Len(x)] := .T. }) 

   EndIf

Else
	
	aCols := AClone(aColsDWZ)		
	If nOpcx <> 3 
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados 
	EndIf	       
	
EndIf

If Len(aCols) > 0 
	n:=1
	
	DEFINE MSDIALOG oDlg TITLE STR0052 From 9,0 To 27.5,80 OF oMainWnd //'Ajuste Base Componente Taxa de Dificil Acesso'
		
		oGetD := MSGetDados():New(15,3,138,314,nOpcx,'AllwaysTrue()','AllwaysTrue()',,IIf(nOpcx<>2,.T.,NIL),aAlter,,,Len(aCols),,,,"TM011DelDWZ" )
		   
	   TM011AjTDA(aColsDWZ, aCols)	   
		                   
	   oGetD:Refresh(.T.)        	                 		
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpc :=1, oDlg:End()},{||oDlg:End()}) CENTERED

Else
	Help("", 1, "TMSA01109") //Nao foi informado Complemento para este Ajuste
EndIf
	
aHeaderDWZ := AClone(aHeader)
IF nOpc == 1
	aColsDWZ := AClone(aCols)
EndIF

Inclui  := IncOld
aHeader := aClone( aOldaHeader )
aCols   := aClone( aOldaCols )
n       := nSavN

RestArea( aArea )
RestArea( aAreaDVC )

//-- Desabilita as Teclas
TMA011DesTec()

Return  lRet
	                                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TM011AjuTDA³ Autor ³ Andre Sperandio    ³ Data ³ 14.Abr.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Os Itens do aCols do DWZ aparecerao deletados na 1a. chamada³±±
±±³          ³do 'Botao de Complemento do Ajuste'.Nas outras chamadas,    ³±±
±±³          ³estes itens poderao estar deletados ou nao.Esta funcao serve³±±
±±³          ³para auxiliar a GetDados a mostrar os itens deletados.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011AjuMin(ExpA1,ExpA2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - aCols Auxiliar do DWZ                               ³±±
±±³          ³ExpA2 - aCols                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao TMSA011Min()                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/	                  
Function  TM011AjTDA(aColsDWZ, aCols)	 
Local nX
                                    
// Se o Item do aCols Auxiliar estiver deletado, deleta este item tambem no aCols 
// Isto tem que ser feito, para que a GetDados mostre os itens deletados na Tela
For nX := 1 To Len(aColsDWZ)                                          
   If aColsDWZ[nX][Len(aColsDWZ[nX])]
		aCols[nX][Len(aCols[nX])] := .T.  
	EndIf	
Next

Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TM011DelDWZ  ³ Autor ³Andre Sperandio     ³ Data ³ 14.Abr.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nao permite desmarcar o componente no Complemento se o mesmo ³±±
±±³          ³ nao estiver no Folder da Tabela de Frete                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA011AjuFol(ExpA1,ExpN1,ExpC1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM011DelDWZ() 
Local nDesPasDWZ := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DWZ_DESPAS'})
Local cFolder    := Posicione( "DT3", 2, xFilial("DT3")+aCols[n,nDesPasDWZ], "DT3_CODPAS" )
Local nSeek      := 0

nSeek := Ascan(aFolder, {|x| x[1] == cFolder } )            
//-- O componente nao podera ser desmarcado se nao estiver no Folder  da Tabela 
If nSeek == 0 
	Return .F. 
EndIf 

Return .T.


/*/{Protheus.doc} TM011DelDJT
//Validação Exclusão
@author caio.y
@since 10/03/2017
@version undefined

@type function
/*/
Function TM011DelDJT() 
Local nDesPasDJT := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DJT_DESPAS'})
Local cFolder    := Posicione( "DT3", 2, xFilial("DT3")+aCols[n,nDesPasDJT], "DT3_CODPAS" )
Local nSeek      := 0

nSeek := Ascan(aFolder, {|x| x[1] == cFolder } )            
//-- O componente nao podera ser desmarcado se nao estiver no Folder  da Tabela 
If nSeek == 0 
	Return .F. 
EndIf 

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM011VlDWZ³ Autor ³Andre Sperandio        ³ Data ³14.Abr.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Preenche os campos de Valor / Percentual de Ajuste           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM011VlDWZ()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM011VlDWZ()

Local nVlAjus := 0
Local cCampo  := ReadVar()

If cCampo $  "M->DWZ_VLAJUS"                                
   nVlAjus := (GdFieldGet('DWZ_VLBASE',n) * (M->DWZ_VLAJUS / 100 )) 
   GdFieldPut('DWZ_VLBAJU', nVlAjus, n)
EndIf 

Return ( .T. )          


/*/{Protheus.doc} TM011VlDJT
//Gatilha valor ajustado
@author caio.y
@since 10/03/2017
@version undefined

@type function
/*/
Function TM011VlDJT()

Local nVlAjus	:= 0
Local cCampo 	:= ReadVar()

If cCampo $  "M->DJT_VLAJUS"                                
   
   nVlAjus := (GdFieldGet('DJT_VLBASE',n) * (M->DJT_VLAJUS / 100 )) 
   GdFieldPut('DJT_VLBAJU', nVlAjus, n)
	
EndIf 

Return .T.                                              

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA011Comp ³ Autor ³Aldo Barbosa dos Santos³ Data³ 12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta Excedente por Sub-Faixa                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011Comp()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA011Comp(nOpcx,cItemDVD)

Local cTitTabFre := AllTrim(RetTitle("DW2_TABFRE"))
Local cTitTipTab := AllTrim(RetTitle("DW2_TIPTAB"))
Local cTitCodPas := AllTrim(RetTitle("DW2_CODPAS"))
Local cTitItem   := AllTrim(RetTitle("DW2_ITEM"  ))
Local oDlgEsp
Local oGetSub
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local nPos        := 0
Local nOpcao      := 0
Local lAchou      := .F.
Local nCnt        := 0
Local ny          := 0
Local cCodPas     := aFolder[nFolder,1]

Local aNoFields   := {}
Local nPosValAte  := 0
Local aRetBox     := {}
Local cFolderName := ''


SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Verifica se existe o componente de frete.
DT3->(dbSetOrder(1))
If !DT3->(MsSeek(xFilial("DT3")+cCodPas))
	Help("",1,"TMSA08011") //-- Componente de frete nao encontrado.
	RestInter() //-- Restaura Area
	Return .F.
EndIf

//-- Verifica se o componente utiliza sub-faixa.
If Empty(DT3->DT3_FAIXA2)
	Help("",1,"TMSA08012") //-- Componente de frete nao configurado para utilizar sub-faixa.
	RestInter() //-- Restaura Area
	Return .F.
EndIf

If (nPos:= Ascan( aColsDY2, { |x| x[1]+x[2] == cCodPas + cItemDVD } ) ) == 0
	FillGetDados(	nOpcx, ;
						"DY2", ;
						1, 	 ;
						xFilial("DY2")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+M->DVC_CODPRO+cCodPas+cItemDVD , ;
						Iif(nOpcx <> 3,{ || DY2->DY2_FILIAL+DY2->DY2_TABFRE+DY2->DY2_TIPTAB+DY2->DY2_CDRORI+DY2->DY2_CDRDES+DY2->DY2_CODPRO+DY2->DY2_CODPAS+DY2->DY2_ITEDVD },{|| ''   }),;
						{|| .T.  },;
						aNoFields,;
						/*aYesFields*/,;
						/*lOnlyYes*/,;
						/*cQuery*/,;
						/*bMontCols*/)
	//-- Inicializa o primeiro item da sub-faixa.
   aCols[Len(aCols),GdFieldPos('DY2_ITEM')]   := StrZero(1, Len(DY2->DY2_ITEM))
  
	//-- Se nao encontrou item no DY2, traz na tela o item desmarcado 				
	aCols[Len(aCols),Len(aHeader)+1]   := .F.						      														
   
Else
	lAchou   := .T.
	aCols    := AClone(aColsDY2[nPos,3]	)
	aHeader  := AClone(aColsDY2[nPos,4])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE STR0055 FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL

@ aPosObj[1,1],010 SAY cTitTabFre + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],030 SAY M->DVC_TABFRE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],055 SAY cTitTipTab + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],085 SAY M->DVC_TIPTAB Of oDlgEsp PIXEL SIZE 10 ,9

@ aPosObj[1,1],105 SAY cTitCodPas + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 35 ,9
@ aPosObj[1,1],140 SAY Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI") Of oDlgEsp PIXEL SIZE 40 ,9

@ aPosObj[1,1],190 SAY STR0056 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],210 SAY cItemDVD Of oDlgEsp PIXEL SIZE 10 ,9

aAltera := {'DY2_EXCMIN','DY2_INTERV','DY2_PERMIN','DY2_PERMAX','DY2_VLREXC','DY2_PERAJU'} 

//       MsGetDados(                  nT ,              nL,              nB,                nR,  nOpc,        cLinhaOk,      cTudoOk,   cIniCpos,  lDeleta,  aAlter,nFreeze,lEmpty, nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
oGetSub:=MSGetDados():New(aPosObj[2,1]/2, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSA011CLOk()','AllWaysTrue',"+DY2_ITEM",nOpcx<>2, aAltera, 3, , 1)

//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := AClone(aColsDY2[nPos,3]),.T.)
oGetSub:Refresh(.T.)

If Empty(aCols)
	//-- Monta uma linha em branco.
	aadd(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		aCols[n][ny] := CriaVar(aHeader[nY][2])
	Next ny		                              
	aCols[n][Len(aHeader)+1] := .T.			                             
EndIf		

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetSub:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() },, ) Centered

//-- Atualiza array de aCols da sub-faixa
If nOpcao == 1
	If (nPos:= Ascan( aColsDY2, { |x| x[1]+x[2] == cCodPas+cItemDVD } ) ) == 0
		Aadd(aColsDY2,{ cCodPas, cItemDVD, AClone(aCols), AClone(aHeader) } )
	Else
		aColsDY2[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA011CLOk ³ Autor ³Aldo Barbosa dos Santos³ Data ³12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida linha do Excedente da sub-faixa                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA011CLOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA011CLOk()

Local lRet        := .F.

if Len(aCols) > 0

	lRet := MaCheckCols(aHeader,aCols,n)

	//-- Valida se esta deletado
	If lRet
		If GDDeleted(n)
			lRet := .T.
		//-- Na primeira linha Valida p/ baixo
		EndIf
	
		If !lRet
			Help(" ",1,"TMSA01107") //"Campo Ate'/Fator Peso Invalido ou ja existente"
		EndIf
	Endif	
Else
	lRet := .T.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA011VSFx³ Autor ³Aldo Barbosa dos Santos ³ Data ³ 12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Coluna da Getdados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA011VSFx()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA011VSEx()

Local lReturn 		:= .T.
Local nPosValor	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_VALOR"  } )
Local nPosValAju	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_VALAJU" } )
Local nPosPerAju	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_PERAJU" } )

Local nPosVlrExc	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_VLREXC" } )

Local nPosValMin	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_VALMIN" } )
Local nPosVlrMin	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_VLRMIN" } )
Local nPosPerMin	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_PERMIN" } )

Local nPosValMax	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_VALMAX" } )
Local nPosVlrMax	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_VLRMAX" } )
Local nPosPerMax	:= Ascan( aHeader, { |aField| AllTrim(aField[2]) = "DY2_PERMAX" } )


Local cReadVar  	:= ReadVar()

Do Case

	Case aCols[n][Len( aHeader ) + 1] // deletado
		lReturn := .T.
		
	Case cReadVar == "M->DY2_VLRMIN"
		aCols[n][nPosPerMin]	:= (  M->DY2_VLRMIN / aCols[n][nPosValMin] ) * 100

	Case cReadVar == "M->DY2_PERMIN"
		if M->DY2_PERMIN <= 0
			lReturn := .F.
		Else	
			aCols[n][nPosVlrMin]	:= aCols[n][nPosValMin] * M->DY2_PERMIN / 100
		Endif	

	Case cReadVar == "M->DY2_VLRMAX"
		aCols[n][nPosPerMax]	:= (  M->DY2_VLRMAX / aCols[n][nPosValMax] ) * 100

	Case cReadVar == "M->DY2_PERMAX"
		if M->DY2_PERMAX <= 0
			lReturn := .F.
		Else	
			aCols[n][nPosVlrMax]	:= aCols[n][nPosValMax] * M->DY2_PERMAX / 100
		Endif	

	Case cReadVar == "M->DY2_VLREXC"
		aCols[n][nPosPerAju]	:= (  M->DY2_VLREXC / aCols[n][nPosValor] ) * 100
		
	Case cReadVar == "M->DY2_PERAJU"
		if M->DY2_PERAJU <= 0
			lReturn := .F.
		Else	
			aCols[n][nPosVlrExc]	:= aCols[n][nPosValor] * M->DY2_PERAJU / 100
		Endif	
		
EndCase

Return lReturn


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMA011SubExc³ Autor ³Aldo Barbosa dos Santos³ Data ³12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Sub-Faixas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA011SubExc(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias                                                ³±±
±±³          ³ ExpC2 - Componente de Frete                                  ³±±
±±³          ³ ExpC3 - Item                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011SubExc(cAliasExc,cCodPas,cItem,cTabTar,nOpcx,cItemDT)

Local aNoFields    := {}
Local aNoFieldsDY2 := {"DY2_TABFRE", "DY2_ITEDVD"}
Local cSeek        := ""
Local bWhile       := { || .T. }
Local aHTmp        := {}
Local nPosValor    := 0
Local nPosValAju   := 0
Local nPosPerAju   := 0
Local cCampo       := ''
Local nCntFor      := 0
Local aArea        := GetArea()
Local nSeek        := 0
Local nValor       := 0
Local nValMin      := 0
Local nValMax      := 0
Local nExcMin      := 0
Local nInterv      := 0
Local nPos         := 0
Local cAlias       := ""

//-- Posiciona no componente de frete
DT3->(DbSetOrder(1))
DT3->(MsSeek(xFilial("DT3")+cCodPas))

//-- Campos que nao deverao aparecer na getdados
If cAliasExc == "DW1" // Item Tabela de Frete
	cAlias := "DY1"
	aNoFields := { "DY1_ITEDT1" }
	cSeek  := xFilial("DY1")+M->DVC_TABFRE+M->DVC_TIPTAB+M->DVC_CDRORI+M->DVC_CDRDES+cProdOri+cCodPas+cItemDT   
	bWhile := { || DY1->(!Eof()) .And. DY1->DY1_FILIAL+DY1->DY1_TABFRE+DY1->DY1_TIPTAB+DY1->DY1_CDRORI+DY1->DY1_CDRDES+DY1->DY1_CODPRO+DY1->DY1_CODPAS+DY1->DY1_ITEDT1 == cSeek }
ElseIf cAliasExc == "DW0" // Item Tabela de Tarifa
	cAlias := "DY0"
	aNoFields := { "DY0_ITEDTG" }
	cSeek  := xFilial("DY0")+M->DVC_TABFRE+M->DVC_TIPTAB+cTabTar+cCodPas+cItemDT
	bWhile := { || DY0->(!Eof()) .And. DY0->DY0_FILIAL+DY0->DY0_TABFRE+DY0->DY0_TIPTAB+DY0->DY0_TABTAR+DY0->DY0_CODPAS+DY0->DY0_ITEDTG == cSeek }
ElseIf cAliasExc == "DW2" // Item Tabela de Ajuste
	cAlias := "DY2"
EndIf

//-- Salva Area
SaveInter()

//-- Cria aHeader do DY2 - SubFaixas da tabela de ajuste 
aHeader := TMA011HdDY2(aNoFieldsDY2)

If !Empty(DT3->DT3_FAIXA2)
	If cAliasExc $ "DW0;DW1"
		If (nPos:= Ascan( aColsDY2, { |x| x[1]+x[2] == cCodPas + cItemDT } ) ) == 0
			(cAlias)->(dbSetOrder(1))
			(cAlias)->(MsSeek(cSeek))
			aHTmp      := aClone(aHeader)
			aCols      := {}
			DbSelectArea(cAlias)
			While Eval(bWhile)
				Aadd(aCols,Array(Len(aHTmp)+1))
				For nCntFor := 1 To Len(aHTmp)
					//-- Troca o Prefixo do AHeader
					cCampo := StrTran(aHTmp[nCntFor,2],"DY2",PrefixoCpo(cAlias))
					If (cAlias)->(FieldPos(cCampo))> 0   //Nao Remover o FieldPos
						aHTmp[nCntFor,2] := cCampo
						If	aHTmp[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=FieldGet(FieldPos(aHTmp[nCntFor,2]))
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHTmp[nCntFor,2])
						EndIf
					Else
						aCols[Len(aCols),nCntFor] :=CriaVar(aHTmp[nCntFor,2])
					EndIf	
				Next nCntFor
			  	GdFieldPut("DY2_VALOR", &(cAlias+'->'+cAlias+'_VALOR'), Len(aCols))
			  	GdFieldPut("DY2_PERAJU", IIf( Empty(GdFieldGet("DY2_PERAJU", Len(Acols))) , 100, GdFieldGet("DY2_PERAJU", Len(Acols) ) ), Len(aCols))
			  	GdFieldPut("DY2_VALAJU", ( &(cAlias+'->'+cAlias+'_VALOR') * GdFieldGet("DY2_PERAJU", Len(Acols) ) ) / 100 , Len(aCols))

			  	GdFieldPut("DY2_VALMIN", &(cAlias+'->'+cAlias+'_VALMIN') , Len(aCols))
			  	GdFieldPut("DY2_PERMIN", IIf( Empty(GdFieldGet("DY2_PERMIN", Len(Acols))) , 100, GdFieldGet("DY2_PERMIN", Len(Acols) ) ) , Len(aCols))
			  	GdFieldPut("DY2_VLRMIN", ( &(cAlias+'->'+cAlias+'_VALMIN') * GdFieldGet("DY2_PERMIN", Len(Acols) ) ) / 100 , Len(aCols))
				
			  	GdFieldPut("DY2_VALMAX", &(cAlias+'->'+cAlias+'_VALMAX') , Len(aCols))
			  	GdFieldPut("DY2_PERMAX", IIf( Empty(GdFieldGet("DY2_PERMAX", Len(Acols))) , 100, GdFieldGet("DY2_PERMAX", Len(Acols) ) ) , Len(aCols))
			  	GdFieldPut("DY2_VLRMAX", ( &(cAlias+'->'+cAlias+'_VALMAX') * GdFieldGet("DY2_PERMAX", Len(Acols) ) ) / 100 , Len(aCols))

			  	GdFieldPut("DY2_VLREXC", &(cAlias+'->'+cAlias+'_VALOR'), Len(aCols))
			  	GdFieldPut("DY2_EMINTB", &(cAlias+'->'+cAlias+'_EXCMIN'), Len(aCols))
			  	GdFieldPut("DY2_FRCTAB", &(cAlias+'->'+cAlias+'_INTERV'), Len(aCols))

				//-- Verifica se existe o ajuste do item
				aCols[Len(aCols),Len(aHTmp)+1] := !DW2->(MsSeek(xFilial("DY2") + M->DVC_TABFRE + M->DVC_TIPTAB +M->DVC_CDRORI + ;
															  M->DVC_CDRDES + M->DVC_CODCLI+ M->DVC_LOJCLI + M->DVC_SEQTAB + M->DVC_CODPRO + M->DVC_SERVIC + cCodPas + cItemDt + M->DVC_CODNEG))
				(cAlias)->(dbSkip())
			EndDo  
			Aadd(aColsDY2,{ cCodPas, cItemDT, AClone(aCols), AClone(aHeader) } )
		EndIf

	ElseIf cAliasExc == "DW2"

		aCols := {}
		nPos  := Ascan( aColsDY2, { |x| x[1]+x[2] == DVD->DVD_CODPAS + DVD->DVD_ITEM } )
		If nPos > 0
			aCols := AClone(aColsDY2[nPos,3])
		EndIf

		dbSelectArea("DY2")
		DY2->(DbSetOrder(2))
		if DY2->(MsSeek(cSeek := xFilial("DY2")+DVD->DVD_TABFRE + DVD->DVD_TIPTAB+DVD->DVD_CDRORI+DVD->DVD_CDRDES+DVD->DVD_CODCLI+DVD->DVD_LOJCLI+DVD->DVD_SEQTAB+DVD->DVD_CODPRO+DVD->DVD_SERVIC+cCodPas+cItemDT))
			If nOpcx <> 5 .And. nOpcx <> 2
				nSeek := Ascan(aCols,{ |x| x[1] == DY2->DY2_ITEM })
			Else
				dbSelectArea("DY2")
				Aadd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					If	aHeader[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=FieldGet(FieldPos(aHeader[nCntFor,2]))
					Else
						aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
					EndIf
				Next nCntFor
				//-- O campo DY2_VALOR (Valor) e' virtual. Portanto, e' necessario procurar
				//-- seu valor na Tabela DT1/DTG
				nValor := 0          
				DY0->(dbSetOrder(1))
				DY1->(dbSetOrder(1))
				If DY1->(MsSeek(xFilial("DY1")+ M->DVC_TABFRE + M->DVC_TIPTAB + DVD->DVD_RGOTAB + DVD->DVD_RGDTAB+DVD->DVD_PRDTAB+DVD->DVD_CODPAS+DVD->DVD_ITEM ))
					nValor  := DY1->DY1_VALOR  
					nValMin := DY1->DY1_VALMIN
					nValMax := DY1->DY1_VALMAX
					nExcMin := DY1->DY1_EXCMIN
					nInterv := DY1->DY1_INTERV
				ElseIf DY0->(MsSeek(xFilial("DY0") + M->DVC_TABFRE + M->DVC_TIPTAB+cTabTar+DVD->DVD_CODPAS+DVD->DVD_ITEM ))
					nValor  := DY0->DY0_VALOR
					nValMin := DY0->DY0_VALMIN
					nValMax := DY0->DY0_VALMAX
					nExcMin := DY0->DY0_EXCMIN
					nInterv := DY0->DY0_INTERV
				EndIf

			  	// minimo
			  	GdFieldPut("DY2_VALMIN", nValMin , Len(aCols))
			  	GdFieldPut("DY2_PERMIN", IIf( Empty(GdFieldGet("DY2_PERMIN", Len(Acols))) , 100, GdFieldGet("DY2_PERMIN", Len(Acols) ) ) , Len(aCols))
			  	GdFieldPut("DY2_VLRMIN", nValMin * GdFieldGet("DY2_PERMIN", Len(Acols))/100 , Len(aCols))

				// maximo			  	
			  	GdFieldPut("DY2_VALMAX", nValMax , Len(aCols))
			  	GdFieldPut("DY2_PERMAX", IIf( Empty(GdFieldGet("DY2_PERMAX", Len(Acols))) , 100, GdFieldGet("DY2_PERMAX", Len(Acols) ) ) , Len(aCols))
			  	GdFieldPut("DY2_VLRMAX", nValMax * GdFieldGet("DY2_PERMAX", Len(Acols))/100, Len(aCols))
			  	
			  	// valor
			  	GdFieldPut("DY2_VALOR" , nValor , Len(aCols))
			  	GdFieldPut("DY2_PERAJU", IIf( Empty(GdFieldGet('DY2_PERAJU', Len(aCols))) , 100, GdFieldGet('DY2_PERAJU', Len(aCols) )), Len(aCols))
			  	GdFieldPut("DY2_VLREXC", nValor * GdFieldGet('DY2_PERAJU', Len(aCols)) / 100, Len(aCols))

			  	GdFieldPut("DY2_EMINTB", nExcMin , Len(aCols))
			  	GdFieldPut("DY2_FRCTAB", nInterv , Len(aCols))

				aCols[Len(aCols),Len(aHeader)+1]:=.F.
				nSeek := 0
 
				aCols[Len(aCols),Len(aHeader)+1]:=.F.
				nSeek := 0
			EndIf
			If nSeek > 0
				Aeval( aHeader, {|aCampo, nI| Iif(!AllTrim(aHeader[nI][2])$"DY2_FRCTAB.DY2_EMINTB.DY2_VALMIN.DY2_VLRMIN.DY2_VALMAX..DY2_VLRMAX.DY2_VALOR.DY2_VLREXC", ;
										aCols[nSeek][nI] := If( aCampo[10] != 'V' .And. nOpcx<>3,;
										DY2->(FieldGet(FieldPos(aHeader[nI,2]))),  CriaVar(aHeader[nI,2], .T.) ),.T.) } )

			  	GdFieldPut("DY2_VLREXC", ( GdFieldGet('DY2_VALOR', nSeek) * GdFieldGet("DY2_PERAJU", Len(Acols) ) ) / 100 , Len(aCols))
			  	GdFieldPut("DY2_PERAJU", IIf( Empty(GdFieldGet('DY2_PERAJU', Len(aCols))) , 100, GdFieldGet('DY2_PERAJU', Len(aCols) )), Len(aCols))
			  	GdFieldPut("DY2_PERMIN", IIf( Empty(GdFieldGet("DY2_PERMIN", Len(Acols))) , 100, GdFieldGet("DY2_PERMIN", Len(Acols) ) ) , Len(aCols))
			  	GdFieldPut("DY2_VLRMIN", ( GdFieldGet('DY2_VALMIN', nSeek) * GdFieldGet("DY2_PERMIN", Len(Acols) ) ) / 100 , Len(aCols))
			  	GdFieldPut("DY2_PERMAX", IIf( Empty(GdFieldGet("DY2_PERMAX", Len(Acols))) , 100, GdFieldGet("DY2_PERMAX", Len(Acols) ) ) , Len(aCols))
			  	GdFieldPut("DY2_VLRMAX", ( GdFieldGet('DY2_VALMAX', nSeek) * GdFieldGet("DY2_PERMAX", Len(Acols) ) ) / 100 , Len(aCols))

			EndIf
			
	   Endif
	   
		//-- Armazena Sub-Tarifas
		If nPos > 0
			aColsDY2[nPos,3] := AClone(aCols)
		Else
			Aadd( aColsDY2, { DVD->DVD_CODPAS, DVD->DVD_ITEM, aClone(aCols), aClone(aHeader) } )
		EndIf
	EndIf
EndIf

//-- Restaura Area
RestInter()
RestArea( aArea )

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMA011HdDY2 ³ Autor ³Aldo Barbosa dos Santos³ Data ³12/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ aHeader da sub-faixa da tabela de ajuste                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA011HdDY2()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA011HdDY2(aNoFields)

Local aHeadDY2 := {}
Local nCont    := 0
Local aDY2Stru  := FwFormStruct(2,"DY2")


For nCont := 1 to Len(aDY2Stru:aFields)
	If Ascan( aNoFields, GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_CAMPO") ) == 0  					
		Aadd( aHeader,{GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_TITULO"),GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_CAMPO"),;
		GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_PICTURE"),GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_TAMANHO"),GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_DECIMAL"),;
		GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_VALID"  ),GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_USADO"  ),GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_TIPO"),;
		GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_ARQUIVO"),GetSX3Cache(aDY2Stru:aFields[nCont][1], "X3_CONTEXT")})
	EndIf							
Next nCont  

Return aHeadDY2

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMA011GTDE  ³ Autor ³ Gustavo Krug         ³ Data ³ 15/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho do campo Descricao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA011GTDE()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA011                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMA011GTDE()
	Local xRet 
		
	If Inclui
		xRet := POSICIONE('DTL',1,XFILIAL('DTL')+ M->DVC_TABFRE + M->DVC_TIPTAB,'DTL_DESCRI')                                   
	Else
		xRet := POSICIONE('DTL',1,XFILIAL('DTL')+ DVC->DVC_TABFRE + DVC->DVC_TIPTAB,'DTL_DESCRI')
	EndIf                                   
		
Return (xRet) 
