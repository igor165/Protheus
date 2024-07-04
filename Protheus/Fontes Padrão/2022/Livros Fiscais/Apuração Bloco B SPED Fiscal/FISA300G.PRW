#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FISA300G.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300GVLD()

Função implementada para que os fontes que utilizam a classe possam
validar se ela está compilada no RPO. Não é possivel utilizar a função 
"FindClass" pois ela só está disponível após a build 131227A.

@author joao.pellegrini
@since 19/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA300GVLD()
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} APURISS()

Classe principal de apuração

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Class APURISS

Data cFilApu as Character   // Filial de apuração
Data cID as Character       // ID da apuração
Data dDtIni as Date         // Data de início do período apurado
Data dDtFim as Date         // Data final do período apurado

Data aMunic as Array        // Array com as apurações por município

Method new() CONSTRUCTOR
Method clear()
Method addMunic(cCodMun)
Method addMov(cCodMun, oObjMov)
Method addDeducao(cCodMun, oObjDed)
Method addUniprof(cCodMun, nQtdeProf, nVlMensal)
Method apurar()
Method saveApur()
Method loadApur(cIDApur)
Method deleteApur()
Method execQuery(cTpQuery, aParams)

Method getFilApu()
Method setFilApu(cFilApu)
Method getID()
Method getDtIni()
Method setDtIni(dDtIni)
Method getDtFim()
Method setDtFim(dDtFim)

Method getApurMun(cCodMun)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Construtor da classe

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method new() Class APURISS

Self:clear()

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} clear()

Método responsável por limpar os arrays utilizados pela classe.

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method clear() Class APURISS

Local nX := 0

Self:cFilApu := ""
Self:cID := ""
Self:dDtIni := CtoD("//")
Self:dDtFim := CtoD("//")

//Laço nos municípios
If ValType(Self:aMunic) == "A"
    For nX:= 1 to Len(Self:aMunic)
        //Obtem a lista de serviços do município corrente no laço
        Self:aMunic[nX]:clear() 
        //Destroi objeto do município
        FreeObj(Self:aMunic[nX])
        Self:aMunic[nX] := Nil
    Next nX
EndIf

Self:aMunic := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addMov()

Método responsável por adicionar um municipio na lista de municipios apurados.
Este método pode receber tanto um código de município (string) quanto um
objeto do tipo APURISSMUN já pronto.

@author joao.pellegrini
@since 12/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method addMunic(xMunic) Class APURISS

Local cTypePar := ValType(xMunic) 
Local oApurMun := NIL

If cTypePar == 'C'
    oApurMun := APURISSMUN():New()
    oApurMun:setCodIBGE(xMunic)
ElseIf cTypePar == 'O'
    oApurMun := xMunic
EndIf

aAdd(Self:aMunic, oApurMun)

Return oApurMun

//------------------------------------------------------------- ------
/*/{Protheus.doc} addMov()

Método responsável por adicionar uma movimentação na apuração.

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method addMov(cCodMun, oObjMov) Class APURISS

Local oApurMun := NIL
Local aApurMun := {}
Local cClassPar := IIf(ValType(oObjMov) == 'O', GetClassName(oObjMov), "")

// Alltrim p/ evitar que as validações dos campos de municipio falhem.
cCodMun := AllTrim(cCodMun)

// Validação caso seja enviado qualquer objeto que não seja do tipo APURISSMOV.
If cClassPar <> "APURISSMOV"
    UserException(STR0001 + cClassPar)//"Tipo de referência inválido no método addMov. Esperado : APURISSMOV - Enviado: "
Else
    // Verifico se já existe apuração para o municipio.
    aApurMun := Self:getApurMun(cCodMun)

    // Se não existir, crio uma nova apuracao para o municipio. Caso contrario apuração estará na primeira posição.
    oApurMun := IIf(Len(aApurMun) == 0, Self:addMunic(cCodMun), aApurMun[1])

    // Adiciona o serviço (movimento) na apuração do município
    oApurMun:addServico(oObjMov)
EndIf

Return

//------------------------------------------------------------- ------
/*/{Protheus.doc} addDeducao()

Método responsável por adicionar uma dedução na apuração.

@author joao.pellegrini
@since 14/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method addDeducao(cCodMun, oObjDed) Class APURISS

Local oApurMun := NIL
Local aApurMun := {}

// Verifico se já existe apuração para o municipio. 
aApurMun := Self:getApurMun(cCodMun)

// Se não existir, crio uma nova apuracao para o municipio. Caso contrario apuração estará na primeira posição.
oApurMun := IIf(Len(aApurMun) == 0, Self:addMunic(cCodMun), aApurMun[1])

// Adiciona a dedução na apuração do município
oApurMun:addDeducao(oObjDed)

Return

//------------------------------------------------------------- ------
/*/{Protheus.doc} addUniprof()

Método responsável por adicionar as informações para cálculo do ISS
sociedade uniprofissional.

@author joao.pellegrini
@since 17/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method addUniprof(cCodMun, nQtdeProf, nVlMensal) Class APURISS

Local oApurMun := NIL
Local aApurMun := {}

// Verifico se já existe apuração para o municipio. 
aApurMun := Self:getApurMun(cCodMun)

// Se não existir, crio uma nova apuracao para o municipio. Caso contrario apuração estará na primeira posição.
oApurMun := IIf(Len(aApurMun) == 0, Self:addMunic(cCodMun), aApurMun[1])

// Adiciona a dedução na apuração do município
oApurMun:setProfHab(nQtdeProf)
oApurmun:setVlMensal(nVlMensal)

Return

//------------------------------------------------------------- ------
/*/{Protheus.doc} apurar()

Método "principal" de apuração do ISS. Este método é responsável por
disparar a apuração de todos os municípips em que houve movimento.

@author joao.pellegrini
@since 12/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method apurar() Class APURISS

Local oApurMun := NIL
Local nX := 0

// Vou percorrer a lista de municípios e chamar o método "apurar" de cada um.
// Se o municipio em questão possuir uma apuração muito diferente, este municipio
// deverá ter uma classe própria que herdará de APURISSMUN e terá seu próprio
// método "apurar()" (Override).
For nX := 1 to Len(Self:aMunic)
    oApurMun := Self:aMunic[nX]
    oApurMun:apurar()
Next nX

Return

