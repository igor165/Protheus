#INCLUDE "GPECALOB.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPECALOB  � Autor � Equipe Advanced RH    � Data �16/03/2007���
���          �			|		| Igor Franzoi			|      |		  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calendario de Obrigacoes.                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAPON/SIGAGPE                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Ch/FNCS   �  Motivo da Alteracao                ���
�������������������������������������������������������������������������Ĵ��
���Raquel Hager�19/08/14�TPVBZR     � Inclusao do fonte na versao 12.     ���
���            �        �           � Ajustes quanto a carga automatica.  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPECALOB()   
Local aArea		:= GetArea()
//Variaveis para dimensionamento dos objetos em tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aCols	  		:= {}
Local aHeader 		:= {}
Local oFont			:= NIL
Local oDlg			:= NIl
Local nOpc
Local cAlias  		:= "LA1"
Local cModRot		:= "2"
Local cAliasLA1		:= GetNextAlias()

Local bSet15   		:= {|| If ( oGetDados:TudoOk(), nOpc := GrvOK(oDlg) , nOpc:= 0) } //Botoes da EnchoiceBar
Local bSet24		:= {|| oDlg:End()} //Botoes EnchoiceBar

Private aRecno 	 	:= {}
Private aAuxCols 	:= {}
Private nAuxCol
Private aAuxHeader
Private nAuxHeader
Private cNumSeq
Private oGetDados	:= NIL

//Opcao padrao para alteracao
DEFAULT nOpc	:= 4

   If nModulo == 9 //FISCAL
   		cModRot := "1"
   EndIf
	// Posiciona na Area de Trabalho
	DbSelectArea("LA1")     
	LA1->(dbSetOrder(1)) // LA1_FILIAL+LA1_SEQNUM
	
	//Verifica existencia de dados na tabela, se vazio carrega parametros originais
	BeginSql alias cAliasLA1
		SELECT COUNT(1) AS CONTADOR
		FROM %table:LA1% LA1
		WHERE  LA1.LA1_FILIAL = %exp:FWxFilial()% 
			   AND LA1.LA1_MODULO = %exp:cModRot%
			   AND LA1.%notDel%
	EndSql
	DbSelectArea("LA1")     
	LA1->(dbSetOrder(1)) // LA1_FILIAL+LA1_SEQNUM
	If !(cAliasLA1)->(Eof()) .And. (cAliasLA1)->CONTADOR == 0
		FirstLoad()	     
	EndIf
	(cAliasLA1)->(dbCloseArea())
	
	DbSelectArea("LA1")     
	LA1->(dbSetOrder(1)) // LA1_FILIAL+LA1_SEQNUM
	
	// Monta as Dimensoes dos Objetos        					   
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5 , 5 }
	aAdd( aObjCoords , { 100 , 080 , .T. , .F. } )
	aAdd( aObjCoords , { 100 , 100 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize, aObjCoords )
	
	aCols := MntCols(FormDat(dDataBase),nOpc,@aHeader,cAlias)
	
	If Empty(aCols)
		nOpc  := 3
		aCols := MntCols(FormDat(dDataBase),nOpc,@aHeader,cAlias)
	EndIf
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 0,0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // "Calendario de Obrigacoes"
	
	//Cria o objeto calendario
	oCalend:=MsCalend():New(aObjSize[1][1]   , aObjSize[1][2],oDlg)
	
	//Valida as datas que irao ser vizualizadas na getdados
	aAuxCols 	:= ChgVal(cAlias,aCols,aHeader,FormDat(oCalend:dDiaAtu),@nOpc) 
	aAuxHeader  := aHeader
	nAuxHeader	:= Len(aHeader)
	
	//Carrega auxiliar p/ validacao de inclusao
	nAuxCol := Len(aAuxCols)
	
	oCalend:dDiaAtu		:= dDataBase
	
	//Marca os dias das obrigacoes em vermelho
	McDay(@oCalend,aAuxCols,aAuxHeader,FormDat(oCalend:dDiaAtu))
	
	/*Quando houver alteracao de mes, refaz validacoes e
	 realoca as obirgacoes no objetos getdados para
	 aquele mes determinado*/
	oCalend:bChangeMes	:= {||	SeqNum(aHeader,oGetDados:aCols,.F.),;
								RlArray(aAuxHeader,@aCols,oGetDados:aCols),; 
								oGetDados:aCols:= aAuxCols := ChgVal(cAlias,aCols,aHeader,FormDat(oCalend:dDiaAtu),@nOpc),;
								nAuxCol := Len(aAuxCols),; 
								McDay(@oCalend,aAuxCols,aAuxHeader,FormDat(oCalend:dDiaAtu)),;
								oGetDados:ForceRefresh(),;
								oGetDados:oBrowse:Refresh(),;
								oGetDados:Refresh(),;
								oDlg:Refresh() }
	
								//oCalend:Disable()
	
	//Cria get dados 
	oGetDados := MsNewGetDados():New(	aObjSize[2][1],;
										aObjSize[2][2],;
									    aObjSize[2][3],;
										aObjSize[2][4],;
										GD_UPDATE + GD_INSERT + GD_DELETE,;
										"LinOk",;
										"TudoOk",;
										NIL,;
										NIL,;
										NIL,;
										NIL,;
										NIL,;
										NIL,;
										"CalobVldDel",; 							//Validacao p/ delecao
										oDlg,;
										aAuxHeader,;
										aAuxCols;
										)
										
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg , bSet15 , bSet24 )  )
	
	If nOpc =  1	//Tratamento para insercao dos dados
	
		SeqNum(aHeader,oGetDados:aCols,.F.)
		RlArray(aAuxHeader,@aCols,oGetDados:aCols)
		AltObrig(cAlias,aHeader,aCols)
	
	EndIf
	
	RestArea(aArea) 

