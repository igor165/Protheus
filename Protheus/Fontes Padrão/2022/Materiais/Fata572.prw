#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA572.CH" 
#INCLUDE 'FWMVCDEF.CH'

Static cSX2F3 := ""

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA572   | Autor � Vendas CRM                    � Data �24.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Cadastro de tipo de regra de rodizio.                               ���
���          � Permite definir tipos de regras de rodizio informando a tabela e    ���                                              
���          � o campo que contera a informacao para validar                       ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Totvs                                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function Fata572()
Local oBrowse   	:= Nil 
Private cCadastro	:= STR0001 //"Atualiza��o de Regra de Rod�zio"
Private aRotina	:= MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ADI')                                       
oBrowse:SetDescription(STR0001) //"Atualiza��o de Regra de Rod�zio"
oBrowse:Activate()

Return .T.  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Vendas Clientes     � Data �  22/11/2007 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina usada para realizar manueten��o na tabela ADK.      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA510                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
					  
Local aRotina   := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'PesqBrw' 					OPERATION 1	ACCESS 0 //Pesquisar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA572'			OPERATION 2	ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA572'			OPERATION 3	ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA572'			OPERATION 4	ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FATA572'  			OPERATION 5	ACCESS 0 //Excluir	
ADD OPTION aRotina TITLE STR0008 ACTION 'Fa572Mnt("ADI",3, 1,.T.)'	OPERATION 6	ACCESS 0 //Manutencao								
					
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados em MVC                             ���
�������������������������������������������������������������������������͹��
���Uso       �FATA510                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruADI := FWFormStruct(1,'ADI', /*bAvalCampo*/,/*lViewUsado*/ )

Local bCommit		:= {|oMdl|FATA572Cmt(oMdl)}		//Gravacao dos dados

oModel := MPFormModel():New('FATA572',/*bPreValidacao*/,{|oModel| FA572TOK(oModel)}, bCommit, /*bCancel*/ )

oModel:AddFields('ADIMASTER',/*cOwner*/,oStruADI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0001)

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para Tela de cadastro no MVC             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA510                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('FATA572')
Local oStruADI := FWFormStruct( 2,'ADI') 
Local cAction

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_ADI',oStruADI,'ADIMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_ADI','TELA')

cAction := {||Fa572Pri('ADI',oModel, 1)}
oView:addUserButton(STR0015," ",cAction,"PARAMETROS") 
    
Return oView   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA572Cmt� Autor � Vendas CRM         � Data �  11/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario MVC.    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA572                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FATA572Cmt(oMdl)

Local nOperation := oMdl:GetOperation()
Local aArea := getArea()
 
If (nOperation == 3) .Or. (nOperation == 4)
	FWModelActive( oMdl )
	FWFormCommit( oMdl ) 
ElseIf nOperation == 5 .And. FT572VldEx(oMdl)
	FWModelActive( oMdl )
	FWFormCommit( oMdl )
Endif                
RestArea(aArea)
 
Return (.T.) 

