#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA903.CH'

Static aResultGIM   := {}
Static aPlanExec    := {}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA903()
Cadastro de Apuração de contrato
@sample		GTPA903()
@return		oBrowse  Retorna o Cadastro de Apuração de contrato
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GTPA903()
Local oBrowse	:= Nil
Local cMsgErro  := ''

If G900VldDic(@cMsgErro)
    oBrowse:=FWMBrowse():New()
    oBrowse:SetAlias("GQR")
    oBrowse:SetDescription(STR0001)		// "Apuração de contrato"
    If GQR->(FieldPos("GQR_STATUS")) > 0
        oBrowse:AddLegend('GQR_STATUS == "1"',"YELLOW","Em apuração")
        oBrowse:AddLegend('GQR_STATUS == "2"',"GREEN" ,"Apuração efetivada")
        oBrowse:AddLegend('GQR_STATUS == "3"',"RED"	  ,"Erro na geração")
    EndIf
    If !(IsBlind())
        oBrowse:Activate()
    EndIf
Else
    FwAlertHelp(cMsgErro, STR0029,)	// "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina"
Endif 

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel - Retorna o Modelo de dados 
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	    := nil
Local oStruGQR	    := FWFormStruct(1,'GQR')//Apuração de contrato
Local oStruG9W	    := FWFormStruct(1,'G9W')//Orcamentos apuracao contratos 
Local oStruG54      := FWFormStruct(1,'G54')//Totais Linha Apuracao Orcament
Local oStruGYN	    := FwFormStruct(1,'GYN')//Viagens 
Local bCommit       := {|oModel| G903Commit(oModel)}                 

oModel := MPFormModel():New('GTPA903',,{|oModel|TP903TudOK(oModel)})

SetStruct('M',oStruGQR, oStruG9W, oStruG54, oStruGYN)

//campos do cabeçalho
oModel:AddFields('GQRMASTER',/*cOwner*/,oStruGQR)
// Orçamentos de contrato
oModel:AddGrid("G9WDETAIL","GQRMASTER",oStruG9W)

//Totais por Linha da Apuracao Orcamento de Contrato
oModel:AddGrid("G54DETAIL","G9WDETAIL",oStruG54)

//Viagens por linha - Listagem
oModel:AddGrid('GYNDETAIL','G54DETAIL',oStruGYN)
	
oModel:GetModel("G54DETAIL" ):SetOptional( .T. )
oModel:GetModel("G54DETAIL" ):SetDescription( STR0002 ) //"Totalizador Linha"

If AliasInDic("G9W") .AND. AliasInDic("GQR")
    oModel:SetRelation( 'G9WDETAIL', { { 'G9W_FILIAL', 'xFilial( "GQR" )' }, { 'G9W_CODGQR'	, 'GQR_CODIGO' } } , G9W->(IndexKey(1))) 
EndIf
If AliasInDic("G9W") .AND. AliasInDic("G54")
    oModel:SetRelation('G54DETAIL', {{'G54_FILIAL', 'xFilial("G9W")'},;
                                    {'G54_CODGQR', 'G9W_CODGQR'} ,;  
                                    {'G54_NUMGY0','G9W_NUMGY0'},;
                                    {'G54_REVISA','G9W_REVISA'}}, G54->(IndexKey(1)))
EndIf
If AliasInDic("G54")
    oModel:SetRelation( 'GYNDETAIL', { { 'GYN_FILIAL', 'xFilial("G54")' },;
                                    { 'GYN_APUCON', 'G54_CODGQR' },;
                                    { 'GYN_LINCOD', 'G54_CODGI2'}} , GYN->(IndexKey(9))) 
EndIf
//Permite grid sem dados
oModel:GetModel('GYNDETAIL'):SetOptional(.T.)
oModel:GetModel('GYNDETAIL'):SetOnlyQuery(.T.)

oModel:SetDescription(STR0001)
oModel:GetModel('GYNDETAIL'):SetDescription(STR0003)	// "Viagens por Linha"
oModel:SetPrimaryKey({"GQR_FILIAL","GQR_CODIGO"})

oModel:GetModel('G9WDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel('G54DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('GYNDETAIL'):SetNoUpdateLine(.T.)
oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)

oModel:SetVldActivate({|oModel| G903VldAct(oModel)})

oModel:SetCommit(bCommit)

Return oModel
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
@sample		ViewDef()
@return		oView - Retorna a View
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	 := ModelDef() 
Local oView		 := FWFormView():New()
Local oStruGQR	 := FWFormStruct(2, 'GQR')
Local oStruG9W	 := FWFormStruct(2, 'G9W')
Local oStruG54   := FWFormStruct(2, 'G54')
Local oStruGYN	 := FWFormStruct(2, 'GYN')

SetStruct('V',oStruGQR, oStruG9W, oStruG54, oStruGYN)

oView:SetModel(oModel)

oView:AddField('VIEW_GQR', oStruGQR,'GQRMASTER')
oView:AddGRID('VIEW_G9W', oStruG9W, 'G9WDETAIL')
oView:AddGRID('VIEW_G54', oStruG54, "G54DETAIL")
//oView:AddGRID('VIEW_GYN', oStruGYN, 'GYNDETAIL')

oView:CreateHorizontalBox('HEADER', 25)
oView:CreateHorizontalBox('GRIDCONTRATO', 35)
oView:CreateHorizontalBox('GRIDLINHA', 40)

oView:SetOwnerView('VIEW_GQR','HEADER')
oView:SetOwnerView('VIEW_G9W','GRIDCONTRATO')
oView:SetOwnerView('VIEW_G54','GRIDLINHA')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_GQR',STR0001)//'Apuração de contrato'
oView:EnableTitleView('VIEW_G9W','Contratos')//'Contratos'
oView:EnableTitleView('VIEW_G54',STR0004)//'Totais por Linha')

oView:SetViewProperty('VIEW_G9W', 'CHANGELINE', {{|oView, oViewId| LineChange(oView, oViewId)}})
oView:SetViewProperty('VIEW_G54', 'CHANGELINE', {{|oView, oViewId| LineChange(oView, oViewId)}})

oView:AddUserButton('Consulta Viagens', "", {|oModel| ConsultaVia(oModel)} )   // "Consulta Viagens"

