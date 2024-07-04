#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA112.CH" 


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA112
Cadastro MVC para cadastrar as regras de Preenchimento aumtoático do CodLan - Cat83.

@author Graziele Mendonça Paro
@since 22/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Function FISA112()
    
    Local   oBrowse := Nil
    
    IF  AliasIndic("F06")
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F06")
        oBrowse:SetDescription(STR0001) //"Regras da Cat83"
        oBrowse:Activate()
    Else
        Help("",1,"Help","Help",STR0002,1,0)  //"Tabela F06 não cadastrada no sistema!"
    EndIf
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Graziele Mendonça Paro
@since 22/07/2015
@version P11

/*/
//-------------------------------------------------------------------

Static Function MenuDef()
    
    Local aRotina := {}
    
    
    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA112' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA112' OPERATION 3 ACCESS 0 //'Incluir'
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA112' OPERATION 4 ACCESS 0 //'Alterar'
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA112' OPERATION 5 ACCESS 0 //'Excluir'
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA112' OPERATION 9 ACCESS 0 //'Copiar'
    ADD OPTION aRotina TITLE 'Facilitador'  ACTION 'FSA112Auto'	   OPERATION 3 ACCESS 0 // Histótico
    
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Graziele Mendonça Paro
@since 22/07/2015
@version P11ADMIN

/*/
//-------------------------------------------------------------------

Static Function ModelDef()
    
    Local oModel    := Nil
    Local oStructCab := FWFormStruct(1, "F06",)
    
    oModel  :=  MPFormModel():New('FISA112MOD',/*bPre*/,/*bPos*/{ || Valid(oModel)},/*bCommit*/, /*bCancel*/)
    
    oModel:AddFields('FISA112MOD' ,, oStructCab )
    
    oModel:SetPrimaryKey({"F06_FILIAL"},{"F06_REGRA"},{"F06_PRODEL"},{"F06_CODINS"})
    
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Graziele Mendonça Paro
@since 22/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    
    Local oModel     := FWLoadModel( "FISA112" )
    Local oStructCab := FWFormStruct(2, "F06")
    
    Local oView := Nil
    
    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW" , oStructCab , 'FISA112MOD')
    
    oStructCab:AddGroup( 'GRPHIP',STR0008 ,'' , 2 )     //"Hipótese/Operação"
    oStructCab:AddGroup( 'GRPLAN',STR0009 ,'' , 2 )     //"Código de Lançamento"
    oStructCab:AddGroup( "GRPELAB"	,STR0010 , '' , 2 )  //"Produtos"
    
    oStructCab:SetProperty( 'F06_PRODEL', MVC_VIEW_GROUP_NUMBER, 'GRPELAB' )
    oStructCab:SetProperty( 'F06_DPRDEL', MVC_VIEW_GROUP_NUMBER, 'GRPELAB' )
    
    oStructCab:SetProperty( 'F06_CODINS', MVC_VIEW_GROUP_NUMBER, 'GRPELAB' )
    oStructCab:SetProperty( 'F06_DINSUM', MVC_VIEW_GROUP_NUMBER, 'GRPELAB' )
    
    oStructCab:SetProperty( 'F06_REGRA', MVC_VIEW_GROUP_NUMBER, 'GRPHIP' )
    oStructCab:SetProperty( 'F06_DREGRA', MVC_VIEW_GROUP_NUMBER, 'GRPHIP' )
    
    oStructCab:SetProperty( 'F06_CODLAN', MVC_VIEW_GROUP_NUMBER, 'GRPLAN' )
    oStructCab:SetProperty( 'F06_DCODL', MVC_VIEW_GROUP_NUMBER, 'GRPLAN' )
    
Return oView

//-------------------------------------------------------------------

