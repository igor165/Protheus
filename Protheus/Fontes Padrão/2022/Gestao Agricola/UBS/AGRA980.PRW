#INCLUDE "AGRA980.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#include "totvs.ch"
#include "topconn.ch"
#INCLUDE 'FWMBROWSE.CH'

/*
############################################################################
# Função   : AGRA980                                                       #
# Descrição: Cadastro de documentos e configuração do componente           #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 10/07/2014                                                    #
############################################################################
*/
Function AGRA980()
	Local oBrowse := Nil,nx
	Local cBarras := If(isSRVunix(),"/","\")
	Local cDuasBa := StrTran(cBarras+cBarras,'"','')

	cCamiDoc := GETMV("MV_DIRACA")
	If Empty(cCamiDoc)
		Help(" ",1,"SEMPARDOC",,CHR(13)+STR0006+ CHR(13)+STR0008+" MV_DIRACA  "+STR0007,3,0)
		Return
	Endif

	// Busca o caminho da Rootpath
	cRootpath := AGRRETCSER("Root")
	
	If .NOT. ExistDir( cCamiDoc )
		cCamiDoi  := cRootpath+cCamiDoc
		cCamiDoi  := StrTran(cCamiDoi,cDuasBa,cBarras)
		cCamPDoc  := cCamiDoi
		cCamiDoi  += If(SubStr(cCamiDoi,Len(cCamiDoi),1) <> cBarras,cBarras,"")	
		cCamiDoc  := cCamiDoi
	Else
		cCamPDoc  := cCamiDoc
	EndIf

	aMatDoc := Directory(cCamPDoc+"*.DOT")

	aMat := {}
	For nx := 1 To Len(aMatDoc)
		Aadd(aMat,{StrTran(aMatDoc[nx,1],".DOT","")})
	Next nx

	aRotina := MenuDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('NKX')
	oBrowse:SetDescription( STR0001 )
	oBrowse:Activate()
Return

/*
############################################################################
# Função   : ModelDef                                                      #
# Descrição: ModelDef                                                      #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 10/07/2014                                                    #
############################################################################
*/
Static Function ModelDef()
	Local oStruNKX := FwFormStruct( 1, "NKX" )//Layout
	Local oStruNKY := FwFormStruct( 1, "NKY" )//Estrutura do Layout de importação


	// Cria o objeto do Modelo de Dados
	oModel := MpFormModel():New( 'AGRA980',/*bPre*/,,, /*bCancel*/ )
	oModel:SetDescription( STR0001 ) //

	// Cabeçalho objeto do Modelo de Dados
	oModel:AddFields( 'CABEC', /*cOwner*/, oStruNKX )
	oModel:GetModel( "CABEC" ):SetDescription( STR0007 ) //Documento

	// Adiciona a estrutura da Grid
	oModel:AddGrid( 'ITEM', 'CABEC', oStruNKY,,{|oMdGrid| AGRA980LOK(oMdGrid)} )
	oModel:GetModel( "ITEM" ):SetDescription( STR0021 )//"Itens da canfiguração"

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation('ITEM',{{'NKY_FILIAL','xFilial("NKY")'},{"NKY_DOCUME","NKX_DOCUME"}},NKY->(IndexKey()))

	//Permissão para grid vazia
	oModel:GetModel( 'ITEM' ):SetOptional(.T.)

	//Controle de campo duplicado
	oModel:GetModel( 'ITEM' ):SetUniqueLine( { 'NKY_MACRO' } )

	// Chave primária do cabecalho(pai)
	oModel:SetPrimaryKey( {"NKX_FILIAL","NKX_DOCUME"} )

Return oModel

/*
############################################################################
# Função   : ViewDef                                                       #
# Descrição: ViewDef                                                       #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 10/07/2014                                                    #
############################################################################
*/
Static Function ViewDef()
	Local oView	  := Nil
	Local oModel	  := FwLoadModel( "AGRA980" )
	Local oStruNKX := FwFormStruct( 2,"NKX")
	Local oStruNKY := FwFormStruct( 2,"NKY")

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_NKX', oStruNKX, 'CABEC')// 'NKXMASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_NKY', oStruNKY, 'ITEM')//'NKYDETAIL' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 15 )
	oView:CreateHorizontalBox( 'INFERIOR', 85 )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_NKX', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_NKY', 'INFERIOR' )

	// Seta o campo incremental da Grid
	oView:AddIncrementField( 'ITEM','NKY_SEQUEN') //'NKYDETAIL', 'NKY_SEQUEN' )