Return( Nil )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � AltObrig		�Autor�Equipe Advanced RH � Data �19/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao �Finaliza o dialogo e retorna opcao de gravacao				�
�����������������������������������������������������������������������Ĵ
� Uso      �GPECALOB                                                    �
�������������������������������������������������������������������������*/
Static Function GrvOK(oDlgFns)
Local nOpcGrv 
Default nOpcGrv := 1

oDlgFns:End()

Return( nOpcGrv )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � AltObrig		�Autor�Equipe Advanced RH � Data �19/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Grava os registros na tabela (inclui, altera e exclui)	 	�
�          � Calendario de Obrigacoes									�
�����������������������������������������������������������������������Ĵ
�Parametros� cAlias 	= alias da tabela								�
�		   � aHeader = array contendo aHeader da GetDados (Campos)		�
�		   � aCols 	= array contendo aCols (Linhas)						�
�������������������������������������������������������������������������*/
Static Function AltObrig(cAlias,aHeader,aCols)
Local nContH
Local nContC
Local nIns      // Auxiliar para localizar a posicao do campo
Local nCampo	// Posicao do campo
Local nPosSeq	:= 0	// Posicao do numero de sequencia no aHeader
Local nPosMes	:= 0	// Posicao do mes/dia no aHeader
Local nPosDes	:= 0	// Posicao da descricao no aHeader
Local nVal		// Variavel de controle

	For nVal := 1 To Len(aHeader)
		If FieldPos(aHeader[nVal,2]) > 0
			If aHeader[nVal,2] == "LA1_SEQNUM"
				nPosSeq := FieldPos(aHeader[nVal,2])
			ElseIf aHeader[nVal,2] == "LA1_MESDIA"
				nPosMes := FieldPos(aHeader[nVal,2])
			ElseIf aHeader[nVal,2] == "LA1_DESCR"
				nPosDes := FieldPos(aHeader[nVal,2])
			EndIf			
		EndIf
	Next
	
	CursorWait()
	
	dbSelectArea(cAlias)
	dbSetOrder(1)
	
	For nContH := 1 To Len(aHeader)
		If FieldPos( aHeader[nContH,2] ) >= 0
			If aHeader[nContH,2] == "LA1_SEQNUM"
				For nContC := 1 To Len(aCols)
					dbSeek( xFilial(cAlias) + aCols[nContC,nContH] )
					If Found()
						If aCols[nContC,Len(aHeader)+1] == .F.
	
							RecLock(cAlias, .F.)
							
							For nIns := 1 To Len(aHeader)
								If aHeader[nIns,2] == "LA1_MESDIA"
	                            	aCols[nContC,nIns] := DatSBar(aCols[nContC,nIns],.T.)
								EndIf
								nCampo := FieldPos( aHeader[nIns,2] )
								FieldPut( nCampo, aCols[nContC,nIns] )
							Next
	
							MsUnlock()
												
						Else
	
							RecLock(cAlias, .F.)
							dbDelete()
							MsUnlock()
	
						EndIf					
					Else
						If aCols[nContC,Len(aHeader)+1] == .F.
						
							If nPosSeq > 0 .And.  nPosMes > 0 .And. nPosDes > 0
								If !Empty( aCols[nContC,nPosSeq] ) .and. ;
									!Empty( aCols[nContC,nPosMes] ) .and. ;
									!Empty( aCols[nContC,nPosDes] )
		
									RecLock(cAlias, .T.)
								
									For nIns := 1 To Len(aHeader)
										nCampo := FieldPos( aHeader[nIns,2] )
										If aHeader[nIns,2] == "LA1_MESDIA"
	
		    	                        	// Quando informado somente o Dia com um caracter na digitacao FORCA
	    		                        	// a gravacao com Dois caracteres para criar o Dia corretamente.
	    		                        	// Exemplo: Digitado 7, ao gravar no arquivo ficara 07.
	    	    	                    	// Esta acao eh necessaria, pois ao digitar o dia com um caracter, o
	    	        	                	// registro sumia da grade devido a gravacao "errada" por assim dizer.
											aCols[nContC,nIns] := If(	Len( Alltrim( DatSBar(aCols[nContC,nIns],.T.) ) ) < 2, ;
																		StrZero( Val( DatSBar(aCols[nContC,nIns],.T.) ), 2 ), ;
																		DatSBar(aCols[nContC,nIns],.T.) )
										EndIf								
										If aHeader[nIns,2] == "LA1_FILIAL"
											aCols[nContC,nIns] := xFilial(cAlias)
										EndIf
										FieldPut( nCampo, aCols[nContC,nIns] )
									Next
		
									MsUnlock()						
								
								EndIf	
							 Endif			
						EndIf									
					EndIf
				Next								
			EndIf
		EndIf
	Next
	
	CursorArrow()