/*/{Protheus.doc} Valid
Validação das informações digitadas.

@author Graziele Mendonça Paro
@since 22/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function Valid(oModel)
    
    Local lRet          :=  .T.
    Local oModel		:=	FWModelActive()
    Local oModelF06		:=	oModel:GetModel('FISA112MOD')
    Local cProEl        :=  oModelF06:GetValue('F06_PRODEL')
    Local cRegra        :=  AllTrim(oModelF06:GetValue('F06_REGRA'))
    Local cInsum        :=  oModelF06:GetValue('F06_CODINS')
    Local cCodlan       :=  oModelF06:GetValue('F06_CODLAN')
    Local nOperation    :=  oModelF06:GetOperation()
    
    IF cRegra $ '01/02/07/08/09/10/11' .and. !Empty(cInsum) .and. ( nOperation == 3 .Or. nOperation == 4)
        lRet	:= .F.
        Help("",1,"Help","Help",STR0011,1,0) //"Para esta hipótese somente deverá ter código do produto elaborado"
    EndIF
    
    dbSelectArea("F06")
    cRegisto    := F06->(RECNO())
    
    If lRet .and. nOperation == 4 // Alterando registro
       
        F06->(DbSetOrder (1))
        If F06->(DbSeek(xFilial("F06")+cRegra+cProEl+cInsum+cCodlan))
             IF F06->(RECNO()) <> cRegisto
                Help("",1,"Help","Help",STR0012,1,0) //Já existe registro com esses dados
                lRet := .F. 
             EndIf   
        EndIF
    EndIF
    
    If lRet .and. nOperation == 3 // Incluindo novo registro
        F06->(DbSetOrder (1))
        If F06->(DbSeek(xFilial("F06")+cRegra+cProEl+cInsum+cCodlan))
                Help("",1,"Help","Help",STR0012,1,0) //Já existe registro com esses dados
                lRet := .F. 
        EndIf        
    EndIF
   
Return lRet

//-------------------------------------------------------------------

/*/{Protheus.doc} FSCODCAT83
Função que irá retornar o código da CAT83 conforme hipótese,
produto elaborado e produto insumo passado. Esta função será
chamada pela equipe de Materiais ao realizar a gravação da
SD3.
O retorno será o código de lançamento que deverá ser gravado

@author Erick Dias
@since 28/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Function FSCODCAT83(cHipotese,cProdElab,cProdInsum)
    
    Local cRet			  := ''
    Default cProdInsum := ''
    
    IF AliasInDic("F06")
    
        cProdElab	:= Padr(cProdElab,TAMSX3("B1_COD")[1])
        cProdInsum	:= Padr(cProdInsum,TAMSX3("B1_COD")[1])
        cHipotese	:= Padr(cHipotese, TamSx3("F06_REGRA")[1])
        
        F06->(DbSetOrder (1))
        If F06->(DbSeek(xFilial("F06")+cHipotese+cProdElab+cProdInsum))
            cRet	:= F06->F06_CODLAN
        EndIF
     ENDIF   
    
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA112Auto
Funcao que chama o pergunte FSA112

@author Graziele Mendonça Paro
@since 21/12/2015
@version P11

