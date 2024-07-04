#INCLUDE "FATA140.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "dbtree.ch"  
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MenuDef   � Autor � Vendas & CRM          � Data �11.04.12  ���    
�������������������������������������������������������������������������Ĵ��
���Descri��o �Menu                                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina	:= {}
Local aRet		:= {}
Local nX 		:= 1

aRotina := FwMVCMenu('FATA140')

Aadd(aRotina,{STR0001,"FT140Estru",0 , 4}) 	//"Estrutura"

aRotina:= CRMXINCROT("ACU",aRotina)

If ExistBlock("FT140BRW")
	aRet := ExecBlock("FT140BRW",.F.,.F.)
	If ValType(aRet) == "A"
		For nX := 1 to Len(aRet)
			AAdd(aRotina,aClone(aRet[nX]))
		Next nX
	EndIf
EndIf
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ViewDef   � Autor � Vendas & CRM          � Data �11.04.12  ���    
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao da View                                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �oView                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
Local oModel   := FWLoadModel( 'FATA140' )			// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruACU := FWFormStruct( 2, 'ACU' )			// Cria as estruturas a serem usadas na View
Local oView											// Interface de visualiza��o constru�da
Local lView	   := !IsInCallStack('FT140Tree')		// Se estiver na tela de estrutura n�o permite manipular o campo ACU_CODPAI

oView := FWFormView():New()							// Cria o objeto de View
oView:SetContinuousForm() 							// Seta formulario continuo 
oView:SetModel( oModel )							// Define qual Modelo de dados ser� utilizado				
oView:AddField( 'VIEW_ACU', oStruACU, 'ACUMASTER') // Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)

oStruACU:SetProperty('ACU_CODPAI', MVC_VIEW_CANCHANGE,lView)

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )			

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_ACU', 'SUPERIOR' )
			
Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ModelDef  � Autor � Vendas & CRM          � Data �11.04.12  ���    
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao do Model                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �oModel                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel 	:= Nil	
Local oStruACU	:= FWFormStruct( 1, 'ACU' )
Local cCodWhen	:= ""
Local cBlQlWhen	:= ""

cCodWhen := AllTrim( GetSX3Cache('ACU_COD', 'X3_WHEN') )
cBlQlWhen := AllTrim( GetSX3Cache('ACU_MSBLQL', 'X3_WHEN') )

cCodWhen := "!IsInCallStack('FT140Tree')" + IIf(Empty( cCodWhen ), "", " .And. ") + cCodWhen
cBlQlWhen := "!IsInCallStack('FT140Tree')" + IIf(Empty( cBlQlWhen ), "", " .And. ") + cBlQlWhen

oStruACU:SetProperty('ACU_COD'		,MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, cCodWhen ))
oStruACU:SetProperty('ACU_MSBLQL'	,MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, cBlQlWhen ))

oModel := MPFormModel():New( 'FATA140', /*pre*/,{|oMdl|Ft140Cnf(oMdl:GetOperation(), oMdl)},{|oMdl| Ft140Comm(oMdl) })

oModel:AddFields( 'ACUMASTER', /*cOwner*/, oStruACU ,/*bPreValid*/ )

oModel:SetVldActivate({|oMdl| Ft140VlAct(oMdl) })
oModel:SetDescription( STR0002 ) //"Categoria de Produtos"

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA140  � Autor � Eduardo Perusso Riera � Data �06.09.05  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Categorias de Produtos                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FATA140(nOpcAuto,aAuto)

Default nOpcAuto := 0
Default aAuto 	 := {} 

If !Empty(aAuto)
	FWMVCRotAuto(ModelDef(),"ACU",nOpcAuto,{{"ACUMASTER",aAuto}})
Else
	DEFINE FWMBROWSE oMBrowse ALIAS "ACU" DESCRIPTION STR0002 //"Categoria de Produtos"
	oMBrowse:SetAttach(.T.)
	oMBrowse:SetTotalDefault("ACU_COD","COUNT",) // "Total de Registros"
		
	If nModulo <> 73
		oMBrowse:SetOpenChart( .F. )
	EndIf
		
	ACTIVATE FWMBROWSE oMBrowse
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft140VlAct� Autor � Vendas & CRM          � Data �11.04.12  ���    
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao de Ativacao do Model                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Model                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft140VlAct(oMdl)
Local lRet := .T.

If oMdl:GetOperation() == MODEL_OPERATION_DELETE
	lRet := Ft140VlDel()
EndIf

Return lRet  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft140Comm � Autor � Vendas & CRM          � Data �11.04.12  ���    
�������������������������������������������������������������������������Ĵ��
���Descri��o �Commit do Model                                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Model                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft140Comm(oMdl)

Local lRet 			:= .T.
Local lECommerce 	:= SuperGetMV("MV_LJECOMM",,.F.)
Local cCodFilho		:= oMdl:GetValue("ACUMASTER", "ACU_COD")
Local cCodPai		:= oMdl:GetValue("ACUMASTER", "ACU_CODPAI")		
Local lIntPOS 		:= (SuperGetMV("MV_LJSYNT",,"0") == "1")
Local lLj904Ft14	:= ExistFunc("Lj904Ft140")

If isInCallStack("FT140Tree") .AND. (oMdl:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdl:GetOperation() == MODEL_OPERATION_UPDATE)
	oMdl:SetValue("ACUMASTER","ACU_CODPAI",cCodigo)
EndIf

If lIntPOS .AND. oMdl:GetOperation() == MODEL_OPERATION_UPDATE .And. ACU->(FieldPos("ACU_POSFLG") > 0) .And. ACU->(FieldPos("ACU_ECDTEX") > 0) .And. (ACU->ACU_POSFLG == "1")
   oMdl:GetModel("ACUMASTER"):SetValue("ACU_ECDTEX","")
Endif  

If lECommerce .AND. oMdl:GetOperation() == MODEL_OPERATION_UPDATE .AND. (ACU->(FieldPos("ACU_ECDTEX")) > 0) 
	   oMdl:GetModel("ACUMASTER"):SetValue("ACU_ECDTEX","")
Endif

If ( oMdl:GetOperation() == MODEL_OPERATION_INSERT .And. cCodFilho == cCodPai )

	cMay := "ACU"+ Alltrim(xFilial("ACU"))
	ACU->(dbSetOrder(1))
	While ( ACU->( DbSeek(xFilial("ACU")+cCodFilho) ) .or. !MayIUseCode(cMay+cCodPai) )
		cCodFilho := Soma1(cCodFilho,Len(cCodFilho))
	EndDo
	oMdl:LoadValue("ACUMASTER", "ACU_COD", cCodFilho)

ElseIf ( oMdl:GetOperation() == MODEL_OPERATION_UPDATE .And. cCodFilho == cCodPai )
	
	Help(" ",1,"Ft140Comm", , STR0025,1,0)  // "Os c�digos da Categoria e Cat.Superior n�o podem ser iguais." 
	Return (.T.)

EndIf

If lRet .AND. lLj904Ft14
	lRet := Lj904Ft140(lECommerce, @oMdl)	
EndIf

lRet := lRet .AND. FwFormCommit(oMdl) 