Return( Nil )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � RlArray		�Autor�Equipe Advanced RH � Data �23/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao �Validacao das alteracoes na getdados p/ insercao, alteracao	�
�          �e exclusao dos dados no array pai (aCols)					�
�          �Calendario de Obrigacoes									�
�����������������������������������������������������������������������Ĵ
�Parametros�aCab 	 = conteudo de aHeader da GetDados (Campos)			�
�		   �aCols 	 = array contendo aCols (Linhas)					�
�		   �aAuxCols = array contendo aAuxCols (Linhas da GetDados)		�
�������������������������������������������������������������������������*/
Static Function RlArray(aCab,aCols,aAuxCol)
Local nContH	// Auxiliar para percorrer aHeader
Local nContC	// Auxiliar para percorrer aCols
Local nChg		// Auxiliar para efetuar a alteracao no array pai
Local nSeg		// Auxiliar para verificar p/ comparar os dois array
Local nInsC
Local nVal
Local nPosSeq	:= 0	// Posicao do numero de sequencia no aHeader
Local nPosMes	:= 0	// Posicao do mes/dia no aHeader
Local nPosDes	:= 0	// Posicao da descricao no aHeader

	For nVal := 1 To Len(aCab)
		If FieldPos(aCab[nVal,2]) > 0
			If aCab[nVal,2] == "LA1_SEQNUM"
				nPosSeq := FieldPos(aCab[nVal,2])
			ElseIf aCab[nVal,2] == "LA1_MESDIA"
				nPosMes := FieldPos(aCab[nVal,2])
			ElseIf aCab[nVal,2] == "LA1_DESCR"
				nPosDes := FieldPos(aCab[nVal,2])
			EndIf			
		EndIf
	Next
	
	// Percorrer a Header para encontrar a posicao do campo
	For nContH := 1 To Len(aCab)
		If FieldPos(aCab[nContH,2]) >= 0	
			If aCab[nContH,2] == "LA1_SEQNUM"
			   If nAuxCol == Len(aAuxCol)
					// Percorrer aCols para encontrar o mesmo registro do acols auxiliar (aAuxCols)
			   		For nContC := 1 To Len(aCols)		     
				 		For nSeg := 1 To Len(aAuxCol)
							// Verifica se a linha nao esta deletada
							If aAuxCol[ nSeg, Len(aCab)+1 ] == .F.						
					 			//Verifica se o Recno igual para posicionar no registro
				     			If aCols[ nContC,nContH ] == aAuxCol[ nSeg, nContH ] 
									//Se for igual, efetua alteracao no acols pai (aCols)
									For nChg := 1 To Len(aAuxCol[nSeg])
										aCols[ nContC, nChg ] := aAuxCol[ nSeg, nChg ]
					    			Next		     			     
			     				EndIf	 
				 			Else
				 				If aCols[ nContC,nContH ] == aAuxCol[ nSeg, nContH ]
									aCols[ nContC, Len(aCab)+1 ] := aAuxCol[ nSeg, Len(aCab)+1 ]
				 				EndIf			 
			     			EndIf	
			     		Next			     
			   		Next
			   // Verificar inclusao e/ou delecao de registros
			   Else
					//Se o array pai e menor que o array auxiliar
					//entao ocorreram incllusoes de linhas
					//MsgAlert(nAuxCol) mostra o valor de nAuxCol
					//MsgAlert(Len(aAuxCol)) mostra o valor total de linhas do array aAuxCols
					//quando for diferente ocorreu inclusao de linhas no acols
			   		If nAuxCol < Len(aAuxCol)
						//Atribui o tamanho do aCols para a variavel 
						//de controle de insercao
			   			If nPosSeq > 0 .And.  nPosMes > 0 .And. nPosDes > 0
				   			For nInsC := nAuxCol+1 To Len(aAuxCol) Step 1
		
								If !Empty( aAuxCol[nInsC,nPosSeq] ) .and. ;
									!Empty( aAuxCol[nInsC,nPosMes] ) .and. ;
									!Empty( aAuxCol[nInsC,nPosDes] )
									//Insere novo registro em aCols (array pai)
									AADD( aCols, aAuxCol[nInsC] )
								EndIf
				   			Next
	                   Endif
						// Percorrer aCols para encontrar o mesmo registro do acols auxiliar (aAuxCols)
			   			For nContC := 1 To Len(aCols)		     
				 			For nSeg := 1 To Len(aAuxCol)
								//Verifica se a linha nao esta deletada
								If aAuxCol[ nSeg, Len(aCab)+1 ] == .F.
					 				//Verifica se o Recno igual para posicionar no registro
				     				If aCols[ nContC,nContH ] == aAuxCol[ nSeg, nContH ] 
										//Se for igual, efetua alteracao no acols pai (aCols)
										For nChg := 1 To Len(aAuxCol[nSeg])
											aCols[ nContC, nChg ] := aAuxCol[ nSeg, nChg ]
					    				Next		     			     
			     					EndIf	 
				 				Else
				 					If aCols[ nContC,nContH ] == aAuxCol[ nSeg, nContH ]
										aCols[ nContC, Len(aCab)+1 ] := aAuxCol[ nSeg, Len(aCab)+1 ]
				 					EndIf
			     				EndIf
			     			Next
			   			Next
			   		EndIf
			   EndIf	
			EndIf  
		EndIf
	Next
	
