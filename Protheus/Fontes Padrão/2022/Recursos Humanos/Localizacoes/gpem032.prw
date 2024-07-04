#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM032.CH"

/*/
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������Ŀ��
���Fun��o      � GPEM032  � Autor   � Erika Kanamori                  � Data � 07/07/2011 ���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o   � Calculo de Ferias Coletivas para o Modelo II                             ���
�����������������������������������������������������������������������������������������Ĵ��
���Sintaxe     � GPEM032()                                                   		      ���
�����������������������������������������������������������������������������������������Ĵ��
��� Uso        � Generico                                                    		      ���
�����������������������������������������������������������������������������������������Ĵ��
���          ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               		      ���
�����������������������������������������������������������������������������������������Ĵ��
���Programador  � Data   � FNC            �  Motivo da Alteracao                          ���
�����������������������������������������������������������������������������������������Ĵ��
���Silvia Taguti�03/01/12�REQ0008 ARG11.6 �Ids da Argentina alterados para opcionais      ���
�����������������������������������������������������������������������������������������Ĵ��
���Marcelo Faria�11/01/12�REQ0008 ARG11.6 �Atualizacao para calculos massivos             ���
���Glaucia M.   �04/02/13�00000000687/2013�Alteracao campo R8_STATUS eR8_SITUAC           ���
���             �        �          TGJMGL�Ajustes para que Calc.Ferias Coletivas fique   ���
���             �        �                �igual ao calculo individual.                   ���
���Glaucia M.   �15/02/13�00000000687/2013�Ajuste para n�o apresentar Localidade Pago e   ���
���             �        �          TGPCYH�habilitei o Trace Log no calculo. Alterei con- ���
���             �        �                �sulta padr�o do roteiro. Tratei para permitir  ���
���             �        �                �somente criar f�rias para funcion�rios com:    ���
���             �        �                �RA_SITFOLH diferente de "F", que n�o possuam   ���
���             �        �                �f�rias previamente calculadas .                ���
���Allyson M.   �20/11/15�          TTRL26�Ajuste p/ guardar o posicionamento de RCH para ���
���             �        �                �nao perder a data de pagamento para as feria   ���
���             �        �                �coletivas   						              ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������*/

Function GPEM032() 

Local lSetCentury	:= __SetCentury( "on" )	//altero o estado de SetCentury 

Local cFilMat		:= Space(99)
Local cFilDep		:= Space(99)
Local cFilPosto		:= Space(99)
Local cFilCC		:= Space(99)
Local cFilLocPag	:= Space(99)
Local cDuracao		:= Space(6)

//Variaveis para montagem da Dialog  
Local oDlg                                         
Local aAdvSize2		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObjCoords2	:= {}
Local aRetcoords    := {}  

Local aArea			:= GetArea()
Local aPages		:= Array( 02 )
Local aFolders		:= Array( 02 )
Local aObjFolder	:= Array( 02 )
Local aButtons		:= {}    

Local bSet15
Local bSet24
Local bDialogInit

Local oProces
Local oFolders
Local oChkHabGrab
Local oChkHabTrace
Local oRadStatus

Private cProces		:= Space( TamSX3( "RCJ_CODIGO" )[1] )
Private cRoteiro 	:= Space( TamSX3( "RY_CALCULO" )[1] )
Private cPeriodo	:= Space( TamSX3( "RCH_PER" )[1] )
Private cNumPag		:= Space( TamSX3( "RCH_NUMPAG" )[1] ) 
Private cProcDesc	:= Space( TamSX3( "RCJ_DESCRI" )[1] )
Private cRotDesc 	:= Space( TamSX3( "RY_DESC" )[1] )
Private lHabGrab	:= .F.  
Private lHabTrace	:= .F.  
Private aFilter		:= {}
Private __aFormulas	:= {}
Private oPeriodo	:= RHPERIODO():New()
Private lGrid		:= .F.           

Private nStatus		:= 1
Private dDataIni	:= Ctod("//")
Private dDataFim	:= Ctod("//")
Private nDuracao	:= Space(6)
Private dDataKey	:= CtoD("//") 
Private dDtFimFer	:= CtoD("//") 
Private dDtPagFer	:= CtoD("//")

Private lColetiva	:= .T. //indica q eh ferias coletivas no calculo (Gpem022Processa)
Private lColetInd	:= .F. /*indica q eh ferias coletivas no calculo (Gpem022Processa)
						     mas obedece informacoes da programacao individual do funcionario */	

