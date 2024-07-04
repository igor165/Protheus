#INCLUDE "AGRC020.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "Protheus.ch"

/** {Protheus.doc} AGRC020
Consulta para impressão de termos de multiplos lotes

@param.: 	Nil
@author: 	Ana Laura Olegini
@since.: 	16/11/2015
@Uso...: 	UBS - Unidade de Beneficiamento de Sementes
*/
Function AGRC020()
	Local oMark 	:= Nil
	Local bKeyF12  	:= {|| If( Pergunte(STR0019, .T.), (oMark:SetFilterDefault(AGRC020FIL()), oMark:Refresh()), .T. ) } //"AGRC020"

	// Cria Pergunte
	cPerg := AGRGRUPSX1(STR0019) //"AGRC020"

	// Seta tecla F12
	SetKey( VK_F12, bKeyF12 )

	If Pergunte(cPerg, .T.)
		oMark := FWMarkBrowse():New()
		oMark:SetAlias('NP9')
		oMark:SetFieldMark("NP9_OK")
		oMark:SetDescription( STR0020 )	//"Consulta de Lotes"
		oMark:SetFilterDefault(AGRC020FIL())

		//Legendas
		AGRLEGEBROW(@oMark,{{"NP9_STATUS = '1'",STR0021	,"RED"},; 		//"Aguardando Resultado Laboratorial"
		{"NP9_STATUS = '2'",STR0022	,"GREEN"},;		//"Disponível"
		{"NP9_STATUS = '3'",STR0023	,"BLACK"}})		//"Finalizado"
		//Ativa o Browse
		oMark:Activate()
	Else
		Return
	EndIf
Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param.: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Ana Laura Olegini
@since.: 	16/11/2015
@Uso...: 	UBS - Unidade de Beneficiamento de Sementes
*/
Static Function MenuDef()
	Local aRotina := {}
	Local iniOP := 7
	lOCAL nx
	aAdd( aRotina, { STR0026 , "PesqBrw"	, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0027 , "AC020PROC"	, 0, 4, 0, Nil } ) //"Imprime Termo"

	//ponto de Entrada para Adição de opções no menu
	If ExistBlock('AGC020MEN')
		aRetM := ExecBlock('AGC020MEN',.F.,.F.)
		If Type("aRetM") == 'A'
			For nx := 1 To Len(aRetM)
				iniOP ++
				aAdd( aRotina, { aRetM[nx,1] , aRetM[nx,2]	, 0, iniOP, 0, Nil } )
			Next nx
		EndIf
	EndIf

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Ana Laura Olegini
@since.: 	16/11/2015
@Uso...: 	UBS - Unidade de Beneficiamento de Sementes
*/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruNP9 	:= FwFormStruct( 1, "NP9" )//Cadastro de Culturas

	// Instancia o modelo de dados
	oModel := MpFormModel():New( 'AGRA840')
	//NPTMASTER é o identificador (ID) dado ao componente.
	oModel:AddFields("NP9MASTER",Nil,oStruNP9)
	//Adicionamos a descrição dos componentes do modelo de dados: NPTMASTER
	oModel:GetModel('NP9MASTER'):SetDescription(STR0020)
Return( oModel )

Function AC020PROC()

	if (__FWLibVersion() >='20160304.2' .and. GetBuild() >= '7.00.131227A-20160331' .and. GetBuild(.T.) >= '7.00.131227A-20160331')
		Processa({||AC020IMP()})
	else
		Alert("Build/Lib desatualizada, poderao ocorrer erros dependendo da versao do seu Microsoft Word")
		Processa({||AC020IMP()})
	endif
Return

