#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'CTBA212.ch'

STATIC __lAutomato  := IsBlind()

Function CTBA212()

Local oBrowse := BrowseDef()

Private aRotina := MenuDef()

oBrowse:Activate()

Return

Static Function BrowseDef()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("QN8")
oBrowse:SetDescription("Apuração por Visão") 

Return oBrowse

/*{Protheus.doc}
MenuDef - Crição dos menus
@author Diogo Vieira
@since 19/02/2020
@version P12
@return aRotina - Vetor com as opções da Rotina do Vetor
@project Inovação Controladoria
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title "Pesquisar"	Action 'PesqBrw' OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title "Visualizar"	Action 'VIEWDEF.CTBA212' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title "Incluir"	    Action 'VIEWDEF.CTBA212' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title "Alterar"	    Action 'VIEWDEF.CTBA212' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title "Excluir"	    Action 'VIEWDEF.CTBA212' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE "Copiar"	    ACTION 'VIEWDEF.CTBA212' OPERATION 9 ACCESS 0 //'Copia'
ADD OPTION aRotina TITLE "Apurar"	    ACTION 'CT212GERAP()' OPERATION 4 ACCESS 0 //'Apurar'
ADD OPTION aRotina TITLE "Estornar Apuração"    ACTION 'CT212ESTAP()' OPERATION 4 ACCESS 0 //'Estornar Apuração'
ADD OPTION aRotina TITLE "Excluir Apuração"	    ACTION 'CT212EXCAP()' OPERATION 4 ACCESS 0 //'Excluir Apurar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruQN8 	:= FWFormStruct( 1, 'QN8') 
Local oStruQN9 	:= FWFormStruct( 1, 'QN9')
Local oModel		

// Cria campo para legenda
oStruQN9:AddField( ;
                        "" , ;               // [01] C Titulo do campo
                        "" , ;               // [02] C ToolTip do campo
                        'QN9_LEG' , ;               // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        50 , ;                      // [05] N Tamanho do campo
                        0 , ;                      // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { |oModel| CTBLEGENDA(oModel) } , ;           // [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                      // [14] L Indica se o campo é virtual
                        
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'CTBA212',/*bPreValidacao*/, {|oModel|CT212TDOK(oModel)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'QN8MASTER', /*cOwner*/, oStruQN8 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'QN9DETAIL', 'QN8MASTER', oStruQN9,{|oModel| CT220VLGRD(oModel)}, {|oModel| CT212LNOK(oModel)}/*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'QN9DETAIL', { { 'QN9_FILIAL', 'FWxFilial("QN9")'},{ 'QN9_IDAP', 'QN8_IDAP' } }, QN9->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({'QN8_FILIAL','QN8_IDAP'})

// Liga o controle de não repetição de linha
oModel:GetModel( 'QN9DETAIL' ):SetUniqueLine( { 'QN9_CDREIT' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( "Apuração Por Visão" ) //"Apuração Por Visão"

// Não copiar Status 
oModel:GetModel("QN8MASTER"):SetFldNoCopy({"QN8_PERIOD","QN8_SALDO","QN8_INDSLD"})
oModel:GetModel("QN9DETAIL"):SetFldNoCopy({"QN9_STATUS","QN9_SALDO","QN9_INDSLD"})

oStruQN8:SetProperty( '*' , MODEL_FIELD_WHEN,{|| !CT212APQN9(oModel,1) })

Return oModel

/*{Protheus.doc}
MenuDef - Crição dos menus
@author Diogo Vieira
@since 31/01/2020
@version P12
@return aRotina - Vetor com as opções da Rotina do Vetor
@project Inovação Controladoria
*/
Static Function ViewDef()

Local oView	   := FwFormView():New()
Local oStruQN8 := FWFormStruct( 2, 'QN8')
Local oStruQN9 := FWFormStruct( 2, 'QN9')

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel('CTBA212')
// Adiciona campo na esturura 
// AddField      (  cIdField ,cOrdem, cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange	,cFolder	,cGroup	,aComboValues	,nMaxLenCombo	,cIniBrow	,lVirtual	,cPictVar, lInsertLine )
oStruQN9:AddField( 'QN9_LEG' ,'01'	,""		 , ""	  ,{}	,''	  , '@BMP' ,NIL		,""		,.F.		,NIL		,NIL	,NIL			,NIL			,NIL		,.T.		,NIL     )

// Remove campo da estrutura
oStruQN9:RemoveField('QN9_IDAP')
oStruQN9:RemoveField('QN9_LOTE')
oStruQN9:RemoveField('QN9_SBLOTE')
oStruQN9:RemoveField('QN9_DOC')
oStruQN9:RemoveField('QN9_TPSALD')
oStruQN9:RemoveField('QN9_MOEDA')
oStruQN9:RemoveField('QN9_DATA')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(Antiga enchoice)
oView:AddField( 'VIEW_QN8', oStruQN8, 'QN8MASTER' )

// Adiciona no nosso View um controle do tipo FormGrid(Antiga newgetdados)
oView:AddGrid(  'VIEW_QN9', oStruQN9, 'QN9DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 25 )
oView:CreateHorizontalBox( 'INFERIOR'	, 75 )

// Relaciona o ID da View com o "box" para exibicão
oView:SetOwnerView( 'VIEW_QN8', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_QN9', 'INFERIOR' )

// Autoincremento
oView:AddIncrementField('QN9DETAIL','QN9_STATUS')

// Ações Relacionadas
oView:AddUserButton( "Atualizar Saldos Visão",'' , {|oView| CT212ATSAL(oModel)  }  )
//oView:AddUserButton( "Estorno",'' , {|oView|  }  )  

Return oView

/*{Protheus.doc} CTBLEGENDA
Define cor da legenda
@author Diogo Vieira 
@since 28/01/2020
@version P12
@return lRet, Logico , Retorno .T. validado  ou .F. não validado
*/
Static Function CTBLEGENDA(oModel)

Local cLegenda  := "BR_AMARELO" // PROCESSSADO
Local cStatus   := ""

oModel := oModel:GetModel( 'QN9DETAIL' )

If oModel:GetOperation() == 3 .Or. oModel:IsCopy()
    cStatus := "1"
Else
    cStatus := QN9->QN9_STATUS 
EndIf

If cStatus == "1" .Or. Empty(cStatus)
    cLegenda := "BR_VERDE"  // A PROCESSAR
ElseIf cStatus == "3"
    cLegenda := "BR_VERMELHO" // ESTORNO   
EndIf

Return cLegenda

/*
{Protheus.doc} CT212LNOK
Faz a validacao da linha 
@author Diogo Vieira
@since 23/01/2020
@version P12
@return lRet, Logico , Retorno .T. validado  ou .F. não validado
*/
Static Function CT212LNOK(oModel)

Local oModel 		:= FWModelActive()
Local oModelQN9		:= oModel:GetModel('QN9DETAIL')
Local oModelQN8		:= oModel:GetModel('QN8MASTER')
Local lRet          := .T.

If oModelQN8:GetValue('QN8_CODDRE') == oModelQN9:GetValue('QN9_CDREIT')
    Help("",1,"CT212VISOK",,STR0004,1,0, , , , , ,{STR0010})
    lRet:=.F.
EndIf 

Return lRet

/*
{Protheus.doc} CT212TDOK
Faz a validacao do modelo 
@author Diogo Vieira
@since 23/01/2020
@version P12
@return lRet, Logico , Retorno .T. validado  ou .F. não validado
*/
Static Function CT212TDOK(oModel)

Local oModel 		:= FWModelActive()
Local oModelQN9		:= oModel:GetModel('QN9DETAIL')
Local oModelQN8		:= oModel:GetModel('QN8MASTER')
Local aArea         := GetArea()
Local aAux      	:= oModelQN8:GetStruct():GetFields()
Local lAltera       := .F.
Local lExist        := .F.
Local lRet          := .T.
Local cAnt          := ""
Local cPos          := "" 
Local nOper	        := oModel:GetOperation()	
Local nTam          := oModelQN9:Length() 
Local nX            := 0

oModel:Activate()

lAltera := nOper == MODEL_OPERATION_UPDATE
aData   := CT212RETDT(oModel)
lRet    := CtbValiDt(3,aData[1][2],.T.)

// Verifico se existe registro processado na grid 
If lRet .And. nTam > 0
    
    lExist := CT212APQN9(oModel,1)

    If lExist .or. lAltera
       dbSelectArea("QN8") 
       QN8->(dbSetOrder(2)) // QN8_FILIAL, QN8_CODDRE, QN8_CALEND, QN8_ANO, QN8_PERIOD, QN8_TPSALD, QN8_MOEDA 
        // Não permito edição da QN8 caso seja alterada
       If MsSeek(xFilial("QN8")+QN8->(oModelQN8:GetValue('QN8_CODDRE'));
                               +QN8->(oModelQN8:GetValue('QN8_CALEND'));
                               +QN8->(oModelQN8:GetValue('QN8_ANO'));
                               +QN8->(oModelQN8:GetValue('QN8_PERIOD'));
                               +QN8->(oModelQN8:GetValue('QN8_TPSALD'));
                               +QN8->(oModelQN8:GetValue('QN8_MOEDA')))
            For nX := 1 to Len(aAux)
                If oModelQN8:GetValue(aAux[nX][3]) <> &("QN8->"+(aAux[nX][3])) .And. ;
                   ("QN8->"+(aAux[nX][3])) <> "QN8->QN8_SALDO" .And. ; // Saldo e indicador de Saldo são atualizados através da CT212ATSAL
                   ("QN8->"+(aAux[nX][3])) <> "QN8->QN8_INDSLD" .And. ; 
                   ("QN8->"+(aAux[nX][3])) <> "QN8->QN8_LOTE" .And. ;  // Lote e Sublote pode ser alterado
                   ("QN8->"+(aAux[nX][3])) <> "QN8->QN8_SBLOTE"

                    cAnt:= &("QN8->"+(aAux[nX][3]))
                    cPos:= oModelQN8:GetValue(aAux[nX][3])
                    lRet := .F.
                    
                    Help("",1,"CTEXISREG",,STR0012,1,0, , , , , ,{})   

                    Exit
                EndIf
            Next nX
       EndIf
    EndIf
EndIf

If nOper == MODEL_OPERATION_INSERT
    dbSelectArea("QN8")
    QN8->(dbSetOrder(2)) // QN8_FILIAL+QN8_CODDRE+QN8_CALEND+QN8_ANO+QN8_PERIOD+QN8_TPSALD+QN8_MOEDA 
    If MsSeek(xFilial("QN8")+QN8->(;
        oModelQN8:GetValue('QN8_CODDRE')+;
        oModelQN8:GetValue('QN8_CALEND')+;
        oModelQN8:GetValue('QN8_ANO')+;
        oModelQN8:GetValue('QN8_PERIOD')+;
        oModelQN8:GetValue('QN8_TPSALD')+;
        oModelQN8:GetValue('QN8_MOEDA')))
        
        lRet:=.F.
        Help("",1,"CTEXISREG",,STR0012,1,0, , , , , ,{})
    EndIf 
ElseIf nOper == MODEL_OPERATION_DELETE 
    If lExist
        lRet:=.F.
        Help("",1,"CTNODELETE",,STR0009+" "+STR0006,1,0, , , , , ,{})
    EndIf    
EndIf

If oModelQN8:GetValue('QN8_CODDRE') == oModelQN9:GetValue('QN9_CDREIT') .And. lRet
    Help("",1,"CT212VISOK",,STR0004,1,0, , , , , ,{STR0010})
    lRet:=.F.
EndIf 

//Preenche informações QN9
If lRet
    CT212APQN9(oModel,6)
Endif   

RestArea(aArea)

Return lRet

/*{Protheus.doc} GATQN9
Carrega Dados QN9 
@author Diogo Vieira
@since 23/01/2020
@version P12
@return .T. 
*/
Function GATQN9()

Local oModel    := FWModelActive()
Local cLote     := oModel:GetValue('QN8MASTER','QN8_LOTE')
Local cSbLote   := oModel:GetValue('QN8MASTER','QN8_SBLOTE')
Local cTpSald   := oModel:GetValue('QN8MASTER','QN8_TPSALD')
Local cMoeda    := oModel:GetValue('QN8MASTER','QN8_MOEDA')
Local nOper     := oModel:GetOperation()

If MODEL_OPERATION_UPDATE == nOper .Or. MODEL_OPERATION_INSERT == nOper
    oModel:LoadValue('QN9DETAIL','QN9_LOTE',cLote)
    oModel:LoadValue('QN9DETAIL','QN9_SBLOTE',cSbLote)
    oModel:LoadValue('QN9DETAIL','QN9_TPSALD',cTpSald)
    oModel:LoadValue('QN9DETAIL','QN9_MOEDA',cMoeda)
EndIf    

Return .T.

/*{Protheus.doc} CT220VLGRD
Validação da Grid
@author Diogo Vieira
@since 23/01/2020
@version P12
@return lRet, Logico , Retorno .T. validado  ou .F. não validado
*/
Static Function CT220VLGRD(oModel)

Local oModel 		:= FWModelActive()
Local lRet          := .T.
Local nOpc          := oModel:GetOperation()

If MODEL_OPERATION_UPDATE == nOpc 
    oModel:GetModel( 'QN9DETAIL' ):SetNoInsertLine( .T. )
    If oModel:GetValue('QN9DETAIL','QN9_STATUS') == "2" .OR. oModel:GetValue('QN9DETAIL','QN9_STATUS') == "3"
        lRet := .F.
        Help("",1,"CT212NODEL",,STR0009,1,0, , , , , ,{STR0013+" "+STR0003}) 
    Else 
        oModel:GetModel( 'QN9DETAIL' ):SetNoInsertLine( .F. )    
    EndIf
EndIf

Return lRet

/*{Protheus.doc} CT212ATSAL
Atualiza saldo das visões
@author Diogo Vieira
@since 14/02/2020
@version P12
@return 
*/
Static Function CT212ATSAL(oModel)

Local oModelQN8		:= oModel:GetModel('QN8MASTER')
Local oModelQN9		:= oModel:GetModel('QN9DETAIL')
Local aData         := {}
Local aBookQN8  	:= CTBSetOf(oModelQN8:GetValue('QN8_CODDRE'))
Local aBookQn9      := {}
Local aSelFil       := {}
Local cArqTmp
local cCodVis       := ""
Local cDc           := "" 
Local cMoeda        := oModelQN8:GetValue('QN8_MOEDA')
Local cTpSald       := oModelQN8:GetValue('QN8_TPSALD')
Local nOperation    := oModel:GetOperation()
Local nSaldo        := 0
Local nX            := 0
Local lRet          := .T.

If nOperation == MODEL_OPERATION_INSERT .or. ! VdSetOfBook( oModelQN8:GetValue('QN8_CODDRE') , .T. )
    lRet := .F.
EndIf

oModel:DeActivate()
oModel:SetOperation(4)
oModel:Activate()

If CT212APQN9(oModel,5) .And. lRet// Existe Pendência de Apuração, logo precisa atualizar saldos

    AADD(aSelFil,oModelQN8:GetValue('QN8_FILIAL'))

    aData:= CT212RETDT(oModel)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta Arquivo Temporario trabalhar saldo QN8     		     ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                CTGerPlan(  oMeter, oText, oDlg, @lEnd, @cArqtmp, aData[1][1]/*dDataIni*/,aData[1][2]/*dDataFim*/;
                            , "", "", "", Repl("Z", 20), "";
                            , Repl("Z", 20), "", Repl("Z", 20);
                            , "", Repl("Z", 20), cMoeda, cTpSald, aBookQN8, Space(2);
                            , Space(20), Repl("Z", 20), Space(30),,,,,.F.,CTOD("  /  /    "),,.F.,,,,,,,,,,,,,,,,,,,,,,,,,;
                            cMoeda, .T., aSelFil,,/*lPlGerSint*/.T.,.T./*lConsSaldo*/,,,,,,,,,,.F./*lDemDRE*/,/*aData[1][1]*//*dFinalA*/)};
                            ,"Buscando Saldos" , "Aguarde" )  // 

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Atualiza Saldos QN8MASTER -> QN8_SALDO					     ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dbSelectArea("cArqTmp")
    dbGoTop()

    If cArqTmp->MOVIMENTO < 0 
        nSaldo := (cArqTmp->MOVIMENTO * -1)
        cDc    := "D"
    ElseiF cArqTmp->MOVIMENTO >= 0 
        nSaldo := cArqTmp->MOVIMENTO
        cDc    := "C"
    EndIf 

    oModel:LoadValue('QN8MASTER','QN8_SALDO',nSaldo)
    oModel:LoadValue('QN8MASTER','QN8_INDSLD',cDc)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Encerro utilização da temporária                             ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("cArqTmp")
    Set Filter To
    dbCloseArea()
    
    If Select("cArqTmp") == 0
        FErase(cArqTmp+GetDBExtension())
        FErase(cArqTmp+OrdBagExt())
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta Arquivo Temporario trabalhar saldo QN9     		     ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If oModelQN9:Length() > 0 
        
        For nX := 1 to oModelQN9:Length()
            oModelQN9:GoLine( nX ) // Registro que irá atualizar os dados
            If oModelQN9:GetValue('QN9_STATUS',nX) == "1" .OR. oModelQN9:GetValue('QN9_STATUS',nX) == "3"
                cCodVis := oModelQN9:GetValue('QN9_CDREIT',nX) 
                aBookQn9	:= CTBSetOf(cCodVis)
                // faz a validação do livro
                If ! VdSetOfBook( cCodVis , .T. )
                    lRet := .F.
                EndIf
                If lRet
                    MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                                CTGerPlan(  oMeter, oText, oDlg, @lEnd, @cArqtmp, aData[1][1]/*dDataIni*/,aData[1][2]/*dDataFim*/;
                                            , "", "", "", Repl("Z", 20), "";
                                            , Repl("Z", 20), "", Repl("Z", 20);
                                            , "", Repl("Z", 20), cMoeda, cTpSald, aBookQN9, Space(2);
                                            , Space(20), Repl("Z", 20), Space(30),,,,,.F.,CTOD("  /  /    "),,.F.,,,,,,,,,,,,,,,,,,,,,,,,,;
                                            cMoeda, .T., aSelFil ,,/*lPlGerSint*/.T.,.T./*lConsSaldo*/,,,,,,,,,,.F./*lDemDRE*/,aData[1][1]/*dFinalA*/) };
                                            ,"Buscando Saldos" , "Aguarde" )

                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Atualiza Saldos QN9DETAIL -> QN9_SALDO					     ³ 
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    dbSelectArea("cArqTmp")
                    dbGoTop()

                    If cArqTmp->MOVIMENTO < 0 
                        nSaldo := (cArqTmp->MOVIMENTO * -1)
                        cDc    := "D"
                    Elseif cArqTmp->MOVIMENTO >= 0
                        nSaldo := cArqTmp->MOVIMENTO
                        cDc    := "C"
                    EndIf 

                    oModel:LoadValue('QN9DETAIL','QN9_SALDO',nSaldo)
                    oModel:LoadValue('QN9DETAIL','QN9_INDSLD',cDc)
                    If oModelQN9:GetValue('QN9_STATUS',nX) == "3"
                        oModel:LoadValue('QN9DETAIL','QN9_STATUS',"1") 
                        oModel:LoadValue('QN9DETAIL','QN9_LEG',"BR_VERDE")
                    EndIf    

                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Encerro utilização da temporária                             ³ 
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    DbSelectArea("cArqTmp")
                    Set Filter To
                    dbCloseArea()
                    
                    If Select("cArqTmp") == 0
                        FErase(cArqTmp+GetDBExtension())
                        FErase(cArqTmp+OrdBagExt())
                    EndIF
                Endif	
            EndIF	
        Next nX

    EndIf  
