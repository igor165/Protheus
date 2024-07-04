#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fwbrowse.ch"
#include "teca934.ch"

Static oMod930 := Nil
Static cItem   := ""
Static lEstLote := .F.
Static lIncLote := .F.

/*/{Protheus.doc} TECA934
@description      Rotina de faturamento antecipado.
@author           josimar.assuncao
@since                 12.04.2017
/*/   
Function TECA934()
Local oMBrowse := FWmBrowse():New()

oMBrowse:SetAlias("ABX")
oMBrowse:SetDescription(STR0001) // "Faturamento Antecipado"
oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
@description      Menu para a rotina de faturamento antecipado.
@author           josimar.assuncao
@since                  12.04.2017
@return           array com as rotinas para execução a partir do browse.
/*/
Static Function MenuDef()
Local aRotina := {}
Local aLote := {}

ADD OPTION aLote TITLE STR0002 ACTION "At934ILote()" OPERATION 3 ACCESS 0   // "Incluir"
ADD OPTION aLote TITLE STR0003 ACTION "At934ELote()" OPERATION 5 ACCESS 0   // "Estornar"

ADD OPTION aRotina TITLE STR0004 ACTION "PesqBrw" OPERATION 1 ACCESS 0   // "Pesquisar"
ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.TECA934" OPERATION 3 ACCESS 0   // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA934" OPERATION 2 ACCESS 0   // "Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA934" OPERATION 5 ACCESS 0   // "Estornar"

ADD OPTION aRotina TITLE STR0006 ACTION aLote OPERATION 3 ACCESS 0   // "Op. Em Lotes"

Return aRotina

/*/{Protheus.doc} ModelDef
@description      Construção do modelo de dados da rotina.
@author           josimar.assuncao
@since                  12.04.2017
@return           Objeto MpFormFormel, modelo de dados da rotina de faturamento antecipado.
/*/
Static Function ModelDef()
Local oModel            := Nil
Local aFldsCab          := { "ABX_CODIGO", "ABX_CONTRT", "ABX_CONREV", "ABX_MESANO", "ABX_OPERAC", "ABX_RECORR"}
Local oStrCab           := FWFormStruct( 1, "ABX" )
Local oStrGrd1          := FWFormStruct( 1, "ABX" )
Local oStrGrd2          := FWFormStruct( 1, "ABX" )
Local bNoInit           := FwBuildFeature( STRUCT_FEATURE_INIPAD, "" )
Local aAux              := {}

// Ajusta os campos na estrutura  removendo os desnecessários
EdtFlds( @oStrCab, aFldsCab, "1", .T./*lIsModel*/ )

oStrCab:AddField(STR0008,STR0008,"ABX_MESANO2","C",7,0,Nil,Nil,Nil,Nil,{||At934IniM2()},.F.,.T.,.T.)  // "Compet. Apurar" ### "Compet. Apurar"


// Adiciona a validação para o campo de contrato 
oStrCab:SetProperty( "ABX_CONTRT", MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld| At934IsFAnt(oMdlVld) } )

// Adiciona a validação para o campo de competência da medição
oStrCab:SetProperty( "ABX_MESANO", MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld| At934CtMd(oMdlVld) } )

// Adiciona o campo para receber o recno da abx no grid da competência apurada
oStrGrd2:AddField( "Recno", "Recno", "ABX_REC", "N", 12, 0, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T. )

// Remove o inicializador por GetSxeNum das linhas
oStrGrd1:SetProperty("ABX_CODIGO", MODEL_FIELD_INIT, bNoInit )
oStrGrd2:SetProperty("ABX_CODIGO", MODEL_FIELD_INIT, bNoInit )

// Cria gatilho para preencher o campo de revisão do contrato
aAux := FwStruTrigger( "ABX_CONTRT", "ABX_CONREV", "At934CtRev()", .F. )
oStrCab:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

// Cria gatilho para carregar as informações de medição e apuração conforme a opção selecionada de operação
aAux := FwStruTrigger( "ABX_CONTRT", "ABX_CONTRT", "At934Load()", .F. )
oStrCab:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "ABX_CONREV", "ABX_CONREV", "At934Load()", .F. )
oStrCab:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "ABX_MESANO", "ABX_MESANO", "At934Load()", .F. )
oStrCab:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

// Constrói todos os modelos de dados para a rotina
oModel := MPFormModel():New( "TECA934", /*bPreValid*/, {|oModel| At934Vld(oModel)}, {|oModel| At934Commit(oModel)}/*bCommit*/, {|oModel| At934Cancel(oModel) }/*bCancel*/ )
oModel:AddFields( "ABXMASTER", /*cOwner*/, oStrCab)

oModel:AddGrid( "ABX_MESATUAL", "ABXMASTER", oStrGrd1, /*bPre*/, /*bPos*/, /*bPreL*/, /*bPosL*/, /*bLoad*/)
oModel:SetRelation("ABX_MESATUAL", { {"ABX_FILIAL","xFilial('ABX')"}, {"ABX_CODIGO" ,"ABX_CODIGO"}, {"ABX_OPERAC" ,"ABX_OPERAC"} }, ABX->(IndexKey(2)))

// A carga dos dados deste grid só é feita manualmente, pois em um estorno não deveria excluir estes registros
oModel:AddGrid( "ABX_MESANTERIOR", "ABXMASTER", oStrGrd2, /*bPre*/, /*bPos*/, /*bPreL*/, /*bPosL*/, {|oMdlGrd| At934ViAnt(oMdlGrd) }/*bLoad*/)

oModel:SetPrimaryKey({})

//Bloqueia os campos atraves do When
oStrGrd1:SetProperty("*",MODEL_FIELD_WHEN,{|| .F. })

oModel:GetModel("ABX_MESANTERIOR"):SetNoInsertLine(.T.)
oModel:GetModel("ABX_MESANTERIOR"):SetNoUpdateLine(.T.)
oModel:GetModel("ABX_MESANTERIOR"):SetOptional(.T.)
oModel:GetModel("ABX_MESANTERIOR"):SetOnlyQuery(.T.)

oModel:GetModel("ABX_MESATUAL"):SetNoInsertLine(.T.)
oModel:GetModel("ABX_MESATUAL"):SetOptional(.T.)

oModel:SetDescription(STR0001)  // "Faturamento Antecipado"
oModel:SetVldActivate({|oModel| At934VldAct( oModel ) })
oModel:SetActivate({|oModel| InitDados( oModel ) })

Return oModel

/*/{Protheus.doc} EdtFlds
@description      Realiza a edição dos campos em uma estrutura mantendo ou removendo os campos informados.
@author           josimar.assuncao
@since                  12.04.2017
@params           oStr, objeto FwFormStruct, objeto que será alvo da operação.
@params           aCpos, array, lista com os campos para a operação.
@params           cAcao, caracter, indica se deverá manter somente os campos da lista (1) ou se deverá remover os campos da lista (2).
/*/
Static Function EdtFlds( oStr, aCpos, cAcao, lIsModel )
Local nX := 1
Local aTodosCampos := {}
Local nIdCampo := ( If( lIsModel, MODEL_FIELD_IDFIELD, MVC_VIEW_IDFIELD ) )

// mantem os campos da lista, removendo todos os demais campos
If cAcao == "1"
      // faz aclone para não ter problema ao remover os itens da estrutura
      aTodosCampos := aClone( oStr:GetFields() )

      For nX := 1 To Len(aTodosCampos)
            // caso não encontre na lista recebida por parâmetro, remove da estrutura
            If ( aScan( aCpos, {|x| x == Alltrim(aTodosCampos[nX, nIdCampo]) } ) == 0 )
                  oStr:RemoveField( aTodosCampos[nX, nIdCampo] )
            EndIf
      Next nX

// remove os campos informados na lista
ElseIf cAcao == "2"
      For nX := 1 To Len(aCpos)
            oStr:RemoveField( aCpos[nX, nIdCampo] )
      Next nX
EndIf

Return 

/*/{Protheus.doc} ViewDef
@description      Construção da view da rotina.
@author           josimar.assuncao
@since                  12.04.2017
@return           Objeto FwFormView, modelo de dados da rotina de faturamento antecipado.
/*/
Static Function ViewDef()
Local oView             := FWFormView():New()
Local aFldsCab          := { "ABX_CODIGO", "ABX_CONTRT", "ABX_CONREV", "ABX_MESANO", "ABX_OPERAC", "ABX_RECORR"}
Local oStrCab           := FWFormStruct( 2, "ABX" )
Local oStrGrd1          := FWFormStruct( 2, "ABX" ,{|cCampo| !AllTrim(cCampo) $ "ABX_OPERAC|ABX_CODIGO|ABX_RECORR|ABX_PEDIDO|ABX_PEDITE|ABX_VLCOMP"} )
Local oStrGrd2          := FWFormStruct( 2, "ABX" ,{|cCampo| !AllTrim(cCampo) $ "ABX_OPERAC|ABX_CODIGO|ABX_RECORR"} )

// Ajusta os campos na estrutura  removendo os desnecessários
EdtFlds( @oStrCab, aFldsCab, "1", .F./*lIsModel*/ )

oStrCab:AddField( "ABX_MESANO2", Soma1( oStrCab:GetProperty("ABX_MESANO", MVC_VIEW_ORDEM ) ), STR0029, STR0029,Nil,"C","@R 99/9999",NIL,"",.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL) // "Compet. Apurar" ### "Compet. Apurar"

oView:SetModel( FwLoadModel("TECA934") )

// Cria e associa as quebras por grupos no field
oStrCab:AddGroup( 'GROUP1', STR0009, '', 2)  // "Tipo faturamento"
oStrCab:AddGroup( 'GROUP2', STR0010, '', 2)  // "Parâmetros"

oStrCab:SetProperty( '*', MVC_VIEW_GROUP_NUMBER, 'GROUP2')
oStrCab:SetProperty( 'ABX_CODIGO', MVC_VIEW_GROUP_NUMBER, 'GROUP1')
oStrCab:SetProperty( 'ABX_OPERAC', MVC_VIEW_GROUP_NUMBER, 'GROUP1')

// Bloqueia o campo de revisão para alteração direta
oStrCab:SetProperty( 'ABX_CONREV', MVC_VIEW_CANCHANGE, .F.)

oView:AddField( "VIEW_MASTER", oStrCab, "ABXMASTER")
oView:AddGrid( "VIEW_GRID1", oStrGrd1, "ABX_MESATUAL")
oView:AddGrid( "VIEW_GRID2", oStrGrd2, "ABX_MESANTERIOR")

// Adiciona as visões na tela
oView:CreateHorizontalBox( "TOP",  35 )
oView:CreateHorizontalBox( "DOWN", 65 )

// Cria as pastas e abas para os dados de Competência Atual e Competência Anterior
oView:CreateFolder( "ABAS", "DOWN" )
oView:AddSheet( "ABAS", "ABA01", STR0011)  // "Competência Medir"
oView:AddSheet( "ABAS", "ABA02", STR0012)  // "Competência Apurar"

oView:CreateHorizontalBox( "VIEWABA01", 100,,, "ABAS", "ABA01")
oView:CreateHorizontalBox( "VIEWABA02", 100,,, "ABAS", "ABA02")

