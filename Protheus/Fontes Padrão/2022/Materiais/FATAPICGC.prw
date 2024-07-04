#Include 'Protheus.ch'
#Include 'FatApiCgc.ch'

Static lMVCCustomer	:= MA030IsMVC()
Static lMvAPIFor     := SuperGetMv("MV_APICCGC", .F., .F.)
Static _nTmDDD       := GetSX3Cache("A1_DDD", "X3_TAMANHO")
Static _nTmTel       := GetSX3Cache("A1_TEL", "X3_TAMANHO")

/*/{Protheus.doc} M030ApiCgc
	Função para automatizar o preenchimento dos dados do cadatro de cliente via API Carol pela função APIFORCLI.
   OBS: Somente Executado via Interface Grafica
	@type  Function
	@author Paulo V. Beraldo
	@since Jan/2021
	@param 
	@return cCNPJ = Código do CNPJ informado pelo cliente
/*/
Function M030ApiCgc()

Local lRet           := .T.
Local nInd           := 0
Local aSetCpo        := {}
Local aRet           := {}
Local aRetCpo        := {}
Local aSx3Cpo        := {}
Local aRetJson       := {}
Local cCNPJ          := &(ReadVar())
Local cCpoRead       := ReadVar() 
Local oField 	      := Nil
Local oModel 	      := Nil
Local oRetJson       := Nil
Local oRest          := Nil

cCpoRead := SubStr( cCpoRead, At( '>', AllTrim( cCpoRead ) ) + 1 )

If lMvAPIFor .AND. !IsBlind() .AND. Len(AllTrim(cCNPJ)) == 14 .AND. Type(cCNPJ) == "N"
   If !( FindFunction( 'APIForCli' ) )
      Help(" ",1,STR0001 ,, STR0002 , 1, 0 ) //"Atenção" | "Função APIForCli não compilada no RPO"
   Else
      If cCpoRead == 'A1_CGC'
         aSx3Cpo := { 'A1_NOME', 'A1_NREDUZ', 'A1_EST', 'A1_CEP', 'A1_BAIRRO', 'A1_MUN', 'A1_END', 'A1_PESSOA', 'A1_DDD', 'A1_TEL', 'A1_CNAE' }
      EndIf

      aRetJson := APIForCli(cCNPJ) // Realiza o POST de consulta CNPJ na Carol
      oRest    := JsonObject():New()
      oRest:FromJson(aRetJson[2])
      aRet     := oRest:GetJsonObject("hits")

      If ValType(aRet) == "U" .OR. Len(aRet) == 0
         Aviso( STR0001 , IIf('"count":0' $ aRetJson[2],;
                              STR0006,;
                              aRetJson[2]) ,{ STR0005 }, 3 ) // "Atenção" | "Dados não encontrados na CAROL" | "Abortar Processo"
         lRet := .F.
      Else
         If !( aRetJson[1] )
            Aviso( STR0001 , aRetJson[2] ,{ STR0005 }, 3 ) // "Atenção" | "Abortar Processo"
            lRet := .F.
         Else
            oRetJson := oRest["hits"][1]["mdmGoldenFieldAndValues"]
            For nInd := 1 To Len( aSx3Cpo )
               aRetCpo := M030GetVal( oRetJson, aSx3Cpo[ nInd ], cCpoRead )
               Aadd( aSetCpo,{ aSx3Cpo[ nInd ], aRetCpo[ 1 ][ 1 ], aRetCpo[ 1 ][ 2 ] } )
            Next nInd
            // Verificando se algum campo está valor excedido. 
            For nInd := 1 To Len( aSetCpo )
               If Len(AllTrim(aSetCpo[ nInd ][ 2 ])) > GetSX3Cache(aSetCpo[ nInd ][ 1 ], "X3_TAMANHO")
                  aSetCpo[ nInd ][ 2 ] := Space(GetSX3Cache(aSetCpo[ nInd ][ 1 ], "X3_TAMANHO"))
               ElseIf Len(AllTrim(aSetCpo[ nInd ][ 2 ])) < GetSX3Cache(aSetCpo[ nInd ][ 1 ], "X3_TAMANHO")
                  aSetCpo[ nInd ][ 2 ] := PadR(aSetCpo[ nInd ][ 2 ] , GetSX3Cache(aSetCpo[ nInd ][ 1 ], "X3_TAMANHO"))
               EndIf   
            Next nInd

            If lMVCCustomer
               oModel := FWModelActive()
               oField := oModel:GetModel("SA1MASTER") 
               If !Empty( oField:GetValue( 'A1_NREDUZ' ) )
                  oField:ClearField( 'A1_NREDUZ' )
               EndIf

               If !Empty( oField:GetValue( 'A1_NOME' ) )
                  oField:ClearField( 'A1_NOME' )
               EndIf
            EndIf

            //Bloco de Gravacao dos Campos e Modelo
            For nInd := 1 To Len( aSetCpo )
               lRet := M030SetVal( oField, aSetCpo[ nInd ][ 1 ], aSetCpo[ nInd ][ 2 ], aSetCpo[ nInd ][ 3 ], 1 )
            Next nInd
         EndIf
      EndIf
   EndIf
EndIf

Return cCNPJ