Else
    If lRet
        Help("",1,"CT212APROC",,STR0013 +" "+ STR0003,1,0, , , , , ,{STR0026}) //'Não Existem Itens com Status: A Processar' //"Se houve estorno atualize os saldos, caso contrário estorne a apuração"
    EndIf     
EndIf

If lRet
    oView := FWViewActive()
    If oView <> Nil	
        oView:Refresh()
    Endif

    oModelQN9:GoLine(1)
EndIf     

Return

/*{Protheus.doc} CT212RETDT
Retorna Data Inicio e Fim do período a processar
@author Diogo Vieira
@since 14/02/2020
@version P12
@return aData
*/
Static Function CT212RETDT(oModel)

Local oModelQN8		:= oModel:GetModel('QN8MASTER')
Local aArea         := GetArea()
local aData         := {}

// Posiciono tabela CTG para pegar informações do calendário
dbSelectArea("CTG")
CTG->(dbSetOrder(1)) //CTG_FILIAL+CTG_CALEND+CTG_EXERC+CTG_PERIOD

// Validação do calendário
If MsSeek(xFilial("CTG")+CTG->(oModelQN8:GetValue('QN8_CALEND')+oModelQN8:GetValue('QN8_ANO')+oModelQN8:GetValue('QN8_PERIOD')))
    Aadd(aData, {CTG->CTG_DTINI,CTG->CTG_DTFIM} )