Return( .T. )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � ChgVal			�Autor�Equipe Advanced RH � Data �19/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao �Valida o dia. Reconstroi o array que ficara na GetDados		�
�          �Calendario de Obrigacoes									�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias 	 = alias da tabela									�
�		   �aColsAll = array contendo aCols Pai (Linhas)				�
�		   �aCab     = array contendo aHeader (Campos)					�
�		   �aCab     = array contendo aHeader (Campos)					�
�		   �aDat     = data do calendario								�
�		   �nOpc     = Opcao para a GetDados							�
�������������������������������������������������������������������������*/
Static Function ChgVal(cAlias,aColsAll,aCab,dDat,nOpc)
Local aDay 		// Guarda os dados apenas do dia
Local nContH    // Auxiliar para percorrer aHeader
Local nContC	// Auxiliar para percorrer aCols 
Local nPosSeq  := 0	// Guarda posicao do numero de sequencia
Local nPosMes  := 0
Local nPosMod  := 0	// Guarda posicao do LA1_Modulo

	aDay  := {}
	
	Default nOpc := 4
	
	For nContH := 1 To Len(aCab)
		If FieldPos (aCab[nConth,2]) > 0
			If aCab[nContH,2] == "LA1_MODULO"
				nPosMod := FieldPos (aCab[nContH,2])
			EndIf
		EndIf
	Next
	
	For nContH := 1 To Len(aCab)
		//Verifica o cabecalho se naum estiver zerado
		If FieldPos (aCab[nContH,2]) > 0 
			//Verifica qual a posicao do campo LA1_MESDIA no a aHeader
			If aCab[nContH,2] == "LA1_MESDIA"
	
			   /*Faz uma pesquisa em aCols a procura do dia desejado
			   para definir um novo aCols com os elementos somente
			   da data determinada no calendario*/
			   For nContC := 1 To Len(aColsAll)
				 /*Verifica a qual modulo o registro pertence
				   so exibe os registros do modulo atual*/
				 If ( ( aColsAll[nContC, nPosMod ] == "2" ) .and. nModulo == 7 ) .or. ;
				 	( ( aColsAll[nContC, nPosMod ] == "1" ) .and. nModulo == 9 )
				     //Verifica se data igual, senao nao aparece na getdados
				     aColsAll[nContC, FieldPos (aCab[nContH,2]) ] := DatSBar( aColsAll[nContC, FieldPos (aCab[nContH,2]) ] )
				     If ( Len( AllTrim( aColsAll[nContC, FieldPos (aCab[nContH,2]) ] ) ) ) == 2 .OR. ; //Verifica dia
						( SubStr( aColsAll[nContC, FieldPos (aCab[nContH,2]) ],3,2 ) == SubStr(dDat,3,2) .And. ;
							Len( AllTrim( aColsAll[nContC, FieldPos (aCab[nContH,2]) ]) ) == 4 ) .OR. ; //Verifica mes
				     	( AllTrim( aColsAll[nContC, FieldPos (aCab[nContH,2]) ] ) == dDat )			  //Verifica dia/mes/ano						
							aColsAll[nContC, FieldPos (aCab[nContH,2]) ] :=  DatBar( aColsAll[nContC, FieldPos (aCab[nContH,2]) ] )
							AADD( aDay, aColsAll[nContC] )		 
					 ElseIf Len( AllTrim( aColsAll[nContC, FieldPos (aCab[nContH,2]) ] ) ) == 8 
							If SubStr(AllTrim( aColsAll[nContC, FieldPos (aCab[nContH,2]) ] ) ,3) == SubStr( dDat,3)
								aColsAll[nContC, FieldPos (aCab[nContH,2]) ] :=  DatBar( aColsAll[nContC, FieldPos (aCab[nContH,2]) ] )
								AADD( aDay, aColsAll[nContC] )				
							EndIf
				     EndIf
				 EndIf  
			   Next			 
			EndIf
		EndIf
	Next
	
	//Caso nao exista registro em aDay, habilitar insercao
	If Empty(aDay)
		For nContH := 1 To Len(aCab)
			If FieldPos(aCab[nContH,2]) > 0
				If aCab[nContH,2] == "LA1_SEQNUM"
					nPosSeq := FieldPos(aCab[nContH,2])
				ElseIf aCab[nContH,2] == "LA1_MESDIA"
					nPosMes := FieldPos(aCab[nContH,2])
				EndIf			
			EndIf
		Next			
		
		If	nPosSeq > 0 .And. nPosMes > 0
			If ( !Empty(aColsAll[Len(aColsAll),nPosSeq]) ) .And. ;
				( Empty(aColsAll[Len(aColsAll),nPosMes]) )
				AADD( aDay, aColsAll[Len(aColsAll)] )
				nOpc := 4
			Else
				nOpc := 3
			EndIf
		 Else 
		 	nOpc := 3
		 Endif
	Else
		nOpc := 4
	EndIf

