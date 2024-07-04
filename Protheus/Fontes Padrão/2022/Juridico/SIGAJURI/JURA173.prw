#INCLUDE "JURA173.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
//----------------------------------------------------------------------
/*/{Protheus.doc} JURA173
Cadastro Follow-Up Padrão

@author Clovis E. Teixeira dos Santos
@since 27/08/09
@version 1.0
/*/
//----------------------------------------------------------------------
Function JURA173()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRT" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRT" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL
//----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0
/*/
//------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA173", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA173", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA173", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA173", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA173", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina
//------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Follow-Up Padrão

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0
/*/
//------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := FwLoadModel( "JURA173" )
Local oStructNRT
Local oStructNRR
Local oStructNZ5

//------------------------------------------------------------------------
//Montagem da interface via dicionario de dados
//------------------------------------------------------------------------
oStructNRT := FWFormStruct( 2, "NRT" )
oStructNRR := FWFormStruct( 2, "NRR" )
oStructNZ5 := FWFormStruct( 2, "NZ5" )

oStructNRR:RemoveField( "NRR_CFOLWP" ) 
oStructNRR:RemoveField( "NRR_CPART" )

oStructNZ5:RemoveField( "NZ5_CFOLWP" )
//------------------------------------------------------------------------
//Montagem do View normal se Container
//------------------------------------------------------------------------
JurSetAgrp( 'NRT',, oStructNRT )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0007 ) // "Follow-Up Padrão"

oView:AddField( "JURA173_VIEW"   , oStructNRT, "NRTMASTER" )

oView:CreateHorizontalBox( "FORMFUPADRAO", 50 )
oView:SetOwnerView( "NRTMASTER", "FORMFUPADRAO" )

oView:CreateHorizontalBox( "FORMDETAIL", 50 )
oView:CreateFolder("FOLDER_01", "FORMDETAIL" )

oView:AddGrid(  "JURA173_DETAIL_NRR" , oStructNRR, "NRRDETAIL" )
oView:AddSheet("FOLDER_01", "ABA_01_01", STR0009 )		//"Responsáveis Modelo Follow-Up"
oView:CreateHorizontalBox("BOX_01_F01_A01" ,100,,,"FOLDER_01","ABA_01_01")
oView:SetOwnerView( "JURA173_DETAIL_NRR", "BOX_01_F01_A01"  )	

oView:AddGrid(  "JURA173_DETAIL_NZ5" , oStructNZ5, "NZ5DETAIL" )
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0012 )		//"Outros Responsáveis Modelo Follow-Up"
oView:CreateHorizontalBox("BOX_01_F01_A02" ,100,,,"FOLDER_01","ABA_01_02")
oView:SetOwnerView( "JURA173_DETAIL_NZ5", "BOX_01_F01_A02"  )	

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Follow-Up Padrão

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0

