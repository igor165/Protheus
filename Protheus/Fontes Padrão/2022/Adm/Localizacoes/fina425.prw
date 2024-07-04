#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FINA425.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FINA425  � Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de clientes que cobrador atende                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINA425 (void)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINA425( )

///////
// Var:
Private aCpsObg := { "AR_CODCLI", "AR_LOJCLI", "AR_SEQUENC" } // Campos Obrigatorios para MsGetDados
Private aRotina := MenuDef()
// Define o cabecalho da tela de atualizacoes
Private cCadastro := OemToAnsi(STR0006) //"Clientes X Cobrador"
// Var:
///////

DbSelectArea("SAR")
DbSetOrder(3) // AR_FILIAL+AR_CODCOBR+AR_SEQUENC

mBrowse(6,1,22,75,"SAR",,,,,,)

RETURN( .T. )     



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FINA425Frm� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Gerencia a Inclusao, Alteracao, Visualizacao e Exclusao    ���
���          � na Lista de Clientes antendidos por cobrador               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINA425Frm()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA425                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINA425Frm( cAlias, nReg, nOpc )

///////
// Var:
Local oDlg			:= NIL
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local oSize			:= NIL
Local oPanel		:= NIL
Local lOk 			:= .F.   
Local cTitSxCobCod	:= RetTitle("AR_CODCOBR")
Local cTitSxCobNom	:= RetTitle("AR_COBNOME")

Private aHeader   		:= {}
Private aCols			:= {}
Private nUsado			:=	0
Private oGet			:= NIL
// Var:
///////

INCLUI := nOpc == 3

RegToMemory("SAR", INCLUI )

///////////////////////////////////////
// Monta aHeader: utilizado na getdados
F425Ahead("SAR") 
DbSelectArea("SAR")
DbSetOrder(1) // AR_FILIAL+AR_CODCOBR+AR_CODCLI+AR_LOJCLI+AR_ITEM

nUsado	:= Len(aHeader)      

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Clientes por cobrador"
					 FROM 120,000 TO 516,665 OF oMainWnd PIXEL	

oSize := FwDefSize():New(.T.,,,oDlg)                                                      

oSize:AddObject("ENCHOICE",100,015,.T.,.T.)
oSize:AddObject("GETDADOS",100,085,.T.,.T.)                 

oSize:lProp := .T.

oSize:Process()

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") + 000	SAY cTitSxCobCod SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") + 040	MSGET oGet_1 VAR M->AR_CODCOBR PICTURE PesqPict("SAR","AR_CODCOBR") ;
																Valid ( ExistCpo("SAQ") ) .and. ( FIN425Cobr() ) .and. ( FIN425VlCp() ) ;
																F3 "SAQ" WHEN INCLUI SIZE 35,10 OF oDlg PIXEL  

//////////////////////////////////////////
// Necessario para simular gatilho no caso
// de somente mostrar dados na tela
If  !INCLUI
	M->AR_COBNOME := Posicione("SAQ",1,xFilial("SAR")+M->AR_CODCOBR,"AQ_NOME")
Endif

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") + 080	SAY cTitSxCobNome SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") + 105	MSGET oGet_2 VAR M->AR_COBNOME PICTURE PesqPict("SAR","AR_COBNOME") ;      
                        										WHEN .F. SIZE 130,10 OF oDlg PIXEL 

/////////////////////////////////////
// Monta aCols: utilizado na getdados
F425Acols(nOpc)

      ////////////////////////////
      // Visualiza          Exclui
If     ( nOpc == 2 ) .or. ( nOpc == 5 ) 

	oGet := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),;
								oSize:GetDimension("GETDADOS","COLINI"),;
								oSize:GetDimension("GETDADOS","LINEND"),;
								oSize:GetDimension("GETDADOS","COLEND"),;
								nOpc,"AllwaysTrue","AllwaysTrue","+AR_ITEM",.T.,,,,,,,,,oDlg)   
	
	
	If ( nOpc == 2 )
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()} )			
	Else
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| F425Dele(),oDlg:End()},{||oDlg:End()} )
	EndIf
	
      ////////////////////////////
      // Inclui             Altera	
ElseIf ( nOpc == 3 ) .or. ( nOpc == 4 ) 

	oGet := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),;
								oSize:GetDimension("GETDADOS","COLINI"),;
								oSize:GetDimension("GETDADOS","LINEND"),;
								oSize:GetDimension("GETDADOS","COLEND"),;
								nOpc,"FI425LinOk" ,"FI425TudOk","+AR_ITEM",.T.,,1,,9999,,,,,oDlg)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := oGet:TudoOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()} )
	
EndIf


If lOk
    FIN425Grav(nOpc)
Endif


DbSelectArea("SAR")
DbSetOrder(3) // AR_FILIAL+AR_CODCOBR+AR_SEQUENC