Return oView

/*
############################################################################
# Função   : MenuDef                                                       #
# Descrição: Definição do menu                                             #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 10/07/2014                                                    #
############################################################################
*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGRA980' OPERATION 2 ACCESS 1
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGRA980' OPERATION 3 ACCESS 1
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGRA980' OPERATION 4 ACCESS 1
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGRA980' OPERATION 5 ACCESS 1
Return aRotina

/*
############################################################################
# Função   : AGRCF3DOC                                                     #
# Descrição: Consulta F3 do documento                                      #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 10/07/2014                                                    #
# OBS.     : ESSA FUNÇÃO É CHAMADA VIA DICIONÁRIO DE DADOS SXB             #
############################################################################
*/
Function AGRCF3DOC()
	Local lRet := .T.
	
	M->NKX_DOCUME := AGRF3MATRIZ(aMat,{STR0012},{1},STR0012+" DOT")
	lRet := Len(aMat) > 0
Return lRet

/*
############################################################################
# Função   : AGR980DOC                                                     #
# Descrição: Validação do documento                                        #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 15/07/2014                                                    #
# OBS.     : ESSA FUNÇÃO É CHAMADA VIA DICIONÁRIO DE DADOS SX3             #
############################################################################
*/
Function AGR980DOC()
	If Ascan(aMat,{|x| Alltrim(x[1]) = Alltrim(M->NKX_DOCUME)}) = 0
		Help(" ",1,"DOCNAOCAD",,CHR(13) + STR0012+" "+STR0010,3,0)
		Return .f.
	Else
		If AGRIFDBSEEK("NKX",Alltrim(M->NKX_DOCUME)+Space(Len(NKX->NKX_DOCUME)-len(Alltrim(M->NKX_DOCUME))),1,,xFilial("NKX"))
			Help(" ",1,"JAGRAVADO")
			Return .f.
		EndIf
	EndIf
Return .T.

/*
############################################################################
# Função   : AGRCONTAB                                                     #
# Descrição: Campos da tabela                                              #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 14/07/2014                                                    #
# OBS.     : ESSA FUNÇÃO É CHAMADA VIA DICIONÁRIO DE DADOS SXB             #
############################################################################
*/
Function AGRCONTAB()
	Local oModel	 := FWModelActive(),nx
	Local aCamSX3 := {},vVetCol := {},nColRet := 3
	Local vVetSM0 := {{"M0_FILIAL",STR0031},{"M0_NOME",STR0032},{"M0_NOMECOM",STR0033},{"M0_ENDCOB",STR0034},;
	{"M0_COMPCOB",STR0035},{"M0_CIDCOB",STR0036},{"M0_ESTCOB",STR0037},{"M0_CEPCOB",STR0038},;
	{"M0_BAIRCOB",STR0039},{"M0_CGC",STR0040},{"M0_INSC",STR0041},{"M0_TEL",STR0042},{"M0_ENDENT",STR0043},;
	{"M0_COMPENT",STR0044},{"M0_CIDENT",STR0045},{"M0_ESTENT",STR0046},{"M0_CEPENT",STR0047},{"M0_BAIRENT",STR0048}}
	Local vVetTab := {"NP9","NPN","SA1","SF2","SB1","NPM"} // Mostra os campos da tabela na consulta F3 quando usa tabela

	If !empty(oModel:GetValue('ITEM','NKY_CODTA'))
		vVetCol := {AGRTITULO('NPU_CODTA'),AGRTITULO('NPT_DESCRI'),AGRTITULO('NPU_CODVA'),AGRTITULO('NPU_DESVA')}
		AGRIFDBSEEK("NPT",oModel:GetValue('ITEM','NKY_CODTA'),1)
		While !NPT->(Eof()) .And. NPT->(NPT_FILIAL) == xFilial("NPT") .And. NPT->(NPT_CODTA) == oModel:GetValue('ITEM', 'NKY_CODTA')
			AGRIFDBSEEK("NPU",NPT->NPT_CODTA,1)
			//Carrega o vetor com os campos da tabela selecionada
			While !NPU->(Eof()) .and. NPU->(NPU_FILIAL) == xFilial("NPU") .And. NPU->(NPU_CODTA) == NPT->(NPT_CODTA)
				Aadd( aCamSX3,{NPU->NPU_CODTA,NPT->NPT_DESCRI,NPU->NPU_CODVA,NPU->NPU_DESVA})
				NPU->(DbSkip())
			End
			NPT->(DbSkip())
		End
	Else
		vVetCol := {STR0019,STR0018}
		nColRet := 1

		//Busca os campos (colunas) das família de tabelas para consulta F3
		aCamSX3 := AGRFACAESSX3(vVetTab,{"CAMPO","TITULO"})

		//Adiciona mais colunas específicas do SIGAMAT.EMP na consulta do F3
		For nx := 1 To Len(vVetSM0)
			Aadd(aCamSX3,vVetSM0[nx])
		Next nx
	EndIf

	M->NKY_CAMPO := AGRF3MATRIZ(aCamSX3,vVetCol,{nColRet},STR0017+" "+STR0013)
