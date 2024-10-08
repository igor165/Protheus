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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF04*   �Autor  �Flavio Luiz Vicco    � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a          ���
���          � Alteracao dos Dados Cadastrais do Fornecedor.               ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Coments   � Aphs Envolvidos :                                           ���
���          � PWSF020.APH       Sele��o de Fornecedores                   ���
���          � PWSF041.APH       Dados do Fornecedor , Endere�os e Fones   ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF040   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os fornecedores disponives para o usuario logado.    ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF040()

Local cHtml := ""   

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//�Fornecedores cadastrados para o usuario logado�
//������������������������������������������������
HttpPost->PWSF020FOR := GetUserFor()
HttpSession->PWSF020FOR := HttpPost->PWSF020FOR

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSF020APH := {	STR0001,;               // Titulo  //"Gerenciamento de Informa��es Cadastrais"
                              "W_PWSF041.APW",;       // Proxima Tela
                              "" }                    // Msg de Erro

HttpSession->PWSF040APH := { STR0002 ,;              // Titulo  //"Dados Cadastrais"
                              "" }                    // Msg de Erro

Do Case
	//�������������������������������������������������������
	//�Nao ha fornecedores cadastrados para o usuario logado�
	//�������������������������������������������������������
	Case Empty( HttpPost->PWSF020FOR )
      HttpSession->PWSF020APH[3] := STR0003 //"N�o h� Fornecedores a consultar."
      cHtml += ExecInPage( "PWSF020" )
	
	//��������������������������������������������������������������Ŀ
	//�Apenas 1 fornecedor cadastrado.                               �
	//� Define a navega��o para pular a tela de sele��o de Fornecedor�
	//����������������������������������������������������������������
	Case Len( HttpPost->PWSF020FOR ) == 2
      HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][FORNECERP_CODIGO]
      cHtml += W_PWSF041()

	//�������������������������������������������������������������
	//�Mais de 1 fornecedor. Chama tela de sele��o de Fornecedores�
	//�������������������������������������������������������������
	Otherwise
      cHtml += ExecInPage( "PWSF020" )

EndCase

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF041   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Dados Cadastrais , endere�os e Telefones.                   ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF041()

Local cHtml    := ""
Local nI       := 0
Local nPos     := 0
Local aWebCols := {} 
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

HttpPost->PWSF040INFO := { { }, { }, { { }, { } } }

