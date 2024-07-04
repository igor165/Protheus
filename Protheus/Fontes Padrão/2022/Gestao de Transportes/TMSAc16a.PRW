#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAC15A.CH'

//--------------------------------------------------------
/*/{Protheus.doc} TMSAC16A
JOB - Conciliação financeira e geração do contrato de carreteiro
@type  Function
@author Caio Murakami
@version 12.1.31
@since 09/02/2021
@return aMovtos
/*/
//----------------------------------------------------------
Function TMSAC16A( cFilOri , cViagem )

Local lRestRepom    := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'
Local lGerCTC       := .F. 
Local lGeraFin      := .F. 

Default cFilOri     := ""
Default cViagem     := ""

If lRestRepom

    iF TmsChekSX1("TMSAC16A")
        If IsBlind()
            If mv_par01 == 1 
                lGerCTC     := .T. 
            EndIf 
            lGeraFin    := .T. 
        Else 

            If Pergunte("TMSAC16A",.T.)
                If mv_par01 == 1 
                    lGerCTC     := .T. 
                EndIf 
                lGeraFin    := .T. 
            EndIf 
        EndIf 
    Else 
        lGeraFin    := .T.  
    EndIf 

    If lGerCTC 
        GeraContrato( cFilOri , cViagem )
    EndIf 

    If lGeraFin
        BaixaFin( cFilOri , cViagem )
    EndIf 

EndIf 

Return

//--------------------------------------------------------
/*/{Protheus.doc} BaixaFin
JOB - Conciliação financeira e geração do contrato de carreteiro
@type  Function
@author Caio Murakami
@version 12.1.31
@since 09/02/2021
@return aMovtos
/*/
//----------------------------------------------------------
Static Function BaixaFin( cFilOri , cViagem  )
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()

Default cFilOri     := ""
Default cViagem     := ""

cQuery  := " SELECT DISTINCT DTY_FILORI, DTY_VIAGEM , DTY_NUMCTC "
cQuery  += " FROM  " + RetSQLName("DTY") + " DTY "
cQuery  += " WHERE DTY_STATUS   IN ('1','3','8') "
cQuery  += " AND DTY_CODOPE     = '01' " //-- Repom

If !Empty( cFilOri ) .And. !Empty( cViagem )
    cQuery  += " AND DTY_FILORI = '" + cFilOri + "' "
    cQuery  += " AND DTY_VIAGEM = '" + cViagem + "' "
EndIf 

cQuery  += " AND DTY.D_E_L_E_T_ = '' " 

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )


While (cAliasQry)->( !Eof() )

    If ValidaBaixa( (cAliasQry)->DTY_FILORI , (cAliasQry)->DTY_VIAGEM  )
        
        //-- Concilia financeiro
        ConciliaFin( (cAliasQry)->DTY_FILORI , (cAliasQry)->DTY_VIAGEM , (cAliasQry)->DTY_NUMCTC  )

        //-- Efetua baixa financeira
        BaixaCtc( (cAliasQry)->DTY_FILORI , (cAliasQry)->DTY_VIAGEM , (cAliasQry)->DTY_NUMCTC  )
    EndIF 

    (cAliasQry)->(dbSkip())
EndDo

Return 
//--------------------------------------------------------
/*/{Protheus.doc} ValidaBaixa
Valida baixas
@type  Function
@author Caio Murakami
@version 12.1.31
@since 09/02/2021
@return lRet
/*/
//----------------------------------------------------------
Static Function ValidaBaixa( cFilOri , cViagem )
Local lRet      := .F. 
Local aStatus   := {} 
Local nPos      := 0 
Local cStatus   := ""

aStatus := TM15StaPrc(cFilOri,cViagem) 

nPos    := aScan(aStatus,{|x| x[1] == "STATUS" }) 

If nPos > 0 
    cStatus := Upper(AllTrim(aStatus[nPos,2]))
    If cStatus  == "CLEARED" .Or. cStatus == "PAID"
        lRet    := .T. 
    EndIf 
EndIf 

Return lRet 