// Associa as views com os modelos
oView:SetOwnerView( "VIEW_MASTER", "TOP")
oView:SetOwnerView( "VIEW_GRID1", "VIEWABA01")
oView:SetOwnerView( "VIEW_GRID2", "VIEWABA02")

oView:SetDescription( STR0001 )  // "Faturamento Antecipado"
oView:SetCloseOnOk( {|| .T.} )

oView:AddUserButton(STR0007 , "VISAPU", {|oModel| At934Vi930()}, , , {MODEL_OPERATION_INSERT,MODEL_OPERATION_VIEW})	//"Visualizar Apuração"

oView:SetFieldAction( 'ABX_OPERAC', { |oView, cIDView, cField, xValue| At934ReLoad(oView) } )

Return oView

/*/{Protheus.doc} At934Limpa
@description      Função para limpar as informações pois foi trocado o tipo da apuração.
@author           josimar.assuncao
@since                  13.04.2017
/*/
Function At934Limpa()
Local oModel            := FwModelActive()
Local oMdlCab           := oModel:GetModel("ABXMASTER")
Local cContrato   := oMdlCab:GetValue("ABX_CONTRT")
Local cRevisao          := oMdlCab:GetValue("ABX_CONREV")
Local cCompetencia      := oMdlCab:GetValue("ABX_MESANO")

Return

/*/{Protheus.doc} At934Load
@description      Função para carregar as informações de medições e apurações.
@author           josimar.assuncao
@since                  13.04.2017
/*/
Function At934Load()
Local oModel            := FwModelActive()
Local oMdlCab           := oModel:GetModel("ABXMASTER")
Local oMdlGrid          := oModel:GetModel("ABX_MESATUAL")
Local oMdlGridAnt            := oModel:GetModel("ABX_MESANTERIOR")

Local cContrato   := oMdlCab:GetValue("ABX_CONTRT")
Local cRevisao          := oMdlCab:GetValue("ABX_CONREV")
Local cCompAtu          := oMdlCab:GetValue("ABX_MESANO")
Local cCompAnt          := oMdlCab:GetValue("ABX_MESANO2")
Local cOperac           := oMdlCab:GetValue("ABX_OPERAC")
Local nX                := 1 
Local aLinMed           := {}
Local nNewLine          := 0
Local aArea             := GetArea()

If !Empty(cContrato) .And. ( !Empty(cCompAtu) .Or. !Empty(cCompAnt) )
      At934ClGrd(oMdlGrid)         
      At934ClGrd(oMdlGridAnt)

      // carrega as informações da competência anterior
      If cOperac == "3" .Or. cOperac == "2"
            If IsBlind()
                  At934CgAnt( oModel, cContrato, cRevisao, cCompAnt )
            Else
                  Processa({|| At934CgAnt( oModel, cContrato, cRevisao, cCompAnt ), STR0014 })  // "Apurando a competência..."
            EndIf
      EndIf

      // carrega somente as informações da competência atual
      If cOperac == "1" .Or. cOperac == "2"
            If IsBlind()
                  aLinMed := At934CgAtu( oModel, cContrato, cRevisao, cCompAtu, cCompAnt )
            Else
                  Processa({|| aLinMed := At934CgAtu( oModel, cContrato, cRevisao, cCompAtu, cCompAnt ), STR0013 })  // "Buscando dados competência para medir..."
            EndIf
      EndIf
EndIf

TFJ->( DbSetOrder( 5 ) )  // TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
If TFJ->( DbSeek( xFilial("TFJ")+cContrato+cRevisao ) )
      oMdlCab:LoadValue('ABX_RECORR',TFJ->TFJ_CNTREC == '1')     
EndIf 
      
RestArea(aArea)
Return 

/*/{Protheus.doc} At934VldAct
@description      Função para validar a ativação de um modelo de dados.
@author           josimar.assuncao
@since                  13.04.2017
@return           Lógico, indica se o objeto pode ser inicializado ou não.
@param                  oModel, objeto MpFormModel, modelo completo da rotina.
/*/
Static Function At934VldAct( oModel )
Local lRet			:= .T.

If oModel:GetOperation()==MODEL_OPERATION_UPDATE
	lRet := .F.
	Help( "", 1, "AT934NOUPDATE", , STR0015, 1, 0,,,,,,;  // "Não é permitido realizar a alteração de dados na rotina."
									{STR0016})  // "Estorne o processo e realize-o novamente."
Elseif oModel:GetOperation()==MODEL_OPERATION_DELETE
	If ABX->ABX_RECORR
		If !A93aUltMed(ABX->ABX_CONTRT, ABX->ABX_CONREV, ABX->ABX_MESANO)
			lRet := .F.
			Help( "", 1, "At934VldAct", , STR0057, 1, 0,,,,,,;  // "Estorno de medição de contrato recorrente será permitido na ordem inversa que foram incluídas, a partir da última medição."
											{STR0058})  // "Realize o estorno da última medição."
		Endif
	Endif
EndIf

Return lRet

/*/{Protheus.doc} InitDados
@description      Função para operações tão logo o modelo termine de ser ativado e antes de ser apresentado na interface.
@author           josimar.assuncao
@since                  13.04.2017
@param                  oModel, objeto MpFormModel, modelo completo da rotina.
/*/
Static Function InitDados( oModel )
Local oMdlCab           := oModel:GetModel("ABXMASTER")
Local oMdlGrdApu := oModel:GetModel("ABX_MESANTERIOR")
Local cCodTFV           := ""

// Carrega os dados da apuração para a exclusão da apuração
If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. ;
      oMdlCab:GetValue("ABX_OPERAC") $ "2/3" // Operação preenchida com a apuração

      cCodTFV := oMdlGrdApu:GetValue("ABX_CODTFV")

      DbSelectArea("TFV")
      TFV->( DbSetOrder( 1 ) ) // TFV_FILIAL + TFV_CODIGO

      If !Empty(cCodTFV) .And. ; // Código não esteja vazio
            TFV->( DbSeek( xFilial("TFV")+cCodTFV ) )  // Consiga posicionar na apuração
            // Instancia e carrega os dados para a apuração
            oMod930 := FwLoadModel("TECA930")
            oMod930:SetOperation( MODEL_OPERATION_DELETE )
            oMod930:Activate()
      EndIf
EndIf

Return

/*/{Protheus.doc} At934CtRev
@description      Captura a revisão recente de um determinando contrato.
@author           josimar.assuncao
@since                  13.04.2017
@return           Caracter, revisão mais recente e que pode receber a medição.
/*/
Function At934CtRev()
Local oModel            := FwModelActive()
Local cContrato   := oModel:GetModel("ABXMASTER"):GetValue("ABX_CONTRT")
Local cRevisao          := Posicione("CN9",7,xFilial("CN9")+cContrato+"05","CN9_REVISA")
Return cRevisao

/*/{Protheus.doc} At934IsFAnt
@description      Valida se o número de contrato é valido.
@author           josimar.assuncao
@since                  13.04.2017
@return           Lógico, determinado se o conteúdo é válido ou não.
/*/
Function At934IsFAnt( oMdlCab )
Local lRet              := .T.
Local cContrato   := oMdlCab:GetValue("ABX_CONTRT")
Local cRevisao          := ""


If !Empty(cContrato)
      cRevisao := Posicione("CN9",7,xFilial("CN9")+cContrato+"05","CN9_REVISA")

      DbSelectArea("TFJ")
      TFJ->( DbSetOrder( 5 ) )  // TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
      If TFJ->( DbSeek( xFilial("TFJ")+cContrato+cRevisao ) )
            If TFJ->TFJ_ANTECI <> "1"
                  lRet := .F.
                  Help( "", 1, "AT934FATANT", , i18n(STR0017,{ TFJ->TFJ_CODIGO }), 1, 0,,,,,,;  // "O orçamento de serviços [#1] não foi configurado para receber faturamento antecipado."
                             {STR0018})  // "Selecione um contrato/orçamento que permita o faturamento antecipado."
            EndIf 
      Else
            lRet := .F.
            Help( "", 1, "AT934NOTFJ", , i18n(STR0019,{ cContrato, cRevisao }), 1, 0,,,,,,;  // "Não foi encontrado orçamento de serviços para este contrato [#1] e revisão [#2]."
                        {STR0020} )  // "Selecione um contrato que esteja vinculado a orçamento de serviços."
      EndIf
EndIf

Return lRet

/*/{Protheus.doc} At934CtMd
@description      Valida se a competência informada existe para o contrato.
@author           josimar.assuncao
@since                  13.04.2017
@return           Lógico, determinado se o conteúdo é válido ou não.
/*/
Function At934CtMd( oMdlCab )
Local lRet              := .F.
Local cCompetencia      := oMdlCab:GetValue("ABX_MESANO")
Local cContrato   		:= oMdlCab:GetValue("ABX_CONTRT")
Local cRevisao          := oMdlCab:GetValue("ABX_CONREV")
Local cOper             := oMdlCab:GetValue("ABX_OPERAC")
Local cTmpQry           := ""
Local lRecorr           := oMdlCab:GetValue("ABX_RECORR")
Local nAno          	:= 0
Local nMes          	:= 0
Local dCompet       	:= 0
Local cCompQry        	:= ""

If !Empty(cCompetencia)
      If Empty(cContrato)
            lRet := .F.
            Help( "", 1, "AT934NOCTR", , i18n(STR0021), 1, 0,,,,,,;  // "A competência só pode ser avaliada após o preenchimento do contrato."
                        {STR0022} )  // "Preencha o contrato antes da competência."
      Else
            // Valida a existência do contrato                  
            cTmpQry := GetNextAlias() 
            If !lRecorr
                  BeginSQL Alias cTmpQry
                        SELECT CNF_NUMERO
                        FROM %Table:CNF% CNF
                        WHERE CNF_FILIAL = %xFilial:CNF%
                             AND CNF_CONTRA = %Exp:cContrato%
                             AND CNF_REVISA = %Exp:cRevisao%
                             AND CNF_COMPET = %Exp:cCompetencia%
                             AND CNF.%NotDel%
                  EndSQL
            Else
                  dCompet := CTOD("01/"+cCompetencia) 
                        
                  nAno := Year(dCompet)
                  nMes := Month(dCompet)
                        
                  cCompQry := Alltrim(Str(nAno) + StrZero(nMes,2))
                        
                  //-- Não é só apaurar
                  If cOper == '1'
                        
                        BeginSQL Alias cTmpQry
                             SELECT E1_NUM
                             FROM %Table:SE1% SE1
                             WHERE E1_FILIAL = %xFilial:SE1%
                                   AND E1_MDCONTR = %Exp:cContrato%
                                   AND E1_MDREVIS = %Exp:cRevisao%
                                   AND E1_TIPO   = 'PR'
                                   AND SUBSTRING(E1_VENCTO,1,6) = %Exp:cCompQry%
                                   AND SE1.%NotDel%
                        EndSQL
                  
                  Else
                        
                        
                        BeginSQL Alias cTmpQry
                             SELECT 1
                             FROM %Table:SE1% SE1
                             WHERE E1_FILIAL = %xFilial:SE1%
                                   AND E1_MDCONTR = %Exp:cContrato%
                                   AND E1_MDREVIS = %Exp:cRevisao%
                                   AND E1_TIPO   = 'PR'
                                   AND SUBSTRING(E1_VENCTO,1,6) = %Exp:cCompQry%
                                   AND SE1.%NotDel%
                                   
                             UNION
                             
                             SELECT 1
                             FROM %Table:ABX% ABX
                             WHERE ABX_FILIAL = %xFilial:ABX%
                                   AND ABX_CONTRT = %Exp:cContrato%
                                   AND ABX_CONREV = %Exp:cRevisao%
                                   AND ABX_MESANO = %Exp:cCompetencia%
                                   AND ABX_CODPLA <> ''
                                   AND ABX_CODTFV = ' '
                                   AND ABX.%NotDel%
                        EndSQL
                  EndIf 
            EndIf       

            If (cTmpQry)->(!EOF())
                  lRet := .T.
            Else
                  lRet := .F.
                  Help( "", 1, "AT934NOCOMPET", , i18n(STR0023,{ cCompetencia, cContrato }), 1, 0,,,,,,;  // "A competência informada [#1] não foi encontrada no contrato [#2]."
                             {STR0024} )  // "Selecione uma competência existente no contrato."
            EndIf

            (cTmpQry)->( DbCloseArea() )
      EndIf