//------------------------------------------------------------- ------
/*/{Protheus.doc} saveApur()

Método responsável por gravar a apuração nas tabelas do banco.

@author joao.pellegrini
@since 12/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method saveApur() Class APURISS

Local oModel := FwLoadModel("FISA300A")
Local oModelF1P := NIL
Local oModelF1N := NIL
Local oModelF1O := NIL
Local oModelF1R := NIL
Local oApurMun := NIL
Local oServico := NIL
Local aMunic := {}
Local aServicos := {}
Local aTitulos := {}
Local lRet := .F.
Local aErros := {}
Local nX := 0
Local nY := 0
Local lGrava := .F.
Local cErros := ""
Local oTitulo := NIL

// Abertura das tabelas.

dbSelectArea("F1P")
F1P->(dbSetOrder(1))

dbSelectArea("F1N")
F1N->(dbSetOrder(1))

dbSelectArea("F1O")
F1O->(dbSetOrder(1))

dbSelectArea("F1R")
F1R->(dbSetOrder(1))

// Como o Self:cID só é gerado nesta função, se ele já estiver preenchido
// e o método saveApur() for chamado novamente, farei um update da apuração.
// Caso contrário farei a gravação de uma nova apuração.
If Empty(Self:cID)
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    lGrava := .T.    
Else
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    lGrava := F1P->(DbSeek(xFilial("F1P") + Self:cID))    
EndIf

If lGrava

    // Ativa o modelo com a operação definida.
    oModel:Activate()

    // F1P - Apuração de ISS
    oModelF1P := oModel:GetModel("FISA300A")
    oModelF1P:Activate()

    // F1N - APuração de ISS por municipio
    oModelF1N := oModel:GetModel("FISA300AMUNICIPIO")
    oModelF1N:Activate()

    // F1O - Detalhamento da apuração por serviço
    oModelF1O := oModel:GetModel("FISA300ASERVICO")
    oModelF1O:Activate()

    // F1R - Títulos da apuração por município.
    oModelF1R := oModel:GetModel("FISA300ATITULO")
    oModelF1R:Activate()

    oModelF1P:SetValue("F1P_FILIAL", xFilial("F1P"))
    oModelF1P:SetValue("F1P_DTINI", Self:dDtIni)
    oModelF1P:SetValue("F1P_DTFIM", Self:dDtFim)

    Self:cID := oModelF1P:GetValue("F1P_ID")

    aMunic := Self:getApurMun()

    For nX := 1 to Len(aMunic)

        oApurMun := aMunic[nX]

        //-----------------------------------------------
        // GRAVAÇÃO DA F1N - APURAÇÃO POR MUNICIPIO
        //-----------------------------------------------

        If !(oModelF1N:SeekLine( { {"F1N_IDAPUR", oModelF1P:GetValue("F1P_ID") }, { "F1N_UF", oApurMun:getUF() }, { "F1N_CODMUN", oApurMun:getMunic() } }, .F. , .T. ))
            If nX > 1 // O grid já começa com uma linha...então só chamo AddLine() da 2a em diante.
                oModelF1N:AddLine()
            EndIf 
        EndIf

        oModelF1N:SetValue("F1N_FILIAL", xFilial("F1N"))
        oModelF1N:SetValue("F1N_IDAPUR", oModelF1P:GetValue("F1P_ID"))
        oModelF1N:SetValue("F1N_UF", oApurMun:getUF())
        oModelF1N:SetValue("F1N_CODMUN", oApurMun:getMunic())
        oModelF1N:SetValue("F1N_ISSPRO", oApurmun:getISSProp())
        oModelF1N:SetValue("F1N_ISSSUB", oApurmun:getISSSub())
        oModelF1N:SetValue("F1N_ISSUNI", oApurmun:getISSUni())
        oModelF1N:SetValue("F1N_DEDPRP", oApurMun:getDedProp())        
        oModelF1N:SetValue("F1N_DEDSUB", oApurMun:getDedSub())
        oModelF1N:SetValue("F1N_DEDUNI", oApurMun:getDedUni())
        oModelF1N:SetValue("F1N_RECUNI", oApurmun:getRecUni())
        oModelF1N:SetValue("F1N_QTDUNI", oApurmun:getProfHab())
        oModelF1N:SetValue("F1N_VLFUNI", oApurmun:getVlMensal())
        oModelF1N:SetValue("F1N_STATUS", oApurmun:getStatus())

        //-----------------------------------------------
        // GRAVAÇÃO DA F1O - SERVIÇOS
        //-----------------------------------------------

        // Não vou regravar os movimentos. Só faço na inclusão.
        If oModel:GetOperation() == MODEL_OPERATION_INSERT

            aServicos := oApurmun:getServicos()

            For nY := 1 to Len(aServicos)

                oServico := aServicos[nY]
                
                If nY > 1 // O grid já começa com uma linha...então só chamo AddLine() da 2a em diante.
                    oModelF1O:AddLine()
                EndIf

                oModelF1O:SetValue("F1O_FILIAL", xFilial("F1O"))
                oModelF1O:SetValue("F1O_IDAPUR", oModelF1N:GetValue("F1N_ID"))
                oModelF1O:SetValue("F1O_CODISS", oServico:getCodISS())
                oModelF1O:SetValue("F1O_VLCONT", oServico:getValCont())
                oModelF1O:SetValue("F1O_MATTER", oServico:getMatTerc())
                oModelF1O:SetValue("F1O_MATPRO", oServico:getMatProp())
                oModelF1O:SetValue("F1O_SUBEMP", oServico:getSubEmp())
                oModelF1O:SetValue("F1O_VLISEN", oServico:getIsent())
                oModelF1O:SetValue("F1O_BSCALC", oServico:getBsCalc())
                oModelF1O:SetValue("F1O_BSRETP", oServico:getBsRetPr())
                oModelF1O:SetValue("F1O_ISSDES", oServico:getISSDest())
                oModelF1O:SetValue("F1O_ISRETP", oServico:getISSRetP())
                oModelF1O:SetValue("F1O_ISRETA", oServico:getISSRetA())

                //FreeObj(oServico)
                //oServico := NIL

            Next nY

        EndIf

        //-----------------------------------------------
        // GRAVAÇÃO DA F1R - TITULOS
        //-----------------------------------------------

        aTitulos := oApurMun:getTitulos()

        For nY := 1 to Len(aTitulos)

            oTitulo := aTitulos[nY]

            If !(oModelF1R:SeekLine( { {"F1R_TPIMP", oTitulo:getTpImp() } }, .F. , .T. ))
                If nY > 1 // O grid já começa com uma linha...então só chamo AddLine() da 2a em diante.
                    oModelF1R:AddLine()
                EndIf
            EndIF

            oModelF1R:SetValue("F1R_IDAPUR", oModelF1N:GetValue("F1N_ID"))
            oModelF1R:LoadValue("F1R_TPIMP", oTitulo:getTpImp())
            oModelF1R:SetValue("F1R_PREFIX", oTitulo:getPrefixo())
            oModelF1R:SetValue("F1R_NUM", oTitulo:getNumTit())
            oModelF1R:SetValue("F1R_PARC", oTitulo:getParcela())
            oModelF1R:SetValue("F1R_TIPO", oTitulo:getTipo())
            oModelF1R:SetValue("F1R_FORN", oTitulo:getFornec())
            oModelF1R:SetValue("F1R_LOJA", oTitulo:getLoja())
            oModelF1R:SetValue("F1R_NATURE", oTitulo:getNaturez())
            oModelF1R:LoadValue("F1R_VALOR", oTitulo:getValor())
            oModelF1R:SetValue("F1R_VENCTO", oTitulo:getDtVenc())
            oModelF1R:SetValue("F1R_STATUS", oTitulo:getStatus())


            //FreeObj(oTitulo)
            //oTitulo := NIL

        Next nY

        // Atualiza o ID do objeto oApurmun com o ID gerado...
        oApurmun:setID(oModelF1N:GetValue("F1N_ID"))

        //FreeObj(oApurMun)
        //oApurMun := NIL

    Next nX

    If oModel:VldData()    
        lRet := oModel:CommitData()
    Else
        aErros := oModel:GetErrorMessage()

         For nX := 1 To Len(aErros)
            If !Empty(aErros[nX])
                cErros += Alltrim(aErros[nX]) + Chr(13) + Chr(10)
            EndIf
        Next nX

        Alert(STR0002 + Chr(13) + Chr(10) + cErros)//"Ocorreram erros durante a gravação: "
    EndIf

    oModel:DeActivate()
    oModel:Destroy()

EndIf

// Limpando arrays e liberando memória...

aSize(aMunic, 0)
aMunic := NIL

aSize(aServicos, 0)
aServicos := NIL

aSize(aTitulos, 0)
aTitulos := NIL

aSize(aErros, 0)
aErros := NIL

Return lRet

//------------------------------------------------------------- ------
/*/{Protheus.doc} loadApur()

