#INCLUDE "MATR267.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR267  � Autor � Bruno Schmidt	        � Data � 20/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Detalhe do saldo da Conta		                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATR267()

Local oReport
Private cAliasSB1 := "SB1"
Private cAliasSB2 := "SB2"
Private aFieldSM0 := {"M0_NOME", "M0_FILIAL", "M0_CGC"}
Private aDatosEmp := IIf (cVersao <> "11" ,FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0),"")
Private cRUC	  := Trim(IIf (cVersao <> "11" ,aDatosEmp[3][2],SM0->M0_CGC))

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Bruno Schmidt   		� Data � 20/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relatorio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATR267                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local cPicD1Qt  := PesqPict("SD1","D1_QUANT",18)
Local cPicB2CM1 := PesqPict("SB2","B2_CM1",18)
Local cPicB2VL1 := PesqPict("SB2","B2_VATU1",18)
Local cPerg     := "MTR267"
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������

oReport := TReport():New("MATR267",STR0001,"MTR267", {|oReport| ReportPrint(oReport)},STR0002)
oReport:SetTotalInLine(.F.)
oReport:SetTotalText(STR0003) //"T o t a l   G e r a l :"
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Produto de                                   �
//� mv_par02     // Produto ate                                  �
//� mv_par03     // Data                                         �
//� mv_par04     // Armazen de                                   �
//� mv_par05     // Armazen ate                                  �
//� mv_par06     // Custo	                                     �
//� mv_par07     // Metodo Avaliacao                             �
//� mv_par08     // Lista Diferente de Zero?                     �
//����������������������������������������������������������������

oSection1 := TRSection():New(oReport,STR0004,"",,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1 :SetTotalInLine(.F.)
oSection1 :SetTotalText(STR0015) //"T O T A I S  :"
oSection1 :SetReadOnly()
oSection1 :SetHeaderPage()

TRCell():New(oSection1,"PRODUTO"  ,"SB1",STR0005+CRLF+STR0008,/*Picture*/,len(SB1->B1_COD),/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection1,"cTraco1"  ,"   ","|"+CRLF+"|"		 ,/*Picture*/,1			,/*lPixel*/,{|| "|" })
TRCell():New(oSection1,"TIPO" 	  ,"SB1",STR0007+CRLF+STR0008,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection1,"cTraco1"  ,"   ","|"+CRLF+"|"		 ,/*Picture*/,1			,/*lPixel*/,{|| "|" })
TRCell():New(oSection1,"DESCRICAO","SB1",STR0009			 ,/*Picture*/,len(SB1->B1_DESC),/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection1,"cTraco1"  ,"   ","|"+CRLF+"|"		 ,/*Picture*/,1			,/*lPixel*/,{|| "|" })
TRCell():New(oSection1,"UNIDMED"  ,"SB1",STR0005+CRLF+STR0011,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection1,"cTraco1"  ,"   ","|"+CRLF+"|"		 ,/*Picture*/,1			,/*lPixel*/,{|| "|" })
TRCell():New(oSection1,"QUANT" 	  ,"SB1",STR0012,cPicD1Qt   ,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection1,"cTraco1"  ,"   ","|"+CRLF+"|"		 ,/*Picture*/,1			,/*lPixel*/,{|| "|" })
TRCell():New(oSection1,"CUSTUNIT" ,"SB1",STR0013,cPicB2CM1,,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection1,"cTraco1"  ,"   ","|"+CRLF+"|"		 ,/*Picture*/,1			,/*lPixel*/,{|| "|" })
TRCell():New(oSection1,"CUSTTOT"  ,"SB1",STR0014,cPicB2VL1,,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

TRFunction():New(oSection1:Cell("CUSTTOT"),NIL,"SUM",/*oBreak*/,"",cPicB2VL1,/*uFormula*/,.T.,.F.)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Bruno Schmidt         � Data � 20/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
���          �ExpL1: Se .T. = gestao de Concessionarias(MV_VEICULO ="S")  ���
���          �ExpL2: Se .T. = base TOP 									  ���
���          �ExpC1: Alias do arquivo SB1								  ���
���          �ExpC2: Alias do arquivo SB3								  ���
���          �ExpN1: var.calculada do saldo em estoque					  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATR267                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport)

Local oSection1	:= oReport:Section(1)
Local nTotal 	:= 0
Local cAliasTOP := ""
Local cUnidSunat:= ""
Local cLin       := ""
Local cSep       := "|"
Local nPeriodo	 := DTOS(MV_PAR03)
Local lCodBar	 := IF (SuperGetMv("MV_USACBAR",,.F.),.T.,.F.)
Local lDesExi	 := IF (SuperGetMv("MV_USATSX5",,.F.),.T.,.F.)
Local lGerArq	 := IF (MV_PAR09==1,.T.,.F.)
Local nValuac	 := Substr(MV_PAR07,2,1)
Local cCodBar	 := ""
Local cCodProd	 := ""
Local cDesc		 := ""
Local cTabla	 := "P7"
Local nPLE		 := SuperGetMv("MV_PLEPERU",,0)
Local nCant	     := 0
Local cProdSAT	 := ""
Local cCatalogo	 := ""

oReport:SetCustomText( {|| Cabec267( oReport ) })

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:GetParam())

