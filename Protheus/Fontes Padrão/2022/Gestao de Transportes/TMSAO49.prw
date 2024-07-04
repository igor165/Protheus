#include 'protheus.ch'
#include 'fileio.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCAContRotaInt()
Classe de Controle Integração com a Rota Inteligente

@author Rafael Souza
@since 11/06/2019
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCAContRotaInt

    DATA cEntidade      As Character
    DATA cFilEnt        As Character 
    DATA cChaveEnt      AS Character
    DATA cModulo        AS Character
    DATA cRotina        AS Character 
    DATA cApi           AS Character 
    DATA cIDRequis      AS Character 
    DATA cCodUser       AS Character 
    DATA dDatEnv        AS Date 
    DATA cHorEnv        AS Character 
    DATA dDatRet        AS Date
    DATA cHorRet        AS Character  
    DATA aCab           AS Array 
    DATA cRet           AS Character  
    DATA cEnvio         AS Character  
    DATA cStatus        As Character

    METHOD New()        Constructor 
    METHOD InsertDLU()
    METHOD UpdateDLU()
    METHOD RemoveDLU()    
    METHOD Destroy()


END CLASS 

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Rafael Souza
@since 11/06/2019
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New() CLASS TMSBCAContRotaInt

Return 


//-----------------------------------------------------------------
/*/{Protheus.doc} IncDLU()
Método responsável pela inclusão da tabela DLU

@author Rafael Souza
@since 12/06/2019
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD InsertDLU( cFilEnt, cEntidade , cChaveEnt , cApi, cIDRequis, cRotina, cRet, cEnvio , cStatus ) CLASS TMSBCAContRotaInt

Local aArea         := GetArea()
Local aAreaDLU      := DLU->(GetArea()) 

Default cFilEnt     := ""
Default cEntidade   := ""
Default cChaveEnt   := ""
Default cApi        := ""
Default cIDRequis   := ""
Default cRotina     := ""
Default cRet        := ""
Default cEnvio      := ""
Default cStatus     := "1"

::cFilEnt       := cFilEnt
::cEntidade     := cEntidade
::cChaveEnt     := cChaveEnt
::cApi          := cApi 
::cIDRequis     := cIDRequis
::cRotina       := cRotina 
::dDatEnv       := dDataBase
::cHorEnv       := StrTran(Left(Time(),5),':','')
::dDatRet       := cTod("")
::cHorRet       := ""
::cCodUser      := __cUserID
::aCab          := {}
::cRet          := cRet
::cEnvio        := cEnvio
::cStatus       := cStatus

If nModulo == 43 
    cModulo := "SIGATMS"
EndIf 

Aadd( ::aCab  , {"DLU_FILIAL" , xFilial("DLU")	  , Nil } )
Aadd( ::aCab  , {"DLU_FILENT" , ::cFilEnt         , Nil } )
Aadd( ::aCab  , {"DLU_ENTIDA" , ::cEntidade       , Nil } )
Aadd( ::aCab  , {"DLU_CHVENT" , ::cChaveEnt       , Nil } )
Aadd( ::aCab  , {"DLU_MODULO" , cModulo           , Nil } )
Aadd( ::aCab  , {"DLU_ROTINA" , ::cRotina         , Nil } )
Aadd( ::aCab  , {"DLU_API"    , ::cApi            , Nil } )
Aadd( ::aCab  , {"DLU_DATENV" , ::dDatEnv         , Nil } )
Aadd( ::aCab  , {"DLU_HORENV" , ::cHorEnv         , Nil } )
Aadd( ::aCab  , {"DLU_IDREQ"  , ::cIDRequis       , Nil } )
Aadd( ::aCab  , {"DLU_RETORN" , ::cRet            , Nil } )
Aadd( ::aCab  , {"DLU_USER"   , ::cCodUser        , Nil } )
Aadd( ::aCab  , {"DLU_ENVIO"  , ::cEnvio          , Nil } )
Aadd( ::aCab  , {"DLU_STATUS" , ::cStatus         , Nil } )

If Len(::aCab) > 0 
    TMSMdlAuto( ::aCab ,,3, "TMSAO50" , "MdFieldDLU" ,, "DLU",)
EndIf 

RestArea( aAreaDLU )
RestArea( aArea )

Return 


//-----------------------------------------------------------------
/*/{Protheus.doc} UpdateDLU()
Método responsável pela alteração da tabela DLU

