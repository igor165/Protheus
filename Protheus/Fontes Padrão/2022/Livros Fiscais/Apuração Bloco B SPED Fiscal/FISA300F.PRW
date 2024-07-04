#Include "FISA300F.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300F()

Rotina para auxiliar a geração dos títulos da apuração de ISS

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300F(cIdF1P, dDtRef, cOpc)

Local nRet	    := 0
Local lExibeCon := .F.

Private lMsErroAuto := .F.
Private aApurMun    := {}
Private oApurISS    := APURISS():New()
Private cOpcao      := cOpc //1=Somente Título;2=Título+Contabilização;3=Somente Contabilização
    
//Faz carga dos valores da apuração
oApurISS:LoadApur(cIdF1P)

BEGIN TRANSACTION

//Processa informações da F1R, para que o usuário possa realizar eventuais ajustes antes de gravar os títulos
ProcF1R(dDtRef)

//Executa a View da F1R
nRet	:= FWExecView(STR0001 ,'FISA300F', MODEL_OPERATION_UPDATE,,, { || OnClose() },,,{ || OnExit() })	 //"Títulos da Apuração"

If nRet == 0 //Clicou no confirmar         

    //Se está contabilizando perguntará para o usuário se deseja visualizar a contabilização
    If cOpc $ "2/3"
        Pergunte("FISA300F", .F.) 
        lExibeCon   := MV_PAR01 == 1
    EndIf
    
    //Gravação dos títulos/Contabilizações
    FwMsgRun(,{|oSay|GrvTitCtb(cIdF1P, lExibeCon) },STR0002,"")	     //"Gerando os títulos/contabilizações "
    
    //TODO Exibir os títulos gerados

ElseIF nRet == 1
	//Clicou no cancelar
	DisarmTransaction()	
EndIF

END TRANSACTION

oApurISS:Clear()

//Destroi objeto
FreeObj(oApurISS)
oApurISS := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 19/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que carrega o modelo já criado no FISA300A

@author Erick G Dias
@since 19/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FwLoadModel("FISA300A")

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias
@since 19/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados
Local oModel := FWLoadModel("FISA300A")

//Criação da estrutura de dados utilizada na interface
Local oMunicipio    := FWFormStruct(2, "F1N")
Local oTitulo       := FWFormStruct(2, "F1R")
Local oView         := Nil

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formulários para interface
oView:AddGrid('VIEW_MUNICIPIO'   , oMunicipio , 'FISA300AMUNICIPIO' )
oView:AddGrid('VIEW_TITULO'      , oTitulo    , 'FISA300ATITULO'   )

//Retira da view os campos de ID
oMunicipio:RemoveField('F1N_ID')
oMunicipio:RemoveField('F1N_IDAPUR')
oMunicipio:RemoveField('F1N_DEDPRP')
oMunicipio:RemoveField('F1N_DEDSUB')
oMunicipio:RemoveField('F1N_DEDUNI')
oMunicipio:RemoveField('F1N_RECUNI')
oMunicipio:RemoveField('F1N_QTDUNI')
oMunicipio:RemoveField('F1N_VLFUNI')
oMunicipio:RemoveField('F1N_STATUS')

oTitulo:RemoveField( 'F1R_ID')
oTitulo:RemoveField( 'F1R_IDAPUR')
oTitulo:RemoveField( 'F1R_NUM')
oTitulo:RemoveField( 'F1R_PARC')
oTitulo:RemoveField( 'F1R_TIPO')
oTitulo:RemoveField( 'F1R_STATUS')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox('SUPERIOR', 50)
oView:CreateHorizontalBox('INFERIOR', 50)

//O formulário da interface será colocado dentro do container
oView:SetOwnerView('VIEW_MUNICIPIO' , 'SUPERIOR')
oView:SetOwnerView('VIEW_TITULO'    , 'INFERIOR')

//Colocando título do formulário
oView:EnableTitleView('VIEW_MUNICIPIO' , STR0003) //"Municípios"
oView:EnableTitleView('VIEW_TITULO'    , STR0004) //"Títulos por Município"

