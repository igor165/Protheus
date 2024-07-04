#Include "GTPA421F.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA421F
Realiza estorno da ficha
@type  Function
@author user
@since 23/11/2021
@version version
@example
(examples)
@see (links_or_references)
/*/
Function GTPA421F()
Local aNewFlds  := {'G6X_USUREA', 'G6X_DATREA', 'G6X_HORREA'}
Local lNewFlds  := GTPxVldDic('G6X', aNewFlds, .F., .T.)
Local cMsgErro  := ''
Local cAgencia  := G6X->G6X_AGENCI
Local cNumFch   := G6X->G6X_NUMFCH

If ( GA421FVal() .AND. lNewFlds )
    If ValidFicha(cAgencia, cNumFch, @cMsgErro)
        
        If G6X->G6X_STATUS $ '2'
            FWMsgRun(, {|| ProcFicha(cAgencia, cNumFch)},"", STR0001) //"Efetuando estorno da ficha..."
        Else
            FwAlertHelp(STR0002,STR0003) //"Status da Ficha" //"Apenas fichas de remessa com status em entregue podem efetuar estorno"
        EndIf
    Else
        FwAlertHelp("ValidFicha",cMsgErro)
    EndIf
Else
    FwAlertHelp(STR0004,STR0005) //"Dicionário desatualizado" //"Atualize o dicionário para utilizar esta rotina"
EndIf
Return 

/*/{Protheus.doc} GA421FVal
(long_description)
@type  Function
@author user
@since 23/11/2021
@version version
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GA421FVal()

Local cCodGrupSup	:= GTPGetRules('GRUPOSUP', .F. , , '')
Local cUsuario      := __cUserID
Local aGrpsUser		:= FwSFUsrGrps(cUsuario)
Local aArea         := GetArea()
Local lRet          := .F.

If !(Empty(cCodGrupSup))
    GYF->(dbSetOrder((1)))
        
    If GYF->(dbSeek(xFilial('GYF')+'GRUPOSUP')) .And. aScan(aGrpsUser,{|x| AllTrim(x) == AllTrim(GYF->GYF_CONTEU)})
        lRet := .T.
    Endif
Else
    lRet := .T.
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} ProcFicha
(long_description)
@type  Static Function
@author user
@since 23/11/2021
@version version
@param cNumFch, caracter, numero da ficha
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ProcFicha(cAgencia, cNumFch)

Local lRet := .T.

//efetuar estorno do titulo -- ultima coisa a ser feito
lRet := A421ExcTitRec()

//Efetuar a gravação dos novos campos e modificar o status da ficha para 5-reaberto - Campos criados
If lRet
    AjustG6X(cAgencia, cNumFch)
EndIf

//Ai avaliar todos os processos que utilizam o status 1 que é o aberto e adicionar na validação o novo status - Feito


Return 

/*/{Protheus.doc} ValidFicha
efetua validação de estorno da ficha
@type  Static Function
@author user
@since 23/11/2021
@version version
@param cNumFch, caracter, numero da ficha
@return lRet, boolean, Retorna se é possivel executar o estorno da ficha
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidFicha(cAgencia, cNumFch, cMsgErro)

Local lRet       := .T.
Local cAliasG59  := GetNextAlias()
Local cAliasGQ6  := GetNextAlias()

//Validação tesouraria
G6X->(DbSetOrder(3))
If G6X->(DbSeek(XFILIAL("G6X") + cAgencia + cNumFch))
    If G6X->G6X_FLAGCX .AND. !(EMPTY(G6X->G6X_CODCX))
        lRet     := .F.
        cMsgErro := STR0006 //'Existe caixa aberto na tesouraria para essa ficha.'
    EndIf
EndIf
    
//Validação arrecadação
If lRet
    BeginSql Alias cAliasG59  
        SELECT 
            G59.R_E_C_N_O_ RECNOG59
        FROM 
            %Table:G59% G59
        WHERE 
            G59.G59_FILIAL = %xFilial:G59%
            AND G59.G59_AGENCI = %Exp:cAgencia% 
            AND G59.G59_NUMFCH = %Exp:cNumFch%    
            AND G59.%NotDel%   
    EndSql

    If ((cAliasG59)->(!EOF()))
        lRet     := .F.
        cMsgErro := STR0007 //'Existe arrecadação aberta para essa ficha.'
    EndIf

    (cAliasG59)->(DbCloseArea())
EndIf

//Validação comissão
If lRet
    BeginSql Alias cAliasGQ6  
        SELECT 
            GQ6.R_E_C_N_O_ RECNOGQ6
        FROM 
            %Table:GQ6% GQ6
        WHERE 
            GQ6.GQ6_FILIAL = %xFilial:GQ6%
            AND GQ6.GQ6_AGENCI = %Exp:cAgencia% 
            AND GQ6.GQ6_NUMFCH = %Exp:cNumFch%    
            AND GQ6.%NotDel%   
    EndSql

    If ((cAliasGQ6)->(!EOF()))
        lRet     := .F.
        cMsgErro := STR0008 //'Existe comissão aberta para essa ficha.'
    EndIf

    (cAliasGQ6)->(DbCloseArea())
EndIf

Return lRet


/*/{Protheus.doc} AjustG6X
    (long_description)
    @type  Static Function
    @author user
    @since 26/11/2021
    @version version
    @param cAgencia, param_type, param_descr
    @param cNumFch, param_type, param_descr
    @return lRet, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AjustG6X(cAgencia, cNumFch)
