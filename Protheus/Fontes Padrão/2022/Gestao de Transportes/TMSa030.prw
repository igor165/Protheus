#include "TMSA030.ch"
#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA030   � Autor �        Nava        � Data � 02/11/01 ���
��������������������������������������������������������������������������͹��
���                        Componentes de Frete                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA030()                                                ���
��������������������������������������������������������������������������͹��
��� Parametros �                                                           ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador    �  Data    � BOPS � Motivo da Alteracao                  ���
��������������������������������������������������������������������������͹��
���Mauro Paladini � 09/08/13 �      � Conversao para padrao MVC            ���
���Mauro Paladini � 06/12/13 �      � Ajustes para funcionamento do Mile   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function TMSA030()

Local oBrowse := Nil
Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DT3")
oBrowse:SetDescription(STR0001) //"Componentes de Frete"
oBrowse:Activate()

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()

Local oModel		:= Nil
Local oStruDT3	:= Nil
Local oStruDJE	:= Nil

Local bPreValid	:= Nil
Local bPosValid	:= { |oMdl| PosVldMdl(oMdl) }
Local bCommit		:= { |oMdl| CommitMdl(oMdl) }
Local bCancel		:= Nil
Local lTabDJE	    := AliasIndic("DJE")

oStruDT3	:= FWFormStruct(1,"DT3")