//������������������������������������������������������������������������Ŀ
//�Query do relatorio                                                      �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

cAliasTOP := "TRC"

BeginSql Alias cAliasTOP

	SELECT B1_FILIAL,B1_COD,B1_CODITE,B1_DESC,B1_UM,B1_TIPOEX,B1_GRUPO,B1_CODBAR,B1_PRODSAT,
		   B2_FILIAL,B2_LOCAL,B2_CM1,B2_CM2,B2_CM3,B2_CM4,B2_CM5

	FROM %table:SB1% SB1,%table:SB2% SB2

	WHERE	B1_FILIAL  = %xFilial:SB1%  AND
	B2_FILIAL  = %xFilial:SB2%  AND
	SB1.B1_COD = SB2.B2_COD     AND
	B1_COD    >= %Exp:mv_par01% AND
	B1_COD    <= %Exp:mv_par02% AND
	B2_LOCAL   >= %Exp:mv_par04% AND
	B2_LOCAL   <= %Exp:mv_par05% AND
	SB1.%NotDel% AND SB2.%NotDel%
EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relatorio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relatorio �
//���������������������������������������������
oSection1:Init()
While !oReport:Cancel() .And.!("TRC")->(Eof())

	aSalatu := CalcEst(TRC->B1_COD,TRC->B2_LOCAL,MV_PAR03+1,nil)

	IF ( MV_PAR08==2 .AND. ( aSalAtu[1]<>0 .OR. aSalAtu[MV_PAR06+1]<>0 ) ) .OR. MV_PAR08==1

		nTotal   := 0

		oSection1:Cell("PRODUTO")  :SetValue(TRC->B1_COD)
		oSection1:Cell("TIPO")	   :SetValue(TRC->B1_TIPOEX)
		oSection1:Cell("DESCRICAO"):SetValue(TRC->B1_DESC)
		SAH->( DbSetOrder(1) ) // AH_FILIAL + AH_UNIMED
		If SAH->( MsSeek( xFilial("SAH") + TRC->B1_UM))
			cUnidSunat:= Trim(SAH->AH_CODERP)
			If cUnidSunat == ""
				cUnidSunat:='99'
			EndIf
		ENDIF
		oSection1:Cell("UNIDMED")  :SetValue(cUnidSunat)
		oSection1:Cell("CUSTUNIT") :SetValue(aSalAtu[MV_PAR06+1]/aSalAtu[1])

		//������������������������������������������������Ŀ
		//� Calcula a quantidade conforme a rotina CalcEst �
		//��������������������������������������������������
		oSection1:Cell("QUANT"):SetValue(aSalAtu[1])
		oSection1:Cell("CUSTTOT"):SetValue(aSalAtu[MV_PAR06+1])
		oSection1:PrintLine()

		If lGerArq

			cCodBar  := StrTran(Trim(TRC->B1_CODBAR),"|","")
			cCodBar	 := StrTran(cCodBar,"/","")
			cCodProd := StrTran(Trim(TRC->B1_COD),"|","")
			cCodProd := StrTran(cCodProd,"/","")
			cProdSAT := Trim(TRC->B1_PRODSAT)

			//01 - Periodo
			cLin += nPeriodo
			cLin += cSep

			//02 - C�digo del cat�logo utilizado
			If lCodBar .and. cProdSAT <> "" .And. cProdSAT == cCodProd
				cCatalogo := "1"		// UNSPSC
			ElseIf lCodBar .and. cCodBar <> "" .And. cCodBar == cCodProd
				cCatalogo := "3"		// GTIN
			Else
				cCatalogo := "9"		// otro
			Endif
			cLin += cCatalogo
			cLin += cSep

			//03 - Tipo de Existencia
			cLin += Trim(TRC->B1_TIPOEX)
			cLin += cSep

			//04 - C�digo propio de la existencia correspondiente al se�alado en la posici�n 02
			If cCatalogo == "1"
				cLin += cProdSAT
			ElseIf cCatalogo == "3"
				cLin += cCodBar
			Else
				cLin += cCodProd
			EndIf
			cLin += cSep

			//05 - C�digo del cat�logo utilizado
			If lCodBar .and. cProdSAT <> ""
				cCatalogo := "1"		// UNSPSC
			ElseIf lCodBar .and. cCodBar <> ""
				cCatalogo := "3"		// GTIN
			Else
				cCatalogo := ""			// otro (9 no es v�lido)
			Endif

			If nPLE > 5181
				cLin += cCatalogo
				cLin += cSep
			Endif

			//06 - C�digo propio de la existencia correspondiente al se�alado en la posici�n 05
			If cCatalogo == "1"
				cLin += Trim(cProdSAT) + IIf( nPLE > 5150 .And. nPLE <= 5181, "00000000", "" )
			ElseIf cCatalogo == "3"
				cLin += cCodBar
			Else
				cLin += ""
			Endif
			cLin += cSep

			//07 - Descripci�n de la existencia
			DbSelectArea("SX5")
			dbSetOrder(1)
			If lDesExi .And. SX5->(MsSeek(xFilial("SX5") + cTabla + TRC->B1_TIPOEX))
				cDesc := StrTran(Trim(SX5->X5_DESCSPA),"|","")
				cDesc := StrTran(cDesc,"/","")
				cLin += cDesc
			Else
				cDesc := StrTran(Trim(TRC->B1_DESC),"|","")
				cDesc := StrTran(cDesc,"/","")
				cLin += cDesc
			EndIf
			cLin += cSep

			//08 - C�digo Unidad de Medida
			cLin += TRIM(TRC->B1_UM)
			cLin += cSep

			//09 - C�digo M�todo de valuaci�n
			cLin += nValuac
			cLin += cSep

			//10 - Cantidad de la Existencia
			nCant := MAX((aSalatu[1]),0)
			cLin += AllTrim(STR(nCant))
			cLin += cSep

			//11 - Costo Unitario de la Existencia
			If aSalAtu[MV_PAR06+1]/aSalAtu[1] > 0
				cLin += AllTrim(Str(aSalAtu[MV_PAR06+1]/aSalAtu[1]))
			Else
				cLin += "0.00"
			EndIf
			cLin += cSep

			//12 - Costo Total
			If aSalAtu[MV_PAR06+1] <> 0
				cLin += AllTrim(Str((aSalAtu[MV_PAR06+1])))
			Else
				cLin += "0.00"
			EndIf
			cLin += cSep

			//13 - Estado de la operaci�n
			cLin += "1"
			cLin += cSep
			cLin += chr(13)+chr(10)
		EndIf

		ENDIF
	TRC->(DbSkip())