If lRet .AND. ExistBlock("FT140GRV")
	ExecBlock("FT140GRV",.F.,.F.)
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft140VlAlt� Autor � Antonio C Ferreira    � Data �22.02.13  ���    
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Tratamento da Inclusao/Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft140VlAlt()
                   
//Limpa variavel para exportacao de dados do ecomerce.

If  ACU->( FieldPos("ACU_ECDTEX") > 0 )
	M->ACU_ECDTEX := ""
EndIf

Return .T.	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ft140VlDel� Autor � Eduardo Perusso Riera � Data �06.09.05  ���    
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Tratamento da Exclusao                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft140VlDel()
Local aArea    	:= GetArea()
Local aAreaACV 	:= ACV->(GetArea())
Local lExclui 	:= .T.   
Local lFt140Exc	:= ExistBlock("FT140EXC")//Ponto de entrada para Validar a Exclus�o
Local cQuery	:= ""
Local nRecno	:= 0

//�������������������������������������������������������������������Ŀ
//� Verifica se a categoria foi utilizada na tabela de Categ.p/Produto�
//���������������������������������������������������������������������
ACV->(dbSetOrder(1))
If ACV->(MsSeek(xFilial("ACV")+ACU->ACU_COD))
	Help(,,"FT140VLDEL", , STR0026,1,0) //'Categoria de Produto est� vinculada � um Grupo de Produto ou Produto'
	lExclui := .F.
EndIf

nRecno := ACU->(Recno())
If lExclui
	ACU->(dbSetOrder(2))
	If ACU->(MsSeek(xFilial("ACU")+ACU->ACU_COD))
		Help(,,"FT140VLDE2", ,STR0027,1,0) //'A Categoria n�o pode ser excluida pois � superior na hierarquia'
		lExclui := .F.
	EndIf
EndIf  

//�����������������������������������������������������������������������������������������������������
//�//Reposiciona no registro atual, pois poder� ter sido disposicionado na valida��o acima(FT140VLDE2)�
//�����������������������������������������������������������������������������������������������������
ACU->(dbSetOrder(1))
ACU->(dbGoTo(nRecno))

//�������������������������������������������������������������������Ŀ
//� Verifica se a categoria foi utilizada em Metas de Vendas          �
//���������������������������������������������������������������������

If lExclui
	cQuery := "SELECT COUNT(*) RECSCT FROM "
	cQuery += RetSqlName("SCT") + " SCT "
	cQuery += " WHERE "                                    
	cQuery += "CT_FILIAL = '"+xFilial("SCT")+"' AND "
	cQuery += "CT_CATEGO = '" + ACU->ACU_COD + "' AND "
	cQuery += "SCT.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSCT",.F.,.T.)

	If TRBSCT->RECSCT > 0
		lExclui := .F.  
	   Help(" ",1,STR0021,,STR0022,1,0)
	Endif 
	TRBSCT->(dbCloseArea())							
EndIf     

If lExclui
	cQuery := "SELECT COUNT(*) RECSAY FROM "
	cQuery += RetSqlName("SAY") + " SAY "
	cQuery += " WHERE "                                    
	cQuery += "AY_FILIAL = '"+xFilial("SAY")+"' AND "
	cQuery += "AY_CATEGO = '" + ACU->ACU_COD + "' AND "
	cQuery += "SAY.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSAY",.F.,.T.)

	If TRBSAY->RECSAY > 0
		lExclui := .F.  
		Help(" ",1,STR0021,,STR0023 ,1,0)
	Endif
	TRBSAY->(dbCloseArea())							
EndIf     
  
//������������������������������������������������Ŀ
//�Ponto de entrada a ser executado na Exclus�o    �
//�Valida��o extra para permitir ou n�o a exclus�o �
//��������������������������������������������������
If lExclui .and. lFt140Exc             
	RestArea(aArea)  //Restaura Area ACU antes de executar o execblock
	lExclui:=ExecBlock("FT140EXC",.F.,.F.)
EndIf
RestArea(aAreaACV)
RestArea(aArea)
Return(lExclui)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft140Estru� Autor �Eduardo Riera          � Data �06.09.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Estrutura da categoria de produtos.                          ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias do arquivo a ser manipulado                     ���
���          � ExpN1: Registro a ser manipulado                             ���
���          � ExpN2: Opcao                                                 ���
���          � ExpA1: Array com campos manipulados                          ���
���          � ExpL1: Indica se a chamada ocorreu da rotina de previsao     ���
���          � ExpD1: Data inicial para apresentacao das previsoes de venda ���
���          � ExpD2: Data final ara apresentacao das previsoes de venda    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FT140Estru(cAlias,nReg,nOpc,aCpo,lPrevVenda,dDataIni,dDatafim)
Local aArea     	:= GetArea()
Local aSize     	:= MsAdvSize(.T.)
Local aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Local aObjects  	:= {{100,100,.T.,.T.}}
Local aObjects2 	:= {{45,100,.T.,.T.},{55,100,.T.,.T.,.T.}}
Local aPosObj   	:= {}
Local cCadastro 	:= STR0002 //"Categoria de produtos"
Local oTree,oDlg
Local oBotao1,oBotao2,oBotao3,oBotao4
Local oPanel
Local aHelpP		:={"Indica se deve mostrar na estrutura os ","produtos relacionados a cada uma das" ,"categorias."}
Local aHelpS		:={"Indica si debe mostrar en la estructura","los productos relacionados a cada una","de las categor�as."}
Local aHelpE		:={"Determine if products in the structure" ,"related to each one of the categories","must be displayed."}                         
LOCAL aButtons		:= {}
LOCAL aTotais		:={}
LOCAL aDados 		:={{""}}
LOCAL aDadosProd	:={}
Local aRetCopy  	:= If(Type("aRotina")=="A",ACLONE(aRotina),{})

PRIVATE cCodVazio   :=CriaVar("ACU_COD",.F.)
PRIVATE cProdVazio  :=CriaVar("ACV_CODPRO",.F.)
PRIVATE lExisteGrupo:=ACV->(FieldPos("ACV_GRUPO")) > 0
PRIVATE cGrupoVazio :=If(lExisteGrupo,Criavar("ACV_GRUPO",.F.),"")
PRIVATE cRecnoVazio :=StrZero(0,10)
PRIVATE nPosIni:=Len(ACU->ACU_COD)+Len(ACV->ACV_CODPRO)+Len(cGrupoVazio)+2

DEFAULT lPrevVenda := .F.
DEFAULT dDataIni   := dDataBase
DEFAULT dDataFim   := dDataBase

If !lPrevVenda
	// Inclui botoes para manipulacao
	AADD(aButtons,{'bmpincluir',{|| FT140Tree(1,oTree)},OemToAnsi(STR0004)})
	AADD(aButtons,{'NOTE',{|| FT140Tree(2,oTree)},OemToAnsi(STR0005)})
	AADD(aButtons,{'EXCLUIR',{|| FT140Tree(3,oTree)},OemToAnsi(STR0006)})                                       
	PutSX1Help("P.FAT14001.",aHelpP,aHelpE,aHelpS)	
	//������������������������������������������������������������������������Ŀ
	//�Mostra a pergunta sobre os produtos                                     �
	//��������������������������������������������������������������������������
	Pergunte("FAT140",.T.)
