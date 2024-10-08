#INCLUDE "QIEA070.CH"
#INCLUDE "PROTHEUS.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QIEA070   � Autor � Paulo Emidio de Barros� Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao de Follow-Up									  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAQIE													  ���
�������������������������������������������������������������������������Ĵ��
���STR 	     � Ultimo utilizado -> STR0006                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      � 										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui",  0,1,,.F.},;  
				 {OemToAnsi(STR0002),"Q070Follow",0,2},; 
				 {OemToAnsi(STR0003),"Q070Follow",0,3},;  
				 {OemToAnsi(STR0004),"Q070Follow",0,4},;  
				 {OemToAnsi(STR0005),"Q070Follow",0,5,3}} 

Return aRotina

Function QIEA070()  
//��������������������������������������������������������������Ŀ
//� Definicao do Browse  										 �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006) //"Equipes de Follow-up"
Private Inclui    := .F.
Private Altera    := .F.

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� 1 - Nome a aparecer no cabecalho                             �
//� 2 - Nome da Rotina associada                                 �
//� 3 - Usado pela rotina                                        �
//� 4 - Tipo de Transa��o a ser efetuada                         �
//�    1) Pesquisa e Posiciona em um Banco de Dados              �
//�    2) Simplesmente Mostra os Campos                          �
//�    3) Inclui registros no Bancos de Dados                    �
//�    4) Altera o registro corrente                             �
//�    5) Remove o registro corrente do Banco de Dados           �
//����������������������������������������������������������������
Private aRotina := MenuDef()

dbSelectArea("QE4") 
mBrowse(06,01,22,75,"QE4") 

Return(NIL)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Q070Follow� Autor �Paulo Emidio de Barros � Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao da Equipe de Follow-Up e seus respectivos respon���
���			 � saveis 												      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Q070Follow(EXPC1,EXPN1,EXPN2)							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Alias do arquivo									  ���
���			 � EXPN1 = Numero do registro 								  ���
���			 � EXPN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NIL														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA070													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Q070Follow(cAlias,nReg,nOpc)

Local oDlg
Local nOpcA    := 0
Local aAreaAnt := GetArea()
Local lDeleta  := .F.
Local oEnchoice
Local oFont
Local oGroup
Local oSize 

Private aTela      := {}
Private aGets      := {}                                           
Private aHeader    := {}
Private aCols      := {}
Private nUsado     := 0                     
Private oGetResp   
Private nPosRes    := 0
Private nPosNomUsu := 0
Private nPosFilRes := 0

//��������������������������������������������������������������Ŀ
//� Verifica se a Equipe esta associada a algum Grupo de Produtos�
//����������������������������������������������������������������
If nOpc == 5 //Exclusao
	QE3->(dbSetOrder(2))
	If QE3->(dbSeek(xFilial("QE3")+QE4->QE4_EQUIPE))
		Help(" ",1,"QE70EXISGR")  
		Return(NIL)                                                     
	EndIf
	
EndIf

//��������������������������������������������������������������Ŀ
//� Cria as variaveis para edicao na enchoice					 �
//����������������������������������������������������������������
RegToMemory("QE4",If(nOpc==3,.T.,.F.),.T.)            

                            
/* Documenta��o dos parametros do Metodo FillGetDados
FillGetDados  (nOpc,; 			// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               Alias,       	// area a ser utilizada;
               nOrdem,      	// ordem correspondente a chave de �ndice para preencher o  acols;
               cSeek,       	// chave utilizada no posicionamento da �rea para preencher o acols; 
               bSeekWhile,  	// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               uSeekFor,    	// pode ser utilizados de duas maneiras:
							 	   1 - bloco-de-codigo, condicao a ser utilizado para executar o Loop no While;
							 	   2 - array bi-dimensional contendo N condicoes, em que o 1 elemento o bloco condicional, o 2 bloco a ser executado se verdadeiro e o 3 e bloco a ser executado se falso:
							 	   Exemplo:
							 	   {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
               aNoFields,   	// array contendo os campos que n�o estar�o no aHeader;
               aYesFields,  	// array contendo somente os campos que estar�o no aHeader;
               lOnlyYes,    	// se verdadeiro, exibe apenas os campos de usu�rio;
               cQuery,      	// query a ser executada para preencher o acols;
               bMontCols,    	// bloco contendo funcao especifica para preencher o aCols; 
               lEmpty,       	// 
               aHeaderAux,   	// 
               aColsAux,     	// 
               bAfterCols,   	// 
               bBeforeCols,  	// 
               bAfterHeader,    // 
               cAliasQry)       // 
*/

