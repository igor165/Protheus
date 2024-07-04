#INCLUDE "CTBS060.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWIZARD.CH"

//Compatibiliza��o de fontes 30/05/2018

Static __lDefTop	:= IfDefTopCTB()  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CTBS060    � Autor �Microsiga	        � Data �04/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Wizard para cadastro das contas contabeis, utilizadas no 	  ���
���          �registro I015 das escritura��es do tipo A e Z.	  		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 											                  ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBS060( cEmp, cChave, cLinHash )

Local aArea    	:= GetArea()
Local aHeader	:= {}
Local lFim    	:= .F.
Local oBold		:= Nil 
Local cLivro	:= CS0->CS0_TIPLIV 
                         
Private aColsCSJ	:= {} 
Private aCamposCSJ	:= {'CSJ_CONTA','CSJ_NOMECT','CSJ_IMPORT'}
Private oWzrdEcd	:= Nil

Default cLinHash := ""

If ValidTpEscrit( cChave, cLinHash )

	//���������������Ŀ
	//�Monta o aheader�
	//�����������������
	aHeader := CriaHeader()
	//�������������Ŀ
	//�Monta o acols�
	//���������������
	aColsCSJ := CriaAcolsCSJ( cChave, cLinHash )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	//������������������������������������������������������������������������Ŀ
	//� Montagem da Interface                                                  �
	//��������������������������������������������������������������������������
	// P1
	DEFINE WIZARD oWzrdEcd ;
	TITLE STR0001 + cEmp; //""Plano de Conta - Registor I015" - Empresa: " //"Plano de Conta - Registro I015 - "
	HEADER STR0002;	 //"Aten��o" //"Aten��o"
	MESSAGE "" ;
	TEXT STR0003 + CRLF + STR0004; //"Essa rotina tem como objetivo ajud�-lo no cadastro e/ou" + CRLF + " selec��o das contas a serem apresentadas no registro I015 //"Essa rotina tem como objetivo ajud�-lo no cadastro e/ou"###" sele��o das contas a serem apresentadas no registro I015"
	NEXT {|| .T.} ;
	FINISH {||.T.}
       

	// P2
	CREATE PANEL oWzrdEcd  ;
	HEADER STR0005; //"Cadastro do Plano de Contas" //"Cadastro do Plano de Contas"
	MESSAGE "";
	BACK {|| .T.} ;
	FINISH {||ECDGravaCsj(oGetDB:Acols, cChave, cLinHash)}
 
	
	oGetDB:= MsNewGetDados():New(003,003,120,284, GD_INSERT+GD_UPDATE+GD_DELETE ,,,,{"CSJ_CONTA", "CSJ_NOMECT"},/*freeze*/,100000,/*fieldok*/,/*superdel*/,/*cDelOk*/,oWzrdEcd:GetPanel(2),aHeader,aColsCSJ)
	@ 122,0 BUTTON STR0006 SIZE 070,010 ACTION {||ECDImpConta(cChave,oGetDB:Acols, cLinHash, cLivro)} PIXEL OF oWzrdEcd:GetPanel(2) //"Importar Pl. de Conta"

	ACTIVATE WIZARD oWzrdEcd CENTERED
Else
	MsgAlert(STR0007) //"Procedimento utilizado apenas para as escritura��es do tipo ''A'' e ''Z''."
EndIf
RestArea( aArea )

Return lFim   


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CTBS060BR  � Autor �Microsiga	        � Data �04/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o para cadastro das contas contabeis, utilizadas no 	  ���
���          �registro I015 das escritura��es do tipo B e R.	  		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 											                  ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBS060BR( cEmp, cChave, cLinHash, cLivro )

Local aArea    	:= GetArea()
Local aHeader	:= {}
Local lFim    	:= .F.
Local oBold		:= Nil
Local oDlgBR	:= Nil
Local cSelConta	:= STR0009 //"Sele��o de Contas"
                         
Private aColsCSJ	:= {} 
Private aCamposCSJ	:= {'CSJ_CONTA','CSJ_NOMECT','CSJ_IMPORT'}
Private oGetDB	:= Nil

