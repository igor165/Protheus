#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TMSXFUNJ.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCAPagBem()
Classe criada para comunicação com PagBem

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

CLASS TMSBCAPagBem

    DATA IsLogActive            AS LOGICAL
    DATA cPATHLOG               AS CHARACTER
    //-- Informações Token
    DATA Instaciado             AS LOGICAL
    DATA deg_codope             AS CHARACTER
    DATA url_token              AS CHARACTER
    DATA access_token           AS CHARACTER
    DATA grant_type             AS CHARACTER
    DATA username               AS CHARACTER
    DATA password               AS CHARACTER
    DATA last_error             AS CHARACTER
    DATA time_token             AS CHARACTER
    DATA Number_Card            AS CHARACTER
    DATA CNPJContr              AS CHARACTER
    DATA data_token             AS DATA
    DATA time_expire            AS NUMERIC
    DATA exibe_erro             AS LOGICAL
    DATA ContrPDG               AS LOGICAL
    
    DATA Drivr_Code             AS CHARACTER
    DATA Drivr_CPF              AS CHARACTER
    DATA Drivr_Name             AS CHARACTER
    DATA RNTRC                  AS CHARACTER
    DATA DrivrNmMthr            AS CHARACTER
    DATA DrivrDtBirth           AS DATA
    DATA drivrlogradouro        AS CHARACTER
    DATA drivrAddNum            AS CHARACTER
    DATA drivrComple            AS CHARACTER
    DATA drivrBairro            AS CHARACTER
    DATA drivrZipcode           AS CHARACTER
    DATA drivrIBGEcode          AS NUMERIC
    DATA drivrCity              AS CHARACTER
    DATA drivrState             AS CHARACTER
    DATA drivrKm                AS CHARACTER
    DATA drivrTelCode           AS NUMERIC
    DATA drivrTel               AS NUMERIC
    DATA drivrCelcode           AS NUMERIC
    DATA drivrCel               AS NUMERIC
    DATA drivr_Email            AS CHARACTER
    DATA drivr_RG               AS CHARACTER
    DATA drivr_UF               AS CHARACTER
    DATA drivrCNHCat            AS CHARACTER
    DATA drivrCNHNum            AS CHARACTER
    DATA DrivrForn              AS CHARACTER
    DATA DrivrLoja              AS CHARACTER
    DATA drivrCNHVal            AS DATA
    DATA DrivrHasCNH            AS LOGICAL
    DATA DrivrDateCad           AS DATA
    DATA DrivrCard              AS ARRAY
    
    DATA RouteName              AS CHARACTER
    DATA RouteOri               AS ARRAY
    DATA RouteDes               AS ARRAY
    DATA RoutePtos              AS ARRAY

    DATA VeicCGCDono            AS CHARACTER
    DATA VeicPlaca              AS CHARACTER
    DATA VeicQtdEixos           AS NUMERIC
    DATA VeicMarca              AS CHARACTER
    DATA VeicMod                AS CHARACTER
    DATA Veiccor                AS CHARACTER
    DATA VeicAnoFab             AS NUMERIC
    DATA VeicAnoMod             AS NUMERIC
    DATA VeicTipo               AS CHARACTER
    DATA VeicPIBGE              AS NUMERIC
    DATA VeicRenavam            AS CHARACTER
    DATA VeicChassis            AS CHARACTER
    DATA VeicTipEixo            AS CHARACTER

    DATA HiredCode              AS CHARACTER
    DATA HiredLoja              AS CHARACTER
    DATA HiredIE                AS CHARACTER
    DATA HiredCPF               AS CHARACTER
    DATA HiredName              AS CHARACTER
    DATA Hiredlogradouro        AS CHARACTER
    DATA HiredAddNum            AS CHARACTER
    DATA HiredComple            AS CHARACTER
    DATA HiredBairro            AS CHARACTER
    DATA HiredZipcode           AS CHARACTER
    DATA HiredCity              AS CHARACTER
    DATA HiredState             AS CHARACTER
    DATA HiredEmail             AS CHARACTER
    DATA HiredRG                AS CHARACTER
    DATA HiredUF                AS CHARACTER
    DATA HiredBanco             AS CHARACTER
    DATA HiredAgencia           AS CHARACTER
    DATA HiredAgDV              AS CHARACTER
    DATA HiredConta             AS CHARACTER
    DATA HiredConDV             AS CHARACTER
    DATA HiredTpCon             AS CHARACTER
    DATA HiredIBGEcode          AS NUMERIC
    DATA HiredTelCode           AS NUMERIC
    DATA HiredTel               AS NUMERIC
    DATA HiredCelcode           AS NUMERIC
    DATA HiredCel               AS NUMERIC
    DATA HiredHasRNT            AS Logical
    DATA HiredCard              AS ARRAY
    DATA aContComp              AS ARRAY 

    //Post Viagem
    DATA IdFrete                AS CHARACTER
    DATA IdPedagio              AS CHARACTER
    DATA VlrTotCon              AS NUMERIC
    DATA VlrBloq                AS NUMERIC
    DATA VlrLib                 AS NUMERIC
    DATA VlrCanPdg              AS NUMERIC
    DATA VlrAjust               AS NUMERIC 
    DATA SitFrete               AS CHARACTER
    DATA SitPedagio             AS CHARACTER
    DATA CIOT                   AS CHARACTER

    //CIOT Agregado
    DATA IdCiotAgre             AS NUMERIC
    DATA NumCiotAg              AS CHARACTER
    DATA DataCancel             AS DATA
    DATA DataEncerr             AS DATA
    DATA StatusCIOT             AS CHARACTER

    //Quitação
    DATA PesoTotalChegadaKg     AS NUMERIC
    
    //Delete Viagem
    DATA DelCancPdg             AS NUMERIC
    DATA DelCancFret            AS NUMERIC
    DATA DelTotPdg              AS NUMERIC
    DATA DelSaldoFre            AS NUMERIC
    DATA DelVlTotFret           AS NUMERIC

    DATA rest_client            AS OBJECT 
    DATA json_object            AS OBJECT 
    DATA error                  AS CHARACTER
    DATA error_description      AS CHARACTER
    DATA msg_description        AS CHARACTER 

    METHOD New()                Constructor
    METHOD PagBemInfo()
    METHOD NewDriver()
    METHOD NewLog()
    METHOD DriverInfo()
    METHOD NewVehicle()
    METHOD VehicleInfo()
    METHOD NewHired()
    METHOD NewRoute()
    METHOD HiredInfo()
    METHOD Post()
    METHOD Get()
    METHOD Put()
    METHOD Auth()
    METHOD GetToken()
    METHOD IsTokenActive()
    METHOD GetLastError()
    METHOD GetErrorDescription()
    METHOD GravaToken()
    METHOD GetDriver()
    METHOD PutDriver()
    METHOD GetCardSituation()
    METHOD PutCardLink()
    METHOD PutVehicle()
    METHOD GetVehicle()
    METHOD PutHired()
    METHOD GetHired()
    METHOD GetHiredRNTRC()
    METHOD GetToll()
    METHOD PutLibViagem()
    METHOD PutBlqViagem()
    METHOD PutUnlockVge()
    METHOD GetRoute()
    METHOD PostRoute()
    METHOD GetTravel()
    METHOD PostTravel()
    METHOD PostAjustFin()
    METHOD DelTravel()
    METHOD DelDeliver()
    METHOD PutQuitacao()
    METHOD Delete()
    METHOD Destroy()
    METHOD Log()
    METHOD GetRelFin()
	METHOD PutSitANTT()
    METHOD PostCiotA()
    METHOD DelCiotA()
    METHOD PutEnCiotA()

END CLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD New() CLASS TMSBCAPagBem

    If ::PagBemInfo()
        ::Instaciado := .T.
        ::NewLog()
        ::NewDriver()
        ::NewVehicle()
        ::NewHired()
		::NewRoute()
    Else
        ::Instaciado := .F.
    EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetLastError()

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetLastError() CLASS TMSBCAPagBem

Return ::last_error

//-----------------------------------------------------------------
/*/{Protheus.doc} GetErrorDescription()

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetErrorDescription() CLASS TMSBCAPagBem

Return ::error_description

//-----------------------------------------------------------------
/*/{Protheus.doc} Post()

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD Post( cPath, aHeaderStr, cParams ) CLASS TMSBCAPagBem

    Local lRet          := .F. 
    Local cResult       := ""

    Default cPath       := ""
    Default aHeaderStr  := {}
    Default cParams     := ""

    ::rest_client:SetPath( cPath )
    
    //-- Gera Log de envio
    ::Log(cParams,.F.)

    If !Empty(cParams)
        ::rest_client:SetPostParams( cParams )
    EndIf

    lRet    := ::rest_client:Post( aHeaderStr )

    If lRet 
        cResult := ::rest_client:GetResult()
    Else
        cResult := AllTrim( ::rest_client:GetLastError() )
    EndIf

    //-- Gera Log de Retorno
    ::Log(cResult,.T.)

    FwFreeArray(aHeaderStr)

Return { lRet, cResult }

//-----------------------------------------------------------------
/*/{Protheus.doc} Delete()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD Delete( cPath, aHeaderStr, cParams ) CLASS TMSBCAPagBem

    Local lRet          := .F. 
    Local cResult       := ""
    Local aRet          := {}

    Default cPath       := ""
    Default aHeaderStr  := {}
    Default cParams     := ""

    //-- Busca token no PagBem
    ::rest_client:SetPath( cPath )

    //-- Gera Log de envio
    ::Log(cParams,.F.)
    
    lRet := ::rest_client:Delete( aHeaderStr, cParams )

    If lRet
        cResult := ::rest_client:GetResult()
    Else
        cResult := AllTrim( ::rest_client:GetLastError() )
    EndIf

    //-- Gera Log de Retorno
    ::Log(cResult,.T.)

    aRet := { lRet, cResult }

    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GET()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD Get( cPath, aHeaderStr, cParams ) CLASS TMSBCAPagBem

    Local lRet          := .F. 
    Local cResult       := ""
    Local aRet          := {}

    Default cPath       := ""
    Default aHeaderStr  := {}
    Default cParams     := ""

    //-- Busca token no PagBem
    ::rest_client:SetPath( cPath )

    If !Empty(cParams)
        ::rest_client:SetGetParams( cParams )
    EndIf

    lRet := ::rest_client:Get( aHeaderStr )

    If lRet
        cResult := ::rest_client:GetResult()
    Else
        cResult := AllTrim( ::rest_client:GetLastError() )
    EndIf

    aRet := { lRet, cResult }

    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PUT()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD Put( cPath, aHeaderStr, cParams ) CLASS TMSBCAPagBem

    Local lRet          := .F. 
    Local cResult       := ""
    Local aRet          := {}

    Default cPath       := ""
    Default aHeaderStr  := {}
    Default cParams     := ""

    //-- Busca token no PagBem
    ::rest_client:SetPath( cPath )

    //-- Gera Log de envio
    ::Log(cParams,.F.)

    lRet := ::rest_client:Put( aHeaderStr, EncodeUTF8( cParams ) )

    If lRet
        cResult := ::rest_client:GetResult()
    Else
        cResult := AllTrim( ::rest_client:GetLastError() )
    EndIf
    //-- Gera Log de Retorno
    ::Log(cResult,.T.)

    aRet := { lRet, cResult }

    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PagBemInfo()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PagBemInfo() CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local aAreaDEG      := DEG->(GetArea())
    Local cCodOpe       := "03"
    Local lRet          := .F.
    Local lTabAtu       := FindFunction("TMSIntgPB") .AND. DEG->(FieldPos("DEG_TOKEN")) > 0

    DbSelectArea("DEG")
    DEG->( DbSetOrder(1) )

    If DEG->( DbSeek( xFilial("DEG") + cCodOpe ) ) .AND. lTabAtu
        ::url_token     := AllTrim(DEG->DEG_URLWS) //"https://homologacao.integracao.pagbem.com.br"
        ::grant_type    := "password"
        ::username      := AllTrim(DEG->DEG_USER)   //"53113791000122"
        ::password      := AllTrim(DEG->DEG_SENHA)  //"iF18pbnaaftTWwsO"
        ::CNPJContr     := AllTrim(DEG->DEG_IDOPE) //"53113791000122"
        ::last_error    := ""
        ::time_token    := DEG->DEG_HRTOKE
        ::exibe_erro    := !IsBlind()
        ::access_token  := AllTrim(DEG->DEG_TOKEN)  //""
        ::deg_codope    := cCodOpe                  //-- PAGBEM
        ::time_expire   := DEG->DEG_EXPIRE
        ::ContrPDG      := DEG->DEG_CONPDG == "1"  //"Gera contrato de Pedagio"
        lRet := .T.
    Else
        If !lTabAtu
            Help( "", 1, STR0002, , STR0018, 1, 0, , , , , , { STR0019 } ) // "O ambiente não está atualizado. Verificamos a falta dos campos DEG_TOKEN, DEG_HRTOKE, DEG_DTTOKE e DEG_EXPIRE." "Atualize o ambiente para que os novos campos da tabela Operadoras de Frota (DEG) sejam criados."
        EndIf
        ::url_token     := ""
        ::grant_type    := "password"
        ::username      := ""
        ::password      := ""
        ::CNPJContr     := ""
        ::last_error    := ""
        ::error_description := ""
        ::time_token    := ""
        ::exibe_erro    := !IsBlind()
        ::access_token  := ""
        ::deg_codope    := cCodOpe                  //-- PAGBEM
        ::time_expire   := ""
    EndIf

    RestArea( aAreaDEG )
    RestArea(aArea)

Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} NewLog()
Método para carregar os dados de Log

@author Daniel Leme
@since 09/03/2022
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewLog() CLASS TMSBCAPagBem
    ::IsLogActive := SuperGetMv("MV_TMSPBLG",,.T.) //-- Todo: verificar com o time DEG

    //Cria os diretórios caso não existam
    If ::IsLogActive
       // If IsSrvUnix()
       //    ::cPATHLOG    := "LOG_PAGBEM/"
       // Else
            ::cPATHLOG    := "LOG_PAGBEM\"
      //  EndIf

        If !ExistDir(::cPATHLOG)
            MakeDir(::cPATHLOG)
        EndIf
    EndIf

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} NewDriver()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewDriver() CLASS TMSBCAPagBem

    ::Drivr_Code        := ""
    ::Drivr_CPF         := ""
    ::Drivr_Name        := ""
    ::RNTRC             := ""
    ::DrivrNmMthr       := ""
    ::DrivrDtBirth      := "2021-12-09T20:33:49.004Z"

    ::drivrlogradouro   := ""
    ::drivrAddNum       := ""
    ::drivrComple       := ""
    ::drivrBairro       := ""
    ::drivrZipcode      := ""
    ::drivrIBGEcode     := 0
    ::drivrCity         := ""
    ::drivrState        := ""
    ::drivrKm           := ""

    ::drivrTelCode      := 0
    ::drivrTel          := 0

    ::drivrCelcode      := 0
    ::drivrCel          := 0

    ::Drivr_Email       := ""

    ::drivr_RG          := ""
    ::drivr_UF          := ""

    ::drivrCNHCat       := ""
    ::drivrCNHNum       := ""
    ::drivrCNHVal       := "2021-12-09T20:33:49.004Z"

    ::DrivrHasCNH       := .F.
    ::DrivrDateCad      := "2021-12-09T20:33:49.004Z"
    ::DrivrForn         := ""
    ::DrivrLoja         := ""
    ::DrivrCard         := {}

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} NewHired()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewHired() CLASS TMSBCAPagBem

    ::HiredCode         := ""
    ::HiredLoja         := ""
    ::HiredIE           := ""
    ::HiredCPF          := ""
    ::HiredName         := ""
    ::HiredEmail        := ""
    ::RNTRC             := ""
    ::HiredHasRNT       := .F.
    ::HiredCard         := {}
    ::Hiredlogradouro   := ""
    ::HiredAddNum       := ""
    ::HiredComple       := ""
    ::HiredBairro       := ""
    ::HiredZipcode      := ""
    ::HiredIBGEcode     := 0
    ::HiredCity         := ""
    ::HiredState        := ""
    ::HiredTelCode      := 0
    ::HiredTel          := 0
    ::HiredCelcode      := 0
    ::HiredCel          := 0
    ::HiredBanco        := ""
    ::HiredAgencia      := ""
    ::HiredAgDV         := ""
    ::HiredConta        := ""
    ::HiredConDV        := ""
    ::HiredTpCon        := ""
    ::aContComp         := {}

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} NewVehicle()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD NewVehicle() CLASS TMSBCAPagBem

    ::VeicPlaca     := ""//"string"
    ::RNTRC         := ""//"string"
    ::VeicQtdEixos  := 0
    ::VeicMarca     := ""//"string"
    ::VeicMod       := ""//"string"
    ::Veiccor       := ""//"Amarelo"
    ::VeicAnoFab    := 0
    ::VeicAnoMod    := 0
    ::VeicTipo      := ""//"Cavalo"
    ::VeicPIBGE     := 0
    ::VeicRenavam   := ""//"string"
    ::VeicChassis   := ""//"string"
    ::VeicTipEixo   := ""//"Simples"
    ::VeicCGCDono   := ""

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} NewRoute()
Método para carregar os dados de Rota

@author Daniel Leme
@since 09/02/2022
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD NewRoute() CLASS TMSBCAPagBem
    ::RouteName := ""             //-- CHARACTER
    ::RouteOri  := {}             //-- ARRAY
    ::RouteDes  := {}             //-- ARRAY
    ::RoutePtos := {}             //-- ARRAY
Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} HiredInfo()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD HiredInfo( cCodFor, cLoja ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local aAreaSA2      := SA2->(GetArea())
    Local lRet          := .F.

    DbSelectArea("SA2")
    SA2->( DbSetOrder(1) )
    // Caso o tranportador não possuir RNTRC, O campo RNTRC fica opcional caso informado: "possuiRNTRC": false,
    If SA2->( DbSeek( xFilial("SA2") + cCodFor + cLoja ) )
        ::HiredCode         := SA2->A2_COD
        ::HiredLoja         := SA2->A2_LOJA
        ::HiredIE           := AllTrim( SA2->A2_INSCR )
        ::HiredCPF          := AllTrim( SA2->A2_CGC )
        ::HiredName         := AllTrim( SA2->A2_NOME )
        ::HiredEmail        := AllTrim( SA2->A2_EMAIL )
        ::RNTRC             := AllTrim( SA2->A2_RNTRC )
        ::HiredHasRNT       := If( !Empty(::RNTRC), .T., .F. )
        ::HiredCard         := {}
        ::Hiredlogradouro   := AllTrim( SA2->A2_END )
        ::HiredAddNum       := "0"
        ::HiredComple       := AllTrim( SA2->A2_ENDCOMP )
        ::HiredBairro       := AllTrim( SA2->A2_BAIRRO )
        ::HiredZipcode      := AllTrim( SA2->A2_CEP )
        ::HiredIBGEcode     := Val( TMSUFToIBGE( SA2->A2_EST ) + RTrim( SA2->A2_COD_MUN ) )
        ::HiredCity         := AllTrim( SA2->A2_MUN )
        ::HiredState        := AllTrim( SA2->A2_EST )
        ::HiredTelCode      := Val( SA2->A2_DDD )
        ::HiredTel          := Val( SA2->A2_FAX )
        ::HiredCelcode      := Val( SA2->A2_DDD )
        ::HiredCel          := Val( SA2->A2_TEL )
        ::HiredBanco        := AllTrim(SA2->A2_BANCO)
        ::HiredAgencia      := AllTrim(SA2->A2_AGENCIA)
        ::HiredAgDV         := AllTrim(SA2->A2_DVAGE)
        ::HiredConta        := AllTrim(SA2->A2_NUMCON)
        ::HiredConDV        := AllTrim(SA2->A2_DVCTA)
        ::HiredTpCon        := If( SA2->A2_TPCONTA == '1', "Conta Corrente", "Poupanca" )
        lRet := .T.
    EndIf
    
    RestArea( aAreaSA2 )
    RestArea(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} VehicleInfo()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD VehicleInfo( cCodVei ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local aAreaDA3      := DA3->(GetArea())
    Local aAreaSA2      := SA2->(GetArea())
    Local aAreaDUT      := DUT->(GetArea())
    Local lRet          := .F.
    Local cTipEixos     := ""
    Local cCatVei       := ""
    Local cTipVei       := ""
    Local cCidPlaca     := ""
    Local lTabAtu       := FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

    DbSelectArea("DA3")
    DA3->( DbSetOrder(1) )

    If DA3->( DbSeek( xFilial("DA3") + cCodVei ) ) .AND. lTabAtu
        ::VeicPlaca     := AllTrim( StrTran( DA3->DA3_PLACA, "-", "" ) ) //"string"
        
        If !Empty(DA3->DA3_CODFOR) .AND. !Empty(DA3->DA3_LOJFOR)
            ::RNTRC         := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR, "A2_RNTRC"   ) )
            ::VeicCGCDono   := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR, "A2_CGC"     ) )
        EndIf

        ::VeicQtdEixos  := If( DA3->DA3_QTDEIX <= 2, 2, DA3->DA3_QTDEIX )//0
        ::VeicMarca     := RTrim( DA3->DA3_MARVEI ) //"string"
        ::VeicMod       := RTrim( DA3->DA3_DESC ) //"string"
        ::VeicCor       := RTrim( DA3->DA3_CORVEI ) //"Amarelo"
        ::VeicAnoFab    := Val( RTrim( DA3->DA3_ANOFAB ) ) //0
        ::VeicAnoMod    := Val( RTrim( DA3->DA3_ANOMOD ) ) //0
        
        cCatVei       := Posicione( "DUT", 1, xFilial("DUT") + DA3->DA3_TIPVEI,'DUT_CATVEI ') // ['Cavalo', 'Carreta', 'Carro', 'Moto']
        
        If cCatVei $ "1/5" // 1=Comum;2=Cavalo;3=Carreta;4=Especial;5=Utilitario;6=Composicao
            cTipVei := "Carro"
        ElseIf cCatVei == "2"
            cTipVei := "Cavalo"
        ElseIf cCatVei $ "3/4/6"
            cTipVei := "Carreta"
        EndIf

        ::VeicTipo      := cTipVei
        
        cCidPlaca       := DA3->DA3_CODMUN
        ::VeicPIBGE     := Val( TMSUFToIBGE( DA3->DA3_ESTPLA ) + cCidPlaca ) //0
        ::VeicRenavam   := RTrim( DA3->DA3_RENAVA ) //"string"
        ::VeicChassis   := RTrim( DA3->DA3_CHASSI ) //"string"

        //1=Eixo Simples/Rodagem Simples;2=Eixo Simples/Rodagem Dupla;3=Eixo Duplo/Tandem;4=Eixo Duplo/Não em Tandem;5=Eixo Triplo
        If DA3->DA3_RODAGE == "1"
            cTipEixos := "Simples"
        ElseIf DA3->DA3_RODAGE == "2"
            cTipEixos := "Duplo"
        ElseIf DA3->DA3_RODAGE == "3" .OR. DA3->DA3_RODAGE == "4"
            cTipEixos := "Duplo"
        ElseIf DA3->DA3_RODAGE == "5"
            cTipEixos := "Triplo"
        EndIf

        ::VeicTipEixo   := cTipEixos //"Simples"
        lRet := .T.
    Else
        If !lTabAtu
            Help( "", 1, STR0002, , STR0014 , 1, 0, , , , , , { STR0015 } ) // "O ambiente não está atualizado. Verificamos a falta dos campos DA3_CODMUN, DA3_RODAGE, DA3_INTOPE e DA3_INTEGR." "Atualize o ambiente para que os novos campos da tabela Veiculos (DA3) sejam criados."
        EndIf
        ::VeicPlaca     := ""//"string"
        ::RNTRC         := ""//"string"
        ::VeicQtdEixos  := 0
        ::VeicMarca     := ""//"string"
        ::VeicMod       := ""//"string"
        ::VeicCor       := ""//"Amarelo"
        ::VeicAnoFab    := 0
        ::VeicAnoMod    := 0
        ::VeicTipo      := ""//"Cavalo"
        ::VeicPIBGE     := 0
        ::VeicRenavam   := ""//"string"
        ::VeicChassis   := ""//"string"
        ::VeicTipEixo   := ""//"Simples"
        ::VeicCGCDono   := ""
    EndIf
    
    RestArea( aAreaDUT )
    RestArea( aAreaSA2 )
    RestArea( aAreaDA3 )
    RestArea(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DriverInfo()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD DriverInfo( cCodMot ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local aAreaDA4      := DA4->(GetArea())
    Local aAreaSA2      := SA2->(GetArea())
    Local cTel
    Local aDataUTC      := {}
    Local lRet          := .F.

    DbSelectArea("DA4")
    DA4->( DbSetOrder(1) )

    If DA4->( DbSeek( xFilial("DA4") + cCodMot ) )
        ::Drivr_Code        := cCodMot
        ::Drivr_CPF         := RTrim( DA4->DA4_CGC )
        ::Drivr_Name        := RTrim( DA4->DA4_NOME )
        ::RNTRC             := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA4->DA4_FORNEC + DA4->DA4_LOJA, "A2_RNTRC"    ) )
        ::DrivrNmMthr       := RTrim( DA4->DA4_MAE )
        ::DrivrForn         := DA4->DA4_FORNEC
        ::DrivrLoja         := DA4->DA4_LOJA

        aDataUTC            := LocalToUTC( DToS( DA4->DA4_DATNAS ), "12:00:00" )
        ::DrivrDtBirth      := SubStr( aDataUTC[1], 1, 4 ) + "-" + SubStr( aDataUTC[1], 5, 2 ) + "-" + SubStr( aDataUTC[1], 7, 2 ) + "T" + aDataUTC[2] + ".000Z" // "2021-12-09T20:33:49.004Z"
        aDataUTC            := Nil

        ::drivrlogradouro   := RTrim( DA4->DA4_END )
        ::drivrAddNum       := "0"              // Não possuimos campo separar
        ::drivrComple       := ""
        ::drivrBairro       := RTrim( DA4->DA4_BAIRRO )
        ::drivrZipcode      := RTrim( DA4->DA4_CEP )
        
        ::drivrIBGEcode     := Val( TMSUFToIBGE( DA4->DA4_EST ) + RTrim( DA4->DA4_CODMUN ) )
        
        ::drivrCity         := RTrim( DA4->DA4_MUN )
        ::drivrState        := RTrim( DA4->DA4_EST )
        ::drivrKm           := "" //

        ::drivrTelCode      := If( Empty( DA4->DA4_DDD ), 11, Val( RTrim( StrTran( DA4->DA4_DDD, "-", "" ) ) ) ) //0

        cTel                := If( Empty( AllTrim( DA4->DA4_TEL ) ), "12345678", AllTrim( StrTran( DA4->DA4_TEL, "-", "" ) ) )
        
        If Len( cTel ) == 8
            ::drivrTel      := Val( cTel )
        ElseIf Len( cTel ) == 9
            ::drivrCel      := Val( cTel )
            ::drivrCelCode  := ::drivrTelCode
        ElseIf Len( cTel ) > 9
            ::drivrCel      := Val( SubStr( cTel, ( Len( cTel ) - 9) + 1, Len( cTel ) ) )
            ::drivrCelCode  := ::drivrTelCode
        EndIf        

        ::Drivr_Email       := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA4->DA4_FORNEC + DA4->DA4_LOJA, "A2_EMAIL"    ) )

        ::drivr_RG          := RTrim( DA4->DA4_RG )
        ::drivr_UF          := RTrim( DA4->DA4_RGEST )

        ::drivrCNHCat       := RTrim( DA4->DA4_CATCNH )
        ::drivrCNHNum       := RTrim( DA4->DA4_NUMCNH )

        aDataUTC            := LocalToUTC( DToS( DA4->DA4_DTVCNH ), "12:00:00" )
        ::drivrCNHVal       := SubStr( aDataUTC[1], 1, 4 ) + "-" + SubStr( aDataUTC[1], 5, 2 ) + "-" + SubStr( aDataUTC[1], 7, 2 ) + "T" + aDataUTC[2] + ".000Z" // "2021-12-09T20:33:49.004Z"
        aDataUTC            := Nil

        ::DrivrHasCNH       := .T.

        aDataUTC            := LocalToUTC( DToS( DA4->DA4_DATNAS ), "12:00:00" )
        ::DrivrDateCad      := SubStr( aDataUTC[1], 1, 4 ) + "-" + SubStr( aDataUTC[1], 5, 2 ) + "-" + SubStr( aDataUTC[1], 7, 2 ) + "T" + aDataUTC[2] + ".000Z" // "2021-12-09T20:33:49.004Z"
        aDataUTC            := Nil

        ::DrivrCard         := RetCardMot(cCodMot)
        
        lRet := .T. 
    EndIf
    
    RestArea( aAreaSA2 )
    RestArea( aAreaDA4 )
    RestArea(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} Auth()

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD Auth() CLASS TMSBCAPagBem

    Local lRet          := .F. 
    Local aHeaderStr    := {} 
    Local cResult       := ""
    Local cParams       := ""
    Local oResult       := Nil 
    Local aTokActive    := {} 
    Local lTokActive    := .F. 

    Default cUrlToken   := ""
    Default cUser       := ""
    Default cPassword   := ""

    cParams := "grant_type=" + ::grant_type
    cParams += "&password=" + ::password
    cParams += "&username=" + Lower( ::username )
    
    ::rest_client   := FwRest():New( ::url_token )

    Aadd( aHeaderStr, "Content-Type: application/x-www-form-urlencoded" )

    //-- Busca token ativo
    aTokActive  := ::IsTokenActive()

    If Len( aTokActive ) > 0 
        lRet            := .T. 
        lTokActive      := aTokActive[1]
        ::access_token  := aTokActive[2]
    EndIf

    //-- Busca token no PagBem
    If !lTokActive

        ::rest_client:SetPath( "/token" )
        ::rest_client:SetPostParams( EncodeUTF8(cParams) )

        ::data_token    := dDataBase
        ::time_token    := Time()

        lRet    := ::rest_client:Post( aHeaderStr )

        If lRet
            cResult     := ::rest_client:GetResult()
            
            If FWJsonDeserialize( cResult, @oResult )
                If AttIsMemberOf( oResult, "access_token" )

                    ::access_token  := oResult:access_token
                    
                    //-- Tempo de expiração
                    If AttIsMemberOf( oResult, "expires_in" )
                        ::time_expire := oResult:expires_in
                        ::GravaToken()
                    EndIf
                
                EndIf
            EndIf

        Else
            ::last_error    := AllTrim( ::rest_client:GetLastError() )
			::error_description := "authentication error"
            cResult         := ::rest_client:GetResult()
        EndIf
    EndIf

    //-- Limpa cache de 
    FwFreeArray(aTokActive)
    FwFreeArray(aHeaderStr)
    FwFreeObj(oResult)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetToken()

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetToken() CLASS TMSBCAPagBem

    Local lRet          := .F.
    Local aTokActive    := {} 
    Local lTokActive    := .F. 

    Default cUrlToken   := ""
    Default cUser       := ""
    Default cPassword   := ""

    //-- Busca token ativo
    aTokActive  := ::IsTokenActive()

    If Len( aTokActive ) > 0 
        lRet            := .T. 
        lTokActive      := aTokActive[1]
        ::access_token  := aTokActive[2]
    EndIf

    //-- Limpa cache de 
    FwFreeArray(aTokActive)

Return ::access_token

//-----------------------------------------------------------------
/*/{Protheus.doc} IsTokenActive()

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD IsTokenActive() CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local cQuery        := ""
    Local cAliasQry     := GetNextAlias()
    Local cToken        := ""
    Local lRet          := .F. 
    Local dDtToken      := CToD("")
    Local cHrToken      := ""
    Local nExpire       := 0     
    Local cHour         := ""
    Local cMin          := ""
    Local cSecs         := ""
    Local cTime         := ""
    Local nSecs         := 0 

    Default cSequen     := ""

    cQuery := QryToken()

    DbUseArea( .T., 'TOPCONN', TCGENQRY( , , cQuery ), cAliasQry, .F., .T. )

    If (cAliasQry)->( !Eof() )
        
        dDtToken    := SToD( (cAliasQry)->DEG_DTTOKE )
        cHrToken    := (cAliasQry)->DEG_HRTOKE
        nExpire     := (cAliasQry)->DEG_EXPIRE

        If dDataBase == dDtToken
            
            cTime   := ElapTime(cHrToken,Time())
            cHour   := SubStr( cTime, 1, 2 ) // Resultado: 10
            cMin    := SubStr( cTime, 4, 2 ) // Resultado: 37
            cSecs   := SubStr( cTime, 7, 2 ) // Resultado: 17
            
            nSecs   := Val(cSecs) + ( Val( cMin ) * 60 ) + ( Hrs2Min(cHour) * 60 ) 

            If nExpire > nSecs
                lRet    := .T. 
                DEG->( DbGoTo( (cAliasQry)->RECNODEG ) )
                cToken          := DEG->DEG_TOKEN
                ::access_token  := cToken
                ::time_token    := cHrToken
                ::data_token    := dDtToken
                ::time_expire   := nExpire
            EndIf
        EndIf

    EndIf

    (cAliasQry)->( DbCloseArea() )

    RestArea( aArea )