/*
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa572Pri  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao na prioridade (peso) do tipo da regra de rodizio         ���
���          �                                                                     ���                                             
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Goldfarb - Menu                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� lMenu - .T.(Funcao chamada pelo Button no Browse                    ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Function Fa572Pri(cAlias, oMdl , nRec, lMenu)  

Local aArea             := getArea()        // Salva a �rea atual antes de iniciar esse processo.
Local cCadastro         := STR0001          // Cadastro de Tipo de Regra de Rodizio
Local nOpc              := oMdl:GetOperation()
Local nOpcA             := 0                // Opcao escolhida no fechamento da janela
Local oDlg                                  // Janela
Local aCpoEnch  	    := NIL              // Campos da enchoice
Local aAlterEnch	    := NIL              // Campos alteraveis da echoice
Local cNotGet           := ""               // Campos excluidos da getdados
Local cTudoOk           := .T.              // Validacao do fechamento da janela
Local aAlter      	 	:= NIL              // Array de campos alteraveis da getdados
Local cLinOk    		:= "AllwaysTrue"    // Funcao executada para Validar o contexto da linha atual do aCols
Local cTudoOkGet   		:= "AllwaysTrue"    // Funcao executada para Validar o contexto geral da MsNewGetDados ( todo aCols )
Local cIniCpos  	   	:= ""               // Campos que serao inicializados ao inserir na getdados
Local nFreeze      		:= 000
Local nMax         		:= 999
Local cFieldOk  		:= "AllwaysTrue"    // Funcao executada na Validacao do campo
Local cSuperDel     	:= NIL
Local cDelOk    		:= "AllwaysTrue"   	// Funcao executada para Validar a exclusao de uma linha do aCols
Local aSize             := {}              // Definicao do tamanho da janela
Local aObjects          := {}              // Definicao do tamanho da janela
Local aInfo             := {}              // Definicao do tamanho da janela
Local nI                := 0               // Auxiliar do laco
Local nOpcAux           := nOpc            // Auxiliar nOpc
Local oUp               := LoadBitmap( GetResources(), "TriUp" ) //Imagem da seta para cima
Local oDown             := LoadBitmap( GetResources(), "TriDown" )//Imagem da seta para baixo
Private oGet
Private aHeader         := {}
Private aCols           := {}

Default lMenu           := .F.

//������������������������������������Ŀ
//�Quando inclusao mudar para alteracao�
//��������������������������������������
If (nOpc == 3)
   nOpc := 4 
   INCLUI := .F.
EndIf


aAdd( aHeader, { '', 'UP'  , '@BMP', 2, 0,,, 'C',, 'V' ,  , } )
aAdd( aHeader, { '', 'DOWN', '@BMP', 2, 0,,, 'C',, 'V' ,  , } )

//���������������Ŀ
//�Carrega aHeader�
//�����������������
DbSelectArea(cAlias)
DbSetOrder(2)
DbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == cAlias
	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. !AllTrim(SX3->X3_CAMPO) $ cNotGet
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		                SX3->X3_CAMPO        ,;
		                SX3->X3_PICTURE      ,;
		                SX3->X3_TAMANHO      ,; 
		                SX3->X3_DECIMAL      ,; 
		                SX3->X3_VALID        ,;
		                SX3->X3_USADO        ,;
		                SX3->X3_TIPO         ,;
		                SX3->X3_F3           ,;
		                SX3->X3_CONTEXT      ,;
		                SX3->X3_CBOX		 ,;   
		                SX3->X3_RELACAO      })
		           
	Endif
	SX3->(dbSkip())
EndDo

DbSelectArea(cAlias)
DbSetOrder(2)

//�������������Ŀ
//�Carrega aCols�
//���������������
If (cAlias)->(RecCount()) > 0
   	(cAlias)->(DbGoTop()) 
   	While !(cAlias)->(Eof()) 
   		aAdd(aCols, Array(Len(aHeader)+1))
		For nI := 3 To Len(aHeader)
			If ( aHeader[nI,10] !=  "V" )   		  
				aCols[Len(aCols)][nI] := FieldGet(FieldPos(aHeader[nI,2]))
	  		Else
				aCols[Len(aCols)][nI] := CriaVar(aHeader[nI,2],.T.)
	  		Endif
      	Next nI
	    //�������������������������Ŀ
		//�Iserindo a imagem UP/Down�
		//���������������������������
		aCols[Len(aCols)][1] := oUp
    	aCols[Len(aCols)][2] := oDown
	    aCols[Len(aCols)][Len(aHeader)+1] := .F.
      	(cAlias)->(dbSkip())
   	EndDo
Else
   	Help(" ", 1, "REGNOIS")
Endif                                                                     -

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
AAdd( aObjects, { 50, 50, .T., .T. } )
aInfo := { aSize[1]/2, Round(aSize[2]/1.5,0), Round(aSize[3]/1.5,0), Round(aSize[4]/1.5,0), 5, 5 } 
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM Round(aSize[7]/1.5,0),0 TO Round(aSize[6]/1.5,0),Round(aSize[5]/1.5,0) OF oMainWnd PIXEL

    oGet  := MsNewGetDados():New( aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], if(nOpc==2 .or. nOpc==5, Nil,GD_UPDATE),cLinOk, cTudoOkGet, cIniCpos, aAlter, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlg, aHeader, aCols )
 	oGet:oBrowse:bLDblClick := {|| Fa572UpD()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1,If(cTudoOk,oDlg:End(),nOpcA:=0)},{||nOpca:=0,oDlg:End()})

If nOpcA == 1
	Begin Transaction
	 	If Fa572Grg(cAlias,nOpc, lMenu)
			EvalTrigger()
			If __lSX8
				ConfirmSX8()
			Endif
		Else
		    DisarmTransaction()
		EndIf
	End Transaction
Else
	If __lSX8
		RollBackSX8()
	Endif
Endif                
If (nOpc == 3)
   nOpc := nOpcAux
EndIf
RestArea(aArea)
Return  

/*
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa572Mnt  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao na prioridade (peso) do tipo da regra de rodizio         ���
���          �                                                                     ���                                             
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � Goldfarb - Menu                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� lMenu - .T.(Funcao chamada direto do menu da MBrowse                ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Function Fa572Mnt(cAlias, nOpc , nRec, lMenu)  

Local aArea             := getArea()        // Salva a �rea atual antes de iniciar esse processo.
Local cCadastro         := STR0001          // Cadastro de Tipo de Regra de Rodizio
Local nOpcA             := 0                // Opcao escolhida no fechamento da janela
Local oDlg                                  // Janela
Local aCpoEnch  	    := NIL              // Campos da enchoice
Local aAlterEnch	    := NIL              // Campos alteraveis da echoice
Local cNotGet           := ""               // Campos excluidos da getdados
Local cTudoOk           := .T.              // Validacao do fechamento da janela
Local aAlter      	 	:= NIL              // Array de campos alteraveis da getdados
Local cLinOk    		:= "AllwaysTrue"    // Funcao executada para Validar o contexto da linha atual do aCols
Local cTudoOkGet   		:= "AllwaysTrue"    // Funcao executada para Validar o contexto geral da MsNewGetDados ( todo aCols )
Local cIniCpos  	   	:= ""
Local nFreeze      		:= 000
Local nMax         		:= 999
Local cFieldOk  		:= "AllwaysTrue"    // Funcao executada na Validacao do campo
Local cSuperDel     	:= NIL
Local cDelOk    		:= "AllwaysTrue"   	// Funcao executada para Validar a exclusao de uma linha do aCols
Local aSize             := {}              // Definicao do tamanho da janela
Local aObjects          := {}              // Definicao do tamanho da janela
Local aInfo             := {}              // Definicao do tamanho da janela
Local nI                := 0               // Auxiliar do laco
Local nOpcAux           := nOpc            // Auxiliar nOpc
Local oUp               := LoadBitmap( GetResources(), "TriUp" ) //Imagem da seta para cima
Local oDown             := LoadBitmap( GetResources(), "TriDown" )//Imagem da seta para baixo
Private oGet
Private aHeader         := {}
Private aCols           := {}

Default lMenu           := .F.

//������������������������������������Ŀ
//�Quando inclusao mudar para alteracao�
//��������������������������������������
If (nOpc == 3) 
   nOpc := 4 
   INCLUI := .F.
EndIf


aAdd( aHeader, { '', 'UP'  , '@BMP', 2, 0,,, 'C',, 'V' ,  , } )
aAdd( aHeader, { '', 'DOWN', '@BMP', 2, 0,,, 'C',, 'V' ,  , } )

//���������������Ŀ
//�Carrega aHeader�
//�����������������
DbSelectArea(cAlias)
DbSetOrder(2)
DbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == cAlias
	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. !AllTrim(SX3->X3_CAMPO) $ cNotGet
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		                SX3->X3_CAMPO        ,;
		                SX3->X3_PICTURE      ,;
		                SX3->X3_TAMANHO      ,; 
		                SX3->X3_DECIMAL      ,; 
		                SX3->X3_VALID        ,;
		                SX3->X3_USADO        ,;
		                SX3->X3_TIPO         ,;
		                SX3->X3_F3           ,;
		                SX3->X3_CONTEXT      ,;
		                SX3->X3_CBOX		 ,;   
		                SX3->X3_RELACAO      })
		           
	Endif
	SX3->(dbSkip())
EndDo

DbSelectArea(cAlias)
DbSetOrder(2)

//�������������Ŀ
//�Carrega aCols�
//���������������
If (cAlias)->(RecCount()) > 0
   	(cAlias)->(DbGoTop()) 
   	While !(cAlias)->(Eof()) 
   		aAdd(aCols, Array(Len(aHeader)+1))
		For nI := 3 To Len(aHeader)
			If ( aHeader[nI,10] !=  "V" )   		  
				aCols[Len(aCols)][nI] := FieldGet(FieldPos(aHeader[nI,2]))
	  		Else
				aCols[Len(aCols)][nI] := CriaVar(aHeader[nI,2],.T.)
	  		Endif
      	Next nI
	    //�������������������������Ŀ
		//�Iserindo a imagem UP/Down�
		//���������������������������
		aCols[Len(aCols)][1] := oUp
    	aCols[Len(aCols)][2] := oDown
	    aCols[Len(aCols)][Len(aHeader)+1] := .F.
      	(cAlias)->(dbSkip())
   	EndDo
Else
   	Help(" ", 1, "REGNOIS")
Endif                                                                     -

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
AAdd( aObjects, { 50, 50, .T., .T. } )
aInfo := { aSize[1]/2, Round(aSize[2]/1.5,0), Round(aSize[3]/1.5,0), Round(aSize[4]/1.5,0), 5, 5 } 
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM Round(aSize[7]/1.5,0),0 TO Round(aSize[6]/1.5,0),Round(aSize[5]/1.5,0) OF oMainWnd PIXEL

    oGet  := MsNewGetDados():New( aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], if(nOpc==2 .or. nOpc==5, Nil,GD_UPDATE),cLinOk, cTudoOkGet, cIniCpos, aAlter, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlg, aHeader, aCols )
 	oGet:oBrowse:bLDblClick := {|| Fa572UpD()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1,If(cTudoOk,oDlg:End(),nOpcA:=0)},{||nOpca:=0,oDlg:End()})

If nOpcA == 1
	Begin Transaction
	 	If Fa572Grg(cAlias,nOpc, lMenu)
			EvalTrigger()
			If __lSX8
				ConfirmSX8()
			Endif
		Else
		    DisarmTransaction()
		EndIf
	End Transaction
Else
	If __lSX8
		RollBackSX8()
	Endif
Endif                
If (nOpc == 3) 
   nOpc := nOpcAux
EndIf
RestArea(aArea)
Return  
          
/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa572Grg  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Gravacao da alteracao na prioridade (peso) no tipo da regra         ���
���          �                                                                     ���               
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
Static Function Fa572Grg(cAlias, nOpc,lMenu)

Local aArea              := getArea()          // Salva a �rea atual antes de iniciar esse processo.
Local lGravou            := .F.                // Auxiliar do retorno da funcao
Local nI                 := 0                  // Auxiliar do laco
Local nCodPos            := aScan(aHeader,{|x| AllTrim(x[2])=="ADI_COD"})  // Posicao do campo ADI_COD
Local nPesoPos           := aScan(aHeader,{|x| AllTrim(x[2])=="ADI_PESO"}) // Posicao do campo ADI_PESO 

//����������������������������Ŀ
//�Se for inclusao ou alteracao�
//������������������������������
If (nOpc == 3) .Or. (nOpc == 4)

	dbSelectArea(cAlias)
	DbSetOrder(1)   
	
	For nI := 1 To Len(oGet:aCols)

   		(cAlias)->(dbSeek(xFilial(cAlias) + oGet:aCols[nI,nCodPos]))

		If (cAlias)->(Found())
       		RecLock(cAlias,.F.)
	         	(cAlias)->ADI_PESO :=  oGet:aCols[nI][nPesoPos]
    	   	(cAlias)->(MsUnLock())

			//��������������������
			//�Atualizar enchoice�
			//��������������������
			If !lMenu 
				If oGet:aCols[nI][nCodPos] == M->ADI_COD
	      		     M->ADI_PESO := oGet:aCols[nI][nPesoPos]
	      		     //oEnch:EnchRefresAll() 
	      		EndIf
      		EndIf
      		lGravou := .T.
   		Endif
   		
	Next nI

EndIf
                       
RestArea(aArea)

Return( lGravou )

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa572LOk  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da linha na manutencao da prioridade                      ���
���          �                                                                     ���                                   
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
Function Fa572LOk()

Local aArea     := GetArea()      // Salva a �rea atual antes de iniciar esse processo.
Local lRetorno  := .T.            // Auxiliar do retorno da funcao 
Local nPesoPos  := aScan(aHeader,{|x| AllTrim(x[2])=="ADI_PESO"}) // Posicao do campo ADI_PESO  

//��������������Ŀ
//�Reordena aCols�
//����������������
oGet:aCols  := aSort( oGet:aCols,,, {|x,y| x[nPesoPos] < y[nPesoPos]} ) 
oGet:oBrowse:Refresh()

RestArea(aArea)
Return(lRetorno)

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa572UpD  | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Altera a prioridade (peso) do tipo de regra                         ���
���          �                                                                     ���                                     
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
Static Function Fa572UpD()

Local nPesoPos  := aScan(aHeader,{|x| AllTrim(x[2])=="ADI_PESO"}) // Posicao do campo ADI_PESO
Local nPeso     := ""    //Peso
Local nIncrem   := 0     // Incremento +1 sobe -1 desce

If oGet:oBrowse:nColPos==1 .And. oGet:nAt > 1 
	nIncrem := -1
EndIf
If oGet:oBrowse:nColPos==2 .And. oGet:nAt < Len(oGet:aCols)
	nIncrem := +1
EndIf

If nPesoPos > 0
	If nIncrem <> 0
	    nPeso :=oGet:aCols[oGet:nAt][nPesoPos]
	   	oGet:aCols[oGet:nAt][nPesoPos] := oGet:aCols[oGet:nAt + nIncrem][nPesoPos]
	    oGet:aCols[oGet:nAt+nIncrem][nPesoPos] := nPeso
	   	//��������������Ŀ
		//�Reordena aCols�
		//����������������
	  	oGet:aCols  := aSort( oGet:aCols,,, {|x,y| x[nPesoPos] < y[nPesoPos]} )
	    //��������������Ŀ
		//�Mantem posicao�
		//����������������
	    oGet:nAt := oGet:nAt+nIncrem
	  	
	  	oGet:oBrowse:Refresh()
	EndIf
EndIf
	
Return
 
//-------------------------------------------------------------------
/*{Protheus.doc} FT572SX2F3 
F3 da entidades do rodizio.
@since   16/05/2017
@version P12
*/
//-------------------------------------------------------------------      
Function FT572SX2F3()