Else
	// Inclui botoes 
	// Inclusao de previsoes
	AADD(aButtons,{'NOTE',{|| Ft140IncPV(oTree,dDataIni,dDatafim,aDadosProd)},OemToAnsi(STR0012),OemToAnsi(STR0013)})
	// Refresh no tree
	AADD(aButtons,{'reload',{|| Fat140Trfs(oDlg,oTree,aTotais,aDadosProd,dDataIni,dDataFim) },"Refresh","Refresh"})
	cCadastro+=OemToAnsi(STR0003)
EndIf

//������������������������������������������������������������������������Ŀ
//�Montagem da Interface                                                   �
//��������������������������������������������������������������������������
aPosObj   := MsObjSize( aInfo,If(lPrevVenda,aObjects2,aObjects),.T.,If(lPrevVenda,.T.,NIL))
// Define arotina fixo
aRotina   := { { "" , "        ", 0 , 2}}
// Caso a chamada ocorra da previsao de vendas monta variaveis de memoria
If lPrevVenda
	RegtoMemory("SB1",.F.)
	RegtoMemory("SC4",.F.)
EndIf
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	// Cria o Tree e preenche as informacoes
	oTree := DbTree():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],oDlg,,,.T.)
	FT140MTree(oTree,cCodVazio,NIL,NIL,NIL,If(lPrevVenda,.T.,mv_par01==1),lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)
	// Caso a chamada ocorra da previsao de vendas altera caracteristica da tela apresentando informacoes sobre produtos e previsoes
	If lPrevVenda
		oPanel := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlg,oDlg:oFont,.T.,.T.,,,aPosObj[2,3],aPosObj[2,4],.T.,.T. )
		oTree:bChange := {|| (If(Val(Substr(oTree:GetCargo(),nPosIni,10))>0,If(Substr(oTree:GetCargo(),1,1) == "2",(SB1->(MsGoto(Val(Substr(oTree:GetCargo(),nPosIni,10)))),RegtoMemory("SB1",.F.)),(SC4->(MsGoto(Val(Substr(oTree:GetCargo(),nPosIni,10)))),RegtoMemory("SC4",.F.))),),FT140RTree(@oTree,@oPanel,{0,0,aPosObj[2,4],aPosObj[2,3]},aTotais)) }	
	EndIf
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
Release Object oTree
RestArea(aArea)
// Restaura area original
aRotina:=AClone(aRetCopy)
Return(.T.)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft140Tree � Autor �Eduardo Riera          � Data �06.09.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Estrutura das categorias                                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: Opcao selecionada                                     ���
���          �        [1] Inclusao                                          ���
���          �        [2] Alteracao                                         ���
���          �        [3] Exclusao                                          ���
���          � ExpO2: Objeto Tree                                           ���
���������������������������������������������������������������������������Ĵ��
���Uso       � CRM                                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FT140Tree(nOpcao,oTree)
Local aArea  	  := GetArea()
Local nOpcA 	  := 0
Local cCargo      := oTree:GetCargo()
Local cTpTree     := Substr(cCargo,1,1)
Local aRetCopy    := If(Type("aRotina")=="A",Aclone(aRotina),{})
Local cFilialACU  := xFilial("ACU")

PRIVATE cCodigo := Substr(cCargo,2,Len(ACU->ACU_COD))
PRIVATE cOkFunc := Nil
PRIVATE cDelFunc:= Nil
PRIVATE aRotina := {}

//������������������������������������������������������������������������Ŀ
//�Caso o tree seja de categoria                                           �
//��������������������������������������������������������������������������
If cTpTree == "1"
	//������������������������������������������������������������������������Ŀ
	//�Verifica a Operacao selecionada                                         �
	//��������������������������������������������������������������������������
	Do Case
		Case nOpcao == 1			
			nOpcA := FWExecView("",'FATA140', MODEL_OPERATION_INSERT,, { || .T. } )
			If nOpcA == 0
				nOpca := 1
			Else
				nOpca := 2
			EndIf
			If nOpcA == 1
				oTree:TreeSeek("1"+cCodigo+cProdVazio)
				oTree:addItem(ACU->ACU_DESC,"1"+ACU->ACU_COD+cProdVazio+cGrupoVazio+cRecnoVazio,"BPMSEDT3","BPMSEDT3",,,2)
			EndIf
		Case nOpcao == 2
			//������������������������������������������������������������������������Ŀ
			//�Posiciona no item selecionado                                           �
			//��������������������������������������������������������������������������
			dbSelectArea("ACU")
			dbSetOrder(1)
			If MsSeek(cFilialACU+cCodigo)	
				cCodigo := ACU->ACU_CODPAI
				nOpcA := FWExecView("",'FATA140', MODEL_OPERATION_UPDATE,, { || .T. } )
				If nOpcA == 0
					nOpca := 1
				Else
					nOpca := 2
				EndIf					
				If nOpcA == 1
					oTree:ChangePrompt(ACU->ACU_DESC,cCargo)		
				EndIf
			EndIf
		Case nOpcao == 3
			//������������������������������������������������������������������������Ŀ
			//�Verifica se este item pode ser deletado                                 �
			//��������������������������������������������������������������������������
			dbSelectArea("ACV")
			dbSetOrder(1)
			dbSelectArea("ACU")
			dbSetOrder(2)
			If !MsSeek(cFilialACU+cCodigo) .And. !(ACV->(MsSeek(xFilial("ACV")+cCodigo)))
				//������������������������������������������������������������������������Ŀ
				//�Posiciona no item selecionado                                           �
				//��������������������������������������������������������������������������
				dbSelectArea("ACU")
				dbSetOrder(1)
				If MsSeek(cFilialACU+cCodigo)
					nOpcA := FWExecView("",'FATA140', MODEL_OPERATION_DELETE,, { || .T. } )
					If nOpcA == 0
						nOpca := 2
					Else
						nOpca := 1
					EndIf
				EndIf			
				If nOpcA == 2
					dbSelectArea("ACU")
					dbSetOrder(1)
					If !MsSeek(cFilialACU+cCodigo)
						oTree:DelItem()
					EndIf
				EndIf
			Else	
				Help(" ",1,"NODELETA", , STR0028,1,0 ) //'Este registro n�o pode ser exclu�do pois possui categorias vinculadas'
			EndIf		
	EndCase
Else
	Help(" ",1,"OPERACINVA", , STR0029,1,0) // 'Selecione um n� referente � uma Categoria'
EndIf
RestArea(aArea)    

aRotina:=AClone(aRetCopy)
RETURN

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft140When � Autor �Antonio C Ferreira     � Data �28.02.2013  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Permite ou nao a edicao do campo                             ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � .T. Editar / .F. Nao editar                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Nome do Campo                                         ���
���������������������������������������������������������������������������Ĵ��
���Uso       � CRM                                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FT140When(cCampo)

Local lOk := .T.  //Controla se edita ou nao o campo da Categoria Pai.
//��������������������������������Ŀ
//�Tratamento para e-Commerce      �
//����������������������������������
Local lECommerce := SuperGetMV("MV_LJECOMM",,.F.)

Default cCampo := ""

If  lECommerce
	If  (cCampo == "ACU_CODPAI") .And. ALTERA .And. (M->ACU_ECFLAG=="1") .And. !( Empty(M->ACU_CODPAI) )
        lOk := .F. //Para nao editar Categoria Pai ja gravado na alteracao da Categoria do e-commerce.
    EndIf    
