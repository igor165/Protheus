#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINR231.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINR231   � Autor �Marcelo Akama       � Data �  29/09/2010 ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para imprimir os cheques recebidos                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function FINR231()
Local oReport

Private cPerg := "FIN231"

If TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport	:= ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Marcelo Akama          � Data �29/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local oSection1
Local cAliasQry1	:= GetNextAlias()
Local cAliasQry2    := cAliasQry1
Local nTamForn

/*
+-Preguntas---------------------------------+
�  MV_PAR01    � Banco      ?               �
�  MV_PAR02    � Agencia     ?              �
�  MV_PAR03    � Conta       ?              �
�  MV_PAR04    � Da data de emissao    ?    �
�  MV_PAR05    � Ate a data de emissao ?    �
�  MV_PAR06    � Da data de vencimento ?    �
�  MV_PAR07    � Ate Data de vencimento ?   �
+-------------------------------------------+
*/

//������������������������������������������������Ŀ
//� Requisitos Entidades Bancarias - Julho de 2012 �
//� O Pergunte eh alterado para FIN231B            �
//��������������������������������������������������
  If cPaisLoc == "ARG"
     cPerg := "FIN231B"
  EndIf

Pergunte( cPerg , .T. )

oReport  := TReport():New( "FINR231", STR0001, cPerg , { |oReport| ReportPrint( oReport, @cAliasQry1, @cAliasQry2 ) }, STR0002, .T.) //"Relatorio de Cheques Recebidos"##"Este programa tem como objetivo imprimir os cheques recebidos"

oSection1 := TRSection():New(oReport,STR0003,{"SEF","FRF","SX5"}) //"Cheques"

nTamForn := TamSX3("EF_FORNECE")[1] + TamSX3("EF_LOJA")[1] + 1


   //������������������������������������������������Ŀ
   //� Requisitos Entidades Bancarias - Julho de 2012 �
   //� Alteracao no Lay Out                           �
   //��������������������������������������������������
   If cPaisLoc == "ARG"
      /*
      +-Preguntas---------------------------------+
      �  MV_PAR08    �Considera Abaixo ?          �
      �  MV_PAR09    �Banco Cheque ?              �
      �  MV_PAR10    �Agencia Cheque ?            �
      �  MV_PAR11    �Conta Cheque ?              �
      �  MV_PAR12    �Codigo Postal ?             �
      �  MV_PAR13    �Imprime Banco ?             �
      +-------------------------------------------+
      */

      //--- Verifica se deve levar em conta os Parametros de Entidades Bancarias
      If MV_PAR08 == 1

         If MV_PAR13 == 1        // Por Codigo

            TRCell():New(oSection1,"EF_BANCO"		,"SEF",STR0015			,					,TamSX3("EF_BANCO")[1]		,.F.,{|| (cAliasQry1)->EF_BANCO })   // "Bco. Cheque"
            TRCell():New(oSection1,"EF_AGENCIA"		,"SEF",STR0016			,					,TamSX3("EF_AGENCIA")[1]	,.F.,{|| (cAliasQry1)->EF_AGENCIA }) // "Age. Cheque"
            TRCell():New(oSection1,"EF_POSTAL"		,"SEF",STR0017			,					,TamSX3("EF_POSTAL")[1]		,.F.,{|| (cAliasQry1)->EF_POSTAL })  // "Cod. Postal"

         ElseIf MV_PAR13 == 2    // Por Nome

            TRCell():New(oSection1,"FJO_NOME"		,"FJN",STR0018			,					,TamSX3("FJO_NOME")[1]		,.F.,{|| FI231BCO( (cAliasQry1)->( EF_BANCO ) ) })  // "Bco. Cheque (Bco/Age/Cod. Postal)"

         EndIf

      EndIf

   EndIf
   //�������Ŀ
   //� F I M �
   //���������


TRCell():New(oSection1,"EF_NUM"		,"SEF",STR0005			,					,TamSX3("EF_NUM")[1]		,.F.,{|| (cAliasQry1)->EF_NUM }) // "No. Cheque"
TRCell():New(oSection1,"EF_VALOR"	,"SEF",STR0006			,"@E 99,999,999.99"	,13							,.F.,{|| (cAliasQry1)->EF_VALOR }) // "Valor"
TRCell():New(oSection1,"EF_DATA"	,"SEF",STR0007			,					,18							,.F.,{|| (cAliasQry1)->EF_DATA }) // "Data Emissao"
TRCell():New(oSection1,"EF_VENCTO"	,"SEF",STR0008 			,					,18							,.F.,{|| (cAliasQry1)->EF_VENCTO }) // "Vencimento"
TRCell():New(oSection1,"EF_FORNECE"	,"SEF",STR0009			,					,25							,.F.,{|| (cAliasQry1)->EF_FORNECE + " " + (cAliasQry1)->EF_LOJA }) // "Fornecedor"
TRCell():New(oSection1,"EF_BENEF"	,"SEF",STR0010			,					,TamSX3("EF_BENEF")[1]		,.F.,{|| (cAliasQry1)->EF_BENEF }) // "Beneficiario"
TRCell():New(oSection1,"EF_STATUS"	,"SEF",STR0011			,					,TamSX3("EF_STATUS")[1]		,.F.,{|| (cAliasQry1)->EF_STATUS }) // "Status"
TRCell():New(oSection1,"FRF_MOTIVO"	,"FRF",STR0012			,					,TamSX3("FRF_MOTIVO")[1]	,.F.,{|| (cAliasQry2)->FRF_MOTIVO }) // "Motivo"
TRCell():New(oSection1,"X5_DESCRI"	,"SX5",STR0019			,					,TamSX3("X5_DESCRI")[1]		,.F.,{|| POSICIONE("SX5",1,XFILIAL("SX5")+ 'G0' + (cAliasQry2)->FRF_MOTIVO,"X5DESCRI()") }) //"Descripcion"
TRCell():New(oSection1,"FRF_DATDEV"	,"FRF",STR0013			,					,							,.F.,{|| (cAliasQry2)->FRF_DATDEV }) // "Data Devolucao"
TRCell():New(oSection1,"FRF_DATPAG"	,"FRF",STR0014			,					,							,.F.,{|| (cAliasQry2)->FRF_DATPAG }) // "Data Pagamento"

#IFNDEF TOP
	TRPosition():New ( oSection1, "FRF" , 1 ,{|| xFilial("FRF")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_PREFIXO+EF_NUM) } , .T. )
	TRPosition():New ( oSection1, "SX5" , 1 ,{|| xFilial("SX5")+"G0"+FRF->FRF_MOTIVO } , .T. )
#ENDIF

Return oReport

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint�Autor  �Marcelo Akama       � Data �  29/09/2010 ���
��������������������������������������������������������������������������͹��
���Desc.     �Query de impressao do relatorio                              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function ReportPrint( oReport, cAliasQry1, cAliasQry2 )

Local oSection1 := oReport:Section(1)
#IFDEF TOP
Local cQuery	:= ""
#ELSE
Local cFiltro	:= ""
#ENDIF

dbSelectArea("SEF")
SEF->(dbSetorder(1))