Local aAreaSX2	:= SX2->( GetArea() )
Local cFilter  	:= "SX2->X2_CHAVE == 'ACH' .Or. SX2->X2_CHAVE == 'SUS'"
Local lRet			:= .T.

DBSelectArea("SX2")
SX2->( DBSetFilter({|| &cFilter  }, cFilter ))

lRet := Conpad1( Nil,Nil,Nil,"SX2PAD")

If lRet 
	cSX2F3 := FwX2Chave()
EndIf

SX2->( DBClearFilter() )

RestArea( aAreaSX2 )
Return( lRet )

//-------------------------------------------------------------------
/*{Protheus.doc} FT572GSX2 
Retorna o codigo da entidade.
@since   16/05/2017
@version P12
*/
//-------------------------------------------------------------------  
Function FT572GSX2()
Return( cSX2F3 )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT572VlCpo�Autor  �Vendas CRM          � Data �  14/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao do campo selecionado para cadastro da regra       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA572                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FT572VlCpo()

Local aArea		:= GetArea()
Local aAreaSX3	:= {}
Local lRet		:= .F.
Local cAlias	:= M->ADI_ALIAS

If Empty(M->ADI_CAMPO)
	lRet := .T.	
Else	
	aAreaSX3	:= SX3->(GetArea())	
	DbSelectArea("SX3")
	DbSetOrder(2)
	lRet := SX3->(DbSeek(M->ADI_CAMPO)) .AND. (SX3->X3_ARQUIVO == cAlias)
	RestArea(aAreaSX3)		