Return { lRet , cToken }

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriver()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetDriver( cCGCMot ) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local cParams   := ""
    Local oResponse := Nil
    Local cPath     := "/api/motoristas/"
    Local cPath2    := "/dados"
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""

    Default cCGCMot         := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )

    If !Empty( cCGCMot )
        cPath := cPath + AllTrim( cCGCMot ) + cPath2
    EndIf

    aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"

            If oResponse:IsSucesso
                // Achei o motorista
                aRet := { oResponse:IsSucesso, "CPF", "" }
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutDriver()
Método para inclusão de motoristas na PAGBEM.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PutDriver( lAltCad ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local lRet          := .F.
    Local aRet          := {}
    Local aRetorno      := {}
    Local aHeaderStr    := {}
    Local oResponse     := Nil
    Local oBody         := JsonObject():New()
    Local oAddress      := JsonObject():New()
    Local oPhones1      := JsonObject():New()
    Local oCelPhones    := JsonObject():New()
    Local oRG           := JsonObject():New()
    Local oCNH          := JsonObject():New()
    Local cPath         := "/api/motoristas/"
    Local cPath2        := "/atualizar"
    Local cBody         := ""
    Local nX            := 0
    Local nLenCard      := 0
    Local aCard         := {}
    Local nErros        := 0
    Local cMsg          := ""

    Default lAltCad     := .F. // Altera ou Inclui

    ::rest_client   := FwRest():New( ::url_token )

	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    If lAltCad
        cPath := cPath + ::Drivr_CPF + cPath2
    Else
        cPath := cPath + ::Drivr_CPF
    EndIf

    oBody["CPF"]            := ::Drivr_CPF
    oBody["nome"]           := ::Drivr_Name
    oBody["RNTRC"]          := ""//::RNTRC
    oBody["nomeMae"]        := ::DrivrNmMthr
    oBody["dataNascimento"] := ::DrivrDtBirth

    oAddress["logradouro"]  := ::drivrlogradouro
    oAddress["numero"]      := ::drivrAddNum
    oAddress["complemento"] := ::drivrComple
    oAddress["bairro"]      := ::drivrBairro
    oAddress["CEP"]         := ::drivrZipcode
    oAddress["codigoIBGE"]  := ::drivrIBGEcode
    oAddress["municipio"]   := ::drivrCity
    oAddress["UF"]          := ::drivrState
    oAddress["KM"]          := ::drivrKm

    oBody["Endereco"]       := oAddress

    If ::drivrTel > 0
        oPhones1["DDD"]         := ::drivrTelCode
        oPhones1["numero"]      := ::drivrTel
        
        oBody["telefone1"]      := oPhones1//aClone( aPhone1 )
    EndIf

    If ::drivrCel > 0
        oCelPhones["numero"]    := ::drivrCel
        oCelPhones["DDD"]       := ::drivrCelcode

        oBody["telefoneCelular"]:= oCelPhones//aClone( aCelPhones )
    EndIf

    oBody["email"]          := ::Drivr_Email

    oRG["numero"]           := ::drivr_RG
    oRG["UF"]               := ::drivr_UF

    oBody["RG"]             := oRG

    oCNH["categoria"]       := ::drivrCNHCat
    oCNH["numero"]          := ::drivrCNHNum
    oCNH["validade"]        := ::drivrCNHVal

    oBody["CNH"]            := oCNH
    
    oBody["possuiCNH"]      := ::DrivrHasCNH
    oBody["dataCadastro"]   := ::DrivrDateCad

    cBody   := oBody:ToJson()

    aRetorno    := ::Put( cPath, aHeaderStr, cBody )
    
    If aRetorno[1]
        
        lRet    := FWJsonDeserialize( aRetorno[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                // Achei o numero do cartão
                nLenCard := Len(oResponse:resultado:Cartoes)
                /*
                    "cartoes": [
                                {
                                    "numeroCartao": "string",
                                    "produtoCartao": "string",
                                    "nomePortadorCartao": "string"
                                }
                */
                If nLenCard > 0

                    For nX := 1 To nLenCard
                        AAdd( aCard, { oResponse:resultado:Cartoes[nLenCard]:numeroCartao, oResponse:resultado:Cartoes[nLenCard]:produtoCartao } )
                    Next nX

                    aRet := { oResponse:IsSucesso, AClone( aCard ), "" }
                Else
                    aRet := { oResponse:IsSucesso, AClone( aCard ), STR0001 } //STR0001 "Sem Cartões vinculados ao Motorista."
                EndIf
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aRetorno[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
    
    RestArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetCardSituation()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetCardSituation( cCard, cCnpjContrat ) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local cParams   := ""
    Local oResponse := Nil
    Local cPath     :=  "/api/cartoes/"
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""

    Default cCard           := ""
    Default cCnpjContrat    := ""

    ::Number_Card       := RTrim( cCard )

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )

    If !Empty( cCard )
        cPath := cPath + AllTrim( cCard )
    EndIf

    aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                // Achei o numero do cartão
                If !(oResponse:resultado:IsCartaoAtivo)

                    If Upper(oResponse:resultado:SituacaoCartao) = "NAOVINCULADO"
                        aRet := { oResponse:resultado:IsCartaoAtivo, "4", "" }
                    ElseIf Upper(oResponse:resultado:SituacaoCartao) = "BLOQUEADO"
                        aRet := { oResponse:resultado:IsCartaoAtivo, "2", "" }
                    ElseIf Upper(oResponse:resultado:SituacaoCartao) = "CANCELADO"
                        aRet := { oResponse:resultado:IsCartaoAtivo, "3", "" }
                    EndIf

                Else
                    If Upper(oResponse:resultado:SituacaoCartao) = "ATIVO"
                        aRet := { oResponse:resultado:IsCartaoAtivo, "1", "" }
                    EndIf
                EndIf
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutCardLink()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

Method PutCardLink( cCardNumber ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local lRet          := .F.
    Local aRet          := {}
    Local aResult       := {}
    Local aRetorno      := {}
    Local aHeaderStr    := {}
    Local oResponse     := Nil
    Local oBody         := JsonObject():New()
    Local oRespCard     := JsonObject():New()
    Local oTelefone     := JsonObject():New()
    Local cPath         := "/api/cartoes"
    Local cBody         := ""
    Local nErros        := 0
    Local nX            := 0
    Local cMsg          := ""

    Default lAltCad     := .F. // Altera ou Inclui
    Default cCardNumber := ""

    ::rest_client   := FwRest():New( ::url_token )

	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    /* {
            "numeroCartaoPagBem": "string",
            "CNPJCPFPortador": "string",
            "responsavelCartao": {
                                "telefone": {
                                                "numero": 0,
                                                "DDD": 0
                                            },
                                "CPF": "string",
                                "nome": "string"
                                }
        }*/

    oBody["numeroCartaoPagBem"]     := cCardNumber
    
    If Len(::Drivr_CPF) == 11
        oBody["CNPJCPFPortador"]        := ::Drivr_CPF
    EndIf

    cBody   := oBody:ToJson()

    aRetorno    := ::Put( cPath, aHeaderStr, cBody )
    
    If aRetorno[1]
        
        lRet    := FWJsonDeserialize( aRetorno[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O" //AttIsMemberOf( < oObj >, < cAttName >, [ lRecursive ] )
            If oResponse:IsSucesso

                aRet := { oResponse:IsSucesso, AClone( aResult ), "" }

            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aRetorno[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
    
    RestArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetVeiculo()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetVehicle() CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local cParams   := ""
    Local oResponse := Nil
    Local cPath     := "/api/veiculos/"
    Local aRet      := { .F., "", "" }
    Local aDados    := {}
    Local cPlaca    := ""
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local aResult   := {}
    
    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )

    cPlaca    := ::VeicPlaca

    If !Empty( cPlaca )
        cPath := cPath + AllTrim( cPlaca )
    EndIf

    aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                // Achei o numero do cartão
                If AttIsMemberOf( oResponse, "Resultado" )

                    AAdd( aDados, oResponse:Resultado:CNPJCPF       )
                    AAdd( aDados, oResponse:Resultado:Placa         )
                    AAdd( aDados, oResponse:Resultado:TipoVeiculo   )
                    
                    If UPPER(oResponse:Resultado:TipoVeiculo) == "CAVALO"
                        AAdd( aDados, oResponse:Resultado:RNTRC     )
                    EndIf

                    aRet := { oResponse:IsSucesso, AClone(aDados), "" }
                Else
                    aRet := IiF(IsInCallStack("VldVeiPgBE"), {.F., {},""}, { oResponse:IsSucesso, {}, "" })
                EndIf
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
    
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutVehicle()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PutVehicle(cPlaca) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local oBody     := JsonObject():New()
    Local cPath     := "/api/veiculos/"
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""

    Default cPlaca  := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    If Empty( cPlaca )
        cPlaca := AllTrim( ::VeicPlaca )
    EndIf

    cPath := cPath + cPlaca
/*    {
    "placa": "string",
    "RNTRC": "string",
    "eixos": 0,
    "marca": "string",
    "modelo": "string",
    "cor": "Amarelo",
    "anoFabricacao": 0,
    "anoModelo": 0,
    "tipoVeiculo": "Cavalo",
    "placaCodigoIBGE": 0,
    "renavam": "string",
    "chassis": "string",
    "tipoEixo": "Simples"
    }*/

    oBody["placa"]              := ::VeicPlaca
    oBody["RNTRC"]              := ::RNTRC
    oBody["eixos"]              := ::VeicQtdEixos
    oBody["marca"]              := ::VeicMarca
    oBody["modelo"]             := ::VeicMod
    oBody["cor"]                := ::Veiccor
    oBody["anoFabricacao"]      := ::VeicAnoFab
    oBody["anoModelo"]          := ::VeicAnoMod
    oBody["tipoVeiculo"]        := ::VeicTipo
    oBody["placaCodigoIBGE"]    := ::VeicPIBGE
    oBody["renavam"]            := ::VeicRenavam
    oBody["chassis"]            := ::VeicChassis
    oBody["tipoEixo"]           := ::VeicTipEixo

    cBody   := oBody:ToJson()

    aResult := ::Put( cPath, AClone( aHeaderStr ), cBody )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                aRet := { oResponse:IsSucesso, "Incluido com sucesso.", "" }
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutHired()
Incluir ou alterar dados dos Fornecedores (hired)

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PutHired( lAltCad ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local lRet          := .F.
    Local aRet          := {}
    Local aRetorno      := {}
    Local aHeaderStr    := {}
    Local oResponse     := Nil
    Local oBody         := JsonObject():New()
    Local oAddress      := JsonObject():New()
    Local oPhones1      := JsonObject():New()
    Local oCelPhones    := JsonObject():New()
    Local oBanco        := JsonObject():New()
    Local cPath         := "/api/contratados/"
    Local cPath2        := "/atualizar"
    Local cBody         := ""
    Local nX            := 0
    Local nLenCard      := 0
    Local aCard         := {}
    Local nErros        := 0
    Local cMsg          := ""

    Default lAltCad     := .F. // Altera ou Inclui

    ::rest_client   := FwRest():New( ::url_token )

	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    If lAltCad
        cPath := cPath + ::HiredCPF + cPath2
    Else
        cPath := cPath + ::HiredCPF
    EndIf

    If !Empty(::HiredIE)
        oBody["IE"]             := ::HiredIE
    EndIf 
    If !Empty(::HiredEmail) 
         oBody["email"]          := ::HiredEmail
    EndIf   
   
    oBody["CNPJCPF"]        := ::HiredCPF
    oBody["nome"]           := ::HiredName
    oBody["RNTRC"]          := ::RNTRC
    oBody["possuiRNTRC"]    := ::HiredHasRNT

    oAddress["logradouro"]  := ::Hiredlogradouro
    oAddress["numero"]      := ::HiredAddNum
    If !Empty(::HiredComple)
        oAddress["complemento"] := ::HiredComple
    EndIf 
    oAddress["bairro"]      := ::HiredBairro
    oAddress["CEP"]         := ::HiredZipcode
    oAddress["codigoIBGE"]  := ::HiredIBGEcode
    oAddress["municipio"]   := ::HiredCity
    oAddress["UF"]          := ::HiredState

    oBody["Endereco"]       := oAddress

    If ::HiredTel > 0
        oPhones1["DDD"]         := ::HiredTelCode
        oPhones1["numero"]      := ::HiredTel
        
        oBody["telefone1"]      := oPhones1//aClone( aPhone1 )
    EndIf

    If ::HiredCel > 0
        oCelPhones["numero"]    := ::HiredCel
        oCelPhones["DDD"]       := ::HiredCelcode

        oBody["telefoneCelular"]:= oCelPhones//aClone( aCelPhones )
    EndIf
    If !Empty( ::HiredBanco )
        oBanco["codigoBanco"]   := ::HiredBanco
        oBanco["agencia"]       := ::HiredAgencia
        oBanco["agenciaDV"]     := ::HiredAgDV
        oBanco["conta"]         := ::HiredConta
        oBanco["contaDV"]       := ::HiredConDV
        oBanco["tipoConta"]     := ::HiredTpCon

        oBody["dadosBancarios"]         := oBanco
    EndIf
    cBody   := oBody:ToJson()

    aRetorno    := ::Put( cPath, aHeaderStr, FwCutOff(cBody,.T.) )
    
    If aRetorno[1]
        
        lRet    := FWJsonDeserialize( aRetorno[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                // Achei o numero do cartão
                nLenCard := Len(oResponse:resultado:Cartoes)
                /*
                    "cartoes": [
                                {
                                    "numeroCartao": "string",
                                    "produtoCartao": "string",
                                    "nomePortadorCartao": "string"
                                }
                */
                If nLenCard > 0

                    For nX := 1 To nLenCard
                        AAdd( aCard, { oResponse:resultado:Cartoes[nLenCard]:numeroCartao, oResponse:resultado:Cartoes[nLenCard]:produtoCartao } )
                    Next nX

                    aRet := { oResponse:IsSucesso, AClone( aCard ), "" }
                Else
                    aRet := { oResponse:IsSucesso, AClone( aCard ), STR0001 } //STR0001 "Sem Cartões vinculados ao Motorista."
                EndIf
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aRetorno[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
    
    RestArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetHired()
Verificar pelo CPF ou CNPJ se o fornecedor está cadastrado no PagBem

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetHired( cCGC ) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local cParams   := ""
    Local oResponse := Nil
    Local cPath     := "/api/contratados/"
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local nLenCard  := 0
    Local cMsg      := ""
    Local aDados    := {}
    Local aResult   := {}

    Default cCGC    := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )

    If Empty( cCGC )
        cCGC := ::HiredCPF
    EndIf

    cPath := cPath + AllTrim( cCGC )

    aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                If AttIsMemberOf( oResponse, "Resultado" )
                    If AttIsMemberOf( oResponse:Resultado, "CNPJCPF" )
                        AAdd( aDados, oResponse:Resultado:CNPJCPF )
                    EndIf

                    If AttIsMemberOf( oResponse:Resultado, "Cartoes" )
                        
                        nLenCard := Len(oResponse:resultado:Cartoes)
                        /*
                            "cartoes": [
                                        {
                                            "numeroCartao": "string",
                                            "produtoCartao": "string",
                                            "nomePortadorCartao": "string"
                                        }
                        */
                        If nLenCard > 0
                            For nX := 1 To nLenCard
                                AAdd( aDados, { oResponse:resultado:Cartoes[nLenCard]:NomePortadorCartao, oResponse:resultado:Cartoes[nLenCard]:numeroCartao, oResponse:resultado:Cartoes[nLenCard]:produtoCartao } )
                            Next nX
                        EndIf
                    EndIf
                    
                    aRet := { oResponse:IsSucesso, { AClone(aDados) }, "" }
                EndIf
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
    
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetHiredRNTRC()


@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetHiredRNTRC( cRNTRC ) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local cParams   := ""
    Local oResponse := Nil
    Local cPath     := "/api/contratados/rntrc/"
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local aDados    := {}
    Local aResult   := {}

    Default cRNTRC  := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )

    If Empty( cRNTRC )
        cRNTRC := ::RNTRC
    EndIf

    cPath := cPath + AllTrim( cRNTRC )

    aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                If AttIsMemberOf( oResponse, "Resultado" )
                    If AttIsMemberOf( oResponse:Resultado, "CNPJCPF" )
                        AAdd( aDados, oResponse:Resultado:CNPJCPF )
                    EndIf

                    If AttIsMemberOf( oResponse:Resultado, "Cartoes" )
                        
                        nLenCard := Len(oResponse:resultado:Cartoes)
                        /*
                            "cartoes": [
                                        {
                                            "numeroCartao": "string",
                                            "produtoCartao": "string",
                                            "nomePortadorCartao": "string"
                                        }
                        */
                        If nLenCard > 0
                            For nX := 1 To nLenCard
                                AAdd( aDados, { oResponse:resultado:Cartoes[nLenCard]:NomePortadorCartao, oResponse:resultado:Cartoes[nLenCard]:numeroCartao, oResponse:resultado:Cartoes[nLenCard]:produtoCartao } )
                            Next nX
                        EndIf
                    EndIf
                    
                    aRet := { oResponse:IsSucesso, { AClone(aDados) }, "" }
                EndIf
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
    
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PostTravel()
Inclui a viagem após o fechamento no sistema pagbem

@author Rodrigo Pirolo
@since 21/01/2022
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PostTravel( lFrete, cCodReg, cItemDTR, lCiotAgre, cCiotAgreg, nQtdTar, nVlrTar ) CLASS TMSBCAPagBem

    Local aAreaSA2      := SA2->( GetArea() )
    Local aAreaDTQ      := DTQ->( GetArea() )
    Local aAreaDTR      := DTR->( GetArea() )
    Local aAreaDT6      := DT6->( GetArea() )
    Local aAreaDTC      := DTC->( GetArea() )
    Local aAreaDTY      := DTY->( GetArea() )
    Local aAreaDA8      := DA8->( GetArea() )
    Local aAreaDMZ      := DMZ->( GetArea() )
    Local aAreaSM0		:= SM0->( GetArea() )
    Local aAreaDEK      := DEK->( GetArea() )
    Local aAreaDT5		:= DT5->( GetArea() )
    Local aAreaDUE      := DUE->( GetArea() )
    Local aAreaDUM      := DUM->( GetArea() )
    Local oResponse     := Nil
    Local oBody         := JsonObject():New()
    Local oTarifa       := JsonObject():New()
    Local oFrete        := JsonObject():New()
    Local oValeCombust  := JsonObject():New()
    Local oDoc          := JsonObject():New()
    Local oDocsViagem   := JsonObject():New()
    Local oCargas       := JsonObject():New()
    Local oNfes         := JsonObject():New()
    Local oDocs         := JsonObject():New()
    Local oDadosBanco   := JsonObject():New()
    Local oContratado   := JsonObject():New()
    Local oCNH          := JsonObject():New()
    Local oMotorista    := JsonObject():New()
    Local oEndRemet     := JsonObject():New()
    Local oOrigem       := JsonObject():New()
    Local oEndDest      := JsonObject():New()
    Local oDestino      := JsonObject():New()
    Local oPeriVia      := JsonObject():New()
    Local oRotas        := JsonObject():New()
    Local oRota         := JsonObject():New()
    Local oCarga        := JsonObject():New()
    Local oCavalo       := JsonObject():New()
    Local oCarretas     := JsonObject():New()
    Local oVeiculos     := JsonObject():New()
    Local oFreQuiReg    := JsonObject():New()
    Local oInfObrig     := JsonObject():New()
    Local oAdianta      := JsonObject():New()
    Local oMoto         := JsonObject():New()
    Local oContr        := JsonObject():New()
    Local oParti        := JsonObject():New()
    Local oPagFrete     := JsonObject():New()
    Local nQtdEixo      := 0
    Local nValPdg       := 0
    Local nPesCob       := 0
    Local nValNf        := 0
    Local nValSeg       := 0
    Local nNota         := 0
    Local nErros        := 0
    Local nX            := 0
    Local nValAdi       := 0
    Local nValFre       := 0
    Local nVlrQui       := 0
    Local nValInss      := 0
    Local nValPis       := 0
    Local nValCof       := 0
    Local nValCsl       := 0
    Local nValIr        := 0
    Local nValSest      := 0
    Local nValIss       := 0
    Local nVlrPdg       := 0
    Local cRNTRC        := ""
    Local cStrDTR       := ""
    Local cMsg          := ""
    Local cHora         := ""
    Local cLocAdi       := ""
    Local cLocQuiFre    := ""
    Local cCobQueb      := ""
    Local cPesUtili     := ""
    Local cTipVei       := ""
    Local cNCM          := ""
    Local cTipEixos     := ""
    Local cCliRem       := ""
    Local cLojRem       := ""
    Local cCliDes       := ""
    Local cLojDes       := ""
    Local cDUMStr       := ""
    Local cPath         := "/api/viagens/"
    Local lDMZPosi      := .F.
    Local lRet          := .T.
    Local aNCM          := {}
    Local aDocViagem    := {}
    Local aNfes         := {}
    Local aHeaderStr    := {}
    Local aDados        := {}
    Local aResult       := {}
    Local aRegra        := {}
    Local aDT6          := {}
    Local aAdian        := {}
    Local aRotas        := {}
    Local aFornec       := {}
    Local aCarretas     := {}
    Local aCards        := {}
    Local aContrat      := {}
    Local aRet          := {}
    Local aSM0Dados     := {}
    Local aFieldSM0     := {    "M0_ENDENT" ,;  //Posição [1]
                                "M0_ESTENT" ,;  //Posição [2]
                                "M0_CODMUN" ,;  //Posição [3]
                                "M0_NOME"   ,;  //Posição [4]
                                "M0_CGC"    ,;  //Posição [5]
                                "M0_BAIRENT",;  //Posição [6]
                                "M0_CEPENT" }   //Posição [7]

    Default lFrete      := .T.
    Default cCodReg     := ""
    Default cItemDTR    := ""
    Default lCiotAgre   := .F.
    Default cCiotAgreg  := ""
    Default nQtdTar     := 0
    Default nVlrTar     := 0

    aSM0Dados := FWSM0Util():GetSM0Data( , DTQ->DTQ_FILORI, aFieldSM0 )

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    cStrDTR := xFilial("DTR") + DTQ->( DTQ_FILORI + DTQ_VIAGEM ) + cItemDTR
    

    If !Empty( cCodReg )
        DbSelectArea("DMZ")
        DMZ->( DbSetOrder(1) )
        If DMZ->( DbSeek( xFilial("DMZ") + cCodReg ) )
            lDMZPosi := .T.
        EndIf
    EndIf

    //Inicio Documento da Viagem
        If DTQ->DTQ_TIPVIA != "2"
            DUD->( DbSetOrder( 2 ) )
            If DUD->( DbSeek( cStrDUD := xFilial("DUD") + DTQ->( DTQ_FILORI + DTQ_VIAGEM ) ) )
                
                nReg    := 0
                nPesCob := 0
                nValNf  := 0
                nValSeg := 0
                aDT6    := {}

                While DUD->( !Eof() ) .And. DUD->( DUD_FILIAL + DUD_FILORI + DUD_VIAGEM ) == cStrDUD
                    
                    DT6->( DbSetOrder( 1 ) )
                    If DT6->( DbSeek( xFilial("DT6") + DUD->( DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE ) ) )
                        
                        If AllTrim( DT6->DT6_SERIE ) == "COL"
                            If Empty(DT6->DT6_CLIREM) .AND. Empty(DT6->DT6_LOJREM)
                                
                                DT5->( DbSetOrder( 4 ) )// DT5_FILIAL, DT5_FILDOC, DT5_DOC, DT5_SERIE
                                If DT5->( DbSeek( xFilial("DT5") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE ) )
                                    
                                    DUM->( DbSetOrder( 1 ) )// DUM_FILIAL, DUM_FILORI, DUM_NUMSOL, DUM_ITEM
                                    If DUM->( DbSeek( xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL ) )
                                        
                                        cDUMStr := xFilial("DUM") + DT5->( DT5_FILORI + DT5_NUMSOL )

                                        While DUM->( !EoF() ) .AND. DUM->( DUM_FILIAL + DUM_FILORI + DUM_NUMSOL ) == cDUMStr
                                            cNCM := Posicione( "SB1", 1, xFilial("SB1") + DUM->DUM_CODPRO, "B1_POSIPI")

                                            //-- Busca NCM do produto
                                            If AScan( aNCM, { |x| x == cNCM } ) == 0
                                                AADD( aNCM, cNCM )
                                            EndIf
                                            DUM->( DbSkip() )
                                        EndDo
                                    EndIf

                                    DUE->( DbSetOrder( 1 ) )// DUE_FILIAL, DUE_CODSOL
                                    If DUE->( DbSeek( xFilial("DUE") + DT5->DT5_CODSOL ) )
                                        AAdd( aDT6, { DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, DUE->DUE_CODCLI, DUE->DUE_LOJCLI, DT6->DT6_CLIDES, DT6->DT6_LOJDES, DT6->DT6_SERTMS }  )
                                    EndIf
                                EndIf

                            EndIf
                        Else
                            AAdd( aDT6, { DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, DT6->DT6_CLIREM, DT6->DT6_LOJREM, DT6->DT6_CLIDES, DT6->DT6_LOJDES, DT6->DT6_SERTMS }  )
                        EndIf

                        nPesCob += DT6->DT6_PESO
                        
                        oDoc := JsonObject():New()

                        oDoc["serie"]   := DT6->DT6_SERIE
                        oDoc["numero"]  := DT6->DT6_DOC

                        oCargas["quantidade"]           := DT6->DT6_QTDVOL
                        oCargas["pesoSaidaKg"]          := DT6->DT6_PESCOB

                        cStrDTC := xFilial("DTC") + DT6->( DT6_FILDOC + DT6_DOC + DT6_SERIE )

                        DTC->( DbSetOrder( 3 ) )
                        If DTC->( DbSeek( cStrDTC ) )
                            aNfes := Nil
                            aNfes := {}
                            nNota := 0
                            While DTC->( !Eof() ) .And. DTC->( DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE ) == cStrDTC
                                
                                oNfes := JsonObject():New()
                                
                                oNfes["serie"]  := Alltrim( DTC->DTC_SERNFC )
                                oNfes["numero"] := Alltrim( DTC->DTC_NUMNFC )
                                
                                AAdd( aNfes, oNfes  )

                                cNCM := Posicione( "SB1", 1, xFilial("SB1") + DTC->DTC_CODPRO, "B1_POSIPI")
                                //-- Busca NCM do produto
                                If AScan( aNCM, { |x| x == cNCM } ) == 0
                                    AADD( aNCM, cNCM )
                                EndIf

                                nNota++
                                nValNf += DTC->DTC_VALOR
                                nValSeg += DTC->DTC_VALSEG

                                DTC->(DbSkip())
                            EndDo
                        EndIf
                        
                        oDocs   := JsonObject():New()

                        oDocs["NFes"]   := AClone( aNfes )
                        oDocs["tipoDocumentoViagem"]        := RetTipDoc(Alltrim(DT6->DT6_DOCTMS),Alltrim(DT6->DT6_SERIE))
                        oDocs["chaveAcessoDocumentoViagem"] := Alltrim(DT6->DT6_CHVCTE)
                        oDocs["filialDocumentoViagem"]      := Alltrim(DT6->DT6_FILDOC)
                        oDocs["valorDocumentoViagem"]       := DT6->DT6_VALMER
                        oDocs["documentoViagem"]            := oDoc
                        oDocs["carga"]                      := oCargas

                    EndIf

                    AAdd( aDocViagem, oDocs )

                    DUD->(DbSkip())
                EndDo
            EndIf
            oDocsViagem    := AClone( aDocViagem )
        ElseIf DTQ->DTQ_TIPVIA == "2"
            oDocs                           := JsonObject():New()
            oDocs["tipoDocumentoViagem"]    := "OC"
    
            oDoc            := JsonObject():New()
            oDoc["serie"]   := "1"
            oDoc["numero"]  := DTQ->DTQ_VIAGEM

            oDocs["documentoViagem"]        := oDoc
            oDocs["valorDocumentoViagem"]   := 0

            AAdd( aDocViagem, oDocs )

            oDocsViagem                     := AClone( aDocViagem )
        EndIf
    //Fim Documento da Viagem
        
    //Inicio Motorista
        DUP->( DbSetOrder(2) )
        If DUP->( DbSeek( xFilial('DUP') + DTQ->( DTQ_FILORI + DTQ_VIAGEM ) ) )

            DA4->( DbSetOrder(1))
            If DA4->( DbSeek( xFilial('DA4') + DUP->DUP_CODMOT ) )

                oCNH["categoria"]               := AllTrim(DA4->DA4_CATCNH)
                oCNH["numero"]                  := AllTrim(DA4->DA4_NUMCNH)
                oCNH["validade"]                := FWTimeStamp( 3, DA4->DA4_DTVCNH, Time() )

                oMotorista["CPF"]               := AllTrim(DA4->DA4_CGC)
                oMotorista["CNH"]               := oCNH

                If ( lFrete .AND. ( DMZ->DMZ_ADIANT == "1" .Or. DMZ->DMZ_QUITAC == "1" ) ) .Or. !lFrete
                    aCards := RetCardMot( DA4->DA4_COD, .T. )
                    If Len( aCards ) > 0
                        oMotorista["numeroCartaoPagBem"]:= aCards[1]
                    EndIf
                EndIf

            EndIf
        EndIf
    //Fim Motorista

    //Inicio Origem
        If DTQ->DTQ_TIPVIA <> "2" // 1=Normal; 2=Vazia; 3=Planejada; 4=Socorro; 5=Redespacho
            fRemDest( @cCliRem, @cLojRem, @cCliDes, @cLojDes, aDT6 )
            SA1->(DbSetOrder(1))
            If SA1->( DbSeek( xFilial("SA1") + cCliRem + cLojRem ) )
                cIBGE   := ""
                aRet    := {}
                aRet    := LjFiGetEnd( AllTrim( SA1->A1_END ), , )
                cIBGE   := TMSUFToIBGE( AllTrim(SA1->A1_EST) ) + AllTrim(SA1->A1_COD_MUN)
                
                oEndRemet["CEP"]           := Alltrim(SA1->A1_CEP)
                oEndRemet["codigoIBGE"]    := cIBGE
                oEndRemet["logradouro"]    := Alltrim(aRet[1])
                oEndRemet["numero"]        := Alltrim(aRet[3])
                oEndRemet["complemento"]   := Alltrim(aRet[4])
                oEndRemet["bairro"]        := Alltrim(SA1->A1_BAIRRO)

                oOrigem["filialContratante"]    := cFilAnt
                oOrigem["remetente"]            := Alltrim(SA1->A1_NOME)
                oOrigem["CNPJRemetente"]        := Alltrim(SA1->A1_CGC)
                oOrigem["endereco"]             := oEndRemet
            EndIf
        ElseIf DTQ->DTQ_TIPVIA == "2"

			cEndereco  := ""
			cEstado    := ""
			cCodMunici := ""
			cNome      := ""
			cCNPFCPF   := ""
			cBairro    := ""
			cCEP       := ""

            If Len(aSM0Dados) > 0
                cEndereco  := AllTrim( aSM0Dados[1][2]  )
                cEstado    := AllTrim( aSM0Dados[2][2]  )
                cCodMunici := AllTrim( aSM0Dados[3][2]  )
                cNome      := Alltrim( aSM0Dados[4][2]  )
                cCNPFCPF   := Alltrim( aSM0Dados[5][2]  )
                cBairro    := Alltrim( aSM0Dados[6][2]  )
                cCEP       := Alltrim( aSM0Dados[7][2]  )
            EndIf

			cIBGE   := AllTrim(cCodMunici)
            aRet    := LjFiGetEnd( AllTrim( cEndereco ), , )
            oEndRemet["CEP"]           := Alltrim(cCEP)
            oEndRemet["codigoIBGE"]    := cIBGE
            oEndRemet["logradouro"]    := Alltrim(aRet[1])
            oEndRemet["numero"]        := Alltrim(aRet[3])
            oEndRemet["complemento"]   := Alltrim(aRet[4])
            oEndRemet["bairro"]        := Alltrim(cBairro)

            oOrigem["filialContratante"]    := cFilAnt
            oOrigem["remetente"]            := Alltrim(cNome)
            oOrigem["CNPJRemetente"]        := Alltrim(cCNPFCPF)
            oOrigem["endereco"]             := oEndRemet
        EndIf
    //Fim Origem

    //Inicio Destino
        If DTQ->DTQ_TIPVIA <> "2" //1=Normal;2=Vazia;3=Planejada;4=Socorro;5=Redespacho
            If SA1->( DbSeek( xFilial("SA1") + cCliDes + cLojDes ) )
                cIBGE   := ""
                aRet    := {}
                aRet    := LjFiGetEnd(AllTrim(SA1->A1_END),,)
                cIBGE   := TMSUFToIBGE( AllTrim(SA1->A1_EST) ) + AllTrim(SA1->A1_COD_MUN)

                oEndDest["CEP"]                 := Alltrim(SA1->A1_CEP)
                oEndDest["codigoIBGE"]          := cIBGE
                oEndDest["logradouro"]          := Alltrim(aRet[1])
                oEndDest["numero"]              := Alltrim(aRet[3])
                oEndDest["complemento"]         := Alltrim(aRet[4])
                oEndDest["bairro"]              := Alltrim(SA1->A1_BAIRRO)
            
                oDestino["destinatario"]        := Alltrim(SA1->A1_NOME)
                oDestino["CNPJDestinatario"]    := Alltrim(SA1->A1_CGC)
                oDestino["endereco"]            := oEndDest
            ElseIf Empty( cCliDes ) .AND. Empty( cLojDes )
                If Len(aSM0Dados) > 0
                    cEndereco  := AllTrim( aSM0Dados[1][2]  )
                    cEstado    := AllTrim( aSM0Dados[2][2]  )
                    cCodMunici := AllTrim( aSM0Dados[3][2]  )
                    cNome      := Alltrim( aSM0Dados[4][2]  )
                    cCNPFCPF   := Alltrim( aSM0Dados[5][2]  )
                    cBairro    := Alltrim( aSM0Dados[6][2]  )
                    cCEP       := Alltrim( aSM0Dados[7][2]  )
                EndIf

                cIBGE   := ""
                aRet    := {}
                aRet    := LjFiGetEnd( Alltrim( cEndereco ), , )
                cIBGE   := AllTrim(cCodMunici)

                oEndDest["CEP"]                 := Alltrim(cCEP)
                oEndDest["codigoIBGE"]          := cIBGE
                oEndDest["logradouro"]          := Alltrim(aRet[1])
                oEndDest["numero"]              := Alltrim(aRet[2])
                oEndDest["complemento"]         := Alltrim(aRet[4])
                oEndDest["bairro"]              := Alltrim(cBairro)
                oEndDest["KM"]                  := ""
            
                oDestino["destinatario"]        := Alltrim(cNome)
                oDestino["CNPJDestinatario"]    := Alltrim(cCNPFCPF)
                oDestino["endereco"]            := oEndDest
            EndIf
        ElseIf DTQ->DTQ_TIPVIA == "2"
			//-- Destinatario

            If Len(aSM0Dados) > 0      
                cEndereco  := AllTrim( aSM0Dados[1][2]  )
                cEstado    := AllTrim( aSM0Dados[2][2]  )
                cCodMunici := AllTrim( aSM0Dados[3][2]  )
                cNome      := Alltrim( aSM0Dados[4][2]  )
                cCNPFCPF   := Alltrim( aSM0Dados[5][2]  )
                cBairro    := Alltrim( aSM0Dados[6][2]  )
                cCEP       := Alltrim( aSM0Dados[7][2]  )
            EndIf

			cIBGE   := ""
			aRet    := {}
			aRet    := LjFiGetEnd( Alltrim( cEndereco ), , )
			cIBGE   := AllTrim(cCodMunici)

            oEndDest["CEP"]                 := Alltrim(cCEP)
            oEndDest["codigoIBGE"]          := cIBGE
            oEndDest["logradouro"]          := Alltrim(aRet[1])
            oEndDest["numero"]              := Alltrim(aRet[3])
            oEndDest["complemento"]         := Alltrim(aRet[4])
            oEndDest["bairro"]              := Alltrim(cBairro)
        
            oDestino["destinatario"]        := Alltrim(cNome)
            oDestino["CNPJDestinatario"]    := Alltrim(cCNPFCPF)
            oDestino["endereco"]            := oEndDest
        EndIf
    //Fim Destino

    //Inicio Periodo da Viagem
        cHora := Alltrim(Transform(DTR->DTR_HORINI, "@R 99.99"))
        cHora := StrTran(cHora,'.',':') + ':00'
        oPeriVia["inicio"]    := FWTimeStamp( 3, dDataBase, cHora )

        cHora := Alltrim(Transform(DTR->DTR_HORFIM, "@R 99.99"))
        cHora := StrTran(cHora,'.',':') + ':00'
        oPeriVia["termino"]   := FWTimeStamp( 3, dDataBase, cHora )
    //Fim Periodo da Viagem

    // Inicio Carga
    	If nPesCob = 0
			nPesCob := 0.01
		EndIf
        oCarga["pesoTotalSaidaKg"]      := nPesCob
        oCarga["tipoViagem"]            := If( lCiotAgre, "TACAgregado", "Padrao" )

        If DTQ->DTQ_TIPVIA == "2"
			oCarga["NCM"] := "0001"
        ElseIf Len(aNCM) > 0
			If Len(aNCM) == 1
				oCarga["NCM"] := SubStr(Alltrim(aNCM[1]),1,4)
            Else
                oCarga["NCM"] := "0001"
			EndIf
		Else
			oCarga["NCM"] := "0001"
		EndIf
    // Fim Carga

    // Começo Veiculos
	    nValPdg := 0
        DbSelectArea("DTR")
        DTR->( DbSetOrder(1) ) // DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM
        If DTR->( DbSeek( cStrDTR ) )
            
            nValPdg += DTR->DTR_VALPDG

            DA3->( DbSetOrder(1) )
            If DA3->( DbSeek( xFilial("DA3") + DTR->DTR_CODVEI ) )
                cCatVei       := Posicione( "DUT", 1, xFilial("DUT") + DA3->DA3_TIPVEI,'DUT_CATVEI ') // ['Cavalo', 'Carreta', 'Carro', 'Moto']
                
                If cCatVei == "5" // 1=Comum;2=Cavalo;3=Carreta;4=Especial;5=Utilitario;6=Composicao
                    cTipVei := "Carro"
                ElseIf cCatVei $ "1/2"
                    cTipVei := "Caminhao"
                ElseIf cCatVei $ "3/4/6"
                    cTipVei := "Carreta"
                EndIf
				
                nQtdEixo += DA3->DA3_QTDEIX
                oCavalo["altoDesempenho"]   := .T.
                oCavalo["placa"]            := StrTran( Alltrim(DA3->DA3_PLACA), "-", "" )
                
                cRNTRC := ""
                cRNTRC := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR, "A2_RNTRC"   ) )
                If !Empty(cRNTRC)
                    oCavalo["RNTRC"]        := cRNTRC
                EndIf
                oCavalo["eixos"]            := DA3->DA3_QTDEIX
                
                If DA3->DA3_RODAGE == "1"
                    cTipEixos := "SIMPLES"
                ElseIf DA3->DA3_RODAGE == "2"
                    cTipEixos := "DUPLO"
                ElseIf DA3->DA3_RODAGE == "3" .OR. DA3->DA3_RODAGE == "4"
                    cTipEixos := "DUPLO"
                ElseIf DA3->DA3_RODAGE == "5"
                    cTipEixos := "TRIPLO"
                EndIf

                AAdd( aFornec, { DA3->DA3_CODFOR, DA3->DA3_LOJFOR, cTipEixos } )
            EndIf

            If !Empty( DTR->DTR_CODRB1 )
                If DA3->(DbSeek( xFilial("DA3") + DTR->DTR_CODRB1 ))
                    oCarretas   := JsonObject():New()

                    nQtdEixo += DA3->DA3_QTDEIX

                    oCarretas["placa"]  := StrTran(Alltrim(DA3->DA3_PLACA),"-","")
                    oCarretas["RNTRC"]  := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR, "A2_RNTRC"   ) )
                    oCarretas["eixos"]  := cValToChar( DA3->DA3_QTDEIX )

                    AAdd( aCarretas, oCarretas )
                EndIf

                If !Empty(DTR->DTR_CODRB2)
                    
                    If DA3->(DbSeek( xFilial("DA3") + DTR->DTR_CODRB2 ))
                        oCarretas   := JsonObject():New()
						
						nQtdEixo += DA3->DA3_QTDEIX
                        
                        oCarretas["placa"]  := StrTran(Alltrim(DA3->DA3_PLACA),"-","")
                        
                        cRNTRC := ""
                        cRNTRC := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR, "A2_RNTRC"   ) )
                        If !Empty(cRNTRC)
                            oCarretas["RNTRC"] := cRNTRC
                        EndIf
                        oCarretas["eixos"]  := cValToChar( DA3->DA3_QTDEIX )

                        AAdd( aCarretas, oCarretas )

                        If !Empty(DTR->DTR_CODRB3)
                    
                            If DA3->(DbSeek( xFilial("DA3") + DTR->DTR_CODRB3 ))
								oCarretas   := JsonObject():New()
								
								nQtdEixo += DA3->DA3_QTDEIX
                                
                                oCarretas["placa"]  := StrTran(Alltrim(DA3->DA3_PLACA),"-","")
                                
                                cRNTRC := ""
                                cRNTRC := RTrim( Posicione( "SA2", 1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR, "A2_RNTRC"   ) )
                                If !Empty(cRNTRC)
                                    oCarretas["RNTRC"] := cRNTRC
                                EndIf
                                oCarretas["eixos"]  := cValToChar( DA3->DA3_QTDEIX )
								
								AAdd( aCarretas, oCarretas )
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
        oVeiculos["cavalo"]     := oCavalo
        oVeiculos["carretas"]   := aClone(aCarretas)
    // Fim Veiculos
    
    //Inicio Contratado
        SA2->( DbSetOrder( 1 ) )
        If lFrete .AND. SA2->( DbSeek( xFilial("SA2") + aFornec[1][1] + aFornec[1][2] ) )
          /*  If !Empty(SA2->A2_BANCO)
                oDadosBanco["codigoBanco"]  := Alltrim(SA2->A2_BANCO)
                oDadosBanco["agencia"]      := Alltrim(SA2->A2_AGENCIA)
                oDadosBanco["agenciaDV"]    := Alltrim(SA2->A2_DVAGE)
                oDadosBanco["conta"]        := Alltrim(SA2->A2_NUMCON)
                oDadosBanco["contaDV"]      := Alltrim(SA2->A2_DVCTA)
                oDadosBanco["tipoConta"]    := If( SA2->A2_TPCONTA == '1', "Conta Corrente", "Poupanca" )
            
                oContratado["dadosBancarios"]       := oDadosBanco
            EndIf
            If DMZ->DMZ_ADIANT == "2" .Or. DMZ->DMZ_QUITAC == "2" // "1=Motorista", "2=Proprietário"
                oContratado["numeroCartaoPagBem"]   := aCards[1] // Cartão FornecedorAlltrim(SA2->A2_XCARD)
            EndIf*/

            oContratado["CNPJCPF"]              := Alltrim(SA2->A2_CGC)
            oContratado["RNTRC"]                := Alltrim(SA2->A2_RNTRC)
        EndIf
    //Fim Contratado

    //Inicio Rotas
        If !lFrete
            DbSelectArea("DEK")
            DEK->( DbSetOrder(2) )
            If DEK->( DbSeek(xFilial("DEK") + DTQ->DTQ_ROTA + "03") )
                cIDRota := Alltrim(DEK->DEK_ROTEIR)
            Else
                lRet := .F.
                ::last_error := STR0045 + " " + DTQ->DTQ_ROTA // "Não foi possível encontrar o roteiro da rota:"
            EndIf

            If lRet
	            If DTR->( DbSeek( cStrDTR ) ) .AND. DTR->DTR_QTDEIX > 0
	                oRotas["idRota"]    := Alltrim(cIDRota)
	                oRotas["qtdEixos"]  := cValToChar( DTR->DTR_QTDEIX )
	                AAdd( aRotas, oRotas )
	            EndIf
	
                If DTR->DTR_QTDEIX > 2 
                    oRota["tipoEixo"]   := "DUPLO"
                Else 
                    oRota["tipoEixo"]   := "SIMPLES"
                Endif
	
	            oRota["meioPagamentoPedagio"]   := "Cartao"
	            oRota["rotas"]                  := AClone(aRotas)
	        EndIf
	    EndIf
	// Fim Rotas

    //Inicio Frete
        If lFrete .And. lRet 
            DbSelectArea("DTY")
            DTY->( DbSetOrder(2) ) // DTY_FILIAL, DTY_FILORI, DTY_VIAGEM, DTY_NUMCTC
            If DTY->( DbSeek( FwXFilial("DTY") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) )
                If DTY->DTY_TAXBAN > 0
                    nTaxa   := 1
                Else
                    nTaxa   := 0
                EndIf
                nVlrTaxa    := DTY->DTY_TAXBAN
                
                AAdd( aContrat, { DTY->DTY_VALFRE, DTY->DTY_INSS, DTY->DTY_PIS, DTY->DTY_COFINS, DTY->DTY_CSLL, DTY->DTY_IRRF, DTY->DTY_SEST, DTY->DTY_ISS } )
                    
            Else
                aContrat    := TMSJPrCon( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
                nTaxa       := nQtdTar
                nVlrTaxa    := nVlrTar
                If Len(aContrat) <= 0
                    lRet := .F.
                    ::last_error:= "Não foi possivel realizar o Preview do Contrato de Carreteiro para a Viagem " + DTQ->DTQ_VIAGEM + "."
                EndIf
            EndIf

            If lRet
                nValFre := aContrat[1][1]
                nValInss:= aContrat[1][2]
                nValPis := aContrat[1][3]
                nValCof := aContrat[1][4]
                nValCsl := aContrat[1][5]
                nValIr  := aContrat[1][6]
                nValSest:= aContrat[1][7]
                nValIss := aContrat[1][8]
                //Realizo a gravação dos impostos previstos na DTR
                //para posteriormente comparar os valores na quitação.
                GrvImpDTR( cStrDTR, .F./*lLimpa*/, nValInss, nValPis, nValCof, nValCsl, nValIr, nValSest, nValIss )
            EndIf

            oTarifa["quantidadeTarifasBancarias"]   := nTaxa
            oTarifa["valorTarifasBancarias"]        := nVlrTaxa

            oFrete["tarifa"]                := oTarifa
            oFrete["codigoTipoCargaANTT"]   := "5"
            oFrete["distanciaPercorrida"]   := cValToChar( DTQ->DTQ_KMVGE )
            oFrete["tipoCarga"]             := "Fracionada"
            oFrete["valorPedagio"]          := cValToChar( nValPdg )
            oFrete["INSS"]                  := nValInss//DTY->DTY_INSS
            oFrete["PIS"]                   := nValPis//DTY->DTY_PIS
            oFrete["COFINS"]                := nValCof//DTY->DTY_COFINS
            oFrete["CSLL"]                  := nValCsl//DTY->DTY_CSLL
            oFrete["IR"]                    := nValIr//DTY->DTY_IRRF
            oFrete["sestSenat"]             := nValSest//DTY->DTY_SEST
            oFrete["seguro"]                := cValToChar( nValSeg )
            oFrete["outrosDebitos"]         := nValIss//DTY->DTY_ISS
            oFrete["adiantamentoFornecedor"]:= 0
            oFrete["valorUnidadeFrete"]     := nValFre/nPesCob
            oFrete["valorKgMercadoria"]     := nValNf/nPesCob
            oFrete["valorPesoSaida"]        := 0
            oFrete["valorTotalFrete"]       := nValFre//DTY->DTY_VALFRE

        EndIf
    //Fim Frete

    //Inicio Vale Combustivel
        //If lFrete 
        //    oValeCombust["tipoValor"]       := ""
        //    oValeCombust["unidades"]        := 0
        //    oValeCombust["participante"]    := ""
        //EndIf
    //Fim Vale Combustivel

    //Inicio Pagamento de Frete
    	If lFrete .AND. lDMZPosi .And. lRet 
            If DMZ->DMZ_PESUTI == "1"
                cPesUtili := "Saida"
            ElseIf DMZ->DMZ_PESUTI == "2"
                cPesUtili := "Chegada"
            ElseIf DMZ->DMZ_PESUTI == "3"
                cPesUtili := "SaidaSeMenorQueChegada"
            EndIf

            If DMZ->DMZ_COBQUE == "1"
                cCobQueb    := "NaoCobra"
            ElseIf DMZ->DMZ_COBQUE == "2"
                cCobQueb    := "Parcial"
            ElseIf DMZ->DMZ_COBQUE == "3"
                cCobQueb    := "Integral"
            EndIf

            If DMZ->DMZ_LOCQUI == "1"
                cLocQuiFre  := "QualquerLugar"
            ElseIf DMZ->DMZ_LOCQUI == "2"
                cLocQuiFre  := "ETF"
            ElseIf DMZ->DMZ_LOCQUI == "3"
                cLocQuiFre  := "Filial"
            ElseIf DMZ->DMZ_LOCQUI == "4"
                cLocQuiFre  := "Transportadora"
            EndIf

            If DMZ->DMZ_LOCADI == "1"
                cLocAdi  := "QualquerLugar"
            ElseIf DMZ->DMZ_LOCADI == "2"
                cLocAdi  := "ETF"
            ElseIf DMZ->DMZ_LOCADI == "3"
                cLocAdi  := "Filial"
            ElseIf DMZ->DMZ_LOCADI == "4"
                cLocAdi  := "Transportadora"
            EndIf

            oFreQuiReg["tipoTolerancia"]        := If( DMZ->DMZ_TIPTOL == "1" , "Porcentagem", "kilograma" ) //""
            oFreQuiReg["freteTipoPeso"]         := "Saida"//cPesUtili //""
            oFreQuiReg["freteLimiteSuperior"]   := If( DMZ->DMZ_TIPTOL == "1" , DMZ->DMZ_LIMEXC, DMZ->DMZ_QUIEXC ) //0
            oFreQuiReg["quebraTipoCobranca"]    := "NaoCobra"//cCobQueb //""
            oFreQuiReg["quebraTolerancia"]      := If( DMZ->DMZ_TIPTOL == "1" , DMZ->DMZ_PORQUE, DMZ->DMZ_QUIQUE ) //0
            oFreQuiReg["avariaTipoCobranca"]    := "NaoCobra"//If( DMZ->DMZ_COBAVA == "1" , "NaoCobra", "Integral" ) //0

            oInfObrig["dataEntrega"]        := .F.
            oInfObrig["peso"]               := .F.
            oInfObrig["ticketBalanca"]      := .F.
            oInfObrig["avaria"]             := .F.//DMZ->DMZ_AVARIA == "1"
            oInfObrig["canhotoNFe"]         := .F.//DMZ->DMZ_NFECAN == "1"
            oInfObrig["comprovantePedagio"] := .F.//DMZ->DMZ_COMPDG == "1"
            oInfObrig["DACTE"]              := .F.//DMZ->DMZ_DACTE == "1"
            //oInfObrig["contratoTransporte"] := DMZ->DMZ_CONTRA == "1"

            If DTR->( DbSeek( cStrDTR ) ) .AND. DTR->DTR_ADIFRE > 0
                oAdianta["data"]        := FWTimeStamp( 3, dDataBase, Time() )
                oAdianta["tipoParcela"] := "Valor"
                nValAdi := DTR->DTR_ADIFRE
                oAdianta["unidades"]    := cValToChar( nValAdi )
                
                AAdd( aAdian, oAdianta )
            EndIf

            //oMoto["porcentagemAdiantamento"]    := 0//If( DMZ->DMZ_ADIANT == "1", 100, 0 )
            //oMoto["porcentagemQuitacao"]        := 0//If( DMZ->DMZ_QUITAC == "1", 100, 0 )
            
            nVlrQui := nValFre - nValAdi - nValInss - nValPis - nValCof - nValCsl - nValIr - nValSest - nValIss

            oMoto["valorAdiantamento"]          := cValToChar( nValAdi )//If( DMZ->DMZ_ADIANT == "1", nValAdi, 0 )
            oMoto["valorQuitacao"]              := cValToChar( nVlrQui )

            //oContr["porcentagemAdiantamento"]   := 0//If( DMZ->DMZ_ADIANT == "2", 0, 100 )
            //oContr["porcentagemQuitacao"]       := 0//If( DMZ->DMZ_QUITAC == "2", 0, 100 )
            oContr["valorAdiantamento"]         := 0//If( DMZ->DMZ_ADIANT == "2", nValAdi, 0 )
            oContr["valorQuitacao"]             := 0
            
            oParti["motorista"]     := oMoto
            oParti["contratado"]    := oContr
        
            oPagFrete["destinacaoComercial"]            := .F.
            oPagFrete["freteQuitacaoRegras"]            := oFreQuiReg
            oPagFrete["informacoesObrigatoriasQuitacao"]:= oInfObrig
            oPagFrete["meioPagamentoFrete"]             := "PagBem"
            oPagFrete["localQuitacao"]                  := "Filial"
            oPagFrete["localAdiantamento"]              := "Filial"
            If nValAdi > 0
                oPagFrete["adiantamento"]                   := AClone( aAdian )
            EndIf
            oPagFrete["participacao"]                   := oParti
        EndIf
    // Fim Pagamento de Frete
    If lRet
        oBody["isViagemLiberada"]       := .F.
        oBody["operador"]               := UsrRetName( __cUserId )
        oBody["tipoVeiculo"]            := cTipVei
        oBody["numeroViagemCliente"]    := DTQ->( DTQ_FILORI + DTQ_VIAGEM )
        oBody["documentosViagem"]       := oDocsViagem
            
        oBody["motorista"]              := oMotorista
        oBody["origem"]                 := oOrigem
        oBody["destino"]                := oDestino
        oBody["periodoViagem"]          := oPeriVia
        If !lFrete 
            oBody["rota"]                   := oRota
        EndIf 
        oBody["dadosCarga"]             := oCarga
        oBody["veiculos"]               := oVeiculos

        If lFrete
            oBody["contratado"]             := oContratado
            oBody["isContratoAvulso"]       := .F. //--> Se informado .T. não será gerado CIOT junto a ANTT pela PAGBEM. 
            oBody["dadosFrete"]             := oFrete
            oBody["pagamentoFrete"]         := oPagFrete
        EndIf

        cBody   := oBody:ToJson()

        If lFrete
            If lCiotAgre
                cPath := "/api/ciotagregado/" + Replace( cCiotAgreg, "/" ) + "/viagem/frete"
            Else
                cPath := cPath + "frete"
            EndIf
        Else
            cPath := cPath + "pedagio"
        EndIf

        aResult := ::Post( cPath, AClone( aHeaderStr ), FwCutOff(cBody,.T.) )

        If aResult[1]
            
            lRet    := FWJsonDeserialize( DeCodeUTF8(aResult[2]), @oResponse )

            If lRet .And. ValType( oResponse ) == "O"
                /*
                    {
                        "isSucesso": true,
                        "erros": [
                                    {
                                    "codigo": 0,
	                                "mensagem": "string"
	                                }
	                            ],
	                    "avisos": [
	                                {
	                                "codigo": 0,
	                                "mensagem": "string"
	                                }
	                            ],
	                    "resultado": {
	                                    "valorTotalFrete": 0,
	                                    "valorCanceladoFrete": 0,
	                                    "valorSaldoFrete": 0,
	                                    "valorTotalPedagio": 0,
	                                    "valorCanceladoPedagio": 0
	                                }
	                }
	            */
	            If oResponse:IsSucesso
	                If AttIsMemberOf( oResponse, "Resultado" )

	                    If AttIsMemberOf( oResponse:Resultado, "idViagem" )
	                        
	                        If lFrete
	                            ::IdFrete   := cValToChar(oResponse:Resultado:IdViagem)
	                            If AttIsMemberOf( oResponse:Resultado, "CIOT" )
	                                ::CIOT := cValToChar(oResponse:Resultado:Ciot)
	                            EndIf
	                        Else
	                            ::IdPedagio := cValToChar(oResponse:Resultado:IdViagem)
	                        EndIf
	                    EndIf
	
	                EndIf
	                lRet := oResponse:IsSucesso
                Else
                    // Não achei o numero do cartão
                    nErros := Len( oResponse:Erros )
                    If nErros > 0
                        
                        For nX := 1 To nErros
                            cMsg += oResponse:Erros[nX]:Mensagem
                        Next nX

                        lRet            := oResponse:IsSucesso
                        ::last_error    := cMsg
                    EndIf
                EndIf
            EndIf
        Else
            lRet            := aResult[1]
            ::last_error    := ::rest_client:GetLastError()
        EndIf
    EndIf
    FwFreeArray( aHeaderStr )
    FwFreeArray( aNCM )
    FwFreeArray( aDocViagem )
    FwFreeArray( aNfes )
    FwFreeArray( aHeaderStr )
    FwFreeArray( aDados )
    FwFreeArray( aResult )
    FwFreeArray( aRegra )
    FwFreeArray( aDT6 )
    FwFreeArray( aAdian )
    FwFreeArray( aRotas )
    FwFreeArray( aFornec )
    FwFreeArray( aCarretas )

    FwFreeObj( oResponse )
    FwFreeObj( oBody )
    FwFreeObj( oTarifa )
    FwFreeObj( oFrete )
    FwFreeObj( oValeCombust )
    FwFreeObj( oDoc )
    FwFreeObj( oDocsViagem )
    FwFreeObj( oCargas )
    FwFreeObj( oNfes )
    FwFreeObj( oDocs )
    FwFreeObj( oDadosBanco )
    FwFreeObj( oContratado )
    FwFreeObj( oCNH )
    FwFreeObj( oMotorista )
    FwFreeObj( oEndRemet )
    FwFreeObj( oOrigem )
    FwFreeObj( oEndDest )
    FwFreeObj( oDestino )
    FwFreeObj( oPeriVia )
    FwFreeObj( oRotas )
    FwFreeObj( oRota )
    FwFreeObj( oCarga )
    FwFreeObj( oCavalo )
    FwFreeObj( oCarretas )
    FwFreeObj( oVeiculos )
    FwFreeObj( oFreQuiReg )
    FwFreeObj( oInfObrig )
    FwFreeObj( oAdianta )
    FwFreeObj( oMoto )
    FwFreeObj( oContr )
    FwFreeObj( oParti )
    FwFreeObj( oPagFrete )

    RestArea( aAreaSA2 )
    RestArea( aAreaDTQ )
    RestArea( aAreaDTR )
    RestArea( aAreaDT6 )
    RestArea( aAreaDTC )
    RestArea( aAreaDTY )
    RestArea( aAreaDA8 )
    RestArea( aAreaDMZ )
    RestArea( aAreaSM0 )
    RestArea( aAreaDEK )
    RestArea( aAreaDT5 )
    RestArea( aAreaDUE )
    RestArea( aAreaDUM )

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GravaToken()

Gravar token nas tabelas

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD DelTravel( cIdViagem ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local aAreaDEG      := DEG->(GetArea())
    Local lRet          := .F.
    Local cPath         := "/api/viagens/"//+{IdViagem}
    Local cBody         := ""
    Local cMsg          := ""
    Local oBody         := JsonObject():New()
    Local nErros        := 0
    Local nX            := 0
    Local aResult       := {}
    Local aHeaderStr    := {}
    Local oResponse     := Nil

    Default cIdViagem   := ""
    
    If !Empty(cIdViagem)
        ::rest_client       := FwRest():New( ::Self:url_token )

        Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
        Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
        Aadd( aHeaderStr, "Accept: application/json"                        )
        Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
        Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

        /*{
           "motivo": "ErroLancamento",
            "observacao": "string"
        }*/
        oBody["motivo"]     := "ErroLancamento" // 'ErroLancamento', 'ProblemaVeiculo', 'Sinistro', 'Roubo', 'Fraude', 'SinistroParcial', 'Suspensao', 'Expurgo', 'Outros'
        oBody["observacao"] := "ErroLancamentoViagem"

        cBody   := oBody:ToJson()
        cPath := cPath + AllTrim( cIdViagem )

        aResult := ::Delete( cPath, AClone( aHeaderStr ), cBody )
        
        ::DelCancPdg    := 0
        ::DelCancFret   := 0
        ::DelTotPdg     := 0
        ::DelSaldoFre   := 0
        ::DelVlTotFret  := 0

        If aResult[1]
       
            lRet    := FWJsonDeserialize( aResult[2], @oResponse )

            If lRet .And. ValType( oResponse ) == "O"
                /*
                {
                    "isSucesso": true,
                    "erros": [
                        {
                        "codigo": 0,
                        "mensagem": "string"
                        }
                    ],
                    "avisos": [
                        {
                        "codigo": 0,
                        "mensagem": "string"
                        }
                    ],
                    "resultado": {
                        "valorTotalFrete": 0,
                        "valorCanceladoFrete": 0,
                        "valorSaldoFrete": 0,
                        "valorTotalPedagio": 0,
                        "valorCanceladoPedagio": 0
                    }
                }
                */
                If oResponse:IsSucesso
                    If AttIsMemberOf( oResponse, "Resultado" )

                        If AttIsMemberOf( oResponse:Resultado, "valorTotalFrete" )
                            ::DelVlTotFret := oResponse:Resultado:valorTotalFrete
                        EndIf
                        If AttIsMemberOf( oResponse:Resultado, "valorSaldoFrete" )
                            ::DelSaldoFre := oResponse:Resultado:valorSaldoFrete
                        EndIf
                        If AttIsMemberOf( oResponse:Resultado, "valorTotalPedagio" )
                            ::DelTotPdg := oResponse:Resultado:valorTotalPedagio
                        EndIf
                        If AttIsMemberOf( oResponse:Resultado, "valorCanceladoFrete" )
                            ::DelCancFret := oResponse:Resultado:valorCanceladoFrete
                        EndIf
                        If AttIsMemberOf( oResponse:Resultado, "valorCanceladoPedagio" )
                            ::DelCancPdg := oResponse:Resultado:valorCanceladoPedagio
                        EndIf

                    EndIf
                    lRet := oResponse:IsSucesso
                Else
                    // Não achei o numero do cartão
                    nErros := Len( oResponse:Erros )
                    If nErros > 0
                        
                        For nX := 1 To nErros
                            cMsg += oResponse:Erros[nX]:Mensagem
                        Next nX

                        lRet            := oResponse:IsSucesso
                        ::last_error    := cMsg
                    EndIf
                EndIf
            EndIf
            
        Else
            lRet            := aResult[1]
            ::last_error    := ::rest_client:GetLastError()
        EndIf
    EndIf
    
    RestArea( aAreaDEG )
    RestArea( aArea )

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetTravel()

Gravar token nas tabelas

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetTravel( cIdViagem ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local aAreaDEG      := DEG->(GetArea())
    Local lRet          := .F.
    Local cPath         := "/api/viagens/" // + {IdViagem}
    Local nErros        := 0
    Local nX            := 0
    Local cMsg          := ""
    Local cParams       := ""
    Local aHeaderStr    := {}
    Local aResult       := {}
    Local oResponse     := Nil

    Default cIdViagem   := ""
    
    If !Empty(cIdViagem)
        Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )
        Aadd( aHeaderStr, "CNPJContratante : " +  ::CNPJContr )

        cPath := cPath + AllTrim( cIdViagem )

        aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

        If aResult[1]

            lRet    := FWJsonDeserialize( aResult[2], @oResponse )

            If lRet .And. ValType( oResponse ) == "O"
                /*
                    "saldos": {
                        "valorTotalConsumido": 0,
                        "valorBloqueado": 0,
                        "valorLiberado": 0
                    },
                    "situacaoFrete": "Frete_AguardandoLiberacao",
                    "situacaoPedagio": "Frete_AguardandoLiberacao",
                    "CIOT": "string",
                    "dataQuitacao": "2022-02-14T12:31:53.671Z",
                */
                ::CIOT      := ""
                ::VlrTotCon := ""
                ::VlrBloq   := ""
                ::VlrLib    := ""
                ::SitFrete  := ""
                ::SitPedagio:= ""
                ::VlrCanPdg := ""
                If oResponse:IsSucesso
                    If AttIsMemberOf( oResponse, "Resultado" )

                        If AttIsMemberOf( oResponse:Resultado, "CIOT" )
                            ::CIOT := oResponse:Resultado:Ciot
                        EndIf

                        If AttIsMemberOf( oResponse:Resultado, "saldos" )
                            ::VlrTotCon := oResponse:Resultado:Saldos:valorTotalConsumido
                            ::VlrBloq   := oResponse:Resultado:Saldos:valorBloqueado
                            ::VlrLib    := oResponse:Resultado:Saldos:valorLiberado
                        EndIf

                        If AttIsMemberOf( oResponse:Resultado, "situacaoFrete" )
                            ::SitFrete := oResponse:Resultado:situacaoFrete
                        EndIf

                        If AttIsMemberOf( oResponse:Resultado, "situacaoPedagio" )
                            ::SitPedagio := oResponse:Resultado:situacaoPedagio
                        EndIf

                        If AttIsMemberOf( oResponse:Resultado, "valorCanceladoPedagio" )
                            ::VlrCanPdg := oResponse:Resultado:valorCanceladoPedagio
                        EndIf

                        lRet := oResponse:IsSucesso
                    EndIf
                Else
                    // Não achei o numero do cartão
                    nErros := Len( oResponse:Erros )
                    If nErros > 0
                        
                        For nX := 1 To nErros
                            cMsg += DecodeUTF8( oResponse:Erros[nX]:Mensagem ) + " "
                        Next nX

                        lRet := oResponse:IsSucesso
                        ::last_error := AllTrim( cMsg )
                    EndIf
                EndIf
            EndIf
            
        Else
            lRet := aResult[1]
            ::last_error := AllTrim( ::rest_client:GetLastError() )
        EndIf
    EndIf
    
    RestArea( aAreaDEG )
    RestArea( aArea )

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRoute()


@author Daniel Leme
@since 03/01/2022
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetRoute( aDados, cIdRota, cCdrOri, cCdrDes ) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local cParams   := ""
    Local oResponse := Nil
    Local cPath     :=  "/api/rotas/pag"
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nI        := 0
    Local nLen      := 0
    Local cMsg      := ""

    Default aDados    := {}
    Default cIdRota   := ""
    Default cCdrOri   := ""
    Default cCdrDes   := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )
	Aadd( aHeaderStr, "CNPJContratante : " +  ::CNPJContr )

    //-- Acrescenta parâmetros ao path
    If !Empty(cIdRota+cCdrOri+cCdrDes)
        cPath += "?"
        //-- IDROTA
        cPath += Iif(!Empty(cIdRota)  ,"IdRota="            + AllTrim(cIdRota)  +"&","")
        //-- CDRORI
        cPath += Iif(!Empty(cCdrOri)  ,"Origem.uF="         + ;
                        AllTrim(Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_EST"))+"&","")
        cPath += Iif(!Empty(cCdrOri)  ,"Origem.codigoIBGE=" + ;
                        AllTrim(TMSUFToIBGE( DUY->DUY_EST ))+ AllTrim(DUY->DUY_CODMUN)+"&","")
        //-- CDRDES
        cPath += Iif(!Empty(cCdrDes)  ,"Destino.uF="         + ;
                        AllTrim(Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_EST"))+"&","")
        cPath += Iif(!Empty(cCdrDes)  ,"Destino.codigoIBGE=" + ;
                        AllTrim(TMSUFToIBGE( DUY->DUY_EST ))+ AllTrim(DUY->DUY_CODMUN)+"&","")

        //-- Retira o último "&" da string path
        cPath := Iif(Right(cPath,1)=="&",Substr(cPath,1,Len(cPath)-1),cPath)
    EndIf
    aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( DeCodeUTF8(aResult[2]), @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                If AttIsMemberOf( oResponse, "Resultado" )
                    If AttIsMemberOf( oResponse:Resultado, "Rotas" )
                        /*
                        "rotas": [
                        {
                            "idRota": 2729,
                            "descricaoRota": "EXCLUIR A ROTA - APÓS IMPORTACAO",
                            "isRotaPronta": true,
                            "distanciaKM": 438.3,
                            "tipoRoteirizacao": "MaisRapida",
                            "origemMunicipio": "São Paulo",
                            "origemUF": "SP",
                            "destinoMunicipio": "Rio de Janeiro",
                            "destinoUF": "RJ",
                            "nomeRoteirizador": "Maplink",
                            "dataRoteirizacao": "2001-01-01T00:00:00",
                            "dataSolicitacao": "2018-12-17T17:15:46.127",
                            "CNPJContratante": "23149892000192",
                            "nomeContratante": "PAGBEM SERVICOS FINANCEIROS E DE LOGISTICA S.A."
                        }
                        ],
                        */
                        If (nLen := oResponse:resultado:numeroRegistros) > 0
                            For nI := 1 To nLen
                                AAdd( aDados, { oResponse:resultado:Rotas[nI]:idRota,;
                                                "",;
                                                Iif( AttIsMemberOf( oResponse:resultado:Rotas[nI], "nomeRota" ),;
                                                    oResponse:resultado:Rotas[nI]:nomeRota,;
                                                    ""),;
                                                Iif( AttIsMemberOf( oResponse:resultado:Rotas[nI], "origemMunicipio" ),;
                                                     oResponse:resultado:Rotas[nI]:origemMunicipio,;
                                                     ""),;
                                                Iif( AttIsMemberOf( oResponse:resultado:Rotas[nI], "origemUF" ),;
                                                     oResponse:resultado:Rotas[nI]:origemUF,;
                                                     ""),;
                                                Iif( AttIsMemberOf( oResponse:resultado:Rotas[nI], "destinoMunicipio" ),;
                                                     oResponse:resultado:Rotas[nI]:destinoMunicipio,;
                                                     ""),;
                                                Iif( AttIsMemberOf( oResponse:resultado:Rotas[nI], "destinoUF" ),;
                                                     oResponse:resultado:Rotas[nI]:destinoUF,;
                                                     ""),;
                                                "" ;
                                                    } )
                            Next nI
                            aRet := {.T.,""}
                        Else
                            aRet := {.F.,"Nenhum registro retornado para o filtro"}
                        EndIf
                    EndIf
                EndIf
            Else
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nI := 1 To nErros
                        cMsg += DecodeUTF8(oResponse:Erros[nI]:Mensagem)
                    Next nI

                    aRet := { oResponse:IsSucesso, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { .F., AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PostRoute()

Método para incluir rotas

@author Daniel Leme
@since 20/02/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PostRoute() CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local lRet          := .F.
    Local aRet          := {.F.,"","Erro Indeterminado"}
    Local aRetorno      := {}
    Local aHeaderStr    := {}
    Local oResponse     := Nil
    Local oBody         := JsonObject():New()
    Local oOrigem       := JsonObject():New()
    Local oDestino      := JsonObject():New()
    Local cPath         :=  "/api/rotas"
    Local cBody         := ""
    Local cUF           := ""
    Local nX            := 0
    Local nErros        := 0
    Local cMsg          := ""

    ::rest_client   := FwRest():New( ::url_token )

	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    //-- DESTINO
    If ::RouteDes[1] == "1"
        oDestino["CEP"]        := ::RouteDes[2]
    ElseIf ::RouteDes[1] == "2"
        cUF := Posicione("DUY",1,xFilial("DUY")+::RouteDes[2],"DUY_EST") 
        oDestino["codigoIBGE"] := TMSUFToIBGE( cUF ) +Posicione("DUY",1,xFilial("DUY")+::RouteDes[2],"DUY_CODMUN") 
    EndIf
    //-- ORIGEM
    If ::RouteOri[1] == "1"
        oOrigem["CEP"]        := ::RouteOri[2]
    ElseIf ::RouteOri[1] == "2"
        cUF := Posicione("DUY",1,xFilial("DUY")+::RouteOri[2],"DUY_EST") 
        oOrigem["codigoIBGE"] := TMSUFToIBGE( cUF ) +Posicione("DUY",1,xFilial("DUY")+::RouteOri[2],"DUY_CODMUN") 
    EndIf

    oBody["destino"]                := oDestino
    oBody["origem"]                 := oOrigem
    oBody["pontosPassagem"]         := {}
    //-- PONTOS
    For nX := 1 To Len(::RoutePtos)
        aAdd(oBody["pontosPassagem"], JsonObject():New())
        If ::RoutePtos[nX][1] == "1"
            aTail(oBody["pontosPassagem"])["CEP"]        := ::RoutePtos[nX][2]
        ElseIf ::RoutePtos[nX][1] == "2"
            cUF := Posicione("DUY",1,xFilial("DUY")+::RoutePtos[nX][2],"DUY_EST") 
            aTail(oBody["pontosPassagem"])["codigoIBGE"] := TMSUFToIBGE( cUF ) +Posicione("DUY",1,xFilial("DUY")+::RoutePtos[nX][2],"DUY_CODMUN") 
        EndIf
    Next nX

    oBody["nomeRota"]               := ::RouteName
    oBody["otimizarPontosPassagem"] := .T.
    oBody["tipoRoteirizacao"]       := "MaisRapida"
    oBody["rotaTemporaria"]         := .F.

    cBody   := oBody:ToJson()

    aRetorno    := ::Post( cPath, aHeaderStr, FwCutOff(cBody,.T.) )
    
    If aRetorno[1]
        
        lRet    := FWJsonDeserialize( aRetorno[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                aRet := { oResponse:IsSucesso,"", "" }
            Else
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    For nX := 1 To nErros
                        cMsg += DecodeUTF8(oResponse:Erros[nX]:Mensagem)
                    Next nX
                    aRet := { oResponse:IsSucesso,"" , cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aRetorno[1], "", AllTrim( ::rest_client:GetLastError() ) }
    EndIf
    
    RestArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GravaToken()

Gravar token nas tabelas

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GravaToken( dData, cTime, cToken, nTimeExp ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local aAreaDEG      := DEG->(GetArea())
    Local lRet          := .F.

    Default dData       := ::data_token
    Default cTime       := ::time_token
    Default cToken      := ::access_token
    Default nTimeExp    := ::time_expire

    DEG->( DbSetOrder( 1 ) )
    If DEG->( DbSeek( xFilial( "DEG" ) + "03" ) )

        RecLock( "DEG", .F. )
            DEG->DEG_DTTOKE := dData
            DEG->DEG_HRTOKE := cTime
            DEG->DEG_TOKEN  := cToken
            DEG->DEG_EXPIRE := nTimeExp
        DEG->( MsUnlock() )
        
        ::access_token  := cToken
        ::time_token    := cTime
        ::data_token    := dData
        ::time_expire   := nTimeExp
        lRet            := .T.

    EndIf
    
    RestArea( aAreaDEG )
    RestArea( aArea )

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} Destroy()

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD Destroy() CLASS TMSBCAPagBem

    ::url_token             := Nil
    ::access_token          := Nil
    ::grant_type            := Nil
    ::username              := Nil
    ::password              := Nil
    ::rest_client           := Nil
    ::json_object           := Nil
    ::last_error            := Nil
    ::error_description     := Nil
    ::data_token            := Nil
    ::time_token            := Nil
    ::time_expire           := Nil
    ::number_card           := Nil

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} Qrytoken()
Retorna query para consulta de token

@author Rodrigo Pirolo
@since 01/11/2021
@version 1.0
/*/
//--------------------------------------------------------------------

Static Function QryToken()

    Local cQuery := ""

    cQuery  := " SELECT R_E_C_N_O_ RECNODEG, DEG_DTTOKE,  DEG_HRTOKE, DEG_EXPIRE "
    cQuery  += " FROM " + RetSQLName("DEG") + " DEG "
    cQuery  += " WHERE DEG_FILIAL = '" + xFilial("DEG") + "' "
    cQuery  += " AND DEG_CODOPE = '03' "
    cQuery  += " AND DEG_TOKEN <> '' "
    cQuery  += " AND DEG_DTTOKE <> '' "
    cQuery  += " AND DEG_HRTOKE <> '' "
    cQuery  += " AND DEG_EXPIRE <> '' "
    cQuery  += " AND DEG.D_E_L_E_T_ = ' ' "

Return cQuery

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSUFToIBGE()
Função para retornar o Codigo IBGE dos estados

@author Rodrigo Pirolo
@since 14/12/2021
@version 1.0
/*/
//--------------------------------------------------------------------

Function TMSUFToIBGE( cUf )

    Local aUF   := {}
    Local nPos  := 0
    Local cRet  := ""

    aAdd( aUF, { "RO", "11" } )
    aAdd( aUF, { "AC", "12" } )
    aAdd( aUF, { "AM", "13" } )
    aAdd( aUF, { "RR", "14" } )
    aAdd( aUF, { "PA", "15" } )
    aAdd( aUF, { "AP", "16" } )
    aAdd( aUF, { "TO", "17" } )
    aAdd( aUF, { "MA", "21" } )
    aAdd( aUF, { "PI", "22" } )
    aAdd( aUF, { "CE", "23" } )
    aAdd( aUF, { "RN", "24" } )
    aAdd( aUF, { "PB", "25" } )
    aAdd( aUF, { "PE", "26" } )
    aAdd( aUF, { "AL", "27" } )
    aAdd( aUF, { "MG", "31" } )
    aAdd( aUF, { "ES", "32" } )
    aAdd( aUF, { "RJ", "33" } )
    aAdd( aUF, { "SP", "35" } )
    aAdd( aUF, { "PR", "41" } )
    aAdd( aUF, { "SC", "42" } )
    aAdd( aUF, { "RS", "43" } )
    aAdd( aUF, { "MS", "50" } )
    aAdd( aUF, { "MT", "51" } )
    aAdd( aUF, { "GO", "52" } )
    aAdd( aUF, { "DF", "53" } )
    aAdd( aUF, { "SE", "28" } )
    aAdd( aUF, { "BA", "29" } )
    aAdd( aUF, { "EX", "99" } )
    
    nPos := aScan( aUF, { |x| x[1] ==  AllTrim( cUf ) } )
    
    If nPos > 0     // Confere se Uf esta OK
        cRet := aUF[ nPos, 2 ]
    EndIf

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSIntgPB()
Executa integração de dados com o sistema PAGBEM
@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
/*/
//--------------------------------------------------------------------

Function TMSIntgPB( cCodMot, cCGCMot, cCodVei, cCodForLoj )

	Local oProcess	:= Nil
	Local lEnd		:= .F.
    Local bBlock    := { || .T. }

    Default cCodMot     := ""
    Default cCGCMot     := ""
    Default cCodVei     := ""
    Default cCodForLoj  := ""

    If FwIsInCallStack("OMSA040") .AND. ( FwIsInCallStack("CommitMdl") .OR. FwIsInCallStack("OMS040AtOp") )
        bBlock  := { | lEnd | IntMotPGBEM( @oProcess, cCodMot, cCGCMot ) }
    ElseIf FwIsInCallStack("OMSA060") .AND. ( FwIsInCallStack("CommitMdL") .OR. FwIsInCallStack("OMS060AtOp") )
        bBlock  := { | lEnd | IntVeiPGBEM( @oProcess, cCodVei ) }
    ElseIf FwIsInCallStack("MATA020")
        bBlock  := { | lEnd | IntForPGBEM( @oProcess, cCodForLoj ) }
    EndIf

	oProcess := MsNewProcess():New( bBlock, STR0002, STR0003, .T. ) //"Integração TMS Protheus X PagBem" "Realizando integração com o Sistem PagBem"
	oProcess:Activate()

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} IntMotPGBEM()
Executa integração de dados 
@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Static Function IntMotPGBEM( oProcess, cCodMot, cCGCMot )

	Local lAltCad	:= .F.
	Local oPagBem	:= Nil
    Local nCards    := 0
    Local nX        := 0

	Default oProcess	:= Nil
	Default lEnd		:= .F.
	Default cCodMot		:= ""
	Default cCGCMot		:= ""

	oProcess:SetRegua1(1)
	
	oPagBem := TMSBCAPagBem():New()
	
    If oPagBem:Instaciado
    	oProcess:SetRegua1(2)
	    oProcess:IncRegua1(STR0004) // STR0004 "Autenticando na PagBem."
        
        oPagBem:Auth()
        oPagBem:GetToken()

        oProcess:SetRegua1(3)
        oProcess:IncRegua1(STR0005) // STR0005 "Verificando Token Ativo."
        
        aPagBem	:= oPagBem:IsTokenActive()

        oProcess:SetRegua1(4)
        If aPagBem[1] .AND. !Empty(cCodMot) .AND. !Empty(cCGCMot)
            oProcess:IncRegua1(STR0006) // STR0006 "Obtendo dados do Motorista."
            
            oPagBem:DriverInfo( cCodMot )
            
            If !Empty(oPagBem:DrivrForn) .AND. !Empty(oPagBem:DrivrLoja)
                IntForPGBEM( oProcess, oPagBem:DrivrForn + oPagBem:DrivrLoja )
            EndIf

            If !Empty( oPagBem:Drivr_Code )
                oProcess:SetRegua1(5)
                oProcess:IncRegua1(STR0007) // STR0007 "Verificando dados do Motorista no Sistema PagBem."
                
                lAltCad := oPagBem:GetDriver( cCGCMot )[1]

                oProcess:SetRegua1(6)
                aPagBem	:= NIL
                aPagBem	:= {}
                oProcess:IncRegua1( If( lAltCad, STR0008, STR0009 ) ) // STR0008 "Alterando dados do Motorista no Sistema PagBem." STR0009 "Incluindo dados do Motorista no Sistema PagBem."

                aPagBem	:= oPagBem:PutDriver( lAltCad )
                oProcess:SetRegua1(7)

                If aPagBem[1]
                    oProcess:IncRegua1( STR0010 ) // STR0010 "Ajustes realizados no Sistema PagBem."

                    nCards := Len( oPagBem:DrivrCard )

                    If nCards > 0
                        oProcess:IncRegua1( STR0013 ) // STR0013 "Vinculando Cartão ao motorista."
                        
                        For nX := 1 To nCards
                            aPagBem := oPagBem:PutCardLink( oPagBem:DrivrCard[nX] )
                        Next nX
                        
                        oProcess:SetRegua1(8)

                    EndIf
                Else
                    Help( "", 1, STR0002, , STR0011 + DecodeUTF8(aPagBem[3]), 1, 0, , , , , , { STR0012 } ) //STR0002"Integração TMS x PAGBEM"  STR0011"Ocorreu um problema na integração entre TMS Protheus e PAGBEM. "  "O cadastro no TMS Protheus será efetivado sem problemas, porém será necessario realizar a integração novamente."
                EndIf

            EndIf
        EndIf
	
        oPagBem:Destroy()
        oProcess:SetRegua1(8)
	EndIf
    FwFreeObj(oPagBem)
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} IntVeiPGBEM()

@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Static Function IntVeiPGBEM( oProcess, cCodVei )

	Local lAltCad       := .F.
	Local oPagBem       := Nil

	Default oProcess	:= Nil
	Default lEnd		:= .F.
	Default cCodVei		:= ""

	oProcess:SetRegua1(1)
	
	oPagBem := TMSBCAPagBem():New()
	If oPagBem:Instaciado
        oProcess:SetRegua1(2)
        oProcess:IncRegua1(STR0004) // STR0004 "Autenticando na PagBem."
        
        oPagBem:Auth()

        oProcess:SetRegua1(3)
        oProcess:IncRegua1(STR0005) // STR0005 "Verificando Token Ativo."
        
        aPagBem	:= oPagBem:IsTokenActive()

        oProcess:SetRegua1(4)
        If aPagBem[1] .AND. !Empty( cCodVei )
            oProcess:IncRegua1( STR0006 ) // STR0006 "Obtendo dados do Motorista."
        
            If oPagBem:VehicleInfo( cCodVei )
                oProcess:SetRegua1(5)
                oProcess:IncRegua1(STR0007) // STR0007 "Verificando dados do Motorista no Sistema PagBem."
                
				lAltCad := oPagBem:GetVehicle()[1]
				
				If lAltCad
					aRet := oPagBem:PutVehicle()
					If aRet[1]
						oProcess:IncRegua1( STR0010 ) // STR0010 "Ajustes realizados no Sistema PagBem."
					Else
						cMsg := STR0011 + DecodeUTF8(aRet[3])
						Help( "", 1, STR0002, , cMsg, 1, 0, , , , , .T., { STR0012 } ) //STR0002"Integração TMS x PAGBEM"  STR0011"Ocorreu um problema na integração entre TMS Protheus e PAGBEM. "  "O cadastro no TMS Protheus será efetivado sem problemas, porém será necessario realizar a integração novamente."
					EndIf
					Begin Transaction
						RecLock( "DA3", .F.)
							DA3->DA3_INTEGR := If( aRet[1], "1", "2")
						DA3->( MsUnlock() )
					End Transaction
				EndIf
			
			EndIf
		EndIf
        
        oProcess:SetRegua1(8)
	EndIf
    oPagBem:Destroy()
    FwFreeObj(oPagBem)
	
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} IntForPGBEM()

@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Static Function IntForPGBEM( oProcess, cCodForLoj )

	Local lAltCad       := .F.
	Local oPagBem       := Nil
    Local aPagBem       := {}
    Local cCodFor       := ""
    Local cLoja         := ""
    Local cRnTrc        := ""

	Default oProcess	:= Nil
	Default lEnd		:= .F.
	Default cCodForLoj  := ""

    If !Empty( cCodForLoj )
        cCodFor       := SubStr( cCodForLoj, 1, TamSx3("A2_COD")[1] )
        cLoja         := SubStr( cCodForLoj, TamSx3("A2_COD")[1] + 1, TamSx3("A2_LOJA")[1] )

        oProcess:SetRegua1(1)
        
        oPagBem := TMSBCAPagBem():New()
        If oPagBem:Instaciado
			oProcess:SetRegua1(2)
			oProcess:IncRegua1(STR0004) // STR0004 "Autenticando na PagBem."
			
			oPagBem:Auth()
			
            oPagBem:GetLastError()
            oPagBem:GetErrorDescription()

			oProcess:SetRegua1(3)
			oProcess:IncRegua1(STR0005) // STR0005 "Verificando Token Ativo."
			
			aPagBem	:= oPagBem:IsTokenActive()
			
			oProcess:SetRegua1(4)
			If aPagBem[1]
				oProcess:IncRegua1( STR0016 ) // STR0016 "Obtendo dados do Motorista."
				
				If oPagBem:HiredInfo( cCodFor, cLoja )
					oProcess:SetRegua1(5)
					oProcess:IncRegua1(STR0017) // STR0017 "Verificando dados do Motorista no Sistema PagBem."
					
					cCGC := oPagBem:HiredCPF
					lAltCad := oPagBem:GetHired( cCGC )[1]
					
					cRnTrc := oPagBem:RNTRC
					oPagBem:GetHiredRNTRC( cRnTrc )
					
					aRet := oPagBem:PutHired( lAltCad )
					If aRet[1]
						oProcess:IncRegua1( STR0010 ) // STR0010 "Ajustes realizados no Sistema PagBem."
					Else
						cMsg := STR0011 + DecodeUTF8(aRet[3])
						Help( "", 1, STR0002, , cMsg, 1, 0, , , , , .T., { STR0012 } ) //STR0002"Integração TMS x PAGBEM"  STR0011"Ocorreu um problema na integração entre TMS Protheus e PAGBEM. "  "O cadastro no TMS Protheus será efetivado sem problemas, porém será necessario realizar a integração novamente."
					EndIf

				EndIf
			EndIf
			
			oProcess:SetRegua1(8)
		EndIf
		oPagBem:Destroy()
        FwFreeObj(oPagBem)
	EndIf
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} RetCardMot()

@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Function RetCardMot( cCodMot, lAtivo )

    Local aArea         := GetArea()
    Local aAreaDEG      := DEG->(GetArea())
    Local aAreaDA4      := DA4->(GetArea())
    Local aAreaDEL      := DEL->(GetArea())
    Local cSeek         := ""
    Local aRet          := {}

    Default cCodMot     := DA4->DA4_COD
    Default lAtivo      := .F.

    DbSelectArea("DEL")
    DEL->( DbSetOrder(2) ) // DEL_FILIAL, DEL_CODMOT, DEL_CODOPE, DEL_IDOPE
    
    If DEL->( DbSeek( xFilial( "DEL" ) + Padr(cCodMot, TamSx3("DEL_CODMOT")[1] ) + "03" ) )
        cSeek := FwxFilial( "DEL" ) + cCodMot + "03"
        While DEL->( !Eof() ) .AND. cSeek == DEL->( DEL_FILIAL + DEL_CODMOT + DEL_CODOPE ) .AND. If( lAtivo, DEL->DEL_STATUS == '1', .T. )

            AAdd( aRet, AllTrim( DEL->DEL_IDOPE ) )

            DEL->( DbSkip() )
        EndDo
    EndIf

    RestArea( aAreaDEL )
    RestArea( aAreaDA4 )
    RestArea( aAreaDEG )
    RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldVeiPgBE
Validação Veiculo na PAGBEM 
@type Static Function
@author Rafael Souza
@since 18/01/2022
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function VldVeiPgBE(cCodVei)

Local oPagBem       := Nil
Local aDados		:= {}
Local cMsg			:= ""
Local lRet			:= .T. 

Default cCodVei		:= ""

oPagBem := TMSBCAPagBem():New()
oPagBem:Auth()

aPagBem	:= oPagBem:IsTokenActive()

If aPagBem[1] .AND. !Empty( cCodVei )

	
	If oPagBem:VehicleInfo( cCodVei )

        aDados := oPagBem:GetVehicle()		
        
		If aDados[1] == .F. 
			cMsg := "veículo não cadastrado na PAGBEM."
			Help( "", 1, STR0002, ,cMsg, 1, 0 ) //STR0002"Integração TMS x PAGBEM"
			lRet := .F.
		EndIf
	EndIf
EndIf

oPagBem:Destroy()
FwFreeObj(oPagBem)
FwFreeArray(aDados)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldMotPgBE
Validação Motorista na PAGBEM 
@type Function
@author Rafael Souza
@since 24/01/2022
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function VldMotPgBE(cCodMot)

Local oPagBem       := Nil
Local aDadosMot		:= {}
Local cMsg			:= ""
Local lRet			:= .T. 
Local cCgcMot       := ""

Default cCodMot		:= ""

oPagBem := TMSBCAPagBem():New()
oPagBem:Auth()

aPagBem	:= oPagBem:IsTokenActive()

If aPagBem[1] .AND. !Empty( cCodMot )

	
	If oPagBem:DriverInfo( cCodMot )
        cCgcMot:= oPagBem:Drivr_CPF
        aDadosMot := oPagBem:GetDriver(cCgcMot)		
        
		If aDadosMot[1] == .F. 
			cMsg := DecodeUTF8(aDadosMot[3])
			Help( "", 1, STR0002, ,cMsg, 1, 0 ) //STR0002"Integração TMS x PAGBEM"
			lRet := .F.
		EndIf
	EndIf
EndIf

oPagBem:Destroy()
FwFreeObj(oPagBem)
FwFreeArray(aDadosMot)

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetToll()
Método para obter o valor do pedágio.

@author Rafael 
@since 24/01/2022
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetToll(cRota, nQtdEix ) CLASS TMSBCAPagBem

Local aHeaderStr:= {}
Local cParams   := ""
Local oResponse := Nil
Local cPath     := "/api/rotas/"
Local cPath2    := "/calcular/eixos/"
Local aRet      := { .F., "" }
Local nErros    := 0
Local nX        := 0
Local cMsg      := ""
Local nLenPdg   := 0
Local aDados    := {}
Local aResult   := {}

Default cRota   := ""
Default nQtdEix := 0

::rest_client       := FwRest():New( ::Self:url_token )

Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )
Aadd( aHeaderStr, "CNPJContratante : " +  ::CNPJContr )

If !Empty( cRota )
    cPath := cPath + AllTrim(cRota)  + cPath2 + cValToChar(nQtdEix)
EndIf

aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

If aResult[1]
    
    lRet    := FWJsonDeserialize( aResult[2], @oResponse )

    If lRet .And. ValType( oResponse ) == "O"
        If oResponse:IsSucesso
            If AttIsMemberOf( oResponse, "Resultado" )
            
                If AttIsMemberOf( oResponse:Resultado, "pracasPedagios" )
                    
                    nLenPdg := Len(oResponse:resultado:pracasPedagios)
                    If nLenPdg > 0
                        For nX := 1 To nLenPdg
                            AAdd( aDados, { oResponse:resultado:pracasPedagios[nLenPdg]:idPracaPedagio, oResponse:resultado:pracasPedagios[nLenPdg]:numeroSequencia, oResponse:resultado:pracasPedagios[nLenPdg]:concessionaria,;
                                            oResponse:resultado:pracasPedagios[nLenPdg]:pracaPedagio, oResponse:resultado:pracasPedagios[nLenPdg]:valorPedagio, oResponse:resultado:pracasPedagios[nLenPdg]:ufPracaPedagio } )
                        Next nX
                    EndIf
                EndIf
                
                If AttIsMemberOf(oResponse:Resultado,"pedagioTotal")
                    nValTotPdg := oResponse:resultado:pedagioTotal
                EndIf 

                aRet := { oResponse:IsSucesso, { AClone(aDados) }, nValTotPdg,"" }
            EndIf
        Else
            // Não achei o numero do cartão
            nErros := Len( oResponse:Erros )
            If nErros > 0
                
                For nX := 1 To nErros
                    cMsg += oResponse:Erros[nX]:Mensagem
                Next nX

                aRet := { oResponse:IsSucesso, {}, cMsg }
            EndIf
        EndIf
    EndIf
Else
    aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
EndIf

FwFreeArray(aHeaderStr)
FwFreeArray(aDados)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} PagBemPdg
Retorna o Valor do pedágio na PAGBEM para gravar na DTR 
@type Function
@author Rafael Souza
@since 24/01/2022
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------

Function PagBemPdg(cRotaVge,nQtdEix)

Local nValPdg   := 0
Local oPagBem   := Nil
Local aDadosPdg := {}

Default cRotaVge := ""
Default nQtdEix  := 0

oPagBem := TMSBCAPagBem():New()
oPagBem:Auth()

aPagBem	:= oPagBem:IsTokenActive()

If aPagBem[1] .And. !Empty(cRotaVge) .And. nQtdEix > 0
    aDadosPdg := oPagBem:GetToll( cRotaVge, nQtdEix )

    If !aDadosPdg[1]
        cMsg := DecodeUTF8(aDadosPdg[3])
        nValPdg := 0
    else
        nValPdg := aDadosPdg[3] //--Valor Total do pedágio
    EndIf

EndIf

FwFreeObj(oPagBem)

Return nValPdg

//-----------------------------------------------------------------
/*/{Protheus.doc} PutLibViagem()
Método para Liberar a Viagem na PAGBEM.

@author Rafael 
@since 17/02/2022
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PutLibViagem(cIdViagem) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local cPath     := "/api/viagens/"+cIdViagem+"/liberar" //--DTR_PRCTRA
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local aResult   := {}

    Default cIdViagem  := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    aResult := ::Put( cPath, AClone( aHeaderStr ) )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                aRet := { oResponse:IsSucesso, "Viagem Liberada", "" }
            Else
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutBlqViagem()
Método para Bloquear a Viagem na PAGBEM.

@author Rafael 
@since 17/02/2022
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PutBlqViagem(cIdViagem) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local cPath     := "/api/viagens/"+cIdViagem+"/bloqueia" //--DTQ_IDOPE
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local cBody     := ""
    Local oBody     := JsonObject():New()
    Local aResult   := {}

    Default cIdViagem  := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    oBody["motivo"]         := "ErroLancamento"
    oBody["observacao"]     := ""
   
    cBody   := oBody:ToJson()

    aResult := ::Put( cPath, AClone( aHeaderStr ) , cBody)

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                aRet := { oResponse:IsSucesso, "Viagem Bloqueada", "" }
            Else
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutUnlockVge()
Método para Desbloquear uma viagem bloqueada anteriormente na PAGBEM

@author Rafael 
@since 18/02/2022
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PutUnlockVge(cIdViagem) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local cPath     := "/api/viagens/"+cIdViagem+"/desbloqueia" //--DTQ_IDOPE
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local cBody     := ""
    Local oBody     := JsonObject():New()
    Local aResult   := {}

    Default cIdViagem  := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    oBody["motivo"]         := "ViagemCorrigida"
    oBody["observacao"]     := ""
   
    cBody   := oBody:ToJson()

    aResult := ::Put( cPath, AClone( aHeaderStr ) , cBody)

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                aRet := { oResponse:IsSucesso, "Viagem Desbloqueada", "" }
            Else
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} Log()
Salva mensagens em arquivos de Log

@author Daniel Leme
@since 08/03/2022
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Log(cMsg,lRetorno) CLASS TMSBCAPagBem    

    If ::IsLogActive
        MemoWrite(::cPATHLOG+AllTrim(Procname(2))+;
                    Dtos(dDatabase)+AllTrim(Str(Seconds()))+;
                    AllTrim(AllToChar(ThreadID()))+;
                    Iif(lRetorno,"_RET","")+".JSon",cMsg)
    EndIf

Return .T.

//------------------------------------------------------------------- 
/*{Protheus.doc} PagBIncRot
Tela para inclusão de Rota PagBem
@type Function
@author Daniel Leme
@since 20/02/2022
@version 12.130
*/
//-------------------------------------------------------------------
Function PagBIncRot( cRota, cCdrOri, cCdrDes)

Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local oDlgEsp
Local aHeadEsp  := {}
Local aColEsp   := {}
Local nOpcao    := 0
Local nI
Local aRet

Local cCbOri    := ""
Local cCEPOri   := CriaVar("A1_CEP",.T.)
Local oComboOri := Nil
Local cCbDes    := ""
Local cCEPDes   := CriaVar("A1_CEP",.T.)
Local oComboDes := Nil
Local cMunOri   := CriaVar( "CC2_MUN", .T. )
Local cMunDes   := CriaVar( "CC2_MUN", .T. )
Local cRouteName:= Criavar( "DA8_DESC", .T. )
Local cVldPto   := "Eval({|| Iif(Empty(CDRPTO) .Or. ExistCpo('DUY',CDRPTO),"+;
				   "(GdFieldPut('DESPTO', Posicione( 'DUY', 1, xFilial('DUY') + CDRPTO, 'DUY_DESCRI' ),"+;
                   "             oGetSub:oBrowse:nAt, oGetSub:aHeader, oGetSub:aCols), .T.),"+;
				   "											.F.) })"

Default cRota     := ""
Default cCdrOri   := CriaVar("DUY_GRPVEN",.T.)
Default cCdrDes   := CriaVar("DUY_GRPVEN",.T.)

//-- Monta aHeader Manual
Aadd( aHeadEsp, { ""           , "UP"    , "@BMP"                      , 1                      , 0, ;
              , , "" , ""   , "" , "", "'UP'" } )
Aadd( aHeadEsp, { ""           , "DOWN"  , "@BMP"                      , 1                      , 0, ;
              , , "" , ""   , "" , "", "'DOWN'" } )
Aadd( aHeadEsp, { "Tipo Ponto" , "TIP"   , "@!"                        , 1                      , 0, ;
              , , "C",      , "V","1=CEP;2=Região" ,"'1'" ,"" , "A", , , } ) 
Aadd( aHeadEsp, { "CEP"        , "CEPPTO", PesqPict("SA1","A1_CEP")    , TamSX3("A1_CEP")[1]    , 0, ;
              , , "C",      , "V", , , , "A", , , } )
Aadd( aHeadEsp, { "Região"     , "CDRPTO", PesqPict("DUY","DUY_GRPVEN"), TamSX3("DUY_GRPVEN")[1], 0, ;
              cVldPto, , "C", "DUY", "V", , , , "A", , , } ) 
Aadd( aHeadEsp, { "Descrição"  , "DESPTO", PesqPict("DUY","DUY_DESCRI"), TamSX3("DUY_DESCRI")[1], 0, ;
              , , "C", ""   , "V", , , , "V", , , } ) 

//-- Monta Linha em branco do aCols Manualmente
aAdd( aColEsp, { "UP",;
                 "DOWN",;
                 "1",;
                 CriaVar("A1_CEP",.T.), ;
                 CriaVar( "DUY_GRPVEN", .T. ),;
                 Space( TamSX3("DUY_DESCRI")[1]),;
                  .T. } )

//-- Dimensoes padroes
aSize   := MsAdvSize(.T.)

//-- Reduz a tela em aproximadamente 15%
aEval( aSize, { | nSize, y | If( nSize > 0, aSize[y] := Int( nSize / 1.13 ), Nil ) } )

//-- Dimensiona os objetos
AAdd( aObjects, { 100, 002, .T., .T. } )
AAdd( aObjects, { 100, 028, .T., .T. } )
AAdd( aObjects, { 100, 070, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

//--Inicializa nome da Rota
If Type("M->DA8_DESC") == "C" .And. !Empty(M->DA8_DESC)
    cRouteName := AllTrim(M->DA8_DESC)
EndIf 
//-- Inicializa Região de Origem
If !Empty(cCdrOri)
 	cMunOri := Posicione( "DUY", 1, xFilial("DUY") + cCdrOri, "DUY_DESCRI" )
    cCbOri  := STR0025 //"2-Região"
EndIf
//-- Inicializa Região de Destino
If !Empty(cCdrDes)
	cMunDes := Posicione( "DUY", 1, xFilial("DUY") + cCdrDes, "DUY_DESCRI" )
    cCbDes  := STR0025 //"2-Região"
EndIf

DEFINE MSDIALOG oDlgEsp TITLE STR0028 FROM aSize[7], 00 TO aSize[6], aSize[5] PIXEL //--'Solicitação de Rota'

    //-- NOME ROTA: Campo ROTA 
	@ aPosObj[2,1]  ,aPosObj[2,2]     SAY "Rota" Of oDlgEsp PIXEL  SIZE 020,009 //--"CEP"
	@ aPosObj[2,1]  ,aPosObj[2,2]+030 MsGet cRouteName ;
											PICTURE PesqPict('DA8','DA8_DESC')   ;
                                            SIZE 180,007 OF oDlgEsp PIXEL

    //-- ORIGEM: Seleção de tipo de Origem PagBem (CEP ou Cód Municipio)
	@ aPosObj[2,1]+13,aPosObj[2,2]     SAY STR0030 Of oDlgEsp PIXEL  SIZE 020,009 //--'Origem'
    @ aPosObj[2,1]+13,aPosObj[2,2]+30  COMBOBOX oComboOri VAR cCbOri ITEMS {STR0024,STR0025} ;//"1-CEP","2-Região"
                           Of oDlgEsp PIXEL  SIZE 080,009
    //-- ORIGEM: Campo CEP 
	@ aPosObj[2,1]+26,aPosObj[2,2]     SAY STR0021 Of oDlgEsp PIXEL  SIZE 020,009 //--"CEP"
	@ aPosObj[2,1]+26,aPosObj[2,2]+030 MsGet cCEPOri ;
											PICTURE PesqPict('SA1','A1_CEP')   ;
                                            WHEN Left(cCbOri,1) == "1" SIZE 020,007 OF oDlgEsp PIXEL
    //-- ORIGEM: Campos Região/Descrição  
	@ aPosObj[2,1]+39,aPosObj[2,2]     SAY STR0029 Of oDlgEsp PIXEL  SIZE 029,009 //"Reg.Origem"
	@ aPosObj[2,1]+39,aPosObj[2,2]+030 MsGet cCdrOri F3 "DUY" Valid Eval({|| Iif(Empty(cCdrOri) .Or. ExistCpo("DUY",cCdrOri),;
																(cMunOri := Posicione( "DUY", 1, xFilial("DUY") + cCdrOri, "DUY_DESCRI" ), .T.),;
																.F.) });
											PICTURE PesqPict('DUY','DUY_GRPVEN') ;
                                            WHEN Left(cCbOri,1) == "2" SIZE 035,007 OF oDlgEsp PIXEL
	@ aPosObj[2,1]+39,aPosObj[2,2]+070 MsGet cMunOri ;
											PICTURE PesqPict('CC2','CC2_MUN') WHEN .F. SIZE 110,007 OF oDlgEsp PIXEL


    //-- DESTINO: Seleção de tipo de Destino PagBem (CEP ou Cód Municipio)
	@ aPosObj[2,1]+13,aPosObj[2,2]+240 SAY STR0020 Of oDlgEsp PIXEL  SIZE 020,009 //--'Destino'
    @ aPosObj[2,1]+13,aPosObj[2,2]+270  COMBOBOX oComboDes VAR cCbDes ITEMS {STR0024,STR0025} ; //"1-CEP","2-Região"
                           Of oDlgEsp PIXEL  SIZE 080,009
    //-- DESTINO: Campo CEP 
	@ aPosObj[2,1]+26,aPosObj[2,2]+240 SAY STR0021 Of oDlgEsp PIXEL  SIZE 020,009 //--"CEP"
	@ aPosObj[2,1]+26,aPosObj[2,2]+270 MsGet cCEPDes ;
											PICTURE PesqPict('SA1','A1_CEP')   ;
                                            WHEN Left(cCbDes,1) == "1" SIZE 020,007 OF oDlgEsp PIXEL
    //-- DESTINO: Campos Região/Descrição  
	@ aPosObj[2,1]+39,aPosObj[2,2]+240 SAY STR0022 Of oDlgEsp PIXEL  SIZE 029,009 //--"Reg.Destino"
	@ aPosObj[2,1]+39,aPosObj[2,2]+270 MsGet cCdrDes F3 "DUY" Valid Eval({|| Iif(Empty(cCdrDes) .Or. ExistCpo("DUY",cCdrDes),;
																(cMunDes := Posicione( "DUY", 1, xFilial("DUY") + cCdrDes, "DUY_DESCRI" ), .T.),;
																.F.) });
											PICTURE PesqPict('DUY','DUY_GRPVEN') ;
                                            WHEN Left(cCbDes,1) == "2" SIZE 035,007 OF oDlgEsp PIXEL
	@ aPosObj[2,1]+39,aPosObj[2,2]+310 MsGet cMunDes PICTURE PesqPict('CC2','CC2_MUN') WHEN .F. SIZE 110,007 OF oDlgEsp PIXEL

    //-- TRAJETO: Dados do trajeto
	@ aPosObj[3,1],aPosObj[2,2] SAY STR0023 Of oDlgEsp PIXEL  SIZE 100,009  //-- "Detalhes do Trajeto"

	//MSNewGetDados():New(                     nTop,        nLeft,      nBottom,       nRight,                        nStyle ,      uLinhaOk,       uTudoOk, cIniCpos, aAlter, nFreeze, nMax, cFieldOk, uSuperDel ,  uDelOk, oWnd   , aParHeader, aParCols)
	oGetSub := MSNewGetDados():New( aPosObj[3,1]+10, aPosObj[3,2], aPosObj[3,3], aPosObj[3,4],  GD_INSERT+GD_UPDATE+GD_DELETE, "AllWaysTrue", "AllWaysTrue",       ,       ,        0, 9999,         ,           ,      "AllWaysTrue", oDlgEsp, aHeadEsp, aColEsp)
	oGetSub:oBrowse:bLDblClick := { |a,nCol| If( nCol==1, If( oGetSub:oBrowse:nAt > 1, ;
															(aAux := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt]),;
															oGetSub:aCols[oGetSub:oBrowse:nAt]   := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt-1]),;
															oGetSub:aCols[oGetSub:oBrowse:nAt-1] := aClone(aAux),;
															oGetSub:oBrowse:nAt-- ,;
															oGetSub:oBrowse:Refresh(.T.) ), Nil ), ;
														  If( nCol == 2, If(oGetSub:oBrowse:nAt < Len(oGetSub:aCols),;
																(aAux := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt]),;
																oGetSub:aCols[oGetSub:oBrowse:nAt] := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt+1]),;
																oGetSub:aCols[oGetSub:oBrowse:nAt+1] := aClone(aAux),;
																oGetSub:oBrowse:nAt++,;
																oGetSub:oBrowse:Refresh(.T.) ), Nil ), oGetSub:EditCell() ) ) }

ACTIVATE MSDIALOG oDlgEsp  CENTERED ON INIT EnchoiceBar( oDlgEsp, { || If( oGetSub:TudoOk(), ( nOpcao := 1, oDlgEsp:End() ), .F. ) }, { || oDlgEsp:End() }, , )

If nOpcao == 1
    oObj := TMSBCAPagBem():New()
    oObj:Auth()
    oObj:RouteName := cRouteName 
    oObj:RouteOri  := {Left(cCbOri,1),Iif(Left(cCbOri,1) == "1",cCEPOri,cCdrOri)}
    oObj:RouteDes  := {Left(cCbDes,1),Iif(Left(cCbDes,1) == "1",cCEPDes,cCdrDes)}
    oObj:RoutePtos := {} 
	For nI := 1 To Len(oGetSub:aCols)
		If !GdDeleted( nI, oGetSub:aHeader, oGetSub:aCols ) 
            aAdd(oObj:RoutePtos,{GdFieldGet( "TIP", nI, , oGetSub:aHeader, oGetSub:aCols ),;
                                 Iif(Left(GdFieldGet( "TIP", nI, , oGetSub:aHeader, oGetSub:aCols ),1)== "1",;
                                     GdFieldGet( "CEPPTO", nI, , oGetSub:aHeader, oGetSub:aCols ),;
                                     GdFieldGet( "CDRPTO", nI, , oGetSub:aHeader, oGetSub:aCols )) })
		EndIf
	Next nI
		
	MsgRun( STR0026, STR0027, ; //--"Realizando comunicação com a Operadora...", "Aguarde..."
            { || CursorWait(),  ;
                 aRet := oObj:PostRoute(),;
                 oObj:Destroy(),;
                 FwFreeObj(oObj) ,;
                 CursorArrow() } ) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
	
    If !aRet[1]
        Help( "", 1, STR0002, , aRet[3], 1, 0, , , , , .T., { STR0012 } ) //STR0002"Integração TMS x PAGBEM"  STR0011"Ocorreu um problema na integração entre TMS Protheus e PAGBEM. "  "O cadastro no TMS Protheus será efetivado sem problemas, porém será necessario realizar a integração novamente."    EndIf
    EndIf
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} fRemDest()

@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Function fRemDest( cCliRem, cLojRem, cCliDes, cLojDes, aDT6)
	Local aArea     := GetArea()

	If Len(aDT6) > 0
        cCliRem := aDT6[1][4]
        cLojRem := aDT6[1][5]
        cCliDes := aDT6[Len(aDT6)][6]
        cLojDes := aDT6[Len(aDT6)][7]
	EndIf
	RestArea(aArea)

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} PgBContrat()

@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Function PgBContrat( cFilOri, cViagem, nOpcx, aMsgErr, cContrat, cNumIdOpe, cNumIdPdg, cItemDTR, cNumCIOT, lCancCiot, lIncCiot )

    Local aArea     := GetArea()
    Local aAreaDTQ  := DTQ->(GetArea() )
    Local aAreaDTR  := DTR->(GetArea() )
    Local aAreaDUP  := DUP->(GetArea() )
    Local aAreaDJL  := DJL->(GetArea() )
    Local aRetForn  := {}
    Local cTipVeiFor:= ""
    Local cCodReg   := ""
    Local nY        := 0
    Local lTipOpVg  := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
    Local lRet      := .T.
    Local lDelViagem:= .F.
    Local lDelPdg   := .F.
    Local oPagBem   := Nil
    Local lCiotAgre := .F.
    Local dDtFimVgm := dDataBase
    Local cCodMot   := ""
    Local cIDOPE    := ""
    Local nQtdTar   := 0
    Local nVlrTar   := 0

    Default cFilOri     := ""
    Default cViagem     := ""
    Default cContrat    := ""
    Default nOpcx       := 3
    Default aMsgErr     := {}
    Default cNumIdOpe   := ""
    Default cNumIdPdg   := ""
    Default cItemDTR    := ""
    Default cNumCIOT    := ""
    Default lCancCiot   := .F.
    Default lIncCiot    := .F.
    
    DTQ->( DbSetOrder(1) )
    If DTQ->( DbSeek( xFilial('DTQ') + cViagem ) )
        
        oPagBem := TMSBCAPagBem():New()
        oPagBem:Auth()
        aPagBem	:= oPagBem:IsTokenActive()

        cCodForn    := DTR->DTR_CODFOR
        cLojForn    := DTR->DTR_LOJFOR
        cCodOpe     := DTR->DTR_CODOPE
        cCodVeiFor  := DTR->DTR_CODVEI
        lCiotAgre   := DTR->DTR_TPCIOT == '2'

        //| Obtém o código do tipo do veículo
        cTipVeiFor  := POSICIONE( "DA3", 1, FWxFilial("DA3")+ cCodVeiFor , "DA3_TIPVEI")
        
        //| busca o contrato considerando o tipo de veículo da viagem
        aRetForn    := TMSContrFor( cCodForn, cLojForn, , DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA, .F., cTipVeiFor, If( lTipOpVg, DTQ->DTQ_TPOPVG, '' ) )

        //| busca o contrato sem considerar o veículo
        If Len(aRetForn) <= 0
            aRetForn := TMSContrFor( cCodForn, cLojForn, , DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA, .F., , If( lTipOpVg, DTQ->DTQ_TPOPVG, '' ) )
        EndIf

        If Len(aRetForn) > 0
            For nY := 1 To Len( aRetForn )
                If Len( aRetForn[nY] ) >= 20 .AND. !Empty( aRetForn[nY][20] )
                    cCodReg := aRetForn[nY][20]
                EndIf
            Next nY
        EndIf

        If aPagBem[1]
            If nOpcx <> 5

                If lCiotAgre
                    DbSelectArea("DUP")
                    DUP->( DbSetOrder(1) ) // DUP_FILIAL, DUP_FILORI, DUP_VIAGEM, DUP_ITEDTR, DUP_CODMOT
                    If DUP->( DbSeek( xFilial("DUP") + cFilOri + cViagem + DTR->DTR_ITEM ) )
                        cIDOPE  := DUP->DUP_IDOPE
                        cCodMot := DUP->DUP_CODMOT
                    EndIf

                    DbSelectArea("SA2")
                    SA2->( DbSetOrder(1) )
                    If SA2->( DbSeek( xFilial("SA2") + DTR->DTR_CODFOR + DTR->DTR_LOJFOR ) )
                        cCGC    := AllTrim( SA2->A2_CGC )
                        cRNTRC  := AllTrim( SA2->A2_RNTRC )
                    EndIf
                    
                    aVeic       := RetPlaca( cCodVeiFor, DTR->DTR_CODRB1, DTR->DTR_CODRB2, DTR->DTR_CODRB3, cRNTRC )//{ { "MFR4485", cRNTRC }, { "QHD1050", cRNTRC } }
                    dDtFimVgm   := DTR->DTR_DTFMCI // Data do Planejamento
                    nQtdTar     := DTR->DTR_QTDSAQ + DTR->DTR_QTDTRA
                    cCodBco     := RetCodBan( cCodMot, cIDOPE, cFilOri, cViagem, "03"   )
                    nVlrTar     := RetTaxTot( cCodBco, DTR->DTR_QTDSAQ, DTR->DTR_QTDTRA )
                    // 1º Verifico se é ciot por periodo e, caso positivo, verifico se na DJL existe CIOT Aberto.
                    //      Se não existir em aberto, chamar a API para inclusão do CIOT e salva na DJL.
                    // 2º utilizar a API de viagem do CIOT agregado.
                    cNumCiot := TmsCiotPer( cCodVeiFor, cCodOpe )
                    If Empty(cNumCiot)
                        lRet    := oPagBem:PostCiotA( cCGC, cRNTRC, aVeic, dDtFimVgm, nQtdTar, nVlrTar )
                        If lRet
                            cNumCiot := oPagBem:NumCiotAg
                            lIncCIOT := .T.
                        EndIf
                    EndIf

                EndIf

                If lRet .AND. oPagBem:PostTravel( .T., cCodReg, cItemDTR, lCiotAgre, cNumCiot, nQtdTar, nVlrTar )
                    cNumIdOpe    := oPagBem:IdFrete
                    cNumCiot     := oPagBem:CIOT
                Else
                    lRet := .F.
                    AAdd( aMsgErr, { STR0037, '06', } ) // STR0031 "Não foi possivel realizar a integração do contrato de Frete no Sistema PagBem."
                    AAdd( aMsgErr, { STR0032 + oPagBem:last_error, '06',  } ) // STR0032 "Erro Sistema PagBem: "
                    AAdd( aMsgErr, { STR0033 + cViagem + STR0034, '06', } ) // STR0033 "Devido ao erro na integração entre TMS Protheus e PagBem a viagem " STR0034 " não será Fechada."
                    If lIncCIOT
                        lCancCiot    := oPagBem:DelCiotA( cNumCiot )
                        If !lCancCiot
                            AAdd( aMsgErr, { STR0032 + oPagBem:last_error, '06',  } ) // STR0032 "Erro Sistema PagBem: "
                        EndIf
                    EndIf
                EndIf

                If lRet .AND. oPagBem:ContrPDG .And. DTR->DTR_VALPDG != 0  
                    //-- Inclui a viagem no Sistema PagBem na segunda vez pelo Pedagio.
                    If oPagBem:PostTravel( .F., cCodReg, cItemDTR )
                        cNumIdPdg   := oPagBem:IdPedagio
                    Else
                        lRet    := .F.
                        lDelViagem  := oPagBem:DelTravel( cNumIdOpe )

                        AAdd( aMsgErr, { STR0031, '06', } ) // STR0031 "Não foi possivel realizar a integração do contrato de Pedagio no Sistema PagBem."
                        AAdd( aMsgErr, { STR0032 + oPagBem:last_error, '06', } ) // STR0032 "Erro Sistema PagBem: "

                        If lDelViagem
                            cNumIdOpe    := ""
                            AAdd( aMsgErr, { STR0033 + cViagem + STR0034, '06', } ) // STR0033 "Devido ao erro na integração entre TMS Protheus e PagBem a viagem " STR0034 " não será Fechada."
                        Else
                            AAdd( aMsgErr, { STR0035 + cViagem + STR0036 + cNumIdOpe, '06', } ) // STR0035 "Não foi possivel cancelar a inclusão do Contrato de Frete no Sistema PagBem, e por este motivo a Viagem " STR0036 "  não será Fechada. ID: "
                            AAdd( aMsgErr, { STR0033 + cViagem + STR0034, '06', } ) // STR0037" não será Fechada."
                        EndIf
                    EndIf
                EndIf

                If !Empty( cNumIdOpe ) .AND. lRet
                    RecLock( "DTR", .F. )
                        DTR->DTR_PRCTRA := cNumIdOpe
                        DTR->DTR_IDPDG  := cNumIdPdg
                        DTR->DTR_CIOT   := cNumCiot
                    DTR->( MsUnlock() )

                    If lIncCIOT .AND. lCiotAgre .AND. !lCancCiot
                        TMSXJCiot( lIncCIOT, cNumCiot, cCodVeiFor, DTR->DTR_DTFMCI, "1" ) // 1=Aberto; 2=Fechado; 3=Encerrado; 9=Cancelado
                    EndIf
                EndIf
                
            Else

                If oPagBem:GetTravel( cNumIdOpe )

                    lDelViagem  := oPagBem:DelTravel( cNumIdOpe )
                    //Estorno do Fechamento Validar:
                    //1º valida se não existem outras viagens já fechadas no CIOT, se não houver, cancela o CIOT (API de deleção) e a tabela DJL.
                    If lCiotAgre
                        lHasViaFec := RetCanCiot( cFilOri, cViagem, cNumCiot, cCodOpe )
                    EndIf

                    If lDelViagem .AND. lCiotAgre .AND. !lHasViaFec
                        lCancCiot    := oPagBem:DelCiotA( DTR->DTR_CIOT )
                        cNumCIOT    := DTR->DTR_CIOT
                    EndIf

                    If !Empty( cNumIdPdg ) .And. lDelViagem
                        cNumIdOpe   := ""
                        lDelPdg     := oPagBem:DelTravel( cNumIdPdg )
                        lRet        := lDelPdg

                        If !lDelPdg
                            AAdd( aMsgErr, { STR0038, '06', } ) // STR0038 "Não foi possivel realizar o cancelamento do contrato de Pedagio no Sistema PagBem."
                            AAdd( aMsgErr, { STR0032 + oPagBem:last_error, '06', } )
                            AAdd( aMsgErr, { STR0039 + cViagem + STR0040, '06', } ) // STR0039 "Devido ao erro na integração entre TMS Protheus e PagBem o Fechamento da viagem " STR0040 " não será Estornado."
                        EndIf
                    ElseIf !lDelViagem
                        lRet := .F.
                        AAdd( aMsgErr, { STR0041, '06', } ) // STR0041 "Não foi possivel realizar o cancelamento do contrato de Frete no Sistema PagBem."
                        AAdd( aMsgErr, { STR0032 + oPagBem:last_error, '06', } )
                        AAdd( aMsgErr, { STR0039 + cViagem + STR0040, '06', } ) // STR0039 "Devido ao erro na integração entre TMS Protheus e PagBem o Fechamento da viagem " STR0040 " não será Estornado."
                    EndIf

                    If lDelViagem .And. lRet
                        RecLock( "DTR", .F. )
                            
                            DTR->DTR_PRCTRA := ""
                            DTR->DTR_CIOT   := ""

                            If !Empty( cNumIdPdg ) .AND. lDelPdg
                                DTR->DTR_IDPDG  := ""
                            EndIf

                        DTR->( MsUnlock() )

                        // Limpo os campos de Valores Previstos Para os Impostos.
                        GrvImpDTR( FwXFilial( "DTR" ) + cFilOri + cViagem + cItemDTR , .T. )

                        If lCancCiot .AND. lCiotAgre
                            TMSXJCiot( .F., cNumCiot, cCodVeiFor, DTR->DTR_DTFMCI, "9" ) // 1=Aberto; 2=Fechado; 3=Encerrado; 9=Cancelado
                        EndIf

                    EndIf
                Else
                    lRet := .F.
                    AAdd( aMsgErr, { STR0041, '06', } ) // STR0041 "Não foi possivel realizar o cancelamento do contrato de Frete no Sistema PagBem."
                    AAdd( aMsgErr, { STR0032 + oPagBem:last_error, '06', } )
                    AAdd( aMsgErr, { STR0039 + cViagem + STR0040, '06', } ) // STR0039 "Devido ao erro na integração entre TMS Protheus e PagBem o Fechamento da viagem " STR0040 " não será Estornado."
                EndIf

            EndIf
        EndIf
    EndIf

    FwFreeObj(oPagBem)

    RestArea(aAreaDJL)
    RestArea(aAreaDUP)
    RestArea(aAreaDTR)
    RestArea(aAreaDTQ)
    RestArea(aArea)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSJIsPgB
Verifica se para a viagem o contrato de carreteiro já foi criado.

@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Function TMSJIsPgB( cFilOri, cViagem )

    Local aArea     := GetArea()
    Local aAreaDTR  := DTR->( GetArea() )
    Local aAreaDTY  := DTY->( GetArea() )
    Local lRet      := .F.

    Default cFilOri:= ""
    Default cViagem:= ""

    DTR->( DbSetOrder(1) ) //-- DTR_FILIAL + DTR_FILORI + DTR_VIAGEM + DTR_ITEM
    DTY->( DbSetOrder(2) ) //-- DTY_FILIAL, DTY_FILORI, DTY_VIAGEM, DTY_NUMCTC
    If DTR->( DbSeek( xFilial("DTR") + cFilOri + cViagem ) ) .AND. DTR->DTR_CODOPE == '03' .AND. !DTY->( DbSeek( xFilial("DTY") + cFilOri + cViagem ) )
        lRet:= .T.
    EndIf

    RestArea(aArea)
    RestArea(aAreaDTR)
    RestArea(aAreaDTY)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSJPrCon
Faz uma Preview do Contrato para obter os valores de impostos, para 
enviar ao Sistema da PagBem.

@author  	Rodrigo Pirolo
@version 	P12
@build		
@since		15/12/2021
@return 	lRet
*/
//--------------------------------------------------------------------

Function TMSJPrCon( cFilOri, cViagem )

    Local aArea     := GetArea()
    Local aAreaDTR  := DTR->( GetArea() )
    Local aAreaSA2  := SA2->( GetArea() )
    Local aAreaDA3  := DA3->( GetArea() )
    Local bWhileVei := { || .T. }
    Local lPaMovBco	:= .F.
    Local cSeekVei  := ""
    Local cTipCTC   := Padr( SuperGetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
    Local cTmsErp    := SuperGetMV("MV_TMSERP",,'0')
    Local cTipCont  := "1" // por viagem
    Local cbxTitPDG := ""
    Local cTitNDF   := "2" //--(1=Sim;2=Não)
    Local cMomTitPDG:= "1"
    Local cMomTitAdi:= ""
    Local cCodFav   := ""
    Local cLojFav   := ""
    Local cFilAtu   := cFilAnt
    Local cTabFre   := ""
    Local cTipTab   := ""
    Local cTabCar   := ""
    Local cGerTitPDG:= "1"
    Local cDedPDG   := "2"
    Local cTpVeiculo:= ""
    Local cFrovei   := ""
    Local cCodForn  := ""
    Local cLojForn  := ""
    Local cCodVei   := ""
    Local cNatuCTC	:= ""
    Local cFilVge 	:= ""
    Local cNumVge 	:= ""
    Local cFilDeb   := ""
    Local cGerPC    := ""
    Local cTitFrete := ""
    Local cContrat  := "SimuTmsxfunj"
    Local nCnt      := 0
    Local nCntFor   := 0
    Local nGerContr := 1
    Local nValFrete := 0
    Local nBasImp   := 0
    Local nQtdOco   := 0
    Local nPesOco   := 0
    Local nQtdDoc   := 0
    Local nDiaSem   := 0
    Local nDiaFimSem:= 0
    Local nQtdKm    := 0
    Local nGrupVei  := 0
    Local nTotValAdi:= 0
    Local nValPedag := 0
    Local nValIRRF  := 0
    Local nValINSS  := 0
    Local nValSEST  := 0
    Local nValISS   := 0
    Local nValRetPIS:= 0
    Local nValRetCOF:= 0
    Local nValRetCSL:= 0
    Local nAcresc   := 0
    Local nDecresc  := 0
    Local nVlrReem  := 0
    Local nTotAdiNDF:= 0
    Local nMaxCus   := 0
    Local aFrete    := {}
    Local aDiaHist  := {}
    Local aMsgErr   := {}
    Local aDadosCTC := {}
    Local a250Frete := {}
    Local aFornec   := {}
    Local aRet      := {} 

    Private lGerTit := SuperGetMV( 'MV_GERTIT', , .T. ) // Verifica se devera gerar ou nao contas a pagar (SE2). Esta variavel e' Private, pois pode ser manipulada em algum PE. NAO RETIRAR !!!
    Private lF050Auto:= .F.
    Private nOldValor := 0
    Private nOldIrr   := 0
    Private nOldIss   := 0
    Private nOldInss  := 0
    Private nOldSEST  := 0
    Private nValDig   := 0
    Private aAutoCab  := {}

    Default cFilOri := ""
    Default cViagem := ""

    DA3->( DbSetOrder(1) )
    SA2->( DbSetOrder(1) )
    DTR->( DbSetOrder(1) )
    cSeekVei  := xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
    bWhileVei := { || DTR->(! Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM == cSeekVei }

    If DTR->( MsSeek( cSeekVei ) )

        While Eval( bWhileVei )

            If nGerContr == 1 //Gera Contrato para o Veiculo.
                If DA3->(MsSeek(xFilial('DA3')+ DTR->DTR_CODVEI))
                    If !Empty(DTR->DTR_CODFOR) .And. !Empty(DTR->DTR_LOJFOR)
                        cCodForn := DTR->DTR_CODFOR
                        cLojForn := DTR->DTR_LOJFOR
                    Else
                        cCodForn := DA3->DA3_CODFOR
                        cLojForn := DA3->DA3_LOJFOR
                    EndIf
                    If Ascan( aFornec, { |x| x[1]+x[2] == cCodForn + cLojForn } ) == 0
                        Aadd( aFornec, { cCodForn, cLojForn, DA3->DA3_COD, DA3->DA3_FROVEI, DA3->DA3_TIPVEI, 0 } )
                    EndIf
                EndIf
            EndIf

            // Carrega variaveis
            For nCnt := 1 To Len( aFornec )

                cTabFre    := ''
                cTipTab    := ''
                cTabCar    := ''
                nValFrete  := 0
                nBasImp    := 0
                nQtdOco    := 0
                nPesOco    := 0
                nQtdDoc    := 0
                nDiaSem    := 0
                nDiaFimSem := 0
                nQtdKm     := 0
                lRet       := .T.
                cGerTitPDG := "1"
                cDedPDG    := "2"

                cCodForn   := aFornec[ nCnt, 1 ]
                cLojForn   := aFornec[ nCnt, 2 ]
                cCodVei    := aFornec[ nCnt, 3 ]
                cFrovei    := aFornec[ nCnt, 4 ]
                cTpVeiculo := aFornec[ nCnt, 5 ]
                nGrupVei   := aFornec[ nCnt, 6 ]
                cNumCiot   := DTR->DTR_CIOT
                
                //-- Motorista da Viagem
                DUP->( DbSetOrder(1))
                If DUP->( DbSeek( xFilial("DUP") + DTR->DTR_FILORI + DTR->DTR_VIAGEM + DTR->DTR_ITEM ) )
                    cCodMot := DUP->DUP_CODMOT
                EndIf

                cFilVge 	:= DTR->DTR_FILORI
                cNumVge 	:= DTR->DTR_VIAGEM
                nTotValAdi 	:= DTR->DTR_ADIFRE

                nValPedag := DTR->DTR_VALPDG
                
                If SA2->( MsSeek( xFilial("SA2") + cCodForn + cLojForn ) )
                    cCondPag	:= SA2->A2_COND
                    cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
                EndIf

                cFilDeb     := TMSA250FilDeb( cCodForn, cLojForn, @cCodFav, @cLojFav, .F., cFilVge, cNumVge, If( cFilAtu <> cFilAnt, .T., .F. ), cCodVei )
                a250Frete	:= A250FreCal( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM , cCodForn , cLojForn , cCodVei, cCodMot, , "03", "DTY" , cTipCont , cTipCTC , cContrat, .F., nValPedag , nTotValAdi, nGrupVei, @aFrete, @aDiaHist, @aMsgErr, .T. )

                If Len( a250Frete ) > 0 .AND. Len( a250Frete[2] ) > 0
                    cTabFre     := a250Frete[2][1][1]  	//-- Tabela de Frete a Pagar
                    cTipTab     := a250Frete[2][1][2]  	//-- Tipo da Tab. de Frete a Pagar
                    nValFrete   := a250Frete[2][1][3]  	//-- Valor do Frete a Pagar
                    nQtdOco     := a250Frete[2][1][4]  	//-- Qtd. de Volumes
                    nPesOco     := a250Frete[2][1][5]  	//-- Peso
                    nQtdDoc     := a250Frete[2][1][6]  	//-- Qtd. de Documentos
                    nDiaSem     := a250Frete[2][1][7]  	//-- No. de Diarias ( Semana )
                    nQtdKm      := a250Frete[2][1][8]  	//-- Quilometragem Percorrida na Viagem
                    nDiaFimSem  := a250Frete[2][1][9]  	//-- No. de Diarias ( Fim de Semana )
                    cGerTitPDG  := a250Frete[2][1][10] 	//-- Gera Titulo de Pedagio ?
                    cDedPDG     := a250Frete[2][1][11] 	//-- Deduz Valor do Pedagio do Valor do Frete ?
                    nBasImp     := a250Frete[2][1][12] 	//-- Valor da Base para calculo dos impostos
                    cTabCar     := a250Frete[2][1][13] 	//-- Tabela de Carreteiro	
                    cGerPC 		:= a250Frete[2][1][14] 	//-- Gera Pedido de Compra ? (1=Sim/2=Nao/3=MV_TMSGRPC)
                    cGerTitCont := a250Frete[2][1][15] 	//-- Gera Titulo do Contrato de Carreteiro ?
                    nBasImp     := nValFrete

                    If nMaxCus == 0
                        nMaxCus := a250Frete[2][1][16] 	//-- Percentual da Rentabilidade x Custo
                    EndIf

                    If Len(a250Frete[2][1]) > 16
                        cTitFrete   := a250Frete[2][1][17] 	//-- Gera Titulo do frete a pagar na geração do contrato, mesmo que o MV_LIBCTC esteja habilitado.
                    EndIf

                    If Len(a250Frete[2][1]) > 17
                        cbxTitPDG   := a250Frete[2][1][18] //-- Efetua a baixa do titulo de pedágio automaticamente?
                    EndIf

                    If Len(a250Frete[2][1]) > 18
                        cTitNDF  := a250Frete[2][1][19] //-- Gera o Titulo de NDF na geração do contrato de carreteiro, mesmo que o MV_LIBCTC esteja habilitado.
                    EndIf

                    If Len(a250Frete[2][1]) > 19
                        cMomTitAdi  := a250Frete[2][1][20] //-- Momento da geração do título do adiantamento.
                    EndIf

                    If Len(a250Frete[2][1]) > 20
                        lPaMovBco	:= a250Frete[2][1][21] //-- Informa se o PA deve movimentar banco.
                    EndIf

                    If Len(a250Frete[2][1]) > 21
                        cMomTitPDG	:= a250Frete[2][1][22] //-- Momento da geração do título de pedágio.
                    EndIf
                    
                    // Carrega variáveis de Acrescimo/Decrescimo e valores financeiros
                    If lRet .AND. Len( a250Frete[4] ) > 0
                        nValIRRF    := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "IRRF" ) ) } )][2]
                        nValINSS    := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "INSS" ) ) } )][2]
                        nValSEST    := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "SEST" ) ) } )][2]
                        nValISS     := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "ISS" ) ) } )][2]
                        nValRetPIS  := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "PIS" ) ) } )][2]
                        nValRetCOF  := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "COF" ) ) } )][2]
                        nAcresc     := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "ACRESC" ) ) } )][2]
                        nDecresc    := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "DECRESC" ) ) } )][2]
                        nVlrReem    := a250Frete[4][1][aScan( a250Frete[4][1], { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( "VLRREEM" ) ) } )][2]
                    EndIf
                    
                    AADD( aDadosCTC, {  /*01*/cCodForn, /*02*/cLojForn, /*03*//*30*/cGerTitCont, /*04*//*09*/cContrat, /*05*//*18*/cCodFav,;
                                        /*06*//*19*/cLojFav, /*07*//*21*/cNatuCTC, /*08*//*10*/nValFrete, /*09*//*16*/nValPedag, /*10*//*20*/nValISS,;
                                        /*11*//*24*/nBasImp, /*12*//*15*/cCodVei } )
                EndIf
            Next nCnt
            
            DTR->( DbSkip() )
        EndDo
    EndIf

    nValISS     := 0
    nValPedag   := 0
    nValFrete   := 0
    nBasImp     := 0 

    For nCntFor := 1 To Len( aDadosCTC )

        aMsgErr     := {}
        cCodForn    := aDadosCTC[nCntFor][1]
        cLojForn    := aDadosCTC[nCntFor][2]
        cGerTitCont := aDadosCTC[nCntFor][3]
        cContrat    := aDadosCTC[nCntFor][4]
        cCodFav     := aDadosCTC[nCntFor][5]
        cLojFav     := aDadosCTC[nCntFor][6]
        cNatuCTC    := aDadosCTC[nCntFor][7]
		nValFrete   := aDadosCTC[nCntFor][8]
		nValPedag   := aDadosCTC[nCntFor][9]
		nValISS     := aDadosCTC[nCntFor][10]

		If aDadosCTC[nCntFor][11] <> 0
			nBasImp := aDadosCTC[nCntFor][11]   //DDBASIMP 24 Valor Base para Calculo dos Impostos
		Else
			nBasImp := aDadosCTC[nCntFor][8]    //DDVLRFRT 10 Valor do Frete informado na viagem / Calculado
		EndIf

        DA3->( MsSeek( xFilial('DA3') + aDadosCTC[ nCntFor, 12 ] ) )
        
        If DA3->DA3_FROVEI == "1"
            cGerTitPDG 	:= "2"
        EndIf
        
        //-- Varre o SDG da Viagem para gerar Titulos das despesas tipo 'NDF' (que NAO movimentam Financeiro)
        //-- PS: Os Titulos das Despesas do Tipo 'PA' sao gerados no Complemento de Viagem
        If cTmsERP <> '1'
            nTotAdiNDF := 0
        EndIf
                    
        AAdd( aRet, { nValFrete, nValINSS, nValRetPIS, nValRetCOF, nValRetCSL, nValIRRF, nValSEST, nValISS } )

    Next nCntFor

    RestArea( aArea )
    RestArea( aAreaDTR )
    RestArea( aAreaSA2 )
    RestArea( aAreaDA3 )

