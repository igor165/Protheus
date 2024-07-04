#include "Protheus.ch"
#include "CSAA100.CH"
#include "fwadaptereai.ch"

/*/                                                  									
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Fun��o    � CSAA100    �Autor  � Cristina Ogura        � Data � 25/07/2001  ���
������������������������������������������������������������������������������Ĺ��
���Descri��o � Cadastramento dos Departamentos de uma empresa                  ���
������������������������������������������������������������������������������Ĺ��
���Parametros� Nenhum                                                          ���
������������������������������������������������������������������������������Ĺ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ĺ��
���Programador � Data     � BOPS �  Motivo da Alteracao                        ���
������������������������������������������������������������������������������Ĺ��
���Cecilia Car.�07/07/2014�TPZVTW�Incluido o fonte da 11 para a 12 e efetuada  ���
���            �          �      �a limpeza.                                   ���
���Marcos Perei�03/09/2015�PCREQ-�Produtizacao projeto Gest�o P�blica na 12.   ���
���            �          �5342  �                                             ���
���Renan Borges�05/02/2016�TUGHE3�Cria��o do ponto de entrada CSAA100VLD para  ���
���     	   �          �      �que seja possivel realizar valida��es customi���
���     	   �          �      �zadas nos dados do cadastro.                 ���
���Eduardo K.M.�21/06/2016�TVFKXG�Cria��o das fun��es CrgKeyini e VldDepSup    ���
���     	   �          �  	 �para que tratar altera��o e exclus�o de 	   ���
���     	   �          �      �departamentos que possuam solicita��es  	   ���
���     	   �          �      �em aberto e carga dp campo QB_KEYINI    	   ���
���Raquel H.   �29/06/2016�TVFOB3�Ajuste p/ consulta padrao da matricula       ���
���     	   �          �      �responsavel 							       ���
���P. Pompeu..�21/09/2016�TVTZYD�Criacao da funcao CCDescSQB....................��
���Flavio C.  �10/11/2016�TWMG32�Corre��o fun��o VldDepSup para tratar alias   ���
���Joao Balbino�20/12/2016�MPRIMESP-264�Ajuste na valida��o do departamento na ���
���     	   �          �      �estrutra de aprova��o por dp				   ���
���Joao Balbino�14/06/2017�MPRIMESP10300�Ajuste na valida��o do repons�vel do  ���
���     	   �          �      �departamento quando SQB for exclusiva.       ���
���M. Silveira �20/06/2017�DRHPON|Ajuste na funcao fEstrutDepto() p/ nao gerar ���
��� 		   �		  �TP-843|o codigo QB_KEYINI em duplicidade.           ���
���Leonardo M. �27/09/2017�MPRIMESP� Ajuste para permitir alterar resp. do     ���
���     	   �          �-10149  � departamento quando o mesmo n�o tem       ���
���     	   �          �        � solicita��es pendentes.			       ���		
���Wesley Alves�20/08/2020�DRHGCH-20762�Envio de dados para gravar na RJP      ���
���Pereira.    �          �            �quando houver altera��o de registros.  ���
�������������������������������������������������������������������������������ٱ�                
���������������������������������������������������������������������������������� 
���������������������������������������������������������������������������������
/*/
/*
Usar essa documenta��o quando inclui o fonte em alguma pasta de inova��o, por exemplo
12.1.6, a cada merge com o fonte da sustenta��o atualizar as informa��es abaixo para 
que no merge final fique facil a atualiza��o do fonte
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    07/07/2015        �  313629   ���
���    03/08/2015        �  319747   ��� 
�������������������������������������ͱ�
*/

Function CSAA100(nOpcAuto , aRotinaNew, aRotAuto, nOpc )
	Local cFiltra			//Variavel para filtro
	Local aIndFil	:= {}	//Variavel Para Filtro
	Local nPos
	Local nX

	Private aSQBVirtual := {}
	Private aSQBVisual  := {}
	Private aSQBHeader  := {}
	Private aSQBFields  := {}
	Private aSQBAltera  := {}
	Private aSQBNotAlt  := {}

	Private lGestPubl	:= if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.) //Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
	               
	Private bFiltraBrw := {|| Nil}		//Variavel para Filtro
	Private cCadastro  := ""
	Private aRotina    := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
	
	Private lExecAuto  	:= ( aRotAuto <> Nil  .And. nOpc <> Nil )
	Private cBkpFilAnt    := cFilAnt
	Private lOrgCfg		:= SuperGetMv("MV_ORGCFG",,"0") == "0"	
	
	If lGestPubl
		cCadastro  := OemToAnsi(STR0038)	//"Lota��es"	
	Else
		cCadastro  := OemToAnsi(STR0001)	//"Departamento"	
	Endif
	If SQB->(ColumnPos('QB_KEYINI')) > 0 	
		CrgKeyini()// Faz carga incial do campo QB_KEYINI
	EndIf	
	
   	If ( nPos := Ascan(aRotina,{|x| Upper(x[2])=="CSA100ATU"}) ) > 0
    	aDel(aRotina , nPos)
		aSize(aRotina,Len(aRotina)-1)
   EndIf
   //������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro utilizando a funcao FilBrowse                      �
	//��������������������������������������������������������������������������
	dbSelectArea("SQB")
	dbSetOrder(1)
	dbGotop()

If lExecAuto
	nPos := aScan(aRotAuto, {|x| x[1] == "QB_FILIAL" })
	If nPos > 0
		M->QB_FILIAL := CriaVar( "QB_FILIAL" )
		M->QB_FILIAL := aRotAuto[ nPos ][2]
		aAdd( aSQBFields , "QB_FILIAL" )
	EndIf

	aSQBHeader := SQB->( GdMontaHeader( NIL , @aSQBVirtual , @aSQBVisual , NIL , {"SQB_FILIAL"}, , .T. ) )

	For nX := 1 To Len( aSQBHeader )
		//If ( nOpc == 3 .OR. nOpc == 4 )
			nPos := aScan(aRotAuto, {|x| x[1] == aSQBHeader[ nX ][ 02 ] })
			If nPos > 0
				&( "M->"+aSQBHeader[ nX , 02 ] ) := CriaVar( aSQBHeader[ nX , 02 ] )
				&( "M->"+aSQBHeader[ nX , 02 ] ) := aRotAuto[ nPos ][2]
				aAdd( aSQBFields , aSQBHeader[ nX , 02 ] )
			EndIf
		//ElseIf ( nOpc == 5 )
		//EndIf
	Next nX

	SQB->(DBSEEK(M->QB_FILIAL + M->QB_DEPTO))

	MBrowseAuto(nOpc,aRotAuto,"SQB", .F.)
Else	
	cFiltra 	:= CHKRH(FunName(),"SQB","1")	
	bFiltraBrw	:= {|| FilBrowse("SQB",@aIndFil,@cFiltra) }

	Eval(bFiltraBrw)

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	dbSelectArea("SQB")
	dbGoTop()
	
	MBrowse(6, 1,22,75,"SQB")
	         
	//������������������������������������������������������������������������Ŀ
	//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
	//��������������������������������������������������������������������������	
	EndFilBrw("SQB",aIndFil)
	
EndIf
	cFilAnt := cBkpFilAnt
	
	dbSelectArea("SQB")
	dbSetOrder(1)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Csa100Rot � Autor � Cristina Ogura       � Data � 25.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Opcao de exclusao dos departamentos                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAa100       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CSA100Rot(cAlias, nReg, nOpc)
	Local lConfirma
	//Local aAC:= { STR0007,STR0008 } 	//"Abandona"###"Confirma"
	Local lAchou :=.F.
	Local aPosEnch:={}
	Local aAreaSQB := {}
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjCoords 	:= {}
	Local aObjSize		:= {}	
	Local nLenSX8  		:= GetSX8Len()
	Private oEnSQB 
	