EndIf

If lRet
      // Preenche o campo da competência anterior
      At934Mes2( oMdlCab )
EndIf

Return lRet

/*/{Protheus.doc} At934CgAtu
@description      Carrega os dados da competência atual.
@author           josimar.assuncao
@since                  17.04.2017
@param                  oModel, objeto FwFormModel, modelo principal da rotina.
@param                  cContrato, caracter, contrato alvo para a carga das planilhas e informações da competência.
@param                  cRevisao, caracter, revisão do contrato para a medição.
@param                  cCompetencia, caracter, parcela/competência que será cobrada.
@param 			cCompetencia Anterior, caracter, parcela/competência anterior que será cobrada.
/*/
Static Function At934CgAtu( oModel, cContrato, cRevisao, cCompetencia, cCompAnt )
Local oMdlCab           := oModel:GetModel("ABXMASTER")
Local oMdlGrd           := oModel:GetModel("ABX_MESATUAL")
Local oMdlGrdAnt        := oModel:GetModel("ABX_MESANTERIOR")
Local cTmpQry           := GetNextAlias()
Local lOk               := .T.
Local nLinAtual   		:= 0
Local cOperac           := ""
Local cCodFatAnt 		:= ""
Local aRet              := {}
Local lRecorr           := oMdlCab:GetValue("ABX_RECORR")
Local dCompet           := 0
Local cCompetQry    	:= ""
Local nValorApur		:= 0
Local oStrABXMdl		:= oMdlGrd:GetStruct()
Local lParamMed   		:= SuperGetMv("MV_GSFAMEN",,"0") == "1"

//-- TITPRO --//
If !lRecorr
      BeginSQL Alias cTmpQry
            SELECT CNA_NUMERO, CNF_NUMERO, CNF_VLPREV VLRMED, CNF_VLREAL
            FROM %Table:CNA% CNA
                  INNER JOIN %Table:CNF% CNF ON CNF_FILIAL = %xFilial:CNF%
                                               AND CNF_CONTRA = CNA_CONTRA
                                               AND CNF_REVISA = CNA_REVISA
                                               AND CNF_NUMPLA = CNA_NUMERO
                                               AND CNF_COMPET = %Exp:cCompetencia%
                                               AND CNF.%NotDel%
            WHERE CNA_FILIAL = %xFilial:CNA%
                  AND CNA_CONTRA = %Exp:cContrato%
                  AND CNA_REVISA = %Exp:cRevisao%
                  AND CNF_VLREAL = 0
                  AND CNA.%NotDel%
                  
      EndSQL
Else
      
      dCompet := CTOD("01/"+cCompetencia) 
                  
      nAno := Year(dCompet)
      nMes := Month(dCompet)
                  
      cCompetQry := Alltrim(Str(nAno) + StrZero(nMes,2))

      BeginSQL Alias cTmpQry
      
            SELECT CNA_NUMERO, E1_VALOR VLRMED
            FROM %Table:CNA% CNA
                  INNER JOIN %Table:SE1% SE1 ON E1_FILIAL = %xFilial:SE1%
                                               AND E1_MDCONTR = CNA_CONTRA
                                               AND E1_MDREVIS = CNA_REVISA
                                               AND E1_MDPLANI = CNA_NUMERO
                                               AND E1_TIPO    = 'PR' 
                                               AND SUBSTRING(E1_VENCTO,1,6) = %Exp:cCompetQry%
                                               
                                               AND SE1.%NotDel%
            WHERE CNA_FILIAL = %xFilial:CNA%
                  AND CNA_CONTRA = %Exp:cContrato%
                  AND CNA_REVISA = %Exp:cRevisao%                
                  AND CNA.%NotDel%
      EndSQL
EndIf 

// Avalia se existe dados a serem carregados considerando os parâmetros
If (cTmpQry)->(!EOF())
      // Habilita para incluir e alterar linhas no grid   
      oStrABXMdl:SetProperty("*",MODEL_FIELD_WHEN,{|| .T. })
      oMdlGrd:SetNoInsertLine(.F.)
      
      // Posiciona na última linha do grid
      oMdlGrd:GoLine( oMdlGrd:Length() )

      // Captura os dados do cabeçalho para não repetir o get
      cCodFatAnt := oMdlCab:GetValue("ABX_CODIGO")
      cOperac := oMdlCab:GetValue("ABX_OPERAC")

      // Percorre todas planilhas e parcela do cronograma para pegar as informações
      While (cTmpQry)->(!EOF()) .And. lOk
            // Captura a linha atual
            nLinAtual := oMdlGrd:GetLine()

            // Avalia se precisa incluir uma nova linha
            If !Empty( oMdlGrd:GetValue("ABX_CODIGO") )
                  lOk := lOk .And. ( oMdlGrd:AddLine() == ( nLinAtual + 1 ) )
                  Aadd(aRet,nLinAtual + 1 )
            EndIf

			If cOperac == "1" .And. lParamMed
				nValorApur := At934VlrApur(cCompAnt,cContrato,cRevisao)
			Elseif cOperac == "2"
				If oMdlGrdAnt:SeekLine( { { "ABX_CODPLA", (cTmpQry)->CNA_NUMERO } } ) .And. lParamMed
					nValorApur := oMdlGrdAnt:GetValue("ABX_VLMEDI")-oMdlGrdAnt:GetValue("ABX_VLAPUR")					
					If nValorApur < 0
						nValorApur := 0
					Endif
				Else
					nValorApur := 0
				Endif
			Endif			

            lOk := lOk .And. oMdlGrd:SetValue("ABX_OPERAC", '1' )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CODIGO", cCodFatAnt )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CONTRT", cContrato )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CONREV", cRevisao )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CODPLA", (cTmpQry)->CNA_NUMERO )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_MESANO", cCompetencia )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_VLMEDI", (cTmpQry)->VLRMED - nValorApur )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_DESCON", nValorApur)
            lOk := lOk .And. oMdlGrd:SetValue("ABX_VLORMD", (cTmpQry)->VLRMED )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_RECORR", oMdlCab:GetValue('ABX_RECORR') )				
			
            (cTmpQry)->(DbSkip())
      End
      oStrABXMdl:SetProperty('*', MODEL_FIELD_WHEN, {|| .F. })
		
      If nValorApur > 0 .And. (cOperac == "1" .Or. cOperac == "2")
           oStrABXMdl:SetProperty('ABX_TPDESC', MODEL_FIELD_WHEN, {|| .T. })
      EndIf
      
      oMdlGrd:GoLine(1)
      
      // Bloqueia novamente para não incluir e alterar linhas no grid
      oMdlGrd:SetNoInsertLine(.T.)
EndIf

(cTmpQry)->(DbCloseArea())

Return aRet 

/*/{Protheus.doc} At934CgAnt
@description      Carrega os dados da competência anterior, competência a ser apurada.
@author           josimar.assuncao
@since                  17.04.2017
@param                  oModel, objeto FwFormModel, modelo principal da rotina.
@param                  cContrato, caracter, contrato alvo para a carga das planilhas e informações da competência.
@param                  cRevisao, caracter, revisão do contrato para a medição.
@param                  cCompetencia, caracter, parcela/competência que será apurada.
/*/
Static Function At934CgAnt( oModel, cContrato, cRevisao, cCompetencia )
Local oMdlCab           := oModel:GetModel("ABXMASTER")
Local oMdlGrd           := oModel:GetModel("ABX_MESANTERIOR")
Local cTmpQry           := GetNextAlias()
Local lOk               := .T.
Local nLinAtual   := 0

BeginSQL Alias cTmpQry
      SELECT ABX_FILIAL, ABX_OPERAC, ABX_CODIGO, ABX_CONTRT, ABX_CONREV,
            ABX_CODPLA, ABX_MESANO, ABX_VLMEDI, ABX.R_E_C_N_O_ ABXRECNO
      FROM %Table:ABX% ABX
      WHERE ABX_FILIAL = %xFilial:ABX%
            AND ABX_CONTRT = %Exp:cContrato%
            AND ABX_CONREV = %Exp:cRevisao%
            AND ABX_MESANO = %Exp:cCompetencia%
            AND ABX_CODPLA <> ''
            AND ABX_CODTFV = ' '
            AND ABX.%NotDel%
EndSQL

If (cTmpQry)->(!EOF())
      // Habilita para incluir e alterar linhas no grid
      oMdlGrd:SetNoUpdateLine(.F.)
      oMdlGrd:SetNoInsertLine(.F.)

      // Posiciona na última linha do grid
      oMdlGrd:GoLine( oMdlGrd:Length() )

      While (cTmpQry)->(!EOF()) .And. lOk
            // Captura a linha atual
            nLinAtual := oMdlGrd:GetLine()

            // Avalia se precisa incluir uma nova linha
            If !Empty( oMdlGrd:GetValue("ABX_CODIGO") )
                  lOk := lOk .And. ( oMdlGrd:AddLine() == ( nLinAtual + 1 ) )
            EndIf

            lOk := lOk .And. oMdlGrd:SetValue("ABX_OPERAC", '3' )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CODIGO", oMdlCab:GetValue("ABX_CODIGO") )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CONTRT", (cTmpQry)->ABX_CONTRT )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CONREV", (cTmpQry)->ABX_CONREV )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_CODPLA", (cTmpQry)->ABX_CODPLA )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_MESANO", (cTmpQry)->ABX_MESANO )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_VLMEDI", (cTmpQry)->ABX_VLMEDI )
            lOk := lOk .And. oMdlGrd:SetValue("ABX_RECORR", oMdlCab:GetValue('ABX_RECORR') )

            // Inserindo o recno para identificação do registro da linha
            lOk := lOk .And. oMdlGrd:SetValue("ABX_REC", (cTmpQry)->ABXRECNO )

            (cTmpQry)->(DbSkip())
      End

      oMdlGrd:GoLine(1)

      // Habilita para incluir e alterar linhas no grid
      oMdlGrd:SetNoUpdateLine(.T.)
      oMdlGrd:SetNoInsertLine(.T.)
