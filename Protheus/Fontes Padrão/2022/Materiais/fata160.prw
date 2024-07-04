#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FATA160.CH'

//Conteudo do Say populado ao escolher cliente ou grupo
Static oSay1	:= NIL
Static oSay2	:= NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA160  � Autor � Vendas & CRM          � Data �31.01.2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Restricoes de Visitas e Entregas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FATA160()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FATA160()
Local aPDFields		:= {"A1_NOME"}

Private cCadastro	:= OemToAnsi(STR0001) //'Cadastro de Restricoes de Visitas e Entregas'
Private aRotina 	:= MenuDef()

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

//�����������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                           �
//�������������������������������������������������������������������������
DEFINE FWMBROWSE oMBrowse ALIAS "ACW" DESCRIPTION STR0001 //'Cadastro de Restricoes de Visitas e Entregas'
ACTIVATE FWMBROWSE oMBrowse	

FATPDUnload()

Return ( .T. )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ViewDef     � Autor �Vendas & CRM           � Data � 31/01/12 ���
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
Local oModel 	 := FWLoadModel( 'FATA160')	  // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
// Cria as estruturas a serem usadas na View
Local oStruACW1 := FWFormStruct( 2, 'ACW' ,{|cCampo| (AllTrim(cCampo) $'ACW_NUMCTR|ACW_GRPVEN|ACW_CODCLI|ACW_LOJA')} )
Local oStruACW2 := FWFormStruct( 2, 'ACW' ,{|cCampo| !(AllTrim(cCampo) $'ACW_NUMCTR|ACW_GRPVEN|ACW_CODCLI|ACW_LOJA')} )    
Local oView									  // Interface de visualiza��o constru�da


oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel( oModel )									// Define qual Modelo de dados ser� utilizado				
oView:AddField( 'VIEW_ACW1', oStruACW1, 'ACWMASTER' )// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddGrid( 'VIEW_ACW2' , oStruACW2, 'ACWDETAIL' )	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddIncrementField( 'VIEW_ACW2', 'ACW_ITEM' )		// Item Incremental do Grid

oView:AddOtherObject("VIEW_SAY", {|oPanel| Ft160Say(oPanel)},NIL,{|| Ft160Pre(FwModelActive())})

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'INFERIOR', 80 )			

oView:CreateVerticalBox( 'SUPERIORESQ', 30, 'SUPERIOR' )
oView:CreateVerticalBox( 'SUPERIORDIR', 70, 'SUPERIOR' )

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_ACW1', 'SUPERIORESQ' )
oView:SetOwnerView( 'VIEW_SAY' , 'SUPERIORDIR')
oView:SetOwnerView( 'VIEW_ACW2', 'INFERIOR' )			

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160Say    � Autor �Vendas & CRM           � Data � 01/02/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Criacao de interface visual "VIEW_SAY"                     	���
���������������������������������������������������������������������������Ĵ��
���Parametros� oPanel - Panel criada pela view                             	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Ft160Say(oPanel)
Local cTexto1		:= ""
Local cTexto2		:= ""

If ValType(oSay1) <> "O" .AND. ValType(oSay2) <> "O" 
	@ 12,0 SAY oSay1 PROMPT cTexto1 SIZE 120,009  OF oPanel PIXEL
	@ 37,0 SAY oSay2 PROMPT cTexto2 SIZE 120,009  OF oPanel PIXEL
Else
	oSay1:SetText(cTexto1)
	oSay2:SetText(cTexto2)
EndIf

Ft160Pre(FwModelActive())

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160LOK    � Autor �Vendas & CRM           � Data � 31/01/12 ���
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
Static Function Ft160LOk(oModelACW)
Local nLoop		:= 0
Local lRet			:= .T.

