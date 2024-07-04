#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MATR145.CH"
#INCLUDE "TOPCONN.CH"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MATR145   �Autor  � FSW Argentina      � Data �  11/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Reporte Lista de embarques arribados resumido               ���
��������������������������������������������������������������������������͹��
���Uso       �                                        �Modulo � Facturacion���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    �BOPS      �Motivo da Alteracao                   ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�6/07/15 �PCREQ-4256�Se elimina la funcion AjustaSX1() que ���
���            �        �          �hace modificacion a SX1 por motivo de ���
���            �        �          �adecuacion a fuentes a nuevas estruc- ���
���            �        �          �turas SX para Version 12.             ���
���M.Camargo   �09.11.15�PCREQ-4262�Merge sistemico v12.1.8		          ���
���A.Rodriguez �21/04/18�DMINA-2464�Ampliar ancho de Val.Total	          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATR145()
Local oReport

   oReport := ReportDef()
   oReport:PrintDialog()
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   � ReportDef� Autor �                       � Data � 05/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descrip.  �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef
Local oReport
Local oSection1
Local oCell

Local cTitSec1    := STR0001
Local oBreak



Private cPerg     := "MTR145"
Private cTit      := OemToAnsi(STR0001)
Private lArchExcel:= .F.
Private cClient   :=''
Private cDestip   :=''


//������������������������������������������������������������������������Ŀ
//�Creaci�n del componente de impresion                                    �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nombre del Informe                                              �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pregunta                                                        �
//�ExpB4 : Bloque de codigo que ser� ejecutado al confirmar la impresion   �
//�ExpC5 : Descripcion                                                     �
//��������������������������������������������������������������������������

oReport:= TReport():New('MATR145',OemToAnsi(STR0001),cPerg, ;
                        {|oReport| ReportPrint(oReport)}, cTit)

oReport:SetPortrait()
oReport:SetTotalInLine(.F.)
Pergunte(cPerg,.F.)

oSection1 := TRSection():New(oReport," ")

oSection1:SetHeaderPage() //El titulo de la seccion se imprime al principio

TRCell():New(oSection1,'PROCESO' ,,STR0002  , /*Picture */    , 17, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )

If Alltrim(cPaisLoc) <> "BRA" .and. Alltrim(cPaisLoc) <> "MEX"
	TRCell():New(oSection1,'TIPO'    ,,STR0003  , /*Picture */    , 12, /*lPixel */, /*{|| code-block de impressao } */ )
Endif

TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'FECHAPRO',,STR0004  , /*Picture */    , 10, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'FECHADEC',,STR0005  , /*Picture */    , 10, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'FINALIZ' ,,STR0006  , /*Picture */    , 10, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'TOTAL'   ,,STR0007  ,"@E 9,999,999,999,999.99", 22, /*lPixel */, /*{|| code-block de impressao } */ )

