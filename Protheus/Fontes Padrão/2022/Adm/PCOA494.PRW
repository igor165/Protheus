// Copyright (C) 2007, Microsiga

#include "protheus.ch"
#include "pcoa494.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA494   �Autor  �Acacio Egas         � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Planejamento de Movimentos n�o operacionais.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static oMenuALV,oMenuAM4

Function PCOA494( cAlias , nReg , nOpcx , aCpos , cVerPlan )

Local nWidth  := GetScreenRes()[1] - 40
Local nHeight := GetScreenRes()[2] - 200
Local _nContItem
Local aHeaderALX,aColsALX

If ALV->ALV_STATUS == "2" .and. cVerPlan==nil  // ORCAMENTO EM REVISAO 
	HELP("  ",1,"PCOA100REV")
	Return
EndIf

Private lAlterPNJ	:= ( nOpcx==4 )
Private _cVerPlan 	:= If(cVerPlan<>nil,cVerPlan, ALV->ALV_VERSAO) // Criado para Ferramenta de Revis�a
Private aDataPlnj := {}
Private _aListData := PcoRetPer(ALV->ALV_INIPER,ALV->ALV_FIMPER,ALV->ALV_TPPERI,.F.,aDataPlnj)

DbSelectArea("ALV")
Private oPlanej := PCOArea():New(0,0, nWidth, nHeight, STR0001 ) //"Planejamento Or�ament�rio"
Private aCampos := {{'',''}}
//�������������������������������������������������������������������Ŀ
//�  Maximiza a oDlg principal, deixando o tamanho correto da window  �
//���������������������������������������������������������������������
oPlanej:ODLG:LMAXIMIZED := .T.

//Cria  Layouts para a Tela
oPlanej:AddLayout("Planej")
oPlanej:AddLayout("Distri")


oPlanej:addSide(28,"Estrutura")

oPlanej:AddWindow(96,"WIN1", STR0002 ,2,.F.,.F.,oPlanej:oArea:oSideBar) //"Estrutura"

oPlanej:AddTre("001","WIN1",nil)

// Monta Estrutura do Tree
oPlanej:No_Tree("Planejamento"		,"ALV","ALLTRIM(ALV_CODIGO)+'-'+ALV_DESCRI","RPMCPO"	,{|| oPlanej:ShowLayout("Planej")	}	,{|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)},,)
oPlanej:No_Tree("Tipo de Despesa"	,"AM4","ALLTRIM(AM4_CODIGO)+'-'+AM4_DESCRI","SIMULACA"	,{|| oPlanej:ShowLayout("Distri"),Find_Agreg()	}	,{|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)},,{|x| PcoIncAM2(x,"006",,,.F.) })

aButs := {}

If lAlterPNJ
	
	aAdd( aButs , { 1, "GPRIMG32"	, 	{|| PcoRatALX(oPlanej:Getobj('WIN2')) }			, STR0003	, .F. } )
	aAdd( aButs , { 1, "EXCLUIR"	, 	{|| PcoExclRatALX(oPlanej:Getobj('WIN2')) }		, STR0005	, .F. } )//"Incluir Rateio"###"Visualizar Rateio"###"Excluir Rateio"

EndIf
aAdd( aButs , { 1, "RELATORIO"	, 	{|| PcoVisuRateioALX(oPlanej:Getobj('WIN2')) }	, STR0004	, .F. } )

// Adiciona Janela 2 com Bot�es - servira para conter o cadastro centro de custo /ou Funcao /ou GetDados
oPlanej:AddWindow(48,"WIN2", STR0006 ,3, lAlterPNJ ,,,aButs) //"Distribui��o de Entidades"

// Monta aHeader da GetDados
aCpos := {"ALX_TIPO","ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOA4941")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4941"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aColsALX	:= nil
// Cria GetDados da Tela
																				//,bChange	,bLoad,bConfirm
oPlanej:AddGtD("001", STR0007 ,"WIN2","Distri",aHeaderALX,aColsALX,{|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("001"))}	,{|x| Find_Agreg()},{|x| PcoPnjAtu(@oPlanej:GetGtd("001"),"006",.T.)}) //"Movimentos n�o operacionais"