cWhile  := Alltrim(RetSIX("QE5","1",.T.,{"QE5_RESPON"}))
cSeek 	:= RetSIX("QE4","1",.T.)

FillGetDados(	nOpc,; 							// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               	"QE5",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de �ndice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da �rea para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que n�o estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usu�rio;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry
               	
//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������
nPosRes    := Ascan(aHeader,{|x|x[2]=="QE5_RESPON"})
nPosNomUsu := Ascan(aHeader,{|x|x[2]=="QE5_NOMUSU"})
nPosFilRes := Ascan(aHeader,{|x|x[2]=="QE5_FILRES"})

QE070AfCols( aHeader, aCols )

nUsado := Len(aHeader)

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"    ,  100, 30, .T., .T. )
oSize:AddObject( "GETDADOS"   ,  100, 70, .T., .T. ) 

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro);
	FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
	
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,;
						{ oSize:GetDimension("ENCHOICE","LININI"),;
						  oSize:GetDimension("ENCHOICE","COLINI"),;
						  oSize:GetDimension("ENCHOICE","LINEND"),;
						  oSize:GetDimension("ENCHOICE","COLEND")};
						  ,,,,,,oDlg,,.T.,,,,,,,.T.) 

If nOpc <> 2 .And. nOpc <> 5
	lDeleta:= .T.
EndIf

oGroup := TGroup():Create(oDlg,oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND");
						,"Respons�veis",,,.T.)
oGroup:oFont:= oFont

oGetResp := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI")+10,oSize:GetDimension("GETDADOS","COLINI")+3,;
						 oSize:GetDimension("GETDADOS","LINEND")-3,oSize:GetDimension("GETDADOS","COLEND")-3,;
						 nOpc,"Q070LinOk","Q070TudOk",,lDeleta,,,,,,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nOpcA :=1,If(oGetResp:TudoOk(),;
	If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA:=0)},{||oDlg:End()}))
	
//Realiza a gravacao dos dados
If nOpc <> 2 .And. nOpcA == 1
	Q070GrvAll(nOpc)
EndIf                       
                             
RestArea(aAreaAnt)

Return(NIL)                    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Q070GrvAll� Autor �Paulo Emidio de Barros � Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Realiza a gravacao dos dados referentes as Equipes de      ���
���			 � Follow-Up												  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Q070GrvAll(nOpc)											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPN1 = Opcao do aRotina									  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NIL														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA070     											      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q070GrvAll(nOpc)   
Local bCampo  := {|x|Field(x)}
Local nCpo	  := 0
Local nIteCol := 0
Local nCpoCol := 0
Local lFound  := .F.

//��������������������������������������������������������������Ŀ
//� Atualizacao das Equipes de Folow-Up							 � 
//����������������������������������������������������������������
If nOpc == 3
	RecLock("QE4",.T.)
Else
	RecLock("QE4",.F.)
EndIf		

If nOpc == 5
	dbDelete()
Else
	For nCpo := 1 To fCount()
		If "_FILIAL"$Field(nCpo)
			FieldPut(nCpo,xFilial("QE4"))
		Else
			FieldPut(nCpo,M->&(EVAL(bCampo,nCpo)))
		Endif
	Next nCpo
EndIf
MsUnLock()