/*�����������������������������������������������������������Ŀ
//�Funcao verifica se existe alguma restri��o de acesso para o�
//�usu�rio que impe�a a execu��o da rotina.                   �
//�������������������������������������������������������������*/
If !(fValidFun({"SQB","SRJ","RCO",;
				"CTT","RGC","RCE","SR6","SR3",;
				"SR7","SRC","RGB","SRV","SRK",;
				"RCP","RG7"}))
	RestArea(aArea)
	Return
Endif	

Begin Sequence

	aAdd(aButtons, {'RELATORIO', {|| TelaLog()}, OemToAnsi(STR0001) , OemToAnsi(STR0002)}) //"Consulta Logs de Calculo"##"Logs"

	/*/
	��������������������������������������������������������������Ŀ
	� Define o Conteudo do aPages								   �
	����������������������������������������������������������������/*/
	aPages[ 01 ] := OemToAnsi( "&" + STR0003 )	//"Gerais"
	aPages[ 02 ] := OemToAnsi( "&" + STR0004 )	//"Faixas"

	/*/
	��������������������������������������������������������������Ŀ
	� Define o Conteudo do aFolders								   �
	����������������������������������������������������������������/*/
	aFolders[ 01 ] := OemToAnsi( "&" + STR0003 ) //"Gerais"
	aFolders[ 02 ] := OemToAnsi( "&" + STR0004 ) //"Faixas"
	
	/*/
	��������������������������������������������������������������Ŀ
	� Define os Elementos para o Array do Objeto Folder        	   �
	����������������������������������������������������������������/*/
	aObjFolder[ 01 ]	:= Array( 01 , 04 )
	aObjFolder[ 02 ]	:= Array( 02 , 04 )
	
	// Em GRID havera uma Barra de processamento da LIB //
	bSet15			:= { || fGeraFilter( aFilter, cFilMat, cFilDep, cFilPosto, cFilCC, cFilLocPag), If( VldCalculo(), CalFerCol(), .F. )} 
	bSet24			:= { || oDlg:End() }

	/*/
	��������������������������������������������������������������Ŀ
	� Define o Bloco para a Inicializacao do Dialog            	   �
	����������������������������������������������������������������/*/
	bDialogInit		:= { ||;
								CursorWait()													,;
								oProces:SetFocus()												,;
								EnchoiceBar( oDlg , bSet15 , bSet24, NIL , aButtons )			,;
								CursorArrow()												 	 ;
					   }
	
	/*/
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������/*/
	aAdvSize2		:= MsAdvSize()
	aInfo2AdvSize	:= { aAdvSize2[1] , aAdvSize2[2] , aAdvSize2[3] , aAdvSize2[4] , 5 , 5 }
	aAdd( aObjCoords2 , { 000 , 000 , .T. , .T. } )
	aObj2Size		:= MsObjSize( aInfo2AdvSize , aObjCoords2 )
	
	Define MsDialog oDlg Title OemToAnsi(STR0005) From aAdvSize2[7],000 TO aAdvSize2[6],aAdvSize2[5] OF oMainWnd PIXEL //"Ferias Coletivas"

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.
		
		/*/
		��������������������������������������������������������������Ŀ
		� Carrega o Objeto Folder               					   �
		����������������������������������������������������������������/*/
		oFolders := TFolder():New(	aObj2Size[1,1]			,;
									aObj2Size[1,2]			,;
									aFolders				,;
									aPages					,;
									oDlg					,;
									NIL						,;
									NIL						,;
									NIL						,;
									.T.						,;
									.F.						,;
									aObj2Size[1,4]			,;
									aObj2Size[1,3]			 ;
								 )

		/*/
		��������������������������������������������������������������������������Ŀ
		� Dados do folder - Gerais 											       �
		����������������������������������������������������������������������������*/
       
		aRetcoords := RetCoords(4,9,55,15,2,40,,oFolders:OWND:NTOP)
		       
		//
		@aRetcoords[1][1]	,aRetcoords[1][2] SAY   STR0006 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Processo: "
	  	@aRetcoords[2][1]	,aRetcoords[2][2] MSGET oProces VAR cProces   SIZE 040,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN GpemValDis(lDisable) */PICTURE ;
									   							   PesqPict("RCJ","RCJ_CODIGO") F3 "RCJ" VALID;
																    ( If( Empty(cProces),;
													    			  	(cProcDesc := "", lRet := .T.),;
															    	  	If( lRet := ExistCpo("RCJ", cProces),;
															    			  cProcDesc := Posicione("RCJ",1,xFilial("RCJ")+cProces, "RCJ_DESCRI"),;
																    		  "")),;
																    lRet := VldPeriodo(),;
																    lRet ) HASBUTTON   
		
																    
		@aRetcoords[3][1]	,aRetcoords[3][2] SAY   STR0007 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Descricao: "																    
	  	@aRetcoords[4][1]	,aRetcoords[4][2] MSGET cProcDesc SIZE 140,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.

		
		@aRetcoords[5][1]	,aRetcoords[5][2] SAY   STR0008 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Tipo Folha: "
		@aRetcoords[6][1]	,aRetcoords[6][2] MSGET cRoteiro  SIZE 040,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN GpemValDis(lDisable) */PICTURE ;
																	PesqPict("SRY","RY_CALCULO") F3 "SRYVAC" VALID;
																    ( If( Empty(cRoteiro),;
													    			  	(cRotDesc := "", lRet := .T.),;
															    	  	If( lRet := ExistCpo("SRY", cRoteiro),;
															    			  cRotDesc := Posicione("SRY",1,xFilial("SRY")+cRoteiro, "RY_DESC"),;
																    		  "")),;
																    lRet := VldPeriodo(),;
																    lRet ) HASBUTTON 
		
																    
	  	@aRetcoords[7][1]  ,aRetcoords[7][2] SAY   STR0007 SIZE 033,007   OF oFolders:aDialogs[ 01 ] PIXEL	//"Descricao: "																    
		@aRetcoords[8][1]  ,aRetcoords[8][2] MSGET cRotDesc SIZE 140,007  OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.
          
		
		@aRetcoords[9][1]	,aRetcoords[9][2] 	SAY   STR0009 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Periodo: "
		@aRetcoords[10][1]	,aRetcoords[10][2] MSGET cPeriodo SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.


		@aRetcoords[11][1]	,aRetcoords[11][2] SAY   STR0010 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Nro Pagto: "
		@aRetcoords[12][1]	,aRetcoords[12][2] MSGET cNumPag SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.

		@aRetcoords[13][1]	,aRetcoords[13][2] SAY   STR0011 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Inicio: "
		@aRetcoords[14][1]	,aRetcoords[14][2] MSGET dDataIni SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON
		
		@aRetcoords[15][1]	,aRetcoords[15][2] SAY   STR0012 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Fim: "
		@aRetcoords[16][1]	,aRetcoords[16][2] MSGET dDataFim SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON

		@aRetcoords[17][1]	,aRetcoords[17][2] SAY   STR0013 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Ini Ferias: "
		@aRetcoords[18][1]	,aRetcoords[18][2] MSGET dDataKey SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN .F. */HASBUTTON ;
												VALID NAOVAZIO() .And. (fDataferM2( dDataKey, nDuracao, "dDtFimFer"))
												
		@aRetcoords[19][1]	,aRetcoords[19][2] SAY   STR0014 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Duracao: "
		@aRetcoords[20][1]	,aRetcoords[20][2] MSGET nDuracao SIZE 040,007 OF oFolders:aDialogs[ 01 ] Picture '999' PIXEL /*WHEN .F. HASBUTTON */;
												VALID NAOVAZIO() .And. (nDuracao:= Val(nDuracao), fDataferM2( dDataKey, nDuracao, "dDtFimFer"), oDlg:Refresh())
        
		@aRetcoords[21][1]	,aRetcoords[21][2] SAY   STR0015 SIZE 040,007   OF oFolders:aDialogs[ 01 ] PIXEL	//"Fim Ferias: "
		@aRetcoords[22][1]	,aRetcoords[22][2] MSGET dDtFimFer SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON
		
		@aRetcoords[23][1]	,aRetcoords[23][2] SAY   STR0016 SIZE 040,007   OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Pagto: "
		@aRetcoords[24][1]	,aRetcoords[24][2] MSGET dDtPagFer SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN .T. */HASBUTTON
		
		@aRetcoords[25][1]	,aRetcoords[25][2]  SAY  STR0017 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Status: "
        
		oRadStatus			:= TRadMenu():New( aRetcoords[26][1]	,aRetcoords[26][2] , {STR0018,STR0019,STR0020} , NIL , oFolders:aDialogs[ 01 ] , NIL , NIL , NIL , NIL , NIL , NIL , NIL , 115 , 010 , NIL , NIL , NIL , .T. ) //"Ativos"##"Inativos"##"Ambos"
		oRadStatus:bSetGet	:= { |nItem| IF( nItem <> NIL , nStatus := nItem , nStatus ) }
		oRadStatus:SetDisable()
				
		@aRetcoords[27][1]	,aRetcoords[27][2] CHECKBOX oChkHabGrab VAR lHabGrab PROMPT OemToAnsi(STR0021) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar Gravacao"
		@aRetcoords[31][1]	,aRetcoords[31][2] CHECKBOX oChkHabTrace VAR lHabTrace PROMPT OemToAnsi( "Habilitar Trace" ) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar TRACE"
		oChkHabGrab:SetDisable() 

		
		/*/
		��������������������������������������������������������������������������Ŀ
		� Dados do folder - Filtros 										       �
		����������������������������������������������������������������������������*/

		@aRetcoords[1][1]	,aRetcoords[1][2] SAY   STR0022 SIZE 045,007   OF oFolders:aDialogs[ 02 ] PIXEL	//"Funcionarios: "
		@aRetcoords[2][1]	,aRetcoords[2][2] MSGET cFilMat   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN GpemValDis(lDisable)*/ F3 "SRA" HASBUTTON

		@aRetcoords[5][1]	,aRetcoords[5][2] SAY   STR0023 SIZE 045,007   OF oFolders:aDialogs[ 02 ] PIXEL	//"Departamentos: "
		@aRetcoords[6][1]	,aRetcoords[6][2] MSGET cFilDep   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "SQB" HASBUTTON

		@aRetcoords[9][1]	,aRetcoords[9][2] 	SAY   STR0024 SIZE 045,007 OF oFolders:aDialogs[ 02 ] PIXEL	//"Centro de Custos: "
		@aRetcoords[10][1]	,aRetcoords[10][2] MSGET cFilCC   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "CTT" HASBUTTON 

		If cPaisLoc $ "COL|COS|DOM|MEX"
			@aRetcoords[13][1]	,aRetcoords[13][2] SAY   STR0025 SIZE 045,007    OF oFolders:aDialogs[ 02 ] PIXEL	//"Local de Pagamento: "
			@aRetcoords[14][1]	,aRetcoords[14][2] MSGET cFilLocPag SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "S015" HASBUTTON
		EndIf
		
		If ( FunName() == "GPEM040" )
			If ExistBlock( "GPM040CAL" )	
				ExecBlock("GPM040CAL")
			EndIf
		EndIf
				
	ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED
                                              	