Return aRet

//------------------------------------------------------------------- 
/*{Protheus.doc} GrvImpDTR
Grava os valores de impostos previstos na dtr
@type Function
@author rodrigo.pirolo
@since 07/03/2022
@version 12.1.30
*/
//-------------------------------------------------------------------

Function GrvImpDTR( cStrDTR, lLimpa, nValInss, nValPis, nValCof, nValCsl, nValIr, nValSest, nValIss )

    Local lRet      := .F.
    Local aAreaDTR  := DTR->( GetArea() )

    DEFAULT nValInss    := 0
    DEFAULT nValPis     := 0
    DEFAULT nValCof     := 0
    DEFAULT nValCsl     := 0
    DEFAULT nValIr      := 0
    DEFAULT nValSest    := 0
    DEFAULT nValIss     := 0
    DEFAULT cStrDTR     := ""
    DEFAULT lLimpa      := .T.

    DbSelectArea("DTR")
    DTR->( DbSetOrder(1) ) // DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM
    If DTR->( DbSeek( cStrDTR ) )
        RecLock( "DTR", .F. )
            If lLimpa
                DTR->DTR_PRCSLL  := 0
                DTR->DTR_PRCOFI  := 0
                DTR->DTR_PRPIS   := 0
                DTR->DTR_PRISS   := 0
                DTR->DTR_PRINSS  := 0
                DTR->DTR_PRSEST  := 0
                DTR->DTR_PRIRRF  := 0
            Else
                DTR->DTR_PRCSLL  := nValCsl
                DTR->DTR_PRCOFI  := nValCof
                DTR->DTR_PRPIS   := nValPis
                DTR->DTR_PRISS   := nValIss
                DTR->DTR_PRINSS  := nValInss
                DTR->DTR_PRSEST  := nValSest
                DTR->DTR_PRIRRF  := nValIr
            EndIf
        DTR->( MsUnLock() )
    EndIf
    
    RestArea(aAreaDTR)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetTipDoc()