Método responsável por efetuar a carga das tabelas da apuração para a
memória.

@author joao.pellegrini
@since 13/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method loadApur(cIDApur) Class APURISS

Local cAlsF1N := ""
Local cAlsF1P := ""
Local aParams := {}
Local oApurMun := NIL
Local lRet := .F.

// Executa o método clear para evitar duplicidade nas listas da apuração.
Self:clear()

// Obtenho os dados do cabeçalho da apuração (F1P)
aParams := {cIDApur}
cAlsF1P := Self:execQuery("F1P", aParams)

If ((cAlsF1P)->(!Eof()))
    
    Self:cFilApu := (cAlsF1P)->F1P_FILIAL
    Self:cID := (cAlsF1P)->F1P_ID
    Self:dDtIni := StoD((cAlsF1P)->F1P_DTINI)
    Self:dDtFim := StoD((cAlsF1P)->F1P_DTFIM)
    
    // Primeiro obtenho os municípios apurados (F1N)
    aParams := {Self:cID}
    cAlsF1N := Self:execQuery("F1N", aParams)

    While ((cAlsF1N)->(!Eof()))
        
        // Passo o ID para o construtor para futura utilização no loadServicos e loadDeducoes.
        oApurMun := APURISSMUN():New((cAlsF1N)->F1N_ID)

        oApurMun:setCodIBGE(RetUfIBGE((cAlsF1N)->F1N_UF) + (cAlsF1N)->F1N_CODMUN)
        oApurMun:setISSProp((cAlsF1N)->F1N_ISSPRO)
        oApurMun:setISSSub((cAlsF1N)->F1N_ISSSUB)
        oApurMun:setISSUni((cAlsF1N)->F1N_ISSUNI)
        oApurMun:setDedProp((cAlsF1N)->F1N_DEDPRP)
        oApurMun:setDedSub((cAlsF1N)->F1N_DEDSUB)
        oApurMun:setDedUni((cAlsF1N)->F1N_DEDUNI)
        oApurMun:setRecUni((cAlsF1N)->F1N_RECUNI)
        oApurMun:setProfHab((cAlsF1N)->F1N_QTDUNI)
        oApurMun:setVlMensal((cAlsF1N)->F1N_VLFUNI)
        oApurMun:setStatus((cAlsF1N)->F1N_STATUS)

        // Carrega os movimentos da apuração do município (F1O)
        oApurMun:loadServicos()

        // Carrega as deduções da apuração do município (F1Q).
        oApurMun:loadDeducoes()

        // Carrega os títulos da apuração do município (F1R).
        oApurMun:loadTitulos()

        // Adiciona o municipio na lista..
        Self:addMunic(oApurMun)

        (cAlsF1N)->(dbSkip())

    EndDo

    // Fechando Alias
    (cAlsF1P)->(dbCloseArea())
    (cAlsF1N)->(dbCloseArea())
    
    // P/ indicar que uma apuração foi carregada
    lRet := .T.

EndIf

aSize(aParams, 0)
aParams := NIL

Return lRet

//------------------------------------------------------------- ------
/*/{Protheus.doc} deleteApur()

Método responsável por excluir uma apuração.

@author joao.pellegrini
@since 14/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method deleteApur() Class APURISS

Local lRet := .F.
Local oModel := FwLoadModel("FISA300A")
Local lFind := .F.

dbSelectArea("F1P")
F1P->(dbSetOrder(1))

oModel:SetOperation(MODEL_OPERATION_DELETE)
oModel:Activate()

lFind := F1P->(DbSeek(xFilial("F1P") + Self:cID))    

If lFind
    lRet := oModel:CommitData()
EndIf

oModel:DeActivate()
oModel:Destroy()

Return lRet

//------------------------------------------------------------- ------
/*/{Protheus.doc} execQuery()

Método responsável por centralizar as queries executadas pela apuração.

@author joao.pellegrini
@since 13/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method execQuery(cTpQuery, aParams) Class APURISS

Local cAlsQry := ""
Local cSelect := ""
Local cFrom := ""
Local cWhere := ""
Local cOrder := ""