// Cria variaveis de memoria para a MSMGet
RegToMemory("ALV", .F.,,, FunName())
//Cria MsmGet
oPlanej:AddMsm("001", STR0008 ,"ALV",ALV->(Recno()),"WIN2","Planej",/*{|x| }*/,/*{|x| }*/) //"Planejamento"

// Adiciona Janela 2
oPlanej:AddWindow(48,"WIN3", STR0009 ,2, lAlterPNJ ,"Distri") //"Distribui��o de Valores"

//********************************************************
//  Gera Variaveis de Memoria para a MsmGetAutoContida   *
//********************************************************
	// Gera vari�veis para utiliza��o na MsMGet
	_aGetValues := {}
	_aGetQuants := {}
	For _nContItem := 1 to Len(_aListData)	
		_SetOwnerPrvt("VLR" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		_SetOwnerPrvt("QTD" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		// Criando campos para a MsmGet
		SX3->(DbSetOrder(2))
		SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
		ADD FIELD _aGetValues TITULO _aListData[_nContItem] CAMPO "VLR" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
		ADD FIELD _aGetQuants TITULO _aListData[_nContItem] CAMPO "QTD" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
	Next	
// Fim                    

//Cria MsmGet
oPlanej:AddMsm("003", STR0010 ,"ALY",ALY->(Recno()),"WIN3","Distri"	,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.,AtuPrc()) },_aGetQuants) //"Quantidades"
oPlanej:AddMsm("002",STR0011,"ALY",ALY->(Recno()),"WIN3","Distri"			,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.) },_aGetValues)  //"Valores"
oPlanej:AddBrw("001", STR0012 ,{"Codigo","Descri��o"},"WIN3","Planej",{|| AtuBrow()}) //"Produtos"###"Codigo"###"Descri��o"

oPlanej:ShowLayout("Planej")
// Inicializa o Tree
AtuAgreg(.t.)

//���������������������������������������������������������������������������������Ŀ
//�Fun��o que desabilita os botoes da WIN2 quando posicionado o registro pai da tree�
//�����������������������������������������������������������������������������������
P493DesBot()

//���������������������������������������������������������������Ŀ
//�Insere tratamento no BCHANGE do objeto da Tree para desabilitar�
//� os botoes da WIN2 quando posicionado no registro pai da Tree  �
//�����������������������������������������������������������������
oPlanej:Aobjetos[1][2]:BCHANGE := {|OOBJ,NROW,NCOL| oObj:TREECHANGE(OOBJ,NROW,NCOL),P493DesBot()}

oPlanej:Activate()

/*
If lAlterPNJ

	Processa( {|| PcoPnjSld() } , STR0015 ) //"Atualizando Saldos"

EndIf
*/

Return

Static Function AtuBrow()
Local nX
Local cId,cCargo

	aCampos:= {}
	For Nx:=1 To Len(oPlanej:GetTre("001"):aCargo)
	
		cCargo := oPlanej:GetTre("001"):aCargo[Nx,1]
		
		If SubStr(cCargo,1,3)="AM4"
		
			cId := SubStr(cCargo,4,Len(cCargo)-3) 
			DbSelectArea("AM2")
			DbSetOrder(3)
			DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + "006" + cId)
			
			DbSelectArea("AM4")
			DbSetOrder(1)			
			DbSeek( xFilial("AM4")+ AM2->AM2_AGREG )
			aAdd(aCampos,{AM4->AM4_CODIGO,AM4->AM4_DESCRI})
	
		EndIf
	
	Next
    If Len(aCampos)=0
    
    	aCampos:= {{'',''}}
    
    EndIf
	oPlanej:GetBrw("001"):SetArray(aCampos)
	oPlanej:GetBrw("001"):bLine := {|| aCampos[oPlanej:GetBrw("001"):nAt] }
	oPlanej:GetBrw("001"):Refresh()

ReTurn

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PopupMenu �Autor  �Acacio Egas         � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o executada ao clicar bot�o direita no xTree.         ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function RightTree(oTree,oObject1,oObject2, x, y, z)