If lExecAuto
	aAreaSQB := getArea()
	lConfirma := .T.
Else 
	/*
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords ) 
	
	//��������������������������������������������������������������Ŀ
	//� Monta a entrada de dados do arquivo                          �
	//����������������������������������������������������������������
	Private aTELA[0][0],aGETS[0]
	
	dbSelectArea(cAlias)
	dbSetOrder(1)
	
	RegToMemory(cAlias, (nOpc == 3))

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
                 
	oEnSQB	:= MsmGet():New(	cAlias		,;
								nReg		,;
								nOpc		,;
								NIL			,;
								NIL			,;
								NIL			,;
								NIL,; //aRdmFields	,;
								aObjSize[1],;
								NIL,; //aRdmAltera	,;
								NIL			,;
								NIL			,;
								NIL			,;
								oDlg		,;
								NIL			,;
								.F.			,;
								NIL			,;
								.F.			 ;
							)
	
	//Grava a area corrente para o possivel desposicionamento
	//que ocorre atraves da consulta padrao SQB, no campo Dep. Superior
	aAreaSQB := getArea()
	
	If SQB->(ColumnPos('QB_KEYINI')) > 0 	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(oEnSQB:aGets, oEnSQB:aTela) .AND. Csa100VldPE() .AND. !ExistKeySqb() .AND. ValFilMat() .And. VldDepSup() .And. RespDepto(), (oDlg:End(), lConfirma := .T.), NIL)}, {|| lConfirma := .F., oDlg:End()}) 
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(oEnSQB:aGets, oEnSQB:aTela) .AND. Csa100VldPE() .AND. !ExistKeySqb() .AND. ValFilMat(), (oDlg:End(), lConfirma := .T.), NIL)}, {|| lConfirma := .F., oDlg:End()}) 
	Endif

EndIf

	If lConfirma == .T.   
	    //Restaura a area corrente eliminando o problema de desposicionamento
	    //por consulta padrao
		restArea(aAreaSqb) 
		
		If nOpc == 5
			Cs100Dele(cAlias, nReg, nOpc)
		Else 
			Cs100Grava(nOpc)
		Endif
		If SuperGetMV( "MV_MDTGPE" , .F. , "N" ) == "S" .And. nOpc == 3 .And. FindFunction("MDTW030")
			MDTW030( "SQB" , M->QB_DEPTO ) //Executa o W.F. de Aviso do SESMT
		EndIf
	Else
		//Acionou o botao cancelar apos ter solicitado uma inclusao
		If __lSX8
			While ( GetSX8Len() > nLenSX8 )
				RollBackSX8()
			EndDo
		EndIf	  
	EndIf
	
Return                    
                           

/*Static Function BtnOkClick
	Local lTudoOk := EnchoTudOk( oEndRd0 )
Return 
*/


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs100Grava� Autor � Cristina Ogura        � Data � 25.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava todos os registros referentes ao departamento         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Cs100Grava                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Cs100Grava(nOpcX)
	Local nCount
	Local nX
	Local nPos
    Local aDeptos
	Local aDadosAuto 	:= {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
    Local cNewDepto 	:= ""
    Local cIniOld		:= ""
    Local cDepSupAnt	:= SQB->QB_DEPSUP
	Local cKey			:= ""
	Local cAliasTmp		:= GetNextAlias()
	Local lKeyIni 		:= SQB->(ColumnPos('QB_KEYINI'))>0 
    Local lIntegDef  	:= FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CSAA100",.T.,,.T.)
	Local lTsaDep	 	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )
	Local lTSREP	 	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
	Local lProcessa		:= .F.
	Local lVdfQbCC		:= (GetMv( "MV_VDFQBCC",, "1" ) == "1")
	Local nLen			:= 0

	Local lProcNG		:= .F. // verifica se processa a integra��o NG

	Private lMsHelpAuto := .f.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .f.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

	IF EMPTY(M->QB_CC) .AND. lGestPubl .AND. lVdfQbCC
		lProcessa := MsgYesNo("O centro de custo n�o foi informado. Deseja vincular ao centro de custo " + alltrim(M->QB_DEPTO) + " automaticamente? ") 
	Else	
		lProcessa := .T.
	EndIf
	
	IF SuperGetMv("MV_RHNG",.F. ,.F.)
		If nOpcx == 4 .AND. (M->QB_DEPTO <> SQB->QB_DEPTO .or. M->QB_DESCRIC <> SQB->QB_DESCRIC)
			lProcNG := .T.
		ELSEIF nOpcx <> 4
			lProcNG := .T.
		ENDIF
	ENDIF
	
	If lProcessa	
		ConfirmSX8()
		If nOpcx == 3 .OR. nOpcx == 4
			RecLock("SQB", Iif(nOpcx == 3, .T., .F.))
			
			For nCount := 1 To SQB->(FCount()) 
				//Grava o campo filial 'manualmente' para quando a tabela estiver
				//exclusiva, a filial seja gravada corretamente
				If ( FieldName(nCount) == "QB_FILIAL" ) 
					SQB->QB_FILIAL := xFilial("SQB")
				Else
					If lExecAuto
						nPos := aScan(aSQBFields, {|x| x ==  FieldName(nCount) })
						If nPos > 0					
							SQB->(FieldPut(nCount, &( "M->"+aSQBFields[ nPos ] )))
						EndIf
					Else
						SQB->(FieldPut(nCount, GetMemVar( FieldName(nCount) )))
					EndIf
				EndIf
			Next nCount
			
			MsUnlock() 
		EndIf
		If SQB->(ColumnPos('QB_KEYINI')) > 0 .And. (nOpcx == 3 .Or. (nOpcx == 4 .And. cDepSupAnt <> SQB->QB_DEPSUP) .Or. Empty(SQB->QB_KEYINI))
			cIniOld := Alltrim(SQB->QB_KEYINI)
			
			If !Empty(SQB->QB_DEPSUP)
				cKey := FGetKeyIni(SQB->QB_FILIAL+SQB->QB_DEPSUP)
				nChave := 1		 	
				BeginSql alias cAliasTmp
					SELECT MAX(QB_KEYINI) AS KEYINI FROM %table:SQB% SQB WHERE
					SQB.%NotDel%
					AND SQB.QB_FILIAL = %exp:SQB->QB_FILIAL%
					AND SUBSTRING(SQB.QB_KEYINI,1,%exp:LEN(ALLTRIM(CKEY))%) = %exp:alltrim(cKey)% 
				EndSql
				If !(cAliasTmp)->(Eof())
					If Len(alltrim((cAliasTmp)->KEYINI)) == Len(alltrim(cKey))
						nChave := 1
					Else
						nChave := val(substr(alltrim((cAliasTmp)->KEYINI),Len(alltrim(cKey))+1,3))+1
					EndIf
				EndIf
				(cAliasTmp)->(dbCloseArea())
				
				cKey := Alltrim(cKey) + StrZero(nChave, 3)
				
				RecLock("SQB", .F.)
					SQB->QB_KEYINI :=  cKey
				MsUnlock()
				
				fTrocaKey(cIniOld, SQB->QB_DEPTO,SQB->QB_FILIAL)
			Else
				nChave := 1
				BeginSql alias cAliasTmp
					SELECT MAX(QB_KEYINI) AS KEYINI FROM %table:SQB% SQB WHERE
					SQB.QB_DEPSUP = %Exp:Space(GetSx3Cache("QB_DEPSUP", "X3_TAMANHO"))% AND
					SQB.%NotDel%
					AND SQB.QB_KEYINI <> '' 
				EndSql
				
				nLen := IIF(len(alltrim((cAliasTmp)->KEYINI)) >= 3, len(alltrim((cAliasTmp)->KEYINI)), 3)
				If !(cAliasTmp)->(Eof())
					nChave := val(substr(alltrim((cAliasTmp)->KEYINI), 1, nLen)) + 1
				EndIf
				(cAliasTmp)->(dbCloseArea())
				
				nLen := IIF(len(cValToChar(nChave)) >= 3, len(cValToChar(nChave)), 3)
				RecLock("SQB", .F.)
					SQB->QB_KEYINI :=   StrZero(nChave,nLen)
				MsUnlock()
				
				fTrocaKey(cIniOld, SQB->QB_DEPTO,SQB->QB_FILIAL) 
			EndIf
			CrgKeyini(.T., cIniOld)
		EndIf
		//-- Inicializa a integracao via WebServices TSA
		If lTSREP .AND. lTsaDep
			oObjREP := PTSREPOBJ():New()
			
			//Executa o WebServices TSA - Centro de Custo
			If oObjREP:WSAllocation( 3 )
				
				//Grava o Log do controle de exportacao WebServices TSA
				oObjRep:WSUpdRHExp( "SQB" )
				
			Endif
		EndIF
		
		If lIntegDef
			// chamada da fun��o integdef
			FwIntegDef('CSAA100')
		EndIf
		
		UpdRD4Desc(cEmpAnt, SQB->QB_FILIAL, SQB->QB_DEPTO, SQB->QB_DESCRIC, "1")
		ConfirmSX8()
		
		if lProcNG
			fPrepDadosApi(nOpcx)
		Endif
		
		If lGestPubl .And.; 						// Gestao de Folha Publica
			lVdfQbCC    	// Indica se o Cadastro de Centro de Custo CTT ser� 1x1 com o Departamento SQB (1-Sim;2-N�o).
			
			If (nOpcx == 3 .or. nOpcX == 4) .and. empty(SQB->QB_CC)
					CTT->(DBSETORDER(1))
					IF !CTT->(dbSeek(xFilial("CTT") + SQB->QB_DEPTO))  
						aDadosAuto:= {	{'CTT_CUSTO' , SQB->QB_DEPTO     , Nil},;	// Especifica qual o C�digo do Centro de Custo.
										{'CTT_CLASSE', "2"			     , Nil},;	// Especifica a classe do Centro de Custo, 
										{'CTT_NORMAL', "2"			     , Nil},;	// 1-Receita ; 2-Despesa                                       
										{'CTT_DESC01', SQB->QB_DESCRIC   , Nil},;	// Indica a Nomenclatura do Centro de Custo
										{'CTT_DTEXIS', CTOD("01/01/1980"), Nil}}	// Especifica qual a Data de In�cio de Exist�ncia para CC
									
						MSExecAuto({|x, y| CTBA030(x, y)},aDadosAuto, 3)
						If lMsErroAuto	
							MostraErro()
						EndIf					
					Endif
					RecLock("SQB", .F.)
						SQB->QB_CC := SQB->QB_DEPTO
					MSUNLOCK()
			Endif
			
		Endif
		
		// ---------------------------------------------------------------------------------
		// Alterado por Cleverson Ernesto Silva - em 31/05/2015
		// -
		// Adicionado chamada da funcao At202AtSup para atualizar o cadastro
		// TECA202 - Area de Supervisao automaticamente nas Alteracoes do
		// cadastro de departamento
		// ---------------------------------------------------------------------------------
		If FindFunction("At202AtSup") .AND. ( nOpcx == 3 .OR. nOpcx == 4 )
			At202AtSup (SQB->QB_DEPTO, SQB->QB_FILRESP , SQB->QB_MATRESP )
		EndIf
	Else	
		RollBackSX8()
	ENDIF
	
