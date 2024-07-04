#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA412A.CH'

/*/{Protheus.doc}  GTPA412A()
Rotina para copiar a comissão de uma determinada agência para outras agências
@type function
@author flavio.martins
@since 21/09/2021
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GTPA412A()
Local lRet      := .T.
Local nOpc      := 0
Local cAgeOri   := G5D->G5D_AGENCI
Local aAgencias := {}

If Pergunte('GTPA412A',.T.)

    If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03)

        FwAlertWarning(STR0002, STR0001) // 'É necessário preencher todas as perguntas', 'Atenção!'
    Else
        GetAgencias(cAgeOri, @aAgencias)

        If aScan(aAgencias, {|x| x[2] == .T.}) > 0
            nOpc := Aviso(STR0003, STR0004 + Chr(13) + Chr(10) +; //"Cópiar comissão de agência", "Atenção, encontrada comissão cadastradas anteriormente."
                          STR0005 + Chr(13) + Chr(10) +;  //"Selecionar 'Sobrescrever' irá substituir os dados atuais pelos dados da comissão utilizada como modelo."
                          STR0006, {STR0007,STR0008,STR0009}, 2 ) //"Selecionar 'Manter' fará com que os dados já cadastrados sejam mantidos", {"Sobrescrever", "Manter","Cancelar"}
        Endif
        
        If nOpc < 3
            FwMsgRun(,{|| lRet := ExecCopia(aAgencias, nOpc) },, STR0010) //"Replicando o cadastro da comissão de agências..."
            
            If lRet
                FwAlertSuccess(STR0011, STR0012) //"Dados replicados com sucesso", "Cópia de Comissão"
            Else
                FwAlertError(STR0014, STR0001) //"Erro na cópia das informações, o processo foi cancelado","Atenção!"
            Endif

        Endif

    Endif

Endif

Return

/*/{Protheus.doc} GetAgencias(cAgeOri)
Função que retorna um array com as agências que serão replicadas
@type function
@author flavio.martins
@since 21/09/2021
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function GetAgencias(cAgeOri, aAgencias)
Local cAliasTmp := GetNextAlias()
Local cAgeIni   := MV_PAR01
Local cAgeFim   := MV_PAR02
Local cTipoAge  := MV_PAR03
Local cQuery    := ''

If cTipoAge != 3
    cQuery := ' AND GI6.GI6_TIPO = ' + Str(cTipoAge)
Endif

cQuery := '%' + cQuery + '%'

BeginSql Alias cAliasTmp
    
    SELECT GI6.GI6_CODIGO,
           COALESCE(G5D.G5D_CODIGO, '') AS G5D_CODIGO
    FROM %Table:GI6% GI6
    LEFT JOIN %Table:G5D% G5D ON G5D.G5D_FILIAL = %xFilial:G5D%
    AND G5D.G5D_AGENCI = GI6.GI6_CODIGO
    AND G5D.%NotDel%
    WHERE GI6.GI6_FILIAL = %xFilial:GI6%
      %Exp:cQuery%
      AND GI6.GI6_CODIGO BETWEEN %Exp:cAgeIni% AND %Exp:cAgeFim%
      AND GI6.GI6_CODIGO <> %Exp:cAgeOri%
      AND GI6.%NotDel%

EndSql

While (cAliasTmp)->(!Eof())

    AADD(aAgencias, {(cAliasTmp)->GI6_CODIGO, Iif(Empty((cAliasTmp)->G5D_CODIGO), .F., .T.)})

    (cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())

Return aAgencias

/*/{Protheus.doc} ExecCopia(aAgencias, nOpc)
Função que irá executar a cópia de comissão do range de agências
@type function
@author flavio.martins
@since 21/09/2021
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function ExecCopia(aAgencias, nOpc)
Local lRet      := .T.
Local oMdlCopia := FwLoadModel('GTPA412')
Local nX        := 0

For nX := 1 To Len(aAgencias)

    If !Empty(aAgencias[nX][2])
        If nOpc == 1 //Sobrescrever
            lRet := DelComissao(aAgencias[nX][1])

            If !(lRet)
                Exit
            Endif 

        ElseIf nOpc == 2 //Manter
            Loop
        Endif
    Endif

    oMdlCopia:SetOperation(MODEL_OPERATION_INSERT)

    oMdlCopia:Activate(.T.)

    oMdlCopia:LoadValue('G5DMASTER', 'G5D_AGENCI', aAgencias[nX][1])

    If oMdlCopia:VldData()
        oMdlCopia:CommitData()
    Else
        lRet := .F.
        JurShowErro(oMdlCopia:GetErrormessage())
        oMdlCopia:DeActivate()
        Exit
    Endif

    oMdlCopia:DeActivate()
  
Next 

oMdlCopia:Destroy()

Return lRet

/*/{Protheus.doc} DelComissao(cAgencia)
Função que exclui a comissão da agência caso a opção seja para sobrescrever
@type function
@author flavio.martins
@since 22/09/2021
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function DelComissao(cAgencia)
Local lRet      := .T.
Local oMdl412   := FwLoadModel('GTPA412')
Local aArea     := G5D->(GetArea())

dbSelectArea('G5D')
G5D->(dbSetOrder(2))

If G5D->(dbSeek(xFilial('G5D')+cAgencia))

    oMdl412:SetOperation(MODEL_OPERATION_DELETE)
    oMdl412:Activate()
            
    If oMdl412:VldData()
        oMdl412:CommitData()
    Else
        lRet := .F.   
        JurShowErro(oMdl412:GetErrormessage())
    Endif

    oMdl412:DeActivate()
    oMdl412:Destroy()

Endif

RestArea(aArea)

Return lRet