RETURN( .T. )



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F425Acols� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � F425Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA425                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F425Acols( nOpc )

Local nCnt, n, nI, nPos

////////////////////
// Montagem do aCols

If nOpc == 3 // Inclusao

	aCols := Array(1,nUsado+1)

	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

    nPos		  := aScan(aHeader,{ |x| AllTrim(x[2])== "AR_ITEM" })
    aCols[1,nPos] := StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.

Else
	              
    DbSelectArea( "SAR" )
	DbSetOrder( 2 )
    DbSeek( xFilial()+M->AR_CODCOBR )

        Do While SAR->(!Eof()) .and. xFilial() == SAR->AR_FILIAL .and.;
             SAR->AR_CODCOBR == M->AR_CODCOBR
			 	
			aAdd(aCols,Array(nUsado+1))
		
			For nI := 1 to nUsado
	   	
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Else										// Campo Virtual
					cCpo := AllTrim(Upper(aHeader[nI,2]))
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
	  			Endif
	 			
			Next nI
	  			
			aCols[Len(aCols),nUsado+1] := .F.
	    	
			DbSkip()

		Enddo
		
Endif

RETURN                 



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F425Ahead� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � F425Ahead()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA425                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F425Ahead(cAlias)

aHeader := {}
nUsado 	:= 0

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias)

Do While !Eof() .and. (X3_ARQUIVO == cAlias)

	///////////////////////////////////////////////////
	// Ignora campos que nao devem aparecer na getdados
    If  Upper( AllTrim(X3_CAMPO) ) == "AR_CODCOBR" 	.or. ;
        Upper( AllTrim(X3_CAMPO) ) == "AR_COBNOME"
				
		DbSkip()
		Loop
	Endif
	// Ignora campos que nao devem aparecer na getdados
	///////////////////////////////////////////////////

	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
		nUsado++
 		aAdd(aHeader,{ Trim(X3Titulo()), X3_CAMPO  , X3_PICTURE ,;
						X3_TAMANHO     , X3_DECIMAL, X3_VALID   ,;
						X3_USADO       , X3_TIPO   , X3_ARQUIVO ,; 
						X3_CONTEXT                               ;
					 }                                           ;
			)
	Endif

	DbSkip()

Enddo 

RETURN



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F425Dele � Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para exclusao dos Clientes por Cobrador             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � F425Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA425                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F425Dele( )

DbSelectArea("SAR")
DbSetOrder(1)      

DbSeek( xFilial() + M->AR_CODCOBR )        


If MsgYesNo( OemToAnsi( STR0012 ) ) // Confirma a exclusao da lista inteira deste cobrador.

	Begin Transaction
	
	Do While SAR->(!Eof())  .and. xFilial() == SAR->AR_FILIAL ;
							.and. SAR->AR_CODCOBR == M->AR_CODCOBR
			 
		RecLock("SAR",.F.)
		DbDelete()
		MsUnLock()
			
		DbSkip()
			
	Enddo
	
	End Transaction

EndIf

RETURN



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FIN425Grav� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao - Incl./Alter						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FIN425Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA425                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FIN425Grav( nOpc )

///////
// Var:
Local nIt       := NIL
Local nNumItem 	:= 1  // Contador para os Itens
Local nPosDel	:= Len(aHeader) + 1
Local lGraOk	:= .T.
Local nCpo		:= 0
// Var:
///////


DbSelectArea("SAR")
DbSetOrder(2) // Chave -> Filial + CodCobrador + Item
	
Begin Transaction
	For nIt := 1 To Len(aCols)
		
		If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado
	
			/////////////////////////////////////////////
			// Caso ja exista registro com a chave abaixo
			// 		trava registro
			// Caso contrario cria registro novo travado
			If ALTERA
				If DbSeek( xFilial("SAR")+ M->AR_CODCOBR + StrZero(nIt,Len(SAR->AR_ITEM)) )
					RecLock("SAR",.F.)
				Else
					RecLock("SAR",.T.)
				Endif
			Else	                   
				RecLock("SAR",.T.)
			Endif
				      
				
			////////////////////////////	
			// Grava dados da MsGetDados
			For nCpo := 1 To Len(aHeader)
				If aHeader[nCpo, 10] <> "V"
	  				SAR->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
				EndIf
			Next nCpo
	            
	            
	                                                                              
			/////////////////////////////
			// Controle de itens do acols
			// Mantem AR_ITEM com valor sequencial
			SAR->AR_ITEM    := StrZero(nNumItem,Len(SAR->AR_ITEM))
				            
	
			//////////////////////////
			// Gravs dados da Enchoice
			SAR->AR_FILIAL  := xFilial("SAR")
			SAR->AR_CODCOBR := M->AR_CODCOBR

	        
			nNumItem++
		
			MsUnLock()					
		Else
			If DbSeek( xFilial("SAR")+ M->AR_CODCOBR + StrZero(nIt,Len(SAR->AR_ITEM)) )
				RecLock("SAR",.F.)
				SAR->(DbDelete())
				MsUnLock()
			Endif
		Endif
		
	Next nIt
