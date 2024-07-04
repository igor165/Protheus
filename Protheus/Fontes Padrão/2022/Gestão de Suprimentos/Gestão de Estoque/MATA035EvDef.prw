#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "MATA035.ch"

/*/{Protheus.doc} MATA035EvDef
Classe Responsavel pelo Evento de validações e atualizações do Cadastro de Grupo de Produtos
@author    Paulo V. Beraldo
@since     25/10/2018
@version   $1.00
@example
(examples)
@see (links_or_references)
/*/

Function MT035EvDef(); Return .T.

Class MATA035EvDef From FwModelEvent
Data aIntSBM		As Array
Data auMovStatus	As Array
Data oModel			As Object

Method New() Constructor
Method A035Int( nMomento, nOpc )
Method AfterTTS( oModel, cIdModel  )
Method A035IniInt( nOpc )
Method A035FimInt( nOpc )
Method ModelPreVld( oModel, cModelId )
Method ModelPosVld( oModel, cModelId )

EndClass

/*/{Protheus.doc} new
Metodo construtor
@author    beraldo
@since     25/10/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method new() Class MATA035EvDef
Self:oModel 	:= Nil
Self:aIntSBM	:= {}
Self:auMovStatus:= {}

Return Self


/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre validação do modelo
@author    beraldo
@since     25/10/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method ModelPreVld( oModel, cModelId ) Class MATA035EvDef
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local nOpc 		:= oModel:GetOperation()

If nOpc == 1
	nOpc := 2
EndIf

Self:auMovStatus := {}
Self:A035Int( 1, nOpc )

RestArea(aAreaSB1)
RestArea(aArea)
Return lRet

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos validação do modelo
@author    beraldo
@since     25/10/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method ModelPosVld( oModel, cModelId ) Class MATA035EvDef
Local nOpc 			:= oModel:GetOperation()
Local lRet 			:= .T.
Local lIntSFC 		:= ExisteSFC("SBM") .And. !IsInCallStack("AUTO035")// Determina se existe integracao com o SFC
Local lIntDPR 		:= IntegraDPR() .And. !IsInCallStack("AUTO035")// Determina se existe integracao com o DPR
LOCAL luMovme		:= (SuperGetMV("MV_UMOV",,.F.)) // Indica se Existe Integração Protheus x uMov.me
Local oMdl
Local cDescricao 	:= ""
Local lMa035Del 	:= ExistBlock( "MA035DEL" )

If	nOpc == 3 .Or. nOpc == 4
	lRet := Ma035Valid(nOpc)
ElseIf nOpc == 5
	lRet := A035Deleta("SBM", SBM->(Recno()), nOpc)
EndIf

If lRet
	Self:A035Int( 2, 2, {} )
	If lMa035Del
		Execblock( "MA035DEL", .F., .F. )
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina para integracao com DPR(Desenvolvedor de Produtos) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And.(lIntDPR .Or. lIntSFC)
	lRet := A035IntDPR(nOpc)
EndIf

If	luMovme .And. (nOpc == 3 .Or. nOpc == 4)
	oMdl := oModel:GetModel('MATA035_SBM')
	cDescricao := oMdl:GetValue('BM_DESC')
	If cDescricao <> SBM->BM_DESC
		aAdd( Self:auMovStatus, oMdl:GetValue('BM_GRUPO') )
	EndIf
EndIf

Return(lRet)

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
@author    beraldo
@since     25/10/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method AfterTTS( oModel, cIdModel ) Class MATA035EvDef
Local lRet			:= .T.
Local nX			:= 0
Local nOpc 			:= oModel:GetOperation()
Local cNameBlock  	:= Iif(nOpc == 3,"MA035INC","MA035ALT")
LOCAL lPIMSINT 	:= (SuperGetMV("MV_PIMSINT",.F.,.F.))// Indica se Existe Integração Protheus x PIMS Graos
LOCAL luMovme		:= (SuperGetMV("MV_UMOV",,.F.)) // Indica se Existe Integração Protheus x uMov.me
Local lExistBlk		:= ExistBlock( cNameBlock )

If nOpc == 3 .Or. nOpc == 4
	IIf( lExistBlk, Execblock( cNameBlock, .F., .F. ), Nil )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao PIMS GRAOS        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPIMSINT
		PIMSGeraXML("MaterialFamily",STR0010,"2","SBM")
	EndIf

	If luMovme .And. Len( Self:auMovStatus ) > 0
		For nX := 1 to Len( Self:auMovStatus )
			If SBM->(MsSeek( FWxFilial( "SBM" ) + Self:auMovStatus[ nX ] ) )
				RecLock( "SBM", .F.)
				SBM->BM_DTUMOV := CTOD("")
				SBM->BM_HRUMOV := ""
				SBM->(MsUnlock())
			EndIf
		Next
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} A035Int
Metodo Utilizado para executar a Integração Protheus x RM Nucleus via EAI e TOTVS-ESB
@author    beraldo
@since     25/10/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method A035Int( nMomento, nOpc )  Class MATA035EvDef
Local lRet		:= .T.
Local aArea		:= GetArea()
Local lIntegra 	:= SuperGetMv("MV_LJGRINT", .F., .F.)	// Se há integração ou não


If lIntegra
	If nMomento == 1
		MsgRun( STR0012, STR0011, {|| Self:A035IniInt( nOpc ) } ) // "Aguarde" "Anotando registros para integração"
	ElseIf nMomento == 2
		MsgRun( STR0013, STR0011, {|| Self:A035FimInt( nOpc ) } ) // "Aguarde" "Executando integração"
	EndIf
EndIf

RestArea( aArea )
Return

/*/{Protheus.doc} A035IniInt
Metodo Responsavel por Iniciar a Integração Protheus x RM Nucleus via EAI e TOTVS-ESB
@author    beraldo
@since     25/10/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method A035IniInt( nOpc )   Class MATA035EvDef
Local oFactory		:= LJCAdapXmlEnvFactory():New()
Local cChave		:= ""