//--------------------------------------------------------
/*/{Protheus.doc} BaixaCtc
Efetua baixa financeiras
@type  Function
@author Caio Murakami
@version 12.1.31
@since 09/02/2021
@return lRet
/*/
//----------------------------------------------------------
Static Function BaixaCtc( cFilOri , cViagem , cNumCtc )
Local aArea         := GetArea()
Local aAreaDTY      := DTY->(GetArea())

//--- variavel para o TMSA250
Private aRotina := {	{ "", "", 0, 1 },;
	                	{ "", "", 0, 2 },;
		                { "", "", 0, 3 },;
		                { "", "", 0, 4 },;
		                { "", "", 0, 5 } }

Default cFilOri     := ""
Default cViagem     := ""
Default cNumCTC     := ""

DTY->(dbSetOrder(2))
If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem + cNumCTC ))
    TMSA250SLD("DTY", DTY->(Recno()), 4)
EndIf 

RestArea(aAreaDTY)
RestArea(aArea)

Return 

//--------------------------------------------------------
/*/{Protheus.doc} ConciliaFin
Efetua conciliação financeiras
@type  Function
@author Caio Murakami
@version 12.1.31
@since 09/02/2021
@return lRet
/*/
//----------------------------------------------------------
Static Function ConciliaFin(cFilOri , cViagem , cNumCtc )
Local cImpCTC       := SuperGetMv("MV_IMPCTC",,"0")
Local aMovRep       := {}

Default cFilOri     := ""
Default cViagem     := ""
Default cNumCTC     := ""

If cImpCTC == "1" 
    aMovRep:= TmsIncImp(cFilOri,cViagem) 
    If Len(aMovRep) > 0
		TmsImpRep(cFilOri,cViagem,aMovRep)
	EndIf
    AlteraTit( cFilOri , cViagem , cNumCTC )  
EndIf 

FwFreeArray(aMovRep)
Return 

//--------------------------------------------------------
/*/{Protheus.doc} GeraContrato
Gera Contrato de Carreteiro
@type  Function
@author Caio Murakami
@version 12.1.31
@since 09/02/2021
@return lRet
/*/
//----------------------------------------------------------
Static Function GeraContrato( cFilOri , cViagem  )
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local cImpCTC       := SuperGetMv("MV_IMPCTC",,"0")

Default cFilOri     := ""
Default cViagem     := ""

cQuery  := " SELECT DTR_FILORI, DTR_VIAGEM "
cQuery  += " FROM " + RetSQLName("DTR") + " DTR "

If cImpCTC == "1"
    DEG->(dbSetOrder(1))
    If DEG->( MsSeek (xFilial("DEG") + "01"))
        If DEG->DEG_REPQUIT == "1" //-- 0=Não Utiliza;1=Contrato de Carreteiro;2=Encerramento de Viagem
            cQuery  += " INNER JOIN " + RetSQLName("DTQ") + " DTQ "
            cQuery  += "    ON DTQ_FILIAL  = '" + xFilial("DTQ") + "' "
            cQuery  += "    AND DTQ_FILORI = DTR_FILORI "
            cQuery  += "    AND DTQ_VIAGEM = DTR_VIAGEM "
            cQuery  += "    AND DTQ_STATUS = '3' " //-- 3=Encerrado
            cQuery  += "    AND DTQ.D_E_L_E_T_  = '' "
        EndIf 
    EndIf 
EndIf

cQuery  += " WHERE  DTR_FILIAL  = '" + xFilial("DTR") + "' "
cQuery  += " AND DTR_CODOPE     = '01' " //-- Repom

If cImpCTC == "0"
    cQuery  += " AND DTR_PRCTRA = '' "
ElseIf cImpCTC == "1"
    cQuery  += " AND DTR_PRCTRA <> '' " 
    cQuery  += " AND DTR_CIOT   <> '' "
EndIF 