Return( aDay )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � McDay			�Autor�Equipe Advanced RH � Data �19/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao �Marca os dias das obrigacoes no calendario em vermelho 		�
�          �Calendario de Obrigacoes									�
�����������������������������������������������������������������������Ĵ
�Parametros�oCalend = objeto do calendario mostrado em tela				�
�		   �aCols   = linhas que contem os dias que irao para a GetDados�
�		   �aCab	= array contendo aHeader (Campos)					�
�		   �aDat     = data do calendario								�
�������������������������������������������������������������������������*/
Function McDay(oCalend,aCols,aCab,dDat)
Local nDia		:= 0
Local nContH
Local nContC

	// Marca os dias a serem mostrados	                          
	For nContH := 1 To Len(aCab)
		//Verifica o cabecalho se naum estiver zerado
		If FieldPos (aCab[nContH,2]) > 0 
			//Verifica qual a posicao do campo LA1_MESDIA no a aHeader
			If aCab[nContH,2] == "LA1_MESDIA"
			   /*Faz uma pesquisa em aCols a procura do dia desejado
			   para marcar a data determinada no calendario*/
			   For nContC := 1 To Len(aCols)
			     //Verifica se data igual, se for marca o dia no objeto calendario
			     If ( Len( AllTrim( DatSBar(aCols[nContC, FieldPos (aCab[nContH,2]) ]) ) ) ) == 2 .OR. ; //Verifica dia
					( SubStr( DatSBar(aCols[nContC, FieldPos (aCab[nContH,2]) ]),3,2 ) == SubStr(dDat,3,2) ) .OR. ; //Verifica mes
			     	( AllTrim( DatSBar(aCols[nContC, FieldPos (aCab[nContH,2]) ]) ) == dDat )					  //Verifica dia/mes/ano	
			     	nDia := AllTrim( SubStr( DatSBar(aCols[nContC, FieldPos (aCab[nContH,2]) ]),1,2 ) )
			     	oCalend:AddRestri( ;
			     		Day ( Ctod(nDia+"/"+StrZero(Month(oCalend:dDiaAtu),02)+"/"+StrZero(Year(oCalend:dDiaAtu),04),'ddmmyy') ) ,;
			     		CLR_HRED,CLR_WHITE )
			     EndIf
			   Next
			EndIf
		EndIf
	Next

Return ( .T. )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � ValDay			�Autor�Equipe Advanced RH � Data �26/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Valida a data digitado no campo mes-dia					�
�          � Calendario de Obrigacoes									�
�����������������������������������������������������������������������Ĵ
�Parametros�cDat = recebe um caracter sem formatacao para validar, 		�
� 		   �lDat = para enviar uma data passar parametro .T.			�
�������������������������������������������������������������������������*/
Function ValDay(cDat,lDat)
Local nDay
Local nMonth
Local nYear
Local nCont
Local lRet	 // Retorno da funcao
Local lFlag	 // Flag de verificacao dos caracteres digitados

DEFAULT lDat := .F.

	// Se for passado um tipo data para a funcao deve-se
	// passar lDat = .T. para fazer a conversao e validacao
	If lDat
		cDat := DToc(cDat)
	EndIf
	
	// Retira as barras
	cDat := StrTran(cDat , '/', '' )
	// Tira os espacos da data
	cDat := AllTrim(cDat)
	
	// Atribui true ao retorno, caso nao caia em nenhuma inconsistencia
	//  retorna true
	lRet := .T.
	
	// Caso nao encontre nenhuma irregularidade nos caracteres digitados
	// retorna true
	lFlag := .T.
	
	// Percorre os caracteres para fazer validacao
	If Len(cDat) <= 8
		For nCont := 1 To Len(cDat)
			If ( Asc( SubStr(cDat,nCont,1) ) < 48 ) .or. ( Asc( SubStr(cDat,nCont,1) ) > 57 )
				lFlag := .F.
			EndIf
		Next
	Else
		lFlag := .F.
	EndIf
	
	If lFlag
	
		If Empty(cDat)
			// Valida se o campo data esta em branco
			MsgAlert(OemToAnsi(STR0010)) //Data em branco!
			lRet := .F.
		ElseIf ( Len(cDat) <= 0 ) .or.	( Len(cDat) == 3 ) .or. ;
				( Len(cDat) == 5 ) .or. ( Len(cDat) == 7 )
			// Valida se o campo data tem o numero de caracteres correto
			MsgAlert(OemToAnsi(STR0011)) //Data Inv�lida
			lRet := .F.
		Else  
			
			If ( Len(cDat) == 1 )
				cDat := "0"+cDat
			ElseIf ( Len(cDat) == 6 )
				cDat := SubStr(cDat,1,2) +;
						SubStr(cDat,3,2) +;
						SubStr( AllTrim( Str( Year( Date() ) ) ),1,2 ) +;
						SubStr(cDat,5,2)
			EndIf
		
			nDay 	:= Val( SubStr(cDat,1,2) )
			nMonth  := Val( SubStr(cDat,3,2) )
			nYear	:= Val( SubStr(cDat,5,4) )
	
			If ( ( ( nDay > 31 ) .or. ( nDay < 1 ) ) .or. ( ( nDay > 29 ) .and. ( nMonth == 2 ) ) ) ;
				.and. !Empty( SubStr(cDat,1,2) )
				MsgAlert(OemToAnsi(STR0007)) // "Dia invalido!"
				lRet := .F.
			ElseIf ( nMonth == 2 ) .and. ( nDay == 29 ) .and. !Empty( SubStr(cDat,5,4) )
				If Empty( Ctod( SubStr(cDat,1,2) + "/" + SubStr(cDat,3,2) + "/"+ SubStr(cDat,5,4) ) )
					MsgAlert(OemToAnsi(STR0007)) // "Dia invalido!"
					lRet := .F.	
				EndIf
			ElseIf ( ( nMonth > 12 ) .or. ( nMonth < 1) ) .and. !Empty( SubStr(cDat,3,2) )
				MsgAlert(OemToAnsi(STR0008)) // "Mes invalido!"
				lRet := .F.
			ElseIf ( nYear < 1900 ) .and. !Empty( SubStr(cDat,5,4) )
				MsgAlert(OemToAnsi(STR0009)) // "Ano invalido!"
				lRet := .F.
			EndIf
	
		EndIf
	
	Else
		MsgAlert(OemToAnsi(STR0012)) // "Parametro data incorreto!"
		lRet  := .F.
	EndIf