Else
    //Caso calendário tenha sido excluído!
    Help("",1,"CT212NOCAL",,STR0017,1,0, , , , , ,{STR0018}) // "Calendário não encontrado" // "Verifique se o calendário/período encontra-se cadastrado!"   
EndIf

RestArea(aArea)

Return aData

/*
{Protheus.doc} CT212GERAP
Gera lançamentos CT2
@author Diogo Vieira
@since 14/02/2020
@version P12
@return 
*/
Function CT212GERAP()

Local oModel   := FWLoadModel('CTBA212')
Local oModelQN8     
Local oModelQN9     
Local lExistAp      := .F.
Local aItens        := {}
Local aCab          := {}
Local aArea         := GetArea()
Local cDoc          := "000001"
Local cCtaCred      := ""
Local cCtaDeb       := ""
Local cCtans        := ""
Local cCtdefi       := ""
Local cCtsupe       := ""
Local cLin          := "001"
Local cLote         := ""
Local cSbLote       := ""
local cTpSald       := ""
Local nTotQN9       := 0
Local nX            := 0

Private lMsErroAuto := .F.

oModel:setOperation(4)

oModel:Activate()
oModelQN8     := oModel:GetModel('QN8MASTER')
oModelQN9     := oModel:GetModel('QN9DETAIL')