@author TOTVS
@since 03/05/2022
@version 1.0
@param cDOCTMS, Caracter, Doctms do documento DT6
@param cSerie, Caracter, Serie do documento DT6
@return cRet
/*/
//--------------------------------------------------------------------

Static Function RetTipDoc(cDocTMS,cSerie)
Local cRet  := ""

Default cDocTMS := ""
Default cSerie  := "" 

If cSerie == "COL" .Or. cDocTMS == "1"
    cRet := "OC"
Else
    If cDocTMS $ "5|D|F|G"
        cRet := "NFS"
    Else
        cRet := "CTe"
    EndIf
EndIf

Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutQuitacao()
Método para Quitar uma viagem na PAGBEM

@author Daniel Leme
@since 04/03/2022
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PutQuitacao(cIdViagem) CLASS TMSBCAPagBem
    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local cPath     := "/api/viagens/"+cIdViagem+"/quitacao" //--DTQ_IDOPE
    Local aRet      := { .F., "" }
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local cBody     := ""
    Local oBody     := JsonObject():New()
    Local aResult   := {}

    Default cIdViagem  := ""

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    oBody["pesoTotalChegadaKg"]  := ::PesoTotalChegadaKg
    oBody["documentosEntregues"] := .T.
    oBody["observacoes"]         := ""
   
    cBody   := oBody:ToJson()

    aResult := ::Put( cPath, AClone( aHeaderStr ) , cBody)

    If aResult[1]
        
        lRet    := FWJsonDeserialize( DeCodeUTF8(aResult[2]), @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                If AttIsMemberOf(oResponse,"Resultado") .And. AttIsMemberOf(oResponse:Resultado,"IdViagemEntregaDocumentacao")
                    aRet := { oResponse:IsSucesso, "Viagem Quitada", AllTrim(AllToChar(oResponse:Resultado:IdViagemEntregaDocumentacao)) }
                Else
                    aRet := { oResponse:IsSucesso, "Viagem Quitada", "" }
                EndIf
            Else
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], AllTrim( ::rest_client:GetLastError() ) }
    EndIf
        
    FwFreeArray(aHeaderStr)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} PagBQuitac
Realiza a Quitação do Contrato

@type Function
@author Daniel Leme
@since 04/03/2022
@version 12.130
@param  cFilori     - Filial Origem da viagem
        cViagem     - Codigo da Viagem
        aMsgErr     - array de mensagens de erro
@return lRet
*/
//-------------------------------------------------------------------
Function PagBQuitac(cFilOri, cViagem, aMsgErr, aCompl)
    Local aRet      := {.T.,""}
    Local aArea     := GetArea()
    Local aAreaDTR  := DTR->( GetArea() )
    Local aAreaDTY  := DTY->( GetArea() )
    Local oPagBem   := Nil
    Local aPagBem   := {}
    Local cIdOpe    := ""
    Local cIdQuit   := ""
    Local nPesoCtc  := 0
    Local nValFre   := 0 

    Default cFilOri := ""
    Default cViagem := ""
    Default aMsgErr := {}
    Default aCompl  := {}

    If !Empty( cViagem ) .AND. !Empty( cFilOri )
        
        //--Chama o envio do acréscimo / Decréscimo para a PagBem
        If DTY->DTY_VLACRE .Or. DTY->DTY_VLDECR != 0
            If DTY->DTY_VLACRE != 0 
                PgbemAjust(DTY->DTY_IDOPE, DTY->DTY_VLACRE, DTY->DTY_FILORI + DTY->DTY_VIAGEM, "Acrescimo de valor" ) //Chama integração de Acréscimo na PAGBEM
            EndIf 
            
            If DTY->DTY_VLDECR != 0 
                PgbemAjust(DTY->DTY_IDOPE, -DTY->DTY_VLDECR, DTY->DTY_FILORI + DTY->DTY_VIAGEM, "Decrescimo de valor" ) //Chama integração de decréscimo na PAGEM
            EndIf 
        EndIf 

        cIdOpe      := DTY->DTY_IDOPE
        nValFre     := DTY->DTY_VALFRE
        nPesoCtc    := DTY->DTY_PESO  

        //--Verifica se existe contrato de complemento para a Viagem 
        While DTY->(!Eof()) .And. DTY->(DTY_FILORI+DTY_VIAGEM) == cFilOri + cViagem 
			If DTY->DTY_TIPCTC == "5"  // Complemento 
                Aadd( aCompl , { 	{"ISS"	, DTY->DTY_ISS } ,;
						{"IRRF"		, DTY->DTY_IRRF     } ,;
						{"SEST" 	, DTY->DTY_SEST     } ,;
						{"INSS" 	, DTY->DTY_INSS     } ,;
						{"PIS" 		, DTY->DTY_PIS      } ,;
						{"COFINS" 	, DTY->DTY_COFINS   } ,;
						{"CSLL" 	, DTY->DTY_CSLL     } ,;
						{"VALFRE"   , DTY->DTY_VALFRE   } ,;
						{"FILORI"	, DTY->DTY_FILORI 	} ,;
						{"NUMCTC"	, DTY->DTY_NUMCTC 	} } )
            EndIf 
			DTY->(dbSkip())
		EndDo 
        If Len(aCompl) > 0 
            PgbemAjust(cIdOpe, nValFre, cFilOri + cViagem, "Acrescimo Contrato Complemento:", aCompl ) //Chama integração de ajuste de valor na PAGBEM.  
        EndIf 

        DTR->( DbSetOrder( 1 ) )
        If DTR->( MsSeek( xFilial('DTR') + cFilOri + cViagem ) )
            oPagBem := TMSBCAPagBem():New()
            oPagBem:Auth()
            If nPesoCtc > 0 
                oPagBem:PesoTotalChegadaKg := nPesoCtc
            Else 
                oPagBem:PesoTotalChegadaKg := 0.01 //--Viagem Vazia
            EndIf  

            aPagBem	:= oPagBem:IsTokenActive()
            
            aRet := oPagBem:PutQuitacao( DTR->DTR_PRCTRA )
            If !aRet[1]
			    Help( "", 1, STR0002, ,aRet[2], 1, 0 ) //STR0002"Integração TMS x PAGBEM"
            Else
                //-- Grava o Id da quitação no contrato principal e complementares
                cIdQuit := aRet[3]
                DTY->( DbSetOrder(2) ) // DTY_FILIAL, DTY_FILORI, DTY_VIAGEM, DTY_NUMCTC
                DTY->( DbSeek( FwXFilial("DTY") + DTR->DTR_FILORI + DTR->DTR_VIAGEM ) )
                Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == FwXFilial("DTY") + DTR->DTR_FILORI + DTR->DTR_VIAGEM
                    RecLock("DTY",.F.)
                    DTY->DTY_IDQUIT := cIdQuit
                    DTY->(MsUnLock())

                    DTY->(DbSkip())
                EndDo
            EndIf

            oPagBem:Destroy()
            FwFreeObj( oPagBem )
        EndIf
    EndIf

    RestArea( aAreaDTR )
    RestArea( aAreaDTY )
    RestArea( aArea )

