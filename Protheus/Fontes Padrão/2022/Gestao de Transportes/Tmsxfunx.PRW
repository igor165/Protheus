#INCLUDE 'PROTHEUS.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCADadosTMS
Classe que retorna dados necessários por diversas rotinas no SIGATMS

Criação de nomes: http://tdn.totvs.com/pages/viewpage.action?pageId=22480532

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCADadosTMS
	DATA cFilOri		As Character
	DATA cViagem		As Character
    DATA cTipoXML       As Character
    DATA lError		    As Logical
    DATA lConectado     As Logical
    DATA nOperation     As Numeric
    DATA aDocs          As Array
    DATA aCustomers     As Array
    DATA aNF            As Array
    DATA aVehicles      As Array
    DATA aTracker       As Array
    DATA aDriver        As Array
    DATA aOperation     As Array
    DATA aColetas       As Array
    DATA aPointOper     As Array
    DATA aPointOcor     As Array
    DATA aError         As Array   
    DATA oXMLVge        As Objetc
    	
	METHOD New() Constructor

	//-- Método para adicionar documentos na viagem
    METHOD AddDocs()	
    METHOD AddNF()
    METHOD AddVehicles()
    METHOD AddDriver()
    METHOD AddOperation()
    METHOD AddCol()
    METHOD PointOcor()
    METHOD PointOperation()
    METHOD AddCustomerTrip()

    //-- Métodos diversos
  	METHOD SendXML()	
    METHOD Connect()
    METHOD Activate()
    METHOD CleanDate()
    
     //-- Gets
    METHOD GetDocs()
    METHOD GetNF()
    METHOD GetXML()
    METHOD GetVehicles()
    METHOD GetOperation()
    METHOD GetCustomers()
    METHOD GetDriver()
    METHOD GetTracker()
    METHOD GetColetas()
    METHOD GetPointOper()
    METHOD GetErrorXML()
    METHOD GetPointOcor()
    
    //-- Método para exibição das mensagens de erro do objeto
	METHOD AddError()
    METHOD GetError()
    METHOD ShowError()
    METHOD CleanError()

    //-- Métodos have
    METHOD HasError()

    //-- Destrói classe e objetos
    METHOD Destroy()
    
ENDCLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New( cFilOri, cViagem , nOper , lInitAuto, cTipoXML ) CLASS TMSBCADadosTMS

Default cFilOri     := ""
Default cViagem     := ""
Default nOper       := 3
Default lInitAuto   := .T. 
Default cTipoXML    := "1" //-- Define o tipo de XML (1=Monitorable,2=Upd Transitions, 3=Trip Action) 

::cFilOri	    := cFilOri
::cViagem	    := cViagem
::lError        := .F. 
::lConectado    := .F.
::nOperation    := nOper
::aDocs         := {}
::aNF           := {}
::aVehicles     := {}
::aTracker      := {}
::aDriver       := {} 
::aCustomers     := {}
::aOperation    := {}
::aColetas      := {}
::aPointOper    := {}
::aPointOcor    := {}
::aError        := {}
::oXMLVge       := TXmlManager():New()
::cTipoXML      := cTipoXML

If lInitAuto .And. !Empty(cFilOri) .And. !Empty(cViagem)
    ::Activate()
EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} Activate()
Ativa e carrega classe

@author Caio Murakami
@since 26/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Activate() CLASS TMSBCADadosTMS
Local cFilOri   := ""
Local cViagem   := ""
Local lRet      := .F. 

cFilOri     := ::cFilOri
cViagem     := ::cViagem

If !Empty(cFilOri) .And. !Empty(cViagem)
    ::AddDocs(cFilOri,cViagem)
    ::AddVehicles(cFilOri,cViagem)
    ::AddOperation(cFilOri,cViagem)
    ::AddDriver(cFIlOri, cViagem)
    lRet    := .T. 
EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} SendXML()
Envia Viagem

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SendXML() CLASS TMSBCADadosTMS
Local oWsCpl    := Nil
Local lRet      := .F. 
Local aArea     := GetArea()
Local oRetorno  := Nil
Local oXmlAux   := Nil
Local nAux      := 1
Local aError    := {}

If ::lConectado
    oWsCpl  := ::oXMLVge

    FwMsgRun( , {| | lRet := oWsCpl:TmsEnvia() } , "Processando" , "Realizando envio de informações para NeoLog" )

    If !lRet
        ::AddError("NEOLOG X SIGATMS" )
        ::AddError(cValToChar(GetWSCError() ) )
        ::AddError(cValToChar(GetWSCError(2) ) )
        ::AddError(cValToChar(GetWSCError(3) ) )
    Else
        oRetorno    := oWsCpl:oRetorno

        //-- Verifica nós do XML
        If XmlChildEx(oRetorno, '_NS2_RESPONSE' ) <> Nil 
            oXmlAux     := oRetorno:_NS2_RESPONSE
            If  XmlChildEx(oXmlAux, '_NS2_MESSAGES' ) <> Nil 
                oXmlAux     := oXmlAux:_NS2_MESSAGES

                If XmlChildEx(oXmlAux, '_NS2_RESPONSEMESSAGE' ) <> Nil 
                    oXmlAux     := oXmlAux:_NS2_RESPONSEMESSAGE
                    
                    If XmlChildEx(oXmlAux, '_NS2_RESULT' ) <> Nil 
                        
                        If Upper(oXmlAux:_NS2_RESULT:Text) == "TRUE"
                            lRet    := .T. 
                        ElseIf  Upper(oXmlAux:_NS2_RESULT:Text) == "FALSE"
                            lRet    := .F.                         
                            aError  := aClone(::GetErrorXML(oRetorno))

                            For nAux := 1 To Len(aError)
                                ::AddError(aError[nAux])
                            Next nAux

                        EndIf

                    EndIf
                EndIf
            EndIf
        EndIf

    EndIf

Else
    ::AddError("NEOLOG X SIGATMS" )
    ::AddError("Web-Service fora do ar!")
EndIf

//FwFreeObj(aConfig)
FwFreeObj(oWsCpl)

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AddError()
Adiciona Erro

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddError(cError) CLASS TMSBCADadosTMS

::lError    := .T. 

If !Empty(cError)
    Aadd(::aError,{cError})
EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetError()
Retorna Erro

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetError() CLASS TMSBCADadosTMS
Local aError    := {} 

aError  := ::aError

Return aError

//-----------------------------------------------------------------
/*/{Protheus.doc} HasError()
Retorna Erro

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD HasError() CLASS TMSBCADadosTMS

Return ::lError

//-----------------------------------------------------------------
/*/{Protheus.doc} ShowError()
Exibe erros

@author Caio Murakami
@since 04/07/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ShowError(lLimpaErr) CLASS TMSBCADadosTMS
Local aError    := {}
Local nCount    := 1
Local cMsgErr   := ""

Default lLimpaErr   := .T. 

If ::HasError()
    aError  := ::GetError()

    For nCount := 1 To Len(aError)						
        cMsgErr	+= AllTrim( SubStr(aError[nCount][1],1,750) ) + chr(13) + chr(10)					
    Next nCount
    
    Help('',1,'NEOLOG',,cMsgErr,1,0)

    If lLimpaErr
        ::CleanError()
    EndIf

EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} CleanError()
Limpa erros

@author Caio Murakami
@since 04/07/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD CleanError() CLASS TMSBCADadosTMS
FwFreeObj(::aError  ) 
::aError    := {} 
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AddDocs()
Adiciona Documentos na viagem

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddDocs( cFilOri, cViagem , cFilDoc , cDoc , cSerie , cOperation ) CLASS TMSBCADadosTMS
Local cQuery    := ""
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local lDT6SqeDes:= DT6->(ColumnPos("DT6_SQEDES")) > 0

Default cFilOri     := ""
Default cViagem     := ""
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""
Default cOperation  := "ADD"

cQuery  := " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_CHVCTE, DT6_CLIREM ,  DT6_LOJREM , DT6_SQEDES ,DT6_CLIDES , DT6_LOJDES , DT6_CLICAL, DT6_LOJCAL, DT6_QTDVOL , DT6_PESO , "
cQuery  += " DT6_METRO3 , DT6_PESOM3 , DT6_VALTOT , DT6_SERTMS , DT6_DOCTMS ,  DT6_CDRDES , DT6_CDRORI ,DT6_CDRCAL,  DT6_STATUS, DT6_CLIEXP, DT6_LOJEXP " 