Return( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@sample		MenuDef()
@return		aRotina - Array de opções do menu
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA903'    OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0006    ACTION 'GTPA903Ger'         OPERATION 3 ACCESS 0 // Gerar Apuração
ADD OPTION aRotina TITLE STR0030    ACTION 'VIEWDEF.GTPA903'    OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.GTPA903'    OPERATION 5 ACCESS 0 // Excluir
ADD OPTION aRotina TITLE STR0031    ACTION 'GTPA903B'           OPERATION 4 ACCESS 0 // Gerar Medição
ADD OPTION aRotina TITLE STR0032    ACTION 'GTPA903C'           OPERATION 4 ACCESS 0 // Estornar Medição
If FindFunction( 'GTPA903D' )
    ADD OPTION aRotina TITLE STR0038    ACTION 'GTPA903D()'         OPERATION 4 ACCESS 0 // Checklist Documentos da Apuração
EndIf

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP903TudOK()
Validação do Modelo 
@sample	TP903TudOK(oModel)
@param		oModel   Modelo de Dados
@return	lRet - Retorna a validacao do modelo de dados (TudoOK)
@author	Inovação
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP903TudOK(oModel)
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GQR", oModel:GetModel('GQRMASTER'):GetValue("GQR_CODIGO")))
		Help( ,, 'Help',"TP903TdOK", STR0008, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

If !ValidMarks(oModel)
    lRet := .F.
    oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","ValidMarks", STR0033) //"Selecione ao menos um contrato e uma linha para finalizar a apuração"
Endif


/*If GQR->(FieldPos("GQR_VLACRE")) > 0 .And. GQR->(FieldPos("GQR_VLDESC")) > 0
    If (oModel:GetModel('GQRMASTER'):GetValue('GQR_VLACRE') > 0 .Or.;
        oModel:GetModel('GQRMASTER'):GetValue('GQR_VLDESC') > 0) .And.;
        AllTrim(oModel:GetModel('GQRMASTER'):GetValue('GQR_MOTIVO')) == ''

        oModel:GetModel():SetErrorMessage(oModel:GetId(),'GQR_MOTIVO',oModel:GetId(),"GQR_MOTIVO", STR0025, STR0026, STR0027) //"Motivo","Motivo do desconto e/ou abatimento não informado", "Informe um motivo"
        lRet := .F.    
    Endif
Endif*/

Return lRet

/*/{Protheus.doc} GTPA903Ger
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function GTPA903Ger()

If !(IsBlind())
    If Pergunte("GTPA903A",.T.)
        FwMsgRun(, {|| GTP903Proc() }, , STR0034) //'Gerando apuração, aguarde...'
    Endif
Else
    GTP903Proc()
Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP903Proc()
Gera Apuração
@sample	GTP903Proc()
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTP903Proc()
Local lRet      := .T.
Local cAliasAUX := ''
Local cAliasGYN := ''
Local oModel    := Nil
Local aAreaGYN	:= GYN->(GetArea())
Local cApuracao := ''
Local cOrcContr := ''
Local cAuxG9W   := ''
Local cAuxG54   := ''
Local cSelect   := '%%'
Local cWhere    := '%%'
Local cWhereGy0 := '%%'
Local cInner    := '%%'
Local cExtCmp   := '%%'
Local cCmpGYD   := '%%'

cAliasAUX := GetNextAlias()

IF (LEN(ALLTRIM(MV_PAR03)) > 0 .OR. LEN(ALLTRIM(MV_PAR04)) > 0)
    cOrcContr := "%GY0_NUMERO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'%"
else
    cOrcContr := "%GY0_NUMERO > '0'%"
EndIf

If !(EMPTY(MV_PAR05)) .OR. !(EMPTY(MV_PAR06))
    cWhere := "% GYN_DTFIM BETWEEN '" + DtoS(MV_PAR05) + "'  AND '" + DtoS(MV_PAR06) + "' AND %"
EndIf

If GY0->(FieldPos("GY0_REVISA")) > 0
    cSelect := '%GY0_REVISA,%'
    cInner  := '% AND GYD_REVISA = GY0_REVISA %'
EndIf

If GY0->(FieldPos("GY0_ATIVO")) > 0
    cWhereGy0 := "% GY0_ATIVO = '1' AND %"
EndIf

If GYD->(FieldPos("GYD_IDPLEX")) > 0 .AND. GYD->(FieldPos("GYD_PLEXTR")) > 0 .AND. GYD->(FieldPos("GYD_IDPLCO")) > 0 .AND. GYD->(FieldPos("GYD_PLCONV")) > 0
    cCmpGYD := "% GYD_IDPLEX,GYD_PLEXTR,GYD_IDPLCO,GYD_PLCONV, %"
Else
    cCmpGYD := "% '','','','', %"
EndIf

If GYN->(FieldPos("GYN_EXTCMP")) > 0
	cExtCmp := "% AND GYN_EXTCMP = " + "'T'"  + "%"
        BeginSql alias cAliasAUX

        SELECT  GY0_NUMERO,
                %Exp:cSelect%
                GY0_CODCN9,
                GY0_CLIENT,
                GY0_LOJACL,
                GY0_TPCTO,
                GY0_TIPPLA,
                GY0_TABPRC,
                GYD_PRODUT,
                GYD_PRONOT,
                GYD_CODGI2,
                GYD_CODGYD,
                GYD_VLRTOT,
                GYD_VLREXT,
                GYD_PRECON,
                GYD_PREEXT,
                GYD_VLRACO,
                %Exp:cCmpGYD%
                SB1.B1_DESC,
                SB1NT.B1_DESC PRODNT,
                GYN_FILIAL,
                GYN_CODIGO,
                GYN_TIPO,
                GYN_LINCOD,
                GYN_DTINI,
                GYN_HRINI,
                GYN_DTFIM,
                GYN_HRFIM,
                GYN_LOCORI,
                GYN_LOCDES,
                GYN_APUCON,
                GI1ORI.GI1_DESCRI DSCORI,
                GI1DES.GI1_DESCRI DSCDES,
                GYN.R_E_C_N_O_
        FROM %Table:GY0% GY0
        INNER JOIN %Table:GYD% GYD ON GYD_FILIAL=GY0_FILIAL 
            AND GYD_NUMERO = GY0_NUMERO 
            %Exp:cInner%
            AND GYD.%NotDel%
        INNER JOIN %Table:GI2% GI2 ON GI2_FILIAL=GYD_FILIAL 
            AND GI2_COD=GYD_CODGI2 
            AND GI2.%NotDel%
        INNER JOIN %Table:GYN% GYN ON GYN_FILIAL=GI2_FILIAL 
            AND GYN_LINCOD=GI2_COD 
            AND GYN.%NotDel%
        INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
            AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
            AND GI1ORI.%NotDel%
        INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
            AND GI1DES.GI1_COD = GYN.GYN_LOCDES
            AND GI1DES.%NotDel%
        INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = GYD.GYD_PRODUT
            AND SB1.%NotDel%
        INNER JOIN %Table:SB1% SB1NT ON SB1NT.B1_FILIAL = %xFilial:SB1%
            AND SB1NT.B1_COD = GYD.GYD_PRONOT
            AND SB1NT.%NotDel%
        WHERE
            GY0.%NotDel% AND
            GY0_FILIAL=%xFilial:GY0% AND
            GY0_CLIENT = %Exp:MV_PAR01% AND
            GY0_LOJACL = %Exp:MV_PAR02% AND
            %Exp:cOrcContr% AND 
            %Exp:cWhere%
            GYN_FINAL = '1' AND 
            GYN_APUCON =''	AND 
            %Exp:cWhereGy0%
            GYN_TIPO = '3' 

    UNION 
        SELECT   GY0_NUMERO,
            %Exp:cSelect%
            GY0_CODCN9,
            GY0_CLIENT,
            GY0_LOJACL,
            GY0_TPCTO,
            GY0_TIPPLA,
            GY0_TABPRC,
            GY0_PRDEXT,
            GY0_PRONOT,
            '',
            GYD_CODGYD,
            0,
            GY0_VLRACO,
            '',
            GY0_PREEXT,
            0,
            GY0_IDPLCO,
            GY0_PLCONV,
            '',
            '',
            SB1.B1_DESC,
            SB1NT.B1_DESC PRODNT,
            GYN_FILIAL,
            GYN_CODIGO,
            GYN_TIPO,
            GYN_LINCOD,
            GYN_DTINI,
            GYN_HRINI,
            GYN_DTFIM,
            GYN_HRFIM,
            GYN_LOCORI,
            GYN_LOCDES,
            GYN_APUCON,
            GI1ORI.GI1_DESCRI DSCORI,
            GI1DES.GI1_DESCRI DSCDES,
            GYN.R_E_C_N_O_
        FROM %Table:GY0% GY0
        INNER JOIN %Table:GYD% GYD ON GYD_FILIAL=GY0_FILIAL 
            AND GYD_NUMERO = GY0_NUMERO 
            %Exp:cInner%
            AND GYD.%NotDel%
        INNER JOIN %Table:GYN% GYN ON GYN_FILIAL= %xFilial:GY0%
            AND GYN_CODGY0=GY0_NUMERO 
            AND GYN.%NotDel%
        INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
            AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
            AND GI1ORI.%NotDel%
        INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
            AND GI1DES.GI1_COD = GYN.GYN_LOCDES
            AND GI1DES.%NotDel%
        INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = GY0.GY0_PRODUT
            AND SB1.%NotDel%
        INNER JOIN %Table:SB1% SB1NT ON SB1NT.B1_FILIAL = %xFilial:SB1%
            AND SB1NT.B1_COD = GY0.GY0_PRONOT
            AND SB1NT.%NotDel%
        WHERE
            GY0.%NotDel% AND
            GY0_FILIAL=%xFilial:GY0% AND
            GY0_CLIENT = %Exp:MV_PAR01% AND
            GY0_LOJACL = %Exp:MV_PAR02% AND
            %Exp:cOrcContr% AND 
            %Exp:cWhere%
            GYN_FINAL = '1' AND 
            GYN_APUCON =''	AND 
            %Exp:cWhereGy0%
            GYN_TIPO = '2'  
            %Exp:cExtCmp%

        ORDER BY GY0.GY0_NUMERO, GYN.GYN_LINCOD

    EndSql	
Else
    BeginSql alias cAliasAUX

        SELECT  GY0_NUMERO,
            %Exp:cSelect%
            GY0_CODCN9,
            GY0_CLIENT,
            GY0_LOJACL,
            GY0_TPCTO,
            GY0_TIPPLA,
            GY0_TABPRC,
            GYD_PRODUT,
            GYD_PRONOT,
            GYD_CODGI2,
            GYD_CODGYD,
            GYD_VLRTOT,
            GYD_VLREXT,
            GYD_PRECON,
            GYD_PREEXT,
            GYD_VLRACO,
            %Exp:cCmpGYD%
            SB1.B1_DESC,
            SB1NT.B1_DESC PRODNT,
            GYN_FILIAL,
            GYN_CODIGO,
            GYN_TIPO,
            GYN_LINCOD,
            GYN_DTINI,
            GYN_HRINI,
            GYN_DTFIM,
            GYN_HRFIM,
            GYN_LOCORI,
            GYN_LOCDES,
            GYN_APUCON,
            GI1ORI.GI1_DESCRI DSCORI,
            GI1DES.GI1_DESCRI DSCDES,
            GYN.R_E_C_N_O_
        FROM %Table:GY0% GY0
        INNER JOIN %Table:GYD% GYD ON GYD_FILIAL=GY0_FILIAL 
            AND GYD_NUMERO = GY0_NUMERO 
            %Exp:cInner%
            AND GYD.%NotDel%
        INNER JOIN %Table:GI2% GI2 ON GI2_FILIAL=GYD_FILIAL 
            AND GI2_COD=GYD_CODGI2 
            AND GI2.%NotDel%
        INNER JOIN %Table:GYN% GYN ON GYN_FILIAL=GI2_FILIAL 
            AND GYN_LINCOD=GI2_COD 
            AND GYN.%NotDel%
        INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
            AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
            AND GI1ORI.%NotDel%
        INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
            AND GI1DES.GI1_COD = GYN.GYN_LOCDES
            AND GI1DES.%NotDel%
        INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = GYD.GYD_PRODUT
            AND SB1.%NotDel%
        INNER JOIN %Table:SB1% SB1NT ON SB1NT.B1_FILIAL = %xFilial:SB1%
            AND SB1NT.B1_COD = GYD.GYD_PRONOT
            AND SB1NT.%NotDel%
        WHERE
            GY0.%NotDel% AND
            GY0_FILIAL=%xFilial:GY0% AND
            GY0_CLIENT = %Exp:MV_PAR01% AND
            GY0_LOJACL = %Exp:MV_PAR02% AND
            %Exp:cOrcContr% AND 
            %Exp:cWhere%
            GYN_FINAL = '1' AND 
            GYN_APUCON =''	AND 
            %Exp:cWhereGy0%
            GYN_TIPO = '3' 

        ORDER BY GY0.GY0_NUMERO, GYN.GYN_LINCOD

    EndSql	
EndIf

If !(cAliasAUX)->(Eof())

    oModel	  := FwLoadModel("GTPA903")
    oModel:SetOperation(MODEL_OPERATION_INSERT)

    oModel:GetModel('G9WDETAIL'):SetNoInsertLine(.F.)
    oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.F.)
    oModel:GetModel('G54DETAIL'):SetNoInsertLine(.F.)
    oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.F.)
    oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.F.)
    oModel:GetModel('GYNDETAIL'):SetNoUpdateLine(.F.)
    oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.F.)

    If oModel:Activate()
    
        oModel:GetModel('GQRMASTER'):LoadValue('GQR_CLIENT',	(cAliasAUX)->GY0_CLIENT)
        oModel:GetModel('GQRMASTER'):LoadValue('GQR_LOJA',      AllTrim((cAliasAUX)->GY0_LOJACL))
        oModel:GetModel('GQRMASTER'):LoadValue('GQR_DTINIA',	MV_PAR05)
        oModel:GetModel('GQRMASTER'):LoadValue('GQR_DTFINA',	MV_PAR06)
        
        cApuracao := oModel:GetModel('GQRMASTER'):GetValue('GQR_CODIGO')

        oModel:GetModel('GQRMASTER'):LoadValue('GQR_USUAPU', __cUserId)

    Else
        Return .F.
    Endif

    While (cAliasAUX)->(!Eof())
        
        If cAuxG9W != (cAliasAUX)->GY0_NUMERO
            If !oModel:GetModel('G9WDETAIL'):SeekLine({{'G9W_NUMGY0',(cAliasAUX)->GY0_NUMERO}},,.T.)
                cAuxG9W := (cAliasAUX)->GY0_NUMERO

                If !(oModel:GetModel('G9WDETAIL'):IsEmpty())
                    oModel:GetModel('G9WDETAIL'):AddLine()
                Endif

                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_MARK', .T.)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_CODGQR', cApuracao)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_CONTRA', (cAliasAUX)->GY0_CODCN9)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_NUMGY0', (cAliasAUX)->GY0_NUMERO)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_REVISA', (cAliasAUX)->GY0_REVISA)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_DTINIA', MV_PAR05)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TPCTO' , (cAliasAUX)->GY0_TPCTO) 
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TIPPLA', (cAliasAUX)->GY0_TIPPLA)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TABPRC', (cAliasAUX)->GY0_TABPRC)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTAPU', 0)
              
            Endif
        Endif  

        If cAuxG54 != (cAliasAUX)->GYN_LINCOD

            cAuxG54 := (cAliasAUX)->GYN_LINCOD

            If !(oModel:GetModel('G54DETAIL'):IsEmpty())
                oModel:GetModel('G54DETAIL'):AddLine()
            Endif

            oModel:GetModel('G54DETAIL'):LoadValue('G54_MARK', .T.)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_NUMGY0', (cAliasAUX)->GY0_NUMERO)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_REVISA', (cAliasAUX)->GY0_REVISA)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_CODGQR', cApuracao)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_PRODUT', (cAliasAUX)->GYD_PRODUT)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_PRODNT', (cAliasAUX)->GYD_PRONOT)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_DPRONT', (cAliasAUX)->PRODNT)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_DPROD' , (cAliasAUX)->B1_DESC)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_CODGYD', (cAliasAUX)->GYD_CODGYD)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_CODGI2', (cAliasAUX)->GYD_CODGI2)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_PRECON', (cAliasAUX)->GYD_PRECON)
            oModel:GetModel('G54DETAIL'):LoadValue('G54_PREEXT', (cAliasAUX)->GYD_PREEXT)
            
            If GYD->(FieldPos("GYD_PLCONV")) > 0
                If ( (cAliasAUX)->GYD_PLCONV != '1' )
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRCON', (cAliasAUX)->GYD_VLRTOT)
                Else
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRCON', GA903Calc((cAliasAUX)->GYD_IDPLCO)) 
                EndIf
            Else
                oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRCON', (cAliasAUX)->GYD_VLRTOT)
            EndIf
            
            If GYD->(FieldPos("GYD_PLCONV")) > 0 .AND. GYD->(FieldPos("GYD_IDPLCO")) > 0
                oModel:GetModel('G54DETAIL'):LoadValue('G54_PLCONV', (cAliasAUX)->GYD_PLCONV) 
                oModel:GetModel('G54DETAIL'):LoadValue('G54_IDPLCO', (cAliasAUX)->GYD_IDPLCO)
            EndIf

            If GYD->(FieldPos("GYD_PLEXTR")) > 0
                If ( (cAliasAUX)->GYD_PLEXTR != '1' )
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLREXT', (cAliasAUX)->GYD_VLREXT)
                Else    
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLREXT', GA903Calc((cAliasAUX)->GYD_IDPLEX))
                EndIf
            Else
                oModel:GetModel('G54DETAIL'):LoadValue('G54_VLREXT', (cAliasAUX)->GYD_VLREXT)
            EndIf
            
            If GYD->(FieldPos("GYD_PLEXTR")) > 0 .AND. GYD->(FieldPos("GYD_IDPLEX")) > 0
                oModel:GetModel('G54DETAIL'):LoadValue('G54_PLEXTR', (cAliasAUX)->GYD_PLEXTR)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_IDPLEX', (cAliasAUX)->GYD_IDPLEX)
            EndIf

            oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRACO', (cAliasAUX)->GYD_VLRACO)

            TotaisVia(oModel)
            TotalLinha(oModel)

            oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTCAL',;
            oModel:GetModel('G9WDETAIL'):GetValue('G9W_TOTAPU'))

        Endif

        If !(oModel:GetModel('GYNDETAIL'):IsEmpty())
            oModel:GetModel('GYNDETAIL'):AddLine()
        Endif

        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_CODIGO', (cAliasAUX)->GYN_CODIGO)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_TIPO', (cAliasAUX)->GYN_TIPO)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_LINCOD', (cAliasAUX)->GYN_LINCOD)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DTINI', StoD((cAliasAUX)->GYN_DTINI))
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_HRINI', (cAliasAUX)->GYN_HRINI)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DTFIM', StoD((cAliasAUX)->GYN_DTFIM))
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_HRFIM', (cAliasAUX)->GYN_HRFIM)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_LOCORI', (cAliasAUX)->GYN_LOCORI)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DSCORI', (cAliasAUX)->DSCORI)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_LOCDES', (cAliasAUX)->GYN_LOCDES)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DSCDES', (cAliasAUX)->DSCDES)
        oModel:GetModel('GYNDETAIL'):LoadValue('GYN_APUCON', cApuracao)

        (cAliasAUX)->(DbSkip())   
    End

    SomaContrato(oModel)

    oModel:GetModel('G9WDETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.T.)
    oModel:GetModel('G54DETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.T.)
    oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('GYNDETAIL'):SetNoUpdateLine(.T.)
    oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)

    FwExecView(STR0019, "VIEWDEF.GTPA903", 3, , {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oModel)	//  "Apuração" 

Else
    cAliasGYN := GetNextAlias()

    BeginSQL alias cAliasGYN

        SELECT  GYN.R_E_C_N_O_
        FROM %Table:GY0% GY0
        INNER JOIN %Table:GYD% GYD ON GYD_FILIAL=GY0_FILIAL 
            AND GYD_NUMERO = GY0_NUMERO 
            %Exp:cInner%
            AND GYD.%NotDel%
        INNER JOIN %Table:GI2% GI2 ON GI2_FILIAL=GYD_FILIAL 
            AND GI2_COD=GYD_CODGI2 
            AND GI2.%NotDel%
        INNER JOIN %Table:GYN% GYN ON GYN_FILIAL=GI2_FILIAL AND 
            GYN_LINCOD = GI2_COD AND
            %Exp:cWhere%
            GYN_APUCON =''	AND
            GYN_TIPO = '3' AND
            GYN_FINAL != '1' AND
            GYN.%NotDel%
        INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
            AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
            AND GI1ORI.%NotDel%
        INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
            AND GI1DES.GI1_COD = GYN.GYN_LOCDES
            AND GI1DES.%NotDel%
        INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = GYD.GYD_PRODUT
            AND SB1.%NotDel%
        WHERE
            GY0_FILIAL=%xFilial:GY0% AND
            GY0_CLIENT = %Exp:MV_PAR01% AND
            GY0_LOJACL = %Exp:MV_PAR02% AND
            %Exp:cOrcContr% AND 
            %Exp:cWhereGy0%
            GY0.%NotDel%                 
    EndSql

    If (cAliasGYN)->(!Eof())
        Help(,,"GTPA903Ger",, STR0035) //"Existem viagens não finalizadas, finalize elas antes de efetuar a apuração!", 1,0
    Else
        Help(,,"GTPA903Ger",, STR0018, 1,0)	//'Nenhum registro foi encontrado para apuração.'
    EndIf

    (cAliasGYN)->(DbCloseArea())
EndIf

(cAliasAUX)->(DbCloseArea())
RestArea(aAreaGYN)

Return lRet

/*/{Protheus.doc} SetStruct
//TODO Descrição auto-gerada.
@author GTP
@since 01/12/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function SetStruct(cTipo,oStruGQR, oStruG9W, oStruG54, oStruGYN)
Local aFldsGYN	:= aClone(oStruGYN:GetFields())
Local cFldsGYN  := '' 
Local nX        := 0
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

If cTipo == 'M'

	oStruG9W:AddField("",		"",		"G9W_MARK","L",1,0,{|| .T.},{|| .T.},{},.F.,{ ||.T.},.F.,.F.,.T.)
	oStruG54:AddField("",		"",		"G54_MARK","L",1,0,{|| .T.},{|| .T.},{},.F.,{ ||.T.},.F.,.F.,.T.)

    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLACRE")) > 0
        oStruG9W:AddTrigger("G9W_VLACRE", "G9W_VLACRE" , {||.T.}, bFldTrig)    
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLDESC")) > 0
        oStruG9W:AddTrigger("G9W_VLDESC", "G9W_VLDESC" , {||.T.}, bFldTrig)  
    EndIf
    
    oStruG9W:AddTrigger("G9W_MARK"  , "G9W_MARK" , {||.T.}, bFldTrig)

    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TPCMPO")) > 0
        oStruG9W:AddTrigger("G9W_TPCMPO"  , "G9W_TPCMPO" , {||.T.}, bFldTrig) 
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
        oStruG9W:AddTrigger("G9W_PORCEN"  , "G9W_PORCEN" , {||.T.}, bFldTrig)  
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLFIXO")) > 0
        oStruG9W:AddTrigger("G9W_VLFIXO"  , "G9W_VLFIXO" , {||.T.}, bFldTrig)  
    EndIf

    oStruG54:AddTrigger("G54_MARK"  , "G54_MARK" , {||.T.}, bFldTrig)  

    If AliasInDic("G54") .AND. G54->(FieldPos("G54_TPCMPO")) > 0
        oStruG54:AddTrigger("G54_TPCMPO"  , "G54_TPCMPO" , {||.T.}, bFldTrig)  
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_PORCEN")) > 0
        oStruG54:AddTrigger("G54_PORCEN"  , "G54_PORCEN" , {||.T.}, bFldTrig)  
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_VLFIXO")) > 0
        oStruG54:AddTrigger("G54_VLFIXO"  , "G54_VLFIXO" , {||.T.}, bFldTrig)  
    EndIf

    oStruG9W:SetProperty("*", MODEL_FIELD_WHEN, { || .F. })
    oStruG9W:SetProperty("G9W_MARK", MODEL_FIELD_WHEN, { || .T. })

    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLACRE")) > 0
        oStruG9W:SetProperty("G9W_VLACRE", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLDESC")) > 0
        oStruG9W:SetProperty("G9W_VLDESC", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_MOTIVO")) > 0
        oStruG9W:SetProperty("G9W_MOTIVO", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TIPCNR")) > 0
        oStruG9W:SetProperty("G9W_TIPCNR", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TPCMPO")) > 0
        oStruG9W:SetProperty("G9W_TPCMPO", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_DESCRI")) > 0
        oStruG9W:SetProperty("G9W_DESCRI", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
        oStruG9W:SetProperty("G9W_PORCEN", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLFIXO")) > 0
        oStruG9W:SetProperty("G9W_VLFIXO", MODEL_FIELD_WHEN, { || .F. })
    EndIf

    oStruGQR:SetProperty("*", MODEL_FIELD_WHEN, { || .F. })

    oStruG54:SetProperty("*", MODEL_FIELD_WHEN, { || .F. })
    oStruG54:SetProperty("G54_MARK", MODEL_FIELD_WHEN, { || .T. })

    If AliasInDic("G54") .AND. G54->(FieldPos("G54_TIPCNR")) > 0
        oStruG54:SetProperty("G54_TIPCNR", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_TPCMPO")) > 0
        oStruG54:SetProperty("G54_TPCMPO", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_DESCRI")) > 0
        oStruG54:SetProperty("G54_DESCRI", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_PORCEN")) > 0
        oStruG54:SetProperty("G54_PORCEN", MODEL_FIELD_WHEN, { || .T. })
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_VLFIXO")) > 0
        oStruG54:SetProperty("G54_VLFIXO", MODEL_FIELD_WHEN, { || .T. })
    EndIf

    If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_CONTRA")) > 0
        oStruGQR:RemoveField("GQR_CONTRA")
    EndIf

    If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_MOTIVO")) > 0
        oStruGQR:RemoveField("GQR_MOTIVO")
    EndIf

Else

	oStruG9W:AddField("G9W_MARK","01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.T.)
	oStruG54:AddField("G54_MARK","01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.T.)

    If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_STATUS")) > 0
        oStruGQR:RemoveField("GQR_STATUS")
    EndIf
    If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_CONTRA")) > 0
        oStruGQR:RemoveField("GQR_CONTRA")
    EndIf
    If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_MOTIVO")) > 0
        oStruGQR:RemoveField("GQR_MOTIVO")
    EndIf
    
    If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_USUAPU")) > 0
        oStruGQR:RemoveField("GQR_USUAPU")
    EndIf

    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TIPCNR")) > 0
        oStruG9W:RemoveField("G9W_TIPCNR")
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TPCMPO")) > 0
        oStruG9W:RemoveField("G9W_TPCMPO")
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_DESCRI")) > 0
        oStruG9W:RemoveField("G9W_DESCRI")
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
        oStruG9W:RemoveField("G9W_PORCEN")
    EndIf
    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
        oStruG9W:RemoveField("G9W_PORCEN")
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_QTDE")) > 0
        oStruG54:RemoveField("G54_QTDE")
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_VLRTOT")) > 0
        oStruG54:RemoveField("G54_VLRTOT")
    EndIf
    If AliasInDic("G54") .AND. G54->(FieldPos("G54_SUBTOT")) > 0
        oStruG54:RemoveField("G54_SUBTOT")
    EndIf

    If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_CODCND")) > 0
        oStruG9W:SetProperty("G9W_CODCND",MVC_VIEW_ORDEM,'19')
    EndIf

    If AliasInDic("G54") .AND. G54->(FieldPos("G54_TOTAL")) > 0
        oStruG54:SetProperty("G54_TOTAL" , MVC_VIEW_ORDEM, '14')
    EndIf

    If AliasInDic("G54") .AND. G54->(FieldPos("G54_VLRACO")) > 0
        oStruG54:SetProperty("G54_VLRACO" , MVC_VIEW_ORDEM, '07')
    EndIf

    cFldsGYN := "GYN_CODIGO|"
    cFldsGYN += "GYN_TIPO|"
    cFldsGYN += "GYN_LINCOD|"
    cFldsGYN += "GYN_DTINI|"
    cFldsGYN += "GYN_HRINI|"
    cFldsGYN += "GYN_DTFIM|"
    cFldsGYN += "GYN_HRFIM|"
    cFldsGYN += "GYN_LOCORI|"
    cFldsGYN += "GYN_LOCDES|"
    cFldsGYN += "GYN_APUCON|"
    cFldsGYN += "GYN_DSCORI|"
    cFldsGYN += "GYN_DSCDES"

    For nX := 1 To Len(aFldsGYN)
        If ( !(aFldsGYN[nX,1] $ cFldsGYN) )
            oStruGYN:RemoveField(aFldsGYN[nX,1])
        EndIf
    Next

EndIf    

Return

/*/{Protheus.doc} FieldTrigger
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/02/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local nX := 0
Local nValor := 0

If cField == 'G9W_VLACRE'
    oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTAPU') -;
         oMdl:GetValue('G9W_VLDESC') + uVal)
Endif

If cField == 'G9W_VLDESC'
    oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTAPU') +;
         oMdl:GetValue('G9W_VLACRE ') - uVal)
Endif

If cField == 'G9W_TPCMPO' .AND. uVal == '2'
    oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTCAL') - oMdl:GetValue('G9W_VLFIXO'))
    oMdl:ClearField('G9W_VLFIXO')
    //oMdl:GetModel('G9WDETAIL'):SetProperty('G9W_PORCEN', MODEL_FIELD_WHEN, { || .T.})
    //oMdl:GetModel('G9WDETAIL'):SetProperty('G9W_VLFIXO', MODEL_FIELD_WHEN, { || .F.})
Endif

If cField == 'G9W_TPCMPO' .AND. uVal == '1'
    oMdl:ClearField('G9W_PORCEN')
    oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTCAL') - oMdl:GetValue('G9W_VLFIXO'))
    oMdl:ClearField('G9W_VLFIXO')
    //oMdl:GetModel('G9WDETAIL'):SetProperty('G9W_PORCEN', MODEL_FIELD_WHEN, { || .T.})
    //oMdl:GetModel('G9WDETAIL'):SetProperty('G9W_VLFIXO', MODEL_FIELD_WHEN, { || .F.})
Endif

If cField == 'G9W_PORCEN'
    If oMdl:GetValue('G9W_TPCMPO') == '2'
        oMdl:LoadValue('G9W_VLFIXO', oMdl:GetValue('G9W_TOTAPU') * (uVal/100))
    EndIf
Endif

If cField == 'G54_TPCMPO' .AND. uVal == '2'
    oMdl:LoadValue('G54_TOTAL', oMdl:GetValue('G54_TOTAL') - oMdl:GetValue('G54_VLFIXO'))
    oMdl:ClearField('G54_VLFIXO')
    //oMdl:GetModel('G54DETAIL'):SetProperty('G54_PORCEN', MODEL_FIELD_WHEN, { || .T.})
    //oMdl:GetModel('G54DETAIL'):SetProperty('G54_VLFIXO', MODEL_FIELD_WHEN, { || .F.})
Endif

If cField == 'G54_TPCMPO' .AND. uVal == '1'
    oMdl:ClearField('G54_PORCEN')
    oMdl:LoadValue('G54_TOTAL', oMdl:GetValue('G54_TOTAL') - oMdl:GetValue('G54_VLFIXO'))
    oMdl:ClearField('G54_VLFIXO')
    //oMdl:GetModel('G54DETAIL'):SetProperty('G54_PORCEN', MODEL_FIELD_WHEN, { || .T.})
    //oMdl:GetModel('G54DETAIL'):SetProperty('G54_VLFIXO', MODEL_FIELD_WHEN, { || .F.})
Endif

If cField == 'G54_PORCEN'
    If oMdl:GetValue('G54_TPCMPO') == '2'
        oMdl:LoadValue('G54_VLFIXO', oMdl:GetValue('G54_TOTAL') * (uVal/100))
    EndIf
Endif

If cField == 'G54_VLFIXO'
    oMdl:LoadValue('G54_TOTAL', oMdl:GetValue('G54_TOTAL') + uVal)
    For nX := 1 To oMdl:GetModel():GetModel('G54DETAIL'):Length()
        nValor += oMdl:GetValue("G54_VLFIXO",nX)
    Next
    oMdl:GetModel():GetModel("G9WDETAIL"):LoadValue("G9W_VLFIXO",nValor)
    oMdl:GetModel():GetModel("G9WDETAIL"):LoadValue("G9W_TOTCAL",;
        oMdl:GetModel():GetModel("G9WDETAIL"):GetValue("G9W_TOTAPU") +;
        oMdl:GetModel():GetModel("G9WDETAIL"):GetValue("G9W_VLACRE") -;
        oMdl:GetModel():GetModel("G9WDETAIL"):GetValue("G9W_VLDESC") + nValor)
Endif

If cField $ 'G9W_MARK|G54_MARK|G9W_VLACRE|G9W_VLDESC|G54_VLFIXO|G9W_VLFIXO'
    //SomaLinha(oMdl)
    SomaContrato(oMdl)
Endif

Return

/*/{Protheus.doc} SomaContrato
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function SomaContrato(oMdl)
Local nTotAcre := 0
Local nTotDesc := 0
Local nTotApu  := 0
Local nTotCal  := 0
Local nX       := 0
Local oModel   := Nil

oModel   := oMdl:GetModel()

For nX := 1 To oModel:GetModel():GetModel('G9WDETAIL'):Length()
    If oModel:GetModel():GetModel('G9WDETAIL'):GetValue('G9W_MARK', nX)
        nTotAcre += oModel:GetModel():GetModel('G9WDETAIL'):GetValue('G9W_VLACRE', nX)
        nTotDesc += oModel:GetModel():GetModel('G9WDETAIL'):GetValue('G9W_VLDESC', nX)
        nTotApu  += oModel:GetModel():GetModel('G9WDETAIL'):GetValue('G9W_TOTAPU', nX)
        nTotCal  += oModel:GetModel():GetModel('G9WDETAIL'):GetValue('G9W_TOTCAL', nX)
    Endif
Next
If !(IsBlind())
    oModel:GetModel():GetModel('GQRMASTER'):LoadValue('GQR_VLACRE', nTotAcre)
    oModel:GetModel():GetModel('GQRMASTER'):LoadValue('GQR_VLDESC', nTotDesc)
    oModel:GetModel():GetModel('GQRMASTER'):LoadValue('GQR_TOTAPU', nTotApu)
    oModel:GetModel():GetModel('GQRMASTER'):LoadValue('GQR_TOTCAL', nTotCal)
Endif

Return

/*/{Protheus.doc} AtuViagens
//TODO Descrição auto-gerada.
@author flavio.martins
@since 24/02/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function AtuViagens(oModel)
Local lRet      := .T.
Local aAreaGYN	:= GYN->(GetArea())
Local cCodApur  := ''
Local n1        := 0
Local n2        := 0
Local n3        := 0

dbSelectArea('GYN')
GYN->(dbSetOrder(1))

For n1 := 1 To oModel:GetModel('G9WDETAIL'):Length()

    oModel:GetModel('G9WDETAIL'):GoLine(n1)

    For n2 := 1 To oModel:GetModel('G54DETAIL'):Length()

        oModel:GetModel('G54DETAIL'):GoLine(n2)

        If oModel:GetModel('G9WDETAIL'):GetValue('G9W_MARK') .And.;
            oModel:GetModel('G54DETAIL'):GetValue('G54_MARK') .And.;
            oModel:GetOperation() != MODEL_OPERATION_DELETE
            cCodApur := oModel:GetModel('GQRMASTER'):GetValue('GQR_CODIGO')
        Else
            cCodApur := ''
        Endif

        For n3 := 1 To oModel:GetModel('GYNDETAIL'):Length()

            If GYN->(dbSeek(xFilial('GYN')+oModel:GetModel('GYNDETAIL'):GetValue('GYN_CODIGO', n3)))
                RecLock("GYN", .F.)
                    GYN->GYN_APUCON := cCodApur 
                MsUnLock()
            Endif

        Next

    Next

Next

RestArea(aAreaGYN)

Return lRet

/*/{Protheus.doc} G903Commit
//TODO Descrição auto-gerada.
@author flavio.martins
@since 24/02/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function G903Commit(oModel)
Local lRet := .T.

If oModel:GetOperation() != MODEL_OPERATION_INSERT
    If oModel:GetModel('GQRMASTER'):GetValue('GQR_STATUS') == '2'
        lRet := .F.
        oModel:GetModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),, STR0036, STR0037) //"Atenção", "Não é possível efetuar manutenção em apuração com medição efetivada!"
    EndIf
Endif

If lRet
    If oModel:GetOperation() != MODEL_OPERATION_DELETE
        DelNoMarks(oModel)
    Endif

    If oModel:VldData()

        Begin Transaction

            If !AtuViagens(oModel) .Or. !FwFormCommit(oModel)
                DisarmTransaction()
                lRet := .F.
                oModel:GetModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),,STR0023, STR0024) //"Erro","Erro ao gravar apuração"
            Endif

            If oModel:GetOperation() == MODEL_OPERATION_INSERT
                lRet := GTPA903B()
            EndIf
        End Transaction

    Endif
Endif

Return lRet

/*/{Protheus.doc} TotaisVia
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/05/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function TotaisVia(oModel)
Local cAliasTmp := GetNextAlias()
Local cContrato := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
Local cDataIni  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA')
Local cDataFim  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA')
Local cExtCmp   := '%%'

If GYN->(FieldPos("GYN_EXTCMP")) > 0
	cExtCmp := '%,GYN_EXTCMP%'
EndIf


BeginSql Alias cAliasTmp

    SELECT GYN_FINAL,
           GYN_EXTRA,
           COUNT(GYN_CODIGO) QTDVIAGENS
    FROM %Table:GYN%
    WHERE GYN_FILIAL = %xFilial:GYN%
      AND GYN_CODGY0 = %Exp:cContrato%
      AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
      AND %NotDel%
    GROUP BY GYN_FINAL, GYN_EXTRA %Exp:cExtCmp%

EndSql

While (cAliasTmp)->(!Eof())

    If (cAliasTmp)->GYN_FINAL = '1' .And. (cAliasTmp)->GYN_EXTRA = 'F'
        oModel:GetModel('G54DETAIL'):LoadValue('G54_QVCFIN', (cAliasTmp)->QTDVIAGENS)    
    ElseIf (cAliasTmp)->GYN_FINAL = '1' .And. (cAliasTmp)->GYN_EXTRA = 'T'
        oModel:GetModel('G54DETAIL'):LoadValue('G54_QVEFIN', (cAliasTmp)->QTDVIAGENS)    
    ElseIf (cAliasTmp)->GYN_FINAL = '2' .And. (cAliasTmp)->GYN_EXTRA = 'F'
        oModel:GetModel('G54DETAIL'):LoadValue('G54_QVCNFI', (cAliasTmp)->QTDVIAGENS)    
    ElseIf (cAliasTmp)->GYN_FINAL = '2' .And. (cAliasTmp)->GYN_EXTRA = 'T'
        oModel:GetModel('G54DETAIL'):LoadValue('G54_QVENFI', (cAliasTmp)->QTDVIAGENS)
    Endif

    (cAliasTmp)->(dbSkip())

End

(cAliasTmp)->(dbCloseArea())

Return

/*/{Protheus.doc} TotalLinha
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function TotalLinha(oModel)
Local cAliasTmp     := GetNextAlias()
Local cCliente      := oModel:GetModel('GQRMASTER'):GetValue('GQR_CLIENT')
Local cLoja         := oModel:GetModel('GQRMASTER'):GetValue('GQR_LOJA')
Local cContrato     := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
Local cItem         := oModel:GetModel('G54DETAIL'):GetValue('G54_CODGYD')
Local cDataIni      := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA')
Local cDataFim      := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA')
Local cPrecoCon     := oModel:GetModel('G54DETAIL'):GetValue('G54_PRECON')
Local cPrecoExt     := oModel:GetModel('G54DETAIL'):GetValue('G54_PREEXT')
Local cLinha        := oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2')
Local nQtdViaCon    := oModel:GetModel('G54DETAIL'):GetValue('G54_QVCFIN')
Local nQtdViaExt    := oModel:GetModel('G54DETAIL'):GetValue('G54_QVEFIN')
Local nVlrCon       := oModel:GetModel('G54DETAIL'):GetValue('G54_VLRCON')
Local nVlrExt       := oModel:GetModel('G54DETAIL'):GetValue('G54_VLREXT')
Local nVlrAco       := oModel:GetModel('G54DETAIL'):GetValue('G54_VLRACO')
Local nQtdCon       := 0
Local nQtdExt       := 0
Local nTotCon       := 0
Local nTotExt       := 0
Local nVlrAdic      := 0
Local nVlrOper      := 0
Local nVlrTot       := 0
Local nVlrTotGer    := 0
Local nTotalApur    := 0
Local nQtdVESL      := 0
Local cExtCmp       := '%%'

If GYN->(FieldPos("GYN_EXTCMP")) > 0
    cExtCmp:= "% AND GYN_EXTCMP = 'T' %"
EndIf

BeginSql Alias cAliasTmp

    SELECT GYD.GYD_NUMERO,
        GYD.GYD_CODGYD,
        (GYD.GYD_KMIDA  +
         GYD.GYD_KMVOLT +
         GYD.GYD_KMGRRD +
         GYD.GYD_KMRDGR) AS KMTOTAL,
         GYD.GYD_CODGI2,
    (SELECT COALESCE(SUM(GYX_VALTOT), 0) AS GYX_VALTOT
    FROM %Table:GYX%
    WHERE GYX_FILIAL = GYD.GYD_FILIAL
        AND GYX_CODIGO = GYD.GYD_NUMERO
        AND GYX_REVISA = GYD.GYD_REVISA
        AND GYX_ITEM = GYD.GYD_CODGYD
        AND %NotDel%) GYX_VALTOT,
    (SELECT COALESCE(SUM(GQZ_VALTOT), 0) AS GQZ_VALTOT
    FROM %Table:GQZ%
    WHERE GQZ_FILIAL = GYD.GYD_FILIAL
        AND GQZ_CODIGO = GYD.GYD_NUMERO
        AND GQZ_REVISA = GYD.GYD_REVISA
        AND GQZ_ITEM = GYD.GYD_CODGYD
        AND %NotDel%) GQZ_VALTOT,
    (SELECT COALESCE(SUM(GQJ_VALTOT), 0) AS GQJ_VALTOT
    FROM %Table:GQJ%
    WHERE GQJ_FILIAL = GYD.GYD_FILIAL
        AND GQJ_CODIGO = GYD.GYD_NUMERO
        AND GQJ_REVISA = GYD.GYD_REVISA
        AND %NotDel%) GQJ_VALTOT,
    (SELECT COUNT(DISTINCT(GYN_DTINI)) 
    FROM %Table:GYN%
    WHERE GYN_FILIAL = %xFilial:GYN%
        AND GYN_CODGY0 = GYD.GYD_NUMERO
        AND GYN_LINCOD = GYD.GYD_CODGI2
        AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
        AND GYN_TIPO = '3'
        AND GYN_EXTRA = 'F'
        AND GYN_FINAL = '1'
        AND %NotDel%) AS QTDDIASCON,
    (SELECT COUNT(DISTINCT(GYN_DTINI)) 
    FROM %Table:GYN%
    WHERE GYN_FILIAL = %xFilial:GYN%
        AND GYN_CODGY0 = GYD.GYD_NUMERO
        AND GYN_LINCOD = GYD.GYD_CODGI2
        AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
        AND GYN_TIPO = '3'
        AND GYN_EXTRA = 'T'
        AND GYN_FINAL = '1'
        AND %NotDel%) AS QTDDIASEXT,
    (SELECT COUNT(GYN_CODIGO) 
    FROM %Table:GYN%
    WHERE GYN_FILIAL = %xFilial:GYN%
        AND GYN_CODGY0 = GYD.GYD_NUMERO
        AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
        AND GYN_TIPO = '2'
        %Exp:cExtCmp%
        AND GYN_FINAL = '1'
        AND %NotDel%) AS QTDVESL
    FROM %Table:GY0% GY0
    INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL = GY0.GY0_FILIAL
    AND GYD.GYD_NUMERO = GY0.GY0_NUMERO
    AND GYD.GYD_REVISA = GY0.GY0_REVISA
    AND GYD.GYD_CODGYD = %Exp:cItem%
    AND GYD.%NotDel%
    WHERE GY0.GY0_FILIAL = %xFilial:GY0%
    AND GY0.GY0_CLIENT = %Exp:cCliente%
    AND GY0.GY0_LOJACL = %Exp:cLoja%
    AND GY0.GY0_NUMERO = %Exp:cContrato%
    AND GY0.GY0_ATIVO = '1'
    AND GY0.%NotDel%
EndSql

nVlrAdic := IIF((cAliasTmp)->GYX_VALTOT > 0,(cAliasTmp)->GYX_VALTOT,(cAliasTmp)->GQJ_VALTOT)
nVlrOper := (cAliasTmp)->GQZ_VALTOTT

nQTDVESL := (cAliasTmp)->QTDVESL

If cPrecoCon = '1' // Preço Fixo
   // nVlrRef     := (cAliasTmp)->GYD_VLRTOT
    nQtdCon     := 1
    nTotCon     := nVlrCon
    nVlrTot     := nVlrCon + nVlrAdic + nVlrOper
    nVlrTotGer  := nVlrTot
ElseIf cPrecoCon = '2' // Preço por KM
    nQtdCon     := nQtdViaCon * (cAliasTmp)->KMTOTAL
    nTotCon     := (nQtdCon * nVlrCon) + (nQtdViaCon * nVlrAco)
    nVlrTot     := nTotCon + nVlrAdic + nVlrOper
    nVlrTotGer  := nVlrTot
ElseIf cPrecoCon = '3' // Preço por Viagem
    nQtdCon     := nQtdViaCon
    nTotCon     := nQtdCon * (nVlrCon + nVlrAco)
    nVlrTot     := nTotCon + nVlrAdic + nVlrOper
    nVlrTotGer  := nVlrTot
ElseIf cPrecoCon = '4' // Preço por Diaria
    nQtdCon     := (cAliasTmp)->QTDDIASCON
    nTotCon     := (nQtdCon * nVlrCon) + (nQtdViaCon * nVlrAco)
    nVlrTot     := nTotCon + nVlrAdic + nVlrOper
    nVlrTotGer  := nVlrTot
Endif

If cPrecoExt = '1'      // Horas
    nQtdExt := RetHrsVia(oModel)
    nTotExt := nQtdExt * nVlrExt
ElseIf cPrecoExt = '2' // Diaria
    nQtdExt := (cAliasTmp)->QTDDIASEXT
    nTotExt := nQtdExt * nVlrExt
ElseIf cPrecoExt = '3' // KM
    nQtdExt := nQtdViaExt * (cAliasTmp)->KMTOTAL
    nTotExt := nQtdExt * nVlrExt
ElseIf cPrecoExt = '4' // Preço Fixo
    nQtdExt := 1
    nTotExt := nVlrExt
Endif

If ( nQtdExt == 0 .And. nVlrExt > 0 )
    nQtdExt := 1
    nTotExt := nVlrExt
EndIf

nTotalApur = nVlrTot + nTotExt

//aTotais := {nVlrLinha, nVlrAdic, nVlrExt, nVlrOper, nVlrTot, nVlrTotGer, nQtdVia, nTotalApur}

//oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRTOT', nVlrRef)
oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTADI', nVlrAdic)
oModel:GetModel('G54DETAIL'):LoadValue('G54_CUSOPE', nVlrOper)
//oModel:GetModel('G54DETAIL'):LoadValue('G54_SUBTOT', nVlrTot)
oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTAL' , nTotalApur)
oModel:GetModel('G54DETAIL'):LoadValue('G54_QTDCON', nQtdCon)
oModel:GetModel('G54DETAIL'):LoadValue('G54_QTDEXT', nQtdExt)
oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTCON', nTotCon)
oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTEXT', nTotExt)

If Empty(Alltrim(cLinha))
    oModel:GetModel('G54DETAIL'):LoadValue('G54_QTVESL', nQTDVESL)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLVESL', nTotExt)
Else
        oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTEXT', nTotExt)
EndIf

oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTAPU', oModel:GetModel('G9WDETAIL'):GetValue('G9W_TOTAPU') + nTotalApur)

(cAliasTmp)->(dbCloseArea())

Return

/*/{Protheus.doc} RetHrsVia
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/05/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function RetHrsVia(oModel)
Local cAliasTmp := GetNextAlias()
Local cContrato := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
Local cDataIni  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA')
Local cDataFim  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA')
Local nHoras    := 0
Local cExtEmp   := ''

IIf(GYN->(ColumnPos("GYN_EXTCMP")) > 0,cExtEmp := "% (GYN_EXTRA = 'T' OR GYN_EXTCMP = 'T' ) %",cExtEmp := "% GYN_EXTRA = 'T' %")

BeginSql Alias cAliasTmp

    SELECT GYN_DTINI,
           GYN_DTFIM,
           GYN_HRINI,
           GYN_HRFIM
    FROM %Table:GYN%
    WHERE GYN_FILIAL = %xFilial:GYN%
      AND GYN_CODGY0 = %Exp:cContrato%
      AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
      AND %Exp:cExtEmp%
      AND GYN_FINAL = '1'
      AND %NotDel%

EndSql

While !(cAliasTmp)->(Eof())

    nHoras += SubHoras( Transform((cAliasTmp)->GYN_HRFIM, "@R 99:99"), Transform((cAliasTmp)->GYN_HRINI, "@R 99:99"))
	
    (cAliasTmp)->(dbSkip())
End

(cAliasTmp)->(dbCloseArea())

Return nHoras

/*/{Protheus.doc} G900VldDic
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/

Function G900VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'GY0','GYD','GQI','GQZ','GYX','GQJ','GQR','G9W','G54'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'GQR_VLACRE','GQR_VLDESC','GQR_USUAPU',;
            'GQR_TOTAPU','GQR_TOTCAL','G9W_CODGQR',;
            'G9W_VLACRE','G9W_VLDESC','G9W_NUMGY0',;
            'G9W_CONTRA','G9W_DTINIA','G9W_TPCTO',;
            'G9W_TIPPLA','G9W_TABPRC','G9W_VLACRE',;
            'G9W_VLDESC','G9W_TOTAPU','G9W_TOTCAL',;
            'G9W_MOTIVO','G54_NUMGY0','G54_CODGQR',;
            'G54_PRODUT','G54_CODGI2','G54_QTDE',;
            'G54_VLRTOT','G54_VLREXT','G54_SUBTOT',;
            'G54_TOTADI','G54_CUSOPE','G54_TOTAL',;
            'G9W_TIPCNR','G9W_TPCMPO','G9W_DESCRI',;
            'G9W_PORCEN','G9W_VLFIXO','G54_TIPCNR',;
            'G54_TPCMPO','G54_DESCRI','G54_PORCEN',;
            'G54_VLFIXO','G54_PRECON','G54_PREEXT',;
            'G54_CODGYD','G54_QVCFIN','G54_QVCNFI',;
            'G54_QVEFIN','G54_QVENFI','G54_QTDCON',;
            'G54_QTDEXT','G54_VLRCON','G54_TOTCON',;
            'G54_TOTEXT','GY0_REVISA','GY0_ATIVO',;
            'G54_REVISA','G54_VLRACO','G9W_REVISA'}
            


For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

For nX := 1 To Len(aFields)
    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
        lRet := .F.
        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
        Exit
    Endif
Next

Return lRet

/*/{Protheus.doc} G903VldAct
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function G903VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G900VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol := STR0029 // "Atualize o dicionário para utilizar esta rotina" 
    FwAlertHelp(cMsgErro, STR0029) // "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina" 
//    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G903VldAct",cMsgErro,cMsgSol,,)      
Endif

Return lRet

/*/{Protheus.doc} LineChange
//TODO Descrição auto-gerada.
@author flavio.martins
@since 01/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oView, cViewId
@type function
/*/
Static Function LineChange(oView, cViewId)
Local oModel := oView:GetModel()

If cViewId = 'G9WDETAIL'
    oModel:GetModel('G54DETAIL'):GoLine(1)
    oModel:GetModel('GYNDETAIL'):GoLine(1)
ElseIf cViewId = 'G54DETAIL'
    oModel:GetModel('GYNDETAIL'):GoLine(1)
Endif  

Return

/*/{Protheus.doc} DelNoMarks
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function DelNoMarks(oModel)
Local nX := 0

oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.F.)
oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.F.)

For nX := 1 To oModel:GetModel('G54DETAIL'):Length()
    If !(oModel:GetModel('G54DETAIL'):GetValue('G54_MARK', nX))
        oModel:GetModel('G54DETAIL'):GoLine(nX)
        oModel:GetModel('G54DETAIL'):DeleteLine()
    Endif
Next

For nX := 1 To oModel:GetModel('G9WDETAIL'):Length()
    If !(oModel:GetModel('G9WDETAIL'):GetValue('G9W_MARK', nX))
        oModel:GetModel('G9WDETAIL'):GoLine(nX)
        oModel:GetModel('G9WDETAIL'):DeleteLine()
    Endif
Next

oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.T.)

Return

/*/{Protheus.doc} ConsultaVia
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function ConsultaVia(oModel)
Local oMdl903A  := FwLoadModel('GTPA903A')
Local nX        := 0
Local nY        := 0
Local cContrDe  := ''
Local cContrAte := ''
Local cLinhaDe  := ''
Local cLinhaAte := ''

For nX := 1 To oModel:GetModel('G9WDETAIL'):Length()

    oModel:GetModel('G9WDETAIL'):GoLine(nX)

    If cContrDe = ''
        cContrDe := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
    Endif

    cContrAte := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
    
    For nY := 1 To oModel:GetModel('G54DETAIL'):Length()

        If cLinhaDe = '' .Or. (oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2',nY) < cLinhaDe)
            cLinhaDe :=  oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2', nY)
        Endif

        If oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2',nY) > cLinhaAte
            cLinhaAte := oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2',nY)
        Endif

    Next 

Next

oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('CODCLI', MODEL_FIELD_WHEN, { || .F.})
oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('LOJCLI', MODEL_FIELD_WHEN, { || .F.})
oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('DATADE', MODEL_FIELD_WHEN, { || .F.})
oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('DATAATE', MODEL_FIELD_WHEN, { || .F.})
//oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('LINHADE', MODEL_FIELD_WHEN, { || .F.})
//oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('LINHAATE', MODEL_FIELD_WHEN, { || .F.})

oMdl903A:SetOperation(MODEL_OPERATION_INSERT)

oMdl903A:Activate()

If !(IsBlind()) .And. oMdl903A:IsActive()
    oMdl903A:GetModel('HEADER'):LoadValue('CODCLI',oModel:GetModel('GQRMASTER'):GetValue('GQR_CLIENT'))
    oMdl903A:GetModel('HEADER'):LoadValue('LOJCLI', oModel:GetModel('GQRMASTER'):GetValue('GQR_LOJA'))
    oMdl903A:GetModel('HEADER'):LoadValue('CONTRATODE', cContrDe)
    oMdl903A:GetModel('HEADER'):LoadValue('CONTRATOATE', cContrAte)
    oMdl903A:GetModel('HEADER'):LoadValue('DATADE', oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA'))
    oMdl903A:GetModel('HEADER'):LoadValue('DATAATE', oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA'))
    oMdl903A:GetModel('HEADER'):LoadValue('LINHADE', cLinhaDe)
    oMdl903A:GetModel('HEADER'):LoadValue('LINHAATE', cLinhaAte)
    
    GA903APesq(oMdl903A)
    GTPA903A(oMdl903A)
Endif

Return

/*/{Protheus.doc} ValidMarks
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function ValidMarks(oModel)
Local lRet      := .F.
Local lVldG9W   := .F.
Local lVldG54   := .F.
Local nX        := 0
Local nY        := 0

For nX := 1 To oModel:GetModel('G9WDETAIL'):Length()

    lVldG9W := oModel:GetModel('G9WDETAIL'):GetValue('G9W_MARK', nX)

    If lVldG9W

        For nY := 1 To oModel:GetModel('G54DETAIL'):Length()
            lVldG54 := oModel:GetModel('G54DETAIL'):GetValue('G54_MARK', nY)

            If lVldG54 
                Exit
            Endif
        Next

        If lVldG9W .And. lVldG54
            lRet := .T.
            Exit
        Endif

    Endif

Next

Return lRet

/*/{Protheus.doc} GA903Calc
Retorna o valor da planilha de custos.
@author Fernando Radu Muscalu
@since 22/07/2022
@version 1.0
@return ${nValue, numérico}, ${Valor que foi calculado na planilha de custos}
@param  cIdCusto, caractere, código da planilha de custos 
        cFilSeek, caractere, código da filial da planilha de custos
@type function
/*/
Function GA903Calc(cIdCusto,cFilSeek)
    
    Local oWorkSheet	:= FWUIWorkSheet():New(/*oWinPlanilha*/,.F. , /*WS_ROWS*/, /*WS_COLS*/)

    Local nValue		:= 0
    Local nP            := 0

    Local aSeek         := {}
    
    Local lSeekAgain    := .F.

    Default cFilSeek    := xFilial("GIM")

    nP := aScan(aPlanExec,{|x| Alltrim(x[1]+x[2]) == Alltrim(cFilSeek+cIdCusto) })

    If ( nP == 0 )

        If ( len(aResultGIM) <= 1 )
            lSeekAgain := .T.
            aResultGIM := {{"GIM_FILIAL","GIM_COD","GIM_PLAN"}}
        Else

            nP := aScan(aResultGIM,{|x| alltrim(x[1]) == Alltrim(cFilSeek) .And. Alltrim(x[2]) == Alltrim(cIdCusto) })
        
            If ( nP == 0 )
                lSeekAgain := .T.
            EndIf    

        EndIf

        If ( lSeekAgain )

            aAdd(aSeek,{"GIM_FILIAL",cFilSeek})
            aAdd(aSeek,{"GIM_COD",cIdCusto})
                
            GTPSeekTable("GIM",aSeek,aResultGIM,.f.)

        EndIf

        If ( Len(aResultGIM) > 1 )
            nP := aScan(aResultGIM,{|x| alltrim(x[1]) == Alltrim(cFilSeek) .And. Alltrim(x[2]) == Alltrim(cIdCusto) })    
        EndIf    
            
        oWorkSheet:lShow := .F.

        oWorkSheet:LoadXmlModel(aResultGIM[nP,3])
        
        If oWorkSheet:CellExists("D2") 	
            nValue := oWorkSheet:GetCellValue("D2")
        EndIf
        
        aAdd(aPlanExec,{cFilSeek,cIdCusto,nValue})

        oWorkSheet:Close()

        GTPDestroy(oWorkSheet)

    Else
        nValue := aPlanExec[nP,3]
    EndIf

Return(nValue)
