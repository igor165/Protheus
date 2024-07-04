#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA571.CH"

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA571   | Autor � Vendas CRM                    � Data �30.01.2012���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de regra de rodizio.                                       ���
���          � Permite definir faixas de valores para compar com a informacao      ��� 
���          � proveniente do cadastro do Suspect ou Prospect, conforme definido   ���
���          � no tipo de regra escolhido, alem de definir e manter a posicao do   ���
���          � do vendedor na fila do rodizio                                      ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fata571()
Private cCadastro 	:= OemToAnsi(STR0001)   // Cadastro de Regra de Rodizio
aRotina 			:= MenuDef()

SX2->(DbSetOrder(1))

If !SX2->(DbSeek("ADG"))
	MsgStop(STR0008) //"Solicite ao administrador que execute o update 'U_UpdRODZ' antes de executar esta rotina"
	Return Nil
EndIf

DEFINE FWMBROWSE oMBrowse ALIAS "ADG" //DESCRIPTION STR0001
ACTIVATE FWMBROWSE oMBrowse
	
Return    


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �MenuDef     � Autor �Vendas & CRM           � Data � 30/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do aRotina (Menu funcional)                        ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()

Private aRotina := {}	//Array para opcoes
				
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.FATA571' OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FATA571' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FATA571' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FATA571' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.FATA571' OPERATION 5 ACCESS 0 //"Exclui"
								
Return(aRotina)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ViewDef     � Autor �Vendas & CRM           � Data � 30/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao da View                                          	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � oView                                                       	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
Local oModel 	 := FWLoadModel( 'FATA571' )	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruADG := FWFormStruct( 2, 'ADG' )	// Cria as estruturas a serem usadas na View
Local oStruADH := FWFormStruct( 2, 'ADH' ) // Retira o Campo AG4_CODIGO do Grid.
Local oView									// Interface de visualiza��o constru�da

oStruADH:RemoveField("ADH_COD")

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel( oModel )									// Define qual Modelo de dados ser� utilizado				
oView:AddField( 'VIEW_ADG', oStruADG, 'ADGMASTER' )	// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddGrid( 'VIEW_ADH' , oStruADH, 'ADHDETAIL' )	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddIncrementField( 'VIEW_ADH', 'ADH_NUMITE' )		// Item Incremental do Grid

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 35 )			
oView:CreateHorizontalBox( 'INFERIOR', 65 )

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_ADG', 'SUPERIOR' )			
oView:SetOwnerView( 'VIEW_ADH', 'INFERIOR' )

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ModelDef    � Autor �Vendas & CRM           � Data � 30/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do Model                                         	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � oModel                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruADG := FWFormStruct( 1, 'ADG' )
Local oStruADH := FWFormStruct( 1, 'ADH' )
Local oModel // Modelo de dados constru�do

oStruADG:SetProperty("ADG_FILIAL",MODEL_FIELD_OBRIGAT,.F.)
oStruADG:SetProperty("ADG_POSICA",MODEL_FIELD_INIT, {|| Fa571Pos() })

oStruADH:RemoveField("ADH_COD")
oStruADH:SetProperty("ADH_FILIAL",MODEL_FIELD_OBRIGAT,.F.)

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FATA571')

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'ADGMASTER', /*cOwner*/, oStruADG )
// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'ADHDETAIL', 'ADGMASTER', oStruADH )
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'ADHDETAIL', { { 'ADH_FILIAL', 'xFilial( "ADH" )' }, { 'ADH_COD', 'ADG_COD' } }, ADH->( IndexKey( 1 ) ) )

//Linha unica dos grid
oModel:GetModel( 'ADHDETAIL' ):SetUniqueLine( { 'ADH_NUMITE','ADH_TIPREG','ADH_FAIXDE','ADH_FAIXAT'} )

Return oModel   
  