EndIf

RestArea(aArea)

Return lRet


/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � FA572F3   | Autor � Vendas CRM                    � Data �21.01.2008���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna o conteudo escolhido na consulta                            ���
���          �                                                                     ���                                  
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
Function FA572F3() 

Local oMdl   :=FWModelActive()
Local oMdlF3 := oMdl:GetModel('ADIMASTER')
Local aCpos     := {}       //Array com os dados
Local aRet      := {}       //Array do retorno da opcao selecionada
Local oDlg                  //Objeto Janela
Local oLbx                  //Objeto List box
Local cTitulo   := STR0009  //Titulo da janela --Campos do sitema
Local cNoCpos   := ""   
Local cDescr    := STR0012
Local lRet 		:= .F.
	    
//���������������������Ŀ
//�Procurar campo no SX3�
//�����������������������
DbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek(M->ADI_ALIAS))

//���������������������������������������������������Ŀ
//�Carrega o vetor com os campos da tabela selecionada�
//�����������������������������������������������������

While !SX3->(Eof()) .And. X3_ARQUIVO == M->ADI_ALIAS
   
   If X3USO(SX3->X3_USADO) .AND. SX3->X3_CONTEXT <> "V" .AND. !AllTrim(SX3->X3_CAMPO) $ cNoCpos
	   aAdd( aCpos, { SX3->X3_CAMPO, SX3->&cDescr } )
   EndIf
   
   SX3->(DbSkip())
   
