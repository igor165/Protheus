#INCLUDE "PWSF020.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE FORNECERP_ENTIDADE 1
#DEFINE FORNECERP_CODIGO   2
#DEFINE FORNECERP_NOMEFANT 3
#DEFINE FORNECERP_RAZAOSOC 4
#DEFINE FORNECERP_CPFCNPJ  5

#DEFINE MYUSERCODE GetUsrCode()

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF02*   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a          ���
���          � Alteracao dos Dados Cadastrais do Fornecedor.               ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Coments.  �Funcoes Pertinentes ao Menu Financeiro (fornecedores):       ���
���          � T�tulos em Aberto		[Ok]		W_PWSF020                     ���
���          �                                                             ���
���          �Aphs Envolvidos :                                            ���
���          � PWSF020.APH 		Sele��o de Fornecedores                   ���
���          � PWSF021.APH 		Browse de Titulos                         ���
���          � PWSF022.APH 		Detalhes dos Titulos                      ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF020   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
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
Web Function PWSF020()

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
HttpSession->PWSF020APH := { STR0001, ;              // Titulo  //"T�tulos em Aberto"
                              "W_PWSF021A.APW", ;      // Proxima Tela
                              ""	}                    // Msg de Erro
	
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
      cHtml += W_PWSF021A()

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
���Programa  �PWSF021A  �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de Busca dos Titulos em Aberto do Fornecedor.          ���
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
Web Function PWSF021A()

Local cHtml    := ""
Local aWebCols := {}
Local oObj
Local oObjIndex

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSF021AAPH := { STR0001, ;             //Titulo //"T�tulos em Aberto"
                              "W_PWSF021.APW", ;      //Proxima Tela
                              "W_PWSF020.APW" }       //Pagina de retorno

//����������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESUPPLIERBILL�
//������������������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WSChgURL( @oObjIndex, "CFGDICTIONARY.APW" )

//�������������������������������������������������������������Ŀ
//�Header a ser utilizado pelas funcoes GridHeader e GridLinesEx�
//���������������������������������������������������������������
If Empty( HttpSession->PWSF021HEADER )
   HttpSession->PWSF021HEADER := { NIL, NIL } 

	//���������������������������������������������Ŀ
   //�Header da estrutura BILLVIEW - Cabec Titulo: �
	//�PREFIX                : Prefixo              �
	//�BILLNUMBER            : No. Titulo           �
	//�INSTALLMENT           : Parcela              �
	//�BILLTYPE              : Tipo                 �
	//�CUSTOMERCODE          : Cliente              �
	//�UNITCUSTOMERCODE      : Loja                 �
	//�CUSTOMERNAME          : Nome                 �
	//�CLASSCODE             : Natureza             �
	//�ISSUEDATE             : DT Emissao           �
	//�ORIGINALDUEDATE       : Vencto Orig          �
	//�REALDUEDATE           : Vencto Real          �
	//�CURRENCY              : Moeda                �
	//�CURRENCYSYMBOL        : Moeda                �
	//�ORIGINALVALUE         : Vlr. Titulo          �
	//�ORIGINALCURRENCYVALUE : Vlr. R$              �
	//�DEDUCTIONSVALUE       : Abatimento           �
	//�DEDUCTIONSVALUE       : Sld.Acresc.          �
	//�INCREASEVALUE         : Sld.Decresc.         �
	//�BALANCEVALUE          : Saldo                �
	//�BALANCECURRENCYVALUE  : Saldo                �
	//�BANK                  : Portador             �
	//�HISTORY               : Historico            �
	//�DELAYINDATES          : Atrasados            �
	//�DELAYINTERESTRATE     : Porc Juros           �
	//�DELAYINTERESTVALUE    : Taxa Perman.         �
	//�����������������������������������������������
   oObj:cHEADERTYPE := "BILLVIEW"
   If oObj:GETHEADER()
      HttpSession->PWSF021HEADER[1] := { oObj:oWSGetHEADERRESULT:oWSBRWHEADER }
   Else
      Return PWSHtmlAlert( "", STR0018 , "", "W_PWSF020.APW" )
   EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSF021HEADER[2] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSF021HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0018 , "", "W_PWSF020.APW" )
		EndIf
	EndIf