#IFDEF TOP

	cAliasQry2 := cAliasQry1

	oSection1:BeginQuery()

	If !Empty(mv_par01)
		cQuery += " AND E1_PORTADO = '" + mv_par01 +"'"
	EndIf
	If !Empty(mv_par02)
		cQuery += " AND E1_AGEDEP = '" + mv_par02 +"'"
	EndIf
	If !Empty(mv_par03)
		cQuery += " AND E1_CONTA = '" + mv_par03 +"'"
	EndIf
	If !Empty(mv_par04) .And. !Empty(mv_par05)
		cQuery += " AND EF_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "'"
	EndIf
	If !Empty(mv_par06) .And. !Empty(mv_par07)
		cQuery += " AND EF_VENCTO BETWEEN '" + DTOS(mv_par06) + "' AND '" + DTOS(mv_par07) + "'"
	EndIf

    /*
    +-Preguntas---------------------------------+
    �  MV_PAR01    � Banco      ?               �
    �  MV_PAR02    � Agencia     ?              �
    �  MV_PAR03    � Conta       ?              �
    �  MV_PAR04    � Da data de emissao    ?    �
    �  MV_PAR05    � Ate a data de emissao ?    �
    �  MV_PAR06    � Da data de vencimento ?    �
    �  MV_PAR07    � Ate Data de vencimento ?   �
    +-------------------------------------------+
    */
      //������������������������������������������������Ŀ
      //� Requisitos Entidades Bancarias - Julho de 2012 �
      //� O Pergunte eh alterado para FIN850B            �
      //��������������������������������������������������
      If cPaisLoc == "ARG"
         /*
         +-Preguntas---------------------------------+
         �  MV_PAR08    �Considera Abaixo ?          �
         �  MV_PAR09    �Banco Cheque ?              �
         �  MV_PAR10    �Agencia Cheque ?            �
         �  MV_PAR11    �Conta Cheque ?              �
         �  MV_PAR12    �Codigo Postal ?             �
         �  MV_PAR13    �Imprime Banco ?             �
         +-------------------------------------------+
         */

         //--- Verifica se deve levar em conta os Parametros de Entidades Bancarias
         If MV_PAR08 == 1

            If Empty( MV_PAR09 )  // Empty( cBcoChq )

               If !Empty( MV_PAR12 )   // !Empty( cPostal )

                   cQuery += " AND EF_POSTAL = '" + MV_PAR12 + "'"

               EndIf

            Else

               cQuery += " AND EF_BANCO = '" + MV_PAR09 + "'"
               cQuery += " AND EF_AGENCIA = '" + MV_PAR10 + "'"

            EndIf

         EndIf

      EndIf
      //�������Ŀ
      //� F I M �
      //���������

	dbSelectArea("SE1")
	SE1->(dbSetOrder(26))
	cQuery += " ORDER BY " + SqlOrder(IndexKey())
	cQuery := "%" + cQuery + "%"

	BeginSql Alias cAliasQry1

		SELECT SEF.EF_BANCO, SEF.EF_AGENCIA, SEF.EF_POSTAL, SEF.EF_CART, SEF.EF_TALAO, SEF.EF_NUM, SEF.EF_VALOR,
			SEF.EF_DATA, SEF.EF_VENCTO, SEF.EF_FORNECE, SEF.EF_LOJA, SEF.EF_BENEF, SEF.EF_STATUS, FRF.FRF_MOTIVO,
			FRF.FRF_DATDEV, FRF.FRF_DATPAG
		FROM %table:SEF% SEF
		INNER JOIN %table:SE1% SE1
		ON (	E1_FILIAL = %xFilial:SE1% AND
					EF_BANCO   = E1_BCOCHQ AND
					EF_AGENCIA = E1_AGECHQ AND
					EF_CONTA   = E1_CTACHQ AND
					EF_NUM     = E1_NUM AND
					EF_CLIENTE = E1_CLIENTE  AND
					EF_LOJACLI=E1_LOJA AND
					EF_TITULO = E1_RECIBO AND
					SE1.%NotDel% )
		LEFT OUTER JOIN %table:FRF% FRF
			ON	(	FRF_FILIAL = %xFilial:FRF% AND
					EF_BANCO   = FRF.FRF_BANCO AND
					EF_AGENCIA = FRF_AGENCI AND
					EF_CONTA   = FRF_CONTA AND
					EF_PREFIXO = FRF_PREFIX AND
					EF_NUM     = FRF_NUM AND
					EF_CART    = FRF_CART AND
					FRF.%NotDel% )
		WHERE EF_FILIAL = %xFilial:SEF% AND
				EF_CART = 'R' AND
				SEF.%NotDel%
				%Exp:cQuery%
	EndSql

	oSection1:EndQuery()

#ELSE

	cAliasQry1 := "SEF"
	cAliasQry2 := "FRF"

	cFiltro := '!Eof() .And. SEF->EF_FILIAL == "'+ xFilial("SEF")+'" EF_CART = "R"'
	If !Empty(mv_par01)
		cFiltro += ' .And. SEF->EF_BANCO = "' + mv_par01 + '"'
	EndIf
	If !Empty(mv_par02)
		cFiltro += ' .And. SEF->EF_AGENCIA = "' + mv_par02 + '"'
	EndIf
	If !Empty(mv_par03)
		cFiltro += ' .And. SEF->EF_CONTA = "' + mv_par03 + '"'
	EndIf
	If !Empty(mv_par04) .And. !Empty(mv_par05)
		cFiltro += ' .And. DTOS(SEF->EF_DATA) >= "' + DTOS(mv_par04) + '"'
		cFiltro += ' .And. DTOS(SEF->EF_DATA) <= "' + DTOS(mv_par05) + '"'
	EndIf
	If !Empty(mv_par06) .And. !Empty(mv_par07)
		cFiltro += ' .And. DTOS(SEF->EF_VENCTO) >= "' + DTOS(mv_par06) + '"'
		cFiltro += ' .And. DTOS(SEF->EF_VENCTO) <= "' + DTOS(mv_par07) + '"'
	EndIf
	If mv_par08=2
		cQuery += ' .And. !Empty(SEF->EF_DATA)'
	EndIf

	oSection1:SetFilter(cFiltro,(cAliasQry1)->(IndexKey()))

#ENDIF

oSection1:Print()

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FI231BCO � Autor � Carlos E. Chigres     � Data � 10/07/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trazer o banco na impressao conforme a parametrizacao      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Banco + Agencia                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FI231BCO( cCodBco )

//--- Retorno
Local cBanco := " "

//--- Ambiente
Local aOrigin := GetArea()

/*
Possiveis conteudos do combo de MV_PAR13
Bco Dep(Cod)
Banco Dep(Nome)
*/


//--- Tabela Entidades Bancarias
dbSelectArea( "FJO" )
//--- Filia + Banco
dbSetOrder(1)
//
dbSeek( xFilial( "FJO" ) + cCodBco )
//
cBanco := SubStr( FJO_NOME, 1, 25 )

RestArea( aOrigin )

Return( cBanco )