cLote         := oModelQN8:GetValue('QN8_LOTE')
cSbLote       := oModelQN8:GetValue('QN8_SBLOTE')
cTpSald       := oModelQN8:GetValue('QN8_TPSALD')

CT212APQN9(oModel,3,@nTotQN9)

If nTotQN9 == oModelQN8:GetValue('QN8_SALDO') .And. nTotQN9 <> 0 .And. oModelQN8:GetValue('QN8_SALDO') <> 0
    
    C102ProxDoc(dDatabase,cLote,cSbLote,@cDoc,Nil,Nil,Nil,0)

    BEGIN TRANSACTION
      
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cabeçalho do lançamento a partir da QN8                      ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    
    aCab := { {'DDATALANC' ,dDataBase ,NIL},;
                    {'CLOTE' ,cLote  ,NIL},;
                    {'CSUBLOTE' ,cSbLote ,NIL},;
                    {'CDOC' , cDoc ,NIL},;
                    {'CPADRAO' ,'' ,NIL},;
                    {'NTOTINF' ,0 ,NIL},;
                    {'NTOTINFLOT' ,0 ,NIL} }

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³  Itens do lançamento a partir da QN9                         ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    If oModelQN9:Length() > 0 

        DbSelectArea("CT8")
        CT8->(dbSetOrder(1)) //CT8_FILIAL, CT8_HIST, R_E_C_N_O_, D_E_L_E_T_

        For nX := 1 to oModelQN9:Length()
            oModelQN9:GoLine( nX )
            
            cCtdefi := oModelQN9:GetValue('QN9_CTDEFI', nX)
            cCtans  := oModelQN9:GetValue('QN9_CTANS' , nX)
            cCtsupe := oModelQN9:GetValue('QN9_CTSUPE', nX)

            If oModelQN9:GetValue('QN9_STATUS', nX) == '1' 

                If oModelQN8:GetValue('QN8_INDSLD',nX) == 'D'
                    If oModelQN9:GetValue('QN9_INDSLD',nX) == 'D'
                        cCtaDeb := cCtdefi
                        cCtaCred:= cCtans
                    Else
                        cCtaCred:= cCtdefi
                        cCtaDeb := cCtans
                    EndIf    
                Else
                    If oModelQN9:GetValue('QN9_INDSLD',nX) == 'D'
                        cCtaCred:= cCtans
                        cCtaDeb := cCtsupe
                    Else 
                        cCtaDeb := cCtans
                        cCtaCred:= cCtsupe
                    EndIf     
                EndIf

                MsSeek(xFilial("CT8")+FWFldGet('QN9_CODHIS',nX))
                                            
                aAdd(aItens,{   {'CT2_FILIAL'   ,xFilial("QN8") , NIL},;
                                {'CT2_LINHA'    , cLin          , NIL},;
                                {'CT2_MOEDLC'   , oModelQN9:GetValue('QN9_MOEDA',nX) , NIL},;
                                {'CT2_DC'       ,'3'   , NIL},;
                                {'CT2_DEBITO'   ,cCtaDeb , NIL},;
                                {'CT2_CREDIT'   ,cCtaCred, NIL},;
                                {'CT2_VALOR'    , oModelQN9:GetValue('QN9_SALDO',nX)  , NIL},;
                                {'CT2_ORIGEM'   ,'CTBA212', NIL},;
                                {'CT2_HP'       ,''   , NIL},;
                                {'CT2_HIST'     ,CT8->CT8_DESC, NIL},; 
                                {'CT2_TPSALD'   ,cTpSald, NIL}} )                    
            
                cLin:= Soma1(cLin)
                
                oModel:LoadValue('QN9DETAIL','QN9_STATUS','2')

                lExistAp:=.T.
            EndIf
        Next nX

        CT8->(DbCloseArea())

        MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

        If lExistAp
            If lMsErroAuto
                DisarmTransaction()
                MostraErro()
                Help("",1,"CT212ERRO",,STR0019,1,0, , , , , ,{}) // 'Erro na Apuração!'
            Else
                CT212APQN9(oModel,2,,cDoc)  //Atualiza Status e Doc   
                
                If oModel:VldData()
			        oModel:CommitData()
		        EndIf
				MsgInfo(STR0014) // Apuração realizada com sucesso!
            Endif
        Else
            Help("",1,"CT212APROC",,STR0013+" "+STR0003,1,0, , , , , ,{STR0026}) //'Não Existem Itens com Status: A Processar'//"Se houve estorno atualize os saldos, caso contrário estorne a apuração"
        EndIf
    EndIf        

    END TRANSACTION