//-- Remetente
cQuery  += " , SA1REM.A1_NREDUZ REMNREDUZ , SA1REM.A1_NOME REMNOME , SA1REM.A1_END  REMEND , SA1REM.A1_COMPLEM REMCOMPLEM , SA1REM.A1_BAIRRO REMBAIRRO , SA1REM.A1_MUN  REMMUN , "
cQuery  += " SA1REM.A1_EST REMEST , SA1REM.A1_CEP  REMCEP , SYAREM.YA_DESCR REMPAISDES "

//-- Destinatário
cQuery  += " , SA1DES.A1_NREDUZ DESNREDUZ , SA1DES.A1_NOME DESNOME , SA1DES.A1_END  DESEND , SA1DES.A1_COMPLEM DESCOMPLEM , SA1DES.A1_BAIRRO DESBAIRRO , SA1DES.A1_MUN  DESMUN , "
cQuery  += " SA1DES.A1_EST DESEST , SA1DES.A1_CEP  DESCEP , SYADES.YA_DESCR DESPAISDES  "

//-- Redespachante
If lDT6SqeDes
    cQuery  += " , DULSQE.DUL_CODRED  SQECODRED , DULSQE.DUL_LOJRED SQELOJRED ,  SA1SQE.A1_NREDUZ SQENREDUZ , SA1SQE.A1_NOME SQENOME , SA1SQE.A1_END  SQEEND , SA1SQE.A1_COMPLEM SQECOMPLEM , SA1SQE.A1_BAIRRO SQEBAIRRO , SA1SQE.A1_MUN  SQEMUN , "
    cQuery  += " SA1SQE.A1_EST SQEEST , SA1SQE.A1_CEP  SQECEP , SYASQE.YA_DESCR SQEPAISDES  "
EndIf

//-- Sol.Coleta
cQuery  += " , DT5_SEQEND , DUE_CODCLI , DUE_LOJCLI , SA1COL.A1_NREDUZ COLNREDUZ , SA1COL.A1_NOME COLNOME , SA1COL.A1_END  COLEND , SA1COL.A1_COMPLEM COLCOMPLEM , SA1COL.A1_BAIRRO COLBAIRRO , SA1COL.A1_MUN  COLMUN , "
cQuery  += " SA1COL.A1_EST COLEST , SA1COL.A1_CEP  COLCEP , SYACOL.YA_DESCR COLPAISDES  "

cQuery  += " FROM " + RetSQLName("DUD") + " DUD "
cQuery  += " INNER JOIN " + RetSQLName("DT6") + " DT6 "
cQuery  += "    ON DT6_FILIAL   = '" + xFilial("DT6") + "' "
cQuery  += "    AND DT6_FILDOC  = DUD_FILDOC "
cQuery  += "    AND DT6_DOC     = DUD_DOC "
cQuery  += "    AND DT6_SERIE   = DUD_SERIE "
cQuery  += "    AND DT6.D_E_L_E_T_ = ' ' "
cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1REM "
cQuery  += "    ON SA1REM.A1_FILIAL     = '" + xFilial("SA1") + "' "
cQuery  += "    AND SA1REM.A1_COD       = DT6_CLIREM "
cQuery  += "    AND SA1REM.A1_LOJA      = DT6_LOJREM "
cQuery  += "    AND SA1REM.D_E_L_E_T_   = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("SYA") + " SYAREM "
cQuery  += "        ON  SYAREM.YA_FILIAL    = '" + xFilial("SYA") + "' "
cQuery  += "        AND SYAREM.YA_CODGI     = SA1REM.A1_PAIS "
cQuery  += "        AND SYAREM.D_E_L_E_T_   = ' ' "
cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1DES "
cQuery  += "    ON SA1DES.A1_FILIAL     = '" + xFilial("SA1") + "' "
cQuery  += "    AND SA1DES.A1_COD       = DT6_CLIDES "
cQuery  += "    AND SA1DES.A1_LOJA      = DT6_LOJDES "
cQuery  += "    AND SA1DES.D_E_L_E_T_   = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("SYA") + " SYADES "
cQuery  += "        ON  SYADES.YA_FILIAL    = '" + xFilial("SYA") + "' "
cQuery  += "        AND SYADES.YA_CODGI     = SA1DES.A1_PAIS "
cQuery  += "        AND SYADES.D_E_L_E_T_   = ' ' "

//-- Tratamento DUL
If lDT6SqeDes
    cQuery  += " LEFT JOIN " + RetSQLName("DUL") + " DULSQE "
    cQuery  += "    ON DULSQE.DUL_FILIAL = '" + xFilial("DUL") + "' "
    cQuery  += "    AND DULSQE.DUL_CODCLI = DT6_CLIDES "
    cQuery  += "    AND DULSQE.DUL_LOJCLI = DT6_LOJDES "
    cQuery  += "    AND DULSQE.DUL_SEQEND = DT6_SQEDES "
    cQuery  += "    AND DULSQE.D_E_L_E_T_ = '' "
    cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1SQE "
    cQuery  += "    ON SA1SQE.A1_FILIAL     = '" + xFilial("SA1") + "'  "
    cQuery  += "    AND SA1SQE.A1_COD       = DULSQE.DUL_CODRED               "
    cQuery  += "    AND SA1SQE.A1_LOJA      = DULSQE.DUL_LOJRED               "
    cQuery  += "    AND SA1SQE.D_E_L_E_T_   = ' ' 
    cQuery  += "    LEFT JOIN " + RetSQLName("SYA") + " SYASQE "
    cQuery  += "        ON  SYASQE.YA_FILIAL    = '" + xFilial("SYA") + "' "
    cQuery  += "        AND SYASQE.YA_CODGI     = SA1SQE.A1_PAIS "
    cQuery  += "        AND SYASQE.D_E_L_E_T_   = ' ' "
EndIf

//-- Tratamento Sol. Coleta
cQuery  += " LEFT JOIN " + RetSQLName("DT5") + " DT5 "
cQuery  += "    ON DT5.DT5_FILIAL   = '" + xFilial("DT5") + "' "
cQuery  += "    AND DT5_NUMSOL      =  DT6_DOC "
cQuery  += "    AND DT5_FILDOC      = DT6_FILDOC "
cQuery  += "    AND DT5_DOC         = DT6_DOC "
cQuery  += "    AND DT5_SERIE       = DT6_SERIE "
cQuery  += "    AND DT5.D_E_L_E_T_  = '' "
cQuery  += "    LEFT JOIN " + RetSQLName("DUE") + " DUE "
cQuery  += "        ON DUE.DUE_FILIAL   = '" + xFilial("DUE") + "' "
cQuery  += "        AND DUE_CODSOL      = DT5_CODSOL "
cQuery  += "        AND DUE.D_E_L_E_T_  = '' "
cQuery  += "    LEFT JOIN " + RetSQLName("SA1") + " SA1COL "
cQuery  += "        ON SA1COL.A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery  += "        AND SA1COL.A1_COD   = DUE_CODCLI "
cQuery  += "        AND SA1COL.A1_LOJA  = DUE_LOJCLI "
cQuery  += "        AND SA1COL.D_E_L_E_T_ = '' "
cQuery  += "    LEFT JOIN " + RetSQLName("SYA") + " SYACOL "
cQuery  += "        ON  SYACOL.YA_FILIAL    = '" + xFilial("SYA") + "' "
cQuery  += "        AND SYACOL.YA_CODGI     = SA1COL.A1_PAIS "
cQuery  += "        AND SYACOL.D_E_L_E_T_   = ' ' "

cQuery  += " WHERE DUD_FILIAL   = '" + xFilial("DUD") + "'  "
cQuery  += "    AND DUD_FILORI  = '" + cFilOri + "' "
cQuery  += "    AND DUD_VIAGEM  = '" + cViagem + "' "

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
    cQuery  += "    AND DUD_FILDOC  = '" + cFilDoc + "' "
    cQuery  += "    AND DUD_DOC     = '" + cDoc + "' "
    cQuery  += "    AND DUD_SERIE   = '" + cSerie + "' "
EndIf