Else
      lOk := .F.
EndIf

(cTmpQry)->(DbCloseArea())

If lOk
      // Processa apuração
      lOk := At934Apurar( oMdlGrd, cContrato, cRevisao, cCompetencia )
EndIf

Return

/*/{Protheus.doc} At934Mes2
@description      Preenche a competência anterior conforme o conteúdo da competência atual
@author           josimar.assuncao
@since                  17.04.2017
@return           cCompAnt, caracter, competência anterior a informada diretamente na tela
/*/
Function At934Mes2( oMdlCab, lParam, cCompRet )
Local cCompAnt          := Space( 7 )
Local cCompAtu          := oMdlCab:GetValue("ABX_MESANO")
Local dTemp             := CTOD("")
Local nMes              := 0
Local nAno              := 0

Default lParam          := .F.
Default cCompRet := ""



If !Empty(cCompAtu)	
      // Monta o primeiro dia do mês
      dTemp := CTOD("01/"+cCompAtu)

      nMes := Month(dTemp) - 1
      nAno := Year( dTemp )

      If nMes == 0
            nMes := 12
            nAno -= 1
      EndIf

      cCompAnt := StrZero(nMes,2)+"/"+cValToChar(nAno)
      If lParam
            cCompRet := cCompAnt
      Else
            oMdlCab:LoadValue( "ABX_MESANO2", cCompAnt )
      EndIf
EndIf

Return

/*/{Protheus.doc} At934Apurar
@description      Realiza a apuração considerando o período integral do mês da competência recebida de 1 ao último dia.
@author           josimar.assuncao
@since                  17.04.2017
@param                  oMdlGrd, objeto fwformgridmodel, objeto com os dados do grid da competência anterior.
@param                  cContrato, caracter, contrato alvo para a carga das planilhas e informações da competência.
@param                  cRevisao, caracter, revisão do contrato para a medição.
@param                  cCompetencia, caracter, parcela/competência que será apurada.
@return           Lógico, determina se conseguiu ou não realizar a apuração
/*/
Static Function At934Apurar( oMdlGrd, cContrato, cRevisao, cCompetencia )
Local lOk               := .T.
Local dIniApur          := CTOD("01/"+cCompetencia)
Local dFimApur          := At934lDay( cCompetencia )
Local oMdlTFV           := Nil
Local oMdlTWB           := Nil
Local oMdlTemp          := Nil
Local nLin1             := 0
Local nPlanilha   := 0
Local nValApurado       := 0
Local cFilTFL           := xFilial("TFL")
Local cCodTFV           := ""
Local oView             := FwViewActive()

oMod930 := FwLoadModel("TECA930")
oMod930:SetOperation( MODEL_OPERATION_INSERT )

oMdlTFV := oMod930:GetModel("TFVMASTER")
oMdlTWB := oMod930:GetModel("TWBDETAIL")

// Carrega as variáveis do pergunte
Pergunte("TEC930",.F.)
MV_PAR01 := cContrato
MV_PAR02 := dIniApur
MV_PAR03 := dFimApur

// Ativa o modelo de dados
lOk := lOk .And. oMod930:Activate()

// Indica hora extra como excedente
lOk := lOk .And. oMdlTFV:SetValue("TFV_HREXTR", "1" )

// Locação de Equipamentos => O valor apurado já é carregado no campo considerado para a cobrança
// assim não precisa realizar o mesmo processo realizado nas outras guias de inserir o valor apurado no valor a medir.

// Abre a TFL para servir de ponte para a planilha
DbSelectArea("TFL")
TFL->( DbSetOrder( 1 ) ) // TFL_FILIAL + TFL_CODIGO

If lOk
      // Captura o código da apuração
      cCodTFV := oMdlTFV:GetValue("TFV_CODIGO")
      
      // Habilita a edição das linhas
      oMdlGrd:SetNoUpdateLine(.F.)

      // Percorre os itens do resumo e copia os valores pelas planilhas
      For nPlanilha := 1 To oMdlTWB:Length()
            oMdlTWB:GoLine( nPlanilha )

            // Posiciona na TFL
            lOk := lOk .And. TFL->( DbSeek( cFilTFL + oMdlTWB:GetValue("TWB_CODTFL") ) )

            // Posiciona na planilha do contrato
            lOk := lOk .And. oMdlGrd:SeekLine( { { "ABX_CODPLA", TFL->TFL_PLAN } } )
            
            // Insere os dados da apuração no faturamento antecipado
            lOk := lOk .And. oMdlGrd:SetValue( "ABX_CODTFV", cCodTFV )
            
            nValApurado := oMdlTWB:GetValue("TWB_TOTMED")
            lOk := lOk .And. oMdlGrd:SetValue( "ABX_VLAPUR", nValApurado )

            If !lOk
                  Exit
            EndIf

      Next nPlanilha
      oMdlTWB:GoLine( 1 )
      oMdlGrd:GoLine( 1 )

      // Bloqueia novamente a edição das linhas
      oMdlGrd:SetNoUpdateLine(.T.)

      // Refresh no grid
      If oView:GetModel():GetId() == "TECA934" .And. ;
            oView:IsActive()

            oView:Refresh("ABX_MESANTERIOR") // "VIEW_GRID2"
      EndIf
EndIf

Return

/*/{Protheus.doc} At934lDay
@description      Retorna o última dia de um determinando mês.
@author           josimar.assuncao
@since                  17.04.2017
@param                  cCompetencia, caracter, parcela/competência alvo.
@return           Date, retorna o último dia.
/*/
Static Function At934lDay( cCompetencia )
Local dLastDay    := CTOD("")
Local dFirst      := CTOD("01/"+cCompetencia)
Local nMonth      := Month(dFirst) 
Local nYear       := Year(dFirst)

If nMonth > 12
      nMonth := 1
      nYear += 1
EndIf

dFirst := CTOD("01/"+StrZero(nMonth,2)+"/" + Str(nYear) )
dLastDay := LastDate(CTOD("01/"+StrZero(nMonth,2)+"/" + Str(nYear) ))

Return dLastDay

/*/{Protheus.doc} At934Cancel
@description      Bloco quando acionado o botão cancelar da rotina
@author           josimar.assuncao
@since                  17.04.2017
@param                  oModel, objeto FwFormModel, modelo principal da rotina
/*/
Static Function At934Cancel(oModel)
Local lRet        := .T.

// Caso a apuração esteja ativa cancela os dados dela
If ValType(oMod930)=="O" .And. oMod930:IsActive()
      A934Cn930()
EndIf

RollBackSXE()

Return lRet

/*/{Protheus.doc} A934Cn930
@description      Cancela os dados da apuração e medição.
@author           josimar.assuncao
@since                  18.04.2017
/*/
Static Function A934Cn930()
oMod930:CancelData()
oMod930:DeActivate()
oMod930:Destroy()
Return 

/*/{Protheus.doc} At934Commit
@description      Grava os dados da rotina.
@author           josimar.assuncao
@since                  18.04.2017
@param                  oModel, objeto FwFormModel, modelo principal da rotina.
@return           Lógico, indica se a gravação aconteceu com sucesso ou não.
/*/
Static Function At934Commit(oModel)
Local lRet              := .T.
Local oMdlCab           := oModel:GetModel("ABXMASTER")
Local oMdlGrdMed 		:= oModel:GetModel("ABX_MESATUAL")
Local oMdlGrdApu 		:= oModel:GetModel("ABX_MESANTERIOR")
Local cOperac           := oMdlCab:GetValue("ABX_OPERAC")
Local nLinha            := 0
Local lParamMed   		:= SuperGetMv("MV_GSFAMEN",,"0") == "1"
Local lReduzMed   		:= .F.
Local lPedido           := .F.
Local nValorDifer       := 0
Local oView             := FwViewActive() 
Local lShowErro   		:= .F.
Local nVlrMedi     	 	:= 0
Local oStrABXMdl		:= oMdlGrdMed:GetStruct()

Begin Transaction

oStrABXMdl:SetProperty("*",MODEL_FIELD_WHEN,{|| .T. })
oMdlGrdApu:SetNoUpdateLine(.F.)

If !IsBlind()    
      If  ( oView:IsActive() .And. oView:GetModel():GetId()=="TECA934" )
            lShowErro := .T.
      EndIf 
EndIf 