Return

/*/{Protheus.doc} FGetKeyIni
//Busca KeyIni de um departamento
@author flavio.scorrea
@since 14/08/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function FGetKeyIni(cChave)
Local aArea	:= GetArea()
Local cKey 	:= ""
dbSelectArea("SQB")
SQB->(dbSetOrder(1))
If SQB->(dbSeek(cChave))
	cKey := SQB->QB_KEYINI
EndIf
RestArea(aArea)
Return cKey

/*/{Protheus.doc} fTrocaKey
//Troca chave de departamentos filhos
@author flavio.scorrea
@since 14/08/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrocaKey(cIniOld, cDepto,cFilDepto) 
Local aArea		:= GetArea()
Local cAliasTmp	:= GetNextAlias()			
Local cKeyOld	:= ""
Local aDeptos	:={}
Local nCont		:= 0

If Empty(cIniOld)
	return
EndIf

BeginSql alias cAliasTmp
	SELECT * FROM  %table:SQB% SQB WHERE
	SQB.%NotDel%
	AND SQB.QB_FILIAL = %exp:cFilDepto%
	AND SUBSTRING(SQB.QB_KEYINI,1,%exp:Len(cIniOld)% ) = %exp:cIniOld% 
	AND SQB.QB_DEPTO <> %exp:cDepto% 
EndSql

While !(cAliasTmp)->(Eof())
	
	dbSelectArea("SQB")
	SQB->(dbSetOrder(1))
	If SQB->(dbSeek((cAliasTmp)->QB_FILIAL+(cAliasTmp)->QB_DEPTO))
		RecLock("SQB", .F.)
			SQB->QB_KEYINI :=  ""//aDeptos [nCont,5]
		MsUnlock()
	EndIf
		
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

RestArea(aArea)
Return

