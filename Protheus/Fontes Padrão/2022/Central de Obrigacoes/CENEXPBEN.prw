#include 'protheus.ch'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#define lLinux IsSrvUnix()
#IFDEF lLinux
    #define CRLF Chr(13) + Chr(10)
    #define BARRA "/"
#ELSE
    #define CRLF Chr(10)
    #define BARRA "\"
#ENDIF
#DEFINE SIB_INCLUIR		"1" // Inclusão
#DEFINE SIB_RETIFIC		"2" // Retificação
#DEFINE SIB_MUDCONT		"3" // Mudança Contratual
#DEFINE SIB_CANCELA		"4" // Cancelamento
#DEFINE SIB_REATIVA		"5" // Reativação

Static _cGetDb := TCGetDB()
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

/*/{Protheus.doc} CENEXPBEN()
    Função responsável pela exportação de beneficiarios não enviados a ANS
    @since 10/05/2021
    @author david.juan
    @see (links_or_references)
/*/
Function CENEXPBEN()
    Local oExpBen := CenExpBen():New()
    Local lRet    := .F.

    if lHabMetric .and. lLibSupFw .and. lVrsAppSw
        FWMetrics():addMetrics("Benef. Não Env. a ANS", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
    endif

    Processa( { || lRet := oExpBen:execute() },"Exportando beneficiários que não foram enviados para a ANS","Aguarde...",.F.)
    oExpBen:destroy()
    oExpBen := Nil
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CenExpBen
Classe responsável pela exportação de beneficiarios não enviados a ANS

@since 10/05/2021
@author david.juan
/*/
//-------------------------------------------------------------------
Class CenExpBen FROM LongNameClass

    Data cFileName
    Data cFolder
    Data nHandle
    Data cAliasB3X
    Data cAliasB3K
    Data lRet

    Method New()
    Method destroy()
    Method execute()
    Method seekB3X()
    Method SelecBenef()
    Method saveFile(oResult)
    Method closeFile()

EndClass

Method New() Class CenExpBen
    self:cFileName   := ''
    self:cFolder     := ''
    self:nHandle     := -1
    self:lRet        := .F.
Return

Method destroy() Class CenExpBen
    self:cFileName   := ''
    self:cFolder     := ''
    self:nHandle     := 0
Return

Method seekB3X() Class CenExpBen
    Local cSQLSeek   := ""

    self:cAliasB3X := GetNextAlias()

    cSQLSeek := "SELECT "
    cSQLSeek += "B3X_CODOPE, "
    cSQLSeek += "B3X_OPERA, "
    cSQLSeek += "B3X_DATA, "
    cSQLSeek += "B3X_IDEORI, "
    cSQLSeek += "B3X_DESORI, "
    cSQLSeek += "B3X_CODCCO, "
    cSQLSeek += "B3X_STATUS, "
    cSQLSeek += "R_E_C_N_O_ AS RECNO "
    cSQLSeek += "FROM "
    cSQLSeek += RetSqlName("B3X")
    cSQLSeek += " WHERE B3X_FILIAL = '" + xFilial("B3X") + "'"
    cSQLSeek += " AND B3X_CODOPE = '" + B3D->B3D_CODOPE + "'"
    cSQLSeek += " AND B3X_STATUS IN('1','2','3','5')"
    cSQLSeek += " AND D_E_L_E_T_ = ' ' "

    If _cGetDb != "MSSQL" .OR. _cGetDb != "POSTGRES" .OR. _cGetDb != "ORACLE"
        cSQLSeek := changeQuery(cSQLSeek)
    EndIf
    If Select(self:cAliasB3X) > 0
        dbSelectArea(self:cAliasB3X)
        (self:cAliasB3X)->(DBCloseArea())
    EndIf
    DBUseArea(.T.,"TOPCONN",TCGenQry(,,cSQLSeek),self:cAliasB3X,.F.,.T.)
    (self:cAliasB3X)->(dbgotop())
    self:lRet := (self:cAliasB3X)->(!Eof())

Return self:lRet

Method SelecBenef() Class CenExpBen

    If Empty((self:cAliasB3X)->B3X_CODCCO) .OR. (self:cAliasB3X)->B3X_STATUS == "1"
        B3K->(dbSetOrder(10))     //Busca Pela Matricula
        self:lRet := B3K->(MsSeek(xFilial("B3K")+(self:cAliasB3X)->B3X_CODOPE+(self:cAliasB3X)->B3X_IDEORI)) //matricula
        If !self:lRet
            B3K->(dbSetOrder(9))     //Busca Pela Matricula Antiga
            self:lRet := B3K->(dbSeek(xFilial("B3K")+(self:cAliasB3X)->B3X_CODOPE+(self:cAliasB3X)->B3X_IDEORI))
            If !self:lRet .AND. !Empty((self:cAliasB3X)->B3X_DESORI)
                B3K->(dbSetOrder(6))     //Busca Pelo Nome
                self:lRet := B3K->(dbSeek(xFilial("B3K")+AllTrim((self:cAliasB3X)->B3X_DESORI)))
            EndIf
        Endif
    Else
        B3K->(dbSetOrder(2))     //Busca Pelo CCO
        self:lRet := B3K->(dbSeek(xFilial("BA1")+(self:cAliasB3X)->B3X_CODOPE+(self:cAliasB3X)->B3X_CODCCO))
    EndIf

Return self:lRet

Method execute() Class CenExpBen
    Local cJson     := ''
    local _cExtens  := "Diretório"//"Arquivo Texto ( *.TXT ) |*.TXT|"
    Local nBenef    := 1

    self:cFilename  := DToS(Date()) + "-BenefNaoEnviadosANS-" + AllTrim(B3D->B3D_CODOPE) + ".json"
    If !isBlind()
        self:cFolder    := cGetFile( _cExtens, "Selecione o Diretório",,, .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
    Else
        self:cFolder    := BARRA + "sib" + BARRA
    EndIF
    If self:seekB3X()
        ProcRegua((self:cAliasB3X)->(LastRec())/100)
        While !(self:cAliasB3X)->(Eof())
            If self:SelecBenef()
                If nBenef > 1
                    cJson += ','
                Else
                    cJson += "[ " + CRLF
                EndIf
                cJson += '{' + CRLF
                cJson += ' "TipoMovimento": '
                Do Case
                    Case AllTrim((self:cAliasB3X)->B3X_OPERA) == SIB_INCLUIR
                        cJson += '"Inclusao",'
                    Case AllTrim((self:cAliasB3X)->B3X_OPERA) == SIB_RETIFIC
                        cJson += '"Retificacao",'
                    Case AllTrim((self:cAliasB3X)->B3X_OPERA) == SIB_MUDCONT
                        cJson += '"Mudança Contratual",'
                    Case AllTrim((self:cAliasB3X)->B3X_OPERA) == SIB_CANCELA
                        cJson += '"Cancelamento",'
                    Case AllTrim((self:cAliasB3X)->B3X_OPERA) == SIB_REATIVA
                        cJson += '"Reativacao",'
                EndCase
                cJson += CRLF
                cJson += ' "DataMovimento": "'           + AllTrim((self:cAliasB3X)->B3X_DATA) +'",' + CRLF
                cJson += ' "CcoBeneficiario": "'         + AllTrim((self:cAliasB3X)->B3X_CODCCO) +'",' + CRLF
                cJson += ' "MatriculaBeneficiario": "'   + AllTrim((self:cAliasB3X)->B3X_IDEORI) +'",' + CRLF
                cJson += ' "MatriculaAntiga": "'         + AllTrim(B3K->B3K_MATANT) +'",' + CRLF
                cJson += ' "NomeBeneficiario": "'        + AllTrim(B3K->B3K_NOMBEN) +'",' + CRLF
                cJson += ' "CpfBeneficiario": "'         + AllTrim(B3K->B3K_CPF) +'",' + CRLF
                cJson += ' "DataNascimento": "'          + AllTrim(B3K->B3K_DATNAS) +'",' + CRLF
                cJson += ' "NomeDaMae": "'               + AllTrim(B3K->B3K_NOMMAE) +'",' + CRLF
                cJson += ' "CnpjContratante": "'         + AllTrim(B3K->B3K_CNPJCO) +'",' + CRLF
                cJson += ' "CeiContratante": "'          + AllTrim(B3K->B3K_CEICON) +'",' + CRLF
                cJson += ' "CaepfContratante": "'        + AllTrim(B3K->B3K_CAEPF) +'",' + CRLF
                cJson += ' "CodigoPlanoNaOperadora": "'  + AllTrim(B3K->B3K_SCPA) +'",' + CRLF
                cJson += ' "CodigoPlanoNaANS": "'        + AllTrim(B3K->B3K_SUSEP) +'"'

                If !Empty(AllTrim(B3K->B3K_CODTIT))
                    cJson += ',' + CRLF
                    cJson += ' "CpfTitular": "'          + Posicione('B3K',1,XFILIAL('B3K')+B3K->(B3K_CODOPE+B3K_CODTIT),'B3K_CPF') +'"'
                EndIf
                cJson += CRLF + '}' + CRLF

                self:saveFile(cJson)
                cJson := ''
            EndIf
            nBenef++
            If (nBenef % 100) == 0
                IncProc(cValToChar(nBenef) + " Beneficiarios Exportados...")
            EndIf
            (self:cAliasB3X)->(dbSkip())
        EndDo
        cJson := ']'
        self:saveFile(cJson)
        If self:closeFile()
            MsgInfo("Arquivo gerado com sucesso em " + self:cFolder,"Central de Obrigações")
            self:lRet := .T.
        EndIf
    Else
        MsgInfo("Não foram encontradas movimentações para exportação","Central de Obrigações")
        self:lRet := .F.
    EndIf
    (self:cAliasB3X)->(DBCloseArea())
Return self:lRet

Method saveFile(oResult) Class CenExpBen
    If File(self:cFolder + self:cFileName)
        FErase(self:cFolder + self:cFileName)
    EndIf
    If self:nHandle < 0
        self:nHandle := FCreate(self:cFolder + self:cFileName,NIL,NIL,.F.)
        FWrite(self:nHandle, oResult)
    Else
        FWrite(self:nHandle, oResult)
    EndIf
Return

Method closeFile() Class CenExpBen
    self:lRet := .T.

    If (!File(self:cFolder + self:cFileName))
        self:lRet := .F.
        Alert("Erro ao criar arquivo - FERROR " + str(FError(),4), "Central de Obrigações" )
    EndIf
    FClose(self:nHandle)
Return self:lRet