Do Case
    
    Case cTpQuery == "F1P"

        cSelect := "F1P.F1P_FILIAL, F1P.F1P_ID, F1P.F1P_DTINI, F1P.F1P_DTFIM "

        cFrom := RetSqlName("F1P") + " F1P "

        cWhere := "F1P.F1P_FILIAL = " + ValToSql(xFilial("F1P")) + " AND "
        cWhere += "F1P.F1P_ID = " + ValToSql(aParams[1]) + " AND "
        cWhere += "F1P.D_E_L_E_T_ = ' ' "

    Case cTpQuery == "F1N"

        cSelect := "F1N.F1N_ID, F1N.F1N_UF, F1N.F1N_CODMUN, F1N.F1N_ISSPRO, F1N.F1N_ISSSUB, F1N.F1N_ISSUNI, F1N.F1N_DEDPRP, F1N.F1N_DEDSUB, F1N.F1N_DEDUNI, F1N.F1N_RECUNI, "
        cSelect += "F1N.F1N_QTDUNI, F1N.F1N_VLFUNI, F1N.F1N_STATUS "
        
        cFrom := RetSqlName("F1N") + " F1N "
        
        cWhere := "F1N.F1N_FILIAL = " + ValToSql(xFilial("F1N")) + " AND "
        cWhere += "F1N.F1N_IDAPUR = " + ValToSql(aParams[1]) + " AND "
        cWhere += "F1N.D_E_L_E_T_ = ' ' "

        cOrder := "ORDER BY F1N.F1N_UF, F1N.F1N_CODMUN "      

EndCase

// Preparando a expressão para executar a query.

cSelect := "%" + cSelect + "%"
cFrom := "%" + cFrom + "%"
cWhere := "%" + cWhere + cOrder + "%"

cAlsQry := GetNextAlias()

BeginSQL Alias cAlsQry

    SELECT
        %Exp:cSelect%
    FROM
        %Exp:cFrom%
    WHERE
        %Exp:cWhere%

EndSql

dbSelectArea(cAlsQry)
(cAlsQry)->(dbGotop())

Return cAlsQry

//-------------------------------------------------------------------
// GETTERS E SETTERS
//-------------------------------------------------------------------

Method getFilApu() Class APURISS
Return Self:cFilApu

Method setFilApu(cFilApu) Class APURISS
Self:cFilApu := cFilApu
Return

Method getID() Class APURISS
Return Self:cID

Method getDtIni() Class APURISS
Return Self:dDtIni

Method setDtIni(dDtIni) Class APURISS
Self:dDtIni := dDtIni
Return

Method getDtFim() Class APURISS
Return Self:dDtFim

Method setDtFim(dDtFim) Class APURISS
Self:dDtFim := dDtFim
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getApurMun()

Método responsável por retornar a apuração de um município específico.

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method getApurMun(cCodMun) Class APURISS

Local aRet := {}
Local nPosMun := 0

DEFAULT cCodMun := ""

// Se não passar um código específico retorno a lista completa.
If cCodMun == ""
    aRet := aClone(Self:aMunic)
ElseIf (nPosMun := aScan(Self:aMunic, {|x| AllTrim(x:getCodIBGE()) == AllTrim(cCodMun)})) > 0
    aAdd(aRet, Self:aMunic[nPosMun])
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} APURISSMOV()

Classe que representa a movimentação a ser apurada.

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Class APURISSMOV

Data cCodISS as Character // Codigo do serviço
Data nValCont as Numeric  // Valor contábil
Data nMatTerc as Numeric  // Valor do material fornecido por terceiros na prestação do serviço
Data nMatProp as Numeric  // Valor do material próprio utilizado na prestação do serviço
Data nSubEmp as Numeric   // Valor da subempreitada
Data nIsent as Numeric    // Valor da operação isenta
Data nBsCalc as Numeric   // Base de cálculo do ISS destacado
Data nBsRetPr as Numeric  // Base de cálculo do ISS retido das prestações
Data nISSDest as Numeric  // Valor do ISS destacado 
Data nISSRetP as Numeric  // Valor do ISS retido nas prestações
Data nISSRetA as Numeric  // Valor do ISS retido nas aquisições

Method new() CONSTRUCTOR
Method somarMov(oObjMov)

Method getCodISS()
Method setCodISS(cCodISS)
Method getValCont()
Method setValCont(nValCont)
Method getMatTerc()
Method setMatTerc(nMatTerc)
Method getMatProp()
Method setMatProp(nMatProp)
Method getSubEmp()
Method setSubEmp(nSubEmp)
Method getIsent()
Method setIsent(nIsent)
Method getBsCalc()
Method setBsCalc(nBsCalc)
Method getBsRetPr()
Method setBsRetPr(nBsRetPr)
Method getISSDest()
Method setISSDest(nISSDest)
Method getISSRetP()
Method setISSRetP(nISSRetP)
Method getISSRetA()
Method setISSRetA(nISSRetA)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Construtor da classe

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method new() Class APURISSMOV

Self:cCodISS := "" 
Self:nValCont := 0
Self:nMatTerc := 0
Self:nMatProp := 0
Self:nSubEmp := 0
Self:nIsent := 0
Self:nBsCalc := 0
Self:nBsRetPr := 0
Self:nISSDest := 0
Self:nISSRetP := 0
Self:nISSRetA := 0

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} somarMov()

Método utilizado para atualizar os valores de um objeto do tipo APURISSMOV
com os valores de outro objeto do mesmo tipo.

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method somarMov(oObjMov) Class APURISSMOV

Self:nValCont += oObjMov:getValCont()
Self:nMatTerc += oObjMov:getMatTerc()
Self:nMatProp += oObjMov:getMatProp()
Self:nSubEmp += oObjMov:getSubEmp()
Self:nIsent += oObjMov:getIsent()
Self:nBsCalc += oObjMov:getBsCalc()
Self:nBsRetPr += oObjMov:getBsRetPr()
Self:nISSDest += oObjMov:getISSDest()
Self:nISSRetP += oObjMov:getISSRetP()
Self:nISSRetA += oObjMov:getISSRetA()

Return

//-------------------------------------------------------------------
// GETTERS E SETTERS
//-------------------------------------------------------------------

Method getCodISS() Class APURISSMOV
Return Self:cCodISS

Method setCodISS(cCodISS) Class APURISSMOV
Self:cCodISS := cCodISS
Return

