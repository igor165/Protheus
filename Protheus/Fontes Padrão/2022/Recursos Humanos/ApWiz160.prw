#INCLUDE 'protheus.ch'
#INCLUDE "apwizard.ch"
#INCLUDE 'apwiz160.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'apwebsrv.ch'
#INCLUDE 'restful.ch'
#INCLUDE 'fileio.ch'

#DEFINE APXSRVINI_FILENAME	GetADV97()
#DEFINE FIELD_STRING_SMALL 30
#DEFINE FIELD_STRING_SIZE 150
#DEFINE FIELD_URL_SIZE 80

//-------------------------------------------------------------------
/*/{Protheus.doc} ApWizRST
Função para edição das chaves de HOST App MeuRH
@author  marcelo faria
@since   10/05/2019
@version 12
@protected
/*/
//-------------------------------------------------------------------
Function ApWizMRH(lIncluir,lDeletar,nNodeLine)
Local nBtnPressed AS NUMERIC
Local aEnableButtons AS ARRAY

aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F., Nil},{.F., Nil} }

nBtnPressed := FWExecView("MRH","apwiz160",4,,,{||.T.},,aEnableButtons)

Return nBtnPressed == VIEW_BUTTON_OK

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de MeuRH para o appserver.ini
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel        AS OBJECT
Local oMRHStruct    AS OBJECT
Local oSocketStruct AS OBJECT

oModel := FWFormModel():New("ApWizMRH",,,{|oModel| commit(oModel)},{||.T.})
oModel:SetDescription(STR0008)

//http://tdn.totvs.com/display/framework/FWFormModelStruct
oMRHStruct := FWFormModelStruct():New()
oMRHStruct:AddTable("FAKE_MASTER" , , STR0008) //"App MeuRH"
oMRHStruct:AddField("RESTPORT","RESTPORT","RESTPORT","N",4,,,,,.T.)
oMRHStruct:AddField("RESTSERVER","RESTSERVER","RESTSERVER","C",FIELD_URL_SIZE,,,,,.T.)
oMRHStruct:AddField("ENABLE","ENABLE","ENABLE","L",1)
oMRHStruct:AddField("SOCKETS","SOCKETS","SOCKETS","C",FIELD_STRING_SIZE)

oMRHStruct:SetProperty("RESTPORT", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'vldPort()'))
oMRHStruct:SetProperty("RESTSERVER", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'vldServer()'))


oSocketStruct := FWFormModelStruct():New()
oSocketStruct:AddTable( "FAKE_SOCKET" ,  , STR0009) //"HOSTs do MeuRH"
oSocketStruct:AddField("NOME","NOME","NOME","C",FIELD_URL_SIZE,,,,,.T.)
oSocketStruct:AddField("HOSTENABLE","HOSTENABLE","HOSTENABLE","L",1)
oSocketStruct:AddField("PATH","PATH","PATH","C",FIELD_STRING_SIZE,,,,,.T.)
oSocketStruct:AddField("PAGE","PAGE","PAGE","C",FIELD_STRING_SMALL,,,,,.T.)

oSocketStruct:SetProperty("NOME", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'vldHost()'))
oSocketStruct:SetProperty("PATH", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'vldPATH()'))

oModel:addFields('MRHMASTER',,oMRHStruct,,,{||LoadMRH()})
oModel:addGrid('MRHSOCKET','MRHMASTER',oSocketStruct, , , ,  ,{||LoadSockets()})

oModel:GetModel("MRHMASTER"):SetDescription(STR0008)
oModel:GetModel("MRHSOCKET"):SetDescription(STR0009)

oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View para o modelo MRH para o ApWebWizard
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel        AS OBJECT
Local oView         AS OBJECT
Local oMRHStruct    AS OBJECT
Local oSocketStruct AS OBJECT

oMRHStruct := FWFormViewStruct():New()
oMRHStruct:AddField("RESTPORT"     ,"01",STR0002,STR0002,,"N", "9999")   //"Porta REST"
oMRHStruct:AddField("RESTSERVER"   ,"02",STR0024,STR0026,,"C")           //"Endereço completo do servidor REST"
oMRHStruct:AddField("ENABLE"       ,"03",STR0003,STR0003,,"L")           //"Log MeuRH Habilitado"