//Desabilita opção de ordenação do Grid
oView:SetViewProperty( "*", "GRIDNOORDER")

//Adiciona o botão de FSA300DLEG
oView:AddUserButton( STR0005, 'CLIPS', {|oView| FSA300DLEG()} ) //'Legenda'

//Adiciona o botão para visualizar o título gerado
oView:AddUserButton( STR0006, 'CLIPS', {|oView| FSA300FTIT()} ) //'Visualizar Título'

oView:AddUserButton( STR0007, 'CLIPS', {|oView| pergunte("FISA300F", .T.)} ) //'Configurações'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} OnClose

Função que fará o tratamento na confirmação da tela dos títulos

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function OnClose()

Local lRet	    := .F.
Local oSay      := Nil

lRet := ApMsgYesNo(STR0008) //"Confirma operação?"

If lRet   
    //Atualização da tela para permitir gravação caso não tenha nenhuma alteração do cliente
    lRet    := FSA300FATU()       

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OnExit

Função que faz validação ao clicar no botão fechar.

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function OnExit()

Local lRet:= .F.

lRet := ApMsgYesNo(STR0009) //"Deseja realmente sair?"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumTit

Função que retorna o número do título sequencial

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GetNumTit()

Local cRet      := ""
Local nTamNF    := TamSx3("FT_NFISCAL")[1]

If SX5->(dbSeek(xFilial("SX5")+"53"+"ISS"))
    cRet := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
    RecLock("SX5",.F.)
    SX5->X5_DESCRI  := cRet
    SX5->X5_DESCSPA := cRet
    SX5->X5_DESCENG := cRet
    SX5->(MsUnlock())
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDtVencto

Função que processa a data de vencimento do título de ISS conforme definição 
do cadastro de município. Para utilização desta função é necessário
posicionar a CC2 primeiro. Se não houver configuração dadata de vencimento
no cadstro de município a função retornará data de vencimento vazia.

@author Erick G. Dias
@since 24/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GetDtVencto(cUf, cCodMun, dDtRef)

Local dNextMonth    := StoD("//")
Local nQtdUtil      := 0
Local dDtVencto     := StoD("//")

//Verifica se o dia de pagamento foi digitado pelo usuário
If !Empty(cUf) .AND. !Empty(cCodMun) .AND. CC2->(DbSeek(xFilial("CC2") + cUf + cCodMun)) .and. CC2->CC2_DTRECO > 0    
    
    //Considera o próximo mês da apuração para o vencimento do título
    dNextMonth    := MonthSum(dDtRef,1)

    //-----------------------------------
    //Considera quantidade de dias uteis
    //-----------------------------------
    If CC2->CC2_TPDIA == '1'
    
        //Inicia com primeiro dia do mês
        dDtVencto   := FirstDay(dNextMonth)
        
        //Laço até obter a quantidade de dias uteis
        Do While nQtdUtil < CC2->CC2_DTRECO
            
            //Verifica se a data é válida, já psotegarndo caso o dia não seja util
            dDtVencto := DataValida(dDtVencto, .T.)                                                
            
            //Incrementa quantidade de dias uteis
            nQtdUtil++
            
            //Verifica se atingiu a quantidade de dias uteis informado pelo cliente
            If nQtdUtil == CC2->CC2_DTRECO
                //Sai do laço pois já obteve a data
                exit
            Else
                //Soma mais um dia pois ainda não atingiu a quantidade de dia uteis
                dDtVencto   := DaySum(dDtVencto,1)
            EndIF            

        EndDo

    //-----------------------------------
    //Considera dia fixo pora vencimento
    //-----------------------------------
    ElseIf CC2->CC2_TPDIA == '2'        

        //Calculando a data de vencimento
        dDtVencto := CtoD( StrZero(CC2->CC2_DTRECO, 2) + "/" + month2str(dNextMonth) + "/" + Year2str(dNextMonth) )

        // Validando data calculada, caso o dia não seja util, será postergado para o próximo dia útil
        dDtVencto := DataValida(dDtVencto, .T.)

    EndIF