If !Empty( HttpSession->CODFORERP )
   nPos := aScan( HttpSession->PWSF020FOR, { |x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

   If nPos > 0
      //������������������������������Ŀ
      //� Inicializa o WS - MTSUPPLIER �
      //��������������������������������
      oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIER"), WSMTSUPPLIER():NEW())
      WsChgUrl( @oObj, "MTSUPPLIER.apw" )

      //�����������������������������Ŀ
      //�    Cabecalho da Pagina      �
      //�������������������������������
      HttpSession->PWSF040APH[1] := STR0004 + HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC] //"Dados Cadastrais : "

      //�����������������������������Ŀ
      //�    Tipos de Estruturas      �
      //�������������������������������
      If Empty( HttpSession->PWSF040TYPES )
         HttpSession->PWSF040TYPES := { NIL , NIL }
      EndIf

      //�����������������������������Ŀ
      //� Busca os tipos de Enderecos �
      //�������������������������������
      If HttpSession->PWSF040TYPES[1] == NIL 
         If oObj:GETTYPEOFADDRESS()
            HttpSession->PWSF040TYPES[1] := oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Aten��o"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //�����������������������������Ŀ
      //� Busca os tipos de Telefones �
      //�������������������������������
      If HttpSession->PWSF040TYPES[2] == NIL 
         If oObj:GETTYPEOFPHONE()
            HttpSession->PWSF040TYPES[2] := oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Aten��o"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

     //�������������������������������������������������������������Ŀ
     //�Header a ser utilizado pelas funcoes GridHeader e GridLinesEx�
     //���������������������������������������������������������������
      If Empty( HttpSession->PWSF040HEADER )
         HttpSession->PWSF040HEADER := { NIL , NIL , NIL , NIL }
      EndIf

      //��������������������������������������������������������
      //�Busca defini��o de Header de Informa��es de Fornecedor�
      //�-SupplierCode     : Codigo do fornecedor              �
      //�-UnitSupplierCode : Loja do fornecedor                �
      //�-Name             : Nome do fornecedor                �
      //�-NickName         : Nome Fantasia                     �
      //�-FederalID        : CNPJ                              �
      //�-StateID          : IE                                �
      //�-DistrictID       : Inscricao Municipal               �
      //�-HomePage         : Home page                         �
      //�-Email            : email                             �
      //�-Addresses        : Enderecos                         �
      //�-Phones           : Array Of PhoneView OPTIONAL       �
      //�-UserFields       : Array Of UserField OPTIONAL       �
      //��������������������������������������������������������
      If HttpSession->PWSF040HEADER[FORNEC_CADASTRO] == NIL 
         If oObj:GETHEADER( "SUPPLIERVIEW" )
            HttpSession->PWSF040HEADER[FORNEC_CADASTRO]	:= oObj:oWSGETHEADERRESULT:OWSBRWHEADER
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Aten��o"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //������������������������������������������
      //� Busca defini��o de Header de Endere�os �
      //�-TypeOfAddress : Tipo do Endereco       �
      //�-Address       : Endereco               �
      //�-AddressNumber : Numero                 �
      //�-District      : Cidade                 �
      //�-State         : Unidade Federativa     �
      //�-ZipCode       : CEP                    �
      //�-Zone          : Bairro                 �
      //�-Country       : Pais                   �
      //������������������������������������������
      If HttpSession->PWSF040HEADER[FORNEC_ENDERECOS] == NIL
         If oObj:GETHEADER( "ADDRESSVIEW" )
            HttpSession->PWSF040HEADER[FORNEC_ENDERECOS] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Aten��o"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //����������������������������������������Ŀ
      //� Busca defini��o de Header de Telefones �
      //�-TypeOfPhone     : Tipo                 �
      //�-PhoneNumber     : Telefone             �
      //�-LocalAreaCode   : DDD                  �
      //�-CountryAreaCode : DDI                  �
      //������������������������������������������
      If HttpSession->PWSF040HEADER[FORNEC_TELEFONES] == NIL 
         If oObj:GETHEADER( "PHONEVIEW" )
            HttpSession->PWSF040HEADER[FORNEC_TELEFONES] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
         Else
            Return PWSHtmlAlert ( "", STR0012 /*"Aten��o"*/ , "", "W_PWSF040" )
         EndIf
      EndIf

      //���������������������������������Ŀ
      //� Busca dados do Fornecedor em si �
      //�����������������������������������
      oObj:cUSERCODE   := MYUSERCODE
      oObj:cSUPPLIERID := HttpSession->CODFORERP
      //cUSERCODE,cSUPPLIERID
      If oObj:GETSUPPLIER()
         HttpSession->PWSF040RESULT := { oObj:oWSGETSUPPLIERRESULT }
      Else
         Return PWSHtmlAlert ( "", STR0012 /*"Aten��o"*/ , "", "W_PWSF040" )
      EndIf

   Else //If nPos > 0
      HttpSession->PWSF020APH[3] := STR0005 //"ERRO PWSF040#001 : Fornecedor Inv�lido"
   EndIf
EndIf

If Empty( HttpSession->PWSF040HEADER )
   HttpSession->PWSF020APH[3] := STR0006 //"ERRO PWSF040#002 : Acesso Inv�lido"
EndIf

If !Empty( HttpSession->PWSF020APH[3] )
   // Houve ocorr�ncia de erro ? Volta para a Tela 020
   cHtml += ExecInPage( "PWSF020" )
Else

   //������������������������������Ŀ
   //� Tipo de Endereco - COMERCIAL �
   //��������������������������������
   nX := aScan( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW,{|x| x:cTYPEOFADDRESS == "1"} )
   If nX == 0
      aAdd(  HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
      aTail( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW ):cTYPEOFADDRESS := "1"
	EndIf
	HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW := aSort(HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW,,,{|x,y| x:cTypeOfAddress < y:cTypeOfAddress })

   //������������������������������Ŀ
   //� Tipo de Telefone - COMERCIAL �
   //��������������������������������
   nX := aScan( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW,{|x| x:cTYPEOFPHONE == "1"})
   If nX == 0
      aAdd(  HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW, MTSUPPLIER_PHONEVIEW():New() )
      aTail( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW ):cTYPEOFPHONE := "1"			
   EndIf

   //������������������������������Ŀ
   //� Tipo de Telefone - FAX       �
   //��������������������������������
   nX := aScan( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW,{|x| x:cTYPEOFPHONE == "2"} )
   If nX == 0
		aAdd(  HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW, MTSUPPLIER_PHONEVIEW():New() )
		aTail( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW ):cTYPEOFPHONE := "2"
	EndIf

	//�����������������������������������������������������������Ŀ
	//� Tudo Certo ? Sem erro e Session montada ?                 �
	//� Monta as vari�veis com os Values para preencher a Tela !!!�
	//�������������������������������������������������������������

	//����������������������Ŀ
	//�   DADOS CADASTRAIS   �
	//������������������������
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

	//����������������������Ŀ
	//� Endereco (COMERCIAL) �
	//������������������������
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

   //����������������������Ŀ
   //� Telefone (COMERCIAL) �
   //������������������������
   aWebCols := {}

   If ExistBlock( "PEF041" )
      aWebCols := ExecBlock( "PEF041", .F., .F., {3} )
   EndIf

   GridLinesEx( { HttpPost->PWSF040INFO[3][1], ;
                  HttpSession->PWSF040HEADER[FORNEC_TELEFONES], ;
                  HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1], ;
                  aWebCols, .T., "H", "1", 0 },"MTSUPPLIER","SA2")

   //����������������������Ŀ
   //�    Telefone (FAX)    �
   //������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF042   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     �Fun��o de Grava��o de Altera��o de Dados.                    ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

//���������������������������������������������������������������������������������Ŀ
//� Retorno do Post                                                                 �
//�����������������������������������������������������������������������������������
PWSSetObjToPost( HttpSession->PWSF040RESULT[1],                                 HttpSession->PWSF040HEADER[FORNEC_CADASTRO], HttpPost->aPost )
PWSSetObjToPost( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[1], HttpSession->PWSF040HEADER[FORNEC_ENDERECOS], HttpPost->aPost, "1" )
PWSSetObjToPost( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1],      HttpSession->PWSF040HEADER[FORNEC_TELEFONES], HttpPost->aPost, "1" )
PWSSetObjToPost( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[2],      HttpSession->PWSF040HEADER[FORNEC_TELEFONES], HttpPost->aPost, "2" )