End
oSection1:Finish()
If lGerArq
	Processa({|| GerArq(AllTrim(MV_PAR10),cLin)},,"")
EndIf
Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR267    � Autor � Bruno Schmidt       � Data � 01.08.11 ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Cabecera del Informe                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MATR267                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Cabec267( oReport )
Local aArea		:= GetArea()
Local aCabec	:= {}
Local cChar		:= chr(160)  // caracter dummy para alinhamento do cabe�alho
Local nExerc    := 0
Local cTitulo	:= ""
Local dFechEmi	:= Dtoc(dDataBase)

nExerc := Year(MV_PAR03)

SX3->( DbSetOrder(2) ) // X3_CAMPO
SX3->( MsSeek( "A1_CGC" , .T.))

cTitulo:= STR0001 // Libro de Inventario y Balances - Detalle del saldo de la Cuenta 20 � Mercader�a y la Cuenta 21- Productos Terminados
aCabec := {	"__LOGOEMP__" , cChar + "         " ;
+ "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999'),;
+ "         " + cChar,;
+ STR0016 + cVersao,; // SIGA / MATR267 /v.
+ UPPER(AllTrim(cTitulo));
, RptHora + " " + time() ;
+ "         " + cChar + RptEmiss + " " + dFechEmi,;
+ (STR0017 + Trim(IIf (cVersao <> "11" ,aDatosEmp[1][2],SM0->M0_NOME)) + STR0018 + STR0019 + Trim(IIf (cVersao <> "11" ,aDatosEmp[2][2],SM0->M0_FILIAL))),; // Empresa:  ## / ## Filial:
+  STR0020 + CVALTOCHAR(nExerc),; // Ejercicio:
+  STR0021 + cRUC,;               // RUC.:
+  STR0022 + MV_PAR07}            // M�todo de Evaluaci�n:

RestArea( aArea )

Return aCabec

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao     � GerArq                                 � Data � 19.02.2020 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao  � Genera el archivo txt                                      ���
���������������������������������������������������������������������������Ĵ��
��� Parametros � cDir - Directorio de creaci�n del archivo.                 ���
���            � cLin - Impresi�n que se realizar� en el txt.               ���
���������������������������������������������������������������������������Ĵ��
��� Retorno    � Nulo                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso        � 3.7 - Estructura del Registro de Activos Fijos             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GerArq(cDir,cLin)

Local nHdl 	:= 0
Local cArq 	:= ""
Local nCont	:= 0

nMes := Month (MV_PAR03)

cArq += STR0023 	 	//LE - Libros Electr�nicos
cArq += cRUC	 		//RUC
cArq += DTOS(MV_PAR03)	//Fecha
cArq += "030700"		//Identificador de Libro
//C�digo de Oportunidad
If nMes == 12
	cArq += "01"
ElseIf nMes == 1
	cArq += "02"
ElseIf nMes == 6
	cArq += "04"
Else
	cArq += "07"
EndIf
cArq += "1" 	  		//Indicador de Operaciones
cArq += "1" 	  		//Indicador del Contenido
cArq += "1" 	  		//Indicador de la Moneda
cArq += "1" 	  		//Indicador de LE generado por PLE
cArq += STR0025			//Extensi�n

FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
   IF SUBSTR(cDir,nCont,1)=='\'
      cDir:=Substr(cDir,1,nCont)
      EXIT
   ENDIF
NEXT

nHdl := fCreate(cDir+cArq)
If nHdl <= 0
	ApMsgStop(STR0026) // No se pudo generar el archivo
Else
		fWrite(nHdl,cLin)
		fClose(nHdl)
MsgAlert(STR0027 + STR0028, "") // Archivo ## generado correctamente
EndIf

Return Nil