Enddo

If Len( aCpos ) > 0

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0010, STR0011  SIZE 230,95 OF oDlg PIXEL	
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
	   oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
	
   	M->ADI_CAMPO  := iIF(Len(aRet) > 0, aRet[1],"")
	M->ADI_CPODES := iIF(Len(aRet) > 0, aRet[2],"") 
	 
	If Len(aRet) > 0  
		lRet := .T.
		SX3->(dbSetOrder(2))
		SX3->(dbSeek(aRet[1]))
	EndIf
	
EndIf	

Return lRet
 
/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � FT572VldEx| Autor � Vendas CRM                    � Data �15.04.2013���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � FAZ VALIDA��O DE EXCLUS�O                                           ���
���          �                                                                     ���                                  
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
Function FT572VldEx(oMdl)
Local lReturn		:= .T.  
Local oMdlMaster	:= oMdl:GetModel('ADIMASTER')
Local cCodigo		:= oMdlMaster:GETVALUE('ADI_COD')
Local cAliasADH		:= ""
Local cQuery		:= ""

#IFDEF TOP
	cAliasADH := GetNextAlias()
	cQuery    := ""

	cQuery += " SELECT COUNT(*) TOT_COD "
	cQuery += "   FROM " + RetSqlName( "ADH" )
	cQuery += "  WHERE ADH_FILIAL='" + xFilial( "ADH" ) + "'"
	cQuery += "    AND ADH_TIPREG = '" + cCodigo + "'"
	cQuery += "    AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasADH,.F.,.T. )

	If (cAliasADH)->TOT_COD > 0			  
		Help( , , 'Help', , STR0017, 1,0)
		lReturn := .F.
	Endif
	(cAliasADH)->(DbCloseArea()) 