/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa571Grv  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao da regra de rodizio                                        ���
���          �                                                                     ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Static Function Fa571Grv(cAlias, nOpc)
Local aArea := getArea()         // Salva a Area atual antes de iniciar esse processo.
Local cAlias1         := "ADH"   //Itens da regra 
Local lGravou           := .F.   // Se gravou algum registro
Local nI                := 0     // Variavel auxiliar para laco
Local nII               := 0     // Variavel auxiliar para sublaco
Local nNumIte           := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_NUMITE"}) // Poscicao do campo  ADH_NUMITE 
Local nTipReg           := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_TIPREG"}) // Poscicao do campo  ADH_TIPREG
Local nFaixDe           := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_FAIXDE"}) // Poscicao do campo  ADH_FAIXDE 
Local nFaixAt           := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_FAIXAT"}) // Poscicao do campo  ADH_FAIXAT
Local cItem             := Repl("0",TamSX3("ADH_NUMITE")[1])                // Sequencial para o item
Local cDadoFrm          := ""       // Dados formatado com o pitcture

//������������Ŀ
//�Gravar itens�
//��������������
If (nOpc == 3) .Or. (nOpc == 4)

	//�������������������������Ŀ
	//�Colocar os itens na ordem�
	//���������������������������
	aSort(oGet:aCols,,,{|x,y| x[1] < y[1] })

	dbSelectArea(cAlias1)
	For nI := 1 To Len(oGet:aCols)

   		(cAlias1)->(dbSeek(xFilial(cAlias1) + M->ADG_COD + oGet:aCols[nI,nNumIte]))

		If !oGet:aCols[nI, Len(aHeader)+1]
       		RecLock(cAlias1,!(cAlias1)->(Found()))
	         	For nII := 1 To Len( aHeader )
		         	If aHeader[ nII, 10 ] <> "V"
				        //�������������������������������������������������������������Ŀ
						//�Para o campo FaixDe e FaixAt transformar o valor para gravar �
						//���������������������������������������������������������������
			            If (nII == nFaixDe) .Or. (nII == nFaixAt)
			                cDadoFrm := Fa571Pcd(oGet:aCols[nI, nTipReg],oGet:aCols[nI, nII])
			                FieldPut(FieldPos(aHeader[nII,2]), cDadoFrm)
			            Else
			            	FieldPut(FieldPos( aHeader[nII,2]), oGet:aCols[nI, nII])
			            EndIf
		         	Endif
	      		Next nII
    	   		    If !(cAlias1)->(Found())
			   		    (cAlias1)->ADH_FILIAL := xFilial(cAlias1)
			   		    (cAlias1)->ADH_COD    := M->ADG_COD
			   		    (cAlias1)->ADH_NUMITE := oGet:aCols[nI,nNumIte]    
		   		    EndIf
      		(cAlias1)->(MsUnLock())
      		lGravou := .T.
   		Else                              	
      		If !(cAlias1)->(Found())
         		Loop
	   		Endif
      		RecLock( cAlias1, .F. )
         		(cAlias1)->(dbDelete())
      		(cAlias1)->(MsUnLock(cAlias1)) 
      		lGravou := .T.
   		Endif
   		
	Next nI

	dbSelectArea( cAlias1 )
	
	//����������������Ŀ
	//�Gravar cabe�alho�
	//������������������
    If (lGravou)  .And. (nOpc <> 5)

	    dbSelectArea(cAlias)
		dbSetOrder(1)
		dbSeek(xFilial(cAlias)+M->ADG_COD)
		
   		RecLock(cAlias, !Found())
	   		For nI := 1 TO FCount()
				FieldPut(nI,M->&(EVAL(bCampo,nI)))
   			Next nI	
   			(cAlias)->ADG_FILIAL := xFilial(cAlias)
		(cAlias)->(MsUnLock()) 
	
	Endif

EndIf

//���������������
//�Excluir itens�
//���������������
If nOpc == 5
   
	dbSelectArea(cAlias1)
    dbSetOrder(1)
	For nI := 1 To Len(oGet:aCols)
		(cAlias1)->(dbSeek(xFilial(cAlias1) + M->ADG_COD + oGet:aCols[nI,nNumIte]))
		If !(cAlias1)->(Found())
		   	Loop
		Endif
		RecLock( cAlias1, .F. )
		   	(cAlias1)->(dbDelete())
		(cAlias1)->(MsUnLock())
		lGravou := .T.
	Next nI

	//�����������������Ŀ
	//�Excluir cabe�alho�
	//�������������������
	dbSelectArea(cAlias)
	RecLock(cAlias, .F.)	
		(cAlias)->(dbDelete())
	(cAlias)->(MsUnLock())
	lGravou := .T.
