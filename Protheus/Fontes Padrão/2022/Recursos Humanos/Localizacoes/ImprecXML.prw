#INCLUDE "IMPRECXML.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#IFNDEF CRLF
#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF 
Static oTmpSRVPD 
Static oTmpSRCIN 
Static oTmpSRCEX

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPRECXML� Autor � Laura Medina               � Data � 23/12/13 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Imprsion de Recibos para Mexico en XML.                         ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � IMPRECXML(void)                                                 ���
������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                 ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                        ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS/FNC  �  Motivo da Alteracao                     ���
������������������������������������������������������������������������������Ĵ��
���Laura Medina�06/02/14�TIGCQI     |Se modifico psra que acepte percepciones/ ���
���            �        �           |Deducciones negativas.                    ���  
���Laura Medina�17/02/14�           �Se modifico el tamano de la tabla temporal���
���            �        �           �para los campos numericos (RC_VALOR).     ���
���            �04/02/14�           �Se modifico la validacion de las percep-  ���
���            �        �           �ciones/deducciones para que acepte valores���
���            �        �           �negativos.                                ���  
���            �05/02/14�           �Se agrego un parametro pare enviar a Tim- ���
���            �        �           �brar o solo imprimir los recibos y se agre���
���            �        �           �garon otros campos a la imprecion del     ���
���            �        �           �recibo (existe en el XML).                ���  
���            �17/02/14�           �* Se agregara la funcionalidad para que se���
���            �        �           �  generen los recibos de SRD.             ���
���Laura Medina�05/02/14�TIFUKF     �Se agrego un parametro pare enviar a Tim- ���
���            �        �           �brar o solo imprimir los recibos y se agre���
���            �        �           �garon otros campos a la imprecion del     ���
���            �        �           �recibo (existe en el XML).                ���  
���            �        �           �* Se agregara la funcionalidad para que se���
���            �        �           �  generen los recibos de SRD.             ���
���            �        �           �* Se quito la pregunta -Dias Pag?- y se a-���
���            �        �           �  gregaron 2 parametros (MV_CFDI_DT y MV_ ���
���            �        �           �  CFDI_PG) para generar historico en base ���
���            �        �           �  a estos conceptos antes del 31/03/2014  ��� 
���            �28/02/14�           �* Se quito el parametro MV_ENVTIMB y se a-���
���            �        �           �  grego la funcionalidad por pregunta.    ���
���L Samaniego �18/03/14�TPAQDP     �Se corrigio un detalle en el query para   ���
���            �        �           �que no marque error cuando el DBMS es Ora-���
���            �        �           �cle y se quito una funcion para crear las ���
���            �        �           �preguntas.                                ���
���            �        �           �Se corrigio un error al momento de generar���
���            �        �           �el recibo periodo cerrado con incapacidad.���
���L Samaniego �28/04/14�TPJTSG     �Se realizan cambios para mejorar el       ��� 
���            �        �           �performance                               ���
���L Samaniego �06/05/14�TPLOPZ     �Se modifica para mostrar barra de avance  ��� 
���            �        �           �en el proceso de timbrado                 ���
���L Samaniego �26/05/14�TPRPOZ     �Version especial para TOTVS en el envio de���
���            �        �           �correo                                    ��� 
���Laura Medina�23/07/14�TPZVW6     �Se corrigio la funcion de Envio de correo ���
���            �        �           �para que cuando el parametro autenticacion���
���            �        �           �(MV_RELAUTH) sea falso, el archivo (Recibo���
���            �        �           �vaya adjunto y no como mensaje de correo. ���  
���LuisEnr�quez�01/02/17�SERINN001  �-Se realiza merge de SERINN001-796 -Se ha-��� 
���            �        �-854       � ce modificaci�n en creaci�n de tablas    ���
���            �        �           � temp. se utiliza clase FWTemporary- Table��� 
���            �        �           � en lugar de funci�n CriaTrab.            ��� 
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/  
Function IMPRECXML(lTerminal,cFilTerminal,cMatTerminal,cMesAnoRef,nRecTipo,cSemanaTerminal)
	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Locais (Basicas)                            �
	����������������������������������������������������������������*/
	Local cString:="SRA"        // alias do arquivo principal (Base)
	Local aOrd   := {STR0001, STR0003, STR0004, STR0002 + " + " + STR0001, STR0002 + " + " + STR0003, STR0128 + " + " + STR0001, STR0128 + " + " + STR0003} //"Matricula"###"Nome"###"Chapa"###"C.Custo + Mat."###"C.Custo + Nome"###Departamento + Mat."###"Departamento + Nome"
	Local cDesc1 := STR0006		//"Emiss�o de Recibos de Pagamento."
	Local cDesc2 := STR0007		//"Devido a tilizac�o de caracteres de compress�o,  e necessario que na impress�o"
	Local cDesc3 := STR0008		//" em formulario seja selecionado, no Tipo de Impress�o, a opc�o 'Direta na Porta'. "
	Local aDriver:= ReadDriver()

	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Locais (Programa)                           �
	����������������������������������������������������������������*/
	Local cIndCond
	Local Baseaux 	:= "S"
	Local cHtml 	:= ""
	Local cMes		:= ""
	Local cAno		:= ""      
	Local lImpCDFi  := ExistBlock("IMPRCFDI")
	Local nItem     := 0
	Local cArchivos := ""
	Local lTimbrado := .F.

	/*
	��������������������������������������������������������������Ŀ
	� Define o numero da linha de impress�o como 0                 �
	����������������������������������������������������������������*/
	SetPrc(0,0)

	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Private(Basicas)                            �
	����������������������������������������������������������������*/
	Private aReturn  := {STR0009, 1, STR0010, 2, 2, 1, "", 1}	//"Zebrado"###"Administra��o"
	Private nomeprog := "IMPRECXML"
	Private aLinha   := { }
	Private nLastKey := 0
	Private cPerg    := "IMPRECXML"
	Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe

	Private cCompac := aDriver[1]
	Private cNormal := aDriver[2]

	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Private(Programa)                           �
	����������������������������������������������������������������*/
	Private aLanca 		:= {}
	Private aProve 		:= {}
	Private aDesco 		:= {}
	Private aBases 		:= {}
	Private aInfo  		:= {}
	Private aCodFol		:= {}
	Private li     		:= _PROW()
	Private Titulo 		:= STR0011		//"EMISS�O DE RECIBOS DE PAGAMENTOS"
	Private lEnvioOk 	:= .F.
	Private lRetCanc	:= .t.
	Private cIRefSem    := GetMv("MV_IREFSEM",,"S")
	Private aPerAberto	:= {}
	Private aPerFechado	:= {}
	Private aPerSelec   := {} // Periodo Seleccionado (Abierto/Cerrado)
	Private cProcesso	:= "" // Armazena o processo selecionado na Pergunte GPR040 (MV_PAR01).
	Private cRoteiro	:= "" // Armazena o Roteiro selecionado na Pergunte GPR040 (MV_PAR02).
	Private cPeriodo	:= "" // Armazena o Periodo selecionado na Pergunte GPR040 (MV_PAR03).
	Private cCcto		:= ""
	Private cCond		:= ""
	Private cRot		:= ""
	Private cDescProc    
	Private cConcpDPg   := "" //CFDi   
	Private nImpReten   := 0   
	Private aTmpArea    := {}     
	Private lGenXML     := .F.
	private lEnvTimb    := .F. //GetMv("MV_ENVTIMB",,.F.)   //.T. Indica si se envia a Timbrar - .F. Solo imprime (XML) sin timbrar
	Private lEsPerAb    := .T.
	Private lExistReg   := .F. 
	//Private cCodBarQR		:= "codbar_cdf"
	Private aVlrPerDed  := {0,0,0,0}
	Private aArchivos   := {} 

	// Nova ordem de impressao para o Mexico - Local de Pago
	If cPaisLoc == "MEX"
		aAdd(aOrd, STR0126)
		//AjustaSX1()
	Endif

	/*
	��������������������������������������������������������������Ŀ
	� Envia controle para a funcao SETPRINT                        �
	����������������������������������������������������������������*/
	wnrel:="IMPRECXML"            //Nome Default do relatorio em Disco

	/*
	��������������������������������������������������������������Ŀ
	� Verifica se o programa foi chamado do terminal - TCF         �
	����������������������������������������������������������������*/
	lTerminal := If( lTerminal == Nil, .F., lTerminal )

	/*
	��������������������������������������������������������������Ŀ
	� Verifica as perguntas selecionadas                           �
	����������������������������������������������������������������*/
	Pergunte("IMPREC",.F.)	

	If Pergunte(cPerg , .T. )

















































































		/*
		��������������������������������������������������������������Ŀ
		� Define a Ordem do Relatorio                                  �
		����������������������������������������������������������������*/
		nOrdem := IF( !( lTerminal ), aReturn[8] , 1 )











		/*
		��������������������������������������������������������������Ŀ

		� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
		����������������������������������������������������������������*/









		cSemanaTerminal := IF( Empty( cSemanaTerminal ) , Space( Len( SRC->RC_SEMANA ) ) , cSemanaTerminal )
		cProcesso  := IF( !( lTerminal ), MV_PAR01 , cProcTerminal		)   //Processo
		cRoteiro   := IF( !( lTerminal ), MV_PAR02 , nRecTipo			)	//Emitir Recibos(Roteiro)
		cPeriodo   := IF( !( lTerminal ), MV_PAR03 , cPerTerminal		)   //Periodo
		Semana     := IF( !( lTerminal ), MV_PAR04 , cSemanaTerminal	)	//Numero da Semana

		//Carregar os periodos abertos (aPerAberto) e/ou 
		// os periodos fechados (aPerFechado), dependendo 
		// do periodo (ou intervalo de periodos) selecionado
		RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
		cRoteiro	,; // Roteiro selecionado na Pergunte.
		cPeriodo	,; // Periodo selecionado na Pergunte.
		Semana		,; // Numero de Pagamento selecionado na Pergunte.
		NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
		NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
		@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
		@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados

		//CFDi
		/*If  Empty(aPerAberto) //El periodo seleccionado esta cerrado y de periodos cerrados no se generan los recibos 
		Return ( IF( lTerminal , cHtml , NIL ) )	
		Endif */

		// Retorna o mes e o ano do periodo selecionado na pergunte.
		AnoMesPer(	cProcesso	,; // Processo selecionado na Pergunte.
		cRoteiro	,; // Roteiro selecionado na Pergunte.
		cPeriodo	,; // Periodo selecionado na Pergunte.
		@cMes		,; // Retorna o Mes do Processo + Roteiro + Periodo selecionado
		@cAno		 ) // Retorna o Ano do Processo + Roteiro + Periodo selecionado
		dDataRef := CTOD("01/" + cMes + "/" + cAno)

		nTipRel		:= IF( !( lTerminal ), MV_PAR05, 3					)	//Tipo de Recibo (Pre/Zebrado/EMail)
		cFilDe		:= IF( !( lTerminal ), MV_PAR06, cFilTerminal		)	//Filial De
		cFilAte		:= IF( !( lTerminal ), MV_PAR07, cFilTerminal		)	//Filial Ate
		cMatDe		:= IF( !( lTerminal ), MV_PAR08, cMatTerminal		)	//Matricula Des
		cMatAte		:= IF( !( lTerminal ), MV_PAR09, cMatTerminal		)	//Matricula Ate
		cNomDe		:= IF( !( lTerminal ), MV_PAR10, SRA->RA_NOME		)	//Nome De
		cNomAte		:= IF( !( lTerminal ), MV_PAR11, SRA->RA_NOME		)	//Nome Ate
		ChapaDe		:= IF( !( lTerminal ), MV_PAR12, SRA->RA_CHAPA 	)	//Chapa De
		ChapaAte	:= IF( !( lTerminal ), MV_PAR13, SRA->RA_CHAPA 	)	//Chapa Ate
		cCcDe		:= IF( !( lTerminal ), MV_PAR14, SRA->RA_CC		)	//Centro de Custo De
		cCcAte		:= IF( !( lTerminal ), MV_PAR15, SRA->RA_CC		)	//Centro de Custo Ate
		cDeptoDe	:= IF( !( lTerminal ), MV_PAR16, SRA->RA_DEPTO		)	//Centro de Custo De
		cDeptoAte	:= IF( !( lTerminal ), MV_PAR17, SRA->RA_DEPTO		)	//Centro de Custo Ate
		cSituacao	:= IF( !( lTerminal ), MV_PAR18, fSituacao(NIL, .F.))	//Situacoes a Imprimir
		cCategoria	:= IF( !( lTerminal ), MV_PAR19, fCategoria(NIL, .F.))	//Categorias a Imprimir
		Mensag1		:= MV_PAR20										 		//Mensagem 1
		Mensag2		:= MV_PAR21												//Mensagem 2
		Mensag3		:= MV_PAR22												//Mensagem 3	
		//cMensRec	:= AllTrim( fPosTab( "S018", MV_PAR23, "=", 4,,,,5) )

		If cPaisLoc == "MEX"
			cLocalDe    := MV_PAR24		//De Local Pago
			cLocalAte   := MV_PAR25		//A Local Pago
			nSumaVerba	:= If( !(lTerminal), MV_PAR26, 1 )					//1 - Sumariza verbas 2 - N�o sumariza			
		Endif

		lEnvTimb   := Iif(MV_PAR27==1,.T.,.F.)
		cBaseAux   := "N"									   				//Imprimir BaseS

		If RCJ->RCJ_CODIGO <> cProcesso	
			DbSelectArea( "RCJ" )
			DbSetOrder( 1 )  // RCJ_FILIAL + RCJ_CODIGO
			DbSeek( xFilial( "RCJ" ) + cProcesso, .F. )
		EndIf

		cDescProc := IIf(RCJ->(EOF()), Space(15), SubStr( RCJ->RCJ_DESCRI, 1, 30))



		If aReturn[5] == 1 .and. nTipRel == 1
			li	:=  0
		EndIf

		IF !( lTerminal )

			cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)

		EndIF
















		If  Posicione("RCH",1,XFILIAL("RCH")+cProcesso+cPeriodo+Semana+cRoteiro,"RCH_STATUS") == "6" .And. lEnvTimb   //Timbrados
			APMSGINFO(STR0132) //"No es posible timbrar este proceso, ya fueron timbrado."
			Return( IF( lTerminal , cHtml , NIL ) )
		Endif        

		DbSelectArea( "SRA" )
		IF  nTipRel==3
			IF lTerminal
				cHtml := R030Imp(.F.,wnRel,cString,cMesAnoRef,lTerminal)
			Else
				ProcGPE({|lEnd| R030IMP(@lEnd,wnRel,cString,cMesAnoRef,.f.)},,,.T.)  // Chamada do Processamento
			EndIF
		Else
			RptStatus({|lEnd| R030Imp(@lEnd,wnRel,cString,cMesAnoRef,.f.)},Titulo)  // Chamada do Relatorio
		EndIF  

		If  lGenXML   
			If lEnvTimb   //Depende del parametro
				Processa({|| lTimbrado:= TimbreRecNom()}) //Sinigica que pudo generar los timbres y debe actualizarse el estatus
				If lTimbrado
					//Impresion de los recibos ya Timbrados    
					If  lImpCDFi  //Existe PE
						Execblock("IMPRCFDI",.f.,.f.,)
					Else
						ImpRXML() 
					Endif
					dbselectarea("RCH")
					If RCH->(dbseek(XFILIAL("RCH")+cProcesso+cPeriodo+Semana+cRoteiro)) 
						Reclock("RCH",.F.)    
						RCH->RCH_STATUS := "6"  //Recibos Timbrados
						Msunlock()
					Endif

				Endif
			Else
				If  lImpCDFi
					Execblock("IMPRCFDI",.f.,.f.,)
				Else  
					ImpRXML() 
				Endif 
			EndIf      
		Else
			If  lImpCDFi
				Execblock("IMPRCFDI",.f.,.f.,)
			Else  
				ImpRXML() 
			Endif
		Endif    
	Endif	//Pergunte

	cArchivos := Alltrim(MV_PAR01) + Alltrim(MV_PAR02) + Alltrim(MV_PAR03) + Alltrim(MV_PAR04)

	For nItem := 1 To Len(aArchivos)
		//Elimina imagenes del SmartClient
		Iif( File( GetClientDir() + aArchivos[nItem,1] + ".jpg" ), FErase( GetClientDir() + aArchivos[nItem,1] + ".jpg" ), "" ) 
		Iif( File( GetClientDir() + aArchivos[nItem,1] + ".bmp" ), FErase( GetClientDir() + aArchivos[nItem,1] + ".bmp" ), "" )
		//Elimina imagenes del servidor (System)
		Iif( File( Curdir() + aArchivos[nItem,1] + ".jpg" ), FErase( Curdir() + aArchivos[nItem,1] + ".jpg" ), "" )
		Iif( File( Curdir() + aArchivos[nItem,1] + ".bmp" ), FErase( Curdir() + aArchivos[nItem,1] + ".bmp" ), "" ) 
	Next
	//Elimana archivo timbradocfdi_xxxxxx.ini
	Iif( File( GetClientDir() + "timbradocfdi_" + cArchivos + ".ini" ), FErase( GetClientDir() + "timbradocfdi_" + cArchivos + ".ini" ), "" ) 
	//Elimina archivo timbrado_xxxxxx.bat
	Iif( File( GetClientDir() + "timbrado_" + cArchivos + ".bat" ), FErase( GetClientDir() + "timbrado_" + cArchivos + ".bat" ), "" )
	//Elimina archivo codbarqr_xxxxxx.txt
	Iif( File( GetClientDir() + "codbarqr_" + cArchivos + ".txt" ), FErase( GetClientDir() + "codbarqr_" + cArchivos + ".txt" ), "" )

