#include 'totvs.ch'
#include 'FWMVCDEF.CH'
#define ARQUIVO_LOG "cenjobsip.log"
//--------------------------------------------------------------------------------------------------
    /*/{Protheus.doc} CENJOBSIP()

    Job para disparar as cargas de dados do SIP

    @author timoteo.bega
    @since 08/01/2019
    /*/
//--------------------------------------------------------------------------------------------------
FUNCTION CENJOBSIP(cDataRef,cTipData,cRegANS,cTipProc,lGerRepas,cLocDigIgn,lAuto)
    Local cCodObri      := ""
    Local aCompro       := {}
    Local cCodComp      := ""
    Local cTipObr       := "1"//SIP
    Local nCompro       := 0
    Local nEsperando    := 0
    Local lContinua     := .F.
    Local cTriRec       := ""
	Local oObj          := FWSX1Util():New()
	Local aPergunte     :={}
	Local lPergNew      := .F.
    Default lGerRepas   := .F.
    Default lAuto       := .F.

	oObj:AddGroup("PLSCARDESN")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("PLSCARDESN")

	If len(apergunte) > 1
		lPergNew:=len(apergunte[2]) > 0
	endif

	If lPergNew .And. Valtype(mv_par01) == "D"
        lPergNew:=.F. //está usando o novo pergunte, mas não atualizou os JOBS no configurador.
	endif

	cDataRef	:= IIF (!lPergNew,DTOS(mv_par01),"")
	cTipData	:= iif (!lPergNew,AllTrim(Str(mv_par02)),AllTrim(Str(mv_par01)))
	cRegANS		:= iif (!lPergNew,mv_par03,mv_par02)
	cTipProc	:= iif (!lPergNew,AllTrim(mv_par04),AllTrim(mv_par03))
    lGerRepas	:= iif (!lPergNew,mv_par05 == 1,IIF(Valtype(mv_par04) == "N",mv_par04 == 1,.F.))
    
	cLocDigIgn	:= RetLocIgn()

    If Empty(cRegANS)
        If !lPergNew
            PlsLogFil(CENDTHRL("E") + " Nao foi possivel executar PLSJOBSIP - " + cDataRef + " - Informe o registro ANS da Operadora.",ARQUIVO_LOG)
        Else
            PlsLogFil(CENDTHRL("E") + " Nao foi possivel executar PLSJOBSIP.Informe o registro ANS da Operadora.",ARQUIVO_LOG)
        EndIf
        
    Else
        cCodObri := CENRETOBRI(cRegANS,cTipObr,"1"/*cAtivo*/)
        aCompro := CENRETCOMA(cRegAns,cCodObri,cTipObr,lAuto)//Retorna compromissos em aberto

        For nCompro := 1 TO Len(aCompro)

            cCodComp := aCompro[nCompro,1]
            cDataRef := aCompro[nCompro,2]
            cAnoComp := SubStr(cDataRef,1,4)
            cTriRec := AllTrim(cAnoComp) + SubStr(cCodComp,2,2)

            If "4" == cTipProc .Or. !B3VExiste(cRegANS,cCodObri,cAnoComp,cCodComp,cTipObr)//Posso executar o job de expostos em periodicidade/agendamento diferente

                PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Inicio PLSJOBSIP - " + cDataRef ,ARQUIVO_LOG)
                PLSJOBSIP(cDataRef,cTipData,cRegANS,cTipProc,lGerRepas,cLocDigIgn,nCompro==1,lAuto)
                iF !lAuto
                    Sleep(5000)
                EndIf
                 PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Termino PLSJOBSIP - " + cDataRef,ARQUIVO_LOG)

                If nCompro < Len(aCompro)
                    
                    While !lContinua

                        If B3VExiste(cRegANS,cCodObri,cAnoComp,cCodComp,cTipObr)

                            nEsperando += 300000//5 minutos
                            cTxt := "[" + cTrirec + "] Compromisso " + SubStr(aCompro[nCompro+1,2],1,4) + "-" + aCompro[nCompro+1,1] + " aguardando a " + AllTrim( Str( ( (nEsperando/1000) / 60) ) ) + " minutos "
                            PtInternal(1,cTxt)
                            PlsLogFil(cTxt,ARQUIVO_LOG)
                            iF !lAuto
                                Sleep(300000)
                            EndIf
                        Else
                            lContinua := .T.
                        EndIf

                    EndDo

                EndIf

            Else
                PlsLogFil("[" + cTrirec + "]" + CENDTHRL("W") + " Já existe um job em execução, nao foi possivel executar o PLSJOBSIP - " + cDataRef,ARQUIVO_LOG)
            EndIf

        Next nCompro
    EndIf
    FreeObj(oObj)
    oObj := Nil

Return

//--------------------------------------------------------------------------------------------------
    /*/{Protheus.doc} SchedDef

    Funcao criada para definir o pergunte do schedule

    @return aParam		Parametros para a pergunta do schedule

    @author TOTVS PLS Team
    @since 26/01/2016
    /*/
//--------------------------------------------------------------------------------------------------
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}
	Local oObj      := FWSX1Util():New()
	Local aPergunte :={}
	Local lPergNew     := .F.

	oObj:AddGroup("PLSCARDESN")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("PLSCARDESN")

	If len(apergunte) > 1
		lPergNew:=len(apergunte[2]) > 0
	endif

	IIF(!lPergNew,aParam := { "P","PLSCARDESP",,aOrdem,""},aParam := { "P","PLSCARDESN",,aOrdem,""})
    FreeObj(oObj)
    oObj := Nil