EndIf
                       
RestArea(aArea)

Return( lGravou )

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa571LOk  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da linha                                                  ���
���          �                                                                     ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fa571LOk()
Local aArea     := GetArea()    // Salva a Area atual antes de iniciar esse processo.
Local lRetorno  := .T.          // Retorno da funcao
Local nNumIte   := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_NUMITE"}) // Poscicao do campo  ADH_NUMITE 
Local nTipReg   := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_TIPREG"}) // Poscicao do campo  ADH_TIPREG 
Local nFaixDe   := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_FAIXDE"}) // Poscicao do campo  ADH_FAIXDE 
Local nFaixAt   := aScan(aHeader,{|x| AllTrim(x[2])=="ADH_FAIXAT"}) // Poscicao do campo  ADH_FAIXAT 
Local nI        := 0           // Auxiliar do laco

//����������������������������������Ŀ
//�Verifica os campos da chave       �
//������������������������������������
If nNumIte == 0 
	lRetorno := .F.
	Help(" ",1,"OBRIGAT",,RetTitle("ADH_NUMITE"),4)
EndIf

//���������������������������������������������Ŀ
//�Verificar outros campos obrigatorio em branco�
//�����������������������������������������������
For nI := 1 To Len(aHeader)
    If X3Obrigat(aHeader[nI][2]) .And. Empty(oGet:aCols[oGet:nAt][aScan(aHeader,{|x| AllTrim(x[2])==aHeader[nI][2]})])
    	Help(" ",1,"OBRIGAT",,RetTitle(aHeader[nI][2]),4)
    	lRetorno := .F.
    EndIf
Next nI

//������������������������������������������������������������������������Ŀ
//�Verifica se nao ha valores duplicados                                   �
//��������������������������������������������������������������������������
If lRetorno
	For nI := 1 To Len(oGet:aCols)
		If nI <> oGet:nAt .And. !oGet:aCols[nI][Len(aHeader)+1]
			If (oGet:aCols[nI][nTipReg]+oGet:aCols[nI][nFaixDe]+oGet:aCols[nI][nFaixAt]==oGet:aCols[oGet:nAt][nTipReg]+;
			    oGet:aCols[oGet:nAt][nFaixDe]+oGet:aCols[oGet:nAt][nFaixAt])

				lRetorno := .F.
				Help(" ",1,"JAGRAVADO")
			
		EndIf
		EndIf
	Next nI
EndIf
RestArea(aArea)
Return(lRetorno)

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa571TOk  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Validaca da tela                                                    ���
���          �                                                                     ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fa571TOk()
Local lRetorno  := .T.    // Retorno da funcao

lRetorno := Fa571LOk()

//��������������������������Ŀ
//�Redefine a posicao na fila�
//����������������������������

M->ADG_POSICA := Fa571Pos()
 
Return(lRetorno) 

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa571Pos  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �  Busca ultima posicao na fila de vendedores                         ���
���          �                                                                     ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Posicao                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fa571Pos()
Local aArea      := getArea()   // Salva a Area atual antes de iniciar esse processo.
Local cPosicao   := StrZero(0,TamSx3("ADG_POSICA")[1]) //Posicao  

DbSelectArea("ADG")
DbSetOrder(2)

//���������������������������Ŀ
//�Posiciona no ultimo da fila�
//�����������������������������
ADG->(DbGoBottom())

cPosicao := Soma1(ADG->ADG_POSICA)
                           
RestArea(aArea)           
Return cPosicao 


/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa571Vld  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �  Validacao da faixa de dados da regra                               ���
���          �                                                                     ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Posicao                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fa571Vld()

Local aArea		:= getArea()   // Salva a Area atual antes de iniciar esse processo.
Local cVar		:= ReadVar()   // Varivel campo atualmente em foco
Local LenOri	:= Len(&(cVar))// Tamanho original
Local lRet		:= .F.         // Auxiliar do retorno da funcao
Local cResult	:= Nil         // Resultado do dado transformado
Local cDado		:= ""          // Informacao
Local nTipReg	:= 0
Local cSeek		:= ""
Local oModel	
Local oMdlADH		