Default cLinHash := ""
Default cLivro := ""

If ValidTpEscrit( cChave, cLinHash )

	//���������������Ŀ
	//�Monta o aheader�
	//�����������������
	aHeader := CriaHeader()
	//�������������Ŀ
	//�Monta o acols�
	//���������������
	aColsCSJ := CriaAcolsCSJ( cChave, cLinHash )  
	
	
	DEFINE MSDIALOG oDlgBR TITLE cSelConta From 9,0 To 37,81 OF oMainWnd
	
	oGetDB := MsNewGetDados():New(003,003,190,318, GD_INSERT+GD_UPDATE+GD_DELETE ,,,,{"CSJ_CONTA", "CSJ_NOMECT"},/*freeze*/,100000,/*fieldok*/,/*superdel*/,/*cDelOk*/,oDlgBR,aHeader,aColsCSJ)
	@ 197,2 BUTTON STR0006 SIZE 070,010 ACTION {||ECDImpConta(cChave,oGetDB:Acols, cLinHash, cLivro)} PIXEL OF oDlgBR //"Importar Pl. de Conta"
	@ 197,252 BUTTON "Ok" SIZE 030,010 ACTION {||ECDGravaCsj(oGetDB:Acols, cChave, cLinHash),oDlgBR:End()} PIXEL OF oDlgBR
	@ 197,284 BUTTON STR0015 SIZE 030,010 ACTION {||oDlgBR:End()} PIXEL OF oDlgBR //"Cancelar"
			
	ACTIVATE MSDIALOG oDlgBR CENTERED
	
EndIf
RestArea( aArea )

Return lFim   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlContaCS3  �Autor  �Equipe CTB        � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o plano de contas da tabela CS3 de acordo com o     ���
���          �Codigo da Revis�o                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PlContaCS3( cChave, cLinHash, cLivro )
Local aArea    		:= GetArea()
Local aStruct	 	:= {}
Local lMarcado		:= .F.
Local cAliasCT1	    := "CT1"
Local cFilCT1	 	:= xFilial("CT1")
Local nX			:= 0
Local aConta		:= {}
Local cTpConta   := ""

Default cChave 		:= ""    
Default cLinHash 	:= ""
Default cLivro := ""

If cLivro == 'A'
	cTpConta := '1'
ElseIf cLivro == 'Z'
	cTpConta := '1'
Else
	cTpConta := '2'
EndIf

If __lDefTop
	cQuery	:= "SELECT * FROM " + RetSQLName( "CT1" ) ;
			+ "  WHERE CT1_FILIAL = '" + cFilCT1 + "'";
			+ "  AND CT1_CLASSE = '" + cTpConta + "'" ;
			+ "  AND D_E_L_E_T_ = ' '";
			+ "	 AND NOT EXISTS(SELECT CSJ_CONTA FROM "+RetSQLName( "CSJ" )+" ";
								+" WHERE CSJ_FILIAL = '"+cFilCT1+"' " ;
								+" AND D_E_L_E_T_ = ' '	";
								+" AND CSJ_CODREV = '"+cChave+"' ";
								+" AND CSJ_HASH = '"+cLinHash+"' ";
								+" AND CSJ_CONTA = CT1_CONTA ) ";
			+ " ORDER BY CT1_CONTA "
							
   
	cQuery := ChangeQuery(cQuery) 
	
	cAliasCT1 := GetNextAlias()
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT1,.T.,.T.)
	
	aStruct   := CT1->(dbStruct())
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" .And. FieldPos( aStruct[nX][1] ) <> 0
			TcSetField( cAliasCT1, aStruct[nX][1], aStruct[nX][2], aStruct[nX][3], aStruct[nX][4] )
		EndIf
	Next nX
Else
	DbSelectArea( "CT1" )
	DbSetOrder(1)
	MsSeek( cFilCT1 + cChave ) 
EndIf
 