//
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs100Dele � Autor � Cristina Ogura        � Data � 25.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Deleta todos os registros referentes ao departamento        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Cs100Dele                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Cs100Dele(cAlias, nReg, nOpc)
	
	Local cIndCond	:= ""
	Local cArqNtx	:= ""
	Local c2IndCond	:= ""
	Local c2ArqNtx	:= ""
	Local n2Index	:= 0
	Local cDepto	:= SQB->QB_DEPTO
	Local aSQBarea	:= SQB->(GetArea())
	Local lRet		:= .T.
	Local lSQ3		:= .F.
	Local lTsaDep	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )
	Local lTSREP	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
	Local oObjREP
    
    Local lIntegDef  :=  FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CSAA100",.T.,,.T.)
	
		//-- Verifica se o departamento esta em alguma visao 
	IF 	( lRet:= fDelDeptoVisao( xFilial('SQB'), cDepto ) )

	   	//-- Verifica delecao atrav�s do SX9
	   	lRet:=  csaa100ChkDel( cAlias , nReg , nOpc, cDepto )
	   	
	   	// CHAMA O PE AP�S A VALIDA��O DA SX9.
	   	If lRet
	   		lRet := CsaPosVldX9()
	   	Endif

   		// CASO O lRet N�O SEJA .T. N�O HA NECESSIDADE DE EXECUTAR O BLOCO ABAIXO.
   		If lRet
	   		//-- se permitiu a delecao atrav�s do SX9, tenta as relacoes especiais do SQB
			//# Verifica se existe algum Depto Superior com este codigo de avaliacao
			c2IndCond	:= "SQB->QB_FILIAL+SQB->QB_DEPSUP"		
			c2ArqNtx  	:= CriaTrab(NIL,.F.)
			IndRegua("SQB", c2ArqNtx, c2IndCond,,, STR0010)		// "Selecionando Registros..."	
			n2Index		:= RetIndex("SQB")
			
			dbSetOrder(n2Index + 1)               
			If dbSeek(xFilial("SQB") + cDepto)
				Help("", 1, "CS100NPODE")		// Nao posso excluir este departamento pois existem cargso ligados a ele"
				lRet := .F.
			EndIf
			
			//# Restaura indices e apaga arquivo temporario
			dbSelectArea("SQB")
			Set Filter To
			RetIndex("SQB")
			dbSetOrder(1)
			FErase (c2ArqNtx + OrdBagExt())
			
			RestArea(aSQBarea)
		EndIf
		
		If lRet
			// Verifica se existe algum calendario/curso com este codigo de avaliacao
			dbSelectArea("SQ3")
			dbSetOrder(1)
			
			cIndCond	:= "SQ3->Q3_FILIAL+SQ3->Q3_DEPTO"		
			cArqNtx  	:= CriaTrab(NIL,.F.)
			IndRegua("SQ3", cArqNtx, cIndCond,,, STR0010)		// "Selecionando Registros..."	
			nIndex		:= RetIndex("SQ3")
			
			dbSetOrder(nIndex + 1)               
			If dbSeek(xFilial("SQ3") + SQB->QB_DEPTO)
				Help("", 1, "CS100NPODE")		// Nao posso excluir este departamento pois existem cargso ligados a ele"
				lRet := .F.
			EndIf
			
			lSQ3 := .T.
		EndIf
		
		If lRet
			Begin Transaction
				dbSelectArea("SQB")
				dbSetOrder(1)
				If dbSeek(xFilial("SQB") + SQB->QB_DEPTO)
					RecLock("SQB", .F., .T.)
					dbDelete()
					WriteSx2("SQB")
				EndIf	         
			End Transaction
		EndIf

		If lTSREP .AND. lTsaDep
			oObjREP := PTSREPOBJ():New()

			//Executa o WebServices TSA - Centro de Custo
			oObjREP:WSAllocation( 5 )
		EndIF
        
        If lIntegDef
			// chamada da fun��o integdef
			FwIntegDef('CSAA100')
		EndIf

		if SuperGetMv("MV_RHNG",.F. ,.F.)
			fPrepDadosApi(nOpc)
		Endif

		If lSQ3
			//# Restaura indices e apaga arquivo temporario
			dbSelectArea("SQ3")
			Set Filter To
			RetIndex("SQ3")
			dbSetOrder(1)
			FErase (cArqNtx + OrdBagExt())
		EndIf  
		
		dbSelectArea("SQB")
		dbSetOrder(1)
  		Else
    	Help("", 1, "CS100DEP")		// Nao posso excluir este departamento pois ele consta em outra tabela"
    Endif
    
Return Nil

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �csaa100ChkDel   �Autor�Mauricio MR		  � Data �12/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verificar se o Depto Pode ser Deletado  					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Firmais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA100                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Firmais >									�
�������������������������������������������������������������������������*/
Static Function csaa100ChkDel( cAlias , nReg , nOpc, cDepto )

Local aArea		:= GetArea()
Local aAreas	:= {}
Local cFilSQB	:= xFilial( "SQB" )
Local lDelOk	:= .T.

//RCL
aAdd( aAreas , Array( 03 ) )
nAreas := Len( aAreas )
aAreas[nAreas,01] := RCL->( GetArea() )
aAreas[nAreas,02] := Array( 2 )
				aAreas[nAreas,02,01] := "RCL_FILIAL"
				aAreas[nAreas,02,02] := "RCL_DEPTO"
aAreas[nAreas,03] := RetOrdem( "RCL" , "RCL_FILIAL+RCL_DEPTO+RCL_POSTO" , .T. )


( cAlias )->( MsGoto( nReg ) )

lDelOk := ChkDelRegs(	cAlias			,;	//01 -> Alias do Arquivo Principal
						nReg			,;	//02 -> Registro do Arquivo Principal
						nOpc			,;	//03 -> Opcao para a AxDeleta
						cFilSQB		,;	//04 -> Filial do Arquivo principal para Delecao
						cDepto			,;	//05 -> Chave do Arquivo Principal para Delecao
						aAreas			,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
						NIL 			,;	//07 -> Mensagem para MsgYesNo
						NIL				,;	//08 -> Titulo do Log de Delecao
						NIL				,;	//09 -> Mensagem para o corpo do Log
						.F.				,;	//10 -> Se executa AxDeleta
						.T.				,;	//11 -> Se deve Mostrar o Log
						NIL				,;	//12 -> Array com o Log de Exclusao
						NIL				,;	//13 -> Array com o Titulo do Log
						NIL				,;	//14 -> Bloco para Posicionamento no Arquivo
						NIL				,;	//15 -> Bloco para a Condicao While
						NIL				,;	//16 -> Bloco para Skip/Loop no While
						NIL				,;	//17 -> Verifica os Relacionamentos no SX9
						NIL				,;	//18 -> Alias que nao deverao ser Verificados no SX9
						NIL				,;	//19 -> Se faz uma checagem soft
						lExecAuto       ;  //20 -> Se esta executando rotina automatica
					)


RestArea( aArea )

Return( lDelOk )


/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �fDelDeptoVisao  �Autor�Mauricio MR		  � Data �12/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verificar se o Depto Pode ser Deletado  					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Firmais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA100                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Firmais >									�
�������������������������������������������������������������������������*/
Static Function fDelDeptoVisao( cFil, cDepto )

Local aSaveArea	:= GetArea() 

Local cTipVis	:= "%RDK.RDK_HIERAR = '1' %" 
Local cQryRDK	:= ''
Local cBranco	:= ''

Local lNaoTemDepto := .T.
Local cOrdem	:= "RDK_FILIAL+RDK_HIERAR+RDK_TIPO+RDK_CODIGO"
Local nOrdem	:= 0	

nOrdem			:= RetOrdem(cOrdem)	
cOrdem	:= "%"+ cOrdem + "%"
cFilVisao  := xFilial( "RDK" , cFil )   

cOrdem	:= "%RDK_FILIAL+RDK_HIERAR+RDK_TIPO+RDK_CODIGO%"
				
cQryRDK := GetNextAlias()
    
BeginSql alias cQryRDK
	
	SELECT 	COUNT(*) AS QTDEDEPTO 
	FROM %table:RDK% RDK
	INNER JOIN %table:RD4% RD4
	ON	RD4_EMPIDE = %exp:cEmpAnt%
		AND	RD4_CODIDE = %exp:cDepto%
		AND	( RD4_FILIDE = %exp:cFil% OR  RD4_FILIDE = %exp:cBranco% ) 
		AND	RD4_CODIDE = %exp:cDepto%
	WHERE                         
		RDK_FILIAL = %exp:cFilVisao%
		AND %exp:cTipVis%
		AND RDK.%NotDel%
		AND RD4.%NotDel% 

EndSql

lNaoTemDepto:=Empty( (cQryRDK)->(QTDEDEPTO) )
(cQryRDK)->(DbCloseArea())

RestArea(aSaveArea)