End Sequence

IF !( lSetCentury )
	__SetCentury( "off" )
EndIF

Return Nil
   


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �CalFerCol   � Autor � Erika Kanamori        � Data � 28/07/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Chama a funcao de calculo das ferias coletivas.               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �CalFerCol()                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/

Static Function CalFerCol()
Local lRet	:= .T.

If empty(dDataKey)
	lColetiva := .F.
	lColetInd := .T. 
Endif

Proc2BarGauge({|lEnd| Gpem022Processa()},,,, .T. , .T. , .F. , .F. )

Return(lRet)



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fValFerCol  � Autor � Erika Kanamori        � Data � 29/07/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se pode calcular ferias coletivas para o funcionario.  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �fValFerCol()                                                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Function fValFerCol()                        

Local lRet		:= .T.
Local nAux		:= 0 
Local nDiasADesc:= 0  
Local nDFerVen	:= 0
Local nDFerPag	:= 0
Local nDFerAVe	:= 0
Local nDFerAdia	:= 0  
Local aPerFerias:= {}
Local dDtRetAf 		:= CTOD("//")
Local lTemAfast		:= .F.
/*/
�������������������������������������������������������������������������������������Ŀ
� Verifica se jah nao tem ferias calculadas para o funcionario no periodo selecionado �
���������������������������������������������������������������������������������������*/                         
dbSelectArea("RHI")
dbSetOrder(RetOrder("RHI", "RHI_FILIAL+RHI_MAT+DTOS(RHI_DTINI)"))
RHI->(dbSeek(xFilial("RHI") + SRA->RA_MAT))