Return .T.

/*
############################################################################
# Função   : AGRA980VNPU                                                   #
# Descrição: Validação da linha                                            #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 15/07/2014                                                    #
############################################################################
*/
Function AGRA980VNPU()
	Local lRetorno := .t.
	Local cTipoAnalise := FWFldGet('NKY_CODTA')
	Local cVariAnalise := FWFldGet('NKY_CAMPO')

	If !Empty(cTipoAnalise)
		lRetorno := EXISTCPO("NPU",cTipoAnalise+cVariAnalise)
	Endif
Return (lRetorno)

/*
############################################################################
# Função   : AGRA980LOK                                                    #
# Descrição: Validação da linha                                            #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 15/07/2014                                                    #
############################################################################
*/
Function AGRA980LOK(oMdGrid)
Return .t.

/*
############################################################################
# Função   : AGRA980PD                                                     #
# Descrição: Produto x Documento                                           #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 16/07/2014                                                    #
############################################################################
*/
Function AGRA980PD()
	Local nDocu,vVetN := {},na
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{050,050,.t.,.t.})

	/*----------------------- RETIRADO.
	If !AGRIFDICIONA("SX3","NKX_FILIAL",2)
	AGRINCOMDIC("UPDAGR10",,.T.)
	EndIf
	----------------------- */
	nDocu   := Len(NKX->NKX_DOCUME)
	vVetN   := {"NKW_COMPON","NKW_DESCOM"}
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	aHeader := {}
	aCols   := {}

	// Emula menu de opções
	aRotina := {{STR0002,"AxPesqui",0,1},;
	{STR0003,"AxVisual",0,2},;
	{STR0003,"AxVisual",0,3}}

	aHeader := AGRCRIAGRID("NKW",vVetN)
	nDoc    := aScan(aHeader,{|x| AllTrim(x[2]) == "NKW_DOCUME"})
	nImp    := aScan(aHeader,{|x| AllTrim(x[2]) == "NKW_IMPRIM"})
	nDesD   := aScan(aHeader,{|x| AllTrim(x[2]) == "NKW_DESDOC"})

	If AGRIFDBSEEK("NKW",SB5->B5_COD,1)
		While !Eof() .And. NKW->NKW_FILIAL = xFilial("NKW") .And. NKW->NKW_COMPON = SB5->B5_COD
			AGRZERAACOLS(aHeader)
			nTamc := Len(aCols)
			DbSelectArea("NKW")
			For na := 1 To Fcount()
				nPos := aScan(aHeader,{|x| AllTrim(x[2]) == Fieldname(na)})
				If nPos > 0
					aCols[nTamc,nPos] := &("NKW->" + Fieldname(na))
					If Fieldname(na) = "NKW_DOCUME"
						aCols[nTamc,nDesD] := Posicione("NKX",1,xFilial("NKX")+NKW->NKW_DOCUME,"NKX_DESCRI")
					EndIf
				EndIf
			Next na
			AGRDBSELSKIP("NKW")
		End
	EndIf

	nOpca := 0
	Define MsDialog oDlgTela Title STR0028+" X "+STR0024 From aSize[7],00 To aSize[6],aSize[5] PIXEL
	oDlgTela:lMaximized := .t.

	@ 0,0 SCROLLBOX oDlg1 SIZE 0,0 OF oDlgTela BORDER
	oDlg1:Align := CONTROL_ALIGN_ALLCLIENT

	@ 1.5,10  Say Oemtoansi(STR0028)                                                   OF oDLG1 PIXEL
	@ 1.5,32  MsGet SB5->B5_COD Picture '@!'                                Size 80,7  OF oDLG1 PIXEL When .f.
	@ 1.5,120 MsGet Posicione("SB1",1,xFilial("SB1")+SB5->B5_COD,"B1_DESC") Size 140,7 OF oDLG1 PIXEL When .F.
	oGetDados := MSGetDados():New(aPosObj[2,1]-140,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,"AllwaysTrue()","AllwaysTrue()",,.T.,,,,1000)
	Activate Msdialog oDlgTela On Init EnchoiceBar(oDlgTela,{|| nOpca := 1,If(!AGRA980TOK(),nOpca := 0,oDlgTela:End())},{||oDlgTela:End()})

	If nOpca = 1
		Processa({|| AGRA980PRO()},STR0026)
	EndIf