EndIf

Return lOk

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft140Grv  � Autor �Eduardo Riera          � Data �06.09.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao complementar da categoria de produtos               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       � CRM                                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FT140Grv()
ACU->ACU_CODPAI := cCodigo
Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft140MTree� Autor �Rodrigo de A Sartorio  � Data �03.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega informacoes do tree                                  ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto tree                                           ���
���          � ExpC1: Codigo da categoria                                   ���
���          � ExpL1: Flag indicando se registro ja esta posicionado        ���
���          � ExpC2: Texto para inclusao no tree                           ���
���          � ExpC3: Codigo para inclusao no cargo do tree                 ���
���          � ExpL2: Flag indicando se apresenta produtos relacionados     ���
���          � ExpL3: Flag indicando se chamada veio da previsao de vendas  ���
���          � ExpA1: Array com os totais por categoria                     ���
���          � ExpD1: Data inicial para considerar as previsoes de venda    ���
���          � ExpD2: Data final para considerar as previsoes de venda      ���
���          � ExpA2: Array com os dados dos produtos                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FT140MTree(oTree,cCodPai,lSeek1,cTexto,cCodCargo,lExplProd,lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)
Local nRec		 := 0
Local aArea		 := GetArea()
Local aDadosRet	 := {}
Local nx		 := 0
Local lCpBloq	 := (ACU->(FieldPos("ACU_MSBLQL")) > 0)
Local cFilialACU := xFilial("ACU")

DEFAULT cTexto    := Space(130)
DEFAULT cCodCargo := ""
DEFAULT lExplProd := .F.
DEFAULT lSeek1    := .F.

dbSelectArea("ACV")
dbSetOrder(1)

dbSelectArea("ACU")
dbSetOrder(2)

//1 FILIAL+COD
//2 FILIAL+CODPAI
//������������������������������������������������������Ŀ
//�Procura por uma categoria nao bloqueada (campo MSBLQL)�
//��������������������������������������������������������
If !lSeek1

	lSeek1:=MsSeek(cFilialACU+cCodPai) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))

	If !lSeek1 .AND. Found()
		While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == cFilialACU .AND. ACU->ACU_CODPAI == cCodPai
			ACU->(DbSkip())
			lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
		End
	EndIf

EndIf

If lSeek1
	If !Empty(cCodPai) .And. !Empty(cTexto) .And. !Empty(cCodCargo)
		oTree:AddTree(cTexto,.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)			
	Else
		oTree:AddTree(STR0001+Space(Len(ACU->ACU_DESC)+130),.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodVazio+cProdVazio+cGrupoVazio+cRecnoVazio)
	EndIf
	// Enquanto esta regiao for a regiao pai
	While !Eof() .And. ACU->ACU_FILIAL+ACU->ACU_CODPAI == cFilialACU+cCodPai
		//Salta categorias bloqueadas
		If (lCpBloq  .AND. ACU->ACU_MSBLQL == '1')
			DbSkip()
			Loop
		End
		cCodCargo:=ACU_COD
		nRec:=Recno()
		cTexto:=ACU->ACU_DESC     
		
		//������������������������������������������������������Ŀ
		//�Procura por uma categoria nao bloqueada (campo MSBLQL)�
		//��������������������������������������������������������
		lSeek1:=MSSeek(cFilialACU+cCodCargo) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))
		
		If !lSeek1 .AND. Found()
			While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == cFilialACU .AND. ACU->ACU_CODPAI == cCodCargo
				ACU->(DbSkip())
				lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
			End
		EndIf
		
		If !lSeek1
			// Inclui todos os produtos relacionados 
			If lExplProd .And. ACV->(MsSeek(xFilial("ACV")+cCodCargo))
				oTree:AddTree(cTexto,.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)						
				aDadosRet:=Fata140Prd(oTree,cCodCargo,lPrevVenda,aTotais,dDataIni,dDataFim)					
				For nx:=1 to Len(aDadosRet)
					AADD(aDadosProd,ACLONE(aDadosRet[nx]))				
				Next nx
				oTree:EndTree()				
			Else
				oTree:AddTreeItem(cTexto,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)
			EndIf
		Else
			FT140MTree(oTree,ACU_CODPAI,lSeek1,cTexto,cCodCargo,lExplProd,lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)
		EndIf
		dbGoto(nRec)
		dbSkip()
	End
	// Inclui todos os produtos relacionados 
	If lExplProd
		aDadosRet:=Fata140Prd(oTree,cCodPai,lPrevVenda,aTotais,dDataIni,dDataFim)		
		For nx:=1 to Len(aDadosRet)
			AADD(aDadosProd,ACLONE(aDadosRet[nx]))				
		Next nx
	EndIf
	oTree:EndTree()	
EndIf
// Sorteia array com resultados por grupo
aSort(aDadosProd,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
RestArea(aArea)
RETURN

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Fata140Prd� Autor �Rodrigo de A Sartorio  � Data �01.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega informacoes da amarracao produto X categoria         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ExpA2: Array com as informacoes de produto X categoria       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto tree                                           ���
���          � ExpC1: Codigo da categoria                                   ���
���          � ExpL1: Flag indicando se a chamada veio da previsao de venda ���
���          � ExpA1: Array com os totais por previsao de venda             ���
���          � ExpD1: Data inicial para considerar as previsoes de venda    ���
���          � ExpD2: Data final para considerar as previsoes de venda      ���
���          � ExpL2: Flag indicando se mostra somente as informacoes dos   ���
���          �        produto associados e nao monta o tree                 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Fata140Prd(oTree,cCod,lPrevVenda,aTotais,dDataIni,dDataFim,lInfo)
Local aArea       := GetArea()
Local cGrupo      := If(lExisteGrupo,RetTitle("ACV_GRUPO"),"")
Local cProduto    := RetTitle("ACV_CODPRO")
Local cTextoTotal := ""
Local cRecno      := cRecnoVazio
Local aRetorno    := {}
Local i           := 0
Local j           := 0
Local aColsGrd    := {}
Local cFilialSB1  := ''
Local cFilialACV  := xFilial("ACV")
Default lInfo := .F.

dbSelectArea("ACV")
dbSetOrder(1)
If MsSeek(cFilialACV+cCod)
	cFilialSB1  := xFilial("SB1")
	While !Eof() .And. cFilialACV+cCod == ACV->ACV_FILIAL+ACV->ACV_CATEGO
		aColsGrd:={}
		cRecno:=cRecnoVazio
		If lExisteGrupo .And. !Empty(ACV->ACV_GRUPO)
			cTextoTotal:=cGrupo+ACV->ACV_GRUPO
		ElseIf !Empty(ACV->ACV_CODPRO)
			cTextoTotal:=cProduto+ACV->ACV_CODPRO
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(cFilialSB1+ACV->ACV_CODPRO))
				cRecno:=StrZero(SB1->(Recno()),10)
				cTextoTotal:=(Alltrim(cProduto))+" - "+(Alltrim(ACV->ACV_CODPRO))+" - "+SB1->B1_DESC				
			EndIf
		ElseIf !Empty(ACV->ACV_REFGRD)
			aColsGrd:=Ft140Grade(ACV->ACV_REFGRD)
		EndIf
		
		If len(aColsGrd)>0
			If !lInfo
				For i:=1 to len(aColsGrd)  
				cTextoTotal:=cProduto + Acolsgrd[i,1]
					If lPrevVenda .And. Fat140PV(oTree,aColsGrd[I,1],ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACv->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,""),.T.)
						oTree:AddTree(cTextoTotal,.T.,,,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,"")+aColsGrd[I,2])
						// Inclui as previsoes de venda ja cadastradas no periodo selecionado
						Fat140PV(oTree,aColsGrd[I,1],ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACV->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,""),.F.)
						oTree:EndTree()
					Else
						oTree:AddTreeItem(cTextoTotal,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+PADR(AcolsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,"")+aColsGrd[I,2])
					EndIf
				Next
			EndIf
			// Array que retorna informacoes dos produtos associados
			For j:=1 to len(aColsGrd)
				AADD(aRetorno,{ACV->ACV_CATEGO,acolsGrd[J,1],ACV->ACV_GRUPO})
			Next
		Else
			If !lInfo
				If lPrevVenda .And. Fat140PV(oTree,ACV->ACV_CODPRO,ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACv->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,""),.T.)
					oTree:AddTree(cTextoTotal,.T.,,,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,"")+cRecno)
					// Inclui as previsoes de venda ja cadastradas no periodo selecionado
					Fat140PV(oTree,ACV->ACV_CODPRO,ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,""),.F.)
					oTree:EndTree()
				Else
					oTree:AddTreeItem(cTextoTotal,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,"")+cRecno)
				EndIf
				
			EndIf
			// Array que retorna informacoes dos produtos associados
			AADD(aRetorno,{ACV->ACV_CATEGO,ACV->ACV_CODPRO,ACV->ACV_GRUPO})
			
		EndIf
		dbSkip()
	End
