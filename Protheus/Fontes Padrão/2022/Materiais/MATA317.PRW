#INCLUDE "MATA317.ch"
#include "PROTHEUS.ch"

#define PRD_CODPRO 1
#define PRD_CODPRC 2
#define PRD_CATEGS 3
#define PRD_NIVEL  4
#define PRD_DESPRO 5
#define LT_CATEGO 1
#define LT_CODPRO 2
#define LT_CODPRC 3
#define LT_TIPO   4
#define LT_CNTNUM 5
#define LT_CNTCBX 6
#define LT_FORMUL 7
#define LT_CATATU 8
#define LT_PROCAT 9  

Static lForm2 := SuperGetMV("MV_REVPLAN",.F.,.F.) .And. FindFunction("MC010FORM2")
Static lMA317Fil := ExistBlock("MA317Fil")
Static lMA317Par := ExistBlock("MA317PAR")
Static lMA317Qry := ExistBlock("MA317QRY")
Static lMA317But := ExistBlock("MA317BUT")
Static lMA317OK  := ExistBlock("MA317OK")
Static lMA317CANC  := ExistBlock("MA317CANC")

Static aDadPrc   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA317   �Autor  � Daniel Leme        � Data �  10/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Itens de Precifica��o por Categoria x Produto              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA317()

Private cCadastro	:= STR0001 //"Itens de Precifica��o por Categoria x Produto "
Private aRotina	:= MenuDef()

If AliasInDic("SAV") .And. AliasInDic("SCI")
	dbSelectArea("ACU")
	dbSetOrder(1)
	dbGoTop()
	
	mBrowse(06,01,22,75,"ACU",,,,,, MA317Legenda("ACU"))
Else
	Alert(STR0027) //"Atualizar dicionário e rodar upddistr para criar a tabela SCI ou tabela SAV inezistente."
EndIf
Return Nil

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Mnt�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Manuten��o de Itens de Precifica��o por Categoria x Produto ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Mnt( cAlias, nReg, nOpcx )

Local aAreaAtu := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local nI       := 0
Local oFont    := TFont():New( "Courier New", 6, 15 )
Local lEnd     := .F.
Local cMvPar   := ''

//-- EnchoiceBar
Local aVisual	:= {"ACU_COD","ACU_DESC"}
Local aAltera	:= {}
Local nOpcA		:= 0
Local nOpcB		:= aRotina[nOpcx,4]
Local oEnch
//-- Ponto de entrada para adicionar botoes na enchoicebar
Local aSomaButtons :={} 
Local nCntFor     := ''

//-- Folder
Local aFldDialogs := {}
Local aFldPrompts := {}
Local aFdHead		:= {}
Local aFdCols 		:= {}
Local aFdGet      := {}

//-- Dialog
Local oDlg
Local aNoFields	:= {}
Local aYesFields	:= {}

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj 		:= {}

//-- GetDados
Local aButtons		:= {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

Private oChkRepeat  := Nil
Private lChkRepeat  := .F.

Private oChkRefresh := Nil
Private lChkRefresh := .F.
Private aFdColsIni  := {}
Private aParam      := {}
Private oFolCom     := Nil 
Private aGetD		  := {}   

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

If Pergunte("MATA317", .T.)
	For nI := 1 To 10
		cMvPar := 'mv_par'+StrZero(nI,2)
		Aadd(aParam,&(cMvPar))
	Next nI		
	If lMA317Par
		ExecBlock('MA317PAR',.F.,.F.)
	EndIf                                                                                               

	//-- Dimensoes padroes
	aSize 	:= MsAdvSize()
	AAdd( aObjects, { 100, 015, .T., .T. } )
	AAdd( aObjects, { 100, 085, .T., .T. } )
	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj  := MsObjSize( aInfo, aObjects,.T.)
	
	aButtons := {	{"RELOAD"	, {|| MATA317Rfs( aGetD[oFolCom:nOption]:aHeader, aGetD[oFolCom:nOption]:aCols ) },STR0002},; //"Atualizar"
						{"PESQUISA"	, {|| MATA317Psq( aGetD[oFolCom:nOption] ) }, STR0003},; //"Pesquisar"
					 	{"AUTOM"		, {|| MATA317Rfs( aGetD[oFolCom:nOption]:aHeader, aGetD[oFolCom:nOption]:aCols, aGetD[oFolCom:nOption]:nAt, .T. ) }, STR0004 } } // //"Forma��o"
	
	// Ponto de entrada para incluir botao na enchoicebar
	If lMA317BUT
		aSomaButtons := ExecBlock("MA317BUT",.F.,.F.,{nOpcB})
		If ValType(aSomaButtons) == "A"
			For nCntFor := 1 To Len(aSomaButtons)
				aAdd(aButtons,aSomaButtons[nCntFor])
			Next
		EndIf
	EndIf
					 	
	Processa({||aFdGet := MATA317Fgd( @aFldPrompts, @aFldDialogs, @lEnd )},STR0020 ,STR0021,.T.)//-- Aguarde..., Executando...
	aFdHead 	:= aClone(aFdGet[1])
	aFdCols 	:= aClone(aFdGet[2])

	If Len(aFldDialogs) > 0	.And. !lEnd
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
		
			//-- Monta a enchoice.
			oEnch	:= MsMGet():New( cAlias, nReg, nOpcB,,,,aVisual, aPosObj[1],aAltera, 3,,,,,,.T. )
			
			//-- Muda o fonte dos gets de campo Memo
			For nI := 1 To Len(oEnch:aEntryCtrls)
				If oEnch:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
					oEnch:aEntryCtrls[nI]:oFont := oFont
				EndIf
			Next nI
			
			//-- TFolder(): New (           [ nTop],        [ nLeft], [ aPrompts],[ aDialogs],   [ oWnd], [ nOption], [ nClrFore], [ nClrBack], [ lPixel], [ uParam10],                      [ nWidth],                       [ nHeight], [ cMsg], [ uParam14] ) --> oObjeto 
			oFolCom := TFolder():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aFldPrompts, aFldDialogs,          ,           ,            ,            ,.T.       ,.F.         ,aPosObj[ 2, 4 ]-aPosObj[ 2, 2 ], aPosObj[ 2, 3 ] - aPosObj[ 2, 1 ])
			
			aGetD := Array(Len(aFldDialogs))
			For nI := 1 To Len(aGetD)
                        //-- MSNewGetDados():New(nTop,nLeft,           nBottom,              nRight,                 nStyle ,     cLinhaOk,       cTudoOk, cIniCpos,aAlter, nFreeze,  nMax,      cFieldOk, cSuperDel ,   cDelOk,                 oWnd,  aParHeader,    aParCols)
					aGetD[nI] := MSNewGetDados():New( 3,     3,aPosObj[ 2, 3 ]-90, aPosObj[ 2, 4 ]-10,Iif(nOpcB!=5,GD_UPDATE,0),"AllWaysTrue","AllWaysTrue",         ,       ,       ,       ,"MATA317Fok()",           ,      .T., oFolCom:aDialogs[nI], aFdHead[nI], aFdCols[nI])
			Next nI
		
			@ aPosObj[ 2, 1 ] + aPosObj[ 2, 3 ]-75,015 CHECKBOX oChkRepeat  VAR lChkRepeat  PROMPT STR0005      SIZE 150, 05 OF oDlg PIXEL //-- "Repetir digita��o " //"Repetir digita��o "
		
			@ aPosObj[ 2, 1 ] + aPosObj[ 2, 3 ]-75,105 CHECKBOX oChkRefresh VAR lChkRefresh PROMPT STR0006 SIZE 150, 05 OF oDlg PIXEL //-- "Atualiza��o autom�tica " //"Atualiza��o autom�tica "
		 
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,;
										{|| IIf( Obrigatorio(aGets,aTela) .And. MATA317TOk(nOpcB),;
										(nOpcA := 1, oDlg:End()),;
										'') },;
										{|| Iif(lMA317CANC .And. !ExecBlock('MA317CANC',.F.,.F.,{nOpcx}),Nil,(nOpcA := 0, oDlg:End())) },,aButtons ) 										
										 
		RestArea(aAreaSM0)
		
		If nOpcB != 2 
			If nOpcA == 1
				Processa({|| MATA317Grv(nOpcB,aGetD)},STR0020,STR0021,.T.) //-- Aguarde..., Executando...
				If __lSX8
					ConfirmSX8()
				EndIf
				If lMA317OK 
					ExecBlock('MA317OK',.F.,.F.)
				EndIf	
			ElseIf __lSX8
				RollBackSX8()
			EndIf
		EndIf
	Else
		If lEnd
			MsgAlert(STR0022,STR0023) //-- Processamento interrompido, ATENǃO
		Else
			Aviso(STR0023,STR0026,{STR0025}) // "Aten磯" // "Categoria n㯠possui iten(s) de precifica磯 ou produto(s) amarrado(s), verifique os cadatros Amarra磯 Categoria x Produto ou Categoria X Itens Precifica磯. "// "Confirmar"
		EndIf	
	EndIf
	RestArea(aAreaATU)