// Processamento para Apuração e Pedido de venda
If (cOperac == "2" .Or. cOperac == "3") 

      If ValType(oMod930)=="O" .And. oMod930:IsActive() .And. !oMdlGrdApu:IsEmpty()
            If !( lRet := ( lRet .And. oMod930:VldData() .And. oMod930:CommitData() ) )
                  If !Empty( oMod930:GetErrorMessage()[MODEL_MSGERR_MESSAGE] ) .Or. !Empty( oMod930:GetErrorMessage()[MODEL_MSGERR_SOLUCTION] )
                        oModel:SetErrorMessage( oMdlCab:GetId(), "ABX_OPERAC", oMdlCab:GetId(), "ABX_OPERAC", "AT9349301",; 
                                                                 oMod930:GetErrorMessage()[MODEL_MSGERR_MESSAGE], oMod930:GetErrorMessage()[MODEL_MSGERR_SOLUCTION], cOperac )
                  Else
                        oModel:SetErrorMessage( oMdlCab:GetId(), "ABX_OPERAC", oMdlCab:GetId(), "ABX_OPERAC", "AT9349302",; 
                                                                 STR0025, STR0026, cOperac )  // "Problemas ao gravar a apuração." ###  "Verifique se a apuração está funcionando adequadamente."
                  EndIf
            EndIf
      EndIf

      If lRet 
            If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !oMdlGrdApu:IsEmpty()
                  // Realiza o processo de inclusão das informações da apuração

                  // Percorre as linhas do grid de apuração 
                  For nLinha := 1 To oMdlGrdApu:Length()
                        oMdlGrdApu:GoLine( nLinha )
                        
                        If !oMdlGrdApu:IsDeleted()
                        // Posiciona na linha da mesma planilha na aba das medições atuais
                             If lRet 
                                   If oMdlGrdMed:SeekLine( { { "ABX_CODPLA", oMdlGrdApu:GetValue("ABX_CODPLA") } } )
                                         lRet := .T.
                                         nVlrMedi := oMdlGrdMed:GetValue("ABX_VLMEDI")
                                   Else
                                         aSeekCmp := At934SkCmpt(oMdlGrdApu:GetValue("ABX_CONTRT"),oMdlGrdApu:GetValue("ABX_CONREV"),oMdlGrdApu:GetValue("ABX_CODPLA"),oMdlCab:GetValue("ABX_MESANO2"),oMdlCab:GetValue("ABX_RECORR"))
                                         lRet := aSeekCmp[1]
                                         nVlrMedi := aSeekCmp[2]
                                   EndIf
                             EndIf 
                             
                             If lRet 
                                   // Valor Apurado - Valor Medido
                                   nValorDifer := ( oMdlGrdApu:GetValue("ABX_VLAPUR") - oMdlGrdApu:GetValue("ABX_VLMEDI") )
      
                                   // Avalia se precisa gerar o pedido
                                   If nValorDifer > 0
                                         lPedido     := .T.
                                   Else
                                         lPedido     := .F.
                                    EndIf
                                   
                                   // Avaliar se reduz a medição quando a apuração foi menor que a medição
									/*If lParamMed .And. !lPedido .And. nValorDifer < 0
										lReduzMed := .T.
										// Reduz o valor a ser medido da parcela da competência
										lRet := lRet .And. oMdlGrdMed:SetValue("ABX_VLMEDI", ( nVlrMedi - nValorDifer) )
									Else
										lReduzMed := .F.
									EndIf*/
                             EndIf
      
                             // Chama a rotina para gerar o pedido de venda
                             If lRet .And. lPedido
                                   lRet := At934GerPv( oMdlGrdApu, lShowErro )
                             EndIf
      
                             If !lRet 
                                   Exit
                             Else
                                   // Posiciona no registro da ABX que sofrerá a alteração
                                   ABX->( DbGoTo( oMdlGrdApu:GetValue("ABX_REC") ) )
                                   Reclock( "ABX", .F. )
                                         // Grava os dados da Apuração
                                         ABX->ABX_CODTFV := oMdlGrdApu:GetValue("ABX_CODTFV")
                                         ABX->ABX_VLAPUR := oMdlGrdApu:GetValue("ABX_VLAPUR")
                                         // Grava os dados do Pedido
                                         ABX->ABX_PEDIDO := oMdlGrdApu:GetValue("ABX_PEDIDO")
                                         ABX->ABX_PEDITE := oMdlGrdApu:GetValue("ABX_PEDITE")
                                         ABX->ABX_VLCOMP := oMdlGrdApu:GetValue("ABX_VLCOMP")
                                   ABX->( MsUnlock() )
                             EndIf
                        EndIf 
                  Next nLinha
                  oMdlGrdApu:GoLine( 1 )
                  oMdlGrdMed:GoLine( 1 )
            
            ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE .And. !oMdlGrdApu:IsEmpty()
                  // Remove as informações da apuração associadas com esta operação
                  
                  // Percorre as linhas para desfazer as opções
                  For nLinha := 1 To oMdlGrdApu:Length()
                        oMdlGrdApu:GoLine( nLinha )

                        If !Empty( oMdlGrdApu:GetValue("ABX_PEDIDO") )
                             lRet := At934ExcPv( oMdlGrdApu, lShowErro )
                        EndIf

                        If !lRet 
                             Exit
                        Else
                             // Posiciona no registro da ABX que sofrerá a alteração
                             ABX->( DbGoTo( oMdlGrdApu:GetValue("ABX_REC") ) )
                             Reclock( "ABX", .F. )
                                   // Grava os dados da Apuração
                                   ABX->ABX_CODTFV := ""
                                   ABX->ABX_VLAPUR := 0
                                   // Grava os dados do Pedido
                                   ABX->ABX_PEDIDO := ""
                                   ABX->ABX_PEDITE := ""
                                   ABX->ABX_VLCOMP := 0
                             ABX->( MsUnlock() )
                        EndIf
                  Next nLinha
                  oMdlGrdApu:GoLine( 1 )
            EndIf
      EndIf
EndIf

// Processamento para Medição do contrato
If lRet .And. ( cOperac == "1" .Or. cOperac == "2" )
      If oModel:GetOperation() == MODEL_OPERATION_INSERT
            lRet := At930GerMd( oMdlGrdMed )
      ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
            lRet := At930ExcMd( oMdlGrdMed )
      EndIf
EndIf

lRet := lRet .And. FwFormCommit(oModel)

If !lRet
      DisarmTransaction()
      Break
EndIf

End Transaction

Return lRet

/*/{Protheus.doc} At934Vi930
@description      Visualiza a apuração associada a um registro.
@author           josimar.assuncao
@since                  18.04.2017
/*/
Function At934Vi930( cTab, cRecno, nOpc )
Local oView 	:= FwViewActive()
Local oModel	:= FwModelActive()
Local aFolder	:= {}
Local cNumApu	:= ""

aFolder := oView:GetFolderActive("ABAS", 2)

If Len(aFolder) == 2
	If aFolder[2] == STR0011
		cNumApu := oModel:GetValue("ABX_MESATUAL","ABX_CODTFV")
	Elseif aFolder[2] == STR0012
		cNumApu := oModel:GetValue("ABX_MESANTERIOR","ABX_CODTFV")
	Endif
Endif

DbSelectArea("TFV")
TFV->( DbSetOrder( 1 ) ) // TFV_FILIAL + TFV_CODIGO

If TFV->( DbSeek( xFilial("TFV")+cNumApu ) )
	FWExecView( STR0007, "VIEWDEF.TECA930", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} )  // "Visualizar Apuração"
Else
      MsgAlert( STR0027, STR0028 )  // "Não encontrada apuração para a medição." ### "Medição sem apuração"
EndIf

Return 

/*/{Protheus.doc} At934ViAnt
@description      Carrega os dados da competência anterior, competência a ser apurada.
@author           josimar.assuncao
@since                  18.04.2017
@param                  oModel, objeto FwFormModel, modelo principal da rotina.
@param                  cContrato, caracter, contrato alvo para a carga das planilhas e informações da competência.
@param                  cRevisao, caracter, revisão do contrato para a medição.
@param                  cCompetencia, caracter, parcela/competência que será apurada.
/*/
Static Function At934ViAnt( oMdlGrd )
Local oModel            := oMdlGrd:GetModel()
Local oMdlCab           := oModel:GetModel("ABXMASTER")
Local cTmpQry           := GetNextAlias()
Local lOk               := .T.
Local nLinAtual   := 0
Local aRet              := {}
Local cContrato   := oMdlCab:GetValue("ABX_CONTRT")
Local cRevisao          := oMdlCab:GetValue("ABX_CONREV")
Local cCompApu          := ""

// Busca a competência anterior
At934Mes2( oMdlCab, .T., @cCompApu )

BeginSQL Alias cTmpQry
      SELECT ABX.*, ABX.R_E_C_N_O_ ABX_REC
      FROM %Table:ABX% ABX
      WHERE ABX_FILIAL = %xFilial:ABX%
            AND ABX_CONTRT = %Exp:cContrato%
            AND ABX_CONREV = %Exp:cRevisao%
            AND ABX_MESANO = %Exp:cCompApu%
            AND ABX_CODPLA <> ''
            
            AND ABX.%NotDel%
EndSQL

aRet := FwLoadByAlias( oMdlGrd, cTmpQry )