Else
     Help("",1,"CT212SALD",,STR0015,1,0, , , , , ,{STR0016}) //'O Saldo Total dos itens a apurar não correpondem com o saldo principal ou estão zerados, Atualize os Saldos ou Revise as Visões'
EndIf 

RestArea(aArea)

Return

/*
{Protheus.doc} CT212APQN9
Atualiza e verifica Itens Percorrendo QN9
@author Diogo Vieira
@since 14/02/2020
@version P12
@return 
@Paramentros  1º oModel
              2º nTOpc = 1 ( Verifica se há apurado )
                 nTOpc = 2 ( GRAVA Status )
                 nTOpc = 3 ( COMPARA SALDOS QN9 / QN8 )
                 nTOpc = 4 ( Estorno Apuração Atualiza DOC, STATUS e DATA )
                 nTOpc = 5 ( Verifica se existe algum item processado )
              3º Total QN9
              4º Existe item apurado?
*/
Static Function CT212APQN9(oModel,nTOpc,nTotQN9,cDoc)

Local oModelQN9   := oModel:GetModel('QN9DETAIL')
Local nX          := 0
Local nTotD       := 0 
Local nTotC       := 0 
Local lRet        := .F.

Default nTotQN9   := 0
Default cDoc      :=""

If oModelQN9:Length() > 0

    For nX := 1 to oModelQN9:Length()
        oModelQN9:GoLine(nX)
        If nTOpc == 1
            If oModelQN9:GetValue('QN9_STATUS',nX) == '2'
                lRet := .T.
                Exit
            EndIf       

        ElseIf nTOpc == 2     
            oModel:LoadValue('QN9DETAIL','QN9_DATA',dDatabase)     
            oModel:LoadValue('QN9DETAIL','QN9_DOC',cDoc)     
            
        ElseIf nTOpc == 3
            If oModelQN9:GetValue('QN9_INDSLD',nX) == 'D' 
                nTotD += oModelQN9:GetValue('QN9_SALDO',nX)
            Else
                nTotC += oModelQN9:GetValue('QN9_SALDO',nX)
            EndIf

        ElseIf nTOpc == 4 // Estorno Apuração 
            oModel:LoadValue('QN9DETAIL','QN9_DATA',CtoD("  /  /    "))
            oModel:LoadValue('QN9DETAIL','QN9_DOC',"")
            oModel:LoadValue('QN9DETAIL','QN9_STATUS',"3")
        
        ElseIf nTOpc == 5
            If oModelQN9:GetValue('QN9_STATUS',nX) == '1' .Or. oModelQN9:GetValue('QN9_STATUS',nX) == '3'
                lRet := .T.
                Exit
            EndIf
        ElseIf nTOpc == 6 // Necessário chamar o gatilho dentro do for
            GATQN9()
        EndIf
    Next nX

    If nTOpc == 3
        nTotQN9:= (nTotD - nTotC)
        nTotQN9:= Iif(nTotQN9 < 0, nTotQN9 * -1 , nTotQN9) 
    EndIf     