oModel	:= FWModelActive()
oMdlADH	:= oModel:GetModel("ADHDETAIL")
cSeek 	:= oModel:GetValue("ADHDETAIL","ADH_TIPREG")

cDado := AllTrim(&(cVar))
//���������������������������Ŀ
//�Posicionar no tipo de regra�
//�����������������������������
DbSelectArea("ADI")
DbSetOrder(1)
ADI->(DbSeek(xFilial("ADI")+cSeek))

//���������������������Ŀ
//�Procurar campo no SX3�
//�����������������������
DbSelectArea("SX3")
SX3->(dbSetOrder(2))
SX3->(dbSeek(ADI->ADI_CAMPO))

//�����������������������������������������Ŀ
//�Pegar informacao do campo conforme o tipo�
//�������������������������������������������
If SX3->X3_TIPO == "N"
	cResult := AllTrim(Transform(Val(cDado), X3_PICTURE))
ElseIf SX3->X3_TIPO == "D"
	cResult := AllTrim(Transform(CToD(cDado),X3_PICTURE))
Else
	cResult := AllTrim(Transform(cDado,X3_PICTURE))
EndIf

//������������������Ŀ
//�Verifica resultado�
//��������������������
If (cResult == Nil) .Or. (Empty(cResult)) .Or. (SX3->X3_TIPO == "N" .AND. Val(cResult) == 0) .Or. (cResult == "  /  /  ")
  lRet := .F.
Else

  oMdlADH:LoadValue(StrTran(cVar, "M->", ""),Substr(PADR(cResult,LenOri),1,LenOri))
  lRet := .T.                           
EndIf  

RestArea(aArea)           
Return lRet


/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa571Pcf  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �  Formata a informacao do campo conforme a picture                   ���
���          �                                                                     ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� cTipReg - Tipo de regra de rodizio                                  ���
���          � cDado   - Informacao do campo a ser formatada                       ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Posicao                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fa571Pcf(cTipReg,cDado)
Local aArea      := getArea()
Local cRet       := ""     
Local nFaixTam    := TamSX3("ADH_FAIXDE")[1]
//���������������������������Ŀ
//�Posicionar no tipo de regra�
//�����������������������������
DbSelectArea("ADI")
DbSetOrder(1)
ADI->(DbSeek(xFilial("ADI")+cTipReg))

//���������������������Ŀ
//�Procurar campo no SX3�
//�����������������������
DbSelectArea("SX3")
SX3->(dbSetOrder(2))
SX3->(dbSeek(ADI->ADI_CAMPO))

If SX3->X3_TIPO == "N"
	cRet := Transform(Val(cDado), X3_PICTURE)
ElseIf SX3->X3_TIPO == "D"
	cRet := Transform(CToD(cDado),X3_PICTURE)
ElseIf SX3->X3_TIPO == "C"
	cRet := Transform(cDado,X3_PICTURE)
EndIf

//���������������������������������������Ŀ
//�Deixar dado conforme o tamanho do campo�
//�����������������������������������������
cRet := PadR(AllTrim(cRet), nFaixTam, ' ')

RestArea(aArea)           
Return cRet

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa571Pcd  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �  Desformata a informacao deixando o sem os caracteres especiais     ���
���          �  da picture                                                         ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� cTipReg - Tipo de regra de rodizio                                  ���
���          � cDado   - Informacao do campo a ser desformatada                    ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Posicao                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fa571Pcd(cTipReg,cDado)
Local aArea      := getArea()
Local cRet       := ""
Local cRetx      := ""  
Local nFaixTam   := TamSX3("ADH_FAIXDE")[1]
Local nI         := 0
//���������������������������Ŀ
//�Posicionar no tipo de regra�
//�����������������������������
DbSelectArea("ADI")
DbSetOrder(1)
ADI->(DbSeek(xFilial("ADI")+cTipReg))

//���������������������Ŀ
//�Procurar campo no SX3�
//�����������������������
DbSelectArea("SX3")
SX3->(dbSetOrder(2))
SX3->(dbSeek(ADI->ADI_CAMPO))

If SX3->X3_TIPO == "D"
	cRet := DToS(CToD(cDado))
