#INCLUDE "PWSF040.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE FORNECERP_ENTIDADE     1
#DEFINE FORNECERP_CODIGO       2
#DEFINE FORNECERP_NOMEFANT     3
#DEFINE FORNECERP_RAZAOSOC     4
#DEFINE FORNECERP_CPFCNPJ      5

#DEFINE FORNEC_CADASTRO        1
#DEFINE FORNEC_ENDERECOS       2
#DEFINE FORNEC_TELEFONES       3

#DEFINE FORNEC_TYPEOFADDRESSES 1
#DEFINE FORNEC_TYPEOFPHONES    2

#DEFINE MYUSERCODE GetUsrCode()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF04*   ºAutor  ³Flavio Luiz Vicco    º Data ³  21/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este fonte possui as funcionalidades relacionado a          º±±
±±º          ³ Alteracao dos Dados Cadastrais do Fornecedor.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºComents   ³ Aphs Envolvidos :                                           º±±
±±º          ³ PWSF020.APH       Seleção de Fornecedores                   º±±
±±º          ³ PWSF041.APH       Dados do Fornecedor , Endereços e Fones   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF040   ºAutor  ³ Flavio Luiz Vicco   º Data ³  21/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra os fornecedores disponives para o usuario logado.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSF040()

Local cHtml := ""   

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fornecedores cadastrados para o usuario logado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpPost->PWSF020FOR := GetUserFor()
HttpSession->PWSF020FOR := HttpPost->PWSF020FOR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem utilizadas pelo APH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSF020APH := {	STR0001,;               // Titulo  //"Gerenciamento de Informações Cadastrais"
                              "W_PWSF041.APW",;       // Proxima Tela
                              "" }                    // Msg de Erro

HttpSession->PWSF040APH := { STR0002 ,;              // Titulo  //"Dados Cadastrais"
                              "" }                    // Msg de Erro

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao ha fornecedores cadastrados para o usuario logado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Empty( HttpPost->PWSF020FOR )
      HttpSession->PWSF020APH[3] := STR0003 //"Não há Fornecedores a consultar."
      cHtml += ExecInPage( "PWSF020" )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas 1 fornecedor cadastrado.                               ³
	//³ Define a navegação para pular a tela de seleção de Fornecedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Len( HttpPost->PWSF020FOR ) == 2
      HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][FORNECERP_CODIGO]
      cHtml += W_PWSF041()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mais de 1 fornecedor. Chama tela de seleção de Fornecedores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Otherwise
      cHtml += ExecInPage( "PWSF020" )

EndCase

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF041   ºAutor  ³ Flavio Luiz Vicco   º Data ³  21/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Dados Cadastrais , endereços e Telefones.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSF041()

Local cHtml    := ""
Local nI       := 0
Local nPos     := 0
Local aWebCols := {} 
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fornecedor Selecionado                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

HttpPost->PWSF040INFO := { { }, { }, { { }, { } } }