oSocketStruct := FWFormViewStruct():New()
oSocketStruct:AddField("NOME"      ,"01",STR0004,STR0004,,"C")           //"Nome do host"
oSocketStruct:AddField("HOSTENABLE","02",STR0005,STR0005,,"L")           //"Host habilitado"
oSocketStruct:AddField("PATH"      ,"03",STR0006,STR0006,,"C")           //"Caminho dos arquivos cliente (PATH)"
oSocketStruct:AddField("PAGE"      ,"04",STR0007,STR0007,,"C")           //"Página principal do host"

oModel := ModelDef()
oView  := FWFormView():New()
oView:Setmodel(oModel)

oView:AddField( 'VIEW_MRH_MASTER', oMRHStruct,    'MRHMASTER' )
oView:AddGrid(  'VIEW_SOCKET'    , oSocketStruct, 'MRHSOCKET' )

oView:CreateHorizontalBox( 'MASTER' , 20 )
oView:SetOwnerView( 'VIEW_MRH_MASTER', 'MASTER' ) 

oView:CreateHorizontalBox( 'SOCKET' , 80 )
oView:SetOwnerView( 'VIEW_SOCKET', 'SOCKET' ) 

oView:EnableTitleView("MRHSOCKET")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Commit
Função para commit do modelo salvando no appserver.ini
/*/
//-------------------------------------------------------------------
Static Function Commit(oModel AS OBJECT)
Local aProperties   AS ARRAY
Local cSocketName   AS CHARACTER
Local nSocketLine   AS NUMERIC
Local cHostsMeuRH   AS CHARACTER
Local aSocketsMeuRH AS ARRAY
Local nI, nY        AS NUMERIC
Local cDir          AS CHARACTER

Local cRestServer   AS CHARACTER
Local cRestPort     AS CHARACTER
Local lMeuRHLog     AS LOGICAL

Local oSockets      AS OBJECT
Local lHostEnable   AS LOGICAL
Local cHostPath     AS CHARACTER
Local cHostPage     AS CHARACTER
Local cRootContext  AS CHARACTER
Local nPosRoot      AS NUMERIC

cRestServer := alltrim(oModel:GetValue("MRHMASTER","RESTSERVER"))
cRestPort   := alltrim(str(oModel:GetValue("MRHMASTER","RESTPORT")))
lMeuRHLog   := oModel:GetValue("MRHMASTER","ENABLE")

oSockets    := oModel:GetModel("MRHSOCKET")


//eliminando todos os hosts MeuRH do RESTCONFIG
//antes de proceder a atualização do INI
nI            := 0
aSocketsMeuRH := {}
cHostsMeuRH   := alltrim(GetPvProfString( "RESTCONFIG", "HostsRest", "", APXSRVINI_FILENAME ))
If !Empty(cHostsMeuRH)
    aSocketsMeuRH := StrTokArr( cHostsMeuRH , ',' )

    //busca a partir da segunda ocorrência, pois a primeira posição é do server rest
    For nI := 2 To Len(aSocketsMeuRH)
        DeleteSectionINI(aSocketsMeuRH[1], APXSRVINI_FILENAME)
    Next
EndIf

//Atualiza os hosts MeuRH no INI
aProperties := {}
cSockets    := cRestServer + ','
For nSocketLine := 1 To oSockets:Length()
    
   oSockets:GoLine(nSocketLine)
   cSocketName := AllTrim(oSockets:GetValue("NOME"))     

    If !oSockets:IsDeleted()
        lHostEnable := oSockets:GetValue("HOSTENABLE")
        cHostPath   := AllTrim(oSockets:GetValue("PATH"))
        cHostPage   := AllTrim(oSockets:GetValue("PAGE"))
        
        WritePProString(cSocketName, "ENABLE",      IIF(lHostEnable,"1","0"),        APXSRVINI_FILENAME)        
        WritePProString(cSocketName, "PATH",        cHostPath,                       APXSRVINI_FILENAME)
        WritePProString(cSocketName, "DEFAULTPAGE", cHostPage,                       APXSRVINI_FILENAME)

        aAdd( aProperties , { cHostPath, cSocketName } )
        cSockets += cSocketName + ','
    EndIf
Next

//Atualiza RESTCONFIG no INI
WritePProString('RESTCONFIG', "restPort", cRestPort, APXSRVINI_FILENAME)
WritePProString('RESTCONFIG', "MeuRHLog", IIF(lHostEnable,"1","0"), APXSRVINI_FILENAME)
WritePProString('RESTCONFIG', "HostsRest", SubStr(cSockets, 1, Len(cSockets)-1), APXSRVINI_FILENAME)


//Preparando e atualizando o arquivo "properties.json"
cDir   := ""
nI     := 0
For nI := 1 To Len(aProperties)

    If aProperties[nI][1] != cDir
    
       If ExistDir(aProperties[nI][1])
          If !FILE(aProperties[nI][1] +"\properties.json") 
             //"Atualização do properties"
             //"Não foi localizado o arquivo 'properties.json' na pasta:"
             //"baixe do portal do cliente os arquivos do App MeuRH!"
             MsgInfo( STR0023  +" " +aProperties[nI][1] +Chr(13) +Chr(10) +Chr(13) +Chr(10) +STR0022, STR0019 )
          Else

             //renomeando o arquivo properties.json
             //essa operação não precisa ser validade, pois localize o arquivo, um novo será criado
             frename(aProperties[nI][1] +"\properties.json" , aProperties[nI][1] +"\properties bkp " +SUBSTR(dToC(DATE()), 1, 2) +"-" +SUBSTR(dToC(DATE()), 4, 2) +" at " +SUBSTR(TIME(), 1, 2) +"-" +SUBSTR(TIME(), 4, 2) +"-" +SUBSTR(TIME(), 7, 2) +".json" )

             //capturando rootContext
             cRootContext := ""
             nY           := 0
             nPosRoot     := AT( "/", aProperties[nI][2] )
             If nPosRoot > 0
                //varre os caracteres após a barra
                For nY := nPosRoot+1 To Len(aProperties[nI][2])
                    If SUBSTR(aProperties[nI][2] , nI , 1) != "/"
                       cRootContext += SUBSTR(aProperties[nI][2] , nY , 1)
                    EndIf
                Next
             EndIf
             
             //criando os dados properties.json
             cNewProperties := criaProp(cRestServer, cRootContext)
             
             //criando o novo arquivo de properties
             If MemoWrite( aProperties[nI][1] +"\properties.json" , cNewProperties )
                //"Atualização do properties"
                //"Arquivo 'properties.json' criado com sucesso!"
                MsgInfo(STR0027,STR0019)
             Else
                //"Atualização do properties"
                //"Erro na atualização do arquivo 'properties.json'"
                MsgInfo(STR0028,STR0019 )
             EndIf
           
          EndIf
       Else
          //"Atualização do properties"
          //"Não foi localizada a pasta:"
          //"para atualização do arquivo 'properties.json'"
          //"baixe do portal do cliente os arquivos do App MeuRH!"
          MsgInfo( STR0020 +" '" +aProperties[nI][1] +"' " +STR0021 +Chr(13) +Chr(10) +Chr(13) +Chr(10) +STR0022, STR0019 )
       EndIf
       
    EndIf   

    cDir := aProperties[nI][1]
Next


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadMRH
Função para carregar o modelo MASTER do MRH
/*/
//-------------------------------------------------------------------
Static Function LoadMRH()
Local aDados      AS ARRAY
Local aHosts      AS ARRAY
Local nI          AS NUMERIC