Return aRet

//------------------------------------------------------------------- 
/*{Protheus.doc} PgbemAjust
Realiza ajuste de valor no contrato - Acréscimo / Decréscimo de Valores
@type Function
@author Rafael Souza
@since 07/03/2022
@version 12.1.30
*/
//-------------------------------------------------------------------

Function PgbemAjust(cIdViagem, nValor, cViagem , cMsgAcDc, aDadosComp )

Local oPagBem	:= Nil
Local aRet      := {}
Local nx        := 0 

Default cIdViagem   := ""
Default nValor      := 0 
Default cViagem     := ""
Default cMsgAcDc    := ""
Default aDadosComp  := {} // Dados Contrato Complemento 

oPagBem := TMSBCAPagBem():New()
oPagBem:Auth()

aPagBem	:= oPagBem:IsTokenActive()

If aPagBem[1] .AND. !Empty( cIdViagem )
    If len(aDadosComp) > 0 
        For nx := 1 To Len( aDadosComp )
            oPagBem:IdFrete         := AllTrim(cIdViagem) 
            oPagBem:VlrAjust        := nValor  //Valor do ajuste
            oPagBem:msg_description := cViagem + " " + cMsgAcDc //Observação Acréscimo / Decréscimo 
            oPagBem:aContComp       := aClone(aDadosComp[nx])

                aRet := oPagBem:PostAjustFin()

                If !aRet[1]
                    Help( "", 1, STR0002, , aRet[3], 1, 0, , , , , .T., { STR0012 } ) //STR0002"Integração TMS x PAGBEM"  STR0011"Ocorreu um problema na integração entre TMS Protheus e PAGBEM. "  "O cadastro no TMS Protheus será efetivado sem problemas, porém será necessario realizar a integração novamente."    
                EndIf
        Next nx 
    Else 
        oPagBem:IdFrete         := AllTrim(cIdViagem) 
        oPagBem:VlrAjust        := nValor  //Valor do ajuste
        oPagBem:msg_description := cViagem + " " + cMsgAcDc //Observação Acréscimo / Decréscimo
        aRet := oPagBem:PostAjustFin()

        If !aRet[1]
            Help( "", 1, STR0002, , aRet[3], 1, 0, , , , , .T., { STR0012 } ) //STR0002"Integração TMS x PAGBEM"  STR0011"Ocorreu um problema na integração entre TMS Protheus e PAGBEM. "  "O cadastro no TMS Protheus será efetivado sem problemas, porém será necessario realizar a integração novamente."    
        EndIf
    EndIf 