@obs NRTMASTER - Cabecalho Follow-up Padrão / NRRDETAIL - Responsáveis Follow-Up Padrão
/*/
//------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := NIL
Local oStructNRT
Local oStructNRR
Local oStructNZ5	

//-------------------------------------------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-------------------------------------------------------------------------
oStructNRT := FWFormStruct(1,"NRT")
oStructNRR := FWFormStruct(1,"NRR")
oStructNZ5 := FWFormStruct(1,"NZ5")

oStructNRR:RemoveField( "NRR_CFOLWP" )
oStructNZ5:RemoveField( "NZ5_CFOLWP" )

//-------------------------------------------------------------------------
//Monta o modelo do formulário
//-------------------------------------------------------------------------
oModel:= MpFormModel():New( "JURA173", /*Pre-Validacao*/, /*Pos-Validacao*/{|oModel| JURA173TOK(oModel)}, { |oX| JA173Commit(oX) } /*Commit*/,/*Cancel*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados Follow-Up Padrão"
//JurSetRules( oModel, "NQSMASTER", , "NQS",, "JURA173" )

oModel:AddFields( "NRTMASTER", /*cOwner*/, oStructNRT, /*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:AddGrid( "NRRDETAIL", "NRTMASTER" /*cOwner*/, oStructNRR, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( "NZ5DETAIL", "NRTMASTER" /*cOwner*/, oStructNZ5, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:GetModel( "NRTMASTER" ):SetDescription( STR0008 ) // "Cabecalho Follow-Up Padrão"
oModel:GetModel( "NRRDETAIL" ):SetDescription( STR0009 ) // "Responsáveis Follow-Up Padrão"
oModel:GetModel( "NZ5DETAIL" ):SetDescription( STR0012 ) // "Outros Responsáveis Follow-Up Padrão"


oModel:GetModel( "NRRDETAIL" ):SetUniqueLine( { "NRR_SIGLA" } )
oModel:GetModel( "NZ5DETAIL" ):SetUniqueLine( { "NZ5_CAMPO" } )

oModel:SetRelation( "NRRDETAIL", { { "NRR_FILIAL", "XFILIAL('NRR')" }, { "NRR_CFOLWP", "NRT_COD" } }, NRR->( IndexKey( 1 ) ) )
oModel:SetRelation( "NZ5DETAIL", { { "NZ5_FILIAL", "XFILIAL('NZ5')" }, { "NZ5_CFOLWP", "NRT_COD" } }, NZ5->( IndexKey( 1 ) ) )
                
oModel:GetModel( "NRRDETAIL" ):SetDelAllLine( .F. )  
oModel:GetModel( "NZ5DETAIL" ):SetDelAllLine( .F. )

oModel:SetOptional( "NRRDETAIL" , .T. )
oModel:SetOptional( "NZ5DETAIL" , .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA173TOK(oModel)
Validações para que seja permitida a inclusão de registro
@author Clovis E. Teixeira dos Santos
@since 14/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA173TOK(oModel)
Local lTudoOk  	:= .T.
Local cModelNRT	:= oModel:GetModel("NRTMASTER")
Local cModelNRR	:= oModel:GetModel("NRRDETAIL")
Local nCt
Local oModelNZ5	:= oModel:GetModel("NZ5DETAIL")
Local lTemPartic:= .F.

//*******************************************************
//Verificar o preenchimento dos campos de hora e duração
// conforme configuração do tipo de follow-up
//*******************************************************
If Posicione('NQS', 1 , xFilial('NQS') + cModelNRT:GetValue('NRT_CTIPOF') , 'NQS_HORAM') == '1'
	
	If Empty(cModelNRT:GetValue('NRT_HORAF')) .Or.;
		(cModelNRT:GetValue('NRT_DURACA') == '  :  ' .Or. cModelNRT:GetValue('NRT_DURACA') == '00:00')
		
		JurMsgErro(STR0011 + RetTitle('NRT_HORAF') +','+ RetTitle('NRT_DURACA'))
		lTudoOk = .F.
		
	EndIf
	
EndIf

If lTudoOk
	
	//*********************************************************************
	//Verificar o preenchimento dos campos de tipo de data e qtde de dias
	// quando for geração automática
	//*********************************************************************
	
	If cModelNRT:GetValue('NRT_TIPOGF') == '1'
		
		If Empty(cModelNRT:GetValue('NRT_DATAT'))		
			JurMsgErro(STR0011 + RetTitle('NRT_DATAT'))
			lTudoOk = .F.			
		ElseIf Empty(cModelNRT:GetValue('NRT_QTDED')) .Or. cModelNRT:GetValue('NRT_QTDED') <= 0			
			JurMsgErro(STR0011 + RetTitle('NRT_QTDED'))
			lTudoOk = .F.			
		EndIf

		//Valida o preenchimento de ao menos 1 grid		
		For nCt := 1 To cModelNRR:GetQtdLine()			
			cModelNRR:GoLine( nCt )				
			If !cModelNRR:IsDeleted()
				If !Empty(cModelNRR:GetValue('NRR_SIGLA'))
					lTemPartic := .T.
					Exit 
				EndIf
			EndIf		
		Next
		
		//Valida o preenchimento de ao menos 1 grid		
		If !lTemPartic
			For nCt := 1 To oModelNZ5:GetQtdLine()			
				oModelNZ5:GoLine( nCt )				
				If !oModelNZ5:IsDeleted()
					If !Empty(oModelNZ5:GetValue('NZ5_CAMPO'))
						lTemPartic := .T.
						Exit 
					EndIf
				EndIf		
			Next
		EndIf

		If !lTemPartic
			JurMsgErro(STR0011 + RetTitle('NRR_SIGLA') + " ou " + RetTitle('NZ5_CAMPO'))
			lTudoOk = .F.		
		EndIf
		
    ElseIf cModelNRT:GetValue('NRT_TIPOGF') == '2'  //Intervencao do usuario
		
        If  (cModelNRT:GetValue('NRT_QTDED') > 0) .And. Empty(cModelNRT:GetValue('NRT_DATAT'))		
            JurMsgErro(STR0011 + RetTitle('NRT_DATAT'))
            lTudoOk = .F.			
        ElseIf (cModelNRT:GetValue('NRT_QTDED') < 0) .Or.;
               !Empty(cModelNRT:GetValue('NRT_DATAT')) .And. (Empty(cModelNRT:GetValue('NRT_QTDED')) .Or. (cModelNRT:GetValue('NRT_QTDED') <= 0))			
            JurMsgErro(STR0011 + RetTitle('NRT_QTDED'))
            lTudoOk = .F.			
        EndIf

    EndIf
EndIf	

If lTudoOk

	If cModelNRT:GetValue('NRT_SUGDES') == '2' .And. Empty(Alltrim(cModelNRT:GetValue('NRT_DESC')))
		lTudoOk = .F.
		JurMsgErro(STR0011 + RetTitle('NRT_DESC'))
	EndIf

EndIf

Return lTudoOk

//-------------------------------------------------------------------
/*/{Protheus.doc} JA173Commit
Commit de dados de Modelo de Flw Up

@author Rafael Rezende Costa
@since 18/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA173Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NRTMASTER","NRT_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NRT',cCod)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA173VdCam
Valida campo NZ5_CAMPO

@author Rafael Tenorio da Costa
@since 18/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA173VdCam( cCampo )

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local cTabela	:= ""	
	Local aSx9CmpRel:= {}

	//Retorna a tabela do campo	
	cTabela := JurPrefTab( cCampo )

	If !(cTabela $ "NSZ|NUQ")
		JurMsgErro(STR0014)		//"Responsável inválido. Verifique se o campo é do Assunto Jurídico(NSZ) ou da Instância(NUQ)."
		lRet := .F.
	EndIf
	
	If lRet
	
		//Busca tabelas relacionada a RD0
		aSx9CmpRel := JURSX9("RD0", cTabela)
		
		If Len(aSx9CmpRel) == 0
		
			JurMsgErro(STR0013)		//"Não foi encontrado relacionamento da tabela desse campo com a tabela de Pessoas\Participantes(RD0)."
			lRet := .F.
		Else
			
			If !( Ascan(aSx9CmpRel, {|x| AllTrim(x[2]) == cCampo .And. x[3] == 1}) > 0 )

				JurMsgErro(STR0015)		//"Campo sem relacionamento com a tabela de Pessoas\Participante(RD0)."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	RestArea( aArea )	
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J173ClrDes()
Limpa descrição quando sugestão de descrição for diferente de Follow-up

@author Jorge Luis Branco Martins Junior
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J173ClrDes()
Local oModel := FWModelActive()

If M->NRT_SUGDES <> '2'
	oModel:ClearField("NRTMASTER","NRT_DESC")
EndIf

Return .T.