If Empty(dDtFimFer)
	dDataKey := CtoD("//")
	nDuracao := 0
	While (RHI->(RHI_FILIAL+RHI_MAT) == SRA->(RA_FILIAL+RA_MAT)) 
		If  (RHI->RHI_PERIOD == cPeriodo)
			dDataKey := RHI->RHI_DTINI
			nDuracao :=	RHI->RHI_DFERIA
			Exit
		Endif
		
		RHI->(dbSkip())      
	End
	If Empty(dDataKey)
   	    lRet	 := .F.	
    	aAdd(aNCalcCol, {SRA->RA_MAT, SRA->RA_NOME} ) 
    Endif
else
	While (RHI->(RHI_FILIAL+RHI_MAT) == SRA->(RA_FILIAL+RA_MAT)) .And. lRet 
		/*	Nao calcular f�rias para funcion�rios com RA_SITFOLH  igual 'F',  ou 
			Ferias j� calculadas no mesmo per�odo/pago, e com situa��o diferente 1=Aberto(nao calculado), ou  de calculo de ferias coletivas*/

		If  (SRA->(RA_SITFOLH)=='F') .Or. ;
			((RHI->RHI_PERIOD == cPeriodo) .And. (RHI->RHI_NUMPAG == cNumPag) .And. (RHI->RHI_STATUS != '1')) .Or. ; 
			(!( (RHI->RHI_DTFIM < dDataKey) .Or. ( RHI->RHI_DTINI > dDtFimFer ) ))
			
			lRet:= .F.
			aAdd(aNCalcCol, {SRA->RA_MAT, SRA->RA_NOME} ) 
			Exit
		Endif
		RHI->(dbSkip())      
	End