// Se houver integração e não for inclusão, anota todos os registros para exclusão, caso algum seja excluído
If nOpc != 3
	Self:aIntSBM :=	{ SBM->(Recno()), oFactory:Create( "SBM" ) }
	cChave 	:= xFilial( "SBM" ) + SBM->BM_GRUPO
    Self:aIntSBM[2]:Inserir( "SBM", cChave, "1", "5" )
    Self:aIntSBM[2]:Gerar()
EndIf

Return

/*/{Protheus.doc} A035FimInt
Metodo Responsavel por Finalizar a Integração Protheus x RM Nucleus via EAI e TOTVS-ESB
@author    beraldo
@since     25/10/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method A035FimInt( nOpc )   Class MATA035EvDef
	Local oFactory		:= LJCAdapXmlEnvFactory():New( )	// Cria a fabrica de Adaptadores de envio
	Local cChave		:= ""

	// Verifica se houve algum registro apagado, e gera a integração desse registro
	If nOpc != 3
		If Len( Self:aIntSBM ) > 0
			// Procura pelo registro do cabeçalho
			SBM->( DbGoTo( Self:aIntSBM[ 1 ] ) )

			// Se não encontrar, significa que o cabeçalho foi apagado, então envia somente a exclusão do cabeçalho
			If SBM->( DELETED() )
				Self:aIntSBM[2]:Finalizar()
			EndIf
		EndIf
	EndIf

	// Independente de ter registros apagados ou não, gera quando não for exclusão, todos os outros registros
	If nOpc != 5
		Self:aIntSBM := { SBM->( Recno() ), oFactory:Create( "SBM" ) }
		cChave 	:= xFilial( "SBM" ) + SBM->BM_GRUPO
	    Self:aIntSBM[2]:Inserir( "SBM", cChave, "1", cValToChar( nOpc ) )
	    Self:aIntSBM[2]:Gerar()
		Self:aIntSBM[2]:Finalizar()
	EndIf
Return
