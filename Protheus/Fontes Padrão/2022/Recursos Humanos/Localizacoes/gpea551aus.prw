/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Observacao:
Em 14/12/2011 foi informado sobre o interropimento do projeto Australia, sendo 
assim todos os fontes ja realizados serao guardados para futuras utilizacoes
no retorno do projeto.
Situacao:
Este cadastro ainda n�o foi finalizado.
Pendencias:
- Implementar validacoes para as funcoes Gp551PosLine e Gp551PosVal
- Aguardar a entrega dos F3 FBT001, FBT002 e FBT003 respectivamente dos campos 
RHU_PRETIT, RHU_NUMCX e RHU_ATBASE
- Com a entrega dos F3 acima testar Inclusao , Alteracao, Visualizacao e Exclusao
- Testar a funcao FBTFunc que depende de massa de dados deste cadastro para gerar
o retorno esperado da funcao.
- Os alertas deixados nas funcoes Gp551PosLine e Gp551PosVal sao para testar se a
validacao estava sendo feita neste fonte ou no GPEA551, talves seja necessario 
implementar no model deste fonte a seguinte instrucao
//oMdlRHU   := FWLoadModel( 'GPEA551' )
 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/
#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA551AUS.CH'
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEA551AUS� Autor � Emerson Campos                    � Data � 12/12/2011 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Benef�cios Adicionais (Fringe Benefits) (RHU)                ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA551AUS()                                                             ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���            �          �                �                                            ���
���������������������������������������������������������������������������������������Ĵ��
���            �          �                �                                            ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
Function GPEA551AUS 
Local cFiltraRh
Local oBrwSRA
Local xRetFilRh

oBrwSRA := FWmBrowse():New()		
oBrwSRA:SetAlias( 'SRA' )
oBrwSRA:SetDescription(STR0001)	//"Benef�cios Adicionais"
	
//Inicializa o filtro utilizando a funcao FilBrowse
xRetFilRh := CHKRH(FunName(),"SRA","1")
If ValType(xRetFilRh) == "L"
	cFiltraRh := if(xRetFilRh,".T.",".F.")
Else
	cFiltraRh := xRetFilRh
EndIf

//Filtro padrao do Browse conforme tabela SRA (Funcion�rios)
oBrwSRA:SetFilterDefault(cFiltraRh)

oBrwSRA:DisableDetails()	
oBrwSRA:Activate()
Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Emerson Campos        � Data �12/12/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002  Action 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.GPEA551' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA551' 	OPERATION 4 ACCESS 0 //"Manuten��o"
ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA551' 	OPERATION 5 ACCESS 0 //"Excluir"
Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Emerson Campos        � Data �12/12/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Benef�cios Adicionais (Fringe Benefits)(RHU)                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()
//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRHU 		:= FWFormStruct(1, 'RHU', /*bAvalCampo*/,/*lViewUsado*/)
Local oMdlRHU

// Blocos de codigo do modelo
Local bLinePos		:= {|oMdl| Gp551PosLine(oMdl)}
Local bPosValid 	:= {|oMdl| Gp551PosVal(oMdl)}
    
// REMOVE CAMPOS DA ESTRUTURA
//oStruRHU:RemoveField('RHQ_MAT')
 
//Atribui 
//oStruRHU:SetProperty( 'RHQ_ORIGEM'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'S'" ) ) 

// Cria o objeto do Modelo de Dados
oMdlRHU := MPFormModel():New('GPEA551', /*bPreValid*/ , bPosValid, /*bCommit*/, /*bCancel*/)
//oMdlRHU   := FWLoadModel( 'GPEA551' )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oMdlRHU:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oMdlRHU:AddGrid( 'RHUDETAIL', 'SRAMASTER', oStruRHU, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
// Faz relaciomaneto entre os compomentes do model
oMdlRHU:SetRelation('RHUDETAIL', {{'RHU_FILIAL', 'xFilial("RHU")'}, {'RHU_MAT', 'RA_MAT'}}, RHU->(IndexKey(1)))

//Define Chave �nica
oMdlRHU:GetModel('RHUDETAIL'):SetUniqueLine({'RHU_CODBEN'})

//Permite grid sem dados
oMdlRHU:GetModel('RHUDETAIL'):SetOptional(.T.)

oMdlRHU:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRHU:GetModel('SRAMASTER'):SetOnlyQuery(.T.)
//oMdlRHU:SetOnlyQuery('SRAMASTER')