End Transaction

DbSelectArea("SAR")
DbSetOrder(3) // AR_FILIAL+AR_CODCOBR+AR_SEQUENC

RETURN( lGraOk )



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FI425LinOk � Autor � Cristiano D. Alarcon � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FI425LinOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ---                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � FINA425                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/                     
Function FI425LinOk( )

///////
// Var:
Local nQtdeCps 	:= Len( aCpsObg )
Local nPosDel  	:= Len( aHeader ) + 1
Local nPosCpo  	:= 0 // Posicao do campo obrigatorio
Local nPosCli  	:= 0 // Posicao do campo Cod. Cliente
Local nPosLoj   := 0 // Posicao do campo Loja Cliente
Local nIt	   	:= 0
Local lRetorno 	:= .T.      
Local cRegAtual := ""
Local cAlias	:= Alias()
Local cTitle 	:= OemToAnsi( STR0007 ) // Atencao!
Local cMsg		:= OemToAnsi( STR0010 ) // Este Cliente ja e atendido por este cobrador.
// Var:
///////                   

nPosCli   := aScan( aHeader, {|x| AllTrim(x[2]) == "AR_CODCLI"} )
nPosLoj   := aScan( aHeader, {|x| AllTrim(x[2]) == "AR_LOJCLI"} )
cRegAtual := aCols[n,nPosCli] + aCols[n,nPosLoj]

///////////////////////////////////////////
// Campos Obrigatorios:
// verifica campo a campo se foi preenchido
For nIt := 1 to nQtdeCps

	nPosCpo  := aScan( aHeader, {|x| AllTrim(x[2]) == aCpsObg[nIt]} )
	
	If Empty ( aCols[n,nPosCpo] ) .and. ( !aCols[n, nPosDel] )
		lRetorno := .F.
		exit
	EndIf   

Next nIt


/////////////////////////////////////////
// Verifica se Cliente ja existe em aCols
If ( lRetorno )  .and. ( !aCols[n,nPosDel] )

	If ( !empty(cRegAtual) ) .and. ( n >= Len(aCols) )
			
		For nIt := 1 to Len( aCols )
			If ( aCols[nIt,nPosCli]+aCols[nIt,nPosLoj] == cRegAtual ) .and. ( nIt != n ) .and. ( !aCols[nIt, nPosDel] )
				lRetorno := .F.          
	 			MsgAlert( cMsg, cTitle )
				Exit
			EndIf
		Next nIt
	
	Endif

Endif


////////////////////////////////////
// Verifica se Cliente existe em SA1
If ( lRetorno ) .and. ( !aCols[n,nPosDel] )
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	If ( !dbSeek(xFilial()+cRegAtual) )
	   lRetorno := .F. 
	   MsgAlert( OemToAnsi(STR0013), cTitle )  // Codigo e sucursal nao existe em cadastro de Clientes
	Endif
	
	dbSelectArea(cAlias)
Endif
 

RETURN( lRetorno )



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FI425TudOk � Autor � Cristiano D. Alarcon � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FI425TudOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ---                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � FINA425                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function FI425TudOk( )

///////
// Var:
Local nQtdeCps 	:= Len( aCpsObg )
Local nPosCpo  	:= 0 // Posicao do campo obrigatorio
Local cCodELoj  := "" // Codigo Cliente + Filial
Local cTitle 	:= OemToAnsi( STR0007 ) // Atencao!
Local cMsg		:= OemToAnsi( STR0008 ) // Campos obrigatorios nao preenchidos.
Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                  
Local nTotCols  := Len(aCols)
Local nPosSeq   := aScan(aHeader, { |x| AllTrim(x[2]) == "AR_SEQUENC"} )
Local nPosCli   := aScan(aHeader, { |x| AllTrim(x[2]) == "AR_CODCLI" } )                          
Local nPosLoj   := aScan(aHeader, { |x| AllTrim(x[2]) == "AR_LOJCLI" } )
// Var:
///////

///////////////////////////////
// Verifica campos obrigatorios
// do aCols
For nIt := 1 To nTotCols
	If aCols[nIt, nPosDel] 	.or. Empty(aCols[nIt,nPosSeq]) ;
							.or. Empty(aCols[nIt,nPosCli]) ;
							.or. Empty(aCols[nIt,nPosLoj])
		nTot ++
	Endif
Next nIt

///////////////////////////////
// Verifica campos obrigatorios
// que nao estao no MsGetDados
If Empty(M->AR_CODCOBR) .or. nTot == nTotCols
	lRetorno := .F.             
	MsgAlert( cMsg, cTitle )