#ENDIF	

Return lReturn
/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    � FA572TOK| Autor � Vendas CRM                    � Data �16/08/2017  ���
����������������������������������������������������������������������������������Ĵ��
���Descri�ao � Faz valida��o de TUDOOK                                             ���
���          �                                                                     ���                                  
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
Function FA572TOK(oModel)
Local lRet		:= .T.
Local oModelADI := oModel:GetModel("ADIMASTER")
Local cPeso		:= oModelADI:GetValue("ADI_PESO")
Local cCod		:= oModelADI:GetValue("ADI_COD")
Local lInclui	:= oModelADI:GetOperation() == MODEL_OPERATION_INSERT 
Local lAltera	:= oModelADI:GetOperation() == MODEL_OPERATION_UPDATE
ADI->(DbSetOrder(2)) 
If lInclui .Or. lAltera
	If (Empty(cPeso) .Or. ADI->(dbSeek(xFilial("ADI") + StrZero(Val(cPeso),TamSx3("ADI_PESO")[1])))) .And.  cCod <> ADI->ADI_COD
		Help(" ", 1, "REGNOIS",,STR0018,2)
		lRet := .F.
	ElseIf !Isnumeric(cPeso)
		Help(" ", 1, "REGNOIS",,STR0019,2)
		lRet := .F.
	EndIf
EndIf

Return lRet