/** {Protheus.doc} ViewDef
@param: 	Nil
@return:	oView
@author: 	Ana Laura Olegini
@since.: 	16/11/2015
@Uso...: 	UBS - Unidade de Beneficiamento de Sementes
*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA840" )
	Local oStruNPE  := FwFormStruct( 2, "NP9" ) // Amostra do Lote de Sementes

	// Instancia a View
	oView := FwFormView():New()
	// Seta o modelo de dados
	oView:SetModel( oModel )
	// Adiciona os atributos da estrutura da view
	oView:AddField( 'VIEW_NP9', oStruNPE, 'NP9MASTER' )
	// Monta o box horizontal
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	// Seta Owner da Interface
	oView:SetOwnerView( 'VIEW_NP9', 'TOTAL' )
Return oView

/** {Protheus.doc} AGRC020FIL
@param: 	Nil
@return:	cFiltro
@author: 	Ana Laura Olegini
@since.: 	16/11/2015
@Uso...: 	UBS - Unidade de Beneficiamento de Sementes
*/
Function AGRC020FIL()
	Local cFiltro   := ""

	cFiltro := "NP9_FILIAL = '" + xFilial("NP9") + "'"
	//Tratado
	If mv_par01 != 3
		cFiltro += " .AND. NP9_TRATO = '"+ Alltrim(STR(mv_par01)) + "'"
	EndIf
	// Safra
	cFiltro += " .AND. NP9_CODSAF = '" + mv_par02 + "'"
	//Produto
	cFiltro += " .AND. NP9_PROD  >= '"+ mv_par03 + "' .AND. NP9_PROD <= '"+ mv_par04 + "'"
	//Local
	cFiltro += " .AND. NP9_LOCAL >= '"+ mv_par05 + "' .AND. NP9_LOCAL <= '"+ mv_par06 + "'"
	//Cultura
	cFiltro += " .AND. NP9_CULTRA >= '"+ mv_par07 + "' .AND. NP9_CULTRA <= '"+ mv_par08 + "'"
	//Cultivares/Variedade
	cFiltro += " .AND. NP9_CTVAR >= '"+ mv_par09 + "' .AND. NP9_CTVAR <= '"+ mv_par10 + "'"
	//Categoria
	cFiltro += " .AND. NP9_CATEG >= '"+ mv_par11 + "' .AND. NP9_CATEG <= '"+ mv_par12 + "'"
	//Peneira
	cFiltro += " .AND. NP9_PENE >= '"+ mv_par13 + "' .AND. NP9_PENE <= '"+ mv_par14 + "'"
	//Data Produção
	cFiltro += " .AND. DTOS(NP9_DATA) >= '"+ DTOS(mv_par15) + "' .AND. DTOS(NP9_DATA) <= '"+ DTOS(mv_par16) + "'"
	//Lote
	cFiltro += " .AND. NP9_LOTE >= '"+ mv_par17 + "' .AND. NP9_LOTE <= '"+ mv_par18 + "'"

Return cFiltro

/** {Protheus.doc} AC020IMP
@param: 	Nil
@return:	Nil
@author: 	Ana Laura Olegini
@since.: 	16/11/2015
@Uso...: 	UBS - Unidade de Beneficiamento de Sementes
*/
Function AC020IMP()
	Local aArea  := GetArea()
	Local cMarca := oMark:Mark()
	Local nMark	 := 0
	Local nCt    := 0

	NP9->( dbGoTop() )
	While !NP9->( EOF() )
		nMark += If(oMark:IsMark(cMarca),1,0)
		NP9->( dbSkip() )
	EndDo

	NP9->( dbGoTop() )
	ProcRegua(nMark)
	While !NP9->( EOF() )
		If oMark:IsMark(cMarca)
			nCt++
			IncProc(STR0028+" "+Alltrim(Str(nCt,7))+" / "+Alltrim(Str(nMark,7))) //"Imprimindo"

			If Empty(NP9->NP9_NUMTC)
				//Grava numero de termo conforme numeração SXE/SXF
				RecLock("NP9",.F.)
				NP9->NP9_NUMTC := GetSxeNum("NP9","NP9_NUMTC")
				MsUnlock()
				ConfirmSX8()
				// Impressão de termos de multiplos lotes
				AGRR920(NP9->NP9_CODSAF,NP9->NP9_LOTE)
			Else
				// Impressão de termos de multiplos lotes
				AGRR920(NP9->NP9_CODSAF,NP9->NP9_LOTE)
			EndIf
		EndIf
		NP9->( dbSkip() )
	End

	//ApMsgInfo( 'Foram impressos ' + AllTrim( Str( nCt ) ) + ' termos de conformidade.' )
	RestArea( aArea )
Return