//��������������������������������������������������������������Ŀ
//� Atualizacao dos Responsaveis por Equipe	de Follow-Up		 � 
//����������������������������������������������������������������
For nIteCol := 1 to Len(aCols)

	If nOpc <> 3 .Or. ( nOpc == 3 .And. !aCols[nIteCol,nUsado+1] ) 
		QE5->(dbSetorder(4))
		lFound := (QE5->(dbSeek(xFilial("QE5")+M->QE4_EQUIPE+aCols[nIteCol,nPosFilRes]+aCols[nIteCol,nPosRes])))
	
		If (nOpc == 5)
			//��������������������������������������������������������������Ŀ
			//� Remove a equipe excluida do Grupo de Produtos 				 � 
			//����������������������������������������������������������������
			Q070DelGrp(M->QE4_EQUIPE)
			
			RecLock("QE5",.F.)
			dbDelete()
			MsUnLock()
		Else
			If !Empty(aCols[nIteCol,nPosFilRes]) .And. !Empty(aCols[nIteCol,nPosRes])
				If !aCols[nIteCol,nUsado+1]	
					If lFound
						RecLock("QE5",.F.)
					Else
						RecLock("QE5",.T.)
					Endif
					For nCpoCol := 1 to Len(aHeader)
						If aHeader[nCpoCol,10] # "V"                  
							FieldPut(FieldPos(AllTrim(aHeader[nCpoCol,2])),aCols[nIteCol,nCpoCol])
						EndIf
					Next nCpoCol
					QE5->QE5_EQUIPE := M->QE4_EQUIPE
					QE5->QE5_FILIAL := xFilial("QE5")
					MsUnLock()
				Else
					If lFound
						RecLock("QE5",.F.)
						dbDelete()
						MsUnLock()
					Endif
				EndIf	
		    EndIf
		EndIf
	Endif
	
Next nIteCol

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q070LinOk � Autor � Paulo Emidio de Barros� Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Linha atual dos Responsaveis				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPO1 = Objeto a ser verificado	                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q070LinOk(o)
Local lRetorno  := .T.
Local nAchou    := 0
Local cProcura  := (aCols[N,nPosFilRes]+aCols[N,nPosRes])

If !(aCols[N,Len(aCols[N])])

	//��������������������������������������������������������������Ŀ
	//� Verifica se campo Responsavel esta' preenchido               �
	//����������������������������������������������������������������
	If !aCols[N,nUsado+1] 
		If Empty(aCols[N,nPosRes])
			Help(" ",1,"QA_CPOOBR")
			lRetorno := .F.	
		EndIf
	EndIf
	
	If lRetorno
		//��������������������������������������������������������������Ŀ
		//� Verifica se o Responsavel ja' existe            			 �
		//����������������������������������������������������������������
		nAchou := Ascan(aCols,{|x|(x[nPosFilRes]+x[nPosRes])==cProcura .And. !(x[Len(aCols[N])])})
		If nAchou > 0 .And. nAchou # N
			Help(" ",1,"A070EXIREE")
			lRetorno := .F.
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se o responsavel esta com status de demitido		 �
	//����������������������������������������������������������������
	If lRetorno
		If ! Empty(aCols[N,nPosRes])
			lRetorno := QA_CHKMAT(aCols[N,nPosFilRes],aCols[N,nPosRes])
		EndIf	
	EndIf
EndIf				
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q070TudOk	� Autor � Paulo Emidio de Barros� Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � validacao dos Responsaiveis digitados       				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPO1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q070TudOk(o)
Local nCpoCol
Local lRetorno := .T.

For nCpoCol := 1 to Len(aCols)
	If ! Q070LinOk(o)
		lRetorno := .F.
		Exit
	EndIf
Next

Return(lRetorno)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q070Resp()� Autor � Paulo Emidio de Barros� Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Responsavel                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA070 - E' chamada no X3_VALID do cpo. QE5_RESPON	``    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Q070Resp()

Local lRetorno := .T.
Local nI       := 0