cQuery  += "    AND DUD.D_E_L_E_T_ = ' ' "
cQuery  += " ORDER BY SA1DES.A1_COD "

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
    cFilDoc     := (cAliasQry)->DT6_FILDOC
    cDoc        := (cAliasQry)->DT6_DOC
    cSerie      := (cAliasQry)->DT6_SERIE

    Aadd( Self:aDocs , {} ) 
    Aadd( Self:aDocs[Len(::aDocs)] , { "DUD_FILORI" , cFilOri                   , "FILORI"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DUD_VIAGEM" , cViagem                   , "VIAGEM"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_FILDOC" , cFilDoc                   , "FILDOC"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_DOC"    , cDoc                      , "DOC"     } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_SERIE"  , cSerie                    , "SERIE"   } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_DOCTMS"  , (cAliasQry)->DT6_DOCTMS  , "DOCTMS"  } )
        
    //-- Remetente
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_CLIREM" , (cAliasQry)->DT6_CLIREM   , "CLIREM"      } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_LOJREM" , (cAliasQry)->DT6_LOJREM   , "LOJREM"      } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMNREDUZ"  , (cAliasQry)->REMNREDUZ    , "REMNREDUZ"   } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMNOME"    , (cAliasQry)->REMNOME      , "REMNOME"     } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMEND"     , (cAliasQry)->REMEND       , "REMEND"      } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMCOMPLEM" , (cAliasQry)->REMCOMPLEM   , "REMCOMPLEM"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMBAIRRO"  , (cAliasQry)->REMBAIRRO    , "REMBAIRRO"   } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMMUN"     , (cAliasQry)->REMMUN       , "REMMUN"      } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMEST"     , (cAliasQry)->REMEST       , "REMEST"      } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMCEP"     , (cAliasQry)->REMCEP       , "REMCEP"      } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "REMPAISDES" , (cAliasQry)->REMPAISDES   , "REMPAISDES"  } )
   
    //-- Destinatário
    If Upper( AllTrim( cSerie ) ) <> "COL"
        If lDT6SqeDes .And. !Empty( (cAliasQry)->SQECODRED ) .And. !Empty( (cAliasQry)->SQELOJRED )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_SQEDES" , ""   , "SQEDES"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQECODRED"  , (cAliasQry)->SQECODRED    , "CLIDES"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQELOJRED"  , (cAliasQry)->SQELOJRED    , "LOJDES"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQENREDUZ"  , (cAliasQry)->DESNREDUZ    , "DESNREDUZ"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQENOME"    , (cAliasQry)->DESNOME      , "DESNOME"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQEEND"     , (cAliasQry)->DESEND       , "DESEND"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQECOMPLEM" , (cAliasQry)->DESCOMPLEM   , "DESCOMPLEM"  } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQEBAIRRO"  , (cAliasQry)->DESBAIRRO    , "DESBAIRRO"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQEMUN"     , (cAliasQry)->DESMUN       , "DESMUN"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQEEST"     , (cAliasQry)->DESEST       , "DESEST"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQECEP"     , (cAliasQry)->DESCEP       , "DESCEP"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "SQEPAISDES" , (cAliasQry)->DESPAISDES   , "DESPAISDES"  } )
        Else
            Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_SQEDES" , ""   , "SQEDES"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_CLIDES" , (cAliasQry)->DT6_CLIDES   , "CLIDES"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_LOJDES" , (cAliasQry)->DT6_LOJDES   , "LOJDES"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESNREDUZ"  , (cAliasQry)->DESNREDUZ    , "DESNREDUZ"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESNOME"    , (cAliasQry)->DESNOME      , "DESNOME"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESEND"     , (cAliasQry)->DESEND       , "DESEND"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESCOMPLEM" , (cAliasQry)->DESCOMPLEM   , "DESCOMPLEM"  } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESBAIRRO"  , (cAliasQry)->DESBAIRRO    , "DESBAIRRO"   } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESMUN"     , (cAliasQry)->DESMUN       , "DESMUN"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESEST"     , (cAliasQry)->DESEST       , "DESEST"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESCEP"     , (cAliasQry)->DESCEP       , "DESCEP"      } )
            Aadd( Self:aDocs[Len(::aDocs)] , { "DESPAISDES" , (cAliasQry)->DESPAISDES   , "DESPAISDES"  } )
        EndIf

    Else
        Aadd( Self:aDocs[Len(::aDocs)] , { "DT5_SEQEND" , (cAliasQry)->DT5_SEQEND   , "SQEDES"   } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "DUE_CODCLI" , (cAliasQry)->DUE_CODCLI   , "CLIDES"   } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "DUE_LOJCLI" , (cAliasQry)->DUE_LOJCLI   , "LOJDES"   } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLNREDUZ"  , (cAliasQry)->COLNREDUZ    , "DESNREDUZ"   } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLNOME"    , (cAliasQry)->COLNOME      , "DESNOME"   } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLEND"     , (cAliasQry)->COLEND       , "DESEND"      } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLCOMPLEM" , (cAliasQry)->COLCOMPLEM   , "DESCOMPLEM"  } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLBAIRRO"  , (cAliasQry)->COLBAIRRO    , "DESBAIRRO"   } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLMUN"     , (cAliasQry)->COLMUN       , "DESMUN"      } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLEST"     , (cAliasQry)->COLEST       , "DESEST"      } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLCEP"     , (cAliasQry)->COLCEP       , "DESCEP"      } )
        Aadd( Self:aDocs[Len(::aDocs)] , { "COLPAISDES" , (cAliasQry)->COLPAISDES   , "DESPAISDES"  } )
    EndIf

    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_QTDVOL" , (cAliasQry)->DT6_QTDVOL   , "QTDVOL"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_PESO"   , (cAliasQry)->DT6_PESO     , "PESO"    } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_PESOM3" , (cAliasQry)->DT6_PESOM3   , "PESOM3"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_VALTOT" , (cAliasQry)->DT6_VALTOT   , "VALTOT"  } )    
    Aadd( Self:aDocs[Len(::aDocs)] , { "OPERATION"  , cOperation                , "OPERATION" } ) 
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_CDRCAL" , (cAliasQry)->DT6_CDRCAL   , "REGCALC" } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_STATUS" , (cAliasQry)->DT6_STATUS   , "STATUS" } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_CLIEXP" , (cAliasQry)->DT6_CLIEXP   , "CLIEXP"   } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_LOJEXP" , (cAliasQry)->DT6_LOJEXP   , "LOJEXP"   } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_METRO3" , (cAliasQry)->DT6_METRO3   , "METRO3" } ) 
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_CHVCTE"  , (cAliasQry)->DT6_CHVCTE  , "DT6_CHVCTE"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_CLICAL"  , (cAliasQry)->DT6_CLICAL  , "CLICAL"  } )
    Aadd( Self:aDocs[Len(::aDocs)] , { "DT6_LOJCAL"  , (cAliasQry)->DT6_LOJCAL  , "LOJCAL"  } )

    If Upper( AllTrim( cSerie ) ) <> "COL"
        If (cAliasQry)->DT6_SERTMS != StrZero(1, Len(DT6->DT6_SERTMS))
            Self:AddNF( cFilOri, cViagem , cFilDoc , cDoc , cSerie , (cAliasQry)->DT6_DOCTMS , cOperation )
        EndIf 
    Else
        Self:AddCol( cFilOri, cViagem , cFilDoc , cDoc, cSerie ) 
    EndIf

    (cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AddNF()
Adiciona Not

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddNF( cFilOri, cViagem , cFilDoc , cDoc , cSerie  , cDocTMS  , cOperation ) CLASS TMSBCADadosTMS
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local lDocRee	:= SuperGetMV('MV_DOCREE',,.F.)
Local nAux      := 1 

Static _oNF1
Static _oNF2    

Default cFilOri     := ""
Default cViagem     := ""
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""
Default cDocTMS     := ""
Default cOperation  := ""

If cDocTMS == "6" .Or. ( lDocRee .And. cDocTMS == "7" )//-- Documento de reentrega

    If _oNF1 == Nil 

        _oNF1   := FWPreparedStatement():New()

        cQuery  := "SELECT DY4_NUMNFC NUMNFC , DY4_SERNFC SERNFC , DTC_EMINFC EMINFC , DY4_CODPRO CODPRO , DY4_QTDVOL QTDVOL , DTC_PESO PESO , DTC_PESOM3 PESOM3 , DTC_VALOR VALOR  , "
        cQuery  += " B1_DESC "
        cQuery  += " FROM " + RetSQLName("DY4") + " DY4 "
        cQuery  += " LEFT JOIN " + RetSQLName("SB1") + " SB1 "
        cQuery  += "    ON B1_FILIAL        = ? "
        cQuery  += "    AND B1_COD          = DY4_CODPRO "
        cQuery  += "    AND SB1.D_E_L_E_T_  = ' ' "
        cQuery  += " INNER JOIN " + RetSQLName("DTC") + " DTC "
        cQuery  += "    ON DTC_FILIAL   = ? "
        cQuery  += "    AND DTC_NUMNFC  = DY4_NUMNFC "
        cQuery  += "    AND DTC_SERNFC  = DY4_SERNFC "
        cQuery  += "    AND DTC_LOTNFC  = DY4_LOTNFC "
        cQuery  += "    AND DTC.D_E_L_E_T_ = ' ' "
        cQuery  += " WHERE DY4_FILIAL   = ? "
        cQuery  += " AND DY4_FILDOC     = ? "
        cQuery  += " AND DY4_DOC        = ? "
        cQuery  += " AND DY4_SERIE      = ? "
        cQuery  += " AND DY4.D_E_L_E_T_ = ' ' "

        cQuery  := ChangeQuery(cQuery)

        _oNF1:SetQuery(cQuery)
    EndIf 

    _oNF1:SetString(nAux++, xFilial("SB1") )
    _oNF1:SetString(nAux++, xFilial("DTC") )			
    _oNF1:SetString(nAux++, xFilial("DY4") )
    _oNF1:SetString(nAux++, cFilDoc )
    _oNF1:SetString(nAux++, cDoc )
    _oNF1:SetString(nAux++, cSerie )
   
    cQuery  := _oNF1:GetFixQuery()

Else

    If _oNF2 == Nil
        _oNF2   := FWPreparedStatement():New()

        cQuery  := " SELECT DTC_NUMNFC NUMNFC , DTC_SERNFC SERNFC  , DTC_EMINFC EMINFC , DTC_CODPRO CODPRO , DTC_QTDVOL QTDVOL , DTC_PESO PESO , DTC_PESOM3 PESOM3 , DTC_VALOR VALOR , "
        cQuery  += " B1_DESC "
        cQuery  += " FROM " + RetSQLName("DTC") + " DTC "
        cQuery  += " LEFT JOIN " + RetSQLName("SB1") + " SB1 "
        cQuery  += "    ON B1_FILIAL        = ? "
        cQuery  += "    AND B1_COD          = DTC_CODPRO "
        cQuery  += "    AND SB1.D_E_L_E_T_  = ' ' "
        cQuery  += " WHERE DTC_FILIAL   = ? "
        cQuery  += " AND DTC_FILDOC     = ? "
        cQuery  += " AND DTC_DOC        = ? "
        cQuery  += " AND DTC_SERIE      = ? "
        cQuery  += " AND DTC.D_E_L_E_T_ = ' ' " 

        cQuery  := ChangeQuery(cQuery)

        _oNF2:SetQuery(cQuery)

    EndIf 

    _oNF2:SetString(nAux++, xFilial("SB1") )
    _oNF2:SetString(nAux++, xFilial("DTC") )			
    _oNF2:SetString(nAux++, cFilDoc )
    _oNF2:SetString(nAux++, cDoc )
    _oNF2:SetString(nAux++, cSerie )
   
    cQuery  := _oNF2:GetFixQuery()

EndIf

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
   
    Aadd(Self:aNF , {} )
    Aadd(Self:aNF[Len(::aNF)] , {"DTQ_FILORI"   , cFilOri                   , "FILORI"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTQ_VIAGEM"   , cViagem                   , "VIAGEM"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_FILDOC"   , cFilDoc                   , "FILDOC"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_DOC"      , cDoc                      , "DOC"     } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_SERIE"    , cSerie                    , "SERIE"   } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_NUMNFC"   , (cAliasQry)->NUMNFC       , "NUMNFC"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_SERNFC"   , (cAliasQry)->SERNFC       , "SERNFC"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_EMINFC"   , (cAliasQry)->EMINFC       , "EMINFC"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_CODPRO"   , (cAliasQry)->CODPRO       , "CODPRO"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"B1_DESC"      , (cAliasQry)->B1_DESC      , "DESC"    } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_QTDVOL"   , (cAliasQry)->QTDVOL       , "QTDVOL"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_PESO"     , (cAliasQry)->PESO         , "PESO"    } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_PESOM3"   , (cAliasQry)->PESOM3       , "PESOM3"  } )
    Aadd(Self:aNF[Len(::aNF)] , {"DTC_VALOR"    , (cAliasQry)->VALOR        , "VALOR"   } )
    Aadd(Self:aNF[Len(::aNF)] , {"OPERATION"    , cOperation                , "OPERATION" } )
    (cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AddVehicles()
Adiciona transportadores

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddVehicles( cFilOri , cViagem ) CLASS TMSBCADadosTMS
Local cAliasQry     := GetNextAlias()
Local cQuery        := ""
Local cCodFor       := ""
Local cLojFor       := ""
Local cCodVei       := ""
Local cPlaca        := ""
Local cNomeFor      := ""
Local cNomeReduz    := ""
Local cNomeRas      := ""
Local aArea         := GetArea()

Default cFilOri     := ""
Default cViagem     := ""

cQuery  := " SELECT DTR_CODVEI, DTR_CODRB1, DTR_CODRB2, DTR_CODRB3, DTR_CODFOR, DTR_LOJFOR, DTR_VALFRE , DTR_PRVFRE, DTR_ADIFRE , "
cQuery  += " DA3_PLACA , DA3_CAPACN , DA3_VOLMAX , DA3_COMEXT , DA3_QTDEIX, DTR_QTDEIX  , DTR_QTEIXV , DA3_LAREXT , DA3_ALTEXT ,"
cQuery  += " A2_CGC , A2_NOME , A2_NREDUZ, A2_CGC  "
cQuery  += " FROM  " + RetSQLName("DTR") + " DTR "  
cQuery  += " LEFT JOIN " + RetSqlName("DA3") + " DA3 "
cQuery  += "    ON DA3_FILIAL   = '" + xFilial("DA3") + "' "
cQuery  += "    AND DA3_COD     = DTR_CODVEI "
cQuery  += "    AND DA3.D_E_L_E_T_ = ' ' "
cQuery  += " LEFT JOIN " + RetSQLName("SA2") + " SA2 "
cQuery  += "    ON A2_FILIAL    = '" + xFilial("SA2") + "' "
cQuery  += "    AND A2_COD      = DTR_CODFOR "
cQuery  += "    AND A2_LOJA     = DTR_LOJFOR "
cQuery  += "    AND SA2.D_E_L_E_T_ = ' ' "
cQuery  += " WHERE DTR_FILIAL   = '" + xFilial("DTR") + "' "
cQuery  += "    AND DTR_FILORI     = '" + cFilOri + "' "
cQuery  += "    AND DTR_VIAGEM     = '" + cViagem + "' "
cQuery  += "    AND DTR.D_E_L_E_T_ = ' ' "

cQuery  := ChangeQuery(cQuery)

//-- Rastreador X Veículos
DAW->(dbSetOrder(1)) //-- FILIAL+CODVEI+SEQUEN

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
    cCodVei     := (cAliasQry)->DTR_CODVEI
    cPlaca      := (cAliasQry)->DA3_PLACA
    cCodFor     := (cAliasQry)->DTR_CODFOR
    cLojFor     := (cAliasQry)->DTR_LOJFOR    
    cNomeFor    := RTrim( (cAliasQry)->A2_NOME )
    cNomeReduz  := RTrim( (cAliasQry)->A2_NREDUZ )
   
    If DAW->( dbSeek(xFilial("DAW") + cCodVei ))
        While DAW->(!Eof()) .And. xFilial("DAW") + cCodVei == DAW->(DAW_FILIAL+DAW_CODVEI)
            cNomeRas := Posicione("SA2", 1 , xFilial("SA2") + DAW->DAW_CODRAS + DAW->DAW_LOJRAS, "A2_NOME")            
            Aadd(::aTracker , {} )
            Aadd(::aTracker[Len(::aTracker)] , { "DAW_CODVEI"   , cCodVei           , "CODVEI"  } )
            Aadd(::aTracker[Len(::aTracker)] , { "DAW_IDRAS"    , DAW->DAW_IDRAS    , "IDRAS"   } )
            Aadd(::aTracker[Len(::aTracker)] , { "A2_NOME"      , RTrim(cNomeRas)   , "NOME"    } )
            DAW->(dbSkip())
        EndDo       
    EndIf
    
    Aadd(::aVehicles , {} )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_CODVEI"   , cCodVei       , "CODVEI"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DA3_PLACA"    , cPlaca        , "PLACA"   } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_CODFOR"   , cCodFor       , "CODFOR"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_LOJFOR"   , cLojFor       , "LOJFOR"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "A2_NOME"      , cNomeFor      , "NOME"    } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "A2_NREDUZ"    , cNomeReduz    , "NREDUZ"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DA3_CAPACN"    , (cAliasQry)->DA3_CAPACN    , "DA3_CAPACN"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DA3_VOLMAX"    , (cAliasQry)->DA3_VOLMAX    , "DA3_VOLMAX"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DA3_COMEXT"    , (cAliasQry)->DA3_COMEXT    , "DA3_COMEXT"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_QTDEIX"    , (cAliasQry)->DTR_QTDEIX    , "DTR_QTDEIX"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DA3_LAREXT"    , (cAliasQry)->DA3_LAREXT    , "DA3_LAREXT"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DA3_ALTEXT"    , (cAliasQry)->DA3_ALTEXT    , "DA3_ALTEXT"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DA3_QTDEIX"    , (cAliasQry)->DA3_QTDEIX    , "DA3_QTDEIX"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_QTEIXV"    , (cAliasQry)->DTR_QTEIXV    , "DTR_QTEIXV"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "A2_CGC"        , (cAliasQry)->A2_CGC        , "CGC"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_VALFRE"    , (cAliasQry)->DTR_VALFRE    , "DTR_VALFRE"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_PRVFRE"    , (cAliasQry)->DTR_PRVFRE    , "DTR_PRVFRE"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_ADIFRE"    , (cAliasQry)->DTR_ADIFRE    , "DTR_ADIFRE"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_CODRB1"    , (cAliasQry)->DTR_CODRB1    , "DTR_CODRB1"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_CODRB2"    , (cAliasQry)->DTR_CODRB2    , "DTR_CODRB2"  } )
    Aadd(::aVehicles[Len(::aVehicles)]  , { "DTR_CODRB3"    , (cAliasQry)->DTR_CODRB3    , "DTR_CODRB3"  } )
    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AddOperation()
