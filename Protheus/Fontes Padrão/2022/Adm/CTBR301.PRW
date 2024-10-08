#Include "CTR301.Ch"
#Include "PROTHEUS.Ch"       

#DEFINE 	TAM_VALOR			20   

Static cTpValor  := "D"
STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR301  � Autor � Jonathan Gonzalez     � Data � 04.03.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balance Analitico Sintetico Modelo 1 en 2 monedas		    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR301()                               			 		    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �           	                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR301()

Local nQuadro

Private titulo		:= ""
Private nomeprog	:= "CTBR301" 
Private aQuadro := { "","","","","","","",""}              
Private aSelFil		:= {} 
Private n_pagini 	 

cTpValor := Alltrim(GetMV("MV_TPVALOR"))    

For nQuadro :=1 To Len(aQuadro)
	aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
Next	

CtbCarTxt()

Pergunte("CTR301",.F.)

oReport := ReportDef()

If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	
	
	oReport:PrintDialog()      
Endif
	
oReport := Nil

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Jonathan Gonzalez		� Data � 04.03.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funccion tiene como objetivo definir las secciones,    ���
���          �secciones, columnas, totalizadores del reporte              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                    				    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
local aArea	   	:= GetArea()   
Local CREPORT		:= "CTBR301"
Local CTITULO		:= STR0010	//"Balance Modelo 1 en dos monedas"
Local CDESC		:= OemToAnsi(STR0001)+OemToAnsi(STR0002)+OemToAnsi(STR0003)	// "Este informe es permitir comparar: El Saldo Anterior, D�bito, Cr�dito y Saldo Actual..."
Local cPerg	   	:= "CTR301" 
Local CCOLBAR		:= "|"                   
Local aTamConta	:= TAMSX3("CT1_CONTA")    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= {40}  
Local cPictVal 	:= PesqPict("CT2","CT2_VALOR")
Local nDecimais
Local cMascara		:= ""
Local cSeparador	:= ""
Local nTamConta	:= 20
Local aSetOfBook
Local nMaskFator 	:= 1 
local cMoneda		:= ""

// Efetua a pergunta antes de montar a configura��o do relatorio, afim de poder definir o layout a ser impresso
Pergunte( "CTR301" , .T. )

If mv_par29 == 1 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		Return
	EndIf 
EndIf
	
cMoneda := MV_PAR08

//��������������������������������������������������������������Ŀ
//� Verifica si usa Set Of Books + Plano Gerencial (Si usa Plano �
//� Gerencial -> carga las especificaciones para la impresion)   �
//����������������������������������������������������������������
If ! ct040Valid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf( mv_par06 )
Endif

cMascara := RetMasCtb( aSetOfBook[2], @cSeparador )

If ! Empty( cMascara )
	nTamConta := aTamConta[1] + ( Len( Alltrim( cMascara ) ) / 2 )
Else
	nTamConta := aTamConta[1]
EndIf

cPicture := aSetOfBook[4]

//������������������������������������������������������������������������Ŀ
//�Cracion de componente de impresion                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nombre del reporte                                              �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloque de codigo que sera ejecutado en confirmacion impresion   �
//�ExpC5 : Descripcion                                                     �
//��������������������������������������������������������������������������
oReport	:= TReport():New( cReport,Capital(CTITULO),cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport ), oReport:CancelPrint(), .T. ) }, CDESC ) 
oReport:ParamReadOnly()
oReport:Setlandscape(.F.)//Pag Horizontal

//Habilita los parametros de personalizacion para  la modificaciones de las secciones
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport al que pertenece                                 �
//�ExpC2 : Descripcion de la seccion                                       �
//�ExpA3 : Array con las tablas utilizadas por la seccion. La primera tabla�
//�        sera considerada como principal para la seccion.                �
//�ExpA4 : Array con los orders de la seccion                              �
//�ExpL5 : Tomara campos de SX3                                            �
//�        Default : False                                                 �
//�ExpL6 : Tomara ordens de Sindex                                         �
//�        Default : False                                                 �
//��������������������������������������������������������������������������
oSection1  := TRSection():New( oReport, STR0014, {"cArqTmp","CT1"},, .F., .F.,,,,,,,,,0 ) //"Plano de contas"

