#include "PROTHEUS.Ch"
#include "ctbr543.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR543   �Autor  � Totvs              � Data �  27/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ctbr543()

If FindFunction( "TRepInUse" ) .And. TRepInUse()
	CTBR543R4()
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR543R4 �Autor  � Totvs              � Data �  27/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ctbr543R4()
Local aArea := GetArea()
Local cPergunte := "CTR543"

Private NomeProg := FunName()

// Acesso somente pelo SIGACTB
If !AMIIn( 34 )
	Return
EndIf

If !Pergunte( cPergunte , .T. )
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
���Programa  �ReportDef �Autor  � Totvs              � Data �  27/09/10   ���
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
Local cPerg			:= "CTR543"
Local cReport		:= "CTBR543"
Local cTitulo		:= STR0002				// "Analise Vertical e Horizontal"
Local cDesc			:= STR0016 + STR0017	// "Este programa ira imprimir o Demonstrativo de Resultado,"                                                                                                                                                                                                                                                                                                                                                                                                                                                          
                                            // "de acordo com os par�metros informados pelo usu�rio. "
Local oReport
Local oDemRenda
Local oCabecSup
Local aOrdem 		:= {}
Local aTamVal		:= TamSX3( "CT2_VALOR" )
Local cDescMoeda    := ""
Local nLineSize     := 0 

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

oReport:SetLandScape( .F. )
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


nLineSize := 75 + (aTamVal[1]*IIF(MV_PAR13 ==1,3,2)) //Tamanho da Linha do cabe�alho superior(Descri��o da Conta + Valor Per�odo 1 + Valor Per�odo 2

//adiciona ordens do relatorio   

//Cabe�alho
oCabecSup  := TRSection():New( oReport, "CABECSUP", {"cArqTmp"},, .F., .F. )										// Se��o do Cabecalho
TRCell():New( oCabecSup, "CBCS_TIT1","",Space(nLineSize),,nLineSize,,,,,,,,,,, )   								// Espa�os			
TRCell():New( oCabecSup, "CBCS_TIT2" , "", STR0003,, 35,,,"CENTER",,"CENTER",,,,,,.T.)				            // "An�lise Vertical"
TRCell():New( oCabecSup, "CBCS_TIT3" ,"",STR0004,,aTamVal[1]+11,,,"CENTER",,"CENTER",,,,,,.T.)	                // "An�lise Horizontal" 
TRCell():New( oCabecSup, "CBCS_ESPACO", "",Space(100),,100,,,"RIGHT",,"RIGHT")									// Espa�os para completar Linha

//Detalhes
oDemRenda  := TRSection():New( oReport, "DETALHES", {"cArqTmp"},, .F., .F. )        						// Se��o de Detalhes
TRCell():New( oDemRenda, "CLN_CONTA"	,""," "	,,60,,)														// Descri��o da Conta
TRCell():New( oDemRenda, "CLN_MOVPERIODO"	,"",,,aTamVal[1]+2,,,"RIGHT",,"RIGHT")							// Mov. no Per�odo
TRCell():New( oDemRenda, "CLN_SALDOATU"	,"",,,aTamVal[1]+2,,,"RIGHT",,"RIGHT")								// Saldo Atual
TRCell():New( oDemRenda, "CLN_SALDOANT"	,"",,,aTamVal[1]+2,,,"RIGHT",,"RIGHT")								// Saldo Anterior
TRCell():New( oDemRenda, "CLN_ESPACO"	,"",Space(5),,5,,,"RIGHT",,"RIGHT")								// Espa�os de Separa��o
TRCell():New( oDemRenda, "CLN_VERTATU" ,"","",,10,,,"RIGHT",,"RIGHT")								 		// A. Vertical Per�odo Atual 
TRCell():New( oDemRenda, "CLN_VERTANT" ,"","",,10,,,"RIGHT",,"RIGHT")										// A. Vertical Per�odo Anterior 
TRCell():New( oDemRenda, "CLN_HORIZABS","",STR0005,,aTamVal[1]+2,,,"RIGHT",,"RIGHT")						// A. Horizontal Absoluto
TRCell():New( oDemRenda, "CLN_HORIZREL", "",STR0007,,10,,,"RIGHT",,"RIGHT")								// A. Horizontal Relativos 
TRCell():New( oDemRenda, "CLN_ESPACO2", "",Space(100),,100,,,"RIGHT",,"RIGHT")							// Espa�os para completar Linha


oDemRenda:SetTotalInLine(.F.) 
oCabecSup:SetHeaderPage()

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
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local oDemRenda		:= oReport:Section( 2 ) 
Local aSetOfBook	:= CTBSetOf( MV_PAR02 )
Local aCtbMoeda		:= {}
Local cArqTmp
Local cPicture
Local aTotal 		:= {}
Local nTotal		:= 0
Local nTotMes		:= 0
Local nTotalSint	:= 0
Local nTotAtu		:= 0
Local nTotVisA		:= 0
Local nTotVisM		:= 0
Local aColunas		:= {}
Local nColuna
Local cTpValor		:= GetMV( "MV_TPVALOR" )
Local lImpTrmAux	:= MV_PAR08 == 1
Local cArqTrm		:= ""
Local cProcesso     := STR0002
Local aTamVal		:= TamSX3( "CT2_VALOR" )
Local cTitAux
Local cMoedaDesc	:= iif( empty( mv_par14 ) , mv_par03 , mv_par14 )

Private dInicio
Private dFinal
Private dPeriodo0
Private cTitulo