(cTmpQry)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} At934GerPv
@description      Gera o pedido de venda.
@author           josimar.assuncao
@since                  19.04.2017
@param                  oMdlGrd, objeto FwFromGridModel, dados no grid para a geração do pedido de venda.
@return           Lógico, indica se conseguiu criar o pedido de venda com sucesso.
/*/
Static Function At934GerPv( oMdlGrd, lShowErro )
Local lRet                   := .T.
Local oModel                 := oMdlGrd:GetModel()
Local aPedCabec         	 := {}
Local aPedItens         	 := {}
Local aItePed                := {}
Local aRateio                := {}
Local nValPedido        	 := 0
Local cItemPv                := ""
Local cErro                  := ""
Local cSolucao               := ""
Local aLocAtend				 := {}
Default lShowErro            := .T.

Private lMsErroAuto     := .F.
Private lMsHelpAuto     := .T.
Private lAutoErrNoFile := .F.

DbSelectArea("CN9")
CN9->( DbSetOrder( 1 ) )  // CN9_FILIAL+CN9_CONTRA+CN9_REVISA

DbSelectArea("CNA")
CNA->( DbSetOrder( 1 ) )  // CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

DbSelectArea("CNB")
CNB->( DbSetOrder( 1 ) )  // CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM

If CN9->( DbSeek( xFilial("CNA")+oMdlGrd:GetValue("ABX_CONTRT")+oMdlGrd:GetValue("ABX_CONREV") ) ) .And. ;
      CNA->( DbSeek( xFilial("CNA")+oMdlGrd:GetValue("ABX_CONTRT")+oMdlGrd:GetValue("ABX_CONREV")+oMdlGrd:GetValue("ABX_CODPLA") ) ) .And. ;
      CNB->( DbSeek( xFilial("CNB")+oMdlGrd:GetValue("ABX_CONTRT")+oMdlGrd:GetValue("ABX_CONREV")+oMdlGrd:GetValue("ABX_CODPLA") ) )
	  
	  aLocAtend := Cn121GetLoc(oMdlGrd:GetValue("ABX_CONTRT"),oMdlGrd:GetValue("ABX_CODPLA"))
      
      // Informações do cabeçalho do orçamento
      cNumCab := GetSXENum("SC5","C5_NUM")
      aAdd( aPedCabec, { 'C5_NUM'   , cNumCab      		, Nil } )
      aAdd( aPedCabec, { 'C5_TIPO'   , 'N'				, Nil } )
      aAdd( aPedCabec, { 'C5_CLIENTE', CNA->CNA_CLIENT,  Nil } )
      aAdd( aPedCabec, { 'C5_LOJACLI', CNA->CNA_LOJACL,  Nil } )
      aAdd( aPedCabec, { 'C5_CONDPAG', CN9->CN9_CONDPG,  Nil } )
      //aAdd( aPedCabec, { "C5_MDCONTR" , CNA->CNA_CONTRA, Nil } )
      aAdd( aPedCabec, { "C5_MDNUMED" , CNA->CNA_RECMED, Nil } )
      aAdd( aPedCabec, { "C5_MDPLANI" , CNA->CNA_NUMERO, Nil } )
	  aAdd( aPedCabec, { "C5_ORIGEM"  ,'TECA934'   	   , Nil } )                 

	  If !Empty(aLocAtend[1])
	  	  aAdd(aPedCabec,{"C5_MUNPRES",aLocAtend[1],NIL}) // Municipio de Prestacao
	  EndIf

	  If !Empty(aLocAtend[2])
	      aAdd(aPedCabec,{"C5_RECISS",aLocAtend[2],NIL}) // Recolhe ISS?
	  EndIf

      // Informaçoes do item para o pedido
      nValPedido := oMdlGrd:GetValue("ABX_VLAPUR") - oMdlGrd:GetValue("ABX_VLMEDI")
      nValPedido := Round(nValPedido,2)

      cItemPv := StrZero( 1, TamSx3('C6_ITEM')[1] )

      aAdd( aItePed, { "C6_ITEM"   , cItemPv, Nil } )
      aAdd( aItePed, { "C6_PRODUTO", CNB->CNB_PRODUT, Nil } )
      aAdd( aItePed, { "C6_QTDVEN" , 1, Nil } )
      aAdd( aItePed, { "C6_PRCVEN" , nValPedido, Nil } )
      aAdd( aItePed, { "C6_VALOR"  , nValPedido, Nil } )
      aAdd( aItePed, { "C6_TES"    , CNB->CNB_TS, Nil } )
      aAdd( aItePed, { "C6_CC"     , CNB->CNB_CC, Nil } )

      aAdd( aPedItens, aclone( aItePed ) )
      // verifica se há centro de custo associado ao item e o considera na geração do pedido de venda
      If CNB->CNB_CC <> " "
            aAdd( aRateio, { "01", { { { "AGG_ITEM"  , "01", Nil },;
                                                           { "AGG_PERC"  , 100, Nil },;
                                                           { "AGG_CC"    , CNB->CNB_CC, Nil },;
                                                           { "AGG_CONTA" , "", Nil },;
                                                           { "AGG_ITEMCT", "", Nil },;
                                                           { "AGG_CLVL"  , "", Nil } } } } )
      EndIf

      lMsErroAuto := .F.
      MsExecAuto( { |w,x,y,z| MATA410( w, x, y, Nil, Nil, Nil, Nil, z ) }, aPedCabec, aPedItens, 3, aRateio )

      If lMsErroAuto
            // Caso tenha acontecido erro
            lRet := .F.
            cErro := STR0030  // "Problemas ao gerar o pedido de venda."
            cSolucao := STR0031  // "Verifique se as informações de contrato, planilha e itens são válidas para a geração do pedido."
            
            If lShowErro
                  MostraErro()
            EndIf
            // Define o erro no objeto principal do modelo
            oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_PEDIDO", oMdlGrd:GetId(), "ABX_PEDIDO", "AT934GERPV",; 
                                         cErro, cSolucao )

      Else
            // Em sucesso da operação guarda as informações do pedido
            lRet := lRet .And. oMdlGrd:SetValue("ABX_PEDIDO", SC5->C5_NUM )
            lRet := lRet .And. oMdlGrd:SetValue("ABX_PEDITE", cItemPv )
            lRet := lRet .And. oMdlGrd:SetValue("ABX_VLCOMP", nValPedido )
      EndIf

EndIf

Return lRet

/*/{Protheus.doc} At934ExcPv
@description      Exclui o pedido de venda.
@author           josimar.assuncao
@since                  19.04.2017
@param                  oMdlGrd, objeto FwFromGridModel, dados no grid para a geração do pedido de venda.
@return           Lógico, indica se conseguiu excluir o pedido de venda com sucesso.
/*/
Static Function At934ExcPv( oMdlGrd, lShowErro )
Local lRet                   := .T.
Local oModel                 := oMdlGrd:GetModel()
Local aPedCabec         := {}
Local cErro                  := ""
Local cSolucao               := ""

Default lShowErro            := .T.

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .F.

DbSelectArea("SC5")
SC5->( DbSetOrder( 1 ) )  // C5_FILIAL+C5_NUM

DbSelectArea("SC6")
SC6->( DbSetOrder( 1 ) )  // C6_FILIAL+C6_NUM+C6_ITEM

If SC5->( DbSeek( xFilial("SC5")+oMdlGrd:GetValue("ABX_PEDIDO") ) ) .And. ;
      SC6->( DbSeek( xFilial("SC6")+oMdlGrd:GetValue("ABX_PEDIDO")+oMdlGrd:GetValue("ABX_PEDITE") ) )

      aAdd( aPedCabec, { "C5_NUM", oMdlGrd:GetValue("ABX_PEDIDO"), Nil } )

      lMsErroAuto := .F.
      MSExecAuto( {|x,y,z| Mata410(x,y,z)}, aPedCabec, {}, 5 )

      If lMsErroAuto
            // Caso tenha acontecido erro
            lRet := .F.
            cErro := STR0032  // "Problemas ao excluir o pedido de venda."
            cSolucao := STR0033  // "Verifique se o pedido pode realmente ser excluído."
            
            If lShowErro
                  MostraErro()
            EndIf
            // Define o erro no objeto principal do modelo
            oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_PEDIDO", oMdlGrd:GetId(), "ABX_PEDIDO", "AT934EXCPV",; 
                                         cErro, cSolucao )

      EndIf

EndIf

Return lRet

/*/{Protheus.doc} At930GerMd
@description      Gera e encerra a medição do contrato.
@author           josimar.assuncao
@since                  19.04.2017
@param                  oMdlGrd, objeto FwFromGridModel, dados no grid para a geração da medição do contrato.
@return           Lógico, indica se conseguiu realizar a medição.
/*/
Static Function At930GerMd( oMdlGrd )
Local lRet              := .T.
Local oModel            := oMdlGrd:GetModel()
Local oMdlCn121   		:= Nil
Local oMdlCND           := Nil
Local oMdlCXN           := Nil
Local oMdlCNE           := Nil
Local oMdlCNQ           := Nil
Local cContrato   		:= ""
Local cRevisao          := ""
Local cNumMed           := ""
Local nValMed           := 0
Local nValPlan          := 0
Local nPlanilha   		:= 0
Local cErro             := ""
Local cSolucao          := ""

If !oMdlGrd:IsEmpty()
      cContrato := oMdlGrd:GetValue("ABX_CONTRT")
      cRevisao := oMdlGrd:GetValue("ABX_CONREV")
      cMesAno := oMdlGrd:GetValue("ABX_MESANO")

      oMdlCn121 := FwLoadModel("CNTA121")
      oMdlCND     := oMdlCn121:GetModel("CNDMASTER")
      oMdlCXN     := oMdlCn121:GetModel("CXNDETAIL")
      oMdlCNE     := oMdlCn121:GetModel("CNEDETAIL")       
      oMdlCNQ := oMdlCn121:GetModel("CNQDETAIL")

      oMdlCn121:SetOperation(MODEL_OPERATION_INSERT)

      lRet := oMdlCn121:Activate()
      // Identifica o número de medição
      If lRet
            cNumMed := oMdlCND:GetValue("CND_NUMMED")
      EndIf

      lRet := lRet .And. oMdlCND:SetValue( "CND_CONTRA", cContrato )
      lRet := lRet .And. oMdlCND:SetValue( "CND_REVISA", cRevisao )
      lRet := lRet .And. oMdlCND:SetValue( "CND_COMPET", cMesAno )

      If lRet .And. oMdlCXN:IsEmpty()
            lRet := .F.
            cErro := STR0036  // "Não foram carregados as planilhas para a medição dos itens."
            cSolucao := STR0037  // "Verique se o contrato possui a competência indicada."
      EndIf

      // Realiza a atualização das planilhas e itens para fazer o valor ficar de acordo com definido a medir
      If lRet 
	        cContrato := ""
            For nPlanilha := 1 To oMdlGrd:Length()
                  oMdlGrd:GoLine( nPlanilha )
                  If !oMdlGrd:IsDeleted()
                        // Posiciona na planilha da medição
                        If oMdlCXN:SeekLine( { { "CXN_NUMPLA", oMdlGrd:GetValue("ABX_CODPLA") } } )
                             // Faz o check nas planilhas
                             If ( lRet := ( lRet .And. oMdlCXN:SetValue("CXN_CHECK",.T.) ) )
                                   // Captura os valores para verificar se há necessidade de ajuste nos itens
                                   nValMed	:= oMdlGrd:GetValue("ABX_VLMEDI")
                                   nValPlan	:= oMdlCXN:GetValue("CXN_VLLIQD")
                                   // Caso o valor da medição na planilha seja menor ao planejado para a parcela realiza os ajustes nos valores dos itens para igualar
                                   If Round(nValMed,2) < Round(nValPlan,2)
                                         lRet := lRet .And. At934AddD( oMdlGrd, oMdlCXN, oMdlCNQ )
                                   // >>>>>> ESSE TRECHO ABAIXO GERA PROBLEMA POR DÍZIMAS NO GCT <<<<<
                                   // Caso o valor da medição maior, aborta o processo para não gerar problemas nas parcelas seguintes
                                   // Caso encontre o erro continua percorrendo pegando todos os contratos.
                                   ElseIf Round(nValMed,2) > Round(nValPlan,2)
										If Empty(cErro)                                   
                                           cErro 	:= STR0038  // "O valor não pode ultrapassar o planejado para a parcela pois isso acabará com o saldo do contrato antes de medir todas as parcelas."
                                           cSolucao := STR0039  // "Revise o(s) contrato(s) e redistribua os valores das parcelas no(s) cronograma(s) financeiro(s)."										   
										Endif

										If cContrato <> oMdlCXN:GetValue("CXN_CONTRA")
										   cSolucao += CRLF+CRLF+STR0052+": "+oMdlCXN:GetValue("CXN_CONTRA")+CRLF //Contrato
										   cSolucao += STR0056+": "+oMdlCXN:GetValue("CXN_NUMPLA") //Planilha(s)
										Else
											cSolucao += ","+oMdlCXN:GetValue("CXN_NUMPLA")
										Endif

	                                    cContrato	:= oMdlCXN:GetValue("CXN_CONTRA")
                                   EndIf
                             EndIf
                        EndIf 
                        If !lRet
                             Exit
                        EndIf
                  EndIf
            Next nPlanilha

            If !Empty(cErro) .And. !Empty(cSolucao)
				lRet := .F.
	            oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934VALPARC",; 
	                                                cErro, cSolucao )
      		Endif            
            oMdlGrd:GoLine( 1 )
      EndIf

      // Valida e confirma os dados
      lRet := lRet .And. oMdlCn121:VldData() .And. oMdlCn121:CommitData()

      If !lRet
            // Caso tenha gerado erro na inclusão da medição
            If !Empty( oMdlCn121:GetErrorMessage()[MODEL_MSGERR_MESSAGE] ) .Or. !Empty( oMdlCn121:GetErrorMessage()[MODEL_MSGERR_SOLUCTION] )
                  oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934INCMD1",; 
                                                           oMdlCn121:GetErrorMessage()[MODEL_MSGERR_MESSAGE], oMdlCn121:GetErrorMessage()[MODEL_MSGERR_SOLUCTION] )
            ElseIf Empty( cErro )
                  cErro := STR0040  // "A inclusão da medição não pôde ser realizada."
                  cSolucao := STR0041  // "Confira se medição pode ser incluída considerando contrato, planilhas e competência."
                  oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934INCMD2",; 
                                                     cErro, cSolucao )
            EndIf
      Else
            // Prossegue para realizar o encerramento da medição
            For nPlanilha := 1 To oMdlGrd:Length()
                  oMdlGrd:GoLine( nPlanilha )
                  // Atribui o número da medição nas linhas
                  lRet := lRet .And. oMdlGrd:SetValue( "ABX_NUMMED", cNumMed )
            Next nPlanilha
            oMdlGrd:GoLine( 1 )
            
            lRet := CN121Encerr(.T.)
            If !lRet
                  // Encerramento da medição gerou algum erro
                  cErro := STR0042  // "O encerramento da medição não pôde ser realizado."
                  cSolucao := STR0043  // "Confira se pode acontecer o encerramento das medições considerando contrato, planilhas e competência."
                  oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934INCMD2",; 
                                                     cErro, cSolucao )
            EndIf
      EndIf
EndIf

Return lRet

/*/{Protheus.doc} At930ExcMd
@description      Estorna e exclui a medição do contrato.
@author           josimar.assuncao
@since                  19.04.2017
@param                  oMdlGrd, objeto FwFromGridModel, dados no grid para a geração da medição do contrato.
@return           Lógico, indica se conseguiu realizar a medição.
/*/
Static Function At930ExcMd( oMdlGrd )
Local lRet              := .T.
Local oModel            := oMdlGrd:GetModel()
Local oMdlCn121   := Nil
Local cContrato   := ""
Local cRevisao          := ""
Local cNumMed           := ""
Local cErro             := ""
Local cSolucao          := ""

If !oMdlGrd:IsEmpty()
      cContrato := oMdlGrd:GetValue("ABX_CONTRT")
      cRevisao := oMdlGrd:GetValue("ABX_CONREV")
      cNumMed := oMdlGrd:GetValue("ABX_NUMMED")
      
      If !Empty(cNumMed)
            DbSelectArea("CND")
            CND->( DbSetOrder( 7 ) )  // CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED

            If CND->( DbSeek( xFilial("CND")+cContrato+cRevisao+cNumMed ) )
                  // Chama a rotina para estorno do encerramento da medição
                  lRet := CN121Estorn(.T.)
                  
                  If !lRet
                        cErro := STR0044  // "O estorno do encerramento da medição não pôde ser realizado."
                        cSolucao := STR0045  // "Confira se medição pode ser estornada."
                        // Caso tenha identificado erro no Estorno do Encerramento da medição
                        oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934ESTMD",; 
                                                           cErro, cSolucao )
                  Else
                        // Quando não identifica o erro, prossegue com a operação
                        oMdlCn121 := FwLoadModel("CNTA121")
                        oMdlCn121:SetOperation(MODEL_OPERATION_DELETE)

                        lRet := oMdlCn121:Activate()
                        // Valida e confirma a operação no modelo
                        lRet := lRet .And. oMdlCn121:VldData() .And. oMdlCn121:CommitData()

                        If !lRet
                             // Caso tenha sido identificado erro no processamento de exclusão da medição
                             If !Empty( oMdlCn121:GetErrorMessage()[MODEL_MSGERR_MESSAGE] ) .Or. !Empty( oMdlCn121:GetErrorMessage()[MODEL_MSGERR_SOLUCTION] )
                                   oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934EXCMD1",; 
                                                                             oMdlCn121:GetErrorMessage()[MODEL_MSGERR_MESSAGE], oMdlCn121:GetErrorMessage()[MODEL_MSGERR_SOLUCTION] )
                             Else
                                   cErro := STR0046  // "A exclusão da medição não pôde ser realizada."
                                   cSolucao := STR0047  // "Confira se medição pode ser excluída."
                                   oModel:SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934ESTMD2",; 
                                                                       cErro, cSolucao )
                             EndIf
                        EndIf
                        oMdlCn121:DeActivate()
                        oMdlCn121:Destroy()
                  EndIf
            EndIf
      EndIf
EndIf

Return lRet

/*/{Protheus.doc} At934AddD
@description      Inclui desconto para reduzir o valor da medição.
@author           josimar.assuncao
@since                  19.04.2017
@param                  oMdlGrd, objeto FwFromGridModel, dados no grid para a geração da medição do contrato.
@param                  oMdlCXN, objeto FwFromGridModel, dados da planilha para medição.
@param                  oMdlCNQ, objeto FwFromGridModel, dados de desconto para a planilha na medição.
@return           Lógico, indica se conseguiu inserir o desconto com sucesso.
/*/
Static Function At934AddD( oMdlGrd, oMdlCXN, oMdlCNQ )
Local lRet 			:= .T.
Local nValMedir 	:= oMdlGrd:GetValue("ABX_VLMEDI")
Local nValLiqAtu 	:= oMdlCXN:GetValue("CXN_VLLIQD")
Local cContra		:= oMdlGrd:GetValue("ABX_CONTRT")
Local cTipCod		:= oMdlGrd:GetValue("ABX_TPDESC")
Local cNumPla		:= oMdlCXN:GetValue("CXN_NUMPLA")
Local nDiferenca 	:= nValLiqAtu - nValMedir
Local cTipDesc 		:= Posicione("CNP",1,xFilial("CNP")+cTipCod,"CNP_DESCRI")
			
lRet := lRet .And. oMdlCNQ:SetValue( "CNQ_CONTRA", cContra )
lRet := lRet .And. oMdlCNQ:SetValue( "CNQ_NUMPLA", cNumPla )
lRet := lRet .And. oMdlCNQ:SetValue( "CNQ_TPDESC", cTipCod )
lRet := lRet .And. oMdlCNQ:SetValue( "CNQ_DESCRI", cTipDesc )
lRet := lRet .And. oMdlCNQ:SetValue( "CNQ_VALOR" , nDiferenca )

If !lRet
	oMdlGrd:GetModel():SetErrorMessage( oMdlGrd:GetId(), "ABX_NUMMED", oMdlGrd:GetId(), "ABX_NUMMED", "AT934DESC",; 
								oMdlCNQ:GetModel():GetErrorMessage()[MODEL_MSGERR_MESSAGE], oMdlCNQ:GetModel():GetErrorMessage()[MODEL_MSGERR_SOLUCTION] )
EndIf

Return lRet

/*/{Protheus.doc} At934ILote
@description      Abre interface de processamento em Lote - Inclusão
@author           matheus.raimundo
@since                  19.04.2017
/*/
Function At934ILote(lAutomato)
Local aButtons    := AT934RetB()
Default lAutomato := .F.
AT934SetIL(.T.)
If !lAutomato
	FWExecView(STR0034,"VIEWDEF.TECA934A",MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,30,aButtons)
EndIF
AT934SetIL(.F.)

Return

/*/{Protheus.doc} At934ELote
@description      Abre interface de processamento em Lote - Inclusão
@author           matheus.raimundo
@since                  19.04.2017
/*/
Function At934ELote(lAutomato)
Local aButtons    := AT934RetB()
Default lAutomato := .F.
AT934SetEL(.T.)
If !lAutomato
	FWExecView(STR0035,"VIEWDEF.TECA934A",MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,30,aButtons)
EndIf
AT934SetEL(.F.)

Return

/*/{Protheus.doc} At934ClGrd
@description      Limpa os grids 
@author           matheus.raimundo
@since                  02.05.2017
@param                  oMdlGrid
@return           Nil
/*/
Function At934ClGrd(oMdlGrid)
Local nNewLine := 0
Local nX       := 0 
Local aProp := GetPropMdl(oMdlGrid)
Local aSaveRows := FwSaveRows()

If !oMdlGrid:IsEmpty()
      oMdlGrid:SetNoInsertLine(.F.)
      nNewLine := oMdlGrid:AddLine()
      oMdlGrid:LineShift(1,nNewLine)
      
      For nX := oMdlGrid:Length() To 1 Step -1
            oMdlGrid:GoLine(nX)
            If nX > 1
                  oMdlGrid:DeleteLine(.T.,.T.)
            EndIf 
            
      Next nX
EndIf 

RstPropMdl(oMdlGrid,aProp)
FwRestRows( aSaveRows )
      
Return 

/*/{Protheus.doc} At934ReLoad
@description      Recarrega os grids 
@author           matheus.raimundo
@since                  02.05.2017
@param                  oMdlGrid
@return           Nil
/*/
Function At934ReLoad(oView)
Local oModel := FwModelActive()
Local oMdlGrid          := oModel:GetModel("ABX_MESATUAL")
Local oMdlGridAnt            := oModel:GetModel("ABX_MESANTERIOR")

At934Load()
oView:Refresh()
Return 

/*/{Protheus.doc} At934SkCmpt
@description      Tenta localizar a competencia do contrato 
@author           matheus.raimundo
@since                  02.05.2017
@param                  oMdlGrid
@return           Nil
/*/
Function At934SkCmpt(cContrato,cRevisao,cPlan,cCompetencia,lRecorr)
Local aRet  := {.F.,0}
Local cTmpQry := GetNextAlias()

BeginSQL Alias cTmpQry                   
      SELECT ABX_VLMEDI VLRMED
      FROM %Table:ABX% ABX
      WHERE ABX_FILIAL = %xFilial:ABX%
            AND ABX_CONTRT = %Exp:cContrato%
            AND ABX_CONREV = %Exp:cRevisao%
            AND ABX_MESANO = %Exp:cCompetencia%
            AND ABX_CODPLA = %Exp:cPlan%
            AND ABX_CODTFV = ' '
            AND ABX.%NotDel%
      EndSQL            

If (cTmpQry)->(!EOF())
      aRet[1] := .T.
      aRet[2] := (cTmpQry)->VLRMED
EndIf
(cTmpQry)->( DbCloseArea() )

Return aRet

/*/{Protheus.doc} At934Vld
@description      Tenta localizar a competencia do contrato 
@author           matheus.raimundo
@since                  02.05.2017
@param                  oMdlGrid
@return           Nil
/*/
Function At934Vld(oModel)
Local lRet := .F.
Local nI   := 1
Local oMdlGrid :=  oModel:GetModel("ABX_MESATUAL")
Local aArea    := GetArea()
Local cTmpQry  := GetNextAlias()
Local cContrato := ""
Local cRevisao  := ""
Local cCompAnt  := ""
Local cComp  := oModel:GetValue('ABXMASTER','ABX_MESANO')
Local cPlanilha  	:= ""
Local aSaveRows := FwSaveRows()
Local lRecorre := oModel:GetValue('ABXMASTER','ABX_RECORR')
	

lRet := !oModel:GetModel('ABX_MESATUAL'):IsEmpty() .Or. !oModel:GetModel('ABX_MESANTERIOR'):IsEmpty()

If !lRet
      Help(" ",1,"A934ANGRID",,STR0059,4,1) //"Não há dados (Medições e Apurações) disponíveis para este processamento"
EndIf 

If lRet .And. oModel:GetValue('ABXMASTER','ABX_OPERAC') == '1'

	cCompAnt := oModel:GetValue('ABXMASTER','ABX_MESANO2')
	
	If !Empty(cCompAnt)
		For nI := 1 To oMdlGrid:Length()
			oMdlGrid:GoLine(nI)
			If !oMdlGrid:IsDeleted()
				cContrato := oMdlGrid:GetValue("ABX_CONTRT")
				cRevisao  := oMdlGrid:GetValue("ABX_CONREV")						
				cPlanilha := oMdlGrid:GetValue("ABX_CODPLA")
				cComp     := oMdlGrid:GetValue("ABX_MESANO")
			
				If !At934FstPc(cContrato,cRevisao,cPlanilha,cComp,lRecorre)
					BeginSQL Alias cTmpQry
						SELECT 1
						FROM %Table:ABX% ABX
						WHERE ABX_FILIAL = %xFilial:ABX%
							AND ABX_CONTRT = %Exp:cContrato%
							AND ABX_CONREV = %Exp:cRevisao%
							AND ABX_MESANO = %Exp:cCompAnt%
							AND ABX_CODPLA = %Exp:cPlanilha%
							AND ABX_CODTFV <> ' '
							AND ABX.%NotDel%
				        EndSql
				        
				        lRet  := (cTmpQry)->(!EOF())
				        (cTmpQry)->( DbCloseArea() )
				        
				        If !lRet
				        	Help(" ",1,"A934ANAPURA",,STR0060 + cCompAnt + STR0061 + cComp,4,1) //"Necessário apurar a competência ## antes de medir a competência " 
							Exit
				        EndIf
				EndIf        
			EndIf        
	    Next nI
	EndIf			
EndIf

//Quando houver desconto não deixa continuar sem inserir o tipo de desconto.
If lRet
	For nI := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nI)
		If oMdlGrid:GetValue("ABX_DESCON") > 0 .And. Empty(oMdlGrid:GetValue("ABX_TPDESC"))
			lRet := .F.
			Help( "", 1, "A934TPDESC", , STR0062, 1, 0,,,,,,;  // "Campo de Tipo de Desconto em branco."
											{STR0063})  // "Informe um Tipo de Desconto."
			Exit
		Endif
	Next nI
Endif

FwRestRows( aSaveRows )
RestArea(aArea)
Return lRet





//-------------------------------------------------------------------
/*/{Protheus.doc} At934Contr()
Consulta especifica de contratos