cQuery  += " AND NOT EXISTS ( "
cQuery  += "                SELECT * FROM " + RetSQLName("DTY") + " DTY "
cQuery  += "                WHERE DTY_FILIAL    = '" + xFilial("DTY") + "' "
cQuery  += "                AND DTY_FILORI      = DTR.DTR_FILORI "
cQuery  += "                AND DTY_VIAGEM      = DTR.DTR_VIAGEM "
cQuery  += "                AND DTY.D_E_L_E_T_  = '' "
cQuery  += " ) "
cQuery  += " AND NOT EXISTS ( "
cQuery  += "                SELECT * FROM " + RetSQLName("DUD") + " DUD "
cQuery  += "                WHERE DUD_FILIAL    = '" + xFilial("DUD") + "' "
cQuery  += "                AND DUD_FILORI      = DTR.DTR_FILORI "
cQuery  += "                AND DUD_VIAGEM      = DTR.DTR_VIAGEM "
cQuery  += "                AND DUD_STATUS      IN ('1', '9' ) " //1-Aberto 2-Transito 3-Carregado 4-Encerrado 9-Cancelado
cQuery  += "                AND DUD.D_E_L_E_T_  = '' "
cQuery  += " ) "

If !Empty( cFilOri ) .And. !Empty( cViagem )
    cQuery  += " AND DTR_FILORI     = '" + cFilOri + "' " 
    cQuery  += " AND DTR_VIAGEM     = '" + cViagem + "' "
EndIf 

cQuery  += " AND DTR.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )


While (cAliasQry)->( !Eof() )    
    TMSA16Prc( (cAliasQry)->DTR_FILORI, (cAliasQry)->DTR_VIAGEM )
    (cAliasQry)->(dbSkip())
EndDo

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSA16Prc()
Realiza o Processamento da Geração do Contrato de Carreteiro a Partir
da Quitação do Contrato no Posto

@author     Katia
@since      01/02/2021
@version    1.0
@param      cFilOri, cViagem
@type       function
@Return     lRet
/*/
//--------------------------------------------------------------------
Function TMSA16Prc( cFilOri, cViagem, lTela )
Local lRet       := .T.
Local aArea      := GetArea()
Local lQuitPost  := .F.
Local aMsgErr    := {}
Local cImpCTC 	 := SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
Local lGera      := .F. 
Local lRestRepom    := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'

Private cCadastro:= "Contrato de Carreteiro"

Default cFilOri:= ""
Default cViagem:= ""
Default lTela  := !IsBlind()

If lRestRepom
    DTQ->( dbSetOrder( 2 ) )
    If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ) )
        If cImpCTC == "1" 
            //--- Valida se o contrato ja foi quitado no Posto. 
            //--- Se quitado, gera o Contrato de Carreteiro
            lQuitPost:= TMSC15ARep( 10 , cFilOri , cViagem, .F.  )  
            If lQuitPost
                lGera:= .T.
            Else
                AAdd( aMsgErr, { "Contrato não está Quitado na REPOM." } ) 
            EndIf
        Else
            //Chamada pelo Fechamento da Viagem para calcular os impostos antes do envio do Contrato
            lGera:= .T.   
        EndIf

        If lGera 
			If ExistFunc("TMSA250Ger")
                lRet    := TMSA250Ger( cFilOri, cViagem )
            Else 
                lRet := TMSA16GCtc( cViagem , cFilOri )
            EndIf 
        Else    
            lRet:= .F.
        EndIf

        If !lRet
            Aadd(aMsgErr,{"Não foi possível gerar o Contrato para a Viagem: " + cFilOri + " - " + cViagem  } )
        EndIf
            
    EndIf    
Else
    AAdd( aMsgErr, { "Viagem não Integrada com a Operadora de Frotas." } ) 
EndIf

If !Empty( aMsgErr ) .And. lTela
    TmsMsgErr( aMsgErr )
    lRet:= .F.
EndIf

RestArea(aArea)    
FwFreeArray(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AlteraTit()
Altera títulos

@author     Caio
@type       function
@since      09/02/2021
@version    1.0
@param      cFilOri, cViagem
@Return     lRet
/*/
//--------------------------------------------------------------------
Static Function AlteraTit( cFilOri , cViagem , cNumCTC )
Local aArea         := GetArea()
Local aAreaSE2      := SE2->(GetArea())
Local aAreaDTY      := DTY->(GetArea())
Local aGrvSe2       := {} 
Local cPrefixo      := TMA250GerPrf(cFilAnt)
Local nValIRRF      := 0 
Local nValINSS      := 0 
Local nValSEST      := 0 