EndIf

/*/
���������������������������������������������������������������������������Ŀ
� Verifica se o funcionario tem direito aos dias de ferias selecionados     �
�����������������������������������������������������������������������������*/ 
If lRet     
	CargaFerias(@aPerFerias, dDataKey)

	If !(len(aPerFerias) < 1)
		/*/
		������������������������������������������������������������������������Ŀ
		� Carrega dias proporcionais e vencidos de ferias, e desconta dias pagos �
		��������������������������������������������������������������������������*/     
		Aeval(aPerFerias,{|x| (nDFerVen += x[5], nDFerAVe += x[4], nDFerAdia += x[6], nDFerPag += x[7])})
		
		/*��������������������������������������������������������������������Ŀ
		//� Verifica se existem dias de ferias que ainda estao para descontar  �
		//����������������������������������������������������������������������*/
		For nAux:= 1 to len(aPerFerias)
			dDtBase:= aPerFerias[nAux, 1]
			dbSelectArea("RHJ")
			RHJ->(DbSetOrder( RetOrdem( "RHJ", "RHJ_FILIAL+RHJ_MAT+DTOS(RHJ_DTBASE)+DTOS(RHJ_DTINI)" ) ))
			RHJ->(dbGoTop())
			If (RHJ->(dbSeek(xFilial("RHJ")+SRA->RA_MAT+ DtoS(dDtBase))))
				While RHJ->(RHJ_FILIAL+RHJ_MAT+DtoS(RHJ_DTBASE)) == xFilial("RHJ")+SRA->RA_MAT+DtoS(dDtBase)
					If RHJ->RHJ_STATUS == 	"1" 
						nDiasADesc+= RHJ->RHJ_DIASPG
					Endif
					RHJ->(dbSkip())        	
				End
			Endif
		End
		
		If nDFerVen + nDFerAVe + nDFerAdia - nDiasADesc - nDFerPag < nDuracao
			lRet:= .F.
			aAdd(aNCalcCol, {SRA->RA_MAT, SRA->RA_NOME} )
		Endif
		
	Endif
Endif

Return(lRet)



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fCriaCabFer � Autor � Erika Kanamori        � Data � 28/07/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Cria cabecalho de ferias e itens de ferias para calculo       ���
���          �coletivo.                                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �fCriaCabFer()                                                 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Function fCriaCabFer()