If oModelACW:getOperation() == MODEL_OPERATION_INSERT .OR. oModelACW:getOperation() == MODEL_OPERATION_UPDATE
	For nLoop := 1 To oModelACW:Length()
		oModelACW:GoLine(nLoop)
		If !oModelACW:IsDeleted()
			//�����������������������������������������������������������������������Ŀ
			//� Validacao se o contato deve ser preenchido                            �
			//�������������������������������������������������������������������������
			If FwFldGet("ACW_ABRANG")=="2" .AND. !Empty(FwFldGet("ACW_CODCON"))
				Help("" , 1, "FT160LINOK", , STR0007, 1, 0,,,,,,{STR0008})	//"O contato n�o deve ser preenchido nesta situa��o."##"Preencha o contato somente se a abrang�ncia for diferente de 'Entrega'"
				lRet := .F.
			Endif
		EndIf
		If lRet
			//�����������������������������������������������������������������������Ŀ
			//� Validacao dos horarios digitados                                      �
			//�������������������������������������������������������������������������
			If ( FwFldGet("ACW_HORA1") > FwFldGet("ACW_HORA2") )
				Help(" ", 1, "VLDHORA")
				lRet := .F.
			EndIf
		EndIf
	Next nLoop
EndIf
	
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ModelDef    � Autor �Vendas & CRM           � Data � 31/01/12 ���
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
Local oStruACW1 := FWFormStruct( 1, 'ACW' ,{|cCampo| (AllTrim(cCampo) $'ACW_NUMCTR|ACW_GRPVEN|ACW_CODCLI|ACW_LOJA')} )	// Estrutura
Local oStruACW2 := FWFormStruct( 1, 'ACW' ,{|cCampo| !(AllTrim(cCampo) $'ACW_NUMCTR|ACW_GRPVEN|ACW_CODCLI|ACW_LOJA')} )	// Estrutura
Local oModel 									// Modelo de dados constru�do

oStruACW1:SetProperty("*",MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN,"INCLUI"))

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FATA160' , NIL, {|oModel| Ft160TOk()})

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'ACWMASTER', /*cOwner*/, oStruACW1)
oModel:AddGrid( 'ACWDETAIL','ACWMASTER', oStruACW2 , ,{|oMdl| Ft160LOK(oMdl)})

oModel:SetRelation("ACWDETAIL",{{"ACW_FILIAL",'xFilial("ACW")'},{"ACW_NUMCTR","ACW_NUMCTR"}},ACW->(IndexKey(1)))
oModel:SetPrimaryKey({'ACW_FILIAL','ACW_NUMCTR','ACW_ITEM'})    
oModel:GetModel('ACWDETAIL'):SetUniqueLine({ "ACW_DATA" })

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Cadastro de Restricoes de Visitas e Entregas'
// Adiciona a descri��o dos Comaadmponentes do Modelo de Dados
oModel:GetModel( 'ACWMASTER' ):SetDescription( STR0001 ) //'Cadastro de Restricoes de Visitas e Entregas'
oModel:GetModel( 'ACWDETAIL' ):SetDescription( STR0001 ) //'Cadastro de Restricoes de Visitas e Entregas'

// Retorna o Modelo de dados
Return oModel

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160Pre    � Autor �Vendas & CRM           � Data � 31/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Ativa��o                                        	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � oModel                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function Ft160Pre(oModel)
Local cTexto1 	:= ""
Local cTexto2 	:= ""
Local cGrpVen	:= ""
Local cCodCli	:= ""
Local cLojCli	:= ""
Local oView		:= NIL