Retorna as Operações da Viagem

@author Caio Murakami
@since 18/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddOperation(cFilOri,cViagem) CLASS TMSBCADadosTMS
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()

Default cFilOri := ""
Default cViagem := ""

cQuery  := " SELECT DTW_SEQUEN , DTW_DATPRE , DTW_HORPRE , DTW_SERVIC , DTW_TAREFA , DTW_ATIVID , DTW_CODCLI , DTW_LOJCLI , "
cQuery  += " A1_NOME , A1_NREDUZ , A1_END , A1_COMPLEM , A1_BAIRRO , A1_MUN , A1_EST , A1_CEP , A1_PAIS , YA_DESCR "
cQuery  += " FROM " + RetSQLName("DTW") + " DTW "
cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1 "
cQuery  += "    ON A1_FILIAL    = '" + xFilial("SA1") + "'  "
cQuery  += "    AND A1_COD      = DTW_CODCLI "
cQuery  += "    AND A1_LOJA     = DTW_LOJCLI "
cQuery  += "    AND SA1.D_E_L_E_T_ = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("SYA") + " SYA "
cQuery  += "        ON  YA_FILIAL   = '" + xFilial("SYA") + "' "
cQuery  += "        AND YA_CODGI   = A1_PAIS "
cQuery  += "        AND SYA.D_E_L_E_T_ = ' ' "
cQuery  += " WHERE DTW_FILIAL   = '" + xFilial("DTW") + "' "
cQuery  += " AND DTW_FILORI     = '" + cFilOri + "' "
cQuery  += " AND DTW_VIAGEM     = '" + cViagem + "' "
cQuery  += " AND DTW.D_E_L_E_T_ = ' ' "
cQuery  += " ORDER BY DTW_SEQUEN "
cQuery  := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())

    Aadd( ::aOperation , {} )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_FILORI"  , cFilOri                                   , "FILORI"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_VIAGEM"  , cViagem                                   , "VIAGEM"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_SEQUEN"  , (cAliasQry)->DTW_SEQUEN                   , "SEQUEN"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_DATPRE"  , (cAliasQry)->DTW_DATPRE                   , "DATPRE"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_HORPRE"  , (cAliasQry)->DTW_HORPRE                   , "HORPRE"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_SERVIC"  , (cAliasQry)->DTW_SERVIC                   , "SERVIC"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_DESSER"  , Tabela("L4",(cAliasQry)-DTW_SERVIC,.F.)   , "DESSER"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_TAREFA"  , (cAliasQry)->DTW_TAREFA                   , "TAREFA"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_DESTAR"  , Tabela("L2",(cAliasQry)->DTW_TAREFA,.F.)  , "DESTAR"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_ATIVID"  , (cAliasQry)->DTW_ATIVID                   , "ATIVID"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_DESATI"  , Tabela("L3",(cAliasQry)->DTW_ATIVID,.F.)  , "DESATI"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_CODCLI"  , (cAliasQry)->DTW_CODCLI                   , "CODCLI"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "DTW_LOJCLI"  , (cAliasQry)->DTW_LOJCLI                   , "LOJCLI"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_NREDUZ"   , (cAliasQry)->A1_NREDUZ                    , "NREDUZ"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_NOME"     , (cAliasQry)->A1_NOME                      , "NOME"    } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_END"      , (cAliasQry)->A1_END                       , "END"     } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_COMPLEM"  , (cAliasQry)->A1_COMPLEM                   , "COMPLEM" } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_BAIRRO"   , (cAliasQry)->A1_BAIRRO                    , "BAIRRO"  } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_MUN"      , (cAliasQry)->A1_MUN                       , "MUN"     } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_EST"      , (cAliasQry)->A1_EST                       , "EST"     } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_CEP"      , (cAliasQry)->A1_CEP                       , "CEP"     } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_PAIS"     , (cAliasQry)->A1_PAIS                      , "PAIS"    } )
    Aadd( ::aOperation[Len(::aOperation)] , { "A1_PAISDES"  , (cAliasQry)->YA_DESCR                     , "PAISDES" } )
    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return 