Local nRestPort   AS NUMERIC
Local cPort       AS CHARACTER
Local cRestServer AS CHARACTER
Local lMeuRHLog   AS LOGICAL
Local cHosts      AS CHARACTER

//Fonte do Framework ApWizLIB
//ReadINIKeys('MRH', nPosMRH, {'RESTPORT','MEURHLOG','HOSTSREST'})

aDados := WizGetMRH()
//varinfo("WizGetMRH aDados: ",aDados )

//separa a primeira ocorrência como endereço do servidor REST
If len( aDados[1][2] ) > 0
   cHosts      := alltrim( GetParValue("HOSTSREST",aDados[1][2]) )

   If !empty(cHosts)
      aHosts      := StrTokArr( cHosts , ',' )
      cRestServer := aHosts[1]
   Else
      aHosts      := {}
      cRestServer := ""
   EndIf

   //atualiza hosts MeuRH do ini a partir da segunda ocorrência 
   cHosts := ""
   For nI := 2 To len(aHosts)
       cHosts += aHosts[nI] 

       If nI != len(aHosts)
          cHosts += ","
       EndIf
   Next

   cPort := GetParValue("RESTPORT" ,aDados[1][2])
   If !empty(cPort) .and. FwIsNumeric(cPort)
      nRestPort   := val(cPort)
   Else
      nRestPort   := 0  
   Endif
   
   lMeuRHLog   := GetParValue("MEURHLOG" ,aDados[1][2]) == "1"