/*/{Protheus.doc} M030SetVal
   Funcao Responsavel por Validar e Gravar a Informacao Recebida Via API no Formulario Protheus
   @type  Static Function
   @author Paulo V. Beraldo
   @since Jan/2021
   @version 1.00
   @param oModel, Object   , Modelo Ativo Sendo Utilizado
   @param xCampo, Caracter , Nome do Campo do Formulario que Esta Recebendo Informacao
   @param xValue, Indefine , Conteudo a Ser Validado e Gravado no Campo do Formulario
   @param lValid, Boolean  , Executa a Validacao de Sistema e de Usuario
   @param nOpcx , Integer  , Informa Se o Processo e de Gravacao ou Limpeza do Campo
   @return lRet , Boolean  , Informa se o Campo Foi Preenchido com Sucesso
/*/
Static Function M030SetVal( oModel, xCampo, xValue, lValid, nOpcx )

Local lRet        := .T.
Local nX3Tam      := 0
Local cX3Tipo     := ""
Local cX3Valid    := ""
Local cX3VldUsr   := ""
Local cValid      := ""

Default nOpcx     := 1
Default lValid    := .F.
Default xValue    := CriaVar( xCampo, .F. )

If lMVCCustomer
   If nOpcx == 1
      lRet := oModel:SetValue( xCampo, xValue )
   Else
      oModel:ClearField( xCampo )
   EndIf
Else
   If nOpcx == 1
      nX3Tam   := GetSx3Cache(xCampo, 'X3_TAMANHO')
      cX3Tipo  := GetSx3Cache(xCampo, 'X3_TIPO')
      If ( Len( AllTrim(xValue) ) > nX3Tam .Or. ( cX3Tipo # ValType(xValue) ) )
         lRet := .F.
      Else
         SetMemVar( xCampo, xValue )
         If lValid
            cX3Valid    := AllTrim(GetSx3Cache(xCampo, 'X3_VALID'))
            cX3VldUsr   := AllTrim(GetSx3Cache(xCampo, 'X3_VLDUSER'))
            cValid      := cX3Valid + IIf(!Empty(cX3Valid) .AND. !Empty(cX3VldUsr), " .AND. ", "") + cX3VldUsr
            lRet        := IIf(Empty(cValid),;
                               .T.,;
                               &(cValid))
         EndIf
      EndIf
   Else
      SetMemVar( xCampo, CriaVar( xCampo, .F. ) )
   EndIf
EndIf

Return lRet


/*/{Protheus.doc} M030GetVal
   Funcao Responsavel por Retornar o Conteudo para o Campo Informado
   @type  Static Function
   @author Paulo V. Beraldo
   @since Fev/2021
   @version 1.00
   @param oRetJson, Object    , Objeto Json Com as Informações da Entidade
   @param cSx3Cpo , Caracter  , Campo Sx3 que Esta Sendo Informado
   @param cCpoRead, Caracter  , Campo que esta Executando o Gatilho com Integração
   @return xRet   , Undefined , Conteudo Capturado via Integracao do Objeto Json
/*/
Static Function M030GetVal( oRetJson, cSx3Cpo, cCpoRead )

Local xRet  := Nil
Local aRet  := {}
Local aTel  := RemDddTel( oRetJson["mdmphone"][2]["mdmphonenumber"] )

If cCpoRead == 'A1_CGC'
   Do Case
      Case cSx3Cpo == 'A1_NOME'
         Aadd( aRet, { Upper( DecodeUTF8( oRetJson["mdmname"] ) ), .F. } )
      Case cSx3Cpo == 'A1_NREDUZ'
         Aadd( aRet, { Upper( oRetJson["mdmdba"] ), .F. } )
      Case cSx3Cpo == 'A1_EST'
         Aadd( aRet, { oRetJson["mdmaddress"][1]["mdmstate"], .F. } )
      Case cSx3Cpo == 'A1_CEP'
         Aadd( aRet, { oRetJson["mdmaddress"][1]["mdmzipcode"], .F. } )
      Case cSx3Cpo == 'A1_BAIRRO'
         Aadd( aRet, { oRetJson["mdmaddress"][1]["mdmaddress3"], .F. } )
      Case cSx3Cpo == 'A1_MUN'                     
         Aadd( aRet, { oRetJson["mdmaddress"][1]["mdmcity"], .F. } )
      Case cSx3Cpo == 'A1_END'                     
         Aadd( aRet, { Upper( oRetJson["mdmaddress"][1]["mdmaddress1"] ), .F. } )
      Case cSx3Cpo == 'A1_PESSOA'                  
         Aadd( aRet, { Iif( Len( AllTrim( oRetJson["mdmtaxid"] ) ) == 11,;
                            "F",;
                            "J" ), .F. } )
      Case cSx3Cpo == 'A1_DDD'
         Aadd( aRet, { IIf( Empty(aTel[2]),;
                            Space(_nTmDDD),;
                            PadR(aTel[2], _nTmDDD) ), .F. } )
      Case cSx3Cpo == 'A1_TEL'
         Aadd( aRet, { IIf( Empty(aTel[1]),;
                            Space(_nTmTel),;
                            PadR(aTel[1], _nTmTel) ), .F. } )
      Case cSx3Cpo == 'A1_CNAE'
         If !Empty( oRetJson["cnaebr"] )
            If Len( AllTrim( oRetJson["cnaebr"] ) ) == 7
               xRet := SubStr( oRetJson["cnaebr"], 1, 4 ) +'-'+ SubStr( oRetJson["cnaebr"], 5, 1 ) +'/'+ SubStr( oRetJson["cnaebr"], 6, 2 )
            Else
               xRet := oRetJson["cnaebr"]
            EndIf
         EndIf
         Aadd( aRet, { xRet, .T. } )
   EndCase

EndIf

Return aRet
