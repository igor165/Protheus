#INCLUDE "CNTA170.ch"

//Transacoes
#DEFINE DEF_TRAINC "015"//Inclusao de Documentos
#DEFINE DEF_TRAEDT "016"//Edicao de Documentos
#DEFINE DEF_TRAEXC "017"//Exclusao de Documentos
#DEFINE DEF_TRAVIS "034"//Visualizacao de Documentos
#DEFINE DEF_TRABCO "038"//Banco de Conhecimento
//Situacoes de contrato
#DEFINE DEF_SCANC "01" //Cancelado
#DEFINE DEF_SELAB "02" //Em Elaboracao
#DEFINE DEF_SEMIT "03" //Emitido
#DEFINE DEF_SAPRO "04" //Em Aprovacao
#DEFINE DEF_SVIGE "05" //Vigente
#DEFINE DEF_SPARA "06" //Paralisado
#DEFINE DEF_SSPAR "07" //Sol Fina.
#DEFINE DEF_SFINA "08" //Finalizado
#DEFINE DEF_SREVS "09" //Revisao   
#DEFINE DEF_SREVD "10" //Revisado

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CNTA170  � Autor � Marcelo Custodio      � Data �09.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Rotina de Cadastro de Documentos                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA170()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CNTA170()
Private cCadastro	:= STR0001 //Cadastro de Documentos
Private aRotina 	:= MenuDef()

mBrowse(6,1,22,75,"CNK")

Return

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN170BcoDoc� Autor � Marcelo Custodio      � Data �09.05.2006���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � Rotina de vinculacao ao banco de conhecimento               ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN170Manut(cExp01,nExp02,nExp03)                            ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Alias                                              ���
���          � cExp02 - Registro                                           ���
���          � cExp03 - Opcao                                              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function CN170BcoDoc(cAlias,nReg,nOpc)

//�������������������������������������������Ŀ
//� Valida acesso ao banco de conhecimento    �
//���������������������������������������������
If CN240VldUsr(CNK->CNK_CONTRA,DEF_TRABCO,.T.)
	MsDocument(cAlias,nReg,nOpc)
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN170Manut� Autor � Marcelo Custodio      � Data �09.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Rotina de Manutencao do Cadastro de Documentos             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN170Manut(cExp01,nExp02,nExp03,xExp04,cExp05,cExp06,cExp07)��
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Alias                                             ���
���          � cExp02 - Registro                                          ���
���          � cExp03 - Opcao                                             ���
���          � Parametros cExp04,cExp05,cExp06 usados apenas para inclusao���
���          � atraves da tela de verificacao de documentos (CNTA100)     ���
���          � xExp04 - Parametro padrao                                  ���
���          � cExp05 - Codigo do contrato                                ���
���          � cExp06 - Codigo do tipo de documento                       ���
���          � cExp07 - Codigo do documento - referencia                  ���
���          � lExp08 - Indica se o usuario podera VISUALIZAR a planilha  ���
���          � 			do contrato mesmo sem ter acesso ao mesmo. Esse	  ���
���          � 			parametro e enviado como .T. exclusivamente pela  ���
���          � 			rotina de liberacao (MATA097) quando o documento e���
���          � 			do tipo CT (Contrato) e o Aprovador nao possui    ���
���          � 			acesso ao contrato.					   			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN170Manut(cAlias,nReg,nOpc,xFiller,cContra,cTpDoc,cCod,lVisAprCt)
Local aSize      := MsAdvSize()
Local aArea      := GetArea()
Local aButtons   := {}
Local aCpos      := {}
Local aEditCpos  := {}
Local nOpca
Local lRet       := .T.  
Local lCN170VLG  := .F.
Local cTra       := ""
Local cCampo	:= ""
Local oDlg

If Type("cCadastro") # "C"
	cCadastro := STR0001 //Cadastro de Documentos
EndIf

If Type("aRotina") == "A"
	If(aRotina[nOpc,4]==3,DEF_TRAINC,If(aRotina[nOpc,4]==4,DEF_TRAEDT,DEF_TRAEXC))
EndIf

Do Case
	Case nOpc == 3
		cTra := DEF_TRAINC
	Case nOpc == 4
		cTra := DEF_TRAEDT
	Case nOpc == 5
		cTra := DEF_TRAEXC
	Otherwise
		cTra := DEF_TRAVIS 
EndCase 

lVisAprCt := (lVisAprCt != Nil .AND. lVisAprCt != .F.)	//DEFAULT

PRIVATE aTela    := {}
PRIVATE aGets    := {}