Method getValCont() Class APURISSMOV
Return Self:nValCont

Method setValCont(nValCont) Class APURISSMOV
Self:nValCont := nValCont
Return

Method getMatTerc() Class APURISSMOV
Return Self:nMatTerc

Method setMatTerc(nMatTerc) Class APURISSMOV
Self:nMatTerc := nMatTerc
Return

Method getMatProp() Class APURISSMOV
Return Self:nMatProp

Method setMatProp(nMatProp) Class APURISSMOV
Self:nMatProp := nMatProp
Return

Method getSubEmp() Class APURISSMOV
Return Self:nSubEmp

Method setSubEmp(nSubEmp) Class APURISSMOV
Self:nSubEmp := nSubEmp
Return

Method getIsent() Class APURISSMOV
Return Self:nIsent

Method setIsent(nIsent) Class APURISSMOV
Self:nIsent := nIsent
Return

Method getBsCalc() Class APURISSMOV
Return Self:nBsCalc

Method setBsCalc(nBsCalc) Class APURISSMOV
Self:nBsCalc := nBsCalc
Return

Method getBsRetPr() Class APURISSMOV
Return Self:nBsRetPr

Method setBsRetPr(nBsRetPr) Class APURISSMOV
Self:nBsRetPr := nBsRetPr
Return

Method getISSDest() Class APURISSMOV
Return Self:nISSDest

Method setISSDest(nISSDest) Class APURISSMOV
Self:nISSDest := nISSDest
Return

Method getISSRetP() Class APURISSMOV
Return Self:nISSRetP

Method setISSRetP(nISSRetP) Class APURISSMOV
Self:nISSRetP := nISSRetP
Return

Method getISSRetA() Class APURISSMOV
Return Self:nISSRetA

Method setISSRetA(nISSRetA) Class APURISSMOV
Self:nISSRetA := nISSRetA
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} APURISSMUN()

Classe que representa a apuração de um município em questão.

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Class APURISSMUN

Data cID as Character      // ID da apuração p/ gravação na F1N
Data cCodIBGE as Character // Código do município (IBGE)
Data nISSProp as Numeric   // Valor do ISS próprio apurado
Data nISSSub as Numeric    // Valor do ISS substituto apurado
Data nISSUni as Numeric    // Valor do ISS de sociedades uniprofissionais
Data nDedProp as Numeric   // Valor das deduções do ISS próprio
Data nDedSub as Numeric    // Valor das deduções do ISS substituto.
Data nDedUni as Numeric    // Valor das deduções do ISS Uniprofissional
Data nRecUni as Numeric    // Valor da receita do ISS Uniprofissional
Data nISSUniDev as Numeric // Valor do ISS Uniprofissional devido (Valor bruto - sem descontar as deduções)
Data nProfHab as Numeric   // Quantidade de profissionais habilitados (utilizado no cálculo do ISS Uniprofissional)
Data nVlMensal as Numeric  // Valor mensal devido por cada profissional da sociedade uniprofissional
Data cStatus as Character  // Status da apuração

Data aDeducoes as Array    // Array de deduções a serem aplicadas sobre os valores apurados
Data aServicos as Array    // Array de serviços apurados
Data aTitulos as Array     // Array de títulos e guias gerados pela apuração

Method new(cIDF1N) CONSTRUCTOR
Method clear()

Method addDeducao(oObjDed)
Method loadDeducoes()
Method clearDeducoes()

Method addServico(oObjMov)
Method loadServicos()
Method clearServicos()

Method addTitulo(oObjTit)
Method loadTitulos()
Method clearTitulos()

Method apurar()

Method getID()
Method setID(cID)
Method getCodIBGE()
Method setCodIBGE(cCodIBGE)
Method getUF()
Method getMunic()
Method getISSProp()
Method setISSProp(nISSProp)
Method getISSSub()
Method setISSSub(nISSSub)
Method getISSUni()
Method setISSUni(nISSUni)
Method getISSUniDev()
Method getDedProp()
Method setDedProp(nDedProp)
Method getDedSub()
Method setDedSub(nDedSub)
Method getDedUni()
Method setDedUni(nDedUni)
Method getRecUni()
Method setRecUni(nRecUni)
Method getProfHab()
Method setProfHab(nProfHab)
Method getVlMensal()
Method setVlMensal(nVlMensal)
Method getStatus()
Method setStatus(cStatus)

Method getDeducoes()
Method getServicos()
Method getTitulos()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Construtor da classe

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method new(cIDF1N) Class APURISSMUN

Self:clear()

Self:cId := cIDF1N

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} clear()

Método responsável por efetuar a limpeza dos arrays utilizados 
pela classe.

@author joao.pellegrini
@since 18/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method clear() Class APURISSMUN

Self:cID := ""
Self:cCodIBGE := ""
Self:nISSProp := 0
Self:nISSSub := 0
Self:nISSUni := 0
Self:nDedProp := 0
Self:nDedSub := 0
Self:nDedUni := 0
Self:nRecUni := 0
Self:nProfHab := 0
Self:nVlMensal := 0
Self:cStatus := "1" //Cria apuração com Status 1, apurado

Self:clearDeducoes()
Self:clearServicos()
Self:clearTitulos()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addServico()

Método responsável por adicionar um serviço na apuração por município.

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method addServico(oObjMov) Class APURISSMUN

Local nPosServ := 0
Local oMovAgrup := NIL

If (nPosServ := aScan(Self:aServicos, {|x| AllTrim(x:getCodISS()) == AllTrim(oObjMov:getCodISS())})) == 0
    aAdd(Self:aServicos, oObjMov)
Else
    Self:aServicos[nPosServ]:somarMov(oObjMov)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addDeducao()

Método responsável por adicionar uma dedução na apuração do municipio

@author joao.pellegrini
@since 14/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method addDeducao(oObjDed) Class APURISSMUN

// Adiciono a dedução na lista de deduções.
aAdd(Self:aDeducoes, oObjDed)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} loadDeducoes()

Método responsável por carregar as deduções no objeto a partir da 
tabela F1Q.

@author joao.pellegrini
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method loadDeducoes() Class APURISSMUN

Local cAlsF1Q := GetNextAlias()
Local oObjDed := NIL
Local cIDApur := Self:cID

// Limpa a lista antes da carga.
Self:clearDeducoes()