else
   cHosts      := ""
   aHosts      := {}
   cRestServer := ""
   nRestPort   := 0
   lMeuRHLog   := .F.
EndIf

Return {nRestPort,cRestServer,lMeuRHLog,cHosts}


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSockets
Função para carregar o modelo dos Sockets do MRH
/*/
//-------------------------------------------------------------------
Static Function LoadSockets()
Local aAux     AS ARRAY
Local aDados   AS ARRAY
Local aRet     AS ARRAY
Local aSockets AS ARRAY
Local nFor     AS NUMERIC
Local nPos     AS NUMERIC
Local oSocket  AS OBJECT
Local cSockets AS CHARACTER

aDados := WizGetMRH()
aRet   := {}

cSockets := GetParValue("HOSTSREST",aDados[1][2])

If !Empty(cSockets)
    aSockets := StrTokArr( cSockets , ',' )
    //varinfo("aSockets: ", aSockets)

    //A primeira ocorrência dos hosts do MeuRH, pertence ao endereço raiz do servidor REST
    //sendo assim a leitura se inicia a partir da segunda ocorrência 
    For nFor := 2 To Len(aSockets)
        If ( nPos := aScan( aDados , {|aDado| aDado[1] == aSockets[nFor] } ) ) > 0
            aAux := aDados[nPos][2]
            oSocket := FWIniMRHSocket():New(aDados[nPos][1])
            oSocket:LoadFromArray( aAux )

            aAdd( aRet , {nFor, oSocket:GetDataArray() })
        EndIf
    Next
EndIf


If Empty(aRet)
    oSocket := FWIniMRHSocket():New()
    oSocket:LoadDefault()
    aAdd( aRet , {1,oSocket:GetDataArray()})
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc}  funções vldPort, vldServer, vldHost, VldPATH
Funções de validação do modelo de dados
/*/
//-------------------------------------------------------------------
Function vldPort()
Local oModel	   := FwModelActive()
Local nI, nPos     := 0
Local lRet         := .T.
Local aSections    := GetIniSessions(APXSRVINI_FILENAME)
Local cRestSockets := alltrim(GetPvProfString( "HTTPV11", "SOCKETS", "", APXSRVINI_FILENAME ))
Local cRestPortMRH := ""
Local cRestPort    := ""
Local aSockets     := {}

nPos := ascan( aSections, "HTTPV11" )
If( nPos <= 0 )
   //"Serviço REST não localizado"
   //'Configure inicialmente o serviço REST, antes de configurar o App MeuRH.'
   Help( ,, OemToAnsi(STR0014),, OemToAnsi(STR0015), 1, 0 )
   lRet := .F.
ElseIf Empty(cRestSockets)
   //"Serviço REST não localizado"
   //"Nenhum socket REST foi localizado, avalie suas configurações REST"
   //MsgStop(STR0016,STR0014) 
   Help( ,, OemToAnsi(STR0014),, OemToAnsi(STR0016), 1, 0 )
   lRet := .F.