EndIf

Return dDtVencto

//-------------------------------------------------------------------
/*/{Protheus.doc} GetForTit

Função que retorna as informações de fornecedores para geração do título
no contas a receber.

@author Erick G. Dias
@since 24/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GetForTit(cUf, cCodMun, cFornec, cLoja, cNaturez)

//Posiciona no detalhamento do município
If !Empty(cUf) .AND. !Empty(cCodMun) .AND. F1T->(DbSeek(xFilial("F1T") + cUf + cCodMun))
    
    //Considera as informações da tabela F1T
    cFornec  := F1T->F1T_FORN
    cLoja    := F1T->F1T_LOJA
    cNaturez := F1T->F1T_NATURE       

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcTit

Função irá criar objeto para gravação da tabela F1R
para, com sugestões de data de vencimento do título, participante
e natureza financeira, conforme cadastro de município.

@author Erick G. Dias
@since 24/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ProcTit(oMunic, dDtRef, cTpImp, nValor)

Local cNumTit   := Criavar("E2_NUM")
Local cPrefix   := Criavar("E2_PREFIXO")
Local cParcela  := Criavar("E2_PARCELA")
Local cTipo     := Criavar("E2_TIPO")
Local cFornec   := Criavar("E2_FORNECE")
Local cLoja     := Criavar("E2_LOJA")
Local cNaturez  := Criavar("E2_NATUREZ")
Local dVencto   := StoD("  /  /    ")
Local oObjTit   := APURISSTIT():New()

//--------------------------------
//Busca Próximo número de título
//--------------------------------
cNumTit := GetNumTit()

//----------------------
//Tipo do Título será TX
//----------------------
cTipo := "TX"+Space(TamSx3("E2_TIPO")[1]-2)

//-------------------------------------
//Obtem o fornecedor, loja e natureza
//-------------------------------------
GetForTit( oMunic:getUF(), oMunic:getMunic(), @cFornec, @cLoja, @cNaturez)

//------------------------------
//Obtem o vencimento do título
//------------------------------
dVencto := GetDtVencto( oMunic:getUF(), oMunic:getMunic(), dDtRef)

//--------------------------
//Popula objeto de título
//--------------------------
oObjTit:setTpImp(cTpImp)
oObjTit:setPrefixo(cPrefix)
oObjTit:setNumTit(cNumTit)
oObjTit:setParcela(cParcela)
oObjTit:setTipo(cTipo)
oObjTit:setFornec(cFornec)
oObjTit:setLoja(cLoja)
oObjTit:setNaturez(cNaturez)
oObjTit:setValor(nValor)
oObjTit:setDtVenc(dVencto)

//Adiciona o título para objeto de apuração de ISS
oMunic:addTitulo(oObjTit)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTitISS

Método que faz a gravação dos títulos no contas a pagar

@author Erick G. Dias
@since 25/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GeraTitISS(oTitulo, lProcContab, cTitGerado, cPrefixo, cCodLp, lExibeCon)

Local lRet  := .F.
Local aSe2  := {  { "E2_FILIAL"   ,xFilial("SE2")     , NIL },;
               { "E2_PREFIXO"  , oTitulo:getPrefixo() , NIL },;
               { "E2_NUM"      , oTitulo:getNumTit()  , NIL },;
               { "E2_TITORIG"  , oTitulo:getNumTit()  , NIL },;
               { "E2_PARCELA"  , oTitulo:getParcela() , NIL },;
               { "E2_TIPO"     , oTitulo:getTipo()    , NIL },;
               { "E2_NATUREZ"  , oTitulo:getNaturez() , NIL },;
               { "E2_FORNECE"  , oTitulo:getFornec()  , NIL },;
               { "E2_LOJA"     , oTitulo:getLoja()    , NIL },;
               { "E2_EMISSAO"  , dDataBase            , NIL },;
               { "E2_VENCTO"   , oTitulo:getDtVenc()  , NIL },;
               { "E2_HIST"     , STR0010    , NIL },; //"Apuração de ISS"
               { "E2_ORIGEM"   , "FISA300"            , NIL },;
               { "E2_VALOR"    , oTitulo:getValor()   , NIL }}

If !Empty(oTitulo:getNaturez()) .AND. !Empty(oTitulo:getFornec()) .AND. !Empty(oTitulo:getLoja()) .AND. !Empty(oTitulo:getDtVenc())
    
    MSExecAuto({|a,b,c,d,e,f,g,h| FINA050(a,b,c,d,e,f,g,h)}, aSe2, Nil, MODEL_OPERATION_INSERT, /*bExecuta*/, /*aDadosBco*/, /*lExibeLanc*/, /*lOnline*/, /*aDadosCTB*/)
        
    //Indica que gerou o título
    lRet    := !lMsErroAuto

    //Armazena o número do título gerado
    cTitGerado  += oTitulo:getNumTit() + '/'
    cPrefixo    += oTitulo:getPrefixo() + '/'

    If lMsErroAuto    
        MostraErro()

    ElseIF cOpcao == "2"
        //Faz contabolização do título gerado
        lProcContab := FSA300TCONT(cCodLp, SE2->(RECNO()), lExibeCon)
    EndIf    

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF1R

