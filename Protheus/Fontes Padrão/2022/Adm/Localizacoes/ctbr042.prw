#Include "ctbr042.ch"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ctbr042   �Autor  �Renato F. Campos    � Data �  18/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Balancete de Escritura��o                                  ���
���          � Impresso somente em modo Grafico (R4) e Paisagem           ���
�������������������������������������������������������������������������͹��
���Uso       � sigactb                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ctbr042()
Private titulo		:= ""
Private nomeprog	:= "CTBR042"
Private oReport		:= Nil
                                                                                     
If ! FindFunction( "TRepInUse" ) .And. TRepInUse() 
	MsgAlert( STR0004 ) // Relatorio Impresso somente em modo grafico
	Return .F.
EndIf

Pergunte( "CTR042" , .T. ) // efetuo o pergunte antes para a defini��o do modelo a ser impresso 

//������������������������������������������������������Ŀ
//� Transforma parametros Range em expressao (intervalo) �
//��������������������������������������������������������
MakeSqlExpr( "CTR042" )	  

//������������������������������������������������������Ŀ
//� Inicializa a montagem do relatorio                   �
//��������������������������������������������������������
oReport := ReportDef()

If Valtype( oReport ) == 'O'

	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	
	
	oReport:PrintDialog()      
Endif
	
oReport := Nil

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Renato F. Campos    � Data �  18/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Balancete de Escritura��o                                  ���
���          � Impresso somente em modo Grafico (R4) e Paisagem           ���
�������������������������������������������������������������������������͹��
���Uso       � sigactb                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ReportDef()

Local cReport		:= "CTBR042"
Local cDesc			:= OemToAnsi(STR0001) + OemToAnsi(STR0002) + OemToAnsi(STR0003)
Local cPerg	   		:= "CTR042"
Local cMascara		:= ""
Local cSeparador	:= ""
Local aSetOfBook

cTitulo	:= STR0003

//����������������������������������������������������������Ŀ
//� Efetua a pergunta antes de montar a configura��o do      �
//� relatorio, afim de poder definir o layout a ser impresso �
//������������������������������������������������������������
Pergunte( "CTR042" , .F. )
      
makesqlexpr("CTR042")
//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)	    	 �
//����������������������������������������������������������������
If ! Ct040Valid( mv_par07 )
	Return .F.
Else
   aSetOfBook := CTBSetOf( mv_par07 )
Endif
                                                                          
cMascara := RetMasCtb( aSetOfBook[2], @cSeparador )

cPicture := aSetOfBook[4]

oReport	 := TReport():New( cReport,Capital( cTitulo ),cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport ), oReport:CancelPrint(), .T. ) }, cDesc )

//����������������������������������������������������������Ŀ
//� Apos a definicao do relatorio, nao sera possivel alterar |
//| os parametros.                                           �
//������������������������������������������������������������
oReport:ParamReadOnly()

//����������������������������������������������������������Ŀ
//� Relatorio impresso somente em modo paisagem              �
//������������������������������������������������������������
oReport:SetLandScape(.T.)

//����������������������������������������������������������Ŀ
//� Montagem da estrutura do relatorio                       |
//������������������������������������������������������������
oSection1  := TRSection():New( oReport, STR0004, { "cArqTmp" , "CT1" } ,, .F., .F. ) //"Plano de contas"