EndIf


If lRet
   cRestPortMRH := AllTrim( str(oModel:getValue("MRHMASTER","RESTPORT") ))

   If !Empty(cRestPortMRH)
       aSockets := StrTokArr( cRestSockets , ',' )

       lRet := .F.
       For nI := 1 To Len(aSockets)
       
          cRestPort := alltrim( GetPvProfString( aSockets[nI], "PORT", "", APXSRVINI_FILENAME ) )
          If cRestPortMRH == cRestPort    
             lRet := .T.
          EndIf

       Next

       If !lRet
          //"Porta REST invalida"
          //"Não foi localizada nos serviço REST a porta informada"
          //MsgStop(STR0018,STR0017) 
          Help( ,, OemToAnsi(STR0017),, OemToAnsi(STR0018), 1, 0 )
          lRet := .F.
       EndIf
   EndIf    

EndIf

Return lRet

Function vldServer()
Local oModel	 := FwModelActive()
Local lRet       := .T.
Local cPortMRH   := ""
Local cServerMRH := ""
   
cPortMRH   := AllTrim( str(oModel:getValue("MRHMASTER","RESTPORT") ))
cServerMRH := AllTrim( oModel:getValue("MRHMASTER","RESTSERVER") )

If !empty(cServerMRH) .and. !(cPortMRH $ cServerMRH)
    //"Hosts do MeuRH"
    //"Porta do REST não localizada na URL do serviço REST"
    Help( ,, OemToAnsi(STR0009),, OemToAnsi(STR0025), 1, 0 )
    lRet := .F.
ElseIf !empty(cServerMRH) .and. ( !("http://" $ cServerMRH) .and. !("https://" $ cServerMRH) ) 
    //"Hosts do MeuRH"
    //"Não foi localizado http ou https na url informada"
    Help( ,, OemToAnsi(STR0009),, OemToAnsi(STR0029), 1, 0 )
    lRet := .F.
EndIf

Return lRet

Function vldHost()
Local oModel	:= FwModelActive()
Local nI        := 0
Local cHostPort := "" 
Local lRet      := .T.
Local cHost     := AllTrim(oModel:getValue("MRHSOCKET","NOME"))    
Local cPortHTTP := alltrim(GetPvProfString( "HTTP", "PORT", "", APXSRVINI_FILENAME ))

If Empty(cPortHTTP)
   //'Porta HTTP não localizada'
   //'Configure inicialmente o serviço HTTP, antes de configurar o App MeuRH.'
   Help( ,, OemToAnsi(STR0010),, OemToAnsi(STR0011), 1, 0 )
   lRet := .F.
EndIf

If lRet .and. !empty(cHost)
  
   For nI := At(":" , cHost) + 1  To Len(cHost)  Step 1
          
       cCaracter := SubStr( cHost, nI, 1 )
       If cCaracter == "/"
          exit
       ElseIf FwIsNumeric( cCaracter )
          cHostPort := cHostPort + cCaracter   
       EndIf  

   Next
      
   If !empty(cHostPort) .and. (cHostPort != cPortHTTP)
      //'Porta HTTP invalida'
      //'Porta HTTP do Host não confere com a porta HTTP configurada.'
      Help( ,, OemToAnsi(STR0012),, OemToAnsi(STR0013), 1, 0 )
      lRet := .F.
   EndIf
   
EndIf

Return lRet

Function vldPATH()
Local oModel	:= FwModelActive()
Local lRet      := .T.
Local cPATH     := AllTrim(oModel:getValue("MRHSOCKET","PATH"))    

If !empty(cPATH) .and. !existDir(cPATH)
   //"Hosts do MeuRH"
   //"Não foi localizado o PATH informado"
   Help( ,, OemToAnsi(STR0009),, OemToAnsi(STR0030), 1, 0 )
   lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} criaProp