Função que processará as informações necessárias para gravação da tabela 
F1R

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ProcF1R(dDtRef)

Local nX        := 0
Local nY        := 0
Local lSaveApur := .F.
Local aTitulos  := {}
Local lExistePro := .F.
Local lExisteUni := .F.

//Faz carga dos valores por município
aApurMun := oApurISS:getApurMun()

//Laço nos municípios
For nX  := 1 to Len(aApurMun)   
    
    lExistePro := .F.    
    lExisteUni := .F.

    //Obtem a lista de F1R do município
    aTitulos    := aApurMun[nX]:getTitulos()

    For nY:=1 to Len(aTitulos)
        
        //Verifica se já existe F1R, e para qual tipo de ISS a F1R já foi gerada.
        If aTitulos[nY]:getTpImp() == "01"
            //Já existe F1R gravada para Iss Próprio
            lExistePro   := .T.        
        ElseIf aTitulos[nY]:getTpImp() == "03"
            //Já existe F1R gravada para Iss Uniprofissional
            lExisteUni   := .T.            
        EndiF        

    Next nY    

    //Verifica se existe valor a recolher do ISS Próprio
    If !lExistePro .AND. aApurMun[nX]:getISSProp() > 0
        ProcTit(aApurMun[nX], dDtRef, "01", aApurMun[nX]:getISSProp())
        lSaveApur   := .T.
    EndIF    
    
    //Verifica se existe valor a recolher da Sociedade Uniprofissional
    If !lExisteUni .AND. aApurMun[nX]:getISSUni() > 0        
        ProcTit(aApurMun[nX], dDtRef, "03", aApurMun[nX]:getISSUni())
        lSaveApur   := .T.
    EndIF        

Next nX

//Salva se necessário as alterações da F1R para exibir o grid par ausuário editar.
If lSaveApur
    oApurISS:SaveApur()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvTitCtb

Função que fará a gravação dos títulos no contas a pagar 

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GrvTitCtb(cIdF1P, lExibeCon)

Local nX            := 0
Local nY            := 0
Local aTitulos      := {}
Local lSaveApur     := .F.
Local lProcContab   := .F.
Local cFiltroBrw    := ""
Local cTipo         := "TX"+Space(TamSx3("E2_TIPO")[1]-2)
Local cTitGerado    := ""
Local cPrefixo      := ""
Local cCodLp        := "750" //Estou utilizando o código 750 para manter compatibilidade com a contabilização da apuração de ISS MATA954
Local cChaveTit     := ""
Local lApurado       := .F.
Local lTitulo       := .F.
Local lCont         := .F.

//Faz carga dos valores da apuração
oApurISS:LoadApur(cIdF1P)

//Faz carga dos valores por município
aApurMun := oApurISS:getApurMun()