EndIf
RestArea(aArea)
RETURN aRetorno

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft140RTree� Autor �Rodrigo de A Sartorio  � Data �05.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua refresh no painel de acordo com posicao no tree       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto tree                                           ���
���          � ExpO2: Objeto painel                                         ���
���          � ExpA1: Array com posicao                                     ���
���          � ExpA2: Array com totais                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FT140RTree(oTree,oPanel,aPos,aTotais)
Local cCargo     := oTree:GetCargo()
Local aDados     := {}
Local aArea      := GetArea()
Local cGrupo     := Substr(cCargo,2,Len(ACU->ACU_COD))
Local nRec       := Val(Substr(cCargo,Len(ACU->ACU_COD)+Len(ACV->ACV_CODPRO)+Len(cGrupoVazio)+2,10))
Local nAcho      := 0
Local lOneColumn := If(aPos[4]-aPos[2]>312,.F.,.T.)
Local oScroll

If Substr(cCargo,1,1) == "1"
	nAcho:=Ascan(aTotais,{|x| x[2]== cGrupo})
	If nAcho > 0
		AADD(aDados,{aTotais[nAcho,3],""})
		AADD(aDados,{STR0007,Transform(aTotais[nAcho,4],PesqPict("SC4","C4_QUANT",14))})
		AADD(aDados,{STR0008,Transform(aTotais[nAcho,5],PesqPict("SC4","C4_QUANT",14))})
		AADD(aDados,{STR0009,Transform(aTotais[nAcho,6],PesqPict("SC4","C4_VALOR",14))})
	Else
		AADD(aDados,{STR0010})
	EndIf
	C040MatScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
	oScroll:Show()
ElseIf Substr(cCargo,1,1) == "2"
	If nRec == 0
		AADD(aDados,{STR0010})
		C040MatScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
		oScroll:Show()
	Else
		dbSelectArea("SB1")
		MsGoto(nRec)
		RegtoMemory("SB1",.F.)
		oPanel:Hide()
		MsFreeObj(@oPanel, .T.)
		MsMGet():New("SB1",nRec,1,,,,,aPos,,3,,,,oPanel,,.T.,lOneColumn)
		oPanel:Show()
	EndIf
ElseIf Substr(cCargo,1,1) == "3" .And. (nRec > 0)
	dbSelectArea("SC4")
	MsGoto(nRec)
	RegtoMemory("SC4",.F.)
	oPanel:Hide()
	MsFreeObj(@oPanel, .T.)
	MsMGet():New("SC4",nRec,1,,,,,aPos,,3,,,,oPanel,,.T.,lOneColumn)
	oPanel:Show()
EndIf
RestArea(aArea)
RETURN

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Fat140PV  � Autor �Rodrigo de A Sartorio  � Data �06.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Inclui informacoes da previsao de venda no tree              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto tree                                           ���
���          � ExpC1: Codigo da categoria                                   ���
���          � ExpA1: Array com os totais da categoria                      ���
���          � ExpD1: Data inicial para filtragem da previsao de vendas     ���
���          � ExpD2: Data final para filtragem da previsao de vendas       ���
���          � ExpC2: Texto para cargo do tree                              ���
���          � ExpL1: Somente checa a existencia de registros               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Fat140PV(oTree,cCodPro,cCodGrupo,aTotais,dDataIni,dDataFim,cCargo,lCheca)		
Local aArea     :=GetArea()

Local lPossuiReg:=.F.
Local cRecno    := cRecnoVazio
Local nAcho     := 0

#IFDEF TOP
	Local cAliasTop := ""
	Local cQuery    := ""
#ELSE
	Local cSeek     :=""
	Local cWhile    :=""
#ENDIF

Default cCodPro  :=""
Default cCodGrupo:=""
Default aTotais  :={}
Default dDataIni := dDatabase
Default dDataFim := dDatabase
Default cCargo   :=""
Default lCheca   :=.F.

#IFDEF TOP
	cAliasTop := GetNextAlias()
	cQuery := "SELECT SC4.*,SC4.R_E_C_N_O_ REGC4 FROM "+RetSqlName("SC4")+" SC4, "+RetSqlName("SB1")+" SB1 "
	cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SC4.C4_FILIAL='"+xFilial("SC4")+"' AND "
	If !Empty(cCodPro)
		cQuery+= "SB1.B1_COD   ='"+cCodPro+"' AND "					
	ElseIf !Empty(cCodGrupo)
		cQuery+= "SB1.B1_GRUPO ='"+cCodGrupo+"' AND "	
	EndIf
	cQuery += "	SC4.C4_PRODUTO = SB1.B1_COD AND "					
	cQuery += "SC4.C4_DATA >= '" + DTOS(dDataIni) + "' AND SC4.C4_DATA <= '" + DTOS(dDataFim) + "' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' AND SC4.D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	aEval(SC4->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
	dbSelectArea(cAliasTop)
	While !Eof() 
		// So esta checando se possui registros
		If lCheca
			lPossuiReg:=.T.
			Exit		
		EndIf
		nAcho:=Ascan(aTotais,{|x| x[2]== Substr(cCargo,1,Len(ACU->ACU_COD))})
		If nAcho > 0
			aTotais[nAcho,4]+=1
			aTotais[nAcho,5]+=C4_QUANT
			aTotais[nAcho,6]+=C4_VALOR
		Else
			AADD(aTotais,{"SC4",Substr(cCargo,1,Len(ACU->ACU_COD)),STR0011,1,C4_QUANT,C4_VALOR})
		EndIf
		cRecno:= StrZero((cAliasTop)->REGC4,10)
		oTree:AddTreeItem(C4_DOC+" - "+DTOC(C4_DATA),"BPMSEDT1","BPMSEDT1","3"+cCargo+cRecno)	
		dbSkip()
	End
	dbCloseArea()      