Return( lNaoTemDepto )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �28/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA100                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   
Static Function MenuDef()
	//��������������������������������������������������������������Ŀ
	//� Define Array contendo as Rotinas a executar do programa      �
	//� ----------- Elementos contidos por dimensao ------------     �
	//� 1. Nome a aparecer no cabecalho                              �
	//� 2. Nome da Rotina associada                                  �
	//� 3. Usado pela rotina                                         �
	//� 4. Tipo de Transa��o a ser efetuada                          �
	//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
	//�    2 - Simplesmente Mostra os Campos                         �
	//�    3 - Inclui registros no Bancos de Dados                   �
	//�    4 - Altera o registro corrente                            �
	//�    5 - Remove o registro corrente do Banco de Dados          �
	//�    6 - Alteracao sem inclusao de registro                    �
	//����������������������������������������������������������������
	Local aRotina :=    { 	{ STR0002, "PesqBrw"	, 0, 1, NIL, .F.},;	//"Pesquisar"
							{ STR0003, "AxVisual"	, 0, 2},; 				//"Visualizar"
							{ STR0004, "Csa100Rot"	, 0, 3},; 				//"Incluir"
							{ STR0005, "Csa100Rot"	, 0, 4},; 				//"Alterar"
							{ STR0006, "Csa100Rot"	, 0, 5},;				//"Excluir"
    						{ STR0015, "Csa100Atu"	, 0, 4} }				//"Atualizar Visoes"
    						
    						
    Local aRet 	:= {}
    Local nX	:= 0
    
	//Ponto de Entrada para inclus�o de itens no menu
	If ExistBlock("CSA100MEN")
		aRet 	 := Execblock("CSA100MEN",.F.,.F.)
		If ValType( aRet )== "A"
			For nX := 1 to Len(aRet)
				aAdd(aRotina, aRet[nX])
			Next nX
		EndIf	
	EndIf

Return aRotina     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CSAA100   �Autor  �Microsiga           � Data �  10/16/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a chave ja existe antes de incluir para evitar  ���
���          �o erro de chave duplicada                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ExistKeySqb()
	Local lRet := .F.
	
	If(ExistCpo("SQB" , M->QB_DEPTO,1,"",.F.)) .AND. Inclui
			MsgAlert(OemToAnsi(STR0014))
		lRet:=.T.
	EndIf
	
	//N�o permite definir o pr�prio departamento como departamento superior
	If !lRet .and. (M->QB_DEPSUP == M->QB_DEPTO)
		If lGestPubl
			MsgAlert(OemToAnsi(STR0039)) //"A Lota��o n�o pode ser o superior dele mesmo."
		Else
			MsgAlert(OemToAnsi(STR0036)) //"O departamento n�o pode ser o superior dele mesmo."
		Endif
		lRet := .T.
	EndIf
	        
Return lRet

Static Function RespDepto()
Local lRet := .T.

If !Empty(M->QB_DEPSUP) .and. (Empty(M->QB_FILRESP) .Or. Empty(M->QB_MATRESP))
	If lGestPubl
		MsgAlert(OemToAnsi(STR0040)) //"� obriga�rio o preenchimnento de Filial e Matricula do respons�vel quando utiliza estrutura de lota��es.
	Else
		MsgAlert(OemToAnsi(STR0037)) //"� obriga�rio o preenchimnento de Filial e Matricula do respons�vel quando utiliza estrutura de departamentos.	
	Endif
	lRet := .F.
EndIf
	        
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Csa100Atu �Autor  � Adilson Silva      � Data � 10/01/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualizar as Descricoes dos Departamentos na Tabela das    ���
���          � Visoes - RD4.                                              ���
�������������������������������������������������������������������������͹��
���Uso       � MP11                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Csa100Atu()

Local aOldAtu := GETAREA()
Local bAction := { || CursorWait(), fProcVisoes( oDlg, aList ), CursorArrow()}
Local oOk     := LoadBitmap( GetResources(), "LBOK" )	//"CHECKED"
Local oNo     := LoadBitmap( GetResources(), "LBNO" )	//"UNCHECKED"
Local lChk1   := .F.

Local aList := {}

Local oList, oGroup
Local oDlg, oConfirma
Local oExit, oChk1

dbSelectArea( "RDK" )
dbSetOrder( 1 )
dbGoTop()
Do While !Eof()
   If RDK->RDK_HIERAR == "1" .And. RDK->RDK_STATUS <> "2"
      Aadd(aList,{.F.,					;	// 01 - Flag
                  RDK->RDK_CODIGO,		;	// 02 - Codigo da Visao
                  RDK->RDK_DESC,		;	// 03 - Descricao da Visao
                  RDK->RDK_DTINCL,		;	// 04 - Data da Inclusao
                  RDK->(Recno())}		)	// 05 - Recno
   EndIf
   dbSkip()
EndDo
dbGoTop()
If Len( aList ) == 0
   Aviso(STR0016,STR0017,{STR0018})	//"ATENCAO"###"N�o existem vis�es a serem atualizadas!"###"Sair"
   RESTAREA( aOldAtu )
   Return
EndIf   

//���������������������������������������������������������������������Ŀ
//� Criacao da Interface                                                �
//�����������������������������������������������������������������������
If lGestPubl
	DEFINE MSDIALOG oDlg TITLE STR0041 FROM 069,236 To 492,936 PIXEL	// "Atualizar Lota��es na Tabela das Vis�es"
Else
	DEFINE MSDIALOG oDlg TITLE STR0019 FROM 069,236 To 492,936 PIXEL	// "Atualizar Departamentos na Tabela das Vis�es"
Endif

@ 010,010 GROUP oGroup TO 200,340 LABEL OemToAnsi( STR0020 ) OF oDlg PIXEL	// "Atualizar Vis�es"
oConfirma := SButton():New(180 , 260 , 1 , { || Eval( bAction )} , oDlg , .T. )
oConfirma:cCaption := STR0021		// "Confirmar"
oExit := SButton():New(180 , 300 , 1 , { || oDlg:End() } , oDlg , .T. )
oExit:cCaption := STR0022			// "Cancelar"
@ 180,013 CheckBox oChk1 VAR lChk1 PROMPT STR0023 SIZE 70,7 PIXEL OF oDlg ON CLICK( aEval( aList, {|x| x[1] := lChk1 } ),oList:Refresh() )	// "Marca/Desmarca Todos"
@ 020,013 ListBox oList Fields HEADER " ", STR0024, STR0025, STR0026, STR0027 SIZE 324,150 OF oDlg PIXEL ON dblClick(aList[oList:nAt,1] := !aList[oList:nAt,1])	// "C�digo"###"Descri��o"###"Data Inclus�o"###"Registro"

oList:SetArray( aList )
oList:bLine := {|| {If(aList[oList:nAt,1],oOk,oNo), ;
                        aList[oList:nAt,2], ;
                        aList[oList:nAt,3], ;
                        aList[oList:nAt,4], ;
                        aList[oList:nAt,5]}}

ACTIVATE MSDIALOG oDlg CENTERED

RESTAREA( aOldAtu )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fProcVisoes�Autor  � Adilson Silva     � Data � 10/01/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     � Executa o Processamento das Atualizacoes das Descricoes dos���
���          � Departamentos na Tabela das Visoes - RD4.                  ���
�������������������������������������������������������������������������͹��
���Uso       � MP11                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fProcVisoes( oDlg, aList )

Local cChave   := ""
Local cFilRdk  := xFilial("RDK")
Local cFilSqb  := xFilial("SQB")
Local nTamDesc := If(Len(RD4->RD4_DESC) < Len(SQB->QB_DESCRIC),Len(RD4->RD4_DESC),Len(SQB->QB_DESCRIC))
Local nX       := 0

If Aviso(STR0016,STR0028,{STR0029,STR0030}) == 1   //"ATENCAO"###"Confirma Processamento?"###"N�o"###"Sim"
   Return
EndIf

// Ordem de Pesquisa do SQB
SQB->(dbSetOrder( RetOrdem("SQB", "QB_FILIAL+QB_DEPTO") ))

Begin Sequence