oModel:= MpFormMOdel():New("TMSA030",  /*bPreValid*/ , bPosValid , bCommit ,/*bCancel*/ )
oModel:AddFields("MdFieldDT3",Nil,oStruDT3,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 	// ""Componentes de Frete"

If lTabDJE
	oStruDJE	:= FwFormStruct( 1, "DJE" )
	
	oModel:AddGrid( "MdGridDJE", "MdFieldDT3", oStruDJE )
	
	oModel:SetRelation( "MdGridDJE", { { "DJE_FILIAL", "xFilial( 'DJE' )" }, { "DJE_CODPAS", "DT3_CODPAS" } }, DJE->( IndexKey( 1 ) ) )
	
	oModel:GetModel( "MdGridDJE" ):SetUniqueLine( { "DJE_CMPREL" } )
	
	oModel:GetModel( "MdGridDJE" ):SetOptional( .T. )
	
	oModel:GetModel("MdGridDJE"):SetDescription(STR0001) // "Componentes de Frete"
EndIf	

	oModel:SetPrimaryKey({"DT3_FILIAL","DT3_CODPAS"})

Return ( oModel )                   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ViewDef()

Local oModel 	:= FwLoadModel("TMSA030")
Local oView 	:= Nil
Local oStruDJE:= Nil 
Local lTabDJE := AliasIndic("DJE")

oView:= FwFormView():New()
oView:SetModel(oModel)

If !lTabDJE
	oView:CreateHorizontalBox( "TELA"	, 100 )
Else
	oStruDJE:=FwFormStruct( 2, "DJE" )
	oStruDJE:RemoveField( "DJE_CODPAS" )
	oView:CreateHorizontalBox( "TELA"	, 050 )
	oView:CreateHorizontalBox( "Grid"	, 050 )
EndIf

oView:AddField('VwFieldDT3', FWFormStruct(2,"DT3") , 'MdFieldDT3') 
oView:SetOwnerView("VwFieldDT3","TELA")

If lTabDJE	
	oView:AddGrid( "VwGridDJE", oStruDJE, "MdGridDJE" )
	oView:SetOwnerView( "VwGridDJE"		, "Grid"	)

	oView:AddIncrementView( "VwGridDJE", "DJE_ITEM" )
	oView:EnableTitleView( "VwGridDJE",STR0019 )  //Componentes Relacionados
EndIf		

Return(oView)




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0014 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0015 	ACTION "VIEWDEF.TMSA030" OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0016 	ACTION "VIEWDEF.TMSA030" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0017 	ACTION "VIEWDEF.TMSA030" OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0018 	ACTION "VIEWDEF.TMSA030" OPERATION 5 ACCESS 0  //"Excluir"
ADD OPTION aRotina TITLE STR0020 	ACTION "VIEWDEF.TMSA030" OPERATION 9 ACCESS 0  //"Copiar"

Return ( aRotina )





/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   � PosVldMdl  � Autor �        Nava        � Data � 02/11/01 ���
��������������������������������������������������������������������������͹��
���        	Deleta a Componentes de Frete e seus Filhos (DT1)   		   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA030Del()                                             ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador    �  Data    � BOPS � Motivo da Alteracao                  ���
��������������������������������������������������������������������������͹��
���Mauro Paladini � 09/08/13 �      � Conversao para padrao MVC            ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function PosVldMdl(oMdl)

Local lRet    := .T.
Local lTabDJE := AliasIndic("DJE")
Local oMdldje := oMdl:GetModel("MdGridDJE")

If oMdl <> Nil .And. oMdl:GetOperation() == MODEL_OPERATION_DELETE

	DVE->(DbSetOrder(2))  // DVE_FILIAL + DVE_CODPAS
	If DVE->(DbSeek(xFilial("DVE") + FwFldGet("DT3_CODPAS")))
		Help(' ', 1, 'TMSA03001')  //-- Nao pode excluir Componente de Frete com Lay-out de Tabela relacionado.
		lRet := .F.
	Else
		If Aviso(	STR0002, STR0003 + FwFldGet("DT3_CODPAS") + CRLF + ; //"AVISO"###"Apagar Componentes de Frete "
					STR0004, { STR0005, STR0006 },, STR0007 ) == 1 //"e TODAS as tabelas CADASTRADAS COM ESTE CODIGO"###"Confirma"###"Cancela"###"Confirmacao"
	
			DbSelectArea( "DT3" )
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
Else
	If  oMdl <> Nil .And. lTabDJE 
		If FwFldGet("DT3_TIPFAI") == '16' //Herda Valor
			If oMdldje:Length() <= 1 .And. (oMdldje:IsEmpty() .Or. oMdldje:IsDeleted())
				Help(' ', 1, 'TMSA03007')  //-- Para o componente que calcula sobre 16-Herda Valor, � obrigatorio informar os componentes relacionados.
				lRet := .F.
			EndIf
		If lRet .And. FwFldGet("DT3_TAXA") == StrZero(1,Len(FwFldGet("DT3_TAXA")))  //Sim
				Help(' ', 1, 'TMSA03012')  //-- Nao � permitido informar TAXA igual a SIM, para componentes que Calcula Sobre '16-Herda Valor'
				lRet := .F.
			EndIf	
		Else
			If oMdldje:Length(.T.) >= 1 .And. !oMdldje:IsEmpty()
				Help(' ', 1, 'TMSA03010')  //-- Para componentes com calcula sobre diferente de 16-Herda Valor, n�o � permitido informar componentes relacionados.
				lRet := .F.
			EndIf
		EndIf	
	
	EndIf
Endif

Return lRet  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CommitMdl � Autor � Mauro Paladini        � Data �02.10.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de gravacao no commit (substituiu a funcao de grv)   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CommitMdl()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������� 
*/

Static Function CommitMdl(oModel)

	Begin Transaction
	
		FwFormCommit(oModel/*oModel*/,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			TMA030ComA()		
		Endif
	
	End Transaction

Return .T.

 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tma030ComA� Autor � Mauro Paladini        � Data �02.10.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao auxiliar de gravacao do commit                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Tma010Comm()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������� 
*/
Static Function TMA030ComA()

Local cQuery  := ""

cQuery := "UPDATE " + RetSqlName('DT1')
cQuery += "   SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DT1_FILIAL = '" + xFilial( 'DT1' ) + "' "
cQuery += "   AND DT1_CODPAS = '" + DT3->DT3_CODPAS + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSA03015',,'DT1',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA030Wh � Autor � Robson Alves          � Data �25.09.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Nao permite a altercao do campo(DT3_TIPFAI) se o componente���
���          �estiver sendo utilizado no layout da tabela de frete.       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsA030Wh()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������� 
*/

Function TmsA030Wh()

Local cCampo  := ReadVar()
Local lRet    := .T.

If Altera
	//�����������������������������������������������������������������������Ŀ
	//� Verifica se o componente esta sendo usando no layout da tabela.       �
	//�������������������������������������������������������������������������
	DVE->(dbSetOrder(2))
	lRet := !(DVE->(MsSeek(xFilial("DTL") + M->DT3_CODPAS)))
EndIf

If cCampo $ 'M->DT3_AGRVAL.M->DT3_APLDES'
	lRet := ( M->DT3_TIPFAI <= StrZero( 50, Len(DT3->DT3_TIPFAI)) )
ElseIf cCampo == 'M->DJE_CMPREL'
	lRet:= M->DT3_TIPFAI == '16' //Herda Valor
ElseIf cCampo == 'M->DT3_FAIXA2'
	If M->DT3_TIPFAI == '18' // TDA X REGI�O 
		lRet := .F. 
	EndIf 
EndIf

Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA030WPe� Autor � Alex Egydio           � Data �24.10.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Nao permite alterar o campo DT3_CALPES se o conteudo for 0 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA030WPe()

Local cCampo	:= ReadVar()
Local lRet		:= .T.

//-- Nao permite digitar se o conteudo for igual a 0-Nao Tem
If	cCampo == 'M->DT3_CALPES'
	lRet := ( M->DT3_CALPES != StrZero(0,Len(DT3->DT3_CALPES)) )
ElseIf cCampo == 'M->DT9_CALPES'

	lRet := AT250WhCfg()

	
EndIf
Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA030Vld� Autor � Alex Egydio           � Data �24.10.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida antes de editar o campo.                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA030Vld()

Local cCampo	:= ReadVar()
Local lRet		:= .T.
Local nTipFai	:= Len(DT3->DT3_TIPFAI)
Local nFaixa	:= Len(DT3->DT3_FAIXA)
Local cTipFai := ""

If	cCampo $ 'M->DT3_TIPFAI.M->DT3_FAIXA.M->DT3_FAIXA2'
	
	If cCampo = 'M->DT3_TIPFAI'
		//-- Gatilha a Faixa padrao
		M->DT3_FAIXA := M->DT3_TIPFAI
	ElseIf cCampo = 'M->DT3_FAIXA'
		//-- Verifica se a Faixa esta preenchida.
		If Empty(M->DT3_FAIXA)
			lRet := .F.
		EndIf
		// -- Se for praca de pedagio valida o campo DT3_FAIXA
		If lRet .And. M->DT3_TIPFAI == StrZero(9, Len(DT3->DT3_TIPFAI))
			If M->DT3_FAIXA <> StrZero(9, Len(DT3->DT3_TIPFAI))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	If lRet
		//-- Compara os campos Calcula Sobre e Faixa Por para veirificacao das faixas reservadas.
		If !Empty(M->DT3_TIPFAI) .And. !Empty(M->DT3_FAIXA)
			If M->DT3_TIPFAI <  "50" .And. M->DT3_FAIXA >= "50"
				Help(' ', 1, 'TMSA03003') //A 'Faixa Por' devera ser entre a numeracao disponibilizada para componentes de tabela A Receber.
				lRet := .F.
			ElseIf M->DT3_TIPFAI >= "50" .And. M->DT3_FAIXA < "50"
				Help(' ', 1, 'TMSA03004') //A 'Faixa Por' devera ser entre a numeracao disponibilizada para componentes de tabela A Pagar
				lRet := .F.
			EndIf
			//-- Compara os campos Calcula Sobre e Sub Faixa para veirificacao das faixas reservadas.
			If lRet .And. !Empty(M->DT3_TIPFAI) .And. DT3->(FieldPos("DT3_FAIXA2")) > 0 .And. !Empty(M->DT3_FAIXA2)
				If M->DT3_TIPFAI <  "50" .And. M->DT3_FAIXA2 >= "50"
					Help(' ', 1, 'TMSA03005') //A 'Sub Faixa' devera ser entre a numeracao disponibilizada para componentes de tabela A Receber.
					lRet := .F.
				ElseIf M->DT3_TIPFAI >= "50" .And. M->DT3_FAIXA2 < "50"
					Help(' ', 1, 'TMSA03006') //A 'Sub Faixa' devera ser entre a numeracao disponibilizada para componentes de tabela A Pagar.
					lRet := .F.
				EndIf
			EndIf
			
			If lRet .And. M->DT3_TIPFAI = '14' .And. M->DT3_FAIXA <> M->DT3_TIPFAI
				lRet	:= .F.
				Help(' ', 1, 'TMSA03007') //--A 'Sub Faixa' dever� ser igual ao campo 'Calcula Sobre' quando o campo for igual a '14'.                                        
			EndIf
			
		EndIf
	EndIf
	
	//-- Se o componente for calculado por PESO MERCADORIA / PESO TRANSPORTADO (DT3_TIPFAI) ou
	//-- se a Faixa for por PESO MERCADORIA / PESO TRANSPORTADO (DT3_FAIXA)
	//-- se a Sub Faixa por PESO MERCADORIA / PESO TRANSPORTADO (DT3_FAIXA2)
	//-- preencher o campo Calc. Peso c/ 2-Peso cubado
	If lRet
		If	M->DT3_TIPFAI == StrZero(1,nTipFai ) .Or. M->DT3_TIPFAI == StrZero(51,nTipFai) .Or.;
			M->DT3_TIPFAI == StrZero(62,nFaixa ) .Or. M->DT3_FAIXA  == StrZero(62,nFaixa ) .Or.;
			M->DT3_FAIXA  == StrZero(1,nFaixa ) .Or. M->DT3_FAIXA  == StrZero(51,nFaixa ) .Or.;
			( DT3->(FieldPos("DT3_FAIXA2")) > 0 .And. ( M->DT3_FAIXA2 == StrZero(1,nFaixa) .Or. M->DT3_FAIXA2 == StrZero(51,nFaixa)) )
			M->DT3_CALPES := StrZero(2,Len(DT3->DT3_CALPES))
			//-- Caso contrario, preencher c/ 0	-Nao utiliza
		Else
			M->DT3_CALPES := StrZero(0,Len(DT3->DT3_CALPES))
		EndIf
		//-- Se o componente informado for > 50, preencher os campos 'Agrupa Valor' e 'Apl. Desconto' c/ Nao Utiliza
		If M->DT3_TIPFAI > StrZero(50,nTipFai)
			M->DT3_AGRVAL := StrZero(0,Len(DT3->DT3_AGRVAL))
			M->DT3_APLDES := StrZero(0,Len(DT3->DT3_APLDES))
		EndIf
	EndIf
	
ElseIf cCampo == 'M->DT3_CALPES'
	//-- Se o componente for calculado pelo peso, nao permitir digitar no campo Calc. Peso o valor 0-Nao Utiliza
	If	M->DT3_TIPFAI == StrZero(1,nTipFai) .Or.	M->DT3_TIPFAI == StrZero(51,nTipFai) .Or. M->DT3_TIPFAI == StrZero(62,nTipFai)
		lRet := ( M->DT3_CALPES != StrZero(0,Len(DT3->DT3_CALPES)) )
	EndIf
ElseIf cCampo == 'M->DT9_CALPES'
	If	GDFieldGet('DT9_CALPES',n) != StrZero(0,Len(DT9->DT9_CALPES))
		lRet := ( M->DT9_CALPES != StrZero(0,Len(DT9->DT9_CALPES)) )
	EndIf
ElseIf cCampo == 'M->DJE_CMPREL'
	cTipFai:= Posicione('DT3', 1, xFilial('DT3') + M->DJE_CMPREL, 'DT3_TIPFAI')
	
	If cTipFai >=  StrZero(50,Len(DT3->DT3_TIPFAI))
		Help(' ', 1, 'TMSA03011') //Somente � permitido selecionar componentes de tabela A Receber.
		lRet := .F.
	ElseIf cTipFai == StrZero(16,Len(DT3->DT3_TIPFAI))
		Help(' ', 1, 'TMSA03008') //Nao � permitido selecionar componentes que calcula sobre 16-Herda Valor
		lRet:= .F.
	EndIf
	
ElseIf cCampo == 'M->DT3_TXADIC'
	If M->DT3_TIPFAI == StrZero(17,nTipFai).And. M->DT3_TXADIC == StrZero(1,Len(DT3->DT3_TXADIC))
		Help(' ', 1, 'TMSA03009') //Nao � permitido selecionar componentes com calcula sobre 17 com Taxa Adicional "Sim".
		lRet:= .F.
	EndIf	

ElseIf cCampo == 'M->DT3_CODPAS'
	If M->DT3_CODPAS == 'TF'
		Help(' ', 1, 'TMSA03016') //N�o � permitido a inclus�o do c�digo 'TF' para o compomente de frete esse, o c�digo e reservado para o Total do Frete.
		lRet:= .F.
	EndIf
EndIf


Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA030BFx� Autor � Eduardo de Souza      � Data � 05/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � x3_Box do campo DT3_FAIXA                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA030BFx()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSA030BFx()

Local cRet := ""
Local nCnt := 0
Local aRet := TMSValField("TIPFAI",.F.,,.F.,.T.)

If ValType(aRet) == "A"
	For nCnt := 1 To Len(aRet)
		If !Empty(cRet)
			cRet += ";"
		EndIf
		cRet += aRet[nCnt,01] + "=" + aRet[nCnt,2]
	Next nCnt
EndIf

Return cRet