dbSelectArea(cAliasCT1)
DbGoTop()
While (cAliasCT1)->( !Eof() )
	
		aAdd(aConta ,Array(3) )    
		aConta[Len(aConta)][1] 	:= lMarcado/*Sele��o*/
		aConta[Len(aConta)][2] 	:= (cAliasCT1)->CT1_CONTA /*Codigo*/
		aConta[Len(aConta)][3] 	:= (cAliasCT1)->CT1_DESC01/*Descri��o*/
		
	(cAliasCT1)->(dbSkip())
EndDo


If __lDefTop
	(cAliasCT1)->( dbCloseArea() )
	dbSelectArea( "CT1" )
EndIf

RestArea( aArea )

Return aConta         
             


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � EcdSelConta � Autor  � Elton C. / Renato	� Data 01.02.10���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Troca marcador entre x e branco                            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � EcdSelConta(nIt,aArray)                                    ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � aArray                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� ExpN1 = Numero da posicao                                  ���
���           � ExpA1 = Array contendo as empresas a serem consolidadas    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function EcdSelConta(nIt,aArray,lEmp)

Local aArea    	:= GetArea()
Local nCont	:= 1
Local cContaAtu	:= ""
Local cDescAtu	:= ""

Default lEmp := .F.

If lEmp
	cContaAtu	:= aArray[nIt][2] //Codigo
	cDescAtu	:= aArray[nIt][3] //Descri��o

	For nCont := 1 to Len(aArray)
		If nCont <> nIt //Nao verificar o que esta sendo marcado/desmarcado
			If aArray[nCont][1]/*Sele��o*/ .And. cContaAtu == aArray[nCont][2]/*Codigo da Conta*/
				Return(aArray)
			EndIf
		EndIf
	Next	
EndIf

//Array que recebe o array com os itens selecionados
aArray[nIt,1] := !aArray[nIt,1]

RestArea( aArea )
Return aArray


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaHeader�Autor  �Equipe CTB          � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o aHeader						                   	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaHeader()
Local aArea	:= GetArea()
Local aHeader 	:= {}
Local nIx		:= 0

DbSelectArea( "SX3" )
DbSetOrder(2)

For nIx := 1 To Len( aCamposCSJ )
	If SX3->( MsSeek( aCamposCSJ[ nIx ] ) )
		aAdd( aHeader, {AlLTrim( X3Titulo() )	, ;	// 01 - Titulo
		SX3->X3_CAMPO	, ;	// 02 - Campo
		SX3->X3_Picture	, ;	// 03 - Picture
		SX3->X3_TAMANHO	, ;	// 04 - Tamanho
		SX3->X3_DECIMAL	, ;	// 05 - Decimal
		"VldImporConta()", ;	// 06 - Valid
		SX3->X3_USADO  	, ;	// 07 - Usado
		SX3->X3_TIPO   	, ;	// 08 - Tipo
		SX3->X3_F3		, ;	// 09 - F3
		SX3->X3_CONTEXT	, ;	// 10 - Contexto
		SX3->X3_CBOX	, ; // 11 - ComboBox
		SX3->X3_RELACAO	} )	// 12 - Relacao
	Endif
Next

RestArea( aArea )

Return aHeader


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaAcolsCS2�Autor  �Equipe CTB        � Data �  02/25/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria e atualiza o aCols                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaAcolsCSJ( cChave, cLinhaHash )

Local aArea    		:= GetArea()
Local aStruct	 	:= {}
Local cAliasCSJ	    := "CSJ"
Local cFilCSJ	 	:= xFilial("CSJ")
Local nX			:= 0
Local aCols			:= {}

Default cChave 		:= ""
Default cLinhaHash	:= ""