If cTra # DEF_TRAINC //Visualizacao OU Edicao OU Exclusao
	cContra := IIf(cContra == Nil, CNK->CNK_CONTRA , cContra)
	lRet := CN240VldUsr(cContra,cTra,.T.,lVisAprCt)
EndIf


If lRet
	dbSelectArea("SX3")
	dbSeek("CNK")
	
	//����������������������������������������������������Ŀ
	//� Seleciona os campos do documento                   �
	//������������������������������������������������������
	While !Eof() .And. SX3->X3_ARQUIVO == "CNK"
		cCampo := SX3->X3_CAMPO
		
		If X3Uso(GetSx3Cache(cCampo,'X3_USADO')) .And. cNivel >= GetSx3Cache(cCampo,'X3_NIVEL')
			Aadd(aCpos, cCampo )
		EndIF
		
		If	( GetSx3Cache(cCampo,'X3_CONTEXT') == "V"  .Or. nOpc == 3 )
			M->&(cCampo) := CriaVar(cCampo)
		Else
			M->&(cCampo) := CNK->(FieldGet(FieldPos(cCampo)))
		EndIf
		
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	
	aEditCpos := aClone(aCpos)
	
	If( nOpc == 3 .And. FwIsInCallStack('CNTIncDoc'))
		If(!Empty(cContra))
			M->CNK_CONTRA:= cContra
			
			If(aScan(aEditCpos,"CNK_CONTRA") > 0)				
				aDel(aEditCpos,aScan(aEditCpos,"CNK_CONTRA"))
				aSize(aEditCpos,Len(aEditCpos) - 1)
			EndIf
		EndIf
		If(!Empty(cTpDoc))
			M->CNK_TPDOC := cTpDoc
		EndIf
	EndIf
	
	// Calcula dimens�es                                            
	oSize := FwDefSize():New()
	oSize:AddObject( "CABECALHO",  100, 100, .T., .T. )      
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	oSize:Process() 	   // Dispara os calculos
	
	//����������������������������������������������������Ŀ
	//� Inclui botao do banco de conhecimento durante a    �
	//� visualizacao                                       �
	//������������������������������������������������������
	If cTra == DEF_TRAVIS
		AAdd(aButtons,{"clips", {|| CN170BcoDoc("CNK",CNK->(Recno()),nOpc) }, STR0008, STR0009 } )		
	EndIf
	
	//����������������������������������������������������Ŀ
	//� Configura exibicao dos campos                      �
	//������������������������������������������������������
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
	
	EnChoice( cAlias, nReg, nOpc,,,,aCpos ,;
					{oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI"),;
					 oSize:GetDimension("CABECALHO","LINEND"),oSize:GetDimension("CABECALHO","COLEND")},aEditCpos,,,,,,.T.)
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela) .And. !TemDestinat() .And. CN240VldUsr(M->CNK_CONTRA,cTra,.T.),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||(nOpcA:=2,oDlg:End())},,aButtons))
	
    If nOpcA == 1 .And. nOpc != 2
        //������������������������������������������������������������Ŀ
        //� Ponto de entrada permite ou n�o a grava��o do documento    �
        //��������������������������������������������������������������  
 		If (ExistBlock("CN170VLG"))
			 lCN170VLG := ExecBlock("CN170VLG",.F.,.F.,{nOpc})
			 If ValType(lCN170VLG) == "L"
				 lRet  := lCN170VLG
			 EndIf
		 EndIf    
		 //����������������������������������������������������Ŀ
		 //� Grava documento                                    �
		 //������������������������������������������������������  
		 If lRet
			 lRet := CN170Grv(nOpc)
			 If lRet 
		         IF cCod != Nil
	    		     cCod := M->CNK_CODIGO
		         EndIf
	    	     If (__lSX8)
	                ConfirmSX8()
	             EndIf
	             EvalTrigger()
	             msUnlockAll()     
	         EndIf
   		EndIf
	Else
       lRet := .F.
   EndIf

	If !lRet 
		If (__lSX8)
	       RollBackSX8()
	    EndIf
	EndIf

EndIf

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN170Grv  � Autor � Marcelo Custodio      � Data �09.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Executa gravacao do tipo de documento                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN170Grv(nExp01)                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN170Grv(nOpc)
Local nCntFor  := 0
Local lRet := .F.