ElseIf SX3->X3_TIPO == "N"
	
//���������������������������
//�Trocar virgulas por ponto�
//���������������������������
	cRetx := ""
	cRet := AllTrim(cDado)
	For nI := 1 to Len(cRet) 
	   If SubStr(cRet, nI,1) <> "."
	   		cRetx += SubStr(cRet, nI,1)
	   EndIf
	Next nI
	cRet := StrTran(cRetx,",",".")  
	cRet := PadL(cRet, nFaixTam, '0')
ElseIf SX3->X3_TIPO == "C"
//���������������������
//�Tirar tra�o e barra�
//���������������������
	If "@R" $ X3_PICTURE
		cRetx := ""
		cRet := AllTrim(cDado)
		For nI := 1 to Len(cRet) 
		   If !(SubStr(cRet, nI,1) $ "-/.,[]{}=+_|?<>\")
		   		cRetx += SubStr(cRet, nI,1)
		   EndIf
		Next nI
		cRet := cRetx
     Else	
		cRet := cDado
     EndIf
EndIf 
//���������������������������������������Ŀ
//�Deixar dado conforme o tamanho do campo�
//�����������������������������������������
cRet := PadR(AllTrim(cRet), nFaixTam, ' ')

RestArea(aArea)           
Return cRet

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � FA571F3   | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �  Troca o F3 adequando ao campo do tipo de regra escolhido           ���
���          �                                                                     ���                                                ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Posicao                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function FA571F3()

Local lRet			:= .T.
Local aArea			:= getArea()
Local nFaixDe			:= 0
Local nFaixAt			:= 0 
Local cTpRegra	 	:= &(ReadVar())
           
Return lRet

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � FA571F3MVC| Autor � Vendas CRM                    � Data �21.01.2012���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Padrao F3 customizada, chamar� a consulta conforme ADH_TIPO���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Posicao                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function FA571F3MVC() 
Local lRet := .F.

Local oModel		:= FwModelActive()
Local oModelADH 	:= oModel:GetModel('ADHDETAIL')

Local lRet			:= .T.
Local aArea			:= GetArea()
Local nFaixDe			:= oModelADH:GetValue("ADH_FAIXDE")
Local nFaixAt			:= oModelADH:GetValue("ADH_FAIXAT") 
Local cMVar		 	:= ReadVar()
Local cVar			:= StrTran(cMVar, "M->", "")
Local cTpRegra		:= oModelADH:GetValue("ADH_TIPREG") 
Local cF3				:= ""
Local cTabela			:= ""
Local cVal			:= ""

DbSelectArea("ADI")
DbSetOrder(1)

If DbSeek(xFilial("ADI")+cTpRegra)
	//��������������������������������������������Ŀ
	//�Procurar campo no SX3 e pegar conteudo do F3�
	//����������������������������������������������
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(ADI->ADI_CAMPO))
		cF3 := SX3->X3_F3						
	EndIf 	
EndIf

If Trim(cF3) == ""
	Alert('Este campo n�o possui consulta padr�o')
Else
	DbSelectArea("SXB")
	SXB->(dbSetOrder(1))
	If SXB->(dbSeek(cF3+"1"))
		If Trim(SXB->XB_CONTEM) != "admi"
			cTabela := Trim(SXB->XB_CONTEM)
		EndIf
	EndIf
	If SXB->(dbSeek(cF3+"5"))
		If Trim(SXB->XB_CONTEM) != ""
			cVal := Trim(SXB->XB_CONTEM)
		EndIf 			
		SXB->(DbSkip())
	EndIf
	
	If cVal <> "" .AND. cTabela <> "" 
		lRet := Conpad1( NIL,NIL,NIL,cF3)
		If lRet 
			//oModelADH:LoadValue(cVar,&(cVal))
			&(cMVar) := &(cVal)
		EndIf			
	//Se nao achou na sxb tenta na sx5 
	ElseIf Len(Trim(cF3)) == 2 .AND. cVal== "" .AND. cTabela == "" 
		lRet := Conpad1( NIL,NIL,NIL,cF3)
		&(cMVar) := SX5->X5_CHAVE
	EndIf		
EndIf

RestArea(aArea)

Return lRet
                                                                                                                                                                                                                                             