Local aAreaRCH		:= RCH->( GetArea() )
Local nAux			:= 0
Local nDFerVen		:= 0                     
Local nDFerAVe		:= 0 
Local nDiasADesc	:= 0
Local nDiasPag		:= 0 
Local nDFerPag		:= 0 
Local nDiasFer		:= nDuracao
Local dDtBase		:= CtoD("//")
Local aPerFerias	:= {}
Local aAreaSR8		:= SR8->(GetArea())
Local cSequencia	:= ""      
Local cVrbDescVac	:= "" 
Local cTipoAfa		:= ""
Local cRot			:= fGetRotOrdinar()   //Obtendo qual roteiro de calculo de Folha de Pagamento
Local cProcesso		:= SRA->RA_PROCES
Local cPer			:= ""
Local cPago			:= ""
Local cSituac		:= "" 
Local cCondicao		:= "Empty(RCH_DTFECH) .AND. RCH_STATUS $ '0 ' .AND. RCH_ROTEIRO $ '" + cRot + "' .AND. RCH_PROCES == '" + cProcesso + "' "      

CargaFerias(@aPerFerias, dDataKey)

If !(len(aPerFerias) < 1)         
	/*�����������������������������������������������������������������������Ŀ
	//� Carrega dias de ferias vencidas e proporcionais e desconta dias pagos.�
	//�������������������������������������������������������������������������*/
   	Aeval(aPerFerias,{|x| (nDFerVen += x[5], nDFerAVe += x[4], nDFerPag += x[7])})
	If nDFerVen > nDFerPag
		nDFerVen:= nDFerVen - nDFerPag
	Else
		nDFerVen:= 0
		nDFerPag:= nDFerPag - nDFerVen
		nDFerAVe:= Max(nDFerAVe - nDFerPag, 0)
	Endif
		
	/*�����������������������������Ŀ
	//� Cria cabecalhos de ferias 	�
	//�������������������������������*/
	dbSelectArea("RHI")
	RecLock( "RHI" , .T.)
		RHI_FILIAL	:= SRA->RA_FILIAL
		RHI_MAT		:= SRA->RA_MAT	  
		RHI_DTINI	:= dDataKey
		RHI_DFERIA	:= nDuracao	
		RHI_DTFIM	:= dDtFimFer
		RHI_DFERVE	:= nDFerVen	
		RHI_DFERPR  := nDFerAVe
		RHI_DTPAGO	:= dDtPagFer
		RHI_PROCES	:= SRA->RA_PROCES   
		RHI_ROTEIR	:= cRoteiro
		RHI_PERIOD	:= cPeriodo
		RHI_NUMPAG	:= cNumPag
		RHI_TPCALC	:= "2"
	RHI->(MsUnlock())
	
	dbSelectArea("RHJ")
	RHJ->(DbSetOrder( RetOrdem( "RHJ", "RHJ_FILIAL+RHJ_MAT+DTOS(RHJ_DTBASE)+DTOS(RHJ_DTINI)" ) ))
	For nAux:= 1 to len(aPerFerias)
		/*��������������������������������������������������������������������Ŀ
		//� Verifica se existem dias de ferias que ainda estao para descontar  �
		//����������������������������������������������������������������������*/  
		dDtBase:= aPerFerias[nAux, 1]
		RHJ->(dbGoTop())
		If (RHJ->(dbSeek(xFilial("RHJ")+SRA->RA_MAT+ DtoS(dDtBase))))
			While RHJ->(RHJ_FILIAL+RHJ_MAT+DtoS(RHJ_DTBASE)) == xFilial("RHJ")+SRA->RA_MAT+DtoS(dDtBase)
				If RHJ->RHJ_STATUS == 	"1" .And. RHJ->RHJ_DTINI <> RHI->RHI_DTINI
					nDiasADesc+= RHJ->RHJ_DIASPG
				Endif
				RHJ->(dbSkip())        	
			End
		Endif
		
		/*��������������������������������������������������������������������Ŀ
		//� Calcula dias de ferias a descontar de cada periodo aquisitivo	   �
		//����������������������������������������������������������������������*/
	    nDiasPag:= aPerFerias[nAux,4] + aPerFerias[nAux,5] + aPerFerias[nAux, 6] - aPerFerias[nAux,7] - nDiasADesc
	    
	    If nDiasPag > nDiasFer
	    	nDiasPag:= nDiasFer
	    Endif
	    
	    nDiasFer:= nDiasFer - nDiasPag	    
        
		/*�����������������������������Ŀ
		//� Cria itens de ferias 		�
		//�������������������������������*/
		RecLock( "RHJ" , .T.)       
			RHJ_FILIAL	:= SRA->RA_FILIAL
			RHJ_MAT		:= SRA->RA_MAT   
			RHJ_DTINI	:= dDataKey 
			RHJ_DTBASE 	:= dDtBase  
			RHJ_DTFIM	:= aPerFerias[nAux, 2]          
			RHJ_DIASDI	:= aPerFerias[nAux, 3]
			RHJ_DFERAA	:= aPerFerias[nAux, 4]
			RHJ_DFERVA  := aPerFerias[nAux, 5]
			RHJ_DIASAN  := aPerFerias[nAux, 6]
			RHJ_DFERAN	:= aPerFerias[nAux, 7]
			RHJ_DIASPG	:= nDiasPag
			RHJ_STATUS	:= "1"	
		RHJ->(MsUnlock())
	End	
    
    
    /*��������������������������������������������������������������������Ŀ
	//� Cria registro referente a ferias lancadas em ausencias             �
	//����������������������������������������������������������������������*/
	cVrbDescVac:= If(!Empty(fGetCodFol("0786")), fGetCodFol("0786"), fGetCodFol("072")) 
	cTipoAfa:= gp240RetCont("RCM", RetOrdem( "RCM", "RCM_FILIAL+RCM_PD" ), xFilial("RCM") + cVrbDescVac, "RCM_TIPO")
	If cPaisLoc =="ARG"
		cSituac	:= RCM->RCM_SITUAC	
	EndIf

	dbSelectArea("SR8")
	SR8->(DbSetOrder( RetOrdem( "SR8", "R8_FILIAL+R8_MAT+R8_SEQ" ) ))
	If SR8->(dbSeek(xFilial("SR8")+SRA->RA_MAT))
		While SR8->(R8_FILIAL+R8_MAT) == xFilial("SR8")+SRA->RA_MAT
			cSequencia:= SR8->R8_SEQ
			SR8->(dbSkip())
		End
		cSequencia:= StrZero(Val(cSequencia) + 1, 3)	
	Else
		cSequencia:= "001"
	Endif
	

	//Obtencao Periodo e Pago, a partir do primeiro roteiro em aberto de Folha
	dbSelectArea("RCH")
	("RCH")->(dbSetOrder(5))
	("RCH")-> (DBSETFILTER( {||&cCondicao}, cCondicao))
	("RCH")->(dbGoTop())
	If ("RCH")->(EOF())
		lRet:=	.F.
	Else  
		cPer	:= RCH->RCH_PER//gp240RetCont("RCH",5,cFilRCH+cProcesso+cRot,"RCH_PER","Empty(RCH->RCH_DTFECH) .AND. (RCH->RCH_PROCES == '" + cProcesso + "')")	
	  	cPago	:= RCH->RCH_NUMPAG
	EndIf
		
	("RCH")->(DbClearFilter())
	
	RestArea( aAreaRCH )

	RecLock("SR8", .T.)
		SR8->R8_FILIAL	:= xFilial("SR8")
		SR8->R8_MAT		:= SRA->RA_MAT
		SR8->R8_SEQ		:= cSequencia
		SR8->R8_DATA	:= Date()
		SR8->R8_TIPOAFA	:= cTipoAfa
		SR8->R8_PD		:= cVrbDescVac
		SR8->R8_DATAINI	:= dDataKey
		SR8->R8_DURACAO	:= nDuracao
		SR8->R8_DATAFIM	:= dDtFimFer
		SR8->R8_DIASEMP := 999
		SR8->R8_DPAGAR	:= nDuracao
		SR8->R8_CONTINU	:= "2"
		SR8->R8_DNAPLIC	:= 0
		SR8->R8_DPAGOS	:= 0
		SR8->R8_PER		:= cPer
		SR8->R8_NUMPAGO	:= cPago
		SR8->R8_NUMID	:= "SR8" + SRA->RA_MAT + cVrbDescVac + Dtos(dDataKey)
		SR8->R8_SDPAGAR	:= nDuracao
		SR8->R8_PROCES	:= SRA->RA_PROCES
		If (cPaisLoc == "ARG"  .And. cSituac <> "")
			SR8->R8_SITUAC	:= cSituac		
		EndIf
	SR8->(MsUnlock())
	
Endif
                    
Return()


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Erika Kanamori        � Data � 07/07/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Menu Funcional                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MenuDef()                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/ 
Static Function MenuDef()
                                                                               	
Local aRotina := {}  

ADD OPTION aRotina Title OemToAnsi(STR0026)  Action 'GPEM032()' OPERATION 6 ACCESS 0   //"Ferias Coletivas" 
	
Return aRotina
    