For nX := 1 To Len( aList )
    // Testa as Visoes Selecionadas
    If !aList[nX,1]
       Loop
    EndIf
    
    cChave := cFilRdk + aList[nX,2]

    // Bloqueia o Cabecalho - RDK
    If !( lLocks := WhileNoLock( "RDK" , {aList[nX,5]} , NIL , 1 , 1 , .T. , 1 , 5 ) )
       Break
    EndIf
    
    Begin Transaction

    // Processa as Atualizacoes das Descricoes dos Departamentos
    dbSelectArea( "RD4" )
    dbSeek( cChave )
    Do While !Eof() .And. RD4->(RD4_FILIAL + RD4_CODIGO) == cChave
       If SQB->(dbSeek( cFilSqb + RD4->RD4_CODIDE ))
          If PadR(RD4->RD4_DESC,nTamDesc) <> PadR(SQB->QB_DESCRIC,nTamDesc)
                RecLock("RD4",.F.)
                 RD4->RD4_DESC := SQB->QB_DESCRIC
                MsUnlock()
          EndIf
       EndIf
       dbSkip()
    EndDo

    End Transaction

    // Libera o Lock do Cabecalho - RDK
	FreeLocks( "RDK" , aList[nX,5] , .T. )
Next nX

End Sequence

// Fecha o Dialogo
oDlg:End()

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ValFilMat	 � Autor � Gustavo M.	        � Data �01.02.13  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida preenchimento de campos responsaveis.				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/   
Static Function ValFilMat()

Local lRet	  := .T.   
Local nFilResp:= 0 
Local nMatResp:= 0
Local nCount  := 0   

For nCount := 1 To SQB->(FCount()) 
	If ( FieldName(nCount) == "QB_FILRESP" ) 
		nFilResp:= nCount
	ElseIf ( FieldName(nCount) == "QB_MATRESP" ) 
		nMatResp:= nCount 
	Endif
Next nCount

If !Empty(GetMemVar( FieldName(nFilResp))) .Or. !Empty(GetMemVar( FieldName(nMatResp)))
	If Empty(GetMemVar( FieldName(nFilResp))) 
	    lRet:= .F.  
	Elseif Empty(GetMemVar( FieldName(nMatResp)))
		lRet:= .F.
	Endif 
	
	If !lRet              
		MsgAlert(OemToAnsi(STR0031))
	Endif
Endif
               
Return lRet

Static Function IntegDef(cXml, nTypeTrans, cTypeMessage, cVersion)
   Local aRet := {}

   aRet := CSAI100(cXml, nTypeTrans, cTypeMessage, cVersion)