@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
Function At934Contr(lAutomato)

Local oModel         := FWModelActive()
Local lRet           := .F.
Local oBrowse        := Nil
Local cAls              := GetNextAlias()
Local nSuperior      := 0
Local nEsquerda      := 0
Local nInferior      := 0
Local nDireita       := 0
Local oDlgTela := Nil
Local cQry   := ""
//Definição do índice da Consulta Padrão
Local aIndex := {"CN9_NUMERO"}
//Definição da Descrição da Chave de Pesquisa da Consulta Padrão
Local aSeek := {{ STR0052, {{STR0052,"C",TamSx3('CN9_NUMERO')[1],0,"",,}} }} //"Contrato" ## "Contrato"
Local cRet := ""
Local cRecorre := ""

Default lAutomato := .F.

cQry := " SELECT CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, TFJ_CNTREC" 
cQry += " FROM " + RetSqlName("CN9") + " CN9 "
cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
cQry += " ON TFJ.TFJ_FILIAL = '" +   xFilial('TFJ') + "'"
cQry += " AND TFJ_CONTRT = CN9_NUMERO AND TFJ_CONREV = CN9_REVISA AND TFJ.D_E_L_E_T_ <> '*'"                                                                   

cQry += "  WHERE CN9_FILIAL = '" +   xFilial('CN9') + "'" 
cQry += "  AND CN9.CN9_SITUAC = '05' "
cQry += "   AND CN9.D_E_L_E_T_ <> '*'"
cQry += "   AND TFJ_ANTECI = '1' "       
cQry += "   AND TFJ_STATUS = '1' "       
cQry += "   AND TFJ.D_E_L_E_T_ <> '*'"

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