//Laço nos municípios
For nX  := 1 to Len(aApurMun)    
    
    //Carrega as informações gravadas na F1R
    aApurMun[nX]:loadTitulos()
    
    //Obtem a lista de F1R do município
    aTitulos    := aApurMun[nX]:getTitulos()

    lApurado    := .F.
    lTitulo     := .F.
    lCont       := .F.

    //Laço nas informações da F1R
    For nY  := 1 to Len(aTitulos)
        
        //-------------------------------------------
        //Gravação dos títulos e/ou contabilização
        //-------------------------------------------
        IF aTitulos[nY]:getStatus() == "1" .And. cOpcao $ "1/2"
            
            //Faz gravação dos títulos
            GeraTitISS(aTitulos[nY], @lProcContab, @cTitGerado, @cPrefixo, cCodLp, lExibeCon)            
    
            //Atualizando o Status da Apuração
            IF cOpcao == "2"
                //Status que gerou título e contabilizou                
                aTitulos[nY]:setStatus('3')

            Else
                //Status que somente gerou título                
                aTitulos[nY]:setStatus('2')
            EndIF
            
            lSaveApur   := .T.        
        //-------------------------------------------
        //Somente Contabilização
        //-------------------------------------------
        ElseIf aTitulos[nY]:getStatus() == "2" .AND. cOpcao == "3"
            //Posiciona o título e realiza a contabilização
            cChaveTit	:= xFilial("SE2") + ;
                        aTitulos[nY]:getPrefixo() + ;
                        aTitulos[nY]:getNumTit() + ;
                        aTitulos[nY]:getParcela() + ;
                        aTitulos[nY]:getTipo() + ;
                        aTitulos[nY]:getFornec() + ;
                        aTitulos[nY]:getLoja()

            //Posiciona no título e realiza a contabilização
            If !Empty(cChaveTit) .And.  SE2->(MsSeek(cChaveTit)) .And. FSA300TCONT(cCodLp, SE2->(RECNO()))                                                
                //Status que contabilizou título                
                aTitulos[nY]:setStatus("3")
                lSaveApur   := .T.
            EndIF
            
        EndIF

        //Verificação para atualizar status do município
        IF aTitulos[nY]:getStatus() == "1"
            //Somente apurado
            lApurado    := .T.
        ElseIF aTitulos[nY]:getStatus() == "2"
            //Somente título
            lTitulo := .T.
        ElseIf aTitulos[nY]:getStatus() == "3"
            //Título e contabilização
            lCont := .T.
        EndIF
        
    Next nY

    //Tratamento para atualizar a legenda da F1N
    If (!lTitulo .AND. !lCont .AND. lApurado) .OR. (!lTitulo .AND. !lCont .AND. !lApurado)
        //Todas F1R somente apuraram
        aApurMun[nX]:setStatus("1")
    ElseIF lTitulo .AND. !lCont .AND. !lApurado
        //Todas F1R somente geraram título
        aApurMun[nX]:setStatus("2")
    ElseIF !lTitulo .AND. lCont .AND. !lApurado
        //Todas F1R geraram título e contabilização
        aApurMun[nX]:setStatus("3")    
    Else    
        //Títulos/Contabilização parcial
        aApurMun[nX]:setStatus("4")
    Endif

Next nX       

//Salva se necessário apuração para atualizar o Status dos municípios que geraram títulos
If lSaveApur    
    oApurISS:SaveApur()
EndIF

If !Empty(cTitGerado)
    //Monta filtro para exibir os títulos gerados pela apuração
    cFiltroBrw	:= ' E2_FILIAL = "' + xFilial("SE2") + '" .AND. '
    cFiltroBrw	+= ' E2_TIPO == "' + cTipo + '" .AND. '
    cFiltroBrw	+= ' E2_ORIGEM == "FISA300" .AND. '
    cFiltroBrw	+= ' E2_NUM $ "' +  cTitGerado + '"'    
        
    FISA300I("SE2", STR0011, cFiltroBrw) //"Título Gerado"

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300FATU