Local lRet      := .T.
Local cUserLog  := AllTrim(RetCodUsr())
Local aArea     := GetArea()
Local aAreaG6x  := G6X->(GetArea())

G6X->(DbSetOrder(3))
If G6X->(DbSeek(XFILIAL("G6X") + cAgencia + cNumFch))
    RecLock("G6X", .F.)
        G6X->G6X_STATUS := '5'
        G6X->G6X_USUREA := cUserLog
        G6X->G6X_DATREA := DDATABASE
        G6X->G6X_HORREA := SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2)
    G6X->(MsUnlock())
EndIf

RestArea(aAreaG6x)
RestArea(aArea)
Return lRet

/*/{Protheus.doc} A421ExcTitRec
    (long_description)
    @type  Static Function
    @author user
    @since 29/11/2021
    @version version
    @return lRet, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function A421ExcTitRec()
Local aTitSE1    := {}
Local cAgencia   := ""
Local cPrefixo   := ""
Local cNumFch    := ""
Local nValor     := 0
Local cParcela   := ""
Local cTipo      := ""
Local cFilialOri := ""
Local cNumerTit  := ""
Local cMsgErro   := ""
Local lRet       := .T.
Local cFilAtu	 := cFilAnt
Local nX         := 0
Local aLog       := {}
Local aNewFlds   := {'G6X_FILORI', 'G6X_PREFIX', 'G6X_E12TIT', 'G6X_PARCEL', 'G6X_TIPO', 'G6X_ORITIT'}
Local lNewFlds   := GTPxVldDic('G6X', aNewFlds, .F., .T.)
Local aArea 	 := GetArea()

Private lMsErroAuto         := .F.
Private lAutoErrNoFile      := .T.

cAgencia   := G6X->G6X_AGENCI
cNumFch    := G6X->G6X_NUMFCH
nValor     := G6X->G6X_VLTODE

If lNewFlds
    cPrefixo   := G6X->G6X_PREFIX
    cParcela   := G6X->G6X_PARCEL
    cTipo      := G6X->G6X_TIPO
    cFilialOri := G6X->G6X_FILORI
    cNumerTit  := G6X->G6X_E12TIT
Else
    lRet := .F.
EndIf

If lRet
    Begin Transaction
        
        aTitSE1	:= {}
        
        DbSelectArea("SE1")
        SE1->(DbSetOrder(1))//E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
        If SE1->(DbSeek(cFilialOri+cPrefixo+cNumerTit+cParcela+cTipo))
            
            aTitSE1 := {{ "E1_FILIAL"	, SE1->E1_FILIAL		            , Nil },; //Filial
                        { "E1_PREFIXO"	, SE1->E1_PREFIXO		            , Nil },; //Prefixo 
                        { "E1_NUM"		, SE1->E1_NUM  					    , Nil },; //Numero
                        { "E1_PARCELA"	, SE1->E1_PARCELA				    , Nil },; //Parcela
                        { "E1_TIPO"		, SE1->E1_TIPO					    , Nil },; //Tipo
                        { "E1_NATUREZ"	, SE1->E1_NATUREZ			        , Nil },; //Natureza
                        { "E1_CLIENTE"	, SE1->E1_CLIENTE				    , Nil },; //Cliente
                        { "E1_LOJA"		, SE1->E1_LOJA			 		    , Nil },; //Loja
                        { "E1_EMISSAO"	, SE1->E1_EMISSAO		         	, Nil },; //Data Emissão
                        { "E1_VENCTO"	, SE1->E1_VENCTO				    , Nil },; //Data Vencimento
                        { "E1_VENCREA"	, SE1->E1_VENCREA				    , Nil },; //Data Vencimento Real
                        { "E1_VALOR"	, SE1->E1_VALOR				        , Nil },; //Valor
                        { "E1_SALDO"	, SE1->E1_SALDO					    , Nil },; //Saldo
                        { "E1_HIST"		, SE1->E1_HIST						, Nil },; //HIstórico
                        { "E1_ORIGEM"	, "GTPA421" 						, Nil }}  //Origem

            MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // 5 - Exclusão

            If lMsErroAuto
                aLog := GetAutoGrLog()
			
                For nX := 1 To Len(aLog)
                    cMsgErro += aLog[nX]+CHR(13)+CHR(10)			
                Next nX

                FwAlertHelp("A421FExcTitRec",STR0010 + cMsgErro + STR0009) //", processo abortado" //"Ocorreu erro no estorno registro não encontrado"
                DisarmTransaction()
                lRet := .F.
            Endif
        EndIf
        
        cFilAnt  := cFilAtu
        
        If lRet
            RECLOCK("G6X",.F.)
            If lNewFlds
                G6X->G6X_FILORI := ""
                G6X->G6X_PREFIX := ""
                G6X->G6X_E12TIT := ""
                G6X->G6X_PARCEL := ""
                G6X->G6X_TIPO   := ""
                G6X->G6X_ORITIT := ""   
            Endif
            G6X->G6X_NUMTIT := ""
            G6X->(MsUnlock())       
        EndIf
        
    End Transaction
Else
    FwAlertHelp("A421FExcTitRec",STR0011) //"Ocorreu erro no estorno, processo abortado"
EndIf

RestArea(aArea)

Return lRet