If !Empty( HttpSession->CODFORERP )
   nPos := aScan( HttpSession->PWSF020FOR, { |x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

   If nPos > 0
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inicializa o WS - MTSUPPLIER ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIER"), WSMTSUPPLIER():NEW())
      WsChgUrl( @oObj, "MTSUPPLIER.apw" )

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³    Cabecalho da Pagina      ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      HttpSession->PWSF040APH[1] := STR0004 + HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC] //"Dados Cadastrais : "

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³    Tipos de Estruturas      ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If Empty( HttpSession->PWSF040TYPES )
         HttpSession->PWSF040TYPES := { NIL , NIL }
      EndIf

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Busca os tipos de Enderecos ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If HttpSession->PWSF040TYPES[1] == NIL 
         If oObj:GETTYPEOFADDRESS()
            HttpSession->PWSF040TYPES[1] := oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Atenção"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Busca os tipos de Telefones ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If HttpSession->PWSF040TYPES[2] == NIL 
         If oObj:GETTYPEOFPHONE()
            HttpSession->PWSF040TYPES[2] := oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Atenção"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Header a ser utilizado pelas funcoes GridHeader e GridLinesEx³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If Empty( HttpSession->PWSF040HEADER )
         HttpSession->PWSF040HEADER := { NIL , NIL , NIL , NIL }
      EndIf

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³Busca definição de Header de Informações de Fornecedor³
      //³-SupplierCode     : Codigo do fornecedor              ³
      //³-UnitSupplierCode : Loja do fornecedor                ³
      //³-Name             : Nome do fornecedor                ³
      //³-NickName         : Nome Fantasia                     ³
      //³-FederalID        : CNPJ                              ³
      //³-StateID          : IE                                ³
      //³-DistrictID       : Inscricao Municipal               ³
      //³-HomePage         : Home page                         ³
      //³-Email            : email                             ³
      //³-Addresses        : Enderecos                         ³
      //³-Phones           : Array Of PhoneView OPTIONAL       ³
      //³-UserFields       : Array Of UserField OPTIONAL       ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If HttpSession->PWSF040HEADER[FORNEC_CADASTRO] == NIL 
         If oObj:GETHEADER( "SUPPLIERVIEW" )
            HttpSession->PWSF040HEADER[FORNEC_CADASTRO]	:= oObj:oWSGETHEADERRESULT:OWSBRWHEADER
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Atenção"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Busca definição de Header de Endereços ³
      //³-TypeOfAddress : Tipo do Endereco       ³
      //³-Address       : Endereco               ³
      //³-AddressNumber : Numero                 ³
      //³-District      : Cidade                 ³
      //³-State         : Unidade Federativa     ³
      //³-ZipCode       : CEP                    ³
      //³-Zone          : Bairro                 ³
      //³-Country       : Pais                   ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If HttpSession->PWSF040HEADER[FORNEC_ENDERECOS] == NIL
         If oObj:GETHEADER( "ADDRESSVIEW" )
            HttpSession->PWSF040HEADER[FORNEC_ENDERECOS] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Atenção"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Busca definição de Header de Telefones ³
      //³-TypeOfPhone     : Tipo                 ³
      //³-PhoneNumber     : Telefone             ³
      //³-LocalAreaCode   : DDD                  ³
      //³-CountryAreaCode : DDI                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If HttpSession->PWSF040HEADER[FORNEC_TELEFONES] == NIL 
         If oObj:GETHEADER( "PHONEVIEW" )
            HttpSession->PWSF040HEADER[FORNEC_TELEFONES] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Atenção"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Busca dados do Fornecedor em si ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      oObj:cUSERCODE   := MYUSERCODE
      oObj:cSUPPLIERID := HttpSession->CODFORERP
      //cUSERCODE,cSUPPLIERID
      If oObj:GETSUPPLIER()
         HttpSession->PWSF040RESULT := { oObj:oWSGETSUPPLIERRESULT }
      Else
         Return PWSHtmlAlert ( "", STR0012 /*"Atenção"*/ , "", "W_PWSF040" )
      EndIf

   Else //If nPos > 0
      HttpSession->PWSF020APH[3] := STR0005 //"ERRO PWSF040#001 : Fornecedor Inválido"
   EndIf
EndIf

If Empty( HttpSession->PWSF040HEADER )
   HttpSession->PWSF020APH[3] := STR0006 //"ERRO PWSF040#002 : Acesso Inválido"
EndIf

If !Empty( HttpSession->PWSF020APH[3] )
   // Houve ocorrÊncia de erro ? Volta para a Tela 020
   cHtml += ExecInPage( "PWSF020" )
Else

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tipo de Endereco - COMERCIAL ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nX := aScan( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW,{|x| x:cTYPEOFADDRESS == "1"} )
   If nX == 0
      aAdd(  HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
      aTail( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW ):cTYPEOFADDRESS := "1"
	EndIf
	HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW := aSort(HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW,,,{|x,y| x:cTypeOfAddress < y:cTypeOfAddress })

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tipo de Telefone - COMERCIAL ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nX := aScan( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW,{|x| x:cTYPEOFPHONE == "1"})
   If nX == 0
      aAdd(  HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW, MTSUPPLIER_PHONEVIEW():New() )
      aTail( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW ):cTYPEOFPHONE := "1"			
   EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tipo de Telefone - FAX       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nX := aScan( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW,{|x| x:cTYPEOFPHONE == "2"} )
   If nX == 0
		aAdd(  HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW, MTSUPPLIER_PHONEVIEW():New() )
		aTail( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW ):cTYPEOFPHONE := "2"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tudo Certo ? Sem erro e Session montada ?                 ³
	//³ Monta as variáveis com os Values para preencher a Tela !!!³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   DADOS CADASTRAIS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aWebCols := { }

	If ExistBlock( "PEF041" )
		aWebCols := ExecBlock( "PEF041", .F., .F., {1} )
	Else
		aAdd( aWebCols, { "SUPPLIERCODE"     , "D" } )
		aAdd( aWebCols, { "UNITSUPPLIERCODE" , "D" } )
		aAdd( aWebCols,   "NAME"             )
		aAdd( aWebCols,   "NICKNAME"         )
		aAdd( aWebCols, { "FEDERALID"        , "D" } )
		aAdd( aWebCols, {  "STATEID"         , "D" } )
		aAdd( aWebCols, { "DISTRICTID"       , "D" } )
		aAdd( aWebCols,   "HOMEPAGE"         )
		aAdd( aWebCols,   "EMAIL"            )
	EndIf

	GridLinesEx( { HttpPost->PWSF040INFO[1], ;
					HttpSession->PWSF040HEADER[FORNEC_CADASTRO], ;
					HttpSession->PWSF040RESULT[1], ;
					aWebCols, .T., "H", NIL ,0 },"MTSUPPLIER","SA2")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereco (COMERCIAL) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aWebCols := {}

   If ExistBlock( "PEF041" )
      aWebCols := ExecBlock( "PEF041", .F., .F., {2} )
   Else
      aAdd( aWebCols, "ADDRESS" )
      aAdd( aWebCols, "ADDRESSNUMBER" )
      aAdd( aWebCols, "DISTRICT" )
      aAdd( aWebCols, { "STATE", "N", { "GETUF", ;
                                      { "CSTATE", "CCODE" };
                                      }, ;
                      { "CCODE", "CDESCRIPTION" } } )
      aAdd( aWebCols, "ZIPCODE" )
      aAdd( aWebCols, "ZONE" )
   EndIf

   GridLinesEx( { HttpPost->PWSF040INFO[2], ;
                  HttpSession->PWSF040HEADER[FORNEC_ENDERECOS], ;
                  HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[1], ;
                  aWebCols, .T., "H", "1", 0 },"MTSUPPLIER","SA2" )

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Telefone (COMERCIAL) ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aWebCols := {}

   If ExistBlock( "PEF041" )
      aWebCols := ExecBlock( "PEF041", .F., .F., {3} )
   EndIf

   GridLinesEx( { HttpPost->PWSF040INFO[3][1], ;
                  HttpSession->PWSF040HEADER[FORNEC_TELEFONES], ;
                  HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1], ;
                  aWebCols, .T., "H", "1", 0 },"MTSUPPLIER","SA2")

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³    Telefone (FAX)    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aWebCols := {}

   If ExistBlock( "PEF041" )
      aWebCols := ExecBlock( "PEF041", .F., .F., {4} )
   EndIf

   GridLinesEx( { HttpPost->PWSF040INFO[3][2], ;
                  HttpSession->PWSF040HEADER[FORNEC_TELEFONES], ;
                  HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[2], ;
                  aWebCols, .T., "H", "2", 0 },"MTSUPPLIER","SA2")

   cHtml += ExecInPage( "PWSF040" )
EndIf

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF042   ºAutor  ³ Flavio Luiz Vicco   º Data ³  21/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função de Gravação de Alteração de Dados.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSF042()

Local cHtml := ""
Local nI    := 0
Local cSupplierId
Local oObj
Local nPosSUPPLIERCode := 0
Local nTamSUPPLIERCode := 0
Local nPosUNITSUPPLIERCode := 0
Local nTamUNITSUPPLIERCode := 0

WEB EXTENDED INIT cHtml START "InSite"

cPaisLoc	:= If(Type('cPaisLoc')=='U',"BRA",cPaisLoc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno do Post                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PWSSetObjToPost( HttpSession->PWSF040RESULT[1],                                 HttpSession->PWSF040HEADER[FORNEC_CADASTRO], HttpPost->aPost )
PWSSetObjToPost( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[1], HttpSession->PWSF040HEADER[FORNEC_ENDERECOS], HttpPost->aPost, "1" )
PWSSetObjToPost( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1],      HttpSession->PWSF040HEADER[FORNEC_TELEFONES], HttpPost->aPost, "1" )
PWSSetObjToPost( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[2],      HttpSession->PWSF040HEADER[FORNEC_TELEFONES], HttpPost->aPost, "2" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Enderecos         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW )
   If Empty( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[nI]:cTYPEOFADDRESS )
      HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[nI]:cTYPEOFADDRESS := Str( nI, 1 )
   EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Telefones Comercial e FAX ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW )
   If nI > 1
      HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cCOUNTRYAREACODE := HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1]:cCOUNTRYAREACODE
      HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cLOCALAREACODE   := HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1]:cLOCALAREACODE
   EndIf

   If Empty( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cTYPEOFPHONE )
      HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cTYPEOFPHONE := Str( nI, 1 )
   EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o WS - CFGVALIDATION ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChk := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGVALIDATION"), WSCFGVALIDATION():NEW())