Return( lRet )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � FormDat		�Autor�Equipe Advanced RH � Data �19/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Transfoma a data											�
�����������������������������������������������������������������������Ĵ
�Parametros� dData = recebe a database do sistema						�
�������������������������������������������������������������������������*/
Static Function FormDat(dData)
         
cData := replace(dtoc(dData),"/","")

Return cData

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � DatBar			�Autor�Equipe Advanced RH � Data �27/04/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Insere as barras na data									�
�����������������������������������������������������������������������Ĵ
�Parametros� cData = recebe a data que vem da tabela					�
�������������������������������������������������������������������������*/
Static Function DatBar(cData)
Local cDatRet

	cData := StrTran( cData, '/', '' )
	
	If ( Len(AllTrim(cData)) == 8 )
		cDatRet := SubStr(AllTrim(cData),1,2)+"/"+SubStr(AllTrim(cData),3,2)+"/"+SubStr(AllTrim(cData),7,2)
	ElseIf ( Len(AllTrim(cData)) == 4)
		cDatRet := SubStr(AllTrim(cData),1,2)+"/"+SubStr(AllTrim(cData),3,2)
	ElseIf ( Len(AllTrim(cData)) == 6 )
		cDatRet := SubStr(AllTrim(cData),1,2)+"/"+SubStr(AllTrim(cData),3,2)+"/"+SubStr(AllTrim(cData),5,2)
	Else
		cDatRet := cData
	EndIf

Return( cDatRet )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � DatSBar		�Autor�Equipe Advanced RH � Data �27/04/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Insere as barras na data									�
�����������������������������������������������������������������������Ĵ
� Retorno  � cDatRet = retorna a data com barras Ex: (01/01/07)			�
�����������������������������������������������������������������������Ĵ
�Parametros�cData = recebe a data que vem da tabela						�
�������������������������������������������������������������������������*/
Static Function DatSBar(cData,lFmt)
Local cDatRet
Default lFmt := .T.
	
	cDatRet := StrTran(cData , '/', '')
	
	If lFmt
		If Len(AllTrim(cData)) == 6
			cDatRet := SubStr(cData,1,2)+Substr(cData,3,2)+SubStr( AllTrim( Str(Year(Date())) ),1,2 )+SubStr(cData,5,2)
		EndIf
	EndIf

Return( cDatRet )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � MntCols		�Autor�Equipe Advanced RH � Data �19/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Verifica se existem registros para o dia selecionado 		�
�          � Calendario de Obrigacoes									�
�������������������������������������������������������������������������*/
Static Function MntCols(dData,nOpc,aHeader,cAlias)
Local aCols := {}
Local cChv	:= xFilial("LA1")
Local nUso
Local aVir   := {}
Local aVis   := {}
Local aCampo := {"LA1_FILIAL"}
Local lNotField  := .F.
Local lEverField := .T.
Local lVirField  := .T.

	// Colunas e linhas da get dados aHeader/aCols
	// Obs: para a funcao GDMontaCols funcionar com parametros de visualizar os campos que 
	// deseja-se, o campo na tabela deve estar marcado como USADO
	aCols:= LA1->(	GDMontaCols(;
								@aHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
								@nUso				,;	//02 -> Numero de Campos em Uso
								@aVir,;			//03 -> [@]Array com os Campos Virtuais
								@aVis,;			//04 -> [@]Array com os Campos Visuais	
								"LA1",;			//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
								aCampo,;		//06 -> Opcional, Campos que nao Deverao constar no aHeader
								@aRecno,;		//07 -> [@]Array unidimensional contendo os Recnos
								"LA1",;			//08 -> Alias do Arquivo Pai
								cChv,;			//09 -> Chave para o Posicionamento no Alias Filho
								NIL,;			//10 -> Bloco para condicao de Loop While
								NIL,;			//11 -> Bloco para Skip no Loop While
								.T.,;			//12 -> Se Havera o Elemento de Delecao no aCols 
								NIL,;			//13 -> Se cria variaveis Publicas
								NIL,;			//14 -> Se Sera considerado o Inicializador Padrao
								NIL,;			//15 -> Lado para o inicializador padrao
								lEverField,;	//16 -> Opcional, Carregar Todos os Campos
								lVirField,;		//17 -> Opcional, Nao Carregar os Campos Virtuais
								NIL,;			//18 -> Opcional, Utilizacao de Query para Selecao de Dados
								NIL,;			//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
								NIL,;			//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
								NIL,;			//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
								lNotField,;		//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
								NIL,;			//23 -> Verifica se Deve Checar se o campo eh usado
								NIL,;			//24 -> Verifica se Deve Checar o nivel do usuario
								NIL,;			//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
								NIL,;			//26 -> [@]Array que contera as chaves conforme recnos
								NIL,;			//27 -> [@]Se devera efetuar o Lock dos Registros
								NIL,;			//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
								NIL,;			//29 -> Numero maximo de Locks a ser efetuado
								NIL,;			//30 -> Utiliza Numeracao na GhostCol
								NIL,;			//31 -> Carrega os Campos de Usuario
								nOpc;
							);
						 )         
						 
	SeqNum(aHeader,aCols,.T.)

Return( aCols )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � TudoOk			�Autor�Equipe Advanced RH � Data �27/04/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Confere a linha digitada									�
�          � Calendario de Obrigacoes									�
�����������������������������������������������������������������������Ĵ
�Uso       � GPECALOB                                                   �
�������������������������������������������������������������������������*/
Function TudoOk( oDados )

