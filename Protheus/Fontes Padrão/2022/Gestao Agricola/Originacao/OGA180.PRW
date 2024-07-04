#INCLUDE "OGA180.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

STATIC __lAutomato      := IiF(IsBlind(),.T.,.F.) //automação


/** {Protheus.doc} OGA180
Rotina para cadastro de amostras avulsas com a classificação

@param:     Nil
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       SIGAARM - Originação de Grãos
*/
Function OGA180(cContrNJR)
	Local oMBrowse := Nil
	Private aMtzDes     := { { "", "" }, { "", "" }, { "", "" } }

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJF" )
	If cContrNJR <> Nil
		oMBrowse:SetFilterDefault("NJF_CODCTR = '"+cContrNJR+"'")
	EndIf
	oMBrowse:SetDescription( STR0001 ) //"Amostras Avulsas"
	oMBrowse:AddLegend( "NJF_STATUS=='0'", "WHITE"      , STR0002) //"Amostra"
	oMBrowse:AddLegend( "NJF_STATUS=='1'", "YELLOW"     , STR0003) //"Classificada"
	oMBrowse:AddLegend( "NJF_STATUS=='2'", "BLUE"       , STR0004) //"Vinculada"
	oMBrowse:AddLegend( "NJF_STATUS=='3'", "GREEN"      , STR0016) //"Liberado"
	oMBrowse:AddLegend( "NJF_STATUS=='4'", "RED"        , STR0017) //"Reprovado"
	oMBrowse:AddLegend( "NJF_STATUS=='5'", "BR_CANCEL"  , STR0018) //"Cancelado"
	oMBrowse:SetMenuDef('OGA180')
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param:     Nil
@return:    aRotina - Array com os itens do menu
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA180 - Amostras
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0005    , "PesqBrw"          , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0006    , "ViewDef.OGA180"   , 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0007    , "ViewDef.OGA180"   , 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0008    , "ViewDef.OGA180"   , 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0009    , "ViewDef.OGA180"   , 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0010    , "ViewDef.OGA180"   , 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0011    , "ViewDef.OGA180"   , 0, 9, 0, Nil } ) //"Copiar"
	aAdd( aRotina, { STR0019    , "OGA180L"          , 0, 4, 0, Nil } ) //"Liberar"
	aAdd( aRotina, { STR0020    , "OGA180R"          , 0, 4, 0, Nil } ) //"REPROVAR"
	aAdd( aRotina, { STR0021    , "OGA180CAN"        , 0, 4, 0, Nil } ) //"CANCELAR"
	aAdd( aRotina, { STR0022    , "AGRCONHECIM('NJR')", 0, 4, , .T. } ) //"Conhecimento"
	aAdd( aRotina, { STR0044    , "OGA180HIS"        , 0, 7, 0, Nil } ) //"Histórico"
Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param:     Nil
@return:    oModel - Modelo de dados
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA180 - Amostras
*/
Static Function ModelDef()	
	Local oStruNJF := FWFormStruct( 1, "NJF" )
	Local oStruNJG := FWFormStruct( 1, "NJG" )
	Local oModel   := MPFormModel():New( "OGA180", ,{| oModel | TudoOK( oModel )} , {| oModel | GrvModelo( oModel ) } )
	Local lObrTb   := SuperGetMV( "MV_AGRO039",.F.,.T.)	

	Local aMaNWhen := {{"NJF_CODCTR"},{"NJF_CODENT"},{"NJF_LOJENT"},{"NJF_NOMENT"},{"NJF_NLJENT"},;
	{"NJF_CODSAF"},{"NJF_CODPRO"},{"NJF_DESPRO"}}

	oStruNJF:SetProperty( "NJF_TIPAUT" , MODEL_FIELD_VALID  , FwBuildFeature( STRUCT_FEATURE_VALID,"OG180VLDCT()") )
	oStruNJF:SetProperty( "NJF_CODCTR" , MODEL_FIELD_VALID  , FwBuildFeature( STRUCT_FEATURE_VALID,"OG180VLDCT()") )
	oStruNJF:SetProperty( "NJF_TABELA" , MODEL_FIELD_VALID  , FwBuildFeature( STRUCT_FEATURE_VALID,"OG180VTAB(.t.)") )  
	oStruNJF:SetProperty( "NJF_TIPAMO" , MODEL_FIELD_VALID  , FwBuildFeature( STRUCT_FEATURE_VALID,"OG180VTAMO()") )
	oStruNJF:SetProperty( "NJF_QTDAMO" , MODEL_FIELD_VALID  , {| oFields | OGA180ATUG( oFields )  } )
	//Alterado a obrigatoriedade para respeitar o parâmetro conforme tarefa DAGROBEN-772
	oStruNJF:SetProperty( "NJF_TABELA" , MODEL_FIELD_OBRIGAT, lObrTb )
	oStruNJF:SetProperty( "NJF_CODSAF" , MODEL_FIELD_OBRIGAT, .T. )
	oStruNJF:SetProperty( "NJF_CODPRO" , MODEL_FIELD_OBRIGAT, .T. )
	//    oStruNJF:SetProperty( "NJF_TIPAUT" , MODEL_FIELD_OBRIGAT, .T. )
	oStruNJF:SetProperty( "NJF_TIPAUT" , MODEL_FIELD_WHEN   , {||IIF(NKI->NKI_TIPREL == '2',.T.,.F.)})
	oStruNJF:SetProperty( "NJF_QTDAUT" , MODEL_FIELD_WHEN   , {||IIF(NKI->NKI_TIPREL == '2',.T.,.F.)})
	oStruNJF:SetProperty( "NJF_CODCTR" , MODEL_FIELD_WHEN   , {||IIF(!NKI->NKI_TIPREL = '1',.T.,.F.)})
	


	oStruNJG:RemoveField( "NJG_CODAMO" )

	//--Adding Gatilhos na NJF --//
	oStruNJF:AddTrigger( "NJF_CODCTR" , "NJF_CODPRO"  , {||.T.}, {|| fOG180GCTR() }  ) // Preenche Cpos. que necessitam inf. do ctrato de Compra

	oModel:SetDescription( STR0012 ) //"Amostra Avulsa"

	oModel:AddFields( "NJFUNICO", Nil, oStruNJF )
	oModel:GetModel( "NJFUNICO" ):SetDescription( STR0013 ) //"Dados da Amostra"

	oModel:AddGrid( "NJGUNICO", "NJFUNICO", oStruNJG, , , , { | oGrid | PosGride( oGrid ) } )
	oModel:GetModel( "NJGUNICO" ):SetDescription( STR0014 ) //"Dados do Item da Amostra"
	oModel:GetModel( "NJGUNICO" ):SetUniqueLine( { "NJG_CODDES" } )
	//Alterado a obrigatoriedade para respeitar o parâmetro conforme tarefa DAGROBEN-772
	oModel:GetModel( "NJGUNICO" ):SetOptional( !lObrTb )
	oModel:GetModel( "NJGUNICO" ):SetNoDelete()
	oModel:GetModel( "NJGUNICO" ):SetNoInsert()

	oModel:SetRelation( "NJGUNICO", { { "NJG_FILIAL", "xFilial( 'NJG' )" }, { "NJG_CODAMO", "NJF_CODAMO" } }, NJG->( IndexKey( 1 ) ) )

	If FUNNAME() = 'OGA280'
		AGRWHENMVC(oStruNJF,aMaNWhen)

		AGRIFDBSEEK("SB5",NJR->NJR_CODPRO,1,.f.)

		oStruNJF:SetProperty("NJF_CODCTR",MODEL_FIELD_INIT,{||NJR->NJR_CODCTR})
		oStruNJF:SetProperty("NJF_CODENT",MODEL_FIELD_INIT,{||NJR->NJR_CODENT})
		oStruNJF:SetProperty("NJF_LOJENT",MODEL_FIELD_INIT,{||NJR->NJR_LOJENT})
		oStruNJF:SetProperty("NJF_NOMENT",MODEL_FIELD_INIT,{||Posicione("NJ0",1,xFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_NOME")})
		oStruNJF:SetProperty("NJF_NLJENT",MODEL_FIELD_INIT,{||Posicione("NJ0",1,xFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_NOMLOJ")})
		oStruNJF:SetProperty("NJF_CODSAF",MODEL_FIELD_INIT,{||NJR->NJR_CODSAF})
		oStruNJF:SetProperty("NJF_CODPRO",MODEL_FIELD_INIT,{||NJR->NJR_CODPRO})
		oStruNJF:SetProperty("NJF_DESPRO",MODEL_FIELD_INIT,{||Posicione('SB1',1,xFilial('SB1')+NJR->NJR_CODPRO,'B1_DESC')})
		//        oStruNJF:SetProperty("NJF_TABELA",MODEL_FIELD_INIT,{||NJR->NJR_TABELA})
		oStruNJF:SetProperty("NJF_DESCTR",MODEL_FIELD_INIT,{||NJR->NJR_DESCRI})
		oStruNJF:SetProperty("NJF_UM1PRO",MODEL_FIELD_INIT,{||NJR->NJR_UM1PRO})
		oStruNJF:SetProperty("NJF_SEMENT",MODEL_FIELD_INIT,{||if(SB5->(Eof()),0, SB5->B5_SEMENTE)})
	EndIf
	oModel:SetVldActivate( { |oModel| fVldActivate( oModel ) } )
	oModel:SetActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param:     Nil
@return:    oView - View do modelo de dados
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA180 - Amostras
*/
Static Function ViewDef()
	Local oStruNJF := FWFormStruct( 2, "NJF" )
	Local oStruNJG := FWFormStruct( 2, "NJG" )
	Local oModel   := FWLoadModel( "OGA180" )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )

	oStruNJG:RemoveField( "NJG_CODAMO" )

	oView:AddField( "VIEW_NJF", oStruNJF, "NJFUNICO" )
	oView:AddGrid( "VIEW_NJG", oStruNJG, "NJGUNICO" )

	oView:AddIncrementField( "VIEW_NJG", "NJG_ITEM" )

	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 70, "TELANOVA" )
	oView:CreateHorizontalBox( "INFERIOR" , 30, "TELANOVA" )

	oView:SetOwnerView( "VIEW_NJF", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NJG", "INFERIOR" )

	oView:EnableTitleView( "VIEW_NJF" )
	oView:EnableTitleView( "VIEW_NJG" )

	///=== Define métodos do View ===/// 
	//oView:SetAfterViewActivate( { | oModel | fAftViewActiv( oModel ) } )
	//oView:SetAfterOkButton( {| oModel | fAftOKButton( oModel ) } )
	oView:SetCloseOnOk( {||.t.} )

Return( oView )


/** {Protheus.doc} OG180VTAB
Função que valida a tabela selecionada e quando permitida atualiza o gride com os itens de classificação

@param:     lIni - Logico que: .t.  indica se deve Validar e inicializar, .f. irá somente Validar 
@return:    lRetorno - verdadeiro ou falso
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA180 - Amostras
*/
Function OG180VTAB( lIni )
	Local aAreaAtu  := GetArea()
	Local oModel        := FwModelActive()
	Local lRetorno      := .T.
	Local cTabela       := oModel:GetModel('NJFUNICO'):GetValue( "NJF_TABELA" )
	Local cCodPro       := oModel:GetModel('NJFUNICO'):GetValue( "NJF_CODPRO" )
	Local cGrupo        := ""

	IF ! Empty(cTabela)
		dbSelectArea( "NNI" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "NNI" ) + cTabela )
			//para o campo de cod. do produto preenchido
			If !Empty(NNI->( NNI_CODPRO ))      
				If NNI->( NNI_CODPRO ) <> cCodPro
					Help( , , STR0015, , STR0034, 1, 0 ) //"AJUDA"###"Tabela nao cadastrada para este produto."
					lRetorno := .f.
				Else
					If ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
						Help( , , STR0015, , STR0035, 1, 0 ) //"AJUDA"###"Tabela fora da validade."
						lRetorno := .f.
					EndIf
				EndIf
				//para o campo de cod. do produto vazio
			ElseIf Empty(NNI->( NNI_CODPRO ))
				//verifica na tabela de produto pelo grupo se o grupo é existente
				//se grupo não existir apresenta mensagem para informar o grupo         
				If AGRIFDBSEEK("SB1",cCodPro,1,.F.)
					cGrupo := SB1->( B1_GRUPO )
					If NNI->( NNI_PRODGR ) <> cGrupo
						AGRHELPNC(STR0036,STR0037,STR0015) //"Produto não faz parte do grupo informado."##"Favor informar um produto do grupo."##"AJUDA"
						lRetorno := .F.
					ElseIf ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
						Help( , , STR0015, , STR0035, 1, 0 ) //"AJUDA"###"Tabela fora da validade."
						lRetorno := .f.
					EndIf
				EndIf
			EndIf       
			IF lRetorno .and. lIni .and. !__lAutomato // devo Inicializar
				OG180GTAB( )
			EndIF
		Else
			Help( , , STR0015, , STR0038, 1, 0 ) //"AJUDA"###"Tabela nao cadastrada."
			lRetorno := .f.
		EndIf
	EndIF

	RestArea (AAreaAtu )

Return( lRetorno )


/** {Protheus.doc} fVldActivate
Função que valida o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Pagung
@since:     01/12/2015
@Uso:       OGA180 - Amostra
*/

Static Function fVldActivate( oModel )
	Local nOpc := oModel:GetOperation()

	/* --- Alteração --- */
	If nOpc == MODEL_OPERATION_UPDATE
		If NJF->( NJF_STATUS ) = "3"
			Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Amostra com status "
			Return( .F. )
		EndIf
		If NJF->( NJF_STATUS ) = "4"
			Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Amostra com status "
			Return( .F. )
		EndIf
		If NJF->( NJF_STATUS ) = "5"
			Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Amostra com status "
			Return( .F. )
		EndIf
	EndIf

	/* --- Exclusão  --- */
	If nOpc == MODEL_OPERATION_DELETE
		If NJF->( NJF_STATUS ) = "3"
			Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Amostra com status "
			Return( .F. )
		EndIf
		If NJF->( NJF_STATUS ) = "4"
			Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Amostra com status "
			Return( .F. )
		EndIf
		If NJF->( NJF_STATUS ) = "5"
			Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Amostra com status "
			Return( .F. )
		EndIf
	EndIf
Return( .T. )

/** {Protheus.doc} PosGride
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA180 - Amostras
*/
Static Function PosGride( oGride )
	Local oModel    := FwModelActive()
	Local nPerTot   := 0
	Local nLinha    := 0
	Local nX        := 0

	nLinha := oGride:GetLine()
	For nX := 1 to oGride:Length()
		oGride:GoLine( nX )
		nPerTot += oGride:GetValue( "NJG_PERDES" )
	Next nX
	oGride:GoLine( nLinha )

	If nPerTot > 0
		oModel:SetValue( "NJFUNICO", "NJF_STATUS", "1" )
	EndIf

Return( .t. )


/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA190 - Pesagens
*/
Static Function GrvModelo( oModel )
	Local oGrdNJF       := oModel:GetModel( "NJFUNICO" )
	Local oGrdNJG       := oModel:GetModel( "NJGUNICO" )
	Local nOperation    := oModel:GetOperation()

	// Gravar Histórico Automaticamente
	If nOperation == MODEL_OPERATION_INSERT
		AGRGRAVAHIS(,,,,{"NJF",xFilial("NJF")+oGrdNJF:Getvalue('NJF_CODAMO'),"3",STR0007})// Incluir
	elseIf nOperation == MODEL_OPERATION_UPDATE
		AGRGRAVAHIS(,,,,{"NJF",NJF->NJF_FILIAL+NJF->NJF_CODAMO,"4",STR0008}) //Alterar 
	elseIf nOperation == MODEL_OPERATION_DELETE
		AGRGRAVAHIS(,,,,{"NJF",NJF->NJF_FILIAL+NJF->NJF_CODAMO,"5",STR0009}) //Excluir
	Endif

	If nOperation = MODEL_OPERATION_INSERT .or. nOperation = MODEL_OPERATION_UPDATE
		IF oGrdNJG:GetValue( "NJG_PERDES") == 0
			oGrdNJF:SetValue("NJF_STATUS","0")
			NJF->( MsUnLock() )
		ELSE
			oGrdNJF:SetValue("NJF_STATUS","1")
			NJF->( MsUnLock() )
		EndIf
	EndIf
	FWFormCommit( oModel )
Return( .T. )

/*
+=================================================================================================+
| Função    : OGA180PER                                                                           |
| Descrição : Carrega a descrição do desconto                                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 07/11/2014                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA180PER()
	Local oModel        := FwModelActive()
	Local oGrdNJF       := oModel:GetModel( "NJFUNICO" )

	OGA180ATUG( oGrdNJF )

Return .T.

Function OGA180VTAB()
	Local lRetorno  := .t.
	Local aAreaAtu  := GetArea()
	Local oModel        := FwModelActive()
	Local oFldNJF       := oModel:GetModel( "NJFUNICO" )
	Local oGrdNJG       := oModel:GetModel( "NJGUNICO" )
	Local cTabela       := oFldNJF:GetValue( "NJF_TABELA" )
	Local cItem     := ""
	Local nLinha        := oGrdNJG:Length()
	Local nCount        := 0
	Local nX            := 0
	Local nAuxCount   := 0
	Local nCountRes   := 0

	If !OGX004VTAB(cTabela)
		Return( .f. )
	EndIf

	//Limpa array
	aResults := {}  

	dbSelectArea( 'NNI' )
	dbSetOrder( 1 )
	If dbSeek( xFilial( 'NNI' ) + cTabela )

		oGrdNJG:SetNoInsert( .f. )
		oGrdNJG:SetNoDelete( .f. )

		dbSelectArea( 'NNJ' )
		dbSetOrder( 2 )
		dbGoTop()
		If dbSeek( xFilial( 'NNJ' ) + NNI->( NNI_CODIGO ) )

			While .Not. Eof() .And. NNJ->( NNJ_FILIAL ) = xFilial('NNJ') .And. NNJ->( NNJ_CODTAB ) = NNI->( NNI_CODIGO )

				nCount++
				cItem := StrZero( nCount, TamSX3( "NJG_ITEM" )[1] )
				If nCount > nLinha
					oGrdNJG:AddLine()
				Else
					oGrdNJG:GoLine( nCount )
					If oGrdNJG:IsDeleted()
						oGrdNJG:UnDeleteLine()
					EndIf
				EndIf

				oGrdNJG:SetValue( "NJG_ITEM"  , cItem )
				oGrdNJG:SetValue( "NJG_CODDES", NNJ_CODDES )
				oGrdNJG:SetValue( "NJG_PERDES", 0 )
				oGrdNJG:SetValue( "NJG_QTDDES", 0 )

				/**
				Varre array de resultados anteriores, se encontrar exame igual
				copia o resultado.
				**/
				If LEN(aResults) > 0
					For nX := 1 to nCountRes

						If aResults[ nX, 5] = NJG_CODDES
							oGrdNJG:SetValue( "NJG_PERDES", aResults[ nX, 8] )
						Endif
					Next nX
				Endif

				/** Carrega matriz de melhoramento de descontos */
				If NNJ->( NNJ_MATRIZ ) = "1"; aMtzDes[ 1, 1 ] := NNJ->( NNJ_CODDES ); EndIf
				If NNJ->( NNJ_MATRIZ ) = "2"; aMtzDes[ 2, 1 ] := NNJ->( NNJ_CODDES ); EndIf
				If NNJ->( NNJ_MATRIZ ) = "3"; aMtzDes[ 3, 1 ] := NNJ->( NNJ_CODDES ); EndIf

				dbSkip()
			EndDo
			If nCount < nLinha
				nAuxCount = nCount + 1
				For nX := nAuxCount to nLinha
					oGrdNJG:GoLine( nX )
					oGrdNJG:DeleteLine()
				Next nX
			EndIf
		EndIf

		oGrdNJG:SetNoInsert( .t. )
		oGrdNJG:SetNoDelete( .t. )
		oGrdNJG:GoLine( 1 )
	Else
		Help(, ,STR0015, , STR0023, 1, 0 ) //"Ajuda"###"Não existe -Tabela de Descontos- cadastrada!!!"
		lRetorno := .f.
	EndIf

	RestArea( aAreaAtu )

Return( lRetorno )

/** {Protheus.doc} OGA180ATUG


@return:    cStatus - Status geral do romaneio
@param:     Nil
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA180ATUG - amostra
*/
Function OGA180ATUG( oNJF )
	Local oView     := NIL
	Local oModel    := FwModelActive()
	Local oNJG      := oModel:GetModel( "NJGUNICO" )
	Local nY        := 0
	Local nX        := 0
	Local nLinha    := 0
	Local cDesRes   := ""
	Local aDescont  := {}
	Local aProcess  := {}
	DEFAULT oNJF 	:= oModel:GetModel( "NJFUNICO" )
	
	If !__lAutomato
		oView     := FWViewActive()
	EndIf

	nLinha := oNJG:nLine

	oNJG:GoLine( nLinha )
	If empty(oNJG:GetValue( "NJG_CODDES" ))
		OGA180VTAB ( )
		oNJG:GoLine( nLinha )
		If empty(oNJG:GetValue( "NJG_CODDES" ))
			return( .t. )
		endIf
	EndIf

	nLinha := oNJG:nLine
	For nX := 1 to oNJG:Length()
		oNJG:GoLine( nX )
		If .Not. oNJG:IsDeleted()
			aAdd( aDescont, { oNJG:GetValue( "NJG_CODDES" ), oNJG:GetValue( "NJG_PERDES" ) } )
		EndIf
	Next nX
	oNJG:GoLine( nLinha )

	If !__lAutomato
		aProcess := OGX004DESC( oNJF:GetValue( "NJF_TABELA" ), oNJF:GetValue( "NJF_QTDAMO" ), aDescont)
	EndIf

	If Len( aProcess ) > 0
		nLinha := oNJG:nLine
		For nX := 1 to oNJG:Length()
			oNJG:GoLine( nX )
			If .Not. oNJG:IsDeleted()
				nY := aScan( aProcess, { | x | AllTrim( x[ 1 ] ) = AllTrim( oNJG:GetValue( "NJG_CODDES" ) ) } )
				oNJG:LoadValue( "NJG_PERDES", aProcess[ nY, 3 ] )
				oNJG:LoadValue( "NJG_READES", aProcess[ nY, 4 ] )
				cDesRes := AGRDESCRINNK(oNJF:GetValue("NJF_TABELA"),oNJG:GetValue("NJG_CODDES"),aProcess[ nY, 3 ])
				oNJG:LoadValue( "NJG_DESRES", cDesRes )
				oNJG:LoadValue( "NJG_QTDDES", aProcess[ nY, 5 ] )
			EndIf
		Next nX
		oNJG:GoLine( nLinha )
	EndIf

   IF !Type('oView') == 'U' 
      oView:Refresh()
   EndIF
Return( .t. )

/** {Protheus.doc} IniModelo
Função que valida a inicialização do modelo de dados

@param:     oModel - Modelo de dados
@param:     nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:    lRetorno - verdadeiro ou falso
@author:    Ricardo Tomasi
@since:     08/06/2010
@Uso:       OGA180 - Contratos
*/
Static Function IniModelo( oModel, nOperation )

	IF IsInCallStack( 'OGA280' ) .and. nOperation == MODEL_OPERATION_INSERT
		///OG180VTAB(.t.)  //Para forçar a inicialização do Grid senao ele não inicializa
		OG180GTAB( )
	EndIF
Return(.t.)

/** {Protheus.doc} OG180VLDCT
Função que valida o campo da tabela de descontos utilizada no contrato
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Pagung
@since:     11/12/2015
@Uso:       OGA180 - Contratos
*/

Function OG180VLDCT( )
	Local lRetorno      := .T.
	Local lTAMOLIBCT    := NKI->NKI_TIPREL =='2'
	Local oModel        := FWModelActive()
	Local oModeLNJF     := oModel:GetModel("NJFUNICO")

	If empty(oModelNJF:GetValue("NJF_CODCTR"))
		if NKI->NKI_TIPREL $'2|3'
			Help( , ,STR0015, , STR0039, 1, 0 )
			lRetorno := .F.
		endif
	elseif AGRIFDBSEEK("NJR",oModelNJF:GetValue("NJF_CODCTR"),1,.f.)
		IF lTAMOLIBCT .and. NJR->NJR_CTRLLG == "2"//NÃO, TIPAMO, LIBERA CONTRATO, CONTRATO N TEM CONTROLE DE LOGISTICA.
			Help( , ,STR0015, , STR0040, 1, 0 )
			lRetorno := .F.
		Elseif lTAMOLIBCT
			IF NJR->NJR_CTRLLG = "1".And. NJR->NJR_CTRLCD = "0"
				Help( , ,STR0015, , STR0026, 1, 0 )//AJUDA#"Ctrl. Logistica -Sim-, Ctrl. Ent/Sai, Deve ser (1-Saida), (2-Entrada) ou (3-Ent/Sai), Verificar -OGA280-"
			ElseIF lRetorno .AND. NJR->NJR_CTRLLG = "1" .And. NJR->NJR_CTRLCD = "1" .and. FwFldGet('NJF_TIPAUT') = "E"//ENTRADA
				Help( , ,STR0015, , STR0027, 1, 0 ) //AJUDA#"Ctrl. Logistica -Sim-, Ctrl. Ent/Sai 1-Saida, Tip. Aut. Deve Ser (S-Saida)."
				lRetorno := .F.
			ElseIF lRetorno .AND. NJR->NJR_CTRLLG = "1" .And. NJR->NJR_CTRLCD = "2" .AND. FwFldGet('NJF_TIPAUT') = "S" //SAIDA
				Help( , ,STR0015, , STR0028, 1, 0 ) //AJUDA#"Ctrl. Logistica -Sim-, Ctrl. Ent/Sai 2-Entrada, Tip. Aut. Deve Ser (E-Entrada)."
				lRetorno := .F.
			EndIf
		EndIf
	Else
		Help( , ,STR0015, , STR0041, 1, 0 )
		lRetorno := .F.
	Endif

Return( lRetorno )


/** {Protheus.doc} OG180VTAMO
Função que valida o campo da tabela de descontos utilizada no contrato

@param:     oFields - Field da tabela NJ0
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Pagung
@since:     11/12/2015
@Uso:       OGA180 - Amostras
*/
Function OG180VTAMO( )
	Local lRetorno      := .T.
	Local oModel        := FWModelActive()
	Local oModeLNJF     := oModel:GetModel("NJFUNICO")

	IF IsInCallStack("OGA280") .or. IsInCallStack("OGA290")

		if NKI->NKI_TIPREL ='1'
			Help( , ,STR0015, , STR0033, 1, 0 )
			lRetorno := .F.
		endif
	EndIf

	IF !AGRIFDBSEEK("NKI",oModeLNJF:GetValue("NJF_TIPAMO"),1,.f.)
		Help( , , STR0015, , STR0045, 1, 0 ) //"AJUDA"###"Tipo de amostra nao cadastrada."
		lRetorno := .f.
	EndIf


Return( lRetorno )



/** {Protheus.doc} OGA180L
Rotina para utilizada para Liberar

@param:     Nil
@author:    Vinicius Pagung
@since:     27/11/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA180L(nOperation)
	Local aAreaAtu  	:= GetArea()
	Local lContinua 	:= .T.
	Local cItemMax 		:= Replicate('9',Tamsx3('NNY_ITEM')[1] )	
	Local cItemAut		:=''

	If !NJF->( NJF_STATUS ) $ "1|2"
		Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Amostra com status "
		Return .F.
	EndIf

	If (ExistBlock("OG180LIB"))
		If ExecBlock("OG180LIB",.F.,.F.) = .f. 
			Return .F.
		EndIF
	EndIf
	BEGIN TRANSACTION
	//"Deseja realmente Liberar a Amostra?"
	If AGRGRAVAHIS(STR0030,"NJF",NJF->NJF_FILIAL+NJF->NJF_CODAMO,STR0016) = 1//#"Deseja realmente Liberar a Amostra?"####Liberado
		lContinua := .T.
	else
		DisarmTransaction()
			lContinua := .F.
	EndIf
	If lContinua
		dbSelectArea( 'NKI' )
		dbSetOrder( 1 )
		If dbSeek( xFilial( 'NKI' ) + NJF->NJF_TIPAMO)
			If NKI->( NKI_TIPREL ) == "2"
				If (NJF->(NJF_QTDAUT)) <= 0
					Help( , ,STR0015, , STR0029, 1, 0 ) //"AJUDA"###"Quantidade da Amostra -Zerado- ou -Nao Informado-"
						lContinua := .F.
				EndIf
				/*Criando autorizacao para o contrato */

				cItemAut 	:=''
				cItemAut	:= fChkAutor( NJF->NJF_CODCTR, NJF->NJF_TIPAUT ) // Verifica se Alguma outra amostra avulsa já gerou autorização, Se Sim deo utilizar essa Autorização
				lIncNJP 	:= Empty( cItemAut ) 
				IF lIncNJP 
					cItemAut := NextNumero("NJP",1,"NJP_ITEM ",.T.,)//Buscando sequencia.- http://tdn.totvs.com/x/0Pxn
				EndIF

				dbSelectArea( 'NNY' )
				dbSetOrder( 1 )
				dbSeek( xFilial( 'NNY' ) + NJF->NJF_CODCTR + cItemMax,.T.)
				NNY->( DbSkip(-1) )//Posicionando na ultima cadência e gravando data fim.

				oMdlNJP := FWLoadModel( "OGA340" )
				IF lIncNJP   // Tenho q Incluir
					oMdlNJP:SetOperation( MODEL_OPERATION_INSERT )
				Else
					dbSelectArea( "NJP" )
					NJP->( dbSetOrder( 1 ) ) //NJP_FILIAL+NJP_CODCTR+NJP_ITEM
					NJP->( dbSeek( fwxFilial( "NJP" ) + NJF->NJF_CODCTR + cItemAut ))
					oMdlNJP:SetOperation( MODEL_OPERATION_UPDATE )
				EndIF
				IF ! oMdlNJP:Activate() // Verificando se o VldActivate Falhou
					cMsg := oMdlNJP:GetErrorMessage()[3] + oMdlNJP:GetErrorMessage()[6]
					Help( ,,STR0015,,cMsg, 1, 0 ) //"Ajuda"
						lContinua := .F.
				EndIF
				RestArea(aAreaAtu) 	// Restauro a area Atual para Garantir que o OGA340, n. desposicionou a Area
				// Pois se o OGA340 fizer ref. no VldActivate ou no SetActivate, a Area que
				// stou utilizando Poderá disposiciona-la

				oNJP:= oMdlNJP:GetModel( "NJPUNICO" )
				IF lIncNJP
					lRet:= oNJP:SetValue( "NJP_CODCTR"  ,   NJF->NJF_CODCTR)
					lRet:= oNJP:SetValue( "NJP_ITEM"    ,   cItemAut)
					lret:= oNJP:SetValue( "NJP_TIPO"    ,   NJF->NJF_TIPAUT)
					lret:= oNJP:SetValue( "NJP_DATINI"  ,   dDatabase      )
					lret:= oNJP:SetValue( "NJP_DATFIM"  ,   NNY->NNY_DATFIM)
					lret:= oNJP:SetValue( "NJP_QTDINI"  ,   NJF->NJF_QTDAUT)
					lret:= oNJP:SetValue( "NJP_QTDAUT"  ,    NJF->NJF_QTDAUT )
					// lret:= oNJP:SetValue( "NJP_TALHAO"  ,   NJF->NJF_TALHAO) // não informar talhao mais apartir de hj 07/01/2016 
					// varias amostras gerar 1 autorizacao) NJF[1..*]----->[1..1] NJP
					lret:= oNJP:SetValue( "NJP_STATUS"  ,   "A")// A=Aberta; I=Iniciada; E=Encerrada
				Else // JÁ Existe devo Alterar
					lret:= oNJP:SetValue( "NJP_QTDAUT"  ,   oNJP:getValue( "NJP_QTDAUT") + NJF->NJF_QTDAUT )
				EndIF


				If ( lRet:=oMdlNJP:VldData() )
					oMdlNJP:CommitData()
					lContinua := .t.
				Else
					cMsg := oMdlNJP:GetErrorMessage()[3] + oMdlNJP:GetErrorMessage()[6]
					Help( ,,STR0015,,cMsg, 1, 0 ) //"Ajuda"
					lContinua := .F.
				EndIf
				oMdlNJP:DeActivate()
			EndIF
		Endif
		if lContinua = .T.
			If RecLock( "NJF", .f. )
				NJF->( NJF_ITMAUT ) := cItemAut
                NJF->( NJF_STATUS ) := "3" //"Liberada"
				NJF->( MsUnLock() )
			EndIf
		EndIf
	EndIF
	END TRANSACTION
	If !lContinua
		Return ( .F. ) 
	Endif
	RestArea( aAreaAtu )
Return( NIL )


/** {Protheus.doc} OGA180R
Rotina para utilizada para Reprovar

@param:     Nil
@author:    Vinicius Pagung
@since:     27/11/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA180R( cAlias, nReg, nAcao )
	Local aAreaAtu  := GetArea()

	If !NJF->( NJF_STATUS ) $ "1|2|3" //1-classificada 2-Pend. Lib 3-Liberada
		Help( ,,STR0015,, STR0024+NJF->( NJF_STATUS )+" - "+X3CboxDesc( "NJF_STATUS", NJF->( NJF_STATUS ) ), 1, 0,) //"AJUDA"###"Operação nao permite movimentação
		Return .F.
	EndIf

	//"Deseja realmente Liberar a Amostra?"
	If AGRGRAVAHIS(STR0031,"NJF",NJF->NJF_FILIAL+NJF->NJF_CODAMO,STR0017) = 1//"Deseja realmente Rejeitar a Amostra?"

		If (ExistBlock("OG180REJ"))
			If ExecBlock("OG180REJ",.F.,.F.) = .f.
				Return .F.
			EndIF
		EndIf

		BEGIN TRANSACTION

		If RecLock( "NJF", .f. )
			NJF->( NJF_STATUS ) := "4" //"Reprovada"
			NJF->( MsUnLock() )
		EndIf

		// verificar se amostra avulsa tem uma uma autorização relacionada
		// caso tiver encerrar autorização
		If !Empty(NJF->( NJF_ITMAUT ))
			dbSelectArea( 'NJP' )
			NJP->(dbSetOrder( 1 ))
			If NJP->( dbSeek( xFilial( 'NJP' ) + NJF->(NJF_CODCTR + NJF_ITMAUT)) )
				IF !NJP_STATUS == 'E' 
					If RecLock( "NJP", .f. )
						Do Case
							Case  ( NJP->NJP_QTDAUT - NJP->NJP_QTDFCO - NJF->NJF_QTDAUT ) <= 0 //Qtd. Autoriz- Qtd. q ja movimentou - a qt.autoriz. da amostra <= 0 encerra
								NJP->NJP_QTDAUT := NJP_QTDFCO
								NJP->NJP_STATUS := "E"
							oTherWise 
								NJP->NJP_QTDAUT  -= NJF->NJF_QTDAUT
						EndCase
						NJP->( MsUnlock() )
					EndIf
					dbSelectArea( "NJR" )
					NJR->( dbSetOrder( 1 ) )
					If NJR->( dbSeek( xFilial("NJR") + NJP->NJP_CODCTR ) )
						OGX010QAut()    // Atualizando as Autorizações
					EndIf
				EndIf
			EndIf
		EndIf
		END TRANSACTION
	EndIf
	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} OGA180CAN
Rotina para utilizada para Cancelar
@param:     Nil
@author:    Vinicius Pagung
@since:     27/11/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA180CAN( cAlias, nReg, nAcao )
	Local aAreaAtu  := GetArea()

	If AGRGRAVAHIS(STR0032,"NJF",NJF->NJF_FILIAL+NJF->NJF_CODAMO,STR0018) = 1//"Deseja realmente Cancelar a Amostra?"

		If (ExistBlock("OG180CAN"))
			If ExecBlock("OG180CAN",.F.,.F.) = .f. 
				Return .F.
			EndIF
		EndIf

		BEGIN TRANSACTION

		If RecLock( "NJF", .f. )
			NJF->( NJF_STATUS ) := "5" //"Reprovada"

			NJF->( MsUnLock() )
		EndIf

		// verificar se amostra avulsa tem uma uma autorização relacionada
		// caso tiver encerrar autorização
        If !Empty(NJF->( NJF_ITMAUT ))
            dbSelectArea( 'NJP' )
            NJP->(dbSetOrder( 1 ))
            If NJP->( dbSeek( xFilial( 'NJP' ) + NJF->(NJF_CODCTR + NJF_ITMAUT)) )
                IF !NJP_STATUS == 'E' 
                    If RecLock( "NJP", .f. )
                        Do Case
                            Case  ( NJP->NJP_QTDAUT - NJP->NJP_QTDFCO - NJF->NJF_QTDAUT ) <= 0 //Qtd. Autoriz- Qtd. q ja movimentou - a qt.autoriz. da amostra <= 0 encerra
                                NJP->NJP_QTDAUT := NJP_QTDFCO
                                NJP->NJP_STATUS := "E"
                            oTherWise 
                                NJP->NJP_QTDAUT  -= NJF->NJF_QTDAUT
                        EndCase
                        NJP->( MsUnlock() )
                    EndIf
                    dbSelectArea( "NJR" )
                    NJR->( dbSetOrder( 1 ) )
                    If NJR->( dbSeek( xFilial("NJR") + NJP->NJP_CODCTR ) )
                        OGX010QAut()// Atualizando as Autorizações
                    EndIf
                EndIf
           EndIf
       EndIf
		END TRANSACTION
	EndIf
	RestArea( aAreaAtu )
Return( Nil )

/**{Protheus.doc}

@return Gatilha campos conforme Contrato.
@author Vinicius Pagung
@since 10/12/2015
@version 1.0
/*/

function fOG180GCTR( )
	Local aAreaAtu  := GetArea()
	Local aAreaNJR  := NJR->( GetArea() )	
	Local oModel    := FWModelActive()
	Local oModeLNJF := oModel:GetModel("NJFUNICO")
	Local cProduto  :=''
	Local cCodSaf   :=''
	//  Local cTabela   :=''
	//    Local cUniMed :=''
	Local cCodCtr   := oModelNJF:GetValue("NJF_CODCTR")


	//--Lendo o Ctrato de Compra //
	dbSelectArea( "NJR" )
	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

	cProduto := NJR->NJR_CODPRO
	cCodSaf  := NJR->NJR_CODSAF
	//  cTabela  := NJR->NJR_TABELA
	//    cUniMed  := NJR->NJR_UM1PRO

	oModelNJF:SetValue("NJF_CODPRO", cProduto )
	oModelNJF:SetValue("NJF_CODSAF", cCodSaf  )
	//omodelNJF:SetValue("NJF_TABELA", cTabela)
	//    oModelNJF:SetVAlue("NJF_UM1AMO", cUniMed  )

	RestArea( aAreaNJR )
	RestArea( aAreaAtu )

Return ( cProduto )

/** {Protheus.doc} TudoOk
@param:     Nil
@author:    Vinicius Pagung
@since:     18/12/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function TudoOk( oModel )
	Local lRetorno      := .T.	
	Local oModeLNJF     := oModel:GetModel("NJFUNICO")

	If empty(oModelNJF:GetValue("NJF_CODCTR"))
		If NKI->NKI_TIPREL $'2|3'
			Help( , ,STR0015, , STR0039, 1, 0 )//AJUDA## INFORME UM COTNRATO
			lRetorno := .F.
		EndIF
	EndIf
	If lRetorno .and. empty(oModelNJF:GetValue("NJF_TIPAUT")).AND. NKI->NKI_TIPREL == '2'
		Help( , ,STR0015, , STR0042, 1, 0 )//AJUDA##"Favor informar se a liberacao é entrada/saida"                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
		lRetorno := .F.
	ENDIF
	If lRetorno .and. oModelNJF:GetValue("NJF_QTDAUT") = 0 .AND. NKI->NKI_TIPREL == '2'
		Help( , ,STR0015, , STR0043, 1, 0 )//AJUDA##"Favor informar a utorizacao"
		lRetorno := .F.
	ENDIF
	IF lRetorno
		IF ! OG180VTAB(.F.)   //Validando a Tabela contra o Produto antes de Salvar
			lRetorno := .f.
		EndIF
	EndIF
Return( lRetorno )

/** {Protheus.doc} OG180GTAB
@param:     Nil
@author:    Vinicius Pagung
@since:     18/12/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
//Função para preencher itens da Tabela de Desconto //
Static function OG180GTAB( )
	Local aAreaAtu      := GetArea()
	Local oModel        := FwModelActive()
	Local oGrdNJG       := oModel:GetModel( "NJGUNICO" )
	Local cTabela       := oModel:GetModel('NJFUNICO'):GetValue( "NJF_TABELA" )
	Local nX            := 0
	Local nCount        := 0
	Local nLinha        := oGrdNJG:Length()
	Local cAliasQry     := GetNextAlias()

	oGrdNJG:SetNoInsert( .f. )
	oGrdNJG:SetNoDelete( .f. )
	
	//Verifica se o item já possui uma liberação na SC9
	//com agendamento na NJ5
	cQuery := "SELECT NNJ.NNJ_CODDES "
	cQuery += " FROM " + RetSqlName("NNJ") + " NNJ "
	cQuery += " WHERE NNJ.NNJ_FILIAL = '" + FwxFilial('NNJ') + " '"
	cQuery += " AND   NNJ.NNJ_CODTAB = '" + cTabela + "' "
	cQuery += " AND   NNJ.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NNJ.NNJ_SEQ "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(! Eof() )
		While (cAliasQry)->(! Eof() )
			nCount++
			If nCount > nLinha
				cItem := SOMA1( fwfldget('NJG_ITEM') )
				oGrdNJG:AddLine()
				oGrdNJG:SetValue( "NJG_ITEM"  , cItem )
			Else
				oGrdNJG:GoLine( nCount )
				If oGrdNJG:IsDeleted()
					oGrdNJG:UnDeleteLine()
				EndIf
			EndIf
			oGrdNJG:SetValue( "NJG_CODDES", (cAliasQry)->NNJ_CODDES )
			oGrdNJG:SetValue( "NJG_PERDES", 0 )

			(cAliasQry)->( DbSkip() )
		End

		If nCount < nLinha
			For nX := nCount to nLinha
				oGrdNJG:GoLine( nX )
				oGrdNJG:DeleteLine()
			Next nX
		EndIf

	EndIf
	(cAliasQry)->(DbcloseArea())

	oGrdNJG:SetNoInsert( .t. )
	oGrdNJG:SetNoDelete( .t. )
	oGrdNJG:GoLine( 1 )

	RestArea (AAreaAtu )        

Return ( cTabela )

/** {Protheus.doc} OGA180HIS
Descrição: Mostra em tela de Historico da Amostra

@param:     Nil
@author:    Vinicius Pagung
@since:     18/12/2015
@Uso:       OGA180
*/
Function OGA180HIS()
	Local cChaveI := "NJF->("+Alltrim(AGRSEEKDIC("SIX","NJF1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NJF",cChaveA)
Return


/** {Protheus.doc} fChkAutor
Verifica se Já existe uma Autorização
q foi gerada por uma outra Amostra Avulsa
Caso sim, Retorna o nr. da Autorização;
Essa rotina visa garantir q as amostras avulsas ref. a um contrato
gerem somente uma autorização, é envial q cada amostra avulsa gere
uma autorização, pois no romaenio teria q informar autorização por autorização
e isso não é necessario para o Caso de recebimento de soja dest. a semente, a Qualidade
quer apenas garantir que não se receba mais mercadoria que o X ( soma das qts. autorizadas na amostra Avulsa)
q a qualidade já autorizou a receber;

@param:    	Contrato, Tipo da Autorização na amostra avulsa;
@Return:    Item da Autorizacao
@author:    Emerson Coelho
@since:     18/12/2015
@Uso:       OGA180
*/
Static Function fChkAutor( cCodCTR, cTipo )
	Local cItem := ''  // Vazio
	Local aAreaAtu := GetArea()
	Local aAreaNJP := NJP->( GetArea() )
	Local aAreaNJF := NJF->( GetArea() )

	dbSelectArea( "NJP" )
	NJP->( dbSetOrder( 1 ) ) //NJP_FILIAL+NJP_CODCTR+NJP_ITEM
	NJP->( dbSeek( fwxFilial( "NJP" ) + cCodCtr ))
	While NJP->(! Eof() )  .and. NJP->(NJP_FILIAL+NJP_CODCTR) == fwxFilial( "NJP" ) + cCodCtr

		IF ! NJP->NJP_STATUS = 'E' //não Está Encerrada
			IF Alltrim( NJP->NJP_TIPO ) == Alltrim( NJF->NJF_TIPAUT )   //-> Verifico se o Tipo de Autorizacao encontrada é igual o tipo da Autorização da Amostra Avulsa
				dbSelectArea( "NJF" )
				NJF->( dbSetOrder( 5 ) ) //NJP_FILIAL+NJP_CODCTR+NJP_ITEM
				IF NJF->( dbSeek( fwxFilial( "NJF" ) + NJP->(NJP_CODCTR+NJP_ITEM) ))   // Identifico a Amostra avulsa que gerou a Autorização ( Garantindo q Autoriz. foi gerada pela rotina de amostra avulsa)
					cItem:=NJP->NJP_ITEM
					Exit  
				EndIF
			EndIF
		EndIF 

		NJP->( DbSkip() )
	EndDo

	RestArea( aAreaAtu )
	RestArea( aAreaNJP )
	RestArea( aAreaNJF )

	//cItem Possui o Nr. da Autorizacao que devo Fazer manutenção, se citem estiver vazio não existe autorização
Return ( cItem )