Do Case
	Case nOpc == 3  //Incluir
		//����������������������������������������������������Ŀ
		//� Inclui documento                                   �
		//������������������������������������������������������
		dbSelectArea("CNK")
		Reclock("CNK",.T.)
		For nCntFor := 1 To FCount()
			If (FieldName(nCntFor)!="CNK_FILIAL")
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			EndIf
		Next nCntFor
		CNK->CNK_FILIAL := xFilial("CNK")
		MsUnlock()
		lRet := .T.
	Case nOpc == 4  //Atualizar
		dbSelectArea("CNK")
		Reclock("CNK",.F.)
		For nCntFor := 1 To FCount()
			If (FieldName(nCntFor)!="CNK_FILIAL")
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			EndIf
		Next nCntFor
		CNK->CNK_FILIAL := xFilial("CNK")
		MsUnlock()
		lRet := .T.
	Case nOpc == 5  //Exclusao
		//��������������������������������������������������������������Ŀ
		//� Exclui a amarracao com os conhecimentos                      �
		//����������������������������������������������������������������
		MsDocument( "CNK", CNK->( RecNo() ), 2, , 3 )
		
		Reclock("CNK",.F.)
		dbDelete()
		MsUnlock()
		lRet := .T.
EndCase

If ExistBlock("CN170GRD")
	ExecBlock("CN170GRD",.F.,.F.,{nOpc})
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN170Conh � Autor � Marcelo Custodio      � Data �09.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Executa base de conhecimento                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN170Conh()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN170Conh()
Local aRotBack := If(Type("aRotina") == "A",aClone( aRotina ),{})
Local nBack    := 0
Local lRet 	   := .T. 	

If Type( "N" ) == "N"
	nBack := N
EndIf

//����������������������������������������������������Ŀ
//� Simula aRotina                                     �
//������������������������������������������������������
Private aRotina := {}

Aadd(aRotina,{STR0007,"MsDocument", 0 , 4}) //"Conhecimento"

//����������������������������������������������������Ŀ
//� Executa banco de conhecimento                      �
//������������������������������������������������������
lRet := MsDocument( "CNK", CNK->( Recno() ), 1 )

aRotina := AClone( aRotBack )

If !Empty( nBack )
	N := nBack
EndIf

Return(lRet) 


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �19/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
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
PRIVATE aRotina	:= 	{ 	{ OemToAnsi(STR0002), "AxPesqui"	, 0, 1, 0, .F.},; 	 //"Pesquisar"
								{ OemToAnsi(STR0003), "CN170Manut"	, 0, 2, 0, nil},;		//"Visualizar"
								{ OemToAnsi(STR0004), "CN170Manut"	, 0, 3, 0, nil},;		//"Incluir"
								{ OemToAnsi(STR0005), "CN170Manut"	, 0, 4, 0, nil},;		//"Alterar"
								{ OemToAnsi(STR0006), "CN170Manut"	, 0, 5, 0, nil},;		//"Excluir"
								{ OemToAnsi(STR0007), "CN170BcoDoc" , 0, 4, 0, nil}}   //Conhecimento

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("CTA170MNU")
	ExecBlock("CTA170MNU",.F.,.F.)
EndIf
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN170VLDDT� Autor � Marcelo Custodio      � Data �18/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida as datas do documento de contrato                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN170VLDDT()                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CN170VLDDT(nCampo)
	Local lRet := .T.
	Local dEmissao	:= Date()
	Local dValidade := Date()
	
	If (FwIsInCallStack("CNTA170") .Or. FwIsInCallStack("CN170Manut"))
		dEmissao := M->CNK_DTEMIS
		dValidade:= M->CNK_DTVALI
	Else	
		dEmissao := FwFldGet("CNK_DTEMIS")
		dValidade:= FwFldGet("CNK_DTVALI")
	EndIf

	If !Empty(dEmissao) .And. !Empty(dValidade) .And. dEmissao > dValidade
		lRet := .F.		
		Help(" ",1,"CN170DTVALI",,STR0011, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0014}) //A data de emiss�o deve ser inferior a data de vencimento. Informe uma data de validade superior a emiss�o.		
	EndIf
Return lRet

Static Function TemDestinat()
    Local lRet := .F.
    Local aAreas := {}

    If AliasInDic('CXR')
        aAreas := {CXR->(GetArea()), GetArea()}
        
        CXR->(dbSetOrder(1)) //-- CXR_FILIAL+CXR_CODIGO+CXR_ITEM
        
        If CXR->(MsSeek(xFilial('CXR') + CNK->CNK_CODIGO))
            Help(" ",1,"CN170TEMCXR",,STR0039, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0040}) //Este documento foi incluso pela nova rotina de Documentos (CNTA171).
            lRet := .T.
        EndIf
        
        aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
    EndIf
    
Return lRet
