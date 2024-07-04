#Include 'TmsA410.ch'
#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA410  � Autor � Antonio C Ferreira    � Data �16.05.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Regras de Tributacao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Mauro Paladini �21/08/13�      � Conversao da rotina para MVC          ���
���Mauro Paladini �06/12/13�      �Ajustes para o funcionamento do Mile   ���
���Mauro Paladini �25/02/14�      �AtuSX para compatibilizacao de campos  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSA410()

Local oBrowse := Nil
Private aRotina := MenuDef()
Private cCadastro	:= STR0001 //'Regras de Tributacao'

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DUF")
oBrowse:SetDescription(STR0001) // "Regras de tributacao"
oBrowse:Activate()
RetIndex('DUF') 

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �21.08.2013���
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

Local oModel	:= Nil
Local oStruCDUF := Nil 
Local oStruIDUG := Nil
Local aMemoDUG 	:= { { 'DUG_CODMSG' , 'DUG_MSGFIS' } }

// Validacoes dos Fields
Local bPreValid	:= Nil
Local bPosValid := Nil 
Local bComValid := Nil
Local bCancel	:= Nil
Local aCpoCheck := {'DUG_CODPAS','DUG_ESTORI','DUG_ESTDES','DUG_ESTDEV'}

// Validacoes da Grid
Local bLinePost	:= { |oMdl| PosVldLine(oMdl) }

Private oModel2	:= oModel

oStruCDUF := FwFormStruct( 1, "DUF") 
oStruIDUG := FwFormStruct( 1, "DUG")

If DUG->(FieldPos("DUG_SATIV")) > 0
	Aadd(aCpoCheck,"DUG_SATIV")
EndIf
If DUG->(FieldPos("DUG_CONSIG")) > 0
	Aadd(aCpoCheck,"DUG_CONSIG")
EndIf	
If DUG->(FieldPos("DUG_ESTVEI")) > 0
	Aadd(aCpoCheck,"DUG_ESTVEI")
EndIf

oModel:= MpFormMOdel():New("TMSA410",  /*bPreValid*/ , /*bPosValid*/ , /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription(STR0001) 		// "Regras de tributacao"

//������������������������������������������Ŀ
//� Tratamento especial para os campos MEMOS �
//��������������������������������������������

FWMemoVirtual( oStruIDUG, aMemoDUG)

oModel:AddFields("MdFieldCDUF",Nil,oStruCDUF,/*prevalid*/,,/*bCarga*/)
                              
oModel:SetPrimaryKey({ "DUF_FILIAL","DUF_REGTRI","DUF_TIPFRE" })
oModel:AddGrid("MdGridIDUG", "MdFieldCDUF" /*cOwner*/, oStruIDUG , /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,  /*bLoad*/)
oModel:SetRelation( "MdGridIDUG", { { "DUG_FILIAL" , 'xFilial("DUG")'  }, { "DUG_REGTRI", "DUF_REGTRI" } , { "DUG_TIPFRE","DUF_TIPFRE"} }, DUG->( IndexKey( 1 ) ) )

oModel:GetModel( "MdGridIDUG" ):SetUniqueLine( aCpoCheck )
oModel:GetModel( "MdGridIDUG" ):SetMaxLine(9999)

Return ( oModel )                   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �20.08.2013���
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

Local oModel 	:= FwLoadModel("TMSA410")
Local oView 	:= Nil

Local oStruCDUF 	:= FwFormStruct( 2, "DUF") 
Local oStruIDUG 	:= FwFormStruct( 2, "DUG") 

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField('VwFieldCDUF', oStruCDUF , 'MdFieldCDUF') 
oView:AddGrid( 'VwGridIDUG', oStruIDUG , 'MdGridIDUG')

oView:CreateHorizontalBox("SUPERIOR",20)
oView:CreateHorizontalBox("INFERIOR",80)              

oView:EnableTitleView('VwFieldCDUF')
oView:EnableTitleView('VwGridIDUG',STR0013) //"Itens da Regra de Tributa��o"

oView:AddIncrementField( 'VwGridIDUG', 'DUG_ITEM' ) 

oView:SetOwnerView("VwFieldCDUF","SUPERIOR")
oView:SetOwnerView("VwGridIDUG","INFERIOR")

Return(oView)




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �14.08.2013���
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

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA410" OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA410" OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA410" OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA410" OPERATION 5 ACCESS 0   //"Excluir"

If ExistBlock("TMA410MNU")
	ExecBlock("TMA410MNU",.F.,.F.)
EndIf

Return ( aRotina )

 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PosVldLine  Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Faz a validacao da linha na GRID (LineOk)                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � EXPL1 - Verdadeiro ou Falso                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PosVldLine(oMld)

	Local lRet 		:= .T.
	Local oModel 	:= FWModelActive()
	Local cTes 		:= oModel:GetValue( "MdGridIDUG" , "DUG_TES" )
	
	lRet := TmsChkTES('4', cTes )
	
Return lRet 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TMSA410Vl � Autor � Henry Fila           � Data �13.11.2002���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida o cabecalho da regra                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Tmsa410Vl()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���               �        �      �                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Function Tmsa410Vl()

Local lRet     := .T.

DUF->(dbSetOrder(1))
If DUF->(MsSeek(xFilial("DUF")+M->DUF_REGTRI+M->DUF_TIPFRE)) .Or. If(Empty(M->DUF_TIPFRE),.F.,DUF->(MsSeek(xFilial("DUF")+M->DUF_REGTRI+If(M->DUF_TIPFRE$"12","3",""))))
	Help(" ",1,"JAGRAVADO") //"Ja existe registro com esta informacao. 
	lRet := .F.
Endif	

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA410Des� Autor �Rodrigo de A Sartorio  � Data �12.12.2003���         `
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilha informacao na descricao do ramo de atividade       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA410Des()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Mauro Paladini �21/08/13�      � Conversao da rotina para MVC          ���
���               �        �      �                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSA410Des()

Local cConteudo	:= &(ReadVar())
Local cDescricao	:= {}
Local lHeader		:= IsInCallStack("TMSA411") // Ajuste pois o fonte TMSA411 utiliza 
Local oModelAtual  	:= Iif(IsInCallStack("TMSA410"), FWModelActive(), {})
Local oModelGrid		:= Iif(IsInCallStack("TMSA410"),oModelAtual:GetModel( "MdGridIDUG" ), {})
Local nPosicao    	:= Iif(IsInCallStack("TMSA410"),GdFieldPos( "DUG_DSATIV", oModelGrid:aHeader ), 0)


If !lHeader
	oModelAtual	:= FWModelActive()
	oModelGrid		:= oModelAtual:GetModel( "MdGridIDUG" )
	nPosicao		:= GdFieldPos( "DUG_DSATIV", oModelGrid:aHeader )
EndIf

If !Empty(cConteudo) .AND. nPosicao > 0 .AND. !lHeader 

	cDescricao	:= FWGetSX5("T3",cConteudo)
	oModelAtual:SetValue( "MdGridIDUG" , "DUG_DSATIV" , Padr(cDescricao[1][4],TamSx3("DUG_DSATIV")[1] ) )

EndIf	

Return .T.