Return( IF( lTerminal , cHtml , NIL ) )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R030IMP  � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento Para emissao do Recibo                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)
	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Locais (Basicas)                            �
	����������������������������������������������������������������*/
	Local aCodBenef		:= {} 
	Local cAcessaSR1	:= &("{ || " + ChkRH("IMPRECXML","SR1","2") + "}")
	Local cAcessaSRA	:= &("{ || " + ChkRH("IMPRECXML","SRA","2") + "}")
	Local cAcessaSRC	:= &("{ || " + ChkRH("IMPRECXML","SRC","2") + "}")
	Local cAcessaSRD	:= &("{ || " + ChkRH("IMPRECXML","SRD","2") + "}")	
	Local cNroHoras   	:= &("{ || If(aVerbasFunc[nReg,05] > 0 .And. cIRefSem == 'S', aVerbasFunc[nReg,05], aVerbasFunc[nReg,6]) }")
	Local cHtml		  	:= ""
	Local nHoras      	:= 0
	Local nMes, nAno
	Local nX
	Local nReg		  	:= 0
	Local cPerAnt	  	:= ""                    
	Local aVerbasFunc	:= {}
	Local aVerbasFilter	:= {}
	Local cFilSRV		:= xFilial("SRV")
	Local dDataLibRh
	Local cMesCorrente	:= getmv("MV_FOLMES")
	Local nTcfDadt		:= If(lTerminal,getmv("MV_TCFDADT",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF 
	Local nTcfDfol		:= If(lTerminal,getmv("MV_TCFDFOL",,0),0)		// indica a quantidade de dias a somar ou diminuir no ultimo dia do mes corrente para liberar a consulta do TCF
	Local nTcfD131		:= If(lTerminal,getmv("MV_TCFD131",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nTcfD132		:= If(lTerminal,getmv("MV_TCFD132",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nTcfDext		:= If(lTerminal,getmv("MV_TCFDEXT",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nContFun:=0  
	Local cTotVencImp   := 0      
	Local lGenero       := .F.
	Local cArchNom := ""
	Local cDirArch := &(SuperGetmv( "MV_CFDRECN" , .F. , "'cfd\recibos\'" ))

	Private tamanho     :=	"M"
	Private limite		:=	132
	Private cDtPago     :=	""
	Private cPict1		:=	"@E 999,999,999.99"
	Private cPict2 		:=	"@E 99,999,999.99"
	Private cPict3 		:=	"@E 999,999.99"
	Private cTipoRot 	:=	PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_TIPO")    
	Private nConsPer    := 0
	Private nConsDed    := 0

	If MsDecimais(1) == 0
		cPict1	:=	"@E 99,999,999,999"
		cPict2 	:=	"@E 9,999,999,999"
		cPict3 	:=	"@E 99,999,999"
	Endif

	// Ajuste do tipo da variavel
	nTcfDadt	:= if(valtype(ntcfdadt)=="C",val(ntcfdadt),ntcfdadt)
	nTcfD131	:= if(valtype(nTcfD131)=="C",val(nTcfD131),nTcfD131)
	nTcfD132	:= if(valtype(nTcfD132)=="C",val(nTcfD132),nTcfD132)
	nTcfDfol	:= if(valtype(ntcfdfol)=="C",val(ntcfdfol),ntcfdfol)
	nTcfDext	:= if(valtype(ntcfdext)=="C",val(ntcfdext),ntcfdext)

	/*
	��������������������������������������������������������������Ŀ
	| Verifica se o Mes solicitado esta liberado para consulta no  |
	| terminal de consulta do funcionario.                         |
	����������������������������������������������������������������*/
	If lTerminal

		If !empty(cMesCorrente)
			cMesCorrente := substr(cMesCorrente,-2)+substr(cMesCorrente,1,4)
		endif

		If	cMesCorrente == cMesArqRef  .or. right(cMesCorrente,4)+left(cMesCorrente,2) == mesano(ddataref) .Or. ;
		mesano(ddataref) > substr(cMesCorrente,3,4)+substr(cMesCorrente,1,2) .Or.;		
		left(cMesArqRef,2) == "13"

			If  cTipoRot == "2" //Adiantamento
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFDADT,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				EndIf
			ElseIf cTipoRot == "1" .and. !empty(nTCFDFOL) //Folha
				dDataLibRh := fMontaDtTcf(cMesCorrente,nTCFDFOL)
				If date() < dDataLibRH 
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			ElseIf cTipoRot == "5" //1a parcela 13o Salario
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFD131,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			ElseIf cTipoRot == "6" //2a parcela 13o Salario
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFD132,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			ElseIf cRoteiro == "EXT"  // Valores Extras
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFDEXT,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			endif
		Endif
	Endif

	/*
	��������������������������������������������������������������Ŀ
	� Selecionando a Ordem de impressao escolhida no parametro.    �
	����������������������������������������������������������������*/

	dbSelectArea( "SRA")
	IF !( lTerminal )
		If nOrdem == 1
			dbSetOrder(1)	//RA_FILIAL+RA_MAT
		ElseIf nOrdem == 2
			dbSetOrder(3)	//RA_FILIAL+RA_NOME
		ElseIf nOrdem == 3
			cArqNtx  := CriaTrab(NIL,.f.)
			cIndCond :="RA_FILIAL+RA_CHAPA+RA_MAT"
			IndRegua("SRA",cArqNtx,cIndCond,,,STR0012)		//"Selecionando Registros..."
		Elseif nOrdem == 4
			dbSetOrder(2)	//RA_FILIAL+RA_CC+RA_MAT
		ElseIf nOrdem == 5
			dbSetOrder(8)	//RA_FILIAL+RA_CC+RA_NOME
		ElseIf nOrdem == 6
			dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_DEPTO+RA_MAT"))		
		ElseIf nOrdem == 7
			dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_DEPTO+RA_NOME"))				
		ElseIf nOrdem == 8
			dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_KEYLOC+RA_NOME"))	
		Endif

		dbGoTop()

		If nTipRel == 2
			@ LI,00 PSAY AvalImp(Limite)
		Endif
	Endif

	/*
	��������������������������������������������������������������Ŀ
	� Selecionando o Primeiro Registro e montando Filtro.          �
	����������������������������������������������������������������*/
	If nOrdem == 1 .or. lTerminal
		cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
		IF !( lTerminal )
			dbSeek(cFilDe + cMatDe,.T.)
			cFim    := cFilAte + cMatAte
		Else
			cFim    := &(cInicio)
		EndIF
	ElseIf nOrdem == 2
		dbSeek(cFilDe + cNomDe + cMatDe,.T.)
		cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
		cFim    := cFilAte + cNomAte + cMatAte
	ElseIf nOrdem == 3
		dbSeek(cFilDe + ChapaDe + cMatDe,.T.)
		cInicio := "SRA->RA_FILIAL + SRA->RA_CHAPA + SRA->RA_MAT"
		cFim    := cFilAte + ChapaAte + cMatAte
	ElseIf nOrdem == 4
		dbSeek(cFilDe + cCcDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
		cFim     := cFilAte + cCcAte + cMatAte	
	ElseIf nOrdem == 5
		dbSeek(cFilDe + cCcDe + cNomDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME"
		cFim     := cFilAte + cCcAte + cNomAte
	ElseIf nOrdem == 6
		dbSeek(cFilDe + cDeptoDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_DEPTO + SRA->RA_MAT"
		cFim     := cFilAte + cDeptoAte + cMatAte	
	ElseIf nOrdem == 7
		dbSeek(cFilDe + cDeptoDe + cNomDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_DEPTO + SRA->RA_NOME"
		cFim     := cFilAte + cDeptoAte + cNomAte
	ElseIf nOrdem == 8
		dbSeek(cFilDe + cLocalDe + cNomDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_KEYLOC + SRA->RA_NOME"
		cFim     := cFilAte + cLocalAte + cNomAte
	Endif

	/*
	��������������������������������������������������������������Ŀ
	� Carrega Regua Processamento                                  �
	����������������������������������������������������������������*/
	dbSelectArea("SRA")
	If nTipRel # 3
		SetRegua(RecCount())	// Total de elementos da regua
	Else
		If !( lTerminal )
			GPProcRegua(RecCount())// Total de elementos da regua
		EndIf
	EndIF

	TOTVENC:= TOTDESC:= FLAG:= CHAVE := 0

	dRCHDtIni := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), SRA->RA_FILIAL , "RCH_DTINI")
	dRCHDtFim := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), SRA->RA_FILIAL , "RCH_DTFIM")
	cFilialAnt := Space(FWGETTAMFILIAL)
	Vez        := 0
	OrdemZ     := 0

	If cPaisLoc == "MEX"
		SRV->(DBSetOrder(1))
		SRV->(DBSeek(cFilSRV))
		aVerbasFilter:= {}   			

		SRV->(DBEval( {|| IF(SRV->RV_IMPRIPD == "1" .AND. !EMPTY(SRV->RV_TIPSAT), AAdd(aVerbasFilter, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	EndIf

	If SRA->( !Eof() .And. &cInicio <= cFim )
		While SRA->( !Eof() .And. &cInicio <= cFim )
			aTmpArea  := {}  
			lGenero   := .F.
			nImpReten   := 0
			aVlrPerDed  := {0,0,0,0}

			//��������������������������������������������������������������//
			// Movimenta Regua Processamento                                //
			//��������������������������������������������������������������//
			If !( lTerminal )

				If nTipRel # 3
					IncRegua()  // Anda a regua
				ElseIf !( lTerminal )
					GPIncProc(SRA->RA_FILIAL + " - " + SRA->RA_MAT + " - " + SRA->RA_NOME)
				EndIf

				If lEnd
					@Prow()+1,0 PSAY cCancel
					Exit
				EndIf

				//��������������������������������������������������������������//
				// Consiste Parametrizacao do Intervalo de Impressao            //
				//��������������������������������������������������������������//
				If	(SRA->RA_CHAPA < ChapaDe)	.Or. (SRA->RA_CHAPA > ChapaAte)	.Or. ;
				(SRA->RA_NOME < cNomDe)		.Or. (SRA->RA_NOME > cNomAte)	.Or. ;
				(SRA->RA_MAT < cMatDe)		.Or. (SRA->RA_MAT > cMatAte)	.Or. ;
				(SRA->RA_CC < cCcDe)		.Or. (SRA->RA_CC > cCcAte)		.Or. ;
				(SRA->RA_DEPTO < cDeptoDe)	.Or. (SRA->RA_DEPTO > cDeptoAte) .Or. ;
				(SRA->RA_KEYLOC < cLocalDe) .Or. (SRA->RA_KEYLOC > cLocalAte)
					SRA->(dbSkip(1))
					Loop
				EndIf

			EndIf

			aLanca	:= {}         // Zera Lancamentos
			aProve	:= {}         // Zera Lancamentos
			aDesco	:= {}         // Zera Lancamentos
			aBases	:= {}         // Zera Lancamentos
			nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00		
			Ordem_rel := 1     // Ordem dos Recibos

			/*
			��������������������������������Ŀ
			� Verifica Data Demissao         �
			����������������������������������*/
			cSitFunc := SRA->RA_SITFOLH
			dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")

			If ( cPaisLoc # "MEX" ) // alterado Reginaldo
				If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
					cSitFunc := " "
				Endif 
			EndIf	

			IF !( lTerminal )			
				/*
				��������������������������������������������������������������Ŀ
				� Consiste situacao e categoria dos funcionarios			   |
				����������������������������������������������������������������*/	  	
				If !( cSitFunc $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria )
					dbSkip()
					Loop
				Endif 

				If ( cPaisLoc # "MEX" )  //alterado Reginaldo 			
					If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
						dbSkip()
						Loop
					EndIf	
				Endif

				/*
				��������������������������������������������������������������Ŀ
				� Consiste controle de acessos e filiais validas			   |
				����������������������������������������������������������������*/
				If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
					dbSkip()
					Loop
				EndIf

			EndIF

			If SRA->RA_FILIAL # cFilialAnt
				If !Fp_CodFol(@aCodFol, SRA->RA_FILIAL) .Or. !fInfo(@aInfo, SRA->RA_FILIAL)
					Exit
				Endif

				dbSelectArea("SRA")
				cFilialAnt := SRA->RA_FILIAL
			Endif

			If  !Empty(aPerAberto)  //Es periodo abierto
				aPerSelec := aPerAberto     
				lEsPerAb  := .T.
			Elseif !Empty(aPerFechado)  //Es periodo cerrado 
				aPerSelec := aPerFechado 
				lEsPerAb  := .F.   
			Endif    

			ObtRegSRC(9)   
			If  !lExistReg
				dbSkip()
				Loop 
			Endif

			cArchNom := Alltrim(MV_PAR01)+Alltrim(MV_PAR02)+Alltrim(MV_PAR03)+Alltrim(MV_PAR04)+"_"+SRA->RA_FILIAL+SRA->RA_MAT + ".xml"

			aAdd ( aArchivos, { Replace( cArchNom, ".xml", "" ) } )
			//Funcion para validar si ya existe el archivo XML y si existe se valida si esta TIMBRADO
			IF File(cDirArch + cArchNom)
				IF   ValidaRecibo( cDirArch + cArchNom )== 1    //Ya timbrado
					dbSkip()
					Loop
				EndIF
			EndIf

			Totvenc := Totdesc := 0
			nConsPer:= nConsDed := 0 

			//Retorna as verbas do funcionario, de acordo com os periodos selecionados
			aVerbasFunc	:= RetornaVerbasFunc(	SRA->RA_FILIAL					,; // Filial do funcionario corrente
			SRA->RA_MAT	  					,; // Matricula do funcionario corrente
			NIL								,; // 
			cRoteiro	  					,; // Roteiro selecionado na pergunte
			IIf(cPaisLoc == "MEX", aVerbasFilter, NIL)	,; //			  aVerbasFilter				 // Array com as verbas que dever�o ser listadas. Se NIL retorna todas as verbas.
			aPerAberto	  					,; // Array com os Periodos e Numero de pagamento abertos
			aPerFechado	 	 				 ) // Array com os Periodos e Numero de pagamento fechados

			If cRoteiro <> "EXT"
				If !Empty(aVerbasFunc)
					LocTrabs("SRVPD")  //Detalle percepciones y deducciones   
				Endif 
				For nReg := 1 to Len(aVerbasFunc)
					If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD))
						dbSkip()
						Loop
					EndIf

					If  PosSrv(aVerbasFunc[nReg,3], SRA->RA_FILIAL, "RV_IMPRIPD") == "1"    //1- Imprimir el concepto
						//Percepciones
						If  PosSrv( aVerbasFunc[nReg,3] , SRA->RA_FILIAL , "RV_TIPOCOD" ) $ "1|3"  .And.  (SRV->RV_IR= "1"  .OR. SRV->RV_IR= "2" .OR. SRV->RV_IR= "3" )  
							GravPerDed("1",SRV->RV_TIPSAT,aVerbasFunc[nReg,3],aVerbasFunc[nReg,7],SRV->RV_IR,nSumaVerba,Alltrim(SRV->RV_DESCDET))   //1-Deduccion,RV_TIPSAT,RV_PD,RC_VALOR,RV_IR
							TOTVENC += aVerbasFunc[nReg,7]
							If  SRV->RV_IR ='1'   //Percepcion Gravada
								aVlrPerDed[1] += aVerbasFunc[nReg][7]   
							Elseif SRV->RV_IR ='2' .Or. SRV->RV_IR ='3'  //Percepcion Exenta  
								aVlrPerDed[2] += aVerbasFunc[nReg][7] 
							Endif
							//Deducciones
						Elseif (SRV->RV_TIPOCOD == "2" .OR. SRV->RV_TIPOCOD == "4") .And.  (SRV->RV_IR= "1"  .OR. SRV->RV_IR= "2" .OR. SRV->RV_IR= "3" )
							GravPerDed("2",SRV->RV_TIPSAT,aVerbasFunc[nReg,3],aVerbasFunc[nReg,7],SRV->RV_IR,nSumaVerba,Alltrim(SRV->RV_DESCDET))   //2-Deduccion,RV_TIPSAT,RV_PD,RC_VALOR,RV_IR
							//fSomaPdRec("D",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7],nSumaVerba)
							TOTDESC += aVerbasFunc[nReg,7]
							If  SRV->RV_IR ='1'   //Deduccion Gravada
								aVlrPerDed[3] += aVerbasFunc[nReg][7]   
							Elseif SRV->RV_IR ='2' .Or. SRV->RV_IR ='3'  //Deduccion Exenta"  
								aVlrPerDed[4] += aVerbasFunc[nReg][7] 
							Endif  
						Endif
					Endif
				Next nReg
			Endif             

			dbSelectArea("SRA")

			//Temporalmente que imprima aunque no tenga percepciones y deducciones 
			If  Empty(aVerbasFunc)
				LocTrabs("SRVPD")  //Detalle percepciones y deducciones   
			Endif

			//Inserta registro ISR en 0 (solo si no existe al menos un registro)
			InsertISR()        

			//Generaci�n del archivo XML (CFDI): Imprimir solo si se genera el XML            
			lGenero := GpeaXML()    

			If !lGenXML .And. lGenero //Existe al menos un registro timbrado
				lGenXML := lGenero
			Endif

			dbSelectArea("SRA")
			SRA->( dbSkip() )
			TOTDESC := TOTVENC := 0

		EndDo
	Else	
		//If  Empty(aVerbasFunc)
		APMSGINFO("No se encontro informaci�n para generar los Recibos")
		//Endif
	Endif

	IF !( lTerminal ) 

		//��������������������������������������������������������������Ŀ
		//�  chamada da fun��o que imprime total de funcionarios e o total vencimentos impressos no final do relat�rio.     �
		//����������������������������������������������������������������
		If nContFun>0
			//FimprTotFun (nContFun,cTotVencImp)       
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Termino do relatorio                                         �
		//����������������������������������������������������������������
		dbSelectArea("SRC")
		dbSetOrder(1)          // Retorno a ordem 1
		dbSelectArea("SRD")
		dbSetOrder(1)          // Retorno a ordem 1
		dbSelectArea("SRA")
		SET FILTER TO
		RetIndex("SRA")

		If !(Type("cArqNtx") == "U")
			fErase(cArqNtx + OrdBagExt())
		Endif

		Set Device To Screen

		If lEnvioOK
			APMSGINFO(STR0042)
		ElseIf nTipRel== 3
			APMSGINFO(STR0043)
		EndIf
		SeTPgEject(.F.)
		nlin:= 0	
		If aReturn[5] = 1 .and. nTipRel # 3
			Set Printer To
			Commit
			//ourspool(wnrel)
		Endif
		MS_FLUSH()

	EndIF
Return cHtml


/*
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fMontaDtTcf 	�Autor�Ricardo Duarte     � Data �13/08/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna a data valida para a consulta do Terminal Consulta  �
�          �do Funcionario                                         		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Retorno   �cHtml  														�
�����������������������������������������������������������������������Ĵ
�Uso	   �GPER030       										    	�
�������������������������������������������������������������������������*/
Static Function fMontaDtTcf(cMesAno,nDia)
	Local dDataValida
	Default nDia := 0

	dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+"01")
	dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+strzero(f_UltDia(dDataValida),2))+nDia
Return dDataValida

/*                                                                                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtNomin � Autor � Laura Medina Prado    � Data � 10/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para obtener las deducciones y Percepciones del    ���
���          � empleado en proceso.                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtConcep()                                                ���
���          � Retorno:  cConceptos                                       ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GravPerDed(cTipoCon,cTipSAT,cPDSRV,nValorSRC,cIR,nSumaCon,cDESCDET)       
	Local nConsec   := 0

	Static lAglutPd  
	DEFAULT nSumaCon := 0

	If  nValorSRC <>0

		If  cTipoCon == "1"    //Percepcion 
			nConsPer++ 
			nConsec :=  nConsPer 
		Elseif cTipoCon == "2" //Deduccion 
			nConsDed++  
			nConsec :=  nConsDed 
		Endif

		If  lAglutPd == Nil
			lAglutPd := ( GetMv("MV_AGLUTPD",,"1") == "1" ) // 1-Agrupa conceptos 2-No Agrupa conceptos
			If ( nSumaCon == 1 )     //Suma los conceptos
				lAglutPd := .T.
			ElseIf ( nSumaCon == 2 ) //Muestra los conceptos por separado 
				lAglutPd := .F.
			EndIf
		Else
			If ( nSumaCon == 1 )     //Suma los conceptos
				lAglutPd := .T.  
			ElseIf ( nSumaCon == 2 ) //Muestra los conceptos por separado 
				lAglutPd := .F.
			EndIf	
		EndIf

		dbSelectArea("SRVPD")     
		SRVPD->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_TIPO+RV_COD+RV_ITEM

		If  lAglutPd  .And.  (SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon+cPDSRV)) )//Sumarizar los conceptos  
			RecLock("SRVPD",.F.)
			If  cIR == "1"  //Gravado         
				SRVPD->RC_VALORGV += nValorSRC	//Importe Gravado 
			Elseif cIR == "2" .OR. cIR == "3"  //Exento
				SRVPD->RC_VALOREX += nValorSRC	//Importe Exento 
			Endif 
			SRVPD->(MsUnlock())
		Else
			If !SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon+cPDSRV+STRZERO(nConsec)))
				RecLock("SRVPD",.T.)
				SRVPD->RA_FILIAL := SRA->RA_FILIAL        		//Filial
				SRVPD->RA_MAT    := SRA->RA_MAT        			//Matricula
				SRVPD->RV_TIPO   := cTipoCon        			//Tipo (1-Percepcion/2-Deduccion)
				SRVPD->RV_ITEM   := STRZERO(nConsec)     		//Consecutivo
				SRVPD->RV_TIPSAT := cTipSAT 					//Tipo Percepcion
				SRVPD->RV_COD	 := cPDSRV	                	//Clave
				SRVPD->RV_DESCDET:= cDESCDET					//Concepto           
				If  cIR == "1"  //Gravado         
					SRVPD->RC_VALORGV:= nValorSRC	//Importe Gravado 
				Elseif cIR == "2" .OR. cIR == "3"  //Exento
					SRVPD->RC_VALOREX:= nValorSRC	//Importe Exento 
				Endif 
				SRVPD->(MsUnlock())
			Endif
		Endif	

		//Impuestos Retenidos (ISR)
		If  cTipSAT =='002D'     //Tipo SAT: ISR
			If cTipoCon== "1" //Percepcion: resta    
				nImpReten-=nValorSRC             
			Elseif cTipoCon == "2" //Deduccion: suma 
				nImpReten+=nValorSRC
			Endif 

			If  lAglutPd  .And.  (SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3")) )//Sumarizar los conceptos  
				RecLock("SRVPD",.F.)
				If  cTipoCon== "1" //Percepcion: resta        
					SRVPD->RC_VALOR -= nValorSRC
				Elseif cTipoCon == "2" //Deduccion: suma 
					SRVPD->RC_VALOR += nValorSRC
				Endif 
				SRVPD->(MsUnlock())
			Else
				If !SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3"))
					RecLock("SRVPD",.T.)
					SRVPD->RA_FILIAL := SRA->RA_FILIAL        		//Filial
					SRVPD->RA_MAT    := SRA->RA_MAT        			//Matricula
					SRVPD->RV_TIPO   := "3"        		   			//Tipo (1-Percepcion/2-Deduccion/3-Impuestos)
					SRVPD->RV_ITEM   := STRZERO(nConsec)     		//Consecutivo
					SRVPD->RV_TIPSAT := cTipSAT 					//Tipo Percepcion
					SRVPD->RV_COD	 := cPDSRV	                	//Clave
					SRVPD->RV_DESCDET:= "ISR" //cDESCDET					//Concepto           
					If  cTipoCon== "1" //Percepcion: resta        
						SRVPD->RC_VALOR -= nValorSRC
					Elseif cTipoCon == "2" //Deduccion: suma 
						SRVPD->RC_VALOR += nValorSRC
					Endif 
					SRVPD->(MsUnlock())
				Endif
			Endif	                                                                           
		Endif      
	Endif


Return    



/*                                                                                   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GpeaXML  � Autor � Laura Medina Prado    � Data � 04/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generaci�n del XML para enviar al PAC y que regrese el Tim-���
���          � bre digital.                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GpeaXML()                                                  ���
���          � Retorno:  aGenXML[]                                        ���
���          � 1 - (.T.) Si genero correctamente el XML                   ���
���          � 2 - Timbre Fiscal                                          ���
���          � 3 - Descripci�n del error en caso de que no se genere XML. ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function GpeaXML() 
	Local aAreaSRA	 := SRA->(GetArea())
	Local lGeneXML    := .F.   
	Local cFilTmp    := cFilAnt 
	Private cRegPatr := "" //RegistroPatronal
	Private dFchPag  := CTOD("//")   //FechaPago
	Private dFchInPag:= CTOD("//")   //FechaInicialPago
	Private dFchFiPag:= CTOD("//")   //FechaFinalPago  
	Private nDiasPag := 0            //NumDiasPagagos
	Private cDeptoIm := ""           //Departamento
	Private cBcoCfdi := ""           //Banco
	Private dFchInLab:= CTOD("//")   //FechaInicioRelLaboral
	Private nAntigue := CTOD("//")   //Antiguedad      
	Private cPuesCfdi:= ""           //Puesto   
	Private cTipJorn := ""           //TipoJornada 
	Private cPerCFDi := ""           //Periodicidad del Pago
	Private nSalBasAp:= 0            //Salario Base Ap
	Private cRiegCFDi:= ""           //Riesgo del Puesto   
	Private nTotPGrav:= 0            //Total Gravado Percepciones
	Private nTotPExen:= 0            //Total Exento Percepciones
	Private nTotDGrav:= 0            //Total Gravado Deducciones
	Private nTotDExen:= 0            //Total Exento Deducciones
	Private aErrores := {}          
	Private cRUTASRV := SuperGetmv( "MV_CFDRECN" , .F. , "\cfd\recibos\" )	// Ruta donde se generan los recibos.xml (servidor)   

	Private cConcepSRV := "" 
	Private lEsExMar := .F.                                                                                                      
	Private cMV_DIAST:= SuperGetmv( "MV_CFDI_DT" , .F. , "" )	// Concepto Num 
	Private cMV_PGRAV:= SuperGetmv( "MV_CFDI_PG" , .F. , "" )	// Concepto de d�as pagados 
	Private aPercDed := {}

	/*aPerSelec[]: 
	1 - Periodo
	2 - No. de Pago
	3 - Mes
	4 - Ano
	5 - DTINI
	6 - DITFIM
	7 - DTPAGO 
	*/        

	If  !lEsPerAb //Solo validar cuando es periodo cerrado 
		If  aPerSelec[1,6]<=ctod('31/03/2014')  //Excepcion 
			lEsExMar := .T.
		Endif
	Endif

	//������������������������������������������������������������������������Ŀ
	//�ELEMENTO NOMINA:  ENCABEZADO                                            �
	//��������������������������������������������������������������������������
	cFilAnt  := SRA->RA_FILIAL 


	//Lugar Expedicion 
	DBSELECTAREA("RGC")
	RGC->(DBSETORDER(RetOrdem("RGC","RGC_FILIAL+RGC_KEYLOC")))
	IF  !RGC->(DBSEEK(XFILIAL("RGC")+SRA->RA_KEYLOC)) 
		//Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Lugar Expedicion"})
	Endif

	//Registro Patronal 
	DBSELECTAREA("RCO")
	RCO->(DBSETORDER(RetOrdem("RCO","RCO_FILIAL+RCO_CODIGO")))
	IF  RCO->(DBSEEK(XFILIAL("RCO")+SRA->RA_CODRPAT)) 
		cRegPatr := RCO->RCO_NREPAT
		/*Else //Requerido
		Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Registro Patronal"})*/
	Endif

	//Fecha Pago 
	IF  !Empty(aPerSelec[1,7])
		dFchPag := aPerSelec[1,7]
		/*Else //Requerido
		Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Fecha de Pago"})*/
	Endif

	//Fecha Inicial Pago 
	IF  !Empty(aPerSelec[1,5])
		dFchInPag := aPerSelec[1,5]
		/*Else //Requerido
		Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Fecha Inicial de Pago"})*/
	Endif

	//Fecha Final Pago 
	IF  !Empty(aPerSelec[1,6])
		dFchFiPag := aPerSelec[1,6]
		/*Else //Requerido
		Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Fecha Final de Pago"})*/
	Endif

	//Obtener concepto de d�as pagados    
	cConcpDPg  := Iif(lEsExMar,cMV_DIAST,ObtConcep(2))
	//Dias Pagados
	nDiasPag := ObtRegSRC(1)
	//Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Fecha Final de Pago"})    

	//Departamentos 
	DBSELECTAREA("SQB")
	SQB->(DBSETORDER(RetOrdem("SQB","QB_FILIAL+QB_DEPTO")))
	IF  SQB->(DBSEEK(XFILIAL("SQB")+SRA->RA_DEPTO)) 
		cDeptoIm := SQB->QB_DESCRIC
	Endif  

	//Bancos 
	DBSELECTAREA("SA6")
	SA6->(DBSETORDER(RetOrdem("SA6","A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON")))
	IF  SA6->(DBSEEK(XFILIAL("SA6")+Subs(SRA->RA_BCDEPSA,1,3)+Subs(SRA->RA_BCDEPSA,4,5))) 
		cBcoCfdi := SA6->A6_TIPSAT
	Endif

	//Fecha inicio de Rel Laboral 
	dFchInLab:= Iif(!Empty(SRA->RA_FECREI),SRA->RA_FECREI,SRA->RA_ADMISSA)

	//Antiguedad
	nAntigue := int((dFchFiPag-dFchInLab+1)/7)  //Semanas cotizadas 
	/*IF  nAntigue==0
	Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"La Antiguedad"})
	Endif*/

	//Puesto (Funciones)
	DBSELECTAREA("SRJ")
	SRJ->(DBSETORDER(RetOrdem("SRJ","RJ_FILIAL+RJ_FUNCAO")))
	IF  SRJ->(DBSEEK(XFILIAL("SRJ")+SRA->RA_CODFUNC)) 
		cPuesCfdi := SRJ->RJ_DESC       
		cRiegCFDi := SRJ->RJ_RIESGO                                         
		/*Else
		Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"El Puesto (RJ_DESC)/Riesgo (RJ_RIESGO)"})*/
	Endif

	//Tipo Jornada 
	DBSELECTAREA("SR6")
	SR6->(DBSETORDER(RetOrdem("SR6","R6_FILIAL+R6_TURNO")))
	IF  SR6->(DBSEEK(XFILIAL("SR6")+SRA->RA_TNOTRAB)) 
		cTipJorn := SR6->R6_DESC        
		/*Else
		Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"El Tipo Jornada (R6_DESC)"})*/
	Endif 

	//Periodicidad Pago (Procesos)
	DBSELECTAREA("RCJ")
	RCJ->(DBSETORDER(RetOrdem("RCJ","RCJ_FILIAL+RCJ_CODIGO")))
	IF  RCJ->(DBSEEK(XFILIAL("RCJ")+SRA->RA_PROCES)) 
		cPerCFDi := RCJ->RCJ_PERIOD
		/*Else
		Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"La Periodicidad (RCJ_PERIOD)"})*/
	Endif          

	//Salario Base
	If (cConcepSRV := ObtConcep(1)) <> ""
		nSalBasAp := ObtRegSRC(2, cConcepSRV)
		//Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Salario Base"})
	EndIf 

	nTotPGrav := aVlrPerDed[1]
	nTotPExen := aVlrPerDed[2]
	nTotDGrav := aVlrPerDed[3]
	nTotDExen := aVlrPerDed[4]    

	//������������������������������������������������������������������������Ŀ
	//�ELEMENTO NOMINA: PERCEPCIONES                                           �
	//��������������������������������������������������������������������������
	//Total Gravado
	//If  (nTotPGrav := ObtRegSRC(3))==0
	//	Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Percepcion Gravada"})
	//Endif  

	//Total Exento
	//If  (nTotPExen := ObtRegSRC(4))==0
	//	Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Percepcion exenta"})
	//Endif  

	//������������������������������������������������������������������������Ŀ
	//�ELEMENTO NOMINA: DEDUCCIONES                                            �
	//��������������������������������������������������������������������������
	//Total Gravado
	//If  (nTotDGrav := ObtRegSRC(7))==0
	//	Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Salario Base"})
	//Endif  

	//Total Exento
	//If  (nTotDExen := ObtRegSRC(8))==0
	//	Aadd(aErrores,{SRA->RA_FILIAL,SRA->RA_MAT,"Salario Base"})
	//Endif  

	//������������������������������������������������������������������������Ŀ
	//�ELEMENTO NOMINA: DEDUCCION                                              �
	//��������������������������������������������������������������������������
	//...

	//������������������������������������������������������������������������Ŀ
	//�ELEMENTO NOMINA: INCAPACIDAD                                            �
	//�������������������������������������������������������������������������� 
	LocTrabs("SRCIN")  //Incapacidades   
	ObtRegSRC(5)

	//������������������������������������������������������������������������Ŀ
	//�ELEMENTO NOMINA: HORASEXTRA                                             �
	//�������������������������������������������������������������������������� 
	LocTrabs("SRCEX")  //Horas Extra
	ObtRegSRC(6)

	SM0->(DBSEEK(SM0->M0_CODIGO+cFilAnt))
	If  GenRECNOM()
		lGeneXML := .T.
	Endif                

	cFilAnt := cFilTmp 
	SM0->(DBSEEK(SM0->M0_CODIGO+cFilAnt))
	RestArea( aAreaSRA ) 
	dbselectarea("SRA")
	SRA->(DBGOTO(aAreaSRA[3]))
Return lGeneXML



/*                                                                               
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtRegSRC� Autor � Laura Medina Prado    � Data � 04/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para obtener el numero de dias pagados.            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtRegSRC(nOpc)                                            ���
���          � 1 - Dias pagados                                           ���
���          � 2 - Salario Base                                           ���
���          � 3 - Total Gravado Percepciones                             ���
���          � 4 - Total Exento Percepciones                              ���
���          � 5 - Incapacidades                                          ���
���          � 6 - Horas Extra                                            ��� 
���          � 7 - Total Gravado Deducciones                              ���
���          � 8 - Total Exento Deducciones                               ���
���          � Retorno:  nDiasPg                                          ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtRegSRC(nOpc, cSRVCon)
	Local aAreaSRA	 := SRA->(GetArea())
	Local nDiasPg   := 0
	Local cQuerySRC := "" //Trayectorial laboral  
	Local cAliasSRC := CriaTrab(Nil,.F.)
	Local nConsec   := 0  //Consecutivo para las incapacidades    
	Local cID0446   := '0446'
	Local cID0447   := '0447'
	Local cQrAlias  := "" //Alias de la tabla en uso (SRC/SRD)

	Default cSRVCon := ""  

	lExistReg := .F.

	If lEsPerAb  
		cQrAlias := "SRC"  
		cQrIdent := "RC"
	Else
		cQrAlias := "SRD"  
		cQrIdent := "RD"
	Endif


	If nOpc == 1 .Or. nOpc == 9     //Dias Pagados
		cQuerySRC := " SELECT " + cQrIdent+"_HORAS RC_HORAS"
	Elseif nOpc == 2 //Salario Base  
		cQuerySRC := " SELECT sum("+cQrIdent+"_VALOR) RC_HORAS"  
		//Elseif nOpc == 3 .Or. nOpc == 4  .Or. nOpc == 7 .Or. nOpc == 8	//Total GravadoP/Total ExentoP/Total GravadoD/Total ExentoD
		//	cQuerySRC := " SELECT SUM("+cQrIdent+"_VALOR) RC_HORAS "
	Elseif nOpc == 5 //Incapacidades
		cQuerySRC := " SELECT " + cQrIdent+"_HORAS RC_HORAS," + cQrIdent+"_VALOR RC_VALOR, RCM_TIPSAT"
	Elseif nOpc == 6 //Horas Extra
		cQuerySRC := " SELECT RV_CODFOL, SUM("+cQrIdent+"_VALOR) RC_VALOR, SUM ("+cQrIdent+"_HORAS) RC_HORAS"
	Endif
	cQuerySRC += " FROM " + RetSqlName(cQrAlias) + " SRC "   
	If nOpc == 5 //Incapacidades
		cQuerySRC += ", " + RetSqlName("RCM") + " RCM "  
	Endif 
	If nOpc == 6 //.OR. nOpc == 3 .OR. nOpc == 4 .Or. nOpc == 7 .Or. nOpc == 8 //Percepciones/Deducciones/Horas Extra
		cQuerySRC += ", " + RetSqlName("SRV") + " SRV "  
	Endif
	cQuerySRC += " WHERE "+cQrIdent+"_FILIAL ='"+SRA->RA_FILIAL+"' AND  
	cQuerySRC += cQrIdent+"_MAT ='"+SRA->RA_MAT+"' AND 
	cQuerySRC += cQrIdent+"_PERIODO ='"+cPeriodo+"' AND 
	cQuerySRC += cQrIdent+"_SEMANA ='"+Semana+"' AND 
	cQuerySRC += cQrIdent+"_PROCES ='"+cProcesso+"' AND 
	cQuerySRC += cQrIdent+"_ROTEIR ='"+cRoteiro+"' AND 
	If  nOpc == 1
		cQuerySRC += cQrIdent+"_PD ='"+cConcpDPg+"' AND 
	Elseif nOpc == 2
		cQuerySRC += cQrIdent+"_PD IN ("+cSRVCon+")  AND   
		//Elseif nOpc == 3    //Gravadas Percepciones
		//	cQuerySRC += " ( (RV_TIPOCOD = '1' OR RV_TIPOCOD = '3' ) AND  RV_IR = '1' ) AND "
		//Elseif nOpc == 4    //Exentas Percepciones
		//	cQuerySRC += " ( (RV_TIPOCOD = '1' OR RV_TIPOCOD = '3' ) AND  (RV_IR = '2' or RV_IR = '3') ) AND "   
	Elseif nOpc == 5    //Incapacidades
		cQuerySRC += " ( ("+cQrIdent+"_PD = RCM_PD  AND RCM_TPIMSS='2') AND "
		cQuerySRC += "    RCM_FILIAL ='"+XFILIAL("RCM")+"' AND RCM.D_E_L_E_T_<>'*' ) AND "   
	Elseif nOpc == 6    //Horas Extra
		cQuerySRC += " ( "+cQrIdent+"_PD = RV_COD  AND (RV_CODFOL ='"+cID0446+"' OR RV_CODFOL ='"+cID0447+"') ) AND "
		//Elseif nOpc == 7    //Gravadas Deducciones
		//	cQuerySRC += " ( (RV_TIPOCOD = '2' OR RV_TIPOCOD = '4' ) AND  RV_IR = '1' ) AND "
		//Elseif nOpc == 8    //Exentas Deducciones
		//	cQuerySRC += " ( ((RV_TIPOCOD = '2' OR RV_TIPOCOD = '4' ) AND  (RV_IR = '2' OR RV_IR = '3') ) OR (RV_TIPOCOD = '2' AND  RV_IR = '3') )   AND "   
	Endif        
	//If  nOpc == 3  .OR. nOpc == 4 .OR.  nOpc == 7 .Or. nOpc == 8  
	//	cQuerySRC += "    RV_FILIAL ='"+XFILIAL("SRV")+"' AND SRV.D_E_L_E_T_<>'*'  AND "  
	//	cQuerySRC += cQrIdent+"_PD = RV_COD AND RV_IMPRIPD = '1' AND RV_TIPSAT <>'' AND "
	//Endif  

	If  nOpc == 6 
		cQuerySRC += "    RV_FILIAL ='"+XFILIAL("SRV")+"' AND SRV.D_E_L_E_T_<>'*'  AND "  
	Endif

	cQuerySRC += "SRC.D_E_L_E_T_<>'*' 
	If  nOpc == 6
		cQuerySRC += " GROUP BY RV_COD, RV_CODFOL " 
	Endif                                              


	cQuerySRC := ChangeQuery(cQuerySRC)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySRC),cAliasSRC,.T.,.T.)   

	(cAliasSRC)->( dbGoTop() ) 
	If  nOpc < 3 .Or. nOpc == 9 //.Or.  nOpc == 7  .Or.  nOpc == 8
		IF  !(cAliasSRC)->(Eof())  
			nDiasPg := (cAliasSRC)->RC_HORAS
			If  nOpc == 9
				lExistReg := .T. 
			Endif 
		Endif
	Elseif nOpc == 5   //Incapacidades
		IF  !(cAliasSRC)->(Eof()) 
			While (cAliasSRC)->(!Eof() )
				nConsec ++
				dbSelectArea("SRCIN")     
				SRCIN->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RCM_TIPSAT 
				If !SRCIN->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+STRZERO(nConsec) ))
					RecLock("SRCIN",.T.)
					SRCIN->RA_FILIAL := SRA->RA_FILIAL        		//Filial
					SRCIN->RA_MAT    := SRA->RA_MAT        			//Matricula
					SRCIN->RC_ITEM   := STRZERO(nConsec,2)    		//Consecutivo
					SRCIN->RC_HORAS  := (cAliasSRC)->RC_HORAS 		//Dias Incapacidad
					SRCIN->RCM_TIPSAT:= (cAliasSRC)->RCM_TIPSAT	//Tipo Incapacidad
					SRCIN->RC_VALOR  := (cAliasSRC)->RC_VALOR		//Descuento	   
					SRCIN->(MsUnlock())
				Endif
				(cAliasSRC)->(dbSkip())
			Enddo
		Endif    
	Elseif nOpc == 6  //Horas Extra 
		IF  !(cAliasSRC)->(Eof()) 
			While (cAliasSRC)->( !Eof()) 
				nConsec ++
				dbSelectArea("SRCEX")    
				SRCEX->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_CODFOL
				If !SRCEX->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+(cAliasSRC)->RV_CODFOL))
					RecLock("SRCEX",.T.)
					SRCEX->RA_FILIAL := SRA->RA_FILIAL        		//Filial
					SRCEX->RA_MAT    := SRA->RA_MAT        			//Matricula
					SRCEX->RGB_DUM   := ObtDias((cAliasSRC)->RV_CODFOL)   //Dias
					SRCEX->RV_CODFOL := Iif((cAliasSRC)->RV_CODFOL==cID0446,"Dobles","Triples") 	//Tipo Horas (valor fijo: Dobles/Triples)
					SRCEX->RC_HORAS  := (cAliasSRC)->RC_HORAS		//Horas Extras
					SRCEX->RC_VALOR  := (cAliasSRC)->RC_VALOR 		//Importe pagado	   							
					SRCEX->(MsUnlock())
				Endif
				(cAliasSRC)->(dbSkip())
			Enddo
		Endif
	Endif
	(cAliasSRC)->( DBCloseArea() ) 

	RestArea( aAreaSRA )
Return nDiasPg


/*                                                                               
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtConcep� Autor � Laura Medina Prado    � Data � 06/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para obtener los conceptos con Id de calculo 0543  ���
���          � (gravado 113), XXXX(gravado del 142) y 0476(liquidacion).  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtConcep()                                                ���
���          � Retorno:  cConceptos                                       ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtConcep(nOpc)
	Local aAreaSRA	 := SRA->(GetArea())
	Local cQuerySRV := "" //Trayectorial laboral  
	Local cAliasSRV := CriaTrab(Nil,.F.)   
	Local cIDCalc   := "('0543','0476','1278')"     //ID'S 
	Local cConceptos:= ""                      

	/*nOpc 
	1- Id's para Salario Base Cotizacion 
	2- Id'  para Dias Pagados */

	If  nOpc== 1   
		If  lEsExMar  //Es exepcion       
			cIDCalc   := "('0543','0476')" 
		Else
			cIDCalc   := "('0543','0476','1376')"  
			//0543 - Gravado 113
			//0476 - Liquidacion 
			//1376 - Total Percepcion Gravada 142
		Endif
	Else     
		cIDCalc   := "('0989')"  
		//0989 - Dias Trabajados
	Endif

	cQuerySRV := " SELECT RV_COD"
	cQuerySRV += " FROM " + RetSqlName("SRV") + " SRV "
	cQuerySRV += " WHERE RV_FILIAL ='"+XFILIAL("SRV")+"' AND  
	cQuerySRV += " RV_CODFOL IN "+cIDCalc+" AND  
	cQuerySRV += " SRV.D_E_L_E_T_<>'*'             
	cQuerySRV := ChangeQuery(cQuerySRV)           

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySRV),cAliasSRV,.T.,.T.)   

	(cAliasSRV)->( dbGoTop() ) 
	IF  !(cAliasSRV)->(Eof())  
		While !(cAliasSRV)->(Eof())  
			cConceptos += "'"+(cAliasSRV)->RV_COD+"',"
			(cAliasSRV)->(dbSkip())
		Enddo
	Endif 


	(cAliasSRV)->( DBCloseArea() ) 

	If !Empty(cConceptos) 
		If  nOpc ==2
			cConceptos:=Substr(Alltrim(cConceptos),2,len(cConceptos)-3)
		Else
			If  lEsExMar  //Es exepcion       
				If !Empty(cMV_PGRAV)
					cConceptos += "'"+Alltrim(cMV_PGRAV)+"',"  
				Endif
			Endif
			cConceptos:=Substr(Alltrim(cConceptos),1,len(cConceptos)-1)        
		Endif
	Endif

	RestArea( aAreaSRA )
Return cConceptos     



/*                                                                               
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtDias  � Autor � Laura Medina Prado    � Data � 09/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para obtener el numero total de dias de Horas Extra���
���          � generados en el periodo.                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtDias()                                                  ���
���          � Retorno:  nDias                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtDias(cIDCalc)
	Local aAreaSRA	:= SRA->(GetArea())

	Local cQueryDIAS := ""   
	Local cAliasDIAS := CriaTrab(Nil,.F.)    
	Local nDias      := 0 
	Local cIDDias    := ""

	If lEsPerAb  
		cQrAlias := "SRC"  
		cQrIdent := "RC"
	Else
		cQrAlias := "SRD"  
		cQrIdent := "RD"
	Endif


	If  cIDCalc == '0446' //Dobles
		cIDDias := '1377'	//ID's
	Elseif cIDCalc == '0447'     //Tripes
		cIDDias := '1378'  //ID's 
	Endif

	cQueryDIAS := " SELECT " + cQrIdent+"_HORAS RC_HORAS"
	cQueryDIAS += " FROM " + RetSqlName(cQrAlias) + " SRC," + RetSqlName("SRV")+ " SRV  " 
	cQueryDIAS += " WHERE "+cQrIdent+"_FILIAL ='"+SRA->RA_FILIAL+"' AND " 
	cQueryDIAS += " RV_FILIAL  ='"+XFILIAL("SRV")+"'  AND "  
	cQueryDIAS += cQrIdent+"_MAT ='"+SRA->RA_MAT+"' AND " 
	cQueryDIAS += cQrIdent+"_PERIODO ='"+cPeriodo+"' AND " 
	cQueryDIAS += cQrIdent+"_SEMANA ='"+Semana+"' AND " 
	cQueryDIAS += cQrIdent+"_PROCES ='"+cProcesso+"' AND " 
	cQueryDIAS += cQrIdent+"_ROTEIR ='"+cRoteiro+"' AND  " 
	cQueryDIAS += cQrIdent+"_PD = RV_COD  AND RV_CODFOL = '"+cIDDias+"' AND "
	cQueryDIAS += " SRC.D_E_L_E_T_<>'*' AND "    
	cQueryDIAS += " SRV.D_E_L_E_T_<>'*' "    


	cQueryDIAS := ChangeQuery(cQueryDIAS)           

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDIAS),cAliasDIAS,.T.,.T.)   

	(cAliasDIAS)->( dbGoTop() ) 
	IF  !(cAliasDIAS)->(Eof())      
		While (cAliasDIAS)->( !Eof()) 







			nDias += (cAliasDIAS)->RC_HORAS	













			(cAliasDIAS)->(dbSkip())
		Enddo
	Endif
	(cAliasDIAS)->( DBCloseArea() ) 

	RestArea( aAreaSRA )
Return nDias




/*                                                                                   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GenRECNOM� Autor � Laura Medina Prado    � Data � 04/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generaci�n del XML para enviar al PAC y que regrese el Tim-���
���          � bre digital (se basa en el RECNOM.ini).                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GpeaXXX()                                                  ���
���          � Retorno:  aGenXML[]                                        ���
���          � 1 - (.T.) Si genero correctamente el XML                   ���
���          � 2 - Timbre Fiscal                                          ���
���          � 3 - Descripci�n del error en caso de que no se genere XML. ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function GenRECNOM() 
	Local aAreaSRA	 := SRA->(GetArea())
	Local lGeneXML := .T.
	Local cNorma  := "RECNOM.INI" 
	Local cDir    := &(cRUTASRV)       // "\cfd\recibos\"        "D:\TEMP\" 
	Local cDest   := Alltrim(MV_PAR01)+Alltrim(MV_PAR02)+Alltrim(MV_PAR03)+Alltrim(MV_PAR04)+"_"+SRA->RA_FILIAL+SRA->RA_MAT  //Proceso+Roteiro+Periodo+No.Pago+"_"Filial+Matricula
	Local cDrive  := ""
	Local cExt    := ".xml" 
	Local aProcFil:= {.F.,cFilAnt}
	Local aTrab	  := {}    
	Local nX      := 0

	cNewFile := cDir + cDest

	SplitPath(cNewFile,@cDrive,@cDir,@cDest,@cExt)

	cDir := cDrive + cDir
	cDest+= ".xml"
	cDirRec := cDir

	Makedir(cDirRec)

	dbSelectArea("SX3")
	dbSetOrder(1)
	Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab)})

	//TimbrarRec(cDest) //Recibo.xml

	//dbCloseAll()
	//OpenFile(SubStr(cNumEmp,1,2))

	//��������������������������������������������������������������Ŀ
	//� Ferase no array aTrab                                        �
	//����������������������������������������������������������������
	For nX := 1 to Len(aTrab)
		Ferase(AllTrim(aTrab[nX][1]))
	Next

	RestArea( aAreaSRA )
Return lGeneXML




/*                                                                               
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LocTrabs � Autor � Laura Medina Prado    � Data � 09/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta los archivos de trabajo.                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � cTpArq - > Area de trabajo a crear.                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function LocTrabs(cTpArq)    
	Local aAreaSRA	 := SRA->(GetArea())
	Local cArqSRV       := "" //Percepciones-Deducciones 
	local aStrutSRV     := {} 
	Local cArqINCAP     := "" //Incapacidad
	local aStrutINC     := {} 
	Local cArqHREXT     := "" //Horas Extra
	local aStrutHEX     := {} 
	Local aOrdem := {}


	//������������������������������������������������������������������������Ŀ
	//�Creacion del archivo de Trabajo - Percepciones/Deducciones              �
	//��������������������������������������������������������������������������
	If cTpArq == "SRVPD"     //Detalle percepciones y deducciones
		If Select("SRVPD")>0
			DbSelectArea("SRVPD")	
			SRVPD->(DbCloseArea())
		EndIf	
		AADD(aStrutSRV,{"RA_FILIAL"	,"C",TAMSX3("RA_FILIAL")[1],0}) 	//Filial
		AADD(aStrutSRV,{"RA_MAT"    ,"C",TAMSX3("RA_MAT")[1],0}) 		//Matricula
		AADD(aStrutSRV,{"RV_TIPO"	,"C",1,0}) 							//Tipo (1-Percepcion/2-Deduccion)
		AADD(aStrutSRV,{"RV_ITEM"	,"C",2,0}) 							//Consecutivo
		AADD(aStrutSRV,{"RV_TIPSAT"	,"C",TAMSX3("RV_TIPSAT")[1],0}) 	//Tipo Percepcion
		AADD(aStrutSRV,{"RV_COD"    ,"C",TAMSX3("RV_COD")[1],0}) 		//Clave
		AADD(aStrutSRV,{"RV_DESCDET","C",TAMSX3("RV_DESCDET")[1],0}) 	//Concepto
		AADD(aStrutSRV,{"RC_VALORGV","N",(TAMSX3("RC_VALOR")[1]) + 4,6})		//Importe Gravado
		AADD(aStrutSRV,{"RC_VALOREX","N",(TAMSX3("RC_VALOR")[1]) + 4,6})		//Importe Exento	
		AADD(aStrutSRV,{"RC_VALOR","N",(TAMSX3("RC_VALOR")[1]) + 4,6})		//Importe Impuesto
		AADD(aStrutSRV,{"RC_HORAS","N",(TAMSX3("RC_VALOR")[1]) + 4,6})		//Importe Impuesto

		oTmpSRVPD := FWTemporaryTable():New("SRVPD") 
		oTmpSRVPD:SetFields( aStrutSRV ) 
		aOrdem	:=	{"RA_FILIAL","RA_MAT","RV_TIPO","RV_COD","RV_ITEM"} 
		oTmpSRVPD:AddIndex("IN1", aOrdem) 
		oTmpSRVPD:Create() 

		DbSelectArea("SRVPD")
		DbSetOrder(1) 

		Aadd(aTmpArea,{"SRVPD",'oTmpSRVPD'})

	Elseif cTpArq == "SRCIN"  //Incapacidades  
		If Select("SRCIN")>0
			DbSelectArea("SRCIN")	
			SRCIN->(DbCloseArea())
		EndIf	
		AADD(aStrutINC,{"RA_FILIAL"	,"C",TAMSX3("RA_FILIAL")[1],0}) 	//Filial
		AADD(aStrutINC,{"RA_MAT"    ,"C",TAMSX3("RA_MAT")[1],0}) 		//Matricula  
		AADD(aStrutINC,{"RC_ITEM"	,"C",2,0}) 							//Consecutivo
		AADD(aStrutINC,{"RC_HORAS"	,"N",(TAMSX3("RC_VALOR")[1]) + 4,6}) 	//Dias Incapacidad
		AADD(aStrutINC,{"RCM_TIPSAT","C",TAMSX3("RCM_TIPSAT")[1],0}) 	//Tipo Incapacidad
		AADD(aStrutINC,{"RC_VALOR"  ,"N",(TAMSX3("RC_VALOR")[1]) + 4,6}) 	//Descuento	

		oTmpSRCIN := FWTemporaryTable():New("SRCIN") 
		oTmpSRCIN:SetFields( aStrutINC ) 
		aOrdem	:=	{"RA_FILIAL","RA_MAT","RC_ITEM"} 
		oTmpSRCIN:AddIndex("IN2", aOrdem) 
		oTmpSRCIN:Create() 

		DbSelectArea("SRCIN")
		DbSetOrder(1) 

		Aadd(aTmpArea,{"SRCIN",'oTmpSRCIN'})

	Elseif cTpArq == "SRCEX"   //Horas Extra
		If Select("SRCEX")>0
			DbSelectArea("SRCEX")	
			SRCEX->(DbCloseArea())
		EndIf	
		AADD(aStrutHEX,{"RA_FILIAL"	,"C",TAMSX3("RA_FILIAL")[1],0}) 	//Filial
		AADD(aStrutHEX,{"RA_MAT"    ,"C",TAMSX3("RA_MAT")[1],0}) 		//Matricula
		AADD(aStrutHEX,{"RGB_DUM"	,"N",2,0})     						//Dias
		AADD(aStrutHEX,{"RV_CODFOL" ,"C",7,0}) 						//Tipo Horas (valor fijo: Dobles/Triples)
		AADD(aStrutHEX,{"RC_HORAS"  ,"N",TAMSX3("RC_HORAS")[1],0}) 	//Horas Extras
		AADD(aStrutHEX,{"RC_VALOR"  ,"N",(TAMSX3("RC_VALOR")[1]) + 4,6}) 	//Importe pagado

		oTmpSRCEX := FWTemporaryTable():New("SRCEX") 
		oTmpSRCEX:SetFields( aStrutHEX ) 
		aOrdem	:=	{"RA_FILIAL","RA_MAT","RV_CODFOL"} 
		oTmpSRCEX:AddIndex("IN3", aOrdem) 
		oTmpSRCEX:Create() 

		DbSelectArea("SRCEX")
		DbSetOrder(1)   

		Aadd(aTmpArea,{"SRCEX",'oTmpSRCEX'})

	Endif

	RestArea( aAreaSRA )
Return   


/*                                                                                 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DelAreaTrab� Autor � Laura Medina Prado   � Data � 18/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Borra los archivos de trabajo.                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DelAreaTrab() 
	Local nI := 0
	For nI:=1 To Len(aTmpArea)	
		dbSelectArea(aTmpArea[nI, 1])
		dbCloseArea()
		&(aTmpArea[nI, 2]):Delete()
		&(aTmpArea[nI, 2]) := Nil
	Next 
Return  


/*                                                                                 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VldCadena  � Autor � Laura Medina Prado   � Data � 20/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para armar la cadena origal: 1-Percepciones (SRVPD)���
���          � 2-Deducciones (SRVPD), 3-Incapacidades (SRVIN) y 4-Horas   ���
���          � Extr (SRCEX).                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function VldCadena(cTipoCon)
	Local cTmpCadOrg:= ""//	cCadOrig  
	Local cPipe     := "|"


	If  cTipoCon=="1" .Or.  cTipoCon=="2"   //Percepciones o Deducciones
		dbSelectArea("SRVPD")     
		SRVPD->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_TIPO+RV_COD+RV_ITEM

		If  SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon))
			While SRVPD->( !Eof() .And.  SRVPD->RA_FILIAL+SRVPD->RA_MAT+SRVPD->RV_TIPO==SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon)
				cTmpCadOrg+= Alltrim(SUBSTR(SRVPD->RV_TIPSAT,1,3)) +cPipe
				cTmpCadOrg+= Alltrim(SRVPD->RV_COD) + cPipe
				cTmpCadOrg+= Alltrim(SRVPD->RV_DESCDET) + cPipe
				cTmpCadOrg+= Alltrim(Str(SRVPD->RC_VALORGV)) + cPipe	
				cTmpCadOrg+= Alltrim(Str(SRVPD->RC_VALOREX))+ cPipe	   
				SRVPD->(dbSkip())
			Enddo  
		Endif   
	Elseif cTipoCon=="3"  //Incapacidades
		dbSelectArea("SRCIN")     
		SRCIN->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RCM_TIPSAT 

		If SRCIN->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
			While SRCIN->( !Eof() .And.  SRCIN->RA_FILIAL+SRCIN->RA_MAT==SRA->RA_FILIAL+SRA->RA_MAT)		
				cTmpCadOrg+= Alltrim(Str(SRCIN->RC_HORAS)) +cPipe
				cTmpCadOrg+= Alltrim(SRCIN->RCM_TIPSAT) + cPipe
				cTmpCadOrg+= Alltrim(Str(SRCIN->RC_VALOR)) + cPipe		 
				SRCIN->(dbSkip()) 	
			Enddo 
		Endif  

	Elseif cTipoCon=="4"  //Horas Extra
		dbSelectArea("SRCEX")     
		SRCEX->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_CODFOL

		If SRCEX->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
			While SRCEX->( !Eof() .And.  SRCEX->RA_FILIAL+SRCEX->RA_MAT==SRA->RA_FILIAL+SRA->RA_MAT)
				cTmpCadOrg+= Alltrim(Str(SRCEX->RGB_DUM)) +cPipe
				cTmpCadOrg+= Alltrim(SRCEX->RV_CODFOL) + cPipe
				cTmpCadOrg+= Alltrim(Str(SRCEX->RC_HORAS)) + cPipe
				cTmpCadOrg+= Alltrim(Str(SRCEX->RC_VALOR)) + cPipe			  
				SRCEX->(dbSkip())
			Enddo
		Endif       
	Endif 

	If !Empty(cTmpCadOrg)
		cCadOrig+=cTmpCadOrg
	Endif

Return     



/*                                                                                 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �InsertISR  � Autor � Laura Medina Prado   � Data � 20/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para insertar un registro en 0 para el ISR cuando  ���
���          � no existe ningun concepto de tipo '002D' - ISR Deduccion   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function InsertISR()       

	dbSelectArea("SRVPD")     
	SRVPD->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_TIPO+RV_COD+RV_ITEM

	If !SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3"))
		RecLock("SRVPD",.T.)
		SRVPD->RA_FILIAL := SRA->RA_FILIAL   //Filial
		SRVPD->RA_MAT    := SRA->RA_MAT      //Matricula
		SRVPD->RV_TIPO   := "3"        		  //Tipo (1-Percepcion/2-Deduccion/3-Impuestos)
		SRVPD->RV_ITEM   := "01"     		  //Consecutivo
		SRVPD->RV_TIPSAT := '002D' 		      //Tipo Percepcion
		SRVPD->RV_COD	 := "ISR"	          //Clave
		SRVPD->RV_DESCDET:= "ISR" //cDESCDET					//Concepto           
		SRVPD->RC_VALOR  := 0
		SRVPD->(MsUnlock())
	Endif

Return 


//+----------------------------------------------------------------------------------------------------------------------+
//|Rutinas para la impresi�n de recbo impreso o envio por email																  |
//+----------------------------------------------------------------------------------------------------------------------+
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPRXML  � Autor � Mayra Camargo         � Data � 16.12.13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao de Recibos de Pagamento Mexico a partir de xml     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � IMPRXML(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      |                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/


Function IMPRXML()
	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Locais (Basicas)                            �
	����������������������������������������������������������������*/
	Local cDesc1 := STR0006		//"Emiss�o de Recibos de Pagamento."
	Local cDesc2 := STR0007		//"Devido a tilizac�o de caracteres de compress�o,  e necessario que na impress�o"
	Local cDesc3 := STR0008		//" em formulario seja selecionado, no Tipo de Impress�o, a opc�o 'Direta na Porta'. "
	Local aDriver:= ReadDriver()

	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Locais (Programa)                           �
	����������������������������������������������������������������*/
	Local cIndCond
	Local cHtml 		:= ""
	Local oPrint		:= Nil
	Local cTitRel		:= ""


	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Private(Basicas)                            �
	����������������������������������������������������������������*/
	Private aReturn  := {STR0009, 1,STR0010, 2, 2, 1, "",1 }	//"Zebrado"###"Administra��o"
	Private nomeprog := "IMPRECXML"
	Private aLinha   := { }
	Private nLastKey := 0
	Private cPerg    := "IMPREC"
	Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe
	Private oFont	:= Nil
	Private cCompac := aDriver[1]
	Private cNormal := aDriver[2]

	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Private(Programa)                           �
	����������������������������������������������������������������*/
	Private li     		:= 0050
	Private Titulo 		:= STR0011		//"EMISS�O DE RECIBOS DE PAGAMENTOS"
	Private lEnvioOk 	:= .T. //modificacion Elena HD 04/10/13
	Private cProcesso	:= "" // Armazena o processo selecionado na Pergunte GPR040 (mv_par01).
	Private cRoteiro		:= "" // Armazena o Roteiro selecionado na Pergunte GPR040 (mv_par02).
	Private cPeriodo		:= "" // Armazena o Periodo selecionado na Pergunte GPR040 (mv_par03).
	Private cCcto			:= ""
	Private cCond			:= ""
	Private cRot			:= ""
	Private cMensRec 	:= ""
	Private cMensGral 	:= "" // Mensaje para cuerpo del Correo (LEMP 13/10/08)
	Private cDescProc
	Private Semana		:= "" // No. de Pago
	Private nTipRel		:= 0
	Private cClaveEmp	:= ""
	Private Ordem_Rel	:= 0
	Private Mensag1, Mensag2,Mensag3
	/*
	��������������������������������������������������������������Ŀ
	� Envia controle para a funcao SETPRINT                        �
	����������������������������������������������������������������*/
	cTitRel:="IMPRECXML"            //Nome Default do relatorio em Disco
	//Pergunte(cPerg,.F.)

	/*
	��������������������������������������������������������������Ŀ
	� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
	����������������������������������������������������������������*/

	cProcesso	:= MV_PAR01
	cRoteiro	:= MV_PAR02	//Emitir Recibos(Roteiro)
	cPeriodo	:= MV_PAR03  //Periodo
	Semana		:= MV_PAR04	//Numero da Semana
	nTipRel	:= MV_PAR05	//Tipo de Recibo (Pre/Zebrado/EMail)
	cFilDe		:= MV_PAR06	//Filial De
	cFilAte    := MV_PAR07	//Filial Ate
	cCcDe		:= MV_PAR14 	//Centro de Custo De
	cCcAte		:= MV_PAR15 	//Centro de Custo Ate
	cMatDe		:= MV_PAR08 	//Matricula Des
	cMatAte	:= MV_PAR09   	//Matricula Ate
	cNomDe		:= MV_PAR10	//Nome De
	cNomAte	:= MV_PAR11	//Nome Ate
	ChapaDe    := MV_PAR12 	//Chapa De
	ChapaAte	:= MV_PAR13	//Chapa Ate
	Mensag1    := MV_PAR20	//Mensagem 1
	Mensag2    := MV_PAR21	//Mensagem 2
	Mensag3    := MV_PAR22	//Mensagem 3
	cSituacao	:= MV_PAR18	//Situacoes a Imprimir
	cCategoria	:= MV_PAR19	//Categorias a Imprimir

	If cPaisLoc == "MEX"
		cLocalDe    := MV_PAR24		//De Local Pago
		cLocalAte   := MV_PAR25		//A Local Pago
	Endif

	cMensRec	:= AllTrim( fPosTab( "S018", MV_PAR23, "=", 4,,,,5) )
	//cMensGral	:= AllTrim( fPosTab( "S018", MV_PAR24, "=", 4,,,,5) ) //Obtener mensaje (LEMP 13/10/08)  


	DbSelectArea( "RCJ" )
	DbSetOrder( 1 )  // RCJ_FILIAL + RCJ_CODIGO
	DbSeek( xFilial( "RCJ" ) + cProcesso, .F. )

	cDescProc := SubStr( RCJ->RCJ_DESCRI, 1, 15 )

	/*
	��������������������������������������������������������������Ŀ
	� Inicializa Impressao                                         �
	����������������������������������������������������������������*/
	oPrint:= TMSPrinter():New( cTitRel )
	oPrint:SetPortrait()

	Processa({|| ImpXml(oPrint,cTitRel)})
	//ImpXml(oPrint,cTitRel)

Return


Static Function ImpXML(oPrint,titulo)
	Local aArea:= getArea()
	Local cCaminhoXML 	:= &(SuperGetMv("MV_CFDRECN", ,))
	Local oXML			:= Nil
	Local cAviso			:= ""
	Local cErro			:= ""
	Local aFiles			:= {}
	Local cPath			:= cCaminhoXML + alltrim(cProcesso)+ alltrim(cRoteiro)+alltrim(cPeriodo)+ alltrim(Semana)
	Local nI				:= 0
	Local cFile			:= ""
	Local cPathSrv		:= GetSrvProfString("Startpath","")
	Local cMat			:= ""
	Local cFilFun			:= ""
	Local cFileAux		:= ""
	Local nPosIni			:= 0
	Local nPosFin			:= 0
	Local cFim			:= ""
	Local cIni			:= "SRA->RA_FILIAL + SRA->RA_MAT"


	Private tamanho     	:= 	"M"
	Private limite		:= 	132
	Private cDtPago     	:= 	""
	Private cPict1		:=	"@E 999,999,999.99"
	Private cPict2 		:= 	"@E 99,999,999.99"
	Private cPict3 		:=	"@E 999,999.99"
	Private cTipoRot 	:= 	PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_TIPO")
	Private oFont		:= nil 
	Private oFont2	:= nil
	Private oFont3  := nil
	Private oFont4  := nil
	Private ofont5:= nil
	Private cNomIma := ""

	DEFINE FONT oFont   	NAME "ARIAL" 			SIZE 0,07 OF oPrint
	DEFINE FONT oFont2   NAME "ARIAL" 			SIZE 0,05 OF oPrint
	DEFINE FONT oFont3   NAME "ARIAL" 			SIZE 0,10 OF oPrint BOLD
	DEFINE FONT oFont4   NAME "ARIAL"			SIZE 0,07 OF oPrint bold
	DEFINE FONT oFont5   NAME "ARIAL" 			SIZE 0,05 OF oPrint bold
	Define Font oFont6   NAME "Courier New" 	SIZE 0,07 OF oPrint  
	DEFINE FONT oFont7   NAME "Arial" 	SIZE 0,05 OF oPrint //bold
	cFim    := cFilAte + cMatAte

	aFiles := Directory(cPath + '*.XML')

	dbSelectArea("SRA")
	dbSetOrder(1)

	For nI:= 1 to len(aFiles)
		cFile 		:= aFiles[nI,1]
		nPosIni	:= Rat("_",cFile)+1
		nPosFin	:= Rat(".",cFile)
		cClaveEmp 	:= Substr(cFile,nPosIni,nPosfin-nPosIni)
		cNomIma := Replace(cFile, ".XML", "")

		SRA->(dbGoTop())
		IF SRA->(dbSeek(cClaveEmp)) .and. &cIni <= cFim  .and. !((SRA->RA_CHAPA < ChapaDe)	.Or. (SRA->RA_CHAPA > ChapaAte)	.Or. ;
		(SRA->RA_FILIAL < cFilDe)	.Or. (SRA->RA_FILIAL > cFilAte) .Or. ;
		(SRA->RA_NOME < cNomDe)		.Or. (SRA->RA_NOME > cNomAte)	.Or. ;
		(SRA->RA_MAT < cMatDe)		.Or. (SRA->RA_MAT > cMatAte)	.Or. ;
		(SRA->RA_CC < cCcDe)		.Or. (SRA->RA_CC > cCcAte)		.Or. ;
		(SRA->RA_DEPTO < cDeptoDe)	.Or. (SRA->RA_DEPTO > cDeptoAte) .or.;
		(!( SRA->RA_SITFOLH $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria )) )


			IncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)
			oXML 	:= XmlParserFile( cCaminhoXML + cFile, "_", @cAviso,@cErro )	 
			IF empty(cAviso) .and. empty(cErro) .and. oXML <> NIL
				//Iif( File( GetClientDir() + cCodBarQR + ".jpg" ), FErase( GetClientDir() + cCodBarQR + ".jpg" ), "" )
				//Iif( File( GetClientDir() + cNomIma + ".bmp" ), FErase( GetClientDir() + cNomIma + ".bmp" ), "" )	
				li := 100 
				If nTipRel == 1
					oPrint:StartPage() 				
					Imprime(oPrint,oXML)	
					oPrint:EndPage()		
				Else
					fSendDPgto(oXML)
				End IF
			EndIF
			oXML := NIL
		EndIF
	Next nI

	IF nTipRel == 1
		//oPrint:Setup()
		oPrint:Preview()
		//oPrint:Print()
		Ms_Flush()

	EndIF
	oPrint:End()
	restarea(aArea)
Return

// 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Imprime   �Autor  �mayra.camargo       � Data � 24/12/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     � Genera el reporte a base del xml con los datos fiscales    ���
���          � y ya timbrado.                                             ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Imprime(oPrint,oXML)

	fCabec(oPrint,oXML)
	fLanca(oPrint,oXML)
	fRodaPe(oPrint,oXML)
Return
//Genera encabezado en base al xml 
Static Function fCabec(oPrint,oXML)   		// Cabecalho do Recibo

	Local cDet			:= ""
	Local cDir			:= oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_CALLE:TEXT + " "
	Local cFileLogo		:= ""   
	Local cFchRelLab    := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaInicioRelLaboral:TEXT
	Local cFchPerIni    := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaInicialPago:TEXT
	Local cFchPerFin    := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaFinalPago:TEXT   
	Local cFchPago      := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FECHAPAGO:TEXT 

	//Fecha Admision
	If !Empty(cFchRelLab)
		cFchRelLab := substr(cFchRelLab,9,2)+"/"+substr(cFchRelLab,6,2)+"/"+substr(cFchRelLab,1,4)
	Else
		cFchRelLab := "//"
	Endif  

	//Fecha Pago
	If !Empty(cFchPago)
		cFchPago := substr(cFchPago,9,2)+"/"+substr(cFchPago,6,2)+"/"+substr(cFchPago,1,4)
	Else
		cFchPago := "//"
	Endif   

	//Fecha Inicio Periodo-Pago
	If !Empty(cFchPerIni)
		cFchPerIni := substr(cFchPerIni,9,2)+"/"+substr(cFchPerIni,6,2)+"/"+substr(cFchPerIni,1,4)
	Else
		cFchPerIni := "//"
	Endif

	//Fecha Final Periodo-Pago
	If !Empty(cFchPerFin)
		cFchPerFin := substr(cFchPerFin,9,2)+"/"+substr(cFchPerFin,6,2)+"/"+substr(cFchPerFin,1,4)
	Else
		cFchPerFin := "//"
	Endif

	fCarLogo(@cFileLogo)

	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_COLONIA:TEXT 			+ " "
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_MUNICIPIO:TEXT 		+ " "
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_CODIGOPOSTAL:TEXT 	+ " "	
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_ESTADO:TEXT 			+ ","
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_PAIS:TEXT

	If File(cFilelogo)
		oPrint:SayBitmap(0060,0100, cFileLogo,200,150) // Tem que estar abaixo do RootPath
	Endif	
	LI+=90    //40
	oPrint:SAY(LI,1000,STR0017,oFont3)
	LI+=40
	oPrint:Line(LI,0050,LI,2400)
	LI +=40
	oPrint:SAY(LI,0100 ,STR0097,oFont4)
	oPrint:SAY(LI,0300 ,oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_NOMBRE:TEXT,oFont)
	Li+= 40
	If ObtUidXML(OXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "RegistroPatronal")
		oPrint:SAY(LI,0100 ,STR0121,OFONT4)
		oPrint:SAY(LI,0300 ,OXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_REGISTROPATRONAL:TEXT,oFont)
	EndIf
	Li+= 40
	oPrint:SAY(LI,0100 ,STR0099,OFONT4)
	oPrint:SAY(LI,0300 ,oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT,oFont)
	Li+= 40
	oPrint:SAY(LI,0100 ,STR0098, oFont4)
	oPrint:SAY(LI,0300 , cDir ,oFont)
	LI+=40
	oPrint:Line(LI,0050,LI,2400)
	LI+=40

	oPrint:SAY(LI,0100 , STR0001 + ": " , oFONT4)
	oPrint:SAY(LI,0300 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NUMEMPLEADO:TEXT,oFont)
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "nombre")
		oPrint:SAY(LI,0520 , STR0003,Ofont4)
		oPrint:SAY(LI,0670 , oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_NOMBRE:TEXT,oFont)
	EndIf
	Li+= 40
	oPrint:SAY(LI,0100 , STR0099, Ofont4)
	oPrint:SAY(LI,0300 , oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT,oFont)
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "NumSeguridadSocial")
		oPrint:SAY(LI,0520 , STR0122, oFONT4)
		oPrint:SAY(LI,0670 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NUMSEGURIDADSOCIAL:TEXT,oFont)
	EndIf
	oPrint:SAY(LI,1160 , STR0123, oFONT4)
	oPrint:SAY(LI,1300 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_CURP:TEXT,oFont) 
	oPrint:SAY(LI,1850 , STR0175, oFONT4)															//PERIODICIDAD DE PAGO
	oPrint:SAY(LI,2100 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_PERIODICIDADPAGO:TEXT,oFont)
	Li+= 40

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "Departamento")
		oPrint:SAY(LI,0100 , STR0128, oFONT4)
		oPrint:SAY(LI,0300 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_DEPARTAMENTO:TEXT,oFont)
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "Puesto")
		oPrint:SAY(LI,1160 , STR0133, Ofont4)
		oPrint:SAY(LI,1300 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_PUESTO:TEXT,oFont)
	EndIf 
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "TipoContrato") 
		oPrint:SAY(LI,1850 , STR0176, oFONT4)															//TIPO DE CONTRATO
		oPrint:SAY(LI,2100 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_TIPOCONTRATO:TEXT,oFont)
	EndIf
	Li+= 40
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "SalarioBaseCotApor")
		oPrint:SAY(LI,0100 ,STR0134, oFONT4)
		oPrint:SAY(LI,0300 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_SalarioBaseCotApor:TEXT,oFont)
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "SalarioDiarioIntegrado")
		oPrint:SAY(LI,0520 ,STR0135, oFONT4)
		oPrint:SAY(LI,0670 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_SalarioDiarioIntegrado:TEXT,oFont) 
	EndIf
	oPrint:SAY(LI,1160 ,STR0126,oFONT4)
	oPrint:SAY(LI,1350 , oXml:_CFDI_COMPROBANTE:_LugarExpedicion:TEXT,oFont)
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "FechaInicioRelLaboral")
		oPrint:SAY(LI,1850 ,STR0111, oFONT4)
		oPrint:SAY(LI,2100 ,cFchRelLab,oFont) // oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaInicioRelLaboral:TEXT
	EndIf
	Li+= 40
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO, "calle")
		cDet := oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_CALLE:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "colonia")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_COLONIA:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "municipio")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_MUNICIPIO:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "codigoPostal")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_CODIGOPOSTAL:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "estado")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_ESTADO:TEXT + " ,"
	EndIf
	cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_PAIS:TEXT 
	oPrint:SAY(Li,0100 ,STR0098 , oFONT4)
	oPrint:SAY(Li,0300 , cDet,oFont)
	Li+= 40 //2
	oPrint:SAY(Li,0100 ,STR0178, OFONT4) //STR0120 - "No Pago: "     Periodo Pago                  
	oPrint:SAY(Li,0300 ,cFchPerIni+" / " + cFchPerFin,oFont) //oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaInicialPago:TEXT +" / " +oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaFinalPago:TEXT
	oPrint:SAY(LI,1850 ,STR0136, ofont4)
	oPrint:SAY(LI,2100 ,cFchPago,oFont) //oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FECHAPAGO:TEXT		

	LI+=40
	oPrint:Line(LI,050,LI,2400)
	LI+=50