EndIf

oPagBem:Destroy()
FwFreeObj(oPagBem)

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} PostAjustFin()
Método para Realizar um ajuste financeiro na viagem sobre os valores
da quitação. (Acréscimo / Decréscimo)

@author Rafael 
@since 08/03/2022
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PostAjustFin() CLASS TMSBCAPagBem

Local aArea         := GetArea()
Local aAreaDTR	    := DTR->(GetArea())
Local lRet          := .F.
Local cPath         := "/api/viagens/"
Local cPath2        := "/ajustefinanceiro" 
Local cMsg          := ""
Local nErros        := 0
Local nX            := 0
Local aResult       := {}
Local aHeaderStr    := {}
Local oResponse     := Nil
Local cIdViagem     := ""
Local cBody         := ""
Local oBody         := JsonObject():New()
Local nISS          := 0
Local nIRRF         := 0
Local nSEST         := 0
Local nINSS         := 0
Local nPIS          := 0
Local nCOFINS       := 0
Local nCSLL         := 0 

::rest_client   := FwRest():New( ::Self:url_token )

Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
Aadd( aHeaderStr, "Accept: application/json"                        )
Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )
        /*
            {
        "recebedorAjuste": "Motorista",
        "motivo": "Estadia",
        "observacao": "string",
        "valor": 0,
        "INSS": 0,
        "PIS": 0,
        "COFINS": 0,
        "CSLL": 0,
        "IR": 0,
        "sestSenat": 0,
        "seguro": 0,
        "outrosDebitos": 0,
        "valorAjusteBruto": 0
        } */ 