//-----------------------------------------------------------------
/*/{Protheus.doc} AddDriver()
Retorna o motorista

@author Caio Murakami
@since 18/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddDriver(cFilOri,cViagem) CLASS TMSBCADadosTMS
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local cMail     := ""
Local cPais     := ""

Default cFilOri := ""
Default cViagem := ""

cQuery  := " SELECT DUP_CODMOT , DUP_ITEDTR , DUP_CONDUT,  DUP_IDOPE ,"
cQuery  += " DA4_NOME , DA4_NREDUZ ,  DA4_CGC , DA4_TEL  , "
cQuery  += " A2_EMAIL , A2_PAIS , YA_DESCR , "
cQuery  += " RA_EMAIL , RA_NACIONC , CCH_PAIS "
cQuery  += " FROM " + RetSQLName("DUP") + " DUP "
cQuery  += " LEFT JOIN " + RetSQLName("DA4") + " DA4 "
cQuery  += "    ON DA4_FILIAL    = '" + xFilial("DA4") + "'  "
cQuery  += "    AND DA4_COD      = DUP_CODMOT "
cQuery  += "    AND DA4.D_E_L_E_T_ = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("SA2") + " SA2 "
cQuery  += "        ON A2_FILIAL    = '" + xFilial("SA2") + "' "
cQuery  += "        AND A2_COD      =   DA4_FORNEC "
cQuery  += "        AND A2_LOJA     =   DA4_LOJA "
cQuery  += "        AND SA2.D_E_L_E_T_  = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("SYA") + " SYA "
cQuery  += "        ON  YA_FILIAL   = '" + xFilial("SYA") + "' "
cQuery  += "        AND YA_CODGI   = A2_PAIS "
cQuery  += "        AND SYA.D_E_L_E_T_ = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("SRA") + " SRA "
cQuery  += "        ON RA_FILIAL    = '" + xFilial("SRA") + "' "
cQuery  += "        AND RA_MAT      = DA4_MAT "
cQuery  += "        AND SRA.D_E_L_E_T_ = ' ' "
cQuery  += "    LEFT JOIN "  + RetSQLName("CCH") + " CCH "
cQuery  += "        ON CCH_FILIAL   = '" + xFilial("CCH") + "' "
cQuery  += "        AND CCH_CODIGO  = RA_NACIONC"
cQuery  += "        AND CCH.D_E_L_E_T_ = ' ' "
cQuery  += " WHERE DUP_FILIAL   = '" + xFIlial("DUP") + "' "
cQuery  += "    AND DUP_FILORI  = '" + cFilOri + "' "
cQuery  += "    AND DUP_VIAGEM  = '" + cViagem + "' "
cQuery  += "    AND DUP.D_E_L_E_T_ = ' ' "
cQuery  := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())

    cMail   := AllTrim( Iif( !Empty((cAliasQry)->A2_EMAIL), (cAliasQry)->A2_EMAIL , (cAliasQry)->RA_EMAIL  ) )
    cPais   := AllTrim( Iif( !Empty((cAliasQry)->A2_PAIS)  , (cAliasQry)->YA_DESCR , (cAliasQry)->CCH_PAIS) ) 

    Aadd(::aDriver, {} )
    Aadd(::aDriver[Len(::aDriver)] , { "DUP_FILORI" , cFilOri                   , "FILORI" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DUP_VIAGEM" , cViagem                   , "VIAGEM" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DUP_ITEDTR" , (cAliasQry)->DUP_ITEDTR   , "ITEDTR" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DUP_CODMOT" , (cAliasQry)->DUP_CODMOT   , "CODMOT" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DUP_CONDUT" , (cAliasQry)->DUP_CONDUT   , "CONDUT" } ) 
    Aadd(::aDriver[Len(::aDriver)] , { "DA4_CGC"    , (cAliasQry)->DA4_CGC      , "CGC" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DA4_NREDUZ" , (cAliasQry)->DA4_NREDUZ   , "NREDUZ" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DA4_NOME"   , (cAliasQry)->DA4_NOME     , "NOME" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DA4_TEL"    , (cAliasQry)->DA4_TEL      , "TEL" } )
    Aadd(::aDriver[Len(::aDriver)] , { "MAIL"       , cMail                     , "MAIL" } )
    Aadd(::aDriver[Len(::aDriver)] , { "PAIS"       , cPais                     , "PAIS" } )
    Aadd(::aDriver[Len(::aDriver)] , { "DUP_IDOPE"  , (cAliasQry)->DUP_IDOPE    , "DUP_IDOPE" } )
    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} AddCol()
Adiciona Itens das Solicitações de Coletas - DUM

@author Rafael Souza
@since 30/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddCol( cFilOri, cViagem , cFilDoc , cDoc, cSerie ) CLASS TMSBCADadosTMS
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()

Default cFilOri := ""
Default cViagem := ""

cQuery  := " SELECT DUM_NUMSOL , DUM_ITEM , DUM_CODPRO , DUM_QTDVOL , DUM_PESO , DUM_PESOM3 , DUM_VALMER , "
cQuery  += " B1_DESC "
cQuery  += " FROM " + RetSQLName("DUM") + " DUM "
cQuery  += " LEFT JOIN " + RetSQLName("SB1") + " SB1 "
cQuery  += "    ON B1_FILIAL        = '" + xFilial("SB1") + "' "
cQuery  += "    AND B1_COD          = DUM_CODPRO "
cQuery  += "    AND SB1.D_E_L_E_T_  = ' ' "
cQuery  += " WHERE DUM_FILIAL   = '" + xFilial("DUM") + "' "
cQuery  += " AND DUM_FILORI     = '" + cFilDoc + "' "
cQuery  += " AND DUM_NUMSOL     = '" + cDoc + "' "
cQuery  += " AND DUM.D_E_L_E_T_ = ' ' " 
cQuery  := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
   
    Aadd(Self:aColetas , {} )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DTQ_FILORI"   , cFilOri                   , "FILORI"  } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DTQ_VIAGEM"   , cViagem                   , "VIAGEM"  } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_FILDOC"   , cFilDoc                   , "FILDOC"  } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_NUMSOL"   , cDoc                      , "DOC"     } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_ITEM"     , (cAliasQry)->DUM_ITEM     , "ITEM"    } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_CODPRO"   , (cAliasQry)->DUM_CODPRO   , "CODPRO"  } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"B1_DESC"      , (cAliasQry)->B1_DESC      , "DESC"    } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_QTDVOL"   , (cAliasQry)->DUM_QTDVOL   , "QTDVOL"  } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_PESO"     , (cAliasQry)->DUM_PESO     , "PESO"    } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_PESOM3"   , (cAliasQry)->DUM_PESOM3   , "PESOM3"  } )
    Aadd(Self:aColetas[Len(::aColetas)] , {"DUM_VALMER"   , (cAliasQry)->DUM_VALMER   , "VALOR"   } )

    (cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} PointOcor()
Apontar Ocorrências

@author Caio Murakami
@since 21/08/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PointOcor( cFilOri , cViagem , cNumOco , cSeqOco )  CLASS TMSBCADadosTMS
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local aArea         := GetArea()

Default cFilOri     := ""
Default cViagem     := ""
Default cNumOco     := ""
Default cSeqOco     := ""

cQuery  := " SELECT  DUA_FILORI ,  DUA_VIAGEM ,  DUA_NUMOCO , DUA_SEQOCO , DUA_DATOCO , DUA_HOROCO , DUA_CODOCO , "
cQuery  += " DUA_CODMOT ,  DUA_FILDOC ,  DUA_DOC , DUA_SERIE , DT2_DESCRI , "
cQuery  += " A1_COD , A1_LOJA , A1_NOME , A1_NREDUZ ,A1_EST, A1_CEP , A1_END, A1_BAIRRO , A1_MUN , A1_COMPLEM, YA_DESCR "
cQuery  += "    FROM  " + RetSQLName("DUA") + " DUA "
cQuery  += "    LEFT JOIN " + RetSQLName("DT6") + " DT6 "
cQuery  += "        ON DT6_FILIAL           = '" + xFilial("DT6") + "' "
cQuery  += "            AND DT6_FILDOC      = DUA_FILDOC "
cQuery  += "            AND DT6_DOC         = DUA_DOC "
cQuery  += "            AND DT6_SERIE       = DUA_SERIE "
cQuery  += "            AND DT6.D_E_L_E_T_  = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("SA1") + " SA1DES "
cQuery  += "        ON A1_FILIAL            = '" + xFilial("SA1") + "' "
cQuery  += "            AND A1_COD          = DT6_CLIDES "
cQuery  += "            AND A1_LOJA         = DT6_LOJDES "
cQuery  += "            AND SA1DES.D_E_L_E_T_  = '' "
cQuery  += "    LEFT JOIN " + RetSQLName("SYA") + " SYA "
cQuery  += "        ON  YA_FILIAL           = '" + xFilial("SYA") + "' "
cQuery  += "            AND YA_CODGI        = SA1DES.A1_PAIS "
cQuery  += "            AND SYA.D_E_L_E_T_  = ' ' "
cQuery  += "    LEFT JOIN " + RetSQLName("DT2") + " DT2 "
cQuery  += "        ON DT2_FILIAL       = '" + xFilial("DT2") + "' "
cQuery  += "        AND DT2_CODOCO      = DUA_CODOCO "
cQuery  += "        AND DT2.D_E_L_E_T_  = '' "
cQuery  += "    WHERE DUA_FILIAL    = '" + xFilial("DUA") + "' "
cQuery  += "        AND DUA_FILORI  = '" + cFilOri + "' "
cQuery  += "        AND DUA_VIAGEM  = '" + cViagem + "' "
If !Empty(cNumOco)
    cQuery      += "    AND DUA_NUMOCO  = '" + cNumOco + "' "
EndIf
If !Empty(cSeqOco)
    cQuery      += "    AND DUA_SEQOCO  = '" + cSeqOco + "' "
EndIf
cQuery      += "        AND DUA.D_E_L_E_T_  = ' ' "

cQuery  := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !EOF() )
    Aadd(::aPointOcor , {} )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_FILORI"   , (cAliasQry)->DUA_FILORI   , "FILORI"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_VIAGEM"   , (cAliasQry)->DUA_VIAGEM   , "VIAGEM"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_NUMOCO"   , (cAliasQry)->DUA_NUMOCO   , "NUMOCO"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_SEQOCO"   , (cAliasQry)->DUA_SEQOCO   , "SEQOCO"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_DATOCO"   , (cAliasQry)->DUA_DATOCO   , "DATOCO"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_HOROCO"   , (cAliasQry)->DUA_HOROCO   , "HOROCO"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_CODOCO"   , (cAliasQry)->DUA_CODOCO   , "CODOCO"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DT2_DESCRI"   , (cAliasQry)->DT2_DESCRI   , "DESCRI"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_CODMOT"   , (cAliasQry)->DUA_CODMOT   , "CODMOT"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_FILDOC"   , (cAliasQry)->DUA_FILDOC   , "FILDOC"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_DOC"      , (cAliasQry)->DUA_DOC      , "DOC"     } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "DUA_SERIE"    , (cAliasQry)->DUA_SERIE    , "SERIE"   } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_COD"       , (cAliasQry)->A1_COD       , "COD"     } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_LOJA"      , (cAliasQry)->A1_LOJA      , "LOJA"    } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_NOME"      , (cAliasQry)->A1_NOME      , "NOME"    } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_NREDUZ"    , (cAliasQry)->A1_NREDUZ    , "NREDUZ"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_EST"       , (cAliasQry)->A1_EST       , "EST"     } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_CEP"       , (cAliasQry)->A1_CEP       , "CEP"     } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_END"       , (cAliasQry)->A1_END       , "END"     } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_BAIRRO"    , (cAliasQry)->A1_BAIRRO    , "BAIRRO"  } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_MUN"       , (cAliasQry)->A1_MUN       , "MUN"     } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "A1_COMPLEM"   , (cAliasQry)->A1_COMPLEM   , "COMPLEM" } )
    Aadd(::aPointOcor[Len(::aPointOcor)] , { "YA_DESCR"     , (cAliasQry)->YA_DESCR     , "PAIS"    } )
    (cAliasQry)->(dbSkip())
EndDo

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} PointOperation()
Apontar operação

@author Caio Murakami
@since 26/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PointOperation(cFilOri, cViagem, nOpcx, cAtivid , dDatIni, cHorIni, dDatRea, cHorRea, cCodCli, cLojCLi , cSequen ) CLASS TMSBCADadosTMS
Local aArea     := GetArea()

Default cFilOri     := ::cFilOri
Default cViagem     := ::cViagem
Default nOpcx       := ::nOperation
Default cAtivid     := ""
Default dDatIni     := dDataBase
Default cHorIni     := Time()
Default dDatRea     := dDataBase
Default cHorRea     := ""
Default cCodCli     := ""
Default cLojCli     := ""
Default cSequen     := ""

Aadd(::aPointOper, {} )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_FILORI" , cFilOri , "FILORI" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_VIAGEM" , cViagem , "VIAGEM" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_CODCLI" , cCodCli , "CODCLI" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_LOJCLI" , cLojCli , "LOJCLI" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_SEQUEN" , cSequen , "SEQUEN" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_ATIVID" , cAtivid , "ATIVID" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_DESATI" , Tabela("L3",cAtivid,.F.) , "DESATI" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_DATINI" , dDatIni , "DATINI" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_HORINI" , cHorIni , "HORINI" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_DATREA" , dDatRea , "DATREA" } )
Aadd(::aPointOper[Len(::aPointOper)] , { "DTW_HORREA" , cHorRea , "HORREA" } )

RestArea(aArea)
Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} Connect()
Conecta webservice

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Connect(lMostraErr) CLASS TMSBCADadosTMS

//Local cURL          := SuperGetMv("MV_CPLURL",.F.,"")
Local lConectado    := .F. 
Local aArea         := GetArea()

Default lMostraErr  := .F.

//FwMsgRun( , { |oSay| lConectado := OMSXCPLWST(cURL,.F.) } , "Processando" , "Efetuando conexão com NeoLog" )

/*If !lConectado
    ::AddError("Falha comunicação NeoLog!")    
    ::AddError(cValToChar(GetWSCError())    )
    ::AddError(cValToChar(GetWSCError(2))   )
    ::AddError(cValToChar(GetWSCError(3))   )

    If lMostraErr
        ::ShowError()
    EndIf
EndIf */