EndIf     


///////////////////////////////////////////
// Campos Obrigatorios: MsGetDados
// verifica campo a campo se foi preenchido
For nIt := 1 to nQtdeCps

	nPosCpo  := aScan( aHeader, {|x| AllTrim(x[2]) == aCpsObg[nIt]} )
	
	If Empty ( aCols[n,nPosCpo] ) .and. ( !aCols[n, nPosDel] )
		lRetorno := .F.                                        
		MsgAlert( cMsg, cTitle)
		exit
	EndIf   

Next nIt


/////////////////////////////////////////////////////
// Verifica se ultimo elemento de aCols esta repetido
// CodCli+LojCli
cCodELoj := aCols[nTotCols,nPosCli] + aCols[nTotCols,nPosLoj]

if ( lRetorno ) .and. ( !aCols[nTotCols,nPosDel] )                                
	For nIt := 1 to nTotCols
		If ( aCols[nIt,nPosCli]+aCols[nIt,nPosLoj] == cCodELoj ) .and. ( nIt != nTotCols )
			
			lRetorno := .F.          
			
			///////////
			// Mensagem
			cTitle 	:= OemToAnsi( STR0007 ) // Atencao!
			cMsg	:= OemToAnsi( STR0011 ) // Existe cliente na lista em duplicidade.
 			MsgAlert( cMsg, cTitle )
			
			Exit
			
		EndIf
	Next nIt
endif


RETURN( lRetorno )



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FIN425CoNo� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funciona como um gatilho para exibicao do mbrowse no campo ���
���          � AR_COBNOME											  	  ���
���          � OBS: foi criada esta func.pelo fato que o campo X3_INIBRW  ���
���          � nao possuir o tamanho necessario para o comando completo	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FIN425CoNo()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ---                               						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SX3->X3_INIBRW                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FIN425CoNo( )

Local cRet := Posicione("SAQ",1,xFilial("SAR")+SAR->AR_CODCOBR,"SAQ->AQ_NOME")

RETURN( cRet )  
   


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FIN425ClNo� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funciona como um gatilho para exibicao do mbrowse no campo ���
���          � AR_CLINOME											  	  ���
���          � OBS: foi criada esta func.pelo fato que o campo X3_INIBRW  ���
���          � nao possuir o tamanho necessario para o comando completo	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FIN425ClNo()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ---                               						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SX3->X3_INIBRW                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FIN425ClNo( )

Local cRet := Posicione("SA1",1,xFilial("SA1")+SAR->AR_CODCLI,"SA1->A1_NOME")

RETURN( cRet )



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FIN425VlCp� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Substitui gatilho para o preenchimento correto na inclusao ���
���          � com o uso de campos fixos.                       	  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FIN425VlCp()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ---                               						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA425Inc()                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FIN425VlCp( )

M->AR_COBNOME := Posicione("SAQ",1,xFilial()+M->AR_CODCOBR,"AQ_NOME")

RETURN( .T. )



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FIN425Cobr� Autor � Cristiano D. Alarcon  � Data � 28.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se ja nao existe listagem de clientes para o      ���
���          � cobrador escolhido na rotina de inclusao.           	  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FIN425Cobr()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ---                               						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA425Inc()                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FIN425Cobr( )

///////
// Var:
Local 	cMsg		:= ""
Local	cTitle		:= ""
Local   lRetorno	:= .T.
Local	cAlias		:= Alias()
Local   cCobrador   := M->AR_CODCOBR
// Var:
///////

dbSelectArea( "SAR" )
dbSetOrder( 1 )

/////////////////////////////////////////
// verifica existencia de Cobrador em SAR
if dbSeek( xFilial("SAR")+cCobrador )

	lRetorno := .F.
	
	///////////
	// Mensagem
	cTitle 	:= OemToAnsi( STR0007 ) // Atencao!
	cMsg	:= OemToAnsi( STR0009 ) // Cobrador ja possui uma listagem de cliente, localize-o para edita-lo.
 			MsgAlert( cMsg, cTitle )

endif


////////////////////////
// Volta a area original
dbSelectArea( cAlias )

RETURN( lRetorno )

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �27/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := { ;	
					{OemToAnsi(STR0001), "AxPesqui"   , 0, 1},; //"Pesquisa"
					{OemToAnsi(STR0002), "FINA425Frm" , 0, 2},; //"Visualiza"
					{OemToAnsi(STR0003), "FINA425Frm" , 0, 3},; //"Inclui"
					{OemToAnsi(STR0004), "FINA425Frm" , 0, 4},; //"Altera"
					{OemToAnsi(STR0005), "FINA425Frm" , 0, 5} ; //"Exclui"
				   }
Return(aRotina)