Return Nil
//

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLanca    �Autor  �mayra.camargo       � Data � 24/12/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     �Genera cuerpo del reporte en base al xml                    ���

���          �                                          			        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fLanca(oPrint,oXML)   // Impressao dos Lancamentos

	Local cString	:= "" //Transform(aLanca[nConta,5],cPict2)

	Local nI		:= 0
	Local cImpGrv	:= ""
	Local cImpExc	:= ""

	oPrint:SAY(Li,0100 ,STR0137	,oFont4)
	oPrint:SAY(Li,0300 ,STR0138	,oFont4)
	oPrint:SAY(Li,0520 ,STR0069	,oFont4)
	oPrint:SAY(Li,1150 ,STR0177	,oFont4)
	oPrint:SAY(Li,1750 ,STR0139	,oFont4)
	oPrint:SAY(Li,2200 ,STR0140	,oFont4)	
	Li+=30
	oPrint:Line(LI,0100,LI,2350)
	Li+=30
	oPrint:SAY(Li,0100 ,oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_CANTIDAD:TEXT	,oFont)
	oPrint:SAY(Li,0250 ,oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_UNIDAD:TEXT		,oFont)
	oPrint:SAY(Li,0520 ,oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_DESCRIPCION:TEXT,oFont)
	oPrint:SAY(Li,1150 ,oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NUMDIASPAGADOS:TEXT,oFont) // DIAS PAGADOS SAT
	oPrint:SAY(Li,1750 ,Transform(val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_VALORUNITARIO:TEXT),cPict2),oFont6)
	oPrint:SAY(Li,2200 ,Transform(val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_IMPORTE:TEXT),cPict2),oFont6)

	Li+=35
	oPrint:Line(LI,0050,LI,2400)
	Li+=30
	oPrint:SAY(Li,0100 ,STR0141	,oFont4)
	oPrint:SAY(Li,0300 ,STR0142	,oFont4)
	oPrint:SAY(Li,0520 ,STR0069	,oFont4)
	oPrint:SAY(Li,1950 ,STR0143	,oFont4)
	Li+=30
	oPrint:Line(LI,0100,LI,2350)
	Li+=35
	oPrint:SAY(Li,0100 ,STR0144,oFont4)
	Li+=50
	If ObtUidXML(oXML,"nomina:Percepciones")
		IF ValType(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION) <> "O"
			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION)

				cImpGrv := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_IMPORTEGRAVADO:TEXT)
				cImpExc := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_IMPORTEEXENTO:TEXT)

				IF !Empty(cImpGrv)
					cString := Transform(cImpGrv,cPict2)
					oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_TIPOPERCEPCION:TEXT,oFont)
					oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_CLAVE:TEXT,oFont)
					oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_CONCEPTO:TEXT,oFont)		
					oPrint:SAY(LI,1750,cString,oFont6)
					Li+=30
				End If

				If !Empty(cImpExc)			
					cString := Transform(cImpExc,cPict2)
					oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_TIPOPERCEPCION:TEXT,oFont)				
					oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_CLAVE:TEXT,oFont)
					oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION[nI]:_CONCEPTO:TEXT,oFont)		
					oPrint:SAY(LI,1750, cString,oFont6)	
					Li+= 30	
				End IF				
			Next nI
		Else
			cImpGrv := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_IMPORTEGRAVADO:TEXT)
			cImpExc := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_IMPORTEEXENTO:TEXT)

			IF !Empty(cImpGrv)
				cString := Transform(cImpGrv,cPict2)
				oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_TIPOPERCEPCION:TEXT,oFont)			
				oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_CLAVE:TEXT,oFont)
				oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_CONCEPTO:TEXT,oFont)		
				oPrint:SAY(LI,1750,cString,oFont6)
				Li+=30
			End If

			If !Empty(cImpExc)			
				cString := Transform(cImpExc,cPict2)
				oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_TIPOPERCEPCION:TEXT,oFont)			
				oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_CLAVE:TEXT,oFont)
				oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_NOMINA_PERCEPCION:_CONCEPTO:TEXT,oFont)		
				oPrint:SAY(LI,1750, cString,oFont6)	
				Li+= 30	
			End IF
			Li+= 50			
		EndIF
	EndIF
	oPrint:SAY(Li,0100 ,STR0145,oFont4)
	Li+=50

	If ObtUidXML(oXML,"nomina:Deducciones")
		If valtype(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION) <> "O"
			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION)

				cImpGrv := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION[nI]:_IMPORTEGRAVADO:TEXT)
				cImpExc := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION[nI]:_IMPORTEEXENTO:TEXT)

				IF !Empty(cImpGrv)
					cString := Transform(cImpGrv,cPict2)
					oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_deducciones:_NOMINA_DEDUCCION[nI]:_TIPODEDUCCION:TEXT,oFont)				
					oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION[nI]:_CLAVE:TEXT,oFont)
					oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION[nI]:_CONCEPTO:TEXT,oFont)	
					oPrint:SAY(LI,2200 , cString,oFont6)
					Li+=30
				End If

				If !Empty(cImpExc)			
					cString := Transform(cImpExc,cPict2)
					oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION[nI]:_TIPODEDUCCION:TEXT,oFont)
					oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION[nI]:_CLAVE:TEXT,oFont)
					oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION[nI]:_CONCEPTO:TEXT,oFont)	
					oPrint:SAY(LI,2200 , cString,oFont6)	
					Li+= 30	
				End IF				
			Next nI
		Else
			cImpGrv := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_IMPORTEGRAVADO:TEXT)
			cImpExc := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_IMPORTEEXENTO:TEXT)

			IF !Empty(cImpGrv)
				cString := Transform(cImpGrv,cPict2)
				oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_TIPODEDUCCION:TEXT,oFont)
				oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_CLAVE:TEXT,oFont)
				oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_CONCEPTO:TEXT,oFont)	
				oPrint:SAY(LI,2200 , cString,oFont6)
				Li+=30
			End If

			If !Empty(cImpExc)			
				cString := Transform(cImpExc,cPict2)
				oPrint:SAY(LI,0100,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_TIPODEDUCCION:TEXT,oFont)
				oPrint:SAY(LI,0300,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_CLAVE:TEXT,oFont)
				oPrint:SAY(LI,0520,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_NOMINA_DEDUCCION:_CONCEPTO:TEXT,oFont)	
				oPrint:SAY(LI,2200 , cString,ofont6)	
				Li+= 30	
			End IF				
			lI+=50
		EndIF
	EndIf

	oPrint:Line(LI,0050,LI,2400)
	Li+=50

	If ObtUidXML(oXML,"nomina:Incapacidades")
		oPrint:SAY(Li,0100 ,STR0147,oFont4)
		Li+=50
		oPrint:SAY(Li,0100 ,STR0148			,oFont4)
		oPrint:SAY(Li,0300 ,STR0141			,oFont4)
		oPrint:SAY(Li,2200 ,STR0149		,oFont4)
		Li+=50
		oPrint:Line(LI,0100,LI,2350)	
		Li+=20

		IF valtype(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD)<> "O"
			For nI := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD)

				oPrint:SAY(Li,0100 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD[NI]:_DIASINCAPACIDAD:TEXT,oFont)
				oPrint:SAY(Li,0300 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD[NI]:_TIPOINCAPACIDAD:TEXT,oFont)
				oPrint:SAY(Li,2200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD[NI]:_DESCUENTO:TEXT),cPict2),oFont6)
				Li+=30			
			Next nI
		Else

			oPrint:SAY(Li,0100 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD:_DIASINCAPACIDAD:TEXT,oFont)
			oPrint:SAY(Li,0300 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD:_TIPOINCAPACIDAD:TEXT,oFont)
			oPrint:SAY(Li,2200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_INCAPACIDADES:_NOMINA_INCAPACIDAD:_DESCUENTO:TEXT),cPict2),oFont6)			
			Li+=30
		EndIF

		Li+=50
	End If

	If ObtUidXML(oXML,"nomina:HorasExtra")
		oPrint:SAY(Li,0100 ,STR0151,oFont4)
		Li+=50
		oPrint:SAY(Li,0100 ,STR0148	,oFont4)
		oPrint:SAY(Li,0300 ,STR0141	,oFont4)
		oPrint:SAY(Li,0520 ,STR0152	,oFont4)
		oPrint:SAY(Li,2200 ,STR0140	,oFont4)
		Li+=50
		oPrint:Line(LI,0100,LI,2350)	
		Li+=20

		IF valtype(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAS:_NOMINA_HORASEXTRA) <> "O"
			For nI := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAS:_NOMINA_HORASEXTRA)

				oPrint:SAY(Li,0100 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAS:_NOMINA_HORASEXTRA[nI]:_DIAS:TEXT,oFont)
				oPrint:SAY(Li,0300 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAS:_NOMINA_HORASEXTRA[nI]:_TIPOHORAS:TEXT,oFont)
				oPrint:SAY(Li,0520 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAS:_NOMINA_HORASEXTRA[nI]:_HORASEXTRA:TEXT,oFont)
				oPrint:SAY(Li,2200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAS:_NOMINA_HORASEXTRA[nI]:_IMPORTEPAGADO:TEXT),cPict2),oFont6)
				Li+=30
			Next nI
		Else

			oPrint:SAY(Li,0100 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAs:_NOMINA_HORASEXTRA:_DIAS:TEXT,oFont)
			oPrint:SAY(Li,0300 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAs:_NOMINA_HORASEXTRA:_TIPOHORAS:TEXT,oFont)
			oPrint:SAY(Li,0520 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAs:_NOMINA_HORASEXTRA:_HORASEXTRA:TEXT,oFont)
			oPrint:SAY(Li,2200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_HORASEXTRAs:_NOMINA_HORASEXTRA:_IMPORTEPAGADO:TEXT),cPict2),oFont6)
			Li+=30
		EndIf
		Li+=50
	End If

	If ObtUidXML(oXML,"cfdi:Impuestos")

		oPrint:SAY(Li,0100 ,STR0154	,oFont4)
		Li+=50
		oPrint:SAY(Li,0100 ,STR0155	,oFont4)
		oPrint:SAY(Li,2200 ,STR0140	,oFont4)
		Li+=50
		oPrint:Line(LI,0100,LI,2350)	
		Li+=20

		IF valtype(oXML:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_RETENCIONES:_CFDI_RETENCION)<> "O"
			For nI := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_RETENCIONES:_CFDI_RETENCION)

				oPrint:SAY(Li,0100 ,oXML:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_RETENCIONES:_CFDI_RETENCION[nI]:_IMPUESTO:TEXT,oFont)
				oPrint:SAY(Li,2200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_RETENCIONES:_CFDI_RETENCION[nI]:_IMPORTE:TEXT),cPict2),oFont6)
				Li+=30
			Next nI
		Else

			oPrint:SAY(Li,0100 ,oXML:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_RETENCIONES:_CFDI_RETENCION:_IMPUESTO:TEXT,oFont)
			oPrint:SAY(Li,2200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_CFDI_RETENCIONES:_CFDI_RETENCION:_IMPORTE:TEXT),cPict2),oFont6)
			Li+=30
		EndIF
		Li+=30
	End If
	oPrint:Line(LI,0050,LI,2400)
	Li+=30