//-- Ajusta os valores de previsto x realizado para envio de acrescimo / decréscimo
cIdViagem   := ::IdFrete
    
If Len(self:aContComp) > 0
        nISS	    := ::aContComp[1][2] //ISS 
        nIRRF	    := ::aContComp[2][2] //IRRF  
        nSEST	    := ::aContComp[3][2] //SEST   
        nINSS	    := ::aContComp[4][2] //INSSS   
        nPIS	    := ::aContComp[5][2] //PIS  
        nCOFINS	    := ::aContComp[6][2] //COFINS 
        nCSLL	    := ::aContComp[7][2] //CSLL  
        ::VlrAjust  := ::aContComp[8][2] //VALFRE
        ::msg_description := ::msg_description + ::aContComp[10][2]
Else 
    DTR->( DbSetOrder( 1 ) )
    If DTR->( MsSeek( xFilial("DTR") + M->DTY_FILORI + M->DTY_VIAGEM ) )
        nISS    := M->DTY_ISS  - DTR->DTR_PRISS
        nIRRF   := M->DTY_IRRF - DTR->DTR_PRIRRF
        nSEST   := M->DTY_SEST - DTR->DTR_PRSEST
        nINSS   := M->DTY_INSS - DTR->DTR_PRINSS
        nPIS    := M->DTY_PIS  - DTR->DTR_PRPIS
        nCOFINS := M->DTY_COFINS - DTR->DTR_PRCOFI
        nCSLL   := M->DTY_CSLL - DTR->DTR_PRCSLL 
    EndIf 

    //--Remove o sinal de negativo (-) para o envio dos impostos a PAGBEM no caso de decréscimo.
    If DTY->DTY_VLDECR != 0 
        nINSS   := ABS(nINSS)
        nPis    := ABS(nPIS)
        nCOFINS := ABS(nCOFINS)
        nCSLL   := ABS(nCSLL)
        nIRRF   := ABS(nIRRF)
        nSEST   := ABS(nSEST)
        nISS    := ABS(nISS)
    EndIf
EndIf 

oBody["recebedorAjuste"]    := "Motorista"
oBody["motivo"]             := "Outros"
oBody["observacao"]         := ::msg_description  
oBody["INSS"]               := cValToChar( nINSS )
oBody["PIS"]                := cValToChar( nPIS ) 
oBody["COFINS"]             := cValToChar( nCOFINS ) 
oBody["CSLL"]               := cValToChar( nCSLL ) 
oBody["IR"]                 := cValToChar( nIRRF ) 
oBody["sestSenat"]          := cValToChar( nSEST ) 
oBody["outrosDebitos"]      := cValToChar( nISS ) //--ISS
oBody["valorAjusteBruto"]   := cValToChar( ::VlrAjust ) // -- Valor Bruto 

cBody   := oBody:ToJson()

cPath := cPath + AllTrim( cIdViagem ) + cPath2

aResult := ::Post( cPath, AClone( aHeaderStr ), cBody )

If aResult[1]

    lRet    := FWJsonDeserialize( aResult[2], @oResponse )

    If lRet .And. ValType( oResponse ) == "O"
        
        If oResponse:IsSucesso
            aRet := { oResponse:IsSucesso,"", "" }
        Else
            nErros := Len( oResponse:Erros )
            If nErros > 0
                
                For nX := 1 To nErros
                    cMsg += DecodeUTF8(oResponse:Erros[nX]:Mensagem)
                Next nX
                aRet := { oResponse:IsSucesso,"" , cMsg }
            EndIf
        EndIf
    EndIf
    
Else
    aRet := { aResult[1], "", AllTrim( ::rest_client:GetLastError() ) }
EndIf

RestArea( aAreaDTR )
RestArea( aArea )

Return aRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} DelDeliver
Remove a entrega na filial

@author Rodrigo Pirolo
@since 28/02/2022
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD DelDeliver( cIdViagem, cIdQuit ) CLASS TMSBCAPagBem

    Local aArea         := GetArea()
    Local lRet          := .F.
    Local cPath         := "/api/viagens/"//+{idViagem}
    Local cPath2        := "/entrega/"//+{idViagemEntregaDocumentacao}
    Local cMsg          := ""
    Local nErros        := 0
    Local nX            := 0
    Local aResult       := {}
    Local aHeaderStr    := {}
    Local oResponse     := Nil

    Default cIdViagem   := ""
    Default cIdQuit     := ""
    
    If !Empty(cIdViagem)
        ::rest_client   := FwRest():New( ::Self:url_token )

        Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
        Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
        Aadd( aHeaderStr, "Accept: application/json"                        )
        Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
        Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

        cPath := cPath + AllTrim( cIdViagem ) + cPath2 + AllTrim( cIdQuit )

        aResult := ::Delete( cPath, AClone( aHeaderStr ) )

        If aResult[1]
       
            lRet    := FWJsonDeserialize( aResult[2], @oResponse )

            If lRet .And. ValType( oResponse ) == "O"
                /*
                    {
                        "isSucesso": true,
                        "erros": [
                                    {
                                    "codigo": 0,
                                    "mensagem": "string"
                                    }
                                ],
                        "avisos": [
                                    {
                                    "codigo": 0,
                                    "mensagem": "string"
                                    }
                                ]
                    }
                */
                If oResponse:IsSucesso
                    
                    lRet := oResponse:IsSucesso

                Else
                    // Não achei o numero do cartão
                    nErros := Len( oResponse:Erros )
                    If nErros > 0
                        
                        For nX := 1 To nErros
                            cMsg += oResponse:Erros[nX]:Mensagem
                        Next nX

                        lRet            := oResponse:IsSucesso
                        ::last_error    := cMsg
                    EndIf
                EndIf
            EndIf
            
        Else
            lRet            := aResult[1]
            ::last_error    := ::rest_client:GetLastError()
        EndIf
    EndIf
    
    RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} PgBDelQuit
Realiza o Cancelamento da Quitação do Contrato

@type Function
@author Rodrigo Pirolo
@since 01/03/2022
@version 12.130
@param  cViagem     - Codigo da Viagem
        cIdQuit     - Id da quitação da Viagem na PAGBEM
@return lRet
*/
//-------------------------------------------------------------------

Function PgBDelQuit( cFilOri, cViagem, cIdQuit, aMsgErr )

    Local aArea     := GetArea()
    Local aAreaDTR  := DTR->( GetArea() )
    Local oPagBem   := Nil
    Local aPagBem   := {}
    Local lDelQuita	:= .F.
    Local cMsg      := ""

    Default cFilOri := ""
    Default cViagem := ""
    Default cIdQuit := ""
    Default aMsgErr := {}

    If !Empty( cViagem ) .AND. !Empty( cIdQuit )
        
        DTR->( DbSetOrder(1) )
        If DTR->( DbSeek( xFilial('DTR') + cFilOri + cViagem ) )
            oPagBem := TMSBCAPagBem():New()
            oPagBem:Auth()

            aPagBem	:= oPagBem:IsTokenActive()
            
            lDelQuita := oPagBem:DelDeliver( DTR->DTR_PRCTRA, cIdQuit )

            If !lDelQuita 
                cMsg := DecodeUTF8(oPagBem:last_error) 
                AAdd( aMsgErr, { STR0002 + " " + cMsg, '06', } )
            Else
                //-- Limpa o Id da quitação no contrato principal e complementares
                DTY->( DbSetOrder(2) ) // DTY_FILIAL, DTY_FILORI, DTY_VIAGEM, DTY_NUMCTC
                DTY->( DbSeek( FwXFilial("DTY") + DTR->DTR_FILORI + DTR->DTR_VIAGEM ) )
                Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == FwXFilial("DTY") + DTR->DTR_FILORI + DTR->DTR_VIAGEM
                    RecLock("DTY",.F.)
                    DTY->DTY_IDQUIT := " "
                    DTY->(MsUnLock())

                    DTY->(DbSkip())
                EndDo
            EndIf     

            oPagBem:Destroy()
            FwFreeObj( oPagBem )
        EndIf
    EndIf

    RestArea( aArea )
    RestArea( aAreaDTR )