EndIf     

Return lRet

/*
{Protheus.doc} CT212EXCAP
Exclusão Apuração por Visões
@author Diogo Vieira
@since 02/03/2020
@version P12
@return 
*/
Function CT212EXCAP()

Local oModel        := FWLoadModel('CTBA212')
Local oModelQN8     
Local oModelQN9     
Local aItens        := {}
Local aCab          := {}

Private lMsErroAuto := .F.

If __lAutomato .Or. MsgYesNo(STR0020, STR0021) //"Deseja prosseguir com a exclusão dos itens apurados?" // "Excluir Apuração?"

    oModel:setOperation(4)
    oModel:Activate()

    oModelQN8     := oModel:GetModel('QN8MASTER')
    oModelQN9     := oModel:GetModel('QN9DETAIL')

    If oModelQN9:GetValue('QN9_STATUS') == '2' // Existe Registro Estornado 

        BEGIN TRANSACTION

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Exclui Todo Documento                                        ³ 
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
        
        aCab := { {'DDATALANC' ,oModelQN9:GetValue('QN9_DATA') ,NIL},;
                        {'CLOTE' ,oModelQN8:GetValue('QN8_LOTE')  ,NIL},;
                        {'CSUBLOTE' ,oModelQN8:GetValue('QN8_SBLOTE') ,NIL},;
                        {'CDOC' , oModelQN9:GetValue('QN9_DOC') ,NIL},;
                        {'CPADRAO' ,'' ,NIL},;
                        {'NTOTINF' ,0 ,NIL},;
                        {'NTOTINFLOT' ,0 ,NIL} }

        MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 5)

        If lMsErroAuto
            DisarmTransaction()
            MostraErro()
            Help("",1,"CT212ERES",,STR0011,1,0, , , , , ,{}) // 'Erro no Exclusão da Apuração!'
        Else
            CT212APQN9(oModel,4) // Retorna Status e Doc Atualiza Status
            
            If oModel:VldData()
                oModel:CommitData()
                MsgInfo(STR0008) // Exclusão realizada com sucesso!
            EndIf 
        Endif

        END TRANSACTION      
    Else
        Help("",1,"CT212NOAPUR",,STR0013 +" "+ STR0001,1,0, , , , , ,{STR0007}) // "Não Existem itens com Status Processado" // "Para Estornar a apuração o status deve ser igual a processado"     
    EndIf    
