#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'MATA016.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA016
Saldos Iniciais Cat83


@author Graziele Mendona Paro
@since 01/12/2015

/*/
//-------------------------------------------------------------------
Function MATA016()
    
    Local oBrw := FWmBrowse():New()
    
    If AliasIndic('CDU')
        
        CDU->(DbSetOrder(1))
        oBrw:SetDescription(STR0001) //STR0001 "Saldo Cred ICMS Cat83"
        oBrw:SetAlias('CDU')
        oBrw:SetMenuDef('MATA016')
        oBrw:Activate()
    Else
        Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas')
    EndIF
    
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu


@author Graziele Mendona Paro
@since 01/12/2015

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'VISUALIZAR' ACTION 'VIEWDEF.MATA016' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE 'INCLUIR' ACTION 'VIEWDEF.MATA016' OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE 'ALTERAR' ACTION 'VIEWDEF.MATA016' OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE 'EXCLUIR' ACTION 'VIEWDEF.MATA016' OPERATION 5 ACCESS 0 //Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Graziele Mendona Paro
@since 01/12/2015

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStru  := FWFormStruct(1,'CDU')
Local oModel := MPFormModel():New('MATA016')

    oModel  :=  MPFormModel():New('MATA016MOD',/*bPre*/,/*bPos*/{ || A016TudOk(oModel)},/*bCommit*/, { || A016Cancel(oModel)})
    
    oModel:AddFields('MATA016MOD' ,, oStru )
    
    oModel:SetPrimaryKey({'CDU_FILIAL','CDU_PERIOD', 'CDU_FICHA', 'CDU_PRODUT'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Graziele Mendona Paro
@since 01/12/2015
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    
    Local oModel    := FWLoadModel('MATA016')
    Local oStru     := FWFormStruct(2, "CDU")
    Local oView     := Nil
    Local lMvLogFac := SuperGetMv("MV_LOGFAC",,.F.)
    
    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW" , oStru , 'MATA016MOD')
    
    IF  AliasIndic('F0H')    
        oView:AddUserButton('Facilitador','',{|| SaldoIni(oModel,oView)},'Facilitador') //Busca valores Iniciais de ICMS e Custo
        
        IF lMvLogFac
            oView:AddUserButton('Log','',{|| LogFacilit(oModel) },'Log Facilit.')  
        EndIf    
    EndIf    
     //fecha a tela após clicar no botao confirmar (o padrao era manter a tela aberta mesmo após a edicao)
     oView:SetCloseOnOK({||.T.})
     
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

Validacao se ja existe o registro cadastrado 

@author Graziele Mendona Paro
@since 01/12/2015
/*/
//-------------------------------------------------------------------
Function A016TudOk(oModel)
Local lRet       := .T.
Local nOperation := oModel:GetOperation()
Local cPeriod    := oModel:GetValue('MATA016MOD','CDU_PERIOD')
Local cProdut    := oModel:GetValue('MATA016MOD','CDU_PRODUT')
Local cFicha     := oModel:GetValue('MATA016MOD','CDU_FICHA' )


If Inclui
	If CDU->(dbSeek(xFilial("CDU")+cPeriod+cFicha+cProdut))
		Help(" ", 1, "JAGRAVADO")
		lRet := .F.
	EndIf
EndIf

IF lRet      
    EndTran()
ELSE      
    DisarmTransaction()      
ENDIF 

 
	
Return(lRet)


//-------------------------------------------------------------------
Function A016Cancel()
      
DisarmTransaction()      
    
Return(.T.)



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

Preenchimento automático do Custo e ICMS Inicial

@author Graziele Mendona Paro
@since 01/12/2015
/*/
//-------------------------------------------------------------------
Function SaldoIni(oModel, oView )
    Local lRet     := .T.
    Local oModel        :=  oModel:GetModel('MATA016MOD')
    Local nQuant        :=  oModel:GetValue('CDU_QTDINI')
    Local cFicha        :=  oModel:GetValue('CDU_FICHA')
    Local cProd         :=  oModel:GetValue('CDU_PRODUT')
    Local dPerCDU       :=  oModel:GetValue('CDU_PERIOD')+ '01'
    Local nIcmsNew      :=  0
    Local nCustoNew     :=  0
    Local cAliasSD1     := ''
    Local cAliasCLV     := ''
    Local cAliasLog     := ''
    Local lMvLogFac     := SuperGetMv("MV_LOGFAC",,.F.)

    IF (oModel:GetOperation() == MODEL_OPERATION_UPDATE) .Or. (oModel:GetOperation() == MODEL_OPERATION_INSERT)
        IF oModel:GetOperation() == MODEL_OPERATION_UPDATE
            dbSelectArea("CDU")
            nCustOld        :=  CDU->CDU_CUSINI
            nICMSOld        :=  CDU->CDU_ICMINI
        ElseiF oModel:GetOperation() == MODEL_OPERATION_INSERT
            nCustOld        :=  0
            nICMSOld        :=  0
        EndIf

        IF cFicha$'11|32'

            //Verifica se a quantidade inicial da CDU está maior que zero
            IF nQuant <= 0
                Alert('A quantidade inicial deve ser Maior que Zero. Informe a quantidade inicial!')
                lRet := .F.
            EndIf

            IF lRet
                IF pergunte('MTA016',.T.,'Parâmetros de geração do arquivo')

                    dDataDe       := Dtos(MV_PAR01)
                    dDataAte      := Dtos(MV_PAR02)

                    //Verifica se o periodo na Wizard é Menor do que o periodo da CDU
                    If dPerCDU <= DDATADE .And.  dPerCDU < dDataAte
                        Alert('O Periodo Selecionado deve ser menor do que o informado na CDU!')
                        lRet := .F.
                    //Verifica se o periodo informado na wizard é válido, ou seja, data Inicial Maior do que a Final
                    ElseIf dDataAte < dDataDe
                        Alert('A data Inicial deve ser Maior que a data Final!')
                        lRet := .F.
                    EndIf

                    IF lRet

                        cAliasSD1   :=  GetNextAlias()

                        BeginSql Alias cAliasSD1
                            SELECT   SD1.D1_COD,
                            Sum(SD1.D1_QUANT)  AS QUANT,
                            Sum(SD1.D1_VALICM) AS ICMS,
                            Sum(SD1.D1_CUSTO)  AS CUSTO
                            FROM     %TABLE:SD1% SD1
                            JOIN     %TABLE:SF1% SF1
                            ON       (
                            SF1.F1_FILIAL = %XFILIAL:SF1%
                            AND      SF1.F1_DOC = SD1.D1_DOC
                            AND      SF1.F1_SERIE = SD1.D1_SERIE
                            AND      SF1.F1_FORNECE = SD1.D1_FORNECE
                            AND      SF1.F1_LOJA = SD1.D1_LOJA
                            AND      SF1.F1_TIPO = SD1.D1_TIPO
                            AND      SF1.%NOTDEL%)
                            WHERE    SD1.D1_FILIAL = %XFILIAL:SD1%
                            AND      SD1.D1_DTDIGIT >= %EXP:DDATADE%
                            AND      SD1.D1_DTDIGIT <= %EXP:DDATAATE%
                            AND      SD1.D1_COD = %EXP:cProd%
                            AND      SD1.%NOTDEL%
                            GROUP BY SD1.D1_COD
                        EndSql
                        DbSelectArea(cAliasSD1)

                        If Empty((cAliasSD1)->QUANT) .Or. (nQuant >(cAliasSD1)->QUANT)
                            Alert('Não existe quantidade suficente para comportar o saldo informado na CDU. Reveja o periodo informado!')
                            lRet := .F.
                        Else
                            //Encontra o Custo/Icms Unitário
                            nCustUni := (cAliasSD1)->CUSTO/(cAliasSD1)->QUANT
                            nIcmsUni := (cAliasSD1)->ICMS/(cAliasSD1)->QUANT
                            //Multiplica o Unitário encontrado pela quantidade informada na CDU
                            nIcmsNew := nIcmsUni * nQuant
                            nCustoNew:= nCustUni * nQuant

                            oModel:Activate()
                            oModel:SetValue( 'CDU_QTDINI', nQuant)
                            oModel:SetValue( 'CDU_ICMINI', nIcmsNew)
                            oModel:SetValue( 'CDU_CUSINI', nCustoNew)
                            oView:SetModifield(.T.)

                            (cAliasSD1)->(DbCloseArea())

                            IF lMvLogFac

                                Begin Transaction

                                    cAliasLog   :=  GetNextAlias()
                                    
                                    BeginSql Alias cAliasLog
                                        SELECT  SD1.D1_FILIAL,
                                        SD1.D1_DOC,
                                        SD1.D1_SERIE,
                                        SD1.D1_DTDIGIT,
                                        SD1.D1_ITEM,
                                        SD1.D1_FORNECE,
                                        SD1.D1_COD,
                                        SD1.D1_QUANT,
                                        SD1.D1_VALICM,
                                        SD1.D1_CUSTO,
                                        SD1.R_E_C_N_O_
                                        FROM     %TABLE:SD1% SD1
                                        JOIN     %TABLE:SF1% SF1
                                        ON       (
                                        SF1.F1_FILIAL = %XFILIAL:SF1%
                                        AND      SF1.F1_DOC = SD1.D1_DOC
                                        AND      SF1.F1_SERIE = SD1.D1_SERIE
                                        AND      SF1.F1_FORNECE = SD1.D1_FORNECE
                                        AND      SF1.F1_LOJA = SD1.D1_LOJA
                                        AND      SF1.F1_TIPO = SD1.D1_TIPO
                                        AND      SF1.%NOTDEL%)
                                        WHERE    SD1.D1_FILIAL = %XFILIAL:SD1%
                                        AND      SD1.D1_DTDIGIT >= %EXP:DDATADE%
                                        AND      SD1.D1_DTDIGIT <= %EXP:DDATAATE%
                                        AND      SD1.D1_COD = %EXP:cProd%
                                        AND      SD1.%NOTDEL%
                                    EndSql
                                    DbSelectArea (cAliasLog)

                                    Do While !(cAliasLog)->(Eof ())
                                        DbSelectArea('F0H')
                                        RecLock("F0H",.T.)
                                        F0H->F0H_FILIAL     := xFilial("F0H")
                                        F0H->F0H_FICHA      := cFicha
                                        F0H->F0H_ID         := GetSXENum('F0H','F0H_ID')
                                        F0H->F0H_TABORI     := "SD1"
                                        F0H->F0H_RECTAB     := (cAliasLog)->R_E_C_N_O_
                                        F0H->F0H_NF         := (cAliasLog)->D1_DOC
                                        F0H->F0H_SERIE      := (cAliasLog)->D1_SERIE
                                        F0H->F0H_DATA       := (cAliasLog)->D1_DTDIGIT
                                        F0H->F0H_FORNECE    := (cAliasLog)->D1_FORNECE
                                        F0H->F0H_ITEM       := (cAliasLog)->D1_ITEM
                                        F0H->F0H_PRODUT     := (cAliasLog)->D1_COD
                                        F0H->F0H_QTD        := (cAliasLog)->D1_QUANT
                                        F0H->F0H_ICMS       := (cAliasLog)->D1_VALICM
                                        F0H->F0H_CUSTO      := (cAliasLog)->D1_CUSTO
                                        F0H->F0H_CUSOLD     := nCustOld
                                        F0H->F0H_CUSNEW     := nCustoNew
                                        F0H->F0H_ICMOLD     := nICMSOld
                                        F0H->F0H_ICMNEW     := nIcmsNew
                                        F0H->F0H_LGNOME     := AllTrim(UsrFullName(RetCodUsr()))
                                        F0H->F0H_LGDATA     := FWTimeStamp(2)
                                        F0H->(MsUnLock())
                                        ConfirmSX8()
                                        (cAliasLog)->(DbSkip())
                                    EndDo
                                    (cAliasLog)->(DbCloseArea())

                                End Transaction

                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
            //Para as fichas 2A buscar da tabela de inventário
        ElseIf cFicha == '21'

            IF lRet

                dDataDe       := dPerCDU
                dDataAte      := dtos(LastDate(stod(dDataDe)))
                cAliasCLV   :=  GetNextAlias()

                BeginSql Alias cAliasCLV
                    SELECT  CLV.CLV_PROD,
                    SUM(CLV.CLV_QUANT) AS CLV_QUANT,
                    SUM(CLV.CLV_VALCUS) AS CLV_VALCUS,
                    SUM(CLV.CLV_VALICM) AS CLV_VALICM
                    FROM %TABLE:CLV% CLV
                    WHERE CLV.CLV_FILIAL = %XFILIAL:CLV%
                    AND CLV.CLV_PROD = %EXP:cProd%
                    AND CLV.CLV_PERIOD >=%EXP:DDATADE%
                    AND CLV.CLV_PERIOD <=%EXP:DDATAATE%
                    AND CLV.%NOTDEL%
                    GROUP BY CLV.CLV_PROD
                EndSql
                DbSelectArea (cAliasCLV)

                IF EMPTY((cAliasCLV)->CLV_PROD)
                    Alert('Não foi encontrado informações na tabela CLV para o Produto/Período informado. Reveja o período informado!')
                    lRet := .F.
                Else
                    //Encontra o Custo/Icms
                    nCustoNew := (cAliasCLV)->CLV_VALCUS
                    nIcmsNew := (cAliasCLV)->CLV_VALICM

                    oModel:Activate()
                    oModel:SetValue( 'CDU_ICMINI', nIcmsNew)
                    oModel:SetValue( 'CDU_CUSINI', nCustoNew)
                    oView:SetModifield(.T.)

                    (cAliasCLV)->(DbCloseArea())

                    IF lMvLogFac

                        Begin Transaction

                        cAliasLog   :=  GetNextAlias()

                        BeginSql Alias cAliasLog
                            SELECT  CLV.CLV_PROD,
                            CLV.CLV_QUANT AS CLV_QUANT,
                            CLV.CLV_VALCUS AS CLV_VALCUS,
                            CLV.CLV_VALICM AS CLV_VALICM,
                            CLV.CLV_PERIOD,
                            CLV.R_E_C_N_O_
                            FROM %TABLE:CLV% CLV
                            WHERE CLV.CLV_FILIAL = %XFILIAL:CLV%
                            AND CLV.CLV_PROD = %EXP:cProd%
                            AND CLV.CLV_PERIOD >=%EXP:DDATADE%
                            AND CLV.CLV_PERIOD <=%EXP:DDATAATE%
                            AND CLV.%NOTDEL%
                            ORDER BY CLV.CLV_PROD
                        EndSql
                        DbSelectArea (cAliasLog)

                        Do While !(cAliasLog)->(Eof ())
                            DbSelectArea('F0H')
                            RecLock("F0H",.T.)
                            F0H->F0H_FILIAL     := xFilial("F0H")
                            F0H->F0H_FICHA      := cFicha
                            F0H->F0H_ID         := GetSXENum('F0H','F0H_ID')
                            F0H->F0H_TABORI     := "CLV"
                            F0H->F0H_RECTAB     := (cAliasLog)->R_E_C_N_O_
                            F0H->F0H_NF         := ''
                            F0H->F0H_SERIE      := ''
                            F0H->F0H_DATA       := (cAliasLog)->CLV_PERIOD
                            F0H->F0H_FORNECE    := ''
                            F0H->F0H_ITEM       := ''
                            F0H->F0H_PRODUT     := (cAliasLog)->CLV_PROD
                            F0H->F0H_QTD        := (cAliasLog)->CLV_QUANT
                            F0H->F0H_ICMS       := (cAliasLog)->CLV_VALICM
                            F0H->F0H_CUSTO      := (cAliasLog)->CLV_VALCUS
                            F0H->F0H_CUSOLD     := nCustOld
                            F0H->F0H_CUSNEW     := nCustoNew
                            F0H->F0H_ICMOLD     := nICMSOld
                            F0H->F0H_ICMNEW     := nIcmsNew
                            F0H->F0H_LGNOME     := AllTrim(UsrFullName(RetCodUsr()))
                            F0H->F0H_LGDATA     := FWTimeStamp(2)
                            F0H->(MsUnLock())
                            ConfirmSX8()
                            (cAliasLog)->(DbSkip())
                        EndDo
                        (cAliasLog)->(DbCloseArea())

                        End Transaction

                    EndIf
                EndIf
            EndIf

        Else
            Alert('Ferramenta válida apenas para as fichas 11, 21 e 32!')
            lRet := .F.
        Endif
    Else
        Alert('Ferramenta válida apenas para alteração ou inclusão!')
        lRet := .F.
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LogFacilit
Funcao generica MVC do View
        
Abre a tela do log para o produto posicionado
        
@author Graziele Mendona Paro
@since 01/12/2015
/*/
        
Static Function LogFacilit (oModel,oView)
Local oModel        :=  oModel:GetModel('MATA016MOD')
Local cFicha        :=  oModel:GetValue('CDU_FICHA')
Local cProd         :=  oModel:GetValue('CDU_PRODUT')
Local cFiltro       := ""
        
cFiltro += 'F0H_FILIAL == "' + xFilial('F0H') + '".AND. F0H_FICHA == "' + cFicha + '" .AND. F0H_PRODUT == "' + cProd+ '"'
        
FISA114(cFiltro)
        
Return