lConectado := .T.
::lConectado    := lConectado

RestArea(aArea)
Return lConectado

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDocs()
Retorna os documentos da viagem

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetDocs() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(Self:aDocs)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetCustomer()
Retorna os clientes da viagem com base nos documentos da mesma

@author Leandro Paulino
@since 31/07/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetCustomers() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(Self:aCustomers)

Return aRet


//-----------------------------------------------------------------
/*/{Protheus.doc} GetNF()
Retorna os documentos da viagem

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetNF() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(Self:aNF)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetVehicles()
Retorna os veículos e proprietarios

@author Caio Murakami
@since 14/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetVehicles() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(Self:aVehicles)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetTracker()
Retorna os rastreadores dos veículos

@author Caio Murakami
@since 19/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetTracker() CLASS TMSBCADadosTMS
Local aRet      := {}

aRet    := aClone(::aTracker )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetOperation()
Retorna as operações DTW

@author Caio Murakami
@since 18/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetOperation() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(Self:aOperation)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriver()
Retorna os motoristas da viagem

@author Caio Murakami
@since 18/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetDriver() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(Self:aDriver)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetColetas()
Retorna os itens das Coletas da Viagem - DUM

@author Rafael Souza
@since 30/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetColetas() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(Self:aColetas)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetXML()
Retorna o Xml

@author Caio Murakami
@since 18/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetXML() CLASS TMSBCADadosTMS
Local oXML  

oXML    := Self:oXMLVge

Return oXML

//-----------------------------------------------------------------
/*/{Protheus.doc} GetErrorXML()
Recupera erro do XML