// Adiciona a descricao do Modelo de Dados
oMdlRHU:SetDescription(OemToAnsi(STR0006))  // "Cadastro Benef�cios Adicionais"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRHU:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0007)) // "Funcion�rios"
oMdlRHU:GetModel('RHUDETAIL'):SetDescription(OemToAnsi(STR0001)) // "Benef�cios Adicionais"
Return oMdlRHU	
	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Emerson               � Data � 11/10/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de Benef�cios Adicionais   ���
���          � (Fringe Benefits)(RHU)                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()	
Local oView
//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA551')
// Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRHU := FWFormStruct(2, 'RHU')

// Cria o objeto de View
oView := FWFormView():New()

// Remove campos da estrutura e ajusta ordem dos campos na view
//Remove
oStruRHU:RemoveField('RHU_MAT')	
 
// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RHU', oStruRHU, 'RHUDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('INFERIOR', 90)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RHU', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_RHU', OemToAnsi(STR0007)) // "Cadastro Programa��o de Rateio"
Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp551LinePos� Autor � Emerson Campos        � Data �12/12/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao responsavel valida��o linha Cad Benef�cios Adicionais ���
���          � (Fringe Benefits)(RHU)                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp551LinePos( oMdlRHU )                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRHU = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Gp551PosLine( oMdlRHU )	
Local lRetorno		:= .T.	
 Alert("Linha")		
Return lRetorno

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp551PosVal � Autor � Emerson Campos        � Data �12/12/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos-validacao do Cadastro de  Benef�cios Adicionais          ���
���          � (Fringe Benefits)(RHU)                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp551PosVal( oMdlRHU )                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRHU = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Gp551PosVal( oMdlRHU )
Local oModel     	:= oMdlRHU:GetModel('RHUDETAIL')	
Local lRetorno      := .T.
Alert("FORM")
Return lRetorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FBTFunc  � Autor � Emerson Campos        � Data �12/12/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o que retorna os dados agrupados por categoria do     ���
���          � benef�cio no formato de um array                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FBTFunc(cFilDe, cFilAte, dDtDe, dDtAte)                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cFilDe  (Caracter) = Filial De                             ���
���          � cFilAte (Caracter) = Filial Ate                            ���
���          � dDtDe   (Date)     = Data De                               ���
���          � dDtAte  (Date)     = Data Ate                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aFbtFunc (Array)                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gper181Aus                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FBTFunc(cFilDe, cFilAte, dDtDe, dDtAte)
Local aFbtFunc 	:= {}
Local cChave	:= xFilial("RHU")+cCodEmp+TR2->TR2_COD

	dbSelectArea("RHU")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(cChave)
		While !Eof()
			If cFilDe >= RHU->RHU_FILIAL .OR. cFilAte <= RHU->RHU_FILIAL
				If (dDtDe >= RHU->RHU_DTINI .AND. dDtDe <= RHU->RHU_DTFIM .OR.;
					dDtDe >= RHU->RHU_DTINI .AND. Empty(RHU->RHU_DTFIM));
					.OR.;
					(dDtAte >= RHU->RHUDTINI  .OR. dDtAte <= RHU->RHU_DTFIM .OR.;
					dDtAte >= RHU->RHU_DTINI .AND. Empty(RHU->RHU_DTFIM));	
			        
			 		cLetCat 	:= fPosTab("S006",RHU->RHU_CATBEN,"=",4,,,,6)
			 		cDescCat	:= fPosTab("S006",RHU->RHU_CATBEN,"=",4,,,,5)
			 		
					Aadd(aFbtFunc,{cLetCat			,;	// Letra da Categoria
					               cDescCat			,;	// Descricao das Categoria 
					               RHU->RHU_MAT   	,;	// Matricula 
					               RHU->RHU_PRETIT	,;	// Prefixo do Titulo
					               RHU->RHU_NUMTIT	,;	// Nro do Titulo 
					               RHU->RHU_PARTIT	,;	// Parcela do Titulo
					               RHU->RHU_TIPTIT	,;	// Tipo do Titulo
					               RHU->RHU_FORTIT	,;	// Fornecedor
					               RHU->RHU_LOJFOR	,;	// Loja
					               RHU->RHU_ATBASE	,;	// Codigo do Bem (Ativo)
					               RHU->RHU_ATITEM	,;	// Item do Bem 
					               RHU->RHU_NOTA  	,;	// Nota do Bem 
					               RHU->RHU_SERIE 	,;	// Serie da Nota
					               RHU->RHU_ITNOTA	,;	// Item da Nota
					               RHU->RHU_NUMCX 	,;	// Numero Caixa
					               RHU->RHU_CAIXA 	,;	// Caixinha
					               RHU->RHU_TIPOCX	,;	// Tipo Movimento Caixa
					               RHU->RHU_VALBEN	,;	// Valor do Beneficio
					               RHU->RHU_CONTR 	,;	// Valor de Contribuicao
					               RHU->RHU_REDUC  	 ;	// Valor de Desconto
					               })
					cLetCat 	:= ""
					cDescCat	:= ""
				EndIf
			EndIf			
			dbSkip()
		EndDo
	EndIf
    
	//Ordena o aFbtFunc por Letra da Categoria + Matricula
	aFbtFunc      := ASort(aFbtFunc,,,     { |x,y| x[1]+x[3]<y[1]+y[3] })
	