If oModel:GetOperation() <> MODEL_OPERATION_INSERT .AND. ValType(oSay1) == "O" .AND. ValType(oSay2) == "O" 
	cGrpVen	:= ACW->ACW_GRPVEN
	cCodCli	:= ACW->ACW_CODCLI
	cLojCli	:= ACW->ACW_LOJA
	
	If Trim(cGrpVen) <> ""                                            				                                                  
		lRetorno := ExistCpo("ACW", cGrpVen ,2)
		If lRetorno
			cTexto1 := Posicione("ACY",1,xFilial("ACY")+cGrpVen,"ACY_DESCRI") 
		EndIf	
	ElseIf Trim(cCodCli+cLojCli) <> "" 				
		lRetorno := ExistCpo("ACW",cCodCli+cLojCli,3)
		If lRetorno			
			cTexto2 := FATPDObfuscate(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_NOME"),"A1_NOME")
		EndIf			
	EndIf
EndIf

If 	ValType(oSay1) == "O" .AND. ValType(oSay2) == "O" 	
	oSay1:SetText(cTexto1)
	oSay2:SetText(cTexto2)
	oSay1:CtrlRefresh()
	oSay2:CtrlRefresh()
EndIf 

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |Fat160ITem  �Autor �Fernando Amorim      � Data � 23/02/07  ���
�������������������������������������������������������������������������͹��
���Descricao �Inclui na primeira linha do acols o numero do item 		  ���
�������������������������������������������������������������������������͹��
���Parametros�												              ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Restricoes de Visitas e Entregas            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Fat160Item(aRegACW)
Local nX := 0
If !ACW->(EOF())
	aAdd(aRegACW,ACW->(RecNo()))
EndIf
If Len(aCols) == 1
	For nX := 1 To Len(aHeader)
			If AllTrim(aHeader[nX,2]) == "ACW_ITEM"
				Acols[Len(Acols),nX] := "01"
			
			EndIf    
	Next nX
EndIf  
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160Grv  � Autor �Eduardo Riera          � Data �07.11.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de gravacao da tabela de restricoes de entrega/visita���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se houve atualizacao dos dados                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo de gravacao                                   ���
���          �       [1] Inclusao                                         ���
���          �       [2] Alteracao                                        ���
���          �       [3] Exclusao                                         ���
���          �ExpA2: Registros da tabela                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ft160Grv( nOpcao , aRegACW )

Local lTravou:= .F.
Local lGravou:= .F.
Local nX     := 0
Local nY     := 0
Local nUsado := Len(aHeader)

DEFAULT aRegACW := {}

If nOpcao <> 3
	For nX := 1 To Len(aCols)
		lTravou := .F.
		If nX <= Len(aRegACW) .AND. nOpcao==2
			ACW->(dbGoto(aRegACW[nX]))
			RecLock("ACW")
			lTravou := .T.
		Else
			If !aCols[nX][nUsado+1]
				RecLock("ACW",.T.)
				lTravou := .T.
			Else
				lTravou := .F.
			EndIf
		EndIf
		If !aCols[nX][nUsado+1]
			lGravou := .T.
			For nY := 1 To nUsado
				If aHeader[nY][10]<>"V"
					ACW->(FieldPut( FieldPos( aHeader[nY][2] ), aCols[nX][nY] ))
				EndIf
			Next nY
			ACW->ACW_FILIAL := xFilial("ACW")
			ACW->ACW_NUMCTR := M->ACW_NUMCTR
			ACW->ACW_GRPVEN := M->ACW_GRPVEN
			ACW->ACW_CODCLI := M->ACW_CODCLI
			ACW->ACW_LOJA   := M->ACW_LOJA
			MsUnLock()
		Else
			If lTravou
				ACW->(dbDelete())
			EndIf
		EndIf
	Next nX
Else
	For nX := 1 To Len(aRegACW)
		ACW->(dbGoto(aRegACW[nX]))
		RecLock("ACW")
		ACW->(dbDelete())
		lGravou := .T.
	Next nX
EndIf
Return(lGravou)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160LinOk� Autor �Eduardo Riera          � Data �07.11.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da LinhaOk                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que as informacoes sao validas                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft160LinOk()
 
Local cHoraNull  := "  :  " 

Local nUsado     := Len(aHeader)
Local lRetorno   := .T.

Local nPHora1    := GdFieldPos('ACW_HORA1' )
Local nPHora2    := GdFieldPos('ACW_HORA2' )
Local nPMotivo   := GdFieldPos('ACW_MOTIVO')
Local nPTipo     := GdFieldPos('ACW_TIPO'  )
Local nPAbrang   := GdFieldPos('ACW_ABRANG')
Local nPCodCon   := GdFieldPos('ACW_CODCON')

If !aCols[n][nUsado + 1]
//�����������������������������������������������������������������������Ŀ
//� Validacao dos campos obrigatorios.                                    �
//�������������������������������������������������������������������������
	Do Case
		Case aCols[n,nPHora1] == cHoraNull
			Help(" ", 1, "OBRIGAT",,RetTitle("ACW_HORA1"))
			lRetorno := .F.
		Case aCols[n,nPHora2] == cHoraNull
			Help(" ", 1, "OBRIGAT",,RetTitle("ACW_HORA2"))
			lRetorno := .F.
		Case Empty(aCols[n,nPMotivo])
			Help(" ", 1, "OBRIGAT",,RetTitle("ACW_MOTIVO"))
			lRetorno := .F.
		Case Empty(aCols[n,nPTipo])
			Help(" ", 1, "OBRIGAT",,RetTitle("ACW_TIPO"))
			lRetorno := .F.
		Case Empty(aCols[n,nPAbrang])
			Help(" ", 1, "OBRIGAT",,RetTitle("ACW_ABRANG"))
			lRetorno := .F.
	EndCase
//�����������������������������������������������������������������������Ŀ
//� Validacao se o contato deve ser preenchido                            �
//�������������������������������������������������������������������������
	If aCols[n,nPAbrang]=="2" .AND. !Empty(aCols[n,nPCodCon])
		Help(" ",1,"FT160LINOK")
		lRetorno := .F.
	Endif        

	If lRetorno 
		//�����������������������������������������������������������������������Ŀ
		//� Validacao dos horarios digitados                                      �
		//�������������������������������������������������������������������������
		If ( aCols[ n, nPHora1 ] > aCols[ n, nPHora2 ] ) 
			Help(" ", 1, "VLDHORA")
			lRetorno := .F.
      EndIf 
	
	EndIf 	         
	
	If lRetorno 
		//�����������������������������������������������������������������������Ŀ
		//� Validacao de duplicidade                                              �
		//�������������������������������������������������������������������������
		lRetorno := GDCheckKey( { "ACW_DATA" }, 3 ) 		
	EndIf 
	
EndIf                                


Return ( lretorno )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160TOk  � Autor �Vendas & CRM           � Data �01.02.2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da TudoOk                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que as informacoes sao validas                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft160TOk(oMdl)

Local lRetorno := .T.

//�����������������������������������������������������������������������Ŀ
//� Validacao do cabecalho                                                �
//�������������������������������������������������������������������������
If ( Empty( FwFldGet("ACW_GRPVEN") ) .AND. Empty( FwFldGet("ACW_CODCLI") ) ) .OR. ;
	( Empty( FwFldGet("ACW_CODCLI") ) .AND. !Empty( FwFldGet("ACW_LOJA") ) )  .OR. ;
	( !Empty( FwFldGet("ACW_CODCLI") ) .AND. Empty( FwFldGet("ACW_LOJA") ) ) 
	Help( " ", 1, "OBRIGAT" ) 
	lRetorno := .F. 
EndIf

If lRetorno 
	If ( !Empty( FwFldGet("ACW_GRPVEN") ) .AND. !Empty( FwFldGet("ACW_CODCLI") ) ) .OR. ;
		( !Empty( FwFldGet("ACW_GRPVEN") ) .AND. !Empty( FwFldGet("ACW_LOJA") ) ) 
		Help( " ", 1, "FT160DUP" ) // Nao e possivel definir grupos de clientes e clientes / loja ao mesmo tempo 
		lRetorno := .F. 
	EndIf		
EndIf 

Return ( lRetorno )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160TudOk� Autor �Eduardo Riera          � Data �07.11.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da TudoOk                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que as informacoes sao validas                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft160TudOk(oMdl)

Local lRetorno := .T.

//�����������������������������������������������������������������������Ŀ
//� Validacao do cabecalho                                                �
//�������������������������������������������������������������������������	

If ( Empty( M->ACW_GRPVEN ) .AND. Empty( M->ACW_CODCLI ) ) .OR. ;
	( Empty( M->ACW_CODCLI ) .AND. !Empty( M->ACW_LOJA ) )  .OR. ;
	( !Empty( M->ACW_CODCLI ) .AND. Empty( M->ACW_LOJA ) ) 
                                                                
	Help( " ", 1, "OBRIGAT" ) 
	lRetorno := .F. 
EndIf

If lRetorno 
	If ( !Empty( M->ACW_GRPVEN ) .AND. !Empty( M->ACW_CODCLI ) ) .OR. ;
		( !Empty( M->ACW_GRPVEN ) .AND. !Empty( M->ACW_LOJA ) ) 
		Help( " ", 1, "FT160DUP" ) // Nao e possivel definir grupos de clientes e clientes / loja ao mesmo tempo 
		lRetorno := .F. 
	EndIf		
EndIf 

Return ( lRetorno )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft160Vld  � Autor �Eduardo Riera          � Data �07.11.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do cabecalho da restricao de entrega/visita       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se os dados preenchidos estao validos         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do arquivo                                     ���
���          �ExpN2: Registro do Arquivo                                  ���
���          �ExpN3: Opcao da MBrowse                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft160Vld()

Local aArea    	:= GetArea()
Local aAreaACY 	:= ACY->(GetArea())

Local cCampo   	:= ReadVar()  
Local cConteudo	:= &( ReadVar() ) 

Local lRetorno 	:= .T.           

//�����������������������������������������������������������������������Ŀ
//� Verifica se cabecalho foi preenchido corretamente                     �
//�������������������������������������������������������������������������
If "ACW_GRPVEN" $ cCampo                                            	
		                                                  
	lRetorno := ExistChav("ACW", cConteudo ,2)
	If lRetorno
		oSay2:SetText("")
		oSay1:SetText(Posicione("ACY",1,xFilial("ACY")+cConteudo,"ACY_DESCRI"))
		M->ACW_CODCLI := CriaVar( "ACW_CODCLI", .T. ) 
		M->ACW_LOJA   := CriaVar( "ACW_LOJA"  , .T. ) 
	EndIf

ElseIf "ACW_CODCLI" $ cCampo .OR. "ACW_LOJA" $ cCampo 	
	
	If Trim(M->ACW_CODCLI) <> "" .AND. Trim(M->ACW_LOJA) <> ""		
		lRetorno := ExistChav("ACW",M->ACW_CODCLI+M->ACW_LOJA,3)
		If lRetorno
			oSay1:SetText("")
			oSay2:SetText(FATPDObfuscate(Posicione("SA1",1,xFilial("SA1")+M->ACW_CODCLI+M->ACW_LOJA,"A1_NOME"),"A1_NOME"))
			M->ACW_GRPVEN := CriaVar( "ACW_GRPVEN", .T. )
		Else 		
			FwFldPut("ACW_LOJA","")
			FwFldPut("ACW_CODCLI","")			
		EndIf
	EndIf
		
EndIf

FATPDLogUser('FT160VLD')

RestArea(aAreaACY)
RestArea(aArea)
Return(lRetorno)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
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
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
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

Private aRotina := {}	//Array para opcoes

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.FATA160' OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.FATA160' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FATA160' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FATA160' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FATA160' OPERATION 5 ACCESS 0 //"Exclui"				
If ExistBlock("FT160MNU")
	ExecBlock("FT160MNU",.F.,.F.)
EndIf
Return(aRotina)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote��o de dados.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa��es enviadas, 
    quando a regra de auditoria de rotinas com campos sens�veis ou pessoais estiver habilitada
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser� utilizada no log das tabelas
    @param nOpc, Numerico, Op��o atribu�da a fun��o em execu��o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n�o esteja aplicada, tamb�m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