#ELSE
	dbSelectArea("SB1")
	If !Empty(cCodPro)
		dbSetOrder(1)
		dbSeek(cSeek:=xFilial()+cCodPro)
		cWhile:="B1_FILIAL+B1_COD"
	ElseIf !Empty(cCodGrupo)
		dbSetOrder(4)
		dbSeek(cSeek:=xFilial()+cCodGrupo)
		cWhile:="B1_FILIAL+B1_GRUPO"
	EndIf
	While !Eof() .And. cSeek == &(cWhile)
		// So esta checando se possui registros
		If lCheca 
			lPossuiReg:=.T.
			Exit		
		EndIf
		cCodPro:=SB1->B1_COD
		dbSelectArea("SC4")
		If Fat140Ind()
			dbSetOrder(2)
			dbSeek(xFilial()+cCodPro+DTOS(dDataIni),.T.)
			While !Eof() .And. C4_FILIAL+C4_PRODUTO == xFilial()+cCodPro .And. DTOS(C4_DATA) <= DTOS(dDataFim)
				// So esta checando se possui registros
				If lCheca
					lPossuiReg:=.T.
					Exit		
				EndIf
				nAcho:=Ascan(aTotais,{|x| x[2]== Substr(cCargo,1,Len(ACU->ACU_COD))})
				If nAcho > 0
					aTotais[nAcho,4]+=1
					aTotais[nAcho,5]+=C4_QUANT
					aTotais[nAcho,6]+=C4_VALOR
				Else
					AADD(aTotais,{"SC4",Substr(cCargo,1,Len(ACU->ACU_COD)),STR0011,1,C4_QUANT,C4_VALOR})
				EndIf
				cRecno:= StrZero(Recno(),10)
				oTree:AddTreeItem(C4_DOC+" - "+DTOC(C4_DATA),"BPMSEDT1","BPMSEDT1","3"+cCargo+cRecno)					
				dbSkip()
			End
		Else
			dbSetOrder(1)
			dbSeek(xFilial()+cCodPro)
			While !Eof() .And. C4_FILIAL+C4_PRODUTO == xFilial()+cCodPro 
				If DTOS(C4_DATA) >= DTOS(dDataIni) .And. DTOS(C4_DATA) <= DTOS(dDataFim)
					// So esta checando se possui registros
					If lCheca
						lPossuiReg:=.T.
						Exit		
					EndIf
					nAcho:=Ascan(aTotais,{|x| x[2]== Substr(cCargo,1,Len(ACU->ACU_COD))})
					If nAcho > 0
						aTotais[nAcho,4]+=1
						aTotais[nAcho,5]+=C4_QUANT
						aTotais[nAcho,6]+=C4_VALOR
					Else
						AADD(aTotais,{"SC4",Substr(cCargo,1,Len(ACU->ACU_COD)),STR0011,1,C4_QUANT,C4_VALOR})
					EndIf
					cRecno:= StrZero(Recno(),10)
					oTree:AddTreeItem(C4_DOC+" - "+DTOC(C4_DATA),"BPMSEDT1","BPMSEDT1","3"+cCargo+cRecno)	
				EndIf
				dbSkip()
			End
		EndIf		
		dbSelectArea("SB1")
		dbSkip()
	End
#ENDIF	
RestArea(aArea)
RETURN lPossuiReg

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Fat140Ind � Autor �Rodrigo de A Sartorio  � Data �06.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Checa se existe o indice 2 do arquivo SC4                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Logico, caso .t. indica existencia de indice                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Fat140Ind()
Local aAreaSIX  := {}
Local lTemIndice:= .F.
Local cSixChave := ""
Local cAreaOri  :=Alias()
aAreaSIX:=SIX->(GetArea())
dbSelectArea("SIX")
dbSeek("SC4")
While ("SC4" == INDICE) .and. !Eof()
	cSixChave := AllTrim(CHAVE)
	If SIX->ORDEM == "2" .And. cSixChave == "C4_FILIAL+C4_PRODUTO+DTOS(C4_DATA)"
		lTemIndice:=.T.
		Exit
	EndIf
	dbSkip()
End
RestArea(aAreaSIX)
dbSelectarea(cAreaOri)
RETURN lTemIndice

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft140IncPV� Autor �Rodrigo de A Sartorio  � Data �10.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Inclui previsoes de venda                                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto tree                                           ���
���          � ExpD1: Data inicial para filtragem da previsao de vendas     ���
���          � ExpD2: Data final para filtragem da previsao de vendas       ���
���          � ExpA1: Array com os dados utilizados para inclusao da Prev.  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Ft140IncPV(oTree,dDataIni,dDatafim,aDadosProd)
Local oDlgGet,oGetD 
Local aRetCopy  	:= If(Type("aRotina")=="A",ACLONE(aRotina),{})
Local cCargo    	:= oTree:GetCargo()
Local cAreaOri 		:= Alias()
Local aAreaSC4  	:= SC4->(GetArea())
Local cCatego   	:= Substr(cCargo,2,Len(ACU->ACU_COD))
LOCAL aObjects  	:= {},aPosObj :={}
LOCAL aSize    		:= MsAdvSize()
LOCAL aInfo     	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local nx        	:= 0
Local nOpca     	:= 0
Local aColsBack 	:= {}
Local nPosProd 		:= 0
Local nPosLocal 	:= 0
Local nPosQuant 	:= 0
Local nPosValor 	:= 0
Local nPosRevis 	:= 0
Local nPosData   	:= 0
Local cFilialSB1	:= ''
Local lPCPREVATU	:= FindFunction('PCPREVATU') 
Private aHeader 	:= {} 
Private aCols   	:= {}
Private lShowOpc	:= .T.
Private n 			:= 1