TRCell():New( oSection1, "CONTA"      ,,STR0007							 /*Titulo*/	,/*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*CodeBlock*/)
TRCell():New( oSection1, "DESCCTA"    ,,STR0008							 /*Titulo*/	,/*Picture*/, 40/*Tamanho*/, /*lPixel*/, /*CodeBlock*/)
TRCell():New( oSection1, "SALDODEB"   ,,STR0009+Chr(13)+Chr(10)+STR0013/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
TRCell():New( oSection1, "SALDOCRD"   ,,STR0009+Chr(13)+Chr(10)+STR0014/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
TRCell():New( oSection1, "SALDOANTDB" ,,STR0010+Chr(13)+Chr(10)+STR0013/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
TRCell():New( oSection1, "SALDOANTCR" ,,STR0010+Chr(13)+Chr(10)+STR0014/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
TRCell():New( oSection1, "SALDOATUDB" ,,STR0011+Chr(13)+Chr(10)+STR0013/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
TRCell():New( oSection1, "SALDOATUCR" ,,STR0011+Chr(13)+Chr(10)+STR0014/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
TRCell():New( oSection1, "MOVIMENTOD" ,,STR0012+Chr(13)+Chr(10)+STR0013/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
TRCell():New( oSection1, "MOVIMENTOC" ,,STR0012+Chr(13)+Chr(10)+STR0014/*Titulo*/	,/*Picture*/, 17/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"CENTER")
                                                                                 
TRPosition():New( oSection1, "CT1", 1, {|| xFilial( "CT1" ) + cArqTMP->CONTA })

oSection1:SetTotalInLine(.T.)          
oSection1:SetTotalText( '' )

Return( oReport )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ReportPrint�Autor  �Renato F. Campos   � Data �  18/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Efetua a impressao do relatorio							  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SigaCTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportPrint( oReport )
Local oSection1 	:= oReport:Section(1) 
Local aSetOfBook
Local lRet			:= .T.
Local lPrintZero	:= (mv_par14==1)
Local lPula			:= (mv_par13==1) 
Local lNormal		:= .T.
Local lVlrZerado	:= (mv_par08==1)
Local nDecimais
Local nDivide		:= 1
Local lImpAntLP		:= (mv_par16 == 1)
Local dDataLP		:= mv_par17
Local lImpSint		:= Iif(mv_par06=1 .Or. mv_par06 ==3,.T.,.F.)
Local lRecDesp0		:= (mv_par18 == 1)
Local cRecDesp		:= mv_par19
Local dDtZeraRD		:= mv_par20
Local oMeter
Local oText
Local oDlg
Local aCtbMoeda		:= {}
Local cArqTmp		:= ""
Local cSeparador	:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cPicture
Local nCont			:= 0
Local cFilUser		:= ""
Local cRngFil	 // range de filiais para a impress�o do relatorio
Local dDtCorte	 	:= mv_par03 //If ( cPaisLoc == "PTG" , mv_par03 , CTOD("  /  /  ") ) // data de corte - usado em Portugal

//��������������������������������������������������������������Ŀ
//� Tratativa para os parametros que ir�o funcionar somente para �
//� TOPCONN                                                      �
//����������������������������������������������������������������
#IFNDEF TOP
	cRngFil	   		:= xFilial( "CT7" )
	dDtCorte	 	:= CTOD("  /  /  ")
#ENDIF

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)             �
//����������������������������������������������������������������
If ! ct040Valid( mv_par07 )
	Return .F.
Else
   aSetOfBook := CTBSetOf(mv_par07)
Endif

//��������������������������������������������������������������Ŀ
//� Valida��o das moedas do CTB                                  �
//����������������������������������������������������������������
aCtbMoeda := CtbMoeda( mv_par09 , nDivide )

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
	Return .F.
Endif

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par09)

If Empty( aSetOfBook[2] )
	cMascara := GetMv( "MV_MASCARA" )
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 		:= aSetOfBook[4]

//��������������������������������������������������������������Ŀ
//� Seta o numero da pagina                                      �
//����������������������������������������������������������������
oReport:SetPageNumber( mv_par12 )

//��������������������������������������������������������������������������Ŀ
//�Titulo do Relatorio                                                       �
//����������������������������������������������������������������������������
Titulo += 	STR0003 + STR0005 + DTOC(MV_PAR01) +;	// "DE"
			STR0006 + DTOC(MV_PAR02) + " " + CtbTitSaldo(mv_par10)	+ " " + cDescMoeda // "ATE"

oReport:SetTitle(Titulo)

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,MV_PAR02,oReport:Title(),,,,,oReport) } )

//��������������������������������������������������������������Ŀ
//� Filtro de usuario                                            �
//����������������������������������������������������������������
cFilUser := oSection1:GetAdvplExpr( "CT1" )

If Empty(cFilUser)
	cFilUser := ".T."
EndIf

MakeSqlExpr( "CTR042" )	  
cRngFil		:= mv_par21

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao			  		     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,mv_par01,mv_par02,"CT7","",mv_par04,;
						mv_par05,,,,,,,mv_par09,mv_par10,aSetOfBook,,,,,;
						.F.,.F.,mv_par12,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
						cRecDesp,dDtZeraRD,,,,,,,,,cRngFil,dDtCorte)},;
						OemToAnsi(OemToAnsi(STR0020)),;//"Criando Arquivo Tempor�rio..."
						OemToAnsi(STR0004))  			//"Balancete de Escritura��o"
                