@author Caio Murakami
@since 19/07/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetErrorXML( oXml ) CLASS TMSBCADadosTMS
Local aRet      := {}
Local oXmlAux   := Nil
Local cError    := ""

Default oXML    := Nil

 //-- Verifica nós do XML
If XmlChildEx(oXml, '_NS2_RESPONSE' ) <> Nil
    oXmlAux     := oXML:_NS2_RESPONSE

    If  XmlChildEx(oXmlAux, '_NS2_MESSAGES' ) <> Nil 
        oXmlAux     := oXmlAux:_NS2_MESSAGES

        If XmlChildEx(oXmlAux, '_NS2_RESPONSEMESSAGE' ) <> Nil 
            oXmlAux     := oXmlAux:_NS2_RESPONSEMESSAGE
            
            If XmlChildEx(oXmlAux, '_NS2_CODE' ) <> Nil 
                cError   := AllTrim(oXmlAux:_NS2_CODE:Text)
                Aadd(aRet , cError )
            EndIf

            If XmlChildEx(oXmlAux, '_NS2_DESCRIPTION' ) <> Nil 
                cError  := AllTrim(oXmlAux:_NS2_DESCRIPTION:Text) 
                Aadd(aRet , cError )
            EndIf
        EndIf
    EndIf
EndIf

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetPointOper()
Retorna operação apontada

@author Caio Murakami
@since 26/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetPointOper() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(::aPointOper)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AddCustomerTrip()
Retona os clientes destinatários da viagem

@author Leandro 
@since 26/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD AddCustomerTrip( cFilOri, cViagem ) CLASS TMSBCADadosTMS
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aArea      := GetArea()
Local cClientes  := ""
Local cFuncNull  := ""
Local cDbType    := TCGetDB()
Local lDT6SqeDes := DT6->(ColumnPos("DT6_SQEDES")) > 0
Local cCliAdd    := ""
Local lCliExpRec := ""

Default cFilOri := ""
Default cViagem := ""

// Tratamento para ISNULL em diferentes BD's
Do Case
    Case cDbType $ "DB2/POSTGRES"
        cFuncNull	:= "COALESCE"
    Case cDbType $ "ORACLE/INFORMIX"
        cFuncNull	:= "NVL"
    Otherwise
        cFuncNull	:= "ISNULL"
EndCase
	
cQuery  := " SELECT DT6_SERIE,  DUD.DUD_SEQUEN, DUD.DUD_SERTMS, " + cFuncNull + "(DT5.DT5_CLIREM,'') DT5_CLIREM , " + cFuncNull + "(DT5.DT5_LOJREM,'') DT5_LOJREM, " 
cQuery  += cFuncNull + "(SA1REM.A1_NOME,'') A1_NOMEREM,  DT6.DT6_CLIDES, DT6.DT6_LOJDES, SA1DES.A1_NOME A1_NOMEDES   "

If lDT6SqeDes
    cQuery  += ", " + cFuncNull + " (DUL.DUL_CODRED,'') DUL_CODRED  , " + cFuncNull + " (DUL.DUL_LOJRED,'') DUL_LOJRED , " + cFuncNull + " (SA1SQE.A1_NOME,'') NOME_SQDES  "
EndIf    

//Expedidor da Coleta
cQuery  += ", " + cFuncNull + " (DT6_CLIEXP,'') DT6_CLIEXP  , " + cFuncNull + " (DT6_LOJEXP,'') DT6_LOJEXP , " + cFuncNull + " (SA1EXP.A1_NOME,'') NOME_EXP  "
//Recebedor da Coleta
cQuery  += ", " + cFuncNull + " (DT6_CLIREC,'') DT6_CLIREC  , " + cFuncNull + " (DT6_LOJREC,'') DT6_LOJREC , " + cFuncNull + " (SA1REC.A1_NOME,'') NOME_REC  "

cQuery  += " FROM " + RetSQLName("DUD") + " DUD  "

cQuery  += " INNER JOIN " + RetSQLName("DT6") + " DT6           "
cQuery  += "    ON DT6_FILIAL       = '" + xFilial("DT6") + "'  "
cQuery  += "    AND DT6_FILDOC      = DUD_FILDOC                "
cQuery  += "    AND DT6_DOC         = DUD_DOC                   "
cQuery  += "    AND DT6_SERIE       = DUD_SERIE                 "
cQuery  += "    AND DT6.D_E_L_E_T_  = ' '                       "

cQuery  += " LEFT JOIN " + RetSQLName("DT5") + " DT5            "
cQuery  += "    ON DT5_FILIAL      = '" + FwxFilial ("DT5") + "'"
cQuery  += " 	AND DT5_FILDOC     = DUD_FILDOC                 "
cQuery  += "	AND DT5_DOC        = DUD_DOC                    "
cQuery  += "    AND DT5_SERIE      = DUD_SERIE                  "
cQuery  += "    AND DT5.D_E_L_E_T_ = ' '                        "

cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1DES             "
cQuery  += "    ON SA1DES.A1_FILIAL     = '" + xFilial("SA1") + "'  "
cQuery  += "    AND SA1DES.A1_COD       = DT6_CLIDES                "
cQuery  += "    AND SA1DES.A1_LOJA      = DT6_LOJDES                "
cQuery  += "    AND SA1DES.D_E_L_E_T_   = ' '                       "

cQuery  += " LEFT JOIN " + RetSqlName("SA1") + " SA1REM "
cQuery  += "    ON SA1REM.A1_FILIAL = '" + xFilial("SA1") + "'  "
cQuery  += "    AND SA1REM.A1_COD   = DT5.DT5_CLIREM    "
cQuery  += "    AND SA1REM.A1_LOJA  = DT5.DT5_LOJREM    "
cQuery  += "    AND SA1REM.D_E_L_E_T_ = ' '             "

If lDT6SqeDes
    cQuery  += " LEFT JOIN " + RetSQLName("DUL") + " DUL "
    cQuery  += "    ON DUL.DUL_FILIAL = '" + xFilial("DUL") + "' "
    cQuery  += "    AND DUL.DUL_CODCLI = DT6_CLIDES "
    cQuery  += "    AND DUL.DUL_LOJCLI = DT6_LOJDES "
    cQuery  += "    AND DUL.DUL_SEQEND = DT6_SQEDES "
    cQuery  += "    AND DUL.D_E_L_E_T_ = '' "
    cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1SQE "
    cQuery  += "    ON SA1SQE.A1_FILIAL     = '" + xFilial("SA1") + "'  "
    cQuery  += "    AND SA1SQE.A1_COD       = DUL_CODRED               "
    cQuery  += "    AND SA1SQE.A1_LOJA      = DUL_LOJRED               "
    cQuery  += "    AND SA1SQE.D_E_L_E_T_   = ' ' 
EndIf

//Expedidor da Coleta
cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1EXP "
cQuery  += "    ON SA1EXP.A1_FILIAL     = '" + xFilial("SA1") + "'  "
cQuery  += "    AND SA1EXP.A1_COD       = DT6_CLIEXP               "
cQuery  += "    AND SA1EXP.A1_LOJA      = DT6_LOJEXP               "
cQuery  += "    AND SA1EXP.D_E_L_E_T_   = ' ' 

//Recebedor da Coleta
cQuery  += " LEFT JOIN " + RetSQLName("SA1") + " SA1REC "
cQuery  += "    ON SA1REC.A1_FILIAL     = '" + xFilial("SA1") + "'  "
cQuery  += "    AND SA1REC.A1_COD       = DT6_CLIREC               "
cQuery  += "    AND SA1REC.A1_LOJA      = DT6_LOJREC               "
cQuery  += "    AND SA1REC.D_E_L_E_T_   = ' ' 

cQuery  += " WHERE DUD_FILIAL   = '" + xFilial("DUD") + "'  "
cQuery  += "    AND DUD_FILORI  = '" + cFilOri + "' "
cQuery  += "    AND DUD_VIAGEM  = '" + cViagem + "' "
cQuery  += "    AND DUD.D_E_L_E_T_ = ' ' "
cQuery += "  ORDER BY DUD.DUD_SEQUEN "

cQuery  := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
    cCliAdd := ""
    //--Se for viagem de coleta compara a duplicidade de clientes através do DT5_CLIREM e DT5_LOJREM
    If (cAliasQry)->(DUD_SERTMS) == '1'
        If ( lCliExpRec := !Empty((cAliasQry)->(DT6_CLIEXP)) .And. !Empty((cAliasQry)->(DT6_LOJEXP)) )
            cCliAdd := "|" + (cAliasQry)->DT6_CLIEXP + (cAliasQry)->DT6_LOJEXP + "|"
        Else
            cCliAdd := "|" + (cAliasQry)->DT5_CLIREM + (cAliasQry)->DT5_LOJREM + "|"
        EndIf
        If ! cCliAdd $ cClientes
            Aadd( Self:aCustomers , {} ) 
            If lCliExpRec
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_CLIEXP    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_LOJEXP    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->NOME_EXP    )
            Else
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT5_CLIREM    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT5_LOJREM    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->A1_NOMEREM    )
            EndIf
            cClientes += cCliAdd
        EndIf

    ElseIf (cAliasQry)->(DUD_SERTMS) == '3'

        If lDT6SqeDes .And. Empty( (cAliasQry)->DUL_CODRED ) .And. Empty( (cAliasQry)->DUL_LOJRED ) .Or. !lDT6SqeDes
            //--Se não for viagem de coleta compara a duplicidade de clientes através do DT6_CLIDES e DT6_LOJDES
            If ! ("|" + (cAliasQry)->DT6_CLIDES + (cAliasQry)->DT6_LOJDES + "|" $ cClientes)
        
                cClientes += "|" + (cAliasQry)->DT6_CLIDES + (cAliasQry)->DT6_LOJDES+ "|"
                Aadd( Self:aCustomers , {} ) 
                
                //-- Destinatário
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_CLIDES    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_LOJDES    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->A1_NOMEDES    )
                
            EndIf       
        Else
            If lDT6SqeDes  .And. ! ("|" + (cAliasQry)->DUL_CODRED + (cAliasQry)->DUL_LOJRED + "|" $ cClientes)
                cClientes  +=  "|" + (cAliasQry)->DUL_CODRED + (cAliasQry)->DUL_LOJRED+ "|"
                
                Aadd( Self:aCustomers , {} ) 
                
                //-- Destinatário
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DUL_CODRED    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DUL_LOJRED    )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->NOME_SQDES    )
                
            EndIf
        EndIf 
    EndIf
    
    If (cAliasQry)->(DUD_SERTMS) == '1' .AND. !Empty((cAliasQry)->DT6_CLIDES) .AND. !Empty((cAliasQry)->DT6_LOJDES)
        cCliAdd := ""
        If ( lCliExpRec := !Empty((cAliasQry)->(DT6_CLIREC)) .And. !Empty((cAliasQry)->(DT6_LOJREC)) )
            cCliAdd := "|" + (cAliasQry)->DT6_CLIREC + (cAliasQry)->DT6_LOJREC + "|"
        Else
            cCliAdd := "|" + (cAliasQry)->DT6_CLIDES + (cAliasQry)->DT6_LOJDES + "|"
        EndIf
        If ! (cCliAdd $ cClientes)
            Aadd( Self:aCustomers , {} ) 
            If lCliExpRec
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_CLIREC )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_LOJREC )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->NOME_REC   )
            Else
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_CLIDES )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->DT6_LOJDES )
                Aadd( Self:aCustomers[Len(::aCustomers)] , (cAliasQry)->A1_NOMEDES )
            EndIf
            cClientes += cCliAdd
        EndIf
    EndIf

    (cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetPointOcor()
Retorna Ocorrência apontada

@author Rafael Souza
@since 14/08/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetPointOcor() CLASS TMSBCADadosTMS
Local aRet      := {} 

aRet    := aClone(::aPointOcor)

Return aRet
//-----------------------------------------------------------------
/*/{Protheus.doc} CleanDate()
Limpa dados

@author Caio Murakami
@since 26/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD CleanDate() CLASS TMSBCADadosTMS

FwFreeObj(::aDocs       )
FwFreeObj(::aNF         )
FwFreeObj(::aVehicles   )
FwFreeObj(::aTracker    )
FwFreeObj(::aOperation  )
FwFreeObj(::aDriver     )
FwFreeObj(::aError      )
FwFreeObj(::oXMLVge     )
FwFreeObj(::aPointOper  )
FwFreeObj(::aPointOcor  )
FwFreeObj(::aColetas    )
FwFreeObj(::aCustomers  )

::aDocs         := {}
::aNF           := {}
::aVehicles     := {}
::aTracker      := {}
::aOperation    := {}
::aDriver       := {}
::aError        := {}
::aPointOper    := {}
::aPointOcor    := {}
::aColetas      := {}
::aCustomers    := {}

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Destroi objeto

@author Caio Murakami
@since 18/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Destroy() CLASS TMSBCADadosTMS

::CleanDate()

::aDocs         := Nil
::aNF           := Nil
::aVehicles     := Nil
::aTracker      := Nil
::aOperation    := Nil
::aDriver       := Nil
::aError        := Nil
::aPointOper    := Nil
::aPointOcor    := Nil 
::aColetas      := Nil
::aCustomers    := Nil

FwFreeObj(Self)

Return