EndIf 

Return

/*
{Protheus.doc} CT212ESTAP
Estorna Apuração Por Visão
@author Diogo Vieira
@since 02/03/2020
@version P12
@return 
*/
Function CT212ESTAP()

Local oModel        := FWLoadModel('CTBA212')
Local oModelQN8     
Local oModelQN9     
Local aItens        := {}
Local aCab          := {}
Local cCtdefi       := ""
Local cCtans        := ""
Local cCtSupe       := ""
Local cDoc          := "000001"
Local cCtaCred      := ""
Local cCtaDeb       := ""
Local cHist         := ""
Local cLin          := StrZero( 1,Len(CT2->CT2_LINHA) ) //"001"
Local cLote         := ""
Local cSbLote       := ""
local cTpSald       := ""
Local nX            := 0

Private lMsErroAuto := .F.

If __lAutomato .Or. MsgYesNo(STR0022, STR0023) //"Deseja prosseguir com o estorno dos itens apurados?" //"Estornar Apuração?"

    oModel:setOperation(4)

    oModel:Activate()
    oModelQN8     := oModel:GetModel('QN8MASTER')
    oModelQN9     := oModel:GetModel('QN9DETAIL')

    cLote         := oModelQN8:GetValue('QN8_LOTE')
    cSbLote       := oModelQN8:GetValue('QN8_SBLOTE')
    cTpSald       := oModelQN8:GetValue('QN8_TPSALD')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    //? Próximo numero de documento                                  ? 
    //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?    

    C102ProxDoc(dDatabase,cLote,cSbLote,@cDoc,Nil,Nil,Nil,0)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    //? Query Registros Apurados existentes na CT2                   ? 
    //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?    

    CT212Qry(oModelQN9:GetValue('QN9_DATA'),cLote,cSbLote,oModelQN9:GetValue('QN9_DOC'),oModelQN8:GetValue('QN8_TPSALD'))

    BEGIN TRANSACTION

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    //? Cabeçalho do lançamento a partir da QN8                      ? 
    //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?    

    aCab := { {'DDATALANC' ,dDataBase ,NIL},;
                    {'CLOTE' ,cLote  ,NIL},;
                    {'CSUBLOTE' ,cSbLote ,NIL},;
                    {'CDOC' , cDoc ,NIL},;
                    {'CPADRAO' ,'' ,NIL},;
                    {'NTOTINF' ,0 ,NIL},;
                    {'NTOTINFLOT' ,0 ,NIL} }

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    //?  Itens do lançamento a partir da QN9                         ? 
    //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    
    If oModelQN9:Length() > 0 
        For nX := 1 to oModelQN9:Length()
            oModelQN9:GoLine( nX )

            cCtdefi:= oModelQN9:GetValue('QN9_CTDEFI', nX) 
            cCtans := oModelQN9:GetValue('QN9_CTANS' , nX)
            cCtSupe:= oModelQN9:GetValue('QN9_CTSUPE', nX)  
            
            If oModelQN9:GetValue('QN9_STATUS', nX) == '2'
                CT212ES->( dbGotop() )
                    
                cCtaDeb := ""
                cCtaCred:= ""
                cHist   := ""

                While CT212ES->(!Eof())
        
                    If CT212ES->CT2_LINHA == cLin
                    
                        If oModelQN8:GetValue('QN8_INDSLD',nX) == 'D'
                            If oModelQN9:GetValue('QN9_INDSLD',nX) == 'D'
                                cCtaCred:= cCtdefi
                                cCtaDeb := cCtans
                            Else
                                cCtaDeb := cCtdefi
                                cCtaCred:= cCtans
                            EndIf    
                        Else
                            If oModelQN9:GetValue('QN9_INDSLD',nX) == 'D'
                                cCtaDeb := cCtans
                                cCtaCred:= cCtSupe                        
                            Else 
                                cCtaCred := cCtans
                                cCtaDeb:= cCtSupe
                            EndIf     
                        EndIf
                        cHist:= "ESTORNO " + DTOC(dDataBase) + " " + cLote + " " + cSbLote + " " + ALLTRIM(oModelQN9:GetValue('QN9_DOC',nX)) + " " + cLin
                    EndIf
                    CT212ES->(dbSkip())
                EndDo            
            EndIf

            If !Empty(cHist) 
                aAdd(aItens,{   {'CT2_FILIAL'   ,xFilial("QN8") , NIL},;
                                {'CT2_LINHA'    , cLin          , NIL},;
                                {'CT2_MOEDLC'   , oModelQN9:GetValue('QN9_MOEDA',nX) , NIL},;
                                {'CT2_DC'       ,'3'   , NIL},;
                                {'CT2_DEBITO'   ,cCtaDeb , NIL},;
                                {'CT2_CREDIT'   ,cCtaCred, NIL},;
                                {'CT2_VALOR'    , oModelQN9:GetValue('QN9_SALDO',nX)  , NIL},;
                                {'CT2_ORIGEM'   ,'CTBA212', NIL},;
                                {'CT2_HP'       ,''   , NIL},;
                                {'CT2_HIST'     ,cHist, NIL},; 
                                {'CT2_TPSALD'   ,cTpSald, NIL}} )  
            Endif

            cLin:= Soma1(cLin)    
        Next nX
    EndIf

    If Len(aItens) > 0

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Realiza o ESTORNO                                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

        If lMsErroAuto 
            DisarmTransaction()
            MostraErro()
            Help("",1,"CT212ERRO",,STR0024,1,0, , , , , ,{}) // 'Erro no Estorno'
        Else
            CT212APQN9(oModel,4)  // Atualiza Status e Limpa Data e Doc             
            If oModel:VldData()
                oModel:CommitData()
                MsgInfo(STR0025) //"Estorno Realizado com Sucesso"
            EndIf
        EndIf
    Else
        Help("",1,"CT212NOAPUR",,STR0013 +" "+ STR0001,1,0, , , , , ,{STR0007}) // "Não Existem itens com Status Processado" // "Verifique se houve apuração!"
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Encerro tabela temporária                                    ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("CT212ES")
    CT212ES->(dbCloseArea())

    END TRANSACTION