/*/
//-------------------------------------------------------------------
Function FSA112Auto()
    Local  lRet:= .F.
    Default nTamRegra := TamSX3("F06_REGRA")[1]
    
    IF pergunte('FSA112',.T.,'Parâmetros de geração do arquivo')
        IF MV_PAR01 == 1
            IF MsgYesNo("ATEÇÃO: Ao utilizar o facilitador, os dados da tabela SG1 serão importadas, para " + CRLF + ;
                    "as seguintes hipoteses: 01,02,03,04 e 05. Que devem ser revisados! O código de " + CRLF + ;
                    "lançamento ficará VAZIO, cabendo ao usuário informar. Deseja Continuar?")
                lRet    :=  .T.
                
                IF lRet
                    Processa({|lEnd| BuscaSG1()},,,.T.)
                EndIf
            EndIf
        ELSEIF  MV_PAR01 == 2
            IF MsgYesNo("ATEÇÃO: Ao utilizar o facilitador, os dados da tabela SB1 serão importadas, para " + CRLF + ;
                    "as seguintes hipoteses: 08 e 09. Que devem ser revisados! O código de " + CRLF + ;
                    "lançamento ficará VAZIO, cabendo ao usuário informar. Deseja Continuar?")
                lRet    :=  .T.
                
                IF lRet
                    BuscaProd(MV_PAR01)
                EndIf
            EndIf
            
        ELSEIF  MV_PAR01 == 3
            IF MsgYesNo("ATEÇÃO: Ao utilizar o facilitador, os dados da tabela SB1 serão importadas, para " + CRLF + ;
                    "as seguintes hipoteses: 10 e 11. Que devem ser revisados! O código de " + CRLF + ;
                    "lançamento ficará VAZIO, cabendo ao usuário informar. Deseja Continuar?")
                lRet    :=  .T.
                
                IF lRet
                    BuscaProd(MV_PAR01)
                EndIf
            EndIf
        EndIf
    ENDIF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}BuscaSG1 - Busca dados da SG1 para importar na F06
Funcao generica MVC com as opcoes de menu

@since 21/12/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function BuscaSG1()
    
    Local aCampos		:= {}
    Local cArqRel		:= ''
    Local cAliasSG1	:= ''
    Local cHip			:= ''
    
    aCampos:={ {"PRODUTO" 	,"C", TamSX3("B1_COD")[1],0},;
        {"TIPO"     	,"C", 2					    ,0}}
    
    cArqRel := CriaTrab(aCampos)
    dbUseArea(.T.,, cArqRel, "TMP" )
    IndRegua("TMP",cArqRel,"PRODUTO+TIPO")
    
    IncProc('Buscando Produto Acabado')
    
    
    cAliasSG1   :=  GetNextAlias()
    BeginSql Alias cAliasSG1
        
        SELECT DISTINCT G1_COD
        FROM   %TABLE:SG1% SG1
        WHERE  SG1.G1_FILIAL=%XFILIAL:SG1%
        AND SG1.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG1.G1_FIM >= %EXP:DTOS(dDataBase)%
        AND SG1.%NOTDEL%
        AND G1_COD NOT IN(SELECT G1_COMP
        FROM   %TABLE:SG1% AS SG12
        WHERE SG12.G1_FILIAL=%XFILIAL:SG1%
        AND SG12.%NOTDEL%
        AND SG12.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG12.G1_FIM >= %EXP:DTOS(dDataBase)%)
        
    EndSql
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbGoTop ())
    F06->(DbSetOrder (1))
    Do While !(cAliasSG1)->(Eof ())
        
        //Busca Produtos Acabados
        Reclock("TMP",.T.)
        TMP->PRODUTO		:= (cAliasSG1)->G1_COD
        TMP->TIPO			:= 'PA'
        TMP->(MsUnLock())
        
        If !F06->(DbSeek(xFilial("F06")+PadR('01', nTamRegra, '')+(cAliasSG1)->G1_COD+space(Len((cAliasSG1)->G1_COD))))
            Reclock("F06",.T.)
            F06->F06_FILIAL			:= xFilial('F06')
            F06->F06_REGRA			:= PadR('01', nTamRegra, '')
            F06->F06_PRODEL			:= (cAliasSG1)->G1_COD
            F06->(MsUnLock())
        EndIf
        
        (cAliasSG1)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbCloseArea())
    
    
    //Busca Produto Intermediário
    IncProc('Buscando Produto Intermediário')
    cAliasSG1   :=  GetNextAlias()
    BeginSql Alias cAliasSG1
        
        SELECT DISTINCT G1_COD
        FROM   %TABLE:SG1% SG1
        WHERE  SG1.G1_FILIAL=%XFILIAL:SG1%
        AND SG1.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG1.G1_FIM >= %EXP:DTOS(dDataBase)%
        AND SG1.%NOTDEL%
        AND G1_COD IN(SELECT G1_COMP
        FROM   %TABLE:SG1% AS SG12
        WHERE SG12.G1_FILIAL=%XFILIAL:SG1%
        AND SG12.%NOTDEL%
        AND SG12.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG12.G1_FIM >= %EXP:DTOS(dDataBase)%)
    EndSql
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbGoTop ())
    
    Do While !(cAliasSG1)->(Eof ())
        
        //Aqui irá processar todos Produtos Intermediários
        Reclock("TMP",.T.)
        TMP->PRODUTO		:= (cAliasSG1)->G1_COD
        TMP->TIPO			:= 'PI'
        TMP->(MsUnLock())
        
        //Incluindo o Apontamento de PI
        If !F06->(DbSeek(xFilial("F06")+PadR('02', nTamRegra, '')+(cAliasSG1)->G1_COD+space(Len((cAliasSG1)->G1_COD))))
            Reclock("F06",.T.)
            F06->F06_FILIAL         := xFilial('F06')
            F06->F06_REGRA          := PadR('02', nTamRegra, '')
            F06->F06_PRODEL         := (cAliasSG1)->G1_COD
            F06->(MsUnLock())
        EndIf
        
        (cAliasSG1)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbCloseArea())
    
    IncProc('Buscando Matéria Prima')
    
    cAliasSG1    :=  GetNextAlias()
    BeginSql Alias cAliasSG1
        
        SELECT DISTINCT G1_COMP
        FROM   %TABLE:SG1% SG1
        WHERE  SG1.G1_FILIAL=%XFILIAL:SG1%
        AND SG1.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG1.G1_FIM >= %EXP:DTOS(dDataBase)%
        AND SG1.%NOTDEL%
        AND G1_COMP NOT IN(SELECT G1_COD
        FROM   %TABLE:SG1% AS SG12
        WHERE SG12.G1_FILIAL=%XFILIAL:SG1%
        AND SG12.%NOTDEL%
        AND SG12.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG12.G1_FIM >= %EXP:DTOS(dDataBase)%)
        
    EndSql
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbGoTop ())
    
    Do While !(cAliasSG1)->(Eof ())
        
        //Aqui irá processar todas as matérias primas/Insumos
        Reclock("TMP",.T.)
        TMP->PRODUTO		:= (cAliasSG1)->G1_COMP
        TMP->TIPO			:= 'MP'
        TMP->(MsUnLock())
        
        (cAliasSG1)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbCloseArea())
    
    
    //Irá gravar na tabela de regras o produto PA
    IncProc('Processando Regras PA x PI x MP')
    
    //Produto acabado e insumos
    cAliasSG1   :=  GetNextAlias()
    BeginSql Alias cAliasSG1
        
        SELECT G1_COD,
        G1_COMP
        FROM   %TABLE:SG1% SG1
        WHERE  SG1.G1_FILIAL=%XFILIAL:SG1%
        AND SG1.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG1.G1_FIM >= %EXP:DTOS(dDataBase)%
        AND SG1.%NOTDEL%
        AND G1_COD NOT IN(SELECT G1_COMP
        FROM   %TABLE:SG1% AS SG12
        WHERE SG12.G1_FILIAL=%XFILIAL:SG1%
        AND SG12.%NOTDEL%
        AND SG12.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG12.G1_FIM >= %EXP:DTOS(dDataBase)%)
        
    EndSql
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbGoTop ())
    
    Do While !(cAliasSG1)->(Eof ())
        
        IF TMP->(MsSeek((cAliasSG1)->G1_COMP))
            
            //Se for MP
            IF TMP->TIPO == 'MP'
                //Trata a requisição
                cHip := PadR('03', nTamRegra, '')
                If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSG1)->G1_COD+(cAliasSG1)->G1_COMP))
                    Reclock("F06",.T.)
                    F06->F06_FILIAL         := xFilial('F06')
                    F06->F06_REGRA          := cHip
                    F06->F06_PRODEL         := (cAliasSG1)->G1_COD
                    F06->F06_CODINS         := (cAliasSG1)->G1_COMP
                    F06->(MsUnLock())
                EndIf
                //Trata devolução de Insumo para produção
                cHip := PadR('05', nTamRegra, '')
                If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSG1)->G1_COD+(cAliasSG1)->G1_COMP))
                    Reclock("F06",.T.)
                    F06->F06_FILIAL         := xFilial('F06')
                    F06->F06_REGRA          := cHip
                    F06->F06_PRODEL         := (cAliasSG1)->G1_COD
                    F06->F06_CODINS         := (cAliasSG1)->G1_COMP
                    F06->(MsUnLock())
                EndIf
                //Se for PI
            ElseIf   TMP->TIPO == 'PI'
                //Trata a requisição do PI - Que nada mais é do que a requisição de um insumo*/
                cHip := PadR('04', nTamRegra, '')
                If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSG1)->G1_COD+(cAliasSG1)->G1_COMP))
                    Reclock("F06",.T.)
                    F06->F06_FILIAL         := xFilial('F06')
                    F06->F06_REGRA          := cHip
                    F06->F06_PRODEL         := (cAliasSG1)->G1_COD
                    F06->F06_CODINS         := (cAliasSG1)->G1_COMP
                    F06->(MsUnLock())
                EndIf
            EndIf
            
        EndIf
        
        (cAliasSG1)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbCloseArea())
    
    //Processa PI e seus respectivos insumos
    //Irá gravar na tabela de regras o produto PA
    IncProc('Processando Regras PI x MP')
    
    
    //Processa PI e seus respectivos insumos
    cAliasSG1   :=  GetNextAlias()
    BeginSql Alias cAliasSG1
        
        SELECT G1_COD,
        G1_COMP
        FROM    %TABLE:SG1% SG1
        WHERE  SG1.G1_FILIAL=%XFILIAL:SG1%
        AND SG1.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG1.%NOTDEL%
        AND SG1.G1_FIM >= %EXP:DTOS(dDataBase)%
        AND G1_COD IN(SELECT G1_COMP
        FROM   %TABLE:SG1% AS SG12
        WHERE SG12.G1_FILIAL=%XFILIAL:SG1%
        AND SG12.%NOTDEL%
        AND SG12.G1_INI <= %EXP:DTOS(dDataBase)%
        AND SG12.G1_FIM >= %EXP:DTOS(dDataBase)% )
        
        
    EndSql
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbGoTop ())
    
    Do While !(cAliasSG1)->(Eof ())
        
        IF TMP->(MsSeek((cAliasSG1)->G1_COMP))
            //Se for MP
            IF TMP->TIPO == 'MP'
                //Trata a requisição
                cHip := PadR('03', nTamRegra, '')
                If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSG1)->G1_COD+(cAliasSG1)->G1_COMP))
                    Reclock("F06",.T.)
                    F06->F06_FILIAL         := xFilial('F06')
                    F06->F06_REGRA          := cHip
                    F06->F06_PRODEL         := (cAliasSG1)->G1_COD
                    F06->F06_CODINS         := (cAliasSG1)->G1_COMP
                    F06->(MsUnLock())
                EndIf
                //Trata devolução de Insumo para produção
                cHip := PadR('05', nTamRegra, '')
                If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSG1)->G1_COD+(cAliasSG1)->G1_COMP))
                    Reclock("F06",.T.)
                    F06->F06_FILIAL         := xFilial('F06')
                    F06->F06_REGRA          := cHip
                    F06->F06_PRODEL         := (cAliasSG1)->G1_COD
                    F06->F06_CODINS         := (cAliasSG1)->G1_COMP
                    F06->(MsUnLock())
                EndIf
                //Se for PI
            ElseIf   TMP->TIPO == 'PI'
                //Trata a requisição do PI - Que nada mais é do que a requisição de um insumo*/
                cHip := PadR('04', nTamRegra, '')
                If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSG1)->G1_COD+(cAliasSG1)->G1_COMP))
                    Reclock("F06",.T.)
                    F06->F06_FILIAL         := xFilial('F06')
                    F06->F06_REGRA          := cHip
                    F06->F06_PRODEL         := (cAliasSG1)->G1_COD
                    F06->F06_CODINS         := (cAliasSG1)->G1_COMP
                    F06->(MsUnLock())
                EndIf
            Endif
        EndIF
        
        (cAliasSG1)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSG1)
    (cAliasSG1)->(DbCloseArea())
    
    F06->(DBGOTOP())
    
    TMP->(DbCloseArea())
    FErase(cArqRel+GetDBExtension())
    FErase(cArqRel+IndexExt())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}BuscaProd - Busca dados da SB1 para importar na F06
