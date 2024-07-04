#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPA122.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

Static oDbTree
Static asDbTree
Static scFistCargo
Static scCargoSeek
Static scAliasTmp
Static slOrdOrigi	:= .T.
Static saOrdProd
Static saAlternativos
Static slTreeChg	:= .F.

/*/{Protheus.doc} PCPA122
Consulta Ordens de Substituicao
@author Douglas Heydt
@since 01/05/2018
@version 12
@return oModel
@type function
/*/

Function PCPA122()
	Local aArea   := GetArea()
	Local oBrowse

	Default lAutoMacao := .F.

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		HELP(' ',1,"Help" ,,STR0018,2,0,,,,,,) //"Rotina não disponível nesta release."
		Return
	EndIf

	oBrowse := BrowseDef()
	IF !lAutoMacao
		oBrowse:Activate()
	ENDIF

	RestArea(aArea)

Return NIL

/*/{Protheus.doc} BrowseDef
Browse da Rotina
@author Douglas Heydt
@since 01/05/2018
@version 12
@return oModel
@type function
/*/
Static Function BrowseDef()
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SVF')
	oBrowse:SetDescription(STR0001) //"Ordem de Substituição"

Return oBrowse

/*/{Protheus.doc} MenuDef
MenuDef da Rotina
@author Douglas Heydt
@since 01/05/2018
@version 12
@return oModel
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002 Action 'PCPA122MNU(1)' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //VISUALIZAR

Return aRotina

//--------------------------------------------------------------------
/*/{Protheus.doc} PCPA123MNU()
Função que executa a view do programa.
Necessário desvio da abertura re-executando sempre a MenuDef e ViewDef
@param nOpcao	- Identifica a operação que está sendo executada (inclusão/exclusão/alteração/visualização)
@author brunno.costa
@since 30/10/2018
@version 1.0
@return nOK	- Identifica se o usuário confirmou (nOk==0) ou cancelou (nOk==1) a operação.
/*/
//--------------------------------------------------------------------
Function PCPA122MNU(nOpcao, aOrdPrdAux, aAlternAux, cCargoSeek)
	Local aArea		:= GetArea()
	Local aAreaSVF	:= SVF->(GetArea())
	Local aAreaSVJ	:= SVJ->(GetArea())
	Local aAreaSD4	:= SD4->(GetArea())
	Local nOpc   	:= 2
	Local nOk    	:= 0
	Local cTexto 	:= ""
	Local nTamCod	:= GetSx3Cache("D4_COD","X3_TAMANHO")
	Local nTamOP	:= GetSx3Cache("D4_OP","X3_TAMANHO")
	Local nTamFilial:= GetSx3Cache("VF_FILIAL","X3_TAMANHO")
	Local lFound	:= .F.

	Private nIndex		:= 0

	Default aOrdPrdAux	:= {}
	Default aAlternAux	:= {}
	Default cCargoSeek	:= Nil

	Default lAutoMacao	:= .F.

	saOrdProd		:= aClone(aOrdPrdAux)
	saAlternativos	:= aClone(aAlternAux)

	Do Case
		Case nOpcao == 1	//Visualização - Original ao Substituto
			saOrdProd	:= {SVF->(VF_FILIAL+VF_OP)}
			nOpc   		:= MODEL_OPERATION_VIEW
			cTexto 		:= STR0007	//"Consulta Substituições: Do Original ao Substituto"
			slOrdOrigi	:= .T.

			//Identifica Cargo que deve abrir posicionado (seleção do usuário)
			scCargoSeek	:= SVF->VF_COMP + ;
						Space(nTamCod) + ;
						SVF->VF_NUM

			scAliasTmp		:= Alias1oNv(saOrdProd, saAlternativos)
			(scAliasTmp)->(DbGoTop())

		Case nOpcao == 2	//Visualização - Substituto ao Original - Tela MATA381 - Todos
			nOpc   		:= MODEL_OPERATION_VIEW
			cTexto 		:= STR0008	//"Consulta Substituições: Do Substituto ao Original"
			slOrdOrigi	:= .F.

			scAliasTmp		:= Alias1oNv(saOrdProd, saAlternativos)
			(scAliasTmp)->(DbGoTop())

			SVJ->(DbSetOrder(4))	//VJ_FILIAL+VJ_ALTERN+VJ_LOCALIZ+VJ_NUMSERI
			SVF->(DbSetOrder(1))	//VF_FILIAL+VF_NUM+VF_OP+VF_COMP
			If SVJ->(DbSeek(xFilial("SVJ")+AllTrim(cCargoSeek)))
				While !SVJ->(EOf());
					.AND. SVJ->VJ_FILIAL == xFilial("SVJ");
					.AND. AllTrim(SVJ->VJ_ALTERN) == AllTrim(cCargoSeek)

					If SVF->(DbSeek(xFilial("SVF")+SVJ->VJ_NUM+Substring(aOrdPrdAux[1],nTamFilial+1,nTamOP)))
						lFound	:= .T.
						Exit
					EndIf
					SVJ->(DbSkip())
				End
			EndIf
			SVJ->(DbSetOrder(1))
			SVF->(DbSetOrder(1))

			If !lFound
				SVF->(DbGoTo((scAliasTmp)->RECSVF))
				SVJ->(DbGoTo((scAliasTmp)->RECSVJ))
				scCargoSeek	:= Nil
			Else
				//Identifica Cargo que deve abrir posicionado (seleção do usuário)
				scCargoSeek	:= cCargoSeek
			EndIf

	EndCase

	IF !lAutoMacao
		nOk := FWExecView(cTexto, "PCPA122", nOpc,,,,,,,,,)
	ENDIF
	aSize(saOrdProd, 0)
	aSize(saAlternativos, 0)

	RestArea(aAreaSVF)
	RestArea(aAreaSVJ)
	RestArea(aAreaSD4)
	RestArea(aArea)

Return nOk

/*/{Protheus.doc} Alias1oNv
Cria alias com os dados dos componentes
@author brunno.costa
@since 13/11/2018
@version 12
@return aLoad
@type function
/*/
Static Function Alias1oNv(aOrdPrdAux, aAlternAux)

	Local cAliasTmp		:= GetNextAlias()
	Local cQuery		:= ""

	DEFAULT aOrdPrdAux	:= {}
	DEFAULT aAlternAux		:= {}

	//Se utiliza Ordenação do Original ao Substituto
	If slOrdOrigi
		cQuery += " SELECT DISTINCT VF_NUM, VF_OP, '' AS VJ_ALTERN, VF_COMP, SVF.R_E_C_N_O_ AS RECSVF, 0 AS RECSVJ "

	//Se utiliza Ordenação do Substituto ao Original
	Else
		cQuery += " SELECT DISTINCT VF_NUM, VF_OP, VJ_ALTERN, VF_COMP, SVF.R_E_C_N_O_ AS RECSVF, SVJ.R_E_C_N_O_ AS RECSVJ "
	EndIf

	cQuery += " FROM " + RetSqlName("SVF") + " SVF JOIN " + RetSqlName("SVJ") + " SVJ  "
	cQuery += " 	ON SVF.VF_NUM = SVJ.VJ_NUM "
	cQuery += " 	AND SVF.VF_FILIAL = SVJ.VJ_FILIAL "
	cQuery += " WHERE SVF.D_E_L_E_T_ = ' '  "
	cQuery += " 		AND SVJ.D_E_L_E_T_ = ' ' "
	cQuery += " 		AND SVJ.VJ_FILIAL = '"+ xFilial("SVF")+ "' "

	If !Empty(aOrdPrdAux)
		cQuery += "			AND SVF.VF_FILIAL || SVF.VF_OP	IN ('"+ArrTokStr(aOrdPrdAux ,"', '",0)+"') "
	EndIf

	If !Empty(aAlternAux)
		cQuery += "			AND SVF.VF_OP || SVJ.VJ_ALTERN || SVJ.VJ_LOCAL || SVJ.VJ_SEQ || SVJ.VJ_OPORIG || SVJ.VJ_LOTE || SVJ.VJ_SUBLOTE || SVJ.VJ_ORDEM " // SVJ.VJ_LOCALIZ || SVJ.VJ_NUMSERI
		cQuery += "				IN ('"+ArrTokStr(aAlternAux,"', '",0)+"') "
	EndIf

	//Se utiliza Ordenação do Original ao Substituto
	If slOrdOrigi
		cQuery += " ORDER BY VF_NUM, VF_COMP "

	//Se utiliza Ordenação do Substituto ao Original
	Else
		cQuery += " ORDER BY VF_NUM, VJ_ALTERN "
	EndIf

	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	(cAliasTmp)->(DbGoTop())

Return cAliasTmp

/*/{Protheus.doc} ModelDef
Cria Modelo da rotina
@author Douglas Heydt
@since 01/05/2018
@version 12
@return oModel
@type function
/*/
Static Function ModelDef()
	Local oModel
	Local oStruSVF 	:= FWFormStruct( 1, 'SVF' )
	Local oStruT4I 	:= FWFormStruct( 1, 'T4I' )
	Local oStruSVJ 	:= FWFormStruct( 1, 'SVJ' )
	Local oEvent   	:= PCPA122EVDEF():New()

	oStruSVJ:AddField(""					,;	// [01]  C   Titulo do campo  -
					STR0013					,;	// [02]  C   ToolTip do campo - Legenda
					"LEGENDA"		   		,;	// [03]  C   Id do Field
					"C"						,;	// [04]  C   Tipo do campo
					30						,;	// [05]  N   Tamanho do campo
					0						,;	// [06]  N   Decimal do campo
					NIL						,;	// [07]  B   Code-block de validação do campo
					NIL						,;	// [08]  B   Code-block de validação When do campo
					NIL						,; 	// [09]  A   Lista de valores permitido do campo
					.F.						,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
					{|| GetCorLeg() }		,;	// [11]  B   Code-block de inicializacao do campo
					NIL						,;	// [12]  L   Indica se trata-se de um campo chave
					NIL						,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						)   // [14]  L   Indica se

	oModel := MPFormModel():New('PCPA122', ,)
	oModel:AddFields( 'SVFMASTER'	, /*cOwner*/	, oStruSVF)
	oModel:AddGrid( 'T4IDETAIL'		, 'SVFMASTER'	, oStruT4I)
	oModel:AddGrid( 'SVJDETAIL'		, 'SVFMASTER'	, oStruSVJ)

	oModel:SetPrimaryKey({})
	oModel:SetRelation("T4IDETAIL", {{"T4I_FILIAL"	,"xFilial('T4I')"},;
									{"T4I_NUM"		, "VF_NUM" }},;
									T4I->(IndexKey(3)))

	oModel:SetRelation("SVJDETAIL", {{"VJ_FILIAL"	,"xFilial('SVJ')"},;
									{"VJ_NUM"		, "VF_NUM" }},;
									SVJ->(IndexKey(3)))

	oModel:GetModel( 'SVFMASTER' ):SetDescription( STR0001 ) //"Ordem de Substituição"
	oModel:GetModel( 'T4IDETAIL' ):SetDescription( STR0009 ) //"Endereços Anteriores"
	oModel:GetModel( 'SVJDETAIL' ):SetDescription( STR0006 ) //"Alternativos"

	oModel:InstallEvent("PCPA122EVDEF", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Cria View da rotina
@author Douglas Heydt
@since 01/05/2018
@version 12
@return oView
@type function
/*/
Static Function ViewDef()
	Local oModel 		:= FWLoadModel( 'PCPA122' )
	Local oStruSVF 		:= FWFormStruct( 2, 'SVF')
	Local oStruT4I 		:= FWFormStruct( 2, 'T4I', {|cCampo| !('|'+AllTrim(cCampo)+'|' $ "|T4I_NUM|" )})
	Local oStruSVJ 		:= FWFormStruct( 2, 'SVJ', {|cCampo| !('|'+AllTrim(cCampo)+'|' $ "|VJ_NUM|" )})
	Local lMVLocaliz	:= AllTrim(SuperGetMV("MV_LOCALIZ", .F., .F.)) == "S"

	oView :=FWFormView():New()
	oView:SetModel(oModel)

	oStruSVJ:AddField(	"LEGENDA"		,;	// [01]  C   Nome do Campo
						"00"			,;	// [02]  C   Ordem
						""				,;	// [03]  C   Titulo do campo
						""				,;	// [04]  C   Descricao do campo
						NIL				,;	// [05]  A   Array com Help
						"C"				,; 	// [06]  C   Tipo do campo
						"@BMP"			,;	// [07]  C   Picture
						NIL				,;	// [08]  B   Bloco de Picture Var
						NIL				,;	// [09]  C   Consulta F3
						.F.				,;	// [10]  L   Indica se o campo é alteravel
						NIL				,;	// [11]  C   Pasta do campo
						NIL				,;	// [12]  C   Agrupamento do campo
						NIL				,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL				,;	// [15]  C   Inicializador de Browse
						.T.				,;	// [16]  L   Indica se o campo é virtual
						NIL				,;	// [17]  C   Picture Variavel
						NIL				)	// [18]  L   Indica pulo de linha após o campo

	//Adicao dos modelos da View
	oView:AddField('VIEW_SVF'		, oStruSVF, 'SVFMASTER')
	oView:AddGrid('VIEW_SVJ'		, oStruSVJ, 'SVJDETAIL')
	oView:AddOtherObject("VIEW_TREE", {|oPanel| MontaTree(oPanel, oModel)})

	//Atribuição dos Titulos da View
	oView:EnableTitleView("VIEW_TREE"	, STR0011)	//"Substituições desta OP:"
	oView:EnableTitleView("VIEW_SVJ"	, STR0012)	//"Alternativos Utilizados:"

	//Criação dos Box da View
	oView:CreateVerticalBox( 'LEFT', 20 )
	oView:CreateVerticalBox( 'RIGHT' , 80 )
	oView:CreateHorizontalBox( 'RIGHT_TOP'		, 270	, 'RIGHT'	, .T.)
	oView:CreateHorizontalBox( 'RIGHT_BOTTOM'	, 100	, 'RIGHT'	, .F.)

	//Vinculo dos objetos com os Boxes da View
	oView:SetOwnerView( 'VIEW_TREE'	, 'LEFT' )
	oView:SetOwnerView( 'VIEW_SVF'	, 'RIGHT_TOP' )
	oView:SetOwnerView( 'VIEW_SVJ'	, 'RIGHT_BOTTOM' )

	If lMVLocaliz
		oView:addUserButton(STR0009, "", {|| a122Endere()}, STR0009/*[ cToolTip ]*/, /*[ nShortCut ]*/, /*[ aOptions ]*/, .T.)	//"Endereços Anteriores"
	EndIf

	oView:addUserButton(STR0013, "", {|| a122Legend()}, STR0013/*[ cToolTip ]*/, /*[ nShortCut ]*/, /*[ aOptions ]*/, .T.)	//"Legenda"