If __lDefTop
	cQuery	:= "SELECT * FROM " + RetSQLTab( "CSJ" ) ;
			+ "  WHERE CSJ_FILIAL = '" + cFilCSJ + "'";
			+ "    AND CSJ_CODREV = '" + cChave + "'" ;
			+ "    AND CSJ_HASH = '" + cLinhaHash + "'" ;
			+ "    AND D_E_L_E_T_ = ' '"
   
	cQuery := ChangeQuery(cQuery) 
	
	cAliasCSJ := GetNextAlias()
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSJ,.T.,.T.)
	
	aStruct   := CSJ->(dbStruct())
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" .And. FieldPos( aStruct[nX][1] ) <> 0
			TcSetField( cAliasCSJ, aStruct[nX][1], aStruct[nX][2], aStruct[nX][3], aStruct[nX][4] )
		EndIf
	Next nX
Else
	DbSelectArea( "CSJ" )
	DbSetOrder(1)
	MsSeek( cFilCSJ + cChave ) 
EndIf
 
dbSelectArea(cAliasCSJ)
DbGoTop()
While (cAliasCSJ)->CSJ_FILIAL == cFilCSJ;
		.And. (cAliasCSJ)->CSJ_CODREV == cChave;
 		.And. (cAliasCSJ)->( !Eof() ) 
 		

	aAdd(aCols,{(cAliasCSJ)->CSJ_CONTA,;
				(cAliasCSJ)->CSJ_NOMECT,;
				(cAliasCSJ)->CSJ_IMPORT,.F.})

	(cAliasCSJ)->(dbSkip())
EndDo

If __lDefTop
	(cAliasCSJ)->( dbCloseArea() )
	dbSelectArea( "CSJ" )
EndIf

RestArea( aArea )

Return aCols    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ECDImportAcols �Autor  �Equipe CTB     � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importa os dados e atualiza o acols	                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECDImportAcols(aContaSel)

Local aArea  	:= GetArea()
Local nX	 	:= 0 
Local aCols 	:= oGetDB:aCols 
Local nAt		:= oGetDB:nAt
Local aHeader   := oGetDB:aHeader
Local nPos		:= aScan(aHeader, {|x| Alltrim(x[2]) == "CSJ_CONTA" })

Default aContaSel := {}

If Len(aContaSel) > 0
	For nX := 1 To Len(aContaSel)
		If aContaSel[nX][1]
			If !aScan(aCols,{|x| Alltrim(x[nPos]) == Alltrim(aContaSel[nX][2])}) > 0
				If Empty(aCols[1][1]) .And. !aCols[1][4]
					aCols[1][1] := aContaSel[nX][2]
					aCols[1][2] := aContaSel[nX][3]
					aCols[1][3] := "1"
				Else
					aAdd(aCols, {aContaSel[nX][2],aContaSel[nX][3],'1',.F.})
				EndIf
			EndIf
		EndIf
	Next
EndIf


oGetDB:Acols := aCols
oGetDB:ForceRefresh()

RestArea( aArea )

Return 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldImporConta  �Autor  �Equipe CTB     � Data �  02/25/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a conta foi importada. Tendo em vista que, em   ���
���          �caso de importa��o o usuario n�o podera alterar os dados    ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldImporConta()

Local aArea    	:= GetArea()
Local lRet 		:= .T.
Local aCols 	:= oGetDB:aCols 
Local nAt		:= oGetDB:nAt
Local aHeader   := oGetDB:aHeader
Local nPos		:= aScan(aHeader, {|x| Alltrim(x[2]) == "CSJ_IMPORT" })

If ( Len(aCols)> 0 ) .And. ( Alltrim( aCols[nAt][nPos] ) == '1' )
	MsgAlert(STR0008) //"Dados importados n�o podem ser alterados."
	lRet := .F.
EndIf

RestArea( aArea )
Return lRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ECDImpConta 	 �Autor  �Equipe CTB     � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Utilizado para importar as contas selecionadas		      ���
���          �														      ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECDImpConta(cChave, aColsGD, cLinHash, cLivro) 

Local aArea    		:= GetArea()
Local aContaSel		:= {}
Local oDlg			:= Nil
Local cSelConta		:= STR0009 //"Sele��o de Contas"
Local oConta		:= Nil 
Local aHeaderSel 	:= {}
Local oComb			:= Nil    
Local oAll			:= Nil
Local lAll       	:= .F.
Local cResult		:= ""
Local cPesquisa		:= Space(30)
Local oOk 			:= LoadBitmap( GetResources(), "LBOK")
Local oNo			:= LoadBitmap( GetResources(), "LBNO")