If MV_PAR04 == 2 
	dInicio  	:= MV_PAR05
	dFinal		:= MV_PAR06
	dPeriodo0	:= CtbPeriodos( MV_PAR03, dInicio, dFinal, .F., .F. )[1][2]
	cTitAux		:= STR0012 + " " + DtoC( dInicio ) + " " + STR0011 + " " + DtoC( dFinal )
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

oReport:SetTitle( oReport:Title() + "  " + cTitAux )
oReport:SetPageNumber(mv_par07) //mv_par07 - Pagina Inicial
 

oDemRenda:Cell("CLN_VERTATU" ):SetTitle(Dtoc(dFinal))
oDemRenda:Cell("CLN_VERTANT" ):SetTitle(Dtoc(dInicio))
oDemRenda:Cell("CLN_SALDOATU" ):SetTitle(Dtoc(dFinal))
oDemRenda:Cell("CLN_SALDOANT" ):SetTitle(Dtoc(dInicio))  
oDemRenda:Cell( "CLN_MOVPERIODO" ):Disable()

oDemRenda:Cell("CLN_CONTA"):SetBlock( { || Iif(cArqTmp->COLUNA<2,Iif(cArqTmp->TIPOCONTA="2",cArqTmp->DESCCTA,cArqTmp->DESCCTA),"") } )		


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

	If MV_PAR10 <= 2 .AND. cArqTmp->TIPOCONTA == "1"
		nTotal := aScan( aTotal, { |x| x[1] = cArqTmp->CONTA } )
		If nTotal = 0
			Aadd( aTotal, { cArqTmp->CONTA, 0, 0 } )
			nTotal := Len( aTotal )
		EndIf

		aTotal[nTotal][2]	+= cArqTmp->SALDOANT
		aTotal[nTotal][3]	+= cArqTmp->SALDOATU
	EndIf

	If cArqTmp->TOTVIS == "1"
		nTotVisM := cArqTmp->SALDOANT
		nTotVisA := cArqTmp->SALDOATU
	EndIf
	
	cArqTmp->( DbSkip() )
End

If Len( aTotal ) == 0
	aTotal := { { "", 0, 0 } }
EndIf

//oDemRenda:Cell( "CONTAS" ):SetBlock( { || cArqTmp->CONTA } )

If MV_PAR13 == 1 
	oDemRenda:Cell( "CLN_MOVPERIODO" ):Enable()
	oDemRenda:Cell( "CLN_MOVPERIODO" ):SetTitle(STR0024)  // "Mov. no Per�odo"
	oDemRenda:Cell( "CLN_MOVPERIODO" ):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO,,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.) } )
EndIf 

// Apresenta as colunas de saldo anterior e movimento do periodo
oDemRenda:Cell( "CLN_SALDOATU" ):SetBlock( { || ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.) } )
oDemRenda:Cell( "CLN_SALDOANT" ):SetBlock( { || ValorCTB(cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.) } )

If MV_PAR10 < 3
	oDemRenda:Cell( "CLN_VERTATU" ):SetBlock( { || Transform((cArqTmp->(SALDOATU)  / nTotAtu) * 100, "@E 9999.99")  + " %" })
	oDemRenda:Cell( "CLN_VERTANT" ):SetBlock( { || Transform((cArqTmp->(SALDOANT) / nTotMes) * 100, "@E 9999.99") + " %" })
Else
	oDemRenda:Cell( "CLN_VERTATU" ):SetBlock( { || Transform((cArqTmp->(SALDOATU) / nTotVisA) * 100 , "@E 9999.99")  + " %" })
	oDemRenda:Cell( "CLN_VERTANT" ):SetBlock( { || Transform((cArqTmp->(SALDOANT) / nTotVisM) * 100  , "@E 9999.99") + " %"})
EndIf                                                                                                               

oDemRenda:Cell( "CLN_HORIZABS" ):SetBlock( { || ValorCTB(cArqTmp->(SALDOATU - SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.) } )
oDemRenda:Cell( "CLN_HORIZREL" ):SetBlock( { || Transform( cArqTmp->( ( SALDOATU - SALDOANT ) / SALDOANT ) * 100, "@E 9999.99")  + " %"})

oDemRenda:Init()

For nColuna := 1 To Len( aColunas )
	cArqTmp->( MsGoto( aColunas[nColuna] ) )

	If cArqTmp->DESCCTA = "-"
		oReport:ThinLine()   	// horizontal
	Else
		nTotal := aScan( aTotal, { |x| x[1] = cArqTmp->SUPERIOR } )
		If MV_PAR10 == 1		//Se considerar o % na sintetica local                     
			If (nTotMes == 0 .AND. nTotAtu == 0) .AND. (Empty( cArqTmp->SUPERIOR ) .OR. cArqTmp->TIPOCONTA == "1") 
				nTotMes := cArqTmp->SALDOANT
				nTotAtu := cArqTmp->SALDOATU
			EndIf
		ElseIf MV_PAR10 == 2	//Se considerar o % do total em relacao a conta de nivel 1
			If nTotal > 0 
				If cArqTmp->TIPOCONTA == "2" 
					nTotMes := aTotal[nTotal][2]
					nTotAtu := aTotal[nTotal][3]
				Else 
					nTotMes := cArqTmp->SALDOANT
					nTotAtu := cArqTmp->SALDOATU				
				EndIf    	
					
			Else				
				nTotMes := cArqTmp->SALDOANT
				nTotAtu := cArqTmp->SALDOATU				
			EndIf					

		EndIf
		
		oDemRenda:PrintLine()	
	EndIf
Next


oDemRenda:Finish()
oReport:ThinLine()

If lImpTrmAux     
	oReport:EndPage()   
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
               
