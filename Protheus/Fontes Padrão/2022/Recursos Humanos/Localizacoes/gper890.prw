#INCLUDE "PROTHEUS.ch"
#INCLUDE "GPER890.ch"

/*/
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Programa  � GPER890  �Autor  �Erika Kanamori                   � Data �26/02/10  ���
�����������������������������������������������������������������������������������Ķ��
���Desc.     � Gera planilla AFP para localizacao Peru.                             ���
�����������������������������������������������������������������������������������Ķ��
���Uso       � Generico                                                             ���
�����������������������������������������������������������������������������������Ķ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                ���
�����������������������������������������������������������������������������������͹��
���Programador     � Data    �FNC/PLANO       �  Motivo da Alteracao                ���
�����������������������������������������������������������������������������������͹��
���Alceu P.        �03/08/11 �00000017236/2011�Ajuste para passar a data e a        ���
���                �         �                �condi��o no mes de competencia.      ���
���Claudinei Soares�16/11/11 �00000028920/2011�Ajuste para n�o considerar entidade  ���
���                �         �Chamado:TDZGOH  �pensional p�blica.                   ���
���Leandro Dr.     �02/03/12 �          TEOUJO�Ajuste no tamanho do pergunte filial ���
���                �         �                �                                     ���
���Jonathan Glez   �07/05/15 �      PCREQ-4256� Se elimina funcion AjustaSx1 Cual   ���
���                �         �                � realiza la modificacion a diccio-   ���
���                �         �                � nario de datos(SX1) por motivo de   ���
���                �         �                � adecuacion nuevaestructura de SXs   ���
���                �         �                � para V12                            ���
���Veronica Flores �01/04/19 � DMINA-6101     �Localizaci�n de N�mina PER -         ���
���                �         �                � actualizaci�n de texto por etiquetas���
���                �         �                � y comentarios. PER                  ���
���Veronica Flores �08/10/20 � DMINA-10234    �Se agrega una bandera en la funci�n  ���
���                �         �                � GPE890Proc()                        ���
���Veronica Flores �27/01/21 � DMINA-11027    �Se agrega validaci�n en la funci�n   ���
���                �         �                � GPE890Proc() para los empleados     ���
���                �         �                � despedidos.                         ���
���Alf. Medrano    �28/01/21 � DMINA-10887    �Se agrega pregunta Generar? y en fun ���
���                �         �                �GPE890Proc se asigna validacion que  ���
���                �         �                �indica la generacion de archivo txt o���
���                �         �                �Reporte en Treport o ambos. Se crea  ���
���                �         �                �Fun ReportDef y ReportPrint.         ���
���Alf. Medrano    �04/02/21 � DMINA-10887    �En fun GPE890Proc se agrega cancel de���
���                �         �                �TReport dentro del While principal   ���
���Alf. Medrano    �04/02/21 � DMINA-10887    �En fun GPE890Proc se agrega validaci ���
���                �         �                �-on para actualizar tama�os de campos���
���                �         �                �cuando l informe se genera en PDF    ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
/*/
Function GPER890()

Local aSays			:= {}, aButtons:= { } 

Private cCadastro 	:= OemToAnsi(STR0001) //"Ajuste de Parametros"
Private nSavRec  	:= RECNO()
Private cProcessos	:= ""

Pergunte("GPR890",.F. )
AADD(aSays,OemToAnsi(STR0002) )  //"Rutina para generacion de archivo magnetico AFP"
AADD(aSays,OemToAnsi(STR0003) )  //"El sistema generara el archivo de acuerdo con los parametros informados."