Local lTudOk := .T.

Return( lTudOk )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � LinOk			�Autor�Equipe Advanced RH � Data �27/04/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descri��o � Confere a linha digitada									�
�          � Calendario de Obrigacoes									�
�����������������������������������������������������������������������Ĵ
� Uso      � GPECALOB                                                   �
�������������������������������������������������������������������������*/
Function LinOk( oDados )
Local lLinOk                                  							
Local nPosDes := If(GdFieldPos("LA1_DESCR")>0,GdFieldPos("LA1_DESCR"),0)
Local nPosPer := If(GdFieldPos("LA1_PERIOD")>0,GdFieldPos("LA1_PERIOD"),0)
Local nPosMes := If(GdFieldPos("LA1_MESDIA")>0,GdFieldPos("LA1_MESDIA"),0)

Default lLinOk := .T.

	If nPosDes > 0 .And.  nPosMes > 0 .And. nPosPer > 0
		If Empty( oGetDados:aCols[oGetDados:oBrowse:nAt,nPosDes] ) .or. Empty( oGetDados:aCols[oGetDados:oBrowse:nAt,nPosMes] ) .or. Empty( oGetDados:aCols[oGetDados:oBrowse:nAt,nPosPer] )
			lLinOk := .F.
			MsgAlert(STR0013) //"Deve ser informado a Descri��o, Per�odo e a Data de Recolhimento"
		EndIf			
	EndIf

Return( lLinOk )

	
/*
�����������������������������������������������������������������������Ŀ
�Funcao    � CargaIni		�Autor�Equipe Advanced RH � Data �16/03/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Insere as obrigacoes padroes iniciais no arquivo do 		�
�          � Calendario de Obrigacoes									�
�������������������������������������������������������������������������*/
Static Function FirstLoad()
Local cAlias := "LA1"
Local nCont
Local aDados := {}

	If AllTrim(cPaisLoc) == "BRA"
	
		//RH
		//Inicializando array aDados com parametros inicias para a tabela
		//                 FILIAL, NUMSEQ,      MODULO, DESCRICAO, 												PERIODO, DIAMES, ANTECIPA,    HABILITA, ACAO, STATUS, PRAZO
		AAdd(aDados, { FWxFilial() , "000001" , "2"  , "GPS(GUIA) - Rec. Contrib. Previdenci�rias(FOLHA)"		, "3" , "20" 	, "2" 		 , "1" , "GPER240"  , "1", 1 } )
		AAdd(aDados, { FWxFilial() , "000002" , "2"  , "GPS(ELETR�NICO) - Rec. Contrib. Previdec.(FOLHA)" 		, "3" , "20" 	, "2" 		 , "1" , "GPEM240"  , "1", 1 } )
		AAdd(aDados, { FWxFilial() , "000003" , "2"  , "GPS(GUIA) - Rec. Contrib. Previdenci�rias (13�)"  		, "3" , "20/12" , "2" 		 , "1" , "GPER240"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000004" , "2"  , "GPS(ELETR�NICO) - Rec. Contrib. Previdenc.(13�)"  		, "3" , "20/12" , "2" 		 , "1" , "GPEM240"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000005" , "2"  , "SEFIP-Sist.Emp.Reg.FGTS e Inf.Prev.Social (FOLHA)"		, "3" , "07" 	, "2" 		 , "1" , "GPEM610"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000006" , "2"  , "GFIP(GUIA) -Rec.FGTS e Inf. � Previd�ncia (FOLHA)"		, "3" , "07" 	, "2" 		 , "1" , "GPER240"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000007" , "2"  , "SEFIP-Sist.Emp.Reg.FGTS e Inf.Prev.Social (13�)"  		, "3" , "30/01" , "2" 		 , "1" , "GPEM610"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000008" , "2"  , "GFIP(GUIA) -Rec. FGTS e Inf. � Previd�ncia (13�)" 		, "3" , "30/01" , "2" 		 , "1" , "GPEM240"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000009" , "2"  , "CAGED(ELET) -Cad. Geral Empregados e Desempregados"	, "3" , "07" 	, "2" 		 , "1" , "GPEM400"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000010" , "2"  , "Rela��o Admitidos/Demitidos ao MTE"			   		, "3" , "07" 	, "2" 		 , "1" , "GPER490"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000011" , "2"  , "GRCS(GUIA) -Recolhimento Contrib. Sindicais"			, "3" , "28" 	, "2" 		 , "1" , "GPER170"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000012" , "2"  , "DARF(GUIA) -Recolhimento do IRRF"						, "3" , "10" 	, "2" 		 , "1" , "GPER050"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000013" , "2"  , "DARF(GUIA) -Recolhimento PIS Empresa"			   		, "3" , "15" 	, "2" 		 , "1" , "GPER055"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000014" , "2"  , "RAIS(Magn�tico) -Rela��o Anual Informa��es Socias"		, "3" , "16/03" , "2" 		 , "1" , "GPEM500"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000015" , "2"  , "DIRF(Magn�tico)-Declara��o Imposto Retido na Fonte"	, "3" , "16/02" , "2" 	     , "1" , "GPEM550"  , "1" , 1 } )
		AAdd(aDados, { FWxFilial() , "000016" , "2"  , "INFORME RENDIMENTO - PESSOA F�SICA"					, "3" , "28/02" , "2" 		 , "1" 	, "GPEM560"  , "1" , 1 })
		AAdd(aDados, { FWxFilial() , "000017" , "2"  , "INFORME RENDIMENTO - PESSOA JUR�DICA"					, "3" , "28/02"	, "2" 		 , "1" 	, "GPEM560"  , "1" , 1 })
		
		//Fiscal
		AAdd(aDados, { FWxFilial() , "000018" , "1"  , "DNF", "3" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000019" , "1"  , "DIPJ", "7" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000020" , "1"  , "DCTF", "3" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000021" , "1"  , "Sintegra", "3" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000022" , "1"  , "Manad", "3" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000023" , "1"  , "SincoNF", "3" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000024" , "1"  , "Dacon", "3" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000025" , "1"  , "Simples Federal", "3" , "30" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000026" , "1"  , "Comprovante Anual de Reten��o", "7" , "2802" , "2" , "1" , ""  , "1" , 1 } 	)
		AAdd(aDados, { FWxFilial() , "000027" , "1"  , "Comprovante Mensal de Reten��o", "3" , "05" , "2" , "1" , ""  , "1" , 1 } 	)
	
	Else
		AAdd(aDados, { FWxFilial() , "000001" , "2"  , "", "3" , "01" , "" , "" , ""  , "1" , 0 } 	)
		AAdd(aDados, { FWxFilial() , "000002" , "1"  , "", "3" , "01" , "" , "" , ""  , "1" , 0 } 	)
	EndIf
		
	dbSelectArea(cAlias)
	dbSetOrder(1)
	
	CursorWait()
		
	For nCont := 1 To Len(aDados)
			
		RecLock(cAlias, .T.)
			
		(cAlias)->LA1_Filial := aDados[nCont][1]
		(cAlias)->LA1_SEQNUM := aDados[nCont][2]
		(cAlias)->LA1_MODULO := aDados[nCont][3]
		(cAlias)->LA1_DESCR  := OemToAnsi(aDados[nCont][4])
		(cAlias)->LA1_PERIOD := aDados[nCont][5]
		(cAlias)->LA1_MESDIA := AllTrim(aDados[nCont][6])
		(cAlias)->LA1_ANTECI := aDados[nCont][7]
		(cAlias)->LA1_HABILI := aDados[nCont][8]
		(cAlias)->LA1_ACAO   := aDados[nCont][9]
		(cAlias)->LA1_STATUS := aDados[nCont][10]
		(cAlias)->LA1_PRAZO  := aDados[nCont][11]
			
		MSUnlock()
			
	Next
		
	CursorArrow()
	