//��������������������������������������������������������������Ŀ
//� Verifica se mudou o Responsavel (Alterou o campo ja digitado)�
//����������������������������������������������������������������
If (!Empty(aCols[N,nPosFilRes]) .And. !Empty(aCols[N,nPosRes]) .And. !Empty(aCols[N,nPosFilRes]) .And.; 
	!Empty(M->QE5_RESPON)) .And. (aCols[N,nPosFilRes]+aCols[N,nPosRes] # aCols[N,nPosFilRes]+M->QE5_RESPON)                             
	If !Inclui                         
		QE5->(dbSetOrder(3))
		If QE5->(dbSeek(xFilial('QE5')+aCols[N,nPosFilRes]+aCols[N,nPosRes]))
			Help(" ",1,"A010ALTCHA") //Campo nao pode ser alterado	
			lRetorno := .F.
		EndIf	
	EndIf	    
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se o Responsavel esta cadastrado				     �
//����������������������������������������������������������������
If lRetorno
	aCols[N,nPosRes] := M->QE5_RESPON
	QAA->(dbSetOrder(1))
	If !QAA->(dbSeek(aCols[N,nPosFilRes]+aCols[N,nPosRes]))
		Help(" ",1,"Q070NAOUSU")  
		lRetorno := .F.
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se o Responsavel ja' existe p/ esta Equipe     	 �
//����������������������������������������������������������������
If lRetorno
	For nI := 1 to Len(aCols)         
		If (aCols[N,nPosFilRes]+M->QE5_RESPON == aCols[nI,nPosFilRes]+aCols[nI,nPosRes]) 
			If !aCols[nI,Len(aCols[nI])]
				If (nI # N)
					Help(" ",1,"A070EXIRES") //"Responsavel ja associado a esta Equipe"
					lRetorno := .F.
				EndIf
			EndIf
		EndIf	
	Next nI
EndIf

//��������������������������������������������������������������Ŀ
//� Preenche o nome do responsavel								 �
//����������������������������������������������������������������
If lRetorno
	aCols[N,nPosNomUsu] := Posicione("QAA",1,aCols[N,nPosFilRes]+aCols[n][nPosRes],"QAA_NOME")
EndIf
             
Return(lRetorno)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q070FilRes� Autor �Paulo Emidio de Barros � Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do campo Filial do Responsavel                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA070 - QE5_FILRES    									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Q070FilRes()

Local cVar     := &(Readvar()) // Conteudo da variavel do campo Filial
Local lRetorno := .T.

//����������������������������������������������������������������Ŀ
//� Verifica se mudou a Filial (Alterou o campo ja' digitado)      �
//������������������������������������������������������������������
If !Empty(aCols[n,nPosFilRes]) .And. !Empty(cVar) .And. aCols[n,nPosFilRes] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado	
	lRetorno:= .f.
EndIf

If lRetorno .And. !NaoVazio()
	lRetorno:= .F.
Else
	aCols[N,nPosFilRes] := M->QE5_FILRES
EndIf
	
Return lRetorno

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q070DelGrp� Autor �Paulo Emidio de Barros � Data �22/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Elimina as equipes associadas aos Grupos de Produtos       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA070 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q070DelGrp(cEquipe)
Local aAreaAnt := GetArea()

//��������������������������������������������������������������Ŀ
//� Remove a equipe do Responsavel que foi excluida do cadastro  � 
//� de Grupo de Produtos										 � 
//����������������������������������������������������������������
dbSelectArea('QE3')
dbSetOrder(2)
dbSeek(xFilial("QE3")+cEquipe)
While !Eof() .And. QE3_EQUIPE == cEquipe
	RecLock('QE3',.F.,.T.)
	QE3->QE3_EQUIPE := Space(TamSX3("QE3_EQUIPE")[1])
	MsUnLock()
	dbSkip()
EndDo	
           
RestArea(aAreaAnt)

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q070FilUsu� Autor �Paulo Emidio de Barros � Data �24/12/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtra as Filiais para selecao do Usuario responsavel      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA070 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q070FilUsu()
Local cFiltro := If(Empty(aCols[N,nPosFilRes]),xFilial("QAA"),aCols[N,nPosFilRes])
Return(cFiltro)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �QE070AfCols �Autor  �Cicero Cruz         � Data �  17/01/04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Rotina que carrega os campos Virtuais                        ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QIEA070                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function QE070AfCols( aHeader, aCols )
Local nLinha := 0

For nLinha := 1 to Len(aCols)
	aCols[nLinha,nPosNomUsu]  := Posicione("QAA",1,aCols[nLinha,nPosFilRes]+aCols[nLinha,nPosRes],"QAA_NOME")
Next

Return