WsChgUrl(@oChk,"CFGVALIDATION.apw")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo CHECKFEDERALID           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSF040RESULT[1]:cFEDERALID )
   //cUSERCODE,cCOUNTRY,cFEDERALID
   oChk:cUSERCODE  := "MSALPHA"
   oChk:cCOUNTRY   := cPaisLoc
   oChk:cFEDERALID := HttpSession->PWSF040RESULT[1]:cFEDERALID
   If !oChk:CHECKFEDERALID()
      Return PWSHTMLALERT( "", STR0007, "", "W_PWSF041.APW" ) //"Erro"
   EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo CHECKSTATEID             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSF040RESULT[1]:cSTATEID )
   //cUSERCODE,cSTATE,cSTATEID
   oChk:cUSERCODE := "MSALPHA"
   oChk:cSTATE    := HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[1]:cSTATE
   oChk:cSTATEID  := HttpSession->PWSF040RESULT[1]:cSTATEID
   If !oChk:CHECKSTATEID()
      Return PWSHTMLALERT( "", STR0007, "", "W_PWSF041.APW" ) //"Erro"
   EndIf
EndIf

//-- Busca tamanho do campo A2_COD
nPosSUPPLIERCode := aScan( HttpSession->PWSF040HEADER[FORNEC_CADASTRO],{|x|x:cHeaderField == "SUPPLIERCODE"})
nTamSUPPLIERCode := HttpSession->PWSF040HEADER[FORNEC_CADASTRO,nPosSUPPLIERCode]:nHeaderSize