Return( Nil )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � SeqNum			�Autor�Equipe Advanced RH � Data �27/04/2007�
�          �           		|	  | Igor Franzoi      |      |			�
�����������������������������������������������������������������������Ĵ
�Descricao � Numerador Sequencial										�
�����������������������������������������������������������������������Ĵ
�Uso       � GPECALOB                                                   �
�������������������������������������������������������������������������*/
Static Function SeqNum(aHeader,aCols,lCrg)
Local nSeqNum
Local nVal 
Local nContC
Local nContH
Local nPosMes	:= 0
Local nPosDes	:= 0

	nSeqNum := cNumSeq
	
	For nContH := 1 To Len(aHeader)
		If FieldPos(aHeader[nContH,2]) > 0
			If aHeader[nContH,2] == "LA1_DESCR"
				nPosDes := FieldPos(aHeader[nContH,2])
			ElseIf aHeader[nContH,2] == "LA1_MESDIA"
				nPosMes := FieldPos(aHeader[nContH,2])
			EndIf			
		EndIf
	Next
	
	If lCrg
	
		If !Empty(Len(aCols))
			nSeqNum := Len(aCols)		
		Else
			nSeqNum := 1
	    EndIf
	    
	Else
	
	    If nPosMes	> 0 .And. nPosDes	> 0
			For nVal := 1 To Len(aHeader)
				If FieldPos(aHeader[nVal,2]) > 0
					If aHeader[nVal,2] == "LA1_SEQNUM"
					   For nContC := 1 To Len(aCols)
						If !Empty( aCols[nContC, nPosMes] ) .and. !Empty( aCols[nContC, nPosDes] )
							If Empty( aCols[nContC, FieldPos(aHeader[nVal,2]) ] )             	
		                		nSeqNum++					
	
								// Validacao do nSeqNum dentro do aCols para nao permitir Duplicidade
								While (AllTrim(StrZero(nSeqNum,6))) <= (aCols[(Len(aCols)-1),FieldPos(aHeader[nVal,2])])
		                			nSeqNum++
								EndDo
	
								aCols[nContC, FieldPos(aHeader[nVal,2]) ] := AllTrim( StrZero( nSeqNum,6 ) )
							EndIf
						EndIf	
					   Next
					EndIf			
				EndIf	
			Next 
	     Endif
	EndIf
	
	cNumSeq := nSeqNum
	
Return( Nil )

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � CalobVldDel	�Autor�Leandro Drumond    � Data �10/05/2012�
�����������������������������������������������������������������������Ĵ
�Descricao � Valida delecao da linha									�
�����������������������������������������������������������������������Ĵ
�Uso       � GPECALOB                                                   �
�������������������������������������������������������������������������*/
Function CalobVldDel()
Local lRet 		:= .T.
Local nStatus 	:= FieldPos("LA1_STATUS")
	
	If oGetDados:aCols[n,nStatus] == "2"
		lRet := .F.
		MsgAlert(STR0014) // "Nao e possivel excluir uma obrigacao com estado concluido."
	EndIf

Return( lRet )