Default cLinHash := ""
Default cLivro := ""

aHeaderSel := ARRAY(3)
aHeaderSel[1]	:= ""  		
aHeaderSel[2] 	:= STR0010	 //"Codigo"
aHeaderSel[3] 	:= STR0011 //"Descri��o"

If ValidAcols( aColsGD )
	aContaSel := PlContaCS3( cChave, cLinHash, cLivro )
	
	If Len(aContaSel) > 0
		DEFINE MSDIALOG oDlg TITLE cSelConta From 9,0 To 37,81 OF oMainWnd
		
		oConta := TWBrowse():New( 1.5,0.8,310,170,Nil,aHeaderSel, Nil, oDlg, Nil, Nil, Nil,Nil,;
		{|| aContaSel := EcdSelConta( oConta:nAt, aContaSel, .T. ), oConta:Refresh() })
		
		oConta:SetArray( aContaSel )
		
		oConta:bLine := {|| {;
		If( aContaSel[oConta:nAt,1] , oOk , oNo ),;   //Selec��o
			aContaSel[oConta:nAt,2],;                 //C�digo da Conta
			aContaSel[oConta:nAt,3],;                 //Descri��o
			}}
			
			@ 09, 07 COMBOBOX oComb VAR cResult ITEMS {STR0012,STR0013} SIZE 80, 58 OF oDlg PIXEL //"1-C�digo"###"2-Descri��o"
			@ 09, 90 MSGET cPesquisa SIZE	100, 9 OF oDlg PIXEL
			@ 09,192 BUTTON STR0014 SIZE 030,010 ACTION {||oConta:nAt := ECDPesqConta(SUBSTRING(cResult,1,1), oConta:aArray,cPesquisa,oConta:nAt)} PIXEL OF oDlg //"Pesquisar"
			@ 195,254 BUTTON "Ok" SIZE 030,010 ACTION {||ECDImportAcols(oConta:aArray),oDlg:End()} PIXEL OF oDlg
			@ 195,285 BUTTON STR0015 SIZE 030,010 ACTION {||oDlg:End()} PIXEL OF oDlg //"Cancelar"
			@ 195,05 CHECKBOX oAll VAR lAll PROMPT STR0016 PIXEL SIZE 90,09;  //"Marca Todas ?"
		ON CLICK ( aEval(aContaSel, { |x| x[1] := lAll }), oConta:Refresh() ) OF oDlg
			
			
			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			 MsgAlert(STR0017) //"N�o existe registro a ser importado"
		EndIf
EndIf



RestArea( aArea )
Return  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ECDPesqConta 	 �Autor  �Equipe CTB     � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Posiciona no item pesquisado							      ���
���          �														      ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECDPesqConta(nOpc, aConta, cPesq, nPos)

Local aArea    	:= GetArea()
Local nRet 	:= 1
Local nX	:= 0

Default nOpc 	:= 1 
Default aConta 	:= {}

If !Empty(cPesq)
	If nOpc == "1"
		For nX := nPos To Len(aConta)
			If Alltrim(cPesq) $Alltrim(aConta[nX][2])
				nRet := nX
				Exit
			EndIf
		Next
	Else
		For nX := nPos To Len(aConta)
			If (UPPER(Alltrim(cPesq))$UPPER(Alltrim(aConta[nX][3])))
				nRet := nX
				Exit
			EndIf
		Next
	EndIf
EndIf

RestArea( aArea )
Return nRet     



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ECDGravaCsj 	 �Autor  �Equipe CTB     � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava os dados na tabela CSJ							      ���
���          �														      ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECDGravaCsj(aConta, cChave, cLinHash)

Local aArea    	:= GetArea()
Local nX			:= 0
Local cAliasCSJ	    := "CSJ"
Local cFilCSJ	 	:= xFilial("CSJ")
Local lRet			:= .T.