EndIf 

Return nOpcA

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Del�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Valida��o da Exclus�o                                       ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Del()
Local lRet	:= .T.
Local aArea	:= GetArea()


RestArea(aArea)
Return lRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Vld�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Valida��o de Campos                                         ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Vld(cCampo) 
Local aArea 	:= GetArea()
Local lRet 		:= .T.

Default cCampo := ReadVar()
                             

RestArea(aArea)

Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Whe�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna se o campo � edit�vel                               ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Whe(cCampo) 

Local   lRet	:= .T.
Default cCampo := ReadVar()

Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Grv�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Grava��o do cadastro de Itens de Precifica��o por Categoria ���
���          � x Produtos                                                  ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Grv(nOpcx,aGetD)
Local aAreas := {	SCI->( GetArea() ),;
						SAV->( GetArea() ),;
						GetArea() }
						
Local nGD, nCols, nHead
Local uRet    := ''
Local uRetIni := ''

If nOpcx != 5
	SAV->( DbSetOrder( 1 ) ) //-- AV_FILIAL+AV_CODPRC
   
	//-- Salva Dados da Tela, Comparando com registros existentes
	For nGD := 1 To Len( aGetD )
		
		ProcRegua( Len( aGetD[nGD]:aHeader ) )
		
		For nHead := 4 To Len( aGetD[nGD]:aHeader ) - 1
			
			IncProc()
			
			If SAV->( MsSeek( xFilial("SAV") + Substr( aGetD[nGD]:aHeader[nHead][2], Len("ITPRC_") + 1 ) ) )  .And. SAV->AV_TIPO $ "1/2"
			
				Begin Transaction
			
				For nCols := 1 To Len( aGetD[nGD]:aCols ) 
				
					//-- Se o valor nao foi alterado nao grava
					uRet    := GdFieldGet(	aGetD[nGD]:aHeader[nHead][2],;
							  						nCols,;
													,;
													aGetD[nGD]:aHeader, ;
													aGetD[nGD]:aCols )
												
					uRetIni := GdFieldGet(	aGetD[nGD]:aHeader[nHead][2],;
													nCols,;
													,;
													aGetD[nGD]:aHeader, ;
													aFdColsIni[nGD] )
												
					If uRet == uRetIni 
						Loop
					EndIf
						
					If SCI->( MsSeek( xFilial("SCI") + ;
											ACU->ACU_COD + ;
											GdFieldGet( "ITPRC_CODPRO", nCols,, aGetD[nGD]:aHeader, aGetD[nGD]:aCols ) + ;
											SAV->AV_CODPRC ) )
		
						RecLock( "SCI", .F. )
					Else
						RecLock( "SCI", .T. )
						SCI->CI_FILIAL	:= xFilial("SCI")
						SCI->CI_CATEGO	:= ACU->ACU_COD
						SCI->CI_CODPRO	:= GdFieldGet( "ITPRC_CODPRO", nCols,, aGetD[nGD]:aHeader, aGetD[nGD]:aCols )
						SCI->CI_CODPRC	:= SAV->AV_CODPRC
					EndIf
	
					SCI->CI_TIPO := SAV->AV_TIPO
	
					If SAV->AV_TIPO == "1" //-- Dado Num�rico
						SCI->CI_CNTNUM	:= uRet
	
					ElseIf SAV->AV_TIPO == "2" //-- Dado L�gico (Combo 1=Sim,2=N�o)
						SCI->CI_CNTCBX	:= uRet
					EndIf
	
					MsUnLock()
					
				Next nCols
				
				End Transaction
			EndIf
		Next nHead
	Next nGD
Else
	Begin Transaction
		//-- Analisa Registros Previamente Salvos
		SCI->( DbSetOrder( 1 ) ) //-- CI_FILIAL+CI_CATEGO+CI_CODPRO+CI_CODPRC
		SCI->( MsSeek( xFilial("SCI") + ACU->ACU_COD ) )
		While SCI->(!Eof()) .And. SCI->(CI_FILIAL+CI_CATEGO) == xFilial("SCI") + ACU->ACU_COD
			RecLock('SCI',.F.)
			dbDelete()
			MsUnLock()  
			SCI->(dbSkip())
		EndDo
	End Transaction
EndIf

//-- Restaura as Areas 
aEval( aAreas, { |x| RestArea(x) } )

Return Nil

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317LOk�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Valida��o da Linha da GetDados                              ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317LOk( nOpc )
Local lRet      := .T.        

Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317TOk�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Valida��o Geral  do cadastro de Itens de Precifica��o por   ���
���          � Categoria x Produto                                         ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317TOk( nOpcx )
Local lRet			:= .T.

Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Fgd�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Montagem dos Folders com colunas e linhas com produtos e    ���
���          � sua respectativa combina��o de Itens de Precifica��o        ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MATA317Fgd( aFldPrompts, aFldDialogs, lEnd )
Local aAreas		:= {	ACU->(GetArea()),;
								SAV->(GetArea()),;
								GetArea()}
