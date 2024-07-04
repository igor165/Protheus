#Include 'TMSA461.ch'
#Include 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMSA461
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	*/
//-----------------------------------------------------------------------------------------------------------

Function TMSA461()

Local aArea     := GetArea()
Local oBrowse 	:= Nil			// Recebe o objeto do Browse

SaveInter() //-- Salva Area

Private aRotina	  := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DF6')
oBrowse:SetDescription(STR0001) // Conferencia de Coletas

//-- Legenda
oBrowse:AddLegend( "DF6_QTDENF > DF6_QTDDIG", "GREEN" , STR0009 )  //Em Aberto
oBrowse:AddLegend( "DF6_QTDENF == DF6_QTDDIG", "RED"  , STR0010 )  //Encerrada

oBrowse:SetCacheView( .F. )
oBrowse:Activate()  

RestArea( aArea )
RestInter()

Return()

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - ModelDef
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	oModel */
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel        := Nil
Local oStruCDF6     := Nil
Local oStruIDF6     := Nil
Local oStruIDMH     := Nil
Local lTmA461Cpo    := ExistBlock('TMA461CPO') //-- Permite ao usuario, incluir campos na getdados
Local cCpos         := ''
Local aCposPE       := {}
Local nCntFor       := 0
Local lDMH 		    := AliasIndic("DMH")

If lTmA461Cpo
    aCposPE := ExecBlock("TMA461CPO",.F.,.F. )
    If ValType(aCposPE) =="A"
        For nCntFor:=1 to Len(aCposPE)
            cCpos += aCposPE[nCntFor] + '|'
        Next nCntFor		
    EndIf
EndIf
oStruCDF6 := FwFormStruct( 1, "DF6", { |cCampo|  AllTrim( cCampo ) + "|" $ "DF6_FILORI|DF6_VIAGEM|" + cCpos } )
oStruIDF6 := FwFormStruct( 1, "DF6", { |cCampo| !AllTrim( cCampo ) + "|" $ "DF6_FILORI|DF6_VIAGEM|" + cCpos } )
If lDMH
    oStruIDMH := FwFormStruct( 1, "DMH" )
EndIf

