#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA510E.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �ManagementIndexDialog �Autor�Vendas Cliente   � Data �  18/06/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Funcoes de tela para o cadastro de Indicadores Gerenciais.         ��� 
���          �                                                                   ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class ManagementIndexDialog 


Method new() Constructor  
Method showDialog()
Method openBrowse()
Method save(nOpc, aColsSKK, aHeaderSKK, nSaveSx8)
EndClass     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas Cliente   � Data �  15/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class ManagementIndexDialog  

Return Self        

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �openBrowse            �Autor�Vendas Cliente   � Data �  11/01/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Inicia o Browse para lista de assuntos por Grupo de Atendimento.   ��� 
���          �                                                                   ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/ 
Method openBrowse() Class ManagementIndexDialog
Local aCores1    	:= {	{"(SUT->UT_ATIVO=='2')" , "BR_VERMELHO" },;	//  "Ativo"
   						    {"(SUT->UT_ATIVO=='1')" , "BR_VERDE"    }}	//  "Inativo"
   						    
Private cCadastro 	:= STR0001	//	"Indicadores"
Private aRotina	:= MenuDef()    


//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������    
MBrowse(,,,,"SUT",,,,,,aCores1,,,,)

Return Nil   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �showDialog   �Autor  �Vendas Cliente   � Data �  15/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe a tela de edicao dos assuntos x grupo de atendimento  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method showDialog(nReg, nOpc) Class ManagementIndexDialog  
Local cSeek		:= ""
Local cWhile         
Local cQuery	:= ""     
Local bAfterCols := Nil  
Local bCond    
Local aColsSKK := {}
Local aHeaderSKK := {}    
Local lRet := .T.
Local nSaveSx8 		:= GetSX8Len()                      			// Funcao de numeracao

DbSelectArea("SUT")         
DbSetOrder(1)
DbGoTo(nReg) 

//���������������������������������Ŀ
//�Atualiza as variaveis de memoria.�
//�����������������������������������
RegToMemory("SUT",IIf(nOpc == 3,.T.,.F.))  

//�����������������������Ŀ
//�Montagem aHeader, aCols�
//������������������������� 
#IFDEF TOP
	cQuery := "SELECT * " 
	cQuery += "FROM "+RetSqlName("SUU")+" SUU  WHERE "
	cQuery += "SUU.UU_FILIAL = '" + xFilial("SUU") + "' AND "
	cQuery += "SUU.UU_CODSUT = '" + SUT->UT_CODIGO + "' AND "
	cQuery += "SUU.D_E_L_E_T_<>'*' "
	cQuery += "ORDER BY SUU.UU_CODSUT "	
#ENDIF	    
cSeek	:= xFilial("SUU") + SUT->UT_CODIGO
cWhile	:= "SUU->UU_FILIAL + SUU->UU_CODSUT"
bCond	:= {||IIf(SUU->UU_FILIAL == xFilial("SUU") .AND. SUU->UU_CODSUT == SUT->UT_CODIGO,.T.,.F.)}    

If nOpc = 3 .OR. nOpc = 4
	bAfterCols := {||.T.}
EndIf

DbSelectArea("SUU")
DbCloseArea() 
				
aHeader := {}
aCols	:= {} 
FillGetDados(	nOpc /*nOpcX*/, "SUU"/*cAlias*/, 1/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, IIf(nOpc==3,.T.,.F.)/*lEmpty*/,; 
				@aHeaderSKK/*aHeaderAux*/, @aColsSKK/*aColsAux*/, bAfterCols/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, /*cAliasQry*/)

lRet := Modelo3(cCadastro,"SUT","SUU",/*aCpoEnChoice*/,"Tk510LinOk()"/*"A081LinOk()"*/,/*"A081TudOk()"*/,nOpc,nOpc)
If lRet .AND. nOpc <> 2
	lRet := Self:Save(nOpc, aCols, aHeader, nSaveSx8)
EndIf

Return lRet      

Function Tk510LinOk()
Local lRet    := .T.
Local nPosSU9 := Ascan(aHeader,{|x| Trim(x[2])=="UU_CODSU9"})
Local nPosSUQ := Ascan(aHeader,{|x| Trim(x[2])=="UU_CODSUQ"})

//������������������������������������������������������Ŀ
//� verifica se esta apagado                             �
//��������������������������������������������������������
If !aCols[n][Len(aCols[n])]
	If Empty(aCols[n][nPosSU9]) .AND. Empty(aCols[n][nPosSUQ])
		lRet := .F.
	EndIf
EndIf

If !lRet
	Help(" ",1,"CHECKCOLS")