@author Katia Tiemi
@since 12/06/2019
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD UpdateDLU( cFilEnt, cEntidade , cChaveEnt , cApi, cIDRequis, cRotina, cRet ) CLASS TMSBCAContRotaInt

Local aArea         := GetArea()
Local aAreaDLU      := DLU->(GetArea()) 

Default cFilEnt     := ""
Default cEntidade   := ""
Default cChaveEnt   := ""
Default cApi        := ""
Default cIDRequis   := ""
Default cRotina     := ""
Default cRet        := ""

::cFilEnt       := Padr((cFilEnt),Len(DLU->DLU_FILENT))
::cEntidade     := Padr((cEntidade),Len(DLU->DLU_ENTIDA))
::cChaveEnt     := Padr((cChaveEnt),Len(DLU->DLU_CHVENT))
::cApi          := cApi 
::cIDRequis     := cIDRequis
::cRotina       := cRotina 
::dDatRet       := dDataBase
::cHorRet       :=StrTran(Left(Time(),5),':','')
::aCab          := {}
::cRet          := cRet

DLU->(dbSetOrder(2))
If DLU->( MsSeek( xFilial("DLU") + ::cFilEnt + ::cEntidade + ::cChaveEnt ) )
    Aadd( ::aCab  , {"DLU_DATRET" , ::dDatRet         , Nil } )
    Aadd( ::aCab  , {"DLU_HORRET" , ::cHorRet         , Nil } )
    Aadd( ::aCab  , {"DLU_RETORN" , ::cRet            , Nil } )   //verificar
   // Aadd( ::aCab  , {"DLU_QTDTEN" , 1                  , Nil } )   //verificar

    If Len(::aCab) > 0 
        TMSMdlAuto( ::aCab ,,4, "TMSAO50" , "MdFieldDLU" ,, "DLU",)
    EndIf 

EndIf 

RestArea( aAreaDLU )
RestArea( aArea )

Return 


//-----------------------------------------------------------------
/*/{Protheus.doc} RemoveDLU()
Método responsável pela exclusão da tabela DLU

@author Katia Tiemi
@since 12/06/2019
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD RemoveDLU( cFilEnt, cEntidade , cChaveEnt , cApi, cIDRequis, cRotina ) CLASS TMSBCAContRotaInt

Local aArea         := GetArea()
Local oMdlDLU       := Nil
Local lRet          := .F.

Default cFilEnt     := ""
Default cEntidade   := ""
Default cChaveEnt   := ""
Default cApi        := ""
Default cIDRequis   := ""
Default cRotina     := ""

::cFilEnt       := cFilEnt
::cEntidade     := cEntidade
::cChaveEnt     := cChaveEnt
::cApi          := cApi 
::cIDRequis     := cIDRequis
::cRotina       := cRotina 
::dDatEnv       := dDataBase
::cHorEnv       := StrTran(Left(Time(),5),':','')
::dDatRet       := cTod("")
::cHorRet       := ""
::cCodUser      := __cUserID
::aCab          := {}

DLU->(dbSetOrder(2))
If DLU->( MsSeek( xFilial("DLU") + ::cFilEnt + ::cEntidade + ::cChaveEnt + DLU->DLU_CODIGO ) )
    oMdlDLU := FWLoadModel( 'TMSAO50' )
	oMdlDLU :SetOperation( MODEL_OPERATION_DELETE )
	oMdlDLU :Activate()
	lRet := oMdlDLU:VldData()
			
	If lRet
		lRet := oMdlDLU:CommitData()
	EndIf
		
	oMdlDLU:DeActivate()
EndIf 

RestArea( aArea )

Return 



//-----------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Destroy objeto

@author Rafael Souza
@since 12/06/2019
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Destroy() CLASS TMSBCAContRotaInt

::aCab          := Nil 
 
Return 