Return aParam

//--------------------------------------------------------------------------------------------------
    /*/{Protheus.doc} CENRETCOMA

    Retorna os compromissos em aberto

    @author timoteo.bega
    @since 19/12/2018
    /*/
//--------------------------------------------------------------------------------------------------
FUNCTION CENRETCOMA(cRegAns,cCodObri,cTipObr,lAuto)
    Local cCodComp  := ""
    Local cSql      := ""
    Local cVecto    := DTOS(dDatabase+120)
    Local aCompro   := {}
    Local cNomeArea := GetNextAlias()
    Default lAuto   := .F.

    If !Empty(cRegAns) .AND. !Empty(cCodObri) .AND. !Empty(cTipObr)
        cSql := " SELECT "
        cSql += " B3D_ANO, B3D_CODIGO "
        cSql += " FROM " + RetSqlName("B3D") + " "
        cSql += " WHERE "
        cSql += " B3D_FILIAL='" + xFilial("B3D") + "' "
        cSql += " AND B3D_CODOPE='" + cRegAns + "' "
        cSql += " AND B3D_CDOBRI='" + cCodObri +"' "
        cSql += " AND B3D_TIPOBR='" + cTipObr + "' "
        cSql += " AND B3D_STATUS <> '6' "
        IIF(!lAuto,cSql += " AND B3D_VCTO < '" + cVecto + "' ",cSql += " AND B3D_VCTO = '21310101' ")
        cSql += " AND D_E_L_E_T_=' ' "
        cSql += " ORDER BY B3D_ANO, B3D_CODIGO "

        If CENCRIAALI(cSql,cNomeArea)
            While !(cNomeArea)->(Eof())
                cTriRec := AllTrim((cNomeArea)->B3D_ANO) + SubStr((cNomeArea)->B3D_CODIGO,2,2)
                cCodComp := (cNomeArea)->B3D_CODIGO
                cDataRef := CENDATREF(cTriRec)
                aAdd(aCompro,{cCodComp,cDataRef})
                (cNomeArea)->(dbSkip())
            EndDo
        EndIf

        (cNomeArea)->(dbCloseArea())
    EndIf

Return aCompro

//--------------------------------------------------------------------------------------------------
    /*/{Protheus.doc} DataRef

    Funcao retorna a data de referencia do trimestre de acordo com o trimestre de reconhecimento passado

    @param cTriRec		Trimestre de reconhecimento yyyyaa

    @return cDataRef	Data de referencia no formado yyyymmaa

    @author timoteo.bega
    @since 23/10/2017
    /*/
//--------------------------------------------------------------------------------------------------
Function CENDATREF(cTriRec)
    Local cDataRef		:= ""
    Local cTrimestre	:= ""
    Local cAno			:= ""
    Local cUltMes		:= ""
    Default cTriRec     := ""

    If !Empty(cTriRec)

        cTrimestre := Right(cTriRec,2)
        cAno := Left(cTriRec,4)
        If cTrimestre == '01'
            cUltMes += '03' 
        ElseIf cTrimestre == '02'
            cUltMes += '06'
        ElseIf cTrimestre == '03'
            cUltMes += '09'
        ElseIf cTrimestre == '04'
            cUltMes += '12'
        Else
            cUltMes += '00'
        EndIf
	    cDataRef := DTOS(Lastday(cToD("01/" + cUltMes + "/"+ cAno), 0))

    EndIf

Return cDataRef

//--------------------------------------------------------------------------------------------------
    /*/{Protheus.doc} B3VExiste

    Verifica se ja existe algum job em execucao 

    @author timoteo.bega
    @since 08/01/2019
    /*/
//--------------------------------------------------------------------------------------------------
Static Function B3VExiste(cRegANS,cCodObri,cAnoComp,cCodComp,cTipo)
    Local lRetorno      := .F.
	Local cNomeArea     := GetNextAlias()
    Local cDatEve       := DTOS(DATE())
    Default cRegANS     := ""
    Default cCodObri    := ""
    Default cAnoComp    := ""
    Default cCodComp    := ""
    Default cTipo       := ""
    
    If PLSALIASEXI("B3V") .And. !Empty(RetSqlName("B3V"))
        StaticCall(CENMONJOB,expiraJobs)

        cSql := " SELECT R_E_C_N_O_ REC "
        cSql += " FROM " + RetSqlName("B3V") + " "
        cSql += " WHERE "
        cSql += " B3V_FILIAL='" + xFilial("B3V") + "' "
        cSql += " AND B3V_CODOPE='" + cRegANS + "' "
        cSql += " AND B3V_CODOBR='" + cCodObri + "' "
        cSql += " AND B3V_ANOCMP='" + cAnoComp + "' "
        cSql += " AND B3V_CDCOMP='" + cCodComp + "' "
        cSql += " AND B3V_TIPO='" + cTipo + "' "
        cSql += " AND B3V_DATEXE='" + cDatEve + "' "
        cSql += " AND B3V_STATUS<>'3' "
        cSql += " AND D_E_L_E_T_=' '"
        If CENCRIAALI(cSql,cNomeArea)
            lRetorno := .T.
        EndIf

        (cNomeArea)->(dbCloseArea())
    EndIf

Return lRetorno