BeginSQL Alias cAlsF1Q
    SELECT
        F1Q.F1Q_TPDED, F1Q.F1Q_VLDED, F1Q.F1Q_NUMPRO, F1Q.F1Q_ORIPRO, F1Q.F1Q_DESPRO, F1Q.F1Q_CODOBS, F1Q.F1Q_INDOBR
    FROM 
        %Table:F1Q% F1Q
    WHERE
        F1Q.F1Q_FILIAL = %xFilial:F1Q% AND
        F1Q.F1Q_IDAPUR = %Exp:cIdApur% AND
        F1Q.%NotDel%
EndSql

dbSelectArea(cAlsF1Q)
(cAlsF1Q)->(dbGoTop())

While ((cAlsF1Q)->(!Eof()))            

    oObjDed := APURISSDED():new()
    oObjDed:setTpDed((cAlsF1Q)->F1Q_TPDED)
    oObjDed:setValor((cAlsF1Q)->F1Q_VLDED)
    oObjDed:setNumProc((cAlsF1Q)->F1Q_NUMPRO)
    oObjDed:setOriProc((cAlsF1Q)->F1Q_ORIPRO)
    oObjDed:setDesProc((cAlsF1Q)->F1Q_DESPRO)
    oObjDed:setCodObs((cAlsF1Q)->F1Q_CODOBS)
    oObjDed:setIndObr((cAlsF1Q)->F1Q_INDOBR)

    Self:addDeducao(oObjDed)

    (cAlsF1Q)->(dbSkip())

EndDo

(cAlsF1Q)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clearDeducoes()

Método responsável por limpar a lista de deduções.

@author joao.pellegrini
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method clearDeducoes() Class APURISSMUN

Local nX := 0

// Laço na lista de deduções
If ValType(Self:aDeducoes) == "A"
    For nX := 1 to Len(Self:aDeducoes)        
        //Destroi objeto por serviço
        FreeObj(Self:aDeducoes[nX])   
        Self:aDeducoes[nX] := Nil         
    Next nX
EndIf

Self:aDeducoes := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} loadServicos()

Método responsável por carregar os movimentos no objeto a partir da 
tabela F1O.

@author joao.pellegrini
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method loadServicos() Class APURISSMUN

Local cAlsF1O := GetNextAlias()
Local oObjMov := NIL
Local cIdApur := Self:cID

// Limpa a lista antes da carga.
Self:clearServicos()

BeginSQL Alias cAlsF1O

    SELECT
        F1O.F1O_CODISS, F1O.F1O_VLCONT, F1O.F1O_MATTER, F1O.F1O_MATPRO, F1O.F1O_SUBEMP, F1O.F1O_VLISEN, F1O.F1O_BSCALC, F1O.F1O_BSRETP, F1O.F1O_ISSDES, F1O.F1O_ISRETP, F1O.F1O_ISRETA
    FROM
        %Table:F1O% F1O
    WHERE
       F1O.F1O_FILIAL = %xFilial:F1O% AND
       F1O.F1O_IDAPUR = %Exp:cIdApur% AND
       F1O.%NotDel%
    ORDER BY F1O.F1O_CODISS

EndSql

dbSelectArea(cAlsF1O)
(cAlsF1O)->(dbGoTop())

While ((cAlsF1O)->(!Eof()))

    oObjMov := APURISSMOV():New()

    oObjMov:setCodISS((cAlsF1O)->F1O_CODISS)
    oObjMov:setValCont((cAlsF1O)->F1O_VLCONT)
    oObjMov:setMatTerc((cAlsF1O)->F1O_MATTER)
    oObjMov:setMatProp((cAlsF1O)->F1O_MATPRO)
    oObjMov:setSubEmp((cAlsF1O)->F1O_SUBEMP)
    oObjMov:setIsent((cAlsF1O)->F1O_VLISEN)
    oObjMov:setBsCalc((cAlsF1O)->F1O_BSCALC)
    oObjMov:setBsRetPr((cAlsF1O)->F1O_BSRETP)
    oObjMov:setISSDest((cAlsF1O)->F1O_ISSDES)
    oObjMov:setISSRetP((cAlsF1O)->F1O_ISRETP)
    oObjMov:setISSRetA((cAlsF1O)->F1O_ISRETA)

    Self:addServico(oObjMov)

    (cAlsF1O)->(dbSkip())

EndDo

(cAlsF1O)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clearServicos()

Método responsável por limpar a lista de serviços.

@author joao.pellegrini
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method clearServicos() Class APURISSMUN

Local nX := 0

//Laço na lista dos serviços
If ValType(Self:aServicos) == "A"
    For nX := 1 to Len(Self:aServicos)
        //Destroi objeto por serviço
        FreeObj(Self:aServicos[nX])   
        Self:aServicos[nX] := Nil         
    Next nX
EndIf

Self:aServicos := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addTitulo()

Método responsável por limpar a lista de serviços.

@author joao.pellegrini
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method addTitulo(oObjTit) Class APURISSMUN

// Adiciono a dedução na lista de deduções.
aAdd(Self:aTitulos, oObjTit)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} loadTitulos()

Método responsável por limpar a lista de serviços.

@author joao.pellegrini
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method loadTitulos() Class APURISSMUN

Local cAlsF1R := GetNextAlias()
Local oObjTit := NIL
Local cIdApur := Self:cID

// Limpa a lista antes da carga.
Self:clearTitulos()

BeginSQL Alias cAlsF1R

    SELECT
        COLUMN F1R_VENCTO AS DATE

        F1R.F1R_TPIMP, F1R.F1R_PREFIX, F1R.F1R_NUM, F1R.F1R_PARC, F1R.F1R_TIPO, F1R.F1R_FORN, F1R.F1R_LOJA, F1R.F1R_VALOR, F1R.F1R_VENCTO, F1R.F1R_NATURE, F1R.F1R_STATUS
    FROM
        %Table:F1R% F1R
    WHERE
       F1R.F1R_FILIAL = %xFilial:F1R% AND
       F1R.F1R_IDAPUR = %Exp:cIdApur% AND
       F1R.%NotDel%
    ORDER BY F1R.F1R_TPIMP, F1R.F1R_NUM

EndSql

dbSelectArea(cAlsF1R)
(cAlsF1R)->(dbGoTop())