AADD(aButtons, { 5,.T.,{|| Pergunte("GPR890",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| If( GPE890Gera(), FechaBatch(), ) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

If !isBlind()
	FormBatch( cCadastro, aSays, aButtons )
Else
	GPE890Gera()
EndIF

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GPE890Gera�Autor  �Erika Kanamori      � Data �  26/02/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega parametros e cria arquivo texto escolhido pelo     ���
���          � usuario.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPE890Gera()
/*
��������������������������������������������������������������Ŀ
� Variaveis utilizadas para parametros                         �
� mv_par01        //  Processo?						           �
� mv_par02        //  Procedimiento?			           |
� mv_par03        //  De Periodo?                              �
� mv_par04        //  Num de Pago ?                            �
� mv_par05        //  Sucursal    ?                            �
� mv_par06        //  Centro de costo?                         �
� mv_par07        //  Matricula?                               �
� mv_par08        //  Nombre    ?                              �
� mv_par09        //  Situacion?                               �
� mv_par10        //  Categoria?                               �
� mv_par11        //  Arquivo de Saida?                        �
� mv_par12        //  Generar?                                 �
����������������������������������������������������������������
*/
Local nTpRep 	:= IIF(Empty(MV_PAR12),1,MV_PAR12)
Private nHdl    := fCreate(mv_par11)
Private lTRep   := IIf(nTpRep == 3 .OR. nTpRep== 2, .T.,.F.)
Private lArch   := IIf(nTpRep == 3 .OR. nTpRep== 1, .T.,.F.)


If lArch
	If nHdl == -1
		MsgAlert(STR0004+mv_par11+STR0005,STR0006) //"O arquivo de nome "###" nao pode ser executado! Verifique os parametros."###"Atencao!"
		Return .F.
	Endif
Endif

//Inicializa a regua de processamento
IF !isblind()
	If lTRep
		 oReport := ReportDef()
   		 oReport:PrintDialog()
	Else
		Processa({|| GPE890Proc() },STR0007)     //"Procesando..."   
	EndIf  
Else
	GPE890Proc()
Endif
Return .T.



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    ReportDef � Autor � Alfredo Medrano        � Data �26/01/2021���
�������������������������������������������������������������������������Ĵ��
���Descricao �Definicion reporte de AFP                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPE890Gera                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Private oReport 
Private aOrd	  := {STR0010} //"Filial - Matricula"
Private oSection1 

///������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
	oReport:= TReport():New("GPER980",STR0011,"GPR890", {|oReport| ReportPrint(oReport)},STR0012) //"Aportaciones de AFP (Administradoras de Fondos de Pensi�n)"// "AFP"
	oReport:SetLandscape() 
	oReport:oPage:nPaperSize:=3	// Impress�o em papel A4		
	oReport:SetTotalInLine(.F.) //True = imprime totalizadores 
	oReport:nFontBody		:= 6 	//Tama�o fuente del documento
	oReport:nLineHeight		:= 30 	//Altura de linea 
	oReport:nColSpace		:= 5	//Espacio entre las columnas de informaci�n
	oReport:ShowHeader()			//imprimir el encabezado del informe (por default)
	oReport:cFontBody		:= "COURIER NEW" // tipo de letra


//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//��������������������������������������������������������������������������
	oSection1:=TRSection():New(oReport,STR0012,{"SRA"},aOrd) //"AFP
	oSection1:SetHeaderBreak(.T.) //Muestra el encabezado de la secci�n
	oSection1:SetHeaderSection(.T.) // Si es verdadero, indica que imprime el encabezado cuando la secci�n inicia nuevamente
	oSection1:SetLineBreak(.T.) //.T. imprime una o mas lineas - .F.= no imprime linea 
	oSection1:SetTotalInLine(.F.) //True = imprime totalizadores 	
	oSection1:SetTotalText(STR0032) // define el titulo del totalizador // Total de Registros


	
//������������������������������������������������������������������������Ŀ
//�Cria��o da celulas da se��o do relat�rio									 �
//� 																				 �
//� TRCell():New 																	 �	
//� ExpO1 : Objeto TSection que a secao pertence                     		 �
//� ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado     		 �
//� ExpC3 : Nome da tabela de referencia da celula              			 �
//� ExpC4 : Titulo da celula                                     			 � 
//� Default : X3Titulo() 														 �
//� ExpC5 : Picture 																 �
//� Default : X3_PICTURE															 �
//� ExpC6 : Tamanho																 �
//� Default : X3_TAMANHO															 �
//� ExpL7 : Informe se o tamanho esta em pixel								 �
//� Default : False																 �		
//� ExpB8 : Bloco de c�digo para impressao.									 �
//� Default : ExpC2																 �
//��������������������������������������������������������������������������
	TRCell():New(oSection1,'RA_FILIAL'	,'SRA'	,STR0013	,/*Picture*/,TamSx3("RA_FILIAL")[1]		, /*lPixel*/,/*{|| code-block de impressao }*/) //Fil.
	TRCell():New(oSection1,'RA_MAT'		,'SRA'	,STR0014	,/*Picture*/,TamSx3("RA_MAT")[1]	    , /*lPixel*/,/*{|| code-block de impressao }*/) //Mat.
	TRCell():New(oSection1,'SECUENCIA'	,''		,STR0015	,/*Picture*/,5	                    	, /*lPixel*/,/*{|| code-block de impressao }*/) //Sec.
	TRCell():New(oSection1,'RA_CUSPP'	,'SRA'	,STR0016	,/*Picture*/,TamSx3("RA_CUSPP")[1]      , /*lPixel*/,/*{|| code-block de impressao }*/) //CUSPP
	TRCell():New(oSection1,'RA_TPCIC'	,'SRA'	,STR0017	,/*Picture*/,TamSx3("RA_TPCIC")[1]		, /*lPixel*/,/*{|| code-block de impressao }*/) //Tp.Doc
	TRCell():New(oSection1,'RA_CIC'		,'SRA'	,STR0018	,/*Picture*/,TamSx3("RA_CIC")[1]		, /*lPixel*/,/*{|| code-block de impressao }*/) //Nr.Doc.Ident
	TRCell():New(oSection1,'RA_PRISOBR' ,'SRA'	,STR0019	,/*Picture*/,20 , /*lPixel*/,/*{|| code-block de impressao }*/) //Apel.Paterno
	TRCell():New(oSection1,'RA_SECSOBR'	,'SRA'	,STR0020	,/*Picture*/,20 , /*lPixel*/,/*{|| code-block de impressao }*/) //Apel.Materno
	TRCell():New(oSection1,'NOMBRES'	,''		,STR0021	,/*Picture*/,30	, /*lPixel*/,/*{|| code-block de impressao }*/) //Nombres
	TRCell():New(oSection1,'RELACTMES'	,''		,STR0022	,/*Picture*/,1 	, /*lPixel*/,/*{|| code-block de impressao }*/) //RL
	TRCell():New(oSection1,'RELINIMES'	,''		,STR0023	,/*Picture*/,1	, /*lPixel*/,/*{|| code-block de impressao }*/) //RL.Ini
	TRCell():New(oSection1,'RELFINMES'	,''		,STR0024	,/*Picture*/,1	, /*lPixel*/,/*{|| code-block de impressao }*/) //RL.Fin
	TRCell():New(oSection1,'EXCAPOR'	,''		,STR0025	,/*Picture*/ ,9 	, /*lPixel*/,/*{|| code-block de impressao }*/) //Exc.Apr
	TRCell():New(oSection1,'REMASEGUR'	,''		,STR0026	,/*Picture*/,9	, /*lPixel*/,/*{|| code-block de impressao }*/) //Rem.Aseg
	TRCell():New(oSection1,'APORPREV'	,''		,STR0027	,/*Picture*/,9	, /*lPixel*/,/*{|| code-block de impressao }*/) //Apr.Vol
	TRCell():New(oSection1,'APORNPREV'	,''		,STR0028	,/*Picture*/,9	, /*lPixel*/,/*{|| code-block de impressao }*/) //Apr.Sn.Pr
	TRCell():New(oSection1,'APORCIAAFP'	,''		,STR0029	,/*Picture*/,9 	, /*lPixel*/,/*{|| code-block de impressao }*/) //Apr.Emp
	TRCell():New(oSection1,'RA_TRAAFP'	,'SRA'	,STR0030	,/*Picture*/,TamSx3("RA_TRAAFP")[1], /*lPixel*/,/*{|| code-block de impressao }*/) //Tp.Trab
	TRCell():New(oSection1,'CODAFP'		,''		,STR0012	,/*Picture*/ ,2	, /*lPixel*/,/*{|| code-block de impressao }*/) //AFP

	//Funcion que cuanta el numero de registros impresios por matricula e imprime el valor al final de la secci�n oSection1 
	TRFunction():New(oSection1:Cell("RA_MAT"/*X3_CAMPO*/) ,"TOTAL1", "COUNT", /*oBreak*/, STR0032, /*cPicture*/, /*uFormula*/, .T./*lEndSection*/, .F./*lEndReport*/, /*lEndPage*/.F.) //"Total de Registros
Return(oReport)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PrintReport� � Autor � Alfredo Medrano    � Data �26/01/2021���
�������������������������������������������������������������������������Ĵ��
���Descricao �Llenado del reporte de  AFP                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  oReport - Objeto del Reporte                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �ReportDef                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)
	oSection1	:= oReport:Section(1)
	GPE890Proc()
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |GPE890Proc�Autor  �Erika Kanamori      � Data �  26/02/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de geraco do arquivo                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPE890Proc()

Local cMes  := ""
Local cAno  := ""
Local cFilialAnt:= ""
Local cAfasComPago := ""
Local cAfasSemPago := ""
Local cLinha:= ""
Local cCodAFP:= ""

Local nSequencia := 1
Local nAporPrev:= 0
Local nAporNaoPrev:= 0

Local nRemAssegur:= 0

Local cFiltro   := ""
Local cFilRD   := ""
Local cFilRC   := ""
Local cFilRCH   := ""
Local nNum := 0

Local cSitQuery	:= ""
Local cCatQuery	:= ""
Local nReg		:= 0
Local cSitua  	:= mv_par09
Local cCateg	:= mv_par10
Local dDataIni	:=  Ctod("") 
Local dDataFim	:=  Ctod("") 
Local cAnoMesArq := ""
Local LConSinrem := .F.
Local LConConRem := .F.
Local lBan 		 := .F.
Local aFasCon		 := {}
Private dDtMov     := CTOD("//")
Private cTpMov     := ""
Private cPerg	   := "GPR890"
PRIVATE cAliasSRA  := "QSRA"
Private cAliasRCH  := "QRCH"
Private cAliasSRCD  := "QSRCD"


//carrega periodos do mes selecionado

dbSelectArea("SRA")
dbSetOrder(1)


pergunte(cPerg,.F.)
MakeSqlExpr(cPerg)   

	IncProc(STR0009)	//"Procesando Informaci�n..."
	
	If !Empty(mv_par05)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR05, MV_PAR05 )
	EndIf
	
	If !Empty(mv_par06)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR06, MV_PAR06 )
	EndIf

	If !Empty(mv_par07)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR07, MV_PAR07 )
	EndIf

	If !Empty(mv_par08)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR08, MV_PAR08 )
	EndIf
	
	If !Empty(mv_par01)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR01, MV_PAR01 )
		cFilRD  += If( !Empty(cFilRD),  " AND " + MV_PAR01, MV_PAR01 )
	EndIf
	
	cFiltro := If( !Empty(cFiltro), "% " + cFiltro + " AND %", "%%" )

	cFiltro	:= strTran(cFiltro, "SRD", "SRA")
	cFiltro	:= strTran(cFiltro, "RD_", "RA_")
		
	If !Empty(mv_par02)
		cFilRD += If( !Empty(cFilRD), " AND " + MV_PAR02, MV_PAR02 )
	EndIf
	
	If !Empty(mv_par03)
		cFilRD += If( !Empty(cFilRD), " AND " + "(RD_PERIODO IN('" + MV_PAR03+"'))", "(RD_PERIODO IN('" + MV_PAR03+"'))" )
	EndIf
	
	If !Empty(mv_par04)
		cFilRD += If( !Empty(cFilRD), " AND " + "(RD_SEMANA IN('" + MV_PAR04 + "'))", "(RD_SEMANA IN('" + MV_PAR04 + "'))" )
	EndIf

	cFilRD := If( !Empty(cFilRD), "% " + cFilRD + " AND %", "%%" )

	cFilRCH := strTran(cFilRD, "RD_SEMANA", "RCH_NUMPAG")       
	cFilRCH := strTran(cFilRCH, "RD_PERIODO", "RCH_PER")                                              
	cFilRCH	:= strTran(cFilRCH, "SRD", "RCH")
	cFilRCH	:= strTran(cFilRCH, "RD_", "RCH_")

                                           
	cFilRC	:= strTran(cFilRD, "SRD", "SRC")
	cFilRC	:= strTran(cFilRC, "RD_", "RC_")
		
	BeginSql alias cAliasRCH

		SELECT  MIN(RCH_ANO+RCH_MES) AS ANOMES
		FROM %table:RCH% RCH
		WHERE %exp:cFilRCH%
		RCH.%notDel%
		  
	 EndSql
		
		iF (cAliasRCH)->( !Eof() )  
		  cAnoMesArq := (cAliasRCH)->ANOMES
		EndIf
	
		(cAliasRCH)->(DbCloseArea())
	
	dDataIni	:= FirstDate(SToD(cAnoMesArq+"01"))
 	dDataFim	:= LastDate(SToD(cAnoMesArq+"01"))

	cMes:= Substr(cAnoMesArq, 5,2 )
	cAno:= Substr(cAnoMesArq, 1, 4)



	cSitQuery := ""
	For nReg:=1 to Len(cSitua)
		cSitQuery += "'"+Subs(cSitua,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSitua)
			cSitQuery += ","
		Endif
	Next nReg
	cSitQuery := "%" + cSitQuery + "%"

	cCatQuery := ""
	For nReg:=1 to Len(cCateg)
		cCatQuery += "'"+Subs(cCateg,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCateg)
			cCatQuery += ","
		Endif
	Next nReg
	cCatQuery := "%" + cCatQuery + "%"
	

	BeginSql alias cAliasSRA


		SELECT  SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC,SRA.RA_PRISOBR,
				SRA.RA_SECSOBR, SRA.RA_PRINOME,SRA.RA_SECNOME,SRA.RA_CUSPP,SRA.RA_SITFOLH,
				SRA.RA_CODAFP,SRA.RA_DEMISSA,SRA.RA_ADMISSA,SRA.RA_TRAAFP,SRA.RA_JUBILAC,
				SRA.RA_PERADM,SRA.RA_PAGADM,SRA.RA_PROCES
		FROM %table:SRA% SRA
		WHERE SUBSTRING(RA_ADMISSA,1,6) <= %exp:cAnoMesArq%
			AND SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%)
			AND SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)
			AND ( SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= %exp:cAnoMesArq% )
		    AND (SRA.RA_CODAFP  <> %exp:' '% OR SRA.RA_JUBILAC IN ('1','2')  )
		    AND %exp:cFiltro%
		    SRA.%notDel%
		      
		    
	    
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 

	    
	EndSql

	cFilialAnt:= "  "
	
	cConcAusen	 :=""
	cAfasSemPago := ""
	cAfasComPago := ""
	aFasCon		 := ExtraeTipo()	
	cConcAusen	 :=aFasCon[1]
	cAfasSemPago :=aFasCon[2]
	cAfasComPago := aFasCon[3]


	If lTRep
		If oReport:nDevice == 6 //PDF
			oReport:nLineHeight		:= 25 	//Altura de linea 
			oReport:nColSpace		:= 3	//Espacio entre las columnas de informaci�n
			oSection1:cell("RA_PRISOBR"):nSize := 15
			oSection1:cell("RA_SECSOBR"):nSize := 15
			oSection1:cell("NOMBRES"):nSize := 20
		EndIf
		oSection1:Init()
	EndIf
	
	While (cAliasSRA)->( !Eof() )  
		If lTRep
			If oReport:Cancel() //termina proceso si se cancela el reporte
				(cAliasSRA)->(DbCloseArea())
				Exit
			EndIf
		EndIf
	
		lBan := .F.
      	If (cAliasSRA)->RA_FILIAL <> cFilialAnt
			cFilialAnt:= (cAliasSRA)->RA_FILIAL
		Endif

		If !(AllTrim((cAliasSRA)->RA_CODAFP) $ "02")
	        cCodAFP := AllTrim(FDESCRCC("ST11",(cAliasSRA)->RA_CODAFP,1,2,96,2)) //codigo para archivo AFP del empleado 
	        cCodCic := AllTrim(FDESCRCC("ST03",(cAliasSRA)->RA_TPCIC,1,2,43,1))  //cod de documento para AFPNET 
	        cRelActMes := "N"
	        cRlIniMes  := "N"
	        cRelFinMes := "N"
	       	
	        cExcepApor := " "
	        nAporCiaAFP := 0
	
	        If AnoMes(stod((cAliasSRA)->RA_ADMISSA)) <= (cAno+cMes) .AND. ((cAliasSRA)->RA_SITFOLH <> 'D' .OR. ((cAliasSRA)->RA_DEMISSA >= DTOS(dDataIni) .And. (cAliasSRA)->RA_SITFOLH == 'D'))
				cRelActMes:= "S"
			EndIf
	
			If AnoMes(stod((cAliasSRA)->RA_ADMISSA)) == (cAno+cMes)
				 cRlIniMes := "S"
			EndIf
	
			If AnoMes(stod((cAliasSRA)->RA_DEMISSA)) == (cAno+cMes)
				cRelFinMes := "S"
			EndIf
			
			If lArch
				cLinha := ""
				cLinha+= StrZero( nSequencia, 5 )
				cLinha+= Padl((cAliasSRA)->RA_CUSPP, 12)
				cLinha+= Padl(cCodCic, 1)
				cLinha+= PadR((cAliasSRA)->RA_CIC, 20)//Padl(Strzero(Val((cAliasSRA)->RA_CIC),20), 20)
				cLinha+= Padl((cAliasSRA)->RA_PRISOBR, 20)
				cLinha+= Padl((cAliasSRA)->RA_SECSOBR, 20)
				cLinha+= Padl((cAliasSRA)->RA_PRINOME + (cAliasSRA)->RA_SECNOME, 20) 
				cLinha+= Padl(cRelActMes, 1)
				cLinha+= Padl(cRlIniMes, 1) 
				cLinha+= Padl(cRelFinMes, 1) 
			Endif

			If lTRep
				oReport:IncMeter()
				oSection1:cell("RA_FILIAL"):SetValue((cAliasSRA)->RA_FILIAL) 
				oSection1:cell("RA_MAT"):SetValue((cAliasSRA)->RA_MAT) 
				oSection1:cell("SECUENCIA"):SetValue(StrZero( nSequencia, 5 )) 
				oSection1:cell("RA_CUSPP"):SetValue((cAliasSRA)->RA_CUSPP)
				oSection1:cell("RA_TPCIC"):SetValue(cCodCic)
				oSection1:cell("RA_CIC"):SetValue((cAliasSRA)->RA_CIC)
				oSection1:cell("RA_PRISOBR"):SetValue((cAliasSRA)->RA_PRISOBR)
				oSection1:cell("RA_SECSOBR"):SetValue((cAliasSRA)->RA_SECSOBR)
				oSection1:cell("NOMBRES"):SetValue((cAliasSRA)->RA_PRINOME + (cAliasSRA)->RA_SECNOME)
				oSection1:cell("RELACTMES"):SetValue(cRelActMes)
				oSection1:cell("RELINIMES"):SetValue(cRlIniMes)
				oSection1:cell("RELFINMES"):SetValue(cRelFinMes)
				
				nNum++
			Endif
			
			
			cJoinSRV1 := "%" + " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRC.RC_PD = SRV.RV_COD AND " + fGR890join("SRC", "SRV") + "%" 
			cJoinSRV2 := "%" + " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRD.RD_PD = SRV.RV_COD AND " + fGR890join("SRD", "SRV") + "%" 
			
			
				BeginSql alias cAliasSRCD
	
					SELECT SRC.RC_FILIAL FILIAL,SRC.RC_PD RCD_PD,SUM(SRC.RC_HORAS) RCD_HORAS,SUM(SRC.RC_VALOR) RCD_VALOR,
						   SRV.RV_CODFOL
					FROM %table:SRC% SRC 
					%exp:cJoinSRV1% 
					WHERE	%exp:cFilRC% 
					SRC.RC_MAT = %exp:(cAliasSRA)->RA_MAT % 
					AND SRC.RC_FILIAL = %exp:(cAliasSRA)->RA_FILIAL % 
					AND SRC.%notDel% AND SRV.%notDel% 
					AND (SRV.RV_CODFOL IN ( %exp:'0859','1153','1154','1356'% ) OR SRV.RV_COD IN ( %exp:cConcAusen%) )
					GROUP BY SRC.RC_FILIAL,SRC.RC_PD,SRV.RV_CODFOL
	
		  			UNION
	
						SELECT SRD.RD_FILIAL FILIAL,SRD.RD_PD RCD_PD,SUM(SRD.RD_HORAS) RCD_HORAS,SUM(SRD.RD_VALOR) RCD_VALOR,
						   SRV.RV_CODFOL
					FROM %table:SRD% SRD 
					%exp:cJoinSRV2% 
					WHERE	%exp:cFilRD% 
					SRD.RD_MAT = %exp:(cAliasSRA)->RA_MAT % 
					AND SRD.RD_FILIAL = %exp:(cAliasSRA)->RA_FILIAL % 
					AND SRD.%notDel% AND SRV.%notDel% 
					AND (SRV.RV_CODFOL IN ( %exp:'0859','1153','1154','1356'% ) OR SRV.RV_COD IN ( %exp:cConcAusen%) )
					GROUP BY SRD.RD_FILIAL,SRD.RD_PD,SRV.RV_CODFOL
	
		
				EndSql
	
	
				nRemAssegur := 0
				nAporPrev := 0
				nAporNaoPrev := 0
				nAporCiaAFP := 0
				nConSinRv := 0
				nConSinRh := 0
				LConSinrem := .F.
				nConConRv := 0
				nConConRh := 0
				LConConRem := .F.
				
				While (cAliasSRCD)->( !Eof() )  
					lBan:= .T.
					If (cAliasSRCD)->RV_CODFOL $ "0859"   
						nRemAssegur += (cAliasSRCD)->RCD_VALOR
						cExcepApor := " "
					ElseIf (cAliasSRCD)->RV_CODFOL $ "1356"
						nAporCiaAFP += (cAliasSRCD)->RCD_VALOR
					ElseIf (cAliasSRCD)->RV_CODFOL $ "1153"
						nAporPrev += (cAliasSRCD)->RCD_VALOR
					ElseiF  (cAliasSRCD)->RV_CODFOL $ "1154"
						nAporNaoPrev += (cAliasSRCD)->RCD_VALOR
					Else
						If (cAliasSRCD)->RCD_PD $ cAfasSemPago
							nConSinRv += (cAliasSRCD)->RCD_VALOR
							nConSinRh += (cAliasSRCD)->RCD_HORAS
							LConSinrem := .T.
						ElseIF 	(cAliasSRCD)->RCD_PD $ cAfasComPago
							nConConRv += (cAliasSRCD)->RCD_VALOR
							nConConRh += (cAliasSRCD)->RCD_HORAS
							LConConRem := .T.
						EndIF
	
					EndIf
		
					(cAliasSRCD)->( DbSkip() )
				EndDo		    		
	
				(cAliasSRCD)->(DbCloseArea())
						
			If nRemAssegur == 0 
			
				iF LConConRem 
					 cExcepApor := "U"	  
				ElseIf LConSinrem
					 cExcepApor := "L"	
				ElseiF (cAliasSRA)->RA_JUBILAC == "1" .and. EMPTY(ALLTRIM((cAliasSRA)->RA_CODAFP)) 
					 cExcepApor := "J"	
				ElseIf (cAliasSRA)->RA_JUBILAC == "2" .and. EMPTY(ALLTRIM((cAliasSRA)->RA_CODAFP)) 
					 cExcepApor := "I"	
				Else
				
				      If AnoMes(STOD((cAliasSRA)->RA_ADMISSA)) == (cAno+cMes)
				 
	
						BeginSql alias cAliasRCH
				
				
						SELECT  RCH_DTINI,RCH_DTFIM
						FROM %table:RCH% RCH
						WHERE RCH_PER = %exp:(cAliasSRA)->RA_PERADM%
						AND RCH_NUMPAG = %exp:(cAliasSRA)->RA_PAGADM%
						AND RCH_PROCES = %exp:(cAliasSRA)->RA_PROCES%
						AND RCH_ROTEIR = %exp:"LIQ"%
						AND RCH.%notDel%
						  
						 EndSql
						
						iF (cAliasRCH)->( !Eof() ) .AND. STOD((cAliasRCH)->RCH_DTINI) > dDatafim
						    cExcepApor := "P"
						Else 
				             cExcepApor := "O"
	
						EndIF
						
						(cAliasRCH)->(DbCloseArea())				   
									     
				    Else
					     cExcepApor := "O"
				    EndIf
				EndIF
			EndIF
			
			If lBan
				If lArch
					cLinha+= Padl(cExcepApor, 1) 
					cLinha+= Padl(Strzero(Val(STRTRAN(Transform(nRemAssegur, "9999999.99"),".","")),9), 9)
					cLinha+= Padl(Strzero(Val(STRTRAN(Transform(nAporPrev, "999999999"),".","")),9), 9)
					cLinha+= Padl(Strzero(Val(STRTRAN(Transform(nAporNaoPrev, "999999999"),".","")),9), 9)   
					cLinha+= Padl(Strzero(Val(STRTRAN(Transform(nAporCiaAFP, "999999999"),".","")),9), 9)    //aportaci�n empleador
					cLinha+= Padl((cAliasSRA)->RA_TRAAFP, 1)
					cLinha+= Padl(cCodAFP, 2)
					cLinha += CRLF

					If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha) //Testa por erros durante a gravacao da linha montada.
						If !MsgAlert(STR0008,STR0006) //"Ocorreu um erro na gravacao do arquivo. Continua?"###"Atencao!"
						Endif
					Endif
				EndIf

				If lTRep
					oSection1:cell("EXCAPOR"):SetValue(cExcepApor) 
					oSection1:cell("REMASEGUR"):SetValue(Padl(Strzero(Val(STRTRAN(Transform(nRemAssegur, "9999999.99"),".","")),9), 9)) 
					oSection1:cell("APORPREV"):SetValue(Padl(Strzero(Val(STRTRAN(Transform(nAporPrev, "999999999"),".","")),9), 9)) 
					oSection1:cell("APORNPREV"):SetValue(Padl(Strzero(Val(STRTRAN(Transform(nAporNaoPrev, "999999999"),".","")),9), 9)) 
					oSection1:cell("APORCIAAFP"):SetValue(Padl(Strzero(Val(STRTRAN(Transform(nAporCiaAFP, "999999999"),".","")),9), 9)) 
					oSection1:cell("RA_TRAAFP"):SetValue((cAliasSRA)->RA_TRAAFP) 
					oSection1:cell("CODAFP"):SetValue(cCodAFP) 
				EndIF
			
			    nSequencia ++
			Else
				If lTRep
					oSection1:cell("EXCAPOR"):SetValue(0) 
					oSection1:cell("REMASEGUR"):SetValue(Padl(Strzero(0,9), 9)) 
					oSection1:cell("APORPREV"):SetValue(Padl(Strzero(0,9), 9)) 
					oSection1:cell("APORNPREV"):SetValue(Padl(Strzero(0,9), 9)) 
					oSection1:cell("APORCIAAFP"):SetValue(Padl(Strzero(0,9), 9)) 
					oSection1:cell("RA_TRAAFP"):SetValue(" ") 
					oSection1:cell("CODAFP"):SetValue(" ") 
				EndIF
		    EndIf
			If lTRep
				oSection1:PrintLine()
			EndIf
	 EndIF
	 
	(cAliasSRA)->( DbSkip() )