Return

/*
############################################################################
# Função   : AGRA980TOK                                                    #
# Descrição: Consistências finais do grid                                  #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 18/07/2014                                                    #
############################################################################
*/
Static Function AGRA980TOK()
	Local nx
	For nx := 1 To Len(aCols)
		If !aCOLS[nx][Len(aCOLS[nx])] .And. Empty(aCols[nx,nImp])
			Alert(STR0019+" "+STR0029+" "+Str(nx,2))
			Return .f.
		EndIf
	Next nx
Return .t.

/*
############################################################################
# Função   : AGRA980PRO                                                    #
# Descrição: Processa arquivo temporário e grava relecionamente prod X Doc #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 17/07/2014                                                    #
############################################################################
*/
Static Function AGRA980PRO()
	Local nx, nQtdl := Len(aCols)
	ProcRegua(nQtdl)
	nRegl := 0
	For nx := 1 To Len(aCols)
		nRegl ++
		IncProc(STR0027+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando  -> "
		If !aCOLS[nx][Len(aCOLS[nx])]
			If !AGRIFDBSEEK("NKW",SB5->B5_COD+aCols[nx,nDoc],1)
				DbselectArea("NKW")
				Reclock("NKW",.T.)
				NKW->NKW_FILIAL := xFilial("NKW")
				NKW->NKW_COMPON := SB5->B5_COD
				NKW->NKW_DOCUME := aCols[nx,nDoc]
			Else
				Reclock("NKW",.F.)
			EndIf
			NKW->NKW_IMPRIM := aCols[nx,nImp]
			Msunlock("NKW")
		Else
			AGRDELETAREG("NKW",SB5->B5_COD+aCols[nx,nDoc])
		EndIf
	Next nx
Return

/*
############################################################################
# Função   : AGRA980VDOC                                                   #
# Descrição: Validação do documento                                        #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 16/07/2014                                                    #
############################################################################
*/
Function AGRA980VD()
	Local nx
	Local nDoc := aScan(aHeader,{|x| AllTrim(x[2]) == "NKW_DOCUME"})
	If !AGRIFDBSEEK("NKX",M->NKW_DOCUME,1,.T.)
		Return .f.
	EndIf
	For nx := 1 To Len(aCols)
		If nx <> n .And. aCols[nx,nDoc] = M->NKW_DOCUME
			Alert(STR0024+" "+Alltrim(M->NKW_DOCUME)+" "+STR0025+" "+Str(nx,2))
			Return .f.
		EndIf
	Next
Return .t.