While ((cAlsF1R)->(!Eof()))

    oObjTit := APURISSTIT():New()

    oObjTit:setTpImp((cAlsF1R)->F1R_TPIMP)
    oObjTit:setPrefixo((cAlsF1R)->F1R_PREFIX)
    oObjTit:setNumTit((cAlsF1R)->F1R_NUM)
    oObjTit:setParcela((cAlsF1R)->F1R_PARC)
    oObjTit:setTipo((cAlsF1R)->F1R_TIPO)
    oObjTit:setFornec((cAlsF1R)->F1R_FORN)
    oObjTit:setLoja((cAlsF1R)->F1R_LOJA)
    oObjTit:setNaturez((cAlsF1R)->F1R_NATURE)
    oObjTit:setValor((cAlsF1R)->F1R_VALOR)
    oObjTit:setDtVenc((cAlsF1R)->F1R_VENCTO)
    oObjTit:setStatus((cAlsF1R)->F1R_STATUS)

    Self:addTitulo(oObjTit)

    (cAlsF1R)->(dbSkip())

EndDo

(cAlsF1R)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} clearServicos()

Método responsável por limpar a lista de serviços.

@author joao.pellegrini
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method clearTitulos() Class APURISSMUN

Local nX := 0

// Laço na lista de titulos
If ValType(Self:aTitulos) == "A"
    For nX := 1 to Len(Self:aTitulos)        
        //Destroi objeto por serviço
        FreeObj(Self:aTitulos[nX])   
        Self:aTitulos[nX] := Nil         
    Next nX
EndIf

Self:aTitulos := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} apurar()

Método responsável por apurar os valores devidos de ISS para o município.
ISS - Próprio, Substituto e Uniprofissional.

@author joao.pellegrini
@since 12/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method apurar() Class APURISSMUN

Local nX := 0
Local oObjDed := NIL
Local aDeducoes := {}

// Zero todos os valores de apuração pois todos serão recalculados.
Self:nISSProp   := 0
Self:nISSSub    := 0
Self:nISSUni    := 0
Self:nDedProp   := 0
Self:nDedSub    := 0
Self:nDedUni    := 0

// Totalizo os valores de ISS devidos..
For nX := 1 to Len(Self:aServicos)
    // Soma o valor do ISS destacado...
    Self:nISSProp += Self:aServicos[nX]:getISSDest()
    // Subtrai o valor do ISS retido nas prestações
    Self:nISSProp -= Self:aServicos[nX]:getISSRetP()
    // ISS Substituto - Retido nas aquisições.
    Self:nISSSub += Self:aServicos[nX]:getISSRetA()
Next nX

// ISS Uniprofissional - Parte da multiplicação de qtde de profissionais por valor mensal.
Self:nISSUni := Self:getISSUniDev()

aDeducoes := Self:getDeducoes()

// Totalizo as deduções
For nX := 1 to Len(aDeducoes)

    oObjDed := aDeducoes[nX]

    Do Case

        // ISS PROPRIO
        Case oObjDed:getIndObr() == "0"

            Self:nDedProp += oObjDed:getValor()  

        // ISS SUBSTITUTO
        Case oObjDed:getIndObr() == "1"

            Self:nDedSub += oObjDed:getValor()

        // ISS UNIPROFISSIONAL
        Case oObjDed:getIndObr() == "2"

            Self:nDedUni += oObjDed:getValor()

    EndCase

Next nX

// Aplicando deduções nos valores apurados...
Self:nISSProp -= Self:nDedProp
Self:nISSSub -= Self:nDedSub
Self:nISSUni -= Self:nDedUni

aSize(aDeducoes, 0)
aDeducoes := NIL

//FreeObj(oObjDed)
//oObjDed := NIL

Return

//-------------------------------------------------------------------
// GETTERS E SETTERS
//-------------------------------------------------------------------

Method getID() Class APURISSMUN
Return Self:cID

Method setID(cID) Class APURISSMUN
Self:cID := cID
Return

Method getCodIBGE() Class APURISSMUN
Return Self:cCodIBGE

Method setCodIBGE(cCodIBGE) Class APURISSMUN
Self:cCodIBGE := cCodIBGE
Return

Method getUF() Class APURISSMUN
Return RetUfIBGE(Left(Self:cCodIBGE, 2)) 

Method getMunic() Class APURISSMUN
Return Right(Self:cCodIBGE, 5)

Method getISSProp() Class APURISSMUN
Return Self:nISSProp

Method setISSProp(nISSProp) Class APURISSMUN
Self:nISSProp := nISSProp
Return

Method getISSSub() Class APURISSMUN
Return Self:nISSSub

Method setISSSub(nISSSub) Class APURISSMUN
Self:nISSSub := nISSSub
Return

Method getISSUni() Class APURISSMUN
Return Self:nISSUni

Method setISSUni(nISSUni) Class APURISSMUN
Self:nISSUni := nISSUni
Return

Method getISSUniDev() Class APURISSMUN
Return Round(Self:nProfHab * Self:nVlMensal, 2)

Method getDedProp() Class APURISSMUN
Return Self:nDedProp

Method setDedProp(nDedProp) Class APURISSMUN
Self:nDedProp := nDedProp
Return

Method getDedSub() Class APURISSMUN
Return Self:nDedSub

Method setDedSub(nDedSub) Class APURISSMUN
Self:nDedSub := nDedSub
Return

Method getDedUni() Class APURISSMUN
Return Self:nDedUni

Method setDedUni(nDedUni) Class APURISSMUN
Self:nDedUni := nDedUni
Return

Method getRecUni() Class APURISSMUN
Return Self:nRecUni

Method setRecUni(nRecUni) Class APURISSMUN
Self:nRecUni := nRecUni
Return

Method getProfHab() Class APURISSMUN
Return Self:nProfHab

Method setProfHab(nProfHab) Class APURISSMUN
Self:nProfHab := nProfHab
Return

Method getVlMensal() Class APURISSMUN
Return Self:nVlMensal

Method setVlMensal(nVlMensal) Class APURISSMUN
Self:nVlMensal := nVlMensal
Return

Method getStatus() Class APURISSMUN
Return Self:cStatus

Method setStatus(cStatus) Class APURISSMUN
Self:cStatus := cStatus
Return

Method getDeducoes() Class APURISSMUN
Return aClone(Self:aDeducoes)

Method getServicos() Class APURISSMUN
Return aClone(Self:aServicos)

Method getTitulos() Class APURISSMUN
Return aClone(Self:aTitulos)