nCount := cArqTmp->( RecCount() )

oReport:SetMeter( nCont )

lRet := !( nCount == 0 .And. !Empty(aSetOfBook[5]))

If lRet
	cArqTmp->(dbGoTop())
	
	// define se ao imprimir uma linha a proxima � pulada
	oSection1:OnPrintLine( {|| IIf( lPula , oReport:SkipLine(),NIL) } )
	
	If lNormal
		oSection1:Cell("CONTA"):SetBlock( {|| EntidadeCTB(cArqTmp->CONTA,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.)} )
	Else
		oSection1:Cell("CONTA"):SetBlock( {|| cArqTmp->CTARES } )
	EndIf	
	
	oSection1:Cell("DESCCTA"):SetBlock( { || cArqTMp->DESCCTA } )
	
	oSection1:Cell("SALDODEB"  ):SetBlock( { || ValorCTB(cArqTmp->SALDODEB  ,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOCRD"  ):SetBlock( { || ValorCTB(cArqTmp->SALDOCRD  ,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOANTDB"):SetBlock( { || ValorCTB(cArqTmp->SALDOANTDB,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOANTCR"):SetBlock( { || ValorCTB(cArqTmp->SALDOANTCR,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOATUDB"):SetBlock( { || ValorCTB(cArqTmp->SALDOATUDB,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOATUCR"):SetBlock( { || ValorCTB(cArqTmp->SALDOATUCR,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("MOVIMENTOD"):SetBlock( { || ValorCTB(IIF( (cArqTmp->SALDOATUDB - cArqTmp->SALDOATUCR) > 0 , cArqTmp->SALDOATUDB - cArqTmp->SALDOATUCR,0 ) ,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("MOVIMENTOC"):SetBlock( { || ValorCTB(IIF( (cArqTmp->SALDOATUDB - cArqTmp->SALDOATUCR) < 0 , cArqTmp->SALDOATUDB - cArqTmp->SALDOATUCR,0 ),,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )

	oSection1:Print()
EndIf

dbSelectArea( "cArqTmp" )
Set Filter TO
dbCloseArea()

If Select( "cArqTmp" ) == 0
	FErase( cArqTmp + GetDBExtension())
	FErase( cArqTmp + OrdBagExt())
EndIF	

Return .T.

/*  
Modelo do relatorio a ser impresso                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             e
+---------------------------------------------------+-----------------------------+-----------------------------------------------------------+-----------------------------+
|                                                   |           Di�rio            |                             Raz�o                         |          Balancete          |
|                                                   +-----------------------------+-----------------------------+-----------------------------+-----------------------------+
|                                                   |       Movimento do M�s      |      Movimento Anterior     |     Movimento Geral         |           Saldos            |
+--------------------+------------------------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
|    Cod. Conta      |    Descri��o da Conta        |   D�bito     |   Cr�dito    |    D�bito    |   Cr�dito    |   D�bito     |   Cr�dito    |   D�bito     |   Cr�dito    |
+--------------------+------------------------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
|x.x.x.xxx.xxxx      |Descri��o da Conta x          |         0,00 |         0,00 |         0,00 |         0,00 |         0,00 |         0,00 |         0,00 |         0,00 |
+--------------------+------------------------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
|x.x.x.xxx.xxxx      |Descri��o da Conta x          |    100000,00 |    100000,00 |       500,00 |         0,00 |    100500,00 |    100000,00 |       500,00 |         0,00 |
+--------------------+------------------------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
|Conta		20   	 |Descricao   40   				|Debito      14|Credito     14|Debito      14|Credito     14|Debito      14|Credito     14|Debito      14|Credito     14|
+--------------------+------------------------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
*/