Return lDelQuita

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRelFin()
GET /api/viagens/relatorioFinanceiro
GET Utilizado no relatorio TMSR001

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD GetRelFin( dDtDe, dDtAte ) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local cParams   := ""
    Local oResponse := Nil
    Local cPath     := "/api/viagens/relatorioFinanceiro"
    Local aRet      := {}
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local cDtDe     := ""
    Local cDtAte    := ""
    Local aLinha    := {}
    Local aResult   := {}

    Default dDtDe   := dDataBase - 60
    Default dDtAte  := dDataBase

    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Authorization : Bearer " + ::access_token )

    cDtDe     := DToS( dDtDe )
    cDtAte    := DToS( dDtAte )

    cParams := "periodo_De=" + SubStr( cDtDe, 1, 4 ) + "-" + SubStr( cDtDe, 5, 2 ) + "-" + SubStr( cDtDe, 7, 2 )
    cParams += "&periodo_Ate=" + SubStr( cDtAte, 1, 4 ) + "-" + SubStr( cDtAte, 5, 2 ) + "-" + SubStr( cDtAte, 7, 2 )
    cParams += "&CNPJ_Contratante=" + ::CNPJContr

    aResult := ::Get( cPath, AClone( aHeaderStr ), cParams )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"

            If oResponse:IsSucesso .AND. AttIsMemberOf( oResponse, "Resultado" )
                // Achei o motorista
                If AttIsMemberOf( oResponse:Resultado, "FinanceiroFrete" ) .AND. ValType(oResponse:Resultado:FinanceiroFrete) == "A"
                    For nX := 1 To Len(oResponse:Resultado:FinanceiroFrete)
                        
                        aLinha := {}

                        AAdd( aLinha, { "FILIAL/VIAGEM",        VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "no_Viagem"                    ) } )
                        AAdd( aLinha, { "CONTRATO PAGBEM",      VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "no_Contrato"                  ) } )
                        AAdd( aLinha, { "CIOT",                 VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "no_CIOT"                      ) } )
                        AAdd( aLinha, { "VLR FRETE BRUTO",      VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_FreteBruto"                ) } )
                        AAdd( aLinha, { "VLR PESO SAÍDA",       VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_PesoSaida"                 ) } )
                        AAdd( aLinha, { "VLR PESO CHEGADA",     VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_PesoChegada"               ) } )
                        AAdd( aLinha, { "VLR QUEBRA",           VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_Quebra"                    ) } )
                        AAdd( aLinha, { "VLR AVARIA",           VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_Avaria"                    ) } )
                        AAdd( aLinha, { "VLR DIF FRETE",        VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_DiferencaFrete"            ) } )
                        AAdd( aLinha, { "VLR INSS",             VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_INSS"                      ) } )
                        AAdd( aLinha, { "VLR PIS",              VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_PIS"                       ) } )
                        AAdd( aLinha, { "VLR COFINS",           VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_Cofins"                    ) } )
                        AAdd( aLinha, { "VLR CSLL",             VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_CSLL"                      ) } )
                        AAdd( aLinha, { "VLR IR",               VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_IR"                        ) } )
                        AAdd( aLinha, { "VLR SEST/SENAT",       VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_SestSenat"                 ) } )
                        AAdd( aLinha, { "VLR SEGURO",           VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_Seguro"                    ) } )
                        AAdd( aLinha, { "VLR ADIANTAMENTO",     VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_AdiantamentoFornecedor"    ) } )
                        AAdd( aLinha, { "VLR OUTROS DEBITOS",   VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_OutrosDebitos"             ) } )
                        AAdd( aLinha, { "VLR AJUSTES",          VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_Ajustes"                   ) } )
                        AAdd( aLinha, { "DATA MOVIMENTO",       VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "dt_Movimento"                 ) } )
                        AAdd( aLinha, { "VLR MOVIMENTO",        VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "vl_Movimento"                 ) } )
                        AAdd( aLinha, { "LOCAL MOVIME",         VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "nm_LocalMovimento"            ) } )
                        AAdd( aLinha, { "TIPO MOVIMENTO",       VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "nm_TipoMovimento"             ) } )
                        AAdd( aLinha, { "DATA EMISSÃO",         VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "dt_Emissao"                   ) } )
                        AAdd( aLinha, { "CPF/CNPJ MOTORISTA",   VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "no_CPFCNPJMotorista"          ) } )
                        AAdd( aLinha, { "CPF/CNPJ CONTRATADO",  VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "no_CPFCNPJContratado"         ) } )
                        AAdd( aLinha, { "IDENT FILIAL",         VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "no_IdentificacaoFilial"       ) } )
                        AAdd( aLinha, { "NOME MOTORISTA",       VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "nomeMotorista"                ) } )
                        AAdd( aLinha, { "NOME CONTRATADO",      VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "nomeContratado"               ) } )
                        AAdd( aLinha, { "NOME FILIAL",          VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "nomeFilial"                   ) } )
                        AAdd( aLinha, { "CNPJ FILIAL",          VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "CNPJFilial"                   ) } )
                        AAdd( aLinha, { "TRANSAÇÃO",            VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "transacao"                    ) } )
                        AAdd( aLinha, { "TARIFA CARTÃO",        VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "tarifaCartao"                 ) } )
                        AAdd( aLinha, { "INC.TARIFA ANTT",      VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "contratanteIncluiTarifaANTT"  ) } )
                        AAdd( aLinha, { "TAFIRAS BANCARIAS",    VerAtriObj( oResponse:Resultado:FinanceiroFrete[nX], "tarifasBancarias"             ) } )

                        AAdd( aRet, AClone( aLinha ) )
                    Next nX
                EndIf
            Else
                lRet    := oResponse:IsSucesso
                aRet    := {}
                nErros  := Len( oResponse:Erros )

                If nErros > 0
                    For nX := 1 To nErros
                        cMsg += DecodeUTF8( oResponse:Erros[nX]:Mensagem )
                    Next nX

                    ::last_error := cMsg
                EndIf
            EndIf
        EndIf
    Else
        lRet            := .F.
        ::last_error    := AllTrim( ::rest_client:GetLastError() )
        aRet            := {}
    EndIf
        
    FwFreeArray( aHeaderStr )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
//--------------------------------------------------------------------

Static Function VerAtriObj( oObj, cSearch )
    
    Local cRet      := "Não há dados na PagBem."
    Local xRet      := ""

    Default oObj    := Nil
    Default cSearch := ""

    If !Empty( cSearch )
        
        cSearch := UPPER( cSearch )

        If AttIsMemberOf( oObj, cSearch )
            xRet    := &( "oObj:" + cSearch )
            cTipo   := ValType( xRet )

            If cTipo == "N"
                
                If cSearch $ 'NO_CONTRATO|TRANSACAO'
                    cRet    := cValToChar(  xRet )
                Else
                    cRet    := AllTrim( Transform( xRet, "@E 99,999,999,999.99" ) )
                EndIf

            ElseIf cTipo == "L"

                cRet    := If( xRet, "Sim", "Não" )

            ElseIf cTipo == "C"

                If cSearch $ 'DT_VENCIMENTO|DT_EMISSAO|DT_MOVIMENTO'
                    cRet    := SubStr( xRet, 9, 2 ) + "/" + SubStr( xRet, 6, 2 ) + "/" + SubStr( xRet, 1, 4 )
                ElseIf cSearch $ 'NO_CPFCNPJMOTORISTA|NO_CPFCNPJCONTRATADO'
                    cRet    := Transform( xRet, If( Len( xRet ) > 11,"@R 99.999.999/9999-99", "@R 999.999.999-99" ) )
                ElseIf cSearch $ 'NM_LOCALMOVIMENTO|NM_TIPOMOVIMENTO'
                    cRet    := DeCodeUTF8( AllTrim( xRet ) )
                Else
                    cRet    := AllTrim( xRet )
                EndIf

            EndIf

        EndIf
    EndIf

Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutSitANTT()
@author Rafael Souza
@since 29/04/2022
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PutSitANTT(cCodFor, cLoja) CLASS TMSBCAPagBem

    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local oBody     := JsonObject():New()
    Local cPath     := "/api/antt/situacao"
    Local aRet      := { .F., "", "" }
    Local aDados    := {}
    Local nErros    := 0
    Local nX        := 0
    Local cMsg      := ""
    Local lRet      := .F. 
    Local aArea     := GetArea()
    Local aAreaSA2  := SA2->(GetArea())


    ::rest_client       := FwRest():New( ::Self:url_token )
    
	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )
    
/*   {
  "CNPJCPFContratado": "string",
  "RNTRCContratado": "string",
  "veiculos": [
    {
      "placa": "string"
    }
  ]
}*/
    DbSelectArea("SA2")
    SA2->( DbSetOrder(1) )
    If SA2->( DbSeek( xFilial("SA2") + cCodFor + cLoja ) )
        oBody["CNPJCPFContratado"]  := AllTrim( SA2->A2_CGC )
        oBody["RNTRCContratado"]    := AllTrim( SA2->A2_RNTRC )
    EndIf 
    
    cBody   := oBody:ToJson()

    aResult := ::Put( cPath, AClone( aHeaderStr ), cBody )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"
            If oResponse:IsSucesso
                
                If AttIsMemberOf( oResponse, "Resultado" )

                   // AAdd( aDados, oResponse:Resultado:nome              )
                    AAdd( aDados, oResponse:Resultado:isRNTRCAtivo      )
                    AAdd( aDados, oResponse:Resultado:validadeRNTRC     )
                    AAdd( aDados, oResponse:Resultado:tipoTransportador )
                    AAdd( aDados, oResponse:Resultado:isTACouEquiparado )
                    
                    aRet := { oResponse:IsSucesso, AClone(aDados), "" }
                Else
                    aRet := { oResponse:IsSucesso, {}, "" }
                EndIf
            Else
                // Não achei o numero do cartão
                nErros := Len( oResponse:Erros )
                If nErros > 0
                    
                    For nX := 1 To nErros
                        cMsg += oResponse:Erros[nX]:Mensagem
                    Next nX

                    aRet := { oResponse:IsSucesso, {}, cMsg }
                EndIf
            EndIf
        EndIf
    Else
        aRet := { aResult[1], {}, AllTrim( ::rest_client:GetLastError() ) }
    EndIf
     
    FwFreeArray(aHeaderStr)
    RestArea( aAreaSA2 )
    RestArea(aArea)   

Return aRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} PostCiotA()
POST /api/ciotagregado
Declara uma operação de CIOT para TAC-Agregado

@author Rodrigo Pirolo
@since 29/04/2022
@version 1.0
/*/
//--------------------------------------------------------------------

METHOD PostCiotA( cCGC, cRNTRC, aVeic, dDtFimVgm, nQtdTar, nVlrTar )  CLASS TMSBCAPagBem

    Local cPath     := "/api/ciotagregado"
    Local cParams   := ""
    Local cBody     := ""
    Local cMsg      := ""
    Local nErros    := 0
    Local nX        := 0
    Local aResult   := {}
    Local aVeiculo  := {}
    Local lRet      := .F.
    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local oBody     := JsonObject():New()
    Local oVeic     := JsonObject():New()
    Local oContrat  := JsonObject():New()

    Default cCGC        := ""
    Default cRNTRC      := ""
    Default aVeic       := {}
    Default dDtFimVgm   := dDataBase
    Default nQtdTar     := 0
    Default nVlrTar     := 0

    For nX := 1 To Len( aVeic )

        oVeic := JsonObject():New()
                                
        oVeic["placa"]  := aVeic[nX][1]
        oVeic["RNTRC"]  := aVeic[nX][2]
        
        AAdd( aVeiculo, oVeic )

    Next nX

    ::rest_client       := FwRest():New( ::Self:url_token )

	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )
    
    oContrat["CNPJCPF"] := cCGC
    oContrat["RNTRC"]   := cRNTRC

    oBody["contratado"] := oContrat

    //oBody["RNTRCContratante"]   := ::Drivr_Name

    oBody["veiculos"]   := AClone( aVeiculo ) // ::RNTRC

    oBody["dataFimViagem"]      := FWTimeStamp( 3, If( dDtFimVgm < dDataBase, dDataBase + 2, dDtFimVgm ), Time() )
    oBody["quantidadeTarifas"]  := nQtdTar
    oBody["valorTarifas"]       := nVlrTar
    
    cBody   := oBody:ToJson()

    aResult := ::Post( cPath, AClone( aHeaderStr ), FwCutOff(cBody,.T.) )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"

            If oResponse:IsSucesso .AND. AttIsMemberOf( oResponse, "Resultado" )
                // "dataFim": "2022-04-28T12:00:45.215Z",
                // "idCIOTAgregado": 0,
                // "CIOT": "string"
                If AttIsMemberOf( oResponse:Resultado, "idCIOTAgregado" )
                    ::IdCiotAgre    := oResponse:Resultado:idCIOTAgregado
                EndIf
                If AttIsMemberOf( oResponse:Resultado, "CIOT" )
                    ::NumCiotAg     := oResponse:Resultado:CIOT
                EndIf
                lRet := .T.
            Else
                lRet := oResponse:IsSucesso
                ::IdCiotAgre    := 0
                ::NumCiotAg     := ""
                nErros := Len( oResponse:Erros )

                If nErros > 0
                    For nX := 1 To nErros
                        cMsg += DecodeUTF8( oResponse:Erros[nX]:Mensagem )
                    Next nX

                    ::last_error := cMsg
                EndIf
            EndIf
        EndIf
    Else
        lRet            := .F.
        ::IdCiotAgre    := 0
        ::NumCiotAg     := ""
        ::last_error    := AllTrim( ::rest_client:GetLastError() )
    EndIf
        
    FwFreeArray( aHeaderStr )

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DelCiotA()
DELETE /api/ciotagregado/ + NumeroCIOT
Cancela uma operação de CIOT para TAC-Agregado

@author Rodrigo Pirolo
@since 04/05/2022
@version 1.0
@param cNumCIOT caracter, numero do ciot com ou sem "/"
/*/
//--------------------------------------------------------------------

METHOD DelCiotA( cNumCIOT )  CLASS TMSBCAPagBem

    Local cPath     := "/api/ciotagregado/"
    Local cBody     := ""
    Local cMsg      := ""
    Local nErros    := 0
    Local nX        := 0
    Local aResult   := {}
    Local lRet      := .F.
    Local aHeaderStr:= {}
    Local oResponse := Nil
    Local oBody     := JsonObject():New()

    Default cNumCIOT:= ""

    ::rest_client       := FwRest():New( ::Self:url_token )

	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    cPath += REPLACE( cNumCIOT, "/" )

    oBody["motivo"] := STR0042 // "Devido a um erro na Viagem, houve necessidade de cancelar o CIOT Agregado."

    cBody   := oBody:ToJson()

    aResult := ::Delete( cPath, AClone( aHeaderStr ), FwCutOff( cBody, .T. ) )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"

            If oResponse:IsSucesso .AND. AttIsMemberOf( oResponse, "Resultado" )
                // "numeroCIOT": "string",
                // "dataCancelamento": "2022-05-04T14:26:55.428Z"
                If AttIsMemberOf( oResponse:Resultado, "numeroCIOT" )
                    ::NumCiotAg     := oResponse:Resultado:numeroCIOT
                EndIf
                If AttIsMemberOf( oResponse:Resultado, "dataCancelamento" )
                    ::DataCancel     := FWDateTimeToLocal(oResponse:Resultado:dataCancelamento)[1]
                EndIf
                ::StatusCIOT := STR0043 // "Cancelado"
                lRet := .T.
            Else
                lRet := oResponse:IsSucesso

                nErros := Len( oResponse:Erros )

                If nErros > 0
                    For nX := 1 To nErros
                        cMsg += DecodeUTF8( oResponse:Erros[nX]:Mensagem )
                    Next nX

                    ::last_error := cMsg
                EndIf
            EndIf
        EndIf
    Else
        lRet            := .F.
        ::last_error    := AllTrim( ::rest_client:GetLastError() )
    EndIf
        
    FwFreeArray( aHeaderStr )

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PutEnCiotA()
PUT /api/ciotagregado/{numeroCIOT}/encerrar
Encerra uma operação de CIOT para TAC-Agregado

@author Rodrigo Pirolo
@since 04/05/2022
@version 1.0
@param cNumCIOT caracter, numero do ciot com ou sem "/"
/*/
//--------------------------------------------------------------------

METHOD PutEnCiotA( cNumCIOT )  CLASS TMSBCAPagBem

    Local cPath     := "/api/ciotagregado/"//{numeroCIOT}
    Local cPath2    := "/encerrar"
    Local cMsg      := ""
    Local nErros    := 0
    Local nX        := 0
    Local aResult   := {}
    Local lRet      := .F.
    Local aHeaderStr:= {}
    Local oResponse := Nil

    Default cNumCIOT:= ""

    ::rest_client       := FwRest():New( ::Self:url_token )

	Aadd( aHeaderStr, "Cache-Control: no-cache"                         )
	Aadd( aHeaderStr, "Content-Type: application/json; charset = utf-8" )
	Aadd( aHeaderStr, "Accept: application/json"                        )
    Aadd( aHeaderStr, "Authorization: " + "Bearer " + ::access_token    )
    Aadd( aHeaderStr, "CNPJContratante: " + ::CNPJContr                 )

    cPath += REPLACE( cNumCIOT, "/" ) + cPath2

    aResult := ::Put( cPath, AClone( aHeaderStr ) )

    If aResult[1]
        
        lRet    := FWJsonDeserialize( aResult[2], @oResponse )

        If lRet .And. ValType( oResponse ) == "O"

            If oResponse:IsSucesso .AND. AttIsMemberOf( oResponse, "Resultado" )
                // "dataEncerramento": "2022-05-04T14:26:55.448Z",
                // "idCIOTAgregado": 0,
                // "CIOT": "string"
                If AttIsMemberOf( oResponse:Resultado, "idCIOTAgregado" )
                    ::IdCiotAgre    := oResponse:Resultado:idCIOTAgregado
                EndIf
                If AttIsMemberOf( oResponse:Resultado, "CIOT" )
                    ::NumCiotAg     := oResponse:Resultado:CIOT
                EndIf
                If AttIsMemberOf( oResponse:Resultado, "dataEncerramento" )
                    ::DataEncerr     := FWDateTimeToLocal(oResponse:Resultado:dataEncerramento)[1]
                EndIf

                ::StatusCIOT := STR0044 // "Encerrado"
                lRet := .T.
            Else
                lRet := oResponse:IsSucesso

                nErros := Len( oResponse:Erros )

                If nErros > 0
                    For nX := 1 To nErros
                        cMsg += DecodeUTF8( oResponse:Erros[nX]:Mensagem )
                    Next nX

                    ::last_error := cMsg
                EndIf
            EndIf
        EndIf
    Else
        lRet            := .F.
        ::last_error    := AllTrim( ::rest_client:GetLastError() )
    EndIf
        
    FwFreeArray( aHeaderStr )

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} PostEnCiotA()
retorna um array contendo a placa e o rntrc

@author Rodrigo Pirolo
@since 06/05/2022
@version 1.0
@param cNumCIOT caracter, numero do ciot com ou sem "/"
/*/
//--------------------------------------------------------------------

Static Function RetPlaca( cCodVei, cCodRB1, cCodRB2, cCodRB3, cRNTRC )

    Local aRet      := {}
    Local aArea     := GetArea()
    Local aAreaDA3  := DA3->(GetArea())

    Default cCodVei := ""
    Default cCodRB1 := ""
    Default cCodRB2 := ""
    Default cCodRB3 := ""
    Default cRNTRC := ""

    DbSelectArea("DA3")
    DA3->( DbSetOrder(1) )
    
    If !Empty(cCodVei) .AND. DA3->( DbSeek( xFilial("DA3") + cCodVei ) )
        AAdd( aRet, { AllTrim(DA3->DA3_PLACA), cRNTRC } )
    EndIf

    If !Empty(cCodRB1) .AND. DA3->( DbSeek( xFilial("DA3") + cCodRB1 ) )
        AAdd( aRet, { AllTrim(DA3->DA3_PLACA), cRNTRC } )
    EndIf

    If !Empty(cCodRB2) .AND. DA3->( DbSeek( xFilial("DA3") + cCodRB2 ) )
        AAdd( aRet, { AllTrim(DA3->DA3_PLACA), cRNTRC } )
    EndIf

    If !Empty(cCodRB3) .AND. DA3->( DbSeek( xFilial("DA3") + cCodRB3 ) )
        AAdd( aRet, { AllTrim(DA3->DA3_PLACA), cRNTRC } )
    EndIf

    RestArea(aArea)
    RestArea(aAreaDA3)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetCodBan()
Funcao que retorna o bandeira (codigo do banco) do cartao

@author Rodrigo Pirolo
@since 06/05/2022
@version 1.0
@param cNumCIOT caracter, numero do ciot com ou sem "/"
/*/
//--------------------------------------------------------------------

Static Function RetCodBan(cCodMot, cIDOPE, cFilOri, cViagem, cOpera) 

    Local cCodBan		:= ""

    Default cCodMot 	:= ""
    Default cIDOPE		:= ""
    Default cFilOri 	:= ""
    Default cViagem		:= ""
    Default cOpera      := ""

    DbSelectArea("DEL")
    DEL->( DbSetOrder(2) ) //DEL_FILIAL+DEL_CODMOT+DEL_CODOPE+DEL_IDOPE
    If DEL->( DbSeek( xFilial("DEL") + cCodMot + cOpera + cIDOPE ) )
        cCodBan := DEL->DEL_CODBAN
    EndIf

Return cCodBan

//-----------------------------------------------------------------
/*/{Protheus.doc} RetTaxTot()
Funcao que retorna a tarifa com os valores totais de saque e transf

@author Rodrigo Pirolo
@since 06/05/2022
@version 1.0
@param cNumCIOT caracter, numero do ciot com ou sem "/"
/*/
//--------------------------------------------------------------------

Static Function RetTaxTot(cCodBan, nQtdSaq, nQtdTransf ) 

Local nValTot   := 0
Local nValSaq   := 0
Local nValTran  := 0

	DbSelectArea("DJB")
	DJB->( DbSetOrder(1) ) //DJB_FILIAL+DJB_CODBAN+DJB_TARIFA+DJB_CODTAF

	If DJB->( DbSeek( xFilial('DJB') + cCodBan ) )

		While DJB->(!EOF()) .And. DJB->(DJB_CODBAN) == cCodBan
			
            If DJB->DJB_TARIFA == '1'   // SAQUE
				nValSaq :=  nQtdSaq * DJB->DJB_VALOR
			Else                        //TRANSFERENCIA
				nValTran :=  nQtdTransf * DJB->DJB_VALOR
			EndIf
		    
            DJB->(DbSkip())
		EndDo

	    nValTot := nValSaq + nValTran
	EndIf

Return nValTot

//-----------------------------------------------------------------
/*/{Protheus.doc} PgBEncCIOT()
@author Rafael Souza
@since 09/05/2022
@version 1.0
@return cRet
/*/
//--------------------------------------------------------------------
Function PgBEncCIOT(cCiot,cCodVei,aMsgErr)

Local lRet         := .T.
Local aAreaDTR     := DTR->(GetArea())
Local aArea        := GetArea()
Local aViagens     := PamVgsCiot(cCiot) //--> Identifica as viagens que estão utilizando o CIOT. 
Local cQuery       := ""
Local cAliasQry    := ""
Local nI           := 0 
Local oObj

Default cCiot   := ""
Default cCodVei := ""
Default aMsgErr := {}

If (lRet := !Empty(aViagens))
	For nI := 1 To Len(aViagens)
		cAliasQry := GetNextAlias()
		cQuery := " SELECT R_E_C_N_O_ NREG "
		cQuery += " FROM " + RetSqlName("DTY")
		cQuery += " WHERE DTY_FILIAL = '" + xFilial("DTY") + "'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += "   AND DTY_FILORI = '" + aViagens[nI][1] + "'"
		cQuery += "   AND DTY_VIAGEM = '" + aViagens[nI][2] + "'"
	
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		lRet := (cAliasQry)->(!Eof())
		
		Do While lRet .And. (cAliasQry)->(!Eof())
			DTY->(dbGoto((cAliasQry)->NREG))
			lRet := DTY->(DTY_STATUS=='4' .Or. (Empty(DTY_STATUS) .And. !Empty(DTY_NUMPC))) .Or.; //-- "Contrato Quitado com Ped. Compra"
			        DTY->(DTY_STATUS=='5')
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		
		If !lRet
			Exit
		EndIf
	Next nI 
EndIf

If lRet
	//--Chama o método para encerrar o CIOT na PAGBEM.
    oObj := TMSBCAPagBem():New()
	oObj:Auth()
	lRet := oObj:PutEnCiotA(cCiot) 

	If lRet
		DJL->(DbSetOrder(1)) //-- DJL_FILIAL+DJL_CIOT+DJL_CODVEI
		If DJL->(DbSeek(xFilial("DJL")+cCiot+cCodVei))
			RecLock("DJL",.F.)
			DJL->DJL_STATUS := "3" //--Encerrado
            DJL->DJL_DATENC := dDataBase 
			MsUnLock()
		EndIf
	Else 
        AAdd( aMsgErr, { STR0032 + oObj:last_error, '06',  } ) // STR0032 "Erro Sistema PagBem: " 
    EndIf
Else
    Help( "", 1, STR0002, , STR0046, 1, 0, , , , , ,) //STR0002"Integração TMS x PAGBEM"  STR0046 "O CIOT não pode ser encerrado. Verifique se todas as viagens estão com contrato quitado" 
EndIf	

FwFreeObj(oObj)

RestArea(aAreaDTR)
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetCodBan()
Funcao que retorna o bandeira (codigo do banco) do cartao

@author Rodrigo Pirolo
@since 06/05/2022
@version 1.0
@param cNumCIOT caracter, numero do ciot com ou sem "/"
/*/
//--------------------------------------------------------------------

Static Function RetCanCiot( cFilOri, cViagem, cNumCiot, cCodOpe )

    Local cQuery	:= ""
    Local cAlias	:= GetNextAlias()
    Local lRet      := .F.

    Default cFilOri := ""
    Default cViagem := ""
    Default cNumCiot:= ""
    Default cCodOpe := ""

    cQuery := " SELECT COUNT(DTQ.DTQ_STATUS) HASVIAGEM "
    cQuery += " FROM " + RetSqlName("DTQ") + " DTQ "
    cQuery +=       " INNER JOIN " + RetSqlName("DTR") + " DTR ON DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
    cQuery +=                                   " AND DTQ.DTQ_FILORI = DTR.DTR_FILORI "
    cQuery +=                                   " AND DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM "
    cQuery +=                                   " AND DTR.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE DTQ.DTQ_FILIAL = '" + xFilial ("DTQ") + "' "
    cQuery +=       " AND DTQ.DTQ_FILORI = '" + cFilOri + "' "
    cQuery +=       " AND DTQ.DTQ_VIAGEM <> '" + cViagem + "' "
    cQuery +=       " AND DTQ.DTQ_STATUS IN ( '5','2','4','3' ) " // 1=Em Aberto;5=Fechada;2=Em Transito;4=Chegada em Filial;3=Encerrada;9=Cancelada
    cQuery +=       " AND DTR.DTR_CIOT = '" + cNumCiot + "' "
    cQuery +=       " AND DTR.DTR_CODOPE = '" + cCodOpe + "' "
    cQuery +=       " AND DTQ.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    
    DbUseArea( .T., 'TOPCONN', TcGenQry( , , cQuery ), cAlias, .F., .T. )
    
    lRet := (cAlias)->(HASVIAGEM) > 0

Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} RetCodBan()
Funcao que retorna o bandeira (codigo do banco) do cartao

@author Rodrigo Pirolo
@since 06/05/2022
@version 1.0
@param cNumCIOT caracter, numero do ciot com ou sem "/"
/*/
//--------------------------------------------------------------------

Function TMSXJCiot( lIncDLJ, cIdCiot, cCodVei, dDtFMCI, cStatus )

    Local lRet      := .F.
    Local aAreaDJL  := DJL->( GetArea() )
    
    Default lIncDLJ := .T.
    Default cIdCiot := ""
    Default cCodVei := ""
    Default dDtFMCI := ""
    Default cStatus := ""

    DbSelectArea("DJL")
    DJL->( DbSetOrder(1) ) // DJL_FILIAL, DJL_CIOT, R_E_C_D_E_L_

    If lIncDLJ
        RecLock( "DJL", .T. )
            DJL_FILIAL  := xFilial("DJL")
            DJL_CIOT    := cIdCiot
            DJL_CODVEI  := cCodVei
            DJL_DATINI  := dDataBase
            DJL_DATFIM  := dDtFMCI
            DJL_DATFEC  := CtoD('')
            DJL_STATUS  := cStatus // 1=Aberto; 2=Fechado; 3=Encerrado; 9=Cancelado
            DJL_CODOPE  := "03"
        DJL->(MsUnLock())
    Else
        If DJL->( DbSeek( xFilial("DJL") + cIdCiot ) )
            RecLock( "DJL", .F. )
                DJL_FILIAL  := xFilial("DJL")
                DJL_CIOT    := cIdCiot
                DJL_CODVEI  := cCodVei
                DJL_DATINI  := dDataBase
                DJL_DATFIM  := dDtFMCI
                DJL_DATFEC  := CtoD('')
                DJL_STATUS  := cStatus // 1=Aberto; 2=Fechado; 3=Encerrado; 9=Cancelado
            DJL->(MsUnLock())
        EndIf
    EndIf

    RestArea( aAreaDJL )

Return lRet