//-------------------------------------------------------------------
/*/{Protheus.doc} APURISSDED

Classe que representa as deduções aplicaveis aos valores apurados

@author joao.pellegrini
@since 14/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Class APURISSDED

Data cTpDed as Character   // Tipo da dedução (ISS calculado a maior, benefício fiscal, etc...)
Data nValor as Numeric     // Valor da dedução
Data cNumProc as Character // Número do processo vinculado à dedução
Data cOriProc as Character // Origem do processo (Sefin, Justiça Federal, etc...)
Data cDesProc as Character // Descrição do processo
Data cCodObs  as Character // Código da observação (p/ geração do registro 0460)
Data cIndObr  as Character // Indicador da obrigação onde será aplicada a dedução (ISS próprio, substituto, uniprofissional)

Method new() CONSTRUCTOR

Method getTpDed()
Method setTpDed(cTpDed)
Method getValor()
Method setValor(nValor)
Method getNumProc()
Method setNumProc(cNumProc)
Method getOriProc()
Method setOriProc(cOriProc)
Method getDesProc()
Method setDesProc(cDesProc)
Method getCodObs()
Method setCodObs(cCodObs)
Method getIndObr()
Method setIndObr(cIndObr)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Construtor da classe

@author joao.pellegrini
@since 14/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method new() Class APURISSDED

Self:cTpDed := ""
Self:nValor := 0
Self:cNumProc := ""
Self:cOriProc := ""
Self:cDesProc := ""
Self:cCodObs := ""
Self:cIndObr := ""

Return Self

//-------------------------------------------------------------------
// GETTERS E SETTERS
//-------------------------------------------------------------------
Method getTpDed() Class APURISSDED
Return Self:cTpDed

Method setTpDed(cTpDed) Class APURISSDED
Self:cTpDed := cTpDed
Return

Method getValor() Class APURISSDED
Return Self:nValor

Method setValor(nValor) Class APURISSDED
Self:nValor := nValor
Return

Method getNumProc() Class APURISSDED
Return Self:cNumProc

Method setNumProc(cNumProc) Class APURISSDED
Self:cNumProc := cNumProc
Return

Method getOriProc() Class APURISSDED
Return Self:cOriProc

Method setOriProc(cOriProc) Class APURISSDED
Self:cOriProc := cOriProc
Return

Method getDesProc() Class APURISSDED
Return Self:cDesProc

Method setDesProc(cDesProc) Class APURISSDED
Self:cDesProc := cDesProc
Return

Method getCodObs() Class APURISSDED
Return Self:cCodObs

Method setCodObs(cCodObs) Class APURISSDED
Self:cCodObs := cCodObs
Return

Method getIndObr() Class APURISSDED
Return Self:cIndObr

Method setIndObr(cIndObr) Class APURISSDED
Self:cIndObr := cIndObr
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} APURISSTIT

Classe que representa os títulos gerados pela apuração

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Class APURISSTIT

Data cTpImp as Character    // Tipo do Imposto (ISS Próprio / Substituto / Uniprofissional)
Data cPrefixo as Character  // Prefixo do título
Data cNumTit as Character   // Número do título
Data cParcela as Character  // Parcela do título
Data cTipo as Character     // Tipo do título
Data cFornec as Character   // Fornecedor do título
Data cLoja as Character     // Loja do fornecedor do título
Data cNatureza as Character // Natureza do Título
Data nValor as Numeric      // Valor do título
Data dDtVenc as Date        // Data de vencimento do título
Data cStatus as Character   // Status do título

Method new() CONSTRUCTOR

Method getTpImp()
Method setTpImp(cTpImp)
Method getPrefixo()
Method setPrefixo(cPrefixo)
Method getNumTit()
Method setNumTit(cNumTit)
Method getParcela()
Method setParcela(cParcela)
Method getTipo()
Method setTipo(cTipo)
Method getFornec()
Method setFornec(cFornec)
Method getLoja()
Method setLoja(cLoja)
Method getNaturez()
Method setNaturez(cNatureza)
Method getValor()
Method setValor(nValor)
Method getDtVenc()
Method setDtVenc(dDtVenc)
Method getStatus()
Method setStatus(cStatus)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Construtor da classe

@author joao.pellegrini
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method new() Class APURISSTIT

Self:cTpImp := ""
Self:cPrefixo := ""
Self:cNumTit := ""
Self:cParcela := ""
Self:cTipo := ""
Self:cFornec := ""
Self:cLoja := ""
Self:cNatureza := ""
Self:nValor := 0
Self:dDtVenc := CtoD("//")
Self:cStatus := "1" // Inicializa como "1 - Não gerado"

Return Self

//-------------------------------------------------------------------
// GETTERS E SETTERS
//-------------------------------------------------------------------

Method getTpImp() Class APURISSTIT
Return Self:cTpImp

Method setTpImp(cTpImp) Class APURISSTIT
Self:cTpImp := cTpImp
Return

Method getPrefixo() Class APURISSTIT
Return Self:cPrefixo

Method setPrefixo(cPrefixo) Class APURISSTIT
Self:cPrefixo := cPrefixo
Return

Method getNumTit() Class APURISSTIT
Return Self:cNumTit

Method setNumTit(cNumTit) Class APURISSTIT
Self:cNumTit := cNumTit
Return

Method getParcela() Class APURISSTIT
Return Self:cParcela

Method setParcela(cParcela) Class APURISSTIT
Self:cParcela := cParcela
Return

Method getTipo() Class APURISSTIT
Return Self:cTipo

Method setTipo(cTipo) Class APURISSTIT
Self:cTipo := cTipo
Return

Method getFornec() Class APURISSTIT
Return Self:cFornec

Method setFornec(cFornec) Class APURISSTIT
Self:cFornec := cFornec
Return

Method getLoja() Class APURISSTIT
Return Self:cLoja

Method setLoja(cLoja) Class APURISSTIT
Self:cLoja := cLoja
Return

Method getNaturez() Class APURISSTIT
Return Self:cNatureza

Method setNaturez(cNatureza) Class APURISSTIT
Self:cNatureza := cNatureza
Return

Method getValor() Class APURISSTIT
Return Self:nValor

Method setValor(nValor) Class APURISSTIT
Self:nValor := nValor
Return

Method getDtVenc() Class APURISSTIT
Return Self:dDtVenc

Method setDtVenc(dDtVenc) Class APURISSTIT
Self:dDtVenc := dDtVenc
Return

Method getStatus() Class APURISSTIT
Return Self:cStatus

Method setStatus(cStatus) Class APURISSTIT
Self:cStatus := cStatus
Return 