//���������������������������Ŀ
//�         Enderecos         �
//�����������������������������
For nI := 1 To Len( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW )
   If Empty( HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[nI]:cTYPEOFADDRESS )
      HttpSession->PWSF040RESULT[1]:OWSADDRESSES:OWSADDRESSVIEW[nI]:cTYPEOFADDRESS := Str( nI, 1 )
   EndIf
Next nI

//���������������������������Ŀ
//� Telefones Comercial e FAX �
//�����������������������������
For nI := 1 To Len( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW )
   If nI > 1
      HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cCOUNTRYAREACODE := HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1]:cCOUNTRYAREACODE
      HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cLOCALAREACODE   := HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[1]:cLOCALAREACODE
   EndIf

   If Empty( HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cTYPEOFPHONE )
      HttpSession->PWSF040RESULT[1]:OWSPHONES:OWSPHONEVIEW[nI]:cTYPEOFPHONE := Str( nI, 1 )
   EndIf
Next nI

//���������������������������������Ŀ
//� Inicializa o WS - CFGVALIDATION �
//�����������������������������������
oChk := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGVALIDATION"), WSCFGVALIDATION():NEW())
WsChgUrl(@oChk,"CFGVALIDATION.apw")

//���������������������������������Ŀ
//� Metodo CHECKFEDERALID           �
//�����������������������������������
If !Empty( HttpSession->PWSF040RESULT[1]:cFEDERALID )
   //cUSERCODE,cCOUNTRY,cFEDERALID
   oChk:cUSERCODE  := "MSALPHA"
   oChk:cCOUNTRY   := cPaisLoc
   oChk:cFEDERALID := HttpSession->PWSF040RESULT[1]:cFEDERALID
   If !oChk:CHECKFEDERALID()
      Return PWSHTMLALERT( "", STR0007, "", "W_PWSF041.APW" ) //"Erro"
   EndIf
EndIf

//���������������������������������Ŀ
//� Metodo CHECKSTATEID             �
//�����������������������������������
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

//������������������������������Ŀ
//� Inicializa o WS - MTSUPPLIER �
//��������������������������������
oObj 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIER"), WSMTSUPPLIER():NEW())
WsChgUrl( @oObj, "MTSUPPLIER.apw" )

oObj:cUSERCODE   := MYUSERCODE
oObj:cSUPPLIERID := cSupplierId
oObj:oWSSUPPLIER := HttpSession->PWSF040RESULT[1]

//���������������������������������Ŀ
//� Metodo PUTSUPPLIER              �
//�����������������������������������
//cUSERCODE,cSUPPLIERID,oWSSUPPLIER
If oObj:PUTSUPPLIER()
   //��������������������������������������������Ŀ
   //� Tudo Certo ? Recarrega dados do Fornecedor �
   //����������������������������������������������
   HttpSession->CODFORERP := cSupplierId
   Return PWSHTMLALERT( "", STR0008, STR0009, "W_PWSF041.APW" ) //"Aviso"###"Alteracoes efetuadas com SUCESSO!"
Else
   Return PWSHTMLALERT( "", STR0007, "", "W_PWSF041.APW" ) //"Erro"
EndIf

WEB EXTENDED END

Return cHtml