If Substr(cCargo,1,1) == "1" .And. (nAcho:=Ascan(aDadosProd,{|x| x[1]== cCatego})) > 0
	cFilialSB1	:= xFilial("SB1")
	
	// Define arotina fixo
	aRotina   := { { "" , "        ", 0 , 3}}
	// Cria dados para tela de inclusao - CABECALHO
	aHeader := A610CriaHeader("SC4",,,.T.)
	For nx:=1 to Len(aHeader)
		If "aProdGrade(M->C4_PRODUTO).or." $ aHeader[nx,6]
			aHeader[nx,6] := StrTran(aHeader[nx,6],"aProdGrade(M->C4_PRODUTO).or.","")					
		EndIf 	
	Next nx
	// Ajusta tamanho dos nomes do campo para evitar erro na SeleOpc
	aEval(aHeader,{|x| x[2] := Padr(x[2],10) })
	// Posicao dos itens na getdados
	nPosProd  :=GDFieldPos("C4_PRODUTO")
	nPosLocal :=GDFieldPos("C4_LOCAL")
	nPosQuant :=GDFieldPos("C4_QUANT")
	nPosValor :=GDFieldPos("C4_VALOR")
	nPosRevis :=GDFieldPos("C4_REVISAO")
	nPosData :=GDFieldPos("C4_DATA")
	// Cria dados para tela de inclusao - LINHAS
	aColsBack  := A610CriaCols("SC4",aHeader,xFilial("SC4") + SC4->C4_PRODUTO,&('{||SC4->C4_FILIAL + SC4->C4_PRODUTO==xFilial("SC4") + SC4->C4_PRODUTO}'))[1]  
	For nx:=nAcho to Len(aDadosProd)
		// Checa categoria
		If aDadosProd[nx,1] <> cCatego
			Exit
		EndIf
		// Preenche produto na getdados	
		If !Empty(aDadosProd[nx,2])
    		SB1->(dbSetOrder(1))
			If SB1->(dbSeek(cFilialSB1+aDadosProd[nx,2]))
				AADD(aCols,ACLONE(aColsBack[1]))			
				aCols[Len(aCols),nPosProd]:=aDadosProd[nx,2]
				aCols[Len(aCols),nPosLocal]:=SB1->B1_LOCPAD
				aCols[Len(aCols),nPosRevis]:=IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
				aCols[Len(aCols),nPosQuant]:=0
				aCols[Len(aCols),nPosData]:=dDataBase
			EndIf
		// Preenche grupo de produtos
		ElseIf !Empty(aDadosProd[nx,3])
			SB1->(dbSetOrder(4))
			SB1->(dbSeek(cFilialSB1+aDadosProd[nx,3]))
			While !SB1->(Eof()) .And. SB1->(B1_FILIAL+B1_GRUPO) == cFilialSB1+aDadosProd[nx,3]
				AADD(aCols,ACLONE(aColsBack[1]))			
				aCols[Len(aCols),nPosProd]:=SB1->B1_COD
				aCols[Len(aCols),nPosLocal]:=SB1->B1_LOCPAD
				aCols[Len(aCols),nPosRevis]:=IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
				aCols[Len(aCols),nPosQuant]:=0
				aCols[Len(aCols),nPosData]:=dDataBase
				SB1->(dbSkip())
			End
		EndIf	
	Next nx	
	// Verifica a existencia de informacoes na inclusao
	If Len(aCols) > 0
		nOpca := 0
		AADD(aObjects,{100,100,.T.,.T.,.F.})
		aPosObj:=MsObjSize(aInfo,aObjects)
		DEFINE MSDIALOG oDlgGet TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
			oGetD := MSGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],1,"Fat140LOk","Fat140TOk","",.T.,,,,,"Ft140FldOk")
		ACTIVATE MSDIALOG oDlgGet ON INIT EnchoiceBar(oDlgGet,{|| nOpca := 1,If(oGetD:TudoOk(),oDlgGet:End(), nOpca :=  0 )},{|| nOpca := 2,oDlgGet:End()})
		// Grava previsoes de venda
		If nOpca == 1
			A610GravaCol(aCols,aHeader,{},"SC4")
		EndIf
	EndIf
EndIf

aRotina:=AClone(aRetCopy)
RestArea(aAreaSC4)
If !Empty(cAreaOri)
	dbSelectArea(cAreaOri)
EndIf

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Fat140LOk � Autor �Rodrigo de A Sartorio  � Data �10.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida inclusao das previsoes de venda por linha             ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto getdados                                       ���
���          � ExpL1: Indica se percorre todas as linhas                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Fat140LOk(o,lTodas)
LOCAL lRet		:= .T.
LOCAL nx  		:= 0
LOCAL nPProd 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_PRODUTO"})
LOCAL nPQtde 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_QUANT"})
LOCAL nPData 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_DATA"})
LOCAL nPOpc  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_OPC"})
LOCAL nPRev  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_REVISAO"})

DEFAULT lTodas 	:= .F.

If !lTodas
	If !GDdeleted(n)
		lRet:=MaCheckCols(aHeader,aCols,n)
	EndIf
	If lRet .And. If(Type("lShowOpc")=="L",lShowOpc,.F.) .And. !Empty(nPOpc)
		lRet := SeleOpc(2,"FATA140",aCols[n,nPProd],,,aCols[n][nPOpc],"M->C4_PRODUTO",,aCols[n,nPQtde],aCols[n,nPData],aCols[n,nPRev])
		If lRet
			lShowOpc := .F.
		EndIf
	EndIF
Else
	For nx:=1 to Len(aCols)
		If !GDdeleted(nx)
			lRet:=MaCheckCols(aHeader,aCols,nx)
		EndIf
		If !lRet
			Exit		
		EndIf
	Next nx