Return aRet
/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �Csa100SetFil    �Autor�Leandro Drumond	   � Data �23/06/2015�
������������������������������������������������������������������������Ĵ
�Descri��o �FUNCAO PARA SETAR UMA VARIAVEL SE PASSOU NO F3				 �
������������������������������������������������������������������������Ĵ
�Retorno   �Campo envado do parametro da linha da getdados         	     �
������������������������������������������������������������������������Ĵ
�Uso       �CSAA100 e sxb			                                     �
��������������������������������������������������������������������������/*/
Function Csa100SetFil()

Local cFiltro := ""
//nao eh necessario trocar a filial do cFilAnt para montar o filtro.
//Ou uso filial do campo QB_FILRESP ou o xFilial atual.
If FunName() == "CSAA100" 
	If !Empty(M->QB_FILRSP2)
		cFiltro := "SRA->RA_FILIAL == '" + M->QB_FILRSP2 + "'  .AND. SRA->RA_SITFOLH <> 'D' "
	EndIf
EndIf

If Empty(cFiltro)
	cFiltro := "SRA->RA_FILIAL == '" + xFilial("SRA") + "'  .AND. SRA->RA_SITFOLH <> 'D' "
EndIf

cFiltro := "@#" + cFiltro + "@#"

Return(cFiltro)



Function Csa100Fil2()

Local cFiltro := ""
If FunName() == "CSAA100" 
	If !Empty(M->QB_FILRESP)
		cFiltro := "SRA->RA_FILIAL == '" + M->QB_FILRESP + "'  .AND. SRA->RA_SITFOLH <> 'D' "
	EndIf
EndIf

If Empty(cFiltro)
	cFiltro := "SRA->RA_FILIAL == '" + xFilial("SRA") + "'  .AND. SRA->RA_SITFOLH <> 'D' "
EndIf

cFiltro := "@#" + cFiltro + "@#"

Return(cFiltro)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o �Csa100VldMat	� Autor � Leandro Drumond       � Data � 23.06.15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida matricula digitada no campo QB_MATRESP               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Csa100VldMat()
Local aArea		:= GetArea()
Local lRet 		:= .F.
Local cQuery 	:= ""
Local cAliasSRA := GetNextAlias()

If Empty(M->QB_FILRESP)
	M->QB_FILRESP := xFilial("SRA") //jah que considero a filial corrente para validacao, jah preencho o campo
EndIf
   
cQuery := " SELECT SRA.RA_MAT, SRA.RA_SITFOLH "
cQuery += " FROM " + RetFullName("SRA",EmpSQBResp()) + " SRA "
cQuery += " WHERE SRA.D_E_L_E_T_ = ' ' "
cQuery += " AND SRA.RA_FILIAL  = '" + xFilial("SRA",M->QB_FILRESP) + "' "
cQuery += " AND SRA.RA_MAT  = '" + M->QB_MATRESP + "' "
cQuery += " ORDER BY SRA.RA_MAT "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

If (cAliasSRA)->(!Eof())
	If (cAliasSRA)->(RA_SITFOLH) <> 'D'
		lRet := .T.
	Else
		lRet := .F.
		Aviso(STR0016,STR0034,{"OK"})//"Aten��o"#"Funcion�rio demitido n�o permitido como respons�vel"
	EndIf
Else
	Help("",1,"REGNOIS")
EndIf

(cAliasSRA)->(dbCloseArea())

RestArea(aArea)

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o �Csa100VldPE	� Autor � Renan Borges       � Data � 05.01.16    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Ponto de entrada CSAAVLD100 para ser poss�vel validar os    ���
���          �os dados do cadastro de departamentos como desejar.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Csa100VldPE()
Local lCsaVld	:= ExistBlock( "CSAA100VLD" )
Local lRet		:= .T.		

If lCsaVld	
	If(Valtype(lVldRet := ExecBlock( "CSAA100VLD", .F.,.F.)) == "L")
		lRet	:= lVldRet
	EndIf
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o �CrgKeyini	� Autor � Jo�o Balbino       � Data � 17.05.16    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que faz a carga incial para grava��o do campor       ���
���          �QB_KEYINI que ser� utilizado na busca das solicita��es.    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function CrgKeyini(lForca, cIniOld)

	Local aAreaSQB 	:= SQB->(GetArea())
	Local nCont 	:= 0
	Local cChave 	:= ""
	Local aDeptos 	:= {}
	Local lKeyIni 	:= SQB->(ColumnPos("QB_KEYINI")) > 0
	Local aDepX		:= {}
	Local aLog		:= {}
	Local nX		:= 0
	Local cMsgYesNo	:= ""
	Local cTitLog	:= ""
	
	Default lForca	:= .F.
	Default cIniOld	:= ""
	
	If IsInCallStack("Cs100Grava") .And. Empty(cIniOld)
		Return
	EndIf
	
	aDeptos := fEstrutDepto(cFilAnt,,,lForca)

	If Len(aDeptos) > 0	
		DbSelectArea("SQB")
		DbSetOrder(1)
		
		If (lKeyIni .And. Empty(SQB->QB_KEYINI) .And. Len(aDeptos)>0) .Or. lForca
			For nCont := 1 To Len(aDeptos)
				If SQB->(DbSeek(xFilial("SQB", aDeptos[nCont,8]) + aDeptos[nCont,1]))
					Reclock("SQB", .F.)
						SQB->QB_KEYINI := aDeptos[nCont,5]
					MsUnlock()
				EndIf
			Next nCont
		EndIf
	EndIf

	If lKeyIni .And. Empty(cIniOld) .And. lOrgCfg 
		cSQBAlias := "QSQB"		
		BeginSql alias cSQBAlias
			SELECT SQB.*
			FROM %table:SQB% SQB
			WHERE SQB.QB_FILRESP <> ' ' AND
			SQB.QB_MATRESP <> ' ' AND
			SQB.QB_KEYINI = ' ' AND
			SQB.%notDel%
			ORDER BY SQB.QB_KEYINI
		EndSql

		While (cSQBAlias)->( !Eof() )
			aAdd(aDepX, {(cSQBAlias)->QB_FILIAL, (cSQBAlias)->QB_DEPTO, (cSQBAlias)->QB_DESCRIC } )
			(cSQBAlias)->( dbSkip() )
		EndDo
		(cSQBAlias)->( dbCloseArea() )

		If Len(aDepX) > 0
			cMsgYesNo	:= OemToAnsi(;
										STR0047 + ;	// "Foram identificados Departamentos com Filial/Matr�cula Respons�vel "
										STR0048 + ;	// "cuja estrutura de hierarquia ,impossibilitando"
										STR0049	+ ; // "a gera��o devida do campo Chave de Busca (QB_KEYINI)."
										CRLF	+ ;
										CRLF	+ ;
										STR0050	+ ; // "OBSERVA��O: Verificar se os n�veis est�o cadastrados corretamente - "
										STR0051	+ ; // "o �ltimo n�vel n�o deve possuir Dep. superior cadastrado!"
										CRLF	+ ;
										CRLF	+ ;
										STR0052	  ;	// "Deseja visualizar o relat�rio de Departamentos inconsistentes agora?"
									)
			cTitLog		:= OemToAnsi( STR0016 )	// Atencao!"
			lGerEr :=  MsgYesNo( OemToAnsi( cMsgYesNo ) ,  OemToAnsi( cTitLog ) ) 
			If lGerEr
				aAdd(aLog,OemToAnsi(STR0053)) // "O(s) Departamento(s) abaixo devem ter sua estrutura de hierarquia revisada: "
				For nX := 1 to Len(aDepX)
					aAdd(aLog,OemToAnsi(STR0046)  + ": " + aDepX[nX][1] + " / " + OemToAnsi(STR0024) + ": " + aDepX[nX][2] + " - " + aDepX[nX][3])
				Next nX		
				aAdd(aLog,"	"		)
				bMkLog := { || fMakeLog( { aLog } ,{ OemToAnsi(STR0054) } ,NIL , .T. , FunName() , NIL , "M" , "L" , NIL , .F. ) }//"Log de Departamentos Inconsistentes"
				MsAguarde( bMkLog , OemToAnsi( STR0054 ) )//"Log de Departamentos Inconsistentes"
			EndIf
		EndIf
	EndIf	
	Restarea(aAreaSQB)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o �VldDepSup	� Autor � Jo�o Balbino       � Data � 17.05.16    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida altera��o no campo departamento superior.            ���
���          �                                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function VldDepSup()
	Local cAliasRH3 := GetNextAlias()
	Local cKey 		:= ""
	Local cFil 		:= ""
	Local cResp 	:= ""
	Local lTemReg 	:= .F.
	Local lRet		:= .T. 
	Local cRetOrdem := "RH3_FILIAL+RH3_DEPTO"
	Local nOrdem	:= RetOrdem(cRetOrdem)
	Local lHist		:= .F.
	Local aDeptos 	:= fEstrutDepto(cFilAnt)
	Local lKeyIni 	:= SQB->(ColumnPos("QB_KEYINI")) > 0 
	Local lOk		:= .T.
	Local nPos 		:= 0
	
	cDepSup := FGetKeyIni(xFilial("SQB",SQB->QB_FILIAL)+M->QB_DEPSUP)
	
	If !Empty(M->QB_KEYINI) .And. Alltrim(M->QB_KEYINI) == substr(cDepSup,1,Len(alltrim(M->QB_KEYINI)))
		MsgAlert(STR0042)//"Estrutura n�o permitida, para mover o departamento para um n�vel inferior � preciso primeiro mover os departamentos 'Filhos'"
		return .F.
	EndIf
	If lKeyIni .And. !Empty(M->QB_KEYINI)
		// Query para verificar se existem solicita��es em aberto		
		cKey  := AllTrim(M->QB_KEYINI)
		cFil  := AllTrim(SQB->QB_FILRESP) 
		cResp := AllTrim(SQB->QB_MATRESP) 
		BeginSQL ALIAS cAliasRH3
			SELECT COUNT(*) QTD
			FROM %table:RH3% RH3
			WHERE RH3.RH3_KEYINI = %exp:ckey%
 					AND RH3.RH3_STATUS IN ('1','4','5')
 					AND RH3.RH3_TIPO <> 'H'
 					AND RH3.RH3_FILAPR = %exp:cFil%
 					AND RH3.RH3_MATAPR = %exp:cResp%
 					AND RH3.%NotDel%
 		EndSQL
 			 			 		
 		lTemReg := Iif((cAliasRH3)->QTD > 0, .T.,.F.)
 		(cAliasRH3)->( dbCloseArea() )
 		
 		cAliasRH3 := GetNextAlias()
 		//Query para verificar se existe hist�rico
 		BeginSQL ALIAS cAliasRH3
			SELECT COUNT(*) QTD
			FROM %table:RH3% RH3
			WHERE RH3.RH3_KEYINI = %exp:ckey%
			AND RH3.RH3_TIPO <> 'H'
			AND RH3.%NotDel%
 		EndSQL
 		
 		lHist := Iif((cAliasRH3)->QTD > 0, .T.,.F.)
 		(cAliasRH3)->( dbCloseArea() )
 		
	 	
		If lTemReg //N�o ser� possivel alterar o cadastro enquanto houver solicita��es pendentes.
			MsgAlert(OemToAnsi(STR0032))
			lRet := .F.
		Elseif lHist // N�o ser� possivel exclus�o se houver hist�rico.
			lOk := MsgYesNo(OemToAnsi(STR0033),OemToAnsi(STR0016)) //# Deseja prosseguir? # ATEN��O
		EndIf
				
		If !lOk
			lRet := .F.
		EndIf
		
	EndIf

Return lRet

/*/{Protheus.doc} CCDescSQB
	Retorna a descricao do Centro de Custo(CTT) utilizando a filial do Departamento(SQB)
@author PHILIPE.POMPEU
@since 21/09/2016
@version P12.1.13
@param cFilQb, caractere, por padrao SQB->QB_FILIAL, porem pode-se passar M->QB_FILIAL se desejado.
@return cReturn, descricao do centro de Custo
/*/
Function CCDescSQB(cFilQb)
Local aArea := GetArea()
Local cMyAlias:= GetNextAlias()
Local cResult := ""
Default cFilQb := If(Empty(AllTrim(xFilial("CTT",SQB->QB_FILIAL))),'% %','% CTT_FILIAL like ' + "'" + AllTrim(xFilial("CTT",SQB->QB_FILIAL)) + "'" + ' AND %')

BeginSql alias cMyAlias
	SELECT CTT_DESC01
	FROM %table:CTT% CTT
	WHERE %exp:cFilQb% 
	CTT_CUSTO = %exp:SQB->QB_CC% AND %notDel%
EndSql

If((cMyAlias)->(!Eof()))
	cResult := (cMyAlias)->CTT_DESC01
EndIf
(cMyAlias)->(dbCloseArea())

RestArea(aArea)
Return cResult

/*/{Protheus.doc} ValComa
	Fun��o para valida��o do campo Comarca (QB_COMARC)