oModel := MpFormModel():New( "TMSA461", /*bPre*/ , {|oModel| TMA461ChkD( oModel )}/*bPost*/, { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi( STR0001 ) ) // 'Conferencia de Coletas'

oModel:AddFields( "TMS461CDF6", Nil, oStruCDF6, /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/ )

oModel:SetPrimaryKey( { "DF6_FILIAL", "DF6_FILORI","DF6_VIAGEM", "DF6_FILDOC", "DF6_DOC","DF6_SERIE" } )

oModel:AddGrid( "TMS461IDF6", "TMS461CDF6", oStruIDF6, { |oMdlGrd, nLine, cAction, cField| DF6LinePre( oMdlGrd, nLine, cAction, cField ) }, ,/*bPre*/,/*bPost*/,/*bLoad*/ )

oModel:SetRelation( "TMS461IDF6", { { "DF6_FILIAL", "xFilial('DF6')" }, { "DF6_FILORI", "DF6_FILORI" }, { "DF6_VIAGEM", "DF6_VIAGEM" } }, DF6->( IndexKey( 1 ) ) )

oModel:GetModel( "TMS461IDF6" ):SetUniqueLine( { "DF6_FILDOC","DF6_DOC","DF6_SERIE" } )

oModel:GetModel( "TMS461IDF6" ):SetDelAllLine( .T. )

If lDMH
    oModel:AddGrid("DMHDET","TMS461IDF6"/*cOwner*/,oStruIDMH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    oModel:SetRelation("DMHDET",{ {"DMH_FILIAL", "xFilial('DMH')"}, {"DMH_FILORI", "DF6_FILORI"},  {"DMH_VIAGEM", "DF6_VIAGEM"},  {"DMH_SEQUEN", "DF6_SEQUEN"} }, DMH->(IndexKey()) )
    oModel:GetModel( "DMHDET" ):SetUniqueLine( { "DMH_CHVNFE" } ) // DMH_FILIAL, DMH_FILORI, DMH_VIAGEM, DMH_SEQUEN, DMH_SEQNFE, DMH_CHVNFE
    oModel:GetModel( "DMHDET" ):SetOptional( .T. )
    oStruIDMH:SetProperty("DMH_CHVNFE", MODEL_FIELD_WHEN, {|| ChvNFeLock(oModel) })
EndIf

oModel:SetVldActivate( { |oModel| VldActdMdl( oModel ) } )

oModel:SetDeActivate( { |oModel| DeActMdl( oModel ) } )

Return(oModel)

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - ViewDef
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	oView */
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FwLoadModel( "TMSA461" )
Local oView	  		:= Nil
Local oStruCDF6		:= Nil
Local oStruIDF6		:= Nil
Local oStruDMH      := Nil
Local lTmA461Cpo    := ExistBlock('TMA461CPO') //-- Permite ao usuario, incluir campos na getdados
Local cCpos         := ''
Local aCposPE       := {}
Local nCntFor       := 0
Local lDMH 		    := AliasIndic("DMH")

If lTmA461Cpo
    aCposPE := ExecBlock("TMA461CPO",.F.,.F. )
    If ValType(aCposPE) =="A"
        For nCntFor:=1 to Len(aCposPE)
            cCpos += aCposPE[nCntFor] + '|'
        Next nCntFor		
    EndIf
EndIf

oStruCDF6 := FwFormStruct( 2, "DF6", { |cCampo|  AllTrim( cCampo ) + "|" $ "DF6_FILORI|DF6_VIAGEM|" + cCpos} )
oStruIDF6 := FwFormStruct( 2, "DF6", { |cCampo| !AllTrim( cCampo ) + "|" $ "DF6_FILORI|DF6_VIAGEM|" + cCpos} )

If lDMH
    oStruDMH := FwFormStruct( 2, "DMH", { |cCampo| !AllTrim( cCampo ) + "|" $ "DMH_FILORI|DMH_VIAGEM|DMH_SEQUEN|" } )
EndIf

oView := FwFormView():New()
oView:SetModel( oModel )

oView:AddField( "VIEWCDF6", oStruCDF6, "TMS461CDF6" )
oView:AddGrid(  "VIEWIDF6", oStruIDF6, "TMS461IDF6" )

If lDMH
    oView:AddGrid ( "VIEWDMH", oStruDMH, "DMHDET")
EndIf

oView:AddIncrementField( 'VIEWIDF6', 'DF6_SEQUEN' )

If lDMH
    oView:AddIncrementField( 'VIEWDMH', 'DMH_SEQNFE' )
EndIf

If lDMH
	oView:CreateHorizontalBox("TOPO"   , 10)
	oView:CreateHorizontalBox("GRID"   , 50)
	oView:CreateHorizontalBox("NFS"    , 40)
Else
    oView:CreateHorizontalBox( 'TOPO'   , 10 )
    oView:CreateHorizontalBox( 'GRID'   , 90 )
Endif

oView:SetOwnerView( "VIEWCDF6"  , "TOPO"  )
oView:SetOwnerView( "VIEWIDF6"  , "GRID"  )

If lDMH
    oView:SetOwnerView( "VIEWDMH"  , "NFS"  )
    oView:AddUserButton(STR0014,'', {|oModel| TMA461CBar(oModel)} ) //Código de Barras
EndIf

Return( oView )

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - MenuDef
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	aRotina */
//-----------------------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aArea		:= GetArea()

Private aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSA461"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSA461"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005, "VIEWDEF.TMSA461"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSA461"  , 0, 5, 0, Nil } ) // Excluir	
aAdd( aRotina, { STR0016, "TMA461Proc"       , 0, 6, 0, Nil } ) // Processa NFe

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TMA461MNU")
	ExecBlock("TMA461MNU",.F.,.F.)
EndIf

RestArea( aArea )

Return aRotina

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - VldActdMdl
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	lRet */
//-----------------------------------------------------------------------------------------------------------

Static Function VldActdMdl( oMdl )

Local aArea		:= GetArea()
Local lRet		:= .T.
Local nOpcx		:= oMdl:GetOperation()

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If nOpcx <> MODEL_OPERATION_VIEW .And. nOpcx <> MODEL_OPERATION_INSERT
	If !TMSAVerAge("6",,,,,,,,,,,,"2",.T.,.T.,,M->DF6_VIAGEM,)
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )

Return( lRet )

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - DeActMdl
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	lRet */
//-----------------------------------------------------------------------------------------------------------
Static Function DeActMdl( oMdl )
Local aArea := GetArea()
Local lRet := .T.

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

RestArea(aArea)

Return(lRet)

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - CommitMdl - Efetiva a gravação do Modelo e chamas a funções de ATZ de Status da DT5
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	lRet */
//-----------------------------------------------------------------------------------------------------------
Static Function CommitMdl( oMdl )

Local aAreaDT5		:= DT5->(GetArea())
Local aAreaDTC		:= DTC->(GetArea())
Local lRet			:= .T.
Local nOpcx	  		:= oMdl:GetOperation()
Local oMdlGrid	    := oMdl:GetModel("TMS461IDF6")
Local nCntFor1      := 0
Local cStatus       := ''
Local nQtdVol       := 0
Local nPeso         := 0
Local cFilOri       := FwFldGet("DF6_FILORI")
Local cViagem       := FwFldGet("DF6_VIAGEM")
Local cFilDoc       := ""
Local cDoc          := ""
Local cSerie        := ""
Local nQtdDig       := 0
Local nQtdNF        := 0

Private cOcorCol    := ''

For nCntFor1 := 1 To oMdlGrid:Length()
    oMdlGrid:GoLine(nCntFor1)
    
    cFilDoc := oMdlGrid:GetValue('DF6_FILDOC', nCntFor1)
    cDoc    := oMdlGrid:GetValue('DF6_DOC', nCntFor1)
    cSerie  := oMdlGrid:GetValue('DF6_SERIE', nCntFor1)
    nQtdDig := oMdlGrid:GetValue('DF6_QTDDIG', nCntFor1)
    nQtdNF  := oMdlGrid:GetValue('DF6_QTDENF', nCntFor1)

    If !oMdlGrid:IsDeleted(nCntFor1)
        If nOpcx == MODEL_OPERATION_INSERT

            cStatus:= StsDT5Ups( nQtdDig, nQtdNF )
            AtStsDT5(cFilDoc, cDoc, cSerie, cStatus)
            
        ElseIf nOpcx == MODEL_OPERATION_UPDATE .And. A050ApoCol()
           
            If oMdlGrid:IsInserted(nCntFor1)

                    cStatus:= StsDT5Ups( nQtdDig, nQtdNF )
                    AtStsDT5(cFilDoc, cDoc, cSerie, cStatus)    
                
            ElseIf oMdlGrid:IsUpdated(nCntFor1)

                If nQtdNF > nQtdDig
                    lRet := A050EstCFec(	cFilDoc,;
                                            cDoc,;
                                            cSerie,;
                                            cFilOri,;
                                            cViagem 	)

                ElseIf nQtdDig == nQtdNF
                    DTC->(DbSetOrder(8))
                    If DTC->(MsSeek(xFilial('DTC') + cFilDoc + cDoc ))
                        While DTC->(DTC_FILIAL+DTC_FILORI+DTC_NUMSOL) == xFilial('DTC') + cFilDoc + cDoc
                            nQtdVol := nQtdVol + DTC->DTC_QTDVOL
                            nPeso   := nPeso + DTC->DTC_PESO
                            DTC->(DbSkip())
                        EndDo
                    EndIf
                    lRet := TMSA050CFec(cFilDoc,;
                                        cDoc,;
                                        cSerie,;
                                        nQtdVol,;
                                        nPeso,;
                                        oMdlGrid:GetValue('DF6_DATCOL', nCntFor1),;
                                        oMdlGrid:GetValue('DF6_HORCOL', nCntFor1),;
                                        '',;
                                        oMdlGrid:GetValue('DF6_ODOCHG', nCntFor1),;
                                        oMdlGrid:GetValue('DF6_DATCHG', nCntFor1),;
                                        oMdlGrid:GetValue('DF6_HORCHG', nCntFor1),;
                                        oMdlGrid:GetValue('DF6_DATSAI', nCntFor1),;
                                        oMdlGrid:GetValue('DF6_HORSAI', nCntFor1)	)
                    
                EndIf

                If lRet
                    cStatus:= StsDT5Ups( nQtdDig, nQtdNF )
                    AtStsDT5(cFilDoc, cDoc, cSerie, cStatus)      
                EndIf

            EndIf
        
        ElseIf nOpcx == MODEL_OPERATION_DELETE
        
            cStatus:= StsDT5Del(cFilDoc, cDoc, cSerie, cFilOri, cViagem)
            AtStsDT5(cFilDoc, cDoc, cSerie, cStatus)

        EndIf
    Else
        
        If nOpcx == MODEL_OPERATION_UPDATE
            cStatus:= StsDT5Del(cFilDoc, cDoc, cSerie, cFilOri, cViagem)
            AtStsDT5(cFilDoc, cDoc, cSerie, cStatus)
        EndIf

    EndIf
    
Next nCntFor1
    
FWFormCommit( oMdl )

RestArea(aAreaDT5)
RestArea(aAreaDTC)

Return( lRet )

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - StsDT5Ups - Retorna o Status para atualizar a DT5 no caso de uma inclusão ou alteração
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	cStatus */
//-----------------------------------------------------------------------------------------------------------
Static Function StsDT5Ups( nQtdDig, nQtdNF )

Local aArea     := GetArea()
Local cStatus   := ""

Default nQtdDig := 0
Default nQtdNF  := 0

If  nQtdNF == nQtdDig
    cStatus := StrZero(5,Len(DT5->DT5_STATUS)) //-- Documento Informado
ElseIf nQtdNF > nQtdDig
    cStatus := StrZero(7,Len(DT5->DT5_STATUS)) //-- Em Conferencia
EndIf

RestArea(aArea)
Return(cStatus)

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - StsDT5Del - Retorna o Status para atualizar a DT5 no caso de uma exclusão
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	cStatus */
//-----------------------------------------------------------------------------------------------------------
Static Function StsDT5Del( cFilDoc, cDOc, cSerie, cFilOri, cViagem )

Local aArea     := GetArea()
Local cStatus   := ""
Local cStatDUD  := ""

Default cFilDoc := ""
Default cDOc    := ""
Default cSerie  := ""
Default cFilOri := ""
Default cViagem := ""

cStatDUD := Posicione('DUD',1,xFilial('DUD') +cFilDoc + cDoc + cSerie + cFilOri + cViagem, 'DUD_STATUS')

If cStatDUD == StrZero(1,Len(DUD->DUD_STATUS)) .Or. cStatDUD == StrZero(3,Len(DUD->DUD_STATUS))
    cStatus := StrZero(2,Len(DT5->DT5_STATUS)) //-- Indicado para Coleta
ElseIf cStatDUD == StrZero(2,Len(DUD->DUD_STATUS))
    cStatus := StrZero(3,Len(DT5->DT5_STATUS)) //-- Em Transito
ElseIf cStatDUD == StrZero(4,Len(DUD->DUD_STATUS)) 
    cStatus := StrZero(4,Len(DT5->DT5_STATUS)) // -- Encerrado
EndIf

RestArea(aArea)
Return(cStatus)

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - AtStsDT5 - Atualiza o status da solicitação de coleta (DT5)
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function AtStsDT5(cFilDoc, cDoc, cSerie, cStatus)

Local aArea      := GetArea()

Default cFilDoc  := ""
Default cDoc     := ""
Default cSerie   := ""
Default cStatus  := ""

   	//-- Atualiza o Status da Solicitacao de Coleta
	DT5->(DbSetOrder(4)) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
	If DT5->(MsSeek(xFilial('DT5') + cFilDoc + cDoc + cSerie ))
		RecLock('DT5',.F.)
		DT5_STATUS := cStatus
		DT5->(MsUnLock())
	EndIf

RestArea(aArea)

Return()

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - DF6LinePre - Validação na linha do Grid
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	lRet */
//-----------------------------------------------------------------------------------------------------------
Static Function DF6LinePre( oMdlGrdDF6, nLinha, cAcao, cCampo )

Local aArea			:= GetArea()
Local lRet			:= .T.
Local nOperation	:= oMdlGrdDF6:GetOperation()

If cAcao == "DELETE" .And. nOperation == MODEL_OPERATION_UPDATE .And. oMdlGrdDF6:GetValue( "DF6_QTDDIG", nLinha ) <> 0
	lRet := .F.
    Help( ,, 'HELP',, STR0012 , 1, 0) //Já existe um Documento informado para essa Solicitação de Coleta, portanto não será permitido a exclusão.
EndIf

RestArea( aArea )
Return( lRet )

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMSA461Vld - Validacao de Campos
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	lRet */
//-----------------------------------------------------------------------------------------------------------

Function TMSA461Vld()
Local lRet          := .T.
Local cCampo        := ReadVar()
Local cFilOri       := FwFldGet("DF6_FILORI")
Local cViagem       := FwFldGet("DF6_VIAGEM")
Local cFilDoc       := ''
Local cDoc          := ''
Local cSerie        := ''
Local aDocto        := {}
Local cAtivSai      := SuperGetMV('MV_ATIVSAI',,'')
Local cAtivSapa     := SuperGetMV('MV_ATVSAPA',,'')

Local oModel	    := FwModelActive()	// Recebe o Model Ativo
Local oMdlGrid	    := oModel:GetModel( "TMS461IDF6")
Local nLinha	    := oMdlGrid:GetLine()
Local lDuplicado    := .F.
Local aAreaDTW      := {}
Local lDMH 		    := AliasIndic("DMH")
Local oMdlGridDMH	:= Nil
Local nLinhaDMH	    := 0

If cCampo $ 'M->DF6_FILORI|M->DF6_VIAGEM'	
	If	lRet .And. M->DF6_FILORI <> cFilAnt
		lRet := .F.
	EndIf
	If lRet .And. !ExistChav("DF6",cFilOri+cViagem) .Or. !ExistCpo("DTQ",cFilOri+AllTrim(cViagem),2)
		lRet := .F. 
	EndIf

ElseIf cCampo == 'M->DF6_FILDOC' .Or. cCampo == 'M->DF6_DOC' .Or. cCampo == 'M->DF6_SERIE'
	//-- Se um dos campos estiverem vazios nao faz a validacao
	If (cCampo == 'M->DF6_FILDOC' .And. (Empty(oMdlGrid:GetValue( 'DF6_DOC'   , nLinha )) .Or. Empty(oMdlGrid:GetValue( 'DF6_SERIE', nLinha )) ) ) .Or. ;
		(cCampo == 'M->DF6_DOC'   .And. (Empty(oMdlGrid:GetValue( 'DF6_FILDOC', nLinha )) .Or. Empty(oMdlGrid:GetValue( 'DF6_SERIE', nLinha )) ) ) .Or. ;
		(cCampo == 'M->DF6_SERIE' .And. (Empty(oMdlGrid:GetValue( 'DF6_FILDOC', nLinha )) .Or. Empty(oMdlGrid:GetValue( 'DF6_DOC'  , nLinha )) ) )
		lRet := .T.
	Else
		//-- Verifica se a Filial Documento + Documento + Serie ja foram Informados
		If cCampo == 'M->DF6_FILDOC'
			cFilDoc := IF(!Empty(M->DF6_FILDOC), M->DF6_FILDOC, oMdlGrid:GetValue('DF6_FILDOC',nLinha))
			cDoc    := oMdlGrid:GetValue( 'DF6_DOC', nLinha ) 
			cSerie  := oMdlGrid:GetValue( 'DF6_SERIE', nLinha )
		ElseIf cCampo == 'M->DF6_DOC'
			cFilDoc := oMdlGrid:GetValue( 'DF6_FILDOC', nLinha ) 
			cDoc    := IF(!Empty(M->DF6_DOC), M->DF6_DOC, oMdlGrid:GetValue('DF6_DOC',nLinha))
			cSerie  := oMdlGrid:GetValue( 'DF6_SERIE', nLinha )
		ElseIf cCampo == 'M->DF6_SERIE'
			cFilDoc := oMdlGrid:GetValue( 'DF6_FILDOC', nLinha ) 
			cDoc    := oMdlGrid:GetValue( 'DF6_DOC', nLinha ) 
			cSerie  := IF(!Empty(M->DF6_SERIE), M->DF6_SERIE, oMdlGrid:GetValue('DF6_SERIE'))
		EndIf

		aDocto := TMSA461SelDoc( .T., cFilDoc, cDoc, cSerie, nLinha, @lDuplicado )
		If Len(aDocto) > 0
			lRet := .T.
        ElseIf lDuplicado
            Help( ,, 'HELP',, STR0013 , 1, 0) //Esta solicitação de coleta já foi informada.
            lRet := .F.
		Else
			Help('',1,'TMSA46102') //-- 'O Documento informado nao existe'
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == 'M->DF6_QTDENF'
	If M->DF6_QTDENF < oMdlGrid:GetValue('DF6_QTDDIG',nLinha)
		Help('',1,'TMSA46103') //-- 'A quantidade de Notas Fiscais informada e inferior ao numero de Notas Fiscais digitadas. Alteracao nao permitida.'
		lRet := .F.
	EndIf

ElseIf cCampo == 'M->DF6_DATCOL' .Or. cCampo == 'M->DF6_HORCOL'

    aAreaDTW := DTW->(GetArea())
	DTW->(DbSetOrder(4))
	If DTW->(MsSeek(xFilial('DTW') + cFilOri+cViagem + cAtivSai))
		If (cCampo == 'M->DF6_DATCOL' .And. oMdlGrid:GetValue( 'DF6_DATCOL', nLinha ) < DTW->DTW_DATREA) .Or.;
			(cCampo == 'M->DF6_HORCOL' .And. oMdlGrid:GetValue( 'DF6_DATCOL', nLinha ) == DTW->DTW_DATREA .And.  HoraToInt(Transform(oMdlGrid:GetValue( 'DF6_HORCOL', nLinha ),"@R 99:99")) < HoraToInt(Transform(DTW->DTW_HORREA,"@R 99:99")) )
            If !Empty(cAtivSapa)
                If DTW->(MsSeek(xFilial('DTW') + cFilOri+cViagem + cAtivSapa))
                    If (cCampo == 'M->DF6_DATCOL' .And. oMdlGrid:GetValue( 'DF6_DATCOL', nLinha ) < DTW->DTW_DATREA) .Or.;
                        (cCampo == 'M->DF6_HORCOL' .And. oMdlGrid:GetValue( 'DF6_DATCOL', nLinha ) == DTW->DTW_DATREA .And.  HoraToInt(Transform(oMdlGrid:GetValue( 'DF6_HORCOL', nLinha ),"@R 99:99")) < HoraToInt(Transform(DTW->DTW_HORREA,"@R 99:99")) )
                    	Help('',1,'TMSA46106') //"Hora invalida e/ou data invalida em relaçao a saida/chegada da viagem"
	            		lRet := .F.
                    EndIf
                EndIf           
            Else
            	Help('',1,'TMSA46106') //"Hora invalida e/ou data invalida em relaçao a saida/chegada da viagem"
	    		lRet := .F.
            EndIf
        EndIf
	EndIf

	If lRet .And. cCampo $ 'M->DF6_HORCOL'
		lRet := AtVldHora(oMdlGrid:GetValue( 'DF6_HORCOL', nLinha ))
	EndIf

    RestArea(aAreaDTW)

ElseIf cCampo == 'M->DF6_DATCHG' .Or. cCampo == 'M->DF6_HORCHG'

	aAreaDTW := DTW->(GetArea())
    DTW->(DbSetOrder(4))
	If DTW->(MsSeek(xFilial('DTW') + cFilOri+cViagem + cAtivSai))
		If (cCampo == 'M->DF6_DATCHG' .And. oMdlGrid:GetValue( 'DF6_DATCHG', nLinha ) < DTW->DTW_DATREA) .Or.;
			(cCampo == 'M->DF6_HORCHG' .And. oMdlGrid:GetValue( 'DF6_DATCHG', nLinha ) == DTW->DTW_DATREA .And.  HoraToInt(Transform(oMdlGrid:GetValue( 'DF6_HORCHG', nLinha ),"@R 99:99")) < HoraToInt(Transform(DTW->DTW_HORREA,"@R 99:99")) )
			If !Empty(cAtivSapa)
                If DTW->(MsSeek(xFilial('DTW') + cFilOri+cViagem + cAtivSapa))
                    If (cCampo == 'M->DF6_DATCHG' .And. oMdlGrid:GetValue( 'DF6_DATCHG', nLinha ) < DTW->DTW_DATREA) .Or.;
                        (cCampo == 'M->DF6_HORCHG' .And. oMdlGrid:GetValue( 'DF6_DATCHG', nLinha ) == DTW->DTW_DATREA .And.  HoraToInt(Transform(oMdlGrid:GetValue( 'DF6_HORCHG', nLinha ),"@R 99:99")) < HoraToInt(Transform(DTW->DTW_HORREA,"@R 99:99")) )
                        Help('',1,'TMSA46106') //"Hora invalida e/ou data invalida em relaçao a saida/chegada da viagem"
                        lRet := .F.
                    EndIf
                EndIf
            Else
                Help('',1,'TMSA46106') //"Hora invalida e/ou data invalida em relaçao a saida/chegada da viagem"
			    lRet := .F.
            Endif
        EndIf
	EndIf

	If lRet .And. cCampo $ 'M->DF6_HORCHG'
		lRet := AtVldHora(oMdlGrid:GetValue( 'DF6_HORCHG', nLinha ))
	EndIf

    RestArea(aAreaDTW)

ElseIf cCampo == 'M->DF6_DATSAI' .Or. cCampo == 'M->DF6_HORSAI'

    aAreaDTW := DTW->(GetArea())
	DTW->(DbSetOrder(4))
	If DTW->(MsSeek(xFilial('DTW') + cFilOri+cViagem + cAtivSai))
		If (cCampo == 'M->DF6_DATSAI' .And. oMdlGrid:GetValue( 'DF6_DATSAI', nLinha ) < DTW->DTW_DATREA) .Or.;
			(cCampo == 'M->DF6_HORSAI' .And. oMdlGrid:GetValue( 'DF6_DATSAI', nLinha ) == DTW->DTW_DATREA .And.  HoraToInt(Transform(oMdlGrid:GetValue( 'DF6_HORSAI', nLinha ),"@R 99:99")) < HoraToInt(Transform(DTW->DTW_HORREA,"@R 99:99")) )
			If !Empty(cAtivSapa)
                If DTW->(MsSeek(xFilial('DTW') + cFilOri+cViagem + cAtivSapa))
                    If (cCampo == 'M->DF6_DATSAI' .And. oMdlGrid:GetValue( 'DF6_DATSAI', nLinha ) < DTW->DTW_DATREA) .Or.;
                        (cCampo == 'M->DF6_HORSAI' .And. oMdlGrid:GetValue( 'DF6_DATSAI', nLinha ) == DTW->DTW_DATREA .And.  HoraToInt(Transform(oMdlGrid:GetValue( 'DF6_HORSAI', nLinha ),"@R 99:99")) < HoraToInt(Transform(DTW->DTW_HORREA,"@R 99:99")) )
                        Help('',1,'TMSA46106') //"Hora invalida e/ou data invalida em relaçao a saida/chegada da viagem"
                        lRet := .F.
                    EndIf
                EndIf
            Else
                Help('',1,'TMSA46106') //"Hora invalida e/ou data invalida em relaçao a saida/chegada da viagem"
                lRet := .F.
            EndIf
		EndIf
	EndIf

	If lRet .And. cCampo $ 'M->DF6_HORSAI'
		lRet := AtVldHora(M->DF6_HORSAI)
	EndIf                             

    RestArea(aAreaDTW)

ElseIf lDMH
    If cCampo == 'M->DMH_CHVNFE'
        oMdlGridDMH	 := oModel:GetModel( "DMHDET")  
        nLinhaDMH	 := oMdlGridDMH:GetLine()
        If Len(AllTrim(oMdlGridDMH:GetValue( 'DMH_CHVNFE'   , nLinhaDMH ))) < 44
            Help('',1,'TMSA46109') //"Chave NFe Inválida !!"
            lRet := .F.
        EndIf
    EndIf
    
Endif

Return( lRet )

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMSA461Doc - Funcao para retornar as Solic. de Coleta da Viagem
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	lRet */
//-----------------------------------------------------------------------------------------------------------
Function TMSA461Doc()
Local aCpos     := {}
Local aDoctos   := {}
Local cTitulo   := STR0011 //-- Solicitacoes de Coleta
Local nItem     := 0
Local lRet      := .F.
Local oDoctosBrw
Local oDoctosDlg
Local oBtnOK
Local oBtnCancel
Local oModel	:= FwModelActive()	// Recebe o Model Ativo
Local oMdlGrid	:= oModel:GetModel( "TMS461IDF6")
Local nLinha	:= oMdlGrid:GetLine()
Local oView     := FwViewActive()
Local aArea     := GetArea()
Local cFilOri   := FwFldGet("DF6_FILORI")
Local cViagem   := FwFldGet("DF6_VIAGEM")

If Empty(cFilOri) .Or. Empty(cViagem)
	Help('',1,'TMSA46104') //-- 'E necessario informar a viagem para realizacao da consulta'
	lRet := .F.
Else
    SaveInter()
	//-- Cabecalho
	AAdd( aCpos, RetTitle('DF6_FILDOC') )
	AAdd( aCpos, RetTitle('DF6_DOC') )
	AAdd( aCpos, RetTitle('DF6_SERIE') )

    //-- Itens
	aDoctos := TMSA461SelDoc()

	If Len(aDoctos) > 0

		DEFINE MSDIALOG oDoctosDlg TITLE cTitulo From 09,00 To 20,60 OF oMainWnd 
	
		oDoctosBrw := TWBrowse():New( 0.4,1,185,70,, aCpos,,oDoctosDlg,,,,,,,,,,,,.T. )
		oDoctosBrw:SetArray( aDoctos )
		oDoctosBrw:bLine := { || aDoctos[ oDoctosBrw:nAT ] }
		oDoctosBrw:bLDblClick := { || ( lRet := .T., nItem := oDoctosBrw:nAt, oDoctosDlg:End() ) }

		DEFINE SBUTTON oBtnOK FROM  4.0,200 TYPE  1 ACTION (lRet := .T., nItem := oDoctosBrw:nAt, oDoctosDlg:End()) ENABLE OF oDoctosDlg
		DEFINE SBUTTON oBtnCancel FROM 18.5,200 TYPE  2 ACTION (lRet := .F.,oDoctosDlg:End()) ENABLE OF oDoctosDlg
	
		ACTIVATE MSDIALOG oDoctosDlg CENTERED
	Else
		Help('',1,'TMSA46105') //-- 'Nao existem documentos para selecao nesta viagem'
		lRet := .F.
	EndIf
	RestInter()
EndIf

If lRet 
    VAR_IXB := aDoctos[nItem,1]
	oMdlGrid:GoLine(nLinha)	
	oMdlGrid:LoadValue( 'DF6_FILDOC', aDoctos[nItem,1])
    oMdlGrid:LoadValue( 'DF6_DOC'   , aDoctos[nItem,2])
    oMdlGrid:LoadValue( 'DF6_SERIE' , aDoctos[nItem,3])
    oView:Refresh()
EndIf

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMSA461SelDoc - Funcao para Validar as Solic. de coleta da viagem 
@author  	Jefferson Tomaz
@version 	P12 12.1.27
@since 		26/09/2019
@return 	aRet */
//-----------------------------------------------------------------------------------------------------------
Static Function TMSA461SelDoc( lValida, cFilDoc, cDoc, cSerie, nLinha, lDuplicado )
Local aArea         := GetArea()
Local cQuery        := ''
Local cAliasQry     := ''
Local aRet          := {}
Local cFilOri       := FwFldGet("DF6_FILORI")
Local cViagem       := FwFldGet("DF6_VIAGEM")
Local oModel	    := FwModelActive()
Local oMdlGrid	    := oModel:GetModel("TMS461IDF6")
Local nI            := 0
Local aDocs         := {}
Default lValida     := .F.
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""
Default nLinha      := 0
Default lDuplicado  := .F.

If !lValida
    For nI := 1 To oMdlGrid:Length()
        oMdlGrid:GoLine(nI)
        If !oMdlGrid:IsDeleted(nI) .AND. !Empty(oMdlGrid:GetValue('DF6_FILDOC', nI))
            aAdd(aDocs, {oMdlGrid:GetValue('DF6_FILDOC', nI) + oMdlGrid:GetValue('DF6_DOC', nI) + oMdlGrid:GetValue('DF6_SERIE', nI)})
        EndIf
    Next
Else
    For nI := 1 To oMdlGrid:Length()
        oMdlGrid:GoLine(nI)
        If !oMdlGrid:IsDeleted(nI) .AND.; 
            nI <> nLinha .AND.;
            oMdlGrid:GetValue('DF6_FILDOC', nI) + oMdlGrid:GetValue('DF6_DOC', nI) + oMdlGrid:GetValue('DF6_SERIE', nI) == cFilDoc + cDoc + cSerie
                lDuplicado := .T.
        EndIf
    Next
EndIf

If !lDuplicado
    cQuery := "SELECT DUD.DUD_FILORI,DUD.DUD_VIAGEM,DUD.DUD_FILDOC,DUD.DUD_DOC,DUD.DUD_SERIE,DT5.DT5_STATUS "
    cQuery += "FROM " + RetSQLName('DUD') + " DUD, " + RetSQLName('DT5') + " DT5 "
    cQuery += "WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
    cQuery += "DUD.DUD_FILORI = '" + cFilOri + "' AND "
    cQuery += "DUD.DUD_VIAGEM = '" + cViagem + "' AND "

    If lValida
        cQuery += "DUD.DUD_FILDOC = '" + cFilDoc + "' AND "
        cQuery += "DUD.DUD_DOC = '" + cDoc + "' AND "
        cQuery += "DUD.DUD_SERIE = '" + cSerie + "' AND "
    EndIf

    cQuery += "DT5.DT5_FILIAL = '" + xFilial("DT5") + "' AND "
    cQuery += "DT5.DT5_FILDOC = DUD.DUD_FILDOC AND "
    cQuery += "DT5.DT5_DOC = DUD.DUD_DOC AND "
    cQuery += "DT5.DT5_SERIE = DUD.DUD_SERIE AND "
    cQuery += "DT5.DT5_STATUS IN ('2','3') AND "
    cQuery += "DUD.D_E_L_E_T_ = '' AND DT5.D_E_L_E_T_ = ''"

    cAliasQry := GetNextAlias()
    cQuery    := ChangeQuery(cQuery)	
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

    While !(cAliasQry)->(EoF())
        If aScan(aDocs, {|x| x[1] == (cAliasQry)->DUD_FILDOC + (cAliasQry)->DUD_DOC + (cAliasQry)->DUD_SERIE}) == 0
            AAdd(aRet,{	(cAliasQry)->DUD_FILDOC,;
                        (cAliasQry)->DUD_DOC,;
                        (cAliasQry)->DUD_SERIE } )
        EndIf
        (cAliasQry)->(DbSkip())
    EndDo
    (cAliasQry)->(DbCloseArea())

    RestArea(aArea)
EndIf

Return aRet

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMA461ChkD - Verifica se pode processar a exclusao 
@author  	Fabio Sampaio
@version 	1.0
@since 		03/05/2021
@return 	lRet */
//-----------------------------------------------------------------------------------------------------------
Static Function TMA461ChkD(oMdl)
Local lRet      := .T.
Local nCntFor   := 0
Local aArea     := GetArea()
Local aAreaDT5  := DT5->(GetArea())
Local oMdlDF6   := oMdl:GetModel('TMS461IDF6')
Local nOperation := oMdl:GetOperation()

If nOperation == MODEL_OPERATION_DELETE
    For nCntFor := 1 To oMdlDF6:Length()
        oMdlDF6:GoLine(nCntFor)
        DT5->(DbSetOrder(4))
        If DT5->(MsSeek(xFilial('DT5') + oMdlDF6:GetValue("DF6_FILDOC") + oMdlDF6:GetValue("DF6_DOC") + oMdlDF6:GetValue("DF6_SERIE")))
            If DT5->DT5_STATUS == StrZero(5,Len(DT5->DT5_STATUS)) //-- Documento Informado            			
                lRet := .F.
                Help('',1,'TMSA46101') //-- 'Exclusao nao permitida, pois a Conferencia de Coleta possui Documento Informado'
                Exit
            EndIf
        EndIf
    Next nCntFor	
EndIf

RestArea(aArea)
RestArea(aAreaDT5)

Return lRet


//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMA461CBar - Código de Barra para inserção de NFe
@author  	Felipe Barbiere
@version 	1.0
@since 		04/05/2021
@return 	Nil */
//-----------------------------------------------------------------------------------------------------------
Static Function TMA461CBar(oModel)
Local cCodbar := Space(TamSX3("DTC_NFEID")[1])
Local oMdlDF6 := oModel:GetModel( "DMHDET" )
Local oGetBar 
Local oDlgBar

If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or.  oModel:GetOperation() == MODEL_OPERATION_INSERT
        DEFINE DIALOG oDlgBar FROM 0,0 TO 120,400 TITLE STR0014 Of oMainWnd PIXEL       //Leitura do Codigo de Barras

        @ 16,10 SAY STR0015 Of oDlgBar PIXEL SIZE 100,10 //--"Informe o código de barras"
        @ 26,10 MSGET oGetBar VAR cCodbar SIZE 140,10 Picture '@!' VALID (oDlgBar:End()) PIXEL
        @ 25,11 MSGET oGetBar VAR cCodbar SIZE 1,1 //-- campo para mudança de foco e execução do valid

        ACTIVATE DIALOG oDlgBar CENTERED VALID(Iif(oDlgBar:WindowState() == 2,(cCodbar == '',.T.),.T.))
        
        If !Empty(cCodbar)
            If !(oMdlDF6:Length() == 1 .And. Empty(oMdlDF6:GetValue("DMH_CHVNFE")))
                oMdlDF6:AddLine()
            EndIf
            oMdlDF6:SetValue("DMH_CHVNFE", cCodbar)
            TMA461CBar(oModel)
        EndIf
EndIf

Return


//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMA461PrcNF - Processamento da busca Notas Fiscais Eletrônicas na SEFAZ
@author  	Felipe Barbiere
@version 	1.0
@since 		13/05/2021
@return 	Nil */
//-----------------------------------------------------------------------------------------------------------
Function TMA461Proc()
    FwMsgRun( , {|| TMA461BNFe() } , STR0018 , STR0017 ) //"Processando"  /  "Realizando comunicação com a SEFAZ"
Return

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMA461BNFe - Busca Notas Fiscais Eletrônicas na SEFAZ
@author  	Felipe Barbiere
@version 	1.0
@since 		13/05/2021
@return 	Nil */
//-----------------------------------------------------------------------------------------------------------
Static Function  TMA461BNFe()
Local aNFs      := {}
Local oNFSEFAZ
Local lDMH 		:= AliasIndic("DMH")

If FindFunction('TMSAC17') .And. lDMH
    cChaveDF6 := DF6->DF6_FILORI+DF6->DF6_VIAGEM+DF6->DF6_SEQUEN
    DMH->(DbSetOrder(1)) //DMH_FILIAL+DMH_FILORI+DMH_VIAGEM+DMH_SEQUEN
    DMH->(DBSeek(xFilial('DMH')+cChaveDF6))
    While DMH->(!EOF()) .And. DMH->(DMH_FILIAL+DMH_FILORI+DMH_VIAGEM+DMH_SEQUEN) == xFilial("DMH") + cChaveDF6
		If !Empty(DMH->DMH_CHVNFE) .And. DMH->DMH_STATUS == "1" //Pendente
            AAdd(aNFs, DMH->DMH_CHVNFE)
        EndIf
	    DMH->(dBSkip())
	EndDo

   If !Empty(aNFs)
        oNFSEFAZ := TMSBCANFESEFAZ():New()
        aResult  := oNFSEFAZ:GetXMLNFe(aNFs)
        If !Empty(aResult)
            oNFSEFAZ:UpdRetSEFAZ(aResult)
        EndIf
    EndIf     
EndIf

Return 

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - ChvNFeLock - When do campo DMH_CHVNFE
@author  	Felipe Barbiere
@version 	1.0
@since 		13/05/2021
@return 	Nil */
//-----------------------------------------------------------------------------------------------------------
Static Function ChvNFeLock(oModel)
Local lRet     := .T.
Local oMdlDF6  := oModel:GetModel( "DMHDET" )

    If oMdlDF6:GetValue('DMH_STATUS') <> '1'
        lRet := .F.
    EndIf

Return (lRet)