Return aFbtFunc

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCalVlrBen� Autor � Emerson Campos     � Data � 13/12/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para alimnetar o campo RHU_VALBEN via gatilho       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA551AUS                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function fCalVlrBen() 
Local oModel 	:= FWModelActive()
Local oModelRHU := oModel:GetModel( 'RHUDETAIL' )
Local nValor	:= 0
Local nVlrDoc 	:= 0
Local nPercen	:= 0
Local nContr	:= 0
Local nReduc	:= 0

nVlrDoc := oModelRHU:getValue("RHU_VALOR")
nPercen	:= oModelRHU:getValue("RHU_PERCEN")
nContr	:= oModelRHU:getValue("RHU_CONTR")
nReduc	:= oModelRHU:getValue("RHU_REDUC")

If !Empty(nVlrDoc)
	nValor := nVlrDoc
	If!Empty(nPercen)
		nValor := (nVlrDoc * nPercen) / 100
	EndIf  	
    
	If!Empty(nContr)
		nValor := nValor - nContr  
	EndIf
	
	If!Empty(nReduc)
		nValor := nValor - nReduc
	EndIf
EndIf

Return nValor

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �vldRhuOri � Autor � Emerson Campos     � Data � 13/12/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para validar se os campos estao de acordo com a     ���
���          � origem selecionada                                         ���
���          � 1 - Titulo  Preencher campos:                              ���
���          � 		o	Prefixo    (RHU_PRETIT)                           ���
���          � 		o	Nro T�tulo (RHU_NUMTIT)                           ���
���          � 		o	Parcela    (RHU_PARTIT)                           ���
���          � 		o	Tipo       (RHU_TIPTIT)                           ���
���          � 		o	Fornecedor (RHU_FORTIT)                           ���
���          � 		o	Loja       (RHU_LOJFOR)                           ���
���          � 2 - Ativo  Preencher campos:                               ���
���          � 		o	Cod. Bem   (RHU_ATBASE)                           ���
���          � 		o	Item       (RHU_ATITEM)                           ���
���          � 		o	Nota       (RHU_NOTA)                             ���
���          � 		o	Item Nota  (RHU_ITNOTA)                           ���
���          � 		o	S�rie Nota (RHU_SERIE)                            ���
���          � 3 - Caixa  Preencher campos:                               ���
���          � 		o	Numero     (RHU_NUMCX)                            ���
���          � 		o	Caixinha   (RHU_CAIXA)                            ���
���          � 		o	Tipo Movim (RHU_TIPOCX)                           ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA551AUS                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function vldRhuOri(cOrigCamp)
Local lRetorno	:= .T.
Local oModel 	:= FWModelActive()
Local oModelRHU := oModel:GetModel( 'RHUDETAIL' )

If Empty(oModelRHU:getValue("RHU_ORIGEM"))
	Help("",1,"GP551ORGNSELEC")	//"O campo origem ainda n�o foi selecionado."  "Necess�rio escolher a origem antes de preencher os dados."
	lRetorno := .F.	
ElseIf oModelRHU:getValue("RHU_ORIGEM") <> cOrigCamp
	Help("",1,"GP551ORGNINVA")	//"Este campo n�o deve ser preenchido."  "Preencha apenas os campos relativos a origem selecionada."
 	lRetorno := .F.
EndIf
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldRhuPerc� Autor � Emerson Campos     � Data � 14/12/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para validar o campo de percentual RHU_PERCEN para  ���
���          � que receba valores entre 0,01% a 100,00%                   ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA551AUS                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function VldRhuPerc()
Local lRetorno	:= .T. 
Local oModel 	:= FWModelActive()
Local oModelRHU := oModel:GetModel( 'RHUDETAIL' )

If oModelRHU:getValue("RHU_PERCEN") > 100
	Help("",1,"GP551VLDPERCE")	//"Percentual superior a 100,00%."  "Selecione um percentual entre 0,01% � 100,00%."
	lRetorno	:= .F.	
EndIf

Return lRetorno