Local aAreaACU		:= ACU->(GetArea())
Local aCateg 		:= {}
Local aItPrc 		:= {}
Local aProd 		:= {}
Local aCatSup 		:= {}
Local aHeadAux		:= {}
Local aFdHead 		:= {}
Local aFdCols 		:= {}
Local nFound		:= 0
Local nNivel		:= 0
Local cItem       := StrZero(1,5)
Local aCatPro     := { ACU->ACU_COD }
Local aAtuPro     := {}
Local cAliasQry   := ''
Local bError
Local nI,nJ,nCnt,nProd,nAux,nB,uRet

aAdd( aAreas, SCI->(GetArea()) )
aAdd( aAreas, ACU->(GetArea()) )
aAdd( aAreas, SAV->(GetArea()) )
aAdd( aAreas, SAV->(GetArea()) )

//-- Sobe Categorias para verificar Itens de Precifica��o e Produtos das Categorias superiores.
If SuperGetMv("MV_HCATSUP",,.T.) 

	ACU->(DbSetOrder(1)) //-- ACU_FILIAL+ACU_COD

 
	LoadCat(@aCatSup,@aCatPro,ACU->ACU_CODPAI)

	//== Adiciona em ordem decrescente para construir os arrays a partir do maior n�vel de categoria.
	For nI := Len( aCatSup ) To 1 Step -1
		nFound := MATA317Cat( aCatSup[nI], .F. , @aCateg, @aItPrc, @aProd, nFound, ++nNivel )
	Next nI

	//-- Reposiciona a Categoria
	RestArea(aAreaACU)
EndIf

//-- Adiciona Itens/Produtos da Categoria selecionada, chamando a fun��o para modo recursivo, descendo a estrutura a partir da categoria selecionada.
MATA317Cat( ACU->ACU_COD, .T., @aCateg, @aItPrc, @aProd, nFound, ++nNivel, @lEnd)

//-- Ordena o Array de Produtos por Aba
aSort( aProd,,,{ |x,y| StrZero(x[2],10) + x[1] < StrZero(y[2],10) + y[1] })

aFdHead	:= {}
aFdCols	:= {}
nProd		:= 0