If !lAutomato
	DEFINE MSDIALOG oDlgTela TITLE STR0064 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //Contratos
	 
	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription(STR0065) //"Contratos vigentes"
	oBrowse:SetAlias(cAls)
	oBrowse:SetDataQuery()
	oBrowse:SetQuery(cQry)
	oBrowse:SetOwner(oDlgTela)
	oBrowse:SetDoubleClick({ || cRecorr := (oBrowse:Alias())->TFJ_CNTREC, cRet := (oBrowse:Alias())->CN9_NUMERO,  , lRet := .T., oDlgTela:End()}) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0048), {|| cRecorre := (oBrowse:Alias())->TFJ_CNTREC, cRet := (oBrowse:Alias())->CN9_NUMERO,  lRet := .T., oDlgTela:End()},, 2 ) //"Cancelar"
	oBrowse:AddButton( OemTOAnsi(STR0049),  {|| cRecorre := "", cRet := "", oDlgTela:End()} ,, 2 ) //"Cancelar" 
	oBrowse:DisableDetails()
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek(,aSeek)
	
	ADD COLUMN oColumn DATA { ||  CN9_NUMERO } TITLE STR0052 SIZE TamSx3('CN9_NUMERO')[1] OF oBrowse //"Contrato"
	ADD COLUMN oColumn DATA { ||  CN9_REVISA } TITLE STR0053 SIZE TamSx3('CN9_REVISA')[1] OF oBrowse  //"Revisão"
	ADD COLUMN oColumn DATA { ||  STOD(CN9_DTINIC)} TITLE STR0054 SIZE TamSx3('CN9_DTINIC')[1]  OF oBrowse //"Data inicial"
	ADD COLUMN oColumn DATA { ||  STOD(CN9_DTFIM) } TITLE STR0055 SIZE TamSx3('CN9_DTFIM')[1]  OF oBrowse //"Data final"
	
	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf

If lRet .OR. lAutomato
	cItem := cRet     
	If oModel <> Nil
		oModel:LoadValue('ABXMASTER', 'ABX_RECORR',IIF(lAutomato, .F., cRecorre == '1'))
	Endif
EndIf
       
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} At995RetIt()
Consulta especifica de base de atendimento

@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
Function At934RetCN()

Return cItem  



Function At934FstPc(cContrato,cRevisao,cPlanilha,cCompetencia,lRecorre)
Local lRet := .F.
Local dCompet   := 0
Local cCompetQry  := ""
Local nMes    := 0
Local nAno    := 0
Local cTmpQry	:= GetNextAlias()

If !lRecorre
     BeginSQL Alias cTmpQry
     	SELECT 1  FROM %Table:CNF% CNF
            WHERE CNF_FILIAL = %xFilial:CNF%
                 AND CNF_CONTRA = %Exp:cContrato%
                 AND CNF_REVISA = %Exp:cRevisao%
                 AND CNF_NUMPLA = %Exp:cPlanilha%
                 AND CNF_COMPET = %Exp:cCompetencia%                 
                 AND CNF.%NotDel%
                 AND CNF_PARCEL = (SELECT MIN(CNF_PARCEL) FROM %Table:CNF%
                 						WHERE CNF_FILIAL = %xFilial:CNF%
                 						AND CNF_CONTRA = %Exp:cContrato%
                 						AND CNF_REVISA = %Exp:cRevisao%
                 						AND CNF_NUMPLA = %Exp:cPlanilha%                 
                 						AND CNF.%NotDel%)
     EndSQL 
     lRet := (cTmpQry)->(!EOF()) 
Else

	dCompet := CTOD("01/"+cCompetencia) 
                        
	nAno := Year(dCompet)
	nMes := Month(dCompet)
                        
	cCompQry := Alltrim(Str(nAno) + StrZero(nMes,2))
                  
	BeginSQL Alias cTmpQry
		SELECT MIN(E1_PARCELA) PARC
		FROM %Table:SE1% SE1
		WHERE E1_FILIAL = %xFilial:SE1%
           AND E1_MDCONTR = %Exp:cContrato%
           AND E1_MDREVIS = %Exp:cRevisao%
           AND E1_MDPLANI = %Exp:cPlanilha%
           AND SUBSTRING(E1_VENCTO,1,6) = %Exp:cCompQry%
           AND E1_TIPO   = 'PR'           
           AND SE1.%NotDel%
     EndSQL      
     //-- Se encontrar o registro, compara com MV_1DUP, se não encontrar é pq o titulo já foi excluído, logo não é a primeira medição
     lRet := SuperGetMV('MV_1DUP') == Alltrim((cTmpQry)->(PARC)) .Or. (cTmpQry)->(EOF()) 
EndIf

(cTmpQry)->( DbCloseArea() )
Return lRet

/*/{Protheus.doc} At934VlrApur
@description 	Verifica o valor da apuração anterior

@param 			cComp, caracter, competencia a ser verificado
@param 			cContrato, caracter, Numero do Contrato
@param 			cRevisao, caracter, Revisão do Contrato
/*/
Static Function At934VlrApur(cComp,cContrato,cRevisao)
Local nValor	:= 0
Local cTmpQry := GetNextAlias()

BeginSQL Alias cTmpQry
	SELECT *
	FROM %Table:ABX% ABX
	WHERE ABX_FILIAL = %xFilial:ABX%
		AND ABX_CONTRT = %Exp:cContrato%
		AND ABX_CONREV = %Exp:cRevisao%
		AND ABX_CODTFV <> ''
		AND ABX_MESANO = %Exp:cComp%
		AND ABX.%NotDel%
EndSQL

If (cTmpQry)->(!EOF())
	 nValor := (cTmpQry)->ABX_VLAPUR
EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} At934VlTp()
Valid do tipo de desconto

@Return lRet, Logico, retorna .T. se o codigo existir e se interferir no pedido de venda     

/*/
//------------------------------------------------------------------
Function At934VlTp()
Local lRet		:= .F.

If ExistCpo("CNP")
	lRet := (Posicione("CNP",1,xFilial("CNP")+FwFldGet("ABX_TPDESC"),"CNP_FLGPED") == "1")
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At934IniM2()
Inicializador padrão do campo ABX_MESANO2

@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
Function At934IniM2()
Local cCompetencia       := ABX->ABX_MESANO 
Local dCompet            := CTOD("")
Local nMes              := 0
Local nAno              := 0
Local cCompAnt          := ""

If !INCLUI 
	dCompet := CTOD("01/"+cCompetencia)
	dCompet := MonthSub(dCompet,1)
	
	
	nAno := Year(dCompet)
	nMes := Month(dCompet)
			
	cCompAnt :=  StrZero(nMes,2) + '/' + Alltrim(Str(nAno)) 			
	
EndIf
Return cCompAnt

//-------------------------------------------------------------------
/*/{Protheus.doc} AT934SetEL()
Manipulação da variavel que indica se a função de Estorno em Lote está na pilha

@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
Function AT934SetEL(lAction)

If VALTYPE(lAction) == 'L'
	lEstLote := lAction
EndIf

Return lEstLote

//-------------------------------------------------------------------
/*/{Protheus.doc} AT934SetIL()
Manipulação da variavel que indica se a função de Inclusão em Lote está na pilha

@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
Function AT934SetIL(lAction)

If VALTYPE(lAction) == 'L'
	lIncLote := lAction
EndIf

Return lIncLote

//-------------------------------------------------------------------
/*/{Protheus.doc} AT934RetB()
Retorna o valor de aButtons

@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
Function AT934RetB()
Local aButtons := {  {.F.,Nil},;             //- Copiar
                                         {.F.,Nil},;             //- Recortar
                                         {.F.,Nil},;             //- Colar
                                         {.F.,Nil},;             //- Calculadora
                                         {.F.,Nil},;             //- Spool
                                         {.F.,Nil},;             //- Imprimir
                                         {.T.,STR0048},;              //- "Confirmar"
                                         {.T.,STR0049},;   //- "Cancelar"
                                         {.F.,Nil},;             //- WalkThrough
                                         {.F.,Nil},;             //- Ambiente
                                         {.F.,Nil},;             //- Mashup
                                         {.F.,Nil},;             //- Help
                                         {.F.,Nil},;             //- Formulário HTML
                                         {.F.,Nil};                   //- ECM
                                   }
Return aButtons