Return oView

/*/{Protheus.doc} MontaTree
Cria Tree de Estrutura Invertida com base na SG1: do COMPONENTE ao PAI
@author brunno.costa
@since 13/11/2018
@version P12
@return Nil
@param oView, object, objeto da view
@param oModel, object, objeto do modelo
@type Function
/*/
Static Function MontaTree(oPanel, oModel, lFirst)

	Local cCargo		:= ""
	Local cFirCarBkp	:= ""
	Local nTamCod   	:= GetSx3Cache("D4_COD","X3_TAMANHO")
	Local nTamNum   	:= GetSx3Cache("VF_NUM","X3_TAMANHO")
	Local aAreaSVF	 	:= SVF->(GetArea())
	Local aAreaSVJ		:= SVJ->(GetArea())
	Local naScan		:= 0

	Default lFirst     := .T.
	Default lAutoMacao := .F.

	IF !lAutoMacao
		oDbTree				:= DbTree():New(0,0,100,100, oPanel,,,.T.)
		oDbTree:Align		:= CONTROL_ALIGN_ALLCLIENT
		oDbTree:bChange		:= {|o,x,y| AcaoTreeCh() }						// Posicao x,y em relacao a Dialog
	ENDIF

	If Empty(asDbTree)
		asDbTree	:= {}
	Else
		aSize(asDbTree, 0)
	EndIf

	cFirCarBkp	:= Nil
	scFistCargo	:= Nil

	//Percorre 1o Nível da Tree - Componentes
	While !(scAliasTmp)->(Eof())
		aAreaAux 	:= (scAliasTmp)->(GetArea())

		If slOrdOrigi
			cCargo	:= (scAliasTmp)->VF_COMP + ;
						Space(nTamCod) + ;
						(scAliasTmp)->VF_NUM + ;
						StrZero((scAliasTmp)->RECSVF, 9) + ;
						StrZero((scAliasTmp)->RECSVJ, 9) + ;
						StrZero(nIndex++, 9) + 'CODI'
		Else
			cCargo	:= (scAliasTmp)->VJ_ALTERN + ;
						Space(nTamCod) + ;
						Space(nTamNum) + ;
						StrZero((scAliasTmp)->RECSVF, 9) + ;
						StrZero((scAliasTmp)->RECSVJ, 9) + ;
						StrZero(nIndex++, 9) + 'CODI'
		EndIf

		If scFistCargo == Nil
			scFistCargo := cCargo
		EndIf

		naScan	:=	aScan(asDbTree,{|x| Left(x[1],Len(cCargo)-31) == Left(cCargo,Len(cCargo)-31) .and. Empty(x[2] )} )
		If naScan == 0
			aAdd(asDbTree,{cCargo, ""})

			//-- Adiciona o Pai na Estrutura
			oDbTree:AddTree(PromptTree(cCargo), .F., 'FOLDER5', 'FOLDER6', , , cCargo)
			oDbTree:TreeSeek(cCargo)

			//Processa o Próximo Nível
			NextNivel(cCargo, 1)

			oDbTree:EndTree()
		EndIf

		oDbTree:TreeSeek(scFistCargo)
		oDbTree:PTCollapse()		//Recolhe Pasta
		RestArea(aAreaAux)

		(scAliasTmp)->(DbSkip())
		If Empty(cFirCarBkp) .AND. !Empty(scFistCargo)
			cFirCarBkp	:= scFistCargo
			scFistCargo	:= Nil
		ElseIf !Empty(scFistCargo)
			scFistCargo	:= Nil
		EndIf
	EndDo

	slTreeChg	:= .T.

	If!Empty(scCargoSeek)
		If !oDbTree:TreeSeek(scCargoSeek)//Posiciona no item proposto na chamada da PCPA122MNU
			oDbTree:TreeSeek(cFirCarBkp)//Posiciona no primeiro Item
		EndIf
		oDbTree:PTCollapse()		//Recolhe Pasta
	ElseIf !Empty(cFirCarBkp)
		oDbTree:TreeSeek(cFirCarBkp)//Posiciona no primeiro Item
		oDbTree:PTCollapse()		//Recolhe Pasta
	EndIf
	AcaoTreeCh()

	RestArea(aAreaSVF)
	RestArea(aAreaSVJ)

	(scAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} NextNivel