EndIf
RETURN lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Fat140TOk � Autor �Rodrigo de A Sartorio  � Data �10.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida inclusao das previsoes de venda de todas as linhas    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto getdados                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Fat140TOk(o)
Return Fat140LOk(o,.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Fat140Trfs� Autor �Rodrigo de A Sartorio  � Data �26.10.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua refresh no tree apos click no botao de refresh        ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto dialog                                         ���
���          � ExpO2: Objeto tree                                           ���
���          � ExpA1: Array com totais                                      ���
���          � ExpA2: Array com dados para inclusao de previsoes            ���
���          � ExpD1: Data inicial para filtragem da previsao de vendas     ���
���          � ExpD2: Data final para filtragem da previsao de vendas       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Fat140Trfs(oDlg,oTree,aTotais,aDadosProd,dDataIni,dDataFim)
Local cCargoOri:=oTree:GetCargo()
// Zera dados dos totalizadores
aTotais:={}
aDadosProd:={}	
// Zera dados do tree
oTree:BeginUpdate()
oTree:Reset()                                            
oTree:EndUpdate()
// Cria o Tree e preenche as informacoes
FT140MTree(oTree,cCodVazio,NIL,NIL,NIL,.T.,.T.,aTotais,dDataIni,dDataFim,aDadosProd)
// Reposiciona o tree na primeira posicao
oTree:TreeSeek("1"+cCodVazio+cProdVazio+cGrupoVazio+cRecnoVazio)
// Atualiza tela com informacoes auxiliares
Eval(oTree:bChange)
// Reposiciona o tree na posicao original
oTree:TreeSeek(cCargoOri)
// Atualiza tela com informacoes auxiliares
Eval(oTree:bChange)
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft140Grade�Autor  �Patricia D. Aguiar  � Data �  05/02/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft140Grade(cProdRef)

Local aAuxiliar 	:= {}
Local aArea     	:= GetArea()
Local cFilialSB1	:= xFilial("SB1")
Default cProdRef	:= ''

DbSelectArea("SB1")
DbSetOrder(1)

If MsSeek(cFilialSB1+cProdRef,.T.)
	While SB1->( !Eof() .And. B1_FILIAL+Left(B1_COD,Len(Alltrim(cProdRef))) == cFilialSB1+Alltrim(cProdRef) )
		Aadd(aAuxiliar,{SB1->B1_COD,StrZero(SB1->(Recno()),10)})
		DbSkip()
	
	EndDo
EndIf

Restarea(aArea)
Return(aAuxiliar)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft140FldOk�Autor  �Andre Anjos         � Data �  29/01/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Valida campos da GetDados                                  ���
�������������������������������������������������������������������������͹��
���Uso       � FATA140                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft140FldOk()
Local lRet := .T.

If Type("lShowOpc") == "L"
	lShowOpc := .T.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft140Cnf  �Autor  �Vendas CRM          � Data �  04/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de validacao da tela, utilizada para verificar se os ���
���          �produtos de uma categoria desativada estarao duplicados ao  ���
���          �reativar a mesma.                                           ���
�������������������������������������������������������������������������͹��
���Uso       �FATA140                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft140Cnf(nOpc, oMdl)

Local aArea			:= GetArea()
Local aAreaACU  	:= ACU->(GetArea())
Local aAreaACV		:= ACV->(GetArea())
Local aProdutos		:= {}
Local aGrupos		:= {}  
Local aProdDup		:= {}
Local aGrupDup		:= {}
Local lRet 			:= .T.
Local lCpBloq		:= (ACU->(FieldPos("ACU_MSBLQL")) > 0)
Local nX			:= 0
Local cCategAtu		:= ACU->ACU_COD
Local cFilialACV	:= ''
Local cFilialACU	:= ''
Local cFilialSBM    := ''
Local cFilialSB1	:= ''

Default nOpc		:= 4
Default oMdl		:= Nil 
//������������������������������������������������������������Ŀ
//�Caso a categoria bloqueada tenha sido desbloqueada, valida  �
//�os produtos que gerarao duplicidade, impedindo o desbloqueio�
//��������������������������������������������������������������
If nOpc == 4 .AND. lCpBloq .AND. ACU->ACU_MSBLQL == "1" .AND. M->ACU_MSBLQL <> "1"
	cFilialACV	:= xFilial("ACV")
	cFilialACU	:= xFilial("ACU")
	cFilialSBM  := xFilial("SBM")
	cFilialSB1	:= xFilial("SB1")
	
	DbSelectArea("ACV")
	DbSetOrder(1) //ACV_FILIAL+ACV_CATEGO+ACV_GRUPO+ACV_CODPRO
	DbSeek(cFilialACV+cCategAtu)
	
	While !ACV->(Eof()) .AND. ACV->ACV_FILIAL == cFilialACV .AND. ACV->ACV_CATEGO == cCategAtu
		Do Case
			Case !Empty(ACV->ACV_GRUPO)
				AAdd(aGrupos,ACV->ACV_GRUPO)
			Case !Empty(ACV->ACV_CODPRO)
				AAdd(aProdutos,ACV->ACV_CODPRO)
		EndCase
		ACV->(DbSkip())
	End

	ACU->(DbSetOrder(1)) //ACU_FILIAL+ACU_COD
	
	nX := 1        
	
	//���������������������������������������������Ŀ
	//�Valida existencia de duplicidade entre grupos�
	//�����������������������������������������������
	ACV->(DbSetOrder(2)) //ACV_FILIAL+ACV_GRUPO+ACV_CODPRO+ACV_CATEGO
	
	While nX <= Len(aGrupos)
		
		If ACV->(DbSeek( cFilialACV+aGrupos[nX] ) )
			
			While !ACV->(Eof()) .AND. ACV->ACV_FILIAL == cFilialACV .AND. ACV->ACV_GRUPO == aGrupos[nX]
				If ACV->ACV_CATEGO <> cCategAtu
					If ACU->(DbSeek(cFilialACU+ACV->ACV_CATEGO)).AND. ACU->ACU_MSBLQL <> "1"
						AAdd(aGrupDup,{	ACV->ACV_GRUPO,;
										GetAdvFVal("SBM","BM_DESC",cFilialSBM+ACV->ACV_GRUPO,1,""),;
										ACV->ACV_CATEGO})
						lRet := .F.
					EndIf
				EndIf
				ACV->(DbSkip())
			End
		EndIf
		nX++

	EndDo
	
	nX := 1
	
	//�����������������������������������������������Ŀ
	//�Valida existencia de duplicidade entre produtos�
	//�������������������������������������������������
	ACV->(DbSetOrder(5)) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO

	While nX <= Len(aProdutos)
		
		ACV->(DbSeek(cFilialACV+aProdutos[nX]))
	
		While !ACV->(Eof()) .AND. ACV->ACV_FILIAL == cFilialACV .AND. ACV->ACV_CODPRO == aProdutos[nX]
			If ACV->ACV_CATEGO <> cCategAtu
				If ACU->(DbSeek(cFilialACU+ACV->ACV_CATEGO)).AND. ACU->ACU_MSBLQL <> "1"
					AAdd(aProdDup,{	ACV->ACV_CODPRO,;
									GetAdvFVal("SB1","B1_DESC",cFilialSB1+ACV->ACV_CODPRO,1,""),;
									ACV->ACV_CATEGO})
					lRet := .F.
				EndIf
			EndIf
			ACV->(DbSkip())
		End
		
		nX++
		
	End

EndIf

If !lRet
	MsgStop(STR0014) //"O desbloqueio desta categoria n�o pode ser realizado pois h� produtos desta categoria que foram vinculados a outra categoria."
	
	//Exibe grupos duplicados
	If Len(aGrupDup) > 0
		Ft140ExDup(STR0015,aGrupDup,STR0016,STR0017,STR0018) //"Grupos duplicados"###"Grupo"###"Descri��o"###"Categoria"
	EndIf
	
	//Exibe produtos duplicados
	If Len(aProdDup) > 0
		Ft140ExDup(STR0019,aProdDup,STR0020,STR0017,STR0018) //"Produtos duplicados"###"Produto"###"Descri��o"###"Categoria"
	EndIf

ElseIf (nOpc == 5)
		Ft140VlAlt()	
EndIf

RestArea(aAreaACV)
RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft140ExDup�Autor  �Vendas CRM          � Data �  09/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe produtos/grupos em duplicidade com outras categorias, ���
���          �ao tentar desbloquear uma categoria bloqueada com filhos.   ���
�������������������������������������������������������������������������͹��
���Uso       �FATA140                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft140ExDup(cTitulo,aLista,cCab1,cCab2,cCab3)

Local oDlg		:= Nil
Local oLbx		:= Nil

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 266,421 PIXEL

@003,002 TO 117,211 LABEL "" PIXEL OF oDlg

@009,004 ListBox oLbx Fields HEADER cCab1,cCab2,cCab3 Size 204,105 Of oDlg Pixel

oLbx:SetArray(aLista)
oLbx:bLine := {||{	aLista[oLbx:nAT][1],;
					aLista[oLbx:nAT][2],;
					aLista[oLbx:nAT][3]}}

DEFINE SBUTTON FROM 119,185 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED 

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao para processamento de mensagem unica.
@author Danilo Dias
@since 02/04/2012
@version 1.0
@param xEnt, caracter/Object, Variavel com conteudo xml/obj para envio/recebimento.
@param nTypeTrans, numeric, Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage, caracter, Tipo de mensagem. (Business Type, WhoIs, etc)
@param cVersion, caracter, Vers�o da Mensagem �nica TOTVS
@param cTransac, caracter, Nome da mensagem iniciada no adapter
@param lEAIObj, Logical Recebe XML ou Objeto EAI
@return ${return}, ${return_description}
/*/
//----------------------------------------------------------------------------
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )

Default xEnt := ""
Default nTypeTrans := ""
Default cTypeMessage := ""
Default cVersion := ""
Default cTransac := ""
Default lEAIObj := .F.

Return FATI140(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