nPosUNITSUPPLIERCode := aScan( HttpSession->PWSF040HEADER[FORNEC_CADASTRO],{|x|x:cHeaderField == "UNITSUPPLIERCODE"})
nTamUNITSUPPLIERCode := HttpSession->PWSF040HEADER[FORNEC_CADASTRO,nPosUNITSUPPLIERCode]:nHeaderSize

cSupplierId := Padr(HttpSession->PWSF040RESULT[1]:cSUPPLIERCode,nTamSUPPLIERCode) + ;
			   Padr(HttpSession->PWSF040RESULT[1]:cUnitSUPPLIERCode,nTamUNITSUPPLIERCode)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o WS - MTSUPPLIER ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIER"), WSMTSUPPLIER():NEW())
WsChgUrl( @oObj, "MTSUPPLIER.apw" )

oObj:cUSERCODE   := MYUSERCODE
oObj:cSUPPLIERID := cSupplierId
oObj:oWSSUPPLIER := HttpSession->PWSF040RESULT[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo PUTSUPPLIER              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cUSERCODE,cSUPPLIERID,oWSSUPPLIER
If oObj:PUTSUPPLIER()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tudo Certo ? Recarrega dados do Fornecedor ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   HttpSession->CODFORERP := cSupplierId
   Return PWSHTMLALERT( "", STR0008, STR0009, "W_PWSF041.APW" ) //"Aviso"###"Alteracoes efetuadas com SUCESSO!"
Else
   Return PWSHTMLALERT( "", STR0007, "", "W_PWSF041.APW" ) //"Erro"
EndIf

WEB EXTENDED END

Return cHtml