@author Equipe RH
@since 24/07/2018
@version P12.1.23
@return lRet, l�gico, indica se valor inserido � v�lido.
/*/
Function ValComa()

Local lGestPubl := IIF(ExistFunc("fUsaGFP"),fUsaGFP(),.F.)
Local lRet		:= .F.

If lGestPubl
	lRet := Existcpo("REC",M->QB_COMARC)                                                                                       
Else
	lRet := Vazio() .or. Existcpo("REC",M->QB_COMARC)                                                                                       
Endif

Return lRet


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o �CsaPosVldX9	� Autor � Silvio C. Stecca  � Data � 09.01.19     ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Ponto de entrada CSAPOSX9 para ser poss�vel validar os      ���
���          �os dados do cadastro de departamentos como desejar ap�s a   ���
���          �valida��o dos dados da tabela SX9 atrav�s da fun��o         ���
���          �csaa100ChkDel().                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function CsaPosVldX9()

	Local lCsaPosX9	:= ExistBlock("CSAPOSX9")
	Local lRet		:= .T.		
	
	If lCsaPosX9	
		If Valtype(lVldRet := ExecBlock("CSAPOSX9", .F., .F.)) == "L"
			lRet := lVldRet
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VldEmpCsa
//TODO Valida a empresa escolhida.
@author martins.marcio
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VldEmpCsa()

Local lRet := .T.

IF !( lRet := SM0->( dbSeek( EmpSQBResp() ) ) )
	Help("",1,"REGNOIS")
Else
	M->QB_FILRESP := SPACE(LEN(SQB->QB_FILRESP)) 
	M->QB_MATRESP := SPACE(LEN(SQB->QB_MATRESP))
EndIf

Return lRet
 
/*/{Protheus.doc} EmpSQBResp
//TODO Retorna a empresa do respons�vel.
@author martins.marcio
@since 28/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function EmpSQBResp()

Local cEmpResp := cEmpAnt

If SQB->(ColumnPos("QB_EMPRESP")) > 0
	If !Empty(M->QB_EMPRESP)
		cEmpResp := M->QB_EMPRESP
	Else
		M->QB_EMPRESP := cEmpResp
	EndIf
EndIf

Return cEmpResp

/*/{Protheus.doc} ConECsa100
//TODO Consulta espec�fica.
@author martins.marcio
@since 03/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function ConECsa100()

Local oDlg, oLbx
Local aCpos  := {}
Local aRet   := {}
Local lRet   := .F.
Local cFilt := SPACE(40)
Private aCombo := {" ","01-"+OemToAnsi(STR0044),"02-"+OemToAnsi(STR0045)} // Matricula, Nome
Private cCombo := " "

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0043) FROM 0,0 TO 350,500 PIXEL

@ 010,010 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 060,010 OF oDlg PIXEL
@ 010,080 MSGET cFilt SIZE 125, 010 OF oDlg PIXEL Picture "@!"
@ 030,010 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0046)/*Filial*/ , OemToAnsi(STR0044)/*Matr�cula*/ , OemToAnsi(STR0045) /*Nome*/ SIZE 230,120 OF oDlg PIXEL

aCpos := fGetSRA(cFilt)

oLbx:SetArray( aCpos )
oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]}}}

DEFINE SBUTTON FROM 010,213 TYPE 17 ACTION (aCpos := fGetSRA(cFilt),oLbx:SetArray( aCpos ),oLbx:bLine := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}})  ENABLE OF oDlg
DEFINE SBUTTON FROM 160,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

If Len(aRet) > 0 .And. lRet
	If Empty(aRet[2])
		lRet := .F.
	Else
		M->QB_MATRESP := aRet[2]
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} fGetSRA
//TODO Executa query da SRA
@author martins.marcio
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilt, characters, descricao
@type function
/*/
Static Function fGetSRA(cFilt)

Local aDados  := {}
Local cQuery := ""
Local cAliasSRA := GetNextAlias()
Default cFilt := SPACE(40)

cQuery := " SELECT SRA.RA_FILIAL,SRA.RA_MAT, SRA.RA_NOME "
cQuery +=   " FROM " + RetFullName("SRA",EmpSQBResp()) + " SRA "
cQuery +=  " WHERE SRA.D_E_L_E_T_ = ' ' "
cQuery +=    " AND SRA.RA_FILIAL  = '" + xFilial("SRA",M->QB_FILRESP) + "' "
cQuery +=    " AND SRA.RA_SITFOLH <> 'D' "
If !Empty(cFilt) .And. !Empty(cCombo)
	If  Left(cCombo,2) == "01"
		cQuery += " AND SRA.RA_MAT LIKE '%" + AllTrim(cFilt) + "%' "
	ElseIf Left(cCombo,2) == "02"
		cQuery += " AND SRA.RA_NOME LIKE '%" + AllTrim(cFilt) + "%' "
	EndIf
EndIf
cQuery += " ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

While (cAliasSRA)->(!Eof())
	aAdd(aDados,{(cAliasSRA)->(RA_FILIAL),(cAliasSRA)->(RA_MAT), (cAliasSRA)->(RA_NOME)})
	(cAliasSRA)->(dbSkip())
EndDo
(cAliasSRA)->(dbCloseArea())

If Len(aDados) < 1
	aAdd(aDados,{" "," "," "})
EndIf

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} function VldMatResp
Valida��o da matricula do responsavel
@author  Gisele Nuncherino
@since   24/07/2020
/*/
//-------------------------------------------------------------------
function VldMatResp()

Local lRet := .T.

if Vazio() .Or. (iif(FindFunction('Csa100VldMat'), Csa100VldMat(), .T.))
	lRet := .T.
else
	lRet := .F.
Endif

return lRet

/*/{Protheus.doc} fPrepDadosApi
Processo para preparar os dados de inclus�o/altera��o/dele��o para 
integra��o via API REST.

@since	20/08/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fPrepDadosApi(nOpcao)
	
Local aArea		:= GetArea()

Local cOperacao := ""

If nOpcao == 5
	cOperacao := "E"
	fSendDadosApi(cOperacao)
ElseIf nOpcao == 4
	cOperacao := "A"
	fSendDadosApi(cOperacao)
ElseIf nOpcao == 3
	cOperacao := "I"
	fSendDadosApi(cOperacao)
EndIf

RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} fSendDadosApi
Processo para enviar os dados de inclus�o/altera��o/dele��o para 
integra��o via API REST.

@since	20/08/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fSendDadosApi(cOperacao)
	
Local dDtBase   := DDATABASE
Local cHoraAt   := time()
Local cTmpEmp   := cEmpAnt
Local cProces   := "SQB"
Local cUserId   := SubStr(cUsuario,7,15)
Local cTmpCod   := ""
Local cTmpFil   := xFilial("SQB")
Local cChave    := ""

Default cOperacao := ''

If ( ( cOperacao == 'I') .OR. ( cOperacao == 'A') .OR. ( cOperacao == 'E'))

	cChave := cTmpEmp + "|" + cTmpFil + "|" + SQB->QB_DEPTO

	If FindFunction("fSetDeptoRJP")
		fSetDeptoRJP(cTmpFil, cProces, cChave, cOperacao,  dDtBase, cHoraAt,cUserId)			
	Endif
EndIf

Return (.T.)