Return Nil

// Genera pie de reporte incluyendo mensajes, totales ,cadenas de sello e imagen de codigo de barras.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fRodape   �Autor  �mayra.camargo       � Data � 24/12/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     �Genera pie de reporte incluyendo mensajes, totales ,        ���
���          � cadenas de sello e imagen de codigo de barras.             ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fRodape(oPrint,oXML)    // Rodape do Recibo
	Local cTotalPerGrv 	:= 0
	Local cTotalPerExc 	:= 0
	Local cTotalDedGrv 	:= 0
	Local cTotalDedExc 	:= 0
	Local cTotal		  	:= 0
	Local cSubTotal	  	:= 0
	Local cCadena 	  	:= ""
	Local nI			 	:= 0
	Local nx				:= 0
	Local cCadAux		  	:= ""
	Local DESC_MSG1		:= ""
	Local DESC_MSG2		:= ""
	Local DESC_MSG3		:= ""
	Local nLiaux			:= ""
	Local cCertSAT		:= ""
	Local cTotalImp		:= 0
	Local cDescuentos	:= 0
	Local nTtlAux := 0
	// MENSAGENS
	If MENSAG1 # SPACE(3)
		If FPHIST82(SRA->RA_FILIAL,"06",MENSAG1)
			DESC_MSG1 := Left(SRX->RX_TXT,30)
		Endif
	Endif

	If MENSAG2 # SPACE(3)
		If FPHIST82(SRA->RA_FILIAL,"06",MENSAG2)
			DESC_MSG2 := Left(SRX->RX_TXT,30)
		Endif
	Endif

	If MENSAG3 # SPACE(3)
		If FPHIST82(SRA->RA_FILIAL,"06",MENSAG3)
			DESC_MSG3 := Left(SRX->RX_TXT,30)
		Endif
	Endif

	If ObtUidXML(oXML,"nomina:Percepciones")
		cTotalPerGrv 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_TOTALGRAVADO:TEXT)
		cTotalPerExc 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_PERCEPCIONES:_TOTALEXENTO:TEXT)
	EndIf

	If ObtUidXML(oXML,"nomina:Deducciones")
		cTotalDedGrv 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_TOTALGRAVADO:TEXT)
		cTotalDedExc 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_NOMINA_DEDUCCIONES:_TOTALEXENTO:TEXT)
	EndIf

	cSubTotal		:= val(oXML:_CFDI_COMPROBANTE:_SUBTOTAL:TEXT)
	cTotal			:= val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT) 
	cTotalImp		:= val(oXML:_CFDI_COMPROBANTE:_CFDI_IMPUESTOS:_totalImpuestosRetenidos:TEXT)    
	cDescuentos	:= val(oXML:_CFDI_COMPROBANTE:_DESCUENTO:TEXT)
	If !Empty(cTotalPerGrv)
		oPrint:SAY(LI,0100, STR0156,oFont4)
		oPrint:SAY(LI,1750, Transform(cTotalPerGrv,cPict2),oFont6)
		Li+= 30
	End IF

	If !Empty(cTotalPerExc)
		oPrint:SAY(LI,0100, "Total Percepciones Exentas",oFont4)
		oPrint:SAY(LI,1750, Transform(cTotalPerExc,cPict2),oFont6)
		Li+= 30
	End IF
	oPrint:SAY(LI,0100, STR0158,oFont4)
	oPrint:SAY(LI,1750, Transform(cSubtotal,cPict2),oFont6)
	Li+= 30
	If !Empty(cTotalDedGrv)
		oPrint:SAY(LI,0100, STR0159,oFont4)
		oPrint:SAY(LI,2200, Transform(cTotalDedGrv,cPict2),oFont6)
		Li+= 30
	End IF
	If !Empty(cTotalDedExc)
		oPrint:SAY(LI,0100, STR0160,oFont4)
		oPrint:SAY(LI,2200, Transform(cTotalDedExc,cPict2),oFont6)
		Li+= 30
	End IF
	oPrint:SAY(LI,0100, STR0161,oFont4)
	oPrint:SAY(LI,2200, Transform(cDescuentos,cPict2),oFont6)
	Li+= 30
	oPrint:SAY(LI,0100, STR0162,oFont4)
	oPrint:SAY(LI,2200, Transform(cTotalImp,cPict2),oFont6)

	Li+= 50
	oPrint:SAY(LI,0100, STR0163,ofont4)
	oPrint:SAY(LI,2200 , Transform(cTotal,cPict2),oFont6)
	LI +=35
	oPrint:line(LI,0050,LI,2400)
	LI +=35

	If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "Banco")
		oPrint:SAY(LI,0100 , STR0164, oFont4	)//"CRED:"
		oPrint:SAY(LI,0300 , oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_BANCO:TEXT,oFont)
	EndIf
	If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA, "CLABE")
		oPrint:SAY(LI,0520 , STR0165, ofont4)
		oPrint:SAY(LI,0670 , oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_CLABE:TEXT,oFont)//"CONTA:"
	EndIf
	LI +=35
	oPrint:line(LI,0050,LI,2400)
	LI +=35
	oPrint:SAY(LI,0100 , STR0166, oFont4	)
	LI +=35
	oPrint:SAY(LI,0100 , DESC_MSG1,oFont)
	LI +=35
	oPrint:SAY(LI,0100 , DESC_MSG2,oFont)
	LI +=35
	oPrint:SAY(LI,0100 , DESC_MSG3,oFont)
	LI +=35

	oPrint:line(LI,0050,LI,2400)
	LI +=35
	nLiaux	:= LI
	oPrint:SAY(LI,0100 , STR0179, oFont5)

	LI +=35

	If ObtUidXML(oXML,"tfd:TimbreFiscalDigital") 
		cCadena := "||" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_VERSION:TEXT
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT 
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOCFD:TEXT 
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
		cCadena += "||"

		nX := 1
		For nI := 1 to (len(cCadena)/150)	+ 1 		
			cCadAux:= Substr(cCadena,nX,150)
			nX+=150	
			oPrint:SAY(LI,0100 ,cCadAux,oFont7)
			Li+=35
		End IF 
	Else
		Li += 35
	End IF

	oPrint:SAY(LI,0500 ,STR0168,oFont5)
	nLiaux	:= LI
	LI +=35
	If ObtUidXML(oXML,"SELLOCFD")
		cCadena :=  oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOCFD:TEXT
		nX := 1
		For nI := 1 to (len(cCadena)/150)	+ 1 		
			cCadAux:= Substr(cCadena,nX,150)
			nX+=150	
			oPrint:SAY(LI,0500 ,cCadAux,oFont7)
			Li+=35
		End IF
	Else
		Li+=35
	EndIf
	oPrint:SAY(LI,0500 , STR0169, oFont5)
	LI +=35
	If	ObtUidXML(oXML,"SELLOSAT")			
		If Val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT) < 0 
			nTtlAux := Val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT) * (- 1)
			nTtlAux := "-" + Replace(Transform(nTtlAux,"999999999.999999") , " ", "0")
		Else
			nTtlAux := Val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT)
			nTtlAux := Replace(Transform(nTtlAux,"9999999999.999999") , " ", "0")	 
		EndIf
		cCertSAT := "?re=" + oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT 
		cCertSAT += "&rr=" + oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT
		cCertSAT += "&tt=" + nTtlAux
		cCertSAT += "&id=" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT

		cCadena :=  oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT

		nX := 1
		For nI := 1 to (len(cCadena)/150)	+ 1 

			cCadAux:= Substr(cCadena,nX,150)
			nX+=150	
			oPrint:SAY(LI,0500 ,cCadAux,oFont7)
			Li+=35
		End IF
		//Aqu� va La imagen rara

		If  CodBarQR( cCertSAT , cNomIma )
			oPrint:SayBitMap( nLIAux, 100, GetClientDir() + cNomIma + ".bmp", 330, 330)							
		Endif
	Else
		Li+=35
	EndIF
	lI+=35		
	oPrint:SAY(LI,0500 , UPPER(STR0170),oFont7)


	lI+=100	
	oPrint:BOX(0050,0050,LI,2700)
	lI+=35
	oPrint:SAY(LI,0100 , cMensRec,oFont7)