Return( oReport )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   � ReportDef� Autor �                       � Data � 05/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descrip.  �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
#IFDEF TOP
	Local oSection1	:= oReport:Section(1)
	Local oBreak
	Local oBreak1
	Local aArea
	Local cDesEst     := ""
	Local cOrden      := ""
	Local nTotReg     := 0
	Local cCorte      := ""
	Local bPrim       := .T.
	Local xImpu       :={}
	Local nAuxTotBru  := 0
	Local nAuxTotal   := 0
	Local cDescri     := ""
	Local nAuxAliq    := 0
	Local nAuxImp     := 0
	Local nTxMoeda    := 0
	Local nVlrUnit    := 0
	Local nVlrTot     := 0
	Local cQuery      := ""
	Local cAntProc    := ""
	Local nTasa       := 0
	Local cAliasTRB	:= GetNextAlias()
	oReport:SetTitle(oReport:Title() + Iif(MV_PAR09 == 1,' - Pesos',' - Dolar'))
	
	//������������������������������������������������������������������������Ŀ
	//�Filtragem do relatorio                                                  �
	//��������������������������������������������������������������������������
	
	cQuery := "SELECT A.DBB_HAWB AS PROCESO,A.DBB_TXMOED AS TXMOEDA, " + CRLF
	cQuery +=         "A.DBB_MOEDA AS MONEDA,C.DBA_DTHAWB AS FECHAPRO,C.DBA_DT_DTA AS FECHADEC,C.DBA_DT_ENC AS FINALIZ, " + CRLF
	
	If Alltrim(cPaisLoc) $ "BRA/MEX"
		cQuery +=  "B.DBC_PRECO AS PRECIO,B.DBC_TOTAL AS TOTAL " + CRLF
	Else
		cQuery +=  "B.DBC_PRECO AS PRECIO,B.DBC_TOTAL AS TOTAL, A.DBB_TIPONF TIPO " + CRLF
	Endif
	
	cQuery += "FROM " + CRLF
	cQuery += "    " + RetSqlName("DBB") + " A, " + RetSqlName("DBC") + " B, " + RetSqlName("DBA") + " C " + CRLF
	cQuery += "WHERE A.DBB_HAWB >= '"+MV_PAR01+"' AND " + CRLF
	cQuery +=       "A.DBB_HAWB <= '"+MV_PAR02+"' AND " + CRLF
	cQuery +=       "C.DBA_DTHAWB>='"+Dtos(MV_PAR03)+"' AND " + CRLF
	cQuery +=       "C.DBA_DTHAWB<='"+Dtos(MV_PAR04)+"' AND "	 + CRLF
	cQuery +=       "(C.DBA_DT_DTA=' ' OR (C.DBA_DT_DTA >= '"+Dtos(MV_PAR05)+"' AND C.DBA_DT_DTA <= '"+Dtos(MV_PAR06)+"' )) AND " + CRLF
	cQuery +=       "(C.DBA_DT_ENC=' ' OR (C.DBA_DT_ENC >= '"+Dtos(MV_PAR07)+"' AND C.DBA_DT_ENC <= '"+Dtos(MV_PAR08)+"' )) AND " + CRLF
	cQuery +=       "A.DBB_HAWB = C.DBA_HAWB AND " + CRLF
	cQuery +=       "A.DBB_HAWB = B.DBC_HAWB AND " + CRLF
	cQuery +=       "A.DBB_ITEM = B.DBC_ITDOC AND " + CRLF
	cQuery +=       "A.D_E_L_E_T_ <> '*' AND " + CRLF
	cQuery +=       "B.D_E_L_E_T_ <> '*' AND " + CRLF
	cQuery +=       "C.D_E_L_E_T_ <> '*' " + CRLF
	
	If Alltrim(cPaisLoc) $ "BRA/MEX"
		cQuery +=    "ORDER BY PROCESO " + CRLF
	else
		cQuery +=    "ORDER BY PROCESO, TIPO " + CRLF
	Endif
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasTRB, .F., .T.)
	
	DbSelectArea(cAliasTRB)
	
	DbGoTop()
	oSection1:Init()
	oSection1:Cell("PROCESO"):SetBlock({|| allTrim((cAliasTRB)->PROCESO)} )
	
	If cPaisLoc <> "BRA" .and. cPaisLoc <> "MEX"
		oSection1:Cell("TIPO"):SetBlock( {|| BuTipoFac(cAliasTRB)  }  )
	Endif
	
	oSection1:Cell("FECHAPRO"):SetBlock({|| Stod((cAliasTRB)->FECHAPRO) })
	oSection1:Cell("FECHADEC"):SetBlock({||  Stod((cAliasTRB)->FECHADEC)})
	oSection1:Cell("FINALIZ"):SetBlock({|| Stod((cAliasTRB)->FINALIZ) })
	
	cAntProc:= allTrim((cAliasTRB)->PROCESO)
	
	SM2->(dbSeek(dDataBase))
	nTasa  := SM2->M2_MOEDA2
	If nTasa == 0
	   nTasa:=1
	EndIf
	
	(cAliasTRB)->(DbGoTop())
	While !oReport:Cancel() .And. !(cAliasTRB)->(Eof())
	
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
	
		While !(cAliasTRB)->(EOF())
	
			If MV_PAR10 == 1     //Del Movimiento
				nTxMoeda := IIF((cAliasTRB)->TXMOEDA > 0,(cAliasTRB)->TXMOEDA,Nil)
			Else
				nTxMoeda := nTasa
			EndIf
	
			Do Case
				Case (MV_PAR09 == 1 .And. (cAliasTRB)->MONEDA == 1) .Or. (MV_PAR09 == 2 .And. (cAliasTRB)->MONEDA == 2)
					nVlrUnit := (cAliasTRB)->PRECIO
					nVlrTot  := (cAliasTRB)->TOTAL
				Case MV_PAR09 == 1 .And. (cAliasTRB)->MONEDA == 2
					nVlrUnit := ((cAliasTRB)->PRECIO * nTxMoeda)
					nVlrTot  := ((cAliasTRB)->TOTAL * nTxMoeda)
				Case MV_PAR09 == 2 .And. (cAliasTRB)->MONEDA == 1
					nTxMoeda := nTasa
					nVlrUnit := ((cAliasTRB)->PRECIO / nTxMoeda)
					nVlrTot  := ((cAliasTRB)->TOTAL / nTxMoeda)
			EndCase
	
			oSection1:Cell("TOTAL"):SetBlock({|| nVlrTot})
	
			If allTrim((cAliasTRB)->PROCESO)<> cAntProc
				cAntProc:= allTrim((cAliasTRB)->PROCESO)
				oReport:SkipLine()
			EndIf
			oSection1:PrintLine()
			(cAliasTRB)->(dbSkip())
	
		EndDo
	
	EndDo
	
	oSection1:Finish()
	//Cierra tabla temporal
	DbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbCloseArea())
	
	Return NIL
	
	Static Function BuTipoFac(cAliasTRB)
	Local cTipoFac := ''
	
	If cPaisLoc <> "BRA" .and. cPaisLoc <> "MEX"
	
		Do Case
		   Case (cAliasTRB)->TIPO == '5'
	      	cTipoFac := STR0010
	   	Case (cAliasTRB)->TIPO == '6'
	      	cTipoFac := STR0011
	   	Case (cAliasTRB)->TIPO == '7'
	      	cTipoFac := STR0012
	   	Case (cAliasTRB)->TIPO == '8'
	      	cTipoFac := STR0013
	   	Case (cAliasTRB)->TIPO == 'A'
	      	cTipoFac := STR0014
		EndCase
		
	Endif
	
#ELSE
	Aviso(STR0001,STR0008,{STR0009})//"Relat�rio dispon�vel apenas para ambiente TopConnect."  
#ENDIF   

Return cTipoFac