EndIf

Return 

/*
{Protheus.doc} CT212Qry
Query Registros Apurados
@author Diogo Vieira
@since 04/03/2020
@version P12
@return 
*/
Function CT212Qry(dData,cLote,cSbLote,cDoc,cTpSald)

Local cQuery    := ""
Local aArea     := GetArea()

Default dData   := CtoD("  /  /    ")
Default cLote   := ""
Default cSbLote := ""
Default cDoc    := ""
Default cTpSald := ""

DbSelectArea("CT2")
CT2->(DbSetOrder(1)) // CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD 

cQuery := " SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC, CT2_LINHA, CT2_TPSALD "
cQuery += " FROM "+RetSqlName("CT2")
cQuery += " WHERE CT2_FILIAL = 	'"+xFilial("CT2")+"' "
cQuery += " AND CT2_DATA 	 = '"+DToS(dData)+"' "
cQuery += " AND CT2_LOTE 	 = '"+cLote+"' "
cQuery += " AND CT2_SBLOTE = '"+cSbLote+"' "
cQuery += " AND CT2_DOC 	 = '"+cDoc+"' "
cQuery += " AND CT2_TPSALD 	 = '"+cTpSald+"' "
cQuery += " AND CT2_ORIGEM = 'CTBA212'"
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

If Select("CT212ES") > 0
    dbSelectArea("CT212ES")
    dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT212ES",.T.,.T.)
TcSetField("CT212ES","CT2_DATA","D",8					  ,0)
dbSelectArea("CT212ES")

RestArea(aArea)

Return