Return Nil

//
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fSendDPgto�Autor  �mayra.camargo       � Data � 24/12/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     �Env�a por mail el  htm generado a partir del xml.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fSendDPgto(oXml) //original
	Local aSvArea		:= GetArea()

	Local cEmail	    := SRA->RA_EMAIL//If(SRA->RA_RECMAIL=="S",SRA->RA_EMAIL,"    ")
	Local cHtml			:= ""
	Local cSubject		:= STR0017 //gsa STR0044	//" DEMONSTRATIVO DE PAGAMENTO "
	Local cTotalPerGrv 	:= 0
	Local cTotalPerExc 	:= 0 
	Local cTotalDedGrv	:= 0
	Local cTotalDedExc 	:= 0
	Local cTotal	  	:= 0
	Local cSubTotal	  	:= 0
	Local nProv
	Local nDesco
	Local cFileAux	:= ""
	Local cImpGrv		:= ""
	Local cImpExc		:= ""
	Local cTotalImp		:= 0

	Local cDescuentos 	:= "0
	Local cDir			:= oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_CALLE:TEXT + " "
	Local cDet 			:= ""



	//Local cCodBarQR		:= "codbar_cdf"
	Local cArquivo		:= getmv("ES_DIRLOG")
	Local DESC_MSG1		:= ""
	Local DESC_MSG2		:= ""
	Local DESC_MSG3		:= ""


	Local cFchRelLab    := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaInicioRelLaboral:TEXT
	Local cFchPerIni    := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaInicialPago:TEXT   
	Local cFchPerFin    := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FechaFinalPago:TEXT   
	Local cFchPago      := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA_NOMINA:_FECHAPAGO:TEXT 
	Local cCadena := ""
	Local cCertSAT := ""

	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL
	Private lAutentica := .F.
	Private cPwAut := ""
	Private cAcAut := ""

	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_COLONIA:TEXT 			+ " "
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_MUNICIPIO:TEXT 		+ " "
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_CODIGOPOSTAL:TEXT 	+ " "	
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_ESTADO:TEXT 			+ ","
	cDir += oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_CFDI_DOMICILIOFISCAL:_PAIS:TEXT

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO, "calle")
		cDet := oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_CALLE:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "colonia")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_COLONIA:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "municipio")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_MUNICIPIO:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "codigoPostal")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_CODIGOPOSTAL:TEXT + " "
	EndIf
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "estado")
		cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_ESTADO:TEXT + " ,"
	EndIf
	cDet += oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_CFDI_DOMICILIO:_PAIS:TEXT

	//Fecha Admision
	If !Empty(cFchRelLab)
		cFchRelLab := substr(cFchRelLab,9,2)+"/"+substr(cFchRelLab,6,2)+"/"+substr(cFchRelLab,1,4)
	Else
		cFchRelLab := "//"
	Endif  

	//Fecha Pago
	If !Empty(cFchPago)
		cFchPago := substr(cFchPago,9,2)+"/"+substr(cFchPago,6,2)+"/"+substr(cFchPago,1,4)
	Else
		cFchPago := "//"
	Endif   

	//Fecha Inicio Periodo-Pago
	If !Empty(cFchPerIni)
		cFchPerIni := substr(cFchPerIni,9,2)+"/"+substr(cFchPerIni,6,2)+"/"+substr(cFchPerIni,1,4)
	Else
		cFchPerIni := "//"
	Endif

	//Fecha Final Periodo-Pago
	If !Empty(cFchPerFin)
		cFchPerFin := substr(cFchPerFin,9,2)+"/"+substr(cFchPerFin,6,2)+"/"+substr(cFchPerFin,1,4)
	Else
		cFchPerFin := "//"
	Endif


	// MENSAGENS
	If MENSAG1 # SPACE(3)
		If FPHIST82(SRA->RA_FILIAL,"06",MENSAG1)
			DESC_MSG1 := Left(SRX->RX_TXT,30)
		Endif
	Endif

	If MENSAG2 # SPACE(3)
		If FPHIST82(SRA->RA_FILIAL,"06",MENSAG2)
			DESC_MSG2 := Left(SRX->RX_TXT,30)
		Endif
	Endif

	If MENSAG3 # SPACE(3)
		If FPHIST82(SRA->RA_FILIAL,"06",MENSAG3)
			DESC_MSG3 := Left(SRX->RX_TXT,30)
		Endif
	Endif

	//��������������������������������������������������������������Ŀ
	//� Busca parametros                                             �
	//����������������������������������������������������������������
	cMailConta	:=If(cMailConta == NIL,GETMV("MV_RELACNT"),cMailConta)           //Conta utilizada p/envio do email
	cMailServer	:=If(cMailServer == NIL,GETMV("MV_RELSERV"),cMailServer)           //Server
	cMailSenha	:=If(cMailSenha == NIL,GETMV("MV_RELAPSW"),cMailSenha)  

	///Autentificaci�n  para envio de Email externo // elena HD 04/10/13
	lAutentica := GetMV("MV_RELAUTH")   
	cPwAut 	:= GetMV("MV_RELAPSW",,""  )//Contrasena para autenticacion en servidor de e-mai
	cAcAut	:= GetMV("MV_RELAUSR",,"" )//Usuario para Autenticacion en el Servidor de Email

	If Empty(cEmail)
		Help("",1,"")
		Return
	Endif

	//��������������������������������������������������������������Ŀ
	//� Verifica se existe o SMTP Server                             �
	//����������������������������������������������������������������
	If 	Empty(cMailServer)
		Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se existe a CONTA                                   �
	//����������������������������������������������������������������
	If 	Empty(cMailConta)
		Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se existe a Senha                                   �
	//����������������������������������������������������������������
	If 	Empty(cMailServer)
		Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf

	cFileAux := u_ImpRcNPdf(Alltrim(MV_PAR01),Alltrim(MV_PAR02),Alltrim(MV_PAR03)+ Alltrim(MV_PAR04),SRA->RA_FILIAL,SRA->RA_MAT )

	//��������������������������������������������������������������Ŀ
	//� Envia e-mail p/funcionario                                   �
	//����������������������������������������������������������������
	//CpyT2S(GetClientDir()+cCodBarQR+".jpg","cfd\ ")

	memowrite(curdir()+"reciboNom.html",cHtml)

	//If File( curdir() + cCodBarQR + ".jpg" )
	//	FErase( curdir() + cCodBarQR + ".jpg" )
	//EndIf
	CpyT2S( GetClientDir() + cNomIma + ".jpg", Curdir() )

	lEnvioOK := EnvRecMail(cSubject,cHtml,cEMail,{cFileAux + ".pdf",cFileAux + ".xml"})

	RestArea( aSvArea )