Processamento Next Nivel da Estrutura (Recursiva)
@author brunno.costa
@since 13/11/2018
@version P12
@return Nil
@param cCargo, characters, cCargo do item
@param nProximo, numeric, descricao
@type Function
/*/
Static Function NextNivel(cCargo, nProximo)

	Local aAreaSVF		:= SVF->(GetArea())
	Local aAreaSVJ		:= SVJ->(GetArea())
	Local cOldCargL		:= oDbTree:GetCargo()
	Local cNum			:= RetFrCargo(cCargo, 3)
	Local nCont 		:= 0
	Local nRecSVF		:= 0
	Local nRecSVJ		:= 0
	Local nIndSVF		:= 1	//VF_FILIAL+VF_NUM+VF_OP+VF_COMP
	Local nIndSVJ		:= 3	//VJ_FILIAL+VJ_NUM+VJ_ALTERN+VJ_LOCAL+VJ_TRT+VJ_SEQ+VJ_OPORIG+VJ_LOTE+VJ_SUBLOTE+VJ_ORDEM+VJ_LOCALIZ+VJ_NUMSERI
	Local cAliasAux
	Local aAlternAux		:= {}

	Default nProximo 	:= 0

	If slOrdOrigi	//Do Original ao Substituto
		SVF->(dbSetOrder(nIndSVF))
		SVJ->(dbSetOrder(nIndSVJ))
		If SVF->(dbSeek(xFilial('SVF') + cNum, .F.))
			If SVJ->(dbSeek(xFilial('SVJ') + SVF->VF_NUM, .F.))
				Do While !SVJ->(Eof()) .And. SVJ->(VJ_FILIAL+VJ_NUM) == xFilial("SVJ")+SVF->VF_NUM
					nCont++
					//Bloco de validação de desempenho para não carregar na Tree todos os componentes do 2o nível (não visível)
					//Adiciona apenas um sub-item de 2o Nível para aplicar o [+] da Tree, adiciona os demais ao clicar nele
					If nProximo == 0 .AND. nCont > 1
						Exit
					Endif

					//Processa o próximo nível da estrutura - trecho de loop
					nRecSVF		:= SVF->(Recno())
					nRecSVJ		:= SVJ->(Recno())
					If ProcNxtNiv(cCargo, nProximo)
						SVJ->(dbSkip())
						Loop
					EndIf
					SVF->(DbGoTo(nRecSVF))
					SVJ->(DbGoTo(nRecSVJ))

					SVJ->(dbSkip())
				EndDo
			EndIf
		EndIf

	Else	//Do Substituto ao Original
		//Processa o próximo nível da estrutura - trecho de loop
		nRecSVF		:= SVF->(Recno())
		nRecSVJ		:= SVJ->(Recno())

		SVF->(DbGoTo(RetFrCargo(cCargo, 4)))
		If !SVF->(Eof())
			SVJ->(DbGoTo(RetFrCargo(cCargo, 5)))
			aAlternAux		:= {SVF->VF_OP+SVJ->(VJ_ALTERN+VJ_LOCAL+VJ_SEQ+VJ_OPORIG+VJ_LOTE+VJ_SUBLOTE+VJ_ORDEM)}
			cAliasAux	:= Alias1oNv(Nil, aAlternAux)
			While !(cAliasAux)->(Eof())
				nCont++
				//Bloco de validação de desempenho para não carregar na Tree todos os componentes do 2o nível (não visível)
				//Adiciona apenas um sub-item de 2o Nível para aplicar o [+] da Tree, adiciona os demais ao clicar nele
				If nProximo == 0 .AND. nCont > 1
					Exit
				Endif
				If cNum >= (cAliasAux)->VF_NUM .OR. Empty(cNum)
					SVF->(DbGoTo((cAliasAux)->RECSVF))
					SVJ->(DbGoTo((cAliasAux)->RECSVJ))
					If ProcNxtNiv(cCargo, nProximo)
						(cAliasAux)->(DbSkip(()))
						Loop
					EndIf
				EndIf
				(cAliasAux)->(DbSkip(()))
			EndDo
			(cAliasAux)->(DbCloseArea())
			SVF->(DbGoTo(nRecSVF))
			SVJ->(DbGoTo(nRecSVJ))
		EndIf
	EndIf

	oDbTree:TreeSeek(cOldCargL)
	RestArea(aAreaSVF)
	RestArea(aAreaSVJ)

Return

/*/{Protheus.doc} ProcNxtNiv
Processamento Next Nível Estrutura - Trecho de Loop (Recursiva)
@author brunno.costa
@since 13/11/2018
@version P12
@return lLoop, logical, indica se deve dar loop no registro atual para não incluir na tree
@param cCargo, characters, cCargo do item
@param nProximo, numeric, controla os próximos níveis que serão processados
@type Function
/*/
Static Function ProcNxtNiv(cCargoPai, nProximo)

	Local aAreaSVF 		:= SVF->(GetArea())
	Local aAreaSVJ 		:= SVJ->(GetArea())
	Local cPrompt  		:= ""
	Local cFolderA 		:= 'FOLDER5'
	Local cFolderB 		:= 'FOLDER6'
	Local cCargo		:= ""
	Local cOldCargo		:= ""
	Local cOldCargL		:= oDbTree:GetCargo()
	Local lLoop 		:= .F.
	Local naScan		:= 0
	Local nTamCod		:= GetSx3Cache("VF_COMP", "X3_TAMANHO")
	Local lAddItem		:= .T.

	If slOrdOrigi
		cCargo	:= SVJ->VJ_ALTERN +;
					SVF->VF_COMP +;
					SVJ->VJ_NUM +;
					StrZero(SVF->(Recno()), 9) +;
					StrZero(SVJ->(Recno()), 9) +;
					StrZero(nIndex++, 9) + 'COMP'
	Else
		cCargo	:= SVF->VF_COMP +;
					SVJ->VJ_ALTERN +;
					SVF->VF_NUM +;
					StrZero(SVF->(Recno()), 9) +;
					StrZero(SVJ->(Recno()), 9) +;
					StrZero(nIndex++, 9) + 'COMP'
	EndIf

	//Verifica se já adicionou o item na Tree - Sem Recno
	naScan	:=	aScan(asDbTree,{|x| x[2] == cCargoPai .and.;
				Left(x[1],Len(cCargo)-31) == Left(cCargo,Len(cCargo)-31) } )

	If naScan > 0
		nIndex--
		cCargo	:= asDbTree[naScan][1]
	EndIf

	//Se não encontra o Cargo na Tree, adiciona
	cOldCargo := oDbTree:GetCargo()
	If !oDbTree:TreeSeek(cCargo)
		lAddItem	:= .T.
	ElseIf Len(AllTrim(oDbTree:GetCargo())) != Len(AllTrim(cCargo))
		lAddItem	:= .T.
	Else
		lAddItem	:= .F.
	EndIf
	oDbTree:TreeSeek(cOldCargo)

	If lAddItem
		If !oDbTree:TreeSeek(cCargo)
			aAdd(asDbTree,{cCargo, oDbTree:GetCargo()})
			cPrompt	:= PromptTree(cCargo)
			oDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderB,,, 2)

		ElseIf Len(AllTrim(oDbTree:GetCargo())) != Len(AllTrim(cCargo))
			oDbTree:TreeSeek(cOldCargo)
			aAdd(asDbTree,{cCargo, oDbTree:GetCargo()})
			cPrompt	:= PromptTree(cCargo)
			oDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderB,,, 2)
		EndIf
	EndIf

	nProximo--
	//Se necessário, processa o próximo nível
	If nProximo > 0
		oDbTree:TreeSeek(cCargo)
		NextNivel(cCargo, nProximo)
		oDbTree:PTCollapse()
	EndIf

	oDbTree:TreeSeek(cOldCargL)

	RestArea(aAreaSVF)
	RestArea(aAreaSVJ)

Return lLoop

/*/{Protheus.doc} AcaoTreeCh
Execuções de ações durante clique/change na Tree
@author brunno.costa
@since 13/11/2018
@version P12
@return Nil
@type Function
/*/
Static Function AcaoTreeCh()

	Local cCargo		:= ""//oDbTree:GetCargo()
	Local oModel		:= FwModelActive()
	Local oView			:= FwViewActive()
	Local cNUM			:= RetFrCargo(cCargo, 3)
	Local nIndSVF	 	:= 1	//VF_FILIAL+VF_NUM+VF_OP+VF_COMP
	Local aAreaSVF		:= SVF->(GetArea())

	Default lAutoMacao := .F.

	IF !lAutoMacao
		cCargo := oDbTree:GetCargo()
	ENDIF

	SVF->(DbGoTo(RetFrCargo(cCargo, 4)))
	SVJ->(DbGoTo(RetFrCargo(cCargo, 5)))

	IF !lAutoMacao
		//Somente para os PI's não abertos nos próximos dois níveis
		If slTreeChg .and. oDbTree:Nivel() == 1 .and. !Empty(cCargo)
			slTreeChg	:= .F.
			NextNivel(cCargo, 1)
			slTreeChg	:= .T.
		EndIf

		oModel:DeActivate()
		oModel:Activate()

		If oView:isActive()
			oView:Refresh("VIEW_SVF")
			oView:Refresh("VIEW_SVJ")
		EndIf

		oDbTree:SetFocus()
	ENDIF
	RestArea(aAreaSVF)

Return

/*/{Protheus.doc} RetFrCargo
Retorna o código do produto selecionado referente o cargo
@author brunno.costa
@since 13/11/2018
@version P12
@return componente, caracters, código do produto relacionado ao cCargo
@param cCargo, characters, descricao
@type Function
/*/
Static Function RetFrCargo(cCargo, nOpcao)
	Local oReturn
	Local nTamCod	:= GetSx3Cache("VF_COMP","X3_TAMANHO")
	Local nTamNum	:= GetSx3Cache("VF_NUM","X3_TAMANHO")

	If 	nOpcao == 1		//Produto Selecionado
		oReturn 	:= SubStr(cCargo,1, nTamCod)

	ElseIf nOpcao == 2	//Pai do Produto Selecionado
		oReturn 	:= Substr( cCargo, nTamCod + 1, nTamCod)

	ElseIf 	nOpcao == 3	//_NUM relacionado ao Cargo
		oReturn 	:= Substr( cCargo, nTamCod*2 + 1, nTamNum)

	ElseIf 	nOpcao == 4	//Recno SVF
		oReturn 	:= Val(SubStr(cCargo, nTamCod*2 + nTamNum + 1, 9))

	ElseIf 	nOpcao == 5	//Recno SVJ
		oReturn 	:= Val(SubStr(cCargo, nTamCod*2 + nTamNum + 1 + 9, 9))

	EndIf
Return oReturn

/*/{Protheus.doc} PromptTree
Gera o texto Prompt de exibição do item na Tree
@author brunno.costa
@since 13/11/2018
@version P12
@return cPrompt, chacacters, texto Prompt do item na Tree
@param cProduto, characters, Produto relacionado ao item
@type Function
/*/
Static Function PromptTree(cCargo)
	Local aAreaSB1
	Local cRet      := ""
	Local nTamCod	:= GetSx3Cache("VF_COMP","X3_TAMANHO")
	Local nTamNum	:= GetSx3Cache("VF_NUM","X3_TAMANHO")
	Local cNum		:= RetFrCargo(cCargo, 3)
	Local cProduto	:= RetFrCargo(cCargo, 1)

	If cProduto != SB1->B1_COD
		aAreaSB1	:= SB1->(GetArea())
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	EndIf

	cRet := Pad(AllTrim(SB1->B1_COD) + Iif(Empty(cNUM),""," - " + cNUM), nTamCod + nTamNum + 3)
	If !Empty(aAreaSB1)
		Restarea(aAreaSB1)
	EndIf

Return cRet

/*/{Protheus.doc} a122Endere
Mostra tela de endereços anteriores
@author brunno.costa
@since 13/11/2018
@version P12
@type Function
/*/
Function a122Endere()
	Local oModel 	:= FwModelActive()
	Local oViewPai 	:= FwViewActive()
	Local oView 	:= Nil
	Local oViewExec := FWViewExec():New()
	Local oStruSVF  := FWFormStruct(2, "SVF", {|cCampo| ("|"+Alltrim(cCampo)+"|" $ "|VF_NUM|VF_COMP|")})
	Local oStruT4I  := FWFormStruct(2, "T4I", {|cCampo| !("|"+Alltrim(cCampo)+"|" $ "|T4I_NUM|T4I_FILIAL|")}, .F.)
	Local lRet 		:= .T.
	Local lCancelar := .F.

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("VIEW_MODAL_SVF", oStruSVF ,"SVFMASTER")
	oView:AddGrid( "VIEW_MODAL_T4I", oStruT4I, "T4IDETAIL")

	oView:CreateHorizontalBox("BOX_GRID_CAB",60,,.T.)
	oView:CreateHorizontalBox("BOX_GRID_T4I",100)

	oView:SetOwnerView("VIEW_MODAL_SVF", 'BOX_GRID_CAB')
	oView:SetOwnerView("VIEW_MODAL_T4I", 'BOX_GRID_T4I')

	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
		oViewExec:setModel(oModel)
		oViewExec:setView(oView)
		oViewExec:setTitle(STR0009) // "Endereços Anteriores"
		oViewExec:setOperation(oViewPai:GetOperation())
		oViewExec:setSize(200, 300)
		oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,""},{.T.,STR0010},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) // STR0010 - Fechar
		oViewExec:SetCloseOnOk({|oViewPai| .T. })
		oViewExec:SetModal(.T.)
		oViewExec:openView(.F.)
	EndIf

	FwViewActive(oViewPai)

Return

/*/{Protheus.doc} GetCorLeg
Verifica se o registro posicionado da SVJ existe na SD4
@author brunno.costa
@since 13/11/2018
@version P12
@type Function
/*/
Static Function GetCorLeg()
	Local aArea		:= GetArea()
	Local aAreaSVF	:= SVF->(GetArea())
	Local aAreaSD4	:= SD4->(GetArea())
	Local cCorLeg	:= "BR_AZUL"

	DbSelectArea("SVF")
	DbSelectArea("SD4")
	SD4->(dbSetOrder(1))
	SVF->(dbSetOrder(1))
	SVF->(DbSeek(xFilial("SVF")+SVJ->VJ_NUM))
	SD4->(DbSeek(xFilial("SD4")+SVJ->VJ_ALTERN+SVF->VF_OP+SVJ->VJ_TRT+SVJ->VJ_LOTE+SVJ->VJ_SUBLOTE))
	While !SD4->(Eof());
		.AND. xFilial("SD4")	== SD4->D4_FILIAL;
		.AND. AllTrim(SVJ->VJ_ALTERN) 	== AllTrim(SD4->D4_COD);
		.AND. AllTrim(SVF->VF_OP)		== AllTrim(SD4->D4_OP);
		.AND. AllTrim(SVJ->VJ_TRT)		== AllTrim(SD4->D4_TRT);
		.AND. AllTrim(SVJ->VJ_LOTE)		== AllTrim(SD4->D4_LOTECTL);
		.AND. Alltrim(SVJ->VJ_SUBLOTE)	== AllTrim(SD4->D4_NUMLOTE)

		If 	AllTrim(SD4->D4_LOCAL)			== AllTrim(SVJ->VJ_LOCAL);
			.AND. AllTrim(SD4->D4_ORDEM)	== AllTrim(SVJ->VJ_ORDEM);
			.AND. AllTrim(SD4->D4_OPORIG)	== AllTrim(SVJ->VJ_OPORIG);
			.AND. AllTrim(SD4->D4_SEQ) 		== AllTrim(SVJ->VJ_SEQ)

			If QtdComp(SD4->D4_QTDEORI) == QtdComp(SD4->D4_QUANT) .And. QtdComp(SD4->D4_QUANT) # QtdComp(0)
				cCorLeg	:= "BR_VERDE"

			ElseIf QtdComp(SD4->D4_QTDEORI) # QtdComp(SD4->D4_QUANT) .And. QtdComp(SD4->D4_QUANT) # QtdComp(0)
				cCorLeg	:= "BR_AMARELO"

			ElseIf QtdComp(SD4->D4_QTDEORI) # QtdComp(SD4->D4_QUANT) .And. QtdComp(SD4->D4_QUANT) == QtdComp(0)
				cCorLeg	:= "BR_VERMELHO"
			EndIf

		EndIf
		SD4->(DbSkip())
	EndDo
	RestArea(aAreaSD4)
	RestArea(aAreaSVF)
	RestArea(aArea)
Return cCorLeg

/*/{Protheus.doc} a122Legend
Mostra legendas da tela
@author brunno.costa
@since 13/11/2018
@version P12
@type Function
/*/
Static Function a122Legend()
	Local aCores	:= {}

	Default lAutoMacao := .F.

	Aadd( aCores , { "BR_VERDE"		, STR0014 } )	//"Empenho em aberto"
	Aadd( aCores , { "BR_AMARELO"	, STR0015 } )	//"Empenho parcialmente baixado"
	Aadd( aCores , { "BR_VERMELHO"	, STR0016 } )	//"Empenho totalmente baixado"
	Aadd( aCores , { "BR_AZUL"		, STR0017 } )	//"Empenho excluído"

	IF !lAutoMacao
		BrwLegenda(STR0001, STR0013, aCores)			//Ordem de Substituição - Legenda
	ENDIF
Return