Funçãoi auxiliar para edição do modelo para permitir salvar caso
não tenha nenhuma alteração realizada pelo cliente, ele acatou
todas as sugestões de geração do título.

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FSA300FATU()

Local oModel    := FWModelActive()
Local oMunic  	:= oModel:GetModel('FISA300AMUNICIPIO')
Local oTitulo	:= oModel:GetModel('FISA300ATITULO')
Local oView 	:= FWViewActive()
Local cVal      := ""
Local nX        := 0
Local nY        := 0
Local lRet      := .T.

//Este trecho é necessário, pois preciso alterar o modelo para o botão confirmar fechar a tela.
//Como o modelo possui tabela temporária, preciso alterar o modelo manualmente
If oTitulo:Length() > 0
    cVal	:= oTitulo:GetValue("F1R_PREFIX",1)
    oTitulo:SetValue('F1R_PREFIX', "." )
    oview:Refresh( 'VIEW_TITULO' )
    oTitulo:SetValue('F1R_PREFIX', cVal )
    oview:Refresh( 'VIEW_TITULO' )
EndIF

//Validação das linhas dos municípios e títulos
For nX:=1 to oMunic:Length()
    
    //Posiciona linha do município
    oMunic:GoLine( nX )

    //Verifico se não está deletada
    IF !oMunic:IsDeleted()

        //Percorre linhas dos títulos do município posicionado
        For nY := 1 to oTitulo:Length()
        
            //Posiciona a linha do título
            oTitulo:GoLine( nY )

            //Verifico se não está deletada e se os campos obrigatórios estáo preenchidos
            IF !oTitulo:IsDeleted() .AND. (Empty(oTitulo:GetValue("F1R_FORN")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_LOJA")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_VENCTO")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_NATURE")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_VALOR")))
                lRet := .F.
                Help( ,, 'Help',, STR0012 + oMunic:GetValue("F1N_MUN") + " !" , 1, 0 ) //"Existem informações obrigatórioas não preenchidas na seção de Títulos por Município em: "
            EndIF

            //Se Aqui alguma informação obrigatório está faltando, não pode permitir gravação
            If !lRet
                Exit
            EndIF

        Next nY
    EndIF

    //Se Aqui alguma informação obrigatório está faltando, não pode permitir gravação
    If !lRet
        Exit
    EndIF

Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300DLEG

Função apra gerar legenda

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300DLEG() 
      
Local aLegenda := {} 

aAdd( aLegenda, { "BR_VERMELHO" , STR0013 })  //"Não gerado"
aAdd( aLegenda, { "BR_VERDE"    , STR0014 })  //"Título gerado"
aAdd( aLegenda, { "BR_AZUL"     , STR0015 })  //"Título gerado e contabilizado"
aAdd( aLegenda, { "BR_AMARELO"  , STR0016 })  //"Títulos/Contabilização parcial"

BrwLegenda( STR0005, STR0005, aLegenda )  //'Legenda'

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300FTIT

Função que exibe o título gerado conforme F1R posicionada

@author Erick G. Dias
@since 02/07/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FSA300FTIT()

Local oModel        :=	FWModelActive()
Local oTitulo	    := oModel:GetModel('FISA300ATITULO')
Local cFiltroBrw    := ""

If !Empty(oTitulo:GetValue("F1R_NUM"))
    //Monta filtro para exibir os títulos gerados pela apuração
    cFiltroBrw	:= ' E2_FILIAL = "' + xFilial("SE2") + '" .AND. '
    cFiltroBrw	+= ' E2_TIPO == "' + "TX"+Space(TamSx3("E2_TIPO")[1]-2) + '" .AND. '
    cFiltroBrw	+= ' E2_ORIGEM == "FISA300" .AND. '
    cFiltroBrw	+= ' E2_NUM == "' +  oTitulo:GetValue("F1R_NUM") + '"'    
        
    FISA300I("SE2", STR0011, cFiltroBrw) //"Título Gerado"

EndIF

Return
 