SAV->(DbSetOrder(1)) //-- AV_FILIAL+AV_CODPRC
//-- Monta os Arrays do objeto TFolder
For nI := 1 To Len(aItPrc)
	aAdd(aFdHead,{})
	nCnt := Len(aFdHead)

	//-- Array Fixo: Todas as colunas s�o espec�ficas - baseadas no cadastro
	aAdd(aFdHead[nCnt],{Posicione('SX3', 2, "CI_ITEM"  , 'X3Titulo()'),"ITPRC_ITEM"  ,PesqPict("SCI","CI_ITEM")	, TamSX3("CI_ITEM")[1]	, TamSX3("CI_ITEM")[2]+3	, , ,"C", ,"V", , , , "V", , , }) 
	aAdd(aFdHead[nCnt],{Posicione('SX3', 2, "CI_CODPRO", 'X3Titulo()'),"ITPRC_CODPRO",PesqPict("SCI","CI_CODPRO")	, TamSX3("CI_CODPRO")[1]	, TamSX3("CI_CODPRO")[2]	, , ,"C", ,"V", , , , "V", , , }) 
	aAdd(aFdHead[nCnt],{Posicione('SX3', 2, "CI_DESPRO", 'X3Titulo()'),"ITPRC_DESPRO",PesqPict("SCI","CI_DESPRO")	, TamSX3("CI_DESPRO")[1]	, TamSX3("CI_DESPRO")[2]	, , ,"C", ,"V", , , , "V", , , }) 

	For nJ := 1 To Len(aItPrc[nI])
	   If SAV->( MsSeek( xFilial("SAV") + aItPrc[nI][nJ] ))
			aAdd(aFdHead[nCnt],{	SAV->AV_TITULO,;																 								//-- 01-TITULO
										"ITPRC_" + aItPrc[nI][nJ],; 																				//-- 02-CAMPO
										Iif(SAV->AV_TIPO=="1",PesqPict("SCI","CI_CNTNUM"),"@!"),;										//-- 03-PICTURE
										Iif(SAV->AV_TIPO=="1",TamSX3("CI_CNTNUM")[1],Iif(SAV->AV_TIPO=="2",1,25)),;		 		//-- 04-TAMANHO
										Iif(SAV->AV_TIPO=="1",TamSX3("CI_CNTNUM")[2],0)	,; 											 	//-- 05-DECIMAL
										,; 																				 								//-- 06-VALID
										,; 																			 									//-- 07-USADO
										Iif(SAV->AV_TIPO=="1","N","C"),;											 								//-- 08-TIPO
										,; 																				  								//-- 09-F3
										"V",; 																											//-- 10-CONTEXT
										Iif(SAV->AV_TIPO=="2",STR0007,Nil),;															//-- 11-CBOX //"1=Sim;2=N�o"
										Iif(SAV->AV_TIPO=="3",SAV->AV_FORMUL,""),;															//-- 12-RELACAO
										,;																													//-- 13-WHEN
										Iif(SAV->AV_TIPO=="3","V","A"),;			  																//-- 14-VISUAL
										,;																													//-- 15-VLDUSER
										,;	 																												//-- 16-PICTVAR
										, }) 																												//-- 17-OBRIGAT
		EndIf
	Next nJ	

	aAdd(aFdHead[nCnt],{	STR0008,;							//-- 01-TITULO //"Prc Sugerido"
								"ITPRC_PRCSUG",;				 			//-- 02-CAMPO
								PesqPict("SCI","CI_CNTNUM"),;			//-- 03-PICTURE
								TamSX3("CI_CNTNUM")[1],;			 	//-- 04-TAMANHO
								TamSX3("CI_CNTNUM")[2],; 			 	//-- 05-DECIMAL
								,; 											//-- 06-VALID
								,; 											//-- 07-USADO
								"N",;			 								//-- 08-TIPO
								,; 			  								//-- 09-F3
								"V",; 										//-- 10-CONTEXT
								,;												//-- 11-CBOX
								,;												//-- 12-RELACAO
								,;												//-- 13-WHEN
								"V",;											//-- 14-VISUAL
								,;												//-- 15-VLDUSER
								,;	 											//-- 16-PICTVAR
								, }) 											//-- 17-OBRIGAT

	//-- Verifica se existem produtos para a Combina��o e Popula o aCols
	aAdd(aFdCols,{})
	nProd := aScan( aProd, { |x| x[PRD_CODPRC] == nI })
	ProcRegua(Len(aProd))
	Do While nProd > 0 .And. nProd <= Len(aProd) .And. aProd[nProd][PRD_CODPRC] == nI
		IncProc()
		
		If lEnd
			Exit
		EndIf
		aAdd(aFdCols[nCnt],Array(Len(aFdHead[nCnt])+1))
		nJ := Len(aFdCols[nCnt])
		aFdCols[nCnt][nJ][1] := cItem
		aFdCols[nCnt][nJ][2] := aProd[nProd][PRD_CODPRO]
		aFdCols[nCnt][nJ][3] := aProd[nProd][PRD_DESPRO]

		//-- Inicializa Itens de Precificacao
		For nB := 4 To Len(aFdHead[nCnt])
			uRet:= ""
			If aFdCols[nCnt][nJ][nB] == Nil
				If aFdHead[nCnt][nB][8] == "N"
					uRet := 0
				ElseIf aFdHead[nCnt][nB][4] == 25 //-- Formula
					SM4->( DbSetOrder( 1 ))
					If SM4->( MsSeek( xFilial("SM4") + aFdHead[nCnt][nB][12] ) )
						bError := ErrorBlock( {|| MATA317Err( @uRet )  } )
						Begin Sequence
							uRet := &(SM4->M4_FORMULA)
						End Sequence
					EndIf
					If !(ValType(uRet) $ "C/N") 
						uRet := ""
					Else
						If ValType(uRet) == "N"
							uRet := TransForm(uRet,PesqPict("SCI","CI_CNTNUM"))
						EndIf				
					EndIf
				Else
					uRet := Space(aFdHead[nCnt][nB][4])
				EndIf
				aFdCols[nCnt][nJ][nB] := uRet
			EndIf
		Next nB													
		
		aFdCols[nCnt][nJ][Len(aFdHead[nCnt])+1] := .F.
	
		cItem := Soma1(cItem)
		nProd += 1
	EndDo
	
	If !lEnd
		cAliasQry:= GetNextAlias()
		For nAux := 1 To Len(aCatPro)
			cQuery := "SELECT CI_CODPRC, CI_TIPO, CI_CNTNUM, CI_CNTCBX, CI_FORMUL, CI_CODPRO, B1_DESC "
			cQuery += "  FROM "
			cQuery += RetSqlName("SCI")+" SCI "
			cQuery += " INNER JOIN "
			cQuery += RetSqlName("SB1")+" SB1 "
			cQuery += "    ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
			cQuery += "   AND SB1.B1_COD    = CI_CODPRO"
			cQuery += "   AND SB1.B1_GRUPO  BETWEEN '"+aParam[4]+"' AND '"+aParam[5]+"' " 	
			If aParam[6] <> 3 // Todos
				cQuery += "AND SB1.B1_MSBLQL = "+Str(aParam[6],1)+""	
			EndIf 
			cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SCI.CI_FILIAL  = '"+xFilial('SCI')+"'"
			cQuery += "   AND SCI.CI_CATEGO  = '"+aCatPro[nAux]+"'"
			cQuery += "   AND SCI.CI_CODPRO BETWEEN '"+aParam[2]+"' AND '"+aParam[3]+"'"
			cQuery += "   AND SCI.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY CI_CODPRO, CI_CODPRC"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			
			ProcRegua(Len(aProd))
			
			While (cAliasQry)->(!Eof())
				
				IncProc()
				
				cCodPro := (cAliasQry)->CI_CODPRO
				
				While (cAliasQry)->(!Eof()) .And. (cAliasQry)->CI_CODPRO == cCodPro
					
					nJ := Ascan(aFdCols[nCnt],{ | e | e[2] == cCodPro } )
					
					If nJ > 0
						If (cAliasQry)->CI_TIPO == '1'
							uRet := (cAliasQry)->CI_CNTNUM
						ElseIf (cAliasQry)->CI_TIPO == '2'
							uRet := (cAliasQry)->CI_CNTCBX
						ElseIf (cAliasQry)->CI_TIPO == '3' .And. !Empty((cAliasQry)->CI_FORMUL)
							SM4->( DbSetOrder( 1 ))
							If SM4->( MsSeek( xFilial("SM4") + (cAliasQry)->CI_FORMUL ) )
								bError := ErrorBlock( {|| MATA317Err( @uRet )  } )
								Begin Sequence
									uRet := &(SM4->M4_FORMULA)
								End Sequence
							EndIf
							If !(ValType(uRet) $ "C/N") 
								uRet := ""
							Else
								If ValType(uRet) == "N"
									uRet := TransForm(uRet,PesqPict("SCI","CI_CNTNUM"))
								EndIf				
							EndIf
						EndIf
						If Ascan(aAtuPro,{ | e | e[1]+e[2]+e[3] == StrZero(nCnt,3)+cCodPro+(cAliasQry)->CI_CODPRC }) == 0
							GdFieldPut( "ITPRC_"+(cAliasQry)->CI_CODPRC, uRet, nJ, aFdHead[nCnt], aFdCols[nCnt] )
						Else
							Aadd(aAtuPro,{ StrZero(nCnt,3), cCodPro, (cAliasQry)->CI_CODPRC })
						EndIf
					EndIf
					
					(cAliasQry)->(dbSkip())
				EndDo
			EndDo
			
			(cAliasQry)->(dbCloseArea())
			dbSelectArea('SCI')
		Next nAux
	EndIf
	
	//-- Se nao possui produtos, a combinacao e descartada.
	If Len(aFdCols[nCnt]) == 0
		aSize(aFdHead,nCnt-1)
		aSize(aFdCols,nCnt-1)
	Else
		aAdd( aFldDialogs, "Seq_" + StrZero(nCnt,3))
		aAdd( aFldPrompts, STR0009 + StrZero(nCnt,3) ) //"Produtos - Composi��o "
	EndIf
	If lEnd
		Exit
	EndIf

Next nI
aFdColsIni := AClone(aFdCols)

//-- Altera a descri��o quando for formada apenas uma Aba
If Len( aFldPrompts ) == 1
	aFldPrompts[1] := STR0010 //"Produtos"
EndIf

//-- Restaura as Areas 
aEval(aAreas, { |x| RestArea(x) } )

Return { aFdHead, aFdCols }

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Cat�Autor  � Daniel Leme        � Data �  10/02/11    ���
��������������������������������������������������������������������������͹��
���Desc.     � Relaciona Produtos e Itens de Precifica��o por Categoria    ���
���          � Recursivamente                                              ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MATA317Cat( cCateg, lRecursiva, aCateg, aItPrc, aProd, nLenPrc, nNivel, lEnd )
Local aAreas 		:= {	ACU->(GetArea()),;
								ACV->(GetArea()),;
								SAW->(GetArea()),;
								GetArea() }
Local nCont 		:= 0
Local aItCat 		:= {}
Local nFound 		:= 0
Local nNewFound	:= 0
Local cAliasQry	:= ''
Local cIndSAV     := ''
Local cQueryUsr   := ''
Local nI, nJ, nCnt

//-- Obtem os Itens de Precifica��o para a Categoria
SAW->( DbSetOrder(1) ) //-- AW_FILIAL+AW_CATEGO+AW_ITEM
SAW->( MsSeek( xFilial("SAW") + cCateg ) )
Do While SAW->( !Eof() ) .And. SAW->( AW_FILIAL + AW_CATEGO ) == xFilial("SAW") + cCateg
	aAdd( aItCat, SAW->AW_CODPRC )

	SAW->( DbSkip() )
EndDo

//-- Acrescenta os Itens de Precifica��o da Categoria, se necess�rio, � lista de Combina��es.
nFound := MATA317Prc( @aItCat, @aItPrc, nLenPrc )

//-- Faz controle de Categorias utilizadas para a combina��o
If nFound > Len( aCateg )
	aSize( aCateg, nFound )
	If nFound > 1
		aCateg[nFound] := aClone( aCateg[ nLenPrc ] )
	Else
		aCateg[nFound] := {}
	EndIf
	aAdd( aCateg[nFound], cCateg )
EndIf

//-- Carrega produtos obtidos em nives inferiores - "Herdados" - para reconfigura��o
aEval(aProd, {|x| Iif( x[PRD_NIVEL] < nNivel,;
						   		MATA317Prod( x[PRD_CODPRO], @aProd, nFound, @aItPrc, @aCateg, nNivel, x[PRD_DESPRO] ),;
								Nil) } )

//-- Busca Produtos da Categoria
cAliasQry := GetNextAlias()
cQuery := "SELECT ACV_GRUPO, ACV_CODPRO, ACV_REFGRD, B1_DESC FROM "
cQuery += RetSqlName("ACV")+" ACV "
cQuery += " INNER JOIN "
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += "    ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"'"
cQuery += "   AND SB1.B1_COD     = ACV_CODPRO"
cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
cQuery += " WHERE ACV.ACV_FILIAL = '"+xFilial('ACV')+"'"
cQuery += "   AND ACV.ACV_CATEGO = '"+cCateg+"'"   
cQuery += "   AND ACV.D_E_L_E_T_ = ' '"
cQuery += "   AND SB1.B1_COD     BETWEEN '"+aParam[2]+"' AND '"+aParam[3]+"' " 	
cQuery += "   AND SB1.B1_GRUPO   BETWEEN '"+aParam[4]+"' AND '"+aParam[5]+"' " 	
If aParam[6] <> 3 // Todos
	cQuery += "AND SB1.B1_MSBLQL  = "+Str(aParam[6],1)+""	
EndIf
If lMA317Qry
	cQueryUsr := ExecBlock('MA317QRY',.F.,.F.)
	If ValType(cQueryUsr) == "C" .And. !Empty(cQueryUsr)
		cQuery += cQueryUsr
	EndIf
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

While (cAliasQry)->(!Eof()) 
	//-- Amarra��o pelo Grupo
	If !Empty( (cAliasQry)->ACV_GRUPO )                              
		SB1->( DbSetOrder(1) ) //-- B1_FILIAL+B1_GRUPO+B1_COD
		SB1->( MsSeek( xFilial("SB1") + (cAliasQry)->ACV_GRUPO ) )
		Do While SB1->( !Eof() ) .And. SB1->( B1_FILIAL+B1_GRUPO ) == xFilial("SB1") + (cAliasQry)->ACV_GRUPO 
			MATA317Prod( SB1->B1_COD, @aProd, nFound, @aItPrc, @aCateg, nNivel, SB1->B1_DESC )
			SB1->( DbSkip() ) 
		EndDo
    
	//-- Amarracao pelo Produto
	ElseIf !Empty( (cAliasQry)->ACV_CODPRO )

		MATA317Prod( (cAliasQry)->ACV_CODPRO, @aProd, nFound, @aItPrc, @aCateg, nNivel, (cAliasQry)->B1_DESC )

	//-- Amarracao pela Ref.Grade
	ElseIf !Empty( (cAliasQry)->ACV_REFGRD )

		MATA317Prod( (cAliasQry)->ACV_REFGRD, @aProd, nFound, @aItPrc, @aCateg, nNivel, (cAliasQry)->B1_DESC )

	EndIf
	
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(dbCloseArea())	
dbSelectArea("ACV")

//-- Verifica se deve descer a estrutura de Categorias Recursivamente
If lRecursiva
	ACU->( DbSetOrder( 2 ) ) //-- ACU_FILIAL+ACU_CODPAI
	ACU->( MsSeek( xFilial("ACU") + cCateg ) )
	nNivel++
	Do While ACU->( !Eof() ) .And. ACU->ACU_CODPAI == cCateg
		nNewFound := MATA317Cat( ACU->ACU_COD, .T., @aCateg, @aItPrc, @aProd, nFound, nNivel,@lEnd )
		ACU->( DbSkip() )
	EndDo
	nNivel--
EndIf	

//-- Restaura as Areas 
aEval( aAreas, { |x| RestArea( x ) } )

Return nFound

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Prod�Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Relaciona Produtos � uma combina��o de Itens de Precifica��o���
���          � , gerando uma nova combina��o, se necess�rio, mesclando     ���
���          � combina��es de categorias distintas em que o produto est�   ���
���          � relacionado                                                 ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MATA317Prod( cCodPro, aProd, nFound, aItPrc, aCateg, nNivel, cDesPro )
Local nPosPrd 		:= 0
Local nOldFound 	:= 0
Local nNewFound 	:= 0
Local lRetPe
Local nI, nJ
Default cDesPro   := ''

//-- Verifica se o Produto j� existe... 
If ( nPosPrd := aScan( aProd, { |x| x[PRD_CODPRO] == cCodPro } )) == 0
	lRetPE := .T.
	If lMA317Fil
		lRetPE := ExecBlock("MA317FIL",.F.,.F.,{cCodPro})
		If ValType(lRetPE) != "L"
			lRetPE := .T.
		EndIf
	EndIf
		
	If lRetPE
		If !Empty( aCateg )
			aAdd(aProd, { cCodPro, nFound, { aClone(aCateg[nFound]) }, nNivel, cDesPro } )
		Else 
			Aviso(STR0023,STR0026,{STR0025}) // "Aten磯" // "Categoria n㯠possui iten(s) de precifica磯 ou produto(s) amarrado(s), verifique os cadatros Amarra磯 Categoria x Produto ou Categoria X Itens Precifica磯. "// "Confirmar"			
		EndIf
	EndIf
Else

	//-- Se o Produto j� existe, mescla a combina��o gerada para a Categoria com a anterior 
	nOldFound := aProd[nPosPrd][PRD_CODPRC]
	nNewFound := MATA317Prc( aClone( aItPrc[ nOldFound ]), @aItPrc, nFound )
	aProd[nPosPrd][PRD_CODPRC] := nNewFound
	
	//-- Tratamento do Array de Categorias, para descri��o das Abas
	If nNewFound > Len( aCateg )
		aSize( aCateg, nNewFound )
		aCateg[nNewFound] := {}
	EndIf

	//-- Mescla as Categorias do Produto
	For nI := 1 To Len( aProd[nPosPrd][PRD_CATEGS] )
		For nJ := 1 To Len( aProd[nPosPrd][PRD_CATEGS][nI] )
			If aScan( aCateg[nNewFound], { |x| x == aProd[nPosPrd][PRD_CATEGS][nI][nJ] }) == 0
				aAdd( aCateg[nNewFound], aProd[nPosPrd][PRD_CATEGS][nI][nJ] )
			EndIf
		Next nJ
	Next nI
	
	//-- Mescla Categorias da Combina��o atual � Nova combina��o
	For nI := 1 To Len( aCateg[nFound] )
		If aScan( aCateg[nNewFound], { |x| x == aCateg[nFound][nI] }) == 0
			aAdd( aCateg[nNewFound], aCateg[nFound][nI] )
		EndIf
	Next nI

	//-- Atualiza as Categorias do Produto
	aAdd( aProd[nPosPrd][PRD_CATEGS], aClone(aCateg[nFound]) )

EndIf	 

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Prc �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Monta a combina��o de Itens de Precifica��o, considerando   ���
���          � sua heran�a dentro da estrutura de categorias               ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MATA317Prc( aItNew, aItPrc, nPosHer )
Local nI,nJ,nCnt
Local nFound := 0

Default nPosHer := 0

//-- Tratamento com Heran�a
If nPosHer > 0
	//-- Compara os Itens de Precifica��o encontrados com os Itens Herdados, retirando duplicidades
	For nI := Len( aItNew ) To 1 Step -1
		If aScan( aItPrc[nPosHer], {|x| x == aItNew[nI] } ) > 0 
			aDel( aItNew, nI )
			aSize( aItNew, Len(aItNew) - 1 )
		EndIf
	Next nI

	//-- Adiciona os Itens de Precifica��o Herdados � Composi��o
	aSize( aItNew, Len( aItNew ) + Len( aItPrc[nPosHer] ) )
	aEval( aItPrc[nPosHer], {|x,y| aIns( aItNew, y ), aItNew[y] := x } )
EndIf
		
//-- Verifica se a composi��o formada para a categoria j� existe, mesmo que em outra ordem.
For nI := 1 To Len( aItPrc )
	If Len( aItPrc[nI] ) == Len( aItNew )
		nCnt := Len( aItNew )
		For nJ := 1 To Len( aItNew )
			If aScan( aItPrc[nI], { |x| x == aItNew[nJ] } ) == 0
				nCnt--
				Exit
			EndIf
		Next nJ
		
		If nCnt == Len( aItNew )
			aItNew := {}
			nFound := nI
			Exit
		EndIf
	EndIf
Next nI

//-- Se foi mantida a composi��o, adiciona-a ao Array de Composi��es
If Len( aItNew ) > 0
	aAdd( aItPrc, aClone( aItNew ) )
	nFound := Len( aItPrc )
EndIf

Return nFound

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Fok �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Fun��o chamada pela propriedada "FieldOk" da NewGetDados,   ���
���          � utilizada para recalcular, dependendo da op��o, os valores  ���
���          � integrando a tela com a planilha de Forma��o de Pre�os      ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Fok()
Local aSvCols
Local bError
Local lRet		:= .T.
Local cCampo	:= ReadVar()
Local nPosCpo	:= GdFieldPos(Substr(cCampo,4))
Local nI       := 0

bError := ErrorBlock( {|| MATA317Err( @lRet )  } )
Begin Sequence

	If lChkRepeat
		
		aSvCols := aClone(aCols)
		aEval( aCols, {|x,y| x[nPosCpo] := &cCampo }, n)
	
	EndIf
	
	If lChkRefresh
		
		aCols[n][nPosCpo] := &cCampo	
		
		For nI := n To Len(aCols)
			If MATA317Rfs( aHeader, aCols, nI )
				If !lChkRepeat
					Exit
				EndIf
			Else
				Exit
			EndIf									
		Next nI							
	
	EndIf

End Sequence

If lRet == Nil
	If lChkRepeat
		aCols := aClone(aSvCols)
	EndIf
	Alert(STR0011) //"Ocorreram problemas ao efetuar opera��es com o(s) �ndice(s). Verifique a planilha de Forma��o"
	lRet := .F.
EndIf	

Return lRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Cts �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Busca uma categoria default para um produto                 ���
���          �                                                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MATA317Cts( cProd, cCatVld )
Local aArea := GetArea()
Local aAreaAux
Local aPais
Local cCateg := ""
Local cQuery := ""
Local aCatPrd := {}
Local cAlias := GetNextAlias()
Local lGrade := MatGrdPrrf( cProd )
Local nQtdPai	:= 0
Local nPosCat	:= 0

Default cCatVld := ""

cQuery := " SELECT  ACU_COD, ACU_CODPAI FROM " + RetSqlName("ACV") + " ACV"
cQuery += " JOIN  " + RetSqlName("ACU") + " ACU ON"
cQuery += "     ACU.ACU_FILIAL     = '" + xFilial("ACU") + "'"
cQuery += "     AND ACU.ACU_COD    = ACV_CATEGO"
cQuery += "     AND ACU.D_E_L_E_T_ = ' '"
cQuery += " WHERE"
cQuery += "     ACV.ACV_FILIAL     = '" + xFilial("ACV") + "'"

If lGrade
	cQuery += "     AND ACV.ACV_REFGRD = '" + cProd + "'"
Else
	cQuery += "     AND ACV.ACV_CODPRO = '" + cProd + "'"
EndIf
cQuery += "     AND ACV.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY ACU_CODPAI"
cQuery := ChangeQuery( cQuery )
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAlias),.F.,.T.)

(cAlias)->( DbEval( {|| aAdd( aCatPrd, { ACU_COD, ACU_CODPAI} ) } ) )
(cAlias)->( DbCloseArea() )

//-- Se n�o encontrou por produto, busca por Grupo de Produtos
If Len( aCatPrd ) == 0 .And. !lGrade
	aAreaAux := SB1->( GetArea() )
	SB1->( DbSetOrder( 1 ))
	If SB1->( MsSeek( xFilial("SB1") + cProd ) )
		cQuery := " SELECT  ACU_COD, ACU_CODPAI FROM " + RetSqlName("ACV") + " ACV"
		cQuery += " JOIN  " + RetSqlName("ACU") + " ACU ON"
		cQuery += "     ACU.ACU_FILIAL     = '" + xFilial("ACU") + "'"
		cQuery += "     AND ACU.ACU_COD    = ACV_CATEGO"
		cQuery += "     AND ACU.D_E_L_E_T_ = ' '"
		cQuery += " WHERE"
		cQuery += "     ACV.ACV_FILIAL     = '" + xFilial("ACV") + "'"
		cQuery += "     AND ACV.ACV_GRUPO  = '" + SB1->B1_GRUPO + "'"
		cQuery += "     AND ACV.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY ACU_CODPAI"
		cQuery := ChangeQuery( cQuery )
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAlias),.F.,.T.)
		
		(cAlias)->( DbEval( {|| aAdd( aCatPrd, { ACU_COD, ACU_CODPAI} ) } ) )
		(cAlias)->( DbCloseArea() )
	EndIf
	RestArea( aAreaAux )
EndIf

//-- Se encontrou apenas uma Categoria, utiliza-a como base
If Len( aCatPrd ) == 1
	cCateg := aCatPrd[1][1]

//-- Se encontrou mais de uma Categoria, verifica exce��es que permitam a sele��o de uma delas
ElseIf Len( aCatPrd ) > 1

	//-- Se possui categoria a validar, busca-a na lista.
	If !Empty(cCatVld) .And. aScan(aCatPrd,{ |x| x[1] == cCatVld }) > 0

		cCateg := cCatVld

	Else
	
		aEval( aCatPrd, { |x,y| nQtdPai += Iif( Empty(x[2]), 1, 0 ),;
										nPosCat := Iif( Empty(x[2]), y, nPosCat) } )
		
		If nQtdPai == 1
			cCateg := aCatPrd[nPosCat][1]
		ElseIf nQtdPai == 0
			cCateg := aCatPrd[1][1]
		ElseIf nQtdPai > 1
	/*		aPais := {}
			nQtdPai := 0
			aEval( aCatPrd, {|x,y| 	cCateg := x[2],;
											Iif( !Empty(x[2]) .And. (nPosCat := aScan(aCatPrd,{|z| z[1] == cCateg })) > 0 },;
													aAdd(aPais,{nPosCat,y}),;
													Nil) )
	*/
			cCateg := ""
		EndIf
	EndIf
	
EndIf

RestArea( aArea )

Return cCateg

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Cnt �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna o conteudo do Item de precifica��o para o produto x ���
���          � categoria. Considera heran�a, se necess�rio                 ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Cnt( cProd, cItPrc, cCateg, cFormula )
Local aArea			:= GetArea()
Local aAreasAux 	:= {}
Local lStatic		:= !(aDadPrc == Nil)
Local bError
Local uRet, nPosPrc

Default cFormula 	:= ""
Default cCateg 	:= ""

If lStatic .And. ( nPosPrc := aScan( aDadPrc, { |x| x[1] == cItPrc }) ) > 0 
	uRet := aDadPrc[nPosPrc][2]
Else
	If Empty(cCateg)
		cCateg := MATA317Cts( cProd, ACU->ACU_COD )
	EndIf
	
	If !Empty( cCateg )
		//-- Resolve F�rmula
		If !Empty( cFormula )
		
			aAdd( aAreasAux, SM4->(GetArea()) )
		
			SM4->( DbSetOrder( 1 ))
			If SM4->( MsSeek( xFilial("SM4") + cFormula ) )
				bError := ErrorBlock( {|| MATA317Err( @uRet )  } )
				Begin Sequence
					uRet := &(SM4->M4_FORMULA)
				End Sequence
			EndIf
			If !(ValType(uRet) $ "C/N") 
				uRet := ""
			Else
				If ValType(uRet) == "N"
					uRet := TransForm(uRet,PesqPict("SCI","CI_CNTNUM"))
				EndIf				
			EndIf
		
		Else
		
			aAdd( aAreasAux, SCI->(GetArea()) )      	
			aAdd( aAreasAux, SAV->(GetArea()) )
			
			SAV->( DbSetOrder( 1 ) ) //-- AV_FILIAL+AV_CODPRC
			SCI->( DbSetOrder( 1 ) ) //-- CI_FILIAL+CI_CATEGO+CI_CODPRO+CI_CODPRC

			If SCI->( MsSeek( xFilial("SCI") + cCateg + cProd + cItPrc ) )
			
				If SCI->CI_TIPO == "1" 		//-- Dado Num�rico
					uRet := SCI->CI_CNTNUM
				ElseIf SCI->CI_TIPO == "2" //-- Dado L�gico (Retorno caractere: combo "1"=Sim,"2"=N�o)
					uRet := SCI->CI_CNTCBX
				ElseIf SCI->CI_TIPO == "3" .And. !Empty(SCI->CI_FORMUL)  //-- Formula SM4
					uRet := MATA317Cnt( cProd, cItPrc, cCateg, SCI->CI_FORMUL )
				EndIf
				
			//-- Se o Item de Precifica��o � do tipo f�rmula, inicializa-o
			ElseIf SAV->( MsSeek( xFilial("SAV") + cItPrc ) ) .And. !Empty( SAV->AV_FORMUL )
					uRet := MATA317Cnt( cProd, cItPrc, cCateg, SAV->AV_FORMUL )
			
			//-- Sobe Categorias para verificar Itens de Precifica��o e Produtos das Categorias superiores.
			ElseIf SuperGetMv("MV_HCATSUP",,.T.) 
			
				aAdd( aAreasAux, ACU->(GetArea()) )
		
				ACU->( DbSetOrder( 1 ) ) //-- ACU_FILIAL+ACU_COD
				If ACU->( MsSeek( xFilial("ACU") + cCateg )) .And. !Empty( ACU->ACU_CODPAI )
					uRet := MATA317Cnt( cProd, cItPrc, ACU->ACU_CODPAI )
				EndIf
			
			EndIf
	
		EndIf
	
	Else
	
		uRet := 0
	
	EndIf

EndIf

If uRet == Nil
	aAdd( aAreasAux, SAV->(GetArea()) )
	
	SAV->( DbSetOrder( 1 ) ) //-- AV_FILIAL+AV_CODPRC
	If SAV->( MsSeek( xFilial("SAV") + cItPrc ) )
		If SAV->AV_TIPO == "1" 		//-- Dado Num�rico
			uRet := 0 
		Else
			uRet := ""
		EndIf
	Else
		uRet := 0 
	EndIf
EndIf        

//-- Restaura as Areas Auxiliares
aEval(aAreasAux, { |x| RestArea(x) } )

//-- Restaura a Area selecionada
RestArea( aArea )

Return uRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Err �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tratamento de erro da rotina                                ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATA317Err( uRet )
uRet := Nil
Break
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Psq �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Pesquisa na NewGetDados                                     ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MATA317Psq(oGd)
Local oDlgPsq
Local oCbx
Local oBigGet
Local cOrd	 := ""
Local aOrd	 := {}
Local cCampo := Space(70)
Local lSeek	 := .F.
Local nSeek	 := 0
Local nOrdem := 1


//-- Monta Op��es de pesquisa pelos campos do aHeader de Tipo Num�rico, Caractere e combobox com Caractere.
aEval( oGd:aHeader, { |x| Iif(x[8] $ "C;N",;
										aAdd( aOrd, x[1] ),;
										Nil) } )

DEFINE MSDIALOG oDlgPsq FROM 00,00 TO 100,490 PIXEL OF oMainWnd TITLE STR0012 //"Pesquisa"

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlgPsq FONT oDlgPsq:oFont ON CHANGE nOrdem := oCbx:nAt
@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlgPsq ENABLE ACTION (lSeek:=.T.,oDlgPsq:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlgPsq ENABLE ACTION oDlgPsq:End()

ACTIVATE MSDIALOG oDlgPsq CENTERED

If lSeek
	If oGd:aHeader[nOrdem][8] == "C" .And. AllTrim(Upper(cCampo)) $ "SIM/NAO/N�O/N�O/N�O/N�O"
		cCampo := Iif( AllTrim(Upper(cCampo)) == "SIM","1","2")
	EndIf

	If oGd:aHeader[nOrdem][8] == "N" .And.  ("," $ cCampo)
		cCampo := StrTran(cCampo,",",".")
	EndIf
	aSort( oGd:aCols,,, { |x,y| x[nOrdem] < y[nOrdem]} )

	nSeek := Ascan(oGd:aCols, {|x| Iif(	oGd:aHeader[nOrdem][8] == "C",;
													AllTrim(Upper(cCampo)) == Left( AllTrim(Upper(x[nOrdem])), Len(AllTrim(cCampo))),;
													Iif( 	oGd:aHeader[nOrdem][8] == "N",;
															x[nOrdem] >= Val(cCampo),;
															.F.);
													) })
	If nSeek > 0
		If ( oGd:LinhaOk() )
			oGd:GoTo( nSeek )
			oGd:oBrowse:Refresh()
			oGd:oBrowse:SetFocus()
			If ( ValType( oGd:oBrowse:bChange ) == "B" )
				Eval( oGd:oBrowse:bChange )
			EndIf
		EndIf
	Else
		Help(" ",1,"REGNOIS")
	EndIf
EndIf

Return Nil

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MATA317Rfs �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Refresh do c�lculo pela planilha de Forma��o de Pre�os      ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MATA317Rfs( aHeadPar, aColsPar, nLine, lTela )
Local aAreas 		:= {	SB1->(GetArea()),;
								GetArea()}
Local nPosPrd		:= aScan( aHeadPar, { |x| "_CODPRO" $ x[2] })
Local nPosPSug		:= aScan( aHeadPar, { |x| "_PRCSUG" $ x[2] })
Local nBegin		:= Iif( nLine == Nil, 1, nLine )
Local nEnd			:= Iif( nLine == Nil, Len( aColsPar ), nLine )
Local aVet   		:= {}
Local nPreco 		:= 0 
Local lSvCols		:= (Type("aCols") == "A"	.And. Type("aHeader") == "A")
Local aSvCols, aSvHead
Local lRet        := .T.

Default lTela := .F.

Pergunte( "MATA317", .F. )

Private cArqMemo   := aParam[1]
Private lDirecao   := .T.  
Private nQualCusto := 1
Private cProg      := "R430"
Private lPesqRev   := .T.
       
Pergunte( "MTC010", .F. )  //-- Este pergunte serve para a funcao MC010Forma, sem os MV_PARXX ocorre error log.

SB1->( DbSetOrder( 1 ))
For nLine := nBegin To nEnd
	If SB1->( MsSeek( xFilial("SB1") + aColsPar[nLine][nPosPrd] ))

		If lSvCols
			aSvCols	:= aClone( aCols )
			aSvHead	:= aClone( aHeader )
		EndIf

      aEval( aHeadPar, {|x,y| Iif( 	Left(x[2],6) == "ITPRC_",;
      										MA317IniPr( Substr( x[2], 7 ), aColsPar[nLine][y] ),;
      										Nil ) })
		If lForm2
			If lTela
				MC010Form2("SB1",SB1->(Recno()),98,1,2)
			Else
				aVet := MC010Form2( "SB1", SB1->( RecNo() ), 98,,, .F. )
			EndIf
		Else
			If lTela
				MC010Forma("SB1",SB1->(Recno()),98,1,2)
			Else
				aVet := MC010Forma( "SB1", SB1->( RecNo() ), 98,,, .F. )
			EndIf
		EndIf

		MA317FimPr()
		
		If lSvCols
			aCols		:= aClone( aSvCols )
			aHeader	:= aClone( aSvHead )
		EndIf
				                                    
		If !lTela 
			If ValType( aVet ) == "A"
				If (nPos := aScan( aVet, {|x| RTrim( x[3] ) == "#PUBLICACAO" }) ) > 0   
					nPreco := aVet[nPos,6]
				EndIf
			Else
				lRet := .F.
				Exit
			EndIf								
		EndIf
	EndIf
	If !lTela
		aColsPar[nLine][nPosPSug] := nPreco
	EndIf
Next nLine

Pergunte( "MATA317", .F. )

//-- Restaura as Areas 
aEval( aAreas, { |x| RestArea(x) } )

Return lRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MA317IniPr�Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Armazena conteudo de um Item de Precifica��o. Utilizado     ���
���          � para integra��o com Forma��o de pre�os                      ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MA317IniPr( cItPrc, uValor )
Local nPos

If aDadPrc == Nil
	aDadPrc := {}
EndIf

If ( nPos := aScan( aDadPrc, {|x| x[1] == cItPrc } ) ) > 0 
	aDadPrc[nPos][2] := uValor
Else
	aAdd( aDadPrc, { cItPrc, uValor })
EndIf

Return 

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MA317FimPr�Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Libera vari�vel est�tica utilizada na integra��o com a      ���
���          � Planilha de Forma��o de pre�os                              ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MA317FimPr()
aDadPrc := Nil
Return




/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA317Legenda� Autor � Daniel Leme        � Data � 19.02.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse ou retorna a ���
���          � para o BROWSE                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA317                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MA317Legenda(cAlias, nReg)

Local aLegenda := 	{	{"BR_VERDE", STR0013},;  //"Categoria x Produto sem valor de precifica��o"
					    	{"BR_AZUL", STR0014 }}      //"Categoria x Produto com valor de precifica��o"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}                                          
	Aadd(uRetorno, { '!Empty(Posicione("SCI",1,xFilial("SCI")+ACU->ACU_COD,"CI_CODPRO"))', aLegenda[2][1] } )
	Aadd(uRetorno, { 'Empty(Posicione("SCI",1,xFilial("SCI")+ACU->ACU_COD,"CI_CODPRO"))' ,  aLegenda[1][1] } )
Else
	BrwLegenda(cCadastro, STR0015, aLegenda, 09) //"Legenda"
Endif

Return uRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MenuDef   �Autor  � Daniel Leme        � Data �  10/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Menu Funcional                                              ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � MATA317                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina	:= {{ STR0003, "AxPesqui"  , 0, 1 },;  //"Pesquisar"
			          { STR0016, "MATA317Mnt", 0, 2 },;  //"Visualizar"
			          { STR0017, "MATA317Mnt", 0, 4 },;  //"Cadastrar"
			          { STR0018, "MATA317Mnt", 0, 5 },; //"Excluir"
			          { STR0015, "MA317Legenda", 0 , 6} }  //"Legenda"
     
Return(aRotina)

//-------------------------------------------------------------------
/*{Protheus.doc} LoadCat
Carrega estrutura da categoria

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadCat(aCatSup,aCatPro,cCodPai)

ACU->(dbSetOrder(1))
If !EMPTY(cCodPai) .AND. (ACU->(dbSeek(xFilial("ACU")+cCodPai)))
	cCodPai:=ACU->ACU_CODPAI 

	While !ACU->(EOF()) .AND. RTrim(ACU->ACU_CODPAI) == RTrim(cCodPai)
		aAdd(aCatSup, ACU->ACU_COD )
		aAdd(aCatPro, ACU->ACU_COD )		
     	LoadCat(@aCatSup,@aCatPro,ACU->ACU_CODPAI)                 
     	ACU->(dbSkip())    	
    EndDo	
EndIf 
    
Return