Default cFilOri     := ""
Default cViagem     := ""
Default cNumCTC     := ""

Private lMsErroAuto := .F. 

DTY->(dbSetOrder(2))
SE2->( dbSetOrder(6) )
If DTY->(MsSeek(xFilial("DTY") + cFilOri + cViagem + cNumCTC))
    If SE2->( MsSeek( xFilial("SE2") + DTY->(DTY_CODFOR + DTY_LOJFOR) + cPrefixo + cNumCTC ))
    
        nValIRRF    := DTY->DTY_IRRF
        nValINSS    := DTY->DTY_INSS
        nValSEST    := Iif( DTY->DTY_VLSENA > 0 , DTY->DTY_VLSENA + DTY->DTY_VLSEST, DTY->DTY_SEST )
        
        Aadd(aGrvSe2,   { "E2_PREFIXO"      , SE2->E2_PREFIXO            , Nil })
        Aadd(aGrvSe2,   { "E2_NUM"          , SE2->E2_NUM            , Nil })
        Aadd(aGrvSe2,   { "E2_TIPO"         , SE2->E2_TIPO            , Nil })
        Aadd(aGrvSe2,   { "E2_NATUREZ"      , SE2->E2_NATUREZ         , Nil })
        Aadd(aGrvSe2,   { "E2_PORTADO"      , SE2->E2_PORTADO           , Nil })
        Aadd(aGrvSe2,   { "E2_FORNECE"      , SE2->E2_FORNECE             , Nil })
        Aadd(aGrvSe2,   { "E2_LOJA"         , SE2->E2_LOJA            , Nil })
        Aadd(aGrvSe2,   { "E2_VALOR"        , SE2->E2_VALOR        , Nil })
        Aadd(aGrvSe2,   { "E2_SALDO"        , SE2->E2_SALDO        , Nil })
        Aadd(aGrvSe2,   { "E2_IRRF"         , nValIRRF    , Nil })   
        Aadd(aGrvSe2,   { "E2_INSS"         , nValINSS    , Nil })  
        Aadd(aGrvSe2,   { "E2_SEST"         , nValSEST    , Nil })    
        Aadd(aGrvSe2,   { "E2_FILIAL"       , SE2->E2_FILIAL, Nil }) 
       
        MsExecAuto({ | a,b,c,d,e,f,g,h,i,j,k | Fina050(a,b,c,d,e,f,g,h,i,j,k) }, aGrvSe2,, 4,,, .f., .f., , , , .F. )
        
        If lMsErroAuto
            Help(" ", 1, "ERROGERACP")
        Endif
        
    EndIf 
EndIf 

RestArea(aAreaSE2)
RestArea(aAreaDTY)
RestArea(aArea)

Return 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
Permite a execucao da rotina via Scheddef.
@type function
@author Caio Murakami
@version 12.1.31
@since 10/02/2021
/*/
//-------------------------------------------------------------------------------------------------
Static Function Scheddef()
Local aParam

aParam := {"P",;  	//Tipo R para relatorio P para processo   
		   "TMSAC16A",;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DTY",;  // Alias            
		   ,;   	//Array de ordens   
		   'Schedule - Repom'} //--> Schedule - Repom   

Return aParam

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSA16GCtc()
Chama geração do contrato carreteiro
@author     Valdemar Roberto Mognon
@since      23/02/2021
@version    1.0
@param      cViagem
@type       function
@Return     lRet
/*/
//--------------------------------------------------------------------
Function TMSA16GCtc( cViagem , cFilOri )
Local lRet := .T.

Default cViagem     := "" 
Default cFilOri     := ""

If lRet
    lRet    := TMSA250Mnt("DTY", 0 , 3 , ,.F.,.F.,,"1", cFilOri , cViagem )
EndIf

Return lRet