Local oMenu := PopupMenu(@oTree)
If oMenu <> Nil
	oMenu:Activate(x - 24, y - 100, oPlanej:GetSidebar() )
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PopupMenu �Autor  �Acacio Egas         � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Popup executado no xTree                                   ���
���          �                                                            ���
���Sintaxe   � LoadTree(ExpC1)                                            ���
�������������������������������������������������������������������������͹��
���          � ExpC1 - Objeto xTree para disparar popup.                  ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PopupMenu(oTree)
Local oMenu := Nil
Local cCargo := oTree:GetCargo()
Local cAlias := SubStr(cCargo,1,3)
Local cId

Do Case	
	Case cAlias == "ALV"
		
		If oMenuALV<>nil
		
			oMenuALV:Free()
			
		EndIf
		
		Menu oMenuALV Popup
		MenuItem STR0016 Block {|| InsertTipo(@oTree)} //"Adicionar Movimentos n�o operacionais"
//		MenuItem "___________________" Disabled
//		MenuItem STR0017 Block {|| Pnj100alt() } //"Reajustar Valores"
		EndMenu

		If !lAlterPNJ
		
			oMenuALV:AITEMS[01]:LACTIVE := .F.
			
		EndIf
		
		oMenu := oMenuALV
		
	Case cAlias == "AM4"
		
		cId := SubStr(cCargo,4,Len(cCargo)-3)
		
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + "006" + cId)

		
		/*BEGINDOC
		//�������������������������������������Ŀ
		//�Posiciona Movimentos n�o Operacionais�
		//���������������������������������������
		ENDDOC*/
		DbSelectArea("AM4")
		DbSetOrder(1)
		DbSeek(xFilial("AM4")+AM2->AM2_AGREG)

		If oMenuAM4<>nil
		
			oMenuAM4:Free()
			
		EndIf

		Menu oMenuAM4 Popup
		MenuItem STR0018 Block {|| 	PcoDistShow( "ALX_AM2ID='" + cId + "' " , (AM4->AM4_TPVLR=='1') , "006" ) } //"Visualizar Distribui��o "
		MenuItem "___________________" Disabled
		MenuItem STR0019 Block {|| DelTipo(@oTree) } //"Excluir Movimento n�o operacional"
		MenuItem "___________________" Disabled
		MenuItem STR0020 Block {|| PcoRunPlan(cId,"006",3,@oPlanej:GetGtd("001")) } //"Gerar Distribui��o"
		MenuItem STR0021 Block {|| PcoRunPlan(cId,"006",5,@oPlanej:GetGtd("001")) } //"Excluir Distribui��o"
		MenuItem "___________________" Disabled 
		MenuItem STR0022 Block {|| PcoPnjAlt( cId , , , {"006"} ), AtuAgreg(.T.,.T.) } //"Reajustar Valores"
		EndMenu		 
		
		If !lAlterPNJ
		
			oMenuAM4:AITEMS[03]:LACTIVE := .F.
			oMenuAM4:AITEMS[05]:LACTIVE := .F.
			oMenuAM4:AITEMS[06]:LACTIVE := .F.
			oMenuAM4:AITEMS[08]:LACTIVE := .F.
		EndIf		
		
		oMenu := oMenuAM4
									
	Otherwise		
		// sem menu		
EndCase 

Return oMenu

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InsertTipo      �Autor  �Acacio Egas   � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Distribui Despesas Indiretas no xTree.                     ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function InsertTipo(oTree)
Local aConfig
If ParamBox({ 	{1, STR0023 ,SPACE(Len(AM4->AM4_CODIGO)),"@S6","ExistCpo('AM4')","AM4",".T.",40,.F.},; //"Movimentos de ?"
	  			{1, STR0025 ,SPACE(Len(AM4->AM4_CODIGO)),"@S6","ExistCpo('AM4')","AM4",".T.",40,.F.}}, STR0026 ,@aConfig,,,,,,,"PCOA494_05",,.T.) //"Movimentos ate ?"###"Distribui��o do Planejamento"

	oPlanej:LoadTree(@oTree,"AM4",aConfig[1],aConfig[2] ,,,,, "AM2->AM2_ID" )
	AtuAgreg()
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DelTipo         �Autor  �Acacio Egas   � Data �  03/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Deleta Despesas Indiretas no xTree.                        ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function DelTipo(oTree)

Local cCargo 	:= oTree:GetCargo()
Local cId		:= SubStr(cCargo,4,Len(cCargo)-3)
Local lContinua := .T.

DbSelectArea("ALX")
DbSetOrder(3)