Criação do novo arquivo ''properties.json''
/*/
//-------------------------------------------------------------------
Static Function criaProp(baseUrl, rootContext)
Local cProperties := ""

     cProperties := '{'                                                                                   +CRLF
     cProperties += '	"ERP": 3,'                                                                        +CRLF
     cProperties += '	"PROPS": {'                                                                       +CRLF
     cProperties += '		"baseUrl": "'      +baseURL     +'",'                                         +CRLF
     cProperties += '		"rootContext": "/' +rootContext +'/"'                                         +CRLF
     cProperties += '	},'                                                                               +CRLF
     cProperties += ' '                                                                                   +CRLF
     cProperties += '	"EXTERNAL_APP_RESPONSE": ['                                                       +CRLF
     cProperties += '		{'                                                                            +CRLF
     cProperties += '			"id": "tfs",'                                                             +CRLF
     cProperties += '			"nameShort": {'                                                           +CRLF
     cProperties += '				"pt": "Financeiro",'                                                  +CRLF
     cProperties += '				"en": "Financial"'                                                    +CRLF
     cProperties += '			},'                                                                       +CRLF
     cProperties += '			"nameLong": {'                                                            +CRLF
     cProperties += '				"pt": "Serviços Financeiros",'                                        +CRLF
     cProperties += '				"en": "Financial Services"'                                           +CRLF
     cProperties += '			},'                                                                       +CRLF
     cProperties += '			"url": "https://totvs.myconsig.com.br/tokens/{token}",'                   +CRLF
     cProperties += '			"urlStaging": "https://staging-totvs.myconsig.com.br/tokens/{token}",'    +CRLF
     cProperties += '			"icon": "ico-money",'                                                     +CRLF
     cProperties += '			"enabled": false,'                                                        +CRLF
     cProperties += '			"grouperId": "paymentSubMenu",'                                           +CRLF
     cProperties += '			"useStagingEnvironment": false'                                           +CRLF
     cProperties += '		}'                                                                            +CRLF
     cProperties += '	]'                                                                                +CRLF
     cProperties += '}'                                                                                   +CRLF
     
Return cProperties



//-------------------------------------------------------------------
/*/{Protheus.doc} FWIniMRHSocket
Classe auxiliar para lidar com Sockets do MRH no INI
/*/
//-------------------------------------------------------------------
CLASS FWIniMRHSocket FROM LongNameClass

    DATA cName       AS CHARACTER
    DATA lHostEnable AS LOGICAL
    DATA cPath       AS CHARACTER
    DATA cPage       AS CHARACTER

    METHOD New()
    METHOD LoadFromArray()
    METHOD LoadDefault()
    METHOD GetDataArray()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor

@param cName Nome do Socket
/*/
//-------------------------------------------------------------------
METHOD New( cName ) CLASS FWIniMRHSocket
    self:cName := cName
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFromArray
Método que faz o Load dos dados a partir do Array da ApWizLib

@param aArray Array de dados
/*/
//-------------------------------------------------------------------
METHOD LoadFromArray( aArray ) CLASS FWIniMRHSocket
    self:cPath       := Padr( GetParValue( 'PATH' , aArray ) , FIELD_STRING_SIZE )
    self:cPage       := Padr( GetParValue( 'DEFAULTPAGE' , aArray ) , FIELD_STRING_SMALL )
    self:lHostEnable := GetParValue( 'ENABLE' , aArray ) == '1'
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDefault
Método que faz o Load com dados em branco
/*/
//-------------------------------------------------------------------
METHOD LoadDefault(  ) CLASS FWIniMRHSocket
    self:cName       := Padr( "", FIELD_URL_SIZE )
    self:cPath       := Padr( "", FIELD_STRING_SIZE )
    self:cPage       := Padr( "", FIELD_STRING_SMALL )
    self:lHostEnable := .F.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataArray
Retorna um array com os dados na ordem esperada pelo modelo de dados
/*/
//-------------------------------------------------------------------
METHOD GetDataArray() CLASS FWIniMRHSocket
Local aRet AS ARRAY

aRet := Array(4)

aRet[1] := self:cName
aRet[2] := self:lHostEnable
aRet[3] := self:cPath
aRet[4] := self:cPage

Return aRet