EndIf //If Empty

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSF021INDEX )
	HttpSession->PWSF021INDEX := {}
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETINDEX�
	//�������������������������������
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SE2" // Tabela: Contas a Pagar
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//����������������������������Ŀ
		//�Resultado do Metodo GETINDEX�
		//������������������������������
		HttpSession->PWSF021INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0018 , "", "W_PWSF020.APW" )
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSF021AINFO )
	HttpSession->PWSF021AINFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEF021A" )
		aWebCols := ExecBlock( "PEF021A", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   GridHeader( HttpSession->PWSF021AINFO, ;
               HttpSession->PWSF021HEADER[2][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
   GridLinesEx( { HttpSession->PWSF021AINFO, ;
               HttpSession->PWSF021HEADER[2][1], ;
               HttpSession->PWSF021INDEX[1], ;
               aWebCols, .F., "A", NIL, 0 } )
EndIf

cHtml += ExecInPage( "PWSF021A" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF021   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com Browse dos Titulos em Aberto do Fornecedor.        ���
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
Web Function PWSF021()

Local cHtml    := ""
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

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSF021APH := { STR0001, ;              //Titulo //"T�tulos em Aberto"
                              "W_PWSF022.APW", ;      //Proxima Tela
                              "W_PWSF021A.APW" }       //Pagina de retorno


HttpPost->PWSF021INFO := { }

If !Empty( HttpSession->CODFORERP )
   nPos := aScan( HttpSession->PWSF020FOR , {|x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

	If nPos > 0 
      HttpSession->PWSF021APH[1]  := STR0004+HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC] //"T�tulos em Aberto : "

      //�������������������������������������������������������������Ŀ
      //�Header a ser utilizado pelas funcoes GridHeader e GridLinesEx�
      //���������������������������������������������������������������

      //����������������������������������������������Ŀ
      //�Inicializa o objeto WS - WSFINANCESUPPLIERBILL�
      //������������������������������������������������
      oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
      WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )
		
      If Empty( HttpSession->PWSF021HEADER )
         HttpSession->PWSF021HEADER := { NIL, NIL } 

			//���������������������������������������������Ŀ
         //�Header da estrutura BILLVIEW - Cabec Titulo: �
			//�PREFIX                : Prefixo              �
			//�BILLNUMBER            : No. Titulo           �
			//�INSTALLMENT           : Parcela              �
			//�BILLTYPE              : Tipo                 �
			//�CUSTOMERCODE          : Cliente              �
			//�UNITCUSTOMERCODE      : Loja                 �
			//�CUSTOMERNAME          : Nome                 �
			//�CLASSCODE             : Natureza             �
			//�ISSUEDATE             : DT Emissao           �
			//�ORIGINALDUEDATE       : Vencto Orig          �
			//�REALDUEDATE           : Vencto Real          �
			//�CURRENCY              : Moeda                �
			//�CURRENCYSYMBOL        : Moeda                �
			//�ORIGINALVALUE         : Vlr. Titulo          �
			//�ORIGINALCURRENCYVALUE : Vlr. R$              �
			//�DEDUCTIONSVALUE       : Abatimento           �
			//�DEDUCTIONSVALUE       : Sld.Acresc.          �
			//�INCREASEVALUE         : Sld.Decresc.         �
			//�BALANCEVALUE          : Saldo                �
			//�BALANCECURRENCYVALUE  : Saldo                �
			//�BANK                  : Portador             �
			//�HISTORY               : Historico            �
			//�DELAYINDATES          : Atrasados            �
			//�DELAYINTERESTRATE     : Porc Juros           �
			//�DELAYINTERESTVALUE    : Taxa Perman.         �
			//�����������������������������������������������
         oObj:cHEADERTYPE := "BILLVIEW"
         If oObj:GETHEADER()
            HttpSession->PWSF021HEADER[1] := { oObj:oWSGetHEADERRESULT:oWSBRWHEADER }
         Else
            Return PWSHtmlAlert( "", STR0018 , "", "W_PWSF020.APW" )
         EndIf
      EndIf

      //���������������������������������Ŀ
      //� Metodo BRWQUOTE                 �
      //�����������������������������������
      oObj:cUSERCODE      := MYUSERCODE
      oObj:cSUPPLIERID    := HttpSession->CODFORERP
      oObj:cQUERYADDWHERE := ""
      oObj:cINDEXKEY      := HttpPost->cINDEX
      //cUSERCODE,cSUPPLIERID,cQUERYADDWHERE,cINDEXKEY
      If oObj:BRWBILL()
         HttpSession->PWSF021RESULT := { oObj:oWSBRWBILLRESULT:oWSBILLVIEW }
      Else
         Return PWSHtmlAlert( "", STR0018 , "", "W_PWSF020.APW" )
      EndIf

      //���������������������������Ŀ
      //�Verifica Resultado da Busca�
      //�����������������������������
      If !Empty( HttpSession->PWSF021RESULT ) .AND. Len( HttpSession->PWSF021RESULT[1] ) > 0

         //���������������������������Ŀ
         //� Cabecalho dos Titulos     �
         //�����������������������������
         If ExistBlock( "PEF021" )
            aWebCols := ExecBlock( "PEF021", .F., .F., {} )
         Else
            aAdd( aWebCols, "PREFIX" )
            aAdd( aWebCols, "BILLNUMBER" )
            aAdd( aWebCols, "INSTALLMENT" )
            aAdd( aWebCols, "BILLTYPE" )
            aAdd( aWebCols, "ISSUEDATE" )
            aAdd( aWebCols, "REALDUEDATE" )
         EndIf

         GridHeader( HttpPost->PWSF021INFO, ;
                     HttpSession->PWSF021HEADER[1][1], ;
                     aWebCols )
         GridLinesEx( { HttpPost->PWSF021INFO, ;
                        HttpSession->PWSF021HEADER[1][1], ;
                        HttpSession->PWSF021RESULT[1], ;
                        aWebCols, .F., "A", NIL, 0 } )
         
         cHtml += ExecInPage( "PWSF021" )

      Else
	      Return PWSHtmlAlert( "", STR0018 , STR0019 , "W_PWSF020.APW" ) // "A busca n�o retornou nenhum titulo para este fornecedor no per�odo solicitado."
      EndIf

   EndIf //If nPos > 0

EndIf

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF022   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de detalhes dos Titulos a Pagar                        ���
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
Web Function PWSF022()

Local cHtml    := ""
Local nPosTit  := 0
Local nPos     := 0
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSF022APH := { STR0002, ;           // Titulo //"Detalhes do T�tulo"
                              "W_PWSF021.APW" }    // Link p/ Voltar

HttpPost->PWSF022INFO := { }

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

//������������������������������������������������Ŀ
//� Inicializa o objeto WS - WSFINANCESUPPLIERBILL �
//��������������������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

nPosTit := Val( HttpGet->cTitulo )

If nPosTit > 0

	nPosFor := aScan( HttpSession->PWSF020FOR, { |x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

	If nPosFor > 0
		//���������������������������������Ŀ
		//� Metodo GETBILL                  �
		//�����������������������������������
		//cUSERCODE,cSUPPLIERID,cPREFIX,cBILLNUMBER,cINSTALLMENT,cBILLTYPE
		oObj:cUSERCODE    := MYUSERCODE
		oObj:cSUPPLIERID  := HttpSession->CODFORERP
		oObj:cPREFIX      := HttpSession->PWSF021RESULT[1][nPosTit]:cPREFIX
		oObj:cBILLNUMBER  := HttpSession->PWSF021RESULT[1][nPosTit]:cBILLNUMBER
		oObj:cINSTALLMENT := HttpSession->PWSF021RESULT[1][nPosTit]:cINSTALLMENT
		oObj:cBILLTYPE    := HttpSession->PWSF021RESULT[1][nPosTit]:cBILLTYPE
		If oObj:GETBILL()

			If ExistBlock( "PEF022" )
				aWebCols := ExecBlock( "PEF022", .F., .F., {} )
			EndIf

			// --- Temporario : Necessario criar estrutura separada do Ctas a Receber (BILLVIEW)
			If (nPos := aScan(HttpSession->PWSF021HEADER[1][1],{|x| AllTrim(x:cHeaderTitle) == "Cliente"})) >0 
				HttpSession->PWSF021HEADER[1][1][nPos]:cHeaderTitle := STR0023 //"Fornecedor"
			EndIf

			GridLinesEx( { 	HttpPost->PWSF022INFO ,;
							HttpSession->PWSF021HEADER[1][1], ;
							HttpSession->PWSF021RESULT[1][nPosTit], ;
							aWebCols, .F., "H", NIL, 0 }, "FINANCESUPPLIERBILL", "SE2" )

		Else
			Return PWSHtmlAlert( "", STR0018 , "", "W_PWSF021.APW" )
		EndIf
	Else
		Return PWSHtmlAlert( "", STR0018 , "", "W_PWSF021.APW" )
	EndIf

	cHtml += ExecInPage( "PWSF022" )

EndIf

WEB EXTENDED END

Return cHtml