If DbSeek(xFilial("ALX")+ cId + "006")

	lContinua := .F.

EndIf
	
If lContinua

	DbSelectArea("AM2")
	DbSetOrder(3)
	If DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + "006" + cId)

		RecLock("AM2",.F.)
			DbDelete()
		MsUnlock()
		oTree:DelItem()
		AtuAgreg()
	EndIf
Else
	Aviso( STR0027 , STR0028 ,{ STR0029 }) //"Aten��o"###"Existem lan�amentos para este agregador. Favor excluir os lan�amentos."###"OK"
EndIf

Return


// Atualiza aCols
Static Function Find_Agreg()
                                
Local cCargo	:= oPlanej:GetTre("001"):GetCargo()
Local cId 		:= SubStr(cCargo,4,Len(cCargo)-3)

DbSelectArea("AM2")
DbSetOrder(3)
DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"006"+cId)

PcoFindALX(cId,"006",@oPlanej:GetGtd("001"))


Return

Static Function AtuAgreg(lIni,lRefresh)
// Monta Tree
Local nX
Local aLoad := {}

Default lIni 		:= .F.
Default lRefresh    := .F.

If lIni
	oPlanej:GetTre("001"):Reset()
EndIf

//Local nBrow := oPlanej:GetBrw("001")
DbSelectArea("AM2")
DbSetorder(3)
DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"006")
Do While !AM2->(Eof()) .and. ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"006"==AM2->AM2_FILIAL+AM2->AM2_PLANEJ+AM2->AM2_VERSAO+AM2->AM2_TIPOPL
	DbSelectArea("AM4")
	DbSetOrder(1)
	DbSeek(xFilial("AM4")+AM2->AM2_AGREG)
	aAdd(aLoad,{"AM4",AM2->AM2_AGREG,{},"'"+AM2->AM2_ID+"'",AM2->AM2_ID})
	AM2->(DbSkip())
EndDo

If lIni

	oPlanej:LoadTree(@oPlanej:GetTre("001"),"ALV",ALV->ALV_CODIGO,,1,.F.,aLoad)

	If lRefresh
	
		oPlanej:GetTre("001"):Display()
		oPlanej:GetTre("001"):TreeSeek(oPlanej:GetTre("001"):aCargo[1,1])
		oPlanej:ShowLayout("Planej")
	
	EndIf

EndIf

aCampos:= {}
For Nx:=1 To Len(oPlanej:GetTre("001"):aCargo)

	DbSelectArea("AM4")
	DbSetOrder(1)

	cCargo := oPlanej:GetTre("001"):aCargo[Nx,1]
	
	If SubStr(cCargo,1,3)="AM4"

	    cId := SubStr(cCargo,4,Len(cCargo)-3)
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"006"+cId)        
		DbSelectArea("AM4")
		DbSetOrder(1)

		DbSeek( xFilial("AM4") + AM2->AM2_AGREG )
		aAdd(aCampos,{AM4->AM4_CODIGO,AM4->AM4_DESCRI})

	EndIf

Next

If Len(aCampos)==0

	aCampos := {{'',''}}

EndIf

oPlanej:GetBrw("001"):SetArray(aCampos)
oPlanej:GetBrw("001"):bLine := {|| aCampos[oPlanej:GetBrw("001"):nAt] }
oPlanej:GetBrw("001"):Refresh()

Return

Static Function AtuPrc()
Local nVlUnit 	:= 0
Local cCargo 	:= oPlanej:GetTre("001"):GetCargo()
Local cId

cId := SubStr(cCargo,4,Len(cCargo)-3)

DbSelectArea("AM2")
DbSetOrder(2)
DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"006"+cId)

DbSelectArea("AM4")
DbSetOrder(1)
DbSeek(xFilial("AM4")+AM2->AM2_AGREG)

If ALLTRIM(AM4->AM4_TPVLR)=='1'
	// 	nVlUnit := BuscaPreco490(AM2->AM2_AGREG,'006') - N�o encontrado fun��o em fontes e nem no diagrama de funcoes.
Else
	Aviso( STR0027 , STR0030 ,{ STR0029 }) //"Aten��o"###"Mov. n�o operacional controlado por Valor"###"OK"
EndIf

Return (nVlUnit)