TRCell():New( oSection1, "CONTA"	,,STR0015			,/*Picture*/, nTamConta+10	, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,	, /*"LEFT"*/,,,.F.)	// CTA
TRCell():New( oSection1, "DESCCTA"  ,,STR0016			,/*Picture*/, aTamDesc[1]	, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,.T.,/*"LEFT"*/,,,.F.)	// DESCRIPCION
TRCell():New( oSection1, "SALDOANT" ,,STR0017			,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// SALDO ANTERIOR
TRCell():New( oSection1, "SALDOANC" ,,STR0017+cMoneda,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// SALDO ANTERIOR 02
TRCell():New( oSection1, "SALDODEB" ,,iif(lIsRussia,STR0028,STR0030)			,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// CARGO/DEBITO
TRCell():New( oSection1, "SALDODEC" ,,iif(lIsRussia,STR0028+' ',STR0030)+cMoneda,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// CARGO/DEBITO 02
TRCell():New( oSection1, "SALDOCRD" ,,iif(lIsRussia,STR0029,STR0031)			,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// ABONO/CREDITO
TRCell():New( oSection1, "SALDOCRC" ,,iif(lIsRussia,STR0029+' ',STR0031)+cMoneda,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// ABONO/CREDITO 02
TRCell():New( oSection1, "SALDOATU" ,,STR0020			,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// SALDO ACTUAL
TRCell():New( oSection1, "SALDOATC" ,,STR0020+cMoneda,/*Picture*/, TAM_VALOR+2	, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,	,"RIGHT",,,.F.)		// SALDO ACTUAL 02

TRPosition():New( oSection1, "CT1", 1, {|| xFilial( "CT1" ) + cArqTMP->CONTA })

oSection1:Cell("CONTA"):lHeaderSize	:= .F.
oSection1:Cell("DESCCTA"):lHeaderSize	:= .F. 
oSection1:Cell("SALDOANT"):lHeaderSize	:= .F.
oSection1:Cell("SALDOANC"):lHeaderSize	:= .F.
oSection1:Cell("SALDODEB"):lHeaderSize	:= .F.
oSection1:Cell("SALDODEC"):lHeaderSize	:= .F.
oSection1:Cell("SALDOCRD"):lHeaderSize	:= .F.
oSection1:Cell("SALDOCRC"):lHeaderSize	:= .F.
oSection1:Cell("SALDOATU"):lHeaderSize	:= .F.  
oSection1:Cell("SALDOATC"):lHeaderSize	:= .F.


oSection1:SetTotalInLine(.F.)          
oSection1:SetTotalText('')
oSection1:SetEdit(.F.)

Return( oReport )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Jonathan Gonzalez    � Data � 04.03.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime el reporte definido de acuerdo a las                ���
���          �especificaciones de la Funcion ReportDef() y los parametros ���
���          �del grupo de preguntas.                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto Reporte                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint( oReport )  

Local oSection1 	:= oReport:Section(1) 
Local lExterno		:= .F.   
Local aSetOfBook
Local dDataFim 	:= mv_par02
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lRet			:= .T.
Local lPrintZero	:= (mv_par18==1)
Local lPula		:= (mv_par17==1) 
Local lNormal		:= (mv_par19==1)
Local lVlrZerado	:= (mv_par07==1)
Local lQbGrupo		:= (mv_par11==1) 
Local lQbConta		:= (mv_par11==2)
Local l132			:= .T.
Local nDecimais
Local nDivide		:= 1
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0                     
Local cSegAte   	:= mv_par21
Local nDigitAte	:= 0
Local lImpAntLP	:= (mv_par22 == 1)
Local dDataLP		:= mv_par23
Local lImpSint		:= Iif(mv_par05=1 .Or. mv_par05 ==3,.T.,.F.)
Local lRecDesp0	:= (mv_par25 == 1)
Local cRecDesp		:= mv_par26
Local dDtZeraRD	:= mv_par27
Local n
Local oMeter
Local oText
Local oDlg
Local oBreak
Local lImpPaisgm	:= .F.	
Local nMaxLin   	:= mv_par28
Local cMoedaDsc	:= mv_par08
Local aCtbMoeda	:= {}
Local aCtbMoedadsc:= {}
Local CCOLBAR		:= "|"                   
Local cTipoAnt		:= ""
Local cGrupoAnt	:= ""
Local cArqTmp		:= ""
Local Tamanho		:= "M"
Local cSeparador	:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local oTotGerDeb		
Local oTotGerCrd
Local oTotGerDec		
Local oTotGerCrc
Local oTotGrpDeb
Local oTotGrpDec
Local oTotGrpCrd
Local oTotGrpCrc
Local cPicture
Local cContaSint
Local cBreak		:= "2"
Local cGrupo		:= ""
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nCont		:= 0
Local cFilUser		:= ""
Local nMasc		:= 0
Local cMasc		:= ""  
Local lEnd
Local cFilCTP 		:= xfilial("CTP")
Local lColDbCr 		:= If(cPaisLoc $ "RUS",.T.,.F.) // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Local nTaxa

Private cTipoMoneda	:= "01"
Private nLinReport	:= 9   
  
n_pagini	:= MV_PAR09

If oReport:nDevice == 5 .OR. oReport:nDevice == 3 
	oSection1:Cell("SALDOANT"):SetAlign("RIGHT")
	oSection1:Cell("SALDOANC"):SetAlign("RIGHT") 	  
	oSection1:Cell("SALDODEB"):SetAlign("RIGHT")
	oSection1:Cell("SALDODEC"):SetAlign("RIGHT")	
	oSection1:Cell("SALDOCRD"):SetAlign("RIGHT")
	oSection1:Cell("SALDOCRC"):SetAlign("RIGHT")	
	oSection1:Cell("SALDOATU"):SetAlign("RIGHT")
	oSection1:Cell("SALDOATC"):SetAlign("RIGHT")         
Endif 

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//Valida que la moneda sea diferente de "01" y que no se a nula
If lRet

	If EMPTY(mv_par08) 
	
		cMensagem	:= STR0023	//"el campo de Comparar con moneda es requerido"
		MsgAlert(cMensagem,STR0022)
		lRet    	:= .F.	
	    Return lRet
	    
	elseif mv_par08 == "01"
	
		cMensagem	:= STR0024	//"Se va a comparar con el mismo tipo de moneda, seleccionar otra."
		MsgAlert(cMensagem,STR0022)
		lRet    	:= .F.	
	    Return lRet   
	
    EndIf

EndIf



DbSelectArea("CTP") 
CTP->(DbSetOrder(2))

If lRet
	If CTP->(DbSeek(cFilCTP + MV_PAR08 + DTOS(MV_PAR16)))
		nTaxa := CTP_TAXA
	else
		MsgAlert(STR0027,STR0021) // "No se encontro tipo de cambio" , //moneda
		lRet    	:= .F.	
	    Return lRet
    EndIf
  CTP->(DbCloseArea())
EndIf
If nTaxa == 0
	nTaxa := 1
Endif
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


//��������������������������������������������������������������Ŀ
//� Verifica si usa Set Of Books + Plano Gerencial (Si usa Plano �
//� Gerencial -> carga las especificaciones para la impresion)   �
//����������������������������������������������������������������
If ! ct301Valid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf(mv_par06)
Endif

If mv_par20 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par20 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par20 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	     

If lRet
	aCtbMoeda := CtbMoeda( mv_par08 , nDivide )

	If Empty(aCtbMoeda[1])                       
		Help(" ",1,"NOMOEDA")
		lRet := .F.
		Return lRet
	Endif

    // valida��o da descri��o da moeda
	if lRet .And. ! Empty( mv_par08 ) .and. mv_par08 <> nil
		aCtbMoedadsc := CtbMoeda( mv_par08 , nDivide )

		If Empty( aCtbMoedadsc[1] )                       
    		Help( " " , 1 , "NOMOEDA")
	        lRet := .F.
    	    Return lRet
	    Endif
	Endif
Endif

If lRet
	If (mv_par25 == 1) .and. ( Empty(mv_par26) .or. Empty(mv_par27) )
		cMensagem	:= STR0012	//"Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= STR0013	//"Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,STR0021)	 //"Ignora Sl Ant.Rec/Des"
		lRet    	:= .F.	
	    Return lRet
    EndIf
EndIf

//aqui
aCtbMoeda  	:= CtbMoeda(mv_par08,nDivide)                

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,cTipoMoneda)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 		:= aSetOfBook[4]

lPrintZero	:= Iif(mv_par18==1,.T.,.F.)

If oReport:Title() == oReport:cRealTitle
	IF mv_par05 == 1
		Titulo:=	OemToAnsi(STR0007)	//"BALANCETE DE VERIFICACAO SINTETICO DE "
	ElseIf mv_par05 == 2
		Titulo:=	OemToAnsi(STR0004)	//"BALANCETE DE VERIFICACAO ANALITICO DE "
	ElseIf mv_par05 == 3
		Titulo:=	OemToAnsi(STR0010)	//"BALANCETE DE VERIFICACAO DE "
	EndIf
	
//"Balance Modelo 1 en dos monedas 99/99/9999 A 99/99/9999 COMPARATIVO EN CDESMOEDA. TIPO DE CAMBIO AL DIA 99/99/9999 DE "
	Titulo += 	DTOC(mv_par01) + OemToAnsi(STR0005) + Dtoc(mv_par02) + ;
			OemToAnsi(STR0006) + RTRIM(cDescMoeda) + CtbTitSaldo(mv_par10) + OemToAnsi (STR0025) + DTOC(MV_PAR16) + OemToAnsi (STR0026) + ALLTRIM(STR(nTaxa))
			   
Else
	Titulo := oReport:Title()
Endif

oReport:SetPageNumber( mv_par09 )
oReport:SetCustomText( {|| nCtCGCCabTR(dDataFim,titulo,oReport)})  


cFilUser := oSection1:GetAdvplExpr("CT1")
If !Empty(cFilUser)
	CT1->( dbSetFilter( { || &cFilUser }, cFilUser ) )
EndIf

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao			  		     �
//����������������������������������������������������������������
            


If lExterno  .or. IsBlind()
	CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,cTipoMoneda,;
				mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil) 
				
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,cTipoMoneda,;
					mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
					.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
					cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi(STR0009)),;  //"Criando Arquivo Tempor�rio..."
					OemToAnsi(STR0010))  				//"Balancete Verificacao"
EndIf                                                          
                
nCount := cArqTmp->(RecCount())

oReport:SetMeter(nCont)

lRet := !(nCount == 0 .And. !Empty(aSetOfBook[5]))

If lRet
	      
	// Verifica Se existe filtragem Ate o Segmento
  	If ! Empty( cSegAte )
		
		//Efetua tratamento da mascara para consegui efetuar o controle do segmento 
		For nMasc := 1 to Len( cMascara )
			
			cMasc += SubStr( cMascara,nMasc,1 )
			
		Next nMasc
	
	
		nDigitAte := CtbRelDig( cSegAte, cMasc ) 	

		oSection1:SetFilter( 'Len(Alltrim(cArqTmp->CONTA)) <= ' + alltrim( Str( nDigitAte )) )  
	EndIf	 

	cArqTmp->(dbGoTop())
	
	If lNormal
		oSection1:Cell("CONTA"):SetBlock( {|| EntidadeCTB(cArqTmp->CONTA,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.)} )
	Else
		oSection1:Cell("CONTA"):SetBlock( {|| cArqTmp->CTARES } )
	EndIf	
	
	oSection1:Cell("DESCCTA"):SetBlock( { || cArqTMp->DESCCTA } )
	If cTpValor != "P"	
	  	oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
	  	oSection1:Cell("SALDOANC"):SetBlock( { || ValorCTB(round(cArqTmp->SALDOANT/nTaxa,nDecimais),,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
	  	oSection1:Cell("SALDODEB"):SetBlock( { || ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
	  	oSection1:Cell("SALDODEC"):SetBlock( { || ValorCTB(round(cArqTmp->SALDODEB/nTaxa,nDecimais),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
	  	oSection1:Cell("SALDOCRD"):SetBlock( { || ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )
	  	oSection1:Cell("SALDOCRC"):SetBlock( { || ValorCTB(round(cArqTmp->SALDOCRD/nTaxa,nDecimais),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )
	    oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )	    
	    oSection1:Cell("SALDOATC"):SetBlock( { || ValorCTB(round(cArqTmp->SALDOATU/nTaxa,nDecimais),,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
	Else	
	  	oSection1:Cell("SALDOANT"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),TAM_VALOR) } )
	  	oSection1:Cell("SALDOANC"):SetBlock( { || PadL(ValorCTB(round(cArqTmp->SALDOANT/nTaxa,nDecimais),,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),TAM_VALOR) } )
	  	oSection1:Cell("SALDODEB"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) } )
	  	oSection1:Cell("SALDODEC"):SetBlock( { || PadL(ValorCTB(round(cArqTmp->SALDODEB/nTaxa,nDecimais),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) } )
	  	oSection1:Cell("SALDOCRD"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) } )
	  	oSection1:Cell("SALDOCRC"):SetBlock( { || PadL(ValorCTB(round(cArqTmp->SALDOCRD/nTaxa,nDecimais),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) } )
	    oSection1:Cell("SALDOATU"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),TAM_VALOR) } )
	    oSection1:Cell("SALDOATC"):SetBlock( { || PadL(ValorCTB(round(cArqTmp->SALDOATU/nTaxa,nDecimais),,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),TAM_VALOR) } )
	EndIf
	
	If lQbGrupo

		//*********************************
		// Total por Grupo do relatorio   *
		//*********************************
	
		oBrkGrupo := TRBreak():New(oSection1, { || cArqTmp->GRUPO },{|| STR0011+" "+ RTrim( Upper(AllTrim(cGrupo) )) + " )" },,,.T.)	//	"TOTALES DE GRUPO "
	  	oBrkGrupo:OnBreak( { |x| cGrupo := x, If(cArqTmp->(Eof()),oBrkGrupo:lPageBreak := .F.,.T.)} )
	
		oTotGrpDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDODEB) },.F.,.F.,.F.,oSection1)
		oTotGrpDeb:Disable()		

		oTotGrpDec := TRFunction():New(oSection1:Cell("SALDODEC"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,round(cArqTmp->SALDODEB/nTaxa,nDecimais)) },.F.,.F.,.F.,oSection1)
		oTotGrpDec:Disable()	
						
		oTotGrpCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDOCRD) },.F.,.F.,.F.,oSection1)
		oTotGrpCrd:Disable() 

		oTotGrpCrc := TRFunction():New(oSection1:Cell("SALDOCRC"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,round(cArqTmp->SALDOCRD/nTaxa,nDecimais)) },.F.,.F.,.F.,oSection1)
		oTotGrpCrc:Disable() 
				
		If cTpValor != "P"	
			TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection1 )
				
			TRFunction():New(oSection1:Cell("SALDODEC"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpDec:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection1 )
	
			TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection1 )

			TRFunction():New(oSection1:Cell("SALDOCRC"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpCrc:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection1 )
		Else
			TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) },.F.,.F.,.F.,oSection1 )

			TRFunction():New(oSection1:Cell("SALDODEC"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpDec:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) },.F.,.F.,.F.,oSection1 )
									
			TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) },.F.,.F.,.F.,oSection1 )		

			TRFunction():New(oSection1:Cell("SALDOCRC"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpCrc:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) },.F.,.F.,.F.,oSection1 )
		EndIf
	EndIf

	//******************************
	// Total Geral do relatorio    *
	//******************************
	oBrkGeral := TRBreak():New(oSection1, { || cArqTmp->(!Eof()) },{|| STR0008 },,,.F.)	//	" TOTALES DE PERIODO"

	// Totaliza
	oTotGerDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDODEB) },.F.,.F.,.F.,oSection1)
   	oTotGerDeb:Disable()

	oTotGerDec := TRFunction():New(oSection1:Cell("SALDODEC"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,round(cArqTmp->SALDODEB/nTaxa,nDecimais)) },.F.,.F.,.F.,oSection1)
   	oTotGerDec:Disable()
   	
   	
	oTotGerCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDOCRD) },.F.,.F.,.F.,oSection1)
   	oTotGerCrd:Disable()     

	oTotGerCrc := TRFunction():New(oSection1:Cell("SALDOCRC"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,round(cArqTmp->SALDOCRD/nTaxa,nDecimais)) },.F.,.F.,.F.,oSection1)
   	oTotGerCrc:Disable()     
   	                    
	If cTpValor != "P"	
	    TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || ValorCTB(oTotGerDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection1)

	    TRFunction():New(oSection1:Cell("SALDODEC"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || ValorCTB(oTotGerDec:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection1)
	  				                    		
	 	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || ValorCTB(oTotGerCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr)},.F.,.F.,.F.,oSection1) 

	 	TRFunction():New(oSection1:Cell("SALDOCRC"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || ValorCTB(oTotGerCrc:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr)},.F.,.F.,.F.,oSection1) 
	 		
	Else	 		
	    TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || PadL(ValorCTB(oTotGerDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) },.F.,.F.,.F.,oSection1)

	    TRFunction():New(oSection1:Cell("SALDODEC"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || PadL(ValorCTB(oTotGerDec:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR) },.F.,.F.,.F.,oSection1)
	  				                    		
	 	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || PadL(ValorCTB(oTotGerCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR)},.F.,.F.,.F.,oSection1) 

	 	TRFunction():New(oSection1:Cell("SALDOCRC"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || PadL(ValorCTB(oTotGerCrc:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR)},.F.,.F.,.F.,oSection1)
	 		 
	EndIf

	oSection1:OnPrintLine( {|| 	CTR301OnPrint( lPula, lQbConta, nMaxLin, @cTipoAnt, @nLinReport, @cGrupoAnt ) } )
           
	oSection1:Print()

	If mv_par24 ==1     
	    oReport:Section(1):SetHeaderSection(.F.)                                                       
		ImpQuadro(Tamanho,X3USO("CT2_DCD"),dDataFim,cTipoMoneda,aQuadro,cDescMoeda,oReport:ClassName(),(If (lImpAntLP,dDataLP,cTod(""))),cPicture,nDecimais,lPrintZero,mv_par10,oReport)
	EndIf	

EndIf     

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return .T.

  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTR301OnPrint �Autor � Jonathan Gonzalez� Data � 04.03.14   ���
�������������������������������������������������������������������������͹��
���Descricao � Executa acoes especificadas nos parametros do relatorio,   ���
���          � antes de imprimir cada linha.                              ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indicar si va saltar lineas entre cuenta sintetica ���
���          � EXPL2 - Indica  si va a terminar la pagina por cuenta      ���
���          � EXPN3 - Indica el total de lineas por pagina del balance   ���
���          � EXPC4 - Guardar o tipo da conta impressa (sint./analitica) ���
���          � EXPN5 - Guarda la linea actual del reporte para la         ���
���          �         cvalidacion con un valor del parametro EXPN3       ���
�������������������������������������������������������������������������͹��
���Retorno   � EXPL1 - Indica si se va a imprimir en linea (.T.)          ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidad Gerencial                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTR301OnPrint( lPula, lQbConta, nMaxLin, cTipoAnt, nLinReport )
                                                                        
Local lRet := .T.           

// Verifica salto de linha para conta sintetica (mv_par17)
If lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2"))
	oReport:SkipLine()
EndIf	

// Verifica quebra de pagina por conta (mv_par11)
If lQbConta .And. cArqTmp->NIVEL1
	oReport:EndPage()
	nLinReport := 9
	Return
EndIf	

// Verifica numero maximo de linhas por pagina (mv_par28)
If ! Empty(nMaxLin)
	CTR301MaxL(nMaxLin,@nLinReport)
EndIf	

cTipoAnt := cArqTmp->TIPOCONTA

If mv_par05 == 1		// Apenas sinteticas
	lRet := (cArqTmp->TIPOCONTA == "1")
ElseIf mv_par05 == 2	// Apenas analiticas
	lRet := (cArqTmp->TIPOCONTA == "2")
EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Ct301Valid� Autor � Jonathan Gonzalez     � Data � 04.03.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Preguntas                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ct301Valid(cSetOfBook)                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T./.F.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Config. reporte                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ct301Valid(cSetOfBook)

Local aSaveArea:= GetArea()
Local lRet		:= .T.	

If !Empty(cSetOfBook)
	dbSelectArea("CTN")
	dbSetOrder(1)
	If !dbSeek(xfilial()+cSetOfBook)
		aSetOfBook := ("","",0,"","")
		Help(" ",1,"NOSETOF")
		lRet := .F.
	EndIf
EndIf
	
RestArea(aSaveArea)

Return lRet


/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �CTR301MAXL� Autor � Jonathan Gonzalez       � Data �  04.03.14  ���
�����������������������������������������������������������������������������͹��
���Desc.     � Basado en el parametro MV_PAR28 (Numero de lineas del Balance),���
���          � cuyo contenido esta en la variable "nMaxLin", controla el final���
���          � de la pagina de TReport                                        ���
�����������������������������������������������������������������������������͹��
���Uso       � AP                                                             ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Static Function CTR301MaxL(nMaxLin,nLinReport)

nLinReport++

If nLinReport > nMaxLin
	oReport:EndPage()
	nLinReport := 10
EndIf

Return Nil

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � nCtCGCCabTR  � Autor � Jonathan Gonzalez       � Data � 04.03.14���
������������������������������������������������������������������������������͹��
���Desc.     � Reinicia el contador de lineas para el contro del reporte.      ���
������������������������������������������������������������������������������͹��
���Uso       � AP                                                              ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
STATIC FUNCTION nCtCGCCabTR(dDataFim,titulo,oReport)

nLinReport := 10                                  
oReport:SetPageNumber(n_pagini)
oReport:OnPageBreak({|| n_pagini += 1})                                                    
nLinReport := 10

RETURN CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport)