Return                                                                                                               



//Realiza env�o de email con adjuntos

Static Function EnvRecMail(cAssunto,cMensaje,cEmail,_aAnexo)
	Local oMailServer := Nil
	Local oMessage
	Local cEmailTo 	:= ""
	Local cEmailBcc	:= ""
	//Local lResult  	:= .F.
	Local cError   	:= ""  
	Local cEMailAst	:= cAssunto

	// Verifica se serao utilizados os valores padrao.
	Local cAccount	:= GetMV( "MV_RELACNT",,"" )
	Local cPassword	:= GetMV( "MV_RELPSW",,""  )
	Local cServer		:= GetMV( "MV_RELSERV",,"" ) //smtp.microsiga.com.br
	Local cAttach 	:= ""
	Local cFrom		:= cAccount             

	Local lUseSSL  	:= GetMv("MV_RELSSL")	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
	Local lAuth    	:= GetMv("MV_RELAUTH")	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
	Local nPort		:= GetMv("MV_SRVPORT")
	Local lresult
	Local nX	    := 0
	Local cTotvs    := Alltrim(SM0->M0_CGC)  
	Local NI        := 0

	Default _aAnexo := {}

	//�������������������������������������������������������������������������������Ŀ
	//�Envia o e-mail para a lista selecionada. Envia como BCC para que a pessoa pense�
	//�que somente ela recebeu aquele email, tornando o email mais personalizado.     �
	//���������������������������������������������������������������������������������

	cEmailTo := cEmail

	If Empty(nPort)
		nPort := 25
	EndIf

	If !lAuth 

		For nI:= 1 to Len(_aAnexo)
			cAttach += _aAnexo[nI] + "; "
		Next nI

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

		If lResult
			SEND MAIL FROM cFrom ;
			TO      	cEmailTo;
			BCC     	cEmailBcc;
			SUBJECT 	cEMailAst;
			BODY    	cEMailAst;
			ATTACHMENT  cAttach  ;
			RESULT lResult

			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				//IF !lworkflow
				Help(" ",1,STR0171,,cError,4,5)
				//ELSE 
				//    CONOUT ("Error: "+cError)
				//ENDIF	
			EndIf

			DISCONNECT SMTP SERVER

		Else
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError

			Help(" ",1,STR0171,,cError,4,5)


		EndIf
		DISCONNECT SMTP SERVER
	Else
		If cTotvs != "TME031112BC0"
			//Instancia o objeto do MailServer
			oMailServer:= TMailManager():New()
			oMailServer:SetUseSSL(lUseSSL)				//Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
			oMailServer:SetUseTLS(.T.) 				//Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento
			oMailServer:Init("pop.totvs.com.br",cServer,cAccount,cPassword,0,nPort)

			//Defini��o do timeout do servidor
			If oMailServer:SetSmtpTimeOut(120) != 0
				Help(" ",1,STR0171,,STR0172 ,4,5)
				Return .F.
			EndIf

			//Conex�o com servidor
			nErr := oMailServer:smtpConnect()
			If nErr <> 0
				Help(" ",1,STR0171,,oMailServer:getErrorString(nErr),4,5)
				oMailServer:smtpDisconnect()
				Return .F.
			EndIf

			//Autentica��o com servidor smtp
			nErr := oMailServer:smtpAuth(cAccount, cPassword)
			If nErr <> 0
				Help(" ",1,STR0171,,STR0173 + oMailServer:getErrorString(nErr),4,5)
				oMailServer:smtpDisconnect()
				return .F.
			EndIf

			//Cria objeto da mensagem+
			oMessage := tMailMessage():new()
			oMessage:clear()
			oMessage:cFrom := cFrom 
			oMessage:cTo := cEmailTo 
			oMessage:cCc := cEmailBcc
			oMessage:cSubject :=  cEMailAst

			oMessage:cBody := cEMailAst
			//oMessage:AttachFile(_CAnexo)							//Adiciona um anexo, nesse caso a imagem esta no root

			For nX := 1 to Len(_aAnexo)
				oMessage:AddAttHTag("Content-ID: <" + _aAnexo[nX] + ">")	//Essa tag, � a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
				oMessage:AttachFile(_aAnexo[nX])							//Adiciona um anexo, nesse caso a imagem esta no root
			Next nX

			//Dispara o email	
			nErr := oMessage:send(oMailServer)
			If nErr <> 0
				Help(" ",1,STR0171,,STR0174 + oMailServer:getErrorString(nErr),4,5)
				oMailServer:smtpDisconnect()
				Return .F.
			Else
				//ApMsgInfo("E-mail enviado com sucesso", "SUCESSO")
				lResult := .T.
			EndIf

			//Desconecta do servidor
			oMailServer:smtpDisconnect()
		Else
			lResult := MailSmtpOn(cMailServer,cMailConta,cMailSenha)
			// Verifica se o E-mail necessita de Autenticacao
			IF lResult   
				If lAutentica
					lResult := MailAuth(cAcAut,cPwAut)
				Else
					lResult := .T.
				Endif
			Endif

			If lResult                      
				ConOut("--> Enviando email...")
				lResult := Mailsend(cMailConta, {cEmail}, {" "}, {" "}, cEMailAst, cMensGral, _aAnexo) //{curdir()+"reciboNom.html"} 
				lEnvioOK := .T.
				// Se apresentou erro ao enviar email, exibe-o
				If !lResult
					While !lResult         //para forzar el envio hasta que la conexion lo permita
						lResult := MailSmtpOn(cMailServer,cMailConta,cMailSenha)
						If lAutentica
							lResult := MailAuth(cAcAut,cPwAut)
						Else
							lResult := .T.
						Endif
						lResult := Mailsend(cMailConta, {cEmail}, {" "}, {" "}, cEMailAst, cMensGral, _aAnexo) //{curdir()+"reciboNom.html"} 
						lEnvioOK := .F.				
						MailSmtpOff()
						//			ConOut("--> ErLuisror: " + MailGetErr())  
						//			alert(MailGetErr())
						dbSkip()
					EndDo
				Else
					ConOut("*** Email enviado.")
				EndIf
				//	DISCONNECT SMTP SERVER
			Else
				lEnvioOK := .F.  
				alert("No conexion con el Servidor")
				alert(MailGetErr())
				//Erro na conexao com o SMTP Server
				//GET MAIL ERROR cError
				//Help(" ",1,"ATENCION",,cError,4,5) 
				ConOut("--> Error: " + MailGetErr())

			EndIf
			//DISCONNECT SMTP SERVER
			MailSmtpOff()
		EndIf
	End IF

Return(lResult)    

//Carga Logo de la empresa
Static Function fCarLogo(cLogo)
	Local  cStartPath:= GetSrvProfString("Startpath","")

	cLogo	:= cStartPath + "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
	//-- Logotipo da Empresa
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	Endif

Return cLogo

// Busca nodo o elemento en el XML
Static Function ObtUidXML(oXML,cNodo)

	Local cXML     := ""     
	Local cError   := ""
	Local cDetalle := ""   
	Local lRet     := .F.

	If valType(oXml) == "O"				//Es un objeto
		SAVE oXml XMLSTRING cXML

		If AT( "ERROR" , Upper(cXML) ) > 0	// El archivo tiene errores
			If 	ValType(oXml:_ERROR) == "O"
				cError   := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT   
			Endif
		Else		//Obtener identificador del certificado 				
			If At( UPPER(cNodo) , Upper(cXml) ) > 0
				lRet := .T. 
			Endif
		Endif
	Endif

Return lRet    