EndDo	

If lTRep
	oSection1:Finish()
	oReport:EndPage()
	IF nNum < 1
		MsgAlert(STR0031) //"No se encontro informaci�n con los parametros asignados"
		oReport:CancelPrint()
		oReport:EndReport()
	EndIf
EndIf

(cAliasSRA)->(DbCloseArea())
fClose(nHdl)
Return


/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��cao  �fGR106join  � Autor �  Equipe RH           � Data � 19/09/2012       ���
����������������������������������������������������������������������������������Ĵ��
���Descrica��o �O tratamento a seguir deve-se ao problema do embedded SQL n�o      ���
���          �converter clausula "SUBSTRING" no INNER JOIN, ao usar banco de dados ���
���          �ORACLE. E segundo sustenta�ao FRAMEWORK, devemos alterar consulta SQL���
����������������������������������������������������������������������������������Ĵ�� 
���Parametro �ExpC1 - Obrigatorio - Vari�vel com Primeira tabela do "inner join"   ���
���          �ExpC2 - Obrigatorio - Vari�vel com Segunda  tabela do "inner join"   ���
���          �ExpC3 - Vari�vel indica se retorno dever� conter "%   %". Caso vazio ���
���          �        o seu valor padr�o ser� "".                                  ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      �GPER106                                                              ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
Static Function fGR890join(cTabela1, cTabela2,cEmbedded)
Local cFiltJoin := ""
Default cEmbedded := ""

cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded	

If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
EndIf

Return (cFiltJoin)


//Exrae los conceptos de acuerdo al tipo de ausencia
static function ExtraeTipo

Local aFas:={"","",""}		
Local cFilRCM:=	XFILIAL("RCM")

dbSelectArea("RCM")
dbSetOrder(1) //RCM_FILIAL+RCM_TIPO
RCM->(DBSEEK(cFilRCM))

While RCM->(!Eof()) .and. RCM->RCM_FILIAL== cFilRCM
		
	If RCM->RCM_CODSEF $ "05/06" //Conceptos que son subsidiados por ESSALUD
		aFas[2]+= "'" + RCM->RCM_PD + "',"
		aFas[1] +=  "'" + RCM->RCM_PD + "',"
			
	Elseif RCM->RCM_CODSEF $ "09/20/21/22"
		aFas[3]+= "''" + RCM->RCM_PD + "',"
		aFas[1] +=  "'" + RCM->RCM_PD + "',"
	Endif
	RCM->(dbSkip())
EndDo
	
	

If !EMPTY(aFas[2])
   	aFas[2] := substr(aFas[2],1,len(aFas[2])-1)
EndIF

If !EMPTY(aFas[3])
   aFas[3] := substr(aFas[3],1,len(aFas[3])-1)
EndIF

If !EMPTY(aFas[1])
   	aFas[1] := "%" + substr(aFas[1],1,len(aFas[1])-1) + "%"
else
   	aFas[1] := "%" + "''" + "%" 
EndIF

Return aFas        