Endif
Return lRet            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Save          �Autor �Vendas Clientes  � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava os dados do indicador.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Save(nOpc, aCols, aHeader, nSaveSx8) Class ManagementIndexDialog  
Local lRet := .T.
Local lNovo :=.T.                                     
Local nI   	:= 0
Local nX   	:= 0 	 		
Local bCampo:= ""
Local nPos	:= 0 
                      
	Do Case
		Case nOpc == 3  // INCLUSAO
			While (GetSx8Len() > nSaveSx8)
				ConfirmSX8()
			End	
			
		Case nOpc == 4 .OR. nOpc == 5 //ALTERACAO # EXCLUSAO
			lNovo := .F.
			
			//�������������������������������������������
			//�Apago as perguntas e respostas anteriores�
			//�������������������������������������������
			DbSelectArea("SUU")
			DbSetOrder(1)
			DbSeek(xFilial("SUU")+M->UT_CODIGO)
			While !Eof() .AND. (xFilial("SUU") == SUU->UU_FILIAL) .AND. (M->UT_CODIGO == SUU->UU_CODSUT)
				RecLock("SUU",.F.,.T.)
				DbDelete()
				MsUnLock()
				DbSkip()
			End
			
	EndCase                      
                                
	BEGIN TRANSACTION
	    
	    DbSelectArea("SUT")
		RecLock("SUT",lNovo)
		REPLACE UT_FILIAL With xFilial("SUT")
	
		For nI :=1 TO SUT->(FCount())
			If (FieldName(nI) <> "UT_FILIAL")
				FieldPut(nI, M->&(FieldName(nI)))
			Endif
		Next nI                  
		If nOpc == 5
			dbDelete()		
		EndIf
		MsUnLock()		
		FkCommit()                  
		              
		If nOpc <> 5
			For nI := 1 TO Len(aCols)
				
				//������������������������������Ŀ
				//�Se a linha nao estiver apagada�
				//��������������������������������
				If !aCols[nI][Len(aHeader)+1]
			
					DbSelectArea("SUU")
					RecLock("SUU",.T.)
			
					bCampo := {|nCPO| Field(nCPO) }
					REPLACE SUU->UU_FILIAL 	WITH xFilial("SUU")
					REPLACE SUU->UU_CODSUT 	WITH M->UT_CODIGO     
					REPLACE SUU->UU_ITEM	WITH STRZERO(nI, 3)
					
					For nX := 1 To SUU->(FCount())
		
						If (EVAL(bCampo,nX) <> "UU_FILIAL") .AND. (EVAL(bCampo,nX) <> "UU_CODSUT") 
		
							nPos:= Ascan(aHeader,{|x| ALLTRIM(EVAL(bCampo,nX)) == ALLTRIM(x[2])})
							If (nPos > 0)
								If (aHeader[nPos][10] <> "V" .AND. aHeader[nPos][08] <> "M")
									REPLACE SUU->&(EVAL(bCampo,nX)) With aCols[nI][nPos]
								Endif
							Endif
							
						Endif
		
					Next nX
				
					MsUnLock()
					DbCommit()
				Endif	
				
			Next nI		
		EndIf
	END TRANSACTION


Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef	� Autor � Vendas Cliente        � Data �18/12/07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 
Local aRotina
               
aRotina		:=	{{ 	STR0002	,"AxPesqui" ,0,1 },; 	// 	"Pesquisar"
				{ 	STR0003	,"TK510EOpc" ,0,2 },;   //	"Visualizar"
			 	{ 	STR0004	,"TK510EOpc" ,0,3 },; 	// 	"Incluir"
			 	{ 	STR0005 ,"TK510EOpc" ,0,4 },;   	//	"Alterar"
			 	{ 	STR0006	,"TK510EOpc" ,0,5 }} 	// 	"Excluir"
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK510EOpc    �Autor  �Vendas Cliente   � Data �  31/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe a tela para edicao dos indicadores                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TK510EOpc(cAlias,	nReg,	nOpc,	aEnchoice)   


If nOpc == 2
	oObj:showDialog(nReg, nOpc)	//"Visualizar"
ElseIf nOpc == 3	     
	oObj:showDialog(nReg, nOpc)	//"Incluir"
ElseIf nOpc == 4	     
	oObj:showDialog(nReg, nOpc)	//"Alterar"
ElseIf nOpc == 5	     
	oObj:showDialog(nReg, nOpc)	//Excluir
EndIf
Return .T.                                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA510B     �Autor  �Michel W. Mosca  � Data �  14/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe a tela para associar a lista de assuntos.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMKA510E()    
Static oObj := ManagementIndexDialog():New()

oObj:openBrowse()
Return .T.   