Default cLinHash := ""

If ValidAcols( aConta )
	EcdDelCSJ( cChave, cLinHash )//Limpa a tabela CSJ
	If Len(aConta) > 0
		DbSelectArea(cAliasCSJ)
		For nX := 1 To Len(aConta)
			If !aConta[nX][4] .And. !Empty(aConta[nX][1])
				RecLock(cAliasCSJ,.T.)
				
				CSJ_FILIAL 	:= cFilCSJ
				CSJ_CODREV 	:= cChave
				CSJ_CONTA  	:= aConta[nX][1]
				CSJ_NOMECT 	:= aConta[nX][2]
				CSJ_IMPORT 	:= aConta[nX][3]
				If !(CS0->CS0_TIPLIV $ "A")
					CSJ_HASH	:= cLinHash
				Else
					CSJ_HASH	:= ""
				EndIf
				MsUnLock()
			EndIf
		Next
	EndIf
Else
	lRet := .F.
EndIf

RestArea( aArea )                                     
Return lRet  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EcdDelCSJ	  �Autor  �Equipe CTB        � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Limpa a tabela CSJ 		                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EcdDelCSJ( cChave, cLinHash )
Local aArea    		:= GetArea()
Local cFilCSJ	 	:= xFilial("CSJ")

Default cChave 		:= ""
Default cLinHash	:= ""

If Len(cLinHash) = 0
	cLinHash	:= " "
Endif

cQuery	:= "DELETE FROM " + RetSQLName( "CSJ" );
			+ "  WHERE CSJ_FILIAL = '" + cFilCSJ + "'";
			+ "    AND CSJ_CODREV = '" + cChave + "'" ;
			+ "    AND CSJ_HASH = '" + cLinHash + "'" ;
			+ "    AND D_E_L_E_T_ = ' '"

If TcSqlExec( cQuery ) <> 0
	UserException( TCSqlError() )
Endif

RestArea( aArea )

Return  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidTpEscrit�Autor  �Equipe CTB       � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a escritura��o � do tipo A,B,R ou Z             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidTpEscrit( cChave, cLinHash )

Local aArea    		:= GetArea()
Local cAliasCS0	    := "CS0"
Local cFilCS0	 	:= xFilial("CS0")
Local lRet			:= .F.

Default cChave 		:= ""
Default cLinHash	:= ""

If __lDefTop

	If Empty(cLinHash)
		cQuery	:= "SELECT COUNT(CS0_TIPLIV) CONTADOR FROM " + RetSQLTab( "CS0" ) ;
				+ "  WHERE CS0_FILIAL = '" + cFilCS0 + "'";
				+ "    AND CS0.CS0_CODREV = '" + cChave + "'" ;
				+ "    AND (CS0.CS0_TIPLIV IN('A','Z')) ";
				+ "    AND D_E_L_E_T_ = ' '"
	   
		cQuery := ChangeQuery(cQuery) 
		
		cAliasCS0 := GetNextAlias()
		
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCS0,.T.,.T.)
	Else
		lRet := .T.
	EndIf
EndIf
 
dbSelectArea(cAliasCS0)
DbGoTop()

If Empty(cLinHash)
	If (cAliasCS0)->CONTADOR > 0
		lRet := .T.
	EndIf
EndIf
If __lDefTop
	(cAliasCS0)->( dbCloseArea() )
	dbSelectArea( "CS0" )
EndIf

RestArea( aArea )

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidAcols   �Autor  �Equipe CTB       � Data �  02/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a linha est� em edi��o		                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Central de Escritura��o                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidAcols( aColsGD )
Local lRet 	:= .T. 
Local nX	:= 0

Default aColsGD := {}

For nX := Iif(Len(aColsGD)>1, 1, 2) To Len(aColsGD)
    If Empty(aColsGD[nX][1]) .And. !aColsGD[nX][4]
       lRet := .F.
       MsgAlert(STR0018) //"Existe linha em edi��o !"
    EndIf
Next
	
Return lRet   

