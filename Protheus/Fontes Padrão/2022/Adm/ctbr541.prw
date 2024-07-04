#include "PROTHEUS.Ch"
#include "ctbr541.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR541   �Autor  � Totvs              � Data �  27/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ctbr541()

If TRepInUse()
	CTBR541R4()
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR541R4 �Autor  � Totvs              � Data �  27/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ctbr541R4()
Local aArea := GetArea()

Private NomeProg := FunName()

// Acesso somente pelo SIGACTB
If !AMIIn( 34 )
	Return
EndIf


If !Pergunte( "CTR541", .T. )
	Return
EndIf

//�����������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros					  		�
//� MV_PAR01				// Data referencia                		�
//� MV_PAR02				// Configuracao de livros			    �
//� MV_PAR03				// Moeda?          			     	    �
//� MV_PAR04				// Usa Data referencia ou periodo De Ate*
//� MV_PAR05				// Periodo De            				�
//� MV_PAR06				// Periodo Ate     			     	    � 
//� MV_PAR07				// Folha Inicial    			     	�
//� MV_PAR08				// Imprime Arq. Termo Auxiliar?			�
//� MV_PAR09				// Arq.Termo Auxiliar ?					� 
//� MV_PAR10				// Consid. % em relacao ao 1o nivel?    � 
//� MV_PAR11				// Tipo de Saldo?                       � 
//� MV_PAR12				// Titulo como nome da Visao?           � 
//� MV_PAR13				// Mov. do Periodo?                     � 
//�������������������������������������������������������������������

// faz a valida��o do livro
If !VdSetOfBook( MV_PAR02 , .T. )
   Return .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()

If ValType( oReport ) == 'O'
	If !Empty( oReport:uParam )
		Pergunte( oReport:uParam , .F. )
	EndIf	
	
	oReport:PrintDialog()
EndIf

oReport := Nil

RestArea( aArea )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR541R4 �Autor  � Totvs              � Data �  27/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
���          � Definicao das colunas do relatorio                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local cPerg			:= "CTR541"
Local cReport		:= "CTBR541"
Local cTitulo		:= STR0002
Local cDesc			:= STR0016 + STR0017	//	"Este programa ira imprimir o Demonstrativo de Renda, "
                                            //	"de acordo com os par�metros informados pelo usu�rio. "
Local oReport
Local oDemRenda
Local aOrdem 		:= {}
Local aTamVal		:= TamSX3( "CT2_VALOR" )

Local aSetOfBook	:= CTBSetOf( MV_PAR02 )

cTitulo		:= If( !Empty( aSetOfBook[10] ), aSetOfBook[10], cTitulo )		// Titulo definido SetOfBook
If ValType( MV_PAR12 ) == "N" .And. MV_PAR12 == 1
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

//������������������������������������������������������������������������Ŀ
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
oReport := TReport():New( 	cReport, cTitulo, cPerg,;
							{ |oReport| Pergunte( cPerg, .F. ), If( !Ct040Valid( MV_PAR02 ), oReport:CancelPrint(), ReportPrint( oReport ) ) },;
							cDesc )

oReport:SetLandScape( .T. )
oReport:ParamReadOnly()

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
//�                                                                        �
//��������������������������������������������������������������������������
//adiciona ordens do relatorio
oDemRenda := TRSection():New( oReport, STR0018, {  "cArqTmp" }, aOrdem /*{}*/, .F., .F. )  //"Detalhe"
TRCell():New( oDemRenda, "CONTA"		, "", STR0021/*Titulo*/	,/*Picture*/, TamSX3( "CT1_CONTA" )[1] 	/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)					//	"Conta"
TRCell():New( oDemRenda, "CLN_CONTA"	, "", STR0019/*Titulo*/	,/*Picture*/, 50 						/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)					//	"Descricao da Conta"
TRCell():New( oDemRenda, "SUPERIOR"		, "", STR0022/*Titulo*/	,/*Picture*/, TamSX3( "CT1_CONTA" )[1] 	/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)					//	"Conta Superior"

// Apresenta as colunas de saldo anterio e movimento do periodo
If MV_PAR13 == 1
	TRCell():New( oDemRenda, "SALDOANT" , "", STR0023/*Titulo*/	,/*Picture*/, aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")	//	"Saldo Anterior"
EndIf

TRCell():New( oDemRenda, "CLN_VLRPER_0" , "", STR0013/*Titulo*/	,/*Picture*/, aTamVal[1]+2 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")	//	"Periodo"
TRCell():New( oDemRenda, "CLN_VLRPERCE" , "", STR0014/*Titulo*/	,/*Picture*/, 8            /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")	//	" % "
TRCell():New( oDemRenda, "CLN_VLRACUMU" , "", STR0009/*Titulo*/	,/*Picture*/, aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")	//	"Acumulado"
TRCell():New( oDemRenda, "CLN_VLRPERACU", "", STR0014/*Titulo*/	,/*Picture*/, 8            /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")	//	" % "

oDemRenda:Cell( "CLN_CONTA" ):SetLineBreak()
oDemRenda:SetHeaderPage()

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor � TOtvs             � Data �  27/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
���          � Funcao de impressao do relatorio acionado pela execucao    ���
���          � do botao <OK> da PrintDialog()                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)
Local oDemRenda		:= oReport:Section( 1 )

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aSetOfBook	:= CTBSetOf( MV_PAR02 )
Local aCtbMoeda		:= {}
Local cArqTmp
Local cPicture
Local aTotal 		:= {}
Local nTotal		:= 0
Local nTotMes		:= 0
Local nTotAtu		:= 0
Local nTotVisA		:= 0
Local nTotVisM		:= 0
Local aColunas		:= {}
Local nColuna
Local cTpValor		:= GetMV( "MV_TPVALOR" )
Local lImpTrmAux	:= IIf( MV_PAR08 == 1, .T., .F. )
Local cArqTrm		:= ""
Local cProcesso     := STR0002
Local aTamVal		:= TamSX3( "CT2_VALOR" )
Local cTitAux
Local lCharSinal	:= .F.

Private dInicio
Private dFinal
Private dPeriodo0
Private cTitulo

If MV_PAR04 == 2 
	dInicio  	:= MV_PAR05
	dFinal		:= MV_PAR06
	dPeriodo0	:= CtbPeriodos( MV_PAR03, dInicio, dFinal, .F., .F. )[1][2]
	cTitAux		:= STR0012 + DtoC( dInicio ) + STR0011 + DtoC( dFinal )
Else
	dInicio  	:= CtoD( "01/" + Subs( DtoC( MV_PAR01 ), 4 ) )
	dFinal		:= MV_PAR01
	dPeriodo0 	:= CtoD( Str( Day( LastDay( MV_PAR01 ) ), 2 ) + "/" + Subs( DtoC( MV_PAR01 ), 4 ) )
	cTitAux 	:= ""
EndIf	

aCtbMoeda := CtbMoeda( MV_PAR03, aSetOfBook[9] )
If Empty( aCtbMoeda[1] )
	Help( " ", 1, "NOMOEDA" )
	oReport:CancelPrint()
    Return .F.
EndIf

nDecimais 	:= DecimalCTB( aSetOfBook, MV_PAR03 )
cPicture 	:= aSetOfBook[4]
If !Empty( cPicture ) .And. Len( Trans( 0, cPicture ) ) > 15
	cPicture := ""
EndIf

oReport:SetTitle( oReport:Title() + cTitAux )
oReport:SetPageNumber( MV_PAR07 )
oReport:SetCustomText( {|| CtCGCCabTR( ,,,,, dDataBase, oReport:Title(),,,,, oReport ) } )

oDemRenda:Cell( "CONTA" ):SetBorder( "LEFT" )
oDemRenda:Cell( "CLN_CONTA" ):SetBorder( "LEFT" )
oDemRenda:Cell( "SUPERIOR" ):SetBorder( "LEFT" )
oDemRenda:Cell( "CLN_VLRPER_0" ):SetBorder( "LEFT" )
oDemRenda:Cell( "CLN_VLRPERCE" ):SetBorder( "LEFT" )

// Apresenta as colunas de saldo anterio e movimento do periodo
If MV_PAR13 == 1
	oDemRenda:Cell( "SALDOANT" ):SetBorder( "LEFT" )
EndIf

oDemRenda:Cell( "CLN_VLRACUMU" ):SetBorder( "LEFT" )
oDemRenda:Cell( "CLN_VLRPERACU" ):SetBorder( "LEFT" )
oDemRenda:Cell( "CLN_VLRPERACU" ):SetBorder( "RIGHT" )

If MV_PAR04 == 2
	oDemRenda:Cell( "CLN_VLRPER_0" ):SetTitle( STR0013 )  //"Periodo "
	oDemRenda:Cell( "CLN_VLRPERCE" ):SetTitle( STR0014 )  //"% "
	oDemRenda:Cell( "CLN_VLRACUMU" ):SetTitle( STR0009 )  //Acumulado
	oDemRenda:Cell( "CLN_VLRPERACU" ):SetTitle( STR0014 ) //"% "
Else
	oDemRenda:Cell( "CLN_VLRPER_0" ):SetTitle( DtoC( MV_PAR01 ) ) 
	oDemRenda:Cell( "CLN_VLRPERCE" ):SetTitle( STR0008 )  //"% Tot"
	oDemRenda:Cell( "CLN_VLRACUMU" ):SetTitle( STR0007 + Subs( DtoC( MV_PAR01 ), 4 ) )  //"Mes "	
	oDemRenda:Cell( "CLN_VLRPERACU" ):SetTitle( STR0008 ) //"% "
EndIf

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao						 �
//����������������������������������������������������������������
MsgMeter( {|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan( oMeter, oText, oDlg, @lEnd, @cArqTmp,;
				dInicio, dFinal, "", "", "", Repl( "Z", Len( CT1->CT1_CONTA ) ),;
				"", Repl( "Z", Len( CTT->CTT_CUSTO ) ), "", Repl( "Z", Len( CTD->CTD_ITEM ) ),;
				"", Repl( "Z", Len( CTH->CTH_CLVL ) ), MV_PAR03,;
				MV_PAR11, aSetOfBook, Space(2), Space(20), Repl( "Z", 20 ), Space(30) ) },;
				STR0006, cProcesso ) //"Criando Arquivo Temporario..."

dbSelectArea( "cArqTmp" )
dbGoTop()

While cArqTmp->( !Eof() )
	Aadd( aColunas, RecNo() )

	If cArqTmp->IDENTIFI = "4" .OR. ( MV_PAR10 == 1 .AND. !Empty( cArqTmp->SUPERIOR ) )
		nTotal := aScan( aTotal, { |x| x[1] = cArqTmp->CONTA } )
		If nTotal = 0
			Aadd( aTotal, { cArqTmp->CONTA, 0, 0 } )
			nTotal := Len( aTotal )
		EndIf

		aTotal[nTotal][2]	+= cArqTmp->SALDOPER
		aTotal[nTotal][3]	+= cArqTmp->(SALDOATU - SALDOANT)
	EndIf

	If cArqTmp->TOTVIS == "1"
		nTotVisM := cArqTmp->SALDOPER
		nTotVisA := cArqTmp->(SALDOATU - SALDOANT)
	EndIf
	
	cArqTmp->( DbSkip() )
End

If Len( aTotal ) == 0
	aTotal := { { "", 0, 0 } }
EndIf

oDemRenda:Cell( "CONTA" ):SetBlock( { || cArqTmp->CONTA } )
oDemRenda:Cell( "CLN_CONTA" ):SetBlock( { || cArqTmp->DESCCTA } )
oDemRenda:Cell( "SUPERIOR" ):SetBlock( { || cArqTmp->SUPERIOR } )

// Apresenta as colunas de saldo anterio e movimento do periodo
If MV_PAR13 == 1
	oDemRenda:Cell( "SALDOANT" ):SetBlock( { || ValorCTB(cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.,,lCharSinal) } )
EndIf

If MV_PAR10 < 3
	oDemRenda:Cell( "CLN_VLRPER_0" ):SetBlock( { || ValorCTB(cArqTmp->(SALDOATU - SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,,, .F.,,lCharSinal) })
	oDemRenda:Cell( "CLN_VLRPERCE" ):SetBlock( { || Transform((cArqTmp->(SALDOATU - SALDOANT) / nTotAtu) * 100, "@E 9999.99") })
	oDemRenda:Cell( "CLN_VLRACUMU" ):SetBlock( { || ValorCTB(cArqTmp->SALDOPER,,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.,,lCharSinal) } )
	oDemRenda:Cell( "CLN_VLRPERACU" ):SetBlock( { || Transform(cArqTmp->(SALDOPER / nTotMes) * 100, "@E 9999.99")})
Else
	oDemRenda:Cell( "CLN_VLRPER_0" ):SetBlock( { || ValorCTB(cArqTmp->(SALDOATU - SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,,, .F.,,lCharSinal) })
	oDemRenda:Cell( "CLN_VLRPERCE" ):SetBlock( { || Transform( cArqTmp->(SALDOATU - SALDOANT) * 100 / nTotVisA, "@E 9999.99") })
	oDemRenda:Cell( "CLN_VLRACUMU" ):SetBlock( { || ValorCTB(cArqTmp->SALDOPER,,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.,,lCharSinal) } )
	oDemRenda:Cell( "CLN_VLRPERACU" ):SetBlock( { || Transform( cArqTmp->SALDOPER * 100 / nTotVisM, "@E 9999.99")})
EndIf

oDemRenda:Init()

For nColuna := 1 To Len( aColunas )
	cArqTmp->( MsGoto( aColunas[nColuna] ) )

	If cArqTmp->DESCCTA = "-"
		oReport:ThinLine()   	// horizontal
	Else
		nTotal := aScan( aTotal, { |x| x[1] = cArqTmp->SUPERIOR } )
		If MV_PAR10 == 1		//Se considerar o % na sintetica local
			If Empty( cArqTmp->SUPERIOR ) .OR. cArqTmp->TIPOCONTA == "1"
				nTotMes := cArqTmp->SALDOPER
				nTotAtu := cArqTmp->( SALDOATU - SALDOANT )
			ElseIf nTotal > 0
				nTotMes := aTotal[nTotal][2]
				nTotAtu := aTotal[nTotal][3]
			EndIf

		ElseIf MV_PAR10 == 2	//Se considerar o % do total em relacao a conta de nivel 1
			If Empty( cArqTmp->SUPERIOR )
				nTotMes := cArqTmp->SALDOPER
				nTotAtu := cArqTmp->( SALDOATU - SALDOANT )
			EndIf					

		EndIf
		
		oDemRenda:PrintLine()	
	EndIf
Next

oDemRenda:Finish()
oReport:ThinLine()

If lImpTrmAux
	cArqTRM 	:= MV_PAR09
	aVariaveis	:= {}

    // Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( DbSeek( PadR( "CTR500" , Len( X1_GRUPO ) , ' ' ) + "01" ) )

	While SX1->X1_GRUPO == PadR( "CTR500" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD( aVariaveis,{ Rtrim( Upper( SX1->X1_VAR01 ) ), &( SX1->X1_VAR01 ) } )
		SX1->( dbSkip() )
	End
	
	If !File( cArqTRM )
		aSavSet := __SetSets()
		cArqTRM := CFGX024( cArqTRM, STR0015 ) // "Respons�veis..."
		__SetSets( aSavSet )
		Set( 24, Set( 24 ), .T. )
	EndIf

	If cArqTRM # NIL
		ImpTerm2( cArqTRM, aVariaveis,,,, oReport )
	EndIf	 
EndIf

DbSelectArea( "cArqTmp" )
Set Filter To
dbCloseArea() 
If Select( "cArqTmp" ) == 0
	FErase( cArqTmp + GetDBExtension() )
	FErase( cArqTmp + OrdBagExt() )
EndIf	

dbselectArea( "CT2" )

Return