Funcao generica MVC com as opcoes de menu

@author Graziele Mendonça Paro
@since 21/12/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function BuscaProd(cTipo)
    
    cAliasSB1   :=  GetNextAlias()
    BeginSql Alias cAliasSB1
        
        SELECT SB1.B1_FILIAL,
        SB1.B1_COD
        FROM   %TABLE:SB1% SB1
        WHERE  SB1.B1_FILIAL = %XFILIAL:SB1%
        AND SB1.B1_MSBLQL <> '1'
        AND SB1.B1_FANTASM = ''
        AND SB1.%NOTDEL%
        ORDER  BY SB1.B1_FILIAL,
        SB1.B1_COD
        
        
    EndSql
    DbSelectArea (cAliasSB1)
    (cAliasSB1)->(DbGoTop ())
    
    
    Do While !(cAliasSB1)->(Eof ())
        //Transferência entre produtos
        IF cTipo == 2
            
            //saída
            cHip := PadR('08', nTamRegra, '')
            If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSB1)->B1_COD))
                Reclock("F06",.T.)
                F06->F06_FILIAL         := xFilial('F06')
                F06->F06_REGRA          := cHip
                F06->F06_PRODEL         := (cAliasSB1)->B1_COD
                F06->(MsUnLock())
            EndIf
            //Entrada
            cHip := PadR('09', nTamRegra, '')
            If !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSB1)->B1_COD))
                Reclock("F06",.T.)
                F06->F06_FILIAL         := xFilial('F06')
                F06->F06_REGRA          := cHip
                F06->F06_PRODEL         := (cAliasSB1)->B1_COD
                F06->(MsUnLock())
            EndIf
            //Inventário
        ElseIf cTipo == 3
            //Para mais
            cHip := PadR('10', nTamRegra, '')
            If  !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSB1)->B1_COD))
                Reclock("F06",.T.)
                F06->F06_FILIAL         := xFilial('F06')
                F06->F06_REGRA          := cHip
                F06->F06_PRODEL         := (cAliasSB1)->B1_COD
                F06->(MsUnLock())
            EndIf
            //Para menos
            cHip := PadR('11', nTamRegra, '')
            If  !F06->(DbSeek(xFilial("F06")+cHip+(cAliasSB1)->B1_COD))
                Reclock("F06",.T.)
                F06->F06_FILIAL         := xFilial('F06')
                F06->F06_REGRA          := cHip
                F06->F06_PRODEL         := (cAliasSB1)->B1_COD
                F06->(MsUnLock())
            EndIf

        EndIf
        (cAliasSB1)->(DbSkip ())
    EndDo
    
    
    DbSelectArea (cAliasSB1)
    (cAliasSB1)->(